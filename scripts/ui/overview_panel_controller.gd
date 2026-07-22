extends RefCounted
class_name OverviewPanelController








const Presenter = preload("res://scripts/ui/game_screen_presenter.gd")
const StatusIconUtil = preload("res://scripts/ui/status_icon_util.gd")
const FontLoader = preload("res://scripts/ui/font_loader.gd")
const ScrollbarThemeRef = preload("res://scripts/ui/scrollbar_theme.gd")
const NativeMobileTouchScrollRef = preload("res://scripts/ui/native_mobile_touch_scroll.gd")
const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")
const PersonalStatCapstoneServiceRef = preload("res://scripts/services/personal_stat_capstone_service.gd")

var _host
var _layer: CanvasLayer = null
var _content: Control = null

var _overview_tab: String = "data"
var _overview_grid: GridContainer = null
var _overview_scroll: ScrollContainer = null
var _overview_tabs_row: HBoxContainer = null

func _init(host) -> void :
    _host = host



func _sz(portrait_v: int, native_v: int, desktop_v: int) -> int:
    if _host._is_mobile_portrait():
        return portrait_v
    if _host._is_native_mobile_landscape():
        return native_v
    return desktop_v



func show_overview_panel() -> void :
    close_overview_panel()
    _overview_tab = "data"
    var portrait: bool = _host._is_mobile_portrait()
    var vp: Vector2 = _host.get_viewport_rect().size

    _layer = CanvasLayer.new()
    _layer.name = "OverviewPanelLayer"
    _layer.layer = 125
    _host.get_tree().root.add_child(_layer)


    var dim: = ColorRect.new()
    dim.color = Color(0, 0, 0, 0.66) if GameState.theme == "dark" else Color(0.2, 0.16, 0.1, 0.42)
    dim.set_anchors_preset(Control.PRESET_FULL_RECT)
    dim.mouse_filter = Control.MOUSE_FILTER_STOP
    dim.gui_input.connect( func(event: InputEvent):
        if Presenter._is_primary_press_event(event):
            close_overview_panel()
    )
    _layer.add_child(dim)


    var panel: = PanelContainer.new()
    var panel_style: = _panel_style()

    panel_style.corner_radius_top_left = 0
    panel_style.corner_radius_top_right = 0
    panel_style.corner_radius_bottom_left = 0
    panel_style.corner_radius_bottom_right = 0
    panel.add_theme_stylebox_override("panel", panel_style)
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    panel.custom_minimum_size = vp
    panel.size = vp
    panel.position = Vector2.ZERO
    _layer.add_child(panel)

    var pad: = 28 if portrait else 30
    var margin: = MarginContainer.new()
    for side in ["left", "right", "top", "bottom"]:
        margin.add_theme_constant_override("margin_" + side, pad)
    panel.add_child(margin)

    var root_vbox: = VBoxContainer.new()
    root_vbox.add_theme_constant_override("separation", 14 if portrait else 12)
    margin.add_child(root_vbox)
    _content = root_vbox


    var header: = HBoxContainer.new()
    header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    root_vbox.add_child(header)
    var title: = Label.new()
    title.text = "数据总览"
    title.add_theme_font_override("font", FontLoader.title())
    title.add_theme_font_size_override("font_size", _sz(30, 24, 22))
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)

    _overview_tabs_row = HBoxContainer.new()
    _overview_tabs_row.add_theme_constant_override("separation", 8)
    _overview_tabs_row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    root_vbox.add_child(_overview_tabs_row)
    _rebuild_overview_tabs()

    var close_btn: = Button.new()
    close_btn.text = "返回"
    close_btn.icon = load("res://assets/ui/back.svg")
    close_btn.expand_icon = false
    close_btn.focus_mode = Control.FOCUS_NONE
    close_btn.custom_minimum_size = Vector2(_sz(200, 128, 128), _sz(80, 42, 42))
    close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    close_btn.add_theme_font_size_override("font_size", _sz(36, 16, 16))
    close_btn.add_theme_constant_override("icon_max_width", _sz(36, 16, 16))
    close_btn.add_theme_constant_override("h_separation", 6)
    close_btn.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    close_btn.add_theme_color_override("font_hover_color", GameState.get_theme_color("border_active"))
    close_btn.add_theme_stylebox_override("normal", GameScreenStyleFactory.modal_return_button_style("normal"))
    close_btn.add_theme_stylebox_override("hover", GameScreenStyleFactory.modal_return_button_style("hover"))
    close_btn.add_theme_stylebox_override("pressed", GameScreenStyleFactory.modal_return_button_style("pressed"))
    close_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    close_btn.pressed.connect(close_overview_panel)
    close_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    header.add_child(close_btn)

    var sep: = HSeparator.new()
    var sep_style: = StyleBoxLine.new()
    sep_style.color = GameState.get_theme_color("border_weak")
    sep.add_theme_stylebox_override("separator", sep_style)
    root_vbox.add_child(sep)


    var scroll: = ScrollContainer.new()
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    root_vbox.add_child(scroll)
    ScrollbarThemeRef.apply_to(scroll)
    _overview_scroll = scroll

    var grid_margin: = MarginContainer.new()
    grid_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    grid_margin.add_theme_constant_override("margin_right", 16)
    scroll.add_child(grid_margin)


    var grid: = GridContainer.new()
    grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    grid.columns = 1 if portrait else 3
    grid.add_theme_constant_override("h_separation", 16)
    grid.add_theme_constant_override("v_separation", 16 if portrait else 14)
    grid_margin.add_child(grid)
    _overview_grid = grid

    _rebuild_overview_grid(portrait)




