# frozen_string_literal: true

module Engine
  module ContentOptions
    module_function

    PREFERENCES = {
      'oral' => { label: 'Oral', group: :core, default: true, description: 'Mouths, tongues, and throats.' },
      'vaginal' => { label: 'Vaginal', group: :core, default: true, description: 'Pussy play and penetration.' },
      'anal' => { label: 'Anal', group: :core, default: true, description: 'Ass play and penetration.' },
      'breast_play' => { label: 'Breast Play', group: :core, default: true, description: 'Breasts and nipples.' },
      'knotting' => { label: 'Knotting', group: :core, default: true, description: 'Knotted beasts and demons.' },
      'tentacles' => { label: 'Tentacles', group: :core, default: true, description: 'Tentacles, vines, and appendages.' },
      'bondage' => { label: 'Bondage', group: :core, default: true, description: 'Binding, restraints, and being held.' },
      'choking' => { label: 'Breath Play', group: :core, default: true, description: 'Choking and tightening collars.' },
      'exhibitionism' => { label: 'Exhibitionism', group: :core, default: true, description: 'Being watched and put on display.' },
      'aphrodisiacs' => { label: 'Aphrodisiacs', group: :core, default: true, description: 'Mists, drugs, and heat.' },
      'possession' => { label: 'Possession', group: :core, default: true, description: 'Spirits controlling your body.' },
      'toys' => { label: 'Toys', group: :core, default: true, description: 'Dildos, vibrators, and devices.' },
      'lactation' => { label: 'Lactation & Milking', group: :body, default: false, description: 'Milking shrines, nectar, and leaking breasts.' },
      'growth' => { label: 'Part Growth', group: :body, default: false, description: 'Fountains that enlarge body parts (capped).' },
      'inflation' => { label: 'Inflation', group: :body, default: false, description: 'Being pumped full until your belly swells.' },
      'oviposition' => { label: 'Oviposition', group: :body, default: false, description: 'Egg-laying creatures.' },
      'breeding' => { label: 'Breeding', group: :body, default: false, description: 'Impregnation and fertility magic.' },
      'bimbofication' => { label: 'Bimbofication', group: :body, default: false, description: 'Airheaded, curvier, giggly transformations.' },
      'futanari' => { label: 'Futanari', group: :body, default: false, description: 'Magic that grants an extra endowment.' },
      'gender_bending' => { label: 'Gender Bending', group: :body, default: false, description: 'Mirrors that swap your sex.' },
      'giant' => { label: 'Giant Growth', group: :body, default: false, description: 'Growing towering and huge.' },
      'shrinking' => { label: 'Shrinking', group: :body, default: false, description: 'Being made tiny and handled.' },
      'weight_gain' => { label: 'Weight Gain', group: :body, default: false, description: 'Feasts that leave you softer and heavier.' },
      'furry' => { label: 'Furry', group: :body, default: false, description: 'Growing fur, ears, and tails.' },
      'latex' => { label: 'Latex & Rubber', group: :body, default: false, description: 'Glossy rubber encasement.' },
      'living_clothing' => { label: 'Living Clothing', group: :body, default: false, description: 'Outfits that move — and bind to you.' },
      'spanking' => { label: 'Spanking & Discipline', group: :kink, default: false, description: 'Paddles, punishments, and rules.' },
      'denial' => { label: 'Orgasm Denial', group: :kink, default: false, description: 'Edging and being kept on the brink.' },
      'chastity' => { label: 'Chastity', group: :kink, default: false, description: 'Locked-up devices and teasing.' },
      'feet' => { label: 'Feet', group: :kink, default: false, description: 'Foot worship and teasing.' },
      'petplay' => { label: 'Petplay', group: :kink, default: false, description: 'Collars, leashes, and being a good pet.' },
      'mind_control' => { label: 'Hypnosis', group: :kink, default: false, description: 'Hypnotic mists and suggestions.' },
      'mindbreak' => { label: 'Mindbreak', group: :kink, default: false, description: 'Whispers that melt your thoughts.' },
      'sensory_deprivation' => { label: 'Sensory Deprivation', group: :kink, default: false, description: 'Blindfolds, silence, and touch only.' },
      'objectification' => { label: 'Objectification', group: :kink, default: false, description: 'Being used as furniture or decor.' },
      'humiliation' => { label: 'Humiliation', group: :kink, default: false, description: 'Shameful displays and teasing crowds.' },
      'slavery' => { label: 'Slavery (fantasy)', group: :kink, default: false, description: 'Auctions and ownership roleplay.' },
      'voyeurism' => { label: 'Voyeurism', group: :kink, default: false, description: 'Watching others through the walls.' },
      'group_sex' => { label: 'Group Sex', group: :kink, default: false, description: 'Orgies and many partners at once.' },
      'bukkake' => { label: 'Bukkake', group: :kink, default: false, description: 'Many partners finishing on you.' },
      'facials' => { label: 'Facials', group: :kink, default: false, description: 'Finishing on your face.' },
      'pegging' => { label: 'Strap-ons', group: :kink, default: false, description: 'Strap-on play, giving or receiving.' },
      'watersports' => { label: 'Watersports', group: :kink, default: false, description: 'Golden showers (always opt-in).' }
    }.freeze

    CORE_KEYS = PREFERENCES.select { |_, v| v[:group] == :core }.keys.freeze
    BODY_KEYS = PREFERENCES.select { |_, v| v[:group] == :body }.keys.freeze
    KINK_KEYS = PREFERENCES.select { |_, v| v[:group] == :kink }.keys.freeze
    EXTRA_KEYS = (BODY_KEYS + KINK_KEYS).freeze

    KEYWORDS = {
      'oral' => /\b(mouth|throat|suck\w*|lick\w*|laps?|lapping|tongue\w*|swallow\w*|blowjob|lips around)\b/i,
      'vaginal' => /\b(pussy|cunt|vagina\w*|womb|clit\w*|folds)\b/i,
      'anal' => /\b(ass|asses|anus|anal|asshole|backdoor)\b/i,
      'breast_play' => /\b(breasts?|nipples?|tits|bust)\b/i,
      'knotting' => /\bknot\w*/i,
      'tentacles' => /\btentacle\w*/i,
      'bondage' => /\b(bind\w*|bound|restrain\w*|tied|shackle\w*|pinned|pins you)\b/i,
      'choking' => /\b(chok\w*|strangl\w*|air supply|cutting off your air|oxygen|around your (neck|throat)|squeez\w* your (neck|throat))\b/i,
      'exhibitionism' => /\b(public\w*|audience|onlookers|crowd|passersby|pass by|watching you|humiliat\w*)\b/i,
      'aphrodisiacs' => /\b(aphrodisiac\w*|drugg\w*)\b/i,
      'possession' => /\b(possess\w*|takes control|controls your)\b/i,
      'toys' => /\b(dildo\w*|vibrat\w*|toys?)\b/i
    }.freeze

    NEUTRAL_SCENES = [
      'The moment blurs into a haze of heat and sensation.',
      'Warmth floods through you as the encounter plays out.',
      'You lose yourself for a while in pleasant, dizzy heat.',
      'Everything narrows to touch, breath, and a rising glow.'
    ].freeze

    BODY_SIZES = {
      'penis' => { label: 'Penis', requires: 'penis', options: %w[small average large], default: 'average' },
      'breasts' => { label: 'Breasts', requires: 'breasts', options: %w[small medium large], default: 'medium' },
      'butt' => { label: 'Butt', requires: nil, options: %w[small medium large huge], default: 'medium' }
    }.freeze

    def preference(key)
      PREFERENCES[key.to_s]
    end

    def resolve_key(input)
      norm = input.to_s.downcase.strip.gsub(/[\s-]+/, '_')
      return norm if PREFERENCES.key?(norm)

      PREFERENCES.find { |_, v| v[:label].downcase.gsub(/[^a-z]+/, '_').delete_suffix('_') == norm }&.first
    end

    def set!(player, key, value)
      saved = player.preferences.is_a?(Hash) ? player.preferences.dup : {}
      saved[key.to_s] = value ? true : false
      player.update(preferences: saved)
    end

    def preferences_for(player)
      saved = player.respond_to?(:preferences) && player.preferences.is_a?(Hash) ? player.preferences : {}
      PREFERENCES.to_h { |k, v| [k, saved.key?(k) ? saved[k] == true : v[:default]] }
    end

    def enabled?(player, key)
      return PREFERENCES.dig(key.to_s, :default) != false if player.nil?

      preferences_for(player).fetch(key.to_s, true)
    end

    def disabled_core(player)
      prefs = preferences_for(player)
      CORE_KEYS.reject { |k| prefs[k] }
    end

    def allowed_text?(player, text)
      disabled_core(player).none? { |k| KEYWORDS[k]&.match?(text.to_s) }
    end

    def pick(player, scenes, fallback: [])
      pool = Array(scenes).select { |s| allowed_text?(player, s) }
      pool = Array(fallback).select { |s| allowed_text?(player, s) } if pool.empty?
      pool.empty? ? NEUTRAL_SCENES.sample : pool.sample
    end

    def scrub!(player, log)
      return log if player.nil?

      Array(log).map! do |entry|
        scene = entry.is_a?(Hash) ? (entry[:scene] || entry['scene']) : nil
        next entry unless scene
        next entry if allowed_text?(player, scene)

        { scene: NEUTRAL_SCENES.sample }
      end
    end

    def applicable_sizes(player)
      parts = player.body_parts_list.map(&:to_s)
      BODY_SIZES.select { |_, v| v[:requires].nil? || parts.include?(v[:requires]) }
    end

    def size_of(player, part)
      spec = BODY_SIZES[part.to_s] or return nil
      saved = player.body_sizes.is_a?(Hash) ? player.body_sizes[part.to_s] : nil
      spec[:options].include?(saved) ? saved : spec[:default]
    end

    def step_size(player, part, delta)
      spec = BODY_SIZES[part.to_s] or return [nil, nil]
      old = size_of(player, part)
      index = (spec[:options].index(old) + delta).clamp(0, spec[:options].size - 1)
      [old, spec[:options][index]]
    end

    def max_size?(player, part)
      spec = BODY_SIZES[part.to_s] or return true
      size_of(player, part) == spec[:options].last
    end
  end
end
