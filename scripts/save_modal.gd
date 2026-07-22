extends Control

const ScrollbarThemeRef = preload("res://scripts/ui/scrollbar_theme.gd")
const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const AndroidRewardAdServiceRef = preload("res://scripts/services/android_reward_ad_service.gd")
const NativeMobileTouchScrollRef = preload("res://scripts/ui/native_mobile_touch_scroll.gd")
const FontLoader = preload("res://scripts/ui/font_loader.gd")
const RouteRegistryRef = preload("res://scripts/route_registry.gd")
const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")

const MOBILE_PORTRAIT_MAX_WIDTH: = 900.0
const MOBILE_PANEL_WIDTH_RATIO: = 0.96
const MOBILE_PANEL_HEIGHT_RATIO: = 0.85
const MOBILE_TITLE_FONT_SIZE: = 53
const MOBILE_SLOT_LABEL_FONT_SIZE: = 41
const MOBILE_SLOT_INFO_FONT_SIZE: = 36
const MOBILE_ACTION_FONT_SIZE: = 36
const MOBILE_CLOSE_FONT_SIZE: = 41
const MOBILE_SLOT_ROW_HEIGHT: = 136.0
const PC_SLOT_ROW_HEIGHT: = 64.0
const MOBILE_ACTION_BUTTON_HEIGHT: = 76.0
const MOBILE_CLOSE_BUTTON_HEIGHT: = 88.0
const TOP_MODAL_Z_INDEX: = 1000

@onready var panel: PanelContainer = $Panel
@onready var vbox: VBoxContainer = $Panel / VBox
@onready var header_box: HBoxContainer = $Panel / VBox / Header
@onready var title_label = $Panel / VBox / Header / TitleLabel
@onready var slots_scroll: ScrollContainer = $Panel / VBox / SlotsScroll
@onready var slots_container = $Panel / VBox / SlotsScroll / SlotsMargin / SlotsVBox
@onready var close_btn = $Panel / VBox / Header / CloseButton

var mode: String = "save"
var _panel_margin_left: float = 24.0
var _panel_margin_right: float = 24.0
var _panel_margin_top: float = 24.0
var _panel_margin_bottom: float = 24.0


var grouped_load: bool = false
var reward_status_text: String = ""

var selected_bucket: String = ""
var tab_bar: HBoxContainer = null
var scroll_touch_drag_suppress_until_ms: int = 0



var _toast_controller = null

func _ready() -> void :
    call_deferred("_raise_to_top_modal_layer")
    mouse_filter = Control.MOUSE_FILTER_STOP
    $Overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    close_btn.text = "返回"
    close_btn.icon = load("res://assets/ui/back.svg")
    close_btn.expand_icon = false
    close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    close_btn.add_theme_constant_override("h_separation", 6)
    close_btn.pressed.connect( func(): visible = false)
    $Overlay.gui_input.connect( func(event: InputEvent):
        if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or (event is InputEventScreenTouch and event.pressed):
            set_deferred("visible", false)
    )
    visible = false
    visibility_changed.connect( func(): if visible: _apply_theme())
    resized.connect(_apply_responsive_layout)
    if has_node("/root/AndroidRewardAdService"):
        AndroidRewardAdService.reward_granted.connect(_on_reward_granted)
        AndroidRewardAdService.reward_failed.connect(_on_reward_failed)
        AndroidRewardAdService.reward_unavailable.connect(_on_reward_unavailable)

func _raise_to_top_modal_layer() -> void :
    z_as_relative = false
    z_index = TOP_MODAL_Z_INDEX
    move_to_front()

func _apply_theme() -> void :
    _apply_responsive_layout()
    title_label.add_theme_font_override("font", FontLoader.title())
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    title_label.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    if GameState.theme == "light":
        $Overlay.color = Color(0.0, 0.0, 0.0, 0.36)
    else:
        $Overlay.color = Color(0, 0, 0, 0.66)

    close_btn.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    close_btn.add_theme_color_override("font_hover_color", GameState.get_theme_color("border_active"))
    close_btn.add_theme_color_override("font_pressed_color", GameState.get_theme_color("border_active"))
    close_btn.add_theme_color_override("font_focus_color", GameState.get_theme_color("text_sub"))

    close_btn.add_theme_stylebox_override("normal", GameScreenStyleFactory.modal_return_button_style("normal"))
    close_btn.add_theme_stylebox_override("hover", GameScreenStyleFactory.modal_return_button_style("hover"))
    close_btn.add_theme_stylebox_override("pressed", GameScreenStyleFactory.modal_return_button_style("pressed"))
    close_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    $Panel.add_theme_stylebox_override("panel", _panel_style())
    ScrollbarThemeRef.apply_to(slots_scroll)

func _get_responsive_window_size() -> Vector2:
    var viewport_size: = get_viewport_rect().size
    var window_size: = Vector2(DisplayServer.window_get_size())

    if OS.has_feature("web"):
        var browser_json: = str(JavaScriptBridge.eval("JSON.stringify({ w: window.innerWidth, h: window.innerHeight })"))
        var parsed = JSON.parse_string(browser_json)
        if parsed is Dictionary:
            var width: = float(parsed.get("w", 0.0))
            var height: = float(parsed.get("h", 0.0))
            if width > 0.0 and height > 0.0:
                return Vector2(width, height)

    if window_size.x > 0.0 and window_size.y > 0.0:
        return window_size
    return viewport_size

