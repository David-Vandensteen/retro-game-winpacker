# retro-game-winpacker
Pack a Game Boy Advance rom into a single Windows executable  

## SetUp
Download or clone this repository  

## Build your rom  

Run the following command to build your ROM:
```cmd
pack -Name "Castlevania - Circle of the Moon" -Input "c:\rom\gba\castlevania-circle-of-the-moon.gba" -Output "c:\rom\win-standalone\castlevania-circle-of-the-moon.exe"
```

This script automatically download NSIS & mGBA into the **build** folder.  
