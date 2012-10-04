#!/bin/bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

data_dir=~/development/scilifelab/master_data
raw_varibench_neutral_snp=$data_dir/varibench/raw_varibench_neutral_snp
raw_varibench_pathogenic_snp=$data_dir/varibench/raw_varibench_pathogenic_snp

selected_varibench_neutral_snp=$script_dir/tmp/selected_varibench_neutral_snp
selected_varibench_pathogenic_snp=$script_dir/tmp/selected_varibench_pathogenic_snp

grep -P "\t[ACGT][ACGT][ACGT]\t" $raw_varibench_neutral_snp > $selected_varibench_neutral_snp
grep -P "\t[ACGT][ACGT][ACGT]\t" $raw_varibench_pathogenic_snp | sed "/p.D214Y/d" | sed "/p.D214N/d" | sed "/p.G449D/d" | sed "/p.I138V/d" | sed "/p.G1306E/d" | sed "/p.G1306A/d" | sed "/p.G1306V/d" > $selected_varibench_pathogenic_snp

