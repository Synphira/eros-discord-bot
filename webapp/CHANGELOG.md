# Web Version Changelog

All notable changes to the **standalone browser version** of Endless Ruins of Sin (`webapp/`) are recorded here.
Changes to the Discord bot go in the main [`CHANGELOG.md`](../CHANGELOG.md).

Format: newest entries first. Dates use the day the work landed in this repo.

---

## 2026-10-19

### Added

- **Syn & Berry's**: the shop and parlour are now run by a married fairy couple — Berry (cheerful, possessive, runs the shop) and Syn (dark, exhausted, flirty, works the parlour bench). Madame Vex is retired, and all mark scenes name Syn. **Berry's quest board** is on the Parlour screen: 3 offers at a time, up to 3 active, 12 repeatable errands paying 50–150 LP, with the **Berry's Favourite** achievement (10) and title (25). Synced from the bot.

### Changed

- **Chest loot rebalanced**: Defiance Tonics are rarer (25% → 15%), chests can drop useful consumables (Defiance Draught, Cooling Elixir, Bottled Sanctuary — always one you can use), and once you own all the chest-only gear, gear drops become unowned shop items instead of quietly turning into LP. Synced from the bot.

### Added

- **Gaping & Fisting** opt-in fetish (58 toggles total) with three fisting events — Shrine of the Open Hand, The Gauntlet and The Living Gauntlet — plus the **Wide Open** title and achievement. Synced from the bot.

### Changed

- **Curses can now find you mid-combat**: orgasming in a fight (35%), satisfying a monster (30%, bosses 40%) and winning (10%, elites 25%, bosses 40%) can all brand you, with +5% per extra cycle. New curses are always ones you don't already have, and curses raise Threat, so the game gets harder the more you collect. Resistance and Submission also scale less steeply in deep cycles, so lust hits and satisfying take longer. Synced from the bot.

### Fixed

- Egg-laying events (Egg Chamber, Oviposition Chamber, Spawning Pool) now lay their eggs in your ass instead of your pussy. Synced from the bot.

## 2026-10-14

### Changed

- Combat text names the new final boss as just "Eros", never "the Eros".

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
