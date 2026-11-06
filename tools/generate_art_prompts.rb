# frozen_string_literal: true

require 'fileutils'

# Writes pixel-sprite NovelAI prompts for encounter monsters, gear, and events.
# Run from the repo root: ruby tools/generate_art_prompts.rb
#
# Named characters, bosses, and relics stay in docs/art_reference.md.

require_relative '../lib/engine/monster_types'
require_relative '../lib/engine/shop'
require_relative '../lib/engine/treasure'
require_relative '../lib/engine/fetish_events'
require_relative '../lib/engine/residents'
require_relative '../lib/engine/wardrobe'

PIXEL = '{{{pixel art}}}, {{lowres}}, {{dot art}}, retro game sprite, hard pixel edges, chunky pixels, flat colors, limited palette, dithering, no anti-aliasing,'
SHADE = 'flat shadow, two-tone shading, solid dark background,'
UC = '{{highres}}, {{absurdres}}, {{smooth shading}}, {{soft shading}}, {{gradient}}, {{airbrush}}, {{glossy}}, {{bloom}}, anime, illustration, painterly, cel shading, sparkles, particles, haze, depth of field, bokeh, soft light, official art, photorealistic, realistic, photoreal, 3d, cgi, loli, shota, child, underage, young, kid, toddler, little girl, blood, gore, wound, injury, rotting, decay, cub, watermark, signature, username, bad anatomy, extra fingers, blurry, anti-aliasing'

ROOT = File.expand_path('..', __dir__)
OUT = File.join(ROOT, 'docs', 'art')

FEMALE = %w[
  Succubus Demoness Siren Night\ Hag Marionette\ Mistress Lamia Harpy HuCow
  Gorgon\ Matron Alraune Dryad Sap\ Dryad Silkweaver Tomb\ Widow Banshee
  Balloon\ Mistress Pollen\ Sprite Mandrake
].freeze

QUADRUPED = %w[
  Wolf Bear Hellhound Wildcat Wild\ Dog Basilisk Dragon Giant\ Spider Giant\ Bee Giant\ Moth
].freeze

# Encounter monsters whose look is already locked on a boss or relic sheet.
ALIAS = {
  'Pale Bride' => 'The relic Pale Bride. Use the empty-lingerie prompt in docs/art_reference.md. Do not draw a body inside the gown.',
  'Dragon' => 'A common tower dragon, on all fours. The humanoid coin-dragon is the Hoardheart Dragon in docs/art_reference.md.',
  'Broodmother' => 'A spider matron. The chest-and-woman boss is the Mimic Broodmother in docs/art_reference.md.'
}.freeze

