extends RefCounted








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
    "city": "res://assets/ui/status_icons/city.webp", 
    "shengjuan": "res://assets/ui/status_icons/shengjuan.webp", 
    "zhongguan": "res://assets/ui/status_icons/zhongguan.webp", 
    "qingyi": "res://assets/ui/status_icons/qingyi.webp", 
    "chaotang": "res://assets/ui/status_icons/qingyi.webp", 
    "shishen": "res://assets/ui/status_icons/shishen.webp", 
    "minwang": "res://assets/ui/status_icons/minwang.webp", 
    "shimin": "res://assets/ui/status_icons/minwang.webp", 

    "houqin": "res://assets/ui/status_icons/guanliang.webp", 
    "qingbao": "res://assets/ui/status_icons/wentao.webp", 
    "mazheng": "res://assets/ui/status_icons/nongsang.webp", 
    "binggong": "res://assets/ui/status_icons/wulue.webp", 
    "jianjun": "res://assets/ui/status_icons/zhongguan.webp", 
    "junxin": "res://assets/ui/status_icons/bingyong.webp", 

    "liangcao": "res://assets/ui/status_icons/guanliang.webp", 
    "xiangyin": "res://assets/ui/status_icons/kuyin.webp", 
    "guanjun": "res://assets/ui/status_icons/bingyong.webp", 
    "mapi": "res://assets/ui/status_icons/nongsang.webp", 
    "jiading": "res://assets/ui/status_icons/shishen.webp", 
    "huoqi": "res://assets/ui/status_icons/wulue.webp", 
    "zhanyi": "res://assets/ui/status_icons/wulue.webp"
}

static func modulate() -> Color:
    return Color(1.0, 0.92, 0.74, 0.94) if GameState.theme == "dark" else Color(0.56, 0.43, 0.24, 0.96)

static func make_texture(stat_key: String, icon_size: float) -> TextureRect:
    if not STATUS_ICON_PATHS.has(stat_key):
        return null
    var tex: = load(STATUS_ICON_PATHS[stat_key]) as Texture2D
    if tex == null:
        return null
    var icon: = TextureRect.new()
    icon.texture = tex
    icon.custom_minimum_size = Vector2(icon_size, icon_size)
    icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    icon.modulate = modulate()
    return icon

static func make_centered(stat_key: String, icon_size: float, slot_size: Vector2, optical_y_offset: float = 0.0) -> Control:
    var icon: = make_texture(stat_key, icon_size)
    if icon == null:
        return null
    var slot: = Control.new()
    slot.custom_minimum_size = slot_size
    slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
    icon.position = Vector2((slot_size.x - icon_size) * 0.5, (slot_size.y - icon_size) * 0.5 + optical_y_offset)
    slot.add_child(icon)
    return slot
