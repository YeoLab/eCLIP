#!/usr/bin/env perl

use warnings;
use strict;

## 20151109 - changed to output bed file as (0,10] instead of (0,9) to match with ucsc bed format

## this is the first version - keeps MOST significant peak if two overlap
my $hashing_value = 100000;

# uses l2foldenr peak files

# input to this file is the ORIGINAL .l2inputnormnew.bed.full file - ie /home/elvannostrand/data/clip/CLIPseq_analysis/Method_paper_finalALLRERUN_102615/EV42_01.basedon_EV42_01.peaks.l2inputnormnew.bed.full

my $fi = $ARGV[0];
my $output_fi = $ARGV[1];
my $output_fi_full = $ARGV[2];
# my $output_fi = $fi.".compressed2.bed";
# my $output_fi_full = $output_fi.".full";

if (-e $output_fi_full) {
    print STDERR "skipping $output_fi_full exists\n";
    exit;
}

open(O,">$output_fi");
open(FULL,">$output_fi_full");

my %peaks2size;
my %peaks2l2fenr;
my %peaks2l10p;
my %peaks2start;
my %read_hash;
my %peak_hash;
my %saved_lines;

&readfi($fi);

my %overlap_hash;
#for my $chr ("chr10") {
for my $chr (keys %read_hash) {
    for my $str ("+","-") {
#	print STDERR "\non $chr $str\n";

	my %deleted_peaks;
	my %kept_peaks;

#	my @sorted_peaks = sort {$peaks2l10p{$chr}{$str}{$fi}{$b} <=> $peaks2l10p{$chr}{$str}{$fi}{$a}} keys %{$peaks2l10p{$chr}{$str}{$fi}};
	my @sorted_peaks = sort {$peaks2l10p{$chr}{$str}{$fi}{$b} <=> $peaks2l10p{$chr}{$str}{$fi}{$a} or $peaks2l2fenr{$chr}{$str}{$fi}{$b} <=> $peaks2l2fenr{$chr}{$str}{$fi}{$a}  or $peaks2size{$chr}{$str}{$fi}{$b} <=> $peaks2size{$chr}{$str}{$fi}{$a} or $peaks2start{$chr}{$str}{$fi}{$b} <=> $peaks2start{$chr}{$str}{$fi}{$a}} keys %{$peaks2l10p{$chr}{$str}{$fi}};
	
	my $i=0;

	for my $peak1 (@sorted_peaks) {
	    my $verbose_flag = 0;
#	while ($i < scalar(@sorted_peaks)) {
## now take any peaks that overlap and merge them
#	    my $peak1 = $sorted_peaks[$i];

	    next if (exists $deleted_peaks{$peak1});
#	    print STDERR "re-checking $peak1\r";

#	    my $peak_id = $chr.":".$start."-".$stop.":".$str.":".$vsinput_l10p.":".$vsinput_l2fenr;

	    my ($p1chr,$p1pos,$p1str,$p1vsinput_l10p,$p1vsinput_l2fenr) = split(/\:/,$peak1);
	    my ($p1start,$p1stop) = split(/\-/,$p1pos);

	    my $p1x = int($p1start / $hashing_value);
	    my $p1y = int( $p1stop / $hashing_value);

	    for my $p1i ($p1x..$p1y) {
		for my $tocomp_peak (@{$read_hash{$chr}{$str}{$fi}{$p1i}}) {
		    print STDERR "comparing $peak1 $tocomp_peak\n" if ($verbose_flag == 1);
		    next if (exists $deleted_peaks{$tocomp_peak});
		    next if ($tocomp_peak eq $peak1);

		    my ($p2compchr,$p2comppos,$p2compstr,$p2compvsinput_l10p,$p2compvsinput_l2fenr) = split(/\:/,$tocomp_peak);
		    my ($p2compstart,$p2compstop) = split(/\-/,$p2comppos);

		    next if ($p2compstop <= $p1start);
		    next if ($p1stop <= $p2compstart);

		    #peak2 overlaps with peak1 and has a lower l10pval - remove it!
		    if ($p1vsinput_l10p >= $p2compvsinput_l10p) {
			print STDERR "discarding $tocomp_peak vs $peak1\n" if ($verbose_flag == 1);
			$deleted_peaks{$tocomp_peak} = 1;
		    } elsif ($p1vsinput_l10p < $p2compvsinput_l10p) {
			$deleted_peaks{$peak1} = 1;
			print STDERR "discarding $peak1 vs $tocomp_peak\n" if ($verbose_flag == 1);
		    } else {
			print STDERR "weird error shouldn't happen $peak1\n";
		    }
		}
	    }
		
#	    my $overlap_start = &min($p1start,$p2start);
#	    my $overlap_stop = &max($p1stop,$p2stop);
#	    $sorted_peaks[$i] = $overlap_start."-".$overlap_stop;

### In this version - if two peaks overlap within a file, just take the one with the highest fold-enrichment over input

	    
	}
	
	for my $peak (@sorted_peaks) {
	    next if (exists $deleted_peaks{$peak});

	    my ($p1chr,$p1pos,$p1str,$p1vsinput_l10p,$p1vsinput_l2fenr) = split(/\:/,$peak);
            my ($p1start,$p1stop) = split(/\-/,$p1pos);
	    print O "$p1chr\t$p1start\t$p1stop\t$p1vsinput_l10p\t$p1vsinput_l2fenr\t$p1str\n";
	    print FULL "".$saved_lines{$p1chr.":".$p1pos.":".$p1str}."\n";
	}
    }
}
close(O);
close(FULL);


