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

Slash and prefix share the same handlers (prefix defaults to `e,`, and `E,` also works for phones that auto-capitalise):

| Slash | Prefix | What it does |
|-------|--------|--------------|
| `/help` | `e,help` | Paged command list with a Tutorial and a Support server link |
| `/create` · `/start` | `e,create` · `e,start` | Character creation — body type, then Submission attitude |
| `/status` | `e,status` | Character sheet: stats, deepest floor, Threat (curses via `/curses`) |
| `/explore` | `e,explore` | Room roll; monsters open **Fight / Flee / Submit** combat |
| `/rest` | `e,rest` | Clear all lust and fully restore defiance; 5-minute cooldown |
| `/curses` | `e,curses` | List active curses grouped by monster type |
| `/removecurse` | `e,removecurse` · `e,removecurse N` | Purge a curse for **50 LP** (menu or number) |
| `/suppresscurse` | `e,suppresscurse N` | Silence a curse for **25 LP**; it reactivates when you are defeated |
| `/restart` | `e,restart` | New delver + body type (confirm button); titles, achievements, progress, Cursed Shop unlocks, and options are kept |
| `/profile` · `/name` | `e,profile [name]` · `e,name [name]` | Character profile, lifetime stats, rename; look up others by character name |
| `/parlour` | `e,parlour` | Syn & Berry's: Syn's permanent tattoos/piercings (small perks, shown on your profile; also a Profile button) |
| `/quests` | `e,quests` | Berry's quest board: take up to 3 errands at a time for bonus Lust Points |
| `/titles` · `/title` | `e,titles` · `e,title [name\|auto]` | Paged title list with a dropdown to equip |
| `/transformation` | `e,transformation [name\|clear\|fuse A + B]` (`e,hybrid`) | Hybrid forms: unlock progress, switch forms, return to human, or fuse two unlocked forms into a Chimera (100 LP) |
| `/achievements` | `e,achievements [category]` | Achievements by category (combat, submission, exploration, curses, lust, events, challenges) |
| `/leaderboard` | `e,leaderboard [cycles\|depth\|kills\|lp]` | Top delvers (character names only) |
| `/levelup` | `e,levelup [stat\|level]` | Stats cost 5 + current value; a Level costs 80% of all three, raises max defiance, and fully heals |
| `/shop` | `e,shop [category]` | Berry's shop counter: browse by category — buy buttons, Prev/Next pages, and a button through to Berry's quests and Syn's parlour |
| `/cursedshop` | `e,cursedshop` | Free living gear you have previously worn and torn free |
| `/buy` · `/sell` | `e,buy` · `e,sell` | Buy / sell by name (cursed gear cannot be sold) |
| `/equipment` | `e,equipment` | View gear, your trophy, and inventory |
| `/equip` · `/unequip` | `e,equip` · `e,unequip` | Equip / unequip normal gear (one trophy at a time) |
| `/remove` | `e,remove [item]` | Destroy cursed mimic gear for LP (unlocks it in the Cursed Shop) |
| `/options` | `e,options` | Content preferences in four menus (Core on by default; Bodies, Kinks and Fetishes opt-in) plus body sizes |
| `/fetish_options` | `e,fetish_options [option] [on/off]` | Toggle one theme by key or name; no arguments lists all 58 |
| — | `e,sluttify [on/off]` | Turn every theme on or off at once (prefix only) |
| `/fight` · `/flee` · `/submit` | `e,fight` · `e,flee` · `e,submit` | Combat actions (also buttons) |

