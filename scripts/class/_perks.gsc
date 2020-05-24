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

/// GivePerk( slot, perkName )
/// GiveAllPerks( perks )
/// TakePerk( perkName )
/// TakePerkFromSlot( slot )
/// TakeAllPerks()

#include scripts\include\_main;


private PERKSLOTS = 3;

StartPerkFunction( perkName ) 
{
	switch( perkName )
	{
		// HUMANS
		case "specialty_extraammo":
			self thread scripts\class\perks\_bandolier::OnGivePerk();
			break;
		case "hud_icon_nvg":
			self thread scripts\class\perks\_nightVision::OnGivePerk();
			break;
		// MONSTERS
		case "perk_extrahealth":
			self thread scripts\class\perks\_extraHealth::OnGivePerk();
			break;
		case "perk_extraspeed":
			self thread scripts\class\perks\_extraSpeed::OnGivePerk();
			break;
		case "perk_extradamage":
			self thread scripts\class\perks\_extraDamage::OnGivePerk();
			break;
		default:
			break;
	}
}

IsExePerk( perkName )
{
	switch( perkName )
	{
		case "specialty_parabolic":
		case "specialty_gpsjammer":
		case "specialty_holdbreath":
		case "specialty_quieter":
		case "specialty_longersprint":
		case "specialty_detectexplosive":
		case "specialty_explosivedamage":
		case "specialty_pistoldeath":
		case "specialty_grenadepulldeath":
		case "specialty_bulletdamage":
		case "specialty_bulletpenetration":
		case "specialty_bulletaccuracy":
		case "specialty_rof":
		case "specialty_fastreload":
		case "specialty_extraammo":
		case "specialty_twoprimaries":
		case "specialty_armorvest":
			return true;
		default:
			return false;
	}
}

GivePerk( slot, perkName )
{
	if( !IsDefined( self.SpawnPlayer.perks ) )
		self.SpawnPlayer.perks = [];	

	self.SpawnPlayer.perks[slot] = perkName;
	self scripts\clients\_hud::SetPerkInfo( slot, perkName );
	
	if( IsExePerk( perkName ) )
		self SetPerk( perkName );
	
	self StartPerkFunction( perkName );
}

GiveAllPerks( perks )
{
	for( slot = 0; slot < PERKSLOTS; slot++ )
	{
		if( IsDefined( perks[slot] ) && perks[slot] != "" )
			self GivePerk( slot, perks[slot] );
	}
}

TakePerk( perkName )
{
	if( !IsDefined( self.SpawnPlayer.perks ) )
		return;

	for( slot = 0; slot < PERKSLOTS; slot++ )
	{
		if( IsDefined( self.SpawnPlayer.perks[slot] ) && self.SpawnPlayer.perks[slot] == perkName )
		{
			self TakePerkFromSlot( slot );
			break;
		}
	}
}

TakePerkFromSlot( slot )
{
	if( !IsDefined( self.SpawnPlayer.perks ) )
		return;

	self.SpawnPlayer.perks[slot] = undefined;
	self scripts\clients\_hud::SetPerkInfo( slot, "" );
	
	if( slot == 2 )
		self SetThirdPerkButton( false );
}

TakeAllPerks()
{
	if( !IsDefined( self.SpawnPlayer.perks ) )
		return;

	for( slot = 0; slot < PERKSLOTS; slot++ )
		self TakePerkFromSlot( slot );
}

SetThirdPerkButton( enabled, optionName, extraParameter )
{
	if( IsDefined( enabled ) && enabled )
	{
		if( IsDefined( optionName ) && IsDefined( extraParameter ) )
			self SetActionSlot( 1, optionName, extraParameter );
		else if( IsDefined( optionName ) )
			self SetActionSlot( 1, optionName );
		else
		{
			self GiveWeapon( "radar_mp" );
			self SetActionSlot( 1, "weapon", "radar_mp" );
		}
		
		self scripts\clients\_hud::SetThirdPerkButtonInfo( true );
	}
	else
	{
		self SetActionSlot( 1, "" );
		self scripts\clients\_hud::SetThirdPerkButtonInfo( false );
	}
}