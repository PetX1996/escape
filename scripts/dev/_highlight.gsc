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

private HL_INI_POINT_LINE = 8;
private HL_INI_POINT_ARROW = 32;
private HL_INI_POINT_TEXTSPACE = 16;
private HL_INI_POINT_TEXTSCALE = 1;

private HL_INI_CYLINDER_VERTEXS = 6; // degree
private HL_INI_CYLINDER_ANGINC = 60; // degree

Init()
{
}

AddText( origin, first, second, color )
{
	/#
	if( IsDefined( second ) )
		Print3d( origin + ( 0,0,HL_INI_POINT_LINE ), second, color, 1, HL_INI_POINT_TEXTSCALE, 1 );
	if( IsDefined( first ) )
		Print3d( origin + ( 0,0,HL_INI_POINT_LINE + HL_INI_POINT_TEXTSPACE ), first, color, 1, HL_INI_POINT_TEXTSCALE, 1 );	
	#/
}

AddPoint( origin, color )
{
	/#
	Line( origin - ( 0,0,HL_INI_POINT_LINE ), origin + ( 0,0,HL_INI_POINT_LINE ), color, false, 1 );
	Line( origin - ( 0,HL_INI_POINT_LINE,0 ), origin + ( 0,HL_INI_POINT_LINE,0 ), color, false, 1 );
	Line( origin - ( HL_INI_POINT_LINE,0,0 ), origin + ( HL_INI_POINT_LINE,0,0 ), color, false, 1 );
	#/
}

AddOrientedPoint( origin, angles, color )
{
	AddPoint( origin, color );
	/#
	vec = AnglesToForward( angles ) * HL_INI_POINT_ARROW;
	Line( origin, origin + vec, color, false, 1 );
	#/
}

HighlightPoint( origin, angles, className, targetName, color )
{
	AddOrientedPoint( origin, angles, color );
	AddText( origin, className, targetName, color );
}

HighlightCuboid( origin, angles, measure, className, targetName, color )
{
	AddOrientedPoint( origin, angles, color );
	AddText( origin + ( 0,0,measure[2] ), className, targetName, color );
	/#
	for( i = 0; i < 2; i++ )
	{
		curZ = ( 0,0,measure[2]*i );
		Line( origin + curZ, origin + ( measure[0],0,0 ) + curZ, color, false, 1 );
		Line( origin + curZ, origin + ( 0,measure[1],0 ) + curZ, color, false, 1 );
		Line( origin + ( measure[0],measure[1],0 ) + curZ, origin + ( 0,measure[1],0 ) + curZ, color, false, 1 );
		Line( origin + ( measure[0],measure[1],0 ) + curZ, origin + ( measure[0],0,0 ) + curZ, color, false, 1 );
	}
	Line( origin, origin + ( 0,0,measure[2] ), color, false, 1 );
	Line( origin + ( measure[0],0,0 ), origin + ( measure[0],0,measure[2] ), color, false, 1 );
	Line( origin + ( 0,measure[1],0 ), origin + ( 0,measure[1],measure[2] ), color, false, 1 );
	Line( origin + ( measure[0],measure[1],0 ), origin + ( measure[0],measure[1],measure[2] ), color, false, 1 );
	#/
}

HighlightCylinder( origin, angles, radius, height, className, targetName, color )
{
	AddOrientedPoint( origin, angles, color );
	AddText( origin + ( 0,0,height ), className, targetName, color );
	/#
	lastPoint = origin + (AnglesToForward( ( 0, HL_INI_CYLINDER_ANGINC * (HL_INI_CYLINDER_VERTEXS-1), 0 ) ) * radius);
	for( vI = 0; vI < HL_INI_CYLINDER_VERTEXS; vI++ )
	{
		vStart = origin + (AnglesToForward( ( 0, HL_INI_CYLINDER_ANGINC * vI, 0 ) )* radius);
		vEnd = vStart + (0, 0, height);
		Line( lastPoint, vStart, color, false, 1 );
		Line( lastPoint + (0, 0, height), vEnd, color, false, 1 );
		Line( vStart, vEnd, color, false, 1 );
		lastPoint = vStart;
	}
	#/
}