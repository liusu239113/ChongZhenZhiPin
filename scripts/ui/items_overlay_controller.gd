extends RefCounted
class_name ItemsOverlayController




const Presenter = preload("res://scripts/ui/game_screen_presenter.gd")
const ScrollbarThemeRef = preload("res://scripts/ui/scrollbar_theme.gd")
const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const FontLoader = preload("res://scripts/ui/font_loader.gd")
const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")
const ItemDetailBuilderRef = preload("res://scripts/ui/item_detail_builder.gd")

var _host

func _init(host) -> void :
    _host = host


func update_items_expand_button() -> void :
    if not is_instance_valid(_host.items_title):
        return
    if _host.items_expand_btn == null or not is_instance_valid(_host.items_expand_btn):
        create_items_expand_button()



    var landscape: bool = not _host._is_mobile_portrait()
    if is_instance_valid(_host.items_expand_btn):
        _host.items_expand_btn.visible = landscape
    var row: Node = _host.items_title.get_parent()
    if row is HBoxContainer:
        row.alignment = BoxContainer.ALIGNMENT_CENTER if landscape else BoxContainer.ALIGNMENT_BEGIN




func create_items_expand_button() -> void :
    var section = _host.items_title.get_parent()
    if section == null:
        return
    var title_row: = HBoxContainer.new()
    title_row.name = "ItemsTitleRow"
    title_row.alignment = BoxContainer.ALIGNMENT_CENTER
    title_row.add_theme_constant_override("separation", 6)
    var title_index: int = _host.items_title.get_index()
    section.add_child(title_row)
    section.move_child(title_row, title_index)

    _host.items_title.reparent(title_row)

    _host.items_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

    _host.items_expand_btn = Button.new()
    _host.items_expand_btn.name = "ItemsExpandButton"
    _host.items_expand_btn.focus_mode = Control.FOCUS_NONE
    _host.items_expand_btn.text = "⧉"
    _host.items_expand_btn.tooltip_text = "展开随身物品"
    _host.items_expand_btn.custom_minimum_size = Vector2(26, 26)
    _host.items_expand_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    _host.items_expand_btn.add_theme_font_size_override("font_size", 18)
    _host.items_expand_btn.add_theme_color_override("font_color", Color(0.92, 0.76, 0.2))
    _host.items_expand_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.85, 0.3))
    _host.items_expand_btn.add_theme_color_override("font_pressed_color", Color(1.0, 0.9, 0.4))

    var btn_style: = StyleBoxEmpty.new()
    btn_style.set_content_margin(SIDE_TOP, 4)
    _host.items_expand_btn.add_theme_stylebox_override("normal", btn_style)
    _host.items_expand_btn.add_theme_stylebox_override("hover", btn_style)
    _host.items_expand_btn.add_theme_stylebox_override("pressed", btn_style)
    _host.items_expand_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    _host.items_expand_btn.pressed.connect(show_items_overlay)
    title_row.add_child(_host.items_expand_btn)


