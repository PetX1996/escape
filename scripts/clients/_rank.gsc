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
	BuildRank();

	level.giveScore = ::giveScore;
}

giveScore( type, value )
{
	if( !IsDefined(value) && !IsDefined(type) )
		return;
	
	if( !IsDefined( self.acp_info ) )
		return;
	
	if( !IsDefined(value) && IsDefined(type) )
		value = level.dvars[type];
	
	value = int( value );
	
	if( value == 0 )
		return;
	
	self.pers["score"] += value;
	self.score = self.pers["score"];
	self notify ( "update_playerscore_hud" );
	
	self giveRankXP( type, value );
	
	if( !IsDefined( type ) || type != "buy" )
		self giveMoney( value );
}

giveMoney( value )
{
	value = int( value );
	
	if( !IsDefined( value ) || value == 0 )
		return;
		
	self.pers["money"] += value;
}

// ================================================================================================================================================================================================= //
// ================================================================================================================================================================================================= //
// ================================================================================================================================================================================================= //
private RANK_MAXXP = 100000;
private RANK_MAXRANK = 99;

/// Získa rank prislúchajúci k XP
GetRankForXP( xp )
{
	if( xp < 0 )
		return 0;
	else if( xp > RANK_MAXXP )
		return RANK_MAXRANK;
		
	cosValue = (xp / RANK_MAXXP) - 1;
	rankId = ((ACos( cosValue ) - 180) * RANK_MAXRANK) / 90;
	return int( (rankId * (-1)) );
}

/// Získa maxXP pre daný rank
GetXPForRank( rankId )
{
	if( rankId < 0 )
		rankId = 0;

	rankId += 1;
	angles = ((rankId * 90) / RANK_MAXRANK) + 180;
	xp = (Cos( angles ) + 1) * RANK_MAXXP;
	return int( xp );
}

BuildRank()
{
	precacheString( &"RANK_PLAYER_WAS_PROMOTED" );
	precacheString( &"RANK_PLAYER_WAS_DEMOTED" );
	precacheString( &"MP_PLUS" );
	
	// ============================================== //

	rankId = 0;
	while( rankId <= RANK_MAXRANK )
	{
		rankIcon = TableLookup( "mp/rankIconTable.csv", 0, rankId, 1 );
		
		if( rankIcon == "" )
			break;
		
		PreCacheShader( rankIcon );
		PreCacheString( TableLookupIString( "mp/rankIconTable.csv", 0, rankId, 2 ) );
		
		rankId++;
	}
}

getRankInfoMinXP( rankId )
{
	return GetXPForRank( (rankId - 1) );
}

getRankInfoMaxXp( rankId )
{
	return GetXPForRank( rankId );
}

/// Získa názov levelu
getRankInfoFull( rankId )
{
	return tableLookupIString( "mp/rankicontable.csv", 0, rankId, 2 );
}

// ================================================================================================================================================================================================= //
// ================================================================================================================================================================================================= //
// ================================================================================================================================================================================================= //

OnPlayerConnected()
{
	self.pers["totalxp"] = self maps\mp\gametypes\_persistence::statGet( "totalxp" );
	
	if( !IsDefined( self.pers["money"] ) )
	{
		self.pers["rankxp"] = 0;
		self.pers["money"] = 0;
	}
	
	self CreateXPHud();
	self UpdateRankInfo();
	
	self maps\mp\gametypes\_persistence::playerPersSupport();
	self thread SendPlayerScoreInfo();
}

CreateXPHud()
{
	self.hud_rankscroreupdate = newClientHudElem(self);
	self.hud_rankscroreupdate.horzAlign = "center";
	self.hud_rankscroreupdate.vertAlign = "middle";
	self.hud_rankscroreupdate.alignX = "center";
	self.hud_rankscroreupdate.alignY = "middle";
	self.hud_rankscroreupdate.x = 0;
	self.hud_rankscroreupdate.y = -50;
	self.hud_rankscroreupdate.font = "default";
	self.hud_rankscroreupdate.fontscale = 2.0;
	self.hud_rankscroreupdate.archived = false;
	self.hud_rankscroreupdate.color = (0.5,0.5,0.5);
	self.hud_rankscroreupdate maps\mp\gametypes\_hud::fontPulseInit();
}

UpdateRankFromB3()
{
	self UpdateRankInfo();
	
	
}

