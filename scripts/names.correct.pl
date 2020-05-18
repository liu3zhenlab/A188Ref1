#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;

sub prompt {
	print <<EOF;
	Usage: perl $0 --gff <gff> --sub [id or name]
	- to change "Name" to "ID" in Maker gff3
	[Options]
	--gff <gff file>: gff filename
	--sub <str>     : substitute with "id" or "name" (id)
	--help
EOF
exit;
}

my ($gff, $help);
my $sub = "id";
&GetOptions("gff|g=s" => \$gff,
			"sub|s=s" => \$sub,
			"help|h"  => \$help);

&prompt if ($help or !defined $gff);
if ($sub ne "name" and $sub ne "id") {
	print STDERR "ERROR: two options only for --sub: name or id\n";
	exit;
}

# gff
my %link; # hash to link ID and Name 
open(GFF, $gff) || die;
while (<GFF>) {
	chomp;
	my @line = split(/\t/, $_);
	if (/ID=([^\;]+)\;.*Name=([^\;]+)/) {
		my $info = $line[8];
		my $id = $1;
		my $name = $2;
		if ($id ne $name) {
			if ($sub eq "id") {
				$info =~ s/$name/$id/g;
			} elsif ($sub eq "name") {
				$info =~ s/$id/$name/g;
			}
			$line[8] = $info;
		}
	}
	print join("\t", @line);
	print "\n";
}
close GFF;

