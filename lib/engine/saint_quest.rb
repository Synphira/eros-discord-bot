# frozen_string_literal: true

module Engine
  # Hidden story on the Drowned Saint. Not listed on the quest board, and
  # she is not a Talk person. Glass lines 1–4 are the real copy. Everything
  # after the glass is placeholder until it is rewritten.
  module SaintQuest
    GLASS = [
      nil,
      "Seems she won't talk to you.",
      'She looks at you from behind the glass.',
      'She leans against the glass watching you...',
      'It looks like she might want to talk to you next time...',
      'She speaks, and the water does not. "Tell the inked one I am sorry I frightened her. ' \
      'Do not use my name. Bring her to the glass, and I will say the rest myself."'
    ].freeze

    CLERGY = {
      'Succubus Queen' => 'The Queen does not gloat. She looks past you, toward a stool that should not be empty, and says nothing you can use.',
      'Verdant Dryad' => 'The Dryad listens to the roots and winces. Something small and sharp is missing from the parlour, and the green knows it.',
      'Lich Lord' => 'The Lich turns a page that is not there. "The stitcher is not in her stitches," he says, and closes the book on you.',
      'Alpha Beast' => 'The Alpha scents the air, growls once at the dark water on you, and will not meet your eyes.'
    }.freeze

    module_function

    def syn_gone?(player)
      player.tracker('syn_taken').positive? && !player.tracker('saint_quest_done').positive?
    end

    def band(player)
      depth = player.tracker('saint_depth')
      return 0 if depth <= 0
      return 1 if depth <= 2

      2
    end

    # Added to the Sin's lust hit. +0.05 per depth, never more than +0.20.
    def lust_bonus(player)
      [player.tracker('saint_depth') * 0.05, 0.20].min
    end

    def forced_relic(player)
      return nil if player.tracker('saint_quest_done').positive?
      return 'drowned_saint' if player.tracker('saint_quest_step') == 4 && !player.tracker('syn_taken').positive?
      return nil unless syn_gone?(player)
      return 'drowned_sin' unless player.tracker('saint_cracked').positive?
      return 'drowned_sin' if errands_done?(player)

      nil
    end

    def errands_done?(player)
      player.tracker('saint_needle').positive? &&
        player.tracker('saint_thread').positive? &&
        player.tracker('saint_warmth').positive?
    end

    def glass_pending?(player)
      step = player.tracker('saint_glass_step')
      step < 5 && player.tracker('drowned_saint_defeats') > step
    end

    def offer(player, enc, allow_pull:)
      relic = (enc[:relic] || enc['relic']).to_s
      if relic == 'drowned_saint' && player.tracker('saint_meeting_due').positive?
        return { action: 'taking', label: 'Talk' }
      end
      if relic == 'drowned_saint' && glass_pending?(player)
        return { action: 'glass', label: 'Talk' }
      end
      if allow_pull && relic == 'drowned_sin' && player.tracker('saint_pull_due').positive?
        return { action: 'pull', label: 'Reach for her' }
      end

      nil
    end

    def press!(player, action)
      case action.to_s
      when 'glass' then press_glass!(player)
      when 'taking' then press_taking!(player)
      when 'pull' then press_pull!(player)
      when 'needle' then press_needle!(player)
      when 'thread' then press_thread!(player)
      when 'apology' then press_apology!(player)
      when 'stool' then stool_line(player)
      else 'There is nothing at the glass.'
      end
    end

    def note_fight!(player, enc, log, satisfied:)
      relic = (enc[:relic] || enc['relic']).to_s
      name = Engine::BossFights.canonical_name(enc[:name].to_s)

      if relic == 'drowned_saint' && player.tracker('saint_glass_step') < 5
        player.bump_tracker!('drowned_saint_defeats')
      end
      if relic == 'drowned_saint' && player.tracker('saint_quest_step') == 4
        player.set_tracker!('saint_meeting_due', 1)
      end

      if player.tracker('saint_quest_step') == 2 && !satisfied &&
         player.tracker('bosses_defeated') > player.tracker('saint_quest_start')
        player.set_tracker!('saint_quest_step', 3)
        log << '_The threshold stays behind you. She can be told, now, that someone below wants to apologize._'
      end

      return unless syn_gone?(player)

      if (line = CLERGY[name])
        log << "_#{line}_"
      end

      return unless relic == 'drowned_sin'

      if satisfied
        player.set_tracker!('saint_yielded', 1)
        player.set_tracker!('saint_pull_due', 0)
        deepen!(player)
        log << depth_satisfy_line(player)
      else
        player.set_tracker!('saint_yielded', 0)
        if !player.tracker('saint_cracked').positive?
          player.set_tracker!('saint_cracked', 1)
          log << crack_line(player)
        elsif errands_done?(player)
          player.set_tracker!('saint_pull_due', 1)
          log << '_The glass is open. She is still in the water. You can reach._'
        end
      end
    end

    def note_death!(player, enc)
      relic = (enc[:relic] || enc['relic']).to_s
      return unless syn_gone?(player) && relic == 'drowned_sin'

      deepen!(player)
    end

    def note_cycle!(player)
      return unless syn_gone?(player)

      deepen!(player)
    end

    # Returns true only when this clear is the one that earns Eros's warmth,
    # so that clear itself does not also drag Syn deeper.
    def note_eros!(player, log, satisfied:)
      return false unless syn_gone?(player)
      return false unless player.tracker('saint_cracked').positive?
      return false if player.tracker('saint_warmth').positive?

      player.set_tracker!('saint_warmth', 1)
      log << warmth_line(player, satisfied)
      true
    end

    def note_syn_visit!(player)
      return nil unless player.tracker('saint_quest_step') == 1

      player.set_tracker!('saint_quest_step', 2)
      player.set_tracker!('saint_quest_start', player.tracker('bosses_defeated'))
      '_Syn listens, needle paused. "An apology. From something that will not give you its name." ' \
        'She looks at the door, not at you. "Clear one throne without kneeling. Then come back and tell me again. ' \
        'I will decide if I walk down there."_'
    end

    def parlour_intro(player)
      return nil unless syn_gone?(player)

      ready = errands_done?(player) ? "\n\n_Berry shuts the ledger. \"The next throne that can hold her will hold her. Do not kneel.\"_" : ''
      "## Syn & Berry's\n" \
        '_Half the parlour is still Berry: steel, bottled light, the ledger open to a page she is not writing in. ' \
        'The other half is an empty bench. The needle is stuck in a scrap of black lace, mid-stitch, as if the hand ' \
        'that held it was called away and did not get to set it down. Berry does not look at the bench._' \
        "#{ready}"
    end

    def apology_ready?(player)
      player.tracker('saint_quest_step') == 3 && !syn_gone?(player)
    end

    def thread_ready?(player)
      syn_gone?(player) && player.tracker('saint_cracked').positive? && !player.tracker('saint_thread').positive?
    end

    def needle_ready?(player)
      syn_gone?(player) && player.tracker('saint_cracked').positive? && !player.tracker('saint_needle').positive?
    end

    def grief_for(player, person)
      return nil unless syn_gone?(player)

      line = grief_line(person, band(player))
      return nil unless line

      key = "saint_grief_#{person}"
      return nil if player.tracker(key).positive?

      player.set_tracker!(key, 1)
      line
    end

    def whisper_line(player)
      return nil unless syn_gone?(player)
      return nil if rand >= 0.07

      [
        'A stitch of black thread drifts past your ankle and does not belong to anything in the room. Somewhere under the floor, water moves.',
        'You hear your name the way you hear it through a wall. When you answer, there is only the tower.',
        'Something knocks once, from inside a wall that has no hollow. The knock does not come again. The water does.'
      ][band(player)]
    end

    def press_glass!(player)
      return 'The tank is shut. She is not looking at you.' unless glass_pending?(player)

      step = player.tracker('saint_glass_step') + 1
      player.set_tracker!('saint_glass_step', step)
      player.set_tracker!('saint_quest_step', 1) if step == 5
      GLASS[step]
    end

    def press_apology!(player)
      return 'Syn is not waiting on an apology.' unless apology_ready?(player)

      trusted = Engine::Marks.owned(player).size >= 5 || Engine::Quests.story_done?(player)
      player.set_tracker!('saint_trust', trusted ? 1 : 0)
      player.set_tracker!('saint_quest_step', 4)
      if trusted
        '_Five marks, or a vow she already said yes to. Syn sets the needle down like a decision. ' \
          '"You would not walk me into a mouth," she says. It is not quite a question. "Fine. I will hear this apology. Once."_'
      else
        '_Syn does not owe you this. She comes anyway, the way she comes to a client she has not decided to keep. ' \
          '"An apology, then. I will stand where I can see the door. Do not make me regret the courtesy."_'
      end
    end

    def press_taking!(player)
      return 'The meeting is over.' unless player.tracker('saint_meeting_due').positive?

      player.set_tracker!('saint_meeting_due', 0)
      player.set_tracker!('syn_taken', 1)
      player.set_tracker!('saint_quest_step', 5)
      woken = player.reactivate_suppressed_curses!
      wake = if woken.any?
               " Every blessing Syn had smothered wakes at once: #{woken.map { |n| "**#{n}**" }.join(', ')}."
             else
               ''
             end
      'The apology lasts one sentence. The glass opens on the second. Syn steps in because you asked her to, ' \
        'and the water closes over the only vessel in the tower that was already full of ink, needle, and nerve. ' \
        "She does not scream. The tank does. When it settles, the bench upstairs is empty.#{wake} " \
        'Eros knows. The tower knows. You are not forgiven.'
    end

    def press_needle!(player)
      return 'Berry has nothing for you to carry.' unless needle_ready?(player)

      player.set_tracker!('saint_needle', 1)
      [
        '_Berry puts a needle in your hand. It is Syn\'s. "She said your name," Berry says, and does not cry where you can see it. "Bring it back with her on the other end of it."_',
        '_Berry wraps the needle in cloth so it will not ring. "I heard her. Not the words. Don\'t ask me to repeat a sound like that."_',
        '_Berry almost does not give it over. Then she does, because refusing will not pull anyone out of a tank. "If this comes back without her, do not bring it to me."_'
      ][band(player)]
    end

    def press_thread!(player)
      return 'Vex is not holding a thread for you.' unless thread_ready?(player)

      player.set_tracker!('saint_thread', 1)
      [
        '_Vex draws one black thread out of a hem that was not finished and knots your wrist once. "Listener\'s knot. It remembers the hand that started the stitch. Follow it down."_',
        '_Vex works in silence longer than is kind. The knot is tight. "She is further than a voice. This will still find the stitch. I dislike how sure I am."_',
        '_Vex looks at the knot and almost takes it back. "At this depth I am sewing a rescue to a drowning. Take it before I become sensible."_'
      ][band(player)]
    end

    def press_pull!(player)
      return 'There is nothing left to reach.' unless player.tracker('saint_pull_due').positive?

      player.set_tracker!('saint_pull_due', 0)
      player.set_tracker!('saint_quest_done', 1)
      player.remember!('badges', 'saint_returned')
      pull_line(player)
    end

    def stool_line(player)
      return 'Syn is on her bench. She is looking at you like you invented the interruption.' unless syn_gone?(player)

      '_The stool is empty. The needle is still in the lace. Berry does not suggest you sit._'
    end

    def deepen!(player)
      player.bump_tracker!('saint_depth')
    end

    def crack_line(player)
      [
        '_The glass cracks when she falls, not before. Through it, clear as a parlour: your name, in Syn\'s mouth. The three errands are open. She is not out._',
        '_The glass cracks. What comes through is Syn, muffled, a shape of a word and then water. Berry will know. Vex will know. The top of the tower will not pretend._',
        '_One knock. Then the crack. Then only water. If she said a name, the tank kept it. The errands open anyway._'
      ][band(player)]
    end

    def depth_satisfy_line(_player)
      '_You kneel, and the tank takes the kneeling as permission to hold her lower. She is not saved. She is deeper._'
    end

    def warmth_line(player, satisfied)
      how = satisfied ? 'You satisfy Eros with Syn still in the tank.' : 'You beat Eros with Syn still in the tank.'
      tail = [
        "#{how} The goddess puts a heat in your ribs that is not for you. \"For the fairy,\" she says. \"Not for you.\"",
        "#{how} Eros does not praise the clear. The warmth she leaves is a coal with someone else's name on it.",
        "#{how} Eros does not look at you. The warmth arrives anyway, furious, and aimed at the tank. \"For the fairy.\""
      ][band(player)]
      "_#{tail}_"
    end

    def pull_line(player)
      deep = band(player)
      trusted = player.tracker('saint_trust').positive?
      if deep >= 2
        '_Berry is the one who tells it, later, because Syn does not. The needle went in. The thread held. ' \
          'What came out of the tank was Syn, and a scar the parlour will not name. ' \
          "#{trusted ? 'Eros says the trust was real, and that you spent it.' : 'Eros says a stranger walked her fairy to the glass, and the Saint is the one she will not forgive first.'} " \
          'The wrath lets go. The blessings stay awake. The badge on your profile is a bubble, and it does not explain itself._'
      elsif deep == 1
        '_You pull. Syn comes up quiet, carried more than climbing, the needle still in her fist and Vex\'s knot ' \
          'bitten through. She does not tell the story. ' \
          "#{trusted ? 'Eros, when she speaks, speaks to Syn: the trust was used.' : 'Eros speaks once, to the room: a courtesy was turned into a taking.'} " \
          'The wrath lets go. The blessings stay awake._'
      else
        '_Syn grabs the needle and the knot and your wrist, in that order, and says your name like a person who ' \
          'decided to. The tank closes on water and nothing else. ' \
          "#{trusted ? 'She told Eros she trusted you. Eros repeats it, so you have to hear what you spent.' : 'She tells Eros she went as a courtesy. Eros repeats that, too, and the Saint is not welcome upstairs.'} " \
          'The wrath lets go. The blessings she had smothered stay awake. You keep a mark for this, and the tower does not tell anyone how you earned it._'
      end
    end

    def grief_line(person, depth)
      case person.to_s
      when 'berry'
        [
          '_Berry smiles with none of her teeth in it. "Ask your questions, sugar. Do not ask me where my wife is."_',
          '_Berry\'s ledger is open to a blank. "She is further away than yesterday. Talk, or get out of my light."_',
          '_Berry does not flip the ledger. "If you are here to be forgiven, the answer is no. If you are here to work, talk."_'
        ][depth]
      when 'vex'
        [
          '_Vex\'s pins are lined up and her hands are not. "The stitcher is missing a stitch. I am listening. Do not waste it."_',
          '_Vex measures a silence. "I can still hear the hem she did not finish. It is further down than a voice should be."_',
          '_Vex almost will not look at you. "At this depth I am not sure a thread is a kindness. Speak anyway."_'
        ][depth]
      when 'pip'
        [
          '_Pip\'s goggles fog. "The bench upstairs is wrong. I checked the tiles. The tiles are fine. The bench is wrong."_',
          '_Pip kicks a plate and does not pick it up. "Something under the tower is heavier than it was. I don\'t like the math."_',
          '_Pip stops pretending it is a mechanism. "She\'s deep. I can\'t sketch a room that far down. Don\'t ask me to."_'
        ][depth]
      when 'nectar'
        [
          '_Nectar leaves a hymn unfinished. "The parlour has a hole in it. I will not dress the hole up as a lesson."_',
          '_Nectar\'s candle leans toward the floor, not the altar. "She is lower than the hymn knows how to go."_',
          '_Nectar sets the candle down. "I will not sing a drowning into looking like mercy. Say what you came to say."_'
        ][depth]
      when 'cartographer'
        [
          '_Fang taps a map that has a new wet stain and no new room. "I did not draw that. I am not going to."_',
          '_Fang rolls the map so the stain is hidden. "The blank is bigger. That is all the survey you get."_',
          '_Fang will not unroll it. "Some depths are not a floor. I don\'t sell a path into one."_'
        ][depth]
      when 'covar'
        [
          '_Covar sets both hands on the counter and does not grin. "The stitcher is not upstairs. Do not ask me to sell you a way to pretend otherwise."_',
          '_Covar\'s tail is still. "She is lower than the last time you walked in. The merchandise can wait."_',
          '_Covar will not lean on the counter. "At this depth I would be a monster to flirt. Buy something, or don\'t. The tank is not for sale."_'
        ][depth]
      end
    end
  end
end
