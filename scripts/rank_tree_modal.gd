extends Control

const ScrollbarThemeRef = preload("res://scripts/ui/scrollbar_theme.gd")
const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const FontLoader = preload("res://scripts/ui/font_loader.gd")
const PortraitBacking = preload("res://scripts/ui/portrait_backing.gd")


const PLAYER_RANK_PORTRAIT_MAP: = {
    "七品": "res://assets/portraits/hanmen_rank7.webp", 
    "六品": "res://assets/portraits/hanmen_rank6.webp", 
    "五品": "res://assets/portraits/hanmen_rank5.webp", 
    "四品": "res://assets/portraits/hanmen_rank4.webp", 
    "三品": "res://assets/portraits/hanmen_rank3.webp", 
    "二品": "res://assets/portraits/hanmen_rank2.webp", 
    "一品": "res://assets/portraits/hanmen_rank2.webp"
}

const CHARACTER_FIXED_RANK_PORTRAIT: = {
    "shijia": "res://assets/portraits/junguan.webp"
}
const PORTRAIT_HEIGHT_RATIO: = 0.86

const CAREER_PATHS: = {
    "地方线": {"label": "地方线", "char": "寒门", "desc": "地方文官正途，自知县历升至布政使。注：明代【巡抚】与【总督】本为差遣无定品，其品阶依所加部院衔（如都御史、兵部尚书）及荣誉衔（如太子太保）而定。", "ranks": [
        {"rank": "正七品", "title": "知县"}, {"rank": "正六品", "title": "通判"}, 
        {"rank": "从五品", "title": "知州"}, {"rank": "正五品", "title": "同知"}, 
        {"rank": "正五品", "title": "按察佥事"}, {"rank": "正四品", "title": "知府"}, 
        {"rank": "正四品", "title": "按察副使"}, {"rank": "正三品", "title": "按察使"}, 
        {"rank": "从二品", "title": "布政使"}, {"rank": "正二品", "title": "巡抚(右都御史衔)"}, 
        {"rank": "从一品", "title": "总督(加太子太保)"}
    ]}, 
    "户部线": {"label": "户部线", "char": "缙绅", "desc": "京官部寺正途，自户部主事入仕，历员外郎、郎中，迁太仆寺少卿、侍郎、尚书，至太子少保、大学士入阁。", "ranks": [
        {"rank": "正六品", "title": "户部主事"}, {"rank": "从五品", "title": "员外郎"}, 
        {"rank": "正五品", "title": "郎中"}, {"rank": "正四品", "title": "太仆寺少卿"}, 
        {"rank": "正三品", "title": "户部侍郎"}, {"rank": "正二品", "title": "户部尚书"}, 
        {"rank": "从一品", "title": "太子少保"}, {"rank": "正一品", "title": "大学士(加太师)"}
    ]}, 
    "边务线": {"label": "边务线", "char": "没落世家", "desc": "武官勋阶正途，自百户起步，历千户、守备、指挥使，升都指挥同知、副总兵、总兵，至左都督统帅三军。", "ranks": [
        {"rank": "正六品", "title": "百户"}, {"rank": "正五品", "title": "千户"}, 
        {"rank": "正四品", "title": "守备(指挥佥事衔)"}, {"rank": "正三品", "title": "指挥使"}, 
        {"rank": "从二品", "title": "都指挥同知"}, {"rank": "正二品", "title": "副总兵(都督佥事衔)"}, 
        {"rank": "从一品", "title": "总兵(都督同知衔)"}, {"rank": "正一品", "title": "左都督"}
    ]}, 
    "言路线": {"label": "言路线", "char": "诗文清望", "desc": "台谏言路正途，自给事中或监察御史入仕，升佥都御史、太常寺少卿，至副都御史、左都御史、大学士。注：明制佥都御史实为正四品，左都御史为正二品。", "ranks": [
        {"rank": "从七品", "title": "给事中"}, {"rank": "正七品", "title": "监察御史"}, 
        {"rank": "正四品", "title": "太常寺少卿"}, {"rank": "正四品", "title": "佥都御史"}, 
        {"rank": "正三品", "title": "副都御史"}, {"rank": "正二品", "title": "左都御史"}, 
        {"rank": "从一品", "title": "左都御史(加太子少保)"}, {"rank": "正一品", "title": "大学士(加太师)"}
    ]}, 
    "内廷线": {"label": "内廷线", "char": "游民", "desc": "内廷宦官晋身之路。据《明史·职官志》，二十四衙门设十二监、四司、八局。宦官法定最高品秩为正四品太监，但司礼监掌印太监掌批红之权，实际权势可凌驾外朝。", "ranks": [
        {"rank": "无品", "title": "火者"}, {"rank": "从六品", "title": "奉御"}, 
        {"rank": "正六品", "title": "典簿"}, {"rank": "从五品", "title": "司副"}, 
        {"rank": "正五品", "title": "监丞"}, {"rank": "从四品", "title": "少监"}, 
        {"rank": "正四品", "title": "太监"}, {"rank": "正四品", "title": "随堂太监"}, 
        {"rank": "正四品", "title": "秉笔太监"}, {"rank": "正四品", "title": "提督东厂"}, 
        {"rank": "正四品", "title": "掌印太监"}
    ]}
}

