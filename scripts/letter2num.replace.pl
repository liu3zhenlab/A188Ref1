#!/usr/bin/perl -w
use strict;
use warnings;

my @alphabet = ("A".."Z");
my %alpnum;
for (my $i=1; $i<=26; $i++) {
	my $chri = $i;
	if ($i < 10) {
		$chri = "0".$i;
	}
	$alpnum{$alphabet[$i - 1]} = $chri;
}

open(IN, $ARGV[0]) || die;
while (<IN>) {
	chomp;
	if (/\-R([A-Z])$/) {
		my $ori = "\-R".$1;
		my $chto = "_T0".$alpnum{$1};
		$_ =~ s/$ori/$chto/;
	}
	print "$_\n";
}
close IN;


