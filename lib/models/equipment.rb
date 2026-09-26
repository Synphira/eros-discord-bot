# frozen_string_literal: true

require 'json'

class Equipment < Sequel::Model(:equipment)
  EQUIPMENT_TYPES = %w[weapon armor accessory special].freeze

  plugin :timestamps, update_on_create: true

  many_to_many :players,
               left_key: :equipment_id,
               right_key: :player_id,
               join_table: :player_equipment

  plugin :validation_helpers

  def validate
    super
    validates_presence %i[name type slot]
    validates_includes EQUIPMENT_TYPES, :type
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
