use warnings;
use strict;

# 2015/11/12 - fixed to deal with ucsc table format (0-based, open ended) vs peaks (0-based, open ended)
# & add genome (mm9) option
# 2016/11/30 - changed annotation structure - now prioritizes coding regions over non-coding within an ensg (ie prioritizes protein coding ensts over non-coding ensts), but then prioritizes a non-coding exon ENSG over a coding intron ENSG - should catch things like intronic miRs better
# 2019/08/06 - removed hardcoded annotation files to be compatible with pipeline

my $verbose_flag = 0;
my $hashing_value = 100000;

my $window_size = 100;

my %all_features;
my %enst2type;
my %enst2ensg;
my %ensg2name;
my %ensg2type;


#defaults to hg19                                                                                                                                                                                        
my $species = "hg19";
if (exists $ARGV[1]) {
    $species = $ARGV[1];
}

my $trna_bed = "/home/elvannostrand/data/clip/CLIPseq_analysis/scripts/hg19-tRNAs.bed";
my $gencode_gtf_file = "/projects/ps-yeolab/genomes/hg19/gencode_v19/gencode.v19.chr_patch_hapl_scaff.annotation.gtf";
my $gencode_tablebrowser_file = "/projects/ps-yeolab/genomes/hg19/gencode_v19/gencode.v19.chr_patch_hapl_scaff.annotation.gtf.parsed_ucsc_tableformat";
#my $gencode_tablebrowser_file = "/projects/ps-yeolab/genomes/hg19/gencode_v19/gencodev19_comprehensive";  
my $mirbase_fi = "/home/elvannostrand/data/clip/CLIPseq_analysis/RNA_type_analysis/mirbase.v20.hg19.gff3";                            
my $lncrna_tablefile = "/home/elvannostrand/data/clip/CLIPseq_analysis/lncRNAs/lncipedia_5_0_hg19.bed.parsed_ucsc_tableformat";
my $lncrna_fullfi = "/home/elvannostrand/data/clip/CLIPseq_analysis/lncRNAs/lncipedia_5_0_hg19.gff.parsed";
my $gtf_proteincoding_flag = "no";             
if ($species eq "hg19") {
} elsif ($species eq "mm9") {
    $trna_bed = "/home/elvannostrand/data/clip/CLIPseq_analysis/scripts/mm9-tRNAs.bed";
    $gencode_gtf_file = "/projects/ps-yeolab/genomes/mm9/gencode.vM1.annotation.gtf";
    $gencode_tablebrowser_file = "/projects/ps-yeolab/genomes/mm9/gencode.vM1.annotation.gtf.parsed_ucsc_tableformat";
} elsif ($species eq "mm10") {
    $trna_bed = "/home/elvannostrand/data/clip/CLIPseq_analysis/scripts/mm10-tRNAs.bed";
    $gencode_gtf_file = "/projects/ps-yeolab/genomes/mm10/gencode/gencode.vM15.chr_patch_hapl_scaff.annotation.gtf";
    $gencode_tablebrowser_file = "/projects/ps-yeolab/genomes/mm10/gencode/gencode.vM15.chr_patch_hapl_scaff.annotation.gtf.parsed_ucsc_tableformat";
} elsif ($species eq "hg38") {
    $trna_bed = "/home/elvannostrand/data/clip/CLIPseq_analysis/scripts/hg38-tRNAs.bed";
    $gencode_gtf_file = "/projects/ps-yeolab/genomes/GRCh38/gencode/v26/gencode.v26.chr_patch_hapl_scaff.annotation.gtf";
    $gencode_tablebrowser_file = "/projects/ps-yeolab/genomes/GRCh38/gencode/v26/gencode.v26.chr_patch_hapl_scaff.annotation.gtf.parsed_ucsc_tableformat";
    $mirbase_fi = "/home/elvannostrand/data/clip/CLIPseq_analysis/RNA_type_analysis/mirbase.v21.hg38.gff3";
    $lncrna_tablefile = "/home/elvannostrand/data/clip/CLIPseq_analysis/lncRNAs/lncipedia_5_0_hg38.bed.parsed_ucsc_tableformat";
    $lncrna_fullfi = "/home/elvannostrand/data/clip/CLIPseq_analysis/lncRNAs/lncipedia_5_0_hg38.gff.parsed";

} elsif ($species eq "rn6") {
    $gencode_gtf_file = "/home/elvannostrand/RN6.gtf";
    $gencode_tablebrowser_file = "/home/elvannostrand/RN6.refGene.table";
    $mirbase_fi = "/home/elvannostrand/rn6_mirbase.gff3";
    $gtf_proteincoding_flag = "all_protein_coding";
    $lncrna_tablefile = "";
    $lncrna_fullfi = "";
    $trna_bed = "";
} else {
    die "species $species not implemented\n";
}
&read_lncrna_parsed($lncrna_fullfi) if ($lncrna_fullfi);
&read_mirbase($mirbase_fi);

