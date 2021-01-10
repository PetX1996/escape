//I========================================================================I
//I                    ___  _____  _____                                   I
//I                   /   !!  __ \!  ___!                                  I
//I                  / /! !! !  \/! !_          ___  ____                  I
//I                 / /_! !! ! __ !  _!        / __!!_  /                  I
//I                 \___  !! !_\ \! !      _  ! (__  / /                   I
//I                     !_/ \____/\_!     (_)  \___!/___!                  I
//I                                                                        I
//I========================================================================I
// Call of Duty 4: Modern Warfare
//I========================================================================I
// Mod      : Escape
// Website  : http://www.4gf.cz/
//I========================================================================I
// Script by: PetX
//I========================================================================I

private TYPE_BOOL = 1;
private TYPE_INT = 2;
private TYPE_FLOAT = 3;
private TYPE_STRING = 4;

init()
{
	LoadAllDvars();
}

LoadAllDvars()
{
	RegisterDvar( "developer", TYPE_BOOL, 0, undefined, undefined, true );
	RegisterDvar( "logic", TYPE_BOOL, 1 );
	RegisterDvar( "autospawn", TYPE_BOOL, 0 );
	//RegisterDvar( "deathrun_support", TYPE_BOOL, 0 );
	RegisterDvar( "flying", TYPE_BOOL, 0 );
	
	// ======  GAME LOGIC ====== //
	// ========================= //
	RegisterDvar( "logic_playersToStart", TYPE_INT, 2 );
	
	RegisterDvar( "logic_preMatchStartTime", TYPE_INT, 5 );
	
	RegisterDvar( "logic_startHumansTime", TYPE_INT, 10 );
	RegisterDvar( "logic_startMonsterTime", TYPE_INT, 10 );
	RegisterDvar( "logic_startHumansTimeAdd", TYPE_INT, 0 );
	RegisterDvar( "logic_startMonsterTimeAdd", TYPE_INT, 5 );
	
	RegisterDvar( "logic_pickMonsters", TYPE_FLOAT, 0.25 );
	RegisterDvar( "logic_pickSystem", TYPE_STRING, "mix" );
	
	RegisterDvar( "logic_timeLimit", TYPE_FLOAT, 10 );
	RegisterDvar( "logic_roundLimit", TYPE_INT, 10 );
	
	RegisterDvar( "logic_respawnTime", TYPE_INT, 5 );
	
	RegisterDvar( "logic_mapVoting", TYPE_BOOL, 0 );
	
	// ======  CHECKPOINT ====== //
	// ========================= //
	RegisterDvar( "checkpoint_deadTime", TYPE_INT, 30 );
	
	// ======  SURVIVAL  ====== //
	// ======================== //
	RegisterDvar( "location_multi", TYPE_FLOAT, 0.2 );
	RegisterDvar( "location_time", TYPE_INT, 30 );
	RegisterDvar( "location_prepareTime", TYPE_INT, 10 );
	RegisterDvar( "location_spaceTime", TYPE_INT, 10 );
	
	// =========  ACP ========== //
	// ========================= //
	RegisterDvar( "b3_allow", TYPE_BOOL, 0 ); // je b3 zapnutá?
		/// <Delete Profile="Release">
		RegisterDvar( "b3_startacp", TYPE_STRING, "1:120" ); // vypnutá b3, nastaví každému toto
		RegisterDvar( "b3_startxp", TYPE_INT, 100 ); // vypnutá b3, nastaví každému toto
		/// <Delete/>
	RegisterDvar( "acp_developers", TYPE_BOOL, 1 ); // 1 = testovanie developerov pod¾a guidu
	
	// ========== STATS =========== //
	// ============================ //
	RegisterDvar( "stats_clearMPData", TYPE_INT, 2 ); // 0 - nemaže ; 1 - maže vždy ; 2 - maže pod¾a verzie
	RegisterDvar( "stats_version", TYPE_INT, 2 ); // verzia hry
	
	// ========  RANK  ======== //
	// ======================== //
	RegisterDvar( "score_kill", TYPE_INT, 100 );
	RegisterDvar( "score_headshot", TYPE_INT, 200 );
	RegisterDvar( "score_damage_allies", TYPE_FLOAT, 0.5 );
	RegisterDvar( "score_damage_axis", TYPE_FLOAT, 0.25 );
	
	RegisterDvar( "score_checkpoint", TYPE_INT, 100 );
	RegisterDvar( "score_spawnpoint", TYPE_INT, 50 );
	RegisterDvar( "score_endMapFirst", TYPE_INT, 500 );
	RegisterDvar( "score_endMapSecond", TYPE_INT, 250 );
	RegisterDvar( "score_endMapThird", TYPE_INT, 125 );
	RegisterDvar( "score_endMapOther", TYPE_INT, 0 );
	
	RegisterDvar( "score_location", TYPE_INT, 25 );
	
	RegisterDvar( "price_restoreAmmo", TYPE_INT, 0 );
	
	// ======  PLAYERS  ======= //
	// ======================== //
	RegisterDvar( "p_healthMin_allies", TYPE_INT, 100 );
	RegisterDvar( "p_healthMax_allies", TYPE_INT, 300 );
	// Minimum health is set for this many HUMANS
	RegisterDvar( "p_healthEnemyMin_allies", TYPE_INT, 20 );
	// Maximum health is set for this many HUMANS
	RegisterDvar( "p_healthEnemyMax_allies", TYPE_INT, 1 );
	
	RegisterDvar( "p_healthMin_axis", TYPE_INT, 500 );
	RegisterDvar( "p_healthMax_axis", TYPE_INT, 5000 );
	// Minimum health is set for this many alive HUMANS
	RegisterDvar( "p_healthEnemyMin_axis", TYPE_INT, 1 );
	// Maximum health is set for this many alive HUMANS
	RegisterDvar( "p_healthEnemyMax_axis", TYPE_INT, 20 );
	
	RegisterDvar( "p_speedMin_allies", TYPE_INT, 80 );
	RegisterDvar( "p_speedMax_allies", TYPE_INT, 110 );
	RegisterDvar( "p_speedMin_axis", TYPE_INT, 80 );
	RegisterDvar( "p_speedMax_axis", TYPE_INT, 120 );
	
	RegisterDvar( "p_knifeDamageAllies", TYPE_INT, 135 );
	RegisterDvar( "p_knifeDamageAxisMin", TYPE_INT, 50 );
	RegisterDvar( "p_knifeDamageAxisMax", TYPE_INT, 200 );

	RegisterDvar( "p_repelMin", TYPE_INT, 200 );
	RegisterDvar( "p_repelMax", TYPE_INT, 500 );
	// Minimum repel is set for this many alive HUMANS
	RegisterDvar( "p_repelEnemyMin", TYPE_INT, 20 );
	// Maximum repel is set for this many alive HUMANS
	RegisterDvar( "p_repelEnemyMax", TYPE_INT, 1 );
	
	// ======  WEAPONS  ======= //
	// ======================== //
	RegisterDvar( "w_unlimitedPrimary", TYPE_BOOL, 1 );
	RegisterDvar( "w_unlimitedSecondary", TYPE_BOOL, 1 );
	
	// ======  QUICK VOTING  ======= //
	// ============================= //	
	RegisterDvar( "qVote_time", TYPE_INT, 15 );
	RegisterDvar( "qVote_delay", TYPE_INT, 30 );
}

