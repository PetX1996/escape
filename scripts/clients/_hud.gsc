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
	//PreCacheShader( "notify_checkpoint" );
	//PreCacheShader( "notify_spawn" );
	
	//PreCacheShader( "notify_level" );
	//PreCacheShader( "notify_leveldown" );
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
/*AddNewNotify( shader )
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
}*/
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

// ========================================================= //	
// LOWER

private LowerBarColor = (0, 0, 0);
private LowerBarAlpha = 0.5;

private LowerProgressBarColor = (1, 1, 1);
private LowerProgressBarAlpha = 1;

private LowerHeight = 8;

public ResetLower()
{
	self.HUD_sLowerText = undefined;
	self.HUD_iLowerTimerEnd = undefined;
	self SetClientDvars("ui_hudLowerT", "", 
		"ui_hudLowerK", "");
		
	if (IsDefined(self.HUD_LowerProgressBar))
	{
		self.HUD_LowerBar.alpha = 0;
		self.HUD_LowerProgressBar.alpha = 0;
	}
	
	self notify("SetLowerText_DestroyAfterTime");
}

public IsLowerActive()
{
	return IsDefined(self.HUD_sLowerText)
		|| (IsDefined(self.HUD_iLowerTimerEnd) && GetTime() < self.HUD_iLowerTimerEnd);
}

public SetLowerText(sText, [iTimeToDestroy], [bDontOverwrite])
{
	if (IsDefined(bDontOverwrite) 
		&& bDontOverwrite
		&& self IsLowerActive())
		return;

	self.HUD_sLowerText = sText;
	self.HUD_iLowerTimerEnd = undefined;
	self SetClientDvars("ui_hudLowerT", sText, 
		"ui_hudLowerK", "");
		
	if (IsDefined(self.HUD_LowerProgressBar))
	{
		self.HUD_LowerBar.alpha = 0;
		self.HUD_LowerProgressBar.alpha = 0;
	}
	
	self notify("SetLowerText_DestroyAfterTime");
	if (IsDefined(iTimeToDestroy))
		self thread SetLowerText_DestroyAfterTime(iTimeToDestroy);
}

public SetLowerBindableText(sPreText, sKey, sPostText, [iTimeToDestroy], [bDontOverwrite])
{
	if (IsDefined(bDontOverwrite) 
		&& bDontOverwrite
		&& self IsLowerActive())
		return;

	self.HUD_sLowerText = sPreText + sKey + sPostText;
	self.HUD_iLowerTimerEnd = undefined;
	self SetClientDvars("ui_hudLowerKT", sPreText, 
		"ui_hudLowerK", sKey, 
		"ui_hudLowerT", sPostText);
		
	if (IsDefined(self.HUD_LowerProgressBar))
	{
		self.HUD_LowerBar.alpha = 0;
		self.HUD_LowerProgressBar.alpha = 0;
	}
	
	self notify("SetLowerText_DestroyAfterTime");
	if (IsDefined(iTimeToDestroy))
		self thread SetLowerText_DestroyAfterTime(iTimeToDestroy);
}

private SetLowerText_DestroyAfterTime(iTime)
{
	self endon("disconnect");
	self endon("SetLowerText_DestroyAfterTime");
	wait iTime;
	
	self ResetLower();
}

public SetLowerTimer(iTime, [iSize], [bDontOverwrite])
{
	self SetLowerTextAndTimer("", iTime, iSize, bDontOverwrite);
}

