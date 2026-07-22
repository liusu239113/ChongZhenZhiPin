extends Control

signal timeline_selected(timeline: String)
signal back_requested

const TIMELINE_BG: Texture2D = preload("res://assets/choose-bg.webp")
const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const FontLoader = preload("res://scripts/ui/font_loader.gd")
const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")

var FONT_TITLE: Font = FontLoader.title()
var FONT_BODY: Font = FontLoader.body()
var FONT_KAI: Font = FontLoader.body()
var FONT_SERIF_BOLD: Font = FontLoader.serif_bold()

const MOBILE_PORTRAIT_MAX_WIDTH: = 900.0
const MOBILE_CARD_WIDTH: = 560.0
const MOBILE_CARD_HEIGHT: = 238.0
const MOBILE_HEADER_FONT_SIZE: = 48
const MOBILE_TIMELINE_YEAR_FONT_SIZE: = 22
const MOBILE_TIMELINE_ERA_FONT_SIZE: = 38
const MOBILE_TIMELINE_SUB_FONT_SIZE: = 28
const MOBILE_TIMELINE_DESC_FONT_SIZE: = 23
const MOBILE_TIMELINE_BADGE_FONT_SIZE: = 20
const MOBILE_ACTION_BUTTON_WIDTH: = 260.0
const MOBILE_ACTION_BUTTON_HEIGHT: = 68.0
const MOBILE_ACTION_FONT_SIZE: = 28
const ACCENT_RED: = Color(0.55, 0.12, 0.08, 0.92)
const GOLD_DARK: = Color(0.49, 0.34, 0.13, 1.0)

var GOLD: Color:
    get: return GameState.get_theme_color("border_active")
var GOLD_SOFT: Color:
    get: return GameState.get_theme_color("text_main") if GameState.theme == "dark" else Color(0.86, 0.75, 0.48, 1.0)
var INK: Color:
    get: return GameState.get_theme_color("text_desc")
var INK_DEEP: Color:
    get: return GameState.get_theme_color("text_main")
var MUTED: Color:
    get: return GameState.get_theme_color("text_sub")

@onready var background: TextureRect = $Background
@onready var overlay: ColorRect = $Overlay

var wanli_card: Control
var chongzhen_card: Control
var chongzhen_17_card: Control
var header_label: Label
var back_button: Button
var confirm_button: Button
var timeline_axis: VBoxContainer

var selected_timeline: String = "wanli"
var hovered_timeline: String = ""


var mode_button: Button
var mode_dropdown: PanelContainer
var mode_mask: Control
const MODE_LABELS: = {"normal": "普通模式", "simple": "简单模式"}
const MODE_DESCS: = {
    "normal": "标准难度。运气抽卡每场只有一次机会；每月 2 点行动力。", 
    "simple": "更易上手。运气抽卡每场失利后可「再试一次」；每月 3 点行动力。", 
}


var _card_scale: float = 1.0

func _ready() -> void :
    GameState.theme_changed.connect(_on_theme_changed)
    resized.connect(_on_resized)


    visibility_changed.connect(_on_visibility_changed)
    _build_ui()

func _on_visibility_changed() -> void :
    if visible:
        refresh_mode_selector()

func _on_theme_changed(_theme: String) -> void :
    if not is_inside_tree(): return

    _clear_dynamic_children()
    _build_ui()

func _clear_dynamic_children() -> void :
    for child in get_children():
        if child == background or child == overlay:
            continue
        child.queue_free()

func _on_resized() -> void :
    if not is_inside_tree():
        return
    _clear_dynamic_children()
    _build_ui()

