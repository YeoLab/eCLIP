#!/usr/bin/env perl

use warnings;
use strict;

#2018-03-05 - editing to re-order mult-ensts to remove odd randomness

my $hashing_value = 100000;
my %enst2gene;
my %enst2ensg;
my %ensg2name;

my %enst2chrstr;
# my $chrM_genelistfi = "/home/elvannostrand/data/clip/CLIPseq_analysis/RNA_type_analysis/genelists.chrM.wchr.txt";
my $chrM_genelistfi = $ARGV[1];
my $filelist_file = $ARGV[2];
my $filelist_file2 = $ARGV[3];
my $mirbase_fi = $ARGV[4];

open(CHR,$chrM_genelistfi);
for my $line (<CHR>) {
    chomp($line);
    my ($ensg,$genename,$enst,$chr,$str) = split(/\t/,$line);
    $enst2chrstr{$enst}{chr} = $chr;
    $enst2chrstr{$enst}{str} = $str;
}
close(CHR);


my %convert_enst2type;
my %convert_enst2priority;
# my $filelist_file = "/home/elvannostrand/data/clip/CLIPseq_analysis/RNA_type_analysis/MASTER_filelist.wrepbaseandtRNA.enst2id.fixed.UpdatedSimpleRepeat";
&read_in_filelists($filelist_file);

# my $filelist_file2 = "/home/elvannostrand/data/clip/CLIPseq_analysis/RNA_type_analysis/ALLRepBase_elements.id_table.FULL";
&read_in_filelists($filelist_file2);

my %gencode_features;
# my $mirbase_fi = "/home/elvannostrand/data/clip/CLIPseq_analysis/RNA_type_analysis/mirbase.v20.hg19.gff3";
&read_mirbase($mirbase_fi);

my %convert_strand = ("+" => "-", "-" => "+");


