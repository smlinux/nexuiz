#!/bin/bash

set -e

base=`pwd`


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

basepk3=$base/data20070531.pk3
nexdir=$base/nexuiz-2.0
nexprodir=$base/nexuiz-current/pro
dpdir=$base/darkplaces
tmpdir=/tmp/NEX
zipdir=/home/polzer/public_html/nexuiz/builds
buildfiles=$base/nexuiz-current/misc/buildfiles
mingwdlls=$buildfiles/w32
osxapps=$buildfiles/osx
copystrip=$buildfiles/copystrip
zipdiff=$base/nexuiz-current/misc/zipdiff
fteqccdir="$base/fteqcc"
fteqccflags=""
mingw=/home/polzer/mingw32
menuqc=menu
newest=NEWEST

if [ -n "$EXPERIMENTAL" ]; then
	basepk3=$base/data20071231.pk3 # newer build to make smaller patches
	nexdir=$base/nexuiz-current
	fteqccflags="$fteqccflags -DMAPINFO"
	ext="${ext}_svntrunk"
	menuqc="menu-div0test"
	newest=NEWEST-svntrunk
fi

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
	buildon macmini nexuiz-osx          fteqcc-osx          /tmp/Darkplaces.build 'CC="gcc -g -arch i386 -arch ppc -isysroot /Developer/SDKs/MacOSX10.4u.sdk -I/Library/Frameworks/SDL.framework/Headers"' strip
		mv "$tmpdir/nexuiz-osx-agl"     "$tmpdir/Nexuiz.app/Contents/MacOS/nexuiz-osx-agl-bin"
		mv "$tmpdir/nexuiz-osx-sdl"     "$tmpdir/Nexuiz-SDL.app/Contents/MacOS/nexuiz-osx-sdl-bin"
	buildon hagger  nexuiz-linux-686    fteqcc-linux-686    /tmp/Darkplaces.build 'CC="gcc -g" DP_MODPLUG_STATIC_LIBDIR=/usr/local/lib'
	buildon hector  nexuiz-linux-x86_64 fteqcc-linux-x86_64 /tmp/Darkplaces.build 'CC="gcc -g" DP_MODPLUG_STATIC_LIBDIR=/home/users4/ommz/polzer/libmodplug-static/lib64'
	buildon hagger  nexuiz              fteqcc.exe          /tmp/Darkplaces.build 'DP_MAKE_TARGET=mingw CC="i586-mingw32msvc-gcc -g -I/home/polzer/mingw32.include" WINDRES=i586-mingw32msvc-windres SDL_CONFIG=/home/polzer/mingw32.SDL/bin/sdl-config' i586-mingw32msvc-strip
}

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

if [ -n "$1" ]; then
	osxhost="$1"
fi

conflicts=`find "$dpdir" "$nexdir" -name '*.orig' -o -name '*.rej' -o -name '*.mine' -o -name '.#*' -o -name '.*~'`
if [ -n "$conflicts" ]; then
	echo "CONFLICTS OR UNNEEDED FILES HAVE BEEN FOUND!"
	echo "NOT PROCEEDING"
	echo
	echo "$conflicts"
	exit 1
fi

set -x

rm -rf "$tmpdir"
mkdir -p "$tmpdir"

cd "$dpdir"
quilt pop -a || true
svn revert -R .
quilt push -a # apply all patches

