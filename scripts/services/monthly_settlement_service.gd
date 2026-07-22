extends RefCounted
class_name MonthlySettlementService

const BattleTypesRef = preload("res://scripts/battle/battle_types.gd")
const PersonalStatCapstoneServiceRef = preload("res://scripts/services/personal_stat_capstone_service.gd")
const BianwuDefenseServiceRef = preload("res://scripts/services/bianwu_defense_service.gd")



static func _bianwu_has_unit_tag(game_state: Node, tag: String) -> bool:
    if not ("bianwu_units" in game_state):
        return false
    for u in game_state.bianwu_units:
        if u is Dictionary:
            var uid: = str(u.get("id", ""))
            if BattleTypesRef.UNITS.has(uid) and BattleTypesRef.UNITS[uid].get("tags", []).has(tag):
                return true
    return false








static func apply_carried_item_city_effects(game_state: Node) -> int:
    if game_state.city.is_empty():
        return 0


    for key in game_state.applied_carried_city_effects:
        if game_state.city.has(key):
            var current_val = int(game_state.city[key])
            game_state.city[key] = max(1, current_val - int(game_state.applied_carried_city_effects[key]))


    var new_effects: = {}
    for item_id in game_state.get_city_boost_item_ids():
        var item_def: Dictionary = GameData.ITEM_DEFS.get(str(item_id), {})
        var city_effects: Dictionary = item_def.get("cityEffects", {})
        for raw_key in city_effects:
            var key: = str(raw_key)
            if not GameData.CITY_STAT_KEYS.has(key):
                continue
            new_effects[key] = int(new_effects.get(key, 0)) + int(city_effects[raw_key])


    game_state.applied_carried_city_effects.clear()
    for key in new_effects:
        var old_level: = int(game_state.city.get(key, 1))
        var new_level: = clampi(old_level + new_effects[key], 1, game_state.CITY_STAT_MAX_LEVEL)
        game_state.city[key] = new_level
        game_state.applied_carried_city_effects[key] = new_effects[key]

    if not game_state.city.has("zhengji"):
        game_state.city["zhengji"] = 0
    return 0

