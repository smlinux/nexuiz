#!/bin/sh

balance_cfgs="balanceHavoc.cfg balance25.cfg balanceSamual.cfg balanceNexrun.cfg"

countw=`awk '/^seta? g_/ { print $2; }' balance.cfg       | sort -u | tr -d '\r' | md5sum | cut -c 1-32`
for b in $balance_cfgs; do
	countb=`awk '/^seta? g_/ { print $2; }' "$b"  | sort -u | tr -d '\r' | md5sum | cut -c 1-32`
	if [ "$countw" != "$countb" ]; then
		echo "Mismatch between balance.cfg and $b. Aborting."
		exit 1
	fi
done
