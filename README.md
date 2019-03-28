arte
====

Download the Content from Arte

v1.0


Dependencies 
====

- SPACE on DISK more than 2TB 
- Linux
- Strong Internet Connection or Time

I chose debian you have to install : wget perl screen 


Usage 
====
1. Create or replace follow folder to your needs: 
	$ogfolder="/arte/stream";
	sed 's/\/arte\/stream/\/our\/disk/' *.pl
	
- 7 Plus: Runs once a day with cron. Download the online content from the TV Program
	23 5 * * * /usr/bin/perl /arte/arte-7plus.pl
- Download everythink at Mediatek 
	bash arte-all.bash
- Download everythink on one Page
	perl arte-all.pl "https://www.arte.tv/de/videos/kultur-und-pop/kunst/?page=23"
- Download only Specific Video
	perl parsebehind.pl "https://www.arte.tv/de/videos/080979-000-A/john-ford-der-mann-der-amerika-erfand/"
- Live records: arte.pl must be used live in
        do not use it , its outdatet und not stable
	
