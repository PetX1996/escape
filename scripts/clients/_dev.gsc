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

#include scripts\include\_string;
#include scripts\include\_array;
#include scripts\include\_quickVoting;

init()
{
	PreCacheModel( "bathroom_soap" );
}

PreCache()
{
	dvar = GetDvar( "scr_spawn_secondaryWeapon" );
	if( dvar != "" ) PreCacheItem( dvar );
	
	dvar = GetDvar( "scr_spawn_primaryWeapon" );
	if( dvar != "" ) PreCacheItem( dvar );
	
	dvar = GetDvar( "scr_spawn_offHand" );
	if( dvar != "" ) PreCacheItem( dvar );
	
	dvar = GetDvar( "scr_spawn_secondaryOffHand" );
	if( dvar != "" ) PreCacheItem( dvar );
	
	dvar = GetDvar( "scr_spawn_bodyModel" );
	if( dvar != "" ) PreCacheModel( dvar );
	
	dvar = GetDvar( "scr_spawn_headModel" );
	if( dvar != "" ) PreCacheModel( dvar );
	
	dvar = GetDvar( "scr_spawn_viewModel" );
	if( dvar != "" ) PreCacheModel( dvar );
}

SpawnPlayer()
{
	if( !level.dvars["developer"] )
		return;

	dvar = GetDvar( "scr_spawn_origin" );
	if( dvar != "" ) self.SpawnPlayer.origin = STR_Str2Vector( dvar );

	dvar = GetDvar( "scr_spawn_angles" );
	if( dvar != "" ) self.SpawnPlayer.angles = STR_Str2Vector( dvar );

	dvar = GetDvar( "scr_spawn_secondaryWeapon" );
	if( dvar != "" ) self.SpawnPlayer.secondaryWeapon = dvar;
	
	dvar = GetDvar( "scr_spawn_primaryWeapon" );
	if( dvar != "" ) self.SpawnPlayer.primaryWeapon = dvar;
	
	dvar = GetDvar( "scr_spawn_offHand" );
	if( dvar != "" ) self.SpawnPlayer.offHand = dvar;
	
	dvar = GetDvar( "scr_spawn_secondaryOffHand" );
	if( dvar != "" ) self.SpawnPlayer.secondaryOffHand = dvar;
	
	dvar = GetDvar( "scr_spawn_bodyModel" );
	if( dvar != "" ) self.SpawnPlayer.bodyModel = dvar;
	
	dvar = GetDvar( "scr_spawn_headModel" );
	if( dvar != "" ) self.SpawnPlayer.headModel = dvar;
	
	dvar = GetDvar( "scr_spawn_viewModel" );
	if( dvar != "" ) self.SpawnPlayer.viewModel = dvar;
	
	dvar = GetDvar( "scr_spawn_health" );
	if( dvar != "" ) self.SpawnPlayer.health = dvar;
	
	dvar = GetDvar( "scr_spawn_speed" );
	if( dvar != "" ) self.SpawnPlayer.speed = dvar;
	
	dvar = GetDvar( "scr_spawn_knifeDamage" );
	if( dvar != "" ) self.SpawnPlayer.knifeDamage = dvar;
	
	dvar = GetDvar( "scr_spawn_knifeRange" );
	if( dvar != "" ) self.SpawnPlayer.knifeRange = dvar;
	
	dvar = GetDvar( "scr_spawn_figureFunction" );
	if( dvar != "" ) self.SpawnPlayer.figureFunction = dvar;
	
	dvar = GetDvar( "scr_spawn_specialAbility" );
	if( dvar != "" ) self.SpawnPlayer.specialAbility = dvar;
	
	dvar = GetDvar( "scr_spawn_equipment" );
	if( dvar != "" ) self.SpawnPlayer.equipment = dvar;
	
	dvar = GetDvar( "scr_spawn_gear" );
	if( dvar != "" ) self.SpawnPlayer.gear = dvar;
	
	dvar = GetDvar( "scr_spawn_firstPerk" );
	if( dvar != "" ) self.SpawnPlayer.perks[0] = dvar;
	
	dvar = GetDvar( "scr_spawn_secondPerk" );
	if( dvar != "" ) self.SpawnPlayer.perks[1] = dvar;
	
	dvar = GetDvar( "scr_spawn_thirdPerk" );
	if( dvar != "" ) self.SpawnPlayer.perks[2] = dvar;
}

OnSpawnPlayer()
{
	if( !level.dvars["developer"] )
		return;
		
	thread StartFlying();
	thread GetFireVector();
}

StartFlying()
{
	self endon( "disconnect" );
	self endon( "death" );

	ent = spawn( "script_origin", self.origin );
	status = "idle";
	track = 800;
	
	while( true )
	{
		wait 0.1;
	
		if( self FragButtonPressed() )
		{
			if( status == "idle" )
			{
				ent.origin = self.origin;
				self linkto( ent );
				self DisableWeapons();
				status = "fly";
				self.flying = true;
				track = 800;
			}
		}	
		else if( status == "fly" )
		{
			status = "idle";
			self unlink();
			self EnableWeapons();
			self.flying = undefined;
		}
		
		if( self AttackButtonPressed() && status == "fly" )
		{
			if( track < 3000 )
				track += 150;
		}
		else if( track >= 1100 )
			track -= 300;
	
		if( status == "fly" )
		{
			ent.origin = self.origin;
		
			angles = self getPlayerAngles();
			origin = self.origin;
			
			vec = AnglesToForward( angles );
			new = (vec*track) + origin;
			
			ent moveto( new, 1 );
		}
	}
}

