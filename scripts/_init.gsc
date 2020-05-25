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
#include scripts\include\_array;
#include scripts\include\_repel;

init()
{
	level.StartLevelTime = GetTime();
	level.dvars = [];
	level.players = [];
	level.CALLBACK = [];
	level.Spawns = [];
	
	if ( getDvar( "scr_player_sprinttime" ) == "" )
		setDvar( "scr_player_sprinttime", getDvar( "player_sprintTime" ) );

	level.splitscreen = isSplitScreen();
	level.xenon = (getdvar("xenonGame") == "true");
	level.ps3 = (getdvar("ps3Game") == "true");
	level.onlineGame = true;
	level.console = (level.xenon || level.ps3); 
	
	level.rankedMatch = ( level.onlineGame && getDvarInt( "sv_pure" ) );

	level.script = toLower( getDvar( "mapname" ) );
	level.gametype = toLower( getDvar( "g_gametype" ) );

	level.otherTeam["allies"] = "axis";
	level.otherTeam["axis"] = "allies";
	
	level.teamBased = true;

	if ( level.splitScreen )
		precacheString( &"MP_ENDED_GAME" );
	else
		precacheString( &"MP_HOST_ENDED_GAME" );

	level.lastStatusTime = 0;
	level.lastSlowProcessFrame = 0;		
		
	level.dropTeam = getdvarint( "sv_maxclients" );
	
	if ( getDvar( "scr_show_unlock_wait" ) == "" )
		setDvar( "scr_show_unlock_wait", 0.1 );
		
	if ( getDvar( "scr_intermission_time" ) == "" )
		setDvar( "scr_intermission_time", 30.0 );
	
	precacheModel( "tag_origin" );	

	//precacheShader( "faction_128_usmc" );
	//precacheShader( "faction_128_arab" );
	//precacheShader( "faction_128_ussr" );
	//precacheShader( "faction_128_sas" );
	
	thread CheckGameType();

	scripts\_dvars::init();
	scripts\_maps::init();
	
	scripts\_mapvariables::RegisterMapSettings();
	
	thread VariableOverflow();
	thread ClientCvar();
}

CheckGameType()
{
	wait 0.5;
	
	//gametype error
	if( !(level.gametype == "escape" || level.gametype == "survival" || level.gametype == "location") )
	{
		SetDvar( "sv_mapRotationCurrent", "gametype survival map "+ level.script ); 
		ExitLevel(false);
		return;
	}
}

VariableOverflow()
{
	while( true )
	{
		if( GetDvar( "scr_varOverflow" ) != "" )
		{
			LogPrint( GetDvar( "scr_varOverflow" ) + "\n" );
			break;
		}
		
		wait 0.5;
	}
	
	array = [];
	
	for( i = 0;; i++ )
	{
		if( i % 10 == 0 )
		{
			LogPrint( "Var Index: "+i+"\n" );
			
			if( i % 1000 == 0 )
				wait 0.001;		
		}
		
		array[i] = i;
	}
}

ClientCvar()
{
	while( true )
	{
		wait 0.5;
	
		dvar = GetDvar( "scr_cvar" );
		if( dvar == "" )
			continue;

		SetDvar( "scr_cvar", "" );
		data = StrTok( dvar, ":" );
		for( i = 0; i < level.players.size; i++ )
			level.players[i] SetClientDvar( data[0], data[1] );
	}
}

// to be used with things that are slow.
// unfortunately, it can only be used with things that aren't time critical.
WaitTillSlowProcessAllowed()
{
	// wait only a few frames if necessary
	// if we wait too long, we might get too many threads at once and run out of variables
	// i'm trying to avoid using a loop because i don't want any extra variables
	if ( level.lastSlowProcessFrame == gettime() )
	{
		wait .05;
		if ( level.lastSlowProcessFrame == gettime() )
		{
		wait .05;
			if ( level.lastSlowProcessFrame == gettime() )
			{
				wait .05;
				if ( level.lastSlowProcessFrame == gettime() )
				{
					wait .05;
				}
			}
		}
	}
	
	level.lastSlowProcessFrame = gettime();
}

/* =========================================== */
/* ======= Callback_StartGameType() ========== */
/* =========================================== */

