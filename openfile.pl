#!/usr/bin/env perl -w
use strict;
use Getopt::Long;
use Pod::Usage;  #a crude 1st attempt at implementation of this

=head1 NAME

openfile.pl  - A wrapper for the Mac OSX 'open' command

=head1 SYNOPSIS

openfile.pl [options] <file>

	Options:
	-force	forces specific application to open file
		forces are:
			illus - Illustrator
			word - Word
			excel - Excel
			tw - TextWrangler
			prev - Preview

	-help display quick help (you're looking at it)
	-man display full manual page

=head1 AUTHOR

	Stephen Gross, 2013

=head1 DESCRIPTION

	automatically determines what file types are to be opened
	executes command to open up file with a GUI application
	run without options to get help or use -help

=cut

my $force;
my $help;
my $man;


#there should be a better way of doing this elegantly
#get hashes from those in the subroutine definehashes()
my @arrayofhashes = definehashes();
my %applications = %{$arrayofhashes[0]};
my %forces = %{$arrayofhashes[1]};

### if run without filename or options, give help
if (@ARGV == 0) {
	pod2usage();
	exit;
	};

##gather command line options and interpret; also using pod2usage
GetOptions (
	"-force=s" => \$force,
	"help|?" => \$help,
	"man" => \$man,
	);

pod2usage() if $help;
pod2usage(-verbose => 2) if $man;
    
#anything left on command line is the file
my $filename = shift @ARGV;

#make sure the file exists
unless (-e $filename) {
	print "I can't find file $filename\n";
	pod2usage();
	exit;
	};

#send $filename to cleanfilename to properly escape spaces in filenames
$filename = cleanfilename($filename);


###parse filename to look for extension
my $extension = getextension($filename);
$extension = fixextension($extension);

print "Extension is: $extension\n";

if ($force) {
	if (exists $forces{$force}) {
	 	system("open -a $forces{$force} $filename &");
	 	print "Forcing $forces{$force} to open $filename\n";
	 	} else {
	 	print "ERROR: I can't recognize -force $force\n";
	 	pod2usage();
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
		".csv" => "Microsoft\\ Excel",
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
	#escape spaces
	$filename =~ s/ /\\ /g;
	#escape parenthesis
	$filename =~ s/\(/\\\(/g;
	$filename =~ s/\)/\\\)/g;
	return $filename;
	};	
