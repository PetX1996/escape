#include plugins\_include;
//#include scripts\include\_shapes;

#include scripts\include\_event;
#include scripts\include\_health;
#include scripts\include\_look;
#include scripts\include\_math;

private IA_SMOOTH_ANGLE = 10;
private IA_MAXSEEDISTANCE = 1000;

private IA_COLLIDE_RADIUS = 128;
private IA_COLLIDE_HEIGHT = 128;

private IA_DELAY_GRAB = 1000;
private IA_DELAY_GRABAGAIN = 500;

//script_team
//script_health
//script_looping
//radius
//height

MovableObjects( objectsName )
{
	if( !isDefined( objectsName ) )
	{
		PluginsError( COMPILER::FilePath, COMPILER::FunctionSignature, "bad function calling" );
		return;
	}
	
	objects = getEntArray( objectsName, "targetname" );
	
	if( !isDefined( objects ) || !objects.size )
	{
		PluginsError( COMPILER::FilePath, COMPILER::FunctionSignature, "undefined entity " + objectsName );
		return;
	}
	
	foreach (object in objects)
	{
		if( !isDefined( object.radius ) )
			object.radius = IA_COLLIDE_RADIUS;
		
		if( !isDefined( object.height ) )
			object.height = IA_COLLIDE_HEIGHT;	

		object.owner = undefined;
		object.placed = undefined;
	
		if( isDefined( object.script_health ) )
		{
			object HEALTH(object.script_health);
				
		    AddCallback(object, "HEALTH_entityDelete", ::MovableObjects_OnDelete);
			
			object HEALTH_Start();
		}
	}

	thread MovableObjects_Monitor( objects );
}

MovableObjects_Monitor( objects )
{
	level waittill( "start_round" );

	while( true )
	{
		wait 0.001;
		
		foreach ( player in level.players )
		{
			wait 0.001;
			
			if( !isDefined( player ) || !isPlayer( player ) || !isAlive( player ) || !isDefined( player.reallyAlive ) || !player.reallyAlive )
				continue;
			
			if( isDefined( player.MovableObjects_grab ) )
				continue;
				
			object = undefined;
			ready = false;
			foreach ( object in objects )
			{
				if( !isDefined( object ) )
					continue;
				
				if( isDefined( object.owner ) )
					continue;
					
				if( isDefined( object.placed ) && isDefined( object.script_looping ) && !object.script_looping )
					continue;
							
				if( isDefined( object.script_team ) && object.script_team != player.pers["team"] )
					continue;
			
				pOrigin = player LOOK_GetPlayerViewPos();
				pAngles = player LOOK_GetPlayerLookVector();
				if( isDefined( distance( pOrigin, object.origin ) ) && distance( pOrigin, object.origin ) <= object.radius*3 )
				{
					start = pOrigin;
					end = start + ( pAngles * IA_MAXSEEDISTANCE );
					trace = BulletTrace( start, end, true, player );
					
					if( isDefined( trace["entity"] ) && trace["entity"] == object )
						ready = true;
				}
				
				if( ready )
				{
					thread MovableObjects_WaitToGrab( player, object );
					break;
				}
			}
			
			if( !ready )
			{
				MovableObjects_CleanPlayerLooking( player );
			}
		}
	}
}

MovableObjects_WaitToGrab( player, object )
{
	if( isDefined( player.MovableObjects_looking ) && player.MovableObjects_looking == object )
		return;

	player notify( "MovableObjects_looking" );
	player endon( "MovableObjects_looking" );
	
	player endon( "disconnect" );
	player endon( "death" );
		
	object endon( "delete" );

	player.MovableObjects_looking = object;
	player thread scripts\clients\_hud::SetLowerText( "Press ^3USE ^7grab object." );
	
	while( !player UseButtonPressed() 
		|| ( isDefined( player.MovableObjects_GrabTime ) && GetTime() - player.MovableObjects_GrabTime < IA_DELAY_GRABAGAIN ) )
	{
		wait 0.1;
	}
	
	player thread MovableObjects_Grab( object );
}

