// DP/Nex Menu
// base/hostcache.qc

float HostCache_ViewCount;
float HostCache_TotalCount;
float HostCache_MasterQueryCount;
float HostCache_MasterReplyCount;
float HostCache_ServerQueryCount;
float HostCache_ServerReplyCount;
float HostCache_SortField;
float HostCache_SortDescending;

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