LOOK = {
  'Wolf' => '1boy, adult, beast, wolf, feral, full body, {{standing on all fours}}, lean shaggy grey-black wolf, pony sized, yellow eyes, drooling grin, coarse mane, red tapered canine cock, dark furry sheath, fat knot, heavy balls',
  'Bear' => '1boy, adult, beast, bear, feral, full body, {{standing on all fours}}, hulking brown bear, thick paws, dense belly fur, thick blunt cock, big furry balls, warm predator eyes',
  'Minotaur' => '1boy, adult, mature male, minotaur, full body, bull head, 8 feet tall, massive chest, dark brown hide, gold nose ring, failing loincloth, huge flared bull cock, heavy balls',
  'Gargoyle' => '1boy, adult, gargoyle, full body, cracked granite skin, glowing ember eyes, stone bat wings, crouched, smooth grey stone cock, knot',
  'Silkweaver' => '1girl, adult, mature female, spider woman, full body, pale chitin, extra arms, white silk threads, glossy abdomen, fangs, bare breasts, ridged ovipositor',
  'Giant Spider' => '1other, adult, giant spider, full body, many legs, glossy black chitin, dripping fangs, large abdomen, ridged ovipositor under the belly',
  'Giant Moth' => '1other, adult, giant moth, full body, dusty patterned wings, feathery antennae, fuzzy thorax, ridged insect cock',
  'Giant Bee' => '1other, adult, giant bee, full body, gold and black stripes, translucent wings, cat sized or larger, stinger, ridged insect cock',
  'Broodmother' => '1girl, adult, mature female, spider matron, full body, huge glossy abdomen, many legs, extra arms, fangs, bare breasts, ridged ovipositor, egg slick',
  'Lamia' => '1girl, adult, mature female, lamia, full body, bare human torso, large breasts, serpent tail, gold scales, forked tongue, thick scaled cock',
  'Naga' => '1boy, adult, mature male, naga, full body, hooded cobra head, scaled muscular torso, coils, thick scaled cock, heavy balls',
  'Centaur' => '1boy, adult, mature male, centaur, full body, human torso, horse body, huge flared equine cock, heavy balls',
  'Harpy' => '1girl, adult, mature female, harpy, full body, bare breasts, feathered wings, talons, sharp smile, feathered groin, plump pussy',
  'Satyr' => '1boy, adult, mature male, satyr, full body, goat legs, curved horns, grinning, huge cock, heavy balls',
  'Ogre' => '1boy, adult, mature male, ogre, full body, hulking, grey-green hide, gut, huge hands, massive thick cock, heavy balls',
  'Troll' => '1boy, adult, mature male, troll, full body, hulking, warty grey-green hide, long arms, huge cock, heavy balls',
  'Goblin' => '1boy, adult, mature male, goblin, full body, short wiry adult, green skin, long pointed ears, sharp grin, oversized cock for his frame',
  'Orc' => '1boy, adult, mature male, orc, full body, green skin, tusks, heavy muscle, huge cock, heavy balls',
  'Kitsune' => '1girl, adult, mature female, kitsune, full body, fox ears, many fox tails, bare, medium breasts, plump pussy, sleek',
  'Dragon' => '1boy, adult, beast, dragon, feral, full body, {{standing on all fours}}, four legs, wings, horns, gold-brown scales, thick scaled cock, heavy balls',
  'HuCow' => '1girl, adult, mature female, hucow, full body, cow horns, cow ears, bell collar, huge lactating breasts, dripping milk, wide hips, plump pussy, tail',
  'Wildcat' => '1boy, adult, beast, wildcat, feral, full body, {{standing on all fours}}, tawny big cat, fangs, barbed cock, knot',
  'Wild Dog' => '1boy, adult, beast, wild dog, feral, full body, {{standing on all fours}}, lean brindle dog, red canine cock, knot, heavy balls',
  'Basilisk' => '1boy, adult, beast, basilisk, feral, full body, {{standing on all fours}}, crested serpent-lizard, stone-pale eyes, scales, thick scaled cock',
  'Gorgon Matron' => '1girl, adult, mature female, gorgon, full body, snake hair, stern beautiful face, scaled hips, bare breasts, thick scaled cock',
  'Imp' => '1boy, adult, mature male, imp, full body, small wiry adult, red skin, stubby horns, bat wings, spade tail, adult grin, ridged cock oversized for his frame',
  'Succubus' => '1girl, adult, mature female, succubus, full body, long curling horns, bat wings, heart-tipped tail, glowing pink eyes, jewellery only, large breasts, plump pussy, ridged cock',
  'Incubus' => '1boy, adult, mature male, incubus, full body, swept-back horns, slit pupils, long tail, sculpted, nude, long ridged red cock, always erect',
  'Hellhound' => '1boy, adult, beast, hellhound, feral, full body, {{standing on all fours}}, black fur, ember cracks in the coat, burning eyes, glowing ridged canine cock, knot',
  'Demoness' => '1girl, adult, mature female, demoness, full body, crimson skin, long horns, bat wings, spade tail, large breasts, plump pussy, ridged cock',
  'Oni' => '1boy, adult, mature male, oni, full body, red skin, huge horns, fangs, iron club, massive ridged cock, heavy balls',
  'Siren' => '1girl, adult, mature female, siren, full body, beautiful, wet, finned tail, bare breasts, scaled hips, plump pussy',
  'Fae Trickster' => '1girl, adult, mature female, fae, full body, slender adult, pointed ears, translucent wings, smirk, small breasts, plump pussy',
  'Cambion' => '1boy, adult, mature male, cambion, full body, mostly human, small horns, thin tail, flushed skin, ridged cock',
  'Rakshasa' => '1boy, adult, mature male, rakshasa, full body, tiger stripes, fangs, reversed hands, muscular, huge cock',
  'Ifrit' => '1boy, adult, mature male, ifrit, full body, bronze skin, flame hair, horns, heat, massive ridged cock',
  'Djinn' => '1girl, adult, mature female, djinn, full body, gold jewellery, bare breasts, smoke from the waist down, sultry',
  'Night Hag' => '1girl, adult, mature female, night hag, full body, severe adult face, blue-grey skin, long claws, long breasts, nude',
  'Pit Fiend' => '1boy, adult, mature male, pit fiend, full body, huge, red scales, vast wings, crown horns, massive ridged cock',
  'Chain Devil' => '1boy, adult, mature male, chain devil, full body, pale, wrapped in living chains, hooks, bound cock',
  'Velvet Devil' => '1girl, adult, mature female, velvet devil, full body, black velvet skin, elegant horns, large soft breasts, plump pussy, ridged cock',
  'Sin Eater' => '1girl, adult, mature female, sin eater, full body, too-wide mouth, stained lips, soft belly, kneeling, hungry, bare breasts',
  'Dream Eater' => '1girl, adult, mature female, dream eater, full body, pale, eyes closed, smoke hair, tendrils, bare, serene',
  'Carnal Fiend' => '1girl, adult, mature female, carnal fiend, full body, flushed, dripping, huge breasts, wide hips, thick ridged cock, heavy balls',
  'Ember Fiend' => '1boy, adult, mature male, ember fiend, full body, charcoal skin, glowing ember cracks, horns, heat, ridged cock',
  'Marionette Mistress' => '1girl, adult, mature female, marionette, full body, beautiful adult, doll joints, puppet strings from her fingers, corset open, bare breasts',
  'Green Slime' => '1girl, adult, slime girl, full body, translucent lime slime, humanoid top, bubbles, dark core, cock-shaped pseudopod',
  'Purple Slime' => '1girl, adult, slime girl, full body, glossy violet slime, curvy, large breasts, wide hips, slick hole and pseudopod cock',
  'Jelly Cube' => '1other, jelly cube, full body, clear wobbling cube, coins and a boot inside, tight wet hole opening on one face',
  'Gelatinous Mass' => '1other, gelatinous mass, full body, huge amber-pink mound, dozens of tendrils, cock-head tips, suckers',
  'Amber Slime' => '1girl, adult, slime girl, full body, translucent amber slime, warm, humanoid, honey-thick, pseudopod cock',
  'Cream Slime' => '1girl, adult, slime girl, full body, opaque cream slime, soft curves, large breasts, dripping, pseudopod cock',
  'Crystal Slime' => '1girl, adult, slime girl, full body, clear crystal slime, faceted highlights, humanoid, pseudopod cock',
  'Rubber Slime' => '1girl, adult, slime girl, full body, glossy black rubber slime, tight shiny body, large breasts, pseudopod cock',
  'Jellyfish' => '1girl, adult, jellyfish girl, full body, translucent bell, trailing wet tentacles, bare torso, suckers',
  'Rose Slime' => '1girl, adult, slime girl, full body, pink rose slime, petals suspended inside, curvy, pseudopod cock',
  'Honey Slime' => '1girl, adult, slime girl, full body, golden honey slime, slow drip, sweet, large breasts, pseudopod cock',
  'Milk Slime' => '1girl, adult, slime girl, full body, white milk slime, heavy breasts, dripping milk, pseudopod cock',
  'Oil Slime' => '1girl, adult, slime girl, full body, black oil slime, rainbow sheen as flat color bands, sleek, pseudopod cock',
  'Bubble Slime' => '1girl, adult, slime girl, full body, clear slime full of bubbles, soft body, pseudopod cock',
  'Syrup Slime' => '1girl, adult, slime girl, full body, dark syrup slime, slow thick drips, heavy curves, pseudopod cock',
  'Pudding Slime' => '1girl, adult, slime girl, full body, brown pudding slime, wobbling breasts, soft, pseudopod cock',
  'Mercury Slime' => '1girl, adult, slime girl, full body, silver mercury slime, mirror-flat color, sleek, pseudopod cock',
  'Glow Slime' => '1girl, adult, slime girl, full body, pale slime, flat cyan glow, humanoid, pseudopod cock',
  'Tar Slime' => '1other, tar slime, full body, black sticky tar mound, bubbles, thick tendrils, cock-head tips',
  'Foam Slime' => '1girl, adult, slime girl, full body, white foam slime, soft piles, curvy silhouette, pseudopod cock',
  'Champagne Slime' => '1girl, adult, slime girl, full body, pale gold slime, rising bubbles, elegant curves, pseudopod cock',
  'Zombie' => '1boy, adult, mature male, zombie, full body, grey-green intact skin, glassy glowing eyes, tattered clothes open, shambling, pale cold stiff cock',
  'Skeleton' => '1boy, adult, skeleton, full body, clean bleached bones, blue ghost-fire in the joints, glowing eye sockets, translucent blue spectral cock, no balls',
  'Ghost' => '1girl, adult, ghost, full body, translucent pale blue, trailing wisps, long drifting hair, glowing ectoplasm pussy',
  'Wraith' => '1boy, adult, wraith, full body, tall hooded shadow, tattered cloak, hollow face, long pale hands, shadowy cold cock',
  'Vampire' => '1boy, adult, mature male, vampire, full body, pale, elegant, red eyes, fangs, open black shirt, cold pale cock',
  'Lich' => '1boy, adult, lich, full body, deep hood, blue flame eyes, tattered robes parted, skeletal hands, spectral blue cock, no balls',
  'Banshee' => '1girl, adult, mature female, banshee, full body, pale, mouth open in a wail, long white hair, tattered gown falling off, bare breasts',
  'Ghoul' => '1boy, adult, mature male, ghoul, full body, grey intact skin, hungry eyes, hunched, long fingers, pale cold cock',
  'Mummy' => '1boy, adult, mature male, mummy, full body, linen wraps falling open, intact desiccated skin, glowing eyes, wrapped cock exposed',
  'Revenant' => '1boy, adult, mature male, revenant, full body, armored corpse, intact pale skin, glowing eyes, torn plate, cold cock',
  'Specter' => '1girl, adult, specter, full body, faint translucent woman, sheet of light, sad beautiful face, glowing pussy',
  'Wight' => '1boy, adult, mature male, wight, full body, corpse-pale, burning eyes, grave clothes open, cold cock, grave dirt as flat color',
  'Poltergeist' => '1other, poltergeist, full body, invisible shape shown by floating torn clothes and a glowing cock of ectoplasm',
  'Dullahan' => '1boy, adult, dullahan, full body, headless armored rider, head carried under one arm, glowing eyes, pale cock',
  'Jiangshi' => '1boy, adult, jiangshi, full body, stiff hopping corpse, paper talisman on the brow, arms out, Qing robe open, pale cock',
  'Headless Knight' => '1boy, adult, headless knight, full body, empty helm, polished plate open at the groin, spectral cock',
  'Tomb Widow' => '1girl, adult, mature female, tomb widow, full body, black mourning lace, pale intact skin, veil, bare breasts, plump pussy',
  'Pale Bride' => '1other, empty bridal lingerie, full body, {{no person}}, {{no skin}}, sheer ivory lace, hollow cups, empty veil, empty opera gloves holding a bouquet',
  'Crypt Keeper' => '1boy, adult, mature male, crypt keeper, full body, pale clerk of the dead, ring of keys, robe open, cold cock, lantern',
  'Bone Dancer' => '1girl, adult, bone dancer, full body, articulated skeleton in a dance pose, blue ghost-fire, spectral pussy, no balls',
  'Tentacle Vine' => '1other, tentacle vine, full body, thick green vines, pink tips, nectar beads, ridged stalks',
  'Alraune' => '1girl, adult, mature female, alraune, full body, growing from a giant flower, green skin, petal hair, large breasts, nectar dripping pussy, vines',
  'Man-Eating Flower' => '1other, man-eating flower, full body, giant pitcher bloom, wet pink throat, fleshy petals, sucking mouth',
  'Living Ivy' => '1other, living ivy, full body, creeping ivy over a statue, glittering pollen as flat specks, fine tendrils',
  'Dryad' => '1girl, adult, mature female, dryad, full body, bark-brown skin, long green leaf hair, flowers, large breasts, vine drapery, barefoot',
  'Mycelian' => '1girl, adult, mature female, mycelian, full body, mushroom cap, pale spotted skin, spores, soft body, ridged mushroom cock',
  'Black Orchid' => '1girl, adult, mature female, black orchid, full body, black petals for hair, dark purple skin, elegant, bare breasts, nectar',
  'Treant' => '1boy, adult, treant, full body, walking tree, face in the bark, branch arms, thick ridged root cock',
  'Mandrake' => '1girl, adult, mature female, mandrake, full body, small adult plant woman, root legs, leafy hair, scream, bare, plump pussy',
  'Corpse Flower' => '1other, corpse flower, full body, huge pale bloom, dark throat, sweet rot suggested by color only, intact petals, no gore',
  'Blood Rose' => '1girl, adult, mature female, blood rose, full body, red rose petals, thorn vines, crimson skin, bare breasts, nectar like wine',
  'Venus Mantrap' => '1other, venus mantrap, full body, giant toothed flower, pink wet interior, green jaws, no blood',
  'Pitcher Plant' => '1other, pitcher plant, full body, tall green pitcher, wet pink mouth, nectar pool inside',
  'Sundew' => '1other, sundew, full body, red sticky tentacles with dew drops, low plant, glistening',
  'Moonflower' => '1girl, adult, mature female, moonflower, full body, white night-bloom hair, pale skin, silver light as flat color, bare breasts',
  'Strangler Fig' => '1other, strangler fig, full body, thick roots gripping a stone column, woody tendrils, ridged root cock',
  'Thorn Vine' => '1other, thorn vine, full body, green vines with flat red thorn marks, pink tips, ridged stalks',
  'Pollen Sprite' => '1girl, adult, mature female, pollen sprite, full body, small adult, leaf wings, pollen cloud as flat dots, nude, mischievous',
  'Sap Dryad' => '1girl, adult, mature female, sap dryad, full body, bark-brown skin, amber sap on her breasts and thighs, leaf hair, large breasts',
  'Nightshade' => '1girl, adult, mature female, nightshade, full body, dark purple skin, belladonna berries in her hair, bare breasts, sultry',
  'Chest Mimic' => '1other, chest mimic, full body, iron-banded treasure chest, lid open with sharp teeth, long tongue, wet pink interior, coins',
  'Door Mimic' => '1other, door mimic, full body, dungeon door, knocker is a mouth, tongue through the keyhole, wood flexing',
  'Statue Mimic' => '1girl, adult, statue mimic, full body, marble nude cracking open, pink wet flesh in the cracks, stone cock turning soft',
  'Item Pile Mimic' => '1other, item pile mimic, full body, pile of gold and weapons rising, tongues between coins, wet hollow',
  'Chair Mimic' => '1other, chair mimic, full body, wooden chair with a grinning mouth in the seat, tongue, plush wet cushion',
  'Wardrobe Mimic' => '1other, wardrobe mimic, full body, tall wardrobe, doors open as a mouth, hanging clothes as tongues, dark wet interior',
  'Couch Mimic' => '1other, couch mimic, full body, velvet couch, cushions splitting into a soft mouth, long tongue',
  'Clothing Mimic' => '1other, clothing mimic, full body, a dress standing empty and alive, lace sleeves reaching, wet interior',
  'Stone Golem' => '1boy, adult, stone golem, full body, blocky stone body, glowing cracks, heavy, thick stone cock',
  'Bed Mimic' => '1other, bed mimic, full body, four-poster bed, sheets parting like lips, tongue in the mattress, canopy teeth',
  'Book Mimic' => '1other, book mimic, full body, huge open book, pages lined with teeth, long tongue, wet gutter',
  'Mirror Mimic' => '1other, mirror mimic, full body, standing mirror, glass rippling into a mouth, tongue reaching out of the reflection',
  'Bath Mimic' => '1other, bath mimic, full body, clawfoot tub, water rising as a tongue, mouth in the drain, steam as flat bands',
  'Throne Mimic' => '1other, throne mimic, full body, velvet throne, seat split into a maw, gold frame, long tongue on the cushion',
  'Curtain Mimic' => '1other, curtain mimic, full body, heavy curtains parting like labia, wet dark gap, tongues in the folds',
  'Rug Mimic' => '1other, rug mimic, full body, ornate rug peeling up, underside is a wet mouth, tassels as small tongues',
  'Chandelier Mimic' => '1other, chandelier mimic, full body, hanging chandelier, candles, crystal arms ending in tongues, mouth at the center',
  'Clock Mimic' => '1other, clock mimic, full body, grandfather clock, face split into a grin, pendulum tongue, open case',
  'Piano Mimic' => '1other, piano mimic, full body, grand piano, keys as teeth, lid open, long tongue across the strings',
  'Loom Mimic' => '1other, loom mimic, full body, wooden loom, threads as tendrils, shuttle mouth, wet warp',
  'Carnival Clown' => '1boy, adult, mature male, clown, full body, white paint, red grin, ruffled collar, costume open, painted cock, balloons',
  'Balloon Mistress' => '1girl, adult, mature female, clown, full body, latex balloons as a dress that fails, painted smile, large breasts, plump pussy',
  'Pie Clown' => '1girl, adult, mature female, clown, full body, cream pie smeared on bare breasts and thighs, painted face, laughing',
  'Honker' => '1boy, adult, mature male, clown, full body, red nose, tiny horn in hand, striped suit open, erect cock, silly and explicit',
  'Ringmaster' => '1boy, adult, mature male, ringmaster, full body, red coat open, top hat, whip, bare chest, thick cock, commanding',
  'Jester' => '1boy, adult, mature male, jester, full body, belled cap, motley open at the crotch, slim, cock with a ribbon, grin',
  'Cotton-Candy Imp' => '1girl, adult, mature female, imp, full body, small wiry adult, pink cotton-candy hair, sugar on her skin, tiny horns, nude, plump pussy',
  'Big-Shoe Brute' => '1boy, adult, mature male, clown, full body, huge shoes, hulking, makeup, costume torn open, massive cock'
}.freeze

