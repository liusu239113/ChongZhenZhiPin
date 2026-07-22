extends RefCounted




const T: = preload("res://scripts/battle/battle_types.gd")


var terrain: String = "plain"
var objective: Dictionary = {"type": "annihilate"}
var turn: int = 0
var max_turns: int = 8
var unlimited_turns: bool = false
const SAFETY_TURN_CAP: = 60
var front_slots: int = 5
var player_front: Array = [null, null, null, null, null, null]
var enemy_front: Array = [null, null, null, null, null, null]
var player_reserve: Array = []
var enemy_reserve: Array = []
var ammo: int = T.DEFAULT_AMMO
var horse: int = T.DEFAULT_HORSE
var morale: int = 0
var intel: int = 0
var wulue: int = 50
var skills: Array = []
var used_skills: Array = []
var skill_cooldowns: Dictionary = {}
var focus_target: int = -1
var enemy_act_cd: int = 0
var active_effects: Dictionary = {}
var log_lines: Array = []
var finished: bool = false
var result_grade: String = ""

var player_total_units: int = 0
var enemy_total_units: int = 0

func setup(config: Dictionary) -> void :
    terrain = str(config.get("terrain", "plain"))
    objective = config.get("objective", {"type": "annihilate"}).duplicate(true)

    var _has_limit: bool = objective.has("turns") or config.has("max_turns")
    unlimited_turns = str(objective.get("type", "annihilate")) == "annihilate" and not _has_limit
    if unlimited_turns:
        max_turns = SAFETY_TURN_CAP
    else:
        max_turns = int(objective.get("turns", config.get("max_turns", 8)))
    front_slots = clampi(int(config.get("front_slots", 5)), 1, 6)
    ammo = int(config.get("ammo", T.DEFAULT_AMMO))
    horse = int(config.get("horse", T.DEFAULT_HORSE))
    intel = int(config.get("intel", 0))
    wulue = int(config.get("wulue", 50))
    skills = (config.get("skills", []) as Array).duplicate()
    used_skills = []
    skill_cooldowns = {}
    morale = 0
    enemy_act_cd = 0
    turn = 0
    finished = false
    result_grade = ""
    log_lines = []
    active_effects = {}

    player_front = [null, null, null, null, null, null]
    enemy_front = [null, null, null, null, null, null]
    player_reserve = []
    enemy_reserve = []

    _deploy(config.get("player_units", []), player_front, player_reserve)
    _deploy(config.get("enemy_units", []), enemy_front, enemy_reserve)

    player_total_units = _all_alive(player_front).size() + player_reserve.size()
    enemy_total_units = _all_alive(enemy_front).size() + enemy_reserve.size()



func _deploy(units: Array, front: Array, reserve: Array) -> void :
    var slot: = 0
    for entry in units:
        var uid: = str(entry) if typeof(entry) == TYPE_STRING else str(entry.get("id", ""))
        var inst: = _make_unit(uid)
        if inst.is_empty():
            continue

        if typeof(entry) == TYPE_DICTIONARY and entry.has("hp"):
            var custom_hp: = int(entry["hp"])
            inst["hp"] = custom_hp
            inst["hp_max"] = custom_hp

        if typeof(entry) == TYPE_DICTIONARY and entry.has("name"):
            inst["name"] = str(entry["name"])

        if typeof(entry) == TYPE_DICTIONARY and entry.has("level"):
            inst["level"] = int(entry["level"])

        if typeof(entry) == TYPE_DICTIONARY and bool(entry.get("ally", false)):
            inst["ally"] = true
        var fixed_pos: = -1
        if typeof(entry) == TYPE_DICTIONARY and entry.has("pos"):
            fixed_pos = int(entry["pos"])
        if fixed_pos >= 0 and fixed_pos < T.FRONT_POSITIONS.size() and fixed_pos < front_slots and front[fixed_pos] == null:
            inst["pos"] = fixed_pos
            front[fixed_pos] = inst
        elif slot < front_slots:
            inst["pos"] = T.FRONT_POSITIONS[slot]
            front[T.FRONT_POSITIONS[slot]] = inst
            slot += 1
        else:
            continue

