#!/bin/bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

annovar_dir=~/development/scilifelab/tools/annovar
annovar_humandb_dir=$annovar_dir/humandb/
tmp_dir=$script_dir/tmp

perl_parser=$script_dir/parse_neutral_training_data.pl
input_file=$tmp_dir/selected_varibench_neutral_snp
reference_file=$annovar_humandb_dir/hg19_refGene.txt
output_file=$tmp_dir/parsed_neutral_snp

tmp_avdb1=$tmp_dir/raw_neutral_data1.avdb
tmp_avdb2=$tmp_dir/raw_neutral_data2.avdb


echo 'Parsing raw Neutral SNP . . . .'
cat $input_file | $perl_parser $reference_file | sort -k1 | awk -F'\t' '{ print $2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$1 }' | grep -E "^[0-9XY]+\s+" | uniq > $output_file

