#!/usr/bin/perl
# arte parser for 7 Plus one day 
# IF not set to date X the past day will used and should be run at 5AM 
# url basic http://www.arte.tv/guide/de/20141121


use warnings;
use strict;
my $date;
my $ogfolder="/arte/stream";
my $homefolder="/arte/arte";
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

# OLD 
#my @liste = `wget http://www.arte.tv/de/guide/$date -qO- | grep "<a data-track-array-click" | sed 's/<a data-track-array-click=.*href=//;s/ title.*//' | grep -v ">" | grep "[[:digit:]]" | sort | uniq`;
my @liste = `wget http://www.arte.tv/de/guide/$date -qO- | grep --color url | tr ':' '\n/' | grep www | grep -v categorie | sed 's/".*//;s/\\u002F/\\//g'  | grep -v permalink | sort | uniq`;

#print @liste;
#exit;

if ( !@liste )
{
	print "LISTE LEER exit now \n";
	exit;
}

foreach my $line (@liste)
{
	# test if guide is in the lin
	if ( $line =~ m/videos/ )
	{
		$line =~ s/\\//g;
		$line =~ s/\/\///;
		
		chomp($line);
		print "$line    \n";
	 	# www.arte.tv/de/videos/005105-000-A/die-zwei-leben-der-veronika 	
		$ID = $line;
		$ID =~ s/.*videos\///;
		$ID =~ s/\/.*//;
		$ID =~ s/-/_/;
		$ID =~ s/!//;
		$ID =~ s/-A//;
		print "=$ID=\n";
		if ( !$ID )
		{
			print "ID is leer\n";
			exit;
		}
		if ( ! `find $ogfolder -name "*$ID*.mp4*" 2> /dev/null` )
		{
			print "\nNO --$line-- found ... Download\n";
			`echo "cd $ogfolder; $homefolder/parsebehind.pl \\\"http://$line\\\" " > /tmp/run7.sh`;
			print "$homefolder/parsebehind.pl \"http://$line\"";
			system("screen -dmS $ID-rtmp bash /tmp/run7.sh"); # start the ffmpeg dump detached 
			sleep 1;
			`rm /tmp/run7.sh`;
		}
	}		
}