func _build_ui() -> void :
    _apply_background()

    var margin = MarginContainer.new()
    margin.set_anchors_preset(Control.PRESET_FULL_RECT)
    var compact = _is_compact_layout()
    var side_pad = 22 if compact else 56
    var top_pad = 110 if compact else 42
    margin.add_theme_constant_override("margin_left", side_pad)
    margin.add_theme_constant_override("margin_top", top_pad)
    margin.add_theme_constant_override("margin_right", side_pad)
    margin.add_theme_constant_override("margin_bottom", 64 if compact else 34)
    add_child(margin)

    var main_vbox = VBoxContainer.new()
    main_vbox.add_theme_constant_override("separation", 12 if compact else 30)
    main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
    margin.add_child(main_vbox)

    var header_box = _build_header(compact)
    main_vbox.add_child(header_box)

    _card_scale = _compute_card_scale(compact, side_pad)

    wanli_card = _build_timeline_card(
        "wanli", 
        "1603", 
        "万历三十一年", 
        "抓 周", 
        "完整科举路线", 
        "从襁褓之中开始，体验完整的科举之路。", 
        "res://assets/Texture/Farmer.webp", 
        0.35
    )
    chongzhen_card = _build_timeline_card(
        "chongzhen", 
        "1628", 
        "崇祯元年", 
        "殿 试", 
        "快速入仕路线", 
        "跳过漫长的科举苦旅，以贡士身份参加殿试。", 
        "res://assets/Texture/MainHall.webp", 
        0.56
    )
    chongzhen_17_card = _build_timeline_card(
        "chongzhen_17", 
        "1644", 
        "崇祯十七年", 
        "甲 申", 
        "暂未开放", 
        "山河将倾，边墙之外的风已经吹到京城。", 
        "res://assets/Texture/GreatWall.webp", 
        0.4
    )

    var cards_box: BoxContainer
    if compact:
        cards_box = VBoxContainer.new()
        cards_box.add_theme_constant_override("separation", 12)
    else:
        cards_box = HBoxContainer.new()
        cards_box.add_theme_constant_override("separation", 28)
    cards_box.alignment = BoxContainer.ALIGNMENT_CENTER
    cards_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
    main_vbox.add_child(cards_box)

    cards_box.add_child(wanli_card)

    cards_box.add_child(chongzhen_card)
    cards_box.add_child(chongzhen_17_card)
    chongzhen_17_card.visible = false

    var actions_hbox = HBoxContainer.new()
    actions_hbox.add_theme_constant_override("separation", 16 if compact else 24)
    actions_hbox.alignment = BoxContainer.ALIGNMENT_CENTER

    back_button = Button.new()
    back_button.text = "返回"
    back_button.focus_mode = Control.FOCUS_NONE
    back_button.custom_minimum_size = _mobile_button_size(132, 46, MOBILE_ACTION_BUTTON_WIDTH, MOBILE_ACTION_BUTTON_HEIGHT)
    _style_back_button(back_button)
    back_button.pressed.connect( func(): back_requested.emit())
    actions_hbox.add_child(back_button)

    confirm_button = Button.new()
    confirm_button.text = "确认时间线"
    confirm_button.focus_mode = Control.FOCUS_NONE
    confirm_button.custom_minimum_size = _mobile_button_size(170, 46, MOBILE_ACTION_BUTTON_WIDTH + 28, MOBILE_ACTION_BUTTON_HEIGHT)
    GameScreenStyleFactory.apply_command_button_style(confirm_button, "primary", 18, 8)
    confirm_button.pressed.connect( func(): timeline_selected.emit(selected_timeline))
    actions_hbox.add_child(confirm_button)
    _update_confirm_button_state()

    main_vbox.add_child(actions_hbox)

    _build_mode_selector(compact, side_pad, top_pad)
    _apply_native_mobile_font_scale()
    _align_mode_button_to_header()

func _apply_background() -> void :
    background.texture = TIMELINE_BG
    background.modulate = Color(1.0, 1.0, 1.0, 1.0)
    overlay.color = Color(0.0, 0.0, 0.0, 0.0)

    var grad_rect = overlay.get_node_or_null("GradientOverlay")
    if not grad_rect:
        grad_rect = TextureRect.new()
        grad_rect.name = "GradientOverlay"
        grad_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
        var tex = GradientTexture2D.new()
        tex.fill = GradientTexture2D.FILL_RADIAL
        tex.fill_from = Vector2(0.5, 0.5)
        tex.fill_to = Vector2(1, 1)
        grad_rect.texture = tex
        overlay.add_child(grad_rect)

    var is_dark = GameState.theme == "dark"
    var grad = Gradient.new()
    grad.set_offset(0, 0.0)
    grad.set_color(0, Color(0.09, 0.02, 0.02, 0.6 if is_dark else 0.35))
    grad.set_offset(1, 1.0)
    grad.set_color(1, Color(0.015, 0.01, 0.01, 0.85 if is_dark else 0.7))
    grad.add_point(0.4, Color(0.05, 0.025, 0.01, 0.75 if is_dark else 0.5))
    grad_rect.texture.gradient = grad

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
func _is_compact_layout() -> bool:
    return _is_mobile_portrait()

func _mobile_font_size(desktop_size: int, mobile_size: int) -> int:
    if _is_mobile_portrait():
        return mobile_size
    return int(round(desktop_size * _card_scale))



func _compute_card_scale(compact: bool, side_pad: int) -> float:
    if compact:
        return 1.0
    var window_w: = _get_responsive_window_size().x
    if window_w <= 0.0:
        window_w = get_viewport_rect().size.x
    if window_w <= 0.0:
        return 1.0
    var sep: = 28.0
    var usable: = window_w - 2.0 * float(side_pad) - 2.0 * sep
    var needed: = 3.0 * 320.0
    if usable >= needed:
        return 1.0
    return clampf(usable / needed, 0.55, 1.0)

