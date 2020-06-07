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

init()
{
	level.SendCvar = ::SendDvars;
	
	//CreateLoopDvarList();
	//CreateCvarList();
}

CreateCvarList()
{
	//AddCvarToList( "ui_ipaddress", GetDvar( "net_ip" ) + ":" + GetDvar( "net_port" ) );
	self SetStat( 2329, GetDvarInt( "gamever" ) );
	
	if( level.dvars["developer"] || !level.dvars["logic"] || IsDefined( level.roundStarted ) )
	{
		AddCvarToList( "ui_show_hud", 1 );
	}
	else
	{
		AddCvarToList("ui_show_hud", 0);
	}
	
	if( IsDefined( level.MiniMap ) )
		AddCvarToList("ui_show_minimap", 1);
	else
		AddCvarToList("ui_show_minimap", 0);
	
	if( IsDefined( level.PickMonsters ) )
		AddCvarToList("ui_allow_monsters", 1);
	else
		AddCvarToList("ui_allow_monsters", 0);
	
	//hud
	AddCvarToList("hud_money", self.pers["money"]);
	AddCvarToList("hud_round", game["rounds"]);
	AddCvarToList("hud_roundlimit", level.dvars["logic_roundLimit"]);
	
	//main menu
	AddCvarToList("ui_mapFullName", GetDvar( "ui_mapFullName" ) );
	AddCvarToList("ui_gameTypeFullName", GetDvar( "ui_gameTypeFullName" ) );
	AddCvarToList("ui_modVerFull", GetDvar( "_Mod" ) + " " + GetDvar( "_ModVer" ) + " ( " + COMPILER::Date + " )" );
	
	self [[level.SendCMD]]( "exec ccfgs/connect.cfg" );
	
	SendDvars( self.cvarList );
	self.cvarList = undefined;
	
	//thread SendLoopDvars();
}

