//
//    Copyright (C) 2022  Jakub Hladik
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY, without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

`default_nettype none

module OSERDESE2 #(
    /* verilator lint_off UNUSED */
    parameter         DATA_RATE_OQ   = "DDR",
    parameter         DATA_RATE_TQ   = "DDR",
    parameter integer DATA_WIDTH     = 4,
    parameter [0:0]   INIT_OQ        = 1'b0,
    parameter [0:0]   INIT_TQ        = 1'b0,
    parameter         SERDES_MODE    = "MASTER",
    parameter [0:0]   SRVAL_OQ       = 1'b0,
    parameter [0:0]   SRVAL_TQ       = 1'b0,
    parameter         TBYTE_CTL      = "FALSE",
    parameter         TBYTE_SRC      = "FALSE",
    parameter integer TRISTATE_WIDTH = 4
    /* verilator lint_on UNUSED */
) (
    /* verilator lint_off UNUSED */
    /* verilator lint_off UNDRIVEN */
    output      logic OFB,
    output      logic OQ,
    output      logic SHIFTOUT1,
    output      logic SHIFTOUT2,
    output      logic TBYTEOUT,
    output      logic TFB,
    output      logic TQ,
    /* verilator lint_on UNDRIVEN */
    input  wire logic CLK,
    input  wire logic CLKDIV,
    input  wire logic D1,
    input  wire logic D2,
    input  wire logic D3,
    input  wire logic D4,
    input  wire logic D5,
    input  wire logic D6,
    input  wire logic D7,
    input  wire logic D8,
    input  wire logic OCE,
    input  wire logic RST,
    input  wire logic SHIFTIN1,
    input  wire logic SHIFTIN2,
    input  wire logic T1,
    input  wire logic T2,
    input  wire logic T3,
    input  wire logic T4,
    input  wire logic TBYTEIN,
    input  wire logic TCE
    /* verilator lint_on UNUSED */
);

    // Null module

endmodule
