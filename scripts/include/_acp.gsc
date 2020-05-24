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

/// ACP()
/// ACP_AddButton( section, name, function )
/// ACP_Show()

/// ACP_AddList( currentIndex, onSlideItem ) // onSlideItem( currentIndex, change )
/// ACP_UpdateList( currentIndex, value )

/// ACP_SetText( text )

/// ACP_POPUP_Notice( title, text, onOK, onClose ) // onOK(), onClose()
/// ACP_POPUP_LIST( title, onOK, onClose ) // onOK(), onClose()
/// ACP_POPUP_LIST_AddItem( name, onChange ) // onChange( currentItem, currentIndex, change )
/// ACP_POPUP_LIST_UpdateItem( currentItem, currentIndex, value )
/// ACP_POPUP_Show()

#include scripts\include\_event;

// menufile
private ACP_MENU_BUTTONS_COUNT = 13;
private ACP_MENU_TEXTLINES_COUNT = 10;
private ACP_MENU_SECTIONS_COUNT = 3;

private ACP_SECTION_MAPS = 0;
private ACP_SECTION_PLAYERS = 1;
private ACP_SECTION_OTHERS = 2;

// ================================================================================================================================================================================================= //

ACP_SendB3Command( command )
{
	logLine = "say;" + self GetGuid() + ";" + self GetEntityNumber() + ";" + self.Name + ";!" + command;
	logPrint( logLine + "\n" );
}

// ================================================================================================================================================================================================= //

ACP_AddButton( section, name, function )
{
	info = SpawnStruct();
	info.Name = name;
	info.Function = function;
	
	size = self.ACP.Sections[section].size;
	self.ACP.Sections[section][size] = info;
}

///
/// VytvorÌ ötrukt˙ru.
///
ACP()
{
	wait 0.001; // divnÈ, to cod je hrozne pomalÈ :(

	if( IsDefined( self.ACP ) )
		return;
		
	self.ACP = SpawnStruct();
	
	self.ACP.DvarList = [];
	self.ACP.CurrentSection = undefined;
	self.ACP.CurrentStartItem = undefined;
	
	self.ACP.CurrentTextLine = 0;
	
	self.ACP.ListIndex = undefined;
	self.ACP.OnSlideListItem = undefined; // ( currentIndex, change )
	
	self.ACP.OnSelectedSection = undefined; // ( section )
	
	self.ACP.Sections = [];
	self.ACP.Sections[ACP_SECTION_MAPS] = [];
	self.ACP.Sections[ACP_SECTION_PLAYERS] = [];
	self.ACP.Sections[ACP_SECTION_OTHERS] = [];
	
	AddCallback( self, "onMenuResponse", ::ACP_OnMenuResponse );
	
	self ACP_Restore();
}
///
/// ZatvorÌ menu.
///
ACP_Close()
{
	self ACP_Dispose();
}
///
/// Zlikviduje celÈ menu.
///
ACP_Dispose()
{
	DeleteCallback( self, "onMenuResponse", ::ACP_OnMenuResponse );
	
	self.ACP = undefined;
	
	self CloseMenu();
	self CloseInGameMenu();
}
///
/// ObnovÌ celÈ menu.
///
ACP_Restore()
{
	self ACP_FreeInfo();
	self ACP_DeleteText();
}
///
/// ZobrazÌ menu.
///
ACP_Show()
{
	//self ACP_Restore();
	self ACP_Refresh();
	self OpenMenu( game["menu_acp"] );
}
///
/// NastavÌ hodnotu dvaru, neposiela ku klientovi!
///
ACP_SetInfo( dvarName, dvarValue )
{
	if( !IsDefined( dvarValue ) )
		dvarValue = "";
		
	self.ACP.DvarList[ dvarName ] = "" + dvarValue;
}
///
/// Poöle vöetky dvary ku klientovi.
///
ACP_Refresh()
{
	//self IPrintLn( "^1Refreshing ACP..." );
	self [[ level.SendCvar ]]( self.ACP.DvarList );
	
	self ACP_FreeInfo();
}
ACP_FreeInfo()
{
	self.ACP.DvarList = [];
	self.ACP.CurrentTextLine = 0;
}

