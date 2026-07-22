extends RefCounted
class_name GameScreenStyleFactory




static var _tab_active_texture_cache: Dictionary = {}

static func topbar_button_style(hovered: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0.8, 0.66, 0.38, 0.1 if hovered else 0.02) if GameState.theme == "dark" else Color(0.96, 0.91, 0.78, 0.42 if hovered else 0.0)
    style.border_width_left = 1 if hovered else 0
    style.border_width_top = 1 if hovered else 0
    style.border_width_right = 1 if hovered else 0
    style.border_width_bottom = 1 if hovered else 0
    style.border_color = GameState.get_theme_color("border_med")
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    style.content_margin_left = 9
    style.content_margin_right = 9
    style.content_margin_top = 4
    style.content_margin_bottom = 4
    return style

static func secondary_modal_button_style(hovered: bool = false, pressed: bool = false, pad_x: int = 18, pad_y: int = 8) -> StyleBoxFlat:
    var state: = "pressed" if pressed else ("hover" if hovered else "normal")
    return command_button_style("secondary", state, pad_x, pad_y)



static func command_button_style(role: String, state: String, pad_x: int = 18, pad_y: int = 8) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    var disabled: = state == "disabled"
    var hovered: = state == "hover"
    var pressed: = state == "pressed"
    if GameState.theme == "dark":
        if disabled:
            style.bg_color = Color(0.08, 0.075, 0.068, 0.78)
            style.border_color = Color(0.38, 0.34, 0.28, 0.24)
        elif role == "secondary":
            style.bg_color = Color(0.18, 0.11, 0.04, 0.52) if hovered else Color(0.12, 0.08, 0.03, 0.3)
            style.border_color = Color(0.86, 0.7, 0.4, 0.82) if hovered else Color(0.78, 0.62, 0.32, 0.62)
        else:
            style.bg_color = Color(0.46, 0.34, 0.16, 0.96) if hovered else Color(0.36, 0.27, 0.12, 0.95)
            style.border_color = Color(0.86, 0.7, 0.4, 0.88) if hovered else Color(0.78, 0.62, 0.32, 0.72)
    else:
        if disabled:
            style.bg_color = Color(0.78, 0.76, 0.7, 0.72)
            style.border_color = Color(0.48, 0.44, 0.36, 0.26)
        elif role == "secondary":
            style.bg_color = Color(0.94, 0.89, 0.77, 0.88) if hovered else Color(0.96, 0.93, 0.86, 0.7)
            style.border_color = Color(0.56, 0.4, 0.16, 0.72) if hovered else Color(0.56, 0.4, 0.16, 0.52)
        else:
            style.bg_color = Color(0.72, 0.56, 0.28, 0.96) if hovered else Color(0.64, 0.48, 0.22, 0.94)
            style.border_color = Color(0.42, 0.29, 0.12, 0.74)
    if pressed and not disabled:
        style.bg_color = style.bg_color.darkened(0.1)
    style.set_border_width_all(1)
    style.set_corner_radius_all(8)
    style.content_margin_left = pad_x
    style.content_margin_right = pad_x
    style.content_margin_top = pad_y
    style.content_margin_bottom = pad_y
    return style


static func apply_command_button_style(button: Button, role: String = "primary", pad_x: int = 18, pad_y: int = 8) -> void :
    var normal_text: = GameState.get_theme_color("border_active") if role == "secondary" else GameState.get_theme_color("text_main")
    var hover_text: = normal_text.lightened(0.12) if GameState.theme == "dark" else normal_text.darkened(0.08)
    button.add_theme_color_override("font_color", normal_text)
    button.add_theme_color_override("font_hover_color", hover_text)
    button.add_theme_color_override("font_pressed_color", hover_text)
    button.add_theme_color_override("font_disabled_color", Color(0.46, 0.43, 0.37, 0.55) if GameState.theme == "dark" else Color(0.42, 0.4, 0.36, 0.46))
    button.add_theme_stylebox_override("normal", command_button_style(role, "normal", pad_x, pad_y))
    button.add_theme_stylebox_override("hover", command_button_style(role, "hover", pad_x, pad_y))
    button.add_theme_stylebox_override("pressed", command_button_style(role, "pressed", pad_x, pad_y))
    button.add_theme_stylebox_override("disabled", command_button_style(role, "disabled", pad_x, pad_y))
    button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


