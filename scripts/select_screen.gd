extends Control

const ScrollbarThemeRef = preload("res://scripts/ui/scrollbar_theme.gd")
const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const NativeMobileTouchScrollRef = preload("res://scripts/ui/native_mobile_touch_scroll.gd")
const FontLoader = preload("res://scripts/ui/font_loader.gd")
const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")

signal character_selected(char_id: String, selected_traits: Array)
signal back_requested

var FONT_TITLE: Font = FontLoader.title()
var FONT_BODY: Font = FontLoader.body()
var FONT_KAI: Font = FontLoader.body()
var FONT_BOLD: Font = FontLoader.serif_bold()
const TIMELINE_BG: Texture2D = preload("res://assets/choose-bg.webp")
const MOBILE_PORTRAIT_MAX_WIDTH: = 900.0
const MOBILE_ORIGIN_COLUMNS: = 2
const MOBILE_NAV_MIN_HEIGHT: = 420.0
const MOBILE_NAV_FIXED_OVERHEAD: = 300.0
const MOBILE_PAGE_MARGIN: = 32
const MOBILE_HEADER_FONT_SIZE: = 60
const MOBILE_SUBTITLE_FONT_SIZE: = 32
const MOBILE_ORIGIN_ROW_HEIGHT: = 150.0
const MOBILE_ORIGIN_NAME_FONT_SIZE: = 42
const MOBILE_ORIGIN_SUB_FONT_SIZE: = 34
const MOBILE_DETAIL_TITLE_FONT_SIZE: = 62
const MOBILE_DETAIL_SUBTITLE_FONT_SIZE: = 38
const MOBILE_BODY_FONT_SIZE: = 36
const MOBILE_STAT_TITLE_FONT_SIZE: = 41
const MOBILE_STAT_ROW_FONT_SIZE: = 34
const MOBILE_TRAITS_TITLE_FONT_SIZE: = 42
const MOBILE_TRAIT_FONT_SIZE: = 43
const MOBILE_TRAIT_BUTTON_HEIGHT: = 60.0
const MOBILE_BACK_BUTTON_FONT_SIZE: = 34
const MOBILE_START_BUTTON_FONT_SIZE: = 34
const MOBILE_START_BUTTON_HEIGHT: = 74.0
const MOBILE_TRAIT_POPUP_WIDTH_RATIO: = 0.62
const MOBILE_TRAIT_POPUP_MIN_WIDTH: = 520.0
const MOBILE_TRAIT_POPUP_MAX_WIDTH: = 680.0
const MOBILE_TRAIT_POPUP_SCREEN_MARGIN: = 28.0
const MOBILE_TRAIT_POPUP_FONT_SIZE: = 38
const MOBILE_TRAIT_POPUP_LINE_SPACING: = 14
const DESKTOP_TRAIT_POPUP_FONT_SIZE: = 16
const DESKTOP_TRAIT_POPUP_LINE_SPACING: = 8
const DESKTOP_LEFT_NAV_WIDTH: = 292.0
const DESKTOP_DETAIL_MIN_WIDTH: = 760.0
const DESKTOP_STATS_MIN_WIDTH: = 360.0
const DESKTOP_TRAITS_MIN_WIDTH: = 330.0
const MOBILE_DETAIL_MIN_HEIGHT: = 680.0
const MOBILE_STATS_MIN_WIDTH: = 0.0
const MOBILE_TRAITS_MIN_WIDTH: = 0.0

var GOLD: Color:
    get: return GameState.get_theme_color("border_active")
var GOLD_SOFT: Color:
    get: return GameState.get_theme_color("text_main") if GameState.theme == "dark" else Color(0.86, 0.75, 0.48, 1.0)
var GOLD_DIM: Color:
    get: return Color(0.7, 0.6, 0.4, 0.82) if GameState.theme == "dark" else Color(0.58, 0.49, 0.3, 0.82)
var PAPER: Color:
    get: return GameState.get_theme_color("bg_popup")
var PAPER_DIM: Color:
    get: return GameState.get_theme_color("bg_panel_weak")
var INK: Color:
    get: return GameState.get_theme_color("text_desc")
var INK_DEEP: Color:
    get: return GameState.get_theme_color("text_main")
var LINE: Color:
    get: return GameState.get_theme_color("border_weak")
var CINNABAR: Color:
    get: return Color(0.8, 0.3, 0.2, 1.0) if GameState.theme == "dark" else Color(0.67, 0.24, 0.18, 1.0)
var CINNABAR_DIM: Color:
    get: return Color(0.8, 0.3, 0.2, 0.68) if GameState.theme == "dark" else Color(0.72, 0.3, 0.24, 0.68)
const GOOD: = Color(0.52, 0.74, 0.46, 1.0)
const BAD: = Color(0.78, 0.32, 0.28, 1.0)
var MUTED: Color:
    get: return GameState.get_theme_color("text_sub")

const STAT_LABEL_OVERRIDES: = {}

@onready var background: TextureRect = $Background
@onready var overlay: ColorRect = $Overlay
@onready var margin: MarginContainer = $Margin
@onready var main_box: BoxContainer = $Margin / HBox
@onready var left_nav: PanelContainer = $Margin / HBox / LeftNav
@onready var left_vbox: VBoxContainer = $Margin / HBox / LeftNav / VBox
@onready var header: Label = $Margin / HBox / LeftNav / VBox / Header
@onready var header_sub: Label = $Margin / HBox / LeftNav / VBox / HeaderSub
@onready var origin_scroll: ScrollContainer = $Margin / HBox / LeftNav / VBox / OriginScroll
@onready var origin_list: GridContainer = $Margin / HBox / LeftNav / VBox / OriginScroll / OriginList
@onready var back_button: Button = $Margin / HBox / RightContent / FloatingContainer / ActionButtons / BackButton
@onready var right_content: PanelContainer = $Margin / HBox / RightContent
@onready var scroll: ScrollContainer = $Margin / HBox / RightContent / Scroll
@onready var content_vbox: VBoxContainer = $Margin / HBox / RightContent / Scroll / VBox
@onready var origin_name: Label = $Margin / HBox / RightContent / Scroll / VBox / InfoHeader / TitleRow / OriginName
@onready var origin_subtitle: Label = $Margin / HBox / RightContent / Scroll / VBox / InfoHeader / TitleRow / OriginSubtitle
@onready var origin_birthplace: Label = $Margin / HBox / RightContent / Scroll / VBox / InfoHeader / OriginBirthplace
@onready var desc: Label = $Margin / HBox / RightContent / Scroll / VBox / Desc
@onready var title_row: BoxContainer = $Margin / HBox / RightContent / Scroll / VBox / InfoHeader / TitleRow
@onready var bottom_split: BoxContainer = $Margin / HBox / RightContent / Scroll / VBox / BottomSplit
@onready var v_separator: VSeparator = $Margin / HBox / RightContent / Scroll / VBox / BottomSplit / VSeparator
@onready var stats_box: VBoxContainer = $Margin / HBox / RightContent / Scroll / VBox / BottomSplit / LeftCol / StatsBox
@onready var right_col: VBoxContainer = $Margin / HBox / RightContent / Scroll / VBox / BottomSplit / RightCol
@onready var fixed_flow: HFlowContainer = $Margin / HBox / RightContent / Scroll / VBox / BottomSplit / RightCol / TraitsContainer / FixedFlow
@onready var start_button: Button = $Margin / HBox / RightContent / FloatingContainer / ActionButtons / StartButton
@onready var floating_container: Control = $Margin / HBox / RightContent / FloatingContainer

