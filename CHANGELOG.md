# Changelog

All notable changes to **Endless Ruins of Sin** are recorded here.

Format: newest entries first. Dates use the day the work landed in this repo.

---

## 2026-10-23

### Added

- **Character bible (design docs):** Saint’s glass; NPC afterlives; pack faces; voice samples; **day-in-the-life** for Syn, Berry, Covar, Nectar, Vex, Fang, and Pip; **Berry dom / Syn sub** locked in `docs/lore.md` / `docs/art_reference.md`.

### Changed

- **Lore bible reorganised:** monolithic `docs/lore.md` split into [`docs/lore/`](docs/lore/README.md) by category (overview, clergy, Syn & Berry, temple systems, conversations, residents, wandering NPCs, relics, meta). `docs/lore.md` is now an index pointer.
- **Lore / art:** after **Restore the Dress**, Covar **wears the Original** at the counter (bible aligned with the Fitting) — not kept on a stand.
- **Lore:** **strange rooms** Ask-about beats locked — omnibus topic; Syn/Berry shorts for Confessor, False Exit, Tea, Mirror Duet, Gorgon Matron, Spring Keeper.
- **Lore:** **soft-favourite dialogue rules** locked — Syn/Berry/Covar/Eros registers after the wedding quest; guest-family warmth with hard bounds (never outranks Berry; no sealed lore dumps; ≠ resident ending).

## 2026-10-22

### Added

- **Character bible deepened (design docs):** build chapters + clergy grid; **Eros-asks-Syn beat** outlined (public surrender ask; Syn refuses; delver delivers no; Eros amused; marriage wins) in `docs/lore.md` / `docs/art_reference.md`.
- **Appearance: your threat is how you look now.** Threat is no longer just your LP and curses — what you wear is a first-class author of it. Every piece of gear carries an **Appearance** reading (Madame Vex's clothes and anything living carry a lot; Berry's chaste steel and hoods carry less than none), and the threat meter doubles as the tower's appearance meter: **Presentable → Provocative → Depraved**. A full revealing outfit on an empty purse already reads Provocative; dressing down pulls you back. Your reading stands beside your gear on the equipment menu.
- **Madame Vex sells clothes now**: a rack beside her bench (9 pieces: harnesses, collars, silks, heels, a certain habit) — cut to be *read* in. They occupy your normal gear slots, raise your Appearance and threat, and pay for submissive play: monsters are easier to satisfy, submitting pays better, and your lust runs hotter in them. She sells the basic rack whenever she is receiving, and the stock doubles after her restoration — the new room has a proper rack. While she is exiled, the rack stands under the sheet with everything else.
- **The tower reacts to how you look.** At Provocative and Depraved: monsters remark on you when they find you and come easier to satisfy (and hit harder — a higher threat is a higher threat), the lustier kinds (demons, slime, beasts) find you more often, admirers are courted halfway by the outfit alone, everything you earn pays 5–10% more LP, Berry quietly knocks 5–10% off her prices "for the view", the clergy notice you before you speak (their greetings change with your look, as do the Residents'), and every boss appraises you before the fight. Living gear reads heavily too: each cursed piece worn adds a large chunk of Appearance.
- **Saved outfits**: the equipment menu gains an **Outfits** button — save what you are wearing into one of 3 slots and load it back on the fly. If living gear is in the way, the slot lists exactly what loading will tear off and what it costs in cursed removal (destroyed as usual) before you commit; if you can't pay, it refuses and names the price. Your trophy is never part of an outfit.
- **Every stitch reads now**: all non-cursed gear has been through the appearance audit — whips, crops, harnesses, and chaps read as you'd expect; crowns and trophies display; modest padded steel reads *less* than bare skin. And holy gear reads loudest of all: the Sacred Rosary, the Exorcist's Censer, the Sister's Veil, veils and altar relics — the tower reads devotion as an invitation, and it would love to break a nun.
- **Vex's rack doubles again — and outfits now keep secrets**: twelve more pieces join Madame Vex's counter (a naughty nurse, a tower maid, a fallen nun, and a velvet bunny walk into her shop…). Wearing **every piece of a matching outfit** wakes a hidden set bonus — the nurse's *Bedside Manner* knits defiance back mid-fight, a full harness of Berry's new **Knight of the Tower** plate grants +15 max defiance, *Broken Vows* pays the fallen nun for submitting, and at least one set was hiding in plain sight across two different shops all along. Sets are written on no label: dress the part completely, and your equipment menu will name what woke up.
- **A signature only one delver can wear**: a developer-only set and weapon exist in the tower now — Syn's own look, made gear in six pieces: the smudged tiara, lace scraps, a garter of ink vials, smoked-glass wings, impossibly tall belled heels that announce every step, and a tower-script thong that labels its wearer as claimed property — plus **Syn's Cursed Ink Needle**, whose marked monsters come away strangely willing. Stocked nowhere, dropped nowhere; the pieces stir, recognise anyone who is not their maker, and refuse to be worn. Worn together, *Hand of the Maker* wakes.

### Changed

- **Threat rebalanced around the wardrobe**: LP's contribution to threat now caps lower (45% instead of 60%), so a fat purse alone no longer makes you the tower's top priority — what you wear can matter more than what you hold. Curses still weigh in, and worn Appearance (up to 40%) stands beside them. The status screen's threat line now shows the Appearance contribution.
- **The bot keeps to NSFW channels in servers**: inside a server, commands and panels now only answer in NSFW channels — prefix commands are ignored silently elsewhere, and slash commands/buttons get a private note pointing at NSFW channels (or DMs). Direct messages are unaffected: the tower answers there as always.
- **Prefix commands work in DMs now**: `e,explore`, `e,buy`, and every other `e,` command respond in direct messages with the bot, not just in server channels.
- **Shop browsing loops properly now**: Syn's Parlour and Berry's Quest Board both carry an **All Shops** button back to the main shop menu, like Covar's counter and the Residents already did — no more dead ends while wandering the counters.

### Fixed

- **`e,buy` works again**: buying by name silently failed for every item — potions included (the Becoming draughts, tonics, and elixirs). The shop buttons were unaffected. An exact name now also wins over a partial match, so `e,buy draught` can't hand you the wrong bottle.
- **The Pale Cartographer's sketches are exact now**: the three rooms he draws are the rooms you meet, in order. Altars, wandering souls, and tower events no longer step in front of a sketched room (a boss floor, a bottled sanctuary, and the tower's guaranteed stairs still take precedence — without consuming the sketch), a sketched descent can no longer dissolve into an empty room if your threat shifted after he drew it, and he has stopped hedging: no more "Probably."
- **NSFW gate now honours age-restricted servers**: in a server Discord has age-restricted as a whole, every channel counts as NSFW even though each channel's own toggle reads off — the bot answers there again. Threads and forum posts also count when their parent channel is marked NSFW (Discord doesn't flag the thread itself). Blocked attempts now leave a `[channel-gate]` line in the bot console naming the channel type and flags, for diagnosing any channel shape that still misreads.

## 2026-10-21

### Added

