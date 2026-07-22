extends Node

const EventService = preload("res://scripts/services/event_service.gd")
const EffectsService = preload("res://scripts/services/effects_service.gd")

func _ready():
    var gs = GameState
    gs.init_character("hanmen", [])
    gs.rank_index = 3
    gs.branch = ""
    gs.active_pending_event = {}
    gs.keju_status = "jinshi"
    gs.year = 16
    gs.month = 1
    gs.initialize_governance_city(6)
    print("is_governance_mode=", gs.is_governance_mode())
    print("city defaults liangshi=", gs.city.get("liangshi"), " pressure=", gs.city.get("liangshi_monthly_pressure"), " bingyong=", gs.city.get("bingyong"))
    gs.city["liangshi"] = 800
    gs.city["yinliang"] = 50000
    gs.update_monthly_breakdowns()
    print("monthly_grain_breakdown=", gs.monthly_grain_breakdown)
    print("monthly net grain=", gs.get_monthly_grain_net_change())
    print("BEFORE liangshi=", gs.city.get("liangshi"), " yinliang=", gs.city.get("yinliang"))

    var buy_idx = EventService._find_trade_card_index("tc_buy_grain")
    var tc = GameData.TRADE_CARDS[buy_idx]
    var ev = EventService._build_action_card_event(gs, tc, "trade")
    print("choice effects=", ev["choices"][0]["effects"])
    EffectsService.apply_choice(gs, ev["choices"][0], 0)
    print("AFTER BUY liangshi=", gs.city.get("liangshi"), " yinliang=", gs.city.get("yinliang"))

    gs.process_monthly_production()
    print("AFTER MONTH liangshi=", gs.city.get("liangshi"), " yinliang=", gs.city.get("yinliang"))
    get_tree().quit()
