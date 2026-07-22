extends RefCounted
class_name GameStateQueryService








static func monthly_official_salary(game_state: Node) -> int:
    var rank_title: String = game_state.get_rank_title()
    if game_state.has_method("is_official_career_stage") and not game_state.is_official_career_stage():
        return 0
    elif game_state.has_method("has_official_salary_rank_title") and not game_state.has_official_salary_rank_title(rank_title):
        return 0
    elif not game_state.has_method("has_official_salary_rank_title") and not game_state.is_governance_mode():
        return 0
    for grade in game_state.OFFICIAL_MONTHLY_SALARY_BY_GRADE.keys():
        if rank_title.begins_with(str(grade)):
            return int(game_state.OFFICIAL_MONTHLY_SALARY_BY_GRADE[grade])
    return 0

static func monthly_official_salary_desc(game_state: Node) -> String:
    var salary: = monthly_official_salary(game_state)
    if salary <= 0:
        return "眼下尚未入官场月俸册，私银只靠旧日积蓄与临事进退。"
    return "你现任%s，照大明俸例由禄米折银入账，每月可得俸禄 %d 私银。衙门皂吏会把这点俸银送到后宅，数目不厚，却是官身每月最稳的一笔进项。" % [game_state.get_rank_title(), salary]

static func gaoji_banyin_income(game_state: Node) -> Dictionary:
    var gwl_outcome = ""
    var gwl_state = game_state.historical_chains.get("gaowanli", {})
    if not gwl_state.is_empty() and gwl_state.has("outcome"):
        gwl_outcome = gwl_state.get("outcome", "")

    var gwl_silver = 0
    var gwl_grain = 0
    var gwl_private = 0
    var gwl_label = "运河分成"


    if gwl_outcome in ["partnered", "canal_allied", "canal_limited"]:
        gwl_silver = 200
        gwl_grain = 200
        gwl_private = 20

    elif gwl_outcome in ["sea_full", "sea_quiet"]:
        gwl_silver = 320
        gwl_grain = 300
        gwl_private = 40
        gwl_label = "海运分成"

    elif gwl_outcome in ["fleet_official", "fleet_shadow", "fleet_small"]:
        gwl_silver = 500
        gwl_grain = 500
        gwl_private = 90
        gwl_label = "商船队分成"

    elif gwl_outcome in ["fleet_merged", "fleet_partner"]:
        gwl_silver = 800
        gwl_grain = 850
        gwl_private = 180
        gwl_label = "海上基业分成"


    if gwl_silver == 0 and gwl_grain == 0:
        gwl_silver = 200
        gwl_grain = 200
        gwl_private = 20
        gwl_label = "运河分成"

    return {
        "silver": gwl_silver, 
        "grain": gwl_grain, 
        "private": gwl_private, 
        "label": gwl_label
    }

static func riot_info(game_state: Node) -> Dictionary:

    if game_state.city.is_empty():
        return {"level": 0, "probability": 0.0, "ratio": 0.0, "label": "安全", "cooldown": false}
    var liumin_val: int = int(game_state.city.get("liumin", 0))
    var renkou_val: int = int(game_state.city.get("renkou_val", 0))
    var total: int = renkou_val + liumin_val
    if total <= 0 or liumin_val <= 0:
        return {"level": 0, "probability": 0.0, "ratio": 0.0, "label": "安全", "cooldown": false}
    var ratio: float = float(liumin_val) / float(total)

    var level: int = 0
    var base_prob: float = 0.0
    var label: String = "安全"
    if ratio >= 0.3:
        level = 3;base_prob = 0.8;label = "揭竿而起"
    elif ratio >= 0.2:
        level = 2;base_prob = 0.5;label = "聚众滋乱"
    elif ratio >= 0.12:
        level = 1;base_prob = 0.3;label = "小股闹事"
    elif liumin_val >= game_state.RIOT_MIN_REFUGEE_COUNT:
        level = 1
        var low_ratio_factor: float = clampf(ratio / game_state.RIOT_LOW_RATIO_MAX, 0.0, 1.0)
        base_prob = lerpf(game_state.RIOT_LOW_RATIO_PROBABILITY_START, game_state.RIOT_LOW_RATIO_PROBABILITY_END, low_ratio_factor)
        label = "小股闹事"
    var grain_empty_pressure: bool = int(game_state.get_grain_shortage_tier()["tier"]) >= 2
    if grain_empty_pressure and liumin_val > 0:
        level = maxi(level, 1)
        base_prob = maxf(base_prob, game_state.RIOT_GRAIN_EMPTY_MIN_PROBABILITY)
        if label == "安全":
            label = "小股闹事"
    if level == 0:
        return {"level": 0, "probability": 0.0, "ratio": ratio, "label": "安全", "cooldown": false}

    var chengfang_lv: int = game_state.get_city_stat_level("chengfang")
    var lizheng_val: int = int(game_state.stats.get("lizheng", 50))
    var mit_lizheng: float = minf(float(lizheng_val) * 0.005, 0.4)
    var mit_chengfang: float = minf(float(chengfang_lv) * 0.016, 0.4)
    var mitigation: float = minf(mit_lizheng + mit_chengfang, 0.8)
    var actual_prob: float = base_prob * (1.0 - mitigation)

    var last_mut_turn: int = int(game_state.city.get("last_mutiny_turn", -99))
    var in_cooldown: bool = (game_state.turn - game_state.last_riot_turn) < 3 or (game_state.turn - last_mut_turn) < 2
    return {"level": level, "probability": actual_prob, "ratio": ratio, "label": label, "cooldown": in_cooldown}