func _mobile_button_size(desktop_width: float, desktop_height: float, mobile_width: float, mobile_height: float) -> Vector2:
    return Vector2(mobile_width, mobile_height) if _is_mobile_portrait() else Vector2(desktop_width, desktop_height)

func _build_header(compact: bool) -> VBoxContainer:
    var header_box = VBoxContainer.new()
    header_box.add_theme_constant_override("separation", 8)
    header_box.alignment = BoxContainer.ALIGNMENT_CENTER

    header_label = Label.new()
    header_label.text = "选择时间线"
    header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _apply_label_font(header_label, FONT_TITLE, MOBILE_HEADER_FONT_SIZE if compact else 40, Color(0.96, 0.88, 0.66, 1.0))
    header_box.add_child(header_label)

    return header_box


func _build_mode_selector(compact: bool, side_pad: int, top_pad: int) -> void :
    var holder = Control.new()
    holder.name = "ModeSelector"
    holder.set_anchors_preset(Control.PRESET_FULL_RECT)
    holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(holder)

    mode_mask = Control.new()
    mode_mask.name = "ModeMask"
    mode_mask.set_anchors_preset(Control.PRESET_FULL_RECT)
    mode_mask.mouse_filter = Control.MOUSE_FILTER_STOP
    mode_mask.visible = false
    holder.add_child(mode_mask)

    mode_mask.gui_input.connect( func(event: InputEvent):
        if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)\
or (event is InputEventScreenTouch and event.pressed):
            _defer_close_mode_dropdown()
    )

    var bw: float = 280.0 if compact else 156.0
    var bh: float = 80.0 if compact else 40.0
    var top_off: float = float(top_pad)

    var btn = Button.new()
    mode_button = btn
    btn.focus_mode = Control.FOCUS_NONE
    btn.add_theme_font_override("font", FONT_SERIF_BOLD)
    btn.add_theme_font_size_override("font_size", 30 if compact else 15)
    _style_mode_button(btn)
    btn.anchor_left = 1.0
    btn.anchor_right = 1.0
    btn.offset_left = - float(side_pad) - bw
    btn.offset_right = - float(side_pad)
    btn.offset_top = top_off
    btn.offset_bottom = top_off + bh
    holder.add_child(btn)


    var avail_w: float = _get_responsive_window_size().x
    if avail_w <= 0.0:
        avail_w = get_viewport_rect().size.x
    var dd_width: float = minf(640.0 if compact else 360.0, maxf(bw, avail_w - float(side_pad) * 2.0))
    var card_h: float = 210.0 if compact else 0.0
    var dd_pad: float = 18.0 if compact else 6.0
    var card_sep: float = 16.0 if compact else 4.0

    var dropdown = PanelContainer.new()
    mode_dropdown = dropdown
    dropdown.visible = false
    var dd_style: = StyleBoxFlat.new()
    dd_style.bg_color = Color(0.04, 0.035, 0.028, 0.98)
    dd_style.border_color = Color(0.72, 0.56, 0.28, 0.42)
    dd_style.border_width_left = 1
    dd_style.border_width_top = 1
    dd_style.border_width_right = 1
    dd_style.border_width_bottom = 1
    dd_style.corner_radius_top_left = 2
    dd_style.corner_radius_top_right = 2
    dd_style.corner_radius_bottom_left = 2
    dd_style.corner_radius_bottom_right = 2
    dd_style.shadow_size = 10 if GameState.theme == "dark" else 0
    dd_style.shadow_color = Color(0, 0, 0, 0.35)
    dropdown.add_theme_stylebox_override("panel", dd_style)
    dropdown.anchor_left = 1.0
    dropdown.anchor_right = 1.0
    dropdown.offset_left = - float(side_pad) - dd_width
    dropdown.offset_right = - float(side_pad)
    dropdown.offset_top = top_off + bh + (10.0 if compact else 6.0)
    dropdown.custom_minimum_size = Vector2(dd_width, 0)
    holder.add_child(dropdown)

    var opts_margin = MarginContainer.new()
    opts_margin.add_theme_constant_override("margin_left", int(dd_pad))
    opts_margin.add_theme_constant_override("margin_right", int(dd_pad))
    opts_margin.add_theme_constant_override("margin_top", int(dd_pad))
    opts_margin.add_theme_constant_override("margin_bottom", int(dd_pad))
    dropdown.add_child(opts_margin)

    var opts_vbox = VBoxContainer.new()
    opts_vbox.add_theme_constant_override("separation", int(card_sep))
    opts_margin.add_child(opts_vbox)

    for mode_id in ["normal", "simple"]:
        var card = _build_mode_option_card(mode_id, card_h, compact)
        opts_vbox.add_child(card)

    btn.pressed.connect( func(): _toggle_mode_dropdown())
    _update_mode_button_text()


