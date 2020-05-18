#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;

my $version = "0.1";

sub prompt {
  print <<EOF;
  Usage: perl gff.agp.liftover.pl --gff <gff> --map <agp>
    --gff <gff>: gff agp file
    --map <agp>: map agp file
    --version  : version
    --help     : help informaton
EOF
exit;
}

my ($gff, $map, $ver, $help);
&GetOptions("gff=s" => \$gff, "map=s" => \$map, "version" => \$ver, "help" => \$help);

if ($ver) {
	print "version=$version\n";
	exit;
}
&prompt if $help or !defined $gff or !defined $map;

# map agp:
my (%map, %component); 
open(MAP, "<", $map) || die;
while(<MAP>) {
	chomp;
	if (!/^#/) {
		my @line = split(/\t/, $_);
		if ($line[4] ne "N" and $line[4] ne "U") {
			my ($ref, $ref_start, $ref_end) = @line[0..2];
			my ($component, $component_start, $component_end)= @line[5..7];
			my $component_strand = $line[8];
			$component{$component}{$component_start}{$component_strand} = $component_end;
			my @refinfo = ($ref, $ref_start);
			if ($component_strand eq "+") {
				$map{$component}{$component_start} = \@refinfo;
			} elsif ($component_strand eq "-") {
				$map{$component}{$component_end} = \@refinfo;
			}
		}
	}
}
close MAP;

# gff
open(IN, "<", $gff) ||die;
while (<IN>) {
	chomp;
	if (!/^#/) {
		my @line = split(/\t/, $_);
		my $ctg = $line[0];
		if (exists $component{$ctg}) {
			my %ctg_start_end = %{$component{$ctg}}; # ctg start end from agp
			my $start = $line[3];
			my $end = $line[4];
			my $strand = $line[6];
			my ($newstart, $newend, $newstrand);
			
			# determine contigs that the entry belongs
			my ($ctg_start, $ctg_end, $ctg_key, $ctg_strand);
			foreach my $estart (keys %ctg_start_end) {	
				my ($eend, $ekey, $estrand);
				if (exists $ctg_start_end{$estart}{"+"}) {
					$eend = $ctg_start_end{$estart}{"+"};
					$ekey = $estart;
					$estrand = "+";
				} else {
					$eend = $ctg_start_end{$estart}{"-"};
					$ekey = $eend;
					$estrand = "-";
				}

				if ($start >= $estart and $end <= $eend) {
					$ctg_start = $estart; # contig start on ref
					$ctg_end = $eend; # contig end on ref
					$ctg_key = $ekey; # which end corresponding to ref start
					$ctg_strand = $estrand; # contig orientation relative to ref
				}
			}

			if (!defined $ctg_start or !defined $ctg_end or !defined $ctg_key or !defined $ctg_strand) {
				print STDERR "ERROR: $ctg is out of range or NOT found in the agp file\n";
				exit;
			}
			
			#print "--$ctg_start\t$ctg_end\t$ctg_key\t$ctg_strand\n";

			# coordinates on ref
			my ($ref, $ref_start);
			if (exists $map{$ctg}{$ctg_key}) {
				($ref, $ref_start) = @{$map{$ctg}{$ctg_key}};
			} else {
				print STDERR "ERROR: $ctg and $ctg_key not in the agp map\n";
				exit;
			}

			if ($ctg_strand eq "+") {
				$newstart =  $ref_start + $start - $ctg_key;
				$newstrand = $strand;
			} elsif ($ctg_strand eq "-") {
				$newstart =  $ref_start + $ctg_key - $end;
				$newstrand = $strand eq "+" ? "-" : "+"; # reverse orientation
			}
			# new end
			$newend =  $newstart + $end - $start;

			# update information
			$line[0] = $ref;
			$line[3] = $newstart;
			$line[4] = $newend;
			$line[6] = $newstrand;

			print join("\t", @line);
			print "\n";
		} else { # $component{$ctg} does not exist
			print "$_\n";
		}
	} else { # print comments
		print "$_\n";
	}
}

