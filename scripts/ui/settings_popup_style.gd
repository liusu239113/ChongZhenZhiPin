extends RefCounted




const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")
const FontLoader = preload("res://scripts/ui/font_loader.gd")

const MODAL_BORDER: = Color(0.42, 0.43, 0.44, 0.72)
const MOBILE_TITLE_FONT_SIZE: = 55
const ROW_META: = "settings_popup_row"

static func panel_style() -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color.html("E0E2E6") if GameState.theme == "light" else GameState.get_theme_color("bg_popup")
    style.set_border_width_all(1)
    style.border_color = MODAL_BORDER
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    style.shadow_size = 0 if GameState.theme == "light" else 12
    style.shadow_color = Color(0.2, 0.15, 0.1, 0.15) if GameState.theme == "light" else Color(0, 0, 0, 0.4)
    style.shadow_offset = Vector2(0, 6)
    return style

static func make_button(label: String, on_press: Callable) -> Button:
    var btn: = Button.new()
    btn.name = "%sPopupButton" % label
    btn.text = label
    btn.custom_minimum_size = Vector2(0, 38)
    btn.focus_mode = Control.FOCUS_NONE
    btn.add_theme_font_override("font", FontLoader.body())
    btn.add_theme_font_size_override("font_size", 14)
    btn.add_theme_color_override("font_color", Color(0.85, 0.75, 0.65, 1.0))
    btn.add_theme_color_override("font_hover_color", GameState.theme_colors["dark"].get("border_active", Color.WHITE))
    btn.add_theme_stylebox_override("normal", GameScreenStyleFactory.topbar_button_style(false))
    btn.add_theme_stylebox_override("hover", GameScreenStyleFactory.topbar_button_style(true))
    btn.add_theme_stylebox_override("pressed", GameScreenStyleFactory.topbar_button_style(true))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    btn.pressed.connect(on_press)
    return btn

static func make_text_toggle_row(label_text: String, value_text: String, on_press: Callable) -> Button:
    var btn: = Button.new()
    btn.name = "%sTextToggleRow" % label_text
    btn.set_meta(ROW_META, true)
    btn.custom_minimum_size = Vector2(0, 38)
    btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    btn.focus_mode = Control.FOCUS_NONE
    btn.add_theme_stylebox_override("normal", GameScreenStyleFactory.topbar_button_style(false))
    btn.add_theme_stylebox_override("hover", GameScreenStyleFactory.topbar_button_style(true))
    btn.add_theme_stylebox_override("pressed", GameScreenStyleFactory.topbar_button_style(true))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    btn.pressed.connect(on_press)

    var wrapper: = HBoxContainer.new()
    wrapper.name = "Content"
    wrapper.alignment = BoxContainer.ALIGNMENT_CENTER
    wrapper.add_theme_constant_override("separation", 18)
    wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE
    btn.add_child(wrapper)
    wrapper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var label: = Label.new()
    label.text = label_text
    label.add_theme_font_override("font", FontLoader.body())
    label.add_theme_font_size_override("font_size", 14)
    label.add_theme_color_override("font_color", Color(0.85, 0.75, 0.65, 0.82))
    label.custom_minimum_size = Vector2(84, 0)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    wrapper.add_child(label)

    var value: = Label.new()
    value.name = "ValueLabel"
    value.text = value_text
    value.add_theme_font_override("font", FontLoader.body())
    value.add_theme_font_size_override("font_size", 14)
    value.add_theme_color_override("font_color", Color(0.98, 0.88, 0.58, 1.0))
    value.custom_minimum_size = Vector2(54, 0)
    value.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    value.mouse_filter = Control.MOUSE_FILTER_IGNORE
    wrapper.add_child(value)
    return btn

static func make_header(title_text: String) -> HBoxContainer:
    var header: = HBoxContainer.new()
    header.name = "SettingsPopupHeader"
    header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var title: = Label.new()
    title.name = "SettingsPopupTitle"
    title.text = title_text
    title.add_theme_font_override("font", FontLoader.title())
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)
    return header

static func make_header_separator() -> HSeparator:
    var separator: = HSeparator.new()
    separator.name = "SettingsPopupSeparator"
    separator.add_theme_stylebox_override("separator", StyleBoxLine.new())
    return separator


static func divider_inset(mobile_portrait: bool, is_landscape_mobile: bool) -> float:
    return 24.0 if mobile_portrait else (18.0 if is_landscape_mobile else 14.0)

