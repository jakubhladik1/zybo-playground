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

PROJ = top
PIN_DEF = top.xdc
DEVICE = xc7z020clg400-1
FAMILY = zynq7

all: $(PROJ).bit

-include build/top.sv.d

build/%.json: rtl/%.sv
	mkdir -p $(@D)
	yosys -E build/$*.sv.d -p 'read_verilog -sv $< ; hierarchy -top $(PROJ) -libdir rtl ; synth_xilinx -flatten -arch xc7 -top $(PROJ) ; write_json $@' 
# yosys -E build/$*.sv.d -p 'read_verilog -sv $< ; hierarchy -top $(PROJ) -libdir rtl ; synth_xilinx -flatten -abc9 -arch xc7 -top $(PROJ) ; write_json $@' 

%.frames: %.fasm $(PIN_DEF)
	python3 /usr/local/share/next-pnr/prjxray/utils/fasm2frames.py --part $(DEVICE) --db-root /usr/local/share/nextpnr-xilinx/database/$(FAMILY) $< > $@
	
%.fasm: $(PIN_DEF) %.json
	nextpnr-xilinx --chipdb /usr/local/share/nextpnr-xilinx/xilinx/$(DEVICE).bin --xdc $< --json $*.json --write $*_routed.json --fasm $@

%.bit: build/%.frames
	xc7frames2bit --part_file /usr/local/share/nextpnr-xilinx/database/$(FAMILY)/$(DEVICE)/part.yaml --part_name $(DEVICE) --frm_file $< --output_file $@

prog: $(PROJ).bit
	openocd -f interface/ftdi/digilent-hs1.cfg -f target/zynq_7000.cfg -c "adapter speed 10000" -c "init" -c "pld load 0 $<" -c "shutdown"

clean:
	rm -rf build $(PROJ).bit

.SECONDARY:
.PHONY: all prog clean
