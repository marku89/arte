#!/usr/bin/perl
# Download for arte files 
# wget http://arte.tv/papi/tvguide/videos/livestream/player/D/
# rtmpdump -v -r "rtmp://artestras.fc.llnwd.net/artestras/s_artestras_scst_geoFRDE_de?s=1320220800&h=878865258ebb8eaa437b99c3c7598998" -o test.mp4 
# better ! no lags ffmpeg -map 0.6 -map 0.7 -i "http://delive.artestras.cshls.lldns.net/artestras/contrib/delive.m3u8" -strict experimental test.mp4

my $file;
my $old;
my $length;
my $stream;
my $geturl;
# url from arte !
my $url="http://arte.tv/papi/tvguide/videos/livestream/player/D/";
# get init url
my $text;
# parse the url
&urlparse();

while (1) 
{
	sleep 3;
	&urlparse();
	while ($file ne $old)
	{
		print "rtmpdump -v -r \"$stream$geturl\" -m $length -o $file";
		$old = $file;
		exit;
	}
}


sub urlparse()
{
	$text=`wget $url -qO-`;
	$text =~ s/ /_/g;

	$file = $text;
	$file =~ s/.*"VTI":"//;
	$file =~ s/".*/.mp4/;
	
    $length = $text;
    $length =~ s/.*"VTI":.*"BDS"://;
    $length =~ s/,".*//;

	$stream = $text;
	$stream =~ s/.*"streamer":"//;
	$stream =~ s/".*//;
	
	$geturl = $text;
	$geturl =~ s/.*"streamer":.*"url":"s_/s_/;
    $geturl =~ s/".*//;	

	print "Next File: $file || $length secs || $stream || $geturl\n";
}
