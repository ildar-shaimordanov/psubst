<# :
@echo off
setlocal
set "POWERSHELL_BAT_ARGS=%*"
if defined POWERSHELL_BAT_ARGS set "POWERSHELL_BAT_ARGS=%POWERSHELL_BAT_ARGS:"=\"%"
rem endlocal & powershell -NoLogo -NoProfile -Command "$_ = $input; Invoke-Expression $( '$input = $_; $_ = \"\"; $args = @( &{ $args } %POWERSHELL_BAT_ARGS% );' + [String]::Join( [char]10, $( Get-Content \"%~f0\" ) ) )"
endlocal & powershell -NoLogo -NoProfile -Command "$input | &{ [ScriptBlock]::Create( ( Get-Content \"%~f0\" ) -join [char]10 ).Invoke( @( &{ $args } %POWERSHELL_BAT_ARGS% ) ) }"
goto :EOF
#>

$project = "psubst"
$revision = & git describe --tags --long
$release = & git describe --tags --abbrev=0
$version = $release -Replace "^v", ""

Write-Output "Revision : $revision" -Verbose
Write-Output "Release  : $release"  -Verbose
Write-Output "Version  : $version"  -Verbose

$builddir = "build"

$templatedir = "nupkg-template"

$git_file = "psubst.bat"
$src_file = "$builddir\$git_file"
$zip_file = "$builddir\$project-$revision.zip"

mkdir $builddir -Verbose

Get-ChildItem $templatedir | Copy-Item -Destination $builddir -Recurse
Copy-Item -Path $git_file -Destination "$builddir/tools"

Get-ChildItem $builddir -File -Recurse | ForEach {
	$enc = if ( $_ -Match "\.(nuspec|bat)$" ) { "ASCII" } else { "UTF8" }
	$_ = $_.FullName
	( Get-Content $_ ) -Replace "%PSUBST\.VERSION%", $version -Replace "%PSUBST\.REVISION%", $revision | Set-Content $_ -Verbose -Encoding $enc
}
