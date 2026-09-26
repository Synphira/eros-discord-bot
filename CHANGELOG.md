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

### Fixed

- Duplicate **Mimic Tongue Amulet** (and any multi-copy gear) — collapsed to one per player; unique DB index on `(player_id, equipment_id)` and on equipment `name` (migration `010`)
- Boss trophies now go through `grant_equipment!` (no second copy on re-clear)
- Submit crash (`undefined method '/' for nil`) — encounters have no `:level`; LP reward uses monster strength
- Willing submit scenes were defined outside `MonsterScenes` and unreachable — moved into the module
- Submit used missing `adjust_lp!` / `stat(:submission)` APIs — now `gain_lp!` and `effective_submission`

---

## Earlier (pre-changelog)

Notable work already in the project before this file existed (summary only):

- Discord bot (discordrb) with Components V2 panels; owner-locked buttons
- Explore / combat / flee / submit loop; lust assaults and climax → defiance loss
- Threat-scaled monsters; boss every 5 floors; shop + equipment; curses
- Rename to **Endless Ruins of Sin**; run reset to Lv1 STR/AGI/RES 5 on defeat
