License:
Except otherwise noted, the open-source code of the DP_Install_Tool.cmd file is © 2011-2012 by Erik Hansen for DriverPacks.net, under a Creative Commons Attribution-ShareAlike license: http://creativecommons.org/licenses/by-sa/3.0/.
7-Zip is open source software by Igor Pavlov. Most of the source code is under the GNU LGPL license. The unRAR code is under a mixed license: GNU LGPL + unRAR restrictions. Check license information here: http://www.7-zip.org/license.txt or http://www.gnu.org/licenses/lgpl.html
DPInst.exe is proprietary code owned completely by Microsoft and distributed under their own license. (see .\bin\*\dpinst-license.rtf)

*** WARNING ***
Ensure you run the DP_Install_Tool.cmd file with an adminstrator account or with adminstrator rights.  

** Caution **
The below caution is for Vista/Win7 users only.
If you run the DP_Install_Tool.cmd file from an account without adminstrator rights, the tool will ask for an adminstrator password to continue.

* Note *
Difference between method 1 & method 2 DriverPacks preparation:
Method 1 will unpack all the selected dps to a temp folder, then .CAB compress the files to save space, then copy all the individual files/folders to the destination.
- Benefit #1: When installing new hardware, Windows will scan removable drives for compatible drivers and auto-install if found.
- Benefit #2: Installing drivers is very quick because the drivers are already pre-staged and ready for use.
- Problem #1: This method takes a LOONNNGGGG time to create and uses roughly 3 times the disc space to store.
- Problem #2: Keeping your SAD disc up-to-date requires completely rebuilding the packs each time an update is available.

Method 2 keeps all the DriverPacks in their .7z compressed state and then unpacks them to the destination drive once install is selected.
- Benefit #1: This method takes less than a minute to create the SAD disc and saves lots of space on the disc itself because the files are kept compressed.
- Benefit #2: Keeping your SAD disc up-to-date is as simple as replacing the .7z packs with updated ones...easy.
- Problem #1: When installing new hardware using the "new hardware wizard", Windows will NOT find any drivers when scanning removable media because the files are still compressed.
- Problem #2: Installing drivers takes longer because the drivers must be unpacked to the system drive before they can be used.

You must prioritize your needs and select the appropriate method to use.  You must select one or the other, not both.



What goes where?

NT5\x86\
-Method-1: Use DriverPacks BASE to create a Method-1 SAD disc selecting the packs you want to include.  By default, the folder "DriverPacks.net" will be created in C:\.
Copy the contents of that DriverPacks.net folder to this folder so that the folder heirarchy looks like this: \NT5\x86\D\.
-Method-2 (preferred): 32-bit Win XP/2000/2003 DriverPacks go here in their compressed state.  An empty "Example" DriverPack is included for reference.  Method 2 will fail if the \NT5\x86\D\ folder exists here, only .7z packs must be present.


NT6\x64\
-Method-1: Extract the contents of all DriverPacks to the NT6\x64\D\ folder so that the folder heirarchy looks like this: \NT6\x64\D\*.  Method 1 will fail if the \NT6\x64\ folder contains any .7z DriverPacks.
-Method-2 (preferred): 64-bit Vista/Win7 DriverPacks go here in their compressed state.  An empty "Example" DriverPack is included for reference.  Method 2 will fail if the \NT6\x64\D\ folder exists here, only .7z packs must be present.

NT6\x86\
-Method-1: Extract the contents of all DriverPacks to the NT6\x86\D\ folder so that the folder heirarchy looks like this: \NT6\x86\D\*.  Method 1 will fail if the \NT6\x86\ folder contains any .7z DriverPacks.
-Method-2 (preferred): 32-bit Vista/Win7 DriverPacks go here in their compressed state.  An empty "Example" DriverPack is included for reference.  Method 2 will fail if the \NT6\x86\D\ folder exists here, only .7z packs must be present.

