@echo off
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::PSubst
:: By:  ildar-shaimordanov  		v2 - 02/09/2008
::      ildar-shaimordanov & Cyberponk 	v3 - 02/06/2015
:: 
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
set "_ThisFile=%~dpf0" &set "_Drive=" &set "_Path=" &set "_Persistent=" &set "_Delete=" &set "_Force="
set _RegQuery="HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices"

if "%~1" == "/?" goto :ShowInfo
if "%~1" == "" goto :PrintDrives
goto :main

:ShowInfo
  echo/PSubst v3.0 - 02/06/2015
  echo/ Associates a path with a drive letter.
  echo/ Manages persistent substituted ^(virtual^) drives.
:ShowUsage
  echo/
  echo/ PSUBST  [drive1: [drive2:]path] [/P] [/F]
  echo/ PSUBST  drive1: /D
  echo/
  echo/   drive1:        Specifies the new virtual drive.
  echo/   [drive2:]path  Specifies the source path for the virtual drive.
  echo/
  echo/   /D             Deletes a substituted ^(virtual^) drive.
  echo/   /P             Makes the substituted drive persistent after boot
  echo/   /F             Forces the overwriting of a persistent drive letter
  echo/
  echo/ Returns:
  echo/   -1 or 1       An error occured
  echo/    0            Command successfull
  echo/ Type SUBST with no parameters to display a list of current  drives.
endlocal & goto:eof

:main
  :ProcessAllArgumentsLoop
    Shift 
    set "_Arg=%~0 "
  if "!_Arg!" NEQ " " (call :ProcessArgument &goto:ProcessAllArgumentsLoop)

  :: Check if all parameters are correct
  if "%_Drive%"=="" (set _Error=No drive letter chosen ^&call:ShowUsage)
  if "%_Error%" NEQ "" goto:ExitWithError

  Call :CheckPersistent
  if "%_Delete%"=="TRUE" goto:RemoveDrive

  :CreateDrive
    echo/Creating drive !_Drive!...
    if not exist "!_Path!" (set _Error=Source path not chosen or invalid ^&call:ShowUsage &goto:ExitWithError)
    :: Check if persistent drive already exists, and if _Force not set, exit with error
    if "%_IsPersistent%"=="TRUE" (if "%_Force%" NEQ "TRUE" (set _Error=Persistent Drive Letter already in use - use /F option to force overwrite &goto:ExitWithError))
    subst !_Drive! "!_Path!"
    :: If Persistent flag is set, add registry entry
    if "%_Persistent%" NEQ "TRUE" goto:end
      call :RequestAdminElevation "!_ThisFile!" %* || goto:eof )
      call :AddPersistent
      call :CheckPersistent
      if "%_IsPersistent%" NEQ "TRUE" (set _Error=Could not create registry entry &goto:ExitWithError) else (fc;: 2>nul)
  goto:end

:RemoveDrive
    echo/Removing drive !_Drive!...
    if "!_Path!" NEQ "" (set _Error=Do not type path and /D arguments at the same time ^&call:ShowUsage &goto:ExitWithError)

    :: Delete Subst drive
    subst %_Drive% /D
    :: If drive is persistent, get admin rights and remove registry entry
    if "%_IsPersistent%"=="TRUE" ((call :RequestAdminElevation "!_ThisFile!" %* || goto:eof ) & call :RemovePersistent )
    :: Check if persistent drive removal was successfull
    Call :CheckPersistent
    if "%_IsPersistent%"=="TRUE" (set _Error=Could not remove registry entry &goto:ExitWithError) else (ver >nul)

:end
endlocal & goto:eof

:ExitWithError
    echo/ERROR: %_Error%
    echo/ 
    fc;: 2>nul
    pause
goto:end

:ProcessArgument
  if /i "!_Arg!"=="/P " (set "_Persistent=TRUE" & goto:eof)    &:: Check for /P flag
  if /i "!_Arg!"=="/D " (set "_Delete=TRUE"     & goto:eof)    &:: Check for /D flag
  if /i "!_Arg!"=="/F " (set "_Force=TRUE"      & goto:eof)    &:: Check for /F flag
    
  if "!_Arg:~1,10!"==": "  (if "!_Drive!"=="" (set "_Drive=!_Arg:~0,2!"  &goto:eof) else (set _Error=Type only 1 drive letter ^&call:ShowUsage))
  if "!_Arg:~1,2!" ==":\"  (if "!_Path!" =="" (set  "_Path=!_Arg:~0,-1!" &goto:eof) else (set _Error=Type only 1 path ^&call:ShowUsage))
