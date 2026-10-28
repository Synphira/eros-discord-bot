# frozen_string_literal: true

# Offline TTK / climax-pressure probe for the combat rebalance.
# Run: ruby tools/balance_combat.rb
# Or:  bundle exec rake balance:combat

require_relative '../lib/engine/tower'
require_relative '../lib/engine/combat_engine'

module BalanceCombat
  module_function

  STR_SOFT = Engine::CombatEngine::STR_SOFT
  LINEAR = Engine::CombatEngine::LINEAR_STR_SHARE
  AGI_CAP = Engine::CombatEngine::AGI_CUT_CAP
  LUST_FLOOR = Engine::CombatEngine::LUST_HIT_FLOOR

  def strike(str)
    Engine::CombatEngine.strike_power(str)
  end

  def threat_stat_mult(threat_pct)
    pct = threat_pct.to_f
    mult = 0.85 + (pct * 0.0075)
    floor = if pct < 40
              0.85
            elsif pct < 75
              1.0
            else
              1.25
            end
    [mult, floor].max.clamp(0.85, 1.85)
  end

  def threat_lust_mult(threat_pct)
    pct = threat_pct.to_f
    mult = 0.9 + (pct * 0.01)
    floor = if pct < 40
              0.9
            elsif pct < 75
              1.05
            else
              1.35
            end
    [mult, floor].max.clamp(0.9, 2.25)
  end

  def hallway(floor:, level:, threat_pct:, cycle:)
    f = floor.to_i
    base_hp = 20 + (f * 5)
    base_lust = 7 + f
    base_agi = 1 + (f / 3)
    sm = threat_stat_mult(threat_pct)
    lm = threat_lust_mult(threat_pct)
    cy = Engine::Tower.cycle_multiplier(cycle)
    lh = Engine::Tower.delver_hp_mult(level)
    {
      hp: [(base_hp * sm * cy * lh).round, 8].max,
      lust: [(base_lust * lm * cy).round, 1].max,
      agi: [(base_agi * sm * cy).round, 1].max
    }
  end

  def boss_hp(base_hp:, level:, threat_pct:, cycle:)
    sm = threat_stat_mult(threat_pct)
    cy = Engine::Tower.cycle_multiplier(cycle)
    lh = Engine::Tower.delver_hp_mult(level)
    [(base_hp * sm * cy * lh).round, 20].max
  end

  def damage(str:, monster_agi:)
    s = strike(str)
    cut = [monster_agi / 2.0, s * AGI_CAP].min
    [(s - cut).round, 1].max
  end

  def lust_hit(raw_lust:, res:, sub:)
    factor = 100.0 / (100 + (res * 3.5))
    base = (raw_lust * factor).round
    floor = [(raw_lust * LUST_FLOOR).ceil, 1].max
    hit = [base, floor].max
    mult = if sub.negative?
             1.0 + (sub * (0.15 / 3.0))
           elsif sub.positive?
             1.0 + (sub * (0.25 / 3.0))
           else
             1.0
           end
    mult = mult.clamp(0.75, 1.45)
    [(hit * mult).round, 1].max
  end

  def ttk(hp, dmg)
    return Float::INFINITY if dmg <= 0

    (hp.to_f / dmg).ceil
  end

  def turns_to_climax(lust_per_hit, from_lust: 0)
    need = 100 - from_lust
    return 0 if need <= 0
    return Float::INFINITY if lust_per_hit <= 0

    (need.to_f / lust_per_hit).ceil
  end

  def row(label, str:, res:, sub:, floor:, level:, threat:, cycle:, boss_base: nil)
    if boss_base
      agi = [(12 * threat_stat_mult(threat) * Engine::Tower.cycle_multiplier(cycle)).round, 1].max
      hp = boss_hp(base_hp: boss_base, level: level, threat_pct: threat, cycle: cycle)
      lust = [(35 * threat_lust_mult(threat) * Engine::Tower.cycle_multiplier(cycle)).round, 1].max
    else
      m = hallway(floor: floor, level: level, threat_pct: threat, cycle: cycle)
      hp = m[:hp]
      lust = m[:lust]
      agi = m[:agi]
    end
    dmg = damage(str: str, monster_agi: agi)
    lh = lust_hit(raw_lust: lust, res: res, sub: sub)
    t = ttk(hp, dmg)
    c0 = turns_to_climax(lh, from_lust: 0)
    c50 = turns_to_climax(lh, from_lust: 50)
    climax_in_fight = t < Float::INFINITY && c0 <= t
    format(
      '%-28s STR=%-4d RES=%-4d Sub=%+-3d | HP=%-5d dmg=%-3d TTK=%-3s | lust/hit=%-3d climax@0=%-3s @50=%-3s %s',
      label, str, res, sub, hp, dmg, t == Float::INFINITY ? '∞' : t.to_s, lh,
      c0 == Float::INFINITY ? '∞' : c0.to_s,
      c50 == Float::INFINITY ? '∞' : c50.to_s,
      climax_in_fight ? 'CLIMAX' : ''
    )
  end

  def report
    puts "STR_SOFT=#{STR_SOFT} LINEAR=#{LINEAR} AGI_CUT_CAP=#{AGI_CAP} LUST_FLOOR=#{LUST_FLOOR}"
    [20, 100, 200, 400, 455].each do |s|
      print "strike(#{s})=#{strike(s).round(1)}  "
    end
    puts
    puts
    samples = [
      ['Early F10 C1 T20 Lv10', { str: 14, res: 14, sub: 0, floor: 10, level: 10, threat: 20, cycle: 1 }],
      ['Early Resistant', { str: 14, res: 14, sub: -3, floor: 10, level: 10, threat: 20, cycle: 1 }],
      ['Mid F27 C1 T55 Lv50', { str: 54, res: 54, sub: 0, floor: 27, level: 50, threat: 55, cycle: 1 }],
      ['High F27 C4 T55 Lv200', { str: 204, res: 204, sub: 0, floor: 27, level: 200, threat: 55, cycle: 4 }],
      ['Syn-band F27 C7 T56', { str: 455, res: 488, sub: -3, floor: 27, level: 438, threat: 56, cycle: 7 }],
      ['Syn-band Eager', { str: 455, res: 488, sub: 3, floor: 27, level: 438, threat: 56, cycle: 7 }],
      ['Syn F35 C7 T56', { str: 455, res: 488, sub: -3, floor: 35, level: 438, threat: 56, cycle: 7 }],
      ['Eros C7 T56 Resistant', { str: 455, res: 488, sub: -3, floor: 35, level: 438, threat: 56, cycle: 7,
                                  boss_base: 260 }],
      ['Eros C1 T80', { str: 404, res: 404, sub: 0, floor: 35, level: 400, threat: 80, cycle: 1,
                        boss_base: 260 }]
    ]
    samples.each { |label, opts| puts row(label, **opts) }
  end
end

BalanceCombat.report if $PROGRAM_NAME == __FILE__
