#!/usr/bin/perl -w
use strict;
use DateTime;
use DateTime::Event::Sunrise;
use DateTime::Format::Duration;
use Getopt::Long;

if (@ARGV == 0) {
	printusage();
	exit;
	};

my ($latitude, $longitude, $startdate, $enddate, $timezone);
  #-0.833 is the default altitude to calculate sunrise
#see notes at http://search.cpan.org/~rkhill/DateTime-Event-Sunrise-0.0501/lib/DateTime/Event/Sunrise.pm

GetOptions (
	"latitude=s" => \$latitude,
	"longitude=s" => \$longitude,
	"startdate=s" => \$startdate,
	"enddate=s" => \$enddate,
	"timezone=s" => \$timezone,
	);

$| = 1;  #turn buffer off


my ($startyear, $startmonth, $startday, $endyear, $endmonth, $endday) = checkends($startdate, $enddate);


my $outfile = "sunriset_"."lat-$latitude"."_long-$longitude".".txt";
open OUT, ">$outfile";
print OUT "date\tsunrise\tsunset\tsunrise_datetime\tsunset_datetime\tlatitude\tlongitude\ttime_zone\n";


#create DateTime objects
my $start = DateTime->new(
	year => $startyear,
	month => $startmonth,
	day => $startday,
	time_zone => $timezone,
	);
	
my $end = DateTime->new(
	year => $endyear,
	month => $endmonth,
	day => $endday,
	time_zone => $timezone,
	);


my @dates;

#create an array of date strings
while () {
	my $stringtime = $start->strftime("%Y-%m-%d");
	push (@dates, $stringtime);
	$start->add(days => 1);
	my $cmp = DateTime->compare($end, $start);
	if ($cmp == 0) {last};
	};

#calculate sunrise/sunset times
for (my $i = 0; $i < @dates; $i++) {
	my $date = $dates[$i];
	my ($year, $month, $day) = split (/-/, $date);
	#recreate DateTime object for that day
	my $dt = DateTime->new(year=>$year, month=> $month, day=>$day,time_zone => $timezone);
	my $sunriseobj = DateTime::Event::Sunrise->sunrise (
		longitude => $longitude,
		latitude => $latitude,
		altitude => -0.833,
		iteration => 0,

		);
	my $sunsetobj = DateTime::Event::Sunrise->sunset (
		longitude => $longitude,
		latitude => $latitude,
		altitude => -0.833,
		iteration => 0,

		);

	my $sunrise = $sunriseobj->next($dt);
	my $sunset = $sunsetobj->next($dt);
	#my $daylength = $sunset - $sunrise;
	#my $daylengthtime = $daylength->format_duration("%H:%M:%S");
	my $sunrisetime = $sunrise->strftime("%H:%M:%S");
	my $sunsettime = $sunset->strftime("%H:%M:%S");
	print OUT "$date\t$sunrisetime\t$sunsettime\t$date $sunrisetime\t$date $sunsettime\t$latitude\t$longitude\t$timezone\n";
	};
	
print "Open $outfile\n";

close OUT;
exit;



#########################
### SUBROUTINES #########
#########################


sub checkends {
	my ($startdate, $enddate) = @_;
	my ($startyear, $startmonth, $startday) = split (/\/|-/, $startdate);
	my ($endyear, $endmonth, $endday) = split (/\/|-/, $enddate);
	return ($startyear, $startmonth, $startday, $endyear, $endmonth, $endday);
	};

sub printusage {
	print "USAGE\n";
	print "\t-latitude\t\n";
	print "\t-longitude\t\n";
	print "\t-startdate YYYY/MM/DD\n";
	print "\t-enddate YYYY/MM/DD\n";
	print "\t-timezone\n";
	print "\n";
	print "Here's some coordinates:\n";
	print "\tAmatitan:\n\t\tLatitude = 20.84\tLongitude = -103.72\tTime Zone = 'America/Los_Angeles'\n";
	print "\tBoyd Canyon:\n\t\tLatitude =  33.63\tLongitude = -116.40\tTime Zone = 'America/Mexico_City'\n";
	
	};
	
