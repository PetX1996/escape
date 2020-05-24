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

/// DeleteShape()
/// AddCuboid( origin, dimensions )
/// InCuboid( Cuboid, point )
/// GetRandomPositionInCuboid( Cuboid )
/// AddCylinder( origin, radius, height )
/// InCylinder( cylinder, point )
/// GetRandomPositionInCylinder( cylinder )

#include scripts\include\_main;
#include scripts\include\_math;

DeleteShape()
{
	self.origin = undefined;
	self.dimensions = undefined;
	self.radius = undefined;
	self.height = undefined;
}

// kváder
// origin - stred spodnej podstavy
// dimensions   - rozmery
AddCuboid( origin, dimensions )
{
	if( !isDefined( origin ) || !isDefined( dimensions ) )
		return;
		
	if( !isDefined( origin[0] ) || !isDefined( origin[1] ) || !isDefined( origin[2] ) )
		return;
	
	if( !isDefined( dimensions[0] ) || !isDefined( dimensions[1] ) || !isDefined( dimensions[2] ) )
		return;
	
	Cuboid = SpawnStruct();
	
	Cuboid.origin = origin;
	Cuboid.dimensions = dimensions;
	
	return Cuboid;
}

InCuboid( Cuboid, point )
{
	state = [];
	for( i = 0;i < 3;i++ )
	{
		if( i != 2 )
		{
			if( point[i] >= Cuboid.origin[i] - Cuboid.dimensions[i]/2 )
			{
				if( point[i] <= Cuboid.origin[i] + Cuboid.dimensions[i]/2 )
					state[i] = true;
			}
		}
		else
		{
			if( point[i] >= Cuboid.origin[i] && point[i] <= Cuboid.origin[i] + Cuboid.dimensions[2] )
				state[i] = true;
		}
	}

	if( isDefined( state[0] ) && isDefined( state[1] ) && isDefined( state[2] ) )
		return true;
	
	return false;
}

GetRandomPositionInCuboid( Cuboid )
{
	position = [];
	for( i = 0;i < 3;i++ )
	{
		if( i != 2 )
		{
			start = Cuboid.origin[i] - Cuboid.dimensions[i]/2;
			end = Cuboid.origin[i] + Cuboid.dimensions[i]/2;
		}
		else
		{
			start = Cuboid.origin[i];
			end = Cuboid.origin[i] + Cuboid.dimensions[i];			
		}
		
		if( start == end )
		{
			position[i] = start;
			continue;
		}
		
		absolute = start;
			
		start -= absolute;
		end -= absolute;
		
		result = RandomFloatRange( start, end );
		position[i] = result + absolute;
	}
	
	return ( position[0], position[1], position[2] );
}

// valec
// origin - stred spodnej podstavy
// radius - polomer valca
// height - výška valca
AddCylinder( origin, radius, height )
{
	if( !isDefined( origin ) || !isDefined( radius ) || !isDefined( height ) )
		return;
		
	if( !isDefined( origin[0] ) || !isDefined( origin[1] ) || !isDefined( origin[2] ) )
		return;
	
	cylinder = SpawnStruct();
	
	cylinder.origin = origin;
	cylinder.radius = radius;
	cylinder.height = height;
	
	return cylinder;
}

InCylinder( cylinder, point )
{
	if( distance2d( cylinder.origin, point ) <= cylinder.radius )
	{
		if( point[2] >= cylinder.origin[2] && point[2] <= cylinder.origin[2] + cylinder.height )
			return true;
	}
	
	return false;
}

GetRandomPositionInCylinder( cylinder )
{
	position = [];
	start = cylinder.origin[2];
	end = cylinder.origin[2] + cylinder.height;	

	if( start == end )
		position[2] = start;
	else
	{
		absolute = start;
				
		start -= absolute;
		end -= absolute;
			
		result = RandomFloatRange( start, end );
		position[2] = result + absolute;
	}
	
	while( true )
	{
		for( i = 0;i < 2;i++ )
		{
			start = cylinder.origin[i] - cylinder.radius;
			end = cylinder.origin[i] + cylinder.radius;
			
			if( start == end )
			{
				position[i] = start;
				continue;
			}
			
			absolute = start;
				
			start -= absolute;
			end -= absolute;
			
			result = RandomFloatRange( start, end );
			position[i] = result + absolute;
		}
		
		if( !InCylinder( cylinder, ( position[0], position[1], position[2] ) ) )
			continue;
		else
			return ( position[0], position[1], position[2] );
		
		wait 0.001;
	}
}

