extends Control
class_name BianwuHexMap

signal region_selected(region_id: String)

const CITY_ICON: = preload("res://assets/ui/map_city_icon.png")
const FORT_ICON: = preload("res://assets/ui/map_fort_icon.png")
const STRONGHOLD_ICON_SIZE: = 46.0
const STABLE_BORDER_COLOR: = Color(0.24, 0.62, 0.38, 0.96)
const WATCH_BORDER_COLOR: = Color(0.7, 0.53, 0.23, 0.94)
const UNSTABLE_BORDER_COLOR: = Color(0.7, 0.31, 0.2, 0.96)
const REBELLION_BORDER_COLOR: = Color(0.86, 0.18, 0.14, 1.0)
const HEX_RADIUS: = 42.0
const SQRT_THREE: = 1.7320508
const NEIGHBORS: = [
    Vector2i(1, 0), 
    Vector2i(0, 1), 
    Vector2i(-1, 1), 
    Vector2i(-1, 0), 
    Vector2i(0, -1), 
    Vector2i(1, -1), 
]
const REGION_CELL_LAYOUTS: = [
    [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(1, -1)], 
    [Vector2i(-2, 1), Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(-3, 2), Vector2i(-3, 3)], 
    [Vector2i(-1, -1), Vector2i(0, -2), Vector2i(1, -2), Vector2i(0, -3), Vector2i(-1, -2)], 
    [Vector2i(2, 0), Vector2i(2, 1), Vector2i(3, 0), Vector2i(3, 1), Vector2i(2, 2)], 
    [Vector2i(-1, 3), Vector2i(0, 2), Vector2i(0, 3), Vector2i(1, 2), Vector2i(1, 3)], 
    [Vector2i(2, -1), Vector2i(2, -2), Vector2i(3, -2), Vector2i(3, -1), Vector2i(4, -2)], 
    [Vector2i(2, 3), Vector2i(3, 2), Vector2i(3, 3), Vector2i(4, 2), Vector2i(4, 3)], 
]
const ACT_ONE_REGION_CELL_LAYOUTS: = {
    "bw1_baoding_city": [Vector2i(-6, -1), Vector2i(-5, -1), Vector2i(-4, -1), Vector2i(-6, 0), Vector2i(-5, 0), Vector2i(-4, 0), Vector2i(-6, 1), Vector2i(-5, 1), Vector2i(-4, 1), Vector2i(-5, 2), Vector2i(-4, 2)], 
    "bw1_baihusuo": [Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-3, 1), Vector2i(-2, 1)], 
    "bw1_dunbao": [Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(-2, -1), Vector2i(-1, -1)], 
    "bw1_juntun": [Vector2i(-1, 1), Vector2i(0, 1), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2)], 
    "bw1_liangzhan": [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)], 
}

var regions: Array = []
var enemies: Array = []
var units: Array = []
var selected_region_id: = ""
var _cells: Array = []

func _ready() -> void :
    mouse_filter = Control.MOUSE_FILTER_STOP
    resized.connect(_rebuild_cells)
    queue_redraw()

func setup(region_data: Array, enemy_data: Array, unit_data: Array, selected_id: String = "") -> void :
    regions = region_data.duplicate(true)
    enemies = enemy_data.duplicate(true)
    units = unit_data.duplicate(true)
    selected_region_id = selected_id
    _rebuild_cells()

func select_region(region_id: String) -> void :
    selected_region_id = region_id
    queue_redraw()

func _rebuild_cells() -> void :
    _cells.clear()
    var draw_size: = size
    if draw_size.x < 200.0 or draw_size.y < 160.0:
        draw_size = custom_minimum_size
    var raw_cells: Array = []
    for region_index in range(regions.size()):
        var region: Dictionary = regions[region_index]
        var layout: Array = _layout_for_region(region, region_index)
        for global_coord in layout:
            raw_cells.append({
                "region_id": str(region.get("id", "")), 
                "region_index": region_index, 
                "coord": global_coord, 
                "raw_center": _axial_to_pixel(global_coord), 
            })
    var bounds: = Rect2()
    for idx in range(raw_cells.size()):
        var point: Vector2 = raw_cells[idx].raw_center
        bounds = Rect2(point, Vector2.ZERO) if idx == 0 else bounds.expand(point)
    var map_center: = bounds.position + bounds.size * 0.5
    var target_center: = Vector2(draw_size.x * 0.5, draw_size.y * 0.53)
    for raw_cell in raw_cells:
        var cell: Dictionary = raw_cell.duplicate()
        cell["center"] = Vector2(raw_cell.raw_center) - map_center + target_center
        cell.erase("raw_center")
        _cells.append(cell)
    queue_redraw()

