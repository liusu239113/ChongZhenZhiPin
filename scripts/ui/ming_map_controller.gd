extends RefCounted
class_name MingMapController




const EventServiceRef = preload("res://scripts/services/event_service.gd")
const MingMapProvinceShapeRef = preload("res://scripts/ui/ming_map_province_shape.gd")
const MING_MAP_MODES: = [
    {"key": "rendi", "label": "任地"}, 
    {"key": "minsheng", "label": "民生"}, 
    {"key": "junwu", "label": "军务"}
]

var _host
var _province_polygons: Dictionary = {}
var _province_layer_size: Vector2 = Vector2.ZERO
var _hovered_province_id: String = ""
var _selected_province_id: String = ""

func _init(host) -> void :
    _host = host

func style_ming_map_overlay() -> void :
    var panel_style: = StyleBoxFlat.new()
    panel_style.bg_color = Color(0.055, 0.047, 0.038, 0.98) if GameState.theme == "dark" else Color(0.94, 0.9, 0.8, 0.98)
    panel_style.border_width_left = 1
    panel_style.border_width_top = 1
    panel_style.border_width_right = 1
    panel_style.border_width_bottom = 1
    panel_style.border_color = Color(0.72, 0.6, 0.36, 0.5)
    panel_style.corner_radius_top_left = 3
    panel_style.corner_radius_top_right = 3
    panel_style.corner_radius_bottom_left = 3
    panel_style.corner_radius_bottom_right = 3
    panel_style.shadow_size = 18
    panel_style.shadow_color = Color(0, 0, 0, 0.35 if GameState.theme == "dark" else 0.18)
    _host.ming_map_panel.add_theme_stylebox_override("panel", panel_style)

    var frame_style: = StyleBoxFlat.new()
    frame_style.bg_color = Color(0.08, 0.065, 0.05, 0.72) if GameState.theme == "dark" else Color(0.8, 0.73, 0.58, 0.72)
    frame_style.border_width_left = 1
    frame_style.border_width_top = 1
    frame_style.border_width_right = 1
    frame_style.border_width_bottom = 1
    frame_style.border_color = Color(0.33, 0.27, 0.18, 0.52)
    frame_style.corner_radius_top_left = 2
    frame_style.corner_radius_top_right = 2
    frame_style.corner_radius_bottom_left = 2
    frame_style.corner_radius_bottom_right = 2
    frame_style.content_margin_left = 8
    frame_style.content_margin_top = 8
    frame_style.content_margin_right = 8
    frame_style.content_margin_bottom = 8
    _host.ming_map_frame.add_theme_stylebox_override("panel", frame_style)
    _host.ming_map_close_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
    _host.ming_map_close_button.add_theme_stylebox_override("hover", _host._map_button_style(true))
    _host.ming_map_close_button.add_theme_stylebox_override("pressed", _host._map_button_style(true))
    _host.ming_map_close_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    _host.ming_map_reset_zoom_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
    _host.ming_map_reset_zoom_button.add_theme_stylebox_override("hover", _host._map_button_style(true))
    _host.ming_map_reset_zoom_button.add_theme_stylebox_override("pressed", _host._map_button_style(true))
    _host.ming_map_reset_zoom_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    _host.top_location_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
    _host.top_location_button.add_theme_stylebox_override("hover", _host._map_button_style(true))
    _host.top_location_button.add_theme_stylebox_override("pressed", _host._map_button_style(true))
    _host.top_location_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    refresh_ming_map_mode_tabs()
    rebuild_ming_map_provinces()

func on_locate_city_pressed() -> void :
    if not is_instance_valid(_host.ming_map_overlay):
        return
    _host.ming_map_overlay.visible = true
    _host.ming_map_overlay.move_to_front()
    _host.ming_map_mode = "rendi"
    set_selected_ming_map_province(_current_map_province_id())
    reset_ming_map_zoom()
    refresh_ming_map_overlay()

func close_ming_map_overlay() -> void :
    _host.ming_map_overlay.visible = false

func on_ming_map_mode_pressed(mode: String) -> void :
    if not _is_supported_mode(mode):
        return
    _host.ming_map_mode = mode
    refresh_ming_map_mode_tabs()
    refresh_ming_map_overlay()

func _is_supported_mode(mode: String) -> bool:
    for mode_def in MING_MAP_MODES:
        if str(mode_def.get("key", "")) == mode:
            return true
    return false

