# Uninstall previous version, if any
Uninstall-BinFile -Name "psubst"

$dir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
Copy-Item -Path "$dir/psubst.bat" -Destination "$env:ChocolateyInstal/bin"
