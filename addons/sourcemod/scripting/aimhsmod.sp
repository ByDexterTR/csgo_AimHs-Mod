// ---- include ---- //

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <multicolors>

// ---- Pragma ---- //

#pragma semicolon 1
#pragma newdecls required

// ---- int ---- //

int g_WeaponParent;
int Digerel = 6;
int Endleme;

// ---- ConVar ---- //

ConVar ConVar_AimMod_T;

// ---- Handle ---- //

Handle Handle_AimMod_T;

// ---- myinfo ---- //

public Plugin myinfo =
{
	name = "AimHS Mod oylaması",
	author = "ByDexter",
	description = "AimHS modu oylaması yapar",
	version = "1.0",
	url = "https://steamcommunity.com/id/ByDexterTR/"
}

// -------------------- OnXStart -------------------- //

public void OnPluginStart()
{
	// ---------------- Prop ---------------- //
	g_WeaponParent = FindSendPropInfo("CBaseCombatWeapon", "m_hOwnerEntity");
	// ---------------- ConVar ---------------- //
	ConVar_AimMod_T = CreateConVar("sm_aimhs_timer", "45.0", "Kaç saniyede bir oylama yapsın");
	// ---------------- Hook ---------------- //
	HookEvent("round_end", Control_REnd);
	HookEvent("round_start", Control_RStart);
	// ---------------- Config ---------------- //
	AutoExecConfig(true, "aimhsmod", "ByDexter");
}

public void OnMapStart()
{
	Handle_AimMod_T = CreateTimer(ConVar_AimMod_T.FloatValue, EventVoteStart, _, TIMER_FLAG_NO_MAPCHANGE);
}

// -------------------- OnXEnd -------------------- //

public void OnMapEnd()
{
	delete Handle_AimMod_T;
}

// -------------------- VOTE -------------------- //

public Action EventVoteStart(Handle timer, any data)
{
	VoteYaptir();
}

void VoteYaptir()
{
	if (IsVoteInProgress())
	{
		return;
	}
	Menu menu = new Menu(Handle_VoteMenu);
	menu.SetTitle("<-- AimHS Modu? -->");
	menu.AddItem("no", "--> Hayır <--");
	menu.AddItem("ak47", "--> Ak47 <--");
	menu.AddItem("m4a4", "--> M4a4 <--");
	menu.AddItem("m4a1", "--> M4a1-s <--");
	menu.AddItem("deagle", "--> Deagle <--");
	menu.AddItem("usp", "--> Usp-s <--");
	menu.ExitButton = false;
	menu.DisplayVoteToAll(20);
}

public int Handle_VoteMenu(Menu menu, MenuAction action, int param1,int param2)
{
	if (action == MenuAction_End)
	{
		if(Digerel == 6)
		{
			Handle_AimMod_T = CreateTimer(ConVar_AimMod_T.FloatValue, EventVoteStart, _, TIMER_FLAG_NO_MAPCHANGE);
			CPrintToChatAll("{darkred}[ByDexter] {green}%d saniye {default}sonra tekrar oylama yapılacak", ConVar_AimMod_T.IntValue);
		}
		delete menu;
	} 
	else if (action == MenuAction_VoteEnd) 
	{
		if (param1 == 0)
		{
			CPrintToChatAll("{darkred}[ByDexter] {green}AimHS Modu {default}istenmedi.");
			Digerel = 6;
			
		}
		if (param1 == 1)
		{
			CPrintToChatAll("{darkred}[ByDexter] {green}Diğer el {default}Ak47 HS turu olacak");
			Digerel = 1;
		}
		if (param1 == 2)
		{
			CPrintToChatAll("{darkred}[ByDexter] {green}Diğer el {default}M4a4 HS turu olacak");
			Digerel = 2;
		}
		if (param1 == 3)
		{
			CPrintToChatAll("{darkred}[ByDexter] {green}Diğer el {default}M4a1-s HS turu olacak");
			Digerel = 3;
		}
		if (param1 == 4)
		{
			CPrintToChatAll("{darkred}[ByDexter] {green}Diğer el {default}Deagle HS turu olacak");
			Digerel = 4;
		}
		if (param1 == 5)
		{
			CPrintToChatAll("{darkred}[ByDexter] {green}Diğer el {default}Usp-s HS turu olacak");
			Digerel = 5;
		}
	}
}

// -------------------- Void -------------------- //

