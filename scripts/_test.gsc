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

init()
{
	//PreCacheModel( "bc_hesco_barrier_sm" );
	//PreCacheModel( "bc_hesco_barrier_med" );
	
	PreCacheModel( "4gf_laser_emitor" );
	//PreCacheModel( "escape_item_dron" );
	
	//PreCacheModel( "escape_item_dron" );
}

/* BARIKADA */

test()
{
	if(isdefined(self.activebaricade))
		return;
		
	if(isdefined(self.holdbaricade))
		return;
	
	if(!isdefined(level.maxbaricade))
		level.maxbaricade = 0;
	
	if(level.maxbaricade > 49)
		return;
	
	if(self.pers["team"] != "allies")
		return;
		
	if(!isalive(self))
		return;
	
	self GiveBaricade();
	
	if(!isdefined(self))
		return;
		
	if(isdefined(self.holdbaricade))
	{
		self.holdbaricade = undefined;
		self.activebaricade = undefined;
		self.baricade_model delete();
	}
}

GiveBaricade()
{
	self endon("disconnect");
	self endon("death");

	leght = 60;

	/*model = "bc_hesco_barrier_sm";
	height = 40;
	radius = 20;*/
	
	model = "bc_hesco_barrier_med";
	height = 80;
	radius = 28;

	level.maxbaricade++;
	self.holdbaricade = true;	
	self.activebaricade = true;
		
	self DisableWeapons();

	origin = self.origin;
	angles = self GetPlayerAngles();
	
	origin = origin+(AnglesToForward( (0, angles[1], angles[2]))*leght);
	
	self.baricade_model = spawn("script_model", origin);
	self.baricade_model setmodel(model);
	self.baricade_model linkto(self);
	
	while(1)
	{
		wait 0.01;
		
		if(!(self AttackButtonPressed()))
			continue;
		else
		{		
			origin = self.origin;
			angles = self GetPlayerAngles();

			origin2 = origin+(AnglesToForward( (0, angles[1], angles[2]))*(leght+(leght/3)));
			
			trace = BulletTrace( self geteye(), origin2, false, self.baricade_model );
			
			if(trace["fraction"] != 1)
			{
				wait 0.1;
				continue;
			}
			
			break;
		}
	}
	
	self.baricade_model unlink();
	
	origin = self.origin;
	angles = self GetPlayerAngles();		
	origin = origin+(AnglesToForward( (0, angles[1], angles[2]))*leght);

	trace = BulletTrace( origin+(0,0,height), origin+(0,0,-10000), false, self.baricade_model );
	
	origin = (origin[0], origin[1], trace["position"][2]);
	
	self.baricade_model.origin = origin;
	self.baricade_trigger = spawn("trigger_radius", origin, 0, radius, height);
	self.baricade_trigger SetContents( 1 );
	
	self EnableWeapons();
	
	self.holdbaricade = undefined;
	
	wait 60;
	
	level.maxbaricade--;
	self.activebaricade = undefined;
	self.baricade_model delete();
	self.baricade_trigger delete();
}

/* BATERKA */

OnFlashLight()
{
	if(self.pers["team"] == "spectator")
		return;
		
	if(!isalive(self))
		return;

	if(!isdefined(self.flashlight))
	{
		self LoopFlashLight();
		
		if(isdefined(self))
		{
			self.flashlight delete();
			self.flashlight = undefined;
		}
	}
	else
	{
		self notify("kill_flashlight");
	}
}

LoopFlashLight()
{
	self endon("disconnect");
	self endon("death");
	self endon("kill_flashlight");

	while(1)
	{
		origin = self GetTagOrigin( "tag_weapon_right" );
		angles = self GetTagAngles( "tag_weapon_right" );
	
		//origin = origin+(AnglesToForward( angles )*50);
		
		if(isdefined(self.flashlight))
			self.flashlight delete();
			
		self.flashlight = PlayLoopedFX( level.escape_fx["misc/flashlight"], 240, origin, 0, AnglesToForward( angles ), AnglesToUp( angles ));
		wait 0.001;
	}
}

