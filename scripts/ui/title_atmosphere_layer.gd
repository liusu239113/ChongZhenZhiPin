extends Control

const DUST_COUNT: = 180
const GOLD: = Color(0.92, 0.64, 0.24, 1.0)
const DUST_DARK: = Color(0.2, 0.14, 0.08, 1.0)

var _time: = 0.0
var _dust: Array[Dictionary] = []


func _ready() -> void :
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _build_dust()
    resized.connect(queue_redraw)


func _process(delta: float) -> void :
    _time += delta
    queue_redraw()


func _draw() -> void :
    var s: = size
    if s.x <= 0.0 or s.y <= 0.0:
        return

    _draw_dust(s)


func _build_dust() -> void :
    _dust.clear()
    var rng: = RandomNumberGenerator.new()
    rng.seed = 1628
    for i in range(DUST_COUNT):
        var right_bias: = pow(rng.randf(), 0.62)
        var lower_bias: = pow(rng.randf(), 0.82)
        _dust.append({
            "x": lerpf(0.1, 0.98, right_bias), 
            "y": lerpf(0.1, 0.92, lower_bias), 
            "r": rng.randf_range(0.55, 2.35), 
            "speed": rng.randf_range(0.012, 0.046), 
            "fall": rng.randf_range(-0.01, 0.014), 
            "phase": rng.randf_range(0.0, TAU), 
            "alpha": rng.randf_range(0.055, 0.18)
        })


func _draw_dust(s: Vector2) -> void :
    for item in _dust:
        var phase: = float(item["phase"])
        var speed: = float(item["speed"])
        var x: = fposmod((float(item["x"]) + _time * speed) * s.x, s.x + 80.0) - 40.0
        var y: = fposmod((float(item["y"]) + _time * float(item["fall"])) * s.y, s.y + 80.0) - 40.0
        y += sin(_time * 0.85 + phase) * 10.0
        var pulse: = 0.72 + 0.28 * sin(_time * 1.6 + phase)
        var alpha: = float(item["alpha"]) * pulse
        var radius: = float(item["r"])
        var color: = Color(GOLD.r, GOLD.g, GOLD.b, alpha)
        draw_circle(Vector2(x, y), radius, color)
        if radius > 1.35:
            draw_circle(Vector2(x, y), radius * 2.6, Color(GOLD.r, GOLD.g, GOLD.b, alpha * 0.22))
