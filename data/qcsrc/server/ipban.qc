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
		strunzone(ban_ip[i]);
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
	n = tokenize(cvar_string("g_banned_list"));
	if(stof(argv(0)) == 1)
	{
		ban_count = (n - 1) / 2;
		for(i = 0; i < ban_count; ++i)
		{
			ban_ip[i] = strzone(argv(2*i+1));
			ban_expire[i] = time + stof(argv(2*i+2));
		}
	}
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
		ServerConsoleEcho(msg, FALSE);
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

float Ban_IsClientBanned(entity client)
{
	float i;
	if(!ban_loaded)
		Ban_LoadBans();
	if(!Ban_GetClientIP(client))
		return FALSE;
	for(i = 0; i < ban_count; ++i)
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

float Ban_Insert(string ip, float bantime)
{
	float i;
	float j;
	float bestscore;
	// already banned?
	for(i = 0; i < ban_count; ++i)
		if(ban_ip[i] == ip)
			return FALSE;
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
	ServerConsoleEcho(strcat(ip, " has been banned for ", ftos(bantime), " seconds"), FALSE);
	ban_expire[i] = time + bantime;
	ban_ip[i] = strzone(ip);
	ban_count = max(ban_count, i + 1);

	Ban_SaveBans();

	return TRUE;
}

void Ban_KickBanClient(entity client, float bantime, float masksize)
{
	if(!Ban_GetClientIP(client))
	{
		dropclient(client);
		return;
	}
	// now ban him
	switch(masksize)
	{
		case 1:
			Ban_Insert(ban_ip1, bantime);
			break;
		case 2:
			Ban_Insert(ban_ip2, bantime);
			break;
		case 3:
			Ban_Insert(ban_ip3, bantime);
			break;
		default:
			Ban_Insert(ban_ip4, bantime);
			break;
	}
	// and kick him
	dropclient(client);
}

float GameCommand_Ban(string command)
{
	float argc;
	float bantime;
	entity client;
	float entno;
	float masksize;

	argc = tokenize(command);
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
			Ban_KickBanClient(client, bantime, masksize);
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
			Ban_Insert(ip, bantime);
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