func _make_unit(uid: String) -> Dictionary:
    var d: = T.unit_def(uid)
    if d.is_empty():
        return {}
    return {
        "id": uid, 
        "name": d.get("name", uid), 
        "cat": d.get("cat", ""), 
        "atk": int(d.get("atk", 1)), 
        "hp": int(d.get("hp", 1)), 
        "hp_max": int(d.get("hp", 1)), 
        "level": 1, 
        "reload_max": int(d.get("reload", 0)), 
        "reload_left": 0, 
        "tags": (d.get("tags", []) as Array).duplicate(), 
        "dmg_reduction": float(d.get("dmg_reduction", 0.0)), 
        "elite": bool(d.get("elite", false)), 
        "ally": false, 
        "ramp": 0, 
        "pos": -1, 
        "no_charge_turns": 0, 
    }




func engage_phase() -> Array:
    var events: Array = []

    if active_effects.has("retreat"):
        return events

    var order: = [T.POS_LEFT, T.POS_FENG, T.POS_CENTER, T.POS_RIGHT, T.POS_REAR, T.POS_REAR_R]
    for pos in order:

        _resolve_attack_at(player_front, enemy_front, pos, true, events)
        _resolve_attack_at(enemy_front, player_front, pos, false, events)
    return events

func _flanks_safe() -> bool:
    return bool(T.TERRAIN.get(terrain, {}).get("flanks_safe", false))

func _resolve_attack_at(attackers: Array, defenders: Array, pos: int, is_player: bool, events: Array) -> void :
    if _flanks_safe() and front_slots >= 3 and (pos == T.POS_LEFT or pos == T.POS_RIGHT):
        return
    var atk_unit = attackers[pos]
    if atk_unit == null or int(atk_unit.get("hp", 0)) <= 0:
        return

    if _is_reloading(atk_unit) and not active_effects.has("volley_all"):
        return

    if is_player and atk_unit.get("tags", []).has("firearm") and ammo <= 0:
        return

    var col: int = T.COLUMN_OF.get(pos, 1)
    var shoot_over: = false
    if T.COL_BACK[col] == pos:
        var fr = attackers[T.COL_FRONT[col]]
        if fr != null and int(fr.get("hp", 0)) > 0:
            if str(atk_unit.get("cat", "")) != T.CAT_RANGED:
                return
            shoot_over = true
    var charging: = _can_charge(atk_unit, is_player)
    var target_pos: = -1
    var col_penalty: = 1.0

    if is_player and focus_target >= 0 and focus_target < defenders.size() and is_targetable(defenders, focus_target):
        target_pos = focus_target
    else:
        var pick: = _column_target(defenders, col)
        if pick.is_empty():
            return
        target_pos = int(pick["pos"])
        col_penalty = float(pick["mult"])
    var target = defenders[target_pos]
    var dmg: = _compute_damage(atk_unit, pos, target, target_pos, is_player, charging, shoot_over)
    if dmg <= 0:
        return
    if col_penalty < 1.0:
        dmg = maxi(1, int(round(dmg * col_penalty)))

    var guard = _adjacent_guard(defenders, target_pos)
    var guard_dmg: = 0
    if guard != null:
        guard_dmg = int(floor(dmg * 0.2))
        if guard_dmg > 0 and dmg - guard_dmg >= 1:
            dmg -= guard_dmg
        else:
            guard_dmg = 0
    target["hp"] = int(target["hp"]) - dmg

    morale = mini(T.MORALE_FULL, morale + (15 if is_player else 8))

    if charging and is_player:
        horse = max(0, horse - 1)
    events.append({"by": atk_unit.get("name"), "to": target.get("name"), "dmg": dmg, "player": is_player, "by_pos": pos, "to_pos": target_pos, "kill": int(target["hp"]) <= 0, "charge": charging})
    if guard_dmg > 0:
        guard["hp"] = int(guard["hp"]) - guard_dmg
        events.append({"by": atk_unit.get("name"), "to": guard.get("name"), "dmg": guard_dmg, "player": is_player, "splash": true, "to_pos": int(guard.get("pos", -1)), "kill": int(guard["hp"]) <= 0, "guard": true})

    if atk_unit.get("tags", []).has("pull") and str(target.get("cat", "")) == T.CAT_CAV and int(target.get("hp", 0)) > 0:
        target["no_charge_turns"] = maxi(int(target.get("no_charge_turns", 0)), 2)

    if int(atk_unit.get("reload_max", 0)) > 0 and not active_effects.has("volley_all"):
        atk_unit["reload_left"] = int(atk_unit["reload_max"])
        if is_player:
            ammo = max(0, ammo - 1)

    var splash: = 0
    if atk_unit.get("tags", []).has("splash2"):
        splash = 2
    elif atk_unit.get("tags", []).has("splash1"):
        splash = 1
    if splash > 0:
        _apply_splash(atk_unit, defenders, target_pos, splash, dmg, is_player, events)


