# Changelog

All notable changes to **Endless Ruins of Sin** are recorded here.

Format: newest entries first. Dates use the day the work landed in this repo.

---

## 2026-09-26

### Added

- **`CHANGELOG.md`** — ongoing record of notable changes (this file)
- **Submission** character trait (−3…+3) chosen during creation after body type
  - Migration `008_add_submission`
  - Options: Eager (+3), Curious (+1), Neutral (0), Reluctant (−1), Resistant (−3)
  - Shown on welcome / status; persists across run resets
  - Affects monster orgasm chance on Submit
- **Treasure system** (`lib/engine/treasure.rb`)
  - Chest loot: LP pouches, immediate defiance tonics, basic gear, or living mimic equipment
  - Mimic chance scales with floor
  - Migration `009_add_cursed_equipment` (`cursed`, `violation_type`, `removal_cost`)
- **Living mimic gear** — Seductive Lingerie, Binding Corset, Enchanted Heels, Living Necklace, Throne’s Throne
  - Auto-binds on find; may violate the wearer during combat (scene + lust)
  - Removed only via `!remove` / `/remove` for LP (item destroyed)
- **`!remove [item]`** — destroy cursed mimic gear for its removal cost
- Basic treasure gear pool (buckler, boots, bracers, vest, short blade)
- **Deepest floor** on `/status` — lifetime highest floor reached (survives defeat)
- **Random events** — glory hole (choice buttons), tentacle pit / mist / vines / spirit (Continue turns), dildo trap & humiliation mirrors (instant); chance scales with floor
- Shop category tabs + buy buttons + pagination (Weapons / Armor / Accessories / Special)
- **`/restart` / `!restart`** — confirm button, then erases the delver completely (LP, curses, all gear, deepest floor) and reopens creation to pick a new body type and Submission. **Run `bundle exec rake commands:register`** for the slash command
- **Max Defiance** — Defiance is your HP; "max HP" effects (Treant Heartwood, Abyssal Plate, Deathly Resilience) raise the cap above 100. Shown as `Defiance d/max` everywhere
- **Boss trophies have real effects** and stack in a dedicated **Trophy** slot (all worn at once, auto-equipped on win, kept through defeat):
  - Mimic Tongue Amulet +2 Submission · Queen's Favor −20% lust damage · King's Crown +3 STR/AGI · Treant Heartwood +10 max Defiance, +2 RES · Lich's Phylactery cheat death once per run · Alpha Beast Trophy −30% monster rooms · Boss Trophy +1 STR/AGI/RES
- `!equipment` lists worn trophies, Phylactery charge state, and each item's stat effects
- Migration `013_add_run_flags` (`phylactery_used`, `sanctuary`)
- **3 new mimic curses** (synced on boot):
  - **Mimic Flesh** — 10% less damage from all monsters, +15% lust damage from mimics
  - **Box Cravings** — +5 LP on every chest opened, +15% damage from mimics
  - **Phantom Latch** — 10% chance per enemy attack to absorb it outright (max once per combat), +20% lust damage from mimics

### Changed

- Shop lists **only** shop catalog stock — cursed / treasure / boss trophies no longer appear
- `/status` no longer lists active curses (use `/curses`); shows **Deepest floor** instead
- `/status` notes an in-progress random event when one is active
- Character creation is two-step: body type → Submission attitude
- Treasure rooms no longer always grant flat +10 LP; they roll the treasure table
- Defeat / broken run: **non-cursed equipment is lost**; cursed mimics, LP, and curses persist
- Shop / grants refuse **duplicate** ownership of the same item
- Combat UI: assault / submit **scenes** render in their own italic blocks between dividers
- Effective stats: equipment can contribute lust resist and submission; lust hits use lust resist
- Submit satisfy chance: 20% + 10% per effective Submission, clamped 5–80%; the chance is shown when a submit fails
- Flee chance now uses effective AGI (gear included)
- Healing (rest, tonics, life drain, regen) is scaled by healing curses (Deathly Resilience −30%)
- Gelatinous Form's 15% damage reduction now applies to all lust damage

### Fixed

- Duplicate **Mimic Tongue Amulet** (and any multi-copy gear) — collapsed to one per player; unique DB index on `(player_id, equipment_id)` and on equipment `name` (migration `010`)
- Boss trophies now go through `grant_equipment!` (no second copy on re-clear)
- Submit crash (`undefined method '/' for nil`) — encounters have no `:level`; LP reward uses monster strength
- Willing submit scenes were defined outside `MonsterScenes` and unreachable — moved into the module
- Submit used missing `adjust_lp!` / `stat(:submission)` APIs — now `gain_lp!` and `effective_submission`
- **Submitting with high Submission caused instant defeat** — satisfying the monster was treated as being broken. It now ends the encounter peacefully (like a successful flee)
- **Lich's Phylactery** did nothing — now restores half your max Defiance once per run when you'd be broken or defeated
- **Infernal Lust** never applied its +30 starting lust — lust now starts at 30 after a run reset and after each climax, and resting can't drop below it
- Shop items that did nothing: Soul-Draining Blade (+2 damage per hit), Abyssal Plate (+10 max Defiance), Talisman of Escape (+20% flee — was rounded to 0), Ring of Sustenance (+3 Defiance per combat round)
- **Curse Purification Scroll** also charged the 50 LP removal fee — now costs only its price
- **Bottled Sanctuary** did nothing — the next explore is now guaranteed safe (treasure, stairs, or empty room)
- Curse effects that were never applied now work: Beast Bait / Infernal Lust LP bonuses, Mimic Tongue flee penalty, Hellfire Blood +2 damage vs demons, Necrotic Aura (living foes miss 20% of the time; +30% undead), Blooming Scent (fewer plants, more monsters), Photosynthesis regen at fight start
- Defiance is clamped when max-Defiance gear or curses are removed
- Treasure-LP curses (Object Desire, Box Cravings) now pay out on **every** chest, not only LP-pouch results

---

## Earlier (pre-changelog)

Notable work already in the project before this file existed (summary only):

- Discord bot (discordrb) with Components V2 panels; owner-locked buttons
- Explore / combat / flee / submit loop; lust assaults and climax → defiance loss
- Threat-scaled monsters; boss every 5 floors; shop + equipment; curses
- Rename to **Endless Ruins of Sin**; run reset to Lv1 STR/AGI/RES 5 on defeat
