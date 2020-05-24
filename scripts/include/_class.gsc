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
#include scripts\include\_item;

// permission stavy
private PERMISSION_LOCK =	0; // zamknutÈ vûdy
private PERMISSION_FREE =	1; // odomknutÈ vûdy
private PERMISSION_BUY =	2; // kontroluje stat, moûnosù k˙più
private PERMISSION_LEVEL =	3; // dostupnÈ podæa levelu

// uloûenÈ classIndexy u hr·Ëa
private STAT_SPAWNCLASS_ALLIES = 3298;
private STAT_SPAWNCLASS_AXIS = 3299;

// poËiatoËn˝ statIndex pre dan˝ tÌm
private STAT_STARTINDEX_ALLIES = 2661;
private STAT_STARTINDEX_AXIS = 3000;

private TABLE_FILE_ALLIES = "mp/HumansClassTable.csv";
private TABLE_FILE_AXIS = "mp/MonsterClassTable.csv";

private TABLE_ITEMS_COUNT = 100;

private TABLE_ALLIES_TYPE_FIGURE_S = 0;
private TABLE_ALLIES_TYPE_WEAPON_S = 20;
private TABLE_ALLIES_TYPE_FIRSTPERK_S = 40;
private TABLE_ALLIES_TYPE_SECONDPERK_S = 60;
private TABLE_ALLIES_TYPE_THIRDPERK_S = 80;

private TABLE_AXIS_TYPE_FIGURE_S = 0;
private TABLE_AXIS_TYPE_WEAPON_S = 20;
private TABLE_AXIS_TYPE_FIRSTPERK_S = 40;
private TABLE_AXIS_TYPE_SECONDPERK_S = 60;
private TABLE_AXIS_TYPE_THIRDPERK_S = 80;

private CLASS_CLASSINDEX_COUNT = 5;
private CLASS_TYPEINDEX_COUNT = 5;

// ================================================================================================================================================================================================= //
// CLASS INDEX
// ================================================================================================================================================================================================= //
///
/// Vr·ti uloûen˝ classIndex.
///
CLASS_GetSpawnClass( team )
{
	if( !IsDefined( team ) )
		team = self.CAC.Team;

	if( !IsDefined( self.pers["spawnClass_"+team] ) )
	{
		stat = STAT_SPAWNCLASS_AXIS;
		if( team == "allies" )
			stat = STAT_SPAWNCLASS_ALLIES;
			
		self.pers["spawnClass_"+team] = self GetStat( stat );
	}
		
	return self.pers["spawnClass_"+team];
}
///
/// NastavÌ nov˝ classIndex.
///
CLASS_SetSpawnClass( team, value )
{
	if( !IsDefined( team ) )
		team = self.CAC.Team;
	
	if( IsDefined( value ) )
		self.pers["spawnClass_"+team] = value;
	else if( !IsDefined( self.pers["spawnClass_"+team] ) )
	{
		stat = STAT_SPAWNCLASS_AXIS;
		if( team == "allies" )
			stat = STAT_SPAWNCLASS_ALLIES;
			
		self.pers["spawnClass_"+team] = self GetStat( stat );
	}
	
	if( team == "allies" )
		self SetStat( STAT_SPAWNCLASS_ALLIES, self.pers["spawnClass_"+team] );
	else
		self SetStat( STAT_SPAWNCLASS_AXIS, self.pers["spawnClass_"+team] );
}

/// 
/// ZÌska ËÌslo statu na z·klade tÌmu, classIndexu a typeIndexu
///
CLASS_GetSlotStat( team, classIndex, typeIndex )
{
	startStat = STAT_STARTINDEX_AXIS;
	if( team == "allies" )
		startStat = STAT_STARTINDEX_ALLIES;
	
	// startStat + (ClassIndex * ClassCount) + typeIndex
	stat = startStat + (classIndex * CLASS_CLASSINDEX_COUNT) + typeIndex;
	return stat;
}

CLASS_GetSlotItem( team, classIndex, typeIndex )
{
	stat = CLASS_GetSlotStat( team, classIndex, typeIndex );
	return self GetStat( stat );
}

CLASS_GetFileByTeam( team )
{
	file = TABLE_FILE_AXIS;
	if( team == "allies" )
		file = TABLE_FILE_ALLIES;
		
	return file;
}

CLASS_GetTypeForTypeIndex( typeIndex )
{
	switch( typeIndex )
	{
		case 0:
			return "Figure";
		case 1:
			return "Weapon";
		case 2:
			return "FirstPerk";
		case 3:
			return "SecondPerk";
		case 4:
			return "ThirdPerk";
		default:
			PrintDebug( "Unknown class typeIndex "+typeIndex );
			return undefined;
	}
}

///
/// Skontroluje dostupnosù(spr·vnosù uloûenej hodnoty - antihack)
///
CLASS_IsStatValid( team, classIndex, typeIndex, stat )
{
	if( !IsDefined( stat ) ) stat = CLASS_GetSlotStat( team, classIndex, typeIndex );
	statValue = self GetStat( stat );
	
	file = CLASS_GetFileByTeam( team );
	
	type = CLASS_GetTypeForTypeIndex( typeIndex );
	Ttype = TableLookUp( file, 0, statValue, 1 );
	if( type != Ttype )
		return false;
		
	Tname = TableLookUp( file, 0, statValue, 3 );
	if( Tname == "" )
		return false;
		
	if( !ITEM_IsAvailablePermission( file, statValue ) )
		return false;
		
	return true;
}

CLASS_GetStatDefaultValue( team, typeIndex )
{
	switch( typeIndex )
	{
		case 0:
			if( team == "allies" )
				return TABLE_ALLIES_TYPE_FIGURE_S;
			else
				return TABLE_AXIS_TYPE_FIGURE_S;
		case 1:
			if( team == "allies" )
				return TABLE_ALLIES_TYPE_WEAPON_S;
			else
				return TABLE_AXIS_TYPE_WEAPON_S;
		case 2:
			if( team == "allies" )
				return TABLE_ALLIES_TYPE_FIRSTPERK_S;
			else
				return TABLE_AXIS_TYPE_FIRSTPERK_S;
		case 3:
			if( team == "allies" )
				return TABLE_ALLIES_TYPE_SECONDPERK_S;
			else
				return TABLE_AXIS_TYPE_SECONDPERK_S;
		case 4:
			if( team == "allies" )
				return TABLE_ALLIES_TYPE_THIRDPERK_S;
			else
				return TABLE_AXIS_TYPE_THIRDPERK_S;
		default:
			PrintDebug( "Unknown class typeIndex "+typeIndex );
			return;
	}
}