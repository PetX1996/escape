main()
{
	maps\mp\_load::main();
	
	VisionSetNaked( "mp_escape_123" );
		
	setdvar("compassmaxrange","2000");

	thread plugins\maps\_des_obj::DestructibleEntity( "bridge", 1000, undefined, "allies" );
	thread plugins\maps\_des_obj::DestructibleEntity( "pillar", 1000, undefined, undefined );
	thread plugins\maps\_des_obj::DestructibleEntity( "box", 1000, undefined, undefined );
	
	thread plugins\maps\_doors::SlideDoors("map_door_brush0", "door0_a", "door0_b", "x", 180, 10, 20, "^2Door open in ^720 ^2seconds.", "^2!!! Door open !!!");
	thread plugins\maps\_doors::SlideDoors("map_door_brush1", "door1_a", "door1_b", "x", 180, 10, 30, "^3Door open in ^730 ^3seconds.", "^3!!! Door open !!!");
	thread plugins\maps\_doors::SlideDoors("map_door_brush2", "door2_a", "door2_b", "x", 180, 10, 45, "^4Door open in ^745 ^4seconds.", "^4!!! Door open !!!");
	thread plugins\maps\_doors::SlideDoors("map_door_brush3", "door3_a", "door3_b", "x", 180, 10, 60, "^5Door open in ^760 ^5seconds.", "^5!!! Door open !!!");
	
	thread plugins\maps\_fx::AddFX( "4gf_street_lamp", "fire/4gf_street_lamp", "oneshot", 15,"4gf_street_lamp", undefined);
	thread plugins\maps\_fx::AddFX( "4gf_evase", "fire/4gf_evase", "oneshot", 15,"4gf_evase", undefined);
	thread plugins\maps\_fx::AddFX( "4gf_fog", "weather/4gf_fog", "oneshot", 15, undefined, undefined);
	thread plugins\maps\_fx::AddFX( "4gf_violet_tree", "misc/4gf_violet_tree", "oneshot", 15, undefined, undefined);
	thread plugins\maps\_fx::AddFX( "4gf_lava", "fire/4gf_lava", "oneshot", 15, undefined, undefined);

	thread plugins\ends\_default::init( "escape_endmap_default" );
	
	level.MapSettings["SpawnsFX"] = "misc/m_resp_b";
}