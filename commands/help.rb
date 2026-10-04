# frozen_string_literal: true

module Commands
  module Help
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    COLOUR = 0x6b5b95
    SUPPORT_URL = 'https://discord.gg/fXWCsyCUyU'

    # [slash, prefix, description]; slash nil = prefix only.
    PAGES = {
      'start' => {
        label: 'Getting Started', emoji: '🗝️', blurb: 'Create, view and restart your delver',
        commands: [
          ['/create · /start', 'e,create · e,start', 'Create your delver: body type, submission stance and name'],
          ['/status', 'e,status', 'Character sheet: stats, deepest floor and Threat'],
          ['/name', 'e,name [name]', 'Set or change your character name'],
          ['/restart', 'e,restart', 'New delver and body type; titles, achievements and progress are kept'],
          ['/help', 'e,help', 'This menu']
        ]
      },
      'explore' => {
        label: 'Exploring & Combat', emoji: '⚔️', blurb: 'Explore, fight, rest and level up',
        commands: [
          ['/explore', 'e,explore', 'Enter the next room: monster, trap, chest, event or stairs'],
          ['/fight · /flee · /submit', 'e,fight · e,flee · e,submit', 'Combat actions (also buttons)'],
          ['/rest', 'e,rest', 'Clear all lust and fully restore defiance, once every 5 minutes'],
          ['/levelup', 'e,levelup [stat|level]', 'Spend LP on STR, AGI, RES or a whole level']
        ]
      },
      'curses' => {
        label: 'Curses', emoji: '🩸', blurb: 'View, remove and suppress curses',
        commands: [
          ['/curses', 'e,curses', 'Your active curses by monster type'],
          ['/removecurse', 'e,removecurse [N]', 'Remove a curse for 50 LP'],
          ['/suppresscurse', 'e,suppresscurse [N]', 'Silence a curse for 25 LP until your next defeat']
        ]
      },
      'gear' => {
        label: 'Gear & Shops', emoji: '🛍️', blurb: 'Shop, equipment, living gear and the parlour',
        commands: [
          ['/shop', 'e,shop [category]', 'Browse the shop by category'],
          ['/buy · /sell', 'e,buy [item] · e,sell [item]', 'Buy a shop item or sell normal gear by name'],
          ['/equipment', 'e,equipment', 'Your gear, trophy and inventory'],
          ['/equip · /unequip', 'e,equip [item] · e,unequip [item]', 'Wear or take off gear (one trophy at a time)'],
          ['/remove', 'e,remove [item]', 'Tear off living gear for LP'],
          ['/cursedshop', 'e,cursedshop', 'Take back living gear you have torn free before, for free'],
          ['/parlour', 'e,parlour', 'Permanent tattoos and piercings with small perks']
        ]
      },
      'progress' => {
        label: 'Progress', emoji: '🏆', blurb: 'Profile, titles, achievements, hybrids, leaderboard',
        commands: [
          ['/profile', 'e,profile [name]', 'Your profile and lifetime stats, or look up another delver'],
          ['/titles · /title', 'e,titles · e,title [name|auto]', 'View and wear earned titles'],
          ['/achievements', 'e,achievements [category]', 'Achievements by category'],
          ['/transformation', 'e,transformation [name|clear]', 'Hybrid forms: take one or return to human'],
          ['/leaderboard', 'e,leaderboard [cycles|depth|kills|lp]', 'Top delvers']
        ]
      },
      'options' => {
        label: 'Content Options', emoji: '🎚️', blurb: 'Choose which themes the tower shows you',
        commands: [
          ['/options', 'e,options', 'Content toggles and body sizes'],
          ['/fetish_options', 'e,fetish_options [option] [on/off]', 'Toggle one theme (no arguments lists them all)'],
          [nil, 'e,sluttify [on/off]', 'Turn every theme on or off at once']
        ]
      }
    }.freeze

    TUTORIAL = <<~TEXT.strip
      **1. Create a delver.** Use `/create`, pick a body type and how willing you are to submit, then name yourself.
      **2. Explore.** `/explore` opens the next room: a monster, a trap, a treasure chest, an event, or the stairs down.
      **3. Fight, flee or submit.** Beating a monster earns **Lust Points (LP)**. Fleeing depends on Agility. Submitting can satisfy it for LP, but your lust rises.
      **4. Watch your Defiance.** Defiance is your will to resist. Lust builds with every hit, and an orgasm at 100 lust drains Defiance. At 0 you are **broken**: back to floor 1 at level 1, with a new curse.
      **5. Spend your LP.** Grow stronger in `/levelup`, buy gear in `/shop`, remove curses, or get marks in `/parlour`.
      **6. Rest.** `/rest` clears your lust and restores Defiance once every 5 minutes.
      **7. Go deeper.** A boss waits every 5 floors, and the Tower Lord rules floor 35. Clear the tower to start a harder cycle with bigger rewards.
      **8. Make it yours.** Turn themes on or off any time in `/options`.
    TEXT

    module_function

    def command_lines(page)
      PAGES.fetch(page)[:commands].map do |slash, prefix, desc|
        head = slash ? "**#{slash}** · `#{prefix}`" : "`#{prefix}` _(prefix only)_"
        "#{head}\n#{desc}"
      end.join("\n\n")
    end

    def run(event, page: 'start', ephemeral: false)
      owner = event.user.id
      ErosUI.reply_v2(event, colour: COLOUR, ephemeral: ephemeral) do |c|
        if page == 'tutorial'
          c.text_display(content: "## How to Play\n#{TUTORIAL}")
        else
          spec = PAGES.fetch(page)
          c.text_display(content: "## #{spec[:emoji]} #{spec[:label]}")
          c.text_display(content: command_lines(page))
        end
        c.separator(divider: true, spacing: :small)
        c.row do |row|
          row.string_select(custom_id: "eros:help:page:#{owner}", placeholder: 'Browse commands…',
                            min_values: 1, max_values: 1) do |menu|
            PAGES.each do |key, spec|
              menu.option(label: spec[:label], value: key, description: spec[:blurb],
                          emoji: { name: spec[:emoji] }, default: key == page)
            end
          end
        end
        c.row do |row|
          row.button(label: 'Tutorial', style: :primary, emoji: { name: '📖' }, custom_id: "eros:help:tutorial:#{owner}",
                     disabled: page == 'tutorial')
          row.button(label: 'Support', style: :link, emoji: { name: '💬' }, url: SUPPORT_URL)
        end
        c.text_display(content: '-# Every slash command also works with the `e,` prefix, like `e,explore`.')
      end
    end

    # Someone else's panel: give them their own private copy instead of changing it.
    def show_from_component(event, page)
      own = ErosHelpers.button_owner_id(event.custom_id) == event.user.id
      run(event, page: page, ephemeral: !own)
    end

    string_select(custom_id: /^eros:help:page:\d+$/) do |event|
      page = Array(event.values).first.to_s
      Commands::Help.show_from_component(event, PAGES.key?(page) ? page : 'start')
    end

    button(custom_id: /^eros:help:tutorial:\d+$/) do |event|
      Commands::Help.show_from_component(event, 'tutorial')
    end

    application_command(:help) { |event| Commands::Help.run(event) }

    command(:help, description: 'Commands, tutorial and support') do |event|
      Commands::Help.run(event)
      nil
    end
  end
end
