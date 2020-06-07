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
#include scripts\include\_look;

init( targetname )
{
	trig = GetEntArray( targetname, "targetname" );
	
	if( !trig.size || !IsDefined( trig[0] ) )
		return;
		
	//PluginInfo( "EndMap Default", "Escape", "0.1" );	
		
	MonitorEndMapTrig( trig[0] );
}

MonitorEndMapTrig( trig )
{
	c = 0;
	while(1)
	{		
		trig waittill( "trigger", player );
		
		if( !IsDefined( player ) || !IsPlayer( player ) || !IsAlive( player ) )
			continue;
		
		if( player.pers["team"] == "axis" )
		{
			iprintln( "Player ^1"+player.name+"^7 finished map!" );
			//player [[level.giveScore]]( "score_endmap_first" );
			
			KillAllPlayersOnTime( trig, 0, "axis" );
			return;
		}
		
		if( !IsDefined( trig.Players ) )
			trig.Players = [];
			
		exit = false;
		for( i = 0;i < trig.Players.size;i++ )
		{
			if( trig.Players[i] == player )
			{	
				exit = true;
				break;
			}
		}
		if( exit )
			continue;
			
		trig.Players[trig.Players.size] = player;	
		
		
		c++;
		
		iprintln( "Player ^1"+player.name+"^7 finished map!" );
		player thread PlayFXLoop( level.escape_fx["visual/endround_player"], 0.5, (0,0,30) );
		player thread ApplyShield();
		
		if(c == 1)
		{
			player iprintlnbold("First place!");
			player [[level.giveScore]]( "score_endMapFirst" );	
		}
		else if(c == 2)
		{
			player iprintlnbold("Second place!");
			player [[level.giveScore]]( "score_endMapSecond" );	
		}
		else if(c == 3)
		{
			player iprintlnbold("Third place!");
			player [[level.giveScore]]( "score_endMapThird" );
		}	
		else
			player [[level.giveScore]]( "score_endMapOther" );
	
		thread KillAllPlayersOnTime( trig, 5, "allies", player );
			
		wait 0.05;
	}
}

PlayFXLoop( FXid, time, origin )
{
	self endon("disconnect");
	self endon("death");
	
	while(1)
	{
		PlayFX( FXid, self.origin+origin );
		wait time;
	}
}

ApplyShield()
{
	self endon("death");
	self endon("disconnect");
	
	while( true )
	{
		for( i = 0;i < level.players.size;i++ )
		{
			player = level.players[i];
			
			if( !isDefined( player ) || !isAlive( player ) || player.pers["team"] != "axis" )
				continue;
				
			if( !isDefined( distance( self LOOK_GetPlayerCenterPos(), player LOOK_GetPlayerCenterPos() ) ) || distance( self LOOK_GetPlayerCenterPos(), player LOOK_GetPlayerCenterPos() ) > 200 )	
				continue;
				
			player BouncePlayer( 1, VectorNormalize( player LOOK_GetPlayerCenterPos() - self LOOK_GetPlayerCenterPos() ) );
		}
		
		wait 0.05;
	}
}

KillAllPlayersOnTime( trig, time, team, winner )
{
	level notify( "KillAllPlayersOnTime" );
	level endon( "KillAllPlayersOnTime" );

	wait time;
	
	for(i = 0;i < level.players.size;i++)
	{
		player = level.players[i];
		
		if( !isAlive( player ) || ( player.pers["team"] == team && player IsTouching(trig) ) )
			continue;
		
		player.skipDeathLogic = true;
		player suicide();
	}
	
	wait time;
	
	[[level.EndRound]]( "allies", winner );
	[[level.PostEndRound]]();
}

