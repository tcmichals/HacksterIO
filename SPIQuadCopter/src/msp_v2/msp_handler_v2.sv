`default_nettype none
`timescale 1ns / 1ps

/**
 * MSP Handler V2 - Pipelined Packet Processor
 * 
 * Clean separation into 3 pipeline stages:
 *   Stage 1: msp_rx - byte reception, header validation, buffering
 *   Stage 2: msp_responder - command decode, response generation
 *   Stage 3: msp_tx - response framing and transmission
 * 
 * Benefits:
 *   - Each stage is simple and testable
 *   - Natural pipeline breaks improve timing
 *   - Easy to add new commands in msp_responder
 */
module msp_handler_v2 #(
    parameter CLK_FREQ_HZ = 72_000_000,
    parameter MAX_PAYLOAD = 16
) (
    input  wire        clk,
    input  wire        rst,
    
    // PC UART Interface
    input  wire [7:0]  pc_rx_data,
    input  wire        pc_rx_valid,
    output wire [7:0]  pc_tx_data,
    output wire        pc_tx_valid,
    input  wire        pc_tx_ready,
    
    // Status
    output wire        active,
    
    // Debug outputs
    output wire [2:0]  dbg_rx_state,
    output wire        dbg_rx_timeout,
    
    // Version information
    input  wire [7:0]  fc_version_major,
    input  wire [7:0]  fc_version_minor,
    input  wire [7:0]  fc_version_patch,
    input  wire [31:0] api_version,
    input  wire [31:0] fc_variant
);

    // =========================================================================
    // Pipeline interconnect signals - packed arrays for yosys compatibility
    // =========================================================================
    
    // Stage 1 → Stage 2
    wire [7:0]  rx_pkt_cmd;
    wire [7:0]  rx_pkt_len;
    wire [MAX_PAYLOAD*8-1:0] rx_pkt_payload;
    wire        rx_pkt_valid;
    wire        rx_pkt_ready;
    wire        rx_pkt_error;
    
    // Stage 2 → Stage 3
    wire [7:0]  resp_cmd;
    wire [7:0]  resp_len;
    wire [MAX_PAYLOAD*8-1:0] resp_payload;
    wire        resp_valid;
    wire        resp_ready;
    
    // TX busy
    wire        tx_busy;
    
    // =========================================================================
    // Stage 1: MSP Receiver
    // =========================================================================
    msp_rx #(
        .MAX_PAYLOAD(MAX_PAYLOAD)
    ) u_msp_rx (
        .clk(clk),
        .rst(rst),
        .rx_data(pc_rx_data),
        .rx_valid(pc_rx_valid),
        .pkt_cmd(rx_pkt_cmd),
        .pkt_len(rx_pkt_len),
        .pkt_payload(rx_pkt_payload),
        .pkt_valid(rx_pkt_valid),
        .pkt_error(rx_pkt_error),
        .pkt_ready(rx_pkt_ready),
        .dbg_state(dbg_rx_state),
        .dbg_timeout(dbg_rx_timeout)
    );
    
    // =========================================================================
    // Stage 2: Response Generator
    // =========================================================================
    msp_responder #(
        .MAX_PAYLOAD(MAX_PAYLOAD)
    ) u_msp_responder (
        .clk(clk),
        .rst(rst),
        .pkt_cmd(rx_pkt_cmd),
        .pkt_len(rx_pkt_len),
        .pkt_payload(rx_pkt_payload),
        .pkt_valid(rx_pkt_valid),
        .pkt_ready(rx_pkt_ready),
        .resp_cmd(resp_cmd),
        .resp_len(resp_len),
        .resp_payload(resp_payload),
        .resp_valid(resp_valid),
        .resp_ready(resp_ready),
        .fc_version_major(fc_version_major),
        .fc_version_minor(fc_version_minor),
        .fc_version_patch(fc_version_patch),
        .api_version(api_version),
        .fc_variant(fc_variant)
    );
    
    // =========================================================================
    // Stage 3: MSP Transmitter
    // =========================================================================
    msp_tx #(
        .MAX_PAYLOAD(MAX_PAYLOAD)
    ) u_msp_tx (
        .clk(clk),
        .rst(rst),
        .resp_cmd(resp_cmd),
        .resp_len(resp_len),
        .resp_payload(resp_payload),
        .resp_valid(resp_valid),
        .resp_ready(resp_ready),
        .tx_data(pc_tx_data),
        .tx_valid(pc_tx_valid),
        .tx_ready(pc_tx_ready),
        .busy(tx_busy)
    );
    
    // Active when any stage is processing
    assign active = rx_pkt_valid | resp_valid | tx_busy;

endmodule
