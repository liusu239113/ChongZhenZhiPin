extends RefCounted
class_name ChoiceRequirementService

static func require_fn_uses_boolean_state(req_fn: String) -> bool:
    return "hasItem" in req_fn or "G.items" in req_fn or "G.historicalChains" in req_fn or "G.tags.filter" in req_fn or "G.lastBranchChoice" in req_fn or "stat(" in req_fn or "att(" in req_fn or "guozuo()" in req_fn or "hasDezhengMandate" in req_fn

static func strip_wrapping_parentheses(raw_text: String) -> String:
    var text: = raw_text.strip_edges()
    while text.begins_with("(") and text.ends_with(")"):
        var depth: = 0
        var wraps_entire: = true
        for idx in range(text.length()):
            var ch: = text.substr(idx, 1)
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
                if depth == 0 and idx < text.length() - 1:
                    wraps_entire = false
                    break
        if not wraps_entire:
            break
        text = text.substr(1, text.length() - 2).strip_edges()
    return text

static func evaluate_require_fn(req_fn: String, game_state: Node) -> bool:
    var expr: = strip_wrapping_parentheses(req_fn)
    var or_groups: = split_require_fn(expr, "||")
    if or_groups.size() > 1:
        for group in or_groups:
            if evaluate_require_fn(group, game_state):
                return true
        return false

    var and_groups: = split_require_fn(expr, "&&")
    if and_groups.size() > 1:
        for group in and_groups:
            if not evaluate_require_fn(group, game_state):
                return false
        return true

    return evaluate_require_fn_condition(expr, game_state)

static func split_require_fn(text: String, separator: String) -> Array[String]:
    var parts: Array[String] = []
    var depth: = 0
    var in_quote: = false
    var quote_char: = ""
    var start: = 0
    var idx: = 0
    while idx < text.length():
        var ch: = text.substr(idx, 1)
        if in_quote:
            if ch == quote_char:
                in_quote = false
        elif ch == "\"" or ch == "'":
            in_quote = true
            quote_char = ch
        elif ch == "(":
            depth += 1
        elif ch == ")":
            depth = maxi(depth - 1, 0)
        elif depth == 0 and text.substr(idx, separator.length()) == separator:
            parts.append(text.substr(start, idx - start).strip_edges())
            idx += separator.length()
            start = idx
            continue
        idx += 1
    parts.append(text.substr(start).strip_edges())
    return parts

