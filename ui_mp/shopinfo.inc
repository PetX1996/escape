// SECTION_WEAPONS_BUTTON( num, num_s, title, startIndex, itemsCount )
SECTION_WEAPONS_BUTTON( 0, "0", "Assault", "0", "15" )
SECTION_WEAPONS_BUTTON( 1, "1", "SMG", "15", "15" )
SECTION_WEAPONS_BUTTON( 2, "2", "LMG", "30", "10" )
SECTION_WEAPONS_BUTTON( 3, "3", "Shotgun", "40", "10" )
SECTION_WEAPONS_BUTTON( 4, "4", "Sniper", "50", "10" )

SECTION_WEAPONS_BUTTON( 6, "6", "Grenade", "60", "10" )

SECTION_WEAPONS_BUTTON( 8, "8", "Equipment", "70", "15" )
SECTION_WEAPONS_BUTTON( 9, "9", "Gear", "85", "15" )

// ASSAULT
// ITEM( listIndex, page, TlineIndex, Ttype, Tstat, Tname, Tinfo, Ticon, TsmallIcon, Tperm, Tprice, Trank, Tmoney, Tacc, Tdmg, Trng, Tfrt, Tmob )
ITEM( 0, 0, "0", "Assault", "200", "AK-47", "PERKS_FULLY_AUTOMATIC_WITH5", "weapon_ak47", "1", "0", "0", "0", "50", "75", "75", "50", "66" )
ITEM( 1, 0, "1", "Assault", "201", "M4 Carbine", "PERKS_FULLY_AUTOMATIC_WITH8", "weapon_m4carbine", "1", "0", "0", "0", "75", "40", "75", "75", "66" )
ITEM( 2, 0, "2", "Assault", "202", "G36C", "PERKS_FULLY_AUTOMATIC_WITH7", "weapon_g36c", "1", "0", "0", "0", "70", "60", "75", "60", "66" )

// SMG
ITEM( 0, 0, "15", "SMG", "215", "AK-47u", "PERKS_FULLY_AUTOMATIC_WITH3", "weapon_aks74u", "1", "0", "0", "0", "65", "85", "40", "60", "100" )
ITEM( 1, 0, "16", "SMG", "216", "P90", "PERKS_FULLY_AUTOMATIC_WITH4", "weapon_p90", "1", "0", "0", "0", "80", "60", "40", "90", "100" )

// LMG
ITEM( 0, 0, "30", "LMG", "230", "SAW", "PERKS_FULLY_AUTOMATIC_WITH10", "weapon_m249saw", "1", "0", "0", "0", "70", "40", "75", "80", "33" )
ITEM( 1, 0, "31", "LMG", "231", "RPD", "PERKS_FULLY_AUTOMATIC_WITH9", "weapon_rpd", "1", "0", "0", "0", "60", "75", "75", "50", "33" )
ITEM( 2, 0, "32", "LMG", "232", "M60E4", "PERKS_FULLY_AUTOMATIC_WITH11", "weapon_m60e4", "1", "0", "0", "0", "65", "85", "75", "25", "33" )

// SHOTGUNS
ITEM( 0, 0, "40", "Shotgun", "240", "BENELLI", "PERKS_SEMIAUTOMATIC_COMBAT", "weapon_benelli_m4", "1", "0", "0", "0", "30", "80", "20", "35", "100" )
ITEM( 1, 0, "41", "Shotgun", "241", "WINCHESTER1200", "PERKS_PUMP_ACTION_SHOTGUN_EFFECTIVE", "weapon_winchester1200", "1", "0", "0", "0", "25", "90", "20", "20", "100" )

// SNIPER
ITEM( 0, 0, "50", "Sniper", "250", "M21", "PERKS_SEMIAUTOMATIC_SNIPER2", "weapon_m14_scoped", "1", "0", "0", "0", "60", "65", "100", "50", "66" )
ITEM( 1, 0, "51", "Sniper", "251", "DRAGUNOV", "PERKS_SEMIAUTOMATIC_SNIPER", "weapon_dragunovsvd", "1", "0", "0", "0", "60", "80", "100", "50", "66" )
ITEM( 2, 0, "52", "Sniper", "252", "BARRETT", "PERKS_SEMIAUTOMATIC_SNIPER1", "weapon_barrett50cal", "1", "0", "0", "0", "60", "90", "100", "35", "66" )

// GRENADE
ITEM( 0, 0, "60", "Grenade", "260", "Frag", "PERKS_ANTIPERSONNEL_DEVICE", "weapon_fraggrenade", "1", "0", "0", "0", "0", "0", "0", "0", "0" )
ITEM( 1, 0, "61", "Grenade", "261", "Flash", "PERKS_DEVICE_THAT_BLINDS_AND", "weapon_flashbang", "1", "0", "0", "0", "0", "0", "0", "0", "0" )
ITEM( 2, 0, "62", "Grenade", "262", "Smoke", "PERKS_DEVICE_THAT_CREATES_A", "weapon_smokegrenade", "1", "0", "0", "0", "0", "0", "0", "0", "0" )

// EQUIPMENT
ITEM( 0, 0, "70", "Equipment", "270", "C4", "PERKS_CHARGE_OF_PLASTIC_EXPLOSIVES", "weapon_c4", "1", "0", "0", "0", "0", "0", "0", "0", "0" )
ITEM( 1, 0, "71", "Equipment", "271", "Claymore", "PERKS_DIRECTIONAL_ANTIPERSONNEL", "weapon_claymore", "1", "0", "0", "0", "0", "0", "0", "0", "0" )
ITEM( 2, 0, "72", "Equipment", "272", "RPG", "PERKS_PORTABLE_SHOULDERLAUNCHED", "weapon_rpg7", "1", "0", "0", "0", "0", "0", "0", "0", "0" )
ITEM( 1, 0, "86", "Gear", "286", "Turret", "...", "clear_alpha_stencil", "1", "0", "0", "0", "0", "0", "0", "0", "0" )

// GEAR
ITEM( 0, 0, "85", "Gear", "285", "Barrier", "...", "clear_alpha_stencil", "1", "0", "0", "0", "0", "0", "0", "0", "0" )

// new
//  - light grenade