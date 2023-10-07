param(
  [Parameter(Mandatory=$true)][string] $Name,
  [Parameter(Mandatory=$true)][string] $In,
  [Parameter(Mandatory=$true)][string] $Out,
  [Parameter(Mandatory=$true)][string] $Arch,
  [switch] $Configure
)

function downloadHttp($url, $targetFile){
  Write-Host "downloadHttp : $url $targetFile"
  Import-Module BitsTransfer

  $start_time = Get-Date
  Start-BitsTransfer -Source $url -Destination $targetFile
  Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}

function Write-Folders {
  Param([Parameter(Mandatory=$true)][string] $Path)
  if (-Not(Test-Path -Path $path)) {
    New-Item -Path $path -ItemType Directory -Force
  }

  if (-Not(Test-Path -Path "$path\download")) {
    New-Item -Path "$path\download" -ItemType Directory -Force
  }
}

function Install-NSIS {
  Param([Parameter(Mandatory=$true)][string] $WorkingPath)
  $urlNSIS = "http://azertyvortex.free.fr/download/retro-game-winpacker/nsis-3.08.zip"

  Write-Folders -Path $WorkingPath

  if (-Not(Test-Path -Path "$WorkingPath\nsis-3.08")) {
    downloadHttp $urlNSIS "$WorkingPath\download\"
    Expand-Archive "$WorkingPath\download\nsis-3.08.zip" $WorkingPath
  }
}

function Install-mGBA {
  Param([Parameter(Mandatory=$true)][string] $WorkingPath)
  $urlMGBA = "http://azertyvortex.free.fr/download/mGBA-0.10.2-win64.zip"

  Write-Folders -Path $WorkingPath

  if (-Not(Test-Path -Path "$WorkingPath\mgba")) {
    downloadHttp $urlMGBA "$WorkingPath\download"
    New-Item -Path "$WorkingPath\mgba" -ItemType Directory -Force
    Expand-Archive "$WorkingPath\download\mGBA-0.10.2-win64.zip" "$WorkingPath\mgba"
    # start the emulator to generate conf
    Start-Process -NoNewWindow -FilePath "$WorkingPath\mgba\mGBA.exe" -ErrorAction Stop
    sleep 2
    # TODO check and loop
    Stop-Process -Name "mGBA" -Force
  }
}

function Install-Nestopia {
  Param([Parameter(Mandatory=$true)][string] $WorkingPath)
  $urlNestopia = "https://sourceforge.net/projects/nestopia/files/Nestopia/v1.40/Nestopia140bin.zip"

  Write-Folders -Path $WorkingPath
  if (-Not(Test-Path -Path "$WorkingPath\nestopia")) {
    downloadHttp $urlNestopia "$WorkingPath\download"
    New-Item -Path "$WorkingPath\nestopia" -ItemType Directory -Force
    Expand-Archive "$WorkingPath\download\Nestopia140bin.zip" "$WorkingPath\nestopia"
    downloadHttp "http://azertyvortex.free.fr/download/nestopia.xml" "$WorkingPath\nestopia"
    $nestopiaConfigFile = "$WorkingPath\nestopia\nestopia.xml"
    $nestopiaContent = [System.IO.File]::ReadAllText($nestopiaConfigFile)
    $nestopiaContent = $nestopiaContent.Replace("            <start-fullscreen>no</start-fullscreen>", "            <start-fullscreen>yes</start-fullscreen>")
    [System.IO.File]::WriteAllText($nestopiaConfigFile, $nestopiaContent)
  }
}

function Install-Snes9x {
  Param([Parameter(Mandatory=$true)][string] $WorkingPath)
  $urlSnes9x = "https://dl.emulator-zone.com/download.php/emulators/snes/snes9x/snes9x-1.62.3-win32-x64.zip"

  Write-Folders -Path $WorkingPath
  if (-Not(Test-Path -Path "$WorkingPath\snes9x")) {
    downloadHttp $urlSnes9x "$WorkingPath\download"
    New-Item -Path "$WorkingPath\snes9x" -ItemType Directory -Force
    Expand-Archive "$WorkingPath\download\snes9x-1.62.3-win32-x64.zip" "$WorkingPath\snes9x"
    # start the emulator to generate conf
    Start-Process -NoNewWindow -FilePath "$WorkingPath\snes9x\snes9x-x64.exe" -ErrorAction Stop
    sleep 2
    # TODO check and loop
    Stop-Process -Name "snes9x-x64" -Force
    sleep 5
    $snesConfigFile = "$WorkingPath\snes9x\snes9x.conf"
    $snesContent = [System.IO.File]::ReadAllText($snesConfigFile)
    $snesContent = $snesContent.Replace("     Fullscreen:Enabled              = FALSE", "     Fullscreen:Enabled              = TRUE")
    [System.IO.File]::WriteAllText($snesConfigFile, $snesContent)
  }
}

