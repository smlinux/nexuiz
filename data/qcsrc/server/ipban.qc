float Ban_Insert(string ip, float bantime, string reason, float dosync);

void OnlineBanList_SendBan(string ip, float bantime, string reason)
{
	string uri;

	uri = cvar_string("g_ban_sync_uri");

	if(uri == "")
		return;

	uri = strcat(uri, "?action=ban");
	uri = strcat(uri, "&ip=", uri_escape(ip));
	uri = strcat(uri, "&duration=", ftos(bantime));
	uri = strcat(uri, "&why=", uri_escape(reason));

	uri_get(uri, 0); // 0 = "discard" callback target
}

void OnlineBanList_SendUnban(string ip)
{
	string uri;

	uri = cvar_string("g_ban_sync_uri");

	if(uri == "")
		return;

	uri = strcat(uri, "?action=unban");
	uri = strcat(uri, "&ip=", uri_escape(ip));

	uri_get(uri, 0); // 0 = "discard" callback target
}

string OnlineBanList_Servers;
float OnlineBanList_Timeout;

void OnlineBanList_URI_Get_Callback(float status, string data)
{
	float n, i, j, l;
	string ip;
	float timeleft;
	string reason;
	string serverip;
	float syncinterval;

	if(time > OnlineBanList_Timeout)
		return;
	OnlineBanList_Timeout = 0;

	syncinterval = cvar("g_ban_sync_interval");
	if(syncinterval == 0)
		return;
	if(syncinterval > 0)
		syncinterval *= 60;

	if(status != 0)
	{
		print("Error receiving the online ban list.\nStatus is ", ftos(status), "\n");
		return;
	}

	if(substring(data, 0, 1) == "<")
	{
		print("Error receiving the online ban list.\nReceived HTML instead of a ban list.\n");
		return;
	}

	if(strstrofs(data, "\r", 0) != -1)
	{
		print("Error receiving the online ban list.\nReceived carriage returns.\n");
		return;
	}

	n = tokenizebyseparator(data, "\n");
	if(mod(n, 4) != 0)
	{
		print("Error receiving the online ban list.\nReceived invalid item count.\n");
		return;
	}

	for(i = 0; i < n; i += 4)
	{
		ip = argv(i);
		timeleft = stof(argv(i + 1));
		reason = argv(i + 2);
		serverip = argv(i + 3);

		timeleft -= 15;
		if(timeleft < 0)
			continue;

		l = strlen(ip);
		for(j = 0; j < l; ++j)
			if(strstrofs("0123456789.", substring(ip, j, 1), 0) == -1)
			{
				print("Invalid character ", substring(ip, j, 1), " in IP address ", ip, ". Skipping this ban.\n");
				goto skip;
			}

		if(strstrofs(strcat(":", OnlineBanList_Servers, ":"), strcat(":", serverip, ":"), 0) != -1)
		{
			if(syncinterval > 0)
				timeleft = min(syncinterval + 15, timeleft);
				// 15 seconds for safety
				// the ban will be prolonged on the next sync
			Ban_Insert(ip, timeleft, strcat("ban synced from ", serverip), 0);
			print("Ban list syncing: accepted ban of ", ip, " by ", serverip, ": ", reason, "\n");
		}

		continue;
:skip
	}
}

void OnlineBanList_Think()
{
	float argc;
	string uri;
	float i;
	
	uri = cvar_string("g_ban_sync_uri");

	if(uri == "")
		return;
	if(cvar("g_ban_sync_interval") == 0) // < 0 is okay, it means "sync on level start only"
		return;
	argc = tokenize_sane(cvar_string("g_ban_sync_trusted_servers"));
	if(argc == 0)
		return;

	if(OnlineBanList_Timeout == 0) // only if there is no ongoing request!
	{
		if(OnlineBanList_Servers)
			strunzone(OnlineBanList_Servers);
		OnlineBanList_Servers = argv(0);
		for(i = 1; i < argc; ++i)
			OnlineBanList_Servers = strcat(OnlineBanList_Servers, ":", argv(i));
		OnlineBanList_Servers = strzone(OnlineBanList_Servers);
		
		uri = strcat(uri, "?action=list");
		uri = strcat(uri, "&servers=", uri_escape(OnlineBanList_Servers));

		OnlineBanList_Timeout = time + 10;
		uri_get(uri, 1); // 1 = "banlist" callback target
	}
	
	if(cvar("g_ban_sync_interval") > 0)
		self.nextthink = time + max(60, cvar("g_ban_sync_interval") * 60);
}

