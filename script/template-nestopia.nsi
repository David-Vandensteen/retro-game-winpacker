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
Icon "..\..\ico\default-nes.ico"
BrandingText "Created with Retro Win Packer /*version*/"
AutocloseWindow True

Section "install"
  SetOutPath $InstDir
  File "/*rom*/"

  /*configFile*/

  SetOutPath "$INSTDIR\language"
  File "..\nestopia\language\english.nlg"

  SetOutPath $INSTDIR
  File "..\nestopia\nestopia.exe"

  Exec '/*exec*/'
SectionEnd