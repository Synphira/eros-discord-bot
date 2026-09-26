# frozen_string_literal: true

# E.R.O.S. — Explorations of Risqué Underground Systems
# Discord entrypoint: slash commands + explore interaction buttons.
#
# Commands:
#   /start   — create (or greet) a player profile
#   /status  — HP, LP, active curses, Threat Level + progress bar
#   /explore — room step with threat calc and action buttons

require 'bundler/setup'
require 'dotenv/load'
require 'discordrb'
require 'fileutils'

require_relative 'config/database'
require_relative 'lib/engine/threat_calculator'
require_relative 'lib/engine/combat_engine'
require_relative 'lib/engine/surge_manager'

TOKEN = ENV.fetch('DISCORD_TOKEN') do
  warn 'Missing DISCORD_TOKEN. Copy .env.example → .env and set your bot token.'
  exit 1
end

CLIENT_ID = ENV['DISCORD_CLIENT_ID']

# Prefix still available for local debugging; primary UX is slash + buttons.
bot = Discordrb::Commands::CommandBot.new(
  token: TOKEN,
  client_id: CLIENT_ID,
  prefix: ENV.fetch('BOT_PREFIX', '!'),
  intents: %i[servers server_messages]
)

# In-memory encounter snapshots keyed by Discord user id (enough for MVP).
# Survives for the process lifetime; restart clears mid-fight state.
ENCOUNTERS = {}

# ---------------------------------------------------------------------------
# Presentation helpers
# ---------------------------------------------------------------------------

module ErosUI
  module_function

  def threat_bar(percent)
    clamped = [[percent, 0].max, 100].min
    filled = (clamped / 10).floor
    empty = 10 - filled
    "`[#{'█' * filled}#{'░' * empty}]` #{clamped.round(1)}%"
  end

  def threat_label(category)
    case category
    when :low    then 'LOW'
    when :medium then 'MEDIUM'
    when :high   then 'HIGH'
    else category.to_s.upcase
    end
  end

  def status_embed(player)
    threat = Engine::ThreatCalculator.calculate(player)
    active = player.active_curses
    curse_lines =
      if active.empty?
        '_None — the dark has not marked you yet._'
      else
        active.map { |c| "• **#{c.name}** _(#{c.category})_" }.join("\n")
      end

    {
      title: 'E.R.O.S. — Delver Status',
      description: 'Explorations of Risqué Underground Systems',
      color: threat_color(threat.category),
      fields: [
        { name: 'Floor', value: player.current_floor.to_s, inline: true },
        { name: 'HP', value: "#{player.hp}/#{player.max_hp}", inline: true },
        { name: 'LP', value: player.lp.to_s, inline: true },
        {
          name: 'Threat Level',
          value: "**#{threat_label(threat.category)}** #{threat_bar(threat.percent)}\n" \
                 "_LP contrib #{threat.lp_component}% · Curses +#{threat.curse_component}_",
          inline: false
        },
        { name: 'Active Curses', value: curse_lines, inline: false },
        {
          name: 'Combat',
          value: player.in_combat ? 'Engaged' : 'Quiet for now',
          inline: true
        }
      ],
      footer: { text: 'Death resets floor to 1 — LP & curses persist.' }
    }
  end

  def threat_color(category)
    case category
    when :low    then 0x4a7c59
    when :medium then 0xb8860b
    when :high   then 0x8b1a1a
    else 0x444444
    end
  end

  # Attach explore action buttons to a discordrb Webhooks::View / Components::View.
  def attach_explore_buttons(view)
    view.row do |row|
      row.button(label: 'Explore Path', style: :primary, custom_id: 'eros:explore_path')
      row.button(label: 'Rest', style: :secondary, custom_id: 'eros:rest')
      row.button(label: 'Use Surge', style: :danger, custom_id: 'eros:use_surge')
    end
  end
end

def find_player(discord_id)
  Player[discord_id]
end

def require_player(event)
  player = find_player(event.user.id)
  return player if player

  msg = 'No profile yet. Use `/start` to descend into the Abyss.'
  if event.respond_to?(:respond)
    event.respond(content: msg, ephemeral: true)
  else
    event << msg
  end
  nil
end

# ---------------------------------------------------------------------------
# Slash command registration (runs once on ready)
# ---------------------------------------------------------------------------

bot.ready do |_event|
  begin
    bot.register_application_command(:start, 'Create your E.R.O.S. delver profile')
    bot.register_application_command(:status, 'Show HP, LP, curses, and Threat Level')
    bot.register_application_command(:explore, 'Step deeper into the endless dungeon')
  rescue Discordrb::Errors::CodeError => e
    warn "Slash registration warning: #{e.message}"
  end
  puts "E.R.O.S. online as #{bot.profile&.username}"
