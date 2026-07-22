extends RefCounted
class_name GovernanceMonthCardDisplay




const EventServiceRef = preload("res://scripts/services/event_service.gd")
const Presenter = preload("res://scripts/ui/game_screen_presenter.gd")

var _host

func _init(host) -> void :
    _host = host

func get_tag_text(card: Dictionary) -> String:
    var tag_text: = str(card.get("tag", "月卡"))
    var card_type: = str(card.get("type", ""))
    if card_type == "visitor":
        var visitor_id: = str(card.get("visitor_id", ""))
        if visitor_id == "v_xiangshen":
            tag_text = "衙门"
        else:
            var visitor_def: = EventServiceRef._find_visitor_by_id(visitor_id)
            if not visitor_def.is_empty() and (str(visitor_def.get("sceneType", "")) == "court" or visitor_def.get("is_court_session", false)):
                tag_text = "衙门"
    var tag_map: = {"剧情事件": "重要"}
    var resolved: = str(tag_map.get(tag_text, tag_text))
    if str(card.get("type", "")) == "governance" and _host._is_governance_card_upgraded(card):
        return resolved + "·2级"
    return resolved

func get_title(card: Dictionary) -> String:
    var cached_title: = str(card.get("title", "")).strip_edges()
    var card_type: = str(card.get("type", ""))
    if card_type in ["story", "attitude"]:
        var idx = GameState.month_cards.find(card)
        if idx >= 0:
            var story_evt: = EventServiceRef.get_month_card_event(GameState, idx)
            var fresh_title: = str(story_evt.get("title", "")).strip_edges()
            if fresh_title != "":
                return fresh_title
        return cached_title
    if card_type == "visitor":
        var visitor_def: = EventServiceRef._find_visitor_by_id(str(card.get("visitor_id", "")))
        var fresh_title: = str(visitor_def.get("title", "")).strip_edges()
        if fresh_title != "":
            return fresh_title
        return cached_title
    elif card_type == "grain_shortage":
        var gs_def: Dictionary = GameData.DYNAMIC_EVENTS.get("grain_shortage", {})
        var fresh_title: = str(gs_def.get("title", "")).strip_edges()
        if fresh_title != "":
            return fresh_title
        return cached_title
    if cached_title != "":
        return cached_title
    var idx: int = int(card.get("idx", -1))
    match card_type:
        "governance":
            if idx >= 0 and idx < GameData.GOVERNANCE_CARDS.size():
                return str(GameData.GOVERNANCE_CARDS[idx].get("title", ""))
        "trade":
            if idx >= 0 and idx < GameData.TRADE_CARDS.size():
                return str(GameData.TRADE_CARDS[idx].get("title", ""))
        "home":
            if idx >= 0 and idx < GameData.HOME_ACTIONS.size():
                return str(GameData.HOME_ACTIONS[idx].get("title", ""))
        "field":
            if idx >= 0 and idx < GameData.FIELD_ACTIONS.size():
                return str(GameData.FIELD_ACTIONS[idx].get("title", ""))
        "court":
            var court_case: = EventServiceRef._find_court_case_by_id(str(card.get("case_id", "")))
            return str(court_case.get("title", ""))
        "court_chain":
            var chain_evt: = EventServiceRef.get_month_card_event(GameState, GameState.month_cards.find(card))
            return str(chain_evt.get("title", ""))
        "visitor":
            var visitor_def: = EventServiceRef._find_visitor_by_id(str(card.get("visitor_id", "")))
            return str(visitor_def.get("title", ""))
        "riot":
            var riot_level: = clampi(int(card.get("riot_level", 1)), 1, 3)
            return ["小股闹事", "聚众滋乱", "揭竿而起"][riot_level - 1]
    return ""

