# frozen_string_literal: true

require_relative 'seasons'

module Engine
  # All Hallows' Heat pack. Rewards earned here persist; the calendar only
  # gates earning and encounter rate.
  module Halloween
    KEY = 'halloween'
    CANDY_TRACKER = 'halloween_candy'
    CANDY_EATEN = 'halloween_candy_eaten'
    CANDY_MAX = 12
    SUBMIT_TRACKER = 'halloween_submits'
    SCARES_OPTION = 'halloween_scares'

    WEEKLY = {
      key: KEY,
      name: "All Hallows' Heat",
      description: 'The temple puts on a mask: undead and demons throng the halls, lust runs hotter (×1.1), ' \
                   'undead lust ×1.2, +3 LP submitting to undead / +2 to demons, elites ×1.5, and events 25% more often. ' \
                   'Mimics stir, biomes lean haunted, pumpkin altars and trick-or-treat rooms appear, Vex stocks costumes, ' \
                   'named folk dress for the night, and candy/titles/gear you earn stay after the season.',
      effects: {
        'lust_mult' => 1.1,
        'undead_lust_mult' => 1.2,
        'undead_submit_lp' => 3,
        'demon_submit_lp' => 2
      },
      monsters: { undead: 2.0, demon: 1.5, mimic: 1.35 },
      special: { 'elite_chance' => 1.5, 'event_rate' => 1.25, 'mimic_chance' => 1.25 }
    }.freeze

    COSTUME_NAMES = [
      'Masquerade Domino',
      'Pumpkin-Cut Bodice',
      'Cobweb Stockings'
    ].freeze

    COSTUMES = [
      { name: 'Masquerade Domino', slot: 'head', type: 'armor', cost: 55, tier: :halloween,
        description: 'A black lace half-mask. The temple loves a face that admits it came to play.',
        stat_modifiers: { 'appearance' => 9, 'satisfy_bonus' => 0.03, 'submit_lp_bonus' => 1 } },
      { name: 'Pumpkin-Cut Bodice', slot: 'chest', type: 'armor', cost: 95, tier: :halloween,
        description: 'Orange silk laced obscenely tight, carved like a jack-o\'-lantern\'s grin across the bust.',
        stat_modifiers: { 'appearance' => 13, 'lust_mult' => 1.08, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.05 } },
      { name: 'Cobweb Stockings', slot: 'legs', type: 'armor', cost: 65, tier: :halloween,
        description: 'Sheer black webs for thighs. Something always seems to catch in them.',
        stat_modifiers: { 'appearance' => 10, 'agility' => 1, 'submit_lp_bonus' => 1 } }
    ].freeze

    PUMPKIN_BLESSING = {
      key: 'pumpkin_glow', name: 'Pumpkin Glow', floors: 4,
      effects: { 'submit_lp_bonus' => 2, 'appearance' => 4, 'satisfy_bonus' => 0.04 },
      summary: 'Candle-warm and faintly orange — the temple likes your costume'
    }.freeze

    # Named characters only — not random encounter monsters. Alpha is always
    # Syn's handiwork.
    DRESS = {
      'Mimic Broodmother' => 'The Broodmother\'s lid is draped in tattered lace and paper bats her brood has glued on crooked. ' \
                            'She looks absurd. She looks delighted.',
      'Succubus Queen' => 'The Queen wears a jewelled half-mask and a gown cut for All Hallows — every inch of her ' \
                         'announces that costume is just another kind of throne.',
      'Incubus King' => 'The King has painted his horns gold and hung a cape that does nothing for his dignity. He ' \
                       'strikes a pose anyway.',
      'Verdant Dryad' => 'Autumn leaves crown the Dryad instead of summer flowers — a harvest halo, soft and inevitable.',
      'Lich Lord' => 'A paper crown sits atop blue fire. The Lich did not ask for it. Someone (Syn) insisted. He is ' \
                    'enduring the curriculum.',
      'Alpha Beast' => 'Syn has buckled a ridiculous bat-wing collar onto her pupper for All Hallows. He is delighted. ' \
                      'You are compromised.',
      'Eros' => 'Even the goddess has indulged the night — a ribbon of black lace somewhere a goddess should not need ' \
               'lace, and a smile that says the temple is allowed to play dress-up.',
      'Syn' => 'Syn has ink-smudged bat wings painted at the corners of her eyes and a needle tucked behind one ear ' \
              'like a festive pin. She looks like she invented the holiday to have an excuse.',
      'Berry' => 'Berry wears a tiny witch\'s hat at a practical angle and pretends it is for the customers. It is ' \
                'absolutely for Syn.',
      'Covar' => 'Covar has a mask. He claims it is for anonymity. It is velvet and fits him far too well.',
      'Madame Vex' => 'Vex\'s living cloth has agreed — for once — to look like cobweb silk. She looks like a ghost who ' \
                     'charges for fittings.',
      'Pip' => 'Pip is in a bedsheet ghost costume with eyeholes cut by someone who hates symmetry. She is very proud.'
    }.freeze

    CLERGY_LINES = {
      'Mimic Broodmother' => {
        victory: 'The Broodmother\'s lid clacks like a laugh. "Dress-up night," she croons. "My brood loves costumes. Especially the ones that scream."',
        praise: 'Little mimics bounce in paper masks. One of them is wearing your discarded dignity.'
      },
      'Succubus Queen' => {
        victory: 'The Queen adjusts her jewelled half-mask. "Samhain etiquette," she purrs. "Kneel prettier."',
        praise: '"Masks make everyone honest," she says, and kisses the spot yours would cover.'
      },
      'Incubus King' => {
        victory: 'Gold-painted horns catch the light. "Trick or treat," the King says, already deciding you are both.',
        praise: 'He tugs a candy ribbon from nowhere and ties it around your wrist like a claim.'
      },
      'Verdant Dryad' => {
        victory: 'Autumn leaves crown her. "The garden dies beautifully this week," she murmurs. "So can you."',
        praise: 'She tucks a dried leaf behind your ear. It smells like smoke and sap.'
      },
      'Lich Lord' => {
        victory: 'The paper crown tips. "All Hallows is when the living remember they are temporary," the Lich notes. "Useful curriculum."',
        praise: 'He stamps your skin with a cold sigil that looks, briefly, like a candy skull.'
      },
      'Alpha Beast' => {
        victory: 'Syn\'s pupper shakes his bat-wing collar proudly. He is delighted. You are compromised.',
        praise: 'He drops a mouthful of foil-wrapped candy on your chest and looks enormously proud.'
      },
      'Eros' => {
        victory: 'The goddess tastes of caramel and endings. "I let the temple play dress-up one week a year," Eros says. "It behaves better after."',
        praise: 'A white tentacle offers you a sweet. Refusing is not among the options.'
      }
    }.freeze

    module_function

    def key
      KEY
    end

    def name
      WEEKLY[:name]
    end

    def weekly
      WEEKLY
    end

    def window?(now = Time.now)
      start = Time.new(now.year, 10, 30)
      finish = Time.new(now.year, 11, 6)
      now >= start && now < finish
    end

    def ends_at(now = Time.now)
      Time.new(now.year, 11, 6).to_i
    end

    def active?(now = Time.now)
      Engine::Seasons.active?(:halloween, now) ||
        (Engine::Seasons.forced_key == KEY)
    end

    # Called only while this pack is the active season (or forced) — do not
    # re-gate on Time.now here (Seasons may be probing a simulated date).
    def dress_line(who)
      DRESS[who.to_s]
    end

    def note_submit!(player)
      return unless player && (active? || Engine::Seasons.forced_key == KEY)

      player.bump_tracker!(SUBMIT_TRACKER)
    end

    def candy_count(player)
      player.tracker(CANDY_TRACKER)
    end

    def grant_candy!(player, amount = 1)
      have = candy_count(player)
      add = [[amount.to_i, 0].max, CANDY_MAX - have].min
      return 0 if add <= 0

      player.set_tracker!(CANDY_TRACKER, have + add)
      add
    end

    def eat_candy!(player)
      have = candy_count(player)
      return { ok: false, message: 'Your candy pouch is empty.' } if have <= 0

      player.set_tracker!(CANDY_TRACKER, have - 1)
      player.bump_tracker!(CANDY_EATEN)
      case rand(3)
      when 0
        gained = player.heal_defiance!(12)
        { ok: true, message: "You unwrap a sticky sweet. Warmth knits through you — **+#{gained} Defiance** " \
                             "(#{candy_count(player)} candy left)." }
      when 1
        player.gain_lp!(8)
        { ok: true, message: "Sugar and lust-light burst on your tongue — **+8 LP** (now `#{player.lp}`). " \
                             "#{candy_count(player)} candy left." }
      else
        before = player.lust
        player.update(lust: [player.lust - 8, 0].max)
        { ok: true, message: "Cool caramel settles the heat — **−#{before - player.lust} Lust** (now `#{player.lust}`). " \
                             "#{candy_count(player)} candy left." }
      end
    end

    def status_consumables(player)
      count = candy_count(player)
      return [] unless count.positive?

      [{ id: 'halloween_candy', label: 'Halloween Candy', count: count, max: CANDY_MAX }]
    end

    def biome_weight_mult(biome_key)
      case biome_key.to_s
      when 'ashen_court', 'masquerade_ball', 'clockwork_brothel', 'bell_choir' then 1.75
      when 'flooded_grotto', 'honeyed_hive', 'milking_barns' then 0.85
      else 1.1
      end
    end

    def presence_suffix
      ' — masked delvers in the temple for All Hallows.'
    end

    def presence_text(users, towers)
      Engine::Seasons.presence_text(users, towers)
    end

    def clergy_line(boss_name, kind = :victory)
      key = kind.to_sym == :praise ? :praise : :victory
      CLERGY_LINES.dig(boss_name.to_s, key)
    end

    def syn_halloween_unlocked?(player)
      player.tracker('syn_halloween_crumb').positive? || active?
    end

    def mark_syn_crumb!(player)
      player.set_tracker!('syn_halloween_crumb', 1)
    end

    def costume_stock?
      active?
    end

    def pumpkin_altar?
      active?
    end

    def chest_bonus!(player)
      return [] unless active?

      lines = []
      added = grant_candy!(player, rand(1..2))
      if added.positive?
        lines << "Foil-wrapped **Halloween Candy** tumbles out — stashed for later " \
                 "(**#{candy_count(player)}/#{CANDY_MAX}** in your pouch)."
      end
      if rand < 0.22
        Engine::Residents.sync_vex_outfits!
        piece = COSTUMES.reject { |s| (item = ::Equipment.first(name: s[:name])) && player.owns_equipment?(item.id) }.sample
        if piece && (item = ::Equipment.first(name: piece[:name]))
          grant = player.grant_equipment!(item, auto_equip: false)
          if grant[:ok]
            lines << "A costume piece: **#{item.name}** — _#{item.description}_ " \
                     '(keeps forever; equip from `e,equipment`).'
          end
        end
      end
      lines
    end

    Engine::Seasons.register!(KEY, self)
  end
end
