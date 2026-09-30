# frozen_string_literal: true

module Engine
  module MonsterScenes
    module_function

    def generate(player, monster_name, monster_type: nil)
      parts = player.body_parts_list.map(&:to_s)
      scenes =
        case monster_type.to_s
        when 'beast' then generate_beast_scene(parts, monster_name)
        when 'demon' then generate_demon_scene(parts, monster_name)
        when 'slime' then generate_slime_scene(parts, monster_name)
        when 'undead' then generate_undead_scene(parts, monster_name)
        when 'plant' then generate_plant_scene(parts, monster_name)
        when 'mimic' then generate_mimic_scene(parts, monster_name)
        else []
        end

      Engine::ContentOptions.pick(player, scenes, fallback: generic_scenes(monster_name))
    end

    def generate_assault(player, monster_name, monster_type: nil)
      parts = player.body_parts_list.map(&:to_s)
      scenes =
        case monster_type.to_s
        when 'beast' then generate_beast_assault(parts, monster_name)
        when 'demon' then generate_demon_assault(parts, monster_name)
        when 'slime' then generate_slime_assault(parts, monster_name)
        when 'undead' then generate_undead_assault(parts, monster_name)
        when 'plant' then generate_plant_assault(parts, monster_name)
        when 'mimic' then generate_mimic_assault(parts, monster_name)
        else []
        end

      Engine::ContentOptions.pick(player, scenes, fallback: generic_assault(monster_name))
    end

    def generate_beast_assault(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The beast plunges its knotting cock into your eager cunt, swelling with each thrust until you're locked together in blissful union."
        scenes << "The #{monster_name} mounts you from behind, its powerful hips driving deep as your body responds with waves of pleasure."
        scenes << "The animal positions you perfectly, entering with practiced movements that make your toes curl in ecstasy."
      end

      if parts.include?('penis')
        scenes << "The beast's rough tongue laps at your cock, bringing you to the edge with expert precision."
        scenes << "The #{monster_name} takes your shaft into its hot mouth, its teeth gently grazing as it worships your length."
        scenes << "The animal's soft paws caress your balls as it strokes you, coaxing pleasure from your very core."
      end

      if parts.include?('anus')
        scenes << "The #{monster_name} slides its thick knot into your welcoming ass, your body accommodating its size with hungry anticipation."
        scenes << "The beast mounts you with primal grace, each movement sending jolts of pleasure through your body."
        scenes << "The animal's claws grip your hips possessively as it claims your ass, marking you as its mate."
      end

      if parts.include?('breasts')
        scenes << "The beast's rough tongue traces circles around your nipples, making them ache with need."
        scenes << "The #{monster_name} nips playfully at your breasts, its teeth sending tingles through your sensitive flesh."
        scenes << "The animal's soft paws knead your tits, knowing exactly how to make you moan with pleasure."
      end

      scenes
    end

    def generate_demon_assault(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The demon's fiery cock stretches your willing cunt, its heat amplifying every sensation as it claims you."
        scenes << "The #{monster_name} summons shadowy tendrils that caress your inner walls, finding spots you never knew existed."
        scenes << "The demon's barbed member scrapes deliciously against your sensitive flesh, each movement bringing you closer to ecstasy."
      end

      if parts.include?('penis')
        scenes << "The demon's bottomless throat takes your entire length, its supernatural skill bringing you pleasure beyond mortal limits."
        scenes << "The #{monster_name}'s hot tail coils around your cock, its scales providing the perfect friction as it milks you."
        scenes << "Shadowy hands fondle your balls, knowing exactly how to tease and please as the demon drains your seed."
      end

      if parts.include?('anus')
        scenes << "The demon's burning cock claims your ass, the heat making your body tingle with anticipation."
        scenes << "The #{monster_name}'s barbed tail rakes your insides with pleasure, each thrust bringing new waves of delight."
        scenes << "Shadowy tendrils explore your depths, filling you completely with their pulsating energy."
      end

      if parts.include?('breasts')
        scenes << "The demon's claws trace glowing patterns on your breasts, the marks humming with magical energy."
        scenes << "The #{monster_name}'s mouth worships your nipples, its sharp teeth providing the perfect edge of sensation."
        scenes << "Shadowy hands cup your tits, their unnatural warmth making you moan with need."
      end

      scenes
    end

    def generate_slime_assault(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The slime molds perfectly to your inner walls, its gelatinous form stimulating every nerve as it fills you completely."
        scenes << "The #{monster_name} flows into your welcoming cunt, its cool touch a delightful contrast to the heat building within."
        scenes << "The slime's tendrils explore your depths, finding new ways to pleasure you with each movement."
      end

      if parts.include?('penis')
        scenes << "The slime engulfs your cock in its slick body, its pulsating rhythm bringing you to heights of pleasure."
        scenes << "The #{monster_name} forms the perfect sheath around your shaft, its texture unlike anything you've felt before."
        scenes << "The slime's cool tendrils wrap around your balls, squeezing gently as it pleasures you in ways you never imagined."
      end

      if parts.include?('anus')
        scenes << "The slime flows into your eager ass, its form adapting to provide the perfect pressure against your sensitive walls."
        scenes << "The #{monster_name} fills you completely, its cool touch making your body tingle with anticipation."
        scenes << "The slime's tendrils explore your depths, finding spots that make you cry out with pleasure."
      end

      if parts.include?('breasts')
        scenes << "The slime covers your breasts, its cool body making your nipples stand erect with need."
        scenes << "The #{monster_name}'s tendrils tease your nipples, their touch sending waves of pleasure through you."
        scenes << "The slime molds to your tits, its surface vibrating with each pulse of its energy."
      end

      scenes
    end

    def generate_undead_assault(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The undead's cold member sends shivers through your body, the chill heightening your senses as it enters you."
        scenes << "The #{monster_name}'s bony fingers trace patterns on your inner walls, their touch strangely arousing as they explore."
        scenes << "The zombie's rigid flesh fills you perfectly, its unnatural temperature making every sensation more intense."
      end

      if parts.include?('penis')
        scenes << "The undead's cold mouth engulfs your cock, its touch sending bolts of pleasure through your body."
        scenes << "The #{monster_name}'s bony fingers wrap around your shaft, their sharp edges providing just the right amount of stimulation."
        scenes << "The ghost's ethereal mouth takes you deep, its cold touch somehow more arousing than warmth."
      end

      if parts.include?('anus')
        scenes << "The undead's cold cock claims your ass, the chill making every nerve ending tingle with pleasure."
        scenes << "The #{monster_name}'s bony fingers explore your depths, their touch sending shivers of delight through you."
        scenes << "The zombie's rigid member fills you completely, its unnatural temperature heightening every sensation."
      end

      if parts.include?('breasts')
        scenes << "The undead's cold hands cup your breasts, their touch making your nipples stand erect with desire."
        scenes << "The #{monster_name}'s bony fingers trace patterns on your sensitive skin, their touch sending shivers through you."
        scenes << "The ghost's ethereal hands pass through your flesh, their cold touch somehow arousing beyond words."
      end

      scenes
    end

    def generate_plant_assault(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The plant's smooth vine slides into your wet cunt, its natural ridges stimulating your inner walls perfectly."
        scenes << "The #{monster_name}'s pollen-coated tendrils caress your inner walls, the aphrodisiac filling you with desire."
        scenes << "The plant's stinger injects you with pleasure-enhancing nectar as it thrusts, your body responding eagerly."
      end

      if parts.include?('penis')
        scenes << "The plant's flowering sheath closes around your cock, its inner petals providing the perfect stimulation."
        scenes << "The #{monster_name}'s smooth vine wraps around your shaft, its natural ridges driving you wild with pleasure."
        scenes << "The plant's nectar drips onto your cock, its aphrodisiac properties making you harder than ever before."
      end

      if parts.include?('anus')
        scenes << "The plant's smooth vine enters your eager ass, its natural texture providing the perfect friction."
        scenes << "The #{monster_name}'s stinger injects pleasure-enhancing nectar as it thrusts, your body responding with waves of ecstasy."
        scenes << "The plant's roots expand inside you, filling you completely as they stimulate every sensitive spot."
      end

      if parts.include?('breasts')
        scenes << "The plant's soft vines wrap around your breasts, their touch making your nipples ache with need."
        scenes << "The #{monster_name}'s flowers bloom around your nipples, sucking gently as they release their nectar."
        scenes << "The plant's pollen covers your tits, making them tingle with heightened sensitivity."
      end

      scenes
    end

    def generate_mimic_assault(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The mimic's tongue-like appendage slides into your cunt, its texture hitting all the right spots as it explores."
        scenes << "The #{monster_name} reveals its true form, its opening transforming into a perfect match for your body as it pleasures you."
        scenes << "The mimic's tendrils caress your inner walls, knowing exactly how to make you moan with pleasure."
      end

      if parts.include?('penis')
        scenes << "The mimic's warm opening engulfs your cock, its inner walls pulsating with perfect rhythm as it milks you."
        scenes << "The #{monster_name} transforms to accommodate you perfectly, its texture driving you wild with pleasure."
        scenes << "The mimic's tendrils wrap around your shaft, knowing exactly how to bring you to the edge and hold you there."
      end

      if parts.include?('anus')
        scenes << "The mimic's appendage slides into your eager ass, its form adapting to provide maximum pleasure."
        scenes << "The #{monster_name} reveals itself, its texture transforming into the perfect stimulation as it claims you."
        scenes << "The mimic's tendrils explore your depths, finding spots that make your whole body tremble with pleasure."
      end

      if parts.include?('breasts')
        scenes << "The mimic's soft tendrils wrap around your breasts, their touch sending waves of pleasure through you."
        scenes << "The #{monster_name} transforms to reveal a mouth-like opening that suckles your nipples perfectly."
        scenes << "The mimic's appendages know exactly how to tease your sensitive flesh, making you gasp with delight."
      end

      scenes
    end

    def generic_assault(monster_name)
      [
        "The #{monster_name} presses against you, its body molding to yours as it seeks pleasure in your embrace.",
        "The #{monster_name} touches you in ways that make your body tremble with anticipation and need.",
        "The #{monster_name} holds you close, its movements becoming more urgent as you both chase ecstasy.",
        "The #{monster_name} explores your body with expert hands, finding places that make you cry out with pleasure.",
        "The #{monster_name} moves against you, its rhythm perfectly matching your body's growing desire."
      ]
    end

    def generate_beast_scene(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The #{monster_name} positions you on all fours, its strong hands gripping your hips as it enters with a satisfied growl."
        scenes << "The beast mounts you from behind, its furry body against your skin as it claims you as its mate."
        scenes << "The #{monster_name} nuzzles your neck before entering, its animalistic need driving it deep inside you."
        scenes << "The beast flips you onto your back, its weight pressing you down as it slides into your wet cunt."
      end

      if parts.include?('penis')
        scenes << "The #{monster_name} pins you gently, its rough tongue wrapping around your cock as it tastes your arousal."
        scenes << "The beast's soft paws caress your body, one hand stroking your length while it nibbles your neck."
        scenes << "The #{monster_name} licks your balls with its rough tongue, the texture driving you wild with pleasure."
      end

      if parts.include?('anus')
        scenes << "The #{monster_name} mounts you with animalistic grace, its thick cock stretching you perfectly as it enters."
        scenes << "The beast prepares you with its tongue, wetting your hole before plunging deep inside with a growl."
        scenes << "The #{monster_name} takes you from behind, its heavy balls slapping against you with each thrust."
      end

      if parts.include?('breasts')
        scenes << "The #{monster_name} laps at your nipples with its rough tongue, making them stand erect with need."
        scenes << "The beast nuzzles your breasts, its hot breath against your skin before taking a nipple in its mouth."
        scenes << "The #{monster_name}'s soft paws knead your tits, its touch surprisingly gentle despite its strength."
      end

      scenes
    end

    def generate_demon_scene(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The #{monster_name} whispers dark promises as it enters, its heat filling you with unnatural desire."
        scenes << "The demon's tail teases your clit as it thrusts, its touch making you gasp with pleasure."
        scenes << "The #{monster_name} marks your thigh with a glowing symbol as it claims you, the heat spreading through your body."
      end

      if parts.include?('penis')
        scenes << "The #{monster_name} summons magical tendrils that worship your cock, bringing you to heights of ecstasy."
        scenes << "The demon's hot mouth takes you deep, its tongue swirling in impossible patterns as it pleasures you."
        scenes << "The #{monster_name} wraps its wings around you, its feathers brushing against your sensitive skin as it strokes you."
      end

      if parts.include?('anus')
        scenes << "The #{monster_name} prepares you with its magical tongue, the sensations making you beg for more."
        scenes << "The demon's shadowy tendrils fill you completely, their pulsating rhythm driving you wild with pleasure."
        scenes << "The #{monster_name} enters you with impossible heat, its touch making your body tingle with anticipation."
      end

      if parts.include?('breasts')
        scenes << "The #{monster_name} traces glowing runes on your breasts, the magic making them ache with need."
        scenes << "The demon's hot mouth worships your nipples, its teeth providing just the right edge of sensation."
        scenes << "The #{monster_name}'s shadowy hands massage your tits, their touch making you moan with pleasure."
      end

      scenes
    end

    def generate_slime_scene(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The #{monster_name} flows into your willing cunt, its cool touch making you gasp as it fills you completely."
        scenes << "The slime forms a perfect shape to stimulate your inner walls, pulsating with pleasure as it moves."
        scenes << "The #{monster_name}'s tendrils explore your depths, finding spots that make your whole body tremble with delight."
        scenes << "The slime changes its viscosity to perfectly match your desires, becoming more liquid as you near climax."
      end

      if parts.include?('penis')
        scenes << "The #{monster_name} engulfs your cock in its cool body, contracting around you with perfect rhythm."
        scenes << "The slime forms additional tendrils to tease your balls while the main body pleasures your shaft."
        scenes << "The #{monster_name} changes its texture to provide the perfect stimulation, its surface becoming more ribbed as you near climax."
      end

      if parts.include?('anus')
        scenes << "The #{monster_name} flows into your eager ass, its cool touch making you gasp with pleasure."
        scenes << "The slime forms tendrils that stimulate your prostate perfectly, making you see stars with each movement."
        scenes << "The #{monster_name} expands and contracts inside you, its rhythm driving you closer to ecstasy with each pulse."
      end

      if parts.include?('breasts')
        scenes << "The #{monster_name} covers your breasts with its cool body, forming tendrils that tease your nipples."
        scenes << "The slime changes its color to match your arousal, darkening as it senses your growing need."
        scenes << "The #{monster_name} forms small appendages to worship your nipples, their touch making you gasp with pleasure."
      end

      scenes
    end

    def generate_undead_scene(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The #{monster_name} enters you with its cold member, the chill making every sensation more intense."
        scenes << "The undead creature kisses your neck as it thrusts, its cold touch sending shivers through your body."
        scenes << "The #{monster_name}'s phantasmal form penetrates you completely, its touch making you ache with need."
      end

      if parts.include?('penis')
        scenes << "The #{monster_name} wraps its cold hands around your cock, its touch making you harder than you've ever been."
        scenes << "The ghost's ethereal mouth takes you deep, its cold touch somehow more arousing than warmth."
        scenes << "The #{monster_name} phases through your clothes to touch you directly, its cold fingers making you gasp."
      end

      if parts.include?('anus')
        scenes << "The #{monster_name} enters you with its cold member, the chill heightening your pleasure with each thrust."
        scenes << "The specter prepares you with its cold tongue, making you beg for more as it explores your depths."
        scenes << "The #{monster_name} holds you in its cold embrace as it takes you, its touch making your body tremble."
      end

      if parts.include?('breasts')
        scenes << "The #{monster_name} touches your breasts with its icy hands, the cold making your nipples stand erect with desire."
        scenes << "The ghost's fingers trace patterns on your sensitive skin, their touch sending waves of pleasure through you."
        scenes << "The #{monster_name} nips at your nipples with its cold teeth, the sensation making you gasp with delight."
      end

      scenes
    end

    def generate_mimic_scene(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The #{monster_name} reveals its true nature, its opening transforming into the perfect shape to pleasure you."
        scenes << "The mimic's tongue-like appendage slides into your wet cunt, its texture hitting all the right spots."
        scenes << "The #{monster_name}'s interior reveals soft, pulsating walls that grip you perfectly as it moves."
        scenes << "The mimic changes its texture to provide the perfect stimulation, becoming more ribbed as your pleasure builds."
      end

      if parts.include?('penis')
        scenes << "The #{monster_name} transforms to reveal a warm, wet opening that engulfs your cock completely."
        scenes << "The mimic's interior molds perfectly to your shape, its walls pulsating with rhythm that drives you wild."
        scenes << "The #{monster_name} forms tendrils that tease your balls while the main body pleasures your shaft."
      end

      if parts.include?('anus')
        scenes << "The #{monster_name} reveals a phallic appendage that slides into you with perfect ease."
        scenes << "The mimic changes its texture to match your desires, becoming smoother or rougher as your pleasure dictates."
        scenes << "The #{monster_name}'s appendages know exactly how to stimulate you, finding spots that make you cry out with ecstasy."
      end

      if parts.include?('breasts')
        scenes << "The #{monster_name} opens to reveal soft, wet appendages that worship your breasts."
        scenes << "The mimic's tendrils wrap around your nipples, their texture changing to provide the perfect stimulation."
        scenes << "The #{monster_name} changes its form to perfectly pleasure you, adapting to your every response."
      end

      scenes
    end

    def generate_plant_scene(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The #{monster_name}'s smooth vines enter you, their natural texture stimulating your inner walls perfectly."
        scenes << "The plant monster's pollen fills the air, making your body ache with desire as it takes you."
        scenes << "The #{monster_name}'s flower-tipped tendril thrusts into your wet cunt, its nectar making you moan with pleasure."
        scenes << "The plant releases its aphrodisiac as it thrusts, your body responding eagerly to its touch."
      end

      if parts.include?('penis')
        scenes << "The #{monster_name} wraps its vines around your cock, their natural texture driving you wild with pleasure."
        scenes << "The plant's flowering sheath engulfs your shaft, its inner petals providing the perfect stimulation."
        scenes << "The #{monster_name}'s pollen-coated tendrils stroke you, the aphrodisiac making you harder than ever."
      end

      if parts.include?('anus')
        scenes << "The #{monster_name} forces its smooth vine into your eager ass, the texture making you gasp with pleasure."
        scenes << "The plant monster's root-like appendage fills you completely, its natural ridges stimulating you perfectly."
        scenes << "The #{monster_name} releases pleasure-enhancing nectar as it thrusts, your body responding with waves of ecstasy."
      end

      if parts.include?('breasts')
        scenes << "The #{monster_name}'s soft vines wrap around your breasts, their touch making your nipples ache with need."
        scenes << "The plant's flowers bloom around your nipples, sucking gently as they release their sweet nectar."
        scenes << "The #{monster_name}'s pollen covers your tits, making them tingle with heightened sensitivity and desire."
      end

      scenes
    end

    def generic_scenes(monster_name)
      [
        "The #{monster_name} presses its body against yours, its touch making your skin tingle with anticipation.",
        "The #{monster_name} whispers your name as it explores your body, knowing exactly how to please you.",
        "The #{monster_name} holds you close, its heartbeat quickening as your bodies move together in perfect rhythm.",
        "The #{monster_name} kisses you deeply, its touch making your body respond with growing heat and desire.",
        "The #{monster_name} traces patterns on your skin, each touch sending jolts of pleasure through your body.",
        "The #{monster_name} moves against you with practiced skill, its body finding yours in the darkness.",
        "The #{monster_name} worships your body with its hands and mouth, leaving no part of you untouched."
      ]
    end

  def generate_willing_scene(player, monster_name, monster_type: nil)
    parts = player.body_parts_list.map(&:to_s)
    scenes =
      case monster_type.to_s
      when 'beast' then generate_beast_willing(parts, monster_name)
      when 'demon' then generate_demon_willing(parts, monster_name)
      when 'slime' then generate_slime_willing(parts, monster_name)
      when 'undead' then generate_undead_willing(parts, monster_name)
      when 'plant' then generate_plant_willing(parts, monster_name)
      when 'mimic' then generate_mimic_willing(parts, monster_name)
      else []
      end
  
    Engine::ContentOptions.pick(player, scenes, fallback: generic_willing(monster_name))
  end

  PRAISE = {
    'beast' => [
      'The %<name>s rumbles a deep, contented purr and nuzzles your neck — a clear sign you have pleased it.',
      'The %<name>s licks your cheek affectionately, its tail wagging. Good pet.',
      'The %<name>s rests its heavy head against you, huffing warm approval.'
    ],
    'demon' => [
      '"Such a delicious little mortal," the %<name>s purrs, tracing a claw under your chin. "You learn so quickly."',
      '"Mm, you were made for this," the %<name>s whispers. "I may have to keep you."',
      'The %<name>s laughs low and pleased. "Exquisite. Hell itself would envy me."'
    ],
    'slime' => [
      'The %<name>s wobbles happily, its surface rippling in bright, contented colours.',
      'The %<name>s gives a pleased little gurgle and hugs you in a warm, squishy embrace.',
      'The %<name>s glows softly, humming a bubbly note of approval.'
    ],
    'undead' => [
      '"Warm... so warm," the %<name>s rasps reverently. "You remind me what it was to live."',
      'The %<name>s bows its hollow head to you, cold fingers tender now. "Thank you, living one."',
      'The %<name>s sighs a long, peaceful breath it no longer needs. "Perfect."'
    ],
    'plant' => [
      'The %<name>s blooms around you, its petals unfurling in a burst of sweet, grateful perfume.',
      'The %<name>s rustles contentedly, gently stroking your hair with a soft tendril.',
      'The %<name>s showers you with glittering pollen — its way of saying you did beautifully.'
    ],
    'mimic' => [
      'The %<name>s clacks its lid in delighted applause. You are clearly its favourite treasure.',
      'The %<name>s shivers with pleasure, its false wood creaking a happy tune.',
      'The %<name>s wraps a tongue around your wrist like a proud little ribbon.'
    ]
  }.freeze

  GENERIC_PRAISE = [
    'The %<name>s regards you with open admiration. "Good. Very good."',
    'The %<name>s murmurs its approval, clearly delighted with you.'
  ].freeze

  def generate_praise(player, monster_name, monster_type)
    lines = PRAISE.fetch(monster_type.to_s, GENERIC_PRAISE).map { |l| format(l, name: monster_name) }
    Engine::ContentOptions.pick(player, lines, fallback: GENERIC_PRAISE.map { |l| format(l, name: monster_name) })
  end
  
  def generate_beast_willing(parts, monster_name)
    scenes = []
  
    if parts.include?('vagina')
      scenes << "You spread your legs invitingly for the #{monster_name}, presenting your wet cunt for its pleasure."
      scenes << "You arch your back, meeting the beast's passionate thrusts with your own hips as it fills you completely."
      scenes << "You wrap your legs around the #{monster_name}'s waist, pulling it deeper as you both chase ecstasy."
      scenes << "You guide the beast's member to your entrance, gasping as it enters you with primal force."
    end
  
    if parts.include?('penis')
      scenes << "You present your erect cock to the #{monster_name}, moaning as its rough tongue wraps around your shaft."
      scenes << "You thrust into the beast's hot mouth, your hands gripping its fur as it worships your length."
      scenes << "You guide the #{monster_name}'s muzzle to your balls, groaning as it takes each one into its mouth."
    end
  
    if parts.include?('anus')
      scenes << "You bend over for the #{monster_name}, spreading your cheeks to invite its thick knot into your eager ass."
      scenes << "You push back against the beast's thrusts, your body welcoming its invading member with pleasure."
      scenes << "You reach back to guide the #{monster_name}'s cock to your hole, gasping as it enters you with force."
    end
  
    if parts.include?('breasts')
      scenes << "You offer your breasts to the #{monster_name}, moaning as its rough tongue laps at your nipples."
      scenes << "You press your tits against the beast's face, encouraging it to suck and nip at your sensitive flesh."
      scenes << "You bounce your breasts in the #{monster_name}'s face, giggling as it tries to catch your nipples with its teeth."
    end
  
    scenes
  end
  
  def generate_demon_willing(parts, monster_name)
    scenes = []
  
    if parts.include?('vagina')
      scenes << "You lie back, spreading your legs for the #{monster_name} as it approaches with burning desire."
      scenes << "You meet the demon's passionate thrusts with your own, your body accepting its infernal heat."
      scenes << "You whisper dark words of invitation, encouraging the #{monster_name} to claim you completely."
      scenes << "You guide the demon's barbed member to your entrance, gasping as it fills you with burning pleasure."
    end
  
    if parts.include?('penis')
      scenes << "You offer your cock to the #{monster_name}, moaning as its supernatural mouth takes you deep."
      scenes << "You thrust into the demon's hot mouth, your hands tangling in its hair as it pleasures you."
      scenes << "You guide the #{monster_name}'s tendrils to your balls, groaning as they tease and squeeze."
    end
  
    if parts.include?('anus')
      scenes << "You present yourself to the #{monster_name}, inviting its burning cock into your eager hole."
      scenes << "You push back against the demon's thrusts, your body welcoming its heat and roughness."
      scenes << "You reach back to spread your cheeks, offering yourself completely to the #{monster_name}."
    end
  
    if parts.include?('breasts')
      scenes << "You offer your breasts to the #{monster_name}, gasping as its hot mouth marks your flesh."
      scenes << "You press your tits against the demon's face, encouraging it to leave its mark on you."
      scenes << "You trace arcane symbols on your breasts, inviting the #{monster_name} to complete the ritual."
    end
  
    scenes
  end
  
  def generate_slime_willing(parts, monster_name)
    scenes = []
  
    if parts.include?('vagina')
      scenes << "You lie back, spreading your legs as the #{monster_name} flows toward you with eagerness."
      scenes << "You welcome the slime into your cunt, moaning as it fills you completely with its cool form."
      scenes << "You reach down to guide the #{monster_name}'s tendrils, directing them to your most sensitive spots."
      scenes << "You wrap your legs around the slime, pulling it deeper as it pulses with pleasure inside you."
    end
  
    if parts.include?('penis')
      scenes << "You present your cock to the #{monster_name}, groaning as its cool body engulfs your length."
      scenes << "You thrust into the slime's forming sheath, your hands pressing against its gelatinous form."
      scenes << "You guide the #{monster_name}'s tendrils to your balls, gasping as they tease and squeeze."
    end
  
    if parts.include?('anus')
      scenes << "You position yourself for the #{monster_name}, inviting its cool form into your eager ass."
      scenes << "You push back against the slime's tendrils, your body welcoming its unusual texture."
      scenes << "You reach back to spread your cheeks, offering yourself completely to the #{monster_name}."
    end
  
    if parts.include?('breasts')
      scenes << "You press your breasts into the #{monster_name}, moaning as it molds to your form."
      scenes << "You guide the slime's tendrils to your nipples, gasping as they tease and suck."
      scenes << "You bounce your tits in the slime, giggling as it forms around them with each movement."
    end
  
    scenes
  end
  
  def generate_undead_willing(parts, monster_name)
    scenes = []
  
    if parts.include?('vagina')
      scenes << "You lie back, spreading your legs as the #{monster_name} approaches with cold hunger."
      scenes << "You welcome the undead's cold member, gasping as it fills you with its chilling touch."
      scenes << "You pull the #{monster_name} closer, your body responding to its unnatural coldness."
      scenes << "You guide the zombie's rigid cock to your entrance, shivering as it enters you."
    end
  
    if parts.include?('penis')
      scenes << "You offer your cock to the #{monster_name}, moaning as its cold mouth takes you deep."
      scenes << "You thrust into the ghost's ethereal mouth, your hands passing through its form as it pleasures you."
      scenes << "You guide the #{monster_name}'s bony fingers to your shaft, groaning at their unusual touch."
    end
  
    if parts.include?('anus')
      scenes << "You present yourself to the #{monster_name}, inviting its cold member into your eager hole."
      scenes << "You push back against the zombie's thrusts, your body welcoming its unnatural coldness."
      scenes << "You reach back to spread your cheeks, offering yourself completely to the #{monster_name}."
    end
  
    if parts.include?('breasts')
      scenes << "You offer your breasts to the #{monster_name}, gasping as its cold hands cup your flesh."
      scenes << "You press your tits against the zombie's face, encouraging it to mark you with its cold touch."
      scenes << "You trace patterns on your nipples, inviting the ghost to touch and tease."
    end
  
    scenes
  end
  
  def generate_plant_willing(parts, monster_name)
    scenes = []
  
    if parts.include?('vagina')
      scenes << "You lie back, spreading your legs as the #{monster_name}'s vines approach with eagerness."
      scenes << "You welcome the plant's smooth tendril, moaning as it slides into your wet cunt."
      scenes << "You guide the #{monster_name}'s tendrils to your most sensitive spots, encouraging their exploration."
      scenes << "You wrap your legs around the plant, pulling its tendrils deeper as they pulse with nectar."
    end
  
    if parts.include?('penis')
      scenes << "You present your cock to the #{monster_name}, groaning as its flowering sheath engulfs you."
      scenes << "You thrust into the plant's soft opening, your hands guiding its vines to tease your balls."
      scenes << "You guide the #{monster_name}'s tendrils to your shaft, gasping as their texture drives you wild."
    end
  
    if parts.include?('anus')
      scenes << "You position yourself for the #{monster_name}, inviting its smooth vine into your eager hole."
      scenes << "You push back against the plant's thrusts, your body welcoming its natural texture."
      scenes << "You reach back to spread your cheeks, offering yourself completely to the #{monster_name}."
    end
  
    if parts.include?('breasts')
      scenes << "You offer your breasts to the #{monster_name}, moaning as its vines wrap around your flesh."
      scenes << "You press your tits against the plant's flowers, gasping as they suck at your nipples."
      scenes << "You trace patterns on your skin, inviting the #{monster_name}'s vines to follow and tease."
    end
  
    scenes
  end
  
  def generate_mimic_willing(parts, monster_name)
    scenes = []
  
    if parts.include?('vagina')
      scenes << "You lie back, spreading your legs as the #{monster_name} reveals its true form with eagerness."
      scenes << "You welcome the mimic's appendage, moaning as it slides into your wet cunt."
      scenes << "You guide the #{monster_name}'s tendrils to your most sensitive spots, encouraging their exploration."
      scenes << "You wrap your legs around the mimic, pulling it deeper as its interior pulses with pleasure."
    end
  
    if parts.include?('penis')
      scenes << "You present your cock to the #{monster_name}, groaning as its opening transforms to welcome you."
      scenes << "You thrust into the mimic's wet interior, your hands guiding its tendrils to tease your balls."
      scenes << "You guide the #{monster_name}'s appendages to your shaft, gasping as their texture changes to please you."
    end
  
    if parts.include?('anus')
      scenes << "You position yourself for the #{monster_name}, inviting its appendage into your eager hole."
      scenes << "You push back against the mimic's thrusts, your body welcoming its changing texture."
      scenes << "You reach back to spread your cheeks, offering yourself completely to the #{monster_name}."
    end
  
    if parts.include?('breasts')
      scenes << "You offer your breasts to the #{monster_name}, moaning as its tendrils wrap around your flesh."
      scenes << "You press your tits against the mimic's opening, gasping as it transforms to please you."
      scenes << "You bounce your breasts in the #{monster_name}'s face, giggling as it transforms to match your desires."
    end
  
    scenes
  end
  
  def generic_willing(monster_name)
    [
      "You willingly submit to the #{monster_name}, your body responding with anticipation and desire.",
      "You offer yourself to the #{monster_name}, eager to experience the pleasure it can provide.",
      "You guide the #{monster_name}'s hands to your body, encouraging its exploration of your flesh.",
      "You press against the #{monster_name}, your movements communicating your desire and willingness.",
      "You whisper words of encouragement to the #{monster_name}, inviting it to take what it wants from you."
    ]
  end
end
end
