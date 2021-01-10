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

GetAllPlayers( team )
{
	array = [];
	for( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
	
		if( !IsDefined( player ) )
			continue;
			
		if( IsDefined( team ) && player.pers["team"] == team )
			array[array.size] = player;
		else if( !IsDefined( team ) )
			array[array.size] = player;
	}
	
	return array;
}

GetAllAlivePlayers( team )
{
	players = [];
	for( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		
		if( !IsDefined( player ) || !IsAlive( player ) )
			continue;
			
		if( IsDefined( team ) && player.pers["team"] == team )
			players[players.size] = player;
		else if( !IsDefined( team ) )
			players[players.size] = player;
	}
	return players;
}

DvarSendAllPlayers( name, value )
{
	if( !isdefined( name ) || name == "" || !isdefined( value ) )
		return;

	players = level.players;
	
	for(i = 0;i < players.size;i++)
		players[i] SetClientDvar( name, value );
}

FreezeMove( status )
{
	if( !isdefined( level.temp_ent ) )
		level.temp_ent = spawn( "script_origin", (0,0,0) );

	if( status )
	{
		self linkto( level.temp_ent );
	}
	else
	{
		self unlink();
	}	
}

WaittllAny(w1, w2, w3, w4, w5, w6, w7, w8)
{
	if(isdefined(w2))
		self endon(w2);
	
	if(isdefined(w3))
		self endon(w3);
		
	if(isdefined(w4))
		self endon(w4);
		
	if(isdefined(w5))
		self endon(w5);
		
	if(isdefined(w6))
		self endon(w6);
		
	if(isdefined(w7))
		self endon(w7);

	if(isdefined(w8))
		self endon(w8);	
		
	self waittill(w1);
}

MapError( message )
{
	/*
	if( !isDefined( level.MapErrors ) )
		level.MapErrors = [];
	
	level.MapErrors[level.MapErrors.size] = "^1Map - ^7"+text;
	*/
	
	PrintError( "", "", message );
}

PrintError( file, function, message )
{
	PrintDebug( file + " ; " + function + " ; " + message );
	LogPrint( file + " ; " + function + " ; " + message + "\n" );
	AssertMsg( message );
}

PrintDebug( text, [a0], [p0], [a1], [p1], [a2], [p2], [a3], [p3], [a4], [p4], [a5], [p5], [a6], [p6], [a7], [p7], [a8], [p8], [a9], [p9] )
{
	if (IsDefined(a0))
		text += "^7;" + a0 + ";^1" + p0;

	if (IsDefined(a1))
		text += "^7;" + a1 + ";^1" + p1;
		
	if (IsDefined(a2))
		text += "^7;" + a2 + ";^1" + p2;	
		
	if (IsDefined(a3))
		text += "^7;" + a3 + ";^1" + p3;
		
	if (IsDefined(a4))
		text += "^7;" + a4 + ";^1" + p4;	
		
	if (IsDefined(a5))
		text += "^7;" + a5 + ";^1" + p5;
		
	if (IsDefined(a6))
		text += "^7;" + a6 + ";^1" + p6;	
		
	if (IsDefined(a7))
		text += "^7;" + a7 + ";^1" + p7;
		
	if (IsDefined(a8))
		text += "^7;" + a8 + ";^1" + p8;	
		
	if (IsDefined(a9))
		text += "^7;" + a9 + ";^1" + p9;
		
	thread PrintDebugNow( text );
}

PrintDebugNow( text )
{
	if( isdefined( self ) && isplayer( self ) )
	{
		if( self.b3level >= 120 || level.dvars["developer"] )
			self iprintln( "[^1DEBUG^7] "+ text );
			
		return;
	}
	
	//wait RandomFloat( 0.5 );
	
	print = false;
	
	players = getentarray( "player", "classname" );
	if( players.size > 0 )
	{
		for(i = 0;i < players.size;i++)
		{
			if( isdefined( players[i] ) && isplayer( players[i] ) && players[i].b3level >= 120 )
			{
				players[i] iprintln( "[^1DEBUG^7] "+ text );
				print = true;
			}
		}
	}
	
	if( print )
		return;
	
	starttime = gettime();
	
	while( true )
	{
		players = getentarray( "player", "classname" );
		for(i = 0;i < players.size;i++)
		{
			if( isdefined( players[i] ) && isplayer( players[i] ) && players[i].b3level >= 120 )
			{
				players[i] iprintln( "[^1DEBUG^7] "+ text );
				print = true;
			}
		}
		
		if( gettime()-starttime > 10000 || print )
		{
			return;
		}
		
		wait 1;
	}
}

CustomPrint(text, size, alive, team)
{
	if(!isdefined(text))
		return;
		
	if(!isdefined(size))
		size = "small";
	
	players = level.players;
	for(i = 0;i < players.size;i++)
	{	
		player = players[i];
	
		if(isdefined(alive) && alive)
		{
			if(isalive(player))
			{
				if(isdefined(team))
				{
					if(team == player.pers["team"])
					{
						if(size == "small")
							player iprintln(text);
						else
							player iprintlnbold(text);
					}
				}
				else
				{
					if(size == "small")
						player iprintln(text);
					else
						player iprintlnbold(text);
				}				
			}
		}
		else
		{
			if(isdefined(team))
			{
				if(team == player.pers["team"])
				{
					if(size == "small")
						player iprintln(text);
					else
						player iprintlnbold(text);
				}
			}
			else
			{
				if(size == "small")
					player iprintln(text);
				else
					player iprintlnbold(text);
			}				
		}		
		
	}
}

BouncePlayer( amount, vec )
{
	self endon("disconnected");
	self endon("death");
	
	for( i = 0;i < amount;i++ )
	{
		self.health = (self.health + 600);
		self finishPlayerDamage( self, self, 600, 0, "MOD_PROJECTILE", "rpg_mp", vec, vec, "none", 0 );
		self StopRumble();
	}
}

AddFXtoList(name)
{
	if(!isdefined(level.escape_fx))
		level.escape_fx = [];

	if(!isdefined(level.escape_fx[name]))
		level.escape_fx[name] = LoadFX( name );

	return level.escape_fx[name];
}

PlaySoundOnTempEnt( sound, origin )
{
	ent = spawn( "script_origin", origin );
	ent PlaySound( sound );
	wait 10;
	ent delete();
}

UIActive()
{
	if( isDefined( self.UIactive ) )
		return true;
	else
		return false;
}

PrintLine( start, end, color, depthTest, secondsDuration )
{
	duration = int( secondsDuration / 0.05 );
	for( i = 0; i < duration; i++ )
	{
		/#
		Line( start, end, color, depthTest, duration );
		#/
		wait 0.05;
	}
}

/*vector_scale(vec, scale)
{
	vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
	return vec;
}

isMG( weapon )
{
	return isSubStr( weapon, "_bipod_" );
}*/