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

#include scripts\include\_shape;

Init()
{
}

EnableShop()
{
	level.SHOP_Allowed = true;
}
DisableShop()
{
	level.SHOP_Allowed = undefined;
}

SearchTriggers()
{
	triggers = GetEntArray( "escape_shop", "targetname" );
	cuboids = [];
	if( triggers.size == 0 )
	{
		cuboids = scripts\shop\_shopSearch::CUBOID_Get( level.Spawns["allies"] );
	}
	
	thread MonitorTouching( triggers, cuboids );
	
	EnableShop();
}

MonitorTouching( triggers, cuboids )
{
	while( true )
	{
		wait 0.1;
	
		if( !IsDefined( level.SHOP_Allowed ) )
			continue;
	
		foreach( player in level.players )
		{
			if( !IsAlive( player ) || player.pers["team"] != "allies" )
				continue;
		
			lastState = player.SHOP_TouchingShop;
			player.SHOP_TouchingShop = undefined;
			nextPlayer = false;
		
			while( true )
			{
				foreach( trig in triggers )
				{
					if( player IsTouching( trig ) )
					{
						TouchingShop( player );
						nextPlayer = true;
						break;
					}
				}
				
				if( nextPlayer )
					break;
			
				foreach( cuboid in cuboids )
				{
					if( SHAPE_IsPointInCuboid( cuboid[0], cuboid[1], player.origin+(0,0,16) ) )
					{
						TouchingShop( player );
						break;
					}
				}
				
				break;
			}
			
			if( IsDefined( player.SHOP_TouchingShop ) && !IsDefined( lastState ) )
				player scripts\clients\_hud::ShowShop();
			else if( !IsDefined( player.SHOP_TouchingShop ) && IsDefined( lastState ) )
				player scripts\clients\_hud::HideShop();
		}
	}
}

TouchingShop( player )
{
	player.SHOP_TouchingShop = true;
	//player iprintln( "shop" );
	
	CheckOpening( player );
}

CheckOpening( player )
{
	if( !IsDefined( player.SHOP ) && player UseButtonPressed() )
		player scripts\shop\_shopMenu::OpenShop();	
}
