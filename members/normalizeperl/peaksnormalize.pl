#!/usr/bin/env perl

use warnings;
use strict;

####
#### ADDED FOR DEPENDENCY ON LOCALLY INSTALLED Statistics::Distributions
###use lib "/projects/ps-yeolab/software/eclip-0.1.4/base_perlmodules/share/perl5";

#### ADDED FOR SINGULARITY IMAGE
###use lib "/opt/base_perlmodules/share/perl5";
####


use Statistics::Distributions;
use Statistics::R;


# This version is for bam files that are READ 2 ONLY of PE mapping
#

##
##
##

# Keep in mind:
# STAR sam output (including output from 'samtools view .bam') is 1-based, closed ended
# Bed files are 0-based, open-ended

unless ($ARGV[0] && $ARGV[1] && $ARGV[2] && $ARGV[3]) {
    #######################################################################################################################
    print STDERR "usage: perl overlap_peakfi_with_bam_PE.pl Experiment_bam_file Input_bam_file Peak_file Output_file\n\n";
    #print STDERR "usage: perlnormalize.pl Experiment_bam_file Input_bam_file Peak_file Output_file  Experiment_bai_file Input_bai_file\n\n";
    #############################################################################################################################################

    exit;
}

# Create a communication bridge with R and start R                                                                                                                                            
my $R = Statistics::R->new();

my $exptbamfile = $ARGV[0];
my $inputbamfile = $ARGV[1];
my $peakfi = $ARGV[2];

my $output_fi = $ARGV[3];

#############################
my $output_full = $ARGV[4];
#############################
#my $exptbaifile = $ARGV[5];
#my $inputbaifile = $ARGV[6];
##############################

my %precalculated_fisher;

