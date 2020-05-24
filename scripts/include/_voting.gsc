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

#include scripts\include\_event;

/// VOTING()
/// VOTING_Start( items, time, title, subTitle, onChangeWinningItem )
/// VOTING_SetTitle( text )
/// VOTING_SetSubTitle( text )

VOTING()
{
	level.VOTING = SpawnStruct();
	AddCallback( level, "onMenuResponse", ::VOTING_OnMenuResponse );
	AddCallback( level, "disconnected", ::VOTING_OnPlayerDisconnected );
	
	VOTING_Clear();
	
	for( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if( IsDefined( player ) )
			player VOTING_PreparePlayer();
	}
	
	VOTING_Refresh();
}

VOTING_PreparePlayer()
{
	self scripts\clients\_hud::HideHud();
	self scripts\clients\_teams::JoinSpectator();

	self allowSpectateTeam( "allies", false );
	self allowSpectateTeam( "axis", false );
	self allowSpectateTeam( "freelook", false );
	self allowSpectateTeam( "none", false );
		
	self.VOTING = SpawnStruct();
	self.VOTING.Selected = undefined;
	self OpenMenu( game["menu_voting"] );
}

VOTING_Start( items, time, title, subTitle, onChangeWinningItem )
{
	level.VOTING.Dvars = [];
	level.VOTING.OnChangeWinningItem = onChangeWinningItem;
	
	for( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if( IsDefined( player ) && IsDefined( player.VOTING ) )
			player.VOTING.Selected = undefined;
	}
	
	VOTING_Clear();
	
	VOTING_AddItems( items );
	VOTING_SetTitle( title );
	VOTING_SetSubTitle( subTitle );
	
	VOTING_Refresh();
	
	
	wait time;
	
	
	winner = VOTING_GetWinningItem();
	
	level.VOTING.Dvars = undefined;
	level.VOTING.OnChangeWinningItem = undefined;
	
	return winner;
}

VOTING_Clear()
{
	VOTING_SetInfo( "VOTING_count" );
	VOTING_SetInfo( "VOTING_title" );
	VOTING_SetInfo( "VOTING_subTitle" );
}

VOTING_Dispose()
{
	DeleteCallback( level, "onMenuResponse", ::VOTING_OnMenuResponse );
	DeleteCallback( level, "disconnected", ::VOTING_OnPlayerDisconnected );
	
	for( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
	
		if( !IsDefined( player ) )
			continue;

		player.VOTING = undefined;
	}
	
	level.VOTING = undefined;
}

VOTING_AddItems( items )
{
	for( i = 0; i < items.size; i++ )
	{
		VOTING_SetInfo( "VOTING_item"+i+"N", items[i] );
		VOTING_SetInfo( "VOTING_item"+i+"V", 0 );
	}
	VOTING_SetInfo( "VOTING_count", items.size );
}
VOTING_GetItems()
{
	items = [];
	while( true )
	{
		item = VOTING_GetInfo( "VOTING_item"+items.size+"N" );
		if( !IsDefined( item ) || item == "" )
			break;
		
		items[items.size] = item;
	}
	return items;
}
VOTING_AddVotes( votes )
{
	for( i = 0; i < votes.size; i++ )
		VOTING_SetInfo( "VOTING_item"+i+"V", votes[i] );
}
VOTING_GetVotes()
{
	votes = [];
	while( true )
	{
		vote = VOTING_GetInfo( "VOTING_item"+votes.size+"V" );
		if( !IsDefined( vote ) || vote == "" )
			break;
		
		votes[votes.size] = Int( vote );
	}
	return votes;	
}

VOTING_OnMenuResponse( player, menu, response )
{
	if( menu != "voting" || !IsDefined( player ) || !IsDefined( player.VOTING ) )
		return;
		
	if( IsSubStr( response, "VOTING_vote_" ) ) // VOTING_vote_<num>
		player VOTING_OnVoted( Int( StrTok( response, "_" )[2] ), player.VOTING.Selected );
}

VOTING_OnVoted( selected, oldSelected )
{
	if( IsDefined( selected ) && IsDefined( oldSelected ) && selected == oldSelected )
		return;

	oldWinner = undefined;
	if( IsDefined( level.VOTING.onChangeWinningItem ) )
		oldWinner = VOTING_GetWinningItem();
		
	votes = VOTING_GetVotes();
	
	if( IsDefined( oldSelected ) )
		votes[oldSelected]--;
		
	if( IsDefined( selected ) )
	{
		votes[selected]++;
		self.VOTING.Selected = selected;
	}
	
	VOTING_AddVotes( votes );
	
	if( IsDefined( level.VOTING.onChangeWinningItem ) )
	{
		newWinner = VOTING_GetWinningItem();
		if( oldWinner != newWinner )
			[[ level.VOTING.onChangeWinningItem ]]( newWinner );
	}

	VOTING_Refresh();
}

VOTING_OnPlayerDisconnected( player )
{
	if( IsDefined( player ) && IsDefined( player.VOTING ) && IsDefined( player.VOTING.Selected ) )
		player VOTING_OnVoted( undefined, player.VOTING.Selected );
}

VOTING_SetInfo( name, value )
{
	if( !IsDefined( level.VOTING.Dvars ) )
		level.VOTING.Dvars = [];

	if( !IsDefined( value ) )
		level.VOTING.Dvars[name] = "";
	else
		level.VOTING.Dvars[name] = ""+value;
}
VOTING_GetInfo( name )
{
	return level.VOTING.Dvars[name];
}
VOTING_Refresh()
{
	for( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if( IsDefined( player ) && IsDefined( player.VOTING ) )
			player [[level.SendCvar]]( level.VOTING.Dvars );
	}
}

VOTING_SetTitle( text )
{
	VOTING_SetInfo( "VOTING_title", text );
}
VOTING_SetSubTitle( text )
{
	VOTING_SetInfo( "VOTING_subTitle", text );
}

VOTING_GetWinningItem()
{
	items = VOTING_GetItems();
	votes = VOTING_GetVotes();
	winner = items[0];
	curVote = 0;
	for( i = 0; i < items.size; i++ )
	{
		if( IsDefined( votes[i] ) && votes[i] > curVote )
		{
			curVote = votes[i];
			winner = items[i];
		}
	}
	return winner;
}