func build_summary(card: Dictionary) -> String:
    match card.get("type", ""):
        "story", "attitude":
            var story_evt: = EventServiceRef.get_month_card_event(GameState, GameState.month_cards.find(card))
            return truncate_text(story_evt.get("narrative", "本月排定的剧情大事，需优先处置。"), 28 if _host._is_mobile_portrait() else 32)
        "governance":
            var idx: int = card.get("idx", -1)
            if idx >= 0 and idx < GameData.GOVERNANCE_CARDS.size():
                var gov_action: Dictionary = GameData.GOVERNANCE_CARDS[idx]
                if str(gov_action.get("specialType", "")) == "card_upgrade":
                    return truncate_text(str(gov_action.get("desc", "")), 28 if _host._is_mobile_portrait() else 32)
                return format_effect_summary(EventServiceRef.get_action_effects_for_state(GameState, gov_action), _host._maybe_doubled_att_effects(GameState, gov_action))
            return ""
        "trade":
            var idx: int = card.get("idx", -1)
            if idx >= 0 and idx < GameData.TRADE_CARDS.size():
                var trade_action: Dictionary = GameData.TRADE_CARDS[idx]
                return format_effect_summary(EventServiceRef.get_action_effects_for_state(GameState, trade_action), trade_action.get("attEffects", {}))
            return ""
        "home":
            var idx: int = card.get("idx", -1)
            if idx >= 0 and idx < GameData.HOME_ACTIONS.size():
                var home_action: Dictionary = GameData.HOME_ACTIONS[idx]
                return format_effect_summary(home_action.get("effects", {}), home_action.get("attEffects", {}))
            return ""
        "field":
            var idx: int = card.get("idx", -1)
            if idx >= 0 and idx < GameData.FIELD_ACTIONS.size():
                var field_action: Dictionary = GameData.FIELD_ACTIONS[idx]
                return format_effect_summary(field_action.get("effects", {}), field_action.get("attEffects", {}))
            return ""
        "court":
            var court_case: = EventServiceRef._find_court_case_by_id(str(card.get("case_id", "")))
            return truncate_text(court_case.get("narrative", "公堂之上摆的是案卷，背后牵的却是乡绅、人命和风声。"), 28 if _host._is_mobile_portrait() else 32)
        "court_chain":
            var chain_evt: = EventServiceRef.get_month_card_event(GameState, GameState.month_cards.find(card))
            return truncate_text(chain_evt.get("narrative", "一桩案子没断干净，后头往往还会拖出第二口血。"), 28 if _host._is_mobile_portrait() else 32)
        "visitor":
            var visitor_def: = EventServiceRef._find_visitor_by_id(str(card.get("visitor_id", "")))
            return truncate_text(visitor_def.get("desc", "街巷来人未必都带好意，但往往都带着某种真相。"), 28 if _host._is_mobile_portrait() else 32)
        "rumor":
            var idx: int = card.get("idx", -1)
            if idx >= 0 and idx < GameData.RUMOR_CARDS.size():
                var rumor_def: Dictionary = GameData.RUMOR_CARDS[idx]
                return truncate_text(str(rumor_def.get("desc", "")), 28 if _host._is_mobile_portrait() else 32)
            return ""
        "riot":
            var riot_level: = clampi(int(card.get("riot_level", 1)), 1, 3)
            var riot_def: Dictionary = GameData.DYNAMIC_EVENTS.get("riot_lv%d" % riot_level, {})
            var riot_summary: = str(riot_def.get("cardSummary", riot_def.get("narrative", "")))
            return truncate_text(riot_summary, 28 if _host._is_mobile_portrait() else 42)
        "mutiny":
            var mutiny_level: = clampi(int(card.get("mutiny_level", 1)), 1, 3)
            var _cg: bool = card.get("cause_grain", true)
            var mutiny_key: = "mutiny_lv3" if mutiny_level == 3 else "mutiny_lv%d_%s" % [mutiny_level, "grain" if _cg else "silver"]
            var mutiny_def: Dictionary = GameData.DYNAMIC_EVENTS.get(mutiny_key, {})
            var mutiny_summary: = str(mutiny_def.get("cardSummary", mutiny_def.get("narrative", "")))
            return truncate_text(mutiny_summary, 28 if _host._is_mobile_portrait() else 42)
        "grain_shortage":
            var gs_def: Dictionary = GameData.DYNAMIC_EVENTS.get("grain_shortage", {})
            var gs_summary: = str(gs_def.get("cardSummary", gs_def.get("narrative", "")))
            return truncate_text(gs_summary, 28 if _host._is_mobile_portrait() else 42)
        _:
            return "月度事件卡。"

func get_summary_lines(card: Dictionary) -> int:
    match str(card.get("type", "")):
        "governance", "trade", "home", "field":
            return 5
        _:
            return 4

