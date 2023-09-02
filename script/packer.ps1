#Param([string] $Args)
param(
  [string] $Name,
  [string] $In,
  [string] $Out
)

function downloadHttp($url, $targetFile){
  Write-Host "downloadHttp : $url $targetFile"
  Import-Module BitsTransfer

  $start_time = Get-Date
  Start-BitsTransfer -Source $url -Destination $targetFile
  Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}

function Install-Dependencies {
  Param([Parameter(Mandatory=$true)][string] $Path)

  $urlNSIS = "http://azertyvortex.free.fr/download/retro-game-winpacker/nsis-3.08.zip"
  $urlMGBA = "http://azertyvortex.free.fr/download/mGBA-0.10.2-win64.zip"

  if (-Not(Test-Path -Path $path)) {
    New-Item -Path $path -ItemType Directory -Force
  }

  if (-Not(Test-Path -Path "$path\download")) {
    New-Item -Path "$path\download" -ItemType Directory -Force
  }

  if (-Not(Test-Path -Path "$path\mgba")) {
    downloadHttp $urlMGBA "$path\download"
    New-Item -Path "$path\mgba" -ItemType Directory -Force
    Expand-Archive "$path\download\mGBA-0.10.2-win64.zip" "$path\mgba"
  }

  if (-Not(Test-Path -Path "$path\nsis-3.08")) {
    downloadHttp $urlNSIS "$path\download\"
    Expand-Archive "$path\download\nsis-3.08.zip" $path
  }
}

function Get-ArgValue {
  param (
    [Parameter(Mandatory=$true)][string] $ArgumentName,
    [bool] $Mandatory
  )
  $argsArray = $Args -split "\s+"
  $index = $argsArray.IndexOf($ArgumentName)

  if ($index -ge 0 -and $index -lt ($argsArray.Length - 1)) {
    return $argsArray[$index + 1]
  } else {
    if ($Mandatory) { throw "$ArgumentName is undefined"}
    return $null
  }
}

function Embed-Config {
  Param(
    [Parameter(Mandatory=$true)][string] $EmulatorExe,
    [Parameter(Mandatory=$true)][string] $ConfigFile,
    [Parameter(Mandatory=$true)][string] $DestinationPath
  )
  Write-Host "----------------------------------------------------------------------" -ForegroundColor blue
  Write-Host "Starting emulator... Please configure your settings and then close it." -ForegroundColor blue
  Write-Host "Your configured settings will be embedded in the standalone file." -ForegroundColor blue
  Write-Host "----------------------------------------------------------------------" -ForegroundColor blue
  Write-Host "emulator : $EmulatorExe"
  Start-Process -NoNewWindow -FilePath $EmulatorExe -Wait -ErrorAction Stop
  Copy-Item -Force -Path $ConfigFile -Destination $DestinationPath -ErrorAction Stop
}

function Write-NSI {
  Param( #TODO param Name
    [Parameter(Mandatory=$true)][string] $NSIFile,
    [Parameter(Mandatory=$true)][string] $InputFile,
    [Parameter(Mandatory=$true)][string] $OutputFile,
    [Parameter(Mandatory=$true)][string] $template,
    [string] $ConfigFile
  )

  $romFileName = Split-Path -Path $InputFile -Leaf
  Write-Host "create nsis script"
  $content = [System.IO.File]::ReadAllText($template).Replace("/*title*/", $Name).Replace("/*rom*/", "$romFileName").Replace("/*output*/", $OutputFile)
  if ($ico) { $content = $content.Replace("..\..\ico\default-gba.ico", $ico) }
  if ($ConfigFile) { $content = $content.Replace("/*configFile*/", 'File "config.ini"') }
  if ($ConfigFile) { $content = $content.Replace("/*portableFile*/", 'File "portable.ini"') }
  [System.IO.File]::WriteAllText($NSIFile, $content)
}

function Write-Exe {
  param(
    [Parameter(Mandatory=$true)][string] $Makensis,
    [Parameter(Mandatory=$true)][string] $NSIFile
  )
  Start-Process -FilePath $Makensis -NoNewWindow -ArgumentList "$NSIFile" -Wait -ErrorAction Stop
}

function Main {
  param(
    [Parameter(Mandatory=$true)][string] $Name,
    [Parameter(Mandatory=$true)][string] $In,
    [Parameter(Mandatory=$true)][string] $Out
  )

  $cwd = Resolve-Path -Path "."
  $template = Join-Path $cwd "script\template.nsi"
  $makensis = Join-Path $cwd "build\nsis-3.08\makensis.exe"

  # $name = Get-ArgValue -ArgumentName "-Name" -Mandatory $true
  # $inputFile = Get-ArgValue -ArgumentName "-Input" -Mandatory $true
  # $outputFile = Get-ArgValue -ArgumentName "-Output" -Mandatory $true

  $name = $Name
  $inputFile = $In
  $outputFile = $Out

  $embedConfig = Get-ArgValue -ArgumentName "-EmbedConfig"

  $nsiFile = Join-Path $cwd "build\$name\$name.nsi"

  Install-Dependencies -Path $(Join-Path $cwd "build")

  if (-Not(Test-Path -Path $(Join-Path $cwd "build\$name"))) { New-Item -Path $(Join-Path $cwd "build\$name") -ItemType Directory -Force }
  if (-Not(Test-Path -Path $inputFile)) {
    Write-Error "$inputFile not found"
    Exit 2
  }

  Copy-Item -Force -Path $inputFile -Destination "$cwd\build\$name" -ErrorAction Stop

  if ($embedConfig -eq "on") { Embed-Config -EmulatorExe "$cwd\build\mgba\mGBA.exe" -ConfigFile "$cwd\build\mgba\config.ini" -DestinationPath "$cwd\build\$name"  }
  if ($embedConfig -eq "on") { New-Item -Path "$cwd\build\$name\portable.ini" -Force -ErrorAction Stop }

  if ($embedConfig -eq "on") {
    Write-NSI -NSIFile $nsiFile -template $template -Input $inputFile -Output $outputFile -ConfigFile "$cwd\build\mgba\config.ini"
  } else {
    Write-NSI -NSIFile $nsiFile -template $template -Input $inputFile -Output $outputFile
  }

  Write-Exe -Makensis $makensis -NSIFile $nsiFile
}

Write-Host $Name
Write-Host $In
Write-Host $Out
Main -Name $Name -In $In -Out $Out
