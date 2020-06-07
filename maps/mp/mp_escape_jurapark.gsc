main()
{
	thread MovingDoor();
	thread DeleteElectricFence();

	thread deleted_brush();
	thread destroy_brush();
	thread car_door();
	thread wait_connect(); 
	thread doors();
	
	//thread plugins\maps\_des_obj::DestructibleEntity("ze_destroy_brush", 100, 10);
	
	//MovingAndRotate( triggerName, brushName, velocityMin, velocityMax, time, loop, rotateType, rotateTime, text, sound )
	thread plugins\maps\_moving::MovingAndRotate( undefined, "dino1", 250, 500, 0, true, 1 );
	thread plugins\maps\_moving::MovingAndRotate( undefined, "dino2", 250, 500, 0, true, 1 );
	thread plugins\maps\_moving::MovingAndRotate( undefined, "dino3", 100, 200, 0, true, 1 );
	thread plugins\maps\_moving::MovingAndRotate( undefined, "dino5", 250, 500, 0, true, 1 );
	thread plugins\maps\_moving::MovingAndRotate( undefined, "dino6", 100, 320, 0, true, 1 );
	thread plugins\maps\_moving::MovingAndRotate( undefined, "dino7", 70, 150, 0, true, 1 );
	thread plugins\maps\_moving::MovingAndRotate( undefined, "dino8", 70, 150, 0, true, 1 );
	thread plugins\maps\_moving::MovingAndRotate( undefined, "dino9", 70, 150, 0, true, 1 );
	thread plugins\maps\_moving::MovingAndRotate( undefined, "dino10", 70, 150, 0, true, 1 );
	thread plugins\maps\_moving::MovingAndRotate( undefined, "dino11", 70, 150, 0, true, 1 );
	thread plugins\maps\_moving::MovingAndRotate( undefined, "dino12", 200, 400, 0, true, 1 );
	thread plugins\maps\_moving::MovingAndRotate( undefined, "dino13", 200, 400, 0, true, 1 );
	thread plugins\maps\_moving::MovingAndRotate( undefined, "dino14", 200, 400, 0, true, 1 );
	thread plugins\maps\_moving::MovingAndRotate( undefined, "dino15", 200, 400, 0, true, 1 );
	
	thread plugins\maps\_moving::MovingAndRotate( "trigger_moving", "trigger_moving_b", 420, 420, 1.5, false, 0, 0.1 );
	thread plugins\maps\_moving::MovingAndRotate( "call", "heli", 15, 80, 30, false, 1, undefined, "Helicopter!!", "endmap" );
}

DeleteElectricFence()
{
	trigger = getEnt( "map_trap_delete_0", "targetname" );
	
	trigger waittill( "trigger" );
	trigger delete();
	
	fence = getEntArray( "plot", "targetname" );
	for( i = 0;i < fence.size;i++ )
		fence[i] delete();

	door = getEnt( "eleplot", "targetname" );
	door unLink();
	door delete();
}

MovingDoor()
{
	activator = getEnt( "open", "targetname" );
	trigger = getEnt( "eleplot", "targetname" );
	door = getEnt( "openplot", "targetname" );
	
	trigger enableLinkTo();
	trigger linkTo( door );
	while( true )
	{
		activator waittill( "trigger" );
		
		door MoveZ( -290, 5 );
		door waittill( "movedone" );
		
		activator waittill( "trigger" );
		
		door MoveZ( 290, 5 );
		door waittill( "movedone" );		
	}
}

deleted_brush()
{
    brushs = getentarray("lom_trig","targetname"); //targetname
    
    if( !isdefined(brushs) || !brushs.size )
        return;
    
    for(i = 0;i < brushs.size;i++)
    {
        brushs[i] thread destroy_brush();
    }
}

destroy_brush()
{
	if( !isDefined( self.target ) )
		return;

    brush = getent(self.target, "targetname");
    
    if(!isdefined(brush))
        return;
        
    self waittill("trigger");
    self delete();
    
    wait 60; //cas do rozbitia
    
    brush delete();
}

wait_connect()
{
	while(1)
	{
		level waittill("connected",player);
		player thread wait_spawn();
	}
}

wait_spawn()
{
	self waittill("spawned_player");
	level notify("first_spawn");
}

car_door()
{
	//door1 = getent("dra","targetname");
	//door2 = getent("drb","targetname");
	
	car_model = getent("cara","targetname");
	car_player = getent("carb","targetname");
	
	level waittill("first_spawn");
	
	//car_player EnableLinkTo();
	car_player LinkTo(car_model);
	
	car_model movey(-2200, 45); //druhy udaj je rychlost
	wait 30;
	
	//door1 rotateyaw(90,60); //druhy udaj je rychlost
	//door2 rotateyaw(-90,60);
	
	car_model waittill("movedone");
	car_model Unlink();
}
doors()
{
	for(i = 0;i < 3;i++)
	{
		thread door_move(i);
	}
}

door_move(i)
{
	door1 = getent("doora_"+i,"targetname");
	door2 = getent("doorb_"+i,"targetname");
	trig = getent("door_trig_"+i, "targetname");

	if(!isdefined(trig) || !isdefined(door1) || !isdefined(door2))
		return;
	
	trig waittill("trigger");
	trig delete();

	door1 rotateyaw(90,65); //druhy udaj je rychlost
	door2 rotateyaw(-90,65); 
}