my @fi1array = split(/\//,$exptbamfile);
my @input_fiarray = split(/\//,$inputbamfile);


my %mapped_read_count;

&sum_idx_stats($inputbamfile,"input");
&sum_idx_stats($exptbamfile,"expt");






my %peaks;
my $hashing_value = 100000;
my %peak_read_counts;
&read_peakfi($peakfi);

&read_bamfi($exptbamfile,"expt");
&read_bamfi($inputbamfile,"input");


my $fisher_tmp_fi = $output_fi.".tmp_fisher";
my $fisher_tmp_fi_out = $output_fi.".tmp_fisher.out";

##########################################
#my $output_full = $output_fi.".full";     # TODO now replaced by taking additional parameter to perl script
##########################################
open(OUTFULL,">$output_full");
open(OUT,">$output_fi");

for my $peak (keys %peak_read_counts) {
    unless (exists $peak_read_counts{$peak}{"expt"}) {
	$peak_read_counts{$peak}{"expt"} = 1;
    }
    $peak_read_counts{$peak}{"input"}++;

#
    my $l2fc = log(($peak_read_counts{$peak}{"expt"}/$mapped_read_count{"expt"}) / ($peak_read_counts{$peak}{"input"}/$mapped_read_count{"input"})) / log(2);

    my ($chipval,$chival,$chitype,$chienrdepl) = &fisher_or_chisq($peak_read_counts{$peak}{"expt"},$mapped_read_count{"expt"}-$peak_read_counts{$peak}{"expt"},$peak_read_counts{$peak}{"input"},$mapped_read_count{"input"}-$peak_read_counts{$peak}{"input"});
    my $log10pval = $chipval > 0 ? -1 * log($chipval)/log(10) : 400 ;
#
#

    my ($chr,$pos,$str,$origpval) = split(/\:/,$peak);
    my ($start,$stop) = split(/\-/,$pos);
    print OUT "$chr\t$start\t$stop\t$log10pval\t$l2fc\t$str\n";
    print OUTFULL "$chr\t$start\t$stop\t$peak\t".$peak_read_counts{$peak}{"expt"}."\t".$peak_read_counts{$peak}{"input"}."\t$chipval\t$chival\t$chitype\t$chienrdepl\t$log10pval\t$l2fc\n";
    

}
close(OUT);

sub max {
    my $x = shift;
    my $y = shift;
    if ($x > $y) {
        return($x);
    } else {
        return($y);
    }
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

sub sum_idx_stats {
    my $bamfi = shift;
    my $label = shift;
    
    my $idxstats = `samtools idxstats $bamfi`;
    my @idxstatss = split(/\n/,$idxstats);
    my $total = 0;
    for my $idxstat (@idxstatss) {
	my ($chr,$pos,$num,$del) = split(/\t/,$idxstat);
	$total += $num;
    }
    $mapped_read_count{$label} = $total;
    print STDERR "$bamfi\t$total\n";
}



sub fisher_or_chisq {
    my ($a,$b,$c,$d) = @_;
    unless ($a && $b && $c && $d) {
	print STDERR "one of the values doesn't exist $a $b $c $d - error\n";
    }

    my $tot = $a + $b + $c + $d;
    my $expa = ($a+$c)*($a+$b)/$tot;
    my $expb = ($b+$d)*($a+$b)/$tot;
    my $expc = ($a+$c)*($c+$d)/$tot;
    my $expd = ($b+$d)*($c+$d)/$tot;

    my $direction = "enriched";
    if ($a<$expa) {
        $direction = "depleted";
        return(1,"DEPL","N",$direction);
    }



    if ($expa < 5 || $expb < 5 || $expc < 5 || $expd < 5 || $a < 5 || $b < 5 || $c < 5 || $d < 5) {
        if (exists $precalculated_fisher{$a."|".$c}) {
            return($precalculated_fisher{$a."|".$c}{p},$precalculated_fisher{$a."|".$c}{v},"F",$direction);
        } else {
            my ($pval,$val) = &fisher_exact($a,$b,$c,$d);
            $precalculated_fisher{$a."|".$c}{p} = $pval;
            $precalculated_fisher{$a."|".$c}{v} = $val;
            return($pval,$val,"F",$direction);
        }
    } else {
        my ($pval,$val) = &chi_square($a,$b,$c,$d);
        return($pval,$val,"C",$direction);
    }
}
sub chi_square {
    my ($a,$b,$c,$d) = @_;
    #
    return(0) unless ($a && $b && $c && $d);
    #
    #
    #
    #

#
#
    my $tot = $a + $b + $c + $d;
    my $expa = ($a+$c)*($a+$b)/$tot;
    my $expb = ($b+$d)*($a+$b)/$tot;
    my $expc = ($a+$c)*($c+$d)/$tot;
    my $expd = ($b+$d)*($c+$d)/$tot;
    
    if ($expa >= 5 || $expb >= 5 || $expc >= 5 || $expd >= 5) {
        my $chival = &square(&abs($a-$expa)-0.5)/$expa +  &square(&abs($b-$expb)-0.5)/$expb + &square(&abs($c-$expc)-0.5)/$expc +  &square(&abs($d-$expd)-0.5)/$expd;
        
        my $pval = Statistics::Distributions::chisqrprob(1,&abs($chival));

        if ($a<$expa) {
            $chival = $chival * -1;
        }
        return ($pval,$chival);
    } else {

        print STDERR "shouldn't get to this - should have been shunted into fisher exact test\n";
        return(1);
    }
}

sub fisher_exact {
    my ($x1,$x2,$y1,$y2) = @_;

    # Run fisher exact test in R

    $R->run("blah <- matrix(c(".$x1.",".$x2.",".$y1.",".$y2."),nrow=2)");
    $R->run("foo <- fisher.test(blah)");
    my $p_value_vs_bgd = $R->get('foo$p.value');
    my $val = "F";
    return($p_value_vs_bgd,$val);













































}

sub abs {
    my $x = shift;
    if ($x > 0) {
        return($x);
    } else {
        return(-1*$x);
    }
}

sub square {
    my $x = shift;
    return($x * $x);
}


sub read_bamfi {
    my $bamfile = shift;
    my $label = shift;
    print STDERR "now doing $label $bamfile\n";
    if ($bamfile =~ /\.bam/) {
	open(B,"samtools view -h $bamfile |") || die "no $bamfile\n";
    } elsif ($bamfile =~ /\.sam/) {
	open(B,$bamfile) || die "no sam $bamfile\n";
    } else {
	print STDERR "file format error not .sam or .bam \n";
	exit;
    }
    while (<B>) {
	my $r1 = $_;
	
	if ($r1 =~ /^\@/) {
	    next;
	} 
	my @tmp_r1 = split(/\t/,$r1);
	my @read_name = split(/\:/,$tmp_r1[0]);
	my $randommer = $read_name[0];
	
	my $r1_cigar = $tmp_r1[5];
	my $r1sam_flag = $tmp_r1[1];
	my $mismatch_flags = $tmp_r1[14];
	
	my $r1_chr = $tmp_r1[2];
	my $r1_start = $tmp_r1[3];

	my $frag_strand;
	if ($r1sam_flag == 147) {
	    $frag_strand = "-";
	} elsif ($r1sam_flag == 163) {
	    $frag_strand = "+";
	} else {
	    print STDERR "R1 strand error $r1sam_flag\n";
	}

	
	my @read_regions = &parse_cigar_string($r1_start,$r1_cigar,$r1_chr,$frag_strand);
	
	my %tmp_hash;
	for my $region (@read_regions) {
	    my ($rchr,$rstr,$rpos) = split(/\:/,$region);
	    my ($rstart,$rstop) = split(/\-/,$rpos);

	    my $verbose_flag = 0;

	    my $rx = int($rstart / $hashing_value);
	    my $ry = int($rstop  / $hashing_value);
	    for my $ri ($rx..$ry) {
		
		for my $peak (@{$peaks{$rchr}{$rstr}{$ri}}) {
		    my ($pchr,$ppos,$pstr,$ppval) = split(/\:/,$peak);
		    my ($pstart,$pstop) = split(/\-/,$ppos);

#
#
#
#
#
#
		    next if ($pstart >= $rstop || $pstop <= $rstart);
		    $tmp_hash{$peak} = 1;

		}
	    }
	}
	
	for my $peak (keys %tmp_hash) {
	    $peak_read_counts{$peak}{$label}++;
	}
    }
    close(B);
}






sub parse_cigar_string {
    my $region_start_pos = shift;
    my $flags = shift;
    my $chr = shift;
    my $strand = shift;

    my $current_pos = $region_start_pos;
    my @regions;

    while ($flags =~ /(\d+)([A-Z])/g) {
       
        if ($2 eq "N") {
            #read has intron of N bases at location

# 1 based, closed ended to 0 based, right side open ended fix
#
            push @regions,$chr.":".$strand.":".($region_start_pos-1)."-".($current_pos-1);

            $current_pos += $1;
            $region_start_pos = $current_pos;
        } elsif ($2 eq "M") {
            #read and genome match
            $current_pos += $1;
        } elsif ($2 eq "S") {
            #beginning of read is soft-clipped; mapped pos is actually start pos of mapping not start of read
        } elsif ($2 eq "I") {
            #read has insertion relative to genome; doesn't change genome position
        } elsif ($2 eq "D") {
#
            $current_pos += $1;
            #read has deletion relative to genome; genome position has to increase
        } else {
            print STDERR "flag $1 $2 $flags\n";

        }
    }

# 1 based, closed ended to 0 based, right side open ended fix            
# $region_start_pos is 1-based, closed ended -> ($region_start_pos-1) is 0-based, closed ended
# ($current_pos-1) is 1-based, closed ended -> ($current_pos-1-1) is 0-based, closed ended -> ($current_pos-1-1+1) is 0-based, open ended

#
    push @regions,$chr.":".$strand.":".($region_start_pos-1)."-".($current_pos-1);

    return(@regions);
}





sub read_peakfi {
    my $fi = shift;


    print STDERR "reading peak file $fi\n";
    open(F,$fi) || die "no peak file $fi\n";
    for my $line (<F>) {
	chomp($line);
	my @tmp = split(/\t/,$line);
	my $chr = shift(@tmp);
	my $start = shift(@tmp);
	my $stop = shift(@tmp);
	my $gene = shift(@tmp);
	my $pval = shift(@tmp);
	my $strand = shift(@tmp);




	my $x = int($start / $hashing_value);
	my $y = int($stop  / $hashing_value);

	my $peak = $chr.":".$start."-".$stop.":".$strand.":".$pval;





	$peak_read_counts{$peak}{allpeaks} = 1;


	for my $i ($x..$y) {
	    push @{$peaks{$chr}{$strand}{$i}},$chr.":".$start."-".$stop.":".$strand.":".$pval;
	}
    }
    close(F);

}
