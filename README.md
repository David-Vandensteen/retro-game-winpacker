# retro-game-winpacker
Pack a Game Boy Advance rom into a single Windows executable  

## SetUp
Download or clone this repository  

## Build a rom
```cmd
mak build "Castlevania - Circle of the Moon" "c:\rom\gba\castlevania-circle-of-the-moon.gba" "c:\rom\gba\castlevania-circle-of-the-moon.ico"
```

The last argument is optional  
This script download NSIS & VisualBoyAdvance in **build** folder  
He build a autonomous exe of the rom in **dist** folder
