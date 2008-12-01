#!/bin/sh

set -e

: ${qual:=95}

for X in "$@"; do
	case "$X" in
		*.jpg)
			jpegoptim --strip-all "$X"
			;;
		*.png|*.tga)
			if convert "$X" -depth 16 RGBA:- | perl -e 'local $/ = \8; while(<>) { substr($_, 6, 2) eq "\xFF\xFF" or exit 1; ++$pix; } END { exit not $pix; }'; then
				echo "$X has no alpha, converting"
				convert "$X" -quality $qual "${X%.*}.jpg"
				jpegoptim --strip-all "${X%.*}.jpg"
				rm -f "$X"
			else
				echo "$X has alpha, not converting"
			fi
			;;
	esac
done
