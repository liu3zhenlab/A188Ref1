#!/usr/bin/perl -w 

# this code was originally in Maker
# a slight modification to allow to use -s -a at the same time

eval 'exec /usr/bin/perl -w  -S $0 ${1+"$@"}'
    if 0; # not running under some shell
use strict;
#use lib ('/home/mcampbell/lib');
#use PostData;
use Getopt::Std;
use vars qw($opt_s $opt_d $opt_a $opt_p $opt_c $opt_m $opt_u);
getopts('sda:pcmu');
use FileHandle;

#-----------------------------------------------------------------------------
#----------------------------------- MAIN ------------------------------------
#-----------------------------------------------------------------------------
my $usage = "\n\nquality_filter_Liu.pl: generates defualt and standard 
gene builds from a maker geneated gff3_file with 
iprscan data pushed onto column 9 using ipr_update_gff.\n  

Note: the script was modified from quality_filter.pl in Maker.
The modification allows to use -s and -a at the same time.
if both specified, transcripts with an AED smaller or equal to -a value 
and/or annoated with Pfam will pass the filter.

USAGE: quality_filter_Liu.pl -[options]<gff3_file>\n                                                                               
OPTIONS: -d  Prints transcripts with an AED <=1 (MAKER default)         
         -s  Prints transcripts with an AED <=1 or -a input if -a is specified
		     and/or Pfam domain if in gff3 (MAKER Standard)
         -a  <number between 0 and 1> Prints transcripts with an 
             AED < the given value\n\n";

my $FILE1 = $ARGV[0];
#my $FILE2 = $ARGV[1];
die($usage) unless $ARGV[0] && ($opt_a || $opt_s || $opt_d);

my %LU_G;
my %LU_T;

build_lus($FILE1);
#build_lu_tid($FILE2);
filter($FILE1);
#PostData(\%LU_G);
#PostData(\%LU_T);
#-----------------------------------------------------------------------------
#---------------------------------- SUBS -------------------------------------
#-----------------------------------------------------------------------------
sub build_lus{
    my $file = shift;
    my %data;
    my $fh = new FileHandle;
    $fh->open($file);

    while (defined(my $line = <$fh>)){
        chomp($line);
        last if $line =~ /^\#\#FASTA/;
        next if $line =~ /^\#/;

        my @array = split(/\t/, $line);
        next unless $array[2] =~ /mRNA/;
        my ($tid) = $array[8] =~ /ID\=(.+?);.*/;
	my ($gid) = $array[8] =~ /Parent\=(.+?);.*/;
        
	my @c9 = split(/\;/, $array[8]);
        foreach my $x (@c9){
            my ($k,$v) = $x =~ /(.+)\=(.+)/;
            $data{$k}=$v;
        }
	#load the LU
	my $aed_threshold = 1;
	if ($opt_s && $opt_a) {
		$aed_threshold = $opt_a;
	}
	
	if ($opt_s && 
	    (($data{'Dbxref'} && $data{'Dbxref'} =~ /Pfam/) ||
	     $data{'_AED'} <= $aed_threshold)){
	    $LU_G{$gid}=1;
	    $LU_T{$tid}=1;
	}
	elsif ($opt_d && $data{'_AED'} <= 1){
	    $LU_G{$gid}=1;
	    $LU_T{$tid}=1;
	}
	elsif ($opt_a && $data{'_AED'} <= $opt_a){
	    $LU_G{$gid}=1;
	    $LU_T{$tid}=1;
	}
	undef %data;
    }

}
#-----------------------------------------------------------------------------
sub filter{
    my $file = shift;

    my $fh = new FileHandle;
    $fh->open($file);
    print "##gff-version 3\n";
    while (defined(my $line = <$fh>)){
        chomp($line);

        last if $line =~ /^\#\#FASTA/;
        next if $line =~ /^\#/;
        my @array = split(/\t/, $line);
	
        if ($array[2] eq 'gene'){
	    my ($id) = $array[8] =~ /ID=(\S+?);/;
	    print $line."\n" if defined($LU_G{$id}); 
	}
	elsif ($array[2] eq 'mRNA'){
	    my ($id) = $array[8] =~ /ID=(\S+?);/;
	    print $line."\n" if defined($LU_T{$id}); 
	}
	elsif ($array[2] eq 'exon'|
	    $array[2] eq 'CDS'|
	    $array[2] eq 'three_prime_UTR'|
	    $array[2] eq 'five_prime_UTR'){

	    my $bool = 0;
	    my ($ids) = $array[8] =~ /Parent=(\S+);?/;
#	    my ($ids) = $array[8] =~ /Parent=(\S+?);/;
	    $ids =~ s/;//;

	    my @ids_array = split(/,/, $ids);
	    
	    foreach my $x (@ids_array){
		if (defined($LU_T{$x})){
		    $bool++;
		}
		else{
		    $line =~  s/$x[^:]//;
		}
	    }
	    print $line."\n" if $bool;
	}

	else{print $line."\n"}
    }
    $fh->close();
    
}
#-----------------------------------------------------------------------------
sub build_lu_gid{

    my $file = shift;       
    
    my $fh = new FileHandle;
    $fh->open($file);
    
    while (defined(my $line = <$fh>)){
	chomp($line);
	$LU_G{$line}=1;
    }
    $fh->close();
}
#-----------------------------------------------------------------------------
sub build_lu_tid{

    my $file = shift;       
    
    my $fh = new FileHandle;
    $fh->open($file);
    
    while (defined(my $line = <$fh>)){
	chomp($line);
	
	last if $line =~ /^\#\#FASTA/;
        next if $line =~ /^\#/;
        my @array = split(/\t/, $line);

        if ($array[2] =~ 'mRNA'){
	    my ($tid) = $line =~ /ID=(.+?);/;
            my ($gid) = $line =~ /Parent=(.+?);/;
	    if (defined($LU_G{$gid})){
		$LU_T{$tid}=1;
	    }
	}
    }
    $fh->close();
}
#-----------------------------------------------------------------------------

