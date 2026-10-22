# frozen_string_literal: true

module Engine
  # The tower's settled residents: delvers and keepers who stopped
  # wandering and took up a trade. Unlike the NPCSystem's passing
  # encounters, these four keep panels of their own — reached from the
  # Shops menu — with talk, services, and (for two of them) a story.
  module Residents
    RESIDENTS = {
      'vex' => {
        name: 'Madame Vex', title: 'the Listener', tag: 'living_clothing',
        blurb: 'Decades ago one of Syn\'s original handmade pieces chose her, and it has never let go. ' \
               'She learned the language of living gear in self-defence. Covar sends her the difficult cases.',
        intro: '_The back room of the Cursed Shop smells of cedar and warm leather. A woman sits very ' \
               'still in a high-backed chair, gloved hands folded, while the living gown she wears breathes ' \
               'slowly against her ribs — older than the temple, patient as debt. "Sit," Madame Vex says. ' \
               '"Your gear has been talking about you. I only translate."_'
      },
      'pip' => {
        name: 'Pip', title: 'Self-Appointed Trapwright', tag: nil,
        blurb: 'A goblin delver who got caught once too often and stayed to study the Queen\'s mechanisms ' \
               'the way monks study scripture. Nobody else uses her title. She has never once minded.',
        intro: '_A goblin in a tool-belt of scavenged springs looks up from a sprung pressure plate she is ' \
               'reverse-engineering with religious care. "Mind the second tile. And the fourth. The third ' \
               'one\'s just showing off." Pip grins with all her teeth. "Pip. Trapwright. The Queen\'s own ' \
               'scholar — self-appointed, but then, so is genius."_'
      },
      'nectar' => {
        name: 'Sister Nectar', title: 'Keeper of the Milking Shrine', tag: 'lactation',
        blurb: 'Keeper of the tower\'s milking shrine, though she somehow staffs every milking room you ' \
               'find. She gets around. Don\'t ask how.',
        intro: '_Brass cups gleam on their hooks and the pumps breathe like something sleeping. Sister ' \
               'Nectar wipes her hands on her apron and looks you over with a professional\'s warmth. ' \
               '"The shrine provides, darling. Arrive tense, leave drained — that\'s the whole liturgy."_'
      },
      'cartographer' => {
        name: 'The Pale Cartographer', title: 'Reader of the Dreaming Land', tag: nil,
        blurb: 'He does not map geography — the land re-dreams itself too fast for that. He reads what the ' \
               'domain is dreaming next, and sells the dream, three rooms at a time.',
        intro: '_His table is covered in maps of rooms that do not exist yet, drawn in white ink on black ' \
               'paper. The Pale Cartographer does not look up from his pen. "You walk a place that dreams ' \
               'itself," he says. "I merely take dictation."_'
      }
    }.freeze

    TOPICS = {
      'vex' => [
        { key: 'the_piece', label: 'Her piece',
          text: '"It chose me in the reign of the first clergy, before Covar, before the shop had a counter. ' \
                'Syn made it with her own hands — she still looks at it the way you look at handwriting you ' \
                'don\'t remember writing." Vex smooths the gown where it rests. "It is old, and proud, and ' \
                'terrified of being catalogued into retirement. So am I, some mornings."' },
        { key: 'the_language', label: 'The language of gear',
          text: '"Creaks are complaints. Tugs are requests. A piece that goes quiet is not content — it is ' \
                'planning." She tilts her head, listening to something under the floor. "Yours hum when you ' \
                'are near what they want. Most people call that a curse. I call it a conversation they ' \
                'weren\'t invited to."' },
        { key: 'covar', label: 'Covar',
          text: '"The boy collects strays and calls it a shop." Something almost fond crosses her face. ' \
                '"When a piece won\'t be catalogued — too old, too proud, too frightened — he sends it to ' \
                'my back room and pretends he hasn\'t. I am the Cursed Shop\'s conscience, darling. It ' \
                'pays terribly."' }
      ],
      'pip' => [
        { key: 'the_designers', label: 'The designers',
          text: '"Syn and the Succubus Queen, every plate of it. Syn\'s patience, the Queen\'s hinge-work — ' \
                'and the Dryad talked them into the vine pieces, you can tell by the manners." Pip presses ' \
                'her ear to the floor like it owes her gossip. "Nobody maintains them. The land re-dreams ' \
                'them. I just take notes before it changes its mind."' },
        { key: 'her_notes', label: 'Her notes',
          text: '"Folded into sprung plates, where the Queen will step." Pip produces a note written in ' \
                'handwriting so eager it leans. "\'Third variation, Feather Array: hinge sings in F. Adoringly, ' \
                'P.\'" She shrugs, ears pink. "Whether she\'s read one... a scholar doesn\'t ask. A scholar ' \
                'documents."' },
        { key: 'staying', label: 'Why she stays',
          text: '"Got caught once too often, didn\'t I? Eleventh time, I stopped cursing and started ' \
                'watching." Her grin goes almost gentle. "Everyone else down here worships the goddess, or ' \
                'the fairies, or their own reflection. I worship the workmanship. Berry thinks that\'s weird. ' \
                'Syn thinks it\'s flattering. Syn is right."' }
      ],
      'nectar' => [
        { key: 'the_shrine', label: 'The shrine',
          text: '"Older than the machinery," Nectar says, patting a pump like a pet. "The tower wanted a ' \
                'place where giving was the whole point, so it grew one, and then it grew me to keep it. ' \
                'The nectar thins when the tower is tired. You can taste the tower\'s mood, if you know how."' },
        { key: 'the_rooms', label: 'Every milking room',
          text: '"Station, chamber, shrine — one room, really. The tower just moves it to where it\'s ' \
                'needed." She says this the way other people discuss weather. "Don\'t ask how I get around. ' \
                'A keeper\'s mystery. Also there are service ducts, but that ruins it."' },
        { key: 'regulars', label: 'Her regulars',
          text: '"The tower sends me the tense ones." Her smile is warm and entirely professional. "I keep ' \
                'a list, you know. Names, preferences, how long they hold out. Yours is a short entry, ' \
                'darling — but there\'s room. There\'s always room."' }
      ],
      'cartographer' => [
        { key: 'the_dreaming', label: 'The dreaming land',
          text: '"Rooms are rolled out of the domain\'s sleep, one at a time, as you walk." His pen never ' \
                'stops. "But sleep leans before it falls. Three rooms ahead, the lean is legible: a hunger, ' \
                'a mechanism, a gleam. Stronger powers — bosses, altars, her — keep their own counsel and ' \
                'override me without apology. I find that honest of them."' },
        { key: 'the_margins', label: 'The margins',
          text: '"The maps have margins, and the margins have you in them." For the first time he looks up, ' \
                'and his eyes are the grey of pencil lead. "Everyone I sketch goes in the margin. It is not ' \
                'vanity. The land dreams delvers too, and I am thorough." He returns to his pen. You do not ' \
                'feel complimented. You feel documented.' },
        { key: 'the_prices', label: 'His prices',
          text: '"Deeper floors dream louder; dictation costs more where the dreaming is dense." He shrugs ' \
                'one pale shoulder. "And descent voids the page. A sketch is for this floor, this cycle. ' \
                'The land does not honour yesterday\'s dreams, and neither do I."' }
      ]
    }.freeze

    CHAINS = {
      'vex' => [
        { name: 'A Stray to Interview', tracker: 'mimics_removed_count', target: 1, reward: 60,
          text: '"A piece only tells the truth once it has been worn and torn free — that is when it decides ' \
                'what it thinks of people." Vex folds her hands. "Tear one free, anywhere in the tower, and ' \
                'come back. I will interview it through you." Tear free 1 living piece.' },
        { name: 'Teach It Manners', tracker: 'vex_refits', target: 1, reward: 60,
          text: '"Temperaments are habits, and habits can be renegotiated." Her gown shifts, listening. ' \
                '"Bring me a piece you are wearing and I will talk it into a kinder shape of itself — once. ' \
                'A piece only renegotiates once; pride, again." Refit 1 worn piece at her bench.' },
        { name: 'The Fitting', action: true, reward: 40,
          text: '"Sit. Still. There." The fitting is mostly her hands at your seams and her voice low, ' \
                'translating creak by creak — but halfway through, the gown she wears reaches a slow seam ' \
                'of itself toward your wrist, curious as a cat, and she lets it. "It does not do that," she ' \
                'says, very quietly, "for customers."' },
        { name: 'What It Asks For', tracker: 'curses_gained', target: 2, reward: 80,
          text: '"It is lonely, if a thing made to be worn can be. It asks — through me, politely — for ' \
                'company its own age: marks with history." She counts on gloved fingers. "Bear two more ' \
                'curses somewhere in the tower and return. Old things collect each other."' },
        { name: "Her Maker", action: true, reward: 60,
          text: 'Syn arrives with her ledger and stops in the doorway. "Oh," she says, to the gown. "Oh, ' \
                'it\'s you." Her hands hover the way hands do over early work — proud, appalled, tender. ' \
                '"I made that before I knew what I was making. It\'s been worn by exactly one person long ' \
                'enough to become someone." Vex, for once, says nothing at all.' },
        { name: "The Original's Choice", choice: true, reward: 200,
          text: '"It has decided to be decided about," Vex says, steady only in the voice. "Persuade it onto ' \
                'the tailor\'s mannequin — worn forever, honoured forever, and me finally out of it. Or ' \
                'persuade me to stop apologising for keeping it. Yours is the voice it will hear, delver. ' \
                'Choose like you mean it."' }
      ],
      'nectar' => [
        { name: 'First Taste', tracker: 'nectar_milkings', target: 1, reward: 50,
          text: '"Business first, liturgy second." Nectar pats the nearest frame. "Let the shrine provide ' \
                'once — properly, with me keeping it — and then we will talk about the taste of the tower\'s ' \
                'mood." Be milked by Sister Nectar 1 time.' },
        { name: 'Thinning Nectar', tracker: 'treasure_found', target: 6, reward: 60,
          text: '"The nectar is thinning, and thin nectar means a tired tower." She writes a list on the ' \
                'back of a hymn sheet: wax, brass polish, three things that are definitely not ingredients. ' \
                '"The mimics hoard all of it. Open chests until I have what I need." Open 6 chests.' },
        { name: 'What Nests Below', tracker: 'monsters_killed', target: 5, reward: 80,
          text: '"Something has nested in the service ducts and it drinks from the lines." Her professional ' \
                'warmth cools by degrees. "I will not have the shrine nibbled. Whatever finds you down there, ' \
                'put five of them down." Defeat 5 monsters.' },
        { name: 'Full Flow', tracker: 'nectar_milkings', target: 5, reward: 80,
          text: '"Better. Fuller. Almost the old pour." She watches the tubes like weather. "Five sessions ' \
                'with me keeping the shrine while I watch the pour, and I will believe it is back." Be milked ' \
                'by Sister Nectar 5 times.' },
        { name: 'Second Pour', action: true, reward: 60,
          text: 'The taste-test is a ceremony of two glasses and absolute seriousness. "First pour: the ' \
                'tower, tired. Second pour—" she fills from the warmed line and watches your face over the ' \
                'rim, "—the tower, attended to. Taste the difference. That difference is you, darling. I ' \
                'intend to keep you."' },
        { name: 'What the Shrine Becomes', choice: true, reward: 180,
          text: '"The shrine is well again, which means it can become something on purpose." Nectar dries ' \
                'the glasses one final time. "A place of worship, where the giving is sacred and slow — or ' \
                'a place of plenty, where nobody leaves wanting and nobody pretends otherwise. You kept it. ' \
                'You choose."' }
      ]
    }.freeze

    ENDINGS = {
      'vex' => {
        'mannequin' => { label: 'Persuade it to the mannequin',
                         text: 'It takes an hour of her voice, low and unhurried, and your hands at the seams. ' \
                               'In the end the gown steps — there is no other word — onto the tailor\'s ' \
                               'mannequin and settles, displayed and breathing, honoured as temple history. ' \
                               'Vex stands in her shift with her arms around herself, free for the first ' \
                               'time in decades, laughing like a dropped glass. "It can still see the door ' \
                               'from there. It\'ll watch the customers. It always did like watching."' },
        'keep' => { label: 'Persuade her to keep it',
                    text: '"Stop apologising," you tell her, and the gown stills like a held breath. Vex ' \
                          'looks down at it — at decades of being worn, and wearing — and her shoulders come ' \
                          'down out of her ears for the first time since you met her. "We stay together, ' \
                          'then," she tells it, and it settles against her ribs like a decision. "It fits, ' \
                          'you know. It always did. That was the part I wasn\'t saying."' }
      },
      'nectar' => {
        'worship' => { label: 'A place of worship',
                       text: '"Worship, then." Nectar lights the tall candles herself. "Slow, sacred, and ' \
                             'kept. The giving is the prayer; the drained are the blessed." The pumps slow ' \
                             'to a hymn\'s tempo behind her. "Come tense, darling. Leave absolved."' },
        'plenty' => { label: 'A place of plenty',
                      text: '"Plenty, then." Her grin goes gloriously unprofessional. "Nobody leaves ' \
                            'wanting, nobody pretends otherwise, and the ducts get a second line by winter." ' \
                            'She chalks it on the board in a keeper\'s hand: ALL ARE FED HERE. "Come tense, ' \
                            'darling. Leave ruined. That\'s also a liturgy."' }
      }
    }.freeze

    NEGOTIATE_MIN = 40
    REFIT_COST = 75
    WEDGE_COST = 60
    MAX_WEDGES = 3
    REFIT_MULTS = [0.8, 0.85, 0.9, 1.1, 1.15, 1.25].freeze

    module_function

    def resident(id)
      RESIDENTS[id.to_s]
    end

    def topics(id)
      TOPICS[id.to_s] || []
    end

    def met?(player, id)
      player.tracker("resident_met_#{id}").positive?
    end

    def mark_met!(player, id)
      player.set_tracker!("resident_met_#{id}", 1)
      player.set_tracker!('nectar_met', 1) if id.to_s == 'nectar'
    end

    # --- story chains (Berry-quest shape, per-resident trackers) --------

    def chain(id)
      CHAINS[id.to_s]
    end

    def story_step(player, id)
      player.tracker("resident_#{id}_step")
    end

    def story_done?(player, id)
      steps = chain(id)
      steps.nil? || story_step(player, id) >= steps.size
    end

    def story_current(player, id)
      steps = chain(id) or return nil
      steps[story_step(player, id)]
    end

    def story_start(player, id, spec)
      key = "resident_#{id}_start"
      start = player.tracker_hash[key]
      return start.to_i unless start.nil?

      now = story_step(player, id).zero? ? 0 : player.progress_value(spec[:tracker].to_sym)
      player.set_tracker!(key, now)
      now
    end

    def story_progress(player, id)
      spec = story_current(player, id) or return nil
      return [1, 1] if spec[:action] || spec[:choice]

      done = player.progress_value(spec[:tracker].to_sym) - story_start(player, id, spec)
      [[done, 0].max, spec[:target]].min.then { |d| [d, spec[:target]] }
    end

    def story_complete?(player, id)
      progress = story_progress(player, id)
      progress && progress[0] >= progress[1]
    end

    # A finished Resident story is once-ever; it leaves a keepsake.
    STORY_KEEPSAKES = {
      'vex' => 'a seam of the Original\'s own thread, freely given',
      'nectar' => 'a hymn sheet from the shrine, amended in Nectar\'s hand'
    }.freeze

    def grant_story_keepsake!(player, id)
      keepsake = STORY_KEEPSAKES[id.to_s] or return nil
      return nil if player.keepsakes.include?(keepsake)

      player.add_keepsake!(keepsake)
      keepsake
    end

    # For delvers who finished before the shelf existed.
    def backfill_story_keepsakes!(player)
      STORY_KEEPSAKES.each_key do |id|
        grant_story_keepsake!(player, id) if player.tracker("#{id}_story_done").positive?
      end
    end

    def advance_story!(player, id, spec)
      step = story_step(player, id)
      player.set_tracker!("resident_#{id}_step", step + 1)
      nxt = chain(id)[step + 1]
      player.set_tracker!("resident_#{id}_start", player.progress_value(nxt[:tracker].to_sym)) if nxt && nxt[:tracker]
      player.gain_lp!(spec[:reward])
      if story_done?(player, id)
        player.set_tracker!("#{id}_story_done", 1)
        player.bump_tracker!('npc_stories_finished')
        grant_story_keepsake!(player, id)
      end
      player.check_progress!
    end

    def claim_story!(player, id)
      spec = story_current(player, id)
      return { ok: false, message: 'That story is finished.' } unless spec
      return { ok: false, message: 'That ending must be chosen, not claimed.' } if spec[:choice]
      unless story_complete?(player, id)
        done, target = story_progress(player, id)
        return { ok: false, message: "**#{spec[:name]}** isn't finished yet — #{done}/#{target}." }
      end

      advance_story!(player, id, spec)
      { ok: true, message: "**#{spec[:name]}** — done, and witnessed. **+#{spec[:reward]} LP**." }
    end

    def choose_ending!(player, id, ending_key)
      spec = story_current(player, id)
      ending = ENDINGS.dig(id.to_s, ending_key.to_s)
      return { ok: false, message: 'That ending is not on offer.' } unless spec && spec[:choice] && ending

      player.set_tracker!("#{id}_ending", ending_key.to_s)
      advance_story!(player, id, spec)
      shelf = STORY_KEEPSAKES[id.to_s] ? "\n_Kept, for the shelf: #{STORY_KEEPSAKES[id.to_s]}._" : ''
      { ok: true, message: "#{ending[:text]}\n\n**Story finished: #{RESIDENTS[id.to_s][:name]}.** **+#{spec[:reward]} LP**.#{shelf}" }
    end

    # --- Madame Vex: negotiation and refits ------------------------------

    # Negotiation is the expensive mercy: the piece comes off intact
    # and stays yours, so it always costs more than tearing it free —
    # twice the tear-free price, with a floor. And while she works out
    # of Covar's back room, his moods are her overhead: if Vex has
    # been freed (the mannequin ending), his grief tax rides on her
    # fee exactly as it does on his own tear-free prices.
    def negotiate_cost(player, item)
      base = [NEGOTIATE_MIN, item.removal_cost.to_i * 2].max
      player.tracker_hash['vex_ending'].to_s == 'mannequin' ? (base * 1.5).ceil : base
    end

    def negotiate_off!(player, equipment_id)
      item = player.equipped_mimics.find { |i| i.id == equipment_id.to_i }
      return { ok: false, message: 'That piece is not being worn.' } unless item

      cost = negotiate_cost(player, item)
      unless player.spend_lp!(cost)
        return { ok: false, message: "Negotiation costs **#{cost} LP** — you have #{player.lp}." }
      end

      surcharge = player.tracker_hash['vex_ending'].to_s == 'mannequin'
      DB[:player_equipment].where(player_id: player.discord_id, equipment_id: item.id).update(is_equipped: false)
      player.clamp_defiance!
      { ok: true,
        message: "_Vex listens at the seams for a long moment, murmuring. The **#{item.name}** sighs — " \
                 'actually sighs — and lets go of you, intact. It goes back in your pack, negotiated off ' \
                 "for **#{cost} LP** instead of torn free._" \
                 "#{surcharge ? "\n_Covar's grief tax is folded into her fee now — she works out of his back room, and his moods are her overhead._" : ''}" }
    end

    def refitted_names(player)
      Array(player.tracker_hash['gear_refitted']).map(&:to_s)
    end

    def refit!(player, equipment_id)
      item = player.equipped_mimics.find { |i| i.id == equipment_id.to_i }
      return { ok: false, message: 'That piece is not being worn.' } unless item
      if refitted_names(player).include?(item.name)
        return { ok: false, message: "The **#{item.name}** has already renegotiated once. Pride, again." }
      end
      unless player.spend_lp!(REFIT_COST)
        return { ok: false, message: "A refit costs **#{REFIT_COST} LP** — you have #{player.lp}." }
      end

      mods = player.gear_effects_for(item).transform_keys(&:to_s).dup
      numeric = mods.select { |_, v| v.is_a?(Numeric) }
      return { ok: false, message: "The **#{item.name}** has no temperament Vex can renegotiate." } if numeric.empty?

      key = numeric.keys.sample
      old = numeric[key]
      new_value =
        if key.end_with?('_mult') || %w[damage_reduction healing_mult encounter_rate].include?(key)
          (REFIT_MULTS - [old]).sample
        else
          [[old.to_i + [-2, -1, 1, 2].sample, -3].max, 5].min
        end
      new_value = old + 1 if new_value == old
      mods[key] = new_value

      overrides = player.tracker_hash['gear_refits']
      overrides = overrides.is_a?(Hash) ? overrides.dup : {}
      overrides[item.name] = mods
      player.set_tracker!('gear_refits', overrides)
      player.set_tracker!('gear_refitted', refitted_names(player) + [item.name])
      player.bump_tracker!('vex_refits')
      { ok: true,
        message: "Vex talks the **#{item.name}** around, seam by seam. Its temperament shifts: " \
                 "**#{Engine::FetishEvents.describe_effect(key, old)}** becomes " \
                 "**#{Engine::FetishEvents.describe_effect(key, new_value)}**. _(Refit once; it will not renegotiate again.)_" }
    end

    # --- Pip: Queen-watching, wedges, reviews ----------------------------

    def spotting_price(player)
      player.tracker('traps_triggered') >= 25 ? 20 : 40
    end

    def buy_spotting!(player)
      return { ok: false, message: 'Pip is already Queen-watching for you — the next trap will be spotted.' } if player.tracker('pip_spotting').positive?

      price = spotting_price(player)
      return { ok: false, message: "Queen-watching costs **#{price} LP** — you have #{player.lp}." } unless player.spend_lp!(price)

      player.set_tracker!('pip_spotting', 1)
      { ok: true,
        message: "Pip walks the next stretch with her ear to the floor. \"There. Hear that? The land's " \
                 "dreaming a mechanism.\" _The next trap you meet will be spotted in time._ **(#{price} LP)**" }
    end

    def buy_wedge!(player)
      if player.tracker('traps_triggered') < 10
        return { ok: false, message: 'Pip shakes her head. "Not yet. Get caught ten times so I can study your technique. For science."' }
      end
      if player.tracker('pip_wedges') >= MAX_WEDGES
        return { ok: false, message: "You already carry **#{MAX_WEDGES}** of Pip's wedges. Jam something first." }
      end
      return { ok: false, message: "A wedge costs **#{WEDGE_COST} LP** — you have #{player.lp}." } unless player.spend_lp!(WEDGE_COST)

      player.bump_tracker!('pip_wedges')
      { ok: true,
        message: 'Pip whittles a wedge from sprung plate-scrap and jams it into your palm. "One use. The ' \
                 'land grows around it after. So will you, probably." _Your next sprung trap will be jammed harmless._' }
    end

    PIP_MILESTONES = {
      10 => { label: 'Ten catches',
              text: '"Ten!" Pip counts your bruises like credentials. "You spot the hinge-work yet? No? ' \
                    'Course not. That\'s the Queen — her mechanisms don\'t perform, they *decide*." She ' \
                    'presses a wedge of plate-scrap on you. "Scholar\'s discount applies to my wedges now. ' \
                    'Get caught more. For the catalogue."' },
      25 => { label: 'Twenty-five catches',
              text: '"Twenty-five catches and still walking into them beautifully." Pip adjusts your ' \
                    'posture with a stick. "Your reads are scholar-grade now, so my Queen-watching gets ' \
                    'cheaper — pattern\'s half-memorised." Her voice drops. "One day I\'ll leave a *signed* ' \
                    'note where she\'ll certainly step. One day."' },
      50 => { label: 'Fifty catches',
              text: '"Fifty. Fifty!" Pip is standing on her workbench. "The catalogue is done, the nerve ' \
                    'is gathered—" she produces a note written in handwriting trying very hard to be calm, ' \
                    'signed, for the first time, in full — "and I need a courier she won\'t catch. That\'s ' \
                    'you, scholar. That\'s always been you."' }
    }.freeze

    def pip_beat_available?(player, threshold)
      player.tracker('traps_triggered') >= threshold.to_i
    end

    def read_pip_beat!(player, threshold)
      beat = PIP_MILESTONES[threshold.to_i]
      return { ok: false, message: 'Pip has nothing new for you yet.' } unless beat && pip_beat_available?(player, threshold)

      heard = Array(player.tracker_hash['pip_beats_heard']).map(&:to_i)
      unless heard.include?(threshold.to_i)
        player.set_tracker!('pip_beats_heard', heard + [threshold.to_i])
        player.set_tracker!('pip_milestones_heard', (heard + [threshold.to_i]).size)
      end
      { ok: true, message: "_#{beat[:text]}_" }
    end

    def deliver_pip_note!(player)
      return { ok: false, message: 'There is no note yet. Fifty catches, scholar.' } unless pip_beat_available?(player, 50)
      return { ok: false, message: 'The note is delivered. Whatever answers, answers to Pip.' } if player.tracker('pip_note_delivered').positive?

      player.set_tracker!('pip_note_delivered', 1)
      player.gain_lp!(120)
      { ok: true,
        message: 'You fold the note into the next sprung plate you find, exactly where a queen would ' \
                 'step. Three rooms later the plate is empty and there are petals on it that were not ' \
                 'there before. Pip, told this, goes very quiet and very pink. "+120 LP. Scholar\'s fee. ' \
                 'Don\'t — don\'t make it a thing."' }
    end

    def review_line(player)
      last = player.tracker_hash['last_trap_name'].to_s
      return nil if last.empty? || player.tracker_hash['pip_reviewed'].to_s == last

      "_\"#{last},\" Pip says, the moment you arrive, not looking up. \"Third variation, if it's the " \
      'one I\'m thinking of. The Queen\'s hinge-work. Syn\'s patience. You never stood a chance — and ' \
      'neither would I. That\'s a compliment, scholar."_'
    end

    # --- Sister Nectar: the shrine service --------------------------------

    def shrine_stamp(player)
      "#{player.current_cycle}:#{player.current_floor}"
    end

    def shrine_visit!(player)
      unless Engine::ContentOptions.enabled?(player, 'lactation')
        return { ok: false, message: 'The shrine stands quiet and dark. (Enable the lactation theme in `/options` to wake it.)' }
      end

      parts = player.body_parts_list.map(&:to_s)
      unless (parts & %w[breasts penis]).any?
        return { ok: false, message: 'Nectar looks you over kindly. "The shrine provides, darling, but it needs something to provide *to* — breasts or a cock. Come back shaped for it."' }
      end
      if player.tracker_hash['nectar_stamp'].to_s == shrine_stamp(player)
        return { ok: false, message: 'Nectar shakes her head, fond. "Once a floor, darling. The shrine provides; it does not spoil."' }
      end

      mark_met!(player, 'nectar')
      regular = player.tracker('nectar_milkings') >= 3
      player.set_tracker!('nectar_stamp', shrine_stamp(player))
      lp = 15 + player.current_floor.to_i
      player.gain_lp!(lp)
      player.gain_lust!(25)
      player.heal_defiance!(10)
      Engine::FetishEvents.apply_condition!(
        player,
        { key: 'milked_dry', name: 'Milked Dry', floors: 2, effects: { 'submission' => 1, 'submit_lp_bonus' => 2 } },
        []
      )
      player.bump_tracker!('being_milked_events')
      player.bump_tracker!('lactation_events')
      player.bump_tracker!('nectar_milkings')
      player.check_progress!
      scene =
        if regular
          "Nectar doesn't bother with the intake questions any more. \"My regular,\" she says, and the " \
          'frame is already warm. The pumps find their rhythm and she keeps one hand resting steady at ' \
          'the small of your back while the shrine takes its tithe of you, unhurried and thorough.'
        else
          'Nectar straps you in herself, adjusting the frame with a keeper\'s fussiness. "Breathe out ' \
          'when it pulls," she instructs, and the cups seal and begin: a slow, rhythmic insistence that ' \
          'works you over until you are drained, flushed, and entirely hers until the humming stops.'
        end
      { ok: true, message: "#{scene}\n**+#{lp} LP** · Lust **+25** · Defiance **+10** · **Milked Dry** for 2 floors." }
    end

    # --- The Pale Cartographer: sketches ----------------------------------

    SKETCH_ICONS = { 'monster' => '⚔️', 'trap' => '🪤', 'treasure' => '🧰', 'stairs' => '🪜', 'empty' => '○' }.freeze
    SKETCH_LABELS = { 'monster' => 'teeth', 'trap' => 'a mechanism', 'treasure' => 'a gleam',
                      'stairs' => 'descent', 'empty' => 'quiet' }.freeze

    def sketch_price(player)
      20 + (3 * player.current_floor.to_i)
    end

    def active_sketch(player)
      saved = player.tracker_hash['cartographer_sketch']
      return nil unless saved.is_a?(Hash) && saved['stamp'].to_s == shrine_stamp(player)

      queue = Array(saved['queue']).map(&:to_s)
      queue.empty? ? nil : queue
    end

    def buy_sketch!(player)
      price = sketch_price(player)
      return { ok: false, message: "A sketch costs **#{price} LP** — you have #{player.lp}." } unless player.spend_lp!(price)

      queue = Engine::Exploration.new(player).projected_pool_kinds(3)
      player.set_tracker!('cartographer_sketch', { 'stamp' => shrine_stamp(player), 'queue' => queue })
      player.bump_tracker!('sketches_bought')
      player.check_progress!
      { ok: true, queue: queue,
        message: "He draws without looking at the page. \"Three rooms of lean,\" he says. " \
                 "#{queue.map { |k| SKETCH_LABELS[k] }.join(', then ')}. Probably.\" " \
                 "_(#{price} LP — the sketch holds for this floor, this cycle.)_" }
    end

    def consume_sketch!(player)
      queue = active_sketch(player) or return nil

      kind = queue.first
      rest = queue.drop(1)
      if rest.empty?
        player.set_tracker!('cartographer_sketch', { 'stamp' => shrine_stamp(player), 'queue' => [] })
      else
        player.set_tracker!('cartographer_sketch', { 'stamp' => shrine_stamp(player), 'queue' => rest })
      end
      kind
    end

    def sketch_strip(player)
      queue = active_sketch(player) or return nil

      "🗺️ _Sketch: #{queue.map { |k| SKETCH_ICONS[k] }.join(' ')}_"
    end

    def rapport_line(player)
      cycles = player.tracker('cycles_completed')
      if cycles >= 5
        '_"Five cycles of margins," he says, and turns a page covered, indefensibly, in sketches of you. ' \
        '"The land dreams you often now. So do I. It is not vanity. It is thoroughness."_'
      elsif cycles >= 3
        '_"You persist," the Cartographer observes, with what might be warmth. "The dreaming has started ' \
        'leaning toward you before I read it. Flattering, or habit. The land does not say."_'
      elsif cycles >= 1
        '_"A returner," he notes, and his pen resumes. "The land dreams returners in longer strokes. ' \
        'Yours, I confess, I have started to recognise."_'
      else
        '_"First cycle," he says, without looking up. "The dreaming is shallow here. Walk. Deepen it. ' \
        'My sketches will thicken as you do."_'
      end
    end

    def boss_warning(player)
      wrapped = ((player.current_floor.to_i - 1) % 35) + 1
      nxt = Engine::Tower::BOSS_FLOORS.find { |f| f > wrapped }
      return nil unless nxt && (nxt - wrapped) <= 3 && player.tracker('cycles_completed') >= 5

      "_\"Dictation, gratis,\" the Cartographer says. \"A lord's floor is **#{nxt - wrapped}** room(s) of " \
      'descent above you. She dreams louder than I draw. Go prepared, or go willing."_'
    end
  end
end
