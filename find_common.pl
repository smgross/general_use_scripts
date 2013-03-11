#!/usr/bin/perl -w
use strict;
use Statistics::R;
use Getopt::Long;
use Pod::Usage;

=head1 NAME
find_common.pl
=head1 SYNOPSIS
find_common.pl  FIND COMMON ELEMENTS IN A NUMBER OF LISTS

find_common.pl [options] [FILES]

NOTE: 
	Input files MUST be formatted with 1 entry per line. Whitespace surrounding
	strings will be ignored. 

Options:
	-col1 TRUE or FALSE   default = FALSE  
			split lines on space characters and use only the 1st word
	-suppress  TRUE or FALSE  default = TRUE
			print all output files.
			if TRUE, only provides the number of common elements
			
	-man display full manual and information
	-help what you see here

Output file(s) will be named by combining names of input files
=head1 DESCRIPTION

determines the common items (union) between 2 or more files
input file(s) format: 1 item per line. Whitespace is ignored.


=head1 AUTHOR
Stephen Gross    smgross@mac.com
2011-2013
=cut

my $suppress = "TRUE";
my $venn = "FALSE";
my $help;
my $man;

GetOptions (
	"suppress=s" => \$suppress,
	"venn=s" => \$venn,
	"help|?" => \$help,
	"man" => \$man,
	);

#Implement pod2usage to display help or manual	
pod2usage() if $help;
pod2usage(-verbose => 2) if $man;


#parse options
if ($suppress =~ m/T/gi) {
	$suppress = "TRUE";
	} else {
	$suppress = "FALSE";
	};

if ($venn =~ m/T/gi) {
	$venn = "TRUE";
	} else {
	$venn = "FALSE";
	};

my @infiles = @ARGV;
if (@infiles < 2) {
	pod2usage(-verbose => 2);
	exit;
	};
	
#perform a check to make sure the file exist
foreach (@infiles) {
	if (-e $_) { 
		#do nothing
		} else {
		print "ERROR: I can't find the file $_. Make sure the file exists and name is spelled correctly.";
		exit;
		};
	};


my @masterarray = readfiles(@infiles);
my %hashofvalues = parse_masterarray(@masterarray);
my $allcommoncounter = countcommonvalues(\%hashofvalues, \@infiles);

print "There are $allcommoncounter items common between the input files\n";

if ($suppress eq "FALSE") {
	my $outfilemain = outfilemainname (@infiles);
	print "Outfile main name core is:\t$outfilemain\n";
	};
	