Callback_StartGameType()
{
	// ====== PreCache ======= //
	
	if ( !IsDefined( game["rounds"] ) )
	{	
		if ( !IsDefined( game["state"] ) )
			game["state"] = "playing";
		
		PreCacheRumble( "damage_heavy" );
		
		PreCacheShader("damage_feedback");
		
		PreCacheShader( "white" );
		PreCacheShader( "black" );
		
		PreCacheItem( "radar_mp" ); // AS 1 - PERK
		PreCacheItem( "airstrike_mp" ); // AS 3 - EQUIPMENT
		PreCacheItem( "helicopter_mp" ); // AS 4 - GEAR
		
		// ============= STATUSICONS ================ //
		PreCacheStatusIcon("hud_status_dead");
		PreCacheStatusIcon("hud_status_connecting");
		PreCacheStatusIcon("hud_status_marshal");
		PreCacheStatusIcon("hud_status_marshal2");
		PreCacheStatusIcon("hud_status_marshal3");
		PreCacheStatusIcon("hud_status_dev");
		PreCacheStatusIcon("hud_status_vip2");
		PreCacheStatusIcon("hud_status_sponzor");
		// ========================================== //		
		
		MakeDvarServerInfo( "scr_allies", "usmc" );
		MakeDvarServerInfo( "scr_axis", "arab" );
		
		//PreCacheModel( "4gf_sgc_rings" );
		//PreCacheModel( "4gf_sgc_ring" );
		//PreCacheModel( "4gf_sgc_gate" );
		//PreCacheModel( "4gf_sgc_dhd" );
		//PreCacheModel( "zat" );
		//PreCacheModel( "zat_model" );
		//PreCacheModel( "staff" );
		//PreCacheModel( "staff_obracene_1" );
		
		scripts\class\_spawn::PreCacheFromTable();
		scripts\clients\_inventory::PreCacheItems();
		
		scripts\shop\_equipment::PreCacheEquipment();
		scripts\shop\_gear::PreCacheGear();
		
		scripts\clients\_dev::PreCache();
		
		game["rounds"] = 1;
		// first round, so set up prematch
	}
	
	if( getdvar( "r_reflectionProbeGenerate" ) == "1" )
		level waittill( "eternity" );

		
	// =========================================== //
	// ============= MAP SETTINGS ================ //
	
	scripts\_mapvariables::UpdateMapSettings();
		
	// =========================================== //
	// =============== GAMETYPES ================= //
		
	thread maps\mp\gametypes\_persistence::init();
	
	// =========================================== //
	// ================= LEVEL =================== //
	
	thread scripts\_bots::init();
	thread scripts\_deathicons::init();
	thread scripts\_effects::init();
	thread scripts\_entities::init();
	thread scripts\_events::init();
	//thread scripts\_challenges::init();
	thread scripts\_logic::init();
	thread scripts\_mapinfo::init();
	thread scripts\_quickVoting::init();
	thread scripts\_scoreboard::init();
	thread scripts\_serversettings::init();
	thread scripts\_spawns::init();
	thread scripts\_test::init();
	
	// =========================================== //
	// ================ CLIENTS ================== //
	
	thread scripts\clients\_clients::init();
	thread scripts\clients\_cmd::init();
	thread scripts\clients\_cvar::init();
	//thread scripts\clients\_damagefeedback::init();
	thread scripts\clients\_dev::init();
	thread scripts\clients\_help::init();
	thread scripts\clients\_hud::init();
	thread scripts\clients\_inventory::init();
	thread scripts\clients\_menus::init();
	thread scripts\clients\_players::init();
	thread scripts\clients\_rank::init();
	//thread scripts\clients\_shop::init();
	//thread scripts\clients\_spray::init();
	thread scripts\clients\_stats::init();
	thread scripts\clients\_teams::init();
	thread scripts\clients\_time::init();
	thread scripts\clients\_quickmessages::init();
	thread scripts\clients\_weapons::init();
	
	// =========================================== //
	// ================== ACP ==================== //	
	
	thread scripts\acp\_acpMain::init();
	
	// =========================================== //
	// ================= CLASS =================== //
	
	thread scripts\class\_cac::init();
	thread scripts\class\_spawn::init();
	
	//thread scripts\class\_humans::init();
	//thread scripts\class\_monsters::init();
	
	//thread scripts\class\humans\_inventory::init();
	
	// =========================================== //
	// ================= SHOP ==================== //

	thread scripts\shop\_shopMain::init();
	
	// =========================================== //
	// ================ PLUGINS ================== //

	plugins\maps\_des_obj::DestructibleEntity( "basic", undefined, 10, undefined, undefined, undefined, undefined, undefined, undefined, undefined );
	
	setdvar( "g_deadChat", 1 );
	
	setClientNameMode("auto_change");
	
	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );
	
	scripts\_events::RunCallback( level, "onStartGameType", 1 );
	
	thread RunDelayedThreads();
}