var current_char_id: String = ""
var selected_trait_ids: Array = []
var origin_entries: Dictionary = {}
var scroll_touch_drag_suppress_until_ms: int = 0
var carried_items_section: VBoxContainer
var carried_items_title: Label
var carried_items_flow: HFlowContainer
var hanmen_selected_stage: String = "childhood"

func _ready() -> void :
    GameState.theme_changed.connect(_on_theme_changed)
    resized.connect(_apply_responsive_layout)
    _apply_page_style()
    _apply_tooltip_style()
    _ensure_carried_items_section()
    back_button.pressed.connect( func(): back_requested.emit())
    start_button.pressed.connect(_on_start_pressed)
    _build_origins()

    if origin_list.get_child_count() > 0:
        for child in origin_list.get_children():
            if child is Button and child.has_meta("cid"):
                _select_origin(child.get_meta("cid"))
                break

    _build_trait_popup()
    _apply_responsive_layout()
    _apply_native_mobile_font_scale()

    visibility_changed.connect( func():
        if visible:
            _update_header()
            if current_char_id != "":
                _update_preview()
    )

func _update_header() -> void :
    header.text = "选择出身"
    header_sub.text = ""

func _apply_page_style() -> void :
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

    margin.add_theme_constant_override("margin_left", 52)
    margin.add_theme_constant_override("margin_top", 38)
    margin.add_theme_constant_override("margin_right", 52)
    margin.add_theme_constant_override("margin_bottom", 38)

    left_nav.add_theme_stylebox_override("panel", _panel_style(Color(0.03, 0.028, 0.024, 0.9) if GameState.theme == "dark" else Color(0.1, 0.095, 0.085, 0.95), GameState.get_theme_color("border_weak"), 1, 24, 0, 0))
    right_content.add_theme_stylebox_override("panel", _panel_style(GameState.get_theme_color("bg_popup"), GameState.get_theme_color("border"), 1, 44, 0, 0))
    left_vbox.add_theme_constant_override("separation", 12)
    content_vbox.add_theme_constant_override("separation", 18)
    scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    ScrollbarThemeRef.apply_to(scroll)
    ScrollbarThemeRef.apply_to(origin_scroll)

    $Margin / HBox / RightContent / Scroll / VBox / InfoHeader / TitleRow.add_theme_constant_override("separation", 6)
    $Margin / HBox / RightContent / Scroll / VBox / InfoHeader.add_theme_constant_override("separation", 22)

    _apply_label_font(header, FONT_TITLE, 38, GOLD_SOFT)
    header.add_theme_constant_override("line_spacing", 2)
    _apply_label_font(header_sub, FONT_KAI, 13, GameState.get_theme_color("text_sub"))
    _apply_label_font(origin_name, FONT_TITLE, 38, INK_DEEP)
    _apply_label_font(origin_subtitle, FONT_KAI, 17, CINNABAR)
    _apply_label_font(origin_birthplace, FONT_BODY, 15, INK)
    _apply_label_font(desc, FONT_BODY, 16, INK)
    if GameState.theme == "dark":
        _apply_label_font(origin_subtitle, FONT_KAI, 17, GameState.get_theme_color("border_active"))
        _apply_label_font(origin_birthplace, FONT_BODY, 15, GameState.get_theme_color("text_sub"))
        _apply_label_font(desc, FONT_BODY, 16, GameState.get_theme_color("text_desc"))
    desc.add_theme_constant_override("line_spacing", 10)
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

    var sep = $Margin / HBox / RightContent / Scroll / VBox / HSeparator
    var sep_style = StyleBoxLine.new()
    sep_style.color = GameState.get_theme_color("border_weak")
    sep_style.thickness = 1
    sep.add_theme_stylebox_override("separator", sep_style)

    var v_sep = $Margin / HBox / RightContent / Scroll / VBox / BottomSplit / VSeparator
    var v_sep_style = StyleBoxLine.new()
    v_sep_style.color = GameState.get_theme_color("border_weak")
    v_sep_style.thickness = 1
    v_sep_style.vertical = true
    v_sep.add_theme_stylebox_override("separator", v_sep_style)

    $Margin / HBox / RightContent / Scroll / VBox / BottomSplit.add_theme_constant_override("separation", 38)
    $Margin / HBox / RightContent / Scroll / VBox / BottomSplit / LeftCol.size_flags_stretch_ratio = 0.95
    $Margin / HBox / RightContent / Scroll / VBox / BottomSplit / RightCol.size_flags_stretch_ratio = 1.05

    var traits_label: Label = $Margin / HBox / RightContent / Scroll / VBox / BottomSplit / RightCol / TraitsHeader / Label
    traits_label.text = "角色特质"
    _apply_label_font(traits_label, FONT_KAI, 17, INK_DEEP)
    $Margin / HBox / RightContent / Scroll / VBox / BottomSplit / RightCol / TraitsContainer.add_theme_constant_override("separation", 13)
    if is_instance_valid(carried_items_section):
        carried_items_section.add_theme_constant_override("separation", 13)
    if is_instance_valid(carried_items_title):
        carried_items_title.text = "随身物品"
        _apply_label_font(carried_items_title, FONT_KAI, 17, INK_DEEP)
    fixed_flow.add_theme_constant_override("h_separation", 8)
    fixed_flow.add_theme_constant_override("v_separation", 8)
    if is_instance_valid(carried_items_flow):
        carried_items_flow.add_theme_constant_override("h_separation", 8)
        carried_items_flow.add_theme_constant_override("v_separation", 8)

    _style_start_button()
    _style_back_button()
    _apply_responsive_layout()

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
func _mobile_font_size(desktop_size: int, mobile_size: int) -> int:
    return mobile_size if _is_mobile_portrait() else desktop_size

