# frozen_string_literal: true

module Engine
  module Treasure
    module_function

    MIMIC_TEMPLATES = [
      {
        name: 'Seductive Lingerie',
        description: 'Delicate lace undergarments that enhance your allure but may have a mind of their own.',
        type: 'armor',
        slot: 'legs',
        stat_modifiers: { 'agility' => 1, 'lust_resist' => -1 },
        violation_type: 'tease',
        removal_cost: 10,
        rarity: 3
      },
      {
        name: 'Binding Corset',
        description: 'A tight corset that restricts your movement but enhances your curves.',
        type: 'armor',
        slot: 'chest',
        stat_modifiers: { 'resistance' => 2, 'agility' => -1 },
        violation_type: 'binding',
        removal_cost: 15,
        rarity: 3
      },
      {
        name: 'Enchanted Heels',
        description: 'Stylish heels that make you taller and more confident but seem to move on their own.',
        type: 'armor',
        slot: 'feet',
        stat_modifiers: { 'agility' => 1, 'lust_resist' => -1 },
        violation_type: 'positioning',
        removal_cost: 8,
        rarity: 3
      },
      {
        name: 'Living Necklace',
        description: 'A beautiful necklace that tightens when you are aroused.',
        type: 'accessory',
        slot: 'head',
        stat_modifiers: { 'resistance' => 1, 'lust_resist' => -1 },
        violation_type: 'choking',
        removal_cost: 12,
        rarity: 3
      },
      {
        name: "Throne's Throne",
        description: 'A throne-shaped buttplug that makes sitting interesting — and may take control.',
        type: 'accessory',
        slot: 'accessory',
        stat_modifiers: { 'resistance' => 2, 'submission' => 1 },
        violation_type: 'anal',
        removal_cost: 20,
        rarity: 4
      }
    ].freeze

    EVENT_MIMICS = [
      {
        name: 'Living Bodysuit',
        description: 'A second skin of glossy, breathing fabric that squeezes wherever you are most sensitive.',
        type: 'armor',
        slot: 'chest',
        stat_modifiers: { 'resistance' => 2, 'lust_resist' => -1 },
        violation_type: 'squeeze',
        removal_cost: 18,
        rarity: 4
      },
      {
        name: 'Living Stockings',
        description: 'Sheer stockings that crawl higher on their own, stroking your thighs with every step.',
        type: 'armor',
        slot: 'legs',
        stat_modifiers: { 'agility' => 2, 'lust_resist' => -1 },
        violation_type: 'squeeze',
        removal_cost: 14,
        rarity: 4
      },
      {
        name: 'Living Gloves',
        description: 'Silken gloves that sometimes decide where your hands should wander.',
        type: 'accessory',
        slot: 'accessory',
        stat_modifiers: { 'strength' => 2, 'lust_resist' => -1 },
        violation_type: 'squeeze',
        removal_cost: 14,
        rarity: 4
      },
      {
        name: 'Chastity Belt',
        description: 'A locked steel belt humming with denial magic. Release is no longer yours to decide.',
        type: 'armor',
        slot: 'groin',
        stat_modifiers: { 'submission' => 2, 'resistance' => 1, 'deny_climax' => true },
        violation_type: 'denial',
        removal_cost: 25,
        rarity: 5
      }
    ].freeze

    LIVING_CLOTHING = EVENT_MIMICS.first(3).freeze

    def all_mimic_templates
      MIMIC_TEMPLATES + EVENT_MIMICS
    end

    BASIC_GEAR = [
      {
        name: 'Cracked Buckler',
        type: 'armor',
        slot: 'accessory',
        description: 'A battered shield fragment that still turns a blow.',
        stat_modifiers: { 'resistance' => 1 },
        cost: 0,
        rarity: 1
      },
      {
        name: 'Traveler\'s Boots',
        type: 'armor',
        slot: 'feet',
        description: 'Worn leather boots. Better than bare stone.',
        stat_modifiers: { 'agility' => 1 },
        cost: 0,
        rarity: 1
      },
      {
        name: 'Reinforced Bracers',
        type: 'armor',
        slot: 'accessory',
        description: 'Simple bracers that steady your grip.',
        stat_modifiers: { 'strength' => 1 },
        cost: 0,
        rarity: 1
      },
      {
        name: 'Padded Vest',
        type: 'armor',
        slot: 'chest',
        description: 'Light padding — better than nothing.',
        stat_modifiers: { 'resistance' => 1 },
        cost: 0,
        rarity: 1
      },
      {
        name: 'Short Blade',
        type: 'weapon',
        slot: 'weapon',
        description: 'A plain iron short blade from some forgotten delver.',
        stat_modifiers: { 'strength' => 1 },
        cost: 0,
        rarity: 1
      }
    ].freeze

    def sync_to_db!
      (MIMIC_TEMPLATES + EVENT_MIMICS + BASIC_GEAR).each do |tpl|
        item = ::Equipment.find_or_create(name: tpl[:name]) do |e|
          apply_template!(e, tpl)
        end
        apply_template!(item, tpl)
        item.save_changes
      end
    end

    def apply_template!(record, tpl)
      record.type = tpl[:type]
      record.slot = tpl[:slot]
      record.description = tpl[:description]
      record.stat_modifiers = tpl[:stat_modifiers] || {}
      record.cost = tpl[:cost] || 0
      record.rarity = tpl[:rarity] || 1
      record.cursed = tpl.key?(:violation_type)
      record.violation_type = tpl[:violation_type]
      record.removal_cost = tpl[:removal_cost] || 0
    end
    module_function :apply_template!

    def open_chest(player)
      sync_to_db!
      level = [player.current_floor, 1].max
      lines = ["**Floor #{level}** — a glint in the dark.", 'You pry open a treasure chest and find:']

      mimic_chance = [[0.1 + (level * 0.02), 0.45].min, 0.1].max
      loot =
        if rand <= mimic_chance
          generate_mimic_loot(player, level)
        else
          generate_normal_loot(player, level)
        end

      lines.concat(loot[:lines])
      player.bump_tracker!('treasure_found')

      bonus_lp = player.curse_effect_sum('mimic_treasure_lp').round
      if bonus_lp.positive?
        player.gain_lp!(bonus_lp)
        lines << "Your craving for containers pays off — **+#{bonus_lp} LP** (now `#{player.lp}`)."
      end

      {
        lines: lines,
        climax: loot[:climax],
        broken: loot[:broken]
      }
    end

    UNOWNED_MIMIC_WEIGHT = 10
    OWNED_MIMIC_WEIGHT = 1

    def pick_mimic_template(player)
      owned = player.equipment_dataset.select_map(Sequel[:equipment][:name])
      weighted = MIMIC_TEMPLATES.map do |tpl|
        [tpl, owned.include?(tpl[:name]) ? OWNED_MIMIC_WEIGHT : UNOWNED_MIMIC_WEIGHT]
      end
      roll = rand * weighted.sum(&:last)
      weighted.each do |tpl, weight|
        return tpl if roll < weight

        roll -= weight
      end
      weighted.last.first
    end

    def generate_mimic_loot(player, level)
      template = pick_mimic_template(player)
      item = ::Equipment.first(name: template[:name])
      unless item
        return { lines: ['_The chest is empty — the mimic fled._'], climax: nil, broken: false }
      end

      if player.owns_equipment?(item.id)
        return generate_normal_loot(player, level).tap do |loot|
          loot[:lines].unshift("_The chest held another **#{item.name}**, but you already wear its twin — something else tumbles out instead._")
        end
      end

      grant = player.grant_equipment!(item, auto_equip: true)
      unless grant[:ok]
        return generate_normal_loot(player, level)
      end

      stats = format_stat_changes(item.stat_modifiers)
      lines = [
        "A suspicious **#{item.name}** — _#{item.description}_",
        "Stat bonus: #{stats}",
        "Removal cost: **#{item.removal_cost}** LP _(use `!remove #{item.name}`)_",
        'The item writhes as you touch it — it binds itself to you!',
        grant[:message]
      ]
      { lines: lines, climax: nil, broken: false }
    end

    def generate_normal_loot(player, level)
      lines = []
      climax = nil
      broken = false

      roll = rand(100)
      if roll < 35
        amount = TREASURE_LP_BASE + (level / 2) + player.curse_effect_sum('treasure_lp').round
        player.gain_lp!(amount)
        lines << "A pouch of lust-essence — **+#{amount} LP** (now `#{player.lp}`)."
      elsif roll < 60
        amount = 15 + (level * 2)
        before = player.defiance
        gained = player.heal_defiance!(amount)
        lines << "A **Defiance Tonic**. You drink it on the spot — **+#{gained} Defiance** " \
                 "(`#{before}` → `#{player.defiance}/#{player.max_defiance}`)."
      elsif roll < 85
        gear_lines = grant_random_basic_gear(player)
        lines.concat(gear_lines)
      else
        amount = 5 + (level / 3) + player.curse_effect_sum('treasure_lp').round
        player.gain_lp!(amount)
        lines << "Loose coins of lust-light — **+#{amount} LP** (now `#{player.lp}`)."
        if rand < 0.4
          lines.concat(grant_random_basic_gear(player))
        end
      end

      if rand < 0.08
        bonus = 8 + level
        gained = player.heal_defiance!(bonus)
        lines << "A cracked vial spills into your mouth — **+#{gained} Defiance** more (now `#{player.defiance}`)."
      end

      { lines: lines, climax: climax, broken: broken }
    end

    TREASURE_LP_BASE = 10

    def grant_random_basic_gear(player)
      candidates = BASIC_GEAR.map { |t| ::Equipment.first(name: t[:name]) }.compact
      candidates.reject! { |item| player.owns_equipment?(item.id) }
      if candidates.empty?
        amount = 8 + player.current_floor
        player.gain_lp!(amount)
        return ["You already own every scrap of common gear here — the chest yields **+#{amount} LP** instead."]
      end

      item = candidates.sample
      result = player.grant_equipment!(item, auto_equip: false)
      stats = format_stat_changes(item.stat_modifiers)
      [
        "You find **#{item.name}** — _#{item.description}_",
        "Stats: #{stats}",
        result[:message],
        '_Equip it with `!equip` when ready._'
      ]
    end

    def format_stat_changes(stats)
      return '_none_' if stats.nil? || stats.empty?

      stats.map do |stat, amount|
        next "`#{stat}`" if amount == true
        next "`#{stat}` #{amount}" unless amount.is_a?(Numeric)
        next "`#{stat}` ×#{amount}" if stat.to_s.end_with?('_mult', '_rate')

        sign = amount.positive? ? '+' : ''
        "`#{stat}` #{sign}#{amount}"
      end.join(', ')
    end
  end

  module MimicScenes
    module_function

    VIOLATION_TAGS = {
      'binding' => 'bondage', 'choking' => 'choking', 'anal' => 'anal', 'denial' => 'chastity'
    }.freeze

    def generate(violation_type, player, item_name)
      type = violation_type.to_s
      tag = VIOLATION_TAGS[type]
      type = 'tease' if tag && !Engine::ContentOptions.enabled?(player, tag)

      scene =
        case type
        when 'tease' then generate_tease_scene(player, item_name)
        when 'binding' then generate_binding_scene(player, item_name)
        when 'positioning' then generate_positioning_scene(player, item_name)
        when 'choking' then generate_choking_scene(player, item_name)
        when 'anal' then generate_anal_scene(player, item_name)
        when 'squeeze' then generate_squeeze_scene(player, item_name)
        when 'denial' then generate_denial_scene(player, item_name)
        end
      fallback = "The #{item_name} writhes against your skin, its movements sending shivers through your body."
      Engine::ContentOptions.pick(player, [scene].compact, fallback: [fallback])
    end

    def generate_tease_scene(player, item_name)
      parts = player.body_parts_list.map(&:to_s)
      scenes = []

      if parts.include?('vagina')
        scenes << "The #{item_name} shifts against your most sensitive areas, its fabric teasing your clit with supernatural awareness."
        scenes << "The #{item_name} tightens around your hips, pressing against your mound as if seeking your warmth."
        scenes << "The lace of the #{item_name} begins to move on its own, tracing patterns against your wet lips."
      end

      if parts.include?('penis')
        scenes << "The #{item_name} shifts, its fabric brushing against your balls and the base of your cock with deliberate intent."
        scenes << "The #{item_name} tightens around your hips, pressing against your groin as it comes alive."
        scenes << "The #{item_name}'s fabric seems to grow hands, stroking along your shaft with teasing touches."
      end

      if parts.include?('anus')
        scenes << "The #{item_name} shifts, a tendril of fabric slipping between your cheeks to tease your hole."
        scenes << "The #{item_name} seems to grow appendages, one of them pressing insistently against your anus."
        scenes << "The #{item_name} tightens around your hips, pulling your cheeks apart as it comes alive."
      end

      if parts.include?('breasts')
        scenes << "The #{item_name}'s fabric tightens around your breasts, its lace teasing your nipples to hardness."
        scenes << "The cups of the #{item_name} seem to grow tongues, licking at your sensitive nipples."
        scenes << "The #{item_name} shifts, its fabric brushing against your breasts with deliberate caresses."
      end

      scenes << "The #{item_name} writhes against your skin, its movements sending shivers through your body."
      Engine::ContentOptions.pick(player, scenes)
    end

    def generate_binding_scene(_player, item_name)
      [
        "The #{item_name} suddenly tightens, binding your limbs snugly in place.",
        "The #{item_name} grows additional straps, wrapping around your body and restricting your movement.",
        "The #{item_name} comes alive, its fabric binding you in an inescapable embrace.",
        "The #{item_name} shifts, wrapping around you and holding you in a vulnerable position.",
        "The #{item_name} tightens around your body, its fabric becoming unbreakable bindings."
      ].sample
    end

    def generate_positioning_scene(_player, item_name)
      [
        "The #{item_name} coaxes your body into a lewd position, making you present yourself invitingly.",
        "The #{item_name} shifts, moving your limbs until you're in a vulnerable pose.",
        "The #{item_name} takes control of your body, positioning you for easy access.",
        "The #{item_name} comes alive, tugging you into a deliciously shameless pose.",
        "The #{item_name} manipulates your limbs, arranging you like a doll for someone's pleasure."
      ].sample
    end

    def generate_choking_scene(_player, item_name)
      [
        "The #{item_name} tightens around your throat, cutting off your air and making you lightheaded with arousal.",
        "The #{item_name} comes alive, wrapping around your neck and constricting just enough to make you gasp.",
        "The #{item_name} shifts, tightening around your throat until you're breathing in shallow pants.",
        "The #{item_name} grows, its length wrapping around your neck and tightening with each breath.",
        "The #{item_name} constricts, making your head swim with oxygen deprivation and pleasure."
      ].sample
    end

    def generate_anal_scene(_player, item_name)
      [
        "The #{item_name} grows an appendage that slides into your ass, stretching you around its girth.",
        "The #{item_name} comes alive, a phallic shape emerging to fill your tight hole.",
        "The #{item_name} shifts, forming a plug that fills your ass and begins to move with a will of its own.",
        "The #{item_name} extends itself, easing into your anus and filling you completely.",
        "The #{item_name} reveals its true nature, a phallus that sinks into your ass and begins to thrust."
      ].sample
    end

    def generate_squeeze_scene(player, item_name)
      parts = player.body_parts_list.map(&:to_s)
      scenes = [
        "The #{item_name} contracts all at once, hugging every curve of you like a lover's full-body embrace.",
        "The #{item_name} ripples across your skin in slow waves, as if tasting you.",
        "The #{item_name} tightens and loosens in a steady rhythm, matching — then quickening — your heartbeat."
      ]
      scenes << "The #{item_name} stretches over your chest and kneads your breasts with hungry pressure." if parts.include?('breasts')
      scenes << "The #{item_name} molds itself around your cock, stroking it through the fabric." if parts.include?('penis')
      scenes << "The #{item_name} presses a slick seam against your folds and rubs." if parts.include?('vagina')
      Engine::ContentOptions.pick(player, scenes)
    end

    def generate_denial_scene(_player, item_name)
      [
        "The #{item_name} hums warmly, building you right up to the edge — then goes cold and still.",
        "The #{item_name} tightens with a click. Whatever you were about to feel, you won't be allowed to.",
        "The #{item_name} pulses with teasing vibrations that stop the instant you start to squirm.",
        "Heat blooms under the #{item_name}'s steel, the lock reminding you exactly who owns your release."
      ].sample
    end
  end
end
