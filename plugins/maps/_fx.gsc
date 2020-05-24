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

#include common_scripts\utility;
#include plugins\_include;

#include scripts\include\_main;

/* 
I==============================================================================================I
Vytvori efekt/zvuk

Radiant
---------------
1. vytvorte script_struct a dajte mu nejaky targetname

GSC mapy
---------------
AddFX( targetname, fx, type, delay, sound, start, end )

targetname(parameter 1 - povinne): 	zadajte string, targetname vasho script_struct, môze byt viac s rovnakym targetname

fx(parameter 2 - povinne):			nazov a cesta k efektu

type(parameter 3 - povinne):		zadajte typ efektu, pozitelne: "oneshot" - spusti sa iba raz, "loop" - spusta sa donekonecna

delay(parameter 4 - iba pri "loop"):rychlost opakovania efektu(pri "loop" type), v sekundach

sound(parameter 5 - nepovinne):		nazov soundaliasu

start(parameter 6 - nepovinne):		cas, za ktory sa efekt spusti(sekundy)
				
end(parameter 7 - nepovinne):		cas, za ktory sa efekt vypne(sekundy)

Vzor
---------------
thread plugins\_fx::AddFX( "fx_light", "visual/fx_light", "oneshot");

I==============================================================================================I
*/

AddFX( targetname, fx, type, delay, sound, start, end )
{
	if(!isdefined(targetname))
		return;
		
	if(!isdefined(fx))
	{
		PluginsError("undefined effect name: "+targetname);
		return;
	}
	
	ent = getstructarray(targetname, "targetname");
	
	if(!isdefined(ent) || ent.size == 0)
	{
		PluginsError("undefined object(script_struct): "+targetname);
		return;
	}	

	PluginInfo("FX system", "PetX", "0.1");
	
	fx = AddFXtoList(fx);
	
	wait 1;
	
	if(isdefined(start))
		wait start;
		
	for(i = 0;i < ent.size;i++)
	{
		ent[i] thread StartFX(fx, type, delay, sound, end);
	}
}

StartFX(fx, type, delay, sound, end)
{
	if(!isdefined(self.angles))
		self.angles = (0,0,0);

	if(type == "oneshot")
	{
		effect = spawnfx(fx, self.origin, AnglesToForward( self.angles ), AnglesToUp( self.angles ));
		triggerFX(effect);
		
		if(isdefined(sound))
			effect playsound(sound);
		
		if(isdefined(end))
		{
			wait end;		
			effect delete();
		}
	}
	else
	{
		self thread LoopFX(fx, delay, sound);
		
		if(isdefined(end))
		{
			wait end;
			self notify("done");
		}
	}
}

LoopFX(fx, delay, sound)
{
	self endon("done");
	
	while(1)
	{
		effect = spawnfx(fx, self.origin, AnglesToForward( self.angles ), AnglesToUp( self.angles ));
		triggerFX(effect);
		
		if(isdefined(sound))
			effect playsound(sound);
		
		if(isdefined(delay))
			wait delay;
		else
			wait 1;
			
		effect delete();
	}
}