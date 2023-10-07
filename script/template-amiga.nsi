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
Icon "..\..\ico\default-amiga.ico"
BrandingText "Created with Retro Win Packer /*version*/"
AutocloseWindow True

Section "install"
  SetOutPath $InstDir
  File "/*rom*/"
  File "..\winuae-5.0.0\Amiga kick13.rom"
  File "..\winuae-5.0.0\winuae64.exe"
  File "game.uae"
  Exec '/*exec*/'
SectionEnd