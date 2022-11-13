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

module PLLE2_BASE #(
    /* verilator lint_off UNUSED */
    parameter         BANDWIDTH          = "OPTIMIZED",
    parameter integer CLKFBOUT_MULT      = 5,
    parameter real    CLKFBOUT_PHASE     = 0.000,
    parameter real    CLKIN1_PERIOD      = 0.000,
    parameter integer CLKOUT0_DIVIDE     = 1,
    parameter real    CLKOUT0_DUTY_CYCLE = 0.500,
    parameter real    CLKOUT0_PHASE      = 0.000,
    parameter integer CLKOUT1_DIVIDE     = 1,
    parameter real    CLKOUT1_DUTY_CYCLE = 0.500,
    parameter real    CLKOUT1_PHASE      = 0.000,
    parameter integer CLKOUT2_DIVIDE     = 1,
    parameter real    CLKOUT2_DUTY_CYCLE = 0.500,
    parameter real    CLKOUT2_PHASE      = 0.000,
    parameter integer CLKOUT3_DIVIDE     = 1,
    parameter real    CLKOUT3_DUTY_CYCLE = 0.500,
    parameter real    CLKOUT3_PHASE      = 0.000,
    parameter integer CLKOUT4_DIVIDE     = 1,
    parameter real    CLKOUT4_DUTY_CYCLE = 0.500,
    parameter real    CLKOUT4_PHASE      = 0.000,
    parameter integer CLKOUT5_DIVIDE     = 1,
    parameter real    CLKOUT5_DUTY_CYCLE = 0.500,
    parameter real    CLKOUT5_PHASE      = 0.000,
    parameter integer DIVCLK_DIVIDE      = 1,
    parameter real    REF_JITTER1        = 0.010,
    parameter         STARTUP_WAIT       = "FALSE"
    /* verilator lint_on UNUSED */
)(
    /* verilator lint_off UNUSED */
    /* verilator lint_off UNDRIVEN */
    output      logic CLKFBOUT,
    output      logic CLKOUT0,
    output      logic CLKOUT1,
    output      logic CLKOUT2,
    output      logic CLKOUT3,
    output      logic CLKOUT4,
    output      logic CLKOUT5,
    output      logic LOCKED,
    /* verilator lint_on UNDRIVEN */
    input  wire logic CLKFBIN,
    input  wire logic CLKIN1,
    input  wire logic PWRDWN,
    input  wire logic RST
    /* verilator lint_on UNUSED */
);

    // Null module

endmodule