func _build_mode_option_card(mode_id: String, card_h: float, compact: bool) -> PanelContainer:
    var selected: = GameState.difficulty == mode_id
    var card = PanelContainer.new()
    card.name = "ModeOpt_" + mode_id
    card.custom_minimum_size = Vector2(0, 0)
    card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    card.add_theme_stylebox_override("panel", _mode_option_style(selected, false))

    var pad = MarginContainer.new()
    pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var lr = 22 if compact else 12
    var tb = 18 if compact else 6
    pad.add_theme_constant_override("margin_left", lr)
    pad.add_theme_constant_override("margin_right", lr)
    pad.add_theme_constant_override("margin_top", tb)
    pad.add_theme_constant_override("margin_bottom", tb)
    card.add_child(pad)

    var vb = VBoxContainer.new()
    vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
    vb.add_theme_constant_override("separation", 10 if compact else 6)
    pad.add_child(vb)

    var title = Label.new()
    title.text = MODE_LABELS[mode_id]
    _apply_label_font(title, FONT_SERIF_BOLD, 32 if compact else 14, 
        Color(0.96, 0.84, 0.56, 1.0) if selected else Color(0.86, 0.74, 0.48, 0.94))
    vb.add_child(title)

    var desc = Label.new()
    desc.text = MODE_DESCS[mode_id]
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    desc.add_theme_constant_override("line_spacing", 6 if compact else 3)
    _apply_label_font(desc, FONT_BODY, 26 if compact else 11, 
        Color(0.82, 0.77, 0.66, 0.92))
    vb.add_child(desc)

    card.gui_input.connect( func(event: InputEvent):
        if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)\
or (event is InputEventScreenTouch and event.pressed):
            _select_difficulty(mode_id)
            card.accept_event()
    )
    card.mouse_entered.connect( func():
        if GameState.difficulty != mode_id:
            card.add_theme_stylebox_override("panel", _mode_option_style(false, true))
    )
    card.mouse_exited.connect( func():
        card.add_theme_stylebox_override("panel", _mode_option_style(GameState.difficulty == mode_id, false))
    )
    return card

