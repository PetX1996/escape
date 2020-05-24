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

//#include scripts\include\_event;

init()
{
	//AddCallback( level, "connected", ::OnPlayerConnected );
}

OnPlayerConnected()
{
	self thread CheckButtons();
}

CheckButtons()
{
	wait 0.05;

	while( IsDefined( self ) )
	{
		if( self AttackButtonPressed() )
		{
			scripts\_events::RunCallback( level, "AttackButtonPressed", 1, self );
			scripts\_events::RunCallback( self, "AttackButtonPressed", 1 );
			
			if( self.pers["team"] == "axis" && IsAlive( self ) && ( !IsDefined( self.lastKnifed ) || GetTime()-self.lastKnifed >= 1000 ) )
			{
				self.lastKnifed = GetTime();
				self [[level.SendCMD]]( "+melee; wait 0.01; -melee" );
			}
		}
		if( self UseButtonPressed() )
		{
			scripts\_events::RunCallback( level, "UseButtonPressed", 1, self );
			scripts\_events::RunCallback( self, "UseButtonPressed", 1 );
		}
		if( self MeleeButtonPressed() )
		{
			scripts\_events::RunCallback( level, "MeleeButtonPressed", 1, self );
			scripts\_events::RunCallback( self, "MeleeButtonPressed", 1 );
		}
		
		wait 0.05;
	}
}