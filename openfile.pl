#!/usr/bin/perl -w
use strict;
use Getopt::Long;
#use Pod::Usage;  #implement this later

=head1 NAME
openfile.pl    

=head1 SYNOPSIS

openfile.pl [options] [file]

	Options:
		-force	forces specific application to open file
	
	run without arguments for full help

=head1 AUTHOR

Stephen Gross, 2013
a wrapper for the Mac OSX command open

=head1 DESCRIPTION

automatically determines what file types are to be opened
executes command to open up file with a GUI application
run without options to get help

=cut

my $force;

#there shoudl be a better way of doing this elegantly
my @arrayofhashes = definehashes();
my %applications = %{$arrayofhashes[0]};
my %forces = %{$arrayofhashes[1]};

### if run without filename or options, give help
if (@ARGV == 0) {
	printhelp();
	exit;
	};

##gather command line options
GetOptions ("-force=s" => \$force);


#anything left on command line is the file
my $filename = shift @ARGV;

unless (-e $filename) {
	print "I can't find file $filename\n";
	exit;
	};

$filename = cleanfilename($filename);


###parse filename to look for extension
my $extension = getextension($filename);
$extension = fixextension($extension);
print $filename;

print "Extension is: $extension\n";

if ($force) {
	if (exists $forces{$force}) {
	 	system("open -a $forces{$force} $filename &");
	 	print "Forcing $forces{$force} to open $filename\n";
	 	} else {
	 	print "ERROR: I can't recognize -force $force\n";
	 	printhelp();
	 	exit;
	 	};
	} else { #force setting not used
 
	if (exists $applications{$extension}) {
		system("open -a $applications{$extension} $filename &");
		print "Opening $filename with $applications{$extension}\n";
		} else {
		print "ERROR: Can't determine how to open $filename\n";
		};
	};
	
exit;

#####
# SUBROUTINES
######
sub getextension {
	my $filename = shift;
	my @fileparts = split (/\./, $filename);
	my $extension = pop @fileparts;
	return $extension;
	};

sub fixextension {
	my $extension = shift;
	$extension =~ s/^\s+//;
	$extension =~ s/\s+$//;
	$extension = "."."$extension";
	return $extension;
	};
	
sub printhelp {
	print "\nAutomatically opens appropriate GUI application to open file.\n";
	print "OPTIONS:\n";
	print "\t-force <application name>\tforces specific application to open file\n";
	print "\tForces are:\n";
	print "\t\tillus - Illustrator\n";
	print "\t\tword - Word\n";
	print "\t\texcel - Excel\n";
	print "\t\ttw - TextWrangler\n";
	print "\t\tprev - Preview\n";
	print "\n";
	};

sub definehashes {
	my %applications = (
		".doc" => "Microsoft\\ Word",
		".docx" => "Microsoft\\ Word",
		".xls" => "Microsoft\\ Excel",
		".xlsx" => "Microsoft\\ Excel",
		".ppt" => "Microsoft\\ PowerPoint",
		".pptx" => "Microsoft\\ PowerPoint",
		".odt" => "LibreOffice",
		".txt" => "TextWrangler",
		".pdf" => "Preview",
		".odp" => "LibreOffice",
		".ods" => "LibreOffice",
		".svg" => "Firefox",
		".ai" => "Adobe\\ Illustrator",
		".jpg" => "Preview",
		".png" => "Preview",
		".pl" => "TextWrangler",
		".py" => "TextWrangler",
		);

	##### here, add a hash for the forces
	my %forces = (
		"illus" => "Adobe\\ Illustrator",
		"word" => "Microsoft\\ Word",
		"excel" => "Microsoft\\ Excel",
		"tw" => "TextWrangler",
		"prev" => "Preview",
		);
	return (\%applications, \%forces);
	};

sub cleanfilename {
	my $filename = shift;
	$filename =~ s/ /\\ /gi;
	return $filename;
	};	