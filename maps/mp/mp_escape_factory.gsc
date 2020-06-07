#include scripts\include\_main;

main()
{
	maps\mp\_load::main();
	maps\mp\steam_pipes::main();
	
	thread Bridge();
	thread TriggerDoor();
	thread ElectricTrap();
	
	thread Elevator( 0, "x", (-1), 1, false, 528, 20, 2, 10, "Elevator #3 comes in 10 seconds.", "Elevator #3 is now available.", "Elevator #3 is broken!" );
	thread Elevator( 1, "y", (-1), 1, true, 528, 40, 100, 15, "Elevator #3 comes in 15 seconds.", "Elevator #3 is now available.", "Elevator #3 is broken!" );
	thread Elevator( 2, "x", 1, (-1), false, 2240, 100, 100, 20, "Elevator #8 comes in 20 seconds.", "Elevator #8 is now available.", "Elevator #8 is broken!" );
	
	thread plugins\maps\_doors::Door( "door_0_2", "z", 112, 50, 45, "Door #3 open in 45 second.", "Door #3 opened!" );
	
	thread plugins\maps\_doors::Door( "door_1_0", "z", 112, 50, 20, "Door #4 open in 20 second.", "Door #4 opened!" );
	thread plugins\maps\_doors::Door( "door_1_1", "z", 112, 50, 10, "Door #4 open in 10 second.", "Door #4 opened!" );

	thread plugins\maps\_doors::Door( "door_2_0", "z", 112, 50, 5, "Door #5 open in 5 second.", "Door #5 opened!" );
	thread plugins\maps\_doors::Door( "door_2_1", "z", 112, 50, 15, "Door #5 open in 15 second.", "Door #5 opened!" );
	thread plugins\maps\_doors::Door( "door_2_2", "z", 112, 50, 20, "Door #6 open in 20 second.", "Door #6 opened!" );

	thread plugins\maps\_doors::Door( "door_3_0", "z", 112, 50, 30, "Door #7 open in 30 second.", "Door #7 opened!" );
	thread plugins\maps\_doors::Door( "door_3_1", "z", 112, 50, 20, "Door #7 open in 20 second.", "Door #7 opened!" );
	
	thread plugins\maps\_doors::Door( "door_3_2", "z", 112, 50, 30, "Door #8 open in 30 second.", "Door #8 opened!" );
	thread plugins\maps\_doors::Door( "door_3_3", "z", 112, 50, 5, "Door #8 open in 5 second.", "Door #8 opened!" );

	
	thread plugins\maps\_doors::Door( "doors_use", "z", 112, 50 );
	
	thread plugins\maps\_des_obj::DestructibleEntity( "wood_plank", 500, undefined, "allies" );
	thread plugins\maps\_des_obj::DestructibleEntity( "wood_plank_door", 500, undefined, undefined );
	thread plugins\maps\_des_obj::DestructibleEntity( "wood_smallplank_door", 500, undefined, undefined );
	
	thread plugins\ends\_nuke::init( "escape_nuke_activator", "escape_nuke_bomb", "escape_nuke_alivezone" );
	
	setdvar( "r_specularcolorscale", "1" );
	setdvar("r_glowbloomintensity0",".25");
	setdvar("r_glowbloomintensity1",".25");
	setdvar("r_glowskybleedintensity0",".3");
	setdvar("compassmaxrange","2200");
	
	AddFXtoList( "misc/electric" );
	
	// ======== ESCAPE ========= //
	level.MapSettings["TimeLimit"] = 8; 							//minutes
	level.MapSettings["SpawnsFX"] = "misc/ui_flagbase_black"; 				//the path to FX, Loop FX recommended
	level.MapSettings["BigSpawnsFX"] = "misc/ui_flagbase_black_big"; 	//the path to FX, Loop FX recommended
	level.MapSettings["AmbientTrack"] = "mp_escape_factory"; 			//ambient track
	
	level.MapSettings["MonstersStartTimeAdd"] = 10;
	// ========================= //
}

ElectricTrap()
{
	for( i = 0; i < 2;i++ )
	{
		hurt = GetEnt( "electric_hurt_"+i, "targetname" );
		hurt HideTrigger();
	}
	
	activator = GetEnt( "electric_activator", "targetname" );
	activator waittill( "trigger" );
	activator delete();
	
	for(i = 0; i < 2; i++)
	{
		startOrigin = GetEnt( "electric_" + i, "targetname" ).origin;
		endOrigin = startOrigin + (0, -666, 0);
		
		hurt = GetEnt( "electric_hurt_"+i, "targetname" );
		thread ElectricTrap_Active( endOrigin, startOrigin, hurt );
	}
}

ElectricTrap_Active( start, end, hurt )
{
	max = 666;
	for( i = 0;i < 20;i++ )
	{
		wait RandomFloatRange( 1, 2 );
		
		curOrigin = (start[0], start[1] + RandomInt( max ), start[2]);
		
		PlayFX( AddFXtoList( "misc/electric" ), curOrigin );
		hurt.origin = (curOrigin[0] + 88, curOrigin[1] + 24, curOrigin[2]);
		wait 1;
		hurt HideTrigger();
	}
}

HideTrigger()
{
	self.origin += ( 0, 0, 100000 );
}