func _is_mobile_portrait() -> bool:
    return false
func _apply_responsive_layout() -> void :
    var viewport_size: = get_viewport_rect().size
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
        return


    panel.set_anchors_preset(Control.PRESET_FULL_RECT)
    panel.offset_left = 0
    panel.offset_right = 0
    panel.offset_top = 0
    panel.offset_bottom = 0

    if _is_mobile_portrait():
        _panel_margin_left = 24.0
        _panel_margin_right = 24.0
        _panel_margin_top = 48.0
        _panel_margin_bottom = 40.0

        vbox.add_theme_constant_override("separation", 24)
        title_label.add_theme_font_size_override("font_size", MOBILE_TITLE_FONT_SIZE)
        slots_container.add_theme_constant_override("separation", 14)
        close_btn.custom_minimum_size = Vector2(200.0, 80.0)
        close_btn.add_theme_font_size_override("font_size", 36)
        close_btn.add_theme_constant_override("icon_max_width", 36)
    else:

        var target_w = clampf(viewport_size.x * 0.9, 800.0, 1100.0)
        if target_w > viewport_size.x * 0.98:
            target_w = viewport_size.x * 0.98
        var margin_x = (viewport_size.x - target_w) * 0.5

        _panel_margin_left = margin_x
        _panel_margin_right = margin_x
        _panel_margin_top = 36.0
        _panel_margin_bottom = 30.0

        vbox.add_theme_constant_override("separation", 20)
        title_label.add_theme_font_size_override("font_size", 26)
        slots_container.add_theme_constant_override("separation", 10)
        close_btn.custom_minimum_size = Vector2(128.0, 42.0)
        close_btn.add_theme_font_size_override("font_size", 16)
        close_btn.add_theme_constant_override("icon_max_width", 16)
    _apply_native_mobile_font_scale()

func open_save_mode() -> void :
    mode = "save"
    grouped_load = false
    reward_status_text = ""
    title_label.text = "存 档"
    _build_slots()
    _raise_to_top_modal_layer()
    visible = true
    _apply_native_mobile_font_scale()

func open_load_mode(grouped: bool = false) -> void :
    mode = "load"
    grouped_load = grouped
    reward_status_text = ""
    selected_bucket = ""
    title_label.text = "读 档"
    _build_slots()
    _raise_to_top_modal_layer()
    visible = true
    _apply_native_mobile_font_scale()

func _build_slots() -> void :
    for child in slots_container.get_children():
        child.queue_free()

    if mode == "load" and grouped_load:
        _build_grouped_load_slots()
        _apply_native_mobile_font_scale()
        return

    _set_tab_bar_visible(false)
    _build_autosave_slot()

    for i in range(SaveManager.get_available_manual_slots()):
        var info = SaveManager.get_slot_info(i)
        var slot_idx = i
        var slot_text = "存档 " + str(i + 1)
        var rename_cb: = Callable()
        var delete_cb: = Callable()
        if not info.is_empty():
            rename_cb = func(): _show_rename_dialog(str(info.get("custom_name", "")), func(nm: String):
                if SaveManager.set_custom_name(slot_idx, nm):
                    _build_slots())
            delete_cb = func(): _show_delete_confirm(slot_text, info, func():
                SaveManager.delete_save(slot_idx)
                _build_slots())
        if mode == "save":
            _add_slot_row(slot_text, info, "保存", false, func(): _do_save(slot_idx), rename_cb, delete_cb)
        else:
            _add_slot_row(slot_text, info, "读取", info.is_empty(), func(): _do_load(slot_idx), rename_cb, delete_cb)
    if SaveManager.can_unlock_more_manual_slots():
        _build_reward_unlock_slot()
    _apply_native_mobile_font_scale()




func _build_grouped_load_slots() -> void :
    var groups: Array = SaveManager.list_save_groups()
    var visible_groups: Array = _filter_visible_groups(groups)


    var bucket_list: = []
    for g in visible_groups:
        bucket_list.append(str(g.get("bucket", "")))
    if selected_bucket == "" or not (selected_bucket in bucket_list):
        selected_bucket = str(bucket_list[0]) if not bucket_list.is_empty() else ""

    _build_tab_bar(visible_groups)

    var current_group: Dictionary = {}
    for g in visible_groups:
        if str(g.get("bucket", "")) == selected_bucket:
            current_group = g
            break

    for e in current_group.get("entries", []):
        var entry: Dictionary = e
        var info: Dictionary = entry.get("info", {})
        var path: String = str(entry.get("path", ""))
        var label: String
        if bool(entry.get("is_autosave", false)):
            label = "自动存档"
        else:
            label = "存档 " + str(int(entry.get("slot", 0)) + 1)
        var entry_bucket: = str(entry.get("bucket", selected_bucket))
        var rename_cb: = Callable()
        var delete_cb: = Callable()
        if not bool(entry.get("is_autosave", false)) and not info.is_empty():
            var p: = path
            rename_cb = func(): _show_rename_dialog(str(info.get("custom_name", "")), func(nm: String):
                if SaveManager.set_custom_name_path(p, nm):
                    _build_slots())
            delete_cb = func(): _show_delete_confirm(label, info, func():
                SaveManager.delete_path(p)
                _build_slots())
        _add_slot_row(label, info, "读取", info.is_empty(), func(): _do_load_path(path, entry_bucket), rename_cb, delete_cb)



    if SaveManager.can_unlock_more_manual_slots():
        _build_reward_unlock_slot()