func close_overview_panel() -> void :
    if _layer != null and is_instance_valid(_layer):
        _layer.queue_free()
    _layer = null
    _content = null
    _overview_grid = null
    _overview_scroll = null
    _overview_tabs_row = null



func _rebuild_overview_tabs() -> void :
    if _overview_tabs_row == null or not is_instance_valid(_overview_tabs_row):
        return
    for c in _overview_tabs_row.get_children():
        c.queue_free()
    var defs: = [{"key": "data", "label": "数据总览"}, {"key": "boosts", "label": "增益总览"}]
    for d in defs:
        var key: String = d["key"]
        var active: bool = key == _overview_tab
        var btn: = Button.new()
        btn.text = d["label"]
        btn.focus_mode = Control.FOCUS_NONE
        btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
        btn.add_theme_font_size_override("font_size", _sz(20, 19, 14))
        btn.add_theme_color_override("font_color", _overview_tab_text_color(active))
        btn.add_theme_color_override("font_hover_color", GameState.get_theme_color("border_active"))
        btn.add_theme_stylebox_override("normal", _overview_tab_style(active))
        btn.add_theme_stylebox_override("hover", _overview_tab_style(true))
        btn.add_theme_stylebox_override("pressed", _overview_tab_style(true))
        btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
        btn.pressed.connect( func():
            if _overview_tab == key:
                return
            _overview_tab = key
            _rebuild_overview_tabs()
            _rebuild_overview_grid(_host._is_mobile_portrait())
        )
        _overview_tabs_row.add_child(btn)

func _rebuild_overview_grid(portrait: bool) -> void :
    if _overview_grid == null or not is_instance_valid(_overview_grid):
        return
    for child in _overview_grid.get_children():
        _overview_grid.remove_child(child)
        child.queue_free()
    if _overview_tab == "boosts":
        _overview_grid.columns = 1
        var governance_card: = _make_governance_boost_section_card(portrait)
        var personal_card: = _make_personal_boost_section_card(portrait)
        var capstone_rows: Array = PersonalStatCapstoneServiceRef.active_bonus_rows(GameState)
        var capstone_card: Control = _make_capstone_boost_section_card(portrait) if not capstone_rows.is_empty() else null
        if portrait:
            var stack: = VBoxContainer.new()
            stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            stack.add_theme_constant_override("separation", 16)
            stack.add_child(governance_card)
            stack.add_child(personal_card)
            if capstone_card != null:
                stack.add_child(capstone_card)
            _overview_grid.add_child(stack)
        else:
            governance_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            governance_card.size_flags_stretch_ratio = 1.0
            personal_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            personal_card.size_flags_stretch_ratio = 1.0
            var row: = HBoxContainer.new()
            row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            row.add_theme_constant_override("separation", 16)
            row.add_child(governance_card)
            row.add_child(personal_card)
            if capstone_card != null:
                capstone_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                capstone_card.size_flags_stretch_ratio = 1.0
                row.add_child(capstone_card)
            _overview_grid.add_child(row)
    else:
        _overview_grid.columns = 1 if portrait else 3
        for section in _build_sections():
            _overview_grid.add_child(_make_section_card(section, portrait))



    _connect_overview_scroll_drag_forwarders()

func _connect_overview_scroll_drag_forwarders() -> void :
    if _overview_grid == null or not is_instance_valid(_overview_grid):
        return
    if _overview_scroll == null or not is_instance_valid(_overview_scroll):
        return
    _host._connect_scroll_drag_forwarders_recursive(_overview_grid, _on_overview_scroll_touch_drag)

func _on_overview_scroll_touch_drag(event: InputEvent) -> void :
    NativeMobileTouchScrollRef.forward_drag_to_scroll(event, _overview_scroll, _host, "overview_scroll_touch_drag_suppress_until_ms")

func _overview_tab_style(active: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    if active:
        style.bg_color = Color(0.78, 0.62, 0.34, 0.26) if GameState.theme == "dark" else Color(0.86, 0.76, 0.52, 0.42)
        style.border_color = Color(0.82, 0.68, 0.4, 0.5) if GameState.theme == "dark" else Color(0.56, 0.4, 0.16, 0.5)
    else:
        style.bg_color = Color(0.02, 0.018, 0.014, 0.3) if GameState.theme == "dark" else Color(1.0, 0.97, 0.88, 0.3)
        style.border_color = Color(0.72, 0.6, 0.34, 0.22) if GameState.theme == "dark" else Color(0.54, 0.4, 0.18, 0.22)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.content_margin_left = _sz(20, 18, 14)
    style.content_margin_right = _sz(20, 18, 14)
    style.content_margin_top = _sz(8, 7, 6)
    style.content_margin_bottom = _sz(9, 8, 7)
    style.corner_radius_top_left = 8
    style.corner_radius_top_right = 8
    style.corner_radius_bottom_left = 8
    style.corner_radius_bottom_right = 8
    return style

func _overview_tab_text_color(active: bool) -> Color:
    if not active:
        return GameState.get_theme_color("text_sub")
    if GameState.theme == "dark":
        return GameState.get_theme_color("border_active")
    return Color(0.4, 0.27, 0.08, 1.0)

func _panel_style() -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0.035, 0.029, 0.022, 0.985) if GameState.theme == "dark" else Color(0.878, 0.886, 0.902, 0.99)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = Color(0.82, 0.68, 0.4, 0.46) if GameState.theme == "dark" else Color(0.56, 0.4, 0.16, 0.44)
    style.corner_radius_top_left = 6
    style.corner_radius_top_right = 6
    style.corner_radius_bottom_right = 6
    style.corner_radius_bottom_left = 6
    style.shadow_color = Color(0, 0, 0, 0.0) if GameState.theme == "light" else Color(0, 0, 0, 0.5)
    style.shadow_size = 0 if GameState.theme == "light" else 16
    style.shadow_offset = Vector2(0, 6)
    return style



