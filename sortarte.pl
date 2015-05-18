#!/usr/bin/perl
# Mar
# Sort arte files in geners
# v0.0.1
use strict;
use warnings;

my $ogfolder="/arte/stream"; # folder to store
my $url;
my $data;
my $folder="sortme";
my $s = 0;
my @liste = `ls $ogfolder/*meta.txt`;
#my @liste = "/arte/stream/20140511-TVGE1468-Karambolage.mp4.meta.txt";

foreach	my $line (@liste)
{
	# reset vars
	$folder="sortme";
	chomp ($line);
	print "$line\n";
	#$url = `cat $line |  grep {  | sed 's/.*VUP://;s/,.*//' | grep http`;
	# get genre:Kurzfilm
	$folder = `cat $line |  grep {  | grep genre | sed 's/.*genre://;s/,.*//'`;
	chomp($folder);
	print"$folder\n\n";
	if (! $folder || $folder =~ m/^{/ )
	{
		print "failure at $line\n take sortme\n";
		$folder="sortme";
	}
	`mkdir -p $folder`;
	my $name = $line ;
	$name =~ s/\.meta\.txt//;
	print "mv $name* $ogfolder/$folder/\n\n";
	`mv $name* $ogfolder/$folder/`;
}
