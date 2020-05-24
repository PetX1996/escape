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
#include scripts\include\_health;
#include scripts\include\_main;
#include scripts\include\_event;

// vöetky entity musia maù definovan˝ 'destructible_type'
// hlavnÈ entity musia maù definovan˝ 'script_health'
// vedæajöie aj hlavnÈ mÙûu maù efekty a zvuky
// volanÌm funkcie DestructibleEntity sa upravia vlastnosti entit s prÌsluön˝m 'destructible_type' stringom

// script_brushmodel, script_model, trigger_damage - main ents(script_health defined)
// other ents(script_health undefined)

// attribute name			- data type	- ent type	- default		- info

//destructible_type		- string		- all		- 'basic'		- typ zniËiteænÈho objektu(t˝mto sa identifikuje zniËiteæn˝ objekt)

//script_health 			- int 		- main		- 0				- celkovÈ zdravie, ak nie je definovanÈ, nereaguje na strelbu - definuje hlavn˙ entitu
//script_personality 		- int 		- main		- 0				- prepoËÌtavanie health podæa hr·Ëov, percento na hr·Ëa, 0-99
//script_team				- string		- main		- ''				- brush mÙûe zniËiù iba jeden z tÌmov, 'allies' 'axis'
//script_delete			- bool		- main		- 0				- zak·ûe zmazanie objektu
//script_shotcount		- bool		- main		- 0				- zak·ûe zobrazenie inform·cie o aktu·lnom healthe

//target					- string		- main		- ''				- ak m· entita definovan˝ target, zmaûe sa aj ten, mÙûe ich maù viacero - zmaû˙ sa vöetky

//script_firefx			- string		- all		- ''				- cesta k efektu, spustÌ sa po kaûdom z·sahu
//script_firefxsound		- string 	- all		- ''				- n·zov soundaliasu, spusÌ sa po kaûdom z·sahu

//script_fxid 			- string 	- all		- ''				- cesta k efektu, spustÌ sa po zniËenÌ
//script_sound 			- string 	- all		- ''				- n·zov soundaliasu, spustÌ sa po zniËenÌ

// F - force - automatickÈ prepÌsanie u vöetk˝ch entit
// D - default - ak nie je definovanÈ, pouûije sa t·to hodnota
DestructibleEntity(destructible_type, Fhealth, Dpersonality, Dteam, Ddelete, Dshotcount, Dthreshold, Dfirefx, Dfirefxsound, Dfxid, Dsound, FUNC_entityDamage, FUNC_entityDelete)
{
	if(!IsDefined(destructible_type))
	{
		PluginsError(__FILE__, __FUNCTIONFULL__, "has not any arguments");
		return;
	}
	
	if(IsDefined(Dfirefx))
		AddFXtoList(Dfirefx);

	if(IsDefined(Dfxid))
		AddFXtoList(Dfxid);
	
	info = SpawnStruct();
	info.script_health = Fhealth;
	info.script_personality = Dpersonality;
	info.script_team = Dteam;
	info.script_delete = Ddelete;
	info.script_shotcount = Dshotcount;
	info.script_threshold = Dthreshold;
	info.script_firefx = Dfirefx;
	info.script_firefxsound = Dfirefxsound;
	info.script_fxid = Dfxid;
	info.script_sound = Dsound;
	
	allEnts = GetEntArray();
	foreach(ent in allEnts)
	{
		if(IsDefined(ent.destructible_type) && ent.destructible_type == destructible_type)
		{
			if(IsDefined(ent.script_fxid))
				AddFXtoList(ent.script_fxid);
			
			if(IsDefined(ent.firefx))
				AddFXtoList(ent.firefx);
			
			if(IsDefined(ent.script_health))
			{
				if(IsDefined(Fhealth))
					ent.script_health = Fhealth;
					
				ent HEALTH(ent.script_health);
				
				if (GetOptionalVar(info.script_shotcount, ent.script_shotcount, 0))
					ent HEALTH_EnableFlag(HEALTH_FLAG_NOPROGRESS);
				
				ent HEALTH_EnableFlag(HEALTH_FLAG_NODELETE);
				
				AddCallback(ent, "HEALTH_entityDamage", ::DestructibleEntity_EntityDamage);
				AddCallback(ent, "HEALTH_entityDelete", ::DestructibleEntity_EntityDelete);
				
				if(IsDefined(FUNC_entityDamage)) AddCallback(ent, "HEALTH_entityDamage", FUNC_entityDamage);
				if(IsDefined(FUNC_entityDelete)) AddCallback(ent, "HEALTH_entityDelete", FUNC_entityDelete);
				
				ent HEALTH_Start();
			}
		}
	}
	
	if(!IsDefined(level.DESOBJ))
		level.DESOBJ = [];
	
	level.DESOBJ[destructible_type] = info;
}

