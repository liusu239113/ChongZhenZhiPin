extends SceneTree

var failures: Array[String] = []

func _initialize() -> void :
    call_deferred("_run")

func _expect(condition: bool, message: String) -> void :
    if not condition:
        failures.append(message)

func _combined_text(node: Node) -> String:
    var result: = ""
    if node is Label:
        result += node.text
    for child in node.get_children():
        result += _combined_text(child)
    return result

func _run() -> void :
    var game_state: = root.get_node("GameState")
    var original_regions: Array = game_state.bianwu_defense_regions.duplicate(true)
    var original_enemies: Array = game_state.bianwu_defense_enemies.duplicate(true)
    game_state.bianwu_defense_regions = [
        {"id": "bw1_baoding_city", "name": "保定城", "allows_deployment": false, "facility": "府城"}, 
        {"id": "bw1_baihusuo", "name": "右卫百户所", "allows_deployment": true}, 
        {"id": "protected_outpost", "name": "旧寨", "allows_deployment": false, "type": "寨堡", "facility": "旧营垒"}, 
    ]
    game_state.bianwu_defense_enemies = []

    var screen: Control = load("res://scenes/game_screen.tscn").instantiate()
    root.add_child(screen)
    await process_frame
    _expect(screen._bianwu_region_id_exists("bw1_baoding_city"), "当前保定城编号应有效")
    _expect( not screen._bianwu_region_id_exists("old_region"), "已移除旧防区编号应无效")
    _expect(screen._resolved_bianwu_selected_region_id("bw1_baoding_city") == "bw1_baoding_city", "有效用户选择应保留")
    _expect(screen._resolved_bianwu_selected_region_id("old_region") == "bw1_baihusuo", "失效用户选择应回退默认可部署防区")

    var scroll: = ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(320, 120)
    var box: = VBoxContainer.new()
    scroll.add_child(box)
    screen.add_child(scroll)
    var filler: = Label.new()
    filler.text = "\n".repeat(80)
    box.add_child(filler)
    await process_frame
    scroll.scroll_vertical = 300
    await process_frame
    screen._show_bianwu_region_detail("bw1_baoding_city", box, screen)
    await process_frame
    await process_frame
    var detail_text: = _combined_text(box)
    _expect(scroll.scroll_vertical == 0, "防区详情切换并重排后应停在顶部")
    _expect(detail_text.begins_with("保定城城池"), "保定详情文本应从保定城标题和城池正文开始")
    screen._show_bianwu_region_detail("protected_outpost", box, screen)
    await process_frame
    await process_frame
    detail_text = _combined_text(box)
    _expect(detail_text.contains("此地由既有驻防体系管理，无须派驻本部兵马。"), "其他不可部署地区应显示通用驻防说明")
    _expect( not detail_text.contains("北直隶") and not detail_text.contains("大宁都司"), "其他不可部署地区不得误用保定专属史实")

    game_state.bianwu_defense_regions = original_regions
    game_state.bianwu_defense_enemies = original_enemies
    screen.free()
    if not failures.is_empty():
        for failure in failures:
            push_error(failure)
        quit(1)
        return
    print("test_bianwu_region_detail_state: ok")
    quit(0)
