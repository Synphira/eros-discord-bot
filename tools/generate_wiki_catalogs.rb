# frozen_string_literal: true

# Regenerates player Wiki catalog pages from engine data. Run from repo root:
#   ruby tools/generate_wiki_catalogs.rb

require 'fileutils'
require 'json'

# Minimal boot: engine modules only (no Discord / DB).
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require_relative '../lib/engine/content_options'
require_relative '../lib/engine/monster_types'
require_relative '../lib/engine/fetish_events'
require_relative '../lib/engine/shop'
require_relative '../lib/engine/treasure'
require_relative '../lib/engine/marks'
require_relative '../lib/engine/curse_catalog'
require_relative '../lib/engine/title_system'
require_relative '../lib/engine/transformation_system'
require_relative '../lib/engine/wardrobe'
require_relative '../lib/engine/residents'

WIKI = File.expand_path('../Wiki', __dir__)

def write!(rel, body)
  path = File.join(WIKI, rel)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, body.gsub(/\n{3,}/, "\n\n").strip + "\n")
  puts "wrote #{rel}"
end

def fmt_mods(mods)
  return '—' if mods.nil? || mods.empty?

  Engine::FetishEvents.describe_effects(mods)
rescue StandardError
  mods.map do |k, v|
    key = k.to_s.tr('_', ' ')
    case v
    when TrueClass then key
    when Numeric
      if k.to_s.end_with?('_mult') || k.to_s.include?('chance') || k.to_s.include?('bonus') && v.abs < 2 && v != v.to_i
        "#{key} #{v.is_a?(Float) ? format('%+g', v) : v}"
      else
        "#{key} #{v.is_a?(Numeric) && v == v.to_i ? format('%+d', v) : v}"
      end
    else
      "#{key}: #{v}"
    end
  end.join('; ')
end

def option_label(key)
  return nil unless key

  Engine::ContentOptions.preference(key)&.dig(:label) || key.to_s.tr('_', ' ')
end

def fmt_req_hash(req)
  return '—' if req.nil? || req.empty?

  labels = Engine::TitleSystem.const_get(:TRACKER_LABELS) rescue {}
  # Prefer the public label map if present
  label_map = {}
  if Engine::TitleSystem.respond_to?(:tracker_label)
    # no-op
  end
  # Pull TRACKER_LABELS-like constant from source map used in achievements
  src = File.read(File.expand_path('../lib/engine/title_system.rb', __dir__))
  # Use requirement_met keys — humanize from TitleSystem if available
  req.map do |k, v|
    label = human_tracker(k)
    case v
    when TrueClass then label
    when Hash
      if v.key?(:max)
        "#{label} ≤ #{v[:max]}"
      elsif v.key?(:min)
        "#{label} ≥ #{v[:min]}"
      else
        "#{label} (#{v.inspect})"
      end
    else
      "#{label}: #{v}"
    end
  end.join('; ')
end

def human_tracker(key)
  key = key.to_s
  map = {
    'floors_cleared' => 'floors cleared',
    'cycles_completed' => 'cycles completed',
    'lp_earned' => 'LP earned',
    'submissions' => 'submissions',
    'curses_acquired' => 'curses acquired',
    'treasure_found' => 'treasures found',
    'beast_submissions' => 'beast submissions',
    'demon_submissions' => 'demon submissions',
    'slime_submissions' => 'slime submissions',
    'undead_submissions' => 'undead submissions',
    'plant_submissions' => 'plant submissions',
    'mimic_submissions' => 'mimic submissions',
    'monsters_killed' => 'monsters killed',
    'bosses_defeated' => 'bosses defeated',
    'bosses_satisfied' => 'bosses satisfied',
    'highest_floor' => 'highest floor',
    'petplay_events' => 'petplay events',
    'being_milked_events' => 'milking events',
    'lactation_events' => 'lactation events',
    'weight_gain_events' => 'weight gain events',
    'body_growth_events' => 'body growth events',
    'exhibitionism_events' => 'exhibitionism events',
    'inflation_events' => 'inflation events',
    'futanari_events' => 'futanari events',
    'body_reduction_events' => 'body reduction events',
    'mind_control_events' => 'mind control events',
    'objectification_events' => 'objectification events',
    'slavery_events' => 'slavery events',
    'bondage_events' => 'bondage events',
    'sensory_deprivation_events' => 'sensory deprivation events',
    'latex_events' => 'latex events',
    'tentacle_events' => 'tentacle events',
    'possession_events' => 'possession events',
    'size_events' => 'size-difference events',
    'furry_events' => 'furry events',
    'pure_title' => 'earn the Pure title',
    'run_floors_cleared' => 'floors cleared this run',
    'run_submissions' => 'submissions this run',
    'forms_unlocked' => 'hybrid forms unlocked',
    'chimera_fused' => 'fuse a Chimera',
    'is_developer' => '(developer only)',
    'is_bug_tester' => '(bug tester only)'
  }
  return map[key] if map[key]

  # Fall back to TitleSystem tracker labels embedded in the file
  if defined?(Engine::TitleSystem) && Engine::TitleSystem.respond_to?(:achievement_tracker_label)
    return Engine::TitleSystem.achievement_tracker_label(key)
  end

  # Pull from the labels hash inside title_system by eval-safe read
  @tracker_labels ||= begin
    h = {}
    File.readlines(File.expand_path('../lib/engine/title_system.rb', __dir__)).each do |line|
      if line =~ /^\s+([a-z0-9_]+):\s+'([^']+)'/
        h[Regexp.last_match(1)] = Regexp.last_match(2)
      end
    end
    h
  end
  @tracker_labels[key] || key.tr('_', ' ')
