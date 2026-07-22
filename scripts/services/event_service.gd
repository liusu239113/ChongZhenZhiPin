extends RefCounted
class_name EventService

const BianwuDefenseServiceRef = preload("res://scripts/services/bianwu_defense_service.gd")

const PersonalStatCapstoneServiceRef = preload("res://scripts/services/personal_stat_capstone_service.gd")

const BattleTypesRef = preload("res://scripts/battle/battle_types.gd")

const GOVERNANCE_SPEAKERS: = {
    "governance": {"name": "告示房", "role": "衙门布告", "faction": "县治"}, 
    "trade": {"name": "粮行", "role": "市面交易", "faction": "商贾"}, 
    "home": {"name": "内宅", "role": "家中私议", "faction": "自宅"}, 
    "field": {"name": "乡间", "role": "踏勘见闻", "faction": "田野"}, 
    "court": {"name": "衙署公堂", "role": "升堂问案", "faction": "衙门"}, 
    "visitor": {"name": "街巷人物", "role": "街谈奇遇", "faction": "街巷"}, 
    "rumor": {"name": "坊间传闻", "role": "传闻勘验", "faction": "传闻"}
}


const RUMOR_CARD_WEIGHT: = 0.2
const RUMOR_CARD_MAX_PER_HAND: = 1
const RUMOR_CARD_HAND_CHANCE: = 0.4
const RUMOR_CARD_RECENT_WINDOW: = 30




const NONGSANG_CARD_IDS: = ["gc2"]
const NONGSANG_CARD_SORT_BIAS: = 0.7






const BINGYONG_CARD_CATEGORY: = "bingyong"
const BINGYONG_CARD_TAG: = "兵勇"
const BINGYONG_CARD_HAND_CHANCE: = 0.7
const BINGYONG_CARD_MAX_PER_HAND: = 1
const MILITARY_DISCIPLINE_CASE_CATEGORY: = "military_discipline"
const MILITARY_DISCIPLINE_CASE_COOLDOWN_MONTHS: = 6



const ZHENGWU_MASTER_ID: = "gc_zhengwu_master"
const ZHENGWU_MASTER_ACT456_FRONT_CHANCE: = 0.3

const DEZHENG_MANDATE_PREREQUISITES: = [
    "guozuo_summon_relief", 
    "beijing_relief_regency"
]

const LEGACY_MONTH_CARD_MIGRATIONS: = {
    "court:case_07": {
        "type": "story", 
        "id": "e2_7b", 
        "title": "矿税之祸", 
        "tag": "剧情事件", 
        "direct": false
    }
}



const CHAIN_CHAPTER_MIN_GAP_MONTHS: = 8

const ATT_EVENT_COOLDOWN: = 5


const ATT_EVENT_PRIORITY: = [
    "att_minwang_low", "att_shishen_low", "att_shishen_low_2", "att_zhongguan_low", "att_qingyi_low", "att_shengjuan_prison", "att_shengjuan_low", 
    "att_shengjuan_high", "att_zhongguan_high", "att_qingyi_high", "att_shishen_high", "att_minwang_high", 
]



const ATT_EVENT_REPEAT_COOLDOWN: = {
    "att_shengjuan_prison": 12, 
}

static func _find_attitude_event_by_id(event_id: String) -> Dictionary:
    for ev in GameData.ATTITUDE_EVENTS:
        if str(ev.get("id", "")) == event_id:
            return ev
    return {}


static func _attitude_event_threshold_met(game_state: Node, ev: Dictionary) -> bool:
    var trig: Dictionary = ev.get("trigger", {})
    var key: = str(trig.get("key", ""))
    if key == "" or not game_state.attitudes.has(key):
        return false
    var val: = int(game_state.attitudes.get(key, 50))
    var direction: = str(trig.get("direction", ""))
    var threshold: = int(trig.get("threshold", 0))
    if direction == "low":
        return val <= threshold
    if direction == "high":
        return val >= threshold
    return false


static func _select_attitude_event(game_state: Node) -> String:
    if not game_state.is_governance_mode():
        return ""
    if game_state.emperor_dead:
        return ""

    if str(game_state.get("active_line")) not in ["", "hanmen"]:
        return ""
    var now_time: = int(game_state.year) * 12 + int(game_state.month)
    if now_time - int(game_state.att_event_last_time) < ATT_EVENT_COOLDOWN:
        return ""
    var current_act: = _get_current_act(game_state)
    for event_id in ATT_EVENT_PRIORITY:
        if ATT_EVENT_REPEAT_COOLDOWN.has(event_id):

            var repeat_cd: = int(ATT_EVENT_REPEAT_COOLDOWN[event_id])
            var last_time: = int(game_state.att_event_repeat_last.get(event_id, -9999))
            if now_time - last_time < repeat_cd:
                continue
        elif event_id in game_state.att_events_triggered:
            continue
        var ev: = _find_attitude_event_by_id(event_id)
        if ev.is_empty():
            continue
        if not _attitude_event_threshold_met(game_state, ev):
            continue
        var min_act: = int(ev.get("requireMinAct", 0))
        if min_act > 0 and current_act < min_act:
            continue
        return event_id
    return ""

static func get_cz_year(current_event_data: Dictionary) -> int:
    if current_event_data.has("year"):
        return current_event_data["year"]
    return 1

static func get_volume_label(current_event_data: Dictionary) -> String:
    if current_event_data.has("stage"):
        return current_event_data["stage"]
    return "崇祯元年"

static func get_governance_turn_label(game_state: Node) -> String:
    var year_name: = "崇祯%s年" % _year_to_chinese(game_state.year)
    if not GameData.SEASON_NAMES.is_empty():
        var season_idx: = clampi(game_state.month - 1, 0, GameData.SEASON_NAMES.size() - 1)
        return "%s · %s" % [year_name, GameData.SEASON_NAMES[season_idx]]
    var month_name: = "正月"
    if game_state.month > 0 and game_state.month <= GameData.MONTH_NAMES.size():
        month_name = GameData.MONTH_NAMES[game_state.month - 1]
    return "%s · %s" % [year_name, month_name]

static func get_governance_stage_label(game_state: Node) -> String:
    var act_key: = str(_get_current_act(game_state))
    var act_cfg: Dictionary = GameData.ACT_CONFIG.get(act_key, {})
    return act_cfg.get("title", "地方治理")

static func get_branch_event(branch: String, branch_index: int, tags: Array[String], game_state: Node = null) -> Dictionary:
    if branch == "zhongchen":
        if branch_index == 1:
            var default_event = _find_branch_event_by_id("zhongchen", "e5_7_zhong")
            if default_event != null:
                var updated_event = default_event.duplicate(true)
                if "分兵北上" in tags:
                    updated_event["narrative"] = "北上的路走了四十天。从山东到京畿，三千里路，你的队伍从一千五百人走到了一千人。不是打没的——一仗都没打，是走没的。\n\n饿跑了一批、病倒了一批、开小差跑了一批。沿途的城全关了门，不是不想开，是不敢开——他们怕你是大顺军的伪装，更怕开了门之后你把他们的粮食吃光。每天都有坏消息传来：居庸关降了、大同降了、宣府也降了。你的斥候骑着瘦得只剩骨头的马回来报告，前方百里内全是大顺军的旗号。\n\n溃军总兵带着三十几个残兵从前方退下来，看到你的队伍时愣了一下，然后说了那句话。他的眼睛已经没有神了，像两口枯井。你站在路边，看着这支越走越少的队伍，心里反复问自己同一个问题：还走不走？"
                    if updated_event.has("choices") and updated_event["choices"].size() > 0:
                        updated_event["choices"][0]["comment"] = "你沿途收了七百多溃兵，队伍达到了一千七百多人。但这些溃兵的眼神和你的老兵不一样——他们眼里没有忠义，只有恐惧和一口饭。你的老兵私底下抱怨说这些人靠不住，但你没有别的选择。能多一个人就多一分力量，哪怕这个人明天就跑了。"
                return updated_event
        elif branch_index == 2:
            if game_state != null and str(game_state.last_branch_choice) == "guozuo_echo_relief":
                return _find_branch_event_by_id("zhongchen", "e5_8_guozuo_relief")
            if "倾巢北上" in tags and "轻装急进" in tags:
                return GameData.rush_event
        elif branch_index == 3:
            if "摄政监国" in tags:
                return _find_branch_event_by_id("zhongchen", "e5_8_guozuo_relief_regency")
            elif "北京解围" in tags:
                return _find_branch_event_by_id("zhongchen", "e5_9_guozuo_after_relief")
        elif branch_index == 4:
            if "摄政监国" in tags:
                return _find_branch_event_by_id("zhongchen", "e5_9_guozuo_after_relief")
            elif "北京解围" in tags:
                return _find_branch_event_by_id("zhongchen", "e5_9_guozuo_after_relief_post")
        elif branch_index == 5:
            if "摄政监国" in tags:
                return _find_branch_event_by_id("zhongchen", "e5_9_guozuo_after_relief_post")
            elif game_state != null and str(game_state.last_branch_choice) == "beijing_marquis_pending":
                return _find_branch_event_by_id("zhongchen", "e5_10_beijing_marquis_offer")
            elif "广济桥夜议" in tags:
                return _find_branch_event_by_id("zhongchen", "e5_10_dezheng_mandate")
        elif branch_index == 6:
            if "广济桥德政起誓" in tags:
                return _find_branch_event_by_id("zhongchen", "e5_11_dezheng_mandate_gather")
            if "摄政监国" in tags:
                return _find_branch_event_by_id("zhongchen", "e5_10_beijing_regent_offer")
        elif branch_index == 7:
            if "广济桥夜议" in tags:
                return _find_branch_event_by_id("zhongchen", "e5_10_dezheng_mandate")
    if branch in GameData.branch_events:
        var event_list = GameData.branch_events[branch]
        if branch_index >= 0 and branch_index < event_list.size():
            var event_data: Dictionary = event_list[branch_index].duplicate(true)

            var variant_keys: Array[String] = ["narrative", "speakerLine", "focusLine"]
            for vkey in variant_keys:
                var vfield: String = vkey + "_variants"
                if event_data.has(vfield):
                    var variants: Array = event_data[vfield]
                    if variants.size() > 0:
                        event_data[vkey] = variants[randi() % variants.size()]
            return event_data
    return {}

static func _has_dezheng_mandate_prerequisite(game_state: Node) -> bool:
    if game_state == null:
        return false
    if not game_state.has_method("has_dezheng_mandate") or not game_state.has_dezheng_mandate():
        return false
    return str(game_state.last_branch_choice) in DEZHENG_MANDATE_PREREQUISITES

static func _find_branch_event_by_id(branch: String, event_id: String) -> Dictionary:
    if not branch in GameData.branch_events:
        return {}
    for event_data in GameData.branch_events[branch]:
        if str(event_data.get("id", "")) == event_id:
            return event_data.duplicate(true)
    return {}

static func get_current_event(in_prison: bool, prison_index: int, branch: String, branch_index: int, current_event: int, tags: Array[String]) -> Dictionary:
    if in_prison:
        if prison_index >= 0 and prison_index < GameData.prison_events.size():
            return GameData.prison_events[prison_index]
        return {}
    if branch != "":
        return get_branch_event(branch, branch_index, tags)
    if current_event >= 0 and current_event < GameData.events.size():
        return GameData.events[current_event]
    return {}

static func _cached_month_cards_match_schedule(game_state: Node) -> bool:
    _migrate_legacy_cached_month_cards(game_state)
    var schedule_key: = "%d-%d" % [game_state.year, game_state.month]
    var scheduled_story_id: String = str(GameData.SPECIAL_EVENT_SCHEDULE.get(schedule_key, ""))
    if scheduled_story_id != "" and _find_event_by_id(scheduled_story_id).is_empty():
        scheduled_story_id = ""
    var cached_story_id: = ""
    for card in game_state.month_cards:
        if typeof(card) != TYPE_DICTIONARY:
            continue
        if str(card.get("type", "")) == "story":
            cached_story_id = str(card.get("id", ""))
            break
    return cached_story_id == scheduled_story_id

static func _migrate_legacy_cached_month_cards(game_state: Node) -> bool:
    if game_state == null or game_state.month_cards.is_empty():
        return false
    var changed: = false
    for idx in range(game_state.month_cards.size()):
        var card = game_state.month_cards[idx]
        if typeof(card) != TYPE_DICTIONARY:
            continue
        var legacy_key: = _legacy_month_card_migration_key(card)
        if not LEGACY_MONTH_CARD_MIGRATIONS.has(legacy_key):
            continue
        var replacement: Dictionary = LEGACY_MONTH_CARD_MIGRATIONS[legacy_key].duplicate(true)
        if str(replacement.get("type", "")) == "story":
            var event_id: = str(replacement.get("id", ""))
            var event_data: = _find_event_by_id(event_id)
            if event_data.is_empty():
                continue
            replacement["title"] = event_data.get("title", replacement.get("title", "剧情事件"))
            replacement["direct"] = _is_direct_story_event(event_data)
        game_state.month_cards[idx] = replacement
        changed = true
    if changed:
        for done_idx in game_state.month_cards_done.duplicate():
            var done_int: = int(done_idx)
            if done_int < 0 or done_int >= game_state.month_cards.size():
                game_state.month_cards_done.erase(done_idx)
        if int(game_state.current_month_card_index) >= game_state.month_cards.size():
            game_state.current_month_card_index = -1
    return changed

static func _legacy_month_card_migration_key(card: Dictionary) -> String:
    var card_type: = str(card.get("type", ""))
    match card_type:
        "court":
            return "court:%s" % str(card.get("case_id", ""))
    return _month_card_identity_key(card)

