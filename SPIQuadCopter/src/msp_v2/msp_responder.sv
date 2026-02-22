`default_nettype none
`timescale 1ns / 1ps

/**
 * MSP Response Generator
 * 
 * Takes validated packet, generates response based on command.
 * Pipeline stage 2: Command processing and response generation
 */
module msp_responder #(
    parameter MAX_PAYLOAD = 16
) (
    input  wire        clk,
    input  wire        rst,
    
    // Packet input from msp_rx - packed array for yosys compatibility
    input  wire [7:0]  pkt_cmd,
    input  wire [7:0]  pkt_len,
    input  wire [MAX_PAYLOAD*8-1:0] pkt_payload,
    input  wire        pkt_valid,
    output reg         pkt_ready,
    
    // Response output to msp_tx - packed array for yosys compatibility
    output reg  [7:0]  resp_cmd,
    output reg  [7:0]  resp_len,
    output reg  [MAX_PAYLOAD*8-1:0] resp_payload,
    output reg         resp_valid,
    input  wire        resp_ready,
    
    // Version info inputs
    input  wire [7:0]  fc_version_major,
    input  wire [7:0]  fc_version_minor,
    input  wire [7:0]  fc_version_patch,
    input  wire [31:0] api_version,
    input  wire [31:0] fc_variant
);

    // MSP Command IDs
    localparam [7:0] MSP_API_VERSION     = 8'd1;
    localparam [7:0] MSP_FC_VARIANT      = 8'd2;
    localparam [7:0] MSP_FC_VERSION      = 8'd3;
    localparam [7:0] MSP_BOARD_INFO      = 8'd4;
    localparam [7:0] MSP_BUILD_INFO      = 8'd5;
    localparam [7:0] MSP_NAME            = 8'd10;
    localparam [7:0] MSP_IDENT           = 8'd100;
    localparam [7:0] MSP_STATUS          = 8'd101;
    localparam [7:0] MSP_MOTOR_COUNT     = 8'd104;
    localparam [7:0] MSP_SET_PASSTHROUGH = 8'd245;
    
    // State machine - using localparams for iverilog compatibility
    localparam [1:0]
        S_IDLE     = 2'd0,
        S_GENERATE = 2'd1,
        S_OUTPUT   = 2'd2;
    
    reg [1:0] state;
    
    // Response generation - registered for timing
    reg [7:0] gen_len;
    reg [7:0] gen_payload [0:MAX_PAYLOAD-1];
    reg [7:0] cmd_latched;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= S_IDLE;
            pkt_ready <= 1'b1;
            resp_valid <= 1'b0;
            resp_cmd <= 8'd0;
            resp_len <= 8'd0;
            resp_payload <= {(MAX_PAYLOAD*8){1'b0}};
            cmd_latched <= 8'd0;
            gen_len <= 8'd0;
        end else begin
            case (state)
                S_IDLE: begin
                    pkt_ready <= 1'b1;
                    resp_valid <= 1'b0;
                    
                    if (pkt_valid) begin
                        cmd_latched <= pkt_cmd;
                        pkt_ready <= 1'b0;
                        state <= S_GENERATE;
                    end
                end
                
                S_GENERATE: begin
                    // Generate response based on command
                    // This is the only combinational decode - shallow
                    resp_cmd <= cmd_latched;
                    
                    case (cmd_latched)
                        MSP_API_VERSION: begin
                            resp_len <= 8'd3;
                            resp_payload[0*8 +: 8] <= 8'h01;              // Protocol version
                            resp_payload[1*8 +: 8] <= api_version[7:0];   // API major
                            resp_payload[2*8 +: 8] <= api_version[15:8];  // API minor
                        end
                        
                        MSP_FC_VARIANT: begin
                            resp_len <= 8'd4;
                            resp_payload[0*8 +: 8] <= fc_variant[7:0];
                            resp_payload[1*8 +: 8] <= fc_variant[15:8];
                            resp_payload[2*8 +: 8] <= fc_variant[23:16];
                            resp_payload[3*8 +: 8] <= fc_variant[31:24];
                        end
                        
                        MSP_FC_VERSION: begin
                            resp_len <= 8'd3;
                            resp_payload[0*8 +: 8] <= fc_version_major;
                            resp_payload[1*8 +: 8] <= fc_version_minor;
                            resp_payload[2*8 +: 8] <= fc_version_patch;
                        end
                        
                        MSP_IDENT: begin
                            resp_len <= 8'd7;
                            resp_payload[0*8 +: 8] <= 8'd250;  // VERSION
                            resp_payload[1*8 +: 8] <= 8'd3;    // MULTITYPE (QuadX)
                            resp_payload[2*8 +: 8] <= 8'd0;    // MSP_VERSION
                            resp_payload[3*8 +: 8] <= 8'd0;    // capability[0]
                            resp_payload[4*8 +: 8] <= 8'd0;    // capability[1]
                            resp_payload[5*8 +: 8] <= 8'd0;    // capability[2]
                            resp_payload[6*8 +: 8] <= 8'd0;    // capability[3]
                        end
                        
                        MSP_STATUS: begin
                            resp_len <= 8'd10;
                            resp_payload[0*8 +: 8] <= 8'd0;  // cycleTime[0]
                            resp_payload[1*8 +: 8] <= 8'd0;  // cycleTime[1]
                            resp_payload[2*8 +: 8] <= 8'd0;  // i2c_errors[0]
                            resp_payload[3*8 +: 8] <= 8'd0;  // i2c_errors[1]
                            resp_payload[4*8 +: 8] <= 8'd0;  // sensors[0]
                            resp_payload[5*8 +: 8] <= 8'd0;  // sensors[1]
                            resp_payload[6*8 +: 8] <= 8'd0;  // flag
                            resp_payload[7*8 +: 8] <= 8'd0;  // current_profile
                            resp_payload[8*8 +: 8] <= 8'd0;  // averageSystemLoad[0]
                            resp_payload[9*8 +: 8] <= 8'd0;  // averageSystemLoad[1]
                        end
                        
                        MSP_MOTOR_COUNT: begin
                            resp_len <= 8'd1;
                            resp_payload[0*8 +: 8] <= 8'd4;  // 4 motors
                        end
                        
                        MSP_SET_PASSTHROUGH: begin
                            // Special: passthrough mode (0-length response)
                            resp_len <= 8'd0;
                        end
                        
                        default: begin
                            // Unknown command - respond with 0 length
                            resp_len <= 8'd0;
                        end
                    endcase
                    
                    state <= S_OUTPUT;
                end
                
                S_OUTPUT: begin
                    resp_valid <= 1'b1;
                    // Only check ready AFTER we've asserted valid for at least one cycle
                    if (resp_valid && resp_ready) begin
                        resp_valid <= 1'b0;
                        state <= S_IDLE;
                    end
                end
                
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
