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

if /i "%~3" == "/p" call :init_persist

if /i "%~2" == "/p" call :load_persist

if /i not "%~2" == "/d" set psubst_path="!psubst_path!"

subst !psubst_disk! !psubst_path!

if /i "%~3" == "/p" call :save_persist

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
set psubst_path=%~df1
set psubst_path=!psubst_path:/=\!
if "!psubst_path:~-1!" == ":" set psubst_path=!psubst_path!\
if "!psubst_path:~-1!" == "\" (
	if not "!psubst_path:~-2,1!" == ":" set psubst_path=!psubst_path:~0,-1!
)
goto :EOF


:init_persist
echo REGEDIT4 > !psubst_file!
echo [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices] >> !psubst_file!

if /i "!psubst_path!" == "/d" (
	rem
	rem SUBST drive1: /D /P
	rem
	echo "!psubst_disk!"=- >> !psubst_file!
) else (
	rem
	rem SUBST drive1: [drive2:]path /P
	rem
	echo "!psubst_disk!"="\\??\\!psubst_path:\=\\!" >> !psubst_file!
)
goto :EOF


:load_persist
set psubst_path=
start /wait regedit /ea !psubst_file! "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices"
for /f "delims== tokens=1,*" %%a in ( 'findstr "??" !psubst_file!' ) do (
	set psubst_line=%%~a

	if "!psubst_disk!" == "!psubst_line!" (
		set psubst_path=%%~b
		set psubst_path=!psubst_path:\\??\\=!
		set psubst_path=!psubst_path:\\=\!
		goto :EOF
	)
)
goto :EOF


:save_persist
if errorlevel 1 (
	if /i not "!psubst_path!" == "/d" goto :EOF
	echo Persistent drive was unregistered.
)
start /wait regedit -s !psubst_file!
goto :EOF


:print_persist
start /wait regedit /ea !psubst_file! "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices"
for /f "delims== tokens=1,*" %%a in ( 'findstr "??" !psubst_file!' ) do (
	set psubst_disk=%%~a
	set psubst_path=%%~b
	set psubst_path=!psubst_path:\\??\\=!
	set psubst_path=!psubst_path:\\=\!

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

