extends RefCounted
class_name ChoiceHintBuilder

const ChoiceRequirementServiceRef = preload("res://scripts/services/choice_requirement_service.gd")
const CHOICE_REQUIREMENT_HINT_MIN_VALUE: = 10

static func build_hidden_hint(choice: Dictionary, req: Dictionary, game_state: Node) -> String:
    if not choice.get("hidden", false):
        return ""

    var label: = str(choice.get("requireLabel", "")).strip_edges()
    if label != "" and label != "条件已达":
        return label

    var parts: Array[String] = []
    if not req.is_empty():
        var stat_key = req.get("stat", "")
        var stat_label = get_stat_label(stat_key)
        var req_val = int(req.get("value", req.get("min", 0)))
        if stat_key == "yinliang":
            parts.append("需要 库银 ≥ %d" % req_val)
        else:
            parts.append("需要 %s ≥ %d" % [stat_label, req_val])

    var req_fn: = str(choice.get("requireFn", "")).strip_edges()
    if req_fn != "":
        parts.append_array(build_require_fn_hints(req_fn))

    var req_char = choice.get("requireChar", [])
    if req_char is Array and req_char.size() > 0:
        for c in req_char:
            var char_name: = ""
            match c:
                "hanmen":
                    char_name = "寒门"
                "jinshen":
                    char_name = "缙绅"
                "shijia":
                    char_name = "没落世家"
                "qingwang":
                    char_name = "诗文清望"
                "neiting":
                    char_name = "游民"
                _:
                    char_name = str(c)
            if char_name != "":
                parts.append("需要出身：%s" % char_name)

    if parts.size() > 0:
        return "；".join(filter_redundant_hints(parts))

    return ""

static func build_satisfied_hints(ch: Dictionary, req: Dictionary, game_state: Node) -> String:
    var parts: Array[String] = []
    var effects = ch.get("effects", {})
    var skip_limit_for = ch.get("skipLimitFor", [])
    var require_label_text: = str(ch.get("requireLabel", "")).strip_edges()
    for k in effects:
        if k in skip_limit_for:
            continue
        if effects[k] < 0:
            var required_effect_value: int = absi(int(effects[k]))
            if not should_show_choice_requirement_value(required_effect_value):
                continue
            if k in ["liumin", "renkou_val", "zhengji"]:
                continue
            if requirement_label_covers(require_label_text, get_stat_label(k), required_effect_value):
                continue
            if k in game_state.stats:
                parts.append("需要 %s ≥ %d" % [get_stat_label(k), required_effect_value])
            elif k == "private_silver":
                parts.append("需要 %s ≥ %d" % [get_stat_label("private_silver"), required_effect_value])
            elif k in game_state.city:
                if GameData.CITY_STAT_KEYS.has(k):
                    continue
                if k == "yinliang":
                    parts.append("需要 库银 ≥ %d" % required_effect_value)
                else:
                    parts.append("需要 %s ≥ %d" % [get_stat_label(k), required_effect_value])

    var req_city = ch.get("requireCity", {})
    if not req_city.is_empty():
        var stat = req_city.get("stat", "")
        var val = req_city.get("min", req_city.get("value", 0))
        var stat_label = ch.get("requireCityLabel", "")
        if stat_label == "":
            if GameData.CITY_STAT_KEYS.has(stat):
                stat_label = GameData.city_stat_effect_label(stat)
            else:
                stat_label = GameData.CITY_STAT_LABELS.get(stat, GameData.STAT_LABELS.get(stat, stat))
        if stat == "yinliang":
            parts.append("需要 库银 ≥ %d" % val)
        else:
            parts.append("需要 %s ≥ %d" % [stat_label, val])

    if not req.is_empty():
        var stat_key = req.get("stat", "")
        var stat_label = get_stat_label(stat_key)
        var req_val = int(req.get("value", req.get("min", 0)))
        if stat_key == "yinliang":
            parts.append("lock_info需要 库银 ≥ %d" % req_val)
        else:
            parts.append("lock_info需要 %s ≥ %d" % [stat_label, req_val])

    var req_label = str(ch.get("requireLabel", "")).strip_edges()
    if req_label != "" and req_label != "条件已达":
        parts.append(format_requirement_label(req_label))

    if parts.size() > 0:
        return "；".join(filter_redundant_hints(parts)).replace("lock_info", "")
    return ""



static func requirement_label_covers(req_label: String, stat_label: String, value: int) -> bool:
    if req_label == "" or stat_label == "":
        return false
    var names: Array[String] = [stat_label]
    if stat_label.ends_with("等级"):
        names.append(stat_label.trim_suffix("等级"))
    var regex: = RegEx.new()
    for name in names:
        if regex.compile("%s\\s*(?:≥|>=|>)\\s*(\\d+)" % name) != OK:
            continue
        var res: = regex.search(req_label)
        if res != null and int(res.get_string(1)) >= value:
            return true
    return false



static func format_requirement_label(raw: String) -> String:
    var text: = raw.strip_edges()
    if text == "":
        return text
    if text.begins_with("需要") or text.begins_with("需"):
        return text
    return "需" + text

