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

#include scripts\include\_main;

init()
{

}

UseSpray()
{	
	if( !isDefined( self.spray ) )
		return;
	
	/*	
	angles = self GetPlayerAngles();	
	origin = self getTagOrigin( "j_head" );//+AnglesToForward( (angles[0], angles[1], 0) )+height;

	trace = bullettrace( origin, origin+( AnglesToForward( angles )*100000), false, self );
	point = trace["position"];
	fraction = trace["fraction"];
		
	if(isdefined(point) && isdefined(distance(point, origin)))
	{
		if(distance(point, origin) > 70)	
			return;
		
		if(fraction == 1)
			return;
	}
		
	//iprintln("spray apply" );	
	PlayFX( self.spray, origin, AnglesToForward( angles ), AnglesToUp( angles ));
	*/
	
	angles = self getPlayerAngles();
	eye = self getTagOrigin( "j_head" );
	forward = eye + vector_scale( anglesToForward( angles ), 70 );
	trace = bulletTrace( eye, forward, false, self );
	
	if( trace["fraction"] == 1 ) //we didnt hit the wall or floor
		return;
		
	position = trace["position"] - vector_scale( anglesToForward( angles ), -2 );
	angles = vectorToAngles( eye - position );
	forward = anglesToForward( angles );
	up = anglesToUp( angles );

	playFx( AddFXtoList( self.spray ), position, forward, up );
}
