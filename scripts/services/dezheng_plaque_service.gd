extends RefCounted
class_name DezhengPlaqueService






























const CITY_STAT_PLAQUE: = {
    "wenjiao": ["崇文兴教", "庠序兴文", "文教昌明", "化民成俗"], 
    "shangmao": ["市井安业", "通商惠工", "懋迁有无", "市廛殷阜"], 
    "baigong": ["百工兴作", "巧夺天工", "百工咸熙", "器用饬新"], 
    "chengfang": ["干城之寄", "金汤永固", "屏翰一方", "捍圉有方"], 
    "nongsang": ["阜俗康民", "劝课农桑", "稼穑丰登"], 
}


const PLAQUE_ZHENGTONG: = "政通人和"
const PLAQUE_FALLBACK: = "阜俗康民"

const ZHENGTONG_PLAQUES: = ["政通人和", "政简刑清", "百废俱兴", "治行卓异"]

const ZHESU_PLAQUES: = ["折狱明允", "明镜高悬", "片言折狱", "剖决如流"]

const QINGFENG_PLAQUES: = ["清风峻节", "两袖清风", "冰壸秋月"]


const ENLIU_PLAQUES: = ["恩流桑梓", "甘棠遗爱", "抚字心劳", "膏泽下民"]


const BALANCE_PLAQUES: = ["允执厥中", "秉公持正", "不偏不党"]


const MARTIAL_CHENGFANG_PLAQUES: = ["靖寇安民", "弭盗安良", "戡乱靖边"]


const MARTIAL_LINGWU_PLAQUES: = ["折冲御侮", "折冲千里", "文武兼资"]


const CLEAN_POS: = ["清廉", "自律", "自守", "不走捷径", "秉公执法", "依法", "刚直", "硬顶", "不畏强权", "铁面", "整饬", "整顿吏治"]
const CLEAN_NEG: = ["贪墨", "贪赃枉法", "行贿", "进贡", "走后宫门路", "钻营", "权金开道", "和稀泥", "士绅交好", "地方坐大"]

const PEOPLE_POS: = ["惠民", "保民", "护民", "仁政", "以工代赈", "收揽流民", "流民屯田", "救荒", "甘薯救荒"]
const PEOPLE_NEG: = ["伤民"]


const ZHENGTONG_OVERFLOW: = 1.2
const COURT_MIN_TOTAL: = 10
const COURT_MIN_JUST: = 7
const TIER2_RATIO: = 0.7
const TIER2_MIN_SAMPLE: = 3




const BALANCE_ATT_KEYS: = ["shengjuan", "zhongguan", "qingyi", "shishen"]
const BALANCE_MIN_FLOOR: = 45
const BALANCE_MAX_SPREAD: = 25


const MARTIAL_MIN_SCORE: = 4