static func _find_cached_month_card_invalid_indices(game_state: Node) -> Array[int]:
    _migrate_legacy_cached_month_cards(game_state)
    var invalid: Array[int] = []
    for idx in range(game_state.month_cards.size()):
        var card = game_state.month_cards[idx]
        if typeof(card) != TYPE_DICTIONARY or not _is_cached_month_card_valid(card):
            invalid.append(idx)
    return invalid

static func _is_cached_month_card_valid(card: Dictionary) -> bool:
    match str(card.get("type", "")):
        "story":
            if card.has("branch"):
                return not get_branch_event(str(card.get("branch", "")), int(card.get("branch_index", 0)), []).is_empty()
            return not _find_event_by_id(str(card.get("id", ""))).is_empty()
        "attitude":
            return not _find_attitude_event_by_id(str(card.get("id", ""))).is_empty()
        "governance":
            return _is_cached_indexed_action_valid(card, GameData.GOVERNANCE_CARDS)
        "trade":
            return _is_cached_indexed_action_valid(card, GameData.TRADE_CARDS)
        "home":
            return _is_cached_indexed_action_valid(card, GameData.HOME_ACTIONS)
        "field":
            return _is_cached_indexed_action_valid(card, GameData.FIELD_ACTIONS)
        "rumor":
            return _is_cached_indexed_action_valid(card, GameData.RUMOR_CARDS)
        "court":
            return not _find_court_case_by_id(str(card.get("case_id", ""))).is_empty()
        "court_chain":
            return not _find_chain_case_by_id(str(card.get("chain_id", ""))).is_empty()
        "visitor":
            return not _find_visitor_by_id(str(card.get("visitor_id", ""))).is_empty()
        "riot":
            var riot_level: = int(card.get("riot_level", 0))
            return riot_level >= 1 and riot_level <= 3
        "mutiny":
            var mutiny_level: = int(card.get("mutiny_level", 0))
            return mutiny_level >= 1 and mutiny_level <= 3
        "grain_shortage":
            return not GameData.DYNAMIC_EVENTS.get("grain_shortage", {}).is_empty()
        "bw_assault":

            return true
    return false

static func _is_cached_indexed_action_valid(card: Dictionary, source_cards: Array) -> bool:
    var idx: = int(card.get("idx", -1))
    if idx < 0 or idx >= source_cards.size():
        return false
    var source: Dictionary = source_cards[idx]
    var cached_id: = str(card.get("id", ""))
    if cached_id != "" and cached_id != str(source.get("id", "")):
        return false
    var cached_title: = str(card.get("title", ""))
    if cached_title != "" and cached_title != str(source.get("title", "")):
        return false
    return true

static func _refresh_invalid_cached_month_cards(game_state: Node) -> bool:
    var invalid_indices: = _find_cached_month_card_invalid_indices(game_state)
    if invalid_indices.is_empty():
        return true
    var replacements: = _build_cached_month_card_replacements(game_state, invalid_indices.size())
    if replacements.size() < invalid_indices.size():
        return false
    for replace_idx in range(invalid_indices.size()):
        game_state.month_cards[invalid_indices[replace_idx]] = replacements[replace_idx]
    return _find_cached_month_card_invalid_indices(game_state).is_empty()

static func sanitize_cached_month_cards(game_state: Node) -> bool:
    if game_state == null or game_state.month_cards.is_empty():
        return true
    var changed: = _migrate_legacy_cached_month_cards(game_state)
    var invalid_indices: = _find_cached_month_card_invalid_indices(game_state)
    if invalid_indices.is_empty():
        if changed:
            _remember_visible_rumor_cards(game_state, game_state.month_cards)
        return true
    var refreshed: = _refresh_invalid_cached_month_cards(game_state)
    if refreshed:
        _remember_visible_rumor_cards(game_state, game_state.month_cards)
    return refreshed

static func _build_cached_month_card_replacements(game_state: Node, count: int) -> Array:
    var pool: = _build_regular_month_action_pool(game_state)
    var used_keys: Array[String] = []
    for card in game_state.month_cards:
        if typeof(card) != TYPE_DICTIONARY:
            continue
        var key: = _month_card_identity_key(card)
        if key != "":
            used_keys.append(key)
    var replacements: Array = []
    for candidate in pool:
        if replacements.size() >= count:
            break
        var key: = _month_card_identity_key(candidate)
        if key == "" or used_keys.has(key):
            continue
        replacements.append(candidate)
        used_keys.append(key)
    return replacements

static func _month_card_identity_key(card: Dictionary) -> String:
    var card_type: = str(card.get("type", ""))
    if card_type == "":
        return ""
    var id_key: = str(card.get("id", ""))
    if id_key != "":
        return "%s:%s" % [card_type, id_key]
    if card.has("idx"):
        return "%s:%d" % [card_type, int(card.get("idx", -1))]
    for key_name in ["case_id", "chain_id", "visitor_id", "riot_level", "mutiny_level"]:
        if card.has(key_name):
            return "%s:%s" % [card_type, str(card.get(key_name, ""))]
    return ""

static func _get_recent_rumor_card_ids(game_state: Node) -> Array[String]:
    var recent: Array[String] = []
    if game_state == null:
        return recent
    var raw = game_state.get("recent_rumor_card_ids")
    if typeof(raw) != TYPE_ARRAY:
        return recent
    for entry in raw:
        var rumor_id: = str(entry)
        if rumor_id != "":
            recent.append(rumor_id)
    return recent

static func _remember_rumor_card_id(game_state: Node, rumor_id: String) -> void :
    if game_state == null or rumor_id == "":
        return
    var recent: Array[String] = _get_recent_rumor_card_ids(game_state)
    recent.erase(rumor_id)
    recent.append(rumor_id)
    while recent.size() > RUMOR_CARD_RECENT_WINDOW:
        recent.pop_front()
    game_state.set("recent_rumor_card_ids", recent)

static func _remember_visible_rumor_cards(game_state: Node, cards: Array) -> void :
    for card in cards:
        if typeof(card) != TYPE_DICTIONARY:
            continue
        if str(card.get("type", "")) != "rumor":
            continue
        var rumor_id: = str(card.get("id", ""))
        _remember_rumor_card_id(game_state, rumor_id)

static func _needs_terminal_fork_recovery(game_state: Node) -> bool:
    if game_state == null or not game_state.is_governance_mode():
        return false
    if game_state.has_method("is_after_sun_chuanting_branch_split") and game_state.is_after_sun_chuanting_branch_split():
        return false
    return int(game_state.year) > 17 or (int(game_state.year) == 17 and int(game_state.month) > 1)

static func _recover_overdue_terminal_fork(game_state: Node) -> bool:
    if not _needs_terminal_fork_recovery(game_state):
        return false
    game_state.year = 17
    game_state.month = 1
    game_state.action_points = game_state.monthly_action_points()
    game_state.month_cards = []
    game_state.month_cards_done.clear()
    game_state.current_month_card_index = -1
    game_state.month_visitors.clear()
    game_state.active_case_chain = {}
    return true

static func generate_month_cards(game_state: Node) -> Array:
    if not game_state.is_governance_mode():
        return []
    if _recover_overdue_terminal_fork(game_state):

        pass
    if game_state.has_method("is_after_sun_chuanting_branch_split") and game_state.is_after_sun_chuanting_branch_split():
        return _generate_sun_chuanting_locked_month_cards(game_state)
    if not game_state.month_cards.is_empty():
        if not game_state.month_cards_done.is_empty():
            sanitize_cached_month_cards(game_state)
            return game_state.month_cards
        if _cached_month_cards_match_schedule(game_state) and sanitize_cached_month_cards(game_state):
            _remember_visible_rumor_cards(game_state, game_state.month_cards)
            return game_state.month_cards
        game_state.month_cards = []
        game_state.month_cards_done.clear()
        game_state.current_month_card_index = -1

    var cards: Array = []
    var schedule_key: = "%d-%d" % [game_state.year, game_state.month]
    var special_event_id: String = str(GameData.SPECIAL_EVENT_SCHEDULE.get(schedule_key, ""))
    var has_story: = false
    if special_event_id != "":
        var special_event = _find_event_by_id(special_event_id)
        if not special_event.is_empty():
            cards.append({
                "type": "story", 
                "id": special_event_id, 
                "title": special_event.get("title", "剧情事件"), 
                "tag": "剧情事件", 
                "direct": _is_direct_story_event(special_event)
            })
            has_story = true


    if not has_story:
        var att_event_id: = _select_attitude_event(game_state)
        if att_event_id != "":
            var att_ev: = _find_attitude_event_by_id(att_event_id)
            if not att_ev.is_empty():
                cards.append({
                    "type": "attitude", 
                    "id": att_event_id, 
                    "title": att_ev.get("title", "剧情事件"), 
                    "tag": "剧情事件", 
                    "direct": false
                })
                has_story = true
                var att_now_time: = int(game_state.year) * 12 + int(game_state.month)
                if ATT_EVENT_REPEAT_COOLDOWN.has(att_event_id):

                    game_state.att_event_repeat_last[att_event_id] = att_now_time
                elif att_event_id not in game_state.att_events_triggered:
                    game_state.att_events_triggered.append(att_event_id)
                game_state.att_event_last_time = att_now_time


    if not has_story:
        var _grain_now: int = int(game_state.city.get("liangshi", 0))
        var _gs_now_time: int = int(game_state.year) * 12 + int(game_state.month)
        if _grain_now <= 0 and (_gs_now_time - int(game_state.grain_shortage_last_time)) >= 12:
            if str(game_state.get("active_line")) in ["", "hanmen"]:
                var gs_template: Dictionary = GameData.DYNAMIC_EVENTS.get("grain_shortage", {})
                if not gs_template.is_empty():
                    cards.append({
                        "type": "grain_shortage", 
                        "title": gs_template.get("title", "粮商"), 
                        "tag": "剧情事件", 
                        "direct": false
                    })
                    has_story = true
                    game_state.grain_shortage_last_time = _gs_now_time

    var now_time: int = int(game_state.year) * 12 + int(game_state.month)
    _queue_due_scheduled_visitors(game_state, now_time)

    var mutiny_level: int = game_state.check_mutiny()
    if mutiny_level > 0:
        var _mg: int = int(game_state.get_monthly_grain_net_change())
        var _ms: = 0
        for _si in game_state.monthly_silver_breakdown:
            _ms += int(_si.get("value", 0))
        var _ng = int(game_state.city.get("liangshi", 0)) + _mg
        var _ns = int(game_state.city.get("yinliang", 0)) + _ms
        var _grain_short: bool = _ng <= 0
        var _silver_short: bool = _ns <= 0
        var _cause_grain: bool = _grain_short if (_grain_short or _silver_short) else true
        var _lv1_title: = "克扣口粮" if _cause_grain else "欠饷闹营"
        var _lv2_title: = "聚众讨粮" if _cause_grain else "聚众讨饷"
        cards.append({
            "type": "mutiny", 
            "mutiny_level": mutiny_level, 
            "title": [_lv1_title, _lv2_title, "军营哗变"][mutiny_level - 1], 
            "tag": "哗变", 
            "cause_grain": _cause_grain
        })

    var riot_level: int = 0
    if not (has_story and mutiny_level > 0):
        riot_level = game_state.check_riot()
    if riot_level > 0:
        cards.append({
            "type": "riot", 
            "riot_level": riot_level, 
            "title": ["小股闹事", "聚众滋乱", "揭竿而起"][riot_level - 1], 
            "tag": "暴动"
        })
    var min_actions: = 2
    var max_non_action_cards: = 5 - min_actions
    var due_followups: Array = []
    var remaining_followups: Array = []
    for follow_up in game_state.pending_follow_ups:
        if int(follow_up.get("ready_after", 0)) <= now_time:
            due_followups.append(follow_up)
        else:
            remaining_followups.append(follow_up)
    game_state.pending_follow_ups = remaining_followups

    var needed: = 4 if has_story else 5


    var is_bianwu_line: = str(game_state.get("active_line")) == "bianwu"

    for follow_up in due_followups:
        if is_bianwu_line:

            game_state.pending_follow_ups.append(follow_up)
            continue
        var follow_type: = str(follow_up.get("type", ""))
        var injected: = false
        if cards.size() < max_non_action_cards:
            if follow_type == "court_chain" and not _hand_has_tag(cards, "衙门"):
                var chain_id: = str(follow_up.get("chain_id", ""))
                var chain_def: = _find_chain_case_by_id(chain_id)
                if not chain_def.is_empty() and _is_chain_case_eligible(chain_def, _get_current_act(game_state)):
                    cards.append({
                        "type": "court_chain", 
                        "chain_id": chain_id, 
                        "event_index": int(follow_up.get("event_index", 0)), 
                        "title": str(follow_up.get("title", chain_def.get("title", "连环案"))), 
                        "tag": "衙门"
                    })
                    needed -= 1
                    injected = true
            elif follow_type == "visitor" and not _hand_has_tag(cards, "街巷"):
                var visitor_id: = str(follow_up.get("visitor_id", ""))
                var visitor_def: = _find_visitor_by_id(visitor_id)
                if not visitor_def.is_empty():
                    cards.append({
                        "type": "visitor", 
                        "visitor_id": visitor_id, 
                        "title": str(follow_up.get("title", visitor_def.get("title", "访客"))), 
                        "tag": "街巷"
                    })
                    needed -= 1
                    injected = true
        if not injected:

            var still_valid: = true
            if follow_type == "visitor" and _find_visitor_by_id(str(follow_up.get("visitor_id", ""))).is_empty():
                still_valid = false
            elif follow_type == "court_chain" and _find_chain_case_by_id(str(follow_up.get("chain_id", ""))).is_empty():
                still_valid = false
            if still_valid:
                follow_up["ready_after"] = now_time + 1 + randi() % 2
                game_state.pending_follow_ups.append(follow_up)



    for scheduled in game_state.pending_scheduled_visitors:
        if is_bianwu_line:
            break
        if cards.size() >= max_non_action_cards or _hand_has_tag(cards, "街巷"):
            break
        var visitor_id: = str(scheduled.get("visitor_id", ""))
        var visitor_def: = _find_visitor_by_id(visitor_id)
        if visitor_def.is_empty():
            continue
        if not _is_visitor_eligible(game_state, visitor_def, _get_current_act(game_state)):
            continue

        if int(scheduled.get("cooldown", 0)) > 0:
            continue
        cards.append({
            "type": "visitor", 
            "visitor_id": visitor_id, 
            "title": visitor_def.get("title", ""), 
            "tag": "街巷", 
            "scheduled": true
        })

        scheduled["shown_pending"] = true
        needed -= 1

    var priority_buy_grain_idx: = -1
    if _should_prioritize_buy_grain(game_state):
        priority_buy_grain_idx = _find_trade_card_index("tc_buy_grain")
        if priority_buy_grain_idx >= 0 and cards.size() < 5:
            var priority_trade: Dictionary = GameData.TRADE_CARDS[priority_buy_grain_idx]
            cards.append({
                "type": "trade", 
                "idx": priority_buy_grain_idx, 
                "id": "tc_buy_grain", 
                "title": priority_trade.get("title", ""), 
                "tag": "交易"
            })






    var current_act: = _get_current_act(game_state)
    var used_keys: Array[String] = []
    for existing in cards:
        if typeof(existing) == TYPE_DICTIONARY:
            var ek: = _month_card_identity_key(existing)
            if ek != "":
                used_keys.append(ek)

    if str(game_state.get("active_line")) == "bianwu":

        _fill_bianwu_slot_cards(game_state, cards, used_keys, has_story)
    else:

        var gov_pool: = _build_governance_class_pool(game_state)

        var court_pool: Array = _build_court_slot_pool(game_state) if current_act <= 4 else []
        var field_pool: Array = _build_field_slot_pool(game_state) if current_act > 4 else []
        var military_court_pool: Array = _build_military_discipline_court_pool(game_state) if current_act >= 5 else []
        var street_pool: = _build_street_slot_pool(game_state)

        var month_index: = int(game_state.year) * 12 + int(game_state.month)
        var alt_pool: Array = []
        if month_index % 2 == 0:
            alt_pool = _build_rumor_slot_pool(game_state)
            if alt_pool.is_empty():
                alt_pool = _collect_bingyong_member_cards(game_state)
        else:
            alt_pool = _collect_bingyong_member_cards(game_state)
            if alt_pool.is_empty():
                alt_pool = _build_rumor_slot_pool(game_state)
        alt_pool.shuffle()

        var prefs: Array[String] = ["gov"]
        prefs.append("court" if current_act <= 4 else "military_court")
        prefs.append("street")
        prefs.append("alt")
        if not has_story:
            prefs.append("gov")

        for pref in prefs:
            if cards.size() >= 5:
                break
            var picked: Dictionary = {}
            match pref:
                "court":
                    if not _hand_has_tag(cards, "衙门"):
                        picked = _take_distinct(court_pool, used_keys)
                "field":
                    if not _hand_has_tag(cards, "田野"):
                        picked = _take_distinct(field_pool, used_keys)
                "military_court":
                    if not _hand_has_tag(cards, "衙门"):
                        picked = _take_distinct(military_court_pool, used_keys)
                    if picked.is_empty() and not _hand_has_tag(cards, "田野"):
                        picked = _take_distinct(field_pool, used_keys)
                "street":
                    if not _hand_has_tag(cards, "街巷"):
                        picked = _take_distinct(street_pool, used_keys)
                "alt":
                    if not _hand_has_tag(cards, "传闻") and not _hand_has_tag(cards, BINGYONG_CARD_TAG):
                        picked = _take_distinct(alt_pool, used_keys)
            if picked.is_empty():
                picked = _take_distinct(gov_pool, used_keys)
            if not picked.is_empty():
                cards.append(picked)
                used_keys.append(_month_card_identity_key(picked))


        while cards.size() < 5:
            var g: = _take_distinct(gov_pool, used_keys)
            if g.is_empty():
                break
            cards.append(g)
            used_keys.append(_month_card_identity_key(g))


    if str(game_state.get("active_line")) != "bianwu":
        _cap_unaffordable_cards_by_resource(game_state, cards, used_keys)

    if has_story and cards.size() > 1:
        var rest: Array = cards.slice(1)
        rest.shuffle()
        cards = [cards[0]] + rest
    elif not has_story:
        cards.shuffle()

    game_state.month_cards = cards
    _remember_visible_rumor_cards(game_state, cards)
    game_state.month_cards_done.clear()
    return game_state.month_cards

