extends Control

signal back_requested

const ScrollbarThemeRef = preload("res://scripts/ui/scrollbar_theme.gd")
const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const NativeMobileTouchScrollRef = preload("res://scripts/ui/native_mobile_touch_scroll.gd")
const FontLoader = preload("res://scripts/ui/font_loader.gd")
const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")
const MOBILE_PORTRAIT_MAX_WIDTH: = 900.0
const MOBILE_DETAIL_PANEL_HEIGHT_RATIO: = 0.92
const MOBILE_DETAIL_PANEL_MIN_HEIGHT: = 1040.0
const MOBILE_DETAIL_PANEL_MAX_HEIGHT: = 1520.0
const MOBILE_TOP_SAFE_AREA_FALLBACK: = 38.0
const ENDING_CATEGORY_KEJU: = "科场人生"
const ENDING_CATEGORY_LOCAL: = "地方路线"
const ENDING_CATEGORY_BIANWU: = "边务路线"
const KEJU_ENDING_ORDER: = [
    "jingguan_ending_yijia", 
    "jingguan_ending_erjia", 
    "jingguan_ending_sanjia_datong", 
    "xiucai_ending", 
    "scholar_ending", 
    "scientist_ending", 
    "doctor_ending", 
    "painter_ending", 
    "musician_ending", 
    "businessman_ending", 
    "soldier_ending", 
    "detour_soldier_border_ending", 
    "detour_farmer_ending", 
    "detour_peddler_ending", 
    "eunuch_ending", 
    "detour_eunuch_ending", 
]
const LOCAL_ENDING_ORDER: = [

    "dezheng_mandate_usurp", 
    "beijing_relief_regency", 
    "beijing_relief_beijing", 
    "beijing_relief_west", 
    "beijing_relief_shandong", 
    "beijing_relief_suspicion", 

    "dumu_xunjie", 
    "dumu_nandu", 
    "dumunanzhj", 

    "dongnan_tietong", 
    "dongnanhubao", 
    "dongnan_huiguang", 
    "dongnan_jiangqing", 
    "luanshi_dutu", 

    "bishan_chuangwang", 
    "bishan_kangqing", 
    "bishan_jianshou", 
    "bishan_guiyin", 
    "bishan_jiangqing", 

    "xinhuo_guming", 
    "xinhuo_fangshou", 
    "xinhuo_dengjin", 

    "hujia_nandu", 
    "buyi_guitian", 
    "juezhan_ziwen", 
    "huabian_shensi", 

    "dadao_zhixing_zhong", 
    "dadao_zhixing_xin", 
    "dadao_zhixing_xiao", 
    "dadao_zhixing_fan", 

    "shi_bi_le_tu_xin", 
    "shi_bi_le_tu_xin_du", 
    "shi_bi_le_tu_xiao", 
    "shi_bi_le_tu_fan", 
    "shi_bi_le_tu_zheng", 

    "huosiren_mu", 

    "riot_martyrdom", 
    "riot_flee", 
    "shengjuan", 
    "shengjuan_rebel", 
    "qingyi", 
    "zhongguan", 
    "shishen", 
    "tizhi", 
    "tizhi_prison", 
    "tizhi_war", 
    "tizhi_rebel", 
    "tizhi_warlord", 
    "minwang", 
]

var title_font: Font = FontLoader.title()
var serif_font: Font = FontLoader.serif_bold()
var body_font: Font = FontLoader.body()

var root_margin: MarginContainer
var page_container: VBoxContainer
var header_container: HBoxContainer
var header_title: Label
var subtitle_label: Label
var count_label: Label
var guozuo_label: Label
var category_tabs: HBoxContainer
var list_scroll: ScrollContainer
var list_margin: MarginContainer
var list_grid: GridContainer
var detail_overlay: ColorRect
var detail_panel: PanelContainer
var detail_title_label: Label
var detail_meta_label: Label
var detail_body_label: Label
var detail_comment_spacer: Control
var detail_comment_top_rule: ColorRect
var detail_comment_heading: Label
var detail_comment_label: Label
var detail_close_button: Button
var back_button: Button
var category_buttons: Dictionary = {}
var active_ending_category: = ENDING_CATEGORY_LOCAL
var list_scroll_touch_drag_suppress_until_ms: int = 0

func _ready() -> void :
    _build_page()
    if not GameState.theme_changed.is_connected(_on_theme_changed):
        GameState.theme_changed.connect(_on_theme_changed)
    resized.connect(_apply_responsive_layout)
    refresh()
    _apply_native_mobile_font_scale()


func refresh() -> void :
    if not is_inside_tree():
        return
    var all_endings: = _collect_codex_endings()
    var filtered_endings: = _filter_endings_by_category(all_endings)
    var unlocked_ids: = SaveManager.get_unlocked_ending_ids()
    count_label.text = "已收录 %d / %d" % [_count_unlocked_in_category(filtered_endings, unlocked_ids), filtered_endings.size()]
    _refresh_guozuo_label()
    _refresh_category_tabs()

    for child in list_grid.get_children():
        child.queue_free()

    for ending in filtered_endings:
        var unlocked: bool = ending.get("id", "") in unlocked_ids
        list_grid.add_child(_make_entry_button(ending, unlocked))

    _apply_responsive_layout()


