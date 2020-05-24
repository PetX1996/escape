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

PreCacheEquipment()
{
	scripts\shop\equipment\_c4::PreCache();
	scripts\shop\equipment\_claymore::PreCache();
	scripts\shop\equipment\_rpg::PreCache();
}

GiveEquipment( name )
{
	self.SpawnPlayer.equipment = name;

	switch( name )
	{
		case "weapon_c4":
			self thread scripts\shop\equipment\_c4::OnGiveEquipment( name );
			break;
		case "weapon_claymore":
			self thread scripts\shop\equipment\_claymore::OnGiveEquipment( name );
			break;
		case "weapon_rpg7":
			self thread scripts\shop\equipment\_rpg::OnGiveEquipment( name );
			break;
		case "":
			break;
		default:
			PrintDebug( "Unknown equipment "+name );
			break;
	}
}

SetEquipmentInfo( icon, ammo, optionName, extraParameter )
{
	if( IsDefined( icon ) && IsDefined( ammo ) && ammo != 0 )
	{
		self scripts\clients\_hud::SetInventoryInfo( 0, icon, ammo );
		
		if( IsDefined( optionName ) && IsDefined( extraParameter ) )
			self SetActionSlot( 3, optionName, extraParameter );
		else if( IsDefined( optionName ) )
			self SetActionSlot( 3, optionName );
		else
		{
			self GiveWeapon( "airstrike_mp" );
			self SetActionSlot( 3, "weapon", "airstrike_mp" );
		}
	}
	else
	{
		self scripts\clients\_hud::SetInventoryInfo( 0, "" );
		self SetActionSlot( 3, "" );
	}
}

UpdateEquipmentInfo( ammo )
{
	if( ammo == 0 )
		self scripts\clients\_inventory::TakeEquipment();
	else
		self scripts\clients\_hud::SetInventoryInfo( 0, undefined, ammo );
}