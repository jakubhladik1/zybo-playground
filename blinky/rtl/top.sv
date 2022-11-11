//
//    Copyright (C) 2022  Jakub Hladik
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

`default_nettype none

module top (
    input  logic clk_ref_i,
    output logic led_o
);

    logic clk_fb;
    logic clk_100_raw; 
    logic clk_100_locked;
    logic clk_100; 
    logic rst_100_meta;
    logic rst_100;

    // Create clk_100 (100.0 MHz) from clk_ref (125 MHz)
    PLLE2_BASE #(
        .BANDWIDTH("OPTIMIZED"),     // OPTIMIZED, HIGH, LOW
        .CLKFBOUT_MULT      (8),     // Multiply value for all CLKOUT, (2-64)
        .CLKFBOUT_PHASE     (0.0),   // Phase offset in degrees of CLKFB, (-360.000-360.000).
        .CLKIN1_PERIOD      (8.000), // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
        .CLKOUT0_DIVIDE     (10),
        .CLKOUT1_DIVIDE     (1),
        .CLKOUT2_DIVIDE     (1),
        .CLKOUT3_DIVIDE     (1),
        .CLKOUT4_DIVIDE     (1),
        .CLKOUT5_DIVIDE     (1),
        // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
        .CLKOUT0_DUTY_CYCLE (0.5),
        .CLKOUT1_DUTY_CYCLE (0.5),
        .CLKOUT2_DUTY_CYCLE (0.5),
        .CLKOUT3_DUTY_CYCLE (0.5),
        .CLKOUT4_DUTY_CYCLE (0.5),
        .CLKOUT5_DUTY_CYCLE (0.5),
        // CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
        .CLKOUT0_PHASE(0.0),
        .CLKOUT1_PHASE(0.0),
        .CLKOUT2_PHASE(0.0),
        .CLKOUT3_PHASE(0.0),
        .CLKOUT4_PHASE(0.0),
        .CLKOUT5_PHASE(0.0),
        .DIVCLK_DIVIDE(1),        // Master division value, (1-56)
        .REF_JITTER1(0.0),        // Reference input jitter in UI, (0.000-0.999).
        .STARTUP_WAIT("FALSE")    // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
    )
    inst_plle2_base (
        // Clock Outputs: 1-bit (each) output: User configurable clock outputs
        .CLKOUT0  (clk_100_raw),    // 1-bit output: CLKOUT0
        .CLKOUT1  ( ),              // 1-bit output: CLKOUT1
        .CLKOUT2  ( ),              // 1-bit output: CLKOUT2
        .CLKOUT3  ( ),              // 1-bit output: CLKOUT3
        .CLKOUT4  ( ),              // 1-bit output: CLKOUT4
        .CLKOUT5  ( ),              // 1-bit output: CLKOUT5
        // Feedback Clocks: 1-bit (each) output: Clock feedback ports
        .CLKFBOUT (clk_fb),         // 1-bit output: Feedback clock
        .LOCKED   (clk_100_locked), // 1-bit output: LOCK
        .CLKIN1   (clk_ref_i),      // 1-bit input: Input clock
        // Control Ports: 1-bit (each) input: PLL control ports
        .PWRDWN   (1'b0),           // 1-bit input: Power-down
        .RST      (1'b0),           // 1-bit input: Reset
        // Feedback Clocks: 1-bit (each) input: Clock feedback ports
        .CLKFBIN  (clk_fb)          // 1-bit input: Feedback clock
    );

    // Buffer the generated clk_100
    BUFG inst_bufg_clk_100 (
        .I (clk_100_raw),
        .O (clk_100)
    );

    // Create an asynchronous reset release synchronously with clk_100 from the PLL locked signal
    always_ff @(posedge clk_100, negedge clk_100_locked) begin
        if (!clk_100_locked) begin
            rst_100_meta <= 1'b1;
            rst_100      <= 1'b1;
        end else begin
            rst_100_meta <= ~clk_100_locked;
            rst_100      <= rst_100_meta;
        end
    end
    
    blinky inst_blinky (
        .clk_i (clk_100),
        .rst_i (rst_100),
        .led_o (led_o)
    );

endmodule
