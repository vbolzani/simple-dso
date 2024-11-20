#!/bin/bash

if [ ! -z "$(ps | grep node)" ]
then
    echo "Node process found in target VM. Killing it..."
    killall node
else
    echo "Node process not found..."
fi

node http.js &
echo "Node process launched..."

exit