static func _generate_sun_chuanting_locked_month_cards(game_state: Node) -> Array:
    var cards: Array = []
    var branch: = str(game_state.get("branch"))
    var branch_idx: = int(game_state.get("branch_index"))
    var tags: Array[String] = []
    if game_state.get("tags") != null:
        for tag in game_state.get("tags"):
            tags.append(str(tag))

    var event_data: Dictionary = get_branch_event(branch, branch_idx, tags)
    if not event_data.is_empty():
        var event_id: = str(event_data.get("id", ""))
        cards.append({
            "type": "story", 
            "id": event_id, 
            "branch": branch, 
            "branch_index": branch_idx, 
            "title": event_data.get("title", "剧情事件"), 
            "tag": "终卷·抉择", 
            "direct": _is_direct_story_event(event_data)
        })

    game_state.month_cards = cards
    game_state.month_cards_done.clear()
    return game_state.month_cards




static func _card_line_ok(card_def: Dictionary, active_line: String) -> bool:
    var norm: = active_line if active_line != "" else "hanmen"
    var lines = card_def.get("lines", null)
    if lines == null:
        return norm == "hanmen"
    for l in lines:
        if str(l) == norm:
            return true
    return false

static func _build_regular_month_action_pool(game_state: Node, priority_trade_idx: int = -1) -> Array:
    var action_pool: Array = []
    var _al: = str(game_state.get("active_line")) if game_state != null else ""

    if _al == "bianwu":
        var bpools: = _build_bianwu_slot_pools(game_state)
        for slot in bpools:
            for it in bpools[slot]:
                action_pool.append(it)
        action_pool.shuffle()
        return action_pool
    for idx in range(GameData.GOVERNANCE_CARDS.size()):
        var gc: Dictionary = GameData.GOVERNANCE_CARDS[idx]
        if not _card_line_ok(gc, _al):
            continue

        if str(gc.get("cardCategory", "")) == BINGYONG_CARD_CATEGORY:
            continue
        if str(gc.get("specialType", "")) == "card_upgrade":
            continue

        if not _card_meets_resource_requirements(game_state, gc):
            continue
        var action_item: = {
            "type": "governance", 
            "idx": idx, 
            "id": str(gc.get("id", "")), 
            "title": gc.get("title", ""), 
            "tag": "政务"
        }
        if gc.has("note"):
            action_item["note"] = gc["note"]
        action_pool.append(action_item)
    for idx in range(GameData.TRADE_CARDS.size()):
        if idx == priority_trade_idx:
            continue
        var tc: Dictionary = GameData.TRADE_CARDS[idx]
        var trade_item: = {
            "type": "trade", 
            "idx": idx, 
            "id": str(tc.get("id", "")), 
            "title": tc.get("title", ""), 
            "tag": "交易"
        }
        if tc.has("note"):
            trade_item["note"] = tc["note"]
        action_pool.append(trade_item)
    for idx in range(GameData.HOME_ACTIONS.size()):
        var ha: Dictionary = GameData.HOME_ACTIONS[idx]
        action_pool.append({
            "type": "home", 
            "idx": idx, 
            "id": str(ha.get("id", "")), 
            "title": ha.get("title", ""), 
            "tag": "自宅"
        })

    var field_act: = _get_current_act(game_state)
    if field_act > 3:
        for idx in range(GameData.FIELD_ACTIONS.size()):
            var fa: Dictionary = GameData.FIELD_ACTIONS[idx]

            if str(fa.get("cardCategory", "")) == BINGYONG_CARD_CATEGORY:
                continue

            if not _card_meets_resource_requirements(game_state, fa):
                continue
            action_pool.append({
                "type": "field", 
                "idx": idx, 
                "id": str(fa.get("id", "")), 
                "title": fa.get("title", ""), 
                "tag": "田野"
            })


    if randf() < BINGYONG_CARD_HAND_CHANCE:
        var bingyong_members: = _collect_bingyong_member_cards(game_state)
        if not bingyong_members.is_empty():
            action_pool.append(bingyong_members[randi() % bingyong_members.size()])





    var recent_rumor_ids: = _get_recent_rumor_card_ids(game_state)
    if randf() < RUMOR_CARD_HAND_CHANCE:
        for idx in range(GameData.RUMOR_CARDS.size()):
            var rc: Dictionary = GameData.RUMOR_CARDS[idx]
            var rumor_id: = str(rc.get("id", ""))
            if recent_rumor_ids.has(rumor_id):
                continue
            if randf() < RUMOR_CARD_WEIGHT:
                action_pool.append({
                    "type": "rumor", 
                    "idx": idx, 
                    "id": rumor_id, 
                    "title": rc.get("title", ""), 
                    "tag": "传闻"
                })

    _weighted_shuffle_action_pool(action_pool, _get_current_act(game_state))
    return action_pool





static func _weighted_shuffle_action_pool(pool: Array, current_act: int) -> void :
    for item in pool:
        var key: = randf()
        if NONGSANG_CARD_IDS.has(str(item.get("id", ""))):
            key *= NONGSANG_CARD_SORT_BIAS
        item["_sort_key"] = key
    pool.sort_custom( func(a, b): return float(a["_sort_key"]) < float(b["_sort_key"]))
    for item in pool:
        item.erase("_sort_key")




const COST_RESOURCE_KEYS: = ["yinliang", "liangshi", "bingyong"]



static func _card_meets_resource_requirements(game_state: Node, card_def: Dictionary) -> bool:
    if game_state == null:
        return true
    var city: Dictionary = game_state.city if game_state.get("city") != null else {}

    var effects: Dictionary = get_action_effects_for_state(game_state, card_def)
    for key in COST_RESOURCE_KEYS:
        var cost: = int(effects.get(key, 0))
        if cost < 0 and int(city.get(key, 0)) < - cost:
            return false

    var required_tag: = str(card_def.get("requiresUnitTag", ""))
    if required_tag != "" and "bianwu_units" in game_state:
        var has_unit: = false
        for u in game_state.bianwu_units:
            if u is Dictionary:
                var uid: = str(u.get("id", ""))
                if BattleTypesRef.UNITS.has(uid) and BattleTypesRef.UNITS[uid].get("tags", []).has(required_tag):
                    has_unit = true
                    break
        if not has_unit:
            return false
    return true




static func _collect_bingyong_member_cards(game_state: Node = null) -> Array:
    var members: Array = []
    var _al: = str(game_state.get("active_line")) if game_state != null else ""
    for idx in range(GameData.GOVERNANCE_CARDS.size()):
        var gc: Dictionary = GameData.GOVERNANCE_CARDS[idx]
        if not _card_line_ok(gc, _al):
            continue
        if str(gc.get("cardCategory", "")) != BINGYONG_CARD_CATEGORY:
            continue
        if not _card_meets_resource_requirements(game_state, gc):
            continue
        var item: = {
            "type": "governance", 
            "idx": idx, 
            "id": str(gc.get("id", "")), 
            "title": gc.get("title", ""), 
            "tag": BINGYONG_CARD_TAG
        }
        if gc.has("note"):
            item["note"] = gc["note"]
        members.append(item)
    for idx in range(GameData.FIELD_ACTIONS.size()):
        var fa: Dictionary = GameData.FIELD_ACTIONS[idx]
        if str(fa.get("cardCategory", "")) != BINGYONG_CARD_CATEGORY:
            continue
        if not _card_meets_resource_requirements(game_state, fa):
            continue
        var item: = {
            "type": "field", 
            "idx": idx, 
            "id": str(fa.get("id", "")), 
            "title": fa.get("title", ""), 
            "tag": BINGYONG_CARD_TAG
        }
        if fa.has("note"):
            item["note"] = fa["note"]
        members.append(item)
    return members

static func _is_direct_story_event(event_data: Dictionary) -> bool:
    var choices: Array = event_data.get("choices", [])
    if choices.is_empty():
        return false
    var has_branch_choice: = false
    for choice in choices:
        if typeof(choice) != TYPE_DICTIONARY:
            continue
        if choice.has("enterBranch"):
            has_branch_choice = true
        else:
            return false
    return has_branch_choice




static func _hand_has_tag(cards: Array, tag: String) -> bool:
    for c in cards:
        if typeof(c) == TYPE_DICTIONARY and str(c.get("tag", "")) == tag:
            return true
    return false


static func _take_distinct(pool: Array, used_keys: Array) -> Dictionary:
    for item in pool:
        if typeof(item) != TYPE_DICTIONARY:
            continue
        var key: = _month_card_identity_key(item)
        if key == "" or used_keys.has(key):
            continue
        return item
    return {}


