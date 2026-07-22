extends RefCounted
class_name PersonalStatCapstoneService

const STAT_CAP: = 100
const WULUE_LIUMIN_REDUCTION: = 1000
const LIZHENG_YINLIANG_BONUS: = 2000
const LIZHENG_PRIVATE_SILVER_BONUS: = 60
const WENTAO_GROWTH_PERIOD: = 3
const STAT_ORDER: = ["wentao", "wulue", "lizheng", "tizhi"]
const STAT_LABELS: = {
    "wentao": "文韬", 
    "wulue": "武略", 
    "lizheng": "理政", 
    "tizhi": "体质", 
}

static func is_active(game_state: Node, stat_key: String) -> bool:
    if str(game_state.active_line) != "hanmen":
        return false
    return int(game_state.stats.get(stat_key, 0)) >= STAT_CAP

static func is_forced_unrest_card(card: Dictionary) -> bool:
    var card_type: = str(card.get("type", ""))
    return card_type in ["riot", "mutiny"]

static func should_waive_action_point(game_state: Node, card: Dictionary) -> bool:
    return is_active(game_state, "tizhi") and is_forced_unrest_card(card)

static func wulue_liumin_reduction(game_state: Node, current_liumin: int) -> int:
    if not is_active(game_state, "wulue"):
        return 0
    return mini(WULUE_LIUMIN_REDUCTION, maxi(0, current_liumin))

static func active_stat_keys(game_state: Node) -> Array:
    var result: Array = []
    for stat_key in STAT_ORDER:
        if is_active(game_state, stat_key):
            result.append(stat_key)
    return result

static func notice_text(stat_key: String) -> String:
    match stat_key:
        "wentao":
            return "文韬已臻满值。自下月起，每累计三个月，治下文教等级提升一级。"
        "wulue":
            return "武略已臻满值。自下月起，每月额外安抚一千流民。"
        "lizheng":
            return "理政已臻满值。自下月起，每月库银增加二千两，私银增加六十两。"
        "tizhi":
            return "体质已臻满值。处理流民暴动与兵勇哗变时，不再消耗行动力。"
    return ""

static func wentao_progress_text(game_state: Node) -> String:
    if game_state.get_city_stat_level("wenjiao") >= game_state.CITY_STAT_MAX_LEVEL:
        return "文教已达上限"
    return "本轮进度：%d／%d个月" % [int(game_state.wentao_capstone_months), WENTAO_GROWTH_PERIOD]

static func active_bonus_rows(game_state: Node) -> Array:
    var rows: Array = []
    if is_active(game_state, "wentao"):
        rows.append({"label": "文韬满值", "text": "每三个月文教等级提升一级；%s" % wentao_progress_text(game_state)})
    if is_active(game_state, "wulue"):
        rows.append({"label": "武略满值", "text": "每月流民减少一千"})
    if is_active(game_state, "lizheng"):
        rows.append({"label": "理政满值", "text": "每月库银增加二千两，私银增加六十两"})
    if is_active(game_state, "tizhi"):
        rows.append({"label": "体质满值", "text": "处理流民暴动与兵勇哗变不消耗行动力"})
    return rows