end

# ---------------------------------------------------------------------------
# /start — create player profile
# ---------------------------------------------------------------------------

bot.application_command(:start) do |event|
  existing = Player[event.user.id]
  if existing
    event.respond(
      content: "You already walk these halls (Floor #{existing.current_floor}). " \
               'Use `/status` or `/explore`.',
      ephemeral: true
    )
    next
  end

  player = Player.create(
    discord_id: event.user.id,
    hp: 100,
    max_hp: 100,
    lp: 0,
    current_floor: 1,
    in_combat: false
  )

  event.respond(
    content: "**Welcome to E.R.O.S.**\n" \
             "Explorations of Risqué Underground Systems.\n" \
             "Profile sealed for <@#{player.discord_id}>. " \
             'Seek the **Seal of the Abyss** — or be remade by what finds you first.'
  )
end

# Prefix fallback for environments without slash sync yet
bot.command(:start, description: 'Create your E.R.O.S. delver profile') do |event|
  existing = Player[event.user.id]
  if existing
    event << "Already registered (Floor #{existing.current_floor}). Try `!status` / `!explore`."
    next
  end
  Player.create(discord_id: event.user.id, hp: 100, max_hp: 100, lp: 0, current_floor: 1, in_combat: false)
  event << 'Profile created. The dungeon waits. Use `!explore`.'
end

# ---------------------------------------------------------------------------
# /status
# ---------------------------------------------------------------------------

bot.application_command(:status) do |event|
  player = require_player(event) or next
  embed = ErosUI.status_embed(player)
  event.respond(embeds: [embed])
end

bot.command(:status, description: 'Show delver status') do |event|
  player = Player[event.user.id]
  unless player
    event << 'No profile. Use `!start` first.'
    next
  end
  event.channel.send_embed do |emb|
    data = ErosUI.status_embed(player)
    emb.title = data[:title]
    emb.description = data[:description]
    emb.color = data[:color]
    data[:fields].each { |f| emb.add_field(name: f[:name], value: f[:value], inline: f[:inline]) }
    emb.footer = Discordrb::Webhooks::EmbedFooter.new(text: data[:footer][:text])
  end
  nil
end

# ---------------------------------------------------------------------------
# /explore — room step + buttons
# ---------------------------------------------------------------------------

def explore_room_narrative(player, threat)
  rooms = [
    'A wet corridor pulses with bioluminescent veins.',
    'You push through a curtain of living silk.',
    'Stone stairs spiral down; something breathes below.',
    'A ruined shrine flickers — LP could buy mercy here, someday.',
    'Footprints in ash lead toward a sealed iron door.'
  ]
  room = rooms.sample
  <<~TEXT.strip
    **Floor #{player.current_floor}** — #{room}

    Threat: **#{ErosUI.threat_label(threat.category)}** #{ErosUI.threat_bar(threat.percent)}
    HP `#{player.hp}/#{player.max_hp}` · LP `#{player.lp}`

    Choose your next move:
  TEXT
end

bot.application_command(:explore) do |event|
  player = require_player(event) or next

  if player.in_combat
    event.respond(
      content: 'You are already in combat. Use the **Use Surge** button or finish the fight via **Explore Path**.',
      ephemeral: true
    )
    next
  end

  threat = Engine::ThreatCalculator.calculate(player)
  text = explore_room_narrative(player, threat)

  event.respond(content: text) { |view| ErosUI.attach_explore_buttons(view) }
end

bot.command(:explore, description: 'Explore the dungeon') do |event|
  player = Player[event.user.id]
  unless player
    event << 'No profile. Use `!start` first.'
    next
  end
  threat = Engine::ThreatCalculator.calculate(player)
  event << explore_room_narrative(player, threat)
  event << 'Buttons: react in slash `/explore` for [Explore Path] [Rest] [Use Surge].'
  nil
end

# ---------------------------------------------------------------------------
# Button handlers
# ---------------------------------------------------------------------------