static func _take_affordable_distinct(game_state: Node, pool: Array, used_keys: Array) -> Dictionary:
    for item in pool:
        if typeof(item) != TYPE_DICTIONARY:
            continue
        var key: = _month_card_identity_key(item)
        if key == "" or used_keys.has(key):
            continue
        if _month_card_is_unaffordable(game_state, item):
            continue
        return item
    return {}



static func _cap_unaffordable_cards_by_resource(game_state: Node, cards: Array, used_keys: Array) -> void :
    var action_pts: = int(game_state.monthly_action_points())
    if action_pts < 2:
        return
    var max_blocked_total: = maxi(int(game_state.monthly_action_points()) - 1, 1)
    var max_blocked_per_resource: = maxi(int(game_state.monthly_action_points()) - 1, 1)
    _cap_unaffordable_positions(game_state, cards, used_keys, _month_card_unaffordable_positions(game_state, cards), max_blocked_total)
    var resource_keys: Array[String] = ["yinliang", "liangshi"]
    for resource_key in resource_keys:
        var blocked_positions: Array[int] = []
        for i in range(cards.size()):
            if _month_card_unaffordable_resource_keys(game_state, cards[i]).has(resource_key):
                blocked_positions.append(i)
        _cap_unaffordable_positions(game_state, cards, used_keys, blocked_positions, max_blocked_per_resource)

static func _month_card_unaffordable_positions(game_state: Node, cards: Array) -> Array[int]:
    var positions: Array[int] = []
    for i in range(cards.size()):
        if _month_card_is_unaffordable(game_state, cards[i]):
            positions.append(i)
    return positions

static func _cap_unaffordable_positions(game_state: Node, cards: Array, used_keys: Array, positions: Array[int], max_allowed: int) -> void :
    var need_replace: = positions.size() - max_allowed
    if need_replace <= 0:
        return
    var replace_pool: = _build_regular_month_action_pool(game_state)
    for pos in positions:
        if need_replace <= 0:
            break
        if pos < 0 or pos >= cards.size():
            continue
        if not _month_card_is_unaffordable(game_state, cards[pos]):
            continue
        var repl: = _take_affordable_distinct(game_state, replace_pool, used_keys)
        if repl.is_empty():
            break
        cards[pos] = repl
        used_keys.append(_month_card_identity_key(repl))
        need_replace -= 1



static func _month_card_is_unaffordable(game_state: Node, card: Dictionary) -> bool:
    return not _month_card_unaffordable_resource_keys(game_state, card).is_empty()

static func _month_card_unaffordable_resource_keys(game_state: Node, card: Dictionary) -> Array[String]:
    if typeof(card) != TYPE_DICTIONARY:
        return []
    var idx: = int(card.get("idx", -1))
    var event_data: Dictionary = {}
    match str(card.get("type", "")):
        "governance":
            if idx >= 0 and idx < GameData.GOVERNANCE_CARDS.size():
                event_data = _build_action_card_event(game_state, GameData.GOVERNANCE_CARDS[idx], "governance")
        "trade":
            if idx >= 0 and idx < GameData.TRADE_CARDS.size():
                event_data = _build_action_card_event(game_state, GameData.TRADE_CARDS[idx], "trade")
        "home":
            if idx >= 0 and idx < GameData.HOME_ACTIONS.size():
                event_data = _build_action_card_event(game_state, GameData.HOME_ACTIONS[idx], "home")
        "field":
            if idx >= 0 and idx < GameData.FIELD_ACTIONS.size():
                event_data = _build_action_card_event(game_state, GameData.FIELD_ACTIONS[idx], "field")
        _:
            return []
    if event_data.is_empty():
        return []
    return _event_unaffordable_resource_keys(game_state, event_data)

static func _event_unaffordable_resource_keys(game_state: Node, event_data: Dictionary) -> Array[String]:
    var choices: Array = event_data.get("choices", [])
    if choices.is_empty():
        return []
    var resource_keys: Array[String] = []
    for choice in choices:
        if typeof(choice) != TYPE_DICTIONARY:
            continue
        var blocked_keys: Array[String] = []
        var effects: Dictionary = choice.get("effects", {})
        var skip_limit_for: Array = choice.get("skipLimitFor", [])
        for key in effects:
            if key in skip_limit_for:
                continue
            var effect_val: = int(effects[key])
            if effect_val >= 0:
                continue
            var current_val: = 0
            if key == "private_silver":
                current_val = int(game_state.private_silver)
            elif game_state.stats.has(key):
                current_val = int(game_state.stats[key])
            elif game_state.city.has(key):
                current_val = int(game_state.city[key])
            elif game_state.attitudes.has(key):
                current_val = int(game_state.attitudes[key])
            if current_val + effect_val < 0 and key in ["private_silver", "yinliang", "liangshi", "bingyong", "action_points"]:
                blocked_keys.append(str(key))
        if blocked_keys.is_empty():
            return []
        for blocked_key in blocked_keys:
            if not resource_keys.has(blocked_key):
                resource_keys.append(blocked_key)
    return resource_keys



static func _event_choices_affordable(game_state: Node, event_data: Dictionary) -> bool:
    var choices: Array = event_data.get("choices", [])
    if choices.is_empty():
        return true
    for choice in choices:
        if typeof(choice) != TYPE_DICTIONARY:
            continue
        var affordable: = true
        var effects: Dictionary = choice.get("effects", {})
        var skip_limit_for: Array = choice.get("skipLimitFor", [])
        for key in effects:
            if key in skip_limit_for:
                continue
            var effect_val: = int(effects[key])
            if effect_val >= 0:
                continue
            var current_val: = 0
            if key == "private_silver":
                current_val = int(game_state.private_silver)
            elif game_state.stats.has(key):
                current_val = int(game_state.stats[key])
            elif game_state.city.has(key):
                current_val = int(game_state.city[key])
            elif game_state.attitudes.has(key):
                current_val = int(game_state.attitudes[key])
            if current_val + effect_val < 0 and key in ["private_silver", "yinliang", "liangshi", "bingyong", "action_points"]:
                affordable = false
                break
        if affordable:
            return true
    return false


const BIANWU_GARRISON_ACTS: = [1]


static func _get_bianwu_stage(game_state: Node) -> String:
    var current_act: = _get_current_act(game_state)
    if BIANWU_GARRISON_ACTS.has(current_act):
        return "garrison"
    return "frontline"





static func _build_bianwu_slot_pools(game_state: Node) -> Dictionary:
    var pools: = {"军务": [], "斥候": [], "边市": [], "军需": [], "应酬": [], "募兵": [], "传闻": []}
    var stage: = _get_bianwu_stage(game_state)
    for idx in range(GameData.GOVERNANCE_CARDS.size()):
        var gc: Dictionary = GameData.GOVERNANCE_CARDS[idx]
        if not _card_line_ok(gc, "bianwu"):
            continue
        var slot: = str(gc.get("bwSlot", ""))
        if not pools.has(slot):
            continue
        var card_stage: = str(gc.get("bwStage", "both"))
        if card_stage != "both" and card_stage != stage:
            continue
        if not _card_meets_resource_requirements(game_state, gc):
            continue
        var item: = {
            "type": "governance", 
            "idx": idx, 
            "id": str(gc.get("id", "")), 
            "title": gc.get("title", ""), 
            "tag": slot
        }
        if gc.has("note"):
            item["note"] = gc["note"]
        pools[slot].append(item)
    for slot in pools:
        pools[slot].shuffle()
    return pools




static func _fill_bianwu_slot_cards(game_state: Node, cards: Array, used_keys: Array, _has_story: bool) -> void :
    var pools: = _build_bianwu_slot_pools(game_state)
    var BianwuDefenseServiceRef = load("res://scripts/services/bianwu_defense_service.gd")
    BianwuDefenseServiceRef.ensure_initialized(game_state)
    var home_id: String = BianwuDefenseServiceRef.default_region_id(game_state)
    for region in game_state.bianwu_defense_regions:
        if not region is Dictionary:
            continue
        var region_id: = str(region.get("id", ""))
        if region_id == "":
            continue
        var tags: = _bianwu_region_card_tags(region)
        if region_id == home_id:

            for extra_tag in ["军务", "募兵", "军需"]:
                if not tags.has(extra_tag):
                    tags.append(extra_tag)
        var quota: = 3 if region_id == home_id else 2
        var picked_count: = 0
        for tag in tags:
            if picked_count >= quota:
                break
            var picked: = _take_distinct(pools.get(tag, []), used_keys)
            if picked.is_empty():
                continue
            picked["bw_region"] = region_id
            cards.append(picked)
            used_keys.append(_month_card_identity_key(picked))
            picked_count += 1
        if picked_count == 0:

            var fallback: = _take_distinct(pools.get("军务", []), used_keys)
            if not fallback.is_empty():
                fallback["bw_region"] = region_id
                cards.append(fallback)
                used_keys.append(_month_card_identity_key(fallback))
        if not BianwuDefenseServiceRef.enemy_in_region(game_state, region_id).is_empty():
            cards.append({
                "type": "bw_assault", 
                "id": "bw_assault_%s" % region_id, 
                "title": "兴兵进剿", 
                "tag": "军争", 
                "bw_region": region_id, 
                "note": "点选出战各部与督战将官，兴兵讨贼。出战须耗一点行动力。", 
            })



static func _bianwu_region_card_tags(region: Dictionary) -> Array:
    var region_type: = str(region.get("type", ""))
    if region_type.contains("城"):
        return ["应酬", "边市"]
    if region_type.contains("屯") or region_type.contains("乡") or region_type.contains("粮"):
        return ["军需", "军务"]
    if region_type.contains("驿") or region_type.contains("渡"):
        return ["边市", "传闻"]
    if region_type.contains("墩") or region_type.contains("墙") or region_type.contains("关") or region_type.contains("山"):
        return ["斥候", "传闻"]
    return ["军务", "募兵"]


static func _build_governance_class_pool(game_state: Node) -> Array:
    var pool: Array = []
    var _al: = str(game_state.get("active_line")) if game_state != null else ""
    for idx in range(GameData.GOVERNANCE_CARDS.size()):
        var gc: Dictionary = GameData.GOVERNANCE_CARDS[idx]
        if not _card_line_ok(gc, _al):
            continue
        if str(gc.get("cardCategory", "")) == BINGYONG_CARD_CATEGORY:
            continue
        if str(gc.get("specialType", "")) == "card_upgrade":
            continue

        if not _card_meets_resource_requirements(game_state, gc):
            continue
        var item: = {
            "type": "governance", 
            "idx": idx, 
            "id": str(gc.get("id", "")), 
            "title": gc.get("title", ""), 
            "tag": "政务"
        }
        if gc.has("note"):
            item["note"] = gc["note"]
        pool.append(item)
    for idx in range(GameData.TRADE_CARDS.size()):
        var tc: Dictionary = GameData.TRADE_CARDS[idx]
        var t_item: = {
            "type": "trade", 
            "idx": idx, 
            "id": str(tc.get("id", "")), 
            "title": tc.get("title", ""), 
            "tag": "交易"
        }
        if tc.has("note"):
            t_item["note"] = tc["note"]
        pool.append(t_item)
    for idx in range(GameData.HOME_ACTIONS.size()):
        var ha: Dictionary = GameData.HOME_ACTIONS[idx]
        pool.append({
            "type": "home", 
            "idx": idx, 
            "id": str(ha.get("id", "")), 
            "title": ha.get("title", ""), 
            "tag": "自宅"
        })
    pool.shuffle()

    if _get_current_act(game_state) > 3 and randf() < ZHENGWU_MASTER_ACT456_FRONT_CHANCE:
        for i in range(pool.size()):
            if str(pool[i].get("id", "")) == ZHENGWU_MASTER_ID:
                var card = pool[i]
                pool.remove_at(i)
                pool.push_front(card)
                break
    return pool


static func _is_court_case_city_eligible(game_state: Node, case_data: Dictionary) -> bool:
    var required_values: Dictionary = case_data.get("requireCityEquals", {})
    if required_values.is_empty():
        return true
    if game_state.city.is_empty():
        return false
    for key in required_values:
        if int(game_state.city.get(key, 0)) != int(required_values[key]):
            return false
    return true

