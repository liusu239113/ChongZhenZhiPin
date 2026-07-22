class_name ScrollbarTheme
extends RefCounted

static func apply_to(scroll: ScrollContainer) -> void :
    if scroll == null:
        return
    var v_scroll_bar: = scroll.get_v_scroll_bar()
    if v_scroll_bar != null:
        _apply_bar(v_scroll_bar)
    var h_scroll_bar: = scroll.get_h_scroll_bar()
    if h_scroll_bar != null:
        _apply_bar(h_scroll_bar)






const BAR_WIDTH: = 14.0
const GRABBER_INSET: = 8.0

static func _apply_bar(scroll_bar: ScrollBar) -> void :
    scroll_bar.custom_minimum_size = Vector2(BAR_WIDTH, BAR_WIDTH)
    if GameState.theme == "light":
        scroll_bar.add_theme_stylebox_override("scroll", _make_style(Color(0.72, 0.6, 0.34, 0.14)))
        scroll_bar.add_theme_stylebox_override("grabber", _make_style(Color(0.72, 0.6, 0.34, 0.42), Color(0.72, 0.6, 0.34, 0.28)))
        scroll_bar.add_theme_stylebox_override("grabber_highlight", _make_style(Color(0.72, 0.6, 0.34, 0.58), Color(0.72, 0.6, 0.34, 0.36)))
        scroll_bar.add_theme_stylebox_override("grabber_pressed", _make_style(Color(0.72, 0.6, 0.34, 0.7), Color(0.72, 0.6, 0.34, 0.42)))
    else:
        scroll_bar.add_theme_stylebox_override("scroll", _make_style(Color(0.07, 0.045, 0.035, 0.78)))
        scroll_bar.add_theme_stylebox_override("grabber", _make_style(Color(0.2, 0.14, 0.1, 0.94), Color(0.48, 0.38, 0.24, 0.28)))
        scroll_bar.add_theme_stylebox_override("grabber_highlight", _make_style(Color(0.27, 0.19, 0.13, 0.96), Color(0.58, 0.46, 0.3, 0.34)))
        scroll_bar.add_theme_stylebox_override("grabber_pressed", _make_style(Color(0.32, 0.23, 0.15, 1.0), Color(0.68, 0.53, 0.34, 0.42)))
    scroll_bar.add_theme_stylebox_override("scroll_focus", scroll_bar.get_theme_stylebox("scroll"))

static func _make_style(bg_color: Color, border_color: Color = Color.TRANSPARENT) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = bg_color
    style.border_color = border_color
    var border_width: = 1 if border_color.a > 0.0 else 0
    style.border_width_left = border_width
    style.border_width_right = border_width
    style.border_width_top = border_width
    style.border_width_bottom = border_width
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2

    style.set_expand_margin(SIDE_LEFT, - GRABBER_INSET)
    return style
