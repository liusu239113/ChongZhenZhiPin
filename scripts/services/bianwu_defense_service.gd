class_name BianwuDefenseService
extends RefCounted

const DEFAULT_COMMAND_POINTS: = 1
const MAX_COMMAND_POINTS: = 3
const UNIT_CARD_CAP: = 1000

const FALLEN_MONTHS_THRESHOLD: = 3
const FALLEN_SIZE_THRESHOLD: = 60
const FORTIFIED_TYPE_KEYWORDS: = ["城", "堡", "所", "卫", "关", "墙", "镇"]
const PENDING_BATTLE_META: = "bianwu_pending_battle"
const QINSHUI_MONTHLY_STABILITY: = 2
const SHUBAN_SUPPLY_RATE: = 0.15
const DEFAULT_OFFICER_PROFILES: = {
    "bw_officer_qinbing": {"name": "顾承武", "role": "武官", "relation": "顾氏族叔", "specialty": "统带家丁", "monthly_effect": "每月：防区安定度 +2", "loyalty": 78, "assigned_unit_id": "knife_shield"}, 
    "bw_officer_liangtai": {"name": "沈维钧", "role": "书办", "relation": "保定粮台书办", "specialty": "转运粮饷", "monthly_effect": "每月：驻防粮草、饷银供给 +15%", "loyalty": 62, "assigned_unit_id": ""}, 
}
const STABILITY_MULTIPLIERS: = {
    "归附": 1.1, 
    "安稳": 1.0, 
    "不安": 0.75, 
    "动荡": 0.4, 
    "失序": 0.0, 
}

static func is_bianwu(game_state: Node) -> bool:
    return game_state != null and str(game_state.get("active_line")) == "bianwu"

static func region_allows_deployment(region: Dictionary) -> bool:
    return bool(region.get("allows_deployment", true))

static func region_counts_for_supply(region: Dictionary) -> bool:
    return bool(region.get("counts_for_supply", true))


static func region_fortified(region: Dictionary) -> bool:
    if region.has("fortified"):
        return bool(region.get("fortified"))
    var region_type: = str(region.get("type", ""))
    for keyword in FORTIFIED_TYPE_KEYWORDS:
        if region_type.contains(keyword):
            return true
    return false

static func stronghold_holder(region: Dictionary) -> String:
    return str(region.get("stronghold_holder", "player"))

static func region_fallen(region: Dictionary) -> bool:
    return bool(region.get("fallen", false))

static func region_has_units(game_state: Node, region_id: String) -> bool:
    for unit in game_state.bianwu_units:
        if unit is Dictionary and str(unit.get("region_id", "")) == region_id:
            return true
    return false

static func enemy_in_region(game_state: Node, region_id: String) -> Dictionary:
    for enemy in game_state.bianwu_defense_enemies:
        if enemy is Dictionary and str(enemy.get("region_id", "")) == region_id:
            return enemy
    return {}


static func region_cell_total(game_state: Node, region_id: String) -> int:
    var HexMapRef = load("res://scripts/ui/bianwu_hex_map.gd")
    var act_layouts: Dictionary = HexMapRef.ACT_ONE_REGION_CELL_LAYOUTS
    if act_layouts.has(region_id):
        return (act_layouts[region_id] as Array).size()
    var idx: = _region_index(game_state, region_id)
    if idx >= 0:
        var layouts: Array = HexMapRef.REGION_CELL_LAYOUTS
        return (layouts[idx % layouts.size()] as Array).size()
    return 5



static func enemy_red_cells(game_state: Node, region_id: String) -> int:
    var region: = _region(game_state, region_id)
    var total: = region_cell_total(game_state, region_id)
    if region_fallen(region):
        return total
    var enemy: = enemy_in_region(game_state, region_id)
    if enemy.is_empty():
        return 1 if stronghold_holder(region) == "rebel" else 0
    return clampi(int(enemy.get("size", 20)) / 10, 1, maxi(1, total - 1))

static func _spend_action_point(game_state: Node) -> void :
    game_state.action_points = maxi(int(game_state.action_points) - 1, 0)

static func default_region_id(game_state: Node) -> String:
    if game_state == null:
        return ""
    for region in game_state.bianwu_defense_regions:
        if region is Dictionary and region_allows_deployment(region) and str(region.get("control", "player")) == "player":
            return str(region.get("id", ""))
    return ""

static func _game_data() -> Node:
    var tree: = Engine.get_main_loop() as SceneTree
    return tree.root.get_node_or_null("GameData") if tree != null else null

static func _maps() -> Dictionary:
    var game_data: = _game_data()
    return game_data.LINES.get("bianwu", {}).get("defense_maps_by_act", {}) if game_data != null else {}

static func _current_act(game_state: Node) -> int:
    if game_state.has_method("get_current_governance_act"):
        return clampi(int(game_state.get_current_governance_act()), 1, 5)
    return 1

static func initialize_for_act(game_state: Node, act: int) -> void :
    if not is_bianwu(game_state):
        return
    var config: Dictionary = _maps().get(str(clampi(act, 1, 5)), {})
    if config.is_empty():
        return
    game_state.bianwu_defense_act = act
    game_state.bianwu_defense_regions = config.get("regions", []).duplicate(true)
    game_state.bianwu_defense_roads = config.get("roads", []).duplicate(true)
    game_state.bianwu_defense_enemies = []
    game_state.bianwu_defense_warnings = []
    game_state.bianwu_defense_last_report = {}
    game_state.bianwu_command_cap = clampi(int(config.get("command_cap", 2)), 1, MAX_COMMAND_POINTS)
    game_state.bianwu_command_points = mini(DEFAULT_COMMAND_POINTS, game_state.bianwu_command_cap)
    _normalize_units(game_state)
    _initialize_officers(game_state)

static func ensure_initialized(game_state: Node) -> void :
    if not is_bianwu(game_state):
        return
    var act: = _current_act(game_state)
    if int(game_state.bianwu_defense_act) != act or game_state.bianwu_defense_regions.is_empty():
        initialize_for_act(game_state, act)
    else:
        normalize_saved_state(game_state)

