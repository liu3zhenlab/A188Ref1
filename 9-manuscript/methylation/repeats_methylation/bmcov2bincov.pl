#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;
use File::Temp;
use Term::ANSIColor;

sub prompt {
  print <<EOF;
  Usage: perl $0 --cov <*bismark.cov.gz> [options]
  [Options]
    --cov|c <file>  : bismark2bedGraph coverage output with the suffix of bismark.cov.gz; required
    --glen|g <file> : file of chromosome lengths (two columns: chr and length); optional
    --win|w <num>   : window bp length (100)
    --mins|s <num>  : minimum sites per window (2)
    --mind|d <num>  : minimum depth per window (10)
    --maxd|m <num>  : maximum depth per window (1000000000)
    --prefix|p <str>: prefix for output; the input filename with removing bismark.cov.* is used by default
    --help          : help information
EOF
exit;
}

my $win = 100;
my $min_site = 1;
my $min_depth = 3;
my $max_depth = 1000000000;
my ($cov, $prefix, $genome_len_file, $help);
&GetOptions("cov|c=s"    => \$cov,
            "win|w=i"    => \$win,
			"glen|g=s"   => \$genome_len_file,
			"mins|s=i"   => \$min_site,
			"mind|d=i"   => \$min_depth,
			"maxd|m=i"   => \$max_depth,
			"prefix|p=s" => \$prefix,
			"help|h"     => \$help) || &prompt;


&prompt if $help;

if (!defined $cov) {
	print STDERR "--cov is required\n";
	&prompt;
}

if (!defined $prefix) {
	$prefix = $cov;
	$prefix =~ s/.*\///g;
	$prefix =~ s/.bismark.cov.*$//g;
}

# genome lengths if specified
my %genome_lens;
if (defined $genome_len_file) {
	open(LEN, "<", $genome_len_file) || die;
	while (<LEN>) {
		chomp;
		my ($chr, $len) = split(/\t/, $_);
		if ($len =~ /^\d+$/) { # integer?
			$genome_lens{$chr} = $len;
		}
	}
}

# input format
# 3(chr) 12998 (start) 12998(end) 100(methyl%) 13(#methyl) 0(#unmethyl)

my $cov_file = $cov;
if ($cov =~ /gz$/) {
	$cov_file = File::Temp->new(SUFFIX => '.cov');
	`gunzip -d -c $cov > $cov_file`;
	&print_progress("unzip $cov");
}

my $win_cov = File::Temp->new(SUFFIX => '.wincov');
open(WIN, ">", $win_cov) || die; # temp output
open(COV, "<", $cov_file) || die;
while (<COV>) {
	chomp;
	my @line = split(/\t/, $_);
	my $chr = $line[0];
	my $win_num = int(($line[1] - 1)/$win);
	my $win_start = $win * $win_num + 1;
	my $win_end = $win * ($win_num + 1);
	# if the end is larger than the chr length, replace it with the chr length
	if (defined $genome_len_file and exists $genome_lens{$chr}) {
		if ($win_end > $genome_lens{$chr}) {
			$win_end = $genome_lens{$chr};
		}
	}
	my $methyl = $line[4];
	my $unmethyl = $line[5];
	my $methyl_perc = 0;
	if (($methyl + $unmethyl) > 0) {
		$methyl_perc = $methyl / ($methyl + $unmethyl);
	}
	print WIN "$chr\t$win_start\t$win_end\t$methyl\t$unmethyl\t$methyl_perc\n";
}
close COV;
close WIN;
&print_progress("convert sites to windows");

# count, filter, and output
my $output_file = $prefix.".".$win."bp.methyl.depth";
`bedtools groupby -g 1,2,3 -c 4,5,5,6 -o sum,sum,count,mean -i $win_cov | \
 awk '(\$4+\$5) >= $min_depth && (\$4+\$5) <= $max_depth && \$6 >= $min_site' > $output_file`;
&print_progress("output $output_file");

print STDERR color('red');
print STDERR "\n[filtering criteria]:\n";
print STDERR color('reset');
print STDERR " 1. win=$win bp (window size)\n";
print STDERR " 2. mins=$min_site (minimum sites with non-zero coverage per window)\n";
print STDERR " 2. mind=$min_depth (minimum reads per window)\n";
print STDERR " 2. maxd=$max_depth (maximum reads per window)\n";
print STDERR color('red');
print STDERR "\[output format\]:\n";
print STDERR color('reset');
print STDERR "chr start(1-based) end(1-based) num_methyl num_unmethyl num_C_sites mean_methyl\n";


##################################
# module 1: progress report
##################################
sub print_progress {
	my $note = shift;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$year += 1900;
	my $cur_time = "\[$mon\/$mday\/$year\ $hour\:$min\:$sec\]";
	print STDERR color('red');
	print STDERR $cur_time;
	print STDERR color('reset');
	print STDERR " $note\n";
	#return($cur_time);
}

