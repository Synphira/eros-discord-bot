---
name: Profile select, badges, chat rank
overview: "Replace the profile button rows with one select menu, add event badges earned from the seasons already in the tower, and add a support-server-only chat rank with a prefix command and a components card."
todos:
  - id: profile-select
    content: Replace attach_nav button rows with one string select, and keep the old button handlers so panels already on screen still open
    status: pending
  - id: badge-catalog
    content: Add lib/engine/badges.rb, grant from existing seasonal trackers, backfill on profile view, and show earned badges on the profile
    status: pending
  - id: badge-page
    content: Add a Badges option on the profile select that lists every season badge, earned and still locked
    status: pending
  - id: chat-rank-store
    content: Add a chat_ranks table and a support-guild message listener with a cooldown, separate from tower level
    status: pending
  - id: chat-rank-command
    content: Add prefix-only e,rank, silent outside the support server, and exempt it from the NSFW prefix gate inside that server
    status: pending
  - id: chat-rank-card
    content: Render the rank as a components card with the speaker's avatar thumbnail and an XP bar, falling back to text if the avatar URL is missing
    status: pending
isProject: false
---

# Profile select, event badges, and support-server chat rank

Three slices. The select comes first because the profile nav is already at Discord's five-buttons-per-row cap, and Badges needs a destination. Badges reuse seasonal trackers that already exist. Chat rank is a different number from tower level and lives only in the support server.

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
- The title-equip select, the achievement-category select, and the keepsake pin buttons stay. They already do a different job.
- A collections page can stack up to five pin rows, a pager row, and this select. Components v2 allows that. The old five-action-row cap is why the section list itself has to be a select.
- Leave the existing `eros:profile:view`, `eros:titles:view`, `eros:achievements:view`, `eros:hybrid:view`, `eros:collections:view`, `eros:lb:open`, `eros:profile:rename`, and `eros:parlour:view` button handlers registered. Messages already on screen keep working. New panels simply stop rendering those buttons.
- Copy that says "press **Rename**" (`show_profile`, `set_name` usage, the leaderboard name hint) should say the menu instead.

`/profile`, `/titles`, `/achievements`, `/leaderboard`, `/transformation`, and their `e,` twins stay. The select changes how you move between panels, not which commands exist.

## Event badges

Badges are a third shelf, beside titles and keepsakes.

- A title is one equipped name.
- A keepsake is a story object, pinned up to three.
- A badge is a small "I was there" mark for a calendar season. You can hold every season you have actually played. They are not equipped one at a time.

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

### Grant, store, backfill

Store the season key, never the tracker key. `remember!('badges', 'halloween')` appends to the array and ignores duplicates. Read them with `Array(tracker_hash['badges'])`. Do not read them through `Player#tracker`, which forces `to_i` and would turn the array into 0.

Keep `badges` out of `RUN_TRACKERS` and `CHARACTER_STORY_TRACKERS`. Then `/restart` and defeat leave them alone, the same way titles and achievements survive.

Grant from one hook, not from every event file. At the end of `Player#bump_tracker!`, look up which badge lists that tracker. If one does, the new value is positive, and that season key is not already stored, `remember!` it. Those seasonal trackers already bump only while the pack is active (`note_submit!` and the event counters say so), so the hook does not need its own calendar check. A later out-of-season read of an old counter must not grant. The hook only runs when the counter increases.

Backfill on your own profile view, same moment as `backfill_story_keepsakes!`: if any mapped tracker is already positive, grant the badge. Delvers who played a season before this ships still have the mark.

No dev grant in the first slice unless `e,dev` already has a nearby "give title" path worth mirroring. Operators can wait.

### Display

On the profile header, under keepsakes, one line when they have any:

**Badges** followed by the emoji in `Seasons::PRIORITY` order.

Show all of them. Twelve fit on a line, so there is no pin limit in this slice. A pin shelf can wait until the catalog outgrows one line.

The Badges page (select value `badges`) lists every catalog entry. Earned ones show emoji, name, and season. Locked ones show the season name and "not earned" with no tracker counts, so the page is a calendar, not a strategy guide. Own profile only. Looking up another delver shows their earned emoji on the card and no Badges menu.

No `/badges` slash command. The page lives on the profile select. `e,profile` remains the way in.

Changelogs: `CHANGELOG.md` when the badges actually grant and show. `DISCORD_CHANGELOG.md` only once a delver can see one on a profile. Do not announce the tracker list.

