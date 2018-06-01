#!/bin/bash

for i in 'dev' 'staging' 'production'
do
	up=${i^^}
	echo "up: $up"
done
