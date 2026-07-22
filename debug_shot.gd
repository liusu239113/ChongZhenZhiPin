extends Node

func _ready() -> void :
    DisplayServer.window_set_size(Vector2i(1500, 950))
    get_window().size = Vector2i(1500, 950)
    await get_tree().process_frame
    await get_tree().process_frame


    GameState.init_character("hanmen")
    GameState.branch = ""
    GameState.branch_index = 0
    GameState.in_prison = false
    GameState.keju_status = "jinshi"
    GameState.set_theme("light")
    GameState.initialize_governance_city(1)
    GameState.year = 1
    GameState.month = 12
    GameState.action_points = 2
    GameState._base_age = 25
    GameState.stats["wentao"] = 90
    GameState.stats["wulue"] = 90
    GameState.stats["lizheng"] = 90
    GameState.stats["tizhi"] = 60


    var gov_idx: = -1
    for i in range(GameData.GOVERNANCE_CARDS.size()):
        if str(GameData.GOVERNANCE_CARDS[i].get("id", "")) == "gc_zhengwu_master":
            gov_idx = i
            break
    print("gc_zhengwu_master gov_idx = ", gov_idx)


    GameState.month_cards = [
        {"type": "governance", "idx": gov_idx, "id": "gc_zhengwu_master", "title": "政务纯熟", "tag": "政务"}, 
    ]
    GameState.month_cards_done.clear()
    GameState.current_month_card_index = -1

    var gs: Control = load("res://scenes/game_screen.tscn").instantiate()
    gs.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(gs)
    await get_tree().process_frame
    await get_tree().process_frame
    gs.start_game()
    for i in range(6):
        await get_tree().process_frame


    GameState.month_cards = [
        {"type": "governance", "idx": gov_idx, "id": "gc_zhengwu_master", "title": "政务纯熟", "tag": "政务"}, 
    ]
    GameState.month_cards_done.clear()
    GameState.current_month_card_index = -1

    gs._execute_month_card(0)
    for i in range(120):
        await get_tree().process_frame

    var img: Image = get_viewport().get_texture().get_image()
    img.save_png("res://../upgrade_modal.png")
    print("screenshot saved")
    await get_tree().process_frame
    get_tree().quit()
