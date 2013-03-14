#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Pod::Usage;


=head1 NAME

	getmd5sums.pl   Get md5 checksums for all files in a directory

=head1 SYNOPSIS

	getmd5sums.pl [options]
	
	Returns a table of file names and md5 checksums to standard output
	
	Options:
		-dir	directory to use. Default = "." (working directory)
		-man	display full help
		-help	display quick help (you're looking at it)

=head1 AUTHOR

	Stephen Gross   2013

=cut


my $dir = ".";
my $man;
my $help;

GetOptions (
	"dir=s" => \$dir,
	"help|h|?" => \$help,
	"man" => \$man,
	);

pod2usage() if $help;
pod2usage(-verbose => 2) if $man;


#remove any trailing / from $dir

$dir =~ s/\/$//g;

my $listing = `ls -1 $dir`;

my @files = split(/\n/, $listing);

my %results;
for (my $i = 0; $i < @files; $i++) {
	my $filename = "$dir"."/"."$files[$i]";
	my $checksum = `md5sum $filename`;
	$checksum =~ s/$filename//g;
	$checksum =~ s/^\s+//g;
	$checksum =~ s/\s+$//g;
	$results{$filename} = $checksum;
	};

print "FILENAME\tmd5 CHECKSUM\n";
for my $file (keys %results) {
	print "$file\t$results{$file}\n";
	};
