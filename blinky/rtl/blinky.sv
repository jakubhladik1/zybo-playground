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

module blinky (
    input  logic clk_i,
    input  logic rst_i,
    output logic led_o
);

    logic [27:0] cnt_q, cnt_n;
    
    assign cnt_n = cnt_q + 28'd1;
    
    always_ff @(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            cnt_q <= 28'd0;
        end else begin
            cnt_q <= cnt_n;
        end
    end
    
    assign led_o = cnt_q[27];
    
endmodule