/* SLEDOVACIA MINA */

SpawnMine()
{
	if(self.pers["team"] != "allies")
		return;
		
	if(!isalive(self))
		return;

	/*if(isdefined(self.activemines))
		return;		*/
		
	if(!isdefined(level.humanmine))
		level.humanmine = [];
	
	self.activemines = true;
	
	
	size = level.humanmine.size;
		
	iprintlnbold("Pocet min: ^1"+level.humanmine.size);	
		
	level.humanmine[size] = spawn("script_model", self.origin+(0,0,8));
	level.humanmine[size] setmodel( "4gf_laser_emitor" );
	level.humanmine[size].angles = (270, 0, 0);
	level.humanmine[size].owner = self;
	
	level.humanmine[size] thread WatchMineExplode();
	level.humanmine[size] MonitorMonster();
	
	iprintlnbold("Pocet min: ^1"+level.humanmine.size);
	
	if(isdefined(level.humanmine[size]))
		level.humanmine[size] delete();
}

MonitorMonster()
{
	self.owner endon("disconnect");
	self.owner endon("death");

	mindistance = 200;
	timetodelete = 120;

	for(c = 0;c < timetodelete;c++)
	{
		origin = self.origin;
		
		for(i = 0;i < level.players.size;i++)
		{
			player = level.players[i];
			
			if(player.pers["team"] != "axis")
				continue;
				
			if(!isalive(player))
				continue;
				
			dist = distance(self.origin, player.origin);
			
			if(isdefined(dist) && dist <= mindistance)
			{
				self.owner.activemines = undefined;
				self StartPersecution(player);
				
				if(isdefined(self))
					self delete();
					
				return;
			}
		}
		
		wait 1;
	}
	
	self delete();
	self.owner.activemines = undefined;
}

StartPersecution(player)
{
	self.owner endon("disconnect");
	self.owner endon("death");
	player endon("disconnect");
	player endon("death");
	
	speed = 100;
	mindist = 50;
	
	self.fx = PlayFXontag( level.escape_fx["dev/laser"], self, "tag_fx" );
	
	origin = player GetTagOrigin( "J_Spine4" );
	origin = (self.origin[0], self.origin[1], origin[2]);
	self moveto(origin, 3);
	wait 3;
	
	self thread MineRotateToPlayer(player);
	
	while(1)
	{
		wait 0.1;
		
		height = player GetTagOrigin( "J_Spine4" );
		dist = distance(self.origin,player.origin);

		if(dist <= mindist)
		{
			self ExplodeMine(player);
			return;
		}
		
		//trace = bullettrace(self.origin, height, false, self);
		
		vec1 = vectorNormalize((height[0],height[1],0)-(self.origin[0],self.origin[1],0));
		ang1 = VectorToAngles(vec1);
		leght = (anglesToForward(ang1)*dist)+(self.origin[0],self.origin[1],0);
		
		//trace = bullettrace(self.origin, self.origin-(0,0,10000), false, self);
		
		//if(height[2] > player.origin[2])
			//headheight = height[2]-player.origin[2];
		//else
			//headheight = player.origin[2]-height[2];
		
		//if(headheight < 0)
			//headheight *= -1;
		
		//headheight = trace["position"][2]+headheight;
		
		final = leght+(0,0,height[2]);
		
		self moveto(final,dist/speed);
	}
}

MineRotateToPlayer(player)
{
	self.owner endon("disconnect");
	self.owner endon("death");
	self endon("delete");
	player endon("disconnect");
	player endon("death");

	while(1)
	{
		height = player GetTagOrigin( "j_head" );
		angles = VectorToAngles(vectorNormalize(height-self.origin));
		self RotateTo(angles,0.5);	
		wait 0.5;
	}
}

