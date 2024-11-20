#!/bin/bash

if [ ! -z "$(ps | grep node)" ]
then
    echo "Node process found in target VM. Killing it..."
    killall node
else
    echo "Node process not found..."
fi

nohup node http.js > node_run.out 2> node_error.log < /dev/null &