## Support-server chat rank

This is not tower level. `players.level` and `/levelup` stay the delver's LP level. Chat rank never pays LP, never writes a player row, and never appears on `/profile` or `/status`.

It counts chat in the support guild only. [`Engine::SupportBonuses.guild_id`](lib/engine/support_bonuses.rb) is that guild (`SUPPORT_GUILD_ID`, else `ERROR_GUILD_ID`, else the baked-in id). Someone with no delver can still have a rank. Someone who `/restart`s keeps it.

### Table

Migration `db/migrations/019_add_chat_ranks.rb`:

- `discord_id` `Bignum` primary key, same type as `players.discord_id`
- `xp` integer, default 0
- `messages` integer, default 0 (awarding messages, not every line)
- `last_award_at` datetime, null

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

A looked-up user with no row gets a card at level 1, 0 XP, and the line that they have not spoken in the server yet. Do not invent a row until they earn XP.

### The card

discordrb 3.8 (what the Gemfile resolves) can build this without a new gem. `ContainerBuilder` has `section` + `thumbnail`, and `ErosUI` containers are already how every panel is drawn. A generated PNG is the heavier option, and it is the one to skip for this slice.

The rank reply is a components container, colour `0xd4af37` (the profile gold):

- A section whose accessory is the target's avatar thumbnail (`cdn.discordapp.com/avatars/...` at size 128, or Discord's default embed avatar when they have none). `ErosUI.reply_v2` yields a container and does not expose `thumbnail` today, so this command builds that one section on the container directly, or a tiny helper is added beside `reply_v2`. Prefer the helper if transformation and profile would also want an avatar later. This slice only needs it for rank.
- Display name (global name, then username). If they have a delver, one quiet line with the character name under it. The rank is still the chat rank.
- **Chat level N** and a bar in the same shape as `ErosUI.threat_bar`, filled from `xp_into_level / xp_for_next`.
- One footer line: awarding messages, and their place is not a leaderboard. No top-10 in this slice.

If the thumbnail URL cannot be built, send the same text with no section accessory. The command still answers.

### Why not a rendered image yet

A PNG card (background, cropped avatar, custom type) needs an image library and a file upload. `ErosUI.reply_v2` does not attach files. discordrb's container does have a `file` component (`attachment://...`) and a `media_gallery`, so a later slice can upload `chat-rank.png` and point a file component at it without leaving components v2.

If that slice happens, use ChunkyPNG. It is pure Ruby and does not put ImageMagick on the host. Skip RMagick. Keep the text-and-thumbnail card as the fallback when the file upload fails.

That later slice is out of scope until the thumbnail card has been seen in the support server and still feels too plain.

### Intent note

[`bot.rb`](bot.rb) requests `:servers`, `:server_messages`, and `:direct_messages`. discordrb 3.8's `INTENTS` hash stops at bit 14 and has no `:message_content` symbol. Bit 15 is Discord's privileged Message Content intent.

The listener can see author and guild from `server_messages` alone. Skipping `e,` lines needs `event.content`. Prefix commands in guilds already need that content. Before shipping the listener, confirm a guild message's content is non-empty in a log line. If it is empty, enable Message Content in the developer portal and identify with the current intent bits OR'd with `1 << 15`. Do not pass the symbol `:message_content` into discordrb 3.8. It is not in `INTENTS`, and `calculate_intents` would drop it.

## Build order

1. Select menu in `attach_nav`, handler `eros:profile:goto`, old button handlers left in place. Badges option hidden until the page exists, or present and opening a one-line empty state. Ship this on its own so the nav can be clicked before badges and rank exist.
2. `Badges` catalog, `bump_tracker!` hook, backfill, profile line, Badges page on the select.
3. Migration, `ChatRank`, listener, `e,rank`, NSFW-gate exemption, thumbnail card, help and wiki lines.

`CHANGELOG.md` entries land with the slice a delver can see (the select, then badges, then `e,rank`). `DISCORD_CHANGELOG.md` waits until a slice is visible in the tower or the support server, and it does not explain the XP formula. Chat rank is support-server only, so its paste belongs in the support server rather than the tower-update changelog if those audiences differ. Until that channel split exists, one `DISCORD_CHANGELOG.md` block for `e,rank` is enough.

No web work. This checkout has no `webapp/`, and chat rank depends on Discord guild messages the web version never sees.
