class_name BianwuDeploymentSlotController
extends RefCounted

const BianwuDefenseServiceRef = preload("res://scripts/services/bianwu_defense_service.gd")
const NativeMobileTouchScrollRef = preload("res://scripts/ui/native_mobile_touch_scroll.gd")
const BattleTypesRef = preload("res://scripts/battle/battle_types.gd")
const FontLoaderRef = preload("res://scripts/ui/font_loader.gd")


const SLOT_TEXT_MAIN: = Color(0.92, 0.88, 0.8)
const SLOT_TEXT_SUB: = Color(0.66, 0.61, 0.52)
const SLOT_ACCENT: = Color(0.86, 0.72, 0.43)
const SLOT_EMPTY_TEXT: = Color(0.64, 0.56, 0.42, 0.88)

const TOUCH_SUPPRESS_KEY: = "bianwu_deployment_scroll_suppress_until_ms"

var _host: Control
var _detail_scroll: ScrollContainer
var _region_id: = ""
var _layer: Control
var _candidate_scroll: ScrollContainer

func _init(host: Control) -> void :
    _host = host

func _game_state() -> Node:
    return _host.get_node_or_null("/root/GameState")

func render_region_slots(region_id: String, detail_box: VBoxContainer, layer: Control, detail_scroll: ScrollContainer = null) -> void :
    _region_id = region_id
    _layer = layer
    _detail_scroll = detail_scroll
    if _detail_scroll == null and detail_box.get_parent() is ScrollContainer:
        _detail_scroll = detail_box.get_parent() as ScrollContainer
    var state: = _game_state()
    if state == null:
        return
    var region: Dictionary = {}
    for candidate in state.bianwu_defense_regions:
        if candidate is Dictionary and str(candidate.get("id", "")) == region_id:
            region = candidate
            break
    if region.is_empty() or not BianwuDefenseServiceRef.region_allows_deployment(region):
        return
    detail_box.add_child(_section_title("驻军"))
    for index in range(state.bianwu_units.size()):
        var unit = state.bianwu_units[index]
        if unit is Dictionary and str(unit.get("region_id", "")) == region_id:
            detail_box.add_child(_unit_slot(unit, index))
    detail_box.add_child(_empty_slot("可调入驻军", "garrison"))

    detail_box.add_child(_section_title("将官"))
    detail_box.add_child(_officer_slot("武官", "qinshui", "每月：防区安定度 +2"))
    detail_box.add_child(_officer_slot("书办", "shuban", "每月：驻防粮草、饷银供给 +15%"))

func attach_unit_drag_source(control: Control, index: int) -> void :
    var state: = _game_state()
    if state == null or index < 0 or index >= state.bianwu_units.size():
        return
    var unit = state.bianwu_units[index]
    var label: = str(unit.get("name", "部队")) if unit is Dictionary else "部队"
    _attach_drag_source(control, "unit", index, label)

func attach_officer_drag_source(control: Control, index: int) -> void :
    var state: = _game_state()
    if state == null or index < 0 or index >= state.bianwu_defense_officers.size():
        return
    var officer: Dictionary = state.bianwu_defense_officers[index]
    _attach_drag_source(control, "officer", index, str(officer.get("name", "人物")))

func _attach_drag_source(control: Control, kind: String, index: int, label: String) -> void :
    control.mouse_filter = Control.MOUSE_FILTER_PASS
    control.set_drag_forwarding(
        _get_drag_data.bind(kind, index, label, control), 
        _reject_source_drop, 
        _ignore_source_drop
    )
    control.gui_input.connect(_forward_source_touch_drag.bind(control))

func _get_drag_data(_position: Vector2, kind: String, index: int, label: String, source: Control) -> Variant:
    var preview: = PanelContainer.new()
    preview.custom_minimum_size = Vector2(150, 42)
    var preview_label: = Label.new()
    preview_label.text = label
    preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    preview.add_child(preview_label)
    source.set_drag_preview(preview)
    return {"kind": kind, "index": index}