func _apply_responsive_layout() -> void :
    if not is_instance_valid(margin):
        return
    var mobile_portrait: = _is_mobile_portrait()
    var page_margin: = MOBILE_PAGE_MARGIN if mobile_portrait else 52
    margin.add_theme_constant_override("margin_left", page_margin)
    margin.add_theme_constant_override("margin_top", 32 if mobile_portrait else 38)
    margin.add_theme_constant_override("margin_right", page_margin)
    margin.add_theme_constant_override("margin_bottom", 32 if mobile_portrait else 38)

    main_box.vertical = mobile_portrait
    main_box.add_theme_constant_override("separation", 24 if mobile_portrait else 16)
    if mobile_portrait:
        var num_options = max(1, origin_entries.size())
        var row_count: = ceili(float(num_options) / float(MOBILE_ORIGIN_COLUMNS))
        var list_height = row_count * MOBILE_ORIGIN_ROW_HEIGHT + (row_count - 1) * 8.0
        origin_list.columns = MOBILE_ORIGIN_COLUMNS
        origin_list.add_theme_constant_override("h_separation", 10)
        origin_list.add_theme_constant_override("v_separation", 8)
        var final_nav_h = maxf(MOBILE_NAV_MIN_HEIGHT, list_height + MOBILE_NAV_FIXED_OVERHEAD)
        var final_scroll_h = list_height
        origin_scroll.custom_minimum_size = Vector2(0, final_scroll_h)
        left_nav.custom_minimum_size = Vector2(0, final_nav_h)
        left_nav.size_flags_vertical = Control.SIZE_FILL
    else:
        origin_list.columns = 1
        origin_list.add_theme_constant_override("h_separation", 0)
        origin_list.add_theme_constant_override("v_separation", 8)
        origin_scroll.custom_minimum_size = Vector2(0, 0)
        left_nav.custom_minimum_size = Vector2(DESKTOP_LEFT_NAV_WIDTH, 0)
        left_nav.size_flags_vertical = Control.SIZE_FILL
    right_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    right_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content_vbox.custom_minimum_size.x = 0 if mobile_portrait else DESKTOP_DETAIL_MIN_WIDTH
    scroll.custom_minimum_size = Vector2(0, MOBILE_DETAIL_MIN_HEIGHT) if mobile_portrait else Vector2(DESKTOP_DETAIL_MIN_WIDTH, 0)
    $Margin / HBox / RightContent / Scroll / VBox / BottomSplit / LeftCol.custom_minimum_size.x = MOBILE_STATS_MIN_WIDTH if mobile_portrait else DESKTOP_STATS_MIN_WIDTH
    $Margin / HBox / RightContent / Scroll / VBox / BottomSplit / RightCol.custom_minimum_size.x = MOBILE_TRAITS_MIN_WIDTH if mobile_portrait else DESKTOP_TRAITS_MIN_WIDTH

    bottom_split.vertical = true if mobile_portrait else false
    bottom_split.add_theme_constant_override("separation", 34 if mobile_portrait else 38)
    v_separator.visible = not mobile_portrait
    title_row.vertical = false
    title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    desc.custom_minimum_size.x = 0
    desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    header.add_theme_font_size_override("font_size", MOBILE_HEADER_FONT_SIZE if mobile_portrait else 38)
    header_sub.add_theme_font_size_override("font_size", MOBILE_SUBTITLE_FONT_SIZE if mobile_portrait else 13)
    origin_name.add_theme_font_size_override("font_size", MOBILE_DETAIL_TITLE_FONT_SIZE if mobile_portrait else 38)
    origin_subtitle.add_theme_font_size_override("font_size", MOBILE_DETAIL_SUBTITLE_FONT_SIZE if mobile_portrait else 17)
    origin_birthplace.add_theme_font_size_override("font_size", MOBILE_BODY_FONT_SIZE if mobile_portrait else 15)
    desc.add_theme_font_size_override("font_size", MOBILE_BODY_FONT_SIZE if mobile_portrait else 16)
    desc.add_theme_constant_override("line_spacing", 18 if mobile_portrait else 10)
    var traits_label: Label = $Margin / HBox / RightContent / Scroll / VBox / BottomSplit / RightCol / TraitsHeader / Label
    traits_label.add_theme_font_size_override("font_size", MOBILE_TRAITS_TITLE_FONT_SIZE if mobile_portrait else 17)
    fixed_flow.add_theme_constant_override("h_separation", 16 if mobile_portrait else 8)
    fixed_flow.add_theme_constant_override("v_separation", 16 if mobile_portrait else 8)
    if is_instance_valid(carried_items_title):
        carried_items_title.add_theme_font_size_override("font_size", MOBILE_TRAITS_TITLE_FONT_SIZE if mobile_portrait else 17)
    if is_instance_valid(carried_items_flow):
        carried_items_flow.add_theme_constant_override("h_separation", 16 if mobile_portrait else 8)
        carried_items_flow.add_theme_constant_override("v_separation", 16 if mobile_portrait else 8)

    back_button.custom_minimum_size = Vector2(260 if mobile_portrait else 88, MOBILE_START_BUTTON_HEIGHT if mobile_portrait else 48)
    back_button.add_theme_font_size_override("font_size", MOBILE_BACK_BUTTON_FONT_SIZE if mobile_portrait else 16)
    back_button.add_theme_constant_override("icon_max_width", MOBILE_BACK_BUTTON_FONT_SIZE if mobile_portrait else 16)
    start_button.custom_minimum_size = Vector2(288 if mobile_portrait else 236, MOBILE_START_BUTTON_HEIGHT if mobile_portrait else 48)
    start_button.add_theme_font_size_override("font_size", MOBILE_START_BUTTON_FONT_SIZE if mobile_portrait else 17)
    floating_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    floating_container.set_anchors_preset(Control.PRESET_FULL_RECT)
    floating_container.offset_left = 0
    floating_container.offset_top = 0
    floating_container.offset_right = 0
    floating_container.offset_bottom = 0

    for entry_cid in origin_entries.keys():
        var entry: Dictionary = origin_entries[entry_cid]
        var button: Button = entry.button
        button.custom_minimum_size = Vector2(0, MOBILE_ORIGIN_ROW_HEIGHT) if mobile_portrait else Vector2(0, 78)
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        entry.name.add_theme_font_size_override("font_size", _mobile_font_size(18, MOBILE_ORIGIN_NAME_FONT_SIZE))
        entry.sub.add_theme_font_size_override("font_size", _mobile_font_size(12, MOBILE_ORIGIN_SUB_FONT_SIZE))

    for child in stats_box.get_children():
        if child is Label:
            child.add_theme_font_size_override("font_size", MOBILE_STAT_TITLE_FONT_SIZE if mobile_portrait else 17)
    _apply_native_mobile_font_scale()

