#!/bin/bash

#Author: Tianchen Yu
#Modified by: Qixiao Zhang, Zhe Mo
#This script should be executed after the rbf and dts files are ready in host (after 1_clean_and_compile)
#This script should be executed within HPS (in development board)
#need to make sure that screen /dev/ttyUSB0 115200 has been executed

#INSTRUCTION:
#Should be run in "lab3-sw"
#Shoule be run like "../shells/2_copy_and_reboot.sh

#screen /dev/ttyUSB0 115200

#ifup eth0
#echo "Ethernet connection checked"

USER_=hz2833
HOST_=micro35

echo "*****MOUNT START******"
mount /dev/mmcblk0p1 /mnt
echo "***MOUNT COMPLETE*****"
echo ""

#fill the directory of soc_system.rbf file after :
echo "*******COPY RBF FILE START*******"
scp $USER_@$HOST_.ee.columbia.edu:Documents/CSEE4840/ee4840project/project-hw/output_files/soc_system.rbf /mnt
echo "*******RBF FILE COPIED***********"
echo ""

echo "*********SYNC START********"
sync
echo "*******SYNC COMPLETE*******"
echo ""

#fill the directory of soc_system.dtb file after :
echo "********COPY RTB FILE START******"
scp $USER_@$HOST_.ee.columbia.edu:Documents/CSEE4840/ee4840project/project-hw/soc_system.dtb /mnt
echo "*********RTB FILE COPIED*********"

#reboot the system from the new rbf and dtb file
reboot
