::PSUBST %PSUBST.REVISION%
::
::Associates a path with a drive letter.
::Manages persistently substituted (virtual) drives.
::
::PSUBST [drive1: [drive2:]path] [/P | /PF]
::PSUBST drive1: /D [/P | /PF]
::PSUBST drive1: /P
::
::  drive1:        Specifies a virtual drive to which you want to assign a path.
::  [drive2:]path  Specifies a physical drive and path you want to assign to
::                 a virtual drive.
::  /D             Deletes a substituted (virtual) drive.
::  /P             Add, delete or display persistent drives.
::  /PF            Add or delete persistent drives with elevated privileges.
::
::Type PSUBST with no parameters to display a list of current virtual drives.
::Type PSUBST /P to display a list of persistent virtual drives.
::Type PSUBST drive1: /P to restore a virtual drive from persistency.
@echo off


if "%~1" == "/?" goto :print_usage


if "%~1" == "" (
	rem
	rem SUBST
	rem

	subst

	goto :EOF
)


if /i "%~1" == "/P" (
	rem
	rem SUBST /P
	rem

	setlocal

	call :psubst_init

	call :psubst_print

	endlocal
	goto :EOF
)


setlocal

call :psubst_init

call :psubst_check_disk "%~1" || exit /b %ERRORLEVEL%

if /i "%~2" == "/P" (
	rem
	rem PSUBST X: /P
	rem

	call :psubst_lookup "%psubst_disk%"
	if not defined psubst_persist_path (
		echo:%~n0: Drive not persistent
		exit /b 1
	)

	setlocal enabledelayedexpansion

	subst "!psubst_persist_disk!" "!psubst_persist_path!"

	endlocal
	goto :EOF
)

if /i "%~2" == "/D" (
	rem
	rem PSUBST X: /D ...
	rem

	set "psubst_reg_op=delete"
	set "psubst_path="
) else (
	rem
	rem PSUBST X: "..." ...
	rem

	call :psubst_check_path "%~2" || exit /b %ERRORLEVEL%
)

if /i "%~3" == "/P" (
	rem
	rem PSUBST ... /P
	rem

	call :psubst_persist "%~3"
) else if /i "%~3" == "/PF" (
	rem
	rem PSUBST ... /PF
	rem

	call :psubst_persist "%~3"
) else if defined psubst_path (
	rem
	rem SUBST X: "..."
	rem

	subst "%psubst_disk%" "%psubst_path%"
) else (
	rem
	rem SUBST X: /D
	rem

	subst "%psubst_disk%" /D
)

endlocal
goto :EOF


:psubst_init
set "psubst_disk="
set "psubst_path="
set "psubst_value="
set "psubst_persist_disk="
set "psubst_persist_path="
set "psubst_reg_op="
set "psubst_regkey=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices"
goto :EOF


:psubst_check_disk
if not "%~1" == "" for %%d in ( "%~1" ) do if /i "%%~d" == "%%~dd" (
	set "psubst_disk=%%~d"
	exit /b 0
)

echo:%~n0: Invalid parameter: %~1
exit /b 1


:psubst_check_path
if /i "%~1" == "/D" (
	set "psubst_reg_op=delete"
	set "psubst_path="
	exit /b 0
)

if not "%~1" == "" for %%f in ( "%~1\." ) do if exist %%~sf\nul (
	set "psubst_reg_op=add"
	set "psubst_path=%%~ff"
	exit /b 0
)

echo:%~n0: Path not found: %~1
exit /b 1


:psubst_persist
call :psubst_lookup "%psubst_disk%"

if /i "%psubst_reg_op%" == "add" if defined psubst_persist_disk (
	echo:%~n0: Drive already SUBSTed persistently
	exit /b 1
)

if /i "%psubst_reg_op%" == "delete" if not defined psubst_persist_disk (
	echo:%~n0: Drive not SUBSTed persistently
	exit /b 1
)

set "psubst_value="

if /i "%~1" == "/PF" (
	call :psubst_persist_reg_sudo
) else (
	call :psubst_persist_reg
)

call :psubst_lookup "%psubst_disk%"

if /i "%psubst_reg_op%" == "add" if not defined psubst_persist_disk (
	echo:%~n0: Unable to add persistently SUBSTed drive
	exit /b 1
)

if /i "%psubst_reg_op%" == "delete" if defined psubst_persist_disk (
	echo:%~n0: Unable to delete persistently SUBSTed drive
	exit /b 1
)
goto :EOF

:psubst_persist_reg
if defined psubst_path set "psubst_value=/t REG_SZ /d "\??\%psubst_path%""
reg %psubst_reg_op% "%psubst_regkey%" /v %psubst_disk% %psubst_value% /f >nul
goto :EOF

rem Based on the solution suggested in this thread:
rem https://www.dostips.com/forum/viewtopic.php?f=3&t=9212
:psubst_persist_reg_sudo
if defined psubst_path set "psubst_value=/t REG_SZ /d \"\??\%psubst_path%\""
reg add "HKCU\Software\Classes\.elevate\shell\runas\command" /ve /d "cmd.exe /c start reg %psubst_reg_op% \"%psubst_regkey%\" /v %psubst_disk% %psubst_value% /f >nul" /f >nul

type nul > "%TEMP%\%~n0.elevate"
"%TEMP%\%~n0.elevate"
del /q "%TEMP%\%~n0.elevate"

reg delete "HKCU\Software\Classes\.elevate" /f >nul

goto :EOF


:psubst_print
setlocal
call :psubst_lookup
endlocal
goto :EOF


:psubst_lookup
set "psubst_persist_disk="
set "psubst_persist_path="

for /f "tokens=1,2,*" %%a in ( 'reg query "%psubst_regkey%"' ) do ^
for /f "tokens=1,* delims=\\" %%k in ( "%%~c" ) do ^
if "%%k" == "??" if "%~1" == "" (
	echo:%%~a\: =^> %%~l
) else if /i "%~1" == "%%~a" (
	set "psubst_persist_disk=%%~a"
	set "psubst_persist_path=%%~l"
	goto :EOF
)
goto :EOF


:print_usage
for /f "tokens=* delims=:" %%s in ( 'findstr "^::" "%~f0"' ) do echo:%%s
goto :EOF