func _apply_tooltip_style() -> void :
    var t: Theme = theme if theme else Theme.new()
    theme = t
    t.set_font("font", "TooltipLabel", FONT_BODY)
    t.set_font_size("font_size", "TooltipLabel", 14)
    if GameState.theme == "dark":
        t.set_color("font_color", "TooltipLabel", Color(0.9, 0.84, 0.73, 0.92))
        t.set_stylebox("panel", "TooltipPanel", _panel_style(Color(0.035, 0.029, 0.022, 0.96), Color(0.72, 0.6, 0.34, 0.34), 1, 14, 4))
    else:
        t.set_color("font_color", "TooltipLabel", Color(0.18, 0.16, 0.14, 0.92))
        t.set_stylebox("panel", "TooltipPanel", _panel_style(Color(0.94, 0.93, 0.91, 0.96), Color(0.56, 0.4, 0.16, 0.35), 1, 14, 4))

var trait_popup: PopupPanel
var trait_hover_card: PanelContainer
var trait_popup_opened_by_hover: = false

func _build_trait_popup() -> void :
    if is_instance_valid(trait_popup): trait_popup.queue_free()
    if is_instance_valid(trait_hover_card): trait_hover_card.queue_free()

    var t_style: StyleBoxFlat
    if GameState.theme == "dark":
        t_style = _panel_style(Color(0.06, 0.05, 0.04, 0.98), Color(0.82, 0.68, 0.4, 0.4), 1, 14, 4, 8)
    else:
        t_style = _panel_style(Color(0.94, 0.93, 0.91, 0.98), Color(0.56, 0.4, 0.16, 0.35), 1, 14, 4, 0)


    trait_popup = PopupPanel.new()
    trait_popup.add_theme_stylebox_override("panel", t_style)

    var rtl_popup = RichTextLabel.new()
    rtl_popup.name = "PopupLabel"
    rtl_popup.bbcode_enabled = true
    rtl_popup.fit_content = true
    rtl_popup.scroll_active = false
    rtl_popup.custom_minimum_size = Vector2(280, 0)
    rtl_popup.add_theme_font_override("normal_font", FONT_BODY)
    rtl_popup.add_theme_font_override("bold_font", FONT_BOLD)
    rtl_popup.add_theme_font_size_override("normal_font_size", DESKTOP_TRAIT_POPUP_FONT_SIZE)
    rtl_popup.add_theme_font_size_override("bold_font_size", DESKTOP_TRAIT_POPUP_FONT_SIZE + 2)
    rtl_popup.add_theme_color_override("default_color", GameState.get_theme_color("text_desc"))
    trait_popup.add_child(rtl_popup)
    add_child(trait_popup)


    trait_hover_card = PanelContainer.new()
    trait_hover_card.visible = false
    trait_hover_card.top_level = true
    trait_hover_card.z_index = 100
    trait_hover_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
    trait_hover_card.add_theme_stylebox_override("panel", t_style)

    var rtl_hover = RichTextLabel.new()
    rtl_hover.name = "HoverLabel"
    rtl_hover.bbcode_enabled = true
    rtl_hover.fit_content = true
    rtl_hover.scroll_active = false
    rtl_hover.custom_minimum_size = Vector2(280, 0)
    rtl_hover.add_theme_font_override("normal_font", FONT_BODY)
    rtl_hover.add_theme_font_override("bold_font", FONT_BOLD)
    rtl_hover.add_theme_font_size_override("normal_font_size", DESKTOP_TRAIT_POPUP_FONT_SIZE)
    rtl_hover.add_theme_font_size_override("bold_font_size", DESKTOP_TRAIT_POPUP_FONT_SIZE + 2)
    rtl_hover.add_theme_color_override("default_color", GameState.get_theme_color("text_desc"))
    trait_hover_card.add_child(rtl_hover)
    add_child(trait_hover_card)

func _ensure_carried_items_section() -> void :
    if is_instance_valid(carried_items_section):
        return

    carried_items_section = VBoxContainer.new()
    carried_items_section.name = "CarriedItemsSection"
    carried_items_section.visible = false
    carried_items_section.add_theme_constant_override("separation", 13)
    right_col.add_child(carried_items_section)

    carried_items_title = Label.new()
    carried_items_title.name = "CarriedItemsTitle"
    carried_items_title.text = "随身物品"
    _apply_label_font(carried_items_title, FONT_KAI, 17, INK_DEEP)
    carried_items_section.add_child(carried_items_title)

    carried_items_flow = HFlowContainer.new()
    carried_items_flow.name = "CarriedItemsFlow"
    carried_items_flow.add_theme_constant_override("h_separation", 8)
    carried_items_flow.add_theme_constant_override("v_separation", 8)
    carried_items_section.add_child(carried_items_flow)

