# Conversations — Reveal & Ask-abouts

Status: living design document. Split from the former monolithic `docs/lore.md` on 2026-10-23. See `README.md` for the full index.

## The Temple Reveal

Players should not initially be told that the dungeon is a temple.

### Syn and Berry's language rule

Syn and Berry must never call the place a **dungeon**.

Before the temple reveal, they should keep its nature vague and use indirect language such as:

- "the tower"
- "this place"
- "these halls"
- "the floors"
- "up here" or "down there," where appropriate

They should not accidentally confirm that it is a temple before the reveal.

After the truth is revealed, Syn and Berry can openly call it **the temple**.

This restriction applies specifically to Syn and Berry. General narration, system text, other characters, and player-facing labels may continue to use words such as dungeon, ruins, or tower unless a later lore pass decides otherwise.

### Reveal timing

The reveal happens **after the first return**. A delver who reaches floor 35 is sent around by Eros herself — and on the second climb, the pretence ends: she has met the goddess, been handed back, and now knows there is no exit, only the loop. From the second cycle onward, the clergy stop pretending with this delver.

**Syn delivers it**, confirming what the delver has already half-guessed — she is proud of the work, and tired of euphemisms with someone who has seen the throne. The reveal is therefore personal rather than proclaimed: one delver at a time, at the moment they have earned the truth by surviving it. Before that moment, the language rule above holds absolutely. After it, Syn and Berry may call the place the temple to that delver.

## Ask About the Bosses

**Talk to Berry** and **Talk to Syn** buttons on the quest board and at the parlour open a conversation screen for each fairy. Defeating or satisfying a boss unlocks that boss as a topic with both of them. The conversation menu currently holds 17 topics (10 general, 7 bosses); Discord select menus allow 25 options, so there is room to grow.

The same boss should produce different conversations depending on who is asked:

- **Berry** gives the domestic, emotional, and relationship-focused view. She is open about jealousy, affection, discomfort, and devotion.
- **Syn** gives more of the temple's history and explains how the boss contributed to building it, while also revealing her own flirtatious history and professional relationships.

The Alpha Beast is the exception to their disagreement: both Syn and Berry adore him and regard him as a very good boy.

The unlock is based on the bosses the player has defeated or satisfied (the `bosses_seen` record). Either path opens the topic — but **satisfying a boss unlocks extra**: Syn and Berry both have additional things to say about a delver who pleased a lord rather than merely beating them, and satisfying is always the version they ask about first. Conversations can be repeated freely, and the fairies remember previous conversations (see Repeats, Memory & Cycles, below). General topics also unlock from experience — first monster defeated, first trap, first curse, first mark, first hybrid form, first altar offering, first completed cycle.

### After the Reveal

Once a delver has been returned from floor 35 and Syn has confirmed the truth (second cycle onward), boss conversations gain **full revealed variants** — second versions of the topics, not extra lines:

- **Syn speaks as a builder.** The euphemisms end. She can call it the temple, name what each boss contributed, tell founding history, and discuss the clergy as clergy. Her revealed variants are where the temple's real history lives.
- **Berry stays Berry.** She may say "temple" now, and she stops pretending not to know — but she does not become a lore source. Her revealed variants stay domestic: the same wife-and-shopkeeper gossip, finally allowed its proper nouns. Marriage still wins the room over ministry.

### Repeats, Memory & Cycles

The fairies **remember being asked**. A topic's first answer is the full one; asking again gets a shorter, familiar version — a summary with the warmth (or the barb) left in, and occasionally an acknowledgment that this delver has asked before. Nobody delivers the same speech twice at someone they recognise.

Depth also grows with cycles as a **soft continuum** — every cycle a little more warmth and sharpness, not hard tier gates. Beyond the reveal variants, Syn and Berry stop treating the delver as a customer and start treating them as a regular: more history from Syn, more unguarded domestic truth from Berry, and opinions updated by everything the delver has survived. The conversation system should feel like a relationship with a memory, because in-world it is one.

### After meeting Eros — expansion plan

Once a delver has met Eros (and Syn has confirmed the temple), conversations grow in three directions over time:

1. **Eros** and **the cycles** as plain topics — Syn may **hint** at the launch/battery; she never spells out soft apocalypse. Berry stays domestic about the goddess.
2. **Residents** as Ask-about topics — **implementation priority #1** when expanding the menu (checklist below).
3. Boss talk gains **“she sent you back”** colour: fairy addenda *and* victory-screen nods from lords who notice a thrice-returned delver.

Menu organisation aims at **categories** (General / Clergy / Residents / Eros) rather than one flat list of 25.

### Residents Ask-abouts — implementation checklist

- **Rollout:** omnibus **“the Residents”** topic first; individual topics later (Vex, Pip, Nectar, Fang, Covar, then Lacta).
- **Unlock:** meet → short answer; finish their story / key beat → deep answer.
- **Reveal variants:** yes — post-temple-reveal diction (`temple`, clergy context) on these topics too.
- **Extras:** story-path hooks (restored Vex, Queen’s note for Pip, etc.), not boss-satisfy logic.

**Syn’s angles:** Vex = Original pride/guilt · Pip = trap-fangirl cute · Nectar = pope-energy awkward · Fang = tease floor secrets · Covar = little brother · Lacta = Nectar’s spare.

**Berry’s angles:** Vex = friend she likes · Pip = put pants on · Nectar = holy but weird · Fang = quiet map boy · Covar = sweet family · Lacta = polite nod.

### Do the Bosses Know?

Yes. Of course they know. The fairies are infamous, delvers repeat things, and several of the lords have heard their own descriptions quoted back at them by flushed delvers who thought they were being clever. Most of the clergy find the gossip mill flattering or funny — in a temple this size, being talked about at the shop is a form of worship too — and nobody with any sense expected Syn, of all people, to keep her opinions private. Berry is the only one who occasionally feels guilty about specific sentences, usually the true ones.

### After a Delver Has Met Eros

Meeting Eros changes how the fairies talk about her — not into casualness, but into **shared experience**. The reverence stays exactly where it was; what changes is that the delver is no longer outside it. Both fairies will ask what she said and what she did, compare it against everything they believe, and speak about the goddess the way people speak about a person they all, now, have in common. Syn in particular finally discusses Eros as someone she *serves* — a person with reactions, preferences, and a sense of humour about her temple — rather than as the mystery at the top of the stairs. It is the closest thing to a promotion the conversation system has: from customer, to regular, to fellow witness.
