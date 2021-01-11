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

// TODO: pri zhadzovanÌ objektu na zem checkovaù v˝sledn˝ origin a nie ten s˙Ëasn˝  - tj. miesta, kam to dopadne :)
// TODO: horeuvedenÈ otestovaù na serveri...

/// IA( entity )
///
/// IA_EnableFlag( flag )
/// IA_DisableFlag( flag )
/// IA_SetCollisions( collide, radius, height )
/// IA_SetDetects( bulletDetect, radius, height, playerRadius, lookMode, grabWithBtn )
/// IA_SetHold( giveToHands, distanceFromPlayer, originOffset, visible, solid, dropOnDeath, disableWeapons )
///
/// IA_GroundObject()
/// IA_PlayerObject( player )

// IA_GroundObject( player ) <------\
// 		\/							|
// IA_WaitToGrab()					|
//		\/							|
// IA_PlayerObject( player )		|
//		\/							|
// IA_WaitToDrop( player )			|
//		\/							|
//		 \__________________________|

//using IA = scripts\include\_interactive;

#include scripts\include\_main;
#include scripts\include\_collision;
#include scripts\include\_look;
#include scripts\include\_entity;
#include scripts\include\_physic;

private IA_PressGrabA = "Press";
private IA_PressGrabB = "to grab the object.";
private IA_PressDropA = "Press";
private IA_PressDropB = "to drop the object.";

#region Flags
/// ignoruje kolÌzie
public sealed IA_Flags_NoCollide = 1;
/// objekt je moûnÈ zobraù bez toho, aby bolo nutnÈ sa naÚ pozeraù
public sealed IA_Flags_NoLook = 2;
/// ignoruje prek·ûky pri zisùovanÌ pozerania sa na objekt
public sealed IA_Flags_NoBulletDetect = 4;
/// schov· objekt poËas pren·öania
public sealed IA_Flags_NoVisible = 8;
/// znehmotnÌ objekt poËas pren·öania
public sealed IA_Flags_NotSolid = 16;
/// nebude objekt drûaù v ruk·ch!
public sealed IA_Flags_NoHoldHands = 32;
/// neschov· hr·Ëovi zbraÚ poËas pren·öania...
public sealed IA_Flags_NoDisableWeapons = 64;
/// zhodÌ objekt na zem po hr·Ëovej smrti
public sealed IA_Flags_DropOnDeath = 128;
/// zak·ûe zobrazenie lower messages
public sealed IA_Flags_NoLowerMessages = 256;
/// zak·ûe pustenie objektu z r˙k
public sealed IA_Flags_NoDrop = 512;
/// zak·ûe zobranie objektu zo zemi
public sealed IA_Flags_NoGrab = 1024;
/// zoberie objekt bez stlaËenia kl·vesy.
public sealed IA_Flags_GrabWithoutBtn = 2048;
/// zhodÌ objekt na zem
public sealed IA_Flags_DropToGround = 4096;
#endregion

///
/// VytvorÌ nov˝ interaktÌvny objekt.
///
IA( entity )
{
	entity.IA_Flags = 0;
	
	if( !IsDefined( entity.radius ) ) entity.radius = 64;
	if( !IsDefined( entity.height ) ) entity.height = 128;
 	
	return entity;
}

