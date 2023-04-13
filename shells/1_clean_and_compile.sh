#!/bin/bash

#Author: Tianchen Yu
#Modified by: Qixiao Zhang, Zhe Mo
#This script is for cleaning, re-compiling HDL,rbf and dtb files when the hardware
#verilog code is modified
#This script should be executed in host machine

#INSTRUCTION:
#Should be run in the folder "lab3-hw"
#Should be run like "../shells/1_clean_and_compile.sh"

echo "qsys cleaning...."
make qsys-clean
echo "qsys clean is completed"
echo ""

echo "generating HDL......"
make qsys
echo ""

make quartus
echo "compiling qsys file......"
echo ""

make rbf
echo "rbf file is created"
echo ""


embedded_command_shell.sh
echo "embedded command finished"

make dtb
echo "dtb and dts files created"