cp -r "$osxapps"/*.app "$tmpdir"
mkdir "$tmpdir/debuginfo"
mkdir "$tmpdir/fteqcc"

svn export "$fteqccdir" "$tmpdir/fteqcc/source"
svn info "$fteqccdir" > "$tmpdir/fteqcc/source/fteqcc-base-revision.txt"
fteqccrev=$((`grep "Last Changed Rev:" "$tmpdir/fteqcc/source/fteqcc-base-revision.txt" | cut -d : -f 2`))
echo "fteqcc rev $fteqccrev"

rm -f *.exe nexuiz-* *-withdebug* *.o
make clean
build
rm -f *.exe nexuiz-* *-withdebug '.#'* *.o
rm -rf fteqcc copystrip
make clean

cd "$tmpdir"
cp "$nexdir/"nexuiz-*.sh "$tmpdir/"
cp "$nexdir/"nexuiz-*.bat "$tmpdir/"
cp "$nexdir/gpl.txt" "$tmpdir/"

cd "$nexdir/data"
svn export . "$tmpdir/data"

cd "$nexprodir"
svn export . "$tmpdir/pro"

cd "$nexdir/Docs"
svn export . "$tmpdir/Docs"

cd "$tmpdir/data"
mkdir -p "$tmpdir/sources"
#zip -9r ../sources/gamesource$date.zip qcsrc
7za a -mx=9 -tzip ../sources/gamesource$date.zip qcsrc

cd "$dpdir"
svn export . "$tmpdir/darkplaces"
svn info > "$tmpdir/darkplaces/nexuiz-base-revision.txt"
svn diff > "$tmpdir/darkplaces/nexuiz-engine-changes.diff"
svn log > "$tmpdir/darkplaces/ChangeLog"

cd "$tmpdir"
7za a -mx=9 -tzip "$tmpdir/sources/enginesource$date.zip" "darkplaces"
rm -rf darkplaces

cd "$tmpdir"
zip -9r "$tmpdir/sources/fteqcc-binaries-and-source-rev$fteqccrev.zip" "fteqcc"
rm -rf fteqcc

cd "$fteqccdir"
rm -f *.o *.bin
make

cd "$tmpdir/data/qcsrc/$menuqc"
"$fteqccdir/fteqcc.bin" $fteqccflags

cd "$tmpdir/data/qcsrc/server"
"$fteqccdir/fteqcc.bin" $fteqccflags

if [ -z "$EXPERIMENTAL" ]; then
	rm -rf "$tmpdir/data/qcsrc"
fi

cd "$tmpdir/Docs"
perl -pi -e '/^#---SET nexversion=([0-9.]*)$/ and $_ = "#---SET nexversion='$version'\n"' FAQ.aft
perl -pi -e '/^\s*Version ([0-9.]*)<\/div>$/ and $_ = "Version '$version'</div>\n"' Readme.htm
cp "$dpdir/darkplaces.txt" .
aft FAQ.aft
aft FAQ.aft
rm FAQ.aft-TOC

cd "$tmpdir/data"
mv common-spog.pk3 ..
perl -pi -e '/^set g_nexuizversion "?([0-9.]*)[^"]*"?/ and $_ = "set g_nexuizversion '$version'\n"' default.cfg
if [ -n "$versiontag" ]; then
	perl -pi -e '/^set g_nexuizversion/ and $_ = "showbrand 3\n$_"' default.cfg
	cp "$buildfiles/brand/$versiontag.tga" gfx/brand.tga
fi
echo >> default.cfg
echo "$defaultcfg" >> default.cfg
7za a -mx=7 -tzip ../data.pk3 .

cd "$tmpdir/pro"
perl -pi -e '/^set g_nexuizversion "?([0-9.]*)[^"]*"?/ and $_ = "set g_nexuizversion '$version-pro'\n"' default.cfg
if [ -n "$versiontag" ]; then
	perl -pi -e '/^set g_nexuizversion/ and $_ = "showbrand 3\n$_"' default.cfg
fi
echo >> default.cfg
echo "$defaultcfg" >> default.cfg
7za a -mx=7 -tzip ../pro.pk3 .

cd "$tmpdir"
rm -rf data
mkdir data
mv data.pk3 data/data$date.pk3
mv common-spog.pk3 data/
rm -rf pro
mkdir pro
mv pro.pk3 pro/data${date}pro.pk3

cp -r "$mingwdlls"/* .
# fix up permissions
chmod 644 *.dll *.exe

mkdir Nexuiz
mv * Nexuiz/ || true

find . -name .svn -exec rm -rf {} \; -prune

rm -f "$zipdir/nexuiz$date$ext.zip"
zip $zipflags -9yr "$zipdir/nexuiz$date$ext.zip"           Nexuiz/gpl.txt Nexuiz/nexuiz* Nexuiz/Nexuiz* Nexuiz/*.dll Nexuiz/sources Nexuiz/Docs Nexuiz/data/data$date.pk3 Nexuiz/data/common-spog.pk3 Nexuiz/pro/*
ln -snf nexuiz$date$ext.zip "$zipdir/nexuiz-$newest.zip"

rm -f "$zipdir/nexuizengineonly$date$ext.zip"
zip $zipflags -9yr "$zipdir/nexuizengineonly$date$ext.zip" Nexuiz/gpl.txt Nexuiz/nexuiz* Nexuiz/Nexuiz* Nexuiz/*.dll
ln -snf nexuizengineonly$date$ext.zip "$zipdir/nexuizengineonly-$newest.zip"

rm -f "$zipdir/nexuizsource$date$ext.zip"
zip $zipflags -9yr "$zipdir/nexuizsource$date$ext.zip"     Nexuiz/gpl.txt                                            Nexuiz/sources
ln -snf nexuizsource$date$ext.zip "$zipdir/nexuizsource-$newest.zip"

$zipdiff -o "Nexuiz/data/datapatch$date.pk3" -f "$basepk3" -t Nexuiz/data/data$date.pk3 -x 'sound/cdtracks/track*.ogg'
mkdir -p gfx
if unzip "Nexuiz/data/data$date.pk3" gfx/brand.tga; then
	zip $zipflags -9r "Nexuiz/data/datapatch$date.pk3" gfx/brand.tga
	rm -rf gfx
fi

rm -f "$zipdir/nexuizpatch$date$ext.zip"
zip $zipflags -9yr "$zipdir/nexuizpatch$date$ext.zip"      Nexuiz/gpl.txt Nexuiz/nexuiz* Nexuiz/Nexuiz* Nexuiz/*.dll Nexuiz/sources Nexuiz/Docs Nexuiz/data/datapatch$date.pk3 Nexuiz/pro/*
ln -snf nexuizpatch$date$ext.zip "$zipdir/nexuizpatch-$newest.zip"

rm -f "$zipdir/nexuizdocs$date$ext.zip"
zip $zipflags -9yr "$zipdir/nexuizdocs$date$ext.zip"       Nexuiz/gpl.txt Nexuiz/Docs
ln -snf nexuizdocs$date$ext.zip "$zipdir/nexuizdocs-$newest.zip"

rm -f "$zipdir/nexuizdebug$date$ext.zip"
zip $zipflags -9yr "$zipdir/nexuizdebug$date$ext.zip"      Nexuiz/gpl.txt Nexuiz/debuginfo/* Nexuiz/sources
ln -snf nexuizdebug$date$ext.zip "$zipdir/nexuizdebug-$newest.zip"