func _layout_for_region(region: Dictionary, region_index: int) -> Array:
    var region_id: = str(region.get("id", ""))
    if ACT_ONE_REGION_CELL_LAYOUTS.has(region_id):
        return ACT_ONE_REGION_CELL_LAYOUTS.get(region_id, [])
    return REGION_CELL_LAYOUTS[region_index % REGION_CELL_LAYOUTS.size()]

func _axial_to_pixel(coord: Vector2i) -> Vector2:
    return Vector2(HEX_RADIUS * SQRT_THREE * (float(coord.x) + float(coord.y) * 0.5), HEX_RADIUS * 1.5 * float(coord.y))

func _hex_points(center: Vector2, radius: float = HEX_RADIUS) -> PackedVector2Array:
    var points: = PackedVector2Array()
    for side in range(6):
        var angle: = deg_to_rad(60.0 * float(side) - 30.0)
        points.append(center + Vector2(cos(angle), sin(angle)) * radius)
    return points

func _region_by_id(region_id: String) -> Dictionary:
    for region in regions:
        if str(region.get("id", "")) == region_id:
            return region
    return {}

func _enemy_count(region_id: String) -> int:
    var count: = 0
    for enemy in enemies:
        if str(enemy.get("region_id", "")) == region_id:
            count += 1
    return count

func _unit_count(region_id: String) -> int:
    var count: = 0
    for unit in units:
        if unit is Dictionary and str(unit.get("region_id", "")) == region_id:
            count += 1
    return count

func _terrain_color(region: Dictionary, cell_index: int) -> Color:
    var region_type: = str(region.get("type", ""))
    var base: = Color(0.17, 0.15, 0.1, 1.0)
    if region_type.contains("屯") or region_type.contains("乡") or region_type.contains("聚落"):
        base = Color(0.2, 0.22, 0.12, 1.0)
    elif region_type.contains("山") or region_type.contains("关") or region_type.contains("边墙"):
        base = Color(0.22, 0.18, 0.13, 1.0)
    elif region_type.contains("驿") or region_type.contains("渡"):
        base = Color(0.15, 0.19, 0.17, 1.0)
    elif region_type.contains("城") or region_type.contains("营") or region_type.contains("卫"):
        base = Color(0.2, 0.16, 0.11, 1.0)
    var variation: = float((cell_index * 17 + 11) % 7) * 0.008
    var color: = base.lightened(variation)
    if not selected_region_id.is_empty() and str(region.get("id", "")) != selected_region_id:
        return color.darkened(0.42)
    if str(region.get("id", "")) == selected_region_id:
        return color.lightened(0.06)
    return color

func _focus_color(color: Color, region_id: String) -> Color:
    if selected_region_id.is_empty() or region_id == selected_region_id:
        return color
    return color.darkened(0.42)

func _stability_border(stability: int) -> Color:
    if stability >= 60:
        return STABLE_BORDER_COLOR
    if stability >= 40:
        return WATCH_BORDER_COLOR
    return UNSTABLE_BORDER_COLOR

func _draw() -> void :
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.035, 0.032, 0.025, 1.0))
    _draw_map_atmosphere()
    for cell_index in range(_cells.size()):
        var cell: Dictionary = _cells[cell_index]
        var region: = _region_by_id(str(cell.region_id))
        var points: = _hex_points(cell.center)
        draw_colored_polygon(points, _terrain_color(region, cell_index))
        draw_polyline(_closed(points), Color(0.46, 0.39, 0.25, 0.25), 1.0, true)
    _draw_region_boundaries()
    _draw_region_labels_and_markers()

func _draw_map_atmosphere() -> void :
    for idx in range(7):
        var center: = Vector2(size.x * (0.18 + float(idx % 3) * 0.31), size.y * (0.2 + float(idx / 3) * 0.3))
        draw_arc(center, 58.0 + float(idx % 2) * 24.0, 0.25, 4.65, 30, Color(0.55, 0.44, 0.25, 0.07), 1.0, true)
    for idx in range(38):
        var x: = fmod(float(idx * 97 + 31), maxf(size.x - 30.0, 1.0)) + 15.0
        var y: = fmod(float(idx * 53 + 17), maxf(size.y - 30.0, 1.0)) + 15.0
        draw_circle(Vector2(x, y), 1.1, Color(0.7, 0.58, 0.34, 0.09))

