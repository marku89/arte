#!/usr/bin/perl
# Download for arte files 
# wget http://arte.tv/papi/tvguide/videos/livestream/player/D/
# rtmpdump -v -r "rtmp://artestras.fc.llnwd.net/artestras/s_artestras_scst_geoFRDE_de?s=1320220800&h=878865258ebb8eaa437b99c3c7598998" -o test.mp4 
# with lags ffmpeg -map 0.6 -map 0.7 -i "http://delive.artestras.cshls.lldns.net/artestras/contrib/delive.m3u8" -strict experimental test.mp4

use strict;
use warnings;


my $file; # filename to write 
my $ogfolder="~/arte/stream"; # folder to store
my $exclude="exclude"; # exclude list from doublicate checking
my $old=" "; # old filename to fetch the change of the mega data 
#my $stream; # stream m3u8 url # old
my $pid;
my $oldpid=0; #very ugly !
my $meta;
my $json;
my $date;
my $ID=0; # ID to seperate the screens and kill them
# url from arte !
my $url="http://arte.tv/papi/tvguide/videos/livestream/player/D/";
my $maps="-map 0.2 -map 0.3"; #low quali
#my $maps="-map 0.0 -map 0.1"; #high quali
# get init url
my $text;
my $filename;

`mkdir -p $ogfolder`;

# parse the url
&urlparse();

print "ID ist -$ID-\n";

while (1) 
{
	if ($file ne $old)
	{
		print "INPUT File: $file || ID: $ID  || orgfile: $filename\n";
		if ( glob("$ogfolder/*$filename") && !(`grep $filename $exclude`)  )
		{
			print "e";
           	 	sleep 1;
		        &urlparse();
            		next;
		}
		if ( $file =~ m/.*Live\.mp4/ ||  $file =~ m/.*ARTE_Journal\.mp4/ ) 
		{
                        print "l";
                        sleep 1;
                        &urlparse();
                        next;
                }
		#`echo "ffmpeg $maps -i $stream -strict experimental $ogfolder/$ID-$file" > /tmp/run.sh`; # writing it to a tmp sh file , because screen have problems with lots of arguement (fix me)
		`echo "rtmpdump -v -r \\\"rtmp://artestras.fc.llnwd.net/artestras/s_artestras_scst_geoFRDE_de?s=1320220800&h=878865258ebb8eaa437b99c3c7598998\\\" -o $ogfolder/$file" > /tmp/run.sh`; 
		system("screen -dmS $ID-rtmp sh /tmp/run.sh"); # start the ffmpeg dump detached 
		sleep 10; # wait so that the stream can start and wie capture some overlapping .
		$pid = `ps aux | grep rtmp | grep "$file" | awk '{print \$2}' | head -n 1`; # get the current screen pid
		chomp($pid);
		print "dritter mit PID $pid\n";
		if ( $oldpid ne 0 ) 
		{
			`kill -2 $oldpid`;
			sleep 5;
			`kill -2 $oldpid`;
			sleep 5;
			`kill $oldpid`;
			print "killed oldpid $oldpid\n";
		}
		# write Metadata
		chomp($meta);
		`echo $meta > $ogfolder/$file.meta.txt`;
		`echo $json >> $ogfolder/$file.meta.txt`;
		# debug output
		print "runed: PID $pid , OLD $oldpid, ID $ID \n";
		$oldpid = $pid; # for the next round 
		$old = $file; # for the next round 
		$ID++; # count the id UP
		`echo $ID > /tmp/ID`
	}
	sleep 1;
	&urlparse();
}


sub urlparse()
{
	$date = `date +"%Y%m%d"`;
	chomp($date);

	$text=`wget $url -qO-`;
	$text =~ s/ /_/g;
	$text =~ s/\(/_/g;
	$text =~ s/\)/_/g;
	$text =~ s/\//_/g;
    # Arte ID
    $ID = $text;
    $ID =~ s/.*IID":"//;
    $ID =~ s/".*//;
	# dateinamen erzeugung
	$file = $text;
	$file =~ s/.*"VTI":"//;
	$file =~ s/".*/.mp4/;
	$filename=$file;
	$file = "$date-$ID-$file";
	# Json dump , debug
	$json = $text;
	# Meta daten 
	$meta = $text;
	$meta =~ s/.*"VDE":"//; 
	$meta =~ s/",".*//;
	$meta =~ s/_/ /g;
	# file backup 
	if (!$file )
	{
		$date = `date +"%Y%m%d_%H"`;
		chomp($date);
		$file = "$date.mp4";
		print "1";
	}
	print ".";
}
