extends RefCounted
class_name MonthWarningController




const CardAnimations = preload("res://scripts/ui/card_animations.gd")
const FontLoader = preload("res://scripts/ui/font_loader.gd")

const LOW_ATTITUDE_WARNING_THRESHOLD: = 8

var _host

func _init(host) -> void :
    _host = host

func refresh() -> void :
    ensure_nodes()


    var is_light: = GameState.theme == "light"
    if _host.month_warning_toggle_btn and is_instance_valid(_host.month_warning_toggle_btn):
        var btn_style_normal = _host.month_warning_toggle_btn.get_theme_stylebox("normal")
        if btn_style_normal is StyleBoxFlat:
            if is_light:
                btn_style_normal.bg_color = Color(0.18, 0.18, 0.18, 0.15)
                btn_style_normal.border_color = Color(0.15, 0.15, 0.15, 0.25)
            else:
                btn_style_normal.bg_color = Color(1, 1, 1, 0.015)
                btn_style_normal.border_color = Color(1, 1, 1, 0.12)
        var btn_style_hover = _host.month_warning_toggle_btn.get_theme_stylebox("hover")
        if btn_style_hover is StyleBoxFlat:
            if is_light:
                btn_style_hover.bg_color = Color(0.18, 0.18, 0.18, 0.25)
                btn_style_hover.border_color = Color(0.6, 0.48, 0.32, 0.6)
            else:
                btn_style_hover.bg_color = Color(1, 1, 1, 0.06)
                btn_style_hover.border_color = Color(0.72, 0.6, 0.44, 0.6)
    if _host.month_warning_badge and is_instance_valid(_host.month_warning_badge):
        _host.month_warning_badge.add_theme_color_override("font_color", Color(0.3, 0.23, 0.12) if is_light else Color(0.82, 0.69, 0.44))
        _host.month_warning_badge.add_theme_font_override("font", FontLoader.serif_bold() if is_light else FontLoader.body())

    if not _is_overview_active() or GameState.city.is_empty():
        _host.month_warning_container.visible = false
        return
    if _host.month_warning_container.get_parent() == _host.governance_vbox:
        _host.governance_vbox.move_child(_host.month_warning_container, _warning_insert_index())

    var is_portrait: bool = _host._is_mobile_portrait()

    _host.month_warning_wrapper.add_theme_constant_override("margin_top", 0)
    if is_portrait:
        _host.month_warning_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _host.month_warning_container.custom_minimum_size.x = 0
        _host.month_warning_wrapper.add_theme_constant_override("margin_left", 24)
    else:
        var card_w: float = _host._get_month_card_size().x
        var card_gap: float = float(_host.NATIVE_LANDSCAPE_MONTH_CARD_GAP if _host._is_native_mobile_landscape() else 12)
        var total_w: = card_w * 5 + card_gap * 4
        _host.month_warning_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        _host.month_warning_container.custom_minimum_size.x = total_w
        _host.month_warning_wrapper.add_theme_constant_override("margin_left", 10)

    var btn_size: = 56.0 if is_portrait else 28.0
    _host.month_warning_toggle_btn.custom_minimum_size = Vector2(btn_size, btn_size)
    var icon_rect: TextureRect = _find_toggle_icon()
    if icon_rect and is_instance_valid(icon_rect):
        var icon_rect_size: = 38.0 if is_portrait else 18.0
        icon_rect.custom_minimum_size = Vector2(icon_rect_size, icon_rect_size)
        icon_rect.size = Vector2(icon_rect_size, icon_rect_size)

    if _host.month_warning_badge and is_instance_valid(_host.month_warning_badge):
        _host.month_warning_badge.add_theme_font_size_override("font_size", 22 if is_portrait else 12)

    var entries: Array = _build_entries()
    for child in _host.month_warning_box.get_children():
        _host.month_warning_box.remove_child(child)
        child.queue_free()

    if entries.is_empty():
        _host.month_warning_container.visible = false
        return
    _host.month_warning_container.visible = true

    var anim_key: String = "%d-%d" % [GameState.year, GameState.month]
    var play_enter: bool = anim_key != _host._month_warning_anim_key
    _host._month_warning_anim_key = anim_key

    if play_enter:
        _host.month_warning_collapsed = false
        _host.month_warning_wrapper.visible = true
        if _host._is_mobile_portrait():
            _host.month_warning_wrapper.custom_minimum_size.x = _host.get_viewport_rect().size.x - 100.0
        else:
            _host.month_warning_wrapper.custom_minimum_size.x = 0
        _host.month_warning_wrapper.custom_minimum_size.y = 0
        _host.month_warning_wrapper.modulate.a = 1.0
        _host.month_warning_badge.visible = false
        var icon_rect_init: TextureRect = _find_toggle_icon()
        if icon_rect_init and is_instance_valid(icon_rect_init):
            icon_rect_init.rotation_degrees = 0.0
            icon_rect_init.modulate = _get_icon_color(true)

    var delay: = 0.0
    for entry in entries:
        var chip: = make_chip(entry)
        _host.month_warning_box.add_child(chip)
        if play_enter and not _host.month_warning_collapsed:
            CardAnimations.play_chip_pop(chip, delay)
            delay += 0.14

    if _host.month_warning_collapsed:
        _host.month_warning_wrapper.visible = false
        _host.month_warning_badge.visible = entries.size() > 0
        _host.month_warning_badge.text = str(entries.size())
        var icon_rect_final: TextureRect = _find_toggle_icon()
        if icon_rect_final and is_instance_valid(icon_rect_final):
            icon_rect_final.rotation_degrees = -90.0
            icon_rect_final.modulate = _get_icon_color(false)
    else:
        _host.month_warning_wrapper.visible = true
        _host.month_warning_badge.visible = false
        if _host._is_mobile_portrait():
            _host.month_warning_wrapper.custom_minimum_size.x = _host.get_viewport_rect().size.x - 100.0
        else:
            _host.month_warning_wrapper.custom_minimum_size.x = 0
        _host.month_warning_wrapper.custom_minimum_size.y = 0
        var icon_rect_final: TextureRect = _find_toggle_icon()
        if icon_rect_final and is_instance_valid(icon_rect_final):
            icon_rect_final.rotation_degrees = 0.0
            icon_rect_final.modulate = _get_icon_color(true)

