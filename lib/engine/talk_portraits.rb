# frozen_string_literal: true

module Engine
  # Pixel portraits shown at the top of a character's Talk panel.
  # Files live in assets/talk and are uploaded with the message, so the
  # panel never depends on an expiring Discord CDN link.
  module TalkPortraits
    DIR = File.expand_path('../../assets/talk', __dir__)

    # Talk person key → filename. Fang's portrait is the Cartographer.
    FILES = {
      'alpha' => 'alpha.png',
      'berry' => 'berry.png',
      'broodmother' => 'broodmother.png',
      'cartographer' => 'cartographer.png',
      'covar' => 'covar.png',
      'dryad' => 'dryad.png',
      'eros' => 'eros.png',
      'king' => 'king.png',
      'lich' => 'lich.png',
      'nectar' => 'nectar.png',
      'pip' => 'pip.png',
      'queen' => 'queen.png',
      'syn' => 'syn.png',
      'vex' => 'vex.png'
    }.freeze

    module_function

    def path_for(person)
      name = FILES[person.to_s]
      return nil unless name

      path = File.join(DIR, name)
      File.file?(path) ? path : nil
    end

    def url_for(person)
      path = path_for(person)
      path ? "attachment://#{File.basename(path)}" : nil
    end
  end
end
