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

/// MEM_DecimalToHexadecimal( decNumber )
/// MEM_GetHexDigit( decNumber )
/// MEM_DecimalToBinary( decNumber, size )
/// MEM_BinaryToDecimal( binNumber )
/// MEM_GetVariableSize( decNumber )
/// MEM_MergeNumbers( decNumber, binNumber )
/// MEM_SeparateNumbers( decNumber, size )

#include scripts\include\_math;
#include scripts\include\_string;
private VAR_MAXSIZE = 64;

///
/// Vráti zvolené èíslo v šestnástkovej sústave(string).
///
MEM_DecimalToHexadecimal( decNumber )
{
	hexNumber = "";
	hexArray = [];
	
	tempNum = 0;
	tempDigitI = 0;
	while( true )
	{
		if( tempDigitI == 4 || decNumber == 0 )
		{
			hexArray[hexArray.size] = MEM_GetHexDigit( tempNum );
			tempDigitI = 0;
			tempNum = 0;
		}
	
		if( decNumber == 0 )
			break;
	
		curDigit = decNumber & 1;
		decNumber >>= 1;
		tempNum |= MATH_Power( 2, tempDigitI ) * curDigit;
		tempDigitI++;
	}
	
	for( i = hexArray.size - 1; i >= 0; i-- )
		hexNumber += hexArray[i];
		
	return hexNumber;
}
MEM_GetHexDigit( decNumber )
{
	switch( decNumber )
	{
		case 10: return "A";
		case 11: return "B";
		case 12: return "C";
		case 13: return "D";
		case 14: return "E";
		case 15: return "F";
		default: return decNumber;
	}
}
///
/// Vráti hodnotu v dvojkovej sústave ako string.
///
MEM_DecimalToBinary( decNumber, size )
{
	binArray = [];
	binString = "";
	while( decNumber != 0 )
	{
		binArray[binArray.size] |= decNumber & 1;
		decNumber >>= 1;
	}
	
	if( IsDefined( size ) ) // doplní nuly na koniec(zaèiatok)
	{
		for( i = binArray.size; i < size; i++ )
			binArray[i] = 0;
	}

	for( i = binArray.size - 1; i >= 0; i-- ) // otoèí poradie cifier
		binString += binArray[i];
	
	return binString;	
}
///
/// Vráti celoèíselnú hodnotu v desiatkovej sústave.
///
MEM_BinaryToDecimal( binNumber )
{
	digits = "" + binNumber + "";
	digitI = 0;
	result = 0;
	
	for( i = digits.size - 1; i >= 0; i-- )
	{
		digit = int( digits[i] );
		
		result += digit * MATH_Power( 2, digitI );
		digitI++;
	}
	
	return result;
}

///
/// Vráti aktuálnu velkos premennej v bitoch
///
MEM_GetVariableSize( decNumber )
{
	binaryNum = MEM_DecimalToBinary( decNumber );
	digits = "" + binaryNum + "";
	return digits.size;
}

///
/// Pridá do existujúcej premennej èíslo zvolenej ve¾kosti
/// (size: 4; add: 0101) 0000 0011 > 0011 0101
/// 0000 0011
/// 0000 0110
/// 0000 1101
/// 0001 1010
/// 0011 0101
///
MEM_MergeNumbers( decNumber, binNumber )
{
	binDigits = "" + binNumber + "";
	for( i = 0; i < binDigits.size; i++ )
	{
		digit = int( binDigits[i] );
		
		decNumber <<= 1;
		decNumber |= digit;
	}
	
	return decNumber;
}

///
/// Vytiahne z existujúcej premennej èíslo zvolenej ve¾kosti
/// (size: 4) 0011 0101 > 0000 0011
///
MEM_SeparateNumbers( decNumber, size )
{
	newNumber = 0;
	newNumDigits = [];
	for( i = 0; i < size; i++ )
	{
		newNumDigits[newNumDigits.size] = decNumber & 1;
		decNumber >>= 1;
	}
	
	for( i = newNumDigits.size - 1; i >= 0; i-- )
	{
		newNumber <<= 1;
		newNumber |= newNumDigits[i];
	}
	
	rusult = [];
	result[0] = decNumber;
	result[1] = newNumber;
	return result;
}
/*
	var = 0;
	iprintln( "var: ^1"+var );
	var = MEM_MergeNumbers( var, "10" );
	iprintln( "var: ^1"+var );
	var = MEM_MergeNumbers( var, "11" );
	iprintln( "var: ^1"+var );
	var = MEM_MergeNumbers( var, "1111" );
	iprintln( "var: ^1"+var );
	
	vars = MEM_SeparateNumbers( var, 4 );
	iprintln( "var: "+vars[0] );
	iprintln( "number: "+vars[1] );
	vars = MEM_SeparateNumbers( vars[0], 2 );
	iprintln( "var: "+vars[0] );
	iprintln( "number: "+vars[1] );
	vars = MEM_SeparateNumbers( vars[0], 2 );
	iprintln( "var: "+vars[0] );
	iprintln( "number: "+vars[1] );
	
	result:
	var: 0			0
	var: 2					10
	var: 11					10	11
	var: 191				10	11	1111
	
	var: 11			1011
	number: 15						1111
	var: 2			10
	number: 3					11
	var: 0			0
	number: 2				10
*/
