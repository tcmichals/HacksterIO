
`default_nettype none
`timescale 1 ns / 1 ns

module tb_neopixels();

    reg clk = 1;
    reg reset = 1;
    reg [31:0] ledData = 31'h0;
    reg axis_valid =0;
    wire o_neoserial;
    wire axis_is_ready;


sendPx dut(
    .axis_aclk(clk),
    .axis_reset(reset),
    .s_axis_data(ledData),
    .s_axis_valid(axis_valid),
    .s_axis_ready(axis_is_ready),
    .o_serial(o_neoserial)
    );

always begin
    #1 begin
        clk =!clk;
    end
end

always @( posedge clk) begin 
    if (reset) begin
    end
    else begin
        if (axis_is_ready && ~axis_valid) begin
            axis_valid <= 1;
            ledData <= ledData +1'b1;        
        end
        else begin
            if (axis_is_ready)
                axis_valid <= 0;
        end
    end
end


initial begin
    $dumpfile("tb_neopixels.vcd");
    $dumpvars(0,tb_neopixels);

    #10 reset<=1;
    #1 reset<=0;

    #100000 $finish;

end    



endmodule
