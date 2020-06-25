#!/usr/bin/env perl

use warnings;
use strict;
use Statistics::Basic qw(:all);
use Statistics::Distributions;
use Statistics::R;
my $R = Statistics::R->new() ;


my %precalculated_fisher;
my $readcount_fi = $ARGV[0];

my %mapped_read_count;
my $clip_read_num_fi = $ARGV[1];

open(RN,$clip_read_num_fi) || die "no $clip_read_num_fi\n";
for my $line (<RN>) {
    chomp($line);
    next unless ($line);
    # my ($shortfi,$num) = split(/\t/,$line);
    # $mapped_read_count{$shortfi} = $num;
    $mapped_read_count{"clip"} = int($line);
 #   print STDERR "shortfi $shortfi\n";
}
close(RN);

my $input_read_num_fi = $ARGV[2];
open(RN,$input_read_num_fi) || die "no $input_read_num_fi\n";
for my $line (<RN>) {
    chomp($line);
    next unless ($line);
    # my ($shortfi,$num) = split(/\t/,$line);
    # $mapped_read_count{$shortfi} = $num;
    $mapped_read_count{"input"} = int($line);
 #   print STDERR "shortfi $shortfi\n";
}
close(RN);

# my $pval_fi = $readcount_fi.".l2fcwithpval_enr.csv";
my $pval_fi = $ARGV[3];
my $l2fc_fi = $ARGV[4];

open(RF,$readcount_fi) || die "no $readcount_fi\n";
my $labelline = <RF>;
chomp($labelline);
my @labels = split(/\t/,$labelline);
my $del = shift(@labels);

my $number_of_categories = 16;

