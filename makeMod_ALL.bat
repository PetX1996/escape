@echo off

set verbose=%1%

set mainChoice=%2%
set iwdChoice=%3%
set runChoice=%4%

set runSettings=%5%

echo.	verbose: %verbose%
echo.	mainChoice: %mainChoice%
echo.	iwdChoice: %iwdChoice%
echo.	runChoice: %runChoice%
echo.	runSettings: %runSettings%

if "%verbose%"=="" set verbose=1

set runSettings=%runSettings:~1,-1%

if "%runSettings%"=="~1,-1" goto RUN_SETTINGS
goto DIRECTORIES

:RUN_SETTINGS
set runSettings="+set developer 1 +set developer_script 0 +set debug 1 +set con_debug 1 +exec escape.cfg +set g_gametype survival +devmap mp_backlot"
set runSettings=%runSettings:~1,-1%
goto DIRECTORIES

:DIRECTORIES
rem pause

echo.	verbose: %verbose%
echo.	mainChoice: %mainChoice%
echo.	iwdChoice: %iwdChoice%
echo.	runChoice: %runChoice%
echo.	runSettings: %runSettings%

rem získa názov zložky s módom
for %%* in (.) do set FOLDERNAME=%%~n*
cd ..\

rem získa názov "mods" zložky
for %%* in (.) do set MODSFOLDER=%%~n*
cd ..\

set GAMEDIR=%CD%
set SOURCEFSGAME=%MODSFOLDER%\%FOLDERNAME%
set OUTPUTFSGAME=%MODSFOLDER%\escape_out
set SOURCEDIR=%GAMEDIR%\%SOURCEFSGAME%
set OUTPUTDIR=%GAMEDIR%\%OUTPUTFSGAME%

echo.	GAMEDIR: %GAMEDIR%
echo.	SOURCEFSGAME: %SOURCEFSGAME%
echo.	OUTPUTFSGAME: %OUTPUTFSGAME%
echo.	SOURCEDIR: %SOURCEDIR%
echo.	OUTPUTDIR: %OUTPUTDIR%

if not exist "%OUTPUTDIR%" mkdir "%OUTPUTDIR%"

set color=1e
color %color%

set XCOPY_EXCLUDE=/EXCLUDE:mod-exclude.txt


