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

set_property PACKAGE_PIN K17 [get_ports {clk_ref_i}]
set_property PACKAGE_PIN D19 [get_ports {tmds_data_po[0]}]
set_property PACKAGE_PIN D20 [get_ports {tmds_data_no[0]}]
set_property PACKAGE_PIN C20 [get_ports {tmds_data_po[1]}]
set_property PACKAGE_PIN B20 [get_ports {tmds_data_no[1]}]
set_property PACKAGE_PIN B19 [get_ports {tmds_data_po[2]}]
set_property PACKAGE_PIN A20 [get_ports {tmds_data_no[2]}]
set_property PACKAGE_PIN H16 [get_ports {tmds_clk_po}]
set_property PACKAGE_PIN H17 [get_ports {tmds_clk_no}]
set_property PACKAGE_PIN M14 [get_ports {led_o}] 
set_property IOSTANDARD LVCMOS33 [get_ports {clk_ref_i}]
set_property IOSTANDARD TMDS_33 [get_ports {tmds_data_po[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {tmds_data_no[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {tmds_data_po[1]}]
set_property IOSTANDARD TMDS_33 [get_ports {tmds_data_no[1]}]
set_property IOSTANDARD TMDS_33 [get_ports {tmds_data_po[2]}]
set_property IOSTANDARD TMDS_33 [get_ports {tmds_data_no[2]}]
set_property IOSTANDARD TMDS_33 [get_ports {tmds_clk_po}]
set_property IOSTANDARD TMDS_33 [get_ports {tmds_clk_no}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_o}]

set_property PACKAGE_PIN F19 [get_ports {sda_o}]
set_property PACKAGE_PIN F20 [get_ports {scl_o}]
set_property PACKAGE_PIN G20 [get_ports {pwrup_o}]

set_property IOSTANDARD LVCMOS33 [get_ports {sda_o}]
set_property IOSTANDARD LVCMOS33 [get_ports {scl_o}]
set_property IOSTANDARD LVCMOS33 [get_ports {pwrup_o}]

set_property PULLUP true [get_ports {pwrup_o}]
