extends RefCounted
class_name GameScreenPresenter

const FontLoader = preload("res://scripts/ui/font_loader.gd")
const EffectsServiceRef = preload("res://scripts/services/effects_service.gd")
const STATUS_ICON_PATHS: = {
    "wentao": "res://assets/ui/status_icons/wentao.webp", 
    "wulue": "res://assets/ui/status_icons/wulue.webp", 
    "lizheng": "res://assets/ui/status_icons/lizheng.webp", 
    "tizhi": "res://assets/ui/status_icons/tizhi.webp", 
    "chengfang": "res://assets/ui/status_icons/chengfang.webp", 
    "nongsang": "res://assets/ui/status_icons/nongsang.webp", 
    "bingyong": "res://assets/ui/status_icons/bingyong.webp", 
    "shangmao": "res://assets/ui/status_icons/shangmao.webp", 
    "baigong": "res://assets/ui/status_icons/baigong.webp", 
    "wenjiao": "res://assets/ui/status_icons/wenjiao.webp", 
    "liangshi": "res://assets/ui/status_icons/guanliang.webp", 
    "yinliang": "res://assets/ui/status_icons/kuyin.webp", 
    "renkou_val": "res://assets/ui/status_icons/renkou.webp", 
    "liumin": "res://assets/ui/status_icons/liuming.webp", 
    "shengjuan": "res://assets/ui/status_icons/shengjuan.webp", 
    "zhongguan": "res://assets/ui/status_icons/zhongguan.webp", 
    "qingyi": "res://assets/ui/status_icons/qingyi.webp", 
    "chaotang": "res://assets/ui/status_icons/qingyi.webp", 
    "shishen": "res://assets/ui/status_icons/shishen.webp", 
    "minwang": "res://assets/ui/status_icons/minwang.webp", 
    "shimin": "res://assets/ui/status_icons/minwang.webp", 


    "jianjun": "res://assets/ui/status_icons/zhongguan.webp", 
    "junxin": "res://assets/ui/status_icons/bingyong.webp"
}
const GUOZUO_LABELS: = {
    "yuan_shadow": "袁案旧影", 
    "tianxiong_remnant": "天雄余脉", 
    "qin_army_remnant": "秦军旧部", 
    "firearm_artisans": "火器匠户", 
    "refugee_tuntian": "流民屯田"
}
const COMPACT_STATUS_TILE_HEIGHT: = 212.0
const COMPACT_ATTITUDE_WARN_THRESHOLD: = 30
const MOBILE_HAIRLINE_WIDTH: = 2.0
const MOBILE_ARCHIVE_CARD_SIDE_PADDING: = 30
const MOBILE_ARCHIVE_CARD_VERTICAL_PADDING: = 24

static func _is_primary_press_event(event: InputEvent) -> bool:
    if event is InputEventScreenTouch:
        return not event.pressed
    if event is InputEventMouseButton:
        return event.button_index == MOUSE_BUTTON_LEFT and not event.pressed
    return false

static func populate_stats(container: Control, stats: Dictionary) -> void :
    var existing_radar = null
    for child in container.get_children():
        if child is RadarChart:
            existing_radar = child
            break

    if existing_radar:

        existing_radar.force_dark_palette = (GameState.theme == "light")
        existing_radar.update_stats(stats)
    else:
        _clear_children(container)
        var radar = preload("res://scripts/ui/radar_chart.gd").new()
        radar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        radar.size_flags_vertical = Control.SIZE_EXPAND_FILL
        radar.force_dark_palette = (GameState.theme == "light")
        container.add_child(radar)
        radar.update_stats(stats)

static func populate_stats_compact(container: Control, stats: Dictionary) -> void :
    _clear_children(container)
    var grid = GridContainer.new()
    grid.columns = 4
    grid.add_theme_constant_override("h_separation", 10)
    grid.add_theme_constant_override("v_separation", 10)
    grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    grid.size_flags_vertical = Control.SIZE_FILL
    container.add_child(grid)

    var stat_keys = ["wentao", "wulue", "lizheng", "tizhi"]
    var stat_labels_map = {"wentao": "文韬", "wulue": "武略", "lizheng": "理政", "tizhi": "体质"}
    var warn_threshold: = 20
    var normal_accent: = Color(0.82, 0.68, 0.38, 1.0)
    var warn_accent: = Color(0.72, 0.28, 0.14, 1.0)

    for key in stat_keys:
        if not stats.has(key):
            continue
        var val: = int(stats[key])
        var is_low: bool = key == "tizhi" and val <= warn_threshold
        var accent: Color = warn_accent if is_low else normal_accent

        var panel = PanelContainer.new()
        panel.name = "StatPanel_" + key
        panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        panel.size_flags_vertical = Control.SIZE_FILL
        panel.custom_minimum_size.y = COMPACT_STATUS_TILE_HEIGHT
        panel.add_theme_stylebox_override("panel", _make_compact_tile_style(accent, is_low, false, 14))

        var chip = VBoxContainer.new()
        chip.alignment = BoxContainer.ALIGNMENT_CENTER
        chip.add_theme_constant_override("separation", 5)
        chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        chip.size_flags_vertical = Control.SIZE_EXPAND_FILL
        panel.add_child(chip)

        var icon = _make_compact_icon_badge(key, accent, 54.0, 46.0)
        if icon:
            chip.add_child(icon)

        var name_label = Label.new()
        name_label.text = stat_labels_map.get(key, key)
        name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        name_label.add_theme_font_size_override("font_size", 20)
        name_label.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        chip.add_child(name_label)

        var val_label = Label.new()
        val_label.text = str(val)
        val_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        val_label.add_theme_font_size_override("font_size", 32)
        val_label.add_theme_color_override("font_color", warn_accent if is_low else GameState.get_theme_color("text_desc"))
        chip.add_child(val_label)

        grid.add_child(panel)

static func populate_attitudes_compact(container: Control, attitudes: Dictionary, get_tier_text: Callable, get_tier_color: Callable) -> void :
    _clear_children(container)
    var normal_accent: = Color(0.82, 0.68, 0.38, 1.0)
    var warn_accent: = Color(0.46, 0.18, 0.12, 1.0)
    var visible_keys: = []

    for key in GameData.ATT_KEYS:
        if not attitudes.has(key):
            continue
        if game_state_attitude_hidden(key):
            continue
        visible_keys.append(key)

    var visible_count: = visible_keys.size()
    if visible_count == 0:
        return

    var unified_card = PanelContainer.new()
    unified_card.name = "CompactAttitudesUnifiedCard"
    unified_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    unified_card.size_flags_vertical = Control.SIZE_FILL
    unified_card.custom_minimum_size.y = 104
    unified_card.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    container.add_child(unified_card)

    var background: = _make_compact_attitudes_notched_background(visible_count)
    unified_card.add_child(background)

    var content_margin = MarginContainer.new()
    content_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
    content_margin.add_theme_constant_override("margin_left", 10)
    content_margin.add_theme_constant_override("margin_right", 10)
    content_margin.add_theme_constant_override("margin_top", 8)
    content_margin.add_theme_constant_override("margin_bottom", 8)
    unified_card.add_child(content_margin)

    var row = HBoxContainer.new()
    row.alignment = BoxContainer.ALIGNMENT_CENTER
    row.add_theme_constant_override("separation", 0)
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content_margin.add_child(row)

    var visible_items: = 0
    for key in visible_keys:
        var att_value: = int(attitudes.get(key, 0))
        var is_locked: = game_state_attitude_locked(key)
        var is_emperor_dead_lock: bool = is_locked and GameState.emperor_dead and (key == "shengjuan" or key == "zhongguan")
        var is_warn: bool = att_value < COMPACT_ATTITUDE_WARN_THRESHOLD and not is_locked
        var accent: Color = warn_accent if is_warn else normal_accent
        if is_locked and not is_emperor_dead_lock:
            accent = GameState.get_theme_color("text_sub")

        var box = VBoxContainer.new()
        box.name = "AttitudeBox_" + key
        if is_emperor_dead_lock:
            box.modulate = Color(0.5, 0.5, 0.5, 0.6)
            box.mouse_filter = Control.MOUSE_FILTER_IGNORE

        box.alignment = BoxContainer.ALIGNMENT_CENTER
        box.add_theme_constant_override("separation", 2)
        box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        box.size_flags_vertical = Control.SIZE_EXPAND_FILL

        var title_row = HBoxContainer.new()
        title_row.alignment = BoxContainer.ALIGNMENT_CENTER
        title_row.add_theme_constant_override("separation", 4)
        title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        box.add_child(title_row)

        if STATUS_ICON_PATHS.has(key):
            var tex: = load(STATUS_ICON_PATHS[key]) as Texture2D
            if tex:
                var icon = TextureRect.new()
                icon.texture = tex
                icon.custom_minimum_size = Vector2(36.0, 36.0)
                icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
                icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                icon.modulate = Color(1.0, 0.92, 0.74, 0.94) if GameState.theme == "dark" else Color(0.56, 0.43, 0.24, 0.96)
                title_row.add_child(icon)

        var name_label = Label.new()
        name_label.text = GameData.ATT_LABELS.get(key, key)
        name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        name_label.add_theme_font_size_override("font_size", 20)
        name_label.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        title_row.add_child(name_label)

        var val_row = HBoxContainer.new()
        val_row.alignment = BoxContainer.ALIGNMENT_CENTER
        val_row.add_theme_constant_override("separation", 6)
        box.add_child(val_row)

        var val_label = Label.new()
        var show_as_dash = is_locked and not is_emperor_dead_lock
        val_label.text = "——" if show_as_dash else str(att_value)
        val_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        val_label.add_theme_font_size_override("font_size", 24)
        var text_color = accent if is_warn else (GameState.get_theme_color("text_desc") if not is_locked else GameState.get_theme_color("text_sub"))
        if is_emperor_dead_lock:
            text_color = warn_accent if att_value < COMPACT_ATTITUDE_WARN_THRESHOLD else normal_accent
        val_label.add_theme_color_override("font_color", text_color)
        val_row.add_child(val_label)

        var tier = Label.new()
        tier.text = "" if show_as_dash else get_tier_text.call(key)
        tier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        tier.add_theme_font_size_override("font_size", 16)
        var tier_color = accent
        if is_emperor_dead_lock:
            tier_color = warn_accent if att_value < COMPACT_ATTITUDE_WARN_THRESHOLD else normal_accent
        tier.add_theme_color_override("font_color", tier_color)
        if tier.text != "":
            val_row.add_child(tier)

        row.add_child(box)
        visible_items += 1

