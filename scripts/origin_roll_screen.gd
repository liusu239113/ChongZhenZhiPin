extends Control





signal origin_rolled(char_id: String, traits: Array)
signal back_requested

const FontLoader = preload("res://scripts/ui/font_loader.gd")
const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")

const TRAIT_REEL_COUNT: = 3
const STRIP_REPEAT: = 16
const IDLE_SPEED: = 760.0



const ORIGINS: = [
    {"glyph": "农", "display": "小农之家", "char_id": "hanmen", "blurb": "你出生在河南祥符的一户农家，世代面朝黄土。"}, 
    {"glyph": "绅", "display": "缙绅之家", "char_id": "jinshen", "blurb": "你出生在苏州缙绅门第，家底丰厚、人脉通达。"}, 
    {"glyph": "将", "display": "将门之后", "char_id": "shijia", "blurb": "你出生在保定一户没落军户，祖上曾以军功封百户。"}, 
    {"glyph": "商", "display": "商贾之家", "char_id": "shangjia", "blurb": "你出生在苏州的商户人家，账册算盘是你最早的玩物。"}, 
    {"glyph": "游", "display": "市井游民", "char_id": "neiting", "blurb": "你出生在顺天府城郊的游民窝棚，从小在街头讨生活。"}, 
    {"glyph": "书", "display": "书香门第", "char_id": "qingwang", "blurb": "你出生在一户清贫书香人家，满屋诗卷却不名一钱。"}, 
]

var FONT_TITLE: Font = FontLoader.title()
var FONT_BODY: Font = FontLoader.body()
var FONT_BOLD: Font = FontLoader.serif_bold()

var GOLD: Color:
    get: return GameState.get_theme_color("border_active")
var INK: Color:
    get: return GameState.get_theme_color("text_desc")
var INK_DEEP: Color:
    get: return GameState.get_theme_color("text_main")
var MUTED: Color:
    get: return GameState.get_theme_color("text_sub")

@onready var background: TextureRect = $Background
@onready var overlay: ColorRect = $Overlay


var _phase: = "idle_spin"
var _reels: Array = []
var _land_tweens: Array[Tween] = []
var _result_origin: Dictionary = {}
var _result_traits: Array = []
var _landed_count: = 0
var _summary_label: RichTextLabel
var _action_button: Button
var _restart_button: Button
var _trait_tooltip: PanelContainer = null
var _pinned_trait_id: String = ""

const _STAT_LABEL_MAP: = {
    "wentao": "文韬", 
    "wulue": "武略", 
    "lizheng": "理政", 
    "tizhi": "体质"
}

func _ready() -> void :
    GameState.theme_changed.connect(_on_theme_changed)
    resized.connect(_rebuild)
    visibility_changed.connect(_on_visibility_changed)
    set_process(true)
    _rebuild()

func _on_visibility_changed() -> void :
    if visible:
        _rebuild()

func _on_theme_changed(_theme: String) -> void :
    if is_inside_tree():
        _rebuild()

func _is_compact() -> bool:
    var s: = get_viewport_rect().size
    return s.x < 980.0 or s.y > s.x * 1.18


