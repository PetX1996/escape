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

/// -------------------------------------------------------------
/// MAIN WINDOW
/// -------------------------------------------------------------
/// -- MAIN --
/// TMENU()
/// 
/// -- SETTINGS --
/// TMENU_SetSectionWidth( size )
/// TMENU_SetBottomBar( type )
///
/// -- ADD --
/// TMENU_AddSection( name, material, position, buttonOnly )
/// TMENU_AddItem( section, name )
/// TMENU_AddSeparator( section )
/// TMENU_DeleteSection( position )
/// TMENU_DeleteItems( section )
///
/// -- ITEMS --
/// TMENU_ITEM_SetTitle( title )
/// TMENU_ITEM_SetSmallImage( material )
/// TMENU_ITEM_SetDescription( text )
/// TMENU_ITEM_SetImage( type, material, width, height )
/// TMENU_ITEM_SetStatInfo( current, max, currentString, maxString )
/// TMENU_ITEM_SetVerticalStatInfo( current, max, currentString, maxString )
/// TMENU_ITEM_SetAcceptButton( text, function )
///
/// TMENU_Show()
///
/// -------------------------------------------------------------
/// POPUP WINDOW
/// -------------------------------------------------------------
/// TMENU_POPUP( name, OnSelected, OnClose )
/// TMENU_POPUP_AddButton( name )
/// TMENU_POPUP_Show()
/// TMENU_POPUP_Close()
///  

#include scripts\include\_event;
#include scripts\include\_string;
#include scripts\include\_main;

// menufile
private TMENU_MENU_BUTTONS_COUNT = 15;
private TMENU_MENU_TEXTLINES_COUNT = 13;
private TMENU_MENU_SECTIONS_COUNT = 8;

// idFlags
private TMENU_FLAG_NOSELECTITEM = 1;

// ================================================================================================================================================================================================= //
// MAIN 
// ================================================================================================================================================================================================= //