static func _build_court_slot_pool(game_state: Node) -> Array:
    var pool: Array = []
    var act: = _get_current_act(game_state)
    var military_discipline_on_cooldown: bool = (
        game_state.has_method("is_military_discipline_case_on_cooldown")
        and bool(game_state.call("is_military_discipline_case_on_cooldown", MILITARY_DISCIPLINE_CASE_COOLDOWN_MONTHS))
    )
    for case_data in GameData.COURT_CASES:
        var case_id: = str(case_data.get("id", ""))
        if case_id == "":
            continue
        if military_discipline_on_cooldown and str(case_data.get("caseCategory", "")) == MILITARY_DISCIPLINE_CASE_CATEGORY:
            continue
        if str(case_data.get("sceneType", "")) == "street":
            continue
        if game_state.used_month_court.has(case_id) or game_state.used_case_ids.has(case_id):
            continue
        if case_data.has("requireAct") and int(case_data.get("requireAct", act)) != act:
            continue
        if int(case_data.get("requireActMin", act)) > act or int(case_data.get("requireActMax", act)) < act:
            continue
        if not _is_court_case_city_eligible(game_state, case_data):
            continue
        pool.append({
            "type": "court", 
            "case_id": case_id, 
            "title": case_data.get("title", ""), 
            "tag": "衙门"
        })
    for chain_data in GameData.CHAIN_CASES:
        var chain_id: = str(chain_data.get("id", ""))
        if chain_id == "":
            continue
        if game_state.used_chain_ids.has(chain_id):
            continue
        if not game_state.active_case_chain.is_empty():
            continue
        if not _is_chain_case_eligible(chain_data, act):
            continue
        var events: Array = chain_data.get("events", [])
        var first_event: Dictionary = events[0] if not events.is_empty() else {}
        pool.append({
            "type": "court_chain", 
            "chain_id": chain_id, 
            "event_index": 0, 
            "title": first_event.get("title", chain_data.get("title", "连环案")), 
            "tag": "衙门"
        })
    for visitor in GameData.VISITORS:
        var visitor_id: = str(visitor.get("id", ""))
        if visitor_id == "":
            continue
        if visitor.has("schedule"):
            continue
        if bool(visitor.get("jianwenOnly", false)):
            continue
        if game_state.used_month_visitors.has(visitor_id):
            continue
        if not _is_visitor_eligible(game_state, visitor, act):
            continue
        var is_court: bool = str(visitor.get("sceneType", "")) == "court" or bool(visitor.get("is_court_session", false)) or visitor_id == "v_xiangshen"
        if is_court:
            pool.append({
                "type": "visitor", 
                "visitor_id": visitor_id, 
                "title": visitor.get("title", ""), 
                "tag": "衙门"
            })
    pool.shuffle()
    return pool

static func _build_military_discipline_court_pool(game_state: Node) -> Array:
    var pool: Array = []
    var act: = _get_current_act(game_state)
    if act < 4 or act > 6 or int(game_state.city.get("bingyong", 0)) <= 0:
        return pool
    if game_state.has_method("is_military_discipline_case_on_cooldown") and game_state.is_military_discipline_case_on_cooldown(MILITARY_DISCIPLINE_CASE_COOLDOWN_MONTHS):
        return pool
    for case_data in GameData.COURT_CASES:
        if str(case_data.get("caseCategory", "")) != MILITARY_DISCIPLINE_CASE_CATEGORY:
            continue
        var case_id: = str(case_data.get("id", ""))
        if case_id == "" or game_state.used_month_court.has(case_id) or game_state.used_case_ids.has(case_id):
            continue
        if act < int(case_data.get("requireActMin", 4)) or act > int(case_data.get("requireActMax", 6)):
            continue
        if not _is_court_case_city_eligible(game_state, case_data):
            continue
        pool.append({
            "type": "court", 
            "case_id": case_id, 
            "title": case_data.get("title", ""), 
            "tag": "衙门"
        })
    pool.shuffle()
    return pool


static func _build_street_slot_pool(game_state: Node) -> Array:
    var pool: Array = []
    var act: = _get_current_act(game_state)
    for case_data in GameData.COURT_CASES:
        var case_id: = str(case_data.get("id", ""))
        if case_id == "":
            continue
        if str(case_data.get("sceneType", "")) != "street":
            continue
        if game_state.used_month_court.has(case_id) or game_state.used_case_ids.has(case_id):
            continue
        if case_data.has("requireAct") and int(case_data.get("requireAct", act)) != act:
            continue
        pool.append({
            "type": "court", 
            "case_id": case_id, 
            "title": case_data.get("title", ""), 
            "tag": "街巷"
        })
    for visitor in GameData.VISITORS:
        var visitor_id: = str(visitor.get("id", ""))
        if visitor_id == "":
            continue
        if visitor.has("schedule"):
            continue
        if bool(visitor.get("jianwenOnly", false)):
            continue
        if game_state.used_month_visitors.has(visitor_id):
            continue
        if not _is_visitor_eligible(game_state, visitor, act):
            continue
        var is_court: bool = str(visitor.get("sceneType", "")) == "court" or bool(visitor.get("is_court_session", false)) or visitor_id == "v_xiangshen"
        if not is_court:
            pool.append({
                "type": "visitor", 
                "visitor_id": visitor_id, 
                "title": visitor.get("title", ""), 
                "tag": "街巷"
            })
    pool.shuffle()
    return pool


static func _build_field_slot_pool(game_state: Node) -> Array:
    var pool: Array = []
    for idx in range(GameData.FIELD_ACTIONS.size()):
        var fa: Dictionary = GameData.FIELD_ACTIONS[idx]
        if str(fa.get("cardCategory", "")) == BINGYONG_CARD_CATEGORY:
            continue

        if not _card_meets_resource_requirements(game_state, fa):
            continue
        pool.append({
            "type": "field", 
            "idx": idx, 
            "id": str(fa.get("id", "")), 
            "title": fa.get("title", ""), 
            "tag": "田野"
        })
    pool.shuffle()
    return pool


static func _build_rumor_slot_pool(game_state: Node) -> Array:
    var pool: Array = []
    var recent: = _get_recent_rumor_card_ids(game_state)
    for idx in range(GameData.RUMOR_CARDS.size()):
        var rc: Dictionary = GameData.RUMOR_CARDS[idx]
        var rid: = str(rc.get("id", ""))
        if recent.has(rid):
            continue
        pool.append({
            "type": "rumor", 
            "idx": idx, 
            "id": rid, 
            "title": rc.get("title", ""), 
            "tag": "传闻"
        })
    pool.shuffle()
    return pool

static func _find_trade_card_index(trade_id: String) -> int:
    for idx in range(GameData.TRADE_CARDS.size()):
        var card: Dictionary = GameData.TRADE_CARDS[idx]
        if str(card.get("id", "")) == trade_id:
            return idx
    return -1

static func get_action_effects_for_state(game_state: Node, action_data: Dictionary) -> Dictionary:
    var effects: Dictionary = action_data.get("effects", {}).duplicate(true)
    var effects_by_act: Dictionary = action_data.get("effectsByAct", {})
    if not effects_by_act.is_empty():
        var act_key: = str(_get_current_act(game_state))
        var act_effects: Dictionary = effects_by_act.get(act_key, {})
        for key in act_effects:
            effects[key] = act_effects[key]


    var effects_by_stage: Dictionary = action_data.get("effectsByBwStage", {})
    if not effects_by_stage.is_empty() and _card_line_ok(action_data, "bianwu"):
        var stage_key: = _get_bianwu_stage(game_state)
        var stage_effects: Dictionary = effects_by_stage.get(stage_key, {})
        for key in stage_effects:
            effects[key] = stage_effects[key]
    if _is_card_upgraded(game_state, action_data):
        effects = _double_numeric_effects(effects)
    return effects

static func _is_card_upgraded(game_state: Node, action_data: Dictionary) -> bool:
    var card_id: = str(action_data.get("id", ""))
    if card_id == "":
        return false
    return game_state.upgraded_governance_cards.has(card_id)

static func _double_numeric_effects(effects: Dictionary) -> Dictionary:
    var doubled: Dictionary = {}
    for key in effects:
        var val = effects[key]
        if typeof(val) == TYPE_INT:
            doubled[key] = int(val) * 2
        elif typeof(val) == TYPE_FLOAT:
            doubled[key] = float(val) * 2.0
        else:
            doubled[key] = val
    return doubled

static func _is_card_upgrade_eligible(game_state: Node, card_data: Dictionary) -> bool:
    var require_any: Dictionary = card_data.get("requireAnyStat", {})
    if require_any.is_empty():
        return false
    var stats_match: = false
    for stat_key in require_any:
        var threshold: = int(require_any[stat_key])
        if int(game_state.stats.get(stat_key, 0)) >= threshold:
            stats_match = true
            break
    if not stats_match:
        return false
    var options: Array = card_data.get("upgradeOptions", [])
    for opt in options:
        if typeof(opt) != TYPE_DICTIONARY:
            continue
        var target_id: = str(opt.get("target_id", ""))
        if target_id == "":
            continue
        if game_state.upgraded_governance_cards.has(target_id):
            continue
        return true
    return false

static func _should_prioritize_buy_grain(game_state: Node) -> bool:
    if game_state.city.is_empty():
        return false
    var buy_idx: = _find_trade_card_index("tc_buy_grain")
    if buy_idx < 0:
        return false
    var buy_card: Dictionary = GameData.TRADE_CARDS[buy_idx]
    var effects: Dictionary = get_action_effects_for_state(game_state, buy_card)
    var grain_gain: = int(effects.get("liangshi", 1000))
    var silver_cost: = absi(int(effects.get("yinliang", -1200)))
    if grain_gain <= 0 or silver_cost <= 0:
        return false
    var grain_stock: = int(game_state.city.get("liangshi", 0))
    var silver_stock: = int(game_state.city.get("yinliang", 0))
    var soldier_grain_need: = int(game_state.city.get("bingyong", 0))
    var low_grain_threshold: = maxi(grain_gain, soldier_grain_need)
    return grain_stock <= low_grain_threshold and silver_stock >= silver_cost * 2




static func _materialized_month_cards(game_state: Node) -> Array:
    if not game_state.month_cards.is_empty():
        sanitize_cached_month_cards(game_state)
        return game_state.month_cards
    return generate_month_cards(game_state)

static func execute_month_card(game_state: Node, card_index: int) -> Dictionary:
    var cards: Array = _materialized_month_cards(game_state)
    if card_index < 0 or card_index >= cards.size():
        return {}
    if game_state.action_points <= 0:
        return {}
    if game_state.month_cards_done.has(card_index):
        return {}

    var selected_card: Dictionary = cards[card_index]
    if _story_card_blocks_selection(game_state, selected_card):
        return {}
    if _riot_card_blocks_selection(game_state, selected_card):
        return {}
    if _mutiny_card_blocks_selection(game_state, selected_card):
        return {}
    if str(selected_card.get("type", "")) == "court_chain":
        var chain_id: = str(selected_card.get("chain_id", ""))
        if chain_id != "":
            game_state.active_case_chain = {
                "chain_id": chain_id, 
                "event_index": int(selected_card.get("event_index", 0))
            }
            if not game_state.used_chain_ids.has(chain_id):
                game_state.used_chain_ids.append(chain_id)

    game_state.current_month_card_index = card_index
    var event_payload: Dictionary = get_month_card_event(game_state, card_index)
    return {
        "card": selected_card, 
        "event": event_payload
    }

static func get_month_card_event(game_state: Node, card_index: int) -> Dictionary:
    var cards: Array = _materialized_month_cards(game_state)
    if card_index < 0 or card_index >= cards.size():
        return {}
    var card: Dictionary = cards[card_index]
    var event_data: Dictionary = {}
    match card.get("type", ""):
        "story":
            if card.has("branch"):
                var tags: Array[String] = []
                if game_state.get("tags") != null:
                    for tag in game_state.get("tags"):
                        tags.append(str(tag))
                event_data = get_branch_event(str(card.get("branch", "")), int(card.get("branch_index", 0)), tags, game_state)
            else:
                event_data = _find_event_by_id(str(card.get("id", "")))
        "attitude":
            event_data = _find_attitude_event_by_id(str(card.get("id", ""))).duplicate(true)
        "governance":
            var idx: int = card.get("idx", -1)
            if idx >= 0 and idx < GameData.GOVERNANCE_CARDS.size():
                event_data = _build_action_card_event(game_state, GameData.GOVERNANCE_CARDS[idx], "governance")
            else:
                event_data = {"id": "error", "title": "无效卡片", "desc": "数据版本变更，此行动卡已失效。", "choices": []}
        "trade":
            var idx: int = card.get("idx", -1)
            if idx >= 0 and idx < GameData.TRADE_CARDS.size():
                event_data = _build_action_card_event(game_state, GameData.TRADE_CARDS[idx], "trade")
            else:
                event_data = {"id": "error", "title": "无效卡片", "desc": "数据版本变更，此交易卡已失效。", "choices": []}
        "home":
            var idx: int = card.get("idx", -1)
            if idx >= 0 and idx < GameData.HOME_ACTIONS.size():
                event_data = _build_action_card_event(game_state, GameData.HOME_ACTIONS[idx], "home")
            else:
                event_data = {"id": "error", "title": "无效卡片", "desc": "数据版本变更，此行动卡已失效。", "choices": []}
        "field":
            var idx: int = card.get("idx", -1)
            if idx >= 0 and idx < GameData.FIELD_ACTIONS.size():
                event_data = _build_action_card_event(game_state, GameData.FIELD_ACTIONS[idx], "field")
            else:
                event_data = {"id": "error", "title": "无效卡片", "desc": "数据版本变更，此行动卡已失效。", "choices": []}
        "rumor":
            var idx: int = card.get("idx", -1)
            if idx >= 0 and idx < GameData.RUMOR_CARDS.size():
                event_data = _build_rumor_card_event(game_state, GameData.RUMOR_CARDS[idx])
            else:
                event_data = {"id": "error", "title": "无效卡片", "desc": "数据版本变更，此传闻卡已失效。", "choices": []}
        "court":
            var court_case: = _find_court_case_by_id(str(card.get("case_id", "")))
            if court_case.is_empty():
                event_data = {"id": "error", "title": "无效案卷", "stage": "案卷已迁移", "speaker": GOVERNANCE_SPEAKERS["court"], "speakerLine": "", "narrative": "这桩案卷已经随内容版本迁移，当前存档中的旧案号不再有效。请返回本月手牌重新进入。", "flavor": "", "focusLine": "", "choices": []}
            else:
                event_data = _build_court_case_event(court_case)
        "court_chain":
            event_data = _build_chain_case_event(game_state, str(card.get("chain_id", "")), int(card.get("event_index", 0)))
        "visitor":
            event_data = _build_visitor_event(_find_visitor_by_id(str(card.get("visitor_id", ""))))
        "riot":
            event_data = _build_riot_event(game_state, int(card.get("riot_level", 1)))
        "mutiny":
            event_data = _build_mutiny_event(game_state, int(card.get("mutiny_level", 1)))
        "grain_shortage":
            event_data = _build_grain_shortage_event()
        _:
            return {}
    if not event_data.has("year") or int(event_data.get("year", 0)) <= 0:
        event_data["year"] = int(game_state.year)
    if not event_data.has("month") or int(event_data.get("month", 0)) <= 0:
        event_data["month"] = int(game_state.month)
    return event_data