func _draw_region_boundaries() -> void :
    for region in regions:
        var region_id: = str(region.get("id", ""))
        var region_cells: = _region_cells(region_id)
        if region_cells.is_empty():
            continue
        var stability: = int(region.get("stability", 60))
        var border: = _stability_border(stability)
        border = _focus_color(border, region_id)
        _draw_cell_group_outline(region_cells, border, 1.4, 2.3)


    for region in regions:
        var region_id: = str(region.get("id", ""))
        var enemy: = _enemy_in_region(region_id)
        var holder: = str(region.get("stronghold_holder", "player"))
        if enemy.is_empty() and holder != "rebel":
            continue
        var rebellion_cells: = _region_cells(region_id)
        if rebellion_cells.is_empty():
            continue
        var fallen: = bool(region.get("fallen", false))
        var total: = rebellion_cells.size()
        var red_count: = 0
        if fallen:
            red_count = total
        elif not enemy.is_empty():
            red_count = clampi(int(enemy.get("size", 20)) / 10, 1, maxi(1, total - 1))
        elif holder == "rebel":
            red_count = 1
        if red_count <= 0:
            continue
        var chosen: Array = []
        if holder == "rebel" or fallen:

            chosen = rebellion_cells.slice(maxi(0, total - red_count))
        else:

            var fort_cell: = _get_fort_cell(region_id, rebellion_cells)
            for cell in rebellion_cells:
                if chosen.size() >= red_count:
                    break
                if not fort_cell.is_empty() and Vector2i(cell.coord) == Vector2i(fort_cell.coord):
                    continue
                chosen.append(cell)
        var fill_color: = Color(0.42, 0.055, 0.04, 0.45 if fallen else 0.33)
        for cell in chosen:
            var points: = _hex_points(cell.center)
            draw_colored_polygon(points, _focus_color(fill_color, region_id))
        var rebellion_color: = _focus_color(REBELLION_BORDER_COLOR, region_id)
        _draw_cell_group_outline(chosen, rebellion_color, 4.2, 3.0)

        if not enemy.is_empty() and not chosen.is_empty():
            var badge_cell: Dictionary = chosen[0]
            draw_string(ThemeDB.fallback_font, Vector2(badge_cell.center) + Vector2(-11, -14), "约%d" % int(enemy.get("size", 0)), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, _focus_color(Color(0.96, 0.52, 0.42, 0.95), region_id))

func _draw_cell_group_outline(cells: Array, color: Color, inset: float, width: float) -> void :
    var coords: = {}
    var joints: = {}
    for cell in cells:
        coords[Vector2i(cell.coord)] = true
    for cell in cells:
        var coord: = Vector2i(cell.coord)
        var points: = _hex_points(cell.center)
        for side in range(6):
            var neighbor_coord: Vector2i = coord + NEIGHBORS[side]
            if not coords.has(neighbor_coord):
                var original_start: = points[side]
                var original_finish: = points[(side + 1) % 6]
                var start: = original_start
                var finish: = original_finish
                var midpoint: = (start + finish) * 0.5
                var inward: = (Vector2(cell.center) - midpoint).normalized() * inset
                start += inward
                finish += inward
                _draw_butt_line(start, finish, color, width)
                _add_outline_joint(joints, original_start, start)
                _add_outline_joint(joints, original_finish, finish)
    _draw_outline_joints(joints, color, width)

func _add_outline_joint(joints: Dictionary, original: Vector2, shifted: Vector2) -> void :
    var key: = "%d:%d" % [roundi(original.x * 10.0), roundi(original.y * 10.0)]
    if not joints.has(key):
        joints[key] = []
    joints[key].append(shifted)

func _draw_outline_joints(joints: Dictionary, color: Color, width: float) -> void :
    for endpoints_value in joints.values():
        var endpoints: Array = endpoints_value
        if endpoints.size() < 2:
            continue
        if endpoints.size() == 2:
            _draw_butt_line(Vector2(endpoints[0]), Vector2(endpoints[1]), color, width)
            continue
        var center: = Vector2.ZERO
        for endpoint in endpoints:
            center += Vector2(endpoint)
        center /= float(endpoints.size())
        for endpoint in endpoints:
            _draw_butt_line(Vector2(endpoint), center, color, width)

func _draw_butt_line(start: Vector2, finish: Vector2, color: Color, width: float) -> void :
    var direction: = finish - start
    if direction.length_squared() <= 0.0001:
        return
    var length: = direction.length()
    var tangent: = direction / length
    var normal: = Vector2( - tangent.y, tangent.x) * width * 0.5
    var taper: = minf(width * 0.7, length * 0.25)
    var start_inner: = start + tangent * taper
    var finish_inner: = finish - tangent * taper
    var strip: = PackedVector2Array([
        start, 
        start_inner + normal, 
        finish_inner + normal, 
        finish, 
        finish_inner - normal, 
        start_inner - normal, 
    ])
    draw_colored_polygon(strip, color)

func _region_cells(region_id: String) -> Array:
    var found: Array = []
    for cell in _cells:
        if str(cell.region_id) == region_id:
            found.append(cell)
    return found

