#!/bin/bash

# look for line where third column is 1, then print first column
current_output=$(mmsg -g -o | awk '$3 == 1 { print $1 }')

# build an associative array `geometry` and format with printf
mmsg -o "$current_output" -g -x | awk '{ geometry[$1] = $2 } END { printf "%s,%s %sx%s\n", geometry["x"], geometry["y"], geometry["width"], geometry["height"] }'