static func _make_compact_attitudes_notched_background(visible_count: int) -> Control:
    var bg = Control.new()
    bg.name = "CompactAttitudesNotchedBackground"
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    bg.draw.connect( func():
        var w: float = bg.size.x
        var h: float = bg.size.y
        if w <= 0.0 or h <= 0.0:
            return
        var notch: = 9.0
        var points: = PackedVector2Array()
        points.append(Vector2(0, 0))
        points.append(Vector2(notch, 0))
        points.append(Vector2(notch, notch))
        points.append(Vector2(0, notch))
        points.append(Vector2(0, h - notch))
        points.append(Vector2(notch, h - notch))
        points.append(Vector2(notch, h))
        points.append(Vector2(w - notch, h))
        points.append(Vector2(w - notch, h - notch))
        points.append(Vector2(w, h - notch))
        points.append(Vector2(w, notch))
        points.append(Vector2(w - notch, notch))
        points.append(Vector2(w - notch, 0))
        points.append(Vector2(w, 0))
        var fill_col: = Color(0.03, 0.029, 0.026, 0.64) if GameState.theme == "dark" else Color(0.96, 0.93, 0.86, 0.44)
        var border_col: = Color(0.78, 0.62, 0.35, 0.48) if GameState.theme == "dark" else Color(0.5, 0.38, 0.2, 0.36)
        bg.draw_colored_polygon(points, fill_col)
        var top_inset: = notch + 7.0
        bg.draw_line(Vector2(top_inset, 0), Vector2(w - top_inset, 0), border_col, MOBILE_HAIRLINE_WIDTH)
        bg.draw_line(Vector2(top_inset, h), Vector2(w - top_inset, h), border_col, MOBILE_HAIRLINE_WIDTH)
        bg.draw_line(Vector2(0, notch), Vector2(0, h - notch), border_col, MOBILE_HAIRLINE_WIDTH)
        bg.draw_line(Vector2(w, notch), Vector2(w, h - notch), border_col, MOBILE_HAIRLINE_WIDTH)
        bg.draw_line(Vector2(0, notch), Vector2(notch, notch), border_col, MOBILE_HAIRLINE_WIDTH)
        bg.draw_line(Vector2(notch, notch), Vector2(notch, 0), border_col, MOBILE_HAIRLINE_WIDTH)
        bg.draw_line(Vector2(notch, 0), Vector2(top_inset, 0), border_col, MOBILE_HAIRLINE_WIDTH)
        bg.draw_line(Vector2(w - top_inset, 0), Vector2(w - notch, 0), border_col, MOBILE_HAIRLINE_WIDTH)
        bg.draw_line(Vector2(w - notch, 0), Vector2(w - notch, notch), border_col, MOBILE_HAIRLINE_WIDTH)
        bg.draw_line(Vector2(w - notch, notch), Vector2(w, notch), border_col, MOBILE_HAIRLINE_WIDTH)
        bg.draw_line(Vector2(0, h - notch), Vector2(notch, h - notch), border_col, MOBILE_HAIRLINE_WIDTH)
        bg.draw_line(Vector2(notch, h - notch), Vector2(notch, h), border_col, MOBILE_HAIRLINE_WIDTH)
        bg.draw_line(Vector2(notch, h), Vector2(top_inset, h), border_col, MOBILE_HAIRLINE_WIDTH)
        bg.draw_line(Vector2(w - top_inset, h), Vector2(w - notch, h), border_col, MOBILE_HAIRLINE_WIDTH)
        bg.draw_line(Vector2(w - notch, h), Vector2(w - notch, h - notch), border_col, MOBILE_HAIRLINE_WIDTH)
        bg.draw_line(Vector2(w - notch, h - notch), Vector2(w, h - notch), border_col, MOBILE_HAIRLINE_WIDTH)
        if visible_count > 1:
            var separator_col: = Color(0.78, 0.62, 0.35, 0.42) if GameState.theme == "dark" else Color(0.48, 0.36, 0.18, 0.34)
            var content_left: = 10.0
            var content_right: = w - 10.0
            var separator_top: = h * 0.24
            var separator_bottom: = h * 0.76
            for i in range(1, visible_count):
                var x: = lerpf(content_left, content_right, float(i) / float(visible_count))
                bg.draw_line(Vector2(x, separator_top), Vector2(x, separator_bottom), separator_col, MOBILE_HAIRLINE_WIDTH, true)
    )
    return bg

static func _apply_style_border_width(style: StyleBoxFlat, width: int) -> void :
    style.border_width_left = width
    style.border_width_top = width
    style.border_width_right = width
    style.border_width_bottom = width

static func _make_compact_tile_style(accent: Color, urgent: bool = false, locked: bool = false, corner_radius: int = 6) -> StyleBoxFlat:
    var style = StyleBoxFlat.new()
    if GameState.theme == "light":
        style.bg_color = Color(0.96, 0.93, 0.86, 0.44)
    else:
        style.bg_color = Color(0.03, 0.029, 0.026, 0.64)
    _apply_style_border_width(style, int(MOBILE_HAIRLINE_WIDTH))
    style.border_color = Color(accent.r, accent.g, accent.b, 0.42 if not locked else 0.18)
    style.corner_radius_top_left = corner_radius
    style.corner_radius_top_right = corner_radius
    style.corner_radius_bottom_left = corner_radius
    style.corner_radius_bottom_right = corner_radius
    style.content_margin_left = 8
    style.content_margin_right = 8
    style.content_margin_top = 8
    style.content_margin_bottom = 8
    style.shadow_size = 8 if GameState.theme == "dark" and not locked else 0
    style.shadow_color = Color(accent.r, accent.g, accent.b, 0.18 if urgent else 0.1)
    return style

static func _make_compact_meter(value: int, accent: Color, locked: bool = false) -> Control:
    var meter = Control.new()
    meter.custom_minimum_size = Vector2(0, 6)
    meter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var clamped: = clampf(float(value) / 100.0, 0.0, 1.0)
    meter.draw.connect( func():
        var track_rect: = Rect2(Vector2(0, 2), Vector2(meter.size.x, 2))
        meter.draw_rect(track_rect, Color(0.7, 0.62, 0.46, 0.18), true)
        if locked:
            return
        var fill_rect: = Rect2(Vector2(0, 1), Vector2(meter.size.x * clamped, 4))
        meter.draw_rect(fill_rect, Color(accent.r, accent.g, accent.b, 0.82), true)
    )
    return meter

static func _compact_accent_color(_key: String) -> Color:

    return Color(0.82, 0.68, 0.38, 1.0)

static func _make_compact_icon_badge(key: String, accent: Color, badge_size: float, icon_size: float):
    if not STATUS_ICON_PATHS.has(key):
        return null
    var tex: = load(STATUS_ICON_PATHS[key]) as Texture2D
    if tex == null:
        return null
    var badge = Control.new()
    badge.custom_minimum_size = Vector2(badge_size, badge_size)
    badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    badge.draw.connect( func():
        var center: Vector2 = badge.size * 0.5
        var radius: float = minf(badge.size.x, badge.size.y) * 0.46
        badge.draw_circle(center, radius, Color(0.02, 0.018, 0.014, 0.46) if GameState.theme == "dark" else Color(0.94, 0.88, 0.74, 0.3))
        badge.draw_arc(center, radius - 1.0, 0.0, TAU, 72, Color(accent.r, accent.g, accent.b, 0.54), 1.2)
        badge.draw_arc(center, radius - 5.0, 0.0, TAU, 72, Color(accent.r, accent.g, accent.b, 0.2), 1.0)
    )
    var icon = TextureRect.new()
    icon.texture = tex
    icon.custom_minimum_size = Vector2(icon_size, icon_size)
    icon.set_anchors_preset(Control.PRESET_CENTER)
    icon.offset_left = - icon_size * 0.5
    icon.offset_top = - icon_size * 0.5
    icon.offset_right = icon_size * 0.5
    icon.offset_bottom = icon_size * 0.5
    icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    icon.modulate = Color(1.0, 0.92, 0.74, 0.94) if GameState.theme == "dark" else Color(0.56, 0.43, 0.24, 0.96)
    badge.add_child(icon)
    return badge

static func _side_color(key: String, force_dark: bool = false) -> Color:
    if force_dark or GameState.theme == "dark":
        return GameState.theme_colors["dark"].get(key, GameState.get_theme_color(key))
    return GameState.get_theme_color(key)

static func _side_is_dark(force_dark: bool = false) -> bool:
    return force_dark or GameState.theme == "dark"

static func _multi_archive_tag_text_color(force_dark: bool = false) -> Color:
    return Color(0.92, 0.76, 0.36, 1.0) if _side_is_dark(force_dark) else Color(0.64, 0.45, 0.12, 1.0)

static func _make_multi_archive_tag_style(force_dark: bool = false) -> StyleBoxFlat:
    var style: = _make_archive_tag_style(force_dark)
    style.border_color = Color(0.85, 0.7, 0.36, 0.88) if _side_is_dark(force_dark) else Color(0.72, 0.52, 0.18, 0.85)
    if force_dark and GameState.theme == "light":
        style.bg_color = Color(0, 0, 0, 0)
    elif _side_is_dark(force_dark):
        style.bg_color = Color(0.09, 0.068, 0.046, 0.88)
    else:
        style.bg_color = Color(0.98, 0.92, 0.8, 0.82)
    return style

static func populate_tags(container: Control, tags: Array[String], empty_text: String = "暂无标签", is_mobile: bool = false, force_dark: bool = false) -> void :
    _clear_children(container)
    if is_mobile:
        container.add_theme_constant_override("h_separation", 14)
        container.add_theme_constant_override("v_separation", 16)
    else:
        container.add_theme_constant_override("h_separation", 8)
        container.add_theme_constant_override("v_separation", 6)

    var visible_tags: = _filter_display_tags(tags)
    if visible_tags.is_empty():
        var empty_label = Label.new()
        empty_label.name = "EmptyTagsLabel"
        empty_label.text = empty_text
        empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        empty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        empty_label.add_theme_font_size_override("font_size", 34 if is_mobile else 12)
        var empty_color: = _side_color("text_sub", force_dark)
        empty_label.add_theme_color_override("font_color", Color(empty_color.r, empty_color.g, empty_color.b, 0.3 if is_mobile else 0.62))
        container.add_child(empty_label)
        return

    var counts: Dictionary = {}
    for tag in visible_tags:
        counts[tag] = counts.get(tag, 0) + 1

    for tag in counts.keys():
        var label = Label.new()
        var count = counts[tag]
        if count > 1:
            label.text = tag + " × %d" % count
            label.add_theme_color_override("font_color", _multi_archive_tag_text_color(force_dark))
            label.add_theme_stylebox_override("normal", _make_multi_archive_tag_style(force_dark))
        else:
            label.text = tag
            label.add_theme_color_override("font_color", _archive_tag_text_color(force_dark))
            label.add_theme_stylebox_override("normal", _make_archive_tag_style(force_dark))
        label.add_theme_font_size_override("font_size", 29 if is_mobile else 12)
        container.add_child(label)

