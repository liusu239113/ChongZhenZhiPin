extends RefCounted
class_name ChoiceTitleFormatter




static func format_title(raw_title: Variant, shorten: bool = false) -> String:
    var title: = str(raw_title).strip_edges()
    var suffix: = ""
    if title.begins_with("【") and title.find("】") > 0:
        var close_idx: = title.find("】")
        suffix = title.substr(close_idx + 1).strip_edges()
        title = title.substr(1, close_idx - 1).strip_edges()

    title = title.replace("(", "（").replace(")", "）")
    title = title.replace("（一甲专属）", "")
    title = title.replace("（一甲专）", "")
    title = title.strip_edges()
    var marker: = ""
    var paren_idx: = title.find("（")
    if paren_idx >= 0 and title.ends_with("）"):
        marker = title.substr(paren_idx + 1, title.length() - paren_idx - 2).strip_edges()
        title = title.substr(0, paren_idx).strip_edges()

    if shorten:
        title = title.substr(0, mini(title.length(), 10))
        suffix = ""

    var result: = ""
    if marker != "":
        result = "【%s·%s】" % [title, marker]
    else:
        result = "【%s】" % title

    if suffix != "":
        var unified_suffix: = suffix
        var has_outer_bracket: = (unified_suffix.begins_with("「") and unified_suffix.ends_with("」")) or (unified_suffix.begins_with("“") and unified_suffix.ends_with("”"))
        if has_outer_bracket:
            var outer_left = "「"
            var outer_right = "」"
            var inner_content = unified_suffix.substr(1, unified_suffix.length() - 2)
            inner_content = inner_content.replace("「", "『").replace("」", "』")
            inner_content = inner_content.replace("“", "『").replace("”", "』")
            unified_suffix = outer_left + inner_content + outer_right
        else:
            unified_suffix = unified_suffix.replace("“", "「").replace("”", "」")
            unified_suffix = unified_suffix.replace("『", "「").replace("』", "」")
        var final_suffix: = ""
        var in_quote: = false
        for c in unified_suffix:
            if c == "\"":
                if not in_quote:
                    final_suffix += "「"
                    in_quote = true
                else:
                    final_suffix += "」"
                    in_quote = false
            else:
                final_suffix += c
        result += final_suffix

    return result

static func split_title(raw_title: Variant, shorten: bool = false) -> Dictionary:
    var formatted: = format_title(raw_title, shorten)
    var tag: = ""
    var line: = formatted
    if formatted.begins_with("【") and formatted.find("】") > 0:
        var close_idx: = formatted.find("】")
        tag = formatted.substr(1, close_idx - 1).strip_edges()
        line = formatted.substr(close_idx + 1).strip_edges()
    return {"tag": tag, "line": line}

static func keep_alphanumeric_and_chinese(text: String) -> String:
    var res = ""
    for i in range(text.length()):
        var c = text.unicode_at(i)
        if (c >= 19968 and c <= 40869) or (c >= 48 and c <= 57) or (c >= 65 and c <= 90) or (c >= 97 and c <= 122):
            res += text[i]
    return res

static func calculate_similarity(s1: String, s2: String) -> float:
    if s1 == s2:
        return 1.0
    var len1 = s1.length()
    var len2 = s2.length()
    if len1 == 0 or len2 == 0:
        return 0.0
    if absi(len1 - len2) > 6:
        return 0.0
    var match_count = 0
    var max_len = maxi(len1, len2)
    for i in range(len1):
        if s2.contains(s1[i]):
            match_count += 1
    return float(match_count) / float(max_len)

static func calc_lcs_length(s1: String, s2: String) -> int:
    var len1: = s1.length()
    var len2: = s2.length()
    if len1 == 0 or len2 == 0:
        return 0

    var dp: Array[int] = []
    for j in range(len2 + 1):
        dp.append(0)

    for i in range(1, len1 + 1):
        var prev: = 0
        for j in range(1, len2 + 1):
            var temp: int = dp[j]
            if s1[i - 1] == s2[j - 1]:
                dp[j] = prev + 1
            else:
                dp[j] = maxi(dp[j], dp[j - 1])
            prev = temp
    return dp[len2]

static func is_action_desc_duplicate(action_desc: String, sys_comment: String) -> bool:
    var clean_action: = keep_alphanumeric_and_chinese(action_desc)
    var clean_sys: = keep_alphanumeric_and_chinese(sys_comment)

    if clean_action == "" or clean_sys == "":
        return false

    if clean_sys.contains(clean_action) or clean_action.contains(clean_sys):
        return true

    var lcs_len: = calc_lcs_length(clean_action, clean_sys)
    var ratio: = float(lcs_len) / float(clean_action.length())
    if ratio >= 0.75:
        return true

    return false

static func extract_actual_action_desc(raw_title: String, raw_desc: String) -> String:
    var title = raw_title.strip_edges()
    var desc = raw_desc.strip_edges()
    var dialogue = title
    if title.begins_with("【") and title.find("】") > 0:
        dialogue = title.substr(title.find("】") + 1).strip_edges()
    var clean_dialogue = keep_alphanumeric_and_chinese(dialogue)
    var clean_desc = keep_alphanumeric_and_chinese(desc)
    if clean_dialogue == clean_desc or clean_desc == "":
        return ""
    if clean_desc.begins_with(clean_dialogue):
        var stripped_desc = desc
        var strip_dial = dialogue.replace("「", "").replace("」", "").replace("“", "").replace("”", "").replace("\"", "").strip_edges()
        if strip_dial != "" and desc.contains(strip_dial):
            stripped_desc = desc.replace(strip_dial, "")
        var final_res = stripped_desc.strip_edges()
        while final_res.length() > 0 and (final_res.begins_with("。") or final_res.begins_with("，") or final_res.begins_with("；") or final_res.begins_with("、") or final_res.begins_with(".")):
            final_res = final_res.substr(1).strip_edges()
        return final_res
    if calculate_similarity(clean_dialogue, clean_desc) > 0.8:
        return ""
    return desc
