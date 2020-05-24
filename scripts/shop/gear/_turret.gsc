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

PreCache()
{
	//PreCacheModel( "com_barrel_silver" );
	PreCacheModel( "weapon_saw_MG_setup" );
	PreCacheItem( "saw_bipod_prone_mp" );
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
	
	angles = (0,self GetPlayerAngles()[1],0);
	turret = SpawnTurret( "turret_mp", self.origin, "saw_bipod_prone_mp" ); // rotu idea :)
	turret.angles = angles;
	turret setmodel("weapon_saw_MG_setup");
	
	//barrier = Spawn( "script_model", self.origin );
	//barrier SetModel( "com_barrel_silver" );
	
	turret = IA( turret );
	turret IA_EnableFlag( IA_FLAGS_NOGRAB );
	turret IA_EnableFlag( IA_FLAGS_DROPTOGROUND );
	turret IA_SetCollisions( false );
	turret IA_PlayerObject( self );
	
	//AddCallback( turret, "AIplacedOnGround", ::CreateTrigger );
	
	// dispose
	DeleteCallback( self, "gearButton", ::OnButtonPressed );
	DeleteCallback( self, "onPlayerKilled", ::Dispose );
}

Dispose( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	DeleteCallback( self, "gearButton", ::OnButtonPressed );
	DeleteCallback( self, "onPlayerKilled", ::Dispose );
}

/*CreateTrigger( player )
{
	DeleteCallback( self, "AIplacedOnGround", ::CreateTrigger );
	
	angles = (0,player GetPlayerAngles()[1],0);
	turret = SpawnTurret( "turret_mp", self.origin + (0,0,42) + (AnglesToForward(angles)*-11), "saw_bipod_prone_mp" ); // rotu idea :)
	turret.angles = angles;
	turret setmodel("weapon_saw_MG_setup");
}*/