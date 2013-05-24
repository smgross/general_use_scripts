#!/usr/bin/perl -w
use strict;
use Statistics::R;
use Getopt::Long;

#if nothing on command line print usage
if (@ARGV == 0) {
	printusage();
	print "Enter in a plain text document on the word line\n";
	exit;
	};

#set defaults for major variables
my $minfreq = 3;
my $maxwords = 10;
my $randomorder = "FALSE";

#read options
GetOptions (
	"minfreq=i" => \$minfreq,
	"maxwords=i" => \$maxwords,
	"randomorder=s" => \$randomorder,
	);

#parse randomorder to T or F [False = DEFAULT]
if ($randomorder =~ m/T/gi) {
	$randomorder = "TRUE";
	};
	

print "SETTINGS:\n";
print "\tminimum word frequency = $minfreq\n";
print "\tmaximum number of words = $maxwords\n";
print "\trandom ordering = $randomorder\n";

	
	
my $infile = shift;
my $outfile = $infile;
$outfile =~ s/\.txt$//g;
$outfile = "wc2"."$outfile"."_mw.$maxwords"."_mf.$minfreq"."_ro.$randomorder";
$outfile = "$outfile".".pdf";

unless (-e $infile) {
	die "I can't fine $infile\n";
	};

open IN, "$infile";	

my @words;


$/ = "\n";

while(<IN>) {
	chomp;
	my $line = $_;
	if ($line =~ m/^\s*$/) {next};
	my @splitline = split (/\s+/, $line);
	for (my $i = 0; $i < @splitline; $i++) {
		$splitline[$i] =~ s/,//;
		$splitline[$i] =~ s/\.//;
		push (@words, $splitline[$i]);
		};
	};

my %wordhash;
for (my $i = 0; $i < @words; $i++) {
	$wordhash{$words[$i]}++;
	};
	
print "\n\nHere's the word matrix:\n";
print "Word\tCount\n";

#while printing the word matrix to the user, calculate the unique words and their frequencies
my (@wordsarray, @frequencyarray);
while (my ($k, $v) = each (%wordhash)) {
	print "$k\t$v\n";
	push (@wordsarray, $k);
	push (@frequencyarray, $v / scalar (@words));
	};


###print outfile	
my $outfile2 = "$infile"."_wordcounts.txt";
open OUT2, ">$outfile2";
print OUT2 "Word\tCount\n";
while (my ($k, $v) = each (%wordhash)) {
	print OUT2 "$k\t$v\n";
	};


### CLOSE PERL FILE HANDLES
close OUT2;
close IN;
	
print "DONE READING FILE.\n";


### Make WORD CLOUDS in R
my $R = Statistics::R->new();
$R->start();

$R->run(q`require(tm)`);
$R->run(q`require(wordcloud)`);
$R->run(q`require(RColorBrewer)`);
$R->set('words', [@wordsarray]);
$R->set('freqs', [@frequencyarray]);

print "DATA LOADED INTO R. MAKING WORD CLOUD\n";


$R->set('maxwords', $maxwords);
$R->set('minfreq', $minfreq);
$R->set('randomorder', $randomorder);
$R->run(qq`pdf("$outfile")`);
$R->run(q`wordcloud(words, freqs, scale = c(14,1), min.freq= minfreq, max.words = maxwords, random.order= randomorder)`);
$R->run(q`dev.off()`);
$R->stop();

print "DONE\n";
print "Open file $outfile\n";



exit;


##### SUBROUTINES ######


sub printusage {
	print "OPTIONS\n";
	print "THIS IS A MODIFICATION OF wordclouder.pl THAT USES VECTORS INSTEAD OF A tm CORPUS\n";
	print "\t-minfreq = minimum word frequency [default = 3]\n";
	print "\t-maxwords = maximum number of words in cloud [default = 10]\n";
	print "\t-randomorder = TRUE or FALSE [default = FALSE]\n";
	print "\n";
	};

