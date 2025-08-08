<p align="center">
<img width="804" height="789" alt="turtle bucheron" src="https://github.com/user-attachments/assets/15865d83-ad3f-4b03-ba68-0bbddb3e90d8" />
</p>

<img width="16" height="16" alt="image" src="https://github.com/user-attachments/assets/ed9d7c93-42b9-4f00-a5ab-595a9fa1a3b3" /> [Version française](README.md)

# ComputerCraft Lumberjack Turtle
ComputerCraft program for a lumberjack turtle

## Program installation: 
  - In Minecraft, start by placing a turtle in your world; this will create a folder on your PC.
  - In the turtle, type the *id* command; you will get your turtle's ID (unique number).
  - Download the *Bucheron.lua* file, then copy it into: **saves/*WORLD*/computercraft/computer/*id*/** (the *saves* folder is in your Minecraft/FTB instance folder).
  - In the *startup.lua* file in the same folder, you can type (may depend on your CC:Tweaked version):
```
*local METIER = "Bucheron"
shell.run(METIER)*
```
  - Another solution: copy the code from *Bucheron.lua* into your *startup.lua*.
  - Then go back to Minecraft and, in your Turtle, hold Ctrl + R until it restarts. The lumberjack program will start.

## Example of a wood farm layout: 
<p align="center">
<img width="612" height="465" alt="Capture d'écran 2025-08-08 094909" src="https://github.com/user-attachments/assets/e0e6f399-be8f-43d2-a72e-1c2ec364e417" />
<img width="3840" height="2019" alt="2025-08-07_19 03 32" src="https://github.com/user-attachments/assets/b49c0819-012c-4e04-9d40-213d8377357a" />
</p>

---

# Program: Turtle Bucheron
## Version: 4.0-alpha04

### Patchnote:

<details>
  
<summary>Show previous version history</summary>

*1.0: Basic version of the lumberjack turtle  
Manual reloading and unloading of the turtle  
Refueling only on turtle reboot  
Can only manage 2 rows of trees of unlimited length.  
The area must be delimited by the type of block to be placed in slot 3.*

*1.1: Monitoring of material quantities in the inventory.  
Area limit monitoring below the turtle in addition to its front face.*

*2.0: Program redesign  
Added automatic inventory emptying/refilling for the turtle.  
Added the ability to use multiple rows.  
Added GPS.  
Removed boundary blocks, full GPS guidance.  
Enlarged inventory.  
Added manual/auto operation mode - `Manual not yet operational.`*

*2.1: Smoother inventory management.*

*2.2: Case not taken into account in string entries.  
Display of program version at turtle startup.*

*2.3: Bug fix for descending after tree cutting.*

*3.0: Integration of network communication with the server.*

*3.1: Sending position, orientation, and number of trees cut during the current run to the server with each communication cycle using the CraftNET protocol.*

*3.2: Improved energy efficiency.*

*3.3: Added stop function for the turtle from the server.  
Changed the information frame sent to the server.*

*4.0-alpha02: PixelLink integration.  
Program modified accordingly.*

*4.0-alpha03: Program corrections during tests.*

</details>

**4.0-alpha04: Program corrections during tests.**

### Roadmap:

- [x] Make the Turtle return to its waiting position in case of loss of connection with the server: validated with several disconnections in various locations. (OK v4.0-alpha03)
- [x] Same when the server no longer authorizes the Turtle to work. (OK v4.0-alpha03)
- [x] Make the Turtle exit the zone when it needs to access a chest; it must restock/deposit in the correct chest. (OK v4.0-alpha03)
- [x] Make the Turtle exit the zone when it needs to access several chests; it must restock/deposit in all chests. (OK v4.0-alpha04)
- [ ] Bug detected in v4.0-alpha03: the Turtle leaves its work area but stops immediately after losing connection to the server. Its position is displayed on the HMI. --> Single occurrence, to be monitored...
- [ ] Test on another farm (new configuration, orientation...)
- [ ] Have the Turtle figure out which way to turn at the first corner when starting the snake. The following turns will alternate left/right based on the first turn.
- [ ] Add a hardcoded start positioning if started outside its starting point.

---
> [!NOTE]
> Automaticaly exiting the logging area for inventory emptying and refilling.

> [!IMPORTANT]
> Dependent on the GPS system. A satellite must be set up to locate the Turtle.

> [!TIP]
> The satellite construction diagram and its GPS programs are [available on GitHub](https://github.com/ValDin08/ComputerCraft_Satellite_GPS).

> [!IMPORTANT]
> Dependent on the Server system and the PixelLink network.
> A Server must be programmed to communicate with the Turtle.
> The PixelLink module, [available on GitHub](https://github.com/ValDin08/ComputerCraft_Reseau/tree/main/PixelLink), must be installed on the Turtle.

> [!TIP]
> The lumberjack server program 4.0-alpha04 is [available as a pre-release on GitHub](https://github.com/ValDin08/ComputerCraft_Reseau/tree/main/Serveur%20Bucheron).

> [!WARNING]
> For your Turtle to work properly, you need to adapt the coordinates below to your setup:
> <img width="1407" height="380" alt="image" src="https://github.com/user-attachments/assets/be7f7b5d-6331-40ab-8610-66999624b9bd" />

> [!WARNING]
> For your Turtle to work properly, you need to adapt the server ID and the side where your Modem is located:
> <img width="1001" height="182" alt="image" src="https://github.com/user-attachments/assets/c485b2db-7ea6-4c09-a44b-e4e84dbb856f" />
