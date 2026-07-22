extends SceneTree

const Service = preload("res://scripts/services/bianwu_defense_service.gd")
const DeploymentController = preload("res://scripts/ui/bianwu_deployment_slot_controller.gd")
const BattleTypes = preload("res://scripts/battle/battle_types.gd")

class TestState extends Node:
    signal state_changed
    var active_line: = "bianwu"
    var year: = 1628
    var month: = 1
    var bianwu_units: Array = []
    var bianwu_unit_group_defs: Dictionary = {}
    var bianwu_defense_regions: Array = [
        {"id": "home", "name": "本营", "stability": 99, "control": "player", "base_grain": 180, "base_silver": 25}, 
        {"id": "north", "name": "北防区", "stability": 60, "control": "player", "base_grain": 180, "base_silver": 25}, 
    ]
    var bianwu_defense_roads: Array = [
        {"id": "home_north", "from": "home", "to": "north", "status": "open"}, 
    ]
    var bianwu_defense_officers: Array = []
    var bianwu_command_points: = 1
    var bianwu_command_cap: = 3
    var bianwu_defense_act: = 1
    var bianwu_defense_enemies: Array = []
    var bianwu_defense_warnings: Array = []
    var bianwu_defense_last_report: = {}
    var city: = {"liangcao": 10000, "xiangyin": 10000}
    var monthly_grain_breakdown: Array = []
    var monthly_silver_breakdown: Array = []
    var last_month_resource_delta: = {}

    func get_city_stat_level(_key: String) -> int:
        return 0

    func to_save_data() -> Dictionary:
        return {
            "bianwu_units": bianwu_units.duplicate(true), 
            "bianwu_unit_group_defs": bianwu_unit_group_defs.duplicate(true), 
        }

    func load_save_data(data: Dictionary) -> void :
        bianwu_units = data.get("bianwu_units", []).duplicate(true)
        bianwu_unit_group_defs = data.get("bianwu_unit_group_defs", {}).duplicate(true)

var failures: Array[String] = []

func _initialize() -> void :
    call_deferred("_run")

func _expect(condition: bool, message: String) -> void :
    if not condition:
        failures.append(message)

func _snapshot(state: TestState) -> String:
    return var_to_str({
        "units": state.bianwu_units, 
        "officers": state.bianwu_defense_officers, 
        "commands": state.bianwu_command_points, 
        "city": state.city, 
    })

func _card_ids(state: TestState) -> Array[String]:
    var ids: Array[String] = []
    for card in state.bianwu_units:
        ids.append(str(card.get("deployment_card_id", "")))
    return ids

func _test_split_and_normalize() -> void :
    var cards: = Service.split_unit_cards({"id": "spear", "hp": 1800, "region_id": "home"})
    _expect(cards.size() == 2, "一千八百兵力应拆为两卡")
    _expect(int(cards[0].hp) == 1000 and int(cards[1].hp) == 800, "一千八百兵力应拆为一千与八百")
    _expect(int(cards[0].hp) + int(cards[1].hp) == 1800, "拆卡后兵力总量必须守恒")

    var state: = TestState.new()
    state.bianwu_units = cards
    Service.normalize_unit_cards(state)
    var first_ids: = _card_ids(state)
    Service.normalize_unit_cards(state)
    _expect(_card_ids(state) == first_ids, "重复规范化必须保持卡号序列不变")
    state.free()

func _test_real_bianwu_new_game_initialization() -> void :
    var game_data: = root.get_node_or_null("GameData")
    var game_state: = root.get_node_or_null("GameState")
    _expect(game_data != null and game_state != null, "真实边务新游戏测试必须取得状态单例")
    if game_data == null or game_state == null:
        return
    game_data.activate_line("bianwu")
    game_state.selected_timeline = "chongzhen"
    game_state.init_character("shijia")
    game_state.active_line = "bianwu"
    game_state.initialize_governance_city(2)
    var total_by_kind: = {"guanjun": 0, "jiading": 0}
    for card in game_state.bianwu_units:
        var hp: = int(card.get("hp", 0))
        _expect(hp > 0 and hp <= 1000, "真实边务新游戏初始化后每张部队卡兵力必须在一至一千之间")
        var kind: = "jiading" if bool(card.get("is_jiading", false)) else "guanjun"
        total_by_kind[kind] = int(total_by_kind[kind]) + hp
    _expect(int(total_by_kind.guanjun) == int(game_state.city.get("guanjun", 0)), "真实边务新游戏官军拆卡后总量必须守恒")
    _expect(int(total_by_kind.jiading) == int(game_state.city.get("jiading", 0)), "真实边务新游戏家丁拆卡后总量必须守恒")
    _expect(int(total_by_kind.guanjun) > 1000 or int(total_by_kind.jiading) > 1000, "真实边务新游戏夹具必须覆盖超过一千兵力的初始化路径")