func _build_page() -> void :
    mouse_filter = Control.MOUSE_FILTER_STOP

    var bg = TextureRect.new()
    bg.name = "Background"
    bg.texture = preload("res://assets/ui/title/title_home_bg.webp")
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    bg.modulate = Color(0.72, 0.68, 0.58, 0.3) if GameState.theme == "dark" else Color(0.92, 0.93, 0.95, 0.4)
    add_child(bg)

    var wash = ColorRect.new()
    wash.name = "Wash"
    wash.set_anchors_preset(Control.PRESET_FULL_RECT)
    wash.color = Color(0.025, 0.023, 0.02, 0.86) if GameState.theme == "dark" else Color(0.878, 0.886, 0.902, 0.92)
    add_child(wash)

    root_margin = MarginContainer.new()
    root_margin.name = "RootMargin"
    root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(root_margin)

    page_container = VBoxContainer.new()
    page_container.name = "Page"
    page_container.add_theme_constant_override("separation", 18)
    root_margin.add_child(page_container)

    header_container = HBoxContainer.new()
    header_container.name = "Header"
    header_container.add_theme_constant_override("separation", 18)
    page_container.add_child(header_container)

    header_title = Label.new()
    header_title.text = "过往卷帙"
    header_title.add_theme_font_override("font", title_font)
    header_title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    header_container.add_child(header_title)

    var sub_vbox = VBoxContainer.new()
    sub_vbox.name = "SubtitleAndCountBox"
    sub_vbox.add_theme_constant_override("separation", 2)
    sub_vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    header_container.add_child(sub_vbox)

    subtitle_label = Label.new()
    subtitle_label.text = "结局图鉴"
    subtitle_label.add_theme_font_override("font", serif_font)
    sub_vbox.add_child(subtitle_label)

    count_label = Label.new()
    count_label.add_theme_font_override("font", body_font)
    sub_vbox.add_child(count_label)

    var header_spacer = Control.new()
    header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header_container.add_child(header_spacer)

    category_tabs = HBoxContainer.new()
    category_tabs.name = "EndingCategoryTabs"
    category_tabs.add_theme_constant_override("separation", 10)
    category_tabs.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    header_container.add_child(category_tabs)

    var keju_tab = _make_category_tab(ENDING_CATEGORY_KEJU)
    keju_tab.visible = false
    category_tabs.add_child(keju_tab)
    category_tabs.add_child(_make_category_tab(ENDING_CATEGORY_LOCAL))
    var bianwu_tab = _make_category_tab(ENDING_CATEGORY_BIANWU)
    bianwu_tab.visible = false
    category_tabs.add_child(bianwu_tab)

    back_button = Button.new()
    back_button.text = "返回"
    back_button.pressed.connect( func(): back_requested.emit())
    back_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    back_button.icon = load("res://assets/ui/back.svg")
    back_button.expand_icon = false
    back_button.add_theme_constant_override("h_separation", 6)
    header_container.add_child(back_button)

    guozuo_label = Label.new()
    guozuo_label.name = "GuozuoLedger"
    guozuo_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    guozuo_label.add_theme_font_override("font", body_font)
    page_container.add_child(guozuo_label)

    var content = HBoxContainer.new()
    content.name = "Content"
    content.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 18)
    page_container.add_child(content)

    list_scroll = ScrollContainer.new()
    list_scroll.name = "EndingList"
    list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    list_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_child(list_scroll)
    ScrollbarThemeRef.apply_to(list_scroll)

    list_margin = MarginContainer.new()
    list_margin.name = "ListMargin"
    list_margin.add_theme_constant_override("margin_right", 24)
    list_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list_scroll.add_child(list_margin)

    list_grid = GridContainer.new()
    list_grid.name = "ListGrid"
    list_grid.columns = 2
    list_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list_grid.add_theme_constant_override("h_separation", 18)
    list_grid.add_theme_constant_override("v_separation", 16)
    list_margin.add_child(list_grid)

    detail_overlay = ColorRect.new()
    detail_overlay.name = "DetailOverlay"
    detail_overlay.visible = false
    detail_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    detail_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    detail_overlay.z_index = 120
    detail_overlay.gui_input.connect(_on_detail_overlay_gui_input)
    add_child(detail_overlay)

    var detail_center = CenterContainer.new()
    detail_center.set_anchors_preset(Control.PRESET_FULL_RECT)
    detail_center.mouse_filter = Control.MOUSE_FILTER_PASS
    detail_overlay.add_child(detail_center)

    detail_panel = PanelContainer.new()
    detail_panel.name = "FullEndingDetail"
    detail_panel.custom_minimum_size = Vector2(980, 720)
    detail_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    detail_panel.gui_input.connect(_on_detail_panel_gui_input)
    detail_center.add_child(detail_panel)

    var detail_margin = MarginContainer.new()
    detail_margin.add_theme_constant_override("margin_left", 34)
    detail_margin.add_theme_constant_override("margin_right", 34)
    detail_margin.add_theme_constant_override("margin_top", 28)
    detail_margin.add_theme_constant_override("margin_bottom", 28)
    detail_panel.add_child(detail_margin)

    var detail_vbox = VBoxContainer.new()
    detail_vbox.add_theme_constant_override("separation", 14)
    detail_margin.add_child(detail_vbox)

    var detail_header = HBoxContainer.new()
    detail_header.add_theme_constant_override("separation", 16)
    detail_vbox.add_child(detail_header)

    detail_title_label = Label.new()
    detail_title_label.add_theme_font_override("font", serif_font)
    detail_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_header.add_child(detail_title_label)

    detail_close_button = Button.new()
    detail_close_button.text = "合上"
    detail_close_button.mouse_filter = Control.MOUSE_FILTER_STOP
    detail_close_button.pressed.connect(_hide_ending_detail)
    detail_close_button.gui_input.connect(_on_detail_close_button_gui_input)
    detail_header.add_child(detail_close_button)

    detail_meta_label = Label.new()
    detail_meta_label.add_theme_font_override("font", body_font)
    detail_meta_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_vbox.add_child(detail_meta_label)

    var detail_scroll = ScrollContainer.new()
    detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_vbox.add_child(detail_scroll)
    ScrollbarThemeRef.apply_to(detail_scroll)

    var detail_text_margin = MarginContainer.new()
    detail_text_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_text_margin.add_theme_constant_override("margin_right", 32)
    detail_scroll.add_child(detail_text_margin)

    var detail_text_box = VBoxContainer.new()
    detail_text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_text_box.add_theme_constant_override("separation", 16)
    detail_text_margin.add_child(detail_text_box)

    detail_body_label = Label.new()
    detail_body_label.add_theme_font_override("font", body_font)
    detail_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_text_box.add_child(detail_body_label)

    detail_comment_spacer = Control.new()
    detail_comment_spacer.custom_minimum_size = Vector2(0, 24)
    detail_text_box.add_child(detail_comment_spacer)

    detail_comment_top_rule = ColorRect.new()
    detail_comment_top_rule.custom_minimum_size = Vector2(0, 1)
    detail_comment_top_rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_text_box.add_child(detail_comment_top_rule)

    detail_comment_heading = Label.new()
    detail_comment_heading.text = "卷末回声"
    detail_comment_heading.add_theme_font_override("font", serif_font)
    detail_comment_heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_text_box.add_child(detail_comment_heading)

    detail_comment_label = Label.new()
    detail_comment_label.add_theme_font_override("font", body_font)
    detail_comment_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_comment_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_text_box.add_child(detail_comment_label)

    _apply_theme()


