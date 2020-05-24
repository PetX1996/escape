rem iw3mp.exe +set fs_game mods/escape  +set net_ip 0.0.0.0  +set sv_punkbuster 0 +map_rotate +set net_port 28960  +set ui_maxclients "64" +set dedicated 1 +exec escape.cfg
iw3mp.exe +set punkbuster 0 +set dedicated 1 +set net_ip "0.0.0.0" +set net_port "28960" +set debug 1 +set con_debug 1 +sets gamestartup \"`date +"%D %T"`\" +set fs_game mods/escape_test +exec escape.cfg +set g_log "games_mp.log" +set ui_maxclients "64" +set g_gametype location +map mp_shipment

rem +set developer 1 

rem +set developer_script 1