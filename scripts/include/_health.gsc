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

// TODO: podivné chovanie u trigger_damage!!

///
/// HEALTH( health )
///
/// HEALTH_EnableFlag( flag )
/// HEALTH_DisableFlag( flag )
///
/// HEALTH_Start()
///
/// HEALTH_Dispose()
///

#include scripts\include\_event;
#include scripts\include\_main;

// iDFlags
private HEALTH_FLAG_NODESTRUCTIBLE = 1;
private HEALTH_FLAG_NODELETE = 2;
private HEALTH_FLAG_NOMODIFY = 4;
private HEALTH_FLAG_NOPROGRESS = 8;

///
/// Pridá novú znièite¾nú entitu
///
HEALTH( health )
{
	switch( self.className )
	{
		case "script_brushmodel":
		case "script_model":
			self SetCanDamage( true );
			break;
		case "trigger_damage":
			//self SetCanDamage( true );
			break;
		default:
			PrintError( __FILE__, __FUNCTIONFULL__, "entity do not have a valid classname" );
			return;
	}
	
	self.maxHealth = health;
	self.health = health;
	self.EntityDamageFlags = 0;
	PrintDebug("hp:"+health+" second: "+self.health);
}
///
/// Upraví vlastnosti entity
///
HEALTH_EnableFlag( flag )
{
	self.EntityDamageFlags |= flag;
}
HEALTH_DisableFlag( flag )
{
	self.EntityDamageFlags &= ~flag;
}
HEALTH_Start()
{
	self thread HEALTH_CheckDamage();
}
///
/// Monitoruje damage
///
HEALTH_CheckDamage()
{
	while( true )
	{
		PrintDebug("^1hp: "+self.health);
		self waittill( "damage", iDamage, attacker, vDir, vPoint, sMeansOfDeath, modelName, tagName, partName, iDFlags );
		PrintDebug("^1hp: "+self.health + " ammount: "+iDamage);
		
		//PrintDebug( "damage!" );
		
		if( self.EntityDamageFlags & HEALTH_FLAG_NODESTRUCTIBLE )
			self HEALTH_Dispose();
			
		sWeapon = undefined;
		if( IsPlayer( attacker ) )
			sWeapon = attacker GetCurrentWeapon();
		
		// callbacks
		self.EntityDamage = SpawnStruct();
		self.EntityDamage.iDamage = iDamage;
		self.EntityDamage.attacker = attacker;
		self.EntityDamage.sWeapon = sWeapon;
		self.EntityDamage.vDir = vDir;
		self.EntityDamage.vPoint = vPoint;
		self.EntityDamage.sMeansOfDeath = sMeansOfDeath;
		self.EntityDamage.modelName = modelName;
		self.EntityDamage.tagName = tagName;
		self.EntityDamage.partName = partName;
		self.EntityDamage.iDFlags = iDFlags;
		
		// modify damage by class
		if( !(self.EntityDamageFlags & HEALTH_FLAG_NOMODIFY) )
			self scripts\class\_spawn::ModifyEntityDamage();
		
		scripts\_events::RunCallback( level, "HEALTH_entityDamage", 0, self );
		scripts\_events::RunCallback( self, "HEALTH_entityDamage", 0 );

		iDamage = self.EntityDamage.iDamage;
		attacker = self.EntityDamage.attacker;	
		
		if( !IsDefined( iDamage ) || iDamage < 1 )
		{
			self.EntityDamage = undefined;
			continue;
		}
		
		self.health -= iDamage;
		if( self.health < 0 )
			self.health = 0;
		
		iprintln("hp: "+self.health + " ammount: "+self.EntityDamage.iDamage);
		if( IsPlayer( attacker ) )
		{
			attacker scripts\clients\_damagefeedback::UpdateDamageFeedback();
			
			if( !(self.EntityDamageFlags & HEALTH_FLAG_NOPROGRESS) )
				attacker scripts\clients\_hud::UpdateTopProgressBar( (1 - ( self.health/self.maxHealth )) * 100, 1 );
		}
		
		if( self.health == 0 )
		{
			self notify( "delete" );
			
			scripts\_events::RunCallback( level, "HEALTH_entityDelete", 0, self );
			scripts\_events::RunCallback( self, "HEALTH_entityDelete", 0 );
			
			if( IsDefined( self ) && !(self.EntityDamageFlags & HEALTH_FLAG_NODELETE) )
				self Delete();
			
			self.EntityDamage = undefined;
			return;
		}
		
		self.EntityDamage = undefined;
	}
}

HEALTH_Dispose()
{
	if( self.ClassName != "trigger_damage" )
		self SetCanDamage( false );
		
	self.EntityDamage = undefined;
	self.EntityDamageFlags = undefined;
	
	DeleteCallback( self, "HEALTH_entityDamage" );
	DeleteCallback( self, "HEALTH_entityDelete" );
}