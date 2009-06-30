#!/bin/sh

# list of files v2.4.2 clients need to play on svn servers

COMPAT_FILES="
	effectinfo.txt
	gfx/crosshairtuba.tga
	gfx/hud/inv_weapon0.tga
	gfx/hud/inv_weapon10.tga
	gfx/hud/inv_weapon11.tga
	gfx/hud/inv_weapon12.tga
	gfx/hud/inv_weapon13.tga
	gfx/hud/inv_weapon14.tga
	gfx/hud/inv_weapon15.tga
	gfx/hud/inv_weapon1.tga
	gfx/hud/inv_weapon2.tga
	gfx/hud/inv_weapon3.tga
	gfx/hud/inv_weapon4.tga
	gfx/hud/inv_weapon5.tga
	gfx/hud/inv_weapon6.tga
	gfx/hud/inv_weapon7.tga
	gfx/hud/inv_weapon8.tga
	gfx/hud/inv_weapon9.tga
	gfx/hud/inv_weapon_hlacmod_renameit.tga
	gfx/hud/keys/key_backward_inv.tga
	gfx/hud/keys/key_backward.tga
	gfx/hud/keys/key_bg.tga
	gfx/hud/keys/key_crouch_inv.tga
	gfx/hud/keys/key_crouch.tga
	gfx/hud/keys/key_forward_inv.tga
	gfx/hud/keys/key_forward.tga
	gfx/hud/keys/key_jump_inv.tga
	gfx/hud/keys/key_jump.tga
	gfx/hud/keys/key_left_inv.tga
	gfx/hud/keys/key_left.tga
	gfx/hud/keys/key_right_inv.tga
	gfx/hud/keys/key_right.tga
	gfx/hud/num_0_stroke.tga
	gfx/hud/num_0.tga
	gfx/hud/num_1_stroke.tga
	gfx/hud/num_1.tga
	gfx/hud/num_2_stroke.tga
	gfx/hud/num_2.tga
	gfx/hud/num_3_stroke.tga
	gfx/hud/num_3.tga
	gfx/hud/num_4_stroke.tga
	gfx/hud/num_4.tga
	gfx/hud/num_5_stroke.tga
	gfx/hud/num_5.tga
	gfx/hud/num_6_stroke.tga
	gfx/hud/num_6.tga
	gfx/hud/num_7_stroke.tga
	gfx/hud/num_7.tga
	gfx/hud/num_8_stroke.tga
	gfx/hud/num_8.tga
	gfx/hud/num_9_stroke.tga
	gfx/hud/num_9.tga
	gfx/hud/num_colon_stroke.tga
	gfx/hud/num_colon.tga
	gfx/hud/num_minus_stroke.tga
	gfx/hud/num_minus.tga
	gfx/hud/num_plus_stroke.tga
	gfx/hud/num_plus.tga
	gfx/hud/sb_ammobg.tga
	gfx/hud/sb_armor.tga
	gfx/hud/sbar.tga
	gfx/hud/sb_bullets.tga
	gfx/hud/sb_cells.tga
	gfx/hud/sb_flag_blue_carrying.tga
	gfx/hud/sb_flag_blue_lost.tga
	gfx/hud/sb_flag_blue_shielded.tga
	gfx/hud/sb_flag_blue_taken.tga
	gfx/hud/sb_flag_red_carrying.tga
	gfx/hud/sb_flag_red_lost.tga
	gfx/hud/sb_flag_red_shielded.tga
	gfx/hud/sb_flag_red_taken.tga
	gfx/hud/sb_fuel.tga
	gfx/hud/sb_health.tga
	gfx/hud/sb_highlight_1.tga
	gfx/hud/sb_highlight_2.tga
	gfx/hud/sb_highlight_3.tga
	gfx/hud/sb_highlight_4.tga
	gfx/hud/sb_invinc.tga
	gfx/hud/sb_kh_blue.tga
	gfx/hud/sb_kh_pink.tga
	gfx/hud/sb_kh_red.tga
	gfx/hud/sb_kh_yellow.tga
	gfx/hud/sb_nexball_carrying.tga
	gfx/hud/sb_rocket.tga
	gfx/hud/sb_shells.tga
	gfx/hud/sb_str.tga
	gfx/hud/sb_timerbg.tga
	models/ctf/shield.md3
	models/ctf/shockwavetransring.md3
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
	models/onslaught/boom.md3
	models/onslaught/controlpoint_icon_dmg1.md3
	models/onslaught/controlpoint_icon_dmg2.md3
	models/onslaught/controlpoint_icon_dmg3.md3
	models/onslaught/controlpoint_icon_gib1.md3
	models/onslaught/controlpoint_icon_gib2.md3
	models/onslaught/controlpoint_icon_gib4.md3
	models/onslaught/controlpoint_pad2.md3
	models/onslaught/generator_dead.md3
	models/onslaught/generator_dmg1.md3
	models/onslaught/generator_dmg2.md3
	models/onslaught/generator_dmg3.md3
	models/onslaught/generator_dmg4.md3
	models/onslaught/generator_dmg5.md3
	models/onslaught/generator_dmg6.md3
	models/onslaught/generator_dmg7.md3
	models/onslaught/generator_dmg8.md3
	models/onslaught/generator_dmg9.md3
	models/onslaught/gen_gib1.md3
	models/onslaught/gen_gib2.md3
	models/onslaught/gen_gib3.md3
	models/onslaught/ons_ray.md3
	models/onslaught/shockwave.md3
	models/onslaught/shockwavetransring.md3
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
	models/weapons/g_tuba.md3
	models/weapons/h_tuba.dpm
	models/weapons/v_tuba.md3
	particles/particlefont.tga
	scripts/onslaught.shader
	sound/announcer/male/amazing.ogg
	sound/announcer/male/awesome.ogg
	sound/ctf/blue_capture.wav
	sound/ctf/blue_dropped.wav
	sound/ctf/blue_returned.wav
	sound/ctf/blue_taken.wav
	sound/ctf/flag_respawn.wav
	sound/ctf/red_capture.wav
	sound/ctf/red_dropped.wav
	sound/ctf/red_returned.wav
	sound/ctf/red_taken.wav
	sound/misc/armor10.wav
	sound/misc/armor17_5.wav
	sound/misc/armor1.wav
	sound/misc/armor25.wav
	sound/misc/itemrespawncountdown.ogg
	sound/misc/poweroff.wav
	sound/misc/powerup.ogg
	sound/misc/shield_respawn.wav
	sound/misc/strength_respawn.wav
	sound/onslaught/electricity_explode.ogg
	sound/onslaught/ons_hit1.ogg
	sound/onslaught/ons_hit2.ogg
	sound/onslaught/ons_spark1.ogg
	sound/onslaught/ons_spark2.ogg
	sound/onslaught/shockwave.ogg
	sound/player/pyria-skadi/coms/needhelp2.ogg
	sound/weapons/tuba_note0.ogg
	sound/weapons/tuba_note-10.ogg
	sound/weapons/tuba_note10.ogg
	sound/weapons/tuba_note-11.ogg
	sound/weapons/tuba_note11.ogg
	sound/weapons/tuba_note-12.ogg
	sound/weapons/tuba_note12.ogg
	sound/weapons/tuba_note-13.ogg
	sound/weapons/tuba_note13.ogg
	sound/weapons/tuba_note-14.ogg
	sound/weapons/tuba_note14.ogg
	sound/weapons/tuba_note-15.ogg
	sound/weapons/tuba_note15.ogg
	sound/weapons/tuba_note-16.ogg
	sound/weapons/tuba_note16.ogg
	sound/weapons/tuba_note-17.ogg
	sound/weapons/tuba_note17.ogg
	sound/weapons/tuba_note-18.ogg
	sound/weapons/tuba_note18.ogg
	sound/weapons/tuba_note19.ogg
	sound/weapons/tuba_note-1.ogg
	sound/weapons/tuba_note1.ogg
	sound/weapons/tuba_note20.ogg
	sound/weapons/tuba_note21.ogg
	sound/weapons/tuba_note22.ogg
	sound/weapons/tuba_note23.ogg
	sound/weapons/tuba_note24.ogg
	sound/weapons/tuba_note25.ogg
	sound/weapons/tuba_note26.ogg
	sound/weapons/tuba_note27.ogg
	sound/weapons/tuba_note-2.ogg
	sound/weapons/tuba_note2.ogg
	sound/weapons/tuba_note-3.ogg
	sound/weapons/tuba_note3.ogg
	sound/weapons/tuba_note-4.ogg
	sound/weapons/tuba_note4.ogg
	sound/weapons/tuba_note-5.ogg
	sound/weapons/tuba_note5.ogg
	sound/weapons/tuba_note-6.ogg
	sound/weapons/tuba_note6.ogg
	sound/weapons/tuba_note-7.ogg
	sound/weapons/tuba_note7.ogg
	sound/weapons/tuba_note-8.ogg
	sound/weapons/tuba_note8.ogg
	sound/weapons/tuba_note-9.ogg
	sound/weapons/tuba_note9.ogg
	sound/weapons/unavailable.wav
	sound/weapons/weaponpickup.ogg
	textures/bloodyskull_alien_glow.tga
	textures/bloodyskull_alien.tga
	textures/bloodyskull.jpg
	textures/bloodyskull_robot_gloss.tga
	textures/bloodyskull_robot_glow.tga
	textures/bloodyskull_robot.tga
	textures/generator_destroyed.tga
	textures/generator_lightning2.tga
	textures/generator_lightning.tga
	textures/generator.tga
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
	textures/ons_boom1.tga
	textures/ons_gengib.tga
	textures/ons_icon.tga
	textures/ons_icon_thrust.tga
	textures/ons_pad.tga
	textures/ons_ray.tga
	textures/ons_shockwave1.tga
	textures/ons_shockwave2.tga
	textures/ons_smoke1.tga
	textures/ons_text.tga
	textures/tuba_gloss.tga
	textures/tuba_glow.tga
	textures/tuba.tga
	scripts/tuba.shader
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
