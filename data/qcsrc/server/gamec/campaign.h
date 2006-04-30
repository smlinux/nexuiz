// this must be included BEFORE campaign_common.h to make this a memory saving
#define CAMPAIGN_MAX_ENTRIES 2

string campaign_message;

void CampaignPreInit();
void CampaignPostInit();
void CampaignPreIntermission();
void CampaignPostIntermission(); // must change map

void CampaignLevelWarp(float n);