const KEJU_PATHS: = {
    "科举线": {"label": "科举线", "desc": "大明科举流程，士子进阶之路。历经县试、府试成为童生，再经院试、乡试、会试、殿试，至考取进士，方为入仕正途。", "ranks": [
        {"rank": "启蒙", "title": "平民"}, 
        {"rank": "县试/府试", "title": "童生"}, 
        {"rank": "院试", "title": "秀才"}, 
        {"rank": "乡试", "title": "举人"}, 
        {"rank": "会试", "title": "贡士"}, 
        {"rank": "殿试", "title": "进士"}
    ]}
}

const PATH_ORDER: = ["地方线", "边务线", "户部线", "内廷线"]
const KEJU_PATH_ORDER: = ["科举线"]
const MOBILE_PORTRAIT_MAX_WIDTH: = 900.0
const MOBILE_PANEL_WIDTH_RATIO: = 0.96
const MOBILE_PANEL_HEIGHT_RATIO: = 0.78
const MOBILE_TITLE_FONT_SIZE: = 67
const MOBILE_SUBTITLE_FONT_SIZE: = 34
const MOBILE_CELL_FONT_SIZE: = 38
const MOBILE_RANK_FONT_SIZE: = 34
const MOBILE_LEGEND_FONT_SIZE: = 31
const MOBILE_CLOSE_FONT_SIZE: = 43
const MOBILE_CLOSE_BUTTON_HEIGHT: = 74.0
const TOP_MODAL_Z_INDEX: = 1000

@onready var overlay: ColorRect = $Overlay
@onready var panel: PanelContainer = $Panel
@onready var margin: MarginContainer = $Panel / Margin
@onready var title_label: Label = $Panel / Margin / VBox / Title
@onready var subtitle_label: Label = $Panel / Margin / VBox / Subtitle
@onready var route_hint: Label = $Panel / Margin / VBox / RouteHint
@onready var vbox: VBoxContainer = $Panel / Margin / VBox
@onready var tab_bar: HBoxContainer = $Panel / Margin / VBox / TabBar
@onready var content_scroll: ScrollContainer = $Panel / Margin / VBox / ContentScroll
@onready var content_vbox: VBoxContainer = $Panel / Margin / VBox / ContentScroll / ContentMargin / ContentVBox
@onready var legend: HBoxContainer = $Panel / Margin / VBox / Legend
@onready var close_button: Button = $Panel / Margin / VBox / CloseButton

var _active_tab: String = ""
var _tab_buttons: Dictionary = {}
var _current_mode: String = "career"
var _portrait_rect: TextureRect = null
var _portrait_badge: PanelContainer = null
var _portrait_identity_label: Label = null

func _ready() -> void :
    call_deferred("_raise_to_top_modal_layer")
    overlay.gui_input.connect(_on_overlay_gui_input)
    close_button.pressed.connect(close_modal)
    visible = false
    _ensure_portrait_nodes()
    _apply_styles()
    resized.connect(_apply_responsive_layout)

func _raise_to_top_modal_layer() -> void :
    z_as_relative = false
    z_index = TOP_MODAL_Z_INDEX
    move_to_front()

