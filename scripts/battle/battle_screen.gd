extends Control






signal battle_finished(grade: String)

const FontLoader = preload("res://scripts/ui/font_loader.gd")
const BattleModel = preload("res://scripts/battle/battle_model.gd")
const T = preload("res://scripts/battle/battle_types.gd")

const GOLD: = Color(0.86, 0.7, 0.42, 1.0)
const INK: = Color(0.9, 0.86, 0.74, 0.96)
const MUTED: = Color(0.66, 0.62, 0.54, 0.9)
const RED: = Color(0.8, 0.34, 0.26, 1.0)
const WARM_HOVER_BG: = Color(0.16, 0.1, 0.05, 0.62)
const WARM_BORDER: = Color(0.8, 0.62, 0.32, 0.42)

const ALLY_BORDER: = Color(0.5, 0.64, 0.42, 1.0)
const ALLY_NAME: = Color(0.64, 0.8, 0.52, 1.0)
const ALLY_HP: = Color(0.48, 0.66, 0.42, 0.95)
const PLAYER_HP: = Color(0.74, 0.63, 0.36, 0.95)
const ENEMY_HP: = Color(0.72, 0.4, 0.32, 0.95)


const TICK_BASE: = 2.6
const START_DELAY: = 1.6
const FOCUS_CD: = 6.0
const FOCUS_TICKS: = 2
const ROTATE_CD: = 5.0
const ENEMY_ROTATE_MAX: = 3
const ENEMY_ROTATE_GAP_MIN: = 10.0
const ENEMY_ROTATE_GAP_MAX: = 26.0
const FRONT_CARD_SIZE: = Vector2(138, 105)
const MORALE_BAR_SIZE: = Vector2(160, 9)
const FRONT_ROW_GAP: = 8
const BATTLE_PANEL_MIN_WIDTH: = 760
const LOG_PANEL_MIN_WIDTH: = 360

var FONT_TITLE: Font = FontLoader.title()
var FONT_BODY: Font = FontLoader.body()
var FONT_BOLD: Font = FontLoader.serif_bold()

@onready var background: TextureRect = $Background
@onready var overlay: ColorRect = $Overlay

var model: BattleModel = null
var _showing_result: = false
var _paused: = false
var _speed: = 1.0
var _tick_accum: = 0.0
var _focus_cd: = 0.0
var _focus_pos: = -1
var _focus_ticks_left: = 0
var _last_engage: Array = []
var _rotate_cd: = 0.0
var _battle_elapsed: = 0.0
var _enemy_rot_count: = 0
var _enemy_rot_next: = 0.0


var _turn_lbl: Label = null
var _res_lbl: Label = null
var _summary_lbl: Label = null
var _morale_fill: Control = null
var _morale_lbl: Label = null
var _tick_fill: Control = null
var _pause_btn: Button = null
var _speed_btn: Button = null
var _player_cards: Array = []
var _enemy_cards: Array = []
var _battle_log_box: VBoxContainer = null
var _battle_log_entries: Array = []
var _skill_btns: Dictionary = {}
var _player_section_lbl: Label = null
var _enemy_section_lbl: Label = null
var _rotate_left_btn: Button = null
var _rotate_right_btn: Button = null
var _used_auto: = false
var _result_pending: = false


var _pending_config: Dictionary = {}
var _muster_layer: Control = null
var _muster_selected: Array = []
var _muster_cards: Array = []
var _muster_count_lbl: Label = null
var _muster_go_btn: Button = null

func _ready() -> void :
    set_process(false)



func start_battle(config: Dictionary) -> void :
    var roster: Array = config.get("player_units", [])
    var slots: = clampi(int(config.get("front_slots", 5)), 1, 6)
    if roster.size() > slots:
        _pending_config = config
        visible = true
        _show_muster_panel(roster, slots)
        return
    _begin_battle(config)

func _begin_battle(config: Dictionary) -> void :
    _close_muster_panel()
    model = BattleModel.new()
    model.setup(config)
    _showing_result = false
    _paused = false
    _speed = 1.0
    _tick_accum = - START_DELAY
    _focus_cd = 0.0
    _focus_pos = -1
    _focus_ticks_left = 0
    _last_engage = []
    _rotate_cd = 0.0
    _battle_elapsed = 0.0
    _enemy_rot_count = 0
    _enemy_rot_next = randf_range(ENEMY_ROTATE_GAP_MIN + 2.0, ENEMY_ROTATE_GAP_MAX)
    _battle_log_entries = []
    _used_auto = false
    _result_pending = false
    visible = true
    _build_ui()
    _refresh_all()
    _play_start_banner()
    set_process(true)





func _show_muster_panel(roster: Array, slots: int) -> void :
    _close_muster_panel()
    _muster_selected = []
    _muster_cards = []
    for i in range(mini(slots, roster.size())):
        _muster_selected.append(i)

    _muster_layer = Control.new()
    _muster_layer.name = "MusterLayer"
    _muster_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(_muster_layer)

    var dim: = ColorRect.new()
    dim.color = Color(0.03, 0.02, 0.01, 0.88)
    dim.set_anchors_preset(Control.PRESET_FULL_RECT)
    _muster_layer.add_child(dim)

    var center: = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    _muster_layer.add_child(center)

    var panel: = PanelContainer.new()
    var pbox: = StyleBoxFlat.new()
    pbox.bg_color = Color(0.09, 0.07, 0.045, 0.97)
    pbox.border_color = WARM_BORDER
    pbox.set_border_width_all(1)
    pbox.set_corner_radius_all(10)
    pbox.content_margin_left = 28;pbox.content_margin_right = 28
    pbox.content_margin_top = 22;pbox.content_margin_bottom = 22
    panel.add_theme_stylebox_override("panel", pbox)
    center.add_child(panel)

    var col: = VBoxContainer.new()
    col.add_theme_constant_override("separation", 12)
    panel.add_child(col)

    var title: = Label.new()
    title.text = "战 前 点 将"
    title.add_theme_font_override("font", FONT_TITLE)
    title.add_theme_font_size_override("font_size", 26)
    title.add_theme_color_override("font_color", GOLD)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    col.add_child(title)

    var pos_names: Array = []
    for i in range(slots):
        pos_names.append(str(T.POS_NAMES.get(T.FRONT_POSITIONS[i], "")))
    var sub: = Label.new()
    sub.text = "本阵可容 %d 队。点选顺序即入阵顺序：%s。入阵后名单锁定，战中无替补。" % [slots, " → ".join(pos_names)]
    sub.add_theme_font_override("font", FONT_BODY)
    sub.add_theme_font_size_override("font_size", 13)
    sub.add_theme_color_override("font_color", MUTED)
    sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    sub.custom_minimum_size = Vector2(560, 0)
    col.add_child(sub)

    var grid: = GridContainer.new()
    grid.columns = 3
    grid.add_theme_constant_override("h_separation", 10)
    grid.add_theme_constant_override("v_separation", 10)
    col.add_child(grid)
    for i in range(roster.size()):
        var refs: = _make_muster_card(roster[i], i)
        grid.add_child(refs["root"])
        _muster_cards.append(refs)

    var foot: = HBoxContainer.new()
    foot.add_theme_constant_override("separation", 18)
    foot.alignment = BoxContainer.ALIGNMENT_CENTER
    col.add_child(foot)
    _muster_count_lbl = Label.new()
    _muster_count_lbl.add_theme_font_override("font", FONT_BODY)
    _muster_count_lbl.add_theme_font_size_override("font_size", 15)
    _muster_count_lbl.add_theme_color_override("font_color", INK)
    foot.add_child(_muster_count_lbl)
    _muster_go_btn = _action_button("擂 鼓 开 战", func(): _confirm_muster())
    foot.add_child(_muster_go_btn)

    _refresh_muster(slots)


