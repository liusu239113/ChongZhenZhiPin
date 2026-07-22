extends Control





const FontLoader = preload("res://scripts/ui/font_loader.gd")
const PORTRAIT_PATH: = "res://assets/portraits/hanmen_rank2.webp"
const RANK_NAME: = "正二品·巡抚(右都御史衔)"
const OUT_PATH: = "user://promotion_preview.png"

var _light_poly: PackedVector2Array
var _dark_poly: PackedVector2Array
var _cream: = Color(0.85, 0.83, 0.77)
var _dark: = Color(0.16, 0.165, 0.185)

func _ready() -> void :
    GameState.theme = "dark"
    set_anchors_preset(Control.PRESET_FULL_RECT)


    var bg: = ColorRect.new()
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    bg.color = Color(0.93, 0.93, 0.93, 1.0)
    add_child(bg)

    add_child(_build_banner())

    await get_tree().process_frame
    await get_tree().process_frame
    await get_tree().process_frame
    var img: = get_viewport().get_texture().get_image()
    img.save_png(OUT_PATH)
    print("saved: ", ProjectSettings.globalize_path(OUT_PATH))
    get_tree().quit()

func _build_banner() -> Control:
    var rank_main: = RANK_NAME
    var rank_xian: = ""
    var paren: = RANK_NAME.find("(")
    if paren != -1:
        rank_main = RANK_NAME.substr(0, paren).strip_edges()
        rank_xian = RANK_NAME.substr(paren + 1).replace(")", "").strip_edges()

    var ph: = 340.0
    var sc: = ph / 410.0
    var hb: = 300.0 * sc
    var lr: = 560.0 * sc
    var slant: = 46.0 * sc
    var gap: = 18.0 * sc
    var dark_w: = 410.0 * sc
    var dl: = lr + gap
    var wb: = dl + dark_w
    var ht: = ph
    var panel_top: = ht - hb

    _light_poly = PackedVector2Array([
        Vector2(0, 0), Vector2(lr + slant, 0), Vector2(lr, hb), Vector2(0, hb)])
    _dark_poly = PackedVector2Array([
        Vector2(dl + slant, 0), Vector2(wb, 0), Vector2(wb, hb), Vector2(dl, hb)])

    var root: = Control.new()
    root.custom_minimum_size = Vector2(wb, ht)
    root.size = Vector2(wb, ht)
    root.position = Vector2((1180 - wb) * 0.5, (760 - ht) * 0.5)

    var backdrop: = Control.new()
    backdrop.position = Vector2(0, panel_top)
    backdrop.size = Vector2(wb, hb)
    backdrop.draw.connect( func():
        backdrop.draw_colored_polygon(_light_poly, _cream)
        backdrop.draw_colored_polygon(_dark_poly, _dark))
    root.add_child(backdrop)

    var portrait: = TextureRect.new()
    portrait.texture = load(PORTRAIT_PATH)
    portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    portrait.material = PortraitBacking.make_tone_material()
    var pw: = ht * 0.78
    portrait.position = Vector2(lr * 0.5 - pw * 0.5, 0)
    portrait.size = Vector2(pw, ht)
    portrait.z_index = 1
    root.add_child(portrait)

    var text_zone: = Control.new()
    text_zone.position = Vector2(dl, panel_top)
    text_zone.size = Vector2(wb - dl, hb)
    root.add_child(text_zone)
    var center: = CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    text_zone.add_child(center)
    var vbox: = VBoxContainer.new()
    vbox.alignment = BoxContainer.ALIGNMENT_CENTER
    vbox.add_theme_constant_override("separation", int(8 * sc))
    center.add_child(vbox)

    var l1: = Label.new()
    l1.text = "升  迁"
    l1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    l1.add_theme_font_override("font", FontLoader.serif_bold())
    l1.add_theme_color_override("font_color", Color(0.96, 0.95, 0.92))
    l1.add_theme_font_size_override("font_size", int(52 * sc))
    vbox.add_child(l1)

    var l2: = Label.new()
    l2.text = rank_main
    l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    l2.add_theme_font_override("font", FontLoader.body())
    l2.add_theme_color_override("font_color", Color(0.93, 0.92, 0.88))
    l2.add_theme_font_size_override("font_size", int(30 * sc))
    vbox.add_child(l2)

    if rank_xian != "":
        var l3: = Label.new()
        l3.text = "（%s）" % rank_xian
        l3.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        l3.add_theme_font_override("font", FontLoader.body())
        l3.add_theme_color_override("font_color", Color(0.62, 0.6, 0.57))
        l3.add_theme_font_size_override("font_size", int(22 * sc))
        vbox.add_child(l3)

    return root
