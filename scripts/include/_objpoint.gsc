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

//#include maps\mp\_utility;
//#include maps\mp\gametypes\_hud_util;
#include scripts\include\_array;

private OBJPOINT_DEFAULT_SIZE = 8;
private OBJPOINT_DEFAULT_ALPHA = 0.5;

OBJPOINT_CreateTeamObjPoint( name, team, origin, shader, alpha )
{
	if( !(team == "allies" || team == "axis" || team == "all") )
		return;

	if( !IsDefined( name ) )
		return;
		
	if ( !IsDefined( shader ) )
		return;
		
	objPoint = OBJPOINT_GetObjPointByName( name );
	
	if ( IsDefined( objPoint ) )
		OBJPOINT_DeleteObjPoint( objPoint );
		
	if ( team == "all" )
		objPoint = newHudElem();
	else
		objPoint = newTeamHudElem( team );
	
	objPoint.name = name;
	objPoint.x = origin[0];
	objPoint.y = origin[1];
	objPoint.z = origin[2];
	objPoint.team = team;
	objPoint.isFlashing = false;
	objPoint.isShown = true;
	
	objPoint setShader( shader, OBJPOINT_DEFAULT_SIZE, OBJPOINT_DEFAULT_SIZE );
	objPoint setWaypoint( true, shader );
	
	if ( IsDefined( alpha ) )
		objPoint.alpha = alpha;
	else
		objPoint.alpha = OBJPOINT_DEFAULT_ALPHA;
		
	objPoint.baseAlpha = objPoint.alpha;
	
	level.objPoints[name] = objPoint;
	
	return objPoint;
}

OBJPOINT_DeleteObjPoint( oldObjPoint )
{
	if ( level.objPoints.size == 1 )
	{
		level.objPoints = [];
		oldObjPoint destroy();
		return;
	}
	
	level.objPoints = DeleteFromArray( level.objPoints.size, oldObjPoint );
	oldObjPoint destroy();
}


OBJPOINT_UpdateOrigin( origin )
{
	if ( self.x != origin[0] )
		self.x = origin[0];

	if ( self.y != origin[1] )
		self.y = origin[1];

	if ( self.z != origin[2] )
		self.z = origin[2];
}


OBJPOINT_SetOriginByName( name, origin )
{
	objPoint = OBJPOINT_GetObjPointByName( name );
	objPoint OBJPOINT_UpdateOrigin( origin );
}


OBJPOINT_GetObjPointByName( name )
{
	if( IsDefined( level.objPoints ) && IsDefined( level.objPoints[name] ) )
		return level.objPoints[name];
	else
		return undefined;
}

OBJPOINT_StartFlashing()
{
	if ( self.isFlashing )
		return;
	
	self.isFlashing = true;
	
	while ( self.isFlashing )
	{
		self fadeOverTime( 0.75 );
		self.alpha = 0.35 * self.baseAlpha;
		wait ( 0.75 );
		
		self fadeOverTime( 0.75 );
		self.alpha = self.baseAlpha;
		wait ( 0.75 );
	}
	
	self.alpha = self.baseAlpha;
}

OBJPOINT_StopFlashing()
{
	if ( !self.isFlashing )
		return;

	self.isFlashing = false;
}
