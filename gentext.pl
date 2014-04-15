#!/usr/bin/perl

my $i;

if (@ARGV[0] )
{
	$i = @ARGV[0];
}
else 
{
	print "Failed to ge \$1";
	exit 1;
}

$i =~ s/\.mp4//;
$i =~ s/\d+-\d+//;
$i =~ s/_/ /g;
$i =~ s/^-//;

#print "--$i--\n";
my $URL = `cat $ARGV[0].meta.txt | grep "{lang"`;
$URL =~ s/.*VUP://;
$URL =~ s/,VSR.*//;
$URL =~ s/_/\//g;
chomp($URL);

#print "--$URL--\n";

$con = `wget -qOurl.txt $URL`;

$text1 =`awk '/<section class=\"desktop hidden-phone visible-tablet-portrait desc-wrapper\" data-controller=\"details\" data-action=\"description\" data-startup>/{f=1;next}/<\\\/section>/{f=0}f' url.txt`;
	$text1 =~ s/<\/p>//g;
	$text1 =~ s/<p>//g;
	#print "==$text1==\n";

$text2 =`awk '/<div itemprop="description" id="content-description" class="collapse">/{f=1;next}/<\\\/div>/{f=0}f' url.txt`;
        $text2 =~ s/<\/p>//g;
        $text2 =~ s/<p>//g;
        #print "==$text2==\n";

$text3 = `grep "<span class=\\\"meta-label\\\">" url.txt`;
$date = `grep "Jahr: " url.txt | sed 's/.*Jahr: //;s/<.*//' `;
chomp($date);
	$text3 =~ s/.*">/\* /g;
	$text3 =~ s/<.*//g;
	$text3 =~ s/.*Als Live verfügbar.*/ /;
	$text3 =~ s/.*Arte\+7.*/ /;
        chomp($text3);
	#print "==$text3==und date: $date\n";
$size = `du -sh @ARGV[0] | sed 's/@ARGV[0]//'`;
chomp($size);
$dau = `grep -A 2 time-row url.txt | grep "(" | head -n 1 | sed 's/.*(//;s/).*//'`;
chomp($dau);
#print "==$dau==";
# printout data
print "$i $date AAC 720p HDTV x264 - iND\n";
print "[CENTER]\n[B][SIZE=\"4\"] $i [/SIZE][/B]\n";
print "[IMG][/IMG]\n";
print "[B]# Beschreibung[/B]\n";
print "$text1";
print "$text2";
print "[url=$URL]ARTE[/url]\n[CODE]\n* Arte Stream \n$text3 \n* Größe: $size \n* Dauer: $dau \n* Hoster: Uploaded.to, Share-Online.biz, Filemonkey.in\n[/CODE]\n\n[B]# Download [/B]";
print "[spoiler]\n[url=htt]Uploaded[/url]\n[url=http]Share-Online[/url]\n[url=http]Filemonkey.in[/url]\n[/spoiler]\n[/CENTER]";