static func evaluate_require_fn_condition(cond: String, game_state: Node) -> bool:
    var text: = cond.strip_edges()
    if "hasDezhengMandate" in text:
        var has_not = "!" in text
        return not game_state.has_dezheng_mandate() if has_not else game_state.has_dezheng_mandate()
    if text == "G.historicalChains":
        return not game_state.historical_chains.is_empty()
    if "G.tags.includes" in text:
        var tag_match: = extract_call_string_argument(text.replace("!", ""))
        var expected: = not text.begins_with("!")
        return game_state.tags.has(tag_match) == expected
    if text.begins_with("G.tags.filter(") and ".length" in text:
        return evaluate_tags_count_condition(text, game_state)
    if text.begins_with("G.lastBranchChoice"):
        return evaluate_last_branch_choice_condition(text, game_state)
    if text.begins_with("G.items.includes("):
        var item_id: = extract_call_string_argument(text)
        return item_id != "" and game_state.items.has(item_id)
    if text.begins_with("[") and ".filter(" in text and "G.items.includes(x)" in text and ".length" in text:
        return evaluate_explicit_items_count_condition(text, game_state)
    if text.begins_with("G.items.filter(") and ".startsWith(" in text and ".length" in text:
        return evaluate_items_prefix_count_condition(text, game_state)
    if text.begins_with("hasItem("):
        var item_id: = extract_call_string_argument(text)
        return item_id != "" and game_state.items.has(item_id)
    if text.begins_with("G.stats.") or text.begins_with("G.attitudes.") or text.begins_with("G.city.") or text.begins_with("G.private_silver") or text.begins_with("stat(") or text.begins_with("att(") or text.begins_with("merit()") or text.begins_with("guozuo()"):
        return evaluate_stat_or_resource_condition(text, game_state)
    if not text.begins_with("G.historicalChains."):
        return false

    var body: = text.replace("G.historicalChains.", "")
    var chain_id: = body.split(".")[0].strip_edges()
    if chain_id == "":
        return false
    var chain_state: Dictionary = game_state.historical_chains.get(chain_id, {})
    if chain_state.is_empty():
        return false
    if body == chain_id:
        return true

    var field_expr: = body.substr(chain_id.length() + 1)
    var operator: = ""
    for candidate in ["!==", "===", ">=", "<=", ">", "<"]:
        if candidate in field_expr:
            operator = candidate
            break
    if operator == "":
        return false

    var parts: = field_expr.split(operator)
    if parts.size() < 2:
        return false
    var field_name: = parts[0].strip_edges()
    var expected_raw: = strip_string_literal_quotes(parts[1].strip_edges()).replace("\"", "").replace("'", "")
    var actual: Variant = chain_state.get(field_name, null)
    match operator:
        "===":
            return str(actual) == expected_raw
        "!==":
            return str(actual) != expected_raw
        ">=":
            return int(actual) >= int(expected_raw)
        "<=":
            return int(actual) <= int(expected_raw)
        ">":
            return int(actual) > int(expected_raw)
        "<":
            return int(actual) < int(expected_raw)
    return false

static func extract_call_string_argument(text: String) -> String:
    var open_idx: = text.find("(")
    var close_idx: = text.rfind(")")
    if open_idx < 0 or close_idx <= open_idx:
        return ""
    var raw_arg: = text.substr(open_idx + 1, close_idx - open_idx - 1).strip_edges()
    return strip_string_literal_quotes(raw_arg)

static func strip_string_literal_quotes(raw_arg: String) -> String:
    if raw_arg.length() >= 2:
        var first: = raw_arg.substr(0, 1)
        var last: = raw_arg.substr(raw_arg.length() - 1, 1)
        if (first == "\"" and last == "\"") or (first == "'" and last == "'")\
or (first == "「" and last == "」") or (first == "『" and last == "』"):
            return raw_arg.substr(1, raw_arg.length() - 2)
    return raw_arg

static func evaluate_last_branch_choice_condition(text: String, game_state: Node) -> bool:
    for candidate in ["===", "!==", "==", "!="]:
        if candidate in text:
            var parts: = text.split(candidate)
            if parts.size() < 2:
                return false
            var expected: = parts[1].strip_edges().replace("\"", "").replace("'", "")
            var is_equal: bool = game_state.last_branch_choice == expected
            return not is_equal if "!" in candidate else is_equal
    return false

static func evaluate_stat_or_resource_condition(text: String, game_state: Node) -> bool:
    var operator: = ""
    for candidate in [">=", "<=", "===", "!==", ">", "<"]:
        if candidate in text:
            operator = candidate
            break
    if operator == "":
        return false
    var parts: = text.split(operator)
    if parts.size() < 2:
        return false

    var left: = parts[0].strip_edges()
    var expected: = int(parts[1].strip_edges())
    var current: = 0
    if left.begins_with("G.private_silver"):
        current = int(game_state.private_silver)
    elif left.begins_with("merit()"):
        current = int(game_state.get_governance_merit())
    elif left.begins_with("guozuo()"):
        current = int(game_state.get_guozuo_count()) if game_state.has_method("get_guozuo_count") else 0
    elif left.begins_with("G.stats."):
        current = int(game_state.stats.get(left.replace("G.stats.", "").strip_edges(), 0))
    elif left.begins_with("G.attitudes."):
        current = int(game_state.attitudes.get(left.replace("G.attitudes.", "").strip_edges(), 0))
    elif left.begins_with("G.city."):
        current = int(game_state.city.get(left.replace("G.city.", "").strip_edges(), 0))
    elif left.begins_with("stat("):
        current = int(game_state.stats.get(extract_call_string_argument(left), 0))
    elif left.begins_with("att("):
        current = int(game_state.attitudes.get(extract_call_string_argument(left), 0))
    else:
        return false

    match operator:
        ">=":
            return current >= expected
        "<=":
            return current <= expected
        "===":
            return current == expected
        "!==":
            return current != expected
        ">":
            return current > expected
        "<":
            return current < expected
    return false