static func populate_archive_info(container: Control, game_state, is_mobile: bool = false, force_dark: bool = false) -> void :
    _clear_children(container)

    var character: Dictionary = {}
    if game_state.char_id != "" and game_state.char_id in GameData.characters:
        character = GameData.characters[game_state.char_id]

    var rows: = []
    var person_name: = str(character.get("person_name", ""))
    var is_bianwu: = str(game_state.route) == "边务线" or str(GameData.active_line) == "bianwu"
    if is_bianwu:
        person_name = "顾延澜"
    if person_name != "":
        rows.append(["姓名", person_name])
    rows.append(["出身", character.get("name", game_state.char_name if game_state.char_name != "" else "未定")])

    var active_branch = game_state.active_pending_event.get("branch", game_state.branch) if not game_state.active_pending_event.is_empty() else game_state.branch
    var is_early_game = active_branch in ["origin", "origin_fail", "origin_detour", "keju", "keju_continue"] or active_branch.begins_with("keju")

    if not is_early_game:
        rows.append(["路线", game_state.route if game_state.route != "" else "未定"])

    if not game_state.city.is_empty():
        var city_label: String = game_state.get_current_city_name()
        var juris: = str(game_state.city.get("juris", ""))
        if juris != "" and not city_label.ends_with(juris):
            city_label += juris
        rows.append(["任地", city_label])

    var has_rank = not is_early_game
    var rank_title = game_state.get_rank_title() if has_rank else "无"
    var rank_val
    var bracket_idx = rank_title.find("(")
    if bracket_idx == -1:
        bracket_idx = rank_title.find("（")

    if bracket_idx != -1:
        var main_rank = rank_title.substr(0, bracket_idx).strip_edges()
        var sub_rank = rank_title.substr(bracket_idx).strip_edges()
        rank_val = [main_rank, sub_rank]
    else:
        rank_val = rank_title

    rows.append(["品级", rank_val])


    if has_rank and game_state.has_method("get_active_honorary_title"):
        var honorary_val: = str(game_state.get_active_honorary_title())
        if honorary_val != "":
            rows.append(["散阶", honorary_val])

    var identity = "平民"
    if game_state.keju_status == "zhuangyuan": identity = "状元"
    elif game_state.keju_status == "bangyan": identity = "榜眼"
    elif game_state.keju_status == "tanhua": identity = "探花"
    elif game_state.keju_status == "erjia": identity = "二甲进士"
    elif game_state.keju_status == "sanjia": identity = "三甲同进士"
    elif game_state.keju_status == "jinshi": identity = "进士"
    elif game_state.keju_status == "gongshi": identity = "贡士"
    elif game_state.keju_status == "juren": identity = "举人"
    elif game_state.keju_status == "xiucai": identity = "秀才"
    elif game_state.keju_status == "tongshi": identity = "童生"

    var identity_val
    if identity != "平民" and game_state.get("keju_year_str") and game_state.keju_year_str != "":
        identity_val = [identity, "(%s)" % game_state.keju_year_str]
    else:
        identity_val = identity

    if not is_bianwu:
        rows.append(["科举", identity_val])
    rows.append(["年月", _get_archive_time_label(game_state)])
    rows.append(["年岁", str(game_state.age)])
    rows.append(["回合", "第 %d 回" % game_state.turn])
    if not is_early_game:
        rows.append(["国祚" if is_mobile else "国祚点数", "%d / 5" % game_state.guozuo_entries.size()])
    rows.append(["时评", _get_reputation(game_state)])

    var target_container = container
    if is_mobile:
        var card = PanelContainer.new()
        card.add_theme_stylebox_override("panel", _make_archive_info_card_style())
        card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        container.add_child(card)

        var grid = GridContainer.new()
        grid.columns = 2
        grid.add_theme_constant_override("h_separation", 44)
        grid.add_theme_constant_override("v_separation", 20)
        grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        card.add_child(grid)
        target_container = grid

    for row_data in rows:
        var row = HBoxContainer.new()
        row.add_theme_constant_override("separation", 10 if is_mobile else 8)
        if is_mobile:
            row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

        var label = Label.new()
        label.text = row_data[0]
        label.custom_minimum_size.x = 80 if is_mobile else 56
        label.add_theme_font_size_override("font_size", 31 if is_mobile else 12)
        label.add_theme_color_override("font_color", _side_color("text_sub", force_dark))
        row.add_child(label)

        var value
        if typeof(row_data[1]) == TYPE_ARRAY:
            value = VBoxContainer.new()
            value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            value.add_theme_constant_override("separation", 2)

            var val1 = Label.new()
            val1.text = row_data[1][0]
            val1.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if is_mobile else HORIZONTAL_ALIGNMENT_RIGHT
            val1.add_theme_font_size_override("font_size", 31 if is_mobile else 12)
            val1.add_theme_color_override("font_color", _side_color("text_desc", force_dark))
            value.add_child(val1)

            var val2 = Label.new()
            val2.text = row_data[1][1]
            val2.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if is_mobile else HORIZONTAL_ALIGNMENT_RIGHT
            val2.add_theme_font_size_override("font_size", 24 if is_mobile else 10)
            val2.add_theme_color_override("font_color", _side_color("text_sub", force_dark))
            value.add_child(val2)
        else:
            value = Label.new()
            value.text = str(row_data[1])
            value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            value.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if is_mobile else HORIZONTAL_ALIGNMENT_RIGHT
            value.add_theme_font_size_override("font_size", 31 if is_mobile else 12)
            value.add_theme_color_override("font_color", _side_color("text_desc", force_dark))

        row.add_child(value)

        target_container.add_child(row)

static func _get_archive_time_label(game_state) -> String:
    var year_label: = ""
    if game_state.has_method("get_current_year_str"):
        year_label = str(game_state.get_current_year_str()).strip_edges()
    if year_label == "":
        return "未定"

    var month_value: = 0
    if game_state.has_method("is_governance_mode") and game_state.is_governance_mode():
        month_value = int(game_state.month)
    else:
        var event_data: Dictionary = {}
        if game_state.has_method("get_current_event"):
            event_data = game_state.get_current_event()
        month_value = int(event_data.get("month", 0))

    var m_name: = GovernanceCalendarText.month_name(month_value) if month_value > 0 else ""
    if m_name != "":
        if not GameData.SEASON_NAMES.is_empty():
            return "%s·%s" % [year_label, m_name]
        return "%s%s" % [year_label, m_name]
    return year_label

static func populate_items(container: Control, items: Array = [], empty_text: String = "尚无物件", is_mobile: bool = false, force_dark: bool = false, select_callback: Callable = Callable()) -> void :
    _clear_children(container)
    if items.is_empty():
        var empty_label = Label.new()
        empty_label.text = empty_text
        empty_label.add_theme_font_size_override("font_size", 31 if is_mobile else 12)
        empty_label.add_theme_color_override("font_color", _side_color("text_sub", force_dark))
        empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        container.add_child(empty_label)
        return

    var current_row_hbox: HBoxContainer = null

    for i in range(items.size()):
        var card: = _build_item_card(items[i], is_mobile, container, force_dark, select_callback)

        if is_mobile:
            if i % 2 == 0:
                current_row_hbox = HBoxContainer.new()
                current_row_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                current_row_hbox.add_theme_constant_override("separation", 24)
                container.add_child(current_row_hbox)
            current_row_hbox.add_child(card)
        else:
            container.add_child(card)

    if is_mobile:
        container.add_theme_constant_override("separation", 24)
        if items.size() % 2 != 0 and current_row_hbox != null:
            var dummy: = Control.new()
            dummy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            current_row_hbox.add_child(dummy)


static func populate_items_columns(container: Control, items: Array, columns: int, is_mobile: bool = false, empty_text: String = "此分类暂无物件", select_callback: Callable = Callable(), selection_mode: bool = false, selected_id: String = "", view_callback: Callable = Callable(), view_selected_id: String = "", suppress_hint: bool = false, occupied_ids: Dictionary = {}, selection_type: String = "governance") -> void :
    _clear_children(container)
    columns = maxi(1, columns)
    if items.is_empty():
        var empty_label: = Label.new()
        empty_label.text = empty_text
        empty_label.add_theme_font_size_override("font_size", 14)
        empty_label.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        empty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        container.add_child(empty_label)
        return

    var current_row_hbox: HBoxContainer = null
    for i in range(items.size()):
        if i % columns == 0:
            current_row_hbox = HBoxContainer.new()
            current_row_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            current_row_hbox.add_theme_constant_override("separation", 10)
            container.add_child(current_row_hbox)
        var card: = _build_item_card(items[i], is_mobile, container, false, select_callback, selection_mode, selected_id, view_callback, view_selected_id, suppress_hint, occupied_ids, selection_type)
        current_row_hbox.add_child(card)


    var remainder: = items.size() % columns
    if remainder != 0 and current_row_hbox != null:
        for _j in range(columns - remainder):
            var dummy: = Control.new()
            dummy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            current_row_hbox.add_child(dummy)


static func _build_item_card(raw_item, is_mobile: bool, owner_lookup: Control = null, force_dark: bool = false, select_callback: Callable = Callable(), selection_mode: bool = false, selected_id: String = "", view_callback: Callable = Callable(), view_selected_id: String = "", suppress_hint: bool = false, occupied_ids: Dictionary = {}, selection_type: String = "governance") -> PanelContainer:
    var item: Dictionary = _resolve_item_city_placeholders(raw_item)
    var item_id_for_sel: = str(item.get("id", ""))

    var already_added: bool = selection_mode and item_id_for_sel != "" and occupied_ids.has(item_id_for_sel)

    var eligible: = GameState._item_is_personal_boost_eligible(item_id_for_sel) if selection_type == "personal" else GameState._item_is_boost_eligible(item_id_for_sel)
    var selectable: bool = ( not selection_mode) or (item_id_for_sel != "" and eligible and not already_added)
    var is_selected: bool = selection_mode and selectable and item_id_for_sel != "" and item_id_for_sel == selected_id

    var is_view_selected: bool = ( not selection_mode) and item_id_for_sel != "" and item_id_for_sel == view_selected_id
    var card = PanelContainer.new()
    card.mouse_filter = Control.MOUSE_FILTER_PASS
    card.add_theme_stylebox_override("panel", _make_item_card_style(is_mobile, force_dark, is_selected or is_view_selected))

    if selection_mode and not selectable:
        card.modulate = Color(1, 1, 1, 0.4)
    card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    card.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    card.tooltip_text = ""
    card.set_meta("item_data", item)
    card.set_meta("item_id", str(item.get("id", "")))
    if str(item.get("id", "")) != "" and not suppress_hint and bool(item.get("draggable", true)):
        card.set_drag_forwarding(Callable(GameScreenPresenter, "_get_item_drag_data").bind(item), Callable(), Callable())
    if not suppress_hint:
        card.mouse_entered.connect( func():
            _show_item_hint_card(card, _build_item_tooltip_text(item), is_mobile, true)
        )
        card.mouse_exited.connect( func():
            _hide_item_hint_card(true)
        )
    card.gui_input.connect( func(event: InputEvent):
        if _is_primary_press_event(event):



            var press_frame: = Engine.get_process_frames()
            if card.has_meta("_last_press_frame") and int(card.get_meta("_last_press_frame")) == press_frame:
                return
            card.set_meta("_last_press_frame", press_frame)
            var gs = owner_lookup.owner if owner_lookup else null
            if gs and gs.has_meta("items_scroll_touch_drag_suppress_until_ms"):
                if Time.get_ticks_msec() < int(gs.get_meta("items_scroll_touch_drag_suppress_until_ms", 0)):
                    return
            if select_callback.is_valid() and str(item.get("id", "")) != "" and selectable:
                select_callback.call(str(item.get("id", "")))
                return

            if view_callback.is_valid() and str(item.get("id", "")) != "":
                view_callback.call(str(item.get("id", "")))
                return
            if suppress_hint:
                return
            _show_item_detail_popup(card, item, is_mobile)
    )

    var card_box = VBoxContainer.new()
    card_box.add_theme_constant_override("separation", 0)
    card.add_child(card_box)

    var header = HBoxContainer.new()
    header.add_theme_constant_override("separation", 16 if is_mobile else 8)
    card_box.add_child(header)


    if selection_mode:
        var check = Label.new()
        check.text = "☑" if is_selected else "☐"
        check.custom_minimum_size = Vector2(40, 40) if is_mobile else Vector2(20, 20)
        check.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        check.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        check.add_theme_font_size_override("font_size", 32 if is_mobile else 16)
        check.add_theme_color_override("font_color", GameState.get_theme_color("border_active") if is_selected else _side_color("text_sub", force_dark))
        header.add_child(check)

    var icon_badge = Label.new()
    var item_icon = str(item.get("icon", ""))

    var fallback_glyph: = "物"
    var item_name_for_glyph: = str(item.get("name", "")).strip_edges()
    if item_name_for_glyph != "":
        fallback_glyph = item_name_for_glyph.substr(0, 1)
    icon_badge.text = item_icon if item_icon != "" else fallback_glyph
    icon_badge.custom_minimum_size = Vector2(72, 72) if is_mobile else Vector2(28, 28)
    icon_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    icon_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    icon_badge.add_theme_font_size_override("font_size", 38 if is_mobile else 13)
    icon_badge.add_theme_color_override("font_color", Color(0.82, 0.68, 0.38, 1.0))
    icon_badge.add_theme_stylebox_override("normal", _make_item_icon_badge_style())
    header.add_child(icon_badge)

    var text_box = VBoxContainer.new()
    text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    text_box.add_theme_constant_override("separation", 4 if is_mobile else 2)
    header.add_child(text_box)


    var name_row = HBoxContainer.new()
    name_row.add_theme_constant_override("separation", 12 if is_mobile else 6)
    text_box.add_child(name_row)

    var name_label = Label.new()
    name_label.text = str(item.get("name", "无名物件"))
    name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    name_label.add_theme_font_size_override("font_size", 34 if is_mobile else 13)
    name_label.add_theme_color_override("font_color", _side_color("text_desc", force_dark))
    name_row.add_child(name_label)

    if already_added:
        var added_tag = Label.new()
        added_tag.text = "已添加"
        added_tag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        added_tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        added_tag.add_theme_font_size_override("font_size", 22 if is_mobile else 11)
        added_tag.add_theme_color_override("font_color", _side_color("text_sub", force_dark))
        added_tag.add_theme_stylebox_override("normal", _make_item_added_tag_style())
        name_row.add_child(added_tag)

    var effect_label = Label.new()
    effect_label.text = _build_item_card_effect_summary(item)
    effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    effect_label.add_theme_font_size_override("font_size", 24 if is_mobile else 10)
    effect_label.add_theme_color_override("font_color", _side_color("text_sub", force_dark))
    text_box.add_child(effect_label)

    return card


