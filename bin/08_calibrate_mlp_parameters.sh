#!/bin/bash -l
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


$script_dir/calibrate_perceptron.sh -i 500 -s 0.007 -m 4 -n 5 -j 4 -k 5

stty sane

