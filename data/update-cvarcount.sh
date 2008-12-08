#!/bin/sh

countd=`awk '/^seta? g_/ { print $2; }' defaultNexuiz.cfg | sort -u | md5sum | cut -c 1-32`
countw=`awk '/^seta? g_/ { print $2; }' weapons.cfg       | sort -u | md5sum | cut -c 1-32`
countp=`awk '/^seta? g_/ { print $2; }' weaponsPro.cfg    | sort -u | md5sum | cut -c 1-32`

if [ "$countw" != "$countp" ]; then
	echo "Mismatch between weapons.cfg and weaponsPro.cfg. Aborting."
	exit 1
fi

sed -i "s/^set cvar_check_default .*/set cvar_check_default $countd/" defaultNexuiz.cfg
sed -i "s/^set cvar_check_weapons .*/set cvar_check_weapons $countw/" weapons.cfg
sed -i "s/^set cvar_check_weapons .*/set cvar_check_weapons $countw/" weaponsPro.cfg

sed -i "s/^string CVAR_CHECK_DEFAULT = .*/string CVAR_CHECK_DEFAULT = \"$countd\";/" qcsrc/server/constants.qh
sed -i "s/^string CVAR_CHECK_WEAPONS = .*/string CVAR_CHECK_WEAPONS = \"$countw\";/" qcsrc/server/constants.qh

make

echo "New checksums: $countd, $countw"
