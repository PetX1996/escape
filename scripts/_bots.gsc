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

init()
{
	thread MonitorDvar();
}

MonitorDvar()
{
	level.BotsCount = 0;
	
	while( true )
	{
		wait 1;
		dvar = GetDvarInt( "scr_testclients" );
		
		if( dvar == 0 )
			continue;
			
		if( level.BotsCount == dvar )
			continue;
		
		for( i = 0;i < dvar-level.BotsCount;i++ )
		{
			AddBot();
		}
	}
}

AddBot()
{
	bot = addtestclient();

	if( !isDefined( bot ) ) 
	{
		PrintDebug( "Could not add test client" );
		SetDvar( "scr_testclients", level.BotsCount );
		return;
	}
		
	level.BotsCount++;
	bot.pers["isBot"] = true;

	bot thread ConnectToTeam();
}

ConnectToTeam()
{
	self endon( "disconnect" );

	self waittill( "connect" );
	//self scripts\class\_changeclass::AutoSelectClass( "allies", 0 );
	//self scripts\class\_changeclass::AutoSelectClass( "axis", 0 );
	self thread [[level.AutoAssign]]();
	
	while( true )
	{
		self waittill( "spawned_player" );
		
		self FreezeControls( true );
	}
}