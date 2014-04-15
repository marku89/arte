#!/usr/bin/perl
# Download for arte files 
# wget http://arte.tv/papi/tvguide/videos/livestream/player/D/

use strict;
use warnings;


my $file; # filename to write 
my $ogfolder="/arte/stream"; # folder to store
my $exclude="exclude"; # exclude list from doublicate checking
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

# url from arte !
my $url="http://arte.tv/papi/tvguide/videos/livestream/player/D/";

# get init url
my $text;
my $filename;

`mkdir -p $ogfolder`;

# parse the url
#&urlparse();

#print "ID ist -$ID-\n";

while (1) 
{
	&urlparse();
	if ( $file ne $old )
	{
		if ( $first )
		{
			print "INPUT1 File: $file || ID: $ID  || orgfile: $filename\n";
			$first=0;
		}
		#my $out=`ls $ogfolder/*$filename`;
		#print "--outist: $out --- \n";
		#exit;
		if ( $pass == 0 )
		{
			if ( `ls $ogfolder/*$filename 2> /dev/null` && !`grep $filename exclude` )
			{
			print "e";
		 	sleep 1;
			$old = $file; # for the next round
		        # check if rtmpdump runs
		        &killoldpid();
			next;
			}
		}
		if ( $file =~ m/.*Live\.mp4/ ||  $file =~ m/.*ARTE_Journal\.mp4/ || $file eq "notlive" ) 
		{
		        print "l";
		        sleep 1;
			$old = $file; # for the next round
		        # check if rtmpdump runs
		        &killoldpid();
			next;
		}
		# Wenn keine fehler oder doppelungen aufgetreten sind , dann wird aufgenommen
		print "INPUT2 File: $file || ID: $ID  || orgfile: $filename\n";
                print "gotopidchecki\n";
                &killoldpid();

		`echo "rtmpdump -v -r \\\"rtmp://artestras.fc.llnwd.net/artestras/s_artestras_scst_geoFRDE_de?s=1320220800&h=878865258ebb8eaa437b99c3c7598998\\\" -o $ogfolder/$file" > /tmp/run.sh`; 
		system("screen -dmS $ID-rtmp bash /tmp/run.sh"); # start the ffmpeg dump detached 
		# write Metadata
		chomp($meta);
		print "get meta";
		`echo \"$meta\n\n\" > $ogfolder/$file.meta.txt`;
		`echo $json >> $ogfolder/$file.meta.txt`;
		# debug output
		$old = $file; # for the next round 
		print "\nruned: PID $pid ,ID $ID \n";
		$first=1;
	}
	sleep 1;
}

sub killoldpid()
{
	# get the current screen pid
	$pid = `pidof rtmpdump`;
	chomp($pid);
	if ( $pid )
        {
            `killall -2 rtmpdump`;
	     sleep 2;
	     if ( `pidof rtmpdump` )
	     {
		#killardly
            	`killall rtmpdump`;
	     }
            print "\nkilled rtmpdump\n";
        }
}

sub urlparse()
{
	$date = `date +"%Y%m%d"`;
	chomp($date);

	$text=`wget $url -qO-`;
	
	# Prüfung ob Live rechte da sind ?
	$URL =  $text;
	$URL =~ s/.*VUP":"//;
	$URL =~ s/".*//;
	$URL =~ s/{/dummy/;
	if ( $URL ne $OLDURL && $URL && $URL ne "dummy" )
	{
		print "New URL : $URL\n";
		my $seite = `wget $URL -qO - | tail -n +630`;
	    	#print $page;
		#if ( grep(/Fernsehserie/,$seite) || grep {/ Doku-Reihe /} $seite || grep {m/ Magazin /} $seite)
		if ( grep {/Fernsehserie/} $seite or grep {/Doku-Reihe/} $seite or grep {/Magazin/} $seite )
                {
                        print "Keyword found";
                        $pass=1;
                }
                else
                {
                        $pass=0;
                }
	        if ( grep{/Als Live verfügbar: nein/}$seite)
		{
	    	  	print "Keine Rechte";
	      		$rechte=1;
	      	}
		else
		{
	      		$rechte=0;
	      	}
		$OLDURL=$URL;
		$first=1;
	}
	if ( $rechte == 1 )
	{
	      print "n";
              $file="notlive";
              $filename="notlive";
              return;	
	}
	# text umbau so das keine probleme enstehen beim parsen
	$text =~ s/ /_/g;
	$text =~ s/\(/_/g;
	$text =~ s/\)/_/g;
	$text =~ s/\//_/g;

    	# get Arte ID
	$ID = $text;
	$ID =~ s/.*IID":"//;
	$ID =~ s/".*//;
	if ( $ID eq "{" )
	{
		$ID = 0;
	}
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
	if (!$file)
	{
		$date = `date +"%Y%m%d_%H"`;
		chomp($date);
		$file = "$date.mp4";
		print "1";
	}
	print ".";
}