func _test_grant_units_uses_deployment_group_cards() -> void :
    var state: = TestState.new()
    state.bianwu_command_points = 2
    Service.grant_unit_group(state, "bow", BattleTypes.unit_def("bow"))
    _expect(state.bianwu_units.size() == 1, "剧情首次解锁弓弩手应建立一个编制且兵力不重复")
    var granted_group_id: = ""
    for card in state.bianwu_units:
        _expect(card is Dictionary, "剧情授予后的边务部队必须全部为分卡字典")
        if not card is Dictionary:
            continue
        granted_group_id = str(card.get("deployment_group_id", ""))
        _expect(int(card.get("hp", 0)) > 0 and int(card.get("hp", 0)) <= 1000, "剧情授予后的单卡兵力必须在一至一千之间")
        _expect( not granted_group_id.is_empty() and not str(card.get("deployment_card_id", "")).is_empty(), "剧情授予后的分卡必须有编制号与卡号")
        _expect(str(card.get("region_id", "")) == "home", "剧情授予的新兵种默认驻扎第一防区")
    var definition: Dictionary = state.bianwu_unit_group_defs.get(granted_group_id, {})
    _expect(str(definition.get("id", "")) == "bow" and str(definition.get("name", "")) == "弓弩手", "剧情授兵必须保存原兵种编号与名称")
    _expect(int(definition.get("level", 0)) == 1 and int(definition.get("cap", 0)) >= 600, "剧情授兵必须保存等级与兵力上限定义")
    var preview: = Service.preview_deployment(state, {"kind": "unit", "index": 0}, "north", "garrison")
    _expect(bool(preview.get("available", false)), "剧情授予的新兵种必须可进入真实调派预览")
    var assigned: = Service.assign_deployment(state, {"kind": "unit", "index": 0}, "north", "garrison")
    _expect(bool(assigned.get("ok", false)) and str(state.bianwu_units[0].get("region_id", "")) == "north", "剧情授予的新兵种必须可真实调派")
    var granted_snapshot: Array = state.bianwu_units.duplicate(true)
    Service.grant_unit_group(state, "bow", BattleTypes.unit_def("bow"))
    _expect(state.bianwu_units == granted_snapshot, "重复剧情授兵不得重复建立编制或增加兵力")
    var roundtrip: Dictionary = state.to_save_data()
    state.bianwu_units = []
    state.bianwu_unit_group_defs = {}
    state.load_save_data(roundtrip)
    var loaded_bow_cards: Array = state.bianwu_units.filter( func(card): return card is Dictionary and str(card.get("id", "")) == "bow")
    _expect(loaded_bow_cards.size() == 1 and int(loaded_bow_cards[0].get("hp", 0)) == 600, "剧情授兵分卡经过保存加载后必须完整保留")
    _expect(state.bianwu_unit_group_defs.get(granted_group_id, {}) == definition, "剧情授兵编制定义经过保存加载后必须完整保留")
    state.free()

func _test_duplicate_card_ids() -> void :
    var state: = TestState.new()
    state.bianwu_units = [
        {"id": "spear", "hp": 700, "deployment_group_id": "group_spear", "deployment_card_id": "group_spear_1"}, 
        {"id": "spear", "hp": 300, "deployment_group_id": "group_spear", "deployment_card_id": "group_spear_1"}, 
    ]
    Service.normalize_unit_cards(state)
    var first_ids: = _card_ids(state)
    _expect(first_ids.size() == 2 and first_ids[0] != first_ids[1], "重复卡号必须重新分配为全局唯一")
    Service.normalize_unit_cards(state)
    _expect(_card_ids(state) == first_ids, "去重后的卡号必须再次规范化幂等")
    state.free()

func _test_group_total_rebuild() -> void :
    var state: = TestState.new()
    state.bianwu_units = [
        {"id": "elite_spear", "name": "精锐长枪营", "level": 3, "hp": 1000, "cap": 5000, "is_jiading": false, "region_id": "home", "morale": 82, "order": "固守", "commander_id": "officer_a", "deployment_group_id": "group_spear", "deployment_card_id": "group_spear_1"}, 
        {"id": "elite_spear", "name": "精锐长枪营", "level": 3, "hp": 800, "cap": 5000, "is_jiading": false, "region_id": "north", "morale": 47, "order": "巡防", "commander_id": "officer_b", "deployment_group_id": "group_spear", "deployment_card_id": "group_spear_2"}, 
    ]
    Service.normalize_unit_cards(state)
    var persisted_definition: Dictionary = state.bianwu_unit_group_defs.get("group_spear", {})
    _expect(str(persisted_definition.get("id", "")) == "elite_spear" and int(persisted_definition.get("level", 0)) == 3, "规范化必须登记兵种静态定义")
    for instance_field in ["hp", "region_id", "morale", "order", "commander_id", "deployment_card_id"]:
        _expect( not persisted_definition.has(instance_field), "持久编制定义不得保存实例字段：%s" % instance_field)
    var first_identity: Dictionary = state.bianwu_units[0].duplicate(true)
    var second_identity: Dictionary = state.bianwu_units[1].duplicate(true)
    first_identity.erase("hp")
    second_identity.erase("hp")
    _expect(Service.set_unit_group_total(state, "group_spear", 2500), "设置兵种组总兵力应成功")
    _expect(state.bianwu_units.size() == 3, "两千五百兵力应重建为三张卡")
    var actual_first_identity: Dictionary = state.bianwu_units[0].duplicate(true)
    var actual_second_identity: Dictionary = state.bianwu_units[1].duplicate(true)
    actual_first_identity.erase("hp")
    actual_second_identity.erase("hp")
    _expect(actual_first_identity == first_identity, "扩兵时第一张既有卡的驻地与独立状态必须保留")
    _expect(actual_second_identity == second_identity, "扩兵时第二张既有卡的驻地与独立状态必须保留")
    _expect(str(state.bianwu_units[2].deployment_card_id) not in ["group_spear_1", "group_spear_2"], "扩兵只能在尾部生成新卡号")
    var total: = 0
    for card in state.bianwu_units:
        total += int(card.get("hp", 0))
    _expect(total == 2500, "重建兵种组后总兵力必须等于目标值")
    _expect(Service.add_unit_group_hp(state, "group_spear", -600), "兵种组增减应成功")
    total = 0
    for card in state.bianwu_units:
        total += int(card.get("hp", 0))
    _expect(total == 1900 and state.bianwu_units.size() == 2, "兵种组增减必须汇总后重建全部卡")
    actual_first_identity = state.bianwu_units[0].duplicate(true)
    actual_second_identity = state.bianwu_units[1].duplicate(true)
    actual_first_identity.erase("hp")
    actual_second_identity.erase("hp")
    _expect(actual_first_identity == first_identity and actual_second_identity == second_identity, "减兵只能删除尾卡且不得覆盖既有卡状态")
    _expect(Service.set_unit_group_total(state, "group_spear", 0), "兵力组应允许降至零")
    _expect(state.bianwu_units.is_empty(), "兵力归零后不得保留零兵占位卡")
    _expect(Service.add_unit_group_hp(state, "group_spear", 650), "空兵力组应能凭持久编制定义恢复")
    total = 0
    for card in state.bianwu_units:
        total += int(card.get("hp", 0))
    _expect(total == 650 and state.bianwu_units.size() == 1, "恢复后的卡组总兵力必须守恒")
    if not state.bianwu_units.is_empty():
        _expect(str(state.bianwu_units[0].id) == "elite_spear" and str(state.bianwu_units[0].name) == "精锐长枪营" and int(state.bianwu_units[0].level) == 3, "恢复卡必须保留精锐兵种与等级定义")
    state.active_line = "hanmen"
    var before: = _snapshot(state)
    _expect( not Service.add_unit_group_hp(state, "group_spear", 100) and _snapshot(state) == before, "非边务兵力组调用不得修改状态")
    state.free()

