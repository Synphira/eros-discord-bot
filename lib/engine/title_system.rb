# frozen_string_literal: true

module Engine
  module TitleSystem
    TITLES = {
      'novice' => {
        name: 'Novice Explorer',
        requirement: { floors_cleared: 3 },
        description: "You've begun your journey into the tower"
      },
      'experienced' => {
        name: 'Dungeon Delver',
        requirement: { floors_cleared: 10 },
        description: "You're growing familiar with the tower's dangers"
      },
      'survivor' => {
        name: 'Tower Survivor',
        requirement: { floors_cleared: 20 },
        description: "You've endured what few can withstand"
      },
      'master' => {
        name: 'Tower Master',
        requirement: { cycles_completed: 1 },
        description: "You've conquered the entire tower and returned victorious"
      },
      'legendary' => {
        name: 'Legendary Hero',
        requirement: { cycles_completed: 3 },
        description: 'Your name is whispered throughout the land as a tower conqueror'
      },
      'mythic' => {
        name: 'Mythic Champion',
        requirement: { cycles_completed: 5 },
        description: "You've achieved what was thought impossible"
      },
      'lustful' => {
        name: 'Lustful',
        requirement: { lp_earned: 500 },
        description: "You've embraced the tower's carnal pleasures"
      },
      'submissive' => {
        name: 'Willing Prey',
        requirement: { submissions: 20 },
        description: "You've learned to find pleasure in submission"
      },
      'cursed' => {
        name: 'Cursed Collector',
        requirement: { curses_acquired: 10 },
        description: 'You wear many curses with pride'
      },
      'rich' => {
        name: 'Treasure Hunter',
        requirement: { treasure_found: 100 },
        description: "You've amassed great wealth in your adventures"
      },

      'beast_breeder' => {
        name: 'Beast Breeder',
        requirement: { beast_submissions: 15 },
        description: "You've willingly offered yourself to beasts many times"
      },
      'demon_consort' => {
        name: 'Demon Consort',
        requirement: { demon_submissions: 15 },
        description: "You've pleased demons enough to earn their favor"
      },
      'slime_vessel' => {
        name: 'Slime Vessel',
        requirement: { slime_submissions: 15 },
        description: 'Your body has become a home for slime creatures'
      },
      'undead_paramour' => {
        name: 'Undead Paramour',
        requirement: { undead_submissions: 15 },
        description: 'Even the dead desire your touch'
      },
      'plant_pollinated' => {
        name: 'Plant Pollinated',
        requirement: { plant_submissions: 15 },
        description: "You've been fertilized by the tower's flora"
      },
      'depraved_one' => {
        name: 'Depraved One',
        requirement: { depraved_tower_clears: 7 },
        description: 'You conquered the Tower Lord seven times with every desire laid bare'
      },
      'mimic_seedbed' => {
        name: 'Mimic Seedbed',
        requirement: { mimic_broodmother_cursed: true },
        description: "You defeated or satisfied the Broodmother while fully cursed, earning the mimics' respect"
      },
      'succubus_bane' => {
        name: 'Succubus Bane',
        requirement: { succubus_defeats: 10 },
        description: 'Ten succubi have fallen to you — their sisters whisper your name in fear'
      },
      'succubus_pet' => {
        name: "Succubus's Pet",
        requirement: { succubus_submissions: 8 },
        description: 'Succubi have claimed you as their favourite plaything'
      },
      'incubus_bane' => {
        name: 'Incubus Bane',
        requirement: { incubus_defeats: 10 },
        description: 'Ten incubi have fallen to you — their charm no longer works'
      },
      'incubus_toy' => {
        name: "Incubus's Plaything",
        requirement: { incubus_submissions: 8 },
        description: 'Incubi seek you out, knowing how eagerly you yield'
      },
      'royal_consort' => {
        name: 'Royal Consort',
        requirement: { royal_demons_cleared: 2, succubus_submissions: 3, incubus_submissions: 3 },
        description: 'You have known both the Succubus Queen and the Incubus King — and their kin'
      },

      'pure' => {
        name: 'Pure',
        requirement: { run_floors_cleared: 30, run_submissions: { max: 0 } },
        description: 'Clear 30 floors in a single run without ever submitting'
      },
      'broken' => {
        name: 'Broken',
        requirement: { submissions: 100 },
        description: "You've completely surrendered to your desires"
      },
      'addicted' => {
        name: 'Lust Addict',
        requirement: { lp_earned: 2000, submissions: 50 },
        description: 'You crave the touch of monsters more than anything'
      },
      'pit_survivor' => {
        name: 'Pit Survivor',
        requirement: { tentacle_pit_survived: 5 },
        description: "You've been claimed by the pit and survived"
      },
      'glory_hole_veteran' => {
        name: 'Glory Hole Veteran',
        requirement: { glory_hole_encounters: 20 },
        description: "You've serviced many unseen partners through the wall"
      },
      'trap_springer' => {
        name: 'Trap Expert',
        requirement: { traps_triggered: 50 },
        description: "You've experienced every trap the tower has to offer"
      },

      'sin_sculptor' => {
        name: 'Sin Sculptor',
        requirement: { is_developer: true },
        description: 'Shaper of the Endless Ruins — every sin here was carved by your hand'
      },
      'climax_checker' => {
        name: 'Climax Checker',
        requirement: { is_bug_tester: true },
        description: 'Bug tester — you have endured the tower\'s flaws so others can endure its pleasures'
      }
    }.merge(
      {
        'bimbo' => ['Bimbo', :bimbo_transformations, 5, "You've embraced the simple pleasure of being pretty and desirable"],
        'inflated' => ['Living Balloon', :inflation_events, 5, 'Your body has learned to enjoy the pleasure of swelling'],
        'clothing_host' => ['Clothing Host', :living_clothing_acquired, 3, 'You willingly wear things that wear you back'],
        'pet' => ['Good Pet', :petplay_events, 5, "You've found contentment in submission and service to beasts"],
        'rubberized' => ['Rubber Doll', :latex_events, 5, 'Your body is encased in the tight embrace of synthetic pleasure'],
        'broodmother' => ['Broodmother', :oviposition_events, 3, "You've carried the young of creatures within you"],
        'chaste' => ['Chaste Slave', :chastity_events, 5, 'Your pleasure is denied so you may serve others better'],
        'chastity_denied' => ['Eternally Denied', :denied_climaxes, 25, 'Locked away and denied so often that release is only a memory'],
        'empty_head' => ['Empty Head', :mind_control_events, 5, "You've found freedom in giving up your thoughts"],
        'cumslut' => ['Cum Covered', :bukkake_events, 5, 'You wear the essence of many creatures like a badge of honor'],
        'public_display' => ['Public Display', :exhibitionism_events, 5, 'Your body is a gift to be seen by all'],
        'macrophile' => ['Giant', :body_growth_events, 3, "You've experienced the pleasure of growing to immense size"],
        'microphile' => ['Miniature', :body_reduction_events, 3, "You've experienced the pleasure of becoming tiny and vulnerable"],
        'futanari' => ['Complete Being', :futanari_events, 3, "You've experienced the pleasure of having both male and female anatomy"],
        'objectified' => ['Human Furniture', :objectification_events, 3, "You've experienced the pleasure of being used as an object"],
        'gender_fluid' => ['Gender Bender', :gender_bending_events, 3, "You've experienced the pleasure of changing your physical form"],
        'milked' => ['Dairy Cow', :being_milked_events, 3, "You've experienced the pleasure of being milked like livestock"],
        'bred' => ['Mother', :impregnation_events, 3, "You've experienced the pleasure of being bred and carrying offspring"],
        'lactating' => ['Nourishing', :lactation_events, 3, "You've experienced the pleasure of producing milk"],
        'marked' => ['Marked Territory', :watersports_events, 3, "You've experienced the pleasure of being marked"],
        'bound' => ['Tightly Bound', :bondage_events, 3, "You've experienced the pleasure of complete restraint"],
        'disciplined' => ['Punished', :discipline_events, 3, "You've experienced the pleasure of discipline and punishment"],
        'shamed' => ['Public Shame', :humiliation_events, 3, "You've experienced the pleasure of public humiliation"],
        'blank_slate' => ['Blank Slate', :mindbreak_events, 3, "You've experienced the pleasure of having your mind completely broken"],
        'deprived' => ['Sensory Void', :sensory_deprivation_events, 3, "You've experienced the pleasure of sensory deprivation"],
        'owned' => ['Property', :slavery_events, 3, "You've experienced the pleasure of being completely owned"],
        'strapped' => ['Penetrator', :strap_on_events, 3, "You've experienced the pleasure of strap-on play"],
        'cum_covered' => ['Facialized', :facial_events, 3, "You've experienced the pleasure of being covered in essence"],
        'foot_worshipper' => ['Footservant', :foot_fetish_events, 3, "You've experienced the pleasure of worshipping feet"],
        'groupie' => ['Groupie', :group_sex_events, 3, "You've experienced the pleasure of group encounters"],
        'performer' => ['Crowd Pleaser', :public_play_events, 3, "You've experienced the pleasure of public display"],
        'voyeur' => ['Watcher', :voyeurism_events, 3, "You've experienced the pleasure of watching without being seen"],
        'well_fed' => ['Feeder', :weight_gain_events, 3, "You've experienced the pleasure of gaining weight and size"],
        'beastkin' => ['Beastkin', :furry_events, 3, "You've experienced the pleasure of taking on animal traits"],
        'overstimulated' => ['Overstimulated', :overstim_events, 3, 'You have been made to orgasm far past the point of mercy'],
        'giggle_toy' => ['Giggle Toy', :tickling_events, 3, 'You squirm, shriek, and drip under every feather'],
        'sissy' => ['Pretty Sissy', :sissy_events, 3, 'Lace, lipstick, and a perfect curtsy'],
        'corrupted' => ['Corrupted', :corruption_events, 3, 'You drank the taint willingly, again and again'],
        'living_canvas' => ['Living Canvas', :body_writing_events, 3, 'Your skin has been written on by every imp in the tower'],
        'scent_hound' => ['Scent Hound', :musk_events, 3, 'One breath of musk and you are on your knees'],
        'fire_and_ice' => ['Fire & Ice', :temperature_events, 3, 'Frost and warm wax have both had their way with you'],
        'size_queen' => ['Size Queen', :size_events, 3, 'The bigger they are, the better'],
        'cum_drenched' => ['Cum-Drenched', :cum_play_events, 3, 'You have bathed in it, drunk it, and worn it proudly'],
        'degraded' => ['Degraded', :degradation_events, 3, 'You answer to every filthy name they call you'],
        'shapeshifted' => ['Monstrous', :monster_form_events, 3, 'You have worn the bodies of the tower\'s creatures'],
        'head_maid' => ['Head Maid', :maid_events, 3, 'The house has never been served so thoroughly'],
        'show_pony' => ['Show Pony', :pony_events, 3, 'Harnessed, bridled, and ridden'],
        'silenced' => ['Silenced', :gag_events, 3, 'Gagged and hooded, and better for it']
      }.transform_values do |name, tracker, count, desc|
        { name: name, requirement: { tracker => count }, description: desc }
      end
    ).freeze

    TITLE_PRIORITY = %w[
      sin_sculptor climax_checker depraved_one mythic legendary master royal_consort mimic_seedbed survivor experienced novice cursed lustful submissive rich
      broken addicted pure succubus_bane incubus_bane succubus_pet incubus_toy beast_breeder demon_consort
      slime_vessel undead_paramour plant_pollinated pit_survivor glory_hole_veteran trap_springer
    ].freeze

    ACHIEVEMENT_CATEGORIES = {
      'combat' => 'Combat',
      'submission' => 'Submission',
      'exploration' => 'Exploration',
      'curses' => 'Curses',
      'lust' => 'Lust',
      'events' => 'Events',
      'kinks' => 'Kinks',
      'challenges' => 'Challenges'
    }.freeze

    KINK_ACHIEVEMENTS = [
      ['first_bimbo', 'Airheaded', 'Experience your first bimbo transformation', :bimbo_transformations, 1, 15],
      ['inflation_veteran', 'Full of Air', 'Experience inflation 3 times', :inflation_events, 3, 25],
      ['clothing_collector', 'Wardrobe', 'Acquire 3 living clothing items', :living_clothing_acquired, 3, 30],
      ['pet_trained', 'Trained Pet', 'Submit to being a pet 5 times', :petplay_events, 5, 35],
      ['rubber_addict', 'Rubber Addict', 'Experience rubber latex events 5 times', :latex_events, 5, 30],
      ['broodmother', 'Broodmother', 'Experience oviposition 3 times', :oviposition_events, 3, 40],
      ['chastity_veteran', 'Denial Expert', 'Wear chastity 5 times', :chastity_events, 5, 35],
      ['mind_controlled', 'Empty Mind', 'Experience mind control 3 times', :mind_control_events, 3, 30],
      ['bukkake_star', 'Bukkake Star', 'Experience group facial events 3 times', :bukkake_events, 3, 40],
      ['exhibitionist', 'Public Display', 'Expose yourself 5 times', :exhibitionism_events, 5, 30],
      ['body_growth_veteran', 'Growing Pains', 'Experience body growth 3 times', :body_growth_events, 3, 25],
      ['body_reduction_veteran', 'Mini Me', 'Experience body reduction 3 times', :body_reduction_events, 3, 25],
      ['futanari_veteran', 'Complete Being', 'Experience futanari transformation 3 times', :futanari_events, 3, 30],
      ['objectification_veteran', 'Objectified', 'Experience objectification 3 times', :objectification_events, 3, 25],
      ['gender_bending_veteran', 'Shapeshifter', 'Experience gender bending 3 times', :gender_bending_events, 3, 25],
      ['being_milked_veteran', 'Dairy', 'Experience being milked 3 times', :being_milked_events, 3, 25],
      ['impregnation_veteran', 'Breeder', 'Experience impregnation 3 times', :impregnation_events, 3, 30],
      ['lactation_veteran', 'Nourishing', 'Experience lactation 3 times', :lactation_events, 3, 25],
      ['watersports_veteran', 'Marked', 'Experience watersports 3 times', :watersports_events, 3, 25],
      ['bondage_veteran', 'Restrained', 'Experience bondage 3 times', :bondage_events, 3, 25],
      ['discipline_veteran', 'Disciplined', 'Experience discipline 3 times', :discipline_events, 3, 25],
      ['humiliation_veteran', 'Shamed', 'Experience humiliation 3 times', :humiliation_events, 3, 25],
      ['mindbreak_veteran', 'Mindless', 'Experience mindbreak 3 times', :mindbreak_events, 3, 30],
      ['sensory_deprivation_veteran', 'Deprived', 'Experience sensory deprivation 3 times', :sensory_deprivation_events, 3, 25],
      ['slavery_veteran', 'Owned', 'Experience slavery 3 times', :slavery_events, 3, 30],
      ['strap_on_veteran', 'Strapped', 'Experience strap-on encounters 3 times', :strap_on_events, 3, 25],
      ['facial_veteran', 'Facialized', 'Experience facial encounters 3 times', :facial_events, 3, 25],
      ['foot_fetish_veteran', 'Footservant', 'Experience foot worship 3 times', :foot_fetish_events, 3, 25],
      ['group_sex_veteran', 'Groupie', 'Experience group sex 3 times', :group_sex_events, 3, 30],
      ['public_play_veteran', 'Exhibitionist', 'Experience public play 3 times', :public_play_events, 3, 25],
      ['voyeurism_veteran', 'Watcher', 'Experience voyeurism 3 times', :voyeurism_events, 3, 25],
      ['weight_gain_veteran', 'Well Fed', 'Experience weight gain 3 times', :weight_gain_events, 3, 25],
      ['furry_veteran', 'Beastkin', 'Experience furry transformation 3 times', :furry_events, 3, 25],
      ['overstim_veteran', 'Too Much', 'Survive the overstimulation engine 3 times', :overstim_events, 3, 35],
      ['tickling_veteran', 'Ticklish', 'Get tickled senseless 3 times', :tickling_events, 3, 20],
      ['sissy_veteran', 'Pretty in Pink', 'Get dolled up 3 times', :sissy_events, 3, 25],
      ['corruption_veteran', 'Tainted', 'Drink from the corrupting font 3 times', :corruption_events, 3, 30],
      ['body_writing_veteran', 'Labelled', 'Get written on 3 times', :body_writing_events, 3, 20],
      ['musk_veteran', 'Musk-Drunk', 'Roll in a musk den 3 times', :musk_events, 3, 25],
      ['temperature_veteran', 'Hot and Cold', 'Play with ice or wax 3 times', :temperature_events, 3, 20],
      ['size_veteran', 'Stretched', 'Take something huge 3 times', :size_events, 3, 30],
      ['cum_play_veteran', 'Cum Fountain', 'Bathe in or drink from the cum fountain 3 times', :cum_play_events, 3, 25],
      ['degradation_veteran', 'No Pride Left', 'Visit the jeering gallery 3 times', :degradation_events, 3, 25],
      ['monster_form_veteran', 'Becoming', 'Wade into the pool of becoming 3 times', :monster_form_events, 3, 30],
      ['maid_veteran', 'At Your Service', 'Serve the monster manor 3 times', :maid_events, 3, 25],
      ['pony_veteran', 'Well Trained', 'Get harnessed in the stables 3 times', :pony_events, 3, 25],
      ['gag_veteran', 'Mmmph', 'Wear a gag or hood 3 times', :gag_events, 3, 25],
      ['denied_frustrated', 'Frustrated', 'Have an orgasm denied by chastity 5 times', :denied_climaxes, 5, 20],
      ['denied_desperate', 'Desperate', 'Have an orgasm denied by chastity 10 times', :denied_climaxes, 10, 40],
      ['denied_broken', 'Broken by Denial', 'Have an orgasm denied by chastity 25 times', :denied_climaxes, 25, 80],
      ['kink_explorer', 'Kink Explorer', 'Accept 25 fetish events', :fetish_events_accepted, 25, 50],
      ['kink_connoisseur', 'Connoisseur of Sin', 'Accept 100 fetish events', :fetish_events_accepted, 100, 150]
    ].map do |id, name, desc, tracker, count, lp|
      { id: id, category: 'kinks', name: name, description: desc, requirement: { tracker => count }, reward: { lp: lp } }
    end.freeze

    ACHIEVEMENTS = [
      { id: 'first_kill', category: 'combat', name: 'First Blood', description: 'Defeat your first monster',
        requirement: { monsters_killed: 1 }, reward: { lp: 10 } },
      { id: 'slayer', category: 'combat', name: 'Monster Slayer', description: 'Defeat 50 monsters',
        requirement: { monsters_killed: 50 }, reward: { lp: 50 } },
      { id: 'champion', category: 'combat', name: 'Tower Champion', description: 'Defeat 200 monsters',
        requirement: { monsters_killed: 200 }, reward: { lp: 150 } },
      { id: 'elite_hunter', category: 'combat', name: 'Elite Hunter', description: 'Defeat 10 elite monsters',
        requirement: { elites_defeated: 10 }, reward: { lp: 60 } },
      { id: 'elite_pleaser', category: 'submission', name: 'Elite Pleaser', description: 'Satisfy 10 elite monsters',
        requirement: { elites_satisfied: 10 }, reward: { lp: 60 } },
      { id: 'chest_resister', category: 'exploration', name: 'Iron Will', description: 'Walk away from 25 treasure chests',
        requirement: { chests_ignored: 25 }, reward: { lp: 40 } },
      { id: 'inked', category: 'lust', name: 'Inked', description: "Wear 3 marks from Madame Vex's parlour",
        requirement: { marks_owned: 3 }, reward: { lp: 40 } },
      { id: 'masterpiece', category: 'lust', name: 'Walking Masterpiece', description: 'Wear 5 marks at once',
        requirement: { marks_owned: 5 }, reward: { lp: 80 } },
      { id: 'first_boss', category: 'combat', name: 'Boss Slayer', description: 'Defeat or satisfy your first boss',
        requirement: { bosses_defeated: 1 }, reward: { lp: 30 } },
      { id: 'all_bosses', category: 'combat', name: 'Boss Conqueror', description: 'Clear all 7 tower bosses',
        requirement: { unique_bosses_defeated: 7 }, reward: { lp: 200 } },
      { id: 'succubus_hunter', category: 'combat', name: 'Succubus Hunter', description: 'Defeat 5 succubi',
        requirement: { succubus_defeats: 5 }, reward: { lp: 30 } },
      { id: 'incubus_hunter', category: 'combat', name: 'Incubus Hunter', description: 'Defeat 5 incubi',
        requirement: { incubus_defeats: 5 }, reward: { lp: 30 } },

      { id: 'willing_sub', category: 'submission', name: 'Willing Participant', description: 'Submit to monsters 50 times',
        requirement: { submissions: 50 }, reward: { lp: 75 } },
      { id: 'beast_lover', category: 'submission', name: 'Beast Lover', description: 'Submit to 10 beast-type monsters',
        requirement: { beast_submissions: 10 }, reward: { lp: 30 } },
      { id: 'demon_follower', category: 'submission', name: 'Demon Follower', description: 'Submit to 10 demon-type monsters',
        requirement: { demon_submissions: 10 }, reward: { lp: 35 } },
      { id: 'slime_filled', category: 'submission', name: 'Slime Filled', description: 'Submit to 10 slime-type monsters',
        requirement: { slime_submissions: 10 }, reward: { lp: 25 } },
      { id: 'undead_lover', category: 'submission', name: 'Undead Lover', description: 'Submit to 10 undead-type monsters',
        requirement: { undead_submissions: 10 }, reward: { lp: 30 } },
      { id: 'plant_fertilized', category: 'submission', name: 'Plant Fertilized', description: 'Submit to 10 plant-type monsters',
        requirement: { plant_submissions: 10 }, reward: { lp: 25 } },
      { id: 'succubus_charmed', category: 'submission', name: 'Succubus Charmed', description: 'Submit to 5 succubi',
        requirement: { succubus_submissions: 5 }, reward: { lp: 30 } },
      { id: 'incubus_charmed', category: 'submission', name: 'Incubus Charmed', description: 'Submit to 5 incubi',
        requirement: { incubus_submissions: 5 }, reward: { lp: 30 } },
      { id: 'monster_friend', category: 'submission', name: 'Monster Friend',
        description: 'Submit 50+ times, at least 1.5× as often as you defeat monsters',
        requirement: { submissions: 50, submission_to_defeat_ratio: 1.5 }, reward: { lp: 60 } },
      { id: 'boss_satisfier', category: 'submission', name: 'Throne Warmer', description: 'Satisfy 3 bosses through submission',
        requirement: { bosses_satisfied: 3 }, reward: { lp: 75 } },

      { id: 'survivor', category: 'exploration', name: 'True Survivor', description: 'Reach floor 20',
        requirement: { highest_floor: 20 }, reward: { lp: 100 } },
      { id: 'master', category: 'exploration', name: 'Tower Master', description: 'Complete a full cycle',
        requirement: { cycles_completed: 1 }, reward: { lp: 300 } },
      { id: 'trap_expert', category: 'exploration', name: 'Trap Expert', description: 'Trigger 25 traps',
        requirement: { traps_triggered: 25 }, reward: { lp: 35 } },
      { id: 'nimble', category: 'exploration', name: 'Light on Your Feet', description: 'Sidestep 10 traps with your agility',
        requirement: { traps_avoided: 10 }, reward: { lp: 30 } },

      { id: 'curse_collector', category: 'curses', name: 'Curse Collector', description: 'Acquire 5 different curses',
        requirement: { curses_acquired: 5 }, reward: { lp: 25 } },
      { id: 'curse_addict', category: 'curses', name: 'Curse Addict', description: 'Have 10 curses active simultaneously',
        requirement: { max_curses_simultaneous: 10 }, reward: { lp: 80 } },
      { id: 'mimic_tamer', category: 'curses', name: 'Mimic Tamer', description: 'Tear free 3 different living items',
        requirement: { mimics_removed_count: 3 }, reward: { lp: 40 } },

      { id: 'lust_monger', category: 'lust', name: 'Lust Monger', description: 'Earn 1000 LP total',
        requirement: { lp_earned: 1000 }, reward: { lp: 100 } },
      { id: 'survival_expert', category: 'lust', name: 'Survival Expert', description: 'Orgasm 20 times without breaking',
        requirement: { climaxes_survived: 20 }, reward: { lp: 100 } },
      { id: 'first_orgasm', category: 'lust', name: 'First Release', description: 'Experience your first orgasm',
        requirement: { total_climaxes: 1 }, reward: { lp: 10 }, hidden: true },
      { id: 'frequent_climax', category: 'lust', name: 'Frequent Flyer', description: 'Orgasm 10 times',
        requirement: { total_climaxes: 10 }, reward: { lp: 25 }, hidden: true },
      { id: 'orgasm_addict', category: 'lust', name: 'Release Addict', description: 'Become addicted to orgasming (10 orgasms in one run)',
        requirement: { climax_addictions: 1 }, reward: { lp: 50 }, hidden: true },
      { id: 'climax_master', category: 'lust', name: 'Orgasm Master', description: 'Orgasm 50 times',
        requirement: { total_climaxes: 50 }, reward: { lp: 100 }, hidden: true },
      { id: 'overwhelming_pleasure', category: 'lust', name: 'Overwhelming Pleasure',
        description: 'Orgasm with lust 15 or more past the limit',
        requirement: { max_climax_overflow: 15 }, reward: { lp: 30 }, hidden: true },
      { id: 'release_denied', category: 'lust', name: 'Denial Tolerant', description: 'Go 3 floors in a row without orgasming',
        requirement: { best_climax_free_floors: 3 }, reward: { lp: 20 }, hidden: true },

      { id: 'pit_veteran', category: 'events', name: 'Pit Veteran', description: 'Survive the tentacle pit 5 times',
        requirement: { tentacle_pit_survived: 5 }, reward: { lp: 50 } },
      { id: 'glory_hole_regular', category: 'events', name: 'Glory Hole Regular', description: 'Use the glory hole 10 times',
        requirement: { glory_hole_encounters: 10 }, reward: { lp: 40 } },
      { id: 'dildo_collector', category: 'events', name: 'Dildo Collector', description: 'Spring the dildo trap 10 times',
        requirement: { dildo_traps_encountered: 10 }, reward: { lp: 30 } },
      { id: 'escape_artist', category: 'events', name: 'Escape Artist', description: 'Wriggle free of 5 multi-turn events early',
        requirement: { events_escaped: 5 }, reward: { lp: 40 } },

      { id: 'mimic_broodmother_cursed', category: 'challenges', name: 'Mimic Seedbed',
        description: 'Defeat or satisfy the Mimic Broodmother while wearing 5 or more cursed items',
        requirement: { mimic_broodmother_cursed: true }, reward: { lp: 500 } },
      { id: 'no_escape', category: 'challenges', name: 'No Escape', description: 'Reach floor 20 in a single run without trying to flee',
        requirement: { current_floor: 20, run_flee_attempts: { max: 0 } }, reward: { lp: 75 } },
      { id: 'depraved_one', category: 'challenges', name: 'Depraved One',
        description: 'Clear the Tower Lord 7 times with every content theme enabled',
        requirement: { depraved_tower_clears: 7 }, reward: { lp: 1000 } },
      { id: 'royal_court', category: 'challenges', name: 'Royal Court', description: 'Clear both the Succubus Queen and the Incubus King',
        requirement: { royal_demons_cleared: 2 }, reward: { lp: 100 } }
    ].concat(KINK_ACHIEVEMENTS).freeze

    TRACKER_LABELS = {
      floors_cleared: 'floors cleared',
      run_floors_cleared: 'floors cleared this run',
      monsters_killed: 'monsters defeated',
      bosses_defeated: 'bosses cleared',
      bosses_satisfied: 'bosses satisfied',
      unique_bosses_defeated: 'different bosses cleared',
      lp_earned: 'LP earned',
      submissions: 'submissions',
      run_submissions: 'submissions this run',
      curses_acquired: 'different curses acquired',
      treasure_found: 'chests opened',
      highest_floor: 'deepest floor',
      cycles_completed: 'cycles completed',
      current_floor: 'current floor',
      beast_submissions: 'beast submissions',
      demon_submissions: 'demon submissions',
      slime_submissions: 'slime submissions',
      undead_submissions: 'undead submissions',
      plant_submissions: 'plant submissions',
      mimic_submissions: 'mimic submissions',
      succubus_defeats: 'succubi defeated',
      incubus_defeats: 'incubi defeated',
      succubus_submissions: 'succubus submissions',
      incubus_submissions: 'incubus submissions',
      royal_demons_cleared: 'demon royals cleared',
      mimic_broodmother_cursed: 'Broodmother cleared while wearing 5 cursed items',
      depraved_tower_clears: 'Tower Lord clears with every content theme on',
      mimics_removed_count: 'living items torn free',
      tentacle_pit_survived: 'tentacle pits survived',
      glory_hole_encounters: 'glory hole uses',
      traps_triggered: 'traps triggered',
      traps_avoided: 'traps avoided',
      events_escaped: 'events escaped early',
      dildo_traps_encountered: 'dildo traps sprung',
      flee_attempts: 'flee attempts',
      run_flee_attempts: 'flee attempts this run',
      submission_to_defeat_ratio: 'submit-to-kill ratio',
      max_curses_simultaneous: 'curses at once',
      climaxes_survived: 'orgasms survived',
      total_climaxes: 'orgasms',
      denied_climaxes: 'orgasms denied by chastity',
      climax_addictions: 'times addicted to orgasming',
      max_climax_overflow: 'lust past the limit at orgasm',
      best_climax_free_floors: 'floors in a row without orgasming',
      bimbo_transformations: 'bimbo transformations',
      living_clothing_acquired: 'living outfits bound',
      fetish_events_accepted: 'fetish events accepted',
      elites_defeated: 'elites defeated',
      elites_satisfied: 'elites satisfied',
      marks_owned: 'marks worn',
      chests_ignored: 'chests left closed',
      is_developer: 'developer',
      is_bug_tester: 'bug tester',
      pure_title: 'Pure title earned',
      body_growth_events: 'giant growths',
      body_reduction_events: 'shrinkings',
      being_milked_events: 'milkings',
      impregnation_events: 'breedings'
    }.freeze

    TRACKER_TAGS = {
      bimbo_transformations: 'bimbofication', inflation_events: 'inflation', living_clothing_acquired: 'living_clothing',
      petplay_events: 'petplay', latex_events: 'latex', oviposition_events: 'oviposition', chastity_events: 'chastity',
      mind_control_events: 'mind_control', bukkake_events: 'bukkake', exhibitionism_events: 'exhibitionism',
      body_growth_events: 'giant', body_reduction_events: 'shrinking', futanari_events: 'futanari',
      objectification_events: 'objectification', gender_bending_events: 'gender_bending', being_milked_events: 'lactation',
      impregnation_events: 'breeding', lactation_events: 'lactation', watersports_events: 'watersports',
      bondage_events: 'bondage', discipline_events: 'spanking', humiliation_events: 'humiliation',
      mindbreak_events: 'mindbreak', sensory_deprivation_events: 'sensory_deprivation', slavery_events: 'slavery',
      strap_on_events: 'pegging', facial_events: 'facials', foot_fetish_events: 'feet', group_sex_events: 'group_sex',
      public_play_events: 'exhibitionism', voyeurism_events: 'voyeurism', weight_gain_events: 'weight_gain',
      furry_events: 'furry', denied_climaxes: 'chastity',
      overstim_events: 'overstimulation', tickling_events: 'tickling', sissy_events: 'sissification',
      corruption_events: 'corruption', body_writing_events: 'body_writing', musk_events: 'musk',
      temperature_events: 'temperature', size_events: 'size_difference', cum_play_events: 'cum_play',
      degradation_events: 'degradation', monster_form_events: 'monster_transformation', maid_events: 'maid_service',
      pony_events: 'pony_play', gag_events: 'gags_hoods'
    }.freeze

    module_function

    ROLE_KEYS = %i[is_developer is_bug_tester].freeze

    def visible?(player, entry)
      return false if entry[:hidden]

      Hash(entry[:requirement]).keys.all? do |key|
        next player.progress_value(key).positive? if ROLE_KEYS.include?(key.to_sym)

        tag = TRACKER_TAGS[key.to_sym]
        tag.nil? || Engine::ContentOptions.enabled?(player, tag)
      end
    end

    def title(key)
      TITLES[key.to_s]
    end

    def achievement(id)
      ACHIEVEMENTS.find { |a| a[:id] == id.to_s }
    end

    def achievements_in(category, player = nil)
      list = ACHIEVEMENTS.select { |a| a[:category] == category.to_s }
      return list unless player

      done = player.earned_achievements
      list.select { |a| done.include?(a[:id]) || visible?(player, a) }
    end

    def visible_titles(player)
      earned = player.earned_titles
      TITLES.select { |key, t| earned.include?(key) || visible?(player, t) }
    end

    def visible_achievements(player)
      done = player.earned_achievements
      ACHIEVEMENTS.select { |a| done.include?(a[:id]) || visible?(player, a) }
    end

    def label_for(key)
      TRACKER_LABELS.fetch(key.to_sym, key.to_s.tr('_', ' '))
    end

    def requirement_met?(player, key, needed)
      have = player.progress_value(key)
      case needed
      when true then have.positive?
      when Hash then have <= needed[:max]
      else have >= needed
      end
    end

    def met?(player, requirement)
      requirement.all? { |key, needed| requirement_met?(player, key, needed) }
    end

    def progress_text(player, requirement)
      requirement.map do |key, needed|
        have = player.progress_value(key)
        case needed
        when true then "#{label_for(key)}: #{have.positive? ? 'done' : 'not yet'}"
        when Hash then "#{have} #{label_for(key)} (must stay ≤ #{needed[:max]})"
        when Float then "#{[have, needed].min.round(2)}/#{needed} #{label_for(key)}"
        else "#{[have, needed].min}/#{needed} #{label_for(key)}"
        end
      end.join(', ')
    end

    def best_title_key(earned)
      earned = Array(earned).map(&:to_s)
      TITLE_PRIORITY.find { |k| earned.include?(k) } || earned.find { |k| TITLES.key?(k) }
    end
  end
end
