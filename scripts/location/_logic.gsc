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
#include scripts\include\_event;
#include scripts\include\_main;

init()
{
	thread StartLogic(); 
	AddCallback( level, "onElapsedRoundTime", ::MonitorGame );
}

StartLogic()
{
	if( level.dvars["developer"] || !level.dvars["logic"] )
		return;

	VisionSetNaked( "mpIntro", 0 );
	level.gameState["allies"] = "waiting";
	level.gameState["axis"] = "waiting";		
		
	wait 1;
	
	while( true )
	{
		LOGIC_WaitingForMorePlayers( level.dvars["logic_playersToStart"] );
		
		LOGIC_CreatePreMatchTimer( level.dvars["logic_preMatchStartTime"] );
		
		if( !LOGIC_CheckPlayersCount( level.dvars["logic_playersToStart"] ) )
			continue;
			
		break;
	}
	
	LOGIC_UpdateStatus( "prematch" );
	LOGIC_StartMap();
	//LOGIC_StartTimer();
	
	LOGIC_PickMonsters( level.dvars["logic_pickMonsters"] );
	
	thread LOGIC_CreateHumansTimer( level.dvars["logic_startHumansTime"] + level.dvars["logic_startHumansTimeAdd"] );
	thread LOGIC_CreateMonstersTimer( level.dvars["logic_startMonsterTime"] + level.dvars["logic_startMonsterTimeAdd"] );
	level waittill( "end_prematch" );
	
	LOGIC_StartRound();
	thread scripts\location\_locations::StartLocationsLogic();
}

MonitorGame()
{
	/*if( LOGIC_GetTimeRemaining() <= 0 ) //ubehol èas? koniec kola!
	{
		thread [[level.EndRound]]( "allies" );
		return;
	}*/
	
	if( level.COUNTER_allies <= 0 ) //žiadni ¾udia? koniec kola!
	{
		DeleteCallback( level, "onElapsedRoundTime", ::MonitorGame );
		[[level.EndRound]]( "axis" );
		[[level.PostEndRound]]();
		return;
	}
}