#!/usr/bin/env perl

use warnings;
use strict;

my %enst2gene;
my %convert_enst2type;
my %multimapping_hash;

my %rRNA_extra_hash;
my %rRNA_extra_hash_rev;
$rRNA_extra_hash{"RNA28S"} = "rRNA_extra";
$rRNA_extra_hash{"RNA18S"} = "rRNA_extra";
$rRNA_extra_hash{"RNA5-8S"} = "rRNA_extra";
$rRNA_extra_hash{"antisense_RNA28S"} = "antisense_rRNA_extra";
$rRNA_extra_hash{"antisense_RNA18S"} = "antisense_rRNA_extra";
$rRNA_extra_hash{"antisense_RNA5-8S"} = "antisense_rRNA_extra";

$rRNA_extra_hash_rev{"rRNA_extra"}{"RNA28S"} = 1;
$rRNA_extra_hash_rev{"rRNA_extra"}{"RNA18S"} = 1;
$rRNA_extra_hash_rev{"rRNA_extra"}{"RNA5-8S"} = 1;
$rRNA_extra_hash_rev{"antisense_rRNA_extra"}{"antisense_RNA28S"} = 1;
$rRNA_extra_hash_rev{"antisense_rRNA_extra"}{"antisense_RNA18S"} = 1;
$rRNA_extra_hash_rev{"antisense_rRNA_extra"}{"antisense_RNA5-8S"} = 1;




#my $working_directory = "/home/elvannostrand/data/clip/CLIPseq_analysis/ENCODE_v9_20151209/PolIII_mapping/";
# my $working_directory = $ARGV[2];
# my $path = "/home/elvannostrand/data/clip/CLIPseq_analysis/RNA_type_analysis/";
#my $filelist_file = "/home/elvannostrand/data/clip/CLIPseq_analysis/RNA_type_analysis/filelist_POLIII";
#my $filelist_file = "/home/elvannostrand/data/clip/CLIPseq_analysis/RNA_type_analysis/MASTER_filelist.wrepbaseandtRNA.enst2id.fixed";
# my $filelist_file = "/home/elvannostrand/data/clip/CLIPseq_analysis/RNA_type_analysis/MASTER_filelist.wrepbaseandtRNA.enst2id.fixed.UpdatedSimpleRepeat";

my $fastq_file1 = $ARGV[0];
my $bowtie_db = $ARGV[1];
my $output = $ARGV[2];
my $filelist_file = $ARGV[3];
&read_in_filelists($filelist_file);

my $print_batch = 10000;
my $read_counter = 0;

#&read_in_filelists("/home/elvannostrand/data/clip/CLIPseq_analysis/RNA_type_analysis/genelists.RNA5S","RNA5S");
#my $fastq_file1 = "/home/gpratt/projects/encode/analysis/encode_v9/484_CLIP_S6_L001_R1_001.B06_484_01_POLR2G.adapterTrim.round2.fastq.gz";
#my $fastq_file2 = "/home/gpratt/projects/encode/analysis/encode_v9/484_CLIP_S6_L001_R2_001.B06_484_01_POLR2G.adapterTrim.round2.fastq.gz";

#my $fastq_file1 = "test_r1.fastq";
#my $fastq_file2 = "test_r2.fastq";
#my $fastq_file1 = "484_CLIP_S6_L001_R1_001.B06_484_01_POLR2G.adapterTrim.round2.fastq";
#my $fastq_file2 = "484_CLIP_S6_L001_R2_001.B06_484_01_POLR2G.adapterTrim.round2.fastq";
#my $fastq_file1 = "484_INPUT_S7_L001_R1_001.unassigned.adapterTrim.round2.fastq";
#my $fastq_file2 = "484_INPUT_S7_L001_R2_001.unassigned.adapterTrim.round2.fastq";




