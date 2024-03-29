# retro-game-winpacker  
![](https://i.ibb.co/jVHbc1G/retro-game-winpacker.png)

This script simplifies the creation of standalone executable files for retro game emulation.  
It is designed for the context of retro gaming, where an emulator is embedded within a standalone Windows executable.


## SetUp  

Download or clone this repository.  

### Parameters

- **In**: The input file or path to the game ROM.
- **Out**: The output file or path for the standalone executable.
- **Configure**: (optional) A switch to embed configuration settings.
- **ForceArch**: (optional) By default the target system is defined by the file extension (.adf, .nes, .sfc, .gba) but you can force the video game system if needed.  
  value can be : nes, snes, gba, amiga

The Configure switch is an optional feature in the script.  
When activated, it includes emulator configuration settings in the standalone executable.  

Without it, the executable contains only the game ROM, emulator and a default config with fullscreen, requiring users to configure the emulator manually for things like resolution and controls.  

With Configure enabled, the script initiates the emulator program.  
It allows the emulator to open, presenting the user with its configuration options and settings.  
The script remains in a "waiting" state, not proceeding further until the user completes their configuration and closes the emulator.  

### Build game example    

Run the following command to build your ROM:
```cmd
pack -In "c:\rom\gba\castlevania-circle-of-the-moon.gba" -Out "c:\rom\win-standalone\castlevania-circle-of-the-moon.exe"
```
