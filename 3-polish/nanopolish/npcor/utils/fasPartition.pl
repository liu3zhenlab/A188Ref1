#!/usr/bin/perl -w
#
# ====================================================================================================
# File: fastaPartition.pl
# Author: Sanzhen Liu
# Date: 4/8/2019
# ====================================================================================================

use strict;
use warnings;
use Getopt::Long;

my $seq_name;
my $size=0;
my $seqCount=0;
my ($fas, $max, $buffer, $help);

sub prompt {
	print <<EOF;
	Usage: perl fastaPartition.pl <Input Fasta File>
	--fas:  single sequence fasta file, required
	--max:  max length for a partitionated sequence (bp) (default=500000)
	--buffer: the percentage to be longer than the max (default=10; 10%)
	--help
EOF
exit;
}
# read the parameters:
&GetOptions("fas=s" => \$fas, "max=i" => \$max, "buffer=i" => \$buffer, "help" => \$help) || &prompt;

if (! defined $fas) {
	print STDERR "FASTA file is required\n";
	&prompt;
}

$max = 500000 if (! defined $max);
$buffer = 10 if (! defined $buffer);
&prompt if ($help);

# Read a sequence
open(IN, $fas) || die;
while (<IN>) {
   $_ =~ s/\R//g;
   chomp;
   if (/^>(\S+)/) {
      $seq_name = $1;
	  $seqCount++;
   } else {
      $_ =~ s/\s//g;
	  $size += length($_);
   }
}
close IN;

if ($seqCount != 1) {
	print STDERR "FASTA must only contain 1 sequence\n";
	&prompt;
}

my $numSubseq = &partition($size, $max, $buffer);

for (my $i=0; $i<$numSubseq; $i++) {
	my $start = 1 + $i * $max;
	my $end = $start + $max - 1;
	if ($i == $numSubseq - 1) {
		$end = $size
	}
	#my $order = $i + 1;
	print "$seq_name\:$start\-$end\n";
}

sub partition {
# determine # parts to be divided
	my ($insize, $maxlen, $buffer2add) = @_;
	my $parts = int($insize / $maxlen);
	if ($parts == 0 or ($insize - $maxlen * $parts) > $maxlen * $buffer2add / 100) {
		$parts++;
	} 
	return $parts;
} # End of sub partition