def clean(text)
  text.to_s.gsub(/\s+/, ' ').gsub(/[*_]/, '').strip
end

def one_sentence(text)
  sentence = clean(text).split(/(?<=[.!?])\s/, 2).first.to_s
  sentence.length > 280 ? "#{sentence[0, 277]}..." : sentence
end

def block(tags, explicit:)
  lines = [PIXEL, tags, SHADE]
  lines << (explicit ? 'nsfw, explicit' : 'suggestive')
  <<~MD.chomp
    **NovelAI prompt**

    ```
    #{lines.join("\n")}
    ```

    **Undesired content**

    ```
    #{UC}, cute, chibi, simple, mascot
    ```
  MD
end

def write_file(relative, title, intro, sections)
  path = File.join(OUT, relative)
  FileUtils.mkdir_p(File.dirname(path))
  body = +"# #{title}\n\n#{intro}\n\nSettings and the shared pixel lock live in [art_reference.md](../../art_reference.md).\n\n"
  body << sections.join("\n\n")
  body << "\n"
  File.write(path, body)
  path
end

def monster_files
  written = []
  Engine::MonsterTypes::TYPES.each do |key, info|
    next if info[:common_monsters].empty?

    sections = info[:common_monsters].map do |name|
      note = ALIAS[name] ? "\n\n_#{ALIAS[name]}_" : ''
      look = LOOK[name] or raise "no look for #{name}"
      "### #{name}#{note}\n\n#{block(look, explicit: true)}"
    end
    rel = "monsters/#{key}.md"
    write_file(rel, "#{info[:name]} monsters", info[:description], sections)
    written << [rel, info[:common_monsters].size]
  end
  written
