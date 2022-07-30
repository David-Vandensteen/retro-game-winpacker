Unicode True
SetCompress force
SetCompressor lzma

!Define packageName "/*title*/"

RequestExecutionLevel user

Name "${packageName}.exe"
ShowInstDetails nevershow
SilentInstall normal
OutFile "..\..\dist\${packageName}.exe"
InstallDir "$TEMP\${packageName}"
Icon "..\..\ico\default-gba.ico"
BrandingText "David Vandensteen - 2022"
AutocloseWindow True

Section "install"
  SetOutPath $InstDir
  File "/*rom*/"
  File "..\visualboyadvance\visualboyadvance.exe"
  Exec 'visualboyadvance.exe "/*rom*/"'
SectionEnd