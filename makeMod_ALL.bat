@echo off

set verbose=%~1
shift
set mainChoice=%~1
shift
set copyArgs=%~1
shift

set ffEnable=%~1
shift

set iwdEnable=%~1
shift
set iwdQuality=%~1
shift

set spcEnable=%~1
shift
set spcSettings=%~1
shift
set spcPlatform=%~1
shift

set runEnable=%~1
shift
set runType=%~1
shift
set runSettings=%~1

echo.	==============================
echo.	Settings from args...
call:FUNC_SETTINGS_DEBUG
echo.	==============================

call:FUNC_DIRECTORIES

echo.	==============================
echo.	Directories...
call:FUNC_DIRECTORIES_DEBUG
echo.	==============================

if "%verbose%"=="" set verbose=1
call:FUNC_SETTINGS_RUN_CHECK
call:FUNC_SETTINGS_SPC_CHECK

echo.	==============================
echo.	Settings after checks...
call:FUNC_SETTINGS_DEBUG
echo.	==============================

set XCOPY_EXCLUDE=/EXCLUDE:mod-exclude.txt

:START                                                                       
set color=1e
color %color%

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
echo.   I                        ESCAPE = MOD = COMPILER                         I
echo.   ==========================================================================
echo.   I                                 V1.1                                   I


:MAKEOPTIONS
echo.   ==========================================================================
echo.   I                          Please choose:                        I
echo.   ==========================================================================
echo    I                             1. ALL                                     I
echo.   I                             2. ALL FAST                                I
echo.   I                             3. FF + IWD                                I
echo.   I                             4. FF + GSC                                I
echo.   I                             5. FF                                      I
echo.   I                             6. IWD                                     I
echo.   I                             7. GSC                                     I
echo.   I                                                                        I
echo.   I                             9. RUN                                     I
echo.   I                                                                        I
echo.   ==========================================================================
if "%mainChoice%"=="" set /p mainChoice=:
if "%mainChoice%"=="1" (
	set ffEnable=1
	set iwdEnable=1
	set spcEnable=1
)
if "%mainChoice%"=="2" (
	set verbose=0
  set copyArgs=/d
	set ffEnable=1
	set iwdEnable=1
	set spcEnable=1	
)
if "%mainChoice%"=="3" (
	set ffEnable=1
	set iwdEnable=1
)
if "%mainChoice%"=="4" (
	set ffEnable=1
	set spcEnable=1
)
if "%mainChoice%"=="5" (
	set ffEnable=1
)
if "%mainChoice%"=="6" (
	set iwdEnable=1
)
if "%mainChoice%"=="7" (
	set spcEnable=1
)
if "%mainChoice%"=="9" (
	set runEnable=1
)
goto COMPILE

:COMPILE
call:FUNC_SETTINGS_DEBUG

if "%ffEnable%"=="1" call:FUNC_COMPILE_FF
if "%iwdEnable%"=="1" call:FUNC_COMPILE_IWD
if "%spcEnable%"=="1" call:FUNC_COMPILE_SPC

if "%runEnable%"=="" call:FUNC_RUN
if "%runEnable%"=="1" call:FUNC_RUN

pause


:: ==================================
:: FUNCTIONS
:: ==================================

:: ==================================
:: SETTINGS

:FUNC_SETTINGS_DEBUG
echo.	verbose: %verbose%
echo.	mainChoice: %mainChoice%
echo.	copyArgs: %copyArgs%
echo.	ffEnable: %ffEnable%
echo.	iwdEnable: %iwdEnable%
echo.	iwdQuality: %iwdQuality%
echo.	spcEnable: %spcEnable%
echo.	spcSettings: %spcSettings%
echo.	spcPlatform: %spcPlatform%
echo.	runEnable: %runEnable%
echo.	runType: %runType%
echo.	runSettings: %runSettings%
goto FINAL

:FUNC_SETTINGS_SPC_CHECK
if "%spcSettings%"=="" call:FUNC_SETTINGS_SPC_SETDEFAULT
goto FINAL

:FUNC_SETTINGS_SPC_SETDEFAULT
if "%verbose%"=="1" ( 
	set spcSettings="-compareDate -verbose"
) else (
	set spcSettings="-compareDate"
)

set spcSettings=%spcSettings:~1,-1%
goto FINAL

:FUNC_SETTINGS_RUN_CHECK
if "%runSettings%"=="" call:FUNC_SETTINGS_RUN_SETDEFAULT
goto FINAL

:FUNC_SETTINGS_RUN_SETDEFAULT
set runSettings="+set developer 1 +set developer_script 1 +set debug 1 +set con_debug 1 +exec escape.cfg +set g_gametype survival +devmap mp_backlot"
set runSettings=%runSettings:~1,-1%
goto FINAL

:FUNC_DIRECTORIES
:: získa názov zložky s módom
for %%* in (.) do set SOURCEFOLDER=%%~n*
cd ..\

:: získa názov "mods" zložky
for %%* in (.) do set MODSFOLDER=%%~n*
cd ..\

set OUTPUTFOLDER=%SOURCEFOLDER%_out

