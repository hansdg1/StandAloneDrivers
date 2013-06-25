
@ECHO off & setlocal EnableDelayedExpansion
net stop "FOG Service"

::Except otherwise noted, the open-source code of the DP_Install_Tool.cmd file is © 2011-2013 by Erik Hansen for DriverPacks.net, under a Creative Commons Attribution-ShareAlike license: http://creativecommons.org/licenses/by-sa/3.0/.
::7-Zip is open source software by Igor Pavlov. Most of the source code is under the GNU LGPL license. The unRAR code is under a mixed license: GNU LGPL + unRAR restrictions. Check license information here: http://www.7-zip.org/license.txt or http://www.gnu.org/licenses/lgpl.html
::DPInst.exe is proprietary code owned completely by Microsoft and distributed under their own license. (see .\bin\*\dpinst-license.rtf)
SET "S_Version=v13.05.07"
SET "S_Title=DriverPacks.net Stand Alone Driver Updater 3"

 :: Originally written by Jeff Herre AKA OverFlow, significantly rewritten by Erik Hansen AKA Mr_Smartepants. 
 :: Modified by Brent Newland (casipc.com) to support network shares and UAC elevation.
 :: Modified by SteveDun to add additional functionality and NT6 touchpad bugfixes.
 :: A Script to use Microsoft's DPInst.exe with the DriverPacks.
 :: Help and Support available at http://forum.driverpacks.net/viewtopic.php?id=5336
 :: This script assumes that the original folder structure of the downloaded archive remains intact.
 :: Please do not alter the folder structure unless you REALLY know what you are doing and alter the below code accordingly. 
 
 :: Changelog:
 :: v130507 v3.0 (Erik Hansen)
 :: Cleaned up user choice code, standardized variable names to X_CamelCase method.
 :: Fixed bug where KTD option was not set when /CR switch is used.
 :: Changed folder delete code to incorporate array processing.

 :: v130501 v3.0 (Erik Hansen)
 :: Modified code to remove designated "known problem" drivers from driver pool prior to dpinst by scanning a "Known-problems*.txt" file.
 :: Modified code to ensure user options are enforced.

 :: v130428 v3.0 (Erik Hansen)
 :: Modified code to remove more known problem Touchpad HID drivers from driver pool prior to dpinst. (Alps/Dell, Elantech)

 :: v130426 v3.0 (Erik Hansen)
 :: Modified OS detection code to use WMIC instead of query the registry.
 :: Fixed bug where files were "cleaned" despite user choice.
 :: Added code to remove known problem Touchpad HID drivers from driver pool prior to dpinst. (Alps/Dell, Elantech)

 :: v130423 v3.0
 :: Remerged codebases (briefly forked during simultaneous development).
 :: Sound effect script removed from bin folder...SAD now creates it dynamically.  (SteveDun)
 :: SAD now calls UAC Check for NT6 OS's dynamically (replaces the Elevate commands in bin folder) (SteveDun)
 :: Now fully works when added to windows ISO's. (SteveDun)
 :: Corrected error's in Cleaning Phase.  (SteveDun)
 :: Modified code to support commandline switches using either slash '/' or dash '-' (example: script.cmd -s) (Erik Hansen)
 :: Modified extraction code to minimize extraction windows. (Erik Hansen)
 :: Added code to count extraction progress in title bar. (Erik Hansen)
 :: Fixed bug where commandline execution would work but double-click would fail. (Erik Hansen)
 :: Cleaned up displayed text to center in window. (Erik Hansen)

 :: v130420 v3.0 (Erik Hansen)
 :: Fixed bug in :Elevate section where commandline switches were not passed to utility when run as a normal user.
 :: Fixed bug where utility would try to delete itself after complete.
 :: Minor fixes to :Cleaningphase section and :Usage verbiage.

 :: v130419 v3.0 (Erik Hansen)
 :: Fixed file copy error for *.ins file.
 :: Added code to skip NT6 folder cleanup for NT5 systems.
 :: Fixed Log file missing error.

 :: v130418 v3.0 (Erik Hansen)
 :: Merged codebase between Erik Hansen and SteveDun
 :: Merged many separate functions to save compute space.
 :: Pruned excess conditional statements to speed processing.
 :: General-level code optimization
 
 :: v130416 v3.0 Modified Final (SteveDun)
 :: Added support for Win 8.1 Blue NT 6.3.
 :: Updated 7-zip32.dll as per request.
 :: reg query for InstallationType for non Server OS's could cause error on some systems is now corrected.
 :: Updated to new version of Devcon.
 :: Additional option to save touchpad drivers if it didnt install the correct one.  Use Device Manager to install it then.
 :: Now KTD works with NT5 systems. 
 :: Added more efficient cleanup routine.
 :: Added support for XP MCE rollup 2.
 :: Instead of exiting on some error's I change it to return to the cmd prompt.
 :: Sound effect played in XP would cause script to crash at the end.  Fixed now.
 :: Addded support for Win8.  
 :: Added restore point creation (supports Win8 & Servers).  Not avail. in silent mode.  
 :: Added user input on weather to restart or not.   
 :: Updated DPInst.exe to newest versions (2 for NT=5(2010) and 2 for NT=6(2012)) (32 and 64 bit).
 :: Fixed silent install failure.
 :: Added Reboot option to silent switches.
 :: Fixed Log file crashing script.
 :: Added option to keep Log file or delete it. Not avail. in silent mode.  Log file is kept by default.
 :: Corrected layout of the timer counter to show correctly.
 :: Updated "/?" or "/H" help from command prompt. 
 :: Minor cosmetic fixes.

 :: v120520
 :: Modified code to detect OS Architecture correctly. (Erik Hansen)
 :: Removed extra parenthesis and other minor refinements.

 :: v120423
 :: Fixed code to detect Server 2003 correctly. (franner)

 :: v120326
 :: Fixed code to prevent errors during cleanup stage (Iceblackice)

 :: v120318
 :: Added code to enable switches.  Only a Help guide and "Silent" operation for now. (Erik Hansen)

 :: v120317
 :: Added code for silent operation.  No prompts, displays progress only. (Erik Hansen)
 :: Added code to delete folders not needed. (Erik Hansen)

 :: v120217
 :: Updated command line 7-zip in \bin folder to 9.22. (Erik Hansen)

 :: v120215
 :: Added command line 7-zip to \bin folder and code to use. (Erik Hansen)
 :: Updated elevate.vbs to current version from MSDN.
 :: Optimized OS detection subroutines.
 :: Fixed log file output reference to %windir%\dpinst.log.
 
 :: v120203
 :: Added code to use native installed 7-Zip IF present. (Erik Hansen)
 :: Fixed bug with extra space in %F_OSbit% variable

 :: v111118
 :: Fixed typo in log file output reference.(Twig123/Dave)

 :: v111009
 :: Fixed typo in KTD option code.(Erik Hansen)

 :: v111008
 :: Added code to allow user to change Keep The Drivers (KTD) option (Erik Hansen)
 :: Fixed bug where DriverPacks wouldn't be found IF there were spaces in the path.
 
 :: v110713
 :: Fixed code to prevent errors during cleanup stage (Erik Hansen)
 :: Added code to report accurate CPU type (Erik Hansen)
 :: Added code to detect DP_*.7z files in the current directory (Erik Hansen)

 :: v110505
 :: Fixed code to prevent writing log to read-only disc (Erik Hansen)
 :: Repackaged dpinst* files to prevent accidental deletion. (Erik Hansen)

 :: v110504
 :: Fixed bug where NT6 Method 1 fails prematurely. (Erik Hansen)

 :: v110503
 :: Fixed code to remove extra backslash from path if one exists. (Erik Hansen)

 :: v110502
 :: Fixed un7zip code to allow for wildcard file extraction (Erik Hansen)

 :: v110501
 :: Updated to support network shares and UAC elevation for NT6 (Brent Newland)
 :: Fixed CPU detection to allow for 32-bit OS on 64-bit CPU (Erik Hansen)
 :: Fixed un7zip code to allow breakpoints (Brent Newland)
 
 :: v110312 (Erik Hansen)
 :: Fixed missing NT5\x86\dpinst.* files
 :: Updated to current DriverPack ChipSET versions.

 :: v110213 (Erik Hansen)
 :: Added NT6 Method 1 functionality.
 :: Added check for UNC (\\server\path\to\file) paths.  Cmd.exe will fail if UNC path is used.
 :: Changed Method 1 COPY function to XCOPY for reliability.
 :: Improved readme.txt instructions.

