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

module dvi_tx_simple (
    input  wire logic        clk_ref_i,
    input  wire logic        rst_i,
    input  wire logic        de_i,
    input  wire logic [11:0] pix_i,
    output      logic        clk_pxl_o,
    output      logic        rst_pxl_o,
    output      logic [2:0]  tmds_data_o
);

    // TMDS data symbols with neutral disparity
    localparam [9:0] TMDS_DAT_10 = 10'b0111110000;
    localparam [9:0] TMDS_DAT_22 = 10'b0100011110;
    localparam [9:0] TMDS_DAT_2C = 10'b0111100100;
    localparam [9:0] TMDS_DAT_36 = 10'b1001000111;
    localparam [9:0] TMDS_DAT_44 = 10'b0100111100;
    localparam [9:0] TMDS_DAT_54 = 10'b0111001100;
    localparam [9:0] TMDS_DAT_68 = 10'b0111011000;
    localparam [9:0] TMDS_DAT_76 = 10'b1010000111;
    localparam [9:0] TMDS_DAT_88 = 10'b0101111000;
    localparam [9:0] TMDS_DAT_92 = 10'b0110001110;
    localparam [9:0] TMDS_DAT_A4 = 10'b0110011100;
    localparam [9:0] TMDS_DAT_B4 = 10'b1000111001;
    localparam [9:0] TMDS_DAT_C6 = 10'b1000010111;
    localparam [9:0] TMDS_DAT_D2 = 10'b1000011011;
    localparam [9:0] TMDS_DAT_DC = 10'b1011100001;
    localparam [9:0] TMDS_DAT_EE = 10'b1000001111;
    // TMDS control symbol (neutral disparity by definition)
    localparam [9:0] TMDS_CTL_00 = 10'b1101010100;

    logic clk_raw, clk_div_raw;
    logic clk, clk_div;
    
    logic pll_fb_raw, pll_fb;
    logic pll_locked;
    (* ASYNC_REG = "TRUE" *) logic rst_meta, rst_sync;

    logic [9:0] sym_blu_d, sym_blu_q;
    logic [9:0] sym_grn_d, sym_grn_q;
    logic [9:0] sym_red_d, sym_red_q;

    // Create clk (200.0 MHz) and clk_div (40.0 MHz)
    //
    // From Xilinx UG953 (2022-10-19):
    //
    //     F_OUT = (F_CLKIN*M)/(D*O)
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
        .CLKFBOUT_MULT      (10),
        // Phase offset in degrees of CLKFB (-360.000-360.000)
        .CLKFBOUT_PHASE     (0.0),
        // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz)
        .CLKIN1_PERIOD      (10.000),
        // Divide amount for each CLKOUT (1-128)
        .CLKOUT0_DIVIDE     (5),
        .CLKOUT1_DIVIDE     (25),
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
        .CLKOUT0  (clk_raw),
        .CLKOUT1  (clk_div_raw),
        /* verilator lint_off PINCONNECTEMPTY */
        .CLKOUT2  ( ),
        .CLKOUT3  ( ),
        .CLKOUT4  ( ),
        .CLKOUT5  ( ),
        /* verilator lint_on PINCONNECTEMPTY */
        // Feedback clock output
        .CLKFBOUT (pll_fb_raw),
        // PLL locked output
        .LOCKED   (pll_locked),
        // Input clock
        .CLKIN1   (clk_ref_i),
        // Control ports
        .PWRDWN   (1'b0),
        .RST      (rst_i),
        // Feedback clock input
        .CLKFBIN  (pll_fb)
    );

    BUFG inst_bufg_pll_fb (
        .I (pll_fb_raw),
        .O (pll_fb)
    );

    BUFG inst_bufg_clk (
        .I (clk_raw),
        .O (clk)
    );

    BUFG inst_bufg_clk_div (
        .I (clk_div_raw),
        .O (clk_div)
    );

    // Create an asynchronous reset release synchronously with clk_100 from the PLL locked signal
    always_ff @(posedge clk, negedge pll_locked) begin
        if (!pll_locked) begin
            rst_meta <= 1'b1;
            rst_sync <= 1'b1;
        end else begin
            rst_meta <= ~pll_locked;
            rst_sync <= rst_meta;
        end
    end

    // Choose symbol to serialize
    always_comb begin
        if (!de_i) begin
            // Output blanking
            sym_blu_d = TMDS_CTL_00;
            sym_grn_d = TMDS_CTL_00;
            sym_red_d = TMDS_CTL_00;
        end else begin
            // Encode blue channel
            case (pix_i[3:0])
                4'd00:   sym_blu_d = TMDS_DAT_10;
                4'd01:   sym_blu_d = TMDS_DAT_22;
                4'd02:   sym_blu_d = TMDS_DAT_2C;
                4'd03:   sym_blu_d = TMDS_DAT_36;
                4'd04:   sym_blu_d = TMDS_DAT_44;
                4'd05:   sym_blu_d = TMDS_DAT_54;
                4'd06:   sym_blu_d = TMDS_DAT_68;
                4'd07:   sym_blu_d = TMDS_DAT_76;
                4'd08:   sym_blu_d = TMDS_DAT_88;
                4'd09:   sym_blu_d = TMDS_DAT_92;
                4'd10:   sym_blu_d = TMDS_DAT_A4;
                4'd11:   sym_blu_d = TMDS_DAT_B4;
                4'd12:   sym_blu_d = TMDS_DAT_C6;
                4'd13:   sym_blu_d = TMDS_DAT_D2;
                4'd14:   sym_blu_d = TMDS_DAT_DC;
                default: sym_blu_d = TMDS_DAT_EE;
            endcase;
            // Encode green channel
            case (pix_i[7:4])
                4'd00:   sym_grn_d = TMDS_DAT_10;
                4'd01:   sym_grn_d = TMDS_DAT_22;
                4'd02:   sym_grn_d = TMDS_DAT_2C;
                4'd03:   sym_grn_d = TMDS_DAT_36;
                4'd04:   sym_grn_d = TMDS_DAT_44;
                4'd05:   sym_grn_d = TMDS_DAT_54;
                4'd06:   sym_grn_d = TMDS_DAT_68;
                4'd07:   sym_grn_d = TMDS_DAT_76;
                4'd08:   sym_grn_d = TMDS_DAT_88;
                4'd09:   sym_grn_d = TMDS_DAT_92;
                4'd10:   sym_grn_d = TMDS_DAT_A4;
                4'd11:   sym_grn_d = TMDS_DAT_B4;
                4'd12:   sym_grn_d = TMDS_DAT_C6;
                4'd13:   sym_grn_d = TMDS_DAT_D2;
                4'd14:   sym_grn_d = TMDS_DAT_DC;
                default: sym_grn_d = TMDS_DAT_EE;
            endcase;
            // Encode red channel
            case (pix_i[11:8])
                4'd00:   sym_red_d = TMDS_DAT_10;
                4'd01:   sym_red_d = TMDS_DAT_22;
                4'd02:   sym_red_d = TMDS_DAT_2C;
                4'd03:   sym_red_d = TMDS_DAT_36;
                4'd04:   sym_red_d = TMDS_DAT_44;
                4'd05:   sym_red_d = TMDS_DAT_54;
                4'd06:   sym_red_d = TMDS_DAT_68;
                4'd07:   sym_red_d = TMDS_DAT_76;
                4'd08:   sym_red_d = TMDS_DAT_88;
                4'd09:   sym_red_d = TMDS_DAT_92;
                4'd10:   sym_red_d = TMDS_DAT_A4;
                4'd11:   sym_red_d = TMDS_DAT_B4;
                4'd12:   sym_red_d = TMDS_DAT_C6;
                4'd13:   sym_red_d = TMDS_DAT_D2;
                4'd14:   sym_red_d = TMDS_DAT_DC;
                default: sym_red_d = TMDS_DAT_EE;
            endcase;
        end
    end

    // Create flip-flops
    always_ff @(posedge clk, posedge rst_sync) begin
        if (rst_sync) begin
            sym_blu_q <= '0;
            sym_grn_q <= '0;
            sym_red_q <= '0;
        end else begin
            sym_blu_q <= sym_blu_d;
            sym_grn_q <= sym_grn_d;
            sym_red_q <= sym_red_d;
        end
    end

    serializer tmds_serializer_ch0 (
        .clk_i     (clk), 
        .clk_div_i (clk_div),
        .rst_i     (rst_sync),
        .data_i    (sym_blu_q),
        .ser_o     (tmds_data_o[0])
    );

    serializer tmds_serializer_ch1 (
        .clk_i     (clk), 
        .clk_div_i (clk_div),
        .rst_i     (rst_sync),
        .data_i    (sym_grn_q),
        .ser_o     (tmds_data_o[1])
    );

    serializer tmds_serializer_ch2 (
        .clk_i     (clk), 
        .clk_div_i (clk_div),
        .rst_i     (rst_sync),
        .data_i    (sym_red_q),
        .ser_o     (tmds_data_o[2])
    );

    assign clk_pxl_o = clk_div;
    assign rst_pxl_o = rst_sync;

endmodule
