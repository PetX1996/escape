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
#include scripts\include\_string;
#include scripts\include\_class;
#include scripts\include\_event;
#include scripts\include\_item;

init()
{

}

CAC_OnOpenMenu( team )
{
	/#
	IPrintLnBold( "Developer script is ENABLED!" );
	return;
	#/

	if( IsDefined( self.CAC ) )
	{
		self CAC_Close();
		wait 0.05;
	}

	self.CAC = SpawnStruct();
	self.CAC.Team = team;
	self.CAC.ClassSelected = self CLASS_GetSpawnClass( team );
	
	AddCallback( self, "onMenuResponse", ::CAC_OnMenuResponse );
	self OpenMenu( game["menu_class_"+team] );
}
CAC_Dispose()
{
	self DeleteCallback( self, "onMenuResponse", ::CAC_OnMenuResponse );
	
	self.CAC = undefined;
}
CAC_Close()
{
	self CAC_Dispose();

	self CloseMenu();
	self CloseInGameMenu();
}

CAC_OnMenuResponse( menu, response )
{
	if( response == "CLASS_esc" )
	{
		if( IsDefined( self.CAC.SPAMWINDOW ) )
			self CAC_SPAMWINDOW_Close();
		else if( IsDefined( self.CAC.POPUP ) )
			self CAC_POPUP_Close();
		else
			self CAC_Close();
		
		return;
	}
	
	if( response == "CLASS_close" )
	{
		self CAC_Dispose();
		return;
	}
	
	if( IsSubStr( response, "CLASS_cSel_" ) ) //"CLASS_cSel_"num_s
	{
		self.CAC.ClassSelected = int( StrTok( response, "_" )[2] );
		return;
	}
	
	if( IsSubStr( response, "CLASS_popup_" ) ) //"CLASS_popup_"TABLE_TYPE_FIGURE_I
	{
		self CAC_POPUP_Open( int( StrTok( response, "_" )[2] ) );
		return;
	}
	
	if( IsSubStr( response, "CLASS_btn_" ) ) //"CLASS_btn_"TlineIndex
	{
		self CAC_OnClickOnItem( int( StrTok( response, "_" )[2] ) );
		return;
	}
	
	if( response == "CLASS_cSpawn" )
	{
		self CLASS_SetSpawnClass( self.CAC.Team, self.CAC.ClassSelected );
		self CAC_Close();
		return;
	}
	
	if( response == "CLASS_spamW_OK" )
	{
		if( IsDefined( self.CAC.SPAMWINDOW ) && IsDefined( self.CAC.SPAMWINDOW.onOK ) )
			self [[ self.CAC.SPAMWINDOW.onOK ]]();
			
		self CAC_SPAMWINDOW_Close();
		return;
	}
	if( response == "CLASS_spamW_C" )
	{
		self CAC_SPAMWINDOW_Close();
		return;
	}
}

