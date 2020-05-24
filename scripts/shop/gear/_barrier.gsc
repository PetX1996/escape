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
#include scripts\include\_interactive;
#include scripts\include\_health;

PreCache()
{
	PreCacheModel( "bc_hesco_barrier_sm" );
	//PreCacheItem( "remington700_mp" );
}

OnGiveGear( name )
{
	self scripts\shop\_gear::SetGearInfo( name, 1 );
	
	AddCallback( self, "onPlayerKilled", ::Dispose );
	AddCallback( self, "gearButton", ::OnButtonPressed );
}

OnButtonPressed()
{
	self scripts\shop\_gear::UpdateGearInfo( 0 );
	
	barrier = Spawn( "script_model", self.origin );
	barrier SetModel( "bc_hesco_barrier_sm" );
	
	barrier = IA( barrier );
	barrier IA_EnableFlag( IA_FLAGS_NOGRAB );
	barrier IA_EnableFlag( IA_FLAGS_DROPTOGROUND );
	barrier IA_SetCollisions( true, 18, 50 );
	barrier IA_PlayerObject( self );
	
	AddCallback( barrier, "IA_placedOnGround", ::CreateTrigger );
	
	// dispose
	DeleteCallback( self, "gearButton", ::OnButtonPressed );
	DeleteCallback( self, "onPlayerKilled", ::Dispose );
}

Dispose( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	DeleteCallback( self, "gearButton", ::OnButtonPressed );
	DeleteCallback( self, "onPlayerKilled", ::Dispose );
}

CreateTrigger( player )
{
	DeleteCallback( self, "IA_placedOnGround", ::CreateTrigger );
	
	self.trigger = Spawn( "trigger_radius", self.origin, 0, 16, 50 );
	self.trigger SetContents( 1 );
	
	self HEALTH( 1000 );
	self HEALTH_Start();
	AddCallback( self, "entityHealthDelete", ::OnDestroy );
}

OnDestroy()
{
	self DeleteCallback( self, "entityHealthDelete", ::OnDestroy );
	self.trigger Delete();
}