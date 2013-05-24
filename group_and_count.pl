#!/usr/bin/perl -w
use strict;

my %hash;

while (<>) {
	chomp;
	if (exists $hash{$_}) {
		my $tempnumber = $hash{$_};
		$tempnumber++;
		$hash{$_} = $tempnumber;
		}
	else {
		$hash{$_} = 1;
		};
	};



while (my ($k, $v) = each %hash) {
	if ($k =~ /^\s+/) {
		$k =~ s/^\s+//;
		};
	print "$k\t$v\n";
	};

