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

PreCacheGear()
{
	scripts\shop\gear\_barrier::PreCache();
	scripts\shop\gear\_turret::PreCache();
}

GiveGear( name )
{
	self.SpawnPlayer.gear = name;

	switch( name )
	{
		case "gear_barrier":
			self thread scripts\shop\gear\_barrier::OnGiveGear( name );
			break;
		case "gear_turret":
			self thread scripts\shop\gear\_turret::OnGiveGear( name );
			break;
		case "":
			break;
		default:
			PrintDebug( "Unknown gear "+name );
			break;
	}
}

SetGearInfo( icon, ammo, optionName, extraParameter )
{
	if( IsDefined( icon ) && IsDefined( ammo ) && ammo != 0 )
	{
		self scripts\clients\_hud::SetInventoryInfo( 1, icon, ammo );
		
		if( IsDefined( optionName ) && IsDefined( extraParameter ) )
			self SetActionSlot( 4, optionName, extraParameter );
		else if( IsDefined( optionName ) )
			self SetActionSlot( 4, optionName );
		else
		{
			self GiveWeapon( "helicopter_mp" );
			self SetActionSlot( 4, "weapon", "helicopter_mp" );
		}
	}
	else
	{
		self scripts\clients\_hud::SetInventoryInfo( 1, "" );
		self SetActionSlot( 4, "" );
	}
}

UpdateGearInfo( ammo )
{
	if( ammo == 0 )
		self scripts\clients\_inventory::TakeGear();
	else
		self scripts\clients\_hud::SetInventoryInfo( 1, undefined, ammo );
}