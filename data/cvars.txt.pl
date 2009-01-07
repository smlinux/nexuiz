#!/usr/bin/perl
use strict;
use warnings;

open my $infh, '-|', '/nexuiz/data/darkplaces/darkplaces-dedicated -basedir .. -nexuiz +sys_colortranslation 2 +sys_specialcharactertranslation 0 +cvarlist +quit 2>&1'
	or die "open: $!";

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
|	g_ban_default_.*                 # private
|	g_ban_sync_.*                    # private
|	g_chat_flood_.*                  # private
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

my %descr;
open my $fh, "<", "cvars.txt"
	or die "<cvars.txt: $!";
while(<$fh>)
{
	chomp;
	/^"(.*?)\" \"(.*)\"$/ or next;
	$descr{$1} = $2;
}
close $fh;

open $fh, ">", "cvars.txt"
	or die ">cvars.txt: $!";

while(<$infh>)
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
			if(defined $descr{$cvar})
			{
				print $fh "\"$cvar\" \"$descr{$cvar}\"\n";
			}
			else
			{
				print $fh "\"$cvar\" \"TODO: describe me\"\n";
			}
		}
		else
		{
			print $fh "\"$cvar\"\n";
		}
	}
}
