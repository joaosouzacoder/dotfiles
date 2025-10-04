#!/usr/bin/env sh

sketchybar --add item clock right \
           --set clock update_freq=10 \
                       label="$(date '+%H:%M')"