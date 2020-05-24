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

init()
{
	thread RemoveProblemEntities();
}

RemoveProblemEntities()
{
	ents = GetEntArray();
	length = ents.size;
	for( i = 0; i < length; i++ )
	{
		if( !IsDefined( ents[i] ) )
			continue;
	
		if( GetSubStr( ents[i].className, 0, 7 ) == "weapon_" )
			ents[i] Delete();
	}
}