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

init()
{
	AddCallback( level, "onStartGameType", ::OnStartGameType );
}

OnStartGameType()
{
	scripts\escape\_checkpoints::init();
	scripts\escape\_logic::init();
	scripts\escape\_spawns::init();

	thread plugins\ends\_default::init( "escape_endmap_default" );
	thread plugins\ends\_none::init( "escape_endmap_none" );
	
	thread CheckMapName();
}

CheckMapName()
{
	wait 1;
	
	//mp_escape_<name>
	
	namePrefix = GetSubStr( level.script, 0, 10 );
	if( namePrefix != "mp_escape_" )
	{
		LogPrint( "ERROR: "+level.script+" is not a valid map name. Map name must be mp_escape_<name>\n" );
		SetDvar( "sv_mapRotationCurrent", "gametype survival map mp_backlot" );
		ExitLevel( false );
		return;				
	}
}