func _test_group_upgrade() -> void :
    var state: = TestState.new()
    state.bianwu_units = [
        {"id": "spear", "name": "长枪手", "level": 1, "hp": 1000, "cap": 5000, "family": "guanjun", "is_jiading": false, "region_id": "home", "morale": 76, "order": "固守", "commander_id": "officer_a", "deployment_group_id": "group_upgrade", "deployment_card_id": "group_upgrade_1"}, 
        {"id": "spear", "name": "长枪手", "level": 1, "hp": 800, "cap": 5000, "family": "guanjun", "is_jiading": false, "region_id": "north", "morale": 51, "order": "巡防", "commander_id": "officer_b", "deployment_group_id": "group_upgrade", "deployment_card_id": "group_upgrade_2"}, 
    ]
    Service.normalize_unit_cards(state)
    var preserved_fields: = ["hp", "region_id", "morale", "order", "commander_id", "deployment_card_id"]
    var before_instances: Array[Dictionary] = []
    for card in state.bianwu_units:
        var snapshot: = {}
        for field in preserved_fields:
            snapshot[field] = card.get(field)
        before_instances.append(snapshot)
    var elite_definition: = {"id": "elite_spear", "name": "精锐长枪营", "level": 4, "cap": 5000, "family": "guanjun", "attack": 88}
    _expect(Service.upgrade_unit_group(state, "spear", elite_definition), "有组编号兵种应整组升级")
    _expect(state.bianwu_units.size() == 2, "整组升级不得改变卡片数量")
    for index in range(state.bianwu_units.size()):
        var card: Dictionary = state.bianwu_units[index]
        _expect(str(card.get("id")) == "elite_spear" and str(card.get("name")) == "精锐长枪营" and int(card.get("level")) == 4, "整组每张卡都应替换兵种静态字段")
        for field in preserved_fields:
            _expect(card.get(field) == before_instances[index].get(field), "整组升级不得改变实例字段：%s" % field)
    var upgraded_definition: Dictionary = state.bianwu_unit_group_defs.get("group_upgrade", {})
    _expect(str(upgraded_definition.get("id", "")) == "elite_spear", "整组升级必须更新持久编制定义")
    _expect(upgraded_definition.has("is_jiading") and not bool(upgraded_definition.get("is_jiading", true)), "整组升级必须保留未覆盖的家丁属性")
    for instance_field in preserved_fields:
        _expect( not upgraded_definition.has(instance_field), "升级后的编制定义不得保存实例字段：%s" % instance_field)
    state.free()