func _roster_info(entry) -> Dictionary:
    var uid: = str(entry) if typeof(entry) == TYPE_STRING else str(entry.get("id", ""))
    var d: = T.unit_def(uid)
    var info: = {
        "name": str(d.get("name", uid)), 
        "hp": int(d.get("hp", 0)), 
        "elite": bool(d.get("elite", false)), 
        "ally": false, 
        "cat": str(d.get("cat", "")), 
    }
    if typeof(entry) == TYPE_DICTIONARY:
        if entry.has("name"):
            info["name"] = str(entry["name"])
        if entry.has("hp"):
            info["hp"] = int(entry["hp"])
        if bool(entry.get("ally", false)):
            info["ally"] = true
    return info

func _make_muster_card(entry, idx: int) -> Dictionary:
    var info: = _roster_info(entry)
    var card: = Button.new()
    card.focus_mode = Control.FOCUS_NONE
    card.custom_minimum_size = Vector2(188, 92)
    card.pressed.connect( func(): _toggle_muster(idx))

    var inner: = VBoxContainer.new()
    inner.set_anchors_preset(Control.PRESET_FULL_RECT)
    inner.alignment = BoxContainer.ALIGNMENT_CENTER
    inner.add_theme_constant_override("separation", 2)
    inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
    card.add_child(inner)

    var name_lbl: = Label.new()
    var name_text: String = str(info["name"])
    if info["elite"]:
        name_text = "%s ·精锐" % name_text
    if info["ally"]:
        name_text = "%s ·援军" % name_text
    name_lbl.text = name_text
    name_lbl.add_theme_font_override("font", FONT_BOLD)
    name_lbl.add_theme_font_size_override("font_size", 15)
    name_lbl.add_theme_color_override("font_color", ALLY_NAME if info["ally"] else INK)
    name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
    inner.add_child(name_lbl)

    var cat_names: = {"pole": "长兵", "cav": "骑兵", "ranged": "远程", "shield": "刀盾"}
    var meta_lbl: = Label.new()
    meta_lbl.text = "%s · 编制 %d" % [cat_names.get(info["cat"], "步队"), info["hp"]]
    meta_lbl.add_theme_font_override("font", FONT_BODY)
    meta_lbl.add_theme_font_size_override("font_size", 12)
    meta_lbl.add_theme_color_override("font_color", MUTED)
    meta_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    meta_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
    inner.add_child(meta_lbl)

    var badge: = Label.new()
    badge.add_theme_font_override("font", FONT_BODY)
    badge.add_theme_font_size_override("font_size", 12)
    badge.add_theme_color_override("font_color", GOLD)
    badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
    inner.add_child(badge)

    return {"root": card, "idx": idx, "badge": badge, "ally": info["ally"]}

func _toggle_muster(idx: int) -> void :
    var slots: = clampi(int(_pending_config.get("front_slots", 5)), 1, 6)
    if idx in _muster_selected:
        _muster_selected.erase(idx)
    elif _muster_selected.size() < slots:
        _muster_selected.append(idx)
    _refresh_muster(slots)

func _refresh_muster(slots: int) -> void :
    for refs in _muster_cards:
        var idx: int = refs["idx"]
        var order: = _muster_selected.find(idx)
        var selected: = order >= 0
        var badge: Label = refs["badge"]
        if selected:
            badge.text = "上阵 · %s" % str(T.POS_NAMES.get(T.FRONT_POSITIONS[order], ""))
        else:
            badge.text = "候 命"
        badge.add_theme_color_override("font_color", GOLD if selected else Color(0.5, 0.46, 0.4, 0.7))
        var box: = StyleBoxFlat.new()
        box.set_corner_radius_all(8)
        box.set_border_width_all(2 if selected else 1)
        if selected:
            box.bg_color = Color(0.15, 0.11, 0.055, 0.95)
            box.border_color = ALLY_BORDER if bool(refs["ally"]) else GOLD
        else:
            box.bg_color = Color(0.08, 0.065, 0.045, 0.9)
            box.border_color = Color(0.4, 0.34, 0.24, 0.4)
        var hover: = box.duplicate() as StyleBoxFlat
        hover.bg_color = WARM_HOVER_BG
        hover.border_color = WARM_BORDER if not selected else hover.border_color
        var card: Button = refs["root"]
        card.add_theme_stylebox_override("normal", box)
        card.add_theme_stylebox_override("hover", hover)
        card.add_theme_stylebox_override("pressed", hover)
        card.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    var need: = mini(slots, _muster_cards.size())
    if _muster_count_lbl != null:
        _muster_count_lbl.text = "已点 %d / %d 队" % [_muster_selected.size(), need]
    if _muster_go_btn != null:
        _muster_go_btn.disabled = _muster_selected.size() != need

func _confirm_muster() -> void :
    var roster: Array = _pending_config.get("player_units", [])
    var chosen: Array = []
    for idx in _muster_selected:
        if idx >= 0 and idx < roster.size():
            chosen.append(roster[idx])
    var cfg: Dictionary = _pending_config.duplicate(true)
    cfg["player_units"] = chosen
    _pending_config = {}
    _begin_battle(cfg)

func _close_muster_panel() -> void :
    if _muster_layer != null and is_instance_valid(_muster_layer):
        _muster_layer.queue_free()
    _muster_layer = null
    _muster_cards = []
    _muster_count_lbl = null
    _muster_go_btn = null




func _process(delta: float) -> void :
    if model == null or model.finished or _showing_result or _result_pending:
        return
    if _paused:
        return
    var d: = delta * _speed
    _focus_cd = maxf(0.0, _focus_cd - d)

    _rotate_cd = maxf(0.0, _rotate_cd - delta)
    _update_rotate_buttons()
    _battle_elapsed += delta
    if _enemy_rot_count < ENEMY_ROTATE_MAX and _battle_elapsed >= _enemy_rot_next and _tick_accum >= 0.0:
        _enemy_rot_count += 1
        _enemy_rot_next = _battle_elapsed + randf_range(ENEMY_ROTATE_GAP_MIN, ENEMY_ROTATE_GAP_MAX)
        _enemy_rotate()
    _tick_accum += d
    _update_tick_bar()
    _update_hint()
    if _tick_accum >= TICK_BASE:
        _tick_accum = 0.0
        _run_round()

func _run_round() -> void :
    model.turn += 1

    if _focus_ticks_left > 0 and _focus_alive(_focus_pos):
        model.set_focus(_focus_pos)
    else:
        model.set_focus(-1)
        _focus_ticks_left = 0
        _focus_pos = -1
    _last_engage = model.engage_phase()
    _animate_engage(_last_engage)
    var enemy_move: = model.enemy_act()
    _append_battle_log_lines(_last_engage, enemy_move)
    model.resolve_phase()
    if _focus_ticks_left > 0:
        _focus_ticks_left -= 1
        if _focus_ticks_left <= 0 or not _focus_alive(_focus_pos):
            _focus_pos = -1
            _focus_ticks_left = 0
    if model.check_finished():
        _refresh_all()
        _result_pending = true
        var result_delay: = maxf(0.75, float(_last_engage.size()) * 0.12 + 0.8) / maxf(0.1, _speed)
        var timer: = get_tree().create_timer(result_delay)
        timer.timeout.connect( func():
            if model == null or not visible or _showing_result:
                return
            _result_pending = false
            _show_result()
        )
        return
    _refresh_all()
func _focus_alive(pos: int) -> bool:
    if pos < 0 or pos >= model.enemy_front.size():
        return false

    return model.is_targetable(model.enemy_front, pos)




func _clear() -> void :
    for c in get_children():
        if c == background or c == overlay:
            continue
        c.queue_free()