static func normalize_saved_state(game_state: Node) -> void :
    if not is_bianwu(game_state):
        return
    game_state.bianwu_command_cap = clampi(int(game_state.bianwu_command_cap), 1, MAX_COMMAND_POINTS)
    game_state.bianwu_command_points = clampi(int(game_state.bianwu_command_points), 0, game_state.bianwu_command_cap)
    for idx in range(game_state.bianwu_defense_regions.size()):
        var region: Dictionary = game_state.bianwu_defense_regions[idx]
        region["stability"] = clampi(int(region.get("stability", 60)), 0, 100)
        region["control"] = str(region.get("control", "player"))
        region["problem"] = str(region.get("problem", ""))
        region["stronghold_holder"] = str(region.get("stronghold_holder", "player"))
        region["fallen"] = bool(region.get("fallen", false))
        region["lost_months"] = int(region.get("lost_months", 0))
        game_state.bianwu_defense_regions[idx] = region


    for enemy_idx in range(game_state.bianwu_defense_enemies.size()):
        var enemy = game_state.bianwu_defense_enemies[enemy_idx]
        if not enemy is Dictionary:
            continue
        var enemy_region_id: = str(enemy.get("region_id", ""))
        var enemy_region_idx: = _region_index(game_state, enemy_region_id)
        if enemy_region_idx < 0:
            continue
        var enemy_region: Dictionary = game_state.bianwu_defense_regions[enemy_region_idx]

        if str(enemy.get("id", "")) == "bw1_bandits" and int(enemy.get("size", 0)) > 30:
            enemy["size"] = 20
            game_state.bianwu_defense_enemies[enemy_idx] = enemy
        if region_fortified(enemy_region) and stronghold_holder(enemy_region) != "rebel" and not region_has_units(game_state, enemy_region_id):
            enemy["settled"] = true
            enemy["target_region_id"] = ""
            enemy["status"] = "据%s盘踞" % str(enemy_region.get("name", "据点"))
            game_state.bianwu_defense_enemies[enemy_idx] = enemy
            enemy_region["stronghold_holder"] = "rebel"
            enemy_region["control"] = "enemy"
            enemy_region["lost_months"] = 0
            game_state.bianwu_defense_regions[enemy_region_idx] = enemy_region
    _normalize_units(game_state)
    _initialize_officers(game_state)

static func split_unit_cards(unit: Dictionary) -> Array:
    var total_hp: = int(unit.get("hp", 0))
    if total_hp <= 0:
        return []
    if total_hp <= UNIT_CARD_CAP and not str(unit.get("deployment_group_id", "")).is_empty() and not str(unit.get("deployment_card_id", "")).is_empty():
        return [unit.duplicate(true)]
    var group_id: = str(unit.get("deployment_group_id", ""))
    if group_id.is_empty():
        var identity: = "%s|%s|%s|%s" % [
            str(unit.get("id", unit.get("unit_id", "unit"))), 
            str(unit.get("name", "")), 
            str(unit.get("region_id", "")), 
            str(unit.get("commander_id", "")), 
        ]
        group_id = "bw_group_%s" % absi(identity.hash())
    var cards: Array = []
    var remaining_hp: = total_hp
    var card_count: = int(ceil(float(total_hp) / UNIT_CARD_CAP))
    for card_index in range(card_count):
        var card: = unit.duplicate(true)
        card["hp"] = mini(UNIT_CARD_CAP, remaining_hp)
        card["deployment_group_id"] = group_id
        card["deployment_card_id"] = "%s_%d" % [group_id, card_index + 1]
        cards.append(card)
        remaining_hp -= int(card["hp"])
    return cards

static func normalize_unit_cards(game_state: Node) -> void :
    if not is_bianwu(game_state):
        return
    var normalized: Array = []
    var used_card_ids: = {}
    var preserved_card_indices: = {}
    var home_id: = default_region_id(game_state)
    for unit_index in range(game_state.bianwu_units.size()):
        var unit = game_state.bianwu_units[unit_index]
        if not unit is Dictionary:
            continue
        var total_hp: = int(unit.get("hp", 0))
        var group_id: = str(unit.get("deployment_group_id", ""))
        var card_id: = str(unit.get("deployment_card_id", ""))
        if total_hp > 0 and total_hp <= UNIT_CARD_CAP and not group_id.is_empty() and not card_id.is_empty() and not used_card_ids.has(card_id):
            used_card_ids[card_id] = true
            preserved_card_indices[unit_index] = true
    for unit_index in range(game_state.bianwu_units.size()):
        var unit = game_state.bianwu_units[unit_index]
        if not unit is Dictionary:
            var legacy_unit_id: = str(unit).strip_edges()
            if legacy_unit_id.is_empty():
                continue
            var BattleTypesRef = load("res://scripts/battle/battle_types.gd")
            var legacy_definition: Dictionary = BattleTypesRef.unit_def(legacy_unit_id)
            if legacy_definition.is_empty():
                continue
            unit = legacy_definition.duplicate(true)
            unit["id"] = legacy_unit_id
            unit["name"] = str(legacy_definition.get("name", legacy_unit_id))
            unit["level"] = int(legacy_definition.get("level", 1))
            unit["cap"] = int(legacy_definition.get("cap", legacy_definition.get("hp", 0)))
            unit["region_id"] = home_id
        var entry: Dictionary = unit
        var preserve_card_id: = preserved_card_indices.has(unit_index)
        for card in split_unit_cards(entry):
            if preserve_card_id:
                normalized.append(card)
                continue
            var card_group_id: = str(card.get("deployment_group_id", ""))
            var card_number: = 1
            var candidate_id: = "%s_%d" % [card_group_id, card_number]
            while used_card_ids.has(candidate_id):
                card_number += 1
                candidate_id = "%s_%d" % [card_group_id, card_number]
            card["deployment_card_id"] = candidate_id
            used_card_ids[candidate_id] = true
            normalized.append(card)
    game_state.bianwu_units = normalized
    for card in normalized:
        if card is Dictionary:
            remember_unit_group_definition(game_state, unit_group_key(card), card)

static func unit_static_definition(unit: Dictionary) -> Dictionary:
    var definition: = unit.duplicate(true)
    for instance_key in ["hp", "deployment_group_id", "deployment_card_id", "region_id", "morale", "supply", "commander_id", "order"]:
        definition.erase(instance_key)
    return definition

static func remember_unit_group_definition(game_state: Node, group_key: String, unit: Dictionary) -> void :
    if not is_bianwu(game_state) or group_key.is_empty() or not "bianwu_unit_group_defs" in game_state:
        return
    game_state.bianwu_unit_group_defs[group_key] = unit_static_definition(unit)

static func unit_group_key(unit: Variant) -> String:
    if unit is Dictionary:
        var group_id: = str(unit.get("deployment_group_id", ""))
        if not group_id.is_empty():
            return group_id
        return "unit:%s:%d" % [str(unit.get("id", "")), int(bool(unit.get("is_jiading", false)))]
    return "unit:%s:0" % str(unit)

static func _new_tail_card_template(source: Dictionary, game_state: Node, group_key: String) -> Dictionary:
    var template: = source.duplicate(true)
    for dynamic_key in ["hp", "deployment_card_id", "region_id", "morale", "supply", "commander_id", "order"]:
        template.erase(dynamic_key)
    template["deployment_group_id"] = str(source.get("deployment_group_id", group_key))
    var default_region: = str(source.get("region_id", ""))
    if default_region.is_empty():
        default_region = default_region_id(game_state)
    template["region_id"] = default_region
    template["morale"] = 65
    template["supply"] = "充足"
    template["commander_id"] = ""
    template["order"] = "驻防"
    return template