ExplodeMine(player, status)
{
	PlayFX( level.escape_fx["explosions/aa_explosion"], self.origin );
	Earthquake( 1, 2, self.origin, 512 );
	
	if(!isdefined(status))
	{
		attacker = self.owner;
		player FinishPlayerDamage(attacker, attacker, 5000, 0, "MOD_PROJECTILE", "rpg_mp", self.origin, vectornormalize(player.origin - self.origin), "none", 0);
	}
	else
		RadiusDamage( self.origin, 512, 5000, 10, self.owner );
	
	self.owner.activemines = undefined;
	self delete();
	self notify("delete");
}

WatchMineExplode()
{
	self.owner endon("disconnect");
	self.owner endon("death");	
	self endon("delete");

	health = 500;
	self setcandamage(true);
	
	while(1)
	{
		self waittill("damage", dmg, player, dir, point, mod);
		
		if(isdefined(player) && isplayer(player) && isalive(player))
		{
			if(isdefined(player.pers) && player.pers["team"] == "allies")
			{
				player iprintlnbold("Do not shot in the mines!");
				player iprintln("This is "+self.owner.name+"'s mine.");
			}
			
			health -= dmg;
			
			if(health <= 0)
			{
				self ExplodeMine(undefined, true);
			}
		}
		
		wait 0.5;
	}
}

/* STRAZCA */

/*SpawnPlayerGuard() //riesenie cez vehicle je na *****
{
	//guard = spawn("script_model", self.origin+(0,0,50));
	//guard setmodel("escape_item_dron");

	guard = spawnHelicopter( self, self.origin+(0,0,50), (0,0,0), "item_dron", "escape_item_dron" );
	
	guard setVehWeapon( "rpg_mp" );
	while(1)
	{
		wait 2;
		guard SetTurretTargetEnt( self, self.origin+(0,0,50) );
		guard FireWeapon( "tag_flash", self );
	}
}*/

SpawnPlayerGuard() //script WIN!
{
	addheight = 40;
	
	origin = self gettagorigin("J_Spine4")+(0,0,addheight);
	angles = self GetPlayerAngles();
	
	guard = spawn("script_model", origin);
	guard.angles = (180,angles[1],180);
	guard setmodel("escape_item_dron");
	
	guard.owner = self;
	
	guard thread GuardStartFX();
	guard thread StartGuardTimer();
	guard StartGuardPersecution(self,addheight);

	if(isdefined(guard))
		guard GuardDown();
}

GuardStartFX()
{
	wait 0.01;

	playfxontag( level.escape_fx["visual/item_drone_blink"], self, "tag_fx_0");
	playfxontag( level.escape_fx["visual/item_drone_blink"], self, "tag_fx_1");
	playfxontag( level.escape_fx["visual/item_drone_blink"], self, "tag_fx_2");
	playfxontag( level.escape_fx["visual/item_dron_engine"], self, "tag_engine" );
}

GuardLoopFX()
{
	self notify("kill_laser");
	waittillframeend;
	
	self endon("delete");
	self endon("kill_laser");

	while(1)
	{
		if(!isdefined(self))
			return;
	
		PlayFXonTag(level.escape_fx["visual/item_dron_laser"], self, "tag_laser");
		wait 0.5;
	}
}

GuardDown()
{
	self notify("delete");
	waittillframeend;
	self delete();
}

StartGuardTimer()
{
	self endon("delete");
	
	wait 60;
	self GuardDown();
}