func _build_origins() -> void :
    for child in origin_list.get_children():
        child.queue_free()
    origin_entries.clear()

    var cids: Array = []
    var desired_order: = ["hanmen", "shijia", "jinshen", "neiting"]
    for cid in desired_order:
        if GameData.characters.has(cid):
            cids.append(cid)
    for k in GameData.characters.keys():

        if not k in cids and k != "qingwang" and k != "shangjia":
            cids.append(k)

    for cid in cids:
        var ch: Dictionary = GameData.characters[cid]
        var btn: = Button.new()
        btn.mouse_filter = Control.MOUSE_FILTER_PASS
        btn.gui_input.connect(_on_origin_touch_drag)
        btn.text = ""
        btn.custom_minimum_size = Vector2(0, 78)
        btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        btn.focus_mode = Control.FOCUS_NONE
        btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
        btn.add_theme_stylebox_override("normal", _origin_button_style(false, false))
        btn.add_theme_stylebox_override("hover", _origin_button_style(false, true))
        btn.add_theme_stylebox_override("pressed", _origin_button_style(true, true))
        btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
        btn.set_meta("cid", cid)

        var active_line: = ColorRect.new()
        active_line.name = "ActiveLine"
        active_line.color = CINNABAR
        active_line.custom_minimum_size = Vector2(3, 0)
        active_line.set_anchors_preset(Control.PRESET_LEFT_WIDE)
        active_line.offset_right = 3
        active_line.visible = false
        btn.add_child(active_line)

        var box: = VBoxContainer.new()
        box.name = "TextBox"
        box.mouse_filter = Control.MOUSE_FILTER_IGNORE
        box.set_anchors_preset(Control.PRESET_FULL_RECT)
        box.offset_left = 22
        box.offset_top = 12
        box.offset_right = -14
        box.offset_bottom = -10
        box.add_theme_constant_override("separation", 5)

        var name_row: = HBoxContainer.new()
        name_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
        name_row.add_theme_constant_override("separation", 8)
        var name_label: = Label.new()
        name_label.name = "NameLabel"
        name_label.text = ch.get("name", "")
        var init_name_color: = Color(0.65, 0.6, 0.52, 0.85) if GameState.theme == "light" else MUTED
        _apply_label_font(name_label, FONT_KAI, _mobile_font_size(18, MOBILE_ORIGIN_NAME_FONT_SIZE), init_name_color)
        name_row.add_child(name_label)

        var sub_label: = Label.new()
        sub_label.name = "SubLabel"
        sub_label.text = ch.get("subtitle", "")
        var init_sub_color: = Color(0.5, 0.45, 0.36, 0.7) if GameState.theme == "light" else GameState.get_theme_color("text_sub")
        _apply_label_font(sub_label, FONT_BODY, _mobile_font_size(12, MOBILE_ORIGIN_SUB_FONT_SIZE), init_sub_color)
        box.add_child(name_row)
        box.add_child(sub_label)
        btn.add_child(box)

        var id_copy: String = cid
        btn.pressed.connect( func(): _select_origin(id_copy))
        origin_list.add_child(btn)
        origin_entries[cid] = {
            "button": btn, 
            "line": active_line, 
            "name": name_label, 
            "sub": sub_label
        }

func _select_origin(cid: String) -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(self, "scroll_touch_drag_suppress_until_ms"):
        return
    current_char_id = cid
    var ch: Dictionary = GameData.characters[cid]
    for entry_cid in origin_entries.keys():
        var active: bool = entry_cid == cid
        var entry: Dictionary = origin_entries[entry_cid]
        entry.line.visible = active
        entry.button.add_theme_stylebox_override("normal", _origin_button_style(active, false))
        entry.button.add_theme_stylebox_override("hover", _origin_button_style(active, true))

        entry.name.add_theme_font_override("font", FONT_BOLD if active else FONT_KAI)
        var active_name_color: = GOLD_SOFT if GameState.theme == "dark" else INK_DEEP
        var name_color: = active_name_color if active else (Color(0.65, 0.6, 0.52, 0.85) if GameState.theme == "light" else MUTED)
        var sub_color: = GameState.get_theme_color("text_sub") if active else (Color(0.5, 0.45, 0.36, 0.7) if GameState.theme == "light" else GameState.get_theme_color("border_weak"))
        entry.name.add_theme_color_override("font_color", name_color)
        entry.sub.add_theme_color_override("font_color", sub_color)

    origin_name.text = ch.get("name", "")
    origin_subtitle.text = "「%s」" % ch.get("subtitle", "")
    origin_birthplace.text = "出身：%s" % ch.get("birthplace", ch.get("route", ""))
    desc.text = ch.get("desc", "")
    scroll.set_deferred("scroll_vertical", 0)
    _update_header()
    _update_preview()

func _update_preview() -> void :
    if current_char_id == "":
        return

    var ch: Dictionary = GameData.characters[current_char_id]
    var stats_key = "stats"
    var final_stats: Dictionary = ch.get(stats_key, ch.get("stats", {})).duplicate()
    if GameData.character_has_feature(current_char_id, "kuixing"):
        var kuixing_count: = SaveManager.get_kuixing_fu_count()
        if kuixing_count > 0:
            final_stats["wentao"] = clampi(int(final_stats.get("wentao", 0)) + kuixing_count, 0, 100)

    _rebuild_stats(ch, final_stats)
    _rebuild_fixed_traits(ch)
    _rebuild_carried_items()
    _refresh_points_and_button()

func _get_selected_origin_private_silver(ch: Dictionary) -> int:
    return int(ch.get("initial_private_silver", 0))

func _format_select_large_number(val: int) -> String:
    var abs_val = abs(val)
    if abs_val < 10000:
        return str(val)
    var result = "%.1f万" % (float(val) / 10000.0)
    if result.ends_with(".0万"):
        return result.replace(".0万", "万")
    return result

func _rebuild_stats(ch: Dictionary, final_stats: Dictionary) -> void :
    for child in stats_box.get_children():
        child.queue_free()

    var title_hbox: = HBoxContainer.new()
    title_hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
    title_hbox.add_theme_constant_override("separation", 14)
    stats_box.add_child(title_hbox)

    var title: = Label.new()
    title.text = "个人禀赋"
    _apply_label_font(title, FONT_KAI, _mobile_font_size(17, MOBILE_STAT_TITLE_FONT_SIZE), INK_DEEP)
    title_hbox.add_child(title)

    var sub_title: = Label.new()
    sub_title.text = "（童年）"
    _apply_label_font(sub_title, FONT_BODY, _mobile_font_size(14, MOBILE_STAT_ROW_FONT_SIZE), MUTED)
    title_hbox.add_child(sub_title)

    var grid: = VBoxContainer.new()
    grid.add_theme_constant_override("separation", 20 if _is_mobile_portrait() else 13)
    stats_box.add_child(grid)

    for stat_key in GameData.STAT_KEYS:
        var raw_stats_key = "stats"
        var raw_val: int = int(ch.get(raw_stats_key, ch.get("stats", {})).get(stat_key, 0))
        var final_val: int = clampi(int(final_stats.get(stat_key, 0)), 0, 100)
        var is_buffed: = final_val > raw_val
        var is_nerfed: = final_val < raw_val

        var row: = HBoxContainer.new()
        row.add_theme_constant_override("separation", 18 if _is_mobile_portrait() else 12)
        var name_lbl: = Label.new()
        name_lbl.text = _stat_label(stat_key)
        name_lbl.custom_minimum_size.x = 64 if _is_mobile_portrait() else 42
        _apply_label_font(name_lbl, FONT_BODY, _mobile_font_size(15, MOBILE_STAT_ROW_FONT_SIZE), INK)

        var bar: = Panel.new()
        bar.custom_minimum_size = Vector2(260, 14 if _is_mobile_portrait() else 8)
        bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        bar.add_theme_stylebox_override("panel", _meter_bg_style())

        var fill: = Panel.new()
        fill.anchor_bottom = 1.0
        fill.anchor_right = clampf(final_val / 100.0, 0.0, 1.0)
        var fill_col: = GOOD if is_buffed else (BAD if is_nerfed else GOLD_DIM)
        fill.add_theme_stylebox_override("panel", _meter_fill_style(fill_col))
        bar.add_child(fill)

        if is_buffed or is_nerfed:
            var marker: = ColorRect.new()
            marker.color = Color(0.93, 0.88, 0.74, 0.58)
            marker.anchor_left = clampf(raw_val / 100.0, 0.0, 1.0)
            marker.anchor_right = marker.anchor_left
            marker.anchor_bottom = 1.0
            marker.custom_minimum_size.x = 2
            bar.add_child(marker)

        var val_lbl: = Label.new()
        val_lbl.custom_minimum_size.x = 82 if _is_mobile_portrait() else 58
        val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        var delta: = ""
        if is_buffed:
            delta = " +%d" % (final_val - raw_val)
        elif is_nerfed:
            delta = " -%d" % (raw_val - final_val)
        val_lbl.text = "%d%s" % [final_val, delta]
        _apply_label_font(val_lbl, FONT_BODY, _mobile_font_size(14, MOBILE_STAT_ROW_FONT_SIZE), GOOD if is_buffed else (BAD if is_nerfed else INK))

        row.add_child(name_lbl)
        row.add_child(bar)
        row.add_child(val_lbl)
        grid.add_child(row)

