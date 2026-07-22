extends SceneTree


const BattleModel: = preload("res://scripts/battle/battle_model.gd")

func _init() -> void :
    var fails: = 0
    fails += _test_auto_resolve()
    fails += _test_manual_annihilate()
    fails += _test_hold_objective()
    fails += _test_five_slot_locked_deployment()
    fails += _test_elite_and_skill()
    fails += _test_ammo_depletion()
    fails += _test_cavalry_charge_horse()
    fails += _test_no_reserve_auto_refill()
    fails += _test_retreat_skill()
    fails += _test_pull_and_guard()
    fails += _test_timeout_field_grade()
    fails += _test_annihilate_timeout_with_enemy_alive_is_fail()
    fails += _test_grade_full_annihilate_zero_loss_is_great()
    fails += _test_grade_by_unit_losses()
    fails += _test_rotate_formation_ring()
    fails += _test_back_row_participation()
    fails += _test_back_row_promotion()
    fails += _test_column_fallback_penalty()
    fails += _test_custom_hp_deployment()
    if fails == 0:
        print("BATTLE TEST: ALL PASS")
    else:
        printerr("BATTLE TEST: %d FAIL" % fails)
    quit(fails)

func _run_manual(m: BattleModel, max_rounds: int = 20, rotate_each: = false) -> String:
    var guard: = 0
    while not m.finished and guard < max_rounds:
        guard += 1
        m.turn += 1
        m.engage_phase()
        m.resolve_phase()
        m.check_finished()
    return m.result_grade

func _test_auto_resolve() -> int:
    var m: = BattleModel.new()
    m.setup({
        "terrain": "plain", "wulue": 70, "intel": 2, 
        "front_slots": 4, 
        "player_units": ["spear", "knife_shield", "bow", "musket"], 
        "enemy_units": ["bow", "bow"], 
    })
    var g: = m.auto_resolve(1.0)
    var ok: = g == "great"
    print("  auto_resolve(强我方) -> %s  [%s]" % [g, "OK" if ok else "EXPECT great"])
    return 0 if ok else 1

func _test_manual_annihilate() -> int:
    var m: = BattleModel.new()
    m.setup({
        "terrain": "plain", "wulue": 60, "front_slots": 3, 
        "objective": {"type": "annihilate"}, 
        "player_units": ["spear", "knife_shield", "cavalry", "bow"], 
        "enemy_units": ["bow", "knife_shield"], 
    })
    var g: = _run_manual(m)
    var ok: = m.finished and g in ["great", "pyrrhic", "fail"]
    print("  manual 歼灭 -> %s (回合 %d)  [%s]" % [g, m.turn, "OK" if ok else "FAIL"])
    return 0 if ok else 1

func _test_hold_objective() -> int:
    var m: = BattleModel.new()
    m.setup({
        "terrain": "siege", "wulue": 55, "front_slots": 3, 
        "objective": {"type": "hold", "turns": 5}, 
        "player_units": ["knife_shield", "spear", "bow", "knife_shield"], 
        "enemy_units": ["cavalry", "cavalry", "bow", "cavalry"], 
    })
    var g: = _run_manual(m, 12, true)
    var ok: = m.finished and g != ""
    print("  manual 守住5回合 -> %s (回合 %d)  [%s]" % [g, m.turn, "OK" if ok else "FAIL"])
    return 0 if ok else 1

func _test_five_slot_locked_deployment() -> int:
    var m: = BattleModel.new()
    m.setup({
        "front_slots": 5, 
        "player_units": ["musket", "knife_shield", "spear", "bow", "cavalry", "cannon"], 
        "enemy_units": ["knife_shield"], 
    })
    var rear = m.player_front[4]
    var overflow_dropped: = m.player_reserve.is_empty()
    var ok: = rear != null and str(rear.get("id", "")) == "cavalry" and overflow_dropped
    print("  五格锁定部署 -> 后翼=%s 超编不上场=%s  [%s]" % [str(rear.get("id", "")) if rear != null else "空", overflow_dropped, "OK" if ok else "FAIL"])
    return 0 if ok else 1

