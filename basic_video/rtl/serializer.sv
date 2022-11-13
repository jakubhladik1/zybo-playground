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

module serializer (
    input  wire logic       clk_i,
    input  wire logic       clk_div_i,
    input  wire logic       rst_i,
    input  wire logic [9:0] data_i,
    output      logic       ser_o
);

    //
    // https://docs.xilinx.com/r/en-US/ug953-vivado-7series-libraries/OSERDESE2
    // https://docs.xilinx.com/v/u/en-US/ug471_7Series_SelectIO
    //

    logic shiftout1, shiftout2;

    OSERDESE2 #(
        // DDR, SDR
        .DATA_RATE_OQ   ("DDR"),
        // DDR, BUF, SDR
        .DATA_RATE_TQ   ("SDR"),
        // Parallel data width (2-8,10,14)
        .DATA_WIDTH     (10),
        // Initial value of OQ output (1'b0,1'b1)
        .INIT_OQ        (1'b0),
        // Initial value of TQ output (1'b0,1'b1)
        .INIT_TQ        (1'b0),
        // MASTER, SLAVE
        .SERDES_MODE    ("MASTER"),
        // OQ output value when SR is used (1'b0,1'b1)
        .SRVAL_OQ       (1'b0),
        // TQ output value when SR is used (1'b0,1'b1)
        .SRVAL_TQ       (1'b0),
        // Enable tristate byte operation (FALSE, TRUE)
        .TBYTE_CTL      ("FALSE"),
        // Tristate byte source (FALSE, TRUE)
        .TBYTE_SRC      ("FALSE"),
        // 3-state converter width (1,4)
        .TRISTATE_WIDTH (1)
    )
    inst_oserdese2_master (
        // Feedback path for data
        /* verilator lint_off PINCONNECTEMPTY */
        .OFB       ( ),
        /* verilator lint_on PINCONNECTEMPTY */
        // Data path output
        .OQ        (ser_o),
        // Data output expansion
        /* verilator lint_off PINCONNECTEMPTY */
        .SHIFTOUT1 ( ),
        .SHIFTOUT2 ( ),
        /* verilator lint_on PINCONNECTEMPTY */
        // Byte group tristate
        /* verilator lint_off PINCONNECTEMPTY */
        .TBYTEOUT  ( ),
        // Tri-state control
        .TFB       ( ),
        .TQ        ( ),
        /* verilator lint_on PINCONNECTEMPTY */
        // High speed clock
        .CLK       (clk_i),
        // Divided clock
        .CLKDIV    (clk_div_i),
        // Parallel data inputs
        .D1        (data_i[0]),
        .D2        (data_i[1]),
        .D3        (data_i[2]),
        .D4        (data_i[3]),
        .D5        (data_i[4]),
        .D6        (data_i[5]),
        .D7        (data_i[6]),
        .D8        (data_i[7]),
        // Output data clock enable
        .OCE       (1'b1),
        // Reset
        .RST       (rst_i),
        // Data input expansion
        .SHIFTIN1  (shiftout1),
        .SHIFTIN2  (shiftout2),
        // Parallel tri-state inputs
        .T1        (1'b0),
        .T2        (1'b0),
        .T3        (1'b0),
        .T4        (1'b0),
        // Byte group tri-state
        .TBYTEIN   (1'b0),
        // Tri-state clock enable
        .TCE       (1'b0)
    );

    OSERDESE2 #(
        // DDR, SDR
        .DATA_RATE_OQ   ("DDR"),
        // DDR, BUF, SDR
        .DATA_RATE_TQ   ("SDR"),
        // Parallel data width (2-8,10,14)
        .DATA_WIDTH     (10),
        // Initial value of OQ output (1'b0,1'b1)
        .INIT_OQ        (1'b0),
        // Initial value of TQ output (1'b0,1'b1)
        .INIT_TQ        (1'b0),
        // MASTER, SLAVE
        .SERDES_MODE    ("SLAVE"),
        // OQ output value when SR is used (1'b0,1'b1)
        .SRVAL_OQ       (1'b0),
        // TQ output value when SR is used (1'b0,1'b1)
        .SRVAL_TQ       (1'b0),
        // Enable tristate byte operation (FALSE, TRUE)
        .TBYTE_CTL      ("FALSE"),
        // Tristate byte source (FALSE, TRUE)
        .TBYTE_SRC      ("FALSE"),
        // 3-state converter width (1,4)
        .TRISTATE_WIDTH (1)
    )
    inst_oserdese2_slave (
        // Feedback path for data
        /* verilator lint_off PINCONNECTEMPTY */
        .OFB       ( ),
        // Data path output
        .OQ        ( ),
        /* verilator lint_on PINCONNECTEMPTY */
        // Data output expansion
        .SHIFTOUT1 (shiftout1),
        .SHIFTOUT2 (shiftout2),
        // Byte group tristate
        /* verilator lint_off PINCONNECTEMPTY */
        .TBYTEOUT  ( ),
        // Tri-state control
        .TFB       ( ),
        .TQ        ( ),
        /* verilator lint_on PINCONNECTEMPTY */
        // High speed clock
        .CLK       (clk_i),
        // Divided clock
        .CLKDIV    (clk_div_i),
        // Parallel data inputs
        .D1        (1'b0),
        .D2        (1'b0),
        .D3        (data_i[8]),
        .D4        (data_i[9]),
        .D5        (1'b0),
        .D6        (1'b0),
        .D7        (1'b0),
        .D8        (1'b0),
        // Output data clock enable
        .OCE       (1'b1),
        // Reset
        .RST       (rst_i),
        // Data input expansion
        .SHIFTIN1  (1'b0),
        .SHIFTIN2  (1'b0),
        // Parallel tri-state inputs
        .T1        (1'b0),
        .T2        (1'b0),
        .T3        (1'b0),
        .T4        (1'b0),
        // Byte group tri-state
        .TBYTEIN   (1'b0),
        // Tri-state clock enable
        .TCE       (1'b0)
    );

endmodule
