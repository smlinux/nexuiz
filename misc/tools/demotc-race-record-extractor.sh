#!/bin/sh

d=$1
i=0
demotc.pl grep "$d" '//RACE RECORD SET (.*)\n' | while IFS=" " read -r timecode result; do
	timecode=${timecode%:}
	result=${result#\"}
	result=${result%\"}

	echo "Possible record found at $timecode: $result, extracting..."

	minutes=${result%%:*}
	result=${result#*:}
	seconds=${result%%.*}
	result=${result#*.}
	tenths=$result

	timecode_start=`echo "$timecode - $minutes*60 - $seconds - $tenths*0.1 - 2" | bc -l`
	timecode_end=`echo "$timecode + 2" | bc -l`
	i=$(($i + 1))
	perl demotc.pl cut "$d" "playback-$i.dem" "$timecode_start" "$timecode_end"
	perl demotc.pl cut "$d" "capture-$i.dem" "$timecode_start" "$timecode_end" --capture
done
