#!/bin/bash

FLAG_1=0
FLAG_2=0
FLAG_3=0

##############################################################################################
# Moving files to desktop and making virtual environment and installing all the dependencies #
##############################################################################################

if test -f ~/Desktop/OFC/OFC.py;
then
    FLAG_3=1
else
    REPO_DIR=$(dirname "$(readlink -f "$0")")
    echo "This is a shell script to install all the dependencies required for this software to run."
    echo "Dependencies required are as follows."
    echo "1 -> python3-virtualenv AND python3-venv"
    echo "2 -> PyGObject" 
    echo "3 -> PyCairo" 
    echo "4 -> Expect" 
    echo "----------Creating Folder for Open Freeze Center----------"
    cd ~/Desktop
    mkdir OFC
    echo "----------Installing python3-virtualenv AND python3-venv and other dependencies----------"
    sudo apt update
    sudo apt upgrade
    sudo apt install python3-virtualenv python3-venv libgirepository1.0-dev libcairo2-dev
    echo "----------Creating Virtual Environment for Open Freeze Center----------"
    python3 -m venv ~/Desktop/OFC
    echo "----------Virtual Environment for Open Freeze Center created----------"
    echo "----------Installing PyGObject----------"
    # get distro version if ubuntu base, since we need to restrict pygobject version for distro version <24.04
	RESTRICT_GI_VER=0
	if [ -f /etc/os-release ]; then
		. /etc/os-release
		if [[ $ID == *"ubuntu"* ]] || [[ $ID_LIKE == *"ubuntu"* ]]; then
		    echo "Running ubuntu-based distro"
		    if { echo "$VERSION_ID"; echo "22.04.5"; } | sort --version-sort --check=quiet; then
		        echo "Version is 22.04 or less, restricting pygobject version"
		        RESTRICT_GI_VER=1
		    fi
		fi
	fi
    if [ "$RESTRICT_GI_VER" -eq "0" ]; then
        ~/Desktop/OFC/bin/pip3 install PyGObject
    else
        ~/Desktop/OFC/bin/pip3 install "PyGObject<=3.52.0"
    fi
    echo "----------Installing PyCairo----------"
    ~/Desktop/OFC/bin/pip3 install pycairo
    echo "----------Installing Expect----------"
    sudo apt-get install expect
    echo "----------Moving files to virtual environment----------"
    cp -i "${REPO_DIR}/install.sh" ~/Desktop/OFC
    cp -i "${REPO_DIR}/file_1.sh" ~/Desktop/OFC
    cp -i "${REPO_DIR}/file_2.sh" ~/Desktop/OFC
    cp -i "${REPO_DIR}/OFC.py" ~/Desktop/OFC
    cp -i "${REPO_DIR}/README.md" ~/Desktop/OFC
    cp -i "${REPO_DIR}/LICENSE"  ~/Desktop/OFC
    FLAG_3=1
fi

################################
# Prepairing the EC read/write #
################################

if test -d /etc/modprobe.d;
then
    if test -f /etc/modprobe.d/ec_sys.conf;
    then
        if grep -q "options ec_sys write_support=1" "/etc/modprobe.d/ec_sys.conf";
        then FLAG_1=1
        else
            echo "----------Prepairing system for EC read/write----------"
            cd ~/Desktop/OFC/
            sudo ./file_1.sh
            FLAG_1=1
        fi
    else
        echo "----------Prepairing system for EC read/write----------"
        sudo touch /etc/modprobe.d/ec_sys.conf
        cd ~/Desktop/OFC/
        sudo ./file_1.sh
        FLAG_1=1
    fi
else
    echo "----------Prepairing system for EC read/write----------"
    mkdir /etc/modprobe.d
    sudo touch /etc/modprobe.d/ec_sys.conf
    cd ~/Desktop/OFC/
    sudo ./file_1.sh
    FLAG_1=1
fi

if test -d /etc/modules-load.d;
then
    if test -f /etc/modules-load.d/ec_sys.conf;
    then
        if grep -q "ec_sys" "/etc/modules-load.d/ec_sys.conf";
        then FLAG_2=1
        else
            echo "----------Prepairing system for EC read/write----------"
            cd ~/Desktop/OFC/
            sudo ./file_2.sh
            FLAG_2=1
        fi
    else
        echo "----------Prepairing system for EC read/write----------"
        sudo touch /etc/modules-load.d/ec_sys.conf
        cd ~/Desktop/OFC/
        sudo ./file_2.sh
        FLAG_2=1
    fi
else
    echo "----------Prepairing system for EC read/write----------"
    mkdir /etc/modules-load.d
    sudo touch /etc/modules-load.d/ec_sys.conf
    cd ~/Desktop/OFC/
    sudo ./file_2.sh
    FLAG_2=1
fi

if [ "$FLAG_1" -eq 1 ] && [ "$FLAG_2" -eq 1 ];
then
    echo "----------EC read/write is enabled----------"
else
    echo "----------EC read/write is can not be enabled----------"
fi

if [ "$FLAG_3" -eq 1 ];
then
    if test -f ~/Desktop/OFC/config.py;
    then
        echo "----------Running Software----------"
        sudo nohup ~/Desktop/OFC/bin/python3 ~/Desktop/OFC/OFC.py
    else
        echo "----------Running Software----------"
        sudo nohup ~/Desktop/OFC/bin/python3 ~/Desktop/OFC/OFC.py
    fi
fi