func _test_set_unit_group_level_preserves_deployment_state() -> void :
    var state: = TestState.new()
    state.bianwu_units = [
        {"id": "spear", "name": "长枪手", "level": 1, "hp": 1000, "cap": 5000, "region_id": "home", "morale": 83, "supply": "充足", "order": "固守", "commander_id": "officer_a", "deployment_group_id": "group_training", "deployment_card_id": "group_training_1"}, 
        {"id": "spear", "name": "长枪手", "level": 1, "hp": 700, "cap": 5000, "region_id": "north", "morale": 46, "supply": "匮乏", "order": "巡防", "commander_id": "officer_b", "deployment_group_id": "group_training", "deployment_card_id": "group_training_2"}, 
    ]
    Service.normalize_unit_cards(state)
    var preserved_fields: = ["hp", "region_id", "morale", "supply", "order", "commander_id", "deployment_card_id"]
    var before: Array[Dictionary] = []
    for card in state.bianwu_units:
        var instance: = {}
        for field in preserved_fields:
            instance[field] = card.get(field)
        before.append(instance)
    _expect(Service.set_unit_group_level(state, "group_training", 3), "操练应通过服务更新整个兵种组")
    for index in range(state.bianwu_units.size()):
        var card: Dictionary = state.bianwu_units[index]
        _expect(int(card.get("level", 0)) == 3, "操练后同组所有分卡等级必须一致")
        for field in preserved_fields:
            _expect(card.get(field) == before[index].get(field), "操练不得改变部署实例字段：%s" % field)
    _expect(int(state.bianwu_unit_group_defs.get("group_training", {}).get("level", 0)) == 3, "操练必须同步持久编制等级定义")
    _expect(Service.set_unit_group_total(state, "group_training", 0), "操练后的兵种组应允许兵力降零")
    _expect(Service.add_unit_group_hp(state, "group_training", 650), "归零兵种组应能从编制等级定义恢复")
    _expect(state.bianwu_units.size() == 1 and int(state.bianwu_units[0].get("level", 0)) == 3, "归零再恢复后必须保持操练后的等级")
    state.free()

func _test_failure_atomicity_and_idempotent_assignment() -> void :
    var state: = TestState.new()
    state.bianwu_defense_officers = [
        {"id": "retainer", "name": "世家亲随", "specialty": "统带家丁", "region_id": "home"}, 
    ]
    state.active_line = "hanmen"
    var before: = _snapshot(state)
    Service.normalize_unit_cards(state)
    _expect(_snapshot(state) == before, "非边务规范化不得修改状态")
    var result: = Service.assign_officer_to_slot(state, 0, "north", "qinshui")
    _expect( not bool(result.ok) and _snapshot(state) == before, "非边务人物调派失败前后状态必须一致")
    result = Service.assign_deployment(state, {"kind": "unit", "index": 0}, "north", "garrison")
    _expect( not bool(result.ok) and _snapshot(state) == before, "非边务统一调派失败前后状态必须一致")

    state.active_line = "bianwu"
    state.bianwu_command_points = 0
    before = _snapshot(state)
    result = Service.assign_officer_to_slot(state, 0, "north", "qinshui")
    _expect( not bool(result.ok) and _snapshot(state) == before, "军令不足失败不得修改状态")

    state.bianwu_command_points = 1
    state.bianwu_defense_officers[0].region_id = "north"
    before = _snapshot(state)
    result = Service.assign_officer_to_slot(state, 0, "north", "qinshui")
    _expect(bool(result.ok) and _snapshot(state) == before, "人物重复派驻目标防区应幂等且不扣军令")

    state.bianwu_defense_officers.append({"id": "clerk", "name": "粮台书办", "specialty": "转运粮饷", "region_id": "north"})
    before = _snapshot(state)
    result = Service.assign_deployment(state, {"kind": "officer", "index": 0}, "north", "shuban")
    _expect( not bool(result.ok) and _snapshot(state) == before, "同防区亲随不得因幂等判断绕过类型校验进入书办槽")
    result = Service.assign_deployment(state, {"kind": "officer", "index": 1}, "north", "qinshui")
    _expect( not bool(result.ok) and _snapshot(state) == before, "同防区书办不得因幂等判断绕过类型校验进入亲随槽")

    state.bianwu_defense_officers[0].region_id = "home"
    before = _snapshot(state)
    result = Service.assign_officer_to_slot(state, 0, "north", "shuban")
    _expect( not bool(result.ok) and _snapshot(state) == before, "槽位类型错误不得修改状态")
    result = Service.assign_deployment(state, {"kind": "officer", "index": 0}, "north", "unknown")
    _expect( not bool(result.ok) and _snapshot(state) == before, "未知槽位不得修改状态")
    state.free()

func _test_deployment_preview_and_atomic_officer_replacement() -> void :
    var state: = TestState.new()
    state.bianwu_units = [{"id": "spear", "name": "长枪营", "hp": 800, "morale": 70, "region_id": "home"}]
    state.bianwu_defense_officers = [
        {"id": "old_retainer", "name": "旧亲随", "specialty": "统带家丁", "region_id": "north"}, 
        {"id": "new_retainer", "name": "新亲随", "specialty": "统带家丁", "region_id": "home"}, 
    ]
    var before: = _snapshot(state)
    var preview: = Service.preview_deployment(state, {"kind": "unit", "index": 0}, "north", "garrison")
    _expect(bool(preview.available) and int(preview.command_cost) == 1 and int(preview.grain_cost) == 160, "八百兵力调防预览应显示军令一与粮草一百六十")
    _expect(_snapshot(state) == before, "调派预览不得修改任何状态")
    state.city.liangcao = 100
    preview = Service.preview_deployment(state, {"kind": "unit", "index": 0}, "north", "garrison")
    _expect( not bool(preview.available) and str(preview.reason).contains("粮草不足"), "粮草不足时预览应给出真实不可用原因")
    state.city.liangcao = 10000

    var result: = Service.assign_deployment(state, {"kind": "officer", "index": 1, "replace_existing": true}, "north", "qinshui")
    _expect(bool(result.ok), "显式更换应允许另一名同类人物进入已占槽")
    _expect(str(state.bianwu_defense_officers[0].region_id) == "home", "更换后原人物应调回边务主防区")
    _expect(str(state.bianwu_defense_officers[1].region_id) == "north", "更换后新人物应进入目标槽")
    _expect(state.bianwu_command_points == 0, "人物更换只应扣除一次军令")

    state.bianwu_defense_officers[0].region_id = "north"
    state.bianwu_defense_officers[1].region_id = "home"
    state.bianwu_command_points = 0
    before = _snapshot(state)
    result = Service.assign_deployment(state, {"kind": "officer", "index": 1, "replace_existing": true}, "north", "qinshui")
    _expect( not bool(result.ok) and _snapshot(state) == before, "军令不足的人物更换必须保持人物与军令完全不变")
    state.free()