func _collect_codex_endings() -> Array:
    var entries: Array = []
    _append_codex_entries(entries, GameData.endings, "regular")
    _append_codex_entries(entries, GameData.bad_endings, "bad")
    return entries


func _append_codex_entries(entries: Array, source_data: Dictionary, source: String) -> void :
    var ids: = source_data.keys()
    ids.sort()
    for id in ids:
        if id == "jingguan_ending_yijia" or id == "jingguan_ending_erjia" or id == "jingguan_ending_sanjia_datong":
            continue
        var ending: Dictionary = source_data[id]
        entries.append({
            "id": str(id), 
            "source": source, 
            "title": ending.get("title", "无名结局"), 
            "emotion": ending.get("emotion", ""), 
            "badge": ending.get("badge", "终 局"), 
            "category": ending.get("category", ENDING_CATEGORY_LOCAL), 
            "narrative": ending.get("narrative", ""), 
            "comment": ending.get("comment", "")
        })


func _make_category_tab(category: String) -> Button:
    var button: = Button.new()
    button.text = category
    button.toggle_mode = true
    button.custom_minimum_size = Vector2(132, 40)
    button.add_theme_font_override("font", body_font)
    button.pressed.connect( func(): _set_active_ending_category(category))
    category_buttons[category] = button
    return button


func _set_active_ending_category(category: String) -> void :
    if active_ending_category == category:
        _refresh_category_tabs()
        return
    active_ending_category = category
    refresh()


func _refresh_category_tabs() -> void :
    for category in category_buttons:
        var button = category_buttons[category]
        if not is_instance_valid(button) or not button is Button:
            continue
        var active: bool = str(category) == active_ending_category
        button.button_pressed = active

        var main_color = GameState.get_theme_color("text_main")
        var sub_color = GameState.get_theme_color("text_sub")

        button.add_theme_color_override("font_color", main_color if active else sub_color)
        button.add_theme_color_override("font_hover_color", main_color)
        button.add_theme_color_override("font_pressed_color", main_color if active else sub_color)
        button.add_theme_color_override("font_hover_pressed_color", main_color)
        button.add_theme_color_override("font_focus_color", main_color if active else sub_color)

        button.add_theme_stylebox_override("normal", _make_category_tab_box(active, false))
        button.add_theme_stylebox_override("hover", _make_category_tab_box(active, true))
        button.add_theme_stylebox_override("pressed", _make_category_tab_box(true, true))
        button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _filter_endings_by_category(endings: Array) -> Array:
    var filtered: Array = []
    for ending in endings:
        if ending.get("category", ENDING_CATEGORY_LOCAL) == active_ending_category:
            filtered.append(ending)
    filtered.sort_custom(_compare_codex_endings)
    return filtered


func _compare_codex_endings(a: Dictionary, b: Dictionary) -> bool:
    var rank_a: = _get_ending_sort_rank(a)
    var rank_b: = _get_ending_sort_rank(b)
    if rank_a != rank_b:
        return _get_ending_sort_rank(a) < _get_ending_sort_rank(b)
    return str(a.get("id", "")) < str(b.get("id", ""))


func _get_ending_sort_rank(ending: Dictionary) -> int:
    var id: = str(ending.get("id", ""))
    if active_ending_category == ENDING_CATEGORY_KEJU:
        var keju_index: = KEJU_ENDING_ORDER.find(id)
        if keju_index >= 0:
            return keju_index
        return 1000
    if active_ending_category == ENDING_CATEGORY_LOCAL:
        var local_index: = LOCAL_ENDING_ORDER.find(id)
        if local_index >= 0:
            return local_index
        return 1000
    return 1000


func _count_unlocked_in_category(filtered_endings: Array, unlocked_ids: Array) -> int:
    var count: = 0
    for ending in filtered_endings:
        if ending.get("id", "") in unlocked_ids:
            count += 1
    return count


