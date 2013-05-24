#!/usr/bin/perl -w
use strict;
use HTML::Strip;
use LWP::Simple;
use Getopt::Long;
use DateTime;
#use DateTime::Format::Human::Duration;
#use Date::Parse;


if (@ARGV == 0) {
	printusage();
	exit;
	};

my ($location, $startdate, $enddate);


GetOptions (
	"location=s" => \$location,
	"startdate=s" => \$startdate,
	"enddate=s" => \$enddate,
	);

$| = 1;  #turn buffer off

#convert the inputs into a standardized format
my ($station, $startday, $startmonth, $startyear, $endday, $endmonth, $endyear) = checkoptions($location, $startdate, $enddate);

print "Location = $station\n";
print "\tStart Month = $startmonth\n\tStart Day = $startday\n\tStart Year = $startyear\n";
print "\n\tEnd Month = $endmonth\n\tEnd Day = $endday\n\tEnd Year = $endyear\n";

#create DateTime objects
my $start = DateTime->new(
	year => $startyear,
	month => $startmonth,
	day => $startday,
	);
	
my $end = DateTime->new(
	year => $endyear,
	month => $endmonth,
	day => $endday,
	);


my $stringstarttime = $start->strftime("%Y-%m-%d");
my $stringendtime = $end->strftime("%Y-%m-%d");


my @dates;	
my $nextday = $start;

while () {
	my $stringtime = $start->strftime("%Y-%m-%d");
	push (@dates, $stringtime);
	$start->add(days => 1);
	my $cmp = DateTime->compare($end, $start);
	if ($cmp == 0) {last};
	};



#remove timestamp from each entry in dates
for (my $i = 0; $i < @dates; $i++) {
	$dates[$i] =~ s/T.+$//;
	$dates[$i] =~ s/^\s+//;
	};


my %headers;
my @alldata;

foreach (@dates) {
	my $date = $_;
	print "\rGathering $date from $station";
	my ($weatherdata, $url) = getweatherdata($date, $station);
	my @weatherline = split (/\n/, $weatherdata);
	foreach (@weatherline) {
		chomp;
		if ($_ =~ m/^\s*$/) {next};
		if ($_ =~ m/^Time/) {
			$headers{$_} = 0;
			next;
			};
		if ($_ =~ m/^\s*$/) {next};
		my @data = split(/,/, $_);
		@data = fillvoids(\@data);
		push (@alldata, \@data);
		};
	};


print "\n\n";


##### Check to make sure there is just one unique header

if (keys %headers > 1) {
	die "ERROR. There are more than 1 headers in the WeatherUnderground data. [A format change] Check manually\n";
	};


my $outfile = "$station"."_weather_"."$stringstarttime"."_"."$stringendtime".".txt";
open OUT, ">$outfile";

my $solarradcolumn;
foreach my $header ( keys %headers) {
	my @array = split (/,/, $header);
	for (my $i = 0; $i < @array; $i++) {
		if ($array[$i] =~ m/SolarRadiation/) {
			$solarradcolumn = $i;
			};
		};
	print OUT join ("\t",@array) . "\n";
	};
	

if ($solarradcolumn) {
	print "I found a column for solar radiation. I will replace NA's with 0's\n";
	};
	

for (my $i = 0; $i < @alldata; $i++) {
	if ($solarradcolumn) {
		if ($alldata[$i][$solarradcolumn] =~ m/NA/) {
			$alldata[$i][$solarradcolumn] = 0;
			};
		};
	print OUT join ("\t", @{$alldata[$i]}) . "\n";
	};
	

print "Open outfile $outfile\n";
$| = 0;
close OUT;
exit;

##########
# SUBROUTINE
##########

	
		
sub getweatherdata {
	my $date = shift;
	my $station = shift;
	my ($year, $month, $day) = split(/-/, $date);
	my $url = "http://www.wunderground.com/weatherstation/WXDailyHistory.asp?ID="."$station"."&day=".$day."&year=".$year."&month=".$month."&format=1";
	my $weatherdata = get("$url");
	my $htmlstrip = HTML::Strip->new();
	my $cleanedweatherdata = $htmlstrip->parse($weatherdata);
	$htmlstrip->eof();
	#print "Retrieved weather data for $date\n";
	$cleanedweatherdata =~ s/<br>//g;
	$cleanedweatherdata =~ s/\n+/\n/g;
	$cleanedweatherdata =~ s/^\s*$//g;
	return ($cleanedweatherdata, $url);
	};

sub printusage {
	print "\n";
	print "-----------------------------------------------------------------------------\n";
	print "| Gathers data from Weather Underground for every day over a period of time |\n";
	print "-----------------------------------------------------------------------------\n";
	print "USAGE:\n";
	print "\t-location\teither Weather Underground station name\n";
	print "\t\t\t\t or strings matching 'guadalajara' or 'boyd canyon' for shortcuts\n";
	print "\t-startdate\tin MM/DD/YYYY format\n";
	print "\t-enddate\tin MM/DD/YYYY format\n";
	print "\n";
	print "OUTPUT: long table of weather data with headers\n";
	print "-----------------------------------------------------------------------------\n";
	};

sub checkoptions{
	my ($location, $startdate, $enddate) = @_;
	my ($station, $startday, $starmonth, $startyear, $endday, $endmonth, $endyear);
	if ($location =~ m/Boyd/gi) {
		#location is boyd canyon
		$station = "KCAPALMD17";
		} elsif ($location =~ m/guada/gi) {
		#location is guadalajara
		$station = "IJALISCO21";
		} else {
		printusage();
		print "WARNING: I don't automatically understand location $location\n";
		};
	
	my @splitstart = split(/\/|-/, $startdate);
	my @splitend = split(/\/|-/, $enddate);
	($startmonth, $startday, $startyear) = @splitstart;
	($endmonth, $endday, $endyear) = @splitend;
	
	if (length $startyear == 2) {
		$startyear = "20"."$startyear";
		};
	if (length $endyear == 2) {
		$endyear = "20"."$endyear";
		};
		
	return ($station, $startday, $startmonth, $startyear, $endday, $endmonth, $endyear);
	};

sub fillvoids {
	my @data = @{$_[0]};
	my $filler = $_[1];
	if ($filler) {
		} else {
		$filler = "NA";
		};
	for (my $i = 0; $i < @data; $i++) {
		if ($data[$i]) {
			} else {
			$data[$i] = $filler;
			};
		};
	return @data;
	};