static func complete_month_card(game_state: Node, card_index: int, auto_advance_month: bool = true) -> void :
    if card_index < 0:
        return
    var cards: Array = _materialized_month_cards(game_state)
    if card_index >= cards.size():
        return
    var completed_card: Dictionary = cards[card_index]
    var waive_action_point: = PersonalStatCapstoneServiceRef.should_waive_action_point(game_state, completed_card)
    if not game_state.month_cards_done.has(card_index):
        game_state.month_cards_done.append(card_index)
    game_state.current_month_card_index = -1
    if game_state.has_method("is_after_sun_chuanting_branch_split") and game_state.is_after_sun_chuanting_branch_split():
        game_state.branch_index += 1
        game_state.action_points = 0
    elif not waive_action_point:
        game_state.action_points = maxi(game_state.action_points - 1, 0)
    game_state.turn += 1
    if auto_advance_month and game_state.action_points <= 0:
        advance_month(game_state)
    game_state.state_changed.emit()

static func finalize_month_card_choice(game_state: Node, card_index: int, choice: Dictionary) -> void :
    var cards: Array = _materialized_month_cards(game_state)
    if card_index < 0 or card_index >= cards.size():
        return
    var card: Dictionary = cards[card_index]
    match str(card.get("type", "")):
        "court":
            var case_id: = str(card.get("case_id", ""))
            if case_id != "":
                if not game_state.used_case_ids.has(case_id):
                    game_state.used_case_ids.append(case_id)
                if not game_state.used_month_court.has(case_id):
                    game_state.used_month_court.append(case_id)
        "court_chain":
            _finalize_chain_choice(game_state, card, choice)
        "visitor":
            var visitor_id: = str(card.get("visitor_id", ""))
            if visitor_id != "":
                if not game_state.used_month_visitors.has(visitor_id):
                    game_state.used_month_visitors.append(visitor_id)
                if not game_state.month_visitors.has(visitor_id):
                    game_state.month_visitors.append(visitor_id)
                var visitor_def: = _find_visitor_by_id(visitor_id)
                if not visitor_def.is_empty():
                    _remove_pending_scheduled_visitor(game_state, visitor_id)
                    var chain_id: = str(visitor_def.get("chainId", ""))
                    var chain_outcome: = str(choice.get("chainOutcome", ""))
                    if chain_id != "" and chain_outcome != "":
                        var previous_chain_state: Dictionary = game_state.historical_chains.get(chain_id, {})
                        var chain_history: Array = previous_chain_state.get("history", [])
                        chain_history.append(chain_outcome)
                        game_state.historical_chains[chain_id] = {
                            "outcome": chain_outcome, 
                            "chapter": int(visitor_def.get("chainChapter", 1)), 
                            "actMet": _get_current_act(game_state), 
                            "history": chain_history, 
                            "resolvedMonthIndex": game_state.year * 12 + game_state.month
                        }

static func advance_month(game_state: Node) -> void :
    if game_state.has_method("repair_governance_city_for_current_act"):
        game_state.repair_governance_city_for_current_act()
    if _recover_overdue_terminal_fork(game_state):
        return
    var old_act_before_advance: = _get_current_act(game_state)
    _age_pending_scheduled_visitors(game_state, old_act_before_advance)
    game_state.month += 1
    game_state.action_points = game_state.monthly_action_points()
    game_state.month_cards = []
    game_state.month_cards_done.clear()
    game_state.current_month_card_index = -1
    game_state.month_visitors.clear()
    game_state.active_case_chain = {}
    if game_state.month > GameData.MONTHS_PER_YEAR:
        var old_act: = old_act_before_advance
        game_state.month = 1
        game_state.year += 1
        var next_act: = _get_current_act(game_state)
        var act_key: = str(next_act)
        if next_act != old_act and GameData.ACT_TRANSITIONS.has(act_key):
            _drop_scheduled_visitors_for_finished_act(game_state, next_act)

            var kept_followups: Array = []
            for fu in game_state.pending_follow_ups:
                if str(fu.get("type", "")) == "court_chain":
                    continue
                kept_followups.append(fu)
            game_state.pending_follow_ups = kept_followups
            game_state.active_case_chain = {}
            var transition: Dictionary = GameData.ACT_TRANSITIONS[act_key]
            var high_cfg: Dictionary = transition.get("high_minwang", {})
            var attitude_key: = str(high_cfg.get("require_attitude", "minwang"))
            var threshold: = int(high_cfg.get("threshold", 80))
            var is_high_minwang: = int(game_state.attitudes.get(attitude_key, 0)) >= threshold
            if is_high_minwang:
                var reward_item: = str(high_cfg.get("reward_item", ""))
                if reward_item != "" and not game_state.items.has(reward_item):
                    game_state.items.append(reward_item)

                    var owned_plaque_evals: Array = []
                    if game_state.dezheng_plaque_evals is Dictionary:
                        owned_plaque_evals = game_state.dezheng_plaque_evals.values()
                    var plaque_eval: = DezhengPlaqueService.compute_eval(game_state, old_act, owned_plaque_evals)
                    game_state.dezheng_plaque_evals[reward_item] = plaque_eval

            var old_act_key: = str(old_act)
            var old_city_cfg: Dictionary = GameData.CITY_BY_ACT.get(old_act_key, {})
            var old_prov = game_state.city.get("province", old_city_cfg.get("province", "未知"))
            var old_name = game_state.city.get("name", old_city_cfg.get("name", "未知"))

            game_state.set_meta("pending_act_transition", {
                "act": act_key, 
                "high_minwang": is_high_minwang, 
                "from_str": "%s · %s" % [old_prov, old_name], 
                "old_city_name": old_name
            })
        if next_act != old_act and GameData.CITY_BY_ACT.has(act_key):
            var city_cfg: Dictionary = GameData.CITY_BY_ACT[act_key]
            game_state.city = city_cfg.get("defaults", {}).duplicate()
            game_state.city["zhengji"] = int(game_state.city.get("zhengji", 0))

            if game_state.has_method("reset_term_tenure_counters"):
                game_state.reset_term_tenure_counters()
            var transfer_city: Dictionary = game_state.resolve_transfer_city_for_act(act_key, game_state.get_rank_title())
            game_state.city["name"] = transfer_city.get("name", city_cfg.get("name", ""))
            game_state.city["juris"] = transfer_city.get("juris", city_cfg.get("juris", ""))
            game_state.city["province"] = transfer_city.get("province", city_cfg.get("province", ""))



            game_state.applied_carried_city_effects.clear()
            if game_state.has_method("apply_carried_item_city_effects"):
                game_state.apply_carried_item_city_effects()
            if game_state.has_method("normalize_personal_boost_item_slots"):

                game_state.normalize_personal_boost_item_slots()

            game_state.set_meta("suppress_month_resource_delta", true)
    if not (game_state.has_method("is_after_sun_chuanting_branch_split") and game_state.is_after_sun_chuanting_branch_split()):
        game_state.process_monthly_production()

    if game_state.get_meta("suppress_month_resource_delta", false):
        game_state.last_month_resource_delta = {}
        game_state.remove_meta("suppress_month_resource_delta")

    if game_state.has_method("apply_bianwu_monthly_attitude_tick"):
        game_state.apply_bianwu_monthly_attitude_tick()
    BianwuDefenseServiceRef.process_month_end(game_state)

static func _queue_due_scheduled_visitors(game_state: Node, now_time: int) -> void :
    var act: = _get_current_act(game_state)
    var queued_ids: Array = []
    for pending in game_state.pending_scheduled_visitors:
        queued_ids.append(str(pending.get("visitor_id", "")))
    for visitor in GameData.VISITORS:
        var visitor_id: = str(visitor.get("id", ""))
        if visitor_id == "" or queued_ids.has(visitor_id):
            continue
        if game_state.resolved_scheduled_visitors.has(visitor_id):
            continue
        if not visitor.has("schedule"):
            continue
        if game_state.used_month_visitors.has(visitor_id):
            continue
        if not _is_visitor_eligible(game_state, visitor, act):
            continue
        var schedule: Dictionary = visitor.get("schedule", {})
        var schedule_year: = int(schedule.get("year", 0))

        if act < _act_for_year(schedule_year):
            continue
        var due_time: = schedule_year * 12 + int(schedule.get("month", 0))
        if due_time > 0 and due_time <= now_time:
            game_state.pending_scheduled_visitors.append({
                "visitor_id": visitor_id, 
                "act": act, 
                "missed_turns": 0
            })
            queued_ids.append(visitor_id)

static func _age_pending_scheduled_visitors(game_state: Node, current_act: int) -> void :
    var kept: Array = []
    for pending in game_state.pending_scheduled_visitors:
        var visitor_id: = str(pending.get("visitor_id", ""))
        var visitor_def: = _find_visitor_by_id(visitor_id)
        if visitor_def.is_empty():
            continue
        if int(pending.get("act", current_act)) != current_act:
            continue
        var schedule: Dictionary = visitor_def.get("schedule", {})

        if bool(schedule.get("retryMode", false)):
            var cooldown: = int(pending.get("cooldown", 0))
            if cooldown > 0:

                var waiting: Dictionary = pending.duplicate(true)
                waiting["cooldown"] = cooldown - 1
                waiting["shown_pending"] = false
                kept.append(waiting)
                continue

            if not bool(pending.get("shown_pending", false)):

                var pass_pending: Dictionary = pending.duplicate(true)
                pass_pending["cooldown"] = 0
                pass_pending["shown_pending"] = false
                kept.append(pass_pending)
                continue

            var appearances: = int(pending.get("appearances", 0)) + 1
            var gap_min: = int(schedule.get("retryGapMin", 2))
            var gap_max: = int(schedule.get("retryGapMax", 3))
            var gap: = gap_min
            if gap_max > gap_min:
                gap += randi() % (gap_max - gap_min + 1)
            var retry_pending: Dictionary = pending.duplicate(true)
            retry_pending["appearances"] = appearances

            retry_pending["cooldown"] = max(gap - 1, 0)
            retry_pending["shown_pending"] = false
            kept.append(retry_pending)
            continue


        var next_pending: Dictionary = pending.duplicate(true)
        next_pending["missed_turns"] = int(pending.get("missed_turns", 0)) + 1
        kept.append(next_pending)
    game_state.pending_scheduled_visitors = kept

static func _drop_scheduled_visitors_for_finished_act(game_state: Node, next_act: int) -> void :


    var kept: Array = []
    for pending in game_state.pending_scheduled_visitors:
        if int(pending.get("act", next_act)) == next_act:
            kept.append(pending)
        else:
            var carried: Dictionary = pending.duplicate(true)
            carried["act"] = next_act
            carried["missed_turns"] = 0
            carried["cooldown"] = 0
            carried["shown_pending"] = false
            kept.append(carried)
    game_state.pending_scheduled_visitors = kept

static func _remove_pending_scheduled_visitor(game_state: Node, visitor_id: String) -> void :
    var kept: Array = []
    for pending in game_state.pending_scheduled_visitors:
        if str(pending.get("visitor_id", "")) != visitor_id:
            kept.append(pending)
    game_state.pending_scheduled_visitors = kept
    if visitor_id != "" and not game_state.resolved_scheduled_visitors.has(visitor_id):
        game_state.resolved_scheduled_visitors.append(visitor_id)

static func _build_rumor_card_event(game_state: Node, rumor_data: Dictionary) -> Dictionary:
    if rumor_data.is_empty():
        return {}
    var speaker: Dictionary = GOVERNANCE_SPEAKERS["rumor"]
    var turn_label: = get_governance_turn_label(game_state)
    var stage_label: = get_governance_stage_label(game_state)
    var success_rate: float = float(rumor_data.get("successRate", 0.5))
    var success_pct: int = int(round(success_rate * 100.0))
    return {
        "id": rumor_data.get("id", ""), 
        "title": rumor_data.get("title", ""), 
        "stage": "%s · %s" % [stage_label, turn_label], 
        "year": game_state.year, 
        "speaker": speaker, 
        "speakerLine": rumor_data.get("comment", ""), 
        "narrative": rumor_data.get("desc", ""), 
        "flavor": "坊间传言，真伪难辨，勘验或有所得。", 
        "focusLine": "本月只剩 %d 点行动力，你准备如何落子？" % game_state.action_points, 
        "choices": [
            {
                "title": "【%s】" % str(rumor_data.get("action", "派人查验")), 
                "description": "胜算约 %d%%，成则有获，败则无所得。" % success_pct, 
                "effects": {}, 
                "pureChance": success_rate, 
                "diceWinEffects": rumor_data.get("successEffects", {}), 
                "diceWinComment": rumor_data.get("successComment", ""), 
                "failComment": rumor_data.get("failComment", ""), 
                "systemComment": rumor_data.get("successComment", "")
            }
        ]
    }

