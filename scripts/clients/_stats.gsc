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
#include scripts\include\_class;

private STAT_DEFAULT_VALUE = 0;
private STAT_VERSION_GAME = 3306;

// poËet statov
private STAT_COUNT = 671;
private STAT_UNLOCKABLE_COUNT = 300;

// Ëas medzi dotazovanÌm statov od hr·Ëa
private STAT_SPACE_TIME = 0.01;
// celkov˝ Ëas mazania profilu
private STAT_TIMER = 33.3;

private SHOP_QUICKBUY_RESETVALUE = 100;
private SHOP_QUICKBUY_PRIMARYWEAPON = 3301;
private SHOP_QUICKBUY_GRENADE = 3302;
private SHOP_QUICKBUY_SPECIALGRENADE = 3303;
private SHOP_QUICKBUY_EQUIPMENT = 3304;
private SHOP_QUICKBUY_GEAR = 3305;

/// 
/// Vyuûitie statov!
/// 0 - 99 classAllies
/// 100 - 199 classAxis
/// 200 - 299 shop
///

init()
{

}

///
/// Odomkne zvolen˝ stat.
///
UnlockStat( num )
{
	statNum = int( TableLookUp( "mp/FreeStatsTable.csv", 0, num, 1 ) );
	trueValue = int( TableLookUp( "mp/FreeStatsTable.csv", 0, num, 2 ) );
	self SetStat( statNum, trueValue );
}
///
/// Zresetuje zvolen˝ stat na default hodnotu. ( 0 - 10 )
///
ResetStat( num )
{
	self SetStatValue( num, STAT_DEFAULT_VALUE );
}
///
/// NastavÌ zvolenÈmu statu konkrÈtnu hodnotu.
///
SetStatValue( num, value )
{
	statNum = int( TableLookUp( "mp/FreeStatsTable.csv", 0, num, 1 ) );
	self SetStat( statNum, value );
}
///
/// ZÌska hodnotu zo zvolenÈho statu.
///
GetStatValue( num )
{
	statNum = int( TableLookUp( "mp/FreeStatsTable.csv", 0, num, 1 ) );
	return self GetStat( statNum );
}
///
/// ZistÌ dostupnosù statu. ( dostupn˝ = TRUE )
///
IsStatAvailable( num )
{
	statNum = int( TableLookUp( "mp/FreeStatsTable.csv", 0, num, 1 ) );
	trueValue = int( TableLookUp( "mp/FreeStatsTable.csv", 0, num, 2 ) );
	if( self GetStat( statNum ) == trueValue )
		return true;
	else
		return false;
}

GetStatByNum( num )
{
	return mp\_stats::GetStatInfo( num )[0];
}

ResetStatsOnConnect()
{
	if( level.dvars["stats_clearMPData"] )
	{
		if( level.dvars["stats_clearMPData"] == 1 || (self GetStat( STAT_VERSION_GAME ) != level.dvars["stats_version"]) )
		{
			self scripts\clients\_hud::SetLowerTextAndTimer( "Clearing your profile...", STAT_TIMER, 130 );
			
			for( i = 0; i < STAT_COUNT; i++ )
			{
				self SetStat( GetStatByNum( i ), STAT_DEFAULT_VALUE );
				wait STAT_SPACE_TIME;
			}
			
			self maps\mp\gametypes\_persistence::StatSet( "SCORE", 0 );
			self maps\mp\gametypes\_persistence::StatSet( "KILLS", 0 );
			wait STAT_SPACE_TIME;
			self maps\mp\gametypes\_persistence::StatSet( "DEATHS", 0 );
			self maps\mp\gametypes\_persistence::StatSet( "ASSISTS", 0 );
			wait STAT_SPACE_TIME;
			self maps\mp\gametypes\_persistence::StatSet( "KILLS_HUMANS", 0 );
			self maps\mp\gametypes\_persistence::StatSet( "KILLS_MONSTERS", 0 );
			wait STAT_SPACE_TIME;
			self maps\mp\gametypes\_persistence::StatSet( "TIME_PLAYED_TOTAL", 0 );
			self maps\mp\gametypes\_persistence::StatSet( "TOTALXP", 0 );
			wait STAT_SPACE_TIME;
			
			self SetStat( STAT_VERSION_GAME, level.dvars["stats_version"] );
		}
	}
	
	self scripts\clients\_hud::SetLowerText( "Checking your profile..." );

	wait STAT_SPACE_TIME;
	self CheckClass();
	
	wait STAT_SPACE_TIME;
	self CheckShop();
	
	wait STAT_SPACE_TIME;
	
	self scripts\clients\_hud::ResetLower();
}

CheckClass()
{
	team = "allies";
	for( tI = 0; tI < 2; tI++ )
	{
		if( tI == 1 )
			team = "axis";
	
		for( classIndex = 0; classIndex < CLASS_CLASSINDEX_COUNT; classIndex++ )
		{
			for( typeIndex = 0; typeIndex < CLASS_TYPEINDEX_COUNT; typeIndex++ )
			{
				stat = CLASS_GetSlotStat( team, classIndex, typeIndex );
				if( !self CLASS_IsStatValid( team, classIndex, typeIndex, stat ) )
				{
					defaultValue = CLASS_GetStatDefaultValue( team, typeIndex );
					self SetStat( stat, defaultValue );
					self IPrintLn( "Reseting stat;^1"+stat+"^7;value;^1"+defaultValue+"^7;team;^1"+team+"^7;classIndex;^1"+classIndex+"^7;typeIndex;^1"+typeIndex  );
				}
				
				wait STAT_SPACE_TIME;
			}
		}
	}
}

CheckShop()
{
	ResetShopStat( SHOP_QUICKBUY_PRIMARYWEAPON, "Assault", "SMG", "LMG", "Shotgun", "Sniper" );
	wait STAT_SPACE_TIME;
	ResetShopStat( SHOP_QUICKBUY_GRENADE, "Grenade" );
	wait STAT_SPACE_TIME;
	ResetShopStat( SHOP_QUICKBUY_SPECIALGRENADE, "Grenade" );
	wait STAT_SPACE_TIME;
	ResetShopStat( SHOP_QUICKBUY_EQUIPMENT, "Equipment" );
	wait STAT_SPACE_TIME;
	ResetShopStat( SHOP_QUICKBUY_GEAR, "Gear" );
	wait STAT_SPACE_TIME;
}
ResetShopStat( stat, type0, type1, type2, type3, type4 )
{
	while( true )
	{
		statValue = self GetStat( stat );
		
		Tname = TableLookUp( "mp/WeaponsTable.csv", 0, statValue, 3 );
		if( Tname == "" )
			break;
		
		Ttype = TableLookUp( "mp/WeaponsTable.csv", 0, statValue, 1 );
		if( (IsDefined( type0 ) && Ttype == type0) 
			|| (IsDefined( type1 ) && Ttype == type1) 
			|| (IsDefined( type2 ) && Ttype == type2)
			|| (IsDefined( type3 ) && Ttype == type3)
			|| (IsDefined( type4 ) && Ttype == type4) )
			return;
			
		break;
	}
	
	self IPrintLn( "Reseting stat;^1"+stat+"^7;value;^1"+SHOP_QUICKBUY_RESETVALUE+"^7;type;^1"+type0 );
	self SetStat( stat, SHOP_QUICKBUY_RESETVALUE );
}