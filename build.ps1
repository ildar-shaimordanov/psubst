
function Init-Build {
	$script:project = "psubst"
	$script:revision = & git describe --tags --long
	$script:release = & git describe --tags --abbrev=0
	$script:version = $release -Replace "^v", ""

	Write-Output "Revision : $revision" -Verbose
	Write-Output "Release  : $release"  -Verbose
	Write-Output "Version  : $version"  -Verbose

	$script:builddir = "build"

	$script:templatedir = "nupkg-template"

	$script:git_file = "psubst.bat"
	$script:src_file = "$builddir\$git_file"
	$script:zip_file = "$builddir\$project-$revision.zip"

	New-Item -ItemType Directory -Path $builddir -Verbose

	Remove-Item -Path $builddir\* -Recurse -Verbose
}

switch ( $args[0] ) {
"file" {
	Init-Build

	( Get-Content $git_file ) -replace "%PSUBST\.REVISION%", $revision | Set-Content $src_file -Verbose

	break
}
"zip" {
	Init-Build

	( Get-Content $git_file ) -replace "%PSUBST\.REVISION%", $revision | Set-Content $src_file -Verbose

	# The code below is based on the answer given to the following question
	# How to create a zip archive with PowerShell?
	# A: https://stackoverflow.com/a/39584254/3627676
	Add-Type -AssemblyName System.IO
	Add-Type -AssemblyName System.IO.Compression
	Add-Type -AssemblyName System.IO.Compression.FileSystem

	$stream = New-Object System.IO.FileStream($zip_file, [System.IO.FileMode]::Create)
	$archive = New-Object System.IO.Compression.ZipArchive($stream, [System.IO.Compression.ZipArchiveMode]::Create)
	[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $src_file, $git_file)

	break
}
"pkg" {
	Init-Build

	Get-ChildItem $templatedir | Copy-Item -Destination $builddir -Recurse
	Copy-Item -Path $git_file -Destination "$builddir/tools"

	Get-ChildItem $builddir -File -Recurse | ForEach {
		$enc = if ( $_ -Match "\.(nuspec|bat)$" ) { "ASCII" } else { "UTF8" }
		$f = $_.FullName
		( Get-Content $f ) -Replace "%PSUBST\.VERSION%", $version -Replace "%PSUBST\.REVISION%", $revision | Set-Content $f -Verbose -Encoding $enc
	}

	pushd "$builddir"
	choco pack
	popd

	break
}
default {
	$me = $MyInvocation.MyCommand.Name
	"Usage: $me file|zip|pkg"
}
}
