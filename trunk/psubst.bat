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


if "%*" == "" (
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

if /i not "%~2" == "/d" set subst_path="!subst_path!"

subst !subst_disk! !subst_path!

if /i "%~3" == "/p" call :save_persist

call :cleanup

endlocal
goto :EOF


:init
set subst_file="%TEMP%\$subst_persist$.reg"
goto :EOF


:init_disk
if "%~1" == "" goto :EOF
set subst_disk=%~d1
if "!subst_disk:~-1!" == "\" set subst_disk=!subst_disk:~0,-1!
goto :EOF


:init_path
if "%~1" == "" goto :EOF
if /i "%~1" == "/d" (
	set subst_path=%~1
	goto :EOF
)
set subst_path=%~df1
set subst_path=!subst_path:/=\!
if "!subst_path:~-1!" == ":" set subst_path=!subst_path!\
if "!subst_path:~-1!" == "\" (
	if not "!subst_path:~-2,1!" == ":" set subst_path=!subst_path:~0,-1!
)
goto :EOF


:init_persist
echo REGEDIT4 > !subst_file!
echo [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices] >> !subst_file!

if /i "!subst_path!" == "/d" (
	rem
	rem SUBST drive1: /D /P
	rem
	echo "!subst_disk!"=- >> !subst_file!
) else (
	rem
	rem SUBST drive1: [drive2:]path /P
	rem
	echo "!subst_disk!"="\\??\\!subst_path:\=\\!" >> !subst_file!
)
goto :EOF


:load_persist
set subst_path=
start /wait regedit /ea !subst_file! "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices"
for /f "delims== tokens=1,*" %%a in ( 'findstr "??" !subst_file!' ) do (
	set subst_line=%%~a

	if "!subst_disk!" == "!subst_line!" (
		set subst_path=%%~b
		set subst_path=!subst_path:\\??\\=!
		set subst_path=!subst_path:\\=\!
		goto :EOF
	)
)
goto :EOF


:save_persist
if errorlevel 1 (
	if /i not "!subst_path!" == "/d" goto :EOF
	echo Persistent drive was unregistered.
)
start /wait regedit -s !subst_file!
goto :EOF


:print_persist
start /wait regedit /ea !subst_file! "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices"
for /f "delims== tokens=1,*" %%a in ( 'findstr "??" !subst_file!' ) do (
	set subst_disk=%%~a
	set subst_path=%%~b
	set subst_path=!subst_path:\\??\\=!
	set subst_path=!subst_path:\\=\!

	if not defined subst_line (
		set subst_line=1
		echo.
	)
	echo !subst_disk!\: =^> !subst_path!
)
goto :EOF


:cleanup
if exist !subst_file! del !subst_file!

set subst_disk=
set subst_path=
set subst_file=
set subst_line=

goto :EOF