func _refresh_guozuo_label() -> void :
    if not is_instance_valid(guozuo_label):
        return
    var labels: = {
        "yuan_shadow": "袁案旧影", 
        "tianxiong_remnant": "天雄余脉", 
        "qin_army_remnant": "秦军旧部", 
        "firearm_artisans": "火器匠户", 
        "refugee_tuntian": "流民屯田"
    }
    var acquired: Array[String] = []
    for entry in GameState.guozuo_entries:
        var entry_id: = str(entry)
        acquired.append(str(labels.get(entry_id, entry_id)))
    var text: = "已获国祚：%d" % acquired.size()
    if not acquired.is_empty():
        text += "\n" + "、".join(acquired)
    guozuo_label.text = text
    guozuo_label.visible = false


func _make_entry_button(ending: Dictionary, unlocked: bool) -> Button:
    var button = Button.new()
    button.mouse_filter = Control.MOUSE_FILTER_PASS
    button.gui_input.connect(_on_list_scroll_touch_drag)
    button.disabled = not unlocked
    button.text = _entry_text(ending, unlocked)
    button.alignment = HORIZONTAL_ALIGNMENT_LEFT
    button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    button.custom_minimum_size = Vector2(0, 84)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 16)
    var entry_main: = GameState.get_theme_color("text_main") if unlocked else GameState.get_theme_color("text_sub")
    button.add_theme_color_override("font_color", entry_main)

    button.add_theme_color_override("font_hover_color", entry_main)
    button.add_theme_color_override("font_pressed_color", entry_main)
    button.add_theme_color_override("font_focus_color", entry_main)
    button.add_theme_color_override("font_disabled_color", GameState.get_theme_color("text_sub"))
    button.add_theme_stylebox_override("normal", _make_entry_box(unlocked, false))
    button.add_theme_stylebox_override("hover", _make_entry_box(unlocked, true))
    button.add_theme_stylebox_override("pressed", _make_entry_box(unlocked, true))
    button.add_theme_stylebox_override("disabled", _make_entry_box(false, false))
    if unlocked:
        button.pressed.connect( func(): _show_ending_detail(ending))
    return button


func _entry_text(ending: Dictionary, unlocked: bool) -> String:
    var state_label: = "已收录" if unlocked else "未解锁"
    var source_label: = "败局" if ending.get("source", "") == "bad" else "终局"
    var seal: = _get_ending_seal(ending)
    return "%s\n卷标：%s\n%s · %s" % [state_label, seal, source_label, ending.get("emotion", "")]


func _get_ending_seal(ending: Dictionary) -> String:
    var id: = str(ending.get("id", ""))
    var explicit_seals: = {
        "dumu_xunjie": "独木难支 · 殉节", 
        "dumu_nandu": "独木难支 · 南渡", 
        "dongnan_tietong": "东南互保 · 铁桶", 
        "dongnan_jiangqing": "东南互保 · 降清", 
        "dongnan_huiguang": "东南互保 · 回光", 
        "bishan_jianshou": "逼上梁山 · 坚守", 
        "bishan_guiyin": "逼上梁山 · 归隐", 
        "bishan_kangqing": "逼上梁山 · 抗清", 
        "bishan_jiangqing": "逼上梁山 · 降清", 
        "xinhuo_guming": "薪尽火传 · 顾命", 
        "xinhuo_fangshou": "薪尽火传 · 放手", 
        "xinhuo_dengjin": "薪尽火传 · 灯尽", 
        "dadao_zhixing_zhong": "大道之行 · 孤臣悟道", 
        "dadao_zhixing_fan": "大道之行 · 反贼悟道", 
        "dadao_zhixing_xiao": "大道之行 · 枭雄悟道", 
        "dadao_zhixing_xin": "大道之行 · 薪火悟道", 
        "shi_bi_le_tu_fan": "适彼乐土 · 百姓渡海", 
        "shi_bi_le_tu_xiao": "适彼乐土 · 枭雄换局", 
        "shi_bi_le_tu_xin": "适彼乐土 · 送火种过海", 
        "shi_bi_le_tu_xin_du": "适彼乐土 · 托孤远航", 
        "shi_bi_le_tu_zheng": "适彼乐土 · 故人舟楫", 
        "jingguan_ending_yijia": "京官及第 · 金榜题名", 
        "jingguan_ending_erjia": "京官及第 · 二甲登科", 
        "jingguan_ending_sanjia_datong": "京官留都 · 窄门入局", 
        "xiucai_ending": "科举仕途 · 秀才村塾", 
        "tizhi": "败局 · 油尽灯枯", 
        "tizhi_prison": "败局 · 狱底枯骨", 
        "tizhi_war": "败局 · 马革裹尸", 
        "tizhi_rebel": "败局 · 草莽残灯", 
        "tizhi_warlord": "败局 · 孤城灯灭", 

        "bishan_chuangwang": "逼上梁山 · 闯王再世", 

        "hujia_nandu": "北上勤王 · 护驾南渡", 
        "huabian_shensi": "北上勤王 · 拷掠身亡", 
        "buyi_guitian": "北上勤王 · 布衣归田", 
        "juezhan_ziwen": "北上勤王 · 决战自刎", 
        "luanshi_dutu": "东南互保 · 乱世赌徒", 

        "businessman_ending": "红尘浮生 · 富甲一方", 
        "soldier_ending": "红尘浮生 · 塞外孤魂", 
        "eunuch_ending": "红尘浮生 · 残缺的野心", 
        "detour_eunuch_ending": "红尘浮生 · 御马监的小火者", 
        "detour_farmer_ending": "红尘浮生 · 陇亩一生", 
        "detour_peddler_ending": "红尘浮生 · 挑担货郎", 
        "detour_soldier_border_ending": "红尘浮生 · 边塞老卒", 
        "scientist_ending": "红尘浮生 · 格物致用", 
        "scholar_ending": "红尘浮生 · 皓首穷经", 
        "painter_ending": "红尘浮生 · 丹青留名", 
        "doctor_ending": "红尘浮生 · 杏林国手", 
        "musician_ending": "红尘浮生 · 丝竹终老", 

        "huosiren_mu": "永乐大典 · 活死人墓", 

        "beijing_relief_beijing": "北靖大捷 · 北靖开府", 
        "beijing_relief_west": "北靖大捷 · 京师拱卫", 
        "beijing_relief_shandong": "北靖大捷 · 听调不宣", 
        "beijing_relief_suspicion": "北靖大捷 · 功高履薄", 
        "dezheng_mandate_usurp": "北靖大捷 · 神器更易", 
        "beijing_relief_regency": "北靖大捷 · 周公吐哺", 

        "riot_flee": "败局 · 临阵脱逃", 
        "riot_martyrdom": "败局 · 以身殉城", 
        "minwang": "败局 · 万家生啖", 
        "shengjuan": "败局 · 天恩浩荡", 
        "shengjuan_rebel": "败局 · 困兽犹斗", 
        "qingyi": "败局 · 青史遗臭", 
        "zhongguan": "败局 · 诏狱听琴", 
        "shishen": "败局 · 釜底抽薪"
    }
    if id in explicit_seals:
        return explicit_seals[id]
    var title: = str(ending.get("title", ""))
    if title != "":
        return title
    return id


