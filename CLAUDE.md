# PvPTimer

Shared WoW Forever rules: ../CLAUDE.md (if present locally).

Small movable frame that shows "PvP: ON" and counts down the PvP flag timer,
resetting to 5:00 on reflag. Shown only while flagged (unless unlocked).

## Files
- `PvPTimer.toc`, `PvPTimer.lua` (everything: frame, state, events, slash).

## SavedVariables `PvPTimerDB`
- `point` = `{ point, relPoint, x, y }`, `locked` (default true),
  `showFlagged` (default true), `sound` (default false).

## Behaviour to keep
- Countdown comes from the game's own PvP timer; if it's secret/unavailable,
  show 5:00 rather than an estimate.
- Manual `/pvp` flag has no game timer: hold at 5:00 until PvP is turned off.
- Colours: red, yellow < 60s, green < 30s; flash on reset.
- Events: PLAYER_FLAGS_CHANGED, UNIT_FACTION, ZONE_CHANGED_NEW_AREA,
  PLAYER_ENTERING_WORLD.

## Slash: `/pvptimer`, `/pvpt` — unlock, lock, reset, sound, flagged.
No CHANGELOG.md yet.
