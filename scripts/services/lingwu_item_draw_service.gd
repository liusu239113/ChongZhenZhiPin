extends RefCounted
class_name LingwuItemDrawService

const COST: = 20


static func build_candidate_ids(
    item_defs: Dictionary, 
    owned_items: Array, 
    kuixing_count: int, 
    kuixing_max: int, 
    kuixing_item_id: String
) -> Array:
    var ordinary_ids: Array[String] = []
    for raw_item_id in item_defs.keys():
        var item_id: = str(raw_item_id)
        if item_id == kuixing_item_id:
            continue
        if item_id not in owned_items:
            ordinary_ids.append(item_id)
    ordinary_ids.sort()
    if not ordinary_ids.is_empty():
        return ordinary_ids
    if kuixing_count < kuixing_max and item_defs.has(kuixing_item_id):
        return [kuixing_item_id]
    return []


static func settle_draw_cost(game_state: Variant, candidates: Array) -> Dictionary:
    if int(game_state.lingwu) < COST:
        return {"status": "insufficient", "cost": 0}
    if candidates.is_empty():
        return {"status": "refunded", "cost": 0}
    game_state.lingwu = maxi(0, int(game_state.lingwu) - COST)
    return {"status": "ready", "cost": COST}


static func draw(game_state: Node, forced_index: = -1) -> Dictionary:
    if not game_state.has_method("has_feature") or not game_state.has_feature("kuixing"):
        return {"status": "unavailable", "cost": 0}
    var root = Engine.get_main_loop().root
    var game_data = root.get_node_or_null("/root/GameData")
    var SaveManager = root.get_node_or_null("/root/SaveManager")
    var EffectsService = load("res://scripts/services/effects_service.gd")
    if game_data == null or SaveManager == null or EffectsService == null:
        return {"status": "unavailable", "cost": 0}
    var candidates: = build_candidate_ids(
        game_data.ITEM_DEFS, 
        game_state.items, 
        SaveManager.get_current_kuixing_fu_count(game_state), 
        SaveManager.KUIXING_FU_MAX_COUNT, 
        SaveManager.KUIXING_FU_ITEM_ID
    )
    var transaction: = settle_draw_cost(game_state, candidates)
    if str(transaction.get("status", "")) != "ready":
        return transaction

    var selected_index: = int(forced_index)
    if selected_index < 0 or selected_index >= candidates.size():
        selected_index = randi_range(0, candidates.size() - 1)
    var item_id: = str(candidates[selected_index])
    if item_id == SaveManager.KUIXING_FU_ITEM_ID:
        var kuixing_reward: Dictionary = SaveManager.add_run_kuixing_fu(game_state)
        if kuixing_reward.is_empty():
            _refund_cost(game_state)
            return {"status": "refunded", "cost": 0}
        game_state.apply_personal_stat_delta("wentao", 1)
        game_state.stats = game_state.stats.duplicate()
        _emit_state_changed(game_state)
        return {
            "status": "kuixing", 
            "item_id": item_id, 
            "count": int(kuixing_reward.get("count", 0)), 
            "cost": COST, 
        }

    var granted: bool = EffectsService.grant_item_once(game_state, item_id, true)
    if not granted:
        _refund_cost(game_state)
        return {"status": "refunded", "cost": 0}
    _emit_state_changed(game_state)
    return {
        "status": "item", 
        "item_id": item_id, 
        "cost": COST, 
    }


static func _refund_cost(game_state: Node) -> void :
    game_state.lingwu = int(game_state.lingwu) + COST


static func _emit_state_changed(game_state: Node) -> void :
    if game_state.has_signal("state_changed"):
        game_state.emit_signal("state_changed")