func _build_ui() -> void :
    _clear()
    _player_cards = []
    _enemy_cards = []
    _skill_btns = {}
    _battle_log_box = null
    _rotate_left_btn = null
    _rotate_right_btn = null

    var margin: = MarginContainer.new()
    margin.set_anchors_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 34)
    margin.add_theme_constant_override("margin_right", 34)
    margin.add_theme_constant_override("margin_top", 18)
    margin.add_theme_constant_override("margin_bottom", 18)
    add_child(margin)

    var root: = VBoxContainer.new()
    root.add_theme_constant_override("separation", 8)
    margin.add_child(root)

    var middle: = HBoxContainer.new()
    middle.add_theme_constant_override("separation", 18)
    middle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(middle)

    middle.add_child(_build_battle_area())
    middle.add_child(_build_battle_log_panel())

    root.add_child(_build_action_bar())

func _build_battle_area() -> Control:
    var panel: = PanelContainer.new()
    panel.custom_minimum_size = Vector2(BATTLE_PANEL_MIN_WIDTH, 0)
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    panel.add_theme_stylebox_override("panel", _area_panel_style(Color(0.07, 0.055, 0.035, 0.22), 0.0))

    var pad: = MarginContainer.new()
    pad.add_theme_constant_override("margin_left", 16)
    pad.add_theme_constant_override("margin_right", 16)
    pad.add_theme_constant_override("margin_top", 10)
    pad.add_theme_constant_override("margin_bottom", 10)
    panel.add_child(pad)

    var area: = VBoxContainer.new()
    area.add_theme_constant_override("separation", 7)
    area.size_flags_vertical = Control.SIZE_EXPAND_FILL
    pad.add_child(area)


    _enemy_section_lbl = _section_label("敌阵", false)
    _enemy_section_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    area.add_child(_enemy_section_lbl)


    var spacer_top: = Control.new()
    spacer_top.size_flags_vertical = Control.SIZE_EXPAND_FILL
    area.add_child(spacer_top)


    area.add_child(_build_front_cross(false))
    _enemy_cards.sort_custom( func(a, b): return int(a["pos"]) < int(b["pos"]))


    var summary_margin: = MarginContainer.new()
    summary_margin.add_theme_constant_override("margin_top", 16)
    summary_margin.add_theme_constant_override("margin_bottom", 16)

    _summary_lbl = Label.new()
    _summary_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _summary_lbl.add_theme_font_override("font", FONT_BODY)
    _summary_lbl.add_theme_font_size_override("font_size", 13)
    _summary_lbl.add_theme_color_override("font_color", MUTED)
    summary_margin.add_child(_summary_lbl)
    area.add_child(summary_margin)


    area.add_child(_build_front_cross(true))
    _player_cards.sort_custom( func(a, b): return int(a["pos"]) < int(b["pos"]))


    var spacer_bottom: = Control.new()
    spacer_bottom.size_flags_vertical = Control.SIZE_EXPAND_FILL
    area.add_child(spacer_bottom)


    _player_section_lbl = _section_label("我阵", true)
    _player_section_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    area.add_child(_player_section_lbl)

    return panel

func _build_battle_log_panel() -> Control:
    var panel: = PanelContainer.new()
    panel.custom_minimum_size = Vector2(LOG_PANEL_MIN_WIDTH, 0)
    panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    panel.add_theme_stylebox_override("panel", _area_panel_style(Color(0.08, 0.065, 0.04, 0.34), 0.34))

    var pad: = MarginContainer.new()
    pad.add_theme_constant_override("margin_left", 14)
    pad.add_theme_constant_override("margin_right", 14)
    pad.add_theme_constant_override("margin_top", 12)
    pad.add_theme_constant_override("margin_bottom", 12)
    panel.add_child(pad)

    var col: = VBoxContainer.new()
    col.add_theme_constant_override("separation", 12)
    col.size_flags_vertical = Control.SIZE_EXPAND_FILL
    pad.add_child(col)

    col.add_child(_build_card_header())

    var header_sep: = HSeparator.new()
    col.add_child(header_sep)

    col.add_child(_section_label("战斗信息", true))
    col.add_child(_build_resource_bar())

    var sep: = HSeparator.new()
    col.add_child(sep)

    col.add_child(_section_label("战斗记录", true))

    _battle_log_box = VBoxContainer.new()
    _battle_log_box.add_theme_constant_override("separation", 8)
    _battle_log_box.alignment = BoxContainer.ALIGNMENT_BEGIN
    _battle_log_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _battle_log_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
    col.add_child(_battle_log_box)

    var spacer: = Control.new()
    spacer.custom_minimum_size = Vector2(0, 8)
    col.add_child(spacer)

    col.add_child(_build_compact_controls())
    return panel

func _area_panel_style(bg: Color, border_alpha: float) -> StyleBoxFlat:
    var s: = StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = WARM_BORDER
    s.border_color.a = border_alpha
    s.set_border_width_all(1)
    s.set_corner_radius_all(6)
    s.content_margin_left = 0
    s.content_margin_right = 0
    s.content_margin_top = 0
    s.content_margin_bottom = 0
    return s

func _build_front_cross(is_player: bool) -> Control:

    var left_refs: = _make_card(T.POS_LEFT, is_player, model.front_slots >= 2)
    var feng_refs: = _make_card(T.POS_FENG, is_player, model.front_slots >= 1)
    var right_refs: = _make_card(T.POS_RIGHT, is_player, model.front_slots >= 4)
    var rear_l_refs: = _make_card(T.POS_REAR, is_player, model.front_slots >= 5)
    var center_refs: = _make_card(T.POS_CENTER, is_player, model.front_slots >= 3)
    var rear_r_refs: = _make_card(T.POS_REAR_R, is_player, model.front_slots >= 6)
    for refs in [left_refs, feng_refs, right_refs, rear_l_refs, center_refs, rear_r_refs]:
        _register_front_card(refs, is_player)

    var grid: = VBoxContainer.new()
    grid.add_theme_constant_override("separation", FRONT_ROW_GAP)
    var row_1: = _card_row([left_refs["root"], feng_refs["root"], right_refs["root"]])
    var row_2: = _card_row([rear_l_refs["root"], center_refs["root"], rear_r_refs["root"]])
    if is_player:
        grid.add_child(row_1)
        grid.add_child(row_2)
    else:
        grid.add_child(row_2)
        grid.add_child(row_1)


    var line: = HBoxContainer.new()
    line.add_theme_constant_override("separation", 30)
    line.alignment = BoxContainer.ALIGNMENT_CENTER
    if is_player:
        _rotate_left_btn = _make_rotate_button(false)
        line.add_child(_rotate_left_btn)
    line.add_child(grid)
    if is_player:
        _rotate_right_btn = _make_rotate_button(true)
        line.add_child(_rotate_right_btn)

    var outer: = CenterContainer.new()
    outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    outer.add_child(line)
    return outer

func _card_row(cards: Array) -> Control:
    var row: = HBoxContainer.new()
    row.add_theme_constant_override("separation", 14)
    row.alignment = BoxContainer.ALIGNMENT_CENTER
    for card in cards:
        row.add_child(card)
    return row

func _register_front_card(refs: Dictionary, is_player: bool) -> void :
    if is_player:
        _player_cards.append(refs)
    else:
        _enemy_cards.append(refs)

