#!/usr/bin/env perl
#
# Author: jessada@kth.se
#

use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

my $variation_idx   = 1;
my $genomic_acc_idx = 11;
my $strand_idx      = 12;
my $codon_idx       = 13;
my $genomic_coord   = 14;

my %reverse_nucleotide = ('A'=>'T', 'C'=>'G', 'G'=>'C', 'T'=>'A');
my %codon2protein = ('TTT'=>'F', 'TTC'=>'F', 'TTA'=>'L', 'TTG'=>'L', 
					 'TCT'=>'S', 'TCC'=>'S', 'TCA'=>'S', 'TCG'=>'S', 
					 'TAT'=>'Y', 'TAC'=>'Y', 'TAA'=>'Stop', 'TAG'=>'Stop',  
					 'TGT'=>'C', 'TGC'=>'C', 'TGA'=>'Stop', 'TGG'=>'W',  
					 'CTT'=>'L', 'CTC'=>'L', 'CTA'=>'L', 'CTG'=>'L',  
					 'CCT'=>'P', 'CCC'=>'P', 'CCA'=>'P', 'CCG'=>'P',   
					 'CAT'=>'H', 'CAC'=>'H', 'CAA'=>'Q', 'CAG'=>'Q',    
					 'CGT'=>'R', 'CGC'=>'R', 'CGA'=>'R', 'CGG'=>'R',     
					 'ATT'=>'I', 'ATC'=>'I', 'ATA'=>'I', 'ATG'=>'M',   
					 'ACT'=>'T', 'ACC'=>'T', 'ACA'=>'T', 'ACG'=>'T',   
					 'AAT'=>'N', 'AAC'=>'N', 'AAA'=>'K', 'AAG'=>'K',   
					 'AGT'=>'S', 'AGC'=>'S', 'AGA'=>'R', 'AGG'=>'R',   
					 'GTT'=>'V', 'GTC'=>'V', 'GTA'=>'V', 'GTG'=>'V',   
					 'GCT'=>'A', 'GCC'=>'A', 'GCA'=>'A', 'GCG'=>'A',    
					 'GAT'=>'D', 'GAC'=>'D', 'GAA'=>'E', 'GAG'=>'E',    
					 'GGT'=>'G', 'GGC'=>'G', 'GGA'=>'G', 'GGG'=>'G',    
					);
					
#foreach my $first_NT (('T', 'C', 'A', 'G')) {
#	foreach my $second_NT (('T', 'C', 'A', 'G')) {
#		foreach my $third_NT (('T', 'C', 'A', 'G')) {
#			my $codon = $first_NT.$second_NT.$third_NT;
#			print "$codon : $codon2protein{$codon}\n";
#		}
#	}
#}
##print %reverse_nucleotide, "\n";
#print $reverse_nucleotide{'A'}, "\n";
#print $reverse_nucleotide{'C'}, "\n";
#print $reverse_nucleotide{'G'}, "\n";
#print $reverse_nucleotide{'T'}, "\n";

#validate references
my @lines;
while( my $line = <>)  {
	my @fields = split(/\t/, $line);
	my $codon  = $fields[$codon_idx];
	my $strand = parse_strand($fields[$strand_idx]);

	my ($ref_protein, $mut_protein) = parse_protein($fields[$variation_idx]);

	if ($strand eq '+') {
		if ($ref_protein ne $codon2protein{$codon}) {
			die "strand+ : something are incorrect at $line\n";
		}
	} else {
		if ($ref_protein ne $codon2protein{compliment_codon($codon)}) {
			die "strand- : something are incorrect at $line\n";
		}
	}

    push @lines, $line;
}