func _mode_option_style(selected: bool, hover: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    if selected:
        style.bg_color = Color(0.16, 0.1, 0.05, 0.78)
        style.border_color = Color(0.86, 0.66, 0.34, 0.62)
    elif hover:
        style.bg_color = Color(0.12, 0.08, 0.04, 0.62)
        style.border_color = Color(0.78, 0.58, 0.3, 0.42)
    else:
        style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
        style.border_color = Color(0.54, 0.4, 0.2, 0.3)
    var bw: = 2 if selected else 1
    style.border_width_left = bw
    style.border_width_top = bw
    style.border_width_right = bw
    style.border_width_bottom = bw
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    return style

func _toggle_mode_dropdown() -> void :
    if mode_dropdown == null or not is_instance_valid(mode_dropdown):
        return
    var to_show = not mode_dropdown.visible
    mode_dropdown.visible = to_show
    if mode_mask and is_instance_valid(mode_mask):
        mode_mask.visible = to_show
    if to_show:

        _fit_mode_dropdown_height()
        call_deferred("_fit_mode_dropdown_height")

func _defer_close_mode_dropdown() -> void :
    if mode_dropdown != null and is_instance_valid(mode_dropdown):
        mode_dropdown.set_deferred("visible", false)
    if mode_mask != null and is_instance_valid(mode_mask):
        mode_mask.set_deferred("visible", false)


func _fit_mode_dropdown_height() -> void :
    if mode_dropdown == null or not is_instance_valid(mode_dropdown):
        return
    var h: float = mode_dropdown.get_combined_minimum_size().y
    if h > 0.0:
        mode_dropdown.offset_bottom = mode_dropdown.offset_top + h

func _select_difficulty(mode_id: String) -> void :
    GameState.difficulty = mode_id
    _defer_close_mode_dropdown()
    _update_mode_button_text()
    _refresh_mode_option_styles()


func refresh_mode_selector() -> void :
    if mode_dropdown != null and is_instance_valid(mode_dropdown):
        mode_dropdown.visible = false
    if mode_mask != null and is_instance_valid(mode_mask):
        mode_mask.visible = false
    _update_mode_button_text()
    _refresh_mode_option_styles()


func _refresh_mode_option_styles() -> void :
    if mode_dropdown == null or not is_instance_valid(mode_dropdown):
        return
    for m in ["normal", "simple"]:
        var card: = mode_dropdown.find_child("ModeOpt_" + m, true, false)
        if not (card is PanelContainer):
            continue
        var sel: bool = (m == GameState.difficulty)
        card.add_theme_stylebox_override("panel", _mode_option_style(sel, false))
        var title_lbl: = _mode_card_title_label(card)
        if title_lbl != null:
            title_lbl.add_theme_color_override("font_color", 
                Color(0.96, 0.84, 0.56, 1.0) if sel else Color(0.86, 0.74, 0.48, 0.94))


func _mode_card_title_label(card: Control) -> Label:
    for pad in card.get_children():
        for vb in pad.get_children():
            for lbl in vb.get_children():
                if lbl is Label:
                    return lbl
    return null

func _update_mode_button_text() -> void :
    if mode_button != null and is_instance_valid(mode_button):
        mode_button.text = MODE_LABELS.get(GameState.difficulty, "普通模式") + "  ▾"

func _style_mode_button(btn: Button) -> void :
    btn.add_theme_stylebox_override("normal", _button_style(Color(0.03, 0.026, 0.02, 0.78), Color(0.72, 0.56, 0.28, 0.34)))
    btn.add_theme_stylebox_override("hover", _button_style(Color(0.14, 0.09, 0.045, 0.82), Color(0.82, 0.62, 0.32, 0.5)))
    btn.add_theme_stylebox_override("pressed", _button_style(Color(0.1, 0.07, 0.035, 0.88), Color(0.82, 0.62, 0.32, 0.5)))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    btn.add_theme_color_override("font_color", Color(0.86, 0.74, 0.48, 0.94))
    btn.add_theme_color_override("font_hover_color", Color(0.98, 0.86, 0.58, 1.0))

func _build_timeline_axis() -> VBoxContainer:
    var axis = VBoxContainer.new()
    axis.custom_minimum_size = Vector2(72, 248)
    axis.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    axis.alignment = BoxContainer.ALIGNMENT_CENTER
    axis.add_theme_constant_override("separation", 8)

    axis.add_child(_axis_node("1603"))
    axis.add_child(_axis_line(88))
    axis.add_child(_axis_seal())
    axis.add_child(_axis_line(88))
    axis.add_child(_axis_node("1628"))
    return axis

func _axis_node(text: String) -> PanelContainer:
    var panel = PanelContainer.new()
    panel.custom_minimum_size = Vector2(58, 28)
    panel.add_theme_stylebox_override("panel", _small_panel_style(Color(0.08, 0.065, 0.045, 0.72), Color(0.76, 0.58, 0.26, 0.42)))
    var label = Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _apply_label_font(label, FONT_KAI, 12, Color(0.9, 0.78, 0.49, 0.9))
    panel.add_child(label)
    return panel

func _axis_line(height: int) -> ColorRect:
    var line = ColorRect.new()
    line.color = Color(0.72, 0.53, 0.22, 0.42)
    line.custom_minimum_size = Vector2(1, height)
    line.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    return line

func _axis_seal() -> PanelContainer:
    var seal = PanelContainer.new()
    seal.custom_minimum_size = Vector2(38, 38)
    seal.add_theme_stylebox_override("panel", _small_panel_style(Color(0.36, 0.055, 0.04, 0.72), Color(0.78, 0.51, 0.28, 0.55)))
    var label = Label.new()
    label.text = "履"
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _apply_label_font(label, FONT_TITLE, 20, Color(0.98, 0.86, 0.66, 0.92))
    seal.add_child(label)
    return seal

func _build_timeline_card(id: String, year: String, era: String, sub_era: String, badge: String, desc: String, bg_tex_path: String = "", art_anchor_top: float = 0.35) -> PanelContainer:
    var card = PanelContainer.new()
    var compact: = _is_mobile_portrait()
    card.custom_minimum_size = Vector2(MOBILE_CARD_WIDTH, MOBILE_CARD_HEIGHT) if compact else Vector2(320, 320) * _card_scale
    card.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    card.add_theme_stylebox_override("panel", _card_panel_style(false, selected_timeline == id))
    card.clip_contents = true

    if bg_tex_path != "":
        var bg_tex: Texture2D = load(bg_tex_path) as Texture2D
        if bg_tex == null:
            var img = Image.new()
            var err = img.load(bg_tex_path)
            if err == OK:
                bg_tex = ImageTexture.create_from_image(img)

        if bg_tex:
            var bg_holder = Control.new()
            bg_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
            bg_holder.set_anchors_preset(Control.PRESET_FULL_RECT)
            bg_holder.offset_left = 2
            bg_holder.offset_top = 2
            bg_holder.offset_right = -2
            bg_holder.offset_bottom = -2

            var tex_rect = TextureRect.new()
            tex_rect.name = "TimelineCardArt"
            tex_rect.texture = bg_tex
            tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
            tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
            tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
            tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
            tex_rect.anchor_top = art_anchor_top
            tex_rect.modulate = _timeline_art_modulate(id, selected_timeline == id, false)
            bg_holder.add_child(tex_rect)

            var grad_tex_rect = TextureRect.new()
            grad_tex_rect.name = "TimelineCardShade"
            grad_tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
            grad_tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
            grad_tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

            var grad_tex = GradientTexture2D.new()
            grad_tex.fill_from = Vector2(0, 0)
            grad_tex.fill_to = Vector2(0, 1)
            var grad = Gradient.new()
            grad.set_color(0, Color(0.04, 0.03, 0.02, 1.0))
            grad.set_color(1, Color(0.04, 0.03, 0.02, 0.0))
            grad.add_point(0.3, Color(0.04, 0.03, 0.02, 1.0))
            grad.add_point(0.65, Color(0.04, 0.03, 0.02, 0.5))
            grad_tex.gradient = grad
            grad_tex_rect.texture = grad_tex
            grad_tex_rect.modulate = _timeline_shade_modulate(id, selected_timeline == id, false)
            bg_holder.add_child(grad_tex_rect)

            card.add_child(bg_holder)

    var card_margin = MarginContainer.new()
    var pad_lr = 24 if compact else int(round(30 * _card_scale))
    var pad_tb = 16 if compact else int(round(28 * _card_scale))
    card_margin.add_theme_constant_override("margin_left", pad_lr)
    card_margin.add_theme_constant_override("margin_top", pad_tb)
    card_margin.add_theme_constant_override("margin_right", pad_lr)
    card_margin.add_theme_constant_override("margin_bottom", pad_tb)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 6 if compact else 10)
    vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
    vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL

    var top_vbox = VBoxContainer.new()
    top_vbox.add_theme_constant_override("separation", 4)

    var year_label = Label.new()
    year_label.text = year
    year_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    _apply_label_font(year_label, FONT_KAI, _mobile_font_size(13, MOBILE_TIMELINE_YEAR_FONT_SIZE), Color(0.92, 0.72, 0.36, 0.82))
    top_vbox.add_child(year_label)
    vbox.add_child(top_vbox)

    var era_label = Label.new()
    era_label.text = era
    era_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    _apply_label_font(era_label, FONT_TITLE, _mobile_font_size(34, MOBILE_TIMELINE_ERA_FONT_SIZE), Color(0.96, 0.9, 0.74, 1.0))
    vbox.add_child(era_label)

    var sub_label = Label.new()
    sub_label.text = sub_era
    sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    _apply_label_font(sub_label, FONT_TITLE, _mobile_font_size(24, MOBILE_TIMELINE_SUB_FONT_SIZE), Color(0.82, 0.62, 0.3, 0.96))
    vbox.add_child(sub_label)

    var sep = ColorRect.new()
    sep.color = Color(0.75, 0.56, 0.24, 0.3)
    sep.custom_minimum_size = Vector2(0, 1)
    vbox.add_child(sep)

    var desc_label = Label.new()
    desc_label.text = desc
    desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    _apply_label_font(desc_label, FONT_BODY, _mobile_font_size(13, MOBILE_TIMELINE_DESC_FONT_SIZE), Color(0.82, 0.77, 0.66, 0.94))
    desc_label.add_theme_constant_override("line_spacing", 5)
    vbox.add_child(desc_label)

    var spacer = Control.new()
    spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    vbox.add_child(spacer)

    if badge != "":
        var badge_chip = _build_status_chip(badge)
        badge_chip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
        _disable_timeline_card_child_mouse(badge_chip)
        vbox.add_child(badge_chip)

    card_margin.add_child(vbox)
    _disable_timeline_card_child_mouse(card_margin)
    card.add_child(card_margin)

    var border_overlay = Panel.new()
    border_overlay.name = "TimelineCardBorder"
    border_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    border_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    border_overlay.add_theme_stylebox_override("panel", _card_border_style(false, selected_timeline == id))
    card.add_child(border_overlay)

    card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

    card.gui_input.connect( func(event: InputEvent):
        if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            _select_timeline(id)
            card.accept_event()
        elif event is InputEventScreenTouch and event.pressed:
            _select_timeline(id)
            card.accept_event()
    )

    card.mouse_entered.connect( func():
        if _is_mobile_portrait():
            return
        hovered_timeline = id
        _refresh_timeline_card_styles()
    )
    card.mouse_exited.connect( func():
        if hovered_timeline == id:
            hovered_timeline = ""
        _refresh_timeline_card_styles()
    )

    return card

