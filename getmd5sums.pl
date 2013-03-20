#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Pod::Usage;


=head1 NAME
	
	getmd5sums.pl  [OPTIONS] <FILEs> Get md5 checksums for files
	
=head1 SYNOPSIS
	
	Options: 
		-dir	get md5sums for all files in directory (. for cwd)
		-man	display full help
		-help	display quick help (you're looking at it)

=head1 AUTHOR
	
	Stephen Gross  smgross@lbl.gov  2013
	
=cut


my $dir;
my $man;
my $help;
my @files;

GetOptions (
	"dir=s" => \$dir,
	"help|h|?" => \$help,
	"man" => \$man,
	);

pod2usage() if $help;
pod2usage(-verbose => 2) if $man;

@files = @ARGV;

if ($dir) {
	$dir =~ s/\/$//g;  #remove trailing slash (if any)
	$dir = "$dir"."/";  #add it back
	my $listing = `ls -1 $dir`;
	@files = split(/\n/, $listing);
	} else {
	$dir = "./";
	};

my %results;
for (my $i = 0; $i < @files; $i++) {
	my $filename = "$dir"."$files[$i]";
	my $checksum = `md5sum $filename`;
	$checksum =~ s/$filename//g;
	$checksum =~ s/^\s+//g;
	$checksum =~ s/\s+$//g;
	$results{$filename} = $checksum;
	};

print "FILENAME\tmd5 CHECKSUM\n";
for my $filename (keys %results) {
	my $printfilename = $filename;
	if ($printfilename =~ m/^\.\//) {
		$printfilename =~ s/^\.\///;
		};
	print "$printfilename\t$results{$filename}\n";
	};

exit;