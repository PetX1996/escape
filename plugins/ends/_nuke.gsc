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

#include plugins\_include;
#include scripts\include\_main;

//activator = activator trigger - targetname
//bomb		= bomb 				- targetname
//aliveZone = aliveZone trigger - targetname
init( activator, bomb, aliveZone )
{
	if( !isDefined( activator ) )
	{
		MapError( "plugins/ends/_nuke - activator trigger - undefined targetname" );
		return;
	}
	
	activators = GetEntArray( activator, "targetname" );
	if( !activators.size || !isDefined( activators[0] ) )
	{
		MapError( "plugins/ends/_nuke - undefined activator entity" );
		return;
	}
	activator = activators[0];
	
	if( isDefined( aliveZone ) )
	{
		aliveZones = GetEntArray( aliveZone, "targetname" );
		if( aliveZones.size && isDefined( aliveZones[0] ) )
			aliveZone = aliveZones[0];
		else
			aliveZone = undefined;
	}
	
	if( isDefined( bomb ) )
	{
		bombs = GetEntArray( bomb, "targetname" );
		if( bombs.size && isDefined( bombs[0] ) )
			bomb = bombs[0];
		else
			bomb = undefined;
	}
	
	//PluginInfo( "EndMap Nuke", "Escape", "0.1" );	
	PreCacheShellShock( "radiation_zeroy" );
	AddFXtoList( "explosions/nuke" );
	
	MonitorEndMapTrig( activator, bomb, aliveZone );
}

MonitorEndMapTrig( activator, bomb, aliveZone )
{
	while( true )
	{
		activator waittill( "trigger", player );
		
		if( isDefined( player ) && isAlive( player ) && player.pers["team"] == "allies" )
			break;
	}
	
	player [[level.giveScore]]( "score_endmap_first" );	
	winner = player;
	
	if( activator.classname == "trigger_use" || activator.classname == "trigger_use_touch" )
		activator SetHintString( "" );
	
	for( i = 0;i < level.players.size;i++ )
		level.players[i] scripts\clients\_hud::SetLowerTextAndTimer( "Explosion in", 10, 120 );
		
	wait 10;
	
	
	if( isDefined( bomb ) )
		activator = bomb;
	
	center = activator.origin;
	
	activator playsound( "exp_suitcase_bomb_main" );
	playRumbleOnPosition( "artillery_rumble", center );
	earthquake( 0.7, 10, center, 10000 );
	PlayFX( AddFXtoList( "explosions/nuke" ), center );
	
	StartTime = GetTime();
	while( true )
	{
		if( GetTime() - StartTime > 10000 )
			break;
	
		for( i = 0;i < level.players.size;i++ )
		{
			player = level.players[i];
			
			if( !isPlayer( player ) || !isAlive( player ) )
				continue;
				
			if( !isDefined( aliveZone ) || !player IsTouching( aliveZone ) )
				ApplyRadiation( player, center );
		}
		
		wait 0.5;
	}
	
	[[level.EndRound]]( "allies", winner );
	[[level.PostEndRound]]();
}

ApplyRadiation( player, center )
{
	radius = 10000;
	damage = 500;
	
	dist = distance( player.origin, center );
	if( dist >= radius )
		return;
	
	dmg = int( ( 1 - (dist/radius) ) * damage );
	
	if( dmg < 1 )
		return;
	
	player shellShock( "radiation_zeroy", 0.7 );
	
	player.skipDeathLogic = true;
	player scripts\_init::Callback_PlayerDamage( player, player, dmg, 0, "MOD_SUICIDE", "rpg_mp", VectorNormalize( player.origin - center ), VectorNormalize( player.origin - center ), "none", 0 );
}