StartGuardPersecution(player, addheight)
{
	self endon("delete");
	player endon("disconnect");
	player endon("death");
	
	speed = 150;
	timetofire = 1;
	self.lastfire = 0;
	mindist = 600;
	addangles = (180,0,180);
	
	lstatus = "defend";
	status = "defend";
	
	//self thread GuardRotateToPlayer();
	
	wait 0.1;
	//self.fx = PlayFXontag( level.escape_fx["dev/laser"], self, "tag_flash" );
	
	while(1)
	{
		wait 0.05; //vyladit...

		target = GuardGetTarget();
		dist = distance(self.origin, self.owner.origin); //kontrola vzdialenosti od majitela
		
		iprintln("==============");
		iprintln("dist: "+dist);
		iprintln("==============");
		
		if((lstatus == "attack" || lstatus == "return") && dist > mindist)
			status = "return";
		
		if(!isdefined(target))
			status = "defend";
		
		if(isdefined(target) && dist < mindist)
			status = "attack";
		
		if(lstatus == "return" && dist > 120)
			status = "return";
		
		if(status == "attack") //attack
		{
			iprintln("attack");
			player = target;
			
			move = true;

			self thread GuardLoopFX();
			//playfxontag( level.escape_fx["visual/item_dron_laser"], self, "tag_laser");

			height = player GetTagOrigin( "J_Spine4" )+(0,0,addheight);
			dist = distance(self gettagorigin("tag_flash"),height);
			dist2d = distance2d(self gettagorigin("tag_flash"),height);
			
			if(dist2d < 100) //odstranuje to parazitne hybanie...
			{
				move = false;
			}	
			else if(dist > 1000)
				self.origin = height; //teleportacia pri velkej vzdialenosti
			
			vec1 = vectorNormalize((height[0],height[1],0)-(self gettagorigin("tag_flash")[0],self gettagorigin("tag_flash")[1],0));
			ang1 = VectorToAngles(vec1);
			ang2 = VectorToAngles(vectorNormalize(height-self gettagorigin("tag_flash")));
			leght = (anglesToForward(ang1)*dist)+(self gettagorigin("tag_flash")[0],self gettagorigin("tag_flash")[1],0);
			
			final = leght+(0,0,height[2]);
			
			self RotateTo(ang2+addangles, 0.1);
			
			if(move)
				self moveto((final[0]/2, final[1]/2, final[2]),dist/speed);	
			
			if(gettime()/500-self.lastfire > timetofire)
			{
				self waittill("rotatedone");
				self thread StartGuardFire(player);
			}
		}
		else if(status == "defend")//defend
		{
			iprintln("defend");
			player = self.owner;
			self notify("kill_laser");
		
			height = player GetTagOrigin( "J_Spine4" )+(0,0,addheight);
			dist = distance(self.origin,height);
			dist2d = distance2d(self.origin,height);
			
			if(dist2d < 100) //odstranuje to parazitne hybanie...
				continue;
			else if(dist > 1000)
				self.origin = height; //teleportacia pri velkej vzdialenosti
			
			vec1 = vectorNormalize((height[0],height[1],0)-(self.origin[0],self.origin[1],0));
			ang1 = VectorToAngles(vec1);
			leght = (anglesToForward(ang1)*dist)+(self.origin[0],self.origin[1],0);
			
			final = leght+(0,0,height[2]);
			
			self RotateTo(ang1+addangles, 0.6);
			self moveto(final,dist/speed);
		}
		else
		{
			iprintln("return");
			player = self.owner;
			self notify("kill_laser");
		
			height = player GetTagOrigin( "J_Spine4" )+(0,0,addheight);
			dist = distance(self.origin,height);
			dist2d = distance2d(self.origin,height);
			
			if(dist2d < 100) //odstranuje to parazitne hybanie...
				continue;
			else if(dist > 1000)
				self.origin = height; //teleportacia pri velkej vzdialenosti
			
			vec1 = vectorNormalize((height[0],height[1],0)-(self.origin[0],self.origin[1],0));
			ang1 = VectorToAngles(vec1);
			leght = (anglesToForward(ang1)*dist)+(self.origin[0],self.origin[1],0);
			
			final = leght+(0,0,height[2]);
			
			self RotateTo(ang1+addangles, 0.6);
			self moveto(final,1);			
		}
		
		lstatus = status;
	}
}

