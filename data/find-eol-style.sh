#!/bin/bash

allstatus=$(
	find . -name .svn -prune -o -type f -print | while IFS= read -r LINE; do
		ext=${LINE##*/}
		ext=${ext##*.}
		if s=`svn propget svn:eol-style "$LINE"`; then
			case "$s" in
				*native*)
					echo "$ext 1"
					;;
				*)
					echo "$ext 0"
					;;
			esac
		fi
	done | sort -u
)

mixed=`echo "$allstatus" | rev | cut -c 3- | rev | uniq -d`
if [ -n "$mixed" ]; then
	echo "The following file extensions need to be manually fixed:"
	echo "$mixed"
	exit 1
fi

echo "$allstatus" > eol-style.txt