end

def item_section(item, explicit:)
  name = item[:name] || item['name']
  description = clean(item[:description] || item['description'])
  tags = if explicit
           "1girl, adult, mature female, full body, wearing #{name}, #{description}"
         else
           "single object centered, #{name}, #{description}"
         end
  "### #{name}\n\n#{block(tags, explicit: explicit)}"
end

def erotic_item?(item)
  text = "#{item[:name]} #{item[:description]}".downcase
  text.match?(/lace|lingerie|corset|heel|stocking|plug|chastity|milking|bra\b|collar|harness|veil|skirt|habit|silk|thong|panties|bodysuit|glove|cloak|bridle|scarf|uniform|anklet|circlet|bodice|hose|goggles|chaps/)
end

def item_files
  shop = Engine::Shop::INVENTORY.map { |item| item_section(item, explicit: erotic_item?(item)) }
  living = (Engine::Treasure::MIMIC_TEMPLATES + Engine::Treasure::EVENT_MIMICS).map { |item| item_section(item, explicit: true) }
  chests = (Engine::Treasure::BASIC_GEAR + Engine::Treasure::CHEST_FINDS).map { |item| item_section(item, explicit: erotic_item?(item)) }
  vex = Engine::Residents::VEX_OUTFITS.map { |item| item_section(item, explicit: true) }
  dev = Engine::Wardrobe::DEV_GEAR.map { |item| item_section(item, explicit: true) }
  [
    write_file('items/shop.md', 'Shop goods', 'Berry\'s counter. Potions are the bottle. Clothes are shown on an adult body.', shop),
    write_file('items/living_gear.md', 'Living gear', 'Cursed mimic pieces. Each one is worn, and awake.', living),
    write_file('items/chests.md', 'Chest finds', 'Common and rare chest gear.', chests),
    write_file('items/vex.md', "Vex's rack", 'Outfits from the Listener\'s rack, shown on an adult body.', vex),
    write_file('items/makers_own.md', "The Maker's Own", "Syn's dev-only set. These pieces refuse anyone else.", dev)
  ]