static func evaluate_tags_count_condition(text: String, game_state: Node) -> bool:
    var equals_marker: = "x==="
    var tag_start: = text.find(equals_marker)
    if tag_start < 0:
        equals_marker = "x=="
        tag_start = text.find(equals_marker)
    if tag_start < 0:
        return false
    tag_start += equals_marker.length()
    var tag_end: = text.find(")", tag_start)
    if tag_end <= tag_start:
        return false
    var raw_tag: = text.substr(tag_start, tag_end - tag_start).strip_edges()
    var tag: = strip_string_literal_quotes(raw_tag)
    if tag == "":
        return false

    var operator: = ""
    for candidate in [">=", "<=", "===", ">", "<"]:
        if candidate in text:
            operator = candidate
            break
    if operator == "":
        return false
    var parts: = text.split(operator)
    if parts.size() < 2:
        return false
    var expected: = int(parts[1].strip_edges())
    var count: int = game_state.tags.count(tag)
    match operator:
        ">=":
            return count >= expected
        "<=":
            return count <= expected
        "===":
            return count == expected
        ">":
            return count > expected
        "<":
            return count < expected
    return false

static func evaluate_items_prefix_count_condition(text: String, game_state: Node) -> bool:
    var prefix_marker: = "startsWith("
    var prefix_start: = text.find(prefix_marker)
    if prefix_start < 0:
        return false
    prefix_start += prefix_marker.length()
    var prefix_end: = text.find(")", prefix_start)
    if prefix_end <= prefix_start:
        return false
    var raw_prefix: = text.substr(prefix_start, prefix_end - prefix_start).strip_edges()
    var prefix: = strip_string_literal_quotes(raw_prefix)
    if prefix == "":
        return false

    var operator: = ""
    for candidate in [">=", "<=", "===", ">", "<"]:
        if candidate in text:
            operator = candidate
            break
    if operator == "":
        return false
    var parts: = text.split(operator)
    if parts.size() < 2:
        return false
    var expected: = int(parts[1].strip_edges())
    var count: = 0
    for item_id in game_state.items:
        if str(item_id).begins_with(prefix):
            count += 1
    match operator:
        ">=":
            return count >= expected
        "<=":
            return count <= expected
        "===":
            return count == expected
        ">":
            return count > expected
        "<":
            return count < expected
    return false

static func evaluate_explicit_items_count_condition(text: String, game_state: Node) -> bool:
    var list_end: = text.find("]")
    if list_end <= 0:
        return false
    if not ".filter(" in text or not "G.items.includes(x)" in text or not ".length" in text:
        return false

    var raw_list: = text.substr(1, list_end - 1)
    var required_items: Array = []
    var idx: = 0
    while idx < raw_list.length():
        var ch: = raw_list.substr(idx, 1)
        if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" or ch == ",":
            idx += 1
            continue
        if ch != "\"" and ch != "'":
            return false
        var quote: = ch
        idx += 1
        var item_start: = idx
        while idx < raw_list.length() and raw_list.substr(idx, 1) != quote:
            idx += 1
        if idx >= raw_list.length():
            return false
        var item_id: = raw_list.substr(item_start, idx - item_start)
        if item_id != "":
            required_items.append(item_id)
        idx += 1
    if required_items.is_empty():
        return false

    var operator: = ""
    for candidate in [">=", "<=", "===", "==", ">", "<"]:
        if candidate in text:
            operator = candidate
            break
    if operator == "":
        return false
    var parts: = text.split(operator)
    if parts.size() < 2:
        return false
    var expected: = int(parts[1].strip_edges())
    var count: = 0
    for item_id in required_items:
        if game_state.items.has(item_id):
            count += 1
    match operator:
        ">=":
            return count >= expected
        "<=":
            return count <= expected
        "===":
            return count == expected
        "==":
            return count == expected
        ">":
            return count > expected
        "<":
            return count < expected
    return false