static func modal_return_button_style(state: String) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    if GameState.theme == "dark":
        if state == "normal":
            style.bg_color = Color(0.02, 0.018, 0.014, 0.62)
            style.border_color = Color(0.72, 0.56, 0.28, 0.25)
        elif state == "hover":
            style.bg_color = Color(0.16, 0.1, 0.05, 0.62)
            style.border_color = Color(0.8, 0.62, 0.32, 0.42)
        else:
            style.bg_color = Color(0.1, 0.07, 0.035, 0.76)
            style.border_color = Color(0.8, 0.62, 0.32, 0.42)
    else:
        if state == "normal":
            style.bg_color = Color(0.74, 0.61, 0.39, 0.9)
        elif state == "hover":
            style.bg_color = Color(0.82, 0.7, 0.48, 0.94)
        else:
            style.bg_color = Color(0.66, 0.54, 0.32, 0.94)
        style.border_color = Color(0.45, 0.33, 0.18, 0.54)
    style.set_border_width_all(1)
    style.corner_radius_top_left = 8
    style.corner_radius_top_right = 8
    style.corner_radius_bottom_left = 8
    style.corner_radius_bottom_right = 8
    style.shadow_size = 6 if GameState.theme == "dark" and style.bg_color.a > 0.2 else 0
    style.shadow_color = Color(0, 0, 0, 0.26)
    style.content_margin_left = 18
    style.content_margin_right = 18
    style.content_margin_top = 8
    style.content_margin_bottom = 8
    return style

static func settings_button_style(hovered: bool, border_width: int) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()

    style.bg_color = Color(0.8, 0.66, 0.38, 0.15 if hovered else 0.08)
    _apply_style_border_width(style, border_width)
    var dark_palette: Dictionary = GameState.theme_colors["dark"]
    style.border_color = dark_palette.get("border_med") if hovered else dark_palette.get("border_weak")
    style.corner_radius_top_left = 4
    style.corner_radius_top_right = 4
    style.corner_radius_bottom_left = 4
    style.corner_radius_bottom_right = 4
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 4
    style.content_margin_bottom = 4
    return style

static func topbar_rank_style(hovered: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()

    style.bg_color = Color(0.8, 0.66, 0.38, 0.09 if hovered else 0.0)
    style.border_width_left = 1 if hovered else 0
    style.border_width_top = 1 if hovered else 0
    style.border_width_right = 1 if hovered else 0
    style.border_width_bottom = 1 if hovered else 0
    style.border_color = GameState.theme_colors["dark"].get("border_med")
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    style.content_margin_left = 0
    style.content_margin_right = 8
    style.content_margin_top = 4
    style.content_margin_bottom = 4
    return style

static func small_help_button_style(hovered: bool, border_width: int) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    if GameState.theme == "light":
        style.bg_color = Color(0.6, 0.45, 0.2, 0.12 if hovered else 0.03)
        style.border_color = Color(0.9, 0.85, 0.75, 0.85 if hovered else 0.6)
    else:
        style.bg_color = Color(0.72, 0.5, 0.16, 0.07 if hovered else 0.01)
        style.border_color = Color(0.72, 0.6, 0.36, 0.48 if hovered else 0.3)
    _apply_style_border_width(style, border_width)
    style.corner_radius_top_left = 9
    style.corner_radius_top_right = 9
    style.corner_radius_bottom_left = 9
    style.corner_radius_bottom_right = 9
    style.content_margin_left = 1
    style.content_margin_right = 1
    style.content_margin_top = 0
    style.content_margin_bottom = 0
    return style

static func choice_title_tag_style(locked: bool = false, border_width: int = 1) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0, 0, 0, 0)
    _apply_style_border_width(style, border_width)
    style.border_color = GameState.get_theme_color("border_med")
    if locked:
        style.border_color.a *= 0.55

    elif GameState.theme == "light":
        style.bg_color = Color(0, 0, 0, 0)
        style.border_color = Color(1.0, 1.0, 1.0, 0.34)
    style.corner_radius_top_left = 14
    style.corner_radius_top_right = 14
    style.corner_radius_bottom_left = 14
    style.corner_radius_bottom_right = 14
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 3
    style.content_margin_bottom = 3
    return style

