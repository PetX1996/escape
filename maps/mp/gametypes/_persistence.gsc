//******************************************************************************
//  _____                  _    _             __
// |  _  |                | |  | |           / _|
// | | | |_ __   ___ _ __ | |  | | __ _ _ __| |_ __ _ _ __ ___
// | | | | '_ \ / _ \ '_ \| |/\| |/ _` | '__|  _/ _` | '__/ _ \
// \ \_/ / |_) |  __/ | | \  /\  / (_| | |  | || (_| | | |  __/
//  \___/| .__/ \___|_| |_|\/  \/ \__,_|_|  |_| \__,_|_|  \___|
//       | |               We don't make the game you play.
//       |_|                 We make the game you play BETTER.
//
//            Website: http://openwarfaremod.com/
//******************************************************************************

private STAT_IDENT = 2328; // identification field in mpdata
private STAT_MIGRATION = 0; // enable(1)/disable(0) rankxp migration to DB

init()
{
	//level thread onPlayerConnect();
	level thread StatFromB3();
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		player thread playerPersSupport();
	}
}

onDisconnect() {
	slot = self getEntityNumber();
	self waittill("disconnect");
	setdvar( "stat_info_" + slot, "" );
	setdvar( "stat_info_live_" + slot, "" );
	
}

playerPersSupport() {
	self endon("disconnect");
	
	self thread onDisconnect();

	if( !level.dvars["b3_allow"] )
	{
		setdvar( "acp_info_" + (self getEntityNumber()), level.dvars["b3_startacp"] );
	}
	
	setdvar( "stat_info_" + (self getEntityNumber()), "" );
	
	self.save_tick = false;
	self.stat_rankxp = undefined;
	self.stat_info = undefined;
	self.stat_info_enabled = undefined;
	self.stat_last_xp = -1;
	self.stat_ident_migrate = undefined;

	self setClientDvar("ui_xpText", "1");
	self.enableText = true;
	
	if ( isDefined(self.pers["isBot"]) )
		return;
		
	while(true) {
		if ( isDefined(self.acp_info) ) break;
		wait 0.25;
	}
	
	self.stat_ident = self getStat( STAT_IDENT );
	if ( self.stat_ident == 0 ) {
		self.stat_ident = getTime() + 1;
		if ( self.stat_ident > 999999999)
			self.stat_ident = RandomIntRange( 999, 999999999 );
		
		self.stat_ident =  self.stat_ident + RandomIntRange( 999, 999999 );
		
		
		if ( STAT_MIGRATION == 1) {
			self.stat_ident_migrate = true;
		} else {
			self setStat( STAT_IDENT, self.stat_ident );
			self.pers["rankxp"] = 0;
			self statSet("rankxp", 0);
		}
		
		self iprintln("^3New B3StatIdent ^2" + self.stat_ident); 
	}

	if( !level.dvars["b3_allow"] )
	{
		setdvar( "stat_info_" + (self getEntityNumber()), self.stat_ident + ":" + level.dvars["b3_startxp"] );
	}
	
	/*
	if ( self.b3level < 100 ) {
		self setStat( STAT_IDENT, self.stat_ident );
		self thread savePersOnly();
		return;
	}
*/
	skip_request = false;
	while(true) {
		if ( isDefined(self.stat_ident_migrate) )
			break;
	
		stat_info = getdvar( "stat_info_live_" + (self getEntityNumber()) );
		info = strtok( stat_info, ":" );
		//self iprintln("stat_info " + stat_info + "  >>> " + self.pers["rankxp"]);
		if(isDefined(info) 
			&& info.size > 1
			&& self.stat_ident == int(info[0]) 
			&& self.pers["rankxp"] == int(info[1]) ) 
		{
			self.stat_last_xp = self.pers["rankxp"];
			self.stat_info = stat_info;
			setdvar( "stat_info_" + (self getEntityNumber()), self.stat_ident + ":" + self.stat_last_xp);
			skip_request = true;
			break;
		} 
				
		self.stat_info = undefined;
		setdvar( "stat_info_live_" + (self getEntityNumber()), "" );
		break;
	}
	
	stat_info = undefined;
	info = undefined;
	
	self.stat_info_enabled = true;
				

	if ( !isDefined(self.stat_ident_migrate) )
		self iprintln("^3B3StatIdent ^2" + self.stat_ident); 
	
	self.save_last = 500 + getTime();
	while(!skip_request) {
		if ( isDefined(self.stat_info) )
			break;

		if ( self.save_last < getTime() ) {
			self iprintln("^3b3ick ^2XQ ^4" + self.stat_ident);
			logPrint("XQ;" + (self getGuid()) + ";" + (self getEntityNumber()) + ";" + self.stat_ident + ";" + self.name + "\n");
			self.save_last = 2000 + getTime();
		}
		wait 0.1;
	}
	
	skip_request = undefined;
}

