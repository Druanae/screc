#!/bin/bash

# --- source files --- #
screcdir="$HOME/.config/screc"
current_version="v0.1"

# --- setup variables --- #

# check config dir exists.
if [ ! -d "$screcdir" ]; then
    echo "INFO:  Could not find config."
    echo "INFO:  Please run setup."
    exit 1
fi

source "$screcdir/config.cfg"

dir_name="$gif_dir"
filename="$filename_format"

# ----------------------- #

function screc() {

    if [ "$1" == "stop" ]; then
        if [ ! -f /tmp/screc.pid ]; then
            echo "Pidfile doesn't exist, exiting..."
            exit 1
        fi
        echo "Stopping screc recording..."
        kill -INT $(cat /tmp/screc.pid)
        exit 0
    elif [ "$1" == "clean" ]; then
        rm /tmp/screc.pid
        exit 0
    elif [ "$1" != "rec" ]; then
        echo "Unknown subcommand $1. Try \"rec\", \"stop\" or \"clean\""
        exit 1
    elif [ -f /tmp/screc.pid ]; then
        echo "Pidfile exists, exiting..."
        exit 1 
    fi 
        TMP_AVI=$(mktemp /tmp/outXXXXXXXXXX.avi)
        TMP_PALETTE=$(mktemp /tmp/outXXXXXXXXXX.png)
    if [ "$2" == "" ]; then
        OUT_GIF="${dir_name}/${filename}.gif"
    else
        OUT_GIF="${dir_name}/${2}.gif"
    fi
    function cleanup() {
        rm /tmp/screc.pid
        rm "$TMP_AVI"
        rm "$TMP_PALETTE"
    }  
    function on_sigint() {
        echo "Stopping gif recorder..."
        kill -INT $(cat "/tmp/screc.pid")
    }  
    trap cleanup EXIT
    trap on_sigint SIGINT

    if [ -f /tmp/screc.pid ]; then
        rm /tmp/screc.pid
    fi
    touch /tmp/screc.pid
    read -r X Y W H G ID < <(slop -f "%x %y %w %h %g %i" -q)
    if [ -z "$X" ]; then
        echo "Cancelled..."
        exit 1
    fi
    ffmpeg -loglevel warning -y -f x11grab -show_region 1 -framerate 15 \
        -s "$W"x"$H" -i :0.0+"$X","$Y" -codec:v huffyuv   \
        -vf crop="iw-mod(iw\\,2):ih-mod(ih\\,2)" "$TMP_AVI" &
    PID="$!"
    echo "$PID" > /tmp/screc.pid &
    wait "$PID"
    ffmpeg -v warning -i "$TMP_AVI" -vf "fps=15,palettegen=stats_mode=full" -y $TMP_PALETTE
    ffmpeg -v warning -i "$TMP_AVI" -i "$TMP_PALETTE" -lavfi "fps=15 [x]; [x][1:v] paletteuse=dither=sierra2_4a" -y $OUT_GIF
    echo $OUT_GIF
}

if [ "${1}" = "-gr" ]; then
    screc rec ${2}
    exit 0
fi

if [ "${1}" = "-gs" ]; then
    screc stop
    exit 0
fi

if [ "${1}" = "-h" ] || [ "${1}" = "--help" ] || [ "${1}" = "" ]; then
    echo -e "usage: screc \e[36m[OPTION]\e[39m..."
    echo -e "Record an area of the screen."
    echo
    echo -e "OPTIONS:"
    echo -e "   -gr        starts the GIF recording"
    echo -e "                optionally delcare a filename."
    echo -e "                i.e. \e[36mscrec -gr example\e[39m"
    echo -e "   -gs        stops the GIF recording"
fi
