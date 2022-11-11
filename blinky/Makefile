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

BUILD_DIR = build
TOP = top
PART = xc7z020clg400-1


all: $(BUILD_DIR)/$(TOP).bit

%_post_synth.dcp: rtl/*.sv $(TOP)_timing.xdc
	mkdir -p $(@D)
	vivado -nolog -nojournal -mode batch -tempDir $(BUILD_DIR) -source scripts/do_synth.tcl -tclargs TOP=$(TOP) PART=$(PART) BUILD_DIR=$(BUILD_DIR)

%_post_layout.dcp: %_post_synth.dcp $(TOP)_pins.xdc
	vivado -nolog -nojournal -mode batch -tempDir $(BUILD_DIR) -source scripts/do_layout.tcl -tclargs TOP=$(TOP) PART=$(PART) BUILD_DIR=$(BUILD_DIR)

%.bit: %_post_layout.dcp
	vivado -nolog -nojournal -mode batch -tempDir $(BUILD_DIR) -source scripts/do_bitstream.tcl -tclargs TOP=$(TOP) PART=$(PART) BUILD_DIR=$(BUILD_DIR)
	rm -f usage_statistics_webtalk.html usage_statistics_webtalk.xml

prog: $(BUILD_DIR)/$(TOP).bit
	openocd -f interface/ftdi/digilent-hs1.cfg -f target/zynq_7000.cfg -c "adapter speed 10000 ; init ; pld load 0 $< ; shutdown"

clean:
	rm -rf $(BUILD_DIR) usage_statistics_webtalk.html usage_statistics_webtalk.xml

.SECONDARY:
.PHONY: all prog clean