func _apply_splash(atk_unit, defenders: Array, center_pos: int, radius: int, base_dmg: int, is_player: bool, events: Array) -> void :
    var ccol: int = T.COLUMN_OF.get(center_pos, 1)
    for col in range(3):
        var dist: int = absi(col - ccol)
        if dist == 0 or dist > radius:
            continue
        var adj: = _effective_front_pos(defenders, col)
        if adj < 0 or adj == center_pos:
            continue
        var u = defenders[adj]
        var sdmg: = maxi(1, int(round(base_dmg * 0.5)))
        u["hp"] = int(u["hp"]) - sdmg
        events.append({"by": atk_unit.get("name"), "to": u.get("name"), "dmg": sdmg, "player": is_player, "splash": true, "to_pos": adj, "kill": int(u["hp"]) <= 0})


func _adjacent_guard(defenders: Array, target_pos: int):
    var tgt = defenders[target_pos]
    if tgt != null and tgt.get("tags", []).has("share20"):
        return null
    for adj in T.ADJACENT_POSITIONS.get(target_pos, []):
        var u = defenders[adj]
        if u != null and int(u.get("hp", 0)) > 0 and u.get("tags", []).has("share20"):
            return u
    return null


func _can_charge(u, is_player: bool) -> bool:
    if not u.get("tags", []).has("charge"):
        return false
    if int(u.get("no_charge_turns", 0)) > 0:
        return false
    var ter: Dictionary = T.TERRAIN.get(terrain, {})
    if bool(ter.get("no_charge", false)) or ter.has("charge_penalty"):
        return false
    if is_player and horse <= 0:
        return false
    return true