unless (scalar(@labels) % $number_of_categories == 0) {
    print STDERR "WARNING WARNING\nWARNING WARNING\n$readcount_fi doesn't have mod $number_of_categories length????\n";
    exit;
}
my $num_replicates = (scalar(@labels) / $number_of_categories);
print("NUM REPLICATES".$num_replicates);
my @file_split = split(/\//,$readcount_fi);
my @file_split2 = split(/\_/,$file_split[$#file_split]);
my $UID = $file_split2[0]."_".$file_split2[1];

my %CLIP;
my $type_flag;
my @rep_listing;
my @input_rep_listing;
my $label1;
my $label2;
my %rep_ip2input;

if ($num_replicates == 2) {
    ($CLIP{"clip"}{fi},$label1) = split(/\|/,$labels[0]);
    ($CLIP{"input"}{fi},$del) = split(/\|/,$labels[$number_of_categories]);
    $labels[0] = $label1;
    $labels[$number_of_categories] = $label1;
    for(my $i=0;$i<$number_of_categories;$i++) {
	$labels[$i] = $UID."clip|".$labels[$i];
    }
    $type_flag = "one_replicate";
    @rep_listing = ("clip");
    @input_rep_listing = ("input");
    $rep_ip2input{"clip"} = "input";
    print("TWO INPUTS");
}

for my $rep (@rep_listing,"input") {
    # my @expt_fi_tmp = split(/\//,$CLIP{$rep}{fi});
    # my $expt_fi_short = $expt_fi_tmp[$#expt_fi_tmp];
    # $expt_fi_short =~ s/\.reads\_by\_loc\.csv//;
    print "rep: $rep"."\n";
    my $expt_fi_short = $rep;
    $CLIP{$rep}{shortfi} = $expt_fi_short;
    $CLIP{$rep}{mappednum} = $mapped_read_count{$expt_fi_short};
    print "$rep, $expt_fi_short, $mapped_read_count{$expt_fi_short}"."\n";
}

for my $rep (@rep_listing) {
    $CLIP{$rep}{ratio} = $CLIP{$rep}{mappednum} / $CLIP{"input"}{mappednum};
    $CLIP{$rep}{inpexpratio} = $CLIP{"input"}{mappednum} / $CLIP{$rep}{mappednum};
    print("CLIP REP RATIO: ".$CLIP{$rep}{ratio}."\n");
    print("IN REP RATIO: ".$CLIP{$rep}{inpexpratio}."\n");
}

my %alldata_l10pvals;
my %l2input_norms;
my %alldata;
for my $line (<RF>) {
    chomp($line);
    my @tmp = split(/\t/,$line);
    my $ensg = shift(@tmp);

    for my $rep (@rep_listing) {
	@{$CLIP{$rep}{data}} = splice @tmp,0,$number_of_categories;
    }
    for my $rep (@input_rep_listing) {
	@{$CLIP{$rep}{data}} = splice @tmp,0,$number_of_categories;
    }
    print STDERR "WARNING WARNING tmp array is too long?? $line\n" if ($tmp[0]);

    for my $rep (@rep_listing) {
	for (my $i=0;$i<=($number_of_categories-1);$i++) {
	    $CLIP{$rep}{data}[$i] = 1 unless ($CLIP{$rep}{data}[$i] > 0);
	    $CLIP{$rep_ip2input{$rep}}{data}[$i] = 1 unless ($CLIP{$rep_ip2input{$rep}}{data}[$i] > 0);
	    
	    my $sum = $CLIP{$rep}{data}[$i] + $CLIP{$rep_ip2input{$rep}}{data}[$i];
	    
	    my $expected_input = $CLIP{$rep}{data}[$i] * $CLIP{$rep}{inpexpratio};
	    my $expected_expt  = $CLIP{$rep_ip2input{$rep}}{data}[$i] * $CLIP{$rep}{ratio};

	    
	    my $chisq_11 = $CLIP{$rep}{data}[$i];
	    my $chisq_10 = $CLIP{$rep}{mappednum} - $CLIP{$rep}{data}[$i];
	    my $chisq_01 = $CLIP{$rep_ip2input{$rep}}{data}[$i];
	    my $chisq_00 = $CLIP{$rep_ip2input{$rep}}{mappednum} - $CLIP{$rep_ip2input{$rep}}{data}[$i];
	    my ($chipval,$chival,$chitype,$chienrdepl) = &fisher_or_chisq($chisq_11,$chisq_10,$chisq_01,$chisq_00);
	    my $log10pval = $chipval > 0 ? -1 * log($chipval)/log(10) : 400 ;
	
	    $alldata_l10pvals{$ensg}{$rep}[$i] = sprintf("%.5f",$log10pval);
	    
## fixed this 2016/01/27 - wasn't actuall counting if both were >= 10, just if expected was >= 10 
#	    if (($CLIP{$rep}{data}[$i] >= 10 && $expected_input >= 10) || ($CLIP{"input"}{data}[$i] >= 10 && $expected_expt >= 10)) {
	    my $min_ip_cutoff = 10;
	    my $min_input_cutoff = 10;
#	    if (($CLIP{$rep}{data}[$i] >= 10 && $CLIP{$rep_ip2input{$rep}}{data}[$i] >= 10) || ($CLIP{$rep}{data}[$i] >= 10 && $expected_input >= 10) || ($CLIP{$rep_ip2input{$rep}}{data}[$i] >= 10 && $expected_expt >= 10)) {
	    if (($CLIP{$rep}{data}[$i] >= $min_ip_cutoff && $CLIP{$rep_ip2input{$rep}}{data}[$i] >= $min_input_cutoff) || ($CLIP{$rep}{data}[$i] >= $min_ip_cutoff && $expected_input >= $min_input_cutoff) || ($CLIP{$rep_ip2input{$rep}}{data}[$i] >= $min_input_cutoff && $expected_expt >= $min_ip_cutoff)) {
		my $l2input_norm = sprintf("%.4f",log(($CLIP{$rep}{data}[$i] / $CLIP{$rep_ip2input{$rep}}{data}[$i]) / ($CLIP{$rep}{ratio}))/log(2));
		push @{$l2input_norms{$rep}{$labels[$i]}},$l2input_norm;
		$alldata{$ensg}{$rep}[$i] = $l2input_norm;
		
	    } else {
		$alldata{$ensg}{$rep}[$i] = "NA";
	    }
	}
    }
}
close(RF);

my %means;
my %stdevs;
for my $rep (@rep_listing) {
    for my $type (keys %{$l2input_norms{$rep}}) {
	my ($mean,$median,$standard_deviation,$skew,$kurtosis,$first,$third) = &stats(\@{$l2input_norms{$rep}{$type}});
	$means{$rep}{$type} = $mean;
	$stdevs{$rep}{$type} = $standard_deviation;
    }
}

open(POUT,">$pval_fi");
# my $l2fc_fi = $readcount_fi.".l2fc.csv";
open(LOUT,">$l2fc_fi");

if ($type_flag eq "one_replicate") {
    print POUT "ENSG\t".join("\t",@labels[0..($number_of_categories-1)])."\n";
    print LOUT "ENSG\t".join("\t",@labels[0..($number_of_categories-1)])."\n";
} elsif ($type_flag eq "two_replicate_ENCODEstyle" || $type_flag eq "two_replicate_two_input") {
    print POUT "ENSG\t".join("\t",@labels[0..($number_of_categories * 2 - 1)])."\n";
    print LOUT "ENSG\t".join("\t",@labels[0..($number_of_categories * 2 - 1)])."\n";
} else {
    print STDERR "type flag error $type_flag\n";
}


for my $ensg (keys %alldata) {
    my %l10pvals;
    my %l2fcs;
    for my $rep (@rep_listing) {
	for my $i (0..($number_of_categories-1)) {
	    $l10pvals{$rep}[$i] = "NaN|".$alldata_l10pvals{$ensg}{$rep}[$i];
	    $l2fcs{$rep}[$i] = "NaN";
	    if ($alldata{$ensg}{$rep}[$i] eq "NA") {
	    } else {
		$l10pvals{$rep}[$i] = $alldata{$ensg}{$rep}[$i]."|".$alldata_l10pvals{$ensg}{$rep}[$i];
		$l2fcs{$rep}[$i] = $alldata{$ensg}{$rep}[$i];

	    }
	}
    }
    
    print LOUT "$ensg";
    print POUT "$ensg";
    for my $rep (@rep_listing) {
	print POUT "\t".join("\t",@{$l10pvals{$rep}});
	print LOUT "\t".join("\t",@{$l2fcs{$rep}});
    }
    print POUT "\n";
    print LOUT "\n";
}
close(POUT);
close(LOUT);
	
#my $pval_fi = $readcount_fi.".l2fcwithpval_enr.csv";
#system("perl /home/elvannostrand/data/clip/CLIPseq_analysis/scripts/regionlevelanalysis_GOanalysisonl2fc.pl $pval_fi");


sub stats {
    my $ref = shift;
    my @array = @$ref;
    my @nums = sort {$a <=> $b} @array;
    my $sum = 0;
    foreach my $nn (@nums) { $sum += $nn; }
    my $n = scalar(@nums);
    return($sum,$sum) if ($n == 1 || $n == 0);
    my $mean = $sum/$n;
    my $average_deviation = 0;
    my $standard_deviation = 0;
    my $variance = 0;
    my $skew = 0;
    my $kurtosis = 0;
    foreach (@nums) {
        my $deviation = $_ - $mean;
        $average_deviation += abs($deviation);
        $variance += $deviation**2;
        $skew += $deviation**3;
        $kurtosis += $deviation**4;
    }
    $average_deviation /= $n;
    $variance /= ($n - 1);

    $standard_deviation = sqrt($variance);

    if ($variance) {
        $skew /= ($n * $variance * $standard_deviation);
        $kurtosis = $kurtosis/($n * $variance * $variance) - 3.0;
    }


    my $mid = int($n/2);
    my $median = ($n % 2) ? $nums[$mid] : ($nums[$mid] + $nums[$mid-1])/2;

    my $first = $nums[int($n/4)];
    my $third = $nums[int(3* $n /4)];



    #printf("n:                  %d\n", $n);    
    #printf("median:             %f\n", $median);                
    #printf("mean:               %f\n", $mean); 
    #printf("average_deviation:  %f\n", $average_deviation);     
    #printf("standard_deviation: %f\n", $standard_deviation);    
    #printf("variance:           %f\n", $variance);              
    #printf("skew:               %f\n", $skew); 
    #printf("kurtosis:           %f\n", $kurtosis);          
    #    return($n,$median,$mean,$average_deviation, $standard_deviation, $variance, $skew, $kurtosis);     

    return($mean,$median,$standard_deviation,$skew,$kurtosis,$first,$third);
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


sub fisher_or_chisq {
    my ($a,$b,$c,$d) = @_;
    unless ($a && $b && $c && $d) {
#        return("1","NA","NA");
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
        if (exists $precalculated_fisher{$a."|".$b."|".$c."|".$d}) {
            return($precalculated_fisher{$a."|".$b."|".$c."|".$d}{p},$precalculated_fisher{$a."|".$b."|".$c."|".$d}{v},"F",$direction);
        } else {
            my ($pval,$val) = &fisher_exact($a,$b,$c,$d);
            $precalculated_fisher{$a."|".$b."|".$c."|".$d}{p} = $pval;
            $precalculated_fisher{$a."|".$b."|".$c."|".$d}{v} = $val;
            return($pval,$val,"F",$direction);
        }
    } else {
        my ($pval,$val) = &chi_square($a,$b,$c,$d);
        return($pval,$val,"C",$direction);
    }
}


sub chi_square {
    my ($a,$b,$c,$d) = @_;
    #    print "$a\t$b\t$c\t$d\t";
    return(0) unless ($a && $b && $c && $d);
    #    $b = $b-$a;
    #    $c = $c-$a;
    #    $d = $d-$c-$b-$a;
    #    $d = $d - $c;

#        print "$a\t$b\t$c\t$d\t";
#    if ($a >= 5 && $b >= 5 && $c >= 5 && $d >= 5 ){
    my $tot = $a + $b + $c + $d;
    my $expa = ($a+$c)*($a+$b)/$tot;
    my $expb = ($b+$d)*($a+$b)/$tot;
    my $expc = ($a+$c)*($c+$d)/$tot;
    my $expd = ($b+$d)*($c+$d)/$tot;
    
    if ($expa >= 5 || $expb >= 5 || $expc >= 5 || $expd >= 5) {
        my $chival = &square(&abs($a-$expa)-0.5)/$expa +  &square(&abs($b-$expb)-0.5)/$expb + &square(&abs($c-$expc)-0.5)/$expc + &square(&abs($d-$expd)-0.5)/$expd;
        
        my $pval = Statistics::Distributions::chisqrprob(1,&abs($chival));

        if ($a<$expa) {
            $chival = $chival * -1;
        }
        return ($pval,$chival);
    } else {
         #       print "\n";
        print STDERR "shouldn't get to this - should have been shunted into fisher exact test\n";
        return(1);
    }
}

sub fisher_exact {
    my ($x1,$x2,$y1,$y2) = @_;
    #Run fisher exact test in R                                                                                                                                       

    $R->run("rm(list = ls())");
    $R->run("blah <- matrix(c(".$x1.",".$x2.",".$y1.",".$y2."),nrow=2)");
    $R->run("foo <- fisher.test(blah)");
    my $p_value_vs_bgd = $R->get('foo$p.value');
    my $val = "F";
    return($p_value_vs_bgd,$val);
}
