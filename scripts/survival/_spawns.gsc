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

init()
{
	level.GT_SpawnPlayer = ::ModifySpawnInfo;
	BuildSpawnSystem();
}

BuildSpawnSystem()
{
	// === START SPAWNS ===
	RegisterSpawnPoints( "allies", "mp_tdm_spawn_allies_start", "classname", true );
	CheckSpawnPoints( "allies" );
	
	RegisterSpawnPoints( "axis", "mp_tdm_spawn", "classname", true );
	CheckSpawnPoints( "axis" );
}

ModifySpawnInfo()
{
	spawnPoint = GetRandomFreeSpawnPoint( level.spawns[self.pers["team"]] );
	self.SpawnPlayer.origin = spawnPoint.origin;
	self.SpawnPlayer.angles = spawnPoint.angles;
}