TITLE %S_Title% %S_Version% & Color 9f

:Default_Options
SET "C_SilentFlag=Y" & SET "C_KTDFlag=N" & SET "C_OSFolderCleanFlag=N" & SET "C_RebootFlag=R"
 :: KTD option.  "Y" will not delete any drivers from the %systemdrive%\D\ folder.
 :: OS folder clean option.  "Y" will delete any drivers for OS folders not needed.
 :: REBOOT "R" or Exit "X"

:Help_Options
IF NOT "%1"=="" (SET "params=%1") ELSE (SET "params=")
IF [%params%]==[/?] GOTO :Usage
FOR %%A IN (/h /help -h -help) DO IF /I [%params%]==[%%A] GOTO Usage
FOR %%A IN (/s -s) DO IF /I [%params%]==[%%A] (SET "C_SilentFlag=Y" & SET "C_KTDFlag=N" & SET "C_OSFolderCleanFlag=Y" & SET "C_RebootFlag=X")
FOR %%A IN (/sr -sr) DO IF /I [%params%]==[%%A] (SET "C_SilentFlag=Y" & SET "C_KTDFlag=N" & SET "C_OSFolderCleanFlag=Y" & SET "C_RebootFlag=R")
FOR %%A IN (/k -k) DO IF /I [%params%]==[%%A] (SET "C_SilentFlag=Y" & SET "C_KTDFlag=Y" & SET "C_OSFolderCleanFlag=Y" & SET "C_RebootFlag=X")
FOR %%A IN (/kr -kr) DO IF /I [%params%]==[%%A] (SET "C_SilentFlag=Y" & SET "C_KTDFlag=Y" & SET "C_OSFolderCleanFlag=Y" & SET "C_RebootFlag=R")
FOR %%A IN (/c -c) DO IF /I [%params%]==[%%A] (SET "C_SilentFlag=Y" & SET "C_KTDFlag=Y" & SET "C_OSFolderCleanFlag=N" & SET "C_RebootFlag=X")
FOR %%A IN (/cr -cr) DO IF /I [%params%]==[%%A] (SET "C_SilentFlag=Y" & SET "C_KTDFlag=Y" & SET "C_OSFolderCleanFlag=N" & SET "C_RebootFlag=R")

