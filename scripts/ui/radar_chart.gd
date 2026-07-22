extends Control
class_name RadarChart

var target_stats: Dictionary = {}
var animated_stats: Dictionary = {}
var animated_value_labels: Dictionary = {}
var max_val: float = 100.0

var force_dark_palette: = false

const KEYS = ["wentao", "lizheng", "wulue", "tizhi"]
const LABELS = ["文韬", "理政", "武略", "体质"]
const STATUS_ICON_PATHS: = {
    "wentao": "res://assets/ui/status_icons/wentao.webp", 
    "lizheng": "res://assets/ui/status_icons/lizheng.webp", 
    "wulue": "res://assets/ui/status_icons/wulue.webp", 
    "tizhi": "res://assets/ui/status_icons/tizhi.webp"
}
const GRID_RING_COUNT: = 4
const GRID_COLOR: = Color(0.34, 0.27, 0.18, 0.72)
const AXIS_COLOR: = Color(0.3, 0.24, 0.16, 0.58)
const GRID_COLOR_LIGHT: = Color(0.34, 0.27, 0.18, 0.4)
const AXIS_COLOR_LIGHT: = Color(0.3, 0.24, 0.16, 0.32)
const DATA_FILL_COLOR: = Color(0.75, 0.6, 0.25, 0.45)
const DATA_CORE_FILL_COLOR: = Color(0.8, 0.65, 0.3, 0.6)
const DATA_OUTLINE_COLOR: = Color(0.86, 0.74, 0.47, 0.96)
const DATA_GLOW_COLOR: = Color(0, 0, 0, 0)
const LABEL_COLOR: = Color(0.64, 0.55, 0.39, 0.98)
const VALUE_COLOR: = Color(0.86, 0.74, 0.47, 1.0)
const LABEL_COLOR_LIGHT: = Color(0.34, 0.28, 0.2, 0.92)
const VALUE_COLOR_LIGHT: = Color(0.58, 0.42, 0.12, 1.0)
const LABEL_VALUE_GAP: = 6.0
const ICON_LABEL_GAP: = 0.0
const LABEL_ICON_SIZE: = 20.0
const LABEL_ICON_SIZE_DEFAULT: = 20.0
const VERTICAL_AXIS_GAP: = 10.0
const CHART_TOP_LABEL_RESERVE_DEFAULT: = 56.0
const CHART_BOTTOM_LABEL_RESERVE_DEFAULT: = 56.0
var chart_top_label_reserve: = CHART_TOP_LABEL_RESERVE_DEFAULT
var chart_bottom_label_reserve: = CHART_BOTTOM_LABEL_RESERVE_DEFAULT
var label_icon_size: = LABEL_ICON_SIZE_DEFAULT:
    set(value):
        label_icon_size = value
        _update_chart_geometry()
        queue_redraw()
var chart_scale: = 1.0:
    set(value):
        chart_scale = value
        _update_chart_geometry()
        queue_redraw()

var label_group_nodes: Array[VBoxContainer] = []
var label_name_rows: Array[HBoxContainer] = []
var icon_nodes: Array[TextureRect] = []
var labels_nodes: Array[Label] = []
var val_nodes: Array[Label] = []
var grid_rings: Array[Line2D] = []
var axis_lines: Array[Line2D] = []
var data_fill: Polygon2D
var data_core_fill: Polygon2D
var data_outline: Line2D

func _ready():
    custom_minimum_size = Vector2(160, 180)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _ensure_render_nodes()
    _ensure_text_nodes()
    resized.connect(_update_chart_geometry)
    set_process(false)
    _update_chart_geometry()

func update_stats(new_stats: Dictionary) -> void :
    if not target_stats.is_empty():
        for i in range(KEYS.size()):
            var key = KEYS[i]
            var new_val = int(new_stats.get(key, 0))
            var old_val = int(target_stats.get(key, 0))
            if new_val != old_val:
                var diff = new_val - old_val
                if i < val_nodes.size():
                    var val_label = val_nodes[i]
                    _animate_control_value_change(val_label, diff, old_val, new_val)

    target_stats = new_stats.duplicate()
    if animated_stats.is_empty():
        for k in KEYS:
            animated_stats[k] = float(target_stats.get(k, 0))
        _update_chart_geometry()
    else:
        set_process(true)