function Install-WinUAE {
  Param([Parameter(Mandatory=$true)][string] $WorkingPath)
  $urlWinUAE = "https://download.abime.net/winuae/releases/WinUAE5000_x64.zip"
  $urlKick = "http://azertyvortex.free.fr/download/amiga-kick.zip"
  $urlConf = "http://azertyvortex.free.fr/download/retro-game-winpacker/game.uae"

  Write-Folders -Path $WorkingPath
  if (-Not(Test-Path -Path "$WorkingPath\winuae-5.0.0")) {
    downloadHttp $urlWinUAE "$WorkingPath\download"
    downloadHttp $urlKick "$WorkingPath\download"
    downloadHttp $urlConf "$WorkingPath\download"
    New-Item -Path "$WorkingPath\winuae-5.0.0" -ItemType Directory -Force
    Expand-Archive "$WorkingPath\download\WinUAE5000_x64.zip" "$WorkingPath\winuae-5.0.0" -Force
    Expand-Archive "$WorkingPath\download\amiga-kick.zip" "$WorkingPath\download" -Force
    Copy-Item -Path "$WorkingPath\download\Amiga kick13.rom" -Destination "$WorkingPath\winuae-5.0.0" -Force
    Copy-Item -Path "$WorkingPath\download\game.uae" -Destination "$WorkingPath\winuae-5.0.0" -Force
    $UAEConfigFile = "$WorkingPath\winuae-5.0.0\game.uae"
    $UAEContent = [System.IO.File]::ReadAllText($UAEConfigFile)
    $UAEContent = $UAEContent.Replace("gfx_fullscreen_amiga=false", "gfx_fullscreen_amiga=true")
    $UAEContent = $UAEContent.Replace("gfx_width_fullscreen=800", "gfx_width_fullscreen=1024")
    $UAEContent = $UAEContent.Replace("gfx_height_fullscreen=600", "gfx_height_fullscreen=768")
    [System.IO.File]::WriteAllText($UAEConfigFile, $UAEContent)
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
  if ($Arch -eq "amiga") {
    # Start-Process -NoNewWindow -FilePath $EmulatorExe -ArgumentList "$ConfigFile" -Wait -ErrorAction Stop
    Start-Process -NoNewWindow -FilePath notepad -ArgumentList "$ConfigFile" -Wait -ErrorAction Stop
  } else {
    Start-Process -NoNewWindow -FilePath $EmulatorExe -Wait -ErrorAction Stop
  }
  Copy-Item -Force -Path $ConfigFile -Destination $DestinationPath -ErrorAction Stop
}

function Write-NSI {
  Param( #TODO param Name
    [Parameter(Mandatory=$true)][string] $NSIFile,
    [Parameter(Mandatory=$true)][string] $InputFile,
    [Parameter(Mandatory=$true)][string] $OutputFile,
    [Parameter(Mandatory=$true)][string] $template,
    [Parameter(Mandatory=$true)][string] $Arch
  )

  $romFileName = Split-Path -Path $InputFile -Leaf
  Write-Host "create nsis script"
  Write-Host $template
  Write-Host $NSIFile
  $NSIcontent = [System.IO.File]::ReadAllText($template).Replace("/*title*/", $Name).Replace("/*output*/", $OutputFile)
  $NSIcontent = $NSIcontent.Replace("/*version*/", $version)

  if ($Arch -eq "gba") {
    $NSIcontent = $NSIcontent.Replace("/*exec*/", 'mGBA.exe --fullscreen "/*rom*/"')
    Copy-Item -Force -Path "$PWD\build\mgba\config.ini" -Destination "$PWD\build\$Name" -ErrorAction Stop
  }

  if ($Arch -eq "nes") {
    $nestopiaContent = [System.IO.File]::ReadAllText("$PWD\build\nestopia\nestopia.xml")
    $nestopiaContent = $nestopiaContent.Replace("C:\temp\retro-game-winpacker\build\nestopia", "$env:TEMP\$Name")
    [System.IO.File]::WriteAllText("$PWD\build\$Name\nestopia.xml", $nestopiaContent)

    $NSIcontent = $NSIcontent.Replace("/*exec*/", 'nestopia.exe "/*rom*/"')
  }

  if ($Arch -eq "snes") {
    # $snesContent = [System.IO.File]::ReadAllText("$PWD\build\snes9x\snes9x.conf")
    # $snesContent = $snesContent.Replace("     Fullscreen:Enabled              = FALSE", "     Fullscreen:Enabled              = TRUE")
    # [System.IO.File]::WriteAllText("$PWD\build\$Name\snes9x.conf", $snesContent)
    Copy-Item -Force -Path "$PWD\build\snes9x\snes9x.conf" -Destination "$PWD\build\$Name" -ErrorAction Stop
    $NSIcontent = $NSIcontent.Replace("/*exec*/", 'snes9x-x64.exe "/*rom*/"')
  }

  if ($Arch -eq "amiga") {
    Copy-Item -Force -Path "$PWD\build\winuae-5.0.0\game.uae" -Destination "$PWD\build\$Name" -ErrorAction Stop
    $UAEContent = [System.IO.File]::ReadAllText("$PWD\build\winuae-5.0.0\game.uae")
    $UAEContent = $UAEContent.Replace("/*path*/", "$env:TEMP\$Name")
    $UAEContent = $UAEContent.Replace("/*file*/", "$romFileName")
    [System.IO.File]::WriteAllText("$PWD\build\$Name\game.uae", $UAEContent)

    $NSIcontent = $NSIcontent.Replace("/*exec*/", "winuae64.exe -f $env:TEMP\$Name\game.uae")
  }

  $NSIcontent = $NSIcontent.Replace("/*rom*/", "$romFileName")
  [System.IO.File]::WriteAllText($NSIFile, $NSIcontent)
}

function Write-Exe {
  param(
    [Parameter(Mandatory=$true)][string] $Makensis,
    [Parameter(Mandatory=$true)][string] $NSIFile
  )
  Write-Host "NSIFile : $NSIFile"
  & $Makensis "$NSIFile"
}

function Main {
  param(
    [Parameter(Mandatory=$true)][string] $Name,
    [Parameter(Mandatory=$true)][string] $In,
    [Parameter(Mandatory=$true)][string] $Out,
    [Parameter(Mandatory=$true)][string] $Arch
  )

  $cwd = Resolve-Path -Path "."

  if ($Arch -eq "gba") { $template = Join-Path -Path $cwd -ChildPath "script\nsi\template-mgba.nsi" }
  if ($Arch -eq "nes") { $template = Join-Path -Path $cwd -ChildPath "script\nsi\template-nestopia.nsi" }
  if ($Arch -eq "snes") { $template = Join-Path -Path $cwd -ChildPath "script\nsi\template-snes9x.nsi" }
  if ($Arch -eq "amiga") { $template = Join-Path -Path $cwd -ChildPath "script\nsi\template-amiga.nsi" }

  $makensis = Join-Path -Path $cwd -ChildPath "build\nsis-3.08\makensis.exe"

  $name = $Name
  $inputFile = $In
  $outputFile = $Out

  $nsiFile = Join-Path -Path $cwd -ChildPath "build\$name\$name.nsi"

  Install-NSIS -WorkingPath $(Join-Path $cwd "build")

  if ($Arch -eq "gba") { Install-mGBA -WorkingPath $(Join-Path $cwd "build") }
  if ($Arch -eq "nes") { Install-Nestopia -WorkingPath $(Join-Path $cwd "build") }
  if ($Arch -eq "snes") { Install-Snes9x -WorkingPath $(Join-Path $cwd "build") }
  if ($Arch -eq "amiga") { Install-WinUAE -WorkingPath $(Join-Path $cwd "build") }

  if (-Not(Test-Path -Path $(Join-Path -Path $cwd -ChildPath "build\$name"))) { New-Item -Path $(Join-Path -Path $cwd -ChildPath "build\$name") -ItemType Directory -Force }
  if (-Not(Test-Path -Path $inputFile)) {
    Write-Error "$inputFile not found"
    Exit 2
  }

  Copy-Item -Force -Path $inputFile -Destination "$cwd\build\$name" -ErrorAction Stop

  if ($Configure) {
    if ($Arch -eq "gba") {
      Embed-Config -EmulatorExe "$cwd\build\mgba\mGBA.exe" -ConfigFile "$cwd\build\mgba\config.ini" -DestinationPath "$cwd\build\$name"
      #New-Item -Path "$cwd\build\$name\portable.ini" -Force -ErrorAction Stop
    }
    if ($Arch -eq "nes") {
      Embed-Config -EmulatorExe "$cwd\build\nestopia\nestopia.exe" -ConfigFile "$cwd\build\nestopia\nestopia.xml" -DestinationPath "$cwd\build\$name"
    }
    if ($Arch -eq "amiga") {
      Embed-Config -EmulatorExe "$cwd\build\winuae-5.0.0\winuae64.exe" -ConfigFile "$cwd\build\winuae-5.0.0\game.uae" -DestinationPath "$cwd\build\$name"
    }
  }

  Write-NSI -Arch $Arch -NSIFile $nsiFile -template $template -Input $inputFile -Output $outputFile
  Write-Exe -Makensis $makensis -NSIFile $nsiFile
}

$version = "1.0.0-develop"

Write-Host $version
Write-Host $PWD
Write-Host $Name
Write-Host $In
Write-Host $Out
Write-Host $Arch

Main -Name $Name -In $In -Out $Out -Arch $Arch
