# E.R.O.S.

**Explorations of Risqué Underground Systems** — a text-based endless dark fantasy roguelike Discord bot.

Descend an endless dungeon of rooms, traps, and monsters. Seek the **Seal of the Abyss**. Death resets your floor to 1; **LP** and persistent **curses** carry over. High LP fuels Overdrive Surges — and raises your Threat.

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

# 4. Invite the bot (OAuth2 URL generator: scopes bot + applications.commands)
# 5. Run
bundle exec ruby bot.rb
```

## Commands

| Command / control | What it does |
|-------------------|--------------|
| `/start` | Create a delver profile (Discord ID as PK) |
| `/status` | HP, LP, active curses, Threat Level + bar |
| `/explore` | Room step; buttons **Explore Path**, **Rest**, **Use Surge** |

Prefix fallbacks (`!start`, `!status`, `!explore`) exist for local debugging.

## Game mechanics (encoded in engine)

- **Threat %** = `(Current LP / Max LP Base × 100) + (Active Curses × 15)`  
  Active = not suppressed. `Max LP Base` = 100 (`Player::MAX_LP_BASE`).
- **Threat categories**
  - `:low` — &lt; 40
  - `:medium` — 40 ≤ x &lt; 75
  - `:high` — ≥ 75
- **LP** boosts endurance pressure and enables 1-turn Overdrive Surges (Sensory Overdrive, Hardened Aura, Willpower Flush, Desperate Escape). Curse-derived surge hooks live in `SurgeManager`.
- **Shrines** — `Player#purge_curse!` / `#suppress_curse!` spend LP (stub hooks; not fully wired in Discord UI yet).
- **Combat** — `CombatEngine` starts/resolves threat-scaled encounters for `/explore`.

## Project layout

```
Gemfile
Rakefile
bot.rb
config/database.rb
db/migrations/001_create_players.rb
db/migrations/002_create_curses.rb
db/migrations/003_create_player_curses.rb
lib/engine/threat_calculator.rb
lib/engine/combat_engine.rb
lib/engine/surge_manager.rb
lib/models/player.rb
lib/models/curse.rb
.env.example
README.md
```

## Blockers / notes

- A real **DISCORD_TOKEN** is required to connect; without it the process exits on boot.
- Slash commands may take a minute to appear globally after first register; guild install is faster for testing.