void SilahlariSil(int client)
{
	for(int j = 0; j < 5; j++)
	{
		int weapon = GetPlayerWeaponSlot(client, j);
		if(weapon != -1)
		{
			RemovePlayerItem(client, weapon);
			RemoveEdict(weapon);						
		}
	}
	GivePlayerItem(client, "weapon_knife");
}

void YerdekiSilahlariSil()
{
	int maxent = GetMaxEntities();
	char weapon[64];
	for (int i = MaxClients; i < maxent; i++)
	{
		if (IsValidEdict(i) && IsValidEntity(i))
		{
			GetEdictClassname(i, weapon, sizeof(weapon));
			if ((StrContains(weapon, "weapon_") != -1 || StrContains(weapon, "item_") != -1) && GetEntDataEnt2(i, g_WeaponParent) == -1)
			RemoveEdict(i);
		}
	}
}

void SetCvar(char cvarName[64], int value)
{
	Handle IntCvar = FindConVar(cvarName);
	if (IntCvar)
	{
		int flags = GetConVarFlags(IntCvar);
		flags &= ~FCVAR_NOTIFY;
		SetConVarFlags(IntCvar, flags);
		SetConVarInt(IntCvar, value, false, false);
		flags |= FCVAR_NOTIFY;
		SetConVarFlags(IntCvar, flags);
	}
}

// -------------------- HookEvent -------------------- //

public Action Control_RStart(Handle event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++) 
	if(IsClientInGame(i) && !IsFakeClient(i))
	{
		if(Digerel == 1)
		{
			Endleme = 1;
			YerdekiSilahlariSil();
			SilahlariSil(i);
			CPrintToChatAll("{darkred}[ByDexter] {green}Ak47 turu {default}başlıyor");
			SetCvar("mp_damage_headshot_only", 1);
			GivePlayerItem(i, "weapon_ak47");
		}
		else if(Digerel == 2)
		{
			Endleme = 1;
			YerdekiSilahlariSil();
			SilahlariSil(i);
			CPrintToChatAll("{darkred}[ByDexter] {green}M4a4 turu {default}başlıyor");
			SetCvar("mp_damage_headshot_only", 1);
			GivePlayerItem(i, "weapon_m4a1");
		}
		else if(Digerel == 3)
		{
			Endleme = 1;
			YerdekiSilahlariSil();
			SilahlariSil(i);
			CPrintToChatAll("{darkred}[ByDexter] {green}M4a1-s turu {default}başlıyor");
			SetCvar("mp_damage_headshot_only", 1);
			GivePlayerItem(i, "weapon_m4a1_silencer");
		}
		else if(Digerel == 4)
		{
			Endleme = 1;
			YerdekiSilahlariSil();
			SilahlariSil(i);
			CPrintToChatAll("{darkred}[ByDexter] {green}Deagle turu {default}başlıyor");
			SetCvar("mp_damage_headshot_only", 1);
			GivePlayerItem(i, "weapon_deagle");
		}
		else if(Digerel == 5)
		{
			Endleme = 1;
			YerdekiSilahlariSil();
			SilahlariSil(i);
			CPrintToChatAll("{darkred}[ByDexter] {green}Usp-s turu {default}başlıyor");
			SetCvar("mp_damage_headshot_only", 1);
			GivePlayerItem(i, "weapon_usp_silencer");
		}
	}
}	

public Action Control_REnd(Handle event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++) 
	if(Endleme && IsClientInGame(i) && !IsFakeClient(i))
	{
		Endleme = 0;
		Digerel = 6;
		SetCvar("mp_damage_headshot_only", 0);
		Handle_AimMod_T = CreateTimer(ConVar_AimMod_T.FloatValue, EventVoteStart, _, TIMER_FLAG_NO_MAPCHANGE);
		CPrintToChatAll("{darkred}[ByDexter] {green}%d saniye {default}sonra tekrar oylama yapılacak", ConVar_AimMod_T.IntValue);
	}
}

// -------------------- Map Control -------------------- //

public void OnAutoConfigsBuffered()
{
    CreateTimer(3.0, aimcontrol);
}

public Action aimcontrol(Handle timer)
{
    char filename[512];
    GetPluginFilename(INVALID_HANDLE, filename, sizeof(filename));
    char mapname[PLATFORM_MAX_PATH];
    GetCurrentMap(mapname, sizeof(mapname));
    if (StrContains(mapname, "aim_", false) == -1)
    {
        ServerCommand("sm plugins unload %s", filename);
    }
    return Plugin_Stop;
}