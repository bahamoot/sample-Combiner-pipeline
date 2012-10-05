#!/bin/bash -l
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

combiner_dir=/home/jessada/development/scilifelab/projects/combiner

tmp_dir=$script_dir/tmp

training_dataset=$tmp_dir/training_dataset
validation_dataset=$tmp_dir/validation_dataset
test_dataset=$tmp_dir/test_dataset

#define default values
STEP_SIZE_DEFAULT="0.0002"
ITERATION_DEFAULT="10000"
MIN_FIRST_HIDDEN_NODES_DEFAULT="3"
MAX_FIRST_HIDDEN_NODES_DEFAULT="5"
MIN_SECOND_HIDDEN_NODES_DEFAULT="3"
MAX_SECOND_HIDDEN_NODES_DEFAULT="5"
OUTPUT_DIR_DEFAULT=$script_dir/../result

usage=$(
cat <<EOF
usage:
$0 [OPTION]
option:
-s VALUE   set step size (default is $STEP_SIZE_DEFAULT)
-i VALUE   set number of iteration (default is $ITERATION_DEFAULT)
-j VALUE   set number of minimum hidden nodes in the first hidden layer (default is $MIN_FIRST_HIDDEN_NODES_DEFAULT)
-k VALUE   set number of maximum hidden nodes in the first hidden layer (default is $MAX_FIRST_HIDDEN_NODES_DEFAULT)
-m VALUE   set number of minimum hidden nodes in the second hidden layer (default is $MIN_SECOND_HIDDEN_NODES_DEFAULT)
-n VALUE   set number of maximum hidden nodes in the second hidden layer (default is $MAX_SECOND_HIDDEN_NODES_DEFAULT)
-O DIR     set output directory (default is $OUTPUT_DIR_DEFAULT). This directory will contain figures and parameter files
EOF
)

die () {
    echo >&2 "[exception] $@"
    echo >&2 "$usage"
    exit 1
}

#get file
while getopts "i:j:k:m:n:s:O:" OPTION; do
  case "$OPTION" in
    i)
      iteration="$OPTARG"
      ;;
    j)
      min_first_hidden_nodes="$OPTARG"
      ;;
    k)
      max_first_hidden_nodes="$OPTARG"
      ;;
    m)
      min_second_hidden_nodes="$OPTARG"
      ;;
    n)
      max_second_hidden_nodes="$OPTARG"
      ;;
    s)
      step_size="$OPTARG"
      ;;
    O)
      output_dir="$OPTARG"
      ;;
    *)
      die "unrecognized option"
      ;;
  esac
done

#setting default values:
: ${step_size=$STEP_SIZE_DEFAULT}
: ${iteration=$ITERATION_DEFAULT}
: ${min_first_hidden_nodes=$MIN_FIRST_HIDDEN_NODES_DEFAULT}
: ${max_first_hidden_nodes=$MAX_FIRST_HIDDEN_NODES_DEFAULT}
: ${min_second_hidden_nodes=$MIN_SECOND_HIDDEN_NODES_DEFAULT}
: ${max_second_hidden_nodes=$MAX_SECOND_HIDDEN_NODES_DEFAULT}
: ${output_dir=$OUTPUT_DIR_DEFAULT}

#show the values as read in by the flags
cat <<EOF
training configuration:
step size               : $step_size
iteration               : $iteration
min first hidden nodes  : $min_first_hidden_nodes
max first hidden nodes  : $max_first_hidden_nodes
min second hidden nodes : $min_second_hidden_nodes
max second hidden nodes : $max_second_hidden_nodes
output directory        : $output_dir
EOF



matlab -nosplash -nodesktop -r "cd "$combiner_dir"; try, calibrate_perceptron($step_size, $iteration, $min_first_hidden_nodes:$max_first_hidden_nodes, $min_second_hidden_nodes:$max_second_hidden_nodes, '$training_dataset', '$validation_dataset', '$test_dataset', '$output_dir'); end; quit"





