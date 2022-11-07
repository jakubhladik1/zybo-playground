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

# Check if we are running on a Mac
if [ ! "$(uname)" == "Darwin" ]; then
    echo "This script can only be run on a Mac."
    exit 1
fi

# Check if brew is installed
which -s brew
if [[ $? != 0 ]] ; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Updating Homebrew..."
    brew update
fi

# Install dependencies for building
brew install cmake python boost boost-python3 eigen bison flex gawk libffi graphviz pkg-config tcl-tk xdot perl ccache autoconf gperftools libftdi bash llvm libopm open-ocd

# Create a folder for compilation of tools
mkdir -p tools
cd tools

# Download, extract, configure, compile and install prjxray
pip3 install Cython intervaltree junit-xml numpy openpyxl ordered-set parse progressbar2 pyjson5 pytest pytest-runner pyyaml scipy\>=1.2.1 simplejson sympy textx yapf==0.24.0
pip3 install fasm
git clone git@github.com:f4pga/prjxray.git
cd prjxray
git submodule update --init --recursive
mkdir build
cmake -DABSL_PROPAGATE_CXX_STD=ON ..
make -j`sysctl -n hw.ncpu`
sudo make install
# Change python version as needed
cp -r prjxray /usr/local/lib/python3.10/site-packages/
./download-latest-db.sh
mkdir -p /usr/local/share/next-pnr/prjxray
cp -r utils /usr/local/share/next-pnr/prjxray/
cp -r database /usr/local/share/nextpnr-xilinx/prjxray/
cd ..

# Download, extract, configure, compile and install yosys
curl -L https://github.com/YosysHQ/yosys/archive/refs/tags/yosys-0.22.tar.gz > yosys.tar.gz
tar -xzf yosys.tar.gz
cd yosys-*
make config-clang
make -j`sysctl -n hw.ncpu`
sudo make install
cd ..

# Download, extract, configure, compile and install nextpnr-xilinx
git clone git@github.com:gatecat/nextpnr-xilinx.git
cd nextpnr-xilinx
git submodule update --init --recursive
cmake -DCMAKE_C_COMPILER="/usr/local/opt/llvm/bin/clang" -DCMAKE_CXX_COMPILER="/usr/local/opt/llvm/bin/clang++" -DARCH=xilinx -DBUILD_GUI=OFF .
make -j`sysctl -n hw.ncpu`
sudo make install
# If you are having issues with the following, see https://github.com/gatecat/nextpnr-xilinx/issues/35#issuecomment-1304865960
python3 xilinx/python/bbaexport.py --device xc7z020clg400-1 --bba xilinx/xc7z020clg400-1.bba
./bbasm -l xilinx/xc7z020clg400-1.bba xilinx/xc7z020clg400-1.bin
mkdir -p /usr/local/share/nextpnr-xilinx
mkdir -p /usr/local/share/nextpnr-xilinx/xilinx
cp xilinx/xc7z020.bin /usr/local/share/nextpnr-xilinx/xilinx/
cp -r xilinx/external/prjxray-db/zynq7 /usr/local/share/nextpnr-xilinx/xilinx/
cd ..

# Download, extract, configure, compile and install verilator
# cocotb currently only supports 4.106
# curl -L https://github.com/verilator/verilator/archive/refs/tags/v5.002.tar.gz > verilator.tar.gz
curl -L https://github.com/verilator/verilator/archive/refs/tags/v4.106.tar.gz > verilator.tar.gz
tar -xzf verilator.tar.gz
cd verilator-*
autoconf
unset VERILATOR_ROOT
./configure
make -j`sysctl -n hw.ncpu`
sudo make install
cd ..

# Install cocotb
pip3 install cocotb pytest

# Install gtkwave
brew install gtkwave
