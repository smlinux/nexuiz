#!/bin/sh

d=$1
i=0
perl demotc.pl "$d" 'all-time fastest lap record with (.*)\n' | while IFS=" " read -r timecode result; do
	timecode=${timecode%:}
	result=${result#\"}
	result=${result%\"}

	minutes=${result%%:*}
	result=${result#*:}
	seconds=${result%%.*}
	result=${result#*.}
	tenths=$result

	timecode_start=`echo "$timecode - $minutes*60 - $seconds - $tenths*0.1 - 2" | bc -l`
	timecode_end=`echo "$timecode + 2" | bc -l`
	i=$(($i + 1))
	perl demotc.pl "$d" "playback-$i.dem" "$timecode_start" "$timecode_end"
	perl demotc.pl "$d" "capture-$i.dem" "$timecode_start" "$timecode_end" --capture
done