:Path_Push
:: Check for network paths, assign temporary drive letter IF found.
SET "pd=%~dp0"
pushd %pd%
SET "D_CurrentDirectory=%cd%"

:Slash
:: Strip all trailing backslash from path.  \\ should become \ then nothing.
IF [%D_CurrentDirectory:~-1%]==[\] SET "D_CurrentDirectory=%D_CurrentDirectory:~0,-1%"
IF [%D_CurrentDirectory:~-1%]==[\] GOTO Slash
cls

rem :: SET LOG=nul & IF [%1] NEQ [] (IF /I [%1] NEQ [Q] (SET LOG=%1) & IF /I [%1] EQU [V] (SET LOG=CON))
SET "LOG=%SystemDrive%\%~n0.log"

:OS_check
IF EXIST WMIC (
FOR %%i IN (Caption BuildNumber ProductType) DO (
  SET T_CMD=%%i
  FOR /F "tokens=1* delims==" %%A IN ('WMIC OS GET !T_CMD! /FORMAT:list') DO (SET "F_%%A=%%B")>nul
  )
  ) ELSE (
  FOR /F "tokens=2*" %%A IN ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber') DO SET F_BuildNumber=%%B
  FOR /F "tokens=2*" %%A IN ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName') DO SET F_Caption=%%B
  FOR /F "tokens=2*" %%A IN ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v InstallationType') DO SET F_ProductType=%%B
)
SET "T_CMD="
IF '%ERRORLEVEL%'=='0' CLS
FOR %%i IN (2600 3790 2715) DO (IF /I "%F_BuildNumber%"=="%%i" SET "F_OSBuild=NT5")
FOR %%i IN (6000 6001 6002 7600 7601 7602 9200 9369 9385) DO (IF /I "%F_BuildNumber%"=="%%i" SET "F_OSBuild=NT6")
SET "F_OSType=WINXP"
FOR %%i IN (6000 6001 6002) DO (IF /I "%F_BuildNumber%"=="%%i" SET "F_OSType=VISTA")
FOR %%i IN (7600 7601 7602) DO (IF /I "%F_BuildNumber%"=="%%i" SET "F_OSType=WIN7")
FOR %%i IN (9200 9369 9385) DO (IF /I "%F_BuildNumber%"=="%%i" SET "F_OSType=WIN8")
FOR %%i IN (Server 2 3) DO (IF /I "%F_ProductType%"=="%%i" SET "F_OSType=SERVER")
IF NOT DEFINED F_OSBuild GOTO Error1

ECHO. & ECHO Locating the DriverPacks...
SET "F_Method=0"
IF /I "%F_OSBuild%"=="NT6" GOTO Elevate

:Processor
:: Detect OS bit-ness on running system.  Assumes 32-bit unless 64-bit components exist.
SET "F_OSbit=32" & SET "D_DPSLocation=%D_CurrentDirectory%\%F_OSBuild%\x86" & SET "F_CPUarch=X86"
IF /I EXIST "%SystemRoot%\SysWOW64\cmd.exe" (SET "F_OSbit=64" & SET "F_CPUarch=X64" & SET "D_DPSLocation=%D_CurrentDirectory%\%F_OSBuild%\x64") ELSE (
  IF DEFINED PROCESSOR_ARCHITEW6432 (SET "F_OSbit=64" & SET "F_CPUarch=X64" & SET "D_DPSLocation=%D_CurrentDirectory%\%F_OSBuild%\x64")
)

:ZipCheck
SET "F_7Zip=N"
IF /I EXIST "%programfiles%\7-Zip\7z.exe" (SET "O_7ZipExe=%programfiles%\7-Zip\7z.exe" & SET "F_7Zip=Y" & GOTO ZipFound)
IF /I EXIST "%D_CurrentDirectory%\bin\%F_OSbit%\7z.exe" (SET "O_7ZipExe=%D_CurrentDirectory%\bin\%F_OSbit%\7z.exe" & SET "F_7Zip=Y" & GOTO ZipFound)

:ZipFound
IF /I NOT EXIST "%O_7ZipExe%" SET "F_7Zip=N"

