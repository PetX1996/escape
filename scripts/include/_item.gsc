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

private TABLE_LINEINDEX = 0;
private TABLE_TYPE = 1;
private TABLE_STAT = 2;
private TABLE_NAME = 3;
private TABLE_IMAGE = 4;
private TABLE_PERMISSION = 5;
private TABLE_PRICE = 6;
private TABLE_RANK = 7;
private TABLE_MONEY = 8;

ITEM_GetTableType( file, TlineIndex )
{ return TableLookUp( file, 0, TlineIndex, TABLE_TYPE ); }

ITEM_GetTableStat( file, TlineIndex )
{ return TableLookUp( file, 0, TlineIndex, TABLE_STAT ); }

ITEM_GetTableName( file, TlineIndex )
{ return TableLookUp( file, 0, TlineIndex, TABLE_NAME ); }

ITEM_GetTableImage( file, TlineIndex )
{ return TableLookUp( file, 0, TlineIndex, TABLE_IMAGE ); }

ITEM_GetTablePermission( file, TlineIndex )
{ return TableLookUp( file, 0, TlineIndex, TABLE_PERMISSION ); }

ITEM_GetTablePrice( file, TlineIndex )
{ return TableLookUp( file, 0, TlineIndex, TABLE_PRICE ); }

ITEM_GetTableRank( file, TlineIndex )
{ return TableLookUp( file, 0, TlineIndex, TABLE_RANK ); }

ITEM_GetTableMoney( file, TlineIndex )
{ return TableLookUp( file, 0, TlineIndex, TABLE_MONEY ); }

ITEM_IsAvailableFull( file, TlineIndex, Tstat, Tpermission, Trank, Tmoney )
{
	if( self ITEM_IsAvailablePermission( file, TlineIndex, Tstat, Tpermission, Trank ) )
	{
		if( file == "mp/WeaponsTable.csv" )
		{
			if( self ITEM_IsAvailableMoney( file, TlineIndex, Tmoney ) )
				return true;
			else
				return false;
		}
		return true;
	}
	return false;
}

ITEM_IsAvailablePermission( file, TlineIndex, Tstat, Tpermission, Trank )
{
	if( !IsDefined( Tpermission ) )	Tpermission = ITEM_GetTablePermission( file, TlineIndex );
	switch( Tpermission )
	{
		case "0":
			return false;
		case "1":
			return true;
		case "2":
			if( !IsDefined( Tstat ) )		Tstat = ITEM_GetTableStat( file, TlineIndex );
		
			if( self scripts\clients\_stats::IsStatAvailable( Tstat ) )
				return true;
			else
				return false;
		case "3":
			if( !IsDefined( Trank ) )		Trank = ITEM_GetTableRank( file, TlineIndex );
		
			if( self.pers["rank"] >= int(Trank) )
				return true;
			else
				return false;
		default:
			PrintDebug( "Error: unknown permission "+Tpermission );
			return false;
	}
}

ITEM_IsAvailableMoney( file, TlineIndex, Tmoney )
{
	if( !IsDefined( Tmoney ) )		Tmoney = ITEM_GetTableMoney( file, TlineIndex );

	if( self.pers["money"] >= int(Tmoney) )
		return true;
	else
		return false;
}

ITEM_IsAvailableToXPBuy( file, TlineIndex, Tstat, Tpermission, Tprice )
{
	if( !IsDefined( Tpermission ) )	Tpermission = ITEM_GetTablePermission( file, TlineIndex );
	if( !IsDefined( Tprice ) )		Tprice = ITEM_GetTablePrice( file, TlineIndex );
	
	if( Tpermission == "2" && Tprice != "0" && !self scripts\clients\_stats::IsStatAvailable( Tstat ) )
		return true;
	else
		return false;
}

ITEM_IsAvailableXpBuy( file, TlineIndex, Tprice, Trank )
{
	if( !IsDefined( Tprice ) )		Tprice = ITEM_GetTablePrice( file, TlineIndex );
	if( !IsDefined( Trank ) )		Trank = ITEM_GetTableRank( file, TlineIndex );
	
	if( self.pers["rankxp"] >= int(Tprice) && self.pers["rank"] >= int(Trank) )
		return true;
	else
		return false;
}

ITEM_BuyItem( file, TlineIndex, Tstat, Tprice )
{
	if( !IsDefined( Tstat ) )		Tstat = ITEM_GetTableStat( file, TlineIndex );
	if( !IsDefined( Tprice ) )		Tprice = ITEM_GetTablePrice( file, TlineIndex );

	self scripts\clients\_stats::UnlockStat( Tstat );
	self scripts\clients\_rank::giveRankXP( "buy", int(Tprice)*(-1) );
}