extends SceneTree

class FakeState:
    extends Node
    var active_line: = "hanmen"
    var city: = {"yinliang": 10001, "liangshi": 8001}


func _assert_equal(actual: Variant, expected: Variant, label: String) -> void :
    if actual != expected:
        push_error("%s: expected %s, got %s" % [label, expected, actual])
        quit(1)


func _initialize() -> void :
    call_deferred("_run")


func _run() -> void :
    var effects_service = load("res://scripts/services/effects_service.gd")
    var state: = FakeState.new()
    root.add_child(state)
    var full_choice: = {
        "effects": {"yinliang": -1600, "liangshi": -900, "minwang": -10}, 
        "dynamicCourtLevy": {
            "ratePercent": 100, 
            "baseCosts": {"yinliang": 1600, "liangshi": 900}
        }
    }
    var full: Dictionary = effects_service.choice_effects_for_state(state, full_choice)
    _assert_equal(full["yinliang"], -7000, "rich silver floors seventy percent")
    _assert_equal(full["liangshi"], -5600, "rich grain floors seventy percent")
    _assert_equal(full["minwang"], -10, "unrelated effects stay unchanged")

    state.city = {"yinliang": 1000, "liangshi": 500}
    var poor: Dictionary = effects_service.choice_effects_for_state(state, full_choice)
    _assert_equal(poor["yinliang"], -1600, "silver uses event floor")
    _assert_equal(poor["liangshi"], -900, "grain uses event floor")

    state.city = {"yinliang": 12000, "liangshi": 8000}
    var half_choice: = full_choice.duplicate(true)
    half_choice["dynamicCourtLevy"]["ratePercent"] = 50
    var half: Dictionary = effects_service.choice_effects_for_state(state, half_choice)
    _assert_equal(half["yinliang"], -4200, "half delivery")
    _assert_equal(half["liangshi"], -2800, "half grain delivery")

    var retained_choice: = full_choice.duplicate(true)
    retained_choice["effects"]["yinliang"] = 700
    retained_choice["effects"]["liangshi"] = 800
    retained_choice["dynamicCourtLevy"]["ratePercent"] = 70
    var retained: Dictionary = effects_service.choice_effects_for_state(state, retained_choice)
    _assert_equal(retained["yinliang"], -5880, "retain thirty percent still deducts seventy percent")
    _assert_equal(retained["liangshi"], -3920, "retained grain never becomes a gain")

    state.active_line = "bianwu"
    var bianwu: Dictionary = effects_service.choice_effects_for_state(state, retained_choice)
    _assert_equal(bianwu["yinliang"], 700, "other routes keep original silver effect")
    _assert_equal(bianwu["liangshi"], 800, "other routes keep original grain effect")

    state.active_line = "hanmen"
    var grain_only: = {
        "effects": {"yinliang": -80, "liangshi": -5000}, 
        "dynamicCourtLevy": {"ratePercent": 100, "baseCosts": {"liangshi": 5000}}
    }
    var selective: Dictionary = effects_service.choice_effects_for_state(state, grain_only)
    _assert_equal(selective["yinliang"], -80, "unconfigured silver remains fixed")
    _assert_equal(selective["liangshi"], -5600, "configured grain becomes dynamic")
    print("dynamic_court_levy_probe: ok")
    quit(0)