func _make_section_card(section: Dictionary, portrait: bool) -> Control:
    var card: = PanelContainer.new()
    card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    card.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    card.add_theme_stylebox_override("panel", _card_style())

    var inner: = MarginContainer.new()
    var ipad: = _sz(20, 20, 16)
    inner.add_theme_constant_override("margin_left", ipad)
    inner.add_theme_constant_override("margin_right", ipad)
    inner.add_theme_constant_override("margin_top", ipad - 2)
    inner.add_theme_constant_override("margin_bottom", ipad - 2)
    card.add_child(inner)

    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", _sz(8, 8, 6))
    inner.add_child(vbox)


    var head: = HBoxContainer.new()
    head.add_theme_constant_override("separation", 8)
    vbox.add_child(head)

    var icon_size: = float(_sz(30, 30, 20))
    var icon: = StatusIconUtil.make_texture(str(section.get("key", "")), icon_size)
    if icon != null:
        if GameState.theme == "light":
            icon.modulate = Color(1, 1, 1, 1)
        head.add_child(icon)

    var name_lbl: = Label.new()
    name_lbl.text = str(section.get("label", ""))
    name_lbl.add_theme_font_override("font", FontLoader.serif_bold())
    name_lbl.add_theme_font_size_override("font_size", _sz(24, 23, 16))
    name_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    head.add_child(name_lbl)

    var head_spacer: = Control.new()
    head_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    head.add_child(head_spacer)

    var cur_caption: = Label.new()
    cur_caption.text = "现有 "
    cur_caption.add_theme_font_size_override("font_size", _sz(16, 15, 10))
    cur_caption.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    cur_caption.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
    head.add_child(cur_caption)

    var cur_val: = Label.new()
    cur_val.text = str(section.get("current", ""))
    cur_val.add_theme_font_size_override("font_size", _sz(26, 26, 18))
    cur_val.add_theme_color_override("font_color", GameState.get_theme_color("border_active") if GameState.theme == "dark" else Color(0.4, 0.29, 0.1))
    cur_val.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    head.add_child(cur_val)


    var hs: = HSeparator.new()
    var hs_style: = StyleBoxLine.new()
    hs_style.color = GameState.get_theme_color("border_weak")
    hs.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs)


    var body_size: = _sz(18, 20, 13)
    var rows: Array = section.get("rows", [])
    if rows.is_empty():
        var empty: = Label.new()
        empty.text = "本月无明显增减"
        empty.add_theme_font_size_override("font_size", body_size)
        empty.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        vbox.add_child(empty)
    for r in rows:
        vbox.add_child(_make_value_row(str(r.get("label", "")), str(r.get("text", "")), str(r.get("kind", "neutral")), body_size, false))


    if bool(section.get("has_net", false)):
        var hs2: = HSeparator.new()
        hs2.add_theme_stylebox_override("separator", hs_style)
        vbox.add_child(hs2)
        vbox.add_child(_make_value_row(str(section.get("net_label", "净增减")), str(section.get("net_text", "")), str(section.get("net_kind", "neutral")), body_size, true))


    var note: = str(section.get("note", ""))
    if note != "":
        var note_lbl: = Label.new()
        note_lbl.text = note
        note_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        note_lbl.add_theme_font_size_override("font_size", _sz(17, 18, 13))
        note_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        note_lbl.add_theme_constant_override("line_spacing", _sz(3, 3, 1))
        vbox.add_child(note_lbl)

    return card