static func month_card_style(card: Dictionary, disabled: bool, hovered: bool = false, pressed: bool = false, border_width: int = 1) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    _apply_style_border_width(style, border_width)

    var card_radius: = 3 if GameState.theme == "light" else 2
    style.corner_radius_top_left = card_radius
    style.corner_radius_top_right = card_radius
    style.corner_radius_bottom_left = card_radius
    style.corner_radius_bottom_right = card_radius
    style.content_margin_left = 14
    style.content_margin_right = 14
    style.content_margin_top = 12
    style.content_margin_bottom = 12
    if GameState.theme == "light":
        style.shadow_size = 6 if disabled else 8
        style.shadow_offset = Vector2(0, 3 if disabled else 4)
        style.shadow_color = Color(0.12, 0.1, 0.08, 0.08 if disabled else 0.14)
    else:
        style.shadow_size = 0
        style.shadow_color = Color(0, 0, 0, 0)
        style.shadow_offset = Vector2(0, 0)

    if disabled:

        style.bg_color = Color(0.788, 0.773, 0.702, 1.0) if GameState.theme == "light" else Color(0.18, 0.17, 0.15, 1.0)
        style.border_color = Color(0.48, 0.46, 0.4, 0.26) if GameState.theme == "light" else GameState.get_theme_color("border_weak")
    elif card.get("type", "") == "story":
        if GameState.theme == "light":
            style.bg_color = Color(0.35, 0.31, 0.26, 1.0) if hovered else Color(0.302, 0.267, 0.216, 1.0)
        else:
            style.bg_color = Color(0.22, 0.14, 0.09, 0.96) if hovered else Color(0.18, 0.11, 0.08, 0.92)
        style.border_color = Color(0.54, 0.34, 0.2, 0.48) if GameState.theme == "light" else Color(0.88, 0.75, 0.46, 0.75 if hovered else 0.45)
    elif card.get("type", "") == "home":
        if GameState.theme == "light":
            style.bg_color = Color(0.5, 0.47, 0.49, 1.0) if hovered else Color(0.443, 0.416, 0.435, 1.0)
        else:
            style.bg_color = Color(0.12, 0.1, 0.14, 0.92) if hovered else Color(0.09, 0.08, 0.11, 0.88)
        style.border_color = Color(0.43, 0.37, 0.48, 0.4 if hovered else 0.26) if GameState.theme == "light" else Color(0.56, 0.5, 0.68, 0.55 if hovered else 0.3)
    elif card.get("type", "") == "field":
        if GameState.theme == "light":
            style.bg_color = Color(0.38, 0.44, 0.36, 1.0) if hovered else Color(0.322, 0.388, 0.306, 1.0)
        else:
            style.bg_color = Color(0.1, 0.14, 0.1, 0.92) if hovered else Color(0.09, 0.11, 0.08, 0.88)
        style.border_color = Color(0.34, 0.48, 0.34, 0.42 if hovered else 0.28) if GameState.theme == "light" else Color(0.38, 0.6, 0.46, 0.6 if hovered else 0.32)
    elif card.get("type", "") == "visitor":
        if GameState.theme == "light":
            style.bg_color = Color(0.36, 0.46, 0.49, 1.0) if hovered else Color(0.302, 0.4, 0.427, 1.0)
        else:
            style.bg_color = Color(0.1, 0.12, 0.16, 0.92) if hovered else Color(0.08, 0.09, 0.12, 0.88)
        style.border_color = Color(0.35, 0.48, 0.56, 0.42 if hovered else 0.28) if GameState.theme == "light" else Color(0.46, 0.62, 0.78, 0.6 if hovered else 0.35)
    elif card.get("type", "") == "rumor":
        if GameState.theme == "light":
            style.bg_color = Color(0.39, 0.35, 0.36, 1.0) if hovered else Color(0.329, 0.29, 0.298, 1.0)
        else:
            style.bg_color = Color(0.12, 0.1, 0.11, 0.95) if hovered else Color(0.09, 0.07, 0.08, 0.9)
        style.border_color = Color(0.62, 0.5, 0.54, 0.48 if hovered else 0.3) if GameState.theme == "light" else Color(0.68, 0.56, 0.6, 0.54 if hovered else 0.34)
    elif card.get("type", "") == "court" or card.get("type", "") == "court_chain":
        if GameState.theme == "light":
            style.bg_color = Color(0.35, 0.31, 0.26, 1.0) if hovered else Color(0.302, 0.267, 0.216, 1.0)
        else:
            style.bg_color = Color(0.15, 0.11, 0.09, 0.94) if hovered else Color(0.12, 0.08, 0.07, 0.9)
        style.border_color = Color(0.48, 0.36, 0.28, 0.42 if hovered else 0.28) if GameState.theme == "light" else Color(0.72, 0.56, 0.4, 0.65 if hovered else 0.38)
    else:
        if GameState.theme == "light":
            style.bg_color = Color(0.44, 0.41, 0.38, 1.0) if hovered else Color(0.376, 0.353, 0.322, 1.0)
        else:
            style.bg_color = Color(0.14, 0.11, 0.08, 0.92) if hovered else Color(0.11, 0.09, 0.06, 0.88)
        style.border_color = Color(0.48, 0.38, 0.26, 0.42 if hovered else 0.28) if GameState.theme == "light" else Color(0.8, 0.66, 0.38, 0.6 if hovered else 0.35)



    if GameState.theme == "light":
        style.border_color.a = 0.48 if disabled else (0.64 if hovered else 0.54)

    if pressed:
        style.bg_color = style.bg_color.darkened(0.08)
    return style

