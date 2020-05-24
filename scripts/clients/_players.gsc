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
	level.SpawnPlayer = ::SpawnPlayer;
}

SpawnPlayer( origin, angles, secondaryWeapon, primaryWeapon, offHand, secondaryOffHand, bodyModel, headModel, viewModel, health, speed, knifeDamage, knifeRange, figureFunction, specialAbility, equipment, gear, perks )
{
	if( self.pers["team"] == "spectator" || IsAlive( self ) )
		return;

	self.voice = "british";
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	//self.archivetime = 0; already set
	self.psoffsettime = 0;
	self.statusicon = "";
	
	team = self.pers["team"];

	// CLEAR INVENTORY
	//self TakeAllWeapons();
	self scripts\class\_perks::TakeAllPerks();
	self scripts\clients\_inventory::TakeAllInventory();
	
	if( !IsDefined( origin ) ) 				origin = (0,0,0);
	if( !IsDefined( angles ) ) 				angles = (0,0,0);
	if( !IsDefined( secondaryWeapon ) )		secondaryWeapon = "";
	if( !IsDefined( primaryWeapon ) )		primaryWeapon = "";
	if( !IsDefined( offHand ) )				offHand = "";
	if( !IsDefined( secondaryOffHand ) )	secondaryOffHand = "";
	if( !IsDefined( bodyModel ) ) 			bodyModel = "";
	if( !IsDefined( headModel ) ) 			headModel = "";
	if( !IsDefined( viewModel ) ) 			viewModel = "";
	if( !IsDefined( health ) ) 				health = 100;
	if( !IsDefined( speed ) ) 				speed = 100;
	if( !IsDefined( knifeDamage ) ) 		knifeDamage = 100;
	if( !IsDefined( knifeRange ) ) 			knifeRange = 100;
	if( !IsDefined( figureFunction ) ) 		figureFunction = "";
	if( !IsDefined( specialAbility ) ) 		specialAbility = "";
	if( !IsDefined( equipment ) ) 			equipment = "";
	if( !IsDefined( gear ) ) 				gear = "";
	if( !IsDefined( perks ) ) 				perks = [];
	
	// ============================================================================================================================================================================================= //	
	// callbacks and modify
	self.SpawnPlayer = SpawnStruct();
	self.SpawnPlayer.origin 			= origin; // vector
	self.SpawnPlayer.angles 			= angles; // vector
	self.SpawnPlayer.secondaryWeapon 	= secondaryWeapon; // string( weaponFile )
	self.SpawnPlayer.primaryWeapon 		= primaryWeapon; // string( weaponFile )
	self.SpawnPlayer.offHand 			= offHand; // string( weaponFile )
	self.SpawnPlayer.secondaryOffHand 	= secondaryOffHand; // string( weaponFile )
	self.SpawnPlayer.bodyModel 			= bodyModel; // string( model )
	self.SpawnPlayer.headModel 			= headModel; // string( model )
	self.SpawnPlayer.viewModel 			= viewModel; // string( model )
	self.SpawnPlayer.health 			= health; // int( % )
	self.SpawnPlayer.speed 				= speed; // int( % )
	self.SpawnPlayer.knifeDamage 		= knifeDamage; // int( % )
	self.SpawnPlayer.knifeRange 		= knifeRange; // int( % )
	self.SpawnPlayer.figureFunction 	= figureFunction; // string
	self.SpawnPlayer.specialAbility 	= specialAbility; // string
	self.SpawnPlayer.equipment 			= equipment; // string
	self.SpawnPlayer.gear 				= gear; // string
	self.SpawnPlayer.perks 				= perks; // array[string]
	
	// spawn system here!
	self [[level.GT_SpawnPlayer]]();
	
	// class options here!
	self scripts\class\_spawn::ModifySpawnInfo();
	
	scripts\_events::RunCallback( level, "playerSpawned", 0, self );
	scripts\_events::RunCallback( self, "playerSpawned", 0 );

	//dev tools
	self scripts\clients\_dev::SpawnPlayer();
	
	// PERKS
	self scripts\class\_perks::GiveAllPerks( self.SpawnPlayer.perks );
	
	// ============================================================================================================================================================================================= //	
	
	// give weapons and other settings here!
	self Spawn( self.SpawnPlayer.origin, self.SpawnPlayer.angles );
	
	self.SpawnPlayer.health = GetPlayerHealth( team, self.SpawnPlayer.health );
	self.Health = self.SpawnPlayer.health;
	self.MaxHealth = self.SpawnPlayer.health;
	
	self SetModel( self.SpawnPlayer.bodyModel );
	self SetViewModel( self.SpawnPlayer.viewmodel );
	if( IsDefined( self.SpawnPlayer.headModel ) && self.SpawnPlayer.headModel != "" )
		self Attach( self.SpawnPlayer.headModel, "", true );
	
	self.SpawnPlayer.speed = GetPlayerSpeed( team, self.SpawnPlayer.speed );
	self SetMoveSpeedScale( self.SpawnPlayer.speed );
	
	minFallDmg = 1.28*self.SpawnPlayer.health;
	maxFallDmg = 3*self.SpawnPlayer.health;
	if( self.pers["team"] == "axis" )
	{
		minFallDmg = 0.16*self.SpawnPlayer.health;
		maxFallDmg = 0.375*self.SpawnPlayer.health;
	}
	
	self.SpawnPlayer.knifeDamage = GetPlayerKnifeDamage( team, self.SpawnPlayer.knifeDamage );
	self.SpawnPlayer.knifeRange = GetPlayerKnifeRange( team, self.SpawnPlayer.knifeRange );
	
	self SetClientDvars( "aim_automelee_range", self.SpawnPlayer.knifeRange, "bg_fallDamageMinHeight", minFallDmg, "bg_fallDamageMaxHeight", maxFallDmg );
	
	// EQUIPMENT & GEAR
	self scripts\shop\_equipment::GiveEquipment( self.SpawnPlayer.equipment );
	self scripts\shop\_gear::GiveGear( self.SpawnPlayer.gear );
	
	// WEAPONS
	self scripts\clients\_weapons::GiveSecondaryWeapon( self.SpawnPlayer.secondaryWeapon, false );
	
	if( self.SpawnPlayer.primaryWeapon != "" )
	{
		self scripts\clients\_weapons::GivePrimaryWeapon( self.SpawnPlayer.primaryWeapon, false );
		self SetSpawnWeapon( self.SpawnPlayer.primaryWeapon );
	}
	else
	{
		self SetSpawnWeapon( self.SpawnPlayer.secondaryWeapon );
	}
	
	self scripts\clients\_weapons::GiveGrenade( self.SpawnPlayer.offHand );
	self scripts\clients\_weapons::GiveSpecialGrenade( self.SpawnPlayer.secondaryOffHand );
	
	//self setClientDvar( "hud_bottom_bar", 1 );
	
	resetTimeout();

	// Stop shellshock and rumble
	self StopShellshock();
	self StopRumble( "damage_heavy" );

	if( level.gameState[self.pers["team"]] != "playing" )
	{
		self FreezeMove( true );
		self DisableWeapons();
	}

	// RESTORE INVENTORY FROM LAST ROUND
	self scripts\clients\_inventory::RestoreSavedInventory();
	
	waittillframeend;
	
	self notify( "spawned_player" );
	self PrintDebug( "spawned" );
	
	if( !IsDefined( level.firstSpawn ) )
		level.firstSpawn = true;
	
	// call callbacks
	scripts\_events::RunCallback( level, "onPlayerSpawned", 1, self );
	scripts\_events::RunCallback( self, "onPlayerSpawned", 1 );
	
	//dev tools
	self thread scripts\clients\_dev::OnSpawnPlayer();
	
	waittillframeend;
	
	self UpdateStatusIcon();
	self scripts\clients\_hud::SetLowerText();
	self scripts\clients\_hud::SetLowerTimer();
	self scripts\clients\_hud::UpdateTopProgressBar( 0 );
	self scripts\clients\_hud::SetHealthBar( 100 );
	self scripts\clients\_hud::UpdateBottomBar();
	self scripts\clients\_hud::HideShop();
	self SetClientDvar( "hud_bottom_bar", 1 );
	
	self.reallyAlive = true;
}

