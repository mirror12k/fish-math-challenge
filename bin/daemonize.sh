#!/bin/sh
sudo su "$1" -c "nohup sh -c \"$2\" < \"$4\" >> \"$3\" 2>&1 &"