func _filter_visible_groups(groups: Array) -> Array:
    if OS.has_feature("editor"):
        return groups
    var only_first: = []
    for g in groups:
        if str(g.get("bucket", "")) == RouteRegistryRef.BUCKET_ORDER[0]:
            only_first.append(g)

    if only_first.is_empty() and not groups.is_empty():
        only_first.append(groups[0])
    return only_first

func _ensure_tab_bar() -> void :
    if tab_bar != null and is_instance_valid(tab_bar):
        return
    tab_bar = HBoxContainer.new()
    tab_bar.name = "TabBar"
    tab_bar.alignment = BoxContainer.ALIGNMENT_BEGIN

    vbox.add_child(tab_bar)
    vbox.move_child(tab_bar, header_box.get_index() + 1)

func _set_tab_bar_visible(v: bool) -> void :
    if tab_bar != null and is_instance_valid(tab_bar):
        tab_bar.visible = v

func _build_tab_bar(visible_groups: Array) -> void :
    _ensure_tab_bar()
    for child in tab_bar.get_children():
        child.queue_free()

    if visible_groups.size() <= 1:
        _set_tab_bar_visible(false)
        return
    _set_tab_bar_visible(true)
    tab_bar.add_theme_constant_override("separation", 18 if _is_mobile_portrait() else 8)
    for g in visible_groups:
        var bucket: = str(g.get("bucket", ""))
        var is_selected: = bucket == selected_bucket
        var btn: = Button.new()
        btn.text = str(g.get("label", ""))
        btn.toggle_mode = true
        btn.button_pressed = is_selected
        btn.focus_mode = Control.FOCUS_NONE
        btn.add_theme_font_override("font", FontLoader.serif_bold())
        btn.add_theme_font_size_override("font_size", MOBILE_SLOT_LABEL_FONT_SIZE if _is_mobile_portrait() else 15)
        var tab_color: = GameState.get_theme_color("text_main") if GameState.theme == "light" else GameState.get_theme_color("border_active")
        var inactive_color: = GameState.get_theme_color("text_sub")
        btn.add_theme_color_override("font_color", tab_color if is_selected else inactive_color)
        btn.add_theme_color_override("font_hover_color", tab_color)
        btn.add_theme_color_override("font_pressed_color", tab_color)
        btn.add_theme_color_override("font_focus_color", tab_color if is_selected else inactive_color)
        var tab_pad_x: = 20 if _is_mobile_portrait() else 14
        var tab_pad_y: = 10 if _is_mobile_portrait() else 6
        btn.add_theme_stylebox_override("normal", _tab_style(is_selected, tab_pad_x, tab_pad_y))
        btn.add_theme_stylebox_override("hover", _tab_style(is_selected, tab_pad_x, tab_pad_y))
        btn.add_theme_stylebox_override("pressed", _tab_style(true, tab_pad_x, tab_pad_y))
        btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
        var target_bucket: = bucket
        btn.pressed.connect( func():
            if selected_bucket == target_bucket:
                return
            selected_bucket = target_bucket
            _build_slots()
        )
        tab_bar.add_child(btn)

func _tab_style(active: bool, pad_x: int, pad_y: int) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    if GameState.theme == "light":
        style.bg_color = Color(0.88, 0.88, 0.9, 0.85) if active else Color(0.91, 0.91, 0.92, 0.0)
    else:
        style.bg_color = Color(0.165, 0.115, 0.07, 0.82) if active else Color(0.105, 0.08, 0.058, 0.0)
    style.border_color = GameState.get_theme_color("border_active")
    style.border_width_bottom = 2 if active else 0
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.content_margin_left = pad_x
    style.content_margin_right = pad_x
    style.content_margin_top = pad_y
    style.content_margin_bottom = pad_y
    return style

func _build_autosave_slot() -> void :
    var info: = SaveManager.get_autosave_info()
    var previous_info: = SaveManager.get_previous_autosave_info()
    if mode == "save":
        _add_slot_row("自动存档", info, "自动", true, Callable())
        _add_slot_row("自动存档", previous_info, "自动", true, Callable())
    else:
        _add_slot_row("自动存档", info, "读取", info.is_empty(), func(): _do_load_autosave())
        _add_slot_row("自动存档", previous_info, "读取", previous_info.is_empty(), func(): _do_load_previous_autosave())