///
/// VytvorÌ ötrukt˙ru.
///
TMENU()
{
	wait 0.001; // divnÈ, to cod je hrozne pomalÈ :(

	if( IsDefined( self.TMENU ) )
		return;
		
	self.TMENU = SpawnStruct();
	
	// settings
	self.TMENU.idFlags = 0;
	self.TMENU.ListWidth = 120;
	
	AddCallback( self, "onMenuResponse", ::TMENU_OnMenuResponse );
	self TMENU_Restore();
}
///
/// ZatvorÌ menu.
///
TMENU_Close()
{
	if( IsDefined( self.TMENU.POPUP ) )
		self TMENU_POPUP_Close();

	if( IsDefined( self.TMENU.OnCloseMenu ) )
		self [[ self.TMENU.OnCloseMenu ]]();

	self TMENU_Dispose();
}
///
/// Zlikviduje celÈ menu.
///
TMENU_Dispose()
{
	if( !IsDefined( self.TMENU ) ) return;
	
	DeleteCallback( self, "onMenuResponse", ::TMENU_OnMenuResponse );
	
	if( IsDefined( self.TMENU.Sections ) )
	{
		self.TMENU.Sections = undefined;
	}
	
	self.TMENU.OnSelectedSection = undefined; 	// ( sectionIndex, sectionName )
	self.TMENU.OnSelectedItem = undefined; 		// ( itemIndex, itemName, sectionIndex, sectionName )
	self.TMENU.OnAcceptButton = undefined; 		// ( itemIndex, itemName, sectionIndex, sectionName )
	self.TMENU.OnCloseMenu = undefined;
	
	self.TMENU.CurrentStartItem = undefined;
	self.TMENU.SelectedItemIndex = undefined;
	
	self.TMENU.ListWidth = undefined;
	self.TMENU.idFlags = undefined;
	
	self.TMENU.DvarList = undefined;
	
	self.TMENU = undefined;
	
	self CloseMenu();
	self CloseInGameMenu();
}
///
/// ObnovÌ celÈ menu.
///
TMENU_Restore( type )
{
	if( !IsDefined( self.TMENU ) ) return;
	
	if( !IsDefined( type ) )
		type = "";
	
	if( type != "item" )
	{
		self TMENU_SetInfo( "TMENU_listW", self.TMENU.ListWidth );
	
		for( i = 0; i < TMENU_MENU_SECTIONS_COUNT; i++ )
		{
			self TMENU_SetInfo( "TMENU_sectionT" + i );
			self TMENU_SetInfo( "TMENU_sectionP" + i );
		}
		
		self TMENU_SetInfo( "TMENU_bottomT" );
		self TMENU_SetInfo( "TMENU_sectionS" );
		
		for( i = 0; i < TMENU_MENU_BUTTONS_COUNT; i++ )
		{
			self TMENU_SetInfo( "TMENU_btn" + i );
		}
		
		self TMENU_SetInfo( "TMENU_btnS" );
		
		self TMENU_SetInfo( "TMENU_next" );
		self TMENU_SetInfo( "TMENU_prev" );
	}
	
	self TMENU_SetInfo( "TMENU_title" );
	
	for( i = 0; i < 3; i++ )
		self TMENU_SetInfo( "TMENU_sPic" + i );
		
	for( i = 0;i < TMENU_MENU_TEXTLINES_COUNT; i++ )
		self TMENU_SetInfo( "TMENU_text" + i );
		
	self TMENU_SetInfo( "TMENU_picTopW" );
	self TMENU_SetInfo( "TMENU_picTopH" );
	self TMENU_SetInfo( "TMENU_picTopM" );
	self TMENU_SetInfo( "TMENU_picBottomW" );
	self TMENU_SetInfo( "TMENU_picBottomH" );
	self TMENU_SetInfo( "TMENU_picBottomM" );
	self TMENU_SetInfo( "TMENU_picMiddleW" );
	self TMENU_SetInfo( "TMENU_picMiddleH" );
	self TMENU_SetInfo( "TMENU_picMiddleM" );
	
	self TMENU_SetInfo( "TMENU_accept" );
	
	for( i = 0; i < 3; i++ )
	{
		self TMENU_SetInfo( "TMENU_acceptStat"+ i +"_P" );
		self TMENU_SetInfo( "TMENU_acceptStat"+ i +"_C" );
		self TMENU_SetInfo( "TMENU_acceptStat"+ i +"_N" );
	}
	
	self TMENU_SetInfo( "TMENU_acceptStatSize" );
	self TMENU_SetInfo( "TMENU_acceptVStat_P" );
	self TMENU_SetInfo( "TMENU_acceptVStat_T" );
}
///
/// ZobrazÌ menu.
///
TMENU_Show()
{
	if( !IsDefined( self.TMENU ) ) return;
	
	//if( self TMENU_CheckIntegrity() )
		//self PrintDebug( "^5TMENU^7 - sections/items integrity error." );
	
	self TMENU_SelectSection( self TMENU_GetFirstSection() );
	
	//self TMENU_Refresh();
	self OpenMenu( game["menu_TMENU"] );
}
///
/// Kontroluje itemy v sekci·ch atÔ..
///
TMENU_CheckIntegrity( section )
{
	if( !IsDefined( self.TMENU.Sections ) )
		return true;
	
	if( !IsDefined( self.TMENU.Sections[section] ) )
		return true;
		
	if( self.TMENU.Sections[section] == "" || self.TMENU.Sections[section] == ";" )
		return true;
	
	return false;
}
///
/// Obsahuje sekcia aj text alebo to je iba tlaËÌtko?
///
TMENU_IsSectionOnlyButton( section )
{
	if( section == 20 )
		return false;

	if( !IsDefined( self.TMENU.Sections ) )
		return true;
	
	if( !IsDefined( self.TMENU.Sections[section] ) )
		return true;
		
	if( self.TMENU.Sections[section] == "" )
		return true;
	
	return false;
}