my %count;
my %count_enst;
my ($total_unique_mapped_read_num,$rep_family_reads,$unique_genomic) = (0,0,0);
my $fi = $ARGV[0];
my $output_fi = $ARGV[5]; # $fi.".chrM_updatedparsed_miR.20180414sorted";
open(OUT,">$output_fi");
open(FI,"gunzip -c $fi |");
while (<FI>) {
    chomp($_);
    my $r1 = $_;
    my @tmp_r1 = split(/\t/,$r1);

    my $r1sam_flag = $tmp_r1[1];
    my $frag_strand;

    next if ($r1sam_flag == 4);

### This section is for only properly paired reads                                                                      
    if ($r1sam_flag == 16 || $r1sam_flag == 272) {
        $frag_strand = "-";
    } elsif ($r1sam_flag eq "0" || $r1sam_flag == 256) {
        $frag_strand = "+";
    }  else {
        next;
        print STDERR "R1 strand error $r1sam_flag\n";
    }


    my $repmap_info = pop(@tmp_r1);
    my $type = pop(@tmp_r1);
    my $mult_transcripts = pop(@tmp_r1);

    my ($ensttype,$mult_ensts) = split(/\|\|/,$repmap_info);
    my $r1_chr = $tmp_r1[2];

    if ($type eq "RepFamily" && ($r1_chr =~ /^chrM\|\|/ || $r1_chr =~ /^antisense_chrM\|\|/)) {
	my ($r1_chronly,$r1_repelement) = split(/\|\|/,$r1_chr);
	my $relative_strand = "+";
        if ($r1_repelement =~ /^antisense\_(.+)$/) {
            $r1_repelement = $1;
            $relative_strand = "-";
        }
	
        if ($r1_repelement =~ /^(.+)\_DOUBLEMAP$/ || $r1_repelement =~ /^antisense\_(.+)\_DOUBLEMAP$/) {
            $r1_repelement = $1;
        }
        my $absolute_strand = $enst2chrstr{$r1_repelement}{str};
        if ($relative_strand eq "-") {
            $absolute_strand = $convert_strand{$absolute_strand};
        }
	
	$ensttype = "chrMreprocess_".$absolute_strand."strand";
	
        $unique_genomic++;

    } elsif ($type eq "RepFamily") {
	if ($mult_transcripts =~ /ZZ\:Z\:(.+)$/) {
	    $mult_ensts = $1;
	} else {
	    print STDERR "error $r1\n";
	}
	$rep_family_reads++;

	my @all_transcripts = split(/\|/,$mult_ensts);
	my ($primary_output,$full_output) = &reorder_transcripts_by_priority(\@all_transcripts);
	($ensttype,$mult_ensts) = split(/\|\|/,$full_output);
	
    } elsif ($type eq "UniqueGenomic") {
	if ($r1_chr eq "chrM") {
	    $ensttype = "chrMreprocess_".$frag_strand."strand";
	}
        my $r1_start = $tmp_r1[3];
        my $r1_cigar = $tmp_r1[5];
	my @read_regions = &parse_cigar_string($r1_start,$r1_cigar,$r1_chr,$frag_strand);

	my $read1_start_position;
	if ($frag_strand eq "+") {
	    $read1_start_position = $r1_start;
	} elsif ($frag_strand eq "-") {
	    my $last_region = $read_regions[$#read_regions];
	    my ($rchr,$rstr,$rpos) = split(/\:/,$last_region);
	    my ($rstart,$rstop) = split(/\-/,$rpos);
	    $read1_start_position = $rstop - 1;
	} else {
	    print STDERR "error $frag_strand\n";
	}

	my $feature_flag = 0;
	my %tmp_gencode_hash;
	
	my $rx = int($read1_start_position / $hashing_value);
	for my $gencode (@{$gencode_features{$r1_chr}{$frag_strand}{$rx}}) {
	    my ($gencode_enst,$gencode_type,$gencode_region) = split(/\|/,$gencode);
	    my ($gencode_start,$gencode_stop) = split(/\-/,$gencode_region);

	    next if ($read1_start_position < $gencode_start);
	    next if ($read1_start_position >= $gencode_stop);
	    my $gencode_ensg = $enst2ensg{$gencode_enst};
	    $tmp_gencode_hash{$gencode_type}{$gencode_ensg}="contained";
	    $feature_flag = 1;

	}

	if ($feature_flag == 1) {
	    my $final_feature_type;
	    if (exists $tmp_gencode_hash{"miRNA"}) {
		my $feature_type_flag = &get_type_flag(\%tmp_gencode_hash,"miRNA");
		$final_feature_type = "miRNA";
	    } elsif (exists $tmp_gencode_hash{"miRNA-proximal"}) {
		my $feature_type_flag = &get_type_flag(\%tmp_gencode_hash,"miRNA-proximal");
		$final_feature_type = "miRNA-proximal";
	    } else {
		print STDERR "this shouldn't be hit $r1\n";
	    }
	    
	    $ensttype = $final_feature_type;
	    $mult_ensts = join("|",keys %{$tmp_gencode_hash{$final_feature_type}});
	}

	$unique_genomic++;
    } else {
	print STDERR "error - this shouldn't happen $r1\n";
    }	

    if ($ensttype =~ /Simple\_repeat/) {
	$ensttype = "Simple_repeat";
    }
    
    $count{$ensttype}++;
    $count_enst{$ensttype."||".$mult_ensts}++;
    $total_unique_mapped_read_num++

}

print OUT "#READINFO\tUsableReads\t".$total_unique_mapped_read_num."\n";
print OUT "#READINFO\tGenomicReads\t".$unique_genomic."\t".sprintf("%.5f",$unique_genomic/$total_unique_mapped_read_num)."\n";
print OUT "#READINFO\tRepFamilyReads\t".$rep_family_reads."\t".sprintf("%.5f",$rep_family_reads/$total_unique_mapped_read_num)."\n";

my @sorted_total = sort {$count{$b} <=> $count{$a}} keys %count;
for my $k (@sorted_total) {
    print OUT "TOTAL\t$k\t$count{$k}\t".sprintf("%.5f",$count{$k} * 1000000 / $total_unique_mapped_read_num)."\n";
}

my @sorted = sort {$count_enst{$b} <=> $count_enst{$a}} keys %count_enst;
for my $s (@sorted) {
    my ($ensttype,$multensts) = split(/\|\|/,$s);
    my @multensts_split = split(/\|/,$multensts);
    my @genes_final;
    my $type = $ensttype;
    for my $multensts_group (@multensts_split) {
	my @gids = split(/\;\;/,$multensts_group);

	my @genes_short;
	for my $gid (@gids) {
	    if (exists $enst2gene{$gid}) {
		push @genes_short,$enst2gene{$gid};
	    } else {
		push @genes_short,$gid;
	    }
	}
	push @genes_final,join(";;",@genes_short);
    }

    my ($ensg_primary,$readnum,$rpm,$enst_all,$ensg_all) = ($type,$count_enst{$s},sprintf("%.5f",$count_enst{$s} * 1000000 / $total_unique_mapped_read_num),$s,join("|",@genes_final));

    
    print OUT "ELEMENT\t".$ensg_primary."\t".$readnum."\t".$rpm."\t".$enst_all."\t".$ensg_all."\n";
}

sub reorder_transcripts_by_priority {
    my $enst_ref = shift;
    my @enst_list = @$enst_ref;
    
    my %reptype_hash;
    for my $enst_id_orig (@enst_list) {
	my $enst_id = $enst_id_orig;
	$enst_id =~ s/\_DOUBLEMAP$//;
	$enst_id =~ s/\_spliced$//;	
	$enst_id =~ s/\_$//;
	$enst_id = lc($enst_id);
	unless (exists $convert_enst2priority{$enst_id} && $convert_enst2priority{$enst_id}) {
	    print STDERR "err $enst_id $enst_id_orig$convert_enst2priority{$enst_id}\n";
	}
	my ($rep_type,$priority_n) = split(/\|/,$convert_enst2priority{$enst_id});
	$reptype_hash{$rep_type}{$enst_id_orig} = $priority_n;
    }
    
    my @sorted_reptypes = sort {$a cmp $b} keys %reptype_hash;
    my @sorted_ensts_bytype;
    my @sorted_topenst_bytype;
    for my $sorted_reptype (@sorted_reptypes) {
	my @sorted_ensts_by_priority = sort {$reptype_hash{$sorted_reptype}{$a} <=> $reptype_hash{$sorted_reptype}{$b}} keys %{$reptype_hash{$sorted_reptype}};
	my $reptype_joined = join(";;",@sorted_ensts_by_priority);
	push @sorted_ensts_bytype,$reptype_joined;
	push @sorted_topenst_bytype,$sorted_ensts_by_priority[0];
    }
    my $output_mult_ensts = join("|",@sorted_ensts_bytype);
    my $output_top_ensts = join("|",@sorted_topenst_bytype);
    my $output_types = join("|",@sorted_reptypes);

    my $primary_output = $output_types."||".$output_top_ensts;       
    my $full_output = $output_types."||".$output_mult_ensts;
    return($primary_output,$full_output);
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
#            push @regions,$chr.":".$strand.":".$region_start_pos."-".($current_pos-1);                                                                                                              
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
#           push @read_regions,$chr.":".$current_pos."-".($current_pos+=$1);                                                                                                                         
            $current_pos += $1;
            #read has deletion relative to genome; genome position has to increase                                                                                                                   
        } else {
            print STDERR "flag $1 $2 $flags\n";

        }
    }
    push @regions,$chr.":".$strand.":".($region_start_pos-1)."-".($current_pos-1);

    return(@regions);
}