func _add_slot_row(slot_text: String, info: Dictionary, action_text: String, disabled: bool, callback: Callable, rename_cb: Callable = Callable(), delete_cb: Callable = Callable()) -> void :
    var slot_panel = PanelContainer.new()
    slot_panel.mouse_filter = Control.MOUSE_FILTER_PASS
    slot_panel.gui_input.connect(_on_scroll_touch_drag)
    if _is_mobile_portrait():
        slot_panel.custom_minimum_size.y = MOBILE_SLOT_ROW_HEIGHT
    else:
        slot_panel.custom_minimum_size.y = PC_SLOT_ROW_HEIGHT

    slot_panel.add_theme_stylebox_override("panel", _slot_style( not info.is_empty()))

    var hbox = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 22 if _is_mobile_portrait() else 12)

    var slot_label = Label.new()
    slot_label.text = slot_text
    slot_label.custom_minimum_size.x = 180 if _is_mobile_portrait() else 86
    slot_label.add_theme_font_size_override("font_size", MOBILE_SLOT_LABEL_FONT_SIZE if _is_mobile_portrait() else 16)
    slot_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    var is_autosave: = slot_text == "自动存档"
    var label_color: Color
    if is_autosave:
        label_color = Color(0.25, 0.45, 0.2) if GameState.theme == "light" else Color(0.5, 0.7, 0.45)
    else:
        label_color = GameState.get_theme_color("text_main") if GameState.theme == "light" else GameState.get_theme_color("border_active")
    slot_label.add_theme_color_override("font_color", label_color)
    hbox.add_child(slot_label)

    var info_label = Label.new()
    info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    info_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    info_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    info_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
    if info.is_empty():
        info_label.text = "- 空 -"
        info_label.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    else:
        var custom_name: = str(info.get("custom_name", ""))
        if custom_name != "":
            info_label.text = "「" + custom_name + "」 | 回合 " + str(info["turn"])
        elif _is_mobile_portrait():
            info_label.text = info["char_name"] + " | " + info["rank"] + " | 回合 " + str(info["turn"])
        else:
            info_label.text = info["char_name"] + " | " + info["rank"] + " | 回合 " + str(info["turn"]) + " | " + info["save_time"]
        var info_color: Color
        if is_autosave:
            info_color = Color(0.3, 0.5, 0.25) if GameState.theme == "light" else Color(0.6, 0.75, 0.55)
        else:
            info_color = GameState.get_theme_color("text_desc")
        info_label.add_theme_color_override("font_color", info_color)
    info_label.add_theme_font_size_override("font_size", MOBILE_SLOT_INFO_FONT_SIZE if _is_mobile_portrait() else 14)
    hbox.add_child(info_label)

    var action_btn = Button.new()
    action_btn.mouse_filter = Control.MOUSE_FILTER_PASS
    action_btn.gui_input.connect(_on_scroll_touch_drag)
    action_btn.custom_minimum_size = Vector2(124.0, MOBILE_ACTION_BUTTON_HEIGHT) if _is_mobile_portrait() else Vector2(0, 0)
    action_btn.add_theme_font_size_override("font_size", MOBILE_ACTION_FONT_SIZE if _is_mobile_portrait() else 14)
    action_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    var action_pad_x: = 24 if _is_mobile_portrait() else 12
    var action_pad_y: = 12 if _is_mobile_portrait() else 4
    GameScreenStyleFactory.apply_command_button_style(action_btn, "primary", action_pad_x, action_pad_y)
    action_btn.text = action_text
    action_btn.disabled = disabled
    if callback.is_valid():
        action_btn.pressed.connect( func():
            if NativeMobileTouchScrollRef.should_suppress_press(self, "scroll_touch_drag_suppress_until_ms"):
                return
            callback.call()
        )

    if delete_cb.is_valid():
        hbox.add_child(_make_row_button("删除", true, delete_cb))
    if rename_cb.is_valid():
        hbox.add_child(_make_row_button("改名", false, rename_cb))
    hbox.add_child(action_btn)

    slot_panel.add_child(hbox)
    slots_container.add_child(slot_panel)


func _make_row_button(text: String, danger: bool, callback: Callable) -> Button:
    var btn: = Button.new()
    btn.mouse_filter = Control.MOUSE_FILTER_PASS
    btn.gui_input.connect(_on_scroll_touch_drag)
    btn.focus_mode = Control.FOCUS_NONE
    btn.custom_minimum_size = Vector2(104.0, MOBILE_ACTION_BUTTON_HEIGHT) if _is_mobile_portrait() else Vector2(0, 0)
    btn.add_theme_font_size_override("font_size", MOBILE_ACTION_FONT_SIZE if _is_mobile_portrait() else 14)
    btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    var col: Color
    if danger:
        col = Color(0.66, 0.22, 0.18) if GameState.theme == "light" else Color(0.82, 0.46, 0.4)
    else:
        col = GameState.get_theme_color("text_main")
    btn.add_theme_color_override("font_color", col)
    btn.add_theme_color_override("font_hover_color", col.darkened(0.1) if GameState.theme == "light" else col.lightened(0.1))
    btn.add_theme_color_override("font_pressed_color", col.darkened(0.2) if GameState.theme == "light" else col.lightened(0.2))
    btn.add_theme_color_override("font_focus_color", col)
    var pad_x: = 24 if _is_mobile_portrait() else 10
    var pad_y: = 12 if _is_mobile_portrait() else 4
    btn.add_theme_stylebox_override("normal", _button_style(false, false, pad_x, pad_y))
    btn.add_theme_stylebox_override("hover", _button_style(true, false, pad_x, pad_y))
    btn.add_theme_stylebox_override("pressed", _button_style(true, true, pad_x, pad_y))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    btn.text = text
    btn.pressed.connect( func():
        if NativeMobileTouchScrollRef.should_suppress_press(self, "scroll_touch_drag_suppress_until_ms"):
            return
        callback.call()
    )
    return btn

