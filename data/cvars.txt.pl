#!/usr/bin/perl
use strict;
use warnings;

my $ignore_re = qr{
|	_.*                              # temp cvars

|	csqc_.*                          # internal
|	gamecfg                          # internal
|	g_configversion                  # internal
|	g_maplist_index                  # internal
|	halflifebsp                      # internal
|	cvar_check_.*                    # internal

|	cl_.*	                         # client
|	con_.*	                         # client
|	g_campaign.*                     # client
|	gl_.*	                         # client
|	joy.*	                         # client
|	menu_.*	                         # client
|	mod_q3bsp_lightmapmergepower     # client
|	mod_q3bsp_nolightmaps            # client
|	net_slist_.*	                 # client
|	r_.*                             # client
|	sbar_.*	                         # client
|	scr_.*	                         # client
|	userbind.*                       # client
|	v_.*                             # client
|	vid_.*                           # client

|	g_banned_list                    # private
|	g_ban_sync.*                     # private
|	log_dest_udp                     # private
|	log_file                         # private
|	net_address                      # private
|	port                             # private
|	rcon_.*                          # private
|	savedgamecfg                     # private
|	settemp_.*                       # private
|	sv_allowdownloads_.*             # private
|	sv_autodemo.*                    # private
|	sv_curl_.*                       # private
|	sv_eventlog.*                    # private
|	sv_heartbeatperoid               # private
|	sv_logscores_.*                  # private
|	sv_master.*                      # private
|	sv_vote_master_password          # private
|	sys_colortranslation             # private
|	sys_specialcharactertranslation  # private
|	timestamps                       # private

|	capturelimit                     # mapinfo
|	timelimit                        # mapinfo
|	fraglimit                        # mapinfo
|	g_arena                          # mapinfo
|	g_assault                        # mapinfo
|	g_ctf                            # mapinfo
|	g_dm                             # mapinfo
|	g_domination                     # mapinfo
|	g_keyhunt                        # mapinfo
|	g_keyhunt_teams                  # mapinfo
|	g_onslaught                      # mapinfo
|	g_race                           # mapinfo
|	g_runematch                      # mapinfo
|	g_tdm                            # mapinfo
|	teamplay                         # mapinfo

|	hostname                         # shown already
|	g_maplist                        # too long
|	g_maplist_mostrecent             # too long
|	sv_motd                          # too long
}x;

while(<DATA>)
{
	chomp;
	if(/^(?:\^7)?([a-z0-9_]*) is "(.*?)" \["(.*?)"\] (.*)$/)
	{
		my ($cvar, $value, $default, $description) = ($1, $2, $3, $4);
		if($cvar =~ /^$ignore_re$/)
		{
			next;
		}
		if($default ne $value)
		{
			die "Run this on a DEFAULT config ($cvar has been changed from $default to $value)";
		}
		if($description eq 'custom cvar')
		{
			print "\"$cvar\" \"TODO: describe me\"\n";
		}
		else
		{
			print "\"$cvar\"\n";
		}
	}
}

__DATA__
List made using:
nexuiz-dedicated +sys_colortranslation 2 +sys_specialcharactertranslation 0 +cvarlist +quit

