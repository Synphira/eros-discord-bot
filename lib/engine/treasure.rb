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
        requires: 'breast_play',
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
        requires: 'bondage',
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
        requires: 'feet',
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
        requires: 'choking',
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
        requires: 'anal',
        part: 'anus',
        removal_cost: 20,
        rarity: 4
      },
      {
        name: 'Dagger of Aching Desire',
        description: 'A wicked dagger that throbs with inner heat. Each wound it deals pulls pleasure out of the victim and into the wielder.',
        type: 'weapon',
        slot: 'weapon',
        stat_modifiers: { 'damage' => 6, 'lust_resist' => -1 },
        violation_type: 'heat',
        requires: 'aphrodisiacs',
        removal_cost: 20,
        rarity: 4
      },
      {
        name: 'Whip of Will-Breaking',
        description: 'A whip that moves on its own. Each strike leaves the target more willing to submit to its wielder.',
        type: 'weapon',
        slot: 'weapon',
        stat_modifiers: { 'damage' => 4, 'submission' => 1 },
        violation_type: 'whip',
        requires: 'spanking',
        removal_cost: 18,
        rarity: 4
      },
      {
        name: 'Tentacle Vine Belt',
        description: 'A belt of glossy living vines that never stop exploring what they hold.',
        type: 'armor',
        slot: 'groin',
        stat_modifiers: { 'resistance' => 1, 'submission' => 1 },
        violation_type: 'tentacle',
        requires: 'tentacles',
        removal_cost: 18,
        rarity: 4
      },
      {
        name: 'Nectar Milking Bra',
        description: 'A soft harness bra that kneads, squeezes and collects whatever you leak.',
        type: 'armor',
        slot: 'chest',
        stat_modifiers: { 'resistance' => 1, 'lust_resist' => -1 },
        violation_type: 'milk',
        requires: 'lactation',
        part: 'breasts',
        removal_cost: 18,
        rarity: 4
      },
      {
        name: 'Knotted Tail Plug',
        description: 'A thick plug with a swelling knot that loves to lodge itself deep and stay.',
        type: 'accessory',
        slot: 'accessory',
        stat_modifiers: { 'submission' => 1, 'resistance' => 1 },
        violation_type: 'knot',
        requires: 'knotting',
        part: 'anus',
        removal_cost: 20,
        rarity: 4
      },
      {
        name: 'Possessed Pendant',
        description: 'A pendant with something old inside it, whispering suggestions your body obeys first.',
        type: 'accessory',
        slot: 'head',
        stat_modifiers: { 'submission' => 1, 'lust_resist' => -1 },
        violation_type: 'possess',
        requires: 'possession',
        removal_cost: 16,
        rarity: 4
      },
      {
        name: 'Hypno Spiral Spectacles',
        description: 'Spectacles etched with slow spirals. Looking through them makes obedience feel restful.',
        type: 'armor',
        slot: 'head',
        stat_modifiers: { 'agility' => 1, 'submission' => 1 },
        violation_type: 'hypno',
        requires: 'mind_control',
        removal_cost: 16,
        rarity: 4
      },
      {
        name: 'Sheer Exhibition Cloak',
        description: 'A cloak that turns transparent exactly when someone is looking.',
        type: 'armor',
        slot: 'chest',
        stat_modifiers: { 'agility' => 1, 'satisfy_bonus' => 0.03 },
        violation_type: 'tease',
        requires: 'exhibitionism',
        removal_cost: 14,
        rarity: 3
      },
      {
        name: 'Buzzing Toy Harness',
        description: 'A harness of humming little toys pressed against everything that makes you squirm.',
        type: 'armor',
        slot: 'groin',
        stat_modifiers: { 'submission' => 1, 'lust_resist' => -1 },
        violation_type: 'tease',
        requires: 'toys',
        removal_cost: 18,
        rarity: 4
      },
      {
        name: 'Good Pet Collar',
        description: 'A plush collar with a bell and a tag engraved GOOD PET. It adores being led.',
        type: 'accessory',
        slot: 'head',
        stat_modifiers: { 'submission' => 2 },
        violation_type: 'binding',
        requires: 'petplay',
        removal_cost: 15,
        rarity: 3
      },
      {
        name: 'Living Maid Uniform',
        description: 'A crisp little uniform that keeps smoothing itself — and you — into perfect service.',
        type: 'armor',
        slot: 'chest',
        stat_modifiers: { 'resistance' => 1, 'submission' => 1 },
        violation_type: 'squeeze',
        requires: 'maid_service',
        removal_cost: 18,
        rarity: 4
      },
      {
        name: 'Pony Bridle',
        description: 'Soft leather straps and a polished bit that make your posture proud and obedient.',
        type: 'armor',
        slot: 'head',
        stat_modifiers: { 'strength' => 1, 'submission' => 1 },
        violation_type: 'binding',
        requires: 'pony_play',
        removal_cost: 16,
        rarity: 4
      },
      {
        name: 'Tickle-Feather Gloves',
        description: 'Gloves sprouting soft feathers that brush every ticklish inch they can reach.',
        type: 'accessory',
        slot: 'accessory',
        stat_modifiers: { 'agility' => 2, 'lust_resist' => -1 },
        violation_type: 'tickle',
        requires: 'tickling',
        removal_cost: 14,
        rarity: 3
      },
      {
        name: 'Musk-Soaked Scarf',
        description: 'A scarf heavy with a heady, animal musk that keeps your body warm and wanting.',
        type: 'armor',
        slot: 'head',
        stat_modifiers: { 'resistance' => 1, 'lust_resist' => -1 },
        violation_type: 'heat',
        requires: 'musk',
        removal_cost: 12,
        rarity: 3
      },
      {
        name: 'Broodmother Plug',
        description: 'A smooth plug that swells warm and heavy inside your ass, pulsing like something about to hatch.',
        type: 'accessory',
        slot: 'accessory',
        stat_modifiers: { 'submission' => 1, 'lust_resist' => -1 },
        violation_type: 'egg',
        requires: 'oviposition',
        part: 'anus',
        removal_cost: 20,
        rarity: 4
      }
    ].freeze

    WEAPON_PROCS = {
      'Dagger of Aching Desire' => {
        steal_lp: 3,
        hit: 'The dagger pulses as it strikes, draining pleasure from the %<name>s and pouring it into you — **+%<lp>s LP**.',
        backlash_chance: 0.25,
        backlash_lust: 15,
        backlash: "The dagger's heat suddenly floods your own body, overwhelming you with desire! Lust **+%<lust>s** (now %<now>s).",
        condition: { key: 'aching_heat', name: 'Overwhelming Arousal', floors: 2, effects: { 'lust_mult' => 1.15 } }
      },
      'Whip of Will-Breaking' => {
        pliant: 0.15,
        pliant_cap: 0.45,
        hit: 'The whip cracks with unnatural force — the %<name>s grows more pliable to your will _(satisfy +%<pct>s%% this fight)_.',
        backlash_chance: 0.3,
        backlash: 'The whip coils back and lashes *you* — suddenly you are desperate to please your enemies!',
        condition: { key: 'submissive_urge', name: 'Submissive Urge', floors: 2,
                     effects: { 'submission' => 2, 'strength' => -1, 'flee_bonus' => -0.15 } }
      }
    }.freeze

    EVENT_MIMICS = [
      {
        name: 'Living Bodysuit',
        description: 'A second skin of glossy, breathing fabric that squeezes wherever you are most sensitive.',
        type: 'armor',
        slot: 'chest',
        stat_modifiers: { 'resistance' => 2, 'lust_resist' => -1 },
        violation_type: 'squeeze',
        requires: 'living_clothing',
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
        requires: 'living_clothing',
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
        requires: 'living_clothing',
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
        requires: 'chastity',
        removal_cost: 25,
        rarity: 5
      }
    ].freeze

    LIVING_CLOTHING = EVENT_MIMICS.first(3).freeze

    def all_mimic_templates
      MIMIC_TEMPLATES + EVENT_MIMICS
    end

    def template_for(name)
      all_mimic_templates.find { |t| t[:name] == name.to_s }
    end

    # Cursed gear only binds a delver whose content toggles allow its theme,
    # and only onto a body that has the part it is made for.
    def template_allowed?(player, tpl)
      return false unless tpl

      req = tpl[:requires]
      return false if req && !Engine::ContentOptions.enabled?(player, req)

      part = tpl[:part]
      return false if part && !player.body_parts_list.map(&:to_s).include?(part.to_s)

      true
    end

    def eligible_mimic_templates(player, templates = MIMIC_TEMPLATES)
      templates.select { |t| template_allowed?(player, t) }
    end

    # Why a template is sealed for this delver, in player-facing words, or
    # nil when it can bind them. Content preferences are named before body
    # requirements so the delver knows what could actually be changed.
    def template_block_reason(player, tpl)
      return 'That piece is not in the Cursed Shop.' unless tpl

      req = tpl[:requires]
      if req && !Engine::ContentOptions.enabled?(player, req)
        return "re-enable **#{requires_label(tpl)}** in `/options` to call it back"
      end

      part = tpl[:part]
      if part && !player.body_parts_list.map(&:to_s).include?(part.to_s)
        return "it needs #{part.to_s.tr('_', ' ')} your body does not have"
      end

      nil
    end

    def requires_label(tpl)
      req = tpl && tpl[:requires]
      req ? Engine::ContentOptions.preference(req)&.fetch(:label, req) : nil
    end

    def weapon_proc!(player, enc, log)
      weapon = player.equipment_for_slot('weapon') or return
      spec = WEAPON_PROCS[weapon.name] or return

      if spec[:steal_lp]
        player.gain_lp!(spec[:steal_lp])
        log << format(spec[:hit], name: enc[:name], lp: spec[:steal_lp])
      end
      if spec[:pliant]
        enc[:pliant] = [enc[:pliant].to_f + spec[:pliant], spec[:pliant_cap]].min
        log << format(spec[:hit], name: enc[:name], pct: (enc[:pliant] * 100).round)
      end
      return unless rand < spec[:backlash_chance]

      player.gain_lust!(spec[:backlash_lust]) if spec[:backlash_lust]
      log << format(spec[:backlash], lust: spec[:backlash_lust], now: player.lust)
      Engine::FetishEvents.apply_condition!(player, spec[:condition], log)
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
        stat_modifiers: { 'resistance' => 1, 'appearance' => -1 },
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

    CHEST_FIND_FLOOR = 8
    CHEST_FIND_CHANCE = 0.45

    CHEST_FINDS = [
      { name: "Old Champion's Sword", type: 'weapon', slot: 'weapon', cost: 60, rarity: 3,
        description: 'A notched blade from a delver who made it further than most.',
        stat_modifiers: { 'strength' => 4, 'damage' => 2, 'crit_chance' => 0.05, 'appearance' => 1 } },
      { name: 'Ghostsilk Gloves', type: 'accessory', slot: 'accessory', cost: 60, rarity: 3,
        description: 'Gloves so light they seem to move a moment before you do.',
        stat_modifiers: { 'agility' => 2, 'dodge_bonus' => 0.06, 'appearance' => 1 } },
      { name: "Sister's Veil", type: 'armor', slot: 'head', cost: 60, rarity: 3,
        description: 'A blessed veil left behind by some devout delver. Touches feel distant through it. ' \
                     'The tower, unfortunately, reads devotion as an invitation.',
        stat_modifiers: { 'resistance' => 2, 'lust_resist' => 2, 'appearance' => 5 } },
      { name: "Delver's Lucky Boots", type: 'armor', slot: 'feet', cost: 60, rarity: 3,
        description: 'Scuffed boots with a knack for kicking open loose floorboards.',
        stat_modifiers: { 'agility' => 2, 'treasure_lp' => 3, 'explore_lp' => 1 } },
      { name: 'Moonlit Mail', type: 'armor', slot: 'chest', cost: 60, rarity: 3,
        description: 'Fine silvered mail that stays cool no matter how hot things get.',
        stat_modifiers: { 'resistance' => 4, 'max_hp' => 10, 'lust_resist' => 1, 'appearance' => 1 } }
    ].freeze

    def sync_to_db!
      (MIMIC_TEMPLATES + EVENT_MIMICS + BASIC_GEAR + CHEST_FINDS).each do |tpl|
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

    CHEST_NAME = 'Treasure Chest'
    CHEST_INTROS = [
      'A chest sits alone in an alcove, its lid open just a crack. Something inside glints and seems to whisper your name.',
      'An ornate chest waits in the middle of the room, gold trim catching the light. It looks far too inviting.',
      'A battered old chest is half-buried in rubble. The lock has already been broken. Someone left in a hurry.',
      'A velvet-lined chest rests on a pedestal, the lid propped open on a single golden hinge. You can almost hear it breathing.'
    ].freeze
    MIMIC_TELLS = [
      'The lock is warm to the touch, and you could swear the keyhole just *licked its lips*.',
      'A thin string of drool runs from under the lid.',
      'The wood grain shifts when you look away, as if the chest is leaning toward you.'
    ].freeze
    LEAVE_LINES = [
      'You turn your back on the chest and walk away. Its whispers fade behind you, and a quiet pride settles in your chest.',
      'Not today. You leave the chest unopened, and the tower\'s pull loosens its grip on you a little.',
      'You step past the chest without a second look. Denying the tower feels better than you expected.'
    ].freeze

    def mimic_chance(level)
      [[0.1 + (level * 0.02), 0.45].min, 0.1].max
    end

    def leave_defiance(player)
      [(player.max_defiance * 0.04).round, 3].max
    end

    def chest_choices(player)
      [
        { key: 'open', label: 'Open it', text: 'Gold, tonics, gear, or something alive', style: :success },
        { key: 'leave', label: 'Leave it', text: "Resist the temptation (+#{leave_defiance(player)} defiance)",
          style: :secondary }
      ]
    end

    def present_chest!(player)
      level = [player.current_floor, 1].max
      mimic = rand <= mimic_chance(level)
      player.store_event!(type: 'chest', level: level, mode: 'choice', name: CHEST_NAME, mimic: mimic)
      log = ["**Floor #{level}** — a glint in the dark.", { scene: CHEST_INTROS.sample }]
      tell_chance = (0.25 + (player.effective_agility * 0.01)).clamp(0.25, 0.6)
      log << "_#{MIMIC_TELLS.sample}_" if mimic && rand < tell_chance
      log << 'Do you open it?'
      { ok: true, mode: :choice, name: CHEST_NAME, colour: 0xb8860b, log: log, choices: chest_choices(player) }
    end

    def choose_chest!(player, data, choice)
      return { ok: true, mode: :choice, name: CHEST_NAME, colour: 0xb8860b, log: ['Open it or leave it?'],
               choices: chest_choices(player) } unless %w[open leave].include?(choice)

      player.clear_event!
      if choice == 'leave'
        before = player.defiance
        gained = player.heal_defiance!(leave_defiance(player))
        player.bump_tracker!('chests_ignored')
        detail = gained.positive? ? "**+#{gained} Defiance** (`#{before}` → `#{player.defiance}/#{player.max_defiance}`)." :
                                    '_Your defiance is already full._'
        return { ok: true, mode: :done, name: CHEST_NAME, colour: 0x4a7c59, choices: [],
                 log: [LEAVE_LINES.sample, detail] }
      end

      result = open_chest(player, mimic: data[:mimic])
      if result[:fight] && result[:monster]
        return { ok: true, mode: :combat, name: CHEST_NAME, colour: 0x8b0000, log: result[:lines],
                 monster: result[:monster], choices: [] }
      end

      { ok: true, mode: :done, name: CHEST_NAME, colour: 0xb8860b, choices: [], log: result[:lines],
        broken: result[:broken] }
    end

    def open_chest(player, mimic: nil)
      sync_to_db!
      level = [player.current_floor, 1].max
      lines = ['You pry open the chest and find:']

      mimic = rand <= mimic_chance(level) if mimic.nil?
      if mimic && eligible_mimic_templates(player).empty?
        # No cursed gear matches this delver's tastes, so the chest itself
        # rears up as a mimic to fight instead of binding them. The chest
        # was still opened — it counts toward chest totals either way.
        player.bump_tracker!('treasure_found')
        monster = Engine::MonsterTypes.generate_monster(level, player: player, type: :mimic)
        ambush = ['The lid snaps open on a mouth full of golden teeth — no gear in here matches your tastes, ' \
                  'so the chest itself lunges! **Chest Mimic!**']
        return { lines: ambush, climax: nil, broken: false, monster: monster, fight: true }
      end

      loot =
        if mimic
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
      pool = eligible_mimic_templates(player)
      return nil if pool.empty?

      owned = player.equipment_dataset.select_map(Sequel[:equipment][:name])
      weighted = pool.map do |tpl|
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
      return { lines: ['_The chest is empty — the mimic fled._'], climax: nil, broken: false } unless template

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
        "Removal cost: **#{item.removal_cost}** LP _(use `e,remove #{item.name}`)_",
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
      if roll < 30
        amount = TREASURE_LP_BASE + (level / 2) + player.curse_effect_sum('treasure_lp').round
        player.gain_lp!(amount)
        lines << "A pouch of lust-essence — **+#{amount} LP** (now `#{player.lp}`)."
      elsif roll < 45
        amount = 15 + (level * 2)
        before = player.defiance
        gained = player.heal_defiance!(amount)
        lines << "A **Defiance Tonic**. You drink it on the spot — **+#{gained} Defiance** " \
                 "(`#{before}` → `#{player.defiance}/#{player.max_defiance}`)."
      elsif roll < 75
        gear_lines = grant_random_basic_gear(player)
        lines.concat(gear_lines)
      elsif roll < 85
        lines.concat(grant_random_consumable(player))
      else
        amount = 5 + (level / 3) + player.curse_effect_sum('treasure_lp').round
        player.gain_lp!(amount)
        lines << "Loose coins of lust-light — **+#{amount} LP** (now `#{player.lp}`)."
        if rand < 0.4
          lines.concat(grant_random_basic_gear(player))
        end
      end

      if rand < 0.08 && player.defiance < player.max_defiance
        bonus = 8 + level
        gained = player.heal_defiance!(bonus)
        lines << "A cracked vial spills into your mouth — **+#{gained} Defiance** more (now `#{player.defiance}`)."
      end

      { lines: lines, climax: climax, broken: broken }
    end

    TREASURE_LP_BASE = 10

    def grant_random_basic_gear(player)
      if player.current_floor >= CHEST_FIND_FLOOR && rand < CHEST_FIND_CHANCE
        finds = CHEST_FINDS.map { |t| ::Equipment.first(name: t[:name]) }.compact
        find = finds.reject { |item| player.owns_equipment?(item.id) }.sample
        return describe_found_gear(player, find, rare: true) if find
      end

      candidates = BASIC_GEAR.map { |t| ::Equipment.first(name: t[:name]) }.compact
      candidates.reject! { |item| player.owns_equipment?(item.id) }
      return describe_found_gear(player, candidates.sample) if candidates.any?

      shop_lines = grant_fallback_shop_gear(player)
      return shop_lines if shop_lines

      amount = 25 + (player.current_floor * 2)
      player.gain_lp!(amount)
      ["You already own every piece of gear the tower keeps in its chests — it melts into **+#{amount} LP** instead."]
    end

    # Once a delver owns all the chest-only gear, chests start coughing up
    # unowned shop gear instead of quietly downgrading the drop to LP.
    def grant_fallback_shop_gear(player)
      Engine::Shop.sync_to_db!
      names = Engine::Shop::INVENTORY.reject { |i| i[:slot] == 'consumable' }.map { |i| i[:name] }
      items = names.map { |n| ::Equipment.first(name: n) }.compact
      items.reject! { |item| player.owns_equipment?(item.id) }
      return nil if items.empty?

      ['_The common chest gear is all yours already — something from the shop shelves tumbles out instead!_'] +
        describe_found_gear(player, items.sample)
    end

    def grant_random_consumable(player)
      pool = []
      pool << :draught if player.defiance < player.max_defiance
      pool << :elixir if player.lust.positive?
      pool << :sanctuary unless player.sanctuary
      case pool.sample
      when :draught
        before = player.defiance
        gained = player.heal_defiance!((player.max_defiance * Engine::Shop::DRAUGHT_PCT).round)
        ["A **Defiance Draught**. You down it on the spot — **+#{gained} Defiance** " \
         "(`#{before}` → `#{player.defiance}/#{player.max_defiance}`)."]
      when :elixir
        before = player.lust
        player.update(lust: [player.lust - Engine::Shop::ELIXIR_LUST, 0].max)
        ["A **Cooling Elixir**. Cool relief spreads through you — **−#{before - player.lust} Lust** (now `#{player.lust}`)."]
      when :sanctuary
        player.update(sanctuary: true)
        ['A **Bottled Sanctuary**. You drink it down — your next exploration will be safe.']
      else
        amount = 10 + player.current_floor
        player.gain_lp!(amount)
        ["A bundle of supplies you can't use right now melts into **+#{amount} LP** (now `#{player.lp}`)."]
      end
    end

    def describe_found_gear(player, item, rare: false)
      result = player.grant_equipment!(item, auto_equip: false)
      [
        "#{rare ? 'A rare find! ' : ''}You find **#{item.name}** — _#{item.description}_",
        "Stats: #{format_stat_changes(item.stat_modifiers)}",
        result[:message],
        '_Equip it with `e,equip` when ready._'
      ]
    end

    FLAT_LABELS = {
      'strength' => 'STR', 'agility' => 'AGI', 'resistance' => 'RES', 'submission' => 'Submission',
      'damage' => 'damage', 'max_hp' => 'max defiance', 'defiance_regen' => 'defiance per combat round',
      'victory_lp_bonus' => 'LP per victory', 'explore_lp' => 'LP per room explored', 'treasure_lp' => 'LP from chests',
      'hit_lp' => 'LP when a monster gets its hands on you', 'submit_lp_bonus' => 'LP when you submit',
      'appearance' => 'Appearance'
    }.freeze
    PERCENT_LABELS = {
      'flee_bonus' => 'flee chance', 'crit_chance' => 'surprise-hit chance (double damage)',
      'lifesteal' => 'of damage dealt returned as defiance', 'dodge_bonus' => 'dodge chance',
      'satisfy_bonus' => 'satisfy chance', 'trap_avoid_bonus' => 'trap avoidance',
      'intimidate_chance' => 'chance a monster backs off without touching you'
    }.freeze
    FLAG_LABELS = { 'deny_climax' => 'orgasms denied', 'cheat_death' => 'survive one defeat per run' }.freeze
    TYPE_NAMES = { 'beast' => 'beasts', 'demon' => 'demons', 'slime' => 'slimes', 'undead' => 'undead',
                   'plant' => 'plants', 'mimic' => 'mimics' }.freeze

    def format_stat_changes(stats)
      return '_none_' if stats.nil? || stats.empty?

      stats.map { |stat, amount| format_stat(stat.to_s, amount) }.join(', ')
    end

    def format_stat(stat, amount)
      return FLAG_LABELS.fetch(stat, stat.tr('_', ' ')) if amount == true
      return "#{stat.tr('_', ' ')} #{amount}" unless amount.is_a?(Numeric)

      sign = ->(n) { n.negative? ? "−#{n.abs}" : "+#{n}" }
      pct = ->(n) { sign.call((n * 100).round) + '%' }
      type, kind = stat.match(/\A(beast|demon|slime|undead|plant|mimic)_(thorns|lust_mult|dodge_bonus)\z/)&.captures
      case
      when FLAT_LABELS.key?(stat) then "#{sign.call(amount)} #{FLAT_LABELS[stat]}"
      when PERCENT_LABELS.key?(stat) then "#{pct.call(amount)} #{PERCENT_LABELS[stat]}"
      when stat == 'lust_resist' then "#{sign.call(-amount)} lust per hit"
      when stat == 'lust_mult' then "#{pct.call(amount - 1)} lust taken"
      when stat == 'encounter_rate' then "#{pct.call(amount - 1)} monster rooms"
      when kind == 'thorns' then "#{sign.call(amount)} damage vs #{TYPE_NAMES[type]}"
      when kind == 'lust_mult' then "#{pct.call(amount - 1)} lust from #{TYPE_NAMES[type]}"
      when kind == 'dodge_bonus' then "#{pct.call(amount)} dodge vs #{TYPE_NAMES[type]}"
      when stat.end_with?('_mult', '_rate') then "#{stat.tr('_', ' ')} ×#{amount}"
      else "#{sign.call(amount)} #{stat.tr('_', ' ')}"
      end
    end
  end

  module MimicScenes
    module_function

    VIOLATION_TAGS = {
      'binding' => 'bondage', 'choking' => 'choking', 'anal' => 'anal', 'denial' => 'chastity', 'whip' => 'spanking',
      'squeeze' => 'living_clothing', 'heat' => 'aphrodisiacs', 'tentacle' => 'tentacles', 'milk' => 'lactation',
      'knot' => 'knotting', 'possess' => 'possession', 'hypno' => 'mind_control', 'tickle' => 'tickling',
      'egg' => 'oviposition'
    }.freeze

    def generate(violation_type, player, item_name)
      type = violation_type.to_s
      tag = VIOLATION_TAGS[type]
      type = 'tease' if tag && !Engine::ContentOptions.enabled?(player, tag)
      # The milking bra can only milk breasts the delver currently has; if a
      # condition has since taken them, it settles for teasing instead.
      if type == 'milk' && !player.body_parts_list.map(&:to_s).include?('breasts')
        type = 'tease'
      end
      # Plugs live in the ass; if a delver somehow has none to plug, the
      # gear settles for teasing instead.
      if %w[anal knot egg].include?(type) && !Engine::ChastitySystem.scene_parts(player).include?('anus')
        type = 'tease'
      end

      scene =
        case type
        when 'tease' then generate_tease_scene(player, item_name)
        when 'binding' then generate_binding_scene(player, item_name)
        when 'positioning' then generate_positioning_scene(player, item_name)
        when 'choking' then generate_choking_scene(player, item_name)
        when 'anal' then generate_anal_scene(player, item_name)
        when 'squeeze' then generate_squeeze_scene(player, item_name)
        when 'denial' then generate_denial_scene(player, item_name)
        when 'heat' then generate_heat_scene(player, item_name)
        when 'whip' then generate_whip_scene(player, item_name)
        when 'tentacle' then generate_tentacle_scene(player, item_name)
        when 'milk' then generate_milk_scene(player, item_name)
        when 'knot' then generate_knot_scene(player, item_name)
        when 'possess' then generate_possess_scene(player, item_name)
        when 'hypno' then generate_hypno_scene(player, item_name)
        when 'tickle' then generate_tickle_scene(player, item_name)
        when 'egg' then generate_egg_scene(player, item_name)
        end
      fallback = "The #{item_name} writhes against your skin, its movements sending shivers through your body."
      Engine::ContentOptions.pick(player, [scene].compact, fallback: [fallback])
    end

    def generate_tease_scene(player, item_name)
      parts = Engine::ChastitySystem.scene_parts(player)
      scenes = Engine::ChastitySystem.lines_for(player, :tease, actor: item_name)

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
        "The #{item_name} coaxes your body into a lewd position, arching your back and pushing your hips up invitingly.",
        "The #{item_name} shifts, moving your limbs until you're kneeling with your knees spread and your chest down.",
        "The #{item_name} takes control of your body, bending you over with your ass in the air for easy access.",
        "The #{item_name} comes alive, tugging you into a deliciously shameless pose — on all fours, head low, hips high.",
        "The #{item_name} manipulates your limbs, arranging you like a doll on your knees with your thighs parted for someone's pleasure."
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
      parts = Engine::ChastitySystem.scene_parts(player)
      scenes = [
        "The #{item_name} contracts all at once, hugging every curve of you like a lover's full-body embrace.",
        "The #{item_name} ripples across your skin in slow waves, as if tasting you.",
        "The #{item_name} tightens and loosens in a steady rhythm, matching — then quickening — your heartbeat."
      ] + Engine::ChastitySystem.lines_for(player, :tease, actor: item_name)
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

    def generate_heat_scene(_player, item_name)
      [
        "The #{item_name} throbs in your grip, and its heat crawls up your arm and pools low in your belly.",
        "The #{item_name} pulses like a heartbeat, flooding you with a fever of desire you can't shake.",
        "Warmth bleeds from the #{item_name} into your palm, every pulse a little hotter and a little lewder.",
        "The #{item_name} hums against your hip, its stolen pleasure leaking back into you in slow, aching waves."
      ].sample
    end

    def generate_whip_scene(_player, item_name)
      [
        "The #{item_name} uncoils on its own and lands a crisp stroke across your rear, leaving you gasping and eager.",
        "The #{item_name} wraps around your thigh and squeezes, whispering that you'd look so much better on your knees.",
        "The #{item_name} cracks beside your ear, and your body flinches into a submissive kneel before you can stop it.",
        "The #{item_name} trails its tip slowly up your spine, then snaps — and the sting melts into heat."
      ].sample
    end

    def generate_tentacle_scene(player, item_name)
      parts = Engine::ChastitySystem.scene_parts(player)
      scenes = [
        "A tendril from the #{item_name} curls around your thigh and squeezes in a slow, deliberate rhythm.",
        "The #{item_name} comes alive, its vines coiling around your waist and tugging you into a helpless swaying."
      ] + Engine::ChastitySystem.lines_for(player, :tentacles, actor: item_name)
      scenes << "The #{item_name} sprouts slick little vines that slip between your folds and rub your clit in slow circles." if parts.include?('vagina')
      scenes << "The #{item_name} sprouts slick little vines that coil around your cock and stroke it in a slow, deliberate rhythm." if parts.include?('penis')
      Engine::ContentOptions.pick(player, scenes)
    end

    def generate_milk_scene(_player, item_name)
      [
        "The #{item_name} kneads your breasts in slow, hungry squeezes, coaxing warmth and wetness to your nipples.",
        "The #{item_name} tightens and releases, over and over, milking you with shameless patience.",
        "Soft cups of the #{item_name} suckle gently at your breasts until you're squirming and leaking."
      ].sample
    end

    def generate_knot_scene(_player, item_name)
      [
        "The #{item_name} swells inside your ass, its knot lodging deep and refusing to slip free until it softens.",
        "The #{item_name} pulses and thickens in your ass, stretching you around its bulge and holding you deliciously full.",
        "Every step makes the #{item_name}'s knot nudge deeper into your ass, and your knees nearly give with each one."
      ].sample
    end

    def generate_possess_scene(_player, item_name)
      [
        "Whispers spill from the #{item_name}, and your hands move on their own — caressing, presenting, obeying.",
        "The #{item_name} goes warm, and your posture melts into something softer and far more willing.",
        "Your body sways without your permission, steered by the thing inside the #{item_name}."
      ].sample
    end

    def generate_hypno_scene(_player, item_name)
      [
        "The spirals of the #{item_name} catch the light, and your thoughts slow to a warm, obedient crawl.",
        "A drowsy calm pours from the #{item_name}. Fighting feels like so much effort. Pleasing feels easy.",
        "Your eyes glaze as the #{item_name} hums — suggestions settle into you like warm honey."
      ].sample
    end

    def generate_tickle_scene(_player, item_name)
      [
        "The feathers of the #{item_name} flutter across your ribs, and helpless giggles shake your whole body.",
        "The #{item_name} tickles under your arms and along your sides until you're squirming and breathless.",
        "Soft plumes from the #{item_name} dance over your most ticklish skin, keeping you writhing."
      ].sample
    end

    def generate_egg_scene(_player, item_name)
      [
        "The #{item_name} swells warm and heavy inside your ass, pulsing slow as something about to hatch.",
        "Heat blooms around the #{item_name} as it thickens in your ass, keeping you full and achingly aware of it.",
        "The #{item_name} throbs in your ass in a deep, patient rhythm, like a heartbeat that isn't yours."
      ].sample
    end
  end
end