func make_chip(entry: Dictionary) -> PanelContainer:
    var chip: = PanelContainer.new()
    var is_portrait: bool = _host._is_mobile_portrait()

    if is_portrait:
        chip.size_flags_horizontal = Control.SIZE_FILL
        var screen_width: float = _host.get_viewport_rect().size.x
        var w_box: float = screen_width - 124.0
        var chip_w: float = (w_box - 10.0) / 2.0
        chip.custom_minimum_size.x = maxf(100.0, chip_w)
    else:
        chip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

    var style: = StyleBoxFlat.new()
    if GameState.theme == "light":
        style.bg_color = Color(1.0, 1.0, 1.0, 0.0)

        style.border_color = Color(0.3, 0.23, 0.12, 0.28)
    else:
        style.bg_color = Color(1, 1, 1, 0.015)
        style.border_color = Color(1, 1, 1, 0.12)
    style.set_corner_radius_all(10)
    style.set_border_width_all(1)
    chip.add_theme_stylebox_override("panel", style)

    var margin: = MarginContainer.new()
    var pad_h: = 24 if is_portrait else 14
    var pad_v: = 14 if is_portrait else 7
    margin.add_theme_constant_override("margin_left", pad_h)
    margin.add_theme_constant_override("margin_right", pad_h)
    margin.add_theme_constant_override("margin_top", pad_v)
    margin.add_theme_constant_override("margin_bottom", pad_v)
    chip.add_child(margin)

    var row: = HBoxContainer.new()
    row.add_theme_constant_override("separation", 0)
    row.alignment = BoxContainer.ALIGNMENT_CENTER
    margin.add_child(row)

    var font_size: = 34 if is_portrait else 13
    var is_warning: = bool(entry.get("warning", false))
    var warning_color: = _warning_text_color()
    var text_label: = Label.new()
    text_label.text = entry.get("prefix", "")
    text_label.add_theme_font_override("font", FontLoader.body())
    text_label.add_theme_font_size_override("font_size", font_size)
    text_label.add_theme_color_override("font_color", warning_color if is_warning else (Color(0.3, 0.23, 0.12, 0.92) if GameState.theme == "light" else Color(1, 1, 1, 0.6)))
    row.add_child(text_label)

    var num_label: = Label.new()
    num_label.text = entry.get("num", "")
    num_label.add_theme_font_override("font", FontLoader.serif_bold() if GameState.theme == "light" else FontLoader.body())
    num_label.add_theme_font_size_override("font_size", font_size)
    var num_color: Color
    if is_warning:
        num_color = warning_color
    elif GameState.theme == "light":

        num_color = Color(0.36, 0.58, 0.38, 1.0) if entry.get("positive", false) else Color(0.78, 0.46, 0.3, 1.0)
    else:
        num_color = Color(0.5, 0.66, 0.48, 0.82) if entry.get("positive", false) else Color(0.8, 0.6, 0.42, 0.82)
    num_label.add_theme_color_override("font_color", num_color)
    row.add_child(num_label)
    return chip