end

PACKS = {
  'core' => Engine::EventPacks::CORE,
  'body' => Engine::EventPacks::BODY,
  'kink' => Engine::EventPacks::KINK,
  'fetish' => Engine::EventPacks::FETISH,
  'halloween' => Engine::EventPacks::HALLOWEEN,
  'thanksgiving' => Engine::EventPacks::THANKSGIVING,
  'christmas' => Engine::EventPacks::CHRISTMAS,
  'new_year' => Engine::EventPacks::NEW_YEAR,
  'valentines' => Engine::EventPacks::VALENTINES,
  'mardi_gras' => Engine::EventPacks::MARDI_GRAS,
  'easter' => Engine::EventPacks::EASTER,
  'april_fools' => Engine::EventPacks::APRIL_FOOLS,
  'may_day' => Engine::EventPacks::MAY_DAY,
  'midsummer' => Engine::EventPacks::MIDSUMMER,
  'pride' => Engine::EventPacks::PRIDE
}.freeze

def event_section(key, data)
  name = data[:name] || key
  blurb = clean(data[:blurb])
  intro = one_sentence(data[:intro])
  tags = "explicit scene, full body, centered, adult, #{name}, #{blurb}, #{intro}"
  "### #{name}\n\n#{block(tags, explicit: true)}"
