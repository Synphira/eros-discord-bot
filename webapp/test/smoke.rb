# frozen_string_literal: true

# Plays the game headlessly under plain Ruby, pressing random buttons.
#   ruby webapp/test/smoke.rb [steps] [seed]
require_relative 'boot'

steps = (ARGV[0] || 3000).to_i
srand((ARGV[1] || 42).to_i)
call = lambda do |action, arg = nil, value = nil|
  view = JSON.parse(Eros::Bridge.handle(JSON.generate(action: action, arg: arg, value: value)))
  abort "#{action}(#{arg.inspect}): #{view['error']}\n#{view['backtrace']&.join("\n")}" if view['error']
  view
end

call.('init')
call.('pick_body', 5)
call.('pick_attitude', 'curious')
view = call.('set_name', nil, 'Smoke Tester')
abort "creation failed: #{view}" unless view['status']
view = call.('pref_all', 'on')

LEAN = %w[explore fight event_choice event_continue resist give_in buy levelup equip defeat_continue].freeze
seen = Hash.new(0)
deepest = 0
steps.times do
  buttons = (view['actions'] || []).flatten + (view['sections'] || []).flat_map { |s| s['actions'] || [] } +
            (view['nav'] || [])
  buttons.reject! { |b| b['disabled'] || %w[restart delete_save pref_all pref size].include?(b['action']) }
  pick = buttons.flat_map { |b| LEAN.include?(b['action']) ? [b] * 6 : [b] }.sample
  view = call.(pick['action'], pick['arg'])
  seen[pick['action']] += 1
  deepest = [deepest, view.dig('status', 'floor').to_i].max
end

reloaded = Eros::Game.new(Eros::Bridge.read_save)
abort 'save did not reload' unless reloaded.player&.display_name == 'Smoke Tester'
p = reloaded.player

code = call.('export_save')['export']
abort 'export code missing' unless code&.start_with?('EROS1:')
abort 'garbage import should fail' unless call.('import_save', nil, 'hello')['import_prompt']
abort 'damaged import should fail' unless call.('import_save', nil, "#{code[0, 40]}!!")['import_prompt']
lp_before = Eros::Bridge.game.player.lp
call.('import_save', nil, code.scan(/.{1,60}/).join("\n"))
abort 'import lost the delver' unless Eros::Bridge.game.player.lp == lp_before

call.('restart')
view = call.('restart')
abort 'restart should return to creation' if view['status']
titles = p.earned_titles.size
call.('pick_body', 1)
call.('pick_attitude', 'neutral')
call.('set_name', nil, 'Second Delver')
again = Eros::Bridge.game.player
abort 'restart lost titles' unless again.earned_titles.size == titles

puts "OK after #{steps} steps (deepest floor #{deepest})"
puts "actions: #{seen.sort_by { -_2 }.map { |k, v| "#{k}=#{v}" }.join(' ')}"
puts "level #{p.level} · lp #{p.lp} · curses #{p.active_curse_count} · gear #{p.equipment.size} · " \
     "titles #{titles} · achievements #{p.earned_achievements.size} · forms #{p.unlocked_transformations.size} · " \
     "conditions #{p.condition_list.size}"