static func filter_redundant_hints(parts: Array[String]) -> Array[String]:
    if parts.size() <= 1:
        return parts

    var regex: = RegEx.new()
    regex.compile("^需要\\s*(.+?)\\s*(≥|≤|>=|<=|>|<|=|==|===)\\s*(\\d+)(次)?$")

    var best_values: = {}
    var key_to_prop: = {}
    var key_to_unit: = {}
    var processed_keys: = {}

    for part in parts:
        var txt: = part.strip_edges()
        var res: = regex.search(txt)
        if res != null:
            var prop: = res.get_string(1).strip_edges()
            var op: = res.get_string(2).strip_edges()
            var val: = int(res.get_string(3))
            var unit: = res.get_string(4)

            var norm_op: = op
            if norm_op in [">=", "≥"]: norm_op = "≥"
            elif norm_op in ["<=", "≤"]: norm_op = "≤"
            elif norm_op in ["==", "=", "==="]: norm_op = "="

            var key: = prop + "_" + norm_op + "_" + unit

            if not best_values.has(key):
                best_values[key] = val
                key_to_prop[key] = prop
                key_to_unit[key] = unit
            else:
                var current_val: int = best_values[key]
                if norm_op == "≥" or norm_op == ">":
                    if val > current_val:
                        best_values[key] = val
                elif norm_op == "≤" or norm_op == "<":
                    if val < current_val:
                        best_values[key] = val

    var filtered_parts: Array[String] = []

    for part in parts:
        var txt: = part.strip_edges()
        var res: = regex.search(txt)
        if res != null:
            var prop: = res.get_string(1).strip_edges()
            var op: = res.get_string(2).strip_edges()
            var unit: = res.get_string(4)

            var norm_op: = op
            if norm_op in [">=", "≥"]: norm_op = "≥"
            elif norm_op in ["<=", "≤"]: norm_op = "≤"
            elif norm_op in ["==", "=", "==="]: norm_op = "="

            var key: = prop + "_" + norm_op + "_" + unit

            if not processed_keys.has(key):
                processed_keys[key] = true
                var best_val: int = best_values[key]
                filtered_parts.append("需要 %s %s %d%s" % [prop, norm_op, best_val, unit])
        else:
            filtered_parts.append(part)

    return filtered_parts

static func should_show_choice_requirement_value(value: int) -> bool:
    return value > CHOICE_REQUIREMENT_HINT_MIN_VALUE

static func build_require_fn_hints(req_fn: String) -> Array[String]:
    var hints: Array[String] = []
    var expr: = ChoiceRequirementServiceRef.strip_wrapping_parentheses(req_fn.strip_edges())
    if expr == "":
        return hints

    var or_groups: = ChoiceRequirementServiceRef.split_require_fn(expr, "||")
    if or_groups.size() > 1:
        var alt_hints: Array[String] = []
        for group in or_groups:
            var alt: = build_require_fn_single_hint(group)
            if alt != "":
                alt_hints.append(alt)
        if alt_hints.size() > 0:
            hints.append(" 或 ".join(alt_hints))
        return hints

    for and_group in ChoiceRequirementServiceRef.split_require_fn(expr, "&&"):
        var sub: = ChoiceRequirementServiceRef.strip_wrapping_parentheses(and_group.strip_edges())
        if sub == "":
            continue
        if ChoiceRequirementServiceRef.split_require_fn(sub, "||").size() > 1 or ChoiceRequirementServiceRef.split_require_fn(sub, "&&").size() > 1:
            hints.append_array(build_require_fn_hints(sub))
        else:
            var hint: = format_require_fn_condition_hint(sub)
            if hint != "":
                hints.append(hint)
    return hints

static func build_require_fn_single_hint(expr: String) -> String:
    return "、".join(build_require_fn_hints(expr))

static func format_require_fn_condition_hint(condition: String) -> String:
    var text: = condition.strip_edges()
    var expected_present: = true
    if text.begins_with("!"):
        expected_present = false
        text = text.substr(1).strip_edges()

    if text.begins_with("hasItem(") or text.begins_with("G.items.includes("):
        var item_id: = ChoiceRequirementServiceRef.extract_call_string_argument(text)
        if item_id == "":
            return ""
        var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
        var item_name: = str(item_def.get("name", item_id))
        return "需要持有「%s」" % item_name if expected_present else "需要未持有「%s」" % item_name

    if "G.tags.includes" in text:
        var tag_name: = ChoiceRequirementServiceRef.extract_call_string_argument(text)
        if tag_name == "":
            return ""
        return "需要「%s」" % tag_name if expected_present else "需要未有「%s」" % tag_name

    if text.begins_with("G.keju_status"):
        var status: = text.split("==")[1].replace("'", "").replace("\"", "").replace(")", "").strip_edges() if "==" in text else ""
        return "需要科举状态：%s" % status if status != "" else ""

    if text.begins_with("G.lastBranchChoice"):
        var branch_choice: = extract_comparison_expected_text(text)
        return "需要路线：%s" % branch_choice if branch_choice != "" else ""

    if text.begins_with("G.historicalChains."):
        return format_historical_chain_hint(text)

    if text.begins_with("G.tags.filter(") and ".length" in text:
        var tag_name: = ChoiceRequirementServiceRef.extract_call_string_argument(text)
        var required_count: = extract_condition_number(text)
        if tag_name != "" and required_count > 0:
            return "需要「%s」≥ %d次" % [tag_name, required_count]

    var numeric_hint: = format_numeric_condition_hint(text)
    if numeric_hint != "":
        return numeric_hint

    return ""