static func stat_label(stat_key: String) -> String:
    var base = GameData.STAT_LABELS.get(stat_key, GameData.ATT_LABELS.get(stat_key, GameData.CITY_STAT_LABELS.get(stat_key, stat_key)))
    if stat_key in ["nongsang", "shangmao", "baigong", "wenjiao", "chengfang"]:
        return base + "等级"
    return base

static func stat_or_resource_value(stat_key: String, game_state: Node) -> int:
    if stat_key == "private_silver":
        return int(game_state.private_silver)
    if stat_key in game_state.attitudes:
        return int(game_state.attitudes.get(stat_key, 0))
    if stat_key in game_state.city:
        return int(game_state.city.get(stat_key, 0))
    return int(game_state.stats.get(stat_key, 0))

static func parse_dice_eligibility(ch: Dictionary, game_state: Node) -> Dictionary:
    var unlocked = true
    var dice_eligible = false
    var gap = 0
    var multi_gaps = []
    var multi_labels = []
    var multi_targets = []
    var multi_keys = []
    var gap_targets = []
    var direct_req = ch.get("require", ch.get("requirement", {}))
    if not direct_req.is_empty():
        var req_stat: = str(direct_req.get("stat", ""))
        var req_val: = int(direct_req.get("value", direct_req.get("min", 0)))
        var current_val: = stat_or_resource_value(req_stat, game_state)
        if current_val >= req_val:
            return {"unlocked": true, "dice": {"eligible": false, "gap": 0, "target": req_val, "label": stat_label(req_stat), "key": req_stat, "multi_gaps": [], "multi_labels": []}}
        return {"unlocked": false, "dice": {"eligible": true, "gap": req_val - current_val, "target": req_val, "label": stat_label(req_stat), "key": req_stat, "multi_gaps": [], "multi_labels": []}}

    if ch.has("requireFn"):
        var req_fn: String = ch["requireFn"]
        if require_fn_uses_boolean_state(req_fn) or "<" in req_fn:
            return {"unlocked": evaluate_require_fn(req_fn, game_state), "dice": {"eligible": false, "gap": 0, "multi_gaps": [], "multi_labels": []}}
        if "&&" in req_fn and "||" in req_fn:
            return {"unlocked": evaluate_require_fn(req_fn, game_state), "dice": {"eligible": false, "gap": 0, "multi_gaps": [], "multi_labels": []}}

        var is_or = "||" in req_fn
        var separator = "||" if is_or else "&&"
        var conditions = req_fn.split(separator)
        var gaps = []
        var bool_success_count = 0
        var bool_fail_count = 0
        var stat_success_count = 0

        for cond in conditions:
            cond = cond.strip_edges()
            if "G.tags" in cond:
                var tag_match = cond.replace("!", "").replace("G.tags.includes(\"", "").replace("\")", "")
                var expected = not ("!" in cond)
                if game_state.tags.has(tag_match) == expected:
                    bool_success_count += 1
                else:
                    bool_fail_count += 1
                continue

            if "G.keju_status" in cond:
                var expected_match = strip_string_literal_quotes(cond.split("==")[1].replace("'", "").replace("\"", "").replace(")", "").strip_edges())
                if game_state.keju_status == expected_match:
                    bool_success_count += 1
                else:
                    bool_fail_count += 1
                continue

            if "G.stats" in cond or "G.attitudes" in cond or "G.city" in cond or "G.private_silver" in cond or "merit()" in cond:
                var comp_split = cond.replace(">=", "<=").replace(">", "<=").split("<=")
                if comp_split.size() < 2:
                    continue
                var m_type = "stats"
                if "G.attitudes" in cond: m_type = "attitudes"
                elif "G.city" in cond: m_type = "city"
                elif "G.private_silver" in cond: m_type = "private_silver"
                elif "merit()" in cond: m_type = "merit"
                var key_parts = comp_split[0].split(".")
                if m_type not in ["private_silver", "merit"] and key_parts.size() < 3:
                    continue
                var m_key = m_type if m_type in ["private_silver", "merit"] else key_parts[2].replace(")", "").strip_edges()
                var m_val = comp_split[1].strip_edges().to_int()

                var db = game_state.stats
                if m_type == "attitudes": db = game_state.attitudes
                elif m_type == "city": db = game_state.city
                var current = game_state.private_silver if m_type == "private_silver" else game_state.get_governance_merit() if m_type == "merit" else db.get(m_key, 0)

                if current >= m_val:
                    stat_success_count += 1
                else:
                    gaps.append(m_val - current)
                    gap_targets.append(m_val)

                if not is_or:
                    var label_name = "政绩" if m_type == "merit" else stat_label(m_key)
                    multi_gaps.append(max(0, m_val - current))
                    multi_labels.append(label_name)
                    multi_targets.append(m_val)
                    multi_keys.append(m_key)

        if is_or:
            if bool_success_count > 0 or stat_success_count > 0:
                unlocked = true
            else:
                unlocked = false
                if gaps.size() > 0:
                    dice_eligible = true
                    gap = gaps.min()
        else:
            if bool_fail_count > 0:
                unlocked = false
                dice_eligible = false
            elif gaps.size() > 0:
                unlocked = false
                dice_eligible = true
                gap = gaps.max()
            else:
                unlocked = true

    var final_multi_gaps = multi_gaps if multi_gaps.size() > 1 else []
    var final_multi_labels = multi_labels if multi_labels.size() > 1 else []
    var final_multi_targets = multi_targets if multi_targets.size() > 1 else []
    var final_multi_keys = multi_keys if multi_keys.size() > 1 else []
    var final_target = gap_targets.max() if gap_targets.size() > 0 else 0
    return {"unlocked": unlocked, "dice": {"eligible": dice_eligible, "gap": gap, "target": final_target, "multi_gaps": final_multi_gaps, "multi_labels": final_multi_labels, "multi_targets": final_multi_targets, "multi_keys": final_multi_keys}}

