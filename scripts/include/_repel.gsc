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

REPEL_Kick( amount, direction )
{
	self.Health += amount;
	self FinishPlayerDamage( self, self, amount, 0, "MOD_PROJECTILE", "rpg_mp", self.origin, direction, "none", 0 );
}

/// scale amount of repel based on alive humans
REPEL_GetScaledAmount( strength )
{
	min = level.dvars["p_repelMin"];
	max = level.dvars["p_repelMax"];
	
	currentPlayers = GetAllAlivePlayers( "allies" ).size;
		
	minPlayers = level.dvars["p_repelEnemyMin"];
	maxPlayers = level.dvars["p_repelEnemyMax"];
	
	// calculate coeficient between 0-1
	coef = (currentPlayers - minPlayers) / (maxPlayers - minPlayers);
	if (coef < 0)
		coef = 0;
	else if (coef > 1)
		coef = 1;
		
	range = max - min;
	amount = min + (range * coef);
	
	calculated = int(amount * strength);
	
	self PrintDebug("REPEL_GetScaledAmount",
		"str", strength,
		"p", currentPlayers, 
		"min", min,
		"max", max, 
		"res", calculated);
	
	return calculated;
}