static func set_unit_group_total(game_state: Node, group_key: String, total_hp: int, unit_template: Dictionary = {}) -> bool:
    if not is_bianwu(game_state) or group_key.is_empty():
        return false
    var remaining: Array = []
    var group_cards: Array[Dictionary] = []
    var insert_index: = -1
    for unit in game_state.bianwu_units:
        if unit_group_key(unit) != group_key:
            remaining.append(unit)
            continue
        if insert_index < 0:
            insert_index = remaining.size()
        if unit is Dictionary:
            group_cards.append(unit)
    var persisted_template: Dictionary = game_state.bianwu_unit_group_defs.get(group_key, {}) if "bianwu_unit_group_defs" in game_state else {}
    if group_cards.is_empty() and unit_template.is_empty() and persisted_template.is_empty():
        return false
    if insert_index < 0:
        insert_index = remaining.size()
    var source_template: Dictionary = unit_template if not unit_template.is_empty() else (group_cards[group_cards.size() - 1] if not group_cards.is_empty() else persisted_template)
    if str(source_template.get("deployment_group_id", "")).is_empty() and not group_key.begins_with("unit:"):
        source_template = source_template.duplicate(true)
        source_template["deployment_group_id"] = group_key
    remember_unit_group_definition(game_state, group_key, source_template)
    var group_cap: = int(source_template.get("cap", total_hp))
    var hp_left: = clampi(total_hp, 0, group_cap) if group_cap > 0 else maxi(0, total_hp)
    var rebuilt: Array = []
    var used_ids: = {}
    for existing in group_cards:
        if hp_left <= 0:
            break
        var preserved: = existing.duplicate(true)
        preserved["hp"] = mini(UNIT_CARD_CAP, hp_left)
        rebuilt.append(preserved)
        used_ids[str(preserved.get("deployment_card_id", ""))] = true
        hp_left -= int(preserved["hp"])
    var tail_template: = _new_tail_card_template(source_template, game_state, group_key)
    var next_number: = 1
    while hp_left > 0:
        var new_card: = tail_template.duplicate(true)
        new_card["hp"] = mini(UNIT_CARD_CAP, hp_left)
        var candidate_id: = "%s_%d" % [str(new_card.get("deployment_group_id", group_key)), next_number]
        while used_ids.has(candidate_id):
            next_number += 1
            candidate_id = "%s_%d" % [str(new_card.get("deployment_group_id", group_key)), next_number]
        new_card["deployment_card_id"] = candidate_id
        used_ids[candidate_id] = true
        rebuilt.append(new_card)
        hp_left -= int(new_card["hp"])
    for card_offset in range(rebuilt.size()):
        remaining.insert(insert_index + card_offset, rebuilt[card_offset])
    game_state.bianwu_units = remaining
    normalize_unit_cards(game_state)
    return true

static func add_unit_group_hp(game_state: Node, group_key: String, delta: int, unit_template: Dictionary = {}) -> bool:
    if not is_bianwu(game_state) or group_key.is_empty():
        return false
    var current_total: = 0
    var found: = false
    for unit in game_state.bianwu_units:
        if unit_group_key(unit) == group_key and unit is Dictionary:
            current_total += int(unit.get("hp", 0))
            found = true
    if found:
        return set_unit_group_total(game_state, group_key, current_total + delta, unit_template)
    return set_unit_group_total(game_state, group_key, delta, unit_template) if delta > 0 else false

static func grant_unit_group(game_state: Node, unit_id: String, definition: Dictionary) -> bool:
    if not is_bianwu(game_state) or unit_id.is_empty() or definition.is_empty():
        return false
    var group_key: = "unit:%s:0" % unit_id
    if "bianwu_unit_group_defs" in game_state and game_state.bianwu_unit_group_defs.has(group_key):
        return false
    for unit in game_state.bianwu_units:
        if unit_group_key(unit) == group_key or (unit is Dictionary and str(unit.get("id", "")) == unit_id) or str(unit) == unit_id:
            return false
    var initial_hp: = int(definition.get("hp", 0))
    if initial_hp <= 0:
        return false
    var template: = definition.duplicate(true)
    template["id"] = unit_id
    template["name"] = str(definition.get("name", unit_id))
    template["level"] = int(definition.get("level", 1))
    template["cap"] = int(definition.get("cap", initial_hp))
    template["is_jiading"] = bool(definition.get("is_jiading", false))
    template["deployment_group_id"] = group_key
    template["region_id"] = default_region_id(game_state)
    return set_unit_group_total(game_state, group_key, initial_hp, template)

static func upgrade_unit_group(game_state: Node, from_unit_id: String, target_definition: Dictionary) -> bool:
    if not is_bianwu(game_state) or from_unit_id.is_empty() or target_definition.is_empty():
        return false
    var group_key: = ""
    var source_definition: Dictionary = {}
    for unit in game_state.bianwu_units:
        if unit is Dictionary and str(unit.get("id", "")) == from_unit_id:
            group_key = str(unit.get("deployment_group_id", ""))
            if not group_key.is_empty():
                source_definition = unit_static_definition(unit)
                break
    if group_key.is_empty():
        return false
    var static_definition: = source_definition
    for key in unit_static_definition(target_definition):
        static_definition[key] = target_definition[key]
    for index in range(game_state.bianwu_units.size()):
        var unit = game_state.bianwu_units[index]
        if not unit is Dictionary or str(unit.get("deployment_group_id", "")) != group_key:
            continue
        var upgraded: Dictionary = unit.duplicate(true)
        for key in static_definition:
            upgraded[key] = static_definition[key]
        game_state.bianwu_units[index] = upgraded
    remember_unit_group_definition(game_state, group_key, static_definition)
    return true

static func set_unit_group_level(game_state: Node, group_key: String, level: int) -> bool:
    if not is_bianwu(game_state) or group_key.is_empty():
        return false
    normalize_unit_cards(game_state)
    var found: = false
    for index in range(game_state.bianwu_units.size()):
        var unit = game_state.bianwu_units[index]
        if not unit is Dictionary or unit_group_key(unit) != group_key:
            continue
        var updated: Dictionary = unit.duplicate(true)
        updated["level"] = level
        game_state.bianwu_units[index] = updated
        found = true
    if not found:
        return false
    var definition: Dictionary = game_state.bianwu_unit_group_defs.get(group_key, {}).duplicate(true)
    definition["level"] = level
    game_state.bianwu_unit_group_defs[group_key] = definition
    return true

static func _normalize_units(game_state: Node) -> void :
    normalize_unit_cards(game_state)
    var home_id: = default_region_id(game_state)
    for idx in range(game_state.bianwu_units.size()):
        var unit = game_state.bianwu_units[idx]
        if not unit is Dictionary:
            continue
        var entry: Dictionary = unit
        var region_id: = str(entry.get("region_id", home_id))
        var region: = _region(game_state, region_id)
        entry["region_id"] = region_id if not region.is_empty() and region_allows_deployment(region) else home_id
        entry["morale"] = clampi(int(entry.get("morale", 65)), 0, 100)
        entry["supply"] = str(entry.get("supply", "充足"))
        entry["commander_id"] = str(entry.get("commander_id", ""))
        entry["order"] = str(entry.get("order", "驻防"))
        game_state.bianwu_units[idx] = entry

