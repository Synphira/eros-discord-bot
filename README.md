# Endless Ruins of Sin

> ## ⚠️ 18+ ONLY — EXPLICIT NSFW CONTENT
>
> **This Discord bot is for adults 18 years of age or older.**
>
> It is an **explicit erotic / pornographic** text game. Expect graphic sexual
> descriptions, non-consent and dubious-consent themes, bondage, monsters,
> transformation, corruption, and related fetish content.
>
> **If you are under 18, leave now.** Do not invite the bot, do not play, do not
> read further. There is no “mostly SFW” mode — content toggles only filter
> *which* adult themes appear, not whether the game is adult.
>
> Hosts: keep the bot in **NSFW / age-restricted** channels or DMs. Inside a
> normal server channel that is not marked NSFW, the bot will refuse to answer.

---

**Endless Ruins of Sin** is a text-based dark-fantasy **NSFW** roguelike Discord
bot. You descend a lust-soaked tower of rooms, traps, monsters, and domain lords,
climbing toward **Eros, Goddess of Lust**, on floor 35.

Defeat sends you back to floor 1 with a new curse. **Lust Points (LP)**,
**curses**, **living gear**, **marks**, **titles**, and long progress carry over.
Clearing the tower starts a harder **cycle**. High LP and curses raise
**Threat**, which makes the tower stronger and hornier.