#define BAN_MAX 64
float ban_loaded;
string ban_ip[BAN_MAX];
float ban_expire[BAN_MAX];
float ban_count;

string ban_ip1;
string ban_ip2;
string ban_ip3;
string ban_ip4;

void Ban_SaveBans()
{
	string out;
	float i;

	if(!ban_loaded)
		return;

	// version of list
	out = "1";
	for(i = 0; i < ban_count; ++i)
	{
		if(time > ban_expire[i])
			continue;
		out = strcat(out, " ", ban_ip[i]);
		out = strcat(out, " ", ftos(ban_expire[i] - time));
	}
	if(strlen(out) <= 1) // no real entries
		cvar_set("g_banned_list", "");
	else
		cvar_set("g_banned_list", out);
}

float Ban_Delete(float i)
{
	if(i < 0)
		return FALSE;
	if(i >= ban_count)
		return FALSE;
	if(ban_expire[i] == 0)
		return FALSE;
	if(ban_expire[i] > 0)
	{
		OnlineBanList_SendUnban(ban_ip[i]);
		strunzone(ban_ip[i]);
	}
	ban_expire[i] = 0;
	ban_ip[i] = "";
	Ban_SaveBans();
	return TRUE;
}

void Ban_LoadBans()
{
	float i, n;
	for(i = 0; i < ban_count; ++i)
		Ban_Delete(i);
	ban_count = 0;
	ban_loaded = TRUE;
	n = tokenize_sane(cvar_string("g_banned_list"));
	if(stof(argv(0)) == 1)
	{
		ban_count = (n - 1) / 2;
		for(i = 0; i < ban_count; ++i)
		{
			ban_ip[i] = strzone(argv(2*i+1));
			ban_expire[i] = time + stof(argv(2*i+2));
		}
	}

	entity e;
	e = spawn();
	e.classname = "bansyncer";
	e.think = OnlineBanList_Think;
	e.nextthink = time + 1;
}

void Ban_View()
{
	float i;
	string msg;
	for(i = 0; i < ban_count; ++i)
	{
		if(time > ban_expire[i])
			continue;
		msg = strcat("#", ftos(i), ": ");
		msg = strcat(msg, ban_ip[i], " is still banned for ");
		msg = strcat(msg, ftos(ban_expire[i] - time), " seconds");
		print(msg, "\n");
	}
}

float Ban_GetClientIP(entity client)
{
	float n;
	n = tokenizebyseparator(client.netaddress, ".");
	if(n != 4)
		return FALSE;
	ban_ip1 = strcat1(argv(0));
	ban_ip2 = strcat(ban_ip1, ".", argv(1));
	ban_ip3 = strcat(ban_ip2, ".", argv(2));
	ban_ip4 = strcat(ban_ip3, ".", argv(3));
	return TRUE;
}

float Ban_IsClientBanned(entity client, float idx)
{
	float i, b, e;
	if(!ban_loaded)
		Ban_LoadBans();
	if(!Ban_GetClientIP(client))
		return FALSE;
	if(idx < 0)
	{
		b = 0;
		e = ban_count;
	}
	else
	{
		b = idx;
		e = idx + 1;
	}
	for(i = b; i < e; ++i)
	{
		string s;
		if(time > ban_expire[i])
			continue;
		s = ban_ip[i];
		if(ban_ip1 == s) return TRUE;
		if(ban_ip2 == s) return TRUE;
		if(ban_ip3 == s) return TRUE;
		if(ban_ip4 == s) return TRUE;
	}
	return FALSE;
}

float Ban_MaybeEnforceBan(entity client)
{
	if(Ban_IsClientBanned(client, -1))
	{
		string s;
		s = strcat("^1NOTE:^7 banned client ", client.netaddress, " just tried to enter\n");
		dropclient(client);
		bprint(s);
		return TRUE;
	}
	return FALSE;
}

