#!/usr/bin/env perl
#
# Author: jessada@kth.se
#

use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
use Log::Log4perl; 

my $conf = q(
    log4perl.category.mylog         = ERROR, Screen

    log4perl.appender.Screen        = Log::Log4perl::Appender::Screen
    log4perl.appender.Screen.stderr = 0
    log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout
);

Log::Log4perl::init( \$conf );

my $log = Log::Log4perl::get_logger("mylog");

my $transcript_ID_idx  = 1;
my $chromosome_id_idx    = 2;
my $strand_idx           = 3;
my $exons_start_idx      = 9;
my $exons_end_idx        = 10;
my $gene_symbol_idx      = 12;

#load and parse refGene.txt
my %transcript_hash;
open my $refGene_fh, "<", $ARGV[0] or die $!;
while( my $line = <$refGene_fh>)  {
	chomp($line);
	my @fields           = split(/\t/, $line);
	my @exons_start      = sort {$a <=> $b} split(/,/, $fields[$exons_start_idx]);
	my @exons_end        = sort {$a <=> $b} split(/,/, $fields[$exons_end_idx]);
	my $sum_NT_count_fwd = 0;
	my $sum_NT_count_bwd = 0;
	if ($#exons_start != $#exons_end) {
		die "something are incorrect at $line";
	}
	
	my @exons;
	for (my $exon_idx = 0; $exon_idx <= $#exons_start; $exon_idx++)
	{
		$sum_NT_count_fwd += $exons_end[$exon_idx]-$exons_start[$exon_idx];

		my $exon_ref = {};
		$exon_ref->{exon_start}       = $exons_start[$exon_idx]+0;
		$exon_ref->{exon_end}         = $exons_end[$exon_idx]+0;
		$exon_ref->{NT_count}         = $exons_end[$exon_idx]-$exons_start[$exon_idx];
		$exon_ref->{sum_NT_count_fwd} = $sum_NT_count_fwd;
		push @exons, $exon_ref;
	}
	for (my $exon_idx = $#exons_start; $exon_idx >= 0; $exon_idx--)
	{
		$sum_NT_count_bwd += $exons_end[$exon_idx]-$exons_start[$exon_idx];
		$exons[$exon_idx]->{sum_NT_count_bwd} = $sum_NT_count_bwd;
	}

	my $transcript_ref = {};
	$transcript_ref->{chromosome}   = substr($fields[$chromosome_id_idx], 3);
	$transcript_ref->{strand}       = $fields[$strand_idx];
	$transcript_ref->{gene_symbol}  = $fields[$gene_symbol_idx];
	$transcript_ref->{exons}        = \@exons;
	$transcript_hash{$fields[$transcript_ID_idx]} = $transcript_ref;
	}
close $refGene_fh;


##dump location table
$log->debug("*********************************************************** dump location table ******************************************************************");
for my $key (keys %transcript_hash)
{
		$log->debug("**************************************************************************************************************************************************");
		$log->debug("$key\t$transcript_hash{$key}->{chromosome}\t$transcript_hash{$key}->{strand}\t$transcript_hash{$key}->{gene_symbol}");
	foreach my $exon (@{$transcript_hash{$key}->{exons}})
	{
		$log->debug("$exon->{exon_start}\t$exon->{exon_end}\t$exon->{NT_count}\t$exon->{sum_NT_count_fwd}\t$exon->{sum_NT_count_bwd}");
	}
}
$log->debug("********************************************************* end dump location table ****************************************************************\n\n\n");

my $contig_acc_idx               = 5;
my $start_position_on_contig_idx = 6;
my $end_position_on_contig_idx   = 7;
my $reading_frame_idx          = 8;
my $ref_allele_idx             = 11;
my $ref_codon_idx              = 12;
my $missense_allele_idx        = 9;
my $missense_codon_idx         = 10;

$log->debug("****************************************************************** P A R S I N G *****************************************************************");
my %SNP_hash;
while( my $line = <STDIN>)  {
	chomp($line);
	my @fields          = split(/\t/, $line);
	my ($transcript_ID, $transcript_version) = split(/\./, $fields[$contig_acc_idx]);
	if ( !exists($transcript_hash{$transcript_ID}))
	{
		next;
	}
	my $chromosome      = get_chromosome($fields[$contig_acc_idx]);

	$log->debug("**************************************************************************************************************************************************");
	$log->debug("transcript ID : $transcript_ID\tversion : $transcript_version\tchromosome : $chromosome\treading frame : $fields[$reading_frame_idx]");
	$log->debug("transcript position : $fields[$start_position_on_contig_idx] - $fields[$end_position_on_contig_idx]");
	$log->debug("reference : $fields[$ref_allele_idx], $fields[$ref_codon_idx]\tmissense : $fields[$missense_allele_idx], $fields[$missense_codon_idx]");

	my ($start_position, $end_position) = get_position($transcript_ID, $fields[$start_position_on_contig_idx], $fields[$end_position_on_contig_idx]);
	if (!defined($start_position) || !defined($end_position)) { next; }
	
	$log->debug("chromosome position : $start_position - $end_position");

	my $ref_allele      = $fields[$ref_allele_idx];
	my $missense_allele = $fields[$missense_allele_idx];
	if (defined($start_position) && defined($end_position))
	{
		my $SNP_key = (looks_like_number($chromosome))? sprintf("%02d", $chromosome):$chromosome;
		$SNP_key   .= "|".sprintf("%012s",$start_position)."|".$missense_allele;
		
		if ( !exists($SNP_hash{$SNP_key}))
		{
			$SNP_hash{$SNP_key} = {};
		} 
		elsif ($transcript_version <= $SNP_hash{$SNP_key}->{transcript_version})
		{
			next;
		} 
		$SNP_hash{$SNP_key}->{transcript_ID} = $transcript_ID;
		$SNP_hash{$SNP_key}->{transcript_version} = $transcript_version;
		$SNP_hash{$SNP_key}->{chromosome} = $chromosome;
		$SNP_hash{$SNP_key}->{start_position} = $start_position;
		$SNP_hash{$SNP_key}->{end_position} = $end_position;
		$SNP_hash{$SNP_key}->{ref_allele} = $ref_allele;
		$SNP_hash{$SNP_key}->{missense_allele} = $missense_allele;
		$SNP_hash{$SNP_key}->{comment} = "contig_acc_ver : $fields[$contig_acc_idx] ; postion : $fields[$start_position_on_contig_idx] - $fields[$end_position_on_contig_idx]";
	} 
}
$log->debug("************************************************************ E N D  O F  P A R S I N G ***********************************************************\n\n\n");

for my $key (keys %SNP_hash)
{
	my $SNP = $SNP_hash{$key};
	print "$key\t$SNP->{chromosome}\t$SNP->{start_position	}\t$SNP->{end_position}\t$SNP->{ref_allele}\t$SNP->{missense_allele}\t$SNP->{comment}\n";
#	print "$key\t$SNP_hash{$key}->{chromosome}\t$start_position\t$end_position\t$ref_allele\t$missense_allele\tcomment : training data\n";
}

sub get_chromosome
{
	my ($contig_accession) = @_;

	my ($transcript_ID, $second_part) = split(/\./, $contig_accession);
	return $transcript_hash{$transcript_ID}->{chromosome};
}

sub get_position
{
	my ($transcript_ID, $start_position_on_contig, $end_position_on_contig) = @_;

	if (! $transcript_hash{$transcript_ID}->{exons}) 
	{
		return (undef, undef);
	}
	my @exons = @{$transcript_hash{$transcript_ID}->{exons}};
	if ($transcript_hash{$transcript_ID}->{strand} eq '+')
	{
		foreach my $exon (@exons)
		{
			if ($start_position_on_contig < $exon->{sum_NT_count_fwd})
			{
				$log->debug("$exon->{exon_start}\t$exon->{exon_end}\t$exon->{NT_count}\t$exon->{sum_NT_count_fwd}");
				return ($exon->{exon_start}+$start_position_on_contig+1-($exon->{sum_NT_count_fwd}-$exon->{NT_count}), 
	                    $exon->{exon_start}+$end_position_on_contig+1-($exon->{sum_NT_count_fwd}-$exon->{NT_count}));
			}	
		}
	}
	else
	{
		for (my $exon_idx = $#exons; $exon_idx >= 0; $exon_idx--)
		{
			my $exon = $exons[$exon_idx];
			if ($start_position_on_contig < $exon->{sum_NT_count_bwd})
			{
				$log->debug("$exon->{exon_start}\t$exon->{exon_end}\t$exon->{NT_count}\t$exon->{sum_NT_count_fwd}\t$exon->{sum_NT_count_bwd}");
				return ($exon->{exon_end}-($start_position_on_contig-($exon->{sum_NT_count_bwd}-$exon->{NT_count})),
				        $exon->{exon_end}-($end_position_on_contig-($exon->{sum_NT_count_bwd}-$exon->{NT_count})));
			}
		}
	}
	return (undef, undef);
}