static func _build_item_card_effect_summary(item: Dictionary) -> String:
    const PERSONAL_EFFECT_LABELS: = {"wentao": "文韬", "wulue": "武略", "lizheng": "理政", "tizhi": "体质"}
    var parts: Array[String] = []
    var effects: Dictionary = item.get("effects", {})
    for key in ["wentao", "wulue", "lizheng", "tizhi"]:
        var value: = int(effects.get(key, 0))
        if value != 0:
            parts.append("%s %+d" % [PERSONAL_EFFECT_LABELS[key], value])
    var city_effects: Dictionary = item.get("cityEffects", {})
    for key in GameData.CITY_STAT_KEYS:
        var value: = int(city_effects.get(key, 0))
        if value != 0:
            parts.append("%s %+d" % [GameData.city_stat_effect_label(key), value])
    var item_id: = str(item.get("id", ""))
    for status_part in GameState.get_item_status_effect_parts(item_id):
        parts.append(str(status_part))
    return "、".join(parts) if not parts.is_empty() else "暂无效果"

static func _get_item_drag_data(_at_position: Vector2, item: Dictionary):
    var item_id: = str(item.get("id", ""))
    if item_id == "":
        return null
    var preview: = Label.new()
    var item_name: = str(item.get("name", item_id))
    preview.text = item_name.substr(0, 1) if item_name != "" else "物"
    preview.custom_minimum_size = Vector2(34, 34)
    preview.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    preview.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    preview.add_theme_font_size_override("font_size", 16)
    preview.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    preview.add_theme_stylebox_override("normal", _make_item_icon_badge_style())
    return {"type": "city_boost_item", "item_id": item_id}

static func _build_item_tooltip_text(item: Dictionary) -> String:
    item = _resolve_item_city_placeholders(item)
    var lines: Array[String] = []
    lines.append(str(item.get("name", "无名物件")))
    lines.append("得自 " + str(item.get("source", "随身旧物")))
    var desc: = str(item.get("desc", "")).strip_edges()
    if desc != "":
        var sections: = _split_item_description_sections(desc)
        var body: = str(sections.get("body", "")).strip_edges()
        var effect: = str(sections.get("effect", "")).strip_edges()
        var note: = str(sections.get("note", "")).strip_edges()
        if effect == "":
            effect = _item_status_effect_fallback(str(item.get("id", "")))
        if body != "":
            lines.append("")
            lines.append(body)
        if effect != "":
            lines.append("")
            lines.append("[效果: %s]" % effect)
        if note != "":
            lines.append("")
            lines.append(note)
    return "\n".join(lines)

static func _show_item_detail_popup(anchor: Control, item: Dictionary, is_mobile: bool = false) -> void :
    _show_item_hint_card(anchor, _build_item_tooltip_text(item), is_mobile, false)

static func _is_native_mobile_landscape(anchor: Control) -> bool:
    if not OS.has_feature("android"):
        return false
    if anchor == null or not is_instance_valid(anchor):
        return false
    var viewport_size: = anchor.get_viewport_rect().size
    return viewport_size.x > viewport_size.y

static func _show_item_hint_card(anchor: Control, text: String, is_mobile: bool = false, opened_by_hover: bool = false) -> void :
    if anchor == null or not is_instance_valid(anchor):
        return
    var clean_text: = text.strip_edges()
    if clean_text == "":
        return
    var tree: = anchor.get_tree()
    if opened_by_hover:
        for node in tree.get_nodes_in_group("item_hint_overlay"):
            if node is Control and node.name == "ItemDetailPopup" and not bool(node.get_meta("opened_by_hover", false)):
                return
    _hide_item_hint_card(false)
    var overlay_layer: = CanvasLayer.new()
    overlay_layer.name = "ItemHintCanvasLayer"
    overlay_layer.layer = 120
    overlay_layer.set_meta("opened_by_hover", opened_by_hover)
    overlay_layer.add_to_group("item_hint_overlay")
    tree.root.add_child(overlay_layer)





    var popup: = Panel.new()
    popup.name = "ItemDetailPopup"
    popup.mouse_filter = Control.MOUSE_FILTER_IGNORE if opened_by_hover else Control.MOUSE_FILTER_STOP
    popup.set_anchors_preset(Control.PRESET_TOP_LEFT)
    popup.set_meta("opened_by_hover", opened_by_hover)
    popup.add_to_group("item_hint_overlay")

    var is_landscape_mobile: = _is_native_mobile_landscape(anchor)
    popup.add_theme_stylebox_override("panel", _make_item_detail_popup_style(is_mobile, is_landscape_mobile))
    popup.theme = anchor.theme

    var popup_width: = 880.0 if is_mobile else (546.0 if is_landscape_mobile else 420.0)
    var margins: = _item_detail_popup_margins(is_mobile, is_landscape_mobile)
    var content_box: = VBoxContainer.new()
    content_box.name = "PopupContent"
    content_box.custom_minimum_size = Vector2(popup_width, 0)
    content_box.position = Vector2(margins.x, margins.y)
    content_box.add_theme_constant_override("separation", 18 if is_mobile else (9 if is_landscape_mobile else 7))
    popup.add_child(content_box)
    _populate_item_hint_content(content_box, clean_text, is_mobile, popup_width, is_landscape_mobile)
    popup.custom_minimum_size = Vector2.ZERO

    overlay_layer.add_child(popup)
    popup.call_deferred("update_minimum_size")
    content_box.call_deferred("update_minimum_size")
    Callable(GameScreenPresenter, "_finalize_item_detail_card").call_deferred(popup, content_box, anchor, is_mobile)


static func get_open_click_item_popup() -> Control:
    var tree: = Engine.get_main_loop() as SceneTree
    if tree == null:
        return null
    for node in tree.get_nodes_in_group("item_hint_overlay"):
        if node is Control and node.name == "ItemDetailPopup" and not bool(node.get_meta("opened_by_hover", false)):
            return node as Control
    return null

static func _hide_item_hint_card(hover_only: bool = false) -> void :
    var tree: = Engine.get_main_loop() as SceneTree
    if tree == null:
        return
    for node in tree.get_nodes_in_group("item_hint_overlay"):
        if hover_only and not bool(node.get_meta("opened_by_hover", false)):
            continue
        if node is CanvasLayer or node is Control:
            node.queue_free()

static func _finalize_item_detail_card(popup: Control, content_box: VBoxContainer, anchor: Control, is_mobile: bool) -> void :
    if popup == null or content_box == null or anchor == null:
        return
    if not is_instance_valid(popup) or not is_instance_valid(content_box) or not is_instance_valid(anchor):
        return
    var is_landscape_mobile: = _is_native_mobile_landscape(anchor)
    var margins: = _item_detail_popup_margins(is_mobile, is_landscape_mobile)
    var content_size: = content_box.get_combined_minimum_size()
    content_box.size = content_size
    popup.size = Vector2(content_size.x + margins.x + margins.z, content_size.y + margins.y + margins.w)
    _position_item_detail_card(popup, anchor, is_mobile, is_landscape_mobile)

static func _position_item_detail_card(popup: Control, anchor: Control, is_mobile: bool, is_landscape_mobile: bool = false) -> void :
    var viewport_size: = anchor.get_viewport_rect().size
    var margin: = 16.0 if is_mobile else (12.0 if is_landscape_mobile else 10.0)
    var gap: = 12.0 if is_mobile else (12.0 if is_landscape_mobile else 10.0)
    var max_popup_height: = maxf(120.0, viewport_size.y - margin * 2.0)
    var popup_size: = Vector2(popup.size.x, minf(popup.size.y, max_popup_height))
    var anchor_rect: = anchor.get_global_rect()
    var x: = anchor_rect.end.x + gap
    var y: = anchor_rect.position.y

    if is_mobile:
        x = anchor_rect.position.x + (anchor_rect.size.x - popup_size.x) * 0.5
        y = anchor_rect.end.y + gap
        if y + popup_size.y > viewport_size.y - margin:
            y = anchor_rect.position.y - popup_size.y - gap
    elif x + popup_size.x > viewport_size.x - margin:
        x = anchor_rect.position.x - popup_size.x - gap

    x = clampf(x, margin, maxf(margin, viewport_size.x - popup_size.x - margin))
    y = clampf(y, margin, maxf(margin, viewport_size.y - popup_size.y - margin))
    popup.size = popup_size
    popup.global_position = Vector2(x, y)

static func _populate_item_hint_content(parent: VBoxContainer, text: String, is_mobile: bool, content_width: float, is_landscape_mobile: bool = false) -> void :
    var lines: = text.split("\n")
    var title: = str(lines[0]).strip_edges() if lines.size() > 0 else ""
    var source: = str(lines[1]).strip_edges() if lines.size() > 1 else ""
    var body_lines: Array[String] = []
    for idx in range(2, lines.size()):
        var clean: = str(lines[idx]).strip_edges()
        if clean != "":
            body_lines.append(clean)

    var title_label: = Label.new()
    title_label.text = title
    title_label.custom_minimum_size = Vector2(content_width, 0)
    title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    title_label.add_theme_font_override("font", FontLoader.title())
    title_label.add_theme_font_size_override("font_size", 53 if is_mobile else (25 if is_landscape_mobile else 19))
    title_label.add_theme_color_override("font_color", Color(0.95, 0.78, 0.42, 1.0) if GameState.theme == "dark" else Color(0.56, 0.37, 0.1, 1.0))
    parent.add_child(title_label)

    if source != "":
        var source_label: = Label.new()
        source_label.text = source
        source_label.custom_minimum_size = Vector2(content_width, 0)
        source_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        source_label.add_theme_font_size_override("font_size", 38 if is_mobile else (16 if is_landscape_mobile else 12))
        source_label.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        parent.add_child(source_label)

    var divider: = ColorRect.new()
    divider.custom_minimum_size = Vector2(content_width, 1)
    divider.color = Color(0.82, 0.68, 0.4, 0.3) if GameState.theme == "dark" else Color(0.56, 0.4, 0.16, 0.3)
    divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(divider)

    for line in body_lines:
        var is_effect: = line.begins_with("[效果") or line.begins_with("[当前收益")
        var is_income: = line.begins_with("[每月进账")
        var is_note: = _is_item_detail_note_line(line)
        var label: = Label.new()
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        label.add_theme_constant_override("line_spacing", 12 if is_mobile else (7 if is_landscape_mobile else 5))
        if is_note:
            label.text = line
            label.custom_minimum_size = Vector2(content_width, 0)
            label.add_theme_font_size_override("font_size", 34 if is_mobile else (16 if is_landscape_mobile else 13))
            label.add_theme_color_override("font_color", _item_detail_note_color())
        elif is_effect or is_income:
            var clean_line: = line.trim_prefix("[").trim_suffix("]")
            label.text = clean_line
            label.autowrap_mode = TextServer.AUTOWRAP_OFF
            label.add_theme_font_size_override("font_size", 36 if is_mobile else (14 if is_landscape_mobile else 13))
            label.add_theme_color_override("font_color", _archive_tag_text_color())

            var effect_tag_style: = _make_archive_tag_style()
            effect_tag_style.bg_color = Color(0, 0, 0, 0)
            label.add_theme_stylebox_override("normal", effect_tag_style)
            label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
        else:
            label.text = line
            label.custom_minimum_size = Vector2(content_width, 0)
            label.add_theme_font_size_override("font_size", 38 if is_mobile else (17 if is_landscape_mobile else 13))
            label.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        parent.add_child(label)