end

def event_files
  written = []
  seen = []
  PACKS.each do |file, pack|
    sections = pack.map { |key, data| event_section(key, data) }
    seen.concat(pack.keys)
    rel = "events/#{file}.md"
    write_file(rel, "#{file.tr('_', ' ').capitalize} events", "#{pack.size} events.", sections)
    written << [rel, pack.size]
  end
  rest = Engine::FetishEvents::EVENTS.reject { |key, _| seen.include?(key) }
  sections = rest.map { |key, data| event_section(key, data) }
  rel = 'events/tower.md'
  write_file(rel, 'Tower events', 'Events that live in the base catalog rather than a themed pack.', sections)
  written << [rel, rest.size]
  written
end

def index(monster_counts, item_paths, event_counts)
  lines = []
  lines << '# Art prompts'
  lines << ''
  lines << 'Pixel-sprite prompts for encounter monsters, gear, and events. Bosses, relics, and named characters stay in [art_reference.md](../art_reference.md).'
  lines << ''
  lines << '## Monsters'
  lines << ''
  monster_counts.each { |rel, n| lines << "- [#{rel}](#{rel}) (#{n})" }
  lines << ''
  lines << '## Items'
  lines << ''
  item_paths.each { |path| lines << "- [#{path.delete_prefix(OUT + '/').delete_prefix(File.join(ROOT, 'docs/art') + '/')}](#{path.sub(OUT + '/', '')})" }
  # fix index links properly below
  lines
