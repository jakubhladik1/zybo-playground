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
from cocotb.triggers import RisingEdge, ClockCycles

@cocotb.test()
async def test_blinky(dut):

    # Get CWIDTH (counter width) parameter value from the DUT
    cwidth = dut.CWIDTH.value.integer
    
    # Create clock
    clock = Clock(dut.clk_i, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Set reset to high
    dut.rst_i.setimmediatevalue(1)

    # Reset value check
    assert dut.cnt_q.value == 0, f"The internal register cnt_q is {dut.cnt_q.value} but should be 0 during reset."
    assert dut.led_o.value == 0, f"The output led_o is {dut.led_o.value} but should be 0 during reset."

    # Create reset pulse
    dut.rst_i.setimmediatevalue(1)
    await ClockCycles(dut.clk_i, 4, rising=True)
    dut.rst_i.setimmediatevalue(0)

    # Right After reset check
    assert dut.cnt_q.value == 0, f"The internal register cnt_q is {dut.cnt_q.value} but should be 0 after reset."
    assert dut.led_o.value == 0, f"The output led_o is {dut.led_o.value} but should be 0 after reset."

    for i in range(0, 10):
        await ClockCycles(dut.clk_i, (2**cwidth)//2-1, rising=True)

        # Right before led_o going high check
        assert dut.cnt_q.value == 7, f"The internal register cnt_q is {dut.cnt_q.value} but should be (2^CWIDTH)/2-1."
        assert dut.led_o.value == 0, f"The output led_o is {dut.led_o.value} but should be 0 at cnt_q = (2^CWIDTH)/2-1."

        await RisingEdge(dut.clk_i)

        # led_o going high check
        assert dut.cnt_q.value == 8, f"The internal register cnt_q is {dut.cnt_q.value} but should be (2^CWIDTH)/2."
        assert dut.led_o.value == 1, f"The output led_o is {dut.led_o.value} but should be 1 at cnt_q = (2^CWIDTH)/2."

        await ClockCycles(dut.clk_i, ((2**cwidth)//2)-1, rising=True)

        # Right before led_o going low check
        assert dut.cnt_q.value == 15, f"The internal register cnt_q is {dut.cnt_q.value} but should be (2^CWIDTH)-1."
        assert dut.led_o.value == 1, f"The output led_o is {dut.led_o.value} but should be 1 at cnt_q = (2^CWIDTH)-1."

        await RisingEdge(dut.clk_i)

        # led_o going low check
        assert dut.cnt_q.value == 0, f"The internal register cnt_q is {dut.cnt_q.value} but should be 0 (rollover)."
        assert dut.led_o.value == 0, f"The output led_o is {dut.led_o.value} but should be 0 at cnt_q = 0 (rollover)."
