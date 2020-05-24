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

/* 
I==============================================================================================I
Zmaze brush po vami zadanej dobe

Radiant
---------------
1. vytvorte trigger_multiple alebo trigger_use_touch a dajte mu nejaky targetname
2. vytvorte brush/model/origin/trigger, stlacte ESC, oznacte trigger a potom brush/model/origin/trigger a spojte pomocou W 

GSC mapy
---------------
DeleteAfterTime(targetname, time, text, done_text)

targetname(parameter 1 - povinne): 	zadajte string, targetname vasho aktivacneho triggeru, trigger môze byt typu multiple alebo use_touch
									s triggerom spojte brush/model/origin/trigger, ktory sa po aktivacii a ubehnutia casu zmaze

time(parameter 2 - nepovinne): 		cas od aktivacie, za ktory sa brush/model/origin/trigger zmaze				 

text(parameter 3 - nepovinne): 		pri aktivacii vypise na obrazovku text
done_text(parameter 4 - nepovinne): pri dokonceni vypise na obrazovku text

Vzor
---------------
thread plugins\_delete::DeleteAfterTime("brush_delete_5", 5, "brush delete in 5 second", "brush now delete");

I==============================================================================================I
*/

DeleteAfterTime(targetname, time, text, done_text)
{
	if(!isdefined(targetname))
		return;
	
	trig = getent(targetname, "targetname");

	if(!isdefined(trig))
	{
		PluginsError(COMPILER::FilePath, COMPILER::FunctionSignature,"undefined object(trigger): "+targetname);
		return;
	}	
	
	if(!isdefined(trig.target))
	{
		PluginsError(COMPILER::FilePath, COMPILER::FunctionSignature,"undefined object(brush): "+targetname);
		return;
	}	
	
	if(!(trig.classname == "trigger_multiple" || trig.classname == "trigger_use_touch"))
	{
		PluginsError(COMPILER::FilePath, COMPILER::FunctionSignature,"trigger must be type ^1trigger_multiple ^7or ^1trigger_use_touch: "+targetname);
		return;
	}
	
	brush = getent(trig.target, "targetname");
	
	if(!isdefined(brush))
	{
		PluginsError(COMPILER::FilePath, COMPILER::FunctionSignature,"undefined object(brush): "+targetname);
		return;
	}	
	
	if(!isdefined(time))
	{
		PluginsError(COMPILER::FilePath, COMPILER::FunctionSignature,"undefined time to open, set to 0: "+targetname);
		time = 0;
	}
	
	PluginInfo("Delete after time", "PetX", "0.1");
	
	trig waittill("trigger");
	trig delete();
	
	if(isdefined(text))
		iprintlnbold(text);
		
	wait time;
	
	if(isdefined(done_text))
		iprintlnbold(done_text);
	
	brush delete();
}
