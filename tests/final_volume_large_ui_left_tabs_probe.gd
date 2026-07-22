extends SceneTree

const VIEWPORT_SIZE: = Vector2i(1280, 720)

func _initialize() -> void :
    call_deferred("_run")

func _run() -> void :
    DisplayServer.window_set_size(VIEWPORT_SIZE)
    root.size = VIEWPORT_SIZE
    await process_frame
    await process_frame

    var game_state: = root.get_node("GameState")
    game_state.init_character("hanmen")
    game_state.branch = ""
    game_state.branch_index = 0
    game_state.in_prison = false
    game_state.keju_status = "jinshi"
    game_state.set_theme("dark")
    game_state.initialize_governance_city(6)
    game_state.year = 16
    game_state.month = 1
    game_state.action_points = 2
    game_state.month_cards_done.clear()
    game_state.current_month_card_index = -1
    game_state.set_large_ui_mode(false)

    var screen: Control = load("res://scenes/game_screen.tscn").instantiate()
    screen.set_anchors_preset(Control.PRESET_FULL_RECT)
    root.add_child(screen)
    await _wait_frames(8)
    screen.governance_scroll.visible = false
    screen._refresh_panels()
    screen._apply_responsive_layout()
    await _wait_frames(12)

    var normal_rect: = _left_tabs_rect(screen)
    screen._set_large_ui_mode(true)
    await _wait_frames(16)
    var large_rect: = _left_tabs_rect(screen)
    var tab_switch_rects: Dictionary = {}
    for tab_key in ["zhisu", "zengyi", "jushi", "dangan", "daoju", "lingwu"]:
        screen._switch_left_tab(tab_key)
        await _wait_frames(3)
        tab_switch_rects[tab_key] = _rect_data(_left_tabs_rect(screen))

    game_state.initialize_governance_city(1)
    game_state.year = 2
    screen._refresh_panels()
    screen._apply_responsive_layout()
    await _wait_frames(12)
    var first_volume_large_rect: = _left_tabs_rect(screen)

    screen._set_large_ui_mode(false)
    await _wait_frames(12)
    screen._set_large_ui_mode(true)
    await _wait_frames(16)
    var repeated_toggle_rect: = _left_tabs_rect(screen)

    var data: = {
        "viewport_width": float(root.size.x), 
        "normal_left": normal_rect.position.x, 
        "normal_right": normal_rect.end.x, 
        "normal_width": normal_rect.size.x, 
        "large_left": large_rect.position.x, 
        "large_right": large_rect.end.x, 
        "large_width": large_rect.size.x, 
        "left_panel_left": screen.left_panel.get_global_rect().position.x, 
        "left_panel_width": screen.left_panel.get_global_rect().size.x, 
        "center_left": screen.center_panel.get_global_rect().position.x, 
        "tab_switches": tab_switch_rects, 
        "first_volume_large": _rect_data(first_volume_large_rect), 
        "repeated_toggle": _rect_data(repeated_toggle_rect), 
    }
    print("FINAL_VOLUME_LEFT_TABS_PROBE ", JSON.stringify(data))

    if not _is_fully_visible(normal_rect) or not _is_fully_visible(large_rect):
        push_error("final-volume large-UI left tabs leave the viewport: " + JSON.stringify(data))
        quit(1)
        return
    if large_rect.size.x < screen.NATIVE_LANDSCAPE_LEFT_TABS_WIDTH - 0.5:
        push_error("final-volume large-UI left tabs collapse below their compact width: " + JSON.stringify(data))
        quit(1)
        return
    for tab_key in tab_switch_rects:
        if not _rect_data_is_fully_visible(tab_switch_rects[tab_key]):
            push_error("left tabs leave the viewport after switching to " + str(tab_key) + ": " + JSON.stringify(data))
            quit(1)
            return
    if not _is_fully_visible(first_volume_large_rect) or not _is_fully_visible(repeated_toggle_rect):
        push_error("left tabs leave the viewport outside the final-volume first toggle: " + JSON.stringify(data))
        quit(1)
        return
    quit(0)

func _left_tabs_rect(screen: Control) -> Rect2:
    return screen.left_tabs.get_global_rect()

func _is_fully_visible(rect: Rect2) -> bool:
    return rect.position.x >= -0.5 and rect.end.x <= float(root.size.x) + 0.5

func _rect_data(rect: Rect2) -> Dictionary:
    return {"left": rect.position.x, "right": rect.end.x, "width": rect.size.x}

func _rect_data_is_fully_visible(data: Dictionary) -> bool:
    return float(data.get("left", - INF)) >= -0.5 and float(data.get("right", INF)) <= float(root.size.x) + 0.5

func _wait_frames(count: int) -> void :
    for _index in range(count):
        await process_frame
