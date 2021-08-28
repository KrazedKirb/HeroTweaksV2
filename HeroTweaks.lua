local mod = get_mod("HeroTweaks")
-------------------------------------------------------
--					//////[GENERAL]\\\\\\
-------------------------------------------------------
--[NETWORK LOOKUP]
--[PING SYSTEM]:
--[HEAL SHARE]:
local PlayerUnitStatusSettings = PlayerUnitStatusSettings
PlayerUnitStatusSettings.CONQUEROR_DEGEN_DELAY = math.huge
PlayerUnitStatusSettings.CONQUEROR_DEGEN_AMOUNT = 0
PlayerUnitStatusSettings.CONQUEROR_DEGEN_START = math.huge
function PlayerUnitHealthExtension:health_degen_settings()
    local buff_extension = self.buff_extension
    local degen_amount = PlayerUnitStatusSettings.NOT_WOUNDED_DEGEN_AMOUNT
    local degen_delay = PlayerUnitStatusSettings.NOT_WOUNDED_DEGEN_DELAY
    local degen_start = PlayerUnitStatusSettings.NOT_WOUNDED_DEGEN_START

    if buff_extension then
        if buff_extension:has_buff_perk("conqueror_healing") then
            degen_amount = PlayerUnitStatusSettings.CONQUEROR_DEGEN_AMOUNT
            degen_delay = PlayerUnitStatusSettings.CONQUEROR_DEGEN_DELAY
            degen_start = PlayerUnitStatusSettings.CONQUEROR_DEGEN_START
        elseif buff_extension:has_buff_perk("smiter_healing") then
            degen_amount = PlayerUnitStatusSettings.SMITER_DEGEN_AMOUNT
            degen_delay = PlayerUnitStatusSettings.SMITER_DEGEN_DELAY
            degen_start = PlayerUnitStatusSettings.SMITER_DEGEN_START
        elseif buff_extension:has_buff_perk("linesman_healing") then
            degen_amount = PlayerUnitStatusSettings.LINESMAN_DEGEN_AMOUNT
            degen_delay = PlayerUnitStatusSettings.LINESMAN_DEGEN_DELAY
            degen_start = PlayerUnitStatusSettings.LINESMAN_DEGEN_START
        elseif buff_extension:has_buff_perk("tank_healing") then
            degen_amount = PlayerUnitStatusSettings.TANK_DEGEN_AMOUNT
            degen_delay = PlayerUnitStatusSettings.TANK_DEGEN_DELAY
            degen_start = PlayerUnitStatusSettings.TANK_DEGEN_START
        elseif buff_extension:has_buff_perk("ninja_healing") then
            degen_amount = PlayerUnitStatusSettings.NINJA_DEGEN_AMOUNT
            degen_delay = PlayerUnitStatusSettings.NINJA_DEGEN_DELAY
            degen_start = PlayerUnitStatusSettings.NINJA_DEGEN_START
        end
    end

    if Managers.weave:get_active_wind() == "death" then
        degen_amount = degen_amount * 2
        degen_delay = degen_delay
        degen_start = 0
    end

    return degen_amount, degen_delay, degen_start
end

for buff_name, buff_settings in pairs(BuffTemplates) do
    if string.find(buff_name, "_conqueror$") then
        buff_settings.buffs[1].perk = "conqueror_healing"
    end
end
--[HEADSHOT/CRIT TEMP HP]:
ProcFunctions.heal_finesse_damage_on_melee = function (player, buff, params)
	if not Managers.state.network.is_server then
			return
	end

	local player_unit = player.player_unit
	local heal_amount_light = 2.5 
	local heal_amount_light_dual = 1.25
	local heal_amount_heavy = 5
	local heal_amount_heavy_dual =  2.5
	local heal_amount_crit_light = 1.5
	local heal_amount_crit_light_dual = 0.75
	local heal_amount_crit_heavy = 3
	local heal_amount_crit_heavy_dual = 1.5
	local max_targets = 3 

	local hit_unit = params[1]
	local hit_zone_name = params[3]
	local target_number = params[4]
	local attack_type = params[2]
	local critical_hit = params[6]
	local breed = AiUtils.unit_breed(hit_unit)

	local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
	local wielded_slot_data = inventory_extension:get_wielded_slot_data("slot_melee")
	local wielded_slot_template = inventory_extension:get_item_template(wielded_slot_data)
	local is_action_dual_wield_attack = wielded_slot_template.dual_wield_attack

	if target_number <= max_targets then
		if target_number == 1 then
			if ALIVE[player_unit] and breed and (attack_type == "light_attack") then
				--mod:echo("checked for dual wield attack right")
				if (hit_zone_name == "head" or hit_zone_name == "neck" or hit_zone_name == "weakspot") then

					DamageUtils.heal_network(player_unit, player_unit, heal_amount_light, "heal_from_proc")
				end

				if critical_hit then

					DamageUtils.heal_network(player_unit, player_unit, heal_amount_crit_light, "heal_from_proc")
				end
			end

			if ALIVE[player_unit] and breed and (attack_type == "heavy_attack") then
				--mod:echo("checked for dual wield attack right")
				if not is_action_dual_wield_attack and (hit_zone_name == "head" or hit_zone_name == "neck" or hit_zone_name == "weakspot") then

					DamageUtils.heal_network(player_unit, player_unit, heal_amount_heavy, "heal_from_proc")
				elseif is_action_dual_wield_attack and (hit_zone_name == "head" or hit_zone_name == "neck" or hit_zone_name == "weakspot") then

					DamageUtils.heal_network(player_unit, player_unit, heal_amount_heavy_dual, "heal_from_proc")
					--mod:echo("DUAL WIELD HEAVY RIGHT")
				end

				if not is_action_dual_wield_attack and critical_hit then
					
					DamageUtils.heal_network(player_unit, player_unit, heal_amount_crit_heavy, "heal_from_proc")
				elseif is_action_dual_wield_attack and critical_hit then
					DamageUtils.heal_network(player_unit, player_unit, heal_amount_crit_heavy_dual, "heal_from_proc")

					--mod:echo("DUAL WIELD HEAVY CRIT RIGHT")
				end
			end
		end

		if target_number == 2 then
			local heal_cleave_headshot = 2
			local heal_cleave_crit = 1

			if (hit_zone_name == "head" or hit_zone_name == "neck" or hit_zone_name == "weakspot") then

				DamageUtils.heal_network(player_unit, player_unit, heal_cleave_headshot, "heal_from_proc")
				--mod:echo("target_number == 2 headshot")
			end

			if critical_hit then

				DamageUtils.heal_network(player_unit, player_unit, heal_cleave_crit, "heal_from_proc")
				--mod:echo("target_number == 2 crit")
			end
		end
		if target_number == 3 then
			local heal_cleave_headshot = 1
			local heal_cleave_crit = 0.5

			if (hit_zone_name == "head" or hit_zone_name == "neck" or hit_zone_name == "weakspot") then

				DamageUtils.heal_network(player_unit, player_unit, heal_cleave_headshot, "heal_from_proc")
				--mod:echo("target_number == 3 headshot")
			end

			if critical_hit then

				DamageUtils.heal_network(player_unit, player_unit, heal_cleave_crit, "heal_from_proc")
				--mod:echo("target_number == 3 crit")
			end
		end
	end
end
--apply dual_wield_attack to appropriate attacks
--axe n falchion
Weapons.dual_wield_axe_falchion_template.dual_wield_attack = true
--dual axe
Weapons.dual_wield_axes_template_1.dual_wield_attack = true
--dual daggers
Weapons.dual_wield_daggers_template_1.dual_wield_attack = true
--mace and sword
Weapons.dual_wield_hammer_sword_template.dual_wield_attack = true
--dual hammers
Weapons.dual_wield_hammers_template.dual_wield_attack = true
--sword and dagger
Weapons.dual_wield_sword_dagger_template_1.dual_wield_attack = true
--dual swords
Weapons.dual_wield_swords_template_1.dual_wield_attack = true
--[TRIGGER PROCS]:
ProcEvents = {
	"on_hit",
	"on_kill",
	"on_kill_elite_special",
	"on_boss_killed",
	"on_special_killed",
	"on_elite_killed",
	"on_ping_target_killed",
	"on_block",
	"on_block_broken",
	"on_timed_block",
	"on_knocked_down",
	"on_ledge_hang_start",
	"on_player_disabled",
	"on_ally_knocked_down",
	"on_revived",
	"on_revived_ally",
	"on_healed",
	"on_healed_ally",
	"on_healed_consumeable",
	"on_assisted",
	"on_assisted_ally",
	"on_push",
	"on_damage_taken",
	"on_consumable_picked_up",
	"on_reload",
	"on_ammo_used",
	"on_unwield",
	"on_critical_hit",
	"on_last_ammo_used",
	"on_gained_ammo_from_no_ammo",
	"on_player_damage_dealt",
	"on_stagger",
	"on_charge_ability_hit",
	"on_charge_ability_hit_blast",
	"on_bardin_consumable_picked_up_any_player",
	"on_dodge",
	"on_dodge_finished",
	"on_leap_start",
	"on_leap_finished",
	"on_enemy_pinged",
	"on_start_action",
	"on_full_charge_action",
	"on_enemy_ignited",
	"on_auto_headshot",
	"on_potion_consumed",
	"on_ability_activated",
	"on_dot_damage_dealt",
	"on_inventory_post_apply_buffs",
	"on_death",
	"on_damage_dealt",
	"on_push_used",
	"on_backstab",
	"on_sweep",
	"on_ranged_hit",
	"on_critical_sweep",
	"on_critical_shot",
	"on_critical_action",
	"on_spell_used",
	"on_grenade_use",
	"on_full_charge",
	"on_charge_finished",
	"on_ability_recharged",
	"on_ability_cooldown_started",
	"on_extra_ability_consumed",
	"on_gromril_armour_removed",
	"on_shield_break"
}
--trigger break shield proc
AIShieldUserExtension.break_shield = function (self, attacker_unit)
	--assert(attacker_unit)
	self:set_is_blocking(false)

	self.shield_broken = true
	local unit = self._unit
	local blackboard = self._blackboard
	blackboard.shield_breaking_hit = true
	blackboard.shield_user = false
	local ai_inventory_extension = ScriptUnit.extension(unit, "ai_inventory_system")
	local inventory_item_definitions = ai_inventory_extension.inventory_item_definitions
	local reason = "shield_break"
	local network_transmit = Managers.state.network.network_transmit
	local game_object_id = Managers.state.unit_storage:go_id(unit)
	local reason_id = NetworkLookup.item_drop_reasons[reason]

	for i = 1, #inventory_item_definitions, 1 do
		local item = inventory_item_definitions[i]
		local success, item_unit = ai_inventory_extension:drop_single_item(i, reason)
		local attacker_unit_buff_extension = ScriptUnit.has_extension(attacker_unit, "buff_system")

		if success then
			network_transmit:send_rpc_clients("rpc_ai_drop_single_item", game_object_id, i, reason_id)
			if attacker_unit_buff_extension then
				attacker_unit_buff_extension:trigger_procs("on_shield_break")
				mod:echo("broke shield proc")
			end
		end
	end
end
-------------------------------------------------------
--					//////[KRUBER]\\\\\\
-------------------------------------------------------
--[HUNTSMAN]:
--PASSIVE
BuffTemplates.markus_huntsman_passive_crit_aura.buffs[1].range = 10

ActionUtils.get_dropoff_scalar = function (damage_profile, target_settings, attacker_unit, target_unit)
	local range_dropoff_settings = target_settings.range_dropoff_settings or damage_profile.range_dropoff_settings

	if not range_dropoff_settings then
		return 0
	end
	local buff_extension = ScriptUnit.has_extension(attacker_unit, "buff_system")
	local attacker_position = POSITION_LOOKUP[attacker_unit] or Unit.world_position(attacker_unit, 0)
	local target_position = POSITION_LOOKUP[target_unit] or Unit.world_position(target_unit, 0)
	local distance = Vector3.distance(target_position, attacker_position)
	local dropoff_start = range_dropoff_settings.dropoff_start
	local dropoff_end = range_dropoff_settings.dropoff_end
	

	if buff_extension:has_buff_perk("no_damage_dropoff") then
		dropoff_start = dropoff_start * 2
		dropoff_end = dropoff_end * 2
	end

	if distance < 10 and buff_extension:has_buff_type("markus_huntsman_movement_speed") then
		DamageProfileTemplates.arrow_carbine.armor_modifier_near.attack = {
			1,
			0.4,
			1,
			1,
			1,
			0.25
		}
		DamageProfileTemplates.longbow_empire.armor_modifier_near.attack = {
			1,
			0.95,
			1,
			1,
			1,
			0.25
		}
		DamageProfileTemplates.arrow_sniper_kruber.armor_modifier_near.attack = {
			1,
			1.15,
			1.5,
			1,
			0.75,
			0.5
		}
		DamageProfileTemplates.shot_sniper.armor_modifier_near.attack = {
			1,
			1.45,
			1.5,
			1,
			0.75,
			0.75
		}
		DamageProfileTemplates.shot_repeating.armor_modifier_near.attack = {
			1.25,
			0.95,
			1,
			1,
			0.5,
			0.4
			--0.25
		}
		DamageProfileTemplates.shot_shotgun.armor_modifier_near.attack = {
			1,
			0.35,
			0.4,
			0.75,
			1,
			0.15
			--0.25
		}
	else
		DamageProfileTemplates.arrow_carbine.armor_modifier_near.attack = {
			1,
			0.25,
			1,
			1,
			1,
			0
		}
		DamageProfileTemplates.longbow_empire.armor_modifier_near.attack = {
			1,
			0.8,
			1,
			1,
			1,
			0
		}
		DamageProfileTemplates.arrow_sniper_kruber.armor_modifier_near.attack = {
			1,
			1,
			1.5,
			1,
			0.75,
			0.25
		}
		DamageProfileTemplates.shot_sniper.armor_modifier_near.attack = {
			1,
			1.2,
			1.5,
			1,
			0.75,
			0.5
		}
		DamageProfileTemplates.shot_repeating.armor_modifier_near.attack = {
			1.25,
			0.8,
			1,
			1,
			0.5,
			0
		}
		DamageProfileTemplates.shot_shotgun.armor_modifier_near.attack = {
			1,
			0.2,
			0.4,
			0.75,
			1,
			0
		}
	end

	local dropoff_scale = dropoff_end - dropoff_start
	local dropoff_distance = math.clamp(distance - dropoff_start, 0, dropoff_scale)
	local dropoff_scalar = dropoff_distance / dropoff_scale

	return dropoff_scalar
end
--[TALENT ORDER]:
TalentTrees.empire_soldier[1] = {
		{
			"markus_huntsman_vanguard",
			"markus_huntsman_bloodlust_2",
			"markus_huntsman_heal_share"
		},
		{
			"markus_huntsman_third_shot_free",
			"markus_huntsman_debuff_defence_on_crit",
			"markus_huntsman_headshot_damage"
		},
		{
			"markus_huntsman_tank_unbalance",
			"markus_huntsman_smiter_unbalance",
			"markus_huntsman_power_level_unbalance"
		},
		{
			"markus_huntsman_headshots_increase_reload_speed",
			"markus_huntsman_passive_crit_buff_on_headshot",
			"markus_huntsman_movement_speed"
		},
		{
			"markus_huntsman_ammo_on_special_kill",
			"markus_huntsman_movement_speed_2",
			"markus_huntsman_passive_temp_health_on_headshot"
		},
		{
			"markus_huntsman_activated_ability_cooldown",
			"markus_huntsman_activated_ability_improved_stealth",
			"markus_huntsman_activated_ability_duration"
		}
}
--[PASSIVES]:
--[INCREASED AMMUNITION]:
BuffTemplates.markus_huntsman_passive_increased_ammunition.buffs[1].perk = "increased_zoom"
BuffTemplates.markus_huntsman_activated_ability_increased_zoom.buffs[1].perk = nil
BuffTemplates.markus_huntsman_activated_ability_increased_zoom_duration.buffs[1].perk = nil
--[MASTER OF THE SKIRMISH]:
Talents.empire_soldier[10].buffs = {
			"markus_huntsman_movement_speed",
			"markus_huntsman_headshots_increase_movement_speed"
		}
ProcFunctions.markus_huntsman_increase_movement_speed = function (player, buff, params)
		local player_unit = player.player_unit
		local attack_type = params[2]
		local hit_zone_name = params[3]
		local buff_extension = ScriptUnit.extension(player_unit, "buff_system")

		if Unit.alive(player_unit) and hit_zone_name == "head" and (attack_type == "instant_projectile" or attack_type == "projectile") then
			buff_extension:add_buff("markus_huntsman_headshots_increase_movement_speed_buff")
		end
	end
BuffTemplates.markus_huntsman_headshots_increase_movement_speed = {
		buffs = {
			{
				max_stacks = 1,
				name = "markus_huntsman_headshots_increase_movement_speed",
				event_buff = true,
				buff_func = "markus_huntsman_increase_movement_speed",
				event = "on_hit"
			}
		}
	}
BuffTemplates.markus_huntsman_headshots_increase_movement_speed_buff = {
	buffs = {
		{
			name = "markus_huntsman_headshots_increase_movement_speed_buff",
			duration = 3,
			max_stacks = 1,
			icon = "markus_huntsman_max_stamina",
			--stat_buff = "reload_speed",
			refresh_durations = true,
			multiplier = 1.15,
			remove_buff_func = "remove_movement_buff",
			apply_buff_func = "apply_movement_buff",
			path_to_movement_setting_to_modify = {
				"move_speed"
			}
		}
	}
}
--[BURST OF ENTHUSIASM]:
ProcFunctions.markus_huntsman_passive_proc = function (player, buff, params)
		local player_unit = player.player_unit
		local attack_type = params[2]
		local hit_zone_name = params[3]

		if Unit.alive(player_unit) and hit_zone_name == "head" and (attack_type == "instant_projectile" or attack_type == "projectile") then
			local weapon_slot = "slot_ranged"
			local ammo_amount = buff.bonus
			local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
			local talent_extension = ScriptUnit.extension(player_unit, "talent_system")
			if talent_extension:has_talent("markus_huntsman_passive_temp_health_on_headshot", "empire_soldier", true) then
				ammo_amount = 2
			else
				ammo_amount = buff.bonus
			end

			if talent_extension:has_talent("markus_huntsman_passive_crit_buff_on_headshot", "empire_soldier", true) then
				buff_extension:add_buff("markus_huntsman_passive_crit_buff")
				buff_extension:add_buff("markus_huntsman_passive_crit_buff_removal")
			end

			local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
			local slot_data = inventory_extension:get_slot_data(weapon_slot)
			local right_unit_1p = slot_data.right_unit_1p
			local left_unit_1p = slot_data.left_unit_1p
			local ammo_extension = GearUtils.get_ammo_extension(right_unit_1p, left_unit_1p)

			if ammo_extension then
				ammo_extension:add_ammo_to_reserve(ammo_amount)
			end
		end
	end
