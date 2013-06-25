@ECHO off
net stop "FOG Service"
::Except otherwise noted, the open-source code of the DP_Install_Tool.cmd file is © 2011-2012 by Erik Hansen for DriverPacks.net, under a Creative Commons Attribution-ShareAlike license: http://creativecommons.org/licenses/by-sa/3.0/.
::7-Zip is open source software by Igor Pavlov. Most of the source code is under the GNU LGPL license. The unRAR code is under a mixed license: GNU LGPL + unRAR restrictions. Check license information here: http://www.7-zip.org/license.txt or http://www.gnu.org/licenses/lgpl.html
::DPInst.exe is proprietary code owned completely by Microsoft and distributed under their own license. (see .\bin\*\dpinst-license.rtf)

 :: rev 12.05.20
 :: Originally written by Jeff Herre AKA OverFlow, significantly rewritten by Erik Hansen AKA Mr_Smartepants. 
 :: Modified by Brent Newland (casipc.com) to support network shares and UAC elevation
 :: A Script to use Microsoft's DPInst.exe with the DriverPacks.
 :: Help and Support available at http://forum.driverpacks.net/viewtopic.php?id=5336
 :: This script assumes that the original folder structure of the downloaded archive remains intact.
 :: Please do not alter the folder structure unless you REALLY know what you are doing and alter the below code accordingly. 
 
 :: Changelog:
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
 :: Fixed bug with extra space in %ARCH% variable

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

:Default-options
:: Change SILENT option to "Y" if you want to bypass all prompts but make sure the next two options are set to your preferences first.
SET "SILENT=N"
:: KTD option.  Default is "N", "Y" will not delete any drivers from the %systemdrive%\D\ folder.
SET "KTD=N"
:: OS folder clean option.  Default is "N", "Y" will delete any drivers for OS folders not needed.
SET "CLEAN=N"

:Help-options
IF "%1"=="/?" goto usage
IF /I "%1"=="/h" goto usage
IF /I "%1"=="/S" SET "SILENT=Y"
::if "%1"=="/K" SET "KTD=Y"
::if "%1"=="/C" SET "CLEAN=Y"

:: Check for network paths, assign temporary drive letter IF found.
SET pd=%~dp0
pushd %~dp0
SET cur=%cd%

:slash
:: Strip all trailing backslash from path.  \\ should become \ then nothing.
IF [%cur:~-1%]==[\]             SET "cur=%cur:~0,-1%"
IF [%cur:~-1%]==[\] GOTO slash
cls

TITLE DriverPacks.net Stand Alone Driver Updater v2.0 & Color 9f

SET LOG=nul & IF [%1] NEQ [] (IF /I [%1] NEQ [Q] (SET LOG=%1) & IF /I [%1] EQU [V] (SET LOG=CON))
SET msg2=%msg% %username%

:OS-check
FOR /F "tokens=2*" %%A IN ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber') DO SET build=%%B
FOR /F "tokens=2*" %%A IN ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName') DO SET prodname=%%B
FOR /F "tokens=2*" %%A IN ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v InstallationType') DO SET installtype=%%B
FOR %%i IN (2600 3790) DO (
IF /I "%build%"=="%%i" SET "OSbuild=NT5"
  )
FOR %%i IN (6000 6001 6002 7600 7601 7602) DO (
IF /I "%build%"=="%%i" SET "OSbuild=NT6"
  )
SET "OSTYPE=WINXP"
FOR %%i IN (6000 6001 6002) DO (
IF /I "%build%"=="%%i" SET "OSTYPE=VISTA"
  )
FOR %%i IN (7600 7601 7602) DO (
IF /I "%build%"=="%%i" SET "OSTYPE=WIN7"
  )
IF /I "%INSTALLTYPE%"=="Server" SET "OSTYPE=SERVER"

ECHO. & ECHO Locating the DriverPacks...
SET "M=0"
IF /I "%OSbuild%"=="NT6" GOTO Elevate

