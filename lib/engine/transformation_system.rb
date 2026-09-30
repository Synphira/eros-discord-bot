# frozen_string_literal: true

module Engine
  module TransformationSystem
    PETKIN = {
      requirement: { petplay_events: 5, beast_submissions: 10 },
      events: { 'petplay' => 25 },
      monsters: { beast: 30 }
    }.freeze

    TRANSFORMATIONS = {
      'kitten' => PETKIN.merge(
        name: 'Kitten', group: 'Beast',
        description: "You've developed feline features — soft ears, a swishing tail, and heightened senses",
        appearance: ['cat ears', 'flexible spine', 'retractable claws', 'cat tail']
      ),
      'puppy' => PETKIN.merge(
        name: 'Puppy', group: 'Beast',
        description: "You've developed canine features — floppy ears, a wagging tail, and an eager-to-please heart",
        appearance: ['floppy ears', 'wagging tail', 'keen nose', 'padded palms']
      ),
      'hucow' => {
        name: 'HuCow', group: 'Beast',
        description: "You've developed bovine features — heavy, leaking breasts and a docile, milkable body",
        requirement: { being_milked_events: 3, lactation_events: 3, weight_gain_events: 3 },
        appearance: ['multiple breasts', 'udder', 'small horns', 'cow tail'],
        events: { 'lactation' => 35, 'weight_gain' => 25 }
      },
      'harpy' => {
        name: 'Harpy', group: 'Beast',
        description: "You've developed avian features including wings and clawed feet",
        requirement: { petplay_events: 5, body_growth_events: 3, exhibitionism_events: 3 },
        appearance: ['feathered arms/wings', 'clawed feet', 'lighter bones'],
        events: { 'exhibitionism' => 30, 'giant' => 25 },
        monsters: { beast: 20 }
      },
      'slimekin' => {
        name: 'Slimekin', group: 'Beast',
        description: 'Your body has become partially gelatinous and amorphous',
        requirement: { slime_submissions: 10, inflation_events: 3 },
        appearance: ['semi-translucent skin', 'amorphous limbs', 'no fixed shape'],
        events: { 'inflation' => 35, 'living_clothing' => 15 },
        monsters: { slime: 30 }
      },
      'succubus' => {
        name: 'Succubus', group: 'Demon',
        description: "You've transformed into a creature of seduction and dreams",
        requirement: { demon_submissions: 15, futanari_events: 3 },
        appearance: ['small wings', 'small horns', 'supernatural beauty', 'tail'],
        events: { 'futanari' => 30, 'mind_control' => 25 },
        monsters: { demon: 35 }
      },
      'incubus' => {
        name: 'Incubus', group: 'Demon',
        description: "You've transformed into a creature of seduction and desire",
        requirement: { demon_submissions: 15, futanari_events: 3 },
        appearance: ['supernatural charm', 'small wings', 'small horns'],
        events: { 'futanari' => 30, 'mind_control' => 25 },
        monsters: { demon: 35 }
      },
      'imp' => {
        name: 'Imp', group: 'Demon',
        description: "You've transformed into a small, mischievous lesser demon",
        requirement: { demon_submissions: 10, body_reduction_events: 3, mind_control_events: 3 },
        appearance: ['small stature', 'wings', 'horns', 'tail'],
        events: { 'mind_control' => 35, 'shrinking' => 25 },
        monsters: { demon: 30 }
      },
      'dryad' => {
        name: 'Dryad', group: 'Plant',
        description: "You've become one with the plant life of the tower",
        requirement: { plant_submissions: 10, objectification_events: 3 },
        appearance: ['bark skin', 'leaves in hair', 'root-like feet'],
        events: { 'objectification' => 25, 'bondage' => 20 },
        monsters: { plant: 35 }
      },
      'alraune' => {
        name: 'Alraune', group: 'Plant',
        description: "You've become a predatory plant creature focused on luring prey",
        requirement: { plant_submissions: 10, futanari_events: 3, mind_control_events: 3 },
        appearance: ['petal-like skin', 'sweet scent', 'vine hair'],
        events: { 'mind_control' => 30, 'futanari' => 25 },
        monsters: { plant: 35 }
      },
      'living_doll' => {
        name: 'Living Doll', group: 'Object',
        description: "You've become more object than person, with porcelain skin and jointed limbs",
        requirement: { objectification_events: 5, petplay_events: 3, mind_control_events: 3 },
        appearance: ['porcelain skin', 'jointed limbs', 'glass eyes'],
        events: { 'objectification' => 35, 'petplay' => 25, 'mind_control' => 20 }
      },
      'furniture' => {
        name: 'Furniture', group: 'Object',
        description: "You've lost your humanity, becoming literally functional furniture",
        requirement: { objectification_events: 10, slavery_events: 5, bondage_events: 3 },
        appearance: ['wood-like skin', 'functional shape'],
        events: { 'objectification' => 40, 'slavery' => 30, 'bondage' => 25 }
      },
      'vampire' => {
        name: 'Vampire', group: 'Supernatural',
        description: "You've become a creature of the night — a thrall-maker with undead hunger",
        requirement: { undead_submissions: 15, mind_control_events: 3, slavery_events: 3 },
        appearance: ['pale skin', 'fangs', 'red eyes'],
        events: { 'mind_control' => 25, 'slavery' => 20 },
        monsters: { undead: 30 }
      },
      'ghost' => {
        name: 'Ghost', group: 'Supernatural',
        description: "You've become ethereal, partially intangible",
        requirement: { undead_submissions: 10, sensory_deprivation_events: 3, bondage_events: 3 },
        appearance: ['translucent body', 'floats', 'cold touch'],
        events: { 'sensory_deprivation' => 35, 'bondage' => 20 },
        monsters: { undead: 30 }
      },
      'latexdoll' => {
        name: 'Latexdoll', group: 'Synthetic',
        description: 'Your skin has become shiny and synthetic, erasing your human features',
        requirement: { latex_events: 10, mind_control_events: 3 },
        appearance: ['rubber skin', 'featureless face', 'seamless body'],
        events: { 'latex' => 40, 'mind_control' => 25, 'living_clothing' => 20 }
      },
      'rubberslime' => {
        name: 'Rubberslime', group: 'Synthetic',
        description: "You've become a hybrid of slime and rubber properties",
        requirement: { latex_events: 7, inflation_events: 3, slime_submissions: 7 },
        appearance: ['shiny translucent skin', 'amorphous shape'],
        events: { 'inflation' => 30, 'latex' => 35 },
        monsters: { slime: 25 }
      },
      'angel' => {
        name: 'Angel', group: 'Holy',
        description: 'Your untouched purity has lifted you above the ruins — monsters shy from your light',
        requirement: { pure_title: true },
        appearance: ['feathered wings', 'soft halo', 'radiant skin'],
        monster_rate: 0.7,
        event_rate: 1.35,
        all_events: 20
      }
    }.freeze

    MONSTER_LABELS = {
      beast: 'Beast', demon: 'Demon', slime: 'Slime', undead: 'Undead', plant: 'Plant', mimic: 'Mimic'
    }.freeze

    module_function

    def get(key)
      TRANSFORMATIONS[key.to_s]
    end

    def find(query)
      q = query.to_s.strip.downcase
      return nil if q.empty?

      TRANSFORMATIONS.find { |k, t| k == q || t[:name].downcase == q || k.tr('_', ' ') == q }&.first
    end

    def eligible?(player, key)
      entry = get(key)
      entry ? Engine::TitleSystem.met?(player, entry[:requirement]) : false
    end

    def visible(player)
      owned = player.unlocked_transformations
      TRANSFORMATIONS.select { |k, t| owned.include?(k) || Engine::TitleSystem.visible?(player, t) }
    end

    def active(player)
      get(player.active_transformation_key)
    end

    def monster_rate(player)
      active(player)&.dig(:monster_rate) || 1.0
    end

    def event_rate(player)
      active(player)&.dig(:event_rate) || 1.0
    end

    def monster_weight(player, type)
      form = active(player)
      return 1.0 unless form

      1.0 + (Hash(form[:monsters])[type.to_sym].to_i / 100.0)
    end

    def event_weight(player, tag)
      form = active(player)
      return 1.0 unless form

      bonus = form[:all_events].to_i
      bonus += Hash(form[:events])[tag.to_s].to_i if tag
      1.0 + (bonus / 100.0)
    end

    def effect_lines(entry)
      lines = []
      if entry[:monster_rate] && entry[:monster_rate] != 1.0
        lines << "Monster rooms #{signed_pct(entry[:monster_rate])}"
      end
      lines << "Random events #{signed_pct(entry[:event_rate])}" if entry[:event_rate] && entry[:event_rate] != 1.0
      lines << "Every event type +#{entry[:all_events]}%" if entry[:all_events].to_i.positive?
      Hash(entry[:monsters]).each { |type, pct| lines << "#{MONSTER_LABELS.fetch(type, type.to_s.capitalize)} monsters +#{pct}%" }
      Hash(entry[:events]).each do |tag, pct|
        label = Engine::ContentOptions.preference(tag)&.dig(:label) || tag.tr('_', ' ').capitalize
        lines << "#{label} events +#{pct}%"
      end
      lines
    end

    def signed_pct(mult)
      pct = ((mult.to_f - 1) * 100).round
      pct.negative? ? "#{pct}%" : "+#{pct}%"
    end
  end
end