RegisterDvar( dvarName, dvarType, defaultValue, minValue, maxValue, ignorePrefix )
{
	dvarFullName = undefined;
	if( IsDefined( ignorePrefix ) && ignorePrefix && GetDvar( dvarName ) != "" )
		dvarFullName = dvarName;
	else if( GetDvar( level.gametype + "_" + dvarName ) != "" )
		dvarFullName = level.gametype + "_" + dvarName;
	else if( GetDvar( "scr_" + dvarName ) != "" )
		dvarFullName = "scr_" + dvarName;

	dvarValue = defaultValue;
	if( IsDefined( dvarFullName ) )
		dvarValue = GetDvarValue( dvarFullName, dvarType, defaultValue, minValue, maxValue );
		
	SetDvarValue( dvarName, dvarValue, dvarType, defaultValue, minValue, maxValue );
}

SetDvarValue( dvarName, dvarValue, dvarType, defaultValue, minValue, maxValue )
{
	if( dvarType == TYPE_BOOL )
	{
		if( !(dvarValue == 0 || dvarValue == 1) )
			dvarValue = defaultValue;
	}
	else if( dvarType == TYPE_INT || dvarType == TYPE_FLOAT )
	{
		if( IsDefined( minValue ) && dvarValue < minValue )
			dvarValue = minValue;
		
		if( IsDefined( maxValue ) && dvarValue > maxValue )
			dvarValue = maxValue;
	}
	
	level.dvars[dvarName] = dvarValue;
}

GetDvarValue( dvarName, dvarType, defaultValue, minValue, maxValue )
{
	switch( dvarType )
	{
		case TYPE_BOOL:
		case TYPE_INT:
			return GetDvarInt( dvarName );
		case TYPE_FLOAT:
			return GetDvarFloat( dvarName );
		default:
			return GetDvar( dvarName );
	}
}