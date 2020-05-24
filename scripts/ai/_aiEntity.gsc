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

// priority
// 0 - vidÌm hr·Ëa!
// 1 - vidÌm bota, kt. vidÌ hr·Ëa!
// 2 - vidÌm bota, kt. vidÌ bota, kt. vidÌ hr·Ëa!
// 3 - vidÌm bota, kt. vidÌ bota, kt. vidÌ bota, kt. vidÌ hr·Ëa!

// TODO: zlepöiù vyberanie ˙hlov pri n·hodnom pohybe
// TODO: ˙tok na hr·Ëa

#include scripts\include\_main;
#include scripts\include\_look;
#include scripts\include\_health;
#include scripts\include\_array;
#include scripts\include\_event;

private AI_INI_SPEED = 120;
private AI_INI_HEALTH = 100;
private AI_INI_DISTANCEFROMGROUND = 16;
private AI_INI_STEPSIZE = 64;

private AI_INI_SIGHTDISTANCE = 512;

private AI_INI_MAXSEARCHPRIORITY = 2;

private AI_INI_CLIMBCOS = 0.5;
private AI_INI_FALLCOS = -0.5;

private AI_INI_MAXRANDOMTRYCOUNT = 20;
private AI_INI_ANGLESINCREMENT = 9; // 180 / AI_INI_MAXRANDOMTRYCOUNT

private AI_INI_MAXAFKTIMES = 10;
private AI_INI_AFKDURATION = 1;

private AI_INI_MAXBULLETTRACETRYCOUNT = 5;

private AI_INI_ATTACKDISTANCE = 32;
private AI_INI_ATTACKSPACETIME = 2000;

private AI_INI_OPTIMALIZATIONTIME = 0.2;

AI( origin, angles )
{
	ent = Spawn( "script_model", origin + (0,0,AI_INI_DISTANCEFROMGROUND) );
	ent.angles = angles;
	//ent SetModel( "bc_hesco_barrier_sm" );
	ent SetModel( "4gf_laser_emitor" );
	
	ent HEALTH( AI_INI_HEALTH );
	AddCallback( ent, "HEALTH_entityDelete", ::AI_Delete );
	ent HEALTH_Start();
	
	ent.AI = SpawnStruct();
	ent.AI.SearchPriority = undefined;
	ent.AI.AFKTimes = 0;
	ent.AI.AttackTime = 0;
	ent.AI.LockedTarget = undefined;
	/# ent.AI.debugLines = 0; #/
	
	if( !IsDefined( level.AI_Field ) )
		level.AI_Field = [];
		
	level.AI_Field[level.AI_Field.size] = ent;
	
	ent thread AI_ProcessMoving();
}

AI_Delete()
{
	level.AI_Field = ARRAY_Remove( level.AI_Field, self );
	self Delete();
}

AI_ProcessMoving()
{
	wait 0.01;
	if( !IsDefined( self ) )
			return;
			
	self AI_ResetDebug();

	for( searchPriority = 0; searchPriority < AI_INI_MAXSEARCHPRIORITY ; searchPriority++ )
	{
		targetEnt = self AI_GetBestTarget( searchPriority );
		if( !IsDefined( self ) )
			return;
		
		if( !IsDefined( targetEnt ) )
			continue;
		
		if( IsPlayer( targetEnt ) && self AI_CheckPlayerAttack( targetEnt ) )
			return;
			
		self AI_MoveToTarget( targetEnt );
		return;
	}
	
	self AI_MoveToTarget();
}

AI_CheckPlayerAttack( player )
{
	playerPos = player.origin + ( 0,0,AI_INI_DISTANCEFROMGROUND );
	if( Distance( self.origin, playerPos ) < AI_INI_ATTACKDISTANCE )
	{
		self AI_Attack( player );
		return true;
	}
	return false;
}

AI_Attack( player )
{
	if( self.AI.AttackTime > GetTime() )
	{
		wait (self.AI.AttackTime - GetTime()) / 1000;
		self thread AI_ProcessMoving();
		return;
	}
	
	self.AI.AttackTime = GetTime() + AI_INI_ATTACKSPACETIME;
	self AI_PrintDebug( "A", (1,1,0) );
	player iprintlnbold( "attack!" );
	self thread AI_ProcessMoving();
	return;
}