func _build_card_header() -> Control:
    var vb: = VBoxContainer.new()
    vb.add_theme_constant_override("separation", 6)

    var title_row: = HBoxContainer.new()
    title_row.add_theme_constant_override("separation", 10)
    title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    var title: = Label.new()
    title.text = str(model.objective.get("title", "军阵交锋"))
    title.add_theme_font_override("font", FONT_TITLE)
    title.add_theme_font_size_override("font_size", 18)
    title.add_theme_color_override("font_color", GOLD)
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title_row.add_child(title)

    _turn_lbl = Label.new()
    _turn_lbl.add_theme_font_override("font", FONT_BOLD)
    _turn_lbl.add_theme_font_size_override("font_size", 13)
    _turn_lbl.add_theme_color_override("font_color", GOLD)
    title_row.add_child(_turn_lbl)

    var tick_wrap: = _make_bar_bg(Vector2(70, 6), Color(0.09, 0.07, 0.045, 0.9))
    _tick_fill = _make_bar_fill(tick_wrap, Color(0.62, 0.5, 0.3, 0.85))
    var tick_center: = CenterContainer.new()
    tick_center.add_child(tick_wrap)
    title_row.add_child(tick_center)

    vb.add_child(title_row)

    var obj: = Label.new()
    obj.text = "目标：" + model.objective_text()
    obj.add_theme_font_override("font", FONT_BODY)
    obj.add_theme_font_size_override("font_size", 12)
    obj.add_theme_color_override("font_color", INK)
    obj.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vb.add_child(obj)

    return vb

func _build_resource_bar() -> Control:
    var vb: = VBoxContainer.new()
    vb.add_theme_constant_override("separation", 6)

    var ter_name: = str(T.TERRAIN.get(model.terrain, {}).get("name", "平原"))
    _res_lbl = Label.new()
    _res_lbl.add_theme_font_override("font", FONT_BODY)
    _res_lbl.add_theme_font_size_override("font_size", 13)
    _res_lbl.add_theme_color_override("font_color", MUTED)
    _res_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _res_lbl.text = "地形：%s" % ter_name
    vb.add_child(_res_lbl)

    var morale_row: = HBoxContainer.new()
    morale_row.add_theme_constant_override("separation", 10)

    var morale_tag: = Label.new()
    morale_tag.text = "士气"
    morale_tag.add_theme_font_override("font", FONT_BODY)
    morale_tag.add_theme_font_size_override("font_size", 13)
    morale_tag.add_theme_color_override("font_color", MUTED)
    morale_row.add_child(morale_tag)

    var bar: = _make_bar_bg(MORALE_BAR_SIZE, Color(0.09, 0.07, 0.045, 0.9))
    _morale_fill = _make_bar_fill(bar, GOLD)
    var bar_center: = CenterContainer.new()
    bar_center.add_child(bar)
    morale_row.add_child(bar_center)

    _morale_lbl = Label.new()
    _morale_lbl.add_theme_font_override("font", FONT_BODY)
    _morale_lbl.add_theme_font_size_override("font_size", 13)
    _morale_lbl.add_theme_color_override("font_color", MUTED)
    morale_row.add_child(_morale_lbl)

    vb.add_child(morale_row)
    return vb

func _make_bar_bg(size_v: Vector2, bg: Color) -> Control:
    var wrap: = Panel.new()
    wrap.custom_minimum_size = size_v
    var s: = StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = WARM_BORDER
    s.set_border_width_all(1)
    s.set_corner_radius_all(3)
    wrap.add_theme_stylebox_override("panel", s)
    return wrap

func _make_bar_fill(wrap: Control, color: Color) -> Control:
    var fill: = Panel.new()
    var s: = StyleBoxFlat.new()
    s.bg_color = color
    s.set_corner_radius_all(3)
    fill.add_theme_stylebox_override("panel", s)
    fill.position = Vector2(1, 1)
    fill.size = Vector2(0, wrap.custom_minimum_size.y - 2)
    fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
    wrap.add_child(fill)
    return fill


func _set_hp_fill_color(fill: Control, c: Color) -> void :
    var sb = fill.get_theme_stylebox("panel")
    if sb is StyleBoxFlat:
        (sb as StyleBoxFlat).bg_color = c

func _section_label(txt: String, is_player: bool) -> Label:
    var l: = Label.new()
    l.text = txt
    l.add_theme_font_override("font", FONT_BOLD)
    l.add_theme_font_size_override("font_size", 14)
    l.add_theme_color_override("font_color", Color(0.74, 0.62, 0.42, 0.9) if is_player else Color(0.72, 0.46, 0.38, 0.9))
    return l


func _make_card(pos: int, is_player: bool, enabled: bool) -> Dictionary:
    var card: = Button.new()
    card.custom_minimum_size = FRONT_CARD_SIZE
    card.focus_mode = Control.FOCUS_NONE
    card.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    card.pivot_offset = card.custom_minimum_size / 2.0

    var vb: = VBoxContainer.new()
    vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
    vb.set_anchors_preset(Control.PRESET_FULL_RECT)
    vb.offset_left = 10;vb.offset_right = -10;vb.offset_top = 8;vb.offset_bottom = -9
    vb.add_theme_constant_override("separation", 2)
    card.add_child(vb)

    var pos_lbl: = Label.new()
    pos_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    pos_lbl.add_theme_font_override("font", FONT_BODY)
    pos_lbl.add_theme_font_size_override("font_size", 10)
    pos_lbl.add_theme_color_override("font_color", Color(0.62, 0.56, 0.46, 0.8))
    vb.add_child(pos_lbl)

    var name_lbl: = Label.new()
    name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name_lbl.add_theme_font_override("font", FONT_BOLD)
    name_lbl.add_theme_font_size_override("font_size", 13)
    vb.add_child(name_lbl)


    var stat_hbox: = HBoxContainer.new()
    stat_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
    stat_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    stat_hbox.add_theme_constant_override("separation", 2)
    vb.add_child(stat_hbox)

    var stat_atk_icon: = TextureRect.new()
    stat_atk_icon.texture = load("res://assets/ui/status_icons/攻击力.svg")
    stat_atk_icon.custom_minimum_size = Vector2(10, 10)
    stat_atk_icon.ignore_texture_size = true
    stat_atk_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    stat_atk_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    stat_atk_icon.modulate = Color.WHITE
    stat_hbox.add_child(stat_atk_icon)

    var stat_lbl: = Label.new()
    stat_lbl.add_theme_font_override("font", FONT_BODY)
    stat_lbl.add_theme_font_size_override("font_size", 11)
    stat_lbl.add_theme_color_override("font_color", INK)
    stat_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    stat_hbox.add_child(stat_lbl)

    var hp_center: = CenterContainer.new()
    hp_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var hp_bg: = _make_bar_bg(Vector2(88, 5), Color(0.06, 0.05, 0.035, 0.9))
    hp_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var hp_fill: = _make_bar_fill(hp_bg, Color(0.55, 0.72, 0.42, 0.95) if is_player else Color(0.72, 0.4, 0.32, 0.95))
    hp_center.add_child(hp_bg)
    vb.add_child(hp_center)

    if is_player:
        card.pressed.connect( func(): _on_player_slot_pressed(pos))
    else:
        card.pressed.connect( func(): _on_enemy_slot_pressed(pos))

    return {
        "root": card, "pos": pos, "enabled": enabled, "is_player": is_player, 
        "pos_lbl": pos_lbl, "name_lbl": name_lbl, "stat_lbl": stat_lbl, "stat_atk_icon": stat_atk_icon, "stat_hbox": stat_hbox, 
        "hp_bg": hp_bg, "hp_fill": hp_fill, 
    }

func _build_action_bar() -> Control:
    var hb: = HBoxContainer.new()
    hb.add_theme_constant_override("separation", 12)
    hb.alignment = BoxContainer.ALIGNMENT_CENTER

    for sid in model.skills:
        var skill_id: = str(sid)
        var name: String = T.SKILLS.get(skill_id, {}).get("name", skill_id)
        var b: = _action_button("将令·" + name, func(): _use_skill(skill_id))
        b.tooltip_text = str(T.SKILLS.get(skill_id, {}).get("desc", ""))
        _skill_btns[skill_id] = b
        hb.add_child(b)
    return hb