func _rebuild_fixed_traits(ch: Dictionary) -> void :
    for child in fixed_flow.get_children():
        child.queue_free()

    for t_def in ch.get("fixed_traits", []):
        var btn: = Button.new()
        btn.mouse_filter = Control.MOUSE_FILTER_PASS
        btn.gui_input.connect(_on_scroll_touch_drag)
        btn.text = t_def.get("name", "")
        btn.focus_mode = Control.FOCUS_NONE
        btn.mouse_default_cursor_shape = Control.CURSOR_ARROW
        btn.add_theme_font_size_override("font_size", _mobile_font_size(14, MOBILE_TRAIT_FONT_SIZE))
        btn.custom_minimum_size = Vector2(0, MOBILE_TRAIT_BUTTON_HEIGHT) if _is_mobile_portrait() else Vector2(0, 0)
        btn.add_theme_stylebox_override("normal", _chip_style(MUTED, 0.09, 0.45))
        btn.add_theme_stylebox_override("hover", _chip_style(MUTED, 0.11, 0.6))
        btn.add_theme_stylebox_override("pressed", _chip_style(MUTED, 0.09, 0.45))
        btn.add_theme_color_override("font_color", INK)
        btn.add_theme_color_override("font_hover_color", INK_DEEP)

        btn.tooltip_text = ""

        var t_desc: String = t_def.get("desc", "")
        btn.mouse_entered.connect( func(): _on_trait_hovered(btn, t_desc))
        btn.mouse_exited.connect( func(): _on_trait_unhovered())
        btn.pressed.connect( func(): _on_trait_clicked(btn, t_desc))

        fixed_flow.add_child(btn)

func _rebuild_carried_items() -> void :
    if not is_instance_valid(carried_items_section) or not is_instance_valid(carried_items_flow):
        return
    for child in carried_items_flow.get_children():
        child.queue_free()

    var ch: Dictionary = GameData.characters.get(current_char_id, {})
    _add_carried_private_silver(ch)

    var kuixing_count: = SaveManager.get_kuixing_fu_count()
    if not GameData.character_has_feature(current_char_id, "kuixing") or kuixing_count <= 0:
        carried_items_section.visible = carried_items_flow.get_child_count() > 0
        return

    var item_def: Dictionary = GameData.ITEM_DEFS.get(SaveManager.KUIXING_FU_ITEM_ID, {})
    if item_def.is_empty():
        carried_items_section.visible = carried_items_flow.get_child_count() > 0
        return

    carried_items_section.visible = true
    var btn: = Button.new()
    btn.mouse_filter = Control.MOUSE_FILTER_PASS
    btn.gui_input.connect(_on_scroll_touch_drag)
    btn.text = "%s ×%d" % [str(item_def.get("name", "魁星符")), kuixing_count]
    btn.focus_mode = Control.FOCUS_NONE
    btn.mouse_default_cursor_shape = Control.CURSOR_ARROW
    btn.add_theme_font_size_override("font_size", _mobile_font_size(14, MOBILE_TRAIT_FONT_SIZE))
    btn.custom_minimum_size = Vector2(0, MOBILE_TRAIT_BUTTON_HEIGHT) if _is_mobile_portrait() else Vector2(0, 0)
    btn.add_theme_stylebox_override("normal", _chip_style(GOLD_DIM, 0.1, 0.52))
    btn.add_theme_stylebox_override("hover", _chip_style(GOLD_DIM, 0.13, 0.7))
    btn.add_theme_stylebox_override("pressed", _chip_style(GOLD_DIM, 0.1, 0.52))
    btn.add_theme_color_override("font_color", INK)
    btn.add_theme_color_override("font_hover_color", INK_DEEP)
    btn.tooltip_text = ""

    var item_desc: = _format_kuixing_item_desc(item_def, kuixing_count)
    btn.mouse_entered.connect( func(): _on_trait_hovered(btn, item_desc))
    btn.mouse_exited.connect( func(): _on_trait_unhovered())
    btn.pressed.connect( func(): _on_trait_clicked(btn, item_desc))
    carried_items_flow.add_child(btn)

