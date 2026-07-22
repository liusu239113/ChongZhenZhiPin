extends SceneTree

const BianwuHexMapRef = preload("res://scripts/ui/bianwu_hex_map.gd")

const ACT_ONE_EXPECTED_COUNTS: = {
    "bw1_baoding_city": 11, 
    "bw1_baihusuo": 4, 
    "bw1_dunbao": 4, 
    "bw1_juntun": 5, 
    "bw1_liangzhan": 4, 
}

var _failures: Array[String] = []

func _initialize() -> void :
    var hex_map = BianwuHexMapRef.new()
    var all_coords: = {}
    var region_coords: = {}
    var pixel_points: Array[Vector2] = []

    for region_id in ACT_ONE_EXPECTED_COUNTS:
        var region: = {"id": region_id}
        var layout: Array = hex_map._layout_for_region(region, 0)
        _expect( not layout.is_empty(), "%s should have a non-empty act-one layout" % region_id)
        _expect(layout == BianwuHexMapRef.ACT_ONE_REGION_CELL_LAYOUTS[region_id], "%s should resolve its dedicated act-one layout" % region_id)
        _expect(layout.size() == ACT_ONE_EXPECTED_COUNTS[region_id], "%s should contain %d cells, got %d" % [region_id, ACT_ONE_EXPECTED_COUNTS[region_id], layout.size()])
        _expect(_is_connected(layout), "%s cells should form one connected axial group" % region_id)
        region_coords[region_id] = layout
        for coord_value in layout:
            var coord: = Vector2i(coord_value)
            _expect( not all_coords.has(coord), "%s reuses global coordinate %s" % [region_id, coord])
            all_coords[coord] = region_id
            pixel_points.append(hex_map._axial_to_pixel(coord))

    _expect(_is_all_connected(all_coords), "all act-one regions should form one contiguous hex map")
    _expect(_regions_touch(region_coords, "bw1_baoding_city", "bw1_baihusuo"), "Baoding city should share an edge with the hundred-household post")
    _expect(_regions_touch(region_coords, "bw1_baihusuo", "bw1_dunbao"), "the hundred-household post should share an edge with the northern outpost")
    _expect(_regions_touch(region_coords, "bw1_baihusuo", "bw1_juntun"), "the hundred-household post should share an edge with the suburban military colony")
    _expect(_regions_touch(region_coords, "bw1_juntun", "bw1_liangzhan"), "the military colony should share an edge with the relay grain station")
    _expect(ACT_ONE_EXPECTED_COUNTS["bw1_baoding_city"] > ACT_ONE_EXPECTED_COUNTS["bw1_baihusuo"], "Baoding city should be larger than the hundred-household post")
    _expect(_bounds_ratio(pixel_points) >= 2.0, "act-one layout should be at least twice as wide as tall")
    _expect(
        hex_map._layout_for_region({"id": "bw2_ningyuan"}, 0) == BianwuHexMapRef.REGION_CELL_LAYOUTS[0], 
        "a later-volume region should fall back to generic layout zero", 
    )
    _expect(
        hex_map._layout_for_region({"id": "unknown_region"}, 3) == BianwuHexMapRef.REGION_CELL_LAYOUTS[3], 
        "an unknown region should fall back to its indexed generic layout", 
    )

    hex_map.free()
    if not _failures.is_empty():
        for failure in _failures:
            push_error("test_bianwu_hex_map_layout: " + failure)
        quit(1)
        return
    print("test_bianwu_hex_map_layout: ok")
    quit(0)

func _is_connected(layout: Array) -> bool:
    if layout.is_empty():
        return false
    var remaining: = {}
    for coord_value in layout:
        remaining[Vector2i(coord_value)] = true
    var queue: Array[Vector2i] = [Vector2i(layout[0])]
    remaining.erase(queue[0])
    while not queue.is_empty():
        var current: Vector2i = queue.pop_front()
        for neighbor_offset in BianwuHexMapRef.NEIGHBORS:
            var neighbor: Vector2i = current + Vector2i(neighbor_offset)
            if remaining.erase(neighbor):
                queue.append(neighbor)
    return remaining.is_empty()

func _is_all_connected(all_coords: Dictionary) -> bool:
    if all_coords.is_empty():
        return false
    var remaining: = all_coords.duplicate()
    var queue: Array[Vector2i] = [Vector2i(remaining.keys()[0])]
    remaining.erase(queue[0])
    while not queue.is_empty():
        var current: Vector2i = queue.pop_front()
        for neighbor_offset in BianwuHexMapRef.NEIGHBORS:
            var neighbor: Vector2i = current + Vector2i(neighbor_offset)
            if remaining.erase(neighbor):
                queue.append(neighbor)
    return remaining.is_empty()

func _regions_touch(region_coords: Dictionary, first_region_id: String, second_region_id: String) -> bool:
    var second_coords: = {}
    for coord_value in region_coords.get(second_region_id, []):
        second_coords[Vector2i(coord_value)] = true
    for coord_value in region_coords.get(first_region_id, []):
        var coord: = Vector2i(coord_value)
        for neighbor_offset in BianwuHexMapRef.NEIGHBORS:
            if second_coords.has(coord + Vector2i(neighbor_offset)):
                return true
    return false

func _bounds_ratio(points: Array[Vector2]) -> float:
    if points.is_empty():
        return 0.0
    var min_point: = points[0]
    var max_point: = points[0]
    for point in points:
        min_point.x = minf(min_point.x, point.x)
        min_point.y = minf(min_point.y, point.y)
        max_point.x = maxf(max_point.x, point.x)
        max_point.y = maxf(max_point.y, point.y)
    var height: = max_point.y - min_point.y
    if height <= 0.0:
        return 0.0
    return (max_point.x - min_point.x) / height

func _expect(condition: bool, message: String) -> void :
    if not condition:
        _failures.append(message)
