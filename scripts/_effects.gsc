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
	if(!isdefined(level.escape_fx))
		level.escape_fx = [];

	level.escape_fx["visual/endround_player"] = LoadFX( "visual/endround_player" );
	//level.escape_fx["misc/m_resp"] = LoadFX( "misc/m_resp" );
	
	//level.escape_fx["misc/flashlight"] = LoadFX( "misc/flashlight" );
	//level.escape_fx["spray/spray_blue_smiley"] = LoadFX( "spray/spray_blue_smiley" ); //TODO: nazvy vytiahut z table...
	//level.escape_fx["spray/spray_blue_smiley"] = LoadFX( "spray/spray_blue_smiley" );
	
	// ============================================ //
	// ================ DEVELOPER ================= //
	//level.escape_fx["dev/laser"] = LoadFX( "dev/laser" );
	//level.escape_fx["dev/entitypoint"] = LoadFX( "dev/entitypoint" );
	//level.escape_fx["dev/distancepoint"] = LoadFX( "dev/distancepoint" );
	
	// ============================================ //
	
	level.escape_fx["explosions/aa_explosion"] = LoadFX( "explosions/aa_explosion" );
	
	level.escape_fx["impacts/blood_large"] = LoadFX( "impacts/blood_large" );
	level.escape_fx["impacts/blood_small"] = LoadFX( "impacts/blood_small" );
	
	/*level.escape_fx["visual/item_dron_fire"] = LoadFX( "visual/item_dron_fire" );
	level.escape_fx["visual/item_dron_laser"] = LoadFX( "visual/item_dron_laser" );
	level.escape_fx["visual/item_drone_blink"] = LoadFX( "visual/item_drone_blink" );
	level.escape_fx["visual/item_dron_engine"] = LoadFX( "visual/item_dron_engine" );
	*/

}