Bridge()
{
	if(!isdefined(level.escape_fx))
		level.escape_fx = [];

	if(!isdefined(level.escape_fx["explosions/aerial_explosion"]))
		level.escape_fx["explosions/aerial_explosion"] = LoadFX( "explosions/aerial_explosion" );
	
	trig = getent("des_stone_trig", "targetname");
	brush = getentarray("des_stone", "targetname");
	lights = GetEntArray( "des_stone_lights", "targetname" );
	
	trig waittill("trigger");
	trig delete();
	iprintlnbold("Bridge will be destroyed in 10 seconds.");
	
	wait 10;
	
	for(i = 0;i < brush.size;i++)
	{
		brush[i] thread StoneMove();
	}
	
	wait 0.5;
	for( i = 0;i < lights.size;i++ )
		lights[i] delete();
}

StoneMove()
{
	wait randomfloat(1.5);
	
	Earthquake( 1, 2, self.origin, 3000 );
	playfx(level.escape_fx["explosions/aerial_explosion"], self.origin);
	
	t = randomfloatrange(1.5, 3);
	self moveto(getent(self.target, "targetname").origin, randomfloatrange(1.5, 3), 0.5);
	wait t/2;
	
	self delete();
}

TriggerDoor()
{
	triggers = getEntArray( "doors_use_loop", "targetname" );
	
	for( i = 0;i < triggers.size;i++ )
		triggers[i] thread TriggerDoor_Move();
}

TriggerDoor_Move()
{
	entity = getEntArray( self.target, "targetname" );
	
	trigger = undefined;
	mainEnt = undefined;
	for( i = 0;i < entity.size;i++ )
	{
		if( entity[i].classname == "trigger_hurt" )
			trigger = entity[i];
			
		if( entity[i].classname == "script_brushmodel" )
			mainEnt = entity[i];
	}
	
	if( !isDefined( mainEnt ) || !isDefined( trigger ) )
		return;
		
	self waittill( "trigger" );
	self delete();
	
	mainEnt MoveZ( 112, 112/50 );
	mainEnt waittill( "movedone" );
	
	wait 5;
	
	trigger.origin = ( trigger.origin[0], trigger.origin[1], trigger.origin[2]+112 );
	trigger enableLinkTo();
	trigger linkTo( mainEnt );
	
	mainEnt MoveZ( -112, 112/50 );
}

Elevator( num, axis, type1, type2, loop, trace, speed, random, startTime, text, doneText, errorText )
{
	activator = getEnt( "ele_activator_"+num, "targetname" );

	cabin = getEnt( "ele_cabin_"+num, "targetname" );
	//light = getEnt( "ele_light_"+num, "targetname" );
	
	topDoorLeft = getEnt( "ele_topdoor_left_"+num, "targetname" );
	topDoorRight = getEnt( "ele_topdoor_right_"+num, "targetname" );
	
	bottomDoorLeft = getEnt( "ele_bottomdoor_left_"+num, "targetname" );
	bottomDoorRight = getEnt( "ele_bottomdoor_right_"+num, "targetname" );
	
	/*if( axis == "x" )
	{
		topDoorLeft MoveX( 70*type1, 0.01 );
		topDoorRight MoveX( 70*type2, 0.01 );
		bottomDoorLeft MoveX( 70*type1, 0.01 );
		bottomDoorRight MoveX( 70*type2, 0.01 );
	}
	else
	{
		topDoorLeft MoveY( 70*type1, 0.01 );
		topDoorRight MoveY( 70*type2, 0.01 );
		bottomDoorLeft MoveY( 70*type1, 0.01 );
		bottomDoorRight MoveY( 70*type2, 0.01 );
	}	*/
	
	for( i = 0;;i++ )
	{
		activator waittill( "trigger" );
		
		if( i == 0 )
		{
			iprintlnbold( text );
			wait startTime;
		
			if( RandomInt( random ) == 0 )
			{
				iprintlnbold( errorText );
				return;
			}
		
			iprintlnbold( doneText );
		}
		
		if( axis == "x" )
		{
			bottomDoorLeft MoveX( 60*type1*(-1), 2 );
			bottomDoorRight MoveX( 60*type2*(-1), 2 );		
		}
		else
		{
			bottomDoorLeft MoveY( 60*type1*(-1), 2 );
			bottomDoorRight MoveY( 60*type2*(-1), 2 );		
		}
		bottomDoorLeft waittill( "movedone" );
		
		activator waittill( "trigger" );
		
		if( !loop )
			activator delete();
		
		if( axis == "x" )
		{
			bottomDoorLeft MoveX( 60*type1, 2 );
			bottomDoorRight MoveX( 60*type2, 2 );		
		}
		else
		{
			bottomDoorLeft MoveY( 60*type1, 2 );
			bottomDoorRight MoveY( 60*type2, 2 );	
		}
		bottomDoorLeft waittill( "movedone" );
		
		cabin MoveZ( trace, trace/speed );
		//light MoveZ( trace, trace/speed );

		cabin waittill( "movedone" );
		wait 1;
		
		if( axis == "x" )
		{
			topDoorLeft MoveX( 60*type1*(-1), 2 );
			topDoorRight MoveX( 60*type2*(-1), 2 );
		}
		else
		{
			topDoorLeft MoveY( 60*type1*(-1), 2 );
			topDoorRight MoveY( 60*type2*(-1), 2 );
		}
		topDoorLeft waittill( "movedone" );
		
		if( !loop )
			break;
		
		activator waittill( "trigger" );
		
		if( axis == "x" )
		{
			topDoorLeft MoveX( 60*type1, 2 );
			topDoorRight MoveX( 60*type2, 2 );
		}
		else
		{
			topDoorLeft MoveY( 60*type1, 2 );
			topDoorRight MoveY( 60*type2, 2 );
		}
		topDoorLeft waittill( "movedone" );	

		cabin MoveZ( trace*(-1), trace/speed );
		//light MoveZ( trace*(-1), trace/speed );	

		cabin waittill( "movedone" );
	}
}

