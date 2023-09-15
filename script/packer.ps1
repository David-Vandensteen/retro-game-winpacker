param(
  [Parameter(Mandatory=$true)][string] $Name,
  [Parameter(Mandatory=$true)][string] $In,
  [Parameter(Mandatory=$true)][string] $Out,
  [Parameter(Mandatory=$true)][string] $Arch,
  [switch] $EmbedConfig
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
    [Parameter(Mandatory=$true)][string] $Arch,
    [string] $ConfigFile = $null
  )

  $romFileName = Split-Path -Path $InputFile -Leaf
  Write-Host "create nsis script"
  Write-Host $template
  Write-Host $NSIFile
  $NSIcontent = [System.IO.File]::ReadAllText($template).Replace("/*title*/", $Name).Replace("/*output*/", $OutputFile)
  $NSIcontent = $NSIcontent.Replace("/*version*/", $version)
  if ($ConfigFile -and ($Arch -eq "gba")) { $NSIcontent = $NSIcontent.Replace("/*configFile*/", 'File "config.ini"') }
  if ($ConfigFile -and ($Arch -eq "gba")) { $NSIcontent = $NSIcontent.Replace("/*mgba-portableFile*/", 'File "portable.ini"') }

  if ($Arch -eq "gba") {
    $NSIcontent = $NSIcontent.Replace("/*exec*/", 'mGBA.exe --fullscreen "/*rom*/"')
  }

  if ($Arch -eq "nes") {
    if ($ConfigFile) {
      $nestopiaContent = [System.IO.File]::ReadAllText("$PWD\build\nestopia\nestopia.xml")
      $nestopiaContent = $nestopiaContent.Replace("$PWD\build\nestopia", "$env:TEMP\$Name")
      $nestopiaContent = $nestopiaContent.Replace("            <start-fullscreen>no</start-fullscreen>", "            <start-fullscreen>yes</start-fullscreen>")
      [System.IO.File]::WriteAllText("$PWD\build\$Name\nestopia.xml", $nestopiaContent)
      $NSIcontent = $NSIcontent.Replace("/*configFile*/", 'File "nestopia.xml"')
    }
    $NSIcontent = $NSIcontent.Replace("/*exec*/", 'nestopia.exe "/*rom*/"')
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
  if ($Arch -eq "gba") { $template = Join-Path -Path $cwd -ChildPath "script\template-mgba.nsi" }
  if ($Arch -eq "nes") { $template = Join-Path -Path $cwd -ChildPath "script\template-nestopia.nsi" }
  $makensis = Join-Path -Path $cwd -ChildPath "build\nsis-3.08\makensis.exe"

  $name = $Name
  $inputFile = $In
  $outputFile = $Out

  $nsiFile = Join-Path -Path $cwd -ChildPath "build\$name\$name.nsi"

  Install-NSIS -WorkingPath $(Join-Path $cwd "build")

  if ($Arch -eq "gba") { Install-mGBA -WorkingPath $(Join-Path $cwd "build") }
  if ($Arch -eq "nes") { Install-Nestopia -WorkingPath $(Join-Path $cwd "build") }

  if (-Not(Test-Path -Path $(Join-Path -Path $cwd -ChildPath "build\$name"))) { New-Item -Path $(Join-Path -Path $cwd -ChildPath "build\$name") -ItemType Directory -Force }
  if (-Not(Test-Path -Path $inputFile)) {
    Write-Error "$inputFile not found"
    Exit 2
  }

  Copy-Item -Force -Path $inputFile -Destination "$cwd\build\$name" -ErrorAction Stop

  if ($EmbedConfig) {
    if ($Arch -eq "gba") {
      Embed-Config -EmulatorExe "$cwd\build\mgba\mGBA.exe" -ConfigFile "$cwd\build\mgba\config.ini" -DestinationPath "$cwd\build\$name"
      New-Item -Path "$cwd\build\$name\portable.ini" -Force -ErrorAction Stop
    }
    if ($Arch -eq "nes") {
      Embed-Config -EmulatorExe "$cwd\build\nestopia\nestopia.exe" -ConfigFile "$cwd\build\nestopia\nestopia.xml" -DestinationPath "$cwd\build\$name"
    }
  }

  if ($EmbedConfig) {
    Write-NSI -Arch $Arch -NSIFile $nsiFile -template $template -Input $inputFile -Output $outputFile -ConfigFile "$cwd\build\mgba\config.ini"
  } else {
    Write-NSI -Arch $Arch -NSIFile $nsiFile -template $template -Input $inputFile -Output $outputFile
  }

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