static func compute_eval(game_state: Node, old_act: int, excluded_evals: Array = []) -> String:
    if game_state == null:
        return PLAQUE_ZHENGTONG
    var act_key: = str(old_act)
    var excluded: = _to_set(excluded_evals)




    var city_gains: = _compute_city_gains(game_state, act_key)


    var tier1: Array = []
    var target: = int(GameData.ACT_CONFIG.get(act_key, {}).get("meritTarget", 0))
    var stat_merit: = 0
    for g in city_gains.values():
        stat_merit += int(g) * 100
    var merit: = int(game_state.get("city").get("zhengji", 0)) + stat_merit if game_state.get("city") is Dictionary else stat_merit
    if target > 0 and float(merit) >= float(target) * ZHENGTONG_OVERFLOW:
        var zt: = _pick_from_pool(ZHENGTONG_PLAQUES, excluded)
        if zt != "":
            tier1.append({"eval": zt, "weight": float(merit) / float(target)})
    var court_total: = int(game_state.get("term_court_total"))
    var court_just: = int(game_state.get("term_court_just"))
    if court_total >= COURT_MIN_TOTAL and court_just >= COURT_MIN_JUST:
        var ratio: = float(court_just) / float(max(1, court_total))
        var zs: = _pick_from_pool(ZHESU_PLAQUES, excluded)
        if zs != "":
            tier1.append({"eval": zs, "weight": 1.0 + ratio})

    var balance_pick: = _pick_balance(game_state, excluded)
    if balance_pick != "":

        tier1.append({"eval": balance_pick, "weight": _balance_weight(game_state)})
    tier1 = _filter_excluded(tier1, excluded)
    if not tier1.is_empty():
        return _weighted_pick(tier1)


    var counts: Dictionary = game_state.get("term_tag_counts")
    if not (counts is Dictionary):
        counts = {}
    var tier2: Array = []
    var clean_pos: = _sum_counts(counts, CLEAN_POS)
    var clean_neg: = _sum_counts(counts, CLEAN_NEG)
    var clean_sample: = clean_pos + clean_neg
    if clean_sample >= TIER2_MIN_SAMPLE and float(clean_pos) / float(clean_sample) >= TIER2_RATIO:
        var qf: = _pick_from_pool(QINGFENG_PLAQUES, excluded)
        if qf != "":
            tier2.append({"eval": qf, "weight": float(clean_pos) / float(clean_sample)})
    var people_pos: = _sum_counts(counts, PEOPLE_POS)
    var people_neg: = _sum_counts(counts, PEOPLE_NEG)
    var people_sample: = people_pos + people_neg
    if people_sample >= TIER2_MIN_SAMPLE and float(people_pos) / float(people_sample) >= TIER2_RATIO:
        var el: = _pick_from_pool(ENLIU_PLAQUES, excluded)
        if el != "":
            tier2.append({"eval": el, "weight": float(people_pos) / float(people_sample)})

    var martial_score: = int(game_state.get("term_martial_chengfang")) + int(game_state.get("term_martial_lingwu"))
    if martial_score >= MARTIAL_MIN_SCORE:
        var martial_pick: = _pick_martial(game_state, excluded)
        if martial_pick != "":

            tier2.append({"eval": martial_pick, "weight": 1.0 + float(martial_score) / float(MARTIAL_MIN_SCORE)})
    tier2 = _filter_excluded(tier2, excluded)
    if not tier2.is_empty():
        return _weighted_pick(tier2)


    return _pick_by_city_gain(city_gains, excluded)


static func _compute_city_gains(game_state: Node, act_key: String) -> Dictionary:
    var city: Dictionary = game_state.get("city") if game_state.get("city") is Dictionary else {}
    var defaults: Dictionary = GameData.CITY_BY_ACT.get(act_key, {}).get("defaults", {})
    var gains: = {}
    for stat_key in GameData.CITY_STAT_KEYS:
        var base_level: = int(defaults.get(stat_key, GameData.CITY_STAT_INIT.get(stat_key, 1)))
        var current_level: = int(city.get(stat_key, base_level))
        gains[stat_key] = maxi(0, current_level - base_level)
    return gains



static func _pick_by_city_gain(gains: Dictionary, excluded: Dictionary = {}) -> String:

    var remaining_stats: Array = []
    for stat_key in GameData.CITY_STAT_KEYS:
        if _stat_has_available_name(stat_key, excluded):
            remaining_stats.append(stat_key)
    if remaining_stats.is_empty():
        return PLAQUE_FALLBACK

    var best_gain: = 0
    for stat_key in remaining_stats:
        best_gain = maxi(best_gain, int(gains.get(stat_key, 0)))
    if best_gain <= 0:
        return _pick_stat_name(remaining_stats[0], excluded)

    while best_gain > 0:
        var top_non_nongsang: Array = []
        var nongsang_is_top: = false
        for stat_key in remaining_stats:
            if int(gains.get(stat_key, 0)) != best_gain:
                continue
            if stat_key == "nongsang":
                nongsang_is_top = true
            else:
                top_non_nongsang.append(stat_key)
        var pool: = top_non_nongsang if not top_non_nongsang.is_empty() else (["nongsang"] if nongsang_is_top else [])
        if not pool.is_empty():

            var stat_choices: Array = []
            for stat_key in pool:
                stat_choices.append({"eval": stat_key, "weight": 1.0})
            var chosen_stat: = _weighted_pick(stat_choices)
            return _pick_stat_name(chosen_stat, excluded)
        best_gain -= 1
    return _pick_stat_name(remaining_stats[0], excluded)


static func _stat_has_available_name(stat_key: String, excluded: Dictionary) -> bool:
    for name in CITY_STAT_PLAQUE.get(stat_key, [PLAQUE_FALLBACK]):
        if not excluded.has(name):
            return true
    return false