func _apply_ending_placeholders(text: String) -> String:
    var replacements: = {}
    var current_city: String = GameState.get_current_city_name()
    if current_city != "":
        replacements["{current_city}"] = current_city
        var city_under: = "辖下各乡"
        if current_city.ends_with("府"):
            city_under = "辖下十余县"
        elif current_city.ends_with("州"):
            city_under = "下辖各县"
        replacements["{city_under}"] = city_under
    else:
        replacements["{current_city}"] = "蓬莱县"
        replacements["{city_under}"] = "辖下各乡"

    var office_title: = GameState.get_office_title() if GameState.has_method("get_office_title") else GameState.get_rank_title()
    var office_juris: = GameState.get_office_juris_from_rank_title() if GameState.has_method("get_office_juris_from_rank_title") else ""
    if office_title != "" and office_title != "未知":
        replacements["{official_title}"] = office_title
        replacements["{office_title}"] = office_title
        replacements["{office_short}"] = office_title
    else:
        replacements["{official_title}"] = "知县"
        replacements["{office_title}"] = "知县"
        replacements["{office_short}"] = "知县"

    if office_juris != "":
        replacements["{office_juris}"] = office_juris
        replacements["{office_scope}"] = office_juris
    else:
        replacements["{office_juris}"] = "县"
        replacements["{office_scope}"] = "县"

    for act_idx in range(1, 7):
        var act_key: = str(act_idx)
        var city_cfg: Dictionary = GameState.resolve_transfer_city_for_act(act_key, GameState.get_rank_title())
        var city_name: = str(city_cfg.get("name", ""))
        if city_name == "":
            var default_names = {
                "1": "蓬莱县", 
                "2": "蒲州", 
                "3": "真定府", 
                "4": "襄阳府", 
                "5": "河西道", 
                "6": "济南府"
            }
            city_name = default_names.get(act_key, "")
        if city_name != "":
            replacements["{city_%s}" % act_key] = city_name

    var result: = text
    for placeholder in replacements:
        result = result.replace(placeholder, replacements[placeholder])
    return result


func _show_ending_detail(ending: Dictionary) -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(self, "list_scroll_touch_drag_suppress_until_ms"):
        return
    detail_overlay.visible = true
    detail_title_label.text = ending.get("title", "")
    detail_meta_label.text = _detail_meta_text(ending)
    detail_body_label.text = _apply_ending_placeholders(ending.get("narrative", ""))
    detail_comment_label.text = _apply_ending_placeholders(ending.get("comment", ""))
    var has_comment: = str(detail_comment_label.text).strip_edges() != ""
    detail_comment_spacer.visible = has_comment
    detail_comment_top_rule.visible = has_comment
    detail_comment_heading.visible = has_comment
    detail_comment_label.visible = has_comment
    _apply_native_mobile_font_scale()


func _hide_ending_detail() -> void :
    detail_overlay.visible = false


func _on_detail_overlay_gui_input(event: InputEvent) -> void :
    if not detail_overlay.visible:
        return
    if _is_primary_release_event(event):
        _hide_ending_detail()
        get_viewport().set_input_as_handled()


func _on_detail_panel_gui_input(event: InputEvent) -> void :
    if event is InputEventMouseButton or event is InputEventScreenTouch:
        get_viewport().set_input_as_handled()


func _on_detail_close_button_gui_input(event: InputEvent) -> void :
    if _is_primary_release_event(event):
        _hide_ending_detail()
        get_viewport().set_input_as_handled()


func _is_primary_press_event(event: InputEvent) -> bool:
    if event is InputEventScreenTouch:
        return event.pressed
    if event is InputEventMouseButton:
        return event.pressed and event.button_index == MOUSE_BUTTON_LEFT
    return false


