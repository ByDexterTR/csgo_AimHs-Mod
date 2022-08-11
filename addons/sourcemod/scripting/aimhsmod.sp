#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

int g_WeaponParent = -1;
bool Mod = false;
int silah = 1;
ConVar aimtimer = null;

public Plugin myinfo = 
{
	name = "AimHS Mod oylaması", 
	author = "ByDexter", 
	description = "AimHS modu oylaması yapar", 
	version = "1.1", 
	url = "https://steamcommunity.com/id/ByDexterTR/"
}

public void OnPluginStart()
{
	g_WeaponParent = FindSendPropInfo("CBaseCombatWeapon", "m_hOwnerEntity");
	
	aimtimer = CreateConVar("sm_aimhs_timer", "5", "Kaç dakika arayla oylama yapılsın", 0, true, 1.0);
	
	HookEvent("round_end", OnRoundEnd);
	HookEvent("round_start", OnRoundStart);
	
	AutoExecConfig(true, "aimhsmod", "ByDexter");
}

public void OnMapStart()
{
	CreateTimer(aimtimer.IntValue * 60.0, VoteStart, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action VoteStart(Handle timer, any data)
{
	if (IsVoteInProgress())
	{
		CancelVote();
	}
	Menu menu = new Menu(VoteMenu_Callback);
	menu.SetTitle("AimHS Modu?\n ");
	menu.AddItem("0", "--> Hayır\n ");
	menu.AddItem("1", "--> Ak47");
	menu.AddItem("2", "--> M4a4");
	menu.AddItem("3", "--> M4a1-s");
	menu.AddItem("4", "--> Deagle");
	menu.AddItem("5", "--> Usp-s");
	menu.ExitButton = false;
	menu.DisplayVoteToAll(20);
	return Plugin_Stop;
}

public int VoteMenu_Callback(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
		{
			if (!Mod)
			{
				CreateTimer(aimtimer.IntValue * 60.0, VoteStart, _, TIMER_FLAG_NO_MAPCHANGE);
				PrintToChatAll("[SM] \x10AimHS modu\x01 istenmedi, \x06%d dakika\x01 sonra tekrar oylama yapılacak.", aimtimer.IntValue);
			}
			delete menu;
		}
		case MenuAction_VoteEnd:
		{
			Mod = false;
			silah = param1;
			switch (param1)
			{
				case 1:
				{
					PrintToChatAll("[SM] \x10AimHS modu\x01 Ak47 seçildi, diğer tur sadece headshot turu olacak.");
					Mod = true;
				}
				case 2:
				{
					PrintToChatAll("[SM] \x10AimHS modu\x01 M4a4 seçildi, diğer tur sadece headshot turu olacak.");
					Mod = true;
				}
				case 3:
				{
					PrintToChatAll("[SM] \x10AimHS modu\x01 M4a1-s seçildi, diğer tur sadece headshot turu olacak.");
					Mod = true;
				}
				case 4:
				{
					PrintToChatAll("[SM] \x10AimHS modu\x01 Deagle seçildi, diğer tur sadece headshot turu olacak.");
					Mod = true;
				}
				case 5:
				{
					PrintToChatAll("[SM] \x10AimHS modu\x01 Usp seçildi, diğer tur sadece headshot turu olacak.");
					Mod = true;
				}
			}
		}
	}
	return 0;
}

public Action OnRoundStart(Event event, const char[] name, bool db)
{
	if (Mod)
	{
		GroundWeaponClear();
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				ClearWeaponEx(i);
			}
		}
		SetCvar("mp_damage_headshot_only", 1);
	}
	return Plugin_Continue;
}

public Action OnRoundEnd(Event event, const char[] name, bool db)
{
	if (Mod)
	{
		GroundWeaponClear();
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				ClearWeaponEx(i);
			}
		}
		Mod = false;
		CreateTimer(aimtimer.IntValue * 60.0, VoteStart, _, TIMER_FLAG_NO_MAPCHANGE);
		PrintToChatAll("[SM] \x10AimHS modu\x01 bitti, \x06%d dakika\x01 sonra tekrar oylama yapılacak.", aimtimer.IntValue);
	}
	return Plugin_Continue;
}

void SetCvar(char[] cvarName, int value)
{
	ConVar IntCvar = FindConVar(cvarName);
	if (IntCvar == null)return;
	int flags = IntCvar.Flags;
	flags &= ~FCVAR_NOTIFY;
	IntCvar.Flags = flags;
	IntCvar.IntValue = value;
	flags |= FCVAR_NOTIFY;
	IntCvar.Flags = flags;
}

void ClearWeaponEx(int client)
{
	int wepIdx;
	for (int i; i < 13; i++)
	{
		while ((wepIdx = GetPlayerWeaponSlot(client, i)) != -1)
		{
			RemovePlayerItem(client, wepIdx);
			RemoveEntity(wepIdx);
		}
	}
	GivePlayerItem(client, "weapon_knife");
	switch (silah)
	{
		case 1:
		{
			GivePlayerItem(client, "weapon_ak47");
		}
		case 2:
		{
			GivePlayerItem(client, "weapon_m4a1");
		}
		case 3:
		{
			GivePlayerItem(client, "weapon_m4a1_silencer");
		}
		case 4:
		{
			GivePlayerItem(client, "weapon_deagle");
		}
		case 5:
		{
			GivePlayerItem(client, "weapon_usp_silencer");
		}
	}
}

void GroundWeaponClear()
{
	int maxent = GetMaxEntities();
	char weapon[64];
	for (int i = MaxClients; i < maxent; i++)
	{
		if (IsValidEdict(i) && IsValidEntity(i))
		{
			GetEntityClassname(i, weapon, sizeof(weapon));
			if ((StrContains(weapon, "weapon_") != -1 || StrContains(weapon, "item_") != -1) && GetEntDataEnt2(i, g_WeaponParent) == -1)
				RemoveEntity(i);
		}
	}
} 