# frozen_string_literal: true

require 'json'
require 'set'

# Just enough of Sequel for the bot's model files to load in the browser.
# Rows live in plain hashes; the web Player saves them to localStorage.
class WebModel
  class << self
    %i[plugin set_primary_key unrestrict_primary_key many_to_many one_to_many many_to_one].each do |name|
      define_method(name) { |*_args, **_opts| nil }
    end

    def create(attrs = {})
      new(attrs)
    end

    def columns
      const_defined?(:WEB_DEFAULTS) ? self::WEB_DEFAULTS.keys : []
    end

    def serialized
      const_defined?(:WEB_SERIALIZED) ? self::WEB_SERIALIZED : []
    end
  end

  attr_reader :values

  def initialize(attrs = {})
    @values = {}
    defaults = self.class.const_defined?(:WEB_DEFAULTS) ? self.class::WEB_DEFAULTS : {}
    defaults.each { |k, v| @values[k] = v.is_a?(Array) || v.is_a?(Hash) ? JSON.parse(JSON.generate(v)) : v }
    attrs.each { |k, v| @values[k.to_sym] = v }
  end

  def [](key)
    @values[key.to_sym]
  end

  def []=(key, value)
    write_value(key.to_sym, value)
  end

  def update(attrs)
    attrs.each { |k, v| write_value(k.to_sym, v) }
    self
  end

  def refresh = self
  def reload = self
  def save = self
  def save_changes = self
  def valid? = true

  def method_missing(name, *args)
    key = name.to_s
    if key.end_with?('=') && args.size == 1
      write_value(key.chomp('=').to_sym, args.first)
    elsif args.empty? && (@values.key?(name) || self.class.columns.include?(name))
      @values[name]
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    key = name.to_s.chomp('=').to_sym
    @values.key?(key) || self.class.columns.include?(key) || super
  end

  private

  # Serialized columns round-trip through JSON like Sequel's serialization
  # plugin, so symbol keys come back as strings exactly as after a DB reload.
  def write_value(key, value)
    if self.class.serialized.include?(key) && (value.is_a?(Array) || value.is_a?(Hash))
      value = JSON.parse(JSON.generate(value))
    end
    @values[key] = value
  end
end

module Sequel
  class UniqueConstraintViolation < StandardError; end

  # Stand-in for Sequel[:table][:column] in the few select_map calls that
  # the web datasets answer without looking at the column.
  class Identifier
    def [](_column) = self
  end

  def self.Model(_table) = WebModel
  def self.[](*) = Identifier.new
end

module Engine
  # Single player: no weekly rotation.
  module Weekly
    MODIFIERS = {}.freeze

    module_function

    def effects(*)
      {}
    end

    def special(*) = 1.0
    def monster_weight(*) = 1.0
    def status_line(*) = nil
    def current(*) = nil
  end

  # No developer or bug-tester tools in the web build.
  module Dev
    DEBUG = Set.new

    module_function

    def owner?(*) = false
    def bug_tester?(*) = false
    def developer?(*) = false
    def debug?(*) = false
    def toggle_debug!(*) = false
  end
end
