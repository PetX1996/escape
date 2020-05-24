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

/// LOOK_DistanceZ( pos1, pos2 )
///
/// LOOK_GetPlayerHeadPos()
/// LOOK_GetPlayerHeight()
/// LOOK_GetPlayerCenterPos()
///
/// LOOK_GetPlayerLookVector()

/// Z�ska vzdialenos� medzi dvomi bodmi na osi Z
LOOK_DistanceZ( pos1, pos2 )
{
	z1 = pos1[2];
	z2 = pos2[2];
	
	if( z1 > z2 )
		return z1-z2;
	else
		return z2-z1;
}
/// Z�ska poz�ciu hlavy hr��a.
LOOK_GetPlayerViewPos()
{
	if( self.pers["team"] == "spectator" )
		return self.origin;
	else
	{
		stance = self GetStance();
		if( stance == "stand" ) 		return self.origin + ( 0,0,60 );
		else if( stance == "crouch" ) 	return self.origin + ( 0,0,40 );
		else 							return self.origin + ( 0,0,11 );
	}
}
/// Z�ska v��ku hr��a.
LOOK_GetPlayerHeight()
{
	if( self.pers["team"] == "spectator" )
		return 0;
	else
	{
		foot = self.origin;
		head = self GetTagOrigin( "j_helmet" );
		
		return head[2]-foot[2];
	}
}
/// Z�ska poz�ciu centra tela.
LOOK_GetPlayerCenterPos()
{
	if( self.pers["team"] == "spectator" )
		return self.origin;
	else
		return self.origin + ( 0, 0, self LOOK_GetPlayerHeight()/2 );
}

/// Z�ska vector, kam sa hr�� pozer�.
LOOK_GetPlayerLookVector()
{
	angles = self GetPlayerAngles();
	return AnglesToForward( angles );
}