static func _item_detail_note_color() -> Color:
    var base: = GameState.get_theme_color("text_sub")
    if GameState.theme == "dark":
        return Color(base.r, base.g, base.b, 0.92)
    return Color(base.r * 0.82, base.g * 0.82, base.b * 0.82, 0.9)



static func _item_status_effect_fallback(item_id: String) -> String:
    if item_id == "":
        return ""
    var parts: Array = GameState.get_item_status_effect_parts(item_id)
    if parts.is_empty():
        return ""
    return "，".join(parts)

static func _split_item_description_sections(raw_desc: String) -> Dictionary:
    var sections: = {"body": raw_desc.strip_edges(), "effect": "", "note": ""}
    if raw_desc.strip_edges() == "":
        return sections

    var body: = raw_desc.strip_edges()
    var extracted_effects: Array[String] = []
    var extracted_notes: Array[String] = []
    for marker in ["效果：", "效果:", "[效果：", "[效果:"]:
        var idx: = body.find(marker)
        if idx >= 0:
            var effect_start: = idx
            if idx > 0 and body.substr(idx - 1, 1) == "[":
                effect_start = idx - 1
            var prefix: = body.substr(0, effect_start).strip_edges()
            var close_idx: = body.find("]", idx)
            var suffix: = body.substr(idx, body.length() - idx).strip_edges()
            if effect_start < idx and close_idx >= idx:
                suffix = body.substr(idx, close_idx - idx).strip_edges()
                var remaining: = body.substr(close_idx + 1, body.length() - close_idx - 1).strip_edges()
                if remaining != "":
                    body = "%s\n%s" % [prefix, remaining]
                else:
                    body = prefix
            else:
                body = prefix
            suffix = suffix.trim_prefix("[").trim_suffix("]")
            suffix = suffix.trim_prefix("效果：").trim_prefix("效果:").strip_edges()
            if suffix != "":
                extracted_effects.append(suffix)
            break

    var body_lines: Array[String] = []
    for line in body.split("\n"):
        var clean: = str(line).strip_edges()
        if clean == "":
            continue
        if clean.begins_with("备注：") or clean.begins_with("备注:"):
            extracted_notes.append(clean.trim_prefix("备注：").trim_prefix("备注:").strip_edges())
        elif _is_item_detail_note_line(clean):
            extracted_notes.append(clean)
        else:
            body_lines.append(clean)

    sections["body"] = "\n".join(body_lines).strip_edges()
    sections["effect"] = "\n".join(extracted_effects).strip_edges()
    sections["note"] = "\n".join(extracted_notes).strip_edges()
    return sections

static func _is_item_detail_note_line(line: String) -> bool:
    var clean: = line.strip_edges()
    return clean.begins_with("当前持有：")\
or clean.begins_with("当前持有:")\
or clean.begins_with("寒门开局加成：")\
or clean.begins_with("寒门开局加成:")\
or clean.begins_with("开局携带：")\
or clean.begins_with("开局携带:")\
or clean.begins_with("眼下")\
or clean.begins_with("当前")\
or clean.begins_with("当下")\
or clean.begins_with("此时")\
or clean.begins_with("目前")\
or clean.begins_with("已持有")\
or clean.begins_with("你现任")

static func _add_item_detail_section(parent: VBoxContainer, section_title: String, text: String, is_auxiliary: bool, is_mobile: bool) -> void :
    var clean: = text.strip_edges()
    if clean == "":
        return

    var section = PanelContainer.new()
    section.add_theme_stylebox_override("panel", _make_item_detail_section_style(is_auxiliary))
    parent.add_child(section)

    var box = VBoxContainer.new()
    box.add_theme_constant_override("separation", 5 if is_mobile else 3)
    section.add_child(box)

    var heading = Label.new()
    heading.text = section_title
    heading.add_theme_font_size_override("font_size", 24 if is_mobile else 10)
    heading.add_theme_color_override("font_color", Color(0.82, 0.68, 0.38, 1.0) if is_auxiliary else GameState.get_theme_color("text_sub"))
    box.add_child(heading)

    var body = Label.new()
    body.text = clean
    body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    if section_title == "备注":
        body.add_theme_font_size_override("font_size", 24 if is_mobile else 11)
    else:
        body.add_theme_font_size_override("font_size", 29 if is_mobile else 13)
    body.add_theme_constant_override("line_spacing", 8 if is_mobile else 5)
    var note_color: = GameState.get_theme_color("text_sub")
    if section_title == "备注":
        body.add_theme_color_override("font_color", Color(note_color.r, note_color.g, note_color.b, 0.66))
    else:
        body.add_theme_color_override("font_color", GameState.get_theme_color("text_desc") if not is_auxiliary else GameState.get_theme_color("text_sub"))
    box.add_child(body)

static func populate_attitudes(container: Control, attitudes: Dictionary, get_tier_text: Callable, get_tier_color: Callable, is_mobile: bool = false, force_dark: bool = false) -> void :
    _clear_children(container)

    var eff_dark: = force_dark or GameState.theme == "dark"
    var eff_pal: Dictionary = GameState.theme_colors["dark"] if eff_dark else GameState.theme_colors[GameState.theme]
    for key in GameData.ATT_KEYS:
        if not attitudes.has(key):
            continue
        if game_state_attitude_hidden(key):
            continue
        var wrapper = PanelContainer.new()
        wrapper.name = "AttitudeWrapper_" + key
        wrapper.mouse_filter = Control.MOUSE_FILTER_PASS
        var wrapper_style = StyleBoxFlat.new()
        wrapper_style.bg_color = Color(0.78, 0.62, 0.34, 0.03) if eff_dark else Color(0.85, 0.68, 0.4, 0.03)
        wrapper_style.border_width_left = 1
        wrapper_style.border_width_top = 1
        wrapper_style.border_width_right = 1
        wrapper_style.border_width_bottom = 1
        var border_col: Color = eff_pal.get("border_weak", GameState.get_theme_color("border_weak"))
        border_col.a = border_col.a * 0.3
        wrapper_style.border_color = border_col
        wrapper_style.corner_radius_top_left = 0
        wrapper_style.corner_radius_top_right = 0
        wrapper_style.corner_radius_bottom_right = 0
        wrapper_style.corner_radius_bottom_left = 0
        wrapper_style.content_margin_left = 14 if is_mobile else 10
        wrapper_style.content_margin_right = 14 if is_mobile else 10
        wrapper_style.content_margin_top = 12 if is_mobile else 8
        wrapper_style.content_margin_bottom = 12 if is_mobile else 8
        wrapper.add_theme_stylebox_override("panel", wrapper_style)

        var att_box = VBoxContainer.new()
        att_box.add_theme_constant_override("separation", 8 if is_mobile else 4)
        var is_locked: = game_state_attitude_locked(key)

        var is_emperor_dead_lock: bool = is_locked and GameState.emperor_dead and (key == "shengjuan" or key == "zhongguan")
        if is_emperor_dead_lock:
            wrapper.modulate = Color(0.5, 0.5, 0.5, 0.6)
            wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE
            att_box.mouse_filter = Control.MOUSE_FILTER_IGNORE

        var header = HBoxContainer.new()
        header.add_theme_constant_override("separation", 16 if is_mobile else 6)
        var icon = _make_status_icon_texture(key, 18.0)
        if icon:
            header.add_child(icon)

        var att_name = Label.new()
        att_name.text = GameData.ATT_LABELS.get(key, key)
        att_name.add_theme_font_size_override("font_size", 13)
        att_name.add_theme_color_override("font_color", eff_pal.get("text_sub", GameState.get_theme_color("text_sub")))
        header.add_child(att_name)

        var spacer = Control.new()
        spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        header.add_child(spacer)

        var value_label = Label.new()
        var att_value: = int(attitudes.get(key, 0))
        var show_as_dash = is_locked and not is_emperor_dead_lock
        value_label.text = "——" if show_as_dash else str(att_value)
        value_label.add_theme_font_size_override("font_size", 12)
        value_label.add_theme_color_override("font_color", eff_pal.get("text_desc", GameState.get_theme_color("text_desc")) if not show_as_dash else eff_pal.get("text_sub", GameState.get_theme_color("text_sub")))
        header.add_child(value_label)

        var tier = Label.new()
        tier.text = "" if show_as_dash else get_tier_text.call(key)
        tier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        tier.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        tier.add_theme_font_size_override("font_size", 10)
        var tier_color = get_tier_color.call(att_value) if not show_as_dash else GameState.get_theme_color("text_sub")
        tier.add_theme_color_override("font_color", tier_color)

        var tier_style = StyleBoxFlat.new()
        tier_style.bg_color = tier_color
        tier_style.bg_color.a = 0.08
        tier_style.border_width_left = 0
        tier_style.border_width_top = 0
        tier_style.border_width_right = 0
        tier_style.border_width_bottom = 0
        tier_style.corner_radius_top_left = 2
        tier_style.corner_radius_top_right = 2
        tier_style.corner_radius_bottom_right = 2
        tier_style.corner_radius_bottom_left = 2
        tier_style.content_margin_left = 12 if is_mobile else 6
        tier_style.content_margin_right = 12 if is_mobile else 6
        tier_style.content_margin_top = 6 if is_mobile else 2
        tier_style.content_margin_bottom = 6 if is_mobile else 2
        tier.add_theme_stylebox_override("normal", tier_style)

        header.add_child(tier)

        att_box.add_child(header)

        var ratio = clampf(float(att_value) / 100.0, 0.0, 1.0)
        var bar_back = create_gradient_bar(ratio, is_locked)
        att_box.add_child(bar_back)

        wrapper.add_child(att_box)
        container.add_child(wrapper)

static func render_event(event_data: Dictionary, date_label: Label, title_label: Label, speaker_avatar: Label, speaker_name: Label, speaker_role: Label, speaker_faction: Label, speaker_line: Label, narrative_label: Label, flavor_label: Label, focus_label: Label) -> void :
    date_label.text = _get_event_time_label(event_data)
    date_label.visible = date_label.text.strip_edges() != ""
    title_label.text = resolve_text_placeholders(str(event_data.get("title", "")))
    var speaker = event_data.get("speaker", {})
    if not (speaker is Dictionary):
        speaker = {"name": str(speaker)}
    var speaker_name_text: String = _resolve_speaker_name(resolve_text_placeholders(str(speaker.get("name", ""))))
    speaker_name.text = speaker_name_text
    speaker_avatar.text = speaker_name_text.substr(0, 1) if speaker_name_text != "" else "人"
    speaker_role.text = resolve_text_placeholders(str(speaker.get("role", speaker.get("title", ""))))
    speaker_faction.text = resolve_text_placeholders(str(speaker.get("faction", "")))
    speaker_role.visible = speaker_role.text != ""
    speaker_faction.visible = speaker_faction.text != ""
    speaker_line.text = resolve_text_placeholders(str(event_data.get("speakerLine", event_data.get("speaker_line", ""))))
    narrative_label.text = _compact_paragraph_breaks(resolve_text_placeholders(str(event_data.get("narrative", ""))))
    flavor_label.text = ""
    focus_label.text = resolve_text_placeholders(str(event_data.get("focusLine", event_data.get("focus_line", ""))))

static func get_event_time_label(event_data: Dictionary) -> String:
    return _get_event_time_label(event_data)

static func _get_event_time_label(event_data: Dictionary) -> String:
    var year_value: = int(event_data.get("year", 0))
    if year_value <= 0:
        return ""
    if year_value > 99:
        return "%d年" % year_value

    var year_label: = "崇祯元年" if year_value == 1 else "崇祯%s年" % _format_chinese_number(year_value)
    if bool(event_data.get("displayYearOnly", false)):
        return year_label
    var month_value: = int(event_data.get("month", 0))
    var m_name: = GovernanceCalendarText.month_name(month_value) if month_value > 0 else ""
    if m_name != "":
        return "%s·%s" % [year_label, m_name]
    return year_label