func on_ming_map_dimmer_gui_input(event: InputEvent) -> void :
    if _host._is_primary_press_event(event):
        _host.ming_map_overlay.set_deferred("visible", false)

func on_ming_map_viewport_gui_input(event: InputEvent) -> void :
    if event is InputEventMouseButton:
        var mouse_event: = event as InputEventMouseButton
        if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP and mouse_event.pressed:
            set_ming_map_zoom(_host.ming_map_zoom * _host.MING_MAP_ZOOM_STEP, mouse_event.position)
            _host.ming_map_viewport.accept_event()
        elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse_event.pressed:
            set_ming_map_zoom(_host.ming_map_zoom / _host.MING_MAP_ZOOM_STEP, mouse_event.position)
            _host.ming_map_viewport.accept_event()
        elif mouse_event.button_index == MOUSE_BUTTON_LEFT:
            _host.ming_map_dragging = mouse_event.pressed and _host.ming_map_zoom > _host.MING_MAP_MIN_ZOOM
            _host.ming_map_drag_last_pos = mouse_event.position
            _host.ming_map_viewport.accept_event()
    elif event is InputEventScreenTouch:
        var touch_event: = event as InputEventScreenTouch
        _host.ming_map_dragging = touch_event.pressed and _host.ming_map_zoom > _host.MING_MAP_MIN_ZOOM
        _host.ming_map_drag_last_pos = touch_event.position
        _host.ming_map_viewport.accept_event()
    elif event is InputEventMagnifyGesture:
        var magnify_event: = event as InputEventMagnifyGesture
        set_ming_map_zoom(_host.ming_map_zoom * magnify_event.factor, magnify_event.position)
        _host.ming_map_viewport.accept_event()
    elif event is InputEventMouseMotion and _host.ming_map_dragging:
        var motion_event: = event as InputEventMouseMotion
        _host.ming_map_zoom_root.position += motion_event.position - _host.ming_map_drag_last_pos
        _host.ming_map_drag_last_pos = motion_event.position
        clamp_ming_map_pan()
        _host.ming_map_viewport.accept_event()
    elif event is InputEventScreenDrag and _host.ming_map_dragging:
        var drag_event: = event as InputEventScreenDrag
        _host.ming_map_zoom_root.position += drag_event.position - _host.ming_map_drag_last_pos
        _host.ming_map_drag_last_pos = drag_event.position
        clamp_ming_map_pan()
        _host.ming_map_viewport.accept_event()

func on_ming_map_province_layer_gui_input(event: InputEvent) -> void :
    if event is InputEventMouseMotion:
        var motion_event: = event as InputEventMouseMotion
        _set_hovered_ming_map_province(_province_at_local_point(motion_event.position))
        if _host.ming_map_dragging:
            on_ming_map_viewport_gui_input(event)
        return
    if event is InputEventMouseButton:
        var mouse_event: = event as InputEventMouseButton
        if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP or mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            on_ming_map_viewport_gui_input(event)
            return
    if event is InputEventScreenDrag or event is InputEventMagnifyGesture:
        on_ming_map_viewport_gui_input(event)
        return
    if not _is_primary_province_press(event):
        on_ming_map_viewport_gui_input(event)
        return
    var province_id: = _province_at_local_point(_event_local_position(event))
    if province_id == "":
        on_ming_map_viewport_gui_input(event)
        return
    set_selected_ming_map_province(province_id)
    _host.ming_map_province_layer.accept_event()

func on_ming_map_province_layer_mouse_exited() -> void :
    _set_hovered_ming_map_province("")

func on_ming_map_viewport_resized() -> void :
    clamp_ming_map_pan()
    rebuild_ming_map_provinces()
    refresh_ming_map_overlay()

func set_ming_map_zoom(target_zoom: float, pivot: Vector2) -> void :
    var old_zoom: float = _host.ming_map_zoom
    var next_zoom: = clampf(target_zoom, _host.MING_MAP_MIN_ZOOM, _host.MING_MAP_MAX_ZOOM)
    if is_equal_approx(old_zoom, next_zoom):
        return
    var content_pivot: Vector2 = (pivot - _host.ming_map_zoom_root.position) / old_zoom
    _host.ming_map_zoom = next_zoom
    _host.ming_map_zoom_root.scale = Vector2.ONE * _host.ming_map_zoom
    apply_ming_map_crisp_text()
    _host.ming_map_zoom_root.position = pivot - content_pivot * _host.ming_map_zoom
    clamp_ming_map_pan()