func _build_compact_controls() -> Control:
    var hb: = HBoxContainer.new()
    hb.add_theme_constant_override("separation", 8)
    hb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _pause_btn = _action_button("⏸ 暂停", func(): _toggle_pause())
    _pause_btn.custom_minimum_size = Vector2(104, 36)
    hb.add_child(_pause_btn)
    _speed_btn = _action_button("速度 ×1", func(): _toggle_speed())
    _speed_btn.custom_minimum_size = Vector2(104, 36)
    hb.add_child(_speed_btn)
    var auto_btn: = _action_button("自动结算", func(): _auto_resolve())
    auto_btn.custom_minimum_size = Vector2(112, 36)
    hb.add_child(auto_btn)
    return hb

func _action_button(txt: String, cb: Callable) -> Button:
    var b: = Button.new()
    b.text = txt
    b.focus_mode = Control.FOCUS_NONE
    b.custom_minimum_size = Vector2(136, 40)
    b.add_theme_font_override("font", FONT_BODY)
    b.add_theme_font_size_override("font_size", 14)
    var normal: = StyleBoxFlat.new()
    normal.bg_color = Color(0.12, 0.09, 0.05, 0.85)
    normal.border_color = GOLD
    normal.border_color.a = 0.5
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(6)
    normal.content_margin_left = 12;normal.content_margin_right = 12
    normal.content_margin_top = 6;normal.content_margin_bottom = 6
    var hover: = normal.duplicate() as StyleBoxFlat
    hover.bg_color = WARM_HOVER_BG
    hover.border_color = WARM_BORDER
    var pressed: = normal.duplicate() as StyleBoxFlat
    pressed.bg_color = Color(0.1, 0.07, 0.035, 0.76)
    pressed.border_color = WARM_BORDER
    var disabled: = normal.duplicate() as StyleBoxFlat
    disabled.bg_color = Color(0.08, 0.065, 0.045, 0.6)
    disabled.border_color.a = 0.18
    b.add_theme_stylebox_override("normal", normal)
    b.add_theme_stylebox_override("hover", hover)
    b.add_theme_stylebox_override("pressed", pressed)
    b.add_theme_stylebox_override("disabled", disabled)
    b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    b.add_theme_color_override("font_color", INK)
    b.add_theme_color_override("font_hover_color", Color(1.0, 0.94, 0.8, 1.0))
    b.add_theme_color_override("font_disabled_color", Color(0.55, 0.5, 0.42, 0.6))
    b.pressed.connect(cb)
    return b

func _card_style(is_player: bool, hot: bool, elite: bool = false, ally: bool = false) -> StyleBoxFlat:
    var s: = StyleBoxFlat.new()
    s.bg_color = Color(0.075, 0.1, 0.065, 0.88) if ally else (Color(0.1, 0.08, 0.05, 0.88) if is_player else Color(0.11, 0.065, 0.05, 0.88))
    if hot:
        s.bg_color = WARM_HOVER_BG if is_player else s.bg_color.lightened(0.08)
    s.border_color = ALLY_BORDER if ally else (GOLD if is_player else RED)
    s.border_color.a = 0.85 if hot else (0.62 if elite else 0.38)
    s.set_border_width_all(2 if (hot or elite) else 1)
    s.set_corner_radius_all(6)
    s.shadow_color = Color(0, 0, 0, 0.26)
    s.shadow_size = 4
    return s




func _refresh_all() -> void :
    if model == null:
        return
    if str(model.objective.get("type", "annihilate")) == "hold":
        _turn_lbl.text = "守住 %d / %d 轮" % [maxi(1, model.turn), model.max_turns]
    elif model.unlimited_turns:
        _turn_lbl.text = "第 %d 轮" % maxi(1, model.turn)
    else:
        _turn_lbl.text = "第 %d 轮 / %d" % [maxi(1, model.turn), model.max_turns]
    _enemy_section_lbl.text = "敌阵"
    var ter_name: = str(T.TERRAIN.get(model.terrain, {}).get("name", "平原"))
    var ammo_txt: = ("弹药尽·火器哑火" if model.ammo <= 0 else "弹药 %d" % model.ammo)
    var horse_txt: = ("马力尽·不可冲锋" if model.horse <= 0 else "马力 %d" % model.horse)
    _res_lbl.text = "地形：%s　%s　%s　情报 %d 级%s" % [ter_name, ammo_txt, horse_txt, model.intel, _active_effects_text()]
    _update_morale_bar()
    for refs in _enemy_cards:
        _update_card(refs, model.enemy_front[int(refs["pos"])])
    for refs in _player_cards:
        _update_card(refs, model.player_front[int(refs["pos"])])
    _update_skill_buttons()
    _rebuild_battle_log()
    _player_section_lbl.text = "我阵"
    _summary_lbl.text = _engage_summary()
    _update_hint()

