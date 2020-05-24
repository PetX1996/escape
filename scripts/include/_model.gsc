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

/// MODEL_SetModelTag( tag )
/// HideToPlayer( player )
///	ShowToPlayers( playersList )

#include scripts\include\_array;

/// Nechá na modele zobrazený len tento tag.
MODEL_SetModelTag( model, tag )
{
	self Hide();
	tags = MODEL_GetTagsFromModel( model );
	
	self ShowAllParts();
	for( t = 0; t < tags.size; t++ )
	{
		if( tags[t] != tag )
			self HidePart( tags[t] );
	}
	
	wait 0.05;
	self Show();
}

/// Zoznam tagov pre jednotlivé multimodely
MODEL_GetTagsFromModel( model )
{
	tags = [];
	switch( model )
	{
		case "4gf_special_model_dr":
			tags = [];
			tags[tags.size] = "tag_chest_b"; // dt bedna modra - finish
			tags[tags.size] = "tag_chest_r"; // dt bedna ruda - finish
			tags[tags.size] = "tag_random_box"; // box s otaznikom - kazda past, 1/5 ze padne -
			tags[tags.size] = "tag_4gf_coin"; // peniaz - normal
			tags[tags.size] = "tag_ammo_box"; // ammo box
			tags[tags.size] = "tag_hp_box"; // lekarnicka
			tags[tags.size] = "tag_hardpoint_box"; // box s lebkou s random HP -
			break;
		default:
			break;
	}
	return tags;
}

HideToPlayers( playersList )
{
	self Hide();
	
	for( p = 0; p < level.players.size; p++ )
	{
		player = level.players[p];
		
		if( IsInArray( playersList, player ) )
			continue;
			
		self ShowToPlayer( player );
	}
}

ShowToPlayers( playersList )
{
	self Hide();
	
	for( p = 0; p < level.players.size; p++ )
	{
		player = level.players.size;
		
		if( IsInArray( playersList, player ) )
			self ShowToPlayer( player );
	}
}