/// SHAPE_Cylinder( position, radius, height )
/// SHAPE_Cuboid( position, size )

/// SHAPE_EnableFlag( flag )
/// SHAPE_DisableFlag( flag )

/// SHAPE_IsInside( point )
/// SHAPE_GetRandomPoint()
/// SHAPE_Print( color, duration )

/// SHAPE_GetRandomPointInCircle( radius )

// flags
private SHAPE_FLAG_ISCYLINDER = 1;
private SHAPE_FLAG_ISCUBOID = 2;
private SHAPE_FLAG_NOENTITY = 4;

SHAPE( entity )
{
	if( !IsDefined( entity ) )
	{
		entity = SpawnStruct();
		entity.ShapeFlags = 0;
		entity SHAPE_EnableFlag( SHAPE_FLAG_NOENTITY );
	}
	
	entity.ShapeFlags = 0;
	return entity;
}

///
/// Pridá virtuálny cylinder, position je stred spodnej podstavy
///
SHAPE_Cylinder( position, radius, height, entity )
{
	shape = SHAPE( entity );
	shape.origin = position;
	shape.radius = radius;
	shape.height = height;
	
	shape SHAPE_EnableFlag( SHAPE_FLAG_ISCYLINDER );
	return shape;
}
///
/// Pridá virtuálny kváder, position je dolný roh.
///
SHAPE_Cuboid( position, scale, entity )
{
	shape = SHAPE( entity );
	shape.origin = position;
	shape.scale = scale;
	
	shape SHAPE_EnableFlag( SHAPE_FLAG_ISCUBOID );
	return shape;
}

SHAPE_EnableFlag( flag )
{
	self.ShapeFlags |= flag;
}
SHAPE_DisableFlag( flag )
{
	self.ShapeFlags &= ~flag;
}
///
/// Zistí, èi sa bod nachádza vnútri shape.
///
SHAPE_IsInside( point )
{
	x = point[0];
	y = point[1];
	z = point[2];

	if( self.ShapeFlags & SHAPE_FLAG_ISCYLINDER )
	{
		if( z >= self.origin[2] && z <= (self.origin[2]+self.height) 
		&& Distance2d( self.origin, point ) <= self.radius )
			return true;
	}
	else if( self.ShapeFlags & SHAPE_FLAG_ISCUBOID )
	{
		if( x >= self.origin[0] && x <= (self.origin[0]+self.scale[0])
		&& y >= self.origin[1] && y <= (self.origin[1]+self.scale[1])
		&& z >= self.origin[2] && z <= (self.origin[2]+self.scale[2]) )
			return true;
	}
	return false;
}
///
/// Získa náhodnú pozíciu vnútri shape.
///
SHAPE_GetRandomPoint()
{
	if( self.ShapeFlags & SHAPE_FLAG_ISCYLINDER )
	{
		r = self.origin + SHAPE_GetRandomPointInCircle( self.radius );
		r += ( 0, 0, RandomFloat( self.height ) );
		
		return ( r[0], r[1], r[2] );
	}
	else if( self.ShapeFlags & SHAPE_FLAG_ISCUBOID )
	{
		r = [];
		for( rI = 0; rI > 3; rI++ )
			r[rI] = MATH_RandomUFloat( self.origin[rI], (self.origin[rI]+self.scale[rI]) );
			
		return ( r[0], r[1], r[2] );
	}
	return ( 0, 0, 0 );
}