RunDelayedThreads()
{
	waittillframeend;
	scripts\shop\_shopTriggers::SearchTriggers();
	
	waittillframeend;
	
}

/* =========================================== */
/* ======= Callback_PlayerConnect() ========== */
/* =========================================== */

Callback_PlayerConnect()
{
	thread notifyConnecting();

	self.reallyAlive = false;
	self.statusicon = "hud_status_connecting";
	self waittill( "begin" );
	waittillframeend;
	
	self SetClientDvar( "playerConnect", 0 );
	self setOrigin( level.spawns["spectator"][ RandomInt( level.spawns["spectator"].size ) ].origin );
	
	self.b3level = 0;
	self.showme = 1;
	self.acp_info = "1:0";
	self.SpawnPlayer = SpawnStruct();
	
	if( IsDefined( self.pers["b3level"] ) )
		self.b3level = self.pers["b3level"];

	if( IsDefined( self.pers["showme"] ) )
		self.showme = self.pers["showme"];
	
	if( !level.splitscreen && !isdefined( self.pers["score"] ) )
		iPrintLn(&"MP_CONNECTED", self);
	
	self initPersStat( "score" );
	self initPersStat( "kills" );
	self initPersStat( "kills_humans" );
	self initPersStat( "kills_monsters" );
	self initPersStat( "assists" );
	self initPersStat( "deaths" );
	self.score = self.pers["score"];
	self.kills = self.pers["kills"];
	self.assists = self.pers["assists"];
	self.deaths = self.pers["deaths"];
	
	thread scripts\clients\_time::OnConnected( self );
	
	if( !isDefined( self.pers["team"] ) )
		self.pers["team"] = "spectator";
	
	self.team = self.pers["team"];
	
	//DEV
	if( getdvar( "r_reflectionProbeGenerate" ) == "1" )
		level waittill( "eternity" );
	
	if( !isdefined( self.pers["MonsterPicked"] ) )
		self.pers["MonsterPicked"] = 0;
		
	if( !isdefined( self.pers["RoundsPlayed"] ) )
	{
		self.pers["RoundsPlayed"] = 1;
		self.firstConnect = true;
	}
	else
		self.pers["RoundsPlayed"]++;
	
	self updateScores();
	
	
	lpselfnum = self getEntityNumber();
	lpGuid = self getGuid();
	logPrint("J;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");
	level.players[level.players.size] = self;
	
	
	self scripts\clients\_rank::onPlayerConnected();
	
	if( !level.dvars["developer"] )
		wait 0.1;
	
	self scripts\clients\_cvar::CreateCvarList();
	
	if( !level.dvars["developer"] )
		wait 0.1;
	
	if( IsDefined( self.firstConnect ) )
	{
		self scripts\clients\_stats::ResetStatsOnConnect();
	
		if( !level.dvars["developer"] )
			wait 0.1;
	}
	
	self thread scripts\clients\_damagefeedback::OnPlayerConnected();
	//self thread scripts\clients\_menus::CLIENT_onMenuResponse();
	//self scripts\_players::CreateHuds();
	self thread scripts\_flashgrenades::monitorFlash();
	//self thread maps\mp\gametypes\_healthoverlay::overlay();	
	self thread scripts\clients\_menus::MonitorMenuResponses();
	self thread scripts\clients\_binds::OnPlayerConnected();
	
	// notify connected
	level notify( "connected", self );
	
	// call callbacks
	scripts\_events::RunCallback( level, "connected", 1, self );

	if( !level.dvars["developer"] )
		wait 0.1;
	
	level endon( "game_ended" );
	
	if( isDefined( self.pers["isBot"] ) )
		return;
	
	//scripts\_maps::MapErrors();
	
	self setclientdvar( "g_scriptMainMenu", game["menu_team"], "playerConnect", 1 );
	
	if( level.dvars["developer"] || level.dvars["autospawn"] )
	{
		//self scripts\class\_changeclass::AutoSelectClass( "allies", 0 );
		self thread [[level.Allies]]();
	}
	else
	{
		if ( self.pers["team"] == "spectator" )
			[[level.spectator]]();
		else	
			self [[level.AutoAssign]]();
	}
}

