extends Control
class_name MingMapProvinceShape

var province_id: String = ""
var points: PackedVector2Array = PackedVector2Array()
var fill_color: Color = Color(0.64, 0.53, 0.3, 0.1)
var stroke_color: Color = Color(0.42, 0.31, 0.16, 0.34)
var stroke_width: float = 1.35

func _draw() -> void :
    if points.size() < 3:
        return
    draw_colored_polygon(points, fill_color)
    var closed: = PackedVector2Array(points)
    closed.append(points[0])
    draw_polyline(closed, stroke_color, stroke_width, true)

func contains_local_point(point: Vector2) -> bool:
    if points.size() < 3:
        return false
    var inside: = false
    var j: = points.size() - 1
    for i in range(points.size()):
        var pi: = points[i]
        var pj: = points[j]
        var crosses: = ((pi.y > point.y) != (pj.y > point.y))\
and (point.x < (pj.x - pi.x) * (point.y - pi.y) / maxf(0.0001, pj.y - pi.y) + pi.x)
        if crosses:
            inside = not inside
        j = i
    return inside