static func choice_style(is_hidden: bool, is_locked: bool = false, hovered: bool = false, pressed: bool = false, border_width: int = 1) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    _apply_style_border_width(style, border_width)
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    style.content_margin_left = 14
    style.content_margin_right = 14
    style.content_margin_top = 12
    style.content_margin_bottom = 12
    style.shadow_size = 4 if not is_locked else 0
    style.shadow_color = Color(0, 0, 0, 0.25)

    if is_locked:
        style.bg_color = Color(0.12, 0.1, 0.08, 0.6)
        style.border_color = Color(0.35, 0.3, 0.25, 0.4)
    elif is_hidden:
        if pressed:
            style.bg_color = Color(0.15, 0.09, 0.06, 0.6)
            style.border_color = Color(1.0, 0.75, 0.35, 0.95)
        elif hovered:
            style.bg_color = Color(0.12, 0.07, 0.04, 0.5)
            style.border_color = Color(0.92, 0.65, 0.25, 0.85)
        else:
            style.bg_color = Color(0.08, 0.05, 0.03, 0.3)
            style.border_color = Color(0.75, 0.55, 0.2, 0.65)
    else:
        if pressed:
            style.bg_color = Color(0.12, 0.09, 0.07, 0.6)
            style.border_color = Color(0.85, 0.75, 0.65, 0.85)
        elif hovered:
            style.bg_color = Color(0.09, 0.07, 0.05, 0.5)
            style.border_color = Color(0.78, 0.62, 0.35, 0.75)
        else:
            style.bg_color = Color(0.05, 0.03, 0.02, 0.2)
            style.border_color = Color(0.68, 0.52, 0.25, 0.55)

    return style

static func tab_style(active: bool, pressed: bool = false) -> StyleBox:
    if active:
        var st: = StyleBoxTexture.new()
        st.texture = tab_active_texture()
        st.content_margin_left = 0
        st.content_margin_right = 0
        st.content_margin_top = 12
        st.content_margin_bottom = 12
        return st

    var style: = StyleBoxFlat.new()
    if pressed:
        style.bg_color = GameState.get_theme_color("choice_press")
        style.border_color = GameState.get_theme_color("border_active")
    else:
        style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
        style.border_color = GameState.get_theme_color("border")

    style.border_width_left = 0
    style.border_width_top = 0
    style.border_width_right = 0
    style.border_width_bottom = 0
    style.corner_radius_top_left = 2
    style.corner_radius_bottom_left = 2
    style.content_margin_left = 0
    style.content_margin_right = 0
    style.content_margin_top = 12
    style.content_margin_bottom = 12
    return style