///
/// Spracovanie v˝stupu z menu.
///
ACP_OnMenuResponse( menu, response )
{
	if( !IsDefined( self.ACP ) ) 
	{
		self ACP_Dispose();
		return;
	}

	if( menu != "acp" )
		return;
		
	if( IsSubStr( response, "ACP_secS_" ) )
	{
		section = StrTok( response, "_" )[2];
		self ACP_SelectSection( Int( section ) );
	}
	else if( IsSubStr( response, "ACP_btn_" ) )
	{
		item = StrTok( response, "_" )[2];
		self ACP_SelectItem( Int( item ) );
	}
	else if( response == "ACP_next" )
	{
		self ACP_SlideItems( 1 );
	}
	else if( response == "ACP_prev" )
	{
		self ACP_SlideItems( -1 );
	}
	else if( response == "ACP_lnext" )
	{
		self ACP_ListSlideItems( 1 );
	}
	else if( response == "ACP_lprev" )
	{
		self ACP_ListSlideItems( -1 );
	}
	else if( response == "ACP_close" )
	{
		self ACP_Dispose();
	}
	else if( response == "ACP_esc" )
	{
		if( IsDefined( self.ACP.POPUP ) )
			self ACP_POPUP_Close();
		else
			self ACP_Close();
	}
	else if( response == "ACP_pOK" )
	{
		if( IsDefined( self.ACP.POPUP.OnOK ) )
			self [[ self.ACP.POPUP.OnOK ]]();
			
		self ACP_POPUP_Close();
	}
	else if( IsSubStr( response, "ACP_pLprev_" ) )
	{
		item = StrTok( response, "_" )[2];
		self ACP_POPUP_LIST_SlideListItems( Int( item ), -1 );
	}
	else if( IsSubStr( response, "ACP_pLnext_" ) )
	{
		item = StrTok( response, "_" )[2];
		self ACP_POPUP_LIST_SlideListItems( Int( item ), 1 );
	}
}

ACP_SelectSection( section )
{
	self ACP_UpdateCurrentItems( self.ACP.Sections[section] );
	
	self ACP_DeleteList();
	self ACP_DeleteText();
	
	self.ACP.CurrentSection = section;
	self.ACP.CurrentStartItem = 0;
	
	self ACP_SetInfo( "ACP_prev", false );
	if( self.ACP.Sections[section].size > ACP_MENU_BUTTONS_COUNT )
		self ACP_SetInfo( "ACP_next", true );
	else
		self ACP_SetInfo( "ACP_next", false );
	
	if( IsDefined( self.ACP.OnSelectedSection ) )
		self [[ self.ACP.OnSelectedSection ]]( section );
	
	self ACP_Refresh();
}
///
/// Vybraù konkrÈtny item.
///
ACP_SelectItem( item )
{
	itemStruct = self.ACP.Sections[self.ACP.CurrentSection][self.ACP.CurrentStartItem + item];
	
	if( IsDefined( itemStruct.Function ) )
		[[ itemStruct.Function ]]();
}
///
/// Pohyb medzi itemami.
///
ACP_SlideItems( type )
{
	items = self.ACP.Sections[self.ACP.CurrentSection];
	
	startCurrent = self.ACP.CurrentStartItem;
	startTarget = ( ACP_MENU_BUTTONS_COUNT * type ) + startCurrent;
	
	if( startTarget < 0 )
		startTarget = 0;
	
	self.ACP.CurrentStartItem = startTarget;
	
	targetItems = [];
	index = 0;
	for( i = startTarget; i < items.size && index < ACP_MENU_BUTTONS_COUNT; i++ )
	{
		targetItems[index] = items[i];
		index++;
	}
	
	self ACP_UpdateCurrentItems( targetItems );
	
	if( index == ACP_MENU_BUTTONS_COUNT && i < items.size )
		self ACP_SetInfo( "ACP_next", true );
	else
		self ACP_SetInfo( "ACP_next", false );
	
	if( startTarget >= ACP_MENU_BUTTONS_COUNT )
		self ACP_SetInfo( "ACP_prev", true );
	else
		self ACP_SetInfo( "ACP_prev", false );
	
	self ACP_Refresh();
}
/// Aktualizuje aktu·lny zoznam itemov.
ACP_UpdateCurrentItems( items )
{
	for( i = 0; i < ACP_MENU_BUTTONS_COUNT; i++ )
		self ACP_SetInfo( "ACP_btn" + i );

	if( !IsDefined( items ) )
		return;
		
	for( i = 0; i < items.size && i < ACP_MENU_BUTTONS_COUNT; i++ )
		self ACP_SetInfo( "ACP_btn" + i, items[i].Name );
}

