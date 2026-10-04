# frozen_string_literal: true

# In-memory catalogue rows for equipment and curses. A record's id is its
# name, so saves stay valid no matter what order the catalogue loads in.
class WebRecord
  class << self
    def registry
      @registry ||= {}
    end

    def find_or_create(name:)
      record = registry[name]
      return record if record

      record = new(name: name)
      yield record if block_given?
      registry[name] = record
    end

    def create(attrs)
      record = new(attrs)
      registry[record.name] = record
    end

    def first(name: nil) = registry[name.to_s]
    def [](id) = registry[id.to_s]
    def all = registry.values

    def where(**conditions)
      rows = registry.values.select do |r|
        conditions.all? { |k, v| v.is_a?(Array) ? v.include?(r[k]) : r[k] == v }
      end
      WebDataset.new(rows)
    end
  end

  def initialize(attrs = {})
    @attrs = { 'cursed' => false, 'removal_cost' => 0, 'cost' => 0, 'rarity' => 1, 'stat_modifiers' => {} }
    update(attrs)
  end

  def id = name
  def name = @attrs['name']
  def [](key) = @attrs[key.to_s]

  def stat_modifiers = @attrs['stat_modifiers'] || {}

  def stat_modifiers=(hash)
    @attrs['stat_modifiers'] = JSON.parse(JSON.generate(hash || {}))
  end

  def stat_modifier_json=(json)
    self.stat_modifiers = JSON.parse(json.to_s.empty? ? '{}' : json)
  end

  def update(attrs)
    attrs.each { |k, v| public_send("#{k}=", v) }
    self
  end

  def save_changes = self

  COLUMNS = %w[name type slot description cost rarity cursed violation_type removal_cost category].freeze

  def method_missing(name, *args)
    key = name.to_s.chomp('=')
    return super unless COLUMNS.include?(key)

    name.to_s.end_with?('=') ? (@attrs[key] = args.first) : @attrs[key]
  end

  def respond_to_missing?(name, include_private = false)
    COLUMNS.include?(name.to_s.chomp('=')) || super
  end
end

# The handful of dataset calls the engine makes on owned rows.
class WebDataset
  include Enumerable

  def initialize(rows)
    @rows = rows
  end

  def each(&) = @rows.each(&)
  def all = @rows.dup
  def count = @rows.size
  def any? = !@rows.empty?
  def select_map(*) = @rows.map(&:name)
end

class Equipment < WebRecord; end
class Curse < WebRecord; end
