extends RefCounted
class_name HelpOverlayController




const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const FontLoader = preload("res://scripts/ui/font_loader.gd")

var _host


var _click_panel: PanelContainer = null




var _overlays: Array = []

func _init(host) -> void :
    _host = host

func show_help_overlay(target_btn: Control, title_text: String, desc_text: String, hover_mode: bool = false) -> void :
    close_help_overlays()
    var mobile_portrait: bool = _host._is_mobile_portrait()
    var overlay: = ColorRect.new()
    overlay.name = "HelpOverlay"
    overlay.color = Color(0, 0, 0, 0.01)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.z_index = 100





    overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

    var panel: = PanelContainer.new()
    panel.visible = false
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var style: = StyleBoxFlat.new()
    style.bg_color = GameState.get_theme_color("bg_popup")
    style.border_width_left = 1;style.border_width_right = 1
    style.border_width_top = 1;style.border_width_bottom = 1
    style.border_color = _host.DIANSHI_MODAL_BORDER
    style.corner_radius_top_left = 2;style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2;style.corner_radius_bottom_right = 2
    style.content_margin_left = _host.MOBILE_HELP_PANEL_PADDING if mobile_portrait else 16
    style.content_margin_right = _host.MOBILE_HELP_PANEL_PADDING if mobile_portrait else 16
    style.content_margin_top = _host.MOBILE_HELP_PANEL_PADDING if mobile_portrait else 16
    style.content_margin_bottom = _host.MOBILE_HELP_PANEL_PADDING if mobile_portrait else 16
    style.shadow_size = 0 if GameState.theme == "light" else 12
    style.shadow_color = Color(0.2, 0.15, 0.1, 0.15) if GameState.theme == "light" else Color(0, 0, 0, 0.42)
    style.shadow_offset = Vector2(0, 6)
    panel.add_theme_stylebox_override("panel", style)
    var vp_size: Vector2 = _host.get_viewport_rect().size
    var panel_width: float = 360.0
    if mobile_portrait:
        panel_width = clampf(vp_size.x * _host.MOBILE_HELP_PANEL_WIDTH_RATIO, _host.MOBILE_HELP_PANEL_MIN_WIDTH, _host.MOBILE_HELP_PANEL_MAX_WIDTH)
    else:
        panel_width = 360.0
    panel.custom_minimum_size = Vector2(panel_width, 0)

    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 18 if mobile_portrait else 8)

    var is_light: bool = GameState.theme == "light"

    var title: = Label.new()
    title.text = title_text
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", _host.MOBILE_HELP_TITLE_FONT_SIZE + 2 if mobile_portrait else 15)

    var title_color: Color = Color(0.32, 0.24, 0.14) if is_light else GameState.get_theme_color("border_active")
    title.add_theme_color_override("font_color", title_color)
    vbox.add_child(title)

    var desc: = Label.new()
    desc.text = desc_text
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    desc.custom_minimum_size.x = panel_width - float((_host.MOBILE_HELP_PANEL_PADDING if mobile_portrait else 16) * 2)
    desc.add_theme_font_size_override("font_size", _host.MOBILE_HELP_BODY_FONT_SIZE + 2 if mobile_portrait else 14)
    desc.add_theme_constant_override("line_spacing", 4 if mobile_portrait else 0)
    desc.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    vbox.add_child(desc)

    panel.add_child(vbox)
    overlay.add_child(panel)
    if not hover_mode:
        _click_panel = panel
    _host.add_child(overlay)
    _overlays.append(overlay)
    NativeMobileFontScalerRef.apply_to(overlay)

    await _host.get_tree().process_frame
    if not is_instance_valid(panel):
        return
    var content_size: = vbox.get_combined_minimum_size()
    var max_panel_height: float = float(vp_size.y) - 20.0
    var vertical_padding: float = float((_host.MOBILE_HELP_PANEL_PADDING if mobile_portrait else 16) * 2)
    panel.size = Vector2(
        panel_width, 
        minf(max_panel_height, content_size.y + vertical_padding)
    )
    var btn_pos: Vector2 = target_btn.get_global_rect().position
    var btn_size: Vector2 = target_btn.get_global_rect().size
    var panel_size: Vector2 = panel.size

    if mobile_portrait:

        var target_x = btn_pos.x + (btn_size.x - panel_size.x) * 0.5
        target_x = clampf(target_x, 16.0, vp_size.x - panel_size.x - 16.0)

        var below_y = btn_pos.y + btn_size.y + 10.0
        var above_y = btn_pos.y - panel_size.y - 10.0


        var target_y = below_y
        if below_y + panel_size.y > vp_size.y - 16.0 and above_y >= 16.0:
            target_y = above_y

        panel.global_position = Vector2(target_x, target_y)
    else:

        var target_x = btn_pos.x + btn_size.x + 8
        var target_y = btn_pos.y


        if target_x + panel_size.x > vp_size.x - 10:
            target_x = btn_pos.x - panel_size.x - 8
        if target_y + panel_size.y > vp_size.y - 10:
            target_y = vp_size.y - panel_size.y - 10

        panel.global_position = Vector2(target_x, target_y)
    panel.visible = true

func close_help_overlays() -> void :
    _click_panel = null
    for overlay in _overlays:
        if is_instance_valid(overlay):
            overlay.queue_free()
    _overlays.clear()

    for child in _host.get_children():
        if child is CanvasItem and child.name == "HelpOverlay":
            child.queue_free()


func has_click_help_open() -> bool:
    return is_instance_valid(_click_panel)


func has_any_help_open() -> bool:
    for overlay in _overlays:
        if is_instance_valid(overlay):
            return true
    return false



func dismiss_help_on_outside_press(press_position: Vector2) -> bool:
    var found: = false
    for overlay in _overlays:
        if not is_instance_valid(overlay):
            continue
        found = true
        for sub in overlay.get_children():
            if sub is Control and sub.visible and sub.get_global_rect().has_point(press_position):
                return false
    if not found:
        return false
    close_help_overlays()
    return true



func dismiss_click_help_on_outside_press(press_position: Vector2) -> bool:
    if not is_instance_valid(_click_panel):
        return false
    if _click_panel.visible and _click_panel.get_global_rect().has_point(press_position):
        return false
    close_help_overlays()
    return true