func _rebuild() -> void :
    if not is_inside_tree():
        return
    _kill_land_tweens()
    _hide_trait_tooltip()
    _reels.clear()
    _result_origin = {}
    _result_traits = []
    _phase = "idle_spin"
    for child in get_children():
        if child == background or child == overlay:
            continue
        child.queue_free()
    if background:
        background.self_modulate.a = 0.5
    overlay.color = Color(0.015, 0.012, 0.01, 0.88) if GameState.theme == "dark" else Color(0.05, 0.04, 0.03, 0.66)

    var compact: = _is_compact()
    var margin: = MarginContainer.new()
    margin.set_anchors_preset(Control.PRESET_FULL_RECT)
    var pad: = 24 if compact else 56
    margin.add_theme_constant_override("margin_left", pad)
    margin.add_theme_constant_override("margin_right", pad)
    margin.add_theme_constant_override("margin_top", 34 if compact else 46)
    margin.add_theme_constant_override("margin_bottom", 30 if compact else 44)
    add_child(margin)

    var root: = VBoxContainer.new()
    root.add_theme_constant_override("separation", 18 if compact else 26)
    root.alignment = BoxContainer.ALIGNMENT_CENTER
    margin.add_child(root)


    var header: = HBoxContainer.new()
    header.add_theme_constant_override("separation", 16)
    root.add_child(header)

    var title_box: = VBoxContainer.new()
    title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title_box)

    var title: = Label.new()
    title.text = "命定之轮"
    title.add_theme_font_override("font", FONT_TITLE)
    title.add_theme_font_size_override("font_size", 50 if compact else 44)
    title.add_theme_color_override("font_color", INK_DEEP)
    title_box.add_child(title)

    var subtitle: = Label.new()
    subtitle.text = "摇动命轮，拼出你的出身与天资。"
    subtitle.add_theme_font_override("font", FONT_BODY)
    subtitle.add_theme_font_size_override("font_size", 24 if compact else 16)
    subtitle.add_theme_color_override("font_color", MUTED)
    title_box.add_child(subtitle)

    var back: = Button.new()
    back.text = "返回"
    back.focus_mode = Control.FOCUS_NONE
    back.custom_minimum_size = Vector2(160 if compact else 112, 56 if compact else 38)
    back.add_theme_font_override("font", FONT_BODY)
    back.add_theme_font_size_override("font_size", 26 if compact else 16)
    _style_secondary_button(back)

    back.icon = load("res://assets/ui/back.svg")
    back.expand_icon = false
    back.add_theme_constant_override("h_separation", 6)
    var fs = 26 if compact else 16
    back.add_theme_constant_override("icon_max_width", fs)

    back.pressed.connect( func(): back_requested.emit())
    header.add_child(back)


    var item_h: float = 64.0 if compact else 56.0
    var reels_row: = HBoxContainer.new()
    reels_row.alignment = BoxContainer.ALIGNMENT_CENTER
    reels_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    reels_row.add_theme_constant_override("separation", 14 if compact else 22)
    root.add_child(reels_row)


    var origin_pool: Array = []
    for o in ORIGINS:
        origin_pool.append("〔%s〕%s" % [o["glyph"], o["display"]])
    var origin_reel: = _build_reel("出身", origin_pool, item_h, 260.0 if compact else 300.0, compact)
    reels_row.add_child(origin_reel["frame"])
    _reels.append(origin_reel)


    var trait_entries: = _all_trait_entries()
    for i in TRAIT_REEL_COUNT:
        var shuffled: = trait_entries.duplicate()
        shuffled.shuffle()
        var names: Array = []
        for t in shuffled:
            names.append(str(t.get("name", "")))
        var tw: float = 150.0 if compact else 168.0
        var reel: = _build_reel("天资", names, item_h, tw, compact)
        reel["entries"] = shuffled
        reels_row.add_child(reel["frame"])
        _reels.append(reel)


    _summary_label = RichTextLabel.new()
    _summary_label.bbcode_enabled = true
    _summary_label.fit_content = true
    _summary_label.scroll_active = false
    _summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _summary_label.custom_minimum_size = Vector2(0, 78 if compact else 64)
    _summary_label.add_theme_font_override("normal_font", FONT_BODY)
    _summary_label.add_theme_font_override("bold_font", FONT_BOLD)
    _summary_label.add_theme_font_size_override("normal_font_size", 28 if compact else 20)
    _summary_label.add_theme_font_size_override("bold_font_size", 28 if compact else 20)
    _summary_label.add_theme_color_override("default_color", INK)
    _summary_label.add_theme_constant_override("line_separation", 8)
    _summary_label.text = "[center]命轮正在转动……按下「揭晓」定下你的开局。[/center]"
    _summary_label.meta_hover_started.connect(_on_summary_meta_hover_started)
    _summary_label.meta_hover_ended.connect(_on_summary_meta_hover_ended)
    _summary_label.meta_clicked.connect(_on_summary_meta_clicked)
    root.add_child(_summary_label)


    var btn_row: = HBoxContainer.new()
    btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
    btn_row.add_theme_constant_override("separation", 18 if compact else 24)
    root.add_child(btn_row)

    _restart_button = Button.new()
    _restart_button.text = "重新摇取"
    _restart_button.focus_mode = Control.FOCUS_NONE
    _restart_button.custom_minimum_size = Vector2(220 if compact else 168, 64 if compact else 50)
    _restart_button.add_theme_font_override("font", FONT_BODY)
    _restart_button.add_theme_font_size_override("font_size", 28 if compact else 18)
    _restart_button.visible = false
    GameScreenStyleFactory.apply_command_button_style(_restart_button, "secondary", 18, 8)
    _restart_button.pressed.connect(_on_restart_pressed)
    btn_row.add_child(_restart_button)

    _action_button = Button.new()
    _action_button.text = "揭晓"
    _action_button.focus_mode = Control.FOCUS_NONE
    _action_button.custom_minimum_size = Vector2(280 if compact else 220, 64 if compact else 50)
    _action_button.add_theme_font_override("font", FONT_BOLD)
    _action_button.add_theme_font_size_override("font_size", 30 if compact else 20)
    GameScreenStyleFactory.apply_command_button_style(_action_button, "primary", 18, 8)
    _action_button.pressed.connect(_on_action_pressed)
    btn_row.add_child(_action_button)

    _apply_native_mobile_font_scale()


