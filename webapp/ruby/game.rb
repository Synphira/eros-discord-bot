# frozen_string_literal: true

module Eros
  # One instance per page. handle(input) applies an action through the bot's
  # engine and returns a view hash for the JavaScript renderer: title, log,
  # status, sections and button rows. Nothing here touches the browser.
  class Game
    SAVE_VERSION = 2
    REST_COOLDOWN = 300
    COLOURS = { 'primary' => 'primary', 'danger' => 'danger', 'success' => 'success' }.freeze
    OPTION_GROUPS = {
      'core' => ['Core', Engine::ContentOptions::CORE_KEYS],
      'body' => ['Opt-in bodies', Engine::ContentOptions::BODY_KEYS],
      'kink' => ['Opt-in kinks', Engine::ContentOptions::KINK_KEYS],
      'fetish' => ['Opt-in fetishes', Engine::ContentOptions::FETISH_KEYS]
    }.freeze
    SCREEN_FOR_COMMAND = {
      'titles' => 'Profile', 'profile' => 'Profile', 'transformation' => 'Hybrids', 'equip' => 'Gear',
      'equipment' => 'Gear', 'unequip' => 'Gear', 'remove' => 'Gear', 'cursedshop' => 'Cursed Shop',
      'shop' => 'Shop', 'removecurse' => 'Curses', 'curses' => 'Curses', 'levelup' => 'Level Up',
      'options' => 'Options', 'parlour' => 'Parlour', 'rest' => 'Rest', 'explore' => 'Explore',
      'fight' => 'Fight', 'flee' => 'Flee', 'submit' => 'Submit', 'status' => 'Status'
    }.freeze

    attr_reader :player

    def initialize(save_json = nil)
      @draft = {}
      @screen = 'hub'
      @tab = nil
      @shop_cat = 'weapon'
      @log = []
      @confirm = nil
      @outcome = nil
      load_save(save_json)
    end

    def save_json
      JSON.generate('v' => SAVE_VERSION, 'player' => @player&.values, 'legacy' => Player.legacy)
    end

    def handle(input, notice: nil)
      @log = [@load_notice, notice].compact
      @load_notice = nil
      action = input['action'].to_s
      @confirm = nil unless %w[restart delete_save].include?(action)
      @outcome = nil unless action == 'init'
      if @player.nil?
        create_step(action, input['arg'], input['value'])
      else
        dispatch(action, input['arg'])
      end
      view
    end

    private

    def load_save(json)
      return if json.nil? || json.empty?

      data = JSON.parse(json)
      unless data.is_a?(Hash) && data['v'] == SAVE_VERSION
        @load_notice = 'The tower has changed since your last visit. Older saves cannot follow you in; create a new delver.'
        return
      end
      Player.legacy = data['legacy']
      @player = Player.new(data['player']) if data['player'].is_a?(Hash)
    rescue JSON::ParserError
      @player = nil
    end

    def say(*lines) = @log.concat(lines.flatten.compact)

    # Character creation

    def create_step(action, arg, value)
      case action
      when 'pick_body' then @draft['body'] = arg.to_i if CharacterArchetypes.fetch(arg)
      when 'pick_attitude' then @draft['attitude'] = arg if CharacterArchetypes::SUBMISSION_CHOICES.key?(arg)
      when 'back' then @draft.delete(@draft.key?('attitude') ? 'attitude' : 'body')
      when 'set_name' then finish_creation(value)
      end
    end

    def finish_creation(raw)
      name = Player.normalize_character_name(raw)
      error = Player.character_name_error(name)
      return say(error) if error

      @player = Player.create_from_archetype!(
        discord_id: 1,
        archetype: CharacterArchetypes.fetch(@draft['body']),
        submission: CharacterArchetypes.submission_value(@draft['attitude']),
        character_name: name
      )
      @draft = {}
      @screen = 'hub'
      say('## Welcome to Endless Ruins of Sin', '_Descend. Endure. Desire._',
          { scene: 'The great doors close behind you with a soft, final sigh. The air is warm and sweet, and ' \
                   'somewhere below, something hungry has already caught your scent.' })
    end

    # Game actions

    def dispatch(action, arg)
      case action
      when 'init' then nil
      when 'nav' then navigate(arg.to_s)
      when 'tab' then @tab = arg.to_s
      when 'explore' then explore!
      when 'fight', 'flee', 'submit', 'resist', 'give_in' then combat!(action.to_sym)
      when 'event_choice' then render_event(Engine::RandomEvents.choose!(@player, arg.to_s))
      when 'event_continue' then render_event(Engine::RandomEvents.continue!(@player))
      when 'defeat_continue' then @screen = 'submission'
      when 'rest' then rest!
      when 'levelup' then level_up!(arg.to_s)
      when 'shop_cat' then @shop_cat = Engine::Shop.normalize_category(arg)
      when 'buy' then say(Engine::Shop.buy_item(@player, arg.to_s)[:message])
      when 'sell' then say(Engine::Shop.sell_item(@player, arg.to_s)[:message])
      when 'equip' then say(@player.equip_item(arg.to_s)[:message])
      when 'unequip' then say(@player.unequip_item(arg.to_s)[:message])
      when 'remove_cursed' then say(@player.remove_cursed_equipment!(arg.to_s)[:message])
      when 'cshop_take' then cursed_shop_take!(arg.to_s)
      when 'curse_remove' then say(@player.remove_curse_at!(arg.to_i)[:message])
      when 'curse_suppress' then say(@player.suppress_curse_at!(arg.to_i)[:message])
      when 'title' then say(@player.select_title!(arg.to_s.empty? ? nil : arg.to_s)[:message])
      when 'hybrid' then say(@player.select_transformation!(arg.to_s.empty? ? nil : arg.to_s)[:message])
      when 'mark_buy' then mark!(Engine::Marks.buy!(@player, arg.to_s))
      when 'mark_remove' then mark!(Engine::Marks.remove!(@player, arg.to_s))
      when 'pref' then toggle_pref!(arg.to_s)
      when 'pref_all' then set_all_prefs!(arg.to_s == 'on')
      when 'size' then set_size!(*arg.to_s.split(':', 2))
      when 'restart' then restart!
      when 'delete_save' then delete_save!
      end
      say(@player.check_progress!) if @player && !%w[init nav tab].include?(action)
    end

    def navigate(screen)
      @screen = screen
      @tab = nil
    end

    def busy?
      message =
        if Eros.encounter_for(@player) then 'You are in combat. Fight, flee, or submit.'
        elsif @player.active_event? then 'Something still has hold of you. Finish the event first.'
        end
      say(message) if message
      !message.nil?
    end

    def explore!
      return say('You are in combat. Fight, flee, or submit.') if Eros.encounter_for(@player)

      @screen = 'hub'
      result = Engine::Exploration.roll(@player)
      progress = @player.check_progress!

      case result.kind
      when :boss
        enc = result.monster
        enc = Engine::CombatEngine.encounter_snapshot(enc) unless enc.is_a?(Hash)
        Eros.set_encounter!(@player, enc.merge(is_boss: true))
        say(result.message,
            "**Boss fight!** Submitting is a gamble: land #{Engine::CombatEngine::BOSS_SATISFY_NEEDED} successful " \
            "submits to satisfy the boss for ×#{Engine::CombatEngine::BOSS_SATISFY_LP_MULT} LP, but it keeps " \
            "attacking and you can't dodge while submitting.")
      when :monster
        started = Engine::CombatEngine.start_encounter(@player, monster: result.monster)
        Eros.set_encounter!(@player, started[:encounter])
        say(result.message, started[:message])
      when :event
        render_event(result.event_result || { mode: :done, log: [result.message], broken: result.broken })
      else
        say(result.message.to_s.split("\n"))
        @outcome = :defeat if result.broken
      end
      say(progress)
    end

    def render_event(result)
      result = result.transform_keys(&:to_sym)
      say("## #{result[:name]}") if result[:name] && !@player.active_event?
      say(Engine::ContentOptions.scrub!(@player, Array(result[:log]).dup))

      if result[:mode].to_s == 'combat'
        started = Engine::CombatEngine.start_encounter(@player, monster: result[:monster])
        Eros.set_encounter!(@player, started[:encounter])
        say(started[:message])
      elsif result[:broken]
        @outcome = :defeat
      end
    end

    def combat!(action)
      enc = Eros.encounter_for(@player)
      return say('You are not in combat.') unless enc

      result = Engine::CombatEngine.act!(@player, action, enc)
      return say(result[:log]) unless result[:ok]

      log = result[:log].concat(@player.check_progress!)
      say(Engine::ContentOptions.scrub!(@player, log))

      if result[:tower_cleared] || result[:fled] || result[:satisfied] || result[:victory]
        Eros.clear_encounter!(@player)
      elsif result[:defeated] || result[:broken]
        Eros.clear_encounter!(@player)
        @outcome = :defeat
      else
        Eros.set_encounter!(@player, result[:encounter])
      end
    end

    def rest_ready_at = @player.tracker('last_rest_at') + REST_COOLDOWN

    def rest!
      return if busy?

      wait = rest_ready_at - Time.now.to_i
      return say("You're too restless to sleep yet. Try again in #{wait / 60}m #{wait % 60}s.") if wait.positive?

      old_lust = @player.lust
      old_def = @player.defiance
      @player.update(lust: 0, defiance: @player.max_defiance)
      @player.set_tracker!('last_rest_at', Time.now.to_i)
      say('You curl up in a quiet corner and sleep until the ache fades.',
          "**−#{old_lust - @player.lust} Lust** (now `#{@player.lust}`) · " \
          "**+#{@player.defiance - old_def} Defiance** (now `#{@player.defiance}/#{@player.max_defiance}`)")
    end

    def level_up!(stat)
      result = stat == 'level' ? @player.upgrade_level! : @player.upgrade_stat!(stat)
      say(result[:message])
    end

    def cursed_shop_take!(name)
      return if busy?

      item = ::Equipment[name]
      message =
        if item.nil? || !item.cursed then 'That item is not in the Cursed Shop.'
        elsif !@player.cursed_shop_unlocked?(item.name)
          "You haven't unlocked **#{item.name}** yet. Wear it and tear it free first."
        else @player.grant_equipment!(item)[:message]
        end
      say(message)
    end

    def mark!(result)
      text = result[:message].to_s
      scene = text[/\A_(.+)_\n/m, 1]
      scene ? say({ scene: scene }, text.sub(/\A_.+_\n/m, '')) : say(text)
    end

    def toggle_pref!(key)
      return unless Engine::ContentOptions::PREFERENCES.key?(key)

      on = !Engine::ContentOptions.preferences_for(@player)[key]
      Engine::ContentOptions.set!(@player, key, on)
      say("**#{Engine::ContentOptions.preference(key)[:label]}** is now **#{on ? 'on' : 'off'}**.")
    end

    def set_all_prefs!(value)
      keys = Engine::ContentOptions::PREFERENCES.keys
      saved = @player.preferences.is_a?(Hash) ? @player.preferences.dup : {}
      keys.each { |k| saved[k] = value }
      @player.update(preferences: saved)
      say(value ? "**All #{keys.size} themes enabled.**" : "**All #{keys.size} themes disabled.** Opt-in events won't appear.")
    end

    def set_size!(part, value)
      spec = Engine::ContentOptions::BODY_SIZES[part.to_s]
      return unless spec && spec[:options].include?(value) && Engine::ContentOptions.applicable_sizes(@player).key?(part)

      sizes = @player.body_sizes.is_a?(Hash) ? @player.body_sizes.dup : {}
      @player.update(body_sizes: sizes.merge(part => value))
      say("#{spec[:label]} size set to **#{value}**.")
    end

    def restart!
      return @confirm = :restart unless @confirm == :restart

      @player.save_legacy!
      @player = nil
      @draft = {}
      @confirm = nil
      say('Your delver fades. Titles, achievements, records and options wait for whoever comes next.')
    end

    def delete_save!
      return @confirm = :delete_save unless @confirm == :delete_save

      @player = nil
      Player.legacy = nil
      @draft = {}
      @confirm = nil
      say('Everything is gone. The tower waits for someone new.')
    end

    # Views

    def btn(label, action, arg: nil, style: 'secondary', disabled: false)
      { label: label, action: action, arg: arg, style: style, disabled: disabled }
    end

    def view
      base = { log: render_log(@log) }
      return base.merge(creation_view) unless @player

      enc = Eros.encounter_for(@player)
      busy = enc || @player.active_event? || @outcome == :defeat
      body =
        if enc then combat_view(enc)
        elsif @player.active_event? then event_view
        elsif @outcome == :defeat then defeat_view
        else screen_view
        end
      base.merge(status: status, nav: side_nav(busy)).merge(body)
    end

    SIDE_NAV = { 'profile' => 'Profile', 'hybrids' => 'Hybrids', 'shop' => 'Shop',
                 'cursed_shop' => 'Cursed Shop', 'parlour' => 'Parlour' }.freeze

    def side_nav(busy)
      SIDE_NAV.map do |screen, label|
        current = !busy && @screen == screen
        btn(label, 'nav', arg: current ? 'hub' : screen, style: current ? 'primary' : 'secondary', disabled: busy)
      end
    end

    def screen_view
      case @screen
      when 'submission' then submission_view
      when 'shop' then shop_view
      when 'cursed_shop' then cursed_shop_view
      when 'gear' then gear_view
      when 'levelup' then levelup_view
      when 'curses' then curses_view
      when 'profile' then profile_view
      when 'hybrids' then hybrids_view
      when 'parlour' then parlour_view
      when 'options' then options_view
      when 'settings' then settings_view
      else hub_view
      end
    end

    def render_log(entries)
      entries.map do |entry|
        scene = entry.is_a?(Hash) ? (entry[:scene] || entry['scene']) : nil
        scene ? { kind: 'scene', text: clean(scene) } : { kind: 'text', text: clean(entry.to_s) }
      end
    end

    # Discord-only bits in shared engine text: slash commands and timestamps.
    def clean(text)
      text.gsub(/\b([Tt]he) the\b/, '\1')
          .gsub(%r{`[/!]([a-z_]+)[^`]*`}) { "**#{SCREEN_FOR_COMMAND.fetch(::Regexp.last_match(1), ::Regexp.last_match(1))}**" }
          .gsub(/<t:\d+:[a-zA-Z]>/, 'soon')
    end

    def creation_view
      if !@draft['body']
        { title: 'Create your delver',
          sections: [{ text: 'Choose your body type. This shapes how the tower touches you.' }],
          actions: CharacterArchetypes::ALL.map { |id, a| [btn("#{a[:label]} (#{a[:blurb]})", 'pick_body', arg: id)] } +
                   [[btn('Import a save', 'import_prompt')]] }
      elsif !@draft['attitude']
        { title: 'How do you feel about submitting to monsters?',
          sections: [{ text: 'Submission makes monsters easier to satisfy. It is a lasting trait.' }],
          actions: CharacterArchetypes::SUBMISSION_CHOICES.map { |k, a| [btn(a[:text], 'pick_attitude', arg: k)] } +
                   [[btn('Back', 'back')]] }
      else
        { title: 'Name your delver',
          sections: [{ text: "-# #{Player::CHARACTER_NAME_LENGTH.min}–#{Player::CHARACTER_NAME_LENGTH.max} letters, " \
                             'numbers, spaces, apostrophes or hyphens.' }],
          input: { action: 'set_name', placeholder: 'Character name', label: 'Enter the tower' },
          actions: [[btn('Back', 'back')]] }
      end
    end

    def status
      p = @player
      threat = Engine::ThreatCalculator.calculate(p)
      {
        name: p.display_name, title: p.active_title_name, body: p.gender, level: p.level,
        cycle: p.current_cycle.to_i, floor: p.current_floor, deepest: p.highest_floor_reached.to_i,
        defiance: p.defiance, max_defiance: p.max_defiance, lust: p.lust, lust_max: Player::CLIMAX_THRESHOLD,
        lp: p.lp, strength: p.effective_strength, agility: p.effective_agility, resistance: p.effective_resistance,
        submission: p.effective_submission, curses: p.active_curse_count,
        threat: "#{threat.category.to_s.upcase} #{threat.percent.round}%",
        form: p.active_transformation_name,
        notes: status_notes
      }
    end

    def status_notes
      notes = @player.condition_list.reject { |c| c['key'] == Engine::Corruption::KEY }.map do |c|
        floors = c['floors'].to_i.positive? ? " (#{c['floors']} floors)" : ''
        "**#{c['name']}**#{floors}"
      end
      notes << clean(Engine::Corruption.status_line(@player).to_s) if Engine::Corruption.status_line(@player)
      notes << "Chastity: #{Engine::ChastitySystem.description(@player)}" if Engine::ChastitySystem.in_chastity?(@player)
      notes << 'Sanctuary: your next room is safe.' if @player.sanctuary
      notes
    end

    def back_row = [btn('Back', 'nav', arg: 'hub')]

    def hub_view
      wait = rest_ready_at - Time.now.to_i
      rest_label = wait.positive? ? "Rest (#{(wait / 60.0).ceil}m)" : 'Rest'
      { title: "Floor #{@player.current_floor}", actions: [
        [btn('Explore', 'explore', style: 'primary'), btn(rest_label, 'rest', disabled: wait.positive?),
         btn('Level Up', 'nav', arg: 'levelup', style: 'success')],
        [btn('Gear', 'nav', arg: 'gear'), btn("Curses (#{@player.active_curse_count})", 'nav', arg: 'curses'),
         btn('Options', 'nav', arg: 'options'), btn('Settings', 'nav', arg: 'settings')]
      ] }
    end

    def combat_view(enc)
      lines = ["**#{enc[:name]}** _(#{enc[:type_name]}#{enc[:is_boss] ? ' · Boss' : ''})_",
               "HP `#{enc[:hp]}/#{enc[:max_hp]}` · STR `#{enc[:strength]}` · AGI `#{enc[:agility]}` · " \
               "Lust hit `#{enc[:lust_damage]}`"]
      affix = Engine::Elites.affix(enc)
      lines << "-# Elite: #{affix[:name]}" if affix && affix[:name]
      colour = enc[:color] ? format('#%06x', enc[:color].to_i) : '#8b1a1a'

      phase = enc[:phase].to_s == 'pending' && Engine::BossFights.phase(enc[:name])
      actions =
        if phase
          [[btn(phase[:resist_label], 'resist', style: 'danger'), btn(phase[:give_label], 'give_in', style: 'primary')]]
        else
          [[btn('Fight', 'fight', style: 'danger'), btn('Flee', 'flee'), btn('Submit', 'submit', style: 'primary')]]
        end
      { title: enc[:is_boss] ? 'Boss fight' : 'Combat', enemy: { hp: enc[:hp], max_hp: enc[:max_hp], colour: colour },
        sections: [{ text: lines.join("\n") }], actions: actions }
    end

    def event_view
      data = @player.event_data
      title = data[:name] || 'Random Event'
      if data[:mode].to_s == 'choice'
        choices = Engine::RandomEvents.choices_for(@player, data)
        text = choices.map { |c| "• **#{c[:label]}** — #{c[:text]}" }.join("\n")
        buttons = choices.map do |c|
          btn(c[:label], 'event_choice', arg: c[:key], style: COLOURS.fetch(c[:style].to_s, 'secondary'),
                                         disabled: c[:disabled])
        end
        { title: title, sections: [{ text: clean(text) }], actions: buttons.each_slice(4).to_a }
      else
        { title: title, sections: [{ text: "-# Turn #{data[:turn].to_i}/#{data[:duration].to_i}" }],
          actions: [[btn('Continue', 'event_continue', style: 'primary')]] }
      end
    end

    def defeat_view
      { title: 'Broken', actions: [[btn('Continue', 'defeat_continue', style: 'primary')]] }
    end

    def submission_view
      { title: 'Submission',
        sections: [{ text: 'You lost all defiance and gave into your desires. The tower forever ravages you.' }],
        actions: [[btn('Try again', 'explore', style: 'primary'), btn('Back', 'nav', arg: 'hub')]] }
    end

    def stats_of(item)
      text = Engine::Treasure.format_stat_changes(item.stat_modifiers)
      text.to_s.empty? ? '' : "\n#{text}"
    end

    def shop_view
      tabs = Engine::Shop::CATEGORIES.map do |k|
        btn(Engine::Shop::CATEGORY_LABELS.fetch(k, k.capitalize), 'shop_cat', arg: k,
                                                                  style: k == @shop_cat ? 'primary' : 'secondary')
      end
      sections = Engine::Shop.stock_for(@shop_cat).map do |item|
        owned = item.type != 'special' && @player.owns_equipment?(item.id)
        { text: "**#{item.name}** — #{item.cost} LP#{owned ? ' _(owned)_' : ''}\n_#{item.description}_#{stats_of(item)}",
          actions: [btn(owned ? 'Owned' : "Buy (#{item.cost})", 'buy', arg: item.id, style: 'success',
                                                                disabled: owned || @player.lp < item.cost.to_i)] }
      end
      { title: "Shop — #{@player.lp} LP", sections: sections, actions: [tabs, back_row] }
    end

    def cursed_shop_view
      items = Engine::Treasure.all_mimic_templates.filter_map { |t| ::Equipment.first(name: t[:name]) }
      unlocked = @player.cursed_shop_unlocks
      sections = items.map do |item|
        if @player.owns_equipment?(item.id)
          { text: "◆ **#{item.name}** — _already bound to you_" }
        elsif unlocked.include?(item.name)
          { text: "◈ **#{item.name}** (#{item.slot}) — _#{item.description}_#{stats_of(item)}\n" \
                  "-# Free · removal #{item.removal_cost} LP",
            actions: [btn('Take it', 'cshop_take', arg: item.id, style: 'danger')] }
        else
          { text: "◇ ??? (#{item.slot}) — _find it in a chest, wear it, and tear it free to unlock_" }
        end
      end
      intro = { text: '_Living gear you have worn and torn free remembers you. Call it back for free; removing it ' \
                      "again costs its usual LP._\n-# Unlocked #{(unlocked & items.map(&:name)).size}/#{items.size}" }
      { title: 'Cursed Shop', sections: [intro] + sections, actions: [back_row] }
    end

    def gear_view
      items = @player.equipment.sort_by { |i| [@player.equipped?(i.name) ? 0 : 1, i.slot.to_s, i.name] }
      sections = items.map do |item|
        worn = @player.equipped?(item.name)
        tag = item.cursed ? ' _(living)_' : ''
        actions =
          if item.cursed
            [btn("Tear free (#{item.removal_cost} LP)", 'remove_cursed', arg: item.id, style: 'danger',
                                                         disabled: @player.lp < item.removal_cost.to_i)]
          elsif worn
            [btn('Unequip', 'unequip', arg: item.id)]
          else
            [btn('Equip', 'equip', arg: item.id, style: 'primary'),
             btn("Sell (#{[(item.cost.to_i * 0.5).round, 1].max})", 'sell', arg: item.id)]
          end
        { text: "#{worn ? '**Worn**' : 'Pack'} · #{item.slot}: **#{item.name}**#{tag}#{stats_of(item)}", actions: actions }
      end
      sections = [{ text: '_Your pack is empty._' }] if sections.empty?
      sections << { text: '-# Normal gear is lost when you are broken. Living gear stays until you tear it free.' }
      { title: 'Gear', sections: sections, actions: [back_row] }
    end

    def levelup_view
      rows = Player::UPGRADE_STATS.map do |s|
        cost = @player.stat_upgrade_cost(s)
        value = @player.public_send(s)
        btn("#{s.capitalize} #{value} → #{value + 1} (#{cost} LP)", 'levelup', arg: s, disabled: @player.lp < cost)
      end
      cost = @player.level_upgrade_cost
      next_max = Player.calculate_max_hp(@player.level + 1)
      { title: "Level up — #{@player.lp} LP",
        sections: [{ text: 'STR: damage. AGI: flee, dodge, traps and event escapes. RES: cuts every lust hit.' },
                   { text: "A level raises every stat by 1 and max defiance to about **#{next_max}**, fully restored." }],
        actions: [rows, [btn("Level #{@player.level + 1} (#{cost} LP)", 'levelup', arg: 'level', style: 'success',
                                                                       disabled: @player.lp < cost)], back_row] }
    end

    def curses_view
      remove = Player::CURSE_REMOVE_COST
      suppress = Player::CURSE_SUPPRESS_COST
      sections = @player.active_curses_ordered.each_with_index.map do |curse, i|
        type = Engine::CurseCatalog.type_label(Engine::CurseCatalog.type_for(curse.name))
        { text: "**#{curse.name}** _(#{type})_\n#{curse.description}",
          actions: [btn("Remove (#{remove} LP)", 'curse_remove', arg: i, style: 'danger', disabled: @player.lp < remove),
                    btn("Suppress (#{suppress} LP)", 'curse_suppress', arg: i, disabled: @player.lp < suppress)] }
      end
      sections = [{ text: '_You are free of curses, for now._' }] if sections.empty?
      held = @player.suppressed_curses.map(&:name)
      sections << { text: "-# Suppressed until you are broken: #{held.join(', ')}" } if held.any?
      { title: 'Curses', sections: sections, actions: [back_row] }
    end

    def profile_view
      tabs = [btn('Titles', 'tab', arg: 'titles', style: @tab.nil? || @tab == 'titles' ? 'primary' : 'secondary')] +
             Engine::TitleSystem::ACHIEVEMENT_CATEGORIES.map do |k, label|
               btn(label, 'tab', arg: k, style: @tab == k ? 'primary' : 'secondary')
             end
      sections = @tab.nil? || @tab == 'titles' ? title_sections : achievement_sections(@tab)
      done = @player.earned_achievements.size
      total = Engine::TitleSystem.visible_achievements(@player).size
      marks = Engine::Marks.profile_line(@player)
      summary = ["Title: **#{@player.active_title_name || 'none'}** · Achievements #{done}/#{total}",
                 "Deepest floor #{@player.highest_floor_reached} · Cycle #{@player.current_cycle}", marks].compact
      { title: "Profile — #{@player.display_name}", sections: [{ text: summary.join("\n") }] + sections,
        actions: tabs.each_slice(5).to_a + [back_row] }
    end

    def title_sections
      active = @player.active_title_key
      Engine::TitleSystem.visible_titles(@player).map do |key, t|
        if @player.earned_titles.include?(key)
          worn = key == active
          { text: "**#{t[:name]}**#{worn ? ' _(worn)_' : ''} — _#{t[:description]}_",
            actions: worn ? [] : [btn('Wear', 'title', arg: key, style: 'primary')] }
        else
          { text: "◇ **#{t[:name]}** — _#{t[:description]}_\n-# #{Engine::TitleSystem.progress_text(@player, t[:requirement])}" }
        end
      end
    end

    def achievement_sections(category)
      done = @player.earned_achievements
      list = Engine::TitleSystem.achievements_in(category, @player)
      return [{ text: '_Nothing here yet._' }] if list.empty?

      list.map do |a|
        reward = a.dig(:reward, :lp).to_i.positive? ? " · +#{a.dig(:reward, :lp)} LP" : ''
        if done.include?(a[:id])
          { text: "✓ **#{a[:name]}** — _#{a[:description]}_#{reward}" }
        else
          { text: "◇ **#{a[:name]}** — _#{a[:description]}_#{reward}\n" \
                  "-# #{Engine::TitleSystem.progress_text(@player, a[:requirement])}" }
        end
      end
    end

    def hybrids_view
      active = @player.active_transformation_key
      owned = @player.unlocked_transformations
      sections = Engine::TransformationSystem.visible(@player).map do |key, t|
        effects = Engine::TransformationSystem.effect_lines(t).map { |l| "• #{l}" }.join("\n")
        if key == active
          { text: "**#{t[:name]}** _(your form)_ — _#{t[:description]}_\n#{effects}",
            actions: [btn('Return to human', 'hybrid', arg: '')] }
        elsif owned.include?(key)
          { text: "**#{t[:name]}** — _#{t[:description]}_\n#{effects}",
            actions: [btn('Take this form', 'hybrid', arg: key, style: 'primary')] }
        else
          { text: "◇ **#{t[:name]}** — _#{t[:description]}_\n" \
                  "-# #{Engine::TitleSystem.progress_text(@player, t[:requirement])}" }
        end
      end
      sections = [{ text: '_No hybrid forms are within reach yet._' }] if sections.empty?
      { title: 'Hybrid Forms', sections: sections, actions: [back_row] }
    end

    def parlour_view
      owned = Engine::Marks.owned(@player)
      intro = { text: "_Vex's parlour smells of warm ink and sweet smoke. Every mark she makes stays through every " \
                      "run._\n-# Marks worn #{owned.size}/#{Engine::Marks::MAX_MARKS}" }
      worn = owned.map do |key|
        mark = Engine::Marks::MARKS[key]
        { text: "#{Engine::Marks.label(key)} — #{mark[:perk]}", actions: [btn('Remove', 'mark_remove', arg: key)] }
      end
      full = owned.size >= Engine::Marks::MAX_MARKS
      offers = Engine::Marks.available(@player).map do |key, mark|
        { text: "#{Engine::Marks.label(key)} — #{mark[:cost]} LP\n#{mark[:perk]}",
          actions: [btn("Get it (#{mark[:cost]})", 'mark_buy', arg: key, style: 'success',
                                                    disabled: full || @player.lp < mark[:cost])] }
      end
      { title: "Parlour — #{@player.lp} LP", sections: [intro] + worn + offers, actions: [back_row] }
    end

    def options_view
      prefs = Engine::ContentOptions.preferences_for(@player)
      sections = OPTION_GROUPS.map do |_, (title, keys)|
        { text: "**#{title}**",
          actions: keys.map do |k|
            p = Engine::ContentOptions.preference(k)
            btn("#{prefs[k] ? '✓ ' : ''}#{p[:label]}", 'pref', arg: k, style: prefs[k] ? 'success' : 'secondary')
          end }
      end
      Engine::ContentOptions.applicable_sizes(@player).each do |part, spec|
        chosen = Engine::ContentOptions.size_of(@player, part)
        sections << { text: "**#{spec[:label]} size**",
                      actions: spec[:options].map do |size|
                        btn(size.capitalize, 'size', arg: "#{part}:#{size}", style: size == chosen ? 'primary' : 'secondary')
                      end }
      end
      intro = { text: '_Choose what the tower may show you. Scenes touching disabled **core** themes are re-rolled or ' \
                      'toned down; **opt-in** themes add new random events when enabled._' }
      { title: 'Content Options', sections: [intro] + sections,
        actions: [[btn('Enable all', 'pref_all', arg: 'on'), btn('Disable all', 'pref_all', arg: 'off')], back_row] }
    end

    def settings_view
      t = ->(k) { @player.tracker(k) }
      lines = ["Monsters defeated **#{t['monsters_killed']}** · Submissions **#{t['submissions']}** · " \
               "Orgasms **#{t['total_climaxes']}**",
               "Bosses beaten **#{t['bosses_defeated']}** · Floors cleared **#{t['floors_cleared']}** · " \
               "LP earned **#{t['lp_earned']}**",
               "Chests opened **#{t['treasure_found']}** · left closed **#{t['chests_ignored']}**"]
      restart = @confirm == :restart
      delete = @confirm == :delete_save
      notes = '-# **Restart** erases this delver but keeps titles, achievements, records and options. ' \
              '**Delete save** erases everything. Your save lives in this browser only; use **Export save** to ' \
              'back it up or move it to another device.'
      { title: 'Settings & stats', sections: [{ text: lines.join("\n") }, { text: notes }],
        actions: [[btn('Export save', 'export_save', style: 'primary'), btn('Import save', 'import_prompt')],
                  [btn(restart ? 'Restart (press again)' : 'Restart', 'restart', style: 'danger'),
                   btn(delete ? 'Delete save (press again)' : 'Delete save', 'delete_save', style: 'danger')],
                  back_row] }
    end
  end
end
