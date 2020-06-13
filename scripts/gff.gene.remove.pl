#!/usr/bin/perl -w
# Sanzhen Liu
# 6/12/2020
# to remove genes from a gff (maker format)

use strict;
use warnings;

my %rmlist;
open(LIST, $ARGV[1]) || die;
while(<LIST>) {
	chomp;
	$rmlist{$_}++;
}
close LIST;

open(GFF, "<", $ARGV[0]) || die;
while (<GFF>) {
	chomp;
	#my @line = split(/\t/, $_);
	if ($_ =~ /\tID=(.+?)[\:\;]/) { # ? to parsimoniously find the match
		my $id = $1;
		$id =~ s/_T.*//g;
		if (! exists $rmlist{$id}) {
			print "$_\n";
		} else {
			print STDERR "removed\t$_\n"; # print removed set to STDERR
		}
	} else {
		print "$_\n"; # include comments
	}
}

