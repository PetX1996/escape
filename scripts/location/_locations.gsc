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
#include scripts\include\_objpoint;

private LOC_STATE_EMPTY = 0;
private LOC_STATE_PREPARE = 1;
private LOC_STATE_DEFEND = 2;

init()
{
	PreCacheShader( "waypoint_defend" );
	PreCacheShader( "waypoint_capture" );
	PreCacheShader( "waypoint_targetneutral" );
	BuildLocations();
}

BuildLocations()
{
	level.LOCATION = SpawnStruct();
	level.LOCATION.AlliesObjPoint = OBJPOINT_CreateTeamObjPoint( "LOCATION_AlliesObjPoint", "allies", (0,0,0), "waypoint_defend", 0 );
	level.LOCATION.AxisObjPoint = OBJPOINT_CreateTeamObjPoint( "LOCATION_AxisObjPoint", "axis", (0,0,0), "waypoint_capture", 0 );
	level.LOCATION.PrepareObjPoint = OBJPOINT_CreateTeamObjPoint( "LOCATION_PrepareObjPoint", "all", (0,0,0), "waypoint_targetneutral", 0 );
	level.LOCATION.CreatedLoc = 0;
	level.LOCATION.MaxLoc = undefined;
	level.LOCATION.PickedLocationI = undefined; // int
	level.LOCATION.LocationTime = 0;
	level.LOCATION.State = LOC_STATE_EMPTY;
	level.LOCATION.Triggers = [];
	level.LOCATION.TriggerIcons = [];
	
	// SD
	triggers = GetEntArray( "bombzone", "targetname" );
	foreach( trigger in triggers )
		RegisterLocationEntity( trigger, trigger.origin+( 0,0,64 ) );

	// CTF
	triggers = GetEntArray( "ctf_zone_allies", "targetname" );
	foreach( trigger in triggers )
		RegisterLocationEntity( trigger, trigger.origin+( 0,0,112 ) );

	triggers = GetEntArray( "ctf_zone_axis", "targetname" );
	foreach( trigger in triggers )
		RegisterLocationEntity( trigger, trigger.origin+( 0,0,112 ) );
		
	// HQ
	triggers = GetEntArray( "radiotrigger", "targetname" );
	ents = GetEntArray( "hq_hardpoint", "targetname" );
	foreach( trigger in triggers )
	{
		foreach( ent in ents )
		{
			if( ent IsTouching( trigger ) )
			{
				RegisterLocationEntity( trigger, ent.origin+( 0,0,24 ) );
				break;
			}
		}
	}
}

RegisterLocationEntity( triggerEnt, iconPos )
{
	level.LOCATION.Triggers[level.LOCATION.Triggers.size] = triggerEnt;
	level.LOCATION.TriggerIcons[level.LOCATION.TriggerIcons.size] = iconPos;
}

/// Sú v mape nejaké lokácie?
IsLocationsExists()
{
	if( level.LOCATION.Triggers.size == 0 )
		return false;

	return true;
}

// táto funkcia je zavolaná po štarte kola
StartLocationsLogic()
{
	if( !IsLocationsExists() )
		return;
	
	level.LOCATION.MaxLoc = Int( GetAllAlivePlayers().size * level.dvars["location_multi"] ) + 1;
	
	while( level.LOCATION.CreatedLoc < level.LOCATION.MaxLoc )
	{
		wait 0.5;
	
		//if( GetAllAlivePlayers( "allies" ) == 0 || GetAllAlivePlayers( "axis" ) == 0 )
			//continue;
	
		CreateNewLocation();
		for( i = 0; i < level.players.size; i++ )
			level.players[i] thread scripts\clients\_hud::UpdateBottomProgressBar( ( level.LOCATION.CreatedLoc / level.LOCATION.MaxLoc )*100 );
	}
	
	[[level.EndRound]]( "allies" );
}

