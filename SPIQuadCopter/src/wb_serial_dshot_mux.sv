/**
 * Wishbone Serial/DSHOT Mux Register (Portable Version)
 * * Simple Wishbone register to select which device (TTL Serial or DSHOT) drives the shared output line.
 * Address: 0x0400 (word-aligned)
 * * Safety features:
 * - One-cycle tristate (global_tristate) on all mode/channel changes.
 * - Unused motor pins actively driven LOW (0) in Passthrough mode to prevent noise (ESC safety).
 * - Serial RX is gated to Logic HIGH (1) in DSHOT mode (UART idle state).
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
    output logic       serial_rx_o    // To Serial Bridge
    
`ifdef SIM_CONTROL
    // Testbench Override Ports (Only visible during simulation)
    , input  wire        tb_mux_force_en
    , input  wire        tb_mux_force_sel
    , input  wire [1:0]  tb_mux_force_ch
`endif
);

    // Only respond to address 0x0400
    // NOTE: For full safety against aliasing, check higher address bits too if not handled by interconnect.
    wire sel = wb_cyc_i & wb_stb_i & (wb_adr_i[11:2] == 10'h100);

    always_ff @(posedge wb_clk_i) begin
        if (wb_rst_i) begin
            mux_sel <= 1'b0;
            mux_ch  <= 2'b0;
            wb_ack_o <= 1'b0;
            wb_dat_o <= 32'b0;
        end else begin
            // Standard registered ACK logic
            wb_ack_o <= sel & ~wb_ack_o;
            
            if (sel && ~wb_ack_o) begin
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
    // Mux Selection and Safety Logic
    // ==========================================

    // Compute effective selection (allowing test override)
    logic effective_mux_sel;
    logic [1:0] effective_mux_ch;

`ifdef SIM_CONTROL
    assign effective_mux_sel = (tb_mux_force_en ? tb_mux_force_sel : mux_sel);
    assign effective_mux_ch  = (tb_mux_force_en ? tb_mux_force_ch  : mux_ch);
`else
    assign effective_mux_sel = mux_sel;
    assign effective_mux_ch  = mux_ch;
`endif

    // One-cycle global tri-state on mode/channel change to avoid contention
    logic prev_mux_sel;
    logic [1:0] prev_mux_ch;
    logic global_tristate; 

    always_ff @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            prev_mux_sel    <= 1'b0;
            prev_mux_ch     <= 2'b0;
            global_tristate <= 1'b0;
        end else begin
            // Detect change in mode or channel selection
            if ((effective_mux_sel != prev_mux_sel) || (effective_mux_ch != prev_mux_ch)) begin
                global_tristate <= 1'b1;  // assert for one cycle
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
            logic pad_oe_active_high; // 1=Drive, 0=High-Z

            always_comb begin
                if (effective_mux_sel == 1'b1) begin
                    // DSHOT Mode: Active Drive
                    pad_out_data       = dshot_val;
                    pad_oe_active_high = 1'b1; 
                end else begin
                    // Passthrough Mode
                    if (is_target) begin
                        pad_out_data       = serial_tx_i;
                        pad_oe_active_high = serial_oe_i; // Tri-state control from bridge
                    end else begin
                        // SAFETY FIX: Drive 0 (Low) to unused ESCs instead of High-Z
                        pad_out_data       = 1'b0;
                        pad_oe_active_high = 1'b1; // ACTIVATE drive to Low
                    end
                end
            end
            
            // Wire to carry signal from Pad -> Fabric (Input path)
            wire pad_input_val;
            
            // Apply global tri-state during mode/channel change
            // The final OE is asserted (1=drive) only if global_tristate is 0 AND the mux logic wants to drive.
            wire final_drive_enable = ~global_tristate & pad_oe_active_high;


            // --- Conditional Compilation for IOBUF (Portable Logic) ---
            
`ifdef GOWIN_FPGA
            // Target: Gowin (Tang Nano 9K)
            // Gowin IOBUF OEN is Active Low (0=Drive, 1=Z).
            wire gowin_oen = ~final_drive_enable;

            // Gowin Primitive Instantiation
            IOBUF io_inst (
                .O(pad_input_val),  // Output to Fabric (Input from Pad)
                .I(pad_out_data),   // Input from Fabric (Output to Pad)
                .OEN(gowin_oen),    // Output Enable (Active Low)
                .IO(pad_motor[i])   // The Physical Pad
            );

`elsif XILINX_FPGA
            // Target: Xilinx (Example)
            // Xilinx IOBUF T is Active High (1=Tri-state, 0=Drive).
            wire xilinx_T = ~final_drive_enable;

            // Xilinx Primitive Instantiation
            IOBUF io_inst (
                .I(pad_out_data),
                .O(pad_input_val),
                .T(xilinx_T),      // Active High Tri-state
                .IO(pad_motor[i])
            );
            
`else // Default for generic simulation/non-specified FPGA
            // Generic Tri-state logic (for simulation/simplicity)
            assign pad_motor[i] = final_drive_enable ? pad_out_data : 1'bz;
            assign pad_input_val = pad_motor[i];

`endif
            
        end
    endgenerate

    // Serial RX Muxing (Reading from the pin)
    
    // Hook up the array using a second generate loop (if necessary) or by direct naming
    // Since the IOBUF instantiation is local, we must connect the pad_input_val wires here.
    logic [3:0] rx_tap_array;

    generate
        for (i = 0; i < 4; i++) begin : tap_connection
             assign rx_tap_array[i] = gen_pads[i].pad_input_val;
        end
    endgenerate

    // Synchronize selected pad to local clock domain (2-FF synchronizer)
    logic serial_rx_meta;
    logic serial_rx_sync;

    always_ff @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            serial_rx_meta <= 1'b1; // SAFETY FIX: Reset to UART Idle (1)
            serial_rx_sync <= 1'b1; // SAFETY FIX: Reset to UART Idle (1)
        end else begin
            serial_rx_meta <= rx_tap_array[effective_mux_ch];
            serial_rx_sync <= serial_rx_meta;
        end
    end

    // SAFETY FIX: Present RX only in passthrough mode; otherwise drive 1 (UART Idle)
    assign serial_rx_o = (effective_mux_sel == 1'b0) ? serial_rx_sync : 1'b1;

endmodule