&read_gencode_gtf($gencode_gtf_file,$gtf_proteincoding_flag);
&read_gencode($gencode_tablebrowser_file);
&read_gencode($lncrna_tablefile) if ($lncrna_tablefile);

&parse_trna_list($trna_bed) if ($trna_bed);

my $peak_fi = $ARGV[0];
my $output = $peak_fi.".annotated_proxdist_miRlncRNA";
open(OUT,">$output");
&read_peak_fi($peak_fi);
close(OUT);

sub parse_trna_list {
    my $trna_fi = shift;
    open(TRNA,$trna_fi);
    for my $line (<TRNA>) {
        chomp($line);
        my @tmp = split(/\t/,$line);
        my $chr = $tmp[0];
        # trna file is 1 based closed ended - shifting to bed format [0 base open ended) here                                                                                            
        my $start = $tmp[1]-1;
        my $stop = $tmp[2];
        my $str = $tmp[5];
        my $id = $tmp[3];

        my $x = int($start/$hashing_value);
        my $y = int($stop /$hashing_value);

        my $feature = $id."|tRNA|".$start."-".$stop;
	$enst2ensg{$id}= $id;
        $ensg2name{$id}{$id} = 1;

        for my $j ($x..$y) {
            push @{$all_features{$chr}{$str}{$j}},$feature;
        }
    }
    close(TRNA);

}