func show_items_overlay(selection_callback: Callable = Callable(), preselect_item_id: String = "", selection_type: String = "") -> void :
    if _host._is_mobile_portrait():
        return
    close_items_overlay()
    _host.items_overlay_selection_callback = selection_callback
    _host.items_overlay_selection_type = selection_type

    _host.items_overlay_selected_id = preselect_item_id
    _host.items_overlay_preselect_id = preselect_item_id
    if selection_callback.is_valid() and selection_type in ["personal", "governance"]:
        _host.items_overlay_category = selection_type
    elif preselect_item_id != "":
        _host.items_overlay_category = _category_for_item(preselect_item_id)
    _host.items_overlay_replace_btn = null

    var viewport_size: Vector2 = _host.get_viewport_rect().size
    _host.items_overlay_layer = CanvasLayer.new()
    _host.items_overlay_layer.name = "ItemsExpandedOverlay"
    _host.items_overlay_layer.layer = 110
    _host.get_tree().root.add_child(_host.items_overlay_layer)


    var dim: = ColorRect.new()
    dim.color = Color(0, 0, 0, 0.55)
    dim.set_anchors_preset(Control.PRESET_FULL_RECT)
    dim.mouse_filter = Control.MOUSE_FILTER_STOP
    dim.gui_input.connect( func(event: InputEvent):
        if Presenter._is_primary_press_event(event):
            close_items_overlay()
    )
    _host.items_overlay_layer.add_child(dim)


    var panel: = PanelContainer.new()
    panel.add_theme_stylebox_override("panel", make_items_overlay_panel_style())
    var panel_w: = clampf(viewport_size.x * 0.84, 680.0, 1320.0)
    var panel_h: = clampf(viewport_size.y * 0.78, 360.0, 820.0)
    panel.custom_minimum_size = Vector2(panel_w, panel_h)
    panel.size = Vector2(panel_w, panel_h)
    panel.position = ((viewport_size - panel.size) * 0.5).floor()
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    _host.items_overlay_layer.add_child(panel)

    var margin: = MarginContainer.new()
    for side in ["left", "right", "top", "bottom"]:
        margin.add_theme_constant_override("margin_" + side, 22)
    panel.add_child(margin)

    var root_vbox: = VBoxContainer.new()
    root_vbox.add_theme_constant_override("separation", 14)
    margin.add_child(root_vbox)
    _host.items_overlay_content = root_vbox


    var header: = HBoxContainer.new()
    root_vbox.add_child(header)
    var title: = Label.new()
    title.text = "随身物品"
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title.add_theme_font_override("font", FontLoader.title())
    title.add_theme_font_size_override("font_size", 22)
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    header.add_child(title)
    var close_btn: = Button.new()
    close_btn.text = "返回"
    close_btn.icon = load("res://assets/ui/back.svg")
    close_btn.expand_icon = false
    close_btn.focus_mode = Control.FOCUS_NONE
    close_btn.custom_minimum_size = Vector2(128, 42)
    close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    close_btn.add_theme_font_size_override("font_size", 16)
    close_btn.add_theme_constant_override("icon_max_width", 16)
    close_btn.add_theme_constant_override("h_separation", 6)
    close_btn.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    close_btn.add_theme_color_override("font_hover_color", GameState.get_theme_color("border_active"))
    close_btn.add_theme_stylebox_override("normal", GameScreenStyleFactory.modal_return_button_style("normal"))
    close_btn.add_theme_stylebox_override("hover", GameScreenStyleFactory.modal_return_button_style("hover"))
    close_btn.add_theme_stylebox_override("pressed", GameScreenStyleFactory.modal_return_button_style("pressed"))
    close_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    close_btn.pressed.connect(close_items_overlay)
    header.add_child(close_btn)


    _host.items_overlay_tabs = HBoxContainer.new()
    _host.items_overlay_tabs.add_theme_constant_override("separation", 6)
    root_vbox.add_child(_host.items_overlay_tabs)


    var body_split: = HBoxContainer.new()
    body_split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
    body_split.add_theme_constant_override("separation", 16)
    root_vbox.add_child(body_split)


    var scroll: = ScrollContainer.new()
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    body_split.add_child(scroll)

    ScrollbarThemeRef.apply_to(scroll)


    var grid_margin: = MarginContainer.new()
    grid_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    grid_margin.add_theme_constant_override("margin_right", 18)
    scroll.add_child(grid_margin)

    _host.items_overlay_grid = VBoxContainer.new()
    _host.items_overlay_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _host.items_overlay_grid.add_theme_constant_override("separation", 10)
    grid_margin.add_child(_host.items_overlay_grid)


    var detail_panel: = PanelContainer.new()
    detail_panel.add_theme_stylebox_override("panel", make_items_overlay_detail_style())
    detail_panel.custom_minimum_size = Vector2(clampf(panel_w * 0.26, 220.0, 320.0), 0)
    detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    body_split.add_child(detail_panel)

    var detail_scroll: = ScrollContainer.new()
    detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    detail_panel.add_child(detail_scroll)
    ScrollbarThemeRef.apply_to(detail_scroll)

    var detail_margin: = MarginContainer.new()
    detail_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    for side in ["left", "right", "top", "bottom"]:
        detail_margin.add_theme_constant_override("margin_" + side, 14)
    detail_scroll.add_child(detail_margin)

    _host.items_overlay_detail = VBoxContainer.new()
    _host.items_overlay_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _host.items_overlay_detail.add_theme_constant_override("separation", 8)
    detail_margin.add_child(_host.items_overlay_detail)


    if selection_callback.is_valid():
        var footer: = HBoxContainer.new()
        footer.alignment = BoxContainer.ALIGNMENT_END
        footer.add_theme_constant_override("separation", 10)
        root_vbox.add_child(footer)
        var hint: = Label.new()
        hint.text = "勾选一件随身物品后替换到增益槽"
        hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        hint.add_theme_font_size_override("font_size", 13)
        hint.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        footer.add_child(hint)
        if _host.items_overlay_preselect_id != "":
            var unequip_btn: = Button.new()
            unequip_btn.text = "卸下"
            unequip_btn.focus_mode = Control.FOCUS_NONE
            unequip_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
            unequip_btn.custom_minimum_size = Vector2(96, 36)
            unequip_btn.add_theme_font_size_override("font_size", 15)
            GameScreenStyleFactory.apply_command_button_style(unequip_btn, "secondary", 14, 6)
            unequip_btn.pressed.connect(_on_items_overlay_unequip_pressed)
            footer.add_child(unequip_btn)
        var replace_btn: = Button.new()
        replace_btn.text = "替换"
        replace_btn.focus_mode = Control.FOCUS_NONE
        replace_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
        replace_btn.custom_minimum_size = Vector2(96, 36)
        replace_btn.add_theme_font_size_override("font_size", 15)
        GameScreenStyleFactory.apply_command_button_style(replace_btn, "primary", 14, 6)
        replace_btn.pressed.connect(_on_items_overlay_replace_pressed)
        footer.add_child(replace_btn)
        _host.items_overlay_replace_btn = replace_btn

    rebuild_items_overlay_tabs()
    populate_items_overlay_grid()
    apply_items_overlay_font_scale()


    if preselect_item_id != "":
        _scroll_overlay_to_selected()