static func update_monthly_breakdowns(game_state: Node) -> void :
    if game_state.city.is_empty():
        game_state.monthly_grain_breakdown.clear()
        game_state.monthly_silver_breakdown.clear()
        return

    if GameData.active_line == "bianwu":
        _update_bianwu_breakdowns(game_state)
        return

    var nongsang_lv = game_state.get_city_stat_level("nongsang")
    var shangmao_lv = game_state.get_city_stat_level("shangmao")
    var baigong_lv = game_state.get_city_stat_level("baigong")
    var wenjiao_lv = game_state.get_city_stat_level("wenjiao")
    var renkou_val = game_state.city.get("renkou_val", 0)
    var bingyong = game_state.city.get("bingyong", 0)

    var grain_production = game_state._city_stat_grain_output(nongsang_lv)
    var poll_tax = int(renkou_val * 0.01)
    var commerce_tax = game_state._city_stat_silver_output(shangmao_lv, "shangmao")
    commerce_tax += game_state._city_stat_silver_output(baigong_lv, "baigong")

    game_state.monthly_grain_breakdown.clear()
    game_state.monthly_grain_breakdown.append({"label": "农桑基础产出", "value": grain_production})
    var baigong_grain = game_state._baigong_grain_output(baigong_lv)
    if baigong_grain > 0:
        game_state.monthly_grain_breakdown.append({"label": "百工辅助产粮", "value": baigong_grain})

    game_state.monthly_silver_breakdown.clear()
    if poll_tax > 0:
        game_state.monthly_silver_breakdown.append({"label": "人丁丁银", "value": poll_tax})
    game_state.monthly_silver_breakdown.append({"label": "商贸与百工税赋", "value": commerce_tax})
    var wenjiao_silver = game_state._wenjiao_silver_output(wenjiao_lv)
    if wenjiao_silver > 0:
        game_state.monthly_silver_breakdown.append({"label": "文教收入", "value": wenjiao_silver})
    if PersonalStatCapstoneServiceRef.is_active(game_state, "lizheng"):
        game_state.monthly_silver_breakdown.append({
            "label": "理政满值", 
            "value": PersonalStatCapstoneServiceRef.LIZHENG_YINLIANG_BONUS, 
        })

    var bingyong_cost_grain = bingyong
    var bingyong_cost_silver = int(bingyong * 0.5)

    game_state.monthly_grain_breakdown.append({"label": "兵勇耗粮", "value": - bingyong_cost_grain})

    var monthly_grain_pressure: = int(game_state.city.get("liangshi_monthly_pressure", 0))
    if monthly_grain_pressure != 0:
        game_state.monthly_grain_breakdown.append({"label": "战乱转运损耗", "value": monthly_grain_pressure})

    var special_items = game_state._process_special_items_monthly()
    game_state.monthly_grain_breakdown.append_array(special_items["grain_breakdowns"])
    game_state.monthly_silver_breakdown.append_array(special_items["silver_breakdowns"])



    var grain_income_base: = 0
    for entry in game_state.monthly_grain_breakdown:
        var v: = int(entry.get("value", 0))
        if v > 0:
            grain_income_base += v
    if grain_income_base > 0:
        for item_id in game_state.get_city_boost_item_ids():
            var pct_def: Dictionary = GameData.ITEM_DEFS.get(str(item_id), {})
            var grain_pct: = int(pct_def.get("statusEffects", {}).get("liangshi_percent", 0))
            if grain_pct == 0:
                continue
            var bonus: = int(floor(grain_income_base * grain_pct / 100.0))
            if bonus != 0:
                game_state.monthly_grain_breakdown.append({
                    "label": str(pct_def.get("name", item_id)), 
                    "value": bonus, 
                })



    var silver_income_base: = 0
    for entry in game_state.monthly_silver_breakdown:
        var sv: = int(entry.get("value", 0))
        if sv > 0:
            silver_income_base += sv
    if silver_income_base > 0:
        for item_id in game_state.get_city_boost_item_ids():
            var pct_def: Dictionary = GameData.ITEM_DEFS.get(str(item_id), {})
            var silver_pct: = int(pct_def.get("statusEffects", {}).get("yinliang_percent", 0))
            if silver_pct == 0:
                continue
            var silver_bonus: = int(floor(silver_income_base * silver_pct / 100.0))
            if silver_bonus != 0:
                game_state.monthly_silver_breakdown.append({
                    "label": str(pct_def.get("name", item_id)), 
                    "value": silver_bonus, 
                })

    game_state.monthly_silver_breakdown.append({"label": "兵勇军饷", "value": - bingyong_cost_silver})

    game_state._append_sanxiang_breakdown()




const BIANWU_LIANGCAO_PER_HOUQIN: = 200
const BIANWU_XIANGYIN_PER_HOUQIN: = 80
const BIANWU_MAIPI_PER_MAZHENG: = 10
const BIANWU_HUOQI_PER_BINGGONG: = 12


const BIANWU_LIANGCAO_PER_SOLDIER: = 1.0
const BIANWU_XIANGYIN_PER_SOLDIER: = 0.5


static func _bianwu_total_soldiers(game_state: Node) -> int:
    if not ("bianwu_units" in game_state):
        return 0
    var total: = 0
    for u in game_state.bianwu_units:
        if u is Dictionary:
            total += int(u.get("hp", 0))
    return total

static func _update_bianwu_breakdowns(game_state: Node) -> Dictionary:
    game_state.monthly_grain_breakdown.clear()
    game_state.monthly_silver_breakdown.clear()
    var supply: = BianwuDefenseServiceRef.append_supply_breakdowns(game_state)
    var houqin_lv: int = game_state.get_city_stat_level("houqin")
    var liangcao_gain: int = houqin_lv * BIANWU_LIANGCAO_PER_HOUQIN
    var xiangyin_gain: int = houqin_lv * BIANWU_XIANGYIN_PER_HOUQIN
    if liangcao_gain > 0:
        game_state.monthly_grain_breakdown.append({"label": "后勤转运", "value": liangcao_gain})
    if xiangyin_gain > 0:
        game_state.monthly_silver_breakdown.append({"label": "后勤筹饷", "value": xiangyin_gain})

    var soldiers: int = _bianwu_total_soldiers(game_state)
    var liangcao_cost: int = int(soldiers * BIANWU_LIANGCAO_PER_SOLDIER)
    var xiangyin_cost: int = int(soldiers * BIANWU_XIANGYIN_PER_SOLDIER)
    if liangcao_cost > 0:
        game_state.monthly_grain_breakdown.append({"label": "军中口粮", "value": - liangcao_cost})
    if xiangyin_cost > 0:
        game_state.monthly_silver_breakdown.append({"label": "士卒月饷", "value": - xiangyin_cost})
    return supply

