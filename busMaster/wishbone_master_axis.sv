`timescale 1ns / 1ps

module wishbone_master_axis #(
    parameter integer ADDR_WIDTH = 32,
    parameter integer DATA_WIDTH = 32,          // Wishbone data width (always 32-bit for AXIS)
    parameter integer TIMEOUT_CYCLES = 1000     // Timeout in clock cycles (~10us @ 100MHz)
)(
    input  logic                    clk,
    input  logic                    rst_n,

    // AXI Stream Slave (Command Input)
    input  logic [7:0]              s_axis_tdata,
    input  logic                    s_axis_tvalid,
    output logic                    s_axis_tready,
    input  logic                    s_axis_tlast, // Optional, can be used to reset packet logic

    // AXI Stream Master (Response Output)
    output logic [7:0]              m_axis_tdata,
    output logic                    m_axis_tvalid,
    input  logic                    m_axis_tready,
    output logic                    m_axis_tlast,
    // Alert to testbench when internal timeout/error occurs
    output logic                    timeout_alert,

    // Wishbone Master Interface
    output logic [ADDR_WIDTH-1:0]   wb_adr_o,
    output logic [DATA_WIDTH-1:0]   wb_dat_o,
    input  logic [DATA_WIDTH-1:0]   wb_dat_i,
    output logic                    wb_we_o,
    output logic                    wb_stb_o,
    output logic                    wb_cyc_o,
    output logic [DATA_WIDTH/8-1:0] wb_sel_o,
    input  logic                    wb_ack_i,
    input  logic                    wb_err_i
);

    // Command Opcodes
    localparam [7:0] CMD_READ  = 8'h00;
    localparam [7:0] CMD_WRITE = 8'h01;

    // Response Codes
    localparam [7:0] RSP_ACK     = 8'hA5;
    localparam [7:0] RSP_SUCCESS = 8'h01;
    localparam [7:0] RSP_ERROR   = 8'hFF;

    // FSM States
    typedef enum logic [4:0] {
        ST_IDLE,
        ST_SEND_CMD_ACK,
        ST_ADDR,
        ST_LEN,
        ST_DUMMY,
        ST_WDATA,
        ST_WB_START,
        ST_WB_WAIT,
        ST_RSP_DATA,
        ST_RSP_STATUS,
        ST_RSP_ERROR,
        ST_TIMEOUT_ERROR
    } state_t;

    state_t state, state_next;

    // Registers
    logic [7:0]              cmd_reg;
    logic [ADDR_WIDTH-1:0]   addr_reg;
    logic [15:0]             len_reg;      // Length in words
    logic [15:0]             word_cnt;     // Counter for words processed
    logic [DATA_WIDTH-1:0]   wdata_reg;
    logic [DATA_WIDTH-1:0]   rdata_reg;
    logic [2:0]              byte_cnt;     // To count bytes (0-3 for Addr/Data, 0-1 for Len)
    logic                    cmd_is_write;
    logic                    wb_error;     // Wishbone error flag
    
    // Timeout counter
    logic [15:0]             timeout_cnt;
    logic                    timeout_expired;

    // Internal signals
    logic                    wb_cycle_done;
    // Expose state-based timeout to TB
    // timeout_alert will be asserted when module enters timeout error state

    // -------------------------------------------------------------------------
    // Timeout Logic
    // -------------------------------------------------------------------------
    
    assign timeout_expired = (timeout_cnt >= TIMEOUT_CYCLES);
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timeout_cnt <= 0;
        end else begin
            // Start timeout when entering WB_WAIT state
            if (state == ST_WB_START) begin
                timeout_cnt <= 0;
            end
            // Increment timeout counter while waiting for Wishbone ACK
            else if (state == ST_WB_WAIT) begin
                if (!wb_ack_i && !wb_err_i) begin
                    timeout_cnt <= timeout_cnt + 1;
                end
            end
            else begin
                timeout_cnt <= 0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Datapath & FSM
    // -------------------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= ST_IDLE;
            byte_cnt     <= 0;
            cmd_reg      <= 0;
            addr_reg     <= 0;
            len_reg      <= 0;
            word_cnt     <= 0;
            wdata_reg    <= 0;
            rdata_reg    <= 0;
            cmd_is_write <= 0;
            wb_error     <= 0;
        end else begin
            state <= state_next;

            // Capture WB error condition
            if (state == ST_WB_WAIT && wb_err_i) begin
                wb_error <= 1;
            end
            
            // Clear error on new command
            if (state == ST_IDLE && s_axis_tvalid && s_axis_tready) begin
                wb_error <= 0;
            end

            // Byte Counter Management
            if (state == ST_ADDR && s_axis_tvalid && s_axis_tready) begin
                if (byte_cnt == 3) byte_cnt <= 0;
                else byte_cnt <= byte_cnt + 1;
            end 
            else if (state == ST_LEN && s_axis_tvalid && s_axis_tready) begin
                if (byte_cnt == 1) byte_cnt <= 0;
                else byte_cnt <= byte_cnt + 1;
            end
            else if (state == ST_WDATA && s_axis_tvalid && s_axis_tready) begin
                 if (byte_cnt == 3) byte_cnt <= 0;
                 else byte_cnt <= byte_cnt + 1;
            end 
            else if (state == ST_RSP_DATA && m_axis_tvalid && m_axis_tready) begin
                 if (byte_cnt == 3) byte_cnt <= 0;
                 else byte_cnt <= byte_cnt + 1;
            end

            // Command Capture
            if (state == ST_IDLE && s_axis_tvalid && s_axis_tready) begin
                cmd_reg      <= s_axis_tdata;
                cmd_is_write <= (s_axis_tdata == CMD_WRITE);
                byte_cnt     <= 0;
            end

            // Address Capture (shift left by 8 and append new byte)
            if (state == ST_ADDR && s_axis_tvalid && s_axis_tready) begin
                addr_reg <= (addr_reg << 8) | s_axis_tdata;
            end

            // Length Capture (shift left by 8 and append new byte)
            if (state == ST_LEN && s_axis_tvalid && s_axis_tready) begin
                len_reg <= (len_reg << 8) | s_axis_tdata;
                word_cnt <= 0; // Reset word counter
            end

            // Write Data Capture (shift left by 8 and append new byte)
            if (state == ST_WDATA && s_axis_tvalid && s_axis_tready) begin
                wdata_reg <= (wdata_reg << 8) | s_axis_tdata;
            end

            // Read Data Capture
            if (state == ST_WB_WAIT && wb_ack_i) begin
                rdata_reg <= wb_dat_i;
            end

            // Increment Word Count / Address
            if (state == ST_WB_WAIT && wb_ack_i) begin
                 word_cnt <= word_cnt + 1;
                 addr_reg <= addr_reg + 4;  // Increment by one 32-bit word
            end
        end
    end

    // FSM Next State Logic
    always_comb begin
        state_next = state;
        s_axis_tready = 0;
        
        m_axis_tvalid = 0;
        m_axis_tdata  = 0;
        m_axis_tlast  = 0;

        wb_cyc_o = 0;
        wb_stb_o = 0;
        wb_we_o  = 0;
        wb_adr_o = addr_reg;
        wb_dat_o = wdata_reg;
        wb_sel_o = 4'b1111;  // All bytes selected for 32-bit data
        timeout_alert = 0;

        case (state)
            ST_IDLE: begin
                s_axis_tready = 1;
                if (s_axis_tvalid) begin
                    state_next = ST_SEND_CMD_ACK;
                end
            end

            ST_SEND_CMD_ACK: begin
                // Emit ACK for Command
                m_axis_tvalid = 1;
                m_axis_tdata  = RSP_ACK;
                if (m_axis_tready) begin
                    state_next = ST_ADDR;
                end
            end

            ST_ADDR: begin
                s_axis_tready = 1;
                if (s_axis_tvalid) begin
                    if (byte_cnt == 3) begin
                        state_next = ST_LEN;
                    end
                end
            end
            
            ST_LEN: begin
                s_axis_tready = 1;
                if (s_axis_tvalid) begin
                    if (byte_cnt == 1) begin
                        state_next = ST_DUMMY;
                    end
                end
            end

            ST_DUMMY: begin
                s_axis_tready = 1;
                if (s_axis_tvalid) begin
                    if (cmd_is_write)
                        state_next = ST_WDATA;
                    else
                        state_next = ST_WB_START;
                end
            end

            ST_WDATA: begin
                s_axis_tready = 1;
                if (s_axis_tvalid) begin
                    if (byte_cnt == 3) begin
                        state_next = ST_WB_START;
                    end
                end
            end

            ST_WB_START: begin
                // Initiate Cycle
                wb_cyc_o = 1;
                wb_stb_o = 1;
                wb_we_o  = cmd_is_write;
                state_next = ST_WB_WAIT;
            end

            ST_WB_WAIT: begin
                wb_cyc_o = 1;
                wb_stb_o = 1;
                wb_we_o  = cmd_is_write;
                
                // Check for timeout
                if (timeout_expired) begin
                    state_next = ST_TIMEOUT_ERROR;
                end
                // Check for Wishbone error
                else if (wb_err_i) begin
                    state_next = ST_RSP_ERROR;
                end
                // Handle successful ACK
                else if (wb_ack_i) begin
                    if (cmd_is_write) begin
                        if ((word_cnt + 1) < len_reg)
                            state_next = ST_WDATA;
                        else 
                            state_next = ST_RSP_STATUS; 
                    end else begin
                        state_next = ST_RSP_DATA;
                    end
                end
            end

            ST_RSP_DATA: begin
                m_axis_tvalid = 1;
                case (byte_cnt)
                    3'd0: m_axis_tdata = (rdata_reg >> 24) & 8'hFF;
                    3'd1: m_axis_tdata = (rdata_reg >> 16) & 8'hFF;
                    3'd2: m_axis_tdata = (rdata_reg >> 8)  & 8'hFF;
                    3'd3: m_axis_tdata = rdata_reg & 8'hFF;
                endcase
                
                // Assert TLAST on the very last byte of the transaction
                if (byte_cnt == 3 && word_cnt == len_reg) m_axis_tlast = 1;

                if (m_axis_tready) begin
                    if (byte_cnt == 3) begin
                        if (word_cnt < len_reg)
                             state_next = ST_WB_START;
                        else 
                             state_next = ST_IDLE;
                    end
                end
            end

            ST_RSP_STATUS: begin
                // Final completion status (success)
                m_axis_tvalid = 1;
                m_axis_tdata = RSP_SUCCESS;
                m_axis_tlast = 1;
                if (m_axis_tready) begin
                    state_next = ST_IDLE;
                end
            end
            
            ST_RSP_ERROR: begin
                // Wishbone error response
                m_axis_tvalid = 1;
                m_axis_tdata = RSP_ERROR;
                m_axis_tlast = 1;
                if (m_axis_tready) begin
                    state_next = ST_IDLE;
                end
            end
            
            ST_TIMEOUT_ERROR: begin
                // Timeout error response
                m_axis_tvalid = 1;
                m_axis_tdata = RSP_ERROR;
                m_axis_tlast = 1;
                timeout_alert = 1;
                if (m_axis_tready) begin
                    state_next = ST_IDLE;
                end
            end
        endcase
    end

endmodule