func _category_for_item(item_id: String) -> String:
    const CITY_RESOURCE_KEYS: = ["yinliang", "liangshi", "bingyong", "liumin", "renkou_val"]
    for item in _host._build_display_items():
        if str(item.get("id", "")) != item_id:
            continue
        if bool(item.get("multi", false)):
            return "multi"
        for key in GameData.CITY_STAT_KEYS:
            if item.get("categories", []).has(str(key)):
                return str(key)
        for key in CITY_RESOURCE_KEYS:
            if item.get("categories", []).has(key):
                return key
        break
    return "all"


func _find_overlay_card(item_id: String) -> Control:
    if not is_instance_valid(_host.items_overlay_grid):
        return null
    for row in _host.items_overlay_grid.get_children():
        for card in row.get_children():
            if card is Control and card.has_meta("item_id") and str(card.get_meta("item_id")) == item_id:
                return card
    return null


func _scroll_overlay_to_selected() -> void :
    if _host.items_overlay_selected_id == "":
        return
    await _host.get_tree().process_frame
    await _host.get_tree().process_frame
    var target: = _find_overlay_card(_host.items_overlay_selected_id)
    if target == null or not is_instance_valid(target):
        return
    if not is_instance_valid(_host.items_overlay_grid):
        return
    var scroll: = _host.items_overlay_grid.get_parent().get_parent() as ScrollContainer
    if scroll != null and is_instance_valid(scroll):
        scroll.ensure_control_visible(target)


func close_items_overlay() -> void :
    if _host.items_overlay_layer != null and is_instance_valid(_host.items_overlay_layer):
        _host.items_overlay_layer.queue_free()
    _host.items_overlay_layer = null
    _host.items_overlay_content = null
    _host.items_overlay_grid = null
    _host.items_overlay_tabs = null
    _host.items_overlay_selection_callback = Callable()
    _host.items_overlay_selection_type = ""
    _host.items_overlay_selected_id = ""
    _host.items_overlay_preselect_id = ""
    _host.items_overlay_view_id = ""
    _host.items_overlay_detail = null
    _host.items_overlay_replace_btn = null




func apply_items_overlay_font_scale() -> void :
    if _host.items_overlay_content != null and is_instance_valid(_host.items_overlay_content):
        NativeMobileFontScalerRef.apply_to(_host.items_overlay_content)