:START                                                                       
rem cls
echo.   I========================================================================I
echo.   I                    ___  _____  _____                                   I
echo.   I                   /   !!  __ \!  ___!                                  I
echo.   I                  / /! !! !  \/! !_          ___  ____                  I
echo.   I                 / /_! !! ! __ !  _!        / __!!_  /                  I
echo.   I                 \___  !! !_\ \! !      _  ! (__  / /                   I
echo.   I                     !_/ \____/\_!     (_)  \___!/___!                  I
echo.   I========================================================================I
echo.   I                                                                        I
echo.   I                        ESCCAPE = MOD = COMPILER                        I
echo.   ==========================================================================
echo.   I                                 V1.1                                   I


:MAKEOPTIONS
echo.   ==========================================================================
echo.   I                          Please choose:                                I
echo.   ==========================================================================
echo    I                             1. FF + IWD                                I
echo.   I                             2. Only .FF                                I
echo.   I                             3. Only .IWD                               I
echo.   I                             4. ALL FAST                                I
echo.   I                                                                        I
echo.   I                             5. Server run Menu                         I
echo.   I                                                                        I
echo.   ==========================================================================
if "%mainChoice%"=="" set /p mainChoice=:
if "%mainChoice%"=="1" goto MAKE_FF
if "%mainChoice%"=="2" goto MAKE_FF
if "%mainChoice%"=="3" goto MAKE_IWD
if "%mainChoice%"=="4" ( 
set verbose=0 
goto MAKE_FF 
)
if "%mainChoice%"=="5" goto RUN
goto START


:MAKE_FF
rem cls
echo.   ==========================================================================
echo.   I                          Building mod FF:                              I
echo.   ==========================================================================
echo.   I                Deleting old mod.ff...                                  I
cd %OUTPUTDIR%
del mod.ff
echo.   ==========================================================================
echo.   I                   Copying language files...                            I
cd %SOURCEDIR%
if not exist "%GAMEDIR%\zone\english" mkdir "%GAMEDIR%\zone\english"
if not exist "%GAMEDIR%\zone_source\english" xcopy "%GAMEDIR%\zone_source\english" "%GAMEDIR%\zone_source\english" /SYI %XCOPY_EXCLUDE%
echo.   ==========================================================================
echo.   I                    Copying assets...                                   I
echo.   ==========================================================================
xcopy animtrees "%GAMEDIR%\raw\animtrees" /SYI %XCOPY_EXCLUDE%
xcopy client_cfg "%GAMEDIR%\raw\client_cfg" /SYI %XCOPY_EXCLUDE%
xcopy english "%GAMEDIR%\raw\english" /SYI %XCOPY_EXCLUDE%
xcopy fx "%GAMEDIR%\raw\fx" /SYI %XCOPY_EXCLUDE%
xcopy images "%GAMEDIR%\raw\images" /SYI %XCOPY_EXCLUDE%
xcopy maps "%GAMEDIR%\raw\maps" /SYI %XCOPY_EXCLUDE%
xcopy materials "%GAMEDIR%\raw\materials" /SYI %XCOPY_EXCLUDE%
xcopy material_properties "%GAMEDIR%\raw\material_properties" /SYI %XCOPY_EXCLUDE%
xcopy mp "%GAMEDIR%\raw\mp" /SYI %XCOPY_EXCLUDE%
xcopy shock "%GAMEDIR%\raw\shock" /SYI %XCOPY_EXCLUDE%
xcopy sound "%GAMEDIR%\raw\sound" /SYI %XCOPY_EXCLUDE%
xcopy soundaliases "%GAMEDIR%\raw\soundaliases" /SYI %XCOPY_EXCLUDE%
xcopy ui "%GAMEDIR%\raw\ui" /SYI %XCOPY_EXCLUDE%
xcopy ui_mp "%GAMEDIR%\raw\ui_mp" /SYI %XCOPY_EXCLUDE%
xcopy vision "%GAMEDIR%\raw\vision" /SYI %XCOPY_EXCLUDE%
xcopy weapons\mp "%GAMEDIR%\raw\weapons\mp" /SYI %XCOPY_EXCLUDE%
xcopy xanim "%GAMEDIR%\raw\xanim" /SYI %XCOPY_EXCLUDE%
xcopy xmodel "%GAMEDIR%\raw\xmodel" /SYI %XCOPY_EXCLUDE%
xcopy xmodelparts "%GAMEDIR%\raw\xmodelparts" /SYI %XCOPY_EXCLUDE%
xcopy xmodelsurfs "%GAMEDIR%\raw\xmodelsurfs" /SYI %XCOPY_EXCLUDE%

echo.   ==========================================================================
echo.   I               Copying assets lists...                                  I
echo.   ==========================================================================
copy /Y mod*.csv "%GAMEDIR%\zone_source"
copy /Y mod_ignore.csv "%GAMEDIR%\zone_source\english\assetlist"

echo.   ==========================================================================
echo.   I             Started building mod.ff...                                 I
echo.   ==========================================================================
cd %GAMEDIR%\bin
linker_pc.exe -language english -compress -verbose -cleanup mod 
cd %OUTPUTDIR%
copy "%GAMEDIR%\zone\english\mod.ff"
echo.   ==========================================================================
echo.   I                Finished building mod.ff!                               I
echo.   ==========================================================================
if "%verbose%"=="1" pause
if "%mainChoice%"=="1" goto MAKE_IWD
if "%mainChoice%"=="4" goto MAKE_IWD
goto COPY_CFG


:MAKE_IWD
rem cls
echo.   ==========================================================================
echo.   I                                   IWD                                  I
echo.   ==========================================================================
echo.   I                          Please choose:                                I
echo.   ==========================================================================
echo    I                             1. Minimum compression (fast)              I
echo.   I                             2. Maximum compression (slow)              I
echo.   I                                                                        I
echo.   I                             0. Exit                                    I
echo.   ==========================================================================
set COMPRESS_TYPE=-mx1
if "%iwdChoice%"=="" set /p iwdChoice=:
if "%iwdChoice%"=="1" set COMPRESS_TYPE=-mx1
if "%iwdChoice%"=="2" set COMPRESS_TYPE=-mx9

echo.   ==========================================================================
echo.   I                    Deleting old .iwd files...                          I
echo.   ==========================================================================
cd %OUTPUTDIR%
del esc.iwd
cd %SOURCEDIR%
echo.   ==========================================================================
echo    Adding images...
7za a %COMPRESS_TYPE% -r -tzip esc.iwd images\*.iwi
echo.   ==========================================================================
echo    Adding sounds...
7za a %COMPRESS_TYPE% -r -tzip esc.iwd sound\*.mp3 sound\*.wav
echo.   ==========================================================================
echo    Adding weapons...
7za a %COMPRESS_TYPE% -r -tzip esc.iwd weapons\mp\*_mp
echo.   ==========================================================================
echo    Adding empty mod.arena file...
7za a %COMPRESS_TYPE% -r -tzip esc.iwd mod.arena
echo.   ==========================================================================
echo  New esc.iwd file successfully built!
echo.   ==========================================================================
cd %OUTPUTDIR%
copy "%SOURCEDIR%\esc.iwd"
cd %SOURCEDIR%
del esc.iwd
if "%verbose%"=="1" pause
goto COPY_CFG

:COPY_CFG
echo.   ==========================================================================
echo.   I                             Copying CFG                                I
echo.   ==========================================================================
cd %SOURCEDIR%
xcopy *.cfg "%OUTPUTDIR%" /s /y
goto PRECOMPILE_SCRIPTS

:PRECOMPILE_SCRIPTS
cd %SOURCEDIR%
echo.   ==========================================================================
echo.   I                        Compiling GSC                                   I
echo.   ==========================================================================
rem ScriptOptimalizer.exe -targetDir="%OUTPUTDIR%" -profile="Debug" -verbose
rem -deleteComments
if "%verbose%"=="1" pause
goto RUN

:RUN
echo.   ==========================================================================
echo.   I                          Please choose:                                I
echo.   ==========================================================================
echo    I                             1. Run Server                              I
echo.   I                                                                        I
echo    I                             3. Quit                                    I
echo.   ==========================================================================
if "%runChoice%"=="" set /p runChoice=:
if "%runChoice%"=="1" goto KONTROLA_EXE
if "%runChoice%"=="3" goto FINAL
goto FINAL

:KONTROLA_EXE
cd %GAMEDIR%
if not exist iw3mp.exe goto ERROR_EXE
goto KONTROLA_FFIWD

:KONTROLA_FFIWD
cd %OUTPUTDIR%
if not exist mod.ff goto ERROR_FFIWD
if not exist esc.iwd goto ERROR_FFIWD
goto SERVER_RUN

:ERROR_EXE
rem cls
set color=0c
color %color%
echo.   ======================================================================
echo.   I                        Invalid folder                              I
echo.   I                                                                    I
echo.   I                        NOT FOUND iw3mp.exe                         I
echo.   I                                                                    I
echo.   I               MOD must be inside MODS inside base COD4 folder      I
echo.   I                                                                    I
echo.   I                 DISABLE UAC    WIN7,VISTA                          I
echo.   ======================================================================
pause
goto FINAL

:ERROR_FFIWD
rem cls
set color=0c
color %color%
echo.   ======================================================================
echo.   I                           Invalid folder                           I
echo.   I                                                                    I
echo.   I                           Missing mod.ff                           I
echo.   I                           Missing esc.ff                           I
echo.   ======================================================================
pause
goto FINAL

:SERVER_RUN
echo.   ======================================================================
echo.   I                            Running....                             I
echo.   ======================================================================
cd %GAMEDIR%
iw3mp.exe +set punkbuster 0 +set dedicated 0 +set logfile 2 +set net_ip "127.0.0.1" +set net_port "28960" +set fs_game %OUTPUTFSGAME% +set g_log "games_mp.log" +set ui_maxclients "64" %runSettings%
goto :FINAL

:FINAL