IA_EnableFlag( flag )
{
	self.IA_Flags |= flag;
}
IA_DisableFlag( flag )
{
	self.IA_Flags &= ~flag;
}
/// NastavÌ parametre kolÌziÌ
IA_SetCollisions( collide, radius, height )
{
	if( IsDefined( collide ) && collide )	self IA_DisableFlag( IA_FLAGS_NOCOLLIDE );
	else if( IsDefined( collide ) )			self IA_EnableFlag( IA_FLAGS_NOCOLLIDE );
		
	if( IsDefined( radius ) )	self.radius = radius;
	if( IsDefined( height ) )	self.height = height;
}
/// NastavÌ moûnosti zisùovania pozerania sa na objekt
IA_SetDetects( bulletDetect, radius, height, playerRadius, lookMode, grabWithBtn )
{
	if( IsDefined( bulletDetect ) && bulletDetect )	self IA_DisableFlag( IA_FLAGS_NOBULLETDETECT );
	else if( IsDefined( bulletDetect ) )			self IA_EnableFlag( IA_FLAGS_NOBULLETDETECT );

	if( IsDefined( lookMode ) && lookMode )	self IA_DisableFlag( IA_FLAGS_NOLOOK );
	else if( IsDefined( lookMode ) )		self IA_EnableFlag( IA_FLAGS_NOLOOK );
		
	if( IsDefined( grabWithBtn ) && grabWithBtn )	self IA_DisableFlag( IA_FLAGS_GRABWITHOUTBTN );
	else if( IsDefined( lookMode ) )				self IA_EnableFlag( IA_FLAGS_GRABWITHOUTBTN );	
		
	if( IsDefined( radius ) ) self.IA_DetectRadius = radius;
	if( IsDefined( height ) ) self.IA_DetectHeight = height;
	if( IsDefined( playerRadius ) ) self.IA_DetectPlayerRadius = playerRadius;
}
/// NastavÌ moûnosti drûania objektu v ruk·ch.
IA_SetHold( giveToHands, distanceFromPlayer, originOffset, visible, solid, dropOnDeath, disableWeapons )
{
	if( IsDefined( giveToHands ) && giveToHands )	self IA_DisableFlag( IA_FLAGS_NOHOLDHANDS );
	else if( IsDefined( giveToHands ) ) 			self IA_EnableFlag( IA_FLAGS_NOHOLDHANDS );
	
	if( IsDefined( distanceFromPlayer ) ) 	self.IA_HoldDistance = distanceFromPlayer;
	if( IsDefined( originOffset ) ) 		self.IA_HoldOffset = originOffset;
	
	if( IsDefined( visible ) && visible )	self IA_DisableFlag( IA_FLAGS_NOVISIBLE );
	else if( IsDefined( visible ) ) 		self IA_EnableFlag( IA_FLAGS_NOVISIBLE );
	
	if( IsDefined( solid ) && solid )	self IA_DisableFlag( IA_FLAGS_NOTSOLID );
	else if( IsDefined( solid ) ) 		self IA_EnableFlag( IA_FLAGS_NOTSOLID );
	
	if( IsDefined( dropOnDeath ) && dropOnDeath )	self IA_EnableFlag( IA_FLAGS_DROPONDEATH );
	else if( IsDefined( dropOnDeath ) ) 			self IA_DisableFlag( IA_FLAGS_DROPONDEATH );
	
	if( IsDefined( disableWeapons ) && disableWeapons )	self IA_DisableFlag( IA_FLAGS_NODISABLEWEAPONS );
	else if( IsDefined( disableWeapons ) ) 				self IA_EnableFlag( IA_FLAGS_NODISABLEWEAPONS );	
}

///
/// Umiestni objekt na zem.
///
IA_GroundObject( player )
{
	if( IsDefined( player ) )
	{
		player.IA_CarryObject = undefined;
		
		if( IsAlive( player ) && player.pers["team"] != "spectator" )
		{
			if( !(self.IA_Flags & IA_FLAGS_NODISABLEWEAPONS) )
				player EnableWeapons();
		}
	}
	
	self UnLink();

	if( self.IA_Flags & IA_FLAGS_DROPTOGROUND )
	{
		offset = self.offset;
		if( !IsDefined( offset ) ) offset = ( 0,0,0 );
		
		self thread PHYSIC_DropToGround( offset[2] );
	}
	
	if( self.IA_Flags & IA_FLAGS_NOTSOLID )
		self ENT_Solid();
		
	if( self.IA_Flags & IA_FLAGS_NOVISIBLE )
		self ENT_Show();
	
	scripts\_events::RunCallback( level, "IA_placedOnGround", 1, self, player );
	scripts\_events::RunCallback( self, "IA_placedOnGround", 1, player );
		
	if( (self.IA_Flags & IA_FLAGS_NOGRAB && !IsDefined( self.AI_AlreadyUsed )) || !(self.IA_Flags & IA_FLAGS_NOGRAB) )
		self thread IA_WaitToGrab();
}
/// »ak· na zobratie objektu hr·Ëom.
IA_WaitToGrab()
{
	iprintln( "IA_WaitToGrab()" );

	self.AI_AlreadyUsed = true;
	while( IsDefined( self ) )
	{
		foreach ( player in level.players )
		{
			if( !IsDefined( player ) || !IsAlive( player ) || player.pers["team"] == "spectator" || IsDefined( player.IA_CarryObject ) )
				continue;
				
			if( self IA_IsPlayerLookAtObject( player ) )
			{
				if( self.IA_Flags & IA_FLAGS_GRABWITHOUTBTN )
				{
					self thread IA_PlayerObject( player );
					return;					
				}
				else
				{
					if( player UseButtonPressed() )
					{
						self thread IA_PlayerObject( player );
						return;
					}
					else
					{
						if( !(self.IA_Flags & IA_FLAGS_NOLOWERMESSAGES) )
							player scripts\clients\_hud::SetLowerBindableText( IA_PRESSGRABA, "+activate", IA_PRESSGRABB, 0.06 );
					}
				}
			}
		}
		wait 0.05;
	}
}