func _disable_timeline_card_child_mouse(node: Control) -> void :
    node.mouse_filter = Control.MOUSE_FILTER_IGNORE
    for child in node.get_children():
        if child is Control:
            _disable_timeline_card_child_mouse(child)

func _select_timeline(id: String) -> void :
    selected_timeline = id
    if _is_mobile_portrait():
        hovered_timeline = ""
    _refresh_timeline_card_styles()
    _update_confirm_button_state()

func _refresh_timeline_card_styles() -> void :
    if wanli_card:
        _update_card_style(wanli_card, "wanli", hovered_timeline == "wanli")
    if chongzhen_card:
        _update_card_style(chongzhen_card, "chongzhen", hovered_timeline == "chongzhen")
    if chongzhen_17_card:
        _update_card_style(chongzhen_17_card, "chongzhen_17", hovered_timeline == "chongzhen_17")

func _update_confirm_button_state() -> void :
    if confirm_button == null:
        return
    confirm_button.disabled = selected_timeline == "chongzhen_17"

func _update_card_style(card: Control, id: String, hover: bool) -> void :
    var selected = (selected_timeline == id)
    card.add_theme_stylebox_override("panel", _card_panel_style(hover, selected))
    var border = card.find_child("TimelineCardBorder", true, false) as Panel
    if border:
        border.add_theme_stylebox_override("panel", _card_border_style(hover, selected))
    var art = card.find_child("TimelineCardArt", true, false) as TextureRect
    if art:
        art.modulate = _timeline_art_modulate(id, selected, hover)
    var shade = card.find_child("TimelineCardShade", true, false) as TextureRect
    if shade:
        shade.modulate = _timeline_shade_modulate(id, selected, hover)