/// Graficky zobrazí shape
SHAPE_Print( color, duration )
{
	if( self.ShapeFlags & SHAPE_FLAG_ISCYLINDER )
		self SHAPE_Print_Cylinder( color, duration );
	else if( self.ShapeFlags & SHAPE_FLAG_ISCUBOID )
		self SHAPE_Print_Cuboid( color, duration );
}
private PRINT_CYLINDER_VERTEXS = 8;
private PRINT_DEPTHTEST = false;
SHAPE_Print_Cylinder( color, duration )
{
	anglesJump = 360 / PRINT_CYLINDER_VERTEXS;
	lastPoint = self.origin + (AnglesToForward( ( 0, (360/PRINT_CYLINDER_VERTEXS) * (PRINT_CYLINDER_VERTEXS-1), 0 ) ) * self.radius);
	for( vI = 0; vI < PRINT_CYLINDER_VERTEXS; vI++ )
	{
		vStart = self.origin + (AnglesToForward( ( 0, anglesJump * vI, 0 ) )* self.radius);
		vEnd = vStart + (0, 0, self.height);
		thread PrintLine( lastPoint, vStart, color, PRINT_DEPTHTEST, duration );
		thread PrintLine( lastPoint + (0, 0, self.height), vEnd, color, PRINT_DEPTHTEST, duration );
		thread PrintLine( vStart, vEnd, color, PRINT_DEPTHTEST, duration );
		
		lastPoint = vStart;
	}
}
SHAPE_Print_Cuboid( color, duration )
{
	position = self.origin;
	multiplicator = 1;
	for( pI = 0; pI < 2; pI++ )
	{
		if( pI == 1 )
		{
			position = self.origin + self.scale;
			multiplicator = -1;
		}
		
		thread PrintLine( position, position + (self.scale[0] * multiplicator, 0, 0), color, PRINT_DEPTHTEST, duration );
		thread PrintLine( position, position + (0, self.scale[1] * multiplicator, 0), color, PRINT_DEPTHTEST, duration );
		thread PrintLine( position + (0, 0, self.scale[2] * multiplicator), position + (self.scale[0] * multiplicator, 0, self.scale[2] * multiplicator), color, PRINT_DEPTHTEST, duration );
		thread PrintLine( position + (0, 0, self.scale[2] * multiplicator), position + (0, self.scale[1] * multiplicator, self.scale[2] * multiplicator), color, PRINT_DEPTHTEST, duration );		
		thread PrintLine( position, position + (0, 0, self.scale[2] * multiplicator), color, PRINT_DEPTHTEST, duration );
		thread PrintLine( position + (0, self.scale[1] * multiplicator, 0), position + (0, self.scale[1] * multiplicator, self.scale[2] * multiplicator), color, PRINT_DEPTHTEST, duration );
	}
}

/// Vráti náhodnú pozíciu v kruhu
SHAPE_GetRandomPointInCircle( radius )
{
	rVec = AnglesToForward( ( 0, RandomFloat( 360 ), 0 ) );
	rLength = RandomFloat( radius );
	return rVec * rLength;
}

SHAPE_GetRandomPointInCylinder( origin, radius, height )
{
	rVec = SHAPE_GetRandomPointInCircle( radius );
	rH = height;
	
	if( rH > 0 ) rH = RandomFloat( rH );
	
	return ( origin[0] + rVec[0], origin[1] + rVec[1], origin[2] + rVec[2] + rH );
}

SHAPE_GetRandomPointInCuboid( origin, measure )
{
	rX = measure[0];
	rY = measure[1];
	rZ = measure[2];
	
	if( rX > 0 ) rX = RandomFloat( rX );
	if( rY > 0 ) rY = RandomFloat( rY );
	if( rZ > 0 ) rZ = RandomFloat( rZ );
	
	return ( origin[0] + rX, origin[1] + rY, origin[2] + rZ );
}

SPAPE_IsPointInCylinder( origin, radius, height, point )
{
	if( point[2] >= origin[2] && point[2] <= origin[2]+height && Distance2D( origin, point ) <= radius )
		return true;

	return false;
}

SHAPE_IsPointInCuboid( origin, measure, point )
{
	for( d = 0; d < 3; d++ )
	{
		if( point[d] >= origin[d] && point[d] <= origin[d]+measure[d] )
			continue;
			
		return false;
	}
	return true;
}