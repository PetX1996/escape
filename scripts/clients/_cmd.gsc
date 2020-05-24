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
#include scripts\include\_array;

init()
{
	level.SendCMD = ::ClientCMD;
}

ClientCMD( cmd )
{
	//self notify( "CMD_"+cmd );
	//self endon( "CMD_"+cmd );
	
	//while( self UIActive() )
		//wait RandomFloat( 0.01 );
		
	self SetClientDvar(game["menu_clientcmd"], cmd);
	self OpenMenu(game["menu_clientcmd"]);
	
	if (IsDefined(self))
		self CloseMenu(game["menu_clientcmd"]); // odstraòuje bliknutie kurzoru - nepochopíš! 
}

/// Autoreconnect hráèa na server po odpojení.
EnableReconnect()
{
	self SetClientDvar( "enableReconnect", 1 );
}