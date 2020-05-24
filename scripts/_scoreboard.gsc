init()
{
	// Humans 
	setdvar("g_TeamName_Allies", "^2Humans");

	precacheShader("faction_128_sas");
	setdvar("g_TeamIcon_Allies", "faction_128_sas");
	setdvar("g_TeamColor_Allies", "1 1 1");
	setdvar("g_ScoresColor_Allies", "0 1 0");	
	
	// Monster
	setdvar("g_TeamName_Axis", "^1Monsters");

	precacheShader("faction_128_arab");
	setdvar("g_TeamIcon_Axis", "faction_128_arab");
	setdvar("g_TeamColor_Axis", "1 1 1");		
	setdvar("g_ScoresColor_Axis", "1 0 0");
	
	// Spectator
	setdvar("g_ScoresColor_Spectator", ".25 .25 .25");
	setdvar("g_ScoresColor_Free", ".76 .78 .10");
	setdvar("g_teamColor_MyTeam", ".6 .8 .6" );
	setdvar("g_teamColor_EnemyTeam", "1 .45 .5" );	
}