static func _initialize_officers(game_state: Node) -> void :
    var home_id: = default_region_id(game_state)
    if not game_state.bianwu_defense_officers.is_empty():
        for idx in range(game_state.bianwu_defense_officers.size()):
            var officer: Dictionary = game_state.bianwu_defense_officers[idx]
            _apply_default_officer_profile(officer)
            officer["loyalty"] = clampi(int(officer.get("loyalty", 60)), 0, 100)
            var region: = _region(game_state, str(officer.get("region_id", "")))
            if region.is_empty() or not region_allows_deployment(region):
                officer["region_id"] = home_id
            game_state.bianwu_defense_officers[idx] = officer
        return
    game_state.bianwu_defense_officers = [
        {"id": "bw_officer_qinbing", "name": "顾承武", "role": "武官", "relation": "顾氏族叔", "specialty": "统带家丁", "monthly_effect": "每月：防区安定度 +2", "loyalty": 78, "region_id": home_id, "assigned_unit_id": "knife_shield"}, 
        {"id": "bw_officer_liangtai", "name": "沈维钧", "role": "书办", "relation": "保定粮台书办", "specialty": "转运粮饷", "monthly_effect": "每月：驻防粮草、饷银供给 +15%", "loyalty": 62, "region_id": home_id, "assigned_unit_id": ""}, 
    ]

static func _apply_default_officer_profile(officer: Dictionary) -> void :
    var profile: Dictionary = DEFAULT_OFFICER_PROFILES.get(str(officer.get("id", "")), {})
    if profile.is_empty():
        return
    for key in profile:
        if key == "loyalty" and officer.has(key):
            continue
        officer[key] = profile[key]

static func stability_label(value: int) -> String:
    if value >= 80:
        return "归附"
    if value >= 60:
        return "安稳"
    if value >= 40:
        return "不安"
    if value >= 20:
        return "动荡"
    return "失序"

static func loyalty_label(value: int) -> String:
    if value >= 80:
        return "死忠"
    if value >= 60:
        return "忠顺"
    if value >= 40:
        return "观望"
    if value >= 20:
        return "离心"
    return "反叛"

static func morale_label(value: int) -> String:
    if value >= 80:
        return "高昂"
    if value >= 60:
        return "可战"
    if value >= 40:
        return "疲惫"
    if value >= 20:
        return "动摇"
    return "濒乱"

static func _region_index(game_state: Node, region_id: String) -> int:
    for idx in range(game_state.bianwu_defense_regions.size()):
        if str(game_state.bianwu_defense_regions[idx].get("id", "")) == region_id:
            return idx
    return -1

static func _region(game_state: Node, region_id: String) -> Dictionary:
    var index: = _region_index(game_state, region_id)
    return game_state.bianwu_defense_regions[index] if index >= 0 else {}

static func _road_between(game_state: Node, from_id: String, to_id: String) -> Dictionary:
    for road in game_state.bianwu_defense_roads:
        if not road is Dictionary:
            continue
        if (str(road.get("from", "")) == from_id and str(road.get("to", "")) == to_id) or (str(road.get("from", "")) == to_id and str(road.get("to", "")) == from_id):
            return road
    return {}

static func calculate_regional_supply(game_state: Node) -> Dictionary:
    var result: = {"theoretical_grain": 0, "theoretical_silver": 0, "actual_grain": 0, "actual_silver": 0, "loss_grain": 0, "loss_silver": 0, "shuban_grain_bonus": 0, "shuban_silver_bonus": 0, "regions": []}
    if not is_bianwu(game_state):
        return result
    ensure_initialized(game_state)
    var home_id: = default_region_id(game_state)
    for region in game_state.bianwu_defense_regions:
        if not region_counts_for_supply(region):
            continue
        if str(region.get("control", "player")) != "player":
            continue
        var region_id: = str(region.get("id", ""))
        var base_grain: = int(region.get("base_grain", 0))
        var base_silver: = int(region.get("base_silver", 0))
        var shuban_grain_bonus: = roundi(base_grain * SHUBAN_SUPPLY_RATE) if has_officer_in_slot(game_state, region_id, "shuban") else 0
        var shuban_silver_bonus: = roundi(base_silver * SHUBAN_SUPPLY_RATE) if has_officer_in_slot(game_state, region_id, "shuban") else 0
        var grain: = base_grain + shuban_grain_bonus
        var silver: = base_silver + shuban_silver_bonus
        result.theoretical_grain += grain
        result.theoretical_silver += silver
        result.shuban_grain_bonus += shuban_grain_bonus
        result.shuban_silver_bonus += shuban_silver_bonus
        var multiplier: float = STABILITY_MULTIPLIERS.get(stability_label(int(region.get("stability", 60))), 1.0)
        if str(region.get("id", "")) != home_id:
            var road_status: = "open"
            var has_route: = false
            for road in game_state.bianwu_defense_roads:
                if str(road.get("from", "")) == str(region.get("id", "")) or str(road.get("to", "")) == str(region.get("id", "")):
                    has_route = true
                    if str(road.get("status", "open")) == "cut":
                        road_status = "cut"
                    elif str(road.get("status", "open")) == "blocked" and road_status != "cut":
                        road_status = "blocked"
            if has_route and road_status == "cut":
                multiplier = 0.0
            elif road_status == "blocked":
                multiplier *= 0.8
        var actual_grain: = int(round(grain * multiplier))
        var actual_silver: = int(round(silver * multiplier))
        result.actual_grain += actual_grain
        result.actual_silver += actual_silver
        result.regions.append({"region_id": region_id, "base_grain": base_grain, "base_silver": base_silver, "shuban_grain_bonus": shuban_grain_bonus, "shuban_silver_bonus": shuban_silver_bonus, "actual_grain": actual_grain, "actual_silver": actual_silver})
    result.loss_grain = result.theoretical_grain - result.actual_grain
    result.loss_silver = result.theoretical_silver - result.actual_silver
    return result

static func append_supply_breakdowns(game_state: Node) -> Dictionary:
    var supply: = calculate_regional_supply(game_state)
    if int(supply.actual_grain) > 0:
        game_state.monthly_grain_breakdown.append({"label": "防区地方应供", "value": int(supply.theoretical_grain) - int(supply.shuban_grain_bonus)})
        if int(supply.shuban_grain_bonus) > 0:
            game_state.monthly_grain_breakdown.append({"label": "书办转运粮草", "value": int(supply.shuban_grain_bonus)})
        if int(supply.loss_grain) > 0:
            game_state.monthly_grain_breakdown.append({"label": "安定与转运损耗", "value": - int(supply.loss_grain)})
    if int(supply.actual_silver) > 0:
        game_state.monthly_silver_breakdown.append({"label": "防区地方供饷", "value": int(supply.theoretical_silver) - int(supply.shuban_silver_bonus)})
        if int(supply.shuban_silver_bonus) > 0:
            game_state.monthly_silver_breakdown.append({"label": "书办转运饷银", "value": int(supply.shuban_silver_bonus)})
        if int(supply.loss_silver) > 0:
            game_state.monthly_silver_breakdown.append({"label": "安定与解饷损耗", "value": - int(supply.loss_silver)})
    return supply


static func add_command_points(game_state: Node, amount: int) -> int:
    if not is_bianwu(game_state):
        return 0
    game_state.action_points = maxi(int(game_state.action_points) + amount, 0)
    return game_state.action_points