func open_modal() -> void :
    _raise_to_top_modal_layer()
    visible = true
    _apply_styles()

    if _should_show_keju_path():
        _current_mode = "keju"
    else:
        _current_mode = "career"

    if _current_mode == "keju":
        title_label.text = "大 明 科 举 流 程"
        subtitle_label.text = "科举晋身之路一览"
        _active_tab = "科举线"
    else:
        title_label.text = "明 末 仕 途 表"
        subtitle_label.text = "大明官制品秩一览"
        var player_route: String = GameState.route
        _active_tab = player_route if (CAREER_PATHS.has(player_route) and player_route in PATH_ORDER) else PATH_ORDER[0]

    _build_tabs()
    _build_path_content(_active_tab)
    _refresh_player_portrait()
    _apply_native_mobile_font_scale()

func _should_show_keju_path() -> bool:
    return GameState.get_display_identity() != GameState.get_rank_title()

func close_modal() -> void :
    visible = false

func _on_overlay_gui_input(event: InputEvent) -> void :
    if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed):
        call_deferred("close_modal")

func _switch_tab(path_key: String) -> void :
    if path_key == _active_tab:
        return
    _active_tab = path_key
    _update_tab_styles()
    _build_path_content(path_key)
    _apply_native_mobile_font_scale()

func _build_tabs() -> void :
    for child in tab_bar.get_children():
        child.queue_free()
    _tab_buttons.clear()

    if _current_mode == "keju":
        tab_bar.visible = false
        return

    tab_bar.visible = true
    var order = PATH_ORDER
    var paths = CAREER_PATHS

    for path_key in order:
        var btn: = Button.new()
        btn.text = paths[path_key]["label"]
        btn.add_theme_font_size_override("font_size", _mobile_value(12, MOBILE_RANK_FONT_SIZE))
        btn.custom_minimum_size = Vector2(_mobile_value(90, 160), _mobile_value(30, 56))
        btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
        btn.mouse_filter = Control.MOUSE_FILTER_PASS
        var key: String = path_key
        btn.pressed.connect( func(): _switch_tab(key))
        tab_bar.add_child(btn)
        _tab_buttons[path_key] = btn
    _update_tab_styles()

func _update_tab_styles() -> void :
    var player_route: String = GameState.route
    for path_key in _tab_buttons:
        var btn: Button = _tab_buttons[path_key]
        var is_active: bool = path_key == _active_tab
        var is_player: bool = path_key == player_route
        btn.add_theme_stylebox_override("normal", _make_tab_style(is_active, false, is_player))
        btn.add_theme_stylebox_override("hover", _make_tab_style(is_active, true, is_player))
        btn.add_theme_stylebox_override("pressed", _make_tab_style(is_active, true, is_player))
        var color: Color
        if is_active:
            color = GameState.get_theme_color("border_active")
        elif is_player:
            color = Color(GameState.get_theme_color("border_active"), 0.7)
        else:
            color = GameState.get_theme_color("text_sub")
        btn.add_theme_color_override("font_color", color)
        btn.add_theme_color_override("font_hover_color", color)
        btn.add_theme_color_override("font_pressed_color", color)

