#!/bin/bash -l
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmp_dir=$script_dir/tmp

input_file=$tmp_dir/featured_snp

shuffled_featured_snp=$tmp_dir/shuffled_featured_snp

tmp_training_dataset=$tmp_dir/tmp_training_dataset
tmp_validation_dataset=$tmp_dir/tmp_validation_dataset
tmp_test_dataset=$tmp_dir/tmp_test_dataset

training_dataset=$tmp_dir/training_dataset
validation_dataset=$tmp_dir/validation_dataset
test_dataset=$tmp_dir/test_dataset


function separate_training_dataset {
	cat $1 > tmp.txt
	record_count=$( cat tmp.txt | wc -l  )

	training_count=$( printf "%.0f\n" $( echo "scale=2;"$record_count"*70/100" | bc ) )
	validating_count=$( printf "%.0f\n" $( echo "scale=2;"$record_count"*15/100" | bc ) )

	sed -n "1,$training_count"p tmp.txt >> $tmp_training_dataset
	sed -n "$[$training_count+1],$[$training_count+$validating_count]"p tmp.txt >> $tmp_validation_dataset
	sed -n "$[$training_count+$validating_count+1],$"p tmp.txt >> $tmp_test_dataset

	rm tmp.txt
}  

if [ -e $tmp_training_dataset ]
then
	rm $tmp_training_dataset
fi

if [ -e $tmp_validation_dataset ]
then
	rm $tmp_validation_dataset
fi

if [ -e $tmp_test_dataset ]
then
	rm $tmp_test_dataset
fi

shuf $input_file > $shuffled_featured_snp

for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y
do
    #for equally distributed both in chromosome and class
    grep "0$" $shuffled_featured_snp | grep "^"$i"|" | separate_training_dataset
    grep "1$" $shuffled_featured_snp | grep "^"$i"|" | separate_training_dataset
done

sort -k1 $tmp_training_dataset > $training_dataset
sort -k1 $tmp_validation_dataset > $validation_dataset
sort -k1 $tmp_test_dataset > $test_dataset