UpdateStatusIcon()
{
	if( ( isalive(self) && self.pers["team"] != "spectator" ) || self.pers["team"] == "spectator" )
	{
		if(self.showme == 1)
		{
			if ( self.b3level >= 120 )
				self.statusicon = "hud_status_dev";
			else if ( self.b3level >= 100 )
				self.statusicon = "hud_status_marshal2";
			else if ( self.b3level >= 80)
				self.statusicon = "hud_status_marshal3";
			else if ( self.b3level >= 60 )
				self.statusicon = "hud_status_marshal";
			else if ( self.b3level >= 40 )
				self.statusicon = "hud_status_marshal";
			else if ( self.b3level >= 10 )
				self.statusicon = "hud_status_vip2";
			else if ( self.b3level >= 6 )
				self.statusicon = "hud_status_sponzor";
			else if ( self.b3level >= 2 )
				self.statusicon = "hud_status_vip2";
			else
				self.statusicon = "";
		}
		else
			self.statusicon = "";
	}
	else if( !isalive(self) )
		self.statusicon = "hud_status_dead";
}

// získa reálnu hodnotu na základe údajov z classu
// classPercentage - integer v rozsahu 0 - 100
// team - allies/axis
// vráti hodnotu v rozsahu min - max na základe classPercentage
GetPlayerHealth( team, classPercentage )
{
	min = level.dvars["p_healthMin_"+team];
	max = level.dvars["p_healthMax_"+team];
	return int( min+((max-min)*(classPercentage/100)) );
}

GetPlayerSpeed( team, classPercentage )
{
	min = level.dvars["p_speedMin_"+team];
	max = level.dvars["p_speedMax_"+team];
	return (min+((max-min)*(classPercentage/100))) / 100;
}

GetPlayerKnifeDamage( team, classPercentage )
{
	if( team == "allies" )
		return level.dvars["p_knifeDamageAllies"];
	else
	{
		min = level.dvars["p_knifeDamageAxisMin"];
		max = level.dvars["p_knifeDamageAxisMax"];
		return int( min+((max-min)*(classPercentage/100)) );	
	}
}

GetPlayerKnifeRange( team, classPercentage )
{
	if( team == "allies" )
		return 128;
	else
		return int( 128 * (classPercentage/100) );
}