extends SceneTree

const EventService = preload("res://scripts/services/event_service.gd")
const EffectsService = preload("res://scripts/services/effects_service.gd")

func _init():
    var gs = root.get_node("GameState")
    if gs == null:
        print("NO GAMESTATE")
        quit()
        return
    gs.init_character("hanmen", [])

    gs.rank_index = 3
    gs.branch = ""
    gs.active_pending_event = {}
    gs.keju_status = "jinshi"
    gs.year = 1
    gs.month = 9
    gs.initialize_governance_city(1)
    print("is_governance_mode=", gs.is_governance_mode())

    gs.city["liangshi"] = 200
    gs.city["yinliang"] = 5000
    gs.update_monthly_breakdowns()
    print("monthly_grain_breakdown=", gs.monthly_grain_breakdown)
    print("monthly net grain=", gs.get_monthly_grain_net_change())
    print("BEFORE liangshi=", gs.city.get("liangshi"), " yinliang=", gs.city.get("yinliang"))


    var buy_idx = EventService._find_trade_card_index("tc_buy_grain")
    var buy_card = gs.GameData.TRADE_CARDS[buy_idx] if false else null
    var card_def = load("res://scripts/game_data.gd")
    var GameData = root.get_node("GameData")
    var tc = GameData.TRADE_CARDS[buy_idx]
    var ev = EventService._build_action_card_event(gs, tc, "trade")
    print("choice effects=", ev["choices"][0]["effects"])
    EffectsService.apply_choice(gs, ev["choices"][0], 0)
    print("AFTER BUY liangshi=", gs.city.get("liangshi"), " yinliang=", gs.city.get("yinliang"))


    gs.process_monthly_production()
    print("AFTER MONTH liangshi=", gs.city.get("liangshi"), " yinliang=", gs.city.get("yinliang"))
    quit()
