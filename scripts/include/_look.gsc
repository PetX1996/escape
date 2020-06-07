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

/// Získa vzdialenos medzi dvomi bodmi na osi Z
LOOK_DistanceZ( pos1, pos2 )
{
	z1 = pos1[2];
	z2 = pos2[2];
	
	if( z1 > z2 )
		return z1-z2;
	else
		return z2-z1;
}
/// Získa pozíciu hlavy hráèa.
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
/// Získa výšku hráèa.
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
/// Získa pozíciu centra tela.
LOOK_GetPlayerCenterPos()
{
	if( self.pers["team"] == "spectator" )
		return self.origin;
	else
		return self.origin + ( 0, 0, self LOOK_GetPlayerHeight()/2 );
}

/// Získa vector, kam sa hráè pozerá.
LOOK_GetPlayerLookVector()
{
	angles = self GetPlayerAngles();
	return AnglesToForward( angles );
}

LOOK_IsPlayerLookAtObject( ent, detectRadius, detectHeight, playerDistance, lookDisabled, traceDisabled )
{
	if (!IsDefined(lookDisabled)) lookDisabled = false;
	if (!IsDefined(traceDisabled)) traceDisabled = false;

	pos = self LOOK_GetPlayerViewPos();
	vec = self LOOK_GetPlayerLookVector();
	dist = Distance2D( pos, ent.origin );
	
	if( lookDisabled 
		&& dist < playerDistance 
		&& LOOK_DistanceZ( self LOOK_GetPlayerCenterPos(), ent.origin ) < detectHeight )
		return true;
	
	point = pos + (vec * Distance( pos, ent.origin ));
	trace = BulletTrace( pos, point, true, self );

	if( trace["fraction"] == 1 || (IsDefined( trace["entity"] ) && trace["entity"] == ent) )
		trace = true;
	else 
		trace = false;
	
	if (Distance2D( point, ent.origin ) < detectRadius
		&& LOOK_DistanceZ( point, ent.origin ) < detectHeight 
		&& ((!traceDisabled && trace) || traceDisabled)
		&& ((IsDefined( playerDistance ) && Distance2D( pos, point ) < playerDistance) || !IsDefined( playerDistance )))
		return true;
	else
		return false;
}