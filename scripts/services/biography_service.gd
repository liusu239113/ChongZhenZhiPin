extends RefCounted
class_name BiographyService

const MAX_BODY_CHARS: = 78

static func make_marker_entry(game_state: Node, marker_id: String) -> Dictionary:
    var entry: = _base_entry(game_state)
    entry["id"] = marker_id
    entry["kind"] = "marker"
    entry["priority"] = 95
    match marker_id:
        "start_chongzhen":
            entry["title"] = "贡士入场"
            entry["body"] = "崇祯元年，以贡士身份入京殿试，仕途由此开卷。"
            entry["year_label"] = "崇祯元年"
            entry["cz_year"] = 1
        "start_origin":
            entry["title"] = "一岁开卷"
            entry["body"] = "一岁抓周，寒门生涯自此起笔。"
            entry["year_label"] = "一岁"
            entry["age"] = 1
            entry["cz_year"] = 0
        _:
            entry["title"] = marker_id
            entry["body"] = marker_id
    return entry

static func make_choice_entry(game_state: Node, event_data: Dictionary, choice: Dictionary, choice_index: int) -> Dictionary:
    var entry: = _base_entry(game_state)





    entry["stage"] = str(event_data.get("stage", ""))
    var cz_ordinal: = _resolve_cz_ordinal(game_state, event_data)
    entry["cz_year"] = cz_ordinal
    if cz_ordinal >= 1:
        entry["year_label"] = _format_cz_year(cz_ordinal)
    entry["id"] = _entry_id(event_data, choice, choice_index, entry)
    entry["kind"] = _entry_kind(game_state, event_data, choice)
    entry["priority"] = _entry_priority(entry["kind"], event_data, choice)
    entry["title"] = _clean_choice_title(choice)
    entry["body"] = _choice_body(event_data, choice, entry["title"])
    if str(entry["title"]) == "" and str(event_data.get("title", "")) != "":
        entry["title"] = str(event_data.get("title", ""))
    if str(entry["body"]) == "":
        entry["body"] = str(event_data.get("cardSummary", ""))
    entry["body"] = _trim_to_sentence(str(entry["body"]), MAX_BODY_CHARS)
    return entry

static func build_biography_text(game_state: Node, ending: Dictionary) -> String:
    var raw_entries: Array = []
    if game_state != null:
        raw_entries = game_state.life_chronicle_entries.duplicate(true)
    for raw in raw_entries:
        if raw is Dictionary:
            _repair_entry_chronology(raw, game_state)
    var entries: = _dedupe_entries(raw_entries)
    var selected: Array = []
    selected.append_array(_select_age_entries(entries))
    selected.append_array(_select_keju_entries(entries))
    selected.append_array(_select_governance_year_entries(entries))
    selected.append(_make_ending_entry(game_state, ending))
    selected = _dedupe_entries(selected)
    selected.sort_custom(Callable(BiographyService, "_sort_entry"))

    var lines: = PackedStringArray()
    lines.append("生平小传")
    lines.append("")
    if selected.is_empty():
        lines.append("此生行迹散佚，只余终局一笔。")
    else:
        for entry in selected:
            var line: = _format_entry(entry)
            if line != "":
                lines.append(line)
    return "\n".join(lines)

static func _resolve_cz_ordinal(game_state: Node, event_data: Dictionary) -> int:





    var ey: = int(event_data.get("year", 0))
    if ey >= 1500:

        return max(0, ey - 1627)
    if ey >= 1 and ey <= 40:

        return ey

    var from_stage: = _parse_cz_from_stage(str(event_data.get("stage", "")))
    if from_stage > 0:
        return from_stage

    if game_state != null and game_state.has_method("is_governance_mode") and game_state.is_governance_mode():
        return max(0, int(game_state.year))
    return 0

static func _repair_entry_chronology(entry: Dictionary, game_state: Node) -> void :



    var stage: = str(entry.get("stage", ""))
    if stage == "":
        stage = _lookup_event_stage(_event_id_of(entry), game_state)
        if stage != "":
            entry["stage"] = stage
    if stage == "":
        return
    var cz: = _parse_cz_from_stage(stage)
    if cz >= 1:
        entry["cz_year"] = cz
        entry["year_label"] = _format_cz_year(cz)