- **Three new monsters prowl the tower** (the pool grows to 126): the **Basilisk** (beast) is met eyes-first — avert yours and fight with your hits landing a quarter softer, or meet her gaze on a Resistance gamble and risk her taking a free turn of lust inside your head before the fight begins. The **Marionette Mistress** (demon) opens every fight with her strings already around you: your first attack or submission is spent sawing free while she takes her turn. The **Champagne Slime** goes out like a cork when defeated — a fountain of bonus LP (10 + floor) — and if she beats you, you are the toast: a closing scene and a little of Eros's Attention, because she is, regrettably, delicious. And the **Door Mimic** gets its moment at last: it reveals itself as the room's exit, and for the rest of that floor your empty rooms check their doors twice. Professionally.
- **The writing breathes**: admirers no longer share one goodbye — each monster kind leaves in its own voice (a beast leaves its scent like a signature; a slime, a damp handprint; the undead simply stop keeping pace), two variants apiece. Satisfying a boss now ends in a proper closing scene for all seven lords, Eros included: the Queen does not dismiss you, the Lich Lord relearns warmth letter by letter, and the goddess returns satisfied clears herself. Covar's bed gains relationship milestones at 1, 5, 10, and 25 trysts (shown next time you visit). And Eros's Attention visits rotate their arrivals — two ways for each of her gifts to land, plus a reserved variant for delvers at 50+ corruption, whose finish she inspects like her own later work.
- **The Residents keep hours now**: the Shops menu gains **The Residents**, a door to the tower's settled souls — also reachable with `e,residents`. **Madame Vex, the Listener** (in Covar's back room) will **negotiate a worn living piece off you intact** for 40 LP instead of tearing it free, and **refit** a piece's temperament — one effect rerolled, once per piece, for 75 LP — and her six-step story, about the Syn-made original that chose her decades ago, ends with you deciding its fate. **Pip**, self-appointed trapwright and scholar of the Queen's mechanisms, sells **Queen-watching** (your next trap is spotted; 40 LP, cheaper once you've been caught 25 times) and **scavenged wedges** that jam a sprung trap harmless, reviews your last trap when you visit, and at 50 catches finally sends her signed note to the Succubus Queen — by you. **Sister Nectar** keeps the Milking Shrine at her panel (once per floor, lactation theme) with personal text for regulars, and once you've met her she staffs the Milking Station and Milking Shrine in the tower too; her six-step story ends with you choosing what the shrine becomes. **The Pale Cartographer** sells **sketches** (20 LP + 3 per floor): the next three rooms the land is dreaming, rolled in advance and shown as icons on your explore panel — bosses, altars, and events override the dream without consuming it, and descending voids it. Six new Residents achievements cover their stories, services, and custom.
- **The Journal is a hub now, and it keeps an Event Index**: `/codex` opens on a choice between **Fragments** (the lore pages, unchanged) and the new **Event Index** — every random, fetish, and timed event in the tower, including the Feather Array trap, listed with how many times each has found you. Events you have never lived appear as silhouettes with a hint: which `/options` theme to enable, or simply to keep wandering. Counts only accrue from today — earlier sightings are fond memories, not entries.
- **Admirers leave parting gifts**: when a follower's 20 rooms run out and it wanders off, it may leave something behind — a little LP, still warm, or a keepsake (a pressed tuft of fur, a shed scale, a flower that never wilts) that goes on the keepsake shelf at the bottom of your `/profile`. Being driven off by a newcomer still gets no farewell: eviction forfeits the gift.
- **Burden reroll**: at a cycle's start, the burdens screen (`/status` → **Burdens**) now offers a **Reroll** button for each carried burden — Eros swaps it for a different burden you are not already carrying, for **150 LP**, climbing 50 LP with every shuffle in the same cycle. The price resets each cycle, and even Glass Defiance and Slow Feet are in the draw.
- The Auction Block can now be escaped with **Outbid the room**: buy your own evening back for LP priced by depth, provided you can pay. Sister Nectar also turns up working the Milking Chamber once you've met her, and satisfying an admirer again now visibly rescues it from wandering.
- Parting gifts widened: alongside LP and keepsakes, a departing admirer may slip you a size tonic that genuinely nudges a body part a step (growth or shrinking, only with the matching toggle on).
- Codex Event Index milestones: witnessing 50% of the catalogue pays +100 LP, and 100% pays +250 LP, claimed automatically when you open the Codex.
- New achievement — "Fate's Gambler" (reroll cycle burdens 5 times in total, +75 LP).
- **Relic bosses — the empty thrones**: from cycle 2 onward, each boss floor (never Eros's own) has a 30% chance to be found empty — the lord called elsewhere, and a **relic** left holding the threshold: a sacred object fed so many offerings over the decades that it woke up hungry. At most two thrones per cycle are held this way, decided once and not rerolled by leaving and returning. Beating or satisfying a relic clears the gate as surely as its priest would, but pays a relic trophy instead of the priest's, and relic clears are counted apart (they never inflate the all-7-bosses honours). The founding pair: the **Pale Bride**, an unclaimed bridal veil still waiting to be chosen — worship her and she favours you, and at half strength she offers her bouquet to catch or let fall — and the **Mirror Queen**, a mirror that kept every face it was ever shown and now fights wearing yours. Three new achievements and a Codex fragment apiece mark the encounters, and the relic pool is built to grow.
- **Restore the Dress — Covar's exile of Madame Vex**: finish Vex's story with the mannequin ending and Covar throws her out of his back room in grief, salvaging the Original himself. While she is exiled: her bench is closed (the Residents hub shows her room empty under a sheet), Covar's tear-free prices **double**, and his counter offers **🪡 Restore the Dress** — a six-step questline. Salvage seam-lore by tearing free 2 living pieces; seek counsel from the **Succubus Queen** and the **Lich Lord**, asked only on their victory screens after defeating or satisfying them (both knew Syn before the temple — her forgiving seams, her named stitches); keep Syn distracted with Berry's errands; gather elite essence; then attend **the Fitting**: Covar wears the restored Original, and Syn walks into his shop to find her first masterpiece alive and better than ever on her little brother. Afterwards his prices are his own again, he wears the dress at the counter (his dress conversation changes a third time), and Vex reopens in a rundown room of her own — at **double her old fees**, permanently. Rent, she says. The finale also leaves a keepsake: a spare button off the restored Original (🪡).
- **Covar has opinions about Madame Vex's dress**: a new Cursed Shop conversation topic, **Madame Vex's dress**. While the original still wears Vex, he is reverent — it's Syn's first ever work, magnificent, unpartable, and he invokes whatever happened to the tiara. If you saw Vex's story through to the mannequin ending, ask again: he is *furious* — you killed such an amazing dress, and he had years of plans to breed accessories to match it. (Shop Confidant still asks for any 8 of his now-9 conversations.)
- **The last of Wave Two**: six sparks land together. **The Choir Loft** (Voyeurism): the tower's unseen choir performs behind a screen — listen from the dark (+8 Attention; she rewards an audience), or with Group Sex enabled **join the harmony** (+12 Attention and the Harmonised condition) — joining 3 times earns "In the Arrangement". **Brother Confess**: confess 5 times and the Confessional's voice gives you his name, unlocking **indulgences** in his booth (+10 LP, the Indulged condition, and a little corruption where that theme runs) — and when he steps out over an unshriven exit, he now steps out *by name*. **Tobin the Beekeeper** joins the wandering NPCs with a three-stage sticky story: tend his Giant Bees, answer for a queenless hive (reach in barehanded and the hive answers back, in combat), and eat the black honey to become Hive-Sweet. Two new traps: **Alarm Bells** (Exhibitionism) don't hurt — they announce you, so your next fight starts watched (+12 lust, a performing monster, a gathered crowd), and the **Waxworks** (Temperature Play) slow you in warm wax now and leave you **Sculpted** for compliments after. The **keepsake shelf** on `/profile` now also receives finished NPC stories (Tobin leaves black honey; Mira, her labelled vial; and so on) and a **first-meeting memento from every boss and relic** — all fourteen of them. And **relic assignment is domain-weighted**: each relic is three times as likely to hold the empty throne in the domains it belongs to (the Hoardheart haunts the Alpha Beast's floors; the Bride, the courts of queens and the dead) — though any relic can still turn up anywhere. Belonging is a pull, not a law.
- **The Dressing Room** (Living Clothing): a fitting room where the outfits choose *you*. Stand still and be dressed — a try-on montage of gowns, suits, and one victorious corset — and leave wearing nothing but the room's attention: the **Worn by the Room** condition (monsters easier to satisfy, better submission pay, a step slower) for 3 floors. With Sissification also enabled, **Ask for the frills** unlocks the full pretty fitting and leaves you **Sissified** instead. Or tear the rack down and fight the Wardrobe Mimic it always was.
- **The Gorgon Matron negotiates**: a new beast prowls the tower — the Basilisk's older, civilised sister, met in her salon of statues. Her gaze is a negotiation, not a check: offer **tribute (10 + 2×floor LP)** and she starts the fight charmed, gamble on **compliments** (flatter her and she leans in; land on the wrong serpent and she fights insulted, hitting 15% harder), or avert your eyes and fight half-blind like her sister demands. Buying 3 civilised contests earns the **Serpent Diplomat** achievement.
- **Wave Two systems — Desire Magnet, Oaths, and burden rituals**: `/options` gains a **🧲 Desire Magnet** — pick a favourite monster kind and it simply finds you more often (×1.5 encounter weight; costs nothing, and eldritch is not a kind that wanders). At a cycle's start, the burdens screen now offers **Oaths**: swear up to **2 extra torments** beyond your 3 burdens, worth **+10% LP each** — a fully burdened, fully sworn delver runs at ×1.95 LP. Oaths torment exactly like burdens (Slow Feet roots you either way) but never count toward Burdens Carried honours; swearing both earns the **Oathkeeper** achievement (+100 LP). And burdens arrive in fiction now: taking or swearing each one plays its own two-line **ritual scene** as the tower answers.
- **Loose ends tied**: the Tea Ceremony can now be **bottled** — decant the second cup (or buy a **Bottled Ceremony** from Berry's new Bottled Curios page, 60 LP, up to 3 carried) and your next monster drinks instead of you, starting the fight charmed and far easier to satisfy. Slipping out of the Confessional unshriven is no longer always safe: a quarter of the time the voice steps out of the booth as the **Confessor** and makes you discuss it properly, in combat. A new event, **The False Exit**, offers a door that's far too convenient — knock and it knocks back, charmed; open it, and the exit was the monster (a Door Mimic, with the usual door paranoia after). Deep floors (21+) now carry slightly more treasure. And freeing Madame Vex has a price after all: Covar is *furious* about his retired listener, so tear-free removal costs carry his **+50% grief tax** for delvers who chose the mannequin ending — shown in his shop and charged at removal.
- **A seventh monster type — Eldritch — and two more relics (the pool is now seven)**: eldritch is a category with exactly two citizens. **Eros herself is now typed Eldritch** (no longer Demon — demon-keyed curses and gear no longer touch her, and the Eldritch Bride form now resonates with her kind), and nothing eldritch ever appears as a random encounter. The second citizen is new: the **Drowned Saint**, a tentacled relic kept in a dark-water reliquary tank below — she reaches for you with all of her at once, her embrace offered at half strength mirrors her goddess's from the throne, and the family resemblance is very much the point. Beside her joins the **Hoardheart Dragon** (beast): a dragon's heart caged in a reliquary of its own hoard, building herself a body of fused offerings — her heart flares hotter once she's bloodied, and being her tribute is a job she takes seriously. Each brings scenes, a phase, a satisfied closing, a Codex fragment, and a trophy (Scale of the Hoardheart; Ring of the Drowned Saint).
- **The relic pool grows to five**: three new relic bosses can now hold an empty throne. The **Empty Confessional** (demon) is a booth that kept a century of whispered sins and now recites yours back — it names your curses aloud mid-fight, and its phase demands one full confession. The **Chalice That Never Empties** (slime) is a cupbearer poured from her own endless wine: submitting lets you drink deep and wins her favour faster while she, impossibly, only gets fuller. The **First Altar Stone** (ancient stone) is the ruined altar Syn first knelt at in the wilds, older than the clergy, humming the first hymn through the floor and into your spine. Each brings its own scenes, phase choice, satisfied closing, Codex fragment, and trophy — the Screen of the Empty Confessional, the Cup of the Never-Emptying Chalice, and the still-warm Chip of the First Altar.
- **The Mirror Queen truly wears you**: she is a literal doppelganger. Her strength and speed are your own effective stats (never below a boss-floor baseline), her endurance stretches past the body she copied, and her lust hit is your own power turned back on you, capped so a glass cannon's double cannot end things in one touch. Her scenes are likewise built from your own body, part for part — everything she does to you, you do to yourself: if she has a cock, it is yours; if she rides you, it is with your own body; her hands, mouth, and wanting are all copied from the original standing in front of her. Her arrival names you and says it plainly — you are fighting, and if you kneel fucking, yourself — and her phase, her stolen moments, and her satisfied closing all keep the same promise: nobody on any floor knows how you like it better than you.
- **Cursed Shop & Covar honors**: a new **Cursed Shop** achievement category (see `/achievements`) with 8 achievements and 5 titles built around Covar's counter. Tearing free living gear now climbs past the old milestones to **Mimic Curator** (15 pieces) and **Mimic Archivist** (20), and unlocking **all 24** pieces earns the achievement **Every Piece Remembers You** (500 LP) and the title **Covar's Favourite Customer**. Covar himself keeps honors too: **Properly Courted** (5 conversations), **Shop Confidant** / **Covar's Confidant** (all 8 conversations), **Behind the Curtain** (first tryst), **Counter Regular** (5), and **Covar's Devotion** / **Covar's Regular** (10). Existing collectors earn everything retroactively the next time their progress is checked.
- **Her altars know you too**: at 25+ Attention an altar's candles light unevenly — noticed; at 60+ they are *already lit* when you arrive, flames leaning like faces. And when Eros visits a delver she has visited before, she says so: she is keeping count too.
- **The clergy recognize their favourites**: Berry, Syn, and Covar now greet delvers according to how the tower regards them — Eros's heavily watched (**marked**), the merely noticed, the tower-changed, returning regulars, and the sweetly often-surrendered each get their own recognition lines at the shop, the parlour, the Cursed Shop, and the fairies' talk screens. Berry's doctrine holds: losing is the local form of prayer, and the devout are greeted like it.
- **The Delver's Journal (`/codex` · `e,codex`)**: a personal lore codex of 14 fragments, each earned by living in the tower — facing each boss (win or yield), drawing Eros's Attention, being cursed or transformed, reaching the dreaming court, finishing a cycle, meeting Covar. Nothing is bought or rolled, locked fragments show what they need, and a **📖 Journal** button now sits on the fairies' talk screens. Like the fairies themselves, the journal keeps the coy version of the truth until the Temple Reveal — after it, the same pages speak plainly, and the boss fragments name what each lord actually is.
- **Domains & the dreaming court**: entering each new five-floor section now names its lord once — the Broodmother's keeping-furniture halls, the Succubus Queen's court, the Incubus King's claimed corridors, the Dryad's regrowing garden, the Lich Lord's archive, the Alpha Beast's pack-runs, and finally Eros's dreaming court. Floors 31–34 play by her rules: monsters thin out, her altars surface far more often, and sometimes she partially manifests — a voice, a tentacle, a warmth — kinder the more of her Attention you've earned, and never her full presence. That waits at the throne.
- **Bosses quote the gossip**: the lords have heard what the fairies say about them. Once you've heard Syn or Berry discuss a boss at the shop, that boss may quote it back when you meet — the Broodmother has views on Berry's honesty, and the Alpha Beast is extremely pleased about "Puppy."
- **Satisfied bosses & fairy memory**: Syn and Berry now remember what you've asked them — the first ask gets the full answer, repeats get a shorter familiar version, and revealed (post-temple-reveal) answers keep their long form under a familiar frame. Satisfying a boss instead of beating them now also earns extra fairy material the first time you discuss that boss (the game now remembers *which* bosses you satisfied), and the talk screens flag that the fairies especially want to hear about those.
- **The Temple Reveal**: the tower's secret is now in the game. After your first return from floor 35 (completing a cycle), talking to **Syn** has her confirm the truth in person — this place is Eros's temple, built by her clergy, and the cycles are hers. From then on, Syn and Berry's conversation answers change: Syn speaks openly as a builder (founding history, each boss's contribution), Berry keeps her domestic voice but finally uses proper nouns, and both fairies have revealed versions of the boss topics plus This Place, The Cycles, Covar, and Eros. Before your first return, they remain as coy as ever.
- **Covar Zephyren keeps the Cursed Shop**: the cursed counter finally has a keeper — Covar, one of the first delvers, whom the tower remade into a large-breasted incubus who loves what he became and stayed by choice. Talk to him from `/cursedshop` across 8 lore topics (his arrival, why he stays, cursed gear, the fairies, his body, his customers, delving advice, and Eros). Hear out **5 different topics** and he will take you to bed for free: pick his cock (dominant, for everyone), or — if you have a cock of your own — fuck his breasts (dominant) or his ass (deliciously submissive) to drain your lust to zero at no defiance cost. Syn and Berry also gain a **Covar Zephyren** conversation topic once you've torn free your first piece of living gear — Syn adores her "little brother," Berry thinks he's sweet family. His name is now reserved like the other residents' — except for the person he's based on, who may wear it himself.
- **Talk to Syn and Berry**: **Talk** buttons on `/quests` and `/parlour` open a conversation with either fairy — pick a topic and hear their very different takes. There are 17 topics: this place, their marriage, their work, monsters, traps, curses, marks, forms, altars, cycles, and all seven bosses. Boss topics unlock once you've defeated or satisfied that boss; the rest open as you experience the tower, with locked topics showing what they need.
- **Remove ALL curses button**: the `/removecurse` menu now has a **Remove ALL N curses (X LP)** button that purges every active curse in one rite, priced honestly at 50 LP per curse — the total is shown on the button and in the menu text, the button greys out when you can't afford it, and suppressed curses are left untouched.
- **Highest Level leaderboard**: `/leaderboard` gains a **Highest Level** ranking — your best level ever is now remembered across defeats and resets, so veterans keep their crown even at floor 1. (Slash commands need re-registering: `bundle exec rake commands:register`.)
- **Potion of Purity & Potion of Depravity**: Depravity is nearly free (10 LP) and deepens your corruption by 25 toward Fully Corrupted (refused if Corruption is toggled off in `/options`, or if you're already as corrupted as the tower can make you); Purity washes away all of your corruption at once, and absolution is priced like it hurts — 500 LP (refused, uncharged, if you're already clean).
- **Admirers leaderboard**: `/leaderboard admirers` (or `e,leaderboard admirers`) ranks delvers by total admirers ever won. "Adored By Everything" and its title now count kinds won across your whole career, so wandered-off and driven-off admirers still count toward them. (Slash commands need re-registering: `bundle exec rake commands:register`.)
- **38 new monsters prowl the tower**: every creature the tower's scenes and hybrid forms already spoke of can now actually be met in a fight — beasts gain the Silkweaver, Giant Spider, Giant Moth, Giant Bee, Broodmother, Lamia, Naga, Centaur, Harpy, Satyr, Ogre, Troll, Goblin, Orc, Kitsune, Dragon, HuCow, Wildcat, and Wild Dog; demons gain the Demoness, Oni, Siren, and Fae Trickster; slimes the Amber, Cream, Crystal, and Rubber Slimes and the Jellyfish; the undead the Vampire and Lich; plants the Dryad, Mycelian, and Black Orchid; and mimics the Chair, Wardrobe, Couch, and Clothing Mimics and the Stone Golem. The bestiary grows from 24 monsters to 62.
- **Every monster kind now fields a similar roster**: the thinner kinds have been stocked up to 20 monsters apiece (beasts, the old favourites, sit at 23) — 61 more creatures debut, among them the Banshee, Ghoul, Mummy, Revenant, Dullahan, and Jiangshi for the undead; the Treant, Mandrake, Corpse Flower, and Venus Mantrap for plants; the Cambion, Rakshasa, Ifrit, and Velvet Devil for demons; eleven new slimes from Honey to Mercury; and a furniture-store of new mimics (Bed, Book, Mirror, Bath, Throne, Curtain, Rug, Chandelier, Clock, Piano, and Loom). 123 monsters now walk the tower, and no kind is a rarity any more.
- **Potions aisle body tonics**: Berry now stocks **Breast / Cock / Butt Growth and Shrinking Tonics** (40 LP each, drunk on the spot, one size step at a time — they refuse, uncharged, if you lack the part or are already at the tonics' limit) and five **Becoming Draughts** (100 LP each) — Male, FtM, Female, MtF, and Hermaphrodite — so you pick exactly which gender you permanently become, body included. Each draught also washes away any condition that changed your gender (Mirror-Changed, Futa Blessing) — including the draught for the gender you were born as, which melts a borrowed gender-swapped shape off so you're yourself again — counts toward gender-bending honors, and refuses, uncharged, only if you already are that gender with no borrowed shape on you.

### Changed

- **Your keepsakes get a Collections page**: the profile nav gains a **Collections** button opening the full collection, five keepsakes to a page with paging, each with its own **Pin/Unpin** toggle. Pin up to **three** favourites — those are the ones your `/profile` shelf displays (before you've chosen, it shows your three most recent). The Collections page also settles any keepsakes owed from finished stories and bosses already met. On `/profile` itself the shelf now shows a single **emoji** per keepsake instead of the full text — 💐 for Berry's bouquet petal, 🍯 for Tobin's black honey, 🪞 for the Mirror Queen's shard, 🐙 for Eros's sucker-mark — with the full names kept on the Collections page, icons included.
- **The keepsake shelf settles its debts**: the three once-ever storylines now leave keepsakes — **Syn & Berry's second wedding** (a pressed petal from Berry's second bouquet), **Madame Vex's** ending (a seam of the Original's own thread), and **Sister Nectar's** ending (an amended hymn sheet) — alongside the seven wandering NPC stories and the boss/relic mementos. Players who finished any of these before the shelf existed (including bosses already met) receive theirs automatically the next time they open their own `/profile` — nobody's history goes unkept.

### Fixed

- **Pip's milestone beats no longer error out**: pressing a catch-milestone button (Ten catches and friends) passed its threshold to the engine as text, and the comparison against your trap count crashed instead of playing her scene. The threshold is coerced to a number at the engine's door, so every milestone reads as Pip intended.
- **`e,dev curse all` means all again**: the dev curse command never had an `all` case, so the word fell into the fuzzy name matcher and afflicted you with Pollen **All**ergy instead. `curse all` now applies every curse in the catalogue (and reports how many were new); `curse <name>` still applies just the one.

- **Eros gets a curtain, not a wall**: reaching floor 35 no longer opens with the full text wall of dialogue, stakes, and stats. Her arrival now stands alone — the temple, the throne, and everything she has to say — behind a single **▶ Continue** button, and the fight (with its stakes and numbers) only begins when you press it. Walking away doesn't skip her: `/explore` returns you to her dialogue, and combat commands refuse until she's been heard. Other bosses are unchanged.
- **Covar's "Why he stays" now answers the question asked**: his Cursed Shop conversation used to explain staying in the tower while the topic promised the shop. He still isn't trapped — he's *settled* — but now he tells you about the green delvers he watched getting living pieces torn off and left tattered, how he honed himself to take living clothing off properly for LP, and why the fees matter: the pieces left behind have to be fed, and the shop is an orphanage that pays for itself, mothered by an extremely handsome incubus.
- **Grief pricing, repriced**: Covar's mannequin-ending grief tax on tear-free removal was +50%; while Vex sits exiled it is now a flat **double**, and restoring the dress lifts it entirely. Vex's own bench fee no longer carries his tax at all — after her return it carries her doubled rent instead.
- **Madame Vex's fee is honest arithmetic now**: negotiating a living piece off intact was a flat 40 LP; it is now **twice that piece's tear-free price (minimum 40 LP)** — the expensive mercy always costs more than destroying the piece, and dearer pieces cost dearer. And Covar's grief tax reaches her bench: for delvers who freed her (the mannequin ending), her negotiation fee carries the same **+50%** as his own removal prices, because she works out of his back room and his moods are her overhead.
- **Admirers wander off**: a monster admirer now follows you for **20 rooms**, then loses your scent and vanishes (you'll see its goodbye as you explore, and `/status` shows each follower's rooms left). Pleasing its kind again refreshes the 20 rooms. Admirers can no longer be collected forever — enjoy them while they last.
- **At most three admirers at once**: your scent only carries so far. Winning a fourth admirer drives off whichever follower was closest to losing your scent (fewest rooms left) — the newcomer takes their place, and you'll see who's been driven off. Your all-time count keeps growing regardless.
- **Leaderboard rankings are paged now**: instead of a button for every ranking, `/leaderboard` has **◀ Prev** / **Next ▶** buttons that flip through Cycles, Deepest, Highest Level, Kills, LP, and Admirers (wrapping around at the ends), with the current ranking and its position shown between them.
- **Achievements use a category dropdown, and the categories have been re-shelved**: the nine category buttons are gone — pick from a dropdown (each entry shows its unlocked count) and page within it as before. Categories are now accurate: **Cycles** (every cycle-count milestone), **Residents** (Berry's quests, the tower's residents and their stories, Eros's Attention), **Forms** (hybrid forms and the chimera), and **Fortune** (LP earnings) are new; tearing living gear free belongs to **Cursed Shop**, boss satisfaction to **Submission**, Syn's marks to their own **Marks**, and the chastity-denial ladder sits whole in **Kinks**. No achievement changed what it asks for — earned progress is untouched, only the filing. (Slash commands need re-registering: `bundle exec rake commands:register`.)
- **Her altars value flesh over coin**: at an Altar of Eros, **offering yourself** now draws the most of Eros's Attention (+25, up from 15), while a 25 LP **tithe** draws less (+15, down from 20) — the tithe's real prize remains her Favour blessing. Praying is unchanged (+10). Coin buys a nod; devotion buys her gaze.
- **Event fights are the monster the scene describes**: choosing to fight in an event (the Silkweaver's web, the lamia, the velvet moth, the troll chieftain, the lich, and 50 more) now spawns that very creature instead of a random same-kind monster — no more answering a spider-woman's challenge by wrestling a bear. The gargoyle fight is properly a beast and the hellhound fight properly a demon, matching their kinds. Eight events whose foe was only ever "a demon" or "an immense beast" still draw from the whole kind.
- **Floor traps are scenes now, not stat lines**: the **Lust Rune**, **Aphrodisiac Gas**, **Pleasure Seal**, and **Binding Vines** traps each play out an explicit, anatomy-matched scene when they catch you (with chastity-aware variants when you're locked), instead of a bare "Lust surges" or "Vines cinch tight." Spotting one in time now also shows you what it's hungry for before you choose to dodge or submit to it. The Bloating Slime and Paddle Golem events were likewise rewritten steamier and stripped of their injury wording. Trap effects are unchanged.
- **The Admirers leaderboard now ranks true lifetime totals**: delvers who won admirers before lifetime counting existed were being ranked by their *current* followers, so their score melted away as admirers wandered off. Lifetime totals are now floored by the monster kinds a delver has ever won (which the tower has always remembered), new wins count upward from that true total, and re-winning a kind after it leaves keeps adding up.
- **Condition summaries no longer leak raw internal text**: effects the summary writer didn't know used to print as snake_case (things like `damage_reduction 2` or `beast_encounter_rate 2`). Every effect now describes itself in plain words, unknown effects humanise instead of leaking, and the Conditions screen recomputes summaries from your effects — so even conditions you are already wearing display cleanly.
- **Monster scenes now match the monster**: every one of the 123 monsters is tagged with a texture family, and the generic scenes are written from it. Dragons, lamiae, and nagae get scaled bodies and forked tongues (and no knots); spiders, bees, and moths are chitinous; harpies feathered; centaurs equine; gargoyles cold stone; ghosts, wraiths, and banshees are spectral rather than bony; sirens are finned and sleek instead of fork-tongued; djinn and fae tricksters are glamoured. Praise after a satisfying encounter matches too — no more dragons rumbling about their fur. Wolves and their kin keep their fur and knots, exactly as they should.
- **Five new traps**: **Kiss Ward** (blow a kiss to pass — the next monster you meet starts charmed, gaining admirer progress for its kind or refreshing an existing admirer), **Honey Floor** (slows you for the floor and your sweet smell draws beasts closer), **Shrinking Doorway** (shrinking opt-in: leaves you **Shrunken** for a few floors, unless you are far too large, in which case you simply get stuck), **Compliment Ward** (body-writing opt-in: a filthy compliment inked where monsters can read it — they lean in closer for a few floors), and the **Feather Array** (tickling opt-in: a timed trap of hundreds of coordinated feathers; enduring it leaves you **Ticklish**). Opt-in traps only appear while their theme is enabled.
- **Five new events**: **The Confessional Booth** (confess small for a little of Eros's Attention, or in detail for more — with Corruption enabled, detailed confessions taint you; occasionally the voice is Syn's), **Aphrodisiac Tea Ceremony** (drink and ride out the **Tea Heat**, refuse and something below appreciates your manners, or pocket the leaves and sell them to Berry), **Mirror Duet** (gender-bending: embrace your reflection and wake **Mirror-Changed**, send her back and keep her compliment in silver ink, or fight **Your Reflection**), **Hot Spring of Sizes** (growth/shrinking: soak and one body part steps a size, with a chance the Spring Keeper surfaces to admire its work; dip a toe to learn its intentions first), and **The Masseuse's Table** (overstimulation: a four-turn timed event; enduring it all pays LP and leaves you **Loose Limbs**). The tea ceremony and masseuse's table also join the Longing system, growing likelier the longer you go without them.
- **Rare-event ladders are kinder**: the tentacle pit, glory hole, and dildo trap now quietly grow more likely the longer you go without seeing one (their pull strengthens every 50 rooms past 150 unseen, up to 5×, and resets when one finds you) — persistence, not pure luck. Their top achievement rungs are also trimmed: **Glory Hole Legend** 30 → 25 uses, **Glory Hole Myth** 50 → 40, **Pit Royalty** 30 → 25 survivals. If you are already past a lowered rung, it unlocks on your next progress check.
- **Depraved clears are judged at Eros's door**: whether a tower clear counts toward **Depraved Disciple / Depraved One** is now decided by your content toggles at the moment the Eros encounter begins — her intro tells you when you stand armed — so flipping a theme mid-fight neither earns the clear cheaply nor voids it by accident. Dying to her disarms it.
- **Mimic fights count as chests**: a mimic chest that rears up and fights you (when no living gear matches your tastes) now counts toward your chests-opened totals and chest achievements, like every other chest you pry open.
- **`/shop` opens on a Shops menu**: instead of landing inside Berry's shelves, the shop command now presents the tower's storefronts as a menu — **Berry's Gear**, **Berry's Potions** (now its own shop, with its themed shelves as tabs), **Cursed Gear — Covar** (showing your unlocked count), **Berry's Quests**, and **Syn's Parlour** — each with its own **Visit** button. Inside a shop you see only that shop's shelves, and an **All Shops** button (also added at Covar's counter and bed) takes you back to the menu. This keeps every shelf uncluttered as new shops are added. `/shop` with a category (or `e,shop potions`) still jumps straight to that aisle, and `e,buy`/`e,sell` by name work as before; future shops will join the menu rather than crowding any shelf.
- **`/options` is a menu now, not a text wall**: the four dropdown walls are gone. The options screen opens on a small menu — **Core**, **Opt-in bodies**, **Opt-in kinks**, **Opt-in fetishes**, each showing how many of its themes are on — and each family opens into pages of five themes, every theme with its description and its own toggle button (lit green ✅ when on, grey when off, saved the instant you press it). The leftover body-size display has been removed from the page entirely; sizes still live on your profile and in Berry's Potions aisle. Old options panels still work and land in the new layout.
- **`/status` tidied**: the Combat line is gone, and burdens have moved off the main sheet behind a **⛓️ Burdens** button — that screen explains the deal (+25% LP per burden, max 3, cycle-start only) and lists every burden with its effect beside its toggle button, which stays live while you're on floor 1. Under your corruption line, `/status` now counts your **Admirers: N current · M all time**, and names the three followers closest to losing your scent (with their rooms left), so you know who is about to wander off.
- **Corruption rebuilt on a 0–100 scale, and it bites now**: stages at 25/50/75/100 (Tainted, Lewd, Depraved, Fully Corrupted). Existing corruption is stretched ×5 so you keep your stage. The gifts are aimed at giving in — up to **+25 LP per submission**, **+20% satisfy chance**, and **+5 Submission** at full corruption — and the tolls scale just as hard: lust lands up to **×1.6**, Resistance erodes to **−5**, max Defiance drops up to **−25**, and healing works up to **40% worse**. Gains rescaled to match: submitting feeds it +5, corrupting fonts +15, and a Potion of Depravity is worth +25.
- **Glass Defiance is a true glass cannon now**: instead of −10 max Defiance, the burden sets your max Defiance to exactly **30** — healing, gear, and level bonuses cannot raise it past 30 while you carry it, and no curse, condition, or penalty can reduce it below 30 either. Since an orgasm costs 20 Defiance, two orgasms with no recovery in between will break you.
- **Slow Feet actually hobbles you**: instead of −1 Agility, the burden now removes fleeing entirely (combat flee attempts are refused — there is no roll to fail) and traps always catch you: your trap-dodge chance is 0%, whatever your Agility or gear says.
- **`/help` explains cycles and burdens**: the tutorial now covers what a cycle is (clear floor 35, return to floor 1 with your delver intact, monsters compounding ~×1.3 stronger and richer per cycle) and what burdens are — up to 3 optional torments taken on `/status` at a cycle's start for +25% LP gains each all cycle, locked in once you delve — naming all five burdens and their drawbacks. Previously burdens were never explained anywhere a player could read.
- **Syn hates every minute of curse removal**: her curse ledger now makes her position unmistakable — curses are blessings and beautiful works of art, removing them is vandalism, suppressing them is smothering something beautiful, and Lust Points are the *only* reason she agrees to either. Payment pointedly does not buy her approval or forgiveness: Suppress and Remove results, the bulk purge, insufficient-LP refusals, and her **Curses** conversation topic (and Berry's account of her) all say so.
- **`/curses` is Syn's curse ledger now**: instead of a read-only list, Syn herself handles your curses — five per page, each curse with its own **Suppress (25 LP)** and **Remove (50 LP)** buttons, steady global numbering across pages, and her voice on every result. Buttons carry the curse's identity rather than a bare number, so an old panel can never quietly act on the wrong curse after the numbering shifts; buttons grey out per-action when you can't afford them, **Remove ALL** remains as her bulk rite, and suppressed curses are shown sleeping under her ink. `/removecurse` and `/suppresscurse` (including their numeric shortcuts and old panel buttons) now open and resolve through the same ledger.
- **The Cursed Shop is organized like a shop now**: Covar's counter borrows the normal shop's layout — **Weapons / Armor / Accessories** aisle tabs, five pieces per page with Prev/Next, and each piece rendered with its own state button beside it (**Take**, **Bound**, **Sealed**, or **Locked**) instead of one long list with a spill of buttons underneath. Ready pieces sort to the top of each aisle, sealed pieces name the setting or body requirement keeping them sealed, and undiscovered pieces stay anonymized. `e,cursedshop [weapon|armor|accessory]` picks an aisle directly. Covar's sex options have moved out of his talk screen into their own page: press **🛏️ Go to bed with Covar** (on the shopfront or his talk screen) to reach his bed, where the three choices each get their own section, anatomy-gated choices show as unavailable instead of vanishing, and scenes now play out and resolve on the bedroom page.
- **Shop buys sit beside the gear**: each item in `/shop` now renders as **Name (cost LP)** with its own **Buy** button right beside its text, instead of a separate row of buy buttons under the list. Owned items show a disabled **Owned** button, and Buy greys out when you can't afford the item.
- **Floor 20 has a new boss: the Verdant Dryad** replaces the Ancient Treant — a towering, voluptuous dryad of bark-brown skin, leaf-green hair and blooming flowers, stepping out of her great tree. Same floor, plant typing, stats, root-grasp, pollen phase and Treant Heartwood trophy; all of her combat, submission and phase scenes are new. Fights and boss records saved under the old name carry over to her.
- **Chimeras have their own screen**: the hybrid menu no longer shows your chimera's card, effects, deepening, or fusion controls at all — just a **🧬 Chimera…** button. The Chimera screen holds everything fused: your current chimera, taking it (or returning to human), its deepening and mutations while it's your form, and the fusion picks.
- **The Milking Station no longer requires breasts alone**: expectant delvers with a cock get the sleeve pump instead, and the frame is only offered to bodies it can actually milk — breasts or a cock.
- **The Special aisle is the Potions aisle now**: same shelf of drink-on-the-spot consumables, relabeled — `/shop potions` or the **Potions** tab reaches it — and shelved by theme, one shelf per page: **Draughts & Elixirs** (Cooling Elixir, Defiance Draught, Bottled Sanctuary, Purity, Depravity), then **Growth Tonics**, **Shrinking Tonics**, and finally the **Becoming Draughts** — never more than five bottles to a page. (Slash commands need re-registering: `bundle exec rake commands:register`.)
- **Body sizes are no longer picked in `/options`**: the size menus are gone (your current sizes still show there and on your profile). Shapes change the way the tower prefers — by drinking Berry's tonics, or by whatever the tower's fountains and events do to you.
- **Scenes now name the act and the anatomy involved**: breeding, knotting, riding, and masturbation scenes across events, NPC encounters, Covar's bed, Eros's altar, and living gear no longer leave it vague — the text says which cock, pussy, ass, or breasts are involved, so what happened to you is never a guessing game.

### Fixed

- **Curse text no longer lies about "damage"**: monsters never deal HP damage to you — their hits build your lust, and defiance is what breaks — so every curse that said "damage" now says **lust damage** and names its monster kind. **Gelatinous Form** now reads honestly (15% less lust damage from all monsters, but slimes deal 25% more — a net ×1.06 from slimes), **Mimic Flesh** likewise; **Oozing Pores** no longer cites a phantom "armor" stat (it's resistance), **Soulbound** no longer claims demons "can't kill you" (they can't *finish* you — your defiance holds at 1), **Deathly Resilience** grants max Defiance rather than plain Defiance, and **Hellfire Blood** now distinguishes the 2 extra damage your hits deal to a demon's HP from the lust damage demons deal you. Hybrid form perks that promised "damage resistance" say "less lust damage taken" instead. No curse's numbers changed — only the words.
- **Shop panels could exceed Discord's 40-component limit**: with the Potions aisle grown to three pages, buying a potion (which re-renders the shop with a notice) on a panel that also carried a regard line overflowed and failed with "Invalid Form Body." The aisle header now folds your LP balance and page into one line, and the redundant page-indicator button is gone; every aisle and page now renders with room to spare.
- **Timed events, milking gear, and boss surrenders keep their anatomy straight to the end**: the tentacle pit, bonding vines, spirit possession, and aphrodisiac mist now name the hole or organ involved on every turn (including caged variants where the friction lands on steel), a caged delver at the Milking Station or Milking Shrine is pumped over the cage instead of being described as sleeve-milked, Covar no longer counts a locked cock as usable for his breasts or ass (he'll say why), surrendering to the Alpha Beast or Incubus King names the cock going into your pussy or ass, and plug-type living gear is now formally gated to bodies with an ass to plug.
- **Events respect the body they're given**: single-partner scenes (breeding and knotting beasts, the Colossus, the Stables, several succubus and incubus encounters) now choose one opening the delver actually has instead of describing several at once, partners who "ride you" only ride a cock when there is one (a pussy gets ground against, clit to clit), and events that require a specific body part no longer offer — or reward — their main choices once that part is gone, even from an old panel. Generic monster embraces no longer claim parts you don't have.
- **Milking only happens to bodies that can be milked**: the Milking Station's **Be milked**, the Milking Chamber, and the Milking Shrine now all require breasts or a cock — delvers with neither are never offered the milking, and stale panels can't grant them milking progress, LP, lust, or conditions. The shrine's scenes now match the body in the stall (cock-only delvers no longer get breast scenes), and the Nectar Milking Bra's living-gear scene falls back to teasing if its wearer's breasts are gone.
- **Eros no longer purges the same curse every visit**: when an altar visit chose the free curse purge, she always took the first curse in the list, so the same curse kept being picked. She now chooses a random active curse each visit.
- Eros's floor-35 introduction now matches the temple's true history: the tower was raised *for* her by her clergy (she did not build it herself), her greeting no longer taunts delvers about "escaping," and beating or satisfying her is described as what it is — she returns you herself to begin the next cycle.
- **Chimera screen could fail with Discord's "Invalid Form Body"**: its **◀ Back to Hybrid Forms** button shared the same button ID as the navigation row's **Hybrids** button, and Discord rejects duplicate component IDs in one message. The back button now has its own ID. Error reports also now include Discord's field-level rejection details (which component and why), so any future invalid panel names its own culprit instead of just "Invalid Form Body."
- **Hybrid and Chimera screens no longer cut text off mid-sentence**: form descriptions, appearances, and effects now display in full on both screens — verified against the longest content in the game, with even the bulkiest pages using well under half of Discord's text limit. The fusion pickers also page now (**◀ Forms / Forms ▶** buttons), so all of your forms stay reachable even past Discord's 25-option menu cap.
- **`/curses` and `/removecurse` no longer break with many curses**: both are paginated (8 per page) so the list stays within Discord's component limits no matter how branded you are, and the purge menus page along with the list. Curse numbers stay the same on every page, so `e,removecurse N` still lines up.
- **The Dildo Trap no longer dodges itself**: spotting it in time now offers the same choice as other traps — **Dodge** or **Let it happen** — instead of automatically rolling you aside.
- **Berry's Cursed Bearer quest can always be finished**: it now counts every curse you gain while the quest is active — including re-gaining a curse you'd already collected and purged — instead of only counting brand-new curses. Delvers who had already collected every curse can complete it again.

### Removed

- **Curse Purification Scroll**: no longer sold. Curses are Syn's ledger work now — purge or suppress them through `/curses`.

## 2026-10-20

### Added

- **Reserved character names**: the tower's own names — Syn, Berry, Eros, the 8 residents, and the bosses — can no longer be taken by players (the developer may still wear Syn, and Berry's own person may wear Berry). Player-name uniqueness (case-insensitive) already applied and still does
- **A developer-only honour**: the title **The Original Syn** and a hidden hybrid form, the **Syn Fae** (platinum hair, smoked-glass wings, parlour ink and all), visible and earnable only by the developer — Syn is based on them, after all. Eros has a special greeting and scene for the form, and it fuses into chimeras like any other

- **Achievements now total 200**: 50 new ones, including a full cycle ladder (2 cycles up to **Quarter Century of Sin** at 25), 2,000-kill and 1,000-floor grinds, all-30-curses **Every Brand**, all-8-residents **Every Story**, all-6-admirer-kinds, and 100 Berry quests — plus **8 new cycle titles** (Second Wind at 2 cycles through **Twenty-Five Towers** at 25)

### Fixed

- **`/transformation` could fail with a Discord "Invalid Form Body" error** for players with a chimera, deepening, and several unlocks at once — the panel's text could exceed Discord's component message limit. Form cards are now trimmed and unlock news is capped at 3 lines

### Added

- **100 titles and 150 achievements**: 19 new titles (Mimic's Favourite, Throne Breaker, Eternal Delver, Trap Toy, Untouchable, Chest Goblin, Denial Royalty, Two-in-One Flesh, Walking Menagerie, Burden Bearer, and more) and 51 new achievements across every category — deep-cycle grinds (1,000 kills, 7 cycles, 25,000 LP), Berry's quests and story, monster admirers, altars, chimeras, burdens, and the six-mark canvas
- **6 new hybrid forms (30 total)**: Centaur, Siren, Minotaur, Clockwork Maid, Porcelain Muse, and Bone Marionette — all fusable into chimeras like any other form

### Fixed

- **The stair-search counter now resets explicitly** the moment you descend a floor (and on defeat resets and cycle clears), instead of relying on the floor stamp to invalidate it — no stale counts can carry into a new floor

### Added

- **Floor progress on `/status`**: shows rooms searched on your current floor, the earliest room stairs can appear, and the room they're guaranteed by

### Changed

- **Late cycles now bite much harder**: monster and boss stats (and their LP rewards) compound at ×1.3 per cycle instead of a flat +20% — cycle 6 is ×3.7, cycle 8 is ×6.3 — so heavily levelled builds stop one-shotting the tower. Satisfying monsters also gets harder each cycle (−5% per cycle, and the satisfy chance cap itself shrinks), and bosses demand one extra successful submit every two cycles (cycle 8 bosses need 6)

### Fixed

- **Stairs minimum is now enforced at a single choke point**: no path (room roll, sanctuary, guarantee) can produce stairs before the threat/cycle minimum, and the stairs message now reports how many rooms you searched on the floor above so the count is visible in-game

- **Eros now recognises Eldritch Brides**: the final boss has a special greeting and tailored scenes for the form — including when it's fused into a chimera as either half — honouring the form's promise that "Eros looks at you differently"

### Changed

- **Floor descent is now threat- and cycle-scaled**: stairs take a smaller share of the room pool as threat climbs (about 18% of rooms at low threat, ~9% at medium, ~3% at high), can never appear before a threat-scaled minimum (5 rooms at low threat, 10 at medium, 15 at high), and are guaranteed by a threat-scaled maximum (20/30/40 rooms). Both the minimum and the maximum grow by +5 rooms per cycle after the first — so a medium-threat cycle-6 floor hides its stairs for at least 35 rooms and guarantees them by 55. Room rolls are normalized, so monster spawn boosts can dilute the stairs but never crowd them out entirely

## 2026-10-19

### Fixed

- **You can no longer be trapped on a floor forever**: after 12 rooms on one floor without descending, the next `/explore` always finds the stairs. This also fixes high-cycle runs where monster spawn boosts (like the Tempting Dark burden) could crowd the stairs out entirely

### Changed

- **Spotted traps are now a choice**: when your Agility lets you dodge a trap, you instead pick **Dodge** (leap clear, as before) or **Let it happen** (stay still and take the trap's full effect — it still counts as a triggered trap, lust surge and all)

- **Breast sizes are now a cup scale**: Flat, A cup, B cup, C cup, D cup, E cup, F cup (in `/options`, shown with cup names everywhere sizes are displayed). Existing delvers migrate automatically (small → A, medium → C, large → E), and growth events now climb the cup ladder one rung at a time

### Added

- **Syn & Berry have taken over the shop and parlour.** Madame Vex is gone; the establishment is now run by a married fairy couple:
  - **Berry** runs the shop counter (`/shop` has her welcome, plus **🍓 Berry's Quests** and **Syn's Parlour** buttons): a cheerful, strawberry-bright, extremely possessive fairy who is all smiles until someone looks at her wife too long
  - **Syn** works the parlour bench (`/parlour`): an exhausted fairy with very long platinum-blonde hair who wears next to nothing and displays every tattoo and piercing she sells on her own inked, pierced skin — and is somehow still the flirtiest person in the tower. All mark scenes, messages and achievement text now name her
- **Berry's quest system**: Berry offers **3 quests at a time** from her own quest board (`/quests`, `e,quests`); hold up to **3 active**. Twelve repeatable errands — defeat monsters, submit willingly, satisfy or defeat bosses and elites, open chests, clear floors, orgasm, collect curses, accept events, dodge traps — each paying **50–150 LP**. Progress counts from your lifetime stats the moment you accept, quests survive defeat and cycles, and completed ones can be claimed from the board (or dropped, which rotates Berry's offers). New achievement **Berry's Favourite** (10 quests, +100 LP) and title **Berry's Favourite** (25 quests). Original character designs for both fairies are in `docs/art_reference.md`
- **10 new marks at Syn's bench** (21 designs total; still up to 5 worn): tattoos **Rose & Thorns** (+1 STR), **Moon Moth** (+2 LP from treasure), **Inked Collar** (Petplay, +1 Submission), **Padlocked Heart** (Chastity, +3% dodge) and **Gate Sigil** (Gaping & Fisting, +4% satisfy); piercings **Ear Cuff Chain** (+4% trap avoidance), **Lip Ring** (Oral, +2% satisfy), **Brow Bar** (+3% chance monsters back off), **Labia Rings** (+2 LP when a monster gets its hands on you) and **Frenum Ladder** (+1 damage). Syn wears every new design herself, of course
- **Operators:** the `/parlour` slash description changed and a new `/quests` slash command was added — run `bundle exec rake commands:register`

### Added

- **Seven new hybrid forms** (24 total): **Eldritch Bride** (tentacles/possession; Eros has Opinions), **Weaver** (bondage; traps fear you), **Lamia** (hypnosis/size; crushing coils), **Kitsune** (furry/hypnosis; illusion tricks), **Hoard Dragon** (open 25 chests), **Gargoyle** (exhibitionism/objectification; a living statue) and **Mycelian** (plants/aphrodisiacs; intoxicating spores) — each with its own combat special
- **Form deepening & resonance**: winning fights or satisfying monsters while wearing a form deepens it (**Stage I/II/III** at 3/8/15), and each stage offers a choice of **three mutations** (Keener Senses, Thicker Hide, Hungrier Heart, Tireless Body, Silken Voice, Predator Grace) that apply only in that form. Monsters of the same *kind* as your form's nature now resonate with you: easier to satisfy (+8%) and gentler with their lust (−10%)
- **Dungeon biomes**: entering each 5-floor section rolls a **weighted biome** for that stretch, **strongly tipped toward the boss waiting at the section's end** (suited biomes roll ~8× as often, so a mimic boss usually rules a Glass Menagerie or Clockwork Brothel while the Lich Lord's stretch tolls with the Bell Choir) — and the roster doubled to **12 biomes**, adding **The Drowned Chapel, Honeyed Hive, Clockwork Brothel, Ashen Court, Flooded Grotto** and **Masquerade Ball** to the original six. Your biome is rolled fresh each section and each cycle, announced as you explore, and tilts monster types and event themes throughout the section
- **Altars of Eros & her Attention**: shrine rooms (7% of explores) let you pray, tithe 25 LP, or offer yourself. Devotion — satisfying monsters and bosses, kneeling at altars, wearing Syn's marks — fills Eros's **Attention** (shown at her altars and noticed in her boss entrance); at 100 she **visits**: a gift of LP, her Favour, a curse purged free, or healing, delivered by tentacle
- **Monster admirers**: satisfy 3 monsters of one type and one becomes your **admirer** — it weakens its own kind for you, leaves LP gifts after victories, and gets jealous (other foes press 10% harder) when you smell of someone else
- **Syn's Secret**: a hidden five-step story at Syn's bench in `/parlour` — invisible until you wear **5 of Syn's marks**, when a **Hear Syn's secret** button appears. Syn (exhausted, shamelessly flirty, and pointedly faithful: "flirting's free, darling; everything else is Berry's") is secretly planning to **renew her vows in a surprise second wedding**: keep Berry distracted with her own quests → gather cake fruit → light the aisle with boss-light → set matching ink with elite essence → satisfy a boss so Eros watches the wedding. Pays 80–200 LP per step, can never be repeated, and vanishes once done. Finishing earns the **Fairy Family** title, unlocks a **sixth mark slot**, and Syn's masterwork **Wedding Mark** — a tribal collar band around the neck meeting in a heart with a strawberry at its centre (+5% satisfy, +3 LP on submit, 150 LP). Marks now total 22 designs
- **Cycle burdens**: at a cycle's start (floor 1, `/status` or web Settings) take up to **3 burdens** — Hungry Tower, Glass Defiance, Slow Feet, Tempting Dark, Branded Start — each multiplying **all LP gains by +25%** (up to ×1.75) for the whole cycle; locked in until you clear the tower
- **Chimera fusion — cross-hybrid forms**: delvers with two or more unlocked hybrid forms can now fuse them into a **Chimera** at `/transformation` (pick a primary and a secondary from the new fusion bench, or `e,transformation fuse Kitten + Slimekin`) for **100 LP**. The primary keeps its full effects and its combat special; the secondary echoes at half strength (flat bonuses halved, multipliers blended halfway — a Kitten-Slimekin Chimera keeps the Kitten's +20% dodge and takes the Slimekin's damage resistance from 20% to 10%), appearances merge, and the combo is stored permanently: fuse once, re-take your Chimera any time like any other form, and re-fuse a different pair whenever you like. **Eros notices chimeras** by their fused name when you reach her temple. The web version's Hybrids tab has the same fusion bench

### Changed

- **Eros has her true form, and she notices you**: the final boss (floor 35) is now described and drawn as designed — towering, ash-grey bangs with crimson heart markings, pitch-black horns, glowing red eyes, black choker, a glossy white heart-accent bodysuit and split mantle, heavy black cuffs, sheer wrapped thigh-highs, and enormous white tentacles with wet crimson-magenta suckered undersides instead of a cape (full brief in `docs/art_reference.md`). Her entrance now **reads your delver**: she comments on your active hybrid form, traces each of Syn's marks on you by name, names the curses she can smell on you (and counts the rest), and greets any living gear that writhes toward her. Her sex scenes do the same — tentacle scenes are woven through the fight, plus lines built from *your actual* form, each worn mark, your first curse and your bound gear — and her mid-fight temptation, sated and beaten lines all move with her new body

### Fixed

- **`e,quests` and the shop's Berry's Quests button did nothing**: the quests module was never added to the bot's command include list, so neither the prefix command nor its button/select handlers were registered. Both work now (the `/quests` slash command also needs `bundle exec rake commands:register` if you haven't run it yet)

### Changed

- **Cursed gear now respects your fetish toggles**: every piece of living mimic gear is themed to one content toggle and can only bind you while that theme is enabled in `/options` (and only onto a body with the right parts). To keep the risk fair, the wardrobe grew from 11 to **24 pieces** themed to other tastes — Tentacle Vine Belt, Knotted Tail Plug, Nectar Milking Bra (Lactation), Possessed Pendant, Hypno Spiral Spectacles (Hypnosis), Sheer Exhibition Cloak, Buzzing Toy Harness, Good Pet Collar (Petplay), Living Maid Uniform, Pony Bridle, Tickle-Feather Gloves, Musk-Soaked Scarf and Broodmother Plug (Oviposition) join the classics, each with its own in-combat violation scenes. The **Cursed Shop** seals pieces whose theme you've disabled (re-enable it to call them back), and pieces you're already wearing stay on but their scenes soften to teasing if you switch their theme off. If **no** cursed piece matches your tastes, a mimic chest no longer hands you gear you didn't consent to — it rears up as a **Chest Mimic** and fights you instead, so chests stay dangerous for everyone
- **Quests moved to their own page**: Berry's quest board no longer sits at the bottom of `/parlour` — it has its own `/quests` command (`e,quests`), and the web version has its own **Quests** tab. `/parlour` is just Syn's marks again; active quests, progress and completed counts are unchanged
- **Chest loot rebalanced** (a player reported mostly seeing Defiance Tonics — they were 25% of normal chests, and once you owned all 10 chest-only gear pieces the 25% gear drop silently turned into LP, leaving veterans with 75% LP / 25% tonics):
  - Defiance Tonic: **25% → 15%** of normal chests; the bonus cracked vial no longer appears at full defiance
  - LP pouch: **35% → 30%**; gear: **25% → 30%** (plus the coins roll can still add a piece)
  - New **10% consumable drop**: a Defiance Draught, Cooling Elixir or Bottled Sanctuary, picked from whichever you'd actually use right now (never a draught at full defiance or an elixir at 0 lust)
  - Once you own every basic and rare chest piece, the gear drop now gives a random **unowned shop item** instead of LP; only a player who owns literally every gear piece in the game gets the LP melt (now worth more: 25 + 2 per floor)
  - Verified by simulation: roughly LP 45%, gear 31–36%, tonic ~15%, consumable ~10% per normal chest. Mimic chances are unchanged

### Added

- **New opt-in fetish: Gaping & Fisting** (toggle `gaping` in `/options` → Opt-in fetishes; there are now 58 toggles, and `e,sluttify` covers it too). Three new events, each with a gentler alternative and a lasting condition:
  - **Shrine of the Open Hand**: a marble hand of Eros fists your ass (and your pussy too, if you have one), leaving you **Stretched Open**
  - **The Gauntlet**: an arena master's huge hand works you open knuckle by knuckle, leaving you **Left Gaping** — or fight him
  - **The Living Gauntlet**: a giant breathing glove fists you itself, leaving you **Glove-Stretched** — or stomp the mimic
  - New title and achievement: **Wide Open** (experience fisting 3 times)

### Changed

- **Curses no longer wait for a defeat.** The tower can now brand you mid-combat:
  - Orgasming in combat without being broken: **35%**
  - Satisfying a monster by submitting: **30%** (bosses: **40%**)
  - Winning a fight: **10%**, elites **25%**, bosses **40%**
  - Every cycle past the first adds **+5%** to all of these (elites add another +10%), capped at 85%. Defeat and being broken still always curse you, and being broken by a trap or event now curses you too
  - Chance-based curses always pick one you don't already bear (type pool first, then any pool), so your collection keeps growing instead of repeating
  - More curses means more **Threat**, so monsters get stronger and their lust hits grow — carrying curses is now a real difficulty spiral. `/help`'s tutorial explains the new rules
- **Deep-cycle combat is less of a pushover:**
  - Resistance now has softer diminishing returns, and a lust hit can never be reduced below 15% of its raw strength — high-RES delvers will feel more than 1–2 lust per turn
  - Submission's satisfy chance has diminishing returns (max 70%, down from 80%), and each cycle makes monsters 3% harder to satisfy (bosses another 5%) — submitting still works, it just takes longer while the monster keeps its hands on you

### Fixed

- **Egg-laying events now put the eggs in your ass**, as intended: the Egg Chamber, the Oviposition Chamber and the Spawning Pool no longer use your pussy/womb (that's still the Breeding events' job). The Egg Chamber's scene was also rewritten — the ovipositor eases in slick and slow instead of forcing its way in

## 2026-10-14

### Changed

- **The final boss is now Eros, Goddess of Lust.** The Tower Lord on floor 35 has been replaced by the goddess who built the tower as her temple. She has a new entrance, new explicit scenes for every body part (forced and willing), new reactions as you satisfy her (or bore her), her own orgasm and defeat lines, a new half-HP choice (**Refuse her** or **Kneel and be hers**) and new flavour for her door-slamming, heat and enraged abilities. Her stats, abilities and rewards are unchanged. The Depraved One title and achievement, the `/help` tutorial and `e,dev finalboss` now name her. Fights against the Tower Lord that were already in progress carry on with her new scenes

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