func _build_reward_unlock_slot() -> void :
    var slot_panel = PanelContainer.new()
    slot_panel.mouse_filter = Control.MOUSE_FILTER_PASS
    slot_panel.gui_input.connect(_on_scroll_touch_drag)
    if _is_mobile_portrait():
        slot_panel.custom_minimum_size.y = MOBILE_SLOT_ROW_HEIGHT
    else:
        slot_panel.custom_minimum_size.y = PC_SLOT_ROW_HEIGHT
    slot_panel.add_theme_stylebox_override("panel", _slot_style(false))

    var hbox = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 22 if _is_mobile_portrait() else 12)

    var slot_label = Label.new()
    slot_label.text = "加开档位"
    slot_label.custom_minimum_size.x = 180 if _is_mobile_portrait() else 86
    slot_label.add_theme_font_size_override("font_size", MOBILE_SLOT_LABEL_FONT_SIZE if _is_mobile_portrait() else 16)
    slot_label.add_theme_color_override("font_color", Color(0.25, 0.45, 0.2) if GameState.theme == "light" else Color(0.5, 0.7, 0.45))
    slot_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    hbox.add_child(slot_label)

    var info_label = Label.new()
    info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    info_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    info_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    info_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
    var current_slots: = SaveManager.get_available_manual_slots()
    if reward_status_text != "":
        info_label.text = reward_status_text
    else:
        info_label.text = "观看一条激励视频，增加 1 个手动存档位（" + str(current_slots) + "/" + str(SaveManager.ANDROID_MAX_MANUAL_SLOTS) + "）"
    info_label.add_theme_font_size_override("font_size", MOBILE_SLOT_INFO_FONT_SIZE if _is_mobile_portrait() else 14)
    info_label.add_theme_color_override("font_color", Color(0.3, 0.5, 0.25) if GameState.theme == "light" else Color(0.6, 0.75, 0.55))
    hbox.add_child(info_label)

    var action_btn = Button.new()
    action_btn.mouse_filter = Control.MOUSE_FILTER_PASS
    action_btn.gui_input.connect(_on_scroll_touch_drag)
    action_btn.custom_minimum_size = Vector2(124.0, MOBILE_ACTION_BUTTON_HEIGHT) if _is_mobile_portrait() else Vector2(0, 0)
    action_btn.add_theme_font_size_override("font_size", MOBILE_ACTION_FONT_SIZE if _is_mobile_portrait() else 14)
    action_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    action_btn.text = "观看"
    action_btn.disabled = not AndroidRewardAdService.is_available()
    var action_pad_x: = 24 if _is_mobile_portrait() else 12
    var action_pad_y: = 12 if _is_mobile_portrait() else 4
    GameScreenStyleFactory.apply_command_button_style(action_btn, "primary", action_pad_x, action_pad_y)
    action_btn.pressed.connect( func():
        if NativeMobileTouchScrollRef.should_suppress_press(self, "scroll_touch_drag_suppress_until_ms"):
            return
        _on_reward_unlock_pressed()
    )
    hbox.add_child(action_btn)

    slot_panel.add_child(hbox)
    slots_container.add_child(slot_panel)

func _panel_style() -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color.html("E0E2E6") if GameState.theme == "light" else GameState.get_theme_color("bg_popup")
    style.border_color = Color(0.42, 0.43, 0.44, 0.72)
    style.set_border_width_all(1)
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    style.content_margin_left = _panel_margin_left
    style.content_margin_right = _panel_margin_right
    style.content_margin_top = _panel_margin_top
    style.content_margin_bottom = _panel_margin_bottom
    style.shadow_size = 0 if GameState.theme == "light" else 12
    style.shadow_color = Color(0.2, 0.15, 0.1, 0.15) if GameState.theme == "light" else Color(0, 0, 0, 0.4)
    style.shadow_offset = Vector2(0, 6)
    return style