func _make_governance_boost_section_card(portrait: bool) -> Control:
    GameState.normalize_city_boost_item_slots()
    var item_ids: Array = GameState.get_city_boost_item_ids()



    var totals: = {}
    var status_totals: = {}
    var items: = []
    for raw_id in item_ids:
        var item_id: = str(raw_id)
        if item_id == "":
            continue
        var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
        if item_def.is_empty():
            continue
        var city_effects: Dictionary = item_def.get("cityEffects", {})
        var effect_parts: = []
        for raw_key in city_effects:
            var key: = str(raw_key)
            if not GameData.CITY_STAT_KEYS.has(key):
                continue
            var amt: = int(city_effects[raw_key])
            if amt == 0:
                continue
            totals[key] = int(totals.get(key, 0)) + amt
            effect_parts.append("%s %+d" % [GameData.city_stat_effect_label(key), amt])

        var status_eff: Dictionary = GameState.get_item_monthly_status_effects(item_id)
        for key in GameState.ITEM_STATUS_EFFECT_KEYS:
            if not status_eff.has(key):
                continue
            var amt: = int(status_eff[key])
            if amt == 0:
                continue
            status_totals[key] = int(status_totals.get(key, 0)) + amt
            effect_parts.append("%s %+d/月" % [GameState.ITEM_STATUS_EFFECT_LABELS.get(key, key), amt])
        if effect_parts.is_empty():
            continue
        items.append({"name": GameScreenPresenter.resolve_text_placeholders(str(item_def.get("name", item_id))), "effects": "、".join(effect_parts)})

    var card: = PanelContainer.new()
    card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    card.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    card.add_theme_stylebox_override("panel", _card_style())

    var inner: = MarginContainer.new()
    var ipad: = _sz(20, 20, 16)
    inner.add_theme_constant_override("margin_left", ipad)
    inner.add_theme_constant_override("margin_right", ipad)
    inner.add_theme_constant_override("margin_top", ipad - 2)
    inner.add_theme_constant_override("margin_bottom", ipad - 2)
    card.add_child(inner)

    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", _sz(8, 8, 6))
    inner.add_child(vbox)


    var head: = HBoxContainer.new()
    head.add_theme_constant_override("separation", 8)
    vbox.add_child(head)

    var icon_size: = float(_sz(30, 30, 20))
    var city_tex: = load("res://assets/ui/status_icons/city.webp") as Texture2D
    if city_tex != null:
        var icon: = TextureRect.new()
        icon.texture = city_tex
        icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        icon.custom_minimum_size = Vector2(icon_size, icon_size)
        icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        icon.modulate = Color(1, 1, 1, 1) if GameState.theme == "light" else StatusIconUtil.modulate()
        head.add_child(icon)

    var name_lbl: = Label.new()
    name_lbl.text = "治理增益总览"
    name_lbl.add_theme_font_override("font", FontLoader.serif_bold())
    name_lbl.add_theme_font_size_override("font_size", _sz(24, 23, 16))
    name_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    head.add_child(name_lbl)

    var head_spacer: = Control.new()
    head_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    head.add_child(head_spacer)

    var cur_caption: = Label.new()
    cur_caption.text = "已配 "
    cur_caption.add_theme_font_size_override("font_size", _sz(16, 15, 10))
    cur_caption.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    cur_caption.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
    head.add_child(cur_caption)

    var cur_val: = Label.new()
    cur_val.text = "%d 件" % items.size()
    cur_val.add_theme_font_size_override("font_size", _sz(26, 26, 18))
    cur_val.add_theme_color_override("font_color", GameState.get_theme_color("border_active") if GameState.theme == "dark" else Color(0.4, 0.29, 0.1))
    cur_val.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    head.add_child(cur_val)


    var hs: = HSeparator.new()
    var hs_style: = StyleBoxLine.new()
    hs_style.color = GameState.get_theme_color("border_weak")
    hs.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs)

    var body_size: = _sz(18, 20, 13)
    if items.is_empty():
        var empty: = Label.new()
        empty.text = "尚未配置随身物品。可在城池属性卡的「增益」页签里装入有城池加成、或能每月增减库银/官粮/兵勇/流民/人口的物品。"
        empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        empty.add_theme_font_size_override("font_size", body_size)
        empty.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        vbox.add_child(empty)
        return card

    _fill_boost_items(vbox, items, body_size)
    var hs2: = HSeparator.new()
    hs2.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs2)
    _fill_boost_totals(vbox, totals, status_totals, body_size)
    var governance_note_gap: = Control.new()
    governance_note_gap.custom_minimum_size = Vector2(0, _sz(8, 8, 6))
    vbox.add_child(governance_note_gap)
    vbox.add_child(_make_governance_boost_note())

    return card

func _make_capstone_boost_section_card(portrait: bool) -> Control:
    var card: = PanelContainer.new()
    card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    card.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    card.add_theme_stylebox_override("panel", _card_style())
    var inner: = MarginContainer.new()
    var ipad: = _sz(20, 20, 16)
    inner.add_theme_constant_override("margin_left", ipad)
    inner.add_theme_constant_override("margin_right", ipad)
    inner.add_theme_constant_override("margin_top", ipad - 2)
    inner.add_theme_constant_override("margin_bottom", ipad - 2)
    card.add_child(inner)
    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", _sz(8, 8, 6))
    inner.add_child(vbox)
    var title: = Label.new()
    title.text = "满值禀赋加成"
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", _sz(24, 23, 16))
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    vbox.add_child(title)
    var hs: = HSeparator.new()
    var hs_style: = StyleBoxLine.new()
    hs_style.color = GameState.get_theme_color("border_weak")
    hs.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs)
    for row in PersonalStatCapstoneServiceRef.active_bonus_rows(GameState):
        var label: = Label.new()
        label.text = "%s｜%s" % [str(row.get("label", "")), str(row.get("text", ""))]
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        label.add_theme_font_size_override("font_size", _sz(18, 20, 13))
        label.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        vbox.add_child(label)
    return card

