# frozen_string_literal: true

module Engine
  module ExtraEvents
    KEYS = %w[milking_shrine swelling_fountain bloating_slime egg_chamber paddle_golem foot_idol].freeze

    TRACKERS = {
      'milking_shrine' => %w[being_milked_events lactation_events],
      'swelling_fountain' => %w[body_growth_events],
      'bloating_slime' => %w[inflation_events],
      'egg_chamber' => %w[oviposition_events],
      'paddle_golem' => %w[discipline_events],
      'foot_idol' => %w[foot_fetish_events],
      'edging_altar' => %w[chastity_events]
    }.freeze

    META = {
      'milking_shrine' => {
        name: 'Milking Shrine',
        blurb: 'a marble shrine hums softly.',
        description: 'Twin crystal cups rise from a softly glowing shrine, sealing gently over your chest with a warm, rhythmic pull...'
      },
      'swelling_fountain' => {
        name: 'Swelling Fountain',
        blurb: 'a fountain bubbles with pink water.',
        description: 'The sweet pink water splashes over you before you can step away. Your skin tingles, and parts of you begin to feel heavier...'
      },
      'bloating_slime' => {
        name: 'Bloating Slime',
        blurb: 'a warm puddle stirs.',
        description: 'A warm, friendly slime flows up your legs and settles inside you, pumping more and more of itself in with a happy gurgle...'
      },
      'egg_chamber' => {
        name: 'Egg Chamber',
        blurb: 'the walls are lined with glistening eggs.',
        description: 'A soft, many-legged creature drops from the ceiling and nuzzles against you, its ovipositor already slick and searching...'
      },
      'paddle_golem' => {
        name: 'Paddle Golem',
        blurb: 'a stone figure turns its head.',
        description: 'A polished stone golem bends you over its knee with surprising gentleness and raises a smooth wooden paddle...'
      },
      'edging_altar' => {
        name: 'Edging Altar',
        blurb: 'an altar glows with patient light.',
        description: 'Glowing runes coil around your wrists as you touch the altar. A voice purrs that you may feel everything — except release...'
      },
      'foot_idol' => {
        name: 'Foot Idol',
        blurb: 'a statue of a barefoot goddess.',
        description: "The goddess statue's eyes glow, and ghostly hands slip off your boots to lavish your feet with attention..."
      }
    }.freeze

    SIZE_WORDS = {
      'penis' => { 'small' => 'petite', 'average' => 'eager', 'large' => 'heavy, thick' },
      'breasts' => { 'small' => 'pert', 'medium' => 'full', 'large' => 'heavy' },
      'butt' => { 'small' => 'tight', 'medium' => 'round', 'large' => 'plump', 'huge' => 'enormous' }
    }.freeze

    DENIAL_CAP = Player::CLIMAX_THRESHOLD - 5

    module_function

    def meta(type)
      META[type.to_s]
    end

    def size_word(player, part)
      SIZE_WORDS.dig(part, Engine::ContentOptions.size_of(player, part)) || ''
    end

    def reward!(player, lp, lust, log)
      player.gain_lp!(lp) if lp.positive?
      player.gain_lust!(lust)
      bits = []
      bits << "**+#{lp} LP**" if lp.positive?
      bits << "lust **+#{lust}** (now #{player.lust})"
      log << bits.join(' · ')
    end

    def apply!(player, type, level, log)
      parts = Engine::ChastitySystem.scene_parts(player)
      bump_trackers!(player, type)
      case type
      when 'milking_shrine' then milking!(player, parts, level, log)
      when 'swelling_fountain' then swelling!(player, level, log)
      when 'bloating_slime' then bloating!(player, level, log)
      when 'egg_chamber' then eggs!(player, parts, level, log)
      when 'paddle_golem' then paddle!(player, level, log)
      when 'foot_idol' then feet!(player, level, log)
      end
    end

    def bump_trackers!(player, type)
      Array(TRACKERS[type.to_s]).each { |t| player.bump_tracker!(t) }
    end

    def milking!(player, parts, level, log)
      size = Engine::ContentOptions.size_of(player, 'breasts')
      log << { scene: "The cups tug in a slow, soothing rhythm until your #{size_word(player, 'breasts')} breasts begin to leak warm milk, " \
                      'drawn away into the shrine with every pulse.' }
      bonus = { 'small' => 0, 'medium' => 2, 'large' => 4 }.fetch(size, 0)
      if parts.include?('penis')
        log << { scene: 'The shrine hums approvingly, and a gentle glow wraps around your cock as well, milking you in time with the cups.' }
        bonus += 2
      elsif (caged = Engine::ChastitySystem.line(player, :milking))
        log << { scene: caged }
        bonus += 2
      end
      log << { scene: 'When the cups finally release you, you feel lighter, flushed, and strangely proud.' }
      reward!(player, 3 + (level / 3) + (bonus / 2), 10 + (level / 2) + bonus, log)
    end

    def swelling!(player, level, log)
      growable = Engine::ContentOptions.applicable_sizes(player).keys.reject { |p| Engine::ContentOptions.max_size?(player, p) }
      if growable.empty?
        log << { scene: 'The water fizzes against your skin, but you are already as generously shaped as the tower allows. It settles for making you tingle all over.' }
        reward!(player, 2, 6 + (level / 2), log)
        return
      end

      part = growable.sample
      old, new = Engine::ContentOptions.step_size(player, part, 1)
      sizes = player.body_sizes.is_a?(Hash) ? player.body_sizes.dup : {}
      player.update(body_sizes: sizes.merge(part => new))
      label = Engine::ContentOptions::BODY_SIZES[part][:label].downcase
      log << { scene: "Warmth pools in your #{label} as they swell, settling heavier and more sensitive than before." }
      log << "_Your #{label} grew: **#{old} → #{new}** (change it any time in `/options`)._"
      reward!(player, 3, 8 + (level / 2), log)
    end

    def bloating!(player, level, log)
      log << { scene: 'Your belly rounds out as the slime keeps filling you, taut and sloshing, until you are gloriously stuffed.' }
      log << { scene: 'Content at last, the slime slides back out in a slow, shivering rush, leaving you trembling and empty.' }
      reward!(player, 4 + (level / 3), 12 + (level / 2), log)
    end

    def eggs!(player, parts, level, log)
      hole = parts.include?('vagina') ? 'womb' : 'belly'
      log << { scene: "The ovipositor slides inside you, and one by one smooth, warm eggs settle deep in your #{hole}, each a heavy little pulse of pleasure." }
      log << { scene: 'The creature chirps happily and scurries off. A short while later the eggs dissolve into a tingling warmth.' }
      reward!(player, 5 + (level / 3), 14 + (level / 2), log)
    end

    def paddle!(player, level, log)
      size = Engine::ContentOptions.size_of(player, 'butt')
      log << { scene: "The paddle lands on your #{size_word(player, 'butt')} rear with a crisp smack, then another, " \
                      'each one leaving a glowing sting that melts into heat.' }
      extra = { 'small' => 0, 'medium' => 1, 'large' => 2, 'huge' => 3 }.fetch(size, 0)
      log << { scene: 'After a final ringing swat the golem pats you twice and sets you back on your feet, cheeks burning.' }
      player.adjust_defiance!(-3)
      log << "The sting costs you **3** defiance. (now #{player.defiance}/#{player.max_defiance})"
      reward!(player, 3 + (level / 3) + extra, 8 + (level / 2) + (extra * 2), log)
    end

    def feet!(player, level, log)
      log << { scene: 'Ghostly fingers knead your soles and warm lips kiss each toe, working tension out of every step you have taken in the tower.' }
      log << { scene: 'By the time your boots slide back on, your legs are jelly and your whole body hums.' }
      reward!(player, 3 + (level / 3), 8 + (level / 2), log)
    end

    def edging_turn!(player, parts, turn, log)
      scene =
        case turn
        when 1 then 'Invisible hands trace slow circles over your most sensitive places, building heat with maddening patience.'
        when 2 then 'The runes pulse, dragging you right to the brink — and holding you there, trembling.'
        else 'The voice laughs softly as it pulls you back from the edge one final time, then releases the runes.'
        end
      log << { scene: scene }
      if turn == 2
        caged = Engine::ChastitySystem.line(player, :edging)
        log << { scene: caged || 'Your cock twitches helplessly, denied.' } if caged || parts.include?('penis')
      end
      gained = [10 + (turn * 5), DENIAL_CAP - player.lust].min
      player.gain_lust!(gained) if gained.positive?
      lp = 2 + turn
      player.gain_lp!(lp)
      log << "Denied, you earn **+#{lp} LP**. Lust held at `#{player.lust}` — just short of release."
    end
  end
end
