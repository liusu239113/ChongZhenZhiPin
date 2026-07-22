extends Node




const HEIGHT: = 950
const WIDTHS: = [1000, 1100, 1150, 1200, 1280, 1350, 1450, 1550, 1700, 1900, 2100]

const EXTRA_SIZES: = [
    Vector2i(1100, 867), 
    Vector2i(1000, 940), 
    Vector2i(1200, 1000), 
    Vector2i(1050, 1000), 
    Vector2i(1280, 1008), 
]

var gs: Control

func _ready() -> void :
    get_window().size = Vector2i(1500, HEIGHT)
    await get_tree().process_frame
    await get_tree().process_frame

    GameState.init_character("hanmen")
    GameState.branch = ""
    GameState.branch_index = 0
    GameState.in_prison = false
    GameState.keju_status = "jinshi"
    GameState.set_theme("dark")
    GameState.initialize_governance_city(1)
    GameState.year = 1
    GameState.month = 9
    GameState.current_event = 0
    GameState.action_points = 2
    GameState.stats["wentao"] = 71
    GameState.stats["wulue"] = 41
    GameState.stats["lizheng"] = 49
    GameState.stats["tizhi"] = 60

    gs = load("res://scenes/game_screen.tscn").instantiate()
    gs.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(gs)
    await get_tree().process_frame
    await get_tree().process_frame
    gs.start_game()
    for i in range(10):
        await get_tree().process_frame
    if OS.get_environment("SWEEP_OVERVIEW") != "1":

        gs._execute_month_card(0)
        for i in range(20):
            await get_tree().process_frame
        print("[sweep] event_scroll.visible=", gs.event_scroll.visible)

    var sizes: Array = []
    for w in WIDTHS:
        sizes.append(Vector2i(w, HEIGHT))
    sizes.append_array(EXTRA_SIZES)
    for s in sizes:
        get_window().size = s
        for i in range(14):
            await get_tree().process_frame
        var vp_size: Vector2 = gs.get_viewport_rect().size
        print("\n===== window %dx%d  viewport=%.0fx%.0f =====" % [s.x, s.y, vp_size.x, vp_size.y])
        _report_offscreen(gs, vp_size)
        _report_wide_minsize(gs)
        _report_speaker_bottom_gap(vp_size)
        var img: Image = get_viewport().get_texture().get_image()
        img.save_png("res://../scratch/width_sweep_%dx%d.png" % [s.x, s.y])
    print("\nsweep done")
    await get_tree().process_frame
    get_tree().quit()

func _report_speaker_bottom_gap(vp_size: Vector2) -> void :
    var anchor: Control = gs.event_portrait_speaker_anchor
    if anchor == null or not is_instance_valid(anchor) or not anchor.is_visible_in_tree():
        return
    var bottom: = - INF
    for c in anchor.get_children():
        if c is Control and (c as Control).visible:
            bottom = maxf(bottom, (c as Control).get_global_rect().end.y)
    if bottom > - INF:
        print("  SPEAKER bottom_gap=%.0f (bottom=%.0f vp_h=%.0f)" % [vp_size.y - bottom, bottom, vp_size.y])

func _report_wide_minsize(root: Node) -> void :

    var stack: Array = [root]
    while not stack.is_empty():
        var n: Node = stack.pop_back()
        for c in n.get_children():
            stack.append(c)
        var ctrl: = n as Control
        if ctrl == null or not ctrl.is_visible_in_tree():
            continue
        var ms: Vector2 = ctrl.get_combined_minimum_size()
        if ms.x <= 600.0:
            continue
        var child_carries: = false
        for c in ctrl.get_children():
            if c is Control and (c as Control).is_visible_in_tree() and (c as Control).get_combined_minimum_size().x > ms.x - 40.0:
                child_carries = true
                break
        if not child_carries:
            print("  WIDE min=%.0f custom=%.0f %s" % [ms.x, ctrl.custom_minimum_size.x, root.get_path_to(ctrl)])

func _report_offscreen(root: Node, vp_size: Vector2) -> void :
    var stack: Array = [root]
    while not stack.is_empty():
        var n: Node = stack.pop_back()
        for c in n.get_children():
            stack.append(c)
        var ctrl: = n as Control
        if ctrl == null or not ctrl.is_visible_in_tree():
            continue
        var r: Rect2 = ctrl.get_global_rect()
        if r.size.x <= 1.0 or r.size.y <= 1.0:
            continue
        var over_left: float = - r.position.x
        var over_right: float = r.end.x - vp_size.x
        if over_left > 1.0 or over_right > 1.0:
            print("  OFFSCREEN x: %s rect=(%.0f,%.0f %.0fx%.0f) over_l=%.0f over_r=%.0f" % [
                root.get_path_to(ctrl), r.position.x, r.position.y, r.size.x, r.size.y, 
                maxf(over_left, 0.0), maxf(over_right, 0.0)])