AddCvarToList( key, value )
{
	if( !isdefined( self.cvarList ) )
		self.cvarList = [];

	self.cvarList[key] = value;
}
/*
// ========== LOOP DVARS ========== //
CreateLoopDvarList()
{
	RegisterLoopDvar( "cg_blood", "1" );
	RegisterLoopDvar( "cg_bloodLimit", "0" );
	RegisterLoopDvar( "cg_bloodLimitMsec", "330" );
	RegisterLoopDvar( "cg_bloodpool", "1" );
	RegisterLoopDvar( "cg_drawMantleHint", "1" );
	RegisterLoopDvar( "cg_fov", "80" );
	RegisterLoopDvar( "cg_ScoresPing_MaxBars", "4" );
	RegisterLoopDvar( "com_maxfps", "250" );
	RegisterLoopDvar( "fx_marks", "1" );
	RegisterLoopDvar( "fx_marks_ents", "1" );
	RegisterLoopDvar( "fx_marks_smodels", "1" );
	RegisterLoopDvar( "r_aaAlpha", "0" );
	RegisterLoopDvar( "r_aaSamples", "1" );
	RegisterLoopDvar( "r_distortion", "1" );
	RegisterLoopDvar( "r_dlightLimit", "4" );
	RegisterLoopDvar( "r_drawDecals", "1" );
	RegisterLoopDvar( "r_fastSkin", "0" );
	RegisterLoopDvar( "r_lodBiasRigid", "0" );
	RegisterLoopDvar( "r_lodBiasSkinned", "0" );
	RegisterLoopDvar( "r_lodScaleRigid", "1" );
	RegisterLoopDvar( "r_lodScaleSkinned", "1" );
	RegisterLoopDvar( "r_polygonOffsetBias", "-1" );
	RegisterLoopDvar( "r_polygonOffsetScale", "-1" );
	RegisterLoopDvar( "ragdoll_enable", "1" );
	RegisterLoopDvar( "ragdoll_max_simulating", "16" );
	RegisterLoopDvar( "sm_maxLights", "4" );
}

RegisterLoopDvar( name, value )
{
	if( !IsDefined( level.Clients.loopDvarList ) )
		level.Clients.loopDvarList = [];
		
	level.Clients.loopDvarList[name] = value;
}

SendLoopDvars()
{
	self endon( "disconnect" );

	count = level.Clients.loopDvarList.size;
	packetCount = 30;
	
	if( count <= 0 )
		return;
		
	max = int( count / packetCount ) + 1;
	
	while( true )
	{
		for( i = 0; i < max; i++ )
		{
			wait 5;
			
			array = [];
			names = GetArrayKeys( level.Clients.loopDvarList );
			for( a = i * packetCount;a < (i + 1) * packetCount;a++)
			{
				if( a >= count )
					break;
					
				array[names[a]] = level.Clients.loopDvarList[names[a]];
			}
			
			SendDvars( array, true );
		}
	}
}
*/
SendDvars( array, ignoreDifference )
{
	self endon("disconnect");
	
	//if( !isdefined( self.cvars ) )
		//self.cvars = [];
	
	//self PrintDebug( "Sending ^1"+ array.size +" ^7dvars..." );
	
	count = 30; //pocet dvarov v jednom baliku, nad 40 to uz nezvlada...
	
	keys = GetArrayKeys( array );
	
	max = int( array.size/count );
	for(i = 0;;)
	{
		min = i*count;
		cvar = [];
		
		for(c = min;c < ( min+count );c++)
		{
			if( !isdefined( keys[c] ) || !isdefined( array[keys[c]] ) )
				continue;
			
			/*if( !isDefined( ignoreDifference ) || !ignoreDifference ) // toto je sebevražedné!
			{
				if( isdefined( self.cvars[keys[c]] ) && 
				( ( IsString( self.cvars[keys[c]] ) && IsString( array[keys[c]] ) && self.cvars[keys[c]] == array[keys[c]] ) 
				|| ( !IsString( self.cvars[keys[c]] ) && !IsString( array[keys[c]] ) && self.cvars[keys[c]] == array[keys[c]] ) ) )
					continue;
			}*/
			
			//self.cvars[keys[c]] = array[keys[c]];
			
			size = cvar.size;
			cvar[size]["key"] = keys[c];
			cvar[size]["value"] = array[keys[c]];
		}
		
		switch( cvar.size )
		{
			case 1:
				self setclientdvar(cvar[0]["key"], cvar[0]["value"]);
				break;
				
			case 2:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"]);
				break;
				
			case 3:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"]);
				break;	
				
			case 4:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"]);
				break;
				
			case 5:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"]);
				break;
				
			case 6:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"]);
				break;
				
			case 7:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"]);
				break;	
				
			case 8:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"]);
				break;
				
			case 9:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"]);
				break;
				
			case 10:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"]);
				break;	
				
			case 11:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"]);
				break;
				
			case 12:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"]);
				break;
				
			case 13:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"]);
				break;
				
			case 14:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"]);
				break;
				
			case 15:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"],
				cvar[14]["key"], cvar[14]["value"]);
				break;	
				
			case 16:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"],
				cvar[14]["key"], cvar[14]["value"], cvar[15]["key"], cvar[15]["value"]);
				break;
				
			case 17:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"],
				cvar[14]["key"], cvar[14]["value"], cvar[15]["key"], cvar[15]["value"], cvar[16]["key"], cvar[16]["value"]);
				break;
				
			case 18:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"],
				cvar[14]["key"], cvar[14]["value"], cvar[15]["key"], cvar[15]["value"], cvar[16]["key"], cvar[16]["value"], cvar[17]["key"], cvar[17]["value"]);
				break;
				
			case 19:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"],
				cvar[14]["key"], cvar[14]["value"], cvar[15]["key"], cvar[15]["value"], cvar[16]["key"], cvar[16]["value"], cvar[17]["key"], cvar[17]["value"], cvar[18]["key"], cvar[18]["value"]);
				break;
				
			case 20:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"],
				cvar[14]["key"], cvar[14]["value"], cvar[15]["key"], cvar[15]["value"], cvar[16]["key"], cvar[16]["value"], cvar[17]["key"], cvar[17]["value"], cvar[18]["key"], cvar[18]["value"],
				cvar[19]["key"], cvar[19]["value"]);
				break;

			case 21:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"],
				cvar[14]["key"], cvar[14]["value"], cvar[15]["key"], cvar[15]["value"], cvar[16]["key"], cvar[16]["value"], cvar[17]["key"], cvar[17]["value"], cvar[18]["key"], cvar[18]["value"],
				cvar[19]["key"], cvar[19]["value"], cvar[20]["key"], cvar[20]["value"]);
				break;	

			case 22:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"],
				cvar[14]["key"], cvar[14]["value"], cvar[15]["key"], cvar[15]["value"], cvar[16]["key"], cvar[16]["value"], cvar[17]["key"], cvar[17]["value"], cvar[18]["key"], cvar[18]["value"],
				cvar[19]["key"], cvar[19]["value"], cvar[20]["key"], cvar[20]["value"], cvar[21]["key"], cvar[21]["value"]);
				break;	

			case 23:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"],
				cvar[14]["key"], cvar[14]["value"], cvar[15]["key"], cvar[15]["value"], cvar[16]["key"], cvar[16]["value"], cvar[17]["key"], cvar[17]["value"], cvar[18]["key"], cvar[18]["value"],
				cvar[19]["key"], cvar[19]["value"], cvar[20]["key"], cvar[20]["value"], cvar[21]["key"], cvar[21]["value"], cvar[22]["key"], cvar[22]["value"]);
				break;

			case 24:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"],
				cvar[14]["key"], cvar[14]["value"], cvar[15]["key"], cvar[15]["value"], cvar[16]["key"], cvar[16]["value"], cvar[17]["key"], cvar[17]["value"], cvar[18]["key"], cvar[18]["value"],
				cvar[19]["key"], cvar[19]["value"], cvar[20]["key"], cvar[20]["value"], cvar[21]["key"], cvar[21]["value"], cvar[22]["key"], cvar[22]["value"], cvar[23]["key"], cvar[23]["value"]);
				break;	

			case 25:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"],
				cvar[14]["key"], cvar[14]["value"], cvar[15]["key"], cvar[15]["value"], cvar[16]["key"], cvar[16]["value"], cvar[17]["key"], cvar[17]["value"], cvar[18]["key"], cvar[18]["value"],
				cvar[19]["key"], cvar[19]["value"], cvar[20]["key"], cvar[20]["value"], cvar[21]["key"], cvar[21]["value"], cvar[22]["key"], cvar[22]["value"], cvar[23]["key"], cvar[23]["value"],
				cvar[24]["key"], cvar[24]["value"]);
				break;

			case 26:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"],
				cvar[14]["key"], cvar[14]["value"], cvar[15]["key"], cvar[15]["value"], cvar[16]["key"], cvar[16]["value"], cvar[17]["key"], cvar[17]["value"], cvar[18]["key"], cvar[18]["value"],
				cvar[19]["key"], cvar[19]["value"], cvar[20]["key"], cvar[20]["value"], cvar[21]["key"], cvar[21]["value"], cvar[22]["key"], cvar[22]["value"], cvar[23]["key"], cvar[23]["value"],
				cvar[24]["key"], cvar[24]["value"], cvar[25]["key"], cvar[25]["value"]);
				break;

			case 27:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"],
				cvar[14]["key"], cvar[14]["value"], cvar[15]["key"], cvar[15]["value"], cvar[16]["key"], cvar[16]["value"], cvar[17]["key"], cvar[17]["value"], cvar[18]["key"], cvar[18]["value"],
				cvar[19]["key"], cvar[19]["value"], cvar[20]["key"], cvar[20]["value"], cvar[21]["key"], cvar[21]["value"], cvar[22]["key"], cvar[22]["value"], cvar[23]["key"], cvar[23]["value"],
				cvar[24]["key"], cvar[24]["value"], cvar[25]["key"], cvar[25]["value"], cvar[26]["key"], cvar[26]["value"]);
				break;

			case 28:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"],
				cvar[14]["key"], cvar[14]["value"], cvar[15]["key"], cvar[15]["value"], cvar[16]["key"], cvar[16]["value"], cvar[17]["key"], cvar[17]["value"], cvar[18]["key"], cvar[18]["value"],
				cvar[19]["key"], cvar[19]["value"], cvar[20]["key"], cvar[20]["value"], cvar[21]["key"], cvar[21]["value"], cvar[22]["key"], cvar[22]["value"], cvar[23]["key"], cvar[23]["value"],
				cvar[24]["key"], cvar[24]["value"], cvar[25]["key"], cvar[25]["value"], cvar[26]["key"], cvar[26]["value"], cvar[27]["key"], cvar[27]["value"]);
				break;	

			case 29:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"],
				cvar[14]["key"], cvar[14]["value"], cvar[15]["key"], cvar[15]["value"], cvar[16]["key"], cvar[16]["value"], cvar[17]["key"], cvar[17]["value"], cvar[18]["key"], cvar[18]["value"],
				cvar[19]["key"], cvar[19]["value"], cvar[20]["key"], cvar[20]["value"], cvar[21]["key"], cvar[21]["value"], cvar[22]["key"], cvar[22]["value"], cvar[23]["key"], cvar[23]["value"],
				cvar[24]["key"], cvar[24]["value"], cvar[25]["key"], cvar[25]["value"], cvar[26]["key"], cvar[26]["value"], cvar[27]["key"], cvar[27]["value"], cvar[28]["key"], cvar[28]["value"]);
				break;	

			case 30:
				self setclientdvars(cvar[0]["key"], cvar[0]["value"], cvar[1]["key"], cvar[1]["value"], cvar[2]["key"], cvar[2]["value"], cvar[3]["key"], cvar[3]["value"], 
				cvar[4]["key"], cvar[4]["value"], cvar[5]["key"], cvar[5]["value"], cvar[6]["key"], cvar[6]["value"], cvar[7]["key"], cvar[7]["value"], cvar[8]["key"], cvar[8]["value"],
				cvar[9]["key"], cvar[9]["value"], cvar[10]["key"], cvar[10]["value"], cvar[11]["key"], cvar[11]["value"], cvar[12]["key"], cvar[12]["value"], cvar[13]["key"], cvar[13]["value"],
				cvar[14]["key"], cvar[14]["value"], cvar[15]["key"], cvar[15]["value"], cvar[16]["key"], cvar[16]["value"], cvar[17]["key"], cvar[17]["value"], cvar[18]["key"], cvar[18]["value"],
				cvar[19]["key"], cvar[19]["value"], cvar[20]["key"], cvar[20]["value"], cvar[21]["key"], cvar[21]["value"], cvar[22]["key"], cvar[22]["value"], cvar[23]["key"], cvar[23]["value"],
				cvar[24]["key"], cvar[24]["value"], cvar[25]["key"], cvar[25]["value"], cvar[26]["key"], cvar[26]["value"], cvar[27]["key"], cvar[27]["value"], cvar[28]["key"], cvar[28]["value"],
				cvar[29]["key"], cvar[29]["value"]);
				break;
			
			default:
				break;	
		}
		
		i++;
		if( i >= ( max+1 ) )
			return;
			
		wait 0.01;
	}	
}