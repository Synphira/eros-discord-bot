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
        blurb: 'Syn\'s first living dress — the Original — chose her decades ago. She learned gear-language ' \
               'in self-defence. Covar sends her the difficult cases. Easy. She\'s listening.',
        intro: '_Cedar, warm leather, pins within reach. Madame Vex sits Listener-still while the living ' \
               'gown breathes against her ribs — older than polite history, patient as debt. "Sit," she ' \
               'says. "You don\'t have to perform. Your gear has been talking. I only translate."_'
      },
      'pip' => {
        name: 'Pip', title: 'Self-Appointed Trapwright', tag: nil,
        blurb: 'Goblin delver who got caught too often and stayed to worship Syn and the Queen\'s hinge-work. ' \
               'Self-appointed Trapwright. Berry keeps saying pants. The traps vote no.',
        intro: '_Goggles askew, tool-belt of scavenged springs, no pants in sight. Pip looks up from a sprung ' \
               'plate. "Mind the second tile. And the fourth. The third\'s just showing off." All teeth. ' \
               '"Pip. Trapwright. Ask me something with hinges."_'
      },
      'nectar' => {
        name: 'Sister Nectar', title: 'Keeper of the Milking Shrine', tag: 'lactation',
        blurb: 'Keeper of the milking shrine — and somehow every milking room you find. Thin nectar means a ' \
               'tired tower. Milking is holy. Treat it like holy.',
        intro: '_Brass cups on hooks; pumps breathing like something asleep. Sister Nectar wipes her hands ' \
               'on her apron with shrine-professional warmth. "Arrive tense, leave drained — that\'s the ' \
               'liturgy. Milking is holy. Then ask, darling."_'
      },
      'cartographer' => {
        name: 'The Pale Cartographer', title: 'Reader of the Dreaming Land', tag: nil,
        blurb: 'Fang does not map geography — the land re-dreams too fast. He reads the next three rooms and ' \
               'sells the dream. Purely cartographic. (He redraws one counter more often than the maps require.)',
        intro: '_White ink on black paper; rooms that do not exist yet. The Pale Cartographer does not look ' \
               'up. "The room moved again. Hold this corner — or ask. You walk a place that dreams itself. ' \
               'I take dictation. Purely cartographic."_'
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
                'a mechanism, a gleam — and what I draw is what you meet. Only the floor lords keep their ' \
                'own counsel and override me without apology. I find that honest of them."' },
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

    # --- Restore the Dress: Covar's exile of Vex, and the way back -----
    # When Vex's story ends with the Original on the mannequin, Covar
    # kicks her out of his back room in grief and salvages the dress
    # himself. While she is exiled, her bench is closed and his own
    # tear-free prices double. A six-step restoration — salvage, counsel
    # from the two clergy who know Syn's magic best, a distraction, an
    # essence, and a fitting — ends with Covar wearing the dress, Syn
    # seeing it on her little brother, prices made whole, and Vex back
    # in business in a rundown room at double her old fees (rent).

    module_function

    def vex_mannequin?(player)
      player.tracker_hash['vex_ending'].to_s == 'mannequin'
    end

    def vex_restored?(player)
      player.tracker('vex_restoration_done').positive?
    end

    def vex_exiled?(player)
      vex_mannequin?(player) && !vex_restored?(player)
    end

    RESTORATION = [
      { name: 'Salvage What Remains', tracker: 'mimics_removed_count', target: 2, reward: 80,
        text: 'Covar has the Original on a stand in the back, under every light he owns, and his hands ' \
              'shake when he works. "The seams remember her shape. I can re-teach them a shape — but I ' \
              'need to study how living seams forgive. Tear free 2 living pieces, anywhere, and bring me ' \
              'the memory of it." Tear free 2 living pieces.' },
      { name: 'An Audience with the Queen', flag: 'queen_dress_counsel', reward: 100,
        text: '"The Queen knew Syn before there was a temple," Covar says. "Her court runs on the oldest ' \
              'version of her magic there is. Beat her or satisfy her — then, on her victory screen, ask ' \
              'her about the dress. She\'ll remember being asked. Queens do." Ask the Succubus Queen ' \
              'about the dress after defeating or satisfying her.' },
      { name: "The Lich Lord's Ledger", flag: 'lich_dress_counsel', reward: 100,
        text: '"And the Lich Lord keeps the archive," Covar says. "Syn\'s first notations are in his ' \
              'stacks — how the early pieces were bound, named, sung shut. Defeat or satisfy him, then ' \
              'ask him about the dress on his victory screen." Ask the Lich Lord about the dress after ' \
              'defeating or satisfying him.' },
      { name: 'Keep Her Distracted', tracker: 'berry_quests_completed', target: 3, reward: 100,
        text: '"Syn cannot know," Covar says, with the air of a man planning a jewel theft. "If she finds ' \
              'a half-restored first work, she\'ll take it home to finish it herself, and it will never ' \
              'be worn again — she keeps things. So: chaos at the parlour. Run 3 of Berry\'s quests. A ' \
              'frazzled Berry is a distracted household." Complete 3 of Berry\'s quests.' },
      { name: 'Essence with a Kick', tracker: 'elites_satisfied', target: 2, reward: 120,
        text: '"The Queen\'s stitch forgives; the Lich\'s stitch remembers; but the thread has to want ' \
              'to live in a body again." Covar threads a needle with something that glows faintly. ' \
              '"Essence with a kick. Satisfy 2 elites and carry it back on you." Satisfy 2 elites.' },
      { name: 'The Fitting', finale: true, reward: 250,
        text: 'Everything is gathered: salvage, a forgiving stitch, a remembering stitch, a distracted ' \
              'maker, and thread that wants a body. All that is left is for somebody to be brave in a ' \
              'dress. Covar has opinions about who.' }
    ].freeze

    def restoration_step(player)
      player.tracker('vex_restoration_step')
    end

    def restoration_done?(player)
      vex_restored?(player) || restoration_step(player) >= RESTORATION.size
    end

    def restoration_available?(player)
      vex_exiled?(player) && !restoration_done?(player)
    end

    def restoration_current(player)
      RESTORATION[restoration_step(player)] if restoration_available?(player)
    end

    def restoration_start(player, spec)
      start = player.tracker_hash['vex_restoration_start']
      return start.to_i unless start.nil?

      now = restoration_step(player).zero? ? 0 : player.progress_value(spec[:tracker].to_sym)
      player.set_tracker!('vex_restoration_start', now)
      now
    end

    def restoration_progress(player)
      spec = restoration_current(player) or return nil
      return [player.tracker(spec[:flag]).positive? ? 1 : 0, 1] if spec[:flag]
      return [1, 1] if spec[:finale]

      done = player.progress_value(spec[:tracker].to_sym) - restoration_start(player, spec)
      [[done, 0].max, spec[:target]].min.then { |d| [d, spec[:target]] }
    end

    def restoration_complete?(player)
      progress = restoration_progress(player)
      progress && progress[0] >= progress[1]
    end

    def claim_restoration!(player)
      spec = restoration_current(player)
      return { ok: false, message: 'There is no dress to restore.' } unless spec
      return { ok: false, message: 'That part of the work is the fitting — begin it when you are ready.' } if spec[:finale]
      unless restoration_complete?(player)
        done, target = restoration_progress(player)
        return { ok: false, message: "**#{spec[:name]}** isn't finished yet — #{done}/#{target}." }
      end

      step = restoration_step(player)
      player.set_tracker!('vex_restoration_step', step + 1)
      nxt = RESTORATION[step + 1]
      player.set_tracker!('vex_restoration_start', player.progress_value(nxt[:tracker].to_sym)) if nxt && nxt[:tracker]
      player.gain_lp!(spec[:reward])
      player.check_progress!
      { ok: true, message: "**#{spec[:name]}** — done. **+#{spec[:reward]} LP**. Covar looks at the dress " \
                           "like a man reading a letter he's answering. \"Next: **#{RESTORATION[step + 1][:name]}**.\"" }
    end

    DRESS_COUNSEL = {
      'queen' => {
        boss: 'Succubus Queen', flag: 'queen_dress_counsel',
        text: 'You ask, with the court\'s ruin settling around you both, about a dress — Syn\'s first ' \
              'work, decades on one woman, now standing empty on a mannequin. The Succubus Queen goes ' \
              'very still. "I knew her before the temple," she says at last. "Before the ledger, before ' \
              'the marks. She made that dress in a rented room with stolen silk and sang every seam shut ' \
              'because she could not afford thread that would hold." Her smile is the oldest thing you ' \
              'have seen in this tower. "Her first magic was not binding, little tailor\'s courier. It ' \
              'was *forgiving* — seams that let the wearer change. Tell Covar: a seam that forgives can ' \
              'be re-taught any shape at all. Even his. Especially his — the dress always did prefer ' \
              'being looked at, and nobody looks like family."'
      },
      'lich' => {
        boss: 'Lich Lord', flag: 'lich_dress_counsel',
        text: 'You ask the Lich Lord about a dress, and the archive itself seems to lean closer. "Shelf ' \
              'nine," he says, "her first notations. She was seventeen kinds of careless and one kind of ' \
              'genius." A page turns itself somewhere in the stacks. "The early pieces were not bound ' \
              'shut, child. They were *named* shut. Every seam a name, every name a promise the silk ' \
              'agreed to keep. The dress has not forgotten its names — it is waiting to be addressed ' \
              'properly." His voice dries into something almost warm. "Tell my sister\'s little ' \
              'matchmaker: speak to it as she did. By name, and without apology. It will know the ' \
              'pronunciation. It taught *her* the pronunciation."'
      }
    }.freeze

    def dress_counsel_available?(player, encounter_name)
      return false unless vex_exiled?(player)

      spec = DRESS_COUNSEL.values.find { |s| s[:boss] == encounter_name.to_s } or return false
      !player.tracker(spec[:flag]).positive?
    end

    # Floor whose domain lord must appear in person for the current
    # Restore-the-Dress counsel step (Succubus Queen = 10, Lich Lord = 25).
    # While that step is active, relics may not hold that throne.
    DRESS_COUNSEL_FLOORS = {
      'queen_dress_counsel' => 10,
      'lich_dress_counsel' => 25
    }.freeze

    def blocks_relic_for_dress_counsel?(player, floor)
      spec = restoration_current(player)
      return false unless spec && spec[:flag]

      DRESS_COUNSEL_FLOORS[spec[:flag]].to_i == floor.to_i
    end

    def dress_counsel!(player, who)
      spec = DRESS_COUNSEL[who.to_s]
      return { ok: false, message: 'They have nothing to say about any dress.' } unless spec
      return { ok: false, message: 'The dress is already whole again.' } if vex_restored?(player)
      return { ok: false, message: 'You have already had that counsel.' } if player.tracker(spec[:flag]).positive?

      player.set_tracker!(spec[:flag], 1)
      player.check_progress!
      { ok: true, message: spec[:text] }
    end

    def finish_restoration!(player)
      spec = restoration_current(player)
      unless spec && spec[:finale] && restoration_complete?(player)
        return { ok: false, message: 'The fitting is not ready. Finish the work first.' }
      end

      player.set_tracker!('vex_restoration_done', 1)
      player.set_tracker!('vex_restoration_step', RESTORATION.size)
      player.gain_lp!(spec[:reward])
      player.add_keepsake!('a spare button off the restored Original')
      player.check_progress!
      { ok: true,
        message: "🪡 **The Fitting.** Covar closes the shop, which he has never once done, and steps behind " \
                 "the bead curtain with the Original in his arms like a bride. Half an hour of muffled " \
                 "swearing, one torn seam forgiven and re-taught, and he comes out wearing Syn's first work " \
                 "— and the dress, given a body that *wants* to be looked at, comes alive on him: seams " \
                 "singing shut in a new key, silk arranging itself around horns and tail and that impossible " \
                 "chest like it had opinions all along and finally a wearer who agrees with them.\n\n" \
                 "That is when the door chime goes, and **Syn** walks in with her ledger — and stops. For " \
                 "three full seconds the tower's most exhausted fairy is wide, wide awake. \"That's—\" she " \
                 "says. \"Oh. Oh, that's *mine*. That's my first—\" She crosses the shop like weather. \"It " \
                 "died. Vex wrote me it had settled on a stand, I mourned it *professionally*—\" Her hands " \
                 "hover, proud, appalled, tender, exactly as they once hovered over it on Vex. \"It hasn't " \
                 "died. It's *better*. The seams forgive more than I ever taught them. Who—\" Then she looks " \
                 "up, properly, at the incubus wearing her first masterpiece like it was cut for him, and her " \
                 "voice goes soft enough to hurt: \"Oh, little brother. Look at you. My first work, on my " \
                 "favourite disaster.\"\n\n" \
                 "\"It's a masterpiece, Syn,\" Covar says, turning once, shameless and radiant, while the " \
                 "dress turns with him like a dance partner. \"It always was. It just needed a body that " \
                 "would show it off properly.\" Syn laughs like she's been caught, kisses his cheek, and " \
                 "buys three things she doesn't need on her way out — family rates, which she refuses.\n\n" \
                 "**+#{spec[:reward]} LP.** The grief tax is lifted: Covar's prices are his own again, and " \
                 "he wears the Original at the counter from now on. Across the tower, in a rundown room " \
                 "with a kettle and strong opinions, Madame Vex has put her sign back up — her fees are " \
                 "doubled now, and she will tell you exactly whose rent is responsible.\n" \
                 '_Kept, for the shelf: a spare button off the restored Original._' }
    end

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
    # twice the tear-free price, with a floor. After the restoration
    # Vex works out of her own rundown room, and rent is merciless:
    # her fee doubles, permanently, and she will itemise whose fault
    # that is. While she is exiled the bench is simply closed.
    # --- Madame Vex's outfit counter -------------------------------------
    # Mundane (not living) clothes cut by the tower's own seamstress,
    # sold from beside her bench. Every piece dresses the delver down
    # the tower's favourite road: it raises their appearance — and so
    # their threat — and pays them for submitting in it. The counter is
    # open whenever Vex is receiving; after her restoration the stock
    # doubles, because the new room has a proper rack. Rent.

    VEX_OUTFITS = [
      { name: 'Ribbon-Bound Harness', slot: 'chest', type: 'armor', cost: 60, tier: :basic,
        description: 'Ribbons where armour ought to be. It holds nothing back and promises everything.',
        stat_modifiers: { 'appearance' => 10, 'satisfy_bonus' => 0.05, 'submit_lp_bonus' => 1, 'lust_mult' => 1.05 } },
      { name: 'Bell Collar of the Willing', slot: 'accessory', type: 'accessory', cost: 45, tier: :basic,
        description: 'A collar with a small, bright bell. Everyone will hear what you are.',
        stat_modifiers: { 'appearance' => 7, 'submission' => 1, 'submit_lp_bonus' => 1 } },
      { name: 'Split-Skirt Silks', slot: 'legs', type: 'armor', cost: 55, tier: :basic,
        description: 'Silk split to the hip on both sides. Walking is a statement; running is a confession.',
        stat_modifiers: { 'appearance' => 10, 'satisfy_bonus' => 0.04, 'submit_lp_bonus' => 1, 'lust_mult' => 1.05 } },
      { name: 'Barefoot Anklets', slot: 'feet', type: 'armor', cost: 35, tier: :basic,
        description: 'Fine chains for bare feet. Shoes are for people with somewhere respectable to be.',
        stat_modifiers: { 'appearance' => 6, 'submit_lp_bonus' => 1, 'explore_lp' => 1 } },
      { name: 'Veil of Display', slot: 'head', type: 'armor', cost: 40, tier: :basic,
        description: 'A veil that covers nothing that matters. It frames; it does not hide.',
        stat_modifiers: { 'appearance' => 7, 'satisfy_bonus' => 0.03, 'victory_lp_bonus' => 1 } },
      { name: "The Devotee's Habit", slot: 'chest', type: 'armor', cost: 110, tier: :restored,
        description: 'Cut like a nun\'s habit by someone who had read the scripture and chosen the other side.',
        stat_modifiers: { 'appearance' => 14, 'satisfy_bonus' => 0.08, 'submit_lp_bonus' => 2,
                          'lust_mult' => 1.10, 'submission' => 1 } },
      { name: 'Gilded Offering Collar', slot: 'accessory', type: 'accessory', cost: 90, tier: :restored,
        description: 'Gold, heavy, and engraved with a price the whole corridor can read.',
        stat_modifiers: { 'appearance' => 11, 'submit_lp_bonus' => 2, 'victory_lp_bonus' => 2 } },
      { name: 'Confession Heels', slot: 'feet', type: 'armor', cost: 70, tier: :restored,
        description: 'Heels tall enough to change your posture and your intentions. Every step announces you.',
        stat_modifiers: { 'appearance' => 10, 'satisfy_bonus' => 0.05, 'submit_lp_bonus' => 2, 'agility' => -1 } },
      { name: 'Crown of Petals and Chains', slot: 'head', type: 'armor', cost: 85, tier: :restored,
        description: 'Flowers threaded through fine chain. A crown for being looked at in.',
        stat_modifiers: { 'appearance' => 11, 'submission' => 1, 'satisfy_bonus' => 0.05, 'victory_lp_bonus' => 1 } },
      { name: "Nurse's Cap", slot: 'head', type: 'armor', cost: 50, tier: :basic,
        description: 'A crisp little cap, starched to within an inch of its life. The uniform does the rest.',
        stat_modifiers: { 'appearance' => 7, 'submit_lp_bonus' => 1 } },
      { name: 'Naughty Nurse Uniform', slot: 'chest', type: 'armor', cost: 85, tier: :basic,
        description: 'White, tight, and hemmed at a length no hospital would survive. Bedside manner sold separately.',
        stat_modifiers: { 'appearance' => 11, 'satisfy_bonus' => 0.05, 'submit_lp_bonus' => 1, 'lust_mult' => 1.05 } },
      { name: "Nurse's Stockings", slot: 'legs', type: 'armor', cost: 55, tier: :basic,
        description: 'White stockings with a red seam up the back. For taking temperatures, among other things.',
        stat_modifiers: { 'appearance' => 8, 'submit_lp_bonus' => 1, 'agility' => 1 } },
      { name: "Maid's Lace Cap", slot: 'head', type: 'armor', cost: 45, tier: :basic,
        description: 'A frilled cap that announces service before you say a word.',
        stat_modifiers: { 'appearance' => 6, 'explore_lp' => 1 } },
      { name: 'Satin Maid Dress', slot: 'chest', type: 'armor', cost: 80, tier: :basic,
        description: 'Black satin, white apron, and a skirt built for bending over in. Dusting not included.',
        stat_modifiers: { 'appearance' => 10, 'victory_lp_bonus' => 1, 'submit_lp_bonus' => 1 } },
      { name: 'Service Heels', slot: 'feet', type: 'armor', cost: 50, tier: :basic,
        description: 'Heels polished to a shine you could check your reflection in. Service with a click.',
        stat_modifiers: { 'appearance' => 7, 'submit_lp_bonus' => 1 } },
      { name: "Fallen Nun's Veil", slot: 'head', type: 'armor', cost: 60, tier: :restored,
        description: 'A veil that has slipped, and keeps slipping. The tower reads devotion as an invitation.',
        stat_modifiers: { 'appearance' => 9, 'satisfy_bonus' => 0.03 } },
      { name: 'Penitent Habit', slot: 'chest', type: 'armor', cost: 95, tier: :restored,
        description: 'A habit cut by a seamstress with no respect whatsoever for the cloth\'s original purpose.',
        stat_modifiers: { 'appearance' => 12, 'satisfy_bonus' => 0.05, 'submit_lp_bonus' => 2, 'lust_mult' => 1.05 } },
      { name: 'Confession Garter', slot: 'legs', type: 'armor', cost: 65, tier: :restored,
        description: 'A garter worn where only confessors and monsters will ever see it. That is the point.',
        stat_modifiers: { 'appearance' => 9, 'submit_lp_bonus' => 1, 'submission' => 1 } },
      { name: 'Velvet Bunny Ears', slot: 'head', type: 'armor', cost: 55, tier: :restored,
        description: 'Tall velvet ears, one flopped. Prey, presented properly.',
        stat_modifiers: { 'appearance' => 8, 'agility' => 1 } },
      { name: 'Velvet Bunny Suit', slot: 'chest', type: 'armor', cost: 90, tier: :restored,
        description: 'Crushed velvet, a bow tie, and a tail placed with intent. The warren approves.',
        stat_modifiers: { 'appearance' => 12, 'satisfy_bonus' => 0.04, 'victory_lp_bonus' => 1 } },
      { name: 'Fishnet Tights', slot: 'legs', type: 'armor', cost: 60, tier: :restored,
        description: 'Fishnets worn over bare skin and under no illusions.',
        stat_modifiers: { 'appearance' => 9, 'submit_lp_bonus' => 1 } }
    ].freeze

    def vex_outfit_stock(player)
      restored = vex_restored?(player)
      VEX_OUTFITS.select { |spec| spec[:tier] == :basic || restored }
    end

    def sync_vex_outfits!
      VEX_OUTFITS.each do |spec|
        record = ::Equipment.find_or_create(name: spec[:name]) do |e|
          e.type = spec[:type]
          e.slot = spec[:slot]
        end
        record.type = spec[:type]
        record.slot = spec[:slot]
        record.description = spec[:description]
        record.stat_modifiers = spec[:stat_modifiers]
        record.cost = spec[:cost]
        record.rarity = 3
        record.cursed = false
        record.violation_type = nil
        record.removal_cost = 0
        record.save_changes
      end
    end
    module_function :sync_vex_outfits!

    def vex_outfit_record(spec)
      ::Equipment.where(name: spec[:name], cursed: false).first
    end

    def vex_outfit_price(player, spec)
      [(spec[:cost] * Engine::ThreatCalculator.price_multiplier(player)).round, 1].max
    end

    def buy_vex_outfit!(player, equipment_id)
      if vex_exiled?(player)
        return { ok: false,
                 message: 'There is no counter. Vex is exiled, and her rack stands empty under the same ' \
                          'sheet as her bench.' }
      end

      sync_vex_outfits!
      item = ::Equipment[equipment_id.to_i]
      spec = item && VEX_OUTFITS.find { |s| s[:name] == item.name }
      return { ok: false, message: 'Vex does not sell that. Her eyebrow says so.' } unless spec
      unless vex_outfit_stock(player).include?(spec)
        return { ok: false, message: '"Not yet, delver. That rack opens when I have a room worth ' \
                                     'hanging it in." She does not elaborate. The kettle does, at length.' }
      end
      return { ok: false, message: "You already own **#{item.name}**." } if player.owns_equipment?(item.id)

      price = vex_outfit_price(player, spec)
      unless player.spend_lp!(price)
        return { ok: false, message: "\"Cash first, poetry later. **#{price} LP**, delver — you have " \
                                     "#{player.lp}.\"" }
      end

      grant = player.grant_equipment!(item, auto_equip: false)
      unless grant[:ok]
        player.refund_lp!(price)
        return grant
      end

      player.bump_tracker!('vex_outfits_bought')
      { ok: true,
        message: "Vex fits **#{item.name}** to you with a tailor's hands and a listener's silence. " \
                 "\"There,\" she says at last. \"Now the tower can read you properly.\" " \
                 "_(**#{price} LP** — equip it from `e,equipment`.)_" }
    end

    def negotiate_cost(player, item)
      base = [NEGOTIATE_MIN, item.removal_cost.to_i * 2].max
      vex_restored?(player) ? base * 2 : base
    end

    def negotiate_off!(player, equipment_id)
      if vex_exiled?(player)
        return { ok: false,
                 message: 'Vex is not receiving anyone. Covar threw her out of the back room, and her ' \
                          'bench stands empty under a sheet. He might forgive the situation — for a ' \
                          'certain value of *help him fix the dress*.' }
      end

      item = player.equipped_mimics.find { |i| i.id == equipment_id.to_i }
      return { ok: false, message: 'That piece is not being worn.' } unless item

      cost = negotiate_cost(player, item)
      unless player.spend_lp!(cost)
        return { ok: false, message: "Negotiation costs **#{cost} LP** — you have #{player.lp}." }
      end

      surcharge = vex_restored?(player)
      DB[:player_equipment].where(player_id: player.discord_id, equipment_id: item.id).update(is_equipped: false)
      player.clamp_defiance!
      { ok: true,
        message: "_Vex listens at the seams for a long moment, murmuring. The **#{item.name}** sighs — " \
                 'actually sighs — and lets go of you, intact. It goes back in your pack, negotiated off ' \
                 "for **#{cost} LP** instead of torn free._" \
                 "#{surcharge ? "\n_Her fee is doubled in the new room, and she itemises the reason without being asked: rent, kettle, and one (1) incubus landlord she declines to call a landlord._" : ''}" }
    end

    def refitted_names(player)
      Array(player.tracker_hash['gear_refitted']).map(&:to_s)
    end

    def refit!(player, equipment_id)
      if vex_exiled?(player)
        return { ok: false,
                 message: 'There is no bench to refit at. Vex is exiled, and the sheet over her worktable ' \
                          'has not moved in days.' }
      end

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
                 "#{queue.map { |k| SKETCH_LABELS[k] }.join(', then ')}. Exactly.\" " \
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
