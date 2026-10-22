# frozen_string_literal: true

module Engine
  # The delver's journal: lore fragments earned by living in the tower.
  # Nothing here is bought or rolled — every entry unlocks from something
  # the delver has actually done, seen, or survived. Before the Temple
  # Reveal the journal keeps the shop's coy language; after it, the same
  # entries tell the truth.
  module Codex
    module_function

    BOSS_FRAGMENTS = {
      'Mimic Broodmother' => {
        title: 'The Broodmother — Appetite', emoji: '🧰',
        want: 'She wants delvers *inside* — kept, fed on, added to the brood, treasured the way she ' \
              'treasures everything she has ever swallowed. Being eaten by her furniture is not an ' \
              'accident of the domain. It is the domain.',
        clergy: 'One of the seven clergy who built this temple. She made no traps and cast no spells; ' \
                'she simply moved in, and the first five floors arranged themselves around her hunger.'
      },
      'Succubus Queen' => {
        title: 'The Succubus Queen — The Court', emoji: '👑',
        want: 'She wants to be *chosen* — remembered, returned to, picked out of every delight the ' \
              'tower offers and told she was the best of them. Flattery is her tribute and repeat ' \
              'visits are her love language.',
        clergy: 'One of the seven clergy who built this temple. With Syn she designed the traps — ' \
                'which is to say, the court contributed half of everything that has ever caught you.'
      },
      'Incubus King' => {
        title: 'The Incubus King — The Claim', emoji: '😈',
        want: 'He wants the claim: your name in his mouth, your knees deciding before your head does. ' \
              'Everything in his domain is already his. A delver is just the part that has not ' \
              'admitted it yet.',
        clergy: 'One of the seven clergy who built this temple. With Syn he worked the spawning spell ' \
                'that populates the floors — the monsters are, in a real sense, his children with her.'
      },
      'Verdant Dryad' => {
        title: 'The Verdant Dryad — The Garden', emoji: '🌿',
        want: 'She wants company, planted close and kept. Her vines are hospitality; her fruit is an ' \
              'invitation; the garden regrows the paths behind delvers so that leaving feels like ' \
              'the rude option.',
        clergy: 'One of the seven clergy who built this temple. The vine and tentacle traps everyone ' \
                'blames on Syn began as watching how the Dryad says hello.'
      },
      'Lich Lord' => {
        title: 'The Lich Lord — The Archive', emoji: '💀',
        want: 'He wants data and warmth: delvers catalogued, measured, filed — and, though he would ' \
              'never say it plainly, kept where his cold halls can feel them living.',
        clergy: 'One of the seven clergy who built this temple, and Syn\'s old teacher in the working ' \
                'of lust energy. The whole temple is, to him, an experiment that has not finished ' \
                'surprising him.'
      },
      'Alpha Beast' => {
        title: 'The Alpha Beast — The Pack', emoji: '🐺',
        want: 'He wants mates and a pack that comes back. Chase is courtship, weather is mood, and a ' \
              'delver who returns to his floors season after season is, as far as he is concerned, ' \
              'already family.',
        clergy: 'One of the seven clergy who built this temple, who joined because Syn asked him to. ' \
                'His consideration was the pack-room and mates to fill it.'
      },
      'Eros' => {
        title: 'Eros — The Throne', emoji: '🌹',
        want: 'She wants surrender itself — not defeat, not worship performed at a safe distance, but ' \
              'the moment a delver stops climbing *at* her and starts kneeling *to* her. That moment ' \
              'is the offering. Everything in the tower exists to produce it. Her throne sits over the ' \
              'source of the lust magic itself, and there is no exit past it: win, or surrender, and ' \
              '**Eros returns you herself**. Nobody walks out of the top of the tower. They are *let* ' \
              'down from it, the way a hand opens.',
        clergy: 'Not clergy. The goddess the temple was built to reach — distant for all the years of ' \
                'building, answering only in dreams and signs, until the cycles began and proved she ' \
                'had been listening after all.'
      }
    }.freeze

    RELIC_FRAGMENTS = {
      'Pale Bride' => {
        title: 'The Pale Bride — The Unclaimed Veil', emoji: '👰',
        text: 'Not clergy, not a ghost exactly: a bridal veil and gown that were offered to the ' \
              'goddess by someone who waited to be chosen and never was. Decades of offerings fed ' \
              'into it until the devotion outlived the devotee and learned to want back. When a ' \
              'throne stands empty, she holds it — still waiting to be picked, and no longer ' \
              'willing to be passed over quietly.'
      },
      'Empty Confessional' => {
        title: 'The Empty Confessional — The Kept Sins', emoji: '🪟',
        text: 'A confessional booth from the older worship, carried into the temple when the clergy ' \
              'built around the old site. A century of delvers knelt at its screen and whispered ' \
              'everything — and the booth kept it all, every sin filed in the dark behind the ' \
              'curtain, until the keeping itself learned to speak. It does not forgive, exactly. ' \
              'Forgiveness was never the part it practised.'
      },
      'Chalice That Never Empties' => {
        title: 'The Chalice That Never Empties — The Pouring', emoji: '🍷',
        text: 'Poured at altars since before the clergy had names for what they served, and never ' \
              'once drained: every offering ever tipped into it stayed, and learned, and became ' \
              'her. She is not the wine and not the cup. She is the pouring — the temple\'s oldest ' \
              'argument that devotion, properly given, only ever makes more of itself.'
      },
      'First Altar Stone' => {
        title: 'The First Altar Stone — The Beginning', emoji: '🪨',
        text: 'The oldest thing in the temple: the ruined altar a young, drifting Syn found in the ' \
              'wilds and knelt at, where the dreams began. The clergy carried it into the finished ' \
              'temple and set it in a floor like a foundation stone. It remembers being worshipped ' \
              'before there was anything to worship in — before the clergy, before the cycles, ' \
              'arguably before the goddess was listening. It is patient the way bedrock is patient.'
      },
      'Hoardheart Dragon' => {
        title: 'The Hoardheart Dragon — The Collection', emoji: '🐉',
        text: 'Dragons do not worship the way people do. One of the first delvers\' offerings to the ' \
              'young temple was a dragon\'s heart, given freely by something ancient that wanted to ' \
              'see what the goddess would build. The clergy caged it in a reliquary of its own hoard, ' \
              'and a century of offerings poured in around it — coins, crowns, chalices, delvers — ' \
              'until the hoard learned to be her body. She is not a dragon kept by the temple. She is ' \
              'what the temple\'s giving looks like, given scales.'
      },
      'Drowned Saint' => {
        title: 'The Drowned Saint — The Other Eldritch', emoji: '🐙',
        text: 'There are exactly two eldritch things in the temple: the goddess at the top, and this. ' \
              'What she was before the reliquary — a god of some drowned place, a piece of Eros shed ' \
              'and kept, a saint who drowned praying — the clergy either never knew or agreed never ' \
              'to write down. She is kept below, in dark water, and worshipped carefully. The family ' \
              'resemblance to the throne is obvious to anyone who survives both. Nobody who survives ' \
              'both talks about it the same way again.'
      },
      'Mirror Queen' => {
        title: 'The Mirror Queen — The Reflection', emoji: '🪞',
        text: 'A tall mirror from the older worship that stood on this site before the temple, ' \
              'which has reflected ten thousand delvers and, once or twice, the goddess herself. ' \
              'It kept every face it was ever shown and learned to wear them. She is not a queen; ' \
              'the crown is part of the frame. What she rules is the moment a delver recognises ' \
              'their own wanting looking back.'
      }
    }.freeze

    def revealed?(player)
      player.tracker('temple_revealed').positive?
    end

    def seen_bosses(player)
      Array(player.tracker_hash['bosses_seen']).map(&:to_s)
    end

    def entry(key, emoji, title, unlocked:, hint:, text: nil)
      { key: key, emoji: emoji, title: title, unlocked: unlocked, hint: hint, text: text }
    end

    def entries(player)
      rev = revealed?(player)
      seen = seen_bosses(player)
      list = []

      list << entry(
        'this_place', '🗼', 'This Place', unlocked: true, hint: nil,
        text: if rev
                'It is a **temple** — Eros\'s, built for her over decades by seven clergy on the site ' \
                'where a young Syn found a ruined altar of the goddess in the wilds. Syn recruited ' \
                'every one of the lords herself; each had known her before there was a temple at all. ' \
                'The building was raised whole, by clergy magic powered by lust energy. It was never ' \
                'meant to be a trial. It was meant to be a doorbell.'
              else
                'Thirty-five floors of hunger with a shop at the bottom and a goddess at the top, and ' \
                'nobody at the shop will call it anything but a tower. The floors change their minds ' \
                'about their shape. The bosses keep delvers the way other people keep appointments. ' \
                'Whatever this place is, it was *made* — that much even a newcomer can feel.'
              end
      )

      BOSS_FRAGMENTS.each do |boss_name, frag|
        unlocked = seen.include?(boss_name)
        text = nil
        if unlocked
          text = frag[:want]
          text += "\n\n#{frag[:clergy]}" if rev
        end
        list << entry(boss_name.downcase.gsub(/[^a-z]+/, '_'), frag[:emoji], frag[:title],
                      unlocked: unlocked, hint: "Face #{boss_name} (win or yield) to earn this fragment", text: text)
      end

      relic_seen = Array(player.tracker_hash['relic_bosses_seen']).map(&:to_s)
      RELIC_FRAGMENTS.each do |relic_name, frag|
        unlocked = relic_seen.include?(relic_name)
        list << entry(relic_name.downcase.gsub(/[^a-z]+/, '_'), frag[:emoji], frag[:title],
                      unlocked: unlocked,
                      hint: 'Face her when a throne stands empty (cycle 2+, boss floors)',
                      text: unlocked ? frag[:text] : nil)
      end

      list << entry(
        'the_fairies', '🍓', 'Berry & Syn', unlocked: true, hint: nil,
        text: 'Married before there was any of this — Berry the devout one, Syn the one who shrugs. ' \
              'Berry runs the quest board and believes every kind word the tower has ever told her. ' \
              'Syn inks skin at the parlour and deflects questions with the ease of long practice. ' \
              'Whatever they are not saying, they are not saying it together.' + (rev ? "\n\nSyn founded this temple. Berry, formally, is nothing here — a lay worshipper married to the founder — and her " \
              'authority is entirely personal. The clergy obey her because Syn\'s wife asked. It has never once not worked.' : '')
      )

      covar_unlocked = player.tracker('mimics_removed_count').positive? ||
                        Array(player.tracker_hash['covar_topics_heard']).any?
      list << entry(
        'covar', '🔮', 'Covar Zephyren', unlocked: covar_unlocked,
        hint: 'Tear free a piece of living gear, or find the Cursed Shop counter',
        text: 'One of the first delvers, changed by the tower into a large-breasted incubus — and, ' \
              'unlike most, delighted about it. He stayed by choice and keeps the Cursed Shop, ' \
              'matchmaking stray living gear to delvers who will appreciate it. Syn calls him her ' \
              'little brother. Berry calls him family. The tower calls him proof of concept.'
      )

      list << entry(
        'altars', '🕯️', 'Altars & Attention', unlocked: player.tracker('eros_attention').positive?,
        hint: 'Draw Eros\'s Attention — satisfy creatures, kneel at altars, wear marks',
        text: 'The altars are genuine: the clergy built them, and the goddess truly watches through ' \
              'them. Attention is literal — her regard, drawn by devotion and by delvers pleasing ' \
              'the tower well. Below the throne she never manifests in full; what visits is a ' \
              'tentacle, a voice, a warmth. Being noticed is the holiest and least safe thing here.'
      )

      list << entry(
        'the_changing', '🦋', 'Curses & Transformations', unlocked: player.tracker('curses_gained').positive? ||
                                                                  Array(player.unlocked_transformations).any?,
        hint: 'Gain a curse, or be transformed by the tower',
        text: 'Neither has an author. Curses are the dungeon\'s lust magic altering a delver from ' \
              'outside; transformations are the delver\'s own lust taking form from inside. Syn made ' \
              'the first living gear and the marks, and will happily take credit for those — but the ' \
              'changing itself is just what lust energy *does* to people here, the way weather does ' \
              'what it does to a coast.'
      )

      list << entry(
        'cycles', '🔄', 'The Cycles', unlocked: player.tracker('cycles_completed').positive?,
        hint: 'Return from floor 35 and begin again',
        text: if rev
                'The cycles are **Eros\'s own creation** — her answer to the finished temple. The ' \
                'clergy built a doorbell; she built the trap behind the door, turning delvers back to ' \
                'the bottom until they surrender. The clergy know the cycles are hers. It is their ' \
                'one proof she ever answered at all.'
              else
                'Beat the top and you wake at the bottom, stronger, marked, remembered. The fairies ' \
                'call it just how the tower is. The tower, notably, has never explained itself.'
              end
      )

      list << entry(
        'the_court', '💤', 'The Dreaming Court', unlocked: player.deepest_depth.to_i >= 31,
        hint: 'Reach floor 31',
        text: 'Floors 31–34 are her front garden: silk and candlelight breathing in and out of ' \
              'existence, altars surfacing like stones in a tide, the land reshaping almost as fast ' \
              'as it is looked at. Monsters thin out — her presence crowds out lesser hungers. The ' \
              'danger there is not being attacked. It is being *noticed*, one delver, individually, ' \
              'by name.'
      )

      list
    end

    def unlocked_count(player)
      entries(player).count { |e| e[:unlocked] }
    end

    def find(player, key)
      entries(player).find { |e| e[:key] == key.to_s }
    end

    # --- event index ---------------------------------------------------
    # Every random, fetish, and timed event the tower can produce, with
    # how often this delver has lived it. Counts only accrue from the
    # day the index opened — no retroactive credit, by design.

    def seen_events(player)
      saved = player.tracker_hash['events_seen']
      saved.is_a?(Hash) ? saved.transform_keys(&:to_s) : {}
    end

    def event_catalog(player)
      seen = seen_events(player)
      keys = (Engine::RandomEvents::EVENT_KEYS + ['feather_array']).uniq
      keys.map do |key|
        if Engine::FetishEvents.event?(key)
          spec = Engine::FetishEvents::EVENTS[key]
          name = spec[:name]
          tag = spec[:tag]
        elsif key == 'feather_array'
          name = 'Feather Array'
          tag = 'tickling'
        else
          name = Engine::RandomEvents.event_meta(key)[:name]
          tag = Engine::RandomEvents::EVENT_TAGS[key]
        end
        count = seen[key].to_i
        { key: key, name: name, tag: tag, seen: count, hint: event_hint(tag, count) }
      end
    end

    # Witnessing half — then all — of the tower's repertoire pays.
    EVENT_MILESTONES = { 50 => 100, 100 => 250 }.freeze

    def claim_event_milestones!(player)
      catalog = event_catalog(player)
      return [] if catalog.empty?

      seen_pct = (catalog.count { |e| e[:seen].positive? } * 100.0 / catalog.size).round
      claimed = Array(player.tracker_hash['codex_milestone_claims']).map(&:to_i)
      fresh = EVENT_MILESTONES.reject { |pct, _| seen_pct < pct || claimed.include?(pct) }
      return [] if fresh.empty?

      player.set_tracker!('codex_milestone_claims', claimed + fresh.keys)
      fresh.map do |pct, lp|
        player.gain_lp!(lp)
        "📖 **Event Index #{pct}% complete** — the tower rewards a thorough witness: **+#{lp} LP**."
      end
    end

    def event_hint(tag, count)
      return nil if count.positive?
      return 'Wander, and let the tower find you.' if tag.nil?

      label = Engine::ContentOptions.preference(tag)&.dig(:label) || tag.to_s.tr('_', ' ')
      "Behind the **#{label}** toggle in `/options` — enable it and wander."
    end
  end
end