func _reject_source_drop(_position: Vector2, _data: Variant) -> bool:
    return false

func _ignore_source_drop(_position: Vector2, _data: Variant) -> void :
    pass

func _section_title(text: String) -> Label:
    var label: = Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", 17)
    label.add_theme_color_override("font_color", Color(0.86, 0.72, 0.43))
    return label

func _hint(text: String) -> Label:
    var label: = Label.new()
    label.text = text
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_color_override("font_color", Color(0.68, 0.65, 0.58))
    return label

func _unit_slot(unit: Dictionary, index: int) -> Button:
    var unit_id: = str(unit.get("id", ""))
    var unit_def: Dictionary = BattleTypesRef.unit_def(unit_id)
    var button: = _slot_button(true, 56)
    var box: = _slot_content(button)

    var first_row: = HBoxContainer.new()
    first_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
    first_row.add_theme_constant_override("separation", 6)
    box.add_child(first_row)

    var name_label: = Label.new()
    name_label.text = str(unit.get("name", unit_def.get("name", "部队")))
    name_label.add_theme_font_override("font", FontLoaderRef.serif_bold())
    name_label.add_theme_font_size_override("font_size", _bw_font(13))
    name_label.add_theme_color_override("font_color", SLOT_TEXT_MAIN)
    name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    first_row.add_child(name_label)

    var level_label: = Label.new()
    level_label.text = "Lv.%d" % int(unit.get("level", 1))
    level_label.add_theme_font_override("font", FontLoaderRef.serif_bold())
    level_label.add_theme_font_size_override("font_size", _bw_font(11))
    level_label.add_theme_color_override("font_color", SLOT_ACCENT)
    first_row.add_child(level_label)

    var second_row: = HBoxContainer.new()
    second_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
    second_row.add_theme_constant_override("separation", 4)
    box.add_child(second_row)

    var atk_icon: = TextureRect.new()
    atk_icon.texture = load("res://assets/ui/status_icons/攻击力.svg")
    atk_icon.custom_minimum_size = Vector2(14, 14)
    atk_icon.ignore_texture_size = true
    atk_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    atk_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    second_row.add_child(atk_icon)

    var atk_label: = Label.new()
    atk_label.text = str(int(unit_def.get("atk", 10)))
    atk_label.add_theme_font_override("font", FontLoaderRef.serif_bold())
    atk_label.add_theme_font_size_override("font_size", _bw_font(12))
    atk_label.add_theme_color_override("font_color", SLOT_TEXT_MAIN)
    second_row.add_child(atk_label)

    var mid_spacer: = Control.new()
    mid_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    mid_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    second_row.add_child(mid_spacer)

    var strength_label: = Label.new()
    strength_label.text = str(int(unit.get("hp", 0)))
    strength_label.add_theme_font_override("font", FontLoaderRef.serif_bold())
    strength_label.add_theme_font_size_override("font_size", _bw_font(13))
    strength_label.add_theme_color_override("font_color", SLOT_ACCENT)
    second_row.add_child(strength_label)

    button.pressed.connect(_open_candidates.bind("garrison", index))
    button.mouse_entered.connect(_show_unit_hint.bind(button, index))
    button.mouse_exited.connect(_hide_unit_hint.bind(button))
    _attach_drop_target(button, "garrison", false)
    return button

