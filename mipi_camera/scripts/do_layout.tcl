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

if {$argc > 0} {
    for {set i 0} {$i < $argc} {incr i} {
        set arg [ lindex $argv $i ]
        if {[ regexp {^BUILD_DIR=(.*)$} $arg match val ] == 1} {
            set build_dir "[ file normalize "${val}" ]"
        }
        if {[ regexp {^TOP=(.*)$} $arg match val ] == 1} {
            set top "$val"
        }
        if {[ regexp {^PART=(.*)$} $arg match val ] == 1} {
            set part "$val"
        }
    }
}

set_param general.maxThreads 2
set_part -quiet ${part}
read_checkpoint "${build_dir}/${top}_post_synth.dcp"
read_xdc "${top}_pins.xdc"
link_design -top ${top} -part ${part}
opt_design 
place_design 
route_design
write_checkpoint -force "${build_dir}/${top}_post_layout.dcp"
report_timing_summary
report_utilization