func ensure_nodes() -> void :
    if _host.month_warning_container != null and is_instance_valid(_host.month_warning_container):
        return

    _host.month_warning_container = HBoxContainer.new()
    _host.month_warning_container.name = "MonthWarningContainer"
    _host.month_warning_container.add_theme_constant_override("separation", 4)

    _host.month_warning_toggle_btn = Button.new()
    _host.month_warning_toggle_btn.name = "MonthWarningToggleBtn"
    _host.month_warning_toggle_btn.flat = true
    _host.month_warning_toggle_btn.focus_mode = Control.FOCUS_NONE
    _host.month_warning_toggle_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

    var btn_style_normal: = StyleBoxFlat.new()
    if GameState.theme == "light":
        btn_style_normal.bg_color = Color(0.18, 0.18, 0.18, 0.15)
        btn_style_normal.border_color = Color(0.15, 0.15, 0.15, 0.25)
    else:
        btn_style_normal.bg_color = Color(1, 1, 1, 0.015)
        btn_style_normal.border_color = Color(1, 1, 1, 0.12)
    btn_style_normal.set_corner_radius_all(6)
    btn_style_normal.set_border_width_all(1)

    var btn_style_hover: = StyleBoxFlat.new()
    if GameState.theme == "light":
        btn_style_hover.bg_color = Color(0.18, 0.18, 0.18, 0.25)
        btn_style_hover.border_color = Color(0.6, 0.48, 0.32, 0.6)
    else:
        btn_style_hover.bg_color = Color(1, 1, 1, 0.06)
        btn_style_hover.border_color = Color(0.72, 0.6, 0.44, 0.6)
    btn_style_hover.set_corner_radius_all(6)
    btn_style_hover.set_border_width_all(1)

    _host.month_warning_toggle_btn.add_theme_stylebox_override("normal", btn_style_normal)
    _host.month_warning_toggle_btn.add_theme_stylebox_override("hover", btn_style_hover)
    _host.month_warning_toggle_btn.add_theme_stylebox_override("pressed", btn_style_hover)
    _host.month_warning_toggle_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

    var btn_size: = 56.0 if _host._is_mobile_portrait() else 28.0
    _host.month_warning_toggle_btn.custom_minimum_size = Vector2(btn_size, btn_size)
    _host.month_warning_toggle_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER

    var icon_rect: = TextureRect.new()
    icon_rect.name = "Icon"
    icon_rect.texture = load("res://assets/ui/status_icons/message.svg")
    icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    var icon_rect_size: = 38.0 if _host._is_mobile_portrait() else 18.0
    icon_rect.custom_minimum_size = Vector2(icon_rect_size, icon_rect_size)
    icon_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER

    var btn_layout: = CenterContainer.new()
    btn_layout.name = "CenterContainer"
    btn_layout.set_anchors_preset(Control.PRESET_FULL_RECT)
    btn_layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
    btn_layout.add_child(icon_rect)
    _host.month_warning_toggle_btn.add_child(btn_layout)

    _host.month_warning_badge = Label.new()
    _host.month_warning_badge.name = "Badge"
    _host.month_warning_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _host.month_warning_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    _host.month_warning_badge.text = "0"
    _host.month_warning_badge.add_theme_font_override("font", FontLoader.serif_bold() if GameState.theme == "light" else FontLoader.body())
    _host.month_warning_badge.add_theme_font_size_override("font_size", 22 if _host._is_mobile_portrait() else 12)

    _host.month_warning_badge.add_theme_color_override("font_color", Color(0.3, 0.23, 0.12) if GameState.theme == "light" else Color(0.82, 0.69, 0.44))
    _host.month_warning_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _host.month_warning_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _host.month_warning_badge.visible = false

    _host.month_warning_toggle_btn.pressed.connect(_host._toggle_month_warning_collapsed)

    _host.month_warning_wrapper = MarginContainer.new()
    _host.month_warning_wrapper.name = "MonthWarningWrapper"
    _host.month_warning_wrapper.clip_contents = true
    _host.month_warning_wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _host.month_warning_wrapper.size_flags_vertical = Control.SIZE_SHRINK_CENTER

    _host.month_warning_box = HFlowContainer.new()
    _host.month_warning_box.name = "MonthWarningBox"
    _host.month_warning_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _host.month_warning_box.add_theme_constant_override("h_separation", 10 if _host._is_mobile_portrait() else 8)
    _host.month_warning_box.add_theme_constant_override("v_separation", 10 if _host._is_mobile_portrait() else 8)

    _host.month_warning_wrapper.add_child(_host.month_warning_box)
    _host.month_warning_container.add_child(_host.month_warning_toggle_btn)
    _host.month_warning_container.add_child(_host.month_warning_badge)
    _host.month_warning_container.add_child(_host.month_warning_wrapper)

    _host.governance_vbox.add_child(_host.month_warning_container)
    _host.governance_vbox.move_child(_host.month_warning_container, _warning_insert_index())

