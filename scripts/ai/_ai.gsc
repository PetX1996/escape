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

private AI_COUNT = 30;
private AI_MAXPLAYERS = 5;

Init()
{
}

AddBots()
{
	level.AI_Allowed = true;
	level.AI_Field = [];
	MonitorBots( AI_COUNT );
}

MonitorBots( count )
{
	while( IsDefined( level.AI_Allowed ) )
	{
		if( level.players.size >= AI_MAXPLAYERS )
		{
			RemoveBots();
			return;
		}
		
		if( level.AI_Field.size < count )
		{
			AddBot();
			PrintDebug( "Bots " + level.AI_Field.size + "/" + count );
		}
		
		wait 1;
	}
}

AddBot()
{
	spawnPoint = level.Spawns["axis"][RandomInt( level.Spawns["axis"].size )];
	scripts\ai\_aiEntity::AI( spawnPoint.origin, spawnPoint.angles );
}

RemoveBots()
{
	level.AI_Allowed = undefined;
	
	while( level.AI_Field.size > 0 )
		scripts\ai\_aiEntity::AI_Delete();
		
	level.AI_Field = undefined;
}