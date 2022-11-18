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

module video_generator #(
    parameter [10:0] NUM_COL_TOTAL  = 11'd90,
    parameter [10:0] NUM_COL_ACTIVE = 11'd80,
    parameter [10:0] NUM_ROW_TOTAL  = 11'd70,
    parameter [10:0] NUM_ROW_ACTIVE = 11'd60
) (
    input  wire logic        clk_i,
    input  wire logic        rst_i,
    output      logic        de_o,
    output      logic [11:0] pix_o
);

    logic [10:0] row_d, row_q;
    logic [10:0] col_d, col_q;

    logic row_last;
    logic col_last;

    logic de_q, de_d;

    logic row_active;
    logic col_active;

    logic [11:0] pix_q, pix_d;

    // Create comparators for last row and last column
    assign row_last = row_q == (NUM_ROW_TOTAL-1);
    assign col_last = col_q == (NUM_COL_TOTAL-1);

    // Creat row counter
    assign row_d = row_last && col_last ? 11'd0         : // Last pixel of a frame
                   col_last             ? row_q + 11'd1 : // Last pixel of a line
                   row_q                                ; // Not last pixel of a line

    // Create column counter
    assign col_d = col_last ? 11'd0         : // Last pixel of a line
                              col_q + 11'd1 ; // Not last pixel of a line

    always_ff @(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            row_q <= '0;
            col_q <= '0;
        end else begin
            row_q <= row_d;
            col_q <= col_d;
        end
    end

    assign row_active = row_q < NUM_ROW_ACTIVE;
    assign col_active = col_q < NUM_COL_ACTIVE;

    // Create data enable signal when in active area
    assign de_d = row_active && col_active;

    // // Create Shierpinsky triangle
    // assign pix_d = ((row_q & col_q) > 0) ? 12'hfff : 12'h000;

    // // Create a white inner border
    // assign pix_d = row_q == 0                  ||
    //                row_q == (NUM_ROW_ACTIVE-1) ||
    //                col_q == 0                  ||
    //                col_q == (NUM_COL_ACTIVE-1) ? 12'hfff : 12'h000;

    // Create a gradient pattern
    assign pix_d = {col_q[3:0], row_q[3:0], 4'hf};

    always_ff @(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            de_q  <= 1'b0;
            pix_q <= '0;
        end else begin
            de_q  <= de_d;
            pix_q <= pix_d;
        end
    end

    // Assign output
    assign de_o  = de_q;
    assign pix_o = pix_q;

endmodule
