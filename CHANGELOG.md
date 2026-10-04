# Changelog

All notable changes to **Endless Ruins of Sin** are recorded here.

Format: newest entries first. Dates use the day the work landed in this repo.

---

## 2026-10-04

### Added

- **New `/help` menu**: commands are split into six pages (Getting Started, Exploring & Combat, Curses, Gear & Shops, Progress, Content Options). Switch pages with a dropdown. A **Tutorial** button explains the basics, and a **Support** button links to the support server. If you press someone else's help menu, you get your own private copy instead of changing theirs.

- **14 new fetish events**, each behind its own toggle and with its own title (at 3 uses) and achievement:
  - **Overstimulation Engine** (Overstimulation): a machine forces two orgasms back to back (costs defiance for both) and leaves you **Oversensitive**
  - **Tickle Trap** (Tickling): imps with feathers; you can try to dash past
  - **Sissy Boutique** (Sissification): lace, lipstick and curtsy lessons, leaving you **Sissified**
  - **Corrupting Font** (Corruption): drink for +3 Corruption, or purge 3 at a defiance cost
  - **Scribe Imps** (Body Writing): filthy words inked on you; you're **Marked** for a few floors (+LP on submit and per hit taken)
  - **Musk Den** (Musk): leaves you **Musk-Drunk**, so beasts hit harder but pay more when you submit
  - **Fire and Ice** (Temperature Play): ice cubes or warm wax, each with its own condition
  - **Colossus Lair** (Size Difference): a huge ogre; leaves you **Stretched**, or fight it
  - **Cum Fountain** (Cum Play): bathe in it, or drink from it if Oral is on
  - **Jeering Gallery** (Degradation): kneel and take the names for **Broken Pride**, or beg for praise and become a **Good Pet**
  - **Pool of Becoming** (Monster Transformation): become part slime, demon or plant for 4 floors, so that type's lust hits you softer and submitting to it pays more
  - **Monster Manor** (Maid Service): serve the house as a **Dutiful Maid** (+LP per floor)
  - **The Stables** (Pony Play): harness, bit and tail, leaving you **Bridled** (+AGI, easier escapes)
  - **Gagmaker's Workshop** (Gags & Hoods): gagged and hooded, so you can't flee next floor but earn more for submitting; or a ring gag if Oral is on
