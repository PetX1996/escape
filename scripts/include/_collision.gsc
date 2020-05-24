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

/// COLLISION_IsPlayerInCylinder( source, radius, height, ignorePlayer )
/// COLLISION_IsAnythingInCylinder( source, radius, height, hitCharacters, ignoreEntity, verticalTraces, horizontalTraces )
/// COLLISION_IsAnythingInSphere( source, radius, hitCharacters, ignoreEntity, traces )

///
/// Zkontroluje, èi sa nejaký hráè nachádza v zadanej zóne, ak áno, vráti TRUE
///
COLLISION_IsPlayerInCylinder( source, radius, height, ignorePlayer )
{
	trigger = spawn( "trigger_radius", source, 0, radius, height );
	
	for( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		
		if( !IsDefined( player ) || !IsAlive( player ) || self.pers["team"] == "spectator" || player == ignorePlayer )
			continue;
			
		if( player IsTouching( trigger ) )
		{
			trigger Delete();
			return true;
		}
	}
	
	trigger Delete();
	return false;
}

///
/// Zkontroluje, èi sa èoko¾vek nachádza vo zvolenej zóne, ak áno, vráti TRUE
///
/// source 				- stred dolnej podstavy
/// verticalTraces 		- hustota kontroly na výšku ( 4 ) - min 2
/// horizontalTraces 	- hustota kontroly z vtáèej perspektívy ( 2 ) - min 1
///
COLLISION_IsAnythingInCylinder( source, radius, height, hitCharacters, ignoreEntity, verticalTraces, horizontalTraces )
{	
	if( !IsDefined( verticalTraces ) ) verticalTraces = 4;
	if( !IsDefined( horizontalTraces ) ) horizontalTraces = 2;

	vertIncrement = (height / (verticalTraces-1));
	for( v = 0; v < verticalTraces; v++ )
	{
		curPos = source + ( 0,0, (vertIncrement * v) );
	
		if( v == 0 ) // down-up traces
		{
			// central
			if( !COLLISION_BulletTracePassed( source, source + ( 0,0,height ), hitCharacters, ignoreEntity ) )
				return true;
				
			angleIncrement = 360 / (horizontalTraces*2);	
			for( h = 0; h < (horizontalTraces*2); h++ )
			{
				curAng = ( 0,angleIncrement * h,0 );
				curAngPos = curPos + (AnglesToForward( curAng ) * radius);
				
				if( !COLLISION_BulletTracePassed( curAngPos, curAngPos + ( 0,0,height ), hitCharacters, ignoreEntity ) )
					return true;				
			}
		}
		
		// edge-center-edge traces
		if( COLLISION_IsAnythingInCylinder_CheckCircle( curPos, radius, horizontalTraces, hitCharacters, ignoreEntity ) )
			return true;		
	}
	
	return false;
}
COLLISION_IsAnythingInCylinder_CheckCircle( curPos, radius, horizontalTraces, hitCharacters, ignoreEntity )
{
	// je použitý polovièný poèet tracov, rozsah uhlov je 0-180
	angleIncrement = 360 / (horizontalTraces * 2);	
	for( h = 0; h < horizontalTraces; h++ )
	{
		curAng = ( 0,angleIncrement * h,0 );
		
		startPos = curPos - (AnglesToForward( curAng ) * radius);
		endPos = curPos + (AnglesToForward( curAng ) * radius);
		
		if( !COLLISION_BulletTracePassed( startPos, endPos, hitCharacters, ignoreEntity ) )
			return true;				
	}	
	
	return false;
}
COLLISION_BulletTracePassed( start, end, hitCharacters, ignoreEntity )
{
	//LogPrint( "[TRACE] ; start "+start+" ; end "+end+"\n" );

	if( BulletTracePassed( start, end, hitCharacters, ignoreEntity ) )
		return true;
	else
		return false;
}

///
/// Zkontroluje, èi sa èoko¾vek nachádza vo zvolenej zóne, ak áno, vráti TRUE
///
/// traces - poèet tracov ( 3 ) min 2
///
COLLISION_IsAnythingInSphere( source, radius, hitCharacters, ignoreEntity, traces )
{
	angleIncrement = 360 / (traces * 2);	
	for( v = 0; v < traces; v++ )
	{
		curAng = ( 0,angleIncrement * v,0 );
		
		for( h = 0; h < traces; h++ )
		{
			if( h == traces - 1 && traces > 2 )
				break;
		
			if( h == traces - 1 && h == v )
				break;
		
			curAng += ( angleIncrement * h,0,0 );
		
			startPos = source - (AnglesToForward( curAng ) * radius);
			endPos = source + (AnglesToForward( curAng ) * radius);
			
			if( !COLLISION_BulletTracePassed( startPos, endPos, hitCharacters, ignoreEntity ) )
				return true;
		}
	}
	
	return false;
}