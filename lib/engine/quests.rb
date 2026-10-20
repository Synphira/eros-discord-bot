# frozen_string_literal: true

module Engine
  # Berry's quest board. Berry, the shopkeeper fairy, always has work for a
  # delver: she offers three quests at a time, you may hold up to MAX_ACTIVE,
  # and progress is measured against your lifetime trackers, so everything
  # you were already doing counts from the moment you accept. Quests are
  # repeatable — Berry never runs out of errands, or opinions about her wife.
  module Quests
    ACTIVE_TRACKER = 'berry_quests_active'
    SEED_TRACKER = 'berry_offer_seed'
    COMPLETED_TRACKER = 'berry_quests_completed'
    MAX_ACTIVE = 3
    OFFER_COUNT = 3

    QUESTS = {
      'essence_run' => {
        name: 'Essence Run', tracker: 'monsters_killed', target: 10, reward: 60,
        ask: 'Berry needs fresh monster essence for her ink thinner. "Defeat 10 monsters, sugar. And don\'t lick any ' \
             'of it on the way back — that\'s for customers."',
        done: '"There\'s my hard-working pet," Berry chirps, bottling the essence. "Syn! Look what the delver ' \
              'brought us! ...Yes, yes, I see you, put your top back on."'
      },
      'willing_pet' => {
        name: 'Willing Pet', tracker: 'submissions', target: 8, reward: 70,
        ask: '"Submit to 8 monsters for me," Berry says, far too brightly. "Syn says it builds character. I say it ' \
             'builds something else entirely, but she\'s the artist."',
        done: '"Eight times on your knees? Oh, Syn is going to be *jealous*," Berry giggles. "Don\'t tell her I ' \
              'said that. Actually — do. It\'s funnier."'
      },
      'boss_breaker' => {
        name: 'Boss Breaker', tracker: 'bosses_defeated', target: 1, reward: 100,
        ask: '"One boss, defeated or satisfied, I don\'t mind which," Berry says. "Their leftover lust makes the ' \
             'shop wards sing. And if it\'s the satisfying kind — details. I want details."',
        done: '"A boss! My hero!" Berry does a loop in the air. "Syn, did you hear? Our delver tumbled a boss! No, ' \
              'you may not ask them to demonstrate on you."'
      },
      'chest_hunter' => {
        name: 'Chest Hunter', tracker: 'treasure_found', target: 6, reward: 50,
        ask: '"Open 6 chests," Berry says. "Half of what\'s in them was mine before the mimics stole it. The other ' \
             'half is mimics. Syn says that\'s still technically inventory."',
        done: '"Six chests and still all your fingers!" Berry beams. "The mimics are getting soft. So is Syn, ' \
              'but don\'t tell her — she\'ll make that face and then I\'ll have to kiss it."'
      },
      'deep_delver' => {
        name: 'Deep Delver', tracker: 'floors_cleared', target: 10, reward: 50,
        ask: '"Walk 10 floors for me," Berry says. "Stretch those legs. Syn spends all day bent over her bench and ' \
             'look at her posture. Terrible. Gorgeous, but terrible."',
        done: '"Ten floors! Look at you, all flushed and exercised," Berry says. "Syn, darling, the delver did the ' \
              'thing with the legs. ...Walking. I meant walking."'
      },
      'sweet_release' => {
        name: 'Sweet Release', tracker: 'total_climaxes', target: 5, reward: 80,
        ask: 'Berry leans over the counter. "Orgasm 5 times in the tower. For research," she says, utterly straight-faced. ' \
             '"Syn keeps the charts. She has *so* many charts."',
        done: '"Five! The charts are updated and Syn is *thrilled*," Berry says. "She\'s doing the little hum. You ' \
              'know the hum. Of course you do, everyone knows the hum."'
      },
      'elite_hunt' => {
        name: 'Elite Hunt', tracker: 'elites_defeated', target: 3, reward: 120,
        ask: '"The big shiny ones — elites, defeat 3 of them," Berry says. "Their essence is extra spicy and Syn\'s ' \
             'inks go all swirly. Also she bets I can\'t get you to do it. Prove her wrong, sugar."',
        done: '"Three elites! I WIN THE BET!" Berry whoops, then composes herself. "Syn owes me a massage. A long ' \
              'one. With the oil. Forget I said anything."'
      },
      'elite_pet' => {
        name: 'Elite Pet', tracker: 'elites_satisfied', target: 2, reward: 120,
        ask: '"Satisfy 2 elites," Berry whispers. "Anyone can fight the big ones. It takes a special kind of delver ' \
             'to leave one of them all wobbly-kneed. Syn\'s words. She talks about you a lot, actually."',
        done: '"Two elites, satisfied!" Berry fans herself. "Syn, our delver is talented. No — Syn — put the ' \
              'sketchbook away, you have customers. ...Draw it later, then."'
      },
      'cursed_bearer' => {
        name: 'Cursed Bearer', tracker: 'curses_acquired', target: 3, reward: 90,
        ask: '"Collect 3 different curses," Berry says cheerfully, like it\'s a shopping list. "Syn studies the ' \
             'marks they leave. Up close. While you\'re wearing them. She\'s very thorough, my wife."',
        done: '"Three curses! Let\'s see them," Berry sings, and Syn is already there with her sketchbook, looking ' \
              'far too awake for once. "Research," Syn murmurs. "Sure it is, darling," Berry says.'
      },
      'show_goer' => {
        name: 'Show-Goer', tracker: 'fetish_events_accepted', target: 4, reward: 60,
        ask: '"Say yes to 4 of the tower\'s little entertainments," Berry says. "Events, darling. The tower throws ' \
             'such lovely parties and Syn never wants to go. Live a little, for both of us."',
        done: '"Four parties!" Berry claps. "And you came back glowing every time. Syn, we are taking this one ' \
              'out. ...The delver, darling. Taking the delver out. Put the harness down."'
      },
      'trap_dancer' => {
        name: 'Trap Dancer', tracker: 'traps_avoided', target: 5, reward: 50,
        ask: '"Dodge 5 traps," Berry says. "Light feet, sugar. Syn set half of them, back before we had the shop. ' \
             'She calls it her early work. I call it why I do the cooking."',
        done: '"Five traps dodged!" Berry beams. "Syn is pretending not to be impressed, which is her favourite way ' \
              'of being impressed. I\'ve learned to translate."'
      },
      'boss_pet' => {
        name: 'Boss Pet', tracker: 'bosses_satisfied', target: 1, reward: 150,
        ask: 'Berry drops her voice. "Satisfy a boss. Don\'t fight it — *satisfy* it. Syn says a satisfied boss ' \
             'leaves a mark like a signature, and I want to see one. On you. For... framing."',
        done: '"You SATISFIED a boss," Berry breathes. "Syn. Syn, come here. Look at our delver. ...Yes, that\'s ' \
              'what I thought. Close your mouth, darling, you\'ll catch a slime."'
      }
    }.freeze

    module_function

    def quest(key)
      QUESTS[key.to_s]
    end

    def active(player)
      Array(player.tracker_hash[ACTIVE_TRACKER]).select { |row| row.is_a?(Hash) && QUESTS.key?(row['key'].to_s) }
    end

    def active_keys(player)
      active(player).map { |row| row['key'].to_s }
    end

    def offers(player)
      keys = QUESTS.keys - active_keys(player)
      return [] if keys.empty?

      seed = player.tracker(SEED_TRACKER)
      rotated = keys.rotate(seed % keys.size)
      rotated.first([OFFER_COUNT, rotated.size].min)
    end

    def progress(player, row)
      spec = quest(row['key']) or return [0, 0]
      current = player.progress_value(spec[:tracker].to_sym) - row['start'].to_i
      [[current, 0].max, spec[:target]].min.then { |done| [done, spec[:target]] }
    end

    def complete?(player, row)
      done, target = progress(player, row)
      done >= target
    end

    def accept!(player, key)
      spec = quest(key)
      return { ok: false, message: 'Berry has never heard of that errand.' } unless spec
      return { ok: false, message: "**#{spec[:name]}** is already on your list, sugar." } if active_keys(player).include?(key.to_s)
      if active(player).size >= MAX_ACTIVE
        return { ok: false, message: "\"Your list is full, pet,\" Berry says. \"Finish or drop one first — " \
                                      "Syn gets twitchy when my board is messy.\"" }
      end

      row = { 'key' => key.to_s, 'start' => player.progress_value(spec[:tracker].to_sym) }
      store!(player, active(player) + [row])
      bump_seed!(player)
      { ok: true, quest: spec, message: "_#{spec[:ask]}_\n**Quest accepted: #{spec[:name]}** — #{objective_text(player, row)}" }
    end

    def claim!(player, key)
      row = active(player).find { |r| r['key'].to_s == key.to_s }
      spec = row && quest(key)
      return { ok: false, message: 'That quest is not on your list.' } unless spec
      unless complete?(player, row)
        done, target = progress(player, row)
        return { ok: false, message: "**#{spec[:name]}** isn't done yet — #{done}/#{target}. Berry taps the board impatiently." }
      end

      store!(player, active(player) - [row])
      player.bump_tracker!(COMPLETED_TRACKER)
      player.gain_lp!(spec[:reward])
      bump_seed!(player)
      news = player.check_progress!
      { ok: true, quest: spec, news: news,
        message: "_#{spec[:done]}_\n**Quest complete: #{spec[:name]}** — **+#{spec[:reward]} LP** (now `#{player.lp}`)." }
    end

    def abandon!(player, key)
      row = active(player).find { |r| r['key'].to_s == key.to_s }
      spec = row && quest(key)
      return { ok: false, message: 'That quest is not on your list.' } unless spec

      store!(player, active(player) - [row])
      bump_seed!(player)
      { ok: true, quest: spec,
        message: "_\"Dropped? Fine, fine,\" Berry sighs, striking **#{spec[:name]}** off the board. \"Syn never " \
                 'finishes anything either. It\'s why the shop has a wife who can count."_' }
    end

    def objective_text(player, row)
      spec = quest(row['key'])
      done, target = progress(player, row)
      "#{spec[:name]}: **#{done}/#{target}** — reward **#{spec[:reward]} LP**"
    end

    def board_lines(player)
      list = active(player)
      return ['_Your list is empty. Berry is already writing your name on hers._'] if list.empty?

      list.map do |row|
        spec = quest(row['key'])
        done, target = progress(player, row)
        state = done >= target ? ' ✅ **ready to claim!**' : ''
        "◆ **#{spec[:name]}** — #{done}/#{target} · reward #{spec[:reward]} LP#{state}"
      end
    end

    def completed(player)
      player.tracker(COMPLETED_TRACKER)
    end

    def store!(player, rows)
      player.update(trackers: player.tracker_hash.merge(ACTIVE_TRACKER => rows))
    end

    def bump_seed!(player)
      player.set_tracker!(SEED_TRACKER, player.tracker(SEED_TRACKER) + 1)
    end
  end
end
