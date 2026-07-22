extends RefCounted
class_name TransitionToastController




const Presenter = preload("res://scripts/ui/game_screen_presenter.gd")
const FontLoader = preload("res://scripts/ui/font_loader.gd")
const CardAnimations = preload("res://scripts/ui/card_animations.gd")
const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const NativeMobileTouchScrollRef = preload("res://scripts/ui/native_mobile_touch_scroll.gd")
const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")

const TOAST_STRIP_TEXT_COLOR: = Color(0.92, 0.91, 0.86, 1.0)

var _host
var _toast_layer: CanvasLayer
var _toast_layer_root: Control

func _init(host) -> void :
    _host = host

func show_effects_toast(effects: Dictionary) -> void :
    var is_mobile: bool = _host._is_mobile_portrait()
    var font_size: = 52 if is_mobile else 22
    var separation: = 44 if is_mobile else 24
    var entries: Array[Dictionary] = []
    var measure_text: = ""
    for key in effects:
        var value: = int(effects[key])
        if value == 0:
            continue
        var entry_text: = Presenter.format_effect_delta_text(key, value)
        if measure_text != "":
            measure_text += " "
        measure_text += entry_text
        entries.append({
            "key": key, 
            "value": value, 
            "text": entry_text, 
        })

    if entries.is_empty():
        return

    var extra_content_width: = float(maxi(0, entries.size() - 1) * separation)
    var toast: = _make_toast_strip_container(is_mobile, measure_text, font_size, extra_content_width)
    toast.add_child(_make_toast_strip_background(toast.custom_minimum_size))

    var center: = CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    center.mouse_filter = Control.MOUSE_FILTER_IGNORE

    var hbox: = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", separation)
    hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE

    for entry in entries:
        var key = entry.get("key")
        var value: = int(entry.get("value", 0))
        var lbl: = _make_toast_strip_label(str(entry.get("text", "")), font_size)
        lbl.set_meta("effect_key", str(key))
        lbl.set_meta("effect_value", value)
        lbl.set_meta("is_city_level_effect", GameData.CITY_STAT_KEYS.has(str(key)))

        var text_col: Color
        if GameState.theme == "light":
            if Presenter.is_effect_positive(key, value):
                text_col = Color(0.92, 0.72, 0.3, 1.0)
            elif Presenter.is_effect_negative(key, value):
                text_col = Color(0.85, 0.45, 0.3, 1.0)
            else:
                text_col = Color(0.92, 0.88, 0.78, 1.0)
        else:
            text_col = _host._get_effect_delta_color(str(key), value)
        lbl.add_theme_color_override("font_color", text_col)
        hbox.add_child(lbl)

    toast.add_child(center)
    center.add_child(hbox)

    _get_toast_layer().add_child(toast)

    var alpha_in = _host.create_tween()
    toast.modulate.a = 0
    alpha_in.tween_property(toast, "modulate:a", 1.0, 0.2)
    CardAnimations.play_result_change_number(hbox)

    await _host.get_tree().process_frame

    if not is_instance_valid(toast):
        return

    center_transient_toast(toast)
    var alpha_out = _host.create_tween()
    alpha_out.tween_interval(1.2)
    alpha_out.tween_property(toast, "modulate:a", 0.0, 0.4)
    alpha_out.tween_callback(toast.queue_free)