static func _build_action_card_event(game_state: Node, action_data: Dictionary, action_type: String) -> Dictionary:
    if action_data.is_empty():
        return {}
    if str(action_data.get("specialType", "")) == "card_upgrade":
        return _build_card_upgrade_event(game_state, action_data, action_type)
    var speaker: Dictionary = GOVERNANCE_SPEAKERS.get(action_type, GOVERNANCE_SPEAKERS["governance"])
    var turn_label: = get_governance_turn_label(game_state)
    var stage_label: = get_governance_stage_label(game_state)
    var merged_effects: = {}
    var base_effects: Dictionary = get_action_effects_for_state(game_state, action_data)
    var att_effects: Dictionary = action_data.get("attEffects", {}).duplicate(true)
    if _is_card_upgraded(game_state, action_data):
        att_effects = _double_numeric_effects(att_effects)
    for k in base_effects:
        merged_effects[k] = base_effects[k]
    for k in att_effects:
        merged_effects[k] = att_effects[k]
    var action_choice: = {
        "title": "【照此施行】", 
        "description": action_data.get("desc", ""), 
        "effects": merged_effects, 
        "tags": action_data.get("tags", []), 
        "systemComment": action_data.get("comment", "")
    }
    for defense_key in ["commandPoints", "grantBianwuOfficer", "regionStability"]:
        if action_data.has(defense_key):
            action_choice[defense_key] = action_data[defense_key]

    return {
        "id": action_data.get("id", ""), 
        "title": action_data.get("title", ""), 
        "stage": "%s · %s" % [stage_label, turn_label], 
        "year": game_state.year, 
        "speaker": speaker, 
        "speakerLine": "", 
        "narrative": action_data.get("comment", ""), 
        "flavor": _action_flavor_text(action_type), 
        "focusLine": "本月只剩 %d 点行动力，你准备如何落子？" % game_state.action_points, 
        "choices": [action_choice]
    }

const _STAT_LABEL_MAP: = {
    "wentao": "文韬", 
    "wulue": "武略", 
    "lizheng": "理政", 
    "tizhi": "体质"
}

static func _build_card_upgrade_event(game_state: Node, action_data: Dictionary, action_type: String) -> Dictionary:
    var speaker: Dictionary = GOVERNANCE_SPEAKERS.get(action_type, GOVERNANCE_SPEAKERS["governance"])
    var turn_label: = get_governance_turn_label(game_state)
    var stage_label: = get_governance_stage_label(game_state)
    var choices: Array = []
    var options: Array = action_data.get("upgradeOptions", [])
    for opt in options:
        if typeof(opt) != TYPE_DICTIONARY:
            continue
        var target_id: = str(opt.get("target_id", ""))
        if target_id == "":
            continue
        if game_state.upgraded_governance_cards.has(target_id):
            continue
        var target_card: = _find_governance_card_by_id(target_id)
        if target_card.is_empty():
            continue
        var cost_stat: = str(opt.get("cost_stat", "lizheng"))
        var cost_amount: = int(opt.get("cost", 20))
        var stat_label: = str(_STAT_LABEL_MAP.get(cost_stat, cost_stat))
        var target_title: = str(opt.get("target_title", target_card.get("title", "")))
        var before_preview: = _format_effects_list(target_card)
        var after_preview: = _format_effects_list_doubled(target_card)
        var description: = "消耗 %d 点%s。升级前「%s」：%s；升级后：%s" % [cost_amount, stat_label, target_title, before_preview, after_preview]
        var effects: = {}
        effects[cost_stat] = - cost_amount
        var require_fn: = "stat('%s') >= %d" % [cost_stat, cost_amount]
        choices.append({
            "title": "【精研·%s】" % target_title, 
            "description": description, 
            "effects": effects, 
            "requireFn": require_fn, 
            "upgradeCardId": target_id, 
            "systemComment": "此政已然驾轻就熟，「%s」今后施行，事半而功倍。" % target_title
        })
    if choices.is_empty():
        choices.append({
            "title": "【暂且作罢】", 
            "description": "暂无可再精研的政务。", 
            "effects": {}, 
            "systemComment": "今日只是翻了翻旧档，未动笔墨。"
        })
    return {
        "id": action_data.get("id", ""), 
        "title": action_data.get("title", ""), 
        "stage": "%s · %s" % [stage_label, turn_label], 
        "year": game_state.year, 
        "speaker": speaker, 
        "speakerLine": "", 
        "narrative": action_data.get("comment", ""), 
        "flavor": "做久了一桩政事，便能看出其中可改可省之处。", 
        "focusLine": "你想把哪一桩政务真正做到纯熟？", 
        "choices": choices
    }

static func _find_governance_card_by_id(card_id: String) -> Dictionary:
    if card_id == "":
        return {}
    for card in GameData.GOVERNANCE_CARDS:
        if typeof(card) == TYPE_DICTIONARY and str(card.get("id", "")) == card_id:
            return card
    return {}

const _LEVEL_STAT_KEYS: = ["nongsang", "chengfang", "shangmao", "baigong", "wenjiao"]

static func _get_upgrade_effect_label(key: String) -> String:
    var base: = _get_effect_label(key)
    if key in _LEVEL_STAT_KEYS:
        return base + "等级"
    return base

static func _format_effects_list(target_card: Dictionary) -> String:
    var parts: Array[String] = []
    var effects: Dictionary = target_card.get("effects", {})
    var att_effects: Dictionary = target_card.get("attEffects", {})
    for src in [effects, att_effects]:
        for key in src:
            var val = src[key]
            if typeof(val) != TYPE_INT and typeof(val) != TYPE_FLOAT:
                continue
            var label: = _get_upgrade_effect_label(key)
            var sign: = "+" if float(val) > 0 else ""
            parts.append("%s %s%s" % [label, sign, _format_effect_number(val)])
    if parts.is_empty():
        return "无特殊效果"
    return "，".join(parts)

static func _format_effects_list_doubled(target_card: Dictionary) -> String:
    var parts: Array[String] = []
    var effects: Dictionary = target_card.get("effects", {})
    var att_effects: Dictionary = target_card.get("attEffects", {})
    for src in [effects, att_effects]:
        for key in src:
            var val = src[key]
            if typeof(val) != TYPE_INT and typeof(val) != TYPE_FLOAT:
                continue
            var label: = _get_upgrade_effect_label(key)
            var doubled = val * 2
            var sign: = "+" if float(doubled) > 0 else ""
            parts.append("%s %s%s" % [label, sign, _format_effect_number(doubled)])
    if parts.is_empty():
        return "效用加倍"
    return "，".join(parts)

static func _format_upgrade_preview(target_card: Dictionary) -> String:
    var parts: Array[String] = []
    var effects: Dictionary = target_card.get("effects", {})
    var att_effects: Dictionary = target_card.get("attEffects", {})
    for src in [effects, att_effects]:
        for key in src:
            var val = src[key]
            if typeof(val) != TYPE_INT and typeof(val) != TYPE_FLOAT:
                continue
            var label: = _get_upgrade_effect_label(key)
            parts.append("%s %s→%s" % [label, _format_effect_number(val), _format_effect_number(val * 2)])
    if parts.is_empty():
        return "效用加倍"
    return "，".join(parts)

static func _format_effect_number(val) -> String:
    var num: = float(val)
    if is_equal_approx(num, round(num)):
        return str(int(round(num)))
    return str(num)

static func _get_effect_label(key: String) -> String:
    if _STAT_LABEL_MAP.has(key):
        return _STAT_LABEL_MAP[key]
    if GameData.CITY_STAT_LABELS.has(key):
        return str(GameData.CITY_STAT_LABELS[key])
    if GameData.ATT_LABELS.has(key):
        return GameData.attitude_effect_label(key)
    match key:
        "liangshi": return "官粮"
        "yinliang": return "库银"
        "bingyong": return "兵勇"
        "liumin": return "流民"
        "zhengji": return "政绩"
        "guanjun":
            var label: = "官军"
            var GameState = Engine.get_main_loop().current_scene.get_node("/root/GameState") if (Engine.get_main_loop() and Engine.get_main_loop().current_scene) else null
            if is_instance_valid(GameState) and "bianwu_units" in GameState and not GameState.bianwu_units.is_empty():
                for u in GameState.bianwu_units:
                    if u is Dictionary and not u.get("is_jiading", false):
                        label = u.get("name", label)
                        break
            return label
        "jiading":
            var label: = "家丁"
            var GameState = Engine.get_main_loop().current_scene.get_node("/root/GameState") if (Engine.get_main_loop() and Engine.get_main_loop().current_scene) else null
            if is_instance_valid(GameState) and "bianwu_units" in GameState and not GameState.bianwu_units.is_empty():
                for u in GameState.bianwu_units:
                    if u is Dictionary and u.get("is_jiading", false):
                        label = u.get("name", label)
                        break
            return label
        "liangcao": return "粮草"
        "xiangyin": return "饷银"
        "mapi": return "马匹"
        "huoqi": return "火器"
        "zhanyi": return "战意"


        _: return str(GameData.STAT_LABELS.get(key, key))

static func _build_court_case_event(case_data: Dictionary) -> Dictionary:
    if case_data.is_empty():
        return {}
    var is_street: = str(case_data.get("sceneType", "")) == "street"
    var default_speaker: Dictionary = GOVERNANCE_SPEAKERS["visitor"] if is_street else GOVERNANCE_SPEAKERS["court"]
    var default_stage: = "街巷事件" if is_street else "升堂问案"
    var default_flavor: = "街头巷尾的风声，传得比告示快，也比案卷乱。" if is_street else "堂上一拍惊堂木，判的是是非，也判你往后怎么做人。"
    var default_focus: = "人声已经聚起来了，你准备怎么处置？" if is_street else "案卷和人心都摆在公堂上，你准备怎么断？"
    return {
        "id": case_data.get("id", ""), 
        "title": case_data.get("title", ""), 
        "stage": case_data.get("stage", default_stage), 
        "speaker": _normalize_speaker(case_data.get("speaker", default_speaker), default_speaker), 
        "speakerLine": "", 
        "narrative": case_data.get("narrative", ""), 
        "flavor": case_data.get("flavor", default_flavor), 
        "focusLine": case_data.get("focusLine", default_focus), 
        "choices": _normalize_choices(case_data.get("choices", [])), 

        "is_court_session": not is_street
    }

static func _normalize_speaker(raw_speaker, default_speaker: Dictionary) -> Dictionary:
    var speaker: = default_speaker.duplicate(true)
    if raw_speaker is Dictionary:
        speaker.merge(raw_speaker, true)
        return speaker
    var speaker_name: = str(raw_speaker).strip_edges()
    if speaker_name != "":
        speaker["name"] = speaker_name
    return speaker

static func _build_chain_case_event(game_state: Node, chain_id: String, event_index: int) -> Dictionary:
    var chain_data: = _find_chain_case_by_id(chain_id)
    if chain_data.is_empty():
        return {}
    var events: Array = chain_data.get("events", [])
    if event_index < 0 or event_index >= events.size():
        return {}
    var event_data: Dictionary = events[event_index]
    var narrative: String = event_data.get("narrative", "")
    var summary: String = event_data.get("previousSummary", "")
    if event_index > 0 and summary != "":
        narrative = summary + "\n\n——————\n\n" + narrative
    return {
        "id": "%s_%d" % [chain_id, event_index], 
        "title": event_data.get("title", chain_data.get("title", "连环案")), 
        "stage": chain_data.get("title", "连环案"), 
        "speaker": GOVERNANCE_SPEAKERS["court"], 
        "speakerLine": "", 
        "narrative": narrative, 
        "flavor": "连环旧案最怕草草翻过，一处松手，后头就会反咬回来。", 
        "focusLine": "案中有案，这一回你的手准备伸到哪一步？", 
        "choices": _normalize_choices(event_data.get("choices", [])), 
        "is_court_session": true
    }

static func _build_visitor_event(visitor_data: Dictionary) -> Dictionary:
    if visitor_data.is_empty():
        return {}
    var encounter: Dictionary = visitor_data.get("encounter", {})
    var is_court: bool = str(visitor_data.get("sceneType", "")) == "court" or str(encounter.get("sceneType", "")) == "court" or bool(visitor_data.get("is_court_session", false)) or visitor_data.get("id", "") == "v_xiangshen"
    var default_speaker: = GOVERNANCE_SPEAKERS["court"] if is_court else GOVERNANCE_SPEAKERS["visitor"]
    var default_stage: = "升堂问案" if is_court else "街巷奇遇"
    var default_flavor: = "堂上一拍惊堂木，判的是是非，也判你往后怎么做人。" if is_court else "县衙之外的来人，往往比公文更早把风声和机会送到你面前。"
    return {
        "id": visitor_data.get("id", ""), 
        "title": visitor_data.get("title", ""), 
        "stage": visitor_data.get("stage", default_stage), 
        "speaker": visitor_data.get("speaker", default_speaker), 
        "speakerLine": "", 
        "narrative": encounter.get("narrative", ""), 
        "flavor": visitor_data.get("flavor", default_flavor), 
        "focusLine": encounter.get("focusLine", "这位来客既带着麻烦，也可能带着机会。"), 
        "choices": _normalize_choices(encounter.get("choices", [])), 
        "is_historical": visitor_data.get("isHistorical", false), 
        "bio": visitor_data.get("bio", ""), 
        "is_court_session": is_court
    }

static func _action_flavor_text(action_type: String) -> String:
    match action_type:
        "governance":
            return "一纸布告落地，消耗的从来不只是墨。"
        "trade":
            return "市面上没有白来的粮，也没有不压价的银。"
        "home":
            return "退回内宅，未必就能把外头的风雨关在门外。"
        "field":
            return "离开县衙的案头，泥土和人声才会把真相推到你脸上。"
        _:
            return ""

