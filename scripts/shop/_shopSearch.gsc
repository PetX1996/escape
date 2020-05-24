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

#include scripts\include\_array;
#include scripts\include\_math;

// h¾adanie spawngroups a optimálneho position/radius

private CUBOID_BORDER = 32;
private CUBOID_HEIGHT = 32;

CUBOID_Get( spawnPoints )
{
	cuboids = [];
	groups = SPAWNGROUPS_Get( spawnPoints );
	foreach( group in groups )
	{
		params = CUBOID_GetParameters( group );
		//origin = params[0];
		//measure = params[1];
		
		cuboids[cuboids.size] = params;
	}
	return cuboids;	
}

CUBOID_GetParameters( spawnPoints )
{
	mX = __INT_MIN__;
	mY = __INT_MIN__;
	mZ = __INT_MIN__;
	nX = __INT_MAX__;
	nY = __INT_MAX__;
	nZ = __INT_MAX__;

	foreach( spawnPoint in spawnPoints )
	{
		o = spawnPoint.origin;
		
		if( o[0] < nX ) nX = o[0];
		if( o[0] > mX ) mX = o[0];
		
		if( o[1] < nY ) nY = o[1];
		if( o[1] > mY ) mY = o[1];
		
		if( o[2] < nZ ) nZ = o[2];
		if( o[2] > mZ ) mZ = o[2];
	}
	
	params = [];
	params[0] = ( nX - CUBOID_BORDER, nY - CUBOID_BORDER, nZ );
	params[1] = ( MATH_Abs( mX-nX ) + (CUBOID_BORDER*2), MATH_Abs( mY-nY ) + (CUBOID_BORDER*2), MATH_Abs( mZ-nZ ) + CUBOID_HEIGHT );
	return params;
}

private CYLINDER_RADIUS = 32;
private CYLINDER_HEIGHT = 32;

CYLINDER_Get( spawnPoints )
{
	triggers = [];
	groups = SPAWNGROUPS_Get( spawnPoints );
	foreach( group in groups )
	{
		params = CYLINDER_GetParameters( group );
		origin = params[0];
		radius = params[1];
		height = params[2];
		
		triggers[triggers.size] = params;
	}
	return triggers;
}

CYLINDER_GetParameters( spawnPoints )
{
	if( spawnPoints.size > 1 )
	{
		points = CYLINDER_GetFarthestPoints( spawnPoints );
		A = (points[0].origin[0], points[0].origin[1], 0);
		B = (points[1].origin[0], points[1].origin[1], 0);
		
		H = (0,0,points[1].origin[2]);
		if( points[0].origin[2] < points[1].origin[2] )
			H = (0,0,points[0].origin[2]);
		
		C = A-B;
		R = VectorNormalize( C )*CYLINDER_RADIUS;
		
		params = [];
		params[0] = (C*0.5)+B+H;
		params[1] = (C*0.5)+R;
		params[2] = MATH_Abs( points[0].origin[2]-points[1].origin[2] ) + CYLINDER_HEIGHT;
		return params;
	}
	else
	{
		params = [];
		params[0] = spawnPoints[0].origin;
		params[1] = CYLINDER_RADIUS;
		params[2] = CYLINDER_HEIGHT;
		return params;
	}
}

CYLINDER_GetFarthestPoints( spawnPoints )
{
	tempDist = 0;
	tempPoint = spawnPoints[0];
	
	mainTempDist = 0;
	mainTempPointA = spawnPoints[0];
	mainTempPointB = spawnPoints[1];
	
	leftPoints = spawnPoints;
	curPoint = spawnPoints[0];
	
	fP = [];
	
	while( leftPoints.size > 1 )
	{
		curPoint = leftPoints[0];
		foreach( point in leftPoints )
		{
			dist = DistanceSquared( point.origin, curPoint.origin );
			if( dist > tempDist )
			{
				tempDist = dist;
				tempPoint = point;
			}
		}
		
		if( tempDist > mainTempDist )
		{
			mainTempDist = tempDist;
			mainTempPointA = tempPoint;
			mainTempPointB = curPoint;
		}
		
		leftPoints = ARRAY_Remove( leftPoints, curPoint );
	}
	
	params = [];
	params[0] = mainTempPointA;
	params[1] = mainTempPointB;
	return params;
}

private SPAWNGROUP_SPACING_SR = 16384; // 128

// získaj všetky grupy v mape
SPAWNGROUPS_Get( spawnPoints )
{
	groups = [];
	leftPoints = spawnPoints;
	while( leftPoints.size > 0 )
	{
		group = SPAWNGROUPS_GetGroup( leftPoints );
		
		foreach( groupItem in group )
			leftPoints = ARRAY_Remove( leftPoints, groupItem );
		
		groups[groups.size] = group;
	}
	return groups;
}

// získaj kompletnú grupu spawnow
SPAWNGROUPS_GetGroup( spawnPoints )
{
	groupPoints = [];
	leftPoints = spawnPoints;
	curPoint = spawnPoints[0];
	
	groupPoints[groupPoints.size] = curPoint;
	leftPoints = ARRAY_Remove( leftPoints, curPoint );
	
	while( true )
	{
		passedSpawns = SPAWNGROUPS_GetSpawnsInRadius( leftPoints, curPoint );
		
		if( passedSpawns.size <= 0 )
			break;
			

		foreach( passedSpawnsItem in passedSpawns )
			leftPoints = ARRAY_Remove( leftPoints, passedSpawnsItem );
		
		groupPoints = ARRAY_AddRange( groupPoints, passedSpawns );

		curPoint = passedSpawns[0];
	}
	
	return groupPoints;
}


// získaj spawny v radiuse
SPAWNGROUPS_GetSpawnsInRadius( spawnPoints, curPoint )
{
	passedPoints = [];
	foreach( spawnPoint in spawnPoints )
	{
		if( DistanceSquared( curPoint.origin, spawnPoint.origin ) < SPAWNGROUP_SPACING_SR )
			passedPoints[passedPoints.size] = spawnPoint;
	}
	return passedPoints;
}