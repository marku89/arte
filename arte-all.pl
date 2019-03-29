#!/usr/bin/perl
# arte parser for every content on the page  
# - dont delete the sleeps , because arte has a connetion limit at 20 per 10 sec 
# 

use warnings;
use strict;

my $date;
my $ogfolder="/arte/stream";
my $homefolder="/arte/arte";
my $ID;
my @liste;
my @prog; 

if ( ! $ARGV[0])
{
           print "USE with url Argument in \"\$URL\" ! ";
}
else
{
        @prog = $ARGV[0];
        chomp(@prog);
}


foreach my $line (@prog)
{
	if ( $line =~ m/RC-/)
	{
		@liste = @prog;
		next;
	}
	print "GET $line\n";
	chomp($line);
	my @listet = `wget $line -qO- | tr ':' '\n/'`;
	#my @listet = `wget $line -qO- | tr ':' '\n/' | grep subtitle | sed 's/",.*//'`;
	chomp(@listet);
	my $count = 0;
	foreach my $ln (@listet)
	{
		#print "$ln\n";
		if ( $ln =~ 'next-teaser__duration' )
		{
			#print "Found sting !! \n";
			$count++;
		}
		if ( $ln =~ 'subtitle' )
		{
			$ln =~ s/",.*//;
			#print "found url $ln\n";
			push @liste,$ln;
		}
		if ( $ln =~ 'RC-' )
		{
			#print "found RC-";
			$count++;
		}
	}
	if ( $count == 0 )
	{
		print "Sting not found, There is no content on the page !\n";
		sleep 1;
		exit 1;
	}
	print "counter $count\n";
	#push @liste, @listet;
	# slow the request per sec down , arte blocks more than 2 per second
	sleep 1; 
	# copy list to rc 
}
my @rcliste = @liste ; 
#print @liste;

if ( !@liste )
{
	print "LISTE LEER exit now \n";
	exit;
}

# get subfolders lists to downloand
foreach my $line (@rcliste)
{
	# test if guide/rc is in the line
        if ( $line =~ m/RC-/ )
        {
		chomp($line);
		$line =~ s/\\u002F/\//g;
		$line =~ s/^\/\///g;
		print "GET RC --$line--\n"; 
 	        my @templiste = `wget $line -qO-  | grep --color url | tr ':' '\n/'   | grep arte.tv | grep videos | grep title | grep -v RC- | sed 's/",.*//'`;
 	        #print "wget $line -qO-  | grep --color url | tr ':' '\n/'   | grep arte.tv | grep videos | grep title | grep -v RC- | sed 's/\",.*//'";
		chomp(@templiste);
		#print @templiste;
		#foreach my $newline (@templiste) 
		#{
		#	print "--$newline--\n";
		#}
		push @liste, @templiste;
		#sleep 1; 
	}

}

# download complete list
foreach my $line (@liste)
{
	if ( $line =~ m/videos/ & $line !~ m/RC-/ )
	{
		$line =~ s/\\u002F/\//g;
		$line =~ s/\\//g;
		$line =~ s/\/\///;
			
		chomp($line);
		#print "GET $line    \n";
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
			next;
		}
		if ( ! `find $ogfolder -name "*$ID*.mp4*" 2> /dev/null` )
		{
			# limit screen 
			my $screen =  `screen -ls | grep arteDN | wc -l`;
			chomp($screen);
			if ( $screen > 10 )
			{
				print "Downloads $screen limit !!\n";
				sleep 30;
				# slow it more down
				if ($screen > 15 )
				{
					sleep 60; 
				} 
			}
			print "\nNO File found ... will Download -- $line --\n";
			#system("cd $ogfolder; $homefolder/parsebehind.pl \\\"http://$line\\\"");
			system("echo \"cd $ogfolder; $homefolder/parsebehind.pl \\\"http://$line\\\"\" > /tmp/run7.sh");
			#print "$homefolder/parsebehind.pl \"http://$line\"";
			system("screen -dmS $ID-arteDN bash /tmp/run7.sh"); # start the ffmpeg dump detached 
			#`rm /tmp/run7.sh`;
			sleep 1;
		}
	}		
}