func reset_ming_map_zoom() -> void :
    _host.ming_map_zoom = _host.MING_MAP_MIN_ZOOM
    _host.ming_map_dragging = false
    _host.ming_map_zoom_root.scale = Vector2.ONE * _host.ming_map_zoom
    apply_ming_map_crisp_text()
    _host.ming_map_zoom_root.position = Vector2.ZERO

func clamp_ming_map_pan() -> void :
    if not is_instance_valid(_host.ming_map_viewport) or not is_instance_valid(_host.ming_map_zoom_root):
        return
    var viewport_size: Vector2 = _host.ming_map_viewport.size
    var content_size: Vector2 = viewport_size * _host.ming_map_zoom
    if content_size.x <= viewport_size.x:
        _host.ming_map_zoom_root.position.x = (viewport_size.x - content_size.x) * 0.5
    else:
        _host.ming_map_zoom_root.position.x = clampf(_host.ming_map_zoom_root.position.x, viewport_size.x - content_size.x, 0.0)
    if content_size.y <= viewport_size.y:
        _host.ming_map_zoom_root.position.y = (viewport_size.y - content_size.y) * 0.5
    else:
        _host.ming_map_zoom_root.position.y = clampf(_host.ming_map_zoom_root.position.y, viewport_size.y - content_size.y, 0.0)

func apply_ming_map_crisp_text() -> void :
    if not is_instance_valid(_host.ming_map_marker_layer):
        return
    for label in collect_ming_map_labels(_host.ming_map_marker_layer):
        remember_ming_map_label_metrics(label)
        var base_font_size: = int(label.get_meta("ming_map_base_font_size", label.get_theme_font_size("font_size")))
        var base_outline_size: = int(label.get_meta("ming_map_base_outline_size", label.get_theme_constant("outline_size")))
        var base_size: = label.get_meta("ming_map_base_size", label.size) as Vector2
        label.add_theme_font_size_override("font_size", maxi(1, roundi(base_font_size * _host.ming_map_zoom)))
        label.add_theme_constant_override("outline_size", maxi(0, roundi(base_outline_size * _host.ming_map_zoom)))
        label.custom_minimum_size = base_size * _host.ming_map_zoom
        label.size = base_size * _host.ming_map_zoom
        label.scale = Vector2.ONE / _host.ming_map_zoom

func collect_ming_map_labels(node: Node) -> Array[Label]:
    var labels: Array[Label] = []
    for child in node.get_children():
        if child is Label:
            labels.append(child)
        labels.append_array(collect_ming_map_labels(child))
    return labels

func remember_ming_map_label_metrics(label: Label) -> void :
    if not label.has_meta("ming_map_base_font_size"):
        label.set_meta("ming_map_base_font_size", label.get_theme_font_size("font_size"))
    if not label.has_meta("ming_map_base_outline_size"):
        label.set_meta("ming_map_base_outline_size", label.get_theme_constant("outline_size"))
    if not label.has_meta("ming_map_base_size"):
        var base_size: = label.size
        if base_size == Vector2.ZERO:
            base_size = label.custom_minimum_size
        label.set_meta("ming_map_base_size", base_size)

func set_ming_map_label_metrics(label: Label, base_font_size: int, base_size: Vector2) -> void :
    label.set_meta("ming_map_base_font_size", base_font_size)
    label.set_meta("ming_map_base_size", base_size)
    label.add_theme_font_size_override("font_size", base_font_size)
    label.custom_minimum_size = base_size
    label.size = base_size
    apply_ming_map_crisp_label(label)

func apply_ming_map_crisp_label(label: Label) -> void :
    remember_ming_map_label_metrics(label)
    var base_font_size: = int(label.get_meta("ming_map_base_font_size", label.get_theme_font_size("font_size")))
    var base_outline_size: = int(label.get_meta("ming_map_base_outline_size", label.get_theme_constant("outline_size")))
    var base_size: = label.get_meta("ming_map_base_size", label.size) as Vector2
    label.add_theme_font_size_override("font_size", maxi(1, roundi(base_font_size * _host.ming_map_zoom)))
    label.add_theme_constant_override("outline_size", maxi(0, roundi(base_outline_size * _host.ming_map_zoom)))
    label.custom_minimum_size = base_size * _host.ming_map_zoom
    label.size = base_size * _host.ming_map_zoom
    label.scale = Vector2.ONE / _host.ming_map_zoom