`e,dev` commands (prefix only, locked to the developer's Discord ID in `DEVELOPER_ID` plus any bug testers listed in `BUG_TESTER_IDS`, comma-separated, both in `.env`) cover stat editing, item/curse grants, debug mode, and boss/cycle skips — `e,dev help` lists them.

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
- **Rest** (`/rest` or button) — clears all lust and fully restores defiance; 5-minute cooldown, blocked in combat and events.
- **Weekly modifiers** — Each week (from Monday) the tower runs one modifier, e.g. Heat Week, Hunting Season (3× elites), Full Moon (more beasts), Mimic Season or Generous Tower. It shows on `/status` with a countdown.
- **Elites** — From floor 3, some monsters spawn with an affix (Rutting, Slick, Towering, Insatiable, Alluring) that buffs them. Beating one pays ×2 LP; satisfying one pays +10 LP.
- **Marks** — Permanent tattoos and piercings from Syn's bench at **Syn & Berry's** (`/parlour`). Each costs LP and gives a small perk; they survive defeat, restarts and cycles. Some designs need a content toggle or body part.
- **Quests** — Berry, who runs the shop counter, posts a quest board of her own at `/quests` (and a button on `/shop` leads there). She offers 3 errands at a time; hold up to 3, progress counts from your lifetime stats the moment you accept, and claiming pays bonus LP (50–150). Quests are repeatable, survive defeat, and completing 10 earns the **Berry's Favourite** achievement (25 for the title). Hidden at Syn's bench in `/parlour` once you wear 5 of her marks is **Syn's Secret**: a one-time five-step plan to surprise Berry with a vow-renewal wedding, ending with the **Fairy Family** title, a sixth mark slot and the masterwork Wedding Mark.
- **Hybrid forms** — 24 forms earned through events and submissions, plus **Chimera fusion** of any two (100 LP; secondary at half strength), **deepening** (3 stages with mutation choices) and **resonance** (kindred monsters are easier to satisfy and gentler). Eros greets hybrids and chimeras by name.
- **Biomes** — Each 5-floor section rolls a weighted biome (12 kinds: Milking Barns, Mirror Gallery, Living Depths, Velvet Kennels, Bell Choir, Glass Menagerie, Drowned Chapel, Honeyed Hive, Clockwork Brothel, Ashen Court, Flooded Grotto, Masquerade Ball), strongly tipped toward the boss waiting at the section's end, tilting monster types and event themes for the whole stretch.
- **Altars & Attention** — Altar rooms let you pray, tithe or offer yourself; devotion fills Eros's **Attention**, and at 100 she visits with a gift, her Favour, a free curse purge, or healing.
- **Admirers** — Satisfy 3 monsters of one type and one becomes your admirer: weaker kin, LP gifts, and jealous sabotage.
- **Cycle burdens** — At floor 1 of a cycle, take up to 3 burdens (LP gains +25% each, up to ×1.75) from `/status`; locked until you clear the tower.
- **Monster types** — Beast, Demon, Slime, Undead, Plant, Mimic (each with roster, color, and assault/submit flavor).
- **Curses** — Defeat always brands you with a curse from the foe's type pool, and the tower can also curse you when you orgasm in combat, satisfy a monster, or win a fight (bosses and elites brand you more often, and every extra cycle raises the odds). New curses are always ones you don't already bear. Effects include lust/damage multipliers, encounter weighting, no-flee/no-death, climax LP, defiance start penalties, and flat STR/AGI/RES. Curses feed Threat, so the more you carry, the stronger and hornier everything gets.
- **Combat** — **Fight** chips monster **HP**. **Flee** (AGI-based). **Submit** / monster hits raise **lust** with assault scenes; climax at 100 costs 20 defiance and leaves you exhausted (STR/AGI -1 for 2 floors) until 10 climaxes in a run make you addicted, after which climaxes buff you instead. Victory grants LP (no automatic floor advance). Defeat applies a curse and resets floor, level, base stats, defiance, and lust. **Non-cursed gear is lost**; living (cursed) mimic gear persists.
- **Bosses** — Every 5th floor, once per gate. Defeating *or satisfying* the boss clears it, grants LP and a trophy, and advances one floor. Bosses are half as easy to satisfy as normal monsters. Only one trophy can be worn at a time, and trophies are lost on defeat. The first time a boss drops below half HP it changes tactics: you pick between **resisting** (costs defiance, deals a heavy blow, but the boss hits harder) or **giving in** (lust, LP and a step of satisfaction, but the boss recovers a little).
- **Stats** — STR: damage. AGI: flee, dodge monster attacks (not while submitting), avoid traps, and slip free of multi-turn events. RES: cuts every lust hit by `100 / (100 + RES × 5)`. Max defiance grows with level: `100 + 10·√(level − 1)`.
- **Explore** — Weighted rooms: monster / trap / treasure / **stairs** (floor+) / empty, plus **random events** (glory hole choices, multi-turn violations, instant traps). Lust traps that hit 100+ also climax.
- **NPC encounters** — Other delvers and characters appear while exploring. Story NPCs (Mira, Lillia, Sister Elara, Marcus, Thomas, Alex) return on deeper floors based on your earlier choices; the Milking Station and Trapped Delvers can repeat. Content toggles and body type shape what appears.
- **Treasure** — Finding a chest gives a choice: **Open it** (LP, a Defiance Tonic, a useful consumable like a Cooling Elixir or Bottled Sanctuary, basic gear, rare gear from floor 8 — and once you own all the chest-only gear, unowned shop gear instead — or **living mimic equipment** that auto-binds and may violate you in combat) or **Leave it** for a small defiance boost (4% of max). Mimics are rolled when the chest appears, and high AGI makes it more likely you spot a tell. No duplicate items. Cursed gear is matched to your `/options` toggles — every piece is themed to a theme you have enabled (there are 24 pieces, from bondage corsets to tentacle vine belts, milking bras and tickle-feather gloves), and the Cursed Shop seals pieces whose theme you have since disabled. If no cursed piece matches your tastes at all, a mimic chest rears up as a **Chest Mimic** to fight instead.
- **Equipment** — Shop / chests / boss trophies, one item per slot (weapon, head, chest, legs, feet, groin, accessory, trophy). Besides STR/AGI/RES, gear can carry damage, lust per hit, lust taken, max defiance, defiance per round, flee, dodge, surprise-hit chance, lifesteal, satisfy chance, trap avoidance, monster-room rate, LP bonuses, and bonuses against specific monster types. The shop also sells Defiance Draughts and Cooling Elixirs. Normal gear is lost on defeat; cursed gear requires `e,remove` + LP to destroy.

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
