// DP/Nex Menu
// base/hostcache.qc

void() HostCache_Init =
{
	SLIST_FIELD_CNAME = gethostcacheindexforkey( "cname" );
	SLIST_FIELD_PING = gethostcacheindexforkey( "ping" );
	SLIST_FIELD_GAME = gethostcacheindexforkey( "game" );
	SLIST_FIELD_MOD = gethostcacheindexforkey( "mod" );
	SLIST_FIELD_MAP = gethostcacheindexforkey( "map" );
	SLIST_FIELD_NAME = gethostcacheindexforkey( "name" );
	SLIST_FIELD_MAXPLAYERS = gethostcacheindexforkey( "maxplayers" );
	SLIST_FIELD_NUMPLAYERS = gethostcacheindexforkey( "numplayers" );
	SLIST_FIELD_NUMHUMANS = gethostcacheindexforkey( "numhumans" );
	SLIST_FIELD_NUMBOTS = gethostcacheindexforkey( "numbots" );
	SLIST_FIELD_PROTOCOL = gethostcacheindexforkey( "protocol" );
};

void() HostCache_Update =
{
	HostCache_ViewCount = gethostcachevalue( SLIST_HOSTCACHEVIEWCOUNT );
	HostCache_TotalCount = gethostcachevalue( SLIST_HOSTCACHETOTALCOUNT );
	HostCache_MasterQueryCount = gethostcachevalue( SLIST_MASTERQUERYCOUNT );
	HostCache_MasterReplyCount = gethostcachevalue( SLIST_MASTERREPLYCOUNT );
	HostCache_ServerQueryCount = gethostcachevalue( SLIST_SERVERQUERYCOUNT );
	HostCache_ServerReplyCount = gethostcachevalue( SLIST_SERVERREPLYCOUNT );
	HostCache_SortField = gethostcachevalue( SLIST_SORTFIELD );
	HostCache_SortDescending = gethostcachevalue( SLIST_SORTDESCENDING );
};

void() HostCache_ResortViewSet =
{
	resorthostcache();
	HostCache_Update();
};

void() HostCache_RefreshHostCache =
{
	refreshhostcache();
	HostCache_Update();
};