#parsing
foreach my $line (@lines) {
	chomp($line);
	my @fields = split(/\t/, $line);
	my $codon  = $fields[$codon_idx];
	my $strand = parse_strand($fields[$strand_idx]);
	my $NT_positions = $fields[$genomic_coord];
	my ($reference_protein, $mutated_protein) = parse_protein($fields[$variation_idx]);
	my @positions    = split(/, /, $NT_positions);
	my $chromosome   = parse_chromosome($fields[$genomic_acc_idx]);
	if ($chromosome eq '23') { $chromosome = 'X'; }
	if ($chromosome eq '24') { $chromosome = 'Y'; }
	 
#	print "**************************************************************************************\n";
#	print "$fields[$variation_idx]\t$fields[$genomic_acc_idx]\t$fields[$strand_idx]\t$fields[$codon_idx]\t$fields[$genomic_coord]\n";
#
#	print $chromosome, "\n";
#	
#	print "ref_protein : $reference_protein\t\tmut_protein : $mutated_protein\n";
#
#	print "@positions\n";
	for (my $index = 0; $index < 3; $index++) {
		foreach my $NT (('T', 'C', 'A', 'G')) {
			if (substr($codon, $index, 1) eq $NT) { next;}
			my $tmp_codon = $codon;
			substr($tmp_codon, $index, 1, $NT);
			my $SNP_key = (looks_like_number($chromosome))? sprintf("%02d", $chromosome):$chromosome;
			$SNP_key    .= "|".sprintf("%012s",$positions[$index])."|".$NT;
			if ($strand eq '+') {
				if ($codon2protein{$tmp_codon} eq $mutated_protein) {
					#print "$tmp_codon : $mutated_protein\t\tpostion : $positions[$index]\t\tfrom ", substr($codon, $index, 1), " to ", substr($tmp_codon, $index, 1), "\n";
					print "$SNP_key\t$chromosome\t$positions[$index]\t$positions[$index]\t", substr($codon, $index, 1), "\t", $NT, "\tcomment : $fields[$variation_idx] | $fields[$genomic_acc_idx] | $fields[$strand_idx] | $fields[$codon_idx] |  $fields[$genomic_coord]\n";
				}
			} else {
				if ($codon2protein{compliment_codon($tmp_codon)} eq $mutated_protein) {
					#print compliment_codon($tmp_codon), " : $mutated_protein\t\tpostion : $positions[$index]\t\tfrom ", substr($codon, $index, 1), " to ", substr($tmp_codon, $index, 1), "\n";
					print "$SNP_key\t$chromosome\t$positions[$index]\t$positions[$index]\t", substr($codon, $index, 1), "\t", $NT, "\tcomment : $fields[$variation_idx] | $fields[$genomic_acc_idx] | $fields[$strand_idx] | $fields[$codon_idx] |  $fields[$genomic_coord]\n";
				}
			}
		}
	}
}

sub parse_protein
{
	my ($protein_variation) = @_;

	my ($first_part, $second_part)  = split(/\./, $protein_variation);
	my ($ref_protein, $mut_protein) = split(/\d+/, $second_part);
	
	return ($ref_protein, $mut_protein);
}

sub parse_chromosome
{
	my ($genomic_accession) = @_;
	
	my ($first_part, $second_part) = split(/\./, $genomic_accession);
	return substr($first_part, 7) + 0;
}

sub parse_strand
{
	my ($txt_strand) = @_;
	
	return substr($txt_strand, 0, 1);
}

sub reverse_compliment_codon
{
	my ($codon) = @_;
	my $out = '';
	
	for (my $key = length($codon)-1; $key >= 0; $key--) {
		$out .= $reverse_nucleotide{substr($codon, $key, 1)};
	}
	return $out;
}

sub reverse_codon
{
	my ($codon) = @_;
	my $out = '';
	
	for (my $key = length($codon)-1; $key >= 0 ; $key--) {
		$out .= substr($codon, $key, 1);
	}
	return $out;
}

sub compliment_codon
{
	my ($codon) = @_;
	my $out = '';
	
	for (my $key = 0; $key < length($codon); $key++) {
		$out .= $reverse_nucleotide{substr($codon, $key, 1)};
	}
	return $out;
}