func show_rank_up_toast(rank_name: String) -> void :
    var is_mobile: bool = _host._is_mobile_portrait()


    var rank_main: = rank_name
    var rank_xian: = ""
    var paren: = rank_name.find("(")
    if paren == -1:
        paren = rank_name.find("（")
    if paren != -1:
        rank_main = rank_name.substr(0, paren).strip_edges()
        rank_xian = rank_name.substr(paren + 1).replace(")", "").replace("）", "").strip_edges()



    var ph: float = 620.0 if is_mobile else 340.0
    var sc: float = ph / 410.0
    var hb: = 300.0 * sc
    var lr: = 560.0 * sc
    var slant: = 46.0 * sc
    var gap: = 18.0 * sc
    var dark_w: = 410.0 * sc
    var dl: = lr + gap
    var wb: = dl + dark_w
    var ht: = ph
    var panel_top: = ht - hb

    var cream: = Color(0.85, 0.83, 0.77)
    var dark: = Color(0.16, 0.165, 0.185)
    var light_poly: = PackedVector2Array([
        Vector2(0, 0), Vector2(lr + slant, 0), Vector2(lr, hb), Vector2(0, hb)])
    var dark_poly: = PackedVector2Array([
        Vector2(dl + slant, 0), Vector2(wb, 0), Vector2(wb, hb), Vector2(dl, hb)])

    var toast: = Control.new()
    toast.custom_minimum_size = Vector2(wb, ht)
    toast.size = Vector2(wb, ht)
    toast.mouse_filter = Control.MOUSE_FILTER_IGNORE


    var backdrop: = Control.new()
    backdrop.position = Vector2(0, panel_top)
    backdrop.size = Vector2(wb, hb)
    backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    backdrop.draw.connect(_draw_rank_banner.bind(backdrop, light_poly, dark_poly, cream, dark))
    toast.add_child(backdrop)


    var rank_portrait_path: String = _host._get_player_rank_portrait_path(rank_name)
    if rank_portrait_path != "":
        var rank_portrait: = TextureRect.new()
        rank_portrait.texture = load(rank_portrait_path)
        rank_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        rank_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        rank_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE

        rank_portrait.material = null
        var pw: = ht * 0.78
        rank_portrait.position = Vector2(lr * 0.5 - pw * 0.5, 0)
        rank_portrait.size = Vector2(pw, ht)
        rank_portrait.z_index = 1
        toast.add_child(rank_portrait)


    var text_zone: = Control.new()
    text_zone.position = Vector2(dl, panel_top)
    text_zone.size = Vector2(wb - dl, hb)
    text_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
    toast.add_child(text_zone)

    var center: = CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    center.mouse_filter = Control.MOUSE_FILTER_IGNORE
    text_zone.add_child(center)

    var vbox: = VBoxContainer.new()
    vbox.alignment = BoxContainer.ALIGNMENT_CENTER
    vbox.add_theme_constant_override("separation", int(8 * sc))
    center.add_child(vbox)

    var lbl1: = Label.new()
    lbl1.text = "升  迁"
    lbl1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lbl1.add_theme_font_override("font", FontLoader.serif_bold())
    lbl1.add_theme_color_override("font_color", Color(0.96, 0.95, 0.92))
    lbl1.add_theme_font_size_override("font_size", int(52 * sc))
    vbox.add_child(lbl1)

    var lbl2: = Label.new()
    lbl2.text = rank_main
    lbl2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lbl2.add_theme_font_override("font", FontLoader.body())
    lbl2.add_theme_color_override("font_color", Color(0.93, 0.92, 0.88))
    lbl2.add_theme_font_size_override("font_size", int(30 * sc))
    vbox.add_child(lbl2)


    var honorary_title: = ""
    if GameState.has_method("get_active_honorary_title"):
        honorary_title = str(GameState.get_active_honorary_title())
    if honorary_title != "":
        var lbl_honorary: = Label.new()
        lbl_honorary.text = honorary_title
        lbl_honorary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        lbl_honorary.add_theme_font_override("font", FontLoader.body())
        lbl_honorary.add_theme_color_override("font_color", Color(0.64, 0.62, 0.58))
        lbl_honorary.add_theme_font_size_override("font_size", int(21 * sc))
        vbox.add_child(lbl_honorary)

    if rank_xian != "":
        var lbl3: = Label.new()
        lbl3.text = "（%s）" % rank_xian
        lbl3.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        lbl3.add_theme_font_override("font", FontLoader.body())
        lbl3.add_theme_color_override("font_color", Color(0.62, 0.6, 0.57))
        lbl3.add_theme_font_size_override("font_size", int(22 * sc))
        vbox.add_child(lbl3)

    toast.z_index = 200
    _host.add_child(toast)
    await _host.get_tree().process_frame

    center_transient_toast(toast)
    var tween = _host.create_tween()

    toast.modulate.a = 0.0
    toast.scale = Vector2(0.9, 0.9)
    var pop_tween = _host.create_tween().set_parallel(true)
    pop_tween.tween_property(toast, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
    pop_tween.tween_property(toast, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

    tween.tween_interval(3.0)
    tween.tween_property(toast, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_SINE)
    tween.tween_callback(toast.queue_free)


func _draw_rank_banner(bd: Control, light_poly: PackedVector2Array, dark_poly: PackedVector2Array, light_col: Color, dark_col: Color) -> void :
    bd.draw_colored_polygon(light_poly, light_col)
    bd.draw_colored_polygon(dark_poly, dark_col)

func _make_toast_strip_container(is_mobile: bool, text: String = "", font_size: int = 0, extra_content_width: float = 0.0) -> Control:
    var visible_size: Vector2 = _get_toast_visible_size()
    var min_width: float = minf(920.0 if is_mobile else 460.0, visible_size.x * 0.72)
    var max_width: float = visible_size.x * 0.82
    var horizontal_padding: float = 96.0 if is_mobile else 48.0
    var content_width: = _measure_toast_text_width(text, font_size) + extra_content_width + horizontal_padding * 2.0
    var width: float = clampf(content_width, min_width, max_width)
    var line_count: = _get_toast_line_count(text)
    var base_height: float = 116.0 if is_mobile else 58.0
    var vertical_padding: float = 22.0 if is_mobile else 11.0
    var dynamic_height: = maxf(base_height, float(line_count) * maxf(float(font_size) * 1.05, 22.0) + vertical_padding * 2.0)
    var height: float = minf(dynamic_height, visible_size.y * 0.38)
    var toast: = Control.new()
    toast.custom_minimum_size = Vector2(width, height)
    toast.size = toast.custom_minimum_size
    toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
    return toast

func _measure_toast_text_width(text: String, font_size: int) -> float:
    if text == "" or font_size <= 0:
        return 0.0
    var font: = FontLoader.serif_bold()
    if font == null:
        return 0.0
    var max_width: = 0.0
    for line in text.split("\n"):
        max_width = maxf(max_width, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)
    return max_width

func _get_toast_line_count(text: String) -> int:
    if text == "":
        return 1
    return maxi(1, text.split("\n").size())

func _make_toast_strip_background(size: Vector2) -> Control:
    var bg: = Control.new()
    bg.set_anchors_preset(Control.PRESET_TOP_LEFT)
    bg.position = Vector2.ZERO
    bg.custom_minimum_size = size
    bg.size = size
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    bg.draw.connect(_draw_toast_strip_background.bind(bg))
    return bg

func _draw_toast_strip_background(bg: Control) -> void :
    var w: = bg.size.x
    var h: = bg.size.y
    var body_col: = Color(0.09, 0.095, 0.11, 0.96)
    var edge_col: = Color(0.22, 0.23, 0.25, 0.38)
    var slant: = minf(52.0, w * 0.08)
    var body_poly: = PackedVector2Array([
        Vector2(slant, 0.0), 
        Vector2(w, 0.0), 
        Vector2(w - slant, h), 
        Vector2(0.0, h)
    ])
    bg.draw_polygon(body_poly, PackedColorArray([body_col, body_col, body_col, body_col]))
    bg.draw_line(Vector2(slant, 0.0), Vector2(0.0, h), edge_col, 2.0, true)
    bg.draw_line(Vector2(w, 0.0), Vector2(w - slant, h), edge_col, 2.0, true)

func _make_toast_strip_label(text: String, font_size: int, color: Color = TOAST_STRIP_TEXT_COLOR) -> Label:
    var lbl: = Label.new()
    lbl.text = text
    lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    lbl.add_theme_font_override("font", FontLoader.serif_bold())
    lbl.add_theme_color_override("font_color", color)
    lbl.add_theme_font_size_override("font_size", font_size)
    lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
    return lbl

func center_transient_toast(toast: Control) -> void :

    var toast_size: = toast.get_combined_minimum_size()
    if toast.custom_minimum_size.x > toast_size.x:
        toast_size.x = toast.custom_minimum_size.x
    if toast.custom_minimum_size.y > toast_size.y:
        toast_size.y = toast.custom_minimum_size.y
    toast.custom_minimum_size = toast_size
    toast.size = toast_size
    toast.anchor_left = 0.5
    toast.anchor_right = 0.5
    toast.anchor_top = 0.5
    toast.anchor_bottom = 0.5
    toast.grow_horizontal = Control.GROW_DIRECTION_BOTH
    toast.grow_vertical = Control.GROW_DIRECTION_BOTH
    toast.offset_left = - toast_size.x * 0.5
    toast.offset_right = toast_size.x * 0.5
    toast.offset_top = - toast_size.y * 0.5
    toast.offset_bottom = toast_size.y * 0.5
    toast.pivot_offset = toast_size * 0.5

func _debug_print_toast_layout(toast: Control, text: String) -> void :
    if not OS.is_debug_build():
        return
    var label: Control = null
    for child in toast.get_children():
        if child is Label:
            label = child
            break
    var parent_control: = toast.get_parent() as Control
    var parent_size: = parent_control.size if parent_control != null else Vector2.ZERO
    var parent_global: = parent_control.global_position if parent_control != null else Vector2.ZERO
    var viewport_rect: Rect2 = _host.get_viewport().get_visible_rect()
    var window_size: = Vector2(DisplayServer.window_get_size())
    var label_size: = label.size if label != null else Vector2.ZERO
    var label_global: = label.global_position if label != null else Vector2.ZERO
    print("[ToastLayoutDebug] text=", text, 
        " viewport_rect=", viewport_rect, 
        " window_size=", window_size, 
        " parent=", toast.get_parent().name if toast.get_parent() != null else "<null>", 
        " parent_size=", parent_size, 
        " parent_global=", parent_global, 
        " toast_size=", toast.size, 
        " toast_global=", toast.global_position, 
        " toast_position=", toast.position, 
        " anchors=", Vector4(toast.anchor_left, toast.anchor_top, toast.anchor_right, toast.anchor_bottom), 
        " offsets=", Vector4(toast.offset_left, toast.offset_top, toast.offset_right, toast.offset_bottom), 
        " label_size=", label_size, 
        " label_global=", label_global, 
        " label_position=", label.position if label != null else Vector2.ZERO, 
        " label_anchors=", Vector4(label.anchor_left, label.anchor_top, label.anchor_right, label.anchor_bottom) if label != null else Vector4.ZERO, 
        " label_offsets=", Vector4(label.offset_left, label.offset_top, label.offset_right, label.offset_bottom) if label != null else Vector4.ZERO
    )

func _get_toast_visible_rect() -> Rect2:
    return _host.get_viewport().get_visible_rect()

func _get_toast_visible_size() -> Vector2:
    var visible_size: = _get_toast_visible_rect().size
    var window_size: = Vector2(DisplayServer.window_get_size())
    if window_size.x > 0.0:
        visible_size.x = minf(visible_size.x, window_size.x)
    if window_size.y > 0.0:
        visible_size.y = minf(visible_size.y, window_size.y)
    return visible_size

func _get_toast_layer() -> Control:
    if is_instance_valid(_toast_layer_root):
        _toast_layer_root.size = _get_toast_visible_size()
        return _toast_layer_root

    var layer: = CanvasLayer.new()
    layer.name = "GlobalToastLayer"
    layer.layer = 1000
    layer.follow_viewport_enabled = false
    layer.process_mode = Node.PROCESS_MODE_ALWAYS

    var root: = Control.new()
    root.name = "GlobalToastRoot"
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.set_anchors_preset(Control.PRESET_TOP_LEFT)
    root.position = Vector2.ZERO
    root.size = _get_toast_visible_size()
    layer.add_child(root)

    _host.get_tree().root.add_child(layer)
    _toast_layer = layer
    _toast_layer_root = root
    return _toast_layer_root

func show_keju_toast(keju_name: String) -> void :
    var is_mobile: bool = _host._is_mobile_portrait()
    var toast: = PanelContainer.new()
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0.12, 0.09, 0.06, 0.95)
    style.border_width_left = 1;style.border_width_right = 1
    style.border_width_top = 1;style.border_width_bottom = 1
    style.border_color = Color(0.76, 0.63, 0.35, 0.4)
    style.corner_radius_top_left = 2;style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2;style.corner_radius_bottom_right = 2
    style.content_margin_left = 80 if is_mobile else 40;style.content_margin_right = 80 if is_mobile else 40
    style.content_margin_top = 40 if is_mobile else 20;style.content_margin_bottom = 40 if is_mobile else 20
    if GameState.theme == "dark":
        style.shadow_size = 20
        style.shadow_color = Color(0, 0, 0, 0.8)
    else:
        style.shadow_size = 0
    toast.add_theme_stylebox_override("panel", style)

    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 16 if is_mobile else 8)
    vbox.alignment = BoxContainer.ALIGNMENT_CENTER

    var lbl1: = Label.new()
    lbl1.text = "金 榜 题 名"
    lbl1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lbl1.add_theme_color_override("font_color", Color(0.76, 0.63, 0.35, 0.8))
    lbl1.add_theme_font_size_override("font_size", 58 if is_mobile else 16)
    vbox.add_child(lbl1)

    var lbl2: = Label.new()
    lbl2.text = keju_name
    lbl2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lbl2.add_theme_color_override("font_color", Color(0.88, 0.84, 0.78, 1.0))
    lbl2.add_theme_font_size_override("font_size", 101 if is_mobile else 28)
    vbox.add_child(lbl2)

    toast.add_child(vbox)

    toast.anchor_left = 0.5
    toast.anchor_right = 0.5
    toast.anchor_top = 0.5
    toast.anchor_bottom = 0.5
    toast.grow_horizontal = Control.GROW_DIRECTION_BOTH
    toast.grow_vertical = Control.GROW_DIRECTION_BOTH
    toast.offset_top = -60
    toast.offset_bottom = -60

    toast.z_index = 200

    _host.add_child(toast)
    var tween = _host.create_tween()

    toast.modulate.a = 0.0
    toast.scale = Vector2(0.9, 0.9)
    var pop_tween = _host.create_tween().set_parallel(true)
    pop_tween.tween_property(toast, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
    pop_tween.tween_property(toast, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

    tween.tween_interval(3.0)
    tween.tween_property(toast, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_SINE)
    tween.tween_callback(toast.queue_free)

func show_simple_toast(text: String) -> void :
    var is_mobile: bool = _host._is_mobile_portrait()
    var toast: = _make_toast_strip(text, 52 if is_mobile else 24)

    toast.z_index = 220
    toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _get_toast_layer().add_child(toast)
    await _host.get_tree().process_frame
    center_transient_toast(toast)
    await _host.get_tree().process_frame
    _debug_print_toast_layout(toast, text)

    toast.modulate.a = 0.0
    toast.scale = Vector2(0.92, 0.92)
    var pop_tween = _host.create_tween().set_parallel(true)
    pop_tween.tween_property(toast, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
    pop_tween.tween_property(toast, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

    var tween = _host.create_tween()
    tween.tween_interval(1.6)
    tween.tween_property(toast, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
    tween.tween_callback(toast.queue_free)

func _make_toast_strip(text: String, font_size: int, color: Color = TOAST_STRIP_TEXT_COLOR) -> Control:
    var is_mobile: bool = _host._is_mobile_portrait()
    var toast: = _make_toast_strip_container(is_mobile, text, font_size)
    toast.add_child(_make_toast_strip_background(toast.custom_minimum_size))

    var lbl: = _make_toast_strip_label(text, font_size, color)
    var toast_size: = toast.custom_minimum_size
    lbl.custom_minimum_size = toast_size
    lbl.size = toast_size
    lbl.position = Vector2.ZERO
    lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    toast.add_child(lbl)
    return toast

func show_stage_transition(title: String, sub: String, callback: Callable) -> void :

    if is_instance_valid(GameState):
        GameState.play_default_bgm(2.0)

    var overlay: = ColorRect.new()
    overlay.color = Color(0, 0, 0, 1)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)



    var screen_size: Vector2 = _host.get_viewport_rect().size
    overlay.size = screen_size

    var mobile_portrait: bool = _host._is_mobile_portrait()





    var center: = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_TOP_LEFT)
    center.position = Vector2.ZERO
    center.size = screen_size

    var vbox: = VBoxContainer.new()
    vbox.alignment = BoxContainer.ALIGNMENT_CENTER
    center.add_child(vbox)

    var lbl1: = Label.new()
    lbl1.text = title
    lbl1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lbl1.add_theme_font_override("font", FontLoader.body())
    lbl1.add_theme_font_size_override("font_size", 42 if mobile_portrait else 32)
    lbl1.add_theme_color_override("font_color", Color(0.8, 0.7, 0.5))
    vbox.add_child(lbl1)

    var lbl2: = Label.new()
    lbl2.text = sub
    lbl2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lbl2.add_theme_font_override("font", FontLoader.body())
    lbl2.add_theme_font_size_override("font_size", 30 if mobile_portrait else 16)
    lbl2.add_theme_color_override("font_color", Color(0.6, 0.5, 0.4))
    vbox.add_child(lbl2)


    overlay.z_index = 200
    overlay.add_child(center)
    _host.add_child(overlay)
    NativeMobileFontScalerRef.apply_to(overlay)

    var tween = _host.create_tween()
    tween.tween_interval(2.0)
    tween.tween_property(overlay, "modulate:a", 0.0, 0.8)
    tween.tween_callback(overlay.queue_free)
    tween.tween_callback(callback)

func show_act_transition_narrative(pending: Dictionary, callback: Callable) -> void :
    var act_key: = str(pending.get("act", ""))
    var transition: Dictionary = GameData.ACT_TRANSITIONS.get(act_key, {})
    if transition.is_empty():
        if callback.is_valid():
            callback.call()
        return


    if is_instance_valid(GameState):
        GameState.play_bgm("res://assets/" + "transfer_bgm.mp3", 1.5)

    var is_high_minwang: = bool(pending.get("high_minwang", false))
    var high_cfg: Dictionary = transition.get("high_minwang", {})
    var narrative: = str(transition.get("narrative", ""))
    var reward_item: = ""
    var current_rank = GameState.get_rank_title()
    var default_rank = str(transition.get("rank", ""))
    var is_fallback_transfer: = current_rank != "" and default_rank != "" and current_rank.replace(" ", "") != default_rank.replace(" ", "")
    if is_fallback_transfer:
        narrative = str(transition.get("fallback_narrative", narrative))
    if is_high_minwang and not high_cfg.is_empty():
        if is_fallback_transfer:
            narrative = str(high_cfg.get("fallback_narrative", narrative))
        else:
            narrative = str(high_cfg.get("narrative", narrative))
        reward_item = str(high_cfg.get("reward_item", ""))

    var old_act_key: = str(int(act_key) - 1)
    var old_city_cfg: Dictionary = GameData.CITY_BY_ACT.get(old_act_key, {})
    var old_default_name = old_city_cfg.get("name", "")
    var old_name = pending.get("old_city_name", old_default_name)

    var new_city_cfg: Dictionary = GameData.CITY_BY_ACT.get(act_key, {})
    var new_default_name = new_city_cfg.get("name", "")
    var new_name = GameState.get_current_city_name() if not GameState.city.is_empty() else new_default_name

    if old_name != "" and old_default_name != "" and old_name != old_default_name:
        narrative = narrative.replace(old_default_name, old_name)
    if new_name != "" and new_default_name != "" and new_name != new_default_name:
        narrative = narrative.replace(new_default_name, new_name)

    if current_rank != "" and default_rank != "":
        var base_default = default_rank.split("·")[1].strip_edges() if "·" in default_rank else default_rank
        var base_current = current_rank.split("·")[1].strip_edges() if "·" in current_rank else current_rank
        if base_default != base_current:
            narrative = narrative.replace(base_default, base_current)
            if "县" in base_current and "州" in base_default:
                narrative = narrative.replace("府学", "县学")
            elif "县" in base_current and "府" in base_default:
                narrative = narrative.replace("府城", "县城")
                narrative = narrative.replace("府衙", "县衙")

    var replacements: = {}
    var current_city_name: = GameState.get_current_city_name()
    if current_city_name != "":
        replacements["{current_city}"] = current_city_name
        replacements["[current_city]"] = current_city_name
    for act_idx in range(1, 7):
        var act_idx_key: = str(act_idx)
        var city_cfg: Dictionary = GameState.resolve_transfer_city_for_act(act_idx_key, GameState.get_rank_title())
        var city_name: = str(city_cfg.get("name", ""))
        if city_name != "":
            replacements["{city_%s}" % act_idx_key] = city_name
            replacements["[city_%s]" % act_idx_key] = city_name

    if not replacements.has("{city_1}") or replacements["{city_1}"] == "":
        replacements["{city_1}"] = "蓬莱县"
        replacements["[city_1]"] = "蓬莱县"


    if reward_item != "":
        replacements["{dezheng_eval}"] = GameScreenPresenter.resolve_dezheng_eval(reward_item)

    for placeholder in replacements:
        narrative = narrative.replace(placeholder, replacements[placeholder])

    var overlay: = PanelContainer.new()
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.z_index = 180

    var panel_style: = StyleBoxFlat.new()
    panel_style.bg_color = Color(0.02, 0.015, 0.015, 1.0) if GameState.theme == "dark" else Color(0.96, 0.92, 0.84, 1.0)
    overlay.add_theme_stylebox_override("panel", panel_style)

    if GameState.theme == "dark":
        var gradient_bg: = make_act_transition_background_gradient()
        overlay.add_child(gradient_bg)
        var glow1: = make_act_transition_orange_glow(Vector2(0.15, 0.85), Vector2(0.65, 0.35), Color(0.2, 0.07, 0.02, 0.48))
        overlay.add_child(glow1)
        var glow2: = make_act_transition_orange_glow(Vector2(0.85, 0.15), Vector2(0.4, 0.6), Color(0.18, 0.06, 0.018, 0.42))
        overlay.add_child(glow2)

    var is_mobile: bool = _host._is_mobile_portrait()
    var window_size: Vector2 = _host.get_viewport_rect().size
    if window_size.x <= 0.0 or window_size.y <= 0.0:
        window_size = _host._get_responsive_window_size()



    var center: = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_TOP_LEFT)
    center.position = Vector2.ZERO
    center.size = window_size
    overlay.add_child(center)

    var scroll_width: = window_size.x * 0.96 if is_mobile else 780.0
    var scroll_height: = window_size.y * 0.91 if is_mobile else 600.0
    var vbox_width: = scroll_width - 24.0 if is_mobile else 740.0

    var scroll: = ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(scroll_width, scroll_height)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER

    var v_bar: = scroll.get_v_scroll_bar()
    if v_bar:
        v_bar.visible = false
        v_bar.visibility_changed.connect( func():
            if v_bar.visible:
                v_bar.visible = false
        )


    scroll.mouse_filter = Control.MOUSE_FILTER_STOP

    center.add_child(scroll)

    var vbox: = VBoxContainer.new()
    vbox.custom_minimum_size = Vector2(vbox_width, 0)
    vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.add_theme_constant_override("separation", 40 if is_mobile else 18)


    vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
    scroll.add_child(vbox)



    scroll.gui_input.connect( func(event):
        NativeMobileTouchScrollRef.forward_event_to_scroll(event, scroll, _host, "relocation_scroll_touch_drag_suppress_until_ms")
    )
    center.gui_input.connect( func(event):
        NativeMobileTouchScrollRef.forward_event_to_scroll(event, scroll, _host, "relocation_scroll_touch_drag_suppress_until_ms")
    )

    var route: = Label.new()
    var dest_prov = GameState.city.get("province", "")
    if dest_prov == "":
        dest_prov = GameData.CITY_BY_ACT.get(act_key, {}).get("province", transition.get("to", "").split(" · ")[0])
    var dest_name = GameState.get_current_city_name()
    if dest_name == "":
        dest_name = GameData.CITY_BY_ACT.get(act_key, {}).get("name", transition.get("to", "").split(" · ")[1] if " · " in transition.get("to", "") else transition.get("to", ""))

    var from_str = pending.get("from_str", transition.get("from", ""))

    if dest_prov != "" and dest_name != "":
        route.text = "%s  ->  %s · %s" % [from_str, dest_prov, dest_name]
    else:
        route.text = "%s  ->  %s" % [from_str, transition.get("to", "")]

    route.mouse_filter = Control.MOUSE_FILTER_IGNORE
    route.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    route.add_theme_font_override("font", FontLoader.body())
    route.add_theme_font_size_override("font_size", 30 if is_mobile else 14)
    route.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    vbox.add_child(route)

    var title: = Label.new()
    title.text = str(transition.get("title", "离任赴任"))
    title.mouse_filter = Control.MOUSE_FILTER_IGNORE
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", 42 if is_mobile else 30)
    title.add_theme_color_override("font_color", Color(0.82, 0.68, 0.38, 1.0))
    vbox.add_child(title)

    var rank: = Label.new()
    rank.text = current_rank if current_rank != "" else str(transition.get("rank", ""))
    rank.mouse_filter = Control.MOUSE_FILTER_IGNORE
    rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    rank.add_theme_font_override("font", FontLoader.body())
    rank.add_theme_font_size_override("font_size", 34 if is_mobile else 15)
    rank.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    vbox.add_child(rank)















    var text_box: = VBoxContainer.new()
    text_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
    text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    text_box.add_theme_constant_override("separation", 26 if is_mobile else 12)
    for para in split_nonempty_paragraphs(narrative):
        var p: = Label.new()
        p.text = para
        p.mouse_filter = Control.MOUSE_FILTER_IGNORE
        p.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        p.add_theme_font_override("font", FontLoader.body())
        p.add_theme_font_size_override("font_size", 30 if is_mobile else 16)
        p.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        p.add_theme_constant_override("line_spacing", 10 if is_mobile else 3)
        text_box.add_child(p)
    vbox.add_child(text_box)

    if reward_item != "":
        add_transition_reward_panel(vbox, reward_item, replacements)

    var button: = Button.new()
    button.text = "赴 任"
    button.custom_minimum_size = Vector2(340, 88) if is_mobile else Vector2(180, 42)
    button.add_theme_font_override("font", FontLoader.serif_bold())
    button.add_theme_font_size_override("font_size", 41 if is_mobile else 16)
    button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    GameScreenStyleFactory.apply_command_button_style(button, "primary", 24 if is_mobile else 18, 12 if is_mobile else 8)
    button.gui_input.connect( func(event):
        NativeMobileTouchScrollRef.forward_event_to_scroll(event, scroll, _host, "relocation_scroll_touch_drag_suppress_until_ms")
    )
    button.pressed.connect( func():
        if NativeMobileTouchScrollRef.should_suppress_press(_host, "relocation_scroll_touch_drag_suppress_until_ms"):
            return
        overlay.queue_free()
        _host._prepare_act_transition_surface()
        var act_cfg: Dictionary = GameData.ACT_CONFIG.get(act_key, {})
        if not act_cfg.is_empty():
            show_stage_transition(str(act_cfg.get("title", "")), str(act_cfg.get("sub", "")), callback)
        elif callback.is_valid():
            callback.call()
    )
    vbox.add_child(button)

    _host.add_child(overlay)
    NativeMobileFontScalerRef.apply_to(overlay)


    scroll.custom_minimum_size = Vector2(scroll_width, scroll_height)
    vbox.custom_minimum_size = Vector2(vbox_width, 0)

func make_act_transition_background_gradient() -> TextureRect:
    var gradient_rect: = TextureRect.new()
    gradient_rect.name = "ActTransitionBlackGradient"
    gradient_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    gradient_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    gradient_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    gradient_rect.stretch_mode = TextureRect.STRETCH_SCALE

    var grad: = Gradient.new()
    grad.set_color(0, Color(0.0, 0.0, 0.0, 0.18))
    grad.set_color(1, Color(0.0, 0.0, 0.0, 0.86))
    grad.add_point(0.42, Color(0.0, 0.0, 0.0, 0.42))
    grad.add_point(0.78, Color(0.0, 0.0, 0.0, 0.68))

    var tex: = GradientTexture2D.new()
    tex.gradient = grad
    tex.fill_from = Vector2(0.5, 0.0)
    tex.fill_to = Vector2(0.5, 1.0)
    tex.width = 64
    tex.height = 512
    gradient_rect.texture = tex
    return gradient_rect

func make_act_transition_orange_glow(center: Vector2, radius_to: Vector2, color: Color) -> TextureRect:
    var glow_rect: = TextureRect.new()
    glow_rect.name = "ActTransitionOrangeGlow_" + str(center.x).replace(".", "_") + "_" + str(center.y).replace(".", "_")
    glow_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    glow_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    glow_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    glow_rect.stretch_mode = TextureRect.STRETCH_SCALE

    var grad: = Gradient.new()
    grad.set_color(0, color)
    grad.set_color(1, Color(0.0, 0.0, 0.0, 0.0))
    grad.add_point(0.5, Color(color.r * 0.4, color.g * 0.4, color.b * 0.4, color.a * 0.4))

    var tex: = GradientTexture2D.new()
    tex.gradient = grad
    tex.fill = GradientTexture2D.FILL_RADIAL
    tex.fill_from = center
    tex.fill_to = radius_to
    tex.width = 256
    tex.height = 256
    glow_rect.texture = tex
    return glow_rect

func split_nonempty_paragraphs(text: String) -> Array[String]:
    var paras: Array[String] = []
    for raw in text.split("\n"):
        var para: = str(raw).strip_edges()
        if para != "":
            paras.append(para)
    return paras

func add_transition_reward_panel(parent: VBoxContainer, item_id: String, replacements: Dictionary = {}) -> void :
    var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
    if item_def.is_empty():
        return
    var is_mobile: bool = _host._is_mobile_portrait()
    var reward_panel: = PanelContainer.new()
    reward_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    reward_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var reward_style: = StyleBoxFlat.new()
    reward_style.bg_color = Color(0.72, 0.6, 0.34, 0.14)
    reward_style.border_color = Color(0.72, 0.6, 0.34, 0.38)
    reward_style.border_width_left = 1
    reward_style.border_width_top = 1
    reward_style.border_width_right = 1
    reward_style.border_width_bottom = 1
    reward_style.corner_radius_top_left = 2
    reward_style.corner_radius_top_right = 2
    reward_style.corner_radius_bottom_left = 2
    reward_style.corner_radius_bottom_right = 2
    reward_style.content_margin_left = 28 if is_mobile else 14
    reward_style.content_margin_right = 28 if is_mobile else 14
    reward_style.content_margin_top = 20 if is_mobile else 10
    reward_style.content_margin_bottom = 20 if is_mobile else 10
    reward_panel.add_theme_stylebox_override("panel", reward_style)

    var box: = VBoxContainer.new()
    box.mouse_filter = Control.MOUSE_FILTER_IGNORE
    box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    box.add_theme_constant_override("separation", 8 if is_mobile else 4)
    reward_panel.add_child(box)

    var heading: = Label.new()
    heading.text = "收 获 物 品"
    heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
    heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    heading.add_theme_font_override("font", FontLoader.serif_bold())
    heading.add_theme_font_size_override("font_size", 31 if is_mobile else 12)
    heading.add_theme_color_override("font_color", Color(0.82, 0.68, 0.38, 1.0))
    box.add_child(heading)

    var name_text = str(item_def.get("name", item_id))
    var desc_text = str(item_def.get("desc", ""))


    name_text = GameScreenPresenter.resolve_dezheng_item_text(item_id, name_text)
    desc_text = GameScreenPresenter.resolve_dezheng_item_text(item_id, desc_text)

    for placeholder in replacements:
        name_text = name_text.replace(placeholder, replacements[placeholder])
        desc_text = desc_text.replace(placeholder, replacements[placeholder])

    var name: = Label.new()
    var icon = str(item_def.get("icon", ""))
    name.text = "%s %s" % [icon, name_text] if icon != "" else name_text
    name.mouse_filter = Control.MOUSE_FILTER_IGNORE
    name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    name.add_theme_font_override("font", FontLoader.serif_bold())
    name.add_theme_font_size_override("font_size", 36 if is_mobile else 15)
    name.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    box.add_child(name)

    var desc: = Label.new()
    desc.text = desc_text
    desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
    desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    desc.add_theme_font_override("font", FontLoader.body())
    desc.add_theme_font_size_override("font_size", 31 if is_mobile else 12)
    if GameState.theme == "light":
        desc.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    else:
        desc.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    box.add_child(desc)

    parent.add_child(reward_panel)
