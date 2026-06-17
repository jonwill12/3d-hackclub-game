# Escape Protocol

A fast-paced 3D first-person shooter where players battle through increasingly difficult levels, unlocking new challenges as they progress.

![Gameplay Screenshot](images/gameplay.png)

> **🎮 Play the game:** *(Add your web demo or download link here)*


### Play on Desktop

1. Download the latest release.
2. Extract the files.
3. Run `godot 3d fps.exe`.

---

# Features

* 🎯 Fast-paced first-person shooter gameplay
* 🔓 Level progression with unlockable levels
* 📖 Tutorial level to teach game mechanics
* 🎮 Smooth movement including running, crouching, and jumping
* 💾 Progress automatically saves between sessions
* 🖼️ Custom level selection screen with preview images and locked levels 


### Requirements

* Godot 4.x


# How It Works

The game is built entirely in Godot using GDScript.

A save system stores player progress in a `ConfigFile`, allowing completed levels to unlock the next level automatically. The level select menu dynamically creates level cards from a list, making it easy to add new levels without redesigning the UI.

In order to relock the levels, you need to delete the save.cfg

The player controller supports smooth acceleration, bunny hopping, crouching, sprinting, jumping, and air movement to create responsive FPS controls.

---

# Roadmap

* More levels
* Better enemy AI
* Weapons and upgrades
* Boss battles
* Sound effects and music
* Additional environments

---

# Credits

Created by **Jonathan  Willner**

Built with:

* Godot Engine
* GDScript

Thanks to everyone who tested the game and provided feedback! and feal free to give your own feed back 
