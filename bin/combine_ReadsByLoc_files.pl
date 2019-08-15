#!/usr/bin/env perl

use warnings;
use strict;

my $line_size = 14;
my @files = @ARGV;

my %hash;
for my $fi (@files) {
    open(F,$fi);
    for my $line (<F>) {
	chomp($line);
	my @tmp = split(/\t/,$line);
	my $ensg = shift(@tmp);
	next if ($ensg eq "all");

	$hash{$ensg}{$fi} = join("\t",@tmp);
	if (scalar(@tmp) == $line_size) {
	} else {
	    print STDERR "changing line_size to ".scalar(@tmp)."\n";
	    $line_size = scalar(@tmp);
	}
    }
    close(F);
}

print "ENSG\t";
for my $fi (@files) {
    print "$fi|".$hash{"ENSG"}{$fi}."\t";
}
print "\n";

for my $k (keys %hash) {
    next if ($k eq "ENSG");
    print "$k\t";
    for my $fi (@files) {
	unless (exists $hash{$k}{$fi}) {
	    $hash{$k}{$fi} = "NaN";
	    for my $i (1..($line_size-1)) {
		$hash{$k}{$fi} .= "\tNaN";
	    }
	}
#	$hash{$k}{$fi} = "0\t0\t0\t0\t0\t0\t0\t0" unless (exists $hash{$k}{$fi});
	print "$hash{$k}{$fi}\t";
    }
    print "\n";
}