--[THICK HIDE]:
Talents.empire_soldier[11].buffs = {
	"markus_huntsman_stacking_damage_reduction_on_kills",
	"markus_huntsman_defence_remove",
	"markus_huntsman_stacking_attack_speed_on_kills",
	"markus_huntsman_attack_speed_remove"
}
BuffTemplates.markus_huntsman_attack_speed_buff = {
	buffs = {
		{
			name = "markus_huntsman_attack_speed_buff",
			max_stacks = 4,
			multiplier = 0.025,
			stat_buff = "attack_speed"
		}
	}
}
BuffTemplates.markus_huntsman_stacking_attack_speed_on_kills = {
		buffs = {
			{
				name = "markus_huntsman_stacking_attack_speed_on_kills",
				buff_to_add = "markus_huntsman_attack_speed_buff",
				max_stacks = 1,
				event_buff = true,
				buff_func = "add_buff_stack_on_special_kill",
				event = "on_kill",
				max_sub_buff_stacks = 4
			}
		}
	}
BuffTemplates.markus_huntsman_attack_speed_remove = {
		buffs = {
			{
				name = "markus_huntsman_attack_speed_remove",
				event = "on_damage_taken",
				buff_func = "remove_ref_buff_stack",
				event_buff = true,
				reference_buff = "markus_huntsman_stacking_attack_speed_on_kills"
			}
		}
	}
