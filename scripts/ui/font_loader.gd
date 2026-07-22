extends RefCounted

static func title() -> Font:
    return _load("res://assets/fonts/alimama-dongfang_web.ttf", "res://assets/fonts/alimama-dongfang.ttf")

static func serif_bold() -> Font:
    return _load("res://assets/fonts/NotoSerifSC-Bold_web.otf", "res://assets/fonts/NotoSerifSC-Bold.otf")

static func body() -> Font:
    return _load("res://assets/fonts/LXGWWenKai-Regular.ttf", "res://assets/fonts/LXGWWenKai-Regular.ttf")

static func _load(web_path: String, desktop_path: String) -> Font:
    var paths: = [desktop_path]
    if OS.has_feature("web"):
        paths = [web_path, desktop_path]
    for path in paths:
        if ResourceLoader.exists(path):
            var font: = load(path) as Font
            if font:
                return font

    var fallback: = SystemFont.new()
    fallback.font_names = PackedStringArray([
        "Songti SC", 
        "SimSun", 
        "STSong", 
        "serif", 
        "PingFang SC", 
        "Microsoft YaHei", 
        "sans-serif"
    ])
    return fallback
