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

///
/// COIN( entity, origin )
///
/// COIN_EnableFlag( flag )
/// COIN_DisableFlag( flag )
/// COIN_SetTeamOnly( team )
/// COIN_CantPlayersGrab( players )
///
/// COIN_Start()
///

#include scripts\include\_model;
#include scripts\include\_array;
#include scripts\include\_main;
#include scripts\include\_physic;
#include scripts\include\_look;

// Flags
private COIN_FLAG_NOGRAB = 1;
private COIN_FLAG_NOROTATE = 2;
private COIN_FLAG_NOMOVEUP = 4;
private COIN_FLAG_ONEPERPLAYER = 8; // kaûd˝ hr·Ë bude maù moûnosù zobraù coin 1-kr·t
private COIN_FLAG_GRABALWAYS = 16; // coin bude dostupn˝ st·le pre vöetk˝ch
private COIN_FLAG_NOHIDEPERPLAYER = 32; // neschov· coin hr·Ëovi po jeho zobratÌ ak je COIN_FLAG_ONEPERPLAYER
private COIN_FLAG_NODELETE = 64;
private COIN_FLAG_DROPTOGROUND = 128; // zhodÌ coin na zem

///
/// VytvorÌ z entity coin na danom mieste.
///
COIN( entity, origin )
{
	entity.CoinFlags = 0;
	entity.CoinTeam = undefined;
	entity.CoinCantPlayers = [];
	entity.CoinPlayerList = [];
	return entity;
}
///
/// UpravÌ vlastnosti coinu
///
COIN_EnableFlag( flag )
{
	self.CoinFlags |= flag;
}
COIN_DisableFlag( flag )
{
	self.CoinFlags &= ~flag;
}
COIN_SetTeamOnly( team )
{
	self.CoinTeam = team;
}
COIN_CantPlayersGrab( players )
{
	self.CoinCantPlayers = players;
}
///
/// Aktivuje coin
///
COIN_Start()
{
	if( self.CoinFlags & COIN_FLAG_DROPTOGROUND )
		self PHYSIC_DropToGround( 30 );

	if( !(self.CoinFlags & COIN_FLAG_NOROTATE) )
		self thread COIN_Rotate();
		
	if( !(self.CoinFlags & COIN_FLAG_NOMOVEUP) )
		self thread COIN_MoveUp();
		
	self thread COIN_MonitorPlayers();
}
/// Rot·cia coinu
private ROTATE_TIME = 3;
COIN_Rotate()
{
	wait 1;
	while( IsDefined( self ) )
	{
		self RotateYaw( 360, ROTATE_TIME );
		wait ROTATE_TIME;
	}
}
/// Pohyb coinu hore - dole
private MOVE_TIME = 2;
COIN_MoveUp()
{
	wait 1;
	while( IsDefined( self ) )
	{
		self MoveZ( 10, MOVE_TIME/2 );
		wait MOVE_TIME/2;
		self MoveZ( -10, MOVE_TIME/2 );
		wait MOVE_TIME/2;
	}
}
/// Monitoruje hr·Ëov
private MONITOR_GRABDISTANCE = 64;
COIN_MonitorPlayers()
{
	while( IsDefined( self ) )
	{
		if( !(self.CoinFlags & COIN_FLAG_NOGRAB) )
		{
			for( p = 0; p < level.players.size; p++ )
			{
				player = level.players[p];
				if( player.pers["team"] == "spectator" || !IsAlive( player ) )
					continue;
					
				if( IsDefined( self.CoinTeam ) && self.CoinTeam != player.pers["team"] )
					continue;
					
				dist = Distance( self.origin, player LOOK_GetPlayerCenterPos() );
				if( dist > MONITOR_GRABDISTANCE )
					continue;
					
				if( IsInArray( self.CoinCantPlayers, player ) )
					continue;
					
				if( self.CoinFlags & COIN_FLAG_GRABALWAYS ) // ak je moûnÈ coin braù vûdy
				{
					self COIN_GrabCoin( player );
				}
				else if( self.CoinFlags & COIN_FLAG_ONEPERPLAYER ) // ak je moûnÈ iba jeden na hr·Ëa
				{
					if( IsInArray( self.CoinPlayerList, player ) )
						continue;
						
					self.CoinPlayerList[self.CoinPlayerList.size] = player;
					self COIN_GrabCoin( player );
					
					if( !(self.CoinFlags & COIN_FLAG_NOHIDEPERPLAYER) )
						self HideToPlayers( self.CoinPlayerList );
				}
				else // iba raz!
				{
					self COIN_GrabCoin( player );
					self COIN_DeleteCoin();
				}
			}
		}
		
		wait 0.5;
	}
}
/// hr·Ë zoberie coin
COIN_GrabCoin( player )
{
	scripts\_events::RunCallback( level, "coinGrab", 0, self, player );
	scripts\_events::RunCallback( self, "coinGrab", 0, player );
}
/// coin sa zmaûe
COIN_DeleteCoin()
{
	scripts\_events::RunCallback( level, "coinDelete", 0, self );
	scripts\_events::RunCallback( self, "coinDelete", 0 );

	if( !(self.CoinFlags & COIN_FLAG_NODELETE) && IsDefined( self ) )
	{
		self Delete();
		return;
	}
}