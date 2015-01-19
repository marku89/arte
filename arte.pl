#!/usr/bin/perl
# Mar
# Download for arte files 
# wget http://arte.tv/papi/tvguide/videos/livestream/player/D/
# v0.8.3
use strict;
use warnings;


my $file=" "; # filename to write 
my $ogfolder="/arte/stream"; # folder to store
my $old=" "; # old filename to fetch the change of the mega data 
my $pid;
my $meta;
my $json;
my $date;
my $startdate;
my $offset;
my $ID=0; # ID to seperate the screens and kill them
my $URL;
my $OLDURL=" ";
my $first=1;
my $rechte=0;
my $pass=0;
my $plus=0;
my $notlive=0;
my $pjson="";
my $path="";
my $purl="";
my ($mp4,$seite);

# url from arte !
my $url="http://arte.tv/papi/tvguide/videos/livestream/player/D/";
my $rtmp="rtmp://artestras.fcod.llnwd.net/a3903/o35/";

# get init url
my $text;
my $filename;

if ( `cat /var/lock/arte` )
{
	print "arte collector runs !!\n";
	exit 1;
}
else
{
	`echo "runs" > /var/lock/arte`;
}


if ( @ARGV ) 
{
	print "No Arguments NEEDED\n arte.pl v0.8.2\n\n";
	exit 1;
}

`mkdir -p $ogfolder`;

while (1) 
{
	&urlparse();
	if ( $file ne $old )
	{
		if ( $first || $file eq " " )
		{
			print "INPUT1 File: $file || ID: $ID  || orgfile: $filename\n";
			$first=0;
		}
		if ( `find $ogfolder -name "*$ID*.mp4" 2> /dev/null` )
		{
			print "exists\n";
		 	sleep 1;
			$old = $file; # for the next round
		        # check if rtmpdump runs
		        &killoldpid();
			next;
		}
		# Wenn keine fehler oder doppelungen aufgetreten sind , dann wird aufgenommen
		print "INPUT2 File: $file || ID: $ID  || orgfile: $filename || ??Plus = $plus\n";
                print "gotopidcheck: R:$rechte, P:$pass, PLUS:$plus, L:$notlive\n";
                &killoldpid();
		if ( $plus == 0 && $rechte )
		{
			`echo "rtmpdump -v -r \\\"rtmp://artestras.fc.llnwd.net/artestras/s_artestras_scst_geoFRDE_de?s=1320220800&h=878865258ebb8eaa437b99c3c7598998\\\" -o \\\"$ogfolder/$file\\\"" > /tmp/run.sh`; 
			system("screen -dmS $ID-rtmp bash /tmp/run.sh"); # start the ffmpeg dump detached 
			# write Metadata
			chomp($meta);
			print "get meta and record !! \n";
			`echo \"$meta\n\n\" > $ogfolder/$file.meta.txt`;
			`echo $json >> $ogfolder/$file.meta.txt`;
			# debug output
			print "\nruned: PID $pid ,ID $ID \n";
		}
		$old = $file; # for the next round 
		$first=1;
	}
	sleep 1;
}

sub killoldpid()
{
	#print "get the current screen pid";
	$pid = `ps aux | grep rtmpdump | grep -v grep | grep 1320220800 | sed 's/root\\s\\+//g' | cut -d " " -f1`;
	chomp($pid);
	if ( $pid )
        {
            `killall -2 rtmpdump`;
	     sleep 2;
	     if ( `ps aux | grep rtmpdump | grep -v grep | grep 1320220800 | sed 's/root\\s\\+//g' | cut -d " " -f1` )
	     {
		#killardly
            	`killall rtmpdump`;
	     }
            print "\nkilled rtmpdump with pid $pid\n";
        }
}

sub urlparse()
{
	$date = `date +"%Y%m%d"`;
	# rest values
	$rechte=0;
	$pass=0;
	$plus=0;
	$notlive=0;

	chomp($date);

	$text=`wget --timeout=5 $url -qO-`;
        # Json dump , debug
        $json = $text;
	#$path = " ";	
	# Prüfung ob Live rechte da sind ?
	$URL =  $text;
	$URL =~ s/.*VUP":"//;
	$URL =~ s/".*//;
	$URL =~ s/{/dummy/;
	if ( $URL ne $OLDURL && $URL && $URL ne "dummy" )
	{
		# debug url # nicht einkomentiern !!!
		#$URL = "http://www.arte.tv/guide/de/016992-000/breaking-the-waves";
		print "New URL : $URL\n";
		$seite = `wget $URL -qO - | tail -n +630`;
	    	print "getpage";
	        if ( grep{/Als Live verfügbar: nein/}$seite)
		{
			# wenn nicht live verfügbar
	    	  	print "!KeineRechte!";
	      		$rechte=0;
	      	}
		else
                {
                        $rechte=1;
                }
		if ( grep{/Arte\+7: nein/}$seite )
		{
			print "!7N!\n";
			$plus = 0;
		}
		else
		{
			print "!7+!\n";
			$plus=1;
		}
		$OLDURL=$URL;
	}
	# text umbau so das keine probleme enstehen beim parsen
	$text =~ s/ /_/g;
	$text =~ s/\(/_/g;
	$text =~ s/\)/_/g;
	$text =~ s/\//_/g;
	$text =~ s/\?//g;
	$text =~ s/!//g;
	$text =~ s/&//g;
	#$text =~ s/\'//g;	
	#$text =~ s/\://g;
	#$text =~ s/\"//g;
	
    	# get Arte ID
	$ID = $text;
	$ID =~ s/.*VPI":"//;
	$ID =~ s/".*//;
	if ( $ID eq "{" || !$ID )
	{
		$ID = 0;
	}
	$ID =~ s/-/_/;
	# dateinamen erzeugung
	$file = $text;
	#print "==FILEIST:$file==";	
	$file =~ s/.*"VTI":"//;
	$file =~ s/,.*/.mp4/;
        $file =~ s/'//g;      
        $file =~ s/://g;
        $file =~ s/"//g;
	#print "==FILEIST:$file==";
	
	$filename=$file;
	$file = "$date-$ID-$file";
	# Meta daten 
	$meta = $text;
	$meta =~ s/.*"VDE":"//; 
	$meta =~ s/",".*//;
	$meta =~ s/_/ /g;
	# file backup 
	if (!$file)
	{
		$date = `date +"%Y%m%d_%H"`;
		chomp($date);
		$file = "$date.mp4";
		print "1";
	}
	print ".";
}
