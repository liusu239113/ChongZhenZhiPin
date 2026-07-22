extends SceneTree

func _initialize() -> void :
    call_deferred("_run")

func _run() -> void :
    DisplayServer.window_set_size(Vector2i(1600, 950))
    root.size = Vector2i(1600, 950)
    await process_frame
    var game_state: = root.get_node("GameState")
    game_state.selected_timeline = "chongzhen"
    game_state.init_character("shijia")
    game_state.active_line = "bianwu"
    root.get_node("GameData").activate_line("bianwu")
    game_state.branch = ""
    game_state.in_prison = false
    game_state.initialize_governance_city(1)
    game_state.year = 1
    game_state.month = 3
    game_state.action_points = 2
    var defense_service = load("res://scripts/services/bianwu_defense_service.gd")
    defense_service.ensure_initialized(game_state)
    game_state.bianwu_defense_enemies = [{"id": "probe_rebels", "name": "流寇前锋", "size": 80, "region_id": "bw1_dunbao", "target_region_id": "bw1_baihusuo", "status": "正在南下"}]
    var screen: Control = load("res://scenes/game_screen.tscn").instantiate()
    screen.set_anchors_preset(Control.PRESET_FULL_RECT)
    root.add_child(screen)
    await process_frame
    screen.start_game()
    for i in range(10):
        await process_frame
    screen._show_bianwu_defense_map()
    for i in range(12):
        await process_frame
    var image: = root.get_texture().get_image()
    image.save_png("/tmp/bianwu_hex_map_probe.png")
    print("BIANWU_HEX_MAP_PROBE /tmp/bianwu_hex_map_probe.png")
    quit(0)
