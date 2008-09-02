@echo off


if "%~1" == "/?" (
	echo Associates a path with a drive letter.
	echo Manages persistent substituted ^(virtual^) drives.
	echo.
	echo PSUBST [drive1: [drive2:]path] [/P]
	echo PSUBST drive1: /D [/P]
	echo.
	echo   drive1:        Specifies a virtual drive to which you want to assign a path.
	echo   [drive2:]path  Specifies a physical drive and path you want to assign to
	echo                  a virtual drive.
	echo   /D             Deletes a substituted ^(virtual^) drive.
	echo   /P             Manages a persistent drives ^(create, delete, display^)
	echo.
	echo Type SUBST with no parameters to display a list of current virtual drives.
	goto :EOF
)


if "%~1" == "" (
	rem
	rem SUBST
	rem

	subst

	goto :EOF
)


if /i "%~1" == "/p" (
	rem
	rem SUBST /P
	rem

	subst

	setlocal enabledelayedexpansion
	setlocal enableextensions

	call :init

	call :print_persist

	call :cleanup

	endlocal
	goto :EOF
)


setlocal enabledelayedexpansion
setlocal enableextensions

call :init

call :init_disk "%~1"
call :init_path "%~2"

subst !psubst_disk! !psubst_path!

if /i "%~3" == "/p" (
	if errorlevel 1 goto stop_reg
	if /i "%~2" == "/d" (
		call :reg delete !psubst_disk! >nul
	) else (
		call :reg add !psubst_disk! !psubst_path! >nul
	)
)

:stop_reg
call :cleanup

endlocal
goto :EOF


:init
set psubst_disk=
set psubst_path=
set psubst_line=
set psubst_file="%TEMP%\$psubst_persist$.reg"
goto :EOF


:init_disk
if "%~1" == "" goto :EOF
set psubst_disk=%~d1
if "!psubst_disk:~-1!" == "\" set psubst_disk=!psubst_disk:~0,-1!
goto :EOF


:init_path
if "%~1" == "" goto :EOF
if /i "%~1" == "/d" (
	set psubst_path=%~1
	goto :EOF
)

if /i "%~1" == "/p" (
	set psubst_path=
	call :reg query > !psubst_file!
	for /f "tokens=1,2,*" %%a in ( 'findstr ?? !psubst_file!' ) do (
		if "!psubst_disk!" == "%%~a" (
			set psubst_path="%%~c"
			set psubst_path=!psubst_path:\??\=!
			goto :EOF
		)
	)
	goto :EOF
)

set psubst_path=%~1
set psubst_path=!psubst_path:/=\!
if "!psubst_path:~-1!" == ":" set psubst_path=!psubst_path!\
if "!psubst_path:~-1!" == "\" (
	if not "!psubst_path:~-2,1!" == ":" set psubst_path=!psubst_path:~0,-1!
)

set psubst_path="!psubst_path!"
goto :EOF


:reg
set psubst_line=
if not "%~3" == "" (
	set psubst_line=\??\%~3
	if not "!psubst_line:~-1!" == "\" set psubst_line="!psubst_line!"
	set psubst_line=/t REG_SZ /d !psubst_line!
)
if not "%~2" == "" set psubst_line=/v %~2 !psubst_line!
if /i not "%~1" == "query" set psubst_line=!psubst_line! /f

reg %~1 "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" !psubst_line!
goto :EOF


:print_persist
call :reg query > !psubst_file!
for /f "tokens=1,2,*" %%a in ( 'findstr ?? !psubst_file!' ) do (
	set psubst_disk=%%~a
	set psubst_path=%%~c
	set psubst_path=!psubst_path:\??\=!

	if not defined psubst_line (
		set psubst_line=1
		echo.
	)
	echo !psubst_disk!\: =^> !psubst_path!
)
goto :EOF


:cleanup
if exist !psubst_file! del !psubst_file!

set psubst_disk=
set psubst_path=
set psubst_file=
set psubst_line=

goto :EOF

