#!/bin/bash

set -e

# Options:
#   pw=foo          extract password
#   version=2.5     make a FINAL build
#   tag=FOO         insert FOO before the date in build names

base=`pwd`

# customizable specific stuff
netradiant_release=1.5.0-svn212
basepk3=$base/data20080229.pk3 # 2.4
hotbasepk3= # hotfix
nexdir=$base/nexuiz
havocdir=$base/nexuiz/havoc
dpdir=$base/darkplaces
tmpdir=/tmp/NEX
zipdir=$base/builds
buildfiles=$base/nexuiz/misc/buildfiles
mingwdlls=$buildfiles/w32
osxapps=$buildfiles/osx
copystrip=$buildfiles/copystrip
zipdiff=$base/nexuiz/misc/tools/zipdiff
fteqccdir="$base/fteqcc"
fteqccflags=""
menuqc=menu
newest=NEWEST
aft="perl -I/chroot/debian-etch/usr/share/aft /chroot/debian-etch/usr/bin/aft"
# end system specific stuff

case "$pw" in
	'')
		zipflags=
		;;
	*)
		zipflags="-P $pw"
		;;
esac

: ${date:=`date +%Y%m%d`}
: ${versiontag:=}
echo "date stamp: $date"

case "$version" in
	'')
		version=2-svntest-$date
		versiontag=test
		defaultcfg=
		ext=
		;;
	*)
		version=$version
		versiontag=$versiontag
		defaultcfg=
		ext=_$version
		;;
esac

mk7z()
{
	7za a -tzip -mx=9 "$@"
	chmod 644 "$1"
}

#if [ -n "$EXPERIMENTAL" ]; then
#	basepk3=$base/data20071231.pk3 # newer build to make smaller patches
#	nexdir=$base/nexuiz
#fi

# TODO normalize the builds
platforms='x86 amd64 osx'
buildon()
{
	host=$1
	prefix=$2
	fteqccname=$3
	path=$4
	makeflags=$5
	strip=$6

	fteqcc_cflags=
	case "$fteqccname" in
		*.exe)
			fteqcc_cflags=win
			;;
	esac

	rm -f "$fteqccdir"/*.o
	rm -f "$fteqccdir"/*.bin
	rsync --exclude "*.o" --exclude "*.d" --exclude "nexuiz-*" --delete-excluded --delete -zvaSHP . "$copystrip" "$fteqccdir" "$host:$path"
	ssh "$host" ". ~/.profile && cd $path && COPYSTRIP_STRIP=$strip PATH=$path/copystrip:\$PATH make $makeflags clean nexuiz && cd ${fteqccdir##*/} && make $makeflags $fteqcc_cflags"
	rsync --exclude "*.o" --exclude "*.d" --delete-excluded --delete -zvaSHP "$host:$path/." .
	for P in -dedicated -sdl -glx -wgl -agl -dedicated.exe -sdl.exe .exe; do
		[ -f nexuiz$P ] && mv nexuiz$P "$tmpdir/$prefix$P"
		[ -f nexuiz$P-withdebug ] && mv nexuiz$P-withdebug "$tmpdir/debuginfo/$prefix$P"
	done
	case "$fteqccname" in
		*.exe)
			mv "${fteqccdir##*/}"/fteqcc.exe "$tmpdir/fteqcc/$fteqccname"
			;;
		*)
			mv "${fteqccdir##*/}"/fteqcc.bin "$tmpdir/fteqcc/$fteqccname"
			;;
	esac
	make clean
}

build()
{
	buildon nexmacbuild                           nexuiz-osx          fteqcc-osx          /tmp/Darkplaces.build 'CC="gcc -g -arch i386 -arch ppc -isysroot /Developer/SDKs/MacOSX10.4u.sdk -mmacosx-version-min=10.4"' strip
	buildon eos.thruhere.net                      nexuiz-linux-686    fteqcc-linux-686    /tmp/Darkplaces.build 'CC="gcc -g" DP_MODPLUG_STATIC_LIBDIR=/home/divverent/modplug-i386/lib' strip
	buildon alientrap.org                         nexuiz-linux-x86_64 fteqcc-linux-x86_64 /tmp/Darkplaces.build 'CC="gcc -g -Wl,--hash-style=sysv" DP_MODPLUG_STATIC_LIBDIR=/home/divverent/modplug-x86_64/lib' strip
	buildon alientrap.org                         nexuiz              fteqcc.exe          /tmp/Darkplaces.build 'DP_MAKE_TARGET=mingw CC="/chroot/debian-etch/usr/bin/i586-mingw32msvc-gcc -g -DSUPPORTDIRECTX -I/home/divverent/dxheaders" WINDRES=/chroot/debian-etch/usr/bin/i586-mingw32msvc-windres SDL_CONFIG=/home/divverent/sdl-win32/SDL-1.2.13/bin/sdl-config' /chroot/debian-etch/usr/bin/i586-mingw32msvc-strip
		mv "$tmpdir/nexuiz-osx-agl"     "$tmpdir/Nexuiz.app/Contents/MacOS/nexuiz-osx-agl-bin"
		mv "$tmpdir/nexuiz-osx-sdl"     "$tmpdir/Nexuiz-SDL.app/Contents/MacOS/nexuiz-osx-sdl-bin"
}