notifyConnecting()
{
	waittillframeend;

	if( isDefined( self ) )
		level notify( "connecting", self );
}

initPersStat( dataName )
{
	if( !isDefined( self.pers[dataName] ) )
		self.pers[dataName] = 0;
}

getPersStat( dataName )
{
	return self.pers[dataName];
}

incPersStat( dataName, increment )
{
	self.pers[dataName] += increment;
	self maps\mp\gametypes\_persistence::statAdd( dataName, increment );
}

/* =========================================== */
/* ====== Callback_PlayerDisconnect() ======== */
/* =========================================== */

Callback_PlayerDisconnect()
{
	level notify( "disconnected", self );

	self removePlayerOnDisconnect();
	
	lpselfnum = self getEntityNumber();
	lpGuid = self getGuid();
	logPrint("Q;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");
	
	//acp
	setdvar( "acp_info_" + lpselfnum, "" );
	//----
	
	// call callbacks
	scripts\_events::RunCallback( level, "disconnected", 0, self );
	scripts\_events::RunCallback( self, "disconnected", 0 );
	
	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if ( level.players[entry] == self )
		{
			while ( entry < level.players.size-1 )
			{
				level.players[entry] = level.players[entry+1];
				entry++;
			}
			level.players[entry] = undefined;
			break;
		}
	}
}

removePlayerOnDisconnect()
{
	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if ( level.players[entry] == self )
		{
			while ( entry < level.players.size-1 )
			{
				level.players[entry] = level.players[entry+1];
				entry++;
			}
			level.players[entry] = undefined;
			break;
		}
	}
}

/* =========================================== */
/* ========= Callback_PlayerDamage =========== */
/* =========================================== */

Callback_PlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if( !IsDefined( self ) || !IsPlayer( self ) || self.pers["team"] == "spectator" || self.sessionteam == "spectator" )
		return;

	if( level.gameState[ self.pers["team"] ] != "playing" ) //prematch status
		return;
			
	if( IsDefined( eAttacker ) && IsPlayer( eAttacker ) && eAttacker != self && self.pers["team"] == eAttacker.pers["team"] ) //friendly fire
		return;

	// Don't do knockback if the damage direction was not specified
	if( !IsDefined( vDir ) )
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	if ( IsHeadShot( sWeapon, sHitLoc, sMeansOfDeath ) )
		sMeansOfDeath = "MOD_HEAD_SHOT";
	
	// explosive barrel/car detection
	if ( sWeapon == "none" && IsDefined( eInflictor ) )
	{
		if ( IsDefined( eInflictor.targetname ) && eInflictor.targetname == "explodable_barrel" )
			sWeapon = "explodable_barrel";
		else if ( IsDefined( eInflictor.destructible_type ) && IsSubStr( eInflictor.destructible_type, "vehicle_" ) )
			sWeapon = "destructible_car";
	}
	
	// ============================================================================================================================================================================================= //	
	// callbacks and modify
	self.PlayerDamage = SpawnStruct();
	self.PlayerDamage.eInflictor 	= eInflictor;
	self.PlayerDamage.eAttacker 	= eAttacker;
	self.PlayerDamage.iDamage 		= iDamage;
	self.PlayerDamage.iDFlags 		= iDFlags;
	self.PlayerDamage.sMeansOfDeath = sMeansOfDeath;
	self.PlayerDamage.sWeapon 		= sWeapon;
	self.PlayerDamage.vPoint 		= vPoint;
	self.PlayerDamage.vDir 			= vDir;
	self.PlayerDamage.sHitLoc 		= sHitLoc;
	self.PlayerDamage.psOffsetTime 	= psOffsetTime;
	
	// modify info by class
	self scripts\class\_spawn::ModifyPlayerDamage();
	
	scripts\_events::RunCallback( level, "playerDamage", 0, self );
	scripts\_events::RunCallback( self, "playerDamage", 0 );	
	
	eInflictor 		= self.PlayerDamage.eInflictor;
	eAttacker 		= self.PlayerDamage.eAttacker;
	iDamage 		= self.PlayerDamage.iDamage;
	iDFlags 		= self.PlayerDamage.iDFlags;
	sMeansOfDeath 	= self.PlayerDamage.sMeansOfDeath;
	sWeapon			= self.PlayerDamage.sWeapon;
	vPoint 			= self.PlayerDamage.vPoint;
	vDir 			= self.PlayerDamage.vDir;
	sHitLoc 		= self.PlayerDamage.sHitLoc;
	psOffsetTime 	= self.PlayerDamage.psOffsetTime;
	self.PlayerDamage = undefined;
	// ============================================================================================================================================================================================= //
	
	// check for completely getting out of the damage
	if( !(iDFlags & level.iDFLAGS_NO_PROTECTION) )
	{
		// Make sure at least one point of damage is done
		iDamage = Int( iDamage );
		if( iDamage < 1 )
			return;
		
		//if( IsDefined( eAttacker ) && IsPlayer( eAttacker ) && eAttacker != self )
			//eAttacker [[level.giveScore]]( undefined, iDamage, "score_damage" );
			
		self finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
	}
}

finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if( IsDefined( eAttacker ) && IsPlayer( eAttacker ) && eAttacker.pers["team"] != self.pers["team"] && AllowMeansOfDeath( sMeansOfDeath ) && IsDefined( vDir ) )
	{
		//IPrintLnBold( "vDir " + vDir[2] );
	
		zDir = vDir[2];
		if( zDir > 0 )
			zDir *= 0.5;
			
		//IPrintLnBold( "zDir " + zDir );
			
		strength = 1;
		if( zDir > 0 )
			strength = (0.5-zDir)*2;
			
		//IPrintLnBold( "strength " + strength );
		self REPEL_Kick( strength*(iDamage/600), (vDir[0], vDir[1], zDir) );
	}

	
	self scripts\clients\_hud::SetHealthBar( ( (self.health - iDamage) / self.maxHealth ) * 100 );
	
	scripts\_events::RunCallback( level, "onPlayerDamage", 1, self, eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
	scripts\_events::RunCallback( self, "onPlayerDamage", 1, eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );	
	
	if( IsDefined( eAttacker ) && IsPlayer( eAttacker ) && IsDefined( iDamage ) && IsDefined( sMeansOfDeath ) && IsDefined( sWeapon ) && IsDefined( sHitLoc ) )
		IPrintLn( "DMG: self;^1"+self.name+"^7;eAttacker;^1"+eAttacker.name+"^7;iDamage;^1"+iDamage+"^7;sMeansOfDeath;^1"+sMeansOfDeath+"^7;sWeapon;^1"+sWeapon+"^7;sHitLoc;^1"+sHitLoc );
		
	if( IsDefined( sMeansOfDeath ) )
		IPrintLn( "sMeansOfDeath;^1"+sMeansOfDeath );
		
	// BLOOD
	self ApplyBlood( sMeansOfDeath, vPoint );
	
	// SCORE
	if( IsDefined( eAttacker ) && IsPlayer( eAttacker ) && eAttacker != self )
	{
		if( !IsDefined( self.takenDamage ) )
			self.takenDamage = [];
		
		self.takenDamage[eAttacker GetGuid()] = iDamage;
		
		eAttacker scripts\clients\_damagefeedback::UpdateDamageFeedback();
	}
	
	self FinishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
	self DamageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage );
}

AllowMeansOfDeath(type)
{
	switch(type)
	{
		case "MOD_RIFLE_BULLET":
		case "MOD_PISTOL_BULLET":
		case "MOD_PROJECTILE_SPLASH":
		case "MOD_PROJECTILE":
			return true;
		default:
			return false;
	}
}

ApplyBlood( sMeansOfDeath, vPoint )
{
	if( IsDefined( sMeansOfDeath ) && (sMeansOfDeath == "MOD_MELEE" || sMeansOfDeath == "MOD_HEAD_SHOT") && RandomInt( 100 % 3 ) == 0 )
		PlayFX( AddFXToList( "impacts/blood_large" ), vPoint );
	else if( sMeansOfDeath != "MOD_FALLING" && sMeansOfDeath != "MOD_SUICIDE" && sMeansOfDeath != "MOD_TRIGGER_HURT" )
		PlayFX( AddFXToList( "impacts/blood_small" ), vPoint );
}

DamageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage )
{
	//self thread maps\mp\gametypes\_weapons::onWeaponDamage( eInflictor, sWeapon, sMeansOfDeath, iDamage );
	self PlayRumbleOnEntity( "damage_heavy" );
}

