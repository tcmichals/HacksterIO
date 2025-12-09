/**
 * PLL-based LED Blinker for Tang9K
 * 
 * Uses Gowin PLL to generate lower frequency clock
 * for LED blinking at human-visible rates
 */

module led_blinker (
    input  logic i_sys_clk,      // 27 MHz system clock
    input  logic i_rst_n,
    output logic o_led0,         // Slow blink (~1 Hz)
    output logic o_led1,         // Medium blink (~2 Hz)
    output logic o_led2,         // Fast blink (~4 Hz)
    output logic o_led3          // Breathing pattern
);

    // =============================
    // Clock Dividers (no PLL needed for basic demo)
    // Using direct clock division for simplicity
    // =============================
    
    logic [25:0] counter_slow;   // For ~1 Hz (27MHz / 2^26 = ~0.4 Hz)
    logic [24:0] counter_med;    // For ~2 Hz
    logic [23:0] counter_fast;   // For ~4 Hz
    logic [22:0] counter_breath; // For breathing effect
    
    logic clk_slow, clk_med, clk_fast, clk_breath;
    
    // =============================
    // Slow Clock - ~0.5 Hz (1 second period)
    // =============================
    always_ff @(posedge i_sys_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            counter_slow <= '0;
        else
            counter_slow <= counter_slow + 1'b1;
    end
    
    assign clk_slow = counter_slow[25];  // Divide by 2^26
    
    // =============================
    // Medium Clock - ~1 Hz (0.5 second period)
    // =============================
    always_ff @(posedge i_sys_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            counter_med <= '0;
        else
            counter_med <= counter_med + 1'b1;
    end
    
    assign clk_med = counter_med[24];   // Divide by 2^25
    
    // =============================
    // Fast Clock - ~2 Hz (0.25 second period)
    // =============================
    always_ff @(posedge i_sys_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            counter_fast <= '0;
        else
            counter_fast <= counter_fast + 1'b1;
    end
    
    assign clk_fast = counter_fast[23];  // Divide by 2^24
    
    // =============================
    // Breathing Clock - PWM for LED3
    // =============================
    always_ff @(posedge i_sys_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            counter_breath <= '0;
        else
            counter_breath <= counter_breath + 1'b1;
    end
    
    // Create breathing effect with PWM
    logic [6:0] pwm_counter;
    logic [6:0] pwm_pattern;
    
    always_ff @(posedge i_sys_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            pwm_counter <= '0;
            pwm_pattern <= 7'd0;
        end else begin
            pwm_counter <= pwm_counter + 1'b1;
            
            // Update pattern every ~262k cycles (~10ms at 27MHz)
            if (counter_breath == '0) begin
                // Triangular wave pattern for breathing
                if (pwm_pattern < 64)
                    pwm_pattern <= pwm_pattern + 1'b1;
                else
                    pwm_pattern <= pwm_pattern - 1'b1;
            end
        end
    end
    
    // PWM output
    logic pwm_out;
    assign pwm_out = pwm_counter < pwm_pattern;
    
    // =============================
    // LED Output Assignments
    // =============================
    
    // LED0: Slow blink
    always_ff @(posedge i_sys_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            o_led0 <= 1'b0;
        else
            o_led0 <= clk_slow;
    end
    
    // LED1: Medium blink
    always_ff @(posedge i_sys_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            o_led1 <= 1'b0;
        else
            o_led1 <= clk_med;
    end
    
    // LED2: Fast blink
    always_ff @(posedge i_sys_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            o_led2 <= 1'b0;
        else
            o_led2 <= clk_fast;
    end
    
    // LED3: Breathing effect
    always_ff @(posedge i_sys_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            o_led3 <= 1'b0;
        else
            o_led3 <= pwm_out;
    end

endmodule