=stop	
if ($suppress eq "FALSE") {	
	my $outputfilename = join ("_", @infiles);
	my $tabfile = $outputfilename . "_tab.txt";
	my $TFfile = join("_", @infiles) ."_TF.txt";
	my $TFfile = "TF_$tabfile".".txt";
	open TAB, ">$tabfile";
	open TF, ">$TFfile";
	
	
	print TAB "item\t" . join ("\t", @infiles) . "\n";
	print TF "item\t" . join ("\t", @infiles)."\n";
	while (my ($k, $v) = each %hashofvalues) {
		print TAB "$k\t";
		print TF "$k\t";
		my @foundarray;
		for (my $i = 0; $i < @infiles ; $i++) {
			if (exists $hashofvalues{$k}{$i}) {
				push (@foundarray, 1);
				} else {
				push (@foundarray, 0);
				};
			}; 
		my $binaryhashstring = join("", @foundarray);
		if (exists $binaryhash{$binaryhashstring}) {
			my $value = $binaryhash{$binaryhashstring};
			$value++;
			$binaryhash{$binaryhashstring} = $value;
			} else {
			$binaryhash{$binaryhashstring} = 1;
			};
		print TAB join ("\t", @foundarray) . "\n";
		my @foundarray2;
		for (my $i = 0; $i<@foundarray; $i++) {
			if ($foundarray[$i] == 1) {
				$foundarray2[$i] = "TRUE";
				};
			if ($foundarray[$i] == 0) {
				$foundarray2[$i] = "FALSE";
				};
			};
		print TF join ("\t", @foundarray2) . "\n";
		};
	
	
	my $binaryfile = "binary_$tabfile".".txt";
	open BINARY, ">$binaryfile";
	print BINARY "binary\tcount\t". join ("\t", @infiles)."\n";
	while (my ($k, $v) = each %binaryhash) {
		print BINARY "$k\t$v\t";
		my @splitk = split (//, $k);
		print BINARY join("\t", @splitk) ."\n";
		};
		
	my $outfile = "commonitems_$tabfile".".txt";
	open OUT, ">$outfile";
	
	my $allcommoncounter = 0;
	while (my ($k, $v) = each %hashofvalues) {
		if (keys %$v == $filenumber) {
			print OUT "$k\n";
			$allcommoncounter++;
			};
		};
	
	my $answer;
	if (@infiles <=5) {	
		print "Would you like a Venn diagram? [Y/N]: ";
		$answer = <STDIN>;
		chomp $answer;
		if ($answer =~ m/Y/gi) {
			print "Working on Venn diagram... please wait....\n";
			my $R = Statistics::R->new();
			$R->start();
			$R->set('filename', $TFfile);
			$R->run(q`library(gplots)`);
			$R->run(q`data<-read.table(file = filename, header = T, sep = "\t")`);
			$R->run(q`rownames(data)<-data$item`);
			$R->run(q`data<-data[,-1]`);
			$R->run(q`pdf(file = "venn_plot.pdf")`);
			$R->run(q`venn(data)`);
			$R->run(q`dev.off()`);
			$R->stop();
			};
		};
	};



=cut


###	Subroutines	####


sub readfiles {
	my @infiles = @_;
	#for each of the infiles, break it into a hash; load each of those hashes into @masterarray
	for (my $i = 0 ; $i < @infiles ; $i++) {
        open IN, $infiles[$i];
        my %filehash;
        while (my $line = <IN>) {
			chomp $line;
			$line =~ s/^\s+//; #remove leading whitespace
			$line =~ s/\s+$//; #remove trailing whitespace
			if ($line =~ m/^\s*$/) {next}; #skip blank lines
			$filehash{$line}++;
			};
        push (@masterarray, \%filehash);
        close IN;
        };
    return @masterarray;
	};

sub parse_masterarray {
	my @masterarray = @_;
	my %unionhash;
	for (my $i = 0 ; $i < @masterarray ; $i++) {  		#for file i in @masterarray
		for my $line_i (keys %{$masterarray[$i]}) {  		#for every line in file i
			for (my $j = 0 ; $j < @masterarray ; $j++) { 	#compare it to file j in @Masterarray
				if (exists $masterarray[$j]{$line_i}) {   	#see if the line of file i exists in file k
					$unionhash{$line_i}{$j}++;     #this is saying line in file i exists in file j X number of times   		
					}; 
				}; 
			};
		};
	return %unionhash;
	};

sub countcommonvalues {
	my %unionhash = %{$_[0]};
	my @infiles = @{$_[1]};
	my $allcommoncounter = 0;
	for my $line (keys %unionhash) {
		#if the number of separate files in which 'line' was observed is equal to the number of input files
		if ( keys (%{$unionhash{$line}}) == scalar (@infiles)) {  
			$allcommoncounter++;
			};	
		};
	return $allcommoncounter;
	};

sub outfilemainname {
	#This just picks a string from the input file names and creates a main string to be used as 
	#  the core for the output file names
	my @infiles = @_;
	my $outfilemainname = join ("_", @infiles);
	if (length ($outfilemainname) > 25) {
		$outfilemainname =~ m/^(.{10})/;
		my $part1 = $1;
		$outfilemainname =~ /(.{10})$/;
		my $part2 = $1;
		$outfilemainname = "$part1".".."."$part2";
		};
	return $outfilemainname;
	};