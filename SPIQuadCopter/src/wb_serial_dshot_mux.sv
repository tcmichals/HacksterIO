/**
 * Wishbone Serial/DSHOT Mux Register
 * 
 * Simple Wishbone register to select which device (TTL Serial or DSHOT) drives the shared output line.
 * Address: 0x0400 (word-aligned)
 *   0: TTL Serial
 *   1: DSHOT
 */

module wb_serial_dshot_mux (
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
    output reg         mux_sel,  // 0: TTL Serial, 1: DSHOT
    output reg  [1:0]  mux_ch,   // 0-3: Which motor channel is target for serial
    
    // External Physical Pads
    inout  wire [3:0]  pad_motor,
    
    // Internal Inputs
    input  wire [3:0]  dshot_in,      // From DSHOT Controller
    
    input  wire        serial_tx_i,   // From Serial Bridge
    input  wire        serial_oe_i,   // From Serial Bridge (active high)
    output reg         serial_rx_o    // To Serial Bridge
);

    // Only respond to address 0x0400
    wire sel = wb_cyc_i & wb_stb_i & (wb_adr_i[11:2] == 10'h100);

    always @(posedge wb_clk_i) begin
        if (wb_rst_i) begin
            mux_sel <= 1'b0; // Default to TTL Serial
            mux_ch  <= 2'b0; // Default to Channel 0
            wb_ack_o <= 1'b0;
            wb_dat_o <= 32'b0;
        end else begin
            wb_ack_o <= 1'b0;
            if (sel) begin
                wb_ack_o <= 1'b1;
                if (wb_we_i) begin
                    mux_sel <= wb_dat_i[0];
                    mux_ch  <= wb_dat_i[2:1];
                end
                wb_dat_o <= {29'b0, mux_ch, mux_sel};
            end
        end
    end

    assign wb_stall_o = 1'b0;

    // ==========================================
    // Muxing Logic
    // ==========================================
    
    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : gen_pads
            wire is_target = (mux_ch == i[1:0]);
            
            // Logic for each pad:
            // If Global Mode is DSHOT (mux_sel=1):
            //    -> Drive always with dshot_in[i]. DSHOT is unidirectional output normally.
            //       If we need DSHOT bidirectional (telemetry), that's a future task, assuming output only for now or simple drive.
            // If Global Mode is PASSTHROUGH (mux_sel=0):
            //    -> If this is the TARGET channel:
            //         Drive serial_tx_i IF serial_oe_i is 1.
            //    -> If NOT target:
            //         Drive 0 (Idling).
            
            wire dshot_val = dshot_in[i];
            
            logic pad_out;
            logic pad_oe;
            
            always_comb begin
                if (mux_sel == 1'b1) begin
                    // DSHOT Mode
                    pad_out = dshot_val;
                    pad_oe  = 1'b1; // Always drive in DSHOT mode (unless dshot controller supports tri-state?) assuming push-pull for now
                end else begin
                    // Passthrough Mode
                    if (is_target) begin
                        pad_out = serial_tx_i;
                        pad_oe  = serial_oe_i; // Tri-state control from bridge
                    end else begin
                        pad_out = 1'b0; // Idle low for others
                        pad_oe  = 1'b1; // Drive low
                    end
                end
            end
            
            assign pad_motor[i] = pad_oe ? pad_out : 1'bz;
            
        end
    endgenerate

    // Serial RX Muxing (Reading from the pin)
    // Only valid in Passthrough mode from the active channel
    logic [3:0] pad_motor_in;
    assign pad_motor_in = pad_motor; // Read value from inout

    // Serial RX Muxing (Reading from the pin)
    // Only valid in Passthrough mode from the active channel
    // Use multiplexer to select the input bit based on mux_ch
    assign serial_rx_o = pad_motor_in[mux_ch];

endmodule
