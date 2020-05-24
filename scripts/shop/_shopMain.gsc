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

#include scripts\include\_item;

private SHOP_FILE = "mp/WeaponsTable.csv";

init()
{
	/*level.SHOP = SpawnStruct();
	level.SHOP.Triggers = GetEntArray( "escape_shop", "targetname" );
	
	for( t = 0; t < level.SHOP.Triggers.size; t++ )
		level.SHOP.Triggers[t] thread CheckUseTrigger();*/
}

HideTriggers()
{
	for( i = 0; i < level.SHOP.Triggers.size; i++ )
		level.SHOP.Triggers[i].origin += (0,0,-100000);
}

ShowTriggers()
{
	for( i = 0; i < level.SHOP.Triggers.size; i++ )
		level.SHOP.Triggers[i].origin += (0,0,100000);
}

CheckUseTrigger()
{
	if( self.classname != "trigger_use_touch" )
		return;

	while( true )
	{
		self waittill( "trigger", player );
		
		if( player.pers["team"] != "allies" )
			continue;
			
		player scripts\shop\_shopMenu::OpenShop();
	}
}

BuyItem( TlineIndex )
{
	Tstat = ITEM_GetTableStat( SHOP_FILE, TlineIndex );
	Tpermission = ITEM_GetTablePermission( SHOP_FILE, TlineIndex );
	Tprice = ITEM_GetTablePrice( SHOP_FILE, TlineIndex );
	Trank = ITEM_GetTableRank( SHOP_FILE, TlineIndex );
	Tmoney = ITEM_GetTableMoney( SHOP_FILE, TlineIndex );
	
	// available states
	Aperm = self ITEM_IsAvailablePermission( SHOP_FILE, TlineIndex, Tstat, Tpermission, Trank );
	Amoney = self ITEM_IsAvailableMoney( SHOP_FILE, TlineIndex, Tmoney );
	AxpBuyType = self ITEM_IsAvailableToXPBuy( SHOP_FILE, TlineIndex, Tstat, Tpermission, Tprice );
	AxpBuy = self ITEM_IsAvailableXpBuy( SHOP_FILE, TlineIndex, Tprice, Trank );
	AalreadyBuyed = self scripts\clients\_inventory::HasInventory( TlineIndex );
	AslotFull = self scripts\clients\_inventory::HasSlotFull( undefined, TlineIndex );
	
	if( Aperm && Amoney ) // all available, buy!
	{
		if( AalreadyBuyed )
		{
			self scripts\shop\_shopMenu::CreatePopUpWindow( "Already purchased", "This item is already purchased!" );
			return false;
		}
		if( AslotFull )
		{
			self scripts\shop\_shopMenu::CreatePopUpWindow( "Replace weapon?", "This weapon slot is already full. Replace it with new weapon?", ::ReplaceWithNewWeapon );
			self.SHOP.POPUP.TlineIndex = TlineIndex;
			self.SHOP.POPUP.Tmoney = Tmoney;
			return false;
		}
		
		self scripts\clients\_inventory::GiveInventory( TlineIndex );
		self scripts\clients\_rank::GiveMoney( int(Tmoney)*(-1) );
		
		self CloseMenu();
		self CloseInGameMenu();
		return true;
	}
	else if( !Amoney ) // need more money..
	{
		self scripts\shop\_shopMenu::CreatePopUpWindow( "Need money", "You need more money to buying this item!" );
		return false;
	}
	else // need unlock stat..
	{
		if( AxpBuyType ) // is item buy type
		{
			if( AxpBuy ) // is xp/level
			{
				Tname = ITEM_GetTableName( SHOP_FILE, TlineIndex );
				
				self scripts\shop\_shopMenu::CreatePopUpWindow( "Confirm buying", "Want you really buy ^1"+Tname+" ^7behind ^1"+Tprice+" ^7XP", ::BuyItemBehindXp );
				self.SHOP.POPUP.TlineIndex = TlineIndex;
				self.SHOP.POPUP.Tstat = Tstat;
				self.SHOP.POPUP.Tprice = Tprice;
				return false;
			}
			else
			{
				self scripts\shop\_shopMenu::CreatePopUpWindow( "Need XP/LVL", "You need more XP or higher LVL to buying this item!" );
				return false;
			}
		}
		else
			return false;
	}
}

BuyItemBehindXp()
{
	self ITEM_BuyItem( SHOP_FILE, self.SHOP.POPUP.TlineIndex, self.SHOP.POPUP.Tstat, self.SHOP.POPUP.Tprice );
}

ReplaceWithNewWeapon()
{
	self scripts\clients\_inventory::GiveInventory( self.SHOP.POPUP.TlineIndex );
	self scripts\clients\_rank::GiveMoney( int(self.SHOP.POPUP.Tmoney)*(-1) );
	self scripts\shop\_shopMenu::UpdateInventoryDvars();
}

RestoreAmmo()
{
	if( self.pers["money"] < level.dvars["price_restoreAmmo"] )
	{
		self scripts\shop\_shopMenu::CreatePopUpWindow( "Need money", "You need more money to buying this item!" );
		return;
	}
	
	restore = false;
	if( IsDefined( self.SpawnPlayer.primaryWeapon ) && self.SpawnPlayer.primaryWeapon != "" )
	{
		restore = true;
		self scripts\clients\_weapons::RestoreAmmo( self.SpawnPlayer.primaryWeapon );
	}	
	if( IsDefined( self.SpawnPlayer.offHand ) && self.SpawnPlayer.offHand != "" )
	{
		restore = true;
		self scripts\clients\_weapons::RestoreAmmo( self.SpawnPlayer.offHand );
	}
	if( IsDefined( self.SpawnPlayer.secondaryOffHand ) && self.SpawnPlayer.secondaryOffHand != "" )
	{
		restore = true;
		self scripts\clients\_weapons::RestoreAmmo( self.SpawnPlayer.secondaryOffHand );
	}
	
	if( restore )
	{
		self scripts\clients\_rank::GiveMoney( level.dvars["price_restoreAmmo"]*(-1) );
	
		self CloseMenu();
		self CloseInGameMenu();	
	}
}