static func _pick_stat_name(stat_key: String, excluded: Dictionary) -> String:
    var names: Array = CITY_STAT_PLAQUE.get(stat_key, [PLAQUE_FALLBACK])
    var picked: = _pick_from_pool(names, excluded)
    if picked != "":
        return picked
    return str(names[0]) if not names.is_empty() else PLAQUE_FALLBACK


static func _pick_balance(game_state: Node, excluded: Dictionary) -> String:
    if not _balance_qualifies(game_state):
        return ""
    var pool: Array = []
    for name in BALANCE_PLAQUES:
        if excluded.has(name):
            continue
        pool.append({"eval": name, "weight": 1.0})
    if pool.is_empty():
        return ""
    return _weighted_pick(pool)

static func _balance_qualifies(game_state: Node) -> bool:
    var att = game_state.get("attitudes")
    if not (att is Dictionary):
        return false
    var vals: Array = []
    for key in BALANCE_ATT_KEYS:
        if not att.has(key):
            return false
        vals.append(int(att[key]))
    if vals.is_empty():
        return false
    var lo: = int(vals[0])
    var hi: = int(vals[0])
    for v in vals:
        lo = mini(lo, int(v))
        hi = maxi(hi, int(v))
    return lo >= BALANCE_MIN_FLOOR and (hi - lo) <= BALANCE_MAX_SPREAD


static func _balance_weight(game_state: Node) -> float:
    var att = game_state.get("attitudes")
    if not (att is Dictionary):
        return 1.0
    var lo: = 100
    var hi: = 0
    for key in BALANCE_ATT_KEYS:
        var v: = int(att.get(key, 50))
        lo = mini(lo, v)
        hi = maxi(hi, v)
    var floor_bonus: = float(lo - BALANCE_MIN_FLOOR) / 20.0
    var spread_bonus: = float(BALANCE_MAX_SPREAD - (hi - lo)) / 25.0
    return 1.2 + maxf(0.0, floor_bonus) + maxf(0.0, spread_bonus)


static func _pick_martial(game_state: Node, excluded: Dictionary) -> String:
    var cf: = int(game_state.get("term_martial_chengfang"))
    var lw: = int(game_state.get("term_martial_lingwu"))

    var primary: Array = MARTIAL_CHENGFANG_PLAQUES if cf >= lw else MARTIAL_LINGWU_PLAQUES
    var secondary: Array = MARTIAL_LINGWU_PLAQUES if cf >= lw else MARTIAL_CHENGFANG_PLAQUES
    var pick: = _pick_from_pool(primary, excluded)
    if pick != "":
        return pick
    return _pick_from_pool(secondary, excluded)

static func _pick_from_pool(names: Array, excluded: Dictionary) -> String:
    var pool: Array = []
    for name in names:
        if excluded.has(name):
            continue
        pool.append({"eval": name, "weight": 1.0})
    if pool.is_empty():
        return ""
    return _weighted_pick(pool)

static func _sum_counts(counts: Dictionary, keys: Array) -> int:
    var total: = 0
    for k in keys:
        total += int(counts.get(k, 0))
    return total

static func _to_set(values: Array) -> Dictionary:
    var result: = {}
    for value in values:
        var eval_name: = str(value)
        if eval_name != "":
            result[eval_name] = true
    return result

static func _filter_excluded(candidates: Array, excluded: Dictionary) -> Array:
    if excluded.is_empty():
        return candidates
    var filtered: Array = []
    for c in candidates:
        if excluded.has(str(c.get("eval", ""))):
            continue
        filtered.append(c)
    return filtered


static func _weighted_pick(candidates: Array) -> String:
    if candidates.is_empty():
        return PLAQUE_ZHENGTONG
    if candidates.size() == 1:
        return str(candidates[0].get("eval", PLAQUE_ZHENGTONG))
    var weights: Array = []
    var total: = 0.0
    for c in candidates:
        var w: float = maxf(0.0001, float(c.get("weight", 1.0)))
        w = w * w
        weights.append(w)
        total += w
    var roll: = randf() * total
    var acc: = 0.0
    for i in range(candidates.size()):
        acc += weights[i]
        if roll <= acc:
            return str(candidates[i].get("eval", PLAQUE_ZHENGTONG))
    return str(candidates[candidates.size() - 1].get("eval", PLAQUE_ZHENGTONG))
