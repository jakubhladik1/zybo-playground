#!/usr/bin/env bash

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

mkdir -p tools
cd tools

sudo apt install -y xvfb libtinfo5 build-essential

#
# Install Vivado 2017.2 manually into $HOME/Xilinx
#

# Install USB JTAG drivers
sudo $HOME/Xilinx/Vivado/2017.2/data/xicom/cable_drivers/lin64/install_script/install_drivers

# Fix issue with non-traditional ethernet adapter name: https://www.itzgeek.com/how-tos/linux/debian/change-default-network-name-ens33-to-old-eth0-on-debian-9.html
sudo sed -i 's/GRUB_CMDLINE_LINUX="[^"]*/& net.ifnames=0 biosdevname=0/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Fix issue with lmutil https://support.xilinx.com/s/question/0D52E00006iHtI4SAK/flexlm-no-such-file-or-directory?language=en_US
sudo ln -s /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3

# Fix issue with obsolete rlwrap: https://support.xilinx.com/s/question/0D52E00006hpSCpSAM/vitis-on-wsl?language=en_US
apt install -y --fix-broken rlwrap
sed -i -e 's|"$RDI_BINROOT"/unwrapped/.*/rlwrap|/usr/bin/rlwrap|' $HOME/Xilinx/SDK/2017.2/bin/x*
sed -i -e 's|"$RDI_BINROOT"/unwrapped/.*/rlwrap|/usr/bin/rlwrap|' $HOME/Xilinx/Vivado/2017.2/bin/x*

# Download, compile, and install Verilator 5.002 (patched)
sudo apt install -y git python3 python3-pip autoconf flex bison
wget -O verilator.tar.gz "https://github.com/verilator/verilator/archive/refs/tags/v5.002.tar.gz"
tar -xzf verilator.tar.gz
cd verilator-*
# cocotb 1.7.1 only supports Verilator 4.106, but a patch exists: https://github.com/verilator/verilator/issues/2778
patch include/verilated_vpi.cpp << EOM
--- verilator-5.002/include/verilated_vpi.cpp   2022-10-29 17:45:54.000000000 -0400
+++ verilator-5.002_patched/include/verilated_vpi.cpp   2022-11-11 17:11:52.240380059 -0500
@@ -610,6 +610,7 @@
             VerilatedVpiCbHolder& ho = *it;
             VL_DEBUG_IF_PLI(VL_DBG_MSGF("- vpi: reason_callback reason=%d id=%" PRId64 "\n",
                                         reason, ho.id()););
+            ho.invalidate();
             (ho.cb_rtnp())(ho.cb_datap());
             called = true;
             if (was_last) break;
EOM
autoconf
./configure
make -j `nproc`
sudo make install
cd ..

# Install cocotb
sudo pip3 install cocotb pytest

# Install OpenOCD
sudo apt install -y openocd

echo "Script finished. Reboot the machine for the new kernel parameters to take effect."