func current_map_act_key() -> String:
    if GameState.is_governance_mode():
        return str(EventServiceRef._get_current_act(GameState))
    return "1"

func current_map_label() -> String:
    GameState._normalize_legacy_city_identity()
    var act_key: = current_map_act_key()
    var city_cfg: Dictionary = GameData.CITY_BY_ACT.get(act_key, {})
    var prov = GameState.city.get("province", city_cfg.get("province", "山东"))
    var cname = GameState.get_current_city_name() if not GameState.city.is_empty() else city_cfg.get("name", "蓬莱县")
    return "%s · %s" % [prov, cname]

func refresh_ming_map_overlay() -> void :
    if not _host.is_inside_tree() or not is_instance_valid(_host.ming_map_marker_layer):
        return

    GameState._normalize_legacy_city_identity()
    var current_act: = current_map_act_key()
    if _selected_province_id == "":
        _selected_province_id = _current_map_province_id()
    rebuild_ming_map_provinces()
    refresh_ming_map_mode_tabs()

    for child in _host.ming_map_marker_layer.get_children():
        var map_act = str(child.get_meta("map_act", ""))
        if map_act == "":
            child.visible = false
            continue

        child.visible = true
        var is_current = (map_act == current_act)

        child.z_index = 4 if is_current else 2

        var dot = child.get_node_or_null("Dot")
        var current_dot = child.get_node_or_null("CurrentDot")
        var city_label = child.get_node_or_null("CityLabel")

        if dot:
            dot.visible = not is_current

        if current_dot:
            if is_current and _host.ming_map_current_marker_texture != null:
                current_dot.texture = _host.ming_map_current_marker_texture
            if dot:
                align_current_map_dot(current_dot, dot)
            current_dot.visible = is_current

        if city_label:
            var label_text = str(child.get_meta("map_label", ""))
            var marker_city_cfg: Dictionary = GameData.CITY_BY_ACT.get(map_act, {})
            label_text = marker_city_cfg.get("name", label_text)
            if is_current:
                var city_cfg: Dictionary = GameData.CITY_BY_ACT.get(current_act, {})
                label_text = GameState.get_current_city_name() if not GameState.city.is_empty() else city_cfg.get("name", label_text)

            city_label.text = label_text
            var label_width = 116.0 if is_current else 76.0
            var label_font_size: = 16 if is_current else 12
            city_label.set_meta("ming_map_base_outline_size", 5 if is_current else 4)
            set_ming_map_label_metrics(city_label, label_font_size, Vector2(label_width, 24.0))
            city_label.add_theme_color_override("font_color", Color(0.47, 0.13, 0.08, 1.0) if is_current else Color(0.16, 0.13, 0.1, 0.62))
    apply_ming_map_crisp_text()
    refresh_ming_map_province_styles()
    refresh_ming_map_detail()

func align_current_map_dot(current_dot: TextureRect, dot: Control) -> void :
    var dot_size: = dot.size
    if dot_size == Vector2.ZERO:
        dot_size = dot.custom_minimum_size
    var current_dot_size: = current_dot.size
    if current_dot_size == Vector2.ZERO:
        current_dot_size = current_dot.custom_minimum_size
    current_dot.position = dot.position + dot_size * 0.5 - current_dot_size * 0.5

func refresh_ming_map_mode_tabs() -> void :
    if not is_instance_valid(_host.ming_map_mode_tabs):
        return
    var mode_buttons: = {
        "rendi": _host.ming_map_mode_rendi_button, 
        "minsheng": _host.ming_map_mode_minsheng_button, 
        "junwu": _host.ming_map_mode_junwu_button
    }
    for key in mode_buttons:
        var btn: Button = mode_buttons[key]
        if not is_instance_valid(btn):
            continue
        var active: bool = key == _host.ming_map_mode
        btn.add_theme_color_override("font_color", Color(0.94, 0.78, 0.42, 1.0) if active else Color(0.76, 0.72, 0.66, 0.72))
        btn.add_theme_color_override("font_hover_color", Color(0.96, 0.84, 0.58, 1.0))
        btn.add_theme_stylebox_override("normal", _host._map_button_style(active))
        btn.add_theme_stylebox_override("hover", _host._map_button_style(true))
        btn.add_theme_stylebox_override("pressed", _host._map_button_style(true))
        btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func refresh_ming_map_detail() -> void :
    if not is_instance_valid(_host.ming_map_detail_label):
        return
    var act_key: = current_map_act_key()
    var city_cfg: Dictionary = GameData.CITY_BY_ACT.get(act_key, {})
    var city_data: Dictionary = GameState.city if not GameState.city.is_empty() else city_cfg.get("defaults", {})
    var city_name: = current_map_label()
    var selected_province: = _selected_province_label()
    var detail: = ""
    match _host.ming_map_mode:
        "minsheng":
            detail = _build_minsheng_detail(city_name, city_data, selected_province)
        "junwu":
            detail = _build_junwu_detail(city_name, city_data, selected_province)
        _:
            detail = _build_rendi_detail(city_name, city_cfg, city_data, selected_province)
    _host.ming_map_detail_label.text = detail

