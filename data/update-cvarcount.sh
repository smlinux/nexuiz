#!/bin/sh

balance_cfgs="balanceHavoc.cfg balance25.cfg balanceSamual.cfg"

countd=`awk '/^seta? g_/ { print $2; }' defaultNexuiz.cfg | sort -u | tr -d '\r' | md5sum | cut -c 1-32`
countw=`awk '/^seta? g_/ { print $2; }' balance.cfg       | sort -u | tr -d '\r' | md5sum | cut -c 1-32`
for b in $balance_cfgs; do
	countb=`awk '/^seta? g_/ { print $2; }' "$b"  | sort -u | tr -d '\r' | md5sum | cut -c 1-32`
	if [ "$countw" != "$countb" ]; then
		echo "Mismatch between balance.cfg and $b. Aborting."
		exit 1
	fi
done

sed -i -e "s/^set cvar_check_default .*/set cvar_check_default $countd/" defaultNexuiz.cfg
sed -i -e "s/^set cvar_check_balance .*/set cvar_check_balance $countw/" balance.cfg
for b in $balance_cfgs; do
	sed -i -e "s/^set cvar_check_balance .*/set cvar_check_balance $countw/" "$b"
done

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
