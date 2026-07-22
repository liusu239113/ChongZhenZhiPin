extends RefCounted
class_name AboutGamePopup





const FontLoader = preload("res://scripts/ui/font_loader.gd")
const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const NativeMobileTouchScrollRef = preload("res://scripts/ui/native_mobile_touch_scroll.gd")
const ScrollbarThemeRef = preload("res://scripts/ui/scrollbar_theme.gd")
const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")

const DIANSHI_MODAL_BORDER: = Color(0.42, 0.43, 0.44, 0.72)


const MOBILE_TITLE_FONT_SIZE: = 55
const MOBILE_BODY_FONT_SIZE: = 38
const MOBILE_ACTION_FONT_SIZE: = 41
const MOBILE_ACTION_WIDTH: = 300.0
const MOBILE_ACTION_HEIGHT: = 84.0

const QQ_GROUPS: = [
    {"name": "崇祯直聘大明公务员内推群 5", "num": "1047655578", "url": "https://qm.qq.com/q/G5ECNHFEiW", "label": "加入 QQ 群 5 →"}, 
    {"name": "崇祯直聘大明公务员内推群 4", "num": "373389531", "url": "https://qm.qq.com/q/idaJLNFpba", "label": "加入 QQ 群 4 →"}, 
    {"name": "崇祯直聘大明公务员内推群 3", "num": "1026412573", "url": "https://qm.qq.com/q/UyMLFFMxEs", "label": "加入 QQ 群 3 →"}, 
    {"name": "崇祯直聘大明公务员内推群 2", "num": "564809903", "url": "https://qm.qq.com/q/j6z9kMVVFm", "label": "加入 QQ 群 2 →"}, 
    {"name": "崇祯直聘大明公务员内推群", "num": "1098366528", "url": "https://qm.qq.com/q/N6utMZodlm", "label": "加入 QQ 群 →"}
]