ACP_AddList( currentIndex, onSlideItem )
{
	self ACP_SetInfo( "ACP_vis1", true );
	self.ACP.ListIndex = currentIndex;
	self.ACP.OnSlideListItem = onSlideItem;
	
	self ACP_ListSlideItems( 0 );
}
ACP_UpdateList( currentIndex, value )
{
	self ACP_SetInfo( "ACP_lI", value );
	self.ACP.ListIndex = currentIndex;
	
	self ACP_Refresh();
}
ACP_DeleteList()
{
	self.ACP.ListIndex = undefined;
	self.ACP.OnSlideListItem = undefined;
	self ACP_SetInfo( "ACP_vis1" );
}
ACP_ListSlideItems( change )
{
	self.ACP.ListIndex += change;
	[[ self.ACP.OnSlideListItem ]]( self.ACP.ListIndex, change );
}

ACP_SetText( text )
{
	self ACP_SetInfo( "ACP_t"+self.ACP.CurrentTextLine, text );
	self.ACP.CurrentTextLine++;
}
ACP_DeleteText()
{
	self.ACP.CurrentTextLine = 0;
	for( i = 0; i < ACP_MENU_TEXTLINES_COUNT; i++ )
		self ACP_SetText( "" );
		
	self.ACP.CurrentTextLine = 0;
}

ACP_POPUP_Notice( title, text, onOK, onClose )
{
	self.ACP.POPUP = SpawnStruct();
	self.ACP.POPUP.OnOK = onOK;
	self.ACP.POPUP.OnClose = onClose;
	self.ACP.POPUP.Showed = undefined;
	
	self ACP_SetInfo( "ACP_vis2", "1" );
	self ACP_SetInfo( "ACP_pT", title );
	self ACP_SetInfo( "ACP_pC", text );
}

ACP_POPUP_LIST( title, onOK, onClose )
{
	self.ACP.POPUP = SpawnStruct();
	self.ACP.POPUP.OnOK = onOK;
	self.ACP.POPUP.OnClose = onClose;
	self.ACP.POPUP.Showed = undefined;
	self.ACP.POPUP.OnListChange = [];
	self.ACP.POPUP.ListIndexes = [];
	
	self ACP_SetInfo( "ACP_vis2", "2" );
	self ACP_SetInfo( "ACP_pT", title );
}
ACP_POPUP_LIST_AddItem( name, onChange )
{
	currentItem = self.ACP.POPUP.OnListChange.size;
	
	self ACP_SetInfo( "ACP_pL"+currentItem, name );
	self ACP_SetInfo( "ACP_pLIC", currentItem+1 );
	
	self.ACP.POPUP.OnListChange[currentItem] = onChange;
	self.ACP.POPUP.ListIndexes[currentItem] = 0;
	
	self ACP_POPUP_LIST_SlideListItems( currentItem, 0 );
}
ACP_POPUP_LIST_UpdateItem( currentItem, currentIndex, value, noUpdate )
{
	self.ACP.POPUP.ListIndexes[currentItem] = currentIndex;
	self ACP_SetInfo( "ACP_pLI"+currentItem, value );
	
	if( IsDefined( self.ACP.POPUP.Showed ) )
		self ACP_Refresh();
}
ACP_POPUP_LIST_SlideListItems( currentItem, change )
{
	self.ACP.POPUP.ListIndexes[currentItem] += change;
	[[ self.ACP.POPUP.OnListChange[currentItem] ]]( currentItem, self.ACP.POPUP.ListIndexes[currentItem], change );
}

ACP_POPUP_Show()
{
	self.ACP.POPUP.Showed = true;
	self ACP_Refresh();
}

ACP_POPUP_Close()
{
	self.ACP.POPUP = undefined;
	self ACP_SetInfo( "ACP_vis2" );
	self ACP_Refresh();
}
