# frozen_string_literal: true

module Engine
  # The tower changes character every five floors. When a delver enters a
  # new five-floor section, its biome is rolled — weighted, and tipped
  # heavily toward whatever boss waits at the end of that section, so the
  # land itself feels like it belongs to the thing guarding it. The biome
  # tilts monster types and event themes for the whole section.
  module Biomes
    BLOCK_SIZE = 5
    BOSS_AFFINITY = 8.0

    # Boss type waiting at the end of each section, by the section's last
    # floor within a cycle (mirrors Engine::BossFights::BOSSES).
    SECTION_BOSS_TYPES = {
      5 => 'mimic', 10 => 'demon', 15 => 'demon', 20 => 'plant',
      25 => 'undead', 30 => 'beast', 35 => 'demon'
    }.freeze

    BIOMES = [
      {
        key: 'milking_barns', name: 'The Milking Barns', weight: 1.0,
        flavour: 'warm hay, sweet milk on the air, and bells tinkling somewhere in the dark',
        monsters: { 'beast' => 1.6 }, tags: { 'lactation' => 1.8, 'weight_gain' => 1.5, 'breeding' => 1.4 }
      },
      {
        key: 'mirror_gallery', name: 'The Mirror Gallery', weight: 1.0,
        flavour: 'endless mirrors watch you from every wall, and none of them agree on what you are doing',
        monsters: { 'demon' => 1.4 }, tags: { 'exhibitionism' => 1.7, 'mind_control' => 1.5, 'voyeurism' => 1.5 }
      },
      {
        key: 'living_depths', name: 'The Living Depths', weight: 1.0,
        flavour: 'the walls breathe slowly, slick and warm, and something below is digesting the last delver',
        monsters: { 'plant' => 1.5, 'slime' => 1.4 }, tags: { 'tentacles' => 1.8, 'inflation' => 1.4, 'living_clothing' => 1.3 }
      },
      {
        key: 'velvet_kennels', name: 'The Velvet Kennels', weight: 1.0,
        flavour: 'soft collars hang in rows, bowls shine, and something eager paces behind every gate',
        monsters: { 'beast' => 1.5 }, tags: { 'petplay' => 1.8, 'pony_play' => 1.6, 'furry' => 1.4 }
      },
      {
        key: 'bell_choir', name: 'The Bell Choir', weight: 1.0,
        flavour: 'a choir of muffled bells tolls through cold stone, and the silence between notes has hands',
        monsters: { 'undead' => 1.6 }, tags: { 'gags_hoods' => 1.6, 'choking' => 1.4, 'sensory_deprivation' => 1.4 }
      },
      {
        key: 'glass_menagerie', name: 'The Glass Menagerie', weight: 1.0,
        flavour: 'glass animals line the shelves, heads turning a fraction too late to follow you',
        monsters: { 'mimic' => 1.7 }, tags: { 'toys' => 1.6, 'living_clothing' => 1.5, 'objectification' => 1.4 }
      },
      {
        key: 'drowned_chapel', name: 'The Drowned Chapel', weight: 0.8,
        flavour: 'a flooded chapel where the pews drift, the hymns bubble, and everything is slick',
        monsters: { 'slime' => 1.5, 'undead' => 1.3 }, tags: { 'inflation' => 1.6, 'cum_play' => 1.5, 'oviposition' => 1.3 }
      },
      {
        key: 'honeyed_hive', name: 'The Honeyed Hive', weight: 0.8,
        flavour: 'amber light, dripping comb, and a low, contented buzzing that gets into your teeth',
        monsters: { 'beast' => 1.4 }, tags: { 'group_sex' => 1.6, 'weight_gain' => 1.4, 'lactation' => 1.3 }
      },
      {
        key: 'clockwork_brothel', name: 'The Clockwork Brothel', weight: 0.8,
        flavour: 'gears sigh behind velvet walls and the furniture has been wound up and left eager',
        monsters: { 'mimic' => 1.4, 'clown' => 1.3 }, tags: { 'toys' => 1.7, 'objectification' => 1.5, 'latex' => 1.5, 'clowns' => 1.4 }
      },
      {
        key: 'ashen_court', name: 'The Ashen Court', weight: 0.7,
        flavour: 'a burnt-out court of beautiful, cruel nobles who never stopped whispering about you',
        monsters: { 'demon' => 1.5 }, tags: { 'degradation' => 1.6, 'slavery' => 1.5, 'spanking' => 1.4 }
      },
      {
        key: 'flooded_grotto', name: 'The Flooded Grotto', weight: 0.8,
        flavour: 'warm pools steam between ferns, and the water keeps touching you back',
        monsters: { 'slime' => 1.4, 'plant' => 1.4 }, tags: { 'oviposition' => 1.7, 'breeding' => 1.5, 'tentacles' => 1.3 }
      },
      {
        key: 'masquerade_ball', name: 'The Masquerade Ball', weight: 0.7,
        flavour: 'an endless masked ball where every dancer already knows your name and your tastes',
        monsters: { 'demon' => 1.3, 'undead' => 1.3, 'clown' => 1.2 },
        tags: { 'exhibitionism' => 1.5, 'group_sex' => 1.5, 'voyeurism' => 1.4, 'clowns' => 1.5 }
      }
    ].freeze

    module_function

    # Deterministic fallback, used when there is no player to roll for.
    def for_floor(floor)
      BIOMES[(([floor.to_i, 1].max - 1) / BLOCK_SIZE) % BIOMES.size]
    end

    def by_key(key)
      BIOMES.find { |b| b[:key] == key.to_s }
    end

    def section_for(floor)
      ([floor.to_i, 1].max - 1) / BLOCK_SIZE
    end

    def boss_type_for_section(section)
      last_floor = (section.to_i + 1) * BLOCK_SIZE
      wrapped = ((last_floor - 1) % 35) + 1
      SECTION_BOSS_TYPES[wrapped]
    end

    def roll_biome(player, section)
      boss_type = boss_type_for_section(section)
      weighted = BIOMES.map do |biome|
        weight = biome[:weight].to_f
        weight *= BOSS_AFFINITY if boss_type && biome[:monsters].key?(boss_type)
        [biome, [weight, 0.01].max]
      end
      roll = rand * weighted.sum { |(_, w)| w }
      weighted.each do |biome, weight|
        roll -= weight
        return biome if roll <= 0
      end
      weighted.last.first
    end

    # The player's current biome, rolled and remembered the first time
    # they enter each five-floor section.
    def current(player)
      return for_floor(1) unless player

      section = section_for(player.current_floor)
      stamp = "#{player.current_cycle.to_i}:#{section}"
      biome = by_key(player.tracker_hash['biome_key']) if player.tracker_hash['biome_section'].to_s == stamp
      return biome if biome

      biome = roll_biome(player, section)
      player.update(trackers: player.tracker_hash.merge('biome_section' => stamp, 'biome_key' => biome[:key]))
      biome
    end

    def monster_weight(player, type)
      return 1.0 unless player

      current(player)[:monsters].fetch(type.to_s, 1.0)
    end

    def event_weight(player, tag)
      return 1.0 unless player && tag

      current(player)[:tags].fetch(tag.to_s, 1.0)
    end

    # Each five-floor section belongs to the lord waiting at its end; the
    # land was shaped around them and reshapes itself in their idiom.
    DOMAIN_INTROS = {
      5 => ['the Mimic Broodmother', 'The furniture is already watching you, and the walls keep ' \
            'rearranging themselves into warmer, hungrier rooms. Everything here wants to keep you inside it.'],
      10 => ['the Succubus Queen', 'Court etiquette hangs in the air like perfume, and the corridors keep ' \
             're-polishing themselves for an audience. Everything here wants to be chosen by her — and to choose you.'],
      15 => ['the Incubus King', 'The halls carry a swagger; doors open like challenges and the very ' \
             'furniture seems claimed. Everything here is already his — the land is merely deciding how you will be, too.'],
      20 => ['the Verdant Dryad', 'Green things push through every seam, and the paths regrow behind you ' \
             'softer than they were. Everything here wants company, planted close and kept.'],
      25 => ['the Lich Lord', 'Cold order settles over the stone; shelves, labels and specimens multiply ' \
             'in the dark. Everything here wants you catalogued, studied — and kept warm in the archive.'],
      30 => ['the Alpha Beast', 'The corridors widen into runs and dens, scratched, scent-marked, lived-in. ' \
             'Everything here smells of pack. Everything here is deciding whether you run with it.'],
      35 => ['Eros', 'The dreaming court. Silk and candlelight breathe in and out of existence, altars ' \
             'surface like stones in a tide, and the land reshapes itself almost as fast as you look at ' \
             'it. She is close. The danger here is not the monsters — it is being noticed.']
    }.freeze

    def wrapped_floor(floor)
      ((floor.to_i - 1) % 35) + 1
    end

    # One-time line for the first room a delver sees in a new section
    # (per cycle). Returns nil once shown, or outside a section start.
    def domain_intro(player)
      return nil unless player

      wrapped = wrapped_floor(player.current_floor)
      return nil unless (wrapped % BLOCK_SIZE) == 1

      lord, text = DOMAIN_INTROS[wrapped + BLOCK_SIZE - 1]
      return nil unless lord

      stamp = "#{player.current_cycle.to_i}:#{section_for(player.current_floor)}"
      return nil if player.tracker_hash['domain_intro_stamp'].to_s == stamp

      player.set_tracker!('domain_intro_stamp', stamp)
      "👑 **Domain of #{lord} — floors #{wrapped}–#{wrapped + BLOCK_SIZE - 1}.** #{text}"
    end

    def line(player)
      biome = current(player)
      boss_type = player && boss_type_for_section(section_for(player.current_floor))
      hint = boss_type && biome[:monsters].key?(boss_type) ? " The land itself serves the **#{boss_type}** waiting below." : ''
      "🌘 **#{biome[:name]}** — #{biome[:flavour]}.#{hint}"
    end
  end
end
