#!/usr/bin/env perl

use warnings;
use strict;

my $sam_fi = $ARGV[0];
my @sam_fi_split = split(/\//,$sam_fi);
my $sam_fi_short = $sam_fi_split[$#sam_fi_split];

# my $output_dir = $ARGV[1];

my %filehandles;
for my $b1 ("A","C","G","T","N") {
    for my $b2 ("A","C","G","T","N") {
        #my $outfi = $output_dir.$sam_fi_short.".".$b1.$b2.".tmp";
        #my $outfi = $sam_fi_short.".".$b1.$b2.".tmp";
        my $outfi = $b1.$b2.'.'.$sam_fi_short.".tmp";  # change this to order them by AC/AT/AC/etc.
        open(my $fh, '>', $outfi);
        $filehandles{$b1.$b2} = $fh;
    }
}



if ($sam_fi =~ /\.sam$/) {
    open(F,$sam_fi);
} elsif ($sam_fi =~ /\.bam$/) {
    open(F,"samtools view -h $sam_fi |") || die "no $sam_fi\n";
} else {
    print STDERR "weird - $sam_fi not either sam or bam file format - exit\n";
    exit;
}

while (<F>) {
    my $r1 = $_;

    next if ($r1 =~ /^\@/);
    chomp($r1);

    my @tmp_r1 = split(/\t/,$r1);
#    my ($r1name,$r1bc) = split(/\s+/,$tmp_r1[0]);

    my $r1sam_flag = $tmp_r1[1];
#    unless ($r1sam_flag) {
#        print STDERR "error $r1\n";
#    }
    next if ($r1sam_flag == 4);

    my $frag_strand;
### This section is for only properly paired reads                                                                                                                                                                       
    if ($r1sam_flag == 16 || $r1sam_flag == 272) {
        $frag_strand = "-";
    } elsif ($r1sam_flag eq "0" || $r1sam_flag == 256) {
        $frag_strand = "+";
    }  else {
        next;
        print STDERR "R1 strand error $r1sam_flag\n";
    }

    my @read_name = split(/\_/,$tmp_r1[0]);
    my $randommer = pop(@read_name);
    my $r1name = join("_",@read_name);

#    my @read_name = split(/\_/,$tmp_r1[0]);
#    my $randommer = $read_name[1];
    my $first2rand = substr($randommer,0,2);
    print { $filehandles{$first2rand} } "".$r1."\n";
}
close(F);