func _get_fort_cell(region_id: String, cells: Array) -> Dictionary:
    if cells.is_empty():
        return {}
    if region_id == "bw1_baoding_city":
        for cell in cells:
            if Vector2i(cell.coord) == Vector2i(-5, 0):
                return cell
    return cells[-1]

func _draw_region_labels_and_markers() -> void :
    var font: = ThemeDB.fallback_font
    for region in regions:
        var region_id: = str(region.get("id", ""))
        var cells: = _region_cells(region_id)
        if cells.is_empty():
            continue
        var center: = Vector2.ZERO
        for cell in cells:
            center += Vector2(cell.center)
        center /= float(cells.size())

        if _region_is_fortified(region):
            var icon: Texture2D = CITY_ICON if str(region.get("type", "")).contains("城") else FORT_ICON
            var icon_cell: = _get_fort_cell(region_id, cells)
            var icon_center: = Vector2(icon_cell.center)
            var icon_alpha: = 0.95 if selected_region_id.is_empty() or region_id == selected_region_id else 0.45
            draw_texture_rect(icon, Rect2(icon_center - Vector2(STRONGHOLD_ICON_SIZE, STRONGHOLD_ICON_SIZE) * 0.5, Vector2(STRONGHOLD_ICON_SIZE, STRONGHOLD_ICON_SIZE)), false, Color(1, 1, 1, icon_alpha))
        var label: = str(region.get("name", ""))
        var label_size: = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 15)
        draw_string(font, center + Vector2( - label_size.x * 0.5, 5), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.9, 0.81, 0.61, 0.95))
        if _unit_count(region_id) > 0:

            if str(region.get("stronghold_holder", "player")) == "rebel":
                _draw_camp_marker(center + Vector2(-30, 29), _unit_count(region_id))
            else:
                _draw_unit_marker(center + Vector2(-30, 29), _unit_count(region_id))

func _draw_unit_marker(position: Vector2, count: int) -> void :
    draw_circle(position, 11.0, Color(0.12, 0.27, 0.2, 0.96))
    draw_arc(position, 11.0, 0.0, TAU, 20, STABLE_BORDER_COLOR, 2.0, true)
    draw_line(position + Vector2(-4, 3), position + Vector2(0, -5), Color(0.82, 0.78, 0.62), 2.0, true)
    draw_line(position + Vector2(0, -5), position + Vector2(5, 4), Color(0.82, 0.78, 0.62), 2.0, true)
    if count > 1:
        draw_string(ThemeDB.fallback_font, position + Vector2(9, 13), str(count), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)


func _region_is_fortified(region: Dictionary) -> bool:
    if region.has("fortified"):
        return bool(region.get("fortified"))
    var region_type: = str(region.get("type", ""))
    for keyword in ["城", "堡", "所", "卫", "关", "墙", "镇"]:
        if region_type.contains(keyword):
            return true
    return false

func _enemy_in_region(region_id: String) -> Dictionary:
    for enemy in enemies:
        if enemy is Dictionary and str(enemy.get("region_id", "")) == region_id:
            return enemy
    return {}


func _draw_camp_marker(position: Vector2, count: int) -> void :
    var tent: = PackedVector2Array([position + Vector2(-11, 9), position + Vector2(0, -10), position + Vector2(11, 9)])
    draw_colored_polygon(tent, Color(0.12, 0.24, 0.19, 0.96))
    draw_polyline(_closed(tent), STABLE_BORDER_COLOR, 2.0, true)
    draw_line(position + Vector2(0, -10), position + Vector2(0, 9), Color(0.82, 0.78, 0.62, 0.85), 1.5, true)
    if count > 1:
        draw_string(ThemeDB.fallback_font, position + Vector2(11, 14), str(count), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)

func _closed(points: PackedVector2Array) -> PackedVector2Array:
    var closed: = points.duplicate()
    if not points.is_empty():
        closed.append(points[0])
    return closed

func _gui_input(event: InputEvent) -> void :
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        _select_at(event.position)
    elif event is InputEventScreenTouch and event.pressed:
        _select_at(event.position)

func select_at_position(position: Vector2) -> bool:
    return _select_at(position)

func _select_at(position: Vector2) -> bool:
    var nearest: Dictionary = {}
    var nearest_distance: = INF
    for cell in _cells:
        var distance: = position.distance_to(Vector2(cell.center))
        if distance <= HEX_RADIUS and distance < nearest_distance:
            nearest = cell
            nearest_distance = distance
    if nearest.is_empty():
        return false
    selected_region_id = str(nearest.region_id)
    queue_redraw()
    region_selected.emit(selected_region_id)
    return true
