extends RefCounted
class_name MobileBottomTabController




var _host

func _init(host) -> void :
    _host = host

func sync_labels() -> void :
    if not is_instance_valid(_host.mobile_bottom_tabs):
        return
    var labels: = {
        "jushi": "个人", 
        "dangan": "档案", 
        "daoju": "行囊", 
        "lingwu": "识悟", 
    }
    configure_content(_host.mobile_jushi_tab, labels["jushi"], "res://assets/ui/status_icons/jushi.webp", "jushi")
    configure_content(_host.mobile_dangan_tab, labels["dangan"], "res://assets/ui/status_icons/dangan.webp", "dangan")
    configure_content(_host.mobile_daoju_tab, labels["daoju"], "res://assets/ui/status_icons/xingnang.webp", "daoju")
    configure_content(_host.mobile_lingwu_tab, labels["lingwu"], "res://assets/ui/status_icons/xingnang.webp", "lingwu")

    apply_style(_host.mobile_jushi_tab, _host.current_left_tab == "jushi", 0)
    apply_style(_host.mobile_dangan_tab, _host.current_left_tab == "dangan", 1)
    apply_style(_host.mobile_daoju_tab, _host.current_left_tab == "daoju", 2)
    apply_style(_host.mobile_lingwu_tab, _host.current_left_tab == "lingwu", 3)
    _host._queue_mobile_pixel_snap()

func configure_content(button: Button, label_text: String, icon_path: String, icon_key: String) -> void :
    button.text = ""
    button.icon = null
    button.expand_icon = false
    button.add_theme_constant_override("h_separation", 0)

    for child in button.get_children():
        if child.name.begins_with("MobileTabContent") or child.name == "ActiveGradientBg":
            button.remove_child(child)
            child.queue_free()

    var content: = HBoxContainer.new()
    content.name = "MobileTabContent"
    content.mouse_filter = Control.MOUSE_FILTER_IGNORE
    content.alignment = BoxContainer.ALIGNMENT_CENTER
    content.add_theme_constant_override("separation", 6)
    content.set_anchors_preset(Control.PRESET_FULL_RECT)
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.size_flags_vertical = Control.SIZE_EXPAND_FILL
    button.add_child(content)

    var icon: = TextureRect.new()
    icon.name = "MobileTabIcon"
    icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
    icon.texture = make_texture(icon_path, icon_key)
    icon.custom_minimum_size = Vector2(30.0, 30.0)
    icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    content.add_child(icon)

    var label: = Label.new()
    label.name = "MobileTabLabel"
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.text = label_text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", _host.MOBILE_BOTTOM_TAB_FONT_SIZE)
    content.add_child(label)

func make_texture(icon_path: String, icon_key: String) -> Texture2D:
    var base: = load(icon_path) as Texture2D
    if base == null:
        return null
    var atlas: = AtlasTexture.new()
    atlas.atlas = base
    atlas.region = _host.MOBILE_BOTTOM_TAB_ICON_REGIONS.get(icon_key, Rect2(0, 0, base.get_width(), base.get_height()))
    return atlas

func apply_style(button: Button, active: bool, position: int = 0) -> void :
    button.flat = false
    button.alignment = HORIZONTAL_ALIGNMENT_CENTER
    button.add_theme_font_size_override("font_size", _host.MOBILE_BOTTOM_TAB_FONT_SIZE)
    button.custom_minimum_size.y = _host.MOBILE_BOTTOM_TAB_HEIGHT

    var unselected_color = Color(0.7, 0.6, 0.38, 0.84) if GameState.theme == "dark" else Color(0.58, 0.46, 0.22, 0.86)
    var active_color = Color(1.0, 0.78, 0.28, 1.0) if GameState.theme == "dark" else Color(0.82, 0.52, 0.1, 1.0)
    var text_color = active_color if active else unselected_color

    button.add_theme_color_override("font_color", text_color)
    button.add_theme_color_override("font_hover_color", text_color)
    button.add_theme_color_override("font_pressed_color", text_color)
    button.add_theme_color_override("font_focus_color", text_color)
    button.add_theme_color_override("font_hover_pressed_color", text_color)
    button.add_theme_color_override("font_disabled_color", text_color)
    button.add_theme_color_override("icon_normal_color", text_color)
    button.add_theme_color_override("icon_hover_color", text_color)
    button.add_theme_color_override("icon_pressed_color", text_color)
    button.add_theme_color_override("icon_focus_color", text_color)
    button.add_theme_color_override("icon_disabled_color", text_color)
    var tab_icon: = button.find_child("MobileTabIcon", true, false) as TextureRect
    if tab_icon:
        tab_icon.modulate = text_color
    var tab_label: = button.find_child("MobileTabLabel", true, false) as Label
    if tab_label:
        tab_label.add_theme_color_override("font_color", text_color)
        tab_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.0))
        tab_label.add_theme_font_size_override("font_size", _host.MOBILE_BOTTOM_TAB_FONT_SIZE)

    button.add_theme_stylebox_override("normal", _host._make_mobile_tab_style(active, false, false, position))
    button.add_theme_stylebox_override("hover", _host._make_mobile_tab_style(active, true, false, position))
    button.add_theme_stylebox_override("pressed", _host._make_mobile_tab_style(active, false, true, position))
