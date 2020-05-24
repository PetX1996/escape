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
	CheckEvents();
}

CheckEvents()
{
	wait 10;

	if( !isDefined( level.EVENTS ) || !level.EVENTS.size )
		return;
	
	events = [];
	for( i = 0;i < level.EVENTS.size;i++ )
	{
		event = level.EVENTS[i];
		
		if( !isDefined( events[event.name] ) )
			events[event.name] = [];
		
		events[event.name][events[event.name].size] = event;
	}
	
	keys = getArrayKeys( events );
	for( i = 0;i < keys.size;i++ )
	{
		array = events[keys[i]];
		
		thread MonitorEvent( keys[i], array );
	}
}

MonitorEvent( name, array )
{
	while( true )
	{
		level waittill( name, object );
		
		for( i = 0;i < array.size;i++ )
		{
			object thread [[array[i].function]]();
		}
	}
}

RunCallback( object, type, runType, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14 )
{
	if( IsDefined( object.CALLBACK ) && IsDefined( object.CALLBACK[type] ) )
	{
		for( i = 0; i < object.CALLBACK[type].size; i++ )
		{
			if( runType == 0 )
			{
				if( IsDefined(arg14) )
					object [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14 );
				else if( IsDefined(arg13) )
					object [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13 );
				else if( IsDefined(arg12) )
					object [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12 );
				else if( IsDefined(arg11) )
					object [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 );
				else if( IsDefined(arg10) )
					object [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 );
				else if( IsDefined(arg9) )
					object [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 );
				else if( IsDefined(arg8) )
					object [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 );					
				else if( IsDefined(arg7) )
					object [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7 );					
				else if( IsDefined(arg6) )
					object [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6 );					
				else if( IsDefined(arg5) )
					object [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5 );					
				else if( IsDefined(arg4) )
					object [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4 );					
				else if( IsDefined(arg3) )
					object [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3 );					
				else if( IsDefined(arg2) )
					object [[object.CALLBACK[type][i]]]( arg0, arg1, arg2 );					
				else if( IsDefined(arg1) )
					object [[object.CALLBACK[type][i]]]( arg0, arg1 );					
				else if( IsDefined(arg0) )
					object [[object.CALLBACK[type][i]]]( arg0 );
				else
					object [[object.CALLBACK[type][i]]]();			
			}
			else
			{
				if( IsDefined(arg14) )
					object thread [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14 );
				else if( IsDefined(arg13) )
					object thread [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13 );
				else if( IsDefined(arg12) )
					object thread [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12 );
				else if( IsDefined(arg11) )
					object thread [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 );
				else if( IsDefined(arg10) )
					object thread [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 );
				else if( IsDefined(arg9) )
					object thread [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 );
				else if( IsDefined(arg8) )
					object thread [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 );				
				else if( IsDefined(arg7) )
					object thread [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7 );			
				else if( IsDefined(arg6) )
					object thread [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5, arg6 );		
				else if( IsDefined(arg5) )
					object thread [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4, arg5 );				
				else if( IsDefined(arg4) )
					object thread [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3, arg4 );	
				else if( IsDefined(arg3) )
					object thread [[object.CALLBACK[type][i]]]( arg0, arg1, arg2, arg3 );	
				else if( IsDefined(arg2) )
					object thread [[object.CALLBACK[type][i]]]( arg0, arg1, arg2 );
				else if( IsDefined(arg1) )
					object thread [[object.CALLBACK[type][i]]]( arg0, arg1 );
				else if( IsDefined(arg0) )
					object thread [[object.CALLBACK[type][i]]]( arg0 );
				else
					object thread [[object.CALLBACK[type][i]]]();
			}
		}
	}
}

DebugCallbacks( printTotalSize, printTypesSize )
{
	totalSize = 0;
	ents = GetEntArray();
	for( i = 0; i < ents.size; i++ )
		totalSize += DebugObjectCallbacks( ents[i], printTotalSize, printTypesSize );
		
	LogPrint( "CALLBACKS;totalSize;"+totalSize+"\n" );
}

DebugObjectCallbacks( object, printTotalSize, printTypesSize )
{
	if( !IsDefined( object ) || !IsDefined( object.CALLBACK ) )
		return 0;
		
	totalSize = 0;
	types = GetArrayKeys( object.CALLBACK );
	for( k = 0; k < types.size; k++ )
	{
		typeSize = object.CALLBACK[types[k]].size;
		if( printTypesSize )
			LogPrint( "CALLBACKS;typeName;"+types[k]+";typeSize;"+typeSize+"\n" );
		
		totalSize += typeSize;
	}
	
	if( printTotalSize )
	{
		text = "CALLBACKS;";
		if( IsDefined( object.className ) )
			text += "objectClassName;"+object.classname+";";
		if( IsDefined( object.targetName ) )
			text += "objectTargetName;"+object.targetname+";";
		
		LogPrint( text+";totalSize;"+totalSize+"\n" );
	}
	
	return totalSize;
}