extends SceneTree

func _initialize() -> void :
    call_deferred("_run")

func _run() -> void :
    DisplayServer.window_set_size(Vector2i(1500, 950))
    root.size = Vector2i(1500, 950)
    await process_frame
    await process_frame

    var game_state: = root.get_node("GameState")
    game_state.init_character("hanmen")
    game_state.branch = ""
    game_state.branch_index = 0
    game_state.in_prison = false
    game_state.keju_status = "jinshi"
    game_state.set_theme("dark")
    game_state.initialize_governance_city(1)
    game_state.year = 2
    game_state.month = 1
    game_state.action_points = 2
    game_state._base_age = 25
    game_state.month_cards = [
        {"type": "story", "id": "e1_4b", "title": "社仓春借", "tag": "重要", "direct": false}
    ]
    game_state.month_cards_done.clear()
    game_state.current_month_card_index = -1

    var screen: Control = load("res://scenes/game_screen.tscn").instantiate()
    screen.set_anchors_preset(Control.PRESET_FULL_RECT)
    root.add_child(screen)
    await process_frame
    await process_frame
    screen.start_game()
    for i in range(8):
        await process_frame

    game_state.month_cards = [
        {"type": "story", "id": "e1_4b", "title": "社仓春借", "tag": "重要", "direct": false}
    ]
    game_state.month_cards_done.clear()
    game_state.current_month_card_index = -1
    screen._execute_month_card(0)
    for i in range(30):
        await process_frame

    var bar: = screen.get_node("CityStatsOverflowHost/CityStatsBar") as Control
    var host: = bar.get_parent() as Control
    var bar_rect: = bar.get_global_rect()
    var children_right: = _max_visible_child_right(bar)
    var overflow: = children_right - bar_rect.end.x
    var portrait_zone: = screen.get_node_or_null("EventPortraitBackdrop/PortraitZone") as Control
    var speaker_anchor: = screen.get_node("EventPortraitLayer/SpeakerAnchor") as Control
    var scroll_outer: = screen.get_node("MainVBox/Layout/CenterPanel/CenterMargin/ScrollOuter") as Control
    var center_panel: = screen.get_node("MainVBox/Layout/CenterPanel") as Control
    var title_label: = screen.event_title_label as Control
    var narrative_label: = screen.narrative_label as Control
    var title_body_gap: = narrative_label.get_global_rect().position.y - title_label.get_global_rect().end.y
    screen.speaker_line.text = ""
    screen.speaker_bubble.visible = false
    screen._update_event_portrait_layout()
    await process_frame
    await process_frame
    var speaker_frame: = screen.event_portrait_speaker_frame as Control
    var speaker_frame_rect: = speaker_frame.get_global_rect()
    var speaker_box: = screen._get_speaker_box_control() as Control
    var speaker_box_rect: Rect2 = speaker_box.get_global_rect()
    var speaker_anchor_rect: Rect2 = speaker_anchor.get_global_rect()
    var portrait_zone_rect: = portrait_zone.get_global_rect()
    var data: = {
        "bar_parent": host.name, 
        "bar_parent_parent": host.get_parent().name if host.get_parent() != null else "", 
        "bar_clip": bar.clip_contents, 
        "bar_x": bar_rect.position.x, 
        "bar_w": bar_rect.size.x, 
        "bar_right": bar_rect.end.x, 
        "children_right": children_right, 
        "scroll_outer_right": scroll_outer.get_global_rect().end.x, 
        "center_panel_right": center_panel.get_global_rect().end.x, 
        "overflow": overflow, 
        "complete_width": screen._get_city_stats_bar_complete_width(), 
        "host_w": host.size.x, 
        "event_portrait_active": screen._is_event_portrait_active(), 
        "portrait_zone_parent": portrait_zone.get_parent().name if portrait_zone != null and portrait_zone.get_parent() != null else "", 
        "portrait_zone_visible": portrait_zone.visible if portrait_zone != null else false, 
        "speaker_anchor_parent": speaker_anchor.get_parent().name if speaker_anchor.get_parent() != null else "", 
        "speaker_anchor_z": speaker_anchor.z_index, 
        "speaker_anchor_x": speaker_anchor_rect.position.x, 
        "speaker_anchor_right": speaker_anchor_rect.end.x, 
        "speaker_box_x": speaker_box_rect.position.x, 
        "speaker_box_right": speaker_box_rect.end.x, 
        "speaker_frame_right": speaker_frame_rect.end.x, 
        "speaker_frame_top": speaker_frame_rect.position.y, 
        "portrait_zone_right": portrait_zone_rect.end.x, 
        "portrait_zone_mid_y": portrait_zone_rect.position.y + portrait_zone_rect.size.y * 0.5, 
        "title_body_gap": title_body_gap
    }
    print("CITY_STATS_PROBE ", JSON.stringify(data))
    if host.name != "CityStatsOverflowHost"\
or host.get_parent() != screen\
or bar.clip_contents\
or overflow > 0.5\
or portrait_zone == null\
or portrait_zone.get_parent().name != "EventPortraitBackdrop"\
or not portrait_zone.visible\
or speaker_anchor.get_parent().name != "EventPortraitLayer"\
or speaker_anchor.z_index < 0\
or speaker_frame_rect.end.x < portrait_zone_rect.end.x - 36.0\
or speaker_frame_rect.position.y < portrait_zone_rect.position.y + portrait_zone_rect.size.y * 0.5\
or title_body_gap > 68.0:
        push_error("event portrait city stats overflow: " + JSON.stringify(data))
        quit(1)
        return
    quit(0)

func _max_visible_child_right(node: Node) -> float:
    var right: = - INF
    if node is Control:
        var control: = node as Control
        if control.visible:
            right = maxf(right, control.get_global_rect().end.x)
    for child in node.get_children():
        right = maxf(right, _max_visible_child_right(child))
    return right