static func _process_bianwu_monthly(game_state: Node) -> void :
    BianwuDefenseServiceRef.apply_monthly_officer_effects(game_state)
    var supply: = _update_bianwu_breakdowns(game_state)
    game_state.bianwu_defense_last_report = supply.duplicate(true)
    if game_state.city.is_empty():
        return
    var mazheng_lv: int = game_state.get_city_stat_level("mazheng")
    var binggong_lv: int = game_state.get_city_stat_level("binggong")
    var mapi_gain: int = mazheng_lv * BIANWU_MAIPI_PER_MAZHENG if _bianwu_has_unit_tag(game_state, "charge") else 0
    var huoqi_gain: int = binggong_lv * BIANWU_HUOQI_PER_BINGGONG if _bianwu_has_unit_tag(game_state, "firearm") else 0


    var liangcao_net: = 0
    for item in game_state.monthly_grain_breakdown:
        liangcao_net += int(item.get("value", 0))
    var xiangyin_net: = 0
    for item in game_state.monthly_silver_breakdown:
        xiangyin_net += int(item.get("value", 0))

    game_state.city["liangcao"] = maxi(0, int(game_state.city.get("liangcao", 0)) + liangcao_net)
    game_state.city["xiangyin"] = maxi(0, int(game_state.city.get("xiangyin", 0)) + xiangyin_net)
    game_state.city["mapi"] = maxi(0, int(game_state.city.get("mapi", 0)) + mapi_gain)
    game_state.city["huoqi"] = maxi(0, int(game_state.city.get("huoqi", 0)) + huoqi_gain)
    if not game_state.city.has("guanjun"):
        game_state.city["guanjun"] = 0
    if not game_state.city.has("jiading"):
        game_state.city["jiading"] = 0

    game_state.last_month_resource_delta = {
        "liangcao": liangcao_net, 
        "xiangyin": xiangyin_net, 
        "mapi": mapi_gain, 
        "huoqi": huoqi_gain, 
        "guanjun": 0, 
        "jiading": 0, 
    }
    game_state.state_changed.emit()