goto:eof &:: End ProcessArgument

:CheckPersistent 
  reg query !_RegQuery! /v !_Drive! >nul 2>&1 && (set "_IsPersistent=TRUE" ) || ( set "_IsPersistent=")
goto:eof &:: End CheckPersistent 

:AddPersistent
  reg add !_RegQuery! /v !_Drive! /t REG_SZ /d "\??\!_Path!" /F
goto:eof &:: End AddPersistent

:RemovePersistent
  reg delete %_RegQuery% /v %_Drive% /F
goto:eof &:: End RemovePersistent

:PrintDrives
  echo/SUBSTed drives:
  subst
  echo/
  echo/Persistent mappings:
  for /f "tokens=1,2,*" %%a in ( 'reg query !_RegQuery! ^| findstr ??' ) do (
    set "_RegPath=%%~c"
    set "_RegPath=!_RegPath:\??\=!"
    echo/%%~a\: =^> !_RegPath!
  )
goto:eof &:: End PrintDrives


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RequestAdminElevation FilePath %* || goto:eof
:: 
:: By:   Cyberponk, V1.1 - 01/06/2015
:: 
:: Func: opens an admin elevation prompt. If elevated, runs everything after the function call, with elevated rights.
:: Returns: -1 if elevation was requested
::           0 if elevation was successful
::           1 if an error occured
:: 
:: USAGE:
:: If function is copied to a batch file:
::     call :RequestAdminElevation "%~dpf0" %* || goto:eof
:: If called as an external library (from a separatef file):
::     set "_DeleteOnExit=0" & call :RequestAdminElevation "%~dpf0" %* || goto:eof
:: If called from inside another CALL, you must set "_ThisFile=%~dpf0" at the beginning of the file
::     call :RequestAdminElevation "%_ThisFile%" %* || goto:eof
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
setlocal ENABLEDELAYEDEXPANSION & set "_FilePath=%~1"
  if NOT EXIST "!_FilePath!" (echo/Read RequestAdminElevation usage information)
  :: UAC.ShellExecute only works with 8.3 filename, so use %~s1
  set "_FN=_%~ns1" & echo/%TEMP%| findstr /C:"(" >nul && (echo/ERROR: %%TEMP%% path can not contain parenthesis &endlocal &fc;: 2>nul & goto:eof)
  :: Remove parenthesis from the temp filename
  set _FN=%_FN:(=%
  set _vbspath="%temp:~%\%_FN:)=%.vbs" & set "_batpath=%temp:~%\%_FN:)=%.bat"

  :: Test if elevated
  >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
  :: If error flag set, we do not have elevation
  if "%errorlevel%" NEQ "0" goto :_getElevation

  :: Elevation successful
  (if exist %_vbspath% ( del %_vbspath% )) & (if exist %_batpath% ( del %_batpath% )) & CD /D "%~dp1"
  :: Set ERRORLEVEL 0 and exit
  endlocal & ver >nul & goto:eof

  :_getElevation
  echo/Requesting elevation...
  :: Try to create %_vbspath% file. If failed, exit with ERRORLEVEL 1
  echo/Set UAC = CreateObject^("Shell.Application"^) > %_vbspath% || (echo/&echo/Unable to create %_vbspath% & endlocal &md; 2>nul &goto:eof) 
  echo/UAC.ShellExecute "%_batpath%", "", "", "runas", 1 >> %_vbspath% & echo/wscript.Quit(1)>> %_vbspath%
  :: Try to create %_batpath% file. If failed, exit with ERRORLEVEL 1
  echo/@%* > "%_batpath%" || (echo/&echo/Unable to create %_batpath% & endlocal &md; 2>nul &goto:eof)
  :: Run %_vbspath%, that calls %_batpath%, that calls the original file
  %_vbspath% && (echo/&echo/Failed to run VBscript %_vbspath% &endlocal &md; 2>nul & goto:eof)
  
  :: Vbscript has been run, exit with ERRORLEVEL -1
  echo/&echo/Elevation was requested on a new CMD window &endlocal &fc;: 2>nul & goto:eof
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


