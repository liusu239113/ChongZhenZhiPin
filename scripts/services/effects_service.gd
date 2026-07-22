extends RefCounted
class_name EffectsService

const BianwuDefenseServiceRef = preload("res://scripts/services/bianwu_defense_service.gd")

static func _without_personal_item_effects(game_state: Node, raw_effects: Dictionary) -> Dictionary:
    var filtered: = raw_effects.duplicate(true)
    if not (game_state.has_method("is_governance_mode") and game_state.is_governance_mode()):
        return filtered
    for key in ["wentao", "wulue", "lizheng", "tizhi"]:
        filtered.erase(key)
    return filtered

const TAG_ALIASES: = {
    "内廷欠账": "内庭牵连", 
    "内庭欠账": "内庭牵连", 
    "得罪士绅": "士绅龃龉", 
    "薅士绅": "士绅龃龉", 
    "士绅破财": "士绅龃龉", 
    "豪右结怨": "士绅龃龉", 
    "实务": "务实"
}

const INTERNAL_ROUTE_TAGS: = [
    "北靖封侯待决", 
    "摄政受命待决"
]

const PERSONAL_STAT_KEYS: = ["wentao", "wulue", "lizheng", "tizhi"]


const LINGWU_CONVERT_KEYS: = ["wentao", "wulue", "lizheng"]

static func grant_item_once(game_state: Node, item_id: String, suppress_state_changed: = false) -> bool:
    var normalized_id: = item_id.strip_edges()
    if normalized_id == "" or normalized_id in game_state.items:
        return false
    var item_def: Dictionary = GameData.ITEM_DEFS.get(normalized_id, {})
    if item_def.is_empty():
        return false
    game_state.items.append(normalized_id)
    var item_effects: Dictionary = _without_personal_item_effects(game_state, item_def.get("effects", {}))
    if not item_effects.is_empty():
        apply_effects_to_state(game_state, item_effects, suppress_state_changed)
    return true

static func normalize_tag_name(tag: Variant) -> String:
    var normalized: = str(tag).strip_edges()
    if normalized in INTERNAL_ROUTE_TAGS:
        return ""
    return TAG_ALIASES.get(normalized, normalized)

static func apply_effects_to_state(game_state: Node, effects: Dictionary, suppress_state_changed: = false) -> void :
    var stats_changed: = false
    var attitudes_changed: = false
    var city_changed: = false

    for key in effects:
        if key == "private_silver":
            game_state.private_silver = maxi(0, game_state.private_silver + effects[key])
        elif key == "lingwu":
            game_state.lingwu = maxi(0, int(game_state.lingwu) + int(effects[key]))
            stats_changed = true
        elif key in game_state.stats:
            game_state.apply_personal_stat_delta(str(key), int(effects[key]))
            stats_changed = true
        elif key in game_state.attitudes:
            if game_state.emperor_dead and (key == "shengjuan" or key == "zhongguan"):
                continue
            game_state.attitudes[key] = clampi(game_state.attitudes[key] + effects[key], 0, 100)
            attitudes_changed = true
        elif key in game_state.city:
            if GameData.CITY_STAT_KEYS.has(key):
                game_state.city[key] = clampi(game_state.city[key] + effects[key], 1, game_state.CITY_STAT_MAX_LEVEL)
            elif key == "yinliang":
                game_state.city[key] = game_state.city[key] + effects[key]
            elif key == "liangshi":
                game_state.city[key] = maxi(0, game_state.city[key] + effects[key])
            else:
                game_state.city[key] = maxi(0, game_state.city[key] + effects[key])
            if key == "jiading":
                _sync_bianwu_unit_hp(game_state, true, int(effects[key]))
            elif key == "guanjun":
                _sync_bianwu_unit_hp(game_state, false, int(effects[key]))
            city_changed = true

    if stats_changed and not suppress_state_changed:
        game_state.stats = game_state.stats.duplicate()
        game_state.state_changed.emit()
    if attitudes_changed and not suppress_state_changed:
        game_state.attitudes = game_state.attitudes.duplicate()
        game_state.state_changed.emit()
    if city_changed and not suppress_state_changed:
        game_state.city = game_state.city.duplicate()
        game_state.state_changed.emit()

static func add_tags_to_state(game_state: Node, new_tags: Array) -> void :
    for normalized_tag in normalize_choice_tags(new_tags):
        game_state.tags.append(normalized_tag)