AI_MoveToTarget( targetEnt )
{
	if( IsDefined( targetEnt ) && IsPlayer( targetEnt ) )
		self.AI.SearchPriority = 0;
	else if( IsDefined( targetEnt ) && IsDefined( targetEnt.AI.SearchPriority ) )
		self.AI.SearchPriority = targetEnt.AI.SearchPriority + 1;
	else
	{
		self.AI.SearchPriority = undefined;
		targetEnt = undefined;
	}
	self.AI.LockedTarget = targetEnt;
	
	targetOrigin = undefined;
	while( IsDefined( targetEnt ) )
	{
		targetOrigin = targetEnt.origin;
		if( IsPlayer( targetEnt ) )
			targetOrigin = targetEnt LOOK_GetPlayerCenterPos();

		stepSize = AI_INI_STEPSIZE;
		dist = Distance( self.origin, targetOrigin );
		if( dist < AI_INI_STEPSIZE )
			stepSize = dist;
			
		playerVec = VectorNormalize( targetOrigin-self.origin );
		
		stepPos = self.origin + (playerVec * stepSize);
		groundPos = self AI_GetGround( stepPos );
		aboveGroundPos = groundPos + (0,0,AI_INI_DISTANCEFROMGROUND);
		
		targetVec = VectorNormalize( aboveGroundPos-self.origin );
		targetOrigin = aboveGroundPos;
		
		if( !self AI_CheckZAxis( targetVec ) || !self AI_CheckZAxis( playerVec ) )
		{
			targetOrigin = undefined;
			break;
		}
		
		if( IsDefined( targetEnt.name ) )
			self AI_PrintDebug( "P "+targetEnt.name, (1,0,0) );
		else
			self AI_PrintDebug( "B "+targetEnt.AI.SearchPriority, (0,1,0) );
		
		break;
	}
	
	if( !IsDefined( targetOrigin ) )
		targetOrigin = self AI_GetRandomOrigin();
	
	if( IsDefined( targetOrigin ) )
		self thread AI_MakeStep( targetOrigin );
	else
		self thread AI_MakeAFK();
}

AI_GetGround( position )
{
	trace = self AI_BulletTrace( position, position + (0,0,-10000) );
	return trace["position"];
}

AI_CheckZAxis( vec )
{
	vecLength = Length( vec );
	if( vecLength == 0 )
		return true;
	
	vecCos = vec[2] / vecLength;
	if( vecCos < AI_INI_CLIMBCOS && vecCos > AI_INI_FALLCOS )
		return true;
		
	return false;
}

AI_GetRandomOrigin()
{
	targetOrigin = undefined;
	for( tryCount = 0; tryCount < AI_INI_MAXRANDOMTRYCOUNT; tryCount++ )
	{
		angles = self AI_GetRandomAngles( tryCount );
		
		forwardVec = AnglesToForward( angles );
		upVec = forwardVec + ( 0,0,AI_INI_CLIMBCOS );
		upPos = self.origin + (upVec * AI_INI_STEPSIZE);
		
		// pozri sa hore
		if( !self AI_BulletTracePassed( self.origin, upPos ) )
			continue;
			
		// n·jdi zem
		groundPos = self AI_GetGround( upPos );
		aboveGroundPos = groundPos + ( 0,0,AI_INI_DISTANCEFROMGROUND );
		
		newVec = VectorNormalize( aboveGroundPos-self.origin );
		newPos = self.origin + (newVec * AI_INI_STEPSIZE);
		
		// pozri sa na nov˙ pozÌciu
		if( !self AI_BulletTracePassed( self.origin, newPos ) )
			continue;

		// zkontroluj sklon
		if( !self AI_CheckZAxis( newVec ) )
			continue;
			
		targetOrigin = newPos;
		break;
	}
	
	self AI_PrintDebug( "R "+tryCount, (0,0,1) );
	return targetOrigin;
}

AI_GetRandomAngles( tryCount ) // only XY
{
	dir = RandomInt(2);
	if( dir == 0 )
		dir = -1;

	randomAngles = RandomFloat( AI_INI_ANGLESINCREMENT )*dir;
	
	// currentAngles + lastMaximum + newRandomIncrement
	return ( 0,self.angles[1] + (tryCount*AI_INI_ANGLESINCREMENT*dir) + randomAngles,0 );
}

AI_MakeStep( targetOrigin )
{
	if( targetOrigin == self.origin )
	{
		self thread AI_ProcessMoving();
		return;
	}

	self.AI.AFKTimes = 0;

	self.angles = VectorToAngles( VectorNormalize( targetOrigin-self.origin ) );
	
	dist = Distance( self.origin, targetOrigin );
	time = dist / AI_INI_SPEED;
	
	AI_PrintLine( self.origin, targetOrigin, time );
	self MoveTo( targetOrigin, time );

	moveTime = time;
	if( moveTime > AI_INI_OPTIMALIZATIONTIME )
		moveTime -= AI_INI_OPTIMALIZATIONTIME;
		
	wait moveTime;
	//iprintln("time;^1"+time+"^7;moveTime;^1"+moveTime);
	
	if( IsDefined( self ) )
		self thread AI_ProcessMoving();
}

AI_MakeAFK()
{
	self.AI.AFKTimes++;
	if( self.AI.AFKTimes >= AI_INI_MAXAFKTIMES )
	{
		self AI_Delete();
		return;
	}
	
	self AI_PrintDebug( "AFK "+self.AI.AFKTimes, (1,1,1) );
	wait AI_INI_AFKDURATION;
	
	if( IsDefined( self ) )
		self thread AI_ProcessMoving();	
}