end

def rarity_stars(n)
  n = n.to_i
  return '' if n <= 0

  '★' * n
end

# Prefer FetishEvents.describe_effects — require it
begin
  require_relative '../lib/engine/fetish_events'
rescue LoadError
end

# ---------- Equipment (Berry + chests + basic) ----------
shop_body = +<<~MD
  # Equipment

  Ordinary gear you can wear. Living (cursed) gear is listed separately under [Living gear](Living-Gear.md). Outfit pieces from Madame Vex are under [Outfits](Outfits.md).

  ## Where to get it

  | Source | What |
  | --- | --- |
  | **Berry's shop** (`/shop`) | Weapons, armor, accessories, potions — buy with LP |
  | **Treasure chests** | Occasional named finds deeper in the tower (around floor 8+) |
  | **Hallway loot** | Simple starter pieces (boots, bracers, short blade, …) |
  | **Boss clear** | A **trophy** for that lord (one equipped at a time; lost on defeat) |

  Ordinary gear is usually **lost on defeat**. Potions are used when you buy them (or carried, for Bottled Ceremony).

  Effects below use Berry's listed base stats. Threat and support discounts change what you actually pay.

MD

%w[weapon armor accessory special].each do |cat|
  label = Engine::Shop::CATEGORY_LABELS[cat]
  shop_body << "\n## #{label}\n\n"
  shop_body << if cat == 'special'
                 "| Name | Cost | What it does |\n| --- | ---: | --- |\n"
               else
                 "| Name | Slot | Cost | Rarity | Effects | Description |\n| --- | --- | ---: | --- | --- | --- |\n"
               end
  Engine::Shop::INVENTORY.select { |i| i[:type] == cat }.each do |i|
    if cat == 'special'
      shop_body << "| **#{i[:name]}** | #{i[:cost]} LP | #{i[:description]} |\n"
    else
      mods = fmt_mods(i[:stat_modifiers])
      shop_body << "| **#{i[:name]}** | #{i[:slot]} | #{i[:cost]} LP | #{rarity_stars(i[:rarity])} | #{mods} | #{i[:description]} |\n"
    end
  end
end