func _make_personal_boost_section_card(portrait: bool) -> Control:
    GameState.normalize_personal_boost_item_slots()
    var item_ids: Array = GameState.personal_boost_item_slots
    var totals: = {}
    var items: = []
    for raw_id in item_ids:
        var item_id: = str(raw_id)
        if item_id == "":
            continue
        var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
        if item_def.is_empty():
            continue
        var effects: Dictionary = item_def.get("effects", {})
        var effect_parts: = []
        for key in ["wentao", "wulue", "lizheng", "tizhi"]:
            var amt: = int(effects.get(key, 0))
            if amt == 0:
                continue
            totals[key] = int(totals.get(key, 0)) + amt
            effect_parts.append("%s %+d" % [str(GameData.STAT_LABELS.get(key, key)), amt])
        if effect_parts.is_empty():
            continue
        items.append({"name": GameScreenPresenter.resolve_text_placeholders(str(item_def.get("name", item_id))), "effects": "、".join(effect_parts)})

    var card: = PanelContainer.new()
    card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    card.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    card.add_theme_stylebox_override("panel", _card_style())
    var inner: = MarginContainer.new()
    var ipad: = _sz(20, 20, 16)
    inner.add_theme_constant_override("margin_left", ipad)
    inner.add_theme_constant_override("margin_right", ipad)
    inner.add_theme_constant_override("margin_top", ipad - 2)
    inner.add_theme_constant_override("margin_bottom", ipad - 2)
    card.add_child(inner)
    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", _sz(8, 8, 6))
    inner.add_child(vbox)

    var head: = HBoxContainer.new()
    head.add_theme_constant_override("separation", 8)
    vbox.add_child(head)
    var icon_size: = float(_sz(30, 30, 20))
    var icon: = StatusIconUtil.make_texture("minwang", icon_size)
    if icon != null:
        head.add_child(icon)
    var name_lbl: = Label.new()
    name_lbl.text = "个人增益总览"
    name_lbl.add_theme_font_override("font", FontLoader.serif_bold())
    name_lbl.add_theme_font_size_override("font_size", _sz(24, 23, 16))
    name_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    head.add_child(name_lbl)
    var head_spacer: = Control.new()
    head_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    head.add_child(head_spacer)
    var cur_caption: = Label.new()
    cur_caption.text = "已配 "
    cur_caption.add_theme_font_size_override("font_size", _sz(16, 15, 10))
    cur_caption.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    head.add_child(cur_caption)
    var cur_val: = Label.new()
    cur_val.text = "%d 件" % items.size()
    cur_val.add_theme_font_size_override("font_size", _sz(26, 26, 18))
    cur_val.add_theme_color_override("font_color", GameState.get_theme_color("border_active") if GameState.theme == "dark" else Color(0.4, 0.29, 0.1))
    head.add_child(cur_val)

    var hs: = HSeparator.new()
    var hs_style: = StyleBoxLine.new()
    hs_style.color = GameState.get_theme_color("border_weak")
    hs.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs)
    var body_size: = _sz(18, 20, 13)
    if items.is_empty():
        var empty: = Label.new()
        empty.text = "尚未配置个人增益物品。可在城池属性卡的「增益」页签里装入能提升文韬、武略、理政或体质的物品。"
        empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        empty.add_theme_font_size_override("font_size", body_size)
        empty.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        vbox.add_child(empty)
        return card

    _fill_boost_items(vbox, items, body_size)
    var hs2: = HSeparator.new()
    hs2.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs2)
    _fill_boost_totals(vbox, totals, {}, body_size, ["wentao", "wulue", "lizheng", "tizhi"])
    var personal_note_gap: = Control.new()
    personal_note_gap.custom_minimum_size = Vector2(0, _sz(8, 8, 6))
    vbox.add_child(personal_note_gap)
    vbox.add_child(_make_personal_boost_note())
    return card


func _fill_boost_items(container: VBoxContainer, items: Array, body_size: int) -> void :
    for it in items:
        container.add_child(_make_value_row(str(it.get("name", "")), str(it.get("effects", "")), "pos", body_size, false))


func _fill_boost_totals(container: VBoxContainer, totals: Dictionary, status_totals: Dictionary, body_size: int, stat_keys: Array = []) -> void :
    var display_keys: Array = GameData.CITY_STAT_KEYS if stat_keys.is_empty() else stat_keys
    for key in display_keys:
        if not totals.has(key):
            continue
        var amt: = int(totals[key])
        if amt == 0:
            continue
        var label: = GameData.city_stat_effect_label(key) if stat_keys.is_empty() else str(GameData.STAT_LABELS.get(key, key))
        container.add_child(_make_value_row(label, "+%d" % amt, "pos", body_size, true))


    for key in GameState.ITEM_STATUS_EFFECT_KEYS:
        if not status_totals.has(key):
            continue
        var amt: = int(status_totals[key])
        if amt == 0:
            continue
        var tone: = "pos" if amt > 0 else "neg"

        if key == "liumin":
            tone = "pos" if amt < 0 else "neg"
        container.add_child(_make_value_row(str(GameState.ITEM_STATUS_EFFECT_LABELS.get(key, key)), "%+d/月" % amt, tone, body_size, true))

func _make_governance_boost_note() -> Label:
    var note_lbl: = Label.new()
    note_lbl.text = "治理增益须装入治理增益栏位方会生效：城池加成直接抬升对应属性等级（受等级上限约束）；库银、官粮、兵勇、流民、人口等则按月增减。"
    note_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    note_lbl.add_theme_font_size_override("font_size", _sz(17, 18, 13))
    note_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    note_lbl.add_theme_constant_override("line_spacing", _sz(3, 3, 1))
    return note_lbl

func _make_personal_boost_note() -> Label:
    var note_lbl: = Label.new()
    note_lbl.text = "个人增益须装入个人增益栏位方会生效：仅提升文韬、武略、理政、体质，不影响城池属性与月度资源结算。"
    note_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    note_lbl.add_theme_font_size_override("font_size", _sz(17, 18, 13))
    note_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    note_lbl.add_theme_constant_override("line_spacing", _sz(3, 3, 1))
    return note_lbl

