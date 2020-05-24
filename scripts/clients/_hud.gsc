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
	PreCacheShader( "notify_checkpoint" );
	PreCacheShader( "notify_spawn" );
	
	PreCacheShader( "notify_level" );
	PreCacheShader( "notify_leveldown" );
}

ShowHud()
{
	self SetClientDvar( "ui_show_hud", 1 );
}
HideHud()
{
	self SetClientDvar( "ui_show_hud", 0 );
}

// ================================================================================================================================================================================================= //	
// NOTIFY
/// Notifikácia zobrazená v hude hráča(hore v strede)
///
/// volať v podobe: "player thread scripts\_hud::AddNewNotify( shader );"
/// player - hráč, ktorému sa táto notifikácia zobrazí
/// shader - názov materiálu, ktorý sa zobrazí, nutné Precache-ovať pri štarte hry
AddNewNotify( shader )
{
	self endon( "disconnect" );

	if( !isdefined( shader ) )
		return;

	if( !isdefined( self.HUD_Notify ) )
		self CreateNotifyElem();
	
	while( isdefined( self.HUD_Notify.displayed ) )
		wait 1;
	
	self.HUD_Notify.displayed = true;
	
	self.HUD_Notify setShader( shader, 190, 80 );
	
	self.HUD_Notify MoveOverTime( 0.4 );
	self.HUD_Notify.y = 80;
	
	wait 3;
	
	self.HUD_Notify MoveOverTime( 0.4 );
	self.HUD_Notify.y = 0;
	wait 0.4;
	
	self.HUD_Notify.displayed = undefined;
}

CreateNotifyElem()
{
	self.HUD_Notify = newClientHudElem(self);				
	self.HUD_Notify.alignX = "center";
	self.HUD_Notify.alignY = "bottom";
	self.HUD_Notify.x = 320;
	self.HUD_Notify.y = 0;
	self.HUD_Notify.alpha = 1;
	self.HUD_Notify.hidewheninmenu = true;
}
// ================================================================================================================================================================================================= //	
// MAIN BARS
/// ProgressBar v hude hráča( úplne dole )
///
/// volať v podobe: "player thread scripts\_hud::UpdateBottomProgressBar( percentage );"
/// player 		- hráč, ktorému sa progress bar aktualizuje
/// percentage 	- pozícia progress baru - percentá
UpdateBottomProgressBar( percentage )
{
	if( !isdefined( percentage ) )
		return;
		
	if( percentage > 100 )
		percentage = 100;

	self.HUD_BottomProgressBar = percentage;
	self setclientdvar( "hud_progressbar_bottom", percentage );
}

/// ===================================================== ///
/// ProgressBar v hude hráča - určený k práci( nad spodným barom )
///
/// volať v podobe: "player thread scripts\_hud::UpdateTopProgressBar( percentage, color, destroyTime );"
/// player 		- hráč, ktorému sa progress bar aktualizuje
/// percentage 	- pozícia progress baru - percentá; ak je hodnota 0, progress bar sa vypne
/// color		- farba progress baru, hodnoty 0-7
/// destroyTime	- čas v sekundách, za ktorý sa bar vypne, default hodnota je 5 sekúnd
/// ===================================================== ///
UpdateTopProgressBar( percentage, color, destroyTime )
{
	if( !IsDefined( percentage ) )
		return;

	if( !IsDefined( color ) )
	{
		color = RandomInt( 8 );
		
		while( isdefined( self.HUD_TopProgressBarColor ) && color == self.HUD_TopProgressBarColor )
			color = RandomInt( 8 );
	}
	
	if( percentage > 100 )
		percentage = 100;
	
	self.HUD_TopProgressBar = percentage;
	self.HUD_TopProgressBarColor = color;
	self setclientdvars( "hud_progressbar_top", percentage, "hud_progressbar_top_color", color );
	
	if( percentage != 0 )
		self thread DestroyProgressBarOnTime( destroyTime );
}

DestroyProgressBarOnTime( destroyTime )
{
	self endon( "disconnect" );
	
	self notify( "DestroyProgressBarOnTime" );
	self endon( "DestroyProgressBarOnTime" );
	
	if( !isdefined( destroyTime ) )
		destroyTime = 5;

	wait destroyTime;
	
	self.HUD_TopProgressBar = undefined;	
	self setclientdvar( "hud_progressbar_top", 0 );
}

// ================================================================================================================================================================================================= //	
// LOWER SECTION
/// Lower text - stred obrazovky, text
///
/// volať v podobe: "player thread scripts\_hud::SetLowerText( text );"
/// player 		- hráč, ktorému sa zobrazí lower text/timer
/// text			- text, ktorý sa vypíše na obrazovke
///
/// pre odstranenie textu zavolajte funkciu bez parametrov
SetLowerText( text, timeToDestroy, ignoreDifference )
{
	if( (!IsDefined( ignoreDifference ) || !ignoreDifference) && IsDefined( self.HUD_LowerText ) && IsDefined( text ) && text == self.HUD_LowerText )
		return;

	if( !IsDefined( text ) || text == "" )
	{
		self.HUD_LowerText = undefined;
		self SetClientDvar( "hud_lower_vis", 0 );
		self notify( "SetLowerText" );
	}
	else
	{
		self.HUD_LowerText = text;
		self SetClientDvars( "hud_lower_text", text, "hud_lower_vis", 2 );
		self notify( "SetLowerText" );
		
		if( IsDefined( timeToDestroy ) )
			self thread SetLowerText_DestroyOnTime( timeToDestroy );
	}
}
SetLowerText_DestroyOnTime( time )
{
	self endon( "SetLowerText" );
	wait time;
	
	self.HUD_LowerText = undefined;
	self SetClientDvar( "hud_lower_vis", 0 );	
}
GetLowerText()
{
	if( !IsDefined( self.HUD_LowerText ) )
		return "";
		
	return self.HUD_LowerText;
}