func _build_reel(tag: String, pool: Array, item_h: float, width: float, compact: bool) -> Dictionary:
    var col: = VBoxContainer.new()
    col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    col.add_theme_constant_override("separation", 8)

    var tag_label: = Label.new()
    tag_label.text = tag
    tag_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    tag_label.add_theme_font_override("font", FONT_BODY)
    tag_label.add_theme_font_size_override("font_size", 20 if compact else 13)
    tag_label.add_theme_color_override("font_color", GOLD)
    tag_label.modulate.a = 0.7
    col.add_child(tag_label)

    var win_h: float = item_h * 3.0
    var window: = Control.new()
    window.clip_contents = true
    window.custom_minimum_size = Vector2(width, win_h)
    window.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    col.add_child(window)


    var frame_panel: = Panel.new()
    frame_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
    frame_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    frame_panel.add_theme_stylebox_override("panel", _reel_frame_style())
    window.add_child(frame_panel)


    var strip: = VBoxContainer.new()
    strip.add_theme_constant_override("separation", 0)
    strip.position = Vector2.ZERO
    strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    window.add_child(strip)
    var total: = pool.size() * STRIP_REPEAT
    for k in total:
        var entry: String = str(pool[k % pool.size()])
        var item: = Label.new()
        item.text = entry
        item.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        item.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        item.custom_minimum_size = Vector2(width, item_h)
        item.clip_text = true
        item.add_theme_font_override("font", FONT_BOLD if tag == "出身" else FONT_BODY)
        item.add_theme_font_size_override("font_size", (26 if compact else 21) if tag == "出身" else (24 if compact else 18))
        item.add_theme_color_override("font_color", INK_DEEP)
        strip.add_child(item)


    var band: = ColorRect.new()
    band.mouse_filter = Control.MOUSE_FILTER_IGNORE
    band.color = Color(0.85, 0.66, 0.3, 0.1)
    band.set_anchors_preset(Control.PRESET_TOP_WIDE)
    band.offset_top = item_h
    band.offset_bottom = item_h * 2.0
    window.add_child(band)


    var fade: = TextureRect.new()
    fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    fade.set_anchors_preset(Control.PRESET_FULL_RECT)
    fade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    fade.texture = _make_fade_texture()
    window.add_child(fade)

    var cycle_h: float = pool.size() * item_h
    var reel: = {
        "strip": strip, 
        "item_h": item_h, 
        "win_h": win_h, 
        "cycle_h": cycle_h, 
        "pool_size": pool.size(), 
        "frame": col, 
        "frame_panel": frame_panel, 
        "spinning": true, 
        "band": band, 
        "tag": tag, 
    }

    strip.position.y = - randf() * cycle_h
    return reel


