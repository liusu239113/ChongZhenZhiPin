extends SceneTree

func _initialize() -> void :
    GameState.landscape_size_mode = "phone"
    var screen = load("res://scenes/game_screen.tscn").instantiate()
    root.add_child(screen)
    await process_frame
    await process_frame
    screen._sync_native_landscape_size_override()
    screen._apply_responsive_layout()
    screen._show_settings_popup()
    await process_frame
    var popup: PanelContainer = screen.settings_popup
    var vbox: VBoxContainer = popup.get_node("VBox")
    print("SETTINGS_PROBE first_size=", popup.size, " first_min=", popup.get_combined_minimum_size(), " vbox_min=", vbox.get_combined_minimum_size(), " viewport=", screen.get_viewport_rect().size)
    screen._hide_settings_popup()
    await process_frame
    screen._show_settings_popup()
    await process_frame
    print("SETTINGS_PROBE second_size=", popup.size, " second_min=", popup.get_combined_minimum_size(), " vbox_min=", vbox.get_combined_minimum_size())
    quit()
