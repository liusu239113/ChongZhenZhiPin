extends RefCounted
class_name ResponsiveLayoutController





var _host

func _init(host) -> void :
    _host = host

func queue_layout() -> void :
    if _host.responsive_layout_pending:
        return
    _host.responsive_layout_pending = true
    _host.call_deferred("_apply_responsive_layout_after_resize")

func apply_after_resize() -> void :
    await _host.get_tree().process_frame
    await _host.get_tree().process_frame
    _host.responsive_layout_pending = false
    apply()

func apply() -> void :
    _host.last_responsive_window_size = get_window_size()
    var mobile_portrait: bool = _host._is_mobile_portrait()
    var layout_mode_changed: bool = _host.had_responsive_layout_pass and mobile_portrait != _host.last_mobile_portrait_layout
    if mobile_portrait:
        _host._apply_mobile_portrait_layout()
    else:
        _host._apply_desktop_landscape_layout()
    if layout_mode_changed:
        refresh_content_for_responsive_change()
    if mobile_portrait:
        _host._queue_mobile_pixel_snap()
    _host.last_mobile_portrait_layout = mobile_portrait
    _host.had_responsive_layout_pass = true
    _host._sync_mobile_tab_labels()
    _host._queue_mobile_pixel_snap()
    _host._apply_native_mobile_font_scale()
    _host._apply_safe_area_horizontal_insets()
    _host._update_items_expand_button()
    _host._update_event_portrait_layout()
    if mobile_portrait:
        _host._close_items_overlay()

func refresh_content_for_responsive_change() -> void :
    _host._refresh_panels()
    if GameState.is_governance_mode() and _host.governance_active_card_index < 0 and _host.governance_scroll.visible:
        _host._show_governance_overview(false)
        return
    if _host.event_scroll.visible:
        if GameState.showing_result:
            _host._apply_mobile_event_phase_visibility()
            _host._apply_chosen_choice_text_layout()
            if _host._is_mobile_portrait():
                _host._apply_mobile_event_width_constraints()
        else:
            _host._render_event_inner()

func get_window_size() -> Vector2:
    var viewport_size: Vector2 = _host.get_viewport_rect().size
    var window_size: = Vector2(DisplayServer.window_get_size())
    if OS.has_feature("web"):
        var browser_json: = str(JavaScriptBridge.eval("JSON.stringify({ w: window.innerWidth, h: window.innerHeight })"))
        var parsed = JSON.parse_string(browser_json)
        if parsed is Dictionary:
            var width: = float(parsed.get("w", 0.0))
            var height: = float(parsed.get("h", 0.0))
            if width > 0.0 and height > 0.0:
                return Vector2(width, height)
    if window_size.x > 0.0 and window_size.y > 0.0:
        return window_size
    return viewport_size
