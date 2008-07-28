#!/bin/sh

set -e

make crc16
crc16=`pwd`/crc16

t=`mktemp -dt csqcarchive.XXXXXX`
cd "$t"

revs()
{
	{
		svn log svn://svn.icculus.org/nexuiz/trunk/data/qcsrc/common
		echo
		svn log svn://svn.icculus.org/nexuiz/trunk/data/qcsrc/client
	} | {
		while IFS= read -r LINE; do
			if [ "$LINE" = "------------------------------------------------------------------------" ]; then
				read -r REV REST
				case "$REV" in
					r*)
						echo ${REV#r}
						;;
				esac
			fi
		done
	} | sort -n
}

revs | less

for rev in `revs`; do
	svn checkout -r"$rev" svn://svn.icculus.org/nexuiz/trunk/data/qcsrc
	rm -f Makefile csprogs.dat
	wget -OMakefile "http://svn.icculus.org/*checkout*/nexuiz/trunk/data/Makefile?revision=$rev" || continue
	make csprogs.dat || continue
	mv csprogs.dat csprogs.dat.`$crc16 < csprogs.dat`
done