func _process(delta: float) -> void :
    if not visible or _phase != "idle_spin" or _reels.is_empty():
        return
    for reel in _reels:
        var strip: VBoxContainer = reel["strip"]
        if strip == null or not is_instance_valid(strip):
            continue
        var y: float = strip.position.y - IDLE_SPEED * delta
        var cycle_h: float = reel["cycle_h"]
        while y <= - cycle_h:
            y += cycle_h
        strip.position.y = y


func _on_action_pressed() -> void :
    if _phase == "idle_spin":
        _start_reveal()
    elif _phase == "revealed":
        _confirm_start()

func _start_reveal() -> void :
    _phase = "landing"
    _action_button.disabled = true
    _action_button.text = "揭晓中…"


    _result_origin = ORIGINS[randi() % ORIGINS.size()]
    _result_traits = _roll_traits(TRAIT_REEL_COUNT)

    _kill_land_tweens()
    _landed_count = 0
    for i in _reels.size():
        var reel: Dictionary = _reels[i]
        reel["spinning"] = false
        var result_index: = 0
        if i == 0:
            for j in ORIGINS.size():
                if ORIGINS[j]["char_id"] == _result_origin["char_id"]:
                    result_index = j
                    break
        else:
            var entries: Array = reel.get("entries", [])
            var want: Dictionary = _result_traits[i - 1]
            for j in entries.size():
                if str(entries[j].get("id", "")) == str(want.get("id", "")):
                    result_index = j
                    break
        var strip: VBoxContainer = reel["strip"]
        var spin_px: float = 1300.0 + i * 520.0
        var final_y: = _landing_target(reel, result_index, spin_px)
        var distance: float = absf(strip.position.y - final_y)
        var dur: float = clampf(distance / 1250.0, 1.3, 2.6) + i * 0.22
        var tw: = create_tween()
        tw.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
        tw.tween_property(strip, "position:y", final_y, dur)
        tw.finished.connect( func():
            _landed_count += 1
            if _landed_count >= _reels.size():
                _on_all_landed()
        )
        _land_tweens.append(tw)


func _landing_target(reel: Dictionary, result_index: int, spin_px: float) -> float:
    var item_h: float = reel["item_h"]
    var win_h: float = reel["win_h"]
    var cycle_h: float = reel["cycle_h"]
    var pc: float = reel["strip"].position.y
    var center_y: float = win_h * 0.5 - item_h * 0.5 - result_index * item_h

    var n: int = int(ceil((center_y - (pc - spin_px)) / cycle_h))
    if n < 1:
        n = 1
    return center_y - n * cycle_h

func _on_all_landed() -> void :
    _phase = "revealed"
    _action_button.disabled = false
    _action_button.text = "就此开始"
    _restart_button.visible = true
    for idx in _reels.size():
        var reel: Dictionary = _reels[idx]
        var fp: Panel = reel.get("frame_panel")
        if fp and is_instance_valid(fp):
            fp.add_theme_stylebox_override("panel", _reel_frame_style(true))
        if reel.get("tag") == "天资":
            var band: ColorRect = reel.get("band")
            if band and is_instance_valid(band):
                band.mouse_filter = Control.MOUSE_FILTER_STOP
                var trait_data: Dictionary = _result_traits[idx - 1]
                var tid: = str(trait_data.get("id", ""))
                if band.mouse_entered.is_connected(_on_band_mouse_entered):
                    band.mouse_entered.disconnect(_on_band_mouse_entered)
                if band.mouse_exited.is_connected(_on_band_mouse_exited):
                    band.mouse_exited.disconnect(_on_band_mouse_exited)
                if band.gui_input.is_connected(_on_band_gui_input):
                    band.gui_input.disconnect(_on_band_gui_input)
                band.mouse_entered.connect(_on_band_mouse_entered.bind(tid, band))
                band.mouse_exited.connect(_on_band_mouse_exited.bind(tid))
                band.gui_input.connect(_on_band_gui_input.bind(tid, band))
    _summary_label.text = _compose_summary()

