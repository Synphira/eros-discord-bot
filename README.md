# Endless Ruins of Sin

**Endless Ruins of Sin** — a text-based endless dark fantasy roguelike Discord bot.

Descend an endless dungeon of rooms, traps, monsters, and bosses. Seek the **Seal of the Abyss**. Defeat resets your floor, level, and base stats; **LP**, **curses**, and **gear** carry over. High LP and curses raise your **Threat**, which makes foes stronger and more aggressive.

## Stack

- Ruby ≥ 3.1
- [discordrb](https://github.com/shardlab/discordrb) — slash commands + buttons
- [Sequel](https://github.com/jeremyevans/sequel) + SQLite
- dotenv

## Setup

```bash
# 1. Install dependencies
bundle install

# 2. Configure secrets
cp .env.example .env
# Edit .env — set DISCORD_TOKEN and DISCORD_CLIENT_ID from the Discord Developer Portal

# 3. Create / migrate the database
bundle exec rake db:migrate

# 4. Register slash commands once (not on every bot restart)
bundle exec rake commands:register
# Optional: instant guild sync while testing
# DISCORD_GUILD_ID=your_guild_id bundle exec rake commands:register

# 5. Invite the bot (OAuth2 URL generator: scopes bot + applications.commands)
# 6. Run
bundle exec ruby bot.rb
```

## Commands

Slash and prefix share the same handlers (prefix defaults to `!`):

| Slash | Prefix | What it does |
|-------|--------|--------------|
| `/help` | `!help` | List all commands |
| `/create` · `/start` | `!create` · `!start` | Character creation — body type, then Submission attitude |
| `/status` | `!status` | Character sheet: stats, deepest floor, Threat (curses via `/curses`) |
| `/explore` | `!explore` | Room roll; monsters open **Fight / Flee / Submit** combat |
| `/curses` | `!curses` | List active curses grouped by monster type |
| `/removecurse` | `!removecurse` · `!removecurse N` | Purge a curse for **50 LP** (menu or number) |
| `/suppresscurse` | `!suppresscurse N` | Silence a curse for **25 LP**; it reactivates when you are defeated |
| `/restart` | `!restart` | New delver + body type (confirm button); titles, achievements, progress, Cursed Shop unlocks, and options are kept |
| `/profile` · `/name` | `!profile [name]` · `!name [name]` | Character profile, lifetime stats, rename; look up others by character name |
| `/titles` · `/title` | `!titles` · `!title [name\|auto]` | Paged title list with a dropdown to equip |
| `/transformation` | `!transformation [name\|clear]` (`!hybrid`) | Hybrid forms: unlock progress, switch forms, or return to human |
| `/achievements` | `!achievements [category]` | Achievements by category (combat, submission, exploration, curses, lust, events, challenges) |
| `/leaderboard` | `!leaderboard [cycles\|depth\|kills\|lp]` | Top delvers (character names only) |
| `/levelup` | `!levelup [stat\|level]` | Stats cost 5 + current value; a Level costs 80% of all three, raises max defiance, and fully heals |
| `/shop` | `!shop [category]` | Browse shop by category — buy buttons, Prev/Next pages |
| `/cursedshop` | `!cursedshop` | Free living gear you have previously worn and torn free |
| `/buy` · `/sell` | `!buy` · `!sell` | Buy / sell by name (cursed gear cannot be sold) |
| `/equipment` | `!equipment` | View gear, your trophy, and inventory |
| `/equip` · `/unequip` | `!equip` · `!unequip` | Equip / unequip normal gear (one trophy at a time) |
| `/remove` | `!remove [item]` | Destroy cursed mimic gear for LP (unlocks it in the Cursed Shop) |
| `/options` | `!options` | Content preferences in three menus (Core on by default; Bodies and Kinks opt-in) plus body sizes |
| `/fetish_options` | `!fetish_options [option] [on/off]` | Toggle one theme by key or name; no arguments lists all 43 |
| — | `!sluttify [on/off]` | Turn every theme on or off at once (prefix only) |
| `/fight` · `/flee` · `/submit` | `!fight` · `!flee` · `!submit` | Combat actions (also buttons) |

`!dev` commands (prefix only, locked to the developer's Discord ID in `DEVELOPER_ID` plus any bug testers listed in `BUG_TESTER_IDS`, comma-separated, both in `.env`) cover stat editing, item/curse grants, debug mode, and boss/cycle skips — `!dev help` lists them.

Errors print as one readable block in the console, are appended to `logs/errors.log`, and are posted to `ERROR_CHANNEL_ID` (a channel in `ERROR_GUILD_ID`) when those are set in `.env`.

Buttons are locked to the player who opened the panel. Button presses **edit** that panel in place; slash/prefix commands always send a **new** message.

### Character creation

1. Pick a **body type** (1–5).
2. Choose **Submission** attitude (Eager +3 → Resistant −3). This is a lasting character trait (not wiped on defeat).

## Game mechanics

- **Threat %** = `(Current LP / Max LP Base × 100) + (Active Curses × 15)`  
  Active = not suppressed. `Max LP Base` = 100.
- **Threat categories**
  - `:low` — &lt; 40
  - `:medium` — 40 ≤ x &lt; 75
  - `:high` — ≥ 75
- **Threat scaling** — Higher Threat boosts monster HP/STR/AGI and lust damage, and biases explore toward more monster rooms. Bosses use the same multipliers.
- **LP** — Currency for level-ups, shop gear, and curse removal. Also drives Threat.
- **Rest** (button) — −20 Lust, +15 Defiance (blocked in combat).
- **Monster types** — Beast, Demon, Slime, Undead, Plant, Mimic (each with roster, color, and assault/submit flavor).
- **Curses** — Defeat rolls a curse from the foe's type pool. Effects include lust/damage multipliers, encounter weighting, no-flee/no-death, climax LP, defiance start penalties, and flat STR/AGI/RES.
- **Combat** — **Fight** chips monster **HP**. **Flee** (AGI-based). **Submit** / monster hits raise **lust** with assault scenes; climax at 100 costs 20 defiance. Victory grants LP (no automatic floor advance). Defeat applies a curse and resets floor, level, base stats, defiance, and lust. **Non-cursed gear is lost**; living (cursed) mimic gear persists.
- **Bosses** — Every 5th floor, once per gate. Defeating *or satisfying* the boss clears it, grants LP and a trophy, and advances one floor. Bosses are half as easy to satisfy as normal monsters. Only one trophy can be worn at a time, and trophies are lost on defeat.
- **Stats** — STR: damage. AGI: flee, dodge monster attacks (not while submitting), avoid traps, and slip free of multi-turn events. RES: cuts every lust hit by `100 / (100 + RES × 5)`. Max defiance grows with level: `100 + 10·√(level − 1)`.
- **Explore** — Weighted rooms: monster / trap / treasure / **stairs** (floor+) / empty, plus **random events** (glory hole choices, multi-turn violations, instant traps). Lust traps that hit 100+ also climax.
- **Treasure** — Chests can yield LP, defiance potions (drunk immediately), basic gear, or **living mimic equipment** that auto-binds and may violate you in combat. No duplicate items.
- **Equipment** — Shop / chests / boss trophies. Equipped gear modifies effective STR/AGI/RES (and lust resist / submission on mimics). Cursed gear requires `!remove` + LP to destroy.

## Project layout

```
Gemfile
Rakefile
bot.rb                          # runtime only — does not register slash commands
register_commands.rb            # one-shot slash registrar
CHANGELOG.md                    # notable changes (keep updated)
config/slash_commands.rb        # slash command definitions
config/database.rb
commands/…
lib/…
db/migrations/…
.env.example
README.md
```

Slash commands are registered with a single bulk overwrite via `bundle exec rake commands:register` (not on every `bot.rb` restart).

All Discord replies use **Components V2** (`has_components: true`) — containers + text displays instead of classic content/embeds.

## Notes

- A real **DISCORD_TOKEN** is required to connect; without it the process exits on boot.
- Run `bundle exec rake commands:register` after changing slash names/descriptions. Global sync can take up to ~1 hour; set `DISCORD_GUILD_ID` for instant guild-scoped registration while testing.
