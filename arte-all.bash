#!/bin/bash
# mar@kola.li
# 28.03.2019
# - beware of ajust value on pages count
# - This download will nee a lot of DISK Space 

# Arte Kino
for i in $(seq 1 5  ); do perl arte-all.pl "https://www.arte.tv/de/videos/kino/stummfilme/?page=$i"; done
for i in $(seq 1 5  ); do perl arte-all.pl "https://www.arte.tv/de/videos/kino/filme/?page=$i"; done
for i in $(seq 1 15 ); do perl arte-all.pl "https://www.arte.tv/de/videos/kino/kurzfilme/?page=$i"; done
for i in $(seq 1 10 ); do perl arte-all.pl "https://www.arte.tv/de/videos/kino/filmgroessen/?page=$i"; done
for i in $(seq 1 50 ); do perl arte-all.pl "https://www.arte.tv/de/videos/kino/rund-um-den-film/?page=$i"; done

# Arte Fernsehfilme
for i in $(seq 1 10 ); do perl arte-all.pl "https://www.arte.tv/de/videos/fernsehfilme-und-serien/serien/?page=$i"; done
for i in $(seq 1 5  ); do perl arte-all.pl "https://www.arte.tv/de/videos/fernsehfilme-und-serien/fernsehfilme/?page=$i"; done
for i in $(seq 1 50 ); do perl arte-all.pl "https://www.arte.tv/de/videos/fernsehfilme-und-serien/kurz-und-witzig/?page=$i"; done

# Arte Kultur
for i in $(seq 1 100); do perl arte-all.pl "https://www.arte.tv/de/videos/kultur-und-pop/kunst/?page=$i"; done
for i in $(seq 1 110); do perl arte-all.pl "https://www.arte.tv/de/videos/kultur-und-pop/popkultur/?page=$i"; done
for i in $(seq 1 15 ); do perl arte-all.pl "https://www.arte.tv/de/videos/kultur-und-pop/ideenwelten/?page=$i"; done

# Arte Concert
for i in $(seq 1 60 ); do perl arte-all.pl "https://www.arte.tv/de/videos/arte-concert/pop/?page=$i"; done
for i in $(seq 1 20 ); do perl arte-all.pl "https://www.arte.tv/de/videos/arte-concert/klassik/?page=$i"; done
for i in $(seq 1 5  ); do perl arte-all.pl "https://www.arte.tv/de/videos/arte-concert/oper/?page=$i"; done
for i in $(seq 1 10 ); do perl arte-all.pl "https://www.arte.tv/de/videos/arte-concert/jazz/?page=$i"; done
for i in $(seq 1 5  ); do perl arte-all.pl "https://www.arte.tv/de/videos/arte-concert/weltmusik/?page=$i"; done
for i in $(seq 1 10 ); do perl arte-all.pl "https://www.arte.tv/de/videos/arte-concert/buehnen-performance/?page=$i"; done

# Arte Wissenschaft
for i in $(seq 1 10 ); do perl arte-all.pl "https://www.arte.tv/de/videos/wissenschaft/gesundheit-und-medizin/?page=$i"; done
for i in $(seq 1 10 ); do perl arte-all.pl "https://www.arte.tv/de/videos/wissenschaft/umwelt-und-natur/?page=$i"; done
for i in $(seq 1 10 ); do perl arte-all.pl "https://www.arte.tv/de/videos/wissenschaft/technik-und-innovation/?page=$i"; done
for i in $(seq 1 20 ); do perl arte-all.pl "https://www.arte.tv/de/videos/wissenschaft/wissen-kompakt/?page=$i"; done

# Arte Welt
for i in $(seq 1 5  ); do perl arte-all.pl "https://www.arte.tv/de/videos/entdeckung-der-welt/natur-und-tiere/?page=$i"; done
for i in $(seq 1 15 ); do perl arte-all.pl "https://www.arte.tv/de/videos/entdeckung-der-welt/reisen/?page=$i"; done
for i in $(seq 1 10 ); do perl arte-all.pl "https://www.arte.tv/de/videos/entdeckung-der-welt/kulinarik/?page=$i"; done
for i in $(seq 1 5  ); do perl arte-all.pl "https://www.arte.tv/de/videos/entdeckung-der-welt/leben-anderswo/?page=$i"; done

# Arte Geschichte
for i in $(seq 1 5  ); do perl arte-all.pl "https://www.arte.tv/de/videos/geschichte/das-20-jahrhundert/?page=$i"; done
for i in $(seq 1 5  ); do perl arte-all.pl "https://www.arte.tv/de/videos/geschichte/die-zeit-vor-dem-20-jahrhundert/?page=$i"; done
for i in $(seq 1 5  ); do perl arte-all.pl "https://www.arte.tv/de/videos/geschichte/biographien/?page=$i"; done

# Arte Aktuelles
for i in $(seq 1 110); do perl arte-all.pl "https://www.arte.tv/de/videos/aktuelles-und-gesellschaft/aktuelles/?page=$i"; done
for i in $(seq 1 50 ); do perl arte-all.pl "https://www.arte.tv/de/videos/aktuelles-und-gesellschaft/reportagen-und-recherchen/?page=$i"; done
for i in $(seq 1 75 ); do perl arte-all.pl "https://www.arte.tv/de/videos/aktuelles-und-gesellschaft/kultur-news/?page=$i"; done
for i in $(seq 1 60 ); do perl arte-all.pl "https://www.arte.tv/de/videos/aktuelles-und-gesellschaft/hintergrund/?page=$i"; done
for i in $(seq 1 30 ); do perl arte-all.pl "https://www.arte.tv/de/videos/aktuelles-und-gesellschaft/junior/?page=$i"; done
for i in $(seq 1 40 ); do perl arte-all.pl "https://www.arte.tv/de/videos/aktuelles-und-gesellschaft/perspektivwechsel/?page=$i"; done

# Arte Sendungen 
for i in $(seq 1 5  ); do perl arte-all.pl "https://www.arte.tv/de/videos/sendungen/?page=$i"; done
