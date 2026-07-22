extends SceneTree






const OUT_PATH: = "user://promotion_over_event.png"

func _initialize() -> void :
    call_deferred("_run")

func _run() -> void :
    DisplayServer.window_set_size(Vector2i(1400, 820))
    root.size = Vector2i(1400, 820)
    await process_frame
    await process_frame

    var gs: = root.get_node("GameState")
    gs.init_character("hanmen")
    gs.branch = ""
    gs.branch_index = 0
    gs.in_prison = false
    gs.keju_status = "jinshi"
    gs.set_theme("dark")
    gs.initialize_governance_city(1)
    gs.year = 2
    gs.month = 1
    gs.action_points = 2
    gs._base_age = 25

    gs.rank_index = 12
    gs.month_cards = [
        {"type": "story", "id": "e1_4b", "title": "社仓春借", "tag": "重要", "direct": false}
    ]
    gs.month_cards_done.clear()
    gs.current_month_card_index = -1

    var screen: Control = load("res://scenes/game_screen.tscn").instantiate()
    screen.set_anchors_preset(Control.PRESET_FULL_RECT)
    root.add_child(screen)
    await process_frame
    await process_frame
    screen.start_game()
    for i in range(8):
        await process_frame


    screen._execute_month_card(0)
    for i in range(30):
        await process_frame


    screen._show_rank_up_toast(gs.get_rank_title())

    for i in range(45):
        await process_frame

    await RenderingServer.frame_post_draw
    var img: = root.get_viewport().get_texture().get_image()
    img.save_png(OUT_PATH)
    print("saved: ", ProjectSettings.globalize_path(OUT_PATH))
    quit()