func _build_rendi_detail(city_name: String, city_cfg: Dictionary, city_data: Dictionary, selected_province: String) -> String:
    var map_cfg: Dictionary = city_cfg.get("map", {})
    var region: = str(map_cfg.get("region", city_cfg.get("province", "")))
    var order: = int(map_cfg.get("route_order", int(current_map_act_key())))
    var juris: = str(city_cfg.get("juris", city_data.get("juris", "")))
    var parts: = [
        "[b]任地[/b]  %s" % city_name, 
        "区域 %s　选中 %s　辖属 %s　履历第%d站" % [region if region != "" else "未详", selected_province, juris if juris != "" else "未详", order], 
        "舆图仅作方位与仕途轨迹展示，不推进月份，也不改动城池数值。"
    ]
    return "\n".join(parts)

func _build_minsheng_detail(city_name: String, city_data: Dictionary, selected_province: String) -> String:
    return "\n".join([
        "[b]民生[/b]  %s　选中 %s" % [city_name, selected_province], 
        "人口 %s　流民 %s　官粮 %s" % [_format_map_number(city_data.get("renkou_val", 0)), _format_map_number(city_data.get("liumin", 0)), _format_map_number(city_data.get("liangshi", 0))], 
        "农桑 %s　文教 %s" % [str(city_data.get("nongsang", 0)), str(city_data.get("wenjiao", 0))]
    ])

func _build_junwu_detail(city_name: String, city_data: Dictionary, selected_province: String) -> String:
    var pressure: = int(city_data.get("liangshi_monthly_pressure", 0))
    var pressure_text: = "无" if pressure == 0 else str(pressure)
    return "\n".join([
        "[b]军务[/b]  %s　选中 %s" % [city_name, selected_province], 
        "兵勇 %s　城防 %s　库银 %s" % [_format_map_number(city_data.get("bingyong", 0)), str(city_data.get("chengfang", 0)), _format_map_number(city_data.get("yinliang", 0))], 
        "转运压力 %s" % pressure_text
    ])

func _format_map_number(value) -> String:
    var amount: = int(value)
    if abs(amount) >= 10000:
        var wan: = float(amount) / 10000.0
        return "%.1f万" % wan
    return str(amount)

func rebuild_ming_map_provinces() -> void :
    if not is_instance_valid(_host.ming_map_province_layer):
        return
    var layer_size: = _get_province_layer_size()
    if layer_size == Vector2.ZERO:
        return
    if _province_polygons.size() == GameData.MING_MAP_PROVINCES.size() and _province_layer_size == layer_size:
        refresh_ming_map_province_styles()
        return
    _province_layer_size = layer_size
    _province_polygons.clear()
    for child in _host.ming_map_province_layer.get_children():
        child.queue_free()
    for province_id in GameData.MING_MAP_PROVINCES.keys():
        var province: Dictionary = GameData.MING_MAP_PROVINCES.get(province_id, {})
        var shape: = MingMapProvinceShapeRef.new()
        shape.name = "Province_%s" % str(province_id)
        shape.province_id = str(province_id)
        shape.set_anchors_preset(Control.PRESET_FULL_RECT)
        shape.size = layer_size
        shape.mouse_filter = Control.MOUSE_FILTER_IGNORE
        shape.points = _normalized_points_to_local(province.get("points", []), layer_size)
        _host.ming_map_province_layer.add_child(shape)
        _province_polygons[shape.province_id] = shape
    refresh_ming_map_province_styles()

