# frozen_string_literal: true

module Engine
  # Hidden outfit sets. Pieces scattered across Berry's shelves, Vex's
  # rack, and the tower's chests belong to named sets; wear every piece
  # of one at once and the set wakes up with a passive of its own. The
  # sets are not written on any label — a delver finds them by dressing
  # the part completely, and the equipment menu names the bonus only
  # once it is active.
  module Wardrobe
    SETS = {
      'naughty_nurse' => {
        name: 'Naughty Nurse', bonus_name: 'Bedside Manner',
        pieces: ["Nurse's Cap", 'Naughty Nurse Uniform', "Nurse's Stockings"],
        effects: { 'defiance_regen' => 3, 'submit_lp_bonus' => 1 },
        blurb: 'The full uniform practices medicine the tower way: something in you knits back ' \
               'together every few moments, bedside and otherwise.'
      },
      'tower_maid' => {
        name: 'Tower Maid', bonus_name: 'In Service',
        pieces: ["Maid's Lace Cap", 'Satin Maid Dress', 'Service Heels'],
        effects: { 'victory_lp_bonus' => 2, 'explore_lp' => 1 },
        blurb: 'Fully in uniform, the tower treats you as staff: doors tip, victories tip better.'
      },
      'fallen_nun' => {
        name: 'Fallen Nun', bonus_name: 'Broken Vows',
        pieces: ["Fallen Nun's Veil", 'Penitent Habit', 'Confession Garter'],
        effects: { 'satisfy_bonus' => 0.06, 'submit_lp_bonus' => 2 },
        blurb: 'Veil, habit, and garter, worn all wrong together. The tower has been waiting to ' \
               'break a nun properly, and it pays in devotion.'
      },
      'velvet_bunny' => {
        name: 'Velvet Bunny', bonus_name: 'Warren Ways',
        pieces: ['Velvet Bunny Ears', 'Velvet Bunny Suit', 'Fishnet Tights'],
        effects: { 'agility' => 1, 'dodge_bonus' => 0.03 },
        blurb: 'Ears up, tail on, nowhere to run — and somehow harder to catch for it.'
      },
      'knight_of_the_tower' => {
        name: 'Knight of the Tower', bonus_name: 'Oathbound Plate',
        pieces: ["Knight's Helm", "Knight's Cuirass", "Knight's Greaves", "Knight's Sabatons"],
        effects: { 'max_hp' => 15, 'resistance' => 1 },
        blurb: 'A full harness of tower plate, vow and all: you simply endure more.'
      },
      'holy_orders' => {
        name: 'Holy Orders', bonus_name: 'Unbroken Vows',
        pieces: ["Exorcist's Censer", 'Sacred Rosary', 'Chaste Plate'],
        effects: { 'lust_mult' => 0.92, 'satisfy_bonus' => 0.03 },
        blurb: 'Censer, rosary, and chaste steel worn together: devotion, armoured — for whatever ' \
               'good the tower lets it do you.'
      },
      'hand_of_the_maker' => {
        name: "The Maker's Own", bonus_name: 'Hand of the Maker',
        pieces: ["Syn's Smudged Tiara", "Syn's Lace Scraps", "Syn's Garter of Vials",
                 "Syn's Smoked-Glass Wings", "Syn's Belled Heels", "Syn's Tower-Script Thong"],
        effects: { 'satisfy_bonus' => 0.08, 'victory_lp_bonus' => 3, 'submit_lp_bonus' => 3 },
        blurb: 'Tiara, lace, garter, and wings, worn as their maker wears them: the tower ' \
               'recognises its first seamstress, and everything in it behaves accordingly.'
      },
      'all_hallows_masque' => {
        name: "All Hallows' Masque", bonus_name: 'Night of Masks',
        pieces: ['Masquerade Domino', 'Pumpkin-Cut Bodice', 'Cobweb Stockings'],
        effects: { 'appearance' => 6, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.04 },
        blurb: 'Mask, bodice, and webs worn together: the temple reads you as dressed for All Hallows — ' \
               'and keeps paying that compliment long after the candles go out.'
      },
      'field_sample' => {
        name: 'Field Sample', bonus_name: 'Catalogue Bait',
        pieces: ['Askew Field Goggles', "Trapwright's Open Harness", 'Seatless Tool Chaps',
                 'Catalogue Crotch Window'],
        effects: { 'appearance' => 5, 'lust_mult' => 1.05, 'submit_lp_bonus' => 2, 'trap_avoid_bonus' => -0.05 },
        blurb: 'Goggles, open harness, seatless chaps, and a crotch window worn together: breasts, ass, and ' \
               'sex bare on purpose. The tower\'s traps read you as a willing sample — and lean in harder.'
      },
      'feast_of_the_willing' => {
        name: 'Feast of the Willing', bonus_name: 'Second Helping',
        pieces: ['Cornucopia Circlet', 'Basting-String Bodice', 'Gravy-Silk Stockings'],
        effects: { 'appearance' => 6, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.04, 'plant_submit_lp' => 1 },
        blurb: 'Circlet, basting bodice, and gravy silk worn together: the temple reads you as a guest who ' \
               'came to be carved — and keeps plating compliments long after the feast ends.'
      },
      'yule_of_surrender' => {
        name: 'Yule of Surrender', bonus_name: 'Gift-Wrapped',
        pieces: ['Antler Circlet', 'Ribbon-Wrapped Bodice', 'Mistletoe Stockings'],
        effects: { 'appearance' => 6, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.04, 'demon_submit_lp' => 1 },
        blurb: 'Antlers, ribbon, and mistletoe silk worn together: the temple reads you as a gift mid-unwrap — ' \
               'and keeps tying compliments long after the tree comes down.'
      },
      'midnight_oath' => {
        name: 'Midnight Oath', bonus_name: 'First Toast',
        pieces: ['Countdown Tiara', 'Midnight Lace Bodice', 'Champagne Sheer Hose'],
        effects: { 'appearance' => 6, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.04, 'explore_lp' => 1 },
        blurb: 'Tiara, midnight lace, and champagne hose worn together: the temple reads you as a vow already ' \
               'breaking — and keeps toasting that honesty after the clock strikes.'
      },
      'heartstring_heat' => {
        name: 'Heartstring Claim', bonus_name: 'Be Mine',
        pieces: ['Rose Circlet', 'Heart-Cut Bodice', 'Arrow-Silk Stockings'],
        effects: { 'appearance' => 6, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.05, 'demon_submit_lp' => 1 },
        blurb: 'Rose circlet, heart-cut bodice, and arrow silk worn together: the temple reads you as a valentine ' \
               'mid-claim — and keeps aiming compliments long after the arrows stop.'
      },
      'carnival_heat' => {
        name: 'Carnival of Beads', bonus_name: 'Throw Me Beads',
        pieces: ['Feathered Domino', 'Bead-Draped Bodice', 'Parade Sheer Hose'],
        effects: { 'appearance' => 6, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.04, 'clown_submit_lp' => 1 },
        blurb: 'Feathered mask, bead-draped bodice, and parade hose worn together: the temple reads you as a float ' \
               'worth throwing for — and keeps cheering that honesty after Fat Tuesday.'
      },
      'hares_heat' => {
        name: "Hare's Hunt", bonus_name: 'Nest Ready',
        pieces: ['Bunny-Ear Circlet', 'Pastel Nest Bodice', 'Spring-Silk Stockings'],
        effects: { 'appearance' => 6, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.04, 'beast_submit_lp' => 1 },
        blurb: 'Bunny ears, nest bodice, and spring silk worn together: the temple reads you as a prize mid-hunt — ' \
               'and keeps nesting compliments long after Monday.'
      },
      'fools_heat' => {
        name: "Fool's Trap", bonus_name: 'Gotcha',
        pieces: ['Askew Jester Cap', 'Whoopee Harness', 'Striped Fool Hose'],
        effects: { 'appearance' => 5, 'submit_lp_bonus' => 2, 'explore_lp' => 1, 'trap_avoid_bonus' => -0.05 },
        blurb: 'Jester cap, whoopee harness, and striped hose worn together: the temple reads you as a willing ' \
               'punchline — and keeps setting you up long after April 1.'
      },
      'maypole_heat' => {
        name: 'Maypole Raising', bonus_name: 'Wound Pretty',
        pieces: ['Flower Crown', 'Maypole Ribbon Bodice', 'Petal-Silk Stockings'],
        effects: { 'appearance' => 6, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.04, 'plant_submit_lp' => 1 },
        blurb: 'Flower crown, ribbon bodice, and petal silk worn together: the temple reads you as a dancer mid-wind — ' \
               'and keeps tying compliments long after the pole comes down.'
      },
      'longest_day' => {
        name: 'Longest Day', bonus_name: 'Golden Hour',
        pieces: ['Sun Halo', 'Honey-Gold Bodice', 'Glow-Silk Stockings'],
        effects: { 'appearance' => 6, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.04, 'plant_submit_lp' => 1 },
        blurb: 'Sun halo, honey-gold bodice, and glow silk worn together: the temple reads you as midsummer mid-ring — ' \
               'and keeps gilding compliments long after the solstice fades.'
      },
      'pride_parade' => {
        name: 'Pride Parade', bonus_name: 'Out & Proud',
        pieces: ['Rainbow Bandana', 'Flag-Draped Bodice', 'Glitter Parade Hose'],
        effects: { 'appearance' => 6, 'submit_lp_bonus' => 2, 'satisfy_bonus' => 0.04, 'explore_lp' => 1 },
        blurb: 'Rainbow bandana, flag bodice, and glitter hose worn together: the temple reads you as a float worth ' \
               'cheering — and keeps celebrating that honesty after the parade rolls out.'
      }
    }.freeze

    # The developer's own signature gear: Syn's look, made wearable —
    # scraps of black lace, a garter hung with needle-case and ink
    # vials, smoked-glass wings, the infamous tiara, and the cursed
    # ink needle itself. Never stocked, never dropped, never synced
    # into any shop: it exists in the equipment table only so its one
    # rightful wearer can be given it by dev command. Every piece is
    # flagged dev_only, and Player#equip_item refuses it to anyone
    # but the developer.
    DEV_GEAR = [
      { name: "Syn's Cursed Ink Needle", type: 'weapon', slot: 'weapon', rarity: 5,
        description: 'The first needle. Its ink is cursed the slow way: whatever it writes on ' \
                     'skin, flesh remembers — monsters come away marked and strangely willing.',
        stat_modifiers: { 'damage' => 6, 'strength' => 3, 'crit_chance' => 0.15, 'appearance' => 10,
                          'satisfy_bonus' => 0.05, 'dev_only' => true } },
      { name: "Syn's Smudged Tiara", type: 'armor', slot: 'head', rarity: 5,
        description: 'The tiara that survived whatever happened to the tiara. Covar tells that ' \
                     'story in whispers and will not be hurried.',
        stat_modifiers: { 'appearance' => 9, 'satisfy_bonus' => 0.03, 'dev_only' => true } },
      { name: "Syn's Lace Scraps", type: 'armor', slot: 'chest', rarity: 5,
        description: 'Barely-there black lace over ink-covered skin. Her body is the catalogue; ' \
                     'this is just the frame.',
        stat_modifiers: { 'appearance' => 12, 'lust_mult' => 1.10, 'satisfy_bonus' => 0.03, 'dev_only' => true } },
      { name: "Syn's Garter of Vials", type: 'armor', slot: 'legs', rarity: 5,
        description: 'A garter belt hung with a needle-case and little ink vials, worn over ' \
                     'tally-marked thighs. Tools of the trade, kept close.',
        stat_modifiers: { 'appearance' => 10, 'victory_lp_bonus' => 2, 'dev_only' => true } },
      { name: "Syn's Smoked-Glass Wings", type: 'accessory', slot: 'accessory', rarity: 5,
        description: 'Drooping wings of smoked glass that catch candlelight like held breath. ' \
                     'Heavy-lidded, like their owner.',
        stat_modifiers: { 'appearance' => 9, 'agility' => 2, 'dodge_bonus' => 0.05, 'dev_only' => true } },
      { name: "Syn's Belled Heels", type: 'armor', slot: 'feet', rarity: 5,
        description: 'Impossibly tall heels with a small bell at each ankle strap, matching the ' \
                     'one in her ear. Every step announces her; the parlour hears its slut coming ' \
                     'and starts smiling early.',
        stat_modifiers: { 'appearance' => 9, 'agility' => 1, 'submit_lp_bonus' => 1, 'dev_only' => true } },
      { name: "Syn's Tower-Script Thong", type: 'armor', slot: 'groin', rarity: 5,
        description: 'A scrap of black lace scripted where only the tower and its favourites will ' \
                     'ever read it: property, claimed and catalogued. She wears her own label.',
        stat_modifiers: { 'appearance' => 11, 'lust_mult' => 1.05, 'submit_lp_bonus' => 1, 'dev_only' => true } }
    ].freeze

    def sync_dev_gear!
      DEV_GEAR.each do |spec|
        record = ::Equipment.find_or_create(name: spec[:name]) do |e|
          e.type = spec[:type]
          e.slot = spec[:slot]
        end
        record.type = spec[:type]
        record.slot = spec[:slot]
        record.description = spec[:description]
        record.stat_modifiers = spec[:stat_modifiers]
        record.cost = 0
        record.rarity = spec[:rarity]
        record.cursed = false
        record.violation_type = nil
        record.removal_cost = 0
        record.save_changes
      end
    end
    module_function :sync_dev_gear!

    module_function

    def set(key)
      SETS[key.to_s]
    end

    # Sets whose every piece is on the delver's body right now,
    # as [key, spec] pairs.
    def active_sets(player)
      worn = player.equipped_items.map { |item| item.name.to_s }
      SETS.select { |_key, spec| (spec[:pieces] - worn).empty? }
    end

    def active?(player)
      active_sets(player).any?
    end

    # Merged bonus effects of every active set. Numeric values sum;
    # multiplier keys (anything ending in _mult) multiply.
    def effects(player)
      merged = {}
      active_sets(player).each_value do |spec|
        spec[:effects].each do |key, value|
          key = key.to_s
          merged[key] =
            if value.is_a?(Numeric) && key.end_with?('_mult') && merged[key]
              merged[key] * value
            elsif value.is_a?(Numeric) && merged[key].is_a?(Numeric)
              merged[key] + value
            else
              value
            end
        end
      end
      merged
    end

    def effect_sum(player, key)
      effects(player)[key.to_s].to_f
    end

    def describe_set(key, spec)
      rendered = Engine::FetishEvents.describe_effects(spec[:effects])
      "**#{spec[:bonus_name]}** _(#{spec[:name]} #{spec[:pieces].size}/#{spec[:pieces].size})_ — #{rendered}\n_#{spec[:blurb]}_"
    end
  end
end
