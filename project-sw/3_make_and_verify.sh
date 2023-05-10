#!/bin/bash

#Author: Tianchen Yu
#Modified by: Qixiao Zhang, Zhe mo
#This script should be executed after the board is rebooted (after 2_copy_and_reboot)
#This script should be executed within HPS (in development board)
#May need to login again after reboot (not included in the script)

#INSTRUCTION:
#Should be run in "lab3-sw"
#Shoule be run like "../shells/3_make_and_verify.sh"

#ifup eth0
#echo "Ethernet connection checked"


echo "*********MAKE COMPILE START********"
make
echo "****driver and program compiled****"
echo ""

echo "****MOD INSTALL******"
insmod vga_ball.ko
echo "****MOD LOADED*******"
echo ""

echo "*****LIST MODEL****"
lsmod
echo ""

echo "******RUN HELLO*****"
./hello
echo "***ALL FINISHED*****"