bot.button(custom_id: /^eros:explore_path$/) do |event|
  player = Player[event.user.id]
  unless player
    event.respond(content: 'No profile. `/start` first.', ephemeral: true)
    next
  end

  # If already in combat, resolve a round against the stored encounter.
  if player.in_combat && ENCOUNTERS[player.discord_id]
    enc = ENCOUNTERS[player.discord_id]
    result = Engine::CombatEngine.resolve_round(
      player,
      monster_hp: enc[:monster_hp],
      monster_damage: enc[:monster_damage],
      monster_name: enc[:monster_name],
      surge_effects: enc[:pending_surge]
    )
    enc[:pending_surge] = nil

    if result[:died]
      ENCOUNTERS.delete(player.discord_id)
      event.respond(content: result[:log].join("\n"))
      next
    end

    if result[:victory]
      ENCOUNTERS.delete(player.discord_id)
      player.update(current_floor: player.current_floor + 1)
      event.respond(content: "#{result[:log].join("\n")}\nYou advance to **Floor #{player.current_floor}**.")
      next
    end

    enc[:monster_hp] = result[:monster_hp]
    ENCOUNTERS[player.discord_id] = enc
    event.respond(
      content: "#{result[:log].join("\n")}\nEnemy HP remaining: **#{result[:monster_hp]}** · Your HP: **#{player.hp}**"
    ) { |view| ErosUI.attach_explore_buttons(view) }
    next
  end

  # Otherwise start a new encounter from this room.
  started = Engine::CombatEngine.start_encounter(player)
  enc = started[:encounter]
  ENCOUNTERS[player.discord_id] = {
    monster_name: enc.monster_name,
    monster_hp: enc.monster_hp,
    monster_damage: enc.monster_damage,
    lp_reward: enc.lp_reward,
    pending_surge: { lp_reward: enc.lp_reward }
  }

  event.respond(content: started[:message]) { |view| ErosUI.attach_explore_buttons(view) }
end

bot.button(custom_id: /^eros:rest$/) do |event|
  player = Player[event.user.id]
  unless player
    event.respond(content: 'No profile. `/start` first.', ephemeral: true)
    next
  end

  if player.in_combat
    event.respond(content: 'You cannot rest mid-combat. Fight, surge, or fall.', ephemeral: true)
    next
  end

  heal = 20
  player.heal!(heal)
  # Resting on a floor can still attract minor LP pressure.
  player.gain_lp!(2)
  threat = Engine::ThreatCalculator.calculate(player)

  event.respond(
    content: "You rest against cold stone. **+#{heal} HP** (now #{player.hp}/#{player.max_hp}), " \
             "**+2 LP**. Threat now **#{ErosUI.threat_label(threat.category)}** " \
             "#{ErosUI.threat_bar(threat.percent)}"
  ) { |view| ErosUI.attach_explore_buttons(view) }
end

bot.button(custom_id: /^eros:use_surge$/) do |event|
  player = Player[event.user.id]
  unless player
    event.respond(content: 'No profile. `/start` first.', ephemeral: true)
    next
  end

  unless player.in_combat
    event.respond(content: 'Surges only ignite in combat. Press **Explore Path** first.', ephemeral: true)
    next
  end

  # Cycle: pick the cheapest affordable builtin surge, prefer hardened_aura if rich.
  manager = Engine::SurgeManager.new(player)
  choice =
    manager.available_surges
           .select { |s| s.cost <= player.lp }
           .min_by(&:cost)

  unless choice
    event.respond(
      content: "Insufficient LP for any surge (have #{player.lp}). " \
               'Sensory Overdrive needs 15; Willpower Flush needs 10.',
      ephemeral: true
    )
    next
  end

  result = manager.activate(choice.key)
  unless result[:ok]
    event.respond(content: result[:message], ephemeral: true)
    next
  end

  # Attach surge side-effects to the next combat round.
  if ENCOUNTERS[player.discord_id]
    pending = result[:side_effects].merge(lp_reward: ENCOUNTERS[player.discord_id][:lp_reward])
    ENCOUNTERS[player.discord_id][:pending_surge] = pending
  end

  fled = result.dig(:side_effects, :fled)
  if fled
    ENCOUNTERS.delete(player.discord_id)
    event.respond(content: "#{result[:message]}\nYou tear free of the encounter.")
    next
  elsif result.dig(:side_effects, :fled) == false
    event.respond(
      content: "#{result[:message]}\nEscape fails — the foe still holds you."
    ) { |view| ErosUI.attach_explore_buttons(view) }
    next
  end

  event.respond(
    content: "#{result[:message]}\nSide effects ready for the next exchange. Press **Explore Path** to strike."
  ) { |view| ErosUI.attach_explore_buttons(view) }
end

# ---------------------------------------------------------------------------
# Boot
# ---------------------------------------------------------------------------

puts 'Starting E.R.O.S. Discord bot...'
bot.run