func _on_restart_pressed() -> void :

    _kill_land_tweens()
    _hide_trait_tooltip()
    _phase = "idle_spin"
    _result_origin = {}
    _result_traits = []
    _action_button.disabled = false
    _action_button.text = "揭晓"
    _restart_button.visible = false
    for reel in _reels:
        reel["spinning"] = true
        var fp: Panel = reel.get("frame_panel")
        if fp and is_instance_valid(fp):
            fp.add_theme_stylebox_override("panel", _reel_frame_style(false))
        if reel.get("tag") == "天资":
            var band: ColorRect = reel.get("band")
            if band and is_instance_valid(band):
                band.mouse_filter = Control.MOUSE_FILTER_IGNORE
                if band.mouse_entered.is_connected(_on_band_mouse_entered):
                    band.mouse_entered.disconnect(_on_band_mouse_entered)
                if band.mouse_exited.is_connected(_on_band_mouse_exited):
                    band.mouse_exited.disconnect(_on_band_mouse_exited)
                if band.gui_input.is_connected(_on_band_gui_input):
                    band.gui_input.disconnect(_on_band_gui_input)
    _summary_label.text = "[center]命轮正在转动……按下「揭晓」定下你的开局。[/center]"

func _confirm_start() -> void :
    if _result_origin.is_empty():
        return
    var char_id: = str(_result_origin.get("char_id", "hanmen"))
    var trait_ids: Array = []
    for t in _result_traits:
        trait_ids.append(str(t.get("id", "")))
    origin_rolled.emit(char_id, trait_ids)


func _compose_summary() -> String:
    var blurb: = str(_result_origin.get("blurb", ""))
    var pos: Array = []
    var neg: Array = []
    for t in _result_traits:
        var name: = str(t.get("name", ""))
        if str(t.get("polarity", "positive")) == "negative":
            neg.append(name)
        else:
            pos.append(name)
    var parts: = blurb
    if not pos.is_empty():
        parts += "自幼" + _join_traits(pos, _result_traits)
    if not neg.is_empty():
        parts += ("，却" if not pos.is_empty() else "自幼") + _join_traits(neg, _result_traits)
    parts += "。"
    return "[center]" + parts + "[/center]"

func _join_traits(names: Array, traits_list: Array = []) -> String:
    var wrapped: Array = []
    for n in names:
        var tid: = ""
        for t in traits_list:
            if str(t.get("name", "")) == n:
                tid = str(t.get("id", ""))
                break
        if tid != "":
            wrapped.append("[url=trait:%s][b]%s[/b][/url]" % [tid, n])
        else:
            wrapped.append("[b]%s[/b]" % n)
    return "、".join(wrapped)


func _all_trait_entries() -> Array:
    var arr: Array = []
    for tid in GameData.traits.keys():
        var t: Dictionary = (GameData.traits[tid] as Dictionary).duplicate()
        t["id"] = tid
        arr.append(t)
    return arr


func _roll_traits(count: int) -> Array:
    var avail: = _all_trait_entries()
    var chosen: Array = []
    for n in count:
        if avail.is_empty():
            break
        var total: = 0.0
        for t in avail:
            total += maxf(0.01, float(t.get("weight", 1)))
        var r: = randf() * total
        var acc: = 0.0
        var pick: Dictionary = avail[0]
        for t in avail:
            acc += maxf(0.01, float(t.get("weight", 1)))
            if r <= acc:
                pick = t
                break
        chosen.append(pick)
        avail.erase(pick)
    return chosen


