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
	BuildSpawnSystem();
	level.GT_SpawnPlayer = ::GetSpawnPoint;
}

BuildSpawnSystem()
{
	// === SPECTATOR ===
	RegisterSpawnPoints( "spectator", "escape_spawns_spectator", "classname", false );
	RegisterSpawnPoints( "spectator", "mp_global_intermission", "classname", false );
	CheckSpawnPoints( "spectator" );
}

GetSpawnPoint()
{}