func _is_primary_release_event(event: InputEvent) -> bool:
    if event is InputEventScreenTouch:
        return not event.pressed
    if event is InputEventMouseButton:
        return not event.pressed and event.button_index == MOUSE_BUTTON_LEFT
    return false


func _on_list_scroll_touch_drag(event: InputEvent) -> void :
    NativeMobileTouchScrollRef.forward_drag_to_scroll(event, list_scroll, self, "list_scroll_touch_drag_suppress_until_ms")


func _detail_meta_text(ending: Dictionary) -> String:
    var emotion: = str(ending.get("emotion", "")).strip_edges()
    var badge: = _visible_detail_badge(ending)
    var parts: Array[String] = []
    if badge != "":
        parts.append(badge)
    if emotion != "":
        parts.append(emotion)
    return " · ".join(parts)


func _visible_detail_badge(ending: Dictionary) -> String:
    var badge: = str(ending.get("badge", "终 局")).strip_edges()
    var normalized: = badge.replace(" ", "")
    if normalized == "开局":
        return ""
    return badge


func _on_theme_changed(_theme: String) -> void :
    _apply_theme()
    refresh()


func _apply_theme() -> void :
    var ink = GameState.get_theme_color("text_main")
    var soft = GameState.get_theme_color("text_sub")
    var body = GameState.get_theme_color("text_desc")
    var echo_ink: = Color(0.88, 0.71, 0.42, 1.0) if GameState.theme == "dark" else Color(0.48, 0.3, 0.13, 1.0)
    var echo_body: = Color(0.76, 0.65, 0.48, 1.0) if GameState.theme == "dark" else Color(0.34, 0.25, 0.17, 1.0)
    var echo_rule: = Color(0.62, 0.48, 0.27, 0.72) if GameState.theme == "dark" else Color(0.48, 0.31, 0.14, 0.48)
    header_title.add_theme_color_override("font_color", ink)
    subtitle_label.add_theme_color_override("font_color", ink)
    count_label.add_theme_color_override("font_color", soft)
    if is_instance_valid(guozuo_label):
        guozuo_label.add_theme_color_override("font_color", echo_body)
    var btn_normal_color = GameState.get_theme_color("text_sub")
    var btn_hover_color = GameState.get_theme_color("border_active")
    back_button.add_theme_color_override("font_color", btn_normal_color)
    back_button.add_theme_color_override("font_hover_color", btn_hover_color)
    back_button.add_theme_color_override("font_pressed_color", btn_hover_color)
    back_button.add_theme_color_override("font_focus_color", btn_normal_color)
    for prop in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_focus_color"]:
        back_button.remove_theme_color_override(prop)
    back_button.add_theme_stylebox_override("normal", GameScreenStyleFactory.modal_return_button_style("normal"))
    back_button.add_theme_stylebox_override("hover", GameScreenStyleFactory.modal_return_button_style("hover"))
    back_button.add_theme_stylebox_override("pressed", GameScreenStyleFactory.modal_return_button_style("pressed"))
    back_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    detail_overlay.color = Color(0.0, 0.0, 0.0, 0.72) if GameState.theme == "dark" else Color(0.0, 0.0, 0.0, 0.42)
    detail_panel.add_theme_stylebox_override("panel", _make_panel_box())
    detail_title_label.add_theme_color_override("font_color", ink)
    detail_meta_label.add_theme_color_override("font_color", soft)
    detail_body_label.add_theme_color_override("font_color", body)
    detail_comment_top_rule.color = echo_rule
    detail_comment_heading.add_theme_color_override("font_color", echo_ink)
    detail_comment_label.add_theme_color_override("font_color", echo_body)
    detail_close_button.add_theme_color_override("font_color", btn_normal_color)
    detail_close_button.add_theme_color_override("font_hover_color", btn_hover_color)
    detail_close_button.add_theme_color_override("font_pressed_color", btn_hover_color)
    detail_close_button.add_theme_stylebox_override("normal", GameScreenStyleFactory.modal_return_button_style("normal"))
    detail_close_button.add_theme_stylebox_override("hover", GameScreenStyleFactory.modal_return_button_style("hover"))
    detail_close_button.add_theme_stylebox_override("pressed", GameScreenStyleFactory.modal_return_button_style("pressed"))
    detail_close_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    _refresh_category_tabs()
    ScrollbarThemeRef.apply_to(list_scroll)