func get_note_text(card: Dictionary) -> String:
    var note_text: = str(card.get("note", ""))
    if note_text == "" and str(card.get("type", "")) == "governance":
        var c_idx: int = card.get("idx", -1)
        if c_idx >= 0 and c_idx < GameData.GOVERNANCE_CARDS.size():
            note_text = str(GameData.GOVERNANCE_CARDS[c_idx].get("note", ""))
    elif note_text == "" and str(card.get("type", "")) == "trade":
        var c_idx: int = card.get("idx", -1)
        if c_idx >= 0 and c_idx < GameData.TRADE_CARDS.size():
            note_text = str(GameData.TRADE_CARDS[c_idx].get("note", ""))
    return note_text

func format_effect_summary(effects: Dictionary, extra_effects: Dictionary = {}) -> String:
    var pos_parts: Array[String] = []
    var neg_parts: Array[String] = []

    var process_effects = func(effs: Dictionary):
        for key in effs.keys():
            var delta: = int(effs[key])
            if delta == 0:
                continue
            if Presenter.is_effect_positive(str(key), delta):
                pos_parts.append(Presenter.format_effect_delta_text(key, delta))
            elif Presenter.is_effect_negative(str(key), delta):
                neg_parts.append(Presenter.format_effect_delta_text(key, delta))

    process_effects.call(effects)
    process_effects.call(extra_effects)

    var parts = pos_parts + neg_parts
    return " / ".join(parts)

func truncate_text(value: String, length: int) -> String:
    var clean_val = Presenter.resolve_text_placeholders(value).replace("\n", "").replace("\r", " ").strip_edges()
    if clean_val.length() <= length:
        return clean_val
    var clipped: String = clean_val.substr(0, length)
    var open_idx: int = clipped.rfind("{")
    var close_idx: int = clipped.rfind("}")
    if open_idx > close_idx:
        clipped = clipped.substr(0, open_idx).strip_edges()
    return "%s…" % clipped

func text_color(disabled: bool, strong: bool) -> Color:
    if disabled:
        return Color(0.52, 0.5, 0.46, 0.78) if GameState.theme == "light" else Color(0.5, 0.48, 0.44, 0.78)

    return Color(0.96, 0.9, 0.76) if strong else Color(0.9, 0.84, 0.7)

func tag_bg(disabled: bool) -> Color:
    if disabled:
        return Color(0.86, 0.84, 0.78, 1.0) if GameState.theme == "light" else Color(0.18, 0.17, 0.15, 1.0)

    return Color(0.2, 0.16, 0.12, 0.8) if GameState.theme == "light" else Color(0.13, 0.1, 0.075, 0.94)

func overlay_colors(card: Dictionary, disabled: bool) -> Array[Color]:
    if GameState.theme != "light":
        return [Color(0.9, 0.8, 0.6, 0.035), Color(0.05, 0.03, 0.01, 0.12)]


    if disabled:
        return [Color(0.96, 0.93, 0.86, 0.14), Color(0.4, 0.37, 0.32, 0.12)]

    var card_type: = str(card.get("type", ""))
    if card_type == "visitor":
        var visitor_id: = str(card.get("visitor_id", ""))
        if visitor_id == "v_xiangshen":
            card_type = "court"
        else:
            var visitor_def: = EventServiceRef._find_visitor_by_id(visitor_id)
            if not visitor_def.is_empty() and (str(visitor_def.get("sceneType", "")) == "court" or visitor_def.get("is_court_session", false)):
                card_type = "court"
    match card_type:
        "court", "court_chain":

            return [Color(0.8, 0.84, 0.8, 0.08), Color(0.1, 0.13, 0.11, 0.18)]
        "story", "attitude":

            return [Color(0.92, 0.82, 0.62, 0.08), Color(0.17, 0.13, 0.07, 0.18)]
        "home":
            return [Color(0.9, 0.85, 0.9, 0.08), Color(0.2, 0.18, 0.2, 0.18)]
        "field":
            return [Color(0.85, 0.9, 0.82, 0.08), Color(0.18, 0.22, 0.17, 0.18)]
        "visitor":
            return [Color(0.82, 0.9, 0.92, 0.08), Color(0.16, 0.22, 0.25, 0.18)]
        "rumor":
            return [Color(0.85, 0.8, 0.82, 0.08), Color(0.18, 0.15, 0.16, 0.18)]
        _:
            return [Color(0.88, 0.84, 0.78, 0.08), Color(0.18, 0.17, 0.15, 0.18)]
