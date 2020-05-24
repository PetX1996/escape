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
#include scripts\include\_event;

init()
{
	AddCallback( level, "connected", ::OnPlayerConnected );
	//AddCallback( level, "onPlayerSpawned", ::OnPlayerSpawned );
	
}

PreCacheItems()
{
	lineIndex = 0;
	while( true )
	{
		Ttype = TableLookUp( "mp/WeaponsTable.csv", 0, lineIndex, 1 );
		if( Ttype == "" || Ttype == "Equipment" || Ttype == "Gear" )
			break;
		
		Tweapon = TableLookUp( "mp/WeaponsTable.csv", 0, lineIndex, 9 );
		if( Tweapon != "" )
			PreCacheItem( Tweapon );
		
		//LogPrint( "PreCacheItem( "+Tweapon+" ), mp/WeaponsTable.csv - line "+lineIndex+"\n" );
		
		lineIndex++;
	}
}

OnPlayerConnected( player )
{
	if( !IsDefined( player.pers["Inventory"] ) )
	{
		player.pers["Inventory"] = [];
		player.pers["Inventory"]["primaryWeapon"] = undefined;
		player.pers["Inventory"]["greande"] = undefined;
		player.pers["Inventory"]["specialGrenade"] = undefined;
		player.pers["Inventory"]["equipment"] = undefined;
		player.pers["Inventory"]["gear"] = undefined;
		
		player SetStat( 2327, GetDvarInt( "scr_inventory_ver" ) ); // security system
	}
}

RestoreSavedInventory()
{
	types = GetAllInventoryTypes();
	for( i = 0; i < types.size; i++ )
	{
		if( IsDefined( self.pers["Inventory"][types[i]] ) )
			self GiveInventory( self.pers["Inventory"][types[i]], types[i] );
	}
}

DeleteInventoryOnDeath()
{
	self.pers["Inventory"] = [];
	self.pers["Inventory"]["primaryWeapon"] = undefined;
	self.pers["Inventory"]["greande"] = undefined;
	self.pers["Inventory"]["specialGrenade"] = undefined;
	self.pers["Inventory"]["equipment"] = undefined;
	self.pers["Inventory"]["gear"] = undefined;
}

GetTypeByLineIndex( TlineIndex, Ttype )
{
	TlineIndex = int( TlineIndex );
	if( !IsDefined( Ttype ) )	Ttype = TableLookUp( "mp/WeaponsTable.csv", 0, TlineIndex, 1 );
	
	switch( Ttype )
	{
		case "Assault":
		case "SMG":
		case "LMG":
		case "Shotgun":
		case "Sniper":
			return "primaryWeapon";
		case "Grenade":
			return scripts\clients\_weapons::GetGrenadeType( TableLookUp( "mp/WeaponsTable.csv", 0, TlineIndex, 9 ) );
		case "Equipment":
			return "equipment";
		case "Gear":
			return "gear";
		default:
			PrintDebug( "Unknown inventory type "+Ttype );
			return "";
	}
}
GetAllInventoryTypes()
{
	types = [];
	types[types.size] = "primaryWeapon";
	types[types.size] = "grenade";
	types[types.size] = "specialGrenade";
	types[types.size] = "equipment";
	types[types.size] = "gear";
	return types;
}

HasSlotFull( type, TlineIndex )
{
	if( !IsDefined( type ) ) type = GetTypeByLineIndex( TlineIndex );
	
	if( IsDefined( self.pers["Inventory"][type] ) )
		return true;
		
	return false;
}

HasInventory( TlineIndex )
{
	TlineIndex = int( TlineIndex );
	types = GetAllInventoryTypes();

	for( i = 0; i < types.size; i++ )
	{
		if( IsDefined( self.pers["Inventory"][types[i]] ) && self.pers["Inventory"][types[i]] == TlineIndex )
			return true;
	}
	return false;
}

