#!/usr/bin/env perl

use warnings;
use strict;
use Fcntl qw(:flock);

my $output_fi = shift(@ARGV);
open(OUT,">$output_fi") || die "can't open output file $output_fi\n";

my @files = @ARGV;
my @split_fi1 = split(/\//,$files[0]);
my $short_fi1 = pop(@split_fi1);
my $working_dir = join("/",@split_fi1);
my $failed_jobs_list = $working_dir."/"."failed_jobs_list.txt";

my $lock_fi = $failed_jobs_list.".lck";
open(S,">$lock_fi") || sleep 5;
flock(S, LOCK_EX) || sleep 5;
open(FH,">>$failed_jobs_list") or die "this is weird - shouldn't be hit $failed_jobs_list\n";

my %read_sums;
for my $file (@files) {
    # my $donefi = $file.".done";
    # my $done_seq = `cat $donefi` if (-e $donefi);
    # chomp($done_seq);
    # if (-e $donefi) {
    # 	print "donefi exists $donefi\n";
    # 	print "doneseq $done_seq X\n";
    # }

    # unless (-e $donefi && $done_seq eq "jobs done") {
	# print FH "Failed job $output_fi on $file\n";
	# exit;
    # }
    &parse_file($file);
}
close(FH);
close(S);

print OUT "#READINFO\tAllReads\t".$read_sums{all}."\n";
print OUT "#READINFO\tUsableReads\t".$read_sums{usable}."\t".($read_sums{usable}/$read_sums{all})."\n";
print OUT "#READINFO\tGenomicReads\t".$read_sums{genomic}."\t".($read_sums{genomic}/$read_sums{usable})."\n";
print OUT "#READINFO\tRepFamilyReads\t".$read_sums{repfamily}."\t".($read_sums{repfamily}/$read_sums{usable})."\n";

my @sorted_total = sort {$read_sums{total}{$b} <=> $read_sums{total}{$a}} keys %{$read_sums{total}};
for my $element (@sorted_total) {
#for my $element (keys %{$read_sums{total}}) {
    print OUT "TOTAL\t$element\t".$read_sums{total}{$element}."\t".($read_sums{total}{$element}/$read_sums{usable})."\n";
}

my @sorted_element = sort {$read_sums{element}{$b}{readnum} <=> $read_sums{element}{$a}{readnum}} keys %{$read_sums{element}};
for my $element (@sorted_element) {
#for my $element (keys %{$read_sums{element}}) {
    print OUT "ELEMENT\t".$read_sums{element}{$element}{ensg_primary}."\t".$read_sums{element}{$element}{readnum}."\t".($read_sums{element}{$element}{readnum}/$read_sums{usable})."\t".$element."\t".$read_sums{element}{$element}{ensg_all}."\n";
}




sub parse_file {
    my $parsed_fi = shift;
    open(P,$parsed_fi) || die "can't open $parsed_fi\n";
    while (<P>) {
	chomp($_);
	my @tmp = split(/\t/,$_);
	if ($tmp[0] eq "#READINFO") {
#	    print STDERR "tmp0 $tmp[0] $_\n";
	    my $line = $_;
	    if ($_ =~ /All\sreads\:\t(\d+)\tPCR\sduplicates\sremoved\:\t(\d+)\tUsable\sRemaining\:\t(\d+)\tUsable\sfrom\sgenomic\smapping\:\t(\d+)\tUsable\sfrom\sfamily\smapping\:\t(\d+)$/) {

		my $all_reads = $1;
		my $pcr_duplicates = $2;
		my $usable_reads = $3;
		my $genomic_reads = $4;
		my $repfamily_reads = $5;
	
		$read_sums{all} += $all_reads;
		$read_sums{usable} += $usable_reads;
		$read_sums{genomic} += $genomic_reads;
		$read_sums{repfamily} += $repfamily_reads;
	
#		print STDERR "all $all_reads rep $repfamily_reads genomic $genomic_reads usable $usable_reads\n";
	    } else {
		print STDERR "couldn't parse readinfo line $_\n";
	    }
	} elsif ($tmp[0] eq "#READINFO2") {
	} elsif ($tmp[0] eq "TOTAL") {
	    my ($total,$element,$readnum,$rpm) = @tmp;
	    
	    $read_sums{total}{$element} += $readnum;
	} else {
	    my ($ensg_primary,$readnum,$rpm,$enst_all,$ensg_all) = @tmp;
	    print STDERR "error - ensg_all mismatch $ensg_all $read_sums{element}{$enst_all}{ensg_all}\n" if (exists $read_sums{element}{$enst_all}{ensg_all} && ($read_sums{element}{$enst_all}{ensg_all} ne $ensg_all));
	    print STDERR "error - ensg_primary mismatch $ensg_primary  $read_sums{element}{$enst_all}{ensg_primary}\n" if (exists  $read_sums{element}{$enst_all}{ensg_primary} && ($read_sums{element}{$enst_all}{ensg_primary} ne $ensg_primary));

	    $read_sums{element}{$enst_all}{ensg_all} = $ensg_all;
	    $read_sums{element}{$enst_all}{ensg_primary} = $ensg_primary;
	    $read_sums{element}{$enst_all}{readnum} += $readnum;
	    
	    
	}
    }
    close(P);
}
