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
#include scripts\include\_quickVoting;
#include scripts\include\_main;

Init()
{
	AddCallback( level, "onMenuResponse", ::OnMenuResponse );
}

OnMenuResponse( player, menu, response )
{
	switch( response )
	{
		case "VOTE_endMap":
		case "VOTE_addBots":
			break;
		default:
			return;
	}
	
	player CloseMenu();
	player CloseInGameMenu();
	
	if( !IsDefined( level.LastQuickVoteTime ) || GetTime() - level.LastQuickVoteTime > 0 )
	{
		level.LastQuickVoteTime = GetTime() + level.Dvars["qVote_time"] + level.Dvars["qVote_delay"];
		StartVoting( response );
	}
	else
	{
		player IPrintLnBold( "Please waiting" );
	}
}

StartVoting( response )
{
	switch( response )
	{
		case "VOTE_endMap":
			thread QV( "Do you want to end map?", level.Dvars["qVote_time"], ::OnEndMap, undefined );
			return;
		case "VOTE_addBots":
			thread QV( "Do you want to add bots?", level.Dvars["qVote_time"], ::OnAddBots, undefined );
			return;
		default:
			PrintError( "Unknown VOTE string '" + response + "'" );
			return;
	}
}

OnEndMap()
{
	[[level.PreEndMap]]( undefined, undefined, "Voting success" );
	[[level.EndMap]]();
}

OnAddBots()
{
	IPrintLnBold( "Adding bots" );
	scripts\ai\_ai::AddBots();
}