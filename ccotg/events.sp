void Event_Init()
{
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("teamplay_round_start", Event_RoundStart);
	HookEvent("arena_round_start", Event_ArenaRoundStart);
}

public Action Event_PlayerSpawn(Event event, const char[] sName, bool bDontBroadcast)
{
	if (!g_cvEnabled.BoolValue)
		return Plugin_Continue;
		
	int iClient = GetClientOfUserId(event.GetInt("userid"));
	
	if (!IsValidClient(iClient) || TF2_GetClientTeam(iClient) <= TFTeam_Spectator || TF2_GetPlayerClass(iClient) == TFClass_Sniper || !Player(iClient).bHasRobotArm)
		return Plugin_Continue;
	
	// Remove gunslinger viewmodels given by the plugin if they spawn with it... and are not a Sniper
	// Doing it this way fucks up animations for other classes if they die as sniper then switch while dead, but that's the only way I could find so far that doesn't have a server-crashing side effect
	TF2Attrib_RemoveByName(iClient, "mod wrench builds minisentry");
	Player(iClient).bHasRobotArm = false;
	
	for (int i = TFWeaponSlot_Primary; i <= TFWeaponSlot_Melee; i++)
	{
		int iWeapon = GetPlayerWeaponSlot(iClient, i);
		if (iWeapon > MaxClients)
		{
			SetEntityRenderMode(iWeapon, RENDER_TRANSCOLOR);
			SetEntityRenderColor(iWeapon, _, _, _, 255);
		}
	}
	
	return Plugin_Continue;
}

public Action Event_RoundStart(Event event, const char[] sName, bool bDontBroadcast)
{
	if (!g_cvEnabled.BoolValue)
		return Plugin_Continue;
	
	if (!g_bArenaMode || g_cvMessWithArenaRoundStates.BoolValue)
		return Plugin_Continue;
		
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (IsClientInGame(iClient))
		{
			TFTeam nTeam = TF2_GetClientTeam(iClient);
			
			// If it's arena mode and we're not messing with round states, let players know they can open the class select menu... with a different key...
			if (nTeam > TFTeam_Spectator && IsTeamAllowedToChangeClass(nTeam))
				CPrintToChat(iClient, "{olive}You can switch classes mid round by pressing your {yellow}'dropitem' {olive}key.");
		}
	}
	
	return Plugin_Continue;
}

public Action Event_ArenaRoundStart(Event event, const char[] sName, bool bDontBroadcast)
{
	if (!g_cvEnabled.BoolValue)
		return Plugin_Continue;
	
	if (!g_bArenaMode || !g_cvMessWithArenaRoundStates.BoolValue)
		return Plugin_Continue;
	
	// If it's arena mode and we're messing with round states, well... do that
	GameRules_SetProp("m_iRoundState", RoundState_RoundRunning);
	
	return Plugin_Continue;
}