///
/// NastavÌ hodnotu dvaru, neposiela ku klientovi!
///
TMENU_SetInfo( dvarName, dvarValue )
{
	if( !IsDefined( self.TMENU ) ) return;
	
	if( !IsDefined( self.TMENU.DvarList ) ) 
		self.TMENU.DvarList = [];
		
	if( !IsDefined( dvarValue ) )
		dvarValue = "";
		
	self.TMENU.DvarList[ dvarName ] = "" + dvarValue + "";
}
///
/// ZÌska aktu·lnu hodnotu podæa n·zvu.
///
TMENU_GetInfo( dvarName )
{
	if( !IsDefined( self.TMENU ) ) return;

	return self.TMENU.DvarList[ dvarName ];
}
///
/// Poöle vöetky dvary ku klientovi.
///
TMENU_Refresh( type )
{
	if( !IsDefined( self.TMENU ) ) return;
	if( !IsDefined( self.TMENU.DvarList ) ) return;
	
	if( !IsDefined( type ) )
		type = "";
		
	dvars = [];
		
	switch( type )
	{
		case "list":
			for( i = 0; i < TMENU_MENU_BUTTONS_COUNT; i++ )
				dvars["TMENU_btn" + i] = self.TMENU.DvarList["TMENU_btn" + i];
				
			dvars["TMENU_btnS"] = self.TMENU.DvarList["TMENU_btnS"];
			dvars["TMENU_next"] = self.TMENU.DvarList["TMENU_next"];
			dvars["TMENU_prev"] = self.TMENU.DvarList["TMENU_prev"];
			break;
		case "item":
			dvars["TMENU_btnS"] = self.TMENU.DvarList["TMENU_btnS"];
			dvars["TMENU_title"] = self.TMENU.DvarList["TMENU_title"];
			
			for( i = 0; i < 3; i++ )
				dvars["TMENU_sPic" + i] = self.TMENU.DvarList["TMENU_sPic" + i];
				
			for( i = 0; i < TMENU_MENU_TEXTLINES_COUNT; i++ )
				dvars["TMENU_text" + i] = self.TMENU.DvarList["TMENU_text" + i];
				
			dvars["TMENU_picTopW"] = self.TMENU.DvarList["TMENU_picTopW"];
			dvars["TMENU_picTopH"] = self.TMENU.DvarList["TMENU_picTopH"];
			dvars["TMENU_picTopM"] = self.TMENU.DvarList["TMENU_picTopM"];
			dvars["TMENU_picBottomW"] = self.TMENU.DvarList["TMENU_picBottomW"];
			dvars["TMENU_picBottomH"] = self.TMENU.DvarList["TMENU_picBottomH"];
			dvars["TMENU_picBottomM"] = self.TMENU.DvarList["TMENU_picBottomM"];
			dvars["TMENU_picMiddleW"] = self.TMENU.DvarList["TMENU_picMiddleW"];
			dvars["TMENU_picMiddleH"] = self.TMENU.DvarList["TMENU_picMiddleH"];
			dvars["TMENU_picMiddleM"] = self.TMENU.DvarList["TMENU_picMiddleM"];
			
			dvars["TMENU_accept"] = self.TMENU.DvarList["TMENU_accept"];
			
			for( i = 0; i < 3; i++ )
			{
				dvars["TMENU_acceptStat"+ i +"_P"] = self.TMENU.DvarList["TMENU_acceptStat"+ i +"_P"];
				dvars["TMENU_acceptStat"+ i +"_C"] = self.TMENU.DvarList["TMENU_acceptStat"+ i +"_C"];
				dvars["TMENU_acceptStat"+ i +"_N"] = self.TMENU.DvarList["TMENU_acceptStat"+ i +"_N"];
			}
			dvars["TMENU_acceptStatSize"] = self.TMENU.DvarList["TMENU_acceptStatSize"];
			dvars["TMENU_acceptVStat_P"] = self.TMENU.DvarList["TMENU_acceptVStat_P"];
			dvars["TMENU_acceptVStat_T"] = self.TMENU.DvarList["TMENU_acceptVStat_T"];
			break;
		default:
			dvars = self.TMENU.DvarList;
			break;			
	}
	
	//self IPrintLn( "^1Refreshing TMENU..." );
	self [[ level.SendCvar ]]( dvars );
}

// ================================================================================================================================================================================================= //
// SETTINGS
// ================================================================================================================================================================================================= //