:PROCESSOR
:: Detect OS bit-ness on running system.  Assumes 32-bit unless 64-bit components exist.
SET "ARCH=32" & SET "DPLoc=%cur%\%OSbuild%\x86"
IF EXIST "%SystemRoot%\SysWOW64" (SET "ARCH=64" & SET "DPLoc=%cur%\%OSbuild%\x64") ELSE (
  IF DEFINED PROCESSOR_ARCHITEW6432 (SET "ARCH=64" & SET "DPLoc=%cur%\%OSbuild%\x64")
)

:ZipCheck
SET "zip=N"
IF EXIST "%programfiles%\7-Zip\7z.exe" (SET "zpath=%programfiles%\7-Zip\7z.exe" & SET "zip=Y" & GOTO ZipFound)
IF EXIST "%cur%\bin\%ARCH%\7z.exe" (SET "zpath=%cur%\bin\%ARCH%\7z.exe" & SET "zip=Y" & GOTO ZipFound)

:ZipFound
IF not EXIST "%zpath%" SET "zip=N"

:DoubleCheck
IF /I "%OSbuild%"=="NT5" GOTO Method5
IF /I "%OSbuild%"=="NT6" GOTO Method6
GOTO Error1

:Method5
::Double check for XP-64.  Delete the below line to force usage for XP-64 (NOT supported, you're on your own!).
IF /I "%ARCH%"=="64" GOTO Error1
IF EXIST "%cur%\D\"             (SET "DPLoc=%cur%" & SET "M=1" & GOTO Message2)
IF EXIST "%DPLoc%\D\"           (SET "M=1" & GOTO Message2)
IF EXIST "%DPLoc%\DP_*.7z"      (SET "M=2" & GOTO Found)
IF EXIST "%cur%\DP_*.7z"        (SET "DPLoc=%cur%" & SET "M=2" & GOTO Found)
ECHO Searching Root folders since DriverPacks were not found in current folder...
FOR %%i IN (C D E F G H I J K L M N O P Q R S T U V W X Y) DO (
 IF EXIST "%%i:\OEM\bin\un7zip.exe" SET "M=2"
 IF EXIST "%%i:\$OEM$\$1\D\"   (SET "DPLoc=%%i:\$OEM$\$1" & SET "M=1" & %%i)
 IF "%M%">="1" GOTO Message2
 )
ECHO. & ECHO Strange... The DriverPacks were not found in %DPLoc% & ECHO. & Pause & GOTO Done

:Method6
IF "%ARCH%"=="32" SET "ARCHP=X86" 
IF "%ARCH%"=="64" SET "ARCHP=X64" 
FOR %%i IN (3 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO (
  IF EXIST "%DPLoc%\%%i\"    SET "M=1" & GOTO Message2
  )
IF EXIST "%DPLoc%\DP_*.7z" (SET "M=2" & GOTO Found)
ECHO. & ECHO Strange... The DriverPacks were not found in %DPLoc% & ECHO. & Pause & GOTO Done

:Found
IF /I "%zip%"=="Y" GOTO Message2
IF not EXIST "%cur%\bin\un7zip.exe" GOTO Error2

:Message2
IF /I "%SILENT%"=="Y" GOTO Lets-GO
::Reset variables to defaults
SET "KTD=N"
SET "CLEAN=N"

cls
SETlocal
ECHO      ********************************************************************
ECHO         Released under Creative Commons Attribution-ShareAlike license
ECHO                   %msg2% please read below carefully.     
ECHO.
ECHO                  Operating System Architecture Detected:
ECHO           %prodname% %ARCH%-bit on %PROCESSOR_ARCHITECTURE% compatible CPU
ECHO            CPU: %PROCESSOR_IDENTIFIER%             
ECHO.
ECHO                 %ARCH%-bit DriverPacks will be installed from 
ECHO               %DPLoc% using method: %M%
ECHO                Native 7-zip command line application found? %zip%
ECHO.
ECHO               IF this is NOT intended, exit the program now!
ECHO      ********************************************************************
ECHO            Do you want to Keep The Drivers (KTD) after install?
ECHO        Answer Y/N  (Y- will keep all drivers unless deleted manually)
ECHO      ********************************************************************

:KTD-option
SET option=n
IF /I "%option%"=="Y" SET "KTD=Y"
IF /I "%KTD%"=="Y" ECHO KTD option has been enabled. 

:Message3
IF /I "%OSbuild%"=="NT5" GOTO Lets-GO
ECHO.
ECHO      ********************************************************************
ECHO            Do you want to remove drivers not needed by this OS?
ECHO            Answer Y/N  (N- will use all drivers from every folder)
ECHO      ********************************************************************

:CLEAN-option
SET option=y
IF /I "%option%"=="Y" SET "CLEAN=Y"
IF /I "%CLEAN%"=="Y" ECHO Unnecessary drivers will be deleted prior to integration. 

:Lets-GO
SET DPFL=%SystemDrive%\DPsFnshr.ini
IF NOT EXIST "%SystemDrive%\D\" MD "%SystemDrive%\D\"

:dpinst
IF /I "%zip%"=="Y" GOTO dpinstNative
ECHO. & ECHO Extracting the DriverPacks %ARCH%-bit core files.
Start /wait /separate /high "" "%cur%\bin\un7zip.exe" "%cur%\bin\%ARCH%\dpinst.7z" %SystemDrive%\D\
GOTO Method1

:dpinstNative
ECHO. & ECHO Extracting the DriverPacks %ARCH%-bit core files using native 7-Zip.
Start /wait /separate /high "" "%zpath%" x "%cur%\bin\%ARCH%\dpinst.7z" -o"%SystemDrive%\D\"

:Method1
IF "%M%"=="1" (
  ECHO. & ECHO Preparing the DriverPacks files. Method 1 was found. & ECHO.
  IF NOT "%DPLoc%"=="%SystemDrive%" ECHO Copying Driverpacks files & XCOPY "%DPLoc%\." "%SystemDrive%\D\." /E /H
  ECHO [Settings]			 	>  %DPFL%
  ECHO DPsRoot     = "%DPLoc%"			>> %DPFL%
  ECHO DPsRootDel  = "false"			>> %DPFL%
  ECHO debug       = "true"			>> %DPFL%
  CD %DPLoc%\D
              )

:Method2
IF /I "%zip%"=="Y" GOTO Method2Native
IF "%M%"=="2" (
  ECHO. & ECHO Preparing the DriverPacks now. Method 2 was found. & ECHO.
  ECHO Extracting DriverPacks from: %DPLoc%
  FOR %%f IN ("%DPLoc%\DP_*.7z") DO Start /wait /separate /high "" "%cur%\bin\un7zip.exe" "%%f" %SystemDrive%\D\
  IF /I "%OSbuild%"=="NT6" GOTO Begin
  COPY /Y "%DPLoc%\*.ins" 			%SystemDrive%\
  Start /wait /separate /high "" "%cur%\bin\un7zip.exe" "%cur%\bin\DPsFnshr.7z" %SystemDrive%\
  %SystemDrive% & cd %SystemDrive%\D
  ECHO [Settings]			 	>  %DPFL%
  ECHO DPsRoot     = "%SystemDrive%"		>> %DPFL%
  ECHO DPsRootDel  = "true"			>> %DPFL%
  ECHO debug       = "true"			>> %DPFL%
              )
GOTO SKIPKTD

:Method2Native
IF "%M%"=="2" (
  ECHO. & ECHO Preparing the DriverPacks now. Method 2 was found. & ECHO Using native 7-Zip
  ECHO Extracting DriverPacks from: %DPLoc%
  FOR %%f IN ("%DPLoc%\DP_*.7z") DO Start /wait /separate /high "" "%zpath%" x "%%f" -o"%SystemDrive%\D\"
  IF /I "%OSbuild%"=="NT6" GOTO Begin
  COPY /Y "%DPLoc%\*.ins" 			%SystemDrive%\
  Start /wait /separate /high "" "%zpath%" x "%cur%\bin\DPsFnshr.7z" -o"%SystemDrive%\"
  %SystemDrive% & cd %SystemDrive%\D
  ECHO [Settings]			 	>  %DPFL%
  ECHO DPsRoot     = "%SystemDrive%"		>> %DPFL%
  ECHO DPsRootDel  = "true"			>> %DPFL%
  ECHO debug       = "true"			>> %DPFL%
              )

:SKIPKTD
IF /I "%KTD%"=="Y" GOTO KEEPKTD
ECHO KTD         = "false"			>> %DPFL%
ECHO KTDlocation = "%SystemRoot%\DriverPacks"	>> %DPFL%
ECHO logLocation = "%SystemRoot%"		>> %DPFL%
GOTO Begin

:KEEPKTD
ECHO KTD         = "paths:D"			>> %DPFL%
ECHO KTDlocation = "%SystemRoot%\DriverPacks"	>> %DPFL%
ECHO logLocation = "%SystemRoot%"		>> %DPFL%

:Begin
IF /I "%CLEAN%"=="N" GOTO Begin2

:CLEAN-warn
ECHO OSTYPE is %OSTYPE%
IF /I "%OSTYPE%"=="SERVER" (
  ECHO drivers will be deleted from "%SystemDrive%\D\%ARCHP%\Vista\" 
  ECHO drivers will be deleted from "%SystemDrive%\D\%ARCHP%\Win7\" )
IF /I "%OSTYPE%"=="VISTA" (
  ECHO drivers will be deleted from "%SystemDrive%\D\%ARCHP%\Server\" 
  ECHO drivers will be deleted from "%SystemDrive%\D\%ARCHP%\Win7\" )
IF /I "%OSTYPE%"=="WIN7" (
  ECHO drivers will be deleted from "%SystemDrive%\D\%ARCHP%\Server\" 
  ECHO drivers will be deleted from "%SystemDrive%\D\%ARCHP%\Vista\" )
IF /I "%SILENT%"=="Y" GOTO CLEAN-folder
ECHO This is your final warning before drivers are deleted from unneeded OS folders.


:CLEAN-folder
IF /I "%OSTYPE%"=="SERVER" (
  RD /S /Q "%SystemDrive%\D\%ARCHP%\Vista\" 
  RD /S /Q "%SystemDrive%\D\%ARCHP%\Win7\" )
IF /I "%OSTYPE%"=="VISTA" (
  RD /S /Q "%SystemDrive%\D\%ARCHP%\Server\" 
  RD /S /Q "%SystemDrive%\D\%ARCHP%\Win7\" )
IF /I "%OSTYPE%"=="WIN7" (
  RD /S /Q "%SystemDrive%\D\%ARCHP%\Server\" 
  RD /S /Q "%SystemDrive%\D\%ARCHP%\Vista\" )
ECHO Excess drivers deleted!  
IF /I "%SILENT%"=="Y" GOTO Begin2


:Begin2
%SystemDrive% & cd %SystemDrive%\D
cls
ECHO      *********************************************************************
ECHO.
ECHO. & ECHO.
ECHO                 Running the MicroSoft Driver Installer now !
ECHO.
ECHO        The progress window is minimized to the task bar & ECHO. & ECHO.
ECHO. & ECHO.
ECHO          Please wait for the MicroSoft tool to complete its job...
ECHO       This may take from 2-30 minutes depending on the speed of this PC.
ECHO.
ECHO      *********************************************************************
Start "MicroSoft Driver Installer Tool Running" /wait /separate /realtime /min CMD /C DPInst.exe /c /s
IF "%OSbuild%"=="NT6" GOTO LOG-file

:Finisher
ECHO. & ECHO Running the DriverPacks.net Finisher now! & ECHO.
%SystemDrive% & cd\ & Start /wait /separate /high "" DPsFnshr.exe

:LOG-file
 :: Log and Attended output section
IF /I [%1] NEQ [Q] (

 IF [LOG] NEQ [nul] (
  ECHO. & ECHO Method %M% was found at: >>%LOG%
  ECHO %DPLoc% >>%LOG%
  ECHO List INF's that were matched with this system  >>%LOG%
  FOR /F "usebackq tokens=2,3*" %%G IN ('type %windir%\dpinst.log') DO (
   IF [%%G]==[Successfull] IF [%%H]==[installation] ECHO %%G %%H %%I >>%LOG%)
 )

:Final-Message
cls
ECHO      *********************************************************************
ECHO.
 ECHO.  & ECHO The DriverPacks Stand Alone Drivers installation is complete!
 ECHO.  & ECHO The log file of this utility's progress is found in %windir%\dpinst.log
 ::ECHO  & Start /min sndrec32 /play /close %windir%\media\ding.wav
   IF /I "%OSbuild%"=="NT5" GOTO Timer
   IF /I "%KTD%"=="Y" GOTO Timer
 ECHO Now cleaning up...
 cd %SYSTEMDRIVE%
 cd \
 IF EXIST "%SYSTEMDRIVE%\D\x86\*" DEL /F /S /Q "%SYSTEMDRIVE%\D\x86\*" >nul
 IF EXIST "%SYSTEMDRIVE%\D\x64\*" DEL /F /S /Q "%SYSTEMDRIVE%\D\x64\*" >nul
 IF EXIST "%SYSTEMDRIVE%\D\*" DEL /F /S /Q "%SYSTEMDRIVE%\D\*" >nul
 IF EXIST "%SYSTEMDRIVE%\DPInst.*" DEL /F /S /Q "%SYSTEMDRIVE%\DPInst.*" >nul
 IF EXIST "%SYSTEMDRIVE%\D" RD /S /Q "%SYSTEMDRIVE%\D\" >nul
:Timer
 ECHO.  & ECHO This window will close itself in 30 seconds... & ECHO. 
 For /l %%A in (1,1,30) do (<nul (SET/p z=#) & >nul ping 127.0.0.1 -n 2 )  
ECHO      *********************************************************************

:Done
popd
endlocal
cscript //B "%windir%\system32\slmgr.vbs" /ato
%windir%\Resources\Themes\aero.theme
shutdown -r -c "Drivers installed. Restarting."
START C:\Drivers\RemoveD.cmd
EXIT
del %0

:Error1
cls
ECHO      ********************************************************************
ECHO.
ECHO                             %msg2%      
ECHO.
ECHO                  Invalid Operating System Detected:
ECHO.
ECHO                       %prodname%
ECHO                    Which uses %OSbuild% DriverPacks
ECHO                    Not currently supported
ECHO.
ECHO                     Please exit the program now!
ECHO.
ECHO      ********************************************************************
pause
exit

:Error2
cls
ECHO      ********************************************************************
ECHO.
ECHO.
ECHO                             %msg2%      
ECHO.
ECHO.
ECHO                        un7zip.exe is missing.
ECHO.
ECHO.
ECHO                     Please exit the program now!
ECHO.
ECHO.
ECHO      ********************************************************************
pause
exit

:Error3
cls
ECHO      ********************************************************************
ECHO.
ECHO                             %msg2%      
ECHO.
ECHO                  Invalid Operating System Detected:
ECHO.
ECHO                        %prodname% %ARCH%-bit OS
ECHO                    Installed on %PROCESSOR_ARCHITECTURE% processor
ECHO                    Not currently supported
ECHO.
ECHO                     Please exit the program now!
ECHO.
ECHO      ********************************************************************
pause
exit

:usage
echo %0 is an batch program to automate the 
echo installation of drivers on any Windows system.
echo Usage is %0 {/?!/h!/H} (only one switch used at a time)
echo /? or /h or /H will bring up this guide.
echo /S will enable "Silent" mode which will not prompt for options but will
echo execute the batch with whatever options are set as default.
pause
exit

:Elevate
::Credit to JohnGray http://www.sevenforums.com/general-discussion/118408-programmatic-way-bat-file-determining-IF-elevated-command-prompt.html
::  try to write a zero-byte file to a system directory
::    IF successful, we are in Elevated mode and delete the file
::    IF unsuccessful, avoid the "Access is denied" message
SETlocal
:: arbitrary choice of system directory and filename
SET tst="%windir%\$del_me$"
:: the first brackets are required to avoid getting the message,
::   even though 2 is redirected to nul.  no, I don't know why.
(type nul>%tst%) 2>nul && (del %tst% & SET elev=t) || (SET elev=)
IF defined elev (GOTO PROCESSOR) else ("%cur%\bin\elevate.cmd" "%pd%\DP_Install_Tool.cmd")
endlocal
