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

#include scripts\include\_array;

ENT_Link( mainEnt, ents )
{
	mainEnt.ENT_LinkEnts = ents;
	for( entI = 0; entI < ents.size; entI++ )
	{
		ents[entI].ENT_LinkMainEnt = mainEnt;
	}
}

ENT_UnLink()
{
	if( IsDefined( self.ENT_LinkMainEnt ) ) // entita je jedna z nalikovaných
	{
		mainEnt = self.ENT_LinkMainEnt;
	
		mainEnt.ENT_LinkEnts = DeleteFromArray( mainEnt.ENT_LinkEnts, self );
		self.ENT_LinkMainEnt = undefined;
	
		self UnLink();	
	}
	else if( IsDefined( self.ENT_LinkEnts ) ) // je to hlavná entita!
	{
		for( entI = 0; entI < self.ENT_LinkEnts.size; entI++ )
		{
			ent = self.ENT_LinkEnts[entI];
			ent.ENT_LinkMainEnt = undefined;
			ent UnLink();
		}
		self.ENT_LinkEnts = undefined;
	}
}

ENT_LinkTo( entity )
{
	if( IsDefined( self.ENT_LinkEnts ) )
	{
		for( entI = 0; entI < self.ENT_LinkEnts.size; entI++ )
			self.ENT_LinkEnts[entI] LinkTo( self );
	}
	self LinkTo( entity );
}

ENT_Delete()
{
	if( IsDefined( self.ENT_LinkEnts ) )
	{
		for( entI = self.ENT_LinkEnts.size-1; entI >= 0; entI-- )
			self.ENT_LinkEnts[entI] Delete();
	}
	self Delete();
}

ENT_Solid()
{
	if( IsDefined( self.ENT_LinkEnts ) )
	{
		for( entI = 0; entI < self.ENT_LinkEnts.size; entI++ )
			self.ENT_LinkEnts[entI] Solid();
	}
	self Solid();
}

ENT_NotSolid()
{
	if( IsDefined( self.ENT_LinkEnts ) )
	{
		for( entI = 0; entI < self.ENT_LinkEnts.size; entI++ )
			self.ENT_LinkEnts[entI] NotSolid();
	}
	self NotSolid();
}

ENT_Hide()
{
	if( IsDefined( self.ENT_LinkEnts ) )
	{
		for( entI = 0; entI < self.ENT_LinkEnts.size; entI++ )
			self.ENT_LinkEnts[entI] Hide();
	}
	self Hide();
}

ENT_Show()
{
	if( IsDefined( self.ENT_LinkEnts ) )
	{
		for( entI = 0; entI < self.ENT_LinkEnts.size; entI++ )
			self.ENT_LinkEnts[entI] Show();
	}
	self Show();
}

ENT_RegisterPlayer( player )
{
	if( !IsDefined( self.ENT_RegisteredPlayers ) )
		self.ENT_RegisteredPlayers = [];

	self.ENT_RegisteredPlayers[self.ENT_RegisteredPlayers.size] = player;
}

ENT_IsPlayerRegister( player )
{
	if( !IsDefined( self.ENT_RegisteredPlayers ) )
		return false;
		
	foreach( reg in self.ENT_RegisteredPlayers )
	{
		if( player == reg )
			return true;
	}
	return false;
}