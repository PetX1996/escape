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
#include scripts\include\_acp;

OnSelectedSection()
{
	self UpdateSelfInfo();
}

UpdateSelfInfo()
{
	self ACP_SetText( "Name: "+self.Name );
	self ACP_SetText( "B3Level: "+self.b3level );
	self ACP_SetText( "Status: "+GetB3Status( self.showme ) );
	
	if( self.b3level >= 100 )
	{
		self ACP_SetText( "RunTime: "+GetTimeFromMiliSeconds( GetTime() )+"( "+GetTime()+" )" );
		self ACP_SetText( "StartTime: "+GetTimeFromMiliSeconds( GetStartTime() )+"( "+GetStartTime()+" )" );
	}
}

HideShow()
{
	self.showme = !self.showme;
	self UpdateSelfInfo();
	self ACP_Refresh();
	
	if( self.showme == 1 )
		self ACP_SendB3Command( "sm 1" );
	else
		self ACP_SendB3Command( "sm 0" );
}