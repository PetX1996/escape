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

/// AddEvent( string, function )
/// AddCallback( object, type, function )
/// DeleteCallback( object, type, function )

AddEvent( string, function )
{
	if( !isDefined( level.EVENTS ) )
		level.EVENTS = [];
		
	size = level.EVENTS.size;
	level.EVENTS[size] = SpawnStruct();
	level.EVENTS[size].name = string;
	level.EVENTS[size].function = function;
}

// ================================================================================================================================================================================================= //
// CALLBACK LIST
// ================================================================================================================================================================================================= //
// <name>				<thread><called on>				<parameters>
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- //
// onStartGameType			1	level					 
// onStartRound				1	level					
// onElapsedRoundTime			1	level
//
// connected					1	level		 		player
// disconnected				0	level/player 			(player)
// playerSpawned				0	level/player			(player)
// onPlayerSpawned			1	level/player			(player)
// playerDamage				0	level/player			(player)
// onPlayerDamage				1	level/player			(player), eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime
// playerKilled				0	level/player			(player)
// onPlayerKilled				1	level/player			(player), eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration
//
// perkButton					1	level/player			(player)
// equipmentButton			1	level/player			(player)
// gearButton					1	level/player			(player)
//
// onGivePrimaryWeapon			1	level/player			(player), weaponFile
// onGiveSecondaryWeapon		1	level/player			(player), weaponFile
// onGiveGrenade				1	level/player			(player), weaponFile
// onGiveSpecialGrenade		1	level/player			(player), weaponFile
// onGiveWeapon				1	level/player			(player), weaponFile
// weaponChange 				1	level/player			(player), oldWeapon, newWeapon
// begin_firing				1	level/player			(player), weaponFile
// end_firing					1	level/player			(player), weaponFile
// reload_start				1	level/player			(player), weaponFile
//
// onMenuResponse				1	level/player			(player), menu, response
// onButtonPressed			1	level/player			(player), button
// changeTeam					1	level/player			(player), oldTeam, newTeam
// leaveGame						level/player			(player)
// AttackButtonPressed			1	level/player			(player)
// UseButtonPressed			1	level/player			(player)
// MeleeButtonPressed			1	level/player			(player)
// 
// HEALTH_entityDamage			0	level/entity			(entity)
// HEALTH_entityDelete			0	level/entity			(entity)
//
// coinGrab						level/entity			(entity), player
// coinDelete						level/entity			(entity)
//
// IA_placedOnGround			1	level/entity			(entity), player
// IA_grabbedByPlayer			1	level/entity			(entity), player
// ================================================================================================================================================================================================= //

AddCallback( object, type, function )
{
	if( !IsDefined( object.CALLBACK ) )
		object.CALLBACK = [];
		
	if( !IsDefined( object.CALLBACK[type] ) )
		object.CALLBACK[type] = [];

	size = object.CALLBACK[type].size;
	object.CALLBACK[type][size] = function;
}

DeleteCallback( object, type, function )
{
	if( IsDefined( type ) && IsDefined( function ) )
	{
		if( !IsDefined( object.CALLBACK ) || !IsDefined( object.CALLBACK[type] ) )
			return;
			
		object.CALLBACK[type] = scripts\include\_array::ARRAY_Remove( object.CALLBACK[type], function );
	}
	else if( IsDefined( type ) )
	{
		if( !IsDefined( object.CALLBACK ) )
			return;		
			
		object.CALLBACK[type] = undefined;
	}
	else
	{
		object.CALLBACK = undefined;
	}
}