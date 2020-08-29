#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;
use File::Temp;
use Term::ANSIColor;


my $up_extension = 2000;
my $down_extension = 2000;
my $up_bin_num = 100;
my $down_bin_num = 100;
my $middle_bin_num = 200;

sub prompt {
  print <<EOF;
  Usage: perl $0 --cov <*bismark.cov.gz> --fbed <bed> [options]
  [Options]
    --cov|c <file>   : bismark2bedGraph coverage output with the suffix of bismark.cov.gz; required
    --fbed|f <file>  : bed file of features (at least six columns with strand +/- on the 6th column); required
    --glen|g <file>  : file of chromosome lengths (two columns: chr and length); required
    --target|t <file>: a subset of genes for summary; optional 
    --upext|e <num>  : bp length upstream of each feature (e.g., gene) ($up_extension)
    --dnext|x <num>  : bp length downstream of each feature ($down_extension)
    --upbin|u <num>  : bin number of upstream regions ($up_bin_num)
    --dnbin|d <num>  : bin number of downstream regions ($down_bin_num)
    --midbin|m <num> : bin number of feature regions, or middle regions ($middle_bin_num)
    --prefix|p <str> : prefix for output; the input filename with removing bismark.cov.* is used by default
	--rerun|r        : if specified and existed intermediated files found, use existed one; off by default
    --help           : help information
EOF
exit;
}

my ($methyl_cov, $feature_bed, $prefix, $genome_len_file);
my ($target, $rerun, $help);
&GetOptions("cov|c=s"    => \$methyl_cov,
			"fbed|f=s"   => \$feature_bed,
			"glen|g=s"   => \$genome_len_file,
			"upext|e=i"  => \$up_extension,
			"dnext|x=i"  => \$down_extension,
			"upbin|u=i"  => \$up_bin_num,
			"dnbin|d=i"  => \$down_bin_num,
			"midbin|m=i" => \$middle_bin_num,
			"prefix|p=s" => \$prefix,
            "target|t=s" => \$target,
			"rerun|r"    => \$rerun,
			"help|h"     => \$help) || &prompt;

&prompt if $help;

if (!defined $methyl_cov or !defined $feature_bed or !defined $genome_len_file) {
	print STDERR color('red'); 
	print STDERR "--cov, --fbed, and --glen are required\n";
	print STDERR color('reset'); 
	&prompt;
}

if (!defined $prefix) {
	$prefix = $methyl_cov;
	$prefix =~ s/.*\///g;
	$prefix =~ s/.bismark.cov.*$//g;
}

# final output
my $bin_methyl = $prefix.".bin.methyl";

# intermediate outputs:
my $methyl_bed = $prefix.".1.methyl.bed";
my $feature_bed2 = $prefix.".2.target.feature.bed";
my $feature_bed_extension = $prefix.".2.feature.bed";
my $feature_methyl = $prefix.".3.feature.methyl";

