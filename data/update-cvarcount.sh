#!/bin/sh

countd=`awk '/^seta? g_/ { print $2; }' defaultNexuiz.cfg | sort -u | tr -d '\r' | md5sum | cut -c 1-32`
countw=`awk '/^seta? g_/ { print $2; }' balance.cfg       | sort -u | tr -d '\r' | md5sum | cut -c 1-32`
counth=`awk '/^seta? g_/ { print $2; }' balanceHavoc.cfg  | sort -u | tr -d '\r' | md5sum | cut -c 1-32`
countl=`awk '/^seta? g_/ { print $2; }' balance25.cfg     | sort -u | tr -d '\r' | md5sum | cut -c 1-32`

if [ "$countw" != "$counth" ]; then
	echo "Mismatch between balance.cfg and balanceHavoc.cfg. Aborting."
	exit 1
fi
if [ "$countw" != "$countl" ]; then
	echo "Mismatch between balance.cfg and balanceHavoc.cfg. Aborting."
	exit 1
fi

sed -i -e "s/^set cvar_check_default .*/set cvar_check_default $countd/" defaultNexuiz.cfg
sed -i -e "s/^set cvar_check_balance .*/set cvar_check_balance $countw/" balance.cfg
sed -i -e "s/^set cvar_check_balance .*/set cvar_check_balance $countw/" balanceHavoc.cfg
sed -i -e "s/^set cvar_check_balance .*/set cvar_check_balance $countw/" balance25.cfg

sed -e "
	s/^string CVAR_CHECK_DEFAULT = .*/string CVAR_CHECK_DEFAULT = \"$countd\";/;
	s/^string CVAR_CHECK_BALANCE = .*/string CVAR_CHECK_BALANCE = \"$countw\";/;
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