func _reel_frame_style(active: bool = false) -> StyleBoxFlat:
    var s: = StyleBoxFlat.new()
    s.bg_color = Color(0.04, 0.032, 0.024, 0.78)
    s.border_color = GOLD
    s.border_color.a = 0.78 if active else 0.4
    var bw: = 2 if active else 1
    s.border_width_left = bw
    s.border_width_top = bw
    s.border_width_right = bw
    s.border_width_bottom = bw
    s.corner_radius_top_left = 6
    s.corner_radius_top_right = 6
    s.corner_radius_bottom_left = 6
    s.corner_radius_bottom_right = 6
    if active:
        s.shadow_color = Color(0.85, 0.66, 0.3, 0.3)
        s.shadow_size = 8
    return s

func _make_fade_texture() -> GradientTexture2D:
    var tex: = GradientTexture2D.new()
    tex.fill_from = Vector2(0, 0)
    tex.fill_to = Vector2(0, 1)
    var g: = Gradient.new()
    g.set_color(0, Color(0.04, 0.032, 0.024, 0.92))
    g.set_color(1, Color(0.04, 0.032, 0.024, 0.92))
    g.add_point(0.3, Color(0.04, 0.032, 0.024, 0.0))
    g.add_point(0.7, Color(0.04, 0.032, 0.024, 0.0))
    tex.gradient = g
    tex.width = 4
    tex.height = 64
    return tex

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

func _style_primary_button(btn: Button) -> void :
    btn.add_theme_stylebox_override("normal", _button_style(Color(0.44, 0.31, 0.15, 0.96) if GameState.theme == "dark" else Color(0.58, 0.43, 0.22, 0.96), Color(0.82, 0.7, 0.46, 0.4)))
    btn.add_theme_stylebox_override("hover", _button_style(Color(0.56, 0.4, 0.2, 1.0) if GameState.theme == "dark" else Color(0.68, 0.52, 0.29, 1.0), Color(0.95, 0.82, 0.52, 0.58)))
    btn.add_theme_stylebox_override("pressed", _button_style(Color(0.34, 0.23, 0.1, 1.0) if GameState.theme == "dark" else Color(0.48, 0.35, 0.17, 1.0), Color(0.95, 0.82, 0.52, 0.44)))
    btn.add_theme_stylebox_override("disabled", _button_style(Color(0.2, 0.17, 0.13, 0.78), Color(0.48, 0.4, 0.28, 0.2)))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

    btn.add_theme_color_override("font_color", Color(0.98, 0.93, 0.84, 1.0))
    btn.add_theme_color_override("font_hover_color", Color(1.0, 0.96, 0.88, 1.0))
    btn.add_theme_color_override("font_disabled_color", Color(0.56, 0.51, 0.43, 0.78))

func _style_secondary_button(btn: Button) -> void :
    btn.add_theme_stylebox_override("normal", _button_style(Color(0.02, 0.018, 0.014, 0.62), Color(0.72, 0.56, 0.28, 0.25)))
    btn.add_theme_stylebox_override("hover", _button_style(Color(0.16, 0.1, 0.05, 0.62), Color(0.8, 0.62, 0.32, 0.42)))
    btn.add_theme_stylebox_override("pressed", _button_style(Color(0.1, 0.07, 0.035, 0.76), Color(0.8, 0.62, 0.32, 0.42)))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

    var norm_color = Color(0.74, 0.64, 0.45, 0.9)
    var hover_color = Color(0.96, 0.84, 0.58, 1.0)
    btn.add_theme_color_override("font_color", norm_color)
    btn.add_theme_color_override("font_hover_color", hover_color)
    btn.add_theme_color_override("font_pressed_color", hover_color)

    btn.add_theme_color_override("icon_normal_color", norm_color)
    btn.add_theme_color_override("icon_hover_color", hover_color)
    btn.add_theme_color_override("icon_pressed_color", hover_color)
    btn.add_theme_color_override("icon_focus_color", hover_color)