func _apply_responsive_layout() -> void :
    if not is_instance_valid(root_margin):
        return
    var viewport_size: = get_viewport_rect().size

    var window_size: = viewport_size
    if OS.has_feature("web"):
        var browser_json: = str(JavaScriptBridge.eval("JSON.stringify({ w: window.innerWidth, h: window.innerHeight })"))
        var parsed = JSON.parse_string(browser_json)
        if parsed is Dictionary:
            var width: = float(parsed.get("w", 0.0))
            var height: = float(parsed.get("h", 0.0))
            if width > 0.0 and height > 0.0:
                window_size = Vector2(width, height)
    else:
        var ds_size: = Vector2(DisplayServer.window_get_size())
        if ds_size.x > 0.0 and ds_size.y > 0.0:
            window_size = ds_size
    var mobile: = window_size.y > window_size.x

    if is_instance_valid(category_tabs) and is_instance_valid(page_container) and is_instance_valid(header_container):
        if mobile:
            _reparent_node(category_tabs, page_container, 2)
        else:
            _reparent_node(category_tabs, header_container)
            if is_instance_valid(back_button):
                header_container.move_child(back_button, header_container.get_child_count() - 1)

    var margin: = 38 if mobile else 58
    var safe_top: = _get_top_safe_area_inset()
    root_margin.add_theme_constant_override("margin_left", margin)
    root_margin.add_theme_constant_override("margin_right", margin)
    root_margin.add_theme_constant_override("margin_top", int(round((36.0 + safe_top) if mobile else 46.0)))
    root_margin.add_theme_constant_override("margin_bottom", 34 if mobile else 42)


    header_title.add_theme_font_size_override("font_size", 65 if mobile else 46)
    subtitle_label.add_theme_font_size_override("font_size", 37 if mobile else 15)
    count_label.add_theme_font_size_override("font_size", 31 if mobile else 16)
    back_button.custom_minimum_size = Vector2(200 if mobile else 128, 80 if mobile else 42)
    back_button.add_theme_font_size_override("font_size", 36 if mobile else 16)
    back_button.add_theme_constant_override("icon_max_width", 36 if mobile else 16)
    if is_instance_valid(category_tabs):
        category_tabs.add_theme_constant_override("separation", 16 if mobile else 10)
        for tab in category_tabs.get_children():
            if tab is Button:
                tab.custom_minimum_size = Vector2(250 if mobile else 132, 76 if mobile else 40)
                tab.add_theme_font_size_override("font_size", 32 if mobile else 15)

    list_grid.columns = 2
    list_scroll.custom_minimum_size = Vector2(0, 0)
    list_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL


    for entry_btn in list_grid.get_children():
        if entry_btn is Button:
            entry_btn.add_theme_font_size_override("font_size", 34 if mobile else 16)
            entry_btn.custom_minimum_size.y = 140 if mobile else 84
            var entry_style_normal = entry_btn.get_theme_stylebox("normal")
            if entry_style_normal is StyleBoxFlat:
                entry_style_normal.content_margin_left = 28 if mobile else 18
                entry_style_normal.content_margin_right = 28 if mobile else 18
                entry_style_normal.content_margin_top = 22 if mobile else 12
                entry_style_normal.content_margin_bottom = 22 if mobile else 12


    var page_node = root_margin.get_child(0)
    if page_node:
        for child in page_node.get_children():
            if child is Label and child.get_parent() == page_node and child.autowrap_mode != TextServer.AUTOWRAP_OFF:
                child.add_theme_font_size_override("font_size", 34 if mobile else 14)

    var panel_width: float = clamp(viewport_size.x * (0.94 if mobile else 0.64), 720.0 if mobile else 860.0, 1120.0)
    var panel_height: float = clampf(
        viewport_size.y * (MOBILE_DETAIL_PANEL_HEIGHT_RATIO if mobile else 0.76), 
        MOBILE_DETAIL_PANEL_MIN_HEIGHT if mobile else 560.0, 
        MOBILE_DETAIL_PANEL_MAX_HEIGHT if mobile else 980.0
    )
    detail_panel.custom_minimum_size = Vector2(panel_width, panel_height)
    detail_title_label.add_theme_font_size_override("font_size", 46 if mobile else 25)
    detail_meta_label.add_theme_font_size_override("font_size", 34 if mobile else 15)
    detail_body_label.add_theme_font_size_override("font_size", 36 if mobile else 16)
    detail_comment_spacer.custom_minimum_size = Vector2(0, 36 if mobile else 28)
    detail_comment_heading.add_theme_font_size_override("font_size", 38 if mobile else 17)
    detail_comment_label.add_theme_font_size_override("font_size", 34 if mobile else 15)
    detail_close_button.custom_minimum_size = Vector2(200 if mobile else 88, 80 if mobile else 40)
    detail_close_button.add_theme_font_size_override("font_size", 36 if mobile else 15)
    _apply_native_mobile_font_scale()


func _get_top_safe_area_inset() -> float:
    if OS.has_feature("web"):
        var css_top: = _get_web_top_safe_area_inset()
        if css_top > 0.0:
            return css_top
    if OS.has_feature("android") or OS.has_feature("ios"):
        var native_top: = _get_native_top_safe_area_inset()
        if native_top > 0.0:
            return native_top
    return MOBILE_TOP_SAFE_AREA_FALLBACK if OS.has_feature("web") else 0.0


func _get_web_top_safe_area_inset() -> float:
    var js: = "\n(() => {\n\tconst probe = document.createElement('div');\n\tprobe.style.cssText = 'position:fixed;top:0;left:0;padding-top:env(safe-area-inset-top);visibility:hidden;pointer-events:none;';\n\tdocument.body.appendChild(probe);\n\tconst value = parseFloat(getComputedStyle(probe).paddingTop) || 0;\n\tprobe.remove();\n\treturn value;\n})()\n"









    var value = JavaScriptBridge.eval(js)
    return float(value) if value != null else 0.0


func _get_native_top_safe_area_inset() -> float:
    var viewport_size: = get_viewport_rect().size
    var window_size: = Vector2(DisplayServer.window_get_size())
    var safe_area: = DisplayServer.get_display_safe_area()
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0 or window_size.y <= 0.0:
        return 0.0
    if safe_area.size.x <= 0 or safe_area.size.y <= 0:
        return 0.0
    var scale_y: = viewport_size.y / window_size.y
    return maxf(0.0, float(safe_area.position.y) * scale_y)


func _apply_native_mobile_font_scale() -> void :
    NativeMobileFontScalerRef.apply_to(self)