func _add_carried_private_silver(ch: Dictionary) -> void :
    if ch.is_empty():
        return
    var private_silver: = _get_selected_origin_private_silver(ch)
    var btn: = Button.new()
    btn.mouse_filter = Control.MOUSE_FILTER_PASS
    btn.gui_input.connect(_on_scroll_touch_drag)
    btn.text = "私银：%s" % _format_select_large_number(private_silver)
    btn.focus_mode = Control.FOCUS_NONE
    btn.mouse_default_cursor_shape = Control.CURSOR_ARROW
    btn.add_theme_font_size_override("font_size", _mobile_font_size(14, MOBILE_TRAIT_FONT_SIZE))
    btn.custom_minimum_size = Vector2(0, MOBILE_TRAIT_BUTTON_HEIGHT) if _is_mobile_portrait() else Vector2(0, 0)
    btn.add_theme_stylebox_override("normal", _chip_style(MUTED, 0.09, 0.45))
    btn.add_theme_stylebox_override("hover", _chip_style(MUTED, 0.11, 0.6))
    btn.add_theme_stylebox_override("pressed", _chip_style(MUTED, 0.09, 0.45))
    btn.add_theme_color_override("font_color", INK)
    btn.add_theme_color_override("font_hover_color", INK_DEEP)
    btn.tooltip_text = ""

    var silver_desc: = "[b]私银[/b]\n得自 私产\n\n天下熙熙，皆为利来。银子不会说话，但它能替你说很多话。\n\n开局携带：%s" % _format_select_large_number(private_silver)
    btn.mouse_entered.connect( func(): _on_trait_hovered(btn, silver_desc))
    btn.mouse_exited.connect( func(): _on_trait_unhovered())
    btn.pressed.connect( func(): _on_trait_clicked(btn, silver_desc))
    carried_items_flow.add_child(btn)

func _format_kuixing_item_desc(item_def: Dictionary, kuixing_count: int) -> String:
    var name: = str(item_def.get("name", "魁星符"))
    var desc_text: = str(item_def.get("desc", "可随身携带的魁星符箓，上面写的是「魁星点斗，独占鳌头」，挂在书袋床头等处皆可。\n[效果：文韬 +1]"))
    return "[b]%s[/b]\n%s\n\n当前持有：%d / %d\n寒门开局加成：文韬 +%d" % [
        name, 
        desc_text, 
        kuixing_count, 
        SaveManager.KUIXING_FU_MAX_COUNT, 
        kuixing_count, 
    ]

func _on_trait_hovered(btn: Button, desc: String) -> void :
    if _is_mobile_portrait():
        _show_trait_popup(desc, true, btn)
        return
    if is_instance_valid(trait_popup) and trait_popup.visible: return
    if not is_instance_valid(trait_hover_card): return
    var rtl = trait_hover_card.get_node("HoverLabel") as RichTextLabel
    rtl.text = desc
    _apply_trait_popup_label_layout(rtl)
    trait_hover_card.size = Vector2.ZERO
    trait_hover_card.reset_size()
    trait_hover_card.global_position = _calc_popup_position(btn, trait_hover_card.size.y)
    trait_hover_card.visible = true

func _on_trait_unhovered() -> void :
    if is_instance_valid(trait_popup) and trait_popup_opened_by_hover:
        trait_popup.hide()
        trait_popup_opened_by_hover = false
    if not is_instance_valid(trait_hover_card): return
    trait_hover_card.visible = false

func _on_trait_clicked(btn: Button, desc: String) -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(self, "scroll_touch_drag_suppress_until_ms"):
        return
    _show_trait_popup(desc, false, btn)

func _calc_popup_position(btn: Button, popup_h: float) -> Vector2:
    var below_y: = btn.global_position.y + btn.size.y + 8
    var vp_h: = get_viewport_rect().size.y
    if below_y + popup_h > vp_h - 16:
        return Vector2(btn.global_position.x, btn.global_position.y - popup_h - 8)
    return Vector2(btn.global_position.x, below_y)

func _show_trait_popup(desc: String, opened_by_hover: bool, btn: Button = null) -> void :
    if not is_instance_valid(trait_popup): return
    if is_instance_valid(trait_hover_card): trait_hover_card.visible = false
    var rtl = trait_popup.get_node("PopupLabel") as RichTextLabel
    rtl.text = desc
    _apply_trait_popup_label_layout(rtl)
    trait_popup.reset_size()
    trait_popup_opened_by_hover = opened_by_hover
    if _is_mobile_portrait():
        var popup_size: = Vector2(_get_mobile_trait_popup_width(), 0)
        var anchor_rect: = Rect2(btn.global_position, btn.size) if btn != null else Rect2(Vector2.ZERO, popup_size)
        trait_popup.popup(_get_trait_popup_anchor_rect(anchor_rect, popup_size.x))
    else:
        rtl.custom_minimum_size = Vector2(280, 0)
        rtl.add_theme_font_size_override("normal_font_size", DESKTOP_TRAIT_POPUP_FONT_SIZE)
        if btn != null:
            var pos: = _calc_popup_position(btn, trait_popup.size.y)
            trait_popup.popup(Rect2(pos.x, pos.y, 0, 0))
        else:
            trait_popup.popup(Rect2(0, 0, 0, 0))

func _refresh_points_and_button() -> void :
    var is_open: = current_char_id == "hanmen"
    start_button.disabled = not is_open
    if not is_open:
        start_button.text = "此出身暂未开放"
    else:
        start_button.text = "定此出身"
func _on_start_pressed() -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(self, "scroll_touch_drag_suppress_until_ms"):
        return
    if current_char_id == "":
        return
    if current_char_id != "hanmen":
        return
    character_selected.emit(current_char_id, selected_trait_ids)

func _stat_label(key: String) -> String:
    return STAT_LABEL_OVERRIDES.get(key, GameData.STAT_LABELS.get(key, key))


func _apply_trait_popup_label_layout(rtl: RichTextLabel) -> void :
    if _is_mobile_portrait():
        rtl.custom_minimum_size = Vector2(_get_mobile_trait_popup_width(), 0)
        rtl.add_theme_font_size_override("normal_font_size", MOBILE_TRAIT_POPUP_FONT_SIZE)
        rtl.add_theme_font_size_override("bold_font_size", MOBILE_TRAIT_POPUP_FONT_SIZE + 2)
    else:
        rtl.custom_minimum_size = Vector2(280, 0)
        rtl.add_theme_font_size_override("normal_font_size", DESKTOP_TRAIT_POPUP_FONT_SIZE)
        rtl.add_theme_font_size_override("bold_font_size", DESKTOP_TRAIT_POPUP_FONT_SIZE + 2)


func _get_mobile_trait_popup_width() -> float:
    var viewport_w: = get_viewport_rect().size.x
    var max_safe_width: = maxf(240.0, viewport_w - MOBILE_TRAIT_POPUP_SCREEN_MARGIN * 2.0)
    var desired_width: = clampf(viewport_w * MOBILE_TRAIT_POPUP_WIDTH_RATIO, MOBILE_TRAIT_POPUP_MIN_WIDTH, MOBILE_TRAIT_POPUP_MAX_WIDTH)
    return minf(desired_width, max_safe_width)


