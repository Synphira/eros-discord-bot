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
| `/create` · `/start` | `!create` · `!start` | Character creation — pick body type (buttons or `!create 1`–`5`) |
| `/status` | `!status` | Full character sheet: body, stats, defiance, lust, LP, Threat |
| `/explore` | `!explore` | Room roll; monsters open **Fight / Flee / Submit** combat |
| `/curses` | `!curses` | List active curses grouped by monster type |
| `/removecurse` | `!removecurse` · `!removecurse N` | Purge a curse for **50 LP** (buttons or number) |
| `/levelup` | `!levelup` | Spend LP: STR/AGI/RES (10) or Level (50, +1 all stats) |
| `/shop` | `!shop` | Browse and buy equipment with LP |
| `/equipment` | `!equipment` | View / equip / unequip gear |
| — | `!fight` · `!flee` · `!submit` | Combat actions (also buttons) |

Buttons are locked to the player who opened the panel. Button presses **edit** that panel in place; slash/prefix commands always send a **new** message.

### Character types

1. Male — penis, anus  
2. Male (FtM) — vagina, anus  
3. Female — vagina, anus, breasts  
4. Female (MtF) — penis, anus, breasts  
5. Hermaphrodite — penis, vagina, anus, breasts  

New delvers start at level 1 with defiance 100, lust 0, LP 0, and STR/AGI/RES 5.

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
- **Combat** — **Fight** chips monster **HP**. **Flee** (AGI-based). **Submit** / monster hits raise **lust** with assault scenes; climax at 100 costs 20 defiance. Victory grants LP (no automatic floor advance). Defeat applies a curse and resets floor, level, base stats, defiance, and lust.
- **Bosses** — Every 5th floor, once per gate. Victory clears the boss, grants a trophy item + LP, and advances one floor.
- **Explore** — Weighted rooms: monster / trap / treasure / **stairs** (floor+) / empty. Lust traps that hit 100+ also climax.
- **Equipment** — Shop purchases and boss trophies; equipped gear adds to effective STR/AGI/RES.

## Project layout

```
Gemfile
Rakefile
bot.rb                          # runtime only — does not register slash commands
register_commands.rb            # one-shot slash registrar
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
