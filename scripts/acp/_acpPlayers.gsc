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

OnSelectedSection()
{
	self ACP_AddList( 0, ::UpdatePlayerList );
}

UpdatePlayerList( currentIndex, change )
{
	if( !IsDefined( level.players[currentIndex] ) )
		currentIndex = 0;
		
	self ACP_UpdateList( currentIndex, level.players[currentIndex].Name );
	self UpdatePlayerInfo( level.players[currentIndex] );
}

UpdatePlayerInfo( player )
{
	self ACP_SetText( "Name: "+player.Name );
	self ACP_SetText( "Team: "+GetTeamString( player.pers["team"] ) );
	self ACP_SetText( "Status: "+GetStatusString( IsAlive( player ), player.pers["team"] ) );
	self ACP_SetText( "Health: "+player.Health+"/"+player.MaxHealth );
	self ACP_SetText( "" );
	self ACP_SetText( "Money: "+player.pers["money"] );
	self ACP_SetText( "XP: "+player.pers["rankxp"] );
	self ACP_SetText( "Rank: "+(player.pers["rank"]+1) );
	self ACP_Refresh();
}

GetCurrentPlayer()
{
	player = level.players[self.ACP.ListIndex];
	if( !IsDefined( player ) )
	{
		self UpdatePlayerList( self.ACP.ListIndex, 1 );
		self ACP_POPUP_Notice( "Notice", "Player disconnected." );
		return undefined;
	}
	
	return player;
}

Kill()
{
	player = self GetCurrentPlayer();
	if( !IsDefined( player ) )
		return;
		
	player Suicide();
	player IPrintLnBold( "You were killed by ^1ADMIN" );
}