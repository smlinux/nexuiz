#!/bin/sh
set -ex

base=`pwd`

basepk3=$base/../Nexuiz/data/data20060614.pk3
nexdir=$base/nexuiz
dpdir=$base/darkplaces
tmpdir=/tmp/NEX
zipdir=/home/polzer/UT/distfiles/nex/
mingwdlls=$base/buildfiles/w32
osxapps=$base/buildfiles/osx
fteqcc="fteqcc.bin -O2"
mingw=/home/polzer/mingw32
ia32=/chroot/fc4-i386
osxhost=macmini_osx
osxtemp=/Users/rpolzer/Darkplaces.build

if [ -n "$1" ]; then
	osxhost=macmini
fi

: ${date:=`date +%Y%m%d`}
echo "date stamp: $date"

buildosx()
{
	rsync --exclude "*.o" --exclude "*.d" --exclude "nexuiz-*" --delete-excluded --delete -zvaSHP . "$osxhost:$osxtemp"
	ssh "$osxhost" ". ~/.profile && cd $osxtemp && make CC=\"gcc -arch i386 -arch ppc -isysroot /Developer/SDKs/MacOSX10.4u.sdk\" clean $*"
	rsync --exclude "*.o" --exclude "*.d" --delete-excluded --delete -zvaSHP "$osxhost:$osxtemp/." .
}

build64()
{
	make "$@"
}

build32()
{
	make CC="gcc -I$ia32/usr/include -I$ia32/usr/X11R6/include -L$ia32/usr/lib -L$ia32/usr/X11R6/lib -m32" DP_MACHINE=i686 "$@"
}

buildwin()
{
	PATH=$mingw/bin:$PATH make DP_MAKE_TARGET=mingw "$@"
}

rm -rf "$tmpdir"
mkdir -p "$tmpdir"
cd "$dpdir"

cp -r "$osxapps"/*.app "$tmpdir"
rm -f *.exe nexuiz-*

make clean
buildosx sdl-nexuiz cl-nexuiz sv-nexuiz
cp nexuiz-agl "$tmpdir/Nexuiz.app/Contents/MacOS/nexuiz-osx-ppc-agl-bin"
cp nexuiz-dedicated "$tmpdir/nexuiz-osx-ppc-dedicated"
cp nexuiz-sdl "$tmpdir/Nexuiz-SDL.app/Contents/MacOS/nexuiz-osx-ppc-sdl-bin"

make clean
buildwin nexuiz
for x in -dedicated -sdl ''; do
	cp nexuiz$x.exe "$tmpdir/nexuiz$x.exe"
done

make clean
build32 nexuiz
for x in dedicated sdl glx; do
	cp nexuiz-$x "$tmpdir/nexuiz-linux-686-$x"
done

make clean
build64 nexuiz
for x in dedicated sdl glx; do
	cp nexuiz-$x "$tmpdir/nexuiz-linux-x86_64-$x"
done

cp "$nexdir/nexuiz-linux.sh" "$tmpdir/"
cp "$nexdir/gpl.txt" "$tmpdir/"

make clean
rm -f *.exe nexuiz-*

cd "$nexdir/data"
svn export . "$tmpdir/data"

cd "$nexdir/Docs"
svn export . "$tmpdir/Docs"

cd "$tmpdir/data"
mkdir -p "$tmpdir/sources"
#zip -9r ../sources/gamesource$date.zip qcsrc
7za a -mx=9 -tzip ../sources/gamesource$date.zip qcsrc

cd "$dpdir/.."
#zip -9r "$tmpdir/sources/enginesource$date.zip" "${dpdir##*/}"
7za a -mx=9 -tzip "$tmpdir/sources/enginesource$date.zip" "${dpdir##*/}"

cd "$tmpdir/data/qcsrc/menu"
$fteqcc

cd "$tmpdir/data/qcsrc/server"
$fteqcc

rm -rf "$tmpdir/data/qcsrc"

cd "$tmpdir/data"
mv common-spog.pk3 ..
#zip -9r ../data.pk3 .
7za a -mx=7 -tzip ../data.pk3 .

cd "$tmpdir"
rm -rf data
mkdir data
mv data.pk3 data/data$date.pk3
mv common-spog.pk3 data/

cp -r "$mingwdlls"/* .
# fix up permissions
chmod 644 *.dll *.exe

mkdir Nexuiz
mv * Nexuiz/ || true

rm -f "$zipdir/nexuiz$date$ext.zip"
zip -9yr "$zipdir/nexuiz$date$ext.zip"           Nexuiz/gpl.txt Nexuiz/nexuiz* Nexuiz/Nexuiz* Nexuiz/*.dll Nexuiz/sources Nexuiz/Docs Nexuiz/data/data$date.pk3 Nexuiz/data/common-spog.pk3
rm -f "$zipdir/nexuizengineonly$date$ext.zip"
zip -9yr "$zipdir/nexuizengineonly$date$ext.zip" Nexuiz/gpl.txt Nexuiz/nexuiz* Nexuiz/Nexuiz* Nexuiz/*.dll
rm -f "$zipdir/nexuizsource$date$ext.zip"
zip -9yr "$zipdir/nexuizsource$date$ext.zip"     Nexuiz/gpl.txt                                            Nexuiz/sources

zipdiff -o Nexuiz/data/datapatch$date.pk3 -f "$basepk3" -t Nexuiz/data/data$date.pk3
rm -f "$zipdir/nexuizpatch$date$ext.zip"
zip -9yr "$zipdir/nexuizpatch$date$ext.zip"      Nexuiz/gpl.txt Nexuiz/nexuiz* Nexuiz/Nexuiz* Nexuiz/*.dll Nexuiz/sources Nexuiz/Docs Nexuiz/data/datapatch$date.pk3
