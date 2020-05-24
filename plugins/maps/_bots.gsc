AddBot( botName, baseName )
{
	base = getEnt( baseName, "targetname" );
	bot = getEnt( botName, "targetname" );
	
	if( !isDefined( level.entityBots ) )
		level.entityBots = [];
	
	level.entityBots[level.entityBots.size] = bot;
	
	trig = getEnt( "trigger", "targetname" );
	trig waittill( "trigger" );
	trig delete();
	
	stepSize = 16;
	speed = 100;
	
	startOrigin = bot.origin;
	startAngles = bot.angles;
	
	while( true )
	{
		array = GetNewPoint( bot, base, stepSize );
		
		if( !isDefined( array ) )
		{
			bot.origin = startOrigin;
			bot.angles = startAngles;
			continue;
		}
		
		point = array["origin"];
		angles = array["angles"];
		
		time = distance( bot.origin, point ) / speed;
		bot MoveTo( point, time );
		bot.angles = angles;
		wait time;
	}
}

GetNewPoint( bot, base, stepSize )
{
	startOrigin = bot.origin;
	startAngles = bot.angles;
	
	angles = startAngles;
	for( i = 0;;i++ )
	{
		mod = ( RandomInt( 100 ) % 3 );
	
		if( i > 12 )
			return undefined;
			
		if( i > 10 )
			angles = startAngles;
		else if( i > 11 )
			angles = ( startAngles[0], startAngles[1] + 180, startAngles[2] );
		else if( mod == 0 )
			angles = startAngles;
		else if( mod == 1 )
			angles = ( startAngles[0], startAngles[1] + 90, startAngles[2] );
		else
			angles = ( startAngles[0], startAngles[1] - 90, startAngles[2] );
		
		point = startOrigin + ( AnglesToForward( angles ) * stepSize );
		
		if( !isOverBase( bot, base, point ) )
			continue;
			
		exit = false;
		for( j = 0;j < level.entityBots.size;j++ )
		{
			entBot = level.entityBots[j];
			
			if( entBot == bot )
				continue;
				
			if( distance2d( entBot, bot ) <= 64 )
			{
				exit = true;
				break;
			}
		}
		if( exit )
			continue;
			
		array = [];
		array["origin"] = point;
		array["angles"] = angles;
		return array;
	}
}

isOverBase( bot, base, point )
{
	if( isOverEntity( bot, base, point ) )
		return true;
		
	return false;
}

isOverEntity( bot, entity, point )
{
	trace = BulletTrace( point, point + ( 0,0,-10000 ), false, bot );
	
	if( isDefined( trace ) && isDefined( trace["entity"] ) )
	{
		if( trace["entity"] == entity )
			return true;
	}
	
	return false;
}