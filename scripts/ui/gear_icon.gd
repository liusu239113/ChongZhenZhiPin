extends Control




@export var line_color: Color = Color(0.72, 0.71, 0.68, 0.85):
    set(value):
        line_color = value
        queue_redraw()


@export var icon_radius: float = 7.0:
    set(value):
        icon_radius = value
        queue_redraw()

var svg_texture: Texture2D = preload("res://assets/ui/settings_custom.svg")

func _init() -> void :
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void :
    var center: = size * 0.5
    var size_dim: = icon_radius * 2.0
    var rect: = Rect2(center - Vector2(icon_radius, icon_radius), Vector2(size_dim, size_dim))
    if svg_texture:
        draw_texture_rect(svg_texture, rect, false, line_color)
