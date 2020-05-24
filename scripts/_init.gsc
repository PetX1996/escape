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
	level.Dvars = [];
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

// ================================================================================================================================================================================================ //
// ================================================================================================================================================================================================ //
// ================================================================================================================================================================================================ //
// ================================================================================================================================================================================================ //
// ================================================================================================================================================================================================ //

// func pointers...
// level.GT_SpawnPlayer
// level.GT_OnDeath
// level.EndRound
// level.EndMap

// __DATE__         // compile date '27. 3. 2013'
// __TIME__         // compile time '16:32'
// __FILE__         // file name '_ai'
// __FILEFULL__     // raw path + file name 'scripts\_ai'
// __LINE__         // current line number '73'
// __LINEFULL__     // current line '	if( !IsDefined( team ) )'
// __FUNCTION__     // current function name 'AI'
// __FUNCTIONFULL__ // current function name + signature 'AI( origin, angles )'
// __INT_MIN__      // min int number '-2147483647'
// __INT_MAX__      // max int number '2147483647'

/*
4096 Dvars
63+1 Dvar name characters shown in console, but the names can be longer
2048 Fx (simultaneously playing)
400 Fx Asset limit (at least CoD5)
2048 Material assets (see here for fix)
1000 Model assets
128 Tags (Joints) in MP
31 HUD Elements (Client)
1600 Sounds
Test map, brushes: 102,631 (138,752)
97.8 MB mapfile

1024 maximálny poèet entít v mape
6144 localized strings

XMODELS
! ak sa používa funkcia PreCacheModel() na model, ktorý nie je v FF, aj tak ho to pridá!!!
! výsledkom je ingame error '1000 xmodel assets', inak je error hlásený v MessageBox-e
! Pri spustení hry lokálne v developeri sa to chová podivne, pridávajú sa aj modely, ktoré tam nemajú èo robi...

mp_backlot 320
mp_citystrees 371

//////////////////////////////////////////////////////////////////////////////////////
// ko¾ko krát sa môže opakova cyklus bez waitu?
// èím viac bordelu tento cyklus obsahuje, tým menej krát sa môže opakova
//////////////////////////////////////////////////////////////////////////////////////
//       100 v pohode
//     1 000 bodka na lagometri
//    10 000 ve¾ká zelená palièka
//   100 000 ve¾ká èervená palièka+výpadok pripojenia
// 1 000 000 pád serveru/zlikvidovanie funkcie
//////////////////////////////////////////////////////////////////////////////////////
//   111 215 - zápis do logu+matematické výpoèty
//   154 763 - zápis do logu
//////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////
// ko¾ko je vo¾ných dvarov na strane klienta?
////////////////////////////////////////////////////
// 4096 - maximum
// cca. 2700 - 2950 vo¾ných
////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// ko¾ko premenných je možné maximálne použi?
////////////////////////////////////////////////////////////
// lokálne/èlenské dáta
// 125/377		- aktuálne používané
// 64246/375	- maximum pridaním lokálnej premennej
// 32190/32431	- maximum pridaním èlenských dát
////////////////////////////////////////////////////////////
// 64621		- maximum po spoèítaní všekých premenných
////////////////////////////////////////////////////////////

//
// ====== VARIABLE OVERFLOW ======
//
// maximum = 65536
//
// Aktívna funkcia 					- current++
//
// ====== EVENTS ======
// Aktívny waittill 				- maximum--
// Aktívny endon					- maximum--
//
// ====== LOCAL ======
// integer			max 2147483647(4 bajt) - current++
// float							- current++
// string			max cca. 2300	- current++
// array							- current++
// function address					- current++
//
// ====== STRUCT ======
// pridanie štruktúry				- current++
// pridanie èlenského data			- current++
//

////////////////////////////////////////////////////////////
// aká je maximálna ve¾kos dvaru?
////////////////////////////////////////////////////////////
// cca 1000 znakov :)
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// aké èíslo je možné uloži do statu?
////////////////////////////////////////////////////////////
// menšie - 0 - 255
// väèšie - -2147483647 - 2147483647
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// BULLETTRACE
////////////////////////////////////////////////////////////
// position - zasiahnutý bod
// fraction - pomer urazenej dráhy k celkovej dráhe
// entity - zasiahnutá entita
// normal - orientácia zasiahnutého polygonu
// surfacetype - materiál zasiahnutého polygonu
// 				default
//				bark
//				brick
//				carpet
//				cloth
//				concrete
//				dirt
//				flesh
//				foliage
//				glass
//				grass
//				gravel
//				ice
//				metal
//				mud
//				paper
//				rock
//				sand
//				snow
//				water
//				wood
//				asphalt
////////////////////////////////////////////////////////////

// ==============================================================================================================================================================================//
// MENU
// ==============================================================================================================================================================================//

On the site of ModsOnline Wiki there are a lot of functions, commands, (reserved) keys and flags related to menu scripting. The only problem is that they are not explained...

http://www.modsonwiki.com/index.php/Call_of_Duty_4:_Script_-_Menu_Scripting

Maybe, we could try and explain them all and show how they work as some kind of tutorial?

Structural Items

	itemDef
	menuDef
	assetGlobalDef
	
Flags

	autowrapped	- zalamovanie textu
	decoration - zákázanie blikania textu
	hidenDuringFlashbang
	hidenDuringScope
	horizontalscroll
	legacySplitScreenScale
	outOfBoundsClick
	noscrollbars
	popup - menu v menu

Functions

	action 			When the item or menu is clicked
	doubleclick	 	When the item or menu is double-clicked
	execKey <key>   When pressed this key
	execKeyInt <key>
	focusDvar
	focusFirst
	leaveFocus		When mouse is not on item
	mouseEnter	 	When the mouse enters the item or menu
	mouseEnterText
	mouseExit		When the mouse exits the item or menu
	mouseExitText
	onClose			When the menu is closed
	onEsc			When Esc(ape) is pressed
	onFocus			When mouse is on item
	onOpen			When the menu is opened

Commands and Tests

	close								<menu>
	closeforgametype
	closeMenuOnDvar						<dvarName> <dvarValue> <menuName>
	exec								<arg>
	execnow								<arg>
	execNowOnDvarFloatValue				<dvar> <value> <arg>
	execNowOnDvarIntValue				<dvar> <value> <arg>
	execNowOnDvarStringValue			<dvar> <value> <arg>
	execOnDvarFloatValue				<dvar> <value> <arg>
	execOnDvarIntValue					<dvar> <value> <arg>
	execOnDvarStringValue				<dvar> <value> <arg>
	fadein
	fadeout
	getautoupdate
	hide
	ingameclose
	ingameopen
	nextlevel
	nosavehide
	open								<menu>
	openforgametype
	openMenuOnDvar						<dvar> <value> <menu>
	openMenuOnDvarNot					<dvar> <value> <menu>
	openScriptMenu 						<menu> <menuResponse>
	play
	profilehide
	profileshow
	saveAvailableHide
	saveDelay
	savegamehide
	savegameshow
	scriptMenuRespondOnDvarFloatValue	<dvar> <value> <message>
	scriptMenuRespondOnDvarIntValue		<dvar> <value> <message>
	scriptMenuRespondOnDvarStringValue	<dvar> <value> <message>
	scriptmenuresponse					<message>
	setbackground 						<material>
	setcolor							<key> <red> <green> <blue> <alpha>
	setdvar								<dvar> <value>
	setfocus
	setfocusbydvar						<dvarName>
	setitemcolor						<item name>	<key> <red> <green> <blue> <alpha>		
	setLocalVarInt						<name> <value>
	setLocalVarString					<name> <value>
	setSaveExecOnSuccess
	show
	showGamerCard
	showhidenewgameresume
	uiScript
	writeSave

Keywords

	accept
	align
	backcolor   	<red> <green> <blue> <alpha>
	background 		<material name>
	blurworld		<value> [MenuDef only]
	border			<int>
	bordercolor		<red> <green> <blue> <alpha>
	bordersize		<float/int>
	columns
	disablecolor
	disableDvar
	dvar
	dvarEnumList
	dvarFloat
	dvarFloatList
	dvarStrList
	dvarTest		<dvarName>
	elementheight
	elementtype
	elementwidth
	enableDvar
	exp forecolor A( <float> )
	exp material( <materialName> )
	exp text( <text> )
	exp rect H( <int> )
	exp rect W( <int> )
	exp rect X( <int> )
	exp rect Y( <int> )
	fadeAmount
	fadeClamp
	faceCycle
	fadeInAmount
	feeder
	focuscolor
	focusSound
	forecolor		<red> <green> <blue> <alpha>
	fullscreen		<boolean>
	group
	hideDvar		{ <dvar enum for dvarTest> }
	maxChars   : Maximum amount of characters in a textfield
	maxCharsGotoNext
	maxPaintChars: Maximum amount of characters in the with of a textfield
	name 			<item name>
	noscrollbars
	notselectable
	origin			<x> <y>
	outlinecolor	<red> <green> <blue> <alpha>
	ownerdraw		<int>
	ownerdrawFlag
	rect 			<x> <y> <width> <height> <horizontal align> <vertical align>
	showDvar		{ <dvar enum for dvarTest> }
	soundloop		<soundalias>
	special
	style			<int>
	text			<string>
	textalign		<int>
	textalignx		<int>
	textaligny		<int>
	textfile
	textfont		<int>
	textsavegame
	textscale		<float>
	textstyle		<int>
	type			<int>
	visible			<boolean>

PreCompile Args & Operations

	#include

	#define
	#undef

	#ifdef <variable> .. #endif
	#ifdef <variable> .. #else .. #endif

	#ifndef <variable> .. #endif
	#ifndef <variable> .. #else .. #endif

	#if <condition> .. #endif
	#if <condition> .. #elif <condition> .. #endif

Conditional functions

	defined( <variable> )

Operators
	
	() * / + - % > >= < <= == || && 
	
	?:
	
Functions

	Cos( <value> )
	DvarBool( <name> )
	DvarInt( <name> )
	DvarString( <name> )
	GameTypeDescription()
	GameTypeName()
	InPrivateParty()
	Int( <value> )
	IsIntermission()
	LocalVarBool( <name> )
	LocalVarInt( <name> )
	LocalVarString( <name> )
	LocString( <locString> )
	MarinesField( "score" )
	Max( <valueA>, <valueB> )
	Milliseconds()
	Min( <valueA>, <valueB> )
	OpforField( "score" )
	OtherTeam( "score" )
	Player( "score" )
	PrivatePartyHost()
	PrivatePartyHostInLobby()
	SecondsAsCountdown( <time> )
	Sin( <value> )
	Stat( <statId> )
	String( <value> )
	TableLookUp( <fileName>, <search column num>, <search value>, <return column num> )
	Team( "name" )
	Team( "score" )
	TimeLeft()
	When( <condition> )
*/

/*
"toggle ui_primary_type smg rifle shotgun sniper"
"statGetInDvar 2313 ui_stat_time_played_other"
"statset 260 1"
scriptMenuResponse "assault_mp,0" // ,0 - WTF?!
"setdvartotime ui_time_marker"
*/

// =============================== //
// == Poradie spúštania funkcií == //
// =============================== //
/*
GSC modu - main()
GSC mapy - main()
Callback_StartGameType()
*/
// =============================== //

/* 
TODO: preskumat toto!

"Press^3 [{+activate}] ^7to respawn"

nachadza sa v lokalizacnom subore, je mozne pouzit aj v iprintln()/iprintlnbold()

je mozne poslat ako cvar a zobrazovat v menu?

Gets a key binding. Applicable values are: "+scores","+speed","+forward","+back", "+moveleft","+moveright", "+moveup", "+movedown", "+left", "+right", "+strafe", "+lookup", "+lookdown", "+mlook", "centerview", "toggleads","+melee", "+prone", "lowerstance", "raisestance", "togglecrouch", "toggleprone", "goprone", "gocrouch", "+gostand", "weaponslot primary", "weaponslot primaryb", "+attack", "weapprev", "weapnext", "+activate", "+reload", "+leanleft", "+leanright", "screenshot", "screenshotJPEG", 

*/

/*
Dnesne napady(3.3.2012)
----------------------------

perky pre ludi:
1. spray(new tlacitko, zobrazovat v hude?)
2. svetlo(dpad - N, nightvision-flashlight-light granade-laser)
3. dalsia blbost(origo perky, rychlost a pod.)
4. pridat new perk?

inventar ludi:
1. vybusniny(c4, clay, rpg, ...)
2. miny, strazci a dalsie blbosti...
3. aj 3 polozka?
*/

