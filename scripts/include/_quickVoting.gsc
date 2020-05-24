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
#include scripts\include\_main;

private QV_INI_TIME = 15;

// QV( name, time, onYes, onNo )

QV( name, time, onYes, onNo )
{
	if( IsDefined( level.QV ) )
	{
		PrintDebug( "QuickVoting already runned." );
		return;
	}
		
	level.QV = SpawnStruct();
	//level.QV.Players = [];
	level.QV.Yes = 0;
	level.QV.No = 0;
	
	foreach( player in level.players )
		player QV_CreateClientInterface( name );
	
	if( !IsDefined( time ) )
		time = QV_INI_TIME;
		
	wait time;
	
	foreach( player in level.players )
		player QV_DeleteClientInterface();
		
	if( level.QV.Yes > level.QV.No )
	{
		IPrintLn( "^2Voting " + name + " passed( " + level.QV.Yes + ":" + level.QV.No + " )" );
	
		if( IsDefined( onYes ) )
			[[onYes]]();
	}
	else
	{
		IPrintLn( "^1Voting " + name + " failed( " + level.QV.Yes + ":" + level.QV.No + " )" );
	
		if( IsDefined( onNo ) )
			[[onNo]]();
	}
	
	level.QV = undefined;
}

QV_CreateClientInterface( name )
{
	self SetClientDvar( "hud_quickVoting", name );
	AddCallback( self, "onButtonPressed", ::QV_OnButtonPressed );
	//level.QV.Players[level.QV.Players.size] = self;
}

QV_DeleteClientInterface()
{
	self SetClientDvar( "hud_quickVoting", "" );
	DeleteCallback( self, "onButtonPressed", ::QV_OnButtonPressed );
}

QV_OnButtonPressed( button )
{
	if( button == "btn_voteyes" || button == "btn_voteno" )
	{
		if( button == "btn_voteyes" )
			self QV_OnVoted( true );
		else
			self QV_OnVoted( false );
			
		self QV_DeleteClientInterface();
	}
}

QV_OnVoted( choice )
{
	if( choice )
		level.QV.Yes++;
	else
		level.QV.No++;
}