func _empty_slot(text: String, slot_kind: String, effect_text: String = "") -> Button:
    var button: = _slot_button(false, 52)
    var box: = _slot_content(button)
    box.alignment = BoxContainer.ALIGNMENT_CENTER

    var hint_label: = Label.new()
    hint_label.text = "＋ " + text
    hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint_label.add_theme_font_override("font", FontLoaderRef.serif_bold())
    hint_label.add_theme_font_size_override("font_size", _bw_font(13))
    hint_label.add_theme_color_override("font_color", SLOT_EMPTY_TEXT)
    box.add_child(hint_label)

    if effect_text != "":
        var effect_label: = Label.new()
        effect_label.text = effect_text
        effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        effect_label.add_theme_font_size_override("font_size", _bw_font(11))
        effect_label.add_theme_color_override("font_color", Color(SLOT_TEXT_SUB.r, SLOT_TEXT_SUB.g, SLOT_TEXT_SUB.b, 0.72))
        box.add_child(effect_label)

    button.pressed.connect(_open_candidates.bind(slot_kind, -1))
    _attach_drop_target(button, slot_kind, false)
    return button

func _officer_slot(title: String, slot_kind: String, monthly_effect: String) -> Button:
    var state: = _game_state()
    var assigned_index: = -1
    var assigned: Dictionary = {}
    for index in range(state.bianwu_defense_officers.size()):
        var officer: Dictionary = state.bianwu_defense_officers[index]
        if str(officer.get("region_id", "")) == _region_id and BianwuDefenseServiceRef.officer_slot_kind(officer) == slot_kind:
            assigned_index = index
            assigned = officer
            break
    if assigned.is_empty():
        return _empty_slot("派任" + title, slot_kind, monthly_effect)
    var button: = _build_officer_card(assigned, assigned_index, title, monthly_effect)
    button.pressed.connect(_open_candidates.bind(slot_kind, assigned_index))
    _attach_drop_target(button, slot_kind, assigned_index >= 0)
    return button

func make_officer_card(officer: Dictionary, officer_index: int) -> Button:
    var slot_kind: = BianwuDefenseServiceRef.officer_slot_kind(officer)
    var title: = "武官" if slot_kind == "qinshui" else "书办"
    return _build_officer_card(officer, officer_index, title, str(officer.get("monthly_effect", "")))

func _build_officer_card(officer: Dictionary, officer_index: int, title: String, fallback_effect: String) -> Button:
    var button: = _slot_button(true, 0)
    var box: = _slot_content(button)

    var first_row: = HBoxContainer.new()
    first_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
    first_row.add_theme_constant_override("separation", 8)
    box.add_child(first_row)

    var role_label: = Label.new()
    role_label.text = title
    role_label.add_theme_font_override("font", FontLoaderRef.serif_bold())
    role_label.add_theme_font_size_override("font_size", _bw_font(11))
    role_label.add_theme_color_override("font_color", SLOT_ACCENT)
    role_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    first_row.add_child(role_label)

    var name_label: = Label.new()
    name_label.text = str(officer.get("name", "人物"))
    name_label.add_theme_font_override("font", FontLoaderRef.serif_bold())
    name_label.add_theme_font_size_override("font_size", _bw_font(13))
    name_label.add_theme_color_override("font_color", SLOT_TEXT_MAIN)
    name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    first_row.add_child(name_label)

    var relation_label: = Label.new()
    var relation: = str(officer.get("relation", "")).strip_edges()
    var specialty: = str(officer.get("specialty", "")).strip_edges()
    var relation_parts: Array[String] = []
    if relation != "":
        relation_parts.append(relation)
    if specialty != "":
        relation_parts.append(specialty)
    relation_label.text = " · ".join(relation_parts)
    relation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    relation_label.add_theme_font_size_override("font_size", _bw_font(11))
    relation_label.add_theme_color_override("font_color", SLOT_TEXT_SUB)
    box.add_child(relation_label)

    var effect_label: = Label.new()
    effect_label.text = str(officer.get("monthly_effect", fallback_effect))
    effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    effect_label.add_theme_font_size_override("font_size", _bw_font(11))
    effect_label.add_theme_color_override("font_color", SLOT_TEXT_SUB)
    box.add_child(effect_label)
    button.resized.connect(_sync_officer_card_height.bind(button, box))
    box.minimum_size_changed.connect(_sync_officer_card_height.bind(button, box))
    Callable(self, "_sync_officer_card_height").call_deferred(button, box)

    button.mouse_entered.connect(_show_officer_hint.bind(button, officer_index))
    button.mouse_exited.connect(_hide_officer_hint.bind(button))
    return button

