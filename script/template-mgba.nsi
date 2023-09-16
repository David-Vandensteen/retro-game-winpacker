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
Icon "..\..\ico\default-gba.ico"
BrandingText "Created with Retro Win Packer /*version*/"
AutocloseWindow True

Section "install"
  SetOutPath $InstDir
  File "/*rom*/"
  File "..\mgba\mGBA.exe"
  File "config.ini"
  File "..\mgba\portable.ini"
  Exec '/*exec*/'
SectionEnd