DestructibleEntity_EntityDamage()
{
	info = level.DESOBJ[self.destructible_type];
	if(IsDefined(self.EntityDamage.attacker) && IsPlayer(self.EntityDamage.attacker))
	{
		pTeam = self.EntityDamage.attacker.pers["team"];
		if((IsDefined(self.script_team) && pTeam != self.script_team) || (IsDefined(info.script_team) && pTeam != info.script_team))
		{
			self.EntityDamage.iDamage = 0;
			return;
		}
	}
	
	self CheckFireFXAndSound(info, true);
	
	self CheckPersonality(info);
}

CheckFireFXAndSound(info, playOnChildren)
{
	fx = GetOptionalVar(info.script_firefx, self.script_firefx, undefined);
	sound = GetOptionalVar(info.script_firefxsound, self.script_firefxsound, undefined);
	
	self PlaySoundAndFX(sound, fx);
		
	if (!playOnChildren)
		return;
		
	targetEnts = GetEntArray(self.target, "targetname");
	foreach(targetEnt in targetEnts)
	{
		if(IsDefined(targetEnt.destructible_type))
			targetEnt CheckFireFXAndSound(info, false);
	}
}

CheckPersonality(info)
{
	personality = Int( GetOptionalVar(info.script_personality, self.script_personality, undefined) );
	
	if(!IsDefined(personality))
		return;
		
	oldHealth = self.maxHealth;
	team = GetOptionalVar(info.script_team, self.script_team, "allies");
	players = GetAllAlivePlayers(team);
	
	percentagePerPlayer = self.script_health * ( Int( personality ) / 100 );
	self.maxHealth = Int( percentagePerPlayer * players.size + self.script_health );
	
	self.health = Int((self.health * int(self.maxHealth/oldHealth * 100) )/ 100);
}

DestructibleEntity_EntityDelete()
{
	info = level.DESOBJ[self.destructible_type];
	
	self CheckFinalFXAndSound(info);

	if (IsDefined(self.target))
	{
		targetEnts = GetEntArray(self.target, "targetname");
		foreach (targetEnt in targetEnts)
		{
			if (IsDefined(targetEnt.destructible_type))
				targetEnt DeleteEntity(info);
		}
	}
	
	self DeleteEntity(info);
}

CheckFinalFXAndSound(info)
{
	fx = GetOptionalVar(info.script_fxid, self.script_fxid, undefined);
	sound = GetOptionalVar(info.script_sound, self.script_sound, undefined);
	
	self PlaySoundAndFX(sound, fx);
}

PlaySoundAndFX(sound, fx)
{
	if(IsDefined(sound))
		thread PlaySoundOnTempEnt(sound, self.origin);	
		
	if(IsDefined(fx))
		PlayFX(AddFXToList(fx), self.origin);
}

DeleteEntity(info)
{
	if(IsDefined(self))
	{
		if(!GetOptionalVar(info.script_delete, self.script_delete, 0))
			self Delete();
		else
			self HEALTH_Dispose();
	}
}

GetOptionalVar(infoVar, entVar, defaultValue)
{
	value = infoVar;
	if(IsDefined(entVar))
		value = entVar;
	if(!IsDefined(value))
		value = defaultValue;
		
	return value;
}