func _sync_officer_card_height(button: Button, content: VBoxContainer) -> void :
    if button == null or content == null or not is_instance_valid(button) or not is_instance_valid(content):
        return
    var content_height: = 0.0
    var visible_rows: = 0
    for child in content.get_children():
        if child is Control and child.visible:
            content_height += (child as Control).get_combined_minimum_size().y
            visible_rows += 1
    if visible_rows > 1:
        content_height += float(content.get_theme_constant("separation") * (visible_rows - 1))
    var target_height: = ceilf(maxf(68.0, content_height + 16.0))
    if not is_equal_approx(button.custom_minimum_size.y, target_height):
        button.custom_minimum_size = Vector2(0, target_height)

func _show_officer_hint(anchor: Control, officer_index: int) -> void :
    if DisplayServer.is_touchscreen_available() or _host == null:
        return
    if _host.has_method("_show_bianwu_officer_hover_hint"):
        _host.call("_show_bianwu_officer_hover_hint", anchor, officer_index)

func _hide_officer_hint(anchor: Control) -> void :
    if _host != null and _host.has_method("_hide_bianwu_officer_hover_hint"):
        _host.call("_hide_bianwu_officer_hover_hint", anchor)

func _show_unit_hint(anchor: Control, unit_index: int) -> void :
    if DisplayServer.is_touchscreen_available() or _host == null:
        return
    if _host.has_method("_show_bianwu_unit_hover_hint"):
        _host.call("_show_bianwu_unit_hover_hint", anchor, unit_index)

func _hide_unit_hint(anchor: Control) -> void :
    if _host != null and _host.has_method("_hide_bianwu_unit_hover_hint"):
        _host.call("_hide_bianwu_unit_hover_hint", anchor)

func _bw_font(base: int) -> int:
    if _host != null and _host.has_method("_bw_detail_font"):
        return int(_host.call("_bw_detail_font", base, _layer))
    return base

func _slot_button(filled: bool, min_height: int) -> Button:
    var button: = Button.new()
    button.custom_minimum_size = Vector2(0, min_height)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.focus_mode = Control.FOCUS_NONE
    button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    button.add_theme_stylebox_override("normal", _slot_style(filled, "normal"))
    button.add_theme_stylebox_override("hover", _slot_style(filled, "hover"))
    button.add_theme_stylebox_override("pressed", _slot_style(filled, "pressed"))
    button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    button.gui_input.connect(_forward_touch_drag)
    return button


func _slot_style(filled: bool, state: String) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    if filled:
        match state:
            "hover":
                style.bg_color = Color(0.16, 0.1, 0.05, 0.62)
                style.border_color = Color(0.8, 0.62, 0.32, 0.42)
            "pressed":
                style.bg_color = Color(0.1, 0.07, 0.035, 0.76)
                style.border_color = Color(0.8, 0.62, 0.32, 0.42)
            _:
                style.bg_color = Color(0.1, 0.085, 0.06, 0.5)
                style.border_color = Color(0.72, 0.6, 0.36, 0.3)
    else:
        match state:
            "hover":
                style.bg_color = Color(0.16, 0.1, 0.05, 0.42)
                style.border_color = Color(0.8, 0.62, 0.32, 0.3)
            "pressed":
                style.bg_color = Color(0.1, 0.07, 0.035, 0.55)
                style.border_color = Color(0.8, 0.62, 0.32, 0.3)
            _:
                style.bg_color = Color(0.03, 0.026, 0.018, 0.38)
                style.border_color = Color(0.72, 0.6, 0.36, 0.14)
    style.set_border_width_all(1)
    style.corner_radius_top_left = 4
    style.corner_radius_top_right = 4
    style.corner_radius_bottom_left = 4
    style.corner_radius_bottom_right = 4
    return style


