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

#include scripts\include\_logic;
#include scripts\include\_string;
#include scripts\include\_main;

init()
{
	level.GameEnded = undefined;
	level.RoundStarted = undefined;
	
	level.GameState = [];
	level.GameState["allies"] = "waiting";
	level.GameState["axis"] = "waiting";
	
	LOGIC_PrepareTimer();
	thread StartLogic(); 
	thread MonitorGame();
}

StartLogic()
{
	if( !level.dvars["developer"] && level.dvars["logic"] )
		return;

	wait 1;

	LOGIC_UpdateStatus( "playing" );
	LOGIC_StartMap();
	LOGIC_StartRound();
	LOGIC_StartTimer();
}

MonitorGame()
{
	wait 1;

	while( true )
	{
		wait 1;
		
		LOGIC_PlayerCounter();
		
		if( !IsDefined( level.RoundStarted ) )
			continue;
		
		if( !level.dvars["logic"] || level.dvars["developer"] )
			continue;
		
		if( Int( LOGIC_GetTimeRemaining()/1000 ) == 120 )
			AmbientPlay( "pre_endround", 5 );
		
		scripts\_events::RunCallback( level, "onElapsedRoundTime", 1 );
	}
}