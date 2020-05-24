init( triggerName )
{
	trigger = GetEntArray( triggerName, "targetname" )[0];
	
	if( isDefined( trigger ) )
	{
		trigger waittill( "trigger", player );
		[[level.EndRound]]( "allies", player );
		[[level.PostEndRound]]();
	}
}