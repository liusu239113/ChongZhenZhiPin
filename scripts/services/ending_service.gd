extends RefCounted
class_name EndingService


const RETREAT_ENDING_IDS: = [
    "bishan_guiyin", "buyi_guitian", "bw_jiejia_guitian", 
    "shi_bi_le_tu_fan", "shi_bi_le_tu_xiao", "shi_bi_le_tu_xin", 
    "shi_bi_le_tu_xin_du", "shi_bi_le_tu_zheng"
]


const KANGQING_ENDING_IDS: = [
    "bishan_kangqing"
]


const BIANWU_BAD_ENDINGS: = {
    "shengjuan": "bw_shengjuan", 
    "chaotang": "bw_chaotang", 
    "jianjun": "bw_jianjun", 
    "junxin": "bw_junxin", 
    "shimin": "bw_shimin", 
    "tizhi": "bw_tizhi", 
}

static func check_bad_ending(game_state: Node) -> String:

    var in_act5_plus = GameData.active_line != "bianwu"\
and (game_state.current_event >= 48 or game_state.branch != "")
    for key in GameData.ATT_KEYS:
        if key in game_state.attitudes and game_state.attitudes[key] <= 0:
            if in_act5_plus:
                continue
            return key
    if game_state.stats.get("tizhi", 1) <= 0:
        return "tizhi"
    return ""

static func resolve_shengjuan_ending(game_state: Node) -> String:
    var tag_count = func(tag: String) -> int:
        return game_state.tags.count(tag)
    var has_military = (
        tag_count.call("军功") >= 2
        or tag_count.call("擅权") >= 1
        or tag_count.call("地方坐大") >= 2
        or tag_count.call("养寇自重") >= 1
    )
    if has_military:
        return "shengjuan_rebel"
    return "shengjuan"

static func resolve_tizhi_ending(game_state: Node) -> String:
    if game_state.in_prison:
        return "tizhi_prison"
    elif game_state.branch == "zhongchen" or game_state.branch == "xinghuo":
        return "tizhi_war"
    elif game_state.branch == "bifan":
        return "tizhi_rebel"
    elif game_state.branch == "xiaoxiong":
        return "tizhi_warlord"
    elif game_state.current_event >= 48:
        return "tizhi_war"
    return "tizhi"

static func get_bad_ending_payload(game_state: Node) -> Dictionary:
    var bad = check_bad_ending(game_state)
    if bad == "":
        return {}

    if GameData.active_line == "bianwu" and BIANWU_BAD_ENDINGS.has(bad):
        var bw_ending: Dictionary = GameData.bad_endings.get(BIANWU_BAD_ENDINGS[bad], {})
        if not bw_ending.is_empty():
            return bw_ending
    var resolved = bad
    if bad == "shengjuan":
        resolved = resolve_shengjuan_ending(game_state)
    elif bad == "tizhi":
        resolved = resolve_tizhi_ending(game_state)
    return GameData.bad_endings.get(resolved, GameData.bad_endings.get(bad, {}))


static func is_loss_ending(ending: Dictionary) -> bool:
    for bad_ending in GameData.bad_endings.values():
        if ending == bad_ending:
            return true
    var badge: = str(ending.get("badge", ""))
    return badge.contains("惨") or badge.contains("败") or badge.contains("殁")

static func is_retreat_ending(ending: Dictionary) -> bool:
    for ending_id in RETREAT_ENDING_IDS:
        if ending == GameData.endings.get(ending_id, {}):
            return true
    return false

static func is_kangqing_ending(ending: Dictionary) -> bool:
    for ending_id in KANGQING_ENDING_IDS:
        if ending == GameData.endings.get(ending_id, {}):
            return true
    return false

static func determine_ending(game_state: Node) -> Dictionary:
    var bad_payload = get_bad_ending_payload(game_state)
    if not bad_payload.is_empty():
        return bad_payload

    if str(game_state.branch) != "":
        if game_state.has_method("is_branch_exhausted") and not game_state.is_branch_exhausted():
            return {}

    if game_state.has_method("get_guozuo_count") and game_state.get_guozuo_count() >= 4:
        if game_state.branch == "zhongchen":
            var beijing_relief_choice = str(game_state.last_branch_choice)
            if beijing_relief_choice != "" and beijing_relief_choice in GameData.endings:
                return GameData.endings[beijing_relief_choice]
            elif "beijing_relief_beijing" in GameData.endings:
                return GameData.endings["beijing_relief_beijing"]

    var fallback_map = {
        "zhongchen": "dumu_nandu", 
        "xiaoxiong": "dongnan_tietong", 
        "bifan": "bishan_jianshou", 
        "xinghuo": "xinhuo_guming"
    }
    if game_state.branch != "" and game_state.branch in fallback_map:
        var branch_key = fallback_map[game_state.branch]
        if branch_key in GameData.endings:
            return GameData.endings[branch_key]

    return {"title": "未知结局", "narrative": "你的故事还没有写完。", "emotion": "未知", "badge": "终局", "comment": ""}
