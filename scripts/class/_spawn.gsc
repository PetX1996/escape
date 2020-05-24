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

//#include scripts\include\_item;
#include scripts\include\_main;
#include scripts\include\_class;

private PRECACHE_MODEL = 0;
private PRECACHE_WEAPON = 1;

init()
{
	//PreCacheFromTable();
	
	//AddCallback( level, "playerDamage", ::ModifyWeaponDamage );
	//AddCallback( level, "entityHealthDamage", ::ModifyWeaponentityDamage );
}

PreCacheFromTable()
{
	for( teamI = 0; teamI < 2; teamI++ )
	{
		file = TABLE_FILE_ALLIES;
		if( teamI == 1 )
			file = TABLE_FILE_AXIS;
		
		for( TlineIndex = 0; TlineIndex < TABLE_ITEMS_COUNT; TlineIndex++ )
		{
			Ttype = TableLookUp( file, 0, TlineIndex, 1 );
			if( Ttype == "" )
				continue;
		
			PreCacheItemFromTable( file, Ttype, TlineIndex );
		}
	}
}
PreCacheItemFromTable( file, Ttype, TlineIndex )
{
	switch( Ttype )
	{
		case "Figure":
			PreCacheIfExists( file, TlineIndex, 8, PRECACHE_MODEL );
			PreCacheIfExists( file, TlineIndex, 9, PRECACHE_MODEL );
			PreCacheIfExists( file, TlineIndex, 10, PRECACHE_MODEL );
			break;
		case "Weapon":
			PreCacheIfExists( file, TlineIndex, 8, PRECACHE_WEAPON );
			break;
		default:
			break;
	}
}
PreCacheIfExists( file, TlineIndex, TvalueIndex, preCacheType )
{
	string = TableLookUp( file, 0, TlineIndex, TvalueIndex );
	if( string == "" )
		return;
	
	switch( preCacheType )
	{
		case PRECACHE_MODEL:
			PreCacheModel( string );
			break;
		case PRECACHE_WEAPON:
			PreCacheItem( string );
			break;
		default:
			break;
	}
}

ModifySpawnInfo()
{
	team = self.pers["team"];
	classIndex = self CLASS_GetSpawnClass( self.pers["team"] );
	file = CLASS_GetFileByTeam( team );
	
	figure = self CLASS_GetSlotItem( team, classIndex, 0 );
	weapon = self CLASS_GetSlotItem( team, classIndex, 1 );
	firstPerk = self CLASS_GetSlotItem( team, classIndex, 2 );
	secondPerk = self CLASS_GetSlotItem( team, classIndex, 3 );
	thirdPerk = self CLASS_GetSlotItem( team, classIndex, 4 );
	
	// FIGURE
	self.SpawnPlayer.bodyModel = TableLookUp( file, 0, figure, 8 );
	self.SpawnPlayer.headModel = TableLookUp( file, 0, figure, 9 );
	self.SpawnPlayer.viewModel = TableLookUp( file, 0, figure, 10 );
	
	self.SpawnPlayer.health = int( TableLookUp( file, 0, figure, 11 ) );
	self.SpawnPlayer.speed = int( TableLookUp( file, 0, figure, 12 ) );
	
	self.SpawnPlayer.figureFunction = TableLookUp( file, 0, figure, 13 );
	self.SpawnPlayer.specialAbility = TableLookUp( file, 0, figure, 14 );
	
	// WEAPON
	self.SpawnPlayer.secondaryWeapon = TableLookUp( file, 0, weapon, 8 );
	if( team == "axis" )
	{
		self.SpawnPlayer.knifeDamage = int( TableLookUp( file, 0, weapon, 9 ) );
		self.SpawnPlayer.knifeRange = int( TableLookUp( file, 0, weapon, 10 ) );
	} 
	else 
	{
		self.SpawnPlayer.knifeDamage = 100;
		self.SpawnPlayer.knifeRange = 100;
	}
	
	// PERKS
	self.SpawnPlayer.perks[0] = TableLookUp( file, 0, firstPerk, 8 );
	self.SpawnPlayer.perks[1] = TableLookUp( file, 0, secondPerk, 8 );
	self.SpawnPlayer.perks[2] = TableLookUp( file, 0, thirdPerk, 8 );
}

