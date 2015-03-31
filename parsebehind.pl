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


my $json = `wget $i -qO - |  grep json | head -n 1`;
$json =~ s/.*arte_vp_url='//; 
$json =~ s/'.*//; 
chomp($json);

if (!$json || $json =~ m/script type/)
{
	print "wgetfailure !!! \n\n";
	exit;
}
print "$json";
my $url = `wget $json -qO - `;

if ( grep { /AUSSCHNITT/  } $url ) 
{
        print "only AUSSCHNITT , no download !\n";
        exit;
}

my $mp4 = $url;
$mp4 =~ s/.*HTTP_MP4_SQ_1//;
$mp4 =~ s/}.*//;

my $path = $mp4;
$path =~ s/.*,"url":"//;
$path =~ s/".*//;

if ( !$path )
{
	print "NO URL found, no live ?\n";
	exit;
}

my $date = `date +"%Y%m%d"`;
chomp($date);

# get Arte ID
my $ID = $url;
$ID =~ s/.*VPI":"//;
$ID =~ s/".*//;
if ( $ID eq "{" )
{
        $ID = 0;
}
$ID =~ s/-/_/;

# Json dump , debug
$json = $url;
# Meta daten 
my $meta = $url;
$meta =~ s/.*"VDE":"//;
$meta =~ s/",".*//;
$meta =~ s/_/ /g;
# file backup 


my $file = $url;
$file  =~ s/ /_/g;
$file  =~ s/\(/_/g;
$file  =~ s/\)/_/g;
$file  =~ s/\//_/g;
$file  =~ s/\?//g;
$file  =~ s/\&//g;
$file  =~ s/\!//g;
$file  =~ s/\'//g;
$file  =~ s/\,//g;
$file  =~ s/}//g;
$file  =~ s/{//g;


$file =~ s/.*"VTI":"//;
$file =~ s/".*/.mp4/;
$file =~ s/'//g;
$file =~ s/://g;
$file =~ s/"//g;



$file = "$date-$ID-$file";

my $ogfolder="/arte/stream";

chomp($meta);
`echo \"$meta\n\n\" > $ogfolder/$file.meta.txt`;
`echo $json >> $ogfolder/$file.meta.txt`;

#print "wget \"$path\" -c -O $file >> /tmp/wget-log\n";
`echo \"wget $path -c -O $file\" >> /tmp/wget-log`;
`wget "$path" -c -O $file`;
if ( $data ) # wenn ein alter file verwendet wurde
{
	`rm $ARGV[0] $ARGV[0].meta.txt`;
}


