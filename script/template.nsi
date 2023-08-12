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
  File "..\visualboyadvance\visualboyadvance.exe"
  Exec 'visualboyadvance.exe "/*rom*/"'
SectionEnd