static func _event_id_of(entry: Dictionary) -> String:
    var id: = str(entry.get("id", ""))
    var colon: = id.find(":")
    return id.substr(0, colon) if colon > 0 else id

static func _lookup_event_stage(event_id: String, game_state: Node) -> String:
    if event_id == "":
        return ""
    var loop: = Engine.get_main_loop()
    if loop == null or not loop is SceneTree:
        return ""
    var gd = (loop as SceneTree).root.get_node_or_null("GameData")
    if gd == null:
        return ""
    for branch_key in gd.branch_events:
        var stage: = _find_stage_in_array(gd.branch_events[branch_key], event_id)
        if stage != "":
            return stage
    for arr in [gd.events, gd.prison_events, gd.wartime_events]:
        var stage: = _find_stage_in_array(arr, event_id)
        if stage != "":
            return stage
    return ""

static func _find_stage_in_array(arr, event_id: String) -> String:
    if not arr is Array:
        return ""
    for ev in arr:
        if ev is Dictionary and str(ev.get("id", "")) == event_id:
            return str(ev.get("stage", ""))
    return ""

static func _parse_cz_from_stage(text: String) -> int:
    var idx: = text.find("崇祯")
    if idx < 0:
        return 0
    var rest: = text.substr(idx + 2)
    var end: = rest.find("年")
    if end <= 0:
        return 0
    return _cz_zh_to_int(rest.substr(0, end).strip_edges())

static func _cz_zh_to_int(s: String) -> int:
    if s == "元":
        return 1
    var digits: = {"零": 0, "〇": 0, "一": 1, "二": 2, "三": 3, "四": 4, "五": 5, "六": 6, "七": 7, "八": 8, "九": 9}
    if s == "十":
        return 10
    if s.begins_with("十"):
        return 10 + int(digits.get(s.substr(1), 0))
    if s.contains("十"):
        var parts: = s.split("十")
        var tens: = int(digits.get(parts[0], 0)) * 10
        var ones: = 0
        if parts.size() > 1 and str(parts[1]) != "":
            ones = int(digits.get(parts[1], 0))
        return tens + ones
    return int(digits.get(s, 0))

static func _base_entry(game_state: Node) -> Dictionary:
    var cz_year: = 0
    var age: = 0
    var year_label: = ""
    if game_state != null:
        if game_state.has_method("get_czYear"):
            cz_year = int(game_state.get_czYear())
        if "age" in game_state:
            age = int(game_state.age)
        if game_state.has_method("get_current_year_str"):
            year_label = str(game_state.get_current_year_str())
    if year_label == "" and cz_year > 0:
        year_label = _format_cz_year(cz_year)
    elif year_label == "" and age > 0:
        year_label = "%d岁" % age
    return {
        "id": "", 
        "turn": int(game_state.turn) if game_state != null else 0, 
        "age": age, 
        "cz_year": cz_year, 
        "year": int(game_state.year) if game_state != null else 0, 
        "month": int(game_state.month) if game_state != null else 0, 
        "year_label": year_label, 
        "kind": "event", 
        "priority": 20, 
        "title": "", 
        "body": ""
    }

static func _entry_id(event_data: Dictionary, choice: Dictionary, choice_index: int, entry: Dictionary) -> String:
    var event_id: = str(event_data.get("id", "event"))
    var choice_id: = str(choice.get("id", choice.get("branchChoice", choice_index)))
    return "%s:%s:%s:%s" % [event_id, choice_id, entry.get("turn", 0), entry.get("cz_year", 0)]

static func _entry_kind(game_state: Node, event_data: Dictionary, choice: Dictionary) -> String:
    if choice.has("setKejuStatus") or choice.has("startKeju"):
        return "keju"
    if choice.get("enterGovernance", false):
        return "keju"
    if choice.has("endingKey") or choice.has("triggerEnding") or event_data.get("isEnding", false):
        return "ending_choice"
    if game_state != null and game_state.has_method("is_governance_mode") and game_state.is_governance_mode():
        return "governance"
    return "age_event"

static func _entry_priority(kind: String, event_data: Dictionary, choice: Dictionary) -> int:
    if kind == "ending_choice":
        return 100
    if choice.get("enterGovernance", false):
        return 90
    if choice.has("setKejuStatus"):
        return 88
    if str(event_data.get("type", "")) == "story":
        return 82
    if str(event_data.get("type", "")) in ["court", "court_chain", "visitor"]:
        return 70
    if choice.has("grantItem") or choice.has("grantGuozuo") or choice.has("rankUp"):
        return 64
    if kind == "governance":
        return 42
    return 30