AI_GetBestTarget( searchPriority )
{
	if( searchPriority == 0 
	&& IsDefined( self.AI.LockedTarget ) 
	&& self AI_IsTargetAvailable( self.AI.LockedTarget ) 
	&& (IsPlayer( self.AI.LockedTarget ) || (IsDefined( self.AI.LockedTarget.AI.SearchPriority ) && self.AI.LockedTarget.AI.SearchPriority < AI_INI_MAXSEARCHPRIORITY)))
		return self.AI.LockedTarget;

	targetsArray = self AI_GetTargetsForPriority( searchPriority );
	if( !IsDefined( targetsArray ) || !IsDefined( self ) )
		return undefined;
	
	wait 0.01;
	if( !IsDefined( self ) )
		return undefined;
		
	foreach( targetEnt in targetsArray )
	{
		if( Distance( targetEnt.origin, self.origin ) < AI_INI_SIGHTDISTANCE && self AI_IsTargetAvailable( targetEnt ) )
			return targetEnt;
	}
		
	/*targetsArray = self AI_SortTargetsByDistance( targetsArray );
	if( !IsDefined( targetsArray ) || !IsDefined( self ) )
		return undefined;
		
	wait 0.01;
	if( !IsDefined( self ) )
		return undefined;
	
	for( i = 0; i < targetsArray.size; i++ )
	{
		if( IsDefined( targetsArray[i] ) && self AI_IsTargetAvailable( targetsArray[i] ) )
			return targetsArray[i];
	}*/
	return undefined;
}

AI_GetTargetsForPriority( searchPriority )
{
	targetsArray = [];
	
	if( searchPriority == 0 )
		targetsArray = self AI_GetAliveTargets();
	else
		targetsArray = self AI_GetAITargets( searchPriority );
	
	return targetsArray;
}

AI_GetAliveTargets()
{
	targetsArray = [];
	for( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if( !IsDefined( player ) || !IsAlive( player ) || player.pers["team"] == "spectator" )
			continue;
			
		targetsArray[targetsArray.size] = player;
	}
	return targetsArray;
}

AI_GetAITargets( searchPriority )
{
	targetsArray = [];
	for( i = 0; i < level.AI_Field.size; i++ )
	{
		bot = level.AI_Field[i];
		if( IsDefined( bot ) && IsDefined( bot.AI.SearchPriority ) && bot.AI.SearchPriority == (searchPriority-1) && bot != self )
		{
			//iprintlnbold( "adding bot target" );
			targetsArray[targetsArray.size] = bot;
		}
	}
	return targetsArray;
}

AI_SortTargetsByDistance( targetsArray )
{
	arrayLength = targetsArray.size;
	sortArray = [];
	for( i = 0; i < arrayLength; i++ )
	{
		nearestTarget = self AI_GetNearestTarget( targetsArray );
		if( !IsDefined( nearestTarget ) || !IsDefined( self ) )
			return undefined;
		
		sortArray[sortArray.size] = nearestTarget;
		targetsArray = DeleteFromArray( targetsArray, nearestTarget );
	}
	
	return sortArray;
}

AI_GetNearestTarget( targetsArray )
{
	nearesTarget = undefined;
	minDist = 99999999;
	for( i = 0; i < targetsArray.size; i++ )
	{
		if( !IsDefined( targetsArray[i] ) )
			continue;
			
		if( !IsDefined( self ) )
			return undefined;
	
		dist = Distance( self.origin, targetsArray[i].origin );
		if( dist < minDist )
		{
			minDist = dist;
			nearesTarget = targetsArray[i];
		}
	}
	return nearesTarget;
}

AI_IsTargetAvailable( targetEnt )
{
	targetOrigin = targetEnt.origin;
	if( IsPlayer( targetEnt ) )
		targetOrigin = targetEnt LOOK_GetPlayerCenterPos();
		
	if( self AI_BulletTracePassed( self.origin, targetOrigin ) )
		return true;
		
	return false;
}

AI_BulletTracePassed( start, end )
{
	trace = self AI_BulletTrace( start, end );
	
	if( trace["fraction"] == 1 )
		return true;
		
	return false;
}

AI_BulletTrace( start, end )
{
	if( start == end )
		return BulletTrace( start, end, false, self );

	tryCount = 0;
	trace = undefined;
	currentPos = start;
	
	trace = BulletTrace( start, end, false, self );
	while( currentPos != end && tryCount < AI_INI_MAXBULLETTRACETRYCOUNT )
	{
		if( IsDefined( trace["entity"] ) && IsInArray( level.AI_Field, trace["entity"] ) )
		{
			currentPos = trace["position"];
			trace = BulletTrace( currentPos, end, false, trace["entity"] );
			tryCount++;
		}
		else
			break;
	}
	
	//if( tryCount != 0 )
		//iprintlnbold( "bulletTraceTryCount ^1"+tryCount );
		
	trace["fraction"] = Distance( start, trace["position"] ) / Distance( start, end );
	return trace;
}

AI_PrintDebug( text, color )
{
	/#
	Print3d( self.origin + ( 0,0,6+(self.AI.debugLines*18) ), text, color, 1, 2, 25 );
	self.AI.debugLines++;
	#/
}
AI_PrintLine( start, end, time )
{
	/#
	thread PrintLine( start, end, (1,1,1), false, time );
	#/
}
AI_ResetDebug()
{
	/#
	self.AI.debugLines = 0;
	#/
}