func _timeline_art_modulate(id: String, selected: bool, hover: bool) -> Color:
    if id == "wanli":
        if selected:
            return Color(1.42, 1.24, 0.96, 1.0)
        if hover:
            return Color(1.2, 1.02, 0.76, 0.88)
        return Color(1.04, 0.86, 0.58, 0.72)
    if selected:
        return Color(1.1, 1.04, 0.92, 1.0)
    if hover:
        return Color(0.98, 0.9, 0.76, 0.76)
    return Color(0.84, 0.72, 0.52, 0.58)

func _timeline_shade_modulate(id: String, selected: bool, hover: bool) -> Color:
    if id == "wanli":
        if selected:
            return Color(1, 1, 1, 0.66)
        if hover:
            return Color(1, 1, 1, 0.76)
        return Color(1, 1, 1, 0.84)
    return Color(1, 1, 1, 1)

func _card_panel_style(hover: bool, selected: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    if selected:
        style.bg_color = Color(0.082, 0.064, 0.043, 0.92)
        style.shadow_color = Color(0.78, 0.52, 0.18, 0.08)
    elif hover:
        style.bg_color = Color(0.058, 0.05, 0.04, 0.88)
        style.shadow_color = Color(0.0, 0.0, 0.0, 0.34)
    else:
        style.bg_color = Color(0.022, 0.022, 0.019, 0.78)
        style.shadow_color = Color(0, 0, 0, 0.3)

    style.border_width_left = 0
    style.border_width_top = 0
    style.border_width_right = 0
    style.border_width_bottom = 0
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    style.shadow_size = 16 if selected else 12
    style.shadow_offset = Vector2(0, 8)
    style.content_margin_left = 0
    style.content_margin_top = 0
    style.content_margin_right = 0
    style.content_margin_bottom = 0
    return style

func _card_border_style(hover: bool, selected: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0, 0, 0, 0)
    if selected:
        style.border_color = Color(0.94, 0.72, 0.34, 0.96)
    elif hover:
        style.border_color = Color(0.72, 0.53, 0.24, 0.7)
    else:
        style.border_color = Color(0.54, 0.4, 0.2, 0.44)
    var border_width = 2 if selected else 1
    style.border_width_left = border_width
    style.border_width_top = border_width
    style.border_width_right = border_width
    style.border_width_bottom = border_width
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    return style

func _small_panel_style(bg: Color, border: Color) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = bg
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = border
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    style.content_margin_left = 8
    style.content_margin_top = 4
    style.content_margin_right = 8
    style.content_margin_bottom = 4
    return style

func _build_status_chip(text: String) -> PanelContainer:
    var chip = PanelContainer.new()
    chip.add_theme_stylebox_override("panel", _small_panel_style(Color(0.16, 0.1, 0.055, 0.64), Color(0.7, 0.48, 0.2, 0.34)))
    var label = Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _apply_label_font(label, FONT_KAI, _mobile_font_size(12, MOBILE_TIMELINE_BADGE_FONT_SIZE), Color(0.86, 0.7, 0.42, 0.88))
    chip.add_child(label)
    return chip

func _style_select_button(btn: Button) -> void :
    btn.add_theme_font_size_override("font_size", MOBILE_ACTION_FONT_SIZE if _is_mobile_portrait() else 16)

    var normal = _button_style(
        Color(0.48, 0.31, 0.13, 0.98), 
        Color(0.95, 0.73, 0.36, 0.48)
    )
    var hover = _button_style(
        Color(0.6, 0.4, 0.18, 1.0), 
        Color(1.0, 0.8, 0.44, 0.68)
    )
    var pressed = _button_style(
        Color(0.35, 0.22, 0.08, 1.0), 
        Color(0.95, 0.72, 0.35, 0.52)
    )
    btn.add_theme_stylebox_override("normal", normal)
    btn.add_theme_stylebox_override("hover", hover)
    btn.add_theme_stylebox_override("pressed", pressed)
    btn.add_theme_stylebox_override("disabled", _button_style(Color(0.15, 0.12, 0.09, 0.72), Color(0.48, 0.39, 0.26, 0.24)))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    btn.add_theme_color_override("font_color", Color(0.98, 0.93, 0.84, 1.0))
    btn.add_theme_color_override("font_hover_color", Color(1.0, 0.96, 0.88, 1.0))
    btn.add_theme_color_override("font_disabled_color", Color(0.62, 0.56, 0.46, 0.72))

func _style_back_button(btn: Button) -> void :
    btn.add_theme_font_size_override("font_size", MOBILE_ACTION_FONT_SIZE if _is_mobile_portrait() else 15)
    btn.add_theme_stylebox_override("normal", _button_style(Color(0.02, 0.018, 0.014, 0.62), Color(0.72, 0.56, 0.28, 0.25)))
    btn.add_theme_stylebox_override("hover", _button_style(Color(0.16, 0.1, 0.05, 0.62), Color(0.8, 0.62, 0.32, 0.42)))
    btn.add_theme_stylebox_override("pressed", _button_style(Color(0.1, 0.07, 0.035, 0.76), Color(0.8, 0.62, 0.32, 0.42)))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

    var norm_color = Color(0.74, 0.64, 0.45, 0.9)
    var hover_color = Color(0.96, 0.84, 0.58, 1.0)
    btn.add_theme_color_override("font_color", norm_color)
    btn.add_theme_color_override("font_hover_color", hover_color)
    btn.add_theme_color_override("font_pressed_color", hover_color)

    btn.icon = load("res://assets/ui/back.svg")
    btn.expand_icon = false
    btn.add_theme_constant_override("h_separation", 6)
    btn.add_theme_color_override("icon_normal_color", norm_color)
    btn.add_theme_color_override("icon_hover_color", hover_color)
    btn.add_theme_color_override("icon_pressed_color", hover_color)
    btn.add_theme_color_override("icon_focus_color", hover_color)

    var fs = btn.get_theme_font_size("font_size")
    if fs <= 0:
        fs = 15
    btn.add_theme_constant_override("icon_max_width", fs)

func _button_style(bg: Color, border: Color) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = bg
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = border
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    style.shadow_size = 6 if GameState.theme == "dark" and bg.a > 0.2 else 0
    style.shadow_color = Color(0, 0, 0, 0.26)
    style.content_margin_left = 18
    style.content_margin_top = 10
    style.content_margin_right = 18
    style.content_margin_bottom = 10
    return style

func _apply_label_font(label: Label, font: Font, size: int, color: Color) -> void :
    label.add_theme_font_override("font", font)
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", color)


func _apply_native_mobile_font_scale() -> void :
    NativeMobileFontScalerRef.apply_to(self)

func _align_mode_button_to_header() -> void :
    if not is_instance_valid(header_label):
        return
    if not header_label.item_rect_changed.is_connected(_do_align):
        header_label.item_rect_changed.connect(_do_align)
    _do_align()

func _do_align() -> void :
    if not is_instance_valid(header_label) or not is_instance_valid(mode_button):
        return



    if header_label.size.y <= 2.0 or header_label.global_position.y <= 1.0:
        return
    var header_center_y = header_label.global_position.y + header_label.size.y / 2.0
    var btn_height = mode_button.size.y
    var target_y = header_center_y - btn_height / 2.0
    mode_button.global_position.y = target_y

    if mode_dropdown and is_instance_valid(mode_dropdown):
        var compact = _is_compact_layout()
        mode_dropdown.global_position.y = target_y + btn_height + (10.0 if compact else 6.0)

        var dd_width = mode_dropdown.custom_minimum_size.x
        mode_dropdown.size = Vector2(dd_width, 0.0)