CAC_OnClickOnItem( TlineIndex )
{
	file = TABLE_FILE_AXIS;
	if( self.CAC.Team == "allies" )
		file = TABLE_FILE_ALLIES;

	Tname = ITEM_GetTableName( file, TlineIndex );
	Tstat = ITEM_GetTableStat( file, TlineIndex );
	Tpermission = ITEM_GetTablePermission( file, TlineIndex );
	Trank = ITEM_GetTableRank( file, TlineIndex );
	Tprice = ITEM_GetTablePrice( file, TlineIndex );
	
	Afull = ITEM_IsAvailableFull( file, TlineIndex, Tstat, Tpermission, Trank );
	Aselected = (self CAC_GetCurrentSlotItem() != TlineIndex);
	
	if( Afull && Aselected ) // pl·cni item do slotu
	{
		slotStat = CLASS_GetSlotStat( self.CAC.Team, self.CAC.ClassSelected, self.CAC.POPUP.typeIndex );
		self SetStat( slotStat, TlineIndex );
		self CAC_POPUP_Close();
	}
	else if( !Afull ) // ups! item nie je dostupn˝!
	{
		AxpBuyType = self ITEM_IsAvailableToXPBuy( file, TlineIndex, Tstat, Tpermission, Tprice );
		AxpBuy = self ITEM_IsAvailableXpBuy( file, TlineIndex, Tprice, Trank );
		
		if( !AxpBuyType ) // item nie je urËen˝ na n·kup :(
		{
			self CAC_SPAMWINDOW_Open( "Locked", "Item is locked." );
			return;
		}
		else
		{
			if( AxpBuy ) // kupujeme!!!
			{
				self CAC_SPAMWINDOW_Open( "Confirm buying", "Want you really buy ^1"+Tname+" ^7behind ^1"+Tprice+" ^7XP", ::CAC_BuyItemBehindXp );
				self.CAC.SPAMWINDOW.TlineIndex = TlineIndex;
				self.CAC.SPAMWINDOW.Tstat = Tstat;
				self.CAC.SPAMWINDOW.Tprice = Tprice;
				self.CAC.SPAMWINDOW.file = file;
				return;				
			}
			else // need xp!! :(
			{
				self CAC_SPAMWINDOW_Open( "Need XP/LVL", "You need more XP or higher LVL to buying this item!" );
				return;				
			}
		}
	}
	else // ups! item uû v slote je!
	{
		self CAC_SPAMWINDOW_Open( "Already Selected", "Item is already selected." );
	}
}

CAC_BuyItemBehindXp()
{
	self ITEM_BuyItem( self.CAC.SPAMWINDOW.file, self.CAC.SPAMWINDOW.TlineIndex, self.CAC.SPAMWINDOW.Tstat, self.CAC.SPAMWINDOW.Tprice );
}

CAC_GetCurrentSlotItem()
{
	stat = CLASS_GetSlotStat( self.CAC.Team, self.CAC.ClassSelected, self.CAC.POPUP.typeIndex );
	return self GetStat( stat );
}

CAC_POPUP_Open( typeIndex )
{
	self.CAC.POPUP = SpawnStruct();

	self.CAC.POPUP.typeIndex = typeIndex;
	self SetClientDvar( "CLASS_visPop", 1 );
}
CAC_POPUP_Close()
{
	self.CAC.POPUP = undefined;
	self SetClientDvar( "CLASS_visPop", 0 );
}

CAC_SPAMWINDOW_Open( title, description, onOK )
{
	self.CAC.SPAMWINDOW = SpawnStruct();
	self.CAC.SPAMWINDOW.onOK = onOK;
	
	self SetClientDvars( "CLASS_spamT", title, "CLASS_spamC", description );
}
CAC_SPAMWINDOW_Close()
{
	self.CAC.SPAMWINDOW = undefined;
	self SetClientDvar( "CLASS_spamT", "" );
}

