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
	print "$data\n";
	$i = $data;
}
chomp($i);

my $rechte = `wget $i -qO - | grep "Arte+7: nein"`;
if ( $rechte )
{
	print "no rights to download at 7+\n";
	exit;
}

my $AID = $i;
## /de/videos/
$AID =~ s/.*de\///g;
$AID =~ s/videos\///;
$AID =~ s/\/.*//;

print " \n==$AID==\n";
my $json = `wget https://api.arte.tv/api/player/v1/config/de/$AID?platform=ARTEPLUS7 -qO - `;
print "wget https://api.arte.tv/api/player/v1/config/de/$AID?platform=ARTEPLUS7 -qO -\n";

if ( grep { /AUSSCHNITT/  } $json ) 
{
        print "only AUSSCHNITT , no download !\n";
        exit;
}

# cleare json
$json =~ s/\\\//\//g;
$json =~ s/\(//g;
$json =~ s/\)//g;
$json =~ s/'//g;
$json =~ s/!//g;


print "$json";
#exit

my $mp4;
$mp4 = `echo '$json' | grep "HTTPS_MP4_SQ_1" -A8 | grep url | head -n1`;
$mp4 =~ s/.*http/http/;
$mp4 =~ s/mp4.*/mp4/;
chomp($mp4);

print "MP4: $mp4\n";

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

my $file = `echo '$json' | grep "VTI"`;
$file =~ s/.*"VTI": "//;
$file =~ s/".*/\.mp4/;
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
$file =~ s/\//-/g;
$file =~ s/\\//g;
$file =~ s/\///g;
$file =~ s/!//g;

#print "=$file= \n";
#exit;

$file = "$date-$ID-$file";
chomp($file);

print "--$file--$mp4--\n";

my $ogfolder="/arte/stream";



`echo '$json' > $ogfolder/$file.meta.txt`;

#print "wget \"$mp4\" -c -O $file >> /tmp/wget-log\n";
`echo 'wget $mp4 -c -O $ogfolder/$file' >> /tmp/wget-log`;
`wget $mp4 -c -O $ogfolder/$file`;