Support server: [discord.gg/fXWCsyCUyU](https://discord.gg/fXWCsyCUyU)

---

## What you play

- **Explore** rooms: monsters, traps, treasure, events, stairs, altars, strange rooms.
- **Combat:** Fight, Flee, or Submit. Lust builds; climax drains Defiance. At 0 Defiance you break.
- **Bosses** every 5 floors (and Eros at 35). Defeat *or* satisfy them to clear the gate. After a clear you can **Talk** with that lord on the victory screen.
- **Shops & residents:** Berry’s counter and quests, Syn’s parlour (marks), Covar’s Cursed Shop (living gear), plus residents like Madame Vex, Pip, Sister Nectar, and the Cartographer.
- **Talk** with Syn, Berry, Covar, and residents (categories: General / Clergy / Residents / Temple). Clergy Talk is victory-only.
- **Content options** (`/options`) — Core themes on by default; Bodies, Kinks, and Fetishes are opt-in. You choose intensity; you do **not** make the bot SFW.
- **Support bonuses** (`/status` → Bonuses): wear this support server’s Discord **tag** for **+5% LP**; **boost** for another **+5% LP**, **10% off all LP prices**, and an **extra Lich's Phylactery** charge per run. Titles: Tagged Devotee / Tower Patron / Beloved of the Tower (revoked if you drop tag or boost). Works in DMs and other servers.

---

## Stack

- Ruby ≥ 3.1
- [discordrb](https://github.com/shardlab/discordrb) — slash commands, buttons, Components V2
- [Sequel](https://github.com/jeremyevans/sequel) — **SQLite** (default) or **Postgres** via `DATABASE_URL`
- dotenv

---

## Setup

```bash
# 1. Dependencies
bundle install

# 2. Secrets
cp .env.example .env
# Set DISCORD_TOKEN and DISCORD_CLIENT_ID (Discord Developer Portal)

# 3. Database
bundle exec rake db:migrate

# 4. Slash commands (once; not on every restart)
bundle exec rake commands:register
# Optional instant guild sync while testing:
# DISCORD_GUILD_ID=your_guild_id bundle exec rake commands:register

# 5. Invite the bot (OAuth2: scopes bot + applications.commands)
# 6. Run
bundle exec ruby bot.rb
```

Invite the bot only into servers that can host **NSFW** play (age-restricted
server and/or NSFW channels). Prefix commands are ignored outside NSFW channels
in a guild; DMs are always allowed.

Useful `.env` knobs (see `.env.example`): `BOT_PREFIX`, `DEVELOPER_ID`,
`BUG_TESTER_IDS`, `ERROR_GUILD_ID` / `ERROR_CHANNEL_ID`, support-server bonus
ids, `DATABASE_URL` for Postgres.

---

## Commands

Slash and prefix share the same handlers. Default prefix is `e,` (`E,` also
works for phones that auto-capitalise).

| Slash | Prefix | What it does |
|-------|--------|--------------|
| `/help` | `e,help` | Paged command list, Tutorial, Support link |
| `/create` · `/start` | `e,create` · `e,start` | Create a delver: body type, submission stance, name |
| `/status` | `e,status` | Sheet, Threat, Burdens, **Bonuses**, Conditions |
| `/explore` | `e,explore` | Next room |
| `/rest` | `e,rest` | Clear lust + full Defiance; 5-minute cooldown |
| `/fight` · `/flee` · `/submit` | `e,fight` · `e,flee` · `e,submit` | Combat (also buttons) |
| `/levelup` | `e,levelup [stat\|level]` | Spend LP on STR / AGI / RES or a level |
| `/curses` | `e,curses` | Syn’s curse ledger |
| `/removecurse` | `e,removecurse [N]` | Purge a curse (**50 LP**) |
| `/suppresscurse` | `e,suppresscurse [N]` | Silence a curse until defeat (**25 LP**) |
| `/shop` | `e,shop [category]` | Shops menu (gear, potions, cursed, quests, parlour) |
| `/buy` · `/sell` | `e,buy` · `e,sell` | Buy / sell by name (living gear cannot be sold) |
| `/equipment` | `e,equipment` | Gear, trophy, inventory |
| `/equip` · `/unequip` | `e,equip` · `e,unequip` | Wear / remove normal gear (one trophy at a time) |
| `/remove` | `e,remove [item]` | Tear off living gear for LP (unlocks Cursed Shop) |
| `/cursedshop` | `e,cursedshop` | Covar’s counter — free reclaim of torn living gear; Talk / bed |
| `/parlour` | `e,parlour` | Syn’s permanent marks |
| `/quests` | `e,quests` | Berry’s quest board (+ Talk to Syn / Berry) |
| `/profile` · `/name` | `e,profile` · `e,name` | Profile / rename / look up by character name |
| `/titles` · `/title` | `e,titles` · `e,title` | Equip titles |
| `/achievements` | `e,achievements` | Achievements by category |
| `/transformation` | `e,transformation` (`e,hybrid`) | Hybrid forms / Chimera fusion |
| `/leaderboard` | `e,leaderboard` | Top delvers |
| `/codex` | `e,codex` | Lore fragments earned in play |
| `/options` | `e,options` | Adult content toggles (+ related menus) |
| `/fetish_options` | `e,fetish_options` | Toggle one theme by key/name |
| — | `e,sluttify [on/off]` | Every theme on or off (prefix only) |
| `/restart` | `e,restart` | New delver + body type (confirm); titles/achievements/progress kept; story quests reset |

`e,dev` (prefix only) is locked to `DEVELOPER_ID` and `BUG_TESTER_IDS`. Run
`e,dev help` for the list.

Buttons belong to the player who opened the panel. Button presses **edit** that
panel; slash/prefix commands send a **new** message. Replies use Discord
**Components V2** (containers + text displays).

### Character creation

1. Pick a **body type**.
2. Choose **Submission** attitude (Eager → Resistant). This trait lasts (not wiped on defeat).
3. Name your delver.

---

## Game mechanics (short)

- **Threat** rises with LP and active curses. Higher Threat = tougher, lustier foes and more monster rooms.
- **LP** — spend on levels, gear, curses, marks, hybrids. Also fuels Threat. Support **tag** / **boost** add +5% each to gains (boost also discounts LP prices).
- **Defiance / Lust** — hits and submission raise lust; climax at 100 drains Defiance. 0 Defiance = defeat.
- **Defeat** — curse, back to floor 1 / level 1; normal gear lost; living gear, LP, curses, marks, titles persist. Cycles reset to 1.
- **Cycles** — clear floor 35 → harder climb, better payouts (~×1.3 per cycle), more curse pressure.
- **Burdens** — up to 3 at floor 1 (+25% LP each). **Oaths** (up to 2, +10% LP) and **rerolls** work mid-climb; reroll price resets on floor 1.
- **Bosses** — every 5 floors; trophy on clear (lost on defeat). Victory **Talk** with that lord.
- **Curses** — from defeat and often from climax / satisfy / wins; manage via `/curses`.
- **Marks, quests, hybrids, admirers, altars, biomes, weekly modifiers, elites** — see `/help` Tutorial for the player-facing tour.

Design lore lives under [`docs/lore/`](docs/lore/README.md). Player-facing changes go in [`CHANGELOG.md`](CHANGELOG.md).

---

## Project layout

```
bot.rb                 # runtime (does not register slash commands)
register_commands.rb   # one-shot slash registrar
CHANGELOG.md
config/                # database, slash definitions
commands/              # Discord command & button handlers
lib/engine/            # game rules, events, conversations
lib/models/            # Player and friends
db/migrations/
docs/lore/             # design bible
webapp/                # standalone browser port (separate changelog)
.env.example
```

Slash commands: `bundle exec rake commands:register` after changing names or
descriptions. Global sync can take up to ~1 hour; set `DISCORD_GUILD_ID` for
instant guild registration while testing.

Errors: console + `logs/errors.log`, and optionally a Discord channel via
`ERROR_GUILD_ID` / `ERROR_CHANNEL_ID`.

---

## Age & content reminder

**18+. NSFW. Explicit.**

This project is adult erotic fiction in game form. By running, inviting, or
playing with this bot you confirm you are an adult and accept graphic sexual
content, including themes many people find extreme. If that is not for you —
or if you are under 18 — **do not use this bot**.