func _test_monthly_officer_effects() -> void :
    var state: = TestState.new()
    state.bianwu_defense_officers = [
        {"id": "retainer", "name": "世家亲随", "specialty": "统带家丁", "region_id": "north"}, 
        {"id": "second_retainer", "name": "另一亲随", "specialty": "统带家丁", "region_id": "north"}, 
        {"id": "clerk", "name": "粮台书办", "specialty": "转运粮饷", "region_id": "north"}, 
    ]
    var effects: = Service.apply_monthly_officer_effects(state)
    _expect(int(state.bianwu_defense_regions[1].stability) == 62, "同一防区即使有多名亲随每月也只能增加两点安定度")
    _expect(int(effects.get("qinshui_regions", 0)) == 1, "亲随月效应应按防区去重计数")
    state.bianwu_defense_regions[1].stability = 99
    Service.apply_monthly_officer_effects(state)
    _expect(int(state.bianwu_defense_regions[1].stability) == 100, "亲随安定度加成最高不得超过一百")
    state.bianwu_defense_officers[0].region_id = "home"
    state.bianwu_defense_officers[1].region_id = "home"
    Service.apply_monthly_officer_effects(state)
    _expect(int(state.bianwu_defense_regions[1].stability) == 100, "亲随移走后原防区不得继续增加安定度")

    state.bianwu_defense_regions[0].stability = 60
    state.bianwu_defense_regions[1].stability = 60
    var original_regions: = state.bianwu_defense_regions.duplicate(true)
    var supply: = Service.calculate_regional_supply(state)
    _expect(int(supply.shuban_grain_bonus) == 27 and int(supply.shuban_silver_bonus) == 4, "书办应将一百八十粮与二十五银分别取整增加二十七粮与四银")
    _expect(int(supply.actual_grain) == 387 and int(supply.actual_silver) == 54, "书办加成应进入本月最终供量")
    _expect(state.bianwu_defense_regions == original_regions, "计算书办供量不得写回防区基础字段")
    var repeated_supply: = Service.calculate_regional_supply(state)
    _expect(repeated_supply == supply and state.bianwu_defense_regions == original_regions, "重复计算供量不得复利或修改基础字段")
    Service.append_supply_breakdowns(state)
    _expect(state.monthly_grain_breakdown.any( func(entry): return str(entry.get("label", "")) == "书办转运粮草" and int(entry.get("value", 0)) == 27), "粮草明细应单列书办转运加成")
    _expect(state.monthly_silver_breakdown.any( func(entry): return str(entry.get("label", "")) == "书办转运饷银" and int(entry.get("value", 0)) == 4), "饷银明细应单列书办转运加成")
    state.bianwu_defense_officers[2].region_id = "home"
    var moved_supply: = Service.calculate_regional_supply(state)
    _expect(int(moved_supply.shuban_grain_bonus) == 27 and int(moved_supply.shuban_silver_bonus) == 4, "书办移走后加成应随人物转移并从原防区消失")
    _expect(int(moved_supply.regions[0].shuban_grain_bonus) == 27 and int(moved_supply.regions[1].shuban_grain_bonus) == 0, "书办加成逐防区明细应随调派位置转移")

    state.active_line = "hanmen"
    var before: = _snapshot(state)
    effects = Service.apply_monthly_officer_effects(state)
    supply = Service.calculate_regional_supply(state)
    _expect(_snapshot(state) == before and effects.is_empty(), "非边务路线不得应用人物月度效应")
    _expect(int(supply.actual_grain) == 0 and int(supply.actual_silver) == 0, "非边务路线不得产生防区供量")
    state.free()

