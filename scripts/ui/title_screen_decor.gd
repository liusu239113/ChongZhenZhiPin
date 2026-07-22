extends Control

const BORDER: = Color(0.48, 0.35, 0.17, 0.68)
const BORDER_FAINT: = Color(0.48, 0.35, 0.17, 0.32)
const INK_FAINT: = Color(0.18, 0.15, 0.12, 0.1)


func _ready() -> void :
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    resized.connect(queue_redraw)
    if not GameState.theme_changed.is_connected(_on_theme_changed):
        GameState.theme_changed.connect(_on_theme_changed)


func _on_theme_changed(_theme: String) -> void :
    queue_redraw()



func _draw_gradient_rect(rect: Rect2, left: Color, right: Color, width: float) -> void :
    var x0: = rect.position.x
    var y0: = rect.position.y
    var x1: = rect.position.x + rect.size.x
    var y1: = rect.position.y + rect.size.y

    draw_polyline_colors([Vector2(x0, y0), Vector2(x1, y0)], [left, right], width)
    draw_polyline_colors([Vector2(x0, y1), Vector2(x1, y1)], [left, right], width)

    draw_line(Vector2(x0, y0), Vector2(x0, y1), left, width)
    draw_line(Vector2(x1, y0), Vector2(x1, y1), right, width)


func _draw() -> void :
    var s: = size
    if s.x <= 0.0 or s.y <= 0.0:
        return



    var mist_y: = s.y * 0.18
    for i in range(4):
        var y: = mist_y + float(i) * s.y * 0.13
        var alpha: = 0.05 - float(i) * 0.006
        draw_arc(Vector2(s.x * (0.55 + float(i) * 0.06), y), s.x * (0.18 + float(i) * 0.04), PI * 1.05, PI * 1.9, 48, Color(0.18, 0.15, 0.12, alpha), 1.0)
