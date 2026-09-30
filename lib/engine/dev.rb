# frozen_string_literal: true

require 'set'

module Engine
  module Dev
    DEBUG = Set.new

    module_function

    def bug_tester_ids
      ENV.fetch('BUG_TESTER_IDS', '').split(/[\s,]+/).grep(/\A\d+\z/).map(&:to_i)
    end

    def developer_id
      raw = ENV.fetch('DEVELOPER_ID', '').strip
      raw.match?(/\A\d+\z/) ? raw.to_i : nil
    end

    def owner?(user_id)
      id = developer_id
      !id.nil? && user_id.to_i == id
    end

    def bug_tester?(user_id)
      bug_tester_ids.include?(user_id.to_i)
    end

    def developer?(user_id)
      owner?(user_id) || bug_tester?(user_id)
    end

    def debug?(player)
      return false unless player

      id = player.respond_to?(:discord_id) ? player.discord_id : player
      developer?(id) && DEBUG.include?(id.to_i)
    end

    def toggle_debug!(user_id)
      return false unless developer?(user_id)

      if DEBUG.include?(user_id.to_i)
        DEBUG.delete(user_id.to_i)
        false
      else
        DEBUG << user_id.to_i
        true
      end
    end
  end
end
