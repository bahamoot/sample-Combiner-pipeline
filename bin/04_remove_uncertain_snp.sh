#!/bin/bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmp_dir=$script_dir/tmp

parsed_neutral_snp=$tmp_dir/parsed_neutral_snp
parsed_pathogenic_snp=$tmp_dir/parsed_pathogenic_snp
output_file=$tmp_dir/non_duplicated_snp

tmp_all_snp=$tmp_dir/all_snp

echo 'Remove uncertain SNPs'

awk -F'\t' '{ print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t0|"$7"\t"$7 }' $parsed_neutral_snp > $tmp_all_snp
awk -F'\t' '{ print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t1|"$7"\t"$7 }' $parsed_pathogenic_snp >> $tmp_all_snp

sort -t $'\t' -k7 $tmp_all_snp | uniq -f6 -u > $output_file