MovableObjects_CleanStatus( object, playerGrab )
{
	if ( isDefined( object ) )
	{
		object unLink();
		if( isDefined( object.ent ) )
			object.ent delete();
		
		object.owner = undefined;
		object.placed = true;
	}
	
	if ( isDefined( playerGrab ) && isDefined( playerGrab.MovableObjects_grab ) )
	{
		playerGrab notify( "MovableObjects_drop" );
		
		playerGrab.MovableObjects_grab = undefined;
		playerGrab thread scripts\clients\_hud::SetLowerText();
	}
	
	foreach (player in level.players)
	{
		if ( isDefined( player) )
		{
			MovableObjects_CleanPlayerLooking( player );
		}
	}
}

MovableObjects_CleanPlayerLooking( player )
{
	if( isDefined( player ) && isDefined( player.MovableObjects_looking ) )
	{
		player notify( "MovableObjects_looking" );
			
		player.MovableObjects_looking = undefined;
		player thread scripts\clients\_hud::SetLowerText();
	}
}

MovableObjects_Grab( object )
{
	if( isDefined( self.MovableObjects_grab ) )
		return;

	self.MovableObjects_grab = true;	
	self.MovableObjects_looking = undefined;
		
	self MovableObjects_GrabObject( object );
	
	MovableObjects_CleanStatus( object, self );
}

MovableObjects_GrabObject( object )
{
	self endon( "disconnect" );
	self endon( "death" );
	object endon( "delete" );
	
	self thread scripts\clients\_hud::SetLowerText( "Press ^3USE ^7drop object." );
	
	StartTime = GetTime();
	
	object.owner = self;
	
	object.ent = spawn( "script_origin", object.origin );
	object linkTo( object.ent );
	
	lastOrigin = self LOOK_GetPlayerViewPos();
	lastAngles = self GetPlayerAngles();
	dist = distance( lastOrigin, object.origin );
	while( true )
	{
		wait 0.01;
	
		if( self UseButtonPressed() && GetTime() - StartTime > IA_DELAY_GRAB )
		{
			if( !self MovableObjects_isPlayerInRadius( object ) )
			{
				self.MovableObjects_GrabTime = GetTime();
				return;
			}
		}
		
		origin = self LOOK_GetPlayerViewPos();
		angles = self GetPlayerAngles();
		
		if( lastOrigin == origin )
		{
			//if( MATH_DistanceNumber( angles[0], lastAngles[0] ) < IA_SMOOTH_ANGLE 
			//	|| MATH_DistanceNumber( angles[1], lastAngles[1] ) < IA_SMOOTH_ANGLE 
			//	|| MATH_DistanceNumber( angles[2], lastAngles[2] ) < IA_SMOOTH_ANGLE )
			//	continue;
		}
		
		lastOrigin = origin;
		lastAngles = angles;
			
		vec = AnglesToForward( angles );
		point = vec * dist + origin;
		
		axis = undefined;
		if( isDefined( object.script_dot ) && object.script_dot != 0 )
		{
			axis = [];
			for( v = 0;v < 3;v++ )
			{
				grid = object.script_dot;
				axis[v] = int( point[v]/grid ) * grid;
			}
		}
		else
		{
			axis = [];
			for( v = 0;v < 3;v++ )
				axis[v] = point[v];
		}
		
		object.ent.origin = ( axis[0], axis[1], axis[2] );
	}
}

MovableObjects_isPlayerInRadius( object )
{
	isTouching = false;
	trigger = spawn( "trigger_radius", ( object.origin[0], object.origin[1], object.origin[2]-(object.height/2) ), 0, object.radius, object.height );
	
	foreach ( player in level.players )
	{
		if( !isDefined( player ) || !isPlayer( player ) || !isAlive( player ) || !isDefined( player.reallyAlive ) || !player.reallyAlive )
			continue;
			
		if( player == self )
			continue;
			
		if( player IsTouching( trigger ) )
		{
			isTouching = true;
			break;
		}
	}
	
	trigger delete();
	return isTouching;
}

MovableObjects_OnDelete()
{
	DeleteCallback(self, "HEALTH_entityDelete", ::MovableObjects_OnDelete);

	MovableObjects_CleanStatus( self, self.owner );
}