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
    input  wire logic clk_ref_i,
    output      logic led_o,
    output      logic sda_o,
    output      logic scl_o,
    output      logic pwrup_o
);

    logic clk_fb;
    logic clk_100_raw; 
    logic clk_100_locked;
    logic clk_100;
    (* ASYNC_REG = "TRUE" *) logic rst_100_meta, rst_100_sync;

    logic scl, sda;

    // Create clk_100 (100.0 MHz) from clk_ref (125 MHz)
    //
    // From Xilinx UG953 (2022-10-19):
    //
    //     F_OUT = (F_CLKIN*M)/(D*O)
    //
    //     F_CLKIN = 125, M = 8, D = 1, O = 10
    //     100 = (125*8)/(4*10)
    //
    // From Xilinx DS187 (v1.21) for -1C speed grade:
    //     F_IN        : [19.0 MHz - 800.0 MHz]
    //     F_INJITTER  : < 20% of clock input period or 1 ns max
    //     F_VCO       : [800.0 MHz - 1600.0 MHz]
    //     PLL_BWLOW   : 1 MHz
    //     PLL_BWHIGH  : 4 MHz
    //     PLL_LOCKMAX : 100 us
    //     PLL_OUTMAX  : 800.0 MHz
    //     PLL_OUTMIN  : 6.25 MHz
    //     PLL_FPFDMAX : 550 MHz
    //     PLL_FPFDMIN : 19 MHz
    //
    PLLE2_BASE #(
        // PLL bandwidth (OPTIMIZED, HIGH, LOW)
        .BANDWIDTH          ("OPTIMIZED"),
        // Multiply value for all CLKOUT (2-64)
        .CLKFBOUT_MULT      (8),
        // Phase offset in degrees of CLKFB (-360.000-360.000)
        .CLKFBOUT_PHASE     (0.0),
        // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz)
        .CLKIN1_PERIOD      (8.000),
        // Divide amount for each CLKOUT (1-128)
        .CLKOUT0_DIVIDE     (10),
        .CLKOUT1_DIVIDE     (1),
        .CLKOUT2_DIVIDE     (1),
        .CLKOUT3_DIVIDE     (1),
        .CLKOUT4_DIVIDE     (1),
        .CLKOUT5_DIVIDE     (1),
        // Duty cycle for each CLKOUT (0.001-0.999)
        .CLKOUT0_DUTY_CYCLE (0.5),
        .CLKOUT1_DUTY_CYCLE (0.5),
        .CLKOUT2_DUTY_CYCLE (0.5),
        .CLKOUT3_DUTY_CYCLE (0.5),
        .CLKOUT4_DUTY_CYCLE (0.5),
        .CLKOUT5_DUTY_CYCLE (0.5),
        // Phase offset for each CLKOUT (-360.000-360.000)
        .CLKOUT0_PHASE      (0.0),
        .CLKOUT1_PHASE      (0.0),
        .CLKOUT2_PHASE      (0.0),
        .CLKOUT3_PHASE      (0.0),
        .CLKOUT4_PHASE      (0.0),
        .CLKOUT5_PHASE      (0.0),
        // Master division value (1-56)
        .DIVCLK_DIVIDE      (1),
        // Reference input jitter in UI (0.000-0.999)
        .REF_JITTER1        (0.0),
        // Delay DONE until PLL locks ("TRUE"/"FALSE")
        .STARTUP_WAIT       ("FALSE")
    )
    inst_plle2_base (
        // User configurable clock outputs
        .CLKOUT0  (clk_100_raw),
        /* verilator lint_off PINCONNECTEMPTY */
        .CLKOUT1  ( ),
        .CLKOUT2  ( ),
        .CLKOUT3  ( ),
        .CLKOUT4  ( ),
        .CLKOUT5  ( ),
        /* verilator lint_on PINCONNECTEMPTY */
        // Feedback clock output
        .CLKFBOUT (clk_fb),
        // PLL locked output
        .LOCKED   (clk_100_locked),
        // Input clock
        .CLKIN1   (clk_ref_i),
        // Control ports
        .PWRDWN   (1'b0),
        .RST      (1'b0),
        // Feedback clock input
        .CLKFBIN  (clk_fb)
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
            rst_100_sync <= 1'b1;
        end else begin
            rst_100_meta <= ~clk_100_locked;
            rst_100_sync <= rst_100_meta;
        end
    end
    
    blinky #(
        .CWIDTH (26)
    ) inst_blinky (
        .clk_i (clk_100),
        .rst_i (rst_100_sync),
        .led_o (led_o)
    );

    // PS7 Block is required in Zynq PL builds
    ps7_null inst_ps7_null (
    );


     logic [23:0] cnt_q;
     always_ff @(posedge clk_100, posedge rst_100_sync) begin
        if (rst_100_sync) begin
            cnt_q <= '0;
        end else begin
            cnt_q <= cnt_q + 1'b1;
        end
    end

    i2c_writer #(
        .CLK_FREQ_HZ (100_000_000),
        .SCL_FREQ_HZ (400_000),
        .SLAVE_ADDR (8'h78),
        .NUM_WRITES (44),
        .WRITE_TABLE ({
            {1'b0, 16'h3008, 8'h42},

            {1'b0, 16'h300E, 8'h45},

            {1'b0, 16'h3017, 8'h00},
            {1'b0, 16'h3018, 8'h00},

            {1'b0, 16'h302E, 8'h08},

            {1'b0, 16'h3034, 8'h1A},
            {1'b0, 16'h3035, 8'h21},
            {1'b0, 16'h3036, 8'h46},
            {1'b0, 16'h3037, 8'h05},

            {1'b0, 16'h303B, 8'h19},

            {1'b0, 16'h303D, 8'h10},

            {1'b0, 16'h3103, 8'h03},
            {1'b0, 16'h3108, 8'h11},

            {1'b0, 16'h3800, 8'h00},
            {1'b0, 16'h3801, 8'h00},
            {1'b0, 16'h3802, 8'h00},
            {1'b0, 16'h3803, 8'h08},

            {1'b0, 16'h3804, 8'h0A},
            {1'b0, 16'h3805, 8'h3B},
            {1'b0, 16'h3806, 8'h07},
            {1'b0, 16'h3807, 8'h9B},

            {1'b0, 16'h3808, 8'h05},
            {1'b0, 16'h3809, 8'h00},
            {1'b0, 16'h380A, 8'h02},
            {1'b0, 16'h380B, 8'hD0},

            {1'b0, 16'h380C, 8'h07},
            {1'b0, 16'h380D, 8'h68},
            {1'b0, 16'h380E, 8'h03},
            {1'b0, 16'h380F, 8'hD8},

            {1'b0, 16'h3810, 8'h00},
            {1'b0, 16'h3811, 8'h00},
            {1'b0, 16'h3812, 8'h00},
            {1'b0, 16'h3813, 8'h00},

            {1'b0, 16'h3814, 8'h31},
            {1'b0, 16'h3815, 8'h31},

            {1'b0, 16'h3821, 8'h01},
            {1'b0, 16'h3824, 8'h01},

            {1'b0, 16'h4837, 8'h24},
            {1'b0, 16'h4300, 8'h00},
            {1'b0, 16'h4800, 8'h14},
            {1'b0, 16'h5001, 8'h02},
            {1'b0, 16'h501F, 8'h03},
            {1'b0, 16'h503D, 8'h80},
            
            {1'b1, 16'h3008, 8'h02}
        })
    ) inst_i2c_writer (
        .clk_i  (clk_100),
        .rst_i  (rst_100_sync),
        .trig_i (cnt_q[23]),
        .sda_o  (sda),
        .scl_o  (scl),
        .done_o ( )
    );

    assign sda_o = sda ? 1'bz : 1'b0;
    assign scl_o = scl ? 1'bz : 1'b0;
    assign pwrup_o = 1'b1;

endmodule