func _slot_content(button: Button) -> VBoxContainer:
    var margin: = MarginContainer.new()
    margin.set_anchors_preset(Control.PRESET_FULL_RECT)
    margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
    margin.add_theme_constant_override("margin_left", 12)
    margin.add_theme_constant_override("margin_right", 12)
    margin.add_theme_constant_override("margin_top", 8)
    margin.add_theme_constant_override("margin_bottom", 8)
    button.add_child(margin)
    var box: = VBoxContainer.new()
    box.mouse_filter = Control.MOUSE_FILTER_IGNORE
    box.add_theme_constant_override("separation", 6)
    margin.add_child(box)
    return box

func _attach_drop_target(control: Control, slot_kind: String, replace_existing: bool) -> void :
    control.set_drag_forwarding(
        _no_drag_data, 
        _can_drop_data.bind(slot_kind, replace_existing), 
        _drop_data.bind(slot_kind, replace_existing)
    )

func _no_drag_data(_position: Vector2) -> Variant:
    return null

func _can_drop_data(_position: Vector2, data: Variant, slot_kind: String, replace_existing: bool = false) -> bool:
    if not data is Dictionary:
        return false
    var kind: = str(data.get("kind", ""))
    if not ((slot_kind == "garrison" and kind == "unit") or (slot_kind in ["qinshui", "shuban"] and kind == "officer")):
        return false
    var payload: = (data as Dictionary).duplicate(true)
    if replace_existing and slot_kind != "garrison":
        payload["replace_existing"] = true
    var preview: = BianwuDefenseServiceRef.preview_deployment(_game_state(), payload, _region_id, slot_kind)
    return bool(preview.get("available", false))

func _drop_data(_position: Vector2, data: Variant, slot_kind: String, replace_existing: bool) -> void :
    if _can_drop_data(Vector2.ZERO, data, slot_kind, replace_existing):
        var payload: = (data as Dictionary).duplicate(true)
        if replace_existing and slot_kind != "garrison":
            payload["replace_existing"] = true
        _assign(payload, slot_kind)

func _forward_touch_drag(event: InputEvent) -> void :
    if _detail_scroll != null:
        NativeMobileTouchScrollRef.forward_drag_to_scroll(event, _detail_scroll, _host, TOUCH_SUPPRESS_KEY)

func _forward_touch_drag_to(event: InputEvent, scroll: ScrollContainer) -> void :
    NativeMobileTouchScrollRef.forward_drag_to_scroll(event, scroll, _host, TOUCH_SUPPRESS_KEY)

func _forward_source_touch_drag(event: InputEvent, source: Control) -> void :
    var scroll: = _find_scroll_parent(source)
    if scroll != null:
        NativeMobileTouchScrollRef.forward_drag_to_scroll(event, scroll, _host, TOUCH_SUPPRESS_KEY)

func _find_scroll_parent(control: Control) -> ScrollContainer:
    var parent: = control.get_parent()
    while parent != null:
        if parent is ScrollContainer:
            return parent as ScrollContainer
        parent = parent.get_parent()
    return null

