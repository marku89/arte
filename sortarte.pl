#!/usr/bin/perl
# Mar
# Sort arte files in geners
# v0.0.1
use strict;
use warnings;

my $ogfolder="/mnt/stream"; # folder to store
my $url;
my $data;
my $folder="sortme";
my $s = 0;
my @liste = `ls $ogfolder/*meta.txt`;
#my @liste = "/arte/stream/20140511-TVGE1468-Karambolage.mp4.meta.txt";

foreach	my $line (@liste)
{
	print "\n\n#####\n";
	# reset vars
	$folder="sortme";
	chomp ($line);
	print "$line\n";
	# get genre:Kurzfilm
	$folder = `cat $line | grep genre | sed 's/.*genre"://;s/,.*//;s/.*_//;s/"//'`;
	chomp($folder);
	print"==$folder==\n";
	#exit;
	if (! $folder || $folder =~ m/^{/ )
	{
		# TEST online genre status
		$url = `cat $line |  grep {  | sed 's/.*VUP://;s/,.*//' | grep http`;
		print "==$url==";
		my $keyword="badge-trailer";
		my $getl = `wget -qO- "$url" | grep content-metadata -A3 | grep "collapse in" -A3 | grep -v "<"`;
		print "==$getl==";
		chomp($getl);
		$folder=$getl;
		#print "i--$getl--a";
		#exit;
		if (! $folder )
		{
			print "failure at $line\n take sortme\n";
			$folder="sortme";
		}
	}
	`mkdir -p $folder`;
	my $name = $line ;
	$name =~ s/\.meta\.txt//;
	print "mv $name* $ogfolder/$folder/\n";
	`mv $name* $ogfolder/$folder/`;
}