/*
======POZNAMKY==============


		  0:01  150 ; 0 = CLASS ALLIES START
		  0:01  151 ; 0 
		  0:01  152 ; 0 
		  0:01  153 ; 0 
		  0:01  154 ; 1 
		  0:01  155 ; 0 
		  0:01  156 ; 1 
		  0:01  157 ; 0 
		  0:02  158 ; 0 
		  0:02  159 ; 0 
		  0:02  160 ; 1 
		  0:02  161 ; 1 
		  0:02  162 ; 1 
		  0:02  163 ; 0 
		  0:02  164 ; 0 
		  0:02  165 ; 0 
		  0:02  166 ; 0 
		  0:02  167 ; 1 
		  0:02  168 ; 0 
		  0:02  169 ; 0 
		  0:02  170 ; 0 
		  0:02  171 ; 0 
		  0:02  172 ; 0 
		  0:02  173 ; 0 
		  0:02  174 ; 0 
		  0:02  175 ; 0 
		  0:02  176 ; 1 
		  0:02  177 ; 0 
		  0:03  178 ; 0 
		  0:03  179 ; 0 
		  0:03  180 ; 0 
		  0:03  181 ; 0 
		  0:03  182 ; 0 
		  0:03  183 ; 0 
		  0:03  184 ; 1 
		  0:03  185 ; 0 
		  0:03  186 ; 1 
		  0:03  187 ; 0 
		  0:03  188 ; 0
		  0:03  189 ; 0 
		  0:03  190 ; 1 
		  0:03  191 ; 0 
		  0:03  192 ; 0 
		  0:03  193 ; 0 
		  0:03  194 ; 0 
		  0:03  200 ; 0 
		  0:03  201 ; 25 
		  0:03  202 ; 5 
		  0:04  203 ; 0 
		  0:04  204 ; 0 
		  0:04  205 ; 191 
		  0:04  206 ; 160 
		  0:04  207 ; 154 
		  0:04  208 ; 103 
		  0:04  209 ; 0 
		  0:04  210 ; 0 
		  0:04  211 ; 10 
		  0:04  212 ; 0 
		  0:04  213 ; 2 
		  0:04  214 ; 3 
		  0:04  215 ; 184 
		  0:04  216 ; 156 
		  0:04  217 ; 162 
		  0:04  218 ; 101 
		  0:04  219 ; 0 
		  0:04  220 ; 0 
		  0:04  221 ; 81 
		  0:04  222 ; 0 
		  0:05  223 ; 2 
		  0:05  224 ; 0 
		  0:05  225 ; 176 
		  0:05  226 ; 167 
		  0:05  227 ; 161 
		  0:05  228 ; 103 
		  0:05  229 ; 0 
		  0:05  230 ; 0 
		  0:05  231 ; 71 
		  0:05  232 ; 0 
		  0:05  233 ; 0 
		  0:05  234 ; 0 
		  0:05  235 ; 186 
		  0:05  236 ; 156 
		  0:05  237 ; 154 
		  0:05  238 ; 102 
		  0:05  239 ; 0 
		  0:05  240 ; 0 
		  0:05  241 ; 61 
		  0:05  242 ; 0 
		  0:06  243 ; 0 
		  0:06  244 ; 3 
		  0:06  245 ; 176 
		  0:06  246 ; 160 
		  0:06  247 ; 161 
		  0:06  248 ; 101 
		  0:06  249 ; 0 
		  0:06  257 ; 0 
		  0:06  258 ; 0 
		  0:06  260 ; 0 
		  0:06  261 ; 0 
		  0:06  262 ; 0 = CLASS ALLIES END
		  0:06  263 ; 0 = CLASS AXIS START
		  0:06  264 ; 0 
		  0:06  290 ; 0 
		  0:06  291 ; 0 
		  0:06  292 ; 0 
		  0:06  293 ; 0 
		  0:06  294 ; 0 
		  0:06  295 ; 0 
		  0:07  296 ; 0 
		  0:07  297 ; 0 
		  0:07  298 ; 0 
		  0:07  501 ; 0 
		  0:07  502 ; 0 
		  0:07  503 ; 0 
		  0:07  504 ; 0 
		  0:07  505 ; 0 
		  0:07  506 ; 0 
		  0:07  507 ; 0 
		  0:07  508 ; 0 
		  0:07  509 ; 0 
		  0:07  510 ; 0 
		  0:07  511 ; 0 
		  0:07  512 ; 0 
		  0:07  513 ; 0 
		  0:07  521 ; 0 
		  0:07  522 ; 0 
		  0:07  523 ; 0 
		  0:07  524 ; 0 
		  0:08  525 ; 0 
		  0:08  526 ; 0 
		  0:08  527 ; 0 
		  0:08  528 ; 0 
		  0:08  529 ; 0 
		  0:08  530 ; 0 
		  0:08  541 ; 0 
		  0:08  542 ; 0 
		  0:08  543 ; 0 
		  0:08  544 ; 0 
		  0:08  545 ; 0 
		  0:08  546 ; 0 
		  0:08  561 ; 0 
		  0:08  562 ; 0 
		  0:08  563 ; 0 
		  0:08  564 ; 0 
		  0:08  581 ; 0 
		  0:08  582 ; 0 
		  0:08  583 ; 0 
		  0:08  584 ; 0 
		  0:09  585 ; 0 
		  0:09  586 ; 0 
		  0:09  587 ; 0 
		  0:09  588 ; 0 
		  0:09  589 ; 0 
		  0:09  590 ; 0 
		  0:09  601 ; 0 
		  0:09  602 ; 0 
		  0:09  603 ; 0 
		  0:09  604 ; 0 
		  0:09  605 ; 0 
		  0:09  606 ; 0 
		  0:09  607 ; 0 
		  0:09  608 ; 0 
		  0:09  609 ; 0 
		  0:09  610 ; 0 
		  0:09  611 ; 0 
		  0:09  612 ; 0 
		  0:09  613 ; 0 
		  0:09  614 ; 0 
		  0:10  615 ; 0 
		  0:10  616 ; 0 
		  0:10  621 ; 0 
		  0:10  622 ; 0 
		  0:10  623 ; 0 
		  0:10  624 ; 0 
		  0:10  625 ; 0 
		  0:10  626 ; 0 
		  0:10  627 ; 0 
		  0:10  628 ; 0 
		  0:10  629 ; 0 
		  0:10  630 ; 0 
		  0:10  631 ; 0 
		  0:10  632 ; 0 
		  0:10  641 ; 0 
		  0:10  642 ; 0 
		  0:10  643 ; 0 
		  0:10  644 ; 0 
		  0:10  645 ; 0 
		  0:10  646 ; 0 
		  0:11  647 ; 0 
		  0:11  648 ; 0 
		  0:11  649 ; 0 
		  0:11  650 ; 0 
		  0:11  651 ; 0 
		  0:11  652 ; 0 
		  0:11  653 ; 0 
		  0:11  654 ; 0 
		  0:11  655 ; 0 
		  0:11  656 ; 0 
		  0:11  661 ; 0 
		  0:11  662 ; 0 = CLASS AXIS END
		  0:11  663 ; 0 = SHOP START
		  0:11  664 ; 0 
		  0:11  665 ; 0 
		  0:11  666 ; 0 
		  0:11  667 ; 0 
		  0:11  668 ; 0 
		  0:11  669 ; 0 
		  0:11  670 ; 0 
		  0:12  671 ; 0 
		  0:12  672 ; 0 
		  0:12  673 ; 0 
		  0:12  674 ; 0 
		  0:12  675 ; 0 
		  0:12  676 ; 0 
		  0:12  677 ; 0 
		  0:12  678 ; 0 
		  0:12  679 ; 0 
		  0:12  680 ; 0 
		  0:12  681 ; 0 
		  0:12  682 ; 0 
		  0:12  683 ; 0 
		  0:12  684 ; 0 
		  0:12  685 ; 0 
		  0:12  686 ; 0 
		  0:12  687 ; 0 
		  0:12  688 ; 0 
		  0:12  689 ; 0 
		  0:12  690 ; 0 
		  0:13  691 ; 0 
		  0:13  692 ; 0 
		  0:13  693 ; 0 
		  0:13  694 ; 0 
		  0:13  695 ; 0 
		  0:13  696 ; 0 
		  0:13  697 ; 0 
		  0:13  698 ; 0 
		  0:13  2501 ; 0 
		  0:13  2502 ; 0 
		  0:13  2503 ; 0 
		  0:13  2504 ; 0 
		  0:13  2505 ; 0 
		  0:13  2506 ; 0 
		  0:13  2507 ; 0 
		  0:13  2508 ; 0 
		  0:13  2509 ; 0 
		  0:13  2510 ; 0 
		  0:13  2511 ; 0 
		  0:13  2512 ; 0 
		  0:14  2513 ; 0 
		  0:14  2521 ; 0 
		  0:14  2522 ; 0 
		  0:14  2523 ; 0 
		  0:14  2524 ; 0 
		  0:14  2525 ; 0 
		  0:14  2526 ; 0 
		  0:14  2527 ; 0 
		  0:14  2528 ; 0 
		  0:14  2529 ; 0 
		  0:14  2530 ; 0 
		  0:14  2541 ; 0 
		  0:14  2542 ; 0 
		  0:14  2543 ; 0 
		  0:14  2544 ; 0 
		  0:14  2545 ; 0 
		  0:14  2546 ; 0 
		  0:14  2561 ; 0 
		  0:14  2562 ; 0 
		  0:14  2563 ; 0 
		  0:15  2564 ; 0 
		  0:15  2581 ; 0 
		  0:15  2582 ; 0 
		  0:15  2583 ; 0 
		  0:15  2584 ; 0 
		  0:15  2585 ; 0 
		  0:15  2586 ; 0 
		  0:15  2587 ; 0 
		  0:15  2588 ; 0 
		  0:15  2589 ; 0 
		  0:15  2590 ; 0 
		  0:15  2601 ; 0 
		  0:15  2602 ; 0 
		  0:15  2603 ; 0 
		  0:15  2604 ; 0 
		  0:15  2605 ; 0 
		  0:15  2606 ; 0 
		  0:15  2607 ; 0 
		  0:15  2608 ; 0 
		  0:15  2609 ; 0 
		  0:16  2610 ; 0 
		  0:16  2611 ; 0 
		  0:16  2612 ; 0 
		  0:16  2613 ; 0 
		  0:16  2614 ; 0 
		  0:16  2615 ; 0 
		  0:16  2616 ; 0 
		  0:16  2621 ; 0 
		  0:16  2622 ; 0 
		  0:16  2623 ; 0 
		  0:16  2624 ; 0 
		  0:16  2625 ; 0 = SHOP END
  0:16  2626 ; 0
  0:16  2627 ; 0 
  0:16  2628 ; 0 
  0:16  2629 ; 0 
  0:16  2630 ; 0 
  0:16  2631 ; 0 
  0:16  2632 ; 0 
  0:16  2641 ; 0 
  0:17  2642 ; 0 
  0:17  2643 ; 0 
  0:17  2644 ; 0 
  0:17  2645 ; 0 
  0:17  2646 ; 0 
  0:17  2647 ; 0 
  0:17  2648 ; 0 
  0:17  2649 ; 0 
  0:17  2650 ; 0 
  0:17  2651 ; 0 
  0:17  2652 ; 0 
  0:17  2653 ; 0 
  0:17  2654 ; 0 
  0:17  2655 ; 0 
  0:17  2656 ; 0 
		  0:17  2661 ; 0 = CLASS ALLIES SETTINGS START
		  0:17  2662 ; 0 
		  0:17  2663 ; 0 
		  0:17  2664 ; 0 
		  0:17  2665 ; 0 
		  0:18  2666 ; 0 
		  0:18  2667 ; 0 
		  0:18  2668 ; 0 
		  0:18  2669 ; 0 
		  0:18  2670 ; 0 
		  0:18  2671 ; 0 
		  0:18  2672 ; 0 
		  0:18  2673 ; 0 
		  0:18  2674 ; 0 
		  0:18  2675 ; 0 
		  0:18  2676 ; 0 
		  0:18  2677 ; 0 
		  0:18  2678 ; 0 
		  0:18  2679 ; 0 
		  0:18  2680 ; 0 
		  0:18  2681 ; 0 
		  0:18  2682 ; 0 
		  0:18  2683 ; 0 
		  0:18  2684 ; 0 
		  0:18  2685 ; 0 = CLASS ALLIES SETTINGS END
  0:19  2686 ; 0
  0:19  2687 ; 0
  0:19  2688 ; 0 
  0:19  2689 ; 0 
  0:19  2690 ; 0 
  0:19  2691 ; 0 
  0:19  2692 ; 0 
  0:19  2693 ; 0 
  0:19  2694 ; 0 
  0:19  2695 ; 0 
  0:19  2696 ; 0 
  0:19  2697 ; 0 
  0:19  2698 ; 0 
		  0:19  3000 ; 9 = CLASS AXIS SETTINGS START
		  0:19  3001 ; 0 
		  0:19  3002 ; 9 
		  0:19  3003 ; 0 
		  0:19  3004 ; 0 
		  0:19  3005 ; 0 
		  0:19  3006 ; 0 
		  0:20  3007 ; 0 
		  0:20  3008 ; 0 
		  0:20  3009 ; 0 
		  0:20  3010 ; 769 
		  0:20  3011 ; 769
		  0:20  3012 ; 0 
		  0:20  3013 ; 0 
		  0:20  3014 ; 0 
		  0:20  3015 ; 0 
		  0:20  3016 ; 0 
		  0:20  3017 ; 0 
		  0:20  3018 ; 0 
		  0:20  3019 ; 0 
		  0:20  3020 ; 801 
		  0:20  3021 ; 0 
		  0:20  3022 ; 0 
		  0:20  3023 ; 0 
		  0:20  3024 ; 0 = CLASS AXIS SETTINGS END
  0:20  3025 ; 801 
  0:20  3026 ; 0 
  0:21  3027 ; 0 
  0:21  3028 ; 0 
  0:21  3029 ; 0 
  0:21  3030 ; 0 
  0:21  3031 ; 0 
  0:21  3032 ; 0 
  0:21  3033 ; 0 
  0:21  3034 ; 0 
  0:21  3035 ; 0 
  0:21  3036 ; 0 
  0:21  3037 ; 0 
  0:21  3038 ; 0 
  0:21  3039 ; 0 
  0:21  3040 ; 0 
  0:21  3041 ; 0 
  0:21  3042 ; 0 
  0:21  3043 ; 0 
  0:21  3044 ; 0 
  0:21  3045 ; 0 
  0:21  3046 ; 0 
  0:22  3047 ; 0 
  0:22  3048 ; 0 
  0:22  3049 ; 0 
  0:22  3050 ; 0 
  0:22  3051 ; 0 
  0:22  3052 ; 0 
  0:22  3053 ; 0 
  0:22  3054 ; 0 
  0:22  3055 ; 0 
  0:22  3056 ; 0 
  0:22  3057 ; 0 
  0:22  3058 ; 0 
  0:22  3059 ; 0 
  0:22  3060 ; 0 
  0:22  3061 ; 769 
  0:22  3062 ; 0 
  0:22  3063 ; 0 
  0:22  3064 ; 0 
  0:22  3065 ; 0 
  0:22  3066 ; 0 
  0:23  3067 ; 0 
  0:23  3068 ; 0 
  0:23  3069 ; 0 
  0:23  3070 ; 0 
  0:23  3071 ; 769 
  0:23  3072 ; 0 
  0:23  3073 ; 0 
  0:23  3074 ; 0 
  0:23  3075 ; 0 
  0:23  3076 ; 0 
  0:23  3077 ; 0 
  0:23  3078 ; 0 
  0:23  3079 ; 0 
  0:23  3080 ; 769 
  0:23  3081 ; 769 
  0:23  3082 ; 0 
  0:23  3083 ; 0 
  0:23  3084 ; 0 
  0:23  3085 ; 0 
  0:23  3086 ; 0 
  0:24  3087 ; 0 
  0:24  3088 ; 0 
  0:24  3089 ; 0 
  0:24  3090 ; 0 
  0:24  3091 ; 0 
  0:24  3092 ; 0 
  0:24  3093 ; 0 
  0:24  3094 ; 0 
  0:24  3095 ; 0 
  0:24  3096 ; 0 
  0:24  3097 ; 0 
  0:24  3098 ; 0 
  0:24  3099 ; 0 
  0:24  3100 ; 0 
  0:24  3101 ; 0 
  0:24  3102 ; 0 
  0:24  3103 ; 0 
  0:24  3104 ; 0 
  0:24  3105 ; 0 
  0:24  3106 ; 0 
  0:25  3107 ; 0 
  0:25  3108 ; 0 
  0:25  3109 ; 0 
  0:25  3110 ; 0 
  0:25  3111 ; 0 
  0:25  3112 ; 0 
  0:25  3113 ; 0 
  0:25  3114 ; 0 
  0:25  3115 ; 0 
  0:25  3116 ; 0 
  0:25  3117 ; 0 
  0:25  3118 ; 0 
  0:25  3119 ; 0 
  0:25  3120 ; 0 
  0:25  3121 ; 0 
  0:25  3122 ; 0 
  0:25  3123 ; 0 
  0:25  3124 ; 0 
  0:25  3125 ; 0 
  0:25  3126 ; 0 
  0:26  3127 ; 0 
  0:26  3128 ; 0 
  0:26  3129 ; 0 
  0:26  3130 ; 0 
  0:26  3131 ; 0 
  0:26  3132 ; 0 
  0:26  3133 ; 0 
  0:26  3134 ; 0 
  0:26  3135 ; 0 
  0:26  3136 ; 0 
  0:26  3137 ; 0 
  0:26  3138 ; 0 
  0:26  3139 ; 0 
  0:26  3140 ; 0 
  0:26  3141 ; 0 
  0:26  3142 ; 0 
  0:26  3143 ; 0 
  0:26  3144 ; 0 
  0:26  3145 ; 0 
  0:26  3146 ; 0 
  0:27  3147 ; 0 
  0:27  3148 ; 0 
  0:27  3149 ; 0 
  0:27  3150 ; 0 
  0:27  3151 ; 0 
  0:27  3152 ; 0 
  0:27  3153 ; 0 
  0:27  3154 ; 0 
  0:27  3155 ; 0 
  0:27  3156 ; 0 
  0:27  3157 ; 0 
  0:27  3158 ; 0 
  0:27  3159 ; 0 
  0:27  3160 ; 0 
  0:27  3161 ; 0 
  0:27  3162 ; 0 
  0:27  3163 ; 0 
  0:27  3164 ; 0 
  0:27  3165 ; 0 
  0:27  3166 ; 0 
  0:28  3167 ; 0 
  0:28  3168 ; 0 
  0:28  3169 ; 0 
  0:28  3170 ; 0 
  0:28  3171 ; 0 
  0:28  3172 ; 0 
  0:28  3173 ; 0 
  0:28  3174 ; 0 
  0:28  3175 ; 0 
  0:28  3176 ; 0 
  0:28  3177 ; 0 
  0:28  3178 ; 0 
  0:28  3179 ; 0 
  0:28  3180 ; 0 
  0:28  3181 ; 0 
  0:28  3182 ; 0 
  0:28  3183 ; 0 
  0:28  3184 ; 0 
  0:28  3185 ; 0 
  0:28  3186 ; 0 
  0:29  3187 ; 0 
  0:29  3188 ; 0 
  0:29  3189 ; 0 
  0:29  3190 ; 0 
  0:29  3191 ; 0 
  0:29  3192 ; 0 
  0:29  3193 ; 0 
  0:29  3194 ; 0 
  0:29  3195 ; 0 
  0:29  3196 ; 0 
  0:29  3197 ; 0 
  0:29  3198 ; 0 
  0:29  3199 ; 0 
  0:29  3200 ; 0 
  0:29  3201 ; 0 
  0:29  3202 ; 0 
  0:29  3203 ; 0 
  0:29  3204 ; 0 
  0:29  3205 ; 0 
  0:29  3206 ; 0 
  0:30  3207 ; 0 
  0:30  3208 ; 0 
  0:30  3209 ; 0 
  0:30  3210 ; 0 
  0:30  3211 ; 0 
  0:30  3212 ; 0 
  0:30  3213 ; 0 
  0:30  3214 ; 0 
  0:30  3215 ; 0 
  0:30  3216 ; 0 
  0:30  3217 ; 0 
  0:30  3218 ; 0 
  0:30  3219 ; 0 
  0:30  3220 ; 0 
  0:30  3221 ; 0 
  0:30  3222 ; 0 
  0:30  3223 ; 0 
  0:30  3224 ; 0 
  0:30  3225 ; 0 
  0:30  3226 ; 0 
  0:31  3227 ; 0 
  0:31  3228 ; 0 
  0:31  3229 ; 0 
  0:31  3230 ; 0 
  0:31  3231 ; 0 
  0:31  3232 ; 0 
  0:31  3233 ; 0 
  0:31  3234 ; 0 
  0:31  3235 ; 0 
  0:31  3236 ; 0 
  0:31  3237 ; 0 
  0:31  3238 ; 0 
  0:31  3239 ; 0 
  0:31  3240 ; 0 
  0:31  3241 ; 0 
  0:31  3242 ; 0 
  0:31  3243 ; 0 
  0:31  3244 ; 0 
  0:31  3245 ; 0 
  0:31  3246 ; 0 
  0:32  3247 ; 0 
  0:32  3248 ; 0 
  0:32  3249 ; 0 
  0:32  3250 ; 0 
  0:32  3251 ; 0 
  0:32  3252 ; 0 
  0:32  3253 ; 0 
  0:32  3254 ; 0 
  0:32  3255 ; 0 
  0:32  3256 ; 0 
  0:32  3257 ; 0 
  0:32  3258 ; 0 
  0:32  3259 ; 0 
  0:32  3260 ; 0 
  0:32  3261 ; 0 
  0:32  3262 ; 0 
  0:32  3263 ; 0 
  0:32  3264 ; 0 
  0:32  3265 ; 0 
  0:32  3266 ; 0 
  0:33  3267 ; 0 
  0:33  3268 ; 0 
  0:33  3269 ; 0 
  0:33  3270 ; 0 
  0:33  3271 ; 0 
  0:33  3272 ; 0 
  0:33  3273 ; 0 
  0:33  3274 ; 0 
  0:33  3275 ; 0 
  0:33  3276 ; 0 
  0:33  3277 ; 0 
  0:33  3278 ; 0 
  0:33  3279 ; 0 
  0:33  3280 ; 0 
  0:33  3281 ; 0 
  0:33  3282 ; 0 
  0:33  3283 ; 0 
  0:33  3284 ; 0 
  0:33  3285 ; 0 
  0:33  3286 ; 0 
  0:34  3287 ; 0 
  0:34  3288 ; 0 
  0:34  3289 ; 0 
  0:34  3290 ; 0 
  0:34  3291 ; 0 
  0:34  3292 ; 0 
  0:34  3293 ; 0 
  0:34  3294 ; 0 
  0:34  3295 ; 0 
  0:34  3296 ; 0 
  0:34  3297 ; 0 
		  0:34  3298 ; 0 = classIndex ALLIES
		  0:34  3299 ; 0 = classIndex AXIS
		  0:34  3300 ; 0
		  0:34  3301 ; 0 = quickBuy primaryWeapon
		  0:34  3302 ; 0 = quickBuy grenade
		  0:34  3303 ; 0 = quickBuy specialGrenade
		  0:34  3304 ; 0 = quickBuy equipment
		  0:34  3305 ; 0 = quickBuy gear
		  0:34  3306 ; 0 = verzia stats
  0:35  3307 ; 0 = 
		  0:35  3308 ; 0 = vsetky nahrane XP
  0:35  3309 ; 0 = 

  2327 = security, scripts\clients\_inventory.gsc
  2329 = security, scripts\clients\_cvar.gsc
  2354
  2355
  
slovom šesto sedemdesiatjeden! 671! :D
 
vycuc z classtable, challangetable, statstable, ... 
zoznam pouzitelnych statov!!!
za predpokladu odnatia pristupu k nim(classy, challange)!!!!!! 
  
stat 150 - 632 - ukladat len male hodnoty!!!!!!!!!!    0-255!!!
stat 2501 - 3149 - znesie extremne vysoke cisla...

vysoke cisla: 214 volnych statov
nizke cisla: 172 volnych statov

*/