static func format_numeric_condition_hint(text: String) -> String:
    var operator: = ""
    for candidate in [">=", "<=", ">", "<", "===", "=="]:
        if candidate in text:
            operator = candidate
            break
    if operator == "":
        return ""

    var parts: = text.split(operator)
    if parts.size() < 2:
        return ""

    var left: = parts[0].strip_edges()
    var value_text: = parts[1].strip_edges().replace(")", "")
    if not value_text.is_valid_int():
        return ""

    var label: = ""
    if left.begins_with("G.stats.") or left.begins_with("G.attitudes.") or left.begins_with("G.city."):
        label = get_stat_label(left.split(".")[2].strip_edges())
    elif left.begins_with("G.private_silver"):
        label = get_stat_label("private_silver")
    elif left.begins_with("stat(") or left.begins_with("att("):
        label = get_stat_label(ChoiceRequirementServiceRef.extract_call_string_argument(left))
    elif left.begins_with("merit()"):
        label = "政绩"

    if label == "":
        return ""

    var display_operator: = format_display_operator(operator)
    return "需要 %s %s %d" % [label, display_operator, int(value_text)]

static func format_display_operator(operator: String) -> String:
    match operator:
        ">=":
            return "≥"
        "<=":
            return "≤"
        "===", "==":
            return "="
    return operator

static func format_historical_chain_hint(text: String) -> String:
    var body: = text.replace("G.historicalChains.", "")
    var chain_id: = body.split(".")[0].strip_edges()
    if chain_id == "":
        return ""

    var chain_names: = {
        "ganshu": "甘薯试种", 
        "tangruowang": "汤若望铸炮", 
        "songyingxing": "宋应星农工", 
        "zhaoerhui": "赵二虎联饷", 
        "guyanwu": "顾炎武经世", 
        "gaowanli": "高万里海防"
    }
    var outcome_names: = {
        "saved_seed": "保留种薯", 
        "reduced": "缩减试种", 
        "accepted": "亲尝推广", 
        "endorsed": "乡老支持", 
        "rationed": "折粮入赈", 
        "halted": "暂止试种", 
        "stored": "暂存其书", 
        "cast": "铸成红夷大炮", 
        "rejected": "拒绝合作", 
        "delayed": "合作推迟", 
        "fullmerged": "全军合并", 
        "recruited": "募为亲兵", 
        "settled": "安置为民"
    }

    var chain_name: String = chain_names.get(chain_id, chain_id)

    if body == chain_id:
        return "需要完成「%s」线索" % chain_name

    var expected: = extract_comparison_expected_text(text)
    if expected != "":
        var expected_name: String = outcome_names.get(expected, expected)
        return "需要「%s」为 %s" % [chain_name, expected_name]
    return "需要「%s」线索" % chain_name

static func extract_condition_number(text: String) -> int:
    for operator in [">=", "<=", ">", "<", "===", "=="]:
        if operator in text:
            var parts: = text.split(operator)
            if parts.size() >= 2:
                var raw: = parts[1].strip_edges().replace(")", "")
                if raw.is_valid_int():
                    return int(raw)
    return 0

static func extract_comparison_expected_text(text: String) -> String:
    for operator in ["!==", "===", ">=", "<=", "==", ">", "<"]:
        if operator in text:
            var parts: = text.split(operator)
            if parts.size() >= 2:
                return parts[1].strip_edges().replace("\"", "").replace("'", "").replace(")", "")
    return ""

static func get_stat_label(stat_key: String) -> String:
    var base = GameData.STAT_LABELS.get(stat_key, GameData.ATT_LABELS.get(stat_key, GameData.CITY_STAT_LABELS.get(stat_key, stat_key)))
    if stat_key == "guanjun" and is_instance_valid(GameState) and "bianwu_units" in GameState and not GameState.bianwu_units.is_empty():
        for u in GameState.bianwu_units:
            if u is Dictionary and not u.get("is_jiading", false):
                base = u.get("name", base)
                break
    elif stat_key == "jiading" and is_instance_valid(GameState) and "bianwu_units" in GameState and not GameState.bianwu_units.is_empty():
        for u in GameState.bianwu_units:
            if u is Dictionary and u.get("is_jiading", false):
                base = u.get("name", base)
                break
    if stat_key in ["nongsang", "shangmao", "baigong", "wenjiao", "chengfang"]:
        return base + "等级"
    return base