func rebuild_items_overlay_tabs() -> void :
    if not is_instance_valid(_host.items_overlay_tabs):
        return
    for child in _host.items_overlay_tabs.get_children():
        child.queue_free()

    var all_items: Array = _host._build_display_items()
    var has_multi: = false
    var present_domains: = {}
    for item in all_items:
        if bool(item.get("multi", false)):
            has_multi = true
        for key in item.get("categories", []):
            present_domains[str(key)] = true



    var selection_mode: bool = _host.items_overlay_selection_callback.is_valid()
    var tab_defs: Array = []
    if selection_mode:
        tab_defs = [
            {"key": "governance", "label": "治理增益"}, 
            {"key": "personal", "label": "个人增益"}, 
        ]
    else:

        tab_defs.append({"key": "all", "label": "全部"})

    if not selection_mode and has_multi:
        tab_defs.append({"key": "multi", "label": "全能"})
    for key in GameData.CITY_STAT_KEYS if not selection_mode else []:
        if present_domains.has(str(key)):
            tab_defs.append({"key": str(key), "label": GameData.city_stat_effect_label(key)})
    const CITY_RESOURCE_KEYS: = ["yinliang", "liangshi", "bingyong", "liumin", "renkou_val"]
    for key in CITY_RESOURCE_KEYS if not selection_mode else []:
        if present_domains.has(key):
            tab_defs.append({"key": key, "label": GameData.city_stat_effect_label(key)})

    if not selection_mode:
        for key in _host.PERSONAL_STAT_KEYS:
            if present_domains.has(str(key)):
                tab_defs.append({"key": str(key), "label": _host.PERSONAL_STAT_LABELS.get(key, str(key))})


    var valid_keys: = {}
    for d in tab_defs:
        valid_keys[d["key"]] = true
    if not valid_keys.has(_host.items_overlay_category):
        _host.items_overlay_category = str(tab_defs[0]["key"]) if not tab_defs.is_empty() else "all"

    for d in tab_defs:
        var btn: = Button.new()
        btn.text = d["label"]
        btn.focus_mode = Control.FOCUS_NONE
        btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
        btn.add_theme_font_size_override("font_size", 13)
        var cat_key: String = d["key"]
        var active: bool = cat_key == _host.items_overlay_category
        btn.set_meta("cat_key", cat_key)
        btn.add_theme_color_override("font_color", _items_overlay_tab_text_color(active))
        btn.add_theme_color_override("font_hover_color", GameState.get_theme_color("border_stronger"))
        btn.add_theme_stylebox_override("normal", make_items_overlay_tab_style(active))
        btn.add_theme_stylebox_override("hover", make_items_overlay_tab_style(true))
        btn.add_theme_stylebox_override("pressed", make_items_overlay_tab_style(true))



        btn.pressed.connect( func():
            if _host.items_overlay_category == cat_key:
                return
            _host.items_overlay_category = cat_key
            _refresh_items_overlay_tab_styles()
            populate_items_overlay_grid()
            apply_items_overlay_font_scale()
        )
        _host.items_overlay_tabs.add_child(btn)


func _refresh_items_overlay_tab_styles() -> void :
    if not is_instance_valid(_host.items_overlay_tabs):
        return
    for btn in _host.items_overlay_tabs.get_children():
        if not (btn is Button) or not btn.has_meta("cat_key"):
            continue
        var active: bool = str(btn.get_meta("cat_key")) == _host.items_overlay_category
        btn.add_theme_color_override("font_color", _items_overlay_tab_text_color(active))
        btn.add_theme_stylebox_override("normal", make_items_overlay_tab_style(active))


