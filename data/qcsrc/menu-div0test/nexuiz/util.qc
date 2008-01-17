void forAllDescendants(entity root, void(entity, entity) funcPre, void(entity, entity) funcPost, entity pass)
{
	depthfirst(root, parent, firstChild, nextSibling, funcPre, funcPost, pass);
}

.string cvarName;
void SUB_Null_ee(entity e1, entity e2)
{
}
void saveCvarsOf(entity ignore, entity e)
{
	if(e.cvarName)
		e.saveCvars(e);
}
void loadCvarsOf(entity ignore, entity e)
{
	if(e.cvarName)
		e.loadCvars(e);
}
void saveAllCvars(entity root)
{
	forAllDescendants(root, saveCvarsOf, SUB_Null_ee, NULL);
}
void loadAllCvars(entity root)
{
	forAllDescendants(root, loadCvarsOf, SUB_Null_ee, NULL);
}

.void(entity) draw_setDependent;
.string cvar_setDependent;
.float cvarMin_setDependent;
.float cvarMax_setDependent;
.string cvar2_setDependent;
.float cvar2Min_setDependent;
.float cvar2Max_setDependent;
.float op_setDependent;
void setDependent_Check(entity e)
{
	float f;
	f = cvar(e.cvar_setDependent);
	if(e.cvarMin_setDependent <= e.cvarMax_setDependent)
		e.disabled = ((f < e.cvarMin_setDependent) || (f > e.cvarMax_setDependent));
	else
		e.disabled = ((f >= e.cvarMax_setDependent) && (f <= e.cvarMin_setDependent));
	if(e.cvar2_setDependent)
	{
		f = cvar(e.cvar2_setDependent);
		if(e.cvar2Min_setDependent <= e.cvar2Max_setDependent)
			e.disabled = (e.disabled + ((f < e.cvar2Min_setDependent) || (f > e.cvar2Max_setDependent)) > e.op_setDependent);
		else
			e.disabled = (e.disabled + ((f >= e.cvar2Max_setDependent) && (f <= e.cvar2Min_setDependent)) > e.op_setDependent);
	}
}
void setDependent_Draw(entity e)
{
	setDependent_Check(e);
	e.draw_setDependent(e);
}
void setDependent(entity e, string theCvarName, float theCvarMin, float theCvarMax)
{
	e.draw_setDependent = e.draw;
	e.cvar_setDependent = theCvarName;
	e.cvarMin_setDependent = theCvarMin;
	e.cvarMax_setDependent = theCvarMax;
	e.cvar2_setDependent = string_null;
	e.draw = setDependent_Draw;
	setDependent_Check(e);
}
void setDependentAND(entity e, string theCvarName, float theCvarMin, float theCvarMax, string theCvar2Name, float theCvar2Min, float theCvar2Max)
{
	e.draw_setDependent = e.draw;
	e.cvar_setDependent = theCvarName;
	e.cvarMin_setDependent = theCvarMin;
	e.cvarMax_setDependent = theCvarMax;
	e.cvar2_setDependent = theCvar2Name;
	e.cvar2Min_setDependent = theCvar2Min;
	e.cvar2Max_setDependent = theCvar2Max;
	e.op_setDependent = 0;
	e.draw = setDependent_Draw;
	setDependent_Check(e);
}
void setDependentOR(entity e, string theCvarName, float theCvarMin, float theCvarMax, string theCvar2Name, float theCvar2Min, float theCvar2Max)
{
	e.draw_setDependent = e.draw;
	e.cvar_setDependent = theCvarName;
	e.cvarMin_setDependent = theCvarMin;
	e.cvarMax_setDependent = theCvarMax;
	e.cvar2_setDependent = theCvar2Name;
	e.cvar2Min_setDependent = theCvar2Min;
	e.cvar2Max_setDependent = theCvar2Max;
	e.op_setDependent = 1;
	e.draw = setDependent_Draw;
	setDependent_Check(e);
}

float preMenuInit()
{
	MapInfo_Enumerate();
	if(!MapInfo_FilterGametype(MAPINFO_TYPE_ALL, 0, 1))
		return FALSE;
	return TRUE;
}

string campaign_name_previous;
float campaign_won_previous;
void preMenuDraw()
{
	if not(campaign_name_previous)
		campaign_name_previous = strzone(strcat(campaign_name, "x")); // force unequal
	if(campaign_name == campaign_name_previous)
	{
		if(cvar(strcat("g_campaign", campaign_name, "_won")))
		{
			if(!campaign_won_previous)
			{
				m_display();
				DialogOpenButton_Click_withCoords(NULL, main.winnerDialog, '0 0 0', '1 1 0');
			}
			campaign_won_previous = 1;
		}
		else
			campaign_won_previous = 0;
	}
	else
	{
		strunzone(campaign_name_previous);
		campaign_name_previous = strzone(campaign_name);
		campaign_won_previous = cvar(strcat("g_campaign", campaign_name, "_won"));
	}

}