# avoid dupes
i=
while [ -f "$zipdir/nexuiz$date$i$ext.zip" ]; do
	if [ -z "$i" ]; then
		i=a
	else
		i=`echo "$i" | tr a-y b-z`
	fi
done
ext=$i$ext

echo "Using build name nexuiz$date$ext"
sleep 3

# check for remains
conflicts=`find "$dpdir" "$nexdir" -name '*.orig' -o -name '*.rej' -o -name '*.mine' -o -name '.#*' -o -name '.*~'`
if [ -n "$conflicts" ]; then
	echo "CONFLICTS OR UNNEEDED FILES HAVE BEEN FOUND!"
	echo "NOT PROCEEDING"
	echo
	echo "$conflicts"
	exit 1
fi

set -x

# prepare temp dir
rm -rf "$tmpdir"
mkdir -p "$tmpdir"

# clean up and patch DP
cd "$dpdir"
quilt pop -a || true
svn revert -R .
if [ -s patches/series ]; then
	quilt push -a # apply all patches
fi

# prepare directory structure
cp -r "$osxapps"/*.app "$tmpdir"
mkdir "$tmpdir/debuginfo"
mkdir "$tmpdir/fteqcc"

# prepare fteqcc build
svn export "$fteqccdir" "$tmpdir/fteqcc/source"
svn info "$fteqccdir" > "$tmpdir/fteqcc/source/fteqcc-base-revision.txt"
fteqccrev=$((`grep "Last Changed Rev:" "$tmpdir/fteqcc/source/fteqcc-base-revision.txt" | cut -d : -f 2`))
echo "fteqcc rev $fteqccrev"

# build all executables
rm -f *.exe nexuiz-* *-withdebug* *.o
make clean
build
rm -f *.exe nexuiz-* *-withdebug '.#'* *.o
rm -rf fteqcc copystrip
make clean

# move shell scripts and license
cd "$tmpdir"
cp "$nexdir/"nexuiz-*.sh "$tmpdir/"
cp "$nexdir/gpl.txt" "$tmpdir/"

# prepare data
cd "$nexdir/data"
svn export . "$tmpdir/data"
svn info . > "$tmpdir/data/nexuiz-data-base-revision.txt"
svn log > "$tmpdir/data/ChangeLog"

# prepare havoc
cd "$havocdir"
svn export . "$tmpdir/havoc"

# prepare Docs
cd "$nexdir/Docs"
svn export . "$tmpdir/Docs"

# prepare server
cd "$nexdir/server"
svn export . "$tmpdir/server"

# make gamesource
cd "$tmpdir/data"
mkdir -p "$tmpdir/sources"
mk7z ../sources/gamesource$date.zip qcsrc nexuiz-data-base-revision.txt ChangeLog

# make enginesource
cd "$dpdir"
svn export . "$tmpdir/darkplaces"
svn info > "$tmpdir/darkplaces/nexuiz-base-revision.txt"
svn diff > "$tmpdir/darkplaces/nexuiz-engine-changes.diff"
svn log > "$tmpdir/darkplaces/ChangeLog"
cd "$tmpdir"
mk7z "$tmpdir/sources/enginesource$date.zip" "darkplaces"
rm -rf darkplaces

# make fteqcc archive
cd "$tmpdir"
zip -9r "$tmpdir/sources/fteqcc-binaries-and-source-rev$fteqccrev.zip" "fteqcc"
rm -rf fteqcc

# clean fteqcc dir
cd "$fteqccdir"
rm -f *.o *.bin
make

# make local compiler
cd "$tmpdir/data"
make FTEQCC="$fteqccdir/fteqcc.bin"

# prepare root
rm -rf "$tmpdir/data/qcsrc"
cd "$tmpdir/Docs"
cp "$dpdir/darkplaces.txt" .
cd "$tmpdir/data"
mv common-spog.pk3 ..
perl -pi -e '/^set g_nexuizversion "?([0-9.]*)[^"]*"?/ and $_ = "set g_nexuizversion '$version'\n"' defaultNexuiz.cfg
if [ -z "$versiontag" ]; then
	perl -pi -e 'm|^//!<showbrand| .. m|^//!>showbrand| and $_ = "";' defaultNexuiz.cfg
	rm -f gfx/brand.tga
fi
echo >> defaultNexuiz.cfg
echo "$defaultcfg" >> defaultNexuiz.cfg
mk7z ../data.pk3 .
cd "$tmpdir/havoc"
mk7z ../havoc.pk3 .

# make data pk3
cd "$tmpdir"
rm -rf data
mkdir data
mv data.pk3 data/data$tag$date.pk3
mv common-spog.pk3 data/
rm -rf havoc
mkdir havoc
mv havoc.pk3 havoc/data$tag${date}havoc.pk3

cp -r "$mingwdlls"/* .
# fix up permissions
chmod 644 *.dll *.exe

mkdir unsupported
cd unsupported
wget http://svn.icculus.org/netradiant/files/netradiant-${netradiant_release}-win32.zip
unzip netradiant-${netradiant_release}-win32.zip
mv NetRadiant netradiant-${netradiant_release}-win32
rm -f netradiant-${netradiant_release}-win32.zip
wget http://svn.icculus.org/netradiant/files/netradiant-${netradiant_release}-osxintel.zip
unzip netradiant-${netradiant_release}-osxintel.zip
mv NetRadiant.app NetRadiant-${netradiant_release}-osxintel.app
rm -f netradiant-${netradiant_release}-osxintel.zip
cat >> unsupported.txt
This directory contains NetRadiant, a stabilized Q3 map editor,
configured for Nexuiz.

It is not officially supported by Alientrap.

Website: http://www.icculus.org/netradiant/
EOF
cd ..

# make main structure
mkdir Nexuiz
mv * Nexuiz/ || true

find . -name .svn -exec rm -rf {} \; -prune

rm -f "$zipdir/nexuiz$date$ext.zip"
zip $zipflags -9yr "$zipdir/nexuiz$date$ext.zip"           Nexuiz/gpl.txt Nexuiz/nexuiz* Nexuiz/Nexuiz* Nexuiz/*.dll Nexuiz/sources Nexuiz/Docs Nexuiz/server Nexuiz/data/data$tag$date.pk3 Nexuiz/data/common-spog.pk3 Nexuiz/havoc/* Nexuiz/unsupported/*
ln -snf nexuiz$date$ext.zip "$zipdir/nexuiz-$newest.zip"

rm -f "$zipdir/nexuizengineonly$date$ext.zip"
zip $zipflags -9yr "$zipdir/nexuizengineonly$date$ext.zip" Nexuiz/gpl.txt Nexuiz/nexuiz* Nexuiz/Nexuiz* Nexuiz/*.dll
ln -snf nexuizengineonly$date$ext.zip "$zipdir/nexuizengineonly-$newest.zip"

rm -f "$zipdir/nexuizsource$date$ext.zip"
zip $zipflags -9yr "$zipdir/nexuizsource$date$ext.zip"     Nexuiz/gpl.txt                                            Nexuiz/sources
ln -snf nexuizsource$date$ext.zip "$zipdir/nexuizsource-$newest.zip"

# TODO remove these excludes after the version after 2.4.2
$zipdiff -o "Nexuiz/data/datapatch$tag$date.pk3" -f "$basepk3" -t Nexuiz/data/data$tag$date.pk3 \
	-x 'sound/cdtracks/track*.ogg' \
	-x 'sound/cdtracks/brainsukker.ogg' \
	-x 'sound/cdtracks/breakdown-easy.ogg' \
	-x 'sound/cdtracks/calling-bogus.ogg' \
	-x 'sound/cdtracks/chaos-fog.ogg' \
	-x 'sound/cdtracks/digital-pursuit.ogg' \
	-x 'sound/cdtracks/infight.ogg' \
	-x 'sound/cdtracks/neuronal-diving.ogg' \
	-x 'sound/cdtracks/subcities.ogg' \
	-x 'sound/cdtracks/thru-the-mirror.ogg'
mkdir -p sound/cdtracks
ln -snf track001.ogg sound/cdtracks/digital-pursuit.ogg
ln -snf track002.ogg sound/cdtracks/breakdown-easy.ogg
ln -snf track003.ogg sound/cdtracks/brainsukker.ogg
ln -snf track004.ogg sound/cdtracks/chaos-fog.ogg
ln -snf track005.ogg sound/cdtracks/infight.ogg
ln -snf track006.ogg sound/cdtracks/neuronal-diving.ogg
ln -snf track007.ogg sound/cdtracks/subcities.ogg
ln -snf track008.ogg sound/cdtracks/thru-the-mirror.ogg
ln -snf track009.ogg sound/cdtracks/calling-bogus.ogg
zip -9yr "Nexuiz/data/datapatch$tag$date.pk3" sound/cdtracks/*
rm -rf sound
[ -n "$hotbasepk3" ] && $zipdiff -o "Nexuiz/data/datapatch$tag$date""hotfix.pk3" -f "$hotbasepk3" -t Nexuiz/data/data$tag$date.pk3
mkdir -p gfx
if unzip "Nexuiz/data/data$tag$date.pk3" gfx/brand.tga; then
	zip -9r "Nexuiz/data/datapatch$tag$date.pk3" gfx/brand.tga
	[ -n "$hotbasepk3" ] && zip -9r "Nexuiz/data/datapatch$tag$date""hotfix.pk3" gfx/brand.tga
	rm -rf gfx
fi

rm -f "$zipdir/nexuizpatch$date$ext.zip"
zip $zipflags -9yr "$zipdir/nexuizpatch$date$ext.zip"      Nexuiz/gpl.txt Nexuiz/nexuiz* Nexuiz/Nexuiz* Nexuiz/*.dll Nexuiz/sources Nexuiz/Docs Nexuiz/server Nexuiz/data/datapatch$tag$date.pk3 Nexuiz/havoc/*
ln -snf nexuizpatch$date$ext.zip "$zipdir/nexuizpatch-$newest.zip"

[ -n "$hotbasepk3" ] && rm -f "$zipdir/nexuizhotfix$date$ext.zip"
[ -n "$hotbasepk3" ] && zip $zipflags -9yr "$zipdir/nexuizhotfix$date$ext.zip"      Nexuiz/gpl.txt Nexuiz/nexuiz* Nexuiz/Nexuiz* Nexuiz/*.dll Nexuiz/sources Nexuiz/Docs Nexuiz/server Nexuiz/data/datapatch$tag$date""hotfix.pk3 Nexuiz/havoc/*
[ -n "$hotbasepk3" ] && ln -snf nexuizhotfix$date$ext.zip "$zipdir/nexuizhotfix-$newest.zip"

rm -f "$zipdir/nexuizdocs$date$ext.zip"
zip $zipflags -9yr "$zipdir/nexuizdocs$date$ext.zip"       Nexuiz/gpl.txt Nexuiz/Docs
ln -snf nexuizdocs$date$ext.zip "$zipdir/nexuizdocs-$newest.zip"

rm -f "$zipdir/nexuizdebug$date$ext.zip"
zip $zipflags -9yr "$zipdir/nexuizdebug$date$ext.zip"      Nexuiz/gpl.txt Nexuiz/debuginfo/* Nexuiz/sources
ln -snf nexuizdebug$date$ext.zip "$zipdir/nexuizdebug-$newest.zip"

case "$versiontag" in
	test)
		;;
	*)
		cat <<'EOF'

NOTE: This is a RELEASE BUILD.

To upload and finish the build, these things have to be done:

- Test the build:
  - On Linux/ATI
  - On Vista/nvidia
  - On Vista/ATI
  - On Vista/Intel
  - On OSX/ATI
  - Turn on "developer 1"; watch out for suspicious messages.
  - While testing, make sure all campaign levels are tested. In CTF/KH levels,
    try to do a capture. After that, finish the game by prvm_edictset server 1
    frags 1000.
  - Play on a server running the new code. Ideally, that server should be public
    and "somewhat compatible" to old clients, and some other players should be
    on it.
- Post the build on the forum as a test release. E.g. run this script again
  with the "version" variable NOT SET, so the build gets marked "testing only",
  and upload it and post it on the forum for testing. Mention the test server
  that is already running the new code. Wait for at least one week for critical
  bug reports.
- If needed, fix the reported bugs and re-run this script for a release build.
  Possibly repeat the testing process.
- Upload the "final" build you have just made to Sourceforge (upload.sf.net,
  incoming). Use the naming scheme nexuiz-25.zip, nexuizpatch-24-to-25.zip
- Make the download available on sourceforge.
- Announce the build on the forum; update the downloads website. Note that the
  download may be still unavailable because of the SF mirror system.
- Wait for the mirrors to catch up.
- Edit the website: make a new news item for the new release, change the logo
  image in the top left for the new version (ask [-z-]).

EOF
		;;
esac