sub read_in_filelists {
    my $fi = shift;
    my $priority_n = 0;
    my %corrected_ensts;
    open(F,$fi);
    for my $line (<F>) {
        chomp($line);
        my ($allenst,$allensg,$gid,$type_label,$typefile) = split(/\t/,$line);
#       my ($allensg,$gid,$allenst) = split(/\t/,$line);                                                                                                                       
	unless ($allenst) {
            print STDERR "error missing enst $line $fi\n";
        }
	$allenst = uc($allenst);
        my @ensts = split(/\|/,$allenst);
	$gid =~ s/\?$//;
        $gid =~ s/\_$//;
        $type_label =~ s/\?$//;
        for my $enst (@ensts) {
            if ($enst =~ /\_$/) {
                $corrected_ensts{$enst}++;
                $enst =~ s/\_$//;
            }
            $enst2gene{$enst} = $gid;
            $enst2gene{"antisense_".$enst} = "antisense_".$gid;
#            $convert_enst2type{$enst} = $type_label.":".$priority_n;                                                                                                          
#            $convert_enst2type{$enst."_antisense"} = $type_label."_antisense:".$priority_n;                                                                                   
            $convert_enst2type{$enst} = $type_label;
	    $convert_enst2type{"antisense_".$enst} = "antisense_".$type_label;
	    $convert_enst2priority{lc($enst)} = $type_label."|".$priority_n;
	    $convert_enst2priority{"antisense_".lc($enst)} = "antisense_".$type_label."|".$priority_n;
#	    print STDERR "enst $enst ".$type_label."|".$priority_n."\n";
            $priority_n++;
	}
    }
    close(F);
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
#                print STDERR "feature $feature $chr $gname $str\n" if ($gname =~ /mir-21$/);
                for my $j ($x..$y) {
                    push @{$gencode_features{$chr}{$str}{$j}},$feature;
                }

                my $prox_upregion = ($start-500)."|".$start;
                my $prox_dnregion = ($stop)."|".($stop+500);
                for my $proxregion ($prox_upregion,$prox_dnregion) {
                    my ($prox_start,$prox_stop) = split(/\|/,$proxregion);

                    my $prox_x = int($prox_start / $hashing_value);
                    my $prox_y = int($prox_stop  / $hashing_value);

                    my $prox_feature = $id."|miRNA-proximal|".$prox_start."-".$prox_stop;

                    for my $j ($prox_x..$prox_y) {
                        push @{$gencode_features{$chr}{$str}{$j}},$prox_feature;
                    }
                }

            } else {
                print STDERR "didn't parse this properly $tmp[8] $line\n";
            }
        }
    }
    close(MIR);
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