DebugEntInfo()
{
	ent = undefined;
	for(i = 0; i < 2; i++)
	{
		if(i == 0)
			ent = self;
		else
			ent = Spawn("script_origin", (1,1,1));
	
		LogPrint("==============================================\n");
		
		DebugMember("accumulate", ent.accumulate);
		DebugMember("accuracy", ent.accuracy);
		DebugMember("accuracystationarymod", ent.accuracystationarymod);
		DebugMember("allowdeath", ent.allowdeath);
		DebugMember("anglelerprate", ent.anglelerprate);
		DebugMember("angles", ent.angles);
		DebugMember("anim_pose", ent.anim_pose);
		DebugMember("animscript", ent.animscript);
		DebugMember("archivetime", ent.archivetime);
		DebugMember("attackeraccuracy", ent.attackeraccuracy);
		DebugMember("bottomarc", ent.bottomarc);
		DebugMember("bravery", ent.bravery);
		DebugMember("bulletsinclip", ent.bulletsinclip);
		DebugMember("chainfallback", ent.chainfallback);
		DebugMember("chainnode", ent.chainnode);
		DebugMember("classname", ent.classname);
		DebugMember("convergencetime", ent.convergencetime);
		DebugMember("count", ent.count);
		DebugMember("coveridleselecttime", ent.coveridleselecttime);
		DebugMember("cursorhint", ent.cursorhint);
		DebugMember("damagedir", ent.damagedir);
		DebugMember("damagelocation", ent.damagelocation);
		DebugMember("damagetaken", ent.damagetaken);
		DebugMember("damageyaw", ent.damageyaw);
		DebugMember("deaths", ent.deaths);
		DebugMember("defaultsightlatency", ent.defaultsightlatency);
		DebugMember("desiredangle", ent.desiredangle);
		DebugMember("disablearrivals", ent.disablearrivals);
		DebugMember("disableexits", ent.disableexits);
		DebugMember("dmg", ent.dmg);
		DebugMember("dontavoidplayer", ent.dontavoidplayer);
		DebugMember("dontshootwhilemoving", ent.dontshootwhilemoving);
		DebugMember("drawoncompass", ent.drawoncompass);
		DebugMember("dropweapon", ent.dropweapon);
		DebugMember("enemy", ent.enemy);
		DebugMember("favoriteenemy", ent.favoriteenemy);
		DebugMember("finished_spawning", ent.finished_spawning);
		DebugMember("fixednode", ent.fixednode);
		DebugMember("followmax", ent.followmax);
		DebugMember("followmin", ent.followmin);
		DebugMember("fovcosine", ent.fovcosine);
		DebugMember("goalradius", ent.goalradius);
		DebugMember("grenade", ent.grenade);
		DebugMember("grenadeammo", ent.grenadeammo);
		DebugMember("grenadeawareness", ent.grenadeawareness);
		DebugMember("grenadeweapon", ent.grenadeweapon);
		DebugMember("groundtype", ent.groundtype);
		DebugMember("group", ent.group);
		DebugMember("groupname", ent.groupname);
		DebugMember("hatmodel", ent.hatmodel);
		DebugMember("headicon", ent.headicon);
		DebugMember("headiconteam", ent.headiconteam);
		DebugMember("health", ent.health);
		DebugMember("hintstring", ent.hintstring);
		DebugMember("ignoreme", ent.ignoreme);
		DebugMember("interval", ent.interval);
		DebugMember("lastscriptstate", ent.lastscriptstate);
		DebugMember("leftarc", ent.leftarc);
		DebugMember("light", ent.light);
		DebugMember("lookahead", ent.lookahead);
		DebugMember("lookforward", ent.lookforward);
		DebugMember("lookright", ent.lookright);
		DebugMember("lookup", ent.lookup);
		DebugMember("maxhealth", ent.maxhealth);
		DebugMember("maxsightdistsqrd", ent.maxsightdistsqrd);
		DebugMember("members", ent.members);
		DebugMember("model", ent.model);
		DebugMember("modelscale", ent.modelscale);
		DebugMember("name", ent.name);
		DebugMember("node", ent.node);
		DebugMember("offnoise", ent.offnoise);
		DebugMember("origin", ent.origin);
		DebugMember("pacifist", ent.pacifist);
		DebugMember("pacifistwait", ent.pacifistwait);
		//DebugMember("pers", ent.pers); array
		DebugMember("personality_type", ent.personality_type);
		DebugMember("personalspace", ent.personalspace);
		DebugMember("proneok", ent.proneok);
		DebugMember("rambochance", ent.rambochance);
		DebugMember("rightarc", ent.rightarc);
		DebugMember("scalespeed", ent.scalespeed);
		DebugMember("scariness", ent.scariness);
		DebugMember("score", ent.score);
		DebugMember("scriptstate", ent.scriptstate);
		DebugMember("sessionstate", ent.sessionstate);
		DebugMember("sessionteam", ent.sessionteam);
		DebugMember("spectatorclient", ent.spectatorclient);
		DebugMember("speed", ent.speed);
		DebugMember("statechangereason", ent.statechangereason);
		DebugMember("statusicon", ent.statusicon);
		DebugMember("suppressionwait", ent.suppressionwait);
		DebugMember("takedamage", ent.takedamage);
		DebugMember("team", ent.team);
		DebugMember("teamname", ent.teamname);
		DebugMember("threatbias", ent.threatbias);
		DebugMember("threshold", ent.threshold);
		DebugMember("toparc", ent.toparc);
		DebugMember("type", ent.type);
		DebugMember("useable", ent.useable);
		DebugMember("visibilitythreshold", ent.visibilitythreshold);
		DebugMember("voice", ent.voice);
		DebugMember("walkdist", ent.walkdist);
		DebugMember("weapon", ent.weapon);
		DebugMember("weaponinfo", ent.weaponinfo);
		
		
		DebugMember("ambience_inner", ent.ambience_inner);
		DebugMember("ambience_outer", ent.ambience_outer);
		DebugMember("ambient", ent.ambient);
		DebugMember("angles", ent.angles);
		DebugMember("count", ent.count);
		DebugMember("delay", ent.delay);
		DebugMember("destructible_type", ent.destructible_type);
		DebugMember("dontdrawoncompass", ent.dontdrawoncompass);
		DebugMember("dontdropweapon", ent.dontdropweapon);
		DebugMember("export", ent.export);
		DebugMember("fixednodesaferadius", ent.fixednodesaferadius);
		DebugMember("groupname", ent.groupname);
		DebugMember("height", ent.height);
		DebugMember("name", ent.name);
		DebugMember("origin", ent.origin);
		DebugMember("radius", ent.radius);
		DebugMember("script_accel", ent.script_accel);
		DebugMember("script_accel_fraction", ent.script_accel_fraction);
		DebugMember("script_accumulate", ent.script_accumulate);
		DebugMember("script_aigroup", ent.script_aigroup);
		DebugMember("script_airspeed", ent.script_airspeed);
		DebugMember("script_allowdeath", ent.script_allowdeath);
		DebugMember("script_angles", ent.script_angles);
		DebugMember("script_anglevehicle", ent.script_anglevehicle);
		DebugMember("script_animation", ent.script_animation);
		DebugMember("script_area", ent.script_area);
		DebugMember("script_assaultnode", ent.script_assaultnode);
		DebugMember("script_attackmetype", ent.script_attackmetype);
		DebugMember("script_attackPattern", ent.script_attackPattern);
		DebugMember("script_attackspeed", ent.script_attackspeed);
		DebugMember("script_autosave", ent.script_autosave);
		DebugMember("script_autosavename", ent.script_autosavename);
		DebugMember("script_avoidplayer", ent.script_avoidplayer);
		DebugMember("script_avoidvehicles", ent.script_avoidvehicles);
		DebugMember("script_badplace", ent.script_badplace);
		DebugMember("script_balcony", ent.script_balcony);
		DebugMember("script_battlechatter", ent.script_battlechatter);
		DebugMember("script_bctrigger", ent.script_bctrigger);
		DebugMember("script_bg_offset", ent.script_bg_offset);
		DebugMember("script_bombmode_dual", ent.script_bombmode_dual);
		DebugMember("script_bombmode_original", ent.script_bombmode_original);
		DebugMember("script_bombmode_single", ent.script_bombmode_single);
		DebugMember("script_breach_id", ent.script_breach_id);
		DebugMember("script_bulletshield", ent.script_bulletshield);
		DebugMember("script_burst", ent.script_burst);
		DebugMember("script_burst_max", ent.script_burst_max);
		DebugMember("script_burst_min", ent.script_burst_min);
		DebugMember("script_chance", ent.script_chance);
		DebugMember("script_cheap", ent.script_cheap);
		DebugMember("script_cleartargetyaw", ent.script_cleartargetyaw);
		DebugMember("script_cobratarget", ent.script_cobratarget);
		DebugMember("script_color_allies", ent.script_color_allies);
		DebugMember("script_color_axis", ent.script_color_axis);
		DebugMember("script_crashtype", ent.script_crashtype);
		DebugMember("script_crashtypeoverride", ent.script_crashtypeoverride);
		DebugMember("script_damage", ent.script_damage);
		DebugMember("script_death", ent.script_death);
		DebugMember("script_death_max", ent.script_death_max);
		DebugMember("script_death_min", ent.script_death_min);
		DebugMember("script_deathchain", ent.script_deathchain);
		DebugMember("script_deathflag", ent.script_deathflag);
		DebugMember("script_deathroll", ent.script_deathroll);
		DebugMember("script_decel", ent.script_decel);
		DebugMember("script_decel_fraction", ent.script_decel_fraction);
		DebugMember("script_delay", ent.script_delay);
		DebugMember("script_delay_goto_goalmax", ent.script_delay_goto_goalmax);
		DebugMember("script_delay_goto_goalmin", ent.script_delay_goto_goalmin);
		DebugMember("script_delay_max", ent.script_delay_max);
		DebugMember("script_delay_min", ent.script_delay_min);
		DebugMember("script_delete", ent.script_delete);
		DebugMember("script_deleteai", ent.script_deleteai);
		DebugMember("script_destructable_area", ent.script_destructable_area);
		DebugMember("script_disconnectpaths", ent.script_disconnectpaths);
		DebugMember("script_displaceable", ent.script_displaceable);
		DebugMember("script_dont_link_turret", ent.script_dont_link_turret);
		DebugMember("script_dontshootwhilemoving", ent.script_dontshootwhilemoving);
		DebugMember("script_dot", ent.script_dot);
		DebugMember("script_drone", ent.script_drone);
		DebugMember("script_dronelag", ent.script_dronelag);
		DebugMember("script_drones_max", ent.script_drones_max);
		DebugMember("script_drones_min", ent.script_drones_min);
		DebugMember("script_droneStartMove", ent.script_droneStartMove);
		DebugMember("script_earthquake", ent.script_earthquake);
		DebugMember("script_emptyspawner", ent.script_emptyspawner);
		DebugMember("script_ender", ent.script_ender);
		DebugMember("script_engage", ent.script_engage);
		DebugMember("script_engageDelay", ent.script_engageDelay);
		DebugMember("script_explode", ent.script_explode);
		DebugMember("script_exploder", ent.script_exploder);
		DebugMember("script_fallback", ent.script_fallback);
		DebugMember("script_fallback_group", ent.script_fallback_group);
		DebugMember("script_falldirection", ent.script_falldirection);
		DebugMember("script_fightdist", ent.script_fightdist);
		DebugMember("script_firefx", ent.script_firefx);
		DebugMember("script_firefxdelay", ent.script_firefxdelay);
		DebugMember("script_firefxsound", ent.script_firefxsound);
		DebugMember("script_firefxtimeout", ent.script_firefxtimeout);
		DebugMember("script_fireondrones", ent.script_fireondrones);
		DebugMember("script_fixednode", ent.script_fixednode);
		DebugMember("script_flag", ent.script_flag);
		DebugMember("script_flag_false", ent.script_flag_false);
		DebugMember("script_flag_set", ent.script_flag_set);
		DebugMember("script_flag_true", ent.script_flag_true);
		DebugMember("script_flag_wait", ent.script_flag_wait);
		DebugMember("script_flakaicount", ent.script_flakaicount);
		DebugMember("script_flashbangs", ent.script_flashbangs);
		DebugMember("script_followmax", ent.script_followmax);
		DebugMember("script_followmin", ent.script_followmin);
		DebugMember("script_followmode", ent.script_followmode);
		DebugMember("script_forcecolor", ent.script_forcecolor);
		DebugMember("script_forcegoal", ent.script_forcegoal);
		DebugMember("script_forcegrenade", ent.script_forcegrenade);
		DebugMember("script_forcespawn", ent.script_forcespawn);
		DebugMember("script_forceyaw", ent.script_forceyaw);
		DebugMember("script_friendname", ent.script_friendname);
		DebugMember("script_fxcommand", ent.script_fxcommand);
		DebugMember("script_fxid", ent.script_fxid);
		DebugMember("script_fxstart", ent.script_fxstart);
		DebugMember("script_fxstop", ent.script_fxstop);
		DebugMember("script_gameobjectname", ent.script_gameobjectname);
		DebugMember("script_gametype_ctf", ent.script_gametype_ctf);
		DebugMember("script_gametype_dm", ent.script_gametype_dm);
		DebugMember("script_gametype_hq", ent.script_gametype_hq);
		DebugMember("script_gametype_sd", ent.script_gametype_sd);
		DebugMember("script_gametype_tdm", ent.script_gametype_tdm);
		DebugMember("script_gatetrigger", ent.script_gatetrigger);
		DebugMember("script_ghettotag", ent.script_ghettotag);
		DebugMember("script_goalvolume", ent.script_goalvolume);
		DebugMember("script_goalyaw", ent.script_goalyaw);
		DebugMember("script_grenades", ent.script_grenades);
		DebugMember("script_grenadespeed", ent.script_grenadespeed);
		DebugMember("script_growl", ent.script_growl);
		DebugMember("script_health", ent.script_health);
		DebugMember("script_hidden", ent.script_hidden);
		DebugMember("script_hint", ent.script_hint);
		DebugMember("script_hoverwait", ent.script_hoverwait);
		DebugMember("script_ignore_suppression", ent.script_ignore_suppression);
		DebugMember("script_ignoreme", ent.script_ignoreme);
		DebugMember("script_immunetoflash", ent.script_immunetoflash);
		DebugMember("script_increment", ent.script_increment);
		DebugMember("script_index", ent.script_index);
		DebugMember("script_keepdriver", ent.script_keepdriver);
		DebugMember("script_killspawner", ent.script_killspawner);
		DebugMember("script_killspawner_group", ent.script_killspawner_group);
		DebugMember("script_label", ent.script_label);
		DebugMember("script_landmark", ent.script_landmark);
		DebugMember("script_layer", ent.script_layer);
		DebugMember("script_light_toggle", ent.script_light_toggle);
		DebugMember("script_linkName", ent.script_linkName);
		DebugMember("script_linkTo", ent.script_linkTo);
		DebugMember("script_location", ent.script_location);
		DebugMember("script_longdeath", ent.script_longdeath);
		DebugMember("script_looping", ent.script_looping);
		DebugMember("script_mapsize_08", ent.script_mapsize_08);
		DebugMember("script_mapsize_16", ent.script_mapsize_16);
		DebugMember("script_mapsize_32", ent.script_mapsize_32);
		DebugMember("script_mapsize_64", ent.script_mapsize_64);
		DebugMember("script_maxdist", ent.script_maxdist);
		DebugMember("script_maxspawn", ent.script_maxspawn);
		DebugMember("script_mg42auto", ent.script_mg42auto);
		DebugMember("script_mg_angle", ent.script_mg_angle);
		DebugMember("script_mgturret", ent.script_mgturret);
		DebugMember("script_minspec_hooks_level", ent.script_minspec_hooks_level);
		DebugMember("script_minspec_level", ent.script_minspec_level);
		DebugMember("script_mortargroup", ent.script_mortargroup);
		DebugMember("script_moveoverride", ent.script_moveoverride);
		DebugMember("script_nodestate", ent.script_nodestate);
		DebugMember("script_noenemyinfo", ent.script_noenemyinfo);
		DebugMember("script_nofriendlywave", ent.script_nofriendlywave);
		DebugMember("script_nohealth", ent.script_nohealth);
		DebugMember("script_nomg", ent.script_nomg);
		DebugMember("script_noteworthy", ent.script_noteworthy);
		DebugMember("script_nowall", ent.script_nowall);
		DebugMember("script_objective", ent.script_objective);
		DebugMember("script_objective_active", ent.script_objective_active);
		DebugMember("script_objective_inactive", ent.script_objective_inactive);
		DebugMember("script_offradius", ent.script_offradius);
		DebugMember("script_offtime", ent.script_offtime);
		DebugMember("script_pacifist", ent.script_pacifist);
		DebugMember("script_parameters", ent.script_parameters);
		DebugMember("script_patroller", ent.script_patroller);
		DebugMember("script_personality", ent.script_personality);
		DebugMember("script_physics", ent.script_physics);
		DebugMember("script_physicsjolt", ent.script_physicsjolt);
		DebugMember("script_pilottalk", ent.script_pilottalk);
		DebugMember("script_plane", ent.script_plane);
		DebugMember("script_playerconeradius", ent.script_playerconeradius);
		DebugMember("script_playerseek", ent.script_playerseek);
		DebugMember("script_prefab_exploder", ent.script_prefab_exploder);
		DebugMember("script_presound", ent.script_presound);
		DebugMember("script_radius", ent.script_radius);
		DebugMember("script_random_killspawner", ent.script_random_killspawner);
		DebugMember("script_randomspawn", ent.script_randomspawn);
		DebugMember("script_repeat", ent.script_repeat);
		DebugMember("script_requires_player", ent.script_requires_player);
		DebugMember("script_reuse", ent.script_reuse);
		DebugMember("script_reuse_max", ent.script_reuse_max);
		DebugMember("script_reuse_min", ent.script_reuse_min);
		DebugMember("script_seekgoal", ent.script_seekgoal);
		DebugMember("script_shotcount", ent.script_shotcount);
		DebugMember("script_sightrange", ent.script_sightrange);
		DebugMember("script_skilloverride", ent.script_skilloverride);
		DebugMember("script_smokegroup", ent.script_smokegroup);
		DebugMember("script_sound", ent.script_sound);
		DebugMember("script_spawn_here", ent.script_spawn_here);
		DebugMember("script_squad", ent.script_squad);
		DebugMember("script_squadname", ent.script_squadname);
		DebugMember("script_stack", ent.script_stack);
		DebugMember("script_stance", ent.script_stance);
		DebugMember("script_start", ent.script_start);
		DebugMember("script_startinghealth", ent.script_startinghealth);
		DebugMember("script_startingposition", ent.script_startingposition);
		DebugMember("script_stealth_dontseek", ent.script_stealth_dontseek);
		DebugMember("script_stopnode", ent.script_stopnode);
		DebugMember("script_stoptoshoot", ent.script_stoptoshoot);
		DebugMember("script_suppression", ent.script_suppression);
		DebugMember("script_tankgroup", ent.script_tankgroup);
		DebugMember("script_targetoffset_z", ent.script_targetoffset_z);
		DebugMember("script_targettype", ent.script_targettype);
		DebugMember("script_team", ent.script_team);
		DebugMember("script_threatbiasgroup", ent.script_threatbiasgroup);
		DebugMember("script_threshold", ent.script_threshold);
		DebugMember("script_timeout", ent.script_timeout);
		DebugMember("script_timer", ent.script_timer);
		DebugMember("script_trace", ent.script_trace);
		DebugMember("script_trigger_group", ent.script_trigger_group);
		DebugMember("script_triggered_playerseek", ent.script_triggered_playerseek);
		DebugMember("script_triggername", ent.script_triggername);
		DebugMember("script_turningdir", ent.script_turningdir);
		DebugMember("script_turret", ent.script_turret);
		DebugMember("script_turret_ambush", ent.script_turret_ambush);
		DebugMember("script_turret_share", ent.script_turret_share);
		DebugMember("script_turretmg", ent.script_turretmg);
		DebugMember("script_unload", ent.script_unload);
		DebugMember("script_unloaddelay", ent.script_unloaddelay);
		DebugMember("script_unloadmgguy", ent.script_unloadmgguy);
		DebugMember("script_usemg42", ent.script_usemg42);
		DebugMember("script_vehicle_lights_off", ent.script_vehicle_lights_off);
		DebugMember("script_vehicle_lights_on", ent.script_vehicle_lights_on);
		DebugMember("script_vehicle_selfremove", ent.script_vehicle_selfremove);
		DebugMember("script_vehicleaianim", ent.script_vehicleaianim);
		DebugMember("script_vehicledetour", ent.script_vehicledetour);
		DebugMember("script_vehicledetourgroup", ent.script_vehicledetourgroup);
		DebugMember("script_vehicledetourtype", ent.script_vehicledetourtype);
		DebugMember("script_vehiclegroup", ent.script_vehiclegroup);
		DebugMember("script_vehicleGroupDelete", ent.script_vehicleGroupDelete);
		DebugMember("script_vehiclenodegroup", ent.script_vehiclenodegroup);
		DebugMember("script_vehicleride", ent.script_vehicleride);
		DebugMember("script_VehicleSpawngroup", ent.script_VehicleSpawngroup);
		DebugMember("script_VehicleStartMove", ent.script_VehicleStartMove);
		DebugMember("script_vehicletriggergroup", ent.script_vehicletriggergroup);
		DebugMember("script_vehiclewalk", ent.script_vehiclewalk);
		DebugMember("script_wait", ent.script_wait);
		DebugMember("script_wait_add", ent.script_wait_add);
		DebugMember("script_wait_max", ent.script_wait_max);
		DebugMember("script_wait_min", ent.script_wait_min);
		DebugMember("script_wheeldirection", ent.script_wheeldirection);
		DebugMember("script_wingman", ent.script_wingman);
		DebugMember("script_wtf", ent.script_wtf);
		DebugMember("script_yawspeed", ent.script_yawspeed);
		DebugMember("spawner_id", ent.spawner_id);
		DebugMember("spawnflags", ent.spawnflags);
		DebugMember("speed", ent.speed);
		DebugMember("squadnum", ent.squadnum);
		DebugMember("target", ent.target);
		DebugMember("targetname", ent.targetname);
		DebugMember("vehicletype", ent.vehicletype);
		DebugMember("weaponinfo", ent.weaponinfo);
		
		LogPrint("==============================================\n");
	}
}

