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

private TYPE_BOOL = 1;
private TYPE_INT = 2;
private TYPE_FLOAT = 3;
private TYPE_STRING = 4;

init()
{
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////// MAP SETTINGS ///////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
// Priorita nastavovania zostupne
// 1. CFG - dvar
// 2. GSC mapy
// 3. default nastavenia
/////////////////////////////////////////////////////////////////////////////////////////////////
RegisterMapSettings()
{
	level.MapSettings = [];
	
	level.MapSettings["TimeLimit"] = level.dvars["logic_timeLimit"];
	
	level.MapSettings["SpawnsFX"] = "misc/m_resp";
	level.MapSettings["SpawnsSound"] = "";
	level.MapSettings["BigSpawnsFX"] = "misc/m_resp_big";
	level.MapSettings["BigSpawnsSound"] = "";
	
	level.MapSettings["AmbientTrack"] = "ambient_default";
	
	level.MapSettings["CheckPointDeadTime"] = level.dvars["checkpoint_deadTime"];
	
	level.MapSettings["HumansStartTimeAdd"] = level.dvars["logic_startHumansTimeAdd"];
	level.MapSettings["MonstersStartTimeAdd"] = level.dvars["logic_startMonsterTimeAdd"];
	
	level.MapSettings["MapInfo"] = [];
}

UpdateMapSettings()
{
	CheckMapSettingsDvars();

	scripts\_dvars::SetDvarValue( "logic_timeLimit", StringToFloat( "" + level.MapSettings["TimeLimit"] + "" ), TYPE_FLOAT, 10 );
		
	level.Spawns["SpawnsFX"] = level.MapSettings["SpawnsFX"];  AddFXtoList( level.Spawns["SpawnsFX"] );
	level.Spawns["SpawnsSound"] = level.MapSettings["SpawnsSound"];
	level.Spawns["BigSpawnsFX"] = level.MapSettings["BigSpawnsFX"];  AddFXtoList( level.Spawns["BigSpawnsFX"] );
	level.Spawns["BigSpawnsSound"] = level.MapSettings["BigSpawnsSound"];
	
	scripts\_dvars::SetDvarValue( "checkpoint_deadTime", Int( level.MapSettings["CheckPointDeadTime"] ), TYPE_INT, 20 );
	
	scripts\_dvars::SetDvarValue( "logic_startHumansTimeAdd", Int( level.MapSettings["HumansStartTimeAdd"] ), TYPE_INT, 0 );
	scripts\_dvars::SetDvarValue( "logic_startMonsterTimeAdd", Int( level.MapSettings["MonstersStartTimeAdd"] ), TYPE_INT, 5 );
}

CheckMapSettingsDvars()
{
	for( i = 0;;i++ )
	{
		dvar = GetDvar( level.script+"_settings_"+i );
		if( dvar == "" ) return;
			
		vars = StrTok( dvar, ";" );
		foreach( var in vars )
		{
			if( var == "" ) continue;
				
			parts = StrTok( var, "," );
			if( parts.size != 2 ) continue;
				
			name = parts[0];
			value = parts[1];
			if( name == "" ) continue;
				
			if( IsSubStr( name, "MapInfo" ) )
			{
				line = GetSubStr( name, 7 );
				if( line == "" ) continue;

				level.MapSettings["MapInfo"][Int( line )] = value;
			}
			else
				level.MapSettings[name] = value;
		}
	}
}