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
#include scripts\include\_entity;
#include scripts\include\_array;

init()
{
	BuildCheckPoints();
}

BuildCheckPoints()
{
	// structure 
	// level
	// level.CHECKPOINT
	// level.CHECKPOINT.LastHumansI
	// level.CHECKPOINT.LastMonstersI
	// level.CHECKPOINT.Triggers[]
	// level.CHECKPOINT.Triggers[i].Spawns[]
	// level.CHECKPOINT.Triggers[i].Spawns[i].FX
	// level.CHECKPOINT.Triggers[i].BigSpawns[]
	// level.CHECKPOINT.Triggers[i].BigSpawns[i].FX

	// === CHECKPOINT SYSTEM ===
	level.CHECKPOINT = SpawnStruct();
	level.CHECKPOINT.LastHumansI = -1;
	level.CHECKPOINT.LastMonstersI = -1;
	level.CHECKPOINT.Triggers = [];
	
	// === TRIGGERS ===
	RegisterCheckpointTriggers();
}

RegisterCheckpointTriggers()
{
	triggers = GetEntArray( "escape_checkpoints_trigger", "targetname" );
	foreach( trigger in triggers )
	{
		/#
		if( !IsDefined( trigger.script_index ) )
		{
			MapError( "CHECKPOINT - Trigger at " + trigger.origin + " does not have any 'script_index'" );
			continue;
		}
		
		if( IsDefined( level.CHECKPOINT.Triggers[trigger.script_index] ) )
		{
			MapError( "CHECKPOINT - Trigger at " + trigger.origin + " has same 'script_index' as trigger at " + level.CHECKPOINT.Triggers[trigger.script_index].origin );
			continue;
		}
		#/
		
		trigger.Spawns = [];
		trigger.BigSpawns = [];
		
		level.CHECKPOINT.Triggers[trigger.script_index] = trigger;
		
		if( IsDefined( trigger.target ) )
		{
			targetEnts = GetEntArray( trigger.target, "targetname" );
			trigger RegisterCheckpointTargetEnts( targetEnts );
		}
		else
		{
			foundSpawns = [];
			
			normalSpawns = GetEntArray( "escape_checkpoints_spawn", "classname" );
			foreach (normalSpawn in normalSpawns)
			{
				if (isDefined (normalSpawn.script_index) && normalSpawn.script_index == trigger.script_index)
					foundSpawns[foundSpawns.size] = normalSpawn;
			}
			
			bigSpawns = GetEntArray( "escape_checkpoints_bigspawn", "classname" );
			foreach (bigSpawn in bigSpawns)
			{
				if (isDefined (bigSpawn.script_index) && bigSpawn.script_index == trigger.script_index)
					foundSpawns[foundSpawns.size] = bigSpawn;
			}
			
			trigger RegisterCheckpointTargetEnts( foundSpawns );
		}
	}
}

RegisterCheckpointTargetEnts( targetEnts )
{
	foreach( targetEnt in targetEnts )
	{
		switch( targetEnt.ClassName )
		{
			case "escape_checkpoints_spawn":
				if (!ARRAY_Contains( self.Spawns, targetEnt) )
				{
					targetEnt PlaceSpawnPoint();
					
					if( IsDefined( targetEnt.script_fxid ) )
						AddFXToList( targetEnt.script_fxid );
						
					self.Spawns[self.Spawns.size] = targetEnt;
				}
				break;
			case "escape_checkpoints_bigspawn":
				/#
				if( !IsDefined( targetEnt.radius ) )
				{
					MapError( "CHECKPOINT - BigSpawn at " + targetEnt.origin + " does not have any 'radius'" );
					break;
				}
				#/
				
				if (!ARRAY_Contains( self.BigSpawns, targetEnt) )
				{			
					targetEnt PlaceSpawnPoint();
					
					if( IsDefined( targetEnt.script_fxid ) )
						AddFXToList( targetEnt.script_fxid );
						
					self.BigSpawns[self.BigSpawns.size] = targetEnt;
				}
				break;
			default:
				MapError( "CHECKPOINT - Unknown linked entity at " + targetEnt.origin );
				break;
		}
	}	
}

StartMonitorCheckPoints()
{	
	for( i = 0; i < level.CHECKPOINT.Triggers.size; i++ )
	{
		if( !IsDefined( level.CHECKPOINT.Triggers[i] ) )
		{
			MapError( "CHECKPOINT - Trigger with 'script_index' '" + i + "' is missing" );
			continue;
		}
		
		level.CHECKPOINT.Triggers[i] thread MonitorCheckpoint( i );
	}
}

MonitorCheckpoint( p )
{
	while( true )
	{
		self waittill( "trigger", player );
		
		if( player.pers["team"] == "allies" )
			self OnHumanTouchTrigger( p, player );
		else
			self OnMonsterTouchTrigger( p, player );
	}
}