static func _clean_choice_title(choice: Dictionary) -> String:
    var title: = str(choice.get("title", choice.get("desc", choice.get("description", "")))).strip_edges()
    title = title.replace("\n", " ")
    if title.begins_with("【") and title.contains("】"):
        var right: = title.find("】")
        var tag: = title.substr(1, right - 1).strip_edges()
        var rest: = title.substr(right + 1).strip_edges()
        return tag if tag != "" else rest
    return _compact_text(title, 18)

static func _choice_body(event_data: Dictionary, choice: Dictionary, fallback_title: String) -> String:

    if choice.has("setKejuStatus"):
        var keju_fallback: = str(choice.get("systemComment", choice.get("comment", ""))).strip_edges()
        return _keju_status_sentence(str(choice.get("setKejuStatus", "")), keju_fallback)
    if choice.get("enterGovernance", false):
        return "释褐为官，自此转入崇祯朝治世，亲莅亲民之任。"

    var body: = str(choice.get("comment", "")).strip_edges()
    if body == "":
        body = str(choice.get("systemComment", "")).strip_edges()
    if body == "":
        body = str(choice.get("description", choice.get("desc", ""))).strip_edges()
    if body == "":
        body = str(event_data.get("cardSummary", "")).strip_edges()
    if body == "" and fallback_title != "":
        body = fallback_title

    if str(event_data.get("type", "")) == "story" and str(event_data.get("title", "")) != "":
        var ev_title: = str(event_data.get("title", "")).strip_edges()
        if not body.begins_with(ev_title):
            body = "%s。%s" % [ev_title, body]
    return body

static func _keju_status_sentence(status: String, fallback: String) -> String:
    match status:
        "tongshi":
            return "考取童生。"
        "xiucai":
            return "考中秀才，得入士林门墙。"
        "juren":
            return "乡试中式，成为举人。"
        "gongshi":
            return "会试中式，取为贡士。"
        "zhuangyuan":
            return "殿试一甲第一名，状元及第。"
        "bangyan":
            return "殿试一甲第二名，榜眼及第。"
        "tanhua":
            return "殿试一甲第三名，探花及第。"
        "erjia":
            return "殿试列二甲，赐进士出身。"
        "sanjia":
            return "殿试列三甲，赐同进士出身。"
        "jinshi":
            return "进士及第。"
    return fallback

static func _select_age_entries(entries: Array) -> Array:
    var selected: Array = []
    for entry in entries:
        var kind: = str(entry.get("kind", ""))
        if kind in ["marker", "age_event"] and int(entry.get("cz_year", 0)) <= 0:
            selected.append(entry)
    return selected

static func _select_keju_entries(entries: Array) -> Array:
    var selected: Array = []
    for entry in entries:
        if str(entry.get("kind", "")) == "keju":
            selected.append(entry)
    return selected

static func _select_governance_year_entries(entries: Array) -> Array:


    var best_by_year: = {}
    for entry in entries:
        var cz_year: = int(entry.get("cz_year", 0))
        if cz_year <= 0:
            continue
        if str(entry.get("kind", "")) == "keju":
            continue
        if not best_by_year.has(cz_year):
            best_by_year[cz_year] = entry
            continue
        var current: Dictionary = best_by_year[cz_year]
        if _entry_score(entry) > _entry_score(current):
            best_by_year[cz_year] = entry
    var selected: Array = []
    for year_key in best_by_year:
        selected.append(best_by_year[year_key])
    return selected

static func _entry_score(entry: Dictionary) -> int:
    return int(entry.get("priority", 0)) * 10000 + int(entry.get("turn", 0))

