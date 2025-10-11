#!/bin/bash

# or with the correct path
CFG=/usr/share/oris/bar/

ewwii daemon --config "$CFG" &
ewwii open bar --config "$CFG"
