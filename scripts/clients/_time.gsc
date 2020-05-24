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

#include scripts\include\_event;

init()
{
	//AddCallback( level, "connected", ::OnConnected );
	AddCallback( level, "changeTeam", ::OnChangeTeam );
	AddCallback( level, "leaveGame", ::UpdatePlayerStat );
}

OnConnected( player )
{
	if( !IsDefined( player.pers["playedTime"] ) )
		player.pers["playedTime"] = maps\mp\gametypes\_persistence::StatGet( "TIME_PLAYED_TOTAL" );
	
	while( IsDefined( player ) )
	{
		player.pers["playedTime"]++;
	
		wait 1;
	}
}

OnChangeTeam( player, oldTeam, newTeam )
{
	UpdatePlayerStat( player );
}
UpdatePlayerStat( player )
{
	player maps\mp\gametypes\_persistence::StatSet( "TIME_PLAYED_TOTAL", player.pers["playedTime"] );
}

GetPlayedMinutes()
{
	return self.pers["playedTime"] / 60;
}