func _make_value_row(label_text: String, value_text: String, kind: String, font_size: int, strong: bool) -> HBoxContainer:
    var row: = HBoxContainer.new()
    var name_lbl: = Label.new()
    name_lbl.text = label_text
    name_lbl.add_theme_font_size_override("font_size", font_size)
    name_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_main") if strong else GameState.get_theme_color("text_desc"))
    row.add_child(name_lbl)

    var spacer: = Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    spacer.custom_minimum_size = Vector2(20, 0)
    row.add_child(spacer)

    var val_lbl: = Label.new()
    val_lbl.text = value_text
    val_lbl.add_theme_font_size_override("font_size", font_size)
    val_lbl.add_theme_color_override("font_color", _color(kind))
    row.add_child(val_lbl)
    return row

func _card_style() -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    var is_light: bool = GameState.theme == "light"
    style.bg_color = Color(1.0, 0.97, 0.9, 0.4) if is_light else Color(1, 1, 1, 0.022)
    style.border_color = Color(0.56, 0.4, 0.16, 0.3) if is_light else Color(0.72, 0.6, 0.36, 0.2)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.corner_radius_top_left = 8
    style.corner_radius_top_right = 8
    style.corner_radius_bottom_right = 8
    style.corner_radius_bottom_left = 8
    return style

func _color(kind: String) -> Color:
    match kind:
        "pos":
            return Color(0.3, 0.7, 0.3)
        "neg":
            return Presenter.negative_delta_color()
        "warn":
            return Color(0.66, 0.46, 0.1) if GameState.theme == "light" else Color(0.85, 0.7, 0.2)
        _:
            return GameState.get_theme_color("text_sub")

func _signed_kind(value: int, invert: bool = false) -> String:

    if value == 0:
        return "neutral"
    var good: bool = (value > 0) != invert
    return "pos" if good else "neg"

func _current_calendar_label() -> String:
    if _host.has_method("_format_cz_year_for_ui") and _host.has_method("_get_month_name"):
        var m_name: String = _host._get_month_name(int(GameState.month))
        if not GameData.SEASON_NAMES.is_empty():
            return "%s·%s" % [_host._format_cz_year_for_ui(int(GameState.year)), m_name]
        return "%s%s" % [_host._format_cz_year_for_ui(int(GameState.year)), m_name]
    return "崇祯%d年%d月" % [int(GameState.year), int(GameState.month)]



func _build_sections() -> Array:
    GameState.update_monthly_breakdowns()
    if GameData.active_line == "bianwu":
        return [
            _build_bianwu_liangcao_section(), 
            _build_bianwu_xiangyin_section(), 
            _build_bianwu_mapi_section(), 
            _build_bianwu_huoqi_section(), 
            _build_bianwu_zhanyi_section(), 
        ]
    return [
        _build_silver_section(), 
        _build_grain_section(), 
        _build_bingyong_section(), 
        _build_liumin_section(), 
        _build_renkou_section(), 
    ]

func _build_bianwu_liangcao_section() -> Dictionary:
    var rows: = []
    var net: = 0
    for item in GameState.monthly_grain_breakdown:
        var v: int = int(item.get("value", 0))
        net += v
        rows.append({"label": str(item.get("label", "")), "text": _fmt_signed(v), "kind": _signed_kind(v)})
    return {
        "key": "liangcao", 
        "label": "粮草", 
        "current": _host._format_large_number(int(GameState.city.get("liangcao", 0))), 
        "rows": rows, 
        "has_net": true, 
        "net_label": "本月预计", 
        "net_text": _fmt_signed(net), 
        "net_kind": _signed_kind(net), 
        "note": "粮草是军中口粮、马料与行军转运储备。后勤等级每月补入粮草；兵种升级、战斗与边务事件会消耗或补充。", 
    }

func _build_bianwu_xiangyin_section() -> Dictionary:
    var rows: = []
    var net: = 0
    for item in GameState.monthly_silver_breakdown:
        var v: int = int(item.get("value", 0))
        net += v
        rows.append({"label": str(item.get("label", "")), "text": _fmt_signed(v), "kind": _signed_kind(v)})
    return {
        "key": "xiangyin", 
        "label": "饷银", 
        "current": _host._format_large_number(int(GameState.city.get("xiangyin", 0))), 
        "rows": rows, 
        "has_net": true, 
        "net_label": "本月预计", 
        "net_text": _fmt_signed(net), 
        "net_kind": _signed_kind(net), 
        "note": "饷银用于发饷、采购军需与维持军务周转。后勤等级每月筹饷；边市、募兵、战斗和边务事件会改变饷银储备。", 
    }

func _bianwu_has_unit_tag(tag: String) -> bool:
    if not ("bianwu_units" in GameState):
        return false
    var BattleTypesRef = load("res://scripts/battle/battle_types.gd")
    for u in GameState.bianwu_units:
        if u is Dictionary:
            var uid: = str(u.get("id", ""))
            if BattleTypesRef.UNITS.has(uid) and BattleTypesRef.UNITS[uid].get("tags", []).has(tag):
                return true
    return false

func _build_bianwu_mapi_section() -> Dictionary:
    var mazheng_lv: int = GameState.get_city_stat_level("mazheng")
    var net: = (mazheng_lv * 10) if _bianwu_has_unit_tag("charge") else 0
    var rows: = []
    rows.append({"label": "马政整备", "text": _fmt_signed(net), "kind": _signed_kind(net)})
    return {
        "key": "mapi", 
        "label": "马匹", 
        "current": _host._format_large_number(int(GameState.city.get("mapi", 0))), 
        "rows": rows, 
        "has_net": true, 
        "net_label": "本月预计", 
        "net_text": _fmt_signed(net), 
        "net_kind": _signed_kind(net), 
        "note": "马匹决定边军机动与骑兵整备。马政等级每月补入马匹；骑兵相关兵种升级、边市买马、缴获与事件会增减马匹。", 
    }