func _get_province_layer_size() -> Vector2:
    var layer_size: Vector2 = _host.ming_map_province_layer.size
    if layer_size == Vector2.ZERO:
        layer_size = _host.ming_map_province_layer.get_parent().size
    return layer_size

func _normalized_points_to_local(raw_points: Array, layer_size: Vector2) -> PackedVector2Array:
    var result: = PackedVector2Array()
    for raw_point in raw_points:
        if raw_point is Array and raw_point.size() >= 2:
            result.append(Vector2(float(raw_point[0]) * layer_size.x, float(raw_point[1]) * layer_size.y))
    return result

func _is_primary_province_press(event: InputEvent) -> bool:
    if event is InputEventMouseButton:
        var mouse_event: = event as InputEventMouseButton
        return mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT
    if event is InputEventScreenTouch:
        var touch_event: = event as InputEventScreenTouch
        return touch_event.pressed
    return false

func _event_local_position(event: InputEvent) -> Vector2:
    if event is InputEventMouseButton:
        return (event as InputEventMouseButton).position
    if event is InputEventScreenTouch:
        return (event as InputEventScreenTouch).position
    if event is InputEventMouseMotion:
        return (event as InputEventMouseMotion).position
    if event is InputEventScreenDrag:
        return (event as InputEventScreenDrag).position
    return _host.ming_map_province_layer.get_local_mouse_position()

func _province_at_local_point(point: Vector2) -> String:
    var province_ids: = GameData.MING_MAP_PROVINCES.keys()
    for index in range(province_ids.size() - 1, -1, -1):
        var province_id: = str(province_ids[index])
        var shape: Control = _province_polygons.get(province_id)
        if shape != null and is_instance_valid(shape) and shape.has_method("contains_local_point"):
            if shape.contains_local_point(point):
                return province_id
    return ""

func set_selected_ming_map_province(province_id: String) -> void :
    if province_id != "" and not GameData.MING_MAP_PROVINCES.has(province_id):
        return
    _selected_province_id = province_id
    refresh_ming_map_province_styles()
    refresh_ming_map_detail()

func _set_hovered_ming_map_province(province_id: String) -> void :
    _hovered_province_id = province_id
    refresh_ming_map_province_styles()

func refresh_ming_map_province_styles() -> void :
    for province_id in _province_polygons:
        var shape: Control = _province_polygons[province_id]
        if not is_instance_valid(shape):
            continue
        var is_current: bool = province_id == _current_map_province_id()
        var is_selected: bool = province_id == _selected_province_id
        var is_hovered: bool = province_id == _hovered_province_id
        shape.fill_color = _province_fill_color(is_current, is_selected, is_hovered)
        shape.stroke_color = _province_stroke_color(is_current, is_selected, is_hovered)
        shape.stroke_width = _province_stroke_width(is_current, is_selected, is_hovered)
        shape.queue_redraw()

func _province_fill_color(is_current: bool, is_selected: bool, is_hovered: bool) -> Color:
    if is_current:
        return Color(0.95, 0.66, 0.22, 0.42)
    if is_selected:
        return Color(0.82, 0.58, 0.28, 0.34)
    if is_hovered:
        return Color(0.7, 0.5, 0.24, 0.28)
    return Color(0.55, 0.45, 0.25, 0.12)

func _province_stroke_color(is_current: bool, is_selected: bool, is_hovered: bool) -> Color:
    if is_current or is_selected:
        return Color(0.72, 0.24, 0.1, 0.86)
    if is_hovered:
        return Color(0.56, 0.35, 0.15, 0.72)
    return Color(0.36, 0.28, 0.16, 0.38)

func _province_stroke_width(is_current: bool, is_selected: bool, is_hovered: bool) -> float:
    if is_current or is_selected:
        return 2.6
    if is_hovered:
        return 2.1
    return 1.35

func _current_map_province_id() -> String:
    var city_cfg: Dictionary = GameData.CITY_BY_ACT.get(current_map_act_key(), {})
    var map_cfg: Dictionary = city_cfg.get("map", {})
    return str(map_cfg.get("province_id", ""))

func _selected_province_label() -> String:
    var province_id: = _selected_province_id
    if province_id == "":
        province_id = _current_map_province_id()
    var province: Dictionary = GameData.MING_MAP_PROVINCES.get(province_id, {})
    return str(province.get("label", "未选"))