UpdateRankInfo( rankId )
{
	if( !IsDefined( rankId ) )
		rankId = GetRankForXP( self.pers["rankxp"] );
		
	if( rankId > RANK_MAXRANK )
		rankId = RANK_MAXRANK;
		
	minXP = GetRankInfoMinXp( rankId );
	maxXP = GetRankInfoMaxXp( rankId );

	self.pers["rank"] = rankId;
	self.pers["participation"] = 0;
	
	self maps\mp\gametypes\_persistence::statSet( "rank", rankId );
	self maps\mp\gametypes\_persistence::statSet( "minxp", minXP );
	self maps\mp\gametypes\_persistence::statSet( "maxxp", maxXP );
	self maps\mp\gametypes\_persistence::statSet( "lastxp", self.pers["rankxp"] );
	self maps\mp\gametypes\_persistence::statSet( "rankxp", self.pers["rankxp"] );
	
	self.rankUpdateTotal = 0;
	
	self setRank( rankId, 0 );
	self.pers["prestige"] = 0;
}

giveRankXP( type, value )
{
	self endon("disconnect");

	self.pers["rankxp"] += value;
	self.pers["totalxp"] += value;
	self PrintDebug( "add ^1"+ value +"^7 XP | total ^1"+ self.pers["rankxp"] );

	self updateRank();
	self thread updateRankScoreHUD( value );
}

updateRank()
{
	newRankId = self GetRankForXP( self.pers["rankxp"] );
	
	if ( newRankId == self.pers["rank"] )
		return false;

	if( newRankId > RANK_MAXRANK )
		return false;
		
	if( newRankId > self.pers["rank"] )
		type = 1;
	else
		type = -1;
		
	self UpdateRankInfo( newRankId );
	self updateRankAnnounceHUD( type );
	return true;
}

updateRankAnnounceHUD( type )
{
	self notify("reset_outcome");
	
	newRankName = self getRankInfoFull( self.pers["rank"] );
	
	if( type == 1 )
	{
		iprintln( &"RANK_PLAYER_WAS_PROMOTED", self, newRankName );
		//self thread scripts\clients\_hud::AddNewNotify("notify_level");
	}
	else
	{
		iprintln( &"RANK_PLAYER_WAS_DEMOTED", self, newRankName );
		//self thread scripts\clients\_hud::AddNewNotify( "notify_leveldown" );
	}
}

updateRankScoreHUD( amount )
{
	self endon( "disconnect" );

	if ( amount == 0 )
		return;

	self notify( "update_score" );
	self endon( "update_score" );

	self.rankUpdateTotal += amount;

	wait ( 0.05 );

	
	if( isDefined( self.hud_rankscroreupdate ) )
	{			
		if ( self.rankUpdateTotal < 0 )
		{
			self.hud_rankscroreupdate.label = &"";
			self.hud_rankscroreupdate.color = (1,0,0);
		}
		else
		{
			self.hud_rankscroreupdate.label = &"MP_PLUS";
			self.hud_rankscroreupdate.color = (1,1,0.5);
		}

		self.hud_rankscroreupdate setValue(self.rankUpdateTotal);
		self.hud_rankscroreupdate.alpha = 0.85;
		self.hud_rankscroreupdate thread maps\mp\gametypes\_hud::fontPulse( self );

		wait 1;
		self.hud_rankscroreupdate fadeOverTime( 0.75 );
		self.hud_rankscroreupdate.alpha = 0;
		
		self.rankUpdateTotal = 0;
	}
}

SendPlayerScoreInfo()
{
	self endon( "disconnect" );

	lastXP = self.pers["rankxp"];
	lastMoney = self.pers["money"];
	
	self.save_last = 20000 + getTime();
	self.save_tick = false;
	
	while( true )
	{
		wait 0.5;
	
		if( !IsDefined( self.acp_info ) )
			continue;
	
		if( lastXP != self.pers["rankxp"] || lastMoney != self.pers["money"] )
		{
			self maps\mp\gametypes\_persistence::statSet( "rankxp", self.pers["rankxp"] );
			self maps\mp\gametypes\_persistence::statSet( "totalxp", self.pers["totalxp"] );
			
			self SetClientDvar( "hud_money", self.pers["money"] );
			
			lastXP = self.pers["rankxp"];
			lastMoney = self.pers["money"];
		}
		
		if ( self.stat_last_xp != self.pers["rankxp"] 
			&& ( self.save_last < getTime() || IsDefined( level.gameEnded ) || self.save_tick ) )
		{
			self.buying = undefined;
			self.save_tick = false;
			self.save_last = 30000 + getTime();
			self.stat_last_xp = self.pers["rankxp"];
			
			logPrint("XP;" + (self getGuid()) + ";" + (self getEntityNumber()) + ";" + self.stat_ident + ";"  +  self.stat_last_xp + ";" + self.name + "\n");
			setdvar( "stat_info_live_" + (self getEntityNumber()), self.stat_ident + ":" + self.stat_last_xp);
			
			if ( self.b3level > 99 )
				self iprintln("^3b3ick ^2" + self.stat_last_xp);
		}
	}
}