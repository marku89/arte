#!/usr/bin/perl
# Download for arte files 
# wget http://arte.tv/papi/tvguide/videos/livestream/player/D/
# v0.8.1
use strict;
use warnings;


my $file; # filename to write 
my $ogfolder="/arte/stream"; # folder to store
my $exclude="/home/markus/arte/exclude"; # exclude list from doublicate checking
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
my $pjson="";
my $path="";
my $purl="";
my $mp4;

# url from arte !
my $url="http://arte.tv/papi/tvguide/videos/livestream/player/D/";
my $rtmp="rtmp://artestras.fcod.llnwd.net/a3903/o35/";

# get init url
my $text;
my $filename;

if ( @ARGV ) 
{
	print "No Arguments NEEDED\n arte.pl v0.8.1\n\n";
	exit 1;
}

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
		#if ( $pass == 0 && $filename )
		if ( $filename )
		{
			if ( `ls $ogfolder/*-$ID* 2> /dev/null` && !`grep $filename exclude` )
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
		if ( !$plus )
		{
			`echo "rtmpdump -v -r \\\"rtmp://artestras.fc.llnwd.net/artestras/s_artestras_scst_geoFRDE_de?s=1320220800&h=878865258ebb8eaa437b99c3c7598998\\\" -o \\\"$ogfolder/$file\\\"" > /tmp/run.sh`; 
		}
		else
		{
			`echo "wget \\\"$path\\\" -c -O $file" > /tmp/run.sh`;			      
		}
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
	print "get the current screen pid";
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
	chomp($date);

	$text=`wget --timeout=5 $url -qO-`;
       # Json dump , debug
        $json = $text;	
	# Prüfung ob Live rechte da sind ?
	$URL =  $text;
	$URL =~ s/.*VUP":"//;
	$URL =~ s/".*//;
	$URL =~ s/{/dummy/;
	if ( $URL ne $OLDURL && $URL && $URL ne "dummy" )
	{
		# debug url 
		#$URL = "http://www.arte.tv/guide/de/046618-019/silex-and-the-city";
		print "New URL : $URL\n";
		my $seite = `wget $URL -qO - | tail -n +630`;
	    	print "getpage";
		#if ( grep(/Fernsehserie/,$seite) || grep {/ Doku-Reihe /} $seite || grep {m/ Magazin /} $seite)
		if ( grep {/Fernsehserie/} $seite or grep {/Doku-Reihe/} $seite or grep {/Magazin/} $seite or grep {/Reportage/} $seite )
                {
			#Ausnahme führ reihen
                        print "!Reihe!";
                        $pass=1;
                }
                else
                {
			#wenn nicht !
                	print "!KeineReihe!";
		        $pass=0;
                }
	        if ( grep{/Als Live verfügbar: nein/}$seite)
		{
			# wenn nicht live verfügbar
	    	  	print "!KeineRechte!";
	      		$rechte=1;
	      	}
		else
                {
                        $rechte=0;
                }
		if ( !grep{/Arte\+7: nein/}$seite)
		{
			print "!7+!\n";
			$plus = 1;
			$pjson = `wget $URL -qO - |  grep json | head -n 1`;
			if ( $pjson =~ m/script type=/ )
			#if ( $pjson =~ m/"VTX":"AUSSCHNITT"/ )
			{
		                print "!N7!\n";
        	                $plus=0;
			}
			else 
			{
				$pjson =~ s/.*arte_vp_url="//;
				$pjson =~ s/".*//;
				chomp($pjson);
				#$pjson = "http://arte.tv/papi/tvguide/videos/stream/player/D/048724-000_EXTRAIT-D/ALL/ALL.json";
				$purl = `wget $pjson -qO - `;
				#print "==$purl==$pjson";
				if ( $purl =~ m/"VTX":"AUSSCHNITT"/ )
				{
					print "NUR Ausschnitt !!!!!\n";
					$plus=0;
				}
				else
				{
					$mp4 = $purl;
				
					$mp4 =~ s/.*HTTP_MP4_SQ_1//;
					$mp4 =~ s/}.*//;
						
					$path = $mp4;
					$path =~ s/.*,"url":"//;
					$path =~ s/".*//;

					print "wget \"$path\" -c -O \$file\n";
				}
			}
		}
		else
		{
			print "!N7!\n";
			$plus=0;
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
	$text =~ s/\?//g;
	$text =~ s/\&//g;
	#$text =~ s/\'//g;	
	#$text =~ s/\://g;
	#$text =~ s/\"//g;
	
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