#my $bowtie_db = "/home/elvannostrand/data/clip/CLIPseq_analysis/RNA_type_analysis/filelist_POLIII.combined.Nflank";
my @bowtie_db_split = split(/\//,$bowtie_db);
my $bowtie_db_short = $bowtie_db_split[$#bowtie_db_split];

my @fastq_fi1_split = split(/\//,$fastq_file1);
my $fastq_fi1_short = $fastq_fi1_split[$#fastq_fi1_split];


#my $output = $working_directory.$fastq_fi1_short.".mapped_vs_".$bowtie_db_short.".sam";
my $bowtie_out = $output.".bowtieout";
open(SAMOUT,">$output");
my $multimapping_out = $output.".multimapping_deleted";
open(MULTIMAP,">$multimapping_out");
my $done_file = $output.".done";

#
my $command = "stdbuf -oL bowtie2 -q --sensitive -a -p 1 --no-mixed --reorder -x $bowtie_db -U $fastq_file1 2> $bowtie_out";
#my $command = "/projects/ps-yeolab/software/bowtie-1.1.1/./bowtie -q -1 $fastq_file1 -2 $fastq_file2 $bowtie_db -a -v 2 --best --strata -S 2> $bowtie_out";
print STDERR "command $command\n";
#my $pid = open(BOWTIE, "-|", "unbuffer /projects/ps-yeolab/software/bowtie-1.1.1/./bowtie -q -1 $fastq_file1 -2 $fastq_file2 $genelistfi  -a -v 2 --best --strata -S 2> $bowtie_out");
my $pid = open(BOWTIE, "-|", "stdbuf -oL bowtie2 -q --sensitive -a -p 3 --no-mixed --reorder -x $bowtie_db -U $fastq_file1 2> $bowtie_out");
#my $pid = open(BOWTIE, "-|", "stdbuf -oL /projects/ps-yeolab/software/bowtie-1.1.1/./bowtie -q -1 $fastq_file1 -2 $fastq_file2 $bowtie_db  -a -v 2 --best --strata -S 2> $bowtie_out");
#print "PID $pid\n";
my %fragment_hash;
my $duplicate_count=0;
my $unique_count=0;
my $all_count=0;
my $prev_r1name = "";

my %read_hash;
if ($pid) {

    while (<BOWTIE>) {
	my $r1 = $_;
	chomp($r1);
	if ($r1 =~ /^\@/) {
	    print SAMOUT "$r1\n";
	    next;
	}

	my @tmp_r1 = split(/\t/,$r1);

	my ($r1name,$r1bc) = split(/\s+/,$tmp_r1[0]);

#	$all_count++;
#	if ($all_count % 1000 == 0) {
#	    print STDERR "$all_count\n";
#	}
	
	my $debug_flag = 0;
#	if ($r1name eq "K00180:734:H2FYCBBXY:5:1101:12053:6378_TCCCCCCGAC") {
#	    print "READ1\t$r1\n";
#	    $debug_flag = 1;
#	}
	print STDERR "read1 $r1\n" if ($debug_flag == 1);
	my $r1sam_flag = $tmp_r1[1];

#	unless ($r1sam_flag) {
#	    print STDERR "error $r1\n";
#	}
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
###
	my $flags_r1 = join("\t",@tmp_r1[11..$#tmp_r1]);
	
	my ($mismatch_score_r1);
	if ($flags_r1 =~ /AS\:i\:(\S+?)\s/) {
	    $mismatch_score_r1 = $1;
	}
	my $paired_mismatch_score = $mismatch_score_r1;


	my $mapped_enst = $tmp_r1[2];
	my $mapped_enst_full = $tmp_r1[2];
	if ($mapped_enst =~ /^(.+)\_spliced/) {
	    $mapped_enst = $1;
	} 
	if ($mapped_enst =~ /^(.+)\_withgenomeflank/) {
	    $mapped_enst = $1;
	}

	unless (exists $convert_enst2type{$mapped_enst}) {
	    print STDERR "enst2type is missing for $mapped_enst $r1\n";
	}
	my ($ensttype,$enstpriority) = split(/\:/,$convert_enst2type{$mapped_enst});

	if ($frag_strand eq "-") {
	    $ensttype = "antisense_".$ensttype;
	    $mapped_enst_full = "antisense_".$mapped_enst_full;
	}

	print "mapped $mapped_enst ensttype $ensttype priority $enstpriority\n" if ($debug_flag == 1);

	if ($r1name eq $prev_r1name) {
	    # current read is same as previous - do nothing
	} else {
	    #current read is different than previous - print and clear hash every 100,000 entries

	    $read_counter++;
	    
	    if ($read_counter > $print_batch) {
		&print_output();
		%read_hash = ();
		$read_counter = 0;
	    }
	    $prev_r1name = $r1name;
	}

	if ($debug_flag == 1) {
	    print "r1name $r1name \t paired_mismatch_score $paired_mismatch_score\n";
	    if (exists $read_hash{$r1name}) {
		print "read has been seen before - $read_hash{$r1name}{quality}\n";
	    } else {
		print "read never seen before\n";
	    }
	}

	unless (exists $read_hash{$r1name}) {
	    # if read has never been seen before, keep first mapping
	    $read_hash{$r1name}{R1}{$ensttype} = $r1;
	    $read_hash{$r1name}{flags}{$ensttype} = $enstpriority;
	    $read_hash{$r1name}{quality} = $paired_mismatch_score;
#	    push @{$read_hash{$r1name}{mult_ensts}{$ensttype}},$mapped_enst;
	    push @{$read_hash{$r1name}{mult_ensts}{$ensttype}},$mapped_enst_full;
	    $read_hash{$r1name}{enst}{$mapped_enst} = $mapped_enst_full;
	    $read_hash{$r1name}{master_enst}{$ensttype} = $mapped_enst_full;
	    print "read never seen before quality $paired_mismatch_score $ensttype\n" if ($debug_flag == 1);

	} else {
	    # is score better than previous mapping?
	    if ($paired_mismatch_score < $read_hash{$r1name}{quality}) {
		# new one is worse, skip
		print "new match has worse score than previous - skip $paired_mismatch_score\n" if ($debug_flag == 1);
	    } elsif ($paired_mismatch_score > $read_hash{$r1name}{quality}) {
		# new one is better match than previous - old should all be discarded
		delete($read_hash{$r1name});
		$read_hash{$r1name}{R1}{$ensttype} = $r1;
		$read_hash{$r1name}{flags}{$ensttype} = $enstpriority;
		$read_hash{$r1name}{quality} = $paired_mismatch_score;
#		push @{$read_hash{$r1name}{mult_ensts}{$ensttype}},$mapped_enst;
		push @{$read_hash{$r1name}{mult_ensts}{$ensttype}},$mapped_enst_full;
		$read_hash{$r1name}{enst}{$mapped_enst} = $mapped_enst_full;
		$read_hash{$r1name}{master_enst}{$ensttype} = $mapped_enst_full;

		print "new match has better quality score - discard all previous $paired_mismatch_score\n" if ($debug_flag == 1);

	    } elsif ($paired_mismatch_score == $read_hash{$r1name}{quality}) {
		# equal quality, both are good - now do family analysis
#		print STDERR "two mapping same quality $r1name priority $enstpriority $read_hash{$r1name}{flags}{$ensttype}\n";
		print "has equal quality, now doing family mapping... \n" if ($debug_flag == 1);

		if (exists $read_hash{$r1name}{flags}{$ensttype}) {
                    # if mapping within family exists before...
		    print "mapping exists within family before... \n" if ($debug_flag == 1);
		    # first - did it already map to this transcript before?
		    if (exists $read_hash{$r1name}{enst}{$mapped_enst}) {
			# is it spliced vs unspliced or tRNA flank vs whole genome? if yes ok
			if ($read_hash{$r1name}{enst}{$mapped_enst}."_withgenomeflank" eq $mapped_enst_full || $read_hash{$r1name}{enst}{$mapped_enst}."_spliced" eq $mapped_enst_full) {
			    #original entry is to shorter transcript - keep that one, skip new one entirely
			    print "original was to original (non-genome flank version for tRNA or non-spliced for others) - keep old, skip this one\n" if ($debug_flag == 1);
			} elsif ($read_hash{$r1name}{enst}{$mapped_enst} eq $mapped_enst_full."_withgenomeflank" || $read_hash{$r1name}{enst}{$mapped_enst} eq $mapped_enst_full."_spliced") {
			    # original entry is to longer transcript - replace with shorter
			    $read_hash{$r1name}{R1}{$ensttype} = $r1;
			    $read_hash{$r1name}{flags}{$ensttype} = $enstpriority;

#                           Can't do this as normal - need to replace old
#			    unshift @{$read_hash{$r1name}{mult_ensts}{$ensttype}},$mapped_enst_full;
			    unless (exists $read_hash{$r1name}{"mult_ensts"}{$ensttype}) {
				print STDERR "error doesn't exist? $r1name $ensttype \n";
			    }
			    for (my $i=0;$i<@{$read_hash{$r1name}{"mult_ensts"}{$ensttype}};$i++) {
				if ($read_hash{$r1name}{mult_ensts}{$ensttype}[$i] eq $read_hash{$r1name}{enst}{$mapped_enst}) {
				    $read_hash{$r1name}{mult_ensts}{$ensttype}[$i] = $mapped_enst_full;
				}
			    }
			    $read_hash{$r1name}{enst}{$mapped_enst} = $mapped_enst_full;
			    $read_hash{$r1name}{master_enst}{$ensttype} = $mapped_enst_full;

			    print "new mapping is the one i want - discard old and keep newer annotation \n" if ($debug_flag == 1);
			} else {
			    # maps to two places in the same transcript - this is probably actually ok for counting purposes, but for now I'm going to flag these as bad
			    # 7/20/16 - going to comment this out for now - basically just skip the second entry but don't flag as bad
#			    $read_hash{$r1name}{flags}{"double_maps"} = 1;

			    print "double maps - $ensttype prev length of mult_ensts array is ".scalar(@{$read_hash{$r1name}{mult_ensts}{$ensttype}})."\n" if ($debug_flag == 1);

			    for (my $i=0;$i<@{$read_hash{$r1name}{"mult_ensts"}{$ensttype}};$i++) {
                                if ($read_hash{$r1name}{mult_ensts}{$ensttype}[$i] eq $read_hash{$r1name}{enst}{$mapped_enst}) {
                                    $read_hash{$r1name}{mult_ensts}{$ensttype}[$i] = $mapped_enst_full."_DOUBLEMAP";
                                }
                            }

                            $read_hash{$r1name}{master_enst}{$ensttype} = $mapped_enst_full."_DOUBLEMAP";

			    print "double maps - $ensttype length of mult_ensts array is ".scalar(@{$read_hash{$r1name}{mult_ensts}{$ensttype}})."\n" if ($debug_flag == 1);
			}


		    } elsif ($enstpriority < $read_hash{$r1name}{flags}{$ensttype}) {
			# priority of new mapping is better than old - replace old
			print "priority of new mapping is better than old - replace old mapping\n" if ($debug_flag == 1);
			$read_hash{$r1name}{R1}{$ensttype} = $r1;
			$read_hash{$r1name}{flags}{$ensttype} = $enstpriority;
#			unshift @{$read_hash{$r1name}{mult_ensts}{$ensttype}},$mapped_enst;
			unshift @{$read_hash{$r1name}{mult_ensts}{$ensttype}},$mapped_enst_full;
#			print STDERR "adding mapped $r1name $mapped_enst\n";

			$read_hash{$r1name}{enst}{$mapped_enst} = $mapped_enst_full;
			$read_hash{$r1name}{master_enst}{$ensttype} = $mapped_enst_full;
		    } else {
			# Mapping is equal quality, but priority of new mapping is worse than old - keep new enst_full but otherwise discard
#			push @{$read_hash{$r1name}{mult_ensts}{$ensttype}},$mapped_enst;
			push @{$read_hash{$r1name}{mult_ensts}{$ensttype}},$mapped_enst_full;
		    }
		} elsif (exists $rRNA_extra_hash{$ensttype} && exists $read_hash{$r1name}{R1}{$rRNA_extra_hash{$ensttype}}) { 
		    
		    # If old mapping was to rRNA_extra but new mapping is RNA18S, RNA28S, or RNA5-8S, keep new mapping and discard old
		    my $old_rRNA_label = $rRNA_extra_hash{$ensttype};
		    delete($read_hash{$r1name}{R1}{$old_rRNA_label});
		    delete($read_hash{$r1name}{flags}{$old_rRNA_label});
		    delete($read_hash{$r1name}{master_enst}{$old_rRNA_label});
		    delete($read_hash{$r1name}{mult_ensts}{$old_rRNA_label});
		    delete($read_hash{$r1name}{enst}{"NR_046235.1"});

		    $read_hash{$r1name}{R1}{$ensttype} = $r1;
		    $read_hash{$r1name}{flags}{$ensttype} = $enstpriority;
		    $read_hash{$r1name}{quality} = $paired_mismatch_score;
		    $read_hash{$r1name}{enst}{$mapped_enst} = $mapped_enst_full;
		    $read_hash{$r1name}{master_enst}{$ensttype} = $mapped_enst_full;
		    push @{$read_hash{$r1name}{mult_ensts}{$ensttype}},$mapped_enst_full;

		    print "new mapping is the one i want - discard old and keep newer annotation \n" if ($debug_flag == 1);
		} elsif (exists $rRNA_extra_hash_rev{$ensttype}) {
		    # new mapping is to rRNA_extra
		    my $rRNA_flag = 0;
		    for my $rRNA_elements (keys %{$rRNA_extra_hash_rev{$ensttype}}) {
			if (exists $read_hash{$r1name}{R1}{$rRNA_elements}) {
			    # new mapping is to rRNA_extra, but old is to RNA28S, RNA18S, or RNA5-8S - discard new mapping
			    $rRNA_flag = 1;
			} 
		    }

		    if ($rRNA_flag == 1) {} else {
			# new mapping is to rRNA_extra, but old is to something non-rRNA - do same as multi-family below
			print STDERR "new mapping is to rRNA_extra, but old is to something non-rRNA - do same as multi-family below\nrRNA_flag $rRNA_flag ensttype $ensttype r1 $r1\n" if ($debug_flag == 1);
			$read_hash{$r1name}{R1}{$ensttype} = $r1;
			$read_hash{$r1name}{flags}{$ensttype} = $enstpriority;
			$read_hash{$r1name}{quality} = $paired_mismatch_score;
			$read_hash{$r1name}{enst}{$mapped_enst} = $mapped_enst_full;
			push @{$read_hash{$r1name}{mult_ensts}{$ensttype}},$mapped_enst_full;
			$read_hash{$r1name}{master_enst}{$ensttype} = $mapped_enst_full;

		    }
#		    $rRNA_extra_hash_rev{"rRNA_extra"}{"RNA28S"} = 1;

		} else {
		    print "maps to two families - $ensttype\n" if ($debug_flag == 1);
#                 hits this if 
		    # 1) read_hash{r1name} already exists (read already seen)
		    # 2) $paired_mismatch_score == $read_hash{$r1name}{quality} - mapping score is same as previous
		    # 3) $read_hash{$r1name}{flags}{$ensttype} doesn't exist - read exists but this is a new family

		    # read maps to multiple gene lists - discard as not uniquely mapping within family
		    # 7/19/16 - changed this to KEEP multi-family mapping
		    

		    #my $type1 = "RN7SL";
		    #my $type2 = "RN7SL_antisense";
#		    if (exists $read_hash{$r1name}{flags}{$type1} && $ensttype eq $type2) {
#			print "$type1\t".$read_hash{$r1name}{R1}{$type1}."\n".$read_hash{$r1name}{R2}{$type1}."\n"."$type2\t".$r1."\n".$r2."\n\n";
#		    }
#		    if (exists $read_hash{$r1name}{flags}{$type2} && $ensttype eq $type1) {
#			print "$type2\t".$read_hash{$r1name}{R1}{$type2}."\n".$read_hash{$r1name}{R2}{$type2}."\n"."$type1\t".$r1."\n".$r2."\n\n";
#		    }

		    $read_hash{$r1name}{R1}{$ensttype} = $r1;
		    $read_hash{$r1name}{flags}{$ensttype} = $enstpriority;
		    $read_hash{$r1name}{quality} = $paired_mismatch_score;
		    $read_hash{$r1name}{enst}{$mapped_enst} = $mapped_enst_full;
		    push @{$read_hash{$r1name}{mult_ensts}{$ensttype}},$mapped_enst_full;

		    #adds new master enst to save for below
		    $read_hash{$r1name}{master_enst}{$ensttype} = $mapped_enst_full;
#		    my @tmp_to_sort = split(/\|/,$read_hash{$r1name}{master_enst});
#		    push @tmp_to_sort,$mapped_enst_full;
#		    my @sorted = sort {$a cmp $b} @tmp_to_sort;
#		    $read_hash{$r1name}{master_enst} = join("|",@sorted);

		}
	    } else {
		# I don't think this should ever be hit
#		print STDERR "this shouldn't be hit - $paired_mismatch_score $read_hash{$r1name}{quality} $r1name $r1 $r2\n";
		print STDERR "this shouldn't be hit - $paired_mismatch_score $read_hash{$r1name}{quality} $r1name $r1\n";
	    }
		
	}
	# end of line processing
	
    }
}

&print_output();
close(SAMOUT);
for my $multi_key (keys %multimapping_hash) {
    print MULTIMAP "$multi_key\t".$multimapping_hash{$multi_key}."\n";
}
close(MULTIMAP);

#my $done_file = $output.".done";
open(DONE,">$done_file");
print DONE "jobs done\n";
close(DONE);


sub print_output {
    my %count;
    my %count_enst;
    for my $read (keys %read_hash) {
	my @ensttype_array = sort {$a cmp $b} keys %{$read_hash{$read}{flags}};
	my $ensttype = $ensttype_array[0];
	my @masterenst_array;
	for my $type (@ensttype_array) {
	    push @masterenst_array,$read_hash{$read}{master_enst}{$type};
	}
	my $ensttype_join = join("|",@ensttype_array);
	my $masterenst_join = join("|",@masterenst_array);
	
	$count{$ensttype_join}++;
	
#	print STDERR "read $read, ensttype $ensttype\n";
	if (scalar(keys %{$read_hash{$read}{flags}}) == 1) {
	    print STDERR "this shouldn't happen this should be 1 ".scalar(keys %{$read_hash{$read}{R1}})."\n" unless (scalar(keys %{$read_hash{$read}{R1}}) == 1);
	    
	    my @r1_split = split(/\t/,$read_hash{$read}{R1}{$ensttype});
	    $r1_split[2] = $ensttype_join."||".$masterenst_join;
	    my $r1_line = join("\t",@r1_split);
	    
#	    print SAMOUT "".$r1_line."\tZZ:Z:".join("|",@{$read_hash{$read}{mult_ensts}{$ensttype}})."\n".$r2_line."\tZZ:Z:".join("|",@{$read_hash{$read}{mult_ensts}{$ensttype}})."\n";
	    print SAMOUT "".$r1_line."\tZZ:Z:".join("|",@{$read_hash{$read}{mult_ensts}{$ensttype}})."\n";
	    
	    my @blah = split(/\t/,$read_hash{$read}{R1}{$ensttype});
	    $count_enst{$ensttype."|".$blah[2]}++;
#	    $count_enst{$ensttype."|".join("|",@{$read_hash{$read}{mult_ensts}{$ensttype}})}++;
	    
	} else {
#	print STDERR "this shouldn't happen this should be 1 ".scalar(keys %{$read_hash{$read}{R1}})."\n" unless (scalar(keys %{$read_hash{$read}{R1}}) == 1);
	    my @all_mult_ensts;
	    for my $key (@ensttype_array) {
		push @all_mult_ensts,join("|",@{$read_hash{$read}{mult_ensts}{$key}});
	    }
	    my $final_mult_ensts = join("|",@all_mult_ensts);
	    
	    unless (exists $read_hash{$read}{R1}{$ensttype} && $read_hash{$read}{R1}{$ensttype}) {
		print "weird error - $read $ensttype readhash doesn't exist ? ".$read_hash{$read}{flags}{$ensttype}."\n";
	    }
	    
	    my @r1_split = split(/\t/,$read_hash{$read}{R1}{$ensttype});
	    $r1_split[2] = $ensttype_join."||".$masterenst_join;
	    my $r1_line = join("\t",@r1_split);

	    print SAMOUT "".$r1_line."\tZZ:Z:".$final_mult_ensts."\n";
#	    print SAMOUT "".$r1_line."\tZZ:Z:".$final_mult_ensts."\n".$r2_line."\tZZ:Z:".$final_mult_ensts."\n";
	    my $multimapping_type = join("|",keys %{$read_hash{$read}{flags}});
	    $multimapping_hash{$multimapping_type}++;
	}
    }
    

}


#my @sorted = sort {$count{$b} <=> $count{$a}} keys %count;
#for my $k (@sorted) {
#    print "$k $count{$k}\n";
#}

#my @sorted = sort {$count_enst{$b} <=> $count_enst{$a}} keys %count_enst;
#for my $s (@sorted) {
#    my ($type,$geneid) = split(/\|/,$s);
#    print "$type\t$geneid\t$count_enst{$s}\t$enst2gene{$geneid}\n";
#    print "$type\t$geneid\t$count_enst{$s}\t$s\n";
#}


#print "unique $unique_count\n duplicate $duplicate_count\n";





sub read_in_filelists {
    my $fi = shift;
    my $priority_n = 0;
    open(F,$fi);
    for my $line (<F>) {
	chomp($line);
	my ($allenst,$allensg,$gid,$type_label,$typefile) = split(/\t/,$line);
#	my ($allensg,$gid,$allenst) = split(/\t/,$line);
	$type_label =~ s/\_$//;
	unless ($allenst) {
	    print STDERR "error missing enst $line $fi\n";
	}
	my @ensts = split(/\|/,$allenst);
	for my $enst (@ensts) {
	    $enst2gene{$enst} = $gid;
	    $convert_enst2type{$enst} = $type_label.":".$priority_n;
	    $priority_n++;
	}
    }
    close(F);
}
