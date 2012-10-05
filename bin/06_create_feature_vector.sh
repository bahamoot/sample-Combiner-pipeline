#!/bin/bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

annovar_dir=~/development/scilifelab/tools/annovar
annovar_humandb_dir=$annovar_dir/humandb/
perl_annotate_variation=$annovar_dir/annotate_variation.pl
tmp_dir=$script_dir/tmp

input_file=$tmp_dir/non_duplicated_snp135
output_file=$tmp_dir/featured_snp

tmp_sift=$tmp_dir/snp135_sift
tmp_pp2=$tmp_dir/snp135_pp2
tmp_phylop=$tmp_dir/snp135_phylop
tmp_lrt=$tmp_dir/snp135_lrt
tmp_mt=$tmp_dir/snp135_mt
tmp_gerp=$tmp_dir/snp135_gerp

tmp_join1=$tmp_dir/tmp_join1
tmp_join2=$tmp_dir/tmp_join2
tmp_join3=$tmp_dir/tmp_join3
tmp_join4=$tmp_dir/tmp_join4
tmp_join5=$tmp_dir/tmp_join5



echo 'Filtering using Effect Predictors . . . '
$perl_annotate_variation -filter -buildver hg19 -dbtype ljb_sift   $input_file $annovar_humandb_dir -score_threshold 0
$perl_annotate_variation -filter -buildver hg19 -dbtype ljb_pp2    $input_file $annovar_humandb_dir -score_threshold 0
$perl_annotate_variation -filter -buildver hg19 -dbtype ljb_phylop $input_file $annovar_humandb_dir -score_threshold 0
$perl_annotate_variation -filter -buildver hg19 -dbtype ljb_lrt    $input_file $annovar_humandb_dir -score_threshold 0
$perl_annotate_variation -filter -buildver hg19 -dbtype ljb_mt     $input_file $annovar_humandb_dir -score_threshold 0
$perl_annotate_variation -filter -buildver hg19 -dbtype ljb_gerp++ $input_file $annovar_humandb_dir -score_threshold 0

echo 'Formating result from Effect Predictors . . . '
awk -F'\t' '{ printf "%s\t%06.3f\t%d\t%d\t%d\t%s\t%s\n", $8, $2, $3, $4, $5, $6, $7 }' $input_file.hg19_ljb_sift_dropped   | sort -k1 > $tmp_sift
awk -F'\t' '{ printf "%s\t%06.3f\t%d\t%d\t%d\t%s\t%s\n", $8, $2, $3, $4, $5, $6, $7 }' $input_file.hg19_ljb_pp2_dropped    | sort -k1 > $tmp_pp2
awk -F'\t' '{ printf "%s\t%06.3f\t%d\t%d\t%d\t%s\t%s\n", $8, $2, $3, $4, $5, $6, $7 }' $input_file.hg19_ljb_phylop_dropped | sort -k1 > $tmp_phylop
awk -F'\t' '{ printf "%s\t%06.3f\t%d\t%d\t%d\t%s\t%s\n", $8, $2, $3, $4, $5, $6, $7 }' $input_file.hg19_ljb_lrt_dropped    | sort -k1 > $tmp_lrt
awk -F'\t' '{ printf "%s\t%06.3f\t%d\t%d\t%d\t%s\t%s\n", $8, $2, $3, $4, $5, $6, $7 }' $input_file.hg19_ljb_mt_dropped     | sort -k1 > $tmp_mt
awk -F'\t' '{ printf "%s\t%06.3f\t%d\t%d\t%d\t%s\t%s\n", $8, $2, $3, $4, $5, $6, $7 }' $input_file.hg19_ljb_gerp++_dropped | sort -k1 > $tmp_gerp

echo 'Joining scores from Effect Predictors . . . '
join -t $'\t' -a 1 -a 2 -j 1 -e NULL -o 0,1.2,2.2 $tmp_gerp $tmp_sift > $tmp_join1
join -t $'\t' -a 1 -a 2 -j 1 -e NULL -o 0,2.2,2.3,1.2 $tmp_pp2 $tmp_join1 > $tmp_join2
join -t $'\t' -a 1 -a 2 -j 1 -e NULL -o 0,2.2,2.3,2.4,1.2 $tmp_phylop $tmp_join2 > $tmp_join3
join -t $'\t' -a 1 -a 2 -j 1 -e NULL -o 0,2.2,2.3,2.4,2.5,1.2 $tmp_lrt $tmp_join3 > $tmp_join4
join -t $'\t' -a 1 -a 2 -j 1 -e NULL -o 0,2.2,2.3,2.4,2.5,2.6,1.2 $tmp_mt $tmp_join4 | uniq | grep -v "NULL" > $tmp_join5

grep "^0" $tmp_join5 | sed 's/$/\t0/g' | sed 's/^0|//g' > $output_file
grep "^1" $tmp_join5 | sed 's/$/\t1/g' | sed 's/^1|//g' >> $output_file