func _make_panel_box() -> StyleBoxFlat:
    var box: = StyleBoxFlat.new()

    var panel_bg: = GameState.get_theme_color("bg_popup") if GameState.theme == "light" else GameState.get_theme_color("bg_panel")
    box.bg_color = _opaque_color(panel_bg)
    box.border_color = GameState.get_theme_color("border_med")
    box.set_border_width_all(1)
    box.corner_radius_top_left = 2
    box.corner_radius_top_right = 2
    box.corner_radius_bottom_left = 2
    box.corner_radius_bottom_right = 2
    return box


func _opaque_color(color: Color) -> Color:
    return Color(color.r, color.g, color.b, 1.0)


func _make_button_box(bg: Color) -> StyleBoxFlat:
    var box: = StyleBoxFlat.new()
    box.bg_color = bg
    box.set_border_width_all(0)
    box.corner_radius_top_left = 2
    box.corner_radius_top_right = 2
    box.corner_radius_bottom_left = 2
    box.corner_radius_bottom_right = 2
    box.content_margin_left = 16
    box.content_margin_right = 16
    box.content_margin_top = 8
    box.content_margin_bottom = 8
    return box


func _make_nav_button_box(state: String) -> StyleBoxFlat:
    var box: = StyleBoxFlat.new()
    if GameState.theme == "dark":
        if state == "normal":
            box.bg_color = Color(0.02, 0.018, 0.014, 0.62)
            box.border_color = Color(0.72, 0.56, 0.28, 0.25)
        elif state == "hover":
            box.bg_color = Color(0.16, 0.1, 0.05, 0.62)
            box.border_color = Color(0.8, 0.62, 0.32, 0.42)
        else:
            box.bg_color = Color(0.1, 0.07, 0.035, 0.76)
            box.border_color = Color(0.8, 0.62, 0.32, 0.42)
    else:
        if state == "normal":
            box.bg_color = Color(0.74, 0.61, 0.39, 0.9)
            box.border_color = Color(0.45, 0.33, 0.18, 0.54)
        elif state == "hover":
            box.bg_color = Color(0.82, 0.7, 0.48, 0.94)
            box.border_color = Color(0.45, 0.33, 0.18, 0.54)
        else:
            box.bg_color = Color(0.66, 0.54, 0.32, 0.94)
            box.border_color = Color(0.45, 0.33, 0.18, 0.54)
    box.set_border_width_all(1)
    box.corner_radius_top_left = 8
    box.corner_radius_top_right = 8
    box.corner_radius_bottom_left = 8
    box.corner_radius_bottom_right = 8
    box.shadow_size = 6 if GameState.theme == "dark" and box.bg_color.a > 0.2 else 0
    box.shadow_color = Color(0, 0, 0, 0.26)
    box.content_margin_left = 18
    box.content_margin_right = 18
    box.content_margin_top = 8
    box.content_margin_bottom = 8
    return box


func _make_category_tab_box(active: bool, hover: bool) -> StyleBoxFlat:
    var box: = StyleBoxFlat.new()
    if GameState.theme == "dark":
        box.bg_color = Color(0.18, 0.11, 0.06, 0.94) if active else (Color(0.13, 0.085, 0.055, 0.88) if hover else Color(0.075, 0.058, 0.042, 0.72))
        box.border_color = Color(0.78, 0.6, 0.34, 0.76) if active else Color(0.54, 0.41, 0.23, 0.48)
    else:
        box.bg_color = Color(0.84, 0.72, 0.48, 0.95) if active else (Color(0.78, 0.67, 0.47, 0.88) if hover else Color(0.66, 0.56, 0.4, 0.64))
        box.border_color = Color(0.48, 0.34, 0.16, 0.62) if active else Color(0.46, 0.33, 0.18, 0.36)
    box.set_border_width_all(1)
    box.corner_radius_top_left = 18
    box.corner_radius_top_right = 18
    box.corner_radius_bottom_left = 18
    box.corner_radius_bottom_right = 18
    box.content_margin_left = 18
    box.content_margin_right = 18
    box.content_margin_top = 8
    box.content_margin_bottom = 8
    return box


func _make_entry_box(unlocked: bool, hover: bool) -> StyleBoxFlat:
    var box: = StyleBoxFlat.new()
    if GameState.theme == "light":
        if unlocked:

            box.bg_color = Color(1.0, 0.995, 0.985, 1.0) if hover else Color(0.995, 0.985, 0.975, 1.0)
            box.border_color = Color(0.3, 0.29, 0.27, 0.55)
            box.set_border_width_all(1)
        else:

            box.bg_color = Color(0.86, 0.86, 0.87, 0.85)
            box.border_color = Color(0.62, 0.62, 0.64, 0.45)
            box.set_border_width_all(1)
    else:
        box.bg_color = GameState.get_theme_color("bg_panel") if unlocked and hover else GameState.get_theme_color("bg_panel_weak")
        box.border_color = GameState.get_theme_color("border_med") if unlocked else GameState.get_theme_color("border_weak")
        box.set_border_width_all(1)
    box.corner_radius_top_left = 2
    box.corner_radius_top_right = 2
    box.corner_radius_bottom_left = 2
    box.corner_radius_bottom_right = 2
    box.content_margin_left = 18
    box.content_margin_right = 18
    box.content_margin_top = 12
    box.content_margin_bottom = 12
    return box


func _reparent_node(node: Control, new_parent: Control, index: int = -1) -> void :
    if not is_instance_valid(node) or not is_instance_valid(new_parent):
        return
    if node.get_parent() == new_parent:
        if index >= 0:
            new_parent.move_child(node, index)
        return
    if node.get_parent() != null:
        node.get_parent().remove_child(node)
    if index >= 0:
        new_parent.add_child(node)
        new_parent.move_child(node, index)
    else:
        new_parent.add_child(node)
