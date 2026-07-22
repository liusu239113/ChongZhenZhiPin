extends SceneTree

var failures: = 0

func _initialize() -> void :
    call_deferred("_run")

func _check(condition: bool, message: String) -> void :
    if condition:
        return
    failures += 1
    push_error("test_bianwu_defense_service: " + message)

func _run() -> void :
    var state = root.get_node_or_null("GameState")
    var data = root.get_node_or_null("GameData")
    _check(state != null and data != null, "project autoloads should be available")
    var defense_service = load("res://scripts/services/bianwu_defense_service.gd")
    state.reset()
    state.active_line = "bianwu"
    data.activate_line("bianwu")
    state.char_id = "shijia"
    state.year = 1
    state.month = 1
    state.city = {"liangcao": 1000, "xiangyin": 500, "name": "保定卫所"}
    state.bianwu_units = [{"id": "spear", "name": "长枪手", "hp": 20}]
    defense_service.ensure_initialized(state)
    _check(state.bianwu_defense_regions.size() == 5, "first-volume map should have five regions")
    _check(state.bianwu_defense_roads.size() == 6, "first-volume map should have six roads")
    _check(defense_service.default_region_id(state) == "bw1_baihusuo", "first-volume default deployment region should be the right-guard hundred-household post")
    var baoding_city: Dictionary = state.bianwu_defense_regions[0]
    _check(str(baoding_city.get("id", "")) == "bw1_baoding_city", "Baoding city should be the protected first map region")
    _check( not defense_service.region_allows_deployment(baoding_city), "Baoding city should reject deployments")
    _check( not defense_service.region_counts_for_supply(baoding_city), "Baoding city should not contribute regional supply")
    var supply: Dictionary = defense_service.calculate_regional_supply(state)
    _check(supply.regions.size() == 4, "first-volume supply should include only the four direct-control regions")
    _check(int(supply.theoretical_grain) == 453, "first-volume theoretical grain should include four-region supply and the initialized clerk bonus")
    _check(int(supply.actual_grain) == 442, "first-volume actual grain should apply stability to the four supply regions")
    var move: Dictionary = defense_service.move_unit(state, 0, "bw1_juntun")
    _check(bool(move.get("ok", false)), "adjacent deployment should succeed")
    _check(state.bianwu_command_points == 0, "deployment should consume one command point")
    state.month = 3
    state.bianwu_defense_enemies = []
    defense_service.advance_enemy_entities(state)
    _check(str(state.bianwu_defense_enemies[0].get("region_id", "")) == "bw1_dunbao", "newly entered enemies should be shown before moving")
    state.month = 4
    defense_service.advance_enemy_entities(state)
    _check(str(state.bianwu_defense_enemies[0].get("region_id", "")) == "bw1_baihusuo", "visible enemies should move to the right-guard hundred-household post next month")
    state.month = 5
    defense_service.advance_enemy_entities(state)
    _check(str(state.bianwu_defense_enemies[0].get("region_id", "")) == "bw1_juntun", "visible enemies should continue along their displayed route")
    state.year = 4
    defense_service.ensure_initialized(state)
    _check(state.bianwu_defense_act == 2 and state.bianwu_defense_regions.size() == 5, "second volume should switch to its larger independent map")
    _check(str(state.bianwu_units[0].get("region_id", "")).begins_with("bw2_"), "units should enter the new volume map")
    _check(str(state.bianwu_defense_officers[0].get("region_id", "")).begins_with("bw2_"), "officers should enter the new volume map")
    state.active_line = "hanmen"
    data.activate_line("hanmen")
    var local_supply: Dictionary = defense_service.calculate_regional_supply(state)
    _check(int(local_supply.actual_grain) == 0, "local route should not receive defense supply")
    if failures > 0:
        print("test_bianwu_defense_service: failed (%d)" % failures)
        quit(1)
    else:
        print("test_bianwu_defense_service: ok")
        quit(0)