shop_body << <<~MD

  ## Chest finds

  Rare pieces that can appear in treasure chests (not sold at Berry's).

  | Name | Slot | Effects | Description |
  | --- | --- | --- | --- |
MD
Engine::Treasure::CHEST_FINDS.each do |i|
  shop_body << "| **#{i[:name]}** | #{i[:slot]} | #{fmt_mods(i[:stat_modifiers])} | #{i[:description]} |\n"
end

shop_body << <<~MD

  ## Basic hallway finds

  Cheap scraps you can pick up while exploring.

  | Name | Slot | Effects | Description |
  | --- | --- | --- | --- |
MD
Engine::Treasure::BASIC_GEAR.each do |i|
  shop_body << "| **#{i[:name]}** | #{i[:slot]} | #{fmt_mods(i[:stat_modifiers])} | #{i[:description]} |\n"
end

shop_body << <<~MD

  ## Hidden outfit sets

  Wear every piece of a set at once and a bonus wakes up (shown on `/equipment` once active). Pieces come from Berry, Vex, chests, and seasons — see [Outfits](Outfits.md).

  | Set | Bonus | Pieces | Effects |
  | --- | --- | --- | --- |
MD
Engine::Wardrobe::SETS.each_value do |spec|
  next if spec[:pieces].any? { |p| p.start_with?("Syn's") } # Maker's Own is listed but Syn pieces are special

  shop_body << "| **#{spec[:name]}** | *#{spec[:bonus_name]}* | #{spec[:pieces].join(', ')} | #{fmt_mods(spec[:effects])} |\n"
end

write!('Systems/Equipment.md', shop_body)

# ---------- Living gear ----------
living = +<<~MD
  # Living gear

  Cursed, clingy equipment. It gives stats **and** acts on its own (tease, bind, milk, deny climax, …). It **survives defeat**.

  ## Where to get it

  | Source | What |
  | --- | --- |
  | **Treasure chests / events** | Living pieces can bind you when your content options allow their theme |
  | **`/remove`** | Tear a piece free for LP — unlocks reclaim |
  | **Covar's Cursed Shop** (`/cursedshop`) | Browse by aisle and take back anything you've torn free, **for free** |
  | **Living Clothing** option | Must be on (or the piece's own required theme) or that item won't bind you |

  Some pieces also need a body part (breasts, anus, …). If your body doesn't have it, Covar won't hand it back.

  ## Catalog

  | Name | Slot | Tear cost | Needs option | Effects | Description |
  | --- | --- | ---: | --- | --- | --- |
MD

(Engine::Treasure::MIMIC_TEMPLATES + Engine::Treasure::EVENT_MIMICS).each do |t|
  opt = option_label(t[:requires]) || '—'
  opt += " · needs #{t[:part]}" if t[:part]
  living << "| **#{t[:name]}** | #{t[:slot]} | #{t[:removal_cost]} LP | #{opt} | #{fmt_mods(t[:stat_modifiers])} | #{t[:description]} |\n"
end

living << <<~MD

  ### Special weapon behavior

  | Weapon | While fighting |
  | --- | --- |
  | **Dagger of Aching Desire** | Steals LP on hit; sometimes floods *you* with lust |
  | **Whip of Will-Breaking** | Makes the foe easier to satisfy; sometimes lashes *you* into a submissive urge |
MD

write!('Systems/Living-Gear.md', living)

# ---------- Outfits (Vex) ----------
tier_label = {
  basic: 'Always in stock',
  restored: 'Restored rack (unlock via Vex\'s story / fittings)',
  halloween: "All Hallows' Heat — then free reclaim forever once owned",
  labor_day: "Pip's Slow Spell — then free reclaim forever once owned",
  thanksgiving: 'Feast of the Willing — then free reclaim forever once owned',
  christmas: 'Yule of Surrender — then free reclaim forever once owned',
  new_year: 'Midnight Oath — then free reclaim forever once owned',
  valentines: 'Heartstring Claim — then free reclaim forever once owned',
  mardi_gras: 'Carnival of Beads — then free reclaim forever once owned',
  easter: "Hare's Hunt — then free reclaim forever once owned",
  april_fools: "Fool's Trap — then free reclaim forever once owned",
  may_day: 'Maypole Raising — then free reclaim forever once owned',
  midsummer: 'Longest Day — then free reclaim forever once owned',
  pride: 'Pride Parade — then free reclaim forever once owned'
}

outfits = +<<~MD
  # Outfits (Madame Vex)

  Buy from **Madame Vex** under `/residents`. Seasonal pieces stay forever after you've earned them and can be reclaimed free later.

  ## Catalog

MD

Engine::Residents::VEX_OUTFITS.group_by { |s| s[:tier] }.each do |tier, list|
  outfits << "### #{tier_label[tier] || tier}\n\n"
  outfits << "| Name | Slot | Cost | Effects | Description |\n| --- | --- | ---: | --- | --- |\n"
  list.each do |s|
    outfits << "| **#{s[:name]}** | #{s[:slot]} | #{s[:cost]} LP | #{fmt_mods(s[:stat_modifiers])} | #{s[:description]} |\n"
  end
  outfits << "\n"
end

outfits << <<~MD
  ## Set bonuses

  Wear every piece of a named set for an extra passive (also listed on [Equipment](Equipment.md)).

  | Set | Bonus | Pieces | Effects |
  | --- | --- | --- | --- |
MD
Engine::Wardrobe::SETS.each_value do |spec|
  next if spec[:pieces].any? { |p| p.include?("Syn's") }

  outfits << "| **#{spec[:name]}** | *#{spec[:bonus_name]}* | #{spec[:pieces].join(', ')} | #{fmt_mods(spec[:effects])} |\n"
end

write!('Systems/Outfits.md', outfits)

# ---------- Marks ----------
marks = +<<~MD
  # Marks (Syn's parlour)

  Permanent tattoos and piercings from `/parlour`. Paid in LP. Survive defeat. You can wear up to **5** at once (6 after finishing Syn & Berry's story).

  Some marks need a content option or a body part. **The Wedding Mark** is story-locked (Syn & Berry).

  | Name | Kind | Place | Cost | Perk | Needs |
  | --- | --- | --- | ---: | --- | --- |
MD

Engine::Marks::MARKS.each_value do |m|
  needs = []
  needs << option_label(m[:requires]) if m[:requires]
  needs << m[:part].to_s if m[:part]
  needs << 'story' if m[:story]
  marks << "| **#{m[:name]}** | #{m[:kind]} | #{m[:place]} | #{m[:cost]} LP | #{m[:perk]} | #{needs.empty? ? '—' : needs.join(', ')} |\n"
end

write!('Systems/Marks.md', marks)

# ---------- Curses ----------
curses = +<<~MD
  # Curses

  Brands the tower sticks on you. They raise **Threat** and change how fights feel.

  ## Where they come from

  Defeat, climaxing in combat, satisfying a monster, and sometimes winning. Deeper cycles brand more often.

  ## Managing them

  | Command | Cost | Effect |
  | --- | --- | --- |
  | `/curses` | — | Syn's ledger |
  | `/removecurse` | 50 LP | Remove for good |
  | `/suppresscurse` | 25 LP | Silence until next defeat |

  ## Catalog by monster type

  When a curse is rolled from a fight, it usually matches that monster's type (mimics have their own pool too).

MD

Engine::CurseCatalog::CURSES.each do |type, list|
  label = Engine::CurseCatalog.type_label(type)
  curses << "### #{label}\n\n| Name | What it does |\n| --- | --- |\n"
  list.each do |c|
    curses << "| **#{c[:name]}** | #{c[:description]} |\n"
  end
  curses << "\n"
end

write!('Systems/Curses.md', curses)

# ---------- Titles ----------
titles = +<<~MD
  # Titles

  Earn titles by playing, then wear one with `/titles` / `/title`.

  Support-server titles (*Tagged Devotee*, *Tower Patron*, *Beloved of the Tower*) come from wearing the support tag and/or boosting — they revoke if you drop those.

  Seasonal titles from holiday achievements stay after the event.

  | Title | How to earn | Description |
  | --- | --- | --- |
MD

Engine::TitleSystem::TITLES.each do |key, t|
  next if t[:requirement]&.key?(:is_developer) || t[:requirement]&.key?(:is_bug_tester)

  how = if t[:support]
          'Support server tag / boost'
        else
          fmt_req_hash(t[:requirement])
        end
  titles << "| **#{t[:name]}** | #{how} | #{t[:description]} |\n"
end

write!('Systems/Titles.md', titles)

# ---------- Achievements ----------
cats = Engine::TitleSystem::ACHIEVEMENT_CATEGORIES
ach = +<<~MD
  # Achievements

  Tracked in `/achievements`. Many grant a small LP reward and unlock a matching title when noted in-game.

  ## Categories

MD

Engine::TitleSystem::ACHIEVEMENTS.group_by { |a| a[:category] }.sort_by { |c, _| cats[c] || c }.each do |cat, list|
  ach << "### #{cats[cat] || cat}\n\n| Name | How to earn | Reward |\n| --- | --- | --- |\n"
  list.each do |a|
    reward = a[:reward] ? a[:reward].map { |k, v| "#{v} #{k.to_s.upcase}" }.join(', ') : '—'
    ach << "| **#{a[:name]}** | #{a[:description]} | #{reward} |\n"
  end
  ach << "\n"
end

write!('Systems/Achievements.md', ach)

# ---------- Transformations ----------
forms = +<<~MD
  # Transformations & hybrids

  Unlock forms by meeting their requirements, then manage them with `/transformation` (also `e,hybrid`). Fuse two into a **Chimera**. Forms survive defeat.

  Related scenes lean on matching `/options` themes (petplay, latex, and so on).

  | Form | Group | Buff | Effects | How to unlock | Look |
  | --- | --- | --- | --- | --- | --- |
MD

Engine::TransformationSystem::TRANSFORMATIONS.each_value do |t|
  look = Array(t[:appearance]).join(', ')
  forms << "| **#{t[:name]}** | #{t[:group]} | *#{t[:buff]}* — #{t[:buff_description]} | #{fmt_mods(t[:effects])} | #{fmt_req_hash(t[:requirement])} | #{look} |\n"
end

forms << <<~MD

  Special combat tricks (stun, drain, dream-feed, …) are listed on each form in-game when unlocked.
MD

write!('Systems/Transformation.md', forms)

# ---------- Marks-and-Titles stub redirect ----------
write!('Systems/Marks-and-Titles.md', <<~MD)
  # Marks & titles

  Split into full catalogs:

  - [Marks](Marks.md) — Syn's parlour tattoos & piercings
  - [Titles](Titles.md) — every wear-able title and how to earn it
  - [Achievements](Achievements.md) — `/achievements` checklist
MD

puts 'done'