static func tab_active_texture() -> ImageTexture:
    var key: = GameState.theme
    if _tab_active_texture_cache.has(key):
        return _tab_active_texture_cache[key]

    var W: = 64
    var H: = 256
    var img: = Image.create(W, H, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))

    var dark: = GameState.theme == "dark"
    var glow: = Color(0.72, 0.58, 0.32) if dark else Color(0.85, 0.68, 0.4)
    var glow_peak_a: = 0.2 if dark else 0.16
    var line_col: = GameState.get_theme_color("border_stronger")
    var line_peak_a: = 0.95

    var cx: = float(W) * 0.5
    var cy: = float(H) * 0.5
    var rx: = float(W) * 0.5
    var ry: = float(H) * 0.32
    var line_center_x: = float(W)
    var line_half_w_max: = 1.7
    var line_vspan: = float(H) * 0.46

    for y in range(H):
        for x in range(W):
            var col: = Color(0, 0, 0, 0)
            var dx: = (float(x) - cx) / rx
            var dy: = (float(y) - cy) / ry
            var d: = sqrt(dx * dx + dy * dy)
            var gf: = clampf(1.0 - d, 0.0, 1.0)
            gf = gf * gf
            if gf > 0.0:
                col = Color(glow.r, glow.g, glow.b, glow_peak_a * gf)
            var vy: = absf(float(y) - cy)
            if vy < line_vspan:
                var vt: = 1.0 - (vy / line_vspan)
                var half_w: = line_half_w_max * vt
                var vt_smooth: = vt * vt * (3.0 - 2.0 * vt)
                var hx: = absf(float(x) - line_center_x)
                if half_w > 0.0 and hx <= half_w + 0.5:
                    var edge: = clampf((half_w + 0.5) - hx, 0.0, 1.0)
                    var la: = line_peak_a * vt_smooth * edge
                    if la > 0.0:
                        col = _blend_color_over(Color(line_col.r, line_col.g, line_col.b, la), col)
            img.set_pixel(x, y, col)

    var tex: = ImageTexture.create_from_image(img)
    _tab_active_texture_cache[key] = tex
    return tex

static func mobile_tab_style(active: bool, hovered: bool = false, pressed: bool = false, position: int = 0, border_width: int = 1) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    var base_bg: = Color(0.038, 0.036, 0.032, 0.94) if GameState.theme == "dark" else Color(0.92, 0.88, 0.78, 0.9)
    if active:
        style.bg_color = Color(0, 0, 0, 0)
        style.border_color = Color(0.9, 0.7, 0.34, 0.22) if GameState.theme == "dark" else Color(0.64, 0.45, 0.18, 0.18)
        style.shadow_size = 6
        style.shadow_color = Color(0.93, 0.64, 0.22, 0.08) if GameState.theme == "dark" else Color(0.8, 0.55, 0.2, 0.08)
        style.shadow_offset = Vector2(0, 0)
    elif pressed:
        style.bg_color = Color(0.16, 0.12, 0.07, 0.94) if GameState.theme == "dark" else Color(0.82, 0.74, 0.58, 0.86)
        style.border_color = Color(0.88, 0.68, 0.32, 0.36)
    elif hovered:
        style.bg_color = Color(0.08, 0.07, 0.06, 0.94) if GameState.theme == "dark" else Color(0.95, 0.92, 0.84, 0.95)
        style.border_color = Color(0.8, 0.64, 0.36, 0.28) if GameState.theme == "dark" else Color(0.56, 0.42, 0.22, 0.22)
    else:
        style.bg_color = base_bg
        style.border_color = Color(0.78, 0.62, 0.35, 0.18) if GameState.theme == "dark" else Color(0.48, 0.38, 0.24, 0.16)

    var shows_frame: = active or hovered or pressed
    var frame_width: = border_width
    style.border_width_top = frame_width if shows_frame else 0
    style.border_width_bottom = frame_width if shows_frame else 0
    style.border_width_left = frame_width if shows_frame or position > 0 else 0
    style.border_width_right = frame_width if shows_frame and position == 2 else 0

    style.corner_radius_top_left = 16 if position == 0 else 0
    style.corner_radius_bottom_left = 16 if position == 0 else 0
    style.corner_radius_top_right = 16 if position == 2 else 0
    style.corner_radius_bottom_right = 16 if position == 2 else 0

    style.content_margin_left = 10
    style.content_margin_right = 10
    style.content_margin_top = 14
    style.content_margin_bottom = 14
    return style

static func _blend_color_over(top: Color, bottom: Color) -> Color:
    var a: = top.a + bottom.a * (1.0 - top.a)
    if a <= 0.0:
        return Color(0, 0, 0, 0)
    var inv: = bottom.a * (1.0 - top.a)
    var r: = (top.r * top.a + bottom.r * inv) / a
    var g: = (top.g * top.a + bottom.g * inv) / a
    var b: = (top.b * top.a + bottom.b * inv) / a
    return Color(r, g, b, a)

static func _apply_style_border_width(style: StyleBoxFlat, width: int) -> void :
    style.border_width_left = width
    style.border_width_right = width
    style.border_width_top = width
    style.border_width_bottom = width
