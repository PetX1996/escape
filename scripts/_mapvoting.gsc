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

#include scripts\include\_array;
#include scripts\include\_event;
#include scripts\include\_voting;

private MV_INI_MAPSCACHESIZE =1;
private MV_INI_MAPSCOUNT = 4;
private MV_INI_MAPTIME = 15;
private MV_INI_GAMETYPETIME = 10;
private MV_INI_SPACETIME = 2;
private MV_INI_ENDTIME = 5;

init()
{
}

StartVoting()
{
	level.mapVoting = SpawnStruct();
	MapVoting();
}

MapVoting()
{
	level.mapVoting.MapsIndexCache = [];
	level.mapVoting.MapsIndex = [];
	level.mapVoting.Maps = [];
	
	GetRandomMaps();
	mapNames = [];
	
	for( i = 0; i < level.mapVoting.Maps.size; i++ )
		mapNames[mapNames.size] = level.mapVoting.Maps[i].FullName;
	
	defaultGameType = "";
	if( level.mapVoting.Maps[0].GameTypes.size == 1 ) defaultGameType = GameTypeToFullName( level.mapVoting.Maps[0].GameTypes[0] );
	
	VOTING();
	winner = VOTING_Start( mapNames, MV_INI_MAPTIME, mapNames[0], defaultGameType, ::MapVoting_OnChangeWinner );
	level.mapVoting.NextMap = GetMapForFullName( winner );
	
	WriteMapIndexToCache( GetMapListIndexForMap( level.mapVoting.NextMap ) );
	
	if( level.mapVoting.NextMap.GameTypes.size > 1 )
		GameTypeVoting();
	else
	{
		level.mapVoting.NextGameType = level.mapVoting.NextMap.GameTypes[0];
		EndVoting();
	}
}

MapVoting_OnChangeWinner( winner )
{
	VOTING_SetTitle( winner );
	
	map = GetMapForFullName( winner );
	if( map.GameTypes.size == 1 )
		VOTING_SetSubTitle( GameTypeToFullName( map.GameTypes[0] ) );
	else
		VOTING_SetSubTitle( "" );
}

GameTypeVoting()
{
	VOTING_Clear();
	VOTING_SetTitle( level.mapVoting.NextMap.FullName );
	VOTING_Refresh();
	
	wait MV_INI_SPACETIME;
	
	gameTypeNames = [];
	for( i = 0; i < level.mapVoting.NextMap.GameTypes.size; i++ )
		gameTypeNames[gameTypeNames.size] = GameTypeToFullName( level.mapVoting.NextMap.GameTypes[i] );
	
	winner = VOTING_Start( gameTypeNames, MV_INI_GAMETYPETIME, level.mapVoting.NextMap.FullName, "", ::GameTypeVoting_OnChangeWinner );
	level.mapVoting.NextGameType = FullNameToGameType( winner );
	
	EndVoting();
}

GameTypeVoting_OnChangeWinner( winner )
{
	VOTING_SetSubTitle( winner );
}

EndVoting()
{
	VOTING_Clear();
	VOTING_SetTitle( level.mapVoting.NextMap.FullName );
	VOTING_SetSubTitle( GameTypeToFullName( level.mapVoting.NextGameType ) );
	VOTING_Refresh();
	
	wait MV_INI_ENDTIME;
	
	[[level.PostEndMap]]( level.mapVoting.NextMap.Name, level.mapVoting.NextGameType );
}

GetMapForFullName( fullName )
{
	for( i = 0; i < level.mapVoting.Maps.size; i++ )
	{
		if( level.mapVoting.Maps[i].FullName == fullName )
			return level.mapVoting.Maps[i];
	}
	return undefined;
}

GetMapListIndexForMap( map )
{
	for( i = 0; i < level.mapVoting.Maps.size; i++ )
	{
		if( level.mapVoting.Maps[i] == map )
			return level.mapVoting.MapsIndex[i];
	}
	return undefined;
}

FullNameToGameType( fullName )
{
	switch( fullName )
	{
		case "Escape":
			return "escape";
		case "Survival":
			return "survival";
		default:
			return "unknown";
	}
}

GameTypeToFullName( gameType )
{
	switch( gameType )
	{
		case "escape":
			return "Escape";
		case "survival":
			return "Survival";
		default:
			return "Unknown";
	}
}

GetRandomMaps()
{
	GetMapsIndexFromCache();
	mapListSize = mp\_mapList::GetMapsCount();
	currentServer = GetCurrentServer();
	
	tryCount = 0;
	while( true )
	{
		wait 0.001;
	
		tryCount++;
		if( tryCount > 50 )
			iprintln( "mapVoting.gsc error" );
	
		if( level.mapVoting.Maps.size >= MV_INI_MAPSCOUNT )
			return;
	
		randomMapIndex = RandomInt( mapListSize );
		
		if( ARRAY_Contains( level.mapVoting.MapsIndex, randomMapIndex ) )
			continue;
			
		if( ARRAY_Contains( level.mapVoting.MapsIndexCache, randomMapIndex ) )
			continue;
			
		map = mp\_mapList::GetMapForIndex( randomMapIndex );
			
		if( !ARRAY_Contains( map.Servers, currentServer ) )
			continue;
		
		size = level.mapVoting.Maps.size;
		level.mapVoting.Maps[size] = map;
		level.mapVoting.MapsIndex[size] = randomMapIndex;
	}
}

GetMapsIndexFromCache()
{
	dvar = GetDvar( "mapVotingCache" );
	
	if( dvar == "" )
		return;
		
	str = StrTok( dvar, ";" );
	for( i = 0; i < str.size; i++ )
	{
		mapI = str[i];
		
		if( mapI == "" )
			continue;
			
		size = level.mapVoting.MapsIndexCache.size;
		level.mapVoting.MapsIndexCache[size] = Int( mapI );
	}
}

WriteMapIndexToCache( mapListIndex )
{
	if( level.mapVoting.MapsIndexCache.size >= MV_INI_MAPSCACHESIZE && level.mapVoting.MapsIndexCache.size )
		level.mapVoting.MapsIndexCache = ARRAY_RemoveAt( level.mapVoting.MapsIndexCache, 0 );
	
	dvar = "";
	for( i = 0; i < level.mapVoting.MapsIndexCache.size; i++ )
		dvar += level.mapVoting.MapsIndexCache[i] + ";";
	
	dvar += mapListIndex;
	SetDvar( "mapVotingCache", dvar );
}


GetCurrentServer()
{
	ip = GetDvar( "net_ip" );
	port = GetDvar( "net_port" );
	
	return ip+":"+port;
}