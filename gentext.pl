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
my $URL = `cat $ARGV[0].meta.txt | grep {`;
$IMG = $URL;

$URL =~ tr/\n//d;
$URL =~ s/.*VUP://;

$URL =~ s/,.*//g;
#$URL =~ s/_/\//g;
chomp($URL);
#print "==$URL==\n";
#exit;

$IMG =~ s/.*Image://m;
$IMG =~ tr/\n//d;
$IMG =~ s/,.*//g;
#$IMG =~ s/_/\//g;
#$IMG =~ s/\/01/_01/g;
#$IMG =~ s/0\//0_/g;
chomp($IMG);
#exit;

print "--$IMG--$URL--\n";
## upload image to http://imgur.com
$imga = `wget --post-data="current_upload=1&total_uploads=1&gallery_title=Gallery+submission+title+(required)&gallery_submit=false&gallery_type=&terms=0&forceAnonymous=false&create_album=0&album_title=Optional+Album+Title&layout=b&catify=0&url=$IMG&edit_url=0" http://imgur.com/upload -qO -`;

#print "--$imga--";
$imga =~ s/.*"hash":"/http:\/\/imgur.com\//;
$imga =~ s/".*/\.jpg/;
$IMG = $imga ;

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
foreach my $in (@ARGV)
{
	print "\n$in\n";

	if ( $in eq "boerse" )
	{
	print "$i $date AAC 720p HDTV x264 - Mar\n";
	print "[CENTER]\n[B][SIZE=\"4\"] $i [/SIZE][/B]\n";
	print "[IMG]$IMG [/IMG]\n";
	print "[B]# Beschreibung[/B]\n";
	print "$text1";
	print "$text2";
	print "[url=$URL]ARTE[/url]\n[CODE]\n* Arte Stream \n$text3 \n* Größe: $size \n* Dauer: $dau \n* Hoster: Uploaded.to, Share-Online.biz,\n[/CODE]\n\n[B]# Download [/B]";
	print "[spoiler]\n[url=htt]Uploaded[/url]\n[url=http]Share-Online[/url]\n[url=http]Filemonkey.in[/url]\n[/spoiler]\n[/CENTER]\n";
	exit;
	}
	if ( $in eq "warez")
	{
	print "$i $date AAC 720p HDTV x264 - Mar\n";
	print "[align=center]\n[B][size=large] $i [/size][/B]\n\n\n";
	print "[IMG]$IMG [/IMG]\n\n\n";
	print "[B]# Beschreibung[/B]\n\n";
	print "$text1";
	print "$text2\n\n\n";
	print "[url=$URL]ARTE[/url]\n[CODE]\n* Arte Stream \n$text3 \n* Größe: $size \n* Dauer: $dau \n* Hoster: Uploaded.to, Share-Online.biz, \n[/CODE]\n\n[B]# Download [/B]";
	print "[hide]\n[url=htt]Uploaded[/url]\n[url=http]Share-Online[/url]\n[url=http]Filemonkey.in[/url]\n[/hide]\n[/align]\n";
	}
}