sub read_mirbase {
    my $mirbase_file = shift;
    open(MIR,$mirbase_fi);
    for my $line (<MIR>) {
        chomp($line);
	$line =~ s/\r//g;
        next if ($line =~ /^\#/);
        my @tmp = split(/\t/,$line);
        if ($tmp[2] eq "miRNA_primary_transcript") {
            my $chr = $tmp[0];
            my $start = $tmp[3]-1;
            my $stop = $tmp[4];
            my $str = $tmp[6];

            if ($tmp[8]=~ /ID\=(\S+?)\;.+Name\=(\S+?)$/ || $tmp[8] =~ /ID\=(\S+?)\;.+Name\=(\S+?)\;/) {
                my $id = $1;
                my $gname = $2;

                my $x = int($start/$hashing_value);
                my $y = int($stop /$hashing_value);

                my $feature = $id."|miRNA|".$start."-".$stop;
                $enst2ensg{$id} = $id;
                $ensg2name{$id}{$gname} = 1;
		print STDERR "feature $feature $chr $gname $str\n" if ($gname =~ /mir-21$/);
                for my $j ($x..$y) {
                    push @{$all_features{$chr}{$str}{$j}},$feature;
                }

                my $prox_upregion = ($start-500)."|".$start;
                my $prox_dnregion = ($stop)."|".($stop+500);
                for my $proxregion ($prox_upregion,$prox_dnregion) {
                    my ($prox_start,$prox_stop) = split(/\|/,$proxregion);

                    my $prox_x = int($prox_start / $hashing_value);
                    my $prox_y = int($prox_stop  / $hashing_value);

                    my $prox_feature = $id."|miRNA_proximal|".$prox_start."-".$prox_stop;

                    for my $j ($prox_x..$prox_y) {
                        push @{$all_features{$chr}{$str}{$j}},$prox_feature;
                    }
                }

            } else {
                print STDERR "didn't parse this properly $tmp[8] $line\n";
            }
        }
    }
    close(MIR);
}


sub read_peak_fi {
    my $peakfi = shift;
    print STDERR "reading $peakfi\n";
    open(PEAK,$peakfi) || die "no peakfi $peakfi\n";
    for my $line (<PEAK>) {
	chomp($line);
	my @tmp = split(/\t/,$line);
	my $chr = $tmp[0];
	my $str = $tmp[5];
	my $start = $tmp[1];
	my $stop = $tmp[2];
#	my ($origchr,$origpos,$str,$orig_pval) = split(/\:/,$tmp[3]);

	my $debug_flag = 0;
#	$debug_flag = 1 if ($start == 149420331);
	
	my %tmp_hash;
	my %tmp_hash2;
	my $feature_flag = 0;

	my $rx = int($start / $hashing_value);
	my $ry = int($stop  / $hashing_value);
	for my $ri ($rx..$ry) {
	    for my $feature (@{$all_features{$chr}{$str}{$ri}}) {
		my ($feature_enst,$feature_type,$feature_region) = split(/\|/,$feature);
		my ($feature_start,$feature_stop) = split(/\-/,$feature_region);

		next if ($stop <= $feature_start);
		next if ($start >= $feature_stop);

		if ($feature_start <= $start && $stop <= $feature_stop) {
                        # peak is entirely within region                                                                                                                                                                                                         
		    my $feature_ensg = $enst2ensg{$feature_enst};
		    $tmp_hash{$feature_ensg}{$feature_type}="contained";
		    for my $jj ($start..($stop-1)) {
                        $tmp_hash2{$jj}{$feature_ensg}{$feature_type}="contained";
                        print "found feature $_ $feature $feature_ensg $feature_type\n" if ($verbose_flag == 1);
                    }

		    $feature_flag = 1;
		    print "found feature $_ $feature $feature_ensg $feature_type\n" if ($verbose_flag == 1);
		} elsif (($feature_start >= $start && $feature_start < $stop) || ($feature_stop > $start && $feature_stop <= $stop)) {
		    # peak is partly overlapping feature
                    my $feature_ensg = $enst2ensg{$feature_enst};
		    $tmp_hash{$feature_ensg}{$feature_type}="partial";
		    $feature_flag = 1;
		    my $overlap_min = &max($feature_start,$start);
                    my $overlap_max = &min($feature_stop,$stop);
                    for my $jj ($overlap_min..$overlap_max) {
                        $tmp_hash2{$jj}{$feature_ensg}{$feature_type}="partial";
                    }

		} elsif ($start <= $feature_start && $stop >= $feature_stop) {
		    # feature is contained within peak
		    my $feature_ensg = $enst2ensg{$feature_enst};
		    $tmp_hash{$feature_ensg}{$feature_type}="featurewithin";
		    $feature_flag = 1;
		    for my $jj ($feature_start..$feature_stop) {
                        $tmp_hash2{$jj}{$feature_ensg}{$feature_type}="featurewithin";
                    }
		}

	    }
	}

	if ($debug_flag == 1) {
	    for my $k (keys %tmp_hash) {
		for my $e (keys %{$tmp_hash{$k}}) {
		    print "$k\t$e\t$tmp_hash{$k}{$e}\n";
		}
	    }
	}
	
	my @toprint;
	my %ensg2featuretype;
	my %featuretype2ensg;
	for my $overlapped_ensg (keys %tmp_hash) {
	  TYPELOOP:	    for my $feature_type ("tRNA","miRNA","miRNA_proximal","CDS","3utr","5utr","5ss","3ss","proxintron","distintron","noncoding_exon","noncoding_5ss","noncoding_3ss","noncoding_proxintron","noncoding_distintron") {
	      if (exists $tmp_hash{$overlapped_ensg}{$feature_type}) {
		    $featuretype2ensg{$feature_type}{$overlapped_ensg} = 1;
		    $ensg2featuretype{$overlapped_ensg}{type} = $feature_type;
		    $ensg2featuretype{$overlapped_ensg}{flag} = &get_type_flag(\%tmp_hash,$feature_type);
		    last TYPELOOP;
	      }
	  }
	    push @toprint,$ensg2featuretype{$overlapped_ensg}{type}.";".$overlapped_ensg;
	}
	my $all_ensg_overlap = "NA";
	if (exists $toprint[0]) {
	    $all_ensg_overlap = join("||",@toprint);
	}
	

	my $final_feature_type = "intergenic";
	my $final_feature_ensg = "NA";
	
      TYPELOOPB:           for my $feature_type ("tRNA","miRNA","CDS","3utr","5utr","miRNA_proximal","noncoding_exon","5ss","noncoding_5ss","3ss","noncoding_3ss","proxintron","noncoding_proxintron","distintron","noncoding_distintron") {
	  if (exists $featuretype2ensg{$feature_type}) {
	      
	      $final_feature_type = $feature_type."||".join("||",keys %{$featuretype2ensg{$feature_type}});
	      $final_feature_ensg = join("||",keys %{$featuretype2ensg{$feature_type}});
	      last TYPELOOPB;
	  }
      }


	my %final_feature_type;
        my %final_feature_ensg;
        my %final_feature_type_sum;
        for my $jj ($start..($stop-1)) {
#            my %ensg2featuretype2;
            my %featuretype2ensg2;

            for my $overlapped_ensg (keys %{$tmp_hash2{$jj}}) {
              TYPELOOP:     for my $feature_type ("tRNA","miRNA","miRNA_proximal","CDS","3utr","5utr","5ss","3ss","proxintron","distintron","noncoding_exon","noncoding_5ss","noncoding_3ss","noncoding_proxintron","noncoding_distintron") {
                  if (exists $tmp_hash2{$jj}{$overlapped_ensg}{$feature_type}) {
                      $featuretype2ensg2{$feature_type}{$overlapped_ensg} = 1;
#                     $ensg2featuretype2{$overlapped_ensg}{type} = $feature_type;
#                     $ensg2featuretype2{$overlapped_ensg}{flag} = &get_type_flag(\%tmp_hash2,$feature_type);
                      last TYPELOOP;
                  }
              }
            }

            $final_feature_type{$jj} = "intergenic";
            $final_feature_ensg{$jj} = "NA";

            my $saved_final_feature_type = "intergenic";
          TYPELOOPB:           for my $feature_type ("tRNA","miRNA","CDS","3utr","5utr","miRNA_proximal","noncoding_exon","5ss","noncoding_5ss","3ss","noncoding_3ss","proxintron","noncoding_proxintron","distintron","noncoding_distintron") {
              if (exists $featuretype2ensg2{$feature_type}) {
#                  $final_feature_type{$jj} = $feature_type."||".join("||",keys %{$featuretype2ensg2{$feature_type}});
#                  $final_feature_ensg{$jj} = join("||",keys %{$featuretype2ensg2{$feature_type}});
                  $saved_final_feature_type = $feature_type;
                  last TYPELOOPB;
              }

          }
            $final_feature_type_sum{$saved_final_feature_type}++;

        }

	
	my @toprint2;
        for my $feature_type (keys %final_feature_type_sum) {
            push @toprint2,$feature_type."|".$final_feature_type_sum{$feature_type};
        }

        my @final_ensgs = split(/\|\|/,$final_feature_ensg);
        my %final_genenames;
        for my $final_ensg (@final_ensgs) {
            for my $gname (keys %{$ensg2name{$final_ensg}}) {
                $final_genenames{$gname} = 1;
            }
        }

	print OUT "$line\t$all_ensg_overlap\t$final_feature_type\t$final_feature_ensg\t".join("|",keys %final_genenames)."\t".join("||",@toprint2)."\n";
	
    }
    close(PEAK);
}





sub get_type_flag {
    my $ref = shift;
    my %feature_hash = %$ref;
    my $feature_type = shift;

    my $feature_type_final = "contained";
    for my $ensg (keys %{$feature_hash{$feature_type}}) {
	$feature_type_final = "partial" unless ($feature_hash{$feature_type}{$ensg} eq "contained");
    }
    return($feature_type_final);
}


sub read_gencode {
    ## eric note: this has been tested for off-by-1 issues with ucsc brower table output!                                                                                                                                                              
    my $fi = shift;
#    my $fi = "/projects/ps-yeolab/genomes/hg19/gencode_v19/gencodev19_comprehensive";
    print STDERR "reading in $fi\n";
    open(F,$fi);
    while (<F>) {
        chomp($_);
        my @tmp = split(/\t/,$_);
        my $enst = $tmp[1];
        next if ($enst eq "name");
        my $chr = $tmp[2];
        my $str = $tmp[3];
        my $txstart = $tmp[4];
        my $txstop = $tmp[5];
        my $cdsstart = $tmp[6];
        my $cdsstop = $tmp[7];

        my @starts = split(/\,/,$tmp[9]);
        my @stops = split(/\,/,$tmp[10]);

        my @tmp_features;

        my $transcript_type = $enst2type{$enst};
        unless ($transcript_type) {
            print STDERR "error transcript_type $transcript_type $enst\n";
        }
        if ($transcript_type eq "protein_coding") {

            for (my $i=0;$i<@starts;$i++) {
                if ($str eq "+") {
                    if ($stops[$i] < $cdsstart) {
                        # exon is all 5' utr                                                                                                                                                                                                                  
                        push @tmp_features,$enst."|5utr|".($starts[$i])."-".$stops[$i];
                    } elsif ($starts[$i] > $cdsstop) {
                        #exon is all 3' utr                                                                                                                                                                                                                   
                        push @tmp_features,$enst."|3utr|".($starts[$i])."-".$stops[$i];
                    } elsif ($starts[$i] > $cdsstart && $stops[$i] < $cdsstop) {
                        #exon is all coding                                                                                                                                                                                                                   
                        push @tmp_features,$enst."|CDS|".($starts[$i])."-".$stops[$i];
                    } else {
                        my $cdsregion_start = $starts[$i];
                        my $cdsregion_stop = $stops[$i];

                        if ($starts[$i] <= $cdsstart && $cdsstart <= $stops[$i]) {
                            #cdsstart is in exon                                                                                                                                                                                                              
                            my $five_region = ($starts[$i])."-".$cdsstart;
                            push @tmp_features,$enst."|5utr|".$five_region;
                            $cdsregion_start = $cdsstart;
                        }

                        if ($starts[$i] <= $cdsstop && $cdsstop <= $stops[$i]) {
                            #cdsstop is in exon                                                                                                                                                                                                               
                            my $three_region = ($cdsstop)."-".$stops[$i];
                            push @tmp_features,$enst."|3utr|".$three_region;
                            $cdsregion_stop = $cdsstop;
                        }

                        my $cds_region = ($cdsregion_start)."-".$cdsregion_stop;
                        push @tmp_features,$enst."|CDS|".$cds_region;
                    }
                } elsif ($str eq "-") {
		    if ($stops[$i] < $cdsstart) {
                        # exon is all 5' utr                                                                                                                                                                                                                  
                        push @tmp_features,$enst."|3utr|".($starts[$i])."-".$stops[$i];
                    } elsif ($starts[$i] > $cdsstop) {
                        #exon is all 3' utr                                                                                                                                                                                                                   
                        push @tmp_features,$enst."|5utr|".($starts[$i])."-".$stops[$i];
                    } elsif ($starts[$i] > $cdsstart &&$stops[$i] < $cdsstop) {
                        #exon is all coding                                                                                                                                                                                                                   
                        push @tmp_features,$enst."|CDS|".($starts[$i])."-".$stops[$i];
                    } else {
                        my $cdsregion_start = $starts[$i];
                        my $cdsregion_stop = $stops[$i];

                        if ($starts[$i] <= $cdsstart && $cdsstart <= $stops[$i]) {
                            #cdsstart is in exon                                                                                                                                                                                                              
                            my $three_region = ($starts[$i])."-".$cdsstart;
                            push @tmp_features,$enst."|3utr|".$three_region;
                            $cdsregion_start = $cdsstart;
                        }

                        if ($starts[$i] <= $cdsstop && $cdsstop <= $stops[$i]) {
                            #cdsstop is in exon                                                                                                                                                                                                               
                            my $five_region = ($cdsstop)."-".$stops[$i];
                            push @tmp_features,$enst."|5utr|".$five_region;
                            $cdsregion_stop = $cdsstop;
                        }

                        my $cds_region = ($cdsregion_start)."-".$cdsregion_stop;
                        push @tmp_features,$enst."|CDS|".$cds_region;
                    }
                }
            }
            for (my $i=0;$i<scalar(@starts)-1;$i++) {
		# full intron is ($stops[$i]+1)."-".$starts[$i+1]
		# prox is 500bp
		
		if ($starts[$i+1]-$stops[$i] > 2 * 500) {
		    if ($str eq "+") {
                        push @tmp_features,$enst."|5ss|".($stops[$i])."-".($stops[$i]+$window_size);
                        push @tmp_features,$enst."|3ss|".($starts[$i+1]-$window_size)."-".$starts[$i+1];
                    } elsif ($str eq "-") {
                        push @tmp_features,$enst."|3ss|".($stops[$i])."-".($stops[$i]+$window_size);
                        push @tmp_features,$enst."|5ss|".($starts[$i+1]-$window_size)."-".$starts[$i+1];
                    }


                    push @tmp_features,$enst."|proxintron|".($stops[$i]+$window_size)."-".($stops[$i]+500);
                    push @tmp_features,$enst."|proxintron|".($starts[$i+1]-500)."-".($starts[$i+1]-$window_size);
		    push @tmp_features,$enst."|distintron|".($stops[$i]+500)."-".($starts[$i+1]-500);
		} else {
		    my $midpoint = int(($starts[$i+1]+$stops[$i])/2);

		    if ($starts[$i+1]-$stops[$i] > 2 * $window_size) {
			push @tmp_features,$enst."|proxintron|".($stops[$i]+$window_size)."-".($starts[$i+1]-$window_size);

			if ($str eq "+") {
                            push @tmp_features,$enst."|5ss|".($stops[$i])."-".($stops[$i]+$window_size);
                            push @tmp_features,$enst."|3ss|".($starts[$i+1]-$window_size)."-".$starts[$i+1];
                        } elsif ($str eq "-") {
                            push @tmp_features,$enst."|3ss|".($stops[$i])."-".($stops[$i]+$window_size);
                            push @tmp_features,$enst."|5ss|".($starts[$i+1]-$window_size)."-".$starts[$i+1];
                        }
                    } else {
                        if ($str eq "+") {
                            push @tmp_features,$enst."|5ss|".($stops[$i])."-".($midpoint);
                            push @tmp_features,$enst."|3ss|".($midpoint)."-".$starts[$i+1];
                        } elsif ($str eq "-") {
                            push @tmp_features,$enst."|3ss|".($stops[$i])."-".($midpoint);
                            push @tmp_features,$enst."|5ss|".($midpoint)."-".$starts[$i+1];
                        }
                    }
		}
            }
        } else {

            for (my $i=0;$i<@starts;$i++) {
                push @tmp_features,$enst."|noncoding_exon|".($starts[$i])."-".$stops[$i];
            }
            for (my $i=0;$i<scalar(@starts)-1;$i++) {
		if ($starts[$i+1]-$stops[$i] > 2 * 500) {
                    if ($str eq "+") {
                        push @tmp_features,$enst."|noncoding_5ss|".($stops[$i])."-".($stops[$i]+$window_size);
                        push @tmp_features,$enst."|noncoding_3ss|".($starts[$i+1]-$window_size)."-".$starts[$i+1];
                    } elsif ($str eq "-") {
                        push @tmp_features,$enst."|noncoding_3ss|".($stops[$i])."-".($stops[$i]+$window_size);
                        push @tmp_features,$enst."|noncoding_5ss|".($starts[$i+1]-$window_size)."-".$starts[$i+1];
                    }


                    push @tmp_features,$enst."|noncoding_proxintron|".($stops[$i]+$window_size)."-".($stops[$i]+500);
                    push @tmp_features,$enst."|noncoding_proxintron|".($starts[$i+1]-500)."-".($starts[$i+1]-$window_size);
                    push @tmp_features,$enst."|noncoding_distintron|".($stops[$i]+500)."-".($starts[$i+1]-500);
                } else {
                    my $midpoint = int(($starts[$i+1]+$stops[$i])/2);

                    if ($starts[$i+1]-$stops[$i] > 2 * $window_size) {
			push @tmp_features,$enst."|noncoding_proxintron|".($stops[$i]+$window_size)."-".($starts[$i+1]-$window_size);

                        if ($str eq "+") {
                            push @tmp_features,$enst."|noncoding_5ss|".($stops[$i])."-".($stops[$i]+$window_size);
                            push @tmp_features,$enst."|noncoding_3ss|".($starts[$i+1]-$window_size)."-".$starts[$i+1];
                        } elsif ($str eq "-") {
                            push @tmp_features,$enst."|noncoding_3ss|".($stops[$i])."-".($stops[$i]+$window_size);
                            push @tmp_features,$enst."|noncoding_5ss|".($starts[$i+1]-$window_size)."-".$starts[$i+1];
                        }
                    } else {
                        if ($str eq "+") {
                            push @tmp_features,$enst."|noncoding_5ss|".($stops[$i])."-".($midpoint);
                            push @tmp_features,$enst."|noncoding_3ss|".($midpoint)."-".$starts[$i+1];
                        } elsif ($str eq "-") {
                            push @tmp_features,$enst."|noncoding_3ss|".($stops[$i])."-".($midpoint);
                            push @tmp_features,$enst."|noncoding_5ss|".($midpoint)."-".$starts[$i+1];
                        }
                    }
                }
            }
        }


        for my $feature (@tmp_features) {
            my ($enst,$type,$region) = split(/\|/,$feature);
            my ($reg_start,$reg_stop) = split(/\-/,$region);
            my $x = int($reg_start/$hashing_value);
            my $y = int($reg_stop /$hashing_value);

            for my $j ($x..$y) {
                push @{$all_features{$chr}{$str}{$j}},$feature;
            }
        }
    }
    close(F);
    
}


sub read_gencode_gtf {

    my $file = shift;
    my $all_protein_coding_flag = shift;
#    my $file = "/projects/ps-yeolab/genomes/hg19/gencode_v19/gencode.v19.chr_patch_hapl_scaff.annotation.gtf";
    print STDERR "Reading in $file\n";
    open(F,$file);
    for my $line (<F>) {
	chomp($line);
	next if ($line =~ /^\#/);
	my @tmp = split(/\t/,$line);

	my $stuff = $tmp[8];
	my @stufff = split(/\;/,$stuff);
	my ($ensg_id,$gene_type,$gene_name,$enst_id,$transcript_type);

	for my $s (@stufff) {
            $s =~ s/^\s//g;
            $s =~ s/\s$//g;

            if ($s =~ /gene_id \"(.+?)\"/) {
		if ($ensg_id) {
                    print STDERR "two ensg ids? $line\n";
		}
                $ensg_id = $1;
            }
            if ($s =~ /transcript_id \"(.+?)\"/) {
		if ($enst_id) {
                    print STDERR "two enst ids? $line\n";
		}
                $enst_id = $1;
            }
            if ($s =~ /gene_type \"(.+?)\"/) {
		if ($gene_type) {
                    print STDERR "two gene types $line\n";
		}
                $gene_type = $1;
		
            }

            if ($s =~ /transcript_type \"(.+?)\"/) {
		$transcript_type = $1;
            }
            if ($s =~ /gene_name \"(.+?)\"/) {
                $gene_name = $1;
            }
	}
	next unless ($enst_id);
	if (exists $enst2ensg{$enst_id} && $ensg_id ne $enst2ensg{$enst_id}) {
	    print STDERR "error two ensgs for enst $enst_id $ensg_id $enst2ensg{$enst_id}\n";
	}

	$transcript_type = "unknown" unless ($transcript_type);
	$gene_name = "unknown" unless ($gene_name);
	$gene_type = "unknown" unless ($gene_type);

	if ($all_protein_coding_flag eq "all_protein_coding") {
	    $gene_type = "protein_coding";
	    $transcript_type = "protein_coding";
	}

	$enst2ensg{$enst_id} = $ensg_id;
	$ensg2name{$ensg_id}{$gene_name}=1;
	$ensg2type{$ensg_id}{$gene_type}=1;
	$enst2type{$enst_id} = $transcript_type;
    }
    close(F);

}


sub read_lncrna_parsed {
    my $lncfi = shift;
    open(LN,$lncfi) || die "no $lncfi\n";
    for my $line (<LN>) {
        chomp($line);
        my @tmp = split(/\t/,$line);
        my $enst_id = $tmp[2];
        my $ensg_id = "lncRNA|".$tmp[1];
        
        my $gene_name = $tmp[1];
        my $transcript_type = "lncRNA";
        my $gene_type = "lncRNA";
        
        $enst2ensg{$enst_id} = $ensg_id;
        $ensg2name{$ensg_id}{$gene_name}=1;
        $ensg2type{$ensg_id}{$gene_type}=1;
        $enst2type{$enst_id} = $transcript_type;
        
    }
    close(LN);

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

sub min {
    my $x = shift;
    my $y = shift;
    if ($x < $y) {
        return($x);
    } else {
        return($y);
    }
}


