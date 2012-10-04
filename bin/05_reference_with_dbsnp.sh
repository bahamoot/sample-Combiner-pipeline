#!/bin/bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

annovar_dir=~/development/scilifelab/tools/annovar
annovar_humandb_dir=$annovar_dir/humandb/
tmp_dir=$script_dir/tmp

perl_annotate_variation=$annovar_dir/annotate_variation.pl
input_file=$tmp_dir/non_duplicated_snp
output_file=$tmp_dir/non_duplicated_snp135

echo 'Filtering using dbSNP . . . '
$perl_annotate_variation -filter -buildver hg19 -dbtype snp135 $input_file $annovar_humandb_dir
awk -F'\t' '{ print $3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9 }' $input_file.hg19_snp135_dropped > $output_file

