#!/bin/bash

mmsg dispatch destroy_all_virtual_output
mmsg dispatch create_virtual_output

client=$(mmsg get focusing-client)
monitor=$(echo $client | jq -r ".monitor")
scale=$(wlr-randr | awk "/^$monitor/{f=1} f && /Scale:/{print \$2; exit}")
position=$(echo $client | jq -r '"\(.x),\(.y)"')
dimensions=$(echo $client | jq -r --argjson scale $scale '"\(.width*$scale)x\(.height*$scale)"')
output=$(wlr-randr | awk '/^HEADLESS/{print $1; exit}')
wlr-randr --output ${output} --pos ${position} --scale ${scale} --custom-mode ${dimensions}@60Hz
