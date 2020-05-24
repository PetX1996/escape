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

/// AddToArray( array, value )
/// DeleteFromArray( array, current )
/// IsInArray( array, value )
/// GetArrayKeyByValue( array, value )

/// ARRAY_Add( array, item )
/// ARRAY_AddRange( array, items )

/// ARRAY_Insert( array, item, index )
/// ARRAY_InsertRange( array, items, index )

/// ARRAY_Remove( array, item )
/// ARRAY_RemoveRange( array, items )
/// ARRAY_RemoveAt( array, index )

/// ARRAY_Contains( array, item )
/// ARRAY_IndexOf( array, item, startIndex )

ARRAY_Combine( firstArray, secondArray )
{
	for( i = 0; i < secondArray.size; i++ )
		firstArray[firstArray.size] = secondArray[i];
	
	return firstArray;
}

AddToArray( array, value )
{
	array[array.size] = value;
}

DeleteFromArray( array, current )
{
	size = array.size;
	for( i = 0;i < size;i++ )
	{
		if( array[i] == current )
		{
			for( a = i;a < size;a++ )
			{
				if( a == size-1 )
				{
					array[a] = undefined;
					return array;
				}
				
				array[a] = array[a+1];
			}
		}
	}
	return array;
}

IsInArray( array, value )
{
	keys = GetArrayKeys( array );
	for( i = 0;i < keys.size;i++ )
	{
		current = array[keys[i]];
		if( isString( current ) && isString( value ) && current == value )
			return true;
		else if( isPlayer( current ) && isPlayer( value ) && current == value )
			return true;
		else if( !isString( current ) && !isString( value ) && current == value )
			return true;
	}
	return false;
}

GetArrayKeyByValue( array, value )
{
	keys = GetArrayKeys( array );
	for(i = 0;i < keys.size;i++)
	{
		if( array[keys[i]] == value )
			return keys[i];
	}
	return undefined;
}

ARRAY_ReWrite( sourceArray, newArray )
{
	keys = GetArrayKeys( newArray );
	for( k = 0; k < keys.size; k++ )
		sourceArray[keys[k]] = newArray[keys[k]];
		
	return sourceArray;
}

ARRAY_Add( array, item )
{
	array[array.size] = item;
	return array;
}
ARRAY_AddRange( array, items )
{
	for( i = 0; i < items.size; i++ )
		array[array.size] = items[i];
	
	return array;
}
ARRAY_Insert( array, item, index )
{
	oldArray = array;
	array[index] = item;
	for( i = index; i < oldArray.size; i++ )
		array[i+1] = oldArray[i];
		
	return array;
}
ARRAY_InsertRange( array, items, index )
{
	oldArray = array;
	for( i = 0; i < items.size; i++ )
		array[index+i] = items[i];
		
	for( i = index; i < oldArray.size; i++ )
		array[i+items.size] = oldArray[i];
		
	return array;
}
ARRAY_Remove( array, item )
{
	for( i = 0; i < array.size; i++ )
	{
		if( array[i] == item )
		{
			for( j = i; j < array.size - 1; j++ )
				array[j] = array[j+1];
				
			array[j] = undefined;
			break;
		}
	}
	return array;
}
ARRAY_RemoveRange( array, items )
{
	newArray = [];
	for( i = 0; i < array.size; i++ )
	{
		if( ARRAY_Contains( items, array[i] ) )
			continue;
			
		newArray[newArray.size] = array[i];
	}
	return newArray;
}
ARRAY_RemoveAt( array, index )
{
	for( i = index; i < array.size - 1; i++ )
		array[i] = array[i+1];

	array[i] = undefined;
	return array;
}
ARRAY_Contains( array, item )
{
	for( i = 0; i < array.size; i++ )
	{
		if( array[i] == item )
			return true;
	}
	return false;
}
ARRAY_IndexOf( array, item, startIndex )
{
	if( !IsDefined( startIndex ) )
		startIndex = 0;
		
	for( i = startIndex; i < array.size; i++ )
	{
		if( array[i] == item )
			return i;
	}
	return -1;
}			