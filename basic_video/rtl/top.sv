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
    input  wire logic       clk_ref_i,
    output      logic [2:0] tmds_data_po,
    output      logic [2:0] tmds_data_no,
    output      logic       tmds_clk_po,
    output      logic       tmds_clk_no,
    output      logic       led_o
);

    logic clk_fb;
    logic clk_100_raw; 
    logic clk_100_locked;
    logic clk_100; 
    (* ASYNC_REG = "TRUE" *) logic rst_100_meta, rst_100_sync;

    logic [2:0] tmds_data;
    logic clk_pix;
    logic rst_pix;

    logic        vgen_de;
    logic [11:0] vgen_pix;

    logic clk_pix_ddr;

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

    dvi_tx_simple inst_dvi_tx_simple (
        .clk_ref_i   (clk_100),
        .rst_i       (rst_100_sync),
        .de_i        (vgen_de),
        .pix_i       (vgen_pix),
        .clk_pxl_o   (clk_pix),
        .rst_pxl_o   (rst_pix),
        .tmds_data_o (tmds_data)
    );

    video_generator #(
        .NUM_COL_TOTAL  (11'd1056),
        .NUM_COL_ACTIVE (11'd800),
        .NUM_ROW_TOTAL  (11'd628),
        .NUM_ROW_ACTIVE (11'd600)
    ) inst_video_generator (
        .clk_i (clk_pix),
        .rst_i (rst_pix),
        .de_o  (vgen_de),
        .pix_o (vgen_pix)
);

    OBUFDS #(
        .IOSTANDARD ("TMDS_33"),
        .SLEW       ("SLOW")
    ) inst_obufds_tmds_data_0 (
        .O  (tmds_data_po[0]),
        .OB (tmds_data_no[0]),
        .I  (tmds_data[0])
    );

    OBUFDS #(
        .IOSTANDARD ("TMDS_33"),
        .SLEW       ("SLOW")
    ) inst_obufds_tmds_data_1 (
        .O  (tmds_data_po[1]),
        .OB (tmds_data_no[1]),
        .I  (tmds_data[1])
    );

    OBUFDS #(
        .IOSTANDARD ("TMDS_33"),
        .SLEW       ("SLOW")
    ) inst_obufds_tmds_data_2 (
        .O  (tmds_data_po[2]),
        .OB (tmds_data_no[2]),
        .I  (tmds_data[2])
    );

    ODDR #(
        .DDR_CLK_EDGE ("OPPOSITE_EDGE"), 
        .INIT         (1'b0),
        .SRTYPE       ("ASYNC")
    ) inst_oddr_tmds_clk (
        .Q  (clk_pix_ddr),
        .C  (clk_pix),
        .CE (1'b1),
        .D1 (1'b1),
        .D2 (1'b0),
        .R  (1'b0),
        .S  (1'b0)
    );

    OBUFDS #(
        .IOSTANDARD ("TMDS_33"),
        .SLEW       ("SLOW")
    ) inst_obufds_tmds_clk (
        .O  (tmds_clk_po),
        .OB (tmds_clk_no),
        .I  (clk_pix_ddr)
    );

    // PS7 Block is required in Zynq PL builds
    ps7_null inst_ps7_null (
    );

endmodule