func _open_candidates(slot_kind: String, assigned_index: int) -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(_host, TOUCH_SUPPRESS_KEY):
        return
    if _host != null and _host.has_method("_dismiss_bianwu_hover_hints"):
        _host.call("_dismiss_bianwu_hover_hints")
    var old: = _host.get_node_or_null("BianwuDeploymentCandidates")
    if old != null:
        old.queue_free()
    var layer: = Control.new()
    layer.name = "BianwuDeploymentCandidates"
    layer.set_anchors_preset(Control.PRESET_FULL_RECT)
    layer.mouse_filter = Control.MOUSE_FILTER_STOP
    layer.z_index = 1200
    _host.add_child(layer)
    var shade: = ColorRect.new()
    shade.set_anchors_preset(Control.PRESET_FULL_RECT)
    shade.color = Color(0, 0, 0, 0.78)
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    shade.gui_input.connect(_on_candidate_backdrop_input.bind(layer))
    layer.add_child(shade)
    var panel: = PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    panel.grow_vertical = Control.GROW_DIRECTION_BOTH
    panel.custom_minimum_size = Vector2(480, 420)
    var panel_style: = StyleBoxFlat.new()
    panel_style.bg_color = Color(0.075, 0.06, 0.04, 0.97)
    panel_style.set_border_width_all(1)
    panel_style.border_color = Color(0.42, 0.43, 0.44, 0.72)
    panel_style.corner_radius_top_left = 6;panel_style.corner_radius_top_right = 6
    panel_style.corner_radius_bottom_left = 6;panel_style.corner_radius_bottom_right = 6
    panel_style.content_margin_left = 26;panel_style.content_margin_right = 26
    panel_style.content_margin_top = 22;panel_style.content_margin_bottom = 20
    panel_style.shadow_color = Color(0, 0, 0, 0.38)
    panel_style.shadow_size = 14
    panel.add_theme_stylebox_override("panel", panel_style)
    layer.add_child(panel)
    var box: = VBoxContainer.new()
    box.add_theme_constant_override("separation", 12)
    panel.add_child(box)

    var title: = Label.new()
    title.text = "选择调派候选"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_override("font", FontLoaderRef.serif_bold())
    title.add_theme_font_size_override("font_size", 18)
    title.add_theme_color_override("font_color", Color(0.95, 0.78, 0.42))
    box.add_child(title)

    var scroll: = ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(420, 280)
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
    box.add_child(scroll)
    _candidate_scroll = scroll
    var list: = VBoxContainer.new()
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list.add_theme_constant_override("separation", 10)
    scroll.add_child(list)
    var replace_existing: = assigned_index >= 0 and slot_kind != "garrison"
    var count: = _populate_candidates(list, slot_kind, layer, replace_existing)
    if count == 0:
        var empty_hint: = _hint("暂无可调派对象")
        empty_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        empty_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        list.add_child(empty_hint)

    var btn_row: = HBoxContainer.new()
    btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
    btn_row.add_theme_constant_override("separation", 14)
    box.add_child(btn_row)
    if assigned_index >= 0:
        var home_id: = _home_region_id()
        if home_id != "" and home_id != _region_id:
            var withdraw: = _command_button("撤回边务主防区", true)
            withdraw.pressed.connect(_withdraw_from_popup.bind(_payload_for(slot_kind, assigned_index, true), slot_kind, home_id, layer))
            withdraw.gui_input.connect(_forward_touch_drag_to.bind(_candidate_scroll))
            btn_row.add_child(withdraw)
    var close: = _command_button("关闭", false)
    close.pressed.connect(_close_candidates.bind(layer))
    close.gui_input.connect(_forward_touch_drag_to.bind(_candidate_scroll))
    btn_row.add_child(close)

func _on_candidate_backdrop_input(event: InputEvent, popup: Control) -> void :
    var pressed_outside: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
    pressed_outside = pressed_outside or (event is InputEventScreenTouch and event.pressed)
    if pressed_outside and popup != null and is_instance_valid(popup):
        popup.queue_free()



func _command_button(text: String, primary: bool) -> Button:
    var button: = Button.new()
    button.text = text
    button.focus_mode = Control.FOCUS_NONE
    button.custom_minimum_size = Vector2(96, 34)
    button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    button.add_theme_font_override("font", FontLoaderRef.serif_bold())
    button.add_theme_font_size_override("font_size", 14)
    if primary:
        button.add_theme_color_override("font_color", Color(0.1, 0.075, 0.04))
        button.add_theme_color_override("font_hover_color", Color(0.16, 0.12, 0.06))
        button.add_theme_color_override("font_pressed_color", Color(0.16, 0.12, 0.06))
    else:
        button.add_theme_color_override("font_color", SLOT_ACCENT)
        button.add_theme_color_override("font_hover_color", Color(0.95, 0.8, 0.5))
        button.add_theme_color_override("font_pressed_color", Color(0.95, 0.8, 0.5))
    button.add_theme_stylebox_override("normal", _command_button_style(primary, "normal"))
    button.add_theme_stylebox_override("hover", _command_button_style(primary, "hover"))
    button.add_theme_stylebox_override("pressed", _command_button_style(primary, "pressed"))
    button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    return button