func _build_path_content(path_key: String) -> void :
    for child in content_vbox.get_children():
        child.queue_free()
    for child in legend.get_children():
        child.queue_free()

    var paths = KEJU_PATHS if _current_mode == "keju" else CAREER_PATHS
    var path_info: Dictionary = paths[path_key]
    var ranks: Array = path_info["ranks"]


    var desc_label: = Label.new()
    desc_label.text = path_info.get("desc", "")
    desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    desc_label.add_theme_font_size_override("font_size", _mobile_value(11, 26))
    desc_label.add_theme_color_override("font_color", Color(GameState.get_theme_color("text_sub"), 0.72))
    content_vbox.add_child(desc_label)


    var spacer: = Control.new()
    spacer.custom_minimum_size = Vector2(0, _mobile_value(4, 8))
    content_vbox.add_child(spacer)


    var player_route: String = GameState.route
    var is_official: bool = (GameState.get_display_identity() == GameState.get_rank_title())
    var current_rank: String = GameState.get_rank_title() if is_official else ""
    var current_title: = ""
    if "·" in current_rank:
        current_title = current_rank.split("·", false, 1)[1]

    var player_path_ranks: Array = []
    var player_current_idx: = -1

    if _current_mode == "keju":
        var keju_to_idx = {
            "none": 0, "tongshi_prep": 0, 
            "tongshi": 1, 
            "xiucai": 2, 
            "juren": 3, 
            "gongshi": 4, 
            "jinshi": 5, "sanjia": 5, "erjia": 5, "tanhua": 5, "bangyan": 5, "zhuangyuan": 5
        }
        player_current_idx = keju_to_idx.get(GameState.keju_status, 0)
        player_path_ranks = ranks
    else:
        if path_key == player_route and CAREER_PATHS.has(player_route):
            player_path_ranks = CAREER_PATHS[player_route]["ranks"]
            for idx in range(player_path_ranks.size()):
                if player_path_ranks[idx]["title"] == current_title:
                    player_current_idx = idx
                    break
            if player_current_idx < 0 and "·" in current_rank:
                var current_pin = current_rank.split("·", false, 1)[0]
                for idx in range(player_path_ranks.size()):
                    if player_path_ranks[idx]["rank"] == current_pin:
                        player_current_idx = idx
                        break


    var reversed_ranks: Array = ranks.duplicate()
    reversed_ranks.reverse()
    var current_row: Control = null
    for entry in reversed_ranks:
        var is_active_path: bool = (_current_mode == "keju") or (path_key == player_route)
        var state: String = "on_path"
        if is_active_path and not player_path_ranks.is_empty():
            var rank_idx: int = player_path_ranks.find(entry)
            if rank_idx == player_current_idx:
                state = "current"
            elif rank_idx >= 0 and rank_idx < player_current_idx:
                state = "reached"
            elif rank_idx > player_current_idx:
                state = "on_path"

        var row: = PanelContainer.new()
        row.custom_minimum_size = Vector2(0, _mobile_value(42, 72))
        row.add_theme_stylebox_override("panel", _make_cell_style(state))
        row.mouse_filter = Control.MOUSE_FILTER_PASS

        var hbox: = HBoxContainer.new()
        hbox.add_theme_constant_override("separation", _mobile_value(16, 28))
        hbox.alignment = BoxContainer.ALIGNMENT_CENTER
        row.add_child(hbox)

        var rank_lbl: = Label.new()
        rank_lbl.text = entry["rank"]
        rank_lbl.custom_minimum_size = Vector2(_mobile_value(60, 110), 0)
        rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        rank_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        rank_lbl.add_theme_font_size_override("font_size", _mobile_value(12, MOBILE_RANK_FONT_SIZE))
        rank_lbl.add_theme_color_override("font_color", Color(GameState.get_theme_color("text_sub"), 0.72))
        hbox.add_child(rank_lbl)

        var sep: = VSeparator.new()
        sep.custom_minimum_size = Vector2(1, 0)
        sep.add_theme_stylebox_override("separator", StyleBoxEmpty.new())
        hbox.add_child(sep)

        var title_lbl: = Label.new()
        title_lbl.text = entry["title"]
        title_lbl.custom_minimum_size = Vector2(_mobile_value(120, 200), 0)
        title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        title_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        title_lbl.add_theme_font_size_override("font_size", _mobile_value(14, MOBILE_CELL_FONT_SIZE))
        title_lbl.add_theme_color_override("font_color", _cell_title_color(state))
        hbox.add_child(title_lbl)

        content_vbox.add_child(row)
        if state == "current":
            current_row = row


    if path_key == "内廷线":
        route_hint.text = "注：明制宦官法定品秩止于正四品。秉笔太监、提督东厂等皆无定品，其权势源于皇帝信任而非官阶高低。"
        route_hint.visible = true
    else:
        route_hint.visible = false

    _apply_native_mobile_font_scale()
    if current_row:
        _scroll_to_row(current_row)

func _add_legend_item(text: String, state: String) -> void :
    var row = HBoxContainer.new()
    row.add_theme_constant_override("separation", 6)
    var swatch = ColorRect.new()
    swatch.custom_minimum_size = Vector2(10, 10)
    swatch.color = _legend_color(state)
    row.add_child(swatch)
    var label = Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", _mobile_value(11, MOBILE_LEGEND_FONT_SIZE))
    label.add_theme_color_override("font_color", Color(GameState.get_theme_color("text_sub"), 0.62))
    row.add_child(label)
    legend.add_child(row)

