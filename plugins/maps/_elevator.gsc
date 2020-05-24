//thread plugins\maps\_elevator::Elevator( activatorName, entityName );
#include plugins\_include;

Elevator( activatorName, entityName, velocity, loop )
{
	if( !isDefined( entityName ) )
	{
		PluginsError( "Elevator() - bad function call" );
		return;
	}
	
	activator = undefined;
	if( isDefined( activatorName ) )
	{
		activator = getEnt( activatorName, "targetname" );
		
		if( !isDefined( activator ) )
		{
			PluginsError( "Elevator() - undefined entity ^1"+activatorName );
			return;
		}
	}
	
	entity = getEntArray( entityName, "targetname" );
	if( !isDefined( entity ) || !entity.size )
	{
		PluginsError( "Elevator() - undefined entity ^1"+entityName );
		return;		
	}
	
	if( !isDefined( velocity ) )
		velocity = 100;
	
	if( !isDefined( loop ) )
		loop = false;
	
	c = 0;
	mainEnt = undefined;
	while( !isDefined( mainEnt ) )
	{
		classname = "script_origin";
		exit = false;
		switch( c )
		{
			case 0:
				classname = "script_brushmodel";
				break;
			case 1:
				classname = "script_model";
				break;
			default:
				mainEnt = entity[0];
				exit = true;
				break;
		}
		
		if( exit )
			break;
		
		for( i = 0;i < entity.size;i++ )
		{
			if( entity[i].classname == classname )
			{
				mainEnt = entity[i];
				break;
			}
		}
		
		c++;
	}
	
	for( i = 0;i < entity.size;i++ )
	{
		if( entity[i].classname == mainEnt.classname )
			continue;
			
		if( entity[i].classname == "trigger_hurt" )
			entity[i] enableLinkTo();
			
		entity[i] linkTo( mainEnt );
	}
	
	targetEnt = undefined;
	startEnt = undefined;
	for( i = 0;i < entity.size;i++ )
	{
		if( isDefined( entity[i].target ) )
		{
			startEnt = entity[i];
			targetEnt = GetEnt( entity[i].target, "targetname" );
			if( !isDefined( targetEnt ) )
			{
				PluginsError( "Elevator() - undefined entity ^1"+targetEnt );
				return;
			}
			
			break;
		}
	}
	
	startOrigin = startEnt.origin;
	for( c = 0;;c++ )
	{
		if( isDefined( activator ) )
			activator waittill( "trigger" );
			
		if( c % 2 == 0 )
		{
			mainEnt moveTo( targetEnt.origin, distance( targetEnt.origin, mainEnt.origin )/velocity );
		}
		else
		{
			mainEnt moveTo( startOrigin, distance( startOrigin, mainEnt.origin )/velocity );
		}
		mainEnt waittill( "movedone" );
	
		if( !loop && c >= 0 )
			break;
	}
	
	for( i = 0;i < entity.size;i++ )
	{
		if( entity[i] == mainEnt )
			continue;
			
		entity[i] unLink();
	}
}