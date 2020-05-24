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
#include scripts\include\_event;

private SHOP_QUICKBUY_RESETVALUE = 100;
private SHOP_QUICKBUY_PRIMARYWEAPON = 3301;
private SHOP_QUICKBUY_GRENADE = 3302;
private SHOP_QUICKBUY_SPECIALGRENADE = 3303;
private SHOP_QUICKBUY_EQUIPMENT = 3304;
private SHOP_QUICKBUY_GEAR = 3305;

// TODO: dorieöiù, Ëo ak m· hr·Ë uû dan˙ vec k˙pen˙? doplniù ammo?



OpenShop()
{
	self.SHOP = SpawnStruct();
	self UpdateInventoryDvars();
	AddCallback( self, "onMenuResponse", ::OnMenuResponse );
	
	self OpenMenu( game["menu_shop"] );
}

CloseShop()
{
	DeleteCallback( self, "onMenuResponse", ::OnMenuResponse );
	self.SHOP = undefined;
	self CloseMenu();
	self CloseInGameMenu();
}

UpdateInventoryDvars()
{
	dvars = [];
	if( IsDefined( self.pers["Inventory"]["primaryWeapon"] ) ) dvars["SHOP_invPrim"] = self.pers["Inventory"]["primaryWeapon"];
	else dvars["SHOP_invPrim"] = -1;
	
	if( IsDefined( self.pers["Inventory"]["grenade"] ) ) dvars["SHOP_invFrag"] = self.pers["Inventory"]["grenade"];
	else dvars["SHOP_invFrag"] = -1;
	
	if( IsDefined( self.pers["Inventory"]["specialGrenade"] ) ) dvars["SHOP_invSFrag"] = self.pers["Inventory"]["specialGrenade"];
	else dvars["SHOP_invSFrag"] = -1;
	
	if( IsDefined( self.pers["Inventory"]["equipment"] ) ) dvars["SHOP_invEq"] = self.pers["Inventory"]["equipment"];
	else dvars["SHOP_invEq"] = -1;
	
	if( IsDefined( self.pers["Inventory"]["gear"] ) ) dvars["SHOP_invGr"] = self.pers["Inventory"]["gear"];
	else dvars["SHOP_invGr"] = -1;
	
	self [[level.SendCvar]]( dvars );
}

OnMenuResponse( menu, response )
{
	if( menu != game["menu_shop"] )
		return;
		
	if( !IsDefined( self.SHOP ) )
		self CloseShop();
		
	if( response == "SHOP_close" || (response == "SHOP_esc" && !IsDefined( self.SHOP.POPUP )) )
	{
		self CloseShop();
		return;
	}
	if( response == "SHOP_esc" || response == "SHOP_popCanc" )
	{
		self DestroyPopUpWindow();
		return;
	}
	if( response == "SHOP_popOK" )
	{
		if( IsDefined( self.SHOP.POPUP.onOK ) )
			self [[self.SHOP.POPUP.onOK]]();
			
		self DestroyPopUpWindow();
		return;
	}
	
	if( IsSubStr( response, "SHOP_quickAdd_" ) ) //"SHOP_quickAdd_"Ttype"_"TlineIndex
	{
		toks = StrTok( response, "_" );
		self AddToQuickBuy( toks[2], int(toks[3]) );
		return;
	}
	if( IsSubStr( response, "SHOP_quickDel_" ) ) //"SHOP_quickDel_"Qstat
	{
		self DeleteFromQuickBuy( int(StrTok( response, "_" )[2]) );
		return;
	}
	
	if( IsSubStr( response, "SHOP_btn_" ) ) //"SHOP_btn_"TlineIndex
	{
		self scripts\shop\_shopMain::BuyItem( StrTok( response, "_" )[2] );
		return;
	}
	if( IsSubStr( response, "SHOP_quickBuy_" ) ) //"SHOP_quickBuy_"Qstat
	{
		self scripts\shop\_shopMain::BuyItem( self GetStat( int(StrTok( response, "_" )[2]) ) );
		return;
	}
	if( response == "SHOP_quickBuyAll" )
	{
		self QuickBuyAll();
		return;
	}
	if( response == "SHOP_restoreAmmo" )
	{
		self scripts\shop\_shopMain::RestoreAmmo();
		return;
	}
}

QuickBuyAll()
{
	if( !BuyForStat( SHOP_QUICKBUY_PRIMARYWEAPON ) ) return;
	if( !BuyForStat( SHOP_QUICKBUY_GRENADE ) ) return;
	if( !BuyForStat( SHOP_QUICKBUY_SPECIALGRENADE ) ) return;
	if( !BuyForStat( SHOP_QUICKBUY_EQUIPMENT ) ) return;
	if( !BuyForStat( SHOP_QUICKBUY_GEAR ) ) return;
}
BuyForStat( stat )
{
	value = self GetStat( stat );
	if( value != SHOP_QUICKBUY_RESETVALUE )
		return self scripts\shop\_shopMain::BuyItem( value );
	
	return true;
}

AddToQuickBuy( type, lineIndex )
{
	switch( type )
	{
		case "Assault":
		case "SMG":
		case "LMG":
		case "Shotgun":
		case "Sniper":
			self SetStat( SHOP_QUICKBUY_PRIMARYWEAPON, lineIndex );
			break;
		case "Grenade":
			if( scripts\clients\_weapons::GetGrenadeType( TableLookUp( "mp/WeaponsTable.csv", 0, lineIndex, 9 ) ) == "grenade" )
				self SetStat( SHOP_QUICKBUY_GRENADE, lineIndex );
			else
				self SetStat( SHOP_QUICKBUY_SPECIALGRENADE, lineIndex );
				
			break;
		case "Equipment":
			self SetStat( SHOP_QUICKBUY_EQUIPMENT, lineIndex );
			break;
		case "Gear":
			self SetStat( SHOP_QUICKBUY_GEAR, lineIndex );
			break;
		default:
			PrintDebug( "Error in quickbuy, unknown type "+type+", lineIndex "+lineIndex );
			break;
	}
}
DeleteFromQuickBuy( stat )
{
	self SetStat( stat, SHOP_QUICKBUY_RESETVALUE );
}

CreatePopUpWindow( title, content, onOK )
{
	self.SHOP.POPUP = SpawnStruct();
	self.SHOP.POPUP.onOK = onOK;
	self SetClientDvars( "SHOP_visPop", 1, "SHOP_popT", title, "SHOP_popC", content );
}
DestroyPopUpWindow()
{
	self.SHOP.POPUP = undefined;
	self SetClientDvar( "SHOP_visPop", 0 );
}