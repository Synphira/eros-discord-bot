# frozen_string_literal: true

module Engine
  module ChastitySystem
    GENITALS = %w[penis vagina].freeze

    STATES = {
      'locked' => {
        name: 'Chastity Belt',
        description: 'Your **Chastity Belt** is locked tight — steel and rune-light seal your genitals away. ' \
                     'The constant pressure is a reminder that your release belongs to someone else.',
        reminder: 'The belt\'s steel presses snugly against you, a heavy reminder that nothing here can reach what it guards.',
        arousal_multiplier: 1.5,
        denial: ['Your body surges toward the edge — and slams into the belt. The steel holds firm, and the orgasm that should have broken over you ' \
                 'crashes back inward as waves of frustrated, denied pleasure.',
                 'You squirm and grind uselessly against the metal, aching and leaking, your need wound tighter than ever.']
      },
      'magical' => {
        name: 'Locked Tight',
        description: 'Glowing runes are **locked tight** across your groin, an invisible barrier no touch can pass. ' \
                     'The energy pulses in time with your arousal.',
        reminder: 'The runes across your groin hum softly, warding off any touch before it can land.',
        arousal_multiplier: 1.4,
        denial: ['The runes flare white-hot as you reach the brink. The barrier drinks in your climax before it can happen ' \
                 'and pours it straight back into you as raw, frustrated arousal.',
                 'You are left shaking at the edge, the magic humming smugly, your release denied.']
      }
    }.freeze

    LINES = {
      monster: {
        'penis' => ['The %<actor>s paws at your cage, and your cock throbs against its prison, straining for a touch that never comes.',
                    'The %<actor>s licks along the steel of your belt, tasting the metal while your caged cock twitches helplessly inside.',
                    'The %<actor>s grinds against your locked cage, every press reminding you that you are not allowed to feel it.'],
        'vagina' => ['The %<actor>s strokes the smooth shield over your folds; the touch never reaches you, and your pussy clenches around nothing.',
                     'The %<actor>s presses against your belt, frustrated, while your sealed pussy aches and drips behind the steel.',
                     'The %<actor>s traces the edges of your chastity shield, teasing the only parts of you it is allowed to touch.']
      },
      willing: {
        'penis' => ['You present your caged cock to the %<actor>s, letting it lick and nuzzle the steel — the denial itself becoming the pleasure.',
                    'You offer yourself to the %<actor>s, your cock throbbing against its cage as it uses every part of you the belt leaves free.'],
        'vagina' => ['You spread your legs for the %<actor>s, but the shield over your pussy turns it away — so you offer it everything else instead.',
                     'You guide the %<actor>s to your locked belt, moaning as it teases the steel your pussy aches behind.']
      },
      tease: {
        'penis' => ['The %<actor>s creeps under your belt and tightens around your cage, squeezing your trapped cock until you whimper.'],
        'vagina' => ['The %<actor>s slides along the edges of your chastity shield, teasing everywhere except where you need it most.']
      },
      tentacles: {
        'penis' => ['A tentacle coils around your cage, squeezing and probing the steel, searching for a way in that it will never find.'],
        'vagina' => ['A thick tentacle presses against the shield over your entrance, pushing and testing, frustrated by the locked steel.']
      },
      vines: {
        'penis' => ['A vine wraps around your cage and tugs at it insistently, its nectar dripping uselessly over the steel.'],
        'vagina' => ['A nectar-coated vine strokes the shield over your clit, sending muffled jolts through the metal.']
      },
      spirit: {
        'penis' => ['Your hands drift to your cage and claw at the lock, the spirit sighing in frustration when the steel will not give.'],
        'vagina' => ['Your hands drift to your belt and stroke the smooth shield, the spirit whimpering through your lips at what it cannot reach.']
      },
      dildo: {
        'penis' => ['It grinds against your cage, sending dull vibrations through the steel straight into your trapped cock.'],
        'vagina' => ['It pushes against the shield over your pussy and buzzes there, the muffled vibrations driving you mad.']
      },
      mirror: {
        'penis' => ['You watch yourself kept locked and caged while monsters laugh and pet your belt, your release forever out of reach.'],
        'vagina' => ['You watch yourself shown off in your belt, monsters tapping the locked shield and mocking how wet you must be behind it.']
      },
      glory: {
        'penis' => ['As you serve them, your cock swells against its cage, throbbing with a need you are not allowed to answer.'],
        'vagina' => ['As you serve them, your pussy grows slick behind its shield, aching for a touch the belt will never allow.']
      },
      mist: {
        'any' => ['The aphrodisiac mist makes your skin flush with heat, and everything sealed beneath your chastity throbs with need it cannot spend.']
      },
      milking: {
        'penis' => ['A slim probe slips past your cage and milks you from the inside, coaxing out leaking drops without ever letting you finish.']
      },
      edging: {
        'penis' => ['Your caged cock strains against the steel, denied twice over.'],
        'vagina' => ['Behind your shield your pussy clenches desperately, denied twice over.']
      },
      futa: {
        'any' => ['The new flesh swells straight into your chastity — locked away the very moment it forms.']
      }
    }.freeze

    DENIAL_LP = 3

    module_function

    def in_chastity?(player)
      player.climax_denied?
    end

    def chastity_type(player)
      return nil unless in_chastity?(player)

      player.equipment_effect_flag?('deny_climax') ? 'locked' : 'magical'
    end

    def state(player)
      STATES[chastity_type(player)]
    end

    def description(player)
      state(player)&.dig(:description)
    end

    def reminder(player)
      state(player)&.dig(:reminder)
    end

    def arousal_multiplier(player)
      state(player)&.dig(:arousal_multiplier) || 1.0
    end

    def scene_parts(player)
      parts = player.body_parts_list.map(&:to_s)
      in_chastity?(player) ? parts - GENITALS : parts
    end

    def caged_parts(player)
      return [] unless in_chastity?(player)

      player.body_parts_list.map(&:to_s) & GENITALS
    end

    def lines_for(player, context, actor: nil)
      return [] unless in_chastity?(player)

      table = LINES.fetch(context)
      pool = table['any'] ? Array(table['any']) : caged_parts(player).flat_map { |part| Array(table[part]) }
      pool.map { |line| actor ? format(line, actor: actor) : line }
    end

    def line(player, context, actor: nil)
      lines_for(player, context, actor: actor).sample
    end

    def scenes(player, context, actor: nil)
      text = line(player, context, actor: actor)
      text ? [{ scene: text }] : []
    end

    def denial_lines(player)
      Array(state(player)&.dig(:denial)).map { |t| "_#{t}_" }
    end
  end
end
