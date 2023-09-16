Unicode True
SetCompress force
SetCompressor /SOLID lzma
SetDatablockOptimize ON
SetCompressorDictSize 64

!Define packageName "/*title*/"

RequestExecutionLevel user

Name "${packageName}.exe"
ShowInstDetails nevershow
SilentInstall normal
OutFile "/*output*/"
InstallDir "$TEMP\${packageName}"
Icon "..\..\ico\default-snes.ico"
BrandingText "Created with Retro Win Packer /*version*/"
AutocloseWindow True

Section "install"
  SetOutPath $InstDir\Roms
  File "/*rom*/"

  SetOutPath $InstDir
  File "snes9x.conf"
  File "..\snes9x\snes9x-x64.exe"

  Exec '/*exec*/'
SectionEnd