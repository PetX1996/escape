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

init()
{
	level.pluginlist = [];
	thread LoadPlugins();
}

LoadPlugins()
{
	wait 0.001; //cas na nacitanie vsetkych pluginov...
	
	if(!isdefined(level.plugins))
	{
		ClearPluginsWindow(0);
		return;
	}
	
	plugins = [];
	
	for(i = 0;i < level.plugins.size;i++)
	{
		if(!isdefined(level.plugins[i]["name"]))
			continue;
	
		if(!isdefined(level.plugins[i]["count"]))
			level.plugins[i]["count"] = 1;
	
		for(a = 0;a < level.plugins.size;a++)
		{
			if(!isdefined(level.plugins[a]["name"]))
				continue;
		
			if(a != i && level.plugins[i]["name"] == level.plugins[a]["name"])
			{
				level.plugins[a]["name"] = undefined;
				level.plugins[i]["count"]++;
				continue;
			}
		}
		
		if(!isdefined(level.plugins[i]["name"]))
			continue;
		
		size = plugins.size;
		plugins[size]["name"] = level.plugins[i]["name"];
		plugins[size]["ver"] = level.plugins[i]["ver"];
		plugins[size]["author"] = level.plugins[i]["author"];
		plugins[size]["count"] = level.plugins[i]["count"];
	}
	
	for(i = 0; i < plugins.size;i++)
	{
		if(!isdefined(plugins[i]["name"]))
			continue;
	
		if(i == 20)
			return;
	
		plugin = plugins[i];
		
		level.pluginlist["help_plugin_name_"+i] = plugin["name"];
		level.pluginlist["help_plugin_ver_"+i] = plugin["ver"];
		level.pluginlist["help_plugin_author_"+i] = plugin["author"];
		level.pluginlist["help_plugin_count_"+i] = plugin["count"];	
	}
	
	if(plugins.size == 20)
		return;
	
	ClearPluginsWindow( plugins.size );
}

ClearPluginsWindow( start )
{
	for(i = start;i < 20;i++) //odstranenie pluginov z predchadzajucej mapy...
	{
		level.pluginlist["help_plugin_name_"+i] = " ";
		level.pluginlist["help_plugin_ver_"+i] = " ";
		level.pluginlist["help_plugin_author_"+i] = " ";
		level.pluginlist["help_plugin_count_"+i] = " ";	
	}
}