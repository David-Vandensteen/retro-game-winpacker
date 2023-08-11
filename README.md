# retro-game-winpacker
Pack a Game Boy Advance rom into a single Windows executable  

## SetUp
Download or clone this repository  

## Build your rom  

Run the following command to build your ROM:
```cmd
mak build "Castlevania - Circle of the Moon" "c:\rom\gba\castlevania-circle-of-the-moon.gba" "c:\rom\gba\castlevania-circle-of-the-moon.ico"
```

The last argument is optional  
This script automatically download NSIS & VisualBoyAdvance into the **build** folder.  
Once the build process is complete, you'll find an autonomous executable of the ROM in the **dist** folder.
