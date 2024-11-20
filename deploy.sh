#!/bin/bash

if [ ! -z $(ps -ef | grep "node") ]
then
    echo "Node process found in target VM. Killing it..."
    killall node
else
    echo "Node process not found..."

node http.js & 