IsHeadShot( sWeapon, sHitLoc, sMeansOfDeath )
{
	return (sHitLoc == "head" || sHitLoc == "helmet") && sMeansOfDeath != "MOD_MELEE" && sMeansOfDeath != "MOD_IMPACT";
}

/* =========================================== */
/* ========= Callback_PlayerKilled =========== */
/* =========================================== */

Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{	
	self endon( "spawned_player" );

	if ( self.pers["team"] == "spectator" )
		return;
	
	if( isHeadShot( sWeapon, sHitLoc, sMeansOfDeath ) )
		sMeansOfDeath = "MOD_HEAD_SHOT";
	
	if( attacker.classname == "script_vehicle" && isDefined( attacker.owner ) )
		attacker = attacker.owner;

	// ============================================================================================================================================================================================= //	
	// callbacks and modify
	self.PlayerKilled = SpawnStruct();
	self.PlayerKilled.eInflictor 		= eInflictor;
	self.PlayerKilled.attacker 			= attacker;
	self.PlayerKilled.iDamage 			= iDamage;
	self.PlayerKilled.sMeansOfDeath 	= sMeansOfDeath;
	self.PlayerKilled.sWeapon 			= sWeapon;
	self.PlayerKilled.vDir 				= vDir;
	self.PlayerKilled.sHitLoc 			= sHitLoc;
	self.PlayerKilled.psOffsetTime 		= psOffsetTime;
	self.PlayerKilled.deathAnimDuration	= deathAnimDuration;
	
	scripts\_events::RunCallback( level, "playerKilled", 0, self );
	scripts\_events::RunCallback( self, "playerKilled", 0 );

	eInflictor 			= self.PlayerKilled.eInflictor;
	attacker 			= self.PlayerKilled.attacker;
	iDamage 			= self.PlayerKilled.iDamage;
	sMeansOfDeath 		= self.PlayerKilled.sMeansOfDeath;
	sWeapon 			= self.PlayerKilled.sWeapon;
	vDir 				= self.PlayerKilled.vDir;
	sHitLoc 			= self.PlayerKilled.sHitLoc;
	psOffsetTime 		= self.PlayerKilled.psOffsetTime;
	deathAnimDuration 	= self.PlayerKilled.deathAnimDuration;
	self.PlayerKilled = undefined;
	// ============================================================================================================================================================================================= //	
		
	// send out an obituary message to all clients about the kill
	if( sMeansOfDeath == "MOD_MELEE" && sWeapon == "hind_ffar_mp" )
		Obituary(self, attacker, sWeapon, "MOD_PISTOL_BULLET" );
	else
		Obituary(self, attacker, sWeapon, sMeansOfDeath );	

	self.sessionstate = "dead";
	self.spawned = undefined;
	self.reallyAlive = false;
	
	self scripts\clients\_players::UpdateStatusIcon();
	
	self incPersStat( "deaths", 1 );
	
	lpselfnum = self getEntityNumber();
	lpselfname = self.name;
	lpattackGuid = "";
	lpattackname = "";
	lpselfteam = self.pers["team"];
	lpselfguid = self getGuid();
	lpattackerteam = "";

	lpattacknum = -1;

	if( isPlayer( attacker ) )
	{
		lpattackGuid = attacker GetGuid();
		lpattackname = attacker.name;
		lpattackerteam = attacker.pers["team"];

		if ( attacker != self ) // killed by enemy
		{
			lpattacknum = attacker getEntityNumber();

			if ( sMeansOfDeath == "MOD_HEAD_SHOT" )
			{
				attacker [[level.giveScore]]( "score_headshot" );
				attacker playLocalSound( "bullet_impact_headshot_2" );
			}
			else
				attacker [[level.giveScore]]( "score_kill" );

			if( IsDefined( self.takenDamage ) )
			{
				guids = GetArrayKeys( self.takenDamage );
				for( i = 0; i < level.players.size; i++ )
				{
					player = level.players[i];
					if( IsDefined( player ) && IsPlayer( player ) && player.pers["team"] != "spectator" && player.pers["team"] != self.pers["team"] )
					{
						guid = player GetGuid();
						if( ARRAY_Contains( guids, guid ) )
						{
							damage = self.takenDamage[guid];
							player [[level.giveScore]]( "score_damage", level.dvars["score_damage_"+self.pers["team"]]*damage );
						}
					}
				}
				self.takenDamage = undefined;
			}
			
			attacker IncPersStat( "kills", 1 );
			attacker.kills = attacker GetPersStat( "kills" );
			
			if( self.pers["team"] == "allies" )
				attacker IncPersStat( "kills_humans", 1 );
			else
				attacker IncPersStat( "kills_monsters", 1 );
		}
	}
	else
	{
		lpattacknum = -1;
		lpattackguid = "";
		lpattackname = "";
		lpattackerteam = "world";
	}			

	logPrint( "K;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackguid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n" );

	///////////////////////////////////////////////////////////////
	//RAGDOLL
	///////////////////////////////////////////////////////////////
	body = self clonePlayer( deathAnimDuration );
	if ( self isOnLadder() || self isMantling() )
		body startRagDoll();
	
	//thread delayStartRagdoll( body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath );

	self.body = body;
	thread scripts\_deathicons::addDeathicon( body, self, self.pers["team"], 5.0 );
	
	self unLink();
	self FreezeControls( false );
	self setClientDvar( "hud_bottom_bar", 0 );
		
	// let the player watch themselves die
	wait 1;
	
	self scripts\clients\_inventory::DeleteInventoryOnDeath();
	
	self notify ( "death_delay_finished" );
	
	self [[level.GT_OnDeath]]( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );
	
	scripts\_events::RunCallback( level, "onPlayerKilled", 1, self, eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );
	scripts\_events::RunCallback( self, "onPlayerKilled", 1, eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );
}