func _apply_styles() -> void :
    _apply_responsive_layout()
    overlay.color = Color(0, 0, 0, 0.66) if GameState.theme == "dark" else Color(0.95, 0.92, 0.86, 0.36)
    panel.add_theme_stylebox_override("panel", _make_modal_panel_style())
    close_button.add_theme_font_size_override("font_size", _mobile_value(15, MOBILE_CLOSE_FONT_SIZE))
    close_button.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    close_button.add_theme_stylebox_override("normal", _make_close_button_style(false))
    close_button.add_theme_stylebox_override("hover", _make_close_button_style(true))
    close_button.add_theme_stylebox_override("pressed", _make_close_button_style(true, true))
    close_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    title_label.add_theme_font_override("font", FontLoader.title())
    title_label.add_theme_font_size_override("font_size", _mobile_value(28, MOBILE_TITLE_FONT_SIZE))
    title_label.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    subtitle_label.add_theme_font_size_override("font_size", _mobile_value(12, MOBILE_SUBTITLE_FONT_SIZE))
    subtitle_label.add_theme_color_override("font_color", Color(GameState.get_theme_color("text_sub"), 0.56))
    route_hint.add_theme_font_size_override("font_size", _mobile_value(11, 26))
    route_hint.add_theme_color_override("font_color", Color(0.82, 0.58, 0.44, 0.76))
    ScrollbarThemeRef.apply_to(content_scroll)

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
func _mobile_value(desktop_value: int, mobile_value: int) -> int:
    return mobile_value if _is_mobile_portrait() else desktop_value

func _apply_responsive_layout() -> void :



    var viewport_size: = size
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
        viewport_size = get_viewport_rect().size
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
        return
    if NativeMobileFontScalerRef.is_native_mobile_landscape(self):

        var half_w: float = viewport_size.x * 0.4
        var half_h: float = viewport_size.y * 0.46
        panel.offset_left = - half_w
        panel.offset_right = half_w
        panel.offset_top = - half_h
        panel.offset_bottom = half_h
        vbox.add_theme_constant_override("separation", 14)
        tab_bar.add_theme_constant_override("separation", 4)
        legend.add_theme_constant_override("separation", 18)
        close_button.custom_minimum_size = Vector2(160.0, 40.0)
    else:
        panel.offset_left = -340.0
        panel.offset_right = 340.0
        panel.offset_top = -280.0
        panel.offset_bottom = 280.0
        vbox.add_theme_constant_override("separation", 14)
        tab_bar.add_theme_constant_override("separation", 4)
        legend.add_theme_constant_override("separation", 18)
        close_button.custom_minimum_size = Vector2(160.0, 40.0)
    _layout_portrait()
    _apply_native_mobile_font_scale()




func _ensure_portrait_nodes() -> void :
    if is_instance_valid(_portrait_rect):
        return

    _portrait_rect = TextureRect.new()
    _portrait_rect.name = "PlayerRankPortrait"
    _portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _portrait_rect.stretch_mode = TextureRect.STRETCH_SCALE
    _portrait_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _portrait_rect.material = PortraitBacking.make_tone_material()
    _portrait_rect.visible = false
    add_child(_portrait_rect)


    _portrait_badge = PanelContainer.new()
    _portrait_badge.name = "PlayerSpeakerBadge"
    _portrait_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _portrait_badge.add_theme_stylebox_override("panel", _make_badge_style())
    _portrait_badge.visible = false
    add_child(_portrait_badge)

    var hbox: = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 12)
    hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _portrait_badge.add_child(hbox)

    var avatar: = Label.new()
    avatar.text = "你"
    avatar.custom_minimum_size = Vector2(46, 46)
    avatar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    avatar.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    avatar.add_theme_font_override("font", FontLoader.serif_bold())
    avatar.add_theme_font_size_override("font_size", 18)
    avatar.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    avatar.add_theme_stylebox_override("normal", _make_avatar_circle_style())
    hbox.add_child(avatar)

    var vbox_txt: = VBoxContainer.new()
    vbox_txt.alignment = BoxContainer.ALIGNMENT_CENTER
    vbox_txt.add_theme_constant_override("separation", 2)
    vbox_txt.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hbox.add_child(vbox_txt)

    var name_lbl: = Label.new()
    name_lbl.text = "你"
    name_lbl.add_theme_font_override("font", FontLoader.serif_bold())
    name_lbl.add_theme_font_size_override("font_size", 18)
    name_lbl.add_theme_color_override("font_color", Color(0.92, 0.86, 0.74))
    vbox_txt.add_child(name_lbl)

    _portrait_identity_label = Label.new()
    _portrait_identity_label.add_theme_font_override("font", FontLoader.body())
    _portrait_identity_label.add_theme_font_size_override("font_size", 13)
    _portrait_identity_label.add_theme_color_override("font_color", Color(GameState.get_theme_color("text_sub"), 0.85))
    vbox_txt.add_child(_portrait_identity_label)