// ================================================================================================================================================================================================= //
// ModifyItem
// ================================================================================================================================================================================================= //
// Ako upraviù cenu/level/dostupnosù?
// 1. ModifyItem( ... )
//
//
// t˙to funckiu je moûnÈ zavolaù na objekty level/player
// najskÙr sa stanovia ˙daje podæa levelu, potom podæa konkrÈtneho hr·Ëa...
// ================================================================================================================================================================================================= //
/*ModifyItem( stat, smallImage, permission, price, rank )
{
	if( !isDefined( self.modifyClass ) )
		self.modifyClass = [];
		
	self.modifyClass[stat] = "";
	
	self.modifyClass[stat] = ModifyItem_AddValue( self.modifyClass[stat], smallImage );
	self.modifyClass[stat] = ModifyItem_AddValue( self.modifyClass[stat], permission );
	self.modifyClass[stat] = ModifyItem_AddValue( self.modifyClass[stat], price );
	self.modifyClass[stat] = ModifyItem_AddValue( self.modifyClass[stat], rank );
}

ModifyItem_AddValue( var, value )
{
	value = ""+value+"";

	if( IsDefined( value ) && value != "" )
		var += value;
	else
		var += " ";
		
	var += ";";
	return var;
}
// ================================================================================================================================================================================================= //

///
/// Inicializ·cia CAC.
///
CAC_OnOpenMenu( team, classIndex )
{
	self.CAC = SpawnStruct();
	self.CAC.Team = team;
	self.CAC.ClassIndex = classIndex;
	
	self CAC_BuildMenu();
}
///
/// Deötrukcia CAC.
///
CAC_Dispose()
{
	self.CAC.Team = undefined;
	self.CAC.ClassIndex = undefined;
	self.CAC.AcceptType = undefined;
	self.CAC = undefined;
}
///
/// Zostavenie menu.
///
CAC_BuildMenu()
{
	self TMENU();
	
	types = self CLASS_GetAllTypes();
	for( i = 0; i < types.size; i++ )
	{
		type = types[i];
			
		image = CLASS_GetImageByType( type );
		sectionI = self TMENU_AddSection( type, image );
		
		self CAC_AddItemsToSection( sectionI, type );
	}
	
	self TMENU_AddSection( "Class", "weapon_c4", 7, true );
	
	self.TMENU.NoSelectItem = true;
	self.TMENU.OnSelectedSection = ::CAC_OnSelectedSection;
	self.TMENU.OnSelectedItem = ::CAC_OnSelectedItem;
	
	self TMENU_Show();
}

CAC_AddItemsToSection( sectionIndex, type )
{
	saveItem = self CLASS_GetSavedItemFromType( type );
	items = self CLASS_GetItemsFromType( type );
	for( j = 0; j < items.size; j++ )
	{
		name = self CLASS_GetItemName( items[j] );
		prefix = "";
		if( items[j] == saveItem )
			prefix = "^2";
			
		self TMENU_AddItem( sectionIndex, prefix + name );
	}
}

CAC_OnSelectedSection( sectionIndex, sectionName )
{
	if( sectionIndex == 7 ) // select class
	{
		self TMENU_POPUP( "Change Class", ::CAC_POPUP_ChangeClass );
		self TMENU_POPUP_AddButton( "Class #1" );
		self TMENU_POPUP_AddButton( "Class #2" );
		self TMENU_POPUP_AddButton( "Class #3" );
		self TMENU_POPUP_Show();
		return;
	}

	saveItem = self CLASS_GetSavedItemFromType( sectionName );
	typeIndex = self CLASS_GetTypeStartIndex( sectionName );
	
	self TMENU_SelectItem( saveItem - typeIndex );
}
CAC_POPUP_ChangeClass( index, name )
{
	self TMENU_Close();
	self CAC_OnOpenMenu( self.CAC.Team, index );
}

CAC_OnSelectedItem( itemIndex, itemName, sectionIndex, sectionName )
{
	self CAC_BuildItemInfo( sectionName, itemIndex, itemName );
}

CAC_OnAcceptButton( itemIndex, itemName, sectionIndex, sectionName )
{
	lineIndex = self CLASS_GetTypeStartIndex( sectionName ) + itemIndex;

	if( self.CAC.AcceptType == ACCEPTTYPE_SELECT )
	{
		stat = self CLASS_GetTypeStat( sectionName );
		lineIndex = self CLASS_GetTypeStartIndex( sectionName ) + itemIndex;
		self scripts\clients\_stats::SetStatValue( stat, lineIndex );
		
		self TMENU_DeleteItems( sectionIndex );
		self CAC_AddItemsToSection( sectionIndex, sectionName );
		self TMENU_SelectSection( sectionIndex );
	}
	else
	{
		stat = self CLASS_GetItemStat( lineIndex );
		price = self CLASS_GetItemPrice( lineIndex );
		
		if( self.pers["rankxp"] >= price )
		{
			self [[level.giveScore]]( "buy", price * -1 );
			self scripts\clients\_stats::UnlockStat( stat );
			
			self TMENU_SelectItem( itemIndex, true );
			self PrintDebug( "buy!" );
		}
		else
			self PrintDebug( "CAC: Error! kupa mozna, prachy ziadne..." );
	}
}

CAC_BuildItemInfo( type, itemIndex, itemName )
{
	self.CAC.AcceptType = undefined;

	lineIndex = self CLASS_GetTypeStartIndex( type ) + itemIndex;
	
	description = self CLASS_GetItemInfo( lineIndex );
	
	available = self CLASS_IsAvailable( lineIndex );
	
	smallImage = self CLASS_GetItemSmallImage( lineIndex );
	image = self CLASS_GetItemImage( lineIndex );
	
	stat = self CLASS_GetItemStat( lineIndex );
	perm = self CLASS_GetItemPerm( lineIndex );
	//iprintln( "avb: "+available );
	if( !available )
	{
		if( perm == PERMISSION_BUY || perm == PERMISSION_TIME )
		{
			price = self CLASS_GetItemPrice( lineIndex );
			rank = self CLASS_GetItemRank( lineIndex );
			
			self TMENU_ITEM_SetStatInfo( self.pers["rankxp"] + " XP", price + " XP" );
			self TMENU_ITEM_SetStatInfo( self.pers["rank"] + " LVL", rank + " LVL" );
			
			if( self.pers["rankxp"] >= price && self.pers["rank"] >= rank )
			{
				self TMENU_ITEM_SetAcceptButton( "BUY NOW", ::CAC_OnAcceptButton );
				self.CAC.AcceptType = ACCEPTTYPE_BUY;
			}
		}
	}
	else
	{
		saveItem = self CLASS_GetSavedItemFromType( type );
		if( saveItem != lineIndex )
		{
			self TMENU_ITEM_SetAcceptButton( "SELECT", ::CAC_OnAcceptButton );
			self.CAC.AcceptType = ACCEPTTYPE_SELECT;
		}
		
		if( perm == PERMISSION_TIME )
		{
			remainingTime = scripts\clients\_stats::GetTimeRemaining( stat );
			totalTime = mp\_timeStats::GetStatTime( stat );
			self TMENU_ITEM_SetStatInfo( remainingTime, totalTime, STR_MinutesToTime( remainingTime ), STR_MinutesToTime( totalTime ) );
		}
	}
	
	switch( type )
	{
		case "Figure":
			if( image != "" )
				self TMENU_ITEM_SetImage( "middle", image, 140, 210 );

			description += "\n\nHealth: "+self CLASS_GetItemValue( lineIndex, 13 );
			description += "\nSpeed: "+self CLASS_GetItemValue( lineIndex, 14 );
			description += "\nJump: "+self CLASS_GetItemValue( lineIndex, 15 );	
			break;
		case "Weapon":
			if( image != "" )
				self TMENU_ITEM_SetImage( "top", image, 140, 110 );
				
			description += "\n\nBullet Damage: "+self CLASS_GetItemValue( lineIndex, 11 );
			description += "\nKnife Damage: "+self CLASS_GetItemValue( lineIndex, 12 );
			break;
		case "Spray":
			if( image != "" )
				self TMENU_ITEM_SetImage( "middle", image, 210, 210 );
				
			break;			
		default:
			if( image != "" )
				self TMENU_ITEM_SetImage( "top", image, 110, 110 );
				
			break;
	}
	
	self TMENU_ITEM_SetDescription( description );
	
	if( smallImage != "" )
		self TMENU_ITEM_SetSmallImage( smallImage );
}

///
/// Vr·ti obr·zok sekcie
///
CLASS_GetImageByType( type, team )
{
	if( !IsDefined( team ) )
		team = self.CAC.Team;
		
	return "weapon_c4"; // TODO: obr·zok zbrane/postavy/etc.
}*/