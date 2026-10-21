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
  end
end
