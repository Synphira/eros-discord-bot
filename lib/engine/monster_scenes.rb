# frozen_string_literal: true

module Engine
  # NSFW Submit scenes — per monster type, filtered by the player's body_parts.
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

      scenes = generic_scenes(monster_name) if scenes.empty?
      scenes.sample
    end

    # Combat-turn assault text — more forceful than Submit scenes.
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

      scenes = generic_assault(monster_name) if scenes.empty?
      scenes.sample
    end

    def generate_beast_assault(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The beast forces its knotting cock into your vagina, swelling inside you as it prepares to breed."
        scenes << "The #{monster_name} mounts you from behind, its rough paws gripping your hips as it pounds into your wet cunt."
        scenes << "The animal forces you onto your back, its heavy body pinning you as it thrusts its thick member deep into your womb."
      end

      if parts.include?('penis')
        scenes << "The beast's rough tongue laps at your cock, its textured surface bringing you to painful arousal."
        scenes << "The #{monster_name} forces its muzzle over your dick, its teeth grazing your shaft as it sucks you dry."
        scenes << "The animal's claws wrap around your balls, squeezing painfully as it strokes you to completion."
      end

      if parts.include?('anus')
        scenes << "The #{monster_name} forces its thick knot into your tight ass, stretching you painfully as it breeds you."
        scenes << "The beast mounts you from behind, its weight pinning you as it slams its cock into your violated hole."
        scenes << "The animal's claws dig into your back as it pounds your ass, its hot breath panting against your neck."
      end

      if parts.include?('breasts')
        scenes << "The beast's rough tongue laps at your nipples, its teeth grazing your sensitive flesh."
        scenes << "The #{monster_name} bites your breasts, its sharp teeth leaving marks as it mauls your chest."
        scenes << "The animal's paws squeeze your tits, its claws pricking your skin as it uses you for its pleasure."
      end

      scenes
    end

    def generate_demon_assault(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The demon's burning cock forces its way into your cunt, its infernal heat searing your insides."
        scenes << "The #{monster_name} summons shadowy tendrils that violate both your holes, stretching you impossibly wide."
        scenes << "The demon's barbed member rakes your inner walls as it thrusts, each movement bringing new agony and pleasure."
      end

      if parts.include?('penis')
        scenes << "The demon's mouth engulfs your cock, its impossibly deep throat taking you to the hilt."
        scenes << "The #{monster_name} wraps its hot tail around your dick, the scales rubbing you raw as it milks you."
        scenes << "Shadowy hands grasp your balls, squeezing painfully as the demon drains your seed."
      end

      if parts.include?('anus')
        scenes << "The demon's burning hot cock forces its way into your ass, stretching you painfully as it claims you."
        scenes << "The #{monster_name}'s barbed tail rakes your insides as it thrusts, each movement tearing you further."
        scenes << "Shadowy tendrils penetrate your ass, filling you completely as they pulse with dark energy."
      end

      if parts.include?('breasts')
        scenes << "The demon's claws rake across your breasts, leaving glowing marks as it claims your flesh."
        scenes << "The #{monster_name}'s mouth closes around your nipple, its sharp teeth drawing blood as it feeds."
        scenes << "Shadowy hands squeeze your tits painfully, the demonic energy burning your skin."
      end

      scenes
    end

    def generate_slime_assault(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The slime forces its way into your womb, its acidic body burning your insides as it fills you."
        scenes << "The #{monster_name} expands inside your cunt, stretching you painfully as it pulses with pleasure."
        scenes << "The slime's tentacles wrap around your cervix, pulling painfully as it tries to enter deeper."
      end

      if parts.include?('penis')
        scenes << "The slime engulfs your cock, its acidic body burning your flesh as it dissolves you."
        scenes << "The #{monster_name} forces its way into your urethra, expanding painfully as it fills your shaft."
        scenes << "The slime's tentacles wrap around your balls, squeezing painfully as they dissolve your skin."
      end

      if parts.include?('anus')
        scenes << "The slime forces its way into your ass, expanding painfully as it fills your intestines."
        scenes << "The #{monster_name}'s acidic body burns your insides as it thrusts, dissolving your flesh from within."
        scenes << "The slime's tentacles expand in your colon, stretching you painfully as they pulse."
      end

      if parts.include?('breasts')
        scenes << "The slime covers your breasts, its acidic body burning your skin as it dissolves your flesh."
        scenes << "The #{monster_name}'s tentacles wrap around your nipples, pulling painfully as they dissolve."
        scenes << "The slime expands around your tits, crushing them as it burns through your skin."
      end

      scenes
    end

    def generate_undead_assault(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The undead's frozen cock forces its way into your cunt, the cold burning your insides."
        scenes << "The #{monster_name}'s bony fingers violate your womb, scraping your insides as it thrusts."
        scenes << "The zombie's rotting member fills you, its diseased flesh infecting your body as it pounds."
      end

      if parts.include?('penis')
        scenes << "The undead's cold mouth engulfs your cock, its teeth scraping your flesh as it sucks."
        scenes << "The #{monster_name}'s bony fingers wrap around your shaft, the sharp edges cutting your skin."
        scenes << "The ghost's ethereal mouth sucks your dick, the cold seeping into your very soul."
      end

      if parts.include?('anus')
        scenes << "The undead's frozen cock forces its way into your ass, the cold burning as it tears you."
        scenes << "The #{monster_name}'s bony fingers scrape your insides as it thrusts, each movement tearing you further."
        scenes << "The zombie's rotting member pounds your ass, the diseased flesh infecting your body."
      end

      if parts.include?('breasts')
        scenes << "The undead's cold hands grip your breasts, the freezing touch burning your skin."
        scenes << "The #{monster_name}'s bony fingers scrape your nipples, drawing no blood but causing intense pain."
        scenes << "The ghost's ethereal hands pass through your tits, the cold seeping into your very bones."
      end

      scenes
    end

    def generate_plant_assault(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The plant's thorny vine forces its way into your cunt, the thorns tearing your flesh."
        scenes << "The #{monster_name}'s pollen-coated tendrils violate your womb, the allergens burning your insides."
        scenes << "The plant's stinger injects you with aphrodisiacs as it thrusts, your body betraying you as it fills you."
      end

      if parts.include?('penis')
        scenes << "The plant's carnivorous flower closes around your cock, the digestive juices burning your flesh."
        scenes << "The #{monster_name}'s thorny vine wraps around your shaft, the thorns cutting into your skin."
        scenes << "The plant's pollen fills your urethra, burning as it travels deeper into your body."
      end

      if parts.include?('anus')
        scenes << "The plant's thorny vine forces its way into your ass, the thorns tearing your insides."
        scenes << "The #{monster_name}'s stinger injects you with toxins as it thrusts, your body convulsing in pain."
        scenes << "The plant's roots force their way into your colon, expanding painfully as they grow."
      end

      if parts.include?('breasts')
        scenes << "The plant's thorny vines wrap around your tits, the thorns cutting into your flesh."
        scenes << "The #{monster_name}'s carnivorous flowers bite your nipples, the digestive juices burning your skin."
        scenes << "The plant's pollen covers your breasts, the allergens causing them to swell painfully."
      end

      scenes
    end

    def generate_mimic_assault(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The mimic's false teeth bite down on your labia as its tongue forces its way into your cunt."
        scenes << "The #{monster_name}'s wooden texture transforms into rough flesh as it pounds into your womb."
        scenes << "The mimic's interior reveals writhing tendrils that violate your cervix, pulling painfully as they thrust."
      end

      if parts.include?('penis')
        scenes << "The mimic's false teeth bite down on your cock, the sharp edges cutting into your flesh."
        scenes << "The #{monster_name}'s wooden interior transforms into a tight, sucking orifice as it engulfs your shaft."
        scenes << "The mimic's tongue wraps around your balls, squeezing painfully as it tries to pull them off."
      end

      if parts.include?('anus')
        scenes << "The mimic's false teeth bite down on your ass cheeks as its tongue forces its way into your hole."
        scenes << "The #{monster_name}'s wooden texture transforms into rough flesh as it pounds your ass."
        scenes << "The mimic's interior reveals writhing tendrils that violate your colon, expanding painfully as they thrust."
      end

      if parts.include?('breasts')
        scenes << "The mimic's false teeth bite down on your nipples, the sharp edges cutting into your flesh."
        scenes << "The #{monster_name}'s wooden texture transforms into rough hands as it mauls your tits."
        scenes << "The mimic's interior reveals writhing tendrils that wrap around your breasts, squeezing painfully."
      end

      scenes
    end

    def generic_assault(monster_name)
      [
        "The #{monster_name} forces you to the ground, its weight pinning you as it violates your body.",
        "The #{monster_name}'s rough hands grip your hips as it thrusts into you, using you for its pleasure.",
        "The #{monster_name} pins your wrists above your head as it assaults you, taking what it wants.",
        "The #{monster_name} forces its way into your body, each movement bringing pain and unwanted pleasure.",
        "The #{monster_name} violates you relentlessly, your body betraying you as it responds to the assault."
      ]
    end

    def generate_beast_scene(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The #{monster_name} mounts you from behind, its rough fur rubbing against your skin as it thrusts into your vagina with primal force."
        scenes << "The beast forces you onto all fours, entering your wet vagina with a growl of satisfaction."
      end

      if parts.include?('penis')
        scenes << "The #{monster_name} pins you down, its rough tongue wrapping around your penis as it tastes your arousal."
        scenes << "The beast's clawed hands grip your hips as it strokes your penis, bringing you to the edge of pleasure."
      end

      if parts.include?('anus')
        scenes << "The #{monster_name} forces its thick member into your tight anus, making you cry out in pain and pleasure."
        scenes << "The beast flips you over, spreading your cheeks to expose your anus before thrusting deep inside."
      end

      if parts.include?('breasts')
        scenes << "The #{monster_name} licks and nips at your breasts, its rough tongue sending shivers through your body."
        scenes << "The beast's claws trace patterns on your sensitive breasts as it prepares to mount you."
      end

      scenes
    end

    def generate_demon_scene(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The #{monster_name} whispers dark words as it enters your vagina, its unnatural heat spreading through you."
        scenes << "The demon's tail wraps around your thigh as it thrusts into your vagina, stealing your resistance with each movement."
      end

      if parts.include?('penis')
        scenes << "The #{monster_name} summons magical tendrils that wrap around your penis, stroking it with infernal skill."
        scenes << "The demon's hot mouth engulfs your penis, its tongue swirling in impossible patterns as it drains your will."
      end

      if parts.include?('anus')
        scenes << "The #{monster_name} forces its burning hot member into your anus, marking you as its property with each thrust."
        scenes << "The demon's shadowy tendrils penetrate your anus, filling you with dark energy and pleasure."
      end

      if parts.include?('breasts')
        scenes << "The #{monster_name} traces arcane symbols on your breasts, causing them to heat up with unnatural desire."
        scenes << "The demon's mouth closes around your nipple, its teeth gently scraping as it drains your resistance."
      end

      scenes
    end

    def generate_slime_scene(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The #{monster_name} flows into your vagina, its cool gelatinous form filling you completely and pulsing with pleasure."
        scenes << "The slime molds itself to your inner walls, stimulating every sensitive spot in your vagina as it writhes inside you."
      end

      if parts.include?('penis')
        scenes << "The #{monster_name} engulfs your penis in its cool body, contracting around it with rhythmic pulses."
        scenes << "The slime forms a tight sheath around your penis, its texture sending waves of pleasure through you."
      end

      if parts.include?('anus')
        scenes << "The #{monster_name} forces its way into your anus, its cool form a strange contrast to the heat building inside you."
        scenes << "The slime stretches your anus as it enters, then fills you completely with its pulsating body."
      end

      if parts.include?('breasts')
        scenes << "The #{monster_name} covers your breasts with its cool body, forming tendrils that tease your nipples."
        scenes << "The slime molds to your breasts, its surface vibrating slightly as it stimulates your sensitive flesh."
      end

      scenes
    end

    def generate_undead_scene(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The #{monster_name} enters your vagina with its cold member, the chill contrasting with the heat of your arousal."
        scenes << "The undead creature's phantasmal form penetrates your vagina, its cold touch sending shivers through your body."
      end

      if parts.include?('penis')
        scenes << "The #{monster_name} wraps its cold hands around your penis, stroking you with unnerving precision."
        scenes << "The ghost's mouth engulfs your penis, its cold touch somehow more arousing than warmth."
      end

      if parts.include?('anus')
        scenes << "The #{monster_name} forces its cold member into your anus, the undead flesh sending chills through you."
        scenes << "The specter phases through your clothes to enter your anus, its cold form filling you completely."
      end

      if parts.include?('breasts')
        scenes << "The #{monster_name} touches your breasts with its icy hands, the cold making your nipples stand erect."
        scenes << "The ghost's fingers trace patterns on your breasts, their touch cold yet somehow arousing."
      end

      scenes
    end

    def generate_mimic_scene(parts, monster_name)
      scenes = []
    
      if parts.include?('vagina')
        scenes << "The #{monster_name} reveals its true form, its tongue-like appendage forcing its way into your vagina."
        scenes << "The mimic's chest opens to reveal a writhing mass of tendrils that immediately plunge into your vagina."
      end
    
      if parts.include?('penis')
        scenes << "The #{monster_name} transforms, revealing a moist opening that engulfs your penis, sucking hungrily."
        scenes << "The mimic's false bottom gives way to a pulsating orifice that strokes your penis with its inner walls."
      end
    
      if parts.include?('anus')
        scenes << "The #{monster_name}'s lid opens, revealing a phallic appendage that forces its way into your anus."
        scenes << "The mimic reveals itself, its wooden texture softening into flesh as it penetrates your anus."
      end
    
      if parts.include?('breasts')
        scenes << "The #{monster_name}'s lid opens, revealing tendrils that wrap around your breasts, squeezing and teasing."
        scenes << "The mimic's interior reveals soft, wet appendages that attach to your nipples, sucking insistently."
      end
    
      scenes
    end

    def generate_plant_scene(parts, monster_name)
      scenes = []

      if parts.include?('vagina')
        scenes << "The #{monster_name} forces its thick vines into your vagina, the rough bark stimulating your inner walls."
        scenes << "The plant monster's pollen fills you with heat as it enters your vagina with its flower-tipped tendril."
      end

      if parts.include?('penis')
        scenes << "The #{monster_name} wraps its vines around your penis, the rough texture stimulating you to full hardness."
        scenes << "The plant's pollen-coated tendrils stroke your penis, filling you with unnatural desire."
      end

      if parts.include?('anus')
        scenes << "The #{monster_name} forces its thorny vine into your anus, the pain mixing with intense pleasure."
        scenes << "The plant monster's root-like appendage penetrates your anus, filling you completely as it deposits its seed."
      end

      if parts.include?('breasts')
        scenes << "The #{monster_name} wraps its vines around your breasts, the rough texture stimulating your nipples."
        scenes << "The plant's flower closes around your nipple, sucking gently as it releases more pollen."
      end

      scenes
    end

    def generic_scenes(monster_name)
      [
        "The #{monster_name} pins you down, its hot breath against your skin...",
        "The #{monster_name} whispers dirty things in your ear as it touches you..."
      ]
    end
  end
end