static func mutiny_info(game_state: Node) -> Dictionary:

    if game_state.city.is_empty():
        return {"level": 0, "probability": 0.0, "deficit_loss": 0, "label": "安全"}

    var bingyong: int = int(game_state.city.get("bingyong", 0))
    if bingyong <= 0:
        return {"level": 0, "probability": 0.0, "deficit_loss": 0, "label": "安全"}

    var current_grain: int = int(game_state.city.get("liangshi", 0))
    var current_silver: int = int(game_state.city.get("yinliang", 0))

    var grain_net: int = game_state.get_monthly_grain_net_change()
    var silver_net: = 0
    if game_state.monthly_silver_breakdown.is_empty():
        game_state.update_monthly_breakdowns()
    for item in game_state.monthly_silver_breakdown:
        silver_net += int(item.get("value", 0))

    var next_grain = current_grain + grain_net
    var next_silver = current_silver + silver_net

    var deficit_grain: = maxi(0, - next_grain)
    var deficit_silver: = maxi(0, - next_silver)

    if deficit_grain == 0 and deficit_silver == 0:
        return {"level": 0, "probability": 0.0, "deficit_loss": 0, "label": "安全"}

    var grain_deficit_soldier_loss = mini(deficit_grain, game_state.GRAIN_DEFICIT_SOLDIER_LOSS_CAP)
    var effective_silver_deficit = deficit_silver
    var unpaid_soldiers = maxi(effective_silver_deficit * 2, grain_deficit_soldier_loss)
    var mutiny_risk_loss = mini(unpaid_soldiers, bingyong)


    var base_prob: float = game_state.mutiny_trigger_chance()

    var both_empty: bool = (next_grain <= 0) and (next_silver <= 0)
    var mitigation: = 1.0
    if not both_empty:
        var current_lizheng = int(game_state.stats.get("lizheng", 50))
        var current_wulue = int(game_state.stats.get("wulue", 50))
        if current_lizheng > 70 and current_wulue > 70:
            mitigation = 0.2
        elif current_lizheng > 70 or current_wulue > 70:
            mitigation = 0.5

    var actual_prob: float = base_prob * mitigation

    if game_state.attitudes.has("junxin"):
        var jx: = int(game_state.attitudes.get("junxin", 60))
        if jx < 25:
            actual_prob = minf(1.0, actual_prob * 1.6)
        elif jx < 40:
            actual_prob = minf(1.0, actual_prob * 1.25)
        elif jx >= 70:
            actual_prob = actual_prob * 0.6
    var base_probability: float = actual_prob
    var modifier_points: = 0
    var active_modifiers: Array = []
    if str(game_state.get("active_line")) in ["", "hanmen"] and game_state.has_method("mutiny_risk_modifier_points"):
        modifier_points = game_state.mutiny_risk_modifier_points()
        active_modifiers = game_state.get_active_mutiny_risk_modifiers()
    actual_prob = clampf(base_probability + float(modifier_points) / 100.0, 0.0, 1.0)
    return {
        "level": 1 if mutiny_risk_loss > 0 else 0, 
        "probability": actual_prob, 
        "base_probability": base_probability, 
        "modifier_points": modifier_points, 
        "modifiers": active_modifiers, 
        "deficit_loss": mutiny_risk_loss, 
        "label": "哗变风险"
    }
