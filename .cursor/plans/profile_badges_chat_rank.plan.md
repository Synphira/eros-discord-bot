---
name: Profile select, badges, chat rank
overview: "Replace the profile button rows with one select menu, add event badges plus developer and debugger badges, add a second developer who cannot take the Syn set or The Original Syn, and add a support-server-only chat rank earned from messages, voice time, and streaming."
todos:
  - id: profile-select
    content: Replace attach_nav button rows with one string select, and keep the old button handlers so panels already on screen still open
    status: pending
  - id: co-developer
    content: Add co-developer 266358927401287680 beside DEVELOPER_ID. Owner-only stays The Original Syn, Syn Fae, and the Syn gear. Dev commands stay open to both.
    status: pending
  - id: badge-catalog
    content: Add lib/engine/badges.rb, grant season badges from existing trackers, sync developer and debugger badges from role, and show every held badge on the profile in place of keepsakes
    status: pending
  - id: badge-page
    content: Add a Badges option on the profile select that lists every season badge, earned and still locked
    status: pending
  - id: chat-rank-store
    content: Add a chat_ranks table, a support-guild message listener with a cooldown, and voice-time plus stream XP from VoiceStateUpdate, separate from tower level
    status: pending
  - id: chat-rank-command
    content: Add prefix-only e,rank, silent outside the support server, and exempt it from the NSFW prefix gate inside that server
    status: pending
  - id: chat-rank-card
    content: Render the rank as a components card with the speaker's avatar thumbnail and an XP bar, falling back to text if the avatar URL is missing
    status: pending
  - id: syn-set-commands
    content: Add owner-only e,dev syn to grant and wear the whole Syn set, and e,dev synlock to skip cursed auto-equip and keep that set through defeat
    status: completed
isProject: false
---

# Profile select, event badges, and support-server chat rank

Four slices. The select comes first because the profile nav is already at Discord's five-buttons-per-row cap, and Badges needs a destination. Badges reuse seasonal trackers that already exist, plus two staff marks. A second developer can use `e,dev` and wear the developer badge, and cannot take the Syn set or **The Original Syn**. Chat rank is a different number from tower level and lives only in the support server.

## Profile command becomes a select

[`commands/status.rb`](commands/status.rb) already did this. `status_nav` is one `string_select` (`eros:status:goto:USER`) with the comment that a select keeps the sheet short on mobile. Profile should follow that shape.

[`Commands::Profile.attach_nav`](commands/profile.rb) currently paints two action rows:

- Profile, Titles, Achievements, Hybrids, Leaderboard (five buttons, the row is full)
- Collections, plus Rename and Parlour on your own profile

Callers: `show_profile`, `show_collections`, `show_titles`, `show_achievements`, `show_leaderboard`, and both hybrid panels in [`commands/transformation.rb`](commands/transformation.rb).

Replace both rows with one select, custom id `eros:profile:goto:USER`.

| Option | Value | Opens |
| --- | --- | --- |
| Profile | `profile` | `show_profile` |
| Titles | `titles` | `show_titles` |
| Achievements | `achievements` | `show_achievements` |
| Hybrids | `hybrids` | `Commands::Transformation.show` |
| Collections | `collections` | `show_collections` |
| Badges | `badges` | the new badges page (slice 2) |
| Leaderboard | `leaderboard` | `show_leaderboard` |
| Parlour | `parlour` | `Commands::Parlour.show` |
| Rename | `rename` | the existing name modal |

Mark the current page `default: true`, the way status does. Rename and Parlour only appear on your own profile. Rename answers the interaction with `ErosUI.show_name_modal` and does not also edit the panel. Discord allows one response, and a modal is that response.

Rules that stay:

- Someone else's profile stays a static card. `attach_nav` is already skipped unless the profile is your own (`rename: own`). The select follows that.
- Prev / Next pager buttons stay. They page inside a section. The leaderboard's stat pager stays too. Those are not section navigation.
- The title-equip select and the achievement-category select stay. They already do a different job.
- Keepsake pin buttons do not stay. Pins only existed to choose which three showed on the profile, and the profile no longer shows keepsakes.
- A collections page can stack up to five pin rows, a pager row, and this select. Components v2 allows that. The old five-action-row cap is why the section list itself has to be a select.
- Leave the existing `eros:profile:view`, `eros:titles:view`, `eros:achievements:view`, `eros:hybrid:view`, `eros:collections:view`, `eros:lb:open`, `eros:profile:rename`, and `eros:parlour:view` button handlers registered. Messages already on screen keep working. New panels simply stop rendering those buttons.
- Copy that says "press **Rename**" (`show_profile`, `set_name` usage, the leaderboard name hint) should say the menu instead.

