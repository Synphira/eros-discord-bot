# Meta — Implementation Notes & Open Questions

Status: living design document. Split from the former monolithic `docs/lore.md` on 2026-10-23. See `README.md` for the full index.

## Future Implementation Notes

These are hooks for later development, not final specifications:

1. ~~Track which bosses have been defeated so their conversation topics unlock individually.~~ Done: topics check the `bosses_seen` record.
2. ~~Add "Ask about..." options for Syn and Berry after the relevant boss has been defeated.~~ Done: Talk buttons on `/quests` and `/parlour` (and the web Quests/Parlour screens) open `Engine::Conversations`.
3. Keep pre-reveal dialogue consistent with Syn and Berry's language rule.
4. Use Syn's conversations to reveal who created particular traps, spells, floors, and systems.
5. Use Berry's conversations to reveal the personal relationships and tensions behind the temple's clergy.
6. Allow boss descriptions, encounters, and floor design to support the contributions attributed to each boss.
7. ~~Decide the temple reveal~~ Decided: after a delver's first return from floor 35, Syn confirms it personally; from the second cycle, clergy drop the pretence with that delver.
8. ~~Consider alternate or expanded conversations after meeting Eros / later cycles~~ Framed: soft continuum depth; Eros+Cycles hints (no soft-apocalypse lecture); Residents Ask-abouts first to build; boss “she sent you back”; category menus.

## Open Questions