func _kill_land_tweens() -> void :
    for tw in _land_tweens:
        if tw != null and tw.is_valid():
            tw.kill()
    _land_tweens.clear()

func _apply_native_mobile_font_scale() -> void :
    if not OS.has_feature("android"):
        return
    NativeMobileFontScalerRef.apply_to(self)


func _on_summary_meta_hover_started(meta: Variant) -> void :
    var meta_str = str(meta)
    if meta_str.begins_with("trait:"):
        var trait_id = meta_str.split(":")[1]
        if _pinned_trait_id == "":
            _show_trait_tooltip_near_control(trait_id, _summary_label)

func _on_summary_meta_hover_ended(meta: Variant) -> void :
    var meta_str = str(meta)
    if meta_str.begins_with("trait:"):
        if _pinned_trait_id == "":
            _hide_trait_tooltip()

func _on_summary_meta_clicked(meta: Variant) -> void :
    var meta_str = str(meta)
    if meta_str.begins_with("trait:"):
        var trait_id = meta_str.split(":")[1]
        get_viewport().set_input_as_handled()
        if _pinned_trait_id == trait_id:
            _hide_trait_tooltip()
        else:
            _pinned_trait_id = trait_id
            _show_trait_tooltip_near_control(trait_id, _summary_label)

func _on_band_mouse_entered(trait_id: String, band: Control) -> void :
    if _pinned_trait_id == "":
        _show_trait_tooltip_near_control(trait_id, band)

func _on_band_mouse_exited(_trait_id: String) -> void :
    if _pinned_trait_id == "":
        _hide_trait_tooltip()

func _on_band_gui_input(event: InputEvent, trait_id: String, band: Control) -> void :
    if event is InputEventMouseButton and event.pressed:
        get_viewport().set_input_as_handled()
        if _pinned_trait_id == trait_id:
            _hide_trait_tooltip()
        else:
            _pinned_trait_id = trait_id
            _show_trait_tooltip_near_control(trait_id, band)

