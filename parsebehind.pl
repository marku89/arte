#!/usr/bin/perl
use warnings;
use strict;
# mars
my $data;
my $i;

if ($ARGV[0] )
{
	$i = $ARGV[0];
}
else 
{
	print "Failed to ge \$1";
	exit 1;
}
if ( $i =~ m/^201/)
{
	$data = `cat $i.meta.txt | grep VUP `;
	$data =~ s/.*VUP://;
	$data =~ s/,VSR.*//;
	if (!$data) 
	{
		print "no data parse incorret use parsebehind \"filename\"\n";
		exit;
	}
	print "get data $data\n";
	$i = $data;
}
chomp($i);

my $rechte = `wget $i -qO - | grep "Arte+7: nein"`;
if ( $rechte )
{
	print "no rights to download at 7+\n";
	exit 3;
}

my $AID = $i;
## /de/videos/
## /en/videos/
$AID =~ s/.*\/de\/videos\///g;
$AID =~ s/.*\/en\/videos\///g;
$AID =~ s/\/.*//;

print " \nArteID==$AID==\n";
my $json = `wget --user-agent="Mozilla/5.0 (<h1>FUCK YOU, we still use WG3T xD)" \"https://api.arte.tv/api/player/v1/config/de/$AID?lifeCycle=1&lang=de_DE?RIPID=23\" -qO - `;

if ( !$AID )
{
	print "no arte id found !!\n";
	exit 2;
}

#print "wget https://api.arte.tv/api/player/v1/config/de/$AID?lifeCycle=1&lang=de_DE?RIPID=23 -qO - \n";

if ( grep { /AUSSCHNITT/  } $json ) 
{
        print "only AUSSCHNITT , no download !\n";
        exit 2;
}

# cleare json
$json =~ s/\\\//\//g;
$json =~ s/\(//g;
$json =~ s/\)//g;
$json =~ s/'//g;
$json =~ s/!//g;
$json =~ s/\?//g;

#print "$json";
#exit

my $mp4;
$mp4 = `echo '$json' | tr '}' '\n'  |  grep "HTTPS_SQ_1" | grep url | head -n1`;
#print "=MP4=1=$mp4==";
$mp4 =~ s/.*http/http/;
$mp4 =~ s/.*https/https/;
$mp4 =~ s/mp4.*/mp4/;
#print "=MP4=2=$mp4==";
#exit;
chomp($mp4);

print "MP4: $mp4\n";

#exit;

if ( !$mp4 )
{
	print "NO URL found, no live ?\n";
	exit;
}

my $date = `date +"%Y%m%d"`;
chomp($date);

# get Arte ID
my $ID = $AID;
$ID =~ s/-/_/;


my $file = $json;
chomp($file);
$file =~ s/.*"VTI":"//;
$file =~ s/":.*//;
#print "=1-=$file=-=\n"; 
$file =~ s/,.*/.mp4/;
#print "=2-=$file=-=\n";
$file =~ s/  / /g;
$file =~ s/ /_/g;
$file =~ s/'//g;
$file =~ s/://g;
$file =~ s/"//g;
$file =~ s/\(//g;
$file =~ s/\)//g;
$file =~ s/\[//g;
$file =~ s/\]//g;
$file =~ s/\+//g;
$file =~ s/&//g;
$file =~ s/\?//g;
$file =~ s/\//-/g;
$file =~ s/\\//g;
$file =~ s/\///g;
$file =~ s/\|//g;

print "final=$file= \n";

$file = "$date-$ID-$file";
chomp($file);

#print "all--$file--$mp4--\n";

my $ogfolder="/arte/stream";



`echo '$json' > $ogfolder/$file.meta.txt`;

#print "wget \"$mp4\" -c -O $ogfolder/$file >> /tmp/wget-log\n";
`echo 'wget $mp4 -c -O $ogfolder/$file' >> /tmp/wget-log`;
`wget $mp4 -c -O $ogfolder/$file`;