ModifyPlayerDamage()
{
	eAttacker = self.PlayerDamage.eAttacker;
	sMeansOfDeath = self.PlayerDamage.sMeansOfDeath;
	
	if( !IsDefined( eAttacker ) || !IsPlayer( eAttacker ) )
		return;
		
	self.PlayerDamage.iDamage = ModifyDamage( eAttacker, sMeansOfDeath, self.PlayerDamage.iDamage );
}
ModifyEntityDamage()
{	
	attacker = self.EntityDamage.attacker;
	sMeansOfDeath = self.EntityDamage.sMeansOfDeath;

	if( !IsDefined( attacker ) || !IsPlayer( attacker ) )
		return;
	
	self.EntityDamage.iDamage = ModifyDamage( attacker, sMeansOfDeath, self.EntityDamage.iDamage );
}
ModifyDamage( player, sMeansOfDeath, defaultDamage )
{
	if( IsDefined( sMeansOfDeath ) && sMeansOfDeath == "MOD_MELEE" )
		return player.SpawnPlayer.knifeDamage;
	else
		return defaultDamage;
}

/*GiveClass()
{
	team = self.pers["team"];
	classIndex = self CLASS_GetSaveClassIndex( team );
	
	types = self CLASS_GetAllTypes( team );
	for( typeI = 0; typeI < types.size; typeI++ )
	{
		type = types[typeI];
		
		stat = self CLASS_GetTypeStat( type, team, classIndex );
		lineIndex = self scripts\clients\_stats::GetStatValue( stat );
		
		switch( type )
		{
			case "Figure":
				self.class["bodyModel"] = self CLASS_GetItemValue( lineIndex, 10, team );
				self.class["bodyHead"] = self CLASS_GetItemValue( lineIndex, 11, team );
				self.class["bodyHands"] = self CLASS_GetItemValue( lineIndex, 12, team );
				self.class["health"] = int( self CLASS_GetItemValue( lineIndex, 13, team ) );
				self.class["speed"] = int( self CLASS_GetItemValue( lineIndex, 14, team ) );
				self.class["jump"] = int( self CLASS_GetItemValue( lineIndex, 15, team ) );
				break;
			case "Weapon":
				self.class["weapon"] = self CLASS_GetItemValue( lineIndex, 10, team );
				self.class["weaponDMG"] = int( self CLASS_GetItemValue( lineIndex, 11, team ) );
				self.class["knifeDMG"] = int( self CLASS_GetItemValue( lineIndex, 12, team ) );
				break;
			default:
				break;
		}
	}
	
	self.maxhealth = self.class["health"];
	self.health = self.maxhealth;
	
	self SetMoveSpeedScale( self.class["speed"]/100 );
	self SetClientDvar( "jump_height", int( 39*(self.class["jump"]/100) ) );
	
	self detachAll();
	self setModel( self.class["bodyModel"] );
	self setViewModel( self.class["bodyHands"] );
	if( self.class["bodyHead"] != "" )
		self attach( self.class["bodyHead"], "", true );
		
	self GiveWeapon( self.class["weapon"] );
	self SetSpawnWeapon( self.class["weapon"] );
}

ModifyWeaponDamage( player )
{
	eAttacker = player.PlayerDamage.eAttacker;
	sWeapon = player.PlayerDamage.sWeapon;
	sMeansOfDeath = player.PlayerDamage.sMeansOfDeath;
	
	if( !IsDefined( eAttacker ) || !IsPlayer( eAttacker ) )
		return;
		
	player.PlayerDamage.iDamage = ModifyDamage( player, sMeansOfDeath, sWeapon );
}
ModifyWeaponentityDamage( entity )
{
	// iDFlags
	#define IDFLAG_NOMODIFY 4
	if( entity.DamageFlags & IDFLAG_NOMODIFY )
		return;
		
	attacker = entity.entityDamage.attacker;
	sWeapon = entity.entityDamage.sWeapon;
	sMeansOfDeath = entity.entityDamage.sMeansOfDeath;

	if( !IsDefined( attacker ) || !IsPlayer( attacker ) )
		return;
	
	entity.entityDamage.iDamage = ModifyDamage( attacker, sMeansOfDeath, sWeapon );
}
ModifyDamage( player, sMeansOfDeath, sWeapon )
{
	if( !IsDefined( sWeapon ) || sWeapon != player.class["weapon"] )
		return;
		
	if( sMeansOfDeath == "MOD_MELEE" )
		return player.class["knifeDMG"];
	else
		return player.class["weaponDMG"];
}*/