/// Lower timer - stred obrazovky, grafické odpočítavadlo času
///
/// volať v podobe: "player thread scripts\_hud::SetLowerTimer( time, size );"
/// player 		- hráč, ktorému sa zobrazí lower text/timer
/// time			- čas, ktorý sa bude odpočítavať
/// size			- veľkosť baru, default je 150
SetLowerTimer( time, size )
{
	if( !isdefined( time ) )
	{
		self setclientdvar( "hud_lower_vis", 0 );
		return;
	}
	
	if( !isdefined( size ) )
		size = 150;
	
	self.HUD_LowerTimerStart = GetTime();
	self.HUD_LowerTimerEnd = GetTime() + (time*1000);
	
	self setclientdvars( "hud_lower_bar_size", size, "hud_lower_bar_time", time, "hud_lower_vis", 3 );
	self [[level.SendCMD]]( "setdvartotime lower_time" );
}

/// Lower text+timer
///
/// volať v podobe: "player thread scripts\_hud::SetLowerTextAndTimer( text, time, size );"
/// player	- hráč, ktorému sa zobrazí lower text/timer
/// text		- text, ktorý sa vypíše na obrazovke
/// time		- čas, ktorý sa bude odpočítavať
/// size		- veľkosť baru, default je 150
SetLowerTextAndTimer( text, time, size )
{
	if( !isdefined( text ) || !isdefined( time ) )
		return;
		
	if( !isdefined( size ) )
		size = 150;

	self.HUD_LowerText = text;
	self.HUD_LowerTimerStart = GetTime();
	self.HUD_LowerTimerEnd = GetTime() + (time*1000);	
	
	self setclientdvars( "hud_lower_text", text, "hud_lower_bar_size", size, "hud_lower_bar_time", time, "hud_lower_vis", 1 );
	self [[level.SendCMD]]( "setdvartotime lower_time" );	
}
// ================================================================================================================================================================================================= //	
// HEALTH BAR
/// HEALTH BAR
/// health - aktuálne zdravie, percento!
SetHealthBar( health )
{
	if( !IsDefined( health ) )
		return;
		
	if( health > 100 )
		health = 100;
	else if( health < 0 )
		health = 0;
		
	self SetClientDvar( "hud_health", health );
}
// ================================================================================================================================================================================================= //	
// SPECIALITY BAR
///
/// Nastaví SPECIALITY bar na určité percento
///
SetSpecialityBarPercentage( percentage )
{
	if( percentage > 100 )
		percentage = 100;
		
	if( percentage < 0 )
		percentage = 0;
		
	self SetClientDvar( "hud_specBar_P", percentage, "hud_specBar_T", 1 );
}
///
/// Nastaví SPECIALITY bar na určitý čas
///
SetSpecialityBarTime( time )
{		
	if( time < 0 )
		time = 0;
	
	self SetClientDvars( "hud_specBar_P", time, "hud_specBar_T", 2 );
	self [[level.SendCMD]]( "setdvartotime spec_time" );	
}
///
/// Schová SPECIALITY bar
///
HideSpecialityBar()
{
	self SetClientDvar( "hud_specBar_T", 0 );
}
// ================================================================================================================================================================================================= //	
// INVENTORY & PERKS
SetPerkInfo( index, material )
{
	self.HUD_BottomBarDvars["hud_Perk"+index+"M"] = material;
}

SetInventoryInfo( index, material, ammo )
{
	if( IsDefined( ammo ) && ammo == 0 )
		ammo = "^1"+ammo;
	else if( !IsDefined( ammo ) )
		ammo = "";

	if( !IsDefined( material ) && IsDefined( ammo ) )
	{
		self.HUD_BottomBarDvars["hud_Inv"+index+"T"] = ammo;
		self SetClientDvar( "hud_Inv"+index+"T", ammo );
		return;
	}
	else
	{
		self.HUD_BottomBarDvars["hud_Inv"+index+"M"] = material;	
		self.HUD_BottomBarDvars["hud_Inv"+index+"T"] = ammo;
	}
	
	if( self.reallyAlive )
		self UpdateBottomBar();
}

SetThirdPerkButtonInfo( enabled )
{
	self.HUD_BottomBarDvars["hud_Perk3BTN"] = enabled;
}

UpdateBottomBar()
{
	if( IsDefined( self.HUD_BottomBarDvars ) )
		self [[level.SendCvar]]( self.HUD_BottomBarDvars );
}

ShowShop()
{
	self SetClientDvar( "hud_shop", 1 );
}
HideShop()
{
	self SetClientDvar( "hud_shop", 0 );
}