- ~~What event reveals that the dungeon is Eros's temple?~~ Decided: the first return from floor 35; Syn confirms it on the second climb.
- ~~Is Berry formally one of the high priestesses?~~ Decided: formally nothing — a devout lay worshipper married to the founder, who knew Syn before the altar.
- ~~Does satisfying a boss unlock the same conversation as defeating them?~~ Decided: same topic either way, but satisfying unlocks extra fairy material.
- ~~Can boss conversations be repeated, and do the fairies remember?~~ Decided: they remember — full first answers, shorter familiar repeats.
- ~~Do the conversations change after the temple reveal?~~ Decided: full revealed variants — Syn speaks as a builder; Berry stays domestic with proper nouns allowed.
- ~~Do later cycles produce different stories?~~ Decided: depth grows with cycles as the delver becomes a regular.
- ~~How much do the bosses know about the fairies' gossip?~~ Decided: they know, and most find it flattering or funny.
- ~~Should meeting Eros change the fairies' conversations about her?~~ Decided: reverence stays, but it becomes shared experience — they compare notes, and Syn speaks of her as a person she serves.
- ~~Are there temple systems whose creators are unassigned?~~ Closed: see Who Made What — every system is attributed.
- ~~What exactly did young Syn find in the ruins~~ Decided: ruined outdoor altar; prior worshippers unknown (stone remembers); they failed by offering love not depravity. Stone now rests before Eros's throne on 35; may wake as First Altar relic. Syn knows it claims her — embarrassed and flattered. Reveal unlocks the story for delvers.
- ~~What does Eros think of Syn?~~ Decided: possessive — Syn is her favourite little fairy slut.
- ~~Residents' personalities and origins?~~ Written: Vex, Pip, Sister Nectar, Cartographer (Fang); see The Residents. Art briefs in `art_reference.md`.
- ~~Wandering NPC personalities?~~ Written: Mira, Lillia, Elara, Marcus, Thomas, Alex, Tobin, Technician, Trapped Delver rules; see Wandering NPCs.
- ~~Relic boss lore?~~ Written: all seven; see Relic Bosses.
- ~~Do the clergy know cycles are a launch?~~ Decided: Syn yes (proud); Lich yes (modelled); Berry told by Syn and stays; others no/half-guess; Drowned Saint hitchhikes. Outside = soft apocalypse, morally ambiguous, timeline fuzzy.
- ~~Domain floor flavour?~~ Written: see Domain flavour (writing bible) under How the Floors Were Assigned.
- ~~Living gear theology?~~ Written: Syn-made = minds; dungeon-grown = feral; took root as pattern-seeds; want = worn; tear vs negotiate = violence vs breakup; Covar breeds/matches/ecosystem; Berry won't wear; Syn's runaway rings.
- ~~What does Eros think of each cleric?~~ Decided: see Theology — Syn possessive; Broodmother amused furniture; Queen tool with taste; King embarrassing; Dryad background comfort; Lich amused at denial; Alpha good-dog; Berry fond (feeds her favourite).
- ~~Hybrids & curses doctrine?~~ Written: land-grown; curse = tower's interest, hybrid = your lust; shelve not erase; chimera = pack/brood plurality; Covar's incubus = his hybrid.
- ~~Syn's in-game parlour arc?~~ Written + future beat outlined: Eros asks public surrender; Syn jokes/quiet/looks at Berry; says no; delver tells Eros; Eros amused; marriage wins.
- ~~Pip's origin?~~ Sealed forever (writers included). Queen knows something unspoken; Syn doesn't care; players never learn; redirect line locked.
- ~~Alpha pack culture?~~ Written: dozens; sapient mates + stock; Alpha absolute; mate = claim not monogamy; satisfied delvers = temporary mates + scent-mark; Berry gets Syn treatment.
- ~~Named pack mates?~~ Written: **Bran** (lieutenant), **Lumen** (den-mother), **Nettle** (favourite pup / family-dumb stock); Syn/Berry Ask-abouts unlock names; art briefs for three, crowd silhouette.
- ~~Voice samples (Residents)?~~ Written: one soft UI-safe signature each — Vex, Pip, Nectar, Fang, Covar, Lacta.
- ~~Voice samples (Clergy)?~~ Written: one soft UI-safe signature each — Broodmother, Queen, King, Dryad, Lich, Alpha.
- ~~Voice samples (Relics)?~~ Written: short UI-safe whispers — Bride, Mirror, Confessional, Chalice, First Altar, Hoardheart; Saint stays mute/pressure.
- ~~Day-in-the-life (Syn)?~~ Written: morning Berry leash → parlour peak (ink + alone soft beat) → wind-down wife duty; cozy+work comedy; delver footnote; 3 ambient lines.
- ~~Day-in-the-life (Berry)?~~ Written: morning dom send-off → shop/quest peak → wind-down leash; cozy+work comedy; delver footnote; 3 ambient lines.
- ~~Day-in-the-life (Covar)?~~ Written: morning nursery → matchmaker peak (Syn sibling spat + alone with Original-on-him) → keeper night; cozy+work comedy; delver footnote; 3 ambient lines.
- ~~Original after restore?~~ Decided: **Covar wears it** at the counter (matches quest Fitting); not left on a stand.
- ~~Day-in-the-life (Nectar)?~~ Written: morning office → holy-dairy peak → vespers; cozy+work comedy; delver footnote; 3 ambient lines.
- ~~Day-in-the-life (Vex)?~~ Written: morning open-room → Listen/dress peak → wind-down; exile + restored variants; cozy+work comedy; delver footnote; 3 ambient lines.
- ~~Day-in-the-life (Fang)?~~ Written: morning map-room → survey peak (Syn tease + Covar almost) → ink wind-down; cozy+work comedy; delver footnote; 3 ambient lines.
- ~~Day-in-the-life (Pip)?~~ Written: morning rounds → maintenance/fangirl peak (Syn + missing Queen note) → sleep in the works; cozy+comedy+fangirl; origin sealed; delver footnote; 3 ambient lines.
- ~~Berry/Syn D/s?~~ Decided: Berry dom / Syn sub; *good girl* = Berry’s command to shush and obey, Syn complies.
- ~~Milking Station Technician's name?~~ **Sister Lacta**; Nectar says it; station UI may stay generic.
- ~~Post-35 / cycle conversation expansions?~~ Framed: soft continuum; Eros+Cycles+Residents topics; Syn hints launch only; boss+fairy “sent you back”; categories; Residents first to implement.
- ~~Marks theology?~~ Written: Syn's craft Eros enjoys; pride keeps them permanent; Berry mandates free removal; cap soft; kink-gate = admit desire; Eros traces = Syn's hand + devotion + flirt.
- ~~How residents settle?~~ Written: soft status; land keeps squatters; remade and/or love a system; Nectar/Covar soft-clergy; exile proves not sacred; player-stay = later fantasy.
- ~~Relic ↔ clergy gossip?~~ Written: see Relic gossip under Relic Bosses.
- ~~Curse catalogue flavour?~~ Written: soft want toward type; removal = scrub fingerprint; formal+slang names; domain stamp via monster; stacks = Attention/Lich/Berry/Syn; mimic not special.
- ~~Monster sapience edges?~~ Written: admirers = crush + domain favour, forget when gone; elites = louder weather; named fights = person+pressure; stock→resident rare if noticed.
- ~~Event bosslets?~~ Written: land improvisations; Confessor = Confessional sibling (+Syn voice remote); False Exit = Queen hinge; Tea = Dryad+Berry; Mirror Duet = vanity twin; Gorgon/Spring = rare sapient stock.
- ~~Strange-rooms Ask-abouts?~~ Written: omnibus topic; met→short / 3+ or fight→deep; Syn tinkerer+Confessor flirt; Berry Tea soft / Confessor+Exit sharp / Gorgon+Spring mom; Syn+Berry line each for all six.
- ~~Soft-favourite dialogue rules?~~ Written: Syn+Berry+Covar+Eros; warmer = domestic crumbs + clearer claim (never > Berry); Berry protective+jealousy jokes; Covar sibling-in-law rib; Eros mark/possessive amusement; hard bounds (no Syn romance past guest-family; no sealed dumps; ≠ resident).
- ~~Berry before (flashbacks)?~~ Written: homebody+strays; estranged family; festival-stall meet; misses nothing; hometown forgotten on purpose; tender only if Syn isn't listening.
- ~~Syn's runaway rings?~~ Written: Syn-made minds; sulk from underfed attention; end at Covar's; Berry wants them stopped + glad they're gone; cameo now, return-quest later.
- ~~Altar theology edges?~~ Written: tithe=Berry / offer=Syn; visit spends Attention down; validate-vs-enjoy kept open; First Altar older channel; hard to offend; fairies rib each other.
- ~~Visit gifts / Favour?~~ Written: Favour = surrender lubricant; LP = well energy; purge = bored of a brand; heal = restore the toy; whim weather; count = possessive + fond.
- ~~Residents Ask-about outline?~~ Checklist written: omnibus first; meet=short / story=deep; reveal variants; story extras; Syn/Berry angle lines locked.
- ~~Clergy relationship grid?~~ Written: private takes under each lord + summary table.
- ~~Syn at the Saint’s glass?~~ Written: curiosity after the seal; resemblance + recognition smile; no words, only want; won’t return (afraid she’d say yes); Syn/Berry/Lich know; delver leaks via Lich/relic gossip.
- ~~Wandering NPC afterlives?~~ Written: cozy corruption + per-character colour; soft home cameos; Mira shrine+staff; Lillia/Elara object echoes; Marcus random-succubus pet; Alex nest regular; see After lives.