///
/// NastavÌ veækosù panela væavo(list)
///
TMENU_SetSectionWidth( size )
{
	self.TMENU.ListWidth = size;
	self TMENU_SetInfo( "TMENU_listW", size );
}
///
/// NastavÌ typ dolnÈho baru
/// 0 - staty + ACCEPT BTN
/// 1 - server connect
///
TMENU_SetBottomBar( type )
{
	self TMENU_SetInfo( "TMENU_bottomT", type );
}

// ================================================================================================================================================================================================= //
// ADD
// ================================================================================================================================================================================================= //

///
/// Prid· nov˙ sekciu.
///
TMENU_AddSection( name, material, position, buttonOnly )
{
	if( !IsDefined( self.TMENU ) ) return;
	
	if( !IsDefined( self.TMENU.Sections ) )
		self.TMENU.Sections = [];
		
	if( IsDefined( position ) && ( position < 0 || position > 7 ) )
		position = undefined;
		
	if( IsDefined( position ) )
		size = position;
	else
		size = self.TMENU.Sections.size;
	
	if( IsDefined( buttonOnly ) && buttonOnly )
		self.TMENU.Sections[size] = "";
	else
		self.TMENU.Sections[size] = ";";
	
	self TMENU_SetInfo( "TMENU_sectionT" + size, name );
	self TMENU_SetInfo( "TMENU_sectionP" + size, material );
	
	return size;
}
///
/// Prid· item do sekcie.
///
TMENU_AddItem( section, name )
{
	if( !IsDefined( self.TMENU ) ) return;
	
	self.TMENU.Sections[section] += name + ";";
}
///
/// Add Separator
///
TMENU_AddSeparator( section )
{
	if( !IsDefined( self.TMENU ) ) return;
	
	self.TMENU.Sections[section] += " ;";
}
///
/// Zmaûe sekciu na zvolenej pozÌcii.
///
TMENU_DeleteSection( position )
{
	if( !IsDefined( self.TMENU ) ) return;
	
	self.TMENU.Sections[position] = undefined;
	self TMENU_SetInfo( "TMENU_sectionT7" );
	self TMENU_SetInfo( "TMENU_sectionP7" );
}
///
/// Zmaûe vöetky itemy v sekcii
///
TMENU_DeleteItems( section )
{
	if( !IsDefined( self.TMENU ) ) return;
	
	self.TMENU.Sections[section] = ";";
}

// ================================================================================================================================================================================================= //
// ITEMS
// ================================================================================================================================================================================================= //