/*
=============================== DVAR DUMP ========================================
      actionSlotsHide "0"
      activeAction ""
      ai_corpseCount "10"
      aim_accel_turnrate_debug "0"
      aim_accel_turnrate_enabled "1"
      aim_accel_turnrate_lerp "1200"
      aim_autoaim_debug "0"
      aim_autoaim_enabled "0"
      aim_autoaim_lerp "40"
      aim_autoaim_region_height "120"
      aim_autoaim_region_width "160"
      aim_automelee_debug "0"
      aim_automelee_enabled "1"
      aim_automelee_lerp "40"
      aim_automelee_range "128"
      aim_automelee_region_height "240"
      aim_automelee_region_width "320"
      aim_input_graph_debug "0"
      aim_input_graph_enabled "1"
      aim_input_graph_index "3"
      aim_lockon_debug "0"
      aim_lockon_deflection "0.05"
      aim_lockon_enabled "1"
      aim_lockon_region_height "90"
      aim_lockon_region_width "90"
      aim_lockon_strength "0.6"
      aim_scale_view_axis "1"
      aim_slowdown_debug "0"
      aim_slowdown_enabled "1"
      aim_slowdown_pitch_scale "0.4"
      aim_slowdown_pitch_scale_ads "0.5"
      aim_slowdown_region_height "90"
      aim_slowdown_region_width "90"
      aim_slowdown_yaw_scale "0.4"
      aim_slowdown_yaw_scale_ads "0.5"
      aim_target_sentient_radius "10"
      aim_turnrate_pitch "90"
      aim_turnrate_pitch_ads "55"
      aim_turnrate_yaw "260"
      aim_turnrate_yaw_ads "90"
      ammoCounterHide "0"
      authPort "20800"
      authServerName "cod4master.activision.com"
      bg_aimSpreadMoveSpeedThreshold "11"
      bg_bobAmplitudeDucked "0.0075 0.0075"
      bg_bobAmplitudeProne "0.02 0.005"
      bg_bobAmplitudeSprinting "0.02 0.014"
      bg_bobAmplitudeStanding "0.007 0.007"
      bg_bobMax "8"
      bg_fallDamageMaxHeight "300"
      bg_fallDamageMinHeight "128"
      bg_foliagesnd_fastinterval "500"
      bg_foliagesnd_maxspeed "180"
      bg_foliagesnd_minspeed "40"
      bg_foliagesnd_resetinterval "500"
      bg_foliagesnd_slowinterval "1500"
      bg_ladder_yawcap "100"
      bg_legYawTolerance "20"
      bg_maxGrenadeIndicatorSpeed "20"
      bg_prone_yawcap "85"
      bg_shock_lookControl "0"
      bg_shock_lookControl_fadeTime "0.001"
      bg_shock_lookControl_maxpitchspeed "0"
      bg_shock_lookControl_maxyawspeed "0"
      bg_shock_lookControl_mousesensitivityscale "0"
      bg_shock_movement "1"
      bg_shock_screenBlurBlendFadeTime "0.001"
      bg_shock_screenBlurBlendTime "0.001"
      bg_shock_screenFlashShotFadeTime "0"
      bg_shock_screenFlashWhiteFadeTime "0"
      bg_shock_screenType "blurred"
      bg_shock_sound "0"
      bg_shock_soundDryLevel "1"
      bg_shock_soundEnd "shellshock_end"
      bg_shock_soundEndAbort "shellshock_end_abort"
      bg_shock_soundFadeInTime "0.25"
      bg_shock_soundFadeOutTime "2.5"
      bg_shock_soundLoop "shellshock_loop"
      bg_shock_soundLoopEndDelay "-1.5"
      bg_shock_soundLoopFadeTime "2"
      bg_shock_soundLoopSilent "shellshock_loop_silent"
      bg_shock_soundModEndDelay "-0.75"
      bg_shock_soundRoomType "generic"
      bg_shock_soundWetLevel "0.5"
      bg_shock_viewKickFadeTime "0.001"
      bg_shock_viewKickPeriod "0.75"
      bg_shock_viewKickRadius "0"
      bg_shock_volume_ambient "0.2"
      bg_shock_volume_announcer "0.9"
      bg_shock_volume_auto "0.5"
      bg_shock_volume_auto2 "0.5"
      bg_shock_volume_auto2d "0.5"
      bg_shock_volume_autodog "0.9"
      bg_shock_volume_body "0.2"
      bg_shock_volume_body2d "0.2"
      bg_shock_volume_bulletimpact "0.5"
      bg_shock_volume_bulletwhizby "0.5"
      bg_shock_volume_effects1 "0.5"
      bg_shock_volume_effects2 "0.5"
      bg_shock_volume_element "0.5"
      bg_shock_volume_hurt "0.4"
      bg_shock_volume_item "0.2"
      bg_shock_volume_local "0.2"
      bg_shock_volume_local2 "0.2"
      bg_shock_volume_menu "1"
      bg_shock_volume_mission "0.9"
      bg_shock_volume_music "0.5"
      bg_shock_volume_musicnopause "0.5"
      bg_shock_volume_nonshock "0.5"
      bg_shock_volume_physics "0.5"
      bg_shock_volume_player1 "0.4"
      bg_shock_volume_player2 "0.4"
      bg_shock_volume_reload "0.2"
      bg_shock_volume_reload2d "0.2"
      bg_shock_volume_shellshock "1"
      bg_shock_volume_vehicle "0.1"
      bg_shock_volume_vehiclelimited "0.1"
      bg_shock_volume_voice "0.2"
      bg_shock_volume_weapon "0.5"
      bg_shock_volume_weapon2d "0.5"
      bg_swingSpeed "0.2"
      bg_viewKickMax "90"
      bg_viewKickMin "5"
      bg_viewKickRandom "0.4"
      bg_viewKickScale "0.2"
      bullet_penetrationEnabled "1"
      bullet_penetrationMinFxDist "30"
      cg_airstrikeKillCamCloseXYDist "24"
      cg_airstrikeKillCamCloseZDist "24"
      cg_airstrikeKillCamDist "200"
      cg_airstrikeKillCamFarBlur "2"
      cg_airstrikeKillCamFarBlurDist "300"
      cg_airstrikeKillCamFarBlurStart "100"
      cg_airstrikeKillCamFov "80"
      cg_airstrikeKillCamNearBlur "4"
      cg_airstrikeKillCamNearBlurEnd "100"
      cg_airstrikeKillCamNearBlurStart "0"
      cg_blood "1"
      cg_brass "1"
      cg_centertime "5"
      cg_chatHeight "8"
      cg_chatTime "12000"
      cg_connectionIconSize "0"
      cg_constantSizeHeadIcons "0"
      cg_crosshairAlpha "1"
      cg_crosshairAlphaMin "0.5"
      cg_crosshairDynamic "0"
      cg_crosshairEnemyColor "1"
      cg_cursorHints "1"
      cg_deadChatWithDead "0"
      cg_deadChatWithTeam "1"
      cg_deadHearAllLiving "0"
      cg_deadHearTeamLiving "1"
      cg_debug_overlay_viewport "0"
      cg_debugevents "0"
      cg_debugInfoCornerOffset "0 0"
      cg_debugposition "0"
      cg_descriptiveText "0"
      cg_draw2D "1"
      cg_drawBreathHint "1"
      cg_drawCrosshair "1"
      cg_drawCrosshairNames "1"
      cg_drawCrosshairNamesPosX "300"
      cg_drawCrosshairNamesPosY "180"
      cg_drawFPS "Simple"
      cg_drawFPSLabels "1"
      cg_drawFriendlyNames "1"
      cg_drawGun "1"
      cg_drawHealth "0"
      cg_drawLagometer "0"
      cg_drawMantleHint "1"
      cg_drawMaterial "Off"
      cg_drawpaused "1"
      cg_drawScriptUsage "0"
      cg_drawShellshock "1"
      cg_drawSnapshot "0"
      cg_drawSpectatorMessages "1"
      cg_drawTalk "ALL"
      cg_drawThroughWalls "0"
      cg_drawTurretCrosshair "1"
      cg_dumpAnims "-1"
      cg_enemyNameFadeIn "250"
      cg_enemyNameFadeOut "250"
      cg_errordecay "100"
      cg_everyoneHearsEveryone "0"
      cg_firstPersonTracerChance "0.5"
      cg_footsteps "1"
      cg_fov "80"
      cg_fovMin "10"
      cg_fovScale "1"
      cg_friendlyNameFadeIn "0"
      cg_friendlyNameFadeOut "1500"
      cg_gameBoldMessageWidth "390"
      cg_gameMessageWidth "455"
      cg_gun_move_f "0"
      cg_gun_move_minspeed "0"
      cg_gun_move_r "0"
      cg_gun_move_rate "0"
      cg_gun_move_u "0"
      cg_gun_ofs_f "0"
      cg_gun_ofs_r "0"
      cg_gun_ofs_u "0"
      cg_gun_x "0"
      cg_gun_y "0"
      cg_gun_z "0"
      cg_headIconMinScreenRadius "0.015"
      cg_heliKillCamDist "1000"
      cg_heliKillCamFarBlur "2"
      cg_heliKillCamFarBlurDist "300"
      cg_heliKillCamFarBlurStart "100"
      cg_heliKillCamFov "15"
      cg_heliKillCamNearBlur "4"
      cg_heliKillCamNearBlurEnd "100"
      cg_heliKillCamNearBlurStart "0"
      cg_heliKillCamZDist "50"
      cg_hintFadeTime "100"
      cg_hudChatIntermissionPosition "5 110"
      cg_hudChatPosition "5 200"
      cg_hudDamageIconHeight "64"
      cg_hudDamageIconInScope "0"
      cg_hudDamageIconOffset "128"
      cg_hudDamageIconTime "2000"
      cg_hudDamageIconWidth "128"
      cg_hudGrenadeIconEnabledFlash "0"
      cg_hudGrenadeIconHeight "25"
      cg_hudGrenadeIconInScope "0"
      cg_hudGrenadeIconMaxHeight "104"
      cg_hudGrenadeIconMaxRangeFlash "500"
      cg_hudGrenadeIconMaxRangeFrag "250"
      cg_hudGrenadeIconOffset "50"
      cg_hudGrenadeIconWidth "25"
      cg_hudGrenadePointerHeight "12"
      cg_hudGrenadePointerPivot "12 27"
      cg_hudGrenadePointerPulseFreq "1.7"
      cg_hudGrenadePointerPulseMax "1.85"
      cg_hudGrenadePointerPulseMin "0.3"
      cg_hudGrenadePointerWidth "25"
      cg_hudlegacysplitscreenscale "2"
      cg_hudMapBorderWidth "2"
      cg_hudMapFriendlyHeight "15"
      cg_hudMapFriendlyWidth "15"
      cg_hudMapPlayerHeight "20"
      cg_hudMapPlayerWidth "20"
      cg_hudMapRadarLineThickness "0.15"
      cg_hudObjectiveTextScale "0.3"
      cg_hudProneY "-160"
      cg_hudSayPosition "5 180"
      cg_hudsplitscreencompassscale "1.5"
      cg_hudsplitscreenstancescale "2"
      cg_hudStanceFlash "1 1 1 1"
      cg_hudStanceHintPrints "0"
      cg_hudVotePosition "5 220"
      cg_invalidCmdHintBlinkInterval "600"
      cg_invalidCmdHintDuration "1800"
      cg_laserEndOffset "0.5"
      cg_laserFlarePct "0.2"
      cg_laserForceOn "0"
      cg_laserLight "1"
      cg_laserLightBeginOffset "13"
      cg_laserLightBodyTweak "15"
      cg_laserLightEndOffset "-3"
      cg_laserLightRadius "3"
      cg_laserRadius "0.8"
      cg_laserRange "1500"
      cg_laserRangePlayer "1500"
      cg_mapLocationSelectionCursorSpeed "0.6"
      cg_marks_ents_player_only "0"
      cg_nopredict "0"
      cg_overheadIconSize "0.7"
      cg_overheadNamesFarDist "1024"
      cg_overheadNamesFarScale "0.6"
      cg_overheadNamesFont "2"
      cg_overheadNamesGlow "0 0 0 1"
      cg_overheadNamesMaxDist "10000"
      cg_overheadNamesNearDist "256"
      cg_overheadNamesSize "0.5"
      cg_overheadRankSize "0.5"
      cg_predictItems "1"
      cg_scoreboardBannerHeight "35"
      cg_scoreboardFont "0"
      cg_scoreboardHeaderFontScale "0.35"
      cg_scoreboardHeight "435"
      cg_scoreboardItemHeight "18"
      cg_scoreboardMyColor "1 0.8 0.4 1"
      cg_scoreboardPingGraph "0"
      cg_scoreboardPingHeight "0.7"
      cg_scoreboardPingText "1"
      cg_scoreboardPingWidth "0.036"
      cg_scoreboardRankFontScale "0.25"
      cg_scoreboardScrollStep "3"
      cg_scoreboardTextOffset "0.5"
      cg_scoreboardWidth "500"
      cg_ScoresPing_BgColor "0.25098 0.25098 0.25098 0.501961"
      cg_ScoresPing_HighColor "0.8 0 0 1"
      cg_ScoresPing_Interval "100"
      cg_ScoresPing_LowColor "0 0.74902 0 1"
      cg_ScoresPing_MaxBars "4"
      cg_ScoresPing_MedColor "0.8 0.8 0 1"
      cg_scriptIconSize "0"
      cg_showmiss "0"
      cg_sprintMeterDisabledColor "0.8 0.1 0.1 0.2"
      cg_sprintMeterEmptyColor "0.7 0.5 0.2 0.8"
      cg_sprintMeterFullColor "0.8 0.8 0.8 0.8"
      cg_subtitleMinTime "3"
      cg_subtitles "1"
      cg_subtitleWidthStandard "520"
      cg_subtitleWidthWidescreen "520"
      cg_teamChatsOnly "0"
      cg_thirdPerson "0"
      cg_thirdPersonAngle "0"
      cg_thirdPersonRange "120"
      cg_tracerchance "0.2"
      cg_tracerlength "160"
      cg_tracerScale "1"
      cg_tracerScaleDistRange "25000"
      cg_tracerScaleMinDist "5000"
      cg_tracerScrewDist "100"
      cg_tracerScrewRadius "0.5"
      cg_tracerSpeed "7500"
      cg_tracerwidth "4"
      cg_viewZSmoothingMax "16"
      cg_viewZSmoothingMin "1"
      cg_viewZSmoothingTime "0.1"
      cg_voiceIconSize "0"
      cg_weaponCycleDelay "500"
      cg_weaponHintsCoD1Style "1"
      cg_weaponleftbone "tag_weapon_left"
      cg_weaponrightbone "tag_weapon_right"
      cg_youInKillCamSize "6"
      cl_allowDownload "1"
      cl_analog_attack_threshold "0.8"
      cl_anglespeedkey "1.5"
      cl_anonymous "0"
      cl_avidemo "0"
      cl_bypassMouseInput "0"
      cl_connectionAttempts "10"
      cl_connectTimeout "200"
      cl_forceavidemo "0"
      cl_freelook "1"
      cl_freezeDemo "0"
      cl_hudDrawsBehindUI "1"
      cl_ingame "1"
      cl_maxpackets "100"
      cl_maxPing "800"
      cl_maxppf "5"
      cl_motdString ""
      cl_mouseAccel "0"
      cl_nodelta "0"
      cl_noprint "0"
      cl_packetdup "2"
      cl_paused "0"
      cl_pitchspeed "140"
      cl_punkbuster "1"
      cl_serverStatusResendTime "750"
      cl_showmouserate "0"
      cl_shownet "0"
      cl_shownuments "0"
      cl_showSend "0"
      cl_showServerCommands "0"
      cl_showTimeDelta "0"
      cl_stanceHoldTime "300"
      cl_talking "0"
      cl_timeout "40"
      cl_updateavailable "0"
      cl_updatefiles ""
      cl_updateoldversion ""
      cl_updateversion ""
      cl_voice "1"
      cl_wwwDownload "1"
      cl_yawspeed "140"
      clientSideEffects "1"
      com_animCheck "0"
      com_filter_output "0"
      com_introPlayed "1"
      com_maxfps "250"
      com_maxFrameTime "100"
      com_playerProfile "PetX"
      com_recommendedSet "1"
      com_statmon "0"
      com_timescale "1"
      compass "1"
      compassClampIcons "1"
      compassCoords "740 3590 400"
      compassECoordCutoff "37"
      compassEnemyFootstepEnabled "0"
      compassEnemyFootstepMaxRange "500"
      compassEnemyFootstepMaxZ "100"
      compassEnemyFootstepMinSpeed "140"
      compassFriendlyHeight "18.75"
      compassFriendlyWidth "18.75"
      compassMaxRange "2000"
      compassMinRadius "0.0001"
      compassMinRange "0.0001"
      compassObjectiveArrowHeight "20"
      compassObjectiveArrowOffset "2"
      compassObjectiveArrowRotateDist "5"
      compassObjectiveArrowWidth "20"
      compassObjectiveDetailDist "10"
      compassObjectiveDrawLines "1"
      compassObjectiveHeight "20"
      compassObjectiveIconHeight "16"
      compassObjectiveIconWidth "16"
      compassObjectiveMaxHeight "70"
      compassObjectiveMaxRange "2048"
      compassObjectiveMinAlpha "1"
      compassObjectiveMinDistRange "1"
      compassObjectiveMinHeight "-70"
      compassObjectiveNearbyDist "4"
      compassObjectiveNumRings "10"
      compassObjectiveRingSize "80"
      compassObjectiveRingTime "10000"
      compassObjectiveTextHeight "18"
      compassObjectiveTextScale "0.3"
      compassObjectiveWidth "20"
      compassPlayerHeight "18.75"
      compassPlayerWidth "18.75"
      compassRadarLineThickness "0.4"
      compassRadarPingFadeTime "4"
      compassRadarUpdateTime "4"
      compassRotation "1"
      compassSize "1"
      compassSoundPingFadeTime "2"
      compassTickertapeStretch "0.5"
      con_default_console_filter "*"
      con_errormessagetime "8"
      con_gameMsgWindow0FadeInTime "0.25"
      con_gameMsgWindow0FadeOutTime "0.5"
      con_gameMsgWindow0Filter "gamenotify obituary"
      con_gameMsgWindow0LineCount "4"
      con_gameMsgWindow0MsgTime "5"
      con_gameMsgWindow0ScrollTime "0.25"
      con_gameMsgWindow0SplitscreenScale "1.5"
      con_gameMsgWindow1FadeInTime "0.25"
      con_gameMsgWindow1FadeOutTime "0.01"
      con_gameMsgWindow1Filter "boldgame"
      con_gameMsgWindow1LineCount "5"
      con_gameMsgWindow1MsgTime "8"
      con_gameMsgWindow1ScrollTime "0.25"
      con_gameMsgWindow1SplitscreenScale "1.5"
      con_gameMsgWindow2FadeInTime "0.75"
      con_gameMsgWindow2FadeOutTime "0.5"
      con_gameMsgWindow2Filter "subtitle"
      con_gameMsgWindow2LineCount "7"
      con_gameMsgWindow2MsgTime "5"
      con_gameMsgWindow2ScrollTime "0.25"
      con_gameMsgWindow2SplitscreenScale "1.5"
      con_gameMsgWindow3FadeInTime "0.25"
      con_gameMsgWindow3FadeOutTime "0.5"
      con_gameMsgWindow3Filter ""
      con_gameMsgWindow3LineCount "5"
      con_gameMsgWindow3MsgTime "5"
      con_gameMsgWindow3ScrollTime "0.25"
      con_gameMsgWindow3SplitscreenScale "1.5"
      con_inputBoxColor "0.25 0.25 0.2 1"
      con_inputHintBoxColor "0.4 0.4 0.35 1"
      con_matchPrefixOnly "1"
      con_minicon "0"
      con_miniconlines "5"
      con_minicontime "4"
      con_outputBarColor "1 1 0.95 0.6"
      con_outputSliderColor "0.15 0.15 0.1 0.6"
      con_outputWindowColor "0.35 0.35 0.3 0.75"
      con_typewriterColorBase "1 1 1"
      con_typewriterColorGlowCheckpoint "0.6 0.5 0.6 1"
      con_typewriterColorGlowCompleted "0 0.3 0.8 1"
      con_typewriterColorGlowFailed "0.8 0 0 1"
      con_typewriterColorGlowUpdated "0 0.6 0.18 1"
      con_typewriterDecayDuration "700"
      con_typewriterDecayStartTime "6000"
      con_typewriterPrintSpeed "50"
      customclass1 ""
      customclass2 "Custom Slot 2"
      customclass3 "Custom Slot 3"
      customclass4 "Custom Slot 4"
      customclass5 "Custom Slot 5"
      debug_destructibles "0"
      dedicated "listen server"
      destructibles_enable_physics "1"
      developer "0"
      developer_script "0"
      didyouknow "@PLATFORM_DYK_MSG21"
      drew_notes "5"
      dynEnt_active "1"
      dynEnt_bulletForce "1000"
      dynEnt_explodeForce "12500"
      dynEnt_explodeMaxEnts "20"
      dynEnt_explodeMinForce "40"
      dynEnt_explodeSpinScale "3"
      dynEnt_explodeUpbias "0.5"
      dynEntPieces_angularVelocity "0 0 0"
      dynEntPieces_impactForce "1000"
      dynEntPieces_velocity "0 0 0"
      fixedtime "0"
      friction "5.5"
      fs_basegame ""
      fs_basepath "D:\Program Files (x86)\Activision\Call of Duty 4 - Modern Warfare"
      fs_cdpath ""
      fs_copyfiles "0"
      fs_debug "0"
      fs_game ""
      fs_homepath "D:\Program Files (x86)\Activision\Call of Duty 4 - Modern Warfare"
      fs_ignoreLocalized "0"
      fs_restrict "0"
      fs_usedevdir "0"
      fx_count "0"
      fx_cull_effect_spawn "0"
      fx_cull_elem_draw "1"
      fx_cull_elem_spawn "1"
      fx_debugBolt "0"
      fx_draw "1"
      fx_drawClouds "1"
      fx_enable "1"
      fx_freeze "0"
      fx_mark_profile "0"
      fx_marks "1"
      fx_marks_ents "1"
      fx_marks_smodels "1"
      fx_profile "0"
      fx_visMinTraceDist "80"
      g_allowvote "1"
      g_antilag "1"
      g_banIPs ""
      g_clonePlayerMaxVelocity "80"
      g_compassShowEnemies "0"
      g_deadChat "1"
      g_debugBullets "0"
      g_debugDamage "0"
      g_debugLocDamage "0"
      g_dropForwardSpeed "10"
      g_dropHorzSpeedRand "100"
      g_dropUpSpeedBase "10"
      g_dropUpSpeedRand "5"
      g_dumpAnims "-1"
      g_entinfo "off"
      g_fogColorReadOnly "0.584314 0.631373 0.552941 1"
      g_fogHalfDistReadOnly "20000"
      g_fogStartDistReadOnly "800"
      g_friendlyfireDist "256"
      g_friendlyNameDist "15000"
      g_gametype "war"
      g_gravity "800"
      g_inactivity "0"
      g_knockback "1000"
      g_listEntity "0"
      g_log "games_mp.log"
      g_logSync "1"
      g_mantleBlockTimeBuffer "500"
      g_maxDroppedWeapons "16"
      g_minGrenadeDamageSpeed "400"
      g_motd ""
      g_no_script_spam "0"
      g_oldVoting "1"
      g_password ""
      g_playerCollisionEjectSpeed "25"
      g_redCrosshairs "1"
      g_ScoresColor_Allies "0.6 0.639216 0.690196 0"
      g_ScoresColor_Axis "0.65098 0.568627 0.411765 0"
      g_ScoresColor_EnemyTeam "0.690196 0.0705882 0.0509804 1"
      g_ScoresColor_Free "0.760784 0.780392 0.101961 0"
      g_ScoresColor_MyTeam "0.25098 0.721569 0.25098 1"
      g_ScoresColor_Spectator "0.25098 0.25098 0.25098 0"
      g_smoothClients "1"
      g_speed "190"
      g_synchronousClients "0"
      g_TeamColor_Allies "0.6 0.639216 0.690196 0"
      g_TeamColor_Axis "0.65098 0.568627 0.411765 0"
      g_TeamColor_EnemyTeam "1 0.45098 0.501961 0"
      g_TeamColor_Free "0.74902 0.25098 0.25098 1"
      g_TeamColor_MyTeam "0.6 0.8 0.6 0"
      g_TeamColor_Spectator "0.25098 0.25098 0.25098 1"
      g_TeamIcon_Allies "faction_128_usmc"
      g_TeamIcon_Axis "faction_128_arab"
      g_TeamIcon_Free ""
      g_TeamIcon_Spectator ""
      g_TeamName_Allies "MPUI_MARINES_SHORT"
      g_TeamName_Axis "MPUI_OPFOR_SHORT"
      g_useGear "1"
      g_useholdspawndelay "500"
      g_useholdtime "0"
      g_voiceChatTalkingDuration "500"
      g_voteAbstainWeight "0.5"
      gamedate "Jun 18 2008"
      gamename "Call of Duty 4"
      heli_barrelMaxVelocity "1250"
      heli_barrelRotation "70"
      heli_barrelSlowdown "360"
      hiDef "1"
      hud_deathQuoteFadeTime "1000"
      hud_enable "1"
      hud_fade_ammodisplay "1.7"
      hud_fade_compass "0"
      hud_fade_healthbar "0"
      hud_fade_offhand "1.7"
      hud_fade_sprint "1.7"
      hud_fade_stance "0"
      hud_fadeout_speed "0.1"
      hud_flash_period_offhand "0.5"
      hud_flash_time_offhand "2"
      hud_health_pulserate_critical "0.5"
      hud_health_pulserate_injured "1"
      hud_health_startpulse_critical "0.33"
      hud_health_startpulse_injured "1"
      hud_healthOverlay_phaseEnd_pulseDuration "700"
      hud_healthOverlay_phaseEnd_toAlpha "0"
      hud_healthOverlay_phaseOne_pulseDuration "150"
      hud_healthOverlay_phaseThree_pulseDuration "400"
      hud_healthOverlay_phaseThree_toAlphaMultiplier "0.6"
      hud_healthOverlay_phaseTwo_pulseDuration "320"
      hud_healthOverlay_phaseTwo_toAlphaMultiplier "0.7"
      hud_healthOverlay_pulseStart "0.55"
      hud_healthOverlay_regenPauseTime "8000"
      hudElemPausedBrightness "0.4"
      in_mouse "1"
      inertiaAngle "0"
      inertiaDebug "0"
      inertiaMax "50"
      jump_height "39"
      jump_ladderPushVel "128"
      jump_slowdownEnable "1"
      jump_spreadAdd "64"
      jump_stepSize "18"
      koth_autodestroytime "60"
      koth_capturetime "20"
      koth_delayPlayer "0"
      koth_destroytime "10"
      koth_kothmode "0"
      koth_spawnDelay "60"
      koth_spawntime "0"
      loc_forceEnglish "0"
      loc_language "0"
      loc_translate "1"
      loc_warnings "0"
      loc_warningsAsErrors "0"
      logfile "2"
      lowAmmoWarningColor1 "0.901961 0.901961 0.901961 0.8"
      lowAmmoWarningColor2 "1 1 1 1"
      lowAmmoWarningNoAmmoColor1 "0.8 0 0 0.8"
      lowAmmoWarningNoAmmoColor2 "1 0 0 1"
      lowAmmoWarningNoReloadColor1 "0.701961 0.701961 0 0.8"
      lowAmmoWarningNoReloadColor2 "1 1 0 1"
      lowAmmoWarningPulseFreq "1.7"
      lowAmmoWarningPulseMax "1.5"
      lowAmmoWarningPulseMin "0"
      m_filter "0"
      m_forward "0.25"
      m_pitch "0.022"
      m_side "0.25"
      m_yaw "0.022"
      mantle_check_angle "60"
      mantle_check_radius "0.1"
      mantle_check_range "20"
      mantle_debug "0"
      mantle_enable "1"
      mantle_view_yawcap "60"
      mapname "mp_convoy"
      masterPort "20810"
      masterServerName "cod4master.activision.com"
      melee_debug "0"
      missileDebugAttractors "0"
      missileDebugDraw "0"
      missileDebugText "0"
      missileHellfireMaxSlope "0.5"
      missileHellfireUpAccel "1000"
      missileJavAccelClimb "300"
      missileJavAccelDescend "3000"
      missileJavClimbAngleDirect "85"
      missileJavClimbAngleTop "50"
      missileJavClimbCeilingDirect "0"
      missileJavClimbCeilingTop "3000"
      missileJavClimbHeightDirect "10000"
      missileJavClimbHeightTop "15000"
      missileJavClimbToOwner "700"
      missileJavSpeedLimitClimb "1000"
      missileJavSpeedLimitDescend "6000"
      missileJavTurnDecel "0.05"
      missileJavTurnRateDirect "60"
      missileJavTurnRateTop "100"
      missileWaterMaxDepth "60"
      monkeytoy "0"
      motd ""
      msg_dumpEnts "0"
      msg_hudelemspew "0"
      msg_printEntityNums "0"
      name "<3 <3 <3"
      net_ip "localhost"
      net_lanauthorize "0"
      net_noipx "0"
      net_noudp "0"
      net_port "28960"
      net_profile "0"
      net_showprofile "0"
      net_socksEnabled "0"
      net_socksPassword ""
      net_socksPort "1080"
      net_socksServer ""
      net_socksUsername ""
      nextdemo ""
      nextmap "map_restart"
      nightVisionDisableEffects "0"
      nightVisionFadeInOutTime "0.1"
      nightVisionPowerOnTime "0.3"
      onlinegame "1"
      overrideNVGModelWithKnife "0"
      packetDebug "0"
      password ""
      perk_armorVest "75"
      perk_bulletDamage "40"
      perk_bulletPenetrationMultiplier "2"
      perk_explosiveDamage "25"
      perk_extraBreath "5"
      perk_grenadeDeath "frag_grenade_short_mp"
      perk_parabolicAngle "180"
      perk_parabolicIcon "specialty_parabolic"
      perk_parabolicRadius "400"
      perk_sprintMultiplier "2"
      perk_weapRateMultiplier "0.75"
      perk_weapReloadMultiplier "0.5"
      perk_weapSpreadMultiplier "0.65"
      phys_autoDisableAngular "1"
      phys_autoDisableLinear "20"
      phys_autoDisableTime "0.9"
      phys_bulletSpinScale "3"
      phys_bulletUpBias "0.5"
      phys_cfm "0.0001"
      phys_collUseEntities "0"
      phys_contact_cfm "1e-005"
      phys_contact_cfm_ragdoll "0.001"
      phys_contact_erp "0.8"
      phys_contact_erp_ragdoll "0.3"
      phys_csl "1"
      phys_dragAngular "0.5"
      phys_dragLinear "0.03"
      phys_drawAwake "0"
      phys_drawAwakeTooLong "0"
      phys_drawCollisionObj "0"
      phys_drawCollisionWorld "0"
      phys_drawcontacts "0"
      phys_drawDebugInfo "0"
      phys_dumpcontacts "0"
      phys_erp "0.8"
      phys_frictionScale "1"
      phys_gravity "-800"
      phys_gravityChangeWakeupRadius "120"
      phys_interBodyCollision "0"
      phys_jitterMaxMass "200"
      phys_joint_cfm "0.0001"
      phys_joint_stop_cfm "0.0001"
      phys_joint_stop_erp "0.8"
      phys_mcv "20"
      phys_mcv_ragdoll "1000"
      phys_minImpactMomentum "250"
      phys_narrowObjMaxLength "4"
      phys_noIslands "0"
      phys_qsi "15"
      phys_reorderConst "1"
      phys_visibleTris "0"
      pickupPrints "0"
      player_adsExitDelay "0"
      player_backSpeedScale "0.7"
      player_breath_fire_delay "0"
      player_breath_gasp_lerp "6"
      player_breath_gasp_scale "4.5"
      player_breath_gasp_time "1"
      player_breath_hold_lerp "1"
      player_breath_hold_time "4.5"
      player_breath_snd_delay "1"
      player_breath_snd_lerp "2"
      player_burstFireCooldown "0.2"
      player_debugHealth "0"
      player_dmgtimer_flinchTime "500"
      player_dmgtimer_maxTime "750"
      player_dmgtimer_minScale "0"
      player_dmgtimer_stumbleTime "500"
      player_dmgtimer_timePerPoint "100"
      player_footstepsThreshhold "0"
      player_lean_rotate_crouch_left "0.8"
      player_lean_rotate_crouch_right "0.3"
      player_lean_rotate_left "0.8"
      player_lean_rotate_right "0.4"
      player_lean_shift_crouch_left "4"
      player_lean_shift_crouch_right "15"
      player_lean_shift_left "5"
      player_lean_shift_right "9"
      player_meleeChargeFriction "1200"
      player_meleeHeight "10"
      player_meleeRange "64"
      player_meleeWidth "10"
      player_MGUseRadius "128"
      player_move_factor_on_torso "0"
      player_moveThreshhold "10"
      player_scopeExitOnDamage "0"
      player_spectateSpeedScale "1"
      player_sprintCameraBob "0.5"
      player_sprintForwardMinimum "105"
      player_sprintMinTime "1"
      player_sprintRechargePause "0"
      player_sprintSpeedScale "1.5"
      player_sprintStrafeSpeedScale "0.667"
      player_sprintTime "4"
      player_strafeAnimCosAngle "0.5"
      player_strafeSpeedScale "0.8"
      player_summary_challenge "0"
      player_summary_match "0"
      player_summary_misc "0"
      player_summary_score "0"
      player_summary_xp "0"
      player_sustainAmmo "0"
      player_throwbackInnerRadius "90"
      player_throwbackOuterRadius "160"
      player_turnAnims "0"
      player_unlock_page "0"
      player_unlockattachment0a ""
      player_unlockattachment0b ""
      player_unlockattachment1a ""
      player_unlockattachment1b ""
      player_unlockattachment2a ""
      player_unlockattachment2b ""
      player_unlockattachments "0"
      player_unlockcamo0a ""
      player_unlockcamo0b ""
      player_unlockcamo1a ""
      player_unlockcamo1b ""
      player_unlockcamo2a ""
      player_unlockcamo2b ""
      player_unlockcamos "0"
      player_unlockchallenge0 ""
      player_unlockchallenge1 ""
      player_unlockchallenge2 ""
      player_unlockchallenges "0"
      player_unlockfeature0 ""
      player_unlockfeature1 ""
      player_unlockfeature2 ""
      player_unlockfeatures "0"
      player_unlockperk0 ""
      player_unlockperk1 ""
      player_unlockperk2 ""
      player_unlockperks "0"
      player_unlockweapon0 ""
      player_unlockweapon1 ""
      player_unlockweapon2 ""
      player_unlockweapons "0"
      player_view_pitch_down "85"
      player_view_pitch_up "85"
      protocol "6"
      r_aaAlpha "off"
      r_aaSamples "1"
      r_altModelLightingUpdate "0"
      r_aspectRatio "auto"
      r_autopriority "0"
      r_blur "0"
      r_brightness "0"
      r_cacheModelLighting "1"
      r_cacheSModelLighting "1"
      r_clear "dev-only blink"
      r_clearColor "0 0 0 0"
      r_clearColor2 "0 0 0 0"
      r_colorMap "Unchanged"
      r_contrast "1"
      r_customMode ""
      r_debugLineWidth "1"
      r_debugShader "none"
      r_depthPrepass "0"
      r_desaturation "1"
      r_detail "1"
      r_diffuseColorScale "1"
      r_displayRefresh "75 Hz"
      r_distortion "1"
      r_dlightLimit "4"
      r_dof_bias "0.5"
      r_dof_enable "1"
      r_dof_farBlur "1.8"
      r_dof_farEnd "7000"
      r_dof_farStart "1000"
      r_dof_nearBlur "6"
      r_dof_nearEnd "60"
      r_dof_nearStart "10"
      r_dof_tweak "0"
      r_dof_viewModelEnd "8"
      r_dof_viewModelStart "2"
      r_drawDecals "1"
      r_drawSun "0"
      r_drawWater "1"
      r_envMapExponent "5"
      r_envMapMaxIntensity "0.5"
      r_envMapMinIntensity "0.2"
      r_envMapOverride "0"
      r_envMapSpecular "1"
      r_envMapSunIntensity "2"
      r_fastSkin "0"
      r_filmTweakBrightness "0"
      r_filmTweakContrast "1.4"
      r_filmTweakDarkTint "0.7 0.85 1"
      r_filmTweakDesaturation "0.2"
      r_filmTweakEnable "0"
      r_filmTweakInvert "0"
      r_filmTweakLightTint "1.1 1.05 0.85"
      r_filmUseTweaks "0"
      r_floatz "1"
      r_fog "1"
      r_forceLod "none"
      r_fullbright "0"
      r_fullscreen "1"
      r_gamma "1.04762"
      r_glow "1"
      r_glow_allowed "1"
      r_glow_allowed_script_forced "0"
      r_glowTweakBloomCutoff "0.5"
      r_glowTweakBloomDesaturation "0"
      r_glowTweakBloomIntensity0 "1"
      r_glowTweakEnable "0"
      r_glowTweakRadius0 "5"
      r_glowUseTweaks "0"
      r_gpuSync "adaptive"
      r_highLodDist "-1"
      r_ignore "0"
      r_ignorehwgamma "0"
      r_inGameVideo "1"
      r_lightMap "Unchanged"
      r_lightTweakAmbient "0.3"
      r_lightTweakAmbientColor "0.74902 0.839216 1 1"
      r_lightTweakDiffuseFraction "0.1"
      r_lightTweakSunColor "1 0.894118 0.623529 1"
      r_lightTweakSunDiffuseColor "0.74902 0.839216 1 1"
      r_lightTweakSunDirection "-30 -340 0"
      r_lightTweakSunLight "1.6"
      r_loadForRenderer "1"
      r_lockPvs "0"
      r_lodBiasRigid "0"
      r_lodBiasSkinned "0"
      r_lodScaleRigid "1"
      r_lodScaleSkinned "1"
      r_logFile "0"
      r_lowestLodDist "-1"
      r_lowLodDist "-1"
      r_mediumLodDist "-1"
      r_mode "1680x1050"
      r_modelVertColor "1"
      r_monitor "0"
      r_multiGpu "0"
      r_norefresh "0"
      r_normal "1"
      r_normalMap "Unchanged"
      r_outdoor "1"
      r_outdoorAwayBias "32"
      r_outdoorDownBias "0"
      r_outdoorFeather "8"
      r_picmip "0"
      r_picmip_bump "0"
      r_picmip_manual "0"
      r_picmip_spec "0"
      r_picmip_water "0"
      r_polygonOffsetBias "-1"
      r_polygonOffsetScale "-1"
      r_portalBevels "0.7"
      r_portalBevelsOnly "0"
      r_portalMinClipArea "0.02"
      r_portalMinRecurseDepth "2"
      r_portalWalkLimit "0"
      r_preloadShaders "0"
      r_pretess "1"
      r_reflectionProbeGenerate "0"
      r_reflectionProbeGenerateExit "0"
      r_reflectionProbeRegenerateAll "0"
      r_rendererInUse "Shader model 3.0"
      r_rendererPreference "Default"
      r_resampleScene "1"
      r_scaleViewport "1"
      r_showFbColorDebug "None"
      r_showFloatZDebug "0"
      r_showLightGrid "0"
      r_showMissingLightGrid "0"
      r_showPixelCost "off"
      r_showPortals "0"
      r_singleCell "0"
      r_skinCache "1"
      r_skipPvs "0"
      r_smc_enable "1"
      r_smp_backend "1"
      r_smp_worker "1"
      r_smp_worker_thread0 "1"
      r_smp_worker_thread1 "1"
      r_specular "1"
      r_specularColorScale "1"
      r_specularMap "Unchanged"
      r_spotLightBrightness "14"
      r_spotLightEndRadius "196"
      r_spotLightEntityShadows "1"
      r_spotLightFovInnerFraction "0.7"
      r_spotLightShadows "1"
      r_spotLightSModelShadows "1"
      r_spotLightStartRadius "36"
      r_sse_skinning "1"
      r_sun_from_dvars "0"
      r_sun_fx_position "0 0 0"
      r_sunblind_fadein "0.5"
      r_sunblind_fadeout "3"
      r_sunblind_max_angle "5"
      r_sunblind_max_darken "0.75"
      r_sunblind_min_angle "30"
      r_sunflare_fadein "1"
      r_sunflare_fadeout "1"
      r_sunflare_max_alpha "1"
      r_sunflare_max_angle "2"
      r_sunflare_max_size "2500"
      r_sunflare_min_angle "45"
      r_sunflare_min_size "0"
      r_sunflare_shader "sun_flare"
      r_sunglare_fadein "0.5"
      r_sunglare_fadeout "3"
      r_sunglare_max_angle "5"
      r_sunglare_max_lighten "0.75"
      r_sunglare_min_angle "30"
      r_sunsprite_shader "sun"
      r_sunsprite_size "16"
      r_texFilterAnisoMax "4"
      r_texFilterAnisoMin "1"
      r_texFilterDisable "0"
      r_texFilterMipBias "0"
      r_texFilterMipMode "Unchanged"
      r_useLayeredMaterials "0"
      r_vc_makelog "0"
      r_vc_showlog "0"
      r_vsync "0"
      r_warningRepeatDelay "5"
      r_zfar "0"
      r_zFeather "0"
      r_znear "4"
      r_znear_depthhack "0.1"
      radius_damage_debug "0"
      ragdoll_baselerp_time "1000"
      ragdoll_bullet_force "500"
      ragdoll_bullet_upbias "0.5"
      ragdoll_debug "0"
      ragdoll_dump_anims "0"
      ragdoll_enable "1"
      ragdoll_explode_force "18000"
      ragdoll_explode_upbias "0.8"
      ragdoll_fps "20"
      ragdoll_jitter_scale "1"
      ragdoll_jointlerp_time "3000"
      ragdoll_max_life "4500"
      ragdoll_max_simulating "16"
      ragdoll_rotvel_scale "1"
      ragdoll_self_collision_scale "1.2"
      rate "25000"
      rcon_password ""
      sc_blur "2"
      sc_count "24"
      sc_debugCasterCount "24"
      sc_debugReceiverCount "24"
      sc_enable "0"
      sc_fadeRange "0.25"
      sc_length "400"
      sc_offscreenCasterLodBias "0"
      sc_offscreenCasterLodScale "20"
      sc_shadowInRate "2"
      sc_shadowOutRate "5"
      sc_showDebug "0"
      sc_showOverlay "0"
      sc_wantCount "12"
      sc_wantCountMargin "1"
      scr_allies "usmc"
      scr_art_tweak "0"
      scr_art_visionfile "mp_convoy"
      scr_axis "arab"
      scr_cinematic_autofocus "1"
      scr_ctf_numlives "0"
      scr_ctf_playerrespawndelay "0"
      scr_ctf_roundlimit "2"
      scr_ctf_roundswitch "1"
      scr_ctf_scorelimit "10"
      scr_ctf_timelimit "5"
      scr_ctf_waverespawndelay "15"
      scr_dm_numlives "0"
      scr_dm_playerrespawndelay "0"
      scr_dm_roundlimit "1"
      scr_dm_scorelimit "150"
      scr_dm_timelimit "10"
      scr_dm_waverespawndelay "0"
      scr_dof_enable "1"
      scr_dom_numlives "0"
      scr_dom_playerrespawndelay "0"
      scr_dom_roundlimit "1"
      scr_dom_scorelimit "200"
      scr_dom_timelimit "0"
      scr_dom_waverespawndelay "0"
      scr_drawfriend "0"
      scr_fog_disable "0"
      scr_game_allowkillcam "1"
      scr_game_deathpointloss "0"
      scr_game_forceuav "0"
      scr_game_graceperiod "0"
      scr_game_hardpoints "1"
      scr_game_matchstarttime "5"
      scr_game_onlyheadshots "0"
      scr_game_perks "1"
      scr_game_playerwaittime "15"
      scr_game_spectatetype "1"
      scr_game_suicidepointloss "0"
      scr_hardcore "0"
      scr_hardpoint_allowartillery "1"
      scr_hardpoint_allowhelicopter "1"
      scr_hardpoint_allowsupply "1"
      scr_hardpoint_allowuav "1"
      scr_heli_armor "500"
      scr_heli_armor_bulletdamage "0.3"
      scr_heli_attract_range "4096"
      scr_heli_attract_strength "1000"
      scr_heli_debug "0"
      scr_heli_dest_wait "2"
      scr_heli_hardpoint_interval "180"
      scr_heli_health_degrade "0"
      scr_heli_loopmax "1"
      scr_heli_maxhealth "1100"
      scr_heli_missile_engage_dist "2000"
      scr_heli_missile_friendlycare "256"
      scr_heli_missile_max "3"
      scr_heli_missile_regen_time "10"
      scr_heli_missile_rof "5"
      scr_heli_missile_target_cone "0.3"
      scr_heli_rage_missile "5"
      scr_heli_target_recognition "0.5"
      scr_heli_target_spawnprotection "5"
      scr_heli_targeting_delay "0.5"
      scr_heli_turret_engage_dist "1000"
      scr_heli_turret_spinup_delay "0.75"
      scr_heli_turretClipSize "40"
      scr_heli_turretReloadTime "1.5"
      scr_heli_visual_range "3500"
      scr_intermission_time "30"
      scr_koth_numlives "0"
      scr_koth_playerrespawndelay "0"
      scr_koth_roundlimit "1"
      scr_koth_roundswitch "1"
      scr_koth_scorelimit "250"
      scr_koth_timelimit "15"
      scr_koth_waverespawndelay "0"
      scr_mapsize "64"
      scr_motd ""
      scr_oldschool "0"
      scr_player_forcerespawn "1"
      scr_player_healthregentime "5"
      scr_player_maxhealth "100"
      scr_player_numlives "0"
      scr_player_respawndelay "0"
      scr_player_sprinttime "4"
      scr_player_suicidespawndelay "0"
      scr_RequiredMapAspectratio "1"
      scr_sab_bombtimer "30"
      scr_sab_defusetime "5"
      scr_sab_hotpotato "0"
      scr_sab_numlives "0"
      scr_sab_planttime "2.5"
      scr_sab_playerrespawndelay "7.5"
      scr_sab_roundlimit "0"
      scr_sab_roundswitch "1"
      scr_sab_scorelimit "1"
      scr_sab_timelimit "20"
      scr_sab_waverespawndelay "0"
      scr_sd_bombtimer "45"
      scr_sd_defusetime "5"
      scr_sd_multibomb "0"
      scr_sd_numlives "1"
      scr_sd_planttime "5"
      scr_sd_playerrespawndelay "0"
      scr_sd_roundlimit "0"
      scr_sd_roundswitch "3"
      scr_sd_scorelimit "4"
      scr_sd_timelimit "2.5"
      scr_sd_waverespawndelay "0"
      scr_show_unlock_wait "0.1"
      scr_team_fftype "0"
      scr_team_kickteamkillers "0"
      scr_team_respawntime "0"
      scr_team_teamkillpointloss "1"
      scr_team_teamkillspawndelay "20"
      scr_teambalance "0"
      scr_teamKillPunishCount "3"
      scr_war_numlives "0"
      scr_war_playerrespawndelay "0"
      scr_war_roundlimit "1"
      scr_war_scorelimit "750"
      scr_war_timelimit "10"
      scr_war_waverespawndelay "0"
      scr_weapon_allowc4 "1"
      scr_weapon_allowclaymores "1"
      scr_weapon_allowflash "1"
      scr_weapon_allowfrags "1"
      scr_weapon_allowmines "1"
      scr_weapon_allowrpgs "1"
      scr_weapon_allowsmoke "1"
      scr_xpscale "1"
      sensitivity "5"
      server1 ""
      server10 ""
      server11 ""
      server12 ""
      server13 ""
      server14 ""
      server15 ""
      server16 ""
      server2 ""
      server3 ""
      server4 ""
      server5 ""
      server6 ""
      server7 ""
      server8 ""
      server9 ""
      shortversion "1.7"
      showdrop "0"
      showpackets "0"
      sm_enable "0"
      sm_fastSunShadow "1"
      sm_lightScore_eyeProjectDist "64"
      sm_lightScore_spotProjectFrac "0.125"
      sm_maxLights "4"
      sm_polygonOffsetBias "0.5"
      sm_polygonOffsetScale "2"
      sm_qualitySpotShadow "1"
      sm_spotEnable "1"
      sm_spotShadowFadeTime "1"
      sm_strictCull "1"
      sm_sunEnable "1"
      sm_sunSampleSizeNear "0.25"
      sm_sunShadowCenter "0 0 0"
      sm_sunShadowScale "1"
      snaps "30"
      snd_cinematicVolumeScale "0.85"
      snd_draw3D "Off"
      snd_drawInfo "None"
      snd_enable2D "1"
      snd_enable3D "1"
      snd_enableEq "1"
      snd_enableReverb "1"
      snd_enableStream "1"
      snd_errorOnMissing "0"
      snd_khz "44"
      snd_levelFadeTime "250"
      snd_outputConfiguration "Windows default"
      snd_slaveFadeTime "500"
      snd_touchStreamFilesOnLoad "0"
      snd_volume "0.338776"
      stat_version "10"
      stopspeed "100"
      sv_allowAnonymous "0"
      sv_allowDownload "1"
      sv_allowedClan1 ""
      sv_allowedClan2 ""
      sv_botsPressAttackBtn "1"
      sv_cheats "0"
      sv_clientArchive "1"
      sv_clientSideBullets "1"
      sv_connectTimeout "45"
      sv_debugRate "0"
      sv_debugReliableCmds "0"
      sv_disableClientConsole "0"
      sv_FFCheckSums ""
      sv_FFNames ""
      sv_floodprotect "4"
      sv_fps "20"
      sv_hostname "CoD4Host"
      sv_iwdNames "iw_13 iw_12 iw_11 iw_10 iw_09 iw_08 iw_07 iw_06 iw_05 iw_04 iw_03 iw_02 iw_01 iw_00"
      sv_iwds "2115322797 1043426064 -292863836 173489706 -1846635013 -1079795827 -1041447890 -715502781 489843315 499941093 309900900 -165391090 648005745 -1190209610 "
      sv_keywords ""
      sv_kickBanTime "300"
      sv_mapname ""
      sv_mapRotation "map mp_backlot map mp_bloc map mp_bog map mp_cargoship map mp_citystreets map mp_convoy map mp_countdown map mp_crash map mp_crossfire map mp_farm map mp_overgrown map mp_pipeline map mp_showdown map mp_strike map mp_vacant"
      sv_mapRotationCurrent ""
      sv_maxclients "24"
      sv_maxPing "0"
      sv_maxRate "5000"
      sv_minPing "0"
      sv_packet_info "0"
      sv_padPackets "0"
      sv_paused "0"
      sv_privateClients "0"
      sv_privatePassword ""
      sv_punkbuster "1"
      sv_pure "1"
      sv_reconnectlimit "3"
      sv_referencedFFCheckSums "89196 39166328 13517381 259"
      sv_referencedFFNames "code_post_gfx_mp mp_convoy common_mp mp_convoy_load"
      sv_referencedIwdNames "main/iw_00 main/iw_04 main/iw_01 main/iw_06 main/iw_02 main/iw_03 main/iw_13 main/iw_12 main/iw_11 main/iw_05"
      sv_referencedIwds "-1190209610 499941093 648005745 -715502781 -165391090 309900900 2115322797 1043426064 -292863836 489843315 "
      sv_running "1"
      sv_serverid "16"
      sv_showAverageBPS "0"
      sv_showCommands "0"
      sv_timeout "240"
      sv_voice "0"
      sv_voiceQuality "3"
      sv_wwwBaseURL ""
      sv_wwwDlDisconnected "0"
      sv_wwwDownload "0"
      sv_zombietime "2"
      sys_configSum "4379996"
      sys_configureGHz "10.4183"
      sys_cpuGHz "2.81247"
      sys_cpuName "AMD Phenom(tm) II X4 925 Processor"
      sys_gpu "ATI Radeon HD 5700 Series"
      sys_lockThreads "none"
      sys_smp_allowed "1"
      sys_SSE "1"
      sys_sysMB "1024"
      timescale "1"
      ui_3dwaypointtext "1"
      ui_allow_classchange "0"
      ui_allow_controlschange "1"
      ui_allow_teamchange "0"
      ui_allowvote "1"
      ui_bigFont "0.4"
      ui_bomb_timer "0"
      ui_borderLowLightScale "0.35"
      ui_browserFriendlyfire "-1"
      ui_browserHardcore "-1"
      ui_browserKillcam "-1"
      ui_browserMod "0"
      ui_browserOldSchool "-1"
      ui_browserShowDedicated "0"
      ui_browserShowEmpty "1"
      ui_browserShowFull "1"
      ui_browserShowPassword "-1"
      ui_browserShowPunkBuster "-1"
      ui_browserShowPure "1"
      ui_buildLocation "-60 460"
      ui_buildSize "0.3"
      ui_cinematicsTimestamp "0"
      ui_connectScreenTextGlowColor "0.3 0.6 0.3 1"
      ui_currentMap "0"
      ui_currentNetMap "0"
      ui_customClassName ""
      ui_customModeEditName ""
      ui_customModeName ""
      ui_deathicontext "1"
      ui_dedicated "0"
      ui_drawCrosshair "0"
      ui_extraBigFont "0.55"
      ui_friendlyfire "0"
      ui_gametype "0"
      ui_hint_text "@MP_NULL"
      ui_hostname "CoD4Host"
      ui_hud_hardcore "0"
      ui_hud_obituaries "1"
      ui_hud_showobjicons "1"
      ui_joinGametype "1"
      ui_lobbypopup ""
      ui_mapname "mp_backlot"
      ui_maxclients "32"
      ui_motd ""
      ui_mousePitch "0"
      ui_multiplayer "1"
      ui_netGametype "4"
      ui_netGametypeName "war"
      ui_netSource "2"
      ui_playerProfileAlreadyChosen "1"
      ui_playerProfileCount "2"
      ui_playerProfileNameNew ""
      ui_playerProfileSelected "PetX"
      ui_score_bar "0"
      ui_scorelimit "750"
      ui_separator_show "1"
      ui_serverStatusTimeOut "7000"
      ui_showEndOfGame "0"
      ui_showList "0"
      ui_showmap "1"
      ui_showMenuOnly ""
      ui_smallFont "0.25"
      ui_timelimit "10"
      ui_uav_allies "0"
      ui_uav_axis "0"
      ui_uav_client "0"
      ui_version_show "1"
      ui_xpText "1"
      uiscript_debug "0"
      useFastFile "1"
      vehDebugClient "0"
      vehDebugServer "0"
      vehDriverViewDist "300"
      vehDriverViewFocusRange "50"
      vehDriverViewHeightMax "50"
      vehDriverViewHeightMin "-15"
      vehHelicopterDecelerationFwd "0.5"
      vehHelicopterDecelerationSide "1"
      vehHelicopterHeadSwayDontSwayTheTurret "1"
      vehHelicopterHoverSpeedThreshold "400"
      vehHelicopterInvertUpDown "0"
      vehHelicopterJitterJerkyness "0.3"
      vehHelicopterLookaheadTime "1"
      vehHelicopterMaxAccel "45"
      vehHelicopterMaxAccelVertical "30"
      vehHelicopterMaxPitch "35"
      vehHelicopterMaxRoll "35"
      vehHelicopterMaxSpeed "150"
      vehHelicopterMaxSpeedVertical "65"
      vehHelicopterMaxYawAccel "90"
      vehHelicopterMaxYawRate "120"
      vehHelicopterRightStickDeadzone "0.3"
      vehHelicopterScaleMovement "1"
      vehHelicopterSoftCollisions "0"
      vehHelicopterStrafeDeadzone "0.3"
      vehHelicopterTiltFromAcceleration "2"
      vehHelicopterTiltFromControllerAxes "0"
      vehHelicopterTiltFromDeceleration "2"
      vehHelicopterTiltFromFwdAndYaw "0"
      vehHelicopterTiltFromFwdAndYaw_VelAtMaxTilt "1"
      vehHelicopterTiltFromVelocity "1"
      vehHelicopterTiltMomentum "0.4"
      vehHelicopterTiltSpeed "1.2"
      vehHelicopterYawOnLeftStick "5"
      vehTestHorsepower "200"
      vehTestMaxMPH "40"
      vehTestWeight "5200"
      vehTextureScrollScale "0"
      version "CoD4 MP 1.7 build 568 nightly Wed Jun 18 2008 04:48:38PM win-x86"
      vid_xpos "3"
      vid_ypos "22"
      voice_deadChat "0"
      voice_global "0"
      voice_localEcho "0"
      waypointDebugDraw "0"
      waypointDistScaleRangeMax "3000"
      waypointDistScaleRangeMin "1000"
      waypointDistScaleSmallest "0.8"
      waypointIconHeight "36"
      waypointIconWidth "36"
      waypointOffscreenCornerRadius "105"
      waypointOffscreenDistanceThresholdAlpha "30"
      waypointOffscreenPadBottom "30"
      waypointOffscreenPadLeft "103"
      waypointOffscreenPadRight "0"
      waypointOffscreenPadTop "0"
      waypointOffscreenPointerDistance "20"
      waypointOffscreenPointerHeight "12"
      waypointOffscreenPointerWidth "25"
      waypointOffscreenRoundedCorners "1"
      waypointOffscreenScaleLength "500"
      waypointOffscreenScaleSmallest "1"
      waypointPlayerOffsetCrouch "56"
      waypointPlayerOffsetProne "30"
      waypointPlayerOffsetStand "74"
      waypointSplitscreenScale "1.8"
      waypointTweakY "-17"
      wideScreen "1"
      winvoice_mic_mute "1"
      winvoice_mic_reclevel "65535"
      winvoice_mic_scaler "1"
      winvoice_save_voice "0"

1448 total dvars
1448 dvar indexes
=============================== END DVAR DUMP =====================================
		
		Bones:
Bone 0: 'tag_origin'
Bone 1: 'j_mainroot'
Bone 2: 'pelvis'
Bone 3: 'tag_sync'
Bone 4: 'j_coatfront_le'
Bone 5: 'j_coatfront_ri'
Bone 6: 'j_coatrear_le'
Bone 7: 'j_coatrear_ri'
Bone 8: 'j_hip_le'
Bone 9: 'j_hip_ri'
Bone 10: 'torso_stabilizer'
Bone 11: 'j_spinelower'
Bone 12: 'back_low'
Bone 13: 'tag_stowed_hip_rear'
Bone 14: 'j_hiptwist_le'
Bone 15: 'j_hiptwist_ri'
Bone 16: 'j_knee_le'
Bone 17: 'j_knee_ri'
Bone 18: 'j_spineupper'
Bone 19: 'back_mid'
Bone 20: 'j_ankle_le'
Bone 21: 'j_ankle_ri'
Bone 22: 'j_knee_bulge_le'
Bone 23: 'j_knee_bulge_ri'
Bone 24: 'j_spine4'
Bone 25: 'j_ball_le'
Bone 26: 'j_ball_ri'
Bone 27: 'j_clavicle_le'
Bone 28: 'j_clavicle_ri'
Bone 29: 'j_neck'
Bone 30: 'neck'
Bone 31: 'j_shoulderraise_le'
Bone 32: 'j_shoulderraise_ri'
Bone 33: 'tag_bipod'
Bone 34: 'tag_inhand'
Bone 35: 'tag_stowed_back'
Bone 36: 'tag_weapon_chest'
Bone 37: 'j_head'
Bone 38: 'head'
Bone 39: 'j_shoulder_le'
Bone 40: 'j_shoulder_ri'
Bone 41: 'j_brow_le'
Bone 42: 'j_brow_ri'
Bone 43: 'j_cheek_le'
Bone 44: 'j_cheek_ri'
Bone 45: 'j_elbow_bulge_le'
Bone 46: 'j_elbow_bulge_ri'
Bone 47: 'j_elbow_le'
Bone 48: 'j_elbow_ri'
Bone 49: 'j_eye_lid_bot_le'
Bone 50: 'j_eye_lid_bot_ri'
Bone 51: 'j_eye_lid_top_le'
Bone 52: 'j_eye_lid_top_ri'
Bone 53: 'j_eyeball_le'
Bone 54: 'j_eyeball_ri'
Bone 55: 'j_head_end'
Bone 56: 'j_jaw'
Bone 57: 'j_levator_le'
Bone 58: 'j_levator_ri'
Bone 59: 'j_lip_top_le'
Bone 60: 'j_lip_top_ri'
Bone 61: 'j_mouth_le'
Bone 62: 'j_mouth_ri'
Bone 63: 'j_shouldertwist_le'
Bone 64: 'j_shouldertwist_ri'
Bone 65: 'tag_eye'
Bone 66: 'j_chin_skinroll'
Bone 67: 'j_helmet'
Bone 68: 'j_lip_bot_le'
Bone 69: 'j_lip_bot_ri'
Bone 70: 'j_wrist_le'
Bone 71: 'j_wrist_ri'
Bone 72: 'j_wristtwist_le'
Bone 73: 'j_wristtwist_ri'
Bone 74: 'tag_reflector_arm_le'
Bone 75: 'tag_reflector_arm_ri'
Bone 76: 'j_gun'
Bone 77: 'j_index_le_1'
Bone 78: 'j_index_ri_1'
Bone 79: 'j_mid_le_1'
Bone 80: 'j_mid_ri_1'
Bone 81: 'j_pinky_le_1'
Bone 82: 'j_pinky_ri_1'
Bone 83: 'j_ring_le_1'
Bone 84: 'j_ring_ri_1'
Bone 85: 'j_thumb_le_1'
Bone 86: 'j_thumb_ri_1'
Bone 87: 'tag_weapon_left'
Bone 88: 'tag_weapon_right'
Bone 89: 'j_index_le_2'
Bone 90: 'j_index_ri_2'
Bone 91: 'j_mid_le_2'
Bone 92: 'j_mid_ri_2'
Bone 93: 'j_pinky_le_2'
Bone 94: 'j_pinky_ri_2'
Bone 95: 'j_ring_le_2'
Bone 96: 'j_ring_ri_2'
Bone 97: 'j_thumb_le_2'
Bone 98: 'j_thumb_ri_2'
Bone 99: 'j_index_le_3'
Bone 100: 'j_index_ri_3'
Bone 101: 'j_mid_le_3'
Bone 102: 'j_mid_ri_3'
Bone 103: 'j_pinky_le_3'
Bone 104: 'j_pinky_ri_3'
Bone 105: 'j_ring_le_3'
Bone 106: 'j_ring_ri_3'
Bone 107: 'j_thumb_le_3'
Bone 108: 'j_thumb_ri_3'
*/