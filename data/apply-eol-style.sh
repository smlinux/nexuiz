#!/bin/sh

while read -r EXT EOLSTYLE; do
	echo "Fixing $EXT..."
	find . -name .svn -prune -o -type f \( -name "*.$EXT" -o -name "$EXT" \) -print0 | \
		case "$EOLSTYLE" in
			1)
				xargs -0 svn propset svn:eol-style native
				;;
			0)
				xargs -0 svn propdel svn:eol-style
				;;
		esac
done <eol-style.txt