func _test_elite_and_skill() -> int:

    var m: = BattleModel.new()
    m.setup({
        "terrain": "siege", "wulue": 65, "front_slots": 3, 
        "objective": {"type": "annihilate"}, 
        "player_units": ["baigan", "langxian", "redcannon", "guanning"], 
        "enemy_units": ["cavalry", "knife_shield", "bow"], 
        "skills": ["pingjian"], 
    })
    m.morale = 100
    var used: = m.use_skill("pingjian")
    var g: = _run_manual(m)
    var ok: = used and m.finished and g != ""
    print("  精锐+将令 -> 用将令=%s 结果=%s  [%s]" % [used, g, "OK" if ok else "FAIL"])
    return 0 if ok else 1

func _test_ammo_depletion() -> int:

    var m: = BattleModel.new()
    m.setup({
        "front_slots": 1, "ammo": 1, 
        "player_units": ["musket"], 
        "enemy_units": ["knife_shield", "knife_shield", "knife_shield"], 
    })
    m.turn += 1
    var ev1: = m.engage_phase()
    var fired: = ev1.any( func(e): return bool(e.get("player", false)))
    m.player_front[0]["reload_left"] = 0
    var ev2: = m.engage_phase()
    var silent: = not ev2.any( func(e): return bool(e.get("player", false)))
    var ok: = fired and m.ammo == 0 and silent
    print("  弹药耗尽哑火 -> fired=%s ammo=%d silent=%s  [%s]" % [fired, m.ammo, silent, "OK" if ok else "FAIL"])
    return 0 if ok else 1

func _test_cavalry_charge_horse() -> int:

    var m: = BattleModel.new()
    m.setup({
        "front_slots": 1, "horse": 1, 
        "player_units": ["cavalry"], 
        "enemy_units": ["knife_shield", "knife_shield"], 
    })
    m.turn += 1
    var ev1: = m.engage_phase()
    var charged: = ev1.any( func(e): return bool(e.get("player", false)) and bool(e.get("charge", false)))
    var ev2: = m.engage_phase()
    var no_charge: = not ev2.any( func(e): return bool(e.get("player", false)) and bool(e.get("charge", false)))
    var ok: = charged and m.horse == 0 and no_charge
    print("  骑兵冲锋耗马力 -> charged=%s horse=%d 再冲=%s  [%s]" % [charged, m.horse, not no_charge, "OK" if ok else "FAIL"])
    return 0 if ok else 1

func _test_no_reserve_auto_refill() -> int:

    var m: = BattleModel.new()
    m.setup({
        "front_slots": 1, 
        "player_units": ["knife_shield", "spear"], 
        "enemy_units": ["musket", "spear"], 
    })
    m.player_front[0]["hp"] = 0
    m.resolve_phase()
    var move: = m.enemy_act()
    var ok: = m.player_front[0] == null and m.player_reserve.is_empty() and move.is_empty()
    print("  无替补/换防 -> 空位=%s 敌动=%s  [%s]" % [m.player_front[0] == null, move.is_empty(), "OK" if ok else "FAIL"])
    return 0 if ok else 1

func _test_retreat_skill() -> int:

    var m: = BattleModel.new()
    m.setup({
        "front_slots": 1, "skills": ["yizouzhi"], 
        "player_units": ["spear"], 
        "enemy_units": ["spear"], 
    })
    m.player_front[0]["hp"] = 4
    m.morale = 100
    var used: = m.use_skill("yizouzhi")
    var healed: bool = int(m.player_front[0]["hp"]) > 4
    m.turn += 1
    var ev: = m.engage_phase()
    var ok: = used and healed and ev.is_empty()
    print("  以走制敌 -> 回血=%s 脱离接触=%s  [%s]" % [healed, ev.is_empty(), "OK" if ok else "FAIL"])
    return 0 if ok else 1

func _test_pull_and_guard() -> int:

    var m: = BattleModel.new()
    m.setup({
        "front_slots": 3, 
        "player_units": [{"id": "baigan", "pos": 0}, {"id": "langxian", "pos": 2}], 
        "enemy_units": [{"id": "guanning", "pos": 0}, {"id": "cavalry", "pos": 1}], 
    })
    m.turn += 1
    var ev: = m.engage_phase()
    var pulled: = false
    for u in m.enemy_front:
        if u != null and int(u.get("no_charge_turns", 0)) > 0:
            pulled = true
    var guarded: = ev.any( func(e): return bool(e.get("guard", false)))
    var ok: = pulled and guarded
    print("  白杆拉拽+狼筅掩护 -> pulled=%s guarded=%s  [%s]" % [pulled, guarded, "OK" if ok else "FAIL"])
    return 0 if ok else 1

