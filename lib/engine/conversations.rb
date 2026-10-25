# frozen_string_literal: true

module Engine
  # Conversations with Syn and Berry. Topics unlock as a delver experiences
  # the tower: beating (or satisfying) a boss opens that boss as a topic with
  # both fairies, and each wife has very different things to say about them.
  # Per the lore in docs/lore/ (see conversations.md / syn_and_berry.md), neither fairy ever calls this place a
  # dungeon before the reveal: after a delver's first return from floor 35,
  # Syn confirms it is a temple, and revealed variants replace the coy ones.
  module Conversations
    # Shared Talk categories. Temple = systems/altars/cycles (not "talking to Eros").
    CATEGORIES = [
      { key: 'general', label: 'General' },
      { key: 'clergy', label: 'Clergy' },
      { key: 'residents', label: 'Residents' },
      { key: 'temple', label: 'Temple' }
    ].freeze

    # Victory-screen Talk person keys ← canonical boss names.
    BOSS_PERSON = {
      'Mimic Broodmother' => 'broodmother',
      'Succubus Queen' => 'queen',
      'Incubus King' => 'king',
      'Verdant Dryad' => 'dryad',
      'Lich Lord' => 'lich',
      'Alpha Beast' => 'alpha',
      'Eros' => 'eros'
    }.freeze

    CLERGY_PEOPLE = %w[broodmother queen king dryad lich alpha eros].freeze
    RESIDENT_PEOPLE = %w[vex pip nectar cartographer].freeze
    FAIRY_PEOPLE = %w[berry syn].freeze

    PEOPLE = {
      'berry' => {
        name: 'Berry',
        emoji: '🍓',
        heading: 'Talking with Berry',
        intro: '_Berry flips her ledger shut and gives you her whole, sunny attention — the dangerous kind. ' \
               '"Ask, sugar. Shop, board, wife, or the temple\'s gossip — I have opinions. Some of them are ' \
               'even polite."_'
      },
      'syn' => {
        name: 'Syn',
        emoji: '🖤',
        heading: 'Talking with Syn',
        intro: '_Syn sets her needle down, folds her inked arms, and looks you over like a catalogue page she ' \
               'already wants to annotate — heavy-lidded, violet-eyed, smirking. "Go on. Ask me something ' \
               'filthy or interesting. I charge more for boring."_'
      },
      'covar' => {
        name: 'Covar Zephyren',
        emoji: '🔮',
        heading: 'Talking with Covar Zephyren',
        intro: '_Covar leans on the cursed counter — horns, tail, D-cup chest on shameless display — and grins. ' \
               '"Browse, ask, touch the merchandise. Some of it touches back. I\'m the matchmaker, not just ' \
               'the shopkeep."_'
      },
      'vex' => {
        name: 'Madame Vex',
        emoji: '🪡',
        heading: 'Talking with Madame Vex',
        intro: '_Vex sits very still, Listener-calm, pins and tape within reach. "Easy. You don\'t have to ' \
               'perform — just talk. I\'m listening."_'
      },
      'pip' => {
        name: 'Pip',
        emoji: '🔧',
        heading: 'Talking with Pip',
        intro: '_Pip looks up from a sprung plate, goggles askew, bare legs swinging. "Mind the second tile. ' \
               'Ask me something with hinges — I\'m in a documenting mood."_'
      },
      'nectar' => {
        name: 'Sister Nectar',
        emoji: '🥛',
        heading: 'Talking with Sister Nectar',
        intro: '_Nectar wipes her hands on her apron with shrine-professional warmth. "Milking is holy. Treat ' \
               'it like holy. Then ask, darling."_'
      },
      'cartographer' => {
        name: 'The Cartographer',
        emoji: '🗺️',
        heading: 'Talking with the Cartographer',
        intro: '_Fang does not look up from the map that is also his room. "The room moved again. Hold this ' \
               'corner — or ask. I\'m mid-line."_'
      },
      'broodmother' => {
        name: 'Mimic Broodmother',
        emoji: '📦',
        heading: 'Talking with the Broodmother',
        intro: '_The lid stays open. Tongues idle. "Open it. Or crawl in. Same door. Ask while you\'re still ' \
               'outside, brood."_',
        victory_only: true
      },
      'queen' => {
        name: 'Succubus Queen',
        emoji: '👑',
        heading: 'Talking with the Succubus Queen',
        intro: '_She lounges like etiquette invented her. "Darling, architecture is just manners with teeth. ' \
               'Ask carefully."_',
        victory_only: true
      },
      'king' => {
        name: 'Incubus King',
        emoji: '🔥',
        heading: 'Talking with the Incubus King',
        intro: '_He grins like Syn already signed the permission slip. "Come here. Syn said I could. Or ask ' \
               'first — cute."_',
        victory_only: true
      },
      'dryad' => {
        name: 'Verdant Dryad',
        emoji: '🌿',
        heading: 'Talking with the Verdant Dryad',
        intro: '_Fruit scent and shade. "Eat. Stay. The grove has room — and answers, if you ask gently."_',
        victory_only: true
      },
      'lich' => {
        name: 'Lich Lord',
        emoji: '❄️',
        heading: 'Talking with the Lich Lord',
        intro: '_Frost-crown flicker. Blue flame in empty sockets. "Fascinating. Wrong, but fascinating. ' \
               'Speak. I am taking notes."_',
        victory_only: true
      },
      'alpha' => {
        name: 'Alpha Beast',
        emoji: '🐺',
        heading: 'Talking with the Alpha Beast',
        intro: '_Soft eyes in a nightmare body. A low rumble that almost shapes a word. *…mate.* Ask; he ' \
               'answers in growl and heat._',
        victory_only: true
      },
      'eros' => {
        name: 'Eros',
        emoji: '❤️',
        heading: 'Talking with Eros',
        intro: '_Red eyes. Tentacle warmth. She already counted your kneels. "I read your skin. Ask — then ' \
               'climb, break, and bring it to my mouth again."_',
        victory_only: true
      }
    }.freeze

    # Boss topics in floor order (fairy Ask-abouts). `boss` = bosses_seen name.
    BOSS_TOPICS = [
      { key: 'broodmother', label: 'Mimic Broodmother', boss: 'Mimic Broodmother', floor: 5, category: 'clergy' },
      { key: 'succubus_queen', label: 'Succubus Queen', boss: 'Succubus Queen', floor: 10, category: 'clergy' },
      { key: 'incubus_king', label: 'Incubus King', boss: 'Incubus King', floor: 15, category: 'clergy' },
      { key: 'verdant_dryad', label: 'Verdant Dryad', boss: 'Verdant Dryad', floor: 20, category: 'clergy' },
      { key: 'lich_lord', label: 'Lich Lord', boss: 'Lich Lord', floor: 25, category: 'clergy' },
      { key: 'alpha_beast', label: 'Alpha Beast', boss: 'Alpha Beast', floor: 30, category: 'clergy' },
      { key: 'eros', label: 'Eros', boss: 'Eros', floor: 35, category: 'clergy' }
    ].freeze

    BOSS_ANSWERS = {
      'broodmother' => {
        berry: 'Berry\'s smile disappears so fast it leaves a draft. "Her? She once tried to fuck my wife. ' \
               'In our own shop, practically in front of the till. I don\'t care what rank she holds up here — ' \
               'the Broodmother can keep her lid, her tongues, and her brood away from Syn."',
        syn: '"Everyone should fuck a mimic at least once," Syn says serenely. "All those tongues, that warm ' \
             'velvet dark, a body that\'s nothing but wanting you inside it. Berry won\'t share me, so the ' \
             'rest of you will simply have to be brave on my behalf."'
      },
      'succubus_queen' => {
        berry: '"Oh, I know about the Queen," Berry says, with a smile that has edges. "Put her and Syn in a ' \
               'room and it\'s flirting and filthy jokes until neither of them has done a stroke of work. ' \
               'Centuries of practice, apparently. I counted the jokes once. I stopped counting."',
        syn: '"An old, dear friend," Syn says warmly. "She and I built the traps together — every plate and ' \
             'petal of them. She brought the cruelty, I brought the craftsmanship, and we brought out the ' \
             'worst in each other beautifully. Tell her I said so. She\'ll laugh. Then she\'ll check the traps."'
      },
      'incubus_king' => {
        berry: '"Him I only like when Syn\'s around," Berry says flatly. "He hits on me. Constantly. Like ' \
               'it\'s a liturgy. With my wife in the room he has to split his attention, and I can get a ' \
               'word — and a sale — in edgeways."',
        syn: '"An annoying fuckboy," Syn says, without heat. "Gorgeous, gifted, and completely unbearable. ' \
             'We did build the monster-spawning working together, so I owe him professional courtesy. I pay ' \
             'it in small coins and leave before he starts posing."'
      },
      'verdant_dryad' => {
        berry: '"Oh, she\'s a friend," Berry says, brightening. "A proper, long-time friend. She keeps us in ' \
               'fruit — you have not lived until you\'ve had her honey-apples — and she\'s the only one up ' \
               'here whose visits don\'t end with me hiding the good ink."',
        syn: '"A friend," Syn says, "and the green mind behind half the things that grab you down there. The ' \
             'tentacle and vine work? Her ideas. I only made them eager. She thinks in roots and hunger the ' \
             'way I think in lines. We understand each other."'
      },
      'lich_lord' => {
        berry: 'Berry shudders theatrically — mostly theatrically. "No. Absolutely not. He\'s undead, sugar. ' \
               'Cold hands, colder jokes, and he looks at people like he\'s reading them. You go visit him. ' \
               'I\'ll keep the shop warm for the survivors."',
        syn: '"A creepy old man," Syn says, "and I don\'t enjoy being around him. But he taught me how to use ' \
             'lust energy — how to make desire do work instead of just making noise. I owe the lesson. I ' \
             'decline the company. Both things can be true."'
      },
      'alpha_beast' => {
        berry: '"A puppy," Berry declares, immediately and completely. "A very large, very good boy who ' \
               'happens to have a floor. Did he wag for you? He wags when he\'s pleased. Nobody up here is ' \
               'allowed to be mean about him. That\'s a shop rule."',
        syn: '"My adorable puppy," Syn purrs. "I designed his floors wide so his pack can roam, and he repays ' \
             'me by being enormous, loyal, and entirely without guile. Everyone up here schemes. ' \
             'He just wants. It\'s refreshing."'
      },
      'eros' => {
        berry: 'Berry\'s voice drops into something soft and certain. "She\'s perfect. That isn\'t flattery, ' \
               'sugar, it\'s just the shape of things. Everything up here exists because she wished it to, and ' \
               'if she ever wished me to do anything — anything — I\'d already be doing it."',
        syn: '"My Goddess," Syn says, simply, and for once there is no tease anywhere in her. "I helped build ' \
             'this place to show her what my faith looks like: visitors tempted, unraveled, and driven into ' \
             'depravity, floor by floor, all of it hers. Judge the work kindly. It was made with love."'
      }
    }.freeze

    # The reveal, delivered by Syn after a delver's first return from
    # floor 35. From then on, revealed variants replace the coy answers:
    # Syn speaks as a builder, Berry keeps her domestic voice with proper
    # nouns finally allowed.
    REVEAL_SCENE =
      '_Syn looks at you for a long moment, then sets her needle down like a decision. "You\'ve been to ' \
      'the top. You\'ve met her, and she handed you back herself — so we stop lying to you now. ' \
      'This is not a dungeon, and it never was. It is a **temple** — to Eros, built by me and six old ' \
      'friends of mine, floor by floor, to tempt the world into giving in to her. The cycles are hers: ' \
      'her answer to our work, and the reason nobody leaves unchanged. Ask me properly now. I built this ' \
      'place. I can finally say so."_'

    REVEALED_BOSS_ANSWERS = {
      'broodmother' => {
        berry: '"In this temple, she\'s a high priestess," Berry says, with enormous reluctance. "Ancient, ' \
               'holy, and still the creature who once kept my wife. The temple can have her ministry. I ' \
               'keep my opinion."',
        syn: '"My Broodmother of the first five floors," Syn says. "She kept me once, long before the ' \
             'temple — I bargained my way out of her, and when I built, I came back and offered her an ' \
             'endless table instead. She is not tame. She is employed. There is a difference, ' \
             'and the difference is architecture."'
      },
      'succubus_queen' => {
        berry: '"A high priestess of this temple," Berry says, "and my wife\'s oldest collaborator in ' \
               'cruelty. The traps were their great work together. In this house I am expected to call ' \
               'that holy. I call it Tuesday."',
        syn: '"My Queen built the traps with me," Syn says openly. "Every plate and petal of them — the ' \
             'temple\'s first ministry, and still the one I am proudest of. She was a small court\'s ' \
             'queen before I made her eternal. Ask her about the work sometime. She preens."'
      },
      'incubus_king' => {
        berry: '"High priest of this temple," Berry says, "unfortunately ordained. He hits on me in a ' \
               'house of worship, sugar. Syn says that makes it liturgy. I say it makes it paperwork."',
        syn: '"The King\'s half of the spawning spell keeps this temple stocked," Syn says. "He owed me ' \
             'a debt once; I collected in genius. His priesthood is real, his crown is self-declared, ' \
             'and both facts annoy him in exactly the wrong order."'
      },
      'verdant_dryad' => {
        berry: '"Our Dryad of the temple," Berry says warmly. "A high priestess, a dear friend, and the ' \
               'reason there is fruit worth eating in a house of sin. Even her vines are hospitable. ' \
               'Eventually. To someone."',
        syn: '"The Dryad\'s garden is the temple\'s mercy and its stickiest argument," Syn says. "She ' \
             'came for company, gave us the vine and tentacle work, and has been feeding this house ' \
             'since before the walls were finished. Rooted things keep a temple honest."'
      },
      'lich_lord' => {
        berry: '"The temple\'s high priest of the cold floors," Berry says with a shudder. "Syn\'s ' \
               'teacher, a thousand years dead, and still the only cleric I will not be alone in a ' \
               'room with. Holy is not the same as welcome, sugar."',
        syn: '"My teacher wears the twenty-first floor," Syn says. "Everything this temple is built ' \
             'with — lust made to work — I learned in his cold hands. He joined us to run an experiment ' \
             'with thirty-five floors of apparatus. I owe him the craft. I decline him the company. ' \
             'Priesthood changes neither fact."'
      },
      'alpha_beast' => {
        berry: '"A high priest of this temple," Berry declares, "and a very good boy. The temple has ' \
               'doctrine, sugar, and the doctrine is that nobody is mean about him in my shop."',
        syn: '"My puppy keeps the wide floors," Syn says, glowing. "I designed them broad for his pack ' \
             'when we raised the temple, and he has been its most honest priest ever since: no ' \
             'doctrine, no scheme, just wanting, offered up whole. Eros could ask for no cleaner ' \
             'worship than his."'
      },
      'eros' => {
        berry: 'Berry\'s voice goes soft and certain. "Now you\'ve stood in front of her too. Isn\'t ' \
               'she perfect? This whole temple is just us downstairs loving her as loudly as we know ' \
               'how. You understand now, sugar. I can see that you do."',
        syn: '"You have met my Goddess," Syn says, and there is no tease anywhere in her. "I built her ' \
             'a temple out of my own past — every priest in it someone I had loved, owed, studied ' \
             'under, or escaped — and she answered by trapping the world in it with us. Judge the ' \
             'work kindly. It was made with love, and now you are part of it."'
      }
    }.freeze

    REVEALED_GENERAL = {
      'this_place' => {
        berry: '"The temple, sugar," Berry says, almost giddy with permission. "Eros\'s temple, ' \
               'thirty-five floors of it, and my wife built it with her oldest friends. I just keep ' \
               'the shop at its heart and feed everyone who bleeds in. Welcome to church."',
        syn: '"My temple," Syn says simply. "To Eros, built by seven pairs of hands over decades — ' \
             'traps, spawning-spells, gardens, kennels, all of it ministry, all of it mine to finally ' \
             'name. You have been in church since the doors closed behind you."'
      },
      'cycles' => {
        berry: '"Her cycles, sugar," Berry says. "We built the temple; she answered it by making ' \
               'sure nobody just... leaves. Round and round until it takes. I have stopped pretending ' \
               'that isn\'t romantic. It is simply also a cage."',
        syn: '"The cycles are hers," Syn says. "Not ours. We built a temple on dreams and signs, and ' \
             'when it stood finished, she laid the loop over it herself — our one proof she answered. ' \
             'Every return is her hand on the back of your neck. Gentle. Final."'
      },
      'covar' => {
        berry: '"Covar keeps the Cursed Shop for this temple," Berry says, "and he is family, sugar. ' \
               'Tower\'s own, remade by the place he serves. If the temple has a matchmaker, it\'s ' \
               'him, and yes, I still send food down."',
        syn: '"My little brother tends the temple\'s living gear," Syn says. "I made the first of it; ' \
             'he made a ministry of collecting the rest. In a house built to change people, ' \
             'the boy who loves what it made of him might be its truest priest — don\'t tell the ' \
             'ordained ones I said so."'
      }
    }.freeze

    # Satisfying a boss (rather than beating them) earns extra fairy
    # material, appended the first time that boss is discussed afterwards.
    SATISFY_EXTRAS = {
      'broodmother' => {
        berry: '_You satisfied her? Berry stares. "Well. At least somebody in this marriage\'s orbit has. Don\'t tell me details and don\'t you dare bring her home."_',
        syn: '_"And you satisfied her, rather than fighting?" Syn\'s smile turns slow. "Good. Everyone should, once. Tell me whether the brood watched. No — tell me everything."_'
      },
      'succubus_queen' => {
        berry: '_"You satisfied the Queen." Berry\'s smile is bright and dangerous. "Centuries of practice, she says. I\'ll be checking my wife\'s story against yours, sugar."_',
        syn: '_Syn positively glows. "Satisfied her? Then you\'ve had the full court treatment. She only does the gaze properly for people she intends to keep thinking about."_'
      },
      'incubus_king' => {
        berry: '_"You satisfied him and walked out?" Berry looks almost impressed. "He\'ll be telling the court it was a royal visitation. Let him. You and I know who did the work."_',
        syn: '_"You satisfied the King?" Syn laughs, delighted. "He\'ll have posed afterwards like it was his achievement. It never is, and somehow he never learns."_'
      },
      'verdant_dryad' => {
        berry: '_"You satisfied the Dryad?" Berry softens. "Then you smell of fruit and pollen for days and everybody\'s kind about it. That\'s her gift. One of them."_',
        syn: '_"Satisfied my Dryad?" Syn murmurs. "Then the garden has your measure now. She keeps what she pleases. Go back sometime — slowly."_'
      },
      'lich_lord' => {
        berry: '_"You satisfied the Lich." Berry shudders theatrically. "Warmth for the corpse, from my own customer. I\'ll be boiling the ledger tonight, sugar."_',
        syn: '_"You gave him your pleasure willingly?" Syn\'s distaste wars with professional pride. "Then his data is excellent and his hands were everywhere. Both. It\'s always both with him."_'
      },
      'alpha_beast' => {
        berry: '_"You satisfied the big boy?" Berry beams. "Did he wag? He wags. You\'re pack-adjacent now, sugar — that\'s a real honour in this house."_',
        syn: '_"You satisfied my puppy?" Syn purrs. "Then you\'ve been claimed in the honestest way this temple knows. He\'ll remember your scent forever. So will I."_'
      },
      'eros' => {
        berry: '_Berry takes your hands, hushed. "You satisfied her. You. Sugar, do you understand what you did? Neither do I, and I\'ve believed in her my whole married life."_',
        syn: '_Syn is quiet a moment. "You satisfied my Goddess," she says at last. "Whatever I built, I never built that. Some doors only open from your side."_'
      }
    }.freeze

    # Shorter familiar versions for repeat asks (first answer is the full
    # one; the fairies remember being asked).
    REPEAT_BOSS = {
      'broodmother' => { berry: '"Still hate her, still because of Syn. Some things are load-bearing, sugar."',
                         syn: '"Still my favourite argument for fucking a mimic once. The brood remembers you kindly."' },
      'succubus_queen' => { berry: '"Still flirting with my wife across the centuries. Still counting the jokes. Still losing."',
                            syn: '"My old friend, my fellow trapwright. Ask her about the work; she\'ll preen for a week."' },
      'incubus_king' => { berry: '"Still only bearable with Syn in the room. Some liturgies never change."',
                          syn: '"Annoying, gorgeous, and half the reason the halls stay stocked. My favourite debt I ever collected."' },
      'verdant_dryad' => { berry: '"Still fruit, still friendship, still the safest arms in the building."',
                           syn: '"My green friend. Half of what grabs you down there started as her daydream."' },
      'lich_lord' => { berry: '"Still dead, still creepy, still not invited to dinner."',
                       syn: '"My cold teacher. I owe him the craft; the company remains declined."' },
      'alpha_beast' => { berry: '"A puppy. A very good boy. This is the whole report, every time."',
                         syn: '"My adorable puppy. Yes, he\'s still perfect. Next question."' },
      'eros' => { berry: '"Still perfect, sugar. Some answers don\'t need updating."',
                  syn: '"My Goddess. Everything else I say is footnotes."' }
    }.freeze

    REPEAT_GENERAL = {
      'this_place' => { berry: '"Home, work, endless stairs. Still true, sugar."',
                        syn: '"Still hungry. Still built to ruin you properly. Climb."' },
      'each_other' => { berry: '"Still mine, still trouble, still worth it."',
                        syn: '"Still Berry. Still the one who makes me behave."' },
      'your_work' => { berry: '"Shop, board, ledger. The empire holds, sugar."',
                       syn: '"I ink. She sells. You leave looking claimed. Same as ever."' },
      'monsters' => { berry: '"Still restocking themselves. I still don\'t ask the tower."',
                      syn: '"Halls still grow teeth. Appetites still need bodies."' },
      'traps' => { berry: '"Still mostly my wife\'s fault. She\'s still proud."',
                   syn: '"Still my workmanship. Sore, wet, smarter — remember?"' },
      'curses' => { berry: '"Still purge, silence, or pay up front."',
                    syn: '"Still pretty scribbles. Points still don\'t buy my approval."' },
      'marks' => { berry: '"Still my wife\'s handwriting on you."',
                   syn: '"Still ink that survives you getting broken. Good."' },
      'transformations' => { berry: '"Still growing on people. The book stays closed, sugar."',
                             syn: '"Desire still picking shapes. Still suits you."' },
      'altars' => { berry: '"Still kneel, offer, be seen. She knows her regulars."',
                    syn: '"Still her favourite: being worshipped on purpose."' },
      'cycles' => { berry: '"Still round again, prettier."',
                    syn: '"Another sitting. Still unfinished. Still watching."' },
      'covar' => { berry: '"Still sweet, still family, still not eating properly."',
                   syn: '"Little brother of the cursed counter. Still obsessed. Flattering."' }
    }.freeze

    # Covar's own topics. He is not bound by the fairies' careful language:
    # he loves this place openly and says so — he just has his own reasons.
    COVAR_TOPICS = [
      {
        key: 'his_arrival', label: 'How he got here', question: 'You were one of the first delvers?',
        category: 'general',
        covar: '"First handful through the doors," Covar says, with real pride. "Came down here with a sword, ' \
               'a dour attitude, and a body I\'d never once questioned. The tower questioned it for me. Horns ' \
               'first, then the tail, then—" he gestures at his chest, which needs no gesturing at, "—the rest ' \
               'of the redesign. I panicked for about a day. Then I caught my reflection enjoying itself, and ' \
               'I had to be honest about a few things."'
      },
      {
        key: 'why_stay', label: 'Why he stays', question: 'Why stay and run this shop?',
        category: 'general',
        covar: '"People assume I\'m trapped," Covar says, offended on the tower\'s behalf. "I\'m not trapped, ' \
               'I\'m *settled*. But the shop?" He sobers, which on him looks like weather changing. "You have ' \
               'to understand what I used to watch. Delvers, green as spring, wearing living pieces they ' \
               'couldn\'t read — getting them torn off by strangers, ripped free in a panic, left tattered ' \
               'on dungeon floors like wedding clothes in a ditch. Nobody *loved* them. Nobody even tried. ' \
               'The pieces remembered being worn, and then they remembered being ruined, and I couldn\'t ' \
               'sleep for it." He taps the counter, steady now. "So I honed myself. Learned every seam, ' \
               'every temperament, every word a piece needs to hear to let go kindly. Now delvers pay me LP ' \
               'and I take their living clothing off *properly* — intact, unhurried, unhurt — and the pieces ' \
               'they leave behind come here, to be catalogued and fed and matched to someone who\'ll keep ' \
               'them. Because that\'s the other thing nobody asks: how else do I feed the ones they leave ' \
               'behind? LP is just love with paperwork, delver. This shop is an orphanage that pays for ' \
               'itself, and I am its extremely handsome mother."'
      },
      {
        key: 'cursed_gear', label: 'Cursed & living gear', question: 'Why cursed gear?',
        category: 'temple',
        covar: 'His whole face lights up — the obsessive\'s glow. "Because living gear *remembers* you. Clean ' \
               'steel forgets. A cursed piece learns your heat, your habits, how you beg—" he catches himself, ' \
               'unrepentant, "—how you wear it. Syn made the first pieces, did you know that? I just… collect ' \
               'them. Catalogue them. Find them good homes. Every piece in this shop is waiting for its person."'
      },
      {
        key: 'vex_dress', label: "Madame Vex's dress", question: "What about the dress Madame Vex wears?",
        category: 'residents',
        covar: '"I would never dare remove the dress," Covar says, with the gravity of a man discussing ' \
               'scripture. "It\'s Syn\'s first ever work, and just look at it—" he does a special gay wave ' \
               'at the memory of it, wrist and all, "—it\'s *magnificent*. If I tried to part the two, the ' \
               'heartbreak of the dress would be too much to bear. After all, they have been with each other ' \
               'for years. I cannot let her first work die — not after what happened to the tiara..."',
        covar_after: '"Don\'t." The grin is simply gone, which on Covar is like the lights going out. "Do you ' \
                     'have any idea what you did? That dress was *Syn\'s first work*. Her first. It wore one ' \
                     'woman for decades, it learned her, it *loved* her after its fashion — and now it sits ' \
                     'on a mannequin like a — like an exhibit. You killed such an amazing dress." He presses ' \
                     'both palms flat on the counter, collecting himself, and fails. "I had plans, you know. ' \
                     'Years of plans. I was going to breed accessories to match it — gloves that had learned ' \
                     'its seams, a collar raised on its hems, little courtiers for the original\'s court. ' \
                     'There was going to be a whole *lineage*. And now—" He looks toward the back room, and ' \
                     'his voice does something complicated. "She\'s free. I know she\'s free. That is the ' \
                     'worst part of you, delver: I cannot even be properly furious. Give me the counter ' \
                     'between us a while longer."',
        covar_restored: '"Careful," Covar says, turning once in it — Syn\'s first work, restored, worn at his ' \
                        'own counter like a coronation. "You\'re looking at history, and history is ' \
                        '*fitted*. She came to the shop, you know. My big sis. Stood in that door and went ' \
                        'quiet as a held breath — her first masterpiece, alive, and better than she left ' \
                        'it, on her favourite disaster." He smooths a seam with something perilously like ' \
                        'reverence. "Vex has her own rooms again. Wears her freedom well. And the Original ' \
                        'has me. Everyone, at last, is being worn by the right thing."'
      },
      {
        key: 'the_fairies', label: 'Syn & Berry', question: 'What about Syn and Berry?',
        category: 'residents',
        covar: '"Family," Covar says simply. "Syn\'s my big sis — she made the first living gear and taught ' \
               'me everything: how it thinks, how to catalogue it, how to tell a shy piece from a hungry one. ' \
               'Berry\'s sweet as her name and treats me like a brother she has to feed. We don\'t see each ' \
               'other often — the shop\'s far and they\'re busy — but when we do, it\'s home. Don\'t tell Syn ' \
               'I called her sis to a customer. She\'ll pretend to hate it and preen for a week."'
      },
      {
        key: 'his_body', label: 'His changed body', question: 'Do you like what you became?',
        category: 'general',
        covar: '"Like?" He leans on the counter, and his chest does something deliberate. "Sweetheart, I ' \
               '*adore* what I became. The tower took a man who was afraid of his own appetites and gave him a ' \
               'body that has them on display. Breasts, cock, tail — a full menu, and every plate generous. ' \
               'Half my customers come in just to look. I charge them in conversation."'
      },
      {
        key: 'customers', label: 'His customers', question: 'Who buys from you?',
        category: 'general',
        covar: '"Everyone, eventually," Covar says. "They come in pretending disgust — \'oh no, cursed, how ' \
               'terrible\' — and they leave with something that has opinions about their skin. Then they come ' \
               'back. The gear chooses as much as the delver does, you know. I just introduce them and take ' \
               'the credit. It\'s matchmaking, really. With teeth."'
      },
      {
        key: 'delving_advice', label: 'Advice for delvers', question: 'Any advice for delving?',
        category: 'temple',
        covar: '"Practical, then." He counts on long fingers. "One: living gear costs LP to tear free, so ' \
               'don\'t wear what you can\'t afford to remove. Two: every curse you carry makes the floors ' \
               'bolder — purge or suppress before a boss, not after. Three: if a chest smiles at you, it has ' \
               'already decided. Four—" his grin turns wicked, "—when you\'re too wound up to think, you know ' \
               'where my counter is."'
      },
      {
        key: 'the_goddess', label: 'Eros', question: 'What about the one at the top?',
        category: 'clergy',
        covar: 'His voice drops, and for once there is no grin in it. "She remade me. Maybe not with her own ' \
               'hands — but this place is hers, and it decided I was worth improving. I\'ve never met her. I ' \
               'don\'t need to. Every morning I wake up in this body, in this shop, in these halls, and I say ' \
               'thank you. That\'s not captivity, delver. That\'s gratitude with a pulse."'
      }
    ].freeze

    # Taking Covar to bed: unlocked after hearing enough of him out. He is
    # dominant with his breasts or his cock — and deliciously submissive
    # when a delver takes his ass instead.
    COVAR_SEX_TOPICS_REQUIRED = 5

    COVAR_SEX = {
      'breasts' => {
        label: 'His breasts', button: '🍒 Fuck his breasts', needs_part: 'penis',
        blurb: 'He takes charge, pressing that impossible chest around your cock and setting the pace himself.',
        text: 'Covar does not wait to be asked twice. He hauls you in, presses that impossible chest around ' \
              'your cock, and keeps you there — both hands squeezing his breasts together, setting the pace ' \
              'himself while his tail curls possessively round your waist. "There you go," he purrs, all ' \
              'dominance and warmth, watching your face over the swell of him. He works you between his ' \
              'breasts until you are shaking, and only then does he let you spill your orgasm across his ' \
              'chest. He holds you through it, smug as a cat.'
      },
      'cock' => {
        label: 'His cock', button: '🍆 Take his cock',
        blurb: 'For everyone: the keeper bends you over his own counter and fucks you — pussy if you have one, ' \
               'ass if you don\'t — firmly, thoroughly, and until you\'re drained.',
        text: 'He turns you against his own counter with an incubus\'s certainty, the bell above his shop ' \
              'door politely ignored. "My counter, my rules," Covar growls, and takes you the way the tower ' \
              'taught him to want people — firmly, thoroughly, one hand spread between your shoulders to ' \
              'keep you exactly where he wants you. He fucks you until your knees forget their duties and ' \
              'your orgasm tears out of you, and his follows with a groan he does not bother to hide. "There," ' \
              'he says, breathless and pleased. "Drained. You\'re welcome."'
      },
      'ass' => {
        label: 'His ass', button: '🍑 Fuck his ass', needs_part: 'penis',
        blurb: 'Take him, and the dominant keeper melts — begging, grateful, and gloriously submissive.',
        text: 'The moment you make it clear which of you will be doing the taking, the great incubus melts. ' \
              '"Oh," Covar breathes, already bending over his own counter, tail lashing with eagerness, "oh, ' \
              'it has been a *while*." The dom of the cursed shop begs beautifully — please, and more, and ' \
              'don\'t stop — until you slide your cock into his ass and reduce him to a whimpering, grateful ' \
              'mess clutching the counter edge. Your orgasm wrings a second, helpless one out of him. ' \
              'Afterwards he stays folded there a moment, laughing weakly. "Come back any time," he says. ' \
              '"Please. That\'s not shop talk."'
      }
    }.freeze

    TOPICS = [
      {
        key: 'this_place', label: 'This place', question: 'What is this place, really?',
        category: 'general', unlock: :always,
        berry: '"This place?" Berry waves at the shelves like that settles it. "Home. Work. Stairs that never ' \
               'quit. Call it whatever keeps you climbing, sugar — I\'m busy keeping the lights on."',
        syn: '"Somewhere people come to get ruined properly." Syn spins a needle on her fingertip. "Old. ' \
             'Hungry. Built to make you want the next door. You want a lecture? Climb higher and earn one."'
      },
      {
        key: 'each_other', label: 'Your wife', question: 'Tell me about your wife.',
        category: 'general', unlock: :always,
        berry: '"Syn?" Soft and exasperated in the same breath. "Platinum disaster. Sleeps through stock day, ' \
               'flirts with anything with a pulse, inks people until my heart does stupid things. She\'s mine. ' \
               'Repeat that and I\'ll deny it while smiling."',
        syn: '"Berry." The smirk softens, then turns wicked. "Feeds me. Owns me. Makes me be good when I\'m ' \
             'spiraling. Everyone thinks the needles make me dangerous — you\'ve never watched my wife collect ' \
             'a debt with that sunny little smile."'
      },
      {
        key: 'your_work', label: 'Your work here', question: 'What do you actually do here?',
        category: 'general', unlock: :always,
        berry: '"Shop. Board. Ledger." She taps each like commandments. "Gear out, points in, errands posted. ' \
               'Syn handles the permanent stuff through the curtain. I handle you behaving while you shop."',
        syn: '"I put pretty permanent things on people who ask nicely — or pay loudly." A lazy glance at your ' \
             'skin. "Berry sells the toys. I make sure you leave looking like someone\'s unfinished fantasy. ' \
             'Hold still someday and I\'ll show you the difference."'
      },
      {
        key: 'monsters', label: 'The monsters', question: 'Where do all the monsters come from?',
        category: 'temple', unlock: { requirement: { monsters_killed: 1 } },
        unlock_text: 'Defeat a monster',
        berry: '"They keep showing up, don\'t they?" Unbothered shrug. "Something likes the halls full. I ' \
               'bottle what you drag back and I don\'t poke the why — safer for my blood pressure."',
        syn: '"Appetites need bodies." She says it like pillow talk. "Someone taught the halls how to grow ' \
             'teeth. Might\'ve been me. Might\'ve been a very long night. Ask again when you\'ve been bitten ' \
             'somewhere interesting."'
      },
      {
        key: 'traps', label: 'The traps', question: 'Who set all these traps?',
        category: 'temple', unlock: { any: { 'traps_triggered' => 1, 'traps_avoided' => 1 } },
        unlock_text: 'Trigger or dodge a trap',
        berry: 'Sympathetic wince. "Sprung one? Half that clever nastiness is my wife\'s early fun. She calls ' \
               'it craftsmanship. I call it why we stock tinctures. Don\'t praise her — she\'ll design worse."',
        syn: 'Eyes bright. "Felt that, did you? Good. A trap should leave you thinking about me for hours — ' \
             'sore, wet, smarter. I had help with the hinges. The philosophy\'s mine: caught is boring. ' \
             'Changed is art."'
      },
      {
        key: 'curses', label: 'Curses', question: 'What can you tell me about curses?',
        category: 'temple', unlock: { requirement: { curses_gained: 1 } },
        unlock_text: 'Be cursed once',
        berry: '"They stick because this place likes souvenirs." Practical. "Pay me — well, pay her — to ' \
               'purge one, hush one, or scrape the lot if you\'re flush. She\'ll call them blessings and glare. ' \
               'Points talk louder than your whining, sugar."',
        syn: 'She almost touches your skin, then doesn\'t. "Look at you — decorated. Something decided you ' \
             'were worth scribbling on. Then you crawl in here begging me to erase the best parts. Fine. Pay. ' \
             'I\'ll vandalise my favourite gallery. Don\'t expect me to like you for it."'
      },
      {
        key: 'marks', label: 'Marks', question: 'What do marks mean to you?',
        category: 'temple', unlock: { requirement: { marks_owned: 1 } },
        unlock_text: 'Wear one of Syn\'s marks',
        berry: '"That\'s her handwriting on you." Proprietary pride. "She\'ll ink anyone with coin — but she ' \
               'remembers the ones she likes. So does this place, long after a run forgets your name."',
        syn: '"Ink that survives you getting broken." Soft laugh. "Runs end. Bodies reset. My work stays — ' \
             'little claims that say you knelt for me. Wear enough and even strangers will know you\'re ' \
             'someone\'s unfinished page. Mine, preferably."'
      },
      {
        key: 'transformations', label: 'Hybrid forms', question: 'What are these hybrid forms?',
        category: 'temple', unlock: { requirement: { forms_unlocked: 1 } },
        unlock_text: 'Unlock a hybrid form',
        berry: '"Ears. Tails. Wings. I\'ve seen delvers come back looking like the floors had opinions." ' \
               'Cheerful. "Syn sketches every one. Whole book. No, you may not peek — that\'s wife privilege."',
        syn: '"Desire picking a shape and the place saying yes." She looks almost hungry. "You stop pretending ' \
             'you\'re only human. Fuse two and you\'re a composition — messy, gorgeous, mine to stare at. ' \
             'Don\'t blush. You already did that when it happened."'
      },
      {
        key: 'altars', label: 'The altars', question: 'What are the altars about?',
        category: 'temple', unlock: { requirement: { eros_attention: 1 } },
        unlock_text: 'Gain Eros\'s Attention at an altar',
        berry: 'Voice dips. "You knelt. Good. She notices — offerings, prayers, the way you look when you mean ' \
               'it. Keep showing up, sugar. Being seen by her is… half of why I stay soft about this place."',
        syn: '"She likes being worshipped with an open mouth and an open schedule." Dry. Filthy fond. "Kneel. ' \
             'Offer. Get noticed. Regulars get remembered — and she remembers skin the way I remember ink."'
      },
      {
        key: 'cycles', label: 'The cycles', question: 'What happens after the top?',
        category: 'temple', unlock: { requirement: { cycles_completed: 1 } },
        unlock_text: 'Complete a cycle',
        berry: '"You went up and came back for more." Delighted. "Favourites don\'t get to leave clean. Floors ' \
               'get bolder, company gets warmer, and you get another chance to come home prettier."',
        syn: '"Round two. Deeper bruises. Better stories." She tips her head. "Whatever you were, it asks what ' \
             'you\'ll be next. I call it another sitting — you under my eyes until the portrait gets honest."'
      },
      {
        key: 'covar', label: 'Covar Zephyren', question: 'What about Covar at the Cursed Shop?',
        category: 'residents', unlock: { requirement: { mimics_removed_count: 1 } },
        unlock_text: 'Tear free a piece of living gear',
        berry: '"Covar?" Soft immediately. "Sweet boy. Family. We don\'t see him enough — that shop eats his ' \
               'hours. Tell him Berry said eat real food, not whatever the shelves are flirting with."',
        syn: '"Little brother energy. Obsessed with my living toys." Fond, teasing. "I taught him. He ' \
             'catalogues like it\'s devotion. Flattering little haunt — if he starts lecturing you about ' \
             'gear sex, that\'s love, not a sales pitch."'
      },
      {
        key: 'resident_vex', label: 'Madame Vex', question: 'What about Madame Vex?',
        category: 'residents', unlock: { requirement: { resident_met_vex: 1 } },
        unlock_text: 'Meet Madame Vex',
        berry: '"Vex is a friend," Berry says carefully. "Listens to living clothes better than most people ' \
               'listen to friends. She loved Covar like a son — which is why it wrecked her when he threw her ' \
               'out over that dress. Be kind when you sit with her, sugar."',
        syn: '"I made a dress once that wouldn\'t shut up. She wore it for decades." Quieter, then a crooked ' \
             'smile. "I still look at her like unfinished homework. She listens anyway. Don\'t make her ' \
             'perform for you — she\'s had enough of that."'
      },
      {
        key: 'resident_pip', label: 'Pip', question: 'What about Pip the Trapwright?',
        category: 'residents', unlock: { requirement: { resident_met_pip: 1 } },
        unlock_text: 'Meet Pip',
        berry: '"Pants," Berry says, automatic. "Tell her I said pants. Genius with hinges. Menace with ' \
               'wardrobe. That\'s the whole briefing."',
        syn: '"She moans over my plates like they\'re lovers." Purr. "Adorable. Useless at clothes. Ask where ' \
             'she\'s from and she\'ll redirect so hard you\'ll be inside a trap before you finish the sentence. ' \
             'Do it. It\'s funny."'
      },
      {
        key: 'resident_nectar', label: 'Sister Nectar', question: 'What about Sister Nectar?',
        category: 'residents', unlock: { requirement: { resident_met_nectar: 1 } },
        unlock_text: 'Meet Sister Nectar',
        berry: '"Means every word of that holy dairy talk." Fond bafflement. "I send her the tense ones. She ' \
               'empties them. I pretend it\'s normal. It is, up here."',
        syn: '"She looks at me like I blessed the pumps." Winces, amused. "I didn\'t. I nod anyway. Sacred ' \
             'awkward — hottest kind of awkward. Don\'t tell Berry I said hottest."'
      },
      {
        key: 'resident_fang', label: 'The Cartographer', question: 'What about the Cartographer?',
        category: 'residents', unlock: { requirement: { resident_met_cartographer: 1 } },
        unlock_text: 'Meet the Cartographer',
        berry: '"Soft. Lost. Good with corners." Berry softens. "Don\'t let Pip crash his sketch mid-line. And ' \
               'if he keeps \'surveying\' one shop more than the others — you didn\'t hear it from me."',
        syn: '"I feed him floor gossip he\'ll never fully get. He blushes and files it." Smirk. "Cute. If you ' \
             'find him loitering somewhere with horns behind the counter, change the subject — he invents ' \
             'excuses faster than maps."'
      },
      {
        key: 'strange_rooms', label: 'Strange rooms', question: 'What about the odd rooms — Confessor, Tea, doors…?',
        category: 'temple', unlock: { any: { 'tea_ceremonies' => 1, 'false_exits_opened' => 1, 'false_exits_knocked' => 1,
                                            'confessor_fights' => 1, 'gorgon_bargains' => 1, 'gorgon_negotiations' => 1,
                                            'spring_soaks' => 1 } },
        unlock_text: 'Meet a strange-room event',
        berry: '"Tea\'s polite — I buy the leaves. The rest?" She fans herself with the ledger. "Confessor ' \
               'wastes an afternoon. Fake doors waste two. Gorgon and the spring girl almost count as people. ' \
               'Be nicer than you feel."',
        syn: '"The land showing off." Lazy shrug. "Sometimes a booth sounds like me saying hi. Sometimes a ' \
             'door is the Queen\'s idea of a joke. Stone likes manners. Soft things like teeth. Negotiate."'
      },
      {
        key: 'resident_vex_deep', label: 'Madame Vex (her story)', question: 'After Vex\'s story…?',
        category: 'residents', unlock: { requirement: { vex_story_done: 1 } },
        unlock_text: 'Finish Madame Vex\'s story',
        berry: '"You walked that with her." Quieter. "Whatever she chose — she\'s still someone I like. Don\'t ' \
               'make me explain her kettle prices twice if she\'s back on her feet."',
        syn: '"You saw how it ended." Soft, then sharp. "She\'s not a museum piece. Talk to her like a person ' \
             'who survived my early work — most people don\'t."'
      },
      {
        key: 'resident_pip_deep', label: 'Pip (milestones)', question: 'After hearing Pip\'s milestones…?',
        category: 'residents', unlock: { requirement: { pip_milestones_heard: 3 } },
        unlock_text: 'Hear all of Pip\'s trap milestones',
        berry: '"Pants. Still." Then softer. "She did something brave with those notes. Don\'t mock it — that\'s ' \
               'sacred nonsense, and I\'ll defend sacred nonsense."',
        syn: '"She wrote love letters to my hinges and then did something stupid-brave for the Queen." Pleased. ' \
             '"Flattering. Her past stays sealed. Ask about plates. Or get caught again — she\'d like that."'
      },
      {
        key: 'resident_nectar_deep', label: 'Sister Nectar (her story)', question: 'After Nectar\'s story…?',
        category: 'residents', unlock: { requirement: { nectar_story_done: 1 } },
        unlock_text: 'Finish Sister Nectar\'s story',
        berry: '"She meant it. All of it." Soft laugh. "Weird. Warm. Send her anyone wound too tight — she\'ll ' \
               'sort them."',
        syn: '"That look she gives me got worse after." Dry. "I still don\'t correct her. Let her have the ' \
             'theology. I\'ll keep the jokes for after service."'
      },
      {
        key: 'resident_fang_deep', label: 'The Cartographer (regular)', question: 'After buying his sketches…?',
        category: 'residents', unlock: { requirement: { sketches_bought: 5 } },
        unlock_text: 'Buy 5 Cartographer sketches',
        berry: '"He\'s getting used to you." Approval. "Still — if Pip barrels through mid-ink, protect the ' \
               'page. And I am not discussing his favourite doorway."',
        syn: '"He filed every scrap I teased him with." Amused. "Regular now. Still invents excuses to ' \
             'blush. Adorable. Don\'t ruin it by naming anything."'
      }
    ].freeze

    # Resident self-talk (ported from Residents::TOPICS + lore crumbs).
    RESIDENT_SELF_TOPICS = {
      'vex' => [
        { key: 'the_piece', label: 'Her piece', category: 'general', unlock: :always,
          question: 'Tell me about the dress.',
          vex: '"It chose me before Covar had a counter. Syn made it with her own hands — she still looks at ' \
               'it like handwriting she forgot writing. It is old, proud, and terrified of being catalogued ' \
               'into retirement. So am I, some mornings."' },
        { key: 'the_language', label: 'Gear language', category: 'general', unlock: :always,
          question: 'How do you hear living gear?',
          vex: '"Creaks are complaints. Tugs are requests. Quiet is planning. Yours hum near what they want. ' \
               'Most call that a curse. I call it a conversation they weren\'t invited to."' },
        { key: 'about_covar', label: 'Covar', category: 'residents', unlock: :always,
          question: 'What about Covar?',
          vex: '"The boy collects strays and calls it a shop." Something almost fond. "Difficult pieces come ' \
               'to my bench. I am the Cursed Shop\'s conscience. It pays terribly."' },
        { key: 'listening', label: 'The Listener', category: 'general', unlock: :always,
          question: 'Why do they call you Listener?',
          vex: '"Because sitting still is a skill, and gear prefers an audience that doesn\'t flinch. Easy. ' \
               'You don\'t have to perform — just talk."' }
      ],
      'pip' => [
        { key: 'the_designers', label: 'The designers', category: 'clergy', unlock: :always,
          question: 'Who designed the traps?',
          pip: '"Syn and the Succubus Queen, every plate. Syn\'s patience, the Queen\'s hinge-work — Dryad ' \
               'talked them into the vines. Nobody maintains them. The land re-dreams them. I take notes."' },
        { key: 'her_notes', label: 'Her notes', category: 'general', unlock: :always,
          question: 'What are the notes for?',
          pip: '"Folded into sprung plates for the Queen." She produces eager handwriting. "A scholar ' \
               'documents. Whether she\'s read one… a scholar doesn\'t ask."' },
        { key: 'staying', label: 'Why she stays', category: 'general', unlock: :always,
          question: 'Why stay in the tower?',
          pip: '"Got caught too often. Eleventh time I started watching. Everyone worships goddesses or ' \
               'fairies. I worship workmanship. Syn thinks it\'s flattering. Syn is right."' },
        { key: 'where_from', label: 'Where she came from', category: 'general', unlock: :always,
          question: 'Where did you come from?',
          pip: '"Oh where\'d I come from? I cum a lot to most of the traps so I\'m not sure what one you—" ' \
               'She lights up. "OH SPEAKING OF TRAPS HAVE YOU BEEN INSIDE THE APHRODISIAC TRAP YET?!"' },
        { key: 'pants', label: 'Pants', category: 'general', unlock: :always,
          question: 'About the pants…',
          pip: '"Fabric gets in the way of field testing." Completely sincere. "You want clean data on a ' \
               'dildo trap, you dress for the science. Berry can yell from the doorway — I\'m busy being ' \
               'accurate."' }
      ],
      'nectar' => [
        { key: 'the_shrine', label: 'The shrine', category: 'temple', unlock: :always,
          question: 'What is the shrine?',
          nectar: '"Older than the machinery. The tower wanted a place where giving was the point, so it grew ' \
                  'one — and me to keep it. Thin nectar means a tired tower. You can taste the mood."' },
        { key: 'the_rooms', label: 'Every milking room', category: 'temple', unlock: :always,
          question: 'How are you everywhere?',
          nectar: '"Station, chamber, shrine — one room. The tower moves it. Don\'t ask how I get around. ' \
                  'Also service ducts, but that ruins it."' },
        { key: 'regulars', label: 'Her regulars', category: 'general', unlock: :always,
          question: 'Who comes to you?',
          nectar: '"The tower sends me the tense ones. I keep a list — names, preferences, how long they hold. ' \
                  'Yours is a short entry, darling. There\'s room."' },
        { key: 'holy', label: 'Holy, not kink', category: 'temple', unlock: :always,
          question: 'Is it really worship?',
          nectar: '"Milking is holy. Treat it like holy. Her Holiness Syn can put the joke away when she\'s ' \
                  'in service."' }
      ],
      'cartographer' => [
        { key: 'the_dreaming', label: 'Dreaming land', category: 'temple', unlock: :always,
          question: 'How do the maps work?',
          cartographer: '"Rooms roll out of the domain\'s sleep. Three ahead, the lean is legible. What I draw ' \
                        'is what you meet — unless a floor lord overrides me. Honest of them."' },
        { key: 'syn_secrets', label: 'Syn\'s secrets', category: 'residents', unlock: :always,
          question: 'Does Syn help?',
          cartographer: '"She teases floor secrets. I mark both versions and pretend I understood the first."' },
        { key: 'covar_crush', label: 'The counter', category: 'residents', unlock: :always,
          question: 'Why mark Covar\'s shop so often?',
          cartographer: '"Covar\'s counter is on this sheet." A beat. "Purely cartographic." He does not look ' \
                        'up. The ears are pink.' },
        { key: 'pip_pants', label: 'Pip', category: 'residents', unlock: :always,
          question: 'Thoughts on Pip?',
          cartographer: '"I wish she would wear pants. The maps deserve dignity."' }
      ]
    }.freeze

    # Victory-only clergy self-talk (4–6 topics each).
    CLERGY_SELF_TOPICS = {
      'broodmother' => [
        { key: 'self', label: 'Who she is', category: 'general', unlock: :always,
          broodmother: '"Brood. Lid. Table that never ends. Syn was my favourite taste that became a person. ' \
                       'You are brood that has not admitted it yet."' },
        { key: 'syn', label: 'Syn', category: 'residents', unlock: :always,
          broodmother: '"She bargained out. Then she came back with a temple and called hunger worship. Clever ' \
                       'meal."' },
        { key: 'keeping', label: 'Keeping you', category: 'general', unlock: :always,
          broodmother: '"I keep. The temple steals upward. I have never learned to forgive that theft."' },
        { key: 'domain', label: 'Her floors', category: 'temple', unlock: :always,
          broodmother: '"Open it. Take it. Crawl inside. Curiosity, greed, comfort — same door."' },
        { key: 'returnee', label: 'Coming back', category: 'temple', unlock: { requirement: { cycles_completed: 1 } },
          unlock_text: 'Complete a cycle',
          broodmother: '"She spat you out again? Fine. Get inside. I\'ll keep what\'s mine until she steals you."' }
      ],
      'queen' => [
        { key: 'self', label: 'Who she is', category: 'general', unlock: :always,
          queen: '"Court manners. Trap craft. Being worshipped is good manners finally enforced by architecture."' },
        { key: 'syn', label: 'Syn', category: 'residents', unlock: :always,
          queen: '"Darling disaster. Best friend. We built every hinge together. Tell her I laughed."' },
        { key: 'traps', label: 'The traps', category: 'temple', unlock: :always,
          queen: '"Syn\'s patience, my cruelty. A trap should leave you thinking about me."' },
        { key: 'vex', label: 'Madame Vex', category: 'residents', unlock: :always,
          queen: '"Even I don\'t bother knowing sluts that desperate." Soft laugh. "Don\'t quote me to Syn."' },
        { key: 'returnee', label: 'Coming back', category: 'temple', unlock: { requirement: { cycles_completed: 1 } },
          unlock_text: 'Complete a cycle',
          queen: '"She keeps sending my toys home. I still want you on your knees — and I love that you remember."' }
      ],
      'king' => [
        { key: 'self', label: 'Who he is', category: 'general', unlock: :always,
          king: '"Gorgeous. Gifted. Unbearable. Syn collected a debt and called it priesthood. Fair."' },
        { key: 'syn', label: 'Syn', category: 'residents', unlock: :always,
          king: '"Come here. Syn said I could. She still holds the leash on the working we built."' },
        { key: 'spawn', label: 'The spawning', category: 'temple', unlock: :always,
          king: '"My half keeps the halls stocked. Appetite shaped into teeth. You\'re welcome."' },
        { key: 'berry', label: 'Berry', category: 'residents', unlock: :always,
          king: '"I hit on her. Constantly. Liturgy. With Syn watching I behave. Mostly."' },
        { key: 'returnee', label: 'Coming back', category: 'temple', unlock: { requirement: { cycles_completed: 1 } },
          unlock_text: 'Complete a cycle',
          king: '"Third time and you\'re still dripping for me. She can have the climb — I claimed the rest."' }
      ],
      'dryad' => [
        { key: 'self', label: 'Who she is', category: 'general', unlock: :always,
          dryad: '"Rooted. Feeding. Syn\'s weather that stayed. Eat. Stay. The grove has room."' },
        { key: 'syn', label: 'Syn', category: 'residents', unlock: :always,
          dryad: '"I fed her before the temple. Fruit and firmness. She still forgets water. I remember."' },
        { key: 'vines', label: 'Vines & tentacles', category: 'temple', unlock: :always,
          dryad: '"My daydreams. Syn made them eager. Hospitality with grip."' },
        { key: 'keeping', label: 'Staying', category: 'general', unlock: :always,
          dryad: '"I lose delvers the way seasons lose leaves. Sadder than I say. Come back slowly."' },
        { key: 'returnee', label: 'Coming back', category: 'temple', unlock: { requirement: { cycles_completed: 1 } },
          unlock_text: 'Complete a cycle',
          dryad: '"My leaf came back. Plant yourself. I\'ll mourn you again when she pulls you free."' }
      ],
      'lich' => [
        { key: 'self', label: 'Who he is', category: 'general', unlock: :always,
          lich: '"Teacher. Apparatus. A thousand years cold. Fascinating. Wrong, but fascinating."' },
        { key: 'syn', label: 'Syn', category: 'residents', unlock: :always,
          lich: '"My rare living pupil. Pride I will not admit. When she impresses me, the frost crown flickers."' },
        { key: 'lust_energy', label: 'Lust energy', category: 'temple', unlock: :always,
          lich: '"Desire made to work. I taught her. The temple is longitudinal study with better furniture."' },
        { key: 'data', label: 'You as data', category: 'general', unlock: :always,
          lich: '"Warmth and numbers, in that reverse order on the paperwork. Do not waste either."' },
        { key: 'returnee', label: 'Coming back', category: 'temple', unlock: { requirement: { cycles_completed: 1 } },
          unlock_text: 'Complete a cycle',
          lich: '"Longitudinal study continues. She returns you; I take notes — and heat."' }
      ],
      'alpha' => [
        { key: 'self', label: 'Who he is', category: 'general', unlock: :always,
          alpha: '*…mate.* Soft eyes. Honest rut. Pack-room because Syn asked.' },
        { key: 'syn', label: 'Syn', category: 'residents', unlock: :always,
          alpha: 'Ear-sit memory. Tiny weight between huge ears. She scratches; he wags. Complete.' },
        { key: 'pack', label: 'The pack', category: 'temple', unlock: :always,
          alpha: 'Bran speaks when he sleeps. Lumen tends dens. Nettle barrels into legs. Family.' },
        { key: 'keeping', label: 'Claim', category: 'general', unlock: :always,
          alpha: 'Temporary mate. Scent-mark. Good ones come back like weather.' },
        { key: 'returnee', label: 'Coming back', category: 'temple', unlock: { requirement: { cycles_completed: 1 } },
          unlock_text: 'Complete a cycle',
          alpha: '*Good mate comes back. Weather. Rut again.*' }
      ],
      'eros' => [
        { key: 'self', label: 'Who she is', category: 'general', unlock: :always,
          eros: '"Depravity. Hunger. Syn knelt and fed me when the world forgot. You are climbing my appetite."' },
        { key: 'syn', label: 'Syn', category: 'residents', unlock: :always,
          eros: '"Favourite little fairy slut. Possessive. Her handwriting on my property is flirtation."' },
        { key: 'cycles', label: 'The cycles', category: 'temple', unlock: :always,
          eros: '"My answer to their temple. Surrender once is a beginning. I send you back myself."' },
        { key: 'surrender', label: 'What she wants', category: 'general', unlock: :always,
          eros: '"Not keeping. Not service. The giving-in. That\'s the offering. Again."' },
        { key: 'returnee', label: 'Sending you back', category: 'temple', unlock: :always,
          eros: '"I sent you back full of me. Climb. Break. Bring it to my mouth once more."' }
      ]
    }.freeze

    module_function

    def normalize_person(person)
      PEOPLE.key?(person.to_s) ? person.to_s : 'berry'
    end

    def person(person)
      PEOPLE[normalize_person(person)]
    end

    def fairy?(person)
      FAIRY_PEOPLE.include?(normalize_person(person))
    end

    def covar?(person)
      normalize_person(person) == 'covar'
    end

    def resident?(person)
      RESIDENT_PEOPLE.include?(normalize_person(person))
    end

    def clergy?(person)
      CLERGY_PEOPLE.include?(normalize_person(person))
    end

    def victory_only?(person)
      !!person(person)[:victory_only]
    end

    def boss_person_for(boss_name)
      BOSS_PERSON[Engine::BossFights.canonical_name(boss_name)]
    end

    def category_label(key)
      CATEGORIES.find { |c| c[:key] == key.to_s }&.dig(:label) || key.to_s.capitalize
    end

    def boss_seen?(player, boss_name)
      canonical = Engine::BossFights.canonical_name(boss_name)
      Array(player.tracker_hash['bosses_seen'])
        .map { |name| Engine::BossFights.canonical_name(name) }
        .include?(canonical)
    end

    def unlocked?(player, topic)
      return boss_seen?(player, topic[:boss]) if topic[:boss]

      unlock = topic[:unlock]
      return true if unlock.nil? || unlock == :always
      return Engine::TitleSystem.met?(player, unlock[:requirement]) if unlock[:requirement]
      if unlock[:any]
        return unlock[:any].any? { |key, need| player.tracker(key) >= need.to_i }
      end

      false
    end

    def unlock_hint(player, topic)
      return "Defeat or satisfy #{topic[:boss]} (floor #{topic[:floor]}) once" if topic[:boss]

      unlock = topic[:unlock]
      return topic[:unlock_text].to_s if unlock == :always || unlock.nil?

      base = topic[:unlock_text].to_s
      progress =
        if unlock[:requirement]
          Engine::TitleSystem.progress_text(player, unlock[:requirement])
        elsif unlock[:any]
          unlock[:any].map { |key, need| "#{[player.tracker(key), need].min}/#{need} #{key.tr('_', ' ')}" }.join(' or ')
        end
      progress && !progress.empty? ? "#{base} — #{progress}" : base
    end

    # Fairy Ask-abouts: general + residents + temple + clergy bosses.
    def fairy_topics(player)
      general = TOPICS.map { |topic| present(player, topic) }
      bosses = BOSS_TOPICS.map do |spec|
        present(player, spec.merge(
                          BOSS_ANSWERS.fetch(spec[:key], {}),
                          revealed_berry: REVEALED_BOSS_ANSWERS.dig(spec[:key], :berry),
                          revealed_syn: REVEALED_BOSS_ANSWERS.dig(spec[:key], :syn),
                          question: "What about #{spec[:label]}?",
                          unlock_text: "Defeat or satisfy #{spec[:label]} once"
                        ))
      end
      general + bosses
    end

    # The reveal: earned by a first return from floor 35, delivered by Syn
    # in person, and remembered afterwards.
    def temple_revealed?(player)
      player.tracker('temple_revealed').positive?
    end

    def reveal_ready?(player)
      !temple_revealed?(player) && player.tracker('cycles_completed').positive?
    end

    def note_revealed!(player)
      player.set_tracker!('temple_revealed', 1)
    end

    def topics_for(player, person)
      person = normalize_person(person)
      list =
        if person == 'covar'
          COVAR_TOPICS
        elsif RESIDENT_PEOPLE.include?(person)
          RESIDENT_SELF_TOPICS.fetch(person, [])
        elsif CLERGY_PEOPLE.include?(person)
          CLERGY_SELF_TOPICS.fetch(person, [])
        else
          return fairy_topics(player)
        end
      list.map { |topic| present(player, topic) }
    end

    def topics_in_category(player, person, category)
      topics_for(player, person).select { |t| (t[:category] || 'general').to_s == category.to_s }
    end

    def categories_for(player, person)
      cats = topics_for(player, person).select { |t| t[:unlocked] }
                                       .map { |t| (t[:category] || 'general').to_s }.uniq
      CATEGORIES.select { |c| cats.include?(c[:key]) }
    end

    def covar_topics_heard(player)
      Array(player.tracker_hash['covar_topics_heard']).map(&:to_s) & COVAR_TOPICS.map { |t| t[:key] }
    end

    def note_covar_topic!(player, key)
      player.remember!('covar_topics_heard', key.to_s)
    end

    def covar_sex_unlocked?(player)
      covar_topics_heard(player).size >= COVAR_SEX_TOPICS_REQUIRED
    end

    # Fucking his breasts or his ass takes a cock of the delver's own —
    # and an uncaged one; his cock is for everyone.
    def covar_sex_available?(player, part)
      spec = COVAR_SEX[part.to_s]
      return false unless spec

      need = spec[:needs_part]
      need.nil? || Engine::ChastitySystem.scene_parts(player).include?(need)
    end

    def covar_sex(player, part)
      spec = COVAR_SEX[part.to_s]
      return { ok: false, message: 'Covar raises an eyebrow. "Pick a part of me, delver."' } unless spec
      unless covar_sex_unlocked?(player)
        return { ok: false,
                 message: "Covar smiles and shakes his head. \"Get to know me first — " \
                          "#{covar_topics_heard(player).size}/#{COVAR_SEX_TOPICS_REQUIRED} conversations. " \
                          'I like to be courted."' }
      end
      unless covar_sex_available?(player, part)
        need = spec[:needs_part]
        if need && player.body_parts_list.map(&:to_s).include?(need.to_s)
          return { ok: false,
                   message: "Covar's gaze drops to your cage, then returns with a sympathetic grin. \"Locked " \
                            'away, delver? That one needs your cock free and hard. My cock, though? That\'s ' \
                            'for everyone."' }
        end
        return { ok: false,
                 message: "Covar's gaze drops, then returns with a sympathetic grin. \"That one needs a " \
                          'cock of your own, delver — and the tower didn\'t give you one. My cock, though? ' \
                          'That\'s for everyone."' }
      end

      cleared = player.lust.to_i
      player.update(lust: 0)
      player.bump_tracker!('covar_trysts')
      { ok: true, part: part.to_s, lust_cleared: cleared, text: covar_text(player, part, spec) }
    end

    # The bead curtain should feel like a relationship, not a vending
    # machine: at 1 / 5 / 10 / 25 trysts the counter talk changes, once.
    COVAR_MILESTONES = {
      1 => '_Afterwards, Covar props himself on an elbow and grins like a man keeping a new secret. ' \
           '"First time behind my curtain," he says. "The gear pretends to sleep, you know. It never ' \
           'does. Neither do I, the first time."_',
      5 => '_"Five," Covar says, before you ask, and taps the headboard where five small notches have ' \
           'appeared that were not there before. "I keep count of the ones who come back, delver. ' \
           'Customers come once. You\'re becoming furniture." He says it like a promotion._',
      10 => '_"Ten times," Covar says, and produces — from where, in a bed, there is no saying — two cups ' \
            'of something that steams. "Staff discount. Drink. The gear by the door has started making ' \
            'room for your boots, have you noticed? It approves of you. It is an excellent judge."_',
      25 => '_"Twenty-five." Covar says it to the ceiling, a little wonderingly. "Syn asked after you by ' \
            'name, you know. Berry has opinions. Eros—" he catches himself and laughs, low and genuinely ' \
            'happy. "Careful, delver. Keep coming back and the shop will start calling you family. Keep ' \
            'coming back after that and it\'ll be true."_'
    }.freeze

    def covar_milestone_line(player)
      reached = COVAR_MILESTONES.keys.select { |m| player.tracker('covar_trysts') >= m }.max
      return nil unless reached && player.tracker('covar_milestone_seen') < reached

      player.set_tracker!('covar_milestone_seen', reached)
      COVAR_MILESTONES[reached]
    end

    # His cock goes where the delver's body invites it: pussy when they have
    # one free, ass otherwise. The other two options are already explicit.
    def covar_text(player, part, spec)
      return spec[:text] unless part.to_s == 'cock'

      parts = Engine::ChastitySystem.scene_parts(player)
      taken =
        if parts.include?('vagina')
          'He slides his cock into your pussy in one sure stroke and fucks you deep, grinding against your clit ' \
          'with every roll of his hips until your orgasm tears out of you around him'
        else
          'He slides his cock into your ass in one sure stroke and fucks you deep, one hand spread between your ' \
          'shoulders, until your orgasm tears out of you under him'
        end
      'He turns you against his own counter with an incubus\'s certainty, the bell above his shop door politely ' \
        "ignored. \"My counter, my rules,\" Covar growls. #{taken}, and his own orgasm follows with a groan he " \
        'does not bother to hide. "There," he says, breathless and pleased. "Drained. You\'re welcome."'
    end

    def available_topics(player, person)
      topics_for(player, person).select { |topic| topic[:unlocked] }.first(25)
    end

    def boss_satisfied?(player, topic)
      return false unless topic[:boss]

      Array(player.tracker_hash['bosses_satisfied_names'])
        .map { |name| Engine::BossFights.canonical_name(name) }
        .include?(Engine::BossFights.canonical_name(topic[:boss]))
    end

    def answer(player, person, key)
      person = normalize_person(person)
      topic = topics_for(player, person).find { |t| t[:key] == key.to_s }
      return { ok: false, message: 'They have nothing to say about that.' } unless topic
      unless topic[:unlocked]
        return { ok: false, topic: topic, message: "🔒 **#{topic[:label]}** — #{unlock_hint(player, topic)}" }
      end

      revealed_now = temple_revealed?(player)
      revealed = REVEALED_GENERAL.dig(topic[:key], person.to_sym) if revealed_now
      full = revealed || topic[:"revealed_#{person}"] if revealed_now
      full = (full || topic[person.to_sym]).to_s
      # Covar has one topic he feels differently about once the dress
      # has been persuaded off Vex and onto the mannequin — and
      # differently again once he is wearing it himself.
      if person == 'covar' && topic[:key] == 'vex_dress'
        if player.tracker('vex_restoration_done').positive?
          full = topic[:covar_restored].to_s
        elsif player.tracker_hash['vex_ending'].to_s == 'mannequin'
          full = topic[:covar_after].to_s
        end
      end

      # The fairies remember being asked: first answer in full, repeats in
      # a shorter familiar version (revealed repeats keep the long form,
      # with a familiar frame).
      token = "#{person}:#{topic[:key]}:#{revealed_now ? 'r' : 'c'}"
      heard = Array(player.tracker_hash['talk_heard']).map(&:to_s).include?(token)
      repeat = (REPEAT_BOSS.dig(topic[:key], person.to_sym) || REPEAT_GENERAL.dig(topic[:key], person.to_sym)) unless revealed_now
      text =
        if heard && repeat
          repeat
        elsif heard && revealed_now
          "_Asked me that before — still true._\n#{full}"
        else
          full
        end

      # Satisfying this boss earns extra, the first time it comes up.
      satisfied_extra = nil
      if !heard && topic[:boss] && boss_satisfied?(player, topic)
        satisfied_extra = SATISFY_EXTRAS.dig(topic[:key], person.to_sym)
        text = "#{text}\n\n#{satisfied_extra}" if satisfied_extra
      end

      player.remember!('talk_heard', token) unless person == 'covar'
      { ok: true, person: person, topic: topic, text: text, heard_before: heard,
        satisfied_extra: !satisfied_extra.nil? }
    end

    def present(player, topic)
      topic.merge(unlocked: unlocked?(player, topic))
    end
  end
end