func _test_protected_baoding_city_rules() -> void :
    var state: = TestState.new()
    state.bianwu_defense_regions = [
        {"id": "bw1_baoding_city", "name": "保定城", "stability": 78, "control": "court", "base_grain": 0, "base_silver": 0, "allows_deployment": false, "counts_for_supply": false}, 
        {"id": "bw1_baihusuo", "name": "百户所", "stability": 72, "control": "player", "base_grain": 120, "base_silver": 55, "allows_deployment": true, "counts_for_supply": true}, 
    ]
    state.bianwu_defense_roads = [
        {"id": "bw1_baoding_baihusuo", "from": "bw1_baoding_city", "to": "bw1_baihusuo", "status": "open"}, 
    ]
    state.bianwu_units = [
        {"id": "spear", "name": "长枪手", "hp": 700, "region_id": "bw1_baihusuo", "morale": 65, "supply": "充足", "commander_id": "", "order": "驻防", "deployment_group_id": "group_spear", "deployment_card_id": "group_spear_1"}, 
    ]
    state.bianwu_defense_officers = [
        {"id": "bw_officer_qinbing", "name": "顾承武", "role": "武官", "relation": "顾氏族叔", "specialty": "统带家丁", "monthly_effect": "每月：防区安定度 +2", "loyalty": 78, "region_id": "bw1_baihusuo", "assigned_unit_id": "knife_shield"}, 
    ]
    state.bianwu_command_points = 2
    state.city["liangcao"] = 1800
    var before: = _snapshot(state)
    var unit_preview: = Service.preview_deployment(state, {"kind": "unit", "index": 0}, "bw1_baoding_city", "garrison")
    var officer_preview: = Service.preview_deployment(state, {"kind": "officer", "index": 0}, "bw1_baoding_city", "qinshui")
    _expect( not bool(unit_preview.get("available", false)) and str(unit_preview.get("reason", "")) == "保定城已有都司与诸卫驻军，无须派驻本部兵马。", "保定城必须拒绝部队调派并返回完整说明")
    _expect( not bool(officer_preview.get("available", false)) and str(officer_preview.get("reason", "")) == "保定城已有都司与诸卫驻军，无须派驻本部兵马。", "保定城必须拒绝人物调派并返回完整说明")
    _expect(_snapshot(state) == before, "保定城调派预览不得修改任何状态")
    var unit_assignment: = Service.assign_deployment(state, {"kind": "unit", "index": 0}, "bw1_baoding_city", "garrison")
    _expect( not bool(unit_assignment.get("ok", false)) and str(unit_assignment.get("message", "")) == "保定城已有都司与诸卫驻军，无须派驻本部兵马。", "统一调派入口必须拒绝部队进入保定城")
    _expect(_snapshot(state) == before, "统一部队调派失败不得修改状态")
    var officer_assignment: = Service.assign_deployment(state, {"kind": "officer", "index": 0}, "bw1_baoding_city", "qinshui")
    _expect( not bool(officer_assignment.get("ok", false)) and str(officer_assignment.get("message", "")) == "保定城已有都司与诸卫驻军，无须派驻本部兵马。", "统一调派入口必须拒绝人物进入保定城")
    _expect(_snapshot(state) == before, "统一人物调派失败不得修改状态")
    var legacy_assignment: = Service.assign_officer(state, 0, "bw1_baoding_city")
    _expect( not bool(legacy_assignment.get("ok", false)) and str(legacy_assignment.get("message", "")) == "保定城已有都司与诸卫驻军，无须派驻本部兵马。", "兼容人物调派入口必须拒绝人物进入保定城")
    _expect(_snapshot(state) == before, "兼容人物调派失败不得修改状态")
    var supply: = Service.calculate_regional_supply(state)
    _expect(int(supply.get("theoretical_grain", 0)) == 120 and int(supply.get("theoretical_silver", 0)) == 55, "保定城不得计入理论粮饷供给")
    _expect(int(supply.get("actual_grain", 0)) == 120 and int(supply.get("actual_silver", 0)) == 55, "百户所安稳时实际粮饷供给必须等于一百二十与五十五")
    _expect(Service.default_region_id(state) == "bw1_baihusuo", "默认驻防区必须选择首个允许部署的玩家防区")
    state.free()

func _test_normalize_protected_city_occupants_home() -> void :
    var state: = TestState.new()
    state.bianwu_defense_regions = [
        {"id": "bw1_baoding_city", "name": "保定城", "stability": 78, "control": "court", "base_grain": 0, "base_silver": 0, "allows_deployment": false, "counts_for_supply": false}, 
        {"id": "bw1_baihusuo", "name": "百户所", "stability": 72, "control": "player", "base_grain": 120, "base_silver": 55, "allows_deployment": true, "counts_for_supply": true}, 
    ]
    state.bianwu_defense_roads = [
        {"id": "bw1_baoding_baihusuo", "from": "bw1_baoding_city", "to": "bw1_baihusuo", "status": "open"}, 
    ]
    state.bianwu_units = [
        {"id": "spear", "name": "长枪手", "hp": 700, "region_id": "bw1_baoding_city", "deployment_group_id": "group_spear", "deployment_card_id": "group_spear_1"}, 
        {"id": "bow", "name": "弓弩手", "hp": 300, "region_id": "missing_region", "deployment_group_id": "group_bow", "deployment_card_id": "group_bow_1"}, 
    ]
    state.bianwu_defense_officers = [
        {"id": "bw_officer_qinbing", "name": "顾承武", "specialty": "统带家丁", "region_id": "bw1_baoding_city"}, 
        {"id": "bw_officer_liangtai", "name": "沈维钧", "specialty": "转运粮饷", "region_id": "missing_region"}, 
    ]
    var original_unit_total: = 0
    for unit in state.bianwu_units:
        original_unit_total += int(unit.get("hp", 0))
    var original_officer_ids: = state.bianwu_defense_officers.map( func(officer): return str(officer.get("id", "")))
    Service.normalize_saved_state(state)
    var normalized_unit_total: = 0
    for unit in state.bianwu_units:
        normalized_unit_total += int(unit.get("hp", 0))
        _expect(str(unit.get("region_id", "")) == "bw1_baihusuo", "禁止部署或不存在的部队驻地必须迁回百户所")
    _expect(normalized_unit_total == original_unit_total, "驻地规范化不得改变总兵力")
    _expect(state.bianwu_defense_officers.map( func(officer): return str(officer.get("id", ""))) == original_officer_ids, "驻地规范化不得改变人物身份")
    for officer in state.bianwu_defense_officers:
        _expect(str(officer.get("region_id", "")) == "bw1_baihusuo", "禁止部署或不存在的人物驻地必须迁回百户所")
    var effects: = Service.apply_monthly_officer_effects(state)
    _expect(int(effects.get("qinshui_regions", 0)) == 1, "迁回百户所的亲随必须在新驻地生效")
    _expect(int(state.bianwu_defense_regions[0].get("stability", 0)) == 78, "保定城不得因残留人物获得安定加值")
    _expect(int(state.bianwu_defense_regions[1].get("stability", 0)) == 74, "亲随迁回后百户所应获得安定加值")
    state.free()

