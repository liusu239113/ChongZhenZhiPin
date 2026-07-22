extends RefCounted
class_name SettingsPopupController




const FontLoader = preload("res://scripts/ui/font_loader.gd")
const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const NativeMobileTouchScrollRef = preload("res://scripts/ui/native_mobile_touch_scroll.gd")
const ScrollbarThemeRef = preload("res://scripts/ui/scrollbar_theme.gd")
const AboutGamePopupRef = preload("res://scripts/ui/about_game_popup.gd")

var _host

func _init(host) -> void :
    _host = host

func show_about_author_popup() -> void :
    _host._hide_settings_popup()

    AboutGamePopupRef.show(_host)

func show_theme_select_popup() -> void :
    var mobile_portrait: bool = _host._is_mobile_portrait()
    var overlay: = ColorRect.new()
    overlay.color = Color(0, 0, 0, 0.4)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.z_index = 100

    overlay.gui_input.connect( func(event):
        if _host._is_primary_press_event(event):
            overlay.queue_free()
    )

    var panel: = PanelContainer.new()
    var style: = StyleBoxFlat.new()
    style.bg_color = Color.html("E0E2E6") if GameState.theme == "light" else GameState.get_theme_color("bg_popup")
    style.border_width_left = 1;style.border_width_right = 1
    style.border_width_top = 1;style.border_width_bottom = 1
    style.border_color = _host.DIANSHI_MODAL_BORDER
    style.corner_radius_top_left = 2;style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2;style.corner_radius_bottom_right = 2
    style.content_margin_left = 44 if mobile_portrait else 24;style.content_margin_right = 44 if mobile_portrait else 24
    style.content_margin_top = 44 if mobile_portrait else 24;style.content_margin_bottom = 44 if mobile_portrait else 24
    style.shadow_size = 0 if GameState.theme == "light" else 12
    style.shadow_color = Color(0.2, 0.15, 0.1, 0.15) if GameState.theme == "light" else Color(0, 0, 0, 0.4)
    style.shadow_offset = Vector2(0, 6)
    panel.add_theme_stylebox_override("panel", style)
    panel.custom_minimum_size = Vector2(720, 0) if mobile_portrait else Vector2(300, 0)

    var center: = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)

    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 30 if mobile_portrait else 20)

    var title: = Label.new()
    title.text = "选择显示模式"
    title.add_theme_font_size_override("font_size", 43 if mobile_portrait else 16)
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)

    var btn_style: = StyleBoxFlat.new()
    btn_style.bg_color = GameState.get_theme_color("bg_panel_weak")
    btn_style.set_border_width_all(1)
    btn_style.border_color = GameState.get_theme_color("border")
    btn_style.content_margin_top = 22 if mobile_portrait else 12;btn_style.content_margin_bottom = 22 if mobile_portrait else 12

    var btn_hover_style = btn_style.duplicate()
    if GameState.theme == "light":
        btn_hover_style.set_border_width_all(0)

    var light_btn: = Button.new()
    light_btn.text = "浅色模式"
    light_btn.custom_minimum_size = Vector2(0, 76) if mobile_portrait else Vector2(0, 0)
    light_btn.add_theme_font_size_override("font_size", 36 if mobile_portrait else 14)
    light_btn.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    light_btn.add_theme_stylebox_override("normal", btn_style)
    light_btn.add_theme_stylebox_override("hover", btn_hover_style)
    light_btn.pressed.connect( func():
        if GameState.theme != "light":
            GameState.toggle_theme()
        overlay.queue_free()
        _host._hide_settings_popup()
    )
    vbox.add_child(light_btn)

    var dark_btn: = Button.new()
    dark_btn.text = "深色模式"
    dark_btn.custom_minimum_size = Vector2(0, 76) if mobile_portrait else Vector2(0, 0)
    dark_btn.add_theme_font_size_override("font_size", 36 if mobile_portrait else 14)
    dark_btn.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    dark_btn.add_theme_stylebox_override("normal", btn_style)
    dark_btn.add_theme_stylebox_override("hover", btn_hover_style)
    dark_btn.pressed.connect( func():
        if GameState.theme != "dark":
            GameState.toggle_theme()
        overlay.queue_free()
        _host._hide_settings_popup()
    )
    vbox.add_child(dark_btn)

    panel.add_child(vbox)
    center.add_child(panel)
    overlay.add_child(center)
    _host.add_child(overlay)
    NativeMobileFontScalerRef.apply_to(overlay)