static func preview_deployment(game_state: Node, payload: Dictionary, target_region_id: String, target_slot: String) -> Dictionary:
    var result: = {"available": false, "reason": "", "command_cost": 1, "grain_cost": 0, "existing_index": -1}
    if not is_bianwu(game_state):
        result.reason = "仅边务路线可以调派。"
        return result
    var target_region: = _region(game_state, target_region_id)
    if target_region.is_empty():
        result.reason = "未找到目标地区。"
        return result
    if not region_allows_deployment(target_region):
        result.reason = "保定城已有都司与诸卫驻军，无须派驻本部兵马。"
        return result
    if region_fallen(target_region):
        result.reason = "此地已全域沦陷，无处立营，唯有自邻区兴兵克复。"
        return result
    var payload_kind: = str(payload.get("kind", payload.get("type", "")))
    var index: = int(payload.get("index", -1))
    if target_slot == "garrison":
        if payload_kind != "unit" or index < 0 or index >= game_state.bianwu_units.size():
            result.reason = "未找到这支部队。"
            return result
        var unit: Dictionary = game_state.bianwu_units[index]
        var from_id: = str(unit.get("region_id", ""))
        if from_id == target_region_id:
            result.reason = "部队已在本防区。"
            return result
        var road: = _road_between(game_state, from_id, target_region_id)
        if road.is_empty() or str(road.get("status", "open")) == "cut":
            result.reason = "两地不相接界，无法直接调动。"
            return result
        var grain_cost: = maxi(10, int(unit.get("hp", 0)) / 5)
        result.grain_cost = grain_cost
        if int(game_state.action_points) < 1:
            result.reason = "本月行动力已用尽。"
            return result
        if int(game_state.city.get("liangcao", 0)) < grain_cost:
            result.reason = "粮草不足，无法调兵。"
            return result
        result.available = true
        return result
    if target_slot == "qinshui" or target_slot == "shuban":
        if payload_kind != "officer" or index < 0 or index >= game_state.bianwu_defense_officers.size():
            result.reason = "未找到可派驻的人物。"
            return result
        var officer: Dictionary = game_state.bianwu_defense_officers[index]
        if officer_slot_kind(officer) != target_slot:
            result.reason = "人物类型与调派槽位不符。"
            return result
        if str(officer.get("region_id", "")) == target_region_id:
            result.reason = "人物已在本防区。"
            return result
        for officer_index in range(game_state.bianwu_defense_officers.size()):
            if officer_index == index:
                continue
            var existing: Dictionary = game_state.bianwu_defense_officers[officer_index]
            if officer_slot_kind(existing) == target_slot and str(existing.get("region_id", "")) == target_region_id:
                result.existing_index = officer_index
                break
        if int(result.existing_index) >= 0 and not bool(payload.get("replace_existing", false)):
            result.reason = "该槽已有人员，需确认更换。"
            return result
        if int(game_state.action_points) < 1:
            result.reason = "本月行动力已用尽。"
            return result
        result.available = true
        return result
    result.reason = "未知的调派槽位。"
    return result

static func move_unit(game_state: Node, unit_index: int, target_region_id: String) -> Dictionary:
    if not is_bianwu(game_state):
        return {"ok": false, "message": "仅边务路线可以调动防区部队。"}
    ensure_initialized(game_state)
    var preview: = preview_deployment(game_state, {"kind": "unit", "index": unit_index}, target_region_id, "garrison")
    if not bool(preview.get("available", false)):
        return {"ok": false, "message": str(preview.get("reason", "无法调动部队。"))}
    var unit: Dictionary = game_state.bianwu_units[unit_index]
    var from_id: = str(unit.get("region_id", ""))
    var road: = _road_between(game_state, from_id, target_region_id)
    var grain_cost: = int(preview.get("grain_cost", 0))
    game_state.city["liangcao"] = int(game_state.city.get("liangcao", 0)) - grain_cost
    _spend_action_point(game_state)
    unit["region_id"] = target_region_id
    unit["morale"] = maxi(0, int(unit.get("morale", 65)) - (5 if str(road.get("status", "open")) == "blocked" else 2))

    var target_region: = _region(game_state, target_region_id)
    unit["order"] = "对峙" if stronghold_holder(target_region) == "rebel" else "移防"
    game_state.bianwu_units[unit_index] = unit
    return {"ok": true, "message": "部队已奉令移防。"}

static func relieve_region(game_state: Node, region_id: String, grain_cost: int = 100, free_command: bool = false) -> Dictionary:
    if not is_bianwu(game_state):
        return {"ok": false, "message": "仅边务路线可以赈济防区。"}
    ensure_initialized(game_state)
    var idx: = _region_index(game_state, region_id)
    if idx < 0:
        return {"ok": false, "message": "未找到目标地区。"}
    if not free_command and int(game_state.action_points) < 1:
        return {"ok": false, "message": "本月行动力已用尽。"}
    if int(game_state.city.get("liangcao", 0)) < grain_cost:
        return {"ok": false, "message": "粮草不足，无法赈济。"}
    game_state.city["liangcao"] = int(game_state.city.get("liangcao", 0)) - grain_cost
    if not free_command:
        _spend_action_point(game_state)
    var region: Dictionary = game_state.bianwu_defense_regions[idx]
    region["stability"] = mini(100, int(region.get("stability", 60)) + 8)
    region["problem"] = ""
    game_state.bianwu_defense_regions[idx] = region
    return {"ok": true, "message": "赈粮已经发到地方。"}

static func assign_officer(game_state: Node, officer_index: int, region_id: String) -> Dictionary:
    if not is_bianwu(game_state) or officer_index < 0 or officer_index >= game_state.bianwu_defense_officers.size():
        return {"ok": false, "message": "未找到可派驻的人物。"}
    var officer: Dictionary = game_state.bianwu_defense_officers[officer_index]
    var slot_kind: = officer_slot_kind(officer)
    if slot_kind.is_empty():
        return {"ok": false, "message": "该人物没有可用的调派槽位。"}
    return assign_officer_to_slot(game_state, officer_index, region_id, slot_kind)

static func officer_slot_kind(officer: Dictionary) -> String:
    var officer_id: = str(officer.get("id", ""))
    var name: = str(officer.get("name", ""))
    var specialty: = str(officer.get("specialty", ""))
    if officer_id == "bw_officer_qinbing" or name == "世家亲随" or specialty == "统带家丁":
        return "qinshui"
    if officer_id == "bw_officer_liangtai" or name == "粮台书办" or specialty == "转运粮饷":
        return "shuban"
    return ""

static func has_officer_in_slot(game_state: Node, region_id: String, slot_kind: String) -> bool:
    if not is_bianwu(game_state):
        return false
    for officer in game_state.bianwu_defense_officers:
        if officer is Dictionary and str(officer.get("region_id", "")) == region_id and officer_slot_kind(officer) == slot_kind:
            return true
    return false

static func apply_monthly_officer_effects(game_state: Node) -> Dictionary:
    if not is_bianwu(game_state):
        return {}
    ensure_initialized(game_state)
    var qinshui_regions: = 0
    for idx in range(game_state.bianwu_defense_regions.size()):
        var region: Dictionary = game_state.bianwu_defense_regions[idx]
        if not has_officer_in_slot(game_state, str(region.get("id", "")), "qinshui"):
            continue
        region["stability"] = mini(100, int(region.get("stability", 60)) + QINSHUI_MONTHLY_STABILITY)
        game_state.bianwu_defense_regions[idx] = region
        qinshui_regions += 1
    return {"qinshui_regions": qinshui_regions}