static func process_monthly_production(game_state: Node) -> void :
    if GameData.active_line == "bianwu":
        _process_bianwu_monthly(game_state)
        return

    game_state.update_monthly_breakdowns()
    if game_state.city.is_empty():
        return

    var liangshi = game_state.city.get("liangshi", 0)
    var yinliang = game_state.city.get("yinliang", 0)
    var bingyong = game_state.city.get("bingyong", 0)
    var renkou_val = game_state.city.get("renkou_val", 0)
    var liumin = game_state.city.get("liumin", 0)

    var net_grain = 0
    for item in game_state.monthly_grain_breakdown:
        net_grain += item.get("value", 0)

    var net_silver = 0
    for item in game_state.monthly_silver_breakdown:
        net_silver += item.get("value", 0)

    liangshi += net_grain
    yinliang += net_silver

    var deficit_silver = maxi(0, - yinliang)
    var deficit_grain = maxi(0, - liangshi)

    if liangshi < 0:
        liangshi = 0



    var special_items = game_state._process_special_items_monthly()
    game_state.private_silver += special_items["actual_effects"]["private_silver"]
    if PersonalStatCapstoneServiceRef.is_active(game_state, "lizheng"):
        game_state.private_silver += PersonalStatCapstoneServiceRef.LIZHENG_PRIVATE_SILVER_BONUS
    bingyong += special_items["actual_effects"]["bingyong"]

    var item_liumin_delta: int = int(special_items["actual_effects"].get("liumin", 0))
    var item_renkou_delta: int = int(special_items["actual_effects"].get("renkou_val", 0))
    liumin = maxi(0, liumin + item_liumin_delta)
    renkou_val = maxi(0, renkou_val + item_renkou_delta)

    var official_salary: int = game_state.get_monthly_official_salary()

    if int(game_state.get("salary_penalty_months")) > 0:
        game_state.salary_penalty_months = maxi(0, int(game_state.salary_penalty_months) - 1)
    elif official_salary > 0:
        game_state.private_silver += official_salary

    var growth = int(renkou_val * game_state.RENKOU_MONTHLY_NATURAL_GROWTH_RATE)
    renkou_val += growth


    var settled = game_state.get_monthly_wenjiao_refugee_settlement(liumin)
    if settled > 0:
        liumin -= settled
        renkou_val += settled


    var liumin_natural_growth: int = 0
    var liumin_base_growth: int = game_state.get_monthly_liumin_natural_inflow()
    if liumin_base_growth > 0:
        var fluctuation: float = randf_range(-0.2, 0.2)
        liumin_natural_growth = maxi(1, int(liumin_base_growth * (1.0 + fluctuation)))
        liumin += liumin_natural_growth

    var shortage: Dictionary = game_state.get_grain_shortage_report(renkou_val, liumin)
    var to_refugee: int = int(shortage.get("to_refugee", 0))
    if to_refugee > 0:
        renkou_val -= to_refugee
        liumin += to_refugee
    var pop_death: int = mini(int(shortage.get("pop_death", 0)), renkou_val)
    if pop_death > 0:
        renkou_val -= pop_death
    var ref_death: int = mini(int(shortage.get("ref_death", 0)), liumin)
    if ref_death > 0:
        liumin -= ref_death
    var minwang_drop: int = int(shortage.get("minwang_drop", 0))
    if minwang_drop > 0:
        game_state.attitudes["minwang"] = maxi(0, int(game_state.attitudes.get("minwang", 50)) - minwang_drop)
    game_state.last_grain_shortage_report = shortage

    var wulue_reduction: = PersonalStatCapstoneServiceRef.wulue_liumin_reduction(game_state, liumin)
    if wulue_reduction > 0:
        liumin = maxi(0, liumin - wulue_reduction)

    if PersonalStatCapstoneServiceRef.is_active(game_state, "wentao"):
        if game_state.get_city_stat_level("wenjiao") < game_state.CITY_STAT_MAX_LEVEL:
            game_state.wentao_capstone_months += 1
            if game_state.wentao_capstone_months >= PersonalStatCapstoneServiceRef.WENTAO_GROWTH_PERIOD:
                game_state.city["wenjiao"] = mini(game_state.get_city_stat_level("wenjiao") + 1, game_state.CITY_STAT_MAX_LEVEL)
                game_state.wentao_capstone_months = 0
    else:
        game_state.wentao_capstone_months = 0




    if game_state.month % 5 == 0:
        var talent_stat: = str(GameData.characters.get(game_state.char_id, {}).get("monthly_talent_stat", ""))
        if talent_stat != "":
            var lv = game_state.get_city_stat_level(talent_stat)
            if lv < game_state.CITY_STAT_MAX_LEVEL:
                game_state.city[talent_stat] = lv + 1

    game_state.city["liangshi"] = liangshi
    game_state.city["yinliang"] = yinliang
    game_state.city["bingyong"] = bingyong
    game_state.city["renkou_val"] = renkou_val
    game_state.city["liumin"] = liumin
    game_state.apply_slotted_item_monthly_attitude_effects()
    game_state.apply_slotted_item_city_level_growth()




    var renkou_recurring: int = growth + settled - to_refugee - pop_death + item_renkou_delta
    var liumin_recurring: int = liumin_natural_growth + to_refugee - settled - ref_death + item_liumin_delta
    game_state.last_month_resource_delta = {
        "yinliang": net_silver, 
        "liangshi": net_grain, 
        "renkou_val": renkou_recurring, 
        "liumin": liumin_recurring - wulue_reduction, 
        "bingyong": 0, 
    }

    game_state.state_changed.emit()
