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

// TODO: dotiahnuù!
// TODO: presun˙ù z weapons.gsc sem

PreCache()
{
	PreCacheItem( "c4_mp" );
}

OnGiveEquipment( name )
{
	self GiveWeapon( "c4_mp" );
	self scripts\shop\_equipment::SetEquipmentInfo( name, self GetAmmoCount( "c4_mp" ), "weapon", "c4_mp" );
	
	AddCallback( self, "onPlayerKilled", ::Dispose );
	AddCallback( self, "end_firing", ::OnEndFiring );
}

OnEndFiring( weapon )
{
	if( weapon != "c4_mp" )
		return;
		
	self scripts\shop\_equipment::UpdateEquipmentInfo( self GetAmmoCount( "c4_mp" ) );
}

Dispose( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	DeleteCallback( self, "end_firing", ::OnEndFiring );
	DeleteCallback( self, "onPlayerKilled", ::Dispose );
}