end

monster_counts = monster_files
item_paths = item_files
event_counts = event_files

index_lines = []
index_lines << '# Art prompts'
index_lines << ''
index_lines << 'Pixel-sprite prompts for encounter monsters, gear, and events. Bosses, relics, and named people stay in [art_reference.md](../art_reference.md). Use that file\'s settings: quality tags off, 512×768, 25 steps, guidance 7.'
index_lines << ''
index_lines << '## Monsters'
index_lines << ''
monster_counts.each { |rel, n| index_lines << "- [#{File.basename(rel, '.md')}](#{rel}) — #{n}" }
index_lines << ''
index_lines << '## Items'
index_lines << ''
item_paths.each do |path|
  rel = path.sub("#{OUT}/", '')
  index_lines << "- [#{File.basename(rel, '.md').tr('_', ' ')}](#{rel})"
end
index_lines << ''
index_lines << '## Events'
index_lines << ''
event_counts.each { |rel, n| index_lines << "- [#{File.basename(rel, '.md').tr('_', ' ')}](#{rel}) — #{n}" }
index_lines << ''
File.write(File.join(OUT, 'README.md'), index_lines.join("\n"))

missing = Engine::MonsterTypes::TYPES.values.flat_map { |t| t[:common_monsters] } - LOOK.keys
abort "missing looks: #{missing.join(', ')}" unless missing.empty?

puts "monsters #{monster_counts.sum { |_, n| n }}"
puts "events #{event_counts.sum { |_, n| n }}"
puts "items #{item_paths.size} files"
