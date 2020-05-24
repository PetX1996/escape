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

/// GetTeamString( team )
/// GetStatusString( alive, team )
/// GetMapName( map )
/// GetTimeFromSeconds( seconds )
/// IndexOf( sourceString, token, startIndex )
/// StringRemove( sourceString, startIndex, length )
/// StringRemoveStr( sourceString, removeString )
/// StringToFloat( sourceString )
/// TextAutoWrapped( text, charsPerLine )
/// STR_Replace( string, fromStr, toStr )
/// STR_MinutesToTime( minutes, completeFormat )

GetTeamString( team )
{
	switch( team )
	{
		case "allies":
			return "Humans";
		case "axis":
			return "Monsters";
		case "spectator":
			return "Spectator";
		default:
			return "Unknown";
	}
}

GetStatusString( alive, team )
{
	if( team == "spectator" )
		return "Spectating";
		
	if( alive )
		return "Playing";
	else
		return "Death";
		
	return "Unknown";
}

GetB3Status( status )
{
	if( !status )
		return "^1Hidden";
	else
		return "Visible";
		
	return "Unknown";
}

GetTimeFromMiliSeconds( miliseconds )
{
	days = Int( miliseconds / 86400000 );
	daysR = miliseconds % 86400000;
	hours = Int( daysR / 3600000 );
	hoursR = daysR % 3600000;
	minutes = Int( hoursR / 60000 );
	minutesR = hoursR % 60000;
	seconds = Int( minutesR / 1000 );
	secondsR = minutesR % 1000;
	miliseconds = Int( secondsR );
	
	return days+"days | "+hours+"hours | "+minutes+"minutes | "+seconds+"seconds | "+miliseconds+"miliseconds";
}

IndexOf( sourceString, token, startIndex )
{
	if( !IsDefined( startIndex ) )
		startIndex = 0;
	
	max = sourceString.size - token.size;
	
	for( i = startIndex;i < max + 1;i++)
	{
		end = i + token.size;
		part = GetSubStr( sourceString, i, end );
		
		if( part == token )
			return i;
	}
	
	return -1;
}

StringRemove( sourceString, startIndex, length )
{
	strLength = sourceString.size;
	
	start = "";
	end = "";
	
	if( startIndex != 0 )
		start = GetSubStr( sourceString, 0, startIndex );
		
	if( startIndex + length < strLength )
		end = GetSubStr( sourceString, startIndex + length, strLength );
		
	return start + end;
}

StringRemoveStr( sourceString, removeString )
{
	str = "";
	toks = StrTok( sourceString, removeString );
	
	for( i = 0; i < toks.size; i++ )
		str += toks[i];
		
	return str;
}

StringToFloat( sourceString )
{
	index = IndexOf( sourceString, "." );
	
	if( index == -1 )
		return Int( sourceString );
		
	intPart = GetSubStr( sourceString, 0, index );
	floatPart = GetSubStr( sourceString, (index + 1), sourceString.size );
	
	if( intPart == "" || floatPart == "" )
		return int( sourceString );
		
	floatPartChars = floatPart;
	divisor = "1";
	for( i = 0;i < floatPartChars.size;i++)
		divisor += "0";
	
	floatNumber = int( floatPart ) / int( divisor );
	intNumber = int( intPart );
	
	return intNumber + floatNumber;
}

TextAutoWrapped( text, charsPerLine )
{
	lines = [];

	linesIndex = 0;
	
	while( text != "" )
	{
		index = TextAutoWrapped_ProcessText( text, charsPerLine );
		
		line = GetSubStr( text, 0, index );
		text = StringRemove( text, 0, index );
		
		line = StringRemoveStr( line, "\n" );
		
		lines[linesIndex] = line;
		linesIndex++;
	}
	
	return lines;
}

TextAutoWrapped_ProcessText( text, charsPerLine )
{
	index = 0;
	line = "";
	
	while( index < text.size )
	{
		line += text[index];
		index++;
		
		if( IsSubStr( line, "\n" ) )
			return index;
		
		if( index > charsPerLine )
		{
			spaceIndex = TextAutoWrapped_GetLastSpaceIndex( line );
			
			if( spaceIndex == -1 )
				return index;
			else
				return spaceIndex + 1;
		}
	}
	
	return index;
}

TextAutoWrapped_GetLastSpaceIndex( text )
{
	for( i = text.size - 1; i >= 0; i-- )
	{
		if( text[i] == " " )
			return i;
	}
	
	return -1;
}

STR_Replace( string, fromStr, toStr )
{
	toks = StrTok( string, fromStr );
	string = "";
	
	for( i = 0; i < toks.size; i++ )
	{
		if( i != toks.size-1 )
			string += toks[i] + toStr;
		else
			string += toks[i];
	}
	
	return string;
}

///
/// Konvertuje minúty na formát  %d"d" %h"h" %m"m"
///
STR_MinutesToTime( minutes, completeFormat )
{
	daysFloat = (minutes / 60) / 24;
	daysInt = int( daysFloat );
	
	hoursFloat = (daysFloat - daysInt) * 24;
	hoursInt = int( hoursFloat );
	
	minutesFloat = (hoursFloat - hoursInt) * 60;
	minutesInt = int( minutesFloat );
	
	if( IsDefined( completeFormat ) && completeFormat )
		return daysInt+"d "+hoursInt+"h "+minutesInt+"m";
	else
	{
		timeFormat = "";
		if( daysInt != 0 )
		{
			timeFormat += daysInt+"d ";
			timeFormat += hoursInt+"h ";
		}
		else if( hoursInt != 0 )
			timeFormat += hoursInt+"h ";
			
		timeFormat += minutesInt+"m";
		return timeFormat;
	}
}

STR_Str2Vector( string )
{
	numbersI = 0;
	numbers = [];
	numbers[0] = "";
	numbers[1] = "";
	numbers[2] = "";
	
	for( c = 0; c < string.size && numbersI < 3; c++ )
	{
		if( string[c] == "(" || string[c] == ")" || string[c] == " " )
			continue;
			
		if( string[c] == "," )
		{
			numbersI++;
			continue;
		}
		
		numbers[numbersI] += string[c];
	}
	
	for( i = 0; i < 3; i++ )
		numbers[i] = StringToFloat( numbers[i] );
		
	return ( numbers[0], numbers[1], numbers[2] );
}