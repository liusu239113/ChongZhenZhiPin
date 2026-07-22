extends SceneTree

const DrawService = preload("res://scripts/services/lingwu_item_draw_service.gd")


class FakeState:
    extends RefCounted
    var lingwu: int

    func _init(initial_lingwu: int) -> void :
        lingwu = initial_lingwu


class UnavailableState:
    extends Node
    var lingwu: = 40
    var items: Array[String] = []
    var stats: = {"wentao": 10}

    func has_feature(_feature: String) -> bool:
        return false


func _init() -> void :
    var defs: = {
        "ordinary_a": {"name": "甲物"}, 
        "ordinary_b": {"name": "乙物"}, 
        "kuixing_fu": {"name": "魁星符"}, 
    }
    var failed: = false
    failed = not _assert_equal(
        DrawService.build_candidate_ids(defs, ["ordinary_a"], 0, 10, "kuixing_fu"), 
        ["ordinary_b"], 
        "普通道具未收齐时只返回未持有普通道具"
    ) or failed
    failed = not _assert_equal(
        DrawService.build_candidate_ids(defs, ["ordinary_a"], 9, 10, "kuixing_fu"), 
        ["ordinary_b"], 
        "普通道具未收齐时即使已有九张魁星符也只返回普通道具"
    ) or failed
    failed = not _assert_equal(
        DrawService.build_candidate_ids(defs, ["ordinary_a", "ordinary_b"], 0, 10, "kuixing_fu"), 
        ["kuixing_fu"], 
        "普通道具收齐后才返回魁星符"
    ) or failed
    failed = not _assert_equal(
        DrawService.build_candidate_ids(defs, ["ordinary_a", "ordinary_b"], 9, 10, "kuixing_fu"), 
        ["kuixing_fu"], 
        "魁星符九张时仍可取得"
    ) or failed
    failed = not _assert_equal(
        DrawService.build_candidate_ids(defs, ["ordinary_a", "ordinary_b"], 10, 10, "kuixing_fu"), 
        [], 
        "魁星符十张后候选池为空"
    ) or failed

    failed = not _assert_equal(
        SaveManager.calculate_kuixing_fu_total(3, 4), 
        7, 
        "当前局持有数应合并全局结局符与本局寻珍符"
    ) or failed
    failed = not _assert_equal(
        SaveManager.calculate_kuixing_fu_total(8, 5), 
        10, 
        "合并后的魁星符总数应封顶十张"
    ) or failed

    var insufficient_state: = FakeState.new(19)
    var insufficient: Dictionary = DrawService.settle_draw_cost(insufficient_state, ["ordinary_a"])
    failed = not _assert_equal(insufficient.get("status"), "insufficient", "余额不足时返回余额不足") or failed
    failed = not _assert_equal(insufficient_state.lingwu, 19, "余额不足时不扣识悟") or failed

    var empty_state: = FakeState.new(40)
    var refunded: Dictionary = DrawService.settle_draw_cost(empty_state, [])
    failed = not _assert_equal(refunded.get("status"), "refunded", "空池时返回已返还") or failed
    failed = not _assert_equal(empty_state.lingwu, 40, "空池时识悟余额保持原值") or failed

    var ready_state: = FakeState.new(40)
    var ready: Dictionary = DrawService.settle_draw_cost(ready_state, ["ordinary_a"])
    failed = not _assert_equal(ready.get("status"), "ready", "有候选且余额足够时事务可继续") or failed
    failed = not _assert_equal(ready_state.lingwu, 20, "成功事务只扣二十点识悟") or failed

    var unavailable_state: = UnavailableState.new()
    var unavailable: Dictionary = DrawService.draw(unavailable_state)
    failed = not _assert_equal(unavailable.get("status"), "unavailable", "不具备魁星功能时不可寻珍") or failed
    failed = not _assert_equal(unavailable_state.lingwu, 40, "不可用路线不扣识悟") or failed
    failed = not _assert_equal(unavailable_state.items, [], "不可用路线不改变行囊") or failed
    failed = not _assert_equal(unavailable_state.stats.get("wentao"), 10, "不可用路线不改变文韬") or failed

    quit(1 if failed else 0)


func _assert_equal(actual: Variant, expected: Variant, message: String) -> bool:
    if actual == expected:
        return true
    push_error("%s：实际 %s，预期 %s" % [message, actual, expected])
    return false