func toggle_collapsed() -> void :
    if _host.month_warning_wrapper == null or not is_instance_valid(_host.month_warning_wrapper):
        return
    _host.month_warning_collapsed = not _host.month_warning_collapsed
    animate_transition(true)

func animate_transition(user_triggered: bool) -> void :
    if _host.month_warning_wrapper == null or not is_instance_valid(_host.month_warning_wrapper):
        return
    if _host.month_warning_toggle_btn == null or not is_instance_valid(_host.month_warning_toggle_btn):
        return

    if _host.month_warning_wrapper.has_meta("active_tween"):
        var active_t = _host.month_warning_wrapper.get_meta("active_tween")
        if is_instance_valid(active_t):
            active_t.kill()

    var t: Tween = _host.month_warning_wrapper.create_tween()
    _host.month_warning_wrapper.set_meta("active_tween", t)
    t.set_parallel(true)

    var entries_count: int = _host.month_warning_box.get_child_count()
    _host.month_warning_badge.text = str(entries_count)
    var icon_rect: TextureRect = _find_toggle_icon()

    if _host.month_warning_collapsed:
        var original_height: float = _host.month_warning_box.size.y
        if original_height > 0:
            _host.month_warning_wrapper.custom_minimum_size.y = original_height
        t.tween_property(_host.month_warning_wrapper, "custom_minimum_size:x", 0.0, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
        t.tween_property(_host.month_warning_wrapper, "modulate:a", 0.0, 0.18).set_trans(Tween.TRANS_SINE)
        if icon_rect and is_instance_valid(icon_rect):
            icon_rect.pivot_offset = icon_rect.size / 2.0
            t.tween_property(icon_rect, "rotation_degrees", -90.0, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
            t.tween_property(icon_rect, "modulate", _get_icon_color(false), 0.22)
        t.chain().tween_callback( func():
            _host.month_warning_wrapper.visible = false
            _host.month_warning_badge.visible = entries_count > 0
            _host.month_warning_badge.modulate.a = 0.0
            var pop_t = _host.month_warning_badge.create_tween()
            pop_t.tween_property(_host.month_warning_badge, "modulate:a", 1.0, 0.15)
            _host.month_warning_wrapper.custom_minimum_size.y = 0
        )
    else:
        _host.month_warning_wrapper.visible = true
        _host.month_warning_badge.visible = false
        var target_w = _host.get_viewport_rect().size.x - 100.0 if _host._is_mobile_portrait() else (_host.month_warning_container.size.x - _host.month_warning_toggle_btn.size.x - 20)
        if target_w <= 100:
            target_w = 400.0
        _host.month_warning_wrapper.custom_minimum_size.x = 0
        t.tween_property(_host.month_warning_wrapper, "custom_minimum_size:x", target_w, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
        _host.month_warning_wrapper.modulate.a = 0.0
        t.tween_property(_host.month_warning_wrapper, "modulate:a", 1.0, 0.22).set_trans(Tween.TRANS_SINE)
        if icon_rect and is_instance_valid(icon_rect):
            icon_rect.pivot_offset = icon_rect.size / 2.0
            t.tween_property(icon_rect, "rotation_degrees", 0.0, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
            t.tween_property(icon_rect, "modulate", _get_icon_color(true), 0.25)
        t.chain().tween_callback( func():
            if _host._is_mobile_portrait():
                _host.month_warning_wrapper.custom_minimum_size.x = _host.get_viewport_rect().size.x - 100.0
            else:
                _host.month_warning_wrapper.custom_minimum_size.x = 0
            _host.month_warning_wrapper.custom_minimum_size.y = 0
        )

func _build_entries() -> Array:
    var delta: Dictionary = GameState.last_month_resource_delta
    var entries: Array = []
    _append_risk_probability_entries(entries)
    if delta.is_empty():
        return entries

    var d_liumin: = int(delta.get("liumin", 0))
    if d_liumin > 0:
        entries.append({"prefix": "流民涌入，上月增加 ", "num": _host._format_large_number(d_liumin), "positive": false})
    elif d_liumin < 0:
        entries.append({"prefix": "流民减少，上月减少 ", "num": _host._format_large_number( - d_liumin), "positive": true})

    var d_grain: = int(delta.get("liangshi", 0))
    if d_grain < 0:
        var grain_now: = int(GameState.city.get("liangshi", 0))
        var grain_prefix: = "官粮见底" if grain_now <= 0 else "官粮告急"
        entries.append({"prefix": "%s，上月净减 " % grain_prefix, "num": _host._format_large_number( - d_grain), "positive": false})
    elif d_grain > 0:
        entries.append({"prefix": "官粮增加，上月净增 ", "num": _host._format_large_number(d_grain), "positive": true})

    var d_silver: = int(delta.get("yinliang", 0))
    if d_silver < 0:
        entries.append({"prefix": "库银亏空，上月净减 ", "num": _host._format_large_number( - d_silver), "positive": false})
    elif d_silver > 0:
        entries.append({"prefix": "库银增加，上月净增 ", "num": _host._format_large_number(d_silver), "positive": true})

    _append_low_attitude_entries(entries)
    _append_low_tizhi_entry(entries)
    return entries

func _append_risk_probability_entries(entries: Array) -> void :

    if not _host._is_local_route():
        return
    var mutiny_info: Dictionary = GameState.get_mutiny_info()
    var riot_info: Dictionary = GameState.get_riot_info()
    var mutiny_probability: = int(round(float(mutiny_info.get("probability", 0.0)) * 100.0))
    var riot_probability: = int(round(float(riot_info.get("probability", 0.0)) * 100.0))
    entries.append({"prefix": "兵变概率 ", "num": "%d%%" % mutiny_probability, "positive": false})
    entries.append({"prefix": "民变概率 ", "num": "%d%%" % riot_probability, "positive": false})

func _append_low_tizhi_entry(entries: Array) -> void :
    var tizhi_val: = int(GameState.stats.get("tizhi", 100))
    if tizhi_val <= 10:
        entries.append({"prefix": "体质欠佳，请注意调理", "num": "", "positive": false, "warning": true})

func _append_low_attitude_entries(entries: Array) -> void :
    for key in GameData.ATT_KEYS:
        if not GameState.attitudes.has(key):
            continue
        if _is_attitude_hidden(key):
            continue
        var value: = int(GameState.attitudes.get(key, 0))
        if value <= LOW_ATTITUDE_WARNING_THRESHOLD:
            var label: = str(GameData.ATT_LABELS.get(key, key))
            entries.append({"prefix": "当前%s态度较低" % label, "num": "", "positive": false, "warning": true})

func _is_attitude_hidden(key: String) -> bool:
    return GameState.emperor_dead and (key == "shengjuan" or key == "zhongguan") and not ("北京解围" in GameState.tags or "摄政监国" in GameState.tags)

func _warning_text_color() -> Color:
    return Color(0.64, 0.3, 0.28, 0.95) if GameState.theme == "light" else Color(0.78, 0.44, 0.4, 0.88)

func _find_toggle_icon() -> TextureRect:
    if _host.month_warning_toggle_btn == null or not is_instance_valid(_host.month_warning_toggle_btn):
        return null
    var icon_rect = _host.month_warning_toggle_btn.get_node_or_null("CenterContainer/Icon")
    if icon_rect != null:
        return icon_rect
    for child in _host.month_warning_toggle_btn.get_children():
        if child is CenterContainer:
            icon_rect = child.get_node_or_null("Icon")
            if icon_rect != null:
                return icon_rect
    return null

func _is_overview_active() -> bool:
    return _host.governance_scroll != null\
and is_instance_valid(_host.governance_scroll)\
and _host.governance_scroll.visible\
and _host.month_cards_container != null\
and is_instance_valid(_host.month_cards_container)\
and _host.month_cards_container.get_parent() == _host.governance_vbox

func _warning_insert_index() -> int:



    return 0

func _get_icon_color(active: bool) -> Color:
    var alpha: = 1.0 if active else 0.5
    if GameState.theme == "light":

        return Color(0.3, 0.23, 0.12, alpha)
    else:
        return Color(1.0, 1.0, 1.0, alpha)
