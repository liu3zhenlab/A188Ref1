#!/usr/bin/perl -w

# File: split.fasta.pl
# Author: Sanzhen Liu
# Date: 6/23/2012 

use strict;
use warnings;
use Getopt::Long;

my ($num, $prefix, $sizeincrease, $sizedecrease);
my ($exclude, $nlt, $help);
my $result = &GetOptions("num|i=i"    => \$num,
                        "prefix|p=s"  => \$prefix,
						"increase|u"  => \$sizeincrease,
						"decrease|d"  => \$sizedecrease,
						"nlt|n=i"     => \$nlt,
						"exclude|e=s" => \$exclude,
						"help|h"      => \$help
);

# print help information if errors occur:
if ($help or !@ARGV) {
	&errINF;
	exit;
}

$num = 1 if (!defined $num or (defined $num and $num<1));

if (!defined $prefix) {
	$prefix = "split";
} # End of if statement

my %excluded; # hash to contain the list of names of excluded sequneces
if (defined $exclude) {
	open(EXCLUDE, "<", $exclude) || die;
	while (<EXCLUDE>) {
		chomp;
		$excluded{$_}++;
	}
	close EXCLUDE;
}

### count the total sequences:
my $count = 0;
my ($seqname, $seq, $size, %size, %seqhash, @seq_list);
open(IN, $ARGV[0]) || die;
while (<IN>) {
	chomp;
	if (/^>(.+)/) {
		if (defined $seqname) {
			if (! exists $excluded{$seqname}) {
				$seqhash{$seqname} = $seq;
				$size{$seqname} = $size;
				push(@seq_list, $seqname);
			}
		}
		$seqname = $1;
		$seq = '';
		$size = 0;
		$count++;
	} else {
		$seq .= $_;
		$size += length($_);
	}
}

# last sequence
if (! exists $excluded{$seqname}) {
	$seqhash{$seqname} = $seq;
	$size{$seqname} = $size;
	push(@seq_list, $seqname);
}
close IN;

# set size descreasing if --nlt is specified
if (defined $nlt) {
	$sizedecrease = 1;
}

# sorting by lengths:
if ($sizedecrease) {
	@seq_list = ();
	foreach (sort {$size{$b} <=> $size{$a}} keys %size) {
		push(@seq_list, $_);
	}
} elsif ($sizeincrease) {
	@seq_list = ();
	foreach (sort {$size{$a} <=> $size{$b}} keys %size) {
		push(@seq_list, $_);
	}
}

print join (";", @seq_list);

### split:
my $out_count = 0;
my $file_count = 1;
my $file_len = 0;
open(OUT,">$prefix.$file_count") || die;
foreach (@seq_list) {
	if (defined $nlt) {
		my $cur_seq_len = $size{$_};
		if ($file_len > $nlt) {
			$file_len = 0;
			close OUT;
			$file_count++;
			open(OUT,">$prefix.$file_count") || die;
		}
		$file_len += $cur_seq_len;
	} else {
		if ($out_count >= $num) {
			$out_count = 0;
			close OUT;	
			$file_count++;
			open(OUT,">$prefix.$file_count") || die;
		}
		$out_count++;
	}
	print OUT ">$_\n$seqhash{$_}\n";
}

sub errINF {
	print <<EOF;
Usage: perl split.fasta.pl <input> [Options]
	Options
	--num|i <num>:  number of sequences in each file (1)
	--nlt <bp>:     each file is not less than the input <bp> length; override --num
	                sequences will be sorted by descreasing order and output sequences in order.
					If output sequence(s) are less than <bp>, the next sequence is output to the same file
	--prefix <str>: file prefix name (split)
	--increase:     output sequences from small to large
	--decrease:     output sequences from large to small, override --size-increase if both are specified
	--exclude:      list of names for sequences to be excluded
	--help:         help information
EOF
	exit;
}

