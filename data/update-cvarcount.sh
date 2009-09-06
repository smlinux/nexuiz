#!/bin/sh

countd=`awk '/^seta? g_/ { print $2; }' defaultNexuiz.cfg | sort -u | md5sum | cut -c 1-32`
countw=`awk '/^seta? g_/ { print $2; }' weapons.cfg       | sort -u | md5sum | cut -c 1-32`
counth=`awk '/^seta? g_/ { print $2; }' weaponsHavoc.cfg  | sort -u | md5sum | cut -c 1-32`
countl=`awk '/^seta? g_/ { print $2; }' weapons25.cfg     | sort -u | md5sum | cut -c 1-32`

if [ "$countw" != "$counth" ]; then
	echo "Mismatch between weapons.cfg and weaponsHavoc.cfg. Aborting."
	exit 1
fi
if [ "$countw" != "$countl" ]; then
	echo "Mismatch between weapons.cfg and weaponsHavoc.cfg. Aborting."
	exit 1
fi

sed -i -e "s/^set cvar_check_default .*/set cvar_check_default $countd/" defaultNexuiz.cfg
sed -i -e "s/^set cvar_check_weapons .*/set cvar_check_weapons $countw/" weapons.cfg
sed -i -e "s/^set cvar_check_weapons .*/set cvar_check_weapons $countw/" weaponsHavoc.cfg
sed -i -e "s/^set cvar_check_weapons .*/set cvar_check_weapons $countw/" weapons25.cfg

sed -e "
	s/^string CVAR_CHECK_DEFAULT = .*/string CVAR_CHECK_DEFAULT = \"$countd\";/;
	s/^string CVAR_CHECK_WEAPONS = .*/string CVAR_CHECK_WEAPONS = \"$countw\";/;
" qcsrc/server/constants.qh > qcsrc/server/constants.qh.new

if ! diff qcsrc/server/constants.qh qcsrc/server/constants.qh.new; then
	mv qcsrc/server/constants.qh.new qcsrc/server/constants.qh
	if [ -z "$DO_NOT_RUN_MAKE" ]; then
		make
	else
		echo "New checksums: $countd, $countw; please recompile!"
	fi
else
	rm -f qcsrc/server/constants.qh.new
fi