static func assign_officer_to_slot(game_state: Node, officer_index: int, target_region_id: String, target_slot: String, replace_existing: bool = false) -> Dictionary:
    if not is_bianwu(game_state):
        return {"ok": false, "message": "仅边务路线可以调派人物。"}
    if officer_index < 0 or officer_index >= game_state.bianwu_defense_officers.size():
        return {"ok": false, "message": "未找到可派驻的人物。"}
    if _region_index(game_state, target_region_id) < 0:
        return {"ok": false, "message": "未找到目标地区。"}
    var officer: Dictionary = game_state.bianwu_defense_officers[officer_index]
    if target_slot != "qinshui" and target_slot != "shuban":
        return {"ok": false, "message": "未知的人物调派槽位。"}
    if officer_slot_kind(officer) != target_slot:
        return {"ok": false, "message": "人物类型与调派槽位不符。"}
    var preview: = preview_deployment(game_state, {"kind": "officer", "index": officer_index, "replace_existing": replace_existing}, target_region_id, target_slot)
    if str(officer.get("region_id", "")) == target_region_id:
        if str(preview.get("reason", "")) != "人物已在本防区。":
            return {"ok": false, "message": str(preview.get("reason", "无法调派人物。"))}
        return {"ok": true, "message": "人物已在目标防区，无需重复调派。"}
    if not bool(preview.get("available", false)):
        return {"ok": false, "message": str(preview.get("reason", "无法调派人物。"))}
    var existing_index: = int(preview.get("existing_index", -1))
    var home_region_id: = default_region_id(game_state)
    if existing_index >= 0:
        var existing: Dictionary = game_state.bianwu_defense_officers[existing_index].duplicate(true)
        if home_region_id == target_region_id:
            home_region_id = str(officer.get("region_id", ""))
        existing["region_id"] = home_region_id
        game_state.bianwu_defense_officers[existing_index] = existing
    officer = officer.duplicate(true)
    officer["region_id"] = target_region_id
    game_state.bianwu_defense_officers[officer_index] = officer
    _spend_action_point(game_state)
    return {"ok": true, "message": "人物已经派驻。"}

static func assign_deployment(game_state: Node, payload: Dictionary, target_region_id: String, target_slot: String) -> Dictionary:
    var payload_kind: = str(payload.get("kind", payload.get("type", "")))
    if target_slot == "garrison":
        if payload_kind != "unit":
            return {"ok": false, "message": "驻军槽位只能调派部队。"}
        return move_unit(game_state, int(payload.get("index", payload.get("unit_index", -1))), target_region_id)
    if target_slot == "qinshui" or target_slot == "shuban":
        if payload_kind != "officer":
            return {"ok": false, "message": "人物槽位只能调派人物。"}
        return assign_officer_to_slot(game_state, int(payload.get("index", payload.get("officer_index", -1))), target_region_id, target_slot, bool(payload.get("replace_existing", false)))
    return {"ok": false, "message": "未知的调派槽位。"}

static func add_officer(game_state: Node, definition: Dictionary) -> bool:
    if not is_bianwu(game_state):
        return false
    var officer: = definition.duplicate(true)
    var officer_id: = str(officer.get("id", ""))
    if officer_id == "":
        return false
    for existing in game_state.bianwu_defense_officers:
        if str(existing.get("id", "")) == officer_id:
            return false
    officer["loyalty"] = clampi(int(officer.get("loyalty", 55)), 0, 100)
    officer["region_id"] = str(officer.get("region_id", default_region_id(game_state)))
    officer["assigned_unit_id"] = str(officer.get("assigned_unit_id", ""))
    game_state.bianwu_defense_officers.append(officer)
    return true

static func add_region_stability(game_state: Node, region_id: String, amount: int) -> bool:
    if not is_bianwu(game_state):
        return false
    var idx: = _region_index(game_state, region_id)
    if idx < 0:
        return false
    var region: Dictionary = game_state.bianwu_defense_regions[idx]
    region["stability"] = clampi(int(region.get("stability", 60)) + amount, 0, 100)
    game_state.bianwu_defense_regions[idx] = region
    return true

static func advance_enemy_entities(game_state: Node) -> void :
    if not is_bianwu(game_state):
        return
    ensure_initialized(game_state)
    var game_data: = _game_data()
    var act_config: Dictionary = game_data.ACT_CONFIG if game_data != null else {}
    var act_month: = (int(game_state.year) - int(act_config.get(str(_current_act(game_state)), {}).get("startYear", game_state.year))) * 12 + int(game_state.month)
    if _current_act(game_state) == 1 and act_month >= 3 and game_state.bianwu_defense_enemies.is_empty():

        var bandits: = {"id": "bw1_bandits", "name": "山匪", "type": "山匪", "size": 20, "region_id": "bw1_dunbao", "target_region_id": "bw1_baihusuo", "route": ["bw1_baihusuo", "bw1_juntun"], "route_index": 0, "spawn_month_index": act_month, "status": "正在南下", "settled": false}
        game_state.bianwu_defense_enemies.append(bandits)
        _enemy_arrive(game_state, 0, "bw1_dunbao")
    for idx in range(game_state.bianwu_defense_enemies.size()):
        var enemy: Dictionary = game_state.bianwu_defense_enemies[idx]
        if int(enemy.get("spawn_month_index", -1)) == act_month:
            continue

        enemy["size"] = int(enemy.get("size", 20)) + maxi(2, int(enemy.get("size", 20)) / 10)
        var here: = str(enemy.get("region_id", ""))


        if region_has_units(game_state, here):
            add_region_stability(game_state, here, -2)
            var total: = region_cell_total(game_state, here)
            if enemy_red_cells(game_state, here) >= total - 1 and not game_state.has_meta(PENDING_BATTLE_META):
                game_state.set_meta(PENDING_BATTLE_META, {"region_id": here, "initiator": "enemy"})
                enemy["status"] = "倾巢来攻"
            else:
                enemy["status"] = "蚕食乡野，步步进逼"
            game_state.bianwu_defense_enemies[idx] = enemy
            continue

        if bool(enemy.get("settled", false)):
            game_state.bianwu_defense_enemies[idx] = enemy
            continue
        var target: = str(enemy.get("target_region_id", ""))
        if target != "" and not _road_between(game_state, here, target).is_empty():
            game_state.bianwu_defense_enemies[idx] = enemy
            _enemy_arrive(game_state, idx, target)
        else:
            game_state.bianwu_defense_enemies[idx] = enemy



