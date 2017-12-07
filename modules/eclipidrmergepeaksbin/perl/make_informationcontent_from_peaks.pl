#!/usr/bin/env perl

use warnings;
use strict;

my $file = $ARGV[0];

my $expt_readnum_file = $ARGV[1];
my $input_readnum_file = $ARGV[2];

my $input_readnum;
my $clip_readnum;

# my $read_num_fi = $ARGV[3];
open(RN,$expt_readnum_file) || die "no $expt_readnum_file\n";
for my $line (<RN>) {
    chomp($line);
    next unless ($line);
    $clip_readnum = $line;
}
close(RN);

# my $read_num_fi = $ARGV[3];
open(RN,$input_readnum_file) || die "no $input_readnum_file\n";
for my $line (<RN>) {
    chomp($line);
    next unless ($line);
    $input_readnum = $line;
}
close(RN);

my $entropy_outfi = $ARGV[3];
# my $entropy_outfi = $file.".entropy";
open(ENT,">$entropy_outfi");
my $excessreads_outfi = $ARGV[4];
# my $excessreads_outfi = $file.".excess_reads";
open(READS,">$excessreads_outfi");

print STDERR "doing $file\n";
open(F,$file);
for my $line (<F>) {
    chomp($line);
    my @tmp = split(/\t/,$line);
    
    my $clip_reads = $tmp[4];
    my $input_reads = $tmp[5];

    my $pi = ($clip_reads / $clip_readnum);
    my $qi = ($input_reads / $input_readnum);

    my $entropy = 0;
    if ($pi > $qi) {
	$entropy = $pi * log($pi / $qi) / log(2);
    }
    my $chr = $tmp[0];
    my $start = $tmp[1];
    my $stop = $tmp[2];

    my ($chrdel,$posdel,$strand,$origpval) = split(/\:/,$tmp[3]);

    my $pos = $tmp[0].":".$tmp[1]."-".$tmp[2].":".$strand;

    print ENT "$line\t$entropy\n";

    my $excess_reads_p = ($pi - $qi);
    print READS "$line\t$excess_reads_p\n";


#    print "$chr\t$start\t$stop\t-\t$entropy\t$strand\n";

    
}
close(F);
close(ENT);
close(READS);