static func normalize_choice_tags(tags: Array) -> Array:
    var normalized_tags: Array = []
    var seen: = {}
    for tag in tags:
        var normalized_tag: = normalize_tag_name(tag)
        if normalized_tag != "" and not seen.has(normalized_tag):
            seen[normalized_tag] = true
            normalized_tags.append(normalized_tag)
    return normalized_tags

static func apply_choice(game_state: Node, choice: Dictionary, choice_index: int) -> Dictionary:
    var current_event: Dictionary = {}
    var should_mark_sun_chuanting_split: = false
    if game_state.has_method("mark_sun_chuanting_branch_split") and game_state.has_method("get_current_event"):
        current_event = game_state.get_current_event()
        if game_state.has_method("is_governance_mode") and game_state.is_governance_mode() and int(game_state.current_month_card_index) >= 0:
            current_event = game_state.get_month_card_event(int(game_state.current_month_card_index))
        should_mark_sun_chuanting_split = str(current_event.get("id", "")) == "e5_5"
    var effects = _convert_personal_effects_to_lingwu(game_state, choice_effects_for_state(game_state, choice))
    var risk_modifier: Dictionary = choice.get("mutinyRiskModifier", {})
    if choice.has("setBingyong"):
        var target: = int(choice["setBingyong"])
        var current: = int(game_state.city.get("bingyong", 0)) if game_state.city else 0
        var delta: = target - current
        if delta != 0:
            effects = effects.duplicate(true)
            effects["bingyong"] = int(effects.get("bingyong", 0)) + delta
    var granted_items: Array[String] = []
    var granted_guozuo: Array[String] = []
    apply_effects_to_state(game_state, effects)

    if str(game_state.get("active_line")) == "bianwu":
        if choice.has("commandPoints"):
            BianwuDefenseServiceRef.add_command_points(game_state, int(choice.get("commandPoints", 0)))
        if choice.has("grantBianwuOfficer"):
            var officer_def = choice.get("grantBianwuOfficer", {})
            if officer_def is Dictionary:
                BianwuDefenseServiceRef.add_officer(game_state, officer_def)
        if choice.has("regionStability"):
            var stability_effect = choice.get("regionStability", {})
            if stability_effect is Dictionary:
                var region_id: = str(stability_effect.get("region_id", ""))
                if region_id == "" and not game_state.bianwu_defense_regions.is_empty():
                    region_id = str(game_state.bianwu_defense_regions[0].get("id", ""))
                BianwuDefenseServiceRef.add_region_stability(game_state, region_id, int(stability_effect.get("amount", 0)))
    if not risk_modifier.is_empty() and game_state.has_method("add_mutiny_risk_modifier"):
        game_state.add_mutiny_risk_modifier(risk_modifier)
    if str(current_event.get("caseCategory", "")) == "military_discipline" and game_state.has_method("mark_military_discipline_case_settled"):
        game_state.mark_military_discipline_case_settled()
    var merit_reward: = int(choice.get("meritReward", 0))
    if merit_reward != 0 and game_state.city and not game_state.city.is_empty():

        game_state.city["zhengji"] = maxi(0, int(game_state.city.get("zhengji", 0)) + merit_reward)
    var choice_tags: = normalize_choice_tags(choice.get("tags", []))
    add_tags_to_state(game_state, choice_tags)
    if choice.has("grantItem"):
        var item_id: = str(choice.get("grantItem", ""))
        if grant_item_once(game_state, item_id):
            granted_items.append(item_id)
    for extra_item_id in choice.get("grantItems", []):
        var eid: = str(extra_item_id)
        if grant_item_once(game_state, eid):
            granted_items.append(eid)



    if choice.has("grantUnits") and "bianwu_units" in game_state:
        var BattleTypesRef = load("res://scripts/battle/battle_types.gd")
        for uid in choice.get("grantUnits", []):
            var unit_id: = str(uid)
            if unit_id != "":
                BianwuDefenseServiceRef.grant_unit_group(game_state, unit_id, BattleTypesRef.unit_def(unit_id))
    if choice.has("upgradeUnit") and "bianwu_units" in game_state:
        var ups: Array = choice["upgradeUnit"] if typeof(choice["upgradeUnit"]) == TYPE_ARRAY else [choice["upgradeUnit"]]
        var BattleTypesRef = load("res://scripts/battle/battle_types.gd")
        for up in ups:
            if typeof(up) != TYPE_DICTIONARY:
                continue
            var from_id: = str(up.get("from", ""))
            var to_id: = str(up.get("to", ""))
            if to_id == "":
                continue
            var grouped_source: Dictionary = {}
            for entry in game_state.bianwu_units:
                if entry is Dictionary and str(entry.get("id", "")) == from_id and not str(entry.get("deployment_group_id", "")).is_empty():
                    grouped_source = entry
                    break
            if not grouped_source.is_empty():
                var grouped_unit_def: Dictionary = BattleTypesRef.unit_def(to_id)
                var target_definition: = BianwuDefenseServiceRef.unit_static_definition(grouped_source)
                for definition_key in grouped_unit_def:
                    target_definition[definition_key] = grouped_unit_def[definition_key]
                target_definition["id"] = to_id
                target_definition["name"] = str(grouped_unit_def.get("name", to_id))
                if BianwuDefenseServiceRef.upgrade_unit_group(game_state, from_id, target_definition):
                    continue
            var to_exists: = false
            for entry in game_state.bianwu_units:
                var entry_id = entry.get("id", "") if entry is Dictionary else str(entry)
                if entry_id == to_id:
                    to_exists = true
                    break
            if to_exists:
                continue
            var from_idx: = -1
            for i in range(game_state.bianwu_units.size()):
                var entry = game_state.bianwu_units[i]
                var entry_id = entry.get("id", "") if entry is Dictionary else str(entry)
                if entry_id == from_id:
                    from_idx = i
                    break
            if from_idx >= 0:
                var old_entry = game_state.bianwu_units[from_idx]
                if old_entry is Dictionary:
                    var new_entry = old_entry.duplicate()
                    new_entry["id"] = to_id
                    var unit_def: Dictionary = BattleTypesRef.unit_def(to_id)
                    if new_entry.get("name", "") == "长枪手" or new_entry.get("name", "") == "刀牌手" or new_entry.get("name", "") == "长枪兵" or new_entry.get("name", "") == "刀盾兵" or new_entry.get("name", "") == "家丁·刀牌手":
                        new_entry["name"] = unit_def.get("name", to_id)
                    game_state.bianwu_units[from_idx] = new_entry
                else:
                    game_state.bianwu_units[from_idx] = to_id
            else:
                game_state.bianwu_units.append(to_id)
    if choice.has("grantSkills") and "bianwu_skills" in game_state:
        for sk in choice.get("grantSkills", []):
            var skill_id: = str(sk)
            if skill_id != "" and skill_id not in game_state.bianwu_skills:
                game_state.bianwu_skills.append(skill_id)

    if choice.has("grantGuozuo") and game_state.has_method("add_guozuo_entry"):
        var guozuo_id: = str(choice.get("grantGuozuo", ""))
        if game_state.add_guozuo_entry(guozuo_id):
            granted_guozuo.append(guozuo_id)

    if choice.has("upgradeCardId"):
        var upgrade_id: = str(choice.get("upgradeCardId", "")).strip_edges()
        if upgrade_id != "" and not game_state.upgraded_governance_cards.has(upgrade_id):
            game_state.upgraded_governance_cards.append(upgrade_id)

    if choice.has("rankUp"):



        game_state.rank_index = max(game_state.rank_index, int(choice["rankUp"]))

    if choice.has("enterBranch"):
        var idx = choice.get("enterBranchIndex", 1) if typeof(choice.get("enterBranchIndex")) in [TYPE_INT, TYPE_FLOAT] else 1
        game_state.enter_branch(choice["enterBranch"], int(idx))

    if choice.has("queueBranch") and choice["queueBranch"] != "":
        var idx = choice.get("queueBranchIndex", 0) if typeof(choice.get("queueBranchIndex")) in [TYPE_INT, TYPE_FLOAT] else 0
        game_state.pending_events.push_back({"type": "branch", "branch": choice["queueBranch"], "index": int(idx)})

    if choice.has("exitBranch") and choice["exitBranch"]:
        game_state.branch = ""
        game_state.branch_index = 0
        if game_state.char_id == "hanmen":
            game_state.initialize_governance_city()
            game_state.month = 9
            game_state.year = 1
            game_state.action_points = game_state.monthly_action_points()
        game_state._base_age = 25
        game_state.current_event = 0
        game_state.state_changed.emit()

    if choice.has("clearBranchOnly") and choice["clearBranchOnly"]:
        game_state.branch = ""
        game_state.branch_index = 0
        game_state.state_changed.emit()

    if choice.has("enterGovernance") and choice["enterGovernance"]:
        game_state.branch = ""
        game_state.branch_index = 0
        game_state.pending_events.clear()

        if GameData.active_line != "bianwu" and game_state.keju_status not in ["zhuangyuan", "bangyan", "tanhua", "erjia", "sanjia", "jinshi", "juren", "gongshi"]:
            game_state.keju_status = "jinshi"
        var governance_entry: Dictionary = game_state.get_initial_governance_entry()
        game_state.initialize_governance_city(int(governance_entry.get("city_act", 1)))
        game_state.month = int(choice.get("governanceStartMonth", 6))
        game_state.transitioning_to_governance = true
        game_state.year = int(governance_entry.get("start_year", 1))
        game_state.action_points = game_state.monthly_action_points()
        game_state._base_age = int(choice.get("governanceBaseAge", 25))
        game_state.current_event = 0
        game_state.state_changed.emit()

    if choice.has("startKeju") and choice["startKeju"]:
        game_state.keju_status = "tongshi_prep"

    if choice.has("setKejuStatus"):
        game_state.keju_status = choice["setKejuStatus"]
        game_state.keju_year = game_state.get_czYear()
        if game_state.has_method("get_current_year_str"):
            game_state.keju_year_str = game_state.get_current_year_str()

    if choice.has("addAge"):
        var amt = int(choice["addAge"])
        for i in range(amt):
            game_state._base_age += 1
            if game_state.has_method("_check_keju_trigger"):
                game_state._check_keju_trigger(game_state._base_age)

    if choice.has("jumpToAge"):
        var target_age = int(choice["jumpToAge"])
        if game_state._base_age < target_age:
            var amt = target_age - game_state._base_age
            for i in range(amt):
                game_state._base_age += 1

            game_state.state_changed.emit()

    if choice.has("enterPrison") and choice["enterPrison"]:
        game_state.enter_prison()

    if choice.has("exitPrison") and choice["exitPrison"]:
        game_state.exit_prison()

    if choice.has("emperorDead") and choice["emperorDead"]:
        game_state.emperor_dead = true
        game_state.attitudes["shengjuan"] = 50
        game_state.attitudes["zhongguan"] = 50

    if choice.has("branchChoice"):
        game_state.last_branch_choice = str(choice.get("branchChoice", ""))

    if should_mark_sun_chuanting_split:
        game_state.mark_sun_chuanting_branch_split()


    if choice.has("special") and typeof(choice["special"]) == TYPE_DICTIONARY:
        var special: Dictionary = choice["special"]

        if bool(special.get("grant_honorary", false)) and game_state.has_method("grant_honorary_title"):
            game_state.grant_honorary_title()

        if special.has("salary_penalty_months"):
            game_state.salary_penalty_months = int(special["salary_penalty_months"])

        if special.has("living_shrine"):
            game_state.living_shrine = bool(special["living_shrine"])
        game_state.state_changed.emit()

    if game_state.has_method("record_life_choice"):
        game_state.record_life_choice(current_event, choice, choice_index)

    if game_state.has_method("record_term_choice"):
        game_state.record_term_choice(current_event, choice)

    game_state.showing_result = true
    game_state.last_choice_index = choice_index
    game_state._last_choice = choice

    return {
        "effects": _effects_with_merit_reward(effects, merit_reward), 
        "tags": choice_tags, 
        "granted_items": granted_items, 
        "granted_guozuo": granted_guozuo, 
        "ending_key": choice.get("endingKey", choice.get("triggerEnding", "")), 
        "system_comment": choice.get("systemComment", choice.get("comment", "")), 
    }