/// Vytvorenie new lokácie.
CreateNewLocation()
{
	location = GetRandomLocation();
	level.LOCATION.CreatedLoc++;
	level.LOCATION.PickedLocationI = location;
	level.LOCATION.State = LOC_STATE_EMPTY;
	
	wait level.dvars["location_spaceTime"];
	
	PrepareStage();
	
	DefendStage();
}

/// Vyberie náhodne jednu z lokácií.
GetRandomLocation()
{
	locs = level.LOCATION.Triggers;
	if( locs.size == 1 )
		return 0;
		
	do
		loc = RandomInt( locs.size );
	while( IsDefined( level.LOCATION.PickedLocationI ) && level.LOCATION.PickedLocationI == loc );
	
	return loc;
}

/// Fáza prípravy lokácie.
PrepareStage()
{
	level.LOCATION.PrepareObjPoint OBJPOINT_UpdateOrigin( GetIconPosition() );
	level.LOCATION.PrepareObjPoint ShowObjPoint();
	
	level.LOCATION.State = LOC_STATE_PREPARE;
	
	wait level.dvars["location_prepareTime"];
	
	level.LOCATION.PrepareObjPoint HideObjPoint();
}

/// Fáza ochrany lokácie.
DefendStage()
{
	level.LOCATION.AlliesObjPoint OBJPOINT_UpdateOrigin( GetIconPosition() );
	level.LOCATION.AxisObjPoint OBJPOINT_UpdateOrigin( GetIconPosition() );
	level.LOCATION.AlliesObjPoint ShowObjPoint();
	level.LOCATION.AxisObjPoint ShowObjPoint();
	
	level.LOCATION.State = LOC_STATE_DEFEND;
	PlayersInTrigger();
	
	level.LOCATION.AlliesObjPoint HideObjPoint();
	level.LOCATION.AxisObjPoint HideObjPoint();
}

private LOCATION_DELAY = 5;
/// Pridanie XP hráèom v triggere
PlayersInTrigger()
{
	level.LOCATION.LocationTime = 0;
	while( level.LOCATION.LocationTime < level.dvars["location_time"] )
	{
		wait LOCATION_DELAY;
	
		if( IsMonsterInLocation() )
		{
			level.LOCATION.AlliesObjPoint.Color = ( 1,0,0 );
			level.LOCATION.AxisObjPoint.Color = ( 0,1,0 );
		}
		else
		{
			defenders = GetLocationDefenders();		
			if( defenders.size >= 1 )
			{
				level.LOCATION.LocationTime += LOCATION_DELAY;
				
				level.LOCATION.AlliesObjPoint.Color = ( 0,1,0 );
				level.LOCATION.AxisObjPoint.Color = ( 1,0,0 );
				
				for( i = 0; i < defenders.size; i++ )
				{
					defenders[i] [[level.giveScore]]( "score_location" );
					defenders[i] scripts\clients\_hud::UpdateTopProgressBar( (level.LOCATION.LocationTime/level.dvars["location_time"])*100, 2, 5 );
				}
			}
			else
			{
				level.LOCATION.AlliesObjPoint.Color = ( 1,1,1 );
				level.LOCATION.AxisObjPoint.Color = ( 1,1,1 );
			}
		}
	}
}

IsMonsterInLocation()
{
	monsters = GetAllAlivePlayers( "axis" );
	for( i = 0; i < monsters.size; i++ )
	{
		if( monsters[i] IsTouching( level.LOCATION.Triggers[level.LOCATION.PickedLocationI] ) )
			return true;
	}	
	
	return false;
}

GetLocationDefenders()
{
	defenders = [];
	humans = GetAllAlivePlayers( "allies" );
	for( i = 0; i < humans.size; i++ )
	{
		if( humans[i] IsTouching( level.LOCATION.Triggers[level.LOCATION.PickedLocationI] ) )
			defenders[defenders.size] = humans[i];
	}
	
	return defenders;
}

GetIconPosition()
{
	return level.LOCATION.TriggerIcons[level.LOCATION.PickedLocationI];
}

ShowObjPoint()
{
	self.alpha = 1;
}

HideObjPoint()
{
	self.alpha = 0;
}