`/profile`, `/titles`, `/achievements`, `/leaderboard`, `/transformation`, and their `e,` twins stay. The select changes how you move between panels, not which commands exist.

## Event badges

Badges replace the keepsake line on the profile. Keepsakes stay in Collections and nowhere else.

- A title is one equipped name.
- A keepsake is a story object. The full list lives on the Collections page. The profile card does not show them, and nothing is pinned.
- A badge is a permanent "I was there" mark for one calendar season. It is added only by playing during that event. You can hold every season you have played since badges shipped. Every badge you hold is shown. There is no pin limit and no display cap.

Do not turn the existing seasonal souvenir titles into badges. Those stay the grind (`Masquerade Meat` and the rest in [`lib/engine/title_system.rb`](lib/engine/title_system.rb)). A badge is one per season, earned the first time any of that season's souvenir trackers becomes positive.

### Catalog

New [`lib/engine/badges.rb`](lib/engine/badges.rb). One entry per key in [`Seasons::PRIORITY`](lib/engine/seasons.rb):

`valentines`, `mardi_gras`, `easter`, `april_fools`, `may_day`, `midsummer`, `pride`, `labor_day`, `halloween`, `thanksgiving`, `christmas`, `new_year`.

Each entry has `key`, `name`, `emoji`, `season` (the pack's public name), and `trackers` (the keys that already count as playing that season).

Tracker sets come from the souvenir titles, plus the submit counter where a pack has one and no titles yet. Labor Day (`Pip's Slow Spell`) has `labor_day_submits` and no souvenir titles, so that counter is its set. The other eleven use the trackers already named on their four titles (submit, stash-eaten, and the two event counters). Copy the keys from `TitleSystem`. Do not invent a second set of counters.

Suggested marks, rewrite freely. The emoji is the profile display. The name is what the Badges page shows.

| Key | Name | Emoji |
| --- | --- | --- |
| valentines | Heartstring | 💘 |
| mardi_gras | Carnival | 🎭 |
| easter | Hare's Hunt | 🐇 |
| april_fools | Fool's Trap | 🃏 |
| may_day | Maypole | 🎀 |
| midsummer | Longest Day | ☀️ |
| pride | Parade | 🌈 |
| labor_day | Field Test | 🔧 |
| halloween | All Hallows | 🎃 |
| thanksgiving | The Feast | 🍗 |
| christmas | Yule | 🎁 |
| new_year | Midnight | 🥂 |

Two staff badges sit beside the seasons. They are not on the calendar, and a locked one is never listed. Someone who does not hold it does not see the row.

| Key | Name | Emoji | Who holds it |
| --- | --- | --- | --- |
| developer | Developer | 🖤 | `Engine::Dev.owner?` and each co-developer |
| debugger | Debugger | 🪲 | owner, each co-developer, and `Engine::Dev.bug_tester?` |

Labor Day's season badge already uses 🔧, so the debugger mark is a different glyph. Change it if you want.

The owner and each co-developer hold both staff badges. A bug tester who is not a developer holds only the debugger mark.

### Grant and store

A holiday badge is a permanent unlock. It is added when that delver plays during the event, and nothing takes it away afterward: not the season ending, not defeat, not `/restart`. While that season is the active one, opening the profile grants the badge if any of its counters is already positive, so progress made earlier in the same event still counts. Once the event is over, those old counters are not scanned. A delver who only played a past year does not receive the badge in the off-week. They receive it the next time that event is running and a mapped counter increases, or when they open the profile during that event with the counter already above zero.

Store the season key, never the tracker key. `remember!('badges', 'halloween')` appends to the array and ignores duplicates. Read them with `Array(tracker_hash['badges'])`. Do not read them through `Player#tracker`, which forces `to_i` and would turn the array into 0.

Keep `badges` out of `RUN_TRACKERS` and `CHARACTER_STORY_TRACKERS`. Then `/restart` and defeat leave the array alone, the same way titles and achievements survive. Do not write a path that deletes a season key.

Grant from one hook, not from every event file. At the end of `Player#bump_tracker!`, look up which badge lists that tracker. If one does, the new value is positive, and that season key is not already stored, `remember!` it. Those seasonal trackers already bump only while the pack is active. Also call `Badges.grant_active!` from the profile card, the Badges page, and `check_progress!`: if `Seasons.active` is one of these seasons and any of its counters is already positive, grant it. Do not scan counters for a season that is not active.

Staff badges are the exception to permanent. They follow the role, not the calendar. `remember!` only adds, and a removed tester should lose the mark. `Badges.sync_staff!(player)` runs from the profile view (and from `check_progress!`, which already awards **Sin Sculptor** and **Climax Checker**). It rewrites only the `developer` and `debugger` keys to match the roles above, and leaves every season key alone.

Season badges are not granted by `e,dev`. The staff ones follow the role, so there is nothing to hand out by hand. Forcing the calendar with `e,dev week` and then playing still counts as playing during the event, because the counters only move while that pack is the active one.

### Display

The profile card in [`commands/profile.rb`](commands/profile.rb) `show_profile` currently renders **Keepsakes** from `displayed_keepsakes` (pinned ones, or the latest if nothing is pinned), with a hint to pin favourites. Remove that block. In its place, one **Badges** line when they hold any:

**Badges** followed by every held emoji: staff first (`developer`, then `debugger`), then `Seasons::PRIORITY`.

No cap. Twelve seasons plus both staff marks is still one short line, and a later badge is shown the same way. Do not add a pin shelf, a "latest three," or a truncation. Looking up another delver shows their earned emoji on that same line, staff marks included.

Collections (`show_collections`) stays the only place a keepsake is listed. Drop the pin count from the header, the 📌 marks, the "pin up to three" hint, and the Pin / Unpin buttons. The page is the list: emoji and text, paged as it is now (`KEEPSAKES_PER_PAGE`). Leave `keepsake_pins` data where it is. Nothing reads it. Do not write a migration to wipe it.

The Badges page (select value `badges`) lists every season. Earned ones show emoji, name, and season. Locked ones show the season name and "not earned" with no tracker counts, so the page is a calendar, not a strategy guide. Staff badges appear on that page only when held, with no locked row and no hint that they exist. Own profile only for the page. Another delver has no Badges menu; their marks are the emoji on the card.

No `/badges` slash command. The page lives on the profile select. `e,profile` remains the way in.

Changelogs: `CHANGELOG.md` when the badges actually grant and show, and when keepsakes leave the profile card. `DISCORD_CHANGELOG.md` only once a delver can see a season badge on a profile. Do not announce the tracker list, the staff badges, or the second id.

## Second developer, and the Syn set

Today one id is the owner. [`Engine::Dev.developer_id`](lib/engine/dev.rb) reads `DEVELOPER_ID`. `owner?` is that id. `developer?` is the owner or anyone in `BUG_TESTER_IDS`, and that is who may run `e,dev`. `Player#progress_value(:is_developer)` is `owner?`, so **The Original Syn**, **Sin Sculptor**, and the **Syn Fae** form stay on the owner. [`Player#equip_item`](lib/models/player.rb) refuses `dev_only` gear to anyone else.

Add a co-developer without widening `owner?`.

- Constant `Engine::Dev::CO_DEVELOPER_IDS = [266_358_927_401_287_680]`, plus optional `CO_DEVELOPER_IDS` in `.env` (comma-separated) merged in, the way `BUG_TESTER_IDS` already parses.
- `co_developer?(user_id)` is membership in that list.
- `developer?` becomes owner or co-developer or bug tester. Both developers and the testers keep `e,dev`.
- `owner?` and `:is_developer` stay the single `DEVELOPER_ID`. **The Original Syn**, **Sin Sculptor**, and **Syn Fae** do not move.

The co-developer gets the developer badge and the dev command list. They do not get the Syn equipment set or **The Original Syn**. That pair stays the owner's, because Syn is based on them.

Close the command holes that would hand those out anyway:

- [`grant_equipment!`](lib/models/player.rb) refuses a `dev_only` item before insert unless `owner?`. Today the check is only inside `equip_item`, so `e,dev item` can still drop the pieces into a pack.
- `e,dev title original_syn`, and `original_syn` inside `e,dev title all`, refuse unless the acting user is the owner.
- `e,dev hybrid syn_fae`, and `syn_fae` inside `e,dev hybrid all`, refuse the same way. The form is already owner-only through `:is_developer`. The command must not bypass that for the new id.

`e,dev title sin_sculptor` can still be forced by anyone with dev access. Automatic award of that title stays owner-only.

### `e,dev syn`

Owner only. Anyone else with dev access gets the same refusal the gear already uses: it recognises one maker.

[`Wardrobe::DEV_GEAR`](lib/engine/wardrobe.rb) is the whole set. Seven pieces, `cursed: false`, `dev_only: true`:

- Syn's Cursed Ink Needle (weapon)
- Syn's Smudged Tiara (head)
- Syn's Lace Scraps (chest)
- Syn's Garter of Vials (legs)
- Syn's Smoked-Glass Wings (accessory)
- Syn's Belled Heels (feet)
- Syn's Tower-Script Thong (groin)

The command grants any missing piece and equips all seven. If a cursed piece is in one of those slots, lift it into the pack (`is_equipped` false). Do not delete it, do not charge LP, and do not run the Cursed Shop unlock. Then equip the Syn piece. Report each piece in one reply.

Document it on the `HELP` string in [`commands/dev.rb`](commands/dev.rb). No slash command.

### `e,dev synlock`

Owner only. Toggles a tracker `syn_lock` between 0 and 1. It is not in `RUN_TRACKERS` or `CHARACTER_STORY_TRACKERS`, so defeat and `/restart` keep it. In-memory like debug mode would forget the lock every boot, which fails the point.

While `syn_lock` is on, two things change, and only for the owner:

1. **Cursed gear does not auto-equip.** [`grant_equipment!`](lib/models/player.rb) equips when `auto_equip` is set or `item.cursed` is true. Living gear uses that second path and takes the slot, and `equip_item` will not put a Syn piece on over it without `e,remove`. With the lock on, a cursed grant still adds the item to the pack and skips that equip. A manual `e,equip` of living gear still works. Ordinary non-cursed auto-equip still works.
2. **Defeat does not delete the set.** `reset_run!` calls `strip_non_cursed_equipment!`, and that **deletes** every non-cursed row except holiday outfits. The Syn pieces are not cursed, so a defeat currently destroys them. With the lock on, rows whose `stat_modifiers` include `dev_only` are left owned and left equipped. Holiday outfits stay on their own rule.

With the lock off, both paths behave as they do now.

`e,dev info` includes `syn lock on/off` next to the debug flag so you can see it.

These two commands are operator-only. `CHANGELOG.md` gets a short ops line. `DISCORD_CHANGELOG.md` stays quiet.

## Support-server chat rank

This is not tower level. `players.level` and `/levelup` stay the delver's LP level. Chat rank never pays LP, never writes a player row, and never appears on `/profile` or `/status`.

It counts chat in the support guild only. [`Engine::SupportBonuses.guild_id`](lib/engine/support_bonuses.rb) is that guild (`SUPPORT_GUILD_ID`, else `ERROR_GUILD_ID`, else the baked-in id). Someone with no delver can still have a rank. Someone who `/restart`s keeps it.

### Table

Migration `db/migrations/019_add_chat_ranks.rb`:

- `discord_id` `Bignum` primary key, same type as `players.discord_id`
- `xp` integer, default 0
- `messages` integer, default 0 (awarding messages, not every line)
- `voice_minutes` integer, default 0 (whole minutes sat in a counted voice channel)
- `stream_minutes` integer, default 0 (whole minutes of those where Go Live was on)
- `last_award_at` datetime, null (chat cooldown only; voice does not use it)

No `level` column. Derive it from `xp` so the two cannot drift.

Model `ChatRank` in `lib/models/chat_rank.rb`, required next to `Player`.

### What earns XP

A `bot.message` listener in `commands/chat_rank.rb`, included from [`bot.rb`](bot.rb).

Count the message when all of these hold:

- It has a server, and `server.id == SupportBonuses.guild_id`.
- The author is not a bot.
- Content is present and does not start with the command prefix (`e,` / `E,`, or `BOT_PREFIX`). A rank lookup must not also grant XP.

Then apply a 60-second cooldown per discord id, using `last_award_at`. Messages inside the cooldown are ignored, including after a restart once the timestamp is in the table. Award `15 + rand(11)` XP (15 through 25) and increment `messages`.

One upsert-style write: insert the row if missing, otherwise add. Two messages in the same second can lose one award. The cooldown makes that rare enough to leave.

Do not count DMs, other guilds, or the bot's own guild-log posts (those authors are bots).

### Voice time and streaming

Same XP pool, same support guild, same "no delver required" rule. Sitting in voice does not write a player row and does not pay LP.

[`bot.rb`](bot.rb) does not request `:server_voice_states` today (the intent list is `:servers`, `:server_messages`, `:direct_messages`, plus `:server_members` when presence asks for it). Add `:server_voice_states`. It is unprivileged (`1 << 7` in discordrb's `INTENTS`). Without it, Discord will not send other people's `VOICE_STATE_UPDATE`, and the rank cannot see the channel.

Listen with `bot.voice_state_update` in `commands/chat_rank.rb`. Ignore bots, ignore every guild that is not `SupportBonuses.guild_id`, and ignore the guild AFK channel (`server.afk_channel`). A stage channel still counts. Mute, deaf, and suppressed still count: the award is for being in the channel, not for talking. Camera (`self_video`) is not the bonus. Only Go Live is.

discordrb 3.8's `VoiceStateUpdateEvent` never reads `self_stream`. The payload has it; the event drops it on the floor. Prepend the event's `initialize` and keep `@self_stream` from `data['self_stream']`. Do not fork the gem.

Sessions live in memory, keyed by discord id: channel id, whether Go Live is on, voice seconds not yet paid, stream seconds not yet paid, and the last mark time. No session table.

- Join a counted channel, or return from AFK: start a session at `Time.now`. Do not back-pay time from before the bot noticed.
- Leave, disconnect, or move to AFK: pay whole minutes, drop the leftover seconds, delete the session. Hopping channels must not mint XP.
- Move between two counted channels: keep the session and the unpaid seconds. The channel id changes. The clock does not reset.
- Go Live flips on or off: keep the unpaid seconds. Seconds from the last mark until now count as stream seconds only when the flag was on for that stretch. Then keep going at the new flag.

A single timer every 60 seconds walks the sessions. For each one still in a counted channel, add the elapsed seconds, then pay `voice_seconds / 60` minutes and `stream_seconds / 60` minutes. One voice minute is **10 XP** and increments `voice_minutes`. One stream minute is **+10 XP** on top and increments `stream_minutes`. Stream time is a subset of voice time, so one minute of Go Live is 20 XP (10 for sitting there, 10 for the stream), and one quiet minute is 10 XP.

Leftover seconds stay in memory until the next tick or a real leave. A bot restart drops them. On ready, seed a session at `Time.now` for each non-bot already in a counted channel on the support guild (`server.voice_states`, which `GUILD_CREATE` fills when the voice intent is on). Do not invent minutes for the outage.

Rates sit next to chat. A message is 15–25 XP and cannot fire more than once a minute, so a person talking in chat and a person sitting in voice earn the same order of XP. Change the 10 / +10 if that feels wrong. Do not pay a fractional minute.

### Curve

Level starts at 1 with 0 XP. XP to go from level `L` to `L + 1` is `100 + (L - 1) * 40`.

- 1 → 2 costs 100 (about five messages)
- 2 → 3 costs 140
- 10 → 11 costs 460

`level_for(xp)` walks that cost until the remaining XP is short. `xp_into_level` and `xp_for_next` feed the bar. No prestige, no role rewards, no tower effect in this slice.

### Command

Prefix only: `e,rank`, with an optional user.

- `e,rank` shows the speaker.
- `e,rank @user` shows that mention (`event.message.mentions`).
- A reply's author is the target when there is no mention.

Do not register it in [`config/slash_commands.rb`](config/slash_commands.rb). Document it like `e,sluttify`: a help row whose slash column is `—`, and a line in [`Wiki/Commands.md`](Wiki/Commands.md).

Where it answers:

- Inside the support guild, it answers.
- Everywhere else, including DMs and NSFW tower channels, it returns `nil` and says nothing.

The prefix gate in [`bot.rb`](bot.rb) (`ErosPrefixGate`) drops every prefix command in a non-NSFW channel before the command body runs. The support server is not guaranteed to be age-restricted (`nsfw_level` 3) or to mark its general chat NSFW, so `e,rank` would never fire there. Exempt this one command from that gate when `event.server.id` is the support guild. The command body still refuses every other guild. Slash commands and the rest of the prefix list stay gated.

A looked-up user with no row gets a card at level 1, 0 XP, and a line that they have not earned any rank yet. Do not invent a row until a message or a paid voice minute actually awards XP.

### The card

discordrb 3.8 (what the Gemfile resolves) can build this without a new gem. `ContainerBuilder` has `section` + `thumbnail`, and `ErosUI` containers are already how every panel is drawn. A generated PNG is the heavier option, and it is the one to skip for this slice.

The rank reply is a components container, colour `0xd4af37` (the profile gold):

- A section whose accessory is the target's avatar thumbnail (`cdn.discordapp.com/avatars/...` at size 128, or Discord's default embed avatar when they have none). `ErosUI.reply_v2` yields a container and does not expose `thumbnail` today, so this command builds that one section on the container directly, or a tiny helper is added beside `reply_v2`. Prefer the helper if transformation and profile would also want an avatar later. This slice only needs it for rank.
- Display name (global name, then username). If they have a delver, one quiet line with the character name under it. The rank is still the chat rank.
- **Chat level N** and a bar in the same shape as `ErosUI.threat_bar`, filled from `xp_into_level / xp_for_next`.
- One footer line: awarding messages, voice minutes, and stream minutes. Their place is not a leaderboard. No top-10 in this slice. A looked-up user who has only sat in voice still gets a card; the "has not spoken" line is only when messages, voice minutes, and stream minutes are all zero.

If the thumbnail URL cannot be built, send the same text with no section accessory. The command still answers.

### Why not a rendered image yet

A PNG card (background, cropped avatar, custom type) needs an image library and a file upload. `ErosUI.reply_v2` does not attach files. discordrb's container does have a `file` component (`attachment://...`) and a `media_gallery`, so a later slice can upload `chat-rank.png` and point a file component at it without leaving components v2.

If that slice happens, use ChunkyPNG. It is pure Ruby and does not put ImageMagick on the host. Skip RMagick. Keep the text-and-thumbnail card as the fallback when the file upload fails.

That later slice is out of scope until the thumbnail card has been seen in the support server and still feels too plain.

### Intent note

[`bot.rb`](bot.rb) requests `:servers`, `:server_messages`, and `:direct_messages`. discordrb 3.8's `INTENTS` hash stops at bit 14 and has no `:message_content` symbol. Bit 15 is Discord's privileged Message Content intent.

The listener can see author and guild from `server_messages` alone. Skipping `e,` lines needs `event.content`. Prefix commands in guilds already need that content. Before shipping the listener, confirm a guild message's content is non-empty in a log line. If it is empty, enable Message Content in the developer portal and identify with the current intent bits OR'd with `1 << 15`. Do not pass the symbol `:message_content` into discordrb 3.8. It is not in `INTENTS`, and `calculate_intents` would drop it.

Voice does not need Message Content. It needs `:server_voice_states` on the same intent list. That symbol exists in discordrb 3.8. No portal privilege toggle.

## Build order

1. Select menu in `attach_nav`, handler `eros:profile:goto`, old button handlers left in place. Badges option hidden until the page exists, or present and opening a one-line empty state. Ship this on its own so the nav can be clicked before badges and rank exist.
2. Co-developer id, owner checks on `grant_equipment!` and on `e,dev title` / `e,dev hybrid` for **The Original Syn** and **Syn Fae**. Then `e,dev syn` and `e,dev synlock`.
3. `Badges` catalog, `bump_tracker!` hook, staff sync, backfill, profile line, Badges page on the select.
4. Migration, `ChatRank`, message listener, voice-state listener and minute timer, `:server_voice_states`, `e,rank`, NSFW-gate exemption, thumbnail card, help and wiki lines.

`CHANGELOG.md` entries land with the slice a delver can see (the select, then badges, then `e,rank`). `DISCORD_CHANGELOG.md` waits until a slice is visible in the tower or the support server, and it does not explain the XP formula. Chat rank is support-server only, so its paste belongs in the support server rather than the tower-update changelog if those audiences differ. Until that channel split exists, one `DISCORD_CHANGELOG.md` block for `e,rank` is enough.

No web work. This checkout has no `webapp/`, and chat rank depends on Discord guild messages the web version never sees.
