# frozen_string_literal: true

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

  SUBMISSION_CHOICES = {
    'eager' => {
      value: 3,
      label: 'Eager',
      text: 'Eagerly submit — I want to be taken by monsters (+3 Submission)'
    },
    'curious' => {
      value: 1,
      label: 'Curious',
      text: 'Curious but open — I might submit if the monster is appealing (+1 Submission)'
    },
    'neutral' => {
      value: 0,
      label: 'Neutral',
      text: "Neutral — I'll decide based on the situation (0 Submission)"
    },
    'reluctant' => {
      value: -1,
      label: 'Reluctant',
      text: "Reluctant — I'll only submit if absolutely necessary (−1 Submission)"
    },
    'resistant' => {
      value: -3,
      label: 'Resistant',
      text: "Very resistant — I'll fight back with all I've got (−3 Submission)"
    }
  }.freeze

  module_function

  def fetch(id)
    ALL[id.to_i]
  end

  def submission_value(choice)
    key = choice.to_s.downcase
    key = 'eager' if key == 'willing'
    key = 'curious' if key == 'open'
    entry = SUBMISSION_CHOICES[key]
    entry ? entry[:value] : 0
  end

  def submission_label(value)
    SUBMISSION_CHOICES.each_value do |entry|
      return entry[:label] if entry[:value] == value.to_i
    end
    value.to_i.zero? ? 'Neutral' : value.to_s
  end

  def menu_text
    lines = ALL.map { |id, a| "**#{id}.** #{a[:label]} _(#{a[:blurb]})_" }
    <<~TEXT.strip
      ## Character Creation
      Select your body type. This shapes how the dungeon marks you.

      #{lines.join("\n")}
    TEXT
  end

  def submission_question
    {
      question: 'How do you feel about submitting to monsters?',
      options: SUBMISSION_CHOICES.map { |key, entry| { key: key, text: entry[:text] } }
    }
  end

  def submission_menu_text
    q = submission_question
    lines = q[:options].each_with_index.map { |opt, i| "**#{i + 1}.** #{opt[:text]}" }
    <<~TEXT.strip
      ## #{q[:question]}

      #{lines.join("\n")}
    TEXT
  end
end