func _process(delta: float) -> void :
    var all_done = true
    var speed = 15.0
    for k in KEYS:
        var target = float(target_stats.get(k, 0))
        var current = float(animated_stats.get(k, target))
        if abs(current - target) > 0.5:
            animated_stats[k] = lerpf(current, target, clampf(speed * delta, 0.0, 1.0))
            all_done = false
        else:
            animated_stats[k] = target

    _update_chart_geometry()

    if all_done:
        set_process(false)

func _ensure_render_nodes() -> void :
    if data_fill != null:
        return

    for i in range(GRID_RING_COUNT):
        var ring: = Line2D.new()
        ring.default_color = GRID_COLOR
        ring.width = 1.0
        ring.closed = true
        ring.antialiased = true
        ring.joint_mode = Line2D.LINE_JOINT_SHARP
        add_child(ring)
        grid_rings.append(ring)

    for i in range(KEYS.size()):
        var axis: = Line2D.new()
        axis.default_color = AXIS_COLOR
        axis.width = 1.0
        axis.antialiased = true
        add_child(axis)
        axis_lines.append(axis)

    data_fill = Polygon2D.new()
    data_fill.color = DATA_FILL_COLOR
    data_fill.antialiased = true
    add_child(data_fill)

    data_core_fill = Polygon2D.new()
    data_core_fill.color = DATA_CORE_FILL_COLOR
    data_core_fill.antialiased = true
    add_child(data_core_fill)

    data_outline = Line2D.new()
    data_outline.default_color = DATA_OUTLINE_COLOR
    data_outline.width = 1.0
    data_outline.closed = true
    data_outline.antialiased = true
    data_outline.joint_mode = Line2D.LINE_JOINT_SHARP
    add_child(data_outline)

func _ensure_text_nodes() -> void :
    if not labels_nodes.is_empty():
        return

    for i in range(KEYS.size()):
        var group: = VBoxContainer.new()
        group.mouse_filter = Control.MOUSE_FILTER_IGNORE
        group.alignment = BoxContainer.ALIGNMENT_CENTER
        group.add_theme_constant_override("separation", LABEL_VALUE_GAP)
        add_child(group)
        label_group_nodes.append(group)

        var name_row: = HBoxContainer.new()
        name_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
        name_row.alignment = BoxContainer.ALIGNMENT_CENTER
        name_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        name_row.add_theme_constant_override("separation", ICON_LABEL_GAP)
        group.add_child(name_row)
        label_name_rows.append(name_row)

        var icon: = TextureRect.new()
        icon.texture = load(STATUS_ICON_PATHS.get(KEYS[i], "")) as Texture2D
        icon.custom_minimum_size = Vector2(label_icon_size, label_icon_size)
        icon.size = Vector2(label_icon_size, label_icon_size)
        icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
        icon.visible = false
        name_row.add_child(icon)
        icon_nodes.append(icon)

        var l: = Label.new()
        l.add_theme_font_size_override("font_size", 13)
        l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        l.mouse_filter = Control.MOUSE_FILTER_IGNORE
        name_row.add_child(l)
        labels_nodes.append(l)

        var v: = Label.new()
        v.add_theme_font_size_override("font_size", 12)
        v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        v.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        v.mouse_filter = Control.MOUSE_FILTER_IGNORE
        group.add_child(v)
        val_nodes.append(v)

