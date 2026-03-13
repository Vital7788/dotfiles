#!/bin/bash

# look for line where third column is 1, then print first column
current_monitor=$(mmsg -g -o | awk '$3 == 1 { print $1 }')

# create variable `monitor`, filter lines that start with `monitor`
# build an associative array `val`, and finally format with printf
mmsg -g -x | awk -v monitor="$current_monitor" '$1 == monitor { val[$2] = $3 } END { printf "%s,%s %sx%s\n", val["x"], val["y"], val["width"], val["height"] }'