public SetLowerTextAndTimer(sText, iTime, [iSize], [bDontOverwrite])
{
	if (IsDefined(bDontOverwrite) 
		&& bDontOverwrite
		&& self IsLowerActive())
		return;

	if (!IsDefined(iSize)) iSize = 150;
	
	self.HUD_sLowerText = sText;
	self.HUD_iLowerTimerEnd = GetTime() + (iTime * 1000);
	
	self SetClientDvars("ui_hudLowerT", sText, "ui_hudLowerK", "");
	//self C_ICCMD::Command("setdvartotime ui_hudLowerTime");
	
	
	if (!IsDefined(self.HUD_LowerProgressBar))
		self InitLowerHud();

	self.HUD_LowerBar.alpha = LowerBarAlpha;
	self.HUD_LowerBar.x = (-0.5) * iSize;
	self.HUD_LowerBar SetShader("white", iSize, LowerHeight);	
	self.HUD_LowerProgressBar.alpha = LowerProgressBarAlpha;
	self.HUD_LowerProgressBar.x = (-0.5) * iSize;
	self.HUD_LowerProgressBar SetShader("white", iSize, LowerHeight);
	self.HUD_LowerProgressBar ScaleOverTime(iTime, 0, LowerHeight);


	self notify("SetLowerText_DestroyAfterTime");
	self thread SetLowerText_DestroyAfterTime(iTime);
}

public SetLowerBindableTextAndTimer(sPreText, sKey, sPostText, iTime, [iSize], [bDontOverwrite])
{
	if (IsDefined(bDontOverwrite) 
		&& bDontOverwrite
		&& self IsLowerActive())
		return;

	if (!IsDefined(iSize)) iSize = 150;
	
	self.HUD_sLowerText = sPreText + sKey + sPostText;
	self.HUD_iLowerTimerEnd = GetTime() + (iTime * 1000);
	
	self SetClientDvars("ui_hudLowerKT", sPreText, 
		"ui_hudLowerK", sKey, 
		"ui_hudLowerT", sPostText);
	//self C_ICCMD::Command("setdvartotime ui_hudLowerTime");
	
	
	if (!IsDefined(self.HUD_LowerProgressBar))
		self InitLowerHud();

	self.HUD_LowerBar.alpha = LowerBarAlpha;
	self.HUD_LowerBar.x = (-0.5) * iSize;
	self.HUD_LowerBar SetShader("white", iSize, LowerHeight);
	self.HUD_LowerProgressBar.alpha = LowerProgressBarAlpha;
	self.HUD_LowerProgressBar.x = (-0.5) * iSize;
	self.HUD_LowerProgressBar SetShader("white", iSize, LowerHeight);
	self.HUD_LowerProgressBar ScaleOverTime(iTime, 0, LowerHeight);


	self notify("SetLowerText_DestroyAfterTime");
	self thread SetLowerText_DestroyAfterTime(iTime);
}

private InitLowerHud()
{
	self.HUD_LowerBar = NewClientHudElem(self);
	self.HUD_LowerBar.alignX = "left";
	self.HUD_LowerBar.alignY = "top";
	self.HUD_LowerBar.horzAlign = "center";
	self.HUD_LowerBar.vertAlign = "middle";
	self.HUD_LowerBar.x = 0;
	self.HUD_LowerBar.y = 100;
	self.HUD_LowerBar.sort = -2;
	self.HUD_LowerBar.color = LowerBarColor;
	self.HUD_LowerBar.alpha = 0;
	//self.HUD_LowerBar.foreground = true;
	self.HUD_LowerBar.hidewheninmenu = true;
	self.HUD_LowerBar SetShader("white", 0, LowerHeight);

	self.HUD_LowerProgressBar = NewClientHudElem(self);
	self.HUD_LowerProgressBar.alignX = "left";
	self.HUD_LowerProgressBar.alignY = "top";
	self.HUD_LowerProgressBar.horzAlign = "center";
	self.HUD_LowerProgressBar.vertAlign = "middle";
	self.HUD_LowerProgressBar.x = 0;
	self.HUD_LowerProgressBar.y = 100;
	self.HUD_LowerProgressBar.sort = -1;
	self.HUD_LowerProgressBar.color = LowerProgressBarColor;
	self.HUD_LowerProgressBar.alpha = LowerProgressBarAlpha;
	//self.HUD_LowerProgressBar.foreground = true;
	self.HUD_LowerProgressBar.hidewheninmenu = true;
	self.HUD_LowerProgressBar SetShader("white", 0, LowerHeight);
}
// ================================================================================================================================================================================================= //	


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
		
	self SetClientDvars( "hud_specBar_P", percentage, "hud_specBar_T", 1 );
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