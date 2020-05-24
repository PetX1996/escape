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

RegisterSpawnPoints( team, keyValue, keyName, dropToGround )
{
	if( !IsDefined( level.spawns[team] ) )
		level.spawns[team] = [];
		
	spawnPoints = GetEntArray( keyValue, keyName );
	foreach( spawnPoint in spawnPoints )
	{
		if( dropToGround )
			spawnPoint PlaceSpawnPoint();
			
		level.spawns[team][level.spawns[team].size] = spawnPoint;
	}
}

CheckSpawnPoints( team )
{
	if( level.spawns[team].size == 0 )
	{
		level.spawns[team] = [];
		level.spawns[team][0] = SpawnStruct();
		level.spawns[team][0].origin = ( 0,0,0 );
		level.spawns[team][0].angles = ( 0,0,0 );
		MapError( "Spawns - Could not load any spawnPoints for \'" + team + "\', gameType \'" + level.gametype + "\'" );
	}
}

private DISTFROMSPAWN_MIN = 64;
IsSpawnPointFree( spawnPoint )
{
	foreach( player in level.players )
	{
		if( !IsAlive( player ) || player.pers["team"] == "spectator" )
			continue;
		
		if( Distance( spawnPoint.origin, player.origin ) < DISTFROMSPAWN_MIN )
			return false;
	}
	return true;
}

GetRandomFreeSpawnPoint( spawnPoints )
{
	startIndex = RandomInt( spawnPoints.size );
	i = startIndex;
	do
	{
		if( IsSpawnPointFree( spawnPoints[i] ) )
			return spawnPoints[i];
		
		i = (i + spawnPoints.size + 1) % spawnPoints.size;
	}
	while( i != startIndex );
	
	return spawnPoints[ RandomInt( spawnPoints.size ) ];
}