## Ideas to Build On Later

This document is a foundation rather than a finished bible. Future additions may include:

- ~~Syn's life before the founding~~ Written: a drifting ink artist, hungry not devout; Berry was an early client who kept feeding her.
- ~~Syn's history during the temple's construction~~ Complete: frame + build chapters for all six (Lich→Dryad→Queen→Broodmother→King→Alpha).
- ~~Berry and Syn's road from client and artist to wives~~ Written: mutual fall; Queen as litmus; lovers after the dreams; Syn's ink proposal → Wedding Mark; Dryad grove first wedding; temple-finished second wedding with full clergy on Dryad floors; Berry dom / Syn sub — *good girl* is Berry’s command, Syn obeys.
- ~~The origin of the monster-spawning spell~~ Written: Syn and the Incubus King's working; his half was a debt paid.
- ~~The creation of the traps~~ Written: Syn and the Succubus Queen's great work, the Dryad inspiring vine and tentacle.
- ~~The relationship between the temple and Eros's altars~~ Decided: clergy-built offering points that Eros genuinely watches through; her Attention is literal regard, and her visits are partial manifestations.
- ~~What the bosses want from delvers who reach them~~ Written: every lord wants to keep them; temple law and the cycles take them onward anyway.
- ~~How the clergy view devoted, transformed, or frequently defeated delvers~~ Written: with no contempt — surrender is the offering, so all three are the temple working.