func _compute_damage(atk_unit, atk_pos: int, target, target_pos: int, is_player: bool, charging: bool = false, shoot_over: bool = false) -> int:

    var base_atk: = float(atk_unit.get("atk", 10))
    var unit_level: = int(atk_unit.get("level", 1))
    var atk_cs: = base_atk + float(unit_level - 1) + float(atk_unit.get("ramp", 0))
    var def_cs: = float(target.get("atk", 10))


    if T.counters(str(atk_unit.get("cat", "")), str(target.get("cat", ""))):
        atk_cs += 4.0
        def_cs -= 2.0



    if atk_pos == T.POS_LEFT:
        atk_cs += 3.0
    elif (atk_pos == T.POS_REAR or atk_pos == T.POS_REAR_R) and atk_unit.get("tags", []).has("ranged") and not shoot_over:
        atk_cs += 2.0


    if target_pos == T.POS_FENG:
        def_cs -= 2.0
    elif target_pos == T.POS_RIGHT and atk_unit.get("tags", []).has("ranged"):
        def_cs += 4.0
    elif (target_pos == T.POS_REAR or target_pos == T.POS_REAR_R) and charging:
        def_cs += 3.0



    if charging and not target.get("tags", []).has("block_charge"):
        atk_cs += 4.0

    if atk_unit.get("tags", []).has("anti_cav") and str(target.get("cat", "")) == T.CAT_CAV:
        atk_cs += 3.0

    if atk_unit.get("tags", []).has("siege_bonus") and terrain in ["siege", "narrow"]:
        atk_cs += 3.0

    if atk_unit.get("tags", []).has("volley") and int(atk_unit.get("reload_left", 0)) == 0:
        atk_cs += 3.0

    var t_red: = float(target.get("dmg_reduction", 0.0))
    if t_red > 0.0:
        var bonus: = 3.0
        if target_pos == T.POS_FENG:
            bonus *= 2.0
        def_cs += bonus

    if _is_reloading(target) and target.get("tags", []).has("reload_shield"):
        def_cs += 5.0


    var ter: Dictionary = T.TERRAIN.get(terrain, {})

    if str(atk_unit.get("cat", "")) in [T.CAT_POLE, T.CAT_SHIELD] and ter.has("infantry_bonus"):
        atk_cs += 2.0
    if str(target.get("cat", "")) in [T.CAT_POLE, T.CAT_SHIELD] and ter.has("infantry_bonus"):
        def_cs += 2.0

    if str(atk_unit.get("cat", "")) == T.CAT_CAV and ter.has("cav_penalty"):
        atk_cs -= 4.0
    if str(target.get("cat", "")) == T.CAT_CAV and ter.has("cav_penalty"):
        def_cs -= 4.0


    if ter.has("arty_bonus") and atk_unit.get("tags", []).has("firearm"):
        atk_cs += 4.0
    if ter.has("all_reduction"):
        def_cs += 2.0
    if ter.has("defender_reduction") and not is_player:
        def_cs += 3.0
    if not is_player and turn <= 1 and ter.has("first_turn_attacker_penalty"):
        atk_cs -= 4.0


    if active_effects.has("yuanyang") and not is_player:
        def_cs += 4.0
    if active_effects.has("artillery_x2") and is_player and atk_unit.get("tags", []).has("firearm"):
        atk_cs += 10.0
    if active_effects.has("tianxiong") and is_player and atk_pos == T.POS_FENG:
        atk_cs += 8.0


    atk_cs -= _wounded_penalty(atk_unit)
    def_cs -= _wounded_penalty(target)


    var cs_diff: = atk_cs - def_cs
    var dmg: = 150.0 + 10.0 * cs_diff

    return maxi(50, int(round(dmg)))

func _wounded_penalty(u) -> float:
    if u == null:
        return 0.0
    var hp: = float(u.get("hp", 0))
    var hp_max: = float(u.get("hp_max", 1))
    if hp_max <= 0:
        return 0.0
    var ratio: = hp / hp_max
    if ratio >= 0.75:
        return 0.0
    elif ratio >= 0.5:
        return 2.0
    elif ratio >= 0.25:
        return 4.0
    else:
        return 6.0

func _is_reloading(u) -> bool:
    return u != null and int(u.get("reload_left", 0)) > 0


func _effective_front_pos(side: Array, col: int) -> int:
    var f: int = T.COL_FRONT[col]
    if side[f] != null and int(side[f].get("hp", 0)) > 0:
        return f
    var b: int = T.COL_BACK[col]
    if side[b] != null and int(side[b].get("hp", 0)) > 0:
        return b
    return -1


func is_targetable(side: Array, pos: int) -> bool:
    if pos < 0 or pos >= side.size():
        return false
    var u = side[pos]
    if u == null or int(u.get("hp", 0)) <= 0:
        return false
    return _effective_front_pos(side, T.COLUMN_OF.get(pos, 1)) == pos


