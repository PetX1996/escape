#include plugins\_include;
//#include scripts\include\_shapes;

#include scripts\include\_event;
#include scripts\include\_health;

//script_team
//script_health
//script_looping
//radius
//height

MovableObjects( objectsName )
{
	if( !isDefined( objectsName ) )
	{
		PluginsError( "MovableObjects() - bad function calling" );
		return;
	}
	
	objects = getEntArray( objectsName, "targetname" );
	
	if( !isDefined( objects ) || !objects.size )
	{
		PluginsError( "MovableObjects() - undefined entity "+objectsName );
		return;
	}
	
	foreach (object in objects)
	{
		if( !isDefined( object.radius ) )
			object.radius = 128;
		
		if( !isDefined( object.height ) )
			object.height = 128;	

		object.owner = undefined;
		object.placed = undefined;
	
		if( isDefined( object.script_health ) )
		{
			object HEALTH(object.script_health);
			
			object HEALTH_EnableFlag(HEALTH_FLAG_NODELETE);
				
		    AddCallback(object, "HEALTH_entityDelete", ::MovableObjects_OnDelete);
			
			object HEALTH_Start();
		}
	}

	thread MovableObjects_Monitor( objects );
}

MovableObjects_Monitor( objects )
{
	size = objects.size;
	
	level waittill( "start_round" );
	while( true )
	{
		wait 0.001;
		
		for( p = 0;p < level.players.size;p++ )
		{
			wait 0.001;
			
			player = level.players[p];
			
			if( !isDefined( player ) || !isPlayer( player ) || !isAlive( player ) || !isDefined( player.spawned ) )
				continue;
			
			if( isDefined( player.MovableObjects_grab ) )
				continue;
				
			object = undefined;
			ready = false;
			for( i = 0;i < size;i++ )
			{
				if( !isDefined( objects[i] ) )
					continue;
			
				object = objects[i];
				
				if( isDefined( object.owner ) )
					continue;
					
				if( isDefined( object.placed ) && isDefined( object.script_looping ) && !object.script_looping )
					continue;
							
				if( isDefined( object.script_team ) && object.script_team != player.pers["team"] )
					continue;
			
				pOrigin = player GetTagOrigin( "tag_eye" );
				pAngles = player GetPlayerAngles();
				if( isDefined( distance( pOrigin, object.origin ) ) && distance( pOrigin, object.origin ) <= object.radius*3 )
				{
					start = pOrigin;
					end = start + ( AnglesToForward( pAngles ) * 1000 );
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
				thread MovableObjects_CleanStatus( player, object );
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
	
	while( !player UseButtonPressed() || ( isDefined( player.MovableObjects_GrabTime ) && GetTime() - player.MovableObjects_GrabTime < 500 ) )
		wait 0.1;
		
	player thread MovableObjects_Grab( object );
}

MovableObjects_CleanStatus( player, object )
{
	if( !isDefined( player.MovableObjects_looking ) )
		return;
		
	player notify( "MovableObjects_looking" );
		
	player.MovableObjects_looking = undefined;
	player thread scripts\clients\_hud::SetLowerText();
}

MovableObjects_Grab( object )
{
	if( isDefined( self.MovableObjects_grab ) )
		return;

	self.MovableObjects_grab = true;	
		
	self MovableObjects_GrabObject( object );
	
	if( isDefined( object ) )
	{
		object unLink();
		if( isDefined( object.ent ) )
			object.ent delete();
		
		object.owner = undefined;
		object.placed = true;
	}
	
	if( isDefined( self ) )
	{
		self.MovableObjects_grab = undefined;
		self.MovableObjects_looking = undefined;
	}
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
	
	lastOrigin = self GetTagOrigin( "tag_eye" );
	lastAngles = self GetPlayerAngles();
	dist = distance( lastOrigin, object.origin );
	while( true )
	{
		wait 0.01;
	
		if( self UseButtonPressed() && GetTime() - StartTime > 1000 )
		{
			if( !MovableObjects_isPlayerInRadius( object ) )
			{
				self thread scripts\clients\_hud::SetLowerText();
				self.MovableObjects_GrabTime = GetTime();
				return;
			}
		}
		
		origin = self GetTagOrigin( "tag_eye" );
		angles = self GetPlayerAngles();
		
		if( lastOrigin == origin )
		{
			if( distanceNum( angles[0], lastAngles[0] ) < 20 && distanceNum( angles[1], lastAngles[1] ) < 20 && distanceNum( angles[2], lastAngles[2] ) < 20 )
				continue;
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

distanceNum( num1, num2 )
{
	if( num1 == num2 )
		return 0;

	if( num1 > num2 )
		return num1-num2;
	else
		return num2-num1;
}

MovableObjects_isPlayerInRadius( object )
{
	trigger = spawn( "trigger_radius", ( object.origin[0], object.origin[1], object.origin[2]-(object.height/2) ), 0, object.radius, object.height );
	for( i = 0;i < level.players.size;i++ )
	{
		player = level.players[i];
		
		if( !isDefined( player ) || !isPlayer( player ) || !isAlive( player ) || !isDefined( player.spawned ) )
			continue;
			
		if( player == self )
			continue;
			
		if( player IsTouching( trigger ) )
		{
			trigger delete();
			return true;
		}
	}
	
	trigger delete();
	return false;
}

MovableObjects_OnDelete( iDamage, attacker, vDir, vPoint, sMeansOfDeath, modelName, tagName, partName, iDFlags )
{
	DeleteCallback(self, "HEALTH_entityDelete", ::MovableObjects_OnDelete);

	if( isDefined( self.owner ) && isPlayer( self.owner ) )
		self.owner scripts\clients\_hud::SetLowerText();
		
	if( isDefined( self.ent ) )
		self.ent delete();
}