///
/// Umiestni objekt do ruky hr·Ëovi.
///
IA_PlayerObject( player )
{
	player.IA_CarryObject = self;
	
	if( !(self.IA_Flags & IA_FLAGS_NODISABLEWEAPONS) )
		player DisableWeapons();
	
	if( self.IA_Flags & IA_FLAGS_NOVISIBLE )
		self ENT_Hide();
		
	if( self.IA_Flags & IA_FLAGS_NOTSOLID )
		self ENT_NotSolid();
		
	if( !(self.IA_Flags & IA_FLAGS_NOHOLDHANDS) ) // nastaviù vzdialenosù medzi hr·Ëom a objektom
	{
		dist = self.IA_HoldDistance;
		offset = self.IA_HoldOffset;
		if( !IsDefined( dist ) ) dist = self.radius * 2;
		if( !IsDefined( offset ) ) offset = ( 0,0,0 );
		
		pPos = player.origin;
		pAngles = ( 0, player GetPlayerAngles()[1], 0 );
		
		self.origin = pPos + ( AnglesToForward( pAngles )*dist ) + offset;
	}
	
	scripts\_events::RunCallback( level, "IA_grabbedByPlayer", 1, self, player );
	scripts\_events::RunCallback( self, "IA_grabbedByPlayer", 1, player );
	
	self ENT_LinkTo( player );
	
	self thread IA_WaitToDrop( player );
}
/// »ak· na zahodenie objektu hr·Ëom.
IA_WaitToDrop( player )
{
	self.AI_AlreadyUsed = true;
	while( IsDefined( self ) )
	{
		// smrù alebo odpojenie hr·Ëa
		if( !IsDefined( player ) || !IsAlive( player ) || player.pers["team"] == "spectator" )
		{
			if( self.IA_Flags & IA_FLAGS_DROPONDEATH )
				self IA_GroundObject( player );
			else
				self IA_DestroyObject( player );
			
			return;
		}	
	
		// vedomÈ zahodenie
		if( !(self.IA_FLAGS & IA_FLAGS_NODROP) )
		{
			if( player AttackButtonPressed() )
			{
				if( self.IA_Flags & IA_FLAGS_NOCOLLIDE 
				|| ( (!(self.IA_Flags & IA_FLAGS_NOCOLLIDE)) && self IA_IsObjectInEmptySpace( player ) ) )
				{
					self IA_GroundObject( player );
					return;
				}
			}
			if( !(self.IA_Flags & IA_FLAGS_NOLOWERMESSAGES) )
				player scripts\clients\_hud::SetLowerBindableText( IA_PRESSDROPA, "+attack", IA_PRESSDROPB, 0.06 );
		}
	
		wait 0.05;
	}
	
	if( !IsDefined( self ) )
		IA_DestroyObject( player );
}

/// Zlikviduje objekt.
IA_DestroyObject( player )
{
	if( IsDefined( player ) )
	{
		player.IA_CarryObject = undefined;
		
		if( IsAlive( player ) && player.pers["team"] != "spectator" )
		{
			if( !(self.IA_Flags & IA_FLAGS_NODISABLEWEAPONS) )
				player EnableWeapons();
		}
	}
	
	scripts\_events::RunCallback( level, "IA_entityDelete", 1, self, player );
	
	if( IsDefined( self ) )
	{
		scripts\_events::RunCallback( self, "IA_entityDelete", 1, player );
	
		self UnLink();
		self ENT_Delete();
	}
}

/// ZistÌ, Ëi sa hr·Ë pozer· na objekt.
IA_IsPlayerLookAtObject( player )
{		
	detectRadius = self.IA_DetectRadius;
	detectHeight = self.IA_DetectHeight;
	if( !IsDefined( detectRadius ) ) detectRadius = self.radius;
	if( !IsDefined( detectHeight ) ) detectHeight = self.height;
	
	lookDisabled = (self.IA_Flags & IA_FLAGS_NOLOOK);
	playerDistance = self.IA_DetectPlayerRadius;
	if( !IsDefined( playerDistance ) ) playerDistance = self.radius * 2;
	
	traceDisabled = (self.IA_Flags & IA_FLAGS_NOBULLETDETECT);
		
	player LOOK_IsPlayerLookAtObject( self, detectRadius, detectHeight, playerDistance, lookDisabled, traceDisabled );
}

/// ZistÌ, Ëi objekt nie je v stene a Ëi naÚ hr·Ë vidÌ.
IA_IsObjectInEmptySpace( player )
{
	selfOrigin = self.origin;
	if( self.IA_Flags & IA_FLAGS_DROPTOGROUND )
	{
		offset = self.offset;
		if( !IsDefined( offset ) ) offset = ( 0,0,0 );
		
		trace = BulletTrace( self.origin, self.origin + (0,0,-10000), false, self );
		selfOrigin = trace["position"] + offset;
	}

	pPos = player LOOK_GetPlayerViewPos();
	trace = BulletTrace( pPos+(player LOOK_GetPlayerLookVector()*Distance(pPos, selfOrigin)), pPos, true, player );
	if( (IsDefined( trace["position"] ) && trace["position"] == pPos) || (IsDefined( trace["entity"] ) && trace["entity"] == self ) )
		trace = true;
	else 
		trace = false;
	
	if( !COLLISION_IsAnythingInCylinder( selfOrigin, self.radius, self.height, true, self )
		&& trace )
		return true;
	else
		return false;
}