func _show_trait_tooltip_near_control(trait_id: String, anchor: Control) -> void :
    var trait_data: Dictionary = {}
    if GameData.traits.has(trait_id):
        trait_data = GameData.traits[trait_id]
    if trait_data.is_empty():
        return


    if _trait_tooltip != null and is_instance_valid(_trait_tooltip):
        _trait_tooltip.queue_free()

    var compact: = _is_compact()

    _trait_tooltip = PanelContainer.new()
    _trait_tooltip.mouse_filter = Control.MOUSE_FILTER_PASS

    var style: = StyleBoxFlat.new()
    if GameState.theme == "light":
        style.bg_color = Color(0.95, 0.93, 0.9, 0.98)
        style.border_color = Color(0.72, 0.56, 0.28, 0.8)
    else:
        style.bg_color = Color(0.08, 0.06, 0.05, 0.98)
        style.border_color = Color(0.85, 0.66, 0.3, 0.8)
    style.border_width_left = 2
    style.border_width_top = 2
    style.border_width_right = 2
    style.border_width_bottom = 2
    style.corner_radius_top_left = 6
    style.corner_radius_top_right = 6
    style.corner_radius_bottom_left = 6
    style.corner_radius_bottom_right = 6
    style.shadow_color = Color(0, 0, 0, 0.4)
    style.shadow_size = 10
    style.content_margin_left = 16
    style.content_margin_right = 16
    style.content_margin_top = 12
    style.content_margin_bottom = 12
    _trait_tooltip.add_theme_stylebox_override("panel", style)

    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 8)
    _trait_tooltip.add_child(vbox)

    var title_row: = HBoxContainer.new()
    title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.add_child(title_row)

    var name_label: = Label.new()
    name_label.text = str(trait_data.get("name", ""))
    name_label.add_theme_font_override("font", FONT_BOLD)
    name_label.add_theme_font_size_override("font_size", 24 if compact else 16)
    name_label.add_theme_color_override("font_color", GOLD)
    title_row.add_child(name_label)

    var spacer: = Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title_row.add_child(spacer)

    var type_label: = Label.new()
    var polarity = str(trait_data.get("polarity", "positive"))
    type_label.text = "〔正面天资〕" if polarity == "positive" else "〔负面天资〕"
    type_label.add_theme_font_override("font", FONT_BODY)
    type_label.add_theme_font_size_override("font_size", 18 if compact else 12)
    type_label.add_theme_color_override("font_color", Color(0.27, 0.65, 0.35) if polarity == "positive" else Color(0.85, 0.35, 0.25))
    title_row.add_child(type_label)

    var line: = ColorRect.new()
    line.custom_minimum_size = Vector2(0, 1)
    line.color = Color(GOLD.r, GOLD.g, GOLD.b, 0.3)
    vbox.add_child(line)

    var desc_label: = Label.new()
    desc_label.text = str(trait_data.get("desc", ""))
    desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    desc_label.add_theme_font_override("font", FONT_BODY)
    desc_label.add_theme_font_size_override("font_size", 22 if compact else 14)
    desc_label.add_theme_color_override("font_color", INK_DEEP)
    vbox.add_child(desc_label)

    var effects: Dictionary = trait_data.get("effects", {})
    if not effects.is_empty():
        var eff_parts: Array = []
        for key in effects.keys():
            var val = effects[key]
            var val_str = ("+" + str(val)) if val >= 0 else str(val)
            var attr_name = _STAT_LABEL_MAP.get(key, key)
            eff_parts.append("%s %s" % [attr_name, val_str])

        if not eff_parts.is_empty():
            var eff_label: = Label.new()
            eff_label.text = "开局效果：" + "，".join(eff_parts)
            eff_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            eff_label.add_theme_font_override("font", FONT_BODY)
            eff_label.add_theme_font_size_override("font_size", 20 if compact else 13)
            eff_label.add_theme_color_override("font_color", MUTED)

            var eff_spacer: = Control.new()
            eff_spacer.custom_minimum_size = Vector2(0, 4)
            vbox.add_child(eff_spacer)
            vbox.add_child(eff_label)

    add_child(_trait_tooltip)

    _trait_tooltip.custom_minimum_size = Vector2(320.0 if compact else 260.0, 0)


    NativeMobileFontScalerRef.apply_to(_trait_tooltip)
    _trait_tooltip.reset_size()

    var anchor_rect: = anchor.get_global_rect()
    var self_rect: = get_global_rect()
    var tooltip_size: = _trait_tooltip.size
    var target_pos: = Vector2.ZERO

    target_pos.x = anchor_rect.position.x + (anchor_rect.size.x - tooltip_size.x) * 0.5
    target_pos.y = anchor_rect.position.y - tooltip_size.y - 10.0

    if target_pos.y < self_rect.position.y + 10.0:
        target_pos.y = anchor_rect.position.y + anchor_rect.size.y + 10.0

    target_pos.x = clampf(target_pos.x, self_rect.position.x + 10.0, self_rect.position.x + self_rect.size.x - tooltip_size.x - 10.0)
    target_pos.y = clampf(target_pos.y, self_rect.position.y + 10.0, self_rect.position.y + self_rect.size.y - tooltip_size.y - 10.0)

    _trait_tooltip.global_position = target_pos

func _hide_trait_tooltip() -> void :
    if _trait_tooltip != null and is_instance_valid(_trait_tooltip):
        _trait_tooltip.queue_free()
    _trait_tooltip = null
    _pinned_trait_id = ""

func _unhandled_input(event: InputEvent) -> void :
    if event is InputEventMouseButton and event.pressed:
        if _pinned_trait_id != "" and _trait_tooltip != null and is_instance_valid(_trait_tooltip):
            var click_pos = event.global_position
            if not _trait_tooltip.get_global_rect().has_point(click_pos):
                _hide_trait_tooltip()
