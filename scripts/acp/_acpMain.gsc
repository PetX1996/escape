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

#include scripts\include\_acp;
#include scripts\include\_string;

init()
{
	thread ACPAccess();
}

// ============================================================== */
// ====================== ACESS SECTION ========================= */
// ============================================================== */

ACPAccess()
{
	wait 0.5;

	while(1) 
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];

			entNum = player GetEntityNumber();
			info = GetDvar( "acp_info_" + entNum );
				
			if( !IsDefined( info ) || info == "" )
				continue;
				
			if( IsDefined( player.acp_info ) && player.acp_info == info )
				continue;
				
			player.acp_info = info;
			info = StrTok( info, ":" );
			
			if( !IsDefined( info ) || !IsDefined( player ) )
				continue;
			
			if( info.size < 2 || !IsDefined( info[0] ) || !IsDefined( info[1] ) )
				continue;
		
			player SetPermission( Int( info[1] ), Int( info[0] ) );
		}
		
		wait 0.5;
	}
}

IsDeveloper()
{
	if( !level.dvars["acp_developers"] )
		return false;
	
	switch( self GetGuid() )
	{
		case "8efa4cbada87e6348e7db02e3893dd89": // I
		case "kde_ta_mam_asi_zobrat_hmm.......": // R3MIEN
		case "615fe32f67350603d6438a563e6dec3b": // Col!ar
			return true;
		default:
			return false;
	}
}

SetPermission( b3level, showme )
{
	if( IsDefined( b3level ) )
	{
		if( self IsDeveloper() && ( !level.dvars["b3_allow"] || b3level >= 40 ) )
			b3level = 120;
	
		self.b3level = b3level;
		self.pers["b3level"] = b3level;
		self SetClientDvar( "b3level", b3level );
		self scripts\clients\_players::UpdateStatusIcon();
	}
	
	if( IsDefined( showme ) )
	{
		self.showme = showme;
		self.pers["showme"] = showme;
		self scripts\clients\_players::UpdateStatusIcon();
	}
}

// ================================================================================================================================================================================================= //

ACP_Open()
{
	self ACP();
	
	self ACP_BuildMenu();
	self.ACP.OnSelectedSection = ::ACP_OnSelectedSection;
	
	self ACP_Show();
}

ACP_BuildMenu()
{
	self ACP_AddButton( ACP_SECTION_MAPS, "Round Restart", scripts\acp\_acpMaps::RoundRestart );
	self ACP_AddButton( ACP_SECTION_MAPS, "Map Restart", scripts\acp\_acpMaps::MapRestart );
	self ACP_AddButton( ACP_SECTION_MAPS, "End Round", scripts\acp\_acpMaps::EndRound );
	self ACP_AddButton( ACP_SECTION_MAPS, "End Map", scripts\acp\_acpMaps::EndMap );
	self ACP_AddButton( ACP_SECTION_MAPS, "Run Map", scripts\acp\_acpMaps::RunMap );
	
	self ACP_AddButton( ACP_SECTION_PLAYERS, "Kill", scripts\acp\_acpPlayers::Kill );
	
	self ACP_AddButton( ACP_SECTION_OTHERS, "Hide/Show ME", scripts\acp\_acpOthers::HideShow );
		
	self scripts\acp\_acpOthers::UpdateSelfInfo();
}

ACP_OnSelectedSection( section )
{
	if( section == ACP_SECTION_MAPS )
		self scripts\acp\_acpMaps::OnSelectedSection();
	else if( section == ACP_SECTION_PLAYERS )
		self scripts\acp\_acpPlayers::OnSelectedSection();
	else if( section == ACP_SECTION_OTHERS )
		self scripts\acp\_acpOthers::OnSelectedSection();
}