static func _normalized_choice_effects(choice: Dictionary) -> Dictionary:
    var effects: Dictionary = choice.get("effects", {})
    var title: = str(choice.get("title", ""))
    if title.contains("亲授农技安置") and int(effects.get("nongsang", 0)) == 3:
        var normalized: = effects.duplicate(true)
        normalized["nongsang"] = 2
        return normalized
    return effects

static func choice_effects_for_state(game_state: Node, choice: Dictionary) -> Dictionary:
    var effects: Dictionary = _normalized_choice_effects(choice).duplicate(true)
    if str(game_state.get("active_line")) not in ["", "hanmen"]:
        return effects
    var risk_modifier: Dictionary = choice.get("mutinyRiskModifier", {})
    if not risk_modifier.is_empty():
        effects["mutiny_risk"] = int(risk_modifier.get("points", 0))
    var levy: Dictionary = choice.get("dynamicCourtLevy", {})
    if levy.is_empty():
        return effects
    var rate_percent: = clampi(int(levy.get("ratePercent", 100)), 0, 100)
    var base_costs: Dictionary = levy.get("baseCosts", {})
    for key in base_costs:
        if key not in ["yinliang", "liangshi"] or not game_state.city.has(key):
            continue
        var base_cost: = maxi(0, int(base_costs[key]))
        var current_amount: = maxi(0, int(game_state.city.get(key, 0)))
        var dynamic_full: = maxi(base_cost, int(floor(float(current_amount) * 0.7)))
        var actual_cost: = int(floor(float(dynamic_full) * float(rate_percent) / 100.0))
        effects[key] = - actual_cost
    return effects

