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

/// MATH_Power( n, exponent )
/// MATH_DistanceNumber( n1, n2 )
/// 

///
///
///
MATH_Power( n, exponent )
{
	if( exponent == 0 )
		return 1;

	result = 1;
	while( exponent != 0 )
	{
		if( exponent > 0 )
		{
			result *= n;
			exponent--;
		}
		else
		{
			result /= n;
			exponent++;
		}
	}
	return result;
}

///
/// Vzdialenosù 2 ËÌsiel na ËÌselnej osi
///
MATH_DistanceNumber( n1, n2 )
{
	return MATH_Abs( n1-n2 );
}

MATH_Abs( n )
{
	if( n < 0 )
		n *= -1;
		
	return n;
}

///
/// ZÌska random FLOAT so znamienkom
///
MATH_RandomUFloat( min, max )
{
	move = min;
	if( move < 0 )
		move *= -1;

	min += move;
	max += move;

	r = RandomFloat( min, max );
	r -= move;
	return r;
}
///
/// ZÌska random INT so znamienkom
///
MATH_RandomUInt( min, max )
{
	return Int( MATH_RandomUFloat( min, max ) );
}