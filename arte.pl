#!/usr/bin/perl
# Download for arte files 
# wget http://arte.tv/papi/tvguide/videos/livestream/player/D/
# rtmpdump -v -r "rtmp://artestras.fc.llnwd.net/artestras/s_artestras_scst_geoFRDE_de?s=1320220800&h=878865258ebb8eaa437b99c3c7598998" -o test.mp4 
# better ! no lags ffmpeg -map 0.6 -map 0.7 -i "http://delive.artestras.cshls.lldns.net/artestras/contrib/delive.m3u8" -strict experimental test.mp4

use strict;
use warnings;

my $file;
my $old;
my $length;
my $stream;
my $geturl;
my $ID=0;
# url from arte !
my $url="http://arte.tv/papi/tvguide/videos/livestream/player/D/";
my $maps="-map 0.6 -map 0.7"; #low quali
#my $maps="-map 0.0 -map 0.1"; #high quali
# get init url
my $text;
# parse the url
&urlparse();

while (1) 
{
	if ($file ne $old)
	{
		print "Next File: $file || $stream || $ID \n";
		$ID++;
		echo "ffmpeg $maps -i $stream -strict experimental $file" > /tmp/run.sh
		`screen -dmS $ID-ffmpeg sh /tmp/run.sh`;
		getting the new pid
		$pid = `screen -ls | grep $ID-ffmpeg | sed 's/\s+//;s/.$ID-ffmpeg.*//'`;
		sleep 10;
		if ( $oldpid ) 
		{
			`kill $oldpid`;
		}
		$oldpid = $pid;
		$old = $file;
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
