#!/usr/bin/bash

# TODO: If benchmakrs folder don't exist, make one

# Write to benchmark folder both the runs
time julia src/main.jl p
time julia src/main.jl s
