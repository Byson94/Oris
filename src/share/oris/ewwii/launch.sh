#!/bin/bash

# or with the correct path
CFG=/usr/share/oris/ewwii/

ewwii daemon --config "$CFG" &
ewwii open bar --config "$CFG"
ewwii open time --config "$CFG"