func _update_chart_geometry() -> void :
    if grid_rings.is_empty():
        return


    var use_light: = GameState.theme == "light" and not force_dark_palette
    var grid_color: = GRID_COLOR_LIGHT if use_light else GRID_COLOR
    var axis_color: = AXIS_COLOR_LIGHT if use_light else AXIS_COLOR
    var label_color: = LABEL_COLOR_LIGHT if use_light else LABEL_COLOR
    var value_color: = VALUE_COLOR_LIGHT if use_light else VALUE_COLOR
    for ring in grid_rings:
        ring.default_color = grid_color
    for axis in axis_lines:
        axis.default_color = axis_color
    for label in labels_nodes:
        label.add_theme_color_override("font_color", label_color)
    for value_label in val_nodes:
        value_label.add_theme_color_override("font_color", value_color)
    for icon in icon_nodes:
        icon.modulate = Color(0.96, 0.84, 0.58, 0.92) if not use_light else Color(0.5, 0.36, 0.14, 0.92)

    var chart_width: float = maxf(0.0, size.x - 96.0)
    var chart_height: float = maxf(0.0, size.y - chart_top_label_reserve - chart_bottom_label_reserve)
    var chart_size: float = min(chart_width, chart_height)
    if chart_size <= 0.0:
        return

    var radius: float = floor(chart_size * 0.5 * chart_scale)
    var center_y: = chart_top_label_reserve + chart_height * 0.5
    var center: Vector2 = Vector2(round(size.x * 0.5), round(center_y))

    for ring_index in range(GRID_RING_COUNT):
        var ring_radius: float = radius * float(ring_index + 1) / float(GRID_RING_COUNT)
        grid_rings[ring_index].points = _build_polygon_points(center, ring_radius)

    for axis_index in range(KEYS.size()):
        var axis_angle: float = _angle_for_index(axis_index)
        axis_lines[axis_index].points = PackedVector2Array([
            center, 
            center + Vector2(cos(axis_angle), sin(axis_angle)) * radius
        ])

    var polygon_points: = PackedVector2Array()
    for point_index in range(KEYS.size()):
        var angle: float = _angle_for_index(point_index)
        var value: = float(animated_stats.get(KEYS[point_index], 0))
        var point_radius: float = radius * clampf(value / max_val, 0.0, 1.0)
        polygon_points.append(center + Vector2(cos(angle), sin(angle)) * point_radius)

    data_fill.polygon = polygon_points
    data_core_fill.polygon = polygon_points
    data_outline.points = polygon_points

    for label_index in range(KEYS.size()):
        var label_angle: float = _angle_for_index(label_index)
        var dir: = Vector2(cos(label_angle), sin(label_angle))

        var label: = labels_nodes[label_index]
        var value_label: = val_nodes[label_index]
        var icon: = icon_nodes[label_index]
        var group: = label_group_nodes[label_index]

        label.text = LABELS[label_index]
        if not animated_value_labels.has(KEYS[label_index]):
            value_label.text = str(int(target_stats.get(KEYS[label_index], animated_stats.get(KEYS[label_index], 0))))

        label.reset_size()
        value_label.reset_size()
        icon.custom_minimum_size = Vector2(label_icon_size, label_icon_size)
        icon.size = Vector2(label_icon_size, label_icon_size)
        group.reset_size()
        var group_size: = group.get_combined_minimum_size()

        var outer_pt = center + dir * radius

        if abs(dir.y) > 0.85:
            _layout_vertical_axis_labels(group, outer_pt, dir, group_size)
            continue

        var pull_x: float = group_size.x * 0.5 + 16.0
        var pull_y: float = group_size.y * 0.5 + 12.0
        var label_pt: Vector2 = (outer_pt + Vector2(dir.x * pull_x, dir.y * pull_y)).round()
        _place_label_group(group, label_pt - group_size * 0.5, group_size)

func _layout_vertical_axis_labels(group: Control, outer_pt: Vector2, dir: Vector2, group_size: Vector2) -> void :
    var group_x: float = outer_pt.x - group_size.x * 0.5

    if dir.y > 0.0:
        var group_y: = minf(outer_pt.y + VERTICAL_AXIS_GAP, size.y - group_size.y)
        group_y = maxf(group_y, outer_pt.y + 2.0)
        _place_label_group(group, Vector2(group_x, group_y), group_size)
    else:
        var group_y: = maxf(0.0, outer_pt.y - VERTICAL_AXIS_GAP - group_size.y)
        _place_label_group(group, Vector2(group_x, group_y), group_size)

func _place_label_group(group: Control, group_pos: Vector2, group_size: Vector2) -> void :
    var clamped_pos: = _clamp_label_position(group_pos, group_size).round()
    group.position = clamped_pos
    group.size = group_size
    for child in group.get_children():
        if child is Control:
            child.size.x = group_size.x

