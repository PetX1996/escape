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

#include scripts\include\_main;

/// Fáza èakania na viac hráèov
LOGIC_WaitingForMorePlayers( playersCount )
{
	while( true )
	{
		wait 1;
	
		if( LOGIC_CheckPlayersCount( playersCount ) )
			return true;
			
		LOGIC_UpdatePlayersHud( undefined, "Waiting for more players" );
	}
}

/// Zkontroluje poèet hráèov potrebných pre štart hry.
LOGIC_CheckPlayersCount( playersCount )
{
	if( GetAllAlivePlayers().size >= playersCount )
		return true;

	return false;
}

/// Fáza odpoèítavania do zaèiatku kola.
LOGIC_CreatePreMatchTimer( time )
{
	if( time == 0 )
		return;
	
	endTime = GetTime()+(time*1000);
	
	while( GetTime() < endTime )
	{
		LOGIC_UpdatePlayersHud( undefined, "Waiting to start round", (endTime-GetTime())/1000, 160 );
		wait 0.1;
	}
}

/// Vybratie potrebného poètu monštier.
LOGIC_PickMonsters( multiplicator )
{
	players = GetAllAlivePlayers();
	
	if( players.size <= 1 )
		return;
	
	count = Int( players.size*multiplicator );
	
	if( count < 1 )
		count = 1;
	
	for( i = 0; i < count; i++ )
		LOGIC_PickMonster();
}
/// Vybratie konkrétneho monštra.
LOGIC_PickMonster()
{
	monster = undefined;
	players = GetAllAlivePlayers( "allies" );
	if( players.size <= 0 )
		return;
	
	level.PickMonsters = true;
	
	if( ( level.dvars["logic_pickSystem"] == "mix" && RandomInt( 3 ) ) || level.dvars["logic_pickSystem"] == "gradually" )
	{
		temp = 99999;
		for( i = 0; i < players.size; i++ )
		{
			player = players[i];
			
			if( player.pers["MonsterPicked"] / player.pers["RoundsPlayed"] <= temp )
			{
				temp = player.pers["MonsterPicked"] / player.pers["RoundsPlayed"];
				monster = player;
			}
		}
	}
	else if( level.dvars["logic_pickSystem"] == "mix" || level.dvars["logic_pickSystem"] == "random" )
	{
		monster = players[ RandomInt( players.size ) ];
	}
	
	if( IsDefined( monster ) )
	{
		IPrintLnBold( "Player ^1"+ monster.name +"^7 was chosen as a monster." );
		monster thread [[level.Axis]]();
		monster.pers["MonsterPicked"]++;
	}
}

/// Fáza zaèiatku kola pre ¾udí.
LOGIC_CreateHumansTimer( time )
{
	while( true )
	{
		if( time == 0 )
			break;
	
		endTime = GetTime()+(time*1000);
		while( GetTime() < endTime )
		{
			LOGIC_UpdatePlayersHud( "allies", "Start in", (endTime-GetTime())/1000, 80 );
			wait 0.1;
		}
		
		break;
	}
	
	LOGIC_FreezeAllPlayers( false, "allies" );
	LOGIC_UpdateStatus( "playing", "allies" );
	level notify( "end_prematch" );
}

/// Fáza zaèiatku kola pre monštrá.
LOGIC_CreateMonstersTimer( time )
{
	while( true )
	{
		if( time == 0 )
			break;
	
		endTime = GetTime()+(time*1000);
		while( GetTime() < endTime )
		{
			LOGIC_UpdatePlayersHud( "axis", "Start in", (endTime-GetTime())/1000, 80 );
			wait 0.1;
		}
	
		break;
	}
	
	LOGIC_FreezeAllPlayers( false, "axis" );
	LOGIC_UpdateStatus( "playing", "axis" );
	level notify( "end_prematch" );
}

/// Posielanie aktuálneho stavu logiky clientom.
LOGIC_UpdatePlayersHud( team, text, time, size )
{
	players = GetAllAlivePlayers( team );
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		
		if( IsDefined( player.GameLogicHud ) && player.GameLogicHud == text )
			continue;
			
		player.GameLogicHud = text;
		
		if( IsDefined( time ) )
			player scripts\clients\_hud::SetLowerTextAndTimer( text, time, size );
		else
			player scripts\clients\_hud::SetLowerText( text );
	}
}

/// Zmrazenie všetkých hráèov.
LOGIC_FreezeAllPlayers( state, team )
{
	players = GetAllAlivePlayers( team );
	for( i = 0; i < players.size; i++ )
	{
		players[i] FreezeMove( state );
		
		if( state )
			players[i] DisableWeapons();
		else
			players[i] EnableWeapons();
	}
}

//Time system
LOGIC_PrepareTimer()
{
	level.TimeLimit = level.dvars["logic_timeLimit"];
	
	SetGameEndTime( 0 );
}

LOGIC_StartTimer()
{	
	level.StartTimerTime = GetTime();
	level.EndMapTime = Int( GetTime() + ( ( level.TimeLimit * 60 ) * 1000 ) );
	
	SetGameEndTime( level.EndMapTime );
}

/// Vráti èas zostávajúci do konca kola v milisekundách.
LOGIC_GetTimeRemaining()
{
	if( IsDefined( level.StartTimerTime ) )
		return Int( level.EndMapTime - GetTime() );
	else
		return Int( ( level.TimeLimit * 60 ) * 1000 ); 
}

//Player counter
LOGIC_PlayerCounter()
{
	allies = GetAllAlivePlayers( "allies" ).size;
	axis = GetAllAlivePlayers( "axis" ).size;
	dvars = [];
	
	if( !IsDefined( level.COUNTER_allies ) || !IsDefined( level.COUNTER_axis ) )
	{
		level.COUNTER_allies = -1;
		level.COUNTER_axis = -1;
	}
	
	if( level.COUNTER_allies != allies )
	{
		level.COUNTER_allies = allies;
		dvars["hud_count_allies"] = allies;
	}
	
	if( level.COUNTER_axis != axis )
	{
		level.COUNTER_axis = axis;
		dvars["hud_count_axis"] = axis;
	}
	
	if( dvars.size )
	{
		for( i = 0; i < level.players.size; i++ )
			level.players[i] thread [[level.SendCvar]]( dvars );
	}
}

LOGIC_StartMap()
{
	VisionSetNaked( level.script, 5 );
	DvarSendAllPlayers( "ui_show_hud", 1 );
	DvarSendAllPlayers( "ui_allow_monsters", 1 );
	AmbientPlay( level.MapSettings["AmbientTrack"], 5 );
}

LOGIC_StartRound()
{
	level.roundStarted = true;
	level notify( "start_round" );
	scripts\_events::RunCallback( level, "onStartRound", 1 );
}

LOGIC_UpdateStatus( status, team )
{
	if( IsDefined( team ) )
		level.gameState[team] = status;
	else
	{
		level.gameState["allies"] = status;
		level.gameState["axis"] = status;
	}
}