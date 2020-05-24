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

init()
{
	AddMenu( "team", "team_marinesopfor" );
	AddMenu( "controls", "ingame_controls" );
	AddMenu( "options", "ingame_options" );
	//AddMenu( "options_escape", "options_escape" );
	AddMenu( "leavegame", "popup_leavegame" );
	//AddMenu( "classteam", "popup_classteam" );
	
	//AddMenu( "leavegame", "popup_leavegame" );
	
	AddMenu( "class_allies", "class_marines" );
	AddMenu( "class_axis", "class_opfor" );
	
	AddMenu( "acp", "acp" );
	//AddMenu( "TMENU", "TMENU" );
	
	AddMenu( "shop", "shop" );
	
	AddMenu( "voting", "voting" );
	
	AddMenu( "clientcmd", "clientcmd" );
	
	AddMenu( "scoreboard", "scoreboard" );

	precacheString( &"MP_HOST_ENDED_GAME" );
	precacheString( &"MP_HOST_ENDGAME_RESPONSE" );
	
	//AddCallback( level, "connected", ::CLIENT_OnMenuResponse );
}

AddMenu( string, name )
{
	game["menu_"+string] = name;
	precacheMenu( game["menu_"+string] );
}

MonitorMenuResponses()
{
	self endon("disconnect");
	
	while( true )
	{
		self waittill( "menuresponse", menu, response );
		
		self PrintDebug("menu response: "+response);
		
		if( IsDefined( response ) && response != "" )
		{
			switch( response )
			{
				case "ACP_open":
				case "c_open":
				case "help_menu_open":
				case "options_open":
				case "mapinfo_open":
				case "scoreboard_open":
				case "TMENU_open":
					self.UIactive = true;
					break;
				case "ACP_close":
				case "ACP_esc":
				case "c_close":
				case "help_menu_close":
				case "options_close":
				case "mapinfo_close":
				case "scoreboard_close":
				case "TMENU_esc":
				case "TMENU_close":
					self.UIactive = undefined;
					break;
				default:
					break;
			}
		}
		
		if( menu == game["menu_team"] )
		{
			exit = true;
			switch( response )
			{
				case "play":
					//self closeMenu();
					//self closeInGameMenu();
					self thread [[level.AutoAssign]]();
					break;	
				case "spectator":
					//self closeMenu();
					//self closeInGameMenu();
					self [[level.spectator]]();
					break;
				default:
					exit = false;
					break;
			}
			
			if( exit )
				continue;
		}
		
		if( menu == game["menu_team"] || menu == game["menu_class_allies"] || menu == game["menu_class_axis"] )
		{
			exit = true;
			switch( response )
			{
				case "c_open_allies":
					self closeMenu();
					self closeInGameMenu();
					self scripts\class\_cac::CAC_OnOpenMenu( "allies" );
					break;
				case "c_open_axis":
					self closeMenu();
					self closeInGameMenu();				
					self scripts\class\_cac::CAC_OnOpenMenu( "axis" );
					break;
				default:
					exit = false;
					break;
			}
			
			if( exit )
				continue;
		}
		
		if(menu == game["menu_quickcommands"])
		{
			scripts\clients\_quickmessages::quickcommands(response);
			continue;
		}
		else if(menu == game["menu_quickstatements"])
		{
			scripts\clients\_quickmessages::quickstatements(response);
			continue;
		}
		else if(menu == game["menu_quickresponses"])
		{
			scripts\clients\_quickmessages::quickresponses(response);
			continue;
		}
		
		if( GetSubStr( response, 0, 4 ) == "btn_" ) //nastavitelne tlacitka
		{
			switch(response)
			{	
				case "btn_acp":
					self scripts\acp\_acpMain::ACP_Open();
					break;
				case "btn_3rdperson":
					if( isdefined( self.thirdperson ) )
					{
						self setClientDvars("cg_thirdPerson", 0, "cg_thirdPersonAngle", 180 ); //off
						self.thirdperson = undefined;
						wait 0.5;
					}
					else
					{
						self setClientDvars("cg_thirdPerson", 1, "cg_thirdPersonAngle", 180 ); //on
						self.thirdperson = true;
						wait 0.5;
					}
					break;	
					
				case "btn_bot":
					//scripts\_ai::AI( level.spawns["allies"][0].origin, level.spawns["allies"][0].angles );
					//self iprintlnbold( "Bot count ^1"+level.AI_Field.size );
					break;
				default:
					scripts\_events::RunCallback( level, "onButtonPressed", 1, self, response );
					scripts\_events::RunCallback( self, "onButtonPressed", 1, response );
					break;
			}
			
			continue;
		}
		
		// call callbacks
		scripts\_events::RunCallback( level, "onMenuResponse", 1, self, menu, response );
		scripts\_events::RunCallback( self, "onMenuResponse", 1, menu, response );
		
		/*if(isdefined(response) && response != "")
		{
			if(IsSubStr(response, "open"))
			{
				string = strtok(response, ":");
				
				if(isdefined(string[0]) && string[0] == "open" && isdefined(string[1]))
				{
					self closeMenu();
					self closeInGameMenu();				
				
					self openMenu( game["menu_"+string[1]] );
				}
				
			}
		}
		*/
		/*if( response == "help_menu_open" )
		{
			if(!isdefined(self.pers["plugin_list"]))
			{
				self.pers["plugin_list"] = true;
				self thread [[level.SendCvar]](level.pluginlist);
			}
		}
		*/

		/*if ( response == "endround" && level.console )
		{
			self closeMenu();
			self closeInGameMenu();
			self iprintln( &"MP_HOST_ENDGAME_RESPONSE" );
			
			continue;
		}*/
	}
}