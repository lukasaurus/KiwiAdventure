# Build Your Own Level! 🥝

## 1. Open your level
In the **FileSystem** panel (bottom left), double-click **`scenes/my_level.tscn`**.

## 2. Add things
Drag pieces from the FileSystem into the 3D view. **Drop them onto the `World` node** (or onto the ground in the 3D view).

| Folder | What's in it |
|---|---|
| `models/PlatformerKit/` | Blocks, slopes, fences, trees, crates, pipes... (solid automatically!) |
| `models/MiniForest/` | Trees, rocks, tents, bridges, ladders |
| `objects/coin.tscn` | 🪙 Coins - collect them all to unlock the flag |
| `objects/goal_flag.tscn` | 🏁 The finish line (only one per level!) |
| `objects/jump_pad.tscn` | 🚀 Bounces you high into the air |
| `objects/moving_platform.tscn` | ↔️ Slides back and forth |
| `objects/platform_falling.tscn` | 💥 Falls when you stand on it |
| `objects/hazard_spikes.tscn` | ☠️ Spikes - back to the start! |
| `objects/hazard_saw.tscn` | ☠️ Spinning saw that slides around |
| `objects/brick.tscn` | 🧱 Hit it from underneath to smash it |

**Tip:** Click the **⋮ / list icon** at the top of the FileSystem panel and choose **thumbnails** to see pictures of every model.

## 3. Move things around
| Key | Does |
|---|---|
| **W** | Move tool (drag the coloured arrows) |
| **E** | Rotate tool |
| **R** | Scale tool |
| **Hold Ctrl while dragging** | Snap to the grid (blocks line up perfectly!) |
| **Ctrl + D** | Duplicate the selected piece |
| **F** | Zoom the camera to the selected piece |
| **Delete** | Remove the selected piece |
| **Right mouse + WASD** | Fly around the 3D view |

## 4. Test it!
Press **F6** (or the 🎬 "Run Current Scene" button, top right) to play **your level** straight away.
Press **F5** to play the whole game from the title screen.

**In the game:** WASD move · SPACE jump (press twice to double jump!) · Mouse look · Scroll zoom · R restart · Esc free the mouse

## 5. Make it yours
* Click the top **`Level`** node → Inspector → change **Level Name**.
* Click a jump pad → change **Strength**.
* Click a moving platform or saw → change **Move Offset** (where it goes) and **Move Time** (how slow).

## Challenge ideas 🏆
* Hide a coin somewhere you can only reach with a jump pad.
* Build a staircase up to the flag.
* Make a path of falling platforms over a big gap.
* Swap your level with a friend and see who can beat it fastest!
