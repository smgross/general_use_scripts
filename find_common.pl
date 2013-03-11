#!/jgi/tools/bin/perl -w
use strict;
use Statistics::R;
use Getopt::Long;

=usage
FIND COMMON ELEMENTS IN A NUMBER OF LISTS
@ARGV contains any number of files with a list of elements, one per line.
ONLY the first word on each line is used, the rest is ignored
=cut

my $suppress = "FALSE";
my $col1 = "FALSE";
my $randomnumber = int(rand(1000));

GetOptions (
	"suppress=s" => \$suppress,
	"col1=s" => \$col1,
	);

if ($suppress =~ m/T/gi) {
	$suppress = "TRUE";
	} else {
	$suppress = "FALSE";
	};

if ($col1 =~ m/T/gi) {
	$col1 = "TRUE";
	} else {
	$col1 = "FALSE";
	};

my @infiles = @ARGV;
if (@infiles == 0) {
	print "---------------------------------------------------------------------------------------------------\n";
	print "find_common3.pl\nUsage:\n\tEnter in two or more files with a list of terms on the command line, with one term per line.\n";
	print "\tThis will compare the items in each of the files and produce a list of common terms as well as tables\n";
	print "\tformatted for import into R to produce Venn diagrams.\n";
	print "\tif 5 or fewer groups are compared, I will automatically make a Venn diagram (requires R and gplots package)\n\n";
	print "\nOPTIONS\n";
	print "\t-suppress [TRUE or FALSE] Default = FALSE. If TRUE, reports only the number of common items.\n";
	print "\t-col1 [TRUE or FALSE] Default = FALSE. If TRUE, input files are split by space, only first word is used for comparisons\n";
	exit;
	};
	
#perform a check to make sure the file exist
foreach (@infiles) {
	if (-e $_) { 
		#do nothing
		} else {
		die "ERROR: I can't find the file $_. Make sure the file exists and name is spelled correctly.";
		};
	};


my @masterarray;

print "Reading files... \n";
my $files = 0;
for (my $i = 0 ; $i < @infiles ; $i++) {
        open IN, $infiles[$i];
        my %filehash;
        while (my $line = <IN>) {
                chomp $line;
                if ($line =~ m/^\s*$/) {next}; #skip blank lines
                my $comparator;
                if ($col1 eq "TRUE") {
                	print "\rSplitting line and recording the first item";
                	my @splitline = split (/\s+/, $line);
                	$comparator = $splitline[0];
                	} else {
                	print "\rRecording the entire line as an entry";
                	$comparator = $line;
                	};
                $filehash{$comparator} = 0;
                };
        my $filehashref = \%filehash;
        push (@masterarray, $filehashref);
        close IN;
        };
        
print "\n...done.\n";
my $filenumber = scalar (@masterarray);
my %hashofvalues;
my %binaryhash;

print "Working...\n";
for (my $i = 0 ; $i < @masterarray ; $i++) {
	my $filenum = $i + 1;
	while (my ($key, $value) = each %{$masterarray[$i]}) {
		print "\r\tFile $filenum ($infiles[$i]), list item $key";
		my $checkvalue = $key; 
		for (my $k = 0 ; $k < @masterarray ; $k++) {
			if (exists $masterarray[$k]{$checkvalue}) {
				if (exists $hashofvalues{$checkvalue}) {
					my %temp = %{$hashofvalues{$checkvalue}};
					$temp{$k} = 0;
					my $tempref = \%temp;
					$hashofvalues{$checkvalue} = $tempref;
					} else {
					my %temp;
					$temp{$k} = 0;
					my $tempref = \%temp;
					$hashofvalues{$checkvalue} = $tempref;
					};
				}; 
			}; 
		};
	};


my $allcommoncounter = 0;
while (my ($k, $v) = each %hashofvalues) {
	if (keys %$v == $filenumber) {
		$allcommoncounter++;
		};
	};
	
if ($suppress eq "FALSE") {	
	print "\n...done... tidying up and creating output files...\n";
	
	#my $tabfile = join("_", @infiles) . "_tab.txt";
	my $tabfile = "tab_$randomnumber".".txt";
	#my $TFfile = join("_", @infiles) ."_TF.txt";
	my $TFfile = "TF_$randomnumber".".txt";
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
	
	
	my $binaryfile = "binary_$randomnumber".".txt";
	open BINARY, ">$binaryfile";
	print BINARY "binary\tcount\t". join ("\t", @infiles)."\n";
	while (my ($k, $v) = each %binaryhash) {
		print BINARY "$k\t$v\t";
		my @splitk = split (//, $k);
		print BINARY join("\t", @splitk) ."\n";
		};
		
	my $outfile = "commonitems_$randomnumber".".txt";
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



print "\n---------------------------------FINISHED--------------------------------------\n";
print "There are $allcommoncounter items in the list common to all the input files: \n\t" . join ("\n\t", @infiles) ."\n";
if ($suppress eq "FALSE") {
	
	if (-e "venn_plot.pdf") {
		print "Open file venn_plot.pdf to see a Venn diagram from the gplots package\n";
		};
	};
print "-------------------------------------------------------------------------------\n";

