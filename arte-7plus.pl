#!/usr/bin/perl
# arte parser for 7 Plus one day 
# IF not set to date X the past day will used and should be run at 5AM 
# url basic http://www.arte.tv/guide/de/20141121


use warnings;
use strict;
my $date;
my $ogfolder="/arte/stream";
my $homefolder="/home/markus/arte";
my $ID;


if ( ! $ARGV[0] )
{
	$date = `date -d "now -1 day" "+%Y%m%d"`;
	chomp($date);
}
else
{
	$date=$ARGV[0];
	chomp($date);
}


my @liste = `wget http://www.arte.tv/guide/de/$date -qO- | grep "<a data-track-array-click" | sed 's/<a data-track-array-click=.*href=//;s/ title.*//' | grep -v ">" | grep "[[:digit:]]" | sort | uniq`;

if ( !@liste )
{
	print "LISTE LEER exit now \n";
	exit;
}

foreach my $line (@liste)
{
	# test if guide is in the lin
	if ( $line =~ m/guide/ )
	{
		$line =~ s/'//g;
		chomp($line);
		#print "$line    \n";
		$ID = $line;
		$ID =~ s/.*de\///;
		$ID =~ s/\/.*//;
		$ID =~ s/-/_/;
		#print "$ID\n";
		if ( !$ID )
		{
			print "ID is leer\n";
			exit;
		}
		if ( ! `find $ogfolder -name "*$ID*.mp4" 2> /dev/null` )
		{
			print "NO $line found ... Download\n";
			`echo "cd $ogfolder; $homefolder/parsebehind.pl \\\"http://www.arte.tv$line\\\" " > /tmp/run7.sh`;
			system("screen -dmS $ID-rtmp bash /tmp/run7.sh"); # start the ffmpeg dump detached 
			sleep 3;
		}
	}		
}