func _command_button_style(primary: bool, state: String) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    if primary:
        match state:
            "hover":
                style.bg_color = Color(0.86, 0.72, 0.45, 0.96)
                style.border_color = Color(0.55, 0.42, 0.2, 0.6)
            "pressed":
                style.bg_color = Color(0.7, 0.57, 0.33, 0.96)
                style.border_color = Color(0.55, 0.42, 0.2, 0.6)
            _:
                style.bg_color = Color(0.78, 0.64, 0.38, 0.94)
                style.border_color = Color(0.55, 0.42, 0.2, 0.55)
    else:
        match state:
            "hover":
                style.bg_color = Color(0.16, 0.1, 0.05, 0.62)
                style.border_color = Color(0.8, 0.62, 0.32, 0.42)
            "pressed":
                style.bg_color = Color(0.1, 0.07, 0.035, 0.76)
                style.border_color = Color(0.8, 0.62, 0.32, 0.42)
            _:
                style.bg_color = Color(0.02, 0.018, 0.014, 0.62)
                style.border_color = Color(0.72, 0.56, 0.28, 0.3)
    style.set_border_width_all(1)
    style.corner_radius_top_left = 6
    style.corner_radius_top_right = 6
    style.corner_radius_bottom_left = 6
    style.corner_radius_bottom_right = 6
    style.content_margin_left = 16
    style.content_margin_right = 16
    style.content_margin_top = 6
    style.content_margin_bottom = 6
    return style

func _populate_candidates(list: VBoxContainer, slot_kind: String, layer: Control, replace_existing: bool) -> int:
    var state: = _game_state()
    var count: = 0
    if slot_kind == "garrison":
        for index in range(state.bianwu_units.size()):
            var unit = state.bianwu_units[index]
            if not unit is Dictionary:
                continue
            list.add_child(_candidate_button(str(unit.get("name", "部队")), index, slot_kind, str(unit.get("region_id", "")), layer, false))
            count += 1
    else:
        for index in range(state.bianwu_defense_officers.size()):
            var officer: Dictionary = state.bianwu_defense_officers[index]
            if BianwuDefenseServiceRef.officer_slot_kind(officer) != slot_kind:
                continue
            list.add_child(_candidate_button(str(officer.get("name", "人物")), index, slot_kind, str(officer.get("region_id", "")), layer, replace_existing))
            count += 1
    return count

