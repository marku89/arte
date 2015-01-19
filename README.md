arte
====

Jeden Film von Arte Aufzeichnen ? auch wenn er nur live läuft, nun möglich !

Das Perl script schreibt kontinurlich die einzelen Filme aus dem live Stream weg in mp4 files sowie Meta Daten und die zwischen seqenzen mit timestamp und Arte ID.

arte.pl v0.8.3


Anforderungen
====

debian ! 

aptitude install perl wget


Benutzung 
====
1. Einstellen der Umgebungsvariabeln auf seine DISK layout 
	my $ogfolder="/arte/stream";


Live:
Zum aufzeichnen arte.pl im scren laufen aufm Server 


7 Plus:
In cron eintragen damit es jeden Morgen läuft.
	0 5 * * * /usr/bin/perl /home/markus/arte/arte-7plus.pl

Einzelne Sendungen:
Wichtig ist das man die Arte URL ohne ? und vollständig angibt in Anführungszeichen !
	perl parsebehind.pl "http://www.arte.tv/guide/de/048727-003/x-enius"
	