static func _convert_personal_effects_to_lingwu(game_state: Node, effects: Dictionary) -> Dictionary:
    if effects.is_empty():
        return effects
    if str(game_state.get("active_line")) != "hanmen":
        return effects
    var converted: = effects.duplicate(true)
    var lingwu_delta: = 0
    for key in LINGWU_CONVERT_KEYS:
        if not converted.has(key):
            continue
        lingwu_delta += int(converted[key])
        converted.erase(key)
    if lingwu_delta != 0:
        converted["lingwu"] = int(converted.get("lingwu", 0)) + lingwu_delta
    return converted

static func _effects_with_merit_reward(effects: Dictionary, merit_reward: int) -> Dictionary:
    if merit_reward == 0:
        return effects
    var merged: = effects.duplicate(true)
    merged["zhengji"] = int(merged.get("zhengji", 0)) + merit_reward
    return merged

static func _sync_bianwu_unit_hp(game_state: Node, is_jd: bool, delta: int) -> void :
    if not BianwuDefenseServiceRef.is_bianwu(game_state) or not "bianwu_units" in game_state:
        return
    var BattleTypesRef = load("res://scripts/battle/battle_types.gd")
    var BIANWU_FORCE_CARD_CAP: = 10000
    var entries: Array = game_state.bianwu_units
    for i in range(entries.size()):
        var entry = entries[i]
        if not entry is Dictionary:
            var unit_id: = str(entry)
            var unit_def: Dictionary = BattleTypesRef.unit_def(unit_id)
            game_state.bianwu_units[i] = {
                "id": unit_id, 
                "hp": int(unit_def.get("hp", 0)), 
                "cap": BIANWU_FORCE_CARD_CAP, 
                "level": 1, 
                "name": str(unit_def.get("name", unit_id)), 
                "is_jiading": false
            }
    BianwuDefenseServiceRef.normalize_unit_cards(game_state)
    for entry in game_state.bianwu_units:
        if entry is Dictionary and bool(entry.get("is_jiading", false)) == is_jd:
            var group_key: = BianwuDefenseServiceRef.unit_group_key(entry)
            BianwuDefenseServiceRef.add_unit_group_hp(game_state, group_key, delta)
            return
    if "bianwu_unit_group_defs" in game_state:
        for persisted_group_key in game_state.bianwu_unit_group_defs:
            var persisted_definition: Dictionary = game_state.bianwu_unit_group_defs[persisted_group_key]
            if bool(persisted_definition.get("is_jiading", false)) == is_jd:
                BianwuDefenseServiceRef.add_unit_group_hp(game_state, persisted_group_key, delta)
                return
    var unit_id: = "knife_shield" if is_jd else "spear"
    var unit_def: Dictionary = BattleTypesRef.unit_def(unit_id)
    var unit_template: = {
        "id": unit_id, 
        "cap": 500 if is_jd else BIANWU_FORCE_CARD_CAP, 
        "level": 1, 
        "name": str(unit_def.get("name", unit_id)), 
        "is_jiading": is_jd, 
    }
    var group_key: = "unit:%s:%d" % [unit_id, int(is_jd)]
    BianwuDefenseServiceRef.add_unit_group_hp(game_state, group_key, delta, unit_template)