set GAMEDIR=%CD%
set SOURCEFSGAME=%MODSFOLDER%\%SOURCEFOLDER%
set OUTPUTFSGAME=%MODSFOLDER%\%OUTPUTFOLDER%
set SOURCEDIR=%GAMEDIR%\%SOURCEFSGAME%
set OUTPUTDIR=%GAMEDIR%\%OUTPUTFSGAME%
goto FINAL

:FUNC_DIRECTORIES_DEBUG
echo.	GAMEDIR: %GAMEDIR%
echo.	SOURCEFOLDER: %SOURCEFOLDER%
echo.	OUTPUTFOLDER: %OUTPUTFOLDER%
echo.	SOURCEFSGAME: %SOURCEFSGAME%
echo.	OUTPUTFSGAME: %OUTPUTFSGAME%
echo.	SOURCEDIR: %SOURCEDIR%
echo.	OUTPUTDIR: %OUTPUTDIR%
goto FINAL

:: ==================================
:: COMPILING

:FUNC_COMPILE_FF
rem cls
echo.   ==========================================================================
echo.   I                          Building mod.ff:                              I
echo.   ==========================================================================
echo.   I                     Deleting old file...                               I
if exist %OUTPUTDIR%\mod.ff del %OUTPUTDIR%\mod.ff
echo.   ==========================================================================
echo.   I                   Coping localized files...                            I
cd %SOURCEDIR%
if not exist "%GAMEDIR%\zone\english" mkdir "%GAMEDIR%\zone\english"
if not exist "%GAMEDIR%\zone_source\english" xcopy "%GAMEDIR%\zone_source\english" "%GAMEDIR%\zone_source\english" /SYI %XCOPY_EXCLUDE%
echo.   ==========================================================================
echo.   I                    Copying raw files...                                I
echo.   ==========================================================================
xcopy animtrees "%GAMEDIR%\raw\animtrees" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy ccfgs "%GAMEDIR%\raw\ccfgs" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy english "%GAMEDIR%\raw\english" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy fx "%GAMEDIR%\raw\fx" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy images "%GAMEDIR%\raw\images" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy maps "%GAMEDIR%\raw\maps" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy materials "%GAMEDIR%\raw\materials" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy material_properties "%GAMEDIR%\raw\material_properties" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy mp "%GAMEDIR%\raw\mp" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy shock "%GAMEDIR%\raw\shock" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy sound "%GAMEDIR%\raw\sound" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy soundaliases "%GAMEDIR%\raw\soundaliases" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy ui "%GAMEDIR%\raw\ui" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy ui_mp "%GAMEDIR%\raw\ui_mp" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy vision "%GAMEDIR%\raw\vision" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy weapons\mp "%GAMEDIR%\raw\weapons\mp" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy xanim "%GAMEDIR%\raw\xanim" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy xmodel "%GAMEDIR%\raw\xmodel" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy xmodelparts "%GAMEDIR%\raw\xmodelparts" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy xmodelsurfs "%GAMEDIR%\raw\xmodelsurfs" /SYI %copyArgs% %XCOPY_EXCLUDE%

echo.   ==========================================================================
echo.   I               Copying source assets CSV...                             I
echo.   ==========================================================================
xcopy zone_source\*.csv "%GAMEDIR%\zone_source" /SYI %XCOPY_EXCLUDE%
xcopy mod.csv "%GAMEDIR%\zone_source" /SYI %XCOPY_EXCLUDE%
xcopy mod_ignore.csv "%GAMEDIR%\zone_source\english\assetlist" /SYI %XCOPY_EXCLUDE%

echo.   ==========================================================================
echo.   I             Building mod.ff started                                    I
echo.   ==========================================================================
cd %GAMEDIR%\bin
linker_pc.exe -language english -compress -verbose -cleanup mod 
cd %OUTPUTDIR%
copy "%GAMEDIR%\zone\english\mod.ff"
echo.   ==========================================================================
echo.   I             Building mod.ff finished                                   I
echo.   ==========================================================================
if "%verbose%"=="1" pause
call:FUNC_COPYCONFIGS
goto FINAL

:FUNC_COPYCONFIGS
echo.   ==========================================================================
echo.   I                       Copying server configs                           I
echo.   ==========================================================================
cd %SOURCEDIR%
xcopy configs "%OUTPUTDIR%\configs" /SYI %copyArgs% %XCOPY_EXCLUDE%
xcopy *.cfg "%OUTPUTDIR%" /YI %copyArgs% %XCOPY_EXCLUDE%
goto FINAL

:FUNC_COMPILE_IWD
rem cls
if "%iwdQuality%"=="" call:FUNC_COMPILE_IWD_QUALITYCHOICE

cd %GAMEDIR%\bin\IWDPacker
echo.   ==========================================================================
echo.   I                            Creating IWD                                I
echo.   ==========================================================================
rem if exist %OUTPUTDIR%\%iwdFileName%.iwd del %OUTPUTDIR%\%iwdFileName%.iwd
set iwdSettings="-compareDate"
set iwdSettings=%iwdSettings:~1,-1%