- **Corruption** (opt-in): every time you submit to a monster you gain 1 Corruption (max 20). At 5, 10, 15 and 20 you reach **Tainted**, **Lewd**, **Depraved** and **Fully Corrupted**, each with an explicit line and a stronger condition (more Submission and LP on submit, less Resistance, more lust taken). It shows in `/status` and resets on defeat
- **Degradation** (opt-in) also changes what monsters say after you submit: most of the time you get sneering name-calling instead of praise
- **Cum Play** is a new core toggle (on by default). Turning it off hides creampie, "filled with cum" and cum-dripping lines across the game, along with the Cum Fountain
- `/options` has a fourth menu, **Opt-in fetishes**, for the new toggles (Monster Transformation sits under Opt-in bodies). There are now 57 toggles; `!sluttify` covers them all, so the Depraved One requirement now includes them too
- **111 more random events**: every content toggle now has at least three events of its own (172 random events in total, up from 61). That includes Oral, Vaginal, Anal, Breast Play, Knotting and Breath Play, which had none before. Some examples: a kneeling shrine and a wall of lips (Oral), a hellhound kennel (Knotting), a giantess garden and a hall of hand-sized worshippers (Size Difference), a collector's cabinet of shrunken delvers (Shrinking), a kitten parlour (Petplay) and a frost queen (Temperature Play). Each has its own explicit scenes for your body, rewards and a condition, and many add an alternate choice or a fight. Events tied to a body part (Vaginal, some Breast Play) only appear if you have it
- With the default settings (core themes only), core-theme events now make up most of the random rooms, so the Glory Hole and the original trap rooms come up less often than before
- **Elite monsters**: from floor 3, some monsters spawn as elites (about 1 in 10 by floor 15) with one of five affixes: **Rutting** (hits harder), **Slick** (much harder to hit), **Towering** (more HP and strength), **Insatiable** (harder to satisfy, but pays double when you submit) and **Alluring** (hits harder, easier to satisfy). Beating an elite pays **double LP**, and satisfying one pays **+10 LP**. New achievements: **Elite Hunter** and **Elite Pleaser** (10 each)
- **Weekly tower modifiers**: each week (resetting Monday) the tower runs one modifier that everyone shares, shown on `/status` with a countdown: **Heat Week**, **Hunting Season** (3× elites), **Full Moon** (more beasts, and they hit harder but pay more), **Mimic Season** (richer chests, more mimics), **Temptation Week** (more random events), **Generous Tower** (more LP from victories and exploring), **Slime Tide** and **Spring Bloom**
- **Boss phases**: the first time a boss drops below half HP, the fight pauses with a scene written for that boss and two buttons. **Resist** costs 10% of your defiance and deals a heavy blow (15% of its HP), but the boss hits 20% harder for the rest of the fight. **Give in** gives +20 lust, +10 LP and one step toward satisfying it, but it recovers 10% HP. Other actions wait until you choose
- **`/parlour` (Madame Vex's Parlour)**: buy up to 5 permanent tattoos and piercings with LP (40–60 each), each with a small perk such as +1 agility, +2 LP when you submit, or a better chance to satisfy monsters. Marks are kept through defeat, restarts and new cycles, show on `/profile`, and can be removed for free. Some designs only appear with a content toggle (Exhibitionism, Body Writing, Degradation, Breast Play, Oral, Vaginal) or a matching body part. Also reachable from a **Parlour** button on your profile. New achievements: **Inked** (3 marks) and **Walking Masterpiece** (5). **Operators:** run `bundle exec rake commands:register` to add `/parlour`
- **Treasure chests are now a choice**: when you find a chest you can **Open it** as before, or **Leave it** to resist the temptation and recover a little defiance (4% of your max, at least 3). Opening is still the gamble: a Defiance Tonic restores far more, but the chest might be a mimic. Sharp-eyed delvers sometimes spot a mimic's tell before deciding (more likely with high AGI); there are no false tells. New achievement: **Iron Will** (walk away from 25 chests)
- **18 new shop items**, filling every slot (weapons, chest, legs, feet, head, accessory) with gear that does more than add a point of a stat: surprise-hit chance (Silvered Rapier), defiance drained from your hits (Soul-Draining Blade), bonus damage and less lust from specific monster types (Beastbane Spear, Exorcist's Censer), dodge (Silent Slippers), trap avoidance (Warded Greaves), fewer monster rooms (Hood of the Unseen), less lust taken (Chaste Plate, Sacred Rosary), a chance for monsters to back off (Crown of Defiance), extra LP from victories, rooms and chests (Trophy Hunter's Charm, Wayfinder Boots, Lucky Coin), and a heavy hitter in the Sinbreaker Maul. Prices run from 30 to 160 LP
- **Two new consumables**: **Defiance Draught** (30 LP, restores 40% of max defiance) and **Cooling Elixir** (25 LP, −40 lust)
- **Rare chest finds**: from floor 8, chests that roll gear can hold one of five better pieces not sold in the shop (Old Champion's Sword, Ghostsilk Gloves, Sister's Veil, Delver's Lucky Boots, Moonlit Mail)
- Dev: `!dev elite [affix]` starts a fight with an elite, and `!dev week [key|auto]` shows or overrides the weekly modifier until restart

### Changed

- **Prefix is now `e,` instead of `!`**, so `!explore` becomes `e,explore`. `E,` also works for phones that auto-capitalise, and a space after the comma (`e, explore`) is fine too. All in-game hints, help pages and usage messages show the new prefix. Operators can still override it with `BOT_PREFIX` in `.env`.
- **Existing shop gear buffed**: Enchanted Whip adds +5% surprise-hit chance, Soul-Draining Blade now returns 20% of its damage as defiance, Leather Harness adds −1 lust per hit, Abyssal Plate gives +15 max defiance (was +10), Lust Ward Amulet blocks 3 lust per hit (was 2), and Talisman of Escape gives +25% flee (was +20%)
- **Gear stats read in plain words** in the shop, equipment and Cursed Shop screens (e.g. "+12% surprise-hit chance (double damage)", "−1 lust per hit") instead of internal names
- Gear can now carry the same kinds of bonuses as curses and conditions (surprise hits, dodge, satisfy chance, LP bonuses, trap avoidance, per-monster damage and lust)

### Fixed

- **Combat turns no longer turn into text walls when you're locked or wearing lots of cursed gear**: cursed gear now acts once per turn (after the monster's move) instead of twice. If you orgasm or get denied more than once in the same turn, only the first one plays the full scene and the rest are a single line. Defiance lost, LP gained and lust are exactly the same as before
- **Corruption now shows on the main `/status` page** when the Corruption toggle is on: your stage, your level out of 20 and its current effects. Before, it only appeared in the Conditions view
- **Turning off Oral no longer hides scenes about sitting in someone's lap**: the filter treated the word "lap" as oral. It now only catches licking ("laps at", "lapping")
- **Combat no longer says "the The Tower Lord"** when a monster's name already starts with "The"

## 2026-10-03

### Changed

- **Rewritten event scenes** for the Milking Shrine, Swelling Fountain, Bloating Slime, Egg Chamber, Paddle Golem, Foot Idol and Edging Altar: longer and far more explicit. The Swelling Fountain now has its own scene for each body part it grows, and the Edging Altar describes your actual body (and your chastity, if you're locked)
- **Rewritten fetish event scenes**: all 33 fetish events (Bimbo Transformation, Living Clothing, Beast Taming, Rubber Chamber, Glory Room, Breeding Chamber, Public Shame and the rest) has new, much more explicit text. Lines about breasts, cocks, pussies, wombs and prostates only appear for bodies that have them, and locked parts are still replaced by chastity lines. Rewards, conditions and choices are unchanged
- **Rewritten monster scenes**: the lines you see when a monster gets its hands on you in combat, and when you submit to one, are rewritten and much more explicit for all six monster types (beasts, demons, slimes, undead, plants and mimics), along with the praise after submitting. New scenes include prostate lines for bodies with a cock and two-hole slime scenes for bodies with both. Body-part and chastity filtering work as before
- **Rewritten core event scenes**: the Glory Hole, Tentacle Pit, Dildo Trap, Aphrodisiac Mist, Bonding Vines, Spirit Possession and mirror room (Public Humiliation) are rewritten and much more explicit. Every glory hole choice now plays out to the finish. Hermaphrodites now get both their cock and pussy scenes in the Tentacle Pit, Bonding Vines, Spirit Possession and Dildo Trap instead of only the pussy one. Rewards, lust and turn counts are unchanged
- **Climaxes describe your body**: when your lust boils over, the climax is now explicit and matches your body (your pussy squirting or your cock spurting, harder the further past the limit you went). If you're locked in chastity, you get a ruined orgasm inside your cage or shield instead. Pussy lines respect the Vaginal content toggle
- **Bosses have their own scenes**: the Mimic Broodmother, Succubus Queen, Incubus King, Ancient Treant, Lich Lord, Alpha Beast and Tower Lord no longer borrow ordinary monster lines. Each has its own explicit scenes for when it gets its hands on you and when you submit, with reactions as you build satisfaction (or fail to impress it), its own climax when fully satisfied, and a line when you beat it in a fight. Boss introductions and special-ability messages (the Queen's gaze, the King's command, the Alpha's rut and so on) are rewritten too. Stats, rewards and abilities are unchanged
- **Explicit combat moments**: fighting back now describes you resisting: shoving a beast's snout away from your thighs, hacking through vines curling between your legs, gritting your teeth against a demon's promises and striking it. Beating a monster or boss is written as you fighting off the tower's pull. Dodging, escaping, getting dragged back when an escape fails, a monster cumming when it's satisfied, beating a monster, being broken by pleasure and being defeated all have their own explicit lines too. All numbers are unchanged
- **Climaxes are now orgasms**: every message, achievement, title description and profile stat says "orgasm" instead of "climax" (the aftermath buff is now **Orgasm High**). The orgasm itself matches your genitals: your cock spurting cum, your pussy squirting, or both going off together if you have both. Locked parts get a ruined orgasm inside the cage or shield instead. Achievement progress and stats carry over untouched
- **Cursed gear no longer floods the log**: when several pieces of living gear act at once, you get one line naming them all with the combined lust, one explicit scene from one of them, and a short line for the rest joining in, instead of three lines per item. A single piece triggering now takes two lines instead of three. Lust gained is unchanged

### Fixed

- **`!dev npc <id>` no longer repeats the first scene**: without a stage number it now continues from your progress with that NPC (so testing Mira walks through stages 1, 2 and 3 based on your choices) and restarts the story once it's finished. It also tells you which stage you're on

### Added

- **NPC encounters**: other delvers and strange characters now turn up while exploring (roughly 1 room in 20 when someone is around). Each one offers choices with their own scenes, rewards, conditions, and sometimes a fight
  - **Story NPCs** you can meet again deeper in the tower, depending on what you chose last time. Unfinished story progress is kept through defeats and `/restart`:
    - **Mira** (floors 8–27, needs Lactation): a delver turning into a HuCow. Help her and her milk eventually grants **Mira's Blessing**; refuse her too often and she attacks
    - **Lillia** (floors 3–14, needs Bimbofication): an adventurer being reshaped by living armour. Push her in and you fight her as a Living Doll
    - **Sister Elara** (floors 10–23, needs Latex & Rubber): a priestess swallowed by latex. Letting her change you **unlocks the Latexdoll hybrid form**
    - **Marcus** (floors 9–12): a man desperate for a succubus. Fund him, travel with him for a **Charming Amulet** (+1 Submission, +1 AGI), or charm him if you're a Succubus or Incubus
    - **Thomas** (floors 16–20): a delver drowning in living gear he can't afford to remove
    - **Alex** (floors 21–35): a newbie who slowly falls in love with the tower's traps
  - **Repeatable encounters**: the **Milking Station** (floors 15–25, needs Lactation; four milks with different effects, or be milked yourself if you have breasts) and **Trapped Delvers** (floors 4–25: the stocks, a glory hole wall, a mirror gazer, and a mimic chest victim)
  - Scenes follow your body (what you have, and what your chastity locks away). "Walk away" leaves a story NPC's path open for later; refusing them outright usually ends it
- Dev: `!dev npc <id> [stage]` starts any NPC encounter, and `!dev npc reset` wipes your NPC progress
- **NPC storylines can be replayed**: once a story reaches an ending (good, bad, or a fight), the encounter tells you it's over for this run. It starts fresh on your next run: after a defeat, a `/restart`, or clearing a cycle. Stories you haven't finished keep their progress. How many times you've finished each story is tracked for the future

---

## 2026-10-02

### Fixed

- When the bot is slow to answer a button, menu or slash command (Discord allows 3 seconds), the panel is now posted as a new message instead of failing with an "Unknown interaction" error
- The glory hole no longer silently drops the **Vagina** option when you're in chastity: it now shows a greyed-out **Vagina 🔒** button so it's clear your chastity is what's blocking it

### Added

- **`/rest`** and **`!rest`**: clears all lust and fully restores defiance, then has a **5-minute cooldown** (the reply shows when you can rest again). The Rest button does the same. It can't be used during combat or an unanswered event
- **Depraved One** title and achievement (+1000 LP): clear the Tower Lord **7 times with every content theme enabled**. Clears only count if all 43 themes are on at the moment of the win
- **Submission screen after a defeat**: the defeat message now has a **Continue** button that leads to a **Submission** screen, with a **Try again** button that starts exploring again
- The level-up screen now has an **Explore** button so you can get back to the dungeon straight away
- **Two cursed weapons** can now turn up in mimic chests. Like other living gear, they bind to you and cost LP to remove
  - **Dagger of Aching Desire** (+6 damage, -1 lust resist): every hit steals **3 LP** from the monster. 25% of hits flood you with heat instead (+15 lust and **Overwhelming Arousal**, lust taken ×1.15 for 2 floors)
  - **Whip of Will-Breaking** (+4 damage, +1 Submission): every hit makes the monster **+15% easier to satisfy** for the rest of the fight (up to +45%). 30% of hits lash you back with **Submissive Urge** (Submission +2, STR -1, flee -15% for 2 floors)
- **Hybrid form buffs and special abilities**: every form now gives a real combat buff, and most also have a special ability that can trigger during fights. Both are listed on `/transformation`. Some examples:
  - Kitten: +20% dodge and +10% satisfy chance. Puppy: 25% less lust taken and +15% LP from submitting
  - Imp: 15% chance for a double-damage surprise attack. Vampire: heals 25% of the damage you deal. Dryad: heals 5 defiance at the start of each fight. Alraune: +15% trap avoidance
  - Specials include stunning the monster for a turn (Harpy, Incubus, Imp, Living Doll, Furniture, Latexdoll), absorbing defiance (Slimekin), stealing LP (Succubus), making the monster hurt itself (Vampire), draining it (Ghost), crushing it (Rubberslime), and Angel's **Divine Intervention**, which can save you when your defiance is low
- **Climaxes rewritten**: each climax now has its own description, which gets more intense the further past 100 your lust went. Afterwards, **Afterglow Exhaustion** gives STR -1 and AGI -1 for 2 floors
  - **Orgasm Addict**: after 10 climaxes in one run you become addicted until your next defeat, and climaxes give **Climax High** instead (STR +1, satisfy +5%, +2 LP on submit for 2 floors). Denied climaxes from chastity don't count
- **6 hidden Lust achievements** that only appear once earned: First Release, Frequent Flyer, Release Addict, Climax Master, Overwhelming Pleasure, and Denial Tolerant
- **Chastity denial achievements**: **Frustrated** (5 denied climaxes, +20 LP), **Desperate** (10, +40 LP) and **Broken by Denial** (25, +80 LP), plus the **Eternally Denied** title at 25. They need the Chastity theme enabled
- `/status` shows a 🔒 line describing your chastity while you're locked, and fetish events remind you that you're caged before you choose

### Changed

- **30 fetish events have richer, longer scenes**, and some have new settings (for example, the Giant's Chamber now has purple crystals, the Shrinking Chamber has spore mushrooms, and the Viewing Chamber has a one-way window). Rewards and conditions are unchanged. The Bestial Pool now tells you which animal you take after
- **Hybrid forms no longer change which events and monsters you meet**, except HuCow and Furniture (which keep their event bonuses) and Angel (which keeps fewer monster rooms and more random events). Angel no longer gives +20% to every event type. HuCow now gets 20% more LP from milking and lactation events

- **`/equipment` is split into two views** with **Equipped** and **Inventory** buttons. The inventory has a dropdown to pick a slot (weapon, head, chest, and so on) and only lists that slot's items, so the message stays short with a large inventory
- **Growing and shrinking conditions replace each other**: gaining Pocket-Sized removes Towering and the reverse, so you can't have both at once. The event message says which one faded
- **Mimic Seedbed** now also counts **satisfying** the Mimic Broodmother by submitting while wearing 5 cursed items, not just defeating it
- Defeat messages no longer say "Your run ends here"; the Submission screen follows instead
- **Chastity-aware scenes**: while you wear the Chastity Belt or have Locked Tight, monsters, living gear, traps, fetish events and other events no longer touch your locked-away parts. They tease, grind and lick at the cage instead, or use your other holes. The glory hole hides the "take them that way" option while you're locked, and egg/milking/edging/tentacle/vine/spirit/mist scenes have their own caged versions
- **Denied climaxes react differently**: the text depends on what's locking you (the steel belt or Locked Tight's runes), your lust stays at the edge (95), and each denial now gives **+3 LP** on top of the usual 6-defiance cost
- **Chastity makes you more sensitive**: monsters' lust damage is **+50%** in the Chastity Belt and **+40%** under Locked Tight
- **`/status` no longer lists conditions directly**: a **Conditions (n)** button switches to a conditions view (with your chastity state), and **Back to Status** switches back
- Taking the stairs now shows **Deepest reached** as cycle and floor (e.g. "Cycle 2 · Floor 12"), the same record shown on `/profile`

### Operators

- Run **`bundle exec rake commands:register`** to add `/rest` (31 commands), then restart the bot. No new migration is needed. The chastity changes only need a restart

---

## 2026-09-30

### Added

- **Hybrid transformations**: 17 permanent forms you unlock like titles and switch between with **`/transformation`** or **`!transformation [name|clear]`** (aliases `!hybrid`, `!transform`). Your active form shows as **Hybrid: X** on `/status` and `/profile`. The profile counts how many forms you've unlocked, and the nav has a new **Hybrids** button
  - Forms: **Kitten**, **Puppy** (same unlock and effects as Kitten), **HuCow**, Harpy, Slimekin, Succubus, Incubus, Imp, Dryad, Alraune, Living Doll, Furniture, Vampire, Ghost, Latexdoll, Rubberslime, and **Angel**
  - Most forms unlock by accepting fetish events and submitting to monster types (for example, Kitten needs 5 petplay events and 10 beast submissions). Each form makes its favourite event themes and monster types more likely while it's active
  - **Angel** unlocks with the **Pure** title: 30% fewer monster rooms, 35% more random events, and +20% weight on every event type
  - Forms whose requirements use a content theme you turned off stay hidden until you enable it. Forms survive defeat and `/restart`

- **33 fetish choice events**, each with **Accept** / **Decline** buttons (some add **Fight**, and the Strap-On Chamber adds **Receive**). Accepting pays LP + lust and usually applies a temporary **condition**. Events: Bimbo Transformation, Inflation Trap, Living Clothing, Beast Taming, Rubber Chamber, Oviposition Chamber, Chastity Trap, Hypnotic Mist, Glory Room, Observation Deck, Giant's Chamber, Shrinking Chamber, Futa Fountain, Living Furniture, Mirror of Change, Milking Chamber, Breeding Chamber, Nectar Fountain, Golden Chamber, Binding Room, Discipline Room, Public Shame, Whispering Chamber, Sensory Void, Auction Block, Strap-On Chamber, Glory Booth, Foot Worship Chamber, Orgy Room, Public Chamber, Viewing Chamber, Feasting Chamber, Bestial Pool
  - **Fight** turns the event into a normal combat against a matching monster type
  - Trap-style events (Inflation Trap, Chastity Trap, Hypnotic Mist, Binding Room, Whispering Chamber) roll **AGI** when you decline; failing means you get caught anyway
- **Conditions** — timed buffs and debuffs that last 2–4 floors, shown on `/status` and cleared on defeat. Examples: Bimbo Brain (more submission and submit LP, less RES), Entranced (can't flee), Pocket-Sized (more AGI and dodge), Owned (extra submit LP, worse flee). Futa Fountain and Mirror of Change temporarily add or swap body parts
- **New living gear** that only binds through events: Living Bodysuit, Living Stockings, Living Gloves, and the **Chastity Belt** (in its own slot; climaxes are **denied** while worn, so lust stays at 95 and each denial costs 6 defiance). All four can be unlocked in the Cursed Shop
- **Content options expanded to 43 themes** in three menus: Core (12, on by default), Bodies (14, opt-in), and Kinks (17, opt-in). New themes include bimbofication, futanari, gender bending, giant growth, shrinking, weight gain, furry, latex, living clothing, breeding, petplay, hypnosis, mindbreak, sensory deprivation, objectification, humiliation, slavery, voyeurism, group sex, bukkake, facials, strap-ons, and watersports
- **`!sluttify [on/off]`** (prefix only): turns all 43 content themes on or off at once. With no argument it turns everything on, or turns everything off if it's already all on
- **`!fetish_options <option> <on/off>`** (alias `!fetish`, plus `/fetish_options`) — toggle one theme by key or name; with no arguments it lists every theme
- **33 fetish titles** (e.g. Bimbo, Living Balloon, Good Pet, Broodmother, Chaste Slave, Beastkin) and **35 achievements** in a new **Kinks** category, including Kink Explorer and Connoisseur of Sin for accepting 25 or 100 fetish events. Titles and achievements for disabled themes are hidden unless you have already earned them
- Dev: `!dev event <key|list>` forces any event; `!dev conditions [clear]` shows or clears conditions
- **Staff titles**: **Sin Sculptor** for the developer and **Climax Checker** for bug testers (anyone in `BUG_TESTER_IDS`). They are awarded automatically, shown by default when no title is picked, and hidden from everyone else
- **Curse suppression**: `/suppresscurse` (`!suppresscurse N`, alias `!suppress`), or the new **Suppress** menu in `/removecurse`. For **25 LP**, half the removal price, a curse stops working until your next defeat, then it reactivates (the defeat message lists which ones). Suppressed curses show struck through in the curse list
- **Bug testers** can now use `!dev` commands and debug mode. List their Discord IDs, comma-separated, in **`BUG_TESTER_IDS`** in `.env`, then restart the bot

### Changed

- **Threat rebalanced** so it no longer hits 100% after one boss's LP. Holding LP now adds threat with diminishing returns, at most 60%, and the LP needed grows with your level: about 15% at 100 LP and 50% at 600 LP on level 1. Each active curse adds 8% (was 15%), capped at 40%; suppressed curses don't count
- The `/removecurse` panel now uses two dropdowns (**Remove** for 50 LP, **Suppress** for 25 LP) instead of one button per curse, so it stays within Discord's limits with many curses
- **Submitting to a boss is now a gamble instead of a one-turn win.** You need **3 successful submits** in the same fight; each has the normal satisfy chance (20% + 10% per Submission, up to 80%). The boss keeps attacking between submits and you can't dodge, so you may climax or break first. Satisfying a boss pays **×1.75 of the boss LP reward**. Progress shows as "satisfaction 1/3" and the boss intro explains the rules
- The Chastity Mimic event was replaced by the new **Chastity Trap** choice event
- Older events now count toward the matching new titles: Milking Shrine (milked and lactation), Swelling Fountain (giant growth), Bloating Slime (inflation), Egg Chamber (oviposition), Paddle Golem (discipline), Foot Idol (feet), Edging Altar (chastity), Bonding Vines (bondage), and Public Humiliation (exhibitionism)
- Submission can now be raised or lowered by curses and conditions, not just gear
- `/status` is now focused on the current run. The deepest-floor line moved out (it's still on `/profile`), and a **Body** line shows your current sizes for the parts your body has, including temporary ones from conditions like Futa Blessing
- The `/status` footer now says that trophies and conditions are lost on defeat

### Fixed

- **Conditions never wore off:** the floor countdown wasn't being saved, so event conditions (Bimbo Brain, Futa Blessing, Mirror-Changed, etc.) lasted until defeat. They now expire after their listed number of floors, and the stairs or boss-clear message says which ones wore off. Clearing the Tower Lord also counts as a floor passed
- Busy combat turns (several cursed-gear triggers, boss specials, praise) could exceed Discord's 40-component limit, so the Fight/Submit button did nothing. The action log now merges scene blocks and trims text to stay within Discord's limits

### Operators
- **Bot status** now reads **"Playing with X users in Y towers."** (total members across all servers, and number of servers). It refreshes right away when the bot joins or leaves a server, and every 2 minutes using fresh member counts from Discord (`PRESENCE_REFRESH_SECONDS` to change). For instant updates on member joins and leaves, enable **Server Members Intent** in the Developer Portal, then set `SERVER_MEMBERS_INTENT=true` in `.env`
- **Errors post to Discord**: each error report is also sent to the channel in **`ERROR_CHANNEL_ID`** (it must be in the server in `ERROR_GUILD_ID`, both in `.env`). Posts never ping anyone, and the same error repeating within a minute posts once, with a repeat count on the next post
- The developer's Discord ID now lives in **`DEVELOPER_ID`** in `.env` instead of the code. If it's missing or invalid, nobody gets owner access; bug testers in `BUG_TESTER_IDS` keep theirs
- **Clearer error logs**: each error now prints one block with what failed, which command or button triggered it and who pressed it, where in the bot's code it broke, and a plain-English hint for common Discord errors (component limit, expired interaction, missing permissions, database). Library frames are hidden, and full traces go to `logs/errors.log`
- Run **`bundle exec rake db:migrate`** (migration 017 adds hybrid forms) and **`bundle exec rake commands:register`** for `/transformation`. Developers get `!dev hybrid <key|all|none>`
- Run **`bundle exec rake db:migrate`** (migration 016 adds `players.conditions`), then **`bundle exec rake commands:register`** (adds `/fetish_options`, `/suppresscurse`, and the Kinks achievement category), then restart the bot

---

## 2026-09-29

### Added

- **`/options`** (`!options`) — content preferences and body sizes
  - **Core themes** (on by default): oral, vaginal, anal, breast play, knotting, tentacles, bondage, breath play, exhibitionism, aphrodisiacs, possession, toys. Scenes touching a disabled theme are re-rolled or replaced with a softer line; glory hole choices and matching events are hidden
  - **Opt-in themes** (off by default), each adding a new random event: lactation (Milking Shrine), body growth (Swelling Fountain), inflation (Bloating Slime), oviposition (Egg Chamber), spanking (Paddle Golem), orgasm denial (Edging Altar, multi-turn), feet (Foot Idol), chastity (Chastity Mimic)
  - **Body sizes** — penis small/average/large, breasts small/medium/large, butt small/medium/large/huge (only parts your body has). The Swelling Fountain grows one step at a time and never past the largest size
- **Cursed Shop** (`/cursedshop`, or the **Cursed** tab in `/shop`) — any living item you have worn and torn free with `/remove` can be taken again for free
- **Monster praise** — after you submit, the monster adds a line of praise that fits its type
- **AGI now does more:**
  - Dodge monster attacks while fighting or fleeing: 10% + 2% per AGI above half the foe's AGI, from 5% to 50%. No dodging while submitting
  - Sidestep trap rooms and the Dildo Trap: 10% + 2% per AGI, 10–60%
  - Wriggle free of multi-turn events early: 5% + 2% per AGI each turn, 5–40%
- **New titles:** Succubus Bane, Succubus's Pet, Incubus Bane, Incubus's Plaything, Royal Consort
- **New achievements:** Succubus Hunter / Charmed, Incubus Hunter / Charmed, Throne Warmer (satisfy 3 bosses), Royal Court, Light on Your Feet (avoid 10 traps), Escape Artist, Mimic Tamer
- **Slash versions of every player command:** `/fight`, `/flee`, `/submit`, `/shop`, `/buy`, `/sell`, `/equipment`, `/equip`, `/unequip`, `/remove`, `/name`, `/title`, `/options`, `/cursedshop`. `/levelup`, `/removecurse`, `/profile`, `/achievements` and `/leaderboard` gained optional arguments
- **Developer commands** (`!dev …`) — prefix only and locked to the developer's Discord ID; nobody else gets any response. They cover editing stats, LP, floor and cycle; granting or removing curses, items, titles and achievements; a **debug mode** (one-hit kills, monsters never act, guaranteed flee and satisfy, traps avoided); instantly winning a fight; and jumping to the next boss, the final boss, or a cycle clear

### Changed

- **Leveling rebalance**
  - A stat now costs **5 + its current value** in LP (STR 5 → 10 LP, STR 15 → 20 LP), so dumping everything into STR gets steadily pricier
  - **Level Up** costs 80% of all three stats combined. It gives +1 to every stat, raises **max defiance** (`100 + 10·√(level − 1)`), and **fully restores defiance**
  - **RES** now cuts lust from every hit by a percentage, `100 / (100 + RES × 5)` (RES 5 ≈ −20%, RES 20 = −50%), instead of a flat amount
- **Boss trophies:** you can wear only **one at a time** (swap with `/equip`), and they are **lost on defeat** like other non-cursed gear. Existing players keep one equipped trophy; any others move to the pack
- **`/titles`** is paged (8 per page), with a dropdown to equip any earned title on the page (or Auto)
- **`/achievements`** is split into categories (Combat, Submission, Exploration, Curses, Lust, Events, Challenges), with pages
- **Pure** now needs 30 floors cleared **in a single run** without submitting; the count resets when you are defeated, so one early submission no longer locks you out
- **`/restart`** keeps your titles, achievements, all progress counters, deepest floor, Cursed Shop unlocks and content options
- Cursed chest items you **don't own yet are 10× likelier** to appear than ones you already wear
- Monster attack and event text reworded to be less harsh (for example, "sexually assaults you" and "violation" are gone)

### Fixed

- **Submitting to a boss no longer loops the fight:** a satisfied boss now counts as cleared and moves you to the next floor, and a satisfied Tower Lord clears the cycle. This closes the infinite-LP farm. Bosses are half as easy to satisfy as normal monsters
- Getting broken by climax during your own **Fight** action now ends the fight properly

### Operators

- Run `bundle exec rake db:migrate` (migration **015**: preferences, body sizes, legacy progress, one trophy per player), then `bundle exec rake commands:register` (27 slash commands), then restart the bot

## 2026-09-28

### Added

- **The Tower Lord** — 7th and final boss on **Floor 35** (Archdemon; blocks fleeing, floods you with lust, enrages below 30% HP). Players already deeper than 35 face it on their next explore
- **Cycles (New Game+)** — defeating the Tower Lord awards **500 LP × cycle**, returns you to Floor 1 of the next cycle, and keeps your level, stats, LP, and all gear
  - Cycle 2+ monsters and bosses get **+20% base stats per cycle**, and monster / boss LP rewards scale the same way
  - Any defeat returns you to **Cycle 1**
- **Character names** — chosen in a pop-up after picking Submission during `/create`; unique (case-insensitive), 2–24 characters. Existing delvers can set one with `/profile` → **Rename** or `!name Your Name`
- **Titles** (10) and **Achievements** (10) with LP rewards, unlocked automatically after fights and explores; progress shown for locked entries. Pick a displayed title with buttons in `/titles` or `!title <name|auto>`
- Lifetime stats: floors cleared, monsters / bosses defeated, LP earned, submissions, chests opened, curses acquired, cycles completed, deepest point reached
- **`/profile`** (`!profile [character name]` to look up others), **`/titles`**, **`/achievements`**, **`/leaderboard`** (`!leaderboard cycles|depth|kills|lp`) — leaderboards list **character names only**, never Discord usernames; unnamed delvers are hidden
- Migration `014_add_profiles_and_cycles`. **Run `bundle exec rake commands:register`** for the new slash commands
- **12 more titles** — Beast Breeder, Demon Consort, Slime Vessel, Undead Paramour, Plant Pollinated (15 submissions to that type), Mimic Seedbed, Pure (30 floors cleared with zero submissions ever), Broken, Lust Addict, Pit Survivor, Glory Hole Veteran, Trap Expert
- **14 more achievements** — per-type submission goals, **Mimic Seedbed** (slay the Mimic Broodmother while wearing 5+ living cursed items, +500 LP), Pit Veteran, Glory Hole Regular, Trap Expert, Dildo Collector, No Escape (reach floor 20 in one run without trying to flee), Monster Friend, Curse Addict (10 curses at once), Survival Expert (20 climaxes without breaking)
- New lifetime stats behind them: submissions per monster type, tentacle pits survived, glory hole uses (ignoring doesn't count), traps triggered (trap rooms + dildo traps), flee attempts (lifetime and per run), peak simultaneous curses, climaxes survived

### Changed

- `/status` shows your character name and title at the top, then just your body type (Male, Male (FtM), Female, Female (MtF), Hermaphrodite) — the body-part list is gone; also shows **Cycle** and floor out of 35
- Refunds and item sales no longer count toward "LP earned"

### Fixed

- `/leaderboard` (and its button) failed to open — the Cycles tab and the Leaderboard nav button shared a button ID

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
