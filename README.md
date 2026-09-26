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
| `/removecurse` | `!removecurse` · `!removecurse N` | Purge a curse for **50 LP** (buttons or number) |
| `/levelup` | `!levelup` | Spend LP: STR/AGI/RES (10) or Level (50, +1 all stats) |
| `/shop` | `!shop` | Browse shop by category — buy buttons, Prev/Next pages |
| `/buy` · `/sell` | `!buy` · `!sell` | Buy / sell by name (cursed gear cannot be sold) |
| `/equipment` | `!equipment` | View gear (cursed items show LP removal cost) |
| `/equip` · `/unequip` | `!equip` · `!unequip` | Equip / unequip normal gear |
| `/remove` | `!remove [item]` | Destroy cursed mimic gear for LP |
| — | `!fight` · `!flee` · `!submit` | Combat actions (also buttons) |

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
- **Bosses** — Every 5th floor, once per gate. Victory clears the boss, grants a trophy item + LP, and advances one floor.
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
