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
{}

OnGivePerk()
{
	AddCallback( self, "onGiveWeapon", ::AddMaxAmmo );
	AddCallback( self, "restoreAmmo", ::AddMaxAmmo );
	AddCallback( self, "onPlayerKilled", ::Dispose );
}

AddMaxAmmo( newWeapon )
{
	self GiveMaxAmmo( newWeapon );
}

Dispose( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	DeleteCallback( self, "onGiveWeapon", ::AddMaxAmmo );
	DeleteCallback( self, "restoreAmmo", ::AddMaxAmmo );
	DeleteCallback( self, "onPlayerKilled", ::Dispose );
}