static func apply_layout(panel: PanelContainer, vbox: VBoxContainer, mobile_portrait: bool, is_landscape_mobile: bool, large_ui: bool = false) -> void :
    var scale_factor: = 1.2 if large_ui else 1.0
    var popup_style: = panel.get_theme_stylebox("panel") as StyleBoxFlat
    if popup_style:
        popup_style.content_margin_left = (44 if mobile_portrait else (28 if is_landscape_mobile else 24)) * scale_factor
        popup_style.content_margin_right = popup_style.content_margin_left

        popup_style.content_margin_top = (44 if mobile_portrait else (16 if is_landscape_mobile else 24)) * scale_factor
        popup_style.content_margin_bottom = popup_style.content_margin_top

    vbox.add_theme_constant_override("separation", (16 if mobile_portrait else (2 if is_landscape_mobile else 6)) * scale_factor)
    for child in vbox.get_children():
        if child is Button:
            var font_sz: = 14
            if mobile_portrait:
                font_sz = 36
            elif is_landscape_mobile:
                font_sz = 18

            font_sz = int(font_sz * scale_factor)

            if child.has_meta(ROW_META):
                child.custom_minimum_size = Vector2(0, (34 if is_landscape_mobile else 38) * scale_factor)
                var wrapper = child.get_node_or_null("Content")
                if wrapper:
                    wrapper.add_theme_constant_override("separation", 18 * scale_factor)
                    for sub_child in wrapper.get_children():
                        if sub_child is Label:
                            sub_child.add_theme_font_size_override("font_size", font_sz)
                            if sub_child.name == "ValueLabel":
                                sub_child.custom_minimum_size = Vector2(54 * scale_factor, 0)
                            else:
                                sub_child.custom_minimum_size = Vector2(84 * scale_factor, 0)
                continue
            if mobile_portrait:
                child.custom_minimum_size = Vector2(0, 76 * scale_factor)
                child.add_theme_font_size_override("font_size", font_sz)
            elif is_landscape_mobile:
                child.custom_minimum_size = Vector2(0, 34 * scale_factor)
                child.add_theme_font_size_override("font_size", font_sz)
            else:
                child.custom_minimum_size = Vector2(0, 38 * scale_factor)
                child.add_theme_font_size_override("font_size", font_sz)

    var title_lbl: = vbox.get_node_or_null("SettingsPopupHeader/SettingsPopupTitle") as Label
    if title_lbl:
        var title_font_sz = 20 if is_landscape_mobile else (MOBILE_TITLE_FONT_SIZE if mobile_portrait else 18)
        title_lbl.add_theme_font_size_override("font_size", int(title_font_sz * scale_factor))
        title_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))

    var inset: = divider_inset(mobile_portrait, is_landscape_mobile) * scale_factor
    var sep_node: = vbox.get_node_or_null("SettingsPopupSeparator") as HSeparator
    if sep_node:
        var sep_style: = sep_node.get_theme_stylebox("separator") as StyleBoxLine
        if sep_style:
            sep_style.grow_begin = - inset
            sep_style.grow_end = - inset
            sep_style.color = GameState.get_theme_color("border_active")
            sep_style.color.a = 0.15

    apply_dividers(vbox, inset)

static func apply_dividers(vbox: VBoxContainer, inset: float) -> void :

    for child in vbox.get_children():
        if child is HSeparator and child.name != "SettingsPopupSeparator":
            vbox.remove_child(child)
            child.free()

    var setting_rows: = []
    for child in vbox.get_children():
        if child is Button or child.has_meta(ROW_META):
            setting_rows.append(child)
    var line_col: Color = GameState.get_theme_color("text_main")
    line_col.a = 0.03 if GameState.theme == "light" else 0.12
    for i in range(setting_rows.size() - 1):
        var sep: = HSeparator.new()
        var sep_style: = StyleBoxLine.new()
        sep_style.color = line_col
        sep_style.thickness = 1
        sep_style.grow_begin = - inset
        sep_style.grow_end = - inset
        sep.add_theme_stylebox_override("separator", sep_style)
        vbox.add_child(sep)
        vbox.move_child(sep, setting_rows[i].get_index() + 1)


static func popup_width(mobile_portrait: bool, is_landscape_mobile: bool, large_ui: bool = false) -> float:
    var base_w: = 880.0 if mobile_portrait else (640.0 if is_landscape_mobile else 420.0)
    return base_w * (1.2 if large_ui else 1.0)
