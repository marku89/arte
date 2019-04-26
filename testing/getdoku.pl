#!/usr/bin/perl
use strict;
use warnings;

# get doku url !!
my @liste = `wget "http://www.zdf.de/ZDFmediathek/senderstartseite/sst0/1209120?teaserListIndex=50&flash=off" -qO- | grep "<p class.*beitrag"`;
my ($deeh,$ID,$base,$title,$ver,$mp4);
my $count = 0;
my $zdf = "/z/arte/zdf-doku";
my $date = `date +"%Y%m%d"`;

foreach my $i (@liste)
{
	#print "==$i==";
	if ( $count == 1 )
	{
		$count = 0;
		next;
	}
	$ID = $i;
	$ID =~ s/.*video\///;
	$ID =~ s/\/.*//;
	chomp($ID);
	$deeh = $i;
	$deeh =~ s/\?.*//;
	$deeh =~ s/.*\///;
	$deeh =~ s/%\d+//g;	
	chomp($deeh);
	print "NAME==$deeh==ID==$ID==\n";
	# now we get the ID and The filename !
	# go on to the xml service :)
	if ( !$ID || !$deeh )
	{
		print "Valules no filled !!!\n";
		exit 1;
	}
	my @xml = `wget -qO- "http://www.zdf.de/ZDFmediathek/xmlservice/v2/web/beitragsDetails?ak=web&id=$ID"`;
	foreach my $d (@xml)
	{	
		if ( $d =~ m/<title>/)
                {
                        $title = $d;
                        $title =~ s/<title>//;
                        $title =~ s/<\/title>//;
                        $title =~ s/\s+/ /g;
                        $title =~ s/ /-/g;
                        $title =~ s/://g;
                        $title =~ s/-$//g;
                        chomp($title);
                        print "==title--$title==";

                }
		if ( $d =~ m/<basename>/)
		{
			$base = $d;
			$base =~ s/<basename>//;
			$base =~ s/<\/basename>//;
			$base =~ s/ //g;
			chomp($base);
			print "==basename--$base==";
		
		}
                if ( $d =~ m/<streamVersion>/)
                {
                        $ver = $d;
                        $ver =~ s/<streamVersion>//;
			$ver =~ s/<\/streamVersion>//;
                        $ver =~ s/ //g;
			chomp($ver);
                        print "==vers--$ver==";
                }

	}
	## download the film , if its not exists
	if ( ! `find $zdf -name "*$ID*.mp4" 2> /dev/null` )
	{
		$mp4 = `wget "http://www.zdf.de/ptmd/vod/mediathek/$base/$ver" -qO-  | grep nrodl | grep 1456k`;
		$mp4 =~ s/ //g;
		chomp($mp4);
		chomp($date);
		print "\n==$mp4==\n";
		print "\nhttp://www.zdf.de/ptmd/vod/mediathek/$base/$ver\n";
		print "wget -qO$zdf/$date-$ID-$title.mp4 $mp4";
		`echo "wget -qO$zdf/$date-$ID-$title.mp4 $mp4" > /tmp/runzdf.sh`;
                system("screen -dmS $ID-rtmp bash /tmp/runzdf.sh"); # start detached 


	}
	$count = 1;
}
