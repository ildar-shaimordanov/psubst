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

Write-Output "Revision: $revision" -Verbose

$builddir = "build"

$git_file = "psubst.bat"
$src_file = "$builddir\$git_file"
$zip_file = "$builddir\$project-$revision.zip"

mkdir $builddir -Verbose

( Get-Content $git_file ) -replace "%PSUBST\.REVISION%", $revision | Set-Content $src_file -Verbose

if ( $args[0] -ieq "ZIP" ) {
	# The code below is based on the answer given to the following question
	# How to create a zip archive with PowerShell?
	# A: https://stackoverflow.com/a/39584254/3627676
	Add-Type -AssemblyName System.IO
	Add-Type -AssemblyName System.IO.Compression
	Add-Type -AssemblyName System.IO.Compression.FileSystem

	$stream = New-Object System.IO.FileStream($zip_file, [System.IO.FileMode]::Create)
	$archive = New-Object System.IO.Compression.ZipArchive($stream, [System.IO.Compression.ZipArchiveMode]::Create)
	[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $src_file, $git_file)
}
