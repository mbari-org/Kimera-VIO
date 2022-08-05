#!/usr/bin/env bash

xhost +local:root

docker run -it \
    -e "DISPLAY=$DISPLAY" \
    -v '/tmp/.X11-unix:/tmp/.X11-unix:rw' \
    -v "$HOME/.Xauthority:/root/.Xauthority:rw" \
    --net=host \
    $@ \
    kimera_vio

xhost +local:root