func _build_bianwu_huoqi_section() -> Dictionary:
    var binggong_lv: int = GameState.get_city_stat_level("binggong")
    var net: = (binggong_lv * 12) if _bianwu_has_unit_tag("firearm") else 0
    var rows: = []
    rows.append({"label": "兵工铸造", "text": _fmt_signed(net), "kind": _signed_kind(net)})
    return {
        "key": "huoqi", 
        "label": "火器", 
        "current": _host._format_large_number(int(GameState.city.get("huoqi", 0))), 
        "rows": rows, 
        "has_net": true, 
        "net_label": "本月预计", 
        "net_text": _fmt_signed(net), 
        "net_kind": _signed_kind(net), 
        "note": "火器是火铳、炮械与火药器材的储备。兵工等级每月补入火器；火器兵种升级、铸造、采购、缴获与战斗奖励会增减火器。", 
    }

func _build_bianwu_zhanyi_section() -> Dictionary:
    return {
        "key": "zhanyi", 
        "label": "战意", 
        "current": _host._format_large_number(int(GameState.city.get("zhanyi", 0))), 
        "rows": [
            {"label": "兵种升级", "text": "核心消耗", "kind": "warn"}, 
            {"label": "主要来源", "text": "操练与战斗", "kind": "pos"}, 
        ], 
        "has_net": false, 
        "net_label": "", 
        "net_text": "", 
        "net_kind": "neutral", 
        "note": "战意来自日常操练和实战胜利，用于提升兵种等级。它不是地方线流民指标，也不参与流民暴动结算。", 
    }

func _build_silver_section() -> Dictionary:
    var rows: = []
    var net: = 0
    for item in GameState.monthly_silver_breakdown:
        var v: int = int(item.get("value", 0))
        net += v
        rows.append({"label": str(item.get("label", "")), "text": _fmt_signed(v), "kind": _signed_kind(v)})
    return {
        "key": "yinliang", 
        "label": "库银", 
        "current": _host._format_large_number(int(GameState.city.get("yinliang", 0))), 
        "rows": rows, 
        "has_net": true, 
        "net_label": "本月净增减", 
        "net_text": _fmt_signed(net), 
        "net_kind": _signed_kind(net), 
        "note": "库银用于发军饷、采办与各项政务开支。三饷（辽饷／剿饷／练饷）由朝廷摊派，逐月扣缴。入不敷出时政务难以为继，兵勇也可能因欠饷哗变。", 
    }

func _build_grain_section() -> Dictionary:
    var rows: = []
    var net: = 0
    for item in GameState.monthly_grain_breakdown:
        var v: int = int(item.get("value", 0))
        net += v
        rows.append({"label": str(item.get("label", "")), "text": _fmt_signed(v), "kind": _signed_kind(v)})
    var note: = "官粮用于养兵与赈济。仓廪空虚时，百姓会流散，进而出现饿殍，民望也逐月下降。"
    var tier: Dictionary = GameState.get_grain_shortage_tier()
    var tier_idx: int = int(tier.get("tier", 0))
    if tier_idx >= 1:
        var tier_note: = [
            "", 
            "【缺粮告急】官仓将尽，百姓已有流散之兆，每月民望 -1。", 
            "【缺粮】官仓见底，百姓断粮流散，开始出现饿殍，每月民望 -3。", 
            "【绝粮】粮食耗尽，饿殍遍地，每月民望 -5。", 
        ]
        note = tier_note[clampi(tier_idx, 1, 3)] + " " + note
    return {
        "key": "liangshi", 
        "label": "官粮", 
        "current": _host._format_large_number(int(GameState.city.get("liangshi", 0))), 
        "rows": rows, 
        "has_net": true, 
        "net_label": "本月净增减", 
        "net_text": _fmt_signed(net), 
        "net_kind": _signed_kind(net), 
        "note": note, 
    }

func _build_bingyong_section() -> Dictionary:
    var bingyong: int = int(GameState.city.get("bingyong", 0))
    var grain_cost: = bingyong
    var silver_cost: = int(bingyong * 0.5)
    var mutiny_info: Dictionary = GameState.get_mutiny_info()
    var mutiny_probability: float = float(mutiny_info.get("probability", 0.0))
    var mutiny_risk_loss: int = int(mutiny_info.get("deficit_loss", 0))
    var reinforcement: int = 50 if GameState.items.has("zhao_dao") else 0
    var net_change: int = reinforcement - mutiny_risk_loss

    var rows: = []
    rows.append({"label": "粮草消耗", "text": "%d/月" % grain_cost, "kind": "warn" if grain_cost > 0 else "neutral"})
    rows.append({"label": "军饷消耗", "text": "%d/月" % silver_cost, "kind": "warn" if silver_cost > 0 else "neutral"})
    if reinforcement > 0:
        rows.append({"label": "赵刀操练", "text": "+%d/月" % reinforcement, "kind": "pos"})
    rows.append({"label": "哗变风险", "text": ("%d%%" % int(round(mutiny_probability * 100))) if mutiny_risk_loss > 0 else "0%", "kind": "neg" if mutiny_risk_loss > 0 else "pos"})
    if mutiny_risk_loss > 0:
        rows.append({"label": "哗变减员", "text": "-%d/月" % mutiny_risk_loss, "kind": "neg"})

    return {
        "key": "bingyong", 
        "label": "兵勇", 
        "current": _host._format_large_number(bingyong), 
        "rows": rows, 
        "has_net": net_change != 0, 
        "net_label": "预计增减", 
        "net_text": _fmt_signed_monthly(net_change), 
        "net_kind": _signed_kind(net_change), 
        "note": "兵勇每月消耗粮饷。粮饷只要有一项不足就可能引发哗变，基础概率100%；理政或武略高于70可使概率减半（降至50%），两项都高于70则降至20%；但粮、银同时见底时，上述缓解全部失效，概率回到100%。兵勇数大于等于流民数10%时，则兵力充足，爆发流民哗变、起义时，可使损失减半。", 
    }

