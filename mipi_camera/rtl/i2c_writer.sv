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

module i2c_writer(
    input  wire logic clk_i,
    input  wire logic rst_i,
    output      logic sda_o,
    output      logic scl_o
);
    parameter CLK_FREQ_HZ = 1_000_000;
    parameter SCL_FREQ_HZ =   100_000;
    parameter [7:0] SLAVE_ADDR = 8'h78;
    parameter [24:0] WRITE_TABLE [0:4] = {
        {1'b0, 16'h3008, 8'h42},
        {1'b0, 16'h3103, 8'h03},
        {1'b0, 16'h3017, 8'h00},
        {1'b0, 16'h3018, 8'h00},
        {1'b1, 16'h3034, 8'h18}
    };
    
    localparam [ 1:0] SCL_START = 2'b11;
    localparam [15:0] SCL_BYTE  = {8{2'b01}};
    localparam [ 1:0] SCL_ACK   = 2'b01;
    localparam [ 1:0] SCL_STOP  = 2'b01;
    localparam [ 1:0] SCL_IDLE  = 2'b11;
    
    localparam [ 1:0] SDA_START = 2'b10;
    localparam [ 1:0] SDA_SACK  = 2'b11;
    localparam [ 1:0] SDA_STOP  = 2'b11;
    localparam [ 1:0] SDA_IDLE  = 2'b11;
    
    localparam [77:0] SCL_PARALLEL_LOAD = {
        SCL_START,
        SCL_BYTE,
        SCL_ACK,
        SCL_BYTE,
        SCL_ACK,
        SCL_BYTE,
        SCL_ACK,
        SCL_BYTE,
        SCL_ACK,
        SCL_STOP,
        SCL_IDLE
    };
    
    localparam [77:0] PRG_PARALLEL_LOAD = '1;
    localparam [$clog2(CLK_FREQ_HZ/SCL_FREQ_HZ*2)-1:0] DLY_CNT = $clog2(CLK_FREQ_HZ/SCL_FREQ_HZ*2)'(CLK_FREQ_HZ/SCL_FREQ_HZ*2);

    logic [$clog2(CLK_FREQ_HZ/SCL_FREQ_HZ*2)-1:0] dly_cnt_q, dly_cnt_d;
    logic [77:0] shift_sda_q, shift_sda_d;
    logic [77:0] shift_scl_q, shift_scl_d;
    logic [77:0] shift_prg_q, shift_prg_d;
    logic [77:0] sda_parallel_load;
    logic busy;
    logic last;
    logic [15:0] addr;
    logic [7:0] data;
    logic [2:0] index_q, index_d;

    assign index_d = last  ? index_q     :
                     !busy ? index_q + 1 : 
                             index_q;

    assign {last, addr, data} = WRITE_TABLE[index_q];
    
    assign sda_parallel_load = {
        SDA_START,
        {
            {2{SLAVE_ADDR[ 7]}}, {2{SLAVE_ADDR[ 6]}}, {2{SLAVE_ADDR[ 5]}}, {2{SLAVE_ADDR[ 4]}},
            {2{SLAVE_ADDR[ 3]}}, {2{SLAVE_ADDR[ 2]}}, {2{SLAVE_ADDR[ 1]}}, {2{SLAVE_ADDR[ 0]}}
        },
        SDA_SACK,
        {
            {2{addr[15]}}, {2{addr[14]}}, {2{addr[13]}}, {2{addr[12]}}, 
            {2{addr[11]}}, {2{addr[10]}}, {2{addr[ 9]}}, {2{addr[ 8]}}
        },
        SDA_SACK,
        {
            {2{addr[ 7]}}, {2{addr[ 6]}}, {2{addr[ 5]}}, {2{addr[ 4]}},
            {2{addr[ 3]}}, {2{addr[ 2]}}, {2{addr[ 1]}}, {2{addr[ 0]}}
        },
        SDA_SACK,
        {
            {2{data[ 7]}}, {2{data[ 6]}}, {2{data[ 5]}}, {2{data[ 4]}},
            {2{data[ 3]}}, {2{data[ 2]}}, {2{data[ 1]}}, {2{data[ 0]}}
        },
        SDA_SACK,
        SDA_STOP,
        SDA_IDLE
    };
    
    assign dly_cnt_d = !busy                    ? '0 :
                       dly_cnt_q == (DLY_CNT-1) ? '0 :
                                                  dly_cnt_q + 1'b1;
    
    assign shift_sda_d = !busy                    ? sda_parallel_load         : 
                         dly_cnt_q == (DLY_CNT-1) ? {shift_sda_q[76:0], 1'b1} : 
                                                    shift_sda_q;
    
    assign shift_scl_d = !busy                    ? SCL_PARALLEL_LOAD         : 
                         dly_cnt_q == (DLY_CNT-1) ? {shift_scl_q[76:0], 1'b1} : 
                                                    shift_scl_q;
    
    assign shift_prg_d = !busy                    ? PRG_PARALLEL_LOAD         : 
                         dly_cnt_q == (DLY_CNT-1) ? {shift_prg_q[76:0], 1'b0} : 
                                                    shift_prg_q;
    
    assign busy = shift_prg_q[77];
    
    always_ff @(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            dly_cnt_q   <= '0;
            shift_sda_q <= '1;
            shift_scl_q <= '1;
            shift_prg_q <= '0;
            index_q     <= '0;
        end else begin
            dly_cnt_q   <= dly_cnt_d;
            shift_sda_q <= shift_sda_d;
            shift_scl_q <= shift_scl_d;
            shift_prg_q <= shift_prg_d;
            index_q     <= index_d;
        end
    end
    
    assign sda_o = shift_sda_q[77];
    assign scl_o = shift_scl_q[77];

endmodule