func _column_target(defenders: Array, atk_col: int) -> Dictionary:
    var same: = _effective_front_pos(defenders, atk_col)
    if same >= 0:
        return {"pos": same, "mult": 1.0}
    var fallback: Array
    match atk_col:
        0: fallback = [[1, 0.5], [2, 1.0 / 3.0]]
        2: fallback = [[1, 0.5], [0, 1.0 / 3.0]]
        _: fallback = [[0, 0.5], [2, 0.5]]
    for entry in fallback:
        var p: = _effective_front_pos(defenders, int(entry[0]))
        if p >= 0:
            return {"pos": p, "mult": float(entry[1])}
    return {}





func rotate(reserve_idx: int, pos: int) -> bool:
    return false




func rotate_formation(is_player: bool, clockwise: bool) -> Array:
    var front: Array = player_front if is_player else enemy_front

    var ring: Array = T.RING.duplicate()
    var n: = ring.size()
    if n < 2:
        return []
    var moves: Array = []
    var new_vals: = {}
    for i in range(n):
        var from: int = ring[i]
        var to: int = ring[(i + 1) % n] if clockwise else ring[(i - 1 + n) % n]
        new_vals[to] = front[from]
        if front[from] != null:
            moves.append({"from": from, "to": to})
    for pos in new_vals.keys():
        front[pos] = new_vals[pos]
        if front[pos] != null:
            front[pos]["pos"] = pos
    return moves

func _slot_enabled(pos: int) -> bool:
    var idx: int = T.FRONT_POSITIONS.find(pos)
    return idx >= 0 and idx < front_slots

func set_focus(pos: int) -> void :
    focus_target = pos

func skip() -> void :
    pass

func use_skill(skill_id: String) -> bool:
    if not skill_id in skills or morale < T.MORALE_FULL:
        return false
    if int(skill_cooldowns.get(skill_id, 0)) > 0:
        return false
    used_skills.append(skill_id)
    skill_cooldowns[skill_id] = int(T.SKILLS.get(skill_id, {}).get("cooldown", 3))
    morale = 0
    match skill_id:
        "yuanyang": active_effects["yuanyang"] = 2
        "pingjian": active_effects["artillery_x2"] = 1
        "huoche": active_effects["volley_all"] = 1
        "baiganpo": _pull_all_enemy_cav(2)
        "tianxiong": active_effects["tianxiong"] = 1
        "yizouzhi": _retreat_heal()
    log_lines.append("将令·%s！" % T.SKILLS.get(skill_id, {}).get("name", skill_id))
    return true

func _pull_all_enemy_cav(turns: int) -> void :
    for u in enemy_front:
        if u != null and str(u.get("cat", "")) == T.CAT_CAV:
            u["no_charge_turns"] = turns

func _retreat_heal() -> void :
    active_effects["retreat"] = 1
    for u in _all_alive(player_front) + player_reserve:
        u["hp"] = mini(int(u.get("hp_max", 1)), int(u.get("hp", 0)) + int(round(int(u.get("hp_max", 1)) * 0.3)))




func enemy_act() -> Dictionary:
    return {}




func resolve_phase() -> void :
    _clear_dead(player_front, player_reserve)
    _clear_dead(enemy_front, enemy_reserve)
    _promote_back_rows(player_front)
    _promote_back_rows(enemy_front)

    for u in _all_alive(player_front) + _all_alive(enemy_front):
        if int(u.get("reload_left", 0)) > 0:
            u["reload_left"] = int(u["reload_left"]) - 1
        if int(u.get("no_charge_turns", 0)) > 0:
            u["no_charge_turns"] = int(u["no_charge_turns"]) - 1
        if u.get("tags", []).has("ramp"):
            u["ramp"] = mini(3, int(u.get("ramp", 0)) + 1)

    for key in active_effects.keys():
        active_effects[key] = int(active_effects[key]) - 1
        if active_effects[key] <= 0:
            active_effects.erase(key)

    for sid in skill_cooldowns.keys():
        skill_cooldowns[sid] = int(skill_cooldowns[sid]) - 1
        if skill_cooldowns[sid] <= 0:
            skill_cooldowns.erase(sid)
    enemy_act_cd = maxi(0, enemy_act_cd - 1)
    focus_target = -1