static func _format_chinese_number(value: int) -> String:
    var cn_nums: = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
    if value <= 10:
        return "十" if value == 10 else cn_nums[value]
    if value < 20:
        return "十%s" % cn_nums[value % 10]
    if value % 10 == 0:
        return "%s十" % cn_nums[int(value / 10)]
    return "%s十%s" % [cn_nums[int(value / 10)], cn_nums[value % 10]]

static func _format_chinese_number_large(value: int) -> String:
    var cn: = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
    if value <= 0:
        return cn[0]
    var result: = ""
    var units: = [["万", 10000], ["千", 1000], ["百", 100], ["十", 10]]
    var remaining: = value
    for unit in units:
        var u_name: String = unit[0]
        var u_val: int = unit[1]
        var digit: = remaining / u_val
        if digit > 0:
            if digit == 1 and u_val == 10 and result == "":
                result += u_name
            else:
                result += cn[digit] + u_name
            remaining %= u_val
        elif result != "" and remaining > 0:
            result += cn[0]
    if remaining > 0:
        result += cn[remaining]
    return result

static func _compact_paragraph_breaks(raw_text: String) -> String:
    var compact_lines: Array[String] = []
    var normalized: = raw_text.replace("\r\n", "\n").replace("\r", "\n")
    for line in normalized.split("\n"):
        var trimmed: = str(line).strip_edges()
        if trimmed != "":
            compact_lines.append(trimmed)
    return "\n".join(compact_lines)

static func _resolve_speaker_name(raw_name: String) -> String:
    if raw_name != "当朝天子":
        return raw_name
    if not GameState.has_method("get_current_year_str"):
        return raw_name
    var year_str: = str(GameState.get_current_year_str())
    if year_str.begins_with("万历"):
        return "万历帝"
    if year_str.begins_with("泰昌"):
        return "泰昌帝"
    if year_str.begins_with("天启"):
        return "天启帝"
    if year_str.begins_with("崇祯"):
        return "崇祯帝"
    return raw_name

static func build_effects_text(effects: Dictionary) -> String:
    var pos_parts: Array[String] = []
    var neg_parts: Array[String] = []
    for key in effects:
        var value = int(effects[key])
        if is_effect_positive(str(key), value):
            pos_parts.append("[" + format_effect_delta_text(key, value) + "]")
        elif is_effect_negative(str(key), value):
            neg_parts.append("[" + format_effect_delta_text(key, value) + "]")
    var parts = pos_parts + neg_parts
    return "  ".join(parts)

static func is_effect_positive(key: String, value: int) -> bool:
    if value == 0:
        return false
    if key == "mutiny_risk":
        return value < 0
    if key == "liumin":
        return value < 0
    return value > 0

static func is_effect_negative(key: String, value: int) -> bool:
    if value == 0:
        return false
    if key == "mutiny_risk":
        return value > 0
    if key == "liumin":
        return value > 0
    return value < 0

static func format_effect_delta_text(key: String, value: int) -> String:
    if key == "mutiny_risk":
        var risk_sign: = "+" if value > 0 else ""
        return "兵变概率 %s%s%%" % [risk_sign, str(value)]
    if key == "zhengji":
        var sign_merit = "+" if value > 0 else ""
        return "政绩 %s%s" % [sign_merit, str(value)]
    if key == "lingwu":
        var sign_lingwu = "+" if value > 0 else ""
        return "识悟 %s%s" % [sign_lingwu, str(value)]
    var label = GameData.STAT_LABELS.get(key, GameData.ATT_LABELS.get(key, GameData.CITY_STAT_LABELS.get(key, key)))
    if key == "guanjun" and is_instance_valid(GameState) and "bianwu_units" in GameState and not GameState.bianwu_units.is_empty():
        for u in GameState.bianwu_units:
            if u is Dictionary and not u.get("is_jiading", false):
                label = u.get("name", label)
                break
    elif key == "jiading" and is_instance_valid(GameState) and "bianwu_units" in GameState and not GameState.bianwu_units.is_empty():
        for u in GameState.bianwu_units:
            if u is Dictionary and u.get("is_jiading", false):
                label = u.get("name", label)
                break
    var sign = "+" if value > 0 else ""
    if GameData.CITY_STAT_KEYS.has(key):
        return "%s %s%s" % [GameData.city_stat_effect_label(key), sign, str(value)]
    if GameData.ATT_KEYS.has(key):
        return "%s %s%s" % [GameData.attitude_effect_label(key), sign, str(value)]
    return "%s %s%s" % [label, sign, str(value)]

static func _should_show_result_change(key: String) -> bool:
    if GameData.ATT_KEYS.has(key):
        return not game_state_attitude_hidden(key) and not (GameState.emperor_dead and (key == "shengjuan" or key == "zhongguan") and not ("北京解围" in GameState.tags or "摄政监国" in GameState.tags))
    return true

static func populate_result_changes(container: Control, effects: Dictionary, is_mobile: bool = false) -> void :
    _clear_children(container)
    container.visible = false
    var pos_keys: Array = []
    var neg_keys: Array = []
    for key in effects:
        if not _should_show_result_change(str(key)):
            continue
        var value = int(effects[key])
        if value == 0:
            continue
        if is_effect_positive(str(key), value):
            pos_keys.append(key)
        elif is_effect_negative(str(key), value):
            neg_keys.append(key)

    var all_keys = pos_keys + neg_keys
    for key in all_keys:
        var value = int(effects[key])
        var is_positive: = is_effect_positive(str(key), value)
        var chip = Label.new()
        chip.text = format_effect_delta_text(key, value)
        chip.set_meta("effect_key", str(key))
        chip.set_meta("effect_value", value)
        chip.set_meta("is_city_level_effect", GameData.CITY_STAT_KEYS.has(str(key)))
        chip.add_theme_font_size_override("font_size", 34 if is_mobile else 14)
        var chip_text_color: = _positive_delta_color() if is_positive else _negative_delta_color()
        if GameState.theme == "light" and not is_mobile:
            chip_text_color = Color(0.39, 0.27, 0.08, 1.0) if is_positive else Color(0.48, 0.18, 0.08, 1.0)
        chip.add_theme_color_override("font_color", chip_text_color)
        chip.add_theme_stylebox_override("normal", _make_result_chip_style(is_positive, is_mobile))
        container.add_child(chip)
        container.visible = true

static func populate_result_items(container: Control, item_ids: Array, is_mobile: bool = false) -> void :
    _clear_children(container)
    container.visible = false
    var visible_items: Array[Dictionary] = []
    for item_id in item_ids:
        var item_key: = str(item_id)
        var item_def: Dictionary = GameData.ITEM_DEFS.get(item_key, {})
        if item_def.is_empty():
            continue
        item_def = _resolve_item_city_placeholders(item_def)
        var city_effects: Dictionary = item_def.get("cityEffects", {})
        visible_items.append({
            "id": item_key, 
            "name": item_def.get("name", item_key), 
            "source": item_def.get("source", "随身旧物"), 
            "desc": item_def.get("desc", ""), 
            "icon": item_def.get("icon", ""), 
            "has_city_effects": not city_effects.is_empty()
        })
    if visible_items.is_empty():
        return

    container.visible = true
    var reward_panel = PanelContainer.new()
    reward_panel.add_theme_stylebox_override("panel", _make_result_item_panel_style(is_mobile))
    container.add_child(reward_panel)

    var box = VBoxContainer.new()
    box.add_theme_constant_override("separation", 14 if is_mobile else 8)
    reward_panel.add_child(box)

    var heading = Label.new()
    heading.text = "收 获 物 品"
    heading.add_theme_font_size_override("font_size", 35 if is_mobile else 12)
    heading.add_theme_color_override("font_color", _positive_delta_color())
    box.add_child(heading)

    for item in visible_items:
        var item_box = VBoxContainer.new()
        item_box.add_theme_constant_override("separation", 8 if is_mobile else 3)
        box.add_child(item_box)

        var name = Label.new()
        var icon = str(item.get("icon", ""))
        name.text = "%s %s" % [icon, item.get("name", item.get("id", "无名物件"))] if icon != "" else str(item.get("name", item.get("id", "无名物件")))
        name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        name.add_theme_font_size_override("font_size", 44 if is_mobile else 15)
        name.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        item_box.add_child(name)

        var source = Label.new()
        source.text = "得自 " + str(item.get("source", "随身旧物"))
        source.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        source.add_theme_font_size_override("font_size", 34 if is_mobile else 11)
        source.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        item_box.add_child(source)

        var desc_text: = str(item.get("desc", "")).strip_edges()
        var body: = desc_text
        var effect: = ""
        if desc_text != "":
            var sections: = _split_item_description_sections(desc_text)
            body = str(sections.get("body", "")).strip_edges()
            effect = str(sections.get("effect", "")).strip_edges()
        if effect == "":
            effect = _item_status_effect_fallback(str(item.get("id", "")))

        var desc = Label.new()
        desc.text = body
        desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        desc.add_theme_font_size_override("font_size", 37 if is_mobile else 12)
        desc.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        item_box.add_child(desc)

        if effect != "":
            var effect_label = Label.new()
            effect_label.text = "效果: " + effect
            effect_label.add_theme_font_size_override("font_size", 34 if is_mobile else 11)
            effect_label.add_theme_color_override("font_color", _archive_tag_text_color())
            effect_label.add_theme_stylebox_override("normal", _make_archive_tag_style())
            effect_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
            item_box.add_child(effect_label)

        if bool(item.get("has_city_effects", false)):
            var city_hint = Label.new()
            city_hint.text = "注：该道具需放入治理增益栏位中方可生效。"
            city_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            city_hint.add_theme_font_size_override("font_size", 30 if is_mobile else 10)
            city_hint.add_theme_color_override("font_color", Color(0.9, 0.74, 0.36, 1.0))
            item_box.add_child(city_hint)

static func _resolve_item_city_placeholders(item: Dictionary) -> Dictionary:
    var resolved: = item.duplicate(true)
    var replacements: = _build_text_placeholder_replacements()
    if replacements.is_empty():
        return resolved
    _apply_city_placeholders_to_dictionary(resolved, replacements)
    return resolved

static func resolve_text_placeholders(text: String) -> String:
    return _replace_city_placeholders(text, _build_text_placeholder_replacements())



static func resolve_dezheng_eval(item_id: String) -> String:
    if is_instance_valid(GameState) and GameState.dezheng_plaque_evals is Dictionary:
        var e: = str(GameState.dezheng_plaque_evals.get(item_id, ""))
        if e != "":
            return e

    return "德惟善政"

static func resolve_dezheng_item_text(item_id: String, text: String) -> String:
    if typeof(text) != TYPE_STRING or text.find("{dezheng_eval}") == -1:
        return text
    return text.replace("{dezheng_eval}", resolve_dezheng_eval(item_id))



static func apply_placeholders_with(data: Variant, replacements: Dictionary) -> void :
    if data is Dictionary:
        _apply_city_placeholders_to_dictionary(data, replacements)
    elif data is Array:
        _apply_city_placeholders_to_array(data, replacements)