:Method_Check
:: Double check for XP-64.  Delete the below line to force usage for XP-64 (NOT supported, you're on your own!).
IF /I "%F_OSBuild%"=="NT5" (IF /I "%F_OSbit%"=="64" GOTO Error1)
:: Determine DriverPack method.
IF /I EXIST "%D_CurrentDirectory%\DP*.7z" (SET "D_DPSLocation=%D_CurrentDirectory%" & SET "F_Method=2" & GOTO Found)
IF /I EXIST "%D_CurrentDirectory%\D\" (SET "D_DPSLocation=%D_CurrentDirectory%" & SET "F_Method=1" & GOTO Message2)
IF /I EXIST "%D_DPSLocation%\D\" (SET "F_Method=1" & GOTO Message2)
IF /I EXIST "%D_DPSLocation%\DP_*.7z" (SET "F_Method=2" & GOTO Found)
FOR %%i IN (3 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO (IF /I EXIST "%D_DPSLocation%\%%i\" (SET "F_Method=1" & GOTO Message2))
ECHO Searching Root folders since DriverPacks were not found in current folder...
FOR %%i IN (C D E F G H I J K L M N O P Q R S T U V W X Y) DO (
 IF /I EXIST "%%i:\OEM\bin\un7zip.exe" (SET "F_Method=2")
 IF /I EXIST "%%i:\$OEM$\$1\D\" (SET "D_DPSLocation=%%i:\$OEM$\$1" & SET "F_Method=1" & %%i)
 IF "%F_Method%" GEQ "1" GOTO Message2
 )
ECHO. & ECHO Strange... The DriverPacks were not found in %D_DPSLocation% & ECHO. & ECHO Press any key to exit... & PAUSE > nul & GOTO BYE

:Found
FOR /F "delims=" %%d IN ('DIR /B /S "%D_DPSLocation%\DP*.7z"') DO (
  IF NOT DEFINED dpsCount (SET /a dpsCount=1) ELSE (SET /a dpsCount+=1)
  SET F_dpsCount=!dpsCount!
  )
SET "dpsCount="
IF /I "%F_7Zip%"=="Y" GOTO Message2
IF /I NOT EXIST "%D_CurrentDirectory%\bin\un7zip.exe" GOTO Error2

:Message2
SET "C_KeepHID="
IF /I "%C_SilentFlag%"=="Y" GOTO Lets_GO

cls
SETlocal
ECHO      **************************** %S_Version% ****************************
ECHO         Released under Creative Commons Attribution-ShareAlike license
ECHO                   %username% please read below carefully.     
ECHO.
ECHO                  Operating System Architecture Detected:
ECHO           %F_Caption% %F_OSbit%-bit on %PROCESSOR_ARCHITECTURE% compatible CPU
ECHO            CPU: %PROCESSOR_IDENTIFIER%             
ECHO.
ECHO                 %F_OSbit%-bit DriverPacks will be installed from 
ECHO                 %D_DPSLocation% using method: %F_Method%
ECHO                Native 7-zip command line application found? %F_7Zip%
ECHO.
ECHO      *********************************************************************
ECHO            Do you want to Keep The Drivers (KTD) after install?
ECHO        Answer Y/N  (Y- will keep all drivers unless deleted manually)
ECHO      *********************************************************************

:KTD_option
SET /p C_KTDFlag=[Y,N]?
IF /I NOT "%C_KTDFlag%"=="Y" (SET "C_KTDFlag=N")

ECHO.
ECHO.
ECHO      *********************************************************************
ECHO                    Do you wish to create a restore point?
ECHO                                 Answer Y/N          
ECHO      *********************************************************************
SET /p C_CreateRestorePoint=[Y,N]?
IF /I NOT "%C_CreateRestorePoint%"=="Y" (SET "C_CreateRestorePoint=N" & GOTO :Clean_Option)

:Create_Restore_Point
IF /I EXIST "%D_CurrentDirectory%\bin\crp.vbs" (start /w %windir%\System32\wscript.exe "%D_CurrentDirectory%\bin\crp.vbs")
ECHO.
ECHO Restore point created successfuly.
ECHO.

:Clean_Option
IF /I "%F_OSBuild%"=="NT5" GOTO Lets_GO
ECHO.
ECHO      *********************************************************************
ECHO             Do you want to remove drivers not needed by this OS?
ECHO            Answer Y/N  (N- will use all drivers from every folder)
ECHO      *********************************************************************
SET /p C_OSFolderCleanFlag=[Y,N]?
IF /I NOT "%C_OSFolderCleanFlag%"=="Y" (SET "C_OSFolderCleanFlag=N")

:Lets_GO
ECHO.
IF /I "%C_KTDFlag%"=="Y" ECHO KTD option has been enabled.
IF /I "%C_OSFolderCleanFlag%"=="Y" ECHO Unnecessary drivers will be deleted prior to integration.
SET O_DPSFinisherINI=%SystemDrive%\DPsFnshr.ini
IF /I NOT EXIST "%SystemDrive%\D\" MD "%SystemDrive%\D\"
ECHO. & ECHO Extracting the DriverPacks %F_OSbit%-bit core files.
IF /I "%F_7Zip%"=="Y" (
  Start /wait /separate /high /min "" "%O_7ZipExe%" x "%D_CurrentDirectory%\bin\%F_OSbit%\dpinst-%F_OSBuild%.7z" -o"%SystemDrive%\D\"
  ) ELSE (
  Start /wait /separate /high /min "" "%D_CurrentDirectory%\bin\un7zip.exe" -aoa "%D_CurrentDirectory%\bin\%F_OSbit%\dpinst-%F_OSBuild%.7z" %SystemDrive%\D\
)

:Method1
IF "%F_Method%"=="1" (
  ECHO. & ECHO Preparing the DriverPacks files. Method 1 was found. & ECHO.
  IF NOT "%D_DPSLocation%"=="%SystemDrive%" (ECHO Copying Driverpacks files & XCOPY "%D_DPSLocation%\." "%SystemDrive%\D\." /E /H)
  ECHO>"%O_DPSFinisherINI%" [Settings]
  ECHO>>"%O_DPSFinisherINI%" DPsRoot = "%D_DPSLocation%"
  ECHO>>"%O_DPSFinisherINI%" DPsRootDel = "false"
  ECHO>>"%O_DPSFinisherINI%" debug = "true"
  CD %D_DPSLocation%\D
)

:Method2
IF "%F_Method%"=="2" (
  ECHO. & ECHO Preparing the DriverPacks now. Method 2 was found. & ECHO.
  ECHO Extracting %F_dpsCount% DriverPacks from: %D_DPSLocation%
  SET "T_Title=Extracting DriverPack"
  SET "F_TempDPScount=1"
  IF /I "%F_7Zip%"=="Y" (
    ECHO Using native 7-Zip
    FOR %%f IN ("%D_DPSLocation%\DP_*.7z") DO (
      @TITLE -Working- !T_Title! !F_TempDPScount! of %F_dpsCount%
      ECHO Extracting DriverPack !F_TempDPScount! of %F_dpsCount%
      IF /I "%F_OSBuild%"=="NT5" (Start /wait /separate /high /min "" "%O_7ZipExe%" x "%%f" -o"%SystemDrive%\")
      IF /I "%F_OSBuild%"=="NT6" (Start /wait /separate /high /min "" "%O_7ZipExe%" x "%%f" -o"%SystemDrive%\D\")
      SET /a "F_TempDPScount=!F_TempDPScount!+1"
      )
    ) ELSE (
    FOR %%f IN ("%D_DPSLocation%\DP_*.7z") DO (
      @TITLE -Working- !T_Title! !F_TempDPScount! of %F_dpsCount%
      ECHO Extracting DriverPack !F_TempDPScount! of %F_dpsCount%
      IF /I "%F_OSBuild%"=="NT5" (Start /wait /separate /high /min "" "%D_CurrentDirectory%\bin\un7zip.exe" -aoa "%%f" %SystemDrive%\)
      IF /I "%F_OSBuild%"=="NT6" (Start /wait /separate /high /min "" "%D_CurrentDirectory%\bin\un7zip.exe" -aoa "%%f" %SystemDrive%\D\)
      SET /a "F_TempDPScount=!F_TempDPScount!+1"
      )
    )
  TITLE %S_Title%
  SET "F_TempDPScount="
  IF /I "%F_OSBuild%"=="NT6" GOTO Begin
  IF /I EXIST "%D_DPSLocation%\*.ins" (COPY /Y "%D_DPSLocation%\*.ins" %SystemDrive%\)
  IF /I "%F_7Zip%"=="Y" (
    Start /wait /separate /high /min "" "%O_7ZipExe%" x "%D_CurrentDirectory%\bin\DPsFnshr.7z" -o"%SystemDrive%\"
    ) ELSE (
    Start /wait /separate /high /min "" "%D_CurrentDirectory%\bin\un7zip.exe" -aoa "%D_CurrentDirectory%\bin\DPsFnshr.7z" %SystemDrive%\
    )
  %SystemDrive% & cd %SystemDrive%\D
  ECHO>"%O_DPSFinisherINI%" [Settings]
  ECHO>>"%O_DPSFinisherINI%" DPsRoot = "%SystemDrive%"
  ECHO>>"%O_DPSFinisherINI%" DPsRootDel = "true"
  ECHO>>"%O_DPSFinisherINI%" debug = "true"
)

:Skip_KTD
IF /I "%C_KTDFlag%"=="Y" (ECHO>>"%O_DPSFinisherINI%" KTD = "paths:D") ELSE (ECHO>>"%O_DPSFinisherINI%" KTD = "false")
ECHO>>"%O_DPSFinisherINI%" KTDlocation = "%SystemRoot%\DriverPacks"
ECHO>>"%O_DPSFinisherINI%" logLocation = "%SystemRoot%"

:Begin
IF /I NOT EXIST "%SystemDrive%\Touchpad HID\" MD "%SystemDrive%\Touchpad HID\"
IF /I "%F_OSBuild%"=="NT6" (
  FOR %%f IN ("%D_DPSLocation%\DP_Touchpad*.7z") DO Start /wait /separate /high /min "" "%O_7ZipExe%" x "%%f" -aoa -o"%SystemDrive%\Touchpad HID\"
  ) ELSE (
  FOR %%f IN ("%D_DPSLocation%\DP_HID*.7z") DO Start /wait /separate /high /min "" "%O_7ZipExe%" x "%%f" -aoa -o"%SystemDrive%\Touchpad HID\"
)
:: Remove known problem Touchpad HID drivers from driver pool
FOR %%i IN ("%SystemDrive%\D\Known-problems*.txt") DO (FOR /F "eol=; tokens=* delims=" %%D IN (%%i) DO (IF /I EXIST "%SYSTEMDRIVE%\D\%%D" RENAME "%SYSTEMDRIVE%\D\%%D" "%%~nxD.bak"))

:Clean_Warn
IF /I "%C_OSFolderCleanFlag%"=="N" GOTO Begin2
IF /I "%F_OSBuild%"=="NT5" GOTO Begin2
ECHO. & ECHO OS Type is %F_OSType% & ECHO.
IF /I "%F_OSType%"=="SERVER" (FOR %%i IN (Vista Win7 Win8) DO (ECHO Drivers will be deleted from "%SystemDrive%\D\%F_CPUarch%\%%i"))
IF /I "%F_OSType%"=="VISTA" (FOR %%i IN (Server Win7 Win8) DO (ECHO Drivers will be deleted from "%SystemDrive%\D\%F_CPUarch%\%%i"))
IF /I "%F_OSType%"=="WIN7" (FOR %%i IN (Server Vista Win8) DO (ECHO Drivers will be deleted from "%SystemDrive%\D\%F_CPUarch%\%%i"))
IF /I "%F_OSType%"=="WIN8" (FOR %%i IN (Server Vista) DO (ECHO Drivers will be deleted from "%SystemDrive%\D\%F_CPUarch%\%%i"))
IF /I "%C_SilentFlag%"=="Y" GOTO Clean_Folder
ECHO.
ECHO This is your final warning before uneeded drivers are deleted!
PAUSE

:Clean_Folder
IF /I "%C_OSFolderCleanFlag%"=="N" GOTO Begin2
IF /I "%F_OSType%"=="SERVER" (FOR %%i IN (Vista Win7 Win8) DO (IF /I EXIST "%SystemDrive%\D\%F_CPUarch%\%%i" RD /S /Q "%SystemDrive%\D\%F_CPUarch%\%%i\"))
IF /I "%F_OSType%"=="VISTA" (FOR %%i IN (Server Win7 Win8) DO (IF /I EXIST "%SystemDrive%\D\%F_CPUarch%\%%i" RD /S /Q "%SystemDrive%\D\%F_CPUarch%\%%i\"))
IF /I "%F_OSType%"=="WIN7" (FOR %%i IN (Vista Server Win8) DO (IF /I EXIST "%SystemDrive%\D\%F_CPUarch%\%%i" RD /S /Q "%SystemDrive%\D\%F_CPUarch%\%%i\"))
IF /I "%F_OSType%"=="WIN8" (FOR %%i IN (Vista Server) DO (IF /I EXIST "%SystemDrive%\D\%F_CPUarch%\%%i" RD /S /Q "%SystemDrive%\D\%F_CPUarch%\%%i\"))

ECHO.
ECHO Excess drivers deleted!  
IF /I "%C_SilentFlag%"=="Y" GOTO Begin2
PAUSE

:Begin2
%SystemDrive% & cd %SystemDrive%\D
cls
ECHO      *********************************************************************
ECHO.
ECHO                 Running the MicroSoft Driver Installer now !
ECHO.
ECHO              The progress window is minimized to the task bar. & ECHO. & ECHO.
ECHO.
ECHO           Please wait for the MicroSoft tool to complete its job...
ECHO       This may take from 2-30 minutes depending on the speed of this PC.
ECHO.
ECHO      *********************************************************************
Start "MicroSoft Driver Installer Tool Running" /wait /separate /realtime /min CMD /C DPInst.exe /c /s
IF "%F_OSBuild%"=="NT6" GOTO Log_File

:Finisher
ECHO. & ECHO Running the DriverPacks Finisher now! & ECHO.
%SystemDrive% & cd\ & Start /wait /separate /high "" DPsFnshr.exe

:Log_File
:: Log and Attended output section
ECHO>>"%LOG%" %S_Version% Log and Attended output section & ECHO>>"%LOG%" *
IF /I [%1] NEQ [Q] (
  IF [LOG] NEQ [nul] (
  ECHO>>"%LOG%" *
  ECHO>>"%LOG%" Method %F_Method% was found at:
  ECHO>>"%LOG%" %D_DPSLocation%
  ECHO>>"%LOG%" List INF's that were matched with this system
  FOR /F "usebackq tokens=2,3,*" %%G IN (`type %windir%\dpinst.log`) DO (
   IF /I "%%G"=="Successfull" (IF /I "%%H"=="installation" ECHO>>"%LOG%" %%G %%H %%I)
   )
))

:Final_Message
cls
ECHO      ********************************************************************* & ECHO.
ECHO        The DriverPacks Stand Alone Driver installation is complete! & ECHO.
ECHO             The dpinst log file can be found in %windir%\DPINST.log
ECHO             The main log file can be found in %LOG%
ECHO.
IF /I "%C_KTDFlag%"=="Y" (
IF /I "%F_OSBuild%"=="NT6" (
  ECHO                  Drivers can be found for NT6 in %SystemDrive%\D\
  ) ELSE (
  ECHO           Drivers can be found for NT5 in %systemroot%\Driverpacks
)
ECHO. & ECHO.
)

:Cleaning_Phase
FOR %%i IN ("%SystemDrive%\D\known-problems*.txt") DO (FOR /F "eol=; tokens=* delims=" %%D IN (%%i) DO (IF /I EXIST "%SYSTEMDRIVE%\D\%%D.bak" RENAME "%SYSTEMDRIVE%\D\%%D.bak" "%%~nxD"))
ECHO  Please check Device Manager to see if Touchpad driver installed correctly.
IF /I "%C_KTDFlag%"=="Y" (
  ECHO            If not, then use Device Manager to install manually.
  SET "C_KeepHID=Y"
  GOTO HID_Clean
  ) ELSE (
  SET "C_KeepHID=N"
  )
IF /I "%C_SilentFlag%"=="Y" (
  GOTO Cleaning2
  )
ECHO.
ECHO    If Touchpad Driver didn't install correctly, do you wish to keep the 
ECHO           Touchpad HID Drivers to reinstall using Device Manager? 
ECHO. 
ECHO                ( "Y" to Keep or "N" to delete directory )
ECHO.
SET /p C_KeepHID=[Y,N]?
IF /I "%C_KeepHID%"=="Y" (GOTO Cleaning2) ELSE (SET "C_KeepHID=N")

:HID_Clean
IF /I NOT "%C_KeepHID%"=="Y" (
  IF /I EXIST "%SYSTEMDRIVE%\Touchpad HID\" RD /S /Q "%SYSTEMDRIVE%\Touchpad HID\" >nul
  IF /I EXIST "%SYSTEMDRIVE%\Touchpad\" RD /S /Q "%SYSTEMDRIVE%\Touchpad\" >nul
)

:Cleaning2
IF /I EXIST "%SYSTEMDRIVE%\DPsFnshr.exe" (
  DEL /F /S /Q "%SYSTEMDRIVE%\DPsFnshr.exe"
  REG DELETE "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "DriverPacks Finisher final cleanup" /f
) >nul
IF /I "%C_KeepHID%"=="Y" (ECHO. & ECHO              Touchpad HID Drivers can be found in %SYSTEMDRIVE%\Touchpad HID\)
IF /I "%C_KTDFlag%"=="Y" GOTO Timer
ECHO.
ECHO Cleanup phase...
ECHO.
cd %SYSTEMDRIVE%
cd \
IF /I EXIST "%SYSTEMDRIVE%\D\x86\*" DEL /F /S /Q "%SYSTEMDRIVE%\D\x86\*" >nul
IF /I EXIST "%SYSTEMDRIVE%\D\x64\*" DEL /F /S /Q "%SYSTEMDRIVE%\D\x64\*" >nul
IF /I EXIST "%SYSTEMDRIVE%\D" (IF /I NOT EXIST "%SYSTEMDRIVE%\D\SAD3" RD /S /Q "%SYSTEMDRIVE%\D\") >nul
IF /I "%C_KeepHID%"=="Y" (GOTO Timer)
IF /I EXIST "%SYSTEMDRIVE%\Touchpad HID\*" DEL /F /S /Q "%SYSTEMDRIVE%\Touchpad HID\*" >nul
IF /I EXIST "%SYSTEMDRIVE%\Touchpad HID\" RD /S /Q "%SYSTEMDRIVE%\Touchpad HID\" >nul

:Timer
 IF /I "%C_SilentFlag%"=="Y" GOTO Continue
 ECHO. & ECHO           Do you wish to keep the Log files or delete them?
 ECHO         Answer Y/N ( "Y" keeps Log files or "N" to delete them )
 SET /p C_KeepLog=[Y,N]?
 IF /I "%C_KeepLog%"=="Y" (GOTO Continue)
 ECHO.
 ECHO Searching for and deleting Log files.  Please stand by...
 ECHO.
 IF /I EXIST "%WINDIR%\DPsFnshr.*" (
 DEL /F /S /Q "%WINDIR%\DPsFnshr.*"
 ) >nul
 IF /I EXIST "%WINDIR%\DPINST.*" (
 DEL /F /S /Q "%WINDIR%\DPINST.*"
 ) >nul
 IF /I EXIST "%WINDIR%\DtcInstall.*" (
 DEL /F /S /Q "%WINDIR%\DtcInstall.*"
 ) >nul
 IF /I EXIST "%WINDIR%\0.*" (
 DEL /F /S /Q "%WINDIR%\0.*" 
 ) >nul 
 IF /I EXIST "%SYSTEMDRIVE%\%~n0.log" (
 DEL /F /S /Q "%SYSTEMDRIVE%\%~n0.log"
 ) >nul
 ECHO.

:Continue
IF /I "%C_SilentFlag%"=="Y" GOTO Done
ECHO                    This window will close in 10 seconds... & ECHO.
FOR /l %%A in (1,1,10) do (<nul (SET/p z=#) & >nul ping 127.0.0.1 -n 2 )
ECHO # & ECHO Done!   
ECHO. 
ECHO      *********************************************************************
SET "O_TADA=%temp%\tada.vbs"
IF /I NOT EXIST "%O_TADA%" (
  ECHO>"%O_TADA%" Set oVoice = CreateObject^("SAPI.SpVoice"^)
  ECHO>>"%O_TADA%" Set oSpFileStream = CreateObject^("SAPI.SpFileStream"^)
  ECHO>>"%O_TADA%" On Error Resume Next
  ECHO>>"%O_TADA%" oSpFileStream.Open "%windir%\Media\tada.wav"
  ECHO>>"%O_TADA%" oVoice.SpeakStream oSpFileStream
  ECHO>>"%O_TADA%" oSpFileStream.Close
  START /W %windir%\System32\wscript.exe "%O_TADA%"
  DEL /F /Q "%O_TADA%"
) >nul

:Done
IF /I "%C_RebootFlag%"=="R" GOTO SD
IF /I "%C_RebootFlag%"=="X" GOTO BYE
ECHO.
ECHO.
ECHO.
ECHO      *********************************************************************
ECHO      Your system must be restarted in order to finish driver installation!
ECHO.
ECHO                    Do you wish to restart now or just exit?
ECHO                    ( Press "R" to restart or "X" to exit. )
ECHO      *********************************************************************
ECHO.
SET /p C_RebootFlag=[R,X]?
IF /I "%C_RebootFlag%"=="R" (GOTO SD)

:BYE
popd
endlocal
EXIT
REM DEL /F /Q %0% >nul

:SD
cscript //B "%windir%\system32\slmgr.vbs" /ato
:: Remove the following line to disable switching to the default Aero theme
%windir%\Resources\Themes\aero.theme
shutdown -r -c "Drivers installed. Restarting."
:: START C:\Drivers\RemoveD.cmd
popd
endlocal
EXIT
REM DEL /F /Q %0% >nul

:Functions_and_Errors
:Error1
CALL :Error_Start
ECHO *                      %F_Caption%
ECHO *                   Which uses %F_OSBuild% DriverPacks
ECHO *                   Not currently supported
CALL :Error_Stop
GOTO EOF

:Error2
CALL :Error_Start
ECHO *                       un7zip.exe is missing.
CALL :Error_Stop
GOTO EOF

:Error3
CALL :Error_Start
ECHO                   Invalid Operating System Detected:
ECHO.
ECHO                         %F_Caption% %F_OSbit%-bit OS
ECHO                     Installed on %PROCESSOR_ARCHITECTURE% processor
ECHO                     Not currently supported
CALL :Error_Stop
GOTO EOF

:Error_Start
cls
ECHO      *********************************************************************
ECHO. & ECHO                             %username% & ECHO.
GOTO EOF

:Error_Stop
ECHO. & ECHO                      Please exit the program now! & ECHO.
ECHO      *********************************************************************
pause
GOTO EOF

:Usage
ECHO.
ECHO %~nx0 is an batch program to automate the 
ECHO installation of drivers on any Windows system.
ECHO.
ECHO The switches /? or /h or /H will bring up this guide.
ECHO You may use either a slash '/' or dash '-' with switches.
ECHO Usage is %~nx0 {/? ! -? ! /h ! -h ! /H ! -H}
ECHO.
ECHO /S or /SR or /K or /KR or /C or /CR will enable "Silent" mode 
ECHO   which will not prompt for options but will execute
ECHO   the batch with whatever options are set as default.
ECHO.
ECHO Examples:
ECHO    "/S"  Silent install, Touchpad/HID drivers kept, exit no reboot.
ECHO    "/SR" Silent install, Touchpad/HID drivers kept, exit and auto reboot.
ECHO.
ECHO    "/K"  Silent install, keeps only drivers for your OS, exit no reboot.
ECHO    "/KR" Silent install, keeps only drivers for your OS, exit and auto reboot.
ECHO.  
ECHO    "/C"  Silent install, keeps all drivers, exit no reboot.
ECHO    "/CR" Silent install, keeps all drivers, exit and auto reboot.
ECHO.
ECHO      *** Use Only One Silent Install Switch ***
ECHO.
ECHO Options to create restore point, delete Log file and Touchpad HID drivers
ECHO are disabled when using silent install switches. 
ECHO.
ECHO Running %~nx0 requires Administrator rights!
ECHO. & ECHO.
ECHO Press any key to return to the command prompt...
PAUSE > nul
GOTO EOF

:Elevate
::checkPrivileges 
MKDIR "%windir%\OEAdminCheck" 
IF '%errorlevel%' == '0' (RMDIR "%windir%\OEAdminCheck" & GOTO gotPrivileges) ELSE (GOTO getPrivileges) 
:getPrivileges 
CLS
SET "O_OEGP=%temp%\OEgetPrivileges.vbs"
ECHO>"%O_OEGP%" Set UAC = CreateObject^("Shell.Application"^)
IF DEFINED PARAMS (
  ECHO>>"%O_OEGP%" UAC.ShellExecute "%~dpnx0", "%params%", "", "runas", 1
  ) ELSE (
  ECHO>>"%O_OEGP%" UAC.ShellExecute "%~dpnx0", "", "", "runas", 1
)
START /W %windir%\System32\wscript.exe "%O_OEGP%"
EXIT /B
:gotPrivileges
IF /I EXIST "%O_OEGP%" (DEL /F /Q "%O_OEGP%") >nul
GOTO Processor

:EOF
