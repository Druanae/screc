#!/bin/bash
function screenrecord() {

    if [ "$1" == "stop" ]; then
        if [ ! -f /tmp/screenrecord.pid ]; then
            echo "Pidfile doesn't exist, exiting..."
            exit 1
        fi
        echo "Stopping gif recorder..."
        kill -INT $(cat /tmp/screenrecord.pid)
        exit 0
    elif [ "$1" == "clean" ]; then
        rm /tmp/screenrecord.pid
        exit 0
    elif [ "$1" != "rec" ]; then
        echo "Unknown subcommand $1. Try \"rec\", \"stop\" or \"clean\""
        exit 1
    elif [ -f /tmp/screenrecord.pid ]; then
        echo "Pidfile exists, exiting..."
        exit 1 
    fi 
    TMP_AVI=$(mktemp /tmp/outXXXXXXXXXX.avi)
    TMP_PALETTE=$(mktemp /tmp/outXXXXXXXXXX.png)
    TMP_GIF=$(mktemp /tmp/outXXXXXXXXXX.gif)
    export LAST_GIF=$TMP_GIF
    function cleanup() {
        rm /tmp/screenrecord.pid
        rm "$TMP_AVI"
        rm "$TMP_PALETTE"
    }  
    function on_sigint() {
        echo "Stopping gif recorder..."
        echo $LAST_GIF
        unset LAST_GIF
        kill -INT $(cat "/tmp/screenrecord.pid")
    }  
    trap cleanup EXIT
    trap on_sigint SIGINT

    touch /tmp/screenrecord.pid
    read -r X Y W H G ID < <(slop -f "%x %y %w %h %g %i" -q)
    if [ -z "$X" ]; then
        echo "Cancelled..."
        exit 1
    fi
    ffmpeg -loglevel warning -y -f x11grab -show_region 1 -framerate 15 \
        -s "$W"x"$H" -i :0.0+"$X","$Y" -codec:v huffyuv   \
        -vf crop="iw-mod(iw\\,2):ih-mod(ih\\,2)" "$TMP_AVI" &
    PID="$!"
    echo "$PID" > /tmp/screenrecord.pid &
    wait "$PID"
    ffmpeg -v warning -i "$TMP_AVI" -vf "fps=15,palettegen=stats_mode=full" -y $TMP_PALETTE
    ffmpeg -v warning -i "$TMP_AVI" -i "$TMP_PALETTE" -lavfi "fps=15 [x]; [x][1:v] paletteuse=dither=sierra2_4a" -y $TMP_GIF
    echo $LAST_GIF
}

if [ "${1}" = "-gr" ]; then
    screenrecord rec
    exit 0
fi

if [ "${1}" = "-gs" ]; then
    screenrecord stop
    exit 0
fi

if [ "${1}" = "-h" ] || [ "${1}" = "--help" ] || [ "${1}" = "" ]; then
    echo "usage: ${0} [-h | -gr | -gs]"
    echo ""
    echo "   -gr        starts the GIF recording"
    echo "   -gs        stops the GIF recording"
fi