func _slot_style(has_save: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    if GameState.theme == "light":
        style.bg_color = Color(0.95, 0.95, 0.96, 0.85) if has_save else Color(0.91, 0.91, 0.92, 0.55)
        style.border_color = Color.TRANSPARENT
    else:
        style.bg_color = Color(0.092, 0.071, 0.05, 0.8) if has_save else Color(0.065, 0.057, 0.046, 0.66)
        style.border_color = Color.TRANSPARENT
    style.set_border_width_all(0)
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    style.content_margin_left = 16
    style.content_margin_right = 16
    style.content_margin_top = 18 if not _is_mobile_portrait() else 12
    style.content_margin_bottom = 18 if not _is_mobile_portrait() else 12
    return style

func _button_style(hovered: bool, pressed: bool = false, pad_x: int = 18, pad_y: int = 8) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    if GameState.theme == "light":
        style.bg_color = Color(0.82, 0.82, 0.84, 0.85) if hovered or pressed else Color(0.88, 0.88, 0.9, 0.5)
    else:
        style.bg_color = Color(0.165, 0.115, 0.07, 0.82) if hovered or pressed else Color(0.105, 0.08, 0.058, 0.72)
    style.border_color = Color.TRANSPARENT
    style.set_border_width_all(0)
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    style.content_margin_left = pad_x
    style.content_margin_right = pad_x
    style.content_margin_top = pad_y
    style.content_margin_bottom = pad_y
    return style



func _show_construction_confirm(bucket: String, on_proceed: Callable) -> void :
    var compact: = _is_mobile_portrait()

    var click_layer: = Control.new()
    click_layer.name = "ConstructionConfirm"
    click_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
    click_layer.mouse_filter = Control.MOUSE_FILTER_STOP
    click_layer.z_as_relative = false
    click_layer.z_index = TOP_MODAL_Z_INDEX + 10
    add_child(click_layer)

    var overlay_bg: = ColorRect.new()
    overlay_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay_bg.color = Color(0.0, 0.0, 0.0, 0.85)
    click_layer.add_child(overlay_bg)

    var dialog_panel: = PanelContainer.new()
    dialog_panel.set_anchors_preset(Control.PRESET_CENTER)
    dialog_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    dialog_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
    dialog_panel.custom_minimum_size = Vector2(640, 500) if compact else Vector2(560, 380)

    var gold: = GameState.get_theme_color("border_active")
    var panel_style: = StyleBoxFlat.new()
    panel_style.bg_color = GameState.get_theme_color("bg_popup")
    panel_style.border_color = Color(0.42, 0.43, 0.44, 0.72)
    panel_style.set_border_width_all(1)
    panel_style.shadow_color = Color(0, 0, 0, 0.6)
    panel_style.shadow_size = 24
    dialog_panel.add_theme_stylebox_override("panel", panel_style)
    click_layer.add_child(dialog_panel)

    var margin: = MarginContainer.new()
    var pad: = 36 if compact else 28
    margin.add_theme_constant_override("margin_left", pad)
    margin.add_theme_constant_override("margin_right", pad)
    margin.add_theme_constant_override("margin_top", pad)
    margin.add_theme_constant_override("margin_bottom", pad)
    dialog_panel.add_child(margin)

    var box: = VBoxContainer.new()
    box.add_theme_constant_override("separation", 24 if compact else 18)
    margin.add_child(box)

    var title_lbl: = Label.new()
    title_lbl.text = "神秘施工现场"
    title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_lbl.add_theme_font_override("font", FontLoader.serif_bold())
    title_lbl.add_theme_font_size_override("font_size", 36 if compact else 22)
    title_lbl.add_theme_color_override("font_color", gold)
    box.add_child(title_lbl)

    var sep: = HSeparator.new()
    var sep_style: = StyleBoxLine.new()
    sep_style.color = gold
    sep_style.color.a = 0.28
    sep.add_theme_stylebox_override("separator", sep_style)
    box.add_child(sep)

    var mode_name: = "未定义线路"
    if bucket == "bianwu":
        mode_name = "没落世家（边务线）"
    elif bucket == "free":
        mode_name = "自由模式（旷野线）"

    var content_lbl: = Label.new()
    content_lbl.text = "此处的「%s」内容仍在全力建设中，暂未正式开放。\n\n如果你不小心点进来了，那么你应该是被某种洪荒之力卷进了神秘施工现场。\n请耐心等待，以后再来玩吧。" % mode_name
    content_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    content_lbl.add_theme_font_size_override("font_size", 28 if compact else 15)
    content_lbl.add_theme_color_override("font_color", Color(0.92, 0.88, 0.76, 0.96))
    content_lbl.add_theme_constant_override("line_spacing", 10 if compact else 6)
    box.add_child(content_lbl)

    var spacer: = Control.new()
    spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    box.add_child(spacer)

    var btn_box: = HBoxContainer.new()
    btn_box.alignment = BoxContainer.ALIGNMENT_CENTER
    btn_box.add_theme_constant_override("separation", 40 if compact else 24)
    box.add_child(btn_box)

    var btn_back: = Button.new()
    btn_back.text = "先回去了"
    btn_back.focus_mode = Control.FOCUS_NONE
    btn_back.custom_minimum_size = Vector2(240 if compact else 140, 68 if compact else 40)
    btn_back.add_theme_font_size_override("font_size", 28 if compact else 16)
    GameScreenStyleFactory.apply_command_button_style(btn_back, "secondary", 24 if compact else 12, 12 if compact else 6)
    btn_back.pressed.connect( func(): click_layer.queue_free())
    btn_box.add_child(btn_back)

    var btn_continue: = Button.new()
    btn_continue.text = "执意探索"
    btn_continue.focus_mode = Control.FOCUS_NONE
    btn_continue.custom_minimum_size = Vector2(240 if compact else 140, 68 if compact else 40)
    btn_continue.add_theme_font_size_override("font_size", 28 if compact else 16)
    GameScreenStyleFactory.apply_command_button_style(btn_continue, "primary", 24 if compact else 12, 12 if compact else 6)
    btn_continue.pressed.connect( func():
        click_layer.queue_free()
        if on_proceed.is_valid():
            on_proceed.call()
    )
    btn_box.add_child(btn_continue)

    _apply_native_mobile_font_scale()


func _show_delete_confirm(slot_text: String, info: Dictionary, on_confirm: Callable) -> void :
    var compact: = _is_mobile_portrait()
    var layer: = _make_dialog_layer("DeleteConfirm")
    var box: = _make_dialog_box(layer, Vector2(640, 420) if compact else Vector2(540, 280))

    var title_lbl: = Label.new()
    title_lbl.text = "删除存档"
    title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_lbl.add_theme_font_override("font", FontLoader.serif_bold())
    title_lbl.add_theme_font_size_override("font_size", 36 if compact else 22)
    title_lbl.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    box.add_child(title_lbl)

    var sep: = HSeparator.new()
    var sep_style: = StyleBoxLine.new()
    sep_style.color = GameState.get_theme_color("border_active")
    sep_style.color.a = 0.28
    sep.add_theme_stylebox_override("separator", sep_style)
    box.add_child(sep)

    var custom: = str(info.get("custom_name", ""))
    var summary: = "%s | %s | 回合 %s" % [str(info.get("char_name", "")), str(info.get("rank", "")), str(info.get("turn", ""))]
    var name_line: = ("「%s」" % custom) if custom != "" else slot_text
    var content_lbl: = Label.new()
    content_lbl.text = "确定删除 %s 吗？\n%s\n\n此操作无法撤销。" % [name_line, summary]
    content_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    content_lbl.add_theme_font_size_override("font_size", 28 if compact else 15)
    content_lbl.add_theme_color_override("font_color", Color(0.92, 0.88, 0.76, 0.96))
    content_lbl.add_theme_constant_override("line_spacing", 10 if compact else 6)
    box.add_child(content_lbl)

    var spacer: = Control.new()
    spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    box.add_child(spacer)

    var btn_box: = HBoxContainer.new()
    btn_box.alignment = BoxContainer.ALIGNMENT_CENTER
    btn_box.add_theme_constant_override("separation", 40 if compact else 24)
    box.add_child(btn_box)

    var btn_cancel: = Button.new()
    btn_cancel.text = "取消"
    btn_cancel.focus_mode = Control.FOCUS_NONE
    btn_cancel.custom_minimum_size = Vector2(240 if compact else 140, 68 if compact else 40)
    btn_cancel.add_theme_font_size_override("font_size", 28 if compact else 16)
    GameScreenStyleFactory.apply_command_button_style(btn_cancel, "secondary", 24 if compact else 12, 12 if compact else 6)
    btn_cancel.pressed.connect( func(): layer.queue_free())
    btn_box.add_child(btn_cancel)

    var btn_del: = Button.new()
    btn_del.text = "删除"
    btn_del.focus_mode = Control.FOCUS_NONE
    btn_del.custom_minimum_size = Vector2(240 if compact else 140, 68 if compact else 40)
    btn_del.add_theme_font_size_override("font_size", 28 if compact else 16)
    GameScreenStyleFactory.apply_command_button_style(btn_del, "primary", 24 if compact else 12, 12 if compact else 6)
    btn_del.pressed.connect( func():
        layer.queue_free()
        if on_confirm.is_valid():
            on_confirm.call())
    btn_box.add_child(btn_del)


    _apply_native_mobile_font_scale()


func _show_rename_dialog(current_name: String, on_submit: Callable) -> void :
    var compact: = _is_mobile_portrait()
    var layer: = _make_dialog_layer("RenameDialog")
    var box: = _make_dialog_box(layer, Vector2(680, 400) if compact else Vector2(520, 260))

    var title_lbl: = Label.new()
    title_lbl.text = "存档命名"
    title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_lbl.add_theme_font_override("font", FontLoader.serif_bold())
    title_lbl.add_theme_font_size_override("font_size", 36 if compact else 22)
    title_lbl.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    box.add_child(title_lbl)


    var native_phone: = NativeMobileFontScalerRef.is_native_phone_landscape(self)
    var edit_font: = 30 if compact else (22 if native_phone else 16)
    var edit_height: = 68.0 if compact else (56.0 if native_phone else 38.0)
    var line_edit: = LineEdit.new()
    line_edit.text = current_name
    line_edit.placeholder_text = "为这个存档起个名字（留空则恢复默认）"
    line_edit.max_length = SaveManager.CUSTOM_NAME_MAX_LEN
    line_edit.virtual_keyboard_enabled = true
    line_edit.context_menu_enabled = true
    line_edit.add_theme_font_size_override("font_size", edit_font)
    line_edit.custom_minimum_size.y = edit_height
    line_edit.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    line_edit.add_theme_color_override("caret_color", GameState.get_theme_color("text_main"))
    line_edit.add_theme_stylebox_override("normal", _button_style(false))
    line_edit.add_theme_stylebox_override("focus", _button_style(true))
    box.add_child(line_edit)

    var spacer: = Control.new()
    spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    box.add_child(spacer)

    var btn_box: = HBoxContainer.new()
    btn_box.alignment = BoxContainer.ALIGNMENT_CENTER
    btn_box.add_theme_constant_override("separation", 40 if compact else 24)
    box.add_child(btn_box)

    var close_dialog: = func():
        DisplayServer.virtual_keyboard_hide()
        layer.queue_free()

    var btn_cancel: = Button.new()
    btn_cancel.text = "取消"
    btn_cancel.focus_mode = Control.FOCUS_NONE
    btn_cancel.custom_minimum_size = Vector2(240 if compact else 140, 68 if compact else 40)
    btn_cancel.add_theme_font_size_override("font_size", 28 if compact else 16)
    GameScreenStyleFactory.apply_command_button_style(btn_cancel, "secondary", 24 if compact else 12, 12 if compact else 6)
    btn_cancel.pressed.connect( func(): close_dialog.call())
    btn_box.add_child(btn_cancel)

    var submit: = func():
        var nm: = line_edit.text.strip_edges()
        close_dialog.call()
        if on_submit.is_valid():
            on_submit.call(nm)

    var btn_ok: = Button.new()
    btn_ok.text = "确定"
    btn_ok.focus_mode = Control.FOCUS_NONE
    btn_ok.custom_minimum_size = Vector2(240 if compact else 140, 68 if compact else 40)
    btn_ok.add_theme_font_size_override("font_size", 28 if compact else 16)
    GameScreenStyleFactory.apply_command_button_style(btn_ok, "primary", 24 if compact else 12, 12 if compact else 6)
    btn_ok.pressed.connect(submit)
    btn_box.add_child(btn_ok)

    line_edit.text_submitted.connect( func(_t: String): submit.call())

    _apply_native_mobile_font_scale()


    line_edit.call_deferred("grab_focus")
    line_edit.call_deferred("select_all")


func _make_dialog_layer(layer_name: String) -> Control:
    var layer: = Control.new()
    layer.name = layer_name
    layer.set_anchors_preset(Control.PRESET_FULL_RECT)
    layer.mouse_filter = Control.MOUSE_FILTER_STOP
    layer.z_as_relative = false
    layer.z_index = TOP_MODAL_Z_INDEX + 10
    add_child(layer)
    var overlay_bg: = ColorRect.new()
    overlay_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay_bg.color = Color(0.0, 0.0, 0.0, 0.7)
    layer.add_child(overlay_bg)
    return layer


func _make_dialog_box(layer: Control, min_size: Vector2) -> VBoxContainer:
    var compact: = _is_mobile_portrait()
    var dialog_panel: = PanelContainer.new()
    dialog_panel.set_anchors_preset(Control.PRESET_CENTER)
    dialog_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    dialog_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
    dialog_panel.custom_minimum_size = min_size
    var panel_style: = StyleBoxFlat.new()
    panel_style.bg_color = GameState.get_theme_color("bg_popup")
    panel_style.border_color = Color(0.42, 0.43, 0.44, 0.72)
    panel_style.set_border_width_all(1)
    panel_style.shadow_color = Color(0, 0, 0, 0.6)
    panel_style.shadow_size = 24
    dialog_panel.add_theme_stylebox_override("panel", panel_style)
    layer.add_child(dialog_panel)

    var margin: = MarginContainer.new()
    var pad: = 36 if compact else 28
    margin.add_theme_constant_override("margin_left", pad)
    margin.add_theme_constant_override("margin_right", pad)
    margin.add_theme_constant_override("margin_top", pad)
    margin.add_theme_constant_override("margin_bottom", pad)
    dialog_panel.add_child(margin)

    var box: = VBoxContainer.new()
    box.add_theme_constant_override("separation", 24 if compact else 18)
    margin.add_child(box)
    return box

func _do_save(slot: int) -> void :
    if SaveManager.save_game(slot):
        _build_slots()

func _do_load(slot: int) -> void :
    if SaveManager.load_game(slot):
        visible = false
        var main = get_tree().root.get_node("Main")
        if main and main.has_method("resume_from_load"):
            main.resume_from_load()

func _do_load_autosave() -> void :
    if SaveManager.load_autosave():
        visible = false
        var main = get_tree().root.get_node("Main")
        if main and main.has_method("resume_from_load"):
            main.resume_from_load()

func _do_load_previous_autosave() -> void :
    if SaveManager.load_previous_autosave():
        visible = false
        var main = get_tree().root.get_node("Main")
        if main and main.has_method("resume_from_load"):
            main.resume_from_load()



func _do_load_path(path: String, bucket: String = "") -> void :
    if bucket == "hanmen" or bucket == "":
        _perform_load_path(path)
        return
    _show_construction_confirm(bucket, func(): _perform_load_path(path))

func _perform_load_path(path: String) -> void :
    if SaveManager.load_path(path):
        visible = false
        var main = get_tree().root.get_node("Main")
        if main and main.has_method("resume_from_load"):
            main.resume_from_load()

func _on_reward_unlock_pressed() -> void :
    reward_status_text = "正在加载激励视频..."
    _build_slots()
    if not AndroidRewardAdService.show_save_slot_reward_ad():
        reward_status_text = "激励视频暂不可用，请稍后再试"
        _build_slots()

func _on_reward_granted(reward_type: String) -> void :
    if reward_type != "save_slot":
        return
    if not SaveManager.can_unlock_more_manual_slots():
        reward_status_text = "手动存档位已达上限"
        _build_slots()
        return
    if SaveManager.unlock_manual_slot_from_reward():
        reward_status_text = "已增加 1 个手动存档位"
        _show_reward_toast("存档档位已+1")
    else:
        reward_status_text = "存档栏位保存失败，请检查存储空间后重试"
    _build_slots()

func _on_reward_failed(reward_type: String, message: String = "") -> void :
    if reward_type != "save_slot":
        return
    reward_status_text = "激励视频未完成，请稍后再试" if message == "" else message
    _build_slots()

func _on_reward_unavailable(reward_type: String, message: String = "") -> void :
    if reward_type != "save_slot":
        return
    reward_status_text = "激励视频暂不可用，请稍后再试" if message == "" else message
    _build_slots()


func _show_reward_toast(text: String) -> void :
    if _toast_controller == null:
        _toast_controller = TransitionToastController.new(self)
    _toast_controller.show_simple_toast(text)


func _apply_native_mobile_font_scale() -> void :
    NativeMobileFontScalerRef.apply_to(self)


func _on_scroll_touch_drag(event: InputEvent) -> void :
    NativeMobileTouchScrollRef.forward_drag_to_scroll(event, slots_scroll, self, "scroll_touch_drag_suppress_until_ms")