static func _enemy_arrive(game_state: Node, enemy_index: int, region_id: String) -> void :
    if enemy_index < 0 or enemy_index >= game_state.bianwu_defense_enemies.size():
        return
    var enemy: Dictionary = game_state.bianwu_defense_enemies[enemy_index]
    enemy["region_id"] = region_id
    var region_idx: = _region_index(game_state, region_id)
    if region_idx < 0:
        game_state.bianwu_defense_enemies[enemy_index] = enemy
        return
    var region: Dictionary = game_state.bianwu_defense_regions[region_idx]
    if region_has_units(game_state, region_id):
        enemy["status"] = "蚕食乡野，步步进逼"
        add_region_stability(game_state, region_id, -3)
    elif region_fortified(region):
        enemy["settled"] = true
        enemy["target_region_id"] = ""
        enemy["status"] = "据%s盘踞" % str(region.get("name", "据点"))
        region["stronghold_holder"] = "rebel"
        region["control"] = "enemy"
        region["lost_months"] = 0
        game_state.bianwu_defense_regions[region_idx] = region
        add_region_stability(game_state, region_id, -6)
    else:
        enemy["status"] = "正在劫掠"
        add_region_stability(game_state, region_id, -6)
        var route: Array = enemy.get("route", [])
        var route_index: = int(enemy.get("route_index", 0)) + 1
        enemy["route_index"] = route_index
        if route_index < route.size():
            enemy["target_region_id"] = str(route[route_index])
            enemy["status"] = "正在向%s移动" % _region_name(game_state, str(route[route_index]))
        else:

            enemy["settled"] = true
            enemy["target_region_id"] = ""
            enemy["status"] = "盘踞乡野"
            region["stronghold_holder"] = "rebel"
            region["control"] = "enemy"
            region["lost_months"] = 0
            game_state.bianwu_defense_regions[region_idx] = region
    game_state.bianwu_defense_enemies[enemy_index] = enemy



static func battle_context(game_state: Node, region_id: String, initiator: String) -> Dictionary:
    var region: = _region(game_state, region_id)
    var fortified: = region_fortified(region)
    var holder: = stronghold_holder(region)
    if fortified and holder == "rebel" and initiator == "player":
        return {"type": "攻坚战", "advantage": "enemy", "desc": "贼据垒而守，我军仰攻，敌得地利。"}
    if fortified and holder == "player" and initiator == "enemy":
        return {"type": "守城战", "advantage": "player", "desc": "我军凭垒而守，得地利。"}
    return {"type": "野战", "advantage": "none", "desc": "两军野地相搏，无地利可恃。"}

static func preview_assault(game_state: Node, region_id: String) -> Dictionary:
    var result: = {"available": false, "reason": ""}
    if not is_bianwu(game_state):
        result.reason = "仅边务路线可以兴兵。"
        return result
    if enemy_in_region(game_state, region_id).is_empty():
        result.reason = "此地并无贼踪。"
        return result
    if game_state.has_meta(PENDING_BATTLE_META):
        result.reason = "敌军已倾巢来攻，先应战再言进剿。"
        return result
    if not region_has_units(game_state, region_id) and not _has_units_adjacent(game_state, region_id):
        result.reason = "本防区及接界防区皆无我军兵马。"
        return result
    if int(game_state.action_points) < 1:
        result.reason = "本月行动力已用尽。"
        return result
    result.available = true
    return result

static func _has_units_adjacent(game_state: Node, region_id: String) -> bool:
    for unit in game_state.bianwu_units:
        if not unit is Dictionary:
            continue
        var from_id: = str(unit.get("region_id", ""))
        if from_id == region_id:
            continue
        var road: = _road_between(game_state, from_id, region_id)
        if not road.is_empty() and str(road.get("status", "open")) != "cut":
            return true
    return false


static func muster_candidates(game_state: Node, region_id: String) -> Array:
    var candidates: Array = []
    for index in range(game_state.bianwu_units.size()):
        var unit = game_state.bianwu_units[index]
        if not unit is Dictionary:
            continue
        var from_id: = str(unit.get("region_id", ""))
        var in_region: = from_id == region_id
        var adjacent: = false
        if not in_region:
            var road: = _road_between(game_state, from_id, region_id)
            adjacent = not road.is_empty() and str(road.get("status", "open")) != "cut"
        if in_region or adjacent:
            candidates.append({"index": index, "unit": unit, "in_region": in_region})
    return candidates


static func muster_officers(game_state: Node, region_id: String) -> Array:
    var officers: Array = []
    for index in range(game_state.bianwu_defense_officers.size()):
        var officer: Dictionary = game_state.bianwu_defense_officers[index]
        if officer_slot_kind(officer) == "qinshui":
            officers.append({"index": index, "officer": officer})
    return officers



static func begin_assault(game_state: Node, region_id: String, unit_card_ids: Array = [], with_officer: bool = false) -> Dictionary:
    var preview: = preview_assault(game_state, region_id)
    if not bool(preview.get("available", false)):
        return {"ok": false, "message": str(preview.get("reason", "无法兴兵。"))}
    if unit_card_ids.is_empty():
        return {"ok": false, "message": "须至少点选一支出战部队。"}
    _spend_action_point(game_state)
    return {"ok": true, "config": build_battle_config(game_state, region_id, "player", unit_card_ids, with_officer), "participants": unit_card_ids}

static func build_battle_config(game_state: Node, region_id: String, initiator: String, unit_card_ids: Array = [], with_officer: bool = false) -> Dictionary:
    var context: = battle_context(game_state, region_id, initiator)
    var enemy: = enemy_in_region(game_state, region_id)
    var advantage: = str(context.get("advantage", "none"))
    var wulue: = int(game_state.stats.get("wulue", 50))
    if advantage == "player":
        wulue += 10
    elif advantage == "enemy":
        wulue -= 10
    if with_officer:
        wulue += 8
    var roster: Array = []
    for unit in game_state.bianwu_units:
        if not unit is Dictionary:
            continue
        if unit_card_ids.is_empty():
            if str(unit.get("region_id", "")) == region_id:
                roster.append(unit.duplicate(true))
        elif unit_card_ids.has(str(unit.get("deployment_card_id", ""))):
            roster.append(unit.duplicate(true))
    return {
        "title": "%s·%s" % [_region_name(game_state, region_id), str(context.get("type", "野战"))], 
        "terrain": "plain", 
        "objective": {"type": "annihilate"}, 
        "player_units": roster, 
        "enemy_units": _enemy_roster(enemy), 
        "wulue": clampi(wulue, 1, 100), 
        "battle_context": {"region_id": region_id, "initiator": initiator, "type": str(context.get("type", "野战"))}, 
    }

static func _enemy_roster(enemy: Dictionary) -> Array:
    var size: = maxi(int(enemy.get("size", 20)), 10)
    var count: = clampi(int(ceil(float(size) / 12.0)), 1, 5)
    var pool: = ["knife_shield", "bow", "spear"]
    var roster: Array = []
    for index in range(count):
        roster.append(pool[index % pool.size()])
    return roster