static func calc_dice_threshold(gap: int) -> Dictionary:
    var filled = "●"
    var empty = "○"




    if gap <= 0: return {"min": -99, "dots": "", "label": "已达标", "level": 0}
    if gap <= 5: return {"min": 2, "dots": filled + filled + filled + filled + empty, "label": "几无悬念", "level": 1}
    if gap <= 15: return {"min": 3, "dots": filled + filled + filled + empty + empty, "label": "尚有把握", "level": 2}
    if gap <= 25: return {"min": 4, "dots": filled + filled + empty + empty + empty, "label": "胜负难料", "level": 3}
    return {"min": 5, "dots": filled + empty + empty + empty + empty, "label": "九死一生", "level": 4}

static func dice_pass_hint(min_val: int) -> String:
    if min_val <= -99:
        return "无需投骰即可通过"
    var number_map = {
        1: "一", 
        2: "二", 
        3: "三", 
        4: "四", 
        5: "五", 
        6: "六"
    }
    var pass_numbers = []
    var start_val = min_val
    if start_val < 1:
        start_val = 1
    for i in range(start_val, 7):
        pass_numbers.append(number_map[i])
    if pass_numbers.size() == 0:
        return "结果不可通过"
    var pass_str = ""
    for val in pass_numbers:
        pass_str += val
    return "结果为" + pass_str + "可通过"
