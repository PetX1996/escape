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

private MUSIC_ENDROUND_PREFIX = "endround_";
private MUSIC_ENDROUND_COUNT = 0;

private MUSIC_ENDMAP_PREFIX = "endmap_";
private MUSIC_ENDMAP_COUNT = 0;

GetMusicNameBySoundAlias( soundalias )
{
	switch( soundalias )
	{
		default:
			return "";
	}
}

/// Spustí hudbu na konci kola
PlayEndRoundMusic( number )
{
	if( !IsDefined( number ) || number >= MUSIC_ENDROUND_COUNT )
		number = RandomInt( MUSIC_ENDROUND_COUNT );
		
	AmbientStop( 1 );
	AmbientPlay( MUSIC_ENDROUND_PREFIX + number, 0.5 );
}

/// Spustí hudbu na konci mapy
PlayEndMapMusic( number )
{
	if( !IsDefined( number ) || number >= MUSIC_ENDMAP_COUNT )
		number = RandomInt( MUSIC_ENDMAP_COUNT );
		
	AmbientStop( 1 );
	AmbientPlay( MUSIC_ENDMAP_PREFIX + number, 1 );	
}