func _refresh_player_portrait() -> void :
    _ensure_portrait_nodes()
    if _current_mode != "career":
        _portrait_rect.visible = false
        _portrait_badge.visible = false
        return
    var path: = _player_rank_portrait_path()
    var show_portrait: = path != "" and not _is_mobile_portrait()
    _portrait_rect.visible = show_portrait
    _portrait_badge.visible = show_portrait
    if not show_portrait:
        return
    _portrait_rect.texture = load(path)
    if is_instance_valid(_portrait_identity_label):
        _portrait_identity_label.text = _player_identity_label()

    _portrait_badge.add_theme_stylebox_override("panel", _make_badge_style())
    _layout_portrait()

func _player_rank_portrait_path() -> String:
    if not GameState.has_feature("rank_portrait"):
        return ""
    if CHARACTER_FIXED_RANK_PORTRAIT.has(GameState.char_id):
        return CHARACTER_FIXED_RANK_PORTRAIT[GameState.char_id]
    var title: = GameState.get_rank_title()
    for grade in PLAYER_RANK_PORTRAIT_MAP:
        if title.contains(grade):
            return PLAYER_RANK_PORTRAIT_MAP[grade]
    return ""

func _player_identity_label() -> String:
    var province: = str(GameState.city.get("province", ""))
    var city_name: = GameState.get_current_city_name()
    var office: = GameState.get_office_title()
    return "%s%s%s" % [province, city_name, office]

func _layout_portrait() -> void :
    if not is_instance_valid(_portrait_rect) or not _portrait_rect.visible:
        return

    var viewport_size: = size
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
        viewport_size = get_viewport_rect().size
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
        return
    var tex: Texture2D = _portrait_rect.texture
    if tex == null or tex.get_height() <= 0:
        return
    var portrait_height: float = viewport_size.y * PORTRAIT_HEIGHT_RATIO
    var portrait_width: float = portrait_height * float(tex.get_width()) / float(tex.get_height())

    var portrait_x: float = viewport_size.x - portrait_width + portrait_width * 0.06
    _portrait_rect.position = Vector2(portrait_x, viewport_size.y - portrait_height)
    _portrait_rect.size = Vector2(portrait_width, portrait_height)
    if is_instance_valid(_portrait_badge):
        var badge_size: Vector2 = _portrait_badge.get_combined_minimum_size()
        _portrait_badge.position = Vector2(
            viewport_size.x - badge_size.x - 24.0, 
            viewport_size.y * 0.78
        )

func _make_badge_style() -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0.06, 0.048, 0.036, 0.94) if GameState.theme == "dark" else Color(0.105, 0.09, 0.07, 0.95)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = Color(GameState.get_theme_color("border_active"), 0.55)
    style.corner_radius_top_left = 4
    style.corner_radius_top_right = 4
    style.corner_radius_bottom_left = 4
    style.corner_radius_bottom_right = 4
    style.content_margin_left = 16
    style.content_margin_right = 22
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    return style

func _make_avatar_circle_style() -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0.04, 0.032, 0.024, 0.85) if GameState.theme == "dark" else Color(0.09, 0.078, 0.062, 0.88)
    style.border_width_left = 2
    style.border_width_top = 2
    style.border_width_right = 2
    style.border_width_bottom = 2
    style.border_color = GameState.get_theme_color("border_active")
    style.corner_radius_top_left = 999
    style.corner_radius_top_right = 999
    style.corner_radius_bottom_left = 999
    style.corner_radius_bottom_right = 999
    return style

func _apply_native_mobile_font_scale() -> void :
    NativeMobileFontScalerRef.apply_to(self)

