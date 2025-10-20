#!/bin/bash

pid=`pgrep -x wf-recorder`
status=$?

if [ $status != 0 ]
then
  wf-recorder -f $(xdg-user-dir VIDEOS)/$(date +'recording_%Y-%m-%d-%H%M%S.mp4') -o DP-1;
  # wf-recorder -f $(xdg-user-dir VIDEOS)/$(date +'recording_%Y-%m-%d-%H%M%S.mp4') -g "1508,350 2492x1227";
else
  pkill --signal SIGINT -x wf-recorder
fi;
