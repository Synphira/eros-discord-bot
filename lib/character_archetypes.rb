# frozen_string_literal: true

# Canonical body-type archetypes for character creation.
module CharacterArchetypes
  ALL = {
    1 => {
      label: 'Male',
      gender: 'Male',
      body_parts: %w[penis anus],
      blurb: 'penis, anus'
    },
    2 => {
      label: 'Male (FtM)',
      gender: 'Male (FtM)',
      body_parts: %w[vagina anus],
      blurb: 'vagina, anus'
    },
    3 => {
      label: 'Female',
      gender: 'Female',
      body_parts: %w[vagina anus breasts],
      blurb: 'vagina, anus, breasts'
    },
    4 => {
      label: 'Female (MtF)',
      gender: 'Female (MtF)',
      body_parts: %w[penis anus breasts],
      blurb: 'penis, anus, breasts'
    },
    5 => {
      label: 'Hermaphrodite',
      gender: 'Hermaphrodite',
      body_parts: %w[penis vagina anus breasts],
      blurb: 'penis, vagina, anus, breasts'
    }
  }.freeze

  module_function

  def fetch(id)
    ALL[id.to_i]
  end

  def menu_text
    lines = ALL.map { |id, a| "**#{id}.** #{a[:label]} _(#{a[:blurb]})_" }
    <<~TEXT.strip
      ## Character Creation
      Select your body type. This shapes how the dungeon marks you.

      #{lines.join("\n")}
    TEXT
  end
end