static func _normalize_choices(raw_choices: Array) -> Array:
    var normalized: Array = []
    for raw_choice in raw_choices:
        var choice: Dictionary = raw_choice
        var converted: = choice.duplicate(true)
        converted["description"] = choice.get("description", choice.get("desc", ""))
        converted["systemComment"] = choice.get("systemComment", choice.get("comment", ""))
        normalized.append(converted)
    return normalized

static func _story_card_blocks_selection(game_state: Node, selected_card: Dictionary) -> bool:
    var has_story: = false
    var story_done: = false
    for idx in range(game_state.month_cards.size()):
        var card: Dictionary = game_state.month_cards[idx]
        if card.get("type", "") in ["story", "attitude", "grain_shortage"]:
            has_story = true
            if game_state.month_cards_done.has(idx):
                story_done = true
            break
    return has_story and not story_done and selected_card.get("type", "") not in ["story", "attitude", "grain_shortage"]

static func _riot_card_blocks_selection(game_state: Node, selected_card: Dictionary) -> bool:
    var has_riot: = false
    var riot_done: = false
    for idx in range(game_state.month_cards.size()):
        var card: Dictionary = game_state.month_cards[idx]
        if card.get("type", "") == "riot":
            has_riot = true
            if game_state.month_cards_done.has(idx):
                riot_done = true
            break
    return has_riot and not riot_done and selected_card.get("type", "") not in ["riot", "mutiny", "story", "attitude", "grain_shortage"]

static func _mutiny_card_blocks_selection(game_state: Node, selected_card: Dictionary) -> bool:
    var has_mutiny: = false
    var mutiny_done: = false
    for idx in range(game_state.month_cards.size()):
        var card: Dictionary = game_state.month_cards[idx]
        if card.get("type", "") == "mutiny":
            has_mutiny = true
            if game_state.month_cards_done.has(idx):
                mutiny_done = true
            break
    return has_mutiny and not mutiny_done and selected_card.get("type", "") not in ["riot", "mutiny", "story", "attitude", "grain_shortage"]

static func _round10(value: float) -> int:
    return int(round(value / 10.0)) * 10

static func _build_riot_event(game_state: Node, riot_level: int) -> Dictionary:
    var bingyong: int = int(game_state.city.get("bingyong", 0))
    var liumin: int = int(game_state.city.get("liumin", 0))
    var can_suppress: bool = bingyong >= int(liumin * 0.3)
    var suppress_note: String = "（兵力充足，损失减半）" if can_suppress else ""

    var key: = "riot_lv%d" % riot_level
    var template: Dictionary = GameData.DYNAMIC_EVENTS.get(key, {})
    if template.is_empty():
        push_warning("Missing dynamic event template: " + key)
        return {}
    var event_data: Dictionary = template.duplicate(true)

    if riot_level == 1:
        if suppress_note != "":
            var c0: Dictionary = event_data["choices"][0]
            c0["description"] = str(c0.get("description", "")) + suppress_note
        return event_data

    if riot_level == 2:
        var tier_key: = "effects_suppressed" if can_suppress else "effects_unsuppressed"
        for choice in event_data["choices"]:
            var overrides: Dictionary = choice.get(tier_key, {})
            if not overrides.is_empty():
                var eff: Dictionary = choice["effects"]
                for k in overrides:
                    eff[k] = overrides[k]
            choice.erase("effects_suppressed")
            choice.erase("effects_unsuppressed")
        if suppress_note != "":
            event_data["choices"][0]["description"] = str(event_data["choices"][0].get("description", "")) + suppress_note
        return event_data


    var choices: Array = []
    var fight: Dictionary = event_data.get("choice_fight", {}).duplicate(true)
    if not fight.is_empty():
        choices.append(fight)

    var recruit: Dictionary = event_data.get("choice_recruit", {}).duplicate(true)
    if not recruit.is_empty():
        recruit["effects"] = {
            "bingyong": _round10(liumin * 0.01), 
            "liumin": _round10( - liumin * 0.1), 
            "minwang": 10, 
            "shengjuan": -8, 
            "shishen": -8, 
            "qingyi": -8
        }
        recruit.erase("effects_template")
        choices.append(recruit)

    var granary: Dictionary = event_data.get("choice_granary", {}).duplicate(true)
    if not granary.is_empty():
        choices.append(granary)

    var divide: Dictionary = event_data.get("choice_divide", {}).duplicate(true)
    if not divide.is_empty():
        choices.append(divide)

    var defend: Dictionary = event_data.get("choice_defend", {}).duplicate(true)
    if not defend.is_empty():
        choices.append(defend)

    var flee: Dictionary = event_data.get("choice_flee", {})
    if not flee.is_empty():
        choices.append(flee)

    var zhao: Dictionary = event_data.get("choice_zhao_erchui", {}).duplicate(true)
    if not zhao.is_empty():
        zhao["effects"] = {
            "liumin": _round10( - liumin * 0.15), 
            "renkou_val": _round10(liumin * 0.05), 
            "bingyong": _round10(liumin * 0.01), 
            "minwang": 5
        }
        zhao.erase("effects_template")
        choices.append(zhao)

    event_data["choices"] = choices
    event_data.erase("choice_fight")
    event_data.erase("choice_recruit")
    event_data.erase("choice_granary")
    event_data.erase("choice_divide")
    event_data.erase("choice_defend")
    event_data.erase("choice_flee")
    event_data.erase("choice_scholar")
    event_data.erase("choice_zhao_erchui")
    event_data.erase("_dynamic_effects_note")
    return event_data

static func _build_grain_shortage_event() -> Dictionary:
    var template: Dictionary = GameData.DYNAMIC_EVENTS.get("grain_shortage", {})
    if template.is_empty():
        push_warning("Missing dynamic event template: grain_shortage")
        return {}
    return template.duplicate(true)

static func _find_event_by_id(event_id: String) -> Dictionary:
    for event_data in GameData.events:
        if event_data.get("id", "") == event_id:
            return event_data
    return {}

static func _find_visitor_by_id(visitor_id: String) -> Dictionary:
    for visitor_data in GameData.VISITORS:
        if visitor_data.get("id", "") == visitor_id:
            return visitor_data
    return {}

static func _find_court_case_by_id(case_id: String) -> Dictionary:
    for case_data in GameData.COURT_CASES:
        if case_data.get("id", "") == case_id:
            return case_data
    return {}

static func _find_chain_case_by_id(chain_id: String) -> Dictionary:
    for chain_data in GameData.CHAIN_CASES:
        if chain_data.get("id", "") == chain_id:
            return chain_data
    return {}

static func _is_visitor_eligible(game_state: Node, visitor: Dictionary, act: int) -> bool:
    if visitor.is_empty():
        return false


    if visitor.has("requireAct") and act < int(visitor.get("requireAct", act)):
        return false
    var visitor_chain_id: = str(visitor.get("chainId", ""))
    var visitor_chain_chapter: = int(visitor.get("chainChapter", 0))
    if visitor_chain_id != "" and visitor_chain_chapter > 0:
        var existing_chain_state: Dictionary = game_state.historical_chains.get(visitor_chain_id, {})
        if int(existing_chain_state.get("chapter", 0)) >= visitor_chain_chapter:
            return false


        var prev_resolved_month_index: = int(existing_chain_state.get("resolvedMonthIndex", -1))
        if prev_resolved_month_index >= 0:
            var current_month_index: int = game_state.year * 12 + game_state.month
            if current_month_index - prev_resolved_month_index < CHAIN_CHAPTER_MIN_GAP_MONTHS:
                return false
    var require_chain: Dictionary = visitor.get("requireChain", {})
    if require_chain.is_empty():
        return true
    var chain_state: Dictionary = game_state.historical_chains.get(str(require_chain.get("id", "")), {})
    if chain_state.is_empty():
        return false
    var not_outcomes: Array = require_chain.get("notOutcomes", [])
    if not_outcomes.has(chain_state.get("outcome", "")):
        return false
    var required_chapter: = int(require_chain.get("requiredChapter", 0))
    if required_chapter > 0 and int(chain_state.get("chapter", 0)) < required_chapter:
        return false
    var required_history: Array = require_chain.get("historyEquals", [])
    if not required_history.is_empty():
        var chain_history: Array = chain_state.get("history", [])
        if chain_history.size() != required_history.size():
            return false
        for idx in range(required_history.size()):
            if str(chain_history[idx]) != str(required_history[idx]):
                return false
    var excluded_histories: Array = require_chain.get("historyNotEqualsAny", [])
    if not excluded_histories.is_empty():
        var chain_history: Array = chain_state.get("history", [])
        for excluded in excluded_histories:
            if typeof(excluded) != TYPE_ARRAY:
                continue
            var excluded_history: Array = excluded
            if chain_history.size() != excluded_history.size():
                continue
            var is_same: = true
            for idx in range(excluded_history.size()):
                if str(chain_history[idx]) != str(excluded_history[idx]):
                    is_same = false
                    break
            if is_same:
                return false
    return true

static func _is_chain_case_eligible(chain_def: Dictionary, act: int) -> bool:
    if chain_def.is_empty():
        return false

    var chain_tag: = "街巷" if str(chain_def.get("sceneType", "")) == "street" else "衙门"
    if chain_tag == "衙门" and act > 4:
        return false
    if chain_def.has("requireAct") and int(chain_def.get("requireAct", act)) != act:
        return false
    return true

static func _finalize_chain_choice(game_state: Node, card: Dictionary, choice: Dictionary) -> void :
    var chain_id: = str(card.get("chain_id", ""))
    if chain_id == "":
        return
    if not game_state.used_chain_ids.has(chain_id):
        game_state.used_chain_ids.append(chain_id)
    var next_event_value: Variant = choice.get("nextEvent", null)
    if next_event_value == null:
        game_state.active_case_chain = {}
        return
    var chain_def: = _find_chain_case_by_id(chain_id)
    var events: Array = chain_def.get("events", [])
    var next_idx: int = int(next_event_value)
    if next_idx < 0 or next_idx >= events.size():
        game_state.active_case_chain = {}
        return
    game_state.active_case_chain = {"chain_id": chain_id, "event_index": next_idx}
    var next_event: Dictionary = events[next_idx]
    var delay: = 1 + randi() % 3
    game_state.pending_follow_ups.append({
        "type": "court_chain", 
        "chain_id": chain_id, 
        "event_index": next_idx, 
        "title": next_event.get("title", chain_def.get("title", "连环案")), 
        "ready_after": game_state.year * 12 + game_state.month + delay
    })

static func _get_current_act(game_state: Node) -> int:
    return _act_for_year(game_state.year)

static func _act_for_year(year: int) -> int:
    var max_act: = 1
    for act_key in GameData.ACT_CONFIG.keys():
        var cfg: Dictionary = GameData.ACT_CONFIG[act_key]
        var start_year: = int(cfg.get("startYear", 1))
        var end_year: = int(cfg.get("endYear", start_year))
        if year >= start_year and year <= end_year:
            return int(act_key)
        max_act = maxi(max_act, int(act_key))
    if year > 17:
        return max_act
    return 1


static func _year_to_chinese(year_value: int) -> String:
    if year_value <= 1:
        return "元"
    var cn_nums: = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
    if year_value <= 10:
        return "十" if year_value == 10 else cn_nums[year_value]
    if year_value < 20:
        return "十%s" % cn_nums[year_value % 10]
    if year_value % 10 == 0:
        return "%s十" % cn_nums[int(year_value / 10)]
    return "%s十%s" % [cn_nums[int(year_value / 10)], cn_nums[year_value % 10]]

static func is_game_over(branch: String, branch_index: int, current_event: int, tags: Array[String]) -> bool:
    if branch != "":
        var event_data = get_branch_event(branch, branch_index, tags)
        if event_data.get("isEnding", false):
            if event_data.get("choices", []).size() > 0:
                return false
            return true
        return is_branch_exhausted(branch, branch_index)
    return current_event >= GameData.events.size()

static func is_branch_exhausted(branch: String, branch_index: int) -> bool:
    if branch == "":
        return false
    if branch_index < 0:
        return false
    if not branch in GameData.branch_events:
        return false
    return branch_index >= GameData.branch_events[branch].size()

static func _build_mutiny_event(game_state: Node, mutiny_level: int) -> Dictionary:
    game_state.get_mutiny_info()
    var current_grain: int = int(game_state.city.get("liangshi", 0))
    var current_silver: int = int(game_state.city.get("yinliang", 0))
    var grain_net: int = int(game_state.get_monthly_grain_net_change())
    var silver_net: = 0
    for item in game_state.monthly_silver_breakdown:
        silver_net += int(item.get("value", 0))
    var next_grain = current_grain + grain_net
    var next_silver = current_silver + silver_net
    var is_grain_deficit: bool = next_grain <= 0
    var is_silver_deficit: bool = next_silver <= 0
    var cause_is_grain: bool = is_grain_deficit if (is_grain_deficit or is_silver_deficit) else true

    var cause_suffix: = "grain" if cause_is_grain else "silver"
    var key: String
    if mutiny_level == 1:
        key = "mutiny_lv1_" + cause_suffix
    elif mutiny_level == 2:
        key = "mutiny_lv2_" + cause_suffix
    else:
        key = "mutiny_lv3"
    var template: Dictionary = GameData.DYNAMIC_EVENTS.get(key, {})
    if template.is_empty():
        push_warning("Missing dynamic event template: " + key)
        return {}
    return template.duplicate(true)