GiveInventory( TlineIndex, type )
{
	TlineIndex = int( TlineIndex );
	if( !IsDefined( type ) )	type = GetTypeByLineIndex( TlineIndex );
	
	switch( type )
	{
		case "primaryWeapon":
			self GivePrimaryWeapon( TlineIndex );
			break;
		case "grenade":
			self GiveGrenade( TlineIndex );
			break;
		case "specialGrenade":
			self GiveSpecialGrenade( TlineIndex );
			break;
		case "equipment":
			self GiveEquipment( TlineIndex );
			break;
		case "gear":
			self GiveGear( TlineIndex );
			break;
		default:
			self PrintDebug( "Unknown inventory type "+type );
			break;
	}
}
GivePrimaryWeapon( TlineIndex )
{
	if( IsDefined( self.pers["Inventory"]["primaryWeapon"] ) )
	{
		oldWeaponFile = TableLookUp( "mp/WeaponsTable.csv", 0, self.pers["Inventory"]["primaryWeapon"], 9 );
		self TakeWeapon( oldWeaponFile );
	}

	TlineIndex = int( TlineIndex );
	weaponFile = TableLookUp( "mp/WeaponsTable.csv", 0, TlineIndex, 9 );
	
	self scripts\clients\_weapons::GivePrimaryWeapon( weaponFile, true );
	
	self.pers["Inventory"]["primaryWeapon"] = TlineIndex;
}
GiveGrenade( TlineIndex )
{
	if( IsDefined( self.pers["Inventory"]["grenade"] ) )
	{
		oldWeaponFile = TableLookUp( "mp/WeaponsTable.csv", 0, self.pers["Inventory"]["grenade"], 9 );
		self TakeWeapon( oldWeaponFile );
	}

	TlineIndex = int( TlineIndex );
	weaponFile = TableLookUp( "mp/WeaponsTable.csv", 0, TlineIndex, 9 );
	
	self scripts\clients\_weapons::GiveGrenade( weaponFile );
	
	self.pers["Inventory"]["grenade"] = TlineIndex;
}
GiveSpecialGrenade( TlineIndex )
{
	if( IsDefined( self.pers["Inventory"]["specialGrenade"] ) )
	{
		oldWeaponFile = TableLookUp( "mp/WeaponsTable.csv", 0, self.pers["Inventory"]["specialGrenade"], 9 );
		self TakeWeapon( oldWeaponFile );
	}

	TlineIndex = int( TlineIndex );
	weaponFile = TableLookUp( "mp/WeaponsTable.csv", 0, TlineIndex, 9 );
	
	self scripts\clients\_weapons::GiveSpecialGrenade( weaponFile );

	self.pers["Inventory"]["specialGrenade"] = TlineIndex;
}
GiveEquipment( TlineIndex )
{
	TlineIndex = int( TlineIndex );
	name = TableLookUp( "mp/WeaponsTable.csv", 0, TlineIndex, 9 );
	
	self.pers["Inventory"]["equipment"] = TlineIndex;
	
	self scripts\shop\_equipment::GiveEquipment( name );
}
GiveGear( TlineIndex )
{
	TlineIndex = int( TlineIndex );
	name = TableLookUp( "mp/WeaponsTable.csv", 0, TlineIndex, 9 );
	
	self.pers["Inventory"]["gear"] = TlineIndex;
	
	self scripts\shop\_gear::GiveGear( name );
}

TakeAllInventory()
{
	self TakeAllWeapons();
	self TakeEquipment();
	self TakeGear();
}
TakeEquipment()
{
	self.SpawnPlayer.equipment = undefined;
	self.pers["Inventory"]["equipment"] = undefined;
	self scripts\shop\_equipment::SetEquipmentInfo();
}
TakeGear()
{
	self.SpawnPlayer.gear = undefined;
	self.pers["Inventory"]["gear"] = undefined;
	self scripts\shop\_gear::SetGearInfo();
}
