# PvPTimer

A small, movable display that shows when you're PvP flagged and counts down your flag timer, restarting at 5:00 every time you get reflagged. Made for WoW Forever.

## Features

- **Two-line display:** "PvP: ON" with the timer underneath.
- **Shows only when you're flagged** and hides as soon as your flag drops.
- **Live countdown** from the game's own PvP timer, so it always matches what the game uses.
- **Resets on reflag:** attack or help a flagged player and the countdown jumps back to 5:00, with a quick flash so you notice.
- **Colour cues:** red normally, yellow under 60 seconds, green under 30.
- **Manual flag (`/pvp`):** holds at 5:00 while you stay flagged and starts counting down when you turn PvP off.
- **Optional sound** when the timer resets.
- **Movable and lockable**, and remembers its position.

## Commands

| Command | What it does |
| --- | --- |
| `/pvptimer` or `/pvpt` | Lists the commands |
| `/pvpt unlock` | Shows the frame so you can drag it into place |
| `/pvpt lock` | Locks it in place and hides it when you're not flagged |
| `/pvpt reset` | Moves it back to the default position (top centre) |
| `/pvpt sound` | Turns the sound on timer reset on or off (off by default) |
| `/pvpt flagged` | Turns the 5:00 hold display on or off for when you're flagged but the countdown hasn't started |

## Install

1. Download and unzip the file.
2. Copy the `PvPTimer` folder into the `Interface/AddOns` folder of your WoW Forever install.
3. Fully quit and restart the game. `/reload` isn't enough to pick up a new addon.
4. Type `/pvpt unlock`, drag the frame where you want it, then type `/pvpt lock`.

## Known issues

- WoW Forever uses the Midnight addon restrictions. If the game hides the PvP timer from addons in some situations, PvPTimer shows "PvP: ON" with 5:00 instead of a live countdown.
- While you're flagged manually with `/pvp`, the game doesn't run a timer, so the display holds at 5:00 until you turn PvP off.

## Author

mythicautopsy – The Monsoon Brigade @ Alliance PVE

Source and issues: https://github.com/mythicautopsy/PvPTimer

Licensed under MIT.