sub min {
    my $x = shift;
    my $y = shift;
    
    if ($x < $y) {
	return($x);
    } else {
	return($y);
    }
}

sub max {
    my $x = shift;
    my $y = shift;

    if ($x > $y) {
	return($x);
    } else {
	return($y);
    }
}

sub readfi {
    my $fi = shift;
    open(F,$fi) || die "can't open $fi\n";
    for my $line (<F>) {
	chomp($line);

	my @tmp = split(/\t/,$line);

#	my $chr = $tmp[0];
#	my $str = $tmp[5];
	my $start = $tmp[1];
	my $stop = $tmp[2];

	my ($chr,$pos,$str,$orig_pval) = split(/\:/,$tmp[3]);
#	my ($start,$stop) = split(/\-/,$pos);

#### Gabe's peaks are open-ended on right side; this fixes that issue (so peak from 1-10 actually covers bases 1-10, not 1-9


	my $vsinput_l10p = $tmp[10];
	my $vsinput_l2fenr = $tmp[11];
#	my $vsinput_l10p = $tmp[3];
#	my $vsinput_l2fenr = $tmp[4];

#	my ($chr,$start,$stop,$ens_id,$pval,$str,$start2,$stop2) = split(/\t/,$line);

	my $peak_id = $chr.":".$start."-".$stop.":".$str.":".$vsinput_l10p.":".$vsinput_l2fenr;


#	if ($peak_id eq "chr10:102122354-102122407:+:29.3173405758206:2.69808212257618") {
#	    print STDERR "read in peak $peak_id\n";
#	    exit;
#	}

	push @{$peak_hash{$chr}{$str}{$fi}},$peak_id;
#	print STDERR "peak $chr $str $start $stop $pval\n";

	$peaks2start{$chr}{$str}{$fi}{$peak_id} = $start;
        $peaks2l10p{$chr}{$str}{$fi}{$peak_id} = $vsinput_l10p;
        $peaks2l2fenr{$chr}{$str}{$fi}{$peak_id} = $vsinput_l2fenr;
        $peaks2size{$chr}{$str}{$fi}{$peak_id} = $stop-$start;


#	$tmp[2] = $stop;
	my $newline = join("\t",@tmp);
	$saved_lines{$chr.":".$start."-".($stop).":".$str} = $newline;

	my $x = int($start / $hashing_value);
	my $y = int( $stop / $hashing_value);

	for my $i ($x..$y) {
	    push @{$read_hash{$chr}{$str}{$fi}{$i}},$peak_id


	}

    }
    close(F);
}
