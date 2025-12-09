/**
 * LED Blinker Testbench
 * 
 * Verifies LED blinking patterns at various frequencies
 */

`timescale 1ns/1ps

module led_blinker_tb;

    parameter SYS_CLK_PERIOD = 37;  // ~27 MHz
    
    logic sys_clk;
    logic rst_n;
    logic led0, led1, led2, led3;
    
    // =============================
    // DUT Instantiation
    // =============================
    led_blinker u_led_blinker (
        .i_sys_clk  (sys_clk),
        .i_rst_n    (rst_n),
        .o_led0     (led0),
        .o_led1     (led1),
        .o_led2     (led2),
        .o_led3     (led3)
    );
    
    // =============================
    // Clock Generation
    // =============================
    initial begin
        sys_clk = 1'b0;
        forever #(SYS_CLK_PERIOD/2) sys_clk = ~sys_clk;
    end
    
    // =============================
    // Test Stimulus
    // =============================
    initial begin
        $dumpfile("led_blinker_tb.vcd");
        $dumpvars(0, led_blinker_tb);
        
        // Initialize
        rst_n = 1'b0;
        repeat(10) @(posedge sys_clk);
        rst_n = 1'b1;
        
        $display("LED Blinker Test Started");
        $display("==============================");
        $display("LED0: ~0.5 Hz (slow blink)");
        $display("LED1: ~1 Hz (medium blink)");
        $display("LED2: ~2 Hz (fast blink)");
        $display("LED3: Breathing pattern (PWM)");
        $display("==============================");
        
        // Run for a long time to see blinking patterns
        // ~2 seconds of simulation
        repeat(54_000_000) @(posedge sys_clk);
        
        $display("Test completed!");
        $finish;
    end
    
    // =============================
    // Monitors
    // =============================
    
    // Count LED toggles
    logic [31:0] led0_toggles, led1_toggles, led2_toggles;
    
    always @(posedge led0) led0_toggles <= led0_toggles + 1'b1;
    always @(posedge led1) led1_toggles <= led1_toggles + 1'b1;
    always @(posedge led2) led2_toggles <= led2_toggles + 1'b1;
    
    // Periodic status output
    logic [31:0] cycle_count;
    
    always_ff @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n)
            cycle_count <= '0;
        else
            cycle_count <= cycle_count + 1'b1;
    end
    
    always @(posedge sys_clk) begin
        // Print status every 27M cycles (~1 second)
        if (cycle_count == 27_000_000) begin
            $display("Time: %t | LED0 toggles: %d | LED1 toggles: %d | LED2 toggles: %d | LED3: %b",
                     $time, led0_toggles, led1_toggles, led2_toggles, led3);
            cycle_count <= '0;
        end
    end

endmodule