static func show(host) -> void :
    var overlay: = ColorRect.new()
    overlay.color = Color(0, 0, 0, 0.56) if GameState.theme == "dark" else Color(0, 0, 0, 0.34)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.z_index = 101
    overlay.add_to_group("blocking_modal_overlay")

    overlay.gui_input.connect( func(event):
        if host._is_primary_press_event(event):
            overlay.queue_free()
    )

    var mobile_portrait: bool = host._is_mobile_portrait()
    var is_landscape_mobile: bool = NativeMobileFontScalerRef.is_native_phone_landscape(host)

    var panel: = PanelContainer.new()
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    panel.gui_input.connect( func(event):
        if event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventScreenDrag:
            panel.get_viewport().set_input_as_handled()
    )
    var panel_style: = StyleBoxFlat.new()
    panel_style.bg_color = Color.html("E0E2E6") if GameState.theme == "light" else GameState.get_theme_color("bg_popup")
    panel_style.set_border_width_all(1)
    panel_style.border_color = DIANSHI_MODAL_BORDER
    panel_style.set_corner_radius_all(2)
    var pad_val: = 24 if is_landscape_mobile else (44 if mobile_portrait else 24)
    panel_style.content_margin_left = pad_val
    panel_style.content_margin_right = pad_val
    panel_style.content_margin_top = pad_val
    panel_style.content_margin_bottom = pad_val
    panel_style.shadow_size = 0 if GameState.theme == "light" else 12
    panel_style.shadow_color = Color(0.2, 0.15, 0.1, 0.15) if GameState.theme == "light" else Color(0, 0, 0, 0.4)
    panel_style.shadow_offset = Vector2(0, 6)
    panel.add_theme_stylebox_override("panel", panel_style)

    var width_val: = 680 if is_landscape_mobile else (800 if mobile_portrait else 620)
    panel.custom_minimum_size = Vector2(width_val, 0)

    var center: = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)

    var vbox: = VBoxContainer.new()
    var sep_val: = 12 if is_landscape_mobile else (24 if mobile_portrait else 16)
    vbox.add_theme_constant_override("separation", sep_val)

    var title: = Label.new()
    title.text = "关于游戏"
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", 20 if is_landscape_mobile else (MOBILE_TITLE_FONT_SIZE if mobile_portrait else 18))
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)

    var separator: = HSeparator.new()
    var sep_style: = StyleBoxLine.new()
    sep_style.color = GameState.get_theme_color("border_active")
    sep_style.color.a = 0.15
    separator.add_theme_stylebox_override("separator", sep_style)
    vbox.add_child(separator)

    var scroll: = ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.mouse_filter = Control.MOUSE_FILTER_PASS
    var scroll_h: = 360.0 if is_landscape_mobile else (600.0 if mobile_portrait else 360.0)
    scroll.custom_minimum_size = Vector2(0, scroll_h)
    ScrollbarThemeRef.apply_to(scroll)

    var scroll_vbox: = VBoxContainer.new()
    scroll_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll_vbox.add_theme_constant_override("separation", 16)
    scroll.add_child(scroll_vbox)

    var gold_hex: = GameState.get_theme_color("border_active").to_html(false)
    var sub_hex: = GameState.get_theme_color("text_sub").to_html(false)
    var desc_hex: = GameState.get_theme_color("text_desc").to_html(false)
    var base_size: int = 18 if is_landscape_mobile else (MOBILE_BODY_FONT_SIZE if mobile_portrait else 14)
    var small_size: int = base_size - 2
    var text_w: float = width_val - pad_val * 2 - 20


    var dev_label: = RichTextLabel.new()
    dev_label.bbcode_enabled = true
    dev_label.fit_content = true
    dev_label.scroll_active = false
    dev_label.selection_enabled = false
    dev_label.mouse_filter = Control.MOUSE_FILTER_PASS
    dev_label.custom_minimum_size.x = text_w
    dev_label.add_theme_font_override("normal_font", FontLoader.body())
    dev_label.add_theme_font_override("bold_font", FontLoader.serif_bold())
    dev_label.add_theme_font_size_override("normal_font_size", base_size)
    dev_label.add_theme_font_size_override("bold_font_size", base_size)
    dev_label.text = "[center][color=#%s]开发者：速速归位工作室[/color][/center]" % desc_hex
    scroll_vbox.add_child(dev_label)


    var qq_title: = Label.new()
    qq_title.text = "QQ 群"
    qq_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    qq_title.add_theme_font_override("font", FontLoader.serif_bold())
    qq_title.add_theme_font_size_override("font_size", small_size)
    qq_title.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    scroll_vbox.add_child(qq_title)

    for g in QQ_GROUPS:
        var g_vbox: = VBoxContainer.new()
        g_vbox.add_theme_constant_override("separation", 4)

        var name_lbl: = Label.new()
        name_lbl.text = g["name"]
        name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        name_lbl.add_theme_font_override("font", FontLoader.serif_bold())
        name_lbl.add_theme_font_size_override("font_size", base_size)
        name_lbl.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
        g_vbox.add_child(name_lbl)

        var num_hbox: = HBoxContainer.new()
        num_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
        num_hbox.add_theme_constant_override("separation", 6)

        var num_lbl: = Label.new()
        num_lbl.text = "群号: " + g["num"]
        num_lbl.add_theme_font_override("font", FontLoader.body())
        num_lbl.add_theme_font_size_override("font_size", base_size)
        num_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        num_hbox.add_child(num_lbl)

        var copy_btn: = Button.new()
        copy_btn.icon = preload("res://assets/ui/copy_icon.svg")
        copy_btn.flat = true
        copy_btn.custom_minimum_size = Vector2(12, 12)
        copy_btn.add_theme_constant_override("icon_max_width", 10)
        var normal_color: = Color(0.9, 0.9, 0.9, 0.6) if GameState.theme == "dark" else Color(0.2, 0.2, 0.2, 0.5)
        var hover_color: = GameState.get_theme_color("border_active")
        copy_btn.add_theme_color_override("icon_normal_color", normal_color)
        copy_btn.add_theme_color_override("icon_hover_color", hover_color)
        copy_btn.add_theme_color_override("icon_pressed_color", hover_color)
        copy_btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
        copy_btn.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
        copy_btn.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
        copy_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
        copy_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

        var group_num: String = g["num"]
        copy_btn.pressed.connect( func():
            DisplayServer.clipboard_set(group_num)
            if "_transition_toast_controller" in host and host._transition_toast_controller:
                host._transition_toast_controller.show_simple_toast("群号已复制")
        )
        num_hbox.add_child(copy_btn)
        g_vbox.add_child(num_hbox)

        var link_lbl: = RichTextLabel.new()
        link_lbl.bbcode_enabled = true
        link_lbl.fit_content = true
        link_lbl.scroll_active = false
        link_lbl.selection_enabled = false
        link_lbl.mouse_filter = Control.MOUSE_FILTER_PASS
        link_lbl.custom_minimum_size.x = text_w
        link_lbl.add_theme_font_override("normal_font", FontLoader.body())
        link_lbl.add_theme_font_size_override("normal_font_size", small_size)
        link_lbl.meta_clicked.connect( func(meta): OS.shell_open(str(meta)))
        link_lbl.text = "[center][url=%s][color=#%s]%s[/color][/url][/center]" % [g["url"], sub_hex, g["label"]]
        g_vbox.add_child(link_lbl)

        scroll_vbox.add_child(g_vbox)


    var xhs_vbox: = VBoxContainer.new()
    xhs_vbox.add_theme_constant_override("separation", 4)

    var xhs_title: = Label.new()
    xhs_title.text = "小红书"
    xhs_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    xhs_title.add_theme_font_override("font", FontLoader.serif_bold())
    xhs_title.add_theme_font_size_override("font_size", small_size)
    xhs_title.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    xhs_vbox.add_child(xhs_title)

    var xhs_name: = Label.new()
    xhs_name.text = "Pyacark 的创造日常"
    xhs_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    xhs_name.add_theme_font_override("font", FontLoader.serif_bold())
    xhs_name.add_theme_font_size_override("font_size", base_size)
    xhs_name.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    xhs_vbox.add_child(xhs_name)

    var xhs_link: = RichTextLabel.new()
    xhs_link.bbcode_enabled = true
    xhs_link.fit_content = true
    xhs_link.scroll_active = false
    xhs_link.selection_enabled = false
    xhs_link.mouse_filter = Control.MOUSE_FILTER_PASS
    xhs_link.custom_minimum_size.x = text_w
    xhs_link.add_theme_font_override("normal_font", FontLoader.body())
    xhs_link.add_theme_font_size_override("normal_font_size", small_size)
    xhs_link.meta_clicked.connect( func(meta): OS.shell_open(str(meta)))
    xhs_link.text = "[center][url=https://xhslink.com/m/4hcA36FCcTm][color=#%s]前往小红书主页 →[/color][/url][/center]" % sub_hex
    xhs_vbox.add_child(xhs_link)

    scroll_vbox.add_child(xhs_vbox)


    var web_vbox: = VBoxContainer.new()
    web_vbox.add_theme_constant_override("separation", 4)

    var web_title: = Label.new()
    web_title.text = "网页版"
    web_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    web_title.add_theme_font_override("font", FontLoader.serif_bold())
    web_title.add_theme_font_size_override("font_size", small_size)
    web_title.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    web_vbox.add_child(web_title)

    var web_link: = RichTextLabel.new()
    web_link.bbcode_enabled = true
    web_link.fit_content = true
    web_link.scroll_active = false
    web_link.selection_enabled = false
    web_link.mouse_filter = Control.MOUSE_FILTER_PASS
    web_link.custom_minimum_size.x = text_w
    web_link.add_theme_font_override("normal_font", FontLoader.body())
    web_link.add_theme_font_size_override("normal_font_size", base_size)
    web_link.meta_clicked.connect( func(meta): OS.shell_open(str(meta)))
    web_link.text = "[center][url=https://game.virtualoverapp.com/game/3033][color=#%s]https://game.virtualoverapp.com/game/3033[/color][/url][/center]" % sub_hex
    web_vbox.add_child(web_link)

    var web_desc: = RichTextLabel.new()
    web_desc.bbcode_enabled = true
    web_desc.fit_content = true
    web_desc.scroll_active = false
    web_desc.selection_enabled = false
    web_desc.mouse_filter = Control.MOUSE_FILTER_PASS
    web_desc.custom_minimum_size.x = text_w
    web_desc.add_theme_font_override("normal_font", FontLoader.body())
    web_desc.add_theme_font_size_override("normal_font_size", small_size)
    web_desc.text = "[center][color=#%s]（游戏是以 PC 横版为基础开发的，如果说有条件的话，可以在大屏幕上玩这个网页版，获得更好的体验。）[/color][/center]" % desc_hex
    web_vbox.add_child(web_desc)

    scroll_vbox.add_child(web_vbox)

    scroll.gui_input.connect( func(event):
        NativeMobileTouchScrollRef.forward_drag_to_scroll(event, scroll, host, "about_scroll_touch_drag_suppress_until_ms")
        if event is InputEventScreenDrag:
            scroll.get_viewport().set_input_as_handled()
    )
    vbox.add_child(scroll)

    var close_btn: = Button.new()
    close_btn.text = "返回"
    close_btn.custom_minimum_size = Vector2(0, 42) if is_landscape_mobile else (Vector2(MOBILE_ACTION_WIDTH, MOBILE_ACTION_HEIGHT) if mobile_portrait else Vector2(120, 36))
    close_btn.add_theme_font_override("font", FontLoader.serif_bold())
    var fs: int = MOBILE_ACTION_FONT_SIZE if mobile_portrait else 14
    close_btn.add_theme_font_size_override("font_size", fs)
    close_btn.add_theme_constant_override("icon_max_width", fs)
    var main_color: = Color(0.85, 0.75, 0.65, 1.0)
    close_btn.add_theme_color_override("font_color", main_color)
    close_btn.add_theme_color_override("icon_normal_color", main_color)
    close_btn.add_theme_color_override("icon_hover_color", main_color)
    close_btn.add_theme_color_override("icon_pressed_color", main_color)
    close_btn.add_theme_color_override("icon_focus_color", main_color)
    var pad_x: = 24 if mobile_portrait else 18
    var pad_y: = 12 if mobile_portrait else 8
    close_btn.add_theme_stylebox_override("normal", GameScreenStyleFactory.secondary_modal_button_style(false, false, pad_x, pad_y))
    close_btn.add_theme_stylebox_override("hover", GameScreenStyleFactory.secondary_modal_button_style(true, false, pad_x, pad_y))
    close_btn.add_theme_stylebox_override("pressed", GameScreenStyleFactory.secondary_modal_button_style(true, true, pad_x, pad_y))
    close_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    close_btn.pressed.connect( func():
        overlay.queue_free()
    )
    vbox.add_child(close_btn)

    panel.add_child(vbox)
    center.add_child(panel)
    overlay.add_child(center)
    host.add_child(overlay)
    NativeMobileFontScalerRef.apply_to(overlay)