func _get_trait_popup_anchor_rect(anchor_rect: Rect2, popup_width: float) -> Rect2:
    var viewport_size: = get_viewport_rect().size
    var x: = anchor_rect.position.x + (anchor_rect.size.x - popup_width) * 0.5
    x = clampf(x, MOBILE_TRAIT_POPUP_SCREEN_MARGIN, viewport_size.x - popup_width - MOBILE_TRAIT_POPUP_SCREEN_MARGIN)

    var popup_height_estimate: = 160.0
    var above_y: = anchor_rect.position.y - popup_height_estimate - 10.0
    var below_y: = anchor_rect.end.y + 10.0
    var y: float
    if _is_mobile_portrait():

        if below_y + popup_height_estimate < viewport_size.y - MOBILE_TRAIT_POPUP_SCREEN_MARGIN:
            y = below_y
        elif above_y >= MOBILE_TRAIT_POPUP_SCREEN_MARGIN:
            y = above_y
        else:
            y = below_y
    else:

        if above_y >= MOBILE_TRAIT_POPUP_SCREEN_MARGIN:
            y = above_y
        else:
            y = below_y
    return Rect2(Vector2(x, y), Vector2(popup_width, 0))


func _on_scroll_touch_drag(event: InputEvent) -> void :
    NativeMobileTouchScrollRef.forward_drag_to_scroll(event, scroll, self, "scroll_touch_drag_suppress_until_ms")

func _on_origin_touch_drag(event: InputEvent) -> void :
    NativeMobileTouchScrollRef.forward_drag_to_scroll(event, origin_scroll, self, "scroll_touch_drag_suppress_until_ms")

func _apply_label_font(label: Label, font: Font, size: int, color: Color) -> void :
    label.add_theme_font_override("font", font)
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", color)


func _apply_native_mobile_font_scale() -> void :
    NativeMobileFontScalerRef.apply_to(self)

func _panel_style(bg: Color, border: Color, border_width: int, pad: int, radius: int, shadow_sz: int = 0) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = bg
    style.border_width_left = border_width
    style.border_width_top = border_width
    style.border_width_right = border_width
    style.border_width_bottom = border_width
    style.border_color = border
    style.corner_radius_top_left = radius
    style.corner_radius_top_right = radius
    style.corner_radius_bottom_left = radius
    style.corner_radius_bottom_right = radius
    style.content_margin_left = pad
    style.content_margin_top = pad
    style.content_margin_right = pad
    style.content_margin_bottom = pad
    style.shadow_color = Color(0, 0, 0, 0.26)
    style.shadow_size = shadow_sz
    return style

func _origin_button_style(active: bool, hover: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = GameState.get_theme_color("bg_panel") if active else (GameState.get_theme_color("bg_panel_weak") if hover else Color(0, 0, 0, 0))
    if GameState.theme == "light":
        var p: = GameState.get_theme_color("bg_panel")
        if active:

            style.bg_color = Color(p.r, p.g, p.b, 0.72)
        elif hover:

            style.bg_color = Color(p.r, p.g, p.b, 0.1)
    if GameState.theme == "dark" and active:
        style.bg_color = Color(0.095, 0.074, 0.05, 0.9)
    style.border_width_left = 2 if active else 0
    style.border_width_bottom = 1
    style.border_color = Color(0.82, 0.68, 0.4, 0.28 if active else 0.14)
    style.content_margin_left = 0
    style.content_margin_right = 0
    style.content_margin_top = 0
    style.content_margin_bottom = 0
    return style

func _chip_style(col: Color, fill_alpha: float, border_alpha: float) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    var mobile_portrait: = _is_mobile_portrait()
    var actual_fill: = fill_alpha * (0.78 if GameState.theme == "dark" else 1.0)
    style.bg_color = Color(col.r, col.g, col.b, actual_fill)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = Color(col.r, col.g, col.b, border_alpha)
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    style.content_margin_left = 14 if mobile_portrait else 12
    style.content_margin_top = 8 if mobile_portrait else 6
    style.content_margin_right = 14 if mobile_portrait else 12
    style.content_margin_bottom = 8 if mobile_portrait else 6
    return style

func _label_chip_style(col: Color, fill_alpha: float, border_alpha: float) -> StyleBoxFlat:
    var style: = _chip_style(col, fill_alpha, border_alpha)
    style.content_margin_left = 10
    style.content_margin_right = 10
    style.content_margin_top = 4
    style.content_margin_bottom = 4
    return style

func _meter_bg_style() -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0.18, 0.16, 0.13, 0.62) if GameState.theme == "dark" else Color(0.85, 0.81, 0.72, 0.6)
    style.border_width_bottom = 1
    style.border_color = Color(0.78, 0.61, 0.32, 0.18)
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    return style

func _meter_fill_style(col: Color) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = col.darkened(0.08) if GameState.theme == "dark" else col
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    return style

func _style_start_button() -> void :
    start_button.add_theme_font_size_override("font_size", 17)
    GameScreenStyleFactory.apply_command_button_style(start_button, "primary", 18, 8)

func _style_back_button() -> void :
    back_button.add_theme_stylebox_override("normal", _button_style(Color(0.02, 0.018, 0.014, 0.62), Color(0.72, 0.56, 0.28, 0.25)))
    back_button.add_theme_stylebox_override("hover", _button_style(Color(0.16, 0.1, 0.05, 0.62), Color(0.8, 0.62, 0.32, 0.42)))
    back_button.add_theme_stylebox_override("pressed", _button_style(Color(0.1, 0.07, 0.035, 0.76), Color(0.8, 0.62, 0.32, 0.42)))
    back_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

    var norm_color = Color(0.74, 0.64, 0.45, 0.9)
    var hover_color = Color(0.96, 0.84, 0.58, 1.0)
    back_button.add_theme_color_override("font_color", norm_color)
    back_button.add_theme_color_override("font_hover_color", hover_color)
    back_button.add_theme_color_override("font_pressed_color", hover_color)

    back_button.icon = load("res://assets/ui/back.svg")
    back_button.expand_icon = false
    back_button.add_theme_constant_override("h_separation", 6)
    back_button.add_theme_color_override("icon_normal_color", norm_color)
    back_button.add_theme_color_override("icon_hover_color", hover_color)
    back_button.add_theme_color_override("icon_pressed_color", hover_color)
    back_button.add_theme_color_override("icon_focus_color", hover_color)

    var fs = back_button.get_theme_font_size("font_size")
    if fs <= 0:
        fs = 18
    back_button.add_theme_constant_override("icon_max_width", fs)

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

func _on_theme_changed(_theme: String) -> void :
    if not is_inside_tree(): return
    _apply_page_style()
    _build_origins()
    if current_char_id != "":
        _select_origin(current_char_id)