//RAGDOLL-TWSE
delayStartRagdoll( ent, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath )
{
// change the line below if you play in an other gameplay
	if ( !isDefined( vDir ) )
	{
	 vDir = (0,0,0);
	}

	explosionPos = ent.origin + ( 0, 0, getHitLocHeight( sHitLoc ) );
	explosionPos -= vDir * 20;
	//thread debugLine( ent.origin + (0,0,(explosionPos[2] - ent.origin[2])), explosionPos );
	explosionRadius = 40;
	explosionForce = .75;
	// if you die by a grenade or an explosion
	if ( sMeansOfDeath == "MOD_EXPLOSIVE" || sMeansOfDeath == "MOD_IMPACT" || isSubStr(sMeansOfDeath, "MOD_GRENADE") || isSubStr(sMeansOfDeath, "MOD_PROJECTILE") )
	{
	 explosionForce = 5;
	 explosionRadius = 50;
	}
	//  if you die by a Barrett bullet
	if ( sWeapon == "barrett_acog_mp" || sWeapon == "barrett_mp" )
	{
	 explosionForce = 2;
	}
	//  if you die by a winchester1200
	if ( sWeapon == "winchester1200_mp" || sWeapon == "winchester1200_grip_mp" || sWeapon == "winchester1200_reflex_mp" )
	{
	 explosionForce = 2;
	}
	//  if you die by a HELI-20mm
	if ( sWeapon == "cobra_20mm_mp" )
	{
	 explosionForce = 3;
	}
	 //  if you die by a DESERT-gold
	if ( sWeapon == "deserteaglegold_mp" )
	{
	 explosionForce = 2;
	}
	// if you die by a headshot
	if ( sHitLoc == "head" || sHitLoc == "helmet" )
	{
	 explosionForce = 1.5;
	}
	// if you die from a fall
	if ( sMeansOfDeath == "MOD_FALLING" )
	{
	 explosionForce = 1.5;
	}

	ent startragdoll( 1 );

	wait .05;

	if ( !isDefined( ent ) )
	{
	 return;
	}

	// apply extra physics force to make the ragdoll go crazy
	// i don't realy know what does this line mean but...
	physicsExplosionSphere( explosionPos, explosionRadius, explosionRadius/2, explosionForce );
	return;
}

getHitLocHeight( sHitLoc )
{
	switch( sHitLoc )
	{
		case "helmet":
		case "head":
		case "neck":
			return 60;
		case "torso_upper":
		case "right_arm_upper":
		case "left_arm_upper":
		case "right_arm_lower":
		case "left_arm_lower":
		case "right_hand":
		case "left_hand":
		case "gun":
			return 48;
		case "torso_lower":
			return 40;
		case "right_leg_upper":
		case "left_leg_upper":
			return 32;
		case "right_leg_lower":
		case "left_leg_lower":
			return 10;
		case "right_foot":
		case "left_foot":
			return 5;
	}
	return 48;
}

/* =========================================== */
/* ======== Callback_PlayerLastStand ========= */
/* =========================================== */

Callback_PlayerLastStand( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
}
