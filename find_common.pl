#!/usr/bin/perl -w
use strict;
use Statistics::R;
use Getopt::Long;
use Pod::Usage;

=head1 NAME

	find_common.pl - FIND COMMON ELEMENTS IN A NUMBER OF LISTS
	
=head1 SYNOPSIS
	
	find_common.pl [options] <FILES>

	IMPORTANT NOTE ON INPUT FILES:
		Input files MUST be formatted with 1 entry per line. 
		Lines are split by whitespace. No whitespace characters are allowed!!!!
		Whitespace surrounding strings will be ignored. 

	OUTPUT FILE(S):
		Output file(s) will be named by combining names of input files

	Options:
	-suppress	TRUE or FALSE  [default = TRUE] (T/F OK)
				print all output files.
				if TRUE, only provides the number of common entries
				
	-venn		TRUE or FALSE [default = FALSE] to produce Venn diagram (T/F OK)	
	
	-man 		display full manual and information
	
	-help 		you're looking at it


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
	"help|?|h" => \$help,
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
	pod2usage();
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
	#build outfile names
	my $outfilemain = outfilemainname (@infiles);
	my ($TFfile, $tabfile, $binaryfile, $commonfile) = createfilenames($outfilemain);
	
	print "Outfile main name core is:\t$outfilemain\n";
	
	#open filehandles for the 4 outfiles
	#using lexical filehandles to pass to subroutines
	open my $tabfh, ">$tabfile"; #tab separated values
	open my $TFfh, ">$TFfile";  #boolean values
	open my $binaryfh, ">$binaryfile"; #presence/absence coded in 1 and 0's
	open my $commonfh, ">$commonfile"; #flat list of common elements

	#print headers on the 3 tabulated outfiles
	print $tabfh "item\t" . join ("\t", @infiles) . "\n";
	print $TFfh "item\t" . join ("\t", @infiles). "\n";
	print $binaryfh "binary\tcount\t". join ("\t", @infiles)."\n";

	#print the TAB and TF files, then close the file handles
	createfile($tabfh, \%hashofvalues, "tab");
	createfile($TFfh, \%hashofvalues, "boolean");
	close $tabfh;
	close $TFfh;
		
	#print the common file, count the number of common values
	my $allcommoncounter = commonfile($commonfh, \%hashofvalues);
	close $commonfh;	
	
	
	
	####remainder is the binary file
	my $binaryhashstring = join("", @foundarray);
	
	if (exists $binaryhash{$binaryhashstring}) {
		my $value = $binaryhash{$binaryhashstring};
		$value++;
		$binaryhash{$binaryhashstring} = $value;
		} else {
		$binaryhash{$binaryhashstring} = 1;
		};
			
	while (my ($k, $v) = each %binaryhash) {
		print BINARY "$k\t$v\t";
		my @splitk = split (//, $k);
		print BINARY join("\t", @splitk) ."\n";
		};
		
	
	


	#create and print the Venn diagram, if requested	
	if (@infiles <= 5 && $venn =~ m/T/gi) {	
		my $code = buildvenn($TFfile);
		if ($code == 0) {
			print "There was an unknown error building the Venn diagram\n";
			};
		};
	};
		






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
	for (my $i = 0 ; $i < @masterarray ; $i++) {  			#for file i in @masterarray
		for my $line_i (keys %{$masterarray[$i]}) {  		#for every line in file i
			for (my $j = 0 ; $j < @masterarray ; $j++) { 	#compare it to file j in @Masterarray
				if (exists $masterarray[$j]{$line_i}) {   	#see if the line of file i exists in file k
					$unionhash{$line_i}{$j}++;     			#this is saying line in file i exists in file j X number of times   		
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

sub buildvenn {
	my $TFfile = shift;
	unless (-e $TFfile) {
		return 0;
		};
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
	return 1;
	};
	
sub createfilenames {
	my $outfilemain = shift;
	my $TFfile = "$outfilemain"."_boolean.txt";
	my $tabfile = "$outfilemain"."_tab.txt";
	my $binaryfile = "$outfilemain"."_binary.txt";
	my $commonfile = "$outfilemain"."_common_items.txt";
	return ($TFfile, $tabfile, $binaryfile, $commonfile);
	};

sub createfile {
	my ($fh, $hashofvaluesref, $type) = @_;  #where $fh = filehandle
	
	#depending on the type of output requested, fix the @markingvalues array
	# 0 = FALSE, 1 = TRUE
	my @markingvalues;
	if ($type eq "tab") {
		@markingvalues = ("FALSE","TRUE");
		} elsif ($type eq "boolean") {
		@markingvalues = (0,1);
		};
	
	#write the output to the filehandle $fh
	while (my ($line, $filename) = each %{$hashofvaluesref}) {
		print $fh "$line\t";
		my @foundarray;
		for (my $i = 0; $i < @infiles ; $i++) {
			if (exists $hashofvalues{$line}{$i}) {
				push (@foundarray, $markingvalues[1]);
				} else {
				push (@foundarray, $markingvalues[0]);
				};
			}; 
		print $tf join ("\t", @foundarray) . "\n";
		};
		return;
	};

sub commonfile {
	my ($fh, $hashofvalues) = @_;
	my $allcommoncounter = 0;
	while (my ($k, $v) = each %{$hashofvalues}) {
		if (keys %$v == $filenumber) {
			print $commonfh "$k\n";
			$allcommoncounter++;
			};
		};
	return $allcommoncounter;
	};