func _test_monthly_production_snapshot_precedes_enemy_advance() -> void :
    var state: = root.get_node_or_null("GameState")
    var game_data: = root.get_node_or_null("GameData")
    _expect(state != null and game_data != null, "完整边务月结测试必须取得生产状态单例")
    if state == null or game_data == null:
        return
    game_data.activate_line("bianwu")
    state.active_line = "bianwu"
    state.bianwu_defense_act = state.get_current_governance_act()
    state.bianwu_defense_regions = [
        {"id": "home", "name": "本营", "stability": 60, "control": "player", "base_grain": 0, "base_silver": 0}, 
        {"id": "north", "name": "北防区", "stability": 59, "control": "player", "base_grain": 180, "base_silver": 25}, 
    ]
    state.bianwu_defense_roads = [{"id": "home_north", "from": "home", "to": "north", "status": "open"}]
    state.bianwu_defense_officers = [
        {"id": "retainer", "name": "世家亲随", "specialty": "统带家丁", "region_id": "north"}, 
        {"id": "clerk", "name": "粮台书办", "specialty": "转运粮饷", "region_id": "north"}, 
    ]
    state.bianwu_defense_enemies = [
        {"id": "enemy", "region_id": "home", "target_region_id": "north", "route": ["north"], "route_index": 0, "spawn_month_index": -1}, 
    ]
    state.bianwu_units = []
    state.city = {"liangcao": 1000, "xiangyin": 1000}
    state.process_monthly_production()
    var grain_total: = 0
    for entry in state.monthly_grain_breakdown:
        grain_total += int(entry.get("value", 0))
    var silver_total: = 0
    for entry in state.monthly_silver_breakdown:
        silver_total += int(entry.get("value", 0))
    _expect(int(state.bianwu_defense_regions[1].stability) == 61, "亲随应在本月供量计算前令临界安定度跨档")
    _expect(int(state.city.liangcao) - 1000 == grain_total and grain_total == 407, "本月粮草入账应等于全部明细合计且书办只加一次")
    _expect(int(state.city.xiangyin) - 1000 == silver_total and silver_total == 109, "本月饷银入账应等于全部明细合计且书办只加一次")
    _expect(int(state.bianwu_defense_last_report.get("actual_grain", 0)) == 207 and int(state.bianwu_defense_last_report.get("actual_silver", 0)) == 29, "保存的边务供量快照应等于本月防区应供入账")
    var settled_report: Dictionary = state.bianwu_defense_last_report.duplicate(true)
    Service.process_month_end(state)
    _expect(int(state.bianwu_defense_regions[1].stability) == 55, "月末敌军推进后不得再次执行亲随加成")
    _expect(state.bianwu_defense_last_report == settled_report, "敌军推进与安定度变化不得覆盖本月已入账供量快照")

func _test_deployment_controller_renders_slots() -> void :
    var game_state: = root.get_node_or_null("GameState")
    _expect(game_state != null, "部署卡槽测试必须取得状态单例")
    if game_state == null:
        return
    game_state.active_line = "bianwu"
    game_state.bianwu_defense_regions = [{"id": "home", "name": "本营"}, {"id": "north", "name": "北防区"}]
    game_state.bianwu_defense_act = game_state.get_current_governance_act()
    game_state.bianwu_defense_roads = [{"id": "home_north", "from": "home", "to": "north", "status": "open"}]
    game_state.bianwu_units = [{"id": "spear", "name": "长枪营", "hp": 800, "morale": 70, "supply": "充足", "region_id": "home"}]
    game_state.bianwu_defense_officers = [
        {"id": "retainer", "name": "世家亲随", "specialty": "统带家丁", "loyalty": 65, "region_id": "north"}, 
        {"id": "second_retainer", "name": "另一亲随", "specialty": "统带家丁", "loyalty": 61, "region_id": "home"}, 
        {"id": "clerk", "name": "粮台书办", "specialty": "转运粮饷", "loyalty": 62, "region_id": "home"}, 
    ]
    var host: = Control.new()
    root.add_child(host)
    var scroll: = ScrollContainer.new()
    var box: = VBoxContainer.new()
    host.add_child(scroll)
    scroll.add_child(box)
    var controller = DeploymentController.new(host)
    controller.render_region_slots("north", box, host, scroll)
    var rendered_text: = _control_text(box)
    for title in ["驻军", "将官", "武官", "书办"]:
        _expect(rendered_text.contains(title), "部署卡槽应显示标题：%s" % title)
    _expect(box.get_child_count() >= 5, "部署卡槽应构造驻军空卡与两个人物槽")
    controller.call("_open_candidates", "qinshui", 0)
    var popup: = host.get_node_or_null("BianwuDeploymentCandidates")
    _expect(popup != null, "点击已填人物槽应构造高层候选弹窗")
    if popup != null:
        var popup_buttons: = popup.find_children("*", "Button", true, false)
        for popup_button in popup_buttons:
            _expect( not popup_button.get_signal_connection_list("gui_input").is_empty(), "候选弹窗每个可点击按钮都应转发触摸拖动")
        var popup_text: = _control_text(popup)
        _expect(popup_text.contains("更换现任"), "已占人物槽候选应明确显示更换语义")
        _expect(popup_text.contains("成本：军令1"), "人物候选应显示服务预览返回的真实军令成本")
        _expect(popup_text.contains("撤回边务主防区") and popup_text.contains("关闭"), "已填槽弹窗应提供撤回与关闭按钮")
    host.free()