///
/// Spracovanie v˝stupu z menu.
///
TMENU_OnMenuResponse( menu, response )
{
	if( !IsDefined( self.TMENU ) ) return;

	if( menu != "tmenu" )
		return;
		
	if( IsSubStr( response, "TMENU_section_" ) )
	{
		section = StrTok( response, "_" )[2];
		self TMENU_SelectSection( int( section ) );
	}
	else if( IsSubStr( response, "TMENU_btn_" ) )
	{
		item = StrTok( response, "_" )[2];
		self TMENU_SelectItem( int( item ), true );
	}
	else if( response == "TMENU_next" )
	{
		self TMENU_SlideItems( 1 );
	}
	else if( response == "TMENU_prev" )
	{
		self TMENU_SlideItems( -1 );
	}
	else if( response == "TMENU_accept" )
	{
		self TMENU_AcceptButton();
	}
	else if( response == "TMENU_close" || response == "TMENU_esc" )
	{
		if( IsDefined( self.TMENU.POPUP ) && response == "TMENU_esc" )
		{
			self TMENU_POPUP_Close();
		}
		else
		{
			if( IsDefined( self.TMENU.OnCloseMenu ) )
				self [[ self.TMENU.OnCloseMenu ]]();
				
			self TMENU_Dispose();
		}
	}
	else if( IsSubStr( response, "TMENU_pp_btn_" ) )
	{
		if( !IsDefined( self.TMENU.POPUP ) )
			return;
	
		num = int( StrTok( response, "_" )[3] );
		
		if( IsDefined( self.TMENU.POPUP.OnSelected ) )
			self [[ self.TMENU.POPUP.OnSelected ]]( num, self.TMENU.POPUP.DvarList["TMENU_pp_btn_"+num] );
	}
}
///
/// Vybraù konkrÈtnu sekciu.
///
TMENU_SelectSection( section )
{
	if( self TMENU_IsSectionOnlyButton( section ) )
	{
		if( IsDefined( self.TMENU.OnSelectedSection ) )
			self [[ self.TMENU.OnSelectedSection ]]( section, self TMENU_GetSectionName( section ) );

		return;
	}

	self TMENU_SetSelectedSection( section );

	if( self TMENU_CheckIntegrity( section ) ) // empty section
	{
		self TMENU_SetInfo( "TMENU_listW", 0 );
		self TMENU_SetInfo( "TMENU_prev", false );
		self TMENU_SetInfo( "TMENU_next", false );
		
		self TMENU_UpdateCurrentItems();
		
		self TMENU_SelectItem();
		
		if( IsDefined( self.TMENU.OnSelectedSection ) )
			self [[ self.TMENU.OnSelectedSection ]]( section, self TMENU_GetSectionName( section ) );		
		
		self TMENU_Refresh();
		
		return;
	}
	
	self TMENU_SetInfo( "TMENU_listW", self.TMENU.ListWidth );
	
	items = self TMENU_GetItemsFromSection( section );
	
	self TMENU_UpdateCurrentItems( items );
	
	self.TMENU.CurrentStartItem = 0;
	
	self TMENU_SetInfo( "TMENU_prev", false );
	if( items.size > TMENU_MENU_BUTTONS_COUNT )
		self TMENU_SetInfo( "TMENU_next", true );
	else
		self TMENU_SetInfo( "TMENU_next", false );
	
	
	if( !(self.TMENU.idFlags & TMENU_FLAG_NOSELECTITEM) )
		self TMENU_SelectItem( self TMENU_GetFirstItem( section ) );
	
	if( IsDefined( self.TMENU.OnSelectedSection ) )
		self [[ self.TMENU.OnSelectedSection ]]( section, self TMENU_GetSectionName( section ) );
	
	self TMENU_Refresh();
}
///
/// Vybraù konkrÈtny item.
///
TMENU_SelectItem( item, refresh )
{
	if( !IsDefined( item ) )
	{
		self TMENU_Restore( "item" );

		if( IsDefined( refresh ) && refresh )
			self TMENU_Refresh( "item" );

		return;
	}

	self TMENU_SetSelectedItem( item );
	self.TMENU.SelectedItemIndex = self TMENU_GetItemIndex( item );
	
	self TMENU_Restore( "item" );
	
	self TMENU_ITEM_SetTitle( self TMENU_GetItemName( item ) );
	
	self.TMENU.OnAcceptButton = undefined; // reset accept button
	
	section = self TMENU_GetSelectedSection();
	item = self TMENU_GetSelectedItem();
	
	itemIndex = self TMENU_GetItemIndex( item );
	itemArray = self TMENU_GetItemsFromSection( section );
	
	if( IsDefined( self.TMENU.OnSelectedItem ) )
		self [[ self.TMENU.OnSelectedItem ]]( itemIndex, itemArray[itemIndex], section, self TMENU_GetSectionName( section ) );
		
		
	if( IsDefined( refresh ) && refresh )
		self TMENU_Refresh( "item" );
}
///
/// Pohyb medzi itemami.
///
TMENU_SlideItems( type )
{
	items = TMENU_GetItemsFromSection( self TMENU_GetSelectedSection() );
	
	startCurrent = self.TMENU.CurrentStartItem;
	startTarget = ( TMENU_MENU_BUTTONS_COUNT * type ) + startCurrent;
	
	if( startTarget < 0 )
		startTarget = 0;
	
	self.TMENU.CurrentStartItem = startTarget;
	
	self TMENU_SetInfo( "TMENU_btnS", 30 );
	
	targetItems = [];
	index = 0;
	for( i = startTarget; i < items.size && index < TMENU_MENU_BUTTONS_COUNT; i++ )
	{
		if( i == self.TMENU.SelectedItemIndex )
			self TMENU_SetInfo( "TMENU_btnS", index );
	
		targetItems[index] = items[i];
		index++;
	}
	
	self TMENU_UpdateCurrentItems( targetItems );
	
	if( index == TMENU_MENU_BUTTONS_COUNT && i < items.size )
		self TMENU_SetInfo( "TMENU_next", true );
	else
		self TMENU_SetInfo( "TMENU_next", false );
	
	if( startTarget >= TMENU_MENU_BUTTONS_COUNT )
		self TMENU_SetInfo( "TMENU_prev", true );
	else
		self TMENU_SetInfo( "TMENU_prev", false );
	
	self TMENU_Refresh( "list" );
}
///
/// TlaËÌtko :)
///
TMENU_AcceptButton()
{
	section = self TMENU_GetSelectedSection();
	item = self TMENU_GetSelectedItem();
	
	itemIndex = self TMENU_GetItemIndex( item );
	itemArray = self TMENU_GetItemsFromSection( section );
	
	if( IsDefined( self.TMENU.OnAcceptButton ) )
		self [[ self.TMENU.OnAcceptButton ]]( itemIndex, itemArray[itemIndex], section, self TMENU_GetSectionName( section ) );
}
///
/// ZÌska itemy zo zvolenej sekcie.
///
TMENU_GetItemsFromSection( section )
{
	itemsStr = self.TMENU.Sections[section];
	items = [];
	
	toks = StrTok( itemsStr, ";" );
	
	for( i = 0; i < toks.size; i++ )
	{
		if( !IsDefined( toks[i] ) )
			continue;
	
		if( toks[i] == "" )
			continue;
			
		items[items.size] = toks[i];
	}
	
	return items;
}
///
/// Vr·ti n·zov sekcie.
///
TMENU_GetSectionName( section )
{
	if( section == 20 )
		return "";

	text = self TMENU_GetInfo( "TMENU_sectionT"+section );
	return text;
}
///
/// Aktualizuje aktu·lny zoznam itemov.
///
TMENU_UpdateCurrentItems( items )
{
	for( i = 0; i < TMENU_MENU_BUTTONS_COUNT; i++ )
		self TMENU_SetInfo( "TMENU_btn" + i );

	if( !IsDefined( items ) )
		return;
		
	for( i = 0; i < items.size && i < TMENU_MENU_BUTTONS_COUNT; i++ )
	{
		self TMENU_SetInfo( "TMENU_btn" + i, items[i] );
	}
}
///
/// Navr·ti zoznam aktu·lnych itemov.
///
TMENU_GetCurrentItems()
{
	items = [];
	for( i = 0; i < TMENU_MENU_BUTTONS_COUNT; i++ )
	{
		name = self TMENU_GetInfo( "TMENU_btn" + i );
		if( !IsDefined( name ) || name == "" )
			break;
			
		items[i] = name;
	}
	
	return items;
}
///
/// Vr·ti index itemu z prÌsluöÈho poæa sekcie podæa indexu zobrazen˝ch itemov.
///
TMENU_GetItemIndex( item )
{
	sectionItems = self TMENU_GetItemsFromSection( self TMENU_GetSelectedSection() );
	currentItems = self TMENU_GetCurrentItems();
	
	for( i = 0; i < sectionItems.size; i++ )
	{
		if( sectionItems[i] == currentItems[item] )
			return i;
	}
	
	return -1;
}
///
/// Vr·ti n·zov itemu v aktu·lne zvolenej sekcii.
///
TMENU_GetItemName( item )
{
	currentItems = self TMENU_GetCurrentItems();
	return currentItems[item];
}
///
/// NastavÌ aktu·lne vybran˙ poloûku 0 - 15
///
TMENU_SetSelectedItem( item )
{
	self TMENU_SetInfo( "TMENU_btnS", item );
}
///
/// Vr·ti aktu·lne vybran˙ poloûku 0 - 15
///
TMENU_GetSelectedItem()
{
	return int( self TMENU_GetInfo( "TMENU_btnS" ) );
}
///
/// NastavÌ aktu·lne vybran˙ sekciu
///
TMENU_SetSelectedSection( section )
{
	self TMENU_SetInfo( "TMENU_sectionS", section );
}
///
/// Vr·ti aktu·lne vybran˙ sekciu
///
TMENU_GetSelectedSection()
{
	return int( self TMENU_GetInfo( "TMENU_sectionS" ) );
}
///
/// Vr·ti prv˙ pouûiteæn˙ sekciu v zozname
///
TMENU_GetFirstSection()
{
	for( i = 0; i < TMENU_MENU_SECTIONS_COUNT; i++ )
	{
		if( IsDefined( self.TMENU.Sections[i] ) && self.TMENU.Sections[i] != "" && self.TMENU.Sections[i] != ";" )
			return i;
	}
	
	return 20;
}
///
/// Vr·ti prv˝ pouûiteæn˝ item v sekcii
///
TMENU_GetFirstItem( section )
{
	items = self TMENU_GetItemsFromSection( section );
	
	for( i = 0; i < items.size; i++ )
	{
		if( !IsDefined( items[i] ) || items[i] == "" || items[i] == " " )
			continue;
		else
			return i;
	}
	
	self PrintDebug( "^5TMENU^7 - no items in section!" );
	return 0;
}

