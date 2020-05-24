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
Pohybuje s modelom/brushom/originom po vami vytvorenej trajektorii z originov
zaroven je mozne na tento objekt nalinkovat dalsie(na model brush, na brush dalsi brush, ...)

Radiant
---------------
1. vytvorte trigger_multiple alebo trigger_use_touch a dajte mu nejaky targetname
2. vytvorte brush/model/origin, môzte ich vytvorit viacero, ale vsetci musia mat rovnaky targetname
   (ako zaklady objekt, na ktory sa nalinkuju ostatne sa vzdy vyberie prvy vytvoreny, ak je medzi objektami model, tak prvy model)
3. vytvorte script_origin, stlacte ESC, oznacte jeden z vytvorenych brushov/modelov/origin a nasledne spojte s script_origin pomocou W
4. ak chcete objekt pocas pohybu otacat, urcte uhly tohto originu(v entity okne, alebo otacanim(R))
5. ak sa ma objekt pohybovat dalej, vytvorte dalsi script_origin a spojte ho s predchadzajucim, taktiez môzte urcit uhol, kam sa ma objekt natocit
6. pocet originov nieje limitovany

GSC mapy
---------------
MovingAndRotate(targetname, brush, v, time, text, done_text)

targetname(parameter 1 - povinne): 	zadajte string, targetname vasho aktivacneho triggeru, trigger môze byt typu multiple alebo use_touch

brush(parameter 2 - povinne):		zadajte string, targetname vasich brushov/modelov/originov...

v(parameter 3 - povinne):			zadajte rychlost pohybu(v palcoch za sekundu)

time(parameter 4 - nepovinne): 		cas od aktivacie, za ktory sa brush/model/origin/trigger zacne pohybovat				 

text(parameter 5 - nepovinne): 		pri aktivacii vypise na obrazovku text
done_text(parameter 6 - nepovinne): pri dokonceni vypise na obrazovku text

Vzor
---------------
thread plugins\_moving::MovingAndRotate("trap1_trig", "trap1_model", 500, 20, "start in 20 second", "start!");


UPDATE: pozit iba jeden script_brushmodel! pocet modelov nieje limitovany...
I==============================================================================================I
*/

MovingAndRotate( triggerName, brushName, velocityMin, velocityMax, time, loop, rotateType, rotateTime, text, sound )
{
	if( !isDefined( triggerName ) && !isDefined( brushName ) )
	{
		PluginsError( "MovingAndRotate() - bad function call" );
		return;
	}
	
	trigger = undefined;
	info = brushName;
	if( isDefined( triggerName ) )
	{
		info = triggerName;
	
		trigger = getEnt( triggerName, "targetname" );
		
		if( !isDefined( trigger ) )
		{
			PluginsError( "MovingAndRotate() - undefined trigger, "+info );
			return;
		}
	}
	
	if( !isDefined( brushName ) )
	{
		PluginsError( "MovingAndRotate() - undefined brush targetname" );		
		return;
	}
	
	ents = GetEntArray( brushName, "targetname" );
	if( !isDefined( ents ) || !ents.size )
	{
		PluginsError( "MovingAndRotate() - undefined brush "+brushName );		
		return;		
	}

	if( !isDefined( velocityMin ) )
		velocityMin = 100;

	if( !isDefined( velocityMax ) )
		velocityMax = 200;
		
	if( !isDefined( time ) )
		time = 0;
	
	if( !isDefined( loop ) )
		loop = false;
	
	if( !isDefined( rotateType ) )
		rotateType = 0;
	
	PluginInfo("Universal Moving System", "Escape", "0.3");
	
	c = 0;
	mainEnt = undefined;
	while( !isDefined( mainEnt ) )
	{
		classname = "script_origin";
		exit = false;
		switch( c )
		{
			case 0:
				classname = "script_brushmodel";
				break;
			case 1:
				classname = "script_model";
				break;
			default:
				mainEnt = ents[0];
				exit = true;
				break;
		}
		
		if( exit )
			break;
		
		for( i = 0;i < ents.size;i++ )
		{
			if( ents[i].classname == classname )
			{
				mainEnt = ents[i];
				break;
			}
		}
		
		c++;
	}

	for( i = 0;i < ents.size;i++ )
	{
		if( ents[i] != mainEnt )
		{
			if( ents[i].classname == "trigger_hurt" )
				ents[i] EnableLinkTo();
		
			ents[i] linkTo( mainEnt );
		}
	}
	
	startEnt = ents[0];
	for( i = 0;i < ents.size;i++ )
	{
		if( isDefined( ents[i].target ) )
			startEnt = ents[i];
	}

	ent = startEnt;
	startOrigin = startEnt.origin;
	startAngles = startEnt.angles;
	origins = [];
	for( i = 0;;i++ )
	{
		if( !isDefined( ent.target ) )
			break;
			
		ent = getEntArray( ent.target, "targetname" )[0];
		
		if( !isDefined( ent ) )
			break;
			
		if( ent == startEnt )
			break;
			
		origins[origins.size] = ent;
	}
	
	if( isDefined( trigger ) )
	{
		trigger waittill( "trigger" );
		trigger delete();
	}
	
	if( isDefined( text ) )
		iprintlnbold( text );
	
	if( isDefined( sound ) )
		mainEnt PlaySound( sound );
	
	wait time;
	
	addAngles = undefined;
	if( mainEnt.classname != "script_model" && mainEnt.classname != "script_origin" && mainEnt.classname != "script_struct" )
	{
		for( i = 0;i < ents.size;i++ )
		{
			ent = ents[i];
			
			if( ent == mainEnt )
				continue;
			
			if( ent.classname == "script_model" || ent.classname == "script_origin" || ent.classname == "script_struct" )
			{
				addAngles = ent.angles;
				break;
			}
		}
	}
	
	angles = undefined;
	c = 1;
	for( c = 0;;c++ )
	{
		if( loop )
			max = origins.size+1;
		else
			max = origins.size;
			
		for( i = 0;i < max;i++ )
		{
			if( i != origins.size )
			{
				origin = origins[i].origin;
				
				if( isDefined( origins[i].angles ) )
					angles = origins[i].angles;
				else
					angles = mainEnt.angles;
			}
			else
			{
				origin = startOrigin;
				angles = startAngles;
			}
			
			if( isDefined( addAngles ) )
				angles = ( angles[0] - addAngles[0], angles[1] - addAngles[1], angles[2] - addAngles[2] );
			
			velocity = undefined;
			if( velocityMin != velocityMax )
				velocity = RandomFloatRange( velocityMin, velocityMax );
			else
				velocity = velocityMin;
				
			t = distance( mainEnt.origin, origin )/velocity;
			
			mainEnt moveto(origin, t);

			if( rotateType == 1 )
			{
				wait (t/4)*3;
				mainEnt rotateto(angles, (t/3));
			}
			mainEnt waittill("movedone");
			
			if( rotateType == 0 )
			{
				time = undefined;
				if( isDefined( rotateTime ) )
					time = rotateTime;
				else
					time = t/3;
					
				mainEnt rotateto(angles, time);
				mainEnt waittill( "rotatedone" );
			}
		}
		
		if( !loop )
			break;
	}
	
	mainEnt.angles = angles;
	
	for( i = 0;i < origins.size;i++ )
		origins[i] delete();
		
	for( i = 0;i < ents.size;i++ )
	{
		if( ents[i] == mainEnt )
			continue;
			
		ents[i] unLink();
	}
}