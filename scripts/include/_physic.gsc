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

/// PHYSIC_DropToGround( addOffsetZ )

#include scripts\include\_math;

///
///	Pustí predmet vo¾ným pádom na zem.
///
PHYSIC_DropToGround( addOffsetZ )
{
	trace = BulletTrace( self.origin, self.origin+(0,0,-100000), false, self );
	
	if( IsDefined( trace ) && IsDefined( trace["position"] ) )
	{
		if( !IsDefined( addOffsetZ ) )
			addOffsetZ = 0;

		self.origin = trace["position"] + ( 0, 0, addOffsetZ );
	}
}