// ================================================================================================================================================================================================= //
// ITEM 
// ================================================================================================================================================================================================= //

///
/// NastavÌ aktu·lny n·zov poloûky.
///
TMENU_ITEM_SetTitle( title )
{
	self TMENU_SetInfo( "TMENU_title", title );
}
///
/// NastavÌ malÈ obr·zky.
///
TMENU_ITEM_SetSmallImage( material )
{
	for( i = 0; i < 3; i++ )
	{
		if( self TMENU_GetInfo( "TMENU_sPic" + i ) == "" )
		{
			self TMENU_SetInfo( "TMENU_sPic" + i, material );
			return;
		}
	}
	
	self PrintDebug( "^5TMENU^7 - exceeded maximum small image." );
}
///
/// Popis itemu, je moûnÈ pouûÌvaù aj znak '\n' :)
///
TMENU_ITEM_SetDescription( text )
{
	imageSize = [];
	imageSize[0] = self TMENU_GetInfo( "TMENU_picTopW" );
	imageSize[1] = self TMENU_GetInfo( "TMENU_picMiddleW" );
	imageSize[2] = self TMENU_GetInfo( "TMENU_picBottomW" );

	maxImageSize = 0;
	for( i = 0; i < 3; i++ )
	{
		if( int( imageSize[i] ) == 0 )
			continue;
			
		if( int( imageSize[i] ) > maxImageSize )
			maxImageSize = int( imageSize[i] );
	}

	lines = TextAutoWrapped( text, int( ( 571 - self.TMENU.ListWidth - maxImageSize ) / 7 ) );
	
	for( i = 0; i < lines.size && i < TMENU_MENU_TEXTLINES_COUNT; i++ )
		self TMENU_SetInfo( "TMENU_text"+i, lines[i] );
	
	if( i == TMENU_MENU_TEXTLINES_COUNT )
		self PrintDebug( "^5TMENU^7 - exceeded maximum text lines." );	
	
	for( ; i < TMENU_MENU_TEXTLINES_COUNT; i++ )
		self TMENU_SetInfo( "TMENU_text"+i );
}
///
/// Prid· obr·zok
/// 'top' 'middle' 'bottom'
/// Width: 452.5(447.5) Height: 220(215)
///
TMENU_ITEM_SetImage( type, material, width, height )
{
	switch( ToLower( type ) )
	{
		case "top":
			type = "Top";
			break;
		case "middle":
			type = "Middle";
			break;
		case "bottom":
			type = "Bottom";
			break;
		default:
			return;
	}
	
	self TMENU_SetInfo( "TMENU_pic"+ type +"M", material );
	self TMENU_SetInfo( "TMENU_pic"+ type +"W", width );
	self TMENU_SetInfo( "TMENU_pic"+ type +"H", height );
}
///
///	Prid· status nejakej hodnoty - prachy, XP, atÔ.
///
TMENU_ITEM_SetStatInfo( current, max, currentString, maxString )
{
	if( !IsDefined( currentString ) ) currentString = current;
	if( !IsDefined( maxString ) ) maxString = max;

	currentInt = int( current );
	maxInt = int( max );

	p = 100;
	if( maxInt != 0 )
		p = (currentInt / maxInt) * 100;

	if( p > 100 )
		p = 100;
	
	for( i = 0; i < 3; i++ )
	{
		if( self TMENU_GetInfo( "TMENU_acceptStat"+ i +"_P" ) != "" )
			continue;
			
		self TMENU_SetInfo( "TMENU_acceptStat"+ i +"_C", currentString );
		self TMENU_SetInfo( "TMENU_acceptStat"+ i +"_N", maxString );
		self TMENU_SetInfo( "TMENU_acceptStat"+ i +"_P", p );
		
		self TMENU_SetInfo( "TMENU_acceptStatSize", i + 1 );
		return;
	}
	
	self PrintDebug( "^5TMENU^7 - exceeded maximum stat count." );
}
///
/// Prid· status nejakej hodnoty - prachy, XP, atÔ. - prekryje ACCEPT btn!
///
TMENU_ITEM_SetVerticalStatInfo( current, max, currentString, maxString )
{
	if( !IsDefined( currentString ) ) currentString = current;
	if( !IsDefined( maxString ) ) maxString = max;

	currentInt = int( current );
	maxInt = int( max );

	p = 100;
	if( maxInt != 0 )
		p = (currentInt / maxInt) * 100;

	if( p > 100 )
		p = 100;
	
	self TMENU_SetInfo( "TMENU_acceptVStat_T", currentString + " / " + maxString );
	self TMENU_SetInfo( "TMENU_acceptVStat_P", p );	
}
///
/// Priradenie ˙lohy tlaËÌtku :)
///
TMENU_ITEM_SetAcceptButton( text, function )
{
	self TMENU_SetInfo( "TMENU_accept", text );
	self.TMENU.OnAcceptButton = function;
}