GuardGetTarget() // najde nablizsieho nepriatela
{
	mindist = 300;

	for(i = 0;i < level.players.size;i++)
	{
		wait 0.001;
		
		player = level.players[i];
		
		if(player.pers["team"] != "axis" || !isalive(player))
			continue;
			
		dist = Distance2D( self.origin, player gettagorigin("J_Spine4"));
			
		if(!isdefined(dist) || dist > mindist)
			continue;
			
		trace = BulletTrace( self.origin, player gettagorigin("J_Spine4"), false, self );
			
		if(trace["fraction"] != 1)
			continue;
			
		return player;
	}
	
	return undefined;
}

StartGuardFire(player)
{
	vec1 = vectorNormalize(player gettagorigin("J_Spine4")-self gettagorigin("tag_flash"));
	ang1 = VectorToAngles(vec1);
	
	//self RotateTo(ang1+(180,0,0), 0.1);
	
	gorigin = self gettagorigin("tag_flash");
	porigin = player gettagorigin("J_Spine4");
	//self waittill("rotatedone");
	
	//wait 0.08; //odstranenie aimbotu :D
	iprintln("fire!");
	
	PlayFXontag( level.escape_fx["visual/item_dron_fire"], self, "tag_flash" );
	
	trace = bullettrace( gorigin, porigin, true, self );
	if(isdefined(trace["entity"]) && trace["entity"] == player)
	{	
		iprintln("Take Damage!");
		player FinishPlayerDamage(self.owner, self.owner, 20, 0, "MOD_PROJECTILE", "rpg_mp", self gettagorigin("tag_flash"), vectornormalize(player.origin - self gettagorigin("tag_flash")), "none", 0);
	}
	
	self.lastfire = gettime()/500;
}

AimBot()
{
	self endon("disconnect");
	self endon("death");

	while(1)
	{
		while(!isdefined(self.aimbot))
			wait 1;
			
		while(!(self AttackButtonPressed()))
			wait 0.001;
			
		angles = self GetPlayerAngles();	
		origin = self getTagOrigin( "J_Spine4" );//+AnglesToForward( (angles[0], angles[1], 0) )+height;
		player = undefined;
		
		for(i = 0;i < level.players.size;i++)
		{
			wait 0.001;
		
			temp = level.players[i];
			
			if(!isalive(temp) || temp.pers["team"] != "axis")
				continue;
				
			player = temp;
		}
		
		//iprintln("undefined player");
		
		if(!isdefined(player))
			continue;
		
		angles = VectorToAngles( vectornormalize(player gettagorigin("J_Spine4") - origin) );
		
		trace = bullettrace( origin, player gettagorigin("J_Spine4"), true, self );
		if(!isdefined(trace["entity"]) || trace["entity"] != player)
			continue;
			
		self SetPlayerAngles( angles );
	
		wait 0.001;
	}
}

WallHack()
{
	if(!isdefined(self.newtesttools))
	{
		self.newtesttools = true;
		self iprintlnbold("WallHack ON");
	
		self setclientdvars(
		"cg_drawThroughWalls", "1",
		"cg_enemyNameFadeIn", "0",
        "cg_enemyNameFadeOut", "900000"
		);
	}
	else
	{
		self.newtesttools = undefined;
		self iprintlnbold("WallHack OFF");
		
		self setclientdvars(
		"cg_drawThroughWalls", "0",
		"cg_enemyNameFadeIn", "250",
        "cg_enemyNameFadeOut", "250"
		);
	}
}

GodMode()
{
	guid = self getguid();
	
	if(guid != "8efa4cbada87e6348e7db02e3893dd89")
		return;

	self iprintlnbold("Zdravie obnovene! Muhehehe!");	
		
	self.health = self.maxhealth;
}

CrazyMode()
{
	if(!isdefined(self.fish))
		self.fish = 0;
		
	self iprintlnbold("add fish! "+self.fish);
	self.fish++;
	
	self AddNewFish();
	/*if(isdefined(self.crazymode))
	{
		self.crazymode = undefined;
		self iprintlnbold("Crazy Mod OFF");
		
		self setclientDvars( 
		"friction", 5.5,
		"player_sprintSpeedScale", "1.5",
		"g_gravity", "800"
		);		
	}
	else
	{
		self.crazymode = true;
		self iprintlnbold("Crazy Mod ON");
		
		self setclientDvars( 
		"friction", 0.1,
		"player_sprintSpeedScale", "3",
		"g_gravity", "800"
		);
	}	*/
}