func _test_timeout_field_grade() -> int:

    var m: = BattleModel.new()
    m.setup({
        "front_slots": 3, "max_turns": 2, 
        "objective": {"type": "annihilate"}, 
        "player_units": ["knife_shield"], 
        "enemy_units": ["spear", "spear", "spear"], 
    })
    var g: = _run_manual(m, 4)
    var ok: = m.finished and g == "fail"
    print("  拖满回合判档 -> %s  [%s]" % [g, "OK" if ok else "EXPECT fail"])
    return 0 if ok else 1

func _test_annihilate_timeout_with_enemy_alive_is_fail() -> int:

    var m: = BattleModel.new()
    m.setup({
        "terrain": "narrow", "front_slots": 2, 
        "objective": {"type": "annihilate", "turns": 1}, 
        "player_units": ["knife_shield", "spear", "knife_shield", "spear"], 
        "enemy_units": ["bow", "knife_shield", "bow", "knife_shield"], 
    })
    var g: = _run_manual(m, 2)
    var enemy_alive: = m.enemy_alive_count()
    var ok: = m.finished and enemy_alive > 0 and g == "fail"
    print("  歼灭超时未清场判失利 -> %s 敌余=%d  [%s]" % [g, enemy_alive, "OK" if ok else "EXPECT fail"])
    return 0 if ok else 1

func _test_grade_full_annihilate_zero_loss_is_great() -> int:

    var m: = BattleModel.new()
    m.setup({
        "front_slots": 3, 
        "objective": {"type": "annihilate"}, 
        "player_units": ["redcannon", "guanning", "baigan"], 
        "enemy_units": ["knife_shield"], 
    })
    var g: = _run_manual(m, 20)
    var losses: int = m.player_total_units - m.player_alive_count()
    var ok: bool = m.finished and not m.is_enemy_alive() and losses == 0 and g == "great"
    print("  全歼零折损判大胜 -> 结果=%s 折损=%d  [%s]" % [g, losses, "OK" if ok else "EXPECT great"])
    return 0 if ok else 1

func _test_grade_by_unit_losses() -> int:

    var no_loss: = BattleModel.new()
    no_loss.setup({"front_slots": 2, "player_units": ["knife_shield", "spear"], "enemy_units": ["bow"]})
    var no_loss_grade: String = no_loss.grade_by_player_losses()

    var one_loss: = BattleModel.new()
    one_loss.setup({"front_slots": 2, "player_units": ["knife_shield", "spear"], "enemy_units": ["bow"]})
    one_loss.player_front[0]["hp"] = 0
    var one_loss_grade: String = one_loss.grade_by_player_losses()

    var all_loss: = BattleModel.new()
    all_loss.setup({"front_slots": 2, "player_units": ["knife_shield", "spear"], "enemy_units": ["bow"]})
    all_loss.player_front[0]["hp"] = 0
    all_loss.player_front[1]["hp"] = 0
    var all_loss_grade: String = all_loss.grade_by_player_losses()

    var ok: bool = no_loss_grade == "great" and one_loss_grade == "pyrrhic" and all_loss_grade == "fail"
    print("  折损占比判档 -> 0损=%s 1损=%s 全损=%s  [%s]" % [no_loss_grade, one_loss_grade, all_loss_grade, "OK" if ok else "FAIL"])
    return 0 if ok else 1

func _test_rotate_formation_ring() -> int:


    var m: = BattleModel.new()
    m.setup({
        "front_slots": 2, 
        "player_units": [{"id": "spear", "pos": 1}, {"id": "knife_shield", "pos": 0}], 
        "enemy_units": ["bow"], 
    })
    var moves: Array = m.rotate_formation(true, true)
    var spear_at_feng: bool = m.player_front[0] != null and str(m.player_front[0].get("id", "")) == "spear"
    var shield_at_right: bool = m.player_front[3] != null and str(m.player_front[3].get("id", "")) == "knife_shield"
    m.rotate_formation(true, false)
    var back_home: bool = m.player_front[1] != null and str(m.player_front[1].get("id", "")) == "spear" and m.player_front[0] != null and str(m.player_front[0].get("id", "")) == "knife_shield"
    var ok: = moves.size() == 2 and spear_at_feng and shield_at_right and back_home
    print("  环形变阵 -> 长枪入前锋=%s 刀盾入右翼=%s 逆转还原=%s  [%s]" % [spear_at_feng, shield_at_right, back_home, "OK" if ok else "FAIL"])
    return 0 if ok else 1