static func resolve_battle(game_state: Node, region_id: String, initiator: String, grade: String, participant_card_ids: Array = []) -> Dictionary:
    if not is_bianwu(game_state):
        return {}
    if game_state.has_meta(PENDING_BATTLE_META):
        game_state.remove_meta(PENDING_BATTLE_META)
    var participants: = participant_card_ids.duplicate()
    if participants.is_empty():
        for unit in game_state.bianwu_units:
            if unit is Dictionary and str(unit.get("region_id", "")) == region_id:
                participants.append(str(unit.get("deployment_card_id", "")))
    var region_idx: = _region_index(game_state, region_id)
    var summary: = {"grade": grade, "region_id": region_id, "message": ""}
    var victory: = grade == "great" or grade == "pyrrhic"
    if victory:
        var kept: Array = []
        for enemy in game_state.bianwu_defense_enemies:
            if not (enemy is Dictionary and str(enemy.get("region_id", "")) == region_id):
                kept.append(enemy)
        game_state.bianwu_defense_enemies = kept
        if region_idx >= 0:
            var region: Dictionary = game_state.bianwu_defense_regions[region_idx]
            region["stronghold_holder"] = "player"
            region["control"] = "player"
            region["fallen"] = false
            region["lost_months"] = 0
            region["problem"] = ""
            region["stability"] = clampi(int(region.get("stability", 60)) + (8 if grade == "great" else 4), 0, 100)
            game_state.bianwu_defense_regions[region_idx] = region
        _apply_battle_losses(game_state, participants, 0.05 if grade == "great" else 0.25, 8 if grade == "great" else 0)
        summary.message = "官军克复%s，贼众溃散。" % _region_name(game_state, region_id)
    else:

        _destroy_units(game_state, participants)
        var enemy: = enemy_in_region(game_state, region_id)
        if not enemy.is_empty():
            enemy["size"] = int(enemy.get("size", 20)) + 5
            enemy["status"] = "气焰更炽"
        if region_idx >= 0:
            var region: Dictionary = game_state.bianwu_defense_regions[region_idx]

            if initiator == "enemy" and stronghold_holder(region) == "player" and region_fortified(region):
                region["stronghold_holder"] = "rebel"
                region["control"] = "enemy"
                region["lost_months"] = 0
                if not enemy.is_empty():
                    enemy["settled"] = true
                    enemy["status"] = "据%s盘踞" % str(region.get("name", "据点"))
            region["stability"] = clampi(int(region.get("stability", 60)) - 4, 0, 100)
            game_state.bianwu_defense_regions[region_idx] = region
        summary.message = "官军覆师，出战各部溃散殆尽。"
    return summary

static func _apply_battle_losses(game_state: Node, participant_card_ids: Array, hp_loss_ratio: float, morale_delta: int) -> void :
    for idx in range(game_state.bianwu_units.size()):
        var unit = game_state.bianwu_units[idx]
        if not unit is Dictionary or not participant_card_ids.has(str(unit.get("deployment_card_id", ""))):
            continue
        var entry: Dictionary = unit
        entry["hp"] = maxi(1, int(round(int(entry.get("hp", 0)) * (1.0 - hp_loss_ratio))))
        entry["morale"] = clampi(int(entry.get("morale", 65)) + morale_delta, 0, 100)
        game_state.bianwu_units[idx] = entry

static func _destroy_units(game_state: Node, participant_card_ids: Array) -> void :
    var kept: Array = []
    for unit in game_state.bianwu_units:
        if unit is Dictionary and participant_card_ids.has(str(unit.get("deployment_card_id", ""))):
            continue
        kept.append(unit)
    game_state.bianwu_units = kept

static func _region_name(game_state: Node, region_id: String) -> String:
    var idx: = _region_index(game_state, region_id)
    return str(game_state.bianwu_defense_regions[idx].get("name", "未知地区")) if idx >= 0 else "未知地区"

static func build_external_warnings(game_state: Node) -> void :
    if not is_bianwu(game_state):
        return
    game_state.bianwu_defense_warnings = []
    var spy_count: = 0
    for officer in game_state.bianwu_defense_officers:
        if str(officer.get("specialty", "")).contains("谍报"):
            spy_count += 1
    var game_data: = _game_data()
    var act_config: Dictionary = game_data.ACT_CONFIG if game_data != null else {}
    var act_month: = (int(game_state.year) - int(act_config.get(str(_current_act(game_state)), {}).get("startYear", game_state.year))) * 12 + int(game_state.month)
    if _current_act(game_state) == 1 and act_month >= 4:
        var text: = "北路有陌生人马靠近防区。"
        if spy_count > 0:
            text = "北路耳目来报，一股流寇可能于下月逼近北路墩堡。"
        game_state.bianwu_defense_warnings.append({"direction": "北路", "level": mini(3, spy_count + 1), "text": text})

static func process_month_end(game_state: Node) -> void :
    if not is_bianwu(game_state):
        return
    ensure_initialized(game_state)
    advance_enemy_entities(game_state)
    build_external_warnings(game_state)
    _advance_rebellion_states(game_state)
    for idx in range(game_state.bianwu_units.size()):
        var unit = game_state.bianwu_units[idx]
        if not unit is Dictionary:
            continue
        var entry: Dictionary = unit
        var region_idx: = _region_index(game_state, str(entry.get("region_id", "")))
        var stability: = 60
        var standoff: = false
        if region_idx >= 0:
            var unit_region: Dictionary = game_state.bianwu_defense_regions[region_idx]
            stability = int(unit_region.get("stability", 60))
            standoff = stronghold_holder(unit_region) == "rebel"
        if int(game_state.city.get("liangcao", 0)) <= 0 or int(game_state.city.get("xiangyin", 0)) <= 0:
            entry["supply"] = "短缺"
            entry["morale"] = maxi(0, int(entry.get("morale", 65)) - 6)
        elif stability >= 60:
            entry["supply"] = "充足"
            entry["morale"] = mini(100, int(entry.get("morale", 65)) + 2)
        else:
            entry["supply"] = "勉强"

        if standoff:
            entry["morale"] = maxi(0, int(entry.get("morale", 65)) - 2)
        game_state.bianwu_units[idx] = entry


static func _advance_rebellion_states(game_state: Node) -> void :
    for idx in range(game_state.bianwu_defense_regions.size()):
        var region: Dictionary = game_state.bianwu_defense_regions[idx]
        var region_id: = str(region.get("id", ""))
        if stronghold_holder(region) != "rebel":
            continue
        var enemy: = enemy_in_region(game_state, region_id)
        if region_has_units(game_state, region_id):

            game_state.bianwu_defense_regions[idx] = region
            continue
        region["lost_months"] = int(region.get("lost_months", 0)) + 1
        region["stability"] = clampi(int(region.get("stability", 60)) - 4, 0, 100)
        var enemy_size: = int(enemy.get("size", 0)) if not enemy.is_empty() else 0
        if not region_fallen(region) and (int(region["lost_months"]) >= FALLEN_MONTHS_THRESHOLD or enemy_size >= FALLEN_SIZE_THRESHOLD):
            region["fallen"] = true
            region["problem"] = "全域沦陷"
        if region_fallen(region):
            for road in game_state.bianwu_defense_roads:
                if not road is Dictionary:
                    continue
                var neighbor_id: = ""
                if str(road.get("from", "")) == region_id:
                    neighbor_id = str(road.get("to", ""))
                elif str(road.get("to", "")) == region_id:
                    neighbor_id = str(road.get("from", ""))
                if neighbor_id != "":
                    add_region_stability(game_state, neighbor_id, -3)
        game_state.bianwu_defense_regions[idx] = region