static func _build_text_placeholder_replacements() -> Dictionary:
    var replacements: = {}
    if GameState.has_method("resolve_honorary_title_for_rank"):
        replacements["{new_honorary_title}"] = GameState.resolve_honorary_title_for_rank()
    var current_city: String = GameState.get_current_city_name()
    if current_city != "":
        replacements["{current_city}"] = current_city
    var current_province: = str(GameState.city.get("province", ""))
    if current_province != "":
        replacements["{current_province}"] = current_province
    var office_title: = GameState.get_office_title() if GameState.has_method("get_office_title") else GameState.get_rank_title()
    var office_juris: = GameState.get_office_juris_from_rank_title() if GameState.has_method("get_office_juris_from_rank_title") else ""
    if office_title != "":
        replacements["{official_title}"] = office_title
        replacements["{office_title}"] = office_title
        replacements["{office_short}"] = office_title
    if office_juris != "":
        replacements["{office_juris}"] = office_juris
        replacements["{office_scope}"] = office_juris
    var bingyong_val: int = GameState.city.get("bingyong", 0) if GameState.city else 0
    if bingyong_val > 0:
        replacements["{bingyong}"] = _format_chinese_number_large(bingyong_val)
    for act_idx in range(1, 7):
        var act_key: = str(act_idx)
        var city_cfg: Dictionary = GameState.resolve_transfer_city_for_act(act_key, GameState.get_rank_title())
        var city_name: = str(city_cfg.get("name", ""))
        if city_name != "":
            replacements["{city_%s}" % act_key] = city_name
    return replacements

static func _apply_city_placeholders_to_dictionary(data: Dictionary, replacements: Dictionary) -> void :
    for key in data.keys():
        var value = data[key]
        if value is String:
            data[key] = _replace_city_placeholders(value, replacements)
        elif value is Dictionary:
            _apply_city_placeholders_to_dictionary(value, replacements)
        elif value is Array:
            _apply_city_placeholders_to_array(value, replacements)

static func _apply_city_placeholders_to_array(data: Array, replacements: Dictionary) -> void :
    for idx in range(data.size()):
        var value = data[idx]
        if value is String:
            data[idx] = _replace_city_placeholders(value, replacements)
        elif value is Dictionary:
            _apply_city_placeholders_to_dictionary(value, replacements)
        elif value is Array:
            _apply_city_placeholders_to_array(value, replacements)

static func _replace_city_placeholders(text: String, replacements: Dictionary) -> String:
    var result: = text
    for placeholder in replacements:
        result = result.replace(str(placeholder), str(replacements[placeholder]))
    return result

static func populate_result_guozuo(container: Control, guozuo_ids: Array, is_mobile: bool = false) -> void :
    if guozuo_ids.is_empty():
        return
    container.visible = true
    var reward_panel = PanelContainer.new()
    reward_panel.add_theme_stylebox_override("panel", _make_result_item_panel_style(is_mobile))
    container.add_child(reward_panel)

    var box = VBoxContainer.new()
    box.add_theme_constant_override("separation", 10 if is_mobile else 5)
    reward_panel.add_child(box)

    var heading = Label.new()
    heading.text = "国 祚 入 档"
    heading.add_theme_font_size_override("font_size", 29 if is_mobile else 12)
    heading.add_theme_color_override("font_color", _positive_delta_color())
    box.add_child(heading)

    for raw_id in guozuo_ids:
        var guozuo_id: = str(raw_id)
        var label: = str(GUOZUO_LABELS.get(guozuo_id, guozuo_id))
        var line = Label.new()
        line.text = "国祚 +1：" + label
        line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        line.add_theme_font_size_override("font_size", 36 if is_mobile else 15)
        line.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        box.add_child(line)

static func populate_result_tags(container: Control, tags: Array, is_mobile: bool = false) -> void :
    _clear_children(container)
    for raw_tag in _unique_display_tags(tags):
        var chip = Label.new()
        chip.text = str(raw_tag)
        chip.add_theme_font_size_override("font_size", 34 if is_mobile else 12)
        chip.add_theme_color_override("font_color", _result_tag_text_color(is_mobile))
        chip.add_theme_stylebox_override("normal", _make_result_tag_style(is_mobile))
        container.add_child(chip)

static func has_visible_tags(tags: Array) -> bool:
    return not _unique_display_tags(tags).is_empty()




const HIDDEN_STATE_FLAGS: = [
    "欠账", 
    "北京解围", "摄政监国", "摄政辅军", "摄政止议", 
    "拥立皇子", "秘匿皇子", "拥兵京畿", "倾巢北上", "听调不宣", 
    "广济桥德政起誓", "广济桥夜议", "檄文号召", "号召旧部", 
    "改朝换代", "屈身事敌", "轻装急进", "功高履薄", 
    "袁案旧影", "文脉誓约", "守誓", "求援", "入宫", 
]

static func should_show_tag(tag: Variant) -> bool:
    return not (EffectsServiceRef.normalize_tag_name(tag) in HIDDEN_STATE_FLAGS)

static func _filter_display_tags(tags: Array) -> Array:
    var filtered: Array = []
    for tag in tags:
        var normalized_tag: = EffectsServiceRef.normalize_tag_name(tag)
        if should_show_tag(normalized_tag):
            filtered.append(normalized_tag)
    return filtered

static func _unique_display_tags(tags: Array) -> Array:
    var unique_tags: Array = []
    var seen: = {}
    for tag in _filter_display_tags(tags):
        if not seen.has(tag):
            seen[tag] = true
            unique_tags.append(tag)
    return unique_tags

static func game_state_attitude_locked(key: String) -> bool:

    var active_branch = GameState.active_pending_event.get("branch", GameState.branch) if not GameState.active_pending_event.is_empty() else GameState.branch
    var is_early_game = active_branch in ["origin", "origin_fail", "origin_detour", "keju", "keju_continue"] or active_branch.begins_with("keju")
    if is_early_game:

        return false

    if "北京解围" in GameState.tags or "摄政监国" in GameState.tags:
        return false

    return GameState.emperor_dead and (key == "shengjuan" or key == "zhongguan")

static func game_state_attitude_hidden(key: String) -> bool:
    if key != "shengjuan" and key != "zhongguan":
        return false
    var active_branch = GameState.active_pending_event.get("branch", GameState.branch) if not GameState.active_pending_event.is_empty() else GameState.branch
    var is_early_game = active_branch in ["origin", "origin_fail", "origin_detour", "keju", "keju_continue"] or active_branch.begins_with("keju")
    return is_early_game and not _has_reached_xiucai()

static func _has_reached_xiucai() -> bool:
    return GameState.keju_status in ["xiucai", "juren", "gongshi", "jinshi", "sanjia", "erjia", "tanhua", "bangyan", "zhuangyuan"]

static func _get_reputation(game_state) -> String:
    var active_branch = game_state.active_pending_event.get("branch", game_state.branch) if not game_state.active_pending_event.is_empty() else game_state.branch
    var is_early_game = active_branch in ["origin", "origin_fail", "origin_detour", "keju", "keju_continue"] or active_branch.begins_with("keju")

    if is_early_game:

        if game_state.keju_status == "juren":
            return "乡举老爷"
        if game_state.keju_status == "xiucai" and game_state.age < 15:
            return "神童秀才"

        if game_state.age < 7:
            return "黄口孺子"
        if game_state.age < 15 and game_state.stats.get("wentao", 0) >= 30:
            return "早慧神童"
        if game_state.age < 15:
            return "蒙童"
        if game_state.age >= 30 and game_state.keju_status in ["none", "tongshi_prep", "tongshi"]:
            return "白首老童生"
        if game_state.age >= 35 and game_state.keju_status == "xiucai":
            return "屡试不中"
        if game_state.stats.get("wentao", 0) >= 60:
            return "才名远播"
        if game_state.keju_status == "juren":
            return "乡举老爷"
        if game_state.keju_status == "xiucai":
            return "庠序秀才"
        return "寒窗苦读"

    var att = game_state.attitudes
    var tags = game_state.tags
    var total_tags = tags.size()
    var counts: Dictionary = {}
    for tag in tags:
        counts[tag] = counts.get(tag, 0) + 1



    var axis_minben = counts.get("保民", 0) + counts.get("惠民", 0) + counts.get("保城", 0)\
+ counts.get("德政", 0) + counts.get("救荒", 0) + counts.get("薯册救荒", 0)\
+ counts.get("以工代赈", 0) + counts.get("屯田安众", 0) + counts.get("流民屯田", 0)\
- counts.get("伤民", 0) - counts.get("失民", 0)

    var axis_lichang = counts.get("士绅龃龉", 0) + counts.get("奉公", 0)\
- counts.get("士绅交好", 0) - counts.get("地方坐大", 0)

    var axis_lianjie = - counts.get("贪墨", 0) - counts.get("权金开道", 0) - counts.get("借商", 0)\
- (1 if game_state.private_silver >= 60 else 0)\
+ counts.get("自清", 0) + (1 if game_state.private_silver < 15 else 0)

    var axis_quanshu = counts.get("擅权", 0) + counts.get("权术", 0) + counts.get("功高震主", 0)\
+ counts.get("拥兵京畿", 0)

    var axis_didang = counts.get("帝党", 0) + counts.get("内庭牵连", 0) + counts.get("入宫", 0)

    var axis_guzhi = counts.get("抗命", 0) + counts.get("冒死", 0) + counts.get("自辩", 0)




    var rank_idx = int(game_state.rank_index)
    var tenure_months = 0
    if int(game_state.year) > 0 and int(game_state.month) > 0:
        tenure_months = max(0, (int(game_state.year) - 1) * 12 + int(game_state.month) - 9)

    var is_senior_minister = rank_idx >= 8 or tenure_months >= 48

    var is_seasoned_official = rank_idx >= 4 or tenure_months >= 24

    if is_senior_minister and att.get("shengjuan", 0) >= 72 and att.get("minwang", 0) >= 58 and game_state.stats.get("lizheng", 0) >= 50:
        return "社稷之臣"

    if is_seasoned_official and att.get("shengjuan", 0) >= 72 and att.get("qingyi", 0) >= 58 and counts.get("奉公", 0) >= 3:
        return "忠臣"

    if game_state.stats.get("lizheng", 0) >= 55 and axis_minben >= 2 and axis_lianjie <= -2:
        return "能臣干吏"
    if game_state.stats.get("lizheng", 0) >= 60 and att.get("shengjuan", 0) >= 50:
        return "能臣"

    if axis_minben <= -2 and att.get("minwang", 0) < 40 and att.get("shengjuan", 0) >= 60:
        return "酷吏"


    if axis_lichang <= -2 and axis_lianjie < 0 and att.get("minwang", 0) < 45 and axis_minben <= 0:
        return "奸臣"

    if is_seasoned_official and axis_didang >= 2 and att.get("shengjuan", 0) >= 65:
        return "帝党核心"

    if is_senior_minister and axis_quanshu >= 2 and att.get("shengjuan", 0) >= 55:
        return "权臣"

    if axis_guzhi >= 3 and axis_lianjie >= 0 and att.get("shengjuan", 0) < 45 and axis_quanshu < 2:
        return "孤臣"
    if att.get("qingyi", 0) >= 72 and game_state.stats.get("wentao", 0) >= 60:
        return "清流"

    if att.get("minwang", 0) >= 72 and att.get("shengjuan", 0) < 40:
        return "诤臣"



    if axis_lianjie >= 1 and game_state.stats.get("lizheng", 0) >= 50 and att.get("minwang", 0) >= 60 and axis_minben >= 1:
        return "百姓青天" if (att.get("minwang", 0) >= 70 and axis_minben >= 4) else "两袖清风"


    if game_state.stats.get("wulue", 0) >= 65 and (counts.get("军功", 0) >= 1 or counts.get("御寇", 0) >= 1):
        return "百战督帅"
    if game_state.stats.get("wulue", 0) >= 50 and (counts.get("军功", 0) >= 1 or counts.get("御寇", 0) >= 1 or counts.get("团练", 0) >= 1):
        return "知兵文臣"


    if att.get("zhongguan", 0) >= 70 and att.get("qingyi", 0) < 40 and att.get("shengjuan", 0) >= 50:
        return "阉党爪牙" if att.get("zhongguan", 0) >= 80 else "浊流之辈"

    var governance_months = tenure_months
    var notable_record = total_tags >= 2 or game_state.stats.get("lizheng", 0) >= 45 or att.get("minwang", 0) >= 55 or att.get("shengjuan", 0) >= 55

    if governance_months < 3:
        return "初任视事"
    if total_tags >= 4:
        return "不粘锅"
    if governance_months >= 18 and not notable_record:
        return "尸位素餐"
    if governance_months >= 10 and not notable_record:
        return "庸臣"
    return "初入宦海"

