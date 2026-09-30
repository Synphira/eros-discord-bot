# frozen_string_literal: true

require 'json'

class Curse < Sequel::Model(:curses)
  CATEGORIES = %w[
    Viscous
    Infernal
    Wild
    Abyssal
    Botanical
    Necrotic
    Mimetic
  ].freeze

  plugin :timestamps, update_on_create: true

  many_to_many :players,
               left_key: :curse_id,
               right_key: :player_id,
               join_table: :player_curses

  plugin :validation_helpers

  def validate
    super
    validates_presence %i[name category]
    validates_includes CATEGORIES, :category
  end

  def stat_modifiers
    JSON.parse(stat_modifier_json || '{}')
  rescue JSON::ParserError
    {}
  end

  def stat_modifiers=(hash)
    self.stat_modifier_json = JSON.generate(hash || {})
  end
end
