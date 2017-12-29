#!/usr/bin/env bash

# ------------------------------------- #
# Author:   Quinn Wilby                 #
# Contact:  contact@loki.moe            #
# Github:   https://github.com/druanae/ #
# ------------------------------------- #
# SCREC - Screen Record                 #
# This script allows you to record your #
# screen using slop and ffmpeg.         #
# ------------------------------------- #

# --- VARIABLE DECLARATIONS --- #
declare file_name='%F_%R:%S'
declare file_type='webm'
declare -r config_dir="${XDG_CONFIG_DIR:-$HOME/.config}/screc"
declare -r config_file="${config_dir}/config.conf"
declare -r red='\e[31m'
declare -r cyan='\e[36m'

# --- FUNCTIONS --- # 

in_term() {
    [[ -t 0 || -p /dev/stdin ]]
}


while getopts "fghsw" opt; do
    case $opt in
        f) mode='fullscreen' ;;
        g) file_type='gif' ;;
        h) help_text; exit 0 ;;
        s) file_type='png' ;;
        w) file_type='webm' ;;
    esac
done
shift $((OPTIND-1))

