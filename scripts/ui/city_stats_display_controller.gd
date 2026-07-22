extends RefCounted
class_name CityStatsDisplayController




var _host

func _init(host) -> void :
    _host = host

func collapse_city_boosts_for_new_month() -> void :
    pass

func _city_boost_effect_text(item_id: String) -> String:
    if item_id == "":
        return ""
    var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
    var city_effects: Dictionary = item_def.get("cityEffects", {})
    var effects: Array[String] = []
    for raw_key in city_effects:
        var key: = str(raw_key)
        if GameData.CITY_STAT_KEYS.has(key):
            effects.append("%s +%d" % [GameData.city_stat_effect_label(key), int(city_effects[raw_key])])
    for part in GameState.get_item_status_effect_parts(item_id):
        effects.append(str(part))
    return "、".join(effects)

func _make_city_boost_slot_style(filled: bool, hover: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    var accent: = GameState.get_theme_color("border_active")
    style.bg_color = Color(accent.r, accent.g, accent.b, 0.1 if filled else 0.035)
    if hover:
        style.bg_color = Color(accent.r, accent.g, accent.b, 0.18)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = Color(accent.r, accent.g, accent.b, 0.62 if filled else 0.34)
    style.corner_radius_top_left = 999
    style.corner_radius_top_right = 999
    style.corner_radius_bottom_left = 999
    style.corner_radius_bottom_right = 999
    style.content_margin_left = 3
    style.content_margin_right = 3
    style.content_margin_top = 3
    style.content_margin_bottom = 3
    return style

func _build_city_boost_slot_tooltip(item_id: String) -> String:
    if item_id == "":
        return "添加随身物品"
    var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
    var name: = str(item_def.get("name", item_id))
    var city_effects: Dictionary = item_def.get("cityEffects", {})
    var effects: Array[String] = []
    for raw_key in city_effects:
        var key: = str(raw_key)
        if GameData.CITY_STAT_KEYS.has(key):
            effects.append("%s +%d" % [GameData.city_stat_effect_label(key), int(city_effects[raw_key])])
    for part in GameState.get_item_status_effect_parts(item_id):
        effects.append(str(part))
    if effects.is_empty():
        return name
    return "%s\n%s" % [name, "、".join(effects)]

func _can_drop_city_boost_item(_at_position: Vector2, data, _slot_index: int) -> bool:
    if typeof(data) != TYPE_DICTIONARY:
        return false
    if str(data.get("type", "")) != "city_boost_item":
        return false
    return GameState._item_is_boost_eligible(str(data.get("item_id", "")))

func build_governance_merit_help_text() -> String:
    var target: = GameState.get_governance_merit_target()
    var current: = GameState.get_governance_merit()
    var final_year: int = _host._get_governance_assessment_year()
    var final_month: String = _host._get_month_name(12)
    var final_label: = "%s%s" % [_host._format_cz_year_for_ui(final_year), final_month]
    var months_left: int = maxi(0, final_year * 12 + 12 - (int(GameState.year) * 12 + int(GameState.month)))
    var time_text: = "本任终考定在%s，距今尚有%d个月。" % [final_label, months_left]
    if months_left == 0:
        time_text = "本任终考就在%s。" % final_label

    var merit_word: = "战功" if GameData.active_line == "bianwu" else "政绩"
    var target_text: = "本任尚无明确%s线。" % merit_word
    if target > 0:
        target_text = "当前%s为%d/%d，%s。" % [merit_word, current, target, "已达考成线" if current >= target else "尚未达考成线"]

    var merit_rule: = GameState.get_governance_merit_desc()
    return "%s\n\n%s\n\n%s\n\n%s能否达标，决定你能否按常途正常晋升。若%s一时追不上，早些与宫里打好关系，也未尝不是一条路。\n\n（提示：点击库银、官粮、兵勇等数值，可查看各项的详细说明。）" % [time_text, target_text, merit_rule, merit_word, merit_word]

func _connect_city_stat_events(row_node: Control, stat_key: String) -> void :
    if row_node == null:
        return
    row_node.mouse_filter = Control.MOUSE_FILTER_STOP
    row_node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

    for child in row_node.get_children():
        if child is Control:
            child.mouse_filter = Control.MOUSE_FILTER_IGNORE
            for sub_child in child.get_children():
                if sub_child is Control:
                    sub_child.mouse_filter = Control.MOUSE_FILTER_IGNORE

    row_node.mouse_entered.connect( func() -> void :
        if DisplayServer.is_touchscreen_available():
            return
        if GameState.has_method("is_after_sun_chuanting_branch_split") and GameState.is_after_sun_chuanting_branch_split():
            return
        if _host != null and _host._tooltips != null:
            _host._tooltips._show_city_stat_tooltip(stat_key, row_node)
            _host._hover_tooltip_active = true
    )

    row_node.mouse_exited.connect( func() -> void :
        if _host != null and _host._hover_tooltip_active:
            if _host._tooltips != null:
                _host._tooltips._clear_resource_tooltips()
            _host._hover_tooltip_active = false
    )

    row_node.gui_input.connect( func(event: InputEvent) -> void :
        if _host == null or not _host.has_method("_is_zhisu_scroll_safe_tap_event") or not _host._is_zhisu_scroll_safe_tap_event(event):
            return
        if GameState.has_method("is_after_sun_chuanting_branch_split") and GameState.is_after_sun_chuanting_branch_split():
            return
        if _host._tooltips != null:
            _host._tooltips._show_city_stat_tooltip(stat_key, row_node)
            _host._hover_tooltip_active = true
    )
