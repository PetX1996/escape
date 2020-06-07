cd /d C:\callofduty4-sources\sources\Mods\escape

set spcArgs="-verbose -compareDate"
set gameArgs="+set developer 1 +set developer_script 1 +set debug 1 +set con_debug 1 +exec escape.cfg +set g_gametype escape +devmap mp_escape_test"

rem	0-1		0-9		   0-1		0-1		  BestSpeed-BestCompression 0-1 	  ""		  0-1		1		""
rem verbose mainChoice ffEnable iwdEnable iwdQuality 				spcEnable spcSettings runEnable runType runSettings
call makeMod_ALL.bat 0 9 "" "" "BestCompression" "" "" 0 1 %gameArgs%
rem pause