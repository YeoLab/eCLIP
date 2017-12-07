#!/usr/bin/env perl

use warnings;
use strict;

my $hashing_value = 10000;
my $l2fc_cutoff = 3;
my $l10p_cutoff = 3;
#my $idr_file = "204.01v02.IDR.out";
my $idr_file = $ARGV[0];
#my $file1 = "204_01.basedon_204_01.peaks.l2inputnormnew.bed.full.compressed2.bed.full.annotated_proxdist.entropy";
my $file1 = $ARGV[1];
#my $file2 = "204_02.basedon_204_02.peaks.l2inputnormnew.bed.full.compressed2.bed.full.annotated_proxdist.entropy";
my $file2 = $ARGV[2];

my $output_bed = $ARGV[3];




my $idr_cutoff = 0.01;
my %idr_cutoffs = ("0.001" => "1000", "0.005" => "955", "0.01" => "830", "0.02" => "705", "0.03" => "632", "0.04" => "580", "0.05" => "540", "0.06" => "507", "0.07" => "479", "0.08" => "455", "0.09" => "434", "0.1" => "415", "0.2" => "290", "0.3" => "217", "0.4" => "165", "0.5" => "125", "1" => "0");

my %idr_output;
&parse_idr_file($idr_file);

my %idrregion2peaks;


&parse_file($file1);
&parse_file($file2);
open(OUTBED,">$output_bed");
for my $idr_region (keys %idrregion2peaks) {
    for my $peak (keys %{$idrregion2peaks{$idr_region}}) {
#	print OUTA "".$idr_region."\t".$peak."\n";
	my ($chr,$pos,$str) = split(/\:/,$peak);
	my ($start,$stop) = split(/\-/,$pos);
	print OUTBED "$chr\t$start\t$stop\t.\t.\t$str\n";
    }
}
#close(OUTA);
# close(CUSTOMOUT);
close(OUTBED);


sub parse_file {
    my $file = shift;
    open(F,$file);
    for my $line (<F>) {
        chomp($line);

        my @tmp = split(/\t/,$line);
        my $chr = $tmp[0];
        my $start = $tmp[1];
        my $stop = $tmp[2];

        my ($chr2,$pos2,$str,$origpval) = split(/\:/,$tmp[3]);
        # my $entropy = $tmp[15]; # if we don't annotate, this is the 13th column
        my $entropy = $tmp[12];
        my $l2fc = $tmp[11];
        my $l10p = $tmp[10];

        next unless ($l2fc >= 3 && $l10p >= 3);
#       print "chr $chr start $start stop $stop str $str l2 $l2fc l10p $l10p ent $entropy\n";


        my $x = int($start / $hashing_value);
        my $y = int($stop / $hashing_value);

        my %overlapping_idrs;


        for my $i ($x..$y) {
            for my $idr_peak (@{$idr_output{$chr}{$str}{$i}}) {
                my ($ichr,$ipos,$istr,$iidr) = split(/\:/,$idr_peak);
                my ($istart,$istop) = split(/\-/,$ipos);
                next if ($istart >= $stop);
                next if ($istop <= $start);

                $overlapping_idrs{$idr_peak} = $iidr;
            }
        }
	
	if (scalar(keys %overlapping_idrs) > 0) {
	    
	    if (scalar(keys %overlapping_idrs) > 1) {
		print STDERR "This should NEVER be hit - peak overlaps with more than one IDR region $line\n".join("\t",keys %overlapping_idrs)."\n---\n";
	    }

	    my @sorted_idr = keys %overlapping_idrs;
	    my $overlapping_idrpeak = $sorted_idr[0];	    
	    my ($ichr,$ipos,$istr,$iidr) = split(/\:/,$overlapping_idrpeak);

	    if ($iidr >= $idr_cutoffs{$idr_cutoff}) {
		$idrregion2peaks{$overlapping_idrpeak}{$chr.":".$start."-".$stop.":".$str} = 1;
	    }
	} else {
	    # peak not in IDR list

	}
    }
    close(F);
}




sub parse_idr_file {
    my $idr_file = shift;
    open(ID,$idr_file);
    for my $line (<ID>) {
	chomp($line);
	my @tmp = split(/\t/,$line);
	
	my $chr = $tmp[0];
	my $start = $tmp[1];
	my $stop = $tmp[2];
	my $str = $tmp[5];
	
	my $idr_score = $tmp[4];
	
	my $x = int($start / $hashing_value);
	my $y = int($stop / $hashing_value);
        
	for my $i ($x..$y) {
	    push @{$idr_output{$chr}{$str}{$i}},$chr.":".$start."-".$stop.":".$str.":".$idr_score;
	}
    }
    close(ID);
}


sub min {
    my $x = shift;
    my $y = shift;
    if ($x < $y) {
	return($x);
    } else {
	return($y);
    }
}