DebugMember(memberName, member)
{
	if(IsDefined(member))
		LogPrint(memberName + "  " + member + "\n");
}

Func(i)
{
	
	IPrintLnBold("func" + ";" + i);
	return;
	
}

GetFireVector()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	deleg = ::func;
	[[deleg]]("delegate!");
	
	/*i = 0;
	str = "";
	while(true)
	{
		str += "-";
		i++;
		
		if (i % 100 == 0)
		{
			iprintlnbold("size "+str.size);
			wait 0.05;
		}
	}*/
	
	/*time = 1;
	for(i = 0; i < 10000; i++)
	{
		startTime = GetTime();
		wait time;
		LogPrint("Time " + time + " : " + ((GetTime() - startTime) / 1000) + "\n");
		time -= 0.001;
	}
	iprintln("done");
	*/

	/*obj = SpawnStruct();
	i = 0;
	obj . a = !false * GetNumber(5) + 3;
	
	( ( ( obj )  Func(0) )  Func(1) )  Func(2);
	
	address = scripts\clients\_dev::Func;
	obj [[address]](5);
	*/
	
	//IPrintLnBold();
	//self u funkcie je len posledný operand????

	/*time = [];
	for(i = 0;i < 10;i++)
	{
		array = [];
		array[0] = 0;
		array[1] = 1;
		array[2] = 2;
		array[3] = 3;
		array[4] = 4;
		array[5] = 5;
		
		LogPrint("Time0: " + GetTime() + "\n");
		startTime = GetTime();
		for(j = 0;j < 10000;j++)
		{
			if(j % 1000 == 0)
				wait 0.001;
				
			ARRAY_IndexOf(array, 5);
		}
		
		time[time.size] = GetTime()-startTime;
		LogPrint("Time1: " + GetTime() + "\n");
		wait 0.001;
	}
	average = 0;
	for(i = 0; i < time.size; i++)
		average += time[i];
		
	average /= time.size;
	
	//LogPrint("Time: " + average + "\n");
	iprintlnbold("Time: " + average);
	*/
	/*while( true )
	{			
		IPrintLnBold("Health "+self.Health);
		IPrintLnBold("MaxHealth "+self.MaxHealth);
		
		if( self UseButtonPressed() )
			self.Health -= 5;
			
		wait 0.05;
	}*/
	
	//wait 5;
	/*
	while( true )
	{
		origin = self.origin;
		wait 1;
		//self ViewKick( 127, self.origin );
		//FinishPlayerDamage( <Inflictor>, <Attacker>, <Damage>, <Damage Flags>, <Means of Death>, <Weapon>, <Direction>, <Hit Loc>, <OffsetTime> )
		self iprintln( self.origin-origin );
		
		health = 200;
		self.Health += health;
		self.Health += health;
		self.Health += health;
		self FinishPlayerDamage( self, self, health, 0, "MOD_PROJECTILE", "rpg_mp", self.origin + (0,0,1000), ( 0,0,1 ), "none", 0 );
		self FinishPlayerDamage( self, self, health, 0, "MOD_PROJECTILE", "rpg_mp", self.origin + (0,0,1000), ( 0,0,1 ), "none", 0 );
		self FinishPlayerDamage( self, self, health, 0, "MOD_PROJECTILE", "rpg_mp", self.origin + (0,0,1000), ( 0,0,1 ), "none", 0 );
	}
	*/
	/*
	ResetTimeout();
	triggers = scripts\shop\_shopSearch::CUBOID_Get( level.Spawns["allies"] );
	groups = scripts\shop\_shopSearch::SPAWNGROUPS_Get( level.Spawns["allies"] );
	while( true )
	{
		i = 0;
		foreach( group in groups )
		{
			foreach( spawn in group )
			{
				/#
				Print3d( spawn.origin+(0,0,30), "Group #"+i, (1,1,1), 1, 1, 1 );
				#/
			}
			i++;
		}
		
		foreach( trig in triggers )
		{
			scripts\dev\_highlight::HighlightCuboid( trig[0], (0,0,0), trig[1], "", "", (RandomFloat(1),RandomFloat(1),RandomFloat(1)) );
			//iprintlnbold( trig[0] + " ; " + trig[1] );
		}
		
		wait 0.05;
	}
	*/
		
	/*
	wait 5;
	while( true )
	{
		//nextXp = scripts\clients\_rank::GetXPForRank(self.pers["rank"] + 1);
		//curXp = self.pers["rankxp"];
		self [[level.giveScore]]("hack", 500);
		wait 0.5;
	}*/
	
	/*
	IPrintLnBold( 5-2 );
	
	while( true )
	{
		i = 0;
		ents = GetEntArray();
		foreach( ent in ents )
		{
			i++;
			
			if( ent == self )
				continue;
		
			if( DistanceSquared( ent.origin, self.origin ) > 1048576 )
				continue;
		
			if( IsDefined( ent.radius ) && IsDefined( ent.height ) )
				scripts\dev\_highlight::HighlightCylinder( ent.origin, ent.angles, ent.radius, ent.height, ent.className, ent.targetName, ( 0,1,0 ) );
			else
				scripts\dev\_highlight::HighlightPoint( ent.origin, ent.angles, ent.className, ent.targetName, ( 1,0,0 ) );
		}
		
		wait 0.5;
	}
	*/
	//scripts\_ai::AI( self.origin + (200,0,0), ( 0,0,0 ) );
	
	/*while( true )
	{
		angles = self GetPlayerAngles();
		origin = self GetTagOrigin( "tag_eye" );
		vec = AnglesToForward( angles );
		
		//trace = BulletTrace( origin, end, false, self );
		
		//if( IsDefined( trace["fraction"] ) )
			//self IPrintLn( "fraction: ^1"+trace["fraction"] );
		//if( IsDefined( trace["surface"] ) )
			//self IPrintLn( "surface: ^1"+trace["surface"] );
		//if( IsDefined( trace["fraction"] ) )
			self IPrintLn( "vec: ^1"+vec );
		
		wait 0.1;
	}*/
	
	//scripts\_events::DebugCallbacks( true, true );
	
	/*self SetStat( 2327, 50 );
	self SetStat( 2329, 50 );
	self SetStat( 2354, 50 );
	self SetStat( 2355, 50 );*/
	/*iprintln( "stat: 2327: "+self GetStat( 2327 ) );
	iprintln( "stat: 2329: "+self GetStat( 2329 ) );
	iprintln( "stat: 2354: "+self GetStat( 2354 ) );
	iprintln( "stat: 2355: "+self GetStat( 2355 ) );
	*/
	// koľko krát sa môže opakovať cyklus bez waitu?
	// čím viac bordelu tento cyklus obsahuje, tým menej krát sa môže opakovať
	//       100 v pohode
	//     1 000 bodka na lagometri
	//    10 000 veľká zelená palička
	//   100 000 veľká červená palička+výpadok pripojenia
	// 1 000 000 pád serveru/zlikvidovanie funkcie

	//   111 215 - zápis do logu+matematické výpočty
	//   154 763 - zápis do logu
	
	////////////////////////////////////////////////////
	// koľko je voľných dvarov na strane klienta?
	// 4096 - maximum
	// cca. 2700 - 2950 voľných
	////////////////////////////////////////////////////
	
	////////////////////////////////////////////////////////////
	// koľko premenných je možné maximálne použiť?
	////////////////////////////////////////////////////////////
	// lokálne/členské dáta
	// 125/377		- aktuálne používané
	// 64246/375	- maximum pridaním lokálnej premennej
	// 32190/32431	- maximum pridaním členských dát
	////////////////////////////////////////////////////////////
	// 65536		- maximum po spočítaní všekých premenných
	////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////
	// aká je maximálna veľkosť dvaru?
	////////////////////////////////////////////////////////////
	// cca 1000 znakov :)
	////////////////////////////////////////////////////////////
	
	
	/*
	while( true )
	{
		wait 0.1;
		
		if( !self UseButtonPressed() )
			continue;
			
		for( i = 0;i < 1000;i++ )
		{
			thread AddVariable();
		}
		
		iprintln( "index: "+i );
	}*/
	
	/*while( true )
	{
		wait 1;
	
		for(i = 0;i < 10000;)
		{
			if( self AttackButtonPressed() )
			{
				self setclientdvar( "test_dvar_"+i, RandomInt( 50 ) );	
				
				LogPrint( "index: "+i+"\n" );
				iprintln( "index: "+i );	
				i++;
			}
			
			wait 0.001;
		}
	}*/
	
	/*cylinder = AddCylinder( ( -512, 512, 0 ), 256, 100 );
	model = spawn( "script_model", ( 0,0,0 ) );
	model setModel( "fx_watermelonmeat_01" );
	//PlayFXOnTag( level.escape_fx["dev/laser"], model, "tag_origin" );
	
	while( true )
	{
		wait 0.5;
		
		origin = self GetTagOrigin( "head" );
		angles = self GetPlayerAngles();
		
		start = origin;
		end = origin+( AnglesToForward( angles )*1000 );
		
		trace = BulletTrace( start, end, false, self );
		
		model MoveTo( trace["position"], 0.001 );
		
		if( isDefined( trace["position"] ) )
		{
			if( InCylinder( cylinder, trace["position"] ) )
				self iprintln( "^3TRUE!!!" );
		}
	}*/
	/*
	cylinder = AddCylinder( ( -512, 512, 16 ), 192, 0 );
	cylinder2 = AddCylinder( ( -512, 512, 16 ), 128, 0 );
	while( true )
	{		
		wait 0.001;

		origin = GetRandomPositionInCylinder( cylinder );
		if( InCylinder( cylinder2, origin ) )
			continue;
		
		model = spawn( "script_model", origin );
		model setModel( "fx_watermelonmeat_01" );	
		
		if( GetEntArray().size >= 950 )
			break;
	
		self iprintln( "entity: ^1"+GetEntArray().size );
	}
	
	self iprintln( "limit reached!!" );
	*/
	/*model = Spawn( "script_model", self.origin );
	model SetModel( "weapon_ak47" );	
	
	list = [];
	while( true )
	{
		ents = getentarray();
		
		for(i = 0;i < ents.size;i++)
		{
			if( !InArray( list, ents[i] ) )
			{
				text = "i;^1"+i;
			
				if( isdefined( ents[i].classname ) && ents[i].classname != "" )
					text = text+"^7;classname;^1"+ents[i].classname;
					
				if( isdefined( ents[i].targetname ) && ents[i].targetname != "" )
					text = text+"^7;targetname;^1"+ents[i].targetname;
					
				if( isdefined( ents[i].model ) && ents[i].model != "" )
					text = text+"^7;model;^1"+ents[i].model;

				list[list.size] = ents[i];
				iprintln( text );
			}
		}
		
		wait 0.1;
	}*/
	
	//wait 5;
	
	//QV( "Add Bots?", 5, ::onYes );
	
	/*self SetClientDvar( "ui_show_minimap", true );
	
	while( true )
	{
		self IPrintLn("This is normal IPrintLn message.");
		self IPrintLnBold("This is normal IPrintLnBold message.");
		self SayAll( "This is player's chat message." );
		wait RandomFloatRange( 0.1, 0.5 );
	}*/
	
	/*model = Spawn( "script_model", ( 0,0,0 ) );
	model SetModel( "bathroom_soap" );
	
	lOrigin = (0,0,0);
	lAngles = (0,0,0);
		
	while( true )
	{
		Zoffset = 0;
		stance = self GetStance();
		if( stance == "stand" ) 		Zoffset = 60;
		else if( stance == "crouch" ) 	Zoffset = 40;
		else 							Zoffset = 11;
		
		origin = self.origin + (0,0,Zoffset);
		angles = self GetPlayerAngles();
	
		if( lOrigin != origin || lAngles != angles )
		{
			lOrigin = origin;
			lAngles = angles;
	
			start = origin;
			end = start + ( AnglesToForward( angles )*100000 );
			
			position = BulletTrace( start, end, false, model )["position"];
			
			model.origin = position;
		}
	
		wait 0.05;
	}*/
}

/// fsef
onYes()
{
	iprintln("YESSS!!!");
}