##################################################################
# reformat methylation data
##################################################################
if ( !$rerun or ($rerun and !-f $feature_methyl)) {
	`gunzip -d -c $methyl_cov | awk '{ print \$1"\t"\$2-1"\t"\$3"\t"\$5"\t"\$6 }' > $methyl_bed`;
}
##################################################################
# feature bed
##################################################################
if ( !$rerun or ($rerun and !-f $feature_methyl)) {
	if (defined $target) {
		my %target;
		open(TARGET, "<", $target) || die;
		while (<TARGET>) {
			chomp;
			$target{$_}++;
		}
		close TARGET;
		
		open(FBED2, ">", $feature_bed2) || die;
		open(FEATURE, "<", $feature_bed) || die;
		while (<FEATURE>) {
			chomp;
			my @line = split(/\t/, $_);
			my $feature_name = $line[3];
			$feature_name =~ s/_T.*//g;
			if (exists $target{$feature_name}) {
				print FBED2 "$_\n";
			}
		}
		close FEATURE;
		close FBED2;
		`bedtools slop -i $feature_bed2 -g $genome_len_file -l $up_extension -r $down_extension -s > $feature_bed_extension`;
	} else {
		`bedtools slop -i $feature_bed -g $genome_len_file -l $up_extension -r $down_extension -s > $feature_bed_extension`;
	}
}
##################################################################
# combine methylation data and genic information
##################################################################
# 3	144941	144941	5	0	144932	161853	Zm00056a017544_T001	-
if ( !$rerun or ($rerun and !-f $feature_methyl)) {
	`bedtools intersect -a $methyl_bed -b $feature_bed_extension -wo | cut  -f 1-5,7,8,9,11 > $feature_methyl`;
}
##################################################################
# bin
##################################################################
my %bin_methyl;
my %region;
open(IN, $feature_methyl) || die;
while (<IN>) {
	chomp;
	my $bin;
	my @line = split(/\t/, $_);
	my $site = $line[2]; # 1-based
	my $strand = $line[8];
	my $n_methyl = $line[3];
	my $n_unmethyl = $line[4];
	my $n_depth = $n_methyl + $n_unmethyl;
	# start and end and determine region: up, down, gene
	my ($gstart, $gend, $location);
	if ($strand eq "+") {
		$gstart = $line[5] + $up_extension + 1; # adjust to 1-based
		$gend = $line[6] - $down_extension;
		if ($site >= $gstart and $site <= $gend) {
			$location = "body";
		} elsif ($site < $gstart) {
			$location = "up";
		} elsif ($site > $gend) {
			$location = "down";
		}
	} else {
		$gstart = $line[6] - $up_extension;
		$gend = $line[5] + 1 + $down_extension;
		if ($site >= $gend and $site <= $gstart) {
			$location = "body";
		} elsif ($site > $gstart) {
			$location = "up";
		} elsif ($site < $gend) {
			$location = "down";
		}
	}

	# up, down, gene
	if ($location eq "up") { # upstream
		$bin = $up_bin_num - int((abs($site - $gstart) - 1) / $up_extension * $up_bin_num);
		my $up_1 = int($up_extension / $up_bin_num) * ($bin - 1) + 1;
		my $up_2 = int($up_extension / $up_bin_num) * $bin;
		$region{$bin} = "up\t$up_1\t$up_2";
	} elsif ($location eq "down") { # downstream
		$bin = $middle_bin_num + $up_bin_num + 1 + int((abs($site - $gend) - 1) / $down_extension * $down_bin_num);
		my $dn_1 = int($down_extension / $down_bin_num) * ($bin - 1) + 1;
		my $dn_2 = int($down_extension / $down_bin_num) * $bin;
		$region{$bin} = "down\t$dn_1\t$dn_2";
	} elsif ($location eq "body") { # gene
		$bin = $up_bin_num + 1 + int(abs($site - $gstart) / abs($gend - $gstart + 1) * $middle_bin_num);
		my $body_1 = $bin - 1;
		my $body_2 = $bin;
		$region{$bin} = "body\t$body_1\t$body_2";
	} else {
		print STDERR "no region was confirmed\n";
	}
	
	# add to hash
	my $methyl_perc = $n_methyl / $n_depth;
	$bin_methyl{$bin}{count}++;
	$bin_methyl{$bin}{sum} += $methyl_perc;
}
close IN;

##################################################################
#output
##################################################################
open(OUT, ">", $bin_methyl) || die;
foreach my $ebin (sort {$a <=> $b} keys %bin_methyl) {
	my $count = $bin_methyl{$ebin}{count};
	my $methyl_perc_sum = $bin_methyl{$ebin}{sum};
	my $methyl_per_mean = $methyl_perc_sum / $count;
	my $part = $region{$ebin};
	print OUT "$ebin\t$part\t$methyl_per_mean\n";
}
close OUT;

##################################################################
# clean-up
##################################################################
`rm $methyl_bed`;
`rm $feature_bed_extension`;
#`rm $feature_methyl`;
if (defined $target) {
	`rm $feature_bed2`;
}
