$dir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
Install-BinFile -Name "psubst" -Path "$dir/psubst.bat"
