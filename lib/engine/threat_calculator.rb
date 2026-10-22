# frozen_string_literal: true

module Engine
  class ThreatCalculator
    LOW_THRESHOLD = 40
    HIGH_THRESHOLD = 75

    LP_MAX = 45.0
    LP_SCALE_BASE = 300.0
    LP_SCALE_PER_LEVEL = 40.0
    CURSE_WEIGHT = 8
    CURSE_MAX = 32
    # Appearance is a first-class author of threat now: what a delver
    # wears (its `appearance` stat, plus a flat bonus for every living
    # piece on their body) can carry them a full category on its own.
    APPEARANCE_MAX = 40
    CURSED_PIECE_APPEARANCE = 10

    # Threat doubles as the tower's appearance reading: the higher it
    # climbs, the sluttier and more depraved the delver looks to every
    # monster, resident, and lord watching.
    APPEARANCE_LABELS = {
      low: 'Presentable',
      medium: 'Provocative',
      high: 'Depraved'
    }.freeze

    APPEARANCE_BLURBS = {
      low: 'The tower reads you as almost respectable. Almost.',
      medium: 'Heads turn as you pass. The tower has noticed what you are wearing — and what it is for.',
      high: 'Nothing about you is left to the imagination, and the tower is not imagining politely. ' \
             'Everything down here can see exactly what you are for.'
    }.freeze

    Result = Struct.new(
      :percent, :category, :lp_component, :curse_component, :appearance_component,
      :stat_mult, :lust_mult, :encounter_bonus,
      keyword_init: true
    )

    def self.calculate(player)
      new(player).calculate
    end

    def self.monster_modifiers(player)
      calculate(player)
    end

    def self.appearance_label(category)
      APPEARANCE_LABELS.fetch(category.to_sym, 'Presentable')
    end

    # Raw appearance points from what is on the delver's body right now:
    # every equipped item's `appearance` stat, plus a heavy flat reading
    # for each cursed (living) piece worn.
    def self.appearance_points(player)
      return 0 unless player.respond_to?(:equipped_items)

      player.equipped_items.sum do |item|
        mods = player.respond_to?(:gear_effects_for) ? player.gear_effects_for(item) : item.stat_modifiers
        points = mods['appearance'].is_a?(Numeric) ? mods['appearance'].to_f : 0.0
        points += CURSED_PIECE_APPEARANCE if item.cursed
        points
      end
    rescue StandardError
      0
    end

    def self.appearance_component(player)
      [[appearance_points(player), 0].max, APPEARANCE_MAX].min.round(1)
    end

    # --- Reaction tuning (appearance made mechanical) -----------------

    def self.satisfy_bonus(player)
      case calculate(player).category
      when :high then 0.06
      when :medium then 0.03
      else 0.0
      end
    end

    def self.lp_multiplier(player)
      case calculate(player).category
      when :high then 1.10
      when :medium then 1.05
      else 1.0
      end
    end

    def self.price_multiplier(player)
      case calculate(player).category
      when :high then 0.90
      when :medium then 0.95
      else 1.0
      end
    end

    # How much likelier the lustier kinds are to find a delver who
    # looks like an invitation.
    def self.encounter_weight(player, type)
      lusty = %w[demon slime beast].include?(type.to_s)
      return 1.0 unless lusty

      case calculate(player).category
      when :high then 1.30
      when :medium then 1.15
      else 1.0
      end
    end

    def self.appearance_line(player)
      result = calculate(player)
      "**Appearance — #{appearance_label(result.category)}** (Threat #{result.percent}%)\n" \
        "_#{APPEARANCE_BLURBS[result.category]}_\n" \
        "-# LP +#{result.lp_component}% · Curses +#{result.curse_component} · " \
        "Worn appearance +#{result.appearance_component}"
    end

    MONSTER_OPENERS = {
      medium: [
        'It looks you over once, slowly, and its hunger changes flavour — less meal, more invitation.',
        'Its eyes travel the length of what you are wearing and it smiles like you dressed for it. Perhaps you did.',
        'It circles you with open appreciation. Whatever you are selling down here, it is buying.'
      ],
      high: [
        'It stops dead at the sight of you. Whatever it came hunting, it was not expecting the hunt to dress like this.',
        'It drinks you in from boots to crown and forgets, for a heartbeat, how the fight was supposed to start.',
        'Its gaze crawls over every indecent inch of you and comes back hungry. You did this on purpose. It knows. It approves.'
      ]
    }.freeze

    def self.monster_opener(player)
      lines = MONSTER_OPENERS[calculate(player).category]
      lines ? "_#{lines.sample}_" : nil
    end

    BOSS_APPRAISALS = {
      medium: [
        'The lord\'s gaze snags on what you are wearing, and lingers a breath longer than courtesy allows.',
        'An appraising look travels over you. "You dressed for my court," the lord observes. It is not a question.'
      ],
      high: [
        'The lord looks you over the way scripture says the goddess looks at offerings — thoroughly, and with intent to use.',
        '"Oh," the lord says, with the satisfaction of a connoisseur presented with the good vintage. "The tower\'s rumours undersold you."'
      ]
    }.freeze

    def self.boss_appraisal(player)
      lines = BOSS_APPRAISALS[calculate(player).category]
      lines ? "_#{lines.sample}_" : nil
    end

    def initialize(player)
      @player = player
    end

    def calculate
      scale = LP_SCALE_BASE + (LP_SCALE_PER_LEVEL * @player.level.to_i)
      lp_component = LP_MAX * (1 - Math.exp(-[@player.lp.to_f, 0].max / scale))
      curse_component = [@player.active_curse_count * CURSE_WEIGHT, CURSE_MAX].min
      worn_component = self.class.appearance_component(@player)
      percent = [(lp_component + curse_component + worn_component), 100].min.round(1)
      category = categorize(percent)

      Result.new(
        percent: percent,
        category: category,
        lp_component: lp_component.round(1),
        curse_component: curse_component,
        appearance_component: worn_component,
        stat_mult: stat_multiplier(percent, category),
        lust_mult: lust_multiplier(percent, category),
        encounter_bonus: encounter_bonus(percent, category)
      )
    end

    def categorize(percent)
      if percent < LOW_THRESHOLD
        :low
      elsif percent < HIGH_THRESHOLD
        :medium
      else
        :high
      end
    end

    def stat_multiplier(percent, category)
      continuous = 0.85 + (percent / 100.0) * 0.75
      floor =
        case category
        when :low then 0.85
        when :medium then 1.0
        when :high then 1.25
        else 1.0
        end
      [[continuous, floor].max, 1.85].min.round(3)
    end

    def lust_multiplier(percent, category)
      continuous = 0.9 + (percent / 100.0) * 1.0
      floor =
        case category
        when :low then 0.9
        when :medium then 1.05
        when :high then 1.35
        else 1.0
        end
      [[continuous, floor].max, 2.25].min.round(3)
    end

    def encounter_bonus(percent, category)
      bonus = (percent / 5.0).round
      category_floor = { low: 0, medium: 5, high: 12 }.fetch(category, 0)
      [[bonus, category_floor].max, 25].min
    end
  end
end