func _build_polygon_points(center: Vector2, radius: float) -> PackedVector2Array:
    var points: = PackedVector2Array()
    for i in range(KEYS.size()):
        var angle: = _angle_for_index(i)
        points.append(center + Vector2(cos(angle), sin(angle)) * radius)
    return points

func _inset_polygon(center: Vector2, points: PackedVector2Array, factor: float) -> PackedVector2Array:
    var inset: = PackedVector2Array()
    for point in points:
        inset.append(center.lerp(point, factor))
    return inset

func _clamp_label_position(position: Vector2, label_size: Vector2) -> Vector2:
    return Vector2(
        clampf(position.x, 0.0, maxf(0.0, size.x - label_size.x)), 
        clampf(position.y, 0.0, maxf(0.0, size.y - label_size.y))
    )

func _angle_for_index(index: int) -> float:
    return index * TAU / KEYS.size() - PI * 0.5

func _snap_point(point: Vector2) -> Vector2:
    return Vector2(round(point.x), round(point.y))

func _expand_polygon_fixed(center: Vector2, points: PackedVector2Array, dist: float) -> PackedVector2Array:
    var expanded: = PackedVector2Array()
    for point in points:
        var dir = (point - center).normalized()
        expanded.append(point + dir * dist)
    return expanded

func _play_pulse_animation(node: Control, is_positive: bool) -> void :
    if node == null or not node.is_inside_tree():
        return

    node.pivot_offset = node.size / 2.0
    var tween: = node.create_tween()
    node.scale = Vector2(1.25, 1.25)

    var original_modulate = node.modulate
    var flash_color = Color(0.95, 0.75, 0.3) if is_positive else Color(0.78, 0.46, 0.42)
    node.modulate = flash_color

    tween.tween_property(node, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.parallel().tween_property(node, "modulate", original_modulate, 0.35)

func _spawn_floating_change_label(target_node: Control, diff: int) -> void :
    if target_node == null or not target_node.is_inside_tree():
        return

    var label: = Label.new()
    label.text = ("+%d" % diff) if diff > 0 else str(diff)

    var font_color: = Color(0.95, 0.75, 0.3) if diff > 0 else Color(0.78, 0.46, 0.42)
    label.add_theme_color_override("font_color", font_color)
    label.add_theme_font_size_override("font_size", 18)

    if target_node.has_theme_font("font"):
        label.add_theme_font_override("font", target_node.get_theme_font("font"))

    label.top_level = true

    var target_pos: = target_node.global_position
    var target_size: = target_node.size
    var start_pos: = target_pos + Vector2(target_size.x * 0.7, -12.0)
    label.position = start_pos

    target_node.add_child(label)

    var tween: = label.create_tween()
    var up_offset: = Vector2(0, -32)
    tween.tween_property(label, "position", start_pos + up_offset, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.parallel().tween_property(label, "modulate:a", 0.0, 0.65).set_delay(0.15)
    tween.tween_callback(label.queue_free)

func _animate_control_value_change(control: Control, diff: int, old_val: int, new_val: int) -> void :
    if control == null:
        return
    _trigger_change_feedback_after_frame(control, diff, old_val, new_val)

func _trigger_change_feedback_after_frame(control: Control, diff: int, old_val: int, new_val: int) -> void :
    if not control.is_inside_tree():
        await control.ready

    if control.is_inside_tree():
        await control.get_tree().process_frame

    if not is_instance_valid(control) or not control.is_inside_tree():
        return

    _spawn_floating_change_label(control, diff)
    _play_pulse_animation(control, diff > 0)
    if control is Label:
        var value_key: = ""
        var idx: = val_nodes.find(control)
        if idx >= 0 and idx < KEYS.size():
            value_key = KEYS[idx]
        if value_key != "":
            animated_value_labels[value_key] = true
        var label: = control as Label
        var tween: Tween = label.create_tween()
        var update_text_func = func(value: float):
            if is_instance_valid(label):
                label.text = str(int(round(value)))
        update_text_func.call(float(old_val))
        tween.tween_method(update_text_func, float(old_val), float(new_val), 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
        tween.tween_callback( func():
            if value_key != "":
                animated_value_labels.erase(value_key)
            if is_instance_valid(label):
                label.text = str(new_val)
        )
