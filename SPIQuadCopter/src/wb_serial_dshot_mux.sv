/**
 * Wishbone Serial/DSHOT Mux Register (Portable Version)
 * - Simple Wishbone register to select which device (TTL Serial or DSHOT) drives the shared output line.
 * Address: 0x0400 (word-aligned)
 * - Safety features:
 * - One-cycle tristate (global_tristate) on all mode/channel changes.
 * - Unused motor pins actively driven LOW (0) in Passthrough mode to prevent noise (ESC safety).
 * - Serial RX is gated to Logic HIGH (1) in DSHOT mode (UART idle state).
 * - Automatic "Zero-Config" hijacking: Sniffs PC traffic for MSP/Passthrough headers to auto-enable bridge.
 */

module wb_serial_dshot_mux #(
    parameter CLK_FREQ_HZ = 72_000_000
) (
    input  wire        wb_clk_i,
    input  wire        wb_rst_i,
    input  wire [31:0] wb_dat_i,
    input  wire [31:0] wb_adr_i,
    input  wire        wb_we_i,
    input  wire [3:0]  wb_sel_i,
    input  wire        wb_stb_i,
    input  wire        wb_cyc_i,
    output reg  [31:0] wb_dat_o,
    output reg         wb_ack_o,
    output wire        wb_stall_o,
    output wire        mux_sel,  // 0: TTL Serial, 1: DSHOT (Effective)
    output reg  [1:0]  mux_ch,   // 0-3: Which motor channel is target for serial
    output reg         msp_mode, // 0: Passthrough mode, 1: MSP FC protocol mode
    
    // PC Sniffer Interface (115200 Parallel)
    input  wire [7:0]  pc_rx_data,
    input  wire        pc_rx_valid,

    // External Physical Pads
    inout  wire [3:0]  pad_motor,
    
    // Internal Inputs
    input  wire [3:0]  dshot_in,      // From DSHOT Controller
    
    input  wire        serial_tx_i,   // From Serial Bridge
    input  wire        serial_oe_i,   // From Serial Bridge (active high)
    output logic       serial_rx_o    // To Serial Bridge
    
`ifdef SIM_CONTROL
    // Testbench Override Ports (Only visible during simulation)
    , input  wire        tb_mux_force_en
    , input  wire        tb_mux_force_sel
    , input  wire [1:0]  tb_mux_force_ch
`endif
);

    // Only respond to address 0x0400
    wire sel = wb_cyc_i & wb_stb_i & (wb_adr_i[11:2] == 10'h100);

    reg reg_mux_sel; // Internal register

    always_ff @(posedge wb_clk_i) begin
        if (wb_rst_i) begin
            reg_mux_sel <= 1'b1; // Default to DSHOT Mode (Safety)
            mux_ch  <= 2'b0;
            msp_mode <= 1'b0;
            wb_ack_o <= 1'b0;
            wb_dat_o <= 32'b0;
        end else begin
            wb_ack_o <= sel & ~wb_ack_o;
            
            if (sel && ~wb_ack_o) begin
                if (wb_we_i) begin
                    $display("[MUX_DUT %0t] WB WRITE: dat=%h", $time, wb_dat_i);
                    reg_mux_sel <= wb_dat_i[0];
                    mux_ch  <= wb_dat_i[2:1];
                    msp_mode <= wb_dat_i[3];
                end
                wb_dat_o <= {28'b0, msp_mode, mux_ch, reg_mux_sel};
            end
        end
    end

    assign wb_stall_o = 1'b0;

    // ==========================================
    // Automatic Serial Passthrough Sniffer
    // ==========================================
    // Sniff the PC parallel stream (115200) for MSP headers
    
    typedef enum logic [2:0] {
        S_IDLE   = 3'd0,
        S_DOLLAR = 3'd1,
        S_M      = 3'd2,
        S_ARROW  = 3'd3,
        S_SIZE   = 3'd4
    } sniff_state_t;
    
    sniff_state_t sniff_state;
    logic auto_passthrough_active;
    logic [31:0] watchdog_timer;
    
    // 5 Second Timeout
    localparam WATCHDOG_LIMIT = (CLK_FREQ_HZ * 5);

    always_ff @(posedge wb_clk_i) begin
        if (wb_rst_i) begin
            sniff_state <= S_IDLE;
            auto_passthrough_active <= 0;
            watchdog_timer <= 0;
        end else begin
            logic watchdog_reset;
            watchdog_reset = 0;

            if (pc_rx_valid) begin
                $display("[MUX_DUT %0t] pc_rx_data=0x%02x state=%d", $time, pc_rx_data, sniff_state);
                // State Machine to catch "$M<" followed by SIZE then CMD
                case (sniff_state)
                    S_IDLE:   if (pc_rx_data == "$") sniff_state <= S_DOLLAR;
                    S_DOLLAR: if (pc_rx_data == "M") sniff_state <= S_M;      else sniff_state <= S_IDLE;
                    S_M:      if (pc_rx_data == "<") sniff_state <= S_ARROW;  else sniff_state <= S_IDLE;
                    S_ARROW:  sniff_state <= S_SIZE; // Received LEN, next is CMD
                    S_SIZE: begin // Received CMD
                        if (pc_rx_data == 8'hF5 || pc_rx_data == 8'h64) begin 
                            $display("[MUX_DUT %0t] SNIFFER MATCH! Triggering Passthrough", $time);
                            auto_passthrough_active <= 1; 
                            watchdog_reset = 1;
                        end
                        sniff_state <= S_IDLE;
                    end
                endcase
                
                if (auto_passthrough_active) watchdog_reset = 1;
            end
            
            // Watchdog Timer
            if (auto_passthrough_active) begin
                if (watchdog_reset) begin
                    watchdog_timer <= 0;
                end else if (watchdog_timer < WATCHDOG_LIMIT) begin
                    watchdog_timer <= watchdog_timer + 1;
                end else begin
                    auto_passthrough_active <= 0; // Timeout -> Revert to DSHOT
                end
            end
        end
    end

    // ==========================================
    // Mux Selection and Safety Logic
    // ==========================================
    logic effective_mux_sel;
    logic [1:0] effective_mux_ch;

`ifdef SIM_CONTROL
    assign effective_mux_sel = (tb_mux_force_en ? tb_mux_force_sel : (auto_passthrough_active ? 1'b0 : reg_mux_sel));
    assign effective_mux_ch  = (tb_mux_force_en ? tb_mux_force_ch  : mux_ch);
`else
    assign effective_mux_sel = auto_passthrough_active ? 1'b0 : reg_mux_sel;
    assign effective_mux_ch  = mux_ch;
`endif
    
    assign mux_sel = effective_mux_sel;

    // One-cycle global tri-state on mode/channel change
    logic prev_mux_sel;
    logic [1:0] prev_mux_ch;
    logic global_tristate; 

    always_ff @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            prev_mux_sel    <= 1'b1;  // Match reg_mux_sel reset value (DSHOT mode)
            prev_mux_ch     <= 2'b0;
            global_tristate <= 1'b0;
        end else begin
            if ((effective_mux_sel != prev_mux_sel) || (effective_mux_ch != prev_mux_ch)) begin
                global_tristate <= 1'b1;  
                prev_mux_sel    <= effective_mux_sel;
                prev_mux_ch     <= effective_mux_ch;
            end else begin
                global_tristate <= 1'b0;
            end
        end
    end
    
    // ==========================================
    // IO Buffer and Muxing Implementation
    // ==========================================
    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : gen_pads
            wire is_target = (effective_mux_ch == i[1:0]);
            wire dshot_val = dshot_in[i];
            
            logic pad_out_data;
            logic pad_oe_active_high; 

            always_comb begin
                if (effective_mux_sel == 1'b1) begin
                    pad_out_data       = dshot_val;
                    pad_oe_active_high = 1'b1; 
                end else begin
                    if (is_target) begin
                        pad_out_data       = serial_tx_i;
                        pad_oe_active_high = serial_oe_i; 
                    end else begin
                        pad_out_data       = 1'b0;
                        pad_oe_active_high = 1'b0; 
                    end
                end
            end
            
            wire pad_input_val;
            wire final_drive_enable = ~global_tristate & pad_oe_active_high;

`ifdef GOWIN_FPGA
            wire gowin_oen = ~final_drive_enable;
            IOBUF io_inst (
                .O(pad_input_val),  
                .I(pad_out_data),   
                .OEN(gowin_oen),    
                .IO(pad_motor[i])   
            );
`else 
            assign pad_motor[i] = final_drive_enable ? pad_out_data : 1'bz;
            assign pad_input_val = pad_motor[i];
`endif
        end
    endgenerate

    logic [3:0] rx_tap_array;
    generate
        for (i = 0; i < 4; i++) begin : tap_connection
             assign rx_tap_array[i] = gen_pads[i].pad_input_val;
        end
    endgenerate

    logic serial_rx_meta;
    logic serial_rx_sync;

    always_ff @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            serial_rx_meta <= 1'b1; 
            serial_rx_sync <= 1'b1; 
        end else begin
            serial_rx_meta <= rx_tap_array[effective_mux_ch];
            serial_rx_sync <= serial_rx_meta;
        end
    end

    // Gated Serial RX to Bridge
    assign serial_rx_o = (effective_mux_sel == 1'b0) ? serial_rx_sync : 1'b1;

endmodule