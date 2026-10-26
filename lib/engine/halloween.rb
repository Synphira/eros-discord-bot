# frozen_string_literal: true

module Engine
  # Seasonal All Hallows' content. The calendar window lives on Weekly;
  # rewards earned here (titles, costumes, candy stockpiles, heard crumbs)
  # are permanent — the season only gates *earning* and *encounter rate*.
  module Halloween
    CANDY_TRACKER = 'halloween_candy'
    CANDY_EATEN = 'halloween_candy_eaten'
    CANDY_MAX = 12
    SUBMIT_TRACKER = 'halloween_submits'
    SCARES_OPTION = 'halloween_scares'

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

    CLERGY_LINES = {
      'Mimic Broodmother' => {
        victory: 'The Broodmother\'s lid clacks like a laugh. "Dress-up night," she croons. "My brood loves costumes. Especially the ones that scream."',
        praise: 'Little mimics bounce in paper masks. One of them is wearing your discarded dignity.'
      },
      'Succubus Queen' => {
        victory: 'The Queen adjusts a jewelled half-mask she was not wearing a moment ago. "Samhain etiquette," she purrs. "Kneel prettier."',
        praise: '"Masks make everyone honest," she says, and kisses the spot yours would cover.'
      },
      'Incubus King' => {
        victory: 'The King has horns painted gold for the night and zero shame. "Trick or treat," he says, already deciding you are both.',
        praise: 'He tugs a candy ribbon from nowhere and ties it around your wrist like a claim.'
      },
      'Verdant Dryad' => {
        victory: 'Autumn leaves crown her instead of flowers. "The garden dies beautifully this week," she murmurs. "So can you."',
        praise: 'She tucks a dried leaf behind your ear. It smells like smoke and sap.'
      },
      'Lich Lord' => {
        victory: 'Blue fire wears a paper crown. "All Hallows is when the living remember they are temporary," the Lich notes. "Useful curriculum."',
        praise: 'He stamps your skin with a cold sigil that looks, briefly, like a candy skull.'
      },
      'Alpha Beast' => {
        victory: 'Syn\'s pupper has a ridiculous bat-wing collar someone buckled on him. He is delighted. You are compromised.',
        praise: 'He drops a mouthful of foil-wrapped candy on your chest and looks enormously proud.'
      },
      'Eros' => {
        victory: 'The goddess tastes of caramel and endings. "I let the temple play dress-up one week a year," Eros says. "It behaves better after."',
        praise: 'A white tentacle offers you a sweet. Refusing is not among the options.'
      }
    }.freeze

    module_function

    def active?(now = Time.now)
      Engine::Weekly.halloween_window?(now)
    end

    def note_submit!(player)
      return unless active? && player

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

    def biome_weight_mult(biome_key)
      return 1.0 unless active?

      case biome_key.to_s
      when 'ashen_court', 'masquerade_ball', 'clockwork_brothel', 'bell_choir' then 1.75
      when 'flooded_grotto', 'honeyed_hive', 'milking_barns' then 0.85
      else 1.1
      end
    end

    def presence_text(users, towers)
      base = "with #{users} #{users == 1 ? 'user' : 'users'} in #{towers} #{towers == 1 ? 'tower' : 'towers'}"
      return "#{base}." unless active?

      "#{base} — masked delvers in the temple for All Hallows."
    end

    def clergy_line(boss_name, kind = :victory)
      return nil unless active?

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

    # Seasonal chest extras: candy always tries; unowned costume pieces sometimes.
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
  end
end
