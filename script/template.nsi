Unicode True
SetCompress force
SetCompressor lzma

!Define packageName "/*title*/"

RequestExecutionLevel user

Name "${packageName}.exe"
ShowInstDetails nevershow
SilentInstall normal
OutFile "/*output*/"
InstallDir "$TEMP\${packageName}"
Icon "..\..\ico\default-gba.ico"
BrandingText "Created with Retro Win Packer"
AutocloseWindow True

Section "install"
  SetOutPath $InstDir
  File "/*rom*/"
  /*configFile*/
  /*portableFile*/
  File "..\mgba\mGBA.exe"
  Exec 'mGBA.exe --fullscreen "/*rom*/"'
SectionEnd