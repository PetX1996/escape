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

#include plugins\_include;

#include scripts\include\_main;

/* 
I==============================================================================================I
Random teleport hraca na originy

Radiant
---------------
1. vytvorte trigger_multiple alebo trigger_use_touch a dajte mu nejaky targetname
2. vytvorte script_origin a dajte mu rovnaky targetname ako triggeru, pocet originov nieje limitovany, vsetky vsak musia mat rovnaky targetname

GSC mapy
---------------
RandomPort(targetname, portfx, enterfx, exitfx, sound, playertext, globaltext)

targetname(parameter 1 - povinne): 	zadajte string, targetname vasho aktivacneho triggeru, trigger môze byt typu multiple alebo use_touch

portfx(parameter 2 - nepovinne):	efekt, ktory sa spusti na pozicii aktivacneho triggeru, zadajte cestu a nazov
enterfx(parameter 3 - nepovinne):	efekt, ktory sa spusti na pozicii aktivacneho triggeru, ked donho vlezie hrac, zadajte cestu a nazov
exitfx(parameter 4 - nepovinne):	efekt, ktory sa spusti na novej pozicii hraca po teleporte, zadajte cestu a nazov
									
sound(parameter 5 - nepovinne): 	zvuk, ktory sa spusti pri teleporte hraca			 

playertext(parameter 6 - nepovinne): text, ktory vypise na obrazovku hracovi, ktory sa teleportoval
globaltext(parameter 7 - nepovinne): text, ktory vypise na obrazovku vsetkym hracom pri teleporte

Vzor
---------------
thread plugins\_port::RandomPort("teleport_final", "impacts/flesh_hit_knife", undefined, undefined, "teleport_sound", "You teleported!", "Teleport active!");

I==============================================================================================I
*/

RandomPort(targetname, portfx, enterfx, exitfx, sound, playertext, globaltext)
{
	if(!isdefined(targetname))
		return;
		
	ent = getentarray(targetname, "targetname");

	if(!isdefined(ent) || ent.size < 2)
	{
		PluginsError("undefined object(trigger or origin): "+targetname);
		return;
	}	
	
	trig = [];
	origin = [];
	
	for(i = 0;i < ent.size;i++)
	{
		if(ent[i].classname == "trigger_multiple" || ent[i].classname == "trigger_use_touch")
			trig[trig.size] = ent[i];
		else
			origin[origin.size] = ent[i];
	}
	
	if(!isdefined(trig[0]))
	{
		PluginsError("undefined object(trigger): "+targetname);
		return;
	}
	
	if(!isdefined(origin[0]))
	{
		PluginsError("undefined object(script_origin): "+targetname);
		return;
	}	
	
	PluginInfo("RandomPort", "PetX", "0.1");
	
	if(isdefined(portfx))
		portfx = AddFXtoList(portfx);
	if(isdefined(enterfx))
		enterfx = AddFXtoList(enterfx);
	if(isdefined(exitfx))
		exitfx = AddFXtoList(exitfx);
	
	wait 1;
	
	for(i = 0;i < trig.size;i++)
	{
		if(isdefined(portfx))
			PlayFX( portfx, trig[i] );
			
		ent[i] thread RandomPortActive(origin, enterfx, exitfx, sound, playertext, globaltext);
	}
}

RandomPortActive(origin, enterfx, exitfx, sound, playertext, globaltext)
{
	while(1)
	{
		self waittill("trigger", player);
		
		if(!isdefined(player) || !isplayer(player) || !isalive(player))
			continue;
		
		if(isdefined(enterfx))
			PlayFX( enterfx, player.origin );
			
		if(isdefined(sound))
			self PlaySound( sound );
		
		final = origin[randomint(origin.size)];

		player linkto(self);
		player setorigin(final.origin);
		player setplayerangles(final.angles);
		player unlink();
		
		if(isdefined(exitfx))
			PlayFX( exitfx, player.origin );
			
		if(isdefined(playertext))
			player iprintlnbold(playertext);
			
		if(isdefined(globaltext))
			iprintlnbold(globaltext);
	}
}
