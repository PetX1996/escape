main()
{
	maps\mp\_load::main();
	
	//thread maps\mp\mp_escape_lab\_bot::main();

	setdvar( "r_specularcolorscale", "1" );
	setdvar("r_glowbloomintensity0",".25");
	setdvar("r_glowbloomintensity1",".25");
	setdvar("r_glowskybleedintensity0",".3");
	setdvar("compassmaxrange","2200");
	
	// ======== ESCAPE ========= //
	level.MapSettings["TimeLimit"] = 8; 							//minutes
	level.MapSettings["SpawnsFX"] = "misc/ui_flagbase_black"; 				//the path to FX, Loop FX recommended
	level.MapSettings["BigSpawnsFX"] = "misc/ui_flagbase_black_big"; 	//the path to FX, Loop FX recommended
	level.MapSettings["AmbientTrack"] = "mp_escape_factory"; 			//ambient track
	
	level.MapSettings["MonstersStartTimeAdd"] = 10;
	// ========================= //
}