func _test_back_row_participation() -> int:

    var m: = BattleModel.new()
    m.setup({
        "front_slots": 6, 
        "player_units": [{"id": "knife_shield", "pos": 0}, {"id": "spear", "pos": 2}, {"id": "bow", "pos": 4}, {"id": "knife_shield", "pos": 1}], 
        "enemy_units": [{"id": "knife_shield", "pos": 0}, {"id": "knife_shield", "pos": 1}], 
    })
    m.turn += 1
    var ev: = m.engage_phase()
    var spear_attacked: = ev.any( func(e): return bool(e.get("player", false)) and int(e.get("by_pos", -1)) == 2)
    var bow_attacked: = ev.any( func(e): return bool(e.get("player", false)) and int(e.get("by_pos", -1)) == 4)
    var back_hit: = ev.any( func(e): return not bool(e.get("player", false)) and int(e.get("to_pos", -1)) in [2, 4, 5])
    var ok: = ( not spear_attacked) and bow_attacked and ( not back_hit)
    print("  后排出手资格 -> 近战后排出手=%s 远程后排出手=%s 后排被打=%s  [%s]" % [spear_attacked, bow_attacked, back_hit, "OK" if ok else "FAIL"])
    return 0 if ok else 1

func _test_back_row_promotion() -> int:

    var m: = BattleModel.new()
    m.setup({
        "front_slots": 6, 
        "player_units": [{"id": "knife_shield", "pos": 0}, {"id": "spear", "pos": 2}], 
        "enemy_units": ["bow"], 
    })
    m.player_front[0]["hp"] = 0
    m.resolve_phase()
    var promoted: bool = m.player_front[0] != null and str(m.player_front[0].get("id", "")) == "spear" and m.player_front[2] == null
    var pos_updated: bool = promoted and int(m.player_front[0].get("pos", -1)) == 0
    var ok: = promoted and pos_updated
    print("  后排自动顶替 -> 顶替=%s 阵位更新=%s  [%s]" % [promoted, pos_updated, "OK" if ok else "FAIL"])
    return 0 if ok else 1

func _test_column_fallback_penalty() -> int:

    var m: = BattleModel.new()
    m.setup({
        "front_slots": 6, 
        "player_units": [{"id": "spear", "pos": 0}], 
        "enemy_units": [{"id": "knife_shield", "pos": 1}, {"id": "knife_shield", "pos": 3}], 
    })
    m.turn += 1
    var ev: = m.engage_phase()
    var mine: = ev.filter( func(e): return bool(e.get("player", false)))
    var hit_left: bool = mine.size() == 1 and int(mine[0].get("to_pos", -1)) == 1

    var m2: = BattleModel.new()
    m2.setup({
        "front_slots": 6, 
        "player_units": [{"id": "spear", "pos": 1}], 
        "enemy_units": [{"id": "knife_shield", "pos": 3}], 
    })
    m2.turn += 1
    var ev2: = m2.engage_phase()
    var mine2: = ev2.filter( func(e): return bool(e.get("player", false)))
    var hit_far: bool = mine2.size() == 1 and int(mine2[0].get("to_pos", -1)) == 3

    var dmg_left: = int(mine[0].get("dmg", 999)) if hit_left else 999
    var dmg_far: = int(mine2[0].get("dmg", 999)) if hit_far else 999
    var ok: = hit_left and hit_far and dmg_left <= 70 and dmg_far <= 60
    print("  空列降级攻击 -> 中列优先左=%s 伤%d 隔列=%s 伤%d  [%s]" % [hit_left, dmg_left, hit_far, dmg_far, "OK" if ok else "FAIL"])
    return 0 if ok else 1

func _test_custom_hp_deployment() -> int:
    var m: = BattleModel.new()
    m.setup({
        "front_slots": 2, 
        "player_units": [{"id": "knife_shield", "pos": 0, "hp": 5000}], 
        "enemy_units": ["bow"], 
    })
    var p = m.player_front[0]
    var ok = p != null and int(p.get("hp", 0)) == 5000 and int(p.get("hp_max", 0)) == 5000
    print("  自定义编制兵力 -> hp=5000 成功=%s  [%s]" % [ok, "OK" if ok else "FAIL"])
    return 0 if ok else 1