Nexuiz Linux 10:44:57 Dec 15 2008 8589 debug
Trying to load library... "libz.so.1" - loaded.
Added packfile data/common-spog.pk3 (26 files)
data/zzz_svn-compat-5011:5013.pk3 is not a PK3 file
unable to load pak "data/zzz_svn-compat-5011:5013.pk3"
Added packfile data/zzz_svn-compat-5014.pk3 (527 files)
data/zzz_svn-compat-5209:5214.pk3 is not a PK3 file
unable to load pak "data/zzz_svn-compat-5209:5214.pk3"
Trying to load library... "libcurl.so.4" "libcurl.so.3" - loaded.
execing quake.rc
execing default.cfg
execing defaultNexuiz.cfg
execing physicsQBR.cfg
execing newhook.cfg
execing ctfscoring-div0.cfg
execing weapons.cfg
execing normal.cfg
Warning: Could not expand $r_showsurfaces
Warning: Could not expand $gl_finish
Warning: Could not expand $v_kicktime
Warning: Could not expand $qport in alias if_dedicated
execing turrets.cfg
execing unit_machinegun.cfg
execing unit_hk.cfg
execing unit_hellion.cfg
execing unit_mlrs.cfg
execing unit_flac.cfg
execing unit_fusreac.cfg
execing unit_plasma.cfg
execing unit_plasma2.cfg
execing unit_tesla.cfg
execing unit_phaser.cfg
execing unit_walker.cfg
execing unit_ewheel.cfg
couldn't exec config.cfg
execing config_update.cfg
Warning: Could not expand $v_hwgamma in alias _update_configversion_0
Warning: Could not expand $r_glsl_contrastboost in alias _update_configversion_0
Warning: Could not expand $r_glsl_contrastboost in alias _update_0_r_glsl_cb_1
Ignore the error message above, the check works fine otherwise 
couldn't exec data/campaign.cfg
couldn't exec autoexec.cfg
^7_alientrap_net_banlist is "" [""] custom cvar
^7_backup_con_chatvars_set is "0" ["0"] custom cvar
^7_cl_color is "102" ["102"] internal storage cvar for current player colors (changed by color command)
^7_cl_name is "Player" ["Player"] internal storage cvar for current player name (changed by name command)
^7_cl_playermodel is "models/player/marine.zym" ["models/player/marine.zym"] internal storage cvar for current player model in Nexuiz (changed by playermodel command)
^7_cl_playerskin is "0" ["0"] internal storage cvar for current player skin in Nexuiz (changed by playerskin command)
^7_cl_rate is "20000" ["20000"] internal storage cvar for current rate (changed by rate command)
^7_supports_weaponpriority is "0" ["0"] custom cvar
^7_update_0_have_r_glsl_cb is "1" ["1"] custom cvar
^7bot_ai_aimskill_blendrate is "2" ["2"] custom cvar
^7bot_ai_aimskill_firetolerance_distdegrees is "180" ["180"] custom cvar
^7bot_ai_aimskill_firetolerance_maxdegrees is "45" ["45"] custom cvar
^7bot_ai_aimskill_firetolerance_mindegrees is "2" ["2"] custom cvar
^7bot_ai_aimskill_fixedrate is "15" ["15"] custom cvar
^7bot_ai_aimskill_mouse is "1" ["1"] custom cvar
^7bot_ai_aimskill_offset is "1" ["1"] custom cvar
^7bot_ai_aimskill_order_filter_1st is "0.2" ["0.2"] custom cvar
^7bot_ai_aimskill_order_filter_2nd is "0.2" ["0.2"] custom cvar
^7bot_ai_aimskill_order_filter_3th is "0.05" ["0.05"] custom cvar
^7bot_ai_aimskill_order_filter_4th is "0.25" ["0.25"] custom cvar
^7bot_ai_aimskill_order_filter_5th is "0.3" ["0.3"] custom cvar
^7bot_ai_aimskill_order_mix_1st is "0.01" ["0.01"] custom cvar
^7bot_ai_aimskill_order_mix_2nd is "0.1" ["0.1"] custom cvar
^7bot_ai_aimskill_order_mix_3th is "0.01" ["0.01"] custom cvar
^7bot_ai_aimskill_order_mix_4th is "0.05" ["0.05"] custom cvar
^7bot_ai_aimskill_order_mix_5th is "0.01" ["0.01"] custom cvar
^7bot_ai_aimskill_think is "1" ["1"] custom cvar
^7bot_ai_chooseweaponinterval is "0.3" ["0.3"] custom cvar
^7bot_ai_dangerdetectioninterval is "0.1" ["0.1"] custom cvar
^7bot_ai_dangerdetectionupdates is "64" ["64"] custom cvar
^7bot_ai_dodgeupdateinterval is "0.1" ["0.1"] custom cvar
^7bot_ai_enemydetectioninterval is "0.5" ["0.5"] custom cvar
^7bot_ai_keyboard_distance is "250" ["250"] custom cvar
^7bot_ai_keyboard_treshold is "0.57" ["0.57"] custom cvar
^7bot_ai_strategyinterval is "2" ["2"] custom cvar
^7bot_ai_thinkinterval is "0.05" ["0.05"] custom cvar
^7bot_ignore_bots is "0" ["0"] custom cvar
^7bot_join_empty is "0" ["0"] custom cvar
^7bot_nofire is "0" ["0"] custom cvar
^7bot_number is "0" ["0"] custom cvar
^7bot_prefix is "[BOT]" ["[BOT]"] custom cvar
^7bot_suffix is "" [""] custom cvar
^7bot_usemodelnames is "0" ["0"] custom cvar
^7bot_vs_human is "0" ["0"] custom cvar
^7capturelimit is "0" ["0"] custom cvar
^7capturelimit_override is "-1" ["-1"] custom cvar
^7cl_autoswitch is "1" ["1"] custom cvar
^7cl_curl_enabled is "1" ["1"] whether client's download support is enabled
^7cl_curl_maxdownloads is "1" ["1"] maximum number of concurrent HTTP/FTP downloads
^7cl_curl_maxspeed is "300" ["300"] maximum download speed (KiB/s)
^7cl_gravity is "800" ["800"] custom cvar
^7cl_handicap is "1" ["1"] custom cvar
^7cl_hidewaypoints is "0" ["0"] custom cvar
^7cl_maxfps is "0" ["0"] maximum fps cap, 0 = unlimited, if game is running faster than this it will wait before running another frame (useful to make cpu time available to other programs)
^7cl_maxidlefps is "20" ["20"] maximum fps cap when the game is not the active window (makes cpu time available to other programs
^7cl_minfps is "40" ["40"] minimum fps target - while the rendering performance is below this, it will drift toward lower quality
^7cl_minfps_fade is "0.2" ["0.2"] how fast the quality adapts to varying framerate
^7cl_minfps_qualitymax is "1" ["1"] highest allowed drawdistance multiplier
^7cl_minfps_qualitymin is "0.25" ["0.25"] lowest allowed drawdistance multiplier
^7cl_minfps_qualitypower is "4" ["4"] raises quality value to a power of itself, higher values make quality drop more sharply in relation to framerate
^7cl_minfps_qualityscale is "0.5" ["0.5"] multiplier for quality
^7cl_netlocalping is "0" ["0"] lags local loopback connection by this much ping time (useful to play more fairly on your own server with people with higher pings)
^7cl_netpacketloss_receive is "0" ["0"] drops this percentage of incoming packets, useful for testing network protocol robustness (jerky movement, effects failing to start, sounds failing to play, etc)
^7cl_netpacketloss_send is "0" ["0"] drops this percentage of outgoing packets, useful for testing network protocol robustness (jerky movement, prediction errors, etc)
^7cl_nogibs is "0" ["0"] custom cvar
^7cl_playerdetailreduction is "0" ["0"] custom cvar
^7cl_port is "0" ["0"] forces client to use chosen port number if not 0
^7cl_shownames is "1" ["1"] custom cvar
^7cl_teamradar is "1" ["1"] custom cvar
^7cl_teamradar_background_alpha is "0.4" ["0.4"] custom cvar
^7cl_teamradar_foreground_alpha is "0.8" ["0.8"] custom cvar
^7cl_teamradar_position is "0 0" ["0 0"] custom cvar
^7cl_teamradar_rotation is "0" ["0"] custom cvar
^7cl_teamradar_scale is "4096" ["4096"] custom cvar
^7cl_teamradar_size is "128 128" ["128 128"] custom cvar
^7cl_teamradar_zoommode is "0" ["0"] custom cvar
^7cl_weaponpriority is "14 13 9 8 11 7 6 5 4 3 2 1 10 12" ["14 13 9 8 11 7 6 5 4 3 2 1 10 12"] custom cvar
^7cl_weaponpriority0 is "14 9 8 4" ["14 9 8 4"] custom cvar
^7cl_weaponpriority1 is "13 7 6 5 1" ["13 7 6 5 1"] custom cvar
^7cl_weaponpriority2 is "7 3" ["7 3"] custom cvar
^7cl_weaponpriority3 is "7 3 2" ["7 3 2"] custom cvar
^7cl_weaponpriority4 is "13 8 6 5 2" ["13 8 6 5 2"] custom cvar
^7cl_weaponpriority5 is "1 12 10" ["1 12 10"] custom cvar
^7cl_weaponpriority6 is "" [""] custom cvar
^7cl_weaponpriority7 is "" [""] custom cvar
^7cl_weaponpriority8 is "" [""] custom cvar
^7cl_weaponpriority9 is "" [""] custom cvar
^7cl_weaponpriority_useforcycling is "0" ["0"] custom cvar
^7cl_zoomfactor is "5" ["5"] custom cvar
^7cl_zoomsensitivity is "0" ["0"] custom cvar
^7cl_zoomspeed is "3.5" ["3.5"] custom cvar
^7cmdline is "/nexuiz/haggerCTF/Nexuiz/darkplaces/nexuiz-dedicated +sys_colortranslation 2 +sys_specialcharactertranslation 0 +cvarlist +quit " ["/nexuiz/haggerCTF/Nexuiz/darkplaces/nexuiz-dedicated +sys_colortranslation 2 +sys_specialcharactertranslation 0 +cvarlist +quit "] contains commandline the engine was launched with
^7collision_endnudge is "0" ["0"] how much to bias collision trace end
^7collision_enternudge is "0" ["0"] how much to bias collision entry fraction
^7collision_impactnudge is "0.03125" ["0.03125"] how much to back off from the impact
^7collision_leavenudge is "0" ["0"] how much to bias collision exit fraction
^7collision_prefernudgedfraction is "1" ["1"] whether to sort collision events by nudged fraction (1) or real fraction (0)
^7collision_startnudge is "0" ["0"] how much to bias collision trace start
^7con_chat is "5" ["5"] how many chat lines to show in a dedicated chat area
^7con_chatpos is "-7" ["-7"] where to put chat (negative: lines from bottom of screen, positive: lines below notify, 0: at top)
^7con_chatsize is "10" ["10"] chat text size in virtual 2D pixels (if con_chat is enabled)
^7con_chattime is "30" ["30"] how long chat lines last, in seconds
^7con_chatwidth is "0.6" ["0.6"] relative chat window width
^7con_completion_chmap is "map" ["map"] custom cvar
^7con_completion_exec is "*.cfg" ["*.cfg"] (null)
^7con_completion_gotomap is "map" ["map"] custom cvar
^7con_completion_playdemo is "*.dem" ["*.dem"] (null)
^7con_completion_ply is "*.dem" ["*.dem"] custom cvar
^7con_completion_tdem is "*.dem" ["*.dem"] custom cvar
^7con_completion_timedemo is "*.dem" ["*.dem"] (null)
^7con_completion_vdomap is "map" ["map"] custom cvar
^7con_completion_vmap is "map" ["map"] custom cvar
^7con_nickcompletion is "1" ["1"] tab-complete nicks in console and message input
^7con_nickcompletion_flags is "11" ["11"] Bitfield: 0: add nothing after completion. 1: add the last color after completion. 2: add a quote when starting a quote instead of the color. 4: will replace 1, will force color, even after a quote. 8: ignore non-alphanumerics. 16: ignore spaces. 
^7con_notify is "4" ["4"] how many notify lines to show
^7con_notifyalign is "" [""] how to align notify lines: 0 = left, 0.5 = center, 1 = right, empty string = game default)
^7con_notifysize is "10" ["10"] notify text size in virtual 2D pixels
^7con_notifytime is "3" ["3"] how long notify lines last, in seconds
^7con_textsize is "8" ["8"] console text size in virtual 2D pixels
^7coop is "0" ["0"] coop mode, 0 = no coop, 1 = coop mode, multiple players playing through the singleplayer game (coop mode also shuts off deathmatch)
^7csqc_progcrc is "-1" ["-1"] CRC of csprogs.dat file to load (-1 is none), only used during level changes and then reset to -1
^7csqc_progname is "csprogs.dat" ["csprogs.dat"] name of csprogs.dat file to load
^7csqc_progsize is "-1" ["-1"] file size of csprogs.dat file to load (-1 is none), only used during level changes and then reset to -1
^7cutscene is "1" ["1"] enables cutscenes in nehahra, can be used by other mods
^7cvar_check_default is "3e222928f6156061e54639483d8961f0" ["3e222928f6156061e54639483d8961f0"] custom cvar
^7cvar_check_weapons is "bf8a055d6b6b090133b248bccf916024" ["bf8a055d6b6b090133b248bccf916024"] custom cvar
^7deathmatch is "1" ["1"] deathmatch mode, values depend on mod but typically 0 = no deathmatch, 1 = normal deathmatch with respawning weapons, 2 = weapons stay (players can only pick up new weapons)
^7deathmatch_force_teamplay is "0" ["0"] custom cvar
^7developer is "0" ["0"] prints additional debugging messages and information (recommended for modders and level designers)
^7developer_entityparsing is "0" ["0"] prints detailed network entities information each time a packet is received
^7developer_loadfile is "0" ["0"] prints name and size of every file loaded via the FS_LoadFile function (which is almost everything)
^7developer_loading is "0" ["0"] prints information about files as they are loaded or unloaded successfully
^7developer_memory is "0" ["0"] prints debugging information about memory allocations
^7developer_memorydebug is "0" ["0"] enables memory corruption checks (very slow)
^7developer_networking is "0" ["0"] prints all received and sent packets (recommended only for debugging)
^7edgefriction is "1" ["1"] how much you slow down when nearing a ledge you might fall off, multiplier of sv_friction (Quake used 2, QuakeWorld used 1 due to a bug in physics code)
^7ekg is "0" ["0"] custom cvar
^7fraglimit is "0" ["0"] ends level if this many frags is reached by any player
^7fraglimit_override is "-1" ["-1"] custom cvar
^7fs_empty_files_in_pack_mark_deletions is "1" ["1"] if enabled, empty files in a pak/pk3 count as not existing but cancel the search in further packs, effectively allowing patch pak/pk3 files to 'delete' files
^7g_antilag is "2" ["2"] custom cvar
^7g_arena is "0" ["0"] custom cvar
^7g_arena_maxspawned is "2" ["2"] custom cvar
^7g_arena_powerups is "0" ["0"] custom cvar
^7g_arena_roundbased is "1" ["1"] custom cvar
^7g_arena_warmup is "5" ["5"] custom cvar
^7g_assault is "0" ["0"] custom cvar
^7g_balance_armor_blockpercent is "0.6" ["0.6"] custom cvar
^7g_balance_armor_limit is "999" ["999"] custom cvar
^7g_balance_armor_regen is "0" ["0"] custom cvar
^7g_balance_armor_regenlinear is "0" ["0"] custom cvar
^7g_balance_armor_rot is "0.1" ["0.1"] custom cvar
^7g_balance_armor_rotlinear is "0" ["0"] custom cvar
^7g_balance_armor_stable is "100" ["100"] custom cvar
^7g_balance_armor_start is "0" ["0"] custom cvar
^7g_balance_cloaked_alpha is "0.25" ["0.25"] custom cvar
^7g_balance_crylink_primary_ammo is "2" ["2"] custom cvar
^7g_balance_crylink_primary_animtime is "0.3" ["0.3"] custom cvar
^7g_balance_crylink_primary_bouncedamagefactor is "0.5" ["0.5"] custom cvar
^7g_balance_crylink_primary_bounces is "1" ["1"] custom cvar
^7g_balance_crylink_primary_damage is "20" ["20"] custom cvar
^7g_balance_crylink_primary_edgedamage is "0" ["0"] custom cvar
^7g_balance_crylink_primary_force is "-55" ["-55"] custom cvar
^7g_balance_crylink_primary_middle_fadetime is "5" ["5"] custom cvar
^7g_balance_crylink_primary_middle_lifetime is "5" ["5"] custom cvar
^7g_balance_crylink_primary_other_fadetime is "0.2" ["0.2"] custom cvar
^7g_balance_crylink_primary_other_lifetime is "0.1" ["0.1"] custom cvar
^7g_balance_crylink_primary_radius is "80" ["80"] custom cvar
^7g_balance_crylink_primary_refire is "0.4" ["0.4"] custom cvar
^7g_balance_crylink_primary_shots is "4" ["4"] custom cvar
^7g_balance_crylink_primary_speed is "7000" ["7000"] custom cvar
^7g_balance_crylink_primary_spread is "0.03" ["0.03"] custom cvar
^7g_balance_crylink_primary_star_fadetime is "0.2" ["0.2"] custom cvar
^7g_balance_crylink_primary_star_lifetime is "0.1" ["0.1"] custom cvar
^7g_balance_crylink_secondary_ammo is "2" ["2"] custom cvar
^7g_balance_crylink_secondary_animtime is "0.3" ["0.3"] custom cvar
^7g_balance_crylink_secondary_bouncedamagefactor is "0.5" ["0.5"] custom cvar
^7g_balance_crylink_secondary_bounces is "0" ["0"] custom cvar
^7g_balance_crylink_secondary_damage is "20" ["20"] custom cvar
^7g_balance_crylink_secondary_edgedamage is "0" ["0"] custom cvar
^7g_balance_crylink_secondary_force is "-55" ["-55"] custom cvar
^7g_balance_crylink_secondary_line_fadetime is "2" ["2"] custom cvar
^7g_balance_crylink_secondary_line_lifetime is "2" ["2"] custom cvar
^7g_balance_crylink_secondary_middle_fadetime is "5" ["5"] custom cvar
^7g_balance_crylink_secondary_middle_lifetime is "5" ["5"] custom cvar
^7g_balance_crylink_secondary_radius is "3" ["3"] custom cvar
^7g_balance_crylink_secondary_refire is "0.5" ["0.5"] custom cvar
^7g_balance_crylink_secondary_shots is "7" ["7"] custom cvar
^7g_balance_crylink_secondary_speed is "7000" ["7000"] custom cvar
^7g_balance_crylink_secondary_spread is "0.08" ["0.08"] custom cvar
^7g_balance_ctf_damageforcescale is "1" ["1"] custom cvar
^7g_balance_ctf_delay_collect is "1.0" ["1.0"] custom cvar
^7g_balance_curse_empathy_minhealth is "20" ["20"] custom cvar
^7g_balance_curse_empathy_takedamage is "-0.4" ["-0.4"] custom cvar
^7g_balance_curse_slow_atkrate is "1.5" ["1.5"] custom cvar
^7g_balance_curse_slow_jumpheight is "1.0" ["1.0"] custom cvar
^7g_balance_curse_slow_moverate is "0.8" ["0.8"] custom cvar
^7g_balance_curse_venom_hpmod is "0.6" ["0.6"] custom cvar
^7g_balance_curse_venom_limitmod is "1" ["1"] custom cvar
^7g_balance_curse_venom_rotrate is "3.0" ["3.0"] custom cvar
^7g_balance_curse_vulner_takedamage is "2.0" ["2.0"] custom cvar
^7g_balance_curse_weak_damage is "0.5" ["0.5"] custom cvar
^7g_balance_curse_weak_force is "0.6" ["0.6"] custom cvar
^7g_balance_electro_combo_damage is "70" ["70"] custom cvar
^7g_balance_electro_combo_edgedamage is "0" ["0"] custom cvar
^7g_balance_electro_combo_force is "200" ["200"] custom cvar
^7g_balance_electro_combo_radius is "250" ["250"] custom cvar
^7g_balance_electro_combo_speed is "2000" ["2000"] custom cvar
^7g_balance_electro_primary_ammo is "2" ["2"] custom cvar
^7g_balance_electro_primary_animtime is "0.3" ["0.3"] custom cvar
^7g_balance_electro_primary_damage is "80" ["80"] custom cvar
^7g_balance_electro_primary_edgedamage is "0" ["0"] custom cvar
^7g_balance_electro_primary_force is "200" ["200"] custom cvar
^7g_balance_electro_primary_lifetime is "30" ["30"] custom cvar
^7g_balance_electro_primary_radius is "150" ["150"] custom cvar
^7g_balance_electro_primary_refire is "0.6" ["0.6"] custom cvar
^7g_balance_electro_primary_speed is "2000" ["2000"] custom cvar
^7g_balance_electro_secondary_ammo is "2" ["2"] custom cvar
^7g_balance_electro_secondary_animtime is "0.3" ["0.3"] custom cvar
^7g_balance_electro_secondary_damage is "60" ["60"] custom cvar
^7g_balance_electro_secondary_edgedamage is "0" ["0"] custom cvar
^7g_balance_electro_secondary_force is "200" ["200"] custom cvar
^7g_balance_electro_secondary_health is "5" ["5"] custom cvar
^7g_balance_electro_secondary_lifetime is "5" ["5"] custom cvar
^7g_balance_electro_secondary_radius is "150" ["150"] custom cvar
^7g_balance_electro_secondary_refire is "0.3" ["0.3"] custom cvar
^7g_balance_electro_secondary_speed is "900" ["900"] custom cvar
^7g_balance_electro_secondary_speed_up is "200" ["200"] custom cvar
^7g_balance_electro_secondary_spread is "0.05" ["0.05"] custom cvar
^7g_balance_falldamage_deadminspeed is "150" ["150"] custom cvar
^7g_balance_falldamage_factor is "0.15" ["0.15"] custom cvar
^7g_balance_falldamage_maxdamage is "25" ["25"] custom cvar
^7g_balance_falldamage_minspeed is "1400" ["1400"] custom cvar
^7g_balance_grapplehook_airfriction is "0.2" ["0.2"] custom cvar
^7g_balance_grapplehook_force_rubber is "2000" ["2000"] custom cvar
^7g_balance_grapplehook_force_rubber_overstretch is "1000" ["1000"] custom cvar
^7g_balance_grapplehook_health is "130" ["130"] custom cvar
^7g_balance_grapplehook_length_min is "50" ["50"] custom cvar
^7g_balance_grapplehook_speed_fly is "1800" ["1800"] custom cvar
^7g_balance_grapplehook_speed_pull is "2000" ["2000"] custom cvar
^7g_balance_grapplehook_stretch is "50" ["50"] custom cvar
^7g_balance_grenadelauncher_primary_ammo is "2" ["2"] custom cvar
^7g_balance_grenadelauncher_primary_animtime is "0.3" ["0.3"] custom cvar
^7g_balance_grenadelauncher_primary_damage is "65" ["65"] custom cvar
^7g_balance_grenadelauncher_primary_edgedamage is "35" ["35"] custom cvar
^7g_balance_grenadelauncher_primary_force is "400" ["400"] custom cvar
^7g_balance_grenadelauncher_primary_lifetime is "30" ["30"] custom cvar
^7g_balance_grenadelauncher_primary_radius is "140" ["140"] custom cvar
^7g_balance_grenadelauncher_primary_refire is "0.7" ["0.7"] custom cvar
^7g_balance_grenadelauncher_primary_speed is "2000" ["2000"] custom cvar
^7g_balance_grenadelauncher_primary_speed_up is "200" ["200"] custom cvar
^7g_balance_grenadelauncher_secondary_ammo is "2" ["2"] custom cvar
^7g_balance_grenadelauncher_secondary_animtime is "0.3" ["0.3"] custom cvar
^7g_balance_grenadelauncher_secondary_damage is "65" ["65"] custom cvar
^7g_balance_grenadelauncher_secondary_edgedamage is "35" ["35"] custom cvar
^7g_balance_grenadelauncher_secondary_force is "400" ["400"] custom cvar
^7g_balance_grenadelauncher_secondary_health is "10" ["10"] custom cvar
^7g_balance_grenadelauncher_secondary_lifetime is "2.5" ["2.5"] custom cvar
^7g_balance_grenadelauncher_secondary_radius is "140" ["140"] custom cvar
^7g_balance_grenadelauncher_secondary_refire is "0.6" ["0.6"] custom cvar
^7g_balance_grenadelauncher_secondary_speed is "1400" ["1400"] custom cvar
^7g_balance_grenadelauncher_secondary_speed_up is "200" ["200"] custom cvar
^7g_balance_hagar_primary_ammo is "1" ["1"] custom cvar
^7g_balance_hagar_primary_damage is "40" ["40"] custom cvar
^7g_balance_hagar_primary_edgedamage is "15" ["15"] custom cvar
^7g_balance_hagar_primary_force is "100" ["100"] custom cvar
^7g_balance_hagar_primary_lifetime is "30" ["30"] custom cvar
^7g_balance_hagar_primary_radius is "70" ["70"] custom cvar
^7g_balance_hagar_primary_refire is "0.15" ["0.15"] custom cvar
^7g_balance_hagar_primary_speed is "3000" ["3000"] custom cvar
^7g_balance_hagar_primary_spread is "0.010" ["0.010"] custom cvar
^7g_balance_hagar_secondary_ammo is "1" ["1"] custom cvar
^7g_balance_hagar_secondary_damage is "40" ["40"] custom cvar
^7g_balance_hagar_secondary_edgedamage is "15" ["15"] custom cvar
^7g_balance_hagar_secondary_force is "100" ["100"] custom cvar
^7g_balance_hagar_secondary_lifetime is "30" ["30"] custom cvar
^7g_balance_hagar_secondary_radius is "70" ["70"] custom cvar
^7g_balance_hagar_secondary_refire is "0.15" ["0.15"] custom cvar
^7g_balance_hagar_secondary_speed is "1400" ["1400"] custom cvar
^7g_balance_hagar_secondary_spread is "0.015" ["0.015"] custom cvar
^7g_balance_health_limit is "999" ["999"] custom cvar
^7g_balance_health_regen is "0.1" ["0.1"] custom cvar
^7g_balance_health_regenlinear is "0" ["0"] custom cvar
^7g_balance_health_rot is "0.1" ["0.1"] custom cvar
^7g_balance_health_rotlinear is "0" ["0"] custom cvar
^7g_balance_health_stable is "100" ["100"] custom cvar
^7g_balance_health_start is "150" ["150"] custom cvar
^7g_balance_hlac_primary_ammo is "1" ["1"] custom cvar
^7g_balance_hlac_primary_animtime is "0.1" ["0.1"] custom cvar
^7g_balance_hlac_primary_damage is "25" ["25"] custom cvar
^7g_balance_hlac_primary_edgedamage is "10" ["10"] custom cvar
^7g_balance_hlac_primary_force is "100" ["100"] custom cvar
^7g_balance_hlac_primary_lifetime is "5" ["5"] custom cvar
^7g_balance_hlac_primary_radius is "70" ["70"] custom cvar
^7g_balance_hlac_primary_refire is "0.1" ["0.1"] custom cvar
^7g_balance_hlac_primary_speed is "9000" ["9000"] custom cvar
^7g_balance_hlac_primary_spread_add is "0.0045" ["0.0045"] custom cvar
^7g_balance_hlac_primary_spread_crouchmod is "0.25" ["0.25"] custom cvar
^7g_balance_hlac_primary_spread_max is "0.25" ["0.25"] custom cvar
^7g_balance_hlac_primary_spread_min is "0.01" ["0.01"] custom cvar
^7g_balance_hlac_secondary_ammo is "10" ["10"] custom cvar
^7g_balance_hlac_secondary_animtime is "0.3" ["0.3"] custom cvar
^7g_balance_hlac_secondary_damage is "25" ["25"] custom cvar
^7g_balance_hlac_secondary_edgedamage is "10" ["10"] custom cvar
^7g_balance_hlac_secondary_force is "100" ["100"] custom cvar
^7g_balance_hlac_secondary_lifetime is "5" ["5"] custom cvar
^7g_balance_hlac_secondary_radius is "70" ["70"] custom cvar
^7g_balance_hlac_secondary_refire is "1" ["1"] custom cvar
^7g_balance_hlac_secondary_shots is "6" ["6"] custom cvar
^7g_balance_hlac_secondary_speed is "9000" ["9000"] custom cvar
^7g_balance_hlac_secondary_spread is "0.15" ["0.15"] custom cvar
^7g_balance_hlac_secondary_spread_crouchmod is "0.5" ["0.5"] custom cvar
^7g_balance_hook_primary_ammo is "0" ["0"] custom cvar
^7g_balance_hook_primary_animtime is "0.3" ["0.3"] custom cvar
^7g_balance_hook_primary_refire is "0" ["0"] custom cvar
^7g_balance_hook_secondary_ammo is "25" ["25"] custom cvar
^7g_balance_hook_secondary_animtime is "0.3" ["0.3"] custom cvar
^7g_balance_hook_secondary_damage is "25" ["25"] custom cvar
^7g_balance_hook_secondary_duration is "1.5" ["1.5"] custom cvar
^7g_balance_hook_secondary_edgedamage is "5" ["5"] custom cvar
^7g_balance_hook_secondary_force is "-2000" ["-2000"] custom cvar
^7g_balance_hook_secondary_gravity is "5" ["5"] custom cvar
^7g_balance_hook_secondary_lifetime is "30" ["30"] custom cvar
^7g_balance_hook_secondary_power is "3" ["3"] custom cvar
^7g_balance_hook_secondary_radius is "500" ["500"] custom cvar
^7g_balance_hook_secondary_refire is "3" ["3"] custom cvar
^7g_balance_hook_secondary_speed is "0" ["0"] custom cvar
^7g_balance_keyhunt_damageforcescale is "1" ["1"] custom cvar
^7g_balance_keyhunt_delay_collect is "1.5" ["1.5"] custom cvar
^7g_balance_keyhunt_delay_drop is "0.4" ["0.4"] custom cvar
^7g_balance_keyhunt_delay_fadeout is "2" ["2"] custom cvar
^7g_balance_keyhunt_delay_return is "60" ["60"] custom cvar
^7g_balance_keyhunt_delay_round is "5" ["5"] custom cvar
^7g_balance_keyhunt_delay_tracking is "10" ["10"] custom cvar
^7g_balance_keyhunt_dropvelocity is "300" ["300"] custom cvar
^7g_balance_keyhunt_maxdist is "150" ["150"] custom cvar
^7g_balance_keyhunt_protecttime is "0.8" ["0.8"] custom cvar
^7g_balance_keyhunt_score_capture is "100" ["100"] custom cvar
^7g_balance_keyhunt_score_carrierfrag is "2" ["2"] custom cvar
^7g_balance_keyhunt_score_collect is "3" ["3"] custom cvar
^7g_balance_keyhunt_score_destroyed is "50" ["50"] custom cvar
^7g_balance_keyhunt_score_destroyed_ownfactor is "1" ["1"] custom cvar
^7g_balance_keyhunt_score_push is "60" ["60"] custom cvar
^7g_balance_keyhunt_throwvelocity is "400" ["400"] custom cvar
^7g_balance_kill_delay is "5" ["5"] custom cvar
^7g_balance_laser_primary_animtime is "0.3" ["0.3"] custom cvar
^7g_balance_laser_primary_damage is "35" ["35"] custom cvar
^7g_balance_laser_primary_edgedamage is "10" ["10"] custom cvar
^7g_balance_laser_primary_force is "400" ["400"] custom cvar
^7g_balance_laser_primary_lifetime is "30" ["30"] custom cvar
^7g_balance_laser_primary_radius is "70" ["70"] custom cvar
^7g_balance_laser_primary_refire is "0.7" ["0.7"] custom cvar
^7g_balance_laser_primary_speed is "9000" ["9000"] custom cvar
^7g_balance_laser_secondary is "0" ["0"] custom cvar
^7g_balance_laser_secondary_animtime is "0.3" ["0.3"] custom cvar
^7g_balance_laser_secondary_damage is "35" ["35"] custom cvar
^7g_balance_laser_secondary_edgedamage is "10" ["10"] custom cvar
^7g_balance_laser_secondary_force is "400" ["400"] custom cvar
^7g_balance_laser_secondary_lifetime is "30" ["30"] custom cvar
^7g_balance_laser_secondary_radius is "70" ["70"] custom cvar
^7g_balance_laser_secondary_refire is "0.7" ["0.7"] custom cvar
^7g_balance_laser_secondary_speed is "9000" ["9000"] custom cvar
^7g_balance_minstanex_ammo is "10" ["10"] custom cvar
^7g_balance_minstanex_animtime is "0.3" ["0.3"] custom cvar
^7g_balance_minstanex_refire is "1" ["1"] custom cvar
^7g_balance_nex_ammo is "5" ["5"] custom cvar
^7g_balance_nex_animtime is "0.3" ["0.3"] custom cvar
^7g_balance_nex_damage is "140" ["140"] custom cvar
^7g_balance_nex_force is "600" ["600"] custom cvar
^7g_balance_nex_refire is "1.5" ["1.5"] custom cvar
^7g_balance_nixnex_ammo_cells is "15" ["15"] custom cvar
^7g_balance_nixnex_ammo_nails is "45" ["45"] custom cvar
^7g_balance_nixnex_ammo_rockets is "15" ["15"] custom cvar
^7g_balance_nixnex_ammo_shells is "15" ["15"] custom cvar
^7g_balance_nixnex_ammoincr_cells is "2" ["2"] custom cvar
^7g_balance_nixnex_ammoincr_nails is "6" ["6"] custom cvar
^7g_balance_nixnex_ammoincr_rockets is "2" ["2"] custom cvar
^7g_balance_nixnex_ammoincr_shells is "2" ["2"] custom cvar
^7g_balance_nixnex_incrtime is "1.6" ["1.6"] custom cvar
^7g_balance_nixnex_roundtime is "25" ["25"] custom cvar
^7g_balance_pause_armor_rot is "5" ["5"] custom cvar
^7g_balance_pause_armor_rot_spawn is "10" ["10"] custom cvar
^7g_balance_pause_health_regen is "5" ["5"] custom cvar
^7g_balance_pause_health_regen_spawn is "0" ["0"] custom cvar
^7g_balance_pause_health_rot is "5" ["5"] custom cvar
^7g_balance_pause_health_rot_spawn is "10" ["10"] custom cvar
^7g_balance_portal_health is "200" ["200"] custom cvar
^7g_balance_portal_lifetime is "15" ["15"] custom cvar
^7g_balance_porto_primary_ammo is "25" ["25"] custom cvar
^7g_balance_porto_primary_lifetime is "30" ["30"] custom cvar
^7g_balance_porto_primary_refire is "1.5" ["1.5"] custom cvar
^7g_balance_porto_primary_speed is "2000" ["2000"] custom cvar
^7g_balance_powerup_invincible_takedamage is "0.2" ["0.2"] custom cvar
^7g_balance_powerup_invincible_time is "30" ["30"] custom cvar
^7g_balance_powerup_strength_damage is "3" ["3"] custom cvar
^7g_balance_powerup_strength_force is "4" ["4"] custom cvar
^7g_balance_powerup_strength_selfdamage is "1.5" ["1.5"] custom cvar
^7g_balance_powerup_strength_selfforce is "1.5" ["1.5"] custom cvar
^7g_balance_powerup_strength_time is "30" ["30"] custom cvar
^7g_balance_rocketlauncher_ammo is "3" ["3"] custom cvar
^7g_balance_rocketlauncher_animtime is "0.3" ["0.3"] custom cvar
^7g_balance_rocketlauncher_damage is "130" ["130"] custom cvar
^7g_balance_rocketlauncher_detonatedelay is "0.2" ["0.2"] custom cvar
^7g_balance_rocketlauncher_edgedamage is "50" ["50"] custom cvar
^7g_balance_rocketlauncher_force is "600" ["600"] custom cvar
^7g_balance_rocketlauncher_health is "30" ["30"] custom cvar
^7g_balance_rocketlauncher_laserguided_allow_steal is "1" ["1"] custom cvar
^7g_balance_rocketlauncher_laserguided_speed is "1000" ["1000"] custom cvar
^7g_balance_rocketlauncher_laserguided_speedaccel is "0" ["0"] custom cvar
^7g_balance_rocketlauncher_laserguided_speedstart is "1000" ["1000"] custom cvar
^7g_balance_rocketlauncher_laserguided_turnrate is "0.75" ["0.75"] custom cvar
^7g_balance_rocketlauncher_lifetime is "30" ["30"] custom cvar
^7g_balance_rocketlauncher_radius is "170" ["170"] custom cvar
^7g_balance_rocketlauncher_refire is "1" ["1"] custom cvar
^7g_balance_rocketlauncher_speed is "850" ["850"] custom cvar
^7g_balance_rocketlauncher_speedaccel is "0" ["0"] custom cvar
^7g_balance_rocketlauncher_speedstart is "850" ["850"] custom cvar
^7g_balance_rune_defense_combo_takedamage is "1.0" ["1.0"] custom cvar
^7g_balance_rune_defense_takedamage is "0.5" ["0.5"] custom cvar
^7g_balance_rune_regen_combo_hpmod is "0.9" ["0.9"] custom cvar
^7g_balance_rune_regen_combo_limitmod is "1" ["1"] custom cvar
^7g_balance_rune_regen_combo_regenrate is "0.5" ["0.5"] custom cvar
^7g_balance_rune_regen_combo_rotrate is "1.5" ["1.5"] custom cvar
^7g_balance_rune_regen_hpmod is "1.75" ["1.75"] custom cvar
^7g_balance_rune_regen_limitmod is "1" ["1"] custom cvar
^7g_balance_rune_regen_regenrate is "3.0" ["3.0"] custom cvar
^7g_balance_rune_speed_atkrate is "0.66" ["0.66"] custom cvar
^7g_balance_rune_speed_combo_atkrate is "1.2" ["1.2"] custom cvar
^7g_balance_rune_speed_combo_jumpheight is "1.0" ["1.0"] custom cvar
^7g_balance_rune_speed_combo_moverate is "0.9" ["0.9"] custom cvar
^7g_balance_rune_speed_jumpheight is "1.4" ["1.4"] custom cvar
^7g_balance_rune_speed_moverate is "1.25" ["1.25"] custom cvar
^7g_balance_rune_strength_combo_damage is "0.9" ["0.9"] custom cvar
^7g_balance_rune_strength_combo_force is "1.0" ["1.0"] custom cvar
^7g_balance_rune_strength_damage is "2.0" ["2.0"] custom cvar
^7g_balance_rune_strength_force is "1.5" ["1.5"] custom cvar
^7g_balance_rune_vampire_absorb is "0.4" ["0.4"] custom cvar
^7g_balance_rune_vampire_combo_absorb is "-0.1" ["-0.1"] custom cvar
^7g_balance_rune_vampire_combo_minhealth is "40" ["40"] custom cvar
^7g_balance_rune_vampire_maxhealth is "500" ["500"] custom cvar
^7g_balance_seeker_flac_ammo is "0.5" ["0.5"] custom cvar
^7g_balance_seeker_flac_animtime is "0.1" ["0.1"] custom cvar
^7g_balance_seeker_flac_damage is "15" ["15"] custom cvar
^7g_balance_seeker_flac_edgedamage is "10" ["10"] custom cvar
^7g_balance_seeker_flac_force is "50" ["50"] custom cvar
^7g_balance_seeker_flac_lifetime is "0.1" ["0.1"] custom cvar
^7g_balance_seeker_flac_lifetime_rand is "0.05" ["0.05"] custom cvar
^7g_balance_seeker_flac_radius is "100" ["100"] custom cvar
^7g_balance_seeker_flac_refire is "0.1" ["0.1"] custom cvar
^7g_balance_seeker_flac_speed is "3000" ["3000"] custom cvar
^7g_balance_seeker_flac_spread is "0.4" ["0.4"] custom cvar
^7g_balance_seeker_missile_accel is "1.05" ["1.05"] custom cvar
^7g_balance_seeker_missile_activate_delay is "0.1" ["0.1"] custom cvar
^7g_balance_seeker_missile_ammo is "2" ["2"] custom cvar
^7g_balance_seeker_missile_animtime is "0.25" ["0.25"] custom cvar
^7g_balance_seeker_missile_count is "4" ["4"] custom cvar
^7g_balance_seeker_missile_damage is "40" ["40"] custom cvar
^7g_balance_seeker_missile_decel is "0.9" ["0.9"] custom cvar
^7g_balance_seeker_missile_delay is "0.25" ["0.25"] custom cvar
^7g_balance_seeker_missile_edgedamage is "10" ["10"] custom cvar
^7g_balance_seeker_missile_force is "250" ["250"] custom cvar
^7g_balance_seeker_missile_lifetime is "15" ["15"] custom cvar
^7g_balance_seeker_missile_proxy is "0" ["0"] custom cvar
^7g_balance_seeker_missile_proxy_delay is "0.2" ["0.2"] custom cvar
^7g_balance_seeker_missile_proxy_maxrange is "45" ["45"] custom cvar
^7g_balance_seeker_missile_radius is "80" ["80"] custom cvar
^7g_balance_seeker_missile_refire is "0.5" ["0.5"] custom cvar
^7g_balance_seeker_missile_smart is "1" ["1"] custom cvar
^7g_balance_seeker_missile_smart_mindist is "800" ["800"] custom cvar
^7g_balance_seeker_missile_smart_trace_max is "2500" ["2500"] custom cvar
^7g_balance_seeker_missile_smart_trace_min is "1000" ["1000"] custom cvar
^7g_balance_seeker_missile_speed is "700" ["700"] custom cvar
^7g_balance_seeker_missile_speed_max is "1250" ["1250"] custom cvar
^7g_balance_seeker_missile_turnrate is "0.65" ["0.65"] custom cvar
^7g_balance_seeker_tag_ammo is "1" ["1"] custom cvar
^7g_balance_seeker_tag_animtime is "0.1" ["0.1"] custom cvar
^7g_balance_seeker_tag_refire is "0.7" ["0.7"] custom cvar
^7g_balance_seeker_tag_speed is "9000" ["9000"] custom cvar
^7g_balance_selfdamagepercent is "0.6" ["0.6"] custom cvar
^7g_balance_shotgun_primary_ammo is "1" ["1"] custom cvar
^7g_balance_shotgun_primary_animtime is "0.2" ["0.2"] custom cvar
^7g_balance_shotgun_primary_bullets is "5" ["5"] custom cvar
^7g_balance_shotgun_primary_damage is "12" ["12"] custom cvar
^7g_balance_shotgun_primary_force is "60" ["60"] custom cvar
^7g_balance_shotgun_primary_refire is "0.5" ["0.5"] custom cvar
^7g_balance_shotgun_primary_spread is "0.08" ["0.08"] custom cvar
^7g_balance_shotgun_secondary_ammo is "1" ["1"] custom cvar
^7g_balance_shotgun_secondary_animtime is "0.2" ["0.2"] custom cvar
^7g_balance_shotgun_secondary_bullets is "5" ["5"] custom cvar
^7g_balance_shotgun_secondary_damage is "12" ["12"] custom cvar
^7g_balance_shotgun_secondary_force is "60" ["60"] custom cvar
^7g_balance_shotgun_secondary_refire is "1.35" ["1.35"] custom cvar
^7g_balance_shotgun_secondary_spread is "0.12" ["0.12"] custom cvar
^7g_balance_teams is "0" ["0"] custom cvar
^7g_balance_teams_complain is "0" ["0"] custom cvar
^7g_balance_teams_force is "0" ["0"] custom cvar
^7g_balance_teams_prevent_imbalance is "0" ["0"] custom cvar
^7g_balance_uzi_first_ammo is "1" ["1"] custom cvar
^7g_balance_uzi_first_damage is "30" ["30"] custom cvar
^7g_balance_uzi_first_force is "50" ["50"] custom cvar
^7g_balance_uzi_first_refire is "0.2" ["0.2"] custom cvar
^7g_balance_uzi_first_spread is "0.01" ["0.01"] custom cvar
^7g_balance_uzi_sustained_ammo is "1" ["1"] custom cvar
^7g_balance_uzi_sustained_damage is "16" ["16"] custom cvar
^7g_balance_uzi_sustained_force is "27" ["27"] custom cvar
^7g_balance_uzi_sustained_refire is "0.1" ["0.1"] custom cvar
^7g_balance_uzi_sustained_spread is "0.05" ["0.05"] custom cvar
^7g_balance_weaponswitchdelay is "0.15" ["0.15"] custom cvar
^7g_ban_default_bantime is "5400" ["5400"] custom cvar
^7g_ban_default_masksize is "3" ["3"] custom cvar
^7g_ban_sync_interval is "5" ["5"] custom cvar
^7g_ban_sync_trusted_servers is "" [""] custom cvar
^7g_ban_sync_uri is "" [""] custom cvar
^7g_banned_list is "" [""] custom cvar
^7g_bugrigs is "0" ["0"] custom cvar
^7g_bugrigs_accel is "800" ["800"] custom cvar
^7g_bugrigs_air_steering is "1" ["1"] custom cvar
^7g_bugrigs_angle_smoothing is "5" ["5"] custom cvar
^7g_bugrigs_friction_air is "0.00001" ["0.00001"] custom cvar
^7g_bugrigs_friction_brake is "950" ["950"] custom cvar
^7g_bugrigs_friction_floor is "50" ["50"] custom cvar
^7g_bugrigs_planar_movement is "1" ["1"] custom cvar
^7g_bugrigs_planar_movement_car_jumping is "1" ["1"] custom cvar
^7g_bugrigs_reverse_speeding is "1" ["1"] custom cvar
^7g_bugrigs_reverse_spinning is "1" ["1"] custom cvar
^7g_bugrigs_reverse_stopping is "1" ["1"] custom cvar
^7g_bugrigs_speed_pow is "2" ["2"] custom cvar
^7g_bugrigs_speed_ref is "400" ["400"] custom cvar
^7g_bugrigs_steer is "1" ["1"] custom cvar
^7g_campaign is "0" ["0"] custom cvar
^7g_campaign_index is "0" ["0"] custom cvar
^7g_campaign_name is "" [""] custom cvar
^7g_campaign_skill is "0" ["0"] custom cvar
^7g_casings is "0" ["0"] custom cvar
^7g_changeteam_banned is "0" ["0"] custom cvar
^7g_changeteam_fragtransfer is "0" ["0"] custom cvar
^7g_chat_flood_burst is "2" ["2"] custom cvar
^7g_chat_flood_burst_team is "2" ["2"] custom cvar
^7g_chat_flood_lmax is "2" ["2"] custom cvar
^7g_chat_flood_lmax_team is "2" ["2"] custom cvar
^7g_chat_flood_notify_flooder is "1" ["1"] custom cvar
^7g_chat_flood_spl is "3" ["3"] custom cvar
^7g_chat_flood_spl_team is "1" ["1"] custom cvar
^7g_chat_nospectators is "0" ["0"] custom cvar
^7g_chat_teamcolors is "0" ["0"] custom cvar
^7g_cloaked is "0" ["0"] custom cvar
^7g_configversion is "1" ["0"] custom cvar
^7g_ctf is "0" ["0"] custom cvar
^7g_ctf_allow_drop is "0" ["0"] custom cvar
^7g_ctf_capture_limit is "-1" ["-1"] custom cvar
^7g_ctf_flag_returntime is "30" ["30"] custom cvar
^7g_ctf_flagcarrier_selfdamage is "1" ["1"] custom cvar
^7g_ctf_flagcarrier_selfforce is "1" ["1"] custom cvar
^7g_ctf_flagpenalty_drop is "2" ["2"] custom cvar
^7g_ctf_flagpenalty_returned is "1" ["1"] custom cvar
^7g_ctf_flagpenalty_suicidedrop is "2" ["2"] custom cvar
^7g_ctf_flagscore_capture is "28" ["28"] custom cvar
^7g_ctf_flagscore_kill is "2" ["2"] custom cvar
^7g_ctf_flagscore_pickup_base is "-3" ["-3"] custom cvar
^7g_ctf_flagscore_pickup_dropped_early is "2" ["2"] custom cvar
^7g_ctf_flagscore_pickup_dropped_late is "2" ["2"] custom cvar
^7g_ctf_flagscore_return is "5" ["5"] custom cvar
^7g_ctf_flagscore_return_by_killer is "6" ["6"] custom cvar
^7g_ctf_flagscore_return_rogue is "10" ["10"] custom cvar
^7g_ctf_flagscore_return_rogue_by_killer is "10" ["10"] custom cvar
^7g_ctf_fullbrightflags is "1" ["1"] custom cvar
^7g_ctf_ignore_frags is "0" ["0"] custom cvar
^7g_ctf_personalpenalty_drop is "2" ["2"] custom cvar
^7g_ctf_personalpenalty_returned is "1" ["1"] custom cvar
^7g_ctf_personalpenalty_suicidedrop is "2" ["2"] custom cvar
^7g_ctf_personalscore_capture is "28" ["28"] custom cvar
^7g_ctf_personalscore_kill is "2" ["2"] custom cvar
^7g_ctf_personalscore_pickup_base is "-3" ["-3"] custom cvar
^7g_ctf_personalscore_pickup_dropped_early is "2" ["2"] custom cvar
^7g_ctf_personalscore_pickup_dropped_late is "2" ["2"] custom cvar
^7g_ctf_personalscore_return is "5" ["5"] custom cvar
^7g_ctf_personalscore_return_by_killer is "6" ["6"] custom cvar
^7g_ctf_personalscore_return_rogue is "10" ["10"] custom cvar
^7g_ctf_personalscore_return_rogue_by_killer is "10" ["10"] custom cvar
^7g_ctf_respawn_delay is "0" ["0"] custom cvar
^7g_ctf_respawn_waves is "0" ["0"] custom cvar
^7g_ctf_reverse is "0" ["0"] custom cvar
^7g_ctf_shield_force is "100" ["100"] custom cvar
^7g_ctf_shield_max_ratio is "0" ["0"] custom cvar
^7g_ctf_shield_min_negscore is "20" ["20"] custom cvar
^7g_ctf_win_mode is "0" ["0"] custom cvar
^7g_dm is "1" ["1"] custom cvar
^7g_dm_respawn_delay is "0" ["0"] custom cvar
^7g_dm_respawn_waves is "0" ["0"] custom cvar
^7g_dom_respawn_delay is "0" ["0"] custom cvar
^7g_dom_respawn_waves is "0" ["0"] custom cvar
^7g_domination is "0" ["0"] custom cvar
^7g_domination_default_teams is "2" ["2"] custom cvar
^7g_domination_disable_frags is "0" ["0"] custom cvar
^7g_domination_point_amt is "0" ["0"] custom cvar
^7g_domination_point_capturetime is "0.1" ["0.1"] custom cvar
^7g_domination_point_glow is "0" ["0"] custom cvar
^7g_domination_point_limit is "-1" ["-1"] custom cvar
^7g_domination_point_rate is "0" ["0"] custom cvar
^7g_footsteps is "0" ["0"] custom cvar
^7g_forced_respawn is "0" ["0"] custom cvar
^7g_friendlyfire is "0.0" ["0.0"] custom cvar
^7g_fullbrightitems is "0" ["0"] custom cvar
^7g_fullbrightplayers is "0" ["0"] custom cvar
^7g_grappling_hook is "0" ["0"] custom cvar
^7g_grappling_hook_tarzan is "2" ["2"] custom cvar
^7g_jump_grunt is "0" ["0"] custom cvar
^7g_keyhunt is "0" ["0"] custom cvar
^7g_keyhunt_point_limit is "-1" ["-1"] custom cvar
^7g_keyhunt_teams is "0" ["0"] custom cvar
^7g_keyhunt_teams_override is "0" ["0"] custom cvar
^7g_laserguided_missile is "0" ["0"] custom cvar
^7g_lms is "0" ["0"] custom cvar
^7g_lms_campcheck_damage is "100" ["100"] custom cvar
^7g_lms_campcheck_distance is "1800" ["1800"] custom cvar
^7g_lms_campcheck_interval is "10" ["10"] custom cvar
^7g_lms_campcheck_message is "^1Don't camp!" ["^1Don't camp!"] custom cvar
^7g_lms_join_anytime is "1" ["1"] custom cvar
^7g_lms_last_join is "3" ["3"] custom cvar
^7g_lms_lives_override is "-1" ["-1"] custom cvar
^7g_lms_regenerate is "0" ["0"] custom cvar
^7g_lms_respawn_delay is "0" ["0"] custom cvar
^7g_lms_respawn_waves is "0" ["0"] custom cvar
^7g_lms_start_ammo_cells is "50" ["50"] custom cvar
^7g_lms_start_ammo_nails is "150" ["150"] custom cvar
^7g_lms_start_ammo_rockets is "50" ["50"] custom cvar
^7g_lms_start_ammo_shells is "50" ["50"] custom cvar
^7g_lms_start_armor is "100" ["100"] custom cvar
^7g_lms_start_health is "250" ["250"] custom cvar
^7g_maplist is "aggressor aneurysm basement basementctf bleach bloodprison bloodprisonctf bluesky darkzone dieselpower dismal downer evilspace farewell final_rage reslimed ruiner runningman_1on1remix runningman runningmanctf silvercity skyway slimepit soylent starship stormkeep strength toxic warfare" ["aggressor aneurysm basement basementctf bleach bloodprison bloodprisonctf bluesky darkzone dieselpower dismal downer evilspace farewell final_rage reslimed ruiner runningman_1on1remix runningman runningmanctf silvercity skyway slimepit soylent starship stormkeep strength toxic warfare"] custom cvar
^7g_maplist_allow_hidden is "1" ["1"] custom cvar
^7g_maplist_check_waypoints is "0" ["0"] custom cvar
^7g_maplist_index is "0" ["0"] custom cvar
^7g_maplist_mostrecent is "" [""] custom cvar
^7g_maplist_mostrecent_count is "3" ["3"] custom cvar
^7g_maplist_selectrandom is "0" ["0"] custom cvar
^7g_maplist_shuffle is "1" ["1"] custom cvar
^7g_maplist_textonly is "0" ["0"] custom cvar
^7g_maplist_votable is "5" ["5"] custom cvar
^7g_maplist_votable_abstain is "0" ["0"] custom cvar
^7g_maplist_votable_keeptwotime is "15" ["15"] custom cvar
^7g_maplist_votable_nodetail is "1" ["1"] custom cvar
^7g_maplist_votable_screenshot_dir is "maps" ["maps"] custom cvar
^7g_maplist_votable_suggestions is "2" ["2"] custom cvar
^7g_maplist_votable_suggestions_override_mostrecent is "0" ["0"] custom cvar
^7g_maplist_votable_timeout is "30" ["30"] custom cvar
^7g_maxplayers is "0" ["0"] custom cvar
^7g_maxplayers_spectator_blocktime is "5" ["5"] custom cvar
^7g_maxpushtime is "8.0" ["8.0"] custom cvar
^7g_midair is "0" ["0"] custom cvar
^7g_midair_shieldtime is "0.3" ["0.3"] custom cvar
^7g_minstagib is "0" ["0"] custom cvar
^7g_minstagib_ammo_drop is "5" ["5"] custom cvar
^7g_minstagib_ammo_start is "10" ["10"] custom cvar
^7g_minstagib_extralives is "2" ["2"] custom cvar
^7g_minstagib_invis_alpha is "0.05" ["0.05"] custom cvar
^7g_minstagib_speed_jumpheight is "1.8" ["1.8"] custom cvar
^7g_minstagib_speed_moverate is "1.25" ["1.25"] custom cvar
^7g_mirrordamage is "0.2" ["0.2"] custom cvar
^7g_nexuizversion is "2.4svn" ["2.4svn"] custom cvar
^7g_nixnex is "0" ["0"] custom cvar
^7g_nixnex_with_laser is "0" ["0"] custom cvar
^7g_norecoil is "0" ["0"] custom cvar
^7g_onslaught is "0" ["0"] custom cvar
^7g_onslaught_cp_health is "1000" ["1000"] custom cvar
^7g_onslaught_gen_health is "10000" ["10000"] custom cvar
^7g_pickup_armorlarge is "100" ["100"] custom cvar
^7g_pickup_armorlarge_max is "999" ["999"] custom cvar
^7g_pickup_armormedium is "25" ["25"] custom cvar
^7g_pickup_armormedium_max is "999" ["999"] custom cvar
^7g_pickup_armorsmall is "5" ["5"] custom cvar
^7g_pickup_armorsmall_max is "999" ["999"] custom cvar
^7g_pickup_cells is "25" ["25"] custom cvar
^7g_pickup_cells_max is "999" ["999"] custom cvar
^7g_pickup_healthlarge is "50" ["50"] custom cvar
^7g_pickup_healthlarge_max is "999" ["999"] custom cvar
^7g_pickup_healthmedium is "25" ["25"] custom cvar
^7g_pickup_healthmedium_max is "999" ["999"] custom cvar
^7g_pickup_healthmega is "100" ["100"] custom cvar
^7g_pickup_healthmega_max is "999" ["999"] custom cvar
^7g_pickup_healthsmall is "5" ["5"] custom cvar
^7g_pickup_healthsmall_max is "999" ["999"] custom cvar
^7g_pickup_items is "1" ["1"] custom cvar
^7g_pickup_nails is "120" ["120"] custom cvar
^7g_pickup_nails_max is "999" ["999"] custom cvar
^7g_pickup_respawntime_ammo is "15" ["15"] custom cvar
^7g_pickup_respawntime_long is "30" ["30"] custom cvar
^7g_pickup_respawntime_medium is "20" ["20"] custom cvar
^7g_pickup_respawntime_powerup is "120" ["120"] custom cvar
^7g_pickup_respawntime_short is "15" ["15"] custom cvar
^7g_pickup_respawntime_weapon is "15" ["15"] custom cvar
^7g_pickup_rockets is "15" ["15"] custom cvar
^7g_pickup_rockets_max is "999" ["999"] custom cvar
^7g_pickup_shells is "15" ["15"] custom cvar
^7g_pickup_shells_max is "999" ["999"] custom cvar
^7g_player_alpha is "1" ["1"] custom cvar
^7g_player_brightness is "0" ["0"] custom cvar
^7g_powerup_shield is "1" ["1"] custom cvar
^7g_powerup_strength is "1" ["1"] custom cvar
^7g_powerup_superhealth is "1" ["1"] custom cvar
^7g_projectiles_newton_style is "2" ["2"] custom cvar
^7g_race is "0" ["0"] custom cvar
^7g_race_laps_limit is "-1" ["-1"] custom cvar
^7g_race_qualifying is "2" ["2"] custom cvar
^7g_race_teams is "0" ["0"] custom cvar
^7g_respawn_delay is "2" ["2"] custom cvar
^7g_respawn_mapsettings is "1" ["1"] custom cvar
^7g_respawn_waves is "0" ["0"] custom cvar
^7g_rune_respawn_delay is "0" ["0"] custom cvar
^7g_rune_respawn_waves is "0" ["0"] custom cvar
^7g_runematch is "0" ["0"] custom cvar
^7g_runematch_allow_same is "0" ["0"] custom cvar
^7g_runematch_drop_runes_max is "2" ["2"] custom cvar
^7g_runematch_frags_killed_runeholder is "5" ["5"] custom cvar
^7g_runematch_frags_killedby_runeholder is "4" ["4"] custom cvar
^7g_runematch_frags_norune is "0" ["0"] custom cvar
^7g_runematch_point_limit is "-1" ["-1"] custom cvar
^7g_runematch_pointamt is "1" ["1"] custom cvar
^7g_runematch_pointrate is "5" ["5"] custom cvar
^7g_runematch_respawntime is "15" ["15"] custom cvar
^7g_runematch_rune_alpha is "0.78" ["0.78"] custom cvar
^7g_runematch_rune_color_strength is "1.0" ["1.0"] custom cvar
^7g_runematch_rune_effects is "544" ["544"] custom cvar
^7g_runematch_rune_glow_color is "0" ["0"] custom cvar
^7g_runematch_rune_glow_size is "0" ["0"] custom cvar
^7g_runematch_shuffletime is "30" ["30"] custom cvar
^7g_shocknex is "0" ["0"] custom cvar
^7g_shootfromcenter is "0" ["0"] custom cvar
^7g_shootfromeye is "0" ["0"] custom cvar
^7g_spawn_furthest is "0.5" ["0.5"] custom cvar
^7g_spawnpoints_auto_move_out_of_solid is "0" ["0"] custom cvar
^7g_spawnpoints_autodrop is "0" ["0"] custom cvar
^7g_spawnshieldtime is "0" ["0"] custom cvar
^7g_spawnsound is "1" ["1"] custom cvar
^7g_start_ammo_cells is "0" ["0"] custom cvar
^7g_start_ammo_nails is "0" ["0"] custom cvar
^7g_start_ammo_rockets is "0" ["0"] custom cvar
^7g_start_ammo_shells is "50" ["50"] custom cvar
^7g_start_delay is "15" ["15"] custom cvar
^7g_start_weapon_crylink is "0" ["0"] custom cvar
^7g_start_weapon_electro is "0" ["0"] custom cvar
^7g_start_weapon_grenadelauncher is "0" ["0"] custom cvar
^7g_start_weapon_hagar is "0" ["0"] custom cvar
^7g_start_weapon_hlac is "0" ["0"] custom cvar
^7g_start_weapon_hook is "0" ["0"] custom cvar
^7g_start_weapon_laser is "1" ["1"] custom cvar
^7g_start_weapon_minstanex is "0" ["0"] custom cvar
^7g_start_weapon_nex is "0" ["0"] custom cvar
^7g_start_weapon_porto is "0" ["0"] custom cvar
^7g_start_weapon_rocketlauncher is "0" ["0"] custom cvar
^7g_start_weapon_seeker is "0" ["0"] custom cvar
^7g_start_weapon_shotgun is "1" ["1"] custom cvar
^7g_start_weapon_uzi is "0" ["0"] custom cvar
^7g_tdm is "0" ["0"] custom cvar
^7g_tdm_respawn_delay is "0" ["0"] custom cvar
^7g_tdm_respawn_waves is "0" ["0"] custom cvar
^7g_tdm_teams is "2" ["2"] custom cvar
^7g_throughfloor is "1" ["1"] custom cvar
^7g_touchexplode is "0" ["0"] custom cvar
^7g_touchexplode_damage is "10" ["10"] custom cvar
^7g_touchexplode_edgedamage is "0" ["0"] custom cvar
^7g_touchexplode_force is "150" ["150"] custom cvar
^7g_touchexplode_radius is "50" ["50"] custom cvar
^7g_turrets is "1" ["1"] custom cvar
^7g_turrets_aimidle_delay is "5" ["5"] custom cvar
^7g_turrets_nofire is "0" ["0"] custom cvar
^7g_turrets_reloadcvars is "1" ["1"] custom cvar
^7g_turrets_targetscan_mindelay is "0.1" ["0.1"] custom cvar
^7g_turrets_unit_ewheel_std_aim_firetolerance_angle is "16" ["16"] custom cvar
^7g_turrets_unit_ewheel_std_aim_firetolerance_dist is "200" ["200"] custom cvar
^7g_turrets_unit_ewheel_std_aim_maxpitch is "45" ["45"] custom cvar
^7g_turrets_unit_ewheel_std_aim_maxrot is "20" ["20"] custom cvar
^7g_turrets_unit_ewheel_std_aim_speed is "90" ["90"] custom cvar
^7g_turrets_unit_ewheel_std_ammo is "500" ["500"] custom cvar
^7g_turrets_unit_ewheel_std_ammo_max is "4000" ["4000"] custom cvar
^7g_turrets_unit_ewheel_std_ammo_recharge is "100" ["100"] custom cvar
^7g_turrets_unit_ewheel_std_health is "200" ["200"] custom cvar
^7g_turrets_unit_ewheel_std_respawntime is "30" ["30"] custom cvar
^7g_turrets_unit_ewheel_std_shot_dmg is "10" ["10"] custom cvar
^7g_turrets_unit_ewheel_std_shot_force is "20" ["20"] custom cvar
^7g_turrets_unit_ewheel_std_shot_radius is "50" ["50"] custom cvar
^7g_turrets_unit_ewheel_std_shot_refire is "0.15" ["0.15"] custom cvar
^7g_turrets_unit_ewheel_std_shot_speed is "7000" ["7000"] custom cvar
^7g_turrets_unit_ewheel_std_shot_spread is "0.025" ["0.025"] custom cvar
^7g_turrets_unit_ewheel_std_shot_volly is "2" ["2"] custom cvar
^7g_turrets_unit_ewheel_std_shot_volly_refire is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_ewheel_std_target_range is "6000" ["6000"] custom cvar
^7g_turrets_unit_ewheel_std_target_range_fire is "4000" ["4000"] custom cvar
^7g_turrets_unit_ewheel_std_target_range_min is "50" ["50"] custom cvar
^7g_turrets_unit_ewheel_std_target_range_optimal is "1000" ["1000"] custom cvar
^7g_turrets_unit_ewheel_std_target_select_anglebias is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_ewheel_std_target_select_missilebias is "0" ["0"] custom cvar
^7g_turrets_unit_ewheel_std_target_select_playerbias is "1" ["1"] custom cvar
^7g_turrets_unit_ewheel_std_target_select_rangebias is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_ewheel_std_target_select_samebias is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_ewheel_std_track_type is "1" ["1"] custom cvar
^7g_turrets_unit_ewheel_turnrate is "180" ["180"] custom cvar
^7g_turrets_unit_flac_std_aim_firetolerance_angle is "5" ["5"] custom cvar
^7g_turrets_unit_flac_std_aim_firetolerance_dist is "200" ["200"] custom cvar
^7g_turrets_unit_flac_std_aim_maxpitch is "35" ["35"] custom cvar
^7g_turrets_unit_flac_std_aim_maxrot is "360" ["360"] custom cvar
^7g_turrets_unit_flac_std_aim_speed is "100" ["100"] custom cvar
^7g_turrets_unit_flac_std_ammo is "500" ["500"] custom cvar
^7g_turrets_unit_flac_std_ammo_max is "1000" ["1000"] custom cvar
^7g_turrets_unit_flac_std_ammo_recharge is "100" ["100"] custom cvar
^7g_turrets_unit_flac_std_health is "700" ["700"] custom cvar
^7g_turrets_unit_flac_std_respawntime is "90" ["90"] custom cvar
^7g_turrets_unit_flac_std_shot_dmg is "35" ["35"] custom cvar
^7g_turrets_unit_flac_std_shot_force is "50" ["50"] custom cvar
^7g_turrets_unit_flac_std_shot_radius is "250" ["250"] custom cvar
^7g_turrets_unit_flac_std_shot_refire is "0.1" ["0.1"] custom cvar
^7g_turrets_unit_flac_std_shot_speed is "6000" ["6000"] custom cvar
^7g_turrets_unit_flac_std_shot_spread is "0.07" ["0.07"] custom cvar
^7g_turrets_unit_flac_std_shot_volly is "4" ["4"] custom cvar
^7g_turrets_unit_flac_std_shot_volly_refire is "1.5" ["1.5"] custom cvar
^7g_turrets_unit_flac_std_target_range is "4000" ["4000"] custom cvar
^7g_turrets_unit_flac_std_target_range_fire is "3500" ["3500"] custom cvar
^7g_turrets_unit_flac_std_target_range_min is "500" ["500"] custom cvar
^7g_turrets_unit_flac_std_target_range_optimal is "1000" ["1000"] custom cvar
^7g_turrets_unit_flac_std_target_select_anglebias is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_flac_std_target_select_missilebias is "1" ["1"] custom cvar
^7g_turrets_unit_flac_std_target_select_playerbias is "0" ["0"] custom cvar
^7g_turrets_unit_flac_std_target_select_rangebias is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_flac_std_target_select_samebias is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_flac_std_track_accel_pitch is "0.45" ["0.45"] custom cvar
^7g_turrets_unit_flac_std_track_accel_rot is "0.65" ["0.65"] custom cvar
^7g_turrets_unit_flac_std_track_blendrate is "0.15" ["0.15"] custom cvar
^7g_turrets_unit_flac_std_track_type is "3" ["3"] custom cvar
^7g_turrets_unit_fusreac_std_ammo is "0" ["0"] custom cvar
^7g_turrets_unit_fusreac_std_ammo_max is "250" ["250"] custom cvar
^7g_turrets_unit_fusreac_std_ammo_recharge is "250" ["250"] custom cvar
^7g_turrets_unit_fusreac_std_health is "700" ["700"] custom cvar
^7g_turrets_unit_fusreac_std_respawntime is "90" ["90"] custom cvar
^7g_turrets_unit_fusreac_std_shot_dmg is "50" ["50"] custom cvar
^7g_turrets_unit_fusreac_std_shot_refire is "0.1" ["0.1"] custom cvar
^7g_turrets_unit_fusreac_std_target_range is "1024" ["1024"] custom cvar
^7g_turrets_unit_fusreac_std_target_range_fire is "1024" ["1024"] custom cvar
^7g_turrets_unit_fusreac_std_target_range_min is "1" ["1"] custom cvar
^7g_turrets_unit_hellion_std_aim_firetolerance_angle is "25" ["25"] custom cvar
^7g_turrets_unit_hellion_std_aim_firetolerance_dist is "200" ["200"] custom cvar
^7g_turrets_unit_hellion_std_aim_maxpitch is "20" ["20"] custom cvar
^7g_turrets_unit_hellion_std_aim_maxrot is "360" ["360"] custom cvar
^7g_turrets_unit_hellion_std_aim_speed is "100" ["100"] custom cvar
^7g_turrets_unit_hellion_std_ammo is "100" ["100"] custom cvar
^7g_turrets_unit_hellion_std_ammo_max is "200" ["200"] custom cvar
^7g_turrets_unit_hellion_std_ammo_recharge is "50" ["50"] custom cvar
^7g_turrets_unit_hellion_std_health is "500" ["500"] custom cvar
^7g_turrets_unit_hellion_std_respawntime is "90" ["90"] custom cvar
^7g_turrets_unit_hellion_std_shot_dmg is "50" ["50"] custom cvar
^7g_turrets_unit_hellion_std_shot_force is "250" ["250"] custom cvar
^7g_turrets_unit_hellion_std_shot_radius is "100" ["100"] custom cvar
^7g_turrets_unit_hellion_std_shot_refire is "0.15" ["0.15"] custom cvar
^7g_turrets_unit_hellion_std_shot_speed is "750" ["750"] custom cvar
^7g_turrets_unit_hellion_std_shot_speed_gain is "1.025" ["1.025"] custom cvar
^7g_turrets_unit_hellion_std_shot_speed_max is "5000" ["5000"] custom cvar
^7g_turrets_unit_hellion_std_shot_spread is "0.08" ["0.08"] custom cvar
^7g_turrets_unit_hellion_std_shot_volly is "2" ["2"] custom cvar
^7g_turrets_unit_hellion_std_shot_volly_refire is "4" ["4"] custom cvar
^7g_turrets_unit_hellion_std_target_range is "6000" ["6000"] custom cvar
^7g_turrets_unit_hellion_std_target_range_fire is "5000" ["5000"] custom cvar
^7g_turrets_unit_hellion_std_target_range_min is "150" ["150"] custom cvar
^7g_turrets_unit_hellion_std_target_range_optimal is "4500" ["4500"] custom cvar
^7g_turrets_unit_hellion_std_target_select_anglebias is "0.01" ["0.01"] custom cvar
^7g_turrets_unit_hellion_std_target_select_missilebias is "0" ["0"] custom cvar
^7g_turrets_unit_hellion_std_target_select_playerbias is "1" ["1"] custom cvar
^7g_turrets_unit_hellion_std_target_select_rangebias is "0.7" ["0.7"] custom cvar
^7g_turrets_unit_hellion_std_target_select_samebias is "0.01" ["0.01"] custom cvar
^7g_turrets_unit_hellion_std_track_accel_pitch is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_hellion_std_track_accel_rot is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_hellion_std_track_blendrate is "0.75" ["0.75"] custom cvar
^7g_turrets_unit_hellion_std_track_type is "3" ["3"] custom cvar
^7g_turrets_unit_hk_std_aim_firetolerance_angle is "25" ["25"] custom cvar
^7g_turrets_unit_hk_std_aim_firetolerance_dist is "250" ["250"] custom cvar
^7g_turrets_unit_hk_std_aim_maxpitch is "20" ["20"] custom cvar
^7g_turrets_unit_hk_std_aim_maxrot is "360" ["360"] custom cvar
^7g_turrets_unit_hk_std_aim_speed is "100" ["100"] custom cvar
^7g_turrets_unit_hk_std_ammo is "120" ["120"] custom cvar
^7g_turrets_unit_hk_std_ammo_max is "240" ["240"] custom cvar
^7g_turrets_unit_hk_std_ammo_recharge is "16" ["16"] custom cvar
^7g_turrets_unit_hk_std_health is "500" ["500"] custom cvar
^7g_turrets_unit_hk_std_respawntime is "90" ["90"] custom cvar
^7g_turrets_unit_hk_std_shot_dmg is "120" ["120"] custom cvar
^7g_turrets_unit_hk_std_shot_force is "600" ["600"] custom cvar
^7g_turrets_unit_hk_std_shot_radius is "200" ["200"] custom cvar
^7g_turrets_unit_hk_std_shot_refire is "5" ["5"] custom cvar
^7g_turrets_unit_hk_std_shot_speed is "500" ["500"] custom cvar
^7g_turrets_unit_hk_std_shot_speed_accel is "1.025" ["1.025"] custom cvar
^7g_turrets_unit_hk_std_shot_speed_accel2 is "1.05" ["1.05"] custom cvar
^7g_turrets_unit_hk_std_shot_speed_decel is "0.9" ["0.9"] custom cvar
^7g_turrets_unit_hk_std_shot_speed_max is "1000" ["1000"] custom cvar
^7g_turrets_unit_hk_std_shot_speed_turnrate is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_hk_std_shot_spread is "0" ["0"] custom cvar
^7g_turrets_unit_hk_std_shot_volly is "0" ["0"] custom cvar
^7g_turrets_unit_hk_std_shot_volly_refire is "0" ["0"] custom cvar
^7g_turrets_unit_hk_std_target_range is "6000" ["6000"] custom cvar
^7g_turrets_unit_hk_std_target_range_fire is "5000" ["5000"] custom cvar
^7g_turrets_unit_hk_std_target_range_min is "220" ["220"] custom cvar
^7g_turrets_unit_hk_std_target_range_optimal is "5000" ["5000"] custom cvar
^7g_turrets_unit_hk_std_target_select_anglebias is "0.1" ["0.1"] custom cvar
^7g_turrets_unit_hk_std_target_select_missilebias is "0" ["0"] custom cvar
^7g_turrets_unit_hk_std_target_select_playerbias is "1" ["1"] custom cvar
^7g_turrets_unit_hk_std_target_select_rangebias is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_hk_std_target_select_samebias is "0.01" ["0.01"] custom cvar
^7g_turrets_unit_hk_std_track_accel_pitch is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_hk_std_track_accel_rot is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_hk_std_track_blendrate is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_hk_std_track_type is "3" ["3"] custom cvar
^7g_turrets_unit_machinegun_std_aim_firetolerance_angle is "16" ["16"] custom cvar
^7g_turrets_unit_machinegun_std_aim_firetolerance_dist is "75" ["75"] custom cvar
^7g_turrets_unit_machinegun_std_aim_maxpitch is "25" ["25"] custom cvar
^7g_turrets_unit_machinegun_std_aim_maxrot is "400" ["400"] custom cvar
^7g_turrets_unit_machinegun_std_aim_speed is "100" ["100"] custom cvar
^7g_turrets_unit_machinegun_std_ammo is "200" ["200"] custom cvar
^7g_turrets_unit_machinegun_std_ammo_max is "2000" ["2000"] custom cvar
^7g_turrets_unit_machinegun_std_ammo_recharge is "95" ["95"] custom cvar
^7g_turrets_unit_machinegun_std_health is "256" ["256"] custom cvar
^7g_turrets_unit_machinegun_std_respawntime is "60" ["60"] custom cvar
^7g_turrets_unit_machinegun_std_shot_dmg is "12" ["12"] custom cvar
^7g_turrets_unit_machinegun_std_shot_force is "15" ["15"] custom cvar
^7g_turrets_unit_machinegun_std_shot_radius is "0" ["0"] custom cvar
^7g_turrets_unit_machinegun_std_shot_refire is "0.1" ["0.1"] custom cvar
^7g_turrets_unit_machinegun_std_shot_speed is "0" ["0"] custom cvar
^7g_turrets_unit_machinegun_std_shot_spread is "0.025" ["0.025"] custom cvar
^7g_turrets_unit_machinegun_std_shot_volly is "5" ["5"] custom cvar
^7g_turrets_unit_machinegun_std_shot_volly_refire is "1.5" ["1.5"] custom cvar
^7g_turrets_unit_machinegun_std_target_range is "4500" ["4500"] custom cvar
^7g_turrets_unit_machinegun_std_target_range_fire is "4000" ["4000"] custom cvar
^7g_turrets_unit_machinegun_std_target_range_min is "2" ["2"] custom cvar
^7g_turrets_unit_machinegun_std_target_range_optimal is "2500" ["2500"] custom cvar
^7g_turrets_unit_machinegun_std_target_select_anglebias is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_machinegun_std_target_select_missilebias is "0" ["0"] custom cvar
^7g_turrets_unit_machinegun_std_target_select_playerbias is "1" ["1"] custom cvar
^7g_turrets_unit_machinegun_std_target_select_rangebias is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_machinegun_std_target_select_samebias is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_machinegun_std_track_accel_pitch is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_machinegun_std_track_accel_rot is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_machinegun_std_track_blendrate is "0.2" ["0.2"] custom cvar
^7g_turrets_unit_machinegun_std_track_type is "3" ["3"] custom cvar
^7g_turrets_unit_mlrs_std_aim_firetolerance_angle is "15" ["15"] custom cvar
^7g_turrets_unit_mlrs_std_aim_firetolerance_dist is "300" ["300"] custom cvar
^7g_turrets_unit_mlrs_std_aim_maxpitch is "15" ["15"] custom cvar
^7g_turrets_unit_mlrs_std_aim_maxrot is "360" ["360"] custom cvar
^7g_turrets_unit_mlrs_std_aim_speed is "180" ["180"] custom cvar
^7g_turrets_unit_mlrs_std_ammo is "300" ["300"] custom cvar
^7g_turrets_unit_mlrs_std_ammo_max is "300" ["300"] custom cvar
^7g_turrets_unit_mlrs_std_ammo_recharge is "50" ["50"] custom cvar
^7g_turrets_unit_mlrs_std_health is "500" ["500"] custom cvar
^7g_turrets_unit_mlrs_std_respawntime is "60" ["60"] custom cvar
^7g_turrets_unit_mlrs_std_shot_dmg is "50" ["50"] custom cvar
^7g_turrets_unit_mlrs_std_shot_force is "50" ["50"] custom cvar
^7g_turrets_unit_mlrs_std_shot_radius is "180" ["180"] custom cvar
^7g_turrets_unit_mlrs_std_shot_refire is "0.1" ["0.1"] custom cvar
^7g_turrets_unit_mlrs_std_shot_speed is "2000" ["2000"] custom cvar
^7g_turrets_unit_mlrs_std_shot_spread is "0.05" ["0.05"] custom cvar
^7g_turrets_unit_mlrs_std_shot_volly is "3" ["3"] custom cvar
^7g_turrets_unit_mlrs_std_shot_volly_refire is "1.5" ["1.5"] custom cvar
^7g_turrets_unit_mlrs_std_target_range is "4000" ["4000"] custom cvar
^7g_turrets_unit_mlrs_std_target_range_fire is "3000" ["3000"] custom cvar
^7g_turrets_unit_mlrs_std_target_range_min is "500" ["500"] custom cvar
^7g_turrets_unit_mlrs_std_target_range_optimal is "2000" ["2000"] custom cvar
^7g_turrets_unit_mlrs_std_target_select_anglebias is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_mlrs_std_target_select_missilebias is "0" ["0"] custom cvar
^7g_turrets_unit_mlrs_std_target_select_playerbias is "1" ["1"] custom cvar
^7g_turrets_unit_mlrs_std_target_select_rangebias is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_mlrs_std_target_select_samebias is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_mlrs_std_track_accel_pitch is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_mlrs_std_track_accel_rot is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_mlrs_std_track_blendrate is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_mlrs_std_track_type is "3" ["3"] custom cvar
^7g_turrets_unit_phaser_std_aim_firetolerance_angle is "20" ["20"] custom cvar
^7g_turrets_unit_phaser_std_aim_firetolerance_dist is "100" ["100"] custom cvar
^7g_turrets_unit_phaser_std_aim_maxpitch is "30" ["30"] custom cvar
^7g_turrets_unit_phaser_std_aim_maxrot is "360" ["360"] custom cvar
^7g_turrets_unit_phaser_std_aim_speed is "100" ["100"] custom cvar
^7g_turrets_unit_phaser_std_ammo is "1000" ["1000"] custom cvar
^7g_turrets_unit_phaser_std_ammo_max is "2000" ["2000"] custom cvar
^7g_turrets_unit_phaser_std_ammo_recharge is "100" ["100"] custom cvar
^7g_turrets_unit_phaser_std_health is "500" ["500"] custom cvar
^7g_turrets_unit_phaser_std_respawntime is "90" ["90"] custom cvar
^7g_turrets_unit_phaser_std_shot_dmg is "100" ["100"] custom cvar
^7g_turrets_unit_phaser_std_shot_force is "5" ["5"] custom cvar
^7g_turrets_unit_phaser_std_shot_radius is "8" ["8"] custom cvar
^7g_turrets_unit_phaser_std_shot_refire is "4" ["4"] custom cvar
^7g_turrets_unit_phaser_std_shot_speed is "4" ["4"] custom cvar
^7g_turrets_unit_phaser_std_shot_spread is "0" ["0"] custom cvar
^7g_turrets_unit_phaser_std_shot_volly is "0" ["0"] custom cvar
^7g_turrets_unit_phaser_std_shot_volly_refire is "5" ["5"] custom cvar
^7g_turrets_unit_phaser_std_target_range is "3000" ["3000"] custom cvar
^7g_turrets_unit_phaser_std_target_range_fire is "3000" ["3000"] custom cvar
^7g_turrets_unit_phaser_std_target_range_min is "0" ["0"] custom cvar
^7g_turrets_unit_phaser_std_target_range_optimal is "1500" ["1500"] custom cvar
^7g_turrets_unit_phaser_std_target_select_anglebias is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_phaser_std_target_select_missilebias is "0" ["0"] custom cvar
^7g_turrets_unit_phaser_std_target_select_playerbias is "1" ["1"] custom cvar
^7g_turrets_unit_phaser_std_target_select_rangebias is "0.85" ["0.85"] custom cvar
^7g_turrets_unit_phaser_std_target_select_samebias is "0" ["0"] custom cvar
^7g_turrets_unit_phaser_std_track_accel_pitch is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_phaser_std_track_accel_rot is "0.9" ["0.9"] custom cvar
^7g_turrets_unit_phaser_std_track_blendrate is "0.1" ["0.1"] custom cvar
^7g_turrets_unit_phaser_std_track_type is "3" ["3"] custom cvar
^7g_turrets_unit_plasma_dual_aim_firetolerance_angle is "16" ["16"] custom cvar
^7g_turrets_unit_plasma_dual_aim_firetolerance_dist is "250" ["250"] custom cvar
^7g_turrets_unit_plasma_dual_aim_maxpitch is "30" ["30"] custom cvar
^7g_turrets_unit_plasma_dual_aim_maxrot is "360" ["360"] custom cvar
^7g_turrets_unit_plasma_dual_aim_speed is "100" ["100"] custom cvar
^7g_turrets_unit_plasma_dual_ammo is "500" ["500"] custom cvar
^7g_turrets_unit_plasma_dual_ammo_max is "800" ["800"] custom cvar
^7g_turrets_unit_plasma_dual_ammo_recharge is "40" ["40"] custom cvar
^7g_turrets_unit_plasma_dual_health is "500" ["500"] custom cvar
^7g_turrets_unit_plasma_dual_respawntime is "60" ["60"] custom cvar
^7g_turrets_unit_plasma_dual_shot_dmg is "80" ["80"] custom cvar
^7g_turrets_unit_plasma_dual_shot_force is "100" ["100"] custom cvar
^7g_turrets_unit_plasma_dual_shot_radius is "150" ["150"] custom cvar
^7g_turrets_unit_plasma_dual_shot_refire is "0.1" ["0.1"] custom cvar
^7g_turrets_unit_plasma_dual_shot_speed is "2000" ["2000"] custom cvar
^7g_turrets_unit_plasma_dual_shot_spread is "0.015" ["0.015"] custom cvar
^7g_turrets_unit_plasma_dual_shot_volly is "2" ["2"] custom cvar
^7g_turrets_unit_plasma_dual_shot_volly_refire is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_plasma_dual_target_range is "3000" ["3000"] custom cvar
^7g_turrets_unit_plasma_dual_target_range_fire is "2500" ["2500"] custom cvar
^7g_turrets_unit_plasma_dual_target_range_min is "100" ["100"] custom cvar
^7g_turrets_unit_plasma_dual_target_range_optimal is "2000" ["2000"] custom cvar
^7g_turrets_unit_plasma_dual_target_select_anglebias is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_plasma_dual_target_select_missilebias is "0" ["0"] custom cvar
^7g_turrets_unit_plasma_dual_target_select_playerbias is "1" ["1"] custom cvar
^7g_turrets_unit_plasma_dual_target_select_rangebias is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_plasma_dual_target_select_samebias is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_plasma_dual_track_accel_pitch is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_plasma_dual_track_accel_rot is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_plasma_dual_track_blendrate is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_plasma_dual_track_type is "3" ["3"] custom cvar
^7g_turrets_unit_plasma_std_aim_firetolerance_angle is "5" ["5"] custom cvar
^7g_turrets_unit_plasma_std_aim_firetolerance_dist is "200" ["200"] custom cvar
^7g_turrets_unit_plasma_std_aim_maxpitch is "30" ["30"] custom cvar
^7g_turrets_unit_plasma_std_aim_maxrot is "360" ["360"] custom cvar
^7g_turrets_unit_plasma_std_aim_speed is "180" ["180"] custom cvar
^7g_turrets_unit_plasma_std_ammo is "400" ["400"] custom cvar
^7g_turrets_unit_plasma_std_ammo_max is "800" ["800"] custom cvar
^7g_turrets_unit_plasma_std_ammo_recharge is "40" ["40"] custom cvar
^7g_turrets_unit_plasma_std_health is "500" ["500"] custom cvar
^7g_turrets_unit_plasma_std_respawntime is "60" ["60"] custom cvar
^7g_turrets_unit_plasma_std_shot_dmg is "80" ["80"] custom cvar
^7g_turrets_unit_plasma_std_shot_force is "100" ["100"] custom cvar
^7g_turrets_unit_plasma_std_shot_radius is "150" ["150"] custom cvar
^7g_turrets_unit_plasma_std_shot_refire is "0.6" ["0.6"] custom cvar
^7g_turrets_unit_plasma_std_shot_speed is "2000" ["2000"] custom cvar
^7g_turrets_unit_plasma_std_shot_spread is "0.0001" ["0.0001"] custom cvar
^7g_turrets_unit_plasma_std_shot_volly is "0" ["0"] custom cvar
^7g_turrets_unit_plasma_std_shot_volly_refire is "0" ["0"] custom cvar
^7g_turrets_unit_plasma_std_target_range is "3500" ["3500"] custom cvar
^7g_turrets_unit_plasma_std_target_range_fire is "3000" ["3000"] custom cvar
^7g_turrets_unit_plasma_std_target_range_min is "200" ["200"] custom cvar
^7g_turrets_unit_plasma_std_target_range_optimal is "1500" ["1500"] custom cvar
^7g_turrets_unit_plasma_std_target_select_anglebias is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_plasma_std_target_select_missilebias is "0" ["0"] custom cvar
^7g_turrets_unit_plasma_std_target_select_playerbias is "1" ["1"] custom cvar
^7g_turrets_unit_plasma_std_target_select_rangebias is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_plasma_std_target_select_samebias is "0.01" ["0.01"] custom cvar
^7g_turrets_unit_plasma_std_track_accel_pitch is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_plasma_std_track_accel_rot is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_plasma_std_track_blendrate is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_plasma_std_track_type is "3" ["3"] custom cvar
^7g_turrets_unit_tesla_std_ammo is "2500" ["2500"] custom cvar
^7g_turrets_unit_tesla_std_ammo_max is "5000" ["5000"] custom cvar
^7g_turrets_unit_tesla_std_ammo_recharge is "100" ["100"] custom cvar
^7g_turrets_unit_tesla_std_health is "1000" ["1000"] custom cvar
^7g_turrets_unit_tesla_std_respawntime is "120" ["120"] custom cvar
^7g_turrets_unit_tesla_std_shot_dmg is "100" ["100"] custom cvar
^7g_turrets_unit_tesla_std_shot_force is "400" ["400"] custom cvar
^7g_turrets_unit_tesla_std_shot_refire is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_tesla_std_shot_volly is "1" ["1"] custom cvar
^7g_turrets_unit_tesla_std_shot_volly_refire is "2.5" ["2.5"] custom cvar
^7g_turrets_unit_tesla_std_target_range is "1024" ["1024"] custom cvar
^7g_turrets_unit_tesla_std_target_select_missilebias is "1" ["1"] custom cvar
^7g_turrets_unit_tesla_std_target_select_playerbias is "1" ["1"] custom cvar
^7g_turrets_unit_walker_run_turnrate is "22.5" ["22.5"] custom cvar
^7g_turrets_unit_walker_std_aim_firetolerance_angle is "16" ["16"] custom cvar
^7g_turrets_unit_walker_std_aim_firetolerance_dist is "64" ["64"] custom cvar
^7g_turrets_unit_walker_std_aim_maxpitch is "15" ["15"] custom cvar
^7g_turrets_unit_walker_std_aim_maxrot is "360" ["360"] custom cvar
^7g_turrets_unit_walker_std_aim_speed is "90" ["90"] custom cvar
^7g_turrets_unit_walker_std_ammo is "500" ["500"] custom cvar
^7g_turrets_unit_walker_std_ammo_max is "4000" ["4000"] custom cvar
^7g_turrets_unit_walker_std_ammo_recharge is "100" ["100"] custom cvar
^7g_turrets_unit_walker_std_health is "500" ["500"] custom cvar
^7g_turrets_unit_walker_std_meele_dmg is "500" ["500"] custom cvar
^7g_turrets_unit_walker_std_meele_force is "600" ["600"] custom cvar
^7g_turrets_unit_walker_std_meele_range is "160" ["160"] custom cvar
^7g_turrets_unit_walker_std_respawntime is "60" ["60"] custom cvar
^7g_turrets_unit_walker_std_rocket_dmg is "50" ["50"] custom cvar
^7g_turrets_unit_walker_std_rocket_force is "150" ["150"] custom cvar
^7g_turrets_unit_walker_std_rocket_radius is "150" ["150"] custom cvar
^7g_turrets_unit_walker_std_rocket_refire is "10" ["10"] custom cvar
^7g_turrets_unit_walker_std_rocket_speed is "650" ["650"] custom cvar
^7g_turrets_unit_walker_std_rocket_speed_add is "2" ["2"] custom cvar
^7g_turrets_unit_walker_std_rocket_tunrate is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_walker_std_shot_dmg is "15" ["15"] custom cvar
^7g_turrets_unit_walker_std_shot_force is "5" ["5"] custom cvar
^7g_turrets_unit_walker_std_shot_radius is "0" ["0"] custom cvar
^7g_turrets_unit_walker_std_shot_refire is "0.1" ["0.1"] custom cvar
^7g_turrets_unit_walker_std_shot_speed is "0" ["0"] custom cvar
^7g_turrets_unit_walker_std_shot_spread is "0.05" ["0.05"] custom cvar
^7g_turrets_unit_walker_std_shot_volly is "0" ["0"] custom cvar
^7g_turrets_unit_walker_std_shot_volly_refire is "0" ["0"] custom cvar
^7g_turrets_unit_walker_std_target_range is "10000" ["10000"] custom cvar
^7g_turrets_unit_walker_std_target_range_fire is "1500" ["1500"] custom cvar
^7g_turrets_unit_walker_std_target_range_min is "64" ["64"] custom cvar
^7g_turrets_unit_walker_std_target_range_optimal is "500" ["500"] custom cvar
^7g_turrets_unit_walker_std_target_select_anglebias is "0.5" ["0.5"] custom cvar
^7g_turrets_unit_walker_std_target_select_missilebias is "0" ["0"] custom cvar
^7g_turrets_unit_walker_std_target_select_playerbias is "1" ["1"] custom cvar
^7g_turrets_unit_walker_std_target_select_rangebias is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_walker_std_target_select_samebias is "0.25" ["0.25"] custom cvar
^7g_turrets_unit_walker_std_track_type is "1" ["1"] custom cvar
^7g_turrets_unit_walker_turn_turnrate is "90" ["90"] custom cvar
^7g_turrets_unit_walker_walk_turnrate is "45" ["45"] custom cvar
^7g_use_ammunition is "1" ["1"] custom cvar
^7g_vampire is "0" ["0"] custom cvar
^7g_warmup is "0" ["0"] custom cvar
^7g_warmup_allguns is "0" ["0"] custom cvar
^7g_warmup_allow_timeout is "0" ["0"] custom cvar
^7g_warmup_limit is "60" ["60"] custom cvar
^7g_warmup_start_ammo_cells is "50" ["50"] custom cvar
^7g_warmup_start_ammo_nails is "150" ["150"] custom cvar
^7g_warmup_start_ammo_rockets is "50" ["50"] custom cvar
^7g_warmup_start_ammo_shells is "50" ["50"] custom cvar
^7g_warmup_start_armor is "100" ["100"] custom cvar
^7g_warmup_start_health is "250" ["250"] custom cvar
^7g_waypointeditor is "0" ["0"] custom cvar
^7g_waypoints_for_items is "1" ["1"] custom cvar
^7g_waypointsprite_deadlifetime is "1" ["1"] custom cvar
^7g_waypointsprite_deployed_lifetime is "10" ["10"] custom cvar
^7g_waypointsprite_distancealphaexponent is "2" ["2"] custom cvar
^7g_waypointsprite_limitedrange is "5120" ["5120"] custom cvar
^7g_waypointsprite_minalpha is "0.4" ["0.4"] custom cvar
^7g_waypointsprite_minscale is "1" ["1"] custom cvar
^7g_waypointsprite_normdistance is "512" ["512"] custom cvar
^7g_waypointsprite_scale is "1" ["1"] custom cvar
^7g_waypointsprite_stuffbinds is "0" ["0"] custom cvar
^7g_waypointsprite_timealphaexponent is "1" ["1"] custom cvar
^7g_weapon_stay is "0" ["0"] custom cvar
^7g_weaponarena is "0" ["0"] custom cvar
^7g_weaponreplace_crylink is "" [""] custom cvar
^7g_weaponreplace_electro is "" [""] custom cvar
^7g_weaponreplace_grenadelauncher is "" [""] custom cvar
^7g_weaponreplace_hagar is "" [""] custom cvar
^7g_weaponreplace_hlac is "" [""] custom cvar
^7g_weaponreplace_hook is "" [""] custom cvar
^7g_weaponreplace_laser is "" [""] custom cvar
^7g_weaponreplace_minstanex is "" [""] custom cvar
^7g_weaponreplace_nex is "" [""] custom cvar
^7g_weaponreplace_porto is "" [""] custom cvar
^7g_weaponreplace_rocketlauncher is "" [""] custom cvar
^7g_weaponreplace_seeker is "" [""] custom cvar
^7g_weaponreplace_shotgun is "" [""] custom cvar
^7g_weaponreplace_uzi is "" [""] custom cvar
^7gamecfg is "1" ["1"] unused cvar in quake, can be used by mods
^7gameversion is "20000" ["20000"] version of game data (mod-specific), when client and server gameversion mismatch in the server browser the server is shown as incompatible
^7gl_finish is "$gl_finish" ["$gl_finish"] custom cvar
^7halflifebsp is "0" ["0"] indicates the current map is hlbsp format (useful to know because of different bounding box sizes)
^7host_framerate is "0" ["0"] locks frame timing to this value in seconds, 0.05 is 20fps for example, note that this can easily run too fast, use cl_maxfps if you want to limit your framerate instead, or sys_ticrate to limit server speed
^7host_speeds is "0" ["0"] reports how much time is used in server/graphics/sound
^7hostname is "Nexuiz Server" ["Nexuiz Server"] server message to show in server browser
^7joy_deadzoneforward is "0.05" ["0.05"] custom cvar
^7joy_deadzonepitch is "0.05" ["0.05"] custom cvar
^7joy_deadzoneside is "0.05" ["0.05"] custom cvar
^7joy_deadzoneup is "0.05" ["0.05"] custom cvar
^7joy_deadzoneyaw is "0.05" ["0.05"] custom cvar
^7joy_sensitivitypitch is "0.9" ["0.9"] custom cvar
^7joy_sensitivityyaw is "-1.8" ["-1.8"] custom cvar
^7joyadvanced is "1" ["1"] custom cvar
^7joyadvaxisr is "2" ["2"] custom cvar
^7joyadvaxisx is "3" ["3"] custom cvar
^7joyadvaxisy is "1" ["1"] custom cvar
^7joyadvaxisz is "4" ["4"] custom cvar
^7joypitchsensitivity is "0.9" ["0.9"] custom cvar
^7joysidesensitivity is "1.0" ["1.0"] custom cvar
^7joyyawsensitivity is "-1.8" ["-1.8"] custom cvar
^7lastlevel is "" [""] custom cvar
^7log_dest_udp is "" [""] UDP address to log messages to (in QW rcon compatible format); multiple destinations can be separated by spaces; DO NOT SPECIFY DNS NAMES HERE
^7log_file is "" [""] filename to log messages to
^7menu_cdtrack is "digital-pursuit" ["digital-pursuit"] custom cvar
^7menu_maxplayers is "8" ["8"] custom cvar
^7menu_mouse_absolute is "0" ["0"] custom cvar
^7menu_mouse_speed is "1" ["1"] custom cvar
^7menu_skin is "wickedz" ["wickedz"] custom cvar
^7menu_slist_showempty is "1" ["1"] custom cvar
^7menu_slist_showfull is "1" ["1"] custom cvar
^7menu_slowmo is "1" ["1"] custom cvar
^7menu_use_default_hostname is "1" ["1"] custom cvar
^7menu_weaponarena_with_laser is "0" ["0"] custom cvar
^7minplayers is "0" ["0"] custom cvar
^7mod_alias_supporttagscale is "1" ["1"] support scaling factors in bone/tag attachment matrices as supported by MD3
^7mod_q3bsp_curves_collisions is "1" ["1"] enables collisions with curves (SLOW)
^7mod_q3bsp_debugtracebrush is "0" ["0"] selects different tracebrush bsp recursion algorithms (for debugging purposes only)
^7mod_q3bsp_lightmapmergepower is "3" ["3"] merges the quake3 128x128 lightmap textures into larger lightmap group textures to speed up rendering, 1 = 256x256, 2 = 512x512, 3 = 1024x1024, 4 = 2048x2048, 5 = 4096x4096, ...
^7mod_q3bsp_nolightmaps is "0" ["0"] do not load lightmaps in Q3BSP maps (to save video RAM, but be warned: it looks ugly)
^7mod_q3bsp_optimizedtraceline is "1" ["1"] whether to use optimized traceline code for line traces (as opposed to tracebox code)
^7net_address is "0.0.0.0" ["0.0.0.0"] network address to open ports on
^7net_connectfloodblockingtimeout is "5" ["5"] when a connection packet is received, it will block all future connect packets from that IP address for this many seconds (cuts down on connect floods)
^7net_connecttimeout is "30" ["30"] after requesting a connection, the client must reply within this many seconds or be dropped (cuts down on connect floods)
^7net_messagetimeout is "300" ["300"] drops players who have not sent any packets for this many seconds
^7net_slist_favorites is "" [""] contains a list of IP addresses and ports to always query explicitly
^7net_slist_maxtries is "3" ["3"] how many times to ask the same server for information (more times gives better ping reports but takes longer)
^7net_slist_pause is "0" ["0"] when set to 1, the server list won't update until it is set back to 0
^7net_slist_queriesperframe is "4" ["4"] maximum number of server information requests to send each rendered frame (guards against low framerates causing problems)
^7net_slist_queriespersecond is "20" ["20"] how many server information requests to send per second
^7net_slist_timeout is "4" ["4"] how long to listen for a server information response before giving up
^7nextmap is "" [""] custom cvar
^7noaim is "1" ["1"] QW option to disable vertical autoaim
^7noexit is "0" ["0"] kills anyone attempting to use an exit
^7nomonsters is "0" ["0"] unused cvar in quake, can be used by mods
^7pausable is "0" ["0"] allow players to pause or not
^7port is "26000" ["26000"] server port for players to connect to
^7pr_checkextension is "1" ["1"] indicates to QuakeC that the standard quakec extensions system is available (if 0, quakec should not attempt to use extensions)
^7prvm_backtraceforwarnings is "0" ["0"] print a backtrace for warnings too
^7prvm_errordump is "0" ["0"] write a savegame on crash to crash-server.dmp
^7prvm_leaktest is "0" ["0"] try to detect memory leaks in strings or entities
^7prvm_leaktest_ignore_classnames is "ctf_team dom_team tdm_team" ["ctf_team dom_team tdm_team"] classnames of entities to NOT leak check because they are found by find(world, classname, ...) but are actually spawned by QC code (NOT map entities)
^7prvm_statementprofiling is "0" ["0"] counts how many times each QuakeC statement has been executed, these counts are displayed in prvm_printfunction output (if enabled)
^7prvm_traceqc is "0" ["0"] prints every QuakeC statement as it is executed (only for really thorough debugging!)
^7quit_and_redirect is "" [""] custom cvar
^7quit_when_empty is "0" ["0"] custom cvar
^7r_ambient is "4" ["4"] custom cvar
^7r_fixtrans_auto is "0" ["0"] automatically fixtrans textures (when set to 2, it also saves the fixed versions to a fixtrans directory)
^7r_labelsprites_roundtopixels is "1" ["1"] try to make label sprites sharper by rounding their size to 0.5x or 1x and by rounding their position to whole pixels if possible
^7r_labelsprites_scale is "0.40625" ["0.40625"] global scale to apply to label sprites before conversion to HUD coordinates
^7r_mipskins is "1" ["1"] mipmaps model skins so they render faster in the distance and do not display noise artifacts, can cause discoloration of skins if they contain undesirable border colors
^7r_mipsprites is "1" ["1"] mipmaps sprites so they render faster in the distance and do not display noise artifacts
^7r_nosurftextures is "0" ["0"] pretends there was no texture lump found in the q1bsp/hlbsp loading (useful for debugging this rare case)
^7r_novis is "0" ["0"] draws whole level, see also sv_cullentities_pvs 0
^7r_picmipsprites is "0" ["0"] make gl_picmip affect sprites too (saves some graphics memory in sprite heavy games)
^7r_picmipworld is "0" ["0"] whether gl_picmip shall apply to world textures too
^7r_showsurfaces is "$r_showsurfaces" ["$r_showsurfaces"] custom cvar
^7r_skeletal_debugbone is "-1" ["-1"] development cvar for testing skeletal model code
^7r_skeletal_debugbonecomponent is "3" ["3"] development cvar for testing skeletal model code
^7r_skeletal_debugbonevalue is "100" ["100"] development cvar for testing skeletal model code
^7r_skeletal_debugtranslatex is "1" ["1"] development cvar for testing skeletal model code
^7r_skeletal_debugtranslatey is "1" ["1"] development cvar for testing skeletal model code
^7r_skeletal_debugtranslatez is "1" ["1"] development cvar for testing skeletal model code
^7r_subdivisions_collision_maxtess is "1024" ["1024"] maximum number of subdivisions (prevents curves beyond a certain detail level, limits smoothing)
^7r_subdivisions_collision_maxvertices is "4225" ["4225"] maximum vertices allowed per subdivided curve
^7r_subdivisions_collision_mintess is "1" ["1"] minimum number of subdivisions (values above 1 will smooth curves that don't need it)
^7r_subdivisions_collision_tolerance is "15" ["15"] maximum error tolerance on curve subdivision for collision purposes (usually a larger error tolerance than for rendering)
^7r_subdivisions_maxtess is "3" ["3"] maximum number of subdivisions (prevents curves beyond a certain detail level, limits smoothing)
^7r_subdivisions_maxvertices is "65536" ["65536"] maximum vertices allowed per subdivided curve
^7r_subdivisions_mintess is "3" ["3"] minimum number of subdivisions (values above 1 will smooth curves that don't need it)
^7r_subdivisions_tolerance is "1000000" ["1000000"] maximum error tolerance on curve subdivision for rendering purposes (in other words, the curves will be given as many polygons as necessary to represent curves at this quality)
^7rcon_address is "" [""] server address to send rcon commands to (when not connected to a server)
^7rcon_password is "" [""] password to authenticate rcon commands
^7rcon_restricted_commands is "restart fraglimit chmap gotomap endmatch reducematchtime extendmatchtime allready kick kickban "sv_cmd bans" "sv_cmd unban" status "sv_cmd teamstatus"" ["restart fraglimit chmap gotomap endmatch reducematchtime extendmatchtime allready kick kickban "sv_cmd bans" "sv_cmd unban" status "sv_cmd teamstatus""] allowed commands for rcon when the restricted mode password was used
^7rcon_restricted_password is "" [""] password to authenticate rcon commands in restricted mode
^7registered is "1" ["1"] indicates if this is running registered quake (whether gfx/pop.lmp was found)
^7samelevel is "0" ["0"] repeats same level if level ends (due to timelimit or someone hitting an exit)
^7saved1 is "0" ["0"] unused cvar in quake that is saved to config.cfg on exit, can be used by mods
^7saved2 is "0" ["0"] unused cvar in quake that is saved to config.cfg on exit, can be used by mods
^7saved3 is "0" ["0"] unused cvar in quake that is saved to config.cfg on exit, can be used by mods
^7saved4 is "0" ["0"] unused cvar in quake that is saved to config.cfg on exit, can be used by mods
^7savedgamecfg is "0" ["0"] unused cvar in quake that is saved to config.cfg on exit, can be used by mods
^7sbar_columns is "default" ["default"] custom cvar
^7sbar_fontsize is "11" ["11"] custom cvar
^7sbar_hudselector is "1" ["1"] custom cvar
^7sbar_showbinds is "1" ["1"] custom cvar
^7sbar_showbinds_limit is "2" ["2"] custom cvar
^7sbar_width is "480" ["480"] custom cvar
^7scr_screenshot_name is "nexuiz" ["nexuiz"] prefix name for saved screenshots (changes based on -game commandline, as well as which game mode is running)
^7scratch1 is "0" ["0"] unused cvar in quake, can be used by mods
^7scratch2 is "0" ["0"] unused cvar in quake, can be used by mods
^7scratch3 is "0" ["0"] unused cvar in quake, can be used by mods
^7scratch4 is "0" ["0"] unused cvar in quake, can be used by mods
^7settemp_list is "0" ["0"] custom cvar
^7settemp_var is "_settemp_x" ["_settemp_x"] custom cvar
^7skill is "1" ["1"] difficulty level of game, affects monster layouts in levels, 0 = easy, 1 = normal, 2 = hard, 3 = nightmare (same layout as hard but monsters fire twice)
^7skill_auto is "0" ["0"] custom cvar
^7skin is "" [""] QW player skin name (example: base)
^7slowmo is "1.0" ["1.0"] controls game speed, 0.5 is half speed, 2 is double speed
^7sv_accelerate is "5.5" ["5.5"] rate at which a player accelerates to sv_maxspeed
^7sv_adminnick is "" [""] nick name to use for admin messages instead of host name
^7sv_aim is "2" ["2"] maximum cosine angle for quake's vertical autoaim, a value above 1 completely disables the autoaim, quake used 0.93
^7sv_airaccel_qw is "0.93" ["0.93"] ratio of QW-style air control as opposed to simple acceleration
^7sv_airaccel_sideways_friction is "0.3" ["0.3"] anti-sideways movement stabilization (reduces speed gain when zigzagging)
^7sv_airaccelerate is "5.5" ["5.5"] rate at which a player accelerates to sv_maxairspeed while in the air, if less than 0 the sv_accelerate variable is used instead
^7sv_allow_shownames is "1" ["1"] custom cvar
^7sv_allowdownloads is "1" ["1"] whether to allow clients to download files from the server (does not affect http downloads)
^7sv_allowdownloads_archive is "0" ["0"] whether to allow downloads of archives (pak/pk3)
^7sv_allowdownloads_config is "0" ["0"] whether to allow downloads of config files (cfg)
^7sv_allowdownloads_dlcache is "0" ["0"] whether to allow downloads of dlcache files (dlcache/)
^7sv_allowdownloads_inarchive is "1" ["1"] whether to allow downloads from archives (pak/pk3)
^7sv_areagrid_mingridsize is "64" ["64"] minimum areagrid cell size, smaller values work better for lots of small objects, higher values for large objects
^7sv_autodemo_perclient is "0" ["0"] set to 1 to enable autorecorded per-client demos (they'll start to record at the beginning of a match); set it to 2 to also record client->server packets (for debugging)
^7sv_autodemo_perclient_nameformat is "sv_autodemos/%Y-%m-%d_%H-%M" ["sv_autodemos/%Y-%m-%d_%H-%M"] The format of the sv_autodemo_perclient filename, followed by the map name, the client number and the IP address + port number, separated by underscores
^7sv_autoscreenshot is "0" ["0"] custom cvar
^7sv_cheats is "0" ["0"] enables cheat commands in any game, and cheat impulses in dpmod
^7sv_checkforpacketsduringsleep is "0" ["0"] uses select() function to wait between frames which can be interrupted by packets being received, instead of Sleep()/usleep()/SDL_Sleep() functions which do not check for packets
^7sv_clmovement_enable is "1" ["1"] whether to allow clients to use cl_movement prediction, which can cause choppy movement on the server which may annoy other players
^7sv_clmovement_minping is "0" ["0"] if client ping is below this time in milliseconds, then their ability to use cl_movement prediction is disabled for a while (as they don't need it)
^7sv_clmovement_minping_disabletime is "1000" ["1000"] when client falls below minping, disable their prediction for this many milliseconds (should be at least 1000 or else their prediction may turn on/off frequently)
^7sv_clmovement_waitforinput is "4" ["4"] when a client does not send input for this many frames, force them to move anyway (unlike QuakeWorld)
^7sv_clones is "0" ["0"] custom cvar
^7sv_cullentities_nevercullbmodels is "0" ["0"] if enabled the clients are always notified of moving doors and lifts and other submodels of world (warning: eats a lot of network bandwidth on some levels!)
^7sv_cullentities_pvs is "1" ["1"] fast but loose culling of hidden entities
^7sv_cullentities_stats is "0" ["0"] displays stats on network entities culled by various methods for each client
^7sv_cullentities_trace is "1" ["1"] somewhat slow but very tight culling of hidden entities, minimizes network traffic and makes wallhack cheats useless
^7sv_cullentities_trace_delay is "1" ["1"] number of seconds until the entity gets actually culled
^7sv_cullentities_trace_delay_players is "0.2" ["0.2"] number of seconds until the entity gets actually culled if it is a player entity
^7sv_cullentities_trace_enlarge is "0" ["0"] box enlargement for entity culling
^7sv_cullentities_trace_prediction is "1" ["1"] also trace from the predicted player position
^7sv_cullentities_trace_samples is "1" ["1"] number of samples to test for entity culling
^7sv_cullentities_trace_samples_extra is "2" ["2"] number of samples to test for entity culling when the entity affects its surroundings by e.g. dlight
^7sv_cullentities_trace_samples_players is "8" ["8"] number of samples to test for entity culling when the entity is a player entity
^7sv_curl_defaulturl is "http://www.nexuiz.com/contentdownload/getmap.php?file=" ["http://www.nexuiz.com/contentdownload/getmap.php?file="] default autodownload source URL
^7sv_curl_serverpackages is "" [""] list of required files for the clients, separated by spaces
^7sv_debugmove is "0" ["0"] disables collision detection optimizations for debugging purposes
^7sv_defaultcharacter is "0" ["0"] custom cvar
^7sv_defaultplayercolors is "" [""] custom cvar
^7sv_defaultplayermodel is "models/player/nexus.zym" ["models/player/nexus.zym"] custom cvar
^7sv_defaultplayermodel_blue is "" [""] custom cvar
^7sv_defaultplayermodel_pink is "" [""] custom cvar
^7sv_defaultplayermodel_red is "" [""] custom cvar
^7sv_defaultplayermodel_yellow is "" [""] custom cvar
^7sv_defaultplayerskin is "0" ["0"] custom cvar
^7sv_defaultplayerskin_blue is "0" ["0"] custom cvar
^7sv_defaultplayerskin_pink is "0" ["0"] custom cvar
^7sv_defaultplayerskin_red is "0" ["0"] custom cvar
^7sv_defaultplayerskin_yellow is "0" ["0"] custom cvar
^7sv_doublejump is "0" ["0"] custom cvar
^7sv_echobprint is "1" ["1"] prints gamecode bprint() calls to server console
^7sv_entpatch is "1" ["1"] enables loading of .ent files to override entities in the bsp (for example Threewave CTF server pack contains .ent patch files enabling play of CTF on id1 maps)
^7sv_eventlog is "0" ["0"] custom cvar
^7sv_eventlog_console is "1" ["1"] custom cvar
^7sv_eventlog_files is "0" ["0"] custom cvar
^7sv_eventlog_files_counter is "0" ["0"] custom cvar
^7sv_eventlog_files_nameprefix is "nexuiz" ["nexuiz"] custom cvar
^7sv_eventlog_files_namesuffix is ".log" [".log"] custom cvar
^7sv_eventlog_files_timestamps is "1" ["1"] custom cvar
^7sv_fixedframeratesingleplayer is "1" ["1"] allows you to use server-style timing system in singleplayer (don't run faster than sys_ticrate)
^7sv_foginterval is "0" ["0"] custom cvar
^7sv_freezenonclients is "0" ["0"] freezes time, except for players, allowing you to walk around and take screenshots of explosions
^7sv_friction is "5" ["5"] how fast you slow down
^7sv_friction_on_land is "0" ["0"] custom cvar
^7sv_gameplayfix_blowupfallenzombies is "1" ["1"] causes findradius to detect SOLID_NOT entities such as zombies and corpses on the floor, allowing splash damage to apply to them
^7sv_gameplayfix_delayprojectiles is "1" ["1"] causes entities to not move on the same frame they are spawned, meaning that projectiles wait until the next frame to perform their first move, giving proper interpolation and rocket trails, but making weapons harder to use at low framerates
^7sv_gameplayfix_droptofloorstartsolid is "0" ["0"] prevents items and monsters that start in a solid area from falling out of the level (makes droptofloor treat trace_startsolid as an acceptable outcome)
^7sv_gameplayfix_droptofloorstartsolid_nudgetocorrect is "1" ["1"] tries to nudge stuck items and monsters out of walls before droptofloor is performed
^7sv_gameplayfix_easierwaterjump is "1" ["1"] changes water jumping to make it easier to get out of water (exactly like in QuakeWorld)
^7sv_gameplayfix_findradiusdistancetobox is "1" ["1"] causes findradius to check the distance to the corner of a box rather than the center of the box, makes findradius detect bmodels such as very large doors that would otherwise be unaffected by splash damage
^7sv_gameplayfix_grenadebouncedownslopes is "1" ["1"] prevents MOVETYPE_BOUNCE (grenades) from getting stuck when fired down a downward sloping surface
^7sv_gameplayfix_multiplethinksperframe is "1" ["1"] allows entities to think more often than the server framerate, primarily useful for very high fire rate weapons
^7sv_gameplayfix_noairborncorpse is "1" ["1"] causes entities (corpses) sitting ontop of moving entities (players) to fall when the moving entity (player) is no longer supporting them
^7sv_gameplayfix_setmodelrealbox is "1" ["1"] fixes a bug in Quake that made setmodel always set the entity box to ('-16 -16 -16', '16 16 16') rather than properly checking the model box, breaks some poorly coded mods
^7sv_gameplayfix_stepdown is "0" ["0"] attempts to step down stairs, not just up them (prevents the familiar thud..thud..thud.. when running down stairs and slopes)
^7sv_gameplayfix_stepwhilejumping is "1" ["1"] applies step-up onto a ledge even while airborn, useful if you would otherwise just-miss the floor when running across small areas with gaps (for instance running across the moving platforms in dm2, or jumping to the megahealth and red armor in dm2 rather than using the bridge)
^7sv_gameplayfix_swiminbmodels is "1" ["1"] causes pointcontents (used to determine if you are in a liquid) to check bmodel entities as well as the world model, so you can swim around in (possibly moving) water bmodel entities
^7sv_gameplayfix_upwardvelocityclearsongroundflag is "1" ["1"] prevents monsters, items, and most other objects from being stuck to the floor when pushed around by damage, and other situations in mods
^7sv_gravity is "800" ["800"] how fast you fall (512 = roughly earth gravity)
^7sv_heartbeatperiod is "120" ["120"] how often to send heartbeat in seconds (only used if sv_public is 1)
^7sv_idealpitchscale is "0.8" ["0.8"] how much to look up/down slopes and stairs when not using freelook
^7sv_intermission_cdtrack is "brainsukker" ["brainsukker"] custom cvar
^7sv_jumpstep is "1" ["1"] whether you can step up while jumping (sv_gameplayfix_stepwhilejumping must also be 1)
^7sv_jumpvelocity is "300" ["300"] cvar that can be used by QuakeC code for jump velocity
^7sv_logscores_bots is "0" ["0"] custom cvar
^7sv_logscores_console is "0" ["0"] custom cvar
^7sv_logscores_file is "0" ["0"] custom cvar
^7sv_logscores_filename is "scores.log" ["scores.log"] custom cvar
^7sv_mapchange_delay is "5" ["5"] custom cvar
^7sv_master1 is "" [""] user-chosen master server 1
^7sv_master2 is "" [""] user-chosen master server 2
^7sv_master3 is "" [""] user-chosen master server 3
^7sv_master4 is "" [""] user-chosen master server 4
^7sv_masterextra1 is "ghdigital.com" ["ghdigital.com"] default master server 1 (admin: LordHavoc)
^7sv_masterextra2 is "dpmaster.deathmask.net" ["dpmaster.deathmask.net"] default master server 2 (admin: Willis)
^7sv_masterextra3 is "dpmaster.tchr.no" ["dpmaster.tchr.no"] default master server 3 (admin: tChr)
^7sv_maxairspeed is "220" ["220"] maximum speed a player can accelerate to when airborn (note that it is possible to completely stop by moving the opposite direction)
^7sv_maxidle is "0" ["0"] custom cvar
^7sv_maxidle_spectatorsareidle is "0" ["0"] custom cvar
^7sv_maxrate is "1000000" ["1000000"] upper limit on client rate cvar, should reflect your network connection quality
^7sv_maxspeed is "400" ["400"] maximum speed a player can accelerate to when on ground (can be exceeded by tricks)
^7sv_maxvelocity is "1000000000" ["1000000000"] universal speed limit on all entities
^7sv_motd is "" [""] custom cvar
^7sv_newflymove is "0" ["0"] enables simpler/buggier player physics (not recommended)
^7sv_nostep is "0" ["0"] prevents MOVETYPE_STEP entities (monsters) from moving
^7sv_playerphysicsqc is "1" ["1"] enables QuakeC function to override player physics
^7sv_pogostick is "0" ["0"] custom cvar
^7sv_precacheitems is "0" ["0"] custom cvar
^7sv_precacheplayermodels is "1" ["1"] custom cvar
^7sv_precacheweapons is "0" ["0"] custom cvar
^7sv_progs is "progs.dat" ["progs.dat"] selects which quakec progs.dat file to run
^7sv_protocolname is "DP7" ["DP7"] selects network protocol to host for (values include QUAKE, QUAKEDP, NEHAHRAMOVIE, DP1 and up)
^7sv_public is "1" ["1"] 1: advertises this server on the master server (so that players can find it in the server browser); 0: allow direct queries only; -1: do not respond to direct queries; -2: do not allow anyone to connect
^7sv_q3acompat_machineshotgunswap is "0" ["0"] custom cvar
^7sv_random_seed is "" [""] random seed; when set, on every map start this random seed is used to initialize the random number generator. Don't touch it unless for benchmarking or debugging
^7sv_ratelimitlocalplayer is "0" ["0"] whether to apply rate limiting to the local player in a listen server (only useful for testing)
^7sv_ready_restart is "0" ["0"] custom cvar
^7sv_ready_restart_after_countdown is "0" ["0"] custom cvar
^7sv_ready_restart_repeatable is "0" ["0"] custom cvar
^7sv_servermodelsonly is "1" ["1"] custom cvar
^7sv_sound_land is "" [""] sound to play when MOVETYPE_STEP entity hits the ground at high speed (empty cvar disables the sound)
^7sv_sound_watersplash is "" [""] sound to play when MOVETYPE_FLY/TOSS/BOUNCE/STEP entity enters or leaves water (empty cvar disables the sound)
^7sv_spectate is "1" ["1"] custom cvar
^7sv_spectator_speed_multiplier is "1.5" ["1.5"] custom cvar
^7sv_status_privacy is "1" ["1"] do not show IP addresses in 'status' replies to clients
^7sv_stepheight is "34" ["34"] how high you can step up (TW_SV_STEPCONTROL extension)
^7sv_stopspeed is "100" ["100"] how fast you come to a complete stop
^7sv_timeout is "0" ["0"] custom cvar
^7sv_timeout_leadtime is "4" ["4"] custom cvar
^7sv_timeout_length is "120" ["120"] custom cvar
^7sv_timeout_number is "2" ["2"] custom cvar
^7sv_timeout_resumetime is "3" ["3"] custom cvar
^7sv_vote_call is "1" ["1"] custom cvar
^7sv_vote_change is "0" ["0"] custom cvar
^7sv_vote_commands is "restart fraglimit chmap gotomap endmatch reducematchtime extendmatchtime allready kick" ["restart fraglimit chmap gotomap endmatch reducematchtime extendmatchtime allready kick"] custom cvar
^7sv_vote_majority_factor is "0.5" ["0.5"] custom cvar
^7sv_vote_master is "1" ["1"] custom cvar
^7sv_vote_master_commands is "" [""] custom cvar
^7sv_vote_master_password is "" [""] custom cvar
^7sv_vote_nospectators is "0" ["0"] custom cvar
^7sv_vote_only_commands is "" [""] custom cvar
^7sv_vote_override_mostrecent is "0" ["0"] custom cvar
^7sv_vote_simple_majority_factor is "0" ["0"] custom cvar
^7sv_vote_singlecount is "0" ["0"] custom cvar
^7sv_vote_timeout is "60" ["60"] custom cvar
^7sv_vote_wait is "120" ["120"] custom cvar
^7sv_wallfriction is "1" ["1"] how much you slow down when sliding along a wall
^7sv_wateraccelerate is "-1" ["-1"] rate at which a player accelerates to sv_maxspeed while in the air, if less than 0 the sv_accelerate variable is used instead
^7sv_waterfriction is "-1" ["-1"] how fast you slow down, if less than 0 the sv_friction variable is used instead
^7sv_writepicture_quality is "10" ["10"] WritePicture quality offset (higher means better quality, but slower)
^7sys_colortranslation is "2" ["1"] terminal console color translation (supported values: 0 = strip color codes, 1 = translate to ANSI codes, 2 = no translation)
^7sys_specialcharactertranslation is "0" ["1"] terminal console conchars to ASCII translation (set to 0 if your conchars.tga is for an 8bit character set or if you want raw output)
^7sys_ticrate is "0.05" ["0.05"] how long a server frame is in seconds, 0.05 is 20fps server rate, 0.1 is 10fps (can not be set higher than 0.1), 0 runs as many server frames as possible (makes games against bots a little smoother, overwhelms network players), 0.0138889 matches QuakeWorld physics
^7sys_useclockgettime is "0" ["0"] use POSIX clock_gettime function (which has issues if the system clock speed is far off, as it can't get fixed by NTP) for timing rather than gettimeofday (which has issues if the system time is stepped by ntpdate, or apparently on some Xen installations)
^7sys_usenoclockbutbenchmark is "0" ["0"] don't use ANY real timing, and simulate a clock (for benchmarking); the game then runs as fast as possible. Run a QC mod with bots that does some stuff, then does a quit at the end, to benchmark a server. NEVER do this on a public server.
^7team is "none" ["none"] QW team (4 character limit, example: blue)
^7teamplay is "0" ["0"] teamplay mode, values depend on mod but typically 0 = no teams, 1 = no team damage no self damage, 2 = team damage and self damage, some mods support 3 = no team damage but can damage self
^7teamplay_default is "4" ["4"] custom cvar
^7teamplay_lockonrestart is "0" ["0"] custom cvar
^7temp1 is "0" ["0"] general cvar for mods to use, in stock id1 this selects which death animation to use on players (0 = random death, other values select specific death scenes)
^7timeformat is "[%Y-%m-%d %H:%M:%S] " ["[%Y-%m-%d %H:%M:%S] "] time format to use on timestamped console messages
^7timelimit is "0" ["0"] ends level at this time (in minutes)
^7timelimit_decrement is "5" ["5"] custom cvar
^7timelimit_increment is "5" ["5"] custom cvar
^7timelimit_max is "60" ["60"] custom cvar
^7timelimit_maxovertime is "5" ["5"] custom cvar
^7timelimit_min is "5" ["5"] custom cvar
^7timelimit_override is "-1" ["-1"] custom cvar
^7timestamps is "0" ["0"] prints timestamps on console messages
^7userbind10_description is "team: roaming, icon" ["team: roaming, icon"] custom cvar
^7userbind10_press is "say_team roaming (l:%l^7) (h:%h^7 a:%a^7 w:%w^7); g_waypointsprite_team_here" ["say_team roaming (l:%l^7) (h:%h^7 a:%a^7 w:%w^7); g_waypointsprite_team_here"] custom cvar
^7userbind10_release is "" [""] custom cvar
^7userbind11_description is "team: attacking, icon" ["team: attacking, icon"] custom cvar
^7userbind11_press is "say_team attacking (l:%l^7) (h:%h^7 a:%a^7 w:%w^7); g_waypointsprite_team_here" ["say_team attacking (l:%l^7) (h:%h^7 a:%a^7 w:%w^7); g_waypointsprite_team_here"] custom cvar
^7userbind11_release is "" [""] custom cvar
^7userbind12_description is "team: killed flag, icon" ["team: killed flag, icon"] custom cvar
^7userbind12_press is "say_team killed flagcarrier (l:%y^7); g_waypointsprite_team_p" ["say_team killed flagcarrier (l:%y^7); g_waypointsprite_team_p"] custom cvar
^7userbind12_release is "" [""] custom cvar
^7userbind13_description is "team: dropped flag, icon" ["team: dropped flag, icon"] custom cvar
^7userbind13_press is "say_team dropped flag (l:%d^7); g_waypointsprite_team_here_d" ["say_team dropped flag (l:%d^7); g_waypointsprite_team_here_d"] custom cvar
^7userbind13_release is "" [""] custom cvar
^7userbind14_description is "team: drop, icon" ["team: drop, icon"] custom cvar
^7userbind14_press is "say_team dropped gun %w (l:%l^7); g_waypointsprite_team_here; wait; dropweapon" ["say_team dropped gun %w (l:%l^7); g_waypointsprite_team_here; wait; dropweapon"] custom cvar
^7userbind14_release is "" [""] custom cvar
^7userbind15_description is "chat: nice one" ["chat: nice one"] custom cvar
^7userbind15_press is "say :-) / nice one" ["say :-) / nice one"] custom cvar
^7userbind15_release is "" [""] custom cvar
^7userbind16_description is "chat: good game" ["chat: good game"] custom cvar
^7userbind16_press is "say good game" ["say good game"] custom cvar
^7userbind16_release is "" [""] custom cvar
^7userbind17_description is "chat: hi / good luck" ["chat: hi / good luck"] custom cvar
^7userbind17_press is "say hi / good luck and have fun" ["say hi / good luck and have fun"] custom cvar
^7userbind17_release is "" [""] custom cvar
^7userbind18_description is "scoreboard / chat history" ["scoreboard / chat history"] custom cvar
^7userbind18_press is "+showscores; +con_chat_maximize" ["+showscores; +con_chat_maximize"] custom cvar
^7userbind18_release is "-showscores; -con_chat_maximize" ["-showscores; -con_chat_maximize"] custom cvar
^7userbind19_description is "toggle recording .avi" ["toggle recording .avi"] custom cvar
^7userbind19_press is "toggle cl_capturevideo" ["toggle cl_capturevideo"] custom cvar
^7userbind19_release is "" [""] custom cvar
^7userbind1_description is "team: quad soon" ["team: quad soon"] custom cvar
^7userbind1_press is "say_team quad soon" ["say_team quad soon"] custom cvar
^7userbind1_release is "" [""] custom cvar
^7userbind20_description is "toggle fullscreen" ["toggle fullscreen"] custom cvar
^7userbind20_press is "toggle vid_fullscreen; vid_restart" ["toggle vid_fullscreen; vid_restart"] custom cvar
^7userbind20_release is "" [""] custom cvar
^7userbind21_description is "" [""] custom cvar
^7userbind21_press is "" [""] custom cvar
^7userbind21_release is "" [""] custom cvar
^7userbind22_description is "" [""] custom cvar
^7userbind22_press is "" [""] custom cvar
^7userbind22_release is "" [""] custom cvar
^7userbind23_description is "" [""] custom cvar
^7userbind23_press is "" [""] custom cvar
^7userbind23_release is "" [""] custom cvar
^7userbind24_description is "" [""] custom cvar
^7userbind24_press is "" [""] custom cvar
^7userbind24_release is "" [""] custom cvar
^7userbind25_description is "" [""] custom cvar
^7userbind25_press is "" [""] custom cvar
^7userbind25_release is "" [""] custom cvar
^7userbind26_description is "" [""] custom cvar
^7userbind26_press is "" [""] custom cvar
^7userbind26_release is "" [""] custom cvar
^7userbind27_description is "" [""] custom cvar
^7userbind27_press is "" [""] custom cvar
^7userbind27_release is "" [""] custom cvar
^7userbind28_description is "" [""] custom cvar
^7userbind28_press is "" [""] custom cvar
^7userbind28_release is "" [""] custom cvar
^7userbind29_description is "" [""] custom cvar
^7userbind29_press is "" [""] custom cvar
^7userbind29_release is "" [""] custom cvar
^7userbind2_description is "team: free item, icon" ["team: free item, icon"] custom cvar
^7userbind2_press is "say_team free item %x^7 (l:%y^7); g_waypointsprite_team_here_p" ["say_team free item %x^7 (l:%y^7); g_waypointsprite_team_here_p"] custom cvar
^7userbind2_release is "" [""] custom cvar
^7userbind30_description is "" [""] custom cvar
^7userbind30_press is "" [""] custom cvar
^7userbind30_release is "" [""] custom cvar
^7userbind31_description is "" [""] custom cvar
^7userbind31_press is "" [""] custom cvar
^7userbind31_release is "" [""] custom cvar
^7userbind32_description is "" [""] custom cvar
^7userbind32_press is "" [""] custom cvar
^7userbind32_release is "" [""] custom cvar
^7userbind3_description is "team: took item, icon" ["team: took item, icon"] custom cvar
^7userbind3_press is "say_team took item (l:%l^7); g_waypointsprite_team_here" ["say_team took item (l:%l^7); g_waypointsprite_team_here"] custom cvar
^7userbind3_release is "" [""] custom cvar
^7userbind4_description is "team: negative" ["team: negative"] custom cvar
^7userbind4_press is "say_team negative" ["say_team negative"] custom cvar
^7userbind4_release is "" [""] custom cvar
^7userbind5_description is "team: positive" ["team: positive"] custom cvar
^7userbind5_press is "say_team positive" ["say_team positive"] custom cvar
^7userbind5_release is "" [""] custom cvar
^7userbind6_description is "team: need help, icon" ["team: need help, icon"] custom cvar
^7userbind6_press is "say_team need help (l:%l^7) (h:%h^7 a:%a^7 w:%w^7); g_waypointsprite_team_helpme; cmd voice needhelp" ["say_team need help (l:%l^7) (h:%h^7 a:%a^7 w:%w^7); g_waypointsprite_team_helpme; cmd voice needhelp"] custom cvar
^7userbind6_release is "" [""] custom cvar
^7userbind7_description is "team: enemy seen, icon" ["team: enemy seen, icon"] custom cvar
^7userbind7_press is "say_team enemy seen (l:%y^7); g_waypointsprite_team_danger_p; cmd voice incoming" ["say_team enemy seen (l:%y^7); g_waypointsprite_team_danger_p; cmd voice incoming"] custom cvar
^7userbind7_release is "" [""] custom cvar
^7userbind8_description is "team: flag seen, icon" ["team: flag seen, icon"] custom cvar
^7userbind8_press is "say_team flag seen (l:%y^7); g_waypointsprite_team_here_p; cmd voice seenflag" ["say_team flag seen (l:%y^7); g_waypointsprite_team_here_p; cmd voice seenflag"] custom cvar
^7userbind8_release is "" [""] custom cvar
^7userbind9_description is "team: defending, icon" ["team: defending, icon"] custom cvar
^7userbind9_press is "say_team defending (l:%l^7) (h:%h^7 a:%a^7 w:%w^7); g_waypointsprite_team_here" ["say_team defending (l:%l^7) (h:%h^7 a:%a^7 w:%w^7); g_waypointsprite_team_here"] custom cvar
^7userbind9_release is "" [""] custom cvar
^7v_kicktime is "$v_kicktime" ["$v_kicktime"] custom cvar
^7vid_x11_display is "" [""] custom cvar
^7welcome_message_time is "8" ["8"] custom cvar
^71544 cvar(s)