func _build_liumin_section() -> Dictionary:
    var riot_info: Dictionary = GameState.get_riot_info()
    var change: Dictionary = GameState.get_monthly_liumin_net_change()
    var base_growth: int = int(change.get("base_growth", 0))
    var grain_shortage_growth: int = int(change.get("grain_shortage_growth", 0))
    var settled: int = int(change.get("settled", 0))
    var ref_death: int = int(change.get("ref_death", 0))
    var net: int = int(change.get("net_change", 0))

    var rows: = []
    if base_growth != 0:
        rows.append({"label": "每月涌入", "text": "%+d/月" % base_growth, "kind": "neg" if base_growth > 0 else "pos"})
    if grain_shortage_growth > 0:
        rows.append({"label": "断粮流散", "text": "+%d/月" % grain_shortage_growth, "kind": "neg"})
    if settled > 0:
        rows.append({"label": "文教安民", "text": "-%d/月" % settled, "kind": "pos"})
    if ref_death > 0:
        rows.append({"label": "流民饿殍", "text": "-%d/月" % ref_death, "kind": "pos"})


    rows.append({"label": "流民占比", "text": "%.1f%%" % (float(riot_info.get("ratio", 0.0)) * 100.0), "kind": _ratio_kind(float(riot_info.get("ratio", 0.0)))})
    rows.append({"label": "暴动等级", "text": str(riot_info.get("label", "安全")), "kind": _riot_level_kind(int(riot_info.get("level", 0)))})
    var prob_text: String
    var prob_kind: String
    if bool(riot_info.get("cooldown", false)):
        prob_text = "冷却中"
        prob_kind = "neutral"
    else:
        var prob: float = float(riot_info.get("probability", 0.0))
        prob_text = "%.0f%%" % (prob * 100.0)
        prob_kind = "neg" if prob >= 0.2 else ("warn" if prob > 0 else "pos")
    rows.append({"label": "月触发概率", "text": prob_text, "kind": prob_kind})

    return {
        "key": "liumin", 
        "label": "流民", 
        "current": _host._format_large_number(int(GameState.city.get("liumin", 0))), 
        "rows": rows, 
        "has_net": (base_growth != 0 or settled > 0 or ref_death > 0 or grain_shortage_growth > 0), 
        "net_label": "本月净增减", 
        "net_text": _fmt_signed_monthly(net), 
        "net_kind": _signed_kind(net, true), 
        "note": "流民聚集容易引发暴动。兴办文教可逐月安置流民入籍；理政与城防越高，暴动之患越轻。官粮短缺时，百姓流散会更严重。", 
    }

func _build_renkou_section() -> Dictionary:
    var change: Dictionary = GameState.get_monthly_renkou_net_change()
    var natural_growth: int = int(change.get("natural_growth", 0))
    var settled: int = int(change.get("settled", 0))
    var to_refugee: int = int(change.get("to_refugee", 0))
    var pop_death: int = int(change.get("pop_death", 0))
    var net: int = int(change.get("net_change", 0))

    var rows: = []
    rows.append({"label": "休养生息", "text": "%+d/月" % natural_growth, "kind": _signed_kind(natural_growth)})
    if settled > 0:
        rows.append({"label": "文教安民入籍", "text": "+%d/月" % settled, "kind": "pos"})
    if to_refugee > 0:
        rows.append({"label": "断粮流散", "text": "-%d/月" % to_refugee, "kind": "neg"})
    if pop_death > 0:
        rows.append({"label": "人口饿殍", "text": "-%d/月" % pop_death, "kind": "neg"})

    var note: = "在籍人口是赋税与徭役的根本，逐月休养生息会自然增长。官粮不继时，百姓流散、饿殍相继，户口随之凋零。"
    var tier: int = int(change.get("tier", 0))
    if tier >= 1:
        note = "当前缺粮%s，百姓流散、饿殍日增，亟须补粮止损。 " % str(change.get("tier_label", "")) + note

    return {
        "key": "renkou_val", 
        "label": "人口", 
        "current": _host._format_large_number(int(GameState.city.get("renkou_val", 0))), 
        "rows": rows, 
        "has_net": true, 
        "net_label": "本月净增减", 
        "net_text": _fmt_signed_monthly(net), 
        "net_kind": _signed_kind(net), 
        "note": note, 
    }

func _ratio_kind(r: float) -> String:
    if r >= 0.5:
        return "neg"
    elif r >= 0.15:
        return "warn"
    return "pos"

func _riot_level_kind(lv: int) -> String:
    if lv >= 2:
        return "neg"
    elif lv == 1:
        return "warn"
    return "pos"

func _fmt_signed(v: int) -> String:
    if v > 0:
        return "+%d" % v
    elif v < 0:
        return str(v)
    return "0"

func _fmt_signed_monthly(v: int) -> String:
    return "%+d/月" % v