static func _make_ending_entry(game_state: Node, ending: Dictionary) -> Dictionary:
    var entry: = _base_entry(game_state)

    var cur_event: = {}
    if game_state != null and game_state.has_method("get_current_event"):
        cur_event = game_state.get_current_event()
    var cz_ordinal: = _resolve_cz_ordinal(game_state, cur_event)
    if cz_ordinal >= 1:
        entry["cz_year"] = cz_ordinal
        entry["year_label"] = _format_cz_year(cz_ordinal)
    entry["id"] = "final_ending:" + str(ending.get("id", ending.get("title", "")))
    entry["kind"] = "final_ending"
    entry["priority"] = 120
    entry["title"] = str(ending.get("title", "终局"))
    entry["body"] = str(ending.get("emotion", ending.get("comment", "")))
    if str(entry["body"]) == "":
        entry["body"] = "一生行至此处，归入此局。"
    entry["body"] = _trim_to_sentence(str(entry["body"]), MAX_BODY_CHARS)
    return entry

static func _dedupe_entries(entries: Array) -> Array:
    var seen: = {}
    var deduped: Array = []
    for raw in entries:
        if not raw is Dictionary:
            continue
        var entry: Dictionary = raw
        var id: = str(entry.get("id", ""))
        if id == "":
            id = "%s:%s:%s" % [entry.get("year_label", ""), entry.get("title", ""), entry.get("turn", 0)]
        if seen.has(id):
            continue
        seen[id] = true
        deduped.append(entry)
    return deduped

static func _sort_entry(a: Dictionary, b: Dictionary) -> bool:

    var a_final: = str(a.get("kind", "")) == "final_ending"
    var b_final: = str(b.get("kind", "")) == "final_ending"
    if a_final != b_final:
        return b_final
    var acz: = int(a.get("cz_year", 0))
    var bcz: = int(b.get("cz_year", 0))
    if acz != bcz:
        if acz <= 0 and bcz > 0:
            return true
        if acz > 0 and bcz <= 0:
            return false
        return acz < bcz
    var aa: = int(a.get("age", 0))
    var ba: = int(b.get("age", 0))
    if aa != ba:
        return aa < ba
    return int(a.get("turn", 0)) < int(b.get("turn", 0))

static func _format_entry(entry: Dictionary) -> String:
    if int(entry.get("cz_year", 0)) <= 0:
        return _format_age_entry(entry)
    var label: = str(entry.get("year_label", ""))
    if label == "":
        label = _format_cz_year(int(entry.get("cz_year", 0)))
    return "%s　%s：%s" % [label, str(entry.get("title", "")), str(entry.get("body", ""))]

static func _format_age_entry(entry: Dictionary) -> String:
    var label: = str(entry.get("year_label", ""))
    var age: = int(entry.get("age", 0))
    if label == "" and age > 0:
        label = "%s岁" % _num_zh(age)
    elif label != "" and age > 0 and not label.ends_with("岁") and not label.contains("崇祯"):

        label = "%s（%s岁）" % [label, _num_zh(age)]
    return "%s　%s：%s" % [label, str(entry.get("title", "")), str(entry.get("body", ""))]

static func _trim_to_sentence(text: String, max_chars: int) -> String:

    var result: = text.strip_edges().replace("\n", " ")
    while result.contains("  "):
        result = result.replace("  ", " ")
    if result.length() <= max_chars:
        return result
    var slice: = result.substr(0, max_chars)
    var cut: = -1
    for sep in ["。", "！", "？", "；"]:
        cut = max(cut, slice.rfind(sep))
    if cut >= 10:
        return slice.substr(0, cut + 1)
    return slice.strip_edges() + "……"

static func _num_zh(n: int) -> String:
    if n <= 0:
        return str(n)
    var units: = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
    if n < 10:
        return units[n]
    if n < 20:
        return "十" + units[n % 10] if n % 10 != 0 else "十"
    if n < 100:
        var t: = int(n / 10)
        var u: = n % 10
        return units[t] + "十" + (units[u] if u != 0 else "")
    return str(n)

static func _compact_text(text: String, max_chars: int) -> String:
    var result: = text.strip_edges().replace("\n", " ")
    while result.contains("  "):
        result = result.replace("  ", " ")
    if result.length() <= max_chars:
        return result
    return result.substr(0, max_chars).strip_edges() + "……"

static func _format_cz_year(year: int) -> String:
    var units: = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
    var tens: = ["", "十", "二十"]
    if year <= 0:
        return ""
    if year == 1:
        return "崇祯元年"
    var t: = int(year / 10)
    var u: = year % 10
    var body: = ""
    if t >= 0 and t < tens.size():
        body = tens[t]
    if u >= 0 and u < units.size():
        body += units[u]
    if body == "十":
        body = "十"
    return "崇祯%s年" % body
