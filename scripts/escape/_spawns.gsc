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

#include scripts\include\_spawn;
#include scripts\include\_shape;

init()
{
	level.GT_SpawnPlayer = ::ModifySpawnInfo;
	BuildSpawnSystem();
}

BuildSpawnSystem()
{
	// === START SPAWNS ===
	RegisterSpawnPoints( "allies", "escape_spawns_humans", "classname", true );
	CheckSpawnPoints( "allies" );
	
	RegisterSpawnPoints( "axis", "escape_spawns_monsters", "classname", true );
	//CheckSpawnPoints( "axis" );
}
	
ModifySpawnInfo()
{
	spawnPoint = GetSpawnPoint( self.pers["team"] );
	if( IsDefined( spawnPoint ) )
	{
		self.SpawnPlayer.origin = spawnPoint.origin;
		self.SpawnPlayer.angles = spawnPoint.angles;
	}
}

GetSpawnPoint( team )
{
	spawnPoint = undefined;

	if( team == "allies" )
	{
		spawnPoint = GetRandomFreeSpawnPoint( level.Spawns["allies"] );
	}
	else
	{
		progress = level.CHECKPOINT.LastMonstersI;
		if( progress == -1 ) //zaèiatok hry
		{
			if( level.Spawns["axis"].size )
				spawnPoint = GetRandomFreeSpawnPoint( level.Spawns["axis"] );
			else
				spawnPoint = GetRandomFreeSpawnPoint( level.Spawns["allies"] );
		}
		else //checkpoint system
		{
			if( level.CHECKPOINT.Triggers[progress].BigSpawns.size )
			{
				if( RandomInt( 3 ) == 0 && level.CHECKPOINT.Triggers[progress].Spawns.size )
				{
					spawnPoint = GetRandomFreeSpawnPoint( level.CHECKPOINT.Triggers[progress].Spawns );
				}
				else
				{
					spawnPoint = GetBigSpawnPosition( level.CHECKPOINT.Triggers[progress].BigSpawns[RandomInt( level.CHECKPOINT.Triggers[progress].BigSpawns.size )] );
				}
			}
			else
			{
				for(p = progress;p >= -1;p--)
				{
					if( p == -1 )
					{
						if( level.Spawns["axis"].size )
							spawnPoint = GetRandomFreeSpawnPoint( level.Spawns["axis"] );
						else
							spawnPoint = GetRandomFreeSpawnPoint( level.Spawns["allies"] );
							
						break;
					}
					else if( level.CHECKPOINT.Triggers[progress].Spawns.size )
					{
						spawnPoint = GetRandomFreeSpawnPoint( level.CHECKPOINT.Triggers[progress].Spawns );
						break;
					}
				}
			}
		}
	}
	return spawnPoint;
}

GetBigSpawnPosition( ent )
{
	origin = SHAPE_GetRandomPointInCylinder( ent.origin, ent.radius, 0 );
	
	SpawnPoint = SpawnStruct();
	SpawnPoint.origin = origin;
	SpawnPoint.angles = ent.angles;
	
	return SpawnPoint;
}