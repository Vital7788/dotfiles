#!/bin/bash
xinput set-prop "pointer:Logitech G305" "libinput Accel Profile Enabled" 0 1
xcape -e "Control_L=Escape"
amixer -c Generic sset 'Auto-Mute Mode' Disabled
dunst
