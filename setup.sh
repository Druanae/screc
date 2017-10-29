#!/bin/bash

# ----- sudo & uninstall ----- #
if [ "${1}" = "--uninstall" ]; then

    rm /usr/local/bin/screc
    rm -rf ${HOME}/.config/screc/
    echo "Uninstallation of screc completed."
    echo "Dependencies however still remain."

    exit 0
fi

#/----------------------------/#

# Install dependencies
echo "Checking Dependencies..."
(which ffmpeg &>/dev/null && echo -e "\e[32mFOUND\e[39m: ffmpeg") \
    || { echo -e "\e[31mERROR\e[39m:ffmpeg not found, please install it via your package manager."; exit 1; }
(which slop &>/dev/null && echo -e "\e[32mFOUND\e[39m: slop") \
    || { echo -e "\e[31mERROR\e[39m: slop not found, please install it via your package manager."; exit 1; }
echo

# Install script 
scriptdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
confdir="$HOME/.config/screc"

if [ -d $confdir ]; then
    cp $confdir/config.cfg $confdir/config.cfg.bak
fi

if [ ! -d $confdir ]; then
    mkdir -p $confdir
fi

cp $scriptdir/script.sh $confdir
cp $scriptdir/setup.sh $confdir
cp $scriptdir/config.cfg $confdir

# Give directory ownership to the actual user
chown -R $(whoami | awk '{print $1}') $confdir

# Create a symbolic link to /usr/local/bin
if [ ! -f /usr/local/bin/screc ]; then
    sudo ln -s $confdir/script.sh /usr/local/bin/screc
fi



# Tell the user its done!
echo -e "INFO: Installation of screc completed. See \e[36mscrec -h\e[39m for usage info."
echo -e "INFO: The config is located in \e[36m~/.config/screc/\e[39m"
echo -e "INFO: To uninstall screc run this script again as root with the \e[36m--uninstall\e[39m flag"