BuffTemplates.markus_huntsman_defence_buff.buffs[1].max_stacks = 4
BuffTemplates.markus_huntsman_stacking_damage_reduction_on_kills.buffs[1].max_sub_buff_stacks = 4
--[GRAIL KNIGHT]:
--Weapons.markus_questingknight_career_skill_weapon.buff_type = "MELEE_ABILITY"
--[VIRTUE OF THE CONFIDENCE]
Weapons.markus_questingknight_career_skill_weapon.actions.action_career_release.default_tank.hit_mass_count = HEAVY_LINESMAN_HIT_MASS_COUNT
--[VIRTUE OF THE IMPETUOUS KNIGHT]
--[[ActionCareerESQuestingKnight.init = function (self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	ActionCareerESQuestingKnight.super.init(self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)

	self.career_extension = ScriptUnit.extension(owner_unit, "career_system")
	self.inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
	self.talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	self.status_extension = ScriptUnit.extension(owner_unit, "status_system")
	self._player = player
	self._is_server = player.is_server
	self._owner_unit = unit
end
ActionCareerESQuestingKnight.finish = function (self, reason, data)
	ActionCareerESQuestingKnight.super.finish(self, reason, data)
	self.inventory_extension:stop_weapon_fx("career_action", true)
	local is_server = self._is_server
	local owner_unit = self._owner_unit
	local talent_extension = self.talent_extension
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit
	local unit_object_id = network_manager:unit_game_object_id(owner_unit)
	local buffs = {
		"markus_questing_knight_ability_buff_on_kill_movement_speed",
		"markus_questing_knight_ability_buff_on_kill_attack_speed"
	}

	local new_action_settings = data and data.new_action_settings
	local is_ability_cancel = new_action_settings and new_action_settings.is_ability_cancel

	if is_ability_cancel or not self._combo_no_wield or reason ~= "new_interupting_action" then
		self.status_extension:set_stagger_immune(false)

		local career_extension = self.career_extension

		if not self._cooldown_started then
			self._cooldown_started = true

			career_extension:start_activated_ability_cooldown()
			if talent_extension:has_talent("markus_questing_knight_ability_buff_on_kill") then
				if is_server then
					local buff_extension = self._buff_extension

					for i = 1, #buffs, 1 do
						local buff_name = buffs[i]
						local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

						buff_extension:add_buff(buff_name, {
							attacker_unit = owner_unit
						})
						network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
					end
				else
					for i = 1, #buffs, 1 do
						local buff_name = buffs[i]
						local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

						network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
					end
				end
			end
		end

		self.inventory_extension:wield_previous_non_level_slot()
	end
end]]
Talents.empire_soldier[73].buffer = "both"

BuffTemplates.markus_questing_knight_ability_buff_on_kill_movement_speed.buffs[1].perk = "no_ranged_knockback"
BuffTemplates.markus_questing_knight_ability_buff_on_kill_attack_speed = {
	buffs = {
		{
			stat_buff = "attack_speed",
			max_stacks = 1,
			name = "markus_questing_knight_ability_buff_on_kill_attack_speed",
			multiplier = 0.15,
			duration = 10
		}
	}
}
BuffTemplates.markus_questing_knight_ability_buff_on_kill_movement_speed.buffs[1].duration = 10
BuffTemplates.markus_questing_knight_ability_buff_on_kill.buffs[1].buff_to_add_1 = "markus_questing_knight_ability_buff_on_kill_attack_speed"
BuffTemplates.markus_questing_knight_ability_buff_on_kill.buffs[1].event = "on_damage_dealt" --"on_kill" --"on_hit"
--BuffTemplates.markus_questing_knight_ability_buff_on_kill.buffs[1].event_buff = nil
--BuffTemplates.markus_questing_knight_ability_buff_on_kill.buffs[1].buff_func = nil
--BuffTemplates.markus_questing_knight_ability_buff_on_kill.buffs[1].buff_to_add = nil

ProcFunctions.markus_questing_knight_ability_kill_buff_func = function (player, buff, params)
		local player_unit = player.player_unit

		if Unit.alive(player_unit) then
			local buffs = {
				"markus_questing_knight_ability_buff_on_kill_movement_speed",
				"markus_questing_knight_ability_buff_on_kill_attack_speed"
			}
			--local killing_blow_table = params[1]
			--local killing_blow_damage_source = killing_blow_table[DamageDataIndex.DAMAGE_SOURCE_NAME]
			local attacker_unit = params[1]
			local damage_source = params[9]
			--[[local target_number = params[4]
			local buff_type = params[5]
			if target_number and target_number <= 1 then
				buff.can_trigger = true
			end]]
			
			--if buff.can_trigger and buff_type == "MELEE_2H"  then
			if attacker_unit and damage_source == "markus_questingknight_career_skill_weapon" then
			--if killing_blow_table and killing_blow_damage_source == "markus_questingknight_career_skill_weapon" then
				local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
				local network_manager = Managers.state.network
				local network_transmit = network_manager.network_transmit
				local unit_object_id = network_manager:unit_game_object_id(player_unit)
				local function is_server()
					return Managers.player.is_server
				end
				if is_server() then
				--local buff_template = buff.template
				--local buff_to_add = buff_template.buff_to_add
				--local buff_to_add_1 = buff_template.buff_to_add_1

					for i = 1, #buffs, 1 do
							local buff_name = buffs[i]
							local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

							buff_extension:add_buff(buff_name, {
								attacker_unit = owner_unit
							})
							network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
					end
				else
					for i = 1, #buffs, 1 do
						local buff_name = buffs[i]
						local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

						network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
					end
				end
			end

				--[[if buff_extension then
					buff_extension:add_buff(buff_to_add)
					buff_extension:add_buff(buff_to_add_1)
				end]]
		end
	end
-------------------------------------------------------
--					//////[SALTZPYRE]\\\\\\
-------------------------------------------------------
--[WITCH HUNTER CAPTAIN:]
--[TEMPLAR'S KNOWLEDGE]:
BuffTemplates.victor_witchhunter_improved_damage_taken_ping.buffs[1].max_stacks = 4
--BuffTemplates.victor_witchhunter_improved_damage_taken_ping.buffs[1].duration = 15
--BuffTemplates.victor_witchhunter_improved_damage_taken_ping.buffs[1].refresh_durations = true
--[BOUNTY HUNTER]:
--[temp hp on cleave]
--[[BuffTemplates.victor_bountyhunter_reaper = {
	buffs = {
		{
			multiplier = -0.05,
			name = "reaper",
			event_buff = true,
			buff_func = "heal_damage_targets_on_melee",
			event = "on_player_damage_dealt",
			perk = "linesman_healing",
			max_targets = 5,
			bonus = 0.25
		}
	}
}
Talents.witch_hunter[20].description = "reaper_desc"
Talents.witch_hunter[20].description_values[1] = {
	value = BuffTemplates.reaper.buffs[1].max_targets
}
Talents.witch_hunter[20].buffs = {
	"victor_bountyhunter_reaper"
}]]
--[steel crescendo]
Talents.witch_hunter[22].buffs = {
	"victor_bountyhunter_steel_crescendo"
}
ProcFunctions.victor_bountyhunter_steel_crescendo_buff_add = function (player, buff, params)
	local player_unit = player.player_unit
	if Unit.alive(player_unit) then
			local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
			local buff_type = params[5]
			local is_critical = params[6]
			local network_manager = Managers.state.network
			local network_transmit = network_manager.network_transmit
			local unit_object_id = network_manager:unit_game_object_id(player_unit)
			local function is_server()
				return Managers.player.is_server
			end
			local buffs_to_add = {
				"victor_bountyhunter_steel_crescendo_buff_power",
				"victor_bountyhunter_steel_crescendo_buff_attack_speed"
				--"victor_bountyhunter_steel_crescendo_buff_healing"
			}
			
			if is_critical and not MeleeBuffTypes[buff_type] then
				for i = 1, #buffs_to_add, 1 do
					local buff_name = buffs_to_add[i]
					local unit_object_id = network_manager:unit_game_object_id(player_unit)
					local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

					if is_server() then
						buff_extension:add_buff(buff_name, {
							attacker_unit = player_unit
						})
						network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
					else
						network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
					end
				end
			end
	end
end	
BuffTemplates.victor_bountyhunter_steel_crescendo = {
	buffs = {
		{
			event = "on_hit",
			event_buff = true,
			max_stacks = 1,
			name = "victor_bountyhunter_steel_crescendo",
			buff_func = "victor_bountyhunter_steel_crescendo_buff_add"
		}
	}
}
BuffTemplates.victor_bountyhunter_steel_crescendo_buff_power = {
	buffs = {
		{
			name = "victor_bountyhunter_steel_crescendo_buff_power",
			stat_buff = "first_melee_hit_damage",
			multiplier = 0.1,
			icon = "victor_bountyhunter_melee_damage_on_no_ammo",
			duration = 10,
			refresh_durations = true,
			max_stacks = 1
		}
	}
}
BuffTemplates.victor_bountyhunter_steel_crescendo_buff_attack_speed = {
	buffs = {
		{
			name = "victor_bountyhunter_steel_crescendo_buff_attack_speed",
			stat_buff = "attack_speed",
			multiplier = 0.1,
			--icon = "victor_bountyhunter_melee_damage_on_no_ammo",
			duration = 10,
			refresh_durations = true,
			max_stacks = 1
		}
	}
}
--[weight of fire]
BuffTemplates.victor_bountyhunter_power_level_on_clip_size_buff.buffs[1].multiplier = 0.0125
--[blessed combat]
ProcFunctions.victor_bountyhunter_blessed_combat = function (player, buff, params)
		local function is_server()
			return Managers.player.is_server
		end
		if not is_server() then
			return
		end

		local player_unit = player.player_unit

		if not Unit.alive(player_unit) then
			return
		end

		local attack_type = params[2]

		if not attack_type then
			return
		end

		local buff_template = buff.template
		local buff_name = ""
		local is_melee = false
		local is_ranged = false

		if attack_type == "projectile" or attack_type == "instant_projectile" then
			local t = Managers.time:time("game")

			if not buff.t then
				buff.t = 0
			end

			if buff.t == t then
				return false
			end

			buff.t = t
			is_ranged = true
			buff_name = buff_template.melee_buff
		elseif attack_type == "light_attack" or attack_type == "heavy_attack" then
			local target_number = params[4]

			if target_number > 1 then
				return false
			end

			is_melee = true
			buff_name = buff_template.ranged_buff
		end

		local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
		local buff_system = Managers.state.entity:system("buff_system")

		if is_ranged then
			if #buff_template.melee_buff_ids < 10 then
				table.insert(buff_template.melee_buff_ids, buff_system:add_buff(player_unit, buff_name, player_unit, true))
			end

			if buff_extension:has_buff_type(buff_template.ranged_buff) then
				buff_system:remove_server_controlled_buff(player_unit, buff_template.ranged_buff_ids[#buff_template.ranged_buff_ids])
				table.remove(buff_template.ranged_buff_ids, #buff_template.ranged_buff_ids)
			else
				table.clear(buff_template.ranged_buff_ids)
			end
		end

		if is_melee then
			if #buff_template.ranged_buff_ids < 10 then
				table.insert(buff_template.ranged_buff_ids, buff_system:add_buff(player_unit, buff_name, player_unit, true))
			end

			if buff_extension:has_buff_type(buff_template.melee_buff) then
				buff_system:remove_server_controlled_buff(player_unit, buff_template.melee_buff_ids[#buff_template.melee_buff_ids])
				table.remove(buff_template.melee_buff_ids, #buff_template.melee_buff_ids)
			else
				table.clear(buff_template.melee_buff_ids)
			end
		end
	end
BuffTemplates.victor_bountyhunter_blessed_melee_buff.buffs[1].max_stacks = 10
BuffTemplates.victor_bountyhunter_blessed_ranged_buff.buffs[1].max_stacks = 10
BuffTemplates.victor_bountyhunter_blessed_ranged_damage_buff.buffs[1].presentation_stacks = 10
BuffTemplates.victor_bountyhunter_blessed_melee_damage_buff.buffs[1].presentation_stacks = 10
--[cruel fortune]
Talents.witch_hunter[26].buffs = {
	"victor_bountyhunter_guaranteed_melee_crit_handler"
}
BuffFunctionTemplates.functions.victor_bountyhunter_apply_guaranteed_melee_crit = function (unit, buff, params)
	local talent_extension = ScriptUnit.has_extension(unit, "talent_system")

		if ALIVE[unit] and talent_extension:has_talent("victor_bountyhunter_passive_reduced_cooldown") then
			local template = buff.template
			local buff_to_apply = template.buff_to_apply
			local buff_extension = ScriptUnit.extension(unit, "buff_system")

			buff_extension:add_buff(buff_to_apply)
		end
	end
ProcFunctions.victor_bountyhunter_remove_guaranteed_melee_crit = function (player, buff, params)
	local player_unit = player.player_unit
	local buff_type = params[5]

	if Unit.alive(player_unit) then
		local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
		local has_buff_to_remove = buff_extension:get_non_stacking_buff("victor_bountyhunter_guaranteed_melee_crit")

		if has_buff_to_remove and MeleeBuffTypes[buff_type] then
			buff_extension:remove_buff(has_buff_to_remove.id)
		end
	end
end
BuffTemplates.victor_bountyhunter_passive_crit_buff.buffs[1].apply_buff_func = "victor_bountyhunter_apply_guaranteed_melee_crit"
BuffTemplates.victor_bountyhunter_passive_crit_buff.buffs[1].buff_to_apply = "victor_bountyhunter_guaranteed_melee_crit"
BuffTemplates.victor_bountyhunter_guaranteed_melee_crit = {
	buffs = {
		{
			stat_buff = "critical_strike_chance_melee",
			bonus = 1,
			icon = "victor_bountyhunter_passive_reduced_cooldown",
			max_stacks = 1,
			name = "victor_bountyhunter_guaranteed_melee_crit"
		}
	}
}
BuffTemplates.victor_bountyhunter_guaranteed_melee_crit_handler = {
	buffs = {
		{
			event_buff = true,
			event = "on_hit",
			buff_func = "victor_bountyhunter_remove_guaranteed_melee_crit",
			max_stacks = 1,
			name = "victor_bountyhunter_guaranteed_melee_crit_handler"
		}
	}
}
--[prized bounty]
--PRIZED BOUNTY NEW
Talents.witch_hunter[27].buffs = {
	"victor_bountyhunter_passive_infinite_ammo",
	"victor_bountyhunter_refresh_blessed_shot_on_headshot_crit"
}
ProcFunctions.victor_bountyhunter_refresh_blessed_shot_on_headshot_crit = function (player, buff, params)
	local player_unit = player.player_unit

		if ALIVE[player_unit] then
			local hit_zone = params[3]
			local target_number = params[4]
			local buff_type = params[5]
			local is_critical = params[6]

			if target_number and target_number <= 1 then
				buff.can_trigger = true
			end

			if buff.can_trigger and buff_type == "RANGED" and (hit_zone == "head" or hit_zone == "neck") and is_critical then
				local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
				local buff_to_add = buff.template.buff_to_add

				buff_extension:add_buff(buff_to_add)

				buff.can_trigger = false
			elseif buff.can_trigger and buff_type == "RANGED_ABILITY" and (hit_zone == "head" or hit_zone == "neck") and is_critical then
				local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
				local buff_to_add_1 = buff.template.buff_to_add_1

				buff_extension:add_buff(buff_to_add_1)

				buff.can_trigger = false
			end
		end
end
BuffFunctionTemplates.functions.add_victor_bountyhunter_refresh_blessed_shot_on_headshot_crit_buff_delayed = function (unit, buff, params)
	local player_unit = unit
	if Unit.alive(player_unit) then
		local template = buff.template
		local procced = math.random() <= template.proc_chance
		local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
		local has_cooldown = buff_extension:get_non_stacking_buff("victor_bountyhunter_refresh_blessed_shot_cooldown")
		if procced and not has_cooldown then
			local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
			buff_extension:add_buff("victor_bountyhunter_refresh_blessed_shot_timer")
		end
	end
end
--[[BuffFunctionTemplates.functions.add_victor_bountyhunter_refresh_blessed_shot_on_headshot_crit_buff_delayed_guaranteed = function (unit, buff, params)
	local player_unit = unit
	if Unit.alive(player_unit) then
		local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
		buff_extension:add_buff("victor_bountyhunter_refresh_blessed_shot_timer_guaranteed")
	end
end]]
BuffFunctionTemplates.functions.victor_bountyhunter_remove_passive_cooldown_on_remove = function (unit, buff, params)
	local player_unit = unit
	if Unit.alive(player_unit) then
		local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
		local has_buff1 = buff_extension:get_non_stacking_buff("victor_bountyhunter_passive_crit_cooldown")  
		local has_buff2 = buff_extension:get_non_stacking_buff("victor_bountyhunter_passive_reduced_cooldown")
		if has_buff1 then
			buff_extension:remove_buff(has_buff1.id)
		end
		if has_buff2 then
			buff_extension:remove_buff(has_buff2.id)
		end
		buff_extension:add_buff("victor_bountyhunter_refresh_blessed_shot_cooldown")
	end
end
BuffFunctionTemplates.functions.victor_bountyhunter_remove_passive_cooldown_on_remove_guaranteed = function (unit, buff, params)
	local player_unit = unit
	if Unit.alive(player_unit) then
		local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
		local has_buff1 = buff_extension:get_non_stacking_buff("victor_bountyhunter_passive_crit_cooldown")  
		local has_buff2 = buff_extension:get_non_stacking_buff("victor_bountyhunter_passive_reduced_cooldown")
		if has_buff1 then
			buff_extension:remove_buff(has_buff1.id)
		end
		if has_buff2 then
			buff_extension:remove_buff(has_buff2.id)
		end
	end
end
BuffTemplates.victor_bountyhunter_refresh_blessed_shot_on_headshot_crit = {
	buffs = {
		{
			name = "victor_bountyhunter_refresh_blessed_shot_on_headshot_crit",
			max_stacks = 1,
			event = "on_hit",
			buff_to_add = "victor_bountyhunter_refresh_blessed_shot_on_headshot_crit_buff",
			buff_to_add_1 = "victor_bountyhunter_refresh_blessed_shot_timer_guaranteed", --"victor_bountyhunter_refresh_blessed_shot_on_headshot_crit_buff_guaranteed",
			event_buff = true,
			buff_func = "victor_bountyhunter_refresh_blessed_shot_on_headshot_crit"
		}
	}
}
BuffTemplates.victor_bountyhunter_refresh_blessed_shot_on_headshot_crit_buff = {
	buffs = {
		{
			name = "victor_bountyhunter_refresh_blessed_shot_on_headshot_crit_buff",
			max_stacks = 1,
			duration = 0, --0.1,
			proc_chance = 1,
			remove_buff_func = "add_victor_bountyhunter_refresh_blessed_shot_on_headshot_crit_buff_delayed"
		}
	}
}
BuffTemplates.victor_bountyhunter_refresh_blessed_shot_on_headshot_crit_buff_guaranteed = {
	buffs = {
		{
			name = "victor_bountyhunter_refresh_blessed_shot_on_headshot_crit_buff_guaranteed",
			max_stacks = 1,
			duration = 0, --0.1,
			remove_buff_func = "add_victor_bountyhunter_refresh_blessed_shot_on_headshot_crit_buff_delayed_guaranteed"
		}
	}
}
BuffTemplates.victor_bountyhunter_refresh_blessed_shot_timer = {
	buffs = {
		{
			name = "victor_bountyhunter_refresh_blessed_shot_timer",
			max_stacks = 1,
			is_cooldown = true,
			duration = 0, --0.05,
			--icon = "victor_witchhunter_power_level_unbalance",
			buff_after_delay = true,
			delayed_buff_name = "victor_bountyhunter_passive_crit_buff",
			remove_buff_func = "victor_bountyhunter_remove_passive_cooldown_on_remove"
		}
	}
}
BuffTemplates.victor_bountyhunter_refresh_blessed_shot_timer_guaranteed = {
	buffs = {
		{
			name = "victor_bountyhunter_refresh_blessed_shot_timer_guaranteed",
			max_stacks = 1,
			is_cooldown = true,
			duration = 0, --0.05,
			--icon = "victor_witchhunter_power_level_unbalance",
			buff_after_delay = true,
			delayed_buff_name = "victor_bountyhunter_passive_crit_buff",
			remove_buff_func = "victor_bountyhunter_remove_passive_cooldown_on_remove_guaranteed"
		}
	}
}
BuffTemplates.victor_bountyhunter_refresh_blessed_shot_cooldown = {
	buffs = {
		{
			name = "victor_bountyhunter_refresh_blessed_shot_cooldown",
			is_cooldown = true,
			duration = 10,
			max_stacks = 1,
			icon = "victor_bountyhunter_passive_infinite_ammo"
		}
	}
}
--[rile the mob]
ProcFunctions.victor_bountyhunter_rile_the_mob = function (player, buff, params)
		local player_unit = player.player_unit
		local function is_server()
			return Managers.player.is_server
		end

		if Unit.alive(player_unit) then
			local buff_type = params[5]
			local is_critical = params[6]

			if is_critical and not MeleeBuffTypes[buff_type] then
				local side = Managers.state.side.side_by_unit[player_unit]
				local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
				local num_targets = #player_and_bot_units
				local range = 40
				local buff_template = buff.template
				local network_manager = Managers.state.network
				local network_transmit = network_manager.network_transmit
				local unit_object_id = network_manager:unit_game_object_id(player_unit)
				local owner_position = POSITION_LOOKUP[player_unit]
				local range_squared = range * range
				local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
				local buff_to_add_1 = buff_template.buff_to_add_1
				--local buff_to_add_2 = buff_template.buff_to_add_2
				--local buff_to_add_3 = buff_template.buff_to_add_3
				local buffs_to_add = {
							"victor_bountyhunter_party_movespeed_on_ranged_crit_buff",
							"victor_bountyhunter_party_dodge_distance_on_ranged_crit_buff",
							"victor_bountyhunter_party_dodge_speed_on_ranged_crit_buff"
						}

				buff_extension:add_buff(buff_to_add_1)
				--buff_extension:add_buff(buff_to_add_2)
				--buff_extension:add_buff(buff_to_add_3)

				for i = 1, num_targets, 1 do
					local target_unit = player_and_bot_units[i]
					local ally_position = POSITION_LOOKUP[target_unit]
					local distance_squared = Vector3.distance_squared(owner_position, ally_position)

					if distance_squared < range_squared then
						for i = 1, #buffs_to_add, 1 do
							local buff_name = buffs_to_add[i]
							local target_unit_object_id = network_manager:unit_game_object_id(target_unit)
							local target_buff_extension = ScriptUnit.extension(target_unit, "buff_system")
							local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

							if is_server() then
								target_buff_extension:add_buff(buff_name)
								network_transmit:send_rpc_clients("rpc_add_buff", target_unit_object_id, buff_template_name_id, unit_object_id, 0, false)
							else
								network_transmit:send_rpc_server("rpc_add_buff", target_unit_object_id, buff_template_name_id, unit_object_id, 0, true)
							end
						end
					end
				end
			end
		end
end
BuffTemplates.victor_bountyhunter_party_movespeed_on_ranged_crit.buffs[1].buff_func = "victor_bountyhunter_rile_the_mob"
BuffTemplates.victor_bountyhunter_party_movespeed_on_ranged_crit.buffs[1].buff_to_add_1 = "victor_bountyhunter_movespeed_on_ranged_crit_buff"
--BuffTemplates.victor_bountyhunter_party_movespeed_on_ranged_crit.buffs[1].buff_to_add_2 = "victor_bountyhunter_dodge_distance_on_ranged_crit_buff"
--BuffTemplates.victor_bountyhunter_party_movespeed_on_ranged_crit.buffs[1].buff_to_add_3 = "victor_bountyhunter_dodge_speed_on_ranged_crit_buff"
BuffTemplates.victor_bountyhunter_movespeed_on_ranged_crit_buff = {
	buffs = {
		{
			remove_buff_func = "remove_movement_buff",
			refresh_durations = true,
			name = "victor_bountyhunter_movespeed_on_ranged_crit_buff",
			max_stacks = 1,
			multiplier = 1.1,
			duration = 10,
			apply_buff_func = "apply_movement_buff",
			path_to_movement_setting_to_modify = {
				"move_speed"
			}
		}
	}
}
BuffTemplates.victor_bountyhunter_party_dodge_distance_on_ranged_crit_buff = {
	buffs = {
		{
			name = "victor_bountyhunter_party_dodge_distance_on_ranged_crit_buff",
			duration = 10,
			multiplier = 1.1,
			refresh_durations = true,
			max_stacks = 1,
			remove_buff_func = "remove_movement_buff",
			apply_buff_func = "apply_movement_buff",
			--icon = "victor_witchhunter_dodge_range",
			path_to_movement_setting_to_modify = {
				"dodging",
				"distance_modifier"
			}
		}
	}
}
BuffTemplates.victor_bountyhunter_party_dodge_speed_on_ranged_crit_buff = {
	buffs = {
		{
			name = "victor_bountyhunter_party_dodge_speed_on_ranged_crit_buff",
			duration = 10,
			refresh_durations = true,
			multiplier = 1.1,
			max_stacks = 1,
			remove_buff_func = "remove_movement_buff",
			--icon = "victor_witchhunter_dodge_range",
			apply_buff_func = "apply_movement_buff",
			path_to_movement_setting_to_modify = {
				"dodging",
				"speed_modifier"
			}
		}
	}
}
--[[BuffTemplates.victor_bountyhunter_dodge_distance_on_ranged_crit_buff = {
	buffs = {
		{
			name = "victor_bountyhunter_dodge_distance_on_ranged_crit_buff",
			duration = 10,
			multiplier = 1.1,
			refresh_durations = true,
			remove_buff_func = "remove_movement_buff",
			apply_buff_func = "apply_movement_buff",
			icon = "victor_captain_activated_ability_stagger_ping_debuff",
			path_to_movement_setting_to_modify = {
				"dodging",
				"distance_modifier"
			}
		}
	}
}
BuffTemplates.victor_bountyhunter_dodge_speed_on_ranged_crit_buff = {
	buffs = {
		{
			name = "victor_bountyhunter_dodge_speed_on_ranged_crit_buff",
			duration = 10,
			refresh_durations = true,
			multiplier = 1.1,
			remove_buff_func = "remove_movement_buff",
			icon = "victor_captain_activated_ability_stagger_ping_debuff",
			apply_buff_func = "apply_movement_buff",
			path_to_movement_setting_to_modify = {
				"dodging",
				"speed_modifier"
			}
		}
	}
}]]
--[salvage]
ProcFunctions.victor_bounty_hunter_ammo_fraction_gain_out_of_ammo = function (player, buff, params)
		local player_unit = player.player_unit

		if player and player.remote then
			return
		end

		if Unit.alive(player_unit) then
			local killed_unit_breed_data = params[2]

			if killed_unit_breed_data.elite or killed_unit_breed_data.special then
				local buff_template = buff.template
				local weapon_slot = "slot_ranged"
				local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
				local slot_data = inventory_extension:get_slot_data(weapon_slot)
				local right_unit_1p = slot_data.right_unit_1p
				local left_unit_1p = slot_data.left_unit_1p
				local right_hand_ammo_extension = ScriptUnit.has_extension(right_unit_1p, "ammo_system")
				local left_hand_ammo_extension = ScriptUnit.has_extension(left_unit_1p, "ammo_system")
				local ammo_extension = right_hand_ammo_extension or left_hand_ammo_extension
				local current_ammo = ammo_extension:remaining_ammo()
				local clip_ammo = ammo_extension:ammo_count()

				if current_ammo < 1 and clip_ammo < 1 then
					local ammo_bonus_fraction = buff_template.ammo_bonus_fraction
					local ammo_amount = math.max(math.round(ammo_extension:max_ammo() * ammo_bonus_fraction), 1)

					if ammo_extension then
						ammo_extension:add_ammo_to_reserve(ammo_amount)
					end
				end
			end
		end
	end
--ULT CHANGES
--just reward buffs
Talents.witch_hunter[33].buffs = {
	"victor_bountyhunter_activated_ability_passive_cooldown_reduction",
	"victor_bountyhunter_activated_ability_penetration",
	"victor_bountyhunter_activated_ability_additional_penetration_on_penetrate"
}
ProcFunctions.victor_bountyhunter_additional_penetration_on_activated_ability_crit = function (player, buff, params)
	local player_unit = player.player_unit
	local action_type = params[1]
	local ranged_ability = action_type == "career_wh_two"
	if Unit.alive(player_unit) then
		if ranged_ability then
			local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
			buff_extension:add_buff("victor_bountyhunter_activated_ability_penetration_buff")
		end
	end
end
ProcFunctions.victor_bountyhunter_add_additional_penetration = function (player, buff, params)
	local player_unit = player.player_unit

	if Unit.alive(player_unit) then
			local hit_zone = params[3]
			local target_number = params[4]
			local buff_type = params[5]

			if target_number and target_number >= 2 then
				buff.can_trigger = true
			end

			if buff.can_trigger and buff_type == "RANGED_ABILITY" then
				local buff_extension = ScriptUnit.extension(player_unit, "buff_system")

				buff_extension:add_buff("victor_bountyhunter_activated_ability_additional_penetration_on_penetrate_buff")

				buff.can_trigger = false
			end
	end
end
BuffTemplates.victor_bountyhunter_activated_ability_penetration = {
	buffs = {
		{
			name = "victor_bountyhunter_activated_ability_penetration",
			max_stacks = 1,
			event = "on_critical_action",
			event_buff = true,
			buff_func = "victor_bountyhunter_additional_penetration_on_activated_ability_crit"
		}
	}
}
BuffTemplates.victor_bountyhunter_activated_ability_penetration_buff = {
	buffs = {
		{
			name = "victor_bountyhunter_activated_ability_penetration_buff",
			duration = 1,
			bonus = 1,
			refresh_durations = true,
			stat_buff = "ranged_additional_penetrations",
			max_stacks = 1
		}
	}
}
BuffTemplates.victor_bountyhunter_activated_ability_additional_penetration_on_penetrate = {
	buffs = {
		{
			name = "victor_bountyhunter_activated_ability_additional_penetration_on_penetrate",
			max_stacks = 1,
			event_buff = true,
			event = "on_hit",
			buff_func = "victor_bountyhunter_add_additional_penetration"
		}
	}
}
BuffTemplates.victor_bountyhunter_activated_ability_additional_penetration_on_penetrate_buff = {
	buffs = {
		{
			name = "victor_bountyhunter_activated_ability_additional_penetration_on_penetrate_buff",
			max_stacks = 1,
			duration = 15,
			refresh_durations = true,
			stat_buff = "ranged_additional_penetrations",
			bonus = 1,
			icon = "victor_bountyhunter_activated_ability_reset_cooldown_on_stacks"
		}
	}
}
--[just reward]
BuffTemplates.victor_bountyhunter_activated_ability_passive_cooldown_reduction.buffs[1].multiplier = 0.25
--[double shotted]
--[buckshot]
Talents.witch_hunter[32].buffs = {
	"victor_bountyhunter_activated_ability_blast_shotgun",
	"victor_bountyhunter_blast_penetration"
}
BuffTemplates.victor_bountyhunter_activated_ability_blast_shotgun.buffs[1].stat_buff = nil
BuffTemplates.victor_bountyhunter_activated_ability_blast_shotgun.buffs[1].multiplier = nil
BuffTemplates.victor_bounty_blast_streak_buff.buffs[1].stat_buff = "cooldown_regen"
BuffTemplates.victor_bounty_blast_streak_buff.buffs[1].multiplier = 0.075
BuffTemplates.victor_bounty_blast_streak_buff.buffs[1].icon = "victor_bountyhunter_activated_ability_shotgun"
ProcFunctions.victor_bountyhunter_blast_penetrations = function (player, buff, params)
	local player_unit = player.player_unit

		if ALIVE[player_unit] then
			local new_action = params[1]
			local kind = new_action.kind

			if kind == "career_wh_two" then
				local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
				local template = buff.template
				local buff_to_add = template.buff_to_add
				buff_extension:add_buff(buff_to_add)
			end
		end
end
BuffTemplates.victor_bountyhunter_blast_penetration = {
	buffs = {
		{
			name = "victor_bountyhunter_blast_penetration",
			event = "on_start_action",
			max_stacks = 1,
			event_buff = true,
			buff_to_add = "victor_bountyhunter_blast_penetration_buff",
			buff_func = "victor_bountyhunter_blast_penetrations"
		}
	}
}
BuffTemplates.victor_bountyhunter_blast_penetration_buff = {
	buffs = {
		{
			stat_buff = "ranged_additional_penetrations",
			max_stacks = 1,
			duration = 0.6,
			bonus = 2
		}
	}
}
--buckshot wep CHANGES
--Weapons.victor_bountyhunter_career_skill_weapon.actions.action_career_release.default.shot_count = 15
ActionBountyHunterHandgun._shotgun_shoot = function (self)
	local world = self.world
	local owner_unit = self.owner_unit
	local current_action = self.current_action
	local spread_extension = self.spread_extension
	local is_server = self.is_server
	local spread_template_override = current_action.shotgun_spread_template

	if spread_template_override then
		self.spread_extension:override_spread_template(spread_template_override)
	end

	local first_person_extension = ScriptUnit.extension(owner_unit, "first_person_system")
	local current_position, current_rotation = first_person_extension:get_projectile_start_position_rotation()
	local num_shots = current_action.shot_count or 1
	local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	local damage_bonus = 0

	if buff_extension:has_buff_type("victor_bounty_blast_streak_buff") then
		num_shots = num_shots + 5
	end

	if not Managers.player:owner(owner_unit).bot_player then
		Managers.state.controller_features:add_effect("rumble", {
			rumble_effect = "handgun_fire"
		})
	end

	local physics_world = World.get_data(world, "physics_world")
	local check_buffs = true
	local weapon_unit = self.weapon_unit

	for i = 1, num_shots, 1 do
		local rotation = current_rotation

		if spread_extension then
			rotation = spread_extension:get_target_style_spread(i, num_shots, current_rotation)
		end

		local direction = Quaternion.forward(rotation)
		local result = PhysicsWorld.immediate_raycast_actors(physics_world, current_position, direction, current_action.range, "static_collision_filter", "filter_player_ray_projectile_static_only", "dynamic_collision_filter", "filter_player_ray_projectile_ai_only", "dynamic_collision_filter", "filter_player_ray_projectile_hitbox_only")

		if result then
			local data = DamageUtils.process_projectile_hit(world, self.item_name, owner_unit, is_server, result, current_action, direction, check_buffs, nil, self.shield_users_blocking, self.is_critical_strike, self.power_level)

			if data.buffs_checked then
				check_buffs = check_buffs and false
			end

			if data.blocked_by_unit then
				self.shield_users_blocking[data.blocked_by_unit] = true
			end
		end

		local hit_position = (result and result[#result][1]) or current_position + direction * current_action.range

		Unit.set_flow_variable(weapon_unit, "hit_position", hit_position)
		Unit.set_flow_variable(weapon_unit, "trail_life", Vector3.length(hit_position - current_position) * 0.1)
		Unit.flow_event(weapon_unit, "lua_bullet_trail")
		Unit.flow_event(weapon_unit, "lua_bullet_trail_set")
	end

	local add_spread = not self.extra_buff_shot

	if spread_extension and add_spread then
		spread_extension:set_shooting()
	end

	if current_action.alert_sound_range_fire then
		Managers.state.entity:system("ai_system"):alert_enemies_within_range(owner_unit, POSITION_LOOKUP[owner_unit], current_action.alert_sound_range_fire)
	end
end
--experimental

--[ZEALOT]:

TalentTrees.witch_hunter[1] = {
		{
			"victor_zealot_reaper",
			"victor_zealot_bloodlust_2",
			"victor_zealot_heal_share"
		},
		{
			"victor_zealot_attack_speed_on_health_percent",
			"victor_zealot_crit_count",
			"victor_zealot_reduced_damage_taken"
		},
		{
			"victor_zealot_smiter_unbalance",
			"victor_zealot_linesman_unbalance",
			"victor_zealot_power_level_unbalance"
		},
		{
			"victor_zealot_passive_move_speed",
			"victor_zealot_passive_healing_received",
			"victor_zealot_passive_damage_taken"
		},
		{
			"victor_zealot_move_speed_on_damage_taken",
			"victor_zealot_max_stamina_on_damage_taken",
			"victor_zealot_power"
		},
		{
			"victor_zealot_activated_ability_power_on_hit",
			"victor_zealot_activated_ability_ignore_death",
			"victor_zealot_activated_ability_cooldown_stack_on_hit"
		}
	}
CareerAbilityWHZealot.update = function (self, unit, input, dt, context, t)
	if not self:_ability_available() then
		return
	end

	local input_extension = self._input_extension

	if not input_extension then
		return
	end

	if not self._is_priming then
		if input_extension:get("action_career") then
			self:_start_priming()
		end
	elseif self._is_priming then
		self:_update_priming(dt)

		if input_extension:get("action_two") then
			self:_stop_priming()
			return
		end

		if input_extension:get("action_three") then
			self:_stop_priming()
			local network_manager = self._network_manager
			local network_transmit = network_manager.network_transmit
			local is_server = self._is_server
			local owner_unit = self._owner_unit
			local buff_extension = self._buff_extension
			
			local buff_name = "zealot_flaggelate_damage" --"zealot_flaggelate"
			local unit_object_id = network_manager:unit_game_object_id(owner_unit)
			local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

			buff_extension:add_buff("zealot_flaggelate_damage")
			--if is_server then
				--[[buff_extension:add_buff(buff_name, {
					attacker_unit = owner_unit
				})]]
			--[[	network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
			else
				network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
			end]]
		end

		if input_extension:get("weapon_reload") then
			self:_stop_priming()

			return
		end

		if not input_extension:get("action_career_hold") then
			self:_run_ability()
		end
	end
end
BuffFunctionTemplates.functions.zealot_flaggelate_damage_start = function (unit, buff, params)
		buff.next_damage_time = params.t + buff.template.time_between_damage
	end
BuffFunctionTemplates.functions.zealot_flaggelate_damage_update = function (unit, buff, params)
		if buff.next_damage_time < params.t then
			local buff_template = buff.template
			buff.next_damage_time = buff.next_damage_time + buff_template.time_between_damage
			local damage = buff_template.damage
			local damage_type = buff_template.damage_type

			DamageUtils.add_damage_network(unit, unit, damage, "full", damage_type, nil, Vector3(1, 0, 0), "health_degen")
		end
	end
BuffFunctionTemplates.functions.zealot_flaggelate_damage_then_heal = function (unit, buff, params)
	local health_extension = ScriptUnit.extension(unit, "health_system")
	local permanent_hp_damage = 15
	
	if health_extension:current_permanent_health() > 15 then
		--DamageUtils.add_damage_network(unit, unit, permanent_hp_damage, "full", damage_type, nil, Vector3(1, 0, 0), "health_degen")
		--DamageUtils.add_damage_network(unit, unit, permanent_hp_damage, "torso", "death_explosion", nil, Vector3(1, 0, 0), "undefined")
		DamageUtils.add_damage_network(unit, unit, permanent_hp_damage, "torso", "death_explosion", nil, Vector3(1, 0, 0), "undefined")
	end
end
BuffTemplates.zealot_flaggelate_damage = {
	buffs = {
		{
			duration = 0,
			name = "zealot_flaggelate_damage",
			icon = "bardin_slayer_crit_chance",
			apply_buff_func = "zealot_flaggelate_damage_then_heal", --"zealot_flaggelate_damage_start",
			max_stacks = 1
		}
	}
}
BuffTemplates.zealot_flaggelate = {
		buffs = {
			{
				max_stacks = 1,
				duration = 1,
				name = "zealot_flaggelate",
				apply_buff_func = "convert_permanent_to_temporary_health"
			}
		}
	}
--[LEVEL 10 TALENTS]:
--[UNBENDING PURPOSE]:
Talents.witch_hunter[5].buffer = "both"
Talents.witch_hunter[5].buffs = {
	"victor_zealot_melee_power_on_damage_taken"
}
BuffTemplates.victor_zealot_melee_power_on_damage_taken = {
	buffs = {
		{
			name = "victor_zealot_melee_power_on_damage_taken",
			event_buff = true,
			event = "on_damage_taken",
			max_stacks = 1,
			buff_func = "zealot_melee_power_on_damage_taken",
			buff_to_add = "victor_zealot_power_buff",
			perk = "uninterruptible"
		}
	}
}
BuffTemplates.victor_zealot_power_buff = {
	buffs = {
		{
			name = "victor_zealot_power_buff",
			stat_buff = "power_level_melee",
			icon = "victor_zealot_power",
			max_stacks = 1,
			duration = 5,
			refresh_durations = true,
			multiplier = 0.15
		}
	}
}
ProcFunctions.zealot_melee_power_on_damage_taken = function (player, buff, params)
		local player_unit = player.player_unit

		if Unit.alive(player_unit) then
			local attacker_unit = params[1]
			local damage_amount = params[2]
			local damage_type = params[3]
			local buff_system = Managers.state.entity:system("buff_system")
			local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
			local template = buff.template
			local buff_name = template.buff_to_add
			local player_side = Managers.state.side.side_by_unit[player_unit]
			local attacker_side = Managers.state.side.side_by_unit[attacker_unit]
			local is_ally = player_side == attacker_side
			local network_manager = Managers.state.network
			local network_transmit = network_manager.network_transmit
			local unit_object_id = network_manager:unit_game_object_id(player_unit)
			local buff_template_name_id = NetworkLookup.buff_templates[buff_name]
			local function is_server()
				return Managers.player.is_server
			end
			if not is_ally and attacker_unit ~= player_unit and damage_amount > 0 and damage_type ~= "overcharge" then
				if is_server() then
					buff_extension:add_buff(buff_name, {
						attacker_unit = player_unit
					})
					network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
				else
					network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
				end
			end
		end
	end
--[CALLOUSED WITHOUT AND WITHIN]:
BuffTemplates.victor_zealot_reduced_damage_taken_buff.buffs[1].stat_buff = nil
BuffTemplates.victor_zealot_reduced_damage_taken_buff.buffs[1].buff_to_add = "victor_zealot_resist_death_on_kill_buff"
BuffTemplates.victor_zealot_reduced_damage_taken_buff.buffs[1].event_buff = true	
BuffTemplates.victor_zealot_reduced_damage_taken_buff.buffs[1].event = "on_kill"
BuffTemplates.victor_zealot_reduced_damage_taken_buff.buffs[1].buff_func = "add_buff"
BuffTemplates.victor_zealot_resist_death_on_kill_buff = {
	buffs = {
		{
			name = "victor_zealot_resist_death_on_kill_buff",
			max_stacks = 1,
			refresh_durations = true,
			icon = "victor_zealot_reduced_damage_taken",
			duration = 2,
			perk = "ignore_death"
		}
	}
}
--[FAITH'S FLURRY]:
Talents.witch_hunter[13].description_values[2].value = 10
BuffTemplates.victor_zealot_activated_ability_power_on_hit_buff.buffs[1].duration = 10
-------------------------------------------------------
--					//////[BARDIN]\\\\\\
-------------------------------------------------------
--[RANGER VETERAN]:
--[FOE FELLER]
--"When a teammate or Bardin picks up Survivalist Ammunition Bardin receives 2.5 percent attack speed and damage to the first enemy hit by a melee attack for 30 seconds. Stacks 4 times."
Talents.dwarf_ranger[43].buffer = "both"
Talents.dwarf_ranger[43].buffs = {
	"bardin_ranger_passive_attack_speed_on_ally_ammo_pickup",
	"bardin_ranger_passive_first_melee_hit_dmg_on_ally_ammo_pickup"
}
BuffTemplates.bardin_ranger_passive_first_melee_hit_dmg_on_ally_ammo_pickup_buff = {
	buffs = {
		{
			name = "bardin_ranger_passive_first_melee_hit_dmg_on_ally_ammo_pickup_buff",
			multiplier = 0.025,
			max_stacks = 4,
			duration = 50,
			refresh_durations = true,
			stat_buff = "first_melee_hit_damage"
		}
	}
}
BuffTemplates.bardin_ranger_passive_attack_speed_on_ally_ammo_pickup_buff = {
	buffs = {
		{
			name = "bardin_ranger_passive_attack_speed_on_ally_ammo_pickup_buff",
			stat_buff = "attack_speed",
			icon = "bardin_ranger_attack_speed",
			multiplier = 0.025,
			max_stacks = 4,
			duration = 50,
			refresh_durations = true
		}
	}
}
BuffTemplates.bardin_ranger_passive_first_melee_hit_dmg_on_ally_ammo_pickup = {
		buffs = {
			{
				max_stacks = 1,
				name = "bardin_ranger_passive_first_melee_hit_dmg_on_ally_ammo_pickup",
				buff_to_add = "bardin_ranger_passive_first_melee_hit_dmg_on_ally_ammo_pickup_buff",
				event = "on_bardin_consumable_picked_up_any_player",
				event_buff = true,
				buff_func = "add_buff"
			}
		}
	}
BuffTemplates.bardin_ranger_passive_attack_speed_on_ally_ammo_pickup = {
		buffs = {
			{
				max_stacks = 1,
				name = "bardin_ranger_passive_attack_speed_on_ally_ammo_pickup",
				buff_to_add = "bardin_ranger_passive_attack_speed_on_ally_ammo_pickup_buff",
				event = "on_bardin_consumable_picked_up_any_player",
				event_buff = true,
				buff_func = "add_buff"
			}
		}
	}
--[FIRST DIBS]
ProcFunctions.ranger_first_dibs_pickup = function (player, buff, params)
		local player_unit = player.player_unit
		local function find_pickup_buff_settings(buff, pickup_settings)
			local template = buff.template
			local buff_settings = (template.pickup_names and template.pickup_names[pickup_settings.pickup_name]) or (template.pickup_slot_names and template.pickup_slot_names[pickup_settings.slot_name]) or (template.pickup_types and template.pickup_types[pickup_settings.type])

			return buff_settings
		end
		local buff_extension = ScriptUnit.extension(player_unit, "buff_system")

		if ALIVE[player_unit] and buff_extension:has_buff_type("bardin_ranger_first_dibs_buffs_cooldown_ready") then
			local template = buff.template
			local buff_to_remove1 = template.buff_to_remove1
			local buff_to_check = template.buff_to_check
			local buff_extension = ScriptUnit.extension(player_unit, "buff_system")

			local pickup_settings = params[2]
			local pickup_specific_settings = find_pickup_buff_settings(buff, pickup_settings)

			if pickup_specific_settings then
				if buff.template.local_only then
					local buff_extension = ScriptUnit.extension(player_unit, "buff_system")

					for i = 1, #pickup_specific_settings, 1 do
						buff_extension:add_buff(pickup_specific_settings[i])
					end
				else
					local buff_system = Managers.state.entity:system("buff_system")

					for i = 1, #pickup_specific_settings, 1 do
						buff_system:add_buff(player_unit, pickup_specific_settings[i], player_unit, false)
					end
				end
				if buff_extension:has_buff_type(buff_to_remove1) then
					local has_buff_to_remove1 = buff_extension:get_non_stacking_buff(buff_to_remove1)

					if has_buff_to_remove1 then
						buff_extension:remove_buff(has_buff_to_remove1.id)
					end
				end
				local player_unit = player.player_unit
				local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
				buff_extension:add_buff("bardin_ranger_first_dibs_buffs_cooldown")
			end
		else
			return
		end
	end 
BuffFunctionTemplates.functions.bardin_ranger_apply_first_dibs = function (unit, buff, params)
		local player_unit = unit

		if ALIVE[player_unit] then
			local template = buff.template
			local buff_to_remove = template.buff_to_remove
			local buff_extension = ScriptUnit.extension(player_unit, "buff_system")

			buff_extension:add_buff(buff_to_remove)
		end
	end
Talents.dwarf_ranger[47].buffer = "both"
Talents.dwarf_ranger[47].buffs = {
	"bardin_ranger_first_dibs_buffs",
	"bardin_ranger_movement_speed"
}			
BuffTemplates.bardin_ranger_first_dibs_buffs_cooldown = {
	buffs = {
		{
			name = "bardin_ranger_first_dibs_buffs_cooldown",
			duration = 30,
			buff_after_delay = true,
			is_cooldown = true,
			icon = "bardin_ranger_movement_speed",
			max_stacks = 1,
			refresh_durations = true,
			delayed_buff_name = "bardin_ranger_first_dibs_buffs_cooldown_ready"
		}
	}
}
BuffTemplates.bardin_ranger_first_dibs_buffs_cooldown_ready = {
	buffs = {
		{
			max_stacks = 1,
			name = "bardin_ranger_first_dibs_buffs_cooldown_ready",
			icon = "bardin_ranger_movement_speed"
		}
	}
}
BuffTemplates.bardin_ranger_first_dibs_buffs = {
	buffs = {
		{
			name = "bardin_ranger_first_dibs_buffs",
			event_buff = true,
			max_stacks = 1,
			buff_to_remove1 = "bardin_ranger_first_dibs_buffs_cooldown_ready",
			buff_to_remove = "bardin_ranger_first_dibs_buffs_cooldown_ready",
			apply_buff_func = "bardin_ranger_apply_first_dibs",
			buff_func = "ranger_first_dibs_pickup",
			event = "on_consumable_picked_up",
			pickup_names = {
				damage_boost_potion = {
					"bardin_ranger_first_dibs_strength_buffs",
					"bardin_ranger_first_dibs_potion_buffs"
				},
				speed_boost_potion = {
					"bardin_ranger_first_dibs_speed_buffs",
					"bardin_ranger_first_dibs_potion_buffs"
				},
				cooldown_reduction_potion = {
					"bardin_ranger_first_dibs_cooldown_buffs",
					"bardin_ranger_first_dibs_potion_buffs"
				},
				first_aid_kit = {
					"bardin_ranger_first_dibs_heal_buffs",
					"bardin_ranger_first_dibs_heal_buffs1"
				},
				healing_draught = {
					"bardin_ranger_first_dibs_heal_buffs",
					"bardin_ranger_first_dibs_heal_buffs1"
				},
				frag_grenade_t1 = {
					"bardin_ranger_first_dibs_grenadet1_buffs",
					"bardin_ranger_first_dibs_grenade_buffs"
				},
				fire_grenade_t1 = {
					"bardin_ranger_first_dibs_grenadet1_buffs",
					"bardin_ranger_first_dibs_grenade_buffs"
				},
				frag_grenade_t2 = {
					"bardin_ranger_first_dibs_grenadet2_buffs",
					"bardin_ranger_first_dibs_grenade_buffs"
				},
				fire_grenade_t2 = {
					"bardin_ranger_first_dibs_grenadet2_buffs",
					"bardin_ranger_first_dibs_grenade_buffs"
				},
				bardin_survival_ale = {
					"bardin_ranger_first_dibs_ale_buffs"
				},
				liquid_bravado_potion = {
					"bardin_ranger_first_dibs_liquid_bravado_buffs",
					"bardin_ranger_first_dibs_potion_buffs"
				},
				vampiric_draught_potion = {
					"bardin_ranger_first_dibs_vampiric_draught_buffs",
					"bardin_ranger_first_dibs_potion_buffs"
				},
				moot_milk_potion = {
					"bardin_ranger_first_dibs_moot_milk_buffs",
					"bardin_ranger_first_dibs_potion_buffs"
				},
				friendly_murderer_potion = {
					"bardin_ranger_first_dibs_friendly_murderer_buffs",
					"bardin_ranger_first_dibs_potion_buffs"
				},
				killer_in_the_shadows_potion = {
					"bardin_ranger_first_dibs_killer_in_the_shadows_buffs",
					"bardin_ranger_first_dibs_potion_buffs"
				},
				pockets_full_of_bombs_potion = {
					"bardin_ranger_first_dibs_pockets_full_of_bombs_buffs",
					"bardin_ranger_first_dibs_potion_buffs"
				},
				hold_my_beer_potion = {
					"bardin_ranger_first_dibs_hold_my_beer_buffs",
					"bardin_ranger_first_dibs_potion_buffs"
				},
				poison_proof_potion = {
					"bardin_ranger_first_dibs_poison_proof_buffs",
					"bardin_ranger_first_dibs_potion_buffs"
				}
			}
		}
	}
}
BuffTemplates.bardin_ranger_first_dibs_liquid_bravado_buffs = {
		buffs = {
			{
				name = "bardin_ranger_first_dibs_liquid_bravado_buffs",
				stat_buff = "power_level",
				max_stacks = 1,
				icon = "potion_liquid_bravado",
				refresh_durations = true,
				multiplier = 0.5,
				duration = 5
			}
		}
	}
BuffTemplates.bardin_ranger_first_dibs_vampiric_draught_buffs = {
		buffs = {
			{
				icon = "potion_vampiric_draught",
				name = "bardin_ranger_first_dibs_vampiric_draught_buffs",
				buff_func = "vampiric_heal",
				event = "on_damage_dealt",
				refresh_durations = true,
				event_buff = true,
				max_stacks = 1,
				duration = 20,
				multiplier = 0.1
			}
		}
	}
BuffTemplates.bardin_ranger_first_dibs_moot_milk_buffs = {
		buffs = {
			{
				apply_buff_func = "apply_movement_buff",
				name = "bardin_ranger_first_dibs_moot_milk_buffs",
				icon = "potion_moot_milk",
				refresh_durations = true,
				remove_buff_func = "remove_movement_buff",
				max_stacks = 1,
				multiplier = 1.5,
				duration = 20,
				path_to_movement_setting_to_modify = {
					"dodging",
					"distance_modifier"
				}
			},
			{
				name = "bardin_ranger_first_dibs_moot_milk_buffs1",
				max_stacks = 1,
				remove_buff_func = "remove_movement_buff",
				apply_buff_func = "apply_movement_buff",
				refresh_durations = true,
				multiplier = 1.5,
				duration = 20,
				path_to_movement_setting_to_modify = {
					"dodging",
					"speed_modifier"
				}
			}
		}
	}
BuffTemplates.bardin_ranger_first_dibs_friendly_murderer_buffs = {
		buffs = {
			{
				name = "bardin_ranger_first_dibs_friendly_murderer_buffs",
				buff_func = "friendly_murder",
				event = "on_damage_dealt",
				refresh_durations = true,
				event_buff = true,
				max_stacks = 1,
				icon = "potion_friendly_murderer",
				duration = 20,
				multiplier = 0.1,
				range = 10
			}
		}
	}
BuffTemplates.bardin_ranger_first_dibs_killer_in_the_shadows_buffs = {
		buffs = {
			{
				name = "bardin_ranger_first_dibs_killer_in_the_shadows_buffs",
				icon = "victor_bountyhunter_passive",
				refresh_durations = true,
				stat_buff = "critical_strike_chance",
				bonus = 0.1,
				max_stacks = 1,
				duration = 20
			}
		}
	}
BuffTemplates.bardin_ranger_first_dibs_pockets_full_of_bombs_buffs = {
	buffs = {
		{
			max_stacks = 1,
			name = "bardin_ranger_first_dibs_pockets_full_of_bombs_buffs",
			update_func = "update_pockets_full_of_bombs_buff",
			icon = "potion_pockets_full_of_bombs",
			refresh_durations = true,
			duration = 1
		}
	}
}
BuffTemplates.bardin_ranger_first_dibs_hold_my_beer_buffs = {
	buffs = {
		{
			name = "bardin_ranger_first_dibs_hold_my_beer_buffs",
			stat_buff = "increased_weapon_damage",
			refresh_durations = true,
			icon = "potion_hold_my_beer",
			max_stacks = 1,
			duration = 5,
			multiplier = 0.5
		}
	}
}
BuffTemplates.bardin_ranger_first_dibs_poison_proof_buffs = {
		buffs = {
			{
				name = "bardin_ranger_first_dibs_poison_proof_buffs",
				perk = "poison_proof",
				max_stacks = 1,
				icon = "potion_poison_proof",
				refresh_durations = true,
				duration = 30
			}
		}
	}
BuffTemplates.bardin_ranger_first_dibs_ale_buffs = {
		buffs = {
			{
				name = "bardin_ranger_first_dibs_ale_buffs",
				icon = "buff_icon_mutator_icon_drunk",
				stat_buff = "damage_taken",
				duration = 30,
				refresh_durations = true,
				multiplier = -0.1,
				max_stacks = 1
			}
		}
	}
BuffTemplates.bardin_ranger_first_dibs_ammo_buffs = {
		buffs = {
			{
				name = "bardin_ranger_first_dibs_ammo_buffs",
				event = "on_ammo_used",
				icon = "victor_bountyhunter_passive_infinite_ammo",
				event_buff = true,
				buff_func = "dummy_function",
				remove_on_proc = true,
				perk = "infinite_ammo",
				priority_buff = true,
				max_stacks = 1
			}
		}
	}
BuffTemplates.bardin_ranger_first_dibs_grenadet1_buffs = {
	buffs = {
		{
			name = "bardin_ranger_first_dibs_grenadet1_buffs",
			duration = 20,
			refresh_durations = true,
			icon = "trinket_increase_grenade_radius",
			stat_buff = "grenade_radius",
			multiplier = 0.15,
			max_stacks = 1
		}
	}
}
BuffTemplates.bardin_ranger_first_dibs_grenadet2_buffs = {
	buffs = {
		{
			name = "bardin_ranger_first_dibs_grenadet2_buffs",
			duration = 20,
			refresh_durations = true,
			icon = "trinket_increase_grenade_radius",
			stat_buff = "grenade_radius",
			multiplier = 0.25,
			max_stacks = 1
		}
	}
}
BuffTemplates.bardin_ranger_first_dibs_strength_buffs = {
		buffs = {
			{
				duration = 5,
				name = "bardin_ranger_first_dibs_strength_buffs",
				refresh_durations = true,
				perk = "potion_armor_penetration",
				max_stacks = 1,
				icon = "potion_buff_01"
			}
		}
	}
BuffTemplates.bardin_ranger_first_dibs_speed_buffs = {
		buffs = {
			{
				apply_buff_func = "apply_movement_buff",
				multiplier = 1.25,
				name = "bardin_ranger_first_dibs_speed_buffs",
				icon = "potion_buff_02",
				refresh_durations = true,
				remove_buff_func = "remove_movement_buff",
				max_stacks = 1,
				duration = 20,
				path_to_movement_setting_to_modify = {
					"move_speed"
				}
			},
			{
				multiplier = 0.25,
				name = "bardin_ranger_first_dibs_speed_buffs1",
				stat_buff = "attack_speed",
				refresh_durations = true,
				max_stacks = 1,
				duration = 20
			}
		}
	}
BuffTemplates.bardin_ranger_first_dibs_cooldown_buffs = {
	buffs = {
		{
			name = "bardin_ranger_first_dibs_cooldown_buffs",
			multiplier = 2.5,
			stat_buff = "cooldown_regen",
			duration = 10,
			max_stacks = 1,
			icon = "potion_buff_03",
			refresh_durations = true
		}
	}
}
BuffTemplates.bardin_ranger_first_dibs_grenade_buffs = {
	buffs = {
		{
			name = "bardin_ranger_first_dibs_grenade_buffs",
			max_stacks = 1,
			refresh_durations = true,
			icon = "trait_trinket_not_consume_grenade",
			duration = 20,
			proc_chance = 0.1,
			stat_buff = "not_consume_grenade"
		}
	}
}
BuffTemplates.bardin_ranger_first_dibs_potion_buffs = {
	buffs = {
		{
			name = "bardin_ranger_first_dibs_potion_buffs",
			max_stacks = 1,
			refresh_durations = true,
			icon = "charm_not_consume_potion",
			duration = 20,
			proc_chance = 0.1,
			stat_buff = "not_consume_potion"
		}
	}
}
BuffTemplates.bardin_ranger_first_dibs_heal_buffs = {
	buffs = {
		{
			name = "bardin_ranger_first_dibs_heal_buffs",
			max_stacks = 1,
			refresh_durations = true,
			update_func = "bardin_ranger_heal_smoke",
			icon = "bardin_ranger_activated_ability_heal",
			duration = 10,
			time_between_heals = 1,
			heal_amount = 1.5
		}
	}
}
BuffTemplates.bardin_ranger_first_dibs_heal_buffs1 = {
	buffs = {
		{
			name = "bardin_ranger_first_dibs_heal_buffs1",
			max_stacks = 1,
			refresh_durations = true,
			icon = "necklace_not_consume_healing",
			duration = 20,
			proc_chance = 0.1,
			stat_buff = "not_consume_medpack"
		}
	}
}
--[IRONBREAKER]:
--[RUNE ETCHED SHIELD]:
Talents.dwarf_ranger[6].buffs = {
	"bardin_ironbreaker_party_power_on_blocked_attacks_add",
	"bardin_ironbreaker_party_power_on_blocked_attacks_add_1"
}
ProcFunctions.buff_on_stagger_enemy = function (player, buff, params)
		local buff_template = buff.template
		local player_unit = player.player_unit
		local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
		local hit_unit = params[1]
		local breed = Unit.get_data(hit_unit, "breed")
		local buff_name = buff_template.buff_to_add
		local enemy_type_list = buff_template.enemy_type or nil
		local add_buff = false
		local function is_server()
			return Managers.player.is_server
		end

		if breed and enemy_type_list then
			for i = 1, #enemy_type_list, 1 do
				local enemy_type = enemy_type_list[i]

				if breed[enemy_type] then
					add_buff = true
				end
			end
		elseif breed then
			add_buff = true
		end

		if add_buff then
			local check_if_group_buff = buff_template.group_buff
			if check_if_group_buff then
				if not Managers.state.network.is_server then
					return
				end

				local buff_system = Managers.state.entity:system("buff_system")
				local template = buff.template
				local buff_to_add = template.buff_to_add
				local player_unit = player.player_unit
				local side = Managers.state.side.side_by_unit[player_unit]
				local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
				local num_units = #player_and_bot_units

				for i = 1, num_units, 1 do
					local unit = player_and_bot_units[i]

					if Unit.alive(unit) then
						buff_system:add_buff(unit, buff_to_add, unit, false)
					end
				end
			else
				local network_manager = Managers.state.network
				local network_transmit = network_manager.network_transmit
				local unit_object_id = network_manager:unit_game_object_id(player_unit)
				local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

				if is_server() then
					buff_extension:add_buff(buff_name, {
						attacker_unit = player_unit
					})
					network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
				else
					network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
				end
			end
		end
	end
BuffTemplates.bardin_ironbreaker_party_power_on_blocked_attacks_add_1 = {
		buffs = {
			{
				name = "bardin_ironbreaker_party_power_on_blocked_attacks_add_1",
				buff_to_add = "bardin_ironbreaker_party_power_on_blocked_attacks_buff",
				chunk_size = 1,
				event_buff = true,
				group_buff = true,
				buff_func = "buff_on_stagger_enemy",
				event = "on_stagger",
				max_stacks = 1,
				max_sub_buff_stacks = 5,
				enemy_type = {
					"elite"
				}
			}
		}
	}
BuffTemplates.bardin_ironbreaker_party_power_on_blocked_attacks_buff.buffs[1].duration = 15
--[VENGEANCE]:
Talents.dwarf_ranger[7].description_values[1].value = 4
BuffTemplates.bardin_ironbreaker_gromril_attack_speed.buffs[1].icon = "bardin_ironbreaker_stamina_regen_during_gromril"
BuffTemplates.bardin_ironbreaker_gromril_attack_speed.buffs[1].multiplier = 0.04
BuffTemplates.bardin_ironbreaker_stacking_buff_gromril.buffs[1].pulse_frequency = 4
BuffTemplates.bardin_ironbreaker_gromril_rising_anger.buffs[1].stat_buff = "attack_speed"
BuffTemplates.bardin_ironbreaker_gromril_rising_anger.buffs[1].multiplier = 0.02
--[DAWI DEFIANCE]:
--Talents.dwarf_ranger[11].buffer = "server"
Talents.dwarf_ranger[11].buffs = {
	--"bardin_ironbreaker_regen_stamina_on_gromril_removed"
	"bardin_ironbreaker_attack_speed_on_shield_break"
}
ProcFunctions.bardin_ironbreaker_regen_stamina_on_gromril_lost = function (player, buff, params)
		local player_unit = player.player_unit

		if Unit.alive(player_unit) then
			local status_extension = ScriptUnit.has_extension(player_unit, "status_system")
			local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
			status_extension:remove_all_fatigue()
			buff_extension:add_buff("bardin_ironbreaker_regen_stamina_on_block_broken_buff")
		end
	end
--[[ProcFunctions.bardin_ironbreaker_regen_stamina_on_block_broken = function (player, buff, params)
		local player_unit = player.player_unit

		if Unit.alive(player_unit) then
			local template = buff.template
			local procced = math.random() <= template.proc_chance

			if procced then
				local status_extension = ScriptUnit.has_extension(player_unit, "status_system")
				local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
				status_extension:remove_all_fatigue()
				buff_extension:add_buff("bardin_ironbreaker_regen_stamina_on_block_broken_buff")
			end
		end
	end]]
BuffTemplates.bardin_ironbreaker_regen_stamina_on_block_broken_buff = {
	buffs = {
			{
				max_stacks = 1,
				duration = 5,
				remove_buff_func = "remove_always_blocking",
				name = "bardin_ironbreaker_regen_stamina_on_block_broken_buff",
				apply_buff_func = "apply_always_blocking",
				icon = "bardin_ironbreaker_regen_stamina_on_block_broken",
				refresh_durations = true
			}
	}
}
--[[BuffTemplates.bardin_ironbreaker_regen_stamina_on_damage_taken = {
	buffs = {
		{
			max_stacks = 1,
			name = "bardin_ironbreaker_regen_stamina_on_damage_taken",
			buff_func = "bardin_ironbreaker_regen_stamina_on_block_broken",
			event_buff = true,
			event = "on_damage_taken",
			proc_chance = 0.5
		}
	}
}]]
BuffTemplates.bardin_ironbreaker_regen_stamina_on_gromril_removed = {
	buffs = {
		{
			max_stacks = 1,
			name = "bardin_ironbreaker_regen_stamina_on_gromril_removed",
			buff_func = "bardin_ironbreaker_regen_stamina_on_gromril_lost",
			event_buff = true,
			event = "on_gromril_armour_removed",
			proc_chance = 1
		}
	}
}
BuffTemplates.bardin_ironbreaker_attack_speed_on_shield_break = {
	buffs = {
		{
			max_stacks = 1,
			name = "bardin_ironbreaker_attack_speed_on_shield_break",
			event_buff = true,
			event = "on_shield_break",
			perk = "shield_break",
			buff_func = "bardin_ironbreaker_attack_speed_on_shield_break"
		}
	}
}
BuffTemplates.bardin_ironbreaker_attack_speed_on_shield_break_buff = {
	buffs = {
		{
			max_stacks = 1,
			name = "bardin_ironbreaker_attack_speed_on_shield_break_buff",
			stat_buff = "attack_speed",
			multiplier = 0.75,
			icon = "bardin_ironbreaker_regen_stamina_on_block_broken"
		}
	}
}
ProcFunctions.bardin_ironbreaker_attack_speed_on_shield_break = function (player, buff, params)
	local player_unit = player.player_unit
	if Unit.alive(player_unit) then

		buff_extension:add_buff("bardin_ironbreaker_attack_speed_on_shield_break_buff")
	end
end
--[SLAYER]:
--[A THOUSAND SPLIT SKULLS]:
Talents.dwarf_ranger[24].buffs = {
	"bardin_slayer_attack_speed_on_double_one_handed_weapons",
	"bardin_slayer_power_on_double_two_handed_weapons"
}
--[SLAYER STAMINA]:
Talents.dwarf_ranger[23].buffer = nil
Talents.dwarf_ranger[23].buffs = {
	"bardin_slayer_reduced_push_cost"
}
Talents.dwarf_ranger[23].icon = "bardin_slayer_passive_stacking_damage_buff_grants_defence"
BuffTemplates.bardin_slayer_reduced_push_cost = {
	buffs = {
		{
			perk = "slayer_stamina"
		}
	}
}
--[HACK AND SLASH]:
Talents.dwarf_ranger[22].buffer = "both"
ProcFunctions.on_critical_strike_debuff_enemy_defence = function (player, buff, params)
		local player_unit = player.player_unit
		local hit_unit = params[1]

		if Unit.alive(player_unit) and Unit.alive(hit_unit) and Managers.player.is_server then
			local buff_extension = ScriptUnit.extension(hit_unit, "buff_system")

			if buff_extension then
				buff_extension:add_buff("on_critical_strike_debuff_enemy_defence")
			end
		end
	end
BuffTemplates.on_critical_strike_debuff_enemy_defence = {
		buffs = {
			{
				stat_buff = "damage_taken",
				multiplier = 0.1,
				duration = 10,
				max_stacks = 1
			}
		}
	}
BuffTemplates.bardin_slayer_crit_chance.buffs[1].bonus = 0.05
BuffTemplates.bardin_slayer_crit_chance.buffs[1].stat_buff = "critical_strike_chance"
BuffTemplates.bardin_slayer_crit_chance.buffs[1].event = "on_critical_hit"
BuffTemplates.bardin_slayer_crit_chance.buffs[1].buff_to_add = "on_critical_strike_debuff_enemy_defence"
BuffTemplates.bardin_slayer_crit_chance.buffs[1].event_buff = true
BuffTemplates.bardin_slayer_crit_chance.buffs[1].buff_func = "on_critical_strike_debuff_enemy_defence"
--[BARGE]:
ExplosionTemplates.bardin_slayer_push_on_dodge.explosion.damage_profile = "slayer_leap_landing_impact"
ExplosionTemplates.bardin_slayer_push_on_dodge.explosion.radius = 2.25
--TROPHY HUNTER
ProcFunctions.add_bardin_slayer_passive_buff = function (player, buff, params)
		if not Managers.state.network.is_server then
			return
		end

		local player_unit = player.player_unit
		local buff_system = Managers.state.entity:system("buff_system")

		if Unit.alive(player_unit) then
			local buff_name = "bardin_slayer_passive_stacking_damage_buff"
			local talent_extension = ScriptUnit.extension(player_unit, "talent_system")
			local buff_extension = ScriptUnit.extension(player_unit, "buff_system")

			if talent_extension:has_talent("bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) then
				buff_name = "bardin_slayer_passive_increased_max_stacks"
			end
			if talent_extension:has_talent("bardin_slayer_passive_movement_speed", "dwarf_ranger", true) then
				buff_name = "bardin_slayer_passive_stacking_damage_buff_increased_duration_returned"
			end

			buff_system:add_buff(player_unit, buff_name, player_unit, false)

			if talent_extension:has_talent("bardin_slayer_passive_movement_speed", "dwarf_ranger", true) then
				buff_system:add_buff(player_unit, "bardin_slayer_passive_movement_speed", player_unit, false)
			end
			if talent_extension:has_talent("bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) then
				local num_stacks = buff_extension:num_buff_type(buff_name)
				local max_stacks = 4

				if num_stacks == max_stacks then
					buff_system:add_buff(player_unit, "bardin_slayer_passive_stacking_crit_buff", player_unit, false)
				end
			end
			if talent_extension:has_talent("bardin_slayer_passive_cooldown_reduction_on_max_stacks", "dwarf_ranger", true) then
				local num_stacks = buff_extension:num_buff_type(buff_name)
				local max_stacks = buff.template.max_stacks

				if num_stacks == max_stacks then
					buff_system:add_buff(player_unit, "bardin_slayer_passive_cooldown_reduction_on_max_stacks", player_unit, false)
				end
			end
		end
	end
BuffTemplates.bardin_slayer_passive_stacking_crit_buff = {
		buffs = {
			{
				name = "bardin_slayer_passive_stacking_crit_buff",
				duration = 2,
				bonus = 0.025,
				max_stacks = 4,
				icon = "bardin_slayer_passive_stacking_damage_buff_increased_duration",
				stat_buff = "critical_strike_chance",
				refresh_durations = true
			}
		}
	}
BuffTemplates.bardin_slayer_passive_stacking_damage_buff_vs_great_foes2 = {
		buffs = {
			{
				name = "bardin_slayer_passive_stacking_damage_buff_vs_great_foes2",
				duration = 2,
				multiplier = 0.1,
				max_stacks = 3,
				stat_buff = "power_level_super_armour",
				refresh_durations = true
			}
		}
	}
BuffTemplates.bardin_slayer_passive_stacking_damage_buff_increased_duration_returned = {
		buffs = {
			{
				name = "bardin_slayer_passive_stacking_damage_buff_increased_duration_returned",
				duration = 5,
				multiplier = 0.1,
				max_stacks = 3,
				icon = "bardin_slayer_passive",
				stat_buff = "increased_weapon_damage_melee",
				refresh_durations = true
			}
		}
	}
BuffTemplates.bardin_slayer_passive_movement_speed.buffs[1].duration = 5
--[DAWI DROP]
CareerAbilityDRSlayer._do_common_stuff = function (self)
	local owner_unit = self._owner_unit
	local is_server = self._is_server
	local local_player = self._local_player
	local bot_player = self._bot_player
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit
	local career_extension = self._career_extension
	local talent_extension = self._talent_extension
	local buffs = {
		"bardin_slayer_activated_ability"
	}

	if talent_extension:has_talent("bardin_slayer_activated_ability_movement") then
		buffs[#buffs + 1] = "bardin_slayer_activated_ability_movement"
	end
	if talent_extension:has_talent("bardin_slayer_activated_ability_leap_damage") then
		if local_player or (is_server and bot_player) then
			local buff_extension = self._buff_extension

			if buff_extension then
				local buff = buff_extension:get_buff_type("bardin_slayer_ability_leap_double")

				if buff then
					buff.aborted = true

					buff_extension:remove_buff(buff.id)
					--career_extension:reduce_activated_ability_cooldown_percent(-1)
					career_extension:start_activated_ability_cooldown()
					career_extension:set_abilities_always_usable(false, "bardin_slayer_activated_ability_leap_damage")
				else
					buff_extension:add_buff("bardin_slayer_ability_leap_double")
					career_extension:set_abilities_always_usable(true, "bardin_slayer_activated_ability_leap_damage")
				end
			end
		end
	else
		career_extension:start_activated_ability_cooldown()
	end
	local unit_object_id = network_manager:unit_game_object_id(owner_unit)

	if is_server then
		local buff_extension = self._buff_extension

		for i = 1, #buffs, 1 do
			local buff_name = buffs[i]
			local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

			buff_extension:add_buff(buff_name, {
				attacker_unit = owner_unit
			})
			network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
		end
	else
		for i = 1, #buffs, 1 do
			local buff_name = buffs[i]
			local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

			network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
		end
	end

	if (is_server and bot_player) or local_player then
		local first_person_extension = self._first_person_extension

		first_person_extension:play_hud_sound_event("Play_career_ability_bardin_slayer_enter")
		first_person_extension:play_remote_unit_sound_event("Play_career_ability_bardin_slayer_enter", owner_unit, 0)
		first_person_extension:play_hud_sound_event("Play_career_ability_bardin_slayer_loop")

		if local_player then
			MOOD_BLACKBOARD.skill_slayer = true

			career_extension:set_state("bardin_activate_slayer")
		end
	end

	career_extension:start_activated_ability_cooldown()
	self:_play_vo()
end
BuffFunctionTemplates.functions.bardin_slayer_double_leap_talent_start_ability_cooldown = function (unit, buff, params)
	local function is_local(unit)
		local player = Managers.player:owner(unit)

		return player and not player.remote
	end
		if ALIVE[unit] and not buff._already_removed and is_local(unit) then
			local career_extension = ScriptUnit.extension(unit, "career_system")

			career_extension:set_abilities_always_usable(false, "bardin_slayer_activated_ability_leap_damage")
			career_extension:stop_ability("cooldown_triggered")
			career_extension:start_activated_ability_cooldown()
		end

		buff._already_removed = true
	end
Talents.dwarf_ranger[32].buffer = "both"
BuffTemplates.bardin_slayer_ability_leap_double = {
		buffs = {
			{
				name = "bardin_slayer_ability_leap_double",
				duration = 3,
				buff_to_add = "bardin_slayer_ability_leap_double_remove",
				icon = "bardin_slayer_activated_ability_leap_range",
				remove_buff_func = "sienna_adept_double_trail_talent_start_ability_cooldown_add",
				max_stacks = 1,
				perk = "free_ability"
			}
		}
	}
BuffTemplates.bardin_slayer_ability_leap_double_remove = {
		buffs = {
			{
				name = "bardin_slayer_ability_leap_double_remove",
				max_stacks = 1,
				duration = 0,
				remove_buff_func = "bardin_slayer_double_leap_talent_start_ability_cooldown"
			}
		}
	}
--[ENGINEER]:
--gromril plated fire rate
local armor_pierce_initial_rounds_per_second = 3
local armor_pierce_max_rps = 4
local armor_pierce_rps_gain_per_shot = 0.167
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.armor_pierce_fire.rps_gain_per_shot = armor_pierce_rps_gain_per_shot
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.armor_pierce_fire.max_rps = armor_pierce_max_rps
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.armor_pierce_fire.initial_rounds_per_second = armor_pierce_initial_rounds_per_second
--mute some steam cranking sounds
Weapons.bardin_engineer_career_skill_weapon.actions.weapon_reload.default.charge_sound_name = nil
Weapons.bardin_engineer_career_skill_weapon_special.actions.weapon_reload.default.charge_sound_name = nil
--[increase base HP to 125]:
CareerSettings.dr_engineer.attributes.max_hp = 125
--[allow cranking at max pressure stacks]:
Weapons.bardin_engineer_career_skill_weapon.actions.weapon_reload.default.condition_func = function (action_user, input_extension)
	local talent_extension = ScriptUnit.has_extension(action_user, "talent_system")
	local career_extension = ScriptUnit.has_extension(action_user, "career_system")
	local buff_extension = ScriptUnit.has_extension(action_user, "buff_system")
	local can_reload = not buff_extension:has_buff_type("bardin_engineer_pump_max_exhaustion_buff")
	
	return can_reload
end
Weapons.bardin_engineer_career_skill_weapon.actions.weapon_reload.default.chain_condition_func = function (action_user, input_extension)
	local talent_extension = ScriptUnit.has_extension(action_user, "talent_system")
	local career_extension = ScriptUnit.has_extension(action_user, "career_system")
	local buff_extension = ScriptUnit.has_extension(action_user, "buff_system")
	local can_reload = not buff_extension:has_buff_type("bardin_engineer_pump_max_exhaustion_buff")
	
	return can_reload
end
Weapons.bardin_engineer_career_skill_weapon_special.actions.weapon_reload.default.condition_func = function (action_user, input_extension)
	local talent_extension = ScriptUnit.has_extension(action_user, "talent_system")
	local career_extension = ScriptUnit.has_extension(action_user, "career_system")
	local buff_extension = ScriptUnit.has_extension(action_user, "buff_system")
	local can_reload = not buff_extension:has_buff_type("bardin_engineer_pump_max_exhaustion_buff")
	
	return can_reload
end
Weapons.bardin_engineer_career_skill_weapon_special.actions.weapon_reload.default.chain_condition_func = function (action_user, input_extension)
	local talent_extension = ScriptUnit.has_extension(action_user, "talent_system")
	local career_extension = ScriptUnit.has_extension(action_user, "career_system")
	local buff_extension = ScriptUnit.has_extension(action_user, "buff_system")
	local can_reload = not buff_extension:has_buff_type("bardin_engineer_pump_max_exhaustion_buff")
	
	return can_reload
end
ActionCareerDREngineerCharge.client_owner_post_update = function (self, dt, t, world, can_damage)
	local buff_extension = self.buff_extension
	local current_action = self.current_action
	local interval = current_action.ability_charge_interval
	local charge_timer = self.ability_charge_timer + dt

	if interval <= charge_timer then
		local recharge_instances = math.floor(charge_timer / interval)
		charge_timer = charge_timer - recharge_instances * interval
		local wwise_world = self.wwise_world
		local buff_to_add = self._buff_to_add
		local num_stacks = buff_extension:num_buff_type(buff_to_add)
		local buff_type = buff_extension:get_buff_type(buff_to_add)

		if buff_type then
			if not self.last_pump_time then
				self.last_pump_time = t
			end

			local buff_template = buff_type.template

			if t - self.last_pump_time > 10 and buff_template.max_stacks <= num_stacks then
				Managers.state.achievement:trigger_event("clutch_pump", self.owner_unit)
			end

			self.last_pump_time = t
		end

		WwiseWorld.set_global_parameter(wwise_world, "engineer_charge", num_stacks + recharge_instances)

		for i = 1, recharge_instances, 1 do
			buff_extension:add_buff(buff_to_add)
		end
	end

	self.ability_charge_timer = charge_timer
	local current_cooldown = self.career_extension:current_ability_cooldown()
end
ProcFunctions.bardin_engineer_remove_pump_stacks_on_fire_long = function (player, buff, params)
		local action = params[1]
		local kind = action and action.kind

		if kind and kind == "career_dr_four" then
			ProcFunctions.bardin_engineer_remove_pump_stacks(player, buff, params)
		end
	end
BuffTemplates.bardin_engineer_remove_pump_stacks_fire_long = {
		buffs = {
			{
				name = "bardin_engineer_remove_pump_stacks_fire_long",
				event = "on_start_action",
				event_buff = true,
				buff_func = "bardin_engineer_remove_pump_stacks_on_fire_long",
				remove_buff_stack_data = {
					{
						buff_to_remove = "bardin_engineer_pump_buff_long",
						num_stacks = math.huge
					}
				}
			}
		}
	}
BuffTemplates.bardin_engineer_remove_pump_stacks_fire.buffs[1].event = "on_kill"
BuffTemplates.bardin_engineer_remove_pump_stacks_fire.buffs[1].remove_buff_stack_data[1].num_stacks = 1
--BuffTemplates.bardin_engineer_remove_pump_stacks_fire.buffs[1].remove_buff_stack_data[2].num_stacks = 1
BuffTemplates.bardin_engineer_remove_pump_stacks_fire.buffs[1].remove_buff_stack_data[2] = nil
ProcFunctions.bardin_engineer_remove_pump_stacks_on_fire = function(player, buff, params)
    local player_unit = player.player_unit
	local killing_blow_data = params[1]
	local attack_type = killing_blow_data[DamageDataIndex.ATTACK_TYPE]

    local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
    local wielded_slot = inventory_extension:get_wielded_slot_name()
    if ALIVE[player_unit] and wielded_slot == "slot_career_skill_weapon" and (attack_type == "instant_projectile") then
		ProcFunctions.bardin_engineer_remove_pump_stacks(player, buff, params)
  end
end
--[allow ability regen from melee and ranged attacks]:
BuffTemplates.bardin_engineer_ability_cooldown_on_hit = {
	buffs = {
		{
			name = "bardin_engineer_ability_cooldown_on_hit",
			event = "on_hit",
			event_buff = true,
			buff_func = "reduce_activated_ability_cooldown",
			bonus = 0.25
		}
	}
}
PassiveAbilitySettings.dr_4.buffs = {
	"bardin_engineer_passive_no_ability_regen",
	"bardin_engineer_passive_ranged_power_aura",
	"bardin_engineer_passive_max_ammo",
	"bardin_engineer_remove_pump_stacks_fire",
	"bardin_engineer_ability_cooldown_on_hit",
	"bardin_ranger_ability_cooldown_on_damage_taken",
	"bardin_engineer_remove_pump_stacks_fire_long"
}
--[allow engineer to use crossbow in all modes]:
ItemMasterList.dr_crossbow.can_wield = {
	"dr_ironbreaker",
	"dr_ranger",
	"dr_engineer"
}
ItemMasterList.dr_crossbow_magic_01.can_wield = {
	"dr_ironbreaker",
	"dr_ranger",
	"dr_engineer"
}
local function add_career_to_weapon_group(weapons, career)
	for _, weapon in ipairs(weapons) do
		local weapon_group_can_wield = DeusWeaponGroups[weapon].can_wield

		if not table.contains(weapon_group_can_wield, career) then
			table.insert(weapon_group_can_wield, career)
		end
	end
end
if DLCSettings.cog then
	add_career_to_weapon_group({
		"dr_1h_axe",
		"dr_2h_hammer",
		"dr_1h_hammer",
		"dr_2h_axe",
		"dr_2h_pick",
		"dr_shield_axe",
		"dr_shield_hammer",
		"dr_dual_wield_hammers",
		"dr_rakegun",
		"dr_handgun",
		"dr_drakegun",
		"dr_drake_pistol",
		"dr_crossbow"
	}, "dr_engineer")
end
--[regular crank gun uninterruptible]:
Weapons.bardin_engineer_career_skill_weapon.actions.action_one.default.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon.actions.action_one.spin.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon.actions.action_one.fire.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon.actions.action_one.base_fire.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon.actions.action_two.default.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon.actions.action_two.charged.uninterruptible = true
--[Gromril rounds uninterruptible]: 
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.default.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.spin.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.fire.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.armor_pierce_fire.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_two.default.uninterruptible = true
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_two.charged.uninterruptible = true
--[Bombardier bomb radius + duration 25% increase]:
--ExplosionTemplates.frag_fire_grenade.explosion.radius = 6.25
--ExplosionTemplates.frag_fire_grenade.aoe.radius = 7.5
--ExplosionTemplates.frag_fire_grenade.aoe.duration = 6.25
--[Increased Super-Armor damage with Gromril-Plated Shot]:
DamageProfileTemplates.engineer_ability_shot_armor_pierce.armor_modifier_near.attack = {
	1,
	1,
	1,
	1,
	0.5,
	0.4
}
DamageProfileTemplates.engineer_ability_shot_armor_pierce.armor_modifier_far.attack = {
	1,
	1,
	1,
	1,
	0.5,
	0.4
}
--[Gromril Shots spread + longer range]:
Weapons.bardin_engineer_career_skill_weapon_special.default_spread_template = "repeating_handgun"
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.armor_pierce_fire.range = 100
--[Bombardier gives bombs at start]:
SimpleInventoryExtension.extensions_ready = function(self, world, unit)
    local first_person_extension = ScriptUnit.extension(unit, "first_person_system")
    self.first_person_extension = first_person_extension
    self._first_person_unit = first_person_extension:get_first_person_unit()
    self.buff_extension = ScriptUnit.extension(unit, "buff_system")
    local career_extension = ScriptUnit.extension(unit, "career_system")
    self.career_extension = career_extension
    local talent_extension = ScriptUnit.has_extension(unit, "talent_system")
    self.talent_extension = talent_extension
    local equipment = self._equipment
    local profile = self._profile
    local unit_1p = self._first_person_unit
    local unit_3p = self._unit

    self:add_equipment_by_category("weapon_slots")
    self:add_equipment_by_category("enemy_weapon_slots")

    local skill_index = (talent_extension and talent_extension:get_talent_career_skill_index()) or 1
    local weapon_index = talent_extension and talent_extension:get_talent_career_weapon_index()
    self.initial_inventory.slot_career_skill_weapon = career_extension:career_skill_weapon_name(skill_index,
                                                          weapon_index)

    self:add_equipment_by_category("career_skill_weapon_slots")

    local additional_inventory = self.initial_inventory.additional_items

    local has_bombardier = self.buff_extension:has_buff_type("bardin_engineer_upgraded_grenades")
	additional_inventory = additional_inventory or {}
	if has_bombardier and additional_inventory then
		additional_inventory = {
		{
			slot_name = "slot_grenade",
            item_name = "grenade_frag_02"
		},
		{
			slot_name = "slot_grenade",
            item_name = "grenade_fire_02"
		}
		}
   else
		additional_inventory = {}
   end
   if additional_inventory then
        for i = 1, #additional_inventory, 1 do
            local additional_item = additional_inventory[i]
            local slot_name = additional_item.slot_name
            local item_data = ItemMasterList[additional_item.item_name]
            local slot_data = self:get_slot_data(slot_name)

            if slot_data then
                self:store_additional_item(slot_name, item_data)
            else
                self:add_equipment(slot_name, item_data)
            end
        end
    end

    Unit.set_data(self._first_person_unit, "equipment", self._equipment)

    if profile.default_wielded_slot then
        local default_wielded_slot = profile.default_wielded_slot
        local slot_data = self._equipment.slots[default_wielded_slot]

        if not slot_data then
            table.dump(self._equipment.slots, "self._equipment.slots", 1)
            Application.error("Tried to wield default slot %s for %s that contained no weapon.", default_wielded_slot,
                career_extension:career_name())
        end

        self:_wield_slot(equipment, slot_data, unit_1p, unit_3p)

        local item_data = slot_data.item_data
        local item_template = BackendUtils.get_item_template(item_data)

        self:_spawn_attached_units(item_template.first_person_attached_units)

        local backend_id = item_data.backend_id
        local buffs = self:_get_property_and_trait_buffs(backend_id)

        self:apply_buffs(buffs, "wield", item_data.name, default_wielded_slot)
    end

    self._equipment.wielded_slot = profile.default_wielded_slot
end
--[FREE SHOT BUG FIX]:
ActionCareerDREngineer._fake_activate_ability = function (self, t)
	--local FREE_ABILITY_AMMO_TIME = 4
	local buff_extension = self.buff_extension

	if buff_extension then
		self._ammo_expended = self._ammo_expended + self._shot_cost * self._num_projectiles_per_shot

		if buff_extension:has_buff_perk("free_ability") then
			buff_extension:trigger_procs("on_ability_activated", self.owner_unit, 1)
			buff_extension:trigger_procs("on_ability_cooldown_started")

			self._free_ammo_t = t --+ FREE_ABILITY_AMMO_TIME
		elseif self._ammo_expended > self.career_extension:get_max_ability_cooldown() / 2 then
			buff_extension:trigger_procs("on_ability_activated", self.owner_unit, 1)
			buff_extension:trigger_procs("on_ability_cooldown_started")

			self._ammo_expended = 0
		end
	end
end
--[Updated Linked Compression Chamber movement + dodge + range after spinning or firing gun]:
ActionCareerDREngineerSpin.client_owner_start_action = function (self, new_action, t)
	ActionCareerDREngineerSpin.super.client_owner_start_action(self, new_action, t)
	self:start_audio_loop()

	self._initial_windup = new_action.initial_windup
	self._windup_max = new_action.windup_max
	self._windup_speed = new_action.windup_speed
	self._current_windup = self.weapon_extension:get_custom_data("windup")
	self._override_visual_spinup = new_action.override_visual_spinup
	self._visual_spinup_min = new_action.visual_spinup_min
	self._visual_spinup_max = new_action.visual_spinup_max
	self._visual_spinup_time = new_action.visual_spinup_time
	self._action_start_t = t
	self._last_update_t = t

	if self.talent_extension:has_talent("bardin_engineer_reduced_ability_fire_slowdown") then
		self._current_windup = 1
		DamageProfileTemplates.engineer_ability_shot.default_target.power_distribution_far = {
			attack = 0.0625,
			impact = 0.05
		}
		Weapons.bardin_engineer_career_skill_weapon.actions.action_one.base_fire.range = 35
		Weapons.bardin_engineer_career_skill_weapon.dodge_count = 3
		Weapons.bardin_engineer_career_skill_weapon.actions.action_one.spin.buff_data = {
			{
				start_time = 0,
				external_multiplier = 0.6,
				buff_name = "planted_fast_decrease_movement",
				end_time = math.huge
			}
		}
		Weapons.bardin_engineer_career_skill_weapon.actions.action_one.base_fire.buff_data = {
			{
				start_time = 0,
				external_multiplier = 0.6,
				buff_name = "planted_fast_decrease_movement",
				end_time = math.huge
			}
		}
		Weapons.bardin_engineer_career_skill_weapon.actions.action_two.default.buff_data = {
			{
				start_time = 0,
				external_multiplier = 0.6,
				buff_name = "planted_fast_decrease_movement",
				end_time = math.huge
			}
		}
		Weapons.bardin_engineer_career_skill_weapon.actions.action_two.charged.buff_data = {
			{
				start_time = 0,
				external_multiplier = 0.6,
				buff_name = "planted_fast_decrease_movement",
				end_time = math.huge
			}
		}
	else
		DamageProfileTemplates.engineer_ability_shot.default_target.power_distribution_far = {
			attack = 0.125,
			impact = 0.05
		}
		Weapons.bardin_engineer_career_skill_weapon.actions.action_one.base_fire.range = 35
		Weapons.bardin_engineer_career_skill_weapon.dodge_count = 1
		Weapons.bardin_engineer_career_skill_weapon.actions.action_one.spin.buff_data = {
			{
				start_time = 0,
				external_multiplier = 0.2,
				buff_name = "planted_fast_decrease_movement",
				end_time = math.huge
			}
		}
		Weapons.bardin_engineer_career_skill_weapon.actions.action_one.base_fire.buff_data = {
			{
				start_time = 0,
				external_multiplier = 0.2,
				buff_name = "planted_fast_decrease_movement",
				end_time = math.huge
			}
		}
		Weapons.bardin_engineer_career_skill_weapon.actions.action_two.default.buff_data = {
			{
				start_time = 0,
				external_multiplier = 0.2,
				buff_name = "planted_fast_decrease_movement",
				end_time = math.huge
			}
		}
		Weapons.bardin_engineer_career_skill_weapon.actions.action_two.charged.buff_data = {
			{
				start_time = 0,
				external_multiplier = 0.2,
				buff_name = "planted_fast_decrease_movement",
				end_time = math.huge
			}
		}
	end
end
--[Engi gets ult from melee + ranged but NOT crank gun]:
ProcFunctions.reduce_activated_ability_cooldown = function (player, buff, params)
	local player_unit = player.player_unit
	local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
	local wielded_slot = inventory_extension:get_wielded_slot_name()
	if Unit.alive(player_unit) then
		local attack_type = params[2]
		local target_number = params[4]
		local career_extension = ScriptUnit.extension(player_unit, "career_system")

		if not attack_type or attack_type == "heavy_attack" or attack_type == "light_attack" then
			career_extension:reduce_activated_ability_cooldown(buff.bonus)
		elseif target_number and target_number == 1 then
			if wielded_slot == "slot_career_skill_weapon" then
				return
			end
				career_extension:reduce_activated_ability_cooldown(buff.bonus)
		end
	end
end
--[Piston Power No Overheat Slowdown]:
ProcFunctions.bardin_engineer_piston_power_add = function (player, buff, params)
		local player_unit = player.player_unit

		if ALIVE[player_unit] then
			local attack_type = params[2]

			if attack_type ~= "heavy_attack" then
				return
			end

			local template = buff.template
			local buff_to_add = template.buff_to_add
			local buff_to_remove = template.buff_to_remove
			local buff_to_check = template.buff_to_check
			local buff_extension = ScriptUnit.extension(player_unit, "buff_system")

			if buff_extension:has_buff_type(buff_to_remove) then
				local overcharge_extension = ScriptUnit.extension(player_unit, "overcharge_system")
				local has_buff_to_remove = buff_extension:get_non_stacking_buff(buff_to_remove)

				if has_buff_to_remove then
					buff_extension:remove_buff(has_buff_to_remove.id)
				end

				local buff_system = Managers.state.entity:system("buff_system")

				buff_system:add_buff(player_unit, buff_to_add, player_unit, false)
				buff_extension:add_buff(buff_to_check)
				overcharge_extension:reset()
			end
		end
	end
BuffTemplates.bardin_engineer_piston_powered.buffs[1].perk = "overcharge_no_slow"
-------------------------------------------------------
--					//////[SIENNA]\\\\\\
-------------------------------------------------------
--[BATTLE WIZARD:]
--[FAMISHED FLAMES]:
BuffTemplates.sienna_adept_increased_burn_damage.buffs[1].multiplier = 0.75
BuffTemplates.sienna_adept_reduced_non_burn_damage.buffs[1].multiplier = -0.15
--[PYROMANCER:]
--[PASSIVES]:
PassiveAbilitySettings.bw_1.buffs = {
			"sienna_scholar_overcharge_no_slow",
			"sienna_scholar_passive",
			"sienna_scholar_passive_ranged_damage",
			"sienna_scholar_ability_cooldown_on_hit",
			"sienna_scholar_ability_cooldown_on_damage_taken"
		}
--[UNCHAINED:]
--[PASSIVES]:

--Not insta explode when launched/disabled
PlayerCharacterStateOverchargeExploding.on_exit = function (self, unit, input, dt, context, t, next_state)
	if not Managers.state.network:game() or not next_state then
		return
	end

	CharacterStateHelper.play_animation_event(unit, "cooldown_end")
	CharacterStateHelper.play_animation_event_first_person(self.first_person_extension, "cooldown_end")

	local career_extension = ScriptUnit.extension(unit, "career_system")
	local career_name = career_extension:career_name()

	if self.falling and next_state ~= "falling" then
		ScriptUnit.extension(unit, "whereabouts_system"):set_no_landing()
	end
end
--[SLAVE TO AQSHY]:
BuffFunctionTemplates.functions.sienna_unchained_health_to_cooldown_update = function (unit, buff, params)
	local talent_extension = ScriptUnit.has_extension(unit, "talent_system")
	if talent_extension:has_talent("sienna_unchained_reduced_overcharge") then
		return
	end
	if talent_extension:has_talent("sienna_unchained_health_to_ult") then
		local t = params.t
		local frequency = 0.25

		if not buff.timer or buff.timer <= t then
			buff.timer = t + frequency
			local career_extension = ScriptUnit.has_extension(unit, "career_system")

			if career_extension and career_extension:current_ability_cooldown_percentage() > 0 then
				career_extension:reduce_activated_ability_cooldown_percent(0.1)

				local health_extension = ScriptUnit.has_extension(unit, "health_system")
				local damage = health_extension:get_max_health() / 24

				DamageUtils.add_damage_network(unit, unit, damage, "torso", "life_tap", nil, Vector3(0, 0, 0), "life_tap", nil, unit)
			end
		end
	else
		local t = params.t
		local frequency = 0.25

		if not buff.timer or buff.timer <= t then
			buff.timer = t + frequency
			local career_extension = ScriptUnit.has_extension(unit, "career_system")

			if career_extension and career_extension:current_ability_cooldown_percentage() > 0 then
				career_extension:reduce_activated_ability_cooldown_percent(0.1)

				local health_extension = ScriptUnit.has_extension(unit, "health_system")
				local damage = health_extension:get_max_health() / 16

				DamageUtils.add_damage_network(unit, unit, damage, "torso", "life_tap", nil, Vector3(0, 0, 0), "life_tap", nil, unit)
			end
		end
	end
end
PassiveAbilitySettings.bw_3.buffs = {
			"sienna_unchained_health_to_ult",
			"sienna_unchained_passive",
			"sienna_unchained_passive_increased_melee_power_on_overcharge",
			"sienna_unchained_ability_cooldown_on_hit",
			"sienna_unchained_ability_cooldown_on_damage_taken"
		}
--[CHAIN REACTION]:
ExplosionTemplates.sienna_unchained_burning_enemies_explosion.explosion.damage_profile = "medium_burning_tank"
ExplosionTemplates.sienna_unchained_burning_enemies_explosion.explosion.effect_name = "fx/wpnfx_flaming_flail_hit_01"
ExplosionTemplates.sienna_unchained_burning_enemies_explosion.explosion.radius_max = 1.5
BuffTemplates.sienna_unchained_exploding_burning_enemies.buffs[1].proc_chance = 0.5
--[OUTBURST]:
ProcFunctions.sienna_burn_push_on_charged_attacks_remove = function (player, buff, params, world)
		local player_unit = player.player_unit

		if player and player.remote then
			return
		end

		if Unit.alive(player_unit) then
			local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
			local position = POSITION_LOOKUP[player_unit]

			buff_extension:remove_buff(buff.id)
			buff_extension:add_buff("sienna_unchained_push_arc_buff_sfx")

			World.create_particles(world, "fx/wpnfx_fire_grenade_impact", position, Quaternion.identity())
		end
	end
BuffTemplates.sienna_unchained_burn_push.buffs[1].stat_buff = "block_angle"
BuffTemplates.sienna_unchained_burn_push.buffs[1].multiplier = 0.3
BuffTemplates.sienna_unchained_push_arc_buff.buffs[1].stat_buff = "push_range"
BuffTemplates.sienna_unchained_push_arc_buff.buffs[1].multiplier = nil
BuffTemplates.sienna_unchained_push_arc_buff.buffs[1].bonus = 10
BuffTemplates.sienna_unchained_push_arc_buff_sfx = {
	activation_sound = "weapon_staff_fire_cone",
	buffs = {
		{
			duration = 0.2,
			max_stacks = 1,
			icon = "kerillian_thornsister_big_push",
			name = "sienna_unchained_push_arc_buff_sfx"
		}
	}
}
--[NUMB TO PAIN]:
Talents.bright_wizard[46].buffer = "both"
Talents.bright_wizard[46].buffs = {
	"sienna_unchained_reduced_passive_overcharge_armor"
}
BuffFunctionTemplates.functions.sienna_unchained_apply_overcharge_armor = function (unit, buff, params)
		local player_unit = unit

		if ALIVE[player_unit] then
			local template = buff.template
			local buff_to_apply = template.buff_to_apply
			local buff_extension = ScriptUnit.extension(player_unit, "buff_system")

			buff_extension:add_buff(buff_to_apply)
		end
	end
ProcFunctions.sienna_unchained_nullify_blood_magic_overcharge = function (player, buff, params)
	local player_unit = player.player_unit
	local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
	local damage_type = params[3]

		if ALIVE[player_unit] and buff_extension:has_buff_type("sienna_unchained_reduced_passive_overcharge_armor_ready") and damage_type ~= "overcharge" then
			local template = buff.template
			local buff_to_remove = template.buff_to_remove
			local buff_name = "sienna_unchained_reduced_passive_overcharge_armor_cooldown"
			local network_manager = Managers.state.network
			local network_transmit = network_manager.network_transmit
			local unit_object_id = network_manager:unit_game_object_id(player_unit)
			local buff_template_name_id = NetworkLookup.buff_templates[buff_name]
			local function is_server()
				return Managers.player.is_server
			end

			if is_server() then
						buff_extension:add_buff(buff_name, {
							attacker_unit = player_unit
						})
						network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
						if buff_extension:has_buff_type(buff_to_remove) then
							local has_buff_to_remove = buff_extension:get_non_stacking_buff(buff_to_remove)

							if has_buff_to_remove then
								buff_extension:remove_buff(has_buff_to_remove.id)
							end
						end
			else
						network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
						if buff_extension:has_buff_type(buff_to_remove) then
							local has_buff_to_remove = buff_extension:get_non_stacking_buff(buff_to_remove)

							if has_buff_to_remove then
								buff_extension:remove_buff(has_buff_to_remove.id)
							end
						end
			end
		end
	end
BuffTemplates.sienna_unchained_reduced_passive_overcharge_armor = {
	buffs = {
		{
			name = "sienna_unchained_reduced_passive_overcharge_armor",
			event = "on_damage_taken",
			max_stacks = 1,
			event_buff = true,
			buff_func = "sienna_unchained_nullify_blood_magic_overcharge",
			apply_buff_func = "sienna_unchained_apply_overcharge_armor",
			buff_to_apply = "sienna_unchained_reduced_passive_overcharge_armor_ready",
			buff_to_remove = "sienna_unchained_reduced_passive_overcharge_armor_ready",
			buff_to_check = "sienna_unchained_reduced_passive_overcharge_armor_cooldown"
		}
	}
}
BuffTemplates.sienna_unchained_reduced_passive_overcharge_armor_ready = {
	buffs = {
		{
			name = "sienna_unchained_reduced_passive_overcharge_armor_ready",
			max_stacks = 1,
			stat_buff = "reduced_overcharge_from_passive",
			multiplier = -1,
			icon = "sienna_unchained_reduced_damage_taken_after_venting"
		}
	}
}
BuffTemplates.sienna_unchained_reduced_passive_overcharge_armor_cooldown = {
	buffs = {
		{
			name = "sienna_unchained_reduced_passive_overcharge_armor_cooldown",
			duration = 10,
			buff_after_delay = true,
			is_cooldown = true,
			max_stacks = 1,
			refresh_durations = true,
			icon = "sienna_unchained_reduced_damage_taken_after_venting",
			delayed_buff_name = "sienna_unchained_reduced_passive_overcharge_armor_ready"
		}
	}
}
--[NATURAL TALENT]:
BuffTemplates.sienna_unchained_reduced_overcharge.buffs[1].multiplier = -0.3
BuffTemplates.sienna_unchained_reduced_overcharge.buffs[1].stat_buff = "reduced_overcharge"
--[LEVEL 30 TALENTS]:
CareerAbilityBWUnchained._run_ability = function (self, new_initial_speed)
	self:_stop_priming()

	local owner_unit = self._owner_unit
	local is_server = self._is_server
	local local_player = self._local_player
	local bot_player = self._bot_player
	local position = POSITION_LOOKUP[owner_unit]
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit
	local career_extension = self._career_extension
	local buff_extension = self._buff_extension
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	local buff_name = "sienna_unchained_activated_ability"

	buff_extension:add_buff(buff_name, {
		attacker_unit = owner_unit
	})

	if (is_server and bot_player) or local_player then
		local overcharge_extension = ScriptUnit.extension(owner_unit, "overcharge_system")
		overcharge_extension:reset()
		career_extension:set_state("sienna_activate_unchained")
		if buff_extension:has_buff_type("sienna_unchained_activated_ability_power_on_enemies_hit_buff1") then
						if not talent_extension:has_talent("sienna_unchained_reduced_overcharge", "bright_wizard", true) and not buff_extension:has_buff_type("traits_ranged_reduced_overcharge") then
							overcharge_extension:reset()
							overcharge_extension:add_charge(35)
						elseif buff_extension:has_buff_type("traits_ranged_reduced_overcharge") and not talent_extension:has_talent("sienna_unchained_reduced_overcharge", "bright_wizard", true) then
							overcharge_extension:reset()
							overcharge_extension:add_charge(44)
						elseif talent_extension:has_talent("sienna_unchained_reduced_overcharge", "bright_wizard", true) and not buff_extension:has_buff_type("traits_ranged_reduced_overcharge") then
							overcharge_extension:reset()
							overcharge_extension:add_charge(50)
						elseif talent_extension:has_talent("sienna_unchained_reduced_overcharge", "bright_wizard", true) and buff_extension:has_buff_type("traits_ranged_reduced_overcharge") then
							overcharge_extension:reset()
							overcharge_extension:add_charge(70)
						end
		end
	end

	local rotation = Unit.local_rotation(owner_unit, 0)
	local explosion_template_name = "explosion_bw_unchained_ability"
	local scale = 1

	if talent_extension:has_talent("sienna_unchained_activated_ability_fire_aura", "bright_wizard", true) then
		explosion_template_name = "explosion_bw_unchained_ability_increased_radius"
	end

	local career_power_level = career_extension:get_career_power_level()

	if talent_extension:has_talent("sienna_unchained_activated_ability_temp_health", "bright_wizard", true) then

		local radius = 10
		local nearby_player_units = FrameTable.alloc_table()
		local proximity_extension = Managers.state.entity:system("proximity_system")
		local broadphase = proximity_extension.player_units_broadphase

		Broadphase.query(broadphase, POSITION_LOOKUP[owner_unit], radius, nearby_player_units)

		local side_manager = Managers.state.side
		local heal_amount = 30
		local heal_type_id = NetworkLookup.heal_types.career_skill

		for _, player_unit in pairs(nearby_player_units) do
			if not side_manager:is_enemy(self._owner_unit, player_unit) then
				local unit_go_id = network_manager:unit_game_object_id(player_unit)

				if unit_go_id then
					network_transmit:send_rpc_server("rpc_request_heal", unit_go_id, heal_amount, heal_type_id)
				end
			end
		end
	end

	local explosion_template = ExplosionTemplates[explosion_template_name]
	local owner_unit_go_id = network_manager:unit_game_object_id(owner_unit)
	local damage_source = "career_ability"
	local explosion_template_id = NetworkLookup.explosion_templates[explosion_template_name]
	local damage_source_id = NetworkLookup.damage_sources[damage_source]
	local is_husk = false

	if is_server then
		network_transmit:send_rpc_clients("rpc_create_explosion", owner_unit_go_id, false, position, rotation, explosion_template_id, scale, damage_source_id, career_power_level, false, owner_unit_go_id)
	else
		network_transmit:send_rpc_server("rpc_create_explosion", owner_unit_go_id, false, position, rotation, explosion_template_id, scale, damage_source_id, career_power_level, false, owner_unit_go_id)
	end

	DamageUtils.create_explosion(self._world, owner_unit, position, rotation, explosion_template, scale, damage_source, is_server, is_husk, owner_unit, career_power_level, false, owner_unit)
	career_extension:start_activated_ability_cooldown()

	if talent_extension:has_talent("sienna_unchained_activated_ability_fire_aura") then
		local buffs = {
			"sienna_unchained_activated_ability_pulse"
		}
		local unit_object_id = network_manager:unit_game_object_id(owner_unit)

		if is_server then
			local buff_extension = self._buff_extension

			for i = 1, #buffs, 1 do
				local buff_name = buffs[i]
				local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

				buff_extension:add_buff(buff_name, {
					attacker_unit = owner_unit
				})
				network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
			end
		else
			for i = 1, #buffs, 1 do
				local buff_name = buffs[i]
				local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

				network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
			end
		end
	end

	if talent_extension:has_talent("sienna_unchained_activated_ability_power_on_enemies_hit") then
		local attack_type_id = NetworkLookup.buff_attack_types.ability
		local attacker_unit_id = network_manager:unit_game_object_id(owner_unit)
		local buff_weapon_type_id = NetworkLookup.buff_weapon_types["n/a"]
		local hit_zone_id = NetworkLookup.hit_zones.torso
		local radius = 10
		local nearby_enemy_units = FrameTable.alloc_table()
		local proximity_extension = Managers.state.entity:system("proximity_system")
		local broadphase = proximity_extension.enemy_broadphase

		Broadphase.query(broadphase, position, radius, nearby_enemy_units)

		local target_number = 1
		local side_manager = Managers.state.side

		for _, enemy_unit in pairs(nearby_enemy_units) do
			if Unit.alive(enemy_unit) then
				local hit_unit_id = network_manager:unit_game_object_id(enemy_unit)

				if side_manager:is_enemy(owner_unit, enemy_unit) then
					if is_server then
						network_transmit:send_rpc_server("rpc_buff_on_attack", attacker_unit_id, hit_unit_id, attack_type_id, false, hit_zone_id, target_number, buff_weapon_type_id)
					else
						network_transmit:send_rpc_server("rpc_buff_on_attack", attacker_unit_id, hit_unit_id, attack_type_id, false, hit_zone_id, target_number, buff_weapon_type_id)
					end
				end
			end
		end
	end

	if talent_extension:has_talent("sienna_unchained_activated_ability_fire_aura", "bright_wizard", true) then
		career_power_level = career_power_level * 1.5
	end

	local inventory_extension = ScriptUnit.has_extension(owner_unit, "inventory_system")
	local lh_weapon_unit, rh_weapon_unit = inventory_extension:get_all_weapon_unit()
	local lh_weapon_extension = lh_weapon_unit and ScriptUnit.has_extension(lh_weapon_unit, "weapon_system")
	local rh_weapon_extension = rh_weapon_unit and ScriptUnit.has_extension(rh_weapon_unit, "weapon_system")
	local has_action = lh_weapon_extension and lh_weapon_extension:has_current_action()
	has_action = has_action or (rh_weapon_extension and rh_weapon_extension:has_current_action())

	if not has_action then
		CharacterStateHelper.play_animation_event(owner_unit, "unchained_ability_explosion")
	end

	if (is_server and bot_player) or local_player then
		local first_person_extension = self._first_person_extension

		if not has_action then
			first_person_extension:animation_event("unchained_ability_explosion")
		end

		first_person_extension:play_hud_sound_event("Play_career_ability_unchained_fire")
		first_person_extension:play_remote_unit_sound_event("Play_career_ability_unchained_fire", owner_unit, 0)
	end

	self:_play_vo()
end
--[FUEL FOR THE FIRE]:
BuffTemplates.sienna_unchained_activated_ability_power_on_enemies_hit_buff1 = {
		buffs = {
			{
				name = "sienna_unchained_activated_ability_power_on_enemies_hit_buff1",
				multiplier = -1,
				max_stacks = 1,
				duration = 15,
				apply_buff_func = "unchained_ability_power_on_enemies_hit_overcharge",
				stat_buff = "reduced_overcharge_from_passive",
				refresh_durations = true
			}
		}
	}
BuffTemplates.sienna_unchained_activated_ability_power_on_enemies_hit_buff2 = {
		buffs = {
			{
				name = "sienna_unchained_activated_ability_power_on_enemies_hit_buff2",
				multiplier = -1,
				max_stacks = 1,
				duration = 15,
				stat_buff = "overcharge_regen",
				refresh_durations = true
			}
		}
	}
BuffFunctionTemplates.functions.unchained_ability_power_on_enemies_hit_overcharge = function (unit, buff, params)
	local overcharge_extension = ScriptUnit.extension(unit, "overcharge_system")
	local buff_extension = ScriptUnit.extension(unit, "buff_system")
	local talent_extension = ScriptUnit.has_extension(unit, "talent_system")
	if talent_extension and talent_extension:has_talent("sienna_unchained_activated_ability_power_on_enemies_hit", "bright_wizard", true) then
						if not talent_extension:has_talent("sienna_unchained_reduced_overcharge", "bright_wizard", true) and not buff_extension:has_buff_type("traits_ranged_reduced_overcharge") then
							--overcharge_extension:reset()
							overcharge_extension:add_charge(35)
						elseif buff_extension:has_buff_type("traits_ranged_reduced_overcharge") and not talent_extension:has_talent("sienna_unchained_reduced_overcharge", "bright_wizard", true) then
							--overcharge_extension:reset()
							overcharge_extension:add_charge(44)
						elseif talent_extension:has_talent("sienna_unchained_reduced_overcharge", "bright_wizard", true) and not buff_extension:has_buff_type("traits_ranged_reduced_overcharge") then
							--overcharge_extension:reset()
							overcharge_extension:add_charge(50)
						elseif talent_extension:has_talent("sienna_unchained_reduced_overcharge", "bright_wizard", true) and buff_extension:has_buff_type("traits_ranged_reduced_overcharge") then
							--overcharge_extension:reset()
							overcharge_extension:add_charge(70)
						end
	end
end
BuffTemplates.sienna_unchained_activated_ability_power_on_enemies_hit_buff.buffs[1].icon = "sienna_unchained_max_overcharge"
BuffTemplates.sienna_unchained_activated_ability_power_on_enemies_hit.buffs[1].buff_to_add = nil
BuffTemplates.sienna_unchained_activated_ability_power_on_enemies_hit.buffs[1].buffs_to_add = {
	"sienna_unchained_activated_ability_power_on_enemies_hit_buff",
	"sienna_unchained_activated_ability_power_on_enemies_hit_buff1",
	"sienna_unchained_activated_ability_power_on_enemies_hit_buff2"
	}
		
ProcFunctions.sienna_unchained_activated_ability_power_on_enemies_hit = function (player, buff, params)
			local player_unit = player.player_unit
			local overcharge_extension = ScriptUnit.extension(player_unit, "overcharge_system")
			local talent_extension = ScriptUnit.extension(player_unit, "talent_system")

			if ALIVE[player_unit] then
				local attack_type = params[2]

				if attack_type and attack_type == "ability" then
					local buff_template = buff.template
					local buff_list = buff_template.buffs_to_add
					local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")
					--[[if talent_extension:has_talent("sienna_unchained_activated_ability_power_on_enemies_hit", "bright_wizard", true) then
						if not talent_extension:has_talent("sienna_unchained_reduced_overcharge", "bright_wizard", true) and not buff_extension:has_buff_type("traits_ranged_reduced_overcharge") then
							overcharge_extension:reset()
							overcharge_extension:add_charge(35)
						elseif buff_extension:has_buff_type("traits_ranged_reduced_overcharge") and not talent_extension:has_talent("sienna_unchained_reduced_overcharge", "bright_wizard", true) then
							overcharge_extension:reset()
							overcharge_extension:add_charge(44)
						elseif talent_extension:has_talent("sienna_unchained_reduced_overcharge", "bright_wizard", true) and not buff_extension:has_buff_type("traits_ranged_reduced_overcharge") then
							overcharge_extension:reset()
							overcharge_extension:add_charge(50)
						elseif talent_extension:has_talent("sienna_unchained_reduced_overcharge", "bright_wizard", true) and buff_extension:has_buff_type("traits_ranged_reduced_overcharge") then
							overcharge_extension:reset()
							overcharge_extension:add_charge(70)
						end
					end]]

					for i = 1, #buff_list, 1 do
					local buff_name = buff_list[i]
					local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
					local network_manager = Managers.state.network
					local network_transmit = network_manager.network_transmit
					local unit_object_id = network_manager:unit_game_object_id(player_unit)
					local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

					if Managers.state.network.is_server then
						buff_extension:add_buff(buff_name, {
							attacker_unit = player_unit
						})
						network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
					else
						network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
					end
				end
			end
		end
	end
--[BLAZING CRESCENDO]:
Talents.bright_wizard[50].icon = "sienna_unchained_max_overcharge"
Talents.bright_wizard[51].icon = "sienna_unchained_activated_ability_radius"
BuffFunctionTemplates.functions.sienna_unchained_activated_ability_pulse_update = function (unit, buff, params)
		local template = buff.template
		local t = params.t
		local position = POSITION_LOOKUP[unit]
		local pulse_frequency = template.pulse_frequency
		local buff_extension = ScriptUnit.extension(unit, "buff_system")

		if not buff_extension then
			return
		end

		if not buff.targeting_effect_id then
			local world = Managers.world:world("level_world")
			local first_person_effect_name = "fx/unchained_aura_talent_1p"
			local third_person_effect_name = "fx/unchained_aura_talent_3p"
			buff.targeting_effect_id = World.create_particles(world, third_person_effect_name, Vector3.zero())
			buff.targeting_variable_id = World.find_particles_variable(world, third_person_effect_name, "charge_radius")

			World.set_particles_variable(world, buff.targeting_effect_id, buff.targeting_variable_id, Vector3(12, 12, 0.2))

			local screenspace_effect_name = first_person_effect_name
			local first_person_extension = ScriptUnit.has_extension(unit, "first_person_system")

			if first_person_extension then
				buff.screenspace_effect_id = first_person_extension:create_screen_particles(screenspace_effect_name)
			end
		end

		if buff.targeting_effect_id then
			local world = Managers.world:world("level_world")

			World.move_particles(world, buff.targeting_effect_id, position)
		end

		if not buff.timer or buff.timer < t then
			if not Managers.state.network.is_server then
				return
			end

			local ai_system = Managers.state.entity:system("ai_system")
			local ai_broadphase = ai_system.broadphase
			local buff_extension = ScriptUnit.extension(unit, "buff_system")
			local buff_system = Managers.state.entity:system("buff_system")
			local range = 10
			local broadphase_results = {}
			table.clear(broadphase_results)

			local num_nearby_enemies = Broadphase.query(ai_broadphase, position, range, broadphase_results)
			local num_alive_nearby_enemies = 0

			for i = 1, num_nearby_enemies, 1 do
				local enemy_unit = broadphase_results[i]

				if AiUtils.unit_alive(enemy_unit) then
					local damage = 2
					local buff_system = Managers.state.entity:system("buff_system")

					buff_system:add_buff(enemy_unit, "burning_1W_dot_unchained_pulse", unit, false, 200, unit)
					DamageUtils.add_damage_network(enemy_unit, enemy_unit, damage, "torso", "burn_shotgun", nil, Vector3(0, 0, 0), nil, nil, unit)
				end
			end

			buff.timer = t + pulse_frequency
		end
	end
BuffTemplates.burning_1W_dot_unchained_pulse.buffs[1].duration = 8
BuffTemplates.burning_1W_dot_unchained_pulse.buffs[1].time_between_dot_damages = 2
--"sienna_unchained_activated_ability_damage"
ExplosionTemplates.explosion_bw_unchained_ability_increased_radius.explosion.radius = 10
ExplosionTemplates.explosion_bw_unchained_ability_increased_radius.explosion.max_damage_radius = 6.5
ExplosionTemplates.explosion_bw_unchained_ability_increased_radius.explosion.no_friendly_fire = nil
ExplosionTemplates.explosion_bw_unchained_ability_increased_radius.explosion.attack_template = "flame_blast"
ExplosionTemplates.explosion_bw_unchained_ability_increased_radius.explosion.alert_enemies_radius = 20
ExplosionTemplates.explosion_bw_unchained_ability_increased_radius.explosion.damage_profile = "unchained_ability_blazing_crescendo"
ExplosionTemplates.explosion_bw_unchained_ability.explosion.no_friendly_fire = true


-------------------------------------------------------
--					//////[KERILLIAN]\\\\\\
-------------------------------------------------------
--[SISTER OF THE THORN]:
--[PASSIVES]
--SoTT LEECH PASSIVE
BuffTemplates.kerillian_thorn_sister_passive_healing_received_aura.buffs[1].range = 15
BuffTemplates.kerillian_thorn_sister_passive_healing_received_aura_buff.buffs[1].icon = "kerillian_thornsister_bloodlust"
BuffTemplates.kerillian_thorn_sister_passive_temp_health_funnel_aura.buffs[1].range = 15
--[INHERITANCE FX ADJUSTMENTS]:
BuffTemplates.kerillian_thorn_sister_avatar_buff_1.deactivation_sound = nil
BuffTemplates.kerillian_thorn_sister_avatar_buff_1.activation_sound = nil
--SOTT CRIT FROM ULT
BuffTemplates.kerillian_thorn_sister_crit_on_any_ability.buffs[1].amount_to_add = 2
--[SHADE]:
--[VANISH]:
--[CLOAK OF MIST]
BuffFunctionTemplates.functions.end_shade_activated_ability = function (unit, buff, params, world)
		local function is_local(unit)
			local player = Managers.player:owner(unit)

			return player and not player.remote
		end
		local function is_bot(unit)
			local player = Managers.player:owner(unit)

			return player and player.bot_player
		end

		local function is_server()
			return Managers.state.network.is_server
		end
		local status_extension = ScriptUnit.has_extension(unit, "status_system")
		local allowed_to_trigger = false
		local talent_extension = ScriptUnit.has_extension(unit, "talent_system")

		if talent_extension and talent_extension:has_talent("kerillian_shade_passive_stealth_on_backstab_kill") then
			if status_extension and (status_extension:subtract_shade_stealth_counter() == 0 or status_extension:subtract_shade_stealth_counter() == 1) then
				allowed_to_trigger = true
			end
		elseif status_extension and status_extension:subtract_shade_stealth_counter() == 0 then
			allowed_to_trigger = true
		end

		if allowed_to_trigger == true then
			if is_local(unit) then
				local first_person_extension = ScriptUnit.extension(unit, "first_person_system")

				first_person_extension:play_hud_sound_event("Play_career_ability_kerillian_shade_exit")
				first_person_extension:play_hud_sound_event("Stop_career_ability_kerillian_shade_loop")

				local career_extension = ScriptUnit.extension(unit, "career_system")

				career_extension:set_state("default")

				local talent_extension = ScriptUnit.has_extension(unit, "talent_system")

				--if talent_extension:has_talent("kerillian_shade_activated_ability_quick_cooldown") then
					--local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

					--buff_extension:add_buff("kerillian_shade_activated_ability_quick_cooldown_crit")
				--end

				MOOD_BLACKBOARD.skill_shade = false

				if Managers.state.network:game() then
					local status_extension = ScriptUnit.extension(unit, "status_system")

					status_extension:set_is_dodging(false)
				end
			end

			if is_local(unit) or (is_server() and is_bot(unit)) then
				local status_extension = ScriptUnit.extension(unit, "status_system")

				status_extension:set_invisible(false)
				status_extension:set_noclip(false)

				local events = {
					"Play_career_ability_kerillian_shade_exit",
					"Stop_career_ability_kerillian_shade_loop_husk"
				}
				local network_manager = Managers.state.network
				local network_transmit = network_manager.network_transmit
				local is_server = Managers.player.is_server
				local unit_id = network_manager:unit_game_object_id(unit)
				local node_id = 0

				for i = 1, #events, 1 do
					local event = events[i]
					local event_id = NetworkLookup.sound_events[event]

					if is_server then
						network_transmit:send_rpc_clients("rpc_play_husk_unit_sound_event", unit_id, node_id, event_id)
					else
						network_transmit:send_rpc_server("rpc_play_husk_unit_sound_event", unit_id, node_id, event_id)
					end
				end
			end
		end
	end
BuffTemplates.kerillian_shade_activated_ability_quick_cooldown.buffs[1].perk = "guaranteed_crit"
-------------------------------------------------------
--//////[DAMAGE PROFILES]\\\\\\
-------------------------------------------------------
--HTDamageProfileTemplates list thingy
HTDamageProfileTemplates = {}
--new damage profiles
HTDamageProfileTemplates.unchained_ability_blazing_crescendo = {
	charge_value = "grenade",
	is_explosion = true,
	no_stagger_damage_reduction_ranged = true,
	armor_modifier = {
		attack = {
			1,
			0.4,
			3,
			0.5,
			1.5,
			0.25
		},
		impact = {
			1,
			0.5,
			100,
			1,
			1,
			1
		}
	},
	default_target = {
		attack_template = "flame_blast",
		dot_template_name = "burning_1W_dot",
		damage_type = "grenade",
		power_distribution = {
			attack = 0.45,
			impact = 1.65
		}
	}
}
--work in network thingy
for key, _ in pairs(HTDamageProfileTemplates) do
    i = #NetworkLookup.damage_profiles + 1
    NetworkLookup.damage_profiles[i] = key
    NetworkLookup.damage_profiles[key] = i
end
--Merge the tables together
table.merge_recursive(DamageProfileTemplates, HTDamageProfileTemplates)
-------------------------------------------------------
--//////[DEUS POWER UP TEMPLATES]\\\\\\
-------------------------------------------------------
-------------------------------------------------------
--//////[TALENT NAMES AND DESCRIPTIONS]\\\\\\
-------------------------------------------------------
mod:hook(_G, "Localize", function(func, key, ...)
  if key == "bardin_slayer_crit_chance_desc" then
    return "Increase critical hit chance by 5 percent. Critical hits cause enemies to take more damage for a short time."
  end
  if key == "bardin_slayer_push_on_dodge_desc" then
    return "Effective dodges push most nearby enemies out of the way."
  end
  if key == "career_passive_desc_bw_3b" then
    return "No Overcharge slowdown. During overcharge, Sienna expends health to increase ability cooldown rate."
  end
  if key == "sienna_unchained_reduced_overcharge_desc" then
    return "Reduces overcharge generated by 30 percent. During overcharge, Sienna no longer expends health to increase ability cooldown rate."
  end
  if key == "sienna_unchained_health_to_ult_desc" then
    return "During overcharge, Sienna expends less health to increase ability cooldown rate through Slave to Aqshy."
  end
  if key == "sienna_unchained_activated_ability_power_on_enemies_hit_desc" then
    return "Hitting an enemy with Living Bomb grants high overcharge and prevents overcharge from decaying or being generated by Blood Magic. Also increases power by 5 percent per enemy hit for 15 seconds. Stacks 5 times."
  end
  if key == "sienna_unchained_reduced_damage_taken_after_venting_desc_2" then
    return "Completely absorb the overcharge generated from a hit every 10 seconds."
  end
  if key == "sienna_unchained_activated_ability_fire_aura_desc" then
    return "Living Bomb explosion radius is increased by 100 percent and grants Sienna a scorching aura that ignites nearby enemies, causing damage over time. The damage and stagger power of the explosion is also increased."
  end
  if key == "sienna_unchained_activated_ability_fire_aura" then
    return "Blazing Crescendo"
  end
  if key == "sienna_adept_increased_burn_damage_reduced_non_burn_damage_desc" then
    return "Burning damage over time is increased by 75 percent. All non-burn damage is reduced by 15 percent."
  end
  if key == "bardin_slayer_attack_speed_on_double_one_handed_weapons_desc" then
    return "Wielding one-handed weapons in both slots increases attack speed by 10 percent. Dual weapons count as one-handed. Wielding two-handed weapons in both slots increases power by 15 percent."
  end
  if key == "bardin_slayer_attack_speed_on_double_one_handed_weapons" then
    return "A Thousand Split Skulls"
  end
  if key == "bardin_slayer_power_on_double_two_handed_weapons_desc" then
    return "Push cost is halved."
  end
  if key == "bardin_slayer_power_on_double_two_handed_weapons" then
    return "Slayer Stamina"
  end
  if key == "sienna_unchained_burn_push_desc_2" then
    return "Increases push/block angle by 30 percent. Pushing an enemy ignites them, causing damage over time. Heavy attacks increase the range of the next push by 100 percent."
  end
  if key == "victor_zealot_reduced_damage_taken_desc" then
    return "Killing an enemy allows Victor to resist death for 2 seconds."
  end
  if key == "victor_zealot_power_desc" then
    return "Taking damage increases melee power by 15 percent for 5 seconds."
  end
  if key == "career_passive_desc_wh_1a" then
    return "Power increases by 5 percent for every 25 health missing. Pressing the Weapon Special bind while holding the Career Skill button will convert all permanent health to temporary health."
  end
  if key == "markus_huntsman_movement_speed" then
    return "Master of the Skirmish"
  end
  if key == "markus_huntsman_movement_speed_desc" then
    return "Ranged headshots increase movement speed by 15 percent for 3 seconds. Close quarters ranged attacks have improved armour penetration."
  end
  if key == "markus_huntsman_movement_speed_desc_2" then
    return "Killing a Special or Elite enemy reduces damage taken by 10 percent and increases attack speed by 2.5 percent. Stacks 4 times. Taking a hit removes one stack."
  end
  if key == "markus_questing_knight_ability_buff_on_kill_desc" then
    return "Killing an enemy with Blessed Blade increases movement speed by 35 percent and attack speed by 10 percent for 15 seconds. Markus also resists ranged knockback during this time."
  end
  if key == "bardin_ironbreaker_party_power_on_blocked_attacks_desc" then
    return "Blocking an attack or staggering an Elite enemy increases the melee power of Bardin and his allies by 2 percent for 15 seconds. Stacks 5 times."
  end
  if key == "bardin_ranger_movement_speed_desc" then
    return "Increases movement speed by 10 percent. When Bardin picks up a consumable, he receives a buff related to that item. 30 second cooldown."
  end
  if key == "bardin_ranger_movement_speed" then
    return "First Dibs"
  end
  return func(key, ...)
end)
-------------------------------------------------------
--//////[TALENT NETWORK LOOKUP]\\\\\\
-------------------------------------------------------
for buff_name, _ in pairs(BuffTemplates) do
    local indexed = table.contains(NetworkLookup.buff_templates, buff_name)
    if not indexed then
        local index = #NetworkLookup.buff_templates + 1
        NetworkLookup.buff_templates[index] = buff_name
        NetworkLookup.buff_templates[buff_name] = index
    end
end
mod:echo("[Hero Tweaks]: Active")
-- Your mod code goes here.
-- https://vmf-docs.verminti.de