func _update_card(refs: Dictionary, unit) -> void :
    var card: Button = refs["root"]
    var is_player: bool = refs["is_player"]
    var pos: int = refs["pos"]
    var enabled: bool = refs["enabled"]
    var focused: = ( not is_player) and _focus_pos == pos

    refs["pos_lbl"].text = ("集火 ▾" if focused else str(T.POS_NAMES.get(pos, "")))
    refs["pos_lbl"].add_theme_color_override("font_color", RED if focused else Color(0.62, 0.56, 0.46, 0.8))


    if not enabled and (unit == null or int(unit.get("hp", 0)) <= 0):
        refs["name_lbl"].text = "· 未启用 ·"
        refs["name_lbl"].add_theme_color_override("font_color", Color(0.42, 0.38, 0.32, 0.5))
        refs["stat_lbl"].text = ""
        if refs.has("stat_atk_icon"):
            refs["stat_atk_icon"].visible = false
        refs["hp_bg"].visible = false
        card.disabled = true
        card.add_theme_stylebox_override("normal", _dim_style())
        card.add_theme_stylebox_override("hover", _dim_style())
        card.add_theme_stylebox_override("pressed", _dim_style())
        card.add_theme_stylebox_override("disabled", _dim_style())
        return

    if unit == null or int(unit.get("hp", 0)) <= 0:
        refs["name_lbl"].text = "—"
        refs["name_lbl"].add_theme_color_override("font_color", MUTED)
        refs["stat_lbl"].text = "空 位"
        if refs.has("stat_atk_icon"):
            refs["stat_atk_icon"].visible = false
        refs["stat_lbl"].add_theme_color_override("font_color", Color(0.5, 0.46, 0.4, 0.6))
        refs["hp_bg"].visible = false
        card.disabled = is_player
        var st: = _card_style(is_player, false)
        card.add_theme_stylebox_override("normal", st)
        card.add_theme_stylebox_override("hover", st)
        card.add_theme_stylebox_override("pressed", st)
        card.add_theme_stylebox_override("disabled", _dim_style())
        return

    var elite: = bool(unit.get("elite", false))
    var ally: = is_player and bool(unit.get("ally", false))
    refs["name_lbl"].text = str(unit.get("name", ""))
    var name_col: = RED
    if is_player:
        name_col = ALLY_NAME if ally else (Color(0.95, 0.8, 0.5, 1.0) if elite else GOLD)
    refs["name_lbl"].add_theme_color_override("font_color", name_col)

    if ally and not focused:
        refs["pos_lbl"].text = str(T.POS_NAMES.get(pos, "")) + "·援"
        refs["pos_lbl"].add_theme_color_override("font_color", ALLY_BORDER)
    _set_hp_fill_color(refs["hp_fill"], ALLY_HP if ally else (PLAYER_HP if is_player else ENEMY_HP))
    var reload_txt: = ""
    if int(unit.get("reload_left", 0)) > 0:
        reload_txt = " 装填%d" % int(unit.get("reload_left"))
    if refs.has("stat_atk_icon"):
        refs["stat_atk_icon"].visible = true
    refs["stat_lbl"].text = "%d　♥%d/%d%s" % [int(unit.get("atk", 0)) + int(unit.get("ramp", 0)), maxi(0, int(unit.get("hp", 0))), int(unit.get("hp_max", 1)), reload_txt]
    refs["stat_lbl"].add_theme_color_override("font_color", Color(0.72, 0.64, 0.52, 0.9) if int(unit.get("reload_left", 0)) > 0 else INK)
    refs["hp_bg"].visible = true
    var ratio: = clampf(float(unit.get("hp", 0)) / maxf(1.0, float(unit.get("hp_max", 1))), 0.0, 1.0)
    var full_w: float = refs["hp_bg"].custom_minimum_size.x - 2.0
    var tw: = create_tween()
    tw.tween_property(refs["hp_fill"], "size:x", full_w * ratio, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

    var hot: = focused
    card.disabled = false
    card.add_theme_stylebox_override("normal", _card_style(is_player, hot, elite, ally))
    card.add_theme_stylebox_override("hover", _card_style(is_player, true, elite, ally))
    card.add_theme_stylebox_override("pressed", _card_style(is_player, true, elite, ally))
    card.add_theme_stylebox_override("disabled", _dim_style())

func _dim_style() -> StyleBoxFlat:
    var s: = StyleBoxFlat.new()
    s.bg_color = Color(0.07, 0.06, 0.045, 0.5)
    s.border_color = Color(0.4, 0.36, 0.3, 0.2)
    s.set_border_width_all(1)
    s.set_corner_radius_all(6)
    return s

func _rebuild_battle_log() -> void :
    if _battle_log_box == null:
        return
    for c in _battle_log_box.get_children():
        c.queue_free()
    if _battle_log_entries.is_empty():
        _battle_log_entries.append({"text": "两军列阵。战中可择机变阵。", "type": "system"})
    var start_idx: = maxi(0, _battle_log_entries.size() - 12)
    for i in range(start_idx, _battle_log_entries.size()):
        var entry: Dictionary = _battle_log_entries[i]
        var l: = Label.new()
        l.text = str(entry.get("text", ""))
        l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        l.add_theme_font_override("font", FONT_BODY)
        l.add_theme_font_size_override("font_size", 12)

        var type: String = entry.get("type", "system")
        var col: = INK
        if type == "player":
            col = Color(0.55, 0.72, 0.45, 0.9)
        elif type == "enemy":
            col = Color(0.78, 0.45, 0.42, 0.9)
        else:
            col = INK if i == _battle_log_entries.size() - 1 else Color(0.72, 0.66, 0.54, 0.84)

        if i != _battle_log_entries.size() - 1:
            col.a *= 0.8

        l.add_theme_color_override("font_color", col)
        _battle_log_box.add_child(l)

func _update_skill_buttons() -> void :
    for sid in _skill_btns.keys():
        var b: Button = _skill_btns[sid]
        var name: String = T.SKILLS.get(sid, {}).get("name", sid)
        var cd: = int(model.skill_cooldowns.get(sid, 0))
        if cd > 0:
            b.text = "将令·%s（冷却 %d 轮）" % [name, cd]
            b.disabled = true
        elif model.morale < T.MORALE_FULL:
            b.text = "将令·%s（蓄士气）" % name
            b.disabled = true
        else:
            b.text = "将令·" + name
            b.disabled = false

func _update_morale_bar() -> void :
    var ratio: = clampf(float(model.morale) / float(T.MORALE_FULL), 0.0, 1.0)
    var full_w: float = MORALE_BAR_SIZE.x - 2.0
    var tw: = create_tween()
    tw.tween_property(_morale_fill, "size:x", full_w * ratio, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    if model.morale >= T.MORALE_FULL:
        _morale_lbl.text = "士气已满，可下将令"
        _morale_lbl.add_theme_color_override("font_color", GOLD)
    else:
        _morale_lbl.text = "%d/100" % model.morale
        _morale_lbl.add_theme_color_override("font_color", MUTED)

func _update_tick_bar() -> void :
    if _tick_fill == null:
        return
    var ratio: = clampf(_tick_accum / TICK_BASE, 0.0, 1.0)
    _tick_fill.size.x = (_tick_fill.get_parent().custom_minimum_size.x - 2.0) * ratio

func _update_hint() -> void :
    return

func _active_effects_text() -> String:
    const EFFECT_NAMES: = {
        "yuanyang": "鸳鸯阵", "artillery_x2": "凭坚城用大炮", "volley_all": "火车营齐射", 
        "tianxiong": "天雄死战", "retreat": "以走制敌", 
    }
    var names: Array = []
    for key in model.active_effects.keys():
        names.append(str(EFFECT_NAMES.get(key, key)))
    return "" if names.is_empty() else "　将令在场：" + "、".join(names)

func _engage_summary() -> String:
    return "—— 列阵相向 ——"

func _append_battle_log_lines(events: Array, enemy_move: Dictionary = {}) -> void :
    if events.is_empty():
        _battle_log_entries.append({
            "text": "第 %d 轮：两军按阵相持，未成杀伤。" % maxi(1, model.turn), 
            "type": "system"
        })
    for e in events:
        var side: = "我军" if bool(e.get("player", false)) else "敌军"
        var act: = "击敌" if bool(e.get("player", false)) else "击我"
        var pos_name: = str(T.POS_NAMES.get(int(e.get("to_pos", -1)), ""))
        var suffix: = "，击溃。" if bool(e.get("kill", false)) else "。"
        var extra: = "（溅射）" if bool(e.get("splash", false)) else ""
        _battle_log_entries.append({
            "text": "第 %d 轮：%s%s%s%s%s，伤 %d%s" % [
                maxi(1, model.turn), 
                side, 
                str(e.get("by", "")), 
                act, 
                pos_name, 
                str(e.get("to", "")), 
                int(e.get("dmg", 0)), 
                extra + suffix, 
            ], 
            "type": "player" if bool(e.get("player", false)) else "enemy"
        })
    _rebuild_battle_log()





func _on_player_slot_pressed(pos: int) -> void :
    return


func _make_rotate_button(clockwise: bool) -> Button:
    var b: = Button.new()
    b.text = "变阵 ▶" if clockwise else "◀ 变阵"
    b.tooltip_text = "向右变阵：阵列顺时针转一位" if clockwise else "向左变阵：阵列逆时针转一位"
    b.focus_mode = Control.FOCUS_NONE
    b.custom_minimum_size = Vector2(96, 46)
    b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    b.add_theme_font_override("font", FONT_BODY)
    b.add_theme_font_size_override("font_size", 13)

    var normal: = StyleBoxFlat.new()
    normal.bg_color = Color(0, 0, 0, 0.0)
    normal.border_color = Color(0.86, 0.78, 0.62, 0.55)
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(23)
    normal.content_margin_left = 12
    normal.content_margin_right = 12
    var hover: = normal.duplicate() as StyleBoxFlat
    hover.bg_color = WARM_HOVER_BG
    hover.border_color = Color(0.86, 0.78, 0.62, 0.8)
    var pressed: = normal.duplicate() as StyleBoxFlat
    pressed.bg_color = Color(0.1, 0.07, 0.035, 0.76)
    pressed.border_color = WARM_BORDER
    var disabled: = normal.duplicate() as StyleBoxFlat
    disabled.border_color = Color(0.6, 0.55, 0.46, 0.22)
    b.add_theme_stylebox_override("normal", normal)
    b.add_theme_stylebox_override("hover", hover)
    b.add_theme_stylebox_override("pressed", pressed)
    b.add_theme_stylebox_override("disabled", disabled)
    b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    b.add_theme_color_override("font_color", Color(0.88, 0.82, 0.68, 0.9))
    b.add_theme_color_override("font_hover_color", Color(1.0, 0.94, 0.8, 1.0))
    b.add_theme_color_override("font_disabled_color", Color(0.55, 0.5, 0.42, 0.55))
    b.pressed.connect( func(): _on_rotate_pressed(clockwise))
    return b

func _on_rotate_pressed(clockwise: bool) -> void :
    if model == null or model.finished or _showing_result or _result_pending:
        return
    if _rotate_cd > 0.0:
        return
    var moves: Array = model.rotate_formation(true, clockwise)
    if moves.is_empty():
        return
    _rotate_cd = ROTATE_CD
    _battle_log_entries.append({
        "text": "第 %d 轮：我军变阵，阵列%s时针转一位。" % [maxi(1, model.turn), "顺" if clockwise else "逆"], 
        "type": "player", 
    })
    _refresh_all()
    _animate_rotation(_player_cards, moves)
    _update_rotate_buttons()

func _enemy_rotate() -> void :
    if model == null or model.finished or _showing_result or _result_pending:
        return
    var clockwise: = randf() < 0.5
    var moves: Array = model.rotate_formation(false, clockwise)
    if moves.is_empty():
        return
    _battle_log_entries.append({
        "text": "第 %d 轮：敌军变阵，阵列易位。" % maxi(1, model.turn), 
        "type": "enemy", 
    })
    _refresh_all()
    _animate_rotation(_enemy_cards, moves)

func _update_rotate_buttons() -> void :
    if _rotate_left_btn == null or _rotate_right_btn == null:
        return
    var cooling: = _rotate_cd > 0.0
    _rotate_left_btn.disabled = cooling
    _rotate_right_btn.disabled = cooling
    _rotate_left_btn.text = ("◀ 变阵·%d" % ceili(_rotate_cd)) if cooling else "◀ 变阵"
    _rotate_right_btn.text = ("变阵·%d ▶" % ceili(_rotate_cd)) if cooling else "变阵 ▶"


func _animate_rotation(cards: Array, moves: Array) -> void :
    var home: = {}
    var gpos: = {}
    for refs in cards:
        var c: Control = refs["root"]
        home[int(refs["pos"])] = c.position
        gpos[int(refs["pos"])] = c.global_position
    for m in moves:
        var from: int = int(m["from"])
        var to: int = int(m["to"])
        if not home.has(to) or not gpos.has(from):
            continue
        for refs in _card_refs(cards, to):
            var c: Control = refs["root"]
            var dest: Vector2 = home[to]
            c.position = dest + (Vector2(gpos[from]) - Vector2(gpos[to]))
            c.pivot_offset = c.size / 2.0
            c.scale = Vector2(0.94, 0.94)
            var tw: = create_tween()
            tw.set_parallel(true)
            tw.tween_property(c, "position", dest, 0.34).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
            tw.tween_property(c, "scale", Vector2.ONE, 0.34).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_enemy_slot_pressed(pos: int) -> void :
    if model == null or model.finished or _showing_result:
        return
    if _focus_pos == pos:

        _focus_pos = -1
        _focus_ticks_left = 0
        _refresh_all()
        return
    if _focus_cd > 0.0 or not _focus_alive(pos):
        return
    _focus_pos = pos
    _focus_ticks_left = FOCUS_TICKS
    _focus_cd = FOCUS_CD
    _refresh_all()
    _pulse_card(_card_refs(_enemy_cards, pos))

func _use_skill(sid: String) -> void :
    if model == null or model.finished or _showing_result:
        return
    if model.use_skill(sid):
        _flash_skill_banner(str(T.SKILLS.get(sid, {}).get("name", sid)))
        _refresh_all()

func _toggle_pause() -> void :
    _paused = not _paused
    _pause_btn.text = "▶ 继续" if _paused else "⏸ 暂停"

func _toggle_speed() -> void :
    _speed = 2.0 if _speed < 2.0 else 1.0
    _speed_btn.text = "速度 ×%d" % int(_speed)

func _auto_resolve() -> void :
    if model == null:
        return
    _used_auto = true
    model.auto_resolve(1.0)
    _show_result()




func _card_refs(cards: Array, pos: int) -> Array:
    var list: = []
    for refs in cards:
        if int(refs["pos"]) == pos:
            list.append(refs)
    return list

func _pulse_card(refs_list: Array) -> void :
    for refs in refs_list:
        if refs.is_empty():
            continue
        var card: Control = refs["root"]
        card.pivot_offset = card.size / 2.0
        var tw: = create_tween()
        tw.tween_property(card, "scale", Vector2(1.08, 1.08), 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
        tw.tween_property(card, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

func _animate_engage(events: Array) -> void :
    var i: = 0
    for e in events:
        var delay: = i * 0.12
        i += 1
        var is_player_attacker: = bool(e.get("player", false))
        var atk_list: = []
        if e.has("by_pos"):
            atk_list = _card_refs(_player_cards if is_player_attacker else _enemy_cards, int(e["by_pos"]))
        var tgt_list: = []
        if e.has("to_pos"):
            tgt_list = _card_refs(_enemy_cards if is_player_attacker else _player_cards, int(e["to_pos"]))
        _schedule_hit(delay, atk_list, tgt_list, int(e.get("dmg", 0)), is_player_attacker, bool(e.get("splash", false)), bool(e.get("kill", false)))
        if bool(e.get("charge", false)) and not atk_list.is_empty():
            for r in atk_list:
                _spawn_tag_popup(r["root"], "冲锋", Color(0.95, 0.78, 0.42, 1.0), delay)

func _schedule_hit(delay: float, atk_list: Array, tgt_list: Array, dmg: int, by_player: bool, splash: bool, kill: bool) -> void :
    var timer: = get_tree().create_timer(maxf(0.01, delay / _speed))
    timer.timeout.connect( func():
        if model == null or not visible or _showing_result:
            return

        if not atk_list.is_empty() and not splash:
            for r in atk_list:
                var atk: Control = r["root"]
                atk.pivot_offset = atk.size / 2.0
                var dir: = -1.0 if by_player else 1.0
                var tw: = create_tween()
                tw.tween_property(atk, "position:y", atk.position.y + dir * 10.0, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
                tw.tween_property(atk, "position:y", atk.position.y, 0.14).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

        if not tgt_list.is_empty():
            for r in tgt_list:
                var tgt: Control = r["root"]
                var tw2: = create_tween()
                tw2.tween_property(tgt, "modulate", Color(1.35, 0.72, 0.62, 1.0), 0.08)
                tw2.tween_property(tgt, "modulate", Color.WHITE, 0.22)
                var base_x: = tgt.position.x
                var tw3: = create_tween()
                tw3.tween_property(tgt, "position:x", base_x + 4.0, 0.045)
                tw3.tween_property(tgt, "position:x", base_x - 4.0, 0.045)
                tw3.tween_property(tgt, "position:x", base_x, 0.045)
                _spawn_damage_popup(tgt, dmg, by_player, splash, kill)
    )

func _spawn_damage_popup(target: Control, dmg: int, by_player: bool, splash: bool, kill: bool) -> void :
    var lbl: = Label.new()
    lbl.text = ("溃" if kill else "−%d" % dmg)
    lbl.add_theme_font_override("font", FONT_BOLD)
    lbl.add_theme_font_size_override("font_size", (26 if kill else (16 if splash else 21)))
    var col: = Color(0.98, 0.86, 0.58, 1.0) if by_player else Color(0.94, 0.52, 0.42, 1.0)
    if kill:
        col = Color(0.95, 0.35, 0.28, 1.0)
    lbl.add_theme_color_override("font_color", col)
    lbl.z_index = 60
    add_child(lbl)
    var rect: = target.get_global_rect()
    lbl.global_position = Vector2(rect.get_center().x - 14 + randf_range(-14.0, 14.0), rect.position.y + 6)
    var tw: = create_tween()
    tw.set_parallel(true)
    tw.tween_property(lbl, "position:y", lbl.position.y - 34.0, 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    tw.tween_property(lbl, "modulate:a", 0.0, 0.75).set_delay(0.25)
    tw.chain().tween_callback(lbl.queue_free)


func _spawn_tag_popup(target: Control, txt: String, col: Color, delay: float = 0.0) -> void :
    var timer: = get_tree().create_timer(maxf(0.01, delay / _speed))
    timer.timeout.connect( func():
        if model == null or not visible or _showing_result:
            return
        var lbl: = Label.new()
        lbl.text = txt
        lbl.add_theme_font_override("font", FONT_BOLD)
        lbl.add_theme_font_size_override("font_size", 14)
        lbl.add_theme_color_override("font_color", col)
        lbl.z_index = 60
        add_child(lbl)
        var rect: = target.get_global_rect()
        lbl.global_position = Vector2(rect.position.x + 6, rect.position.y - 4)
        var tw: = create_tween()
        tw.set_parallel(true)
        tw.tween_property(lbl, "position:y", lbl.position.y - 22.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
        tw.tween_property(lbl, "modulate:a", 0.0, 0.7).set_delay(0.2)
        tw.chain().tween_callback(lbl.queue_free)
    )

func _flash_skill_banner(skill_name: String) -> void :
    var lbl: = Label.new()
    lbl.text = "将令 · " + skill_name
    lbl.add_theme_font_override("font", FONT_TITLE)
    lbl.add_theme_font_size_override("font_size", 42)
    lbl.add_theme_color_override("font_color", GOLD)
    lbl.z_index = 70
    lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lbl.set_anchors_preset(Control.PRESET_CENTER_TOP)
    add_child(lbl)
    var vp: = size
    lbl.position = Vector2(vp.x / 2.0 - 200.0, vp.y * 0.3)
    lbl.custom_minimum_size = Vector2(400, 0)
    lbl.modulate.a = 0.0
    lbl.scale = Vector2(0.9, 0.9)
    lbl.pivot_offset = Vector2(200, 30)
    var tw: = create_tween()
    tw.set_parallel(true)
    tw.tween_property(lbl, "modulate:a", 1.0, 0.18)
    tw.tween_property(lbl, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tw.chain().tween_interval(0.8)
    tw.chain().tween_property(lbl, "modulate:a", 0.0, 0.35)
    tw.chain().tween_callback(lbl.queue_free)

func _play_start_banner() -> void :

    var toast: = Control.new()
    toast.custom_minimum_size = Vector2(480, 80)
    toast.z_index = 70
    add_child(toast)


    var bg: = Control.new()
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    bg.draw.connect(_draw_start_banner_bg.bind(bg))
    toast.add_child(bg)


    var center: = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    center.mouse_filter = Control.MOUSE_FILTER_IGNORE
    toast.add_child(center)

    var lbl: = Label.new()
    lbl.text = "两 军 列 阵"
    lbl.add_theme_font_override("font", FONT_TITLE)
    lbl.add_theme_font_size_override("font_size", 38)
    lbl.add_theme_color_override("font_color", Color(0.92, 0.91, 0.86, 1.0))
    lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    center.add_child(lbl)


    var vp: = size
    toast.position = Vector2(vp.x / 2.0 - toast.custom_minimum_size.x / 2.0, vp.y * 0.42)
    toast.modulate.a = 0.0


    var tw: = create_tween()
    tw.tween_property(toast, "modulate:a", 1.0, 0.3)
    tw.tween_interval(0.7)
    tw.tween_property(toast, "modulate:a", 0.0, 0.4)
    tw.tween_callback(toast.queue_free)

func _draw_start_banner_bg(bg: Control) -> void :
    var w: = bg.size.x
    var h: = bg.size.y

    var body_col: = Color(0.09, 0.095, 0.11, 0.96)
    var edge_col: = Color(0.22, 0.23, 0.25, 0.38)
    var slant: = minf(52.0, w * 0.08)
    var body_poly: = PackedVector2Array([
        Vector2(slant, 0.0), 
        Vector2(w, 0.0), 
        Vector2(w - slant, h), 
        Vector2(0.0, h)
    ])

    bg.draw_polygon(body_poly, PackedColorArray([body_col, body_col, body_col, body_col]))
    bg.draw_line(Vector2(slant, 0.0), Vector2(0.0, h), edge_col, 2.0, true)
    bg.draw_line(Vector2(w, 0.0), Vector2(w - slant, h), edge_col, 2.0, true)




func _show_result() -> void :
    _showing_result = true
    set_process(false)
    _clear()
    var grade: = str(model.result_grade)
    var kills: int = model.enemy_total_units - model.enemy_alive_count()
    var losses: int = model.player_total_units - model.player_alive_count()
    var data: Dictionary = {
        "great": {"t": "大 胜", "c": GOLD, "d": "你把这支兵带赢了。可哪怕是大胜，校场上也少了几张面孔——断后的、没退回来的。"}, 
        "pyrrhic": {"t": "惨 胜", "c": Color(0.82, 0.74, 0.5, 1.0), "d": "赢是赢了，赢得很难看。伤亡的名册比战报还长。"}, 
        "fail": {"t": "失 利", "c": RED, "d": "退下来了。活着的人比死了的人更沉默。父亲那句『好好活下去』，今天又懂深了一层。"}, 
    }.get(grade, {"t": "战 毕", "c": INK, "d": ""})

    var center: = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(center)
    var vb: = VBoxContainer.new()
    vb.add_theme_constant_override("separation", 22)
    vb.alignment = BoxContainer.ALIGNMENT_CENTER
    center.add_child(vb)

    var t: = Label.new()
    t.text = str(data["t"])
    t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    t.add_theme_font_override("font", FONT_TITLE)
    t.add_theme_font_size_override("font_size", 56)
    t.add_theme_color_override("font_color", data["c"])
    vb.add_child(t)

    var d: = Label.new()
    d.text = str(data["d"])
    d.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    d.custom_minimum_size = Vector2(560, 0)
    d.add_theme_font_override("font", FONT_BODY)
    d.add_theme_font_size_override("font_size", 18)
    d.add_theme_color_override("font_color", INK)
    vb.add_child(d)


    if not _used_auto:
        var report: = Label.new()
        report.text = "历时 %d 轮　·　击溃敌军 %d/%d 支　·　折损 %d/%d 支" % [maxi(1, model.turn), kills, model.enemy_total_units, losses, model.player_total_units]
        report.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        report.add_theme_font_override("font", FONT_BODY)
        report.add_theme_font_size_override("font_size", 15)
        report.add_theme_color_override("font_color", MUTED)
        vb.add_child(report)

    var cont: = _action_button("收 兵", func(): _finish_and_emit(grade))
    cont.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    vb.add_child(cont)


    center.modulate.a = 0.0
    var tw: = create_tween()
    tw.tween_property(center, "modulate:a", 1.0, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    t.scale = Vector2(1.25, 1.25)
    t.pivot_offset = Vector2(80, 40)
    var tw2: = create_tween()
    tw2.tween_property(t, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _finish_and_emit(grade: String) -> void :
    visible = false
    set_process(false)
    battle_finished.emit(grade)
