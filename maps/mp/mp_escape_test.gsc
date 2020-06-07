#include scripts\include\_main;

main()
{
	//thread plugins\maps\_moving::MovingAndRotate( "trigger_moving", "trigger_moving_b", 300, 300, 5, false, 0 );
	
	//thread plugins\maps\_moving::MovingAndRotate( "move_active", "move", 100, 500, 0, false );
	
	cubes = getEntArray("box_green", "targetname");
	for ( i = 0; i < cubes.size; i++ )
	{
		if (RandomInt(3) == 0)
		{
			cubes[i].script_team = "allies";
		}
		
		/*cubes[i].script_dot = 16;
		cubes[i].radius = 45;
		cubes[i].height = 64;
		
		if (cubes[i].script_health == 200)
		{
			cubes[i].script_health = 5001;
		}
		else if (cubes[i].script_health == 500)
		{
			cubes[i].script_health = 10001;
		}
		else if (cubes[i].script_health == 1000)
		{
			cubes[i].script_health = 50001;
		}*/
	}
	
	thread plugins\maps\_interactive::MovableObjects( "box_green" );
	thread plugins\maps\_interactive::MovableObjects( "box_yellow" );
	thread plugins\maps\_interactive::MovableObjects( "box_red" );
	
	thread plugins\maps\_des_obj::DestructibleEntity( "box_dark" );
	
	//thread plugins\maps\_elevator::Elevator( "elevator_active", "elevator", 500, true );
	thread plugins\ends\_nuke::init( "escape_endmap_nuke_activator_0", "escape_endmap_nuke_bomb_0", "escape_endmap_nuke_alive_0" );
	thread plugins\ends\_nuke::init( "escape_endmap_nuke_activator_1", "escape_endmap_nuke_bomb_1", "escape_endmap_nuke_alive_1" );
}
