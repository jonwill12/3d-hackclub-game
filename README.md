3D Hackclub Game
A first-person shooter where you survive against enemies that hunt you down across an open arena.

🎮 Play the Demo
Play on itch.io → https://jonwill12.itch.io/hackclub3dgame

Quick Start

Go to the itch.io page
Download the zip
Extract and run hackclub3dgame.exe


Features

First-person movement with sprint, crouch, and jump
Shoot enemies with a full weapon system including pistol, rifle, shotgun, sniper, and rocket launcher
Enemies that chase and attack you using pathfinding
Player health system with HUD health bar
Enemies take damage and die when shot
Animated enemy characters using Mixamo animations


How It Works
The game uses a state machine based character controller for smooth first-person movement with separate states for idle, walking, running, crouching, jumping, and being in the air. Enemy AI uses Godot's NavigationAgent3D to path toward the player across a baked NavMesh, and deal contact damage when close. The weapon system is resource-based, making it easy to add and customize new weapons with different stats, fire rates, and ammo types.

Built With

Godot 4 — game engine
JehenoSimpleFPSWeaponSystem — weapon system addon
JehenoSimpleFPSController — character controller addon
Mixamo — enemy character and animations
Kenney — prototype textures


Credits
Built for Hack Club Stardance by jonwill12.
