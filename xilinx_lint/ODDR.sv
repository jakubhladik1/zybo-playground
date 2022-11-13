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

module ODDR #(
    /* verilator lint_off UNUSED */
    parameter       DDR_CLK_EDGE = "OPPOSITE_EDGE",
    parameter [0:0] INIT         = 1'b0,
    parameter       SRTYPE       = "SYNC"
    /* verilator lint_on UNUSED */
) (
    /* verilator lint_off UNUSED */
    /* verilator lint_off UNDRIVEN */
    output      logic Q,
    /* verilator lint_on UNDRIVEN */
    input  wire logic C,
    input  wire logic CE,
    input  wire logic D1,
    input  wire logic D2,    
    input  wire logic R,
    input  wire logic S
    /* verilator lint_on UNUSED */
);

    // Null module

endmodule