static func _clear_children(container: Control) -> void :
    for child in container.get_children():
        child.queue_free()

static func _make_result_chip_style(is_positive: bool, is_mobile: bool = false) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    if GameState.theme == "light" and not is_mobile:
        style.bg_color = Color(1, 1, 1, 0.16)
    else:
        style.bg_color = Color(0.072, 0.056, 0.04, 0.94) if GameState.theme == "dark" else Color(0.93, 0.89, 0.8, 0.7)
    _apply_style_border_width(style, int(MOBILE_HAIRLINE_WIDTH) if is_mobile else 1)
    if GameState.theme == "light" and not is_mobile:
        style.border_color = Color(1, 1, 1, 0.34)
    else:
        style.border_color = Color(0.78, 0.65, 0.38, 0.48) if is_positive else Color(0.48, 0.2, 0.1, 0.42)
    style.content_margin_left = 18 if is_mobile else 10
    style.content_margin_right = 18 if is_mobile else 10
    style.content_margin_top = 10 if is_mobile else 5
    style.content_margin_bottom = 10 if is_mobile else 5
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_right = 2
    style.corner_radius_bottom_left = 2
    return style

static func _make_result_item_panel_style(is_mobile: bool = false) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(1, 1, 1, 0.07) if GameState.theme == "light" and not is_mobile else Color(0.72, 0.6, 0.34, 0.14)
    _apply_style_border_width(style, int(MOBILE_HAIRLINE_WIDTH) if is_mobile else 1)
    style.border_color = Color(1, 1, 1, 0.22) if GameState.theme == "light" and not is_mobile else Color(0.72, 0.6, 0.34, 0.38)
    style.content_margin_left = 24 if is_mobile else 14
    style.content_margin_right = 24 if is_mobile else 14
    style.content_margin_top = 18 if is_mobile else 10
    style.content_margin_bottom = 18 if is_mobile else 10
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_right = 2
    style.corner_radius_bottom_left = 2
    return style

static func _make_result_tag_style(is_mobile: bool = false) -> StyleBoxFlat:
    var style: = _make_archive_tag_style()
    if GameState.theme == "light" and not is_mobile:
        style.bg_color = Color(0.95, 0.93, 0.88, 0.92)
        style.border_color = Color(0.25, 0.23, 0.2, 0.3)
        style.content_margin_left = 9
        style.content_margin_right = 9
        style.content_margin_top = 4
        style.content_margin_bottom = 4
    return style

static func _result_tag_text_color(is_mobile: bool = false) -> Color:
    if GameState.theme == "light" and not is_mobile:
        return Color(0.22, 0.19, 0.15, 0.96)
    return _archive_tag_text_color()

static func _negative_delta_color() -> Color:
    return Color(0.7, 0.32, 0.14, 1.0) if GameState.theme == "dark" else Color(0.58, 0.25, 0.1, 1.0)

static func _positive_delta_color() -> Color:
    return Color(0.82, 0.68, 0.38, 1.0) if GameState.theme == "dark" else Color(0.5, 0.36, 0.1, 1.0)

static func negative_delta_color() -> Color:
    return _negative_delta_color()

static func positive_delta_color() -> Color:
    return _positive_delta_color()

static func _make_archive_tag_style(force_dark: bool = false) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()

    if force_dark and GameState.theme == "light":
        style.bg_color = Color(0, 0, 0, 0)
    else:
        style.bg_color = Color(0.07, 0.055, 0.038, 0.82) if _side_is_dark(force_dark) else Color(0.96, 0.91, 0.78, 0.72)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = Color(0.78, 0.61, 0.32, 0.56) if _side_is_dark(force_dark) else Color(0.62, 0.45, 0.16, 0.48)
    style.content_margin_left = 7
    style.content_margin_right = 7
    style.content_margin_top = 3
    style.content_margin_bottom = 3
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_right = 2
    style.corner_radius_bottom_left = 2
    return style

static func _make_item_card_style(is_mobile: bool = false, force_dark: bool = false, selected: bool = false) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()

    if force_dark and GameState.theme == "light":
        style.bg_color = Color(0.2, 0.19, 0.17, 0.66)
    else:
        style.bg_color = Color(0.072, 0.06, 0.043, 0.72) if _side_is_dark(force_dark) else Color(1.0, 1.0, 1.0, 0.92)
    _apply_style_border_width(style, int(MOBILE_HAIRLINE_WIDTH) if is_mobile else 1)
    style.border_color = Color(0.72, 0.6, 0.34, 0.3) if _side_is_dark(force_dark) else Color(0.62, 0.48, 0.2, 0.3)

    if selected:
        var accent: = GameState.get_theme_color("border_active")
        _apply_style_border_width(style, 2 if is_mobile else 1)
        style.border_color = Color(accent.r, accent.g, accent.b, 0.55)
        style.bg_color = Color(accent.r, accent.g, accent.b, 0.08)
    var horizontal_margin = 16 if is_mobile else 10
    var vertical_margin = 16 if is_mobile else 10
    style.content_margin_left = horizontal_margin
    style.content_margin_right = horizontal_margin
    style.content_margin_top = vertical_margin
    style.content_margin_bottom = vertical_margin
    style.corner_radius_top_left = 3
    style.corner_radius_top_right = 3
    style.corner_radius_bottom_right = 3
    style.corner_radius_bottom_left = 3
    return style

static func _make_archive_info_card_style() -> StyleBoxFlat:
    var style: = _make_item_card_style(true)
    style.content_margin_left = MOBILE_ARCHIVE_CARD_SIDE_PADDING
    style.content_margin_right = MOBILE_ARCHIVE_CARD_SIDE_PADDING
    style.content_margin_top = MOBILE_ARCHIVE_CARD_VERTICAL_PADDING
    style.content_margin_bottom = MOBILE_ARCHIVE_CARD_VERTICAL_PADDING
    return style

static func _make_item_icon_badge_style() -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0.78, 0.62, 0.34, 0.14) if GameState.theme == "dark" else Color(0.72, 0.6, 0.34, 0.16)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = Color(0.78, 0.62, 0.34, 0.36) if GameState.theme == "dark" else Color(0.62, 0.48, 0.2, 0.36)
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_right = 2
    style.corner_radius_bottom_left = 2
    return style


static func _make_item_added_tag_style() -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0.78, 0.62, 0.34, 0.12) if GameState.theme == "dark" else Color(0.72, 0.6, 0.34, 0.14)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = Color(0.78, 0.62, 0.34, 0.34) if GameState.theme == "dark" else Color(0.62, 0.48, 0.2, 0.34)
    style.content_margin_left = 6
    style.content_margin_right = 6
    style.content_margin_top = 1
    style.content_margin_bottom = 2
    style.corner_radius_top_left = 3
    style.corner_radius_top_right = 3
    style.corner_radius_bottom_right = 3
    style.corner_radius_bottom_left = 3
    return style

static func _make_item_detail_popup_style(is_mobile: bool = false, is_landscape_mobile: bool = false) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0.035, 0.029, 0.022, 0.97) if GameState.theme == "dark" else Color.html("EAECF0")
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = Color(0.82, 0.68, 0.4, 0.44) if GameState.theme == "dark" else Color(0.56, 0.4, 0.16, 0.42)
    var pad: = 34 if is_mobile else (18 if is_landscape_mobile else 14)
    style.content_margin_left = pad
    style.content_margin_right = pad
    style.content_margin_top = 28 if is_mobile else (16 if is_landscape_mobile else 12)
    style.content_margin_bottom = 28 if is_mobile else (16 if is_landscape_mobile else 12)
    style.corner_radius_top_left = 5
    style.corner_radius_top_right = 5
    style.corner_radius_bottom_right = 5
    style.corner_radius_bottom_left = 5
    if GameState.theme == "dark":
        style.shadow_color = Color(0, 0, 0, 0.42)
        style.shadow_size = 10
        style.shadow_offset = Vector2(0, 5)
    return style

static func _item_detail_popup_margins(is_mobile: bool = false, is_landscape_mobile: bool = false) -> Vector4:
    var horizontal: = 48.0 if is_mobile else (18.0 if is_landscape_mobile else 14.0)
    var top: = 40.0 if is_mobile else (16.0 if is_landscape_mobile else 12.0)
    var bottom: = 40.0 if is_mobile else (16.0 if is_landscape_mobile else 12.0)
    return Vector4(horizontal, top, horizontal, bottom)

static func _make_item_detail_section_style(is_auxiliary: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    if is_auxiliary:
        style.bg_color = Color(0.78, 0.62, 0.34, 0.1) if GameState.theme == "dark" else Color(0.7, 0.55, 0.25, 0.12)
        style.border_color = Color(0.78, 0.62, 0.34, 0.28) if GameState.theme == "dark" else Color(0.56, 0.4, 0.16, 0.26)
    else:
        style.bg_color = Color(0.02, 0.018, 0.014, 0.18) if GameState.theme == "dark" else Color(1.0, 0.97, 0.88, 0.18)
        style.border_color = Color(0.72, 0.6, 0.34, 0.16) if GameState.theme == "dark" else Color(0.54, 0.4, 0.18, 0.16)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.content_margin_left = 10
    style.content_margin_right = 10
    style.content_margin_top = 8
    style.content_margin_bottom = 9
    style.corner_radius_top_left = 3
    style.corner_radius_top_right = 3
    style.corner_radius_bottom_right = 3
    style.corner_radius_bottom_left = 3
    return style

static func _archive_tag_text_color(force_dark: bool = false) -> Color:
    return Color(0.78, 0.62, 0.28, 1.0) if _side_is_dark(force_dark) else Color(0.54, 0.4, 0.12, 1.0)

static func create_gradient_bar(ratio: float, is_locked: bool) -> Panel:
    var bar_height = 4
    var bg = Panel.new()
    bg.custom_minimum_size = Vector2(0, bar_height)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    bg.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW

    var bg_style = StyleBoxFlat.new()
    bg_style.bg_color = Color(0.24, 0.18, 0.12, 0.95) if GameState.theme == "light" else Color(0.22, 0.2, 0.17, 0.62)
    bg_style.corner_radius_top_left = 2
    bg_style.corner_radius_top_right = 2
    bg_style.corner_radius_bottom_left = 2
    bg_style.corner_radius_bottom_right = 2
    bg.add_theme_stylebox_override("panel", bg_style)

    var fill = TextureRect.new()
    fill.anchor_right = clampf(ratio, 0.0, 1.0)
    fill.anchor_bottom = 1.0
    fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
    fill.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

    if is_locked:
        var grad = Gradient.new()
        grad.set_color(0, Color(0.2, 0.2, 0.2, 0.8))
        grad.set_color(1, Color(0.3, 0.3, 0.3, 0.8))
        var grad_tex = GradientTexture1D.new()
        grad_tex.gradient = grad
        fill.texture = grad_tex
    else:
        var low_color = Color(0.7, 0.24, 0.14, 0.95)
        var high_color = Color(0.86, 0.69, 0.36, 0.95)
        var base_color = low_color.lerp(high_color, ratio)
        var grad = Gradient.new()
        grad.set_color(0, base_color.lightened(0.2))
        grad.set_color(1, base_color)
        var grad_tex = GradientTexture1D.new()
        grad_tex.gradient = grad
        fill.texture = grad_tex

    bg.add_child(fill)
    return bg

static func _make_status_icon_texture(key: String, icon_size: float):
    if not STATUS_ICON_PATHS.has(key):
        return null
    var tex: = load(STATUS_ICON_PATHS[key]) as Texture2D
    if tex == null:
        return null
    var icon: = TextureRect.new()
    icon.texture = tex
    icon.custom_minimum_size = Vector2(icon_size, icon_size)
    icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    icon.modulate = Color(1.0, 0.92, 0.74, 0.92) if GameState.theme == "dark" else Color(1.0, 1.0, 1.0, 1.0)
    return icon
