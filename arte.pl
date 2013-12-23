#!/usr/bin/perl
# Download for arte files 
# wget http://arte.tv/papi/tvguide/videos/livestream/player/D/
# rtmpdump -v -r "rtmp://artestras.fc.llnwd.net/artestras/s_artestras_scst_geoFRDE_de?s=1320220800&h=878865258ebb8eaa437b99c3c7598998" -o test.mp4 
# better ! no lags ffmpeg -map 0.6 -map 0.7 -i "http://delive.artestras.cshls.lldns.net/artestras/contrib/delive.m3u8" -strict experimental test.mp4

use strict;
use warnings;


my $file; # filename to write 
my $olgasfolder="/home/markus/arte/stream"; # folder to store
my $old=" "; # old filename to fetch the change of the mega data 
my $stream; # stream m3u8 url
my $pid;
my $oldpid;
my $ID=0; # ID to seperate the screens and kill them
# url from arte !
my $url="http://arte.tv/papi/tvguide/videos/livestream/player/D/";
my $maps="-map 0.6 -map 0.7"; #low quali
#my $maps="-map 0.0 -map 0.1"; #high quali
# get init url
my $text;

`mkdir -p /home/markus/arte/stream/`;
# parse the url
&urlparse();


while (1) 
{
	if ($file ne $old)
	{
		print "Next File: $file || $stream || $ID \n";
		`echo "ffmpeg $maps -i $stream -strict experimental $olgasfolder/$file" > /tmp/run.sh`; # writing it to a tmp sh file , because screen have problems with lots of arguement (fix me)
		system("screen -dmS $ID-ffmpeg sh /tmp/run.sh"); # start the ffmpeg dump detached 
		$pid = `screen -ls | grep ffmpeg | grep -v .1 | sed 's/\\s+//;s/.$ID-ffmpeg.*//'`; # get the current screen pid
		sleep 10; # wait so that the stream can start and wie capture some overlapping . 
		if ( $oldpid ) 
		{
			`kill $oldpid`;
		}
		$oldpid = $pid; # for the next round 
		$old = $file; # for the next round 
		$ID++; # count the id UP
		print "--runed: PID $pid , OLD $oldpid, ID $ID \n";
	}
	sleep 3;
	&urlparse();
}


sub urlparse()
{
	$text=`wget $url -qO-`;
	$text =~ s/ /_/g;
	
	$file = $text;
	$file =~ s/.*"VTI":"//;
	$file =~ s/".*/.mp4/;
	
	$stream = $text;
	$stream =~ s/.*"bitrate":.*"url":"http/http/;
    $stream =~ s/".*//;	
	
	if (!$file || !$stream)
	{
		$file = `date +"%Y%m%d_%H%M.mp4"`;
		$stream = "http://delive.artestras.cshls.lldns.net/artestras/contrib/delive.m3u8";
	}
	print "Get: $file || $stream \n";
}
