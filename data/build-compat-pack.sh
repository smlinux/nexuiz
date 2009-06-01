#!/bin/sh

# list of files v2.4.2 clients need to play on svn servers

COMPAT_FILES="
	effectinfo.txt
	sound/announcer/male/amazing.ogg
	sound/announcer/male/awesome.ogg
	sound/misc/shield_respawn.wav
	sound/misc/strength_respawn.wav
	sound/player/pyria-skadi/coms/needhelp2.ogg
	sound/weapons/unavailable.wav
	sound/ctf/blue_dropped.wav
	sound/ctf/red_dropped.wav
	sound/ctf/flag_respawn.wav
	sound/ctf/blue_taken.wav
	sound/ctf/blue_capture.wav
	sound/ctf/red_taken.wav
	sound/ctf/red_capture.wav
	sound/ctf/blue_returned.wav
	sound/ctf/red_returned.wav
	sound/misc/itemrespawncountdown.ogg
	sound/misc/armor25.wav
	sound/misc/powerup.ogg
	sound/misc/armor17_5.wav
	sound/misc/armor10.wav
	sound/misc/armor1.wav
	sound/misc/poweroff.wav
	scripts/onslaught.shader
	models/sprites/item-extralife_frame0.tga
	models/sprites/item-extralife_frame1.tga
	models/sprites/item-fuelregen_frame0.tga
	models/sprites/item-fuelregen_frame1.tga
	models/sprites/item-invis_frame0.tga
	models/sprites/item-invis_frame1.tga
	models/sprites/item-jetpack_frame0.tga
	models/sprites/item-jetpack_frame1.tga
	models/sprites/item-shield_frame0.tga
	models/sprites/item-shield_frame1.tga
	models/sprites/item-speed_frame0.tga
	models/sprites/item-speed_frame1.tga
	models/sprites/item-strength_frame0.tga
	models/sprites/item-strength_frame1.tga
	sound/weapons/weaponpickup.ogg
	particles/particlefont.tga
	models/gibs/arm.md3
	models/gibs/arm.md3_0.skin
	models/gibs/arm.md3_1.skin
	models/gibs/arm.md3_2.skin
	models/gibs/bloodyskull.md3
	models/gibs/bloodyskull.md3_0.skin
	models/gibs/bloodyskull.md3_1.skin
	models/gibs/bloodyskull.md3_2.skin
	models/gibs/chest.md3
	models/gibs/chest.md3_0.skin
	models/gibs/chest.md3_1.skin
	models/gibs/chest.md3_2.skin
	models/gibs/chunk.mdl
	models/gibs/eye.md3
	models/gibs/leg1.md3
	models/gibs/leg1.md3_0.skin
	models/gibs/leg1.md3_1.skin
	models/gibs/leg1.md3_2.skin
	models/gibs/leg2.md3
	models/gibs/leg2.md3_0.skin
	models/gibs/leg2.md3_1.skin
	models/gibs/leg2.md3_2.skin
	models/gibs/smallchest.md3
	models/gibs/smallchest.md3_0.skin
	models/gibs/smallchest.md3_1.skin
	models/gibs/smallchest.md3_2.skin
	textures/meat_alien_gloss.tga
	textures/meat_alien_glow.tga
	textures/meat_alien_norm.tga
	textures/meat_alien.tga
	textures/meat_gloss.tga
	textures/meat_norm.tga
	textures/meat_robot_gloss.tga
	textures/meat_robot_glow.tga
	textures/meat_robot_norm.tga
	textures/meat_robot.tga
	textures/meat.tga
	textures/bloodyskull_alien_glow.tga
	textures/bloodyskull_alien.tga
	textures/bloodyskull.jpg
	textures/bloodyskull_robot_gloss.tga
	textures/bloodyskull_robot_glow.tga
	textures/bloodyskull_robot.tga
"

rm -rf pack
mkdir pack
for F in $COMPAT_FILES; do
	case "$F" in
		*/*)
			mkdir -p pack/${F%/*}
			;;
	esac
	cp "$F" pack/"$F"
done

cd pack

find textures/ -type f -print0 | qual=85 scaledown=256x256 xargs -0 ../../misc/tools/jpeg-if-not-alpha.sh

if false; then
	find . -name \*.ogg | while IFS= read -r NAME; do
		c=`vorbiscomment -l "$NAME"`
		oggdec -o "$NAME.wav" "$NAME"
		oggenc -q 0 -o "$NAME" "$NAME.wav"
		echo "$c" | vorbiscomment -w "$NAME"
		rm -f "$NAME.wav"
		touch "${NAME%.ogg}.wav" # to disable this file, should the client have it
	done
fi

rev=`svnversion .. | sed 's/M$//g; s/.*://g;'`
pack="zzz_svn-compat-$rev"
echo "Support files to play on svn servers of revision $rev" > "$pack.txt"
7za a -tzip -mx=9 "../$pack.pk3" .
rm -f "$pack.txt"

cd ..
rm -rf pack