OnHumanTouchTrigger( p, player )
{
	//aktualizuj najnovší checkpoint
	if( p > level.CHECKPOINT.LastHumansI )
	{
		level.CHECKPOINT.LastHumansI = p;
		
		PrintDebug( "level.CHECKPOINT.LastHumansI = " + p );
		
		foreach( client in level.players )
			client thread scripts\clients\_hud::UpdateBottomProgressBar( ( (p+1) / (level.CHECKPOINT.Triggers.size+1) )*100 );
			
		// callback here?
	}
	
	//zisti, èi je hráè v checkpointe prvý krát
	if( self ENT_IsPlayerRegister( player ) )
		return;
	
	player.CHECKPOINT_LastHumansI = p;
	
	self ENT_RegisterPlayer( player );
	
	//odmeò hráèa za úsilie
	IPrintLnBold("Humans proceeded to " + (p + 1) + "/" + level.CHECKPOINT.Triggers.size + " of the map");
	//player thread scripts\clients\_hud::AddNewNotify( "notify_checkpoint" );
	player thread [[level.giveScore]]( "score_checkpoint" );
	
	// callback here?
}

OnMonsterTouchTrigger( p, player )
{
	//aktualizuj najnovší checkpoint
	if( p > level.CHECKPOINT.LastMonstersI )
	{
		level.CHECKPOINT.LastMonstersI = p;
		
		PrintDebug( "level.CHECKPOINT.LastMonstersI = " + p );
	
		self thread KillPlayersBehindCheckpoint( p );
		
		// callback here?

		if( level.CHECKPOINT.Triggers[p].Spawns.size || level.CHECKPOINT.Triggers[p].BigSpawns.size )
		{
			PrintDebug( "Moving monsters spawngroup to: " + p + "/" + level.CHECKPOINT.Triggers.size );
		
			//zobraz všetkým monštrám aktualizáciu
			foreach( monster in level.players )
			{
				if( monster.pers["team"] == "axis" && IsAlive( monster ) )
				{
					monster IPrintLnBold("Moving monsters spawngroup to " + (p + 1) + "/" + level.CHECKPOINT.Triggers.size + " of the map");
					//monster thread scripts\clients\_hud::AddNewNotify( "notify_spawn" );
				}
			}
			
			thread UpdateSpawnsGroup( p );
			
			//odmeò hráèa za úsilie
			player thread [[level.giveScore]]( "score_spawnpoint" );
			
			// callback here?
		}
	}
}

UpdateSpawnsGroup( p )
{
	if( p > 0 )
		DisableSpawnGroup( p-1 );

	EnableSpawnGroup( p );
}

EnableSpawnGroup( p )
{
	if( level.CHECKPOINT.Triggers[p].Spawns.size )
		EnableSpawnPoints( level.CHECKPOINT.Triggers[p].Spawns, level.Spawns["SpawnsFX"], level.Spawns["SpawnsSound"] );
	
	if( level.CHECKPOINT.Triggers[p].BigSpawns.size )
		EnableSpawnPoints( level.CHECKPOINT.Triggers[p].BigSpawns, level.Spawns["BigSpawnsFX"], level.Spawns["BigSpawnsSound"] );
}

EnableSpawnPoints( spawnPoints, fx, sound )
{
	foreach( spawnPoint in spawnPoints )
	{
		if( IsDefined( spawnPoint.script_fxid ) )
			fx = spawnPoint.script_fxid;
		
		if( IsDefined( spawnPoint.script_sound ) )
			sound = spawnPoint.script_sound;
		
		if( fx != "" )
			spawnPoint.FX = PlayLoopedFX( AddFXToList( fx ), 999999, spawnPoint.origin );
			
		if( sound != "" )
			spawnPoint PlaySound( sound );
	}
}

DisableSpawnGroup( p )
{
	if( level.CHECKPOINT.Triggers[p].Spawns.size )
		DisableSpawnPoints( level.CHECKPOINT.Triggers[p].Spawns );
		
	if( level.CHECKPOINT.Triggers[p].BigSpawns.size )
		DisableSpawnPoints( level.CHECKPOINT.Triggers[p].BigSpawns );
}

DisableSpawnPoints( spawnPoints )
{
	for( i = spawnPoints.size-1; i >= 0; i-- )
	{
		if( IsDefined( spawnPoints[i].FX ) )
			spawnPoints[i].FX Delete();
		
		spawnPoints[i] Delete();
	}
}

private ATTENTION_COUNT = 3;
KillPlayersBehindCheckpoint( p )
{
	level notify( "KillPlayersBehindCheckpoint" );
	level endon( "KillPlayersBehindCheckpoint" );
	
	time = level.dvars["checkpoint_deadTime"];

	for( c = ATTENTION_COUNT; c >= 0; c-- )
	{
		foreach( player in level.players )
		{
			if( player.pers["team"] != "allies" || !IsAlive( player ) )
				continue;
		
			if( self ENT_IsPlayerRegister( player )
				|| ( IsDefined(player.CHECKPOINT_LastHumansI) && player.CHECKPOINT_LastHumansI >= p ))
				continue;
				
			if( c == 0 )
			{
				player Suicide();
				player IPrintLnBold("^1You are in deadly zone!");
			}
			else
			{
				player IPrintLnBold("^1Attention! ^7You are in deadly zone!");
				player IPrintLnBold("Leave this area in ^1" + Int( (time/ATTENTION_COUNT)*c ) + "^7 seconds!");
			}
		}
		wait time/ATTENTION_COUNT;
	}
}