func _promote_back_rows(front: Array) -> void :
    for col in range(3):
        var f: int = T.COL_FRONT[col]
        var b: int = T.COL_BACK[col]
        if front[f] == null and front[b] != null and _slot_enabled(f):
            front[f] = front[b]
            front[b] = null
            front[f]["pos"] = f

func _clear_dead(front: Array, reserve: Array) -> void :
    for i in range(front.size()):
        if front[i] != null and int(front[i].get("hp", 0)) <= 0:
            front[i] = null
    var keep: Array = []
    for u in reserve:
        if int(u.get("hp", 0)) > 0:
            keep.append(u)
    reserve.assign(keep)




func is_player_alive() -> bool:
    return not _all_alive(player_front).is_empty() or not player_reserve.is_empty()

func is_enemy_alive() -> bool:
    return not _all_alive(enemy_front).is_empty() or not enemy_reserve.is_empty()

func _protected_alive() -> bool:
    var pid: = str(objective.get("protect", ""))
    if pid == "":
        return true
    for u in _all_alive(player_front) + player_reserve:
        if str(u.get("id", "")) == pid:
            return true
    return false


func check_finished() -> bool:
    var otype: = str(objective.get("type", "annihilate"))
    if not is_player_alive() or not _protected_alive():
        _finish("fail")
        return true
    match otype:
        "annihilate":
            if not is_enemy_alive():
                _finish(grade_by_player_losses())
                return true
        "hold":
            if turn >= max_turns:
                _finish(grade_by_player_losses())
                return true
        "protect":
            if not is_enemy_alive() or turn >= max_turns:
                _finish(grade_by_player_losses() if _protected_alive() else "fail")
                return true
    if turn >= max_turns:


        _finish("fail")
        return true
    return false

func _finish(grade: String) -> void :
    finished = true
    result_grade = grade


func grade_by_player_losses() -> String:
    var total: = maxi(1, player_total_units)
    var losses: = total - player_alive_count()
    if losses <= 0:
        return "great"
    if losses >= total:
        return "fail"
    return "pyrrhic"




func auto_resolve(supply: float = 1.0) -> String:
    var p: = _side_score(player_front, player_reserve)
    var e: = _side_score(enemy_front, enemy_reserve)
    var wulue_mod: float = 1.0 + (wulue - 50) * 0.01
    var intel_coef: float = [1.0, 1.1, 1.2][clampi(intel, 0, 2)]
    var terrain_coef: = 1.0
    if terrain in ["siege", "narrow"]:
        terrain_coef = 1.2
    elif terrain == "ford":
        terrain_coef = 1.15
    var force: float = p * wulue_mod * intel_coef * clampf(supply, 0.8, 1.1) * terrain_coef
    var ratio: float = force / max(1.0, e)
    if ratio >= 1.3:
        result_grade = "great"
    elif ratio >= 0.95:
        result_grade = "pyrrhic"
    else:
        result_grade = "fail"
    finished = true
    return result_grade




func _all_alive(front: Array) -> Array:
    var out: Array = []
    for u in front:
        if u != null and int(u.get("hp", 0)) > 0:
            out.append(u)
    return out

func _side_score(front: Array, reserve: Array) -> float:
    var total: = 0.0
    for u in _all_alive(front) + reserve:
        var s: = float(u.get("atk", 1)) * float(u.get("hp", 1)) / 6.0
        if bool(u.get("elite", false)):
            s *= 1.2
        total += s
    return total

func player_alive_count() -> int:
    return _all_alive(player_front).size() + player_reserve.size()

func enemy_alive_count() -> int:
    return _all_alive(enemy_front).size() + enemy_reserve.size()

func objective_text() -> String:
    match str(objective.get("type", "annihilate")):
        "hold": return "守住 %d 回合" % max_turns
        "protect": return "护住主将不溃，撑到援军 / 退敌"
        _: return "歼灭当面之敌"
