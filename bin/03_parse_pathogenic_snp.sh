#!/bin/bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmp_dir=$script_dir/tmp

perl_parser=$script_dir/parse_pathogenic_training_data.pl
input_file=$tmp_dir/selected_varibench_pathogenic_snp
output_file=$tmp_dir/parsed_pathogenic_snp

echo 'Parsing raw Pathogenic SNP . . . .'

$perl_parser < $input_file | sort -k1 $tmp_avdb1 | awk -F'\t' '{ print $2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$1 }' | uniq > $output_file


