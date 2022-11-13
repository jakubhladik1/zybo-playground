#
#    Copyright (C) 2022  Jakub Hladik
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles

import numpy as np
from PIL import Image


@cocotb.test()
async def test_video_generator(dut):

    frame = np.zeros((dut.NUM_ROW_ACTIVE.value.integer, dut.NUM_COL_ACTIVE.value.integer, 3), dtype=np.uint8)
    row = 0
    col = 0

    # Assert reset
    dut.rst_i.setimmediatevalue(1)

    # Create clock
    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Hold reset asserted for four clock cycles
    await ClockCycles(dut.clk_i, 4)

    # Deassert reset synchronously with clk_i
    dut.rst_i.value = 0

    while True:
        if dut.de_o.value:
            frame[row, col] = dut.pix_o.value.integer

            if row == 0 or row == (dut.NUM_ROW_ACTIVE.value.integer-1) or col == 0 or col == dut.NUM_COL_ACTIVE.value.integer-1:
                assert dut.pix_o.value == 0xfff
            else:
                assert dut.pix_o.value == 0x000
            
            if (col == (dut.NUM_COL_ACTIVE.value.integer-1)):
                if (row == (dut.NUM_ROW_ACTIVE.value.integer-1)):
                    break
                row += 1
                col = 0
            else:
                col += 1
        await RisingEdge(dut.clk_i)

    img = Image.fromarray(frame, "RGB")
    img.save("frame.png")

