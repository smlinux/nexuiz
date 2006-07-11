#!/bin/sh

: ignore <<'EOF'

Nexuiz map recompilation script

NOTE: to use this script, you need a shell script called q3map2 in your $PATH.
      Mine looks like this:

        #!/bin/sh
        exec ~/bin/q3map2.x86 -threads 2 "$@"

      Note that you can NOT call q3map2.x86 directly from $PATH, as it segfaults
      then!

Usage:
sh compile.sh tznex01

EOF

settings_bloodprison=":-fast:-fast"
settings_default="-samplesize 8::-deluxe -patchshadows -samples 3"
settings_farewell="-samplesize 8 -patchmeta::-deluxe -patchshadows -samples 3"
scale_bloodprison=1.2

set -ex

map2()
{
	dir=`pwd`
	# note: you are in data/maps. Removintg these two components...
	dir=${dir%/*/*}

	q3map2 -fs_basepath "$dir" -fs_game data -v "$@"
}

for MAP in "$@"; do
	[ -f "$MAP.map" ]

	# get settings for this map
	eval s=\$settings_$MAP
	[ -n "$s" ] || s=$settings_default
	eval scale=\$scale_$MAP

	# recompile it
	if [ -n "$scale" ]; then
		if ! grep "_keeplights" "$MAP.map" >/dev/null; then
			echo "$MAP does not have _keeplights in worldspawn!"
			exit 1
		fi
	fi
	map2 -bsp -meta `echo "$s" | cut -d : -f 1` "$MAP.map" | tee    "$MAP.log"
	if [ -n "$scale" ]; then
		map2 -scale "$scale" "$MAP.bsp"
		mv "${MAP}_s.bsp" "$MAP.bsp"
	fi
	map2 -vis       `echo "$s" | cut -d : -f 2` "$MAP.map" | tee -a "$MAP.log"
	map2 -light     `echo "$s" | cut -d : -f 3` "$MAP.map" | tee -a "$MAP.log"
	rm   -f                                     "$MAP.srf"
done
