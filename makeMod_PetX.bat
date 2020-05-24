if not "%CD%"=="D:\CoD4 Tvorba Map\Call of Duty 4 - Mod ESCAPE\Mods\escape" cd /d D:\CoD4 Tvorba Map\Call of Duty 4 - Mod ESCAPE\Mods\escape

set args="+set developer 1 +set developer_script 0 +set debug 1 +set con_debug 1 +exec escape.cfg +set g_gametype survival +devmap mp_backlot"

rem verbose mainChoice iwdChoice runChoice runSettings
call makeMod_ALL.bat 0 2 1 1 %args%