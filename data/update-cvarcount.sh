#!/bin/sh

countd=`awk '/^seta? g_/ { print $2; }' defaultNexuiz.cfg | sort -u | md5sum | cut -c 1-32`
countw=`awk '/^seta? g_/ { print $2; }' weapons.cfg       | sort -u | md5sum | cut -c 1-32`
counth=`awk '/^seta? g_/ { print $2; }' weaponsHavoc.cfg  | sort -u | md5sum | cut -c 1-32`

if [ "$countw" != "$counth" ]; then
	echo "Mismatch between weapons.cfg and weaponsHavoc.cfg. Aborting."
	exit 1
fi

sed -i "s/^set cvar_check_default .*/set cvar_check_default $countd/" defaultNexuiz.cfg
sed -i "s/^set cvar_check_weapons .*/set cvar_check_weapons $countw/" weapons.cfg
sed -i "s/^set cvar_check_weapons .*/set cvar_check_weapons $countw/" weaponsHavoc.cfg

sed -i "s/^string CVAR_CHECK_DEFAULT = .*/string CVAR_CHECK_DEFAULT = \"$countd\";/" qcsrc/server/constants.qh
sed -i "s/^string CVAR_CHECK_WEAPONS = .*/string CVAR_CHECK_WEAPONS = \"$countw\";/" qcsrc/server/constants.qh

[ -z "$DO_NOT_RUN_MAKE" ] && make

echo "New checksums: $countd, $countw; please recompile!"