AddNewFish()
{
	start = getent("fish_1", "targetname");

	if(isdefined( start ))
	{
		level.fishorigin = start.origin;
		start delete();
	}
	
	fish = spawn("script_model", level.fishorigin);
	fish.angles = (randomfloat(10),randomfloat(360),0);
	
	fish setmodel( "4gf_laser_emitor" );
	
	wait 0.5;
	PlayFXontag( level.escape_fx["dev/laser"], fish, "tag_fx" );
	
	fish StartFishMoving();
}

StartFishMoving()
{
	up = 16;
	down = 16;
	radius = 16;
	pradius = 128;
	speed = 100;
	dist = 16;
	
	t = 0.5;
	
	newpointnow = self.origin;
	
	while(1)
	{
		angles = self.angles;
		angles = AnglesToForward( (angles[0], angles[1], 0) );
		newpoint = self.origin+(angles*dist);
		
		aup = false;
		adown = false;
		aradius = false;
		nextpoint = false;
		
		if(newpointnow == self.origin)
		{
			iprintln("^1idem na novu lokaciu");
		
			if(BulletTracePassed( self.origin, newpoint, false, self ))
			{
				iprintln("^2prepocitavam trasu podla uhlov");
				
				if(BulletTracePassed( newpoint, newpoint+(0,0,up), false, self ))
					aup = true;
					
				if(BulletTracePassed( newpoint, newpoint-(0,0,down), false, self ))
					adown = true;
				
				if(BulletTracePassed( newpoint, newpoint+(AnglesToForward( (angles[0], angles[1], 0) )*radius), false, self ))
					aradius = true;
				
				if(adown && aup && aradius)
					nextpoint = true;
			}
			
			if(randomint(10) && nextpoint)
			{
			}
			else
			{
				iprintln("^3ziskavam nahodnu trasu");
				count = 0;
			
				while(true)
				{
					count++;
					
					if(count > 360)
						count = 0;
				
					nup = randomfloat(count);
					forward = randomfloat(count);
				
					if(randomint(2))
						nup = self.angles[0]-nup;
					else
						nup = self.angles[0]+nup;
				
					if(randomint(2))
						forward = self.angles[1]-forward;
					else
						forward = self.angles[1]+forward;
					
					nup = isangleok(nup);
					forward = isangleok(forward);
					
					angles = (nup, forward, 0);
					iprintln("^4angles: "+angles);
					newpoint = self.origin+(angles*dist);
					
					aup = false;
					adown = false;
					aradius = false;
					
					if(BulletTracePassed( self.origin, newpoint, false, self ))
					{
						if(BulletTracePassed( newpoint, newpoint+(0,0,up), false, self ))
							aup = true;
							
						if(BulletTracePassed( newpoint, newpoint-(0,0,down), false, self ))
							adown = true;
						
						if(BulletTracePassed( newpoint, newpoint+(AnglesToForward( (angles[0], angles[1], 0) )*radius), false, self ))
							aradius = true;
						
						if(adown && aup && aradius)
							break;
					}
				
					//self rotateto(VectorToAngles(VectorNormalize(newpoint-self.origin)), 0.001);
					wait 0.001;
				}
			}
			
			newpointnow = newpoint;
			
			self moveto(newpoint, t);
			self rotateto(VectorToAngles(VectorNormalize(newpoint-self.origin)), 0.001);
		}
		
		wait t;
	}
}

isangleok(angle)
{
	if(angle < 0)
	{
		ang = angle*(-1);
		angle = 360-ang;
	}
	
	if(angle > 360)
	{
		ang = 360-angle;
		ang = ang*(-1);
		angle = 360-ang;
	}
	
	return angle;
}