func _candidate_button(display_name: String, index: int, slot_kind: String, current_region_id: String, layer: Control, replace_existing: bool) -> Button:
    var payload: = _payload_for(slot_kind, index, replace_existing)
    var preview: = BianwuDefenseServiceRef.preview_deployment(_game_state(), payload, _region_id, slot_kind)
    var reason: = str(preview.get("reason", ""))
    var available: = bool(preview.get("available", false))
    var region_name: = _region_name(current_region_id)
    var cost_text: = "现防区：%s　　成本：行动力%d" % [region_name, int(preview.get("command_cost", 0))]
    if int(preview.get("grain_cost", 0)) > 0:
        cost_text += "、粮草%d" % int(preview.get("grain_cost", 0))

    var button: = _slot_button(available, 0)

    button.gui_input.disconnect(_forward_touch_drag)
    button.disabled = not available
    if not available:

        button.add_theme_stylebox_override("disabled", _slot_style(false, "normal"))
        button.mouse_default_cursor_shape = Control.CURSOR_ARROW
    var box: = _slot_content(button)
    box.add_theme_constant_override("separation", 4)

    var first_row: = HBoxContainer.new()
    first_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
    first_row.add_theme_constant_override("separation", 8)
    box.add_child(first_row)

    var name_label: = Label.new()
    name_label.text = display_name
    name_label.add_theme_font_override("font", FontLoaderRef.serif_bold())
    name_label.add_theme_font_size_override("font_size", 14)
    name_label.add_theme_color_override("font_color", SLOT_TEXT_MAIN if available else Color(SLOT_TEXT_MAIN.r, SLOT_TEXT_MAIN.g, SLOT_TEXT_MAIN.b, 0.45))
    name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    first_row.add_child(name_label)

    var tag_label: = Label.new()
    if not available:
        tag_label.text = "不可调"
        tag_label.add_theme_color_override("font_color", Color(0.7, 0.36, 0.22, 0.85))
    elif replace_existing and slot_kind != "garrison":
        tag_label.text = "更换现任"
        tag_label.add_theme_color_override("font_color", SLOT_ACCENT)
    if tag_label.text != "":
        tag_label.add_theme_font_override("font", FontLoaderRef.serif_bold())
        tag_label.add_theme_font_size_override("font_size", 11)
        tag_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        first_row.add_child(tag_label)

    var info_label: = Label.new()
    info_label.text = cost_text
    info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info_label.add_theme_font_size_override("font_size", 11)
    info_label.add_theme_color_override("font_color", SLOT_TEXT_SUB if available else Color(SLOT_TEXT_SUB.r, SLOT_TEXT_SUB.g, SLOT_TEXT_SUB.b, 0.55))
    box.add_child(info_label)

    if reason != "":
        var reason_label: = Label.new()
        reason_label.text = "不可调缘由：" + reason
        reason_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        reason_label.add_theme_font_size_override("font_size", 11)
        reason_label.add_theme_color_override("font_color", Color(0.7, 0.36, 0.22, 0.75))
        box.add_child(reason_label)


    button.custom_minimum_size = Vector2(0, 56 if reason == "" else 74)
    button.pressed.connect(_assign_from_popup.bind(payload, slot_kind, layer))
    button.gui_input.connect(_forward_touch_drag_to.bind(_candidate_scroll))
    return button

func _payload_for(slot_kind: String, index: int, replace_existing: bool = false) -> Dictionary:
    return {"kind": "unit" if slot_kind == "garrison" else "officer", "index": index, "replace_existing": replace_existing}

func _assign_from_popup(payload: Dictionary, slot_kind: String, popup: Control) -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(_host, TOUCH_SUPPRESS_KEY):
        return
    popup.queue_free()
    _assign(payload, slot_kind)

func _withdraw_from_popup(payload: Dictionary, slot_kind: String, target_region_id: String, popup: Control) -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(_host, TOUCH_SUPPRESS_KEY):
        return
    popup.queue_free()
    var result: = BianwuDefenseServiceRef.assign_deployment(_game_state(), payload, target_region_id, slot_kind)
    _host.call("_on_bianwu_deployment_result", result, target_region_id, _layer)

func _close_candidates(popup: Control) -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(_host, TOUCH_SUPPRESS_KEY):
        return
    popup.queue_free()

func _assign(payload: Dictionary, slot_kind: String) -> void :
    var result: = BianwuDefenseServiceRef.assign_deployment(_game_state(), payload, _region_id, slot_kind)
    _host.call("_on_bianwu_deployment_result", result, _region_id, _layer)

func _home_region_id() -> String:
    var state: = _game_state()
    return BianwuDefenseServiceRef.default_region_id(state)

func _region_name(region_id: String) -> String:
    var state: = _game_state()
    for region in state.bianwu_defense_regions:
        if str(region.get("id", "")) == region_id:
            return str(region.get("name", "未知防区"))
    return "未知防区"
