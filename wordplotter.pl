#!/usr/bin/perl -w
use strict;
use Statistics::R;

my $infile = shift;
my $outfile = "$infile".".pdf";
$outfile =~ s/\.txt//g;


unless (-e $infile) {
	die "I can't fine $infile\n";
	};

open IN, "$infile";	

my @words;

#preprogram in stopwords
my $stopword = "a,able,about,across,after,all,almost,also,am,among,an,and,any,are,as,at,be,because,been,but,by,can,cannot,could,dear,did,do,does,either,else,ever,every,for,from,get,got,had,has,have,he,her,hers,him,his,how,however,i,if,in,into,is,it,its,just,least,let,like,likely,may,me,might,most,must,my,neither,no,nor,not,of,off,often,on,only,or,other,our,own,rather,said,say,says,she,should,since,so,some,than,that,the,their,them,then,there,these,they,this,tis,to,too,twas,us,wants,was,we,were,what,when,where,which,while,who,whom,why,will,with,would,yet,you,your";
my @stopwords = split (/,/, $stopword);
	
$/ = "\n";

while(<IN>) {
	chomp;
	my $line = $_;
	if ($line =~ m/^\s*$/) {next};
	my @splitline = split (/\s+/, $line);
	for (my $i = 0; $i < @splitline; $i++) {
		$splitline[$i] =~ s/,//;
		$splitline[$i] =~ s/\.//;
		my $stopfound = 0;
		foreach (@stopwords) {
			if ("$splitline[$i]" eq "$_") {
				$stopfound++;
				};
		if ($stopfound == 0) {
			push (@words, $splitline[$i]);
			};
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
	
my $R = Statistics::R->new();
$R->start();
$R->set('words', [@wordsarray]);
$R->set('freqs', [@frequencyarray]);
$R->run(q`df<-cbind(words, freqs)`);