float Ban_Insert(string ip, float bantime, string reason, float dosync)
{
	float i;
	float j;
	float bestscore;
	entity e;
	string s;

	if(dosync)
		OnlineBanList_SendBan(ip, bantime, reason);

	// already banned?
	for(i = 0; i < ban_count; ++i)
		if(ban_ip[i] == ip)
		{
			// prolong the ban
			if(time + bantime > ban_expire[i])
			{
				ban_expire[i] = time + bantime;
				print(ip, "'s ban has been prolonged to ", ftos(bantime), " seconds from now\n");
			}
			// and abort
			return FALSE;
		}
	// do we have a free slot?
	for(i = 0; i < ban_count; ++i)
		if(time > ban_expire[i])
			break;
	// no free slot? Then look for the one who would get unbanned next
	if(i >= BAN_MAX)
	{
		i = 0;
		bestscore = ban_expire[i];
		for(j = 1; j < ban_count; ++j)
		{
			if(ban_expire[j] < bestscore)
			{
				i = j;
				bestscore = ban_expire[i];
			}
		}
	}
	// if we replace someone, will we be banned longer than him (so long-term
	// bans never get overridden by short-term bans)
	if(ban_expire[i] > time + bantime)
		return FALSE;
	// okay, insert our new victim as i
	Ban_Delete(i);
	print(ip, " has been banned for ", ftos(bantime), " seconds\n");
	ban_expire[i] = time + bantime;
	ban_ip[i] = strzone(ip);
	ban_count = max(ban_count, i + 1);

	Ban_SaveBans();

	// Enforce our new ban
	s = "";
	FOR_EACH_REALCLIENT(e)
		if(Ban_IsClientBanned(e, i))
		{
			s = strcat(s, "^1NOTE:^7 banned client ", e.netname, "^7 has to go\n");
			dropclient(e);
		}
	bprint(s);

	return TRUE;
}

void Ban_KickBanClient(entity client, float bantime, float masksize, string reason)
{
	if(!Ban_GetClientIP(client))
	{
		sprint(client, strcat("Kickbanned: ", reason, "\n"));
		dropclient(client);
		return;
	}
	// now ban him
	switch(masksize)
	{
		case 1:
			Ban_Insert(ban_ip1, bantime, reason, 1);
			break;
		case 2:
			Ban_Insert(ban_ip2, bantime, reason, 1);
			break;
		case 3:
			Ban_Insert(ban_ip3, bantime, reason, 1);
			break;
		default:
			Ban_Insert(ban_ip4, bantime, reason, 1);
			break;
	}
	// and kick him
	sprint(client, strcat("Kickbanned: ", reason, "\n"));
	dropclient(client);
}

float GameCommand_Ban(string command)
{
	float argc;
	float bantime;
	entity client;
	float entno;
	float masksize;
	string reason;

	argc = tokenize_sane(command);
	if(argv(0) == "help")
	{
		print("  kickban # n m p - kickban player n for m seconds, using mask size p (1 to 4)\n");
		print("  ban ip m - ban an IP or range (incomplete IP, like 1.2.3) for m seconds\n");
		print("  bans - list all existing bans\n");
		print("  unban n - delete the entry #n from the bans list\n");
		return TRUE;
	}
	if(argv(0) == "kickban")
	{
		if(argc >= 3)
		{
			entno = stof(argv(2));
			if(entno > maxclients || entno < 1)
				return TRUE;
			client = edict_num(entno);
			if(argc >= 4)
				bantime = stof(argv(3));
			else
				bantime = cvar("g_ban_default_bantime");
			if(argc >= 5)
				masksize = stof(argv(4));
			else
				masksize = cvar("g_ban_default_masksize");
			if(argc >= 6)
				reason = substring(command, argv_start_index(5), strlen(command) - argv_start_index(5));
			else
				reason = "";
			Ban_KickBanClient(client, bantime, masksize, reason);
			return TRUE;
		}
	}
	else if(argv(0) == "ban")
	{
		if(argc >= 2)
		{
			string ip;
			ip = argv(1);
			if(argc >= 3)
				bantime = stof(argv(2));
			else
				bantime = cvar("g_ban_default_bantime");
			if(argc >= 4)
				reason = substring(command, argv_start_index(3), strlen(command) - argv_start_index(3));
			else
				reason = "";
			Ban_Insert(ip, bantime, reason, 1);
			return TRUE;
		}
	}
	else if(argv(0) == "bans")
	{
		Ban_View();
		return TRUE;
	}
	else if(argv(0) == "unban")
	{
		if(argc >= 2)
		{
			float who;
			who = stof(argv(1));
			Ban_Delete(who);
			return TRUE;
		}
	}
	return FALSE;
}
