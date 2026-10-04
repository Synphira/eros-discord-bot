# frozen_string_literal: true

module Engine
  module Shop
    def self.sell_item(player, equipment_id)
      equipment = ::Equipment[equipment_id]
      unless equipment && player.owns_equipment?(equipment.name)
        return { ok: false, error: :not_found, message: 'Item not found in your pack.' }
      end
      if equipment.cursed
        return { ok: false, error: :cursed, message: "Living gear can't be sold — tear it free instead (costs LP)." }
      end

      sell_price = [(equipment.cost * 0.5).round, 1].max
      player.refund_lp!(sell_price)
      player.drop_equipment!(equipment.name)
      { ok: true, message: "You sold **#{equipment.name}** for **#{sell_price}** LP!" }
    end
  end
end

module Eros
  module_function

  # Every item and curse a save can reference, registered by name.
  def load_catalogue!
    Engine::Shop.sync_to_db!
    Engine::Treasure.sync_to_db!
    Engine::BossFights.sync_trophies!
    Engine::CurseCatalog.sync_to_db!
    Engine::NPCSystem::NPC_GEAR.each do |name, tpl|
      ::Equipment.find_or_create(name: name) { |e| Engine::Treasure.apply_template!(e, tpl) }
    end
  end

  def encounter_for(player)
    player.reconcile_encounter!
  end

  def set_encounter!(player, snapshot)
    snap = snapshot.is_a?(Hash) ? snapshot.transform_keys(&:to_sym) : Engine::CombatEngine.encounter_snapshot(snapshot)
    player.store_encounter!(snap)
    snap
  end

  def clear_encounter!(player)
    player.clear_encounter!
  end
end

Eros.load_catalogue!