StatFromB3()
{
	while(1) {
		
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( isDefined( player ) && isDefined(player.stat_info_enabled) )
			{
				enNum = player getEntityNumber();
				//iprintln("hladam " + enNum);
			
				stat_info = getdvar( "stat_info_" + enNum );
				if (!isDefined(player.pers["rankxp"]) || stat_info == "" || (isDefined(player.stat_info) && player.stat_info == stat_info))
					continue;

				info = strtok( stat_info, ":" );
				
				if(!isDefined(info) || !isDefined(player))
					continue;
				
				if(!isDefined(info[0])) {
					continue;
				}
				
				if(isDefined(info[0])) {
					ident = int(info[0]);
					if ( player.stat_ident != ident ) {
						continue;
					}
				}				

				if(isDefined(info[1])) {
					
					stat_rankxp = int(info[1]);
					if ( isDefined(player.stat_ident_migrate) ) {
						player setStat( STAT_IDENT, player.stat_ident );
						stat_rankxp = player.pers["rankxp"];
						player.stat_last_xp = stat_rankxp;
						player iprintln("^3B3ick ^2XP-MiG ^4" + stat_rankxp);
						player.stat_ident_migrate = undefined;
						logPrint("XP;" + (player getGuid()) + ";" + (player getEntityNumber()) + ";" + player.stat_ident + ";"  +  player.stat_last_xp + ";" + player.name + "\n");
					} else {
						player.pers["rankxp"] = stat_rankxp;
						player.stat_last_xp = stat_rankxp;
						player iprintln("^3B3ick ^2XP ^4" + stat_rankxp);
					}
					
					player.stat_info = stat_info;
					//player statSet("rankxp", stat_rankxp);
					setdvar( "stat_info_live_" + (player getEntityNumber()), player.stat_ident + ":" + stat_rankxp);
					player thread updatePlayerStats();
				} else {
					//TODO: error!
				}
				
			}
		}
		
		wait 0.5;
	}
}


updatePlayerStats() {
	self endon("disconnect");
	
	self scripts\clients\_rank::UpdateRankFromB3();
}

// ==========================================
// Script persistent data functions
// These are made for convenience, so persistent data can be tracked by strings.
// They make use of code functions which are prototyped below.
/*
=============
statGet

Returns the value of the named stat
=============
*/
statGet( dataName )
{
	if ( !level.rankedMatch && level.scr_server_rank_type != 2 )
		return 0;

	return self getStat( int(tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 )) );
}

/*
=============
setStat

Sets the value of the named stat
=============
*/
statSet( dataName, value )
{
	if ( !level.rankedMatch && level.scr_server_rank_type != 2 )
		return;
	
	if ( dataName == "rankxp" ) {
		self.save_tick = true;
		//iprintln("xp " + value + "  >>> " + self.pers["rankxp"]);
	}
	
	self setStat( int(tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 )), value );	
}

/*
=============
statAdd

Adds the passed value to the value of the named stat
=============
*/
statAdd( dataName, value )
{	
	if ( !level.rankedMatch && level.scr_server_rank_type != 2 )
		return;

	statCell = Int( tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 ) );
	curValue = self getStat( statCell );
	self setStat( statCell, value + curValue );
}
