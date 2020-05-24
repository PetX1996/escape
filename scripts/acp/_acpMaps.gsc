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

#include scripts\include\_string;
#include scripts\include\_acp;

OnSelectedSection()
{
	self UpdateMapInfo();
}

UpdateMapInfo()
{
	self ACP_SetText( "Map: "+level.script+"( "+level.gametype+" )" );
	self ACP_SetText( "Round: "+game["rounds"]+"/"+level.dvars["logic_roundLimit"] );
}

RoundRestart()
{
	map_restart( true );
}

MapRestart()
{
	ExitLevel( false );
}

EndRound()
{
	[[ level.EndRound ]]();
}

EndMap()
{
	[[ level.EndMap ]]();
}

RunMap()
{
	self ACP_POPUP_LIST( "Run Map", ::RunMap_Map );
	self ACP_POPUP_LIST_AddItem( "Map", ::RunMap_OnChangeMap );
	self ACP_POPUP_LIST_AddItem( "GameType", ::RunMap_OnChangeGameType );
	self ACP_POPUP_Show();
}

RunMap_OnChangeMap( currentItem, currentIndex, change )
{
	maxIndex = mp\_mapList::GetMapsCount();
	
	if( currentIndex < 0 )
		currentIndex = maxIndex - 1;
	
	if( currentIndex >= maxIndex )
		currentIndex = 0;

	map = mp\_mapList::GetMapForIndex( currentIndex );
	self ACP_POPUP_LIST_UpdateItem( currentItem, currentIndex, map.FullName );
	
	self RunMap_OnChangeGameType( currentItem+1, 0, 0 );
}

RunMap_OnChangeGameType( currentItem, currentIndex, change )
{
	map = mp\_mapList::GetMapForIndex( self.ACP.POPUP.ListIndexes[currentItem-1] );
	
	if( currentIndex < 0 )
		currentIndex = map.GameTypes.size - 1;
		
	if( currentIndex >= map.GameTypes.size )
		currentIndex = 0;
	
	self ACP_POPUP_LIST_UpdateItem( currentItem, currentIndex, scripts\_mapvoting::GameTypeToFullName( map.GameTypes[currentIndex] ) );
}

RunMap_Map()
{
	map = mp\_mapList::GetMapForIndex( self.ACP.POPUP.ListIndexes[0] );
	gametype = map.GameTypes[self.ACP.POPUP.ListIndexes[1]];
	[[ level.EndMap ]]( map.Name, gametype );
}