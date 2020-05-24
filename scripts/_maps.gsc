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

#include scripts\include\_string;
#include scripts\include\_main;
#include scripts\include\_array;

init()
{
	InitCurrentMap();
	
	level.PreEndRound = ::PreEndRound;
	level.EndRound = ::EndRound;
	level.PostEndRound = ::PostEndRound;
	
	level.PreEndMap = ::PreEndMap;
	level.EndMap = ::EndMap;
	level.PostEndMap = ::PostEndMap;
}

InitCurrentMap()
{
	gameType = scripts\_mapVoting::GameTypeToFullName( level.gametype );
	SetDvar( "ui_gameTypeFullName", gameType );
	
	mapListSize = mp\_mapList::GetMapsCount();
	for( i = 0; i < mapListSize; i++ )
	{
		map = mp\_mapList::GetMapForIndex( i );
		if( map.Name == level.script )
		{
			SetDvar( "ui_mapFullName", map.FullName );
			return;
		}
	}
	SetDvar( "ui_mapFullName", level.script );
}

// PreEndRound()
// 	- stanovenie premenných, zahájenie konca
//
// EndRound( team, player, reason )
// 	- ukonèujúca obrazovka
//
// PostEndRound()
// 	- rozhodnutie o ïalšom pokraèovaní, nové kolo alebo mapa?

// PreEndMap( team, player, reason )
// 	- ukonèovanie mapy, kontrola skonèenia kola
//
// EndMap()
// 	- spustenie votingu alebo rotácie?
//
// PostEndMap( map, gametype )
// 	- spustenie konkrétnej mapy

PreEndRound()
{
	if( IsDefined( level.GameEnded ) )
		return false;

	level.GameEnded = true;
	return true;
}

EndRound( team, player, reason )
{
	if( !PreEndRound() )
		return;

	if( IsDefined( team ) )
	{
		team = GetTeamString( team );
		IPrintLnBold( "^1"+team+" ^7win!" );
	}
	else if( IsDefined( reason ) )
	{
		IPrintLnBold( reason );
	}
	else
	{
		IPrintLnBold( "Round ended!" );
	}
	
	wait 5;
}

PostEndRound()
{
	game["rounds"]++;
	
	if( game["rounds"] <= level.dvars["logic_roundLimit"] )
		FastRestart();
	else
		EndMap();
}

PreEndMap( team, player, reason )
{
	EndRound( team, player, reason );
}

EndMap()
{
	if( level.dvars["logic_mapVoting"] )
		thread scripts\_mapvoting::StartVoting();
	else
		thread MapRotation();
}

PostEndMap( map, gametype )
{
	SetDvar( "sv_mapRotationCurrent", "gametype " + gametype + " map " + map );
	ExitLevel( false );
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FastRestart()
{
	Map_restart( true );
}

MapRotation()
{
	index = GetDvarInt( "mapRotationCache" );
	index++;
	
	if( index >= mp\_mapList::GetMapsCount() )
		index = 0;
		
	SetDvar( "mapRotationCache", index );
	newMap = mp\_mapList::GetMapForIndex( index );
	PostEndMap( newMap.Name, newMap.GameTypes[ RandomInt( newMap.GameTypes.size ) ] );
}

/////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////// MAP ERRORS ///////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/*MapErrors()
{
	if( !level.dvars["developer"] )
		return;
	
	if( !isDefined( level.MapErrors ) || !level.MapErrors.size )
		return;
		
	self endon( "disconnect" );
		
	OpenDevTool( "^3MapErrors list", undefined, ::OnCloseMapErrors );
	
	for( i = 0;i < level.MapErrors.size;i++ )
	{
		error = level.MapErrors[i];
		
		self iprintln( "[^1MapError^7] "+error );
		SetTextLine( i+2, error );
	}
	
	ApplyTextLines();
	
	self waittill( "MapErrors close" );
}

OnCloseMapErrors()
{
	self notify( "MapErrors close" );
}*/