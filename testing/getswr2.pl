#!/usr/bin/perl
use strict;
use warnings;


my $date;
my $ogfolder = "/arte/swr2/";


if ( ! $ARGV[0] )
{
        $date = `date -d "now -1 day" "+%Y%m%d"`;
}
else
{
        $date=$ARGV[0];
}
chomp($date);

# get list from yesterday <-
my $list = `wget -qO- "http://www.swr.de/swr2/programm" | grep $date | grep -v did | sed 's/.*http/http/;s/html.*/html/'`;
chomp($list);
#print "yesterday url:==$list==";
my @liste = `wget -qO- "$list" | grep "Audio anhören" | sed 's/.*http/http/;s/html.*/html/'`;
my $mp3;
my $out;

foreach my $in (@liste)
{
	chomp($in);
	## manual test
	#$in = ""; 
	print "==$in==\n";
	$mp3 = `wget -qO- "$in" | grep "file:.*mp3" | sed 's/.*http/http/;s/mp3.*/mp3/' | head -n1`;
	chomp($mp3);
	print "==$mp3==\n";

	# name check
	# ==http://www.swr.de/swr2/programm/sendungen/literatur/thomas-glavinic-der-jonas-komplex/-/id=659892/did=17635198/nid=659892/nr0xnp/index.html==
	# --http://pd-ondemand.swr.de/swr2/literatur/on-demand/2016/06/868861.12844s.mp3--
	my $name = $mp3;
	$name =~ s/.*\///;
	print "--$name--\n";
	$out = $name;
		
	if ( $mp3 =~ m/on-demand/ || $mp3 =~ m/sendungen-ondemand/ || $mp3 =~ m/tagesgespraech/ || $name =~ m/^\d+/ )
	{
		my $name = $in;
        	$name =~ s/\/-\/id=.*//;
	        $name =~ s/.*\///;
	        print "--$name--\n";
		#print "need name!! $mp3";
		$out =  "$name.mp3";
	}
	
	# doppler check
	if ( ! `find $ogfolder -name "*$out*" 2> /dev/null` )	
	{	
		print "Download !\n";
		$out = "$date-$out";
		chomp($out);
		print "cd $ogfolder; wget -O $out \\\"$mp3\\\" \n\n";
		`echo "cd $ogfolder; wget -O $out \\\"$mp3\\\" " > /tmp/runswr2.sh`;
                system("screen -dmS $out-swr bash /tmp/runswr2.sh"); # start the wget dump detached
	}
}