// ================================================================================================================================================================================================= //
// POPUP
// ================================================================================================================================================================================================= //

///
///  VytvorÌ nov˝ POPUP
///
TMENU_POPUP( name, onSelected, onClose )
{
	self.TMENU.POPUP = SpawnStruct();
	self.TMENU.POPUP.DvarList = [];
	self.TMENU.POPUP.OnSelected = onSelected; // ( index, name )
	self.TMENU.POPUP.OnClose = onClose;
	
	self.TMENU.POPUP.DvarList["TMENU_pp_name"] = name;
	self.TMENU.POPUP.DvarList["TMENU_pp_btns"] = "0";
	
	for( i = 0; i < 5; i++ )
		self.TMENU.POPUP.DvarList["TMENU_pp_btn_"+i] = "";
}
///
/// ZatvorÌ menu
///
TMENU_POPUP_Close()
{
	if( IsDefined( self.TMENU.POPUP.OnClose ) )
		self [[ self.TMENU.POPUP.OnClose ]]();

	self TMENU_POPUP_Dispose();
	self SetClientDvar( "TMENU_pp_name", "" );
}
///
/// Zlikviduje vöetky premennÈ
///
TMENU_POPUP_Dispose()
{
	self.TMENU.POPUP = undefined;
}
///
/// ZobrazÌ POPUP
///
TMENU_POPUP_Show()
{
	self [[ level.SendCvar ]]( self.TMENU.POPUP.DvarList );
}
///
/// Prid· new tlaËÌtko
///
TMENU_POPUP_AddButton( name )
{
	for( i = 0; i < 5; i++ )
	{
		if( self.TMENU.POPUP.DvarList["TMENU_pp_btn_"+i] == "" )
		{
			self.TMENU.POPUP.DvarList["TMENU_pp_btns"] = i + 1;
			self.TMENU.POPUP.DvarList["TMENU_pp_btn_"+i] = name;			
		
			return;
		}
	}

	self PrintDebug( "^5TMENU^7 - exceeded maximum buttons in POPUP" );
}