IWDPacker.exe -gameDir="%GAMEDIR%" -ffName="mod" -verbose -debugUnusedInDirs -outputFile="%OUTPUTDIR%\esc.iwd" -compression=%iwdQuality% -imagesDir="%SOURCEDIR%\images" -soundsDir="%SOURCEDIR%\sound" -weaponsDir="%SOURCEDIR%\weapons\mp" -includeCodImages -includeCodSounds -includeCodWeapons %iwdSettings%
IWDPacker.exe -gameDir="%GAMEDIR%" -ffName="mod" -verbose -debugUnusedInDirs -outputFile="%OUTPUTDIR%\s.iwd" -compression=%iwdQuality% -weaponsDir="%SOURCEDIR%\weapons\mapsupport" -weaponsIncludeRegex=".*" %iwdSettings%
echo.   ==========================================================================
echo  New IWD file successfully built!
echo.   ==========================================================================
if "%verbose%"=="1" pause
goto FINAL

:FUNC_COMPILE_IWD_QUALITYCHOICE
echo.   ==========================================================================
echo.   I                             IWD COMPRESSION                            I
echo.   ==========================================================================
echo.   I                          Please choose:                                I
echo.   ==========================================================================
echo    I                             1. BestSpeed                               I
echo.   I                             2. BestCompression                         I
echo.   I                                                                        I
echo.   I                             0. Exit                                    I
echo.   ==========================================================================
if "%iwdQuality%"=="" set /p iwdQuality=:
if "%iwdQuality%"=="1" set iwdQuality=BestSpeed
if "%iwdQuality%"=="2" set iwdQuality=BestCompression
goto FINAL

:FUNC_COMPILE_SPC
if "%spcPlatform%"=="" call:FUNC_COMPILE_SPC_PLATFORMCHOICE

echo.   ==========================================================================
echo.   I                        Pre-compiling of GSC                            I
echo.   ==========================================================================
cd %GAMEDIR%\bin\CODSCRIPT
spc.exe -workingDir="%GAMEDIR%\bin\CODSCRIPT" -raw=FSGame -FSGameFolderName="%SOURCEFOLDER%" -settingsFile=%SOURCEFSGAME%\spc.xml %spcSettings%
if "%verbose%"=="1" pause

if "%spcPlatform%"=="1" (
  cd %OUTPUTDIR%
  del /f /s "*.gsx"
)

goto FINAL

:FUNC_COMPILE_SPC_PLATFORMCHOICE
echo.   ==========================================================================
echo.   I                             GSC PLATFORM                               I
echo.   ==========================================================================
echo.   I                          Please choose:                                I
echo.   ==========================================================================
echo    I                             1. Classic                                 I
echo.   I                             2. Ninja 1.8X                              I
echo.   I                                                                        I
echo.   I                             0. Exit                                    I
echo.   ==========================================================================
if "%spcPlatform%"=="" set /p spcPlatform=:
if "%spcPlatform%"=="1" set spcPlatform=1
if "%spcPlatform%"=="2" set spcPlatform=2
goto FINAL

:: ==================================
:: RUN

:FUNC_RUN
if "%runType%"=="" call:FUNC_RUN_TYPECHOICE

call:FUNC_RUN_CHECKS

if "%runType%"=="1" call:FUNC_RUN_DEVELOPER

goto FINAL

:FUNC_RUN_TYPECHOICE
echo.   ==========================================================================
echo.   I                          Please choose:                                I
echo.   ==========================================================================
echo    I                             1. Run Server                              I
echo.   I                                                                        I
echo    I                             0. EXIT                                    I
echo.   ==========================================================================
if "%runType%"=="" set /p runType=:
if "%runType%"=="1" set runType=1
if "%runType%"=="0" exit
goto FINAL

:FUNC_RUN_CHECKS
if not exist "%GAMEDIR%\iw3mp.exe" call:FUNC_RUN_ERRORS "Could not find iw3mp.exe"
if not exist "%OUTPUTDIR%\mod.ff" call:FUNC_RUN_ERRORS "Could not find mod.ff"
if not exist "%OUTPUTDIR%\esc.iwd" call:FUNC_RUN_ERRORS "Could not find esc.iwd"
goto FINAL

:FUNC_RUN_ERRORS
rem cls
set color=0c
color %color%
echo.   ======================================================================
echo.   I                        Could not find mod                          I
echo.   I                                                                    I
echo.   I            %~1             I
echo.   I                                                                    I
echo.   I               MOD.FF MUST BE IN FOLDER MODS IN BASE COD4 DIR       I
echo.   I                                                                    I
echo.   I       Run As ADMINISTRATOR!                                        I
echo.   ======================================================================
pause
exit

:FUNC_RUN_DEVELOPER
echo.   ======================================================================
echo.   I                            Running game....                        I
echo.   ======================================================================
cd %GAMEDIR%
iw3mp.exe +set punkbuster 0 +set dedicated 0 +set logfile 2 +set net_ip "127.0.0.1" +set net_port "28960" +set fs_game %OUTPUTFSGAME% +set g_log "games_mp.log" +set ui_maxclients "64" %runSettings%
exit

:FINAL