func _scroll_to_row(row: Control) -> void :
    if not is_instance_valid(row) or not is_instance_valid(content_scroll):
        return
    if not row.is_inside_tree() or not content_scroll.is_inside_tree():
        return





    for _i in range(3):
        await get_tree().process_frame
        if not is_instance_valid(row) or not is_instance_valid(content_scroll):
            return
        if not row.is_inside_tree() or not content_scroll.is_inside_tree():
            return

        var vbar: = content_scroll.get_v_scroll_bar()
        if is_instance_valid(vbar) and vbar.max_value > content_scroll.size.y:
            break

    if not is_instance_valid(row) or not is_instance_valid(content_scroll):
        return
    if not row.is_inside_tree() or not content_scroll.is_inside_tree():
        return

    var row_y: = row.position.y
    var scroll_h: = content_scroll.size.y
    var row_h: = row.size.y
    if row_h <= 0:
        row_h = row.custom_minimum_size.y


    var target_scroll: = row_y - (scroll_h - row_h) / 2.0
    if target_scroll < 0.0:
        target_scroll = 0.0
    var vbar2: = content_scroll.get_v_scroll_bar()
    if is_instance_valid(vbar2):
        var max_scroll: = vbar2.max_value - scroll_h
        if max_scroll > 0.0 and target_scroll > max_scroll:
            target_scroll = max_scroll
    content_scroll.scroll_vertical = int(target_scroll)

func _make_modal_panel_style() -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = GameState.get_theme_color("bg_popup")
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = Color(0.42, 0.43, 0.44, 0.72)
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    style.shadow_color = Color(0, 0, 0, 0.0) if GameState.theme == "light" else Color(0, 0, 0, 0.48)
    style.shadow_size = 0 if GameState.theme == "light" else 18
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 12
    style.content_margin_bottom = 12
    return style

func _make_tab_style(active: bool, hovered: bool, is_player: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    if active:
        style.bg_color = Color(0.14, 0.1, 0.06, 0.92)
        style.border_color = GameState.get_theme_color("border_active")
    elif hovered:
        style.bg_color = Color(0.09, 0.07, 0.05, 0.82)
        style.border_color = Color(GameState.get_theme_color("border_med"), 0.7)
    elif is_player:
        style.bg_color = Color(0.08, 0.06, 0.04, 0.72)
        style.border_color = Color(GameState.get_theme_color("border_active"), 0.4)
    else:
        style.bg_color = Color(0.05, 0.045, 0.035, 0.52)
        style.border_color = Color(GameState.get_theme_color("border_weak"), 0.4)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1 if not active else 2
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.content_margin_left = 6
    style.content_margin_right = 6
    style.content_margin_top = 4
    style.content_margin_bottom = 4
    return style

func _make_cell_style(state: String) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 8
    style.content_margin_bottom = 8
    match state:
        "current":
            style.bg_color = Color(0.18, 0.12, 0.065, 0.96)
            if _current_mode == "keju":
                style.border_color = GameState.get_theme_color("border_med")
            else:
                style.border_color = GameState.get_theme_color("border_active")
                style.shadow_color = Color(0.5, 0.38, 0.15, 0.2)
                style.shadow_size = 10
        "reached":
            style.bg_color = Color(0.1, 0.078, 0.052, 0.86)
            style.border_color = GameState.get_theme_color("border_med")
        "on_path":
            style.bg_color = Color(0.075, 0.064, 0.048, 0.76)
            style.border_color = GameState.get_theme_color("border_weak")
        _:
            style.bg_color = Color(0.048, 0.044, 0.038, 0.54)
            style.border_color = Color(GameState.get_theme_color("border_weak"), 0.55)
    return style

func _cell_title_color(state: String) -> Color:
    match state:
        "current":
            return Color(0.98, 0.93, 0.82, 1)
        "reached":
            return GameState.get_theme_color("border_active")
        "on_path":
            return Color(GameState.get_theme_color("text_desc"), 0.85)
        _:
            return Color(GameState.get_theme_color("text_sub"), 0.55)

func _legend_color(state: String) -> Color:
    match state:
        "current":
            if _current_mode == "keju":
                return GameState.get_theme_color("border_med")
            return GameState.get_theme_color("border_active")
        "reached":
            return Color(0.72, 0.58, 0.32, 0.72)
        "on_path":
            return Color(0.22, 0.2, 0.17, 0.72)
        _:
            return Color(0.08, 0.07, 0.06, 0.72)

func _make_close_button_style(hovered: bool, pressed: bool = false) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = GameState.get_theme_color("choice_press" if pressed else ("choice_hover" if hovered else "choice_normal"))
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = GameState.get_theme_color("border_active" if hovered or pressed else "border")
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    style.content_margin_left = 18
    style.content_margin_right = 18
    style.content_margin_top = 8
    style.content_margin_bottom = 8
    return style
