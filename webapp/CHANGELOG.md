# Web Version Changelog

All notable changes to the **standalone browser version** of Endless Ruins of Sin (`webapp/`) are recorded here.
Changes to the Discord bot go in the main [`CHANGELOG.md`](../CHANGELOG.md).

Format: newest entries first. Dates use the day the work landed in this repo.

---

## 2026-10-04

### Added

- **Standalone web game** running on ruby.wasm in the browser: age gate, character creation (body type, submission stance, name), and a status panel. Progress saves automatically to this browser's local storage.
- **Full bot ruleset**: the web game now runs the Discord bot's own engine, so combat, elites, boss phases and trophies, every random and opt-in event, NPC story arcs, curses, conditions, corruption, orgasm addiction, chastity, hybrid forms, titles, achievements, marks and tower cycles all work the same as on Discord. Weekly modifiers and the leaderboard are left out because the web game is single-player.
- **Screens**: Shop, Cursed Shop, Gear, Curses (remove or suppress), Level Up, Profile (titles and achievements by category), Hybrids, Parlour, Content Options (toggles and body sizes), and Settings with game stats.
- **Rest**: clears lust and fully restores defiance, with a 5-minute cooldown.
- **Restart** erases your delver but keeps titles, achievements, records and content options. **Delete save** erases everything.
- **Side panel navigation**: Profile, Hybrids, Shop, Cursed Shop and Parlour buttons sit in the status panel so they are reachable from any screen. The current screen is highlighted, and the buttons are disabled during combat and events.
- **Sync tool**: `ruby webapp/tools/sync_from_bot.rb` copies the bot's latest engine into the web version after bot changes.
- **Export / Import save**: Settings can export your save as a code (copy it or download it as a file) and import one to continue on another browser or device. Character creation also offers **Import a save**. Bad or damaged codes are rejected without touching your current game.
- **itch.io build**: `ruby webapp/tools/build_itch.rb` syncs the engine, bundles the Ruby runtime, runs a quick test and writes an upload-ready zip to `webapp/dist/`.

### Changed

- Saves from the first web prototype can't be loaded. You get a short notice and start character creation instead.
- The Ruby runtime now ships with the game (`vendor/`, fetched by `webapp/tools/vendor_ruby.rb`), so it loads without a CDN. The CDN is still used as a fallback for local play without the bundle.

### Fixed

- The game now loads even on hosts that don't serve `.wasm` files with the WebAssembly content type.
- The notice about incompatible old saves is now actually shown instead of being cleared before display.
- **Scrolling on mobile**: the page now scrolls on phones, including inside the itch.io embed. On small screens the story log flows with the page instead of being a separate scroll box that could trap your swipes. The export/import window scrolls on short screens too.