func populate_items_overlay_grid() -> void :
    if not is_instance_valid(_host.items_overlay_grid):
        return
    var all_items: Array = _host._build_display_items()
    var filtered: Array = []
    for item in all_items:
        var item_id: = str(item.get("id", ""))
        if _host.items_overlay_category == "personal":
            if GameState._item_is_personal_boost_eligible(item_id):
                filtered.append(item)
        elif _host.items_overlay_category == "governance":
            if GameState._item_is_boost_eligible(item_id):
                filtered.append(item)
        elif _host.items_overlay_category == "all":
            filtered.append(item)
        elif _host.items_overlay_category == "multi":
            if bool(item.get("multi", false)):
                filtered.append(item)
        else:
            if item.get("categories", []).has(_host.items_overlay_category):
                filtered.append(item)

    _sort_items_by_effect(filtered)

    var selection_mode: bool = _host.items_overlay_selection_callback.is_valid()

    if not selection_mode:

        var view_found: = false
        if _host.items_overlay_view_id != "":
            for item in filtered:
                if str(item.get("id", "")) == _host.items_overlay_view_id:
                    view_found = true
                    break
        if not view_found and not filtered.is_empty():
            _host.items_overlay_view_id = str(filtered[0].get("id", ""))

    var pick_callback: = Callable()
    var view_callback: = Callable()
    if selection_mode:
        pick_callback = Callable(self, "_on_items_overlay_item_picked")
    else:

        view_callback = Callable(self, "_on_items_overlay_item_viewed")


    var occupied_ids: = {}
    if selection_mode:
        var slots: Array = []
        if _host.items_overlay_selection_type == "personal":
            GameState.normalize_personal_boost_item_slots()
            slots = GameState.personal_boost_item_slots
        else:
            GameState.normalize_city_boost_item_slots()
            slots = GameState.city_boost_item_slots
        for sid in slots:
            var sid_str: = str(sid)
            if sid_str != "" and sid_str != _host.items_overlay_preselect_id:
                occupied_ids[sid_str] = true
    Presenter.populate_items_columns(_host.items_overlay_grid, filtered, 3, false, "此分类暂无物件", pick_callback, selection_mode, _host.items_overlay_selected_id, view_callback, _host.items_overlay_view_id, true, occupied_ids, _host.items_overlay_selection_type)
    _update_items_overlay_replace_btn()
    populate_items_overlay_detail()



func _item_effect_sort_value(item: Dictionary) -> int:
    const CITY_RESOURCE_KEYS: = ["yinliang", "liangshi", "bingyong", "liumin", "renkou_val"]
    var item_id: = str(item.get("id", ""))
    var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
    var city_effects: Dictionary = item_def.get("cityEffects", {})
    var status_effects: Dictionary = item_def.get("statusEffects", {})
    var cat: String = str(_host.items_overlay_category)
    if GameData.CITY_STAT_KEYS.has(cat):
        return int(city_effects.get(cat, 0))
    if CITY_RESOURCE_KEYS.has(cat):
        return abs(int(status_effects.get(cat, 0)))
    var best: = 0
    for raw_key in city_effects:
        var key: = str(raw_key)
        if GameData.CITY_STAT_KEYS.has(key):
            best = maxi(best, int(city_effects[raw_key]))
    for raw_key in status_effects:
        var key: = str(raw_key)
        if CITY_RESOURCE_KEYS.has(key):
            best = maxi(best, abs(int(status_effects[raw_key])))
    return best


func _sort_items_by_effect(items: Array) -> void :
    var indexed: Array = []
    for i in range(items.size()):
        indexed.append({"item": items[i], "value": _item_effect_sort_value(items[i]), "order": i})
    indexed.sort_custom( func(a, b):
        if a["value"] != b["value"]:
            return a["value"] > b["value"]
        return a["order"] < b["order"]
    )
    items.clear()
    for entry in indexed:
        items.append(entry["item"])


func _on_items_overlay_item_picked(item_id: String) -> void :

    if _host.items_overlay_selected_id == item_id:
        _host.items_overlay_selected_id = ""
    else:
        _host.items_overlay_selected_id = item_id
    populate_items_overlay_grid()
    apply_items_overlay_font_scale()


func _on_items_overlay_item_viewed(item_id: String) -> void :
    if _host.items_overlay_view_id != item_id:
        _host.items_overlay_view_id = item_id
        populate_items_overlay_grid()
        apply_items_overlay_font_scale()


func _items_overlay_active_id() -> String:
    if _host.items_overlay_selection_callback.is_valid():
        return _host.items_overlay_selected_id
    return _host.items_overlay_view_id