func _test_protected_baoding_city_renders_no_slots() -> void :
    var game_state: = root.get_node_or_null("GameState")
    _expect(game_state != null, "保定城卡槽测试必须取得真实状态单例")
    if game_state == null:
        return
    var original_regions: Array = game_state.bianwu_defense_regions.duplicate(true)
    game_state.bianwu_defense_regions = [
        {"id": "bw1_baoding_city", "name": "保定城", "allows_deployment": false}, 
    ]
    var host: = Control.new()
    root.add_child(host)
    var box: = VBoxContainer.new()
    host.add_child(box)
    var controller = DeploymentController.new(host)
    controller.render_region_slots("bw1_baoding_city", box, host)
    _expect(box.get_child_count() == 0, "保定城禁止部署时不得渲染任何驻军或将官槽")
    game_state.bianwu_defense_regions = original_regions
    host.free()

func _test_deployment_controller_empty_and_unavailable_states() -> void :
    var game_state: = root.get_node_or_null("GameState")
    _expect(game_state != null, "部署空态测试必须取得状态单例")
    if game_state == null:
        return
    game_state.active_line = "bianwu"
    game_state.bianwu_defense_regions = [{"id": "home", "name": "本营"}, {"id": "north", "name": "北防区"}]
    game_state.bianwu_defense_act = game_state.get_current_governance_act()
    game_state.bianwu_defense_roads = []
    game_state.bianwu_units = [{"id": "spear", "name": "长枪营", "hp": 800, "morale": 70, "supply": "充足", "region_id": "home"}]
    game_state.bianwu_defense_officers = []
    game_state.bianwu_command_points = 1
    game_state.city["liangcao"] = 1000
    var host: = Control.new()
    root.add_child(host)
    var detail_scroll: = ScrollContainer.new()
    var detail_box: = VBoxContainer.new()
    host.add_child(detail_scroll)
    detail_scroll.add_child(detail_box)
    var controller = DeploymentController.new(host)
    controller.render_region_slots("north", detail_box, host, detail_scroll)
    controller.call("_open_candidates", "shuban", -1)
    var popup: = host.get_node_or_null("BianwuDeploymentCandidates")
    _expect(popup != null and _control_text(popup).contains("暂无可调派对象"), "无匹配人物时候选弹窗应显示暂无可调派对象")
    if popup != null:
        popup.free()
    controller.call("_open_candidates", "garrison", -1)
    popup = host.get_node_or_null("BianwuDeploymentCandidates")
    _expect(popup != null and _control_text(popup).contains("没有可通行道路"), "道路中断时候选项应显示道路不可用原因")
    if popup != null:
        popup.free()
    game_state.bianwu_defense_roads = [{"id": "home_north", "from": "home", "to": "north", "status": "open"}]
    game_state.city["liangcao"] = 0
    controller.call("_open_candidates", "garrison", -1)
    popup = host.get_node_or_null("BianwuDeploymentCandidates")
    _expect(popup != null and _control_text(popup).contains("粮草不足"), "粮草不足时候选项应显示粮草不可用原因")
    if popup != null:
        popup.free()
    game_state.city["liangcao"] = 1000
    game_state.bianwu_command_points = 0
    controller.call("_open_candidates", "garrison", -1)
    popup = host.get_node_or_null("BianwuDeploymentCandidates")
    _expect(popup != null and _control_text(popup).contains("军令已用尽"), "军令不足时候选项应显示军令不可用原因")
    host.free()

func _control_text(control: Node) -> String:
    var combined: = ""
    if control is Label or control is Button:
        combined += str(control.text)
    for child in control.get_children():
        combined += _control_text(child)
    return combined

func _run() -> void :
    _test_split_and_normalize()
    _test_real_bianwu_new_game_initialization()
    _test_grant_units_uses_deployment_group_cards()
    _test_duplicate_card_ids()
    _test_group_total_rebuild()
    _test_group_upgrade()
    _test_set_unit_group_level_preserves_deployment_state()
    _test_failure_atomicity_and_idempotent_assignment()
    _test_deployment_preview_and_atomic_officer_replacement()
    _test_monthly_officer_effects()
    _test_protected_baoding_city_rules()
    _test_normalize_protected_city_occupants_home()
    _test_monthly_production_snapshot_precedes_enemy_advance()
    _test_deployment_controller_renders_slots()
    _test_protected_baoding_city_renders_no_slots()
    _test_deployment_controller_empty_and_unavailable_states()
    if not failures.is_empty():
        for failure in failures:
            push_error(failure)
        quit(1)
        return
    print("test_bianwu_deployment_slots: ok")
    quit(0)
