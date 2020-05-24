init()
{
	PreCacheShader("damage_feedback");
	//precacheShader("damage_feedback_j");

	//level thread onPlayerConnect();
}

OnPlayerConnected()
{
	self.HUD_DamageFeedback = NewClientHudElem(self);
	self.HUD_DamageFeedback.horzAlign = "center";
	self.HUD_DamageFeedback.vertAlign = "middle";
	self.HUD_DamageFeedback.x = -12;
	self.HUD_DamageFeedback.y = -12;
	self.HUD_DamageFeedback.alpha = 0;
	self.HUD_DamageFeedback.archived = true;
	self.HUD_DamageFeedback SetShader("damage_feedback", 24, 48);
}

UpdateDamageFeedback( hitBodyArmor )
{
	self.HUD_DamageFeedback SetShader("damage_feedback", 24, 48);
	self PlayLocalSound("MP_hit_alert");
	
	self.HUD_DamageFeedback.alpha = 1;
	self.HUD_DamageFeedback FadeOverTime(1);
	self.HUD_DamageFeedback.alpha = 0;
}