func populate_items_overlay_detail() -> void :
    if not is_instance_valid(_host.items_overlay_detail):
        return
    for child in _host.items_overlay_detail.get_children():
        child.queue_free()

    var active_id: = _items_overlay_active_id()
    var detail: = ItemDetailBuilderRef.build(active_id)


    var empty_text: = ""
    if active_id == "":
        empty_text = "点选左侧随身物品\n查看其效果"
    elif detail.is_empty():
        empty_text = "未找到物件详情"
    if empty_text != "":
        var empty: = Label.new()
        empty.text = empty_text
        empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        empty.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        empty.size_flags_vertical = Control.SIZE_EXPAND_FILL
        empty.add_theme_font_size_override("font_size", 14)
        empty.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        _host.items_overlay_detail.add_child(empty)
        return

    var name_label: = Label.new()
    name_label.text = str(detail.get("name", "无名物件"))
    name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    name_label.add_theme_font_override("font", FontLoader.title())
    name_label.add_theme_font_size_override("font_size", 17)
    name_label.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    _host.items_overlay_detail.add_child(name_label)

    var source_label: = Label.new()
    source_label.text = "得自 " + str(detail.get("source", "随身旧物"))
    source_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    source_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    source_label.add_theme_font_size_override("font_size", 11)
    source_label.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    _host.items_overlay_detail.add_child(source_label)

    _append_detail_paragraph(str(detail.get("body", "")), "text_desc", 13)
    var effect: = str(detail.get("effect", ""))
    if effect != "":
        _append_detail_heading("效果")
        _append_detail_paragraph(effect, "border_active", 13)
    _append_detail_paragraph(str(detail.get("note", "")), "text_sub", 12)


func _append_detail_heading(text: String) -> void :
    var spacer: = Control.new()
    spacer.custom_minimum_size = Vector2(0, 4)
    _host.items_overlay_detail.add_child(spacer)
    var label: = Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", 12)
    label.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    _host.items_overlay_detail.add_child(label)


func _append_detail_paragraph(text: String, color_key: String, font_size: int) -> void :
    if text == "":
        return
    var label: = Label.new()
    label.text = text
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", GameState.get_theme_color(color_key))
    _host.items_overlay_detail.add_child(label)

func make_items_overlay_detail_style() -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0.02, 0.018, 0.014, 0.34) if GameState.theme == "dark" else Color(1.0, 0.97, 0.88, 0.36)
    style.border_color = Color(0.72, 0.6, 0.34, 0.24) if GameState.theme == "dark" else Color(0.54, 0.4, 0.18, 0.24)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.corner_radius_top_left = 6
    style.corner_radius_top_right = 6
    style.corner_radius_bottom_right = 6
    style.corner_radius_bottom_left = 6
    return style


func _on_items_overlay_replace_pressed() -> void :
    if _host.items_overlay_selected_id == "":
        return
    if _host.items_overlay_selection_callback.is_valid():
        _host.items_overlay_selection_callback.call(_host.items_overlay_selected_id)


func _on_items_overlay_unequip_pressed() -> void :
    if _host.items_overlay_selection_callback.is_valid():
        _host.items_overlay_selection_callback.call("")


func _update_items_overlay_replace_btn() -> void :
    if _host.items_overlay_replace_btn != null and is_instance_valid(_host.items_overlay_replace_btn):
        _host.items_overlay_replace_btn.disabled = _host.items_overlay_selected_id == "" or (_host.items_overlay_selection_type != "" and _host.items_overlay_category != _host.items_overlay_selection_type)

func make_items_overlay_panel_style() -> StyleBoxFlat:
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

func make_items_overlay_tab_style(active: bool) -> StyleBoxFlat:
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
    style.content_margin_left = 14
    style.content_margin_right = 14
    style.content_margin_top = 6
    style.content_margin_bottom = 7
    style.corner_radius_top_left = 12
    style.corner_radius_top_right = 12
    style.corner_radius_bottom_right = 12
    style.corner_radius_bottom_left = 12
    return style

func _items_overlay_tab_text_color(active: bool) -> Color:
    if not active:
        return GameState.get_theme_color("text_sub")
    if GameState.theme == "dark":
        return GameState.get_theme_color("border_active")
    return Color(0.4, 0.27, 0.08, 1.0)
