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

#include scripts\include\_event;

init()
{
	level.spectator = ::JoinSpectator;
	level.AutoAssign = ::AutoAssign;
	level.Allies = ::JoinAllies;
	level.Axis = ::JoinAxis;
	
	//AddCallback( level, "onPlayerKilled", ::OnDeath );
	level.GT_OnDeath = ::OnDeath;
}

JoinAllies()
{
	oldTeam = self.pers["team"];
	self.pers["team"] = "allies";

	if( IsAlive( self ) )
	{
		self.skipDeathLogic = true;
		self suicide();
		//return;
	}
	
	self.pers["team"] = "allies";
	self.team = "allies";
	self.sessionteam = "allies";
	
	self notify( "joined_team", self.team );
	
	scripts\_events::RunCallback( level, "changeTeam", 1, self, oldTeam, "allies" );
	scripts\_events::RunCallback( self, "changeTeam", 1, oldTeam, "allies" );
	
	/*if( !isDefined( self.pers["class"] ) || !isDefined( self.pers["class"]["allies"] ) )
	{
		self scripts\class\_changeclass::onOpen( "allies" );
	}
	else*/
		self [[level.SpawnPlayer]]();
}

JoinAxis()
{	
	oldTeam = self.pers["team"];
	if( isAlive( self ) )
	{
		if( self.team == "axis" && level.gameState["axis"] == "playing" )
		{
			self.pers["team"] = "axis";
			self.skipDeathLogic = undefined;
			self suicide();
			return;
		}
		else
		{
			self.skipDeathLogic = true;
			self suicide();
			self waittill( "death_delay_finished" );
		}
	}
	
	if( isdefined( self.RespawnTime ) && self.RespawnTime > GetTime() )
	{
		self iprintln( "Spawn is possible only for ^1"+ int( (self.RespawnTime - GetTime()) / 1000 ) +"^7 seconds." );
		return;
	}
	
	self.pers["team"] = "axis";
	self.team = "axis";
	self.sessionteam = "axis";
	
	self notify( "joined_team", self.team );
		
	scripts\_events::RunCallback( level, "changeTeam", 1, self, oldTeam, "axis" );
	scripts\_events::RunCallback( self, "changeTeam", 1, oldTeam, "axis" );			
		
	/*if( !isDefined( self.pers["class"] ) || !isDefined( self.pers["class"]["axis"] ) )
	{
		self scripts\class\_changeclass::onOpen( "axis" );
	}
	else*/
		self [[level.SpawnPlayer]]();
}

AutoAssign()
{
	if( !isdefined( level.PickMonsters ) )
		self JoinAllies();
	else
		self JoinAxis();
}

JoinSpectator()
{
	oldTeam = self.pers["team"];
	if( self.team == "axis" && level.gameState["axis"] == "playing" )
	{
		time = level.dvars["logic_respawnTime"];
		self.RespawnTime = GetTime() + ( time*1000 );
	}

	self closeMenu();
	self closeInGameMenu();

	self unLink();
	self EnableWeapons();
	self FreezeControls( false );
	resettimeout();
	
	self.pers["team"] = "spectator";
	self.sessionteam = "spectator";
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.team = "spectator";

	if( isAlive( self ) )
	{
		self suicide();
		//self waittill( "death_delay_finished" );
	}

	spawnPoint = level.spawns["spectator"][ RandomInt( level.spawns["spectator"].size ) ];
	self spawn( spawnPoint.origin, spawnPoint.angles );	
	
	self allowSpectateTeam( "freelook", true );
	self allowSpectateTeam( "allies", true );
	self allowSpectateTeam( "axis", true );
	self allowSpectateTeam( "none", true );
	
	self scripts\clients\_players::UpdateStatusIcon();
	//self notify( "joined_team", self.team );
	
	scripts\_events::RunCallback( level, "changeTeam", 1, self, oldTeam, "spectator" );
	scripts\_events::RunCallback( self, "changeTeam", 1, oldTeam, "spectator" );	
}

OnDeath( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	if( IsDefined( self.skipDeathLogic ) )
	{
		self.skipDeathLogic = undefined;
		return;
	}
	
	if( IsPlayer( self ) ) // TODO: dotiahnuù!!
	{
		if( self.pers["team"] == "allies" )
		{
			if( level.gameState["axis"] != "playing" ) //prematch respawn
			{
				self thread [[level.SpawnPlayer]]();
			}
			else //pridanie k monötr·m
			{
				if( IsDefined( level.roundStarted ) )
					wait 2;
				self thread [[level.Axis]]();
			}
		}
		else if( self.pers["team"] == "axis" )
		{
			if( level.gameState["axis"] == "playing" )
			{
				time = level.dvars["logic_respawnTime"];
				self.RespawnTime = GetTime() + ( time*1000 );
				
				if( GetTime() < self.RespawnTime )
				{
					time = (self.RespawnTime - GetTime()) / 1000;
					self thread scripts\clients\_hud::SetLowerTextAndTimer( "Waiting for respawn", time, 160 );
					
					
					//allow spectating
					//self.pers["team"] = "spectator";
					//self.sessionteam = "spectator";
					self.sessionstate = "spectator";
					self.spectatorclient = -1;
					//self.team = "spectator";
					
					self allowSpectateTeam( "freelook", true );
					self allowSpectateTeam( "allies", false );
					self allowSpectateTeam( "axis", true );
					self allowSpectateTeam( "none", true );
					
					wait time;
				}
			}
			
			if( IsDefined( self ) )
				self thread [[level.SpawnPlayer]]();			
		}
	}
}
