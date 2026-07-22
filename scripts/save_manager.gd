extends Node

const AdsConfigRef = preload("res://scripts/services/ads_config.gd")
const RouteRegistryRef = preload("res://scripts/route_registry.gd")

const SAVE_DIR = "user://saves/"
const AUTOSAVE_PATH = SAVE_DIR + "autosave.save"
const PREVIOUS_AUTOSAVE_FILENAME: = "previous_autosave.save"
const ENDING_CODEX_PATH = "user://ending_codex.save"
const SLOT_UNLOCK_PATH = SAVE_DIR + "manual_slot_unlocks.save"
const SLOT_UNLOCK_TEMP_PATH = SLOT_UNLOCK_PATH + ".tmp"
const MAX_SLOTS = 10
const KUIXING_FU_ITEM_ID: = "kuixing_fu"
const KUIXING_FU_MAX_COUNT: = 10
const KUIXING_FU_REWARD_ENDINGS: = [
    "juren_ending", 
    "juren_teacher_ending", 
    "xiucai_ending", 
    "scholar_ending", 
    "businessman_ending", 
    "soldier_ending", 
    "scientist_ending", 
    "doctor_ending", 
    "painter_ending", 
    "musician_ending", 
    "idle_rich_ending", 
    "eunuch_ending", 
    "detour_eunuch_ending", 
    "detour_farmer_ending", 
    "detour_peddler_ending", 
    "detour_soldier_border_ending", 
]

const REBIRTH_POINTS_MAX: = 30
const ANDROID_REWARD_SAVE_SLOTS_ENABLED: = true
const ANDROID_DEFAULT_MANUAL_SLOTS: = 3
const ANDROID_MAX_MANUAL_SLOTS: = 30

var _android_manual_slot_count_fallback: = -1

func _ready() -> void :
    DirAccess.make_dir_recursive_absolute(SAVE_DIR)
    _initialize_android_manual_slot_count()

func _flush_persistent_userfs() -> void :
    if OS.has_feature("web"):
        JavaScriptBridge.force_fs_sync()





func _bucket_dir(bucket: String) -> String:
    if bucket == "" or bucket == "hanmen":
        return SAVE_DIR
    return SAVE_DIR + bucket + "/"

func _ensure_bucket_dir(bucket: String) -> void :
    var dir: = _bucket_dir(bucket)
    if dir != SAVE_DIR:
        DirAccess.make_dir_recursive_absolute(dir)


func _all_bucket_dirs() -> Array:
    var dirs: = [SAVE_DIR]
    for bucket in RouteRegistryRef.BUCKET_ORDER:
        if bucket == "hanmen":
            continue
        dirs.append(_bucket_dir(bucket))
    return dirs

func _initialize_android_manual_slot_count() -> void :
    if not _uses_android_reward_slots():
        return
    var slot_state: = _read_manual_slot_unlock_state()
    if bool(slot_state.get("valid", false)):
        _android_manual_slot_count_fallback = int(slot_state.get("count", ANDROID_DEFAULT_MANUAL_SLOTS))
        return
    var initial_count: = ANDROID_DEFAULT_MANUAL_SLOTS
    var legacy_count: = _detect_legacy_android_manual_slot_count()
    if legacy_count >= 0:
        initial_count = legacy_count

    _android_manual_slot_count_fallback = initial_count
    var marker_saved: = _write_manual_slot_unlock_count(initial_count)
    if not marker_saved and initial_count == ANDROID_DEFAULT_MANUAL_SLOTS:

        _android_manual_slot_count_fallback = MAX_SLOTS

func _detect_legacy_android_manual_slot_count() -> int:
    var has_legacy_save: = false
    var highest_slot: = -1
    for dir in _all_bucket_dirs():
        if FileAccess.file_exists(dir + "autosave.save") or FileAccess.file_exists(dir + PREVIOUS_AUTOSAVE_FILENAME):
            has_legacy_save = true
        for i in range(ANDROID_MAX_MANUAL_SLOTS):
            if not FileAccess.file_exists(dir + "slot_" + str(i) + ".save"):
                continue
            has_legacy_save = true
            highest_slot = maxi(highest_slot, i)
    if not has_legacy_save:
        return -1
    return clampi(maxi(MAX_SLOTS, highest_slot + 1), ANDROID_DEFAULT_MANUAL_SLOTS, ANDROID_MAX_MANUAL_SLOTS)

func get_slot_path(slot: int, bucket: String = "") -> String:
    if bucket == "":
        bucket = RouteRegistryRef.current_bucket()
    return _bucket_dir(bucket) + "slot_" + str(slot) + ".save"

func get_autosave_path(bucket: String = "") -> String:
    if bucket == "":
        bucket = RouteRegistryRef.current_bucket()
    return _bucket_dir(bucket) + "autosave.save"

func get_previous_autosave_path(bucket: String = "") -> String:
    if bucket == "":
        bucket = RouteRegistryRef.current_bucket()
    return _bucket_dir(bucket) + PREVIOUS_AUTOSAVE_FILENAME

func _uses_android_reward_slots() -> bool:
    return ANDROID_REWARD_SAVE_SLOTS_ENABLED and OS.has_feature("android")

func get_available_manual_slots() -> int:
    if not _uses_android_reward_slots():
        return MAX_SLOTS
    if not AdsConfigRef.ADS_ENABLED:


        return clampi(maxi(MAX_SLOTS, _read_manual_slot_unlock_count()), MAX_SLOTS, ANDROID_MAX_MANUAL_SLOTS)
    return clampi(_read_manual_slot_unlock_count(), ANDROID_DEFAULT_MANUAL_SLOTS, ANDROID_MAX_MANUAL_SLOTS)

func can_unlock_more_manual_slots() -> bool:

    return (
        AdsConfigRef.ADS_ENABLED
        and _uses_android_reward_slots()
        and get_available_manual_slots() < ANDROID_MAX_MANUAL_SLOTS
    )

func unlock_manual_slot_from_reward() -> bool:
    if not can_unlock_more_manual_slots():
        return false
    var current_slots: = get_available_manual_slots()
    if current_slots >= ANDROID_MAX_MANUAL_SLOTS:
        return false
    return _write_manual_slot_unlock_count(current_slots + 1)

func _read_manual_slot_unlock_count() -> int:
    var slot_state: = _read_manual_slot_unlock_state()
    if bool(slot_state.get("valid", false)):
        return int(slot_state.get("count", ANDROID_DEFAULT_MANUAL_SLOTS))
    if _android_manual_slot_count_fallback >= 0:
        return _android_manual_slot_count_fallback
    return ANDROID_DEFAULT_MANUAL_SLOTS

func _read_manual_slot_unlock_state(path: String = SLOT_UNLOCK_PATH) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {"valid": false}
    var file: = FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {"valid": false}
    var data = file.get_var()
    var read_error: = file.get_error()
    file.close()
    if read_error != OK:
        return {"valid": false}
    if data is Dictionary:
        var manual_slots = data.get("manual_slots", null)
        if manual_slots is int and _is_valid_android_manual_slot_count(manual_slots):
            return {"valid": true, "count": int(manual_slots)}
    if data is int and _is_valid_android_manual_slot_count(data):
        return {"valid": true, "count": int(data)}
    return {"valid": false}

func _is_valid_android_manual_slot_count(value: int) -> bool:
    return value >= ANDROID_DEFAULT_MANUAL_SLOTS and value <= ANDROID_MAX_MANUAL_SLOTS

func _write_manual_slot_unlock_count(slot_count: int) -> bool:
    _remove_manual_slot_temp_file()
    var file: = FileAccess.open(SLOT_UNLOCK_TEMP_PATH, FileAccess.WRITE)
    if file == null:
        push_error("Cannot open manual slot unlock temp file: " + SLOT_UNLOCK_TEMP_PATH)
        return false
    var safe_slot_count: = clampi(slot_count, ANDROID_DEFAULT_MANUAL_SLOTS, ANDROID_MAX_MANUAL_SLOTS)
    file.store_var({
        "manual_slots": safe_slot_count, 
        "updated_at": Time.get_datetime_string_from_system(), 
    })
    file.flush()
    var write_error: = file.get_error()
    file.close()
    if write_error != OK:
        _remove_manual_slot_temp_file()
        return false

    var rename_error: = DirAccess.rename_absolute(SLOT_UNLOCK_TEMP_PATH, SLOT_UNLOCK_PATH)
    if rename_error != OK:
        _remove_manual_slot_temp_file()
        return false
    _android_manual_slot_count_fallback = safe_slot_count
    _flush_persistent_userfs()
    return true

func _remove_manual_slot_temp_file() -> void :
    if FileAccess.file_exists(SLOT_UNLOCK_TEMP_PATH):
        DirAccess.remove_absolute(SLOT_UNLOCK_TEMP_PATH)

func _build_save_data(autosave: bool = false) -> Dictionary:
    var data = GameState.to_save_data()
    data["save_time"] = Time.get_datetime_string_from_system().replace("T", " ")
    if autosave:
        data["autosave"] = true
        data["autosave_kind"] = "current"
    return data

func _write_save_data(path: String, autosave: bool = false) -> bool:
    var data = _build_save_data(autosave)
    return _write_raw_save_data(path, data)

func _write_raw_save_data(path: String, data: Dictionary) -> bool:
    var file = FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        push_error("Cannot open save file: " + path)
        return false
    file.store_var(data)
    file.close()
    _flush_persistent_userfs()
    return true

func _read_save_data(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var file = FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    var data = file.get_var()
    file.close()
    if data is Dictionary:
        return data
    return {}



func _location_label_from_data(data: Dictionary) -> String:
    var city: Dictionary = data.get("city", {})
    if city.is_empty():
        return ""
    if str(data.get("branch", "")) in ["zhongchen", "bifan", "xiaoxiong", "xinghuo"]:
        return ""
    var city_label: = str(city.get("name", ""))
    if city_label == "":
        return ""

    const LEGACY_NAMES: = ["延庆道", "延昌道", "延安府", "庆阳府"]
    if city_label in LEGACY_NAMES:
        city_label = "河西道"

    if city_label == "河西道":
        match str(city.get("juris", "")):
            "县": city_label = "安化县"
            "州": city_label = "宁州"
            "府": city_label = "庆阳府"
    var juris: = str(city.get("juris", ""))
    if juris != "" and not city_label.ends_with(juris):
        city_label += juris
    var province: = str(city.get("province", ""))
    if province != "":
        return province + "·" + city_label
    return city_label

func _info_from_data(data: Dictionary) -> Dictionary:
    if data.is_empty():
        return {}
    var rank_str = data.get("display_identity", "")
    if rank_str == "":
        rank_str = GameData.RANKS[data.get("rank_index", 0)] if data.get("rank_index", 0) < GameData.RANKS.size() else ""


    var location_str = str(data.get("display_location", ""))
    if not data.has("display_location") or "延庆道" in location_str or "延昌道" in location_str or "延安府" in location_str:

        location_str = _location_label_from_data(data)
    if location_str == "":
        location_str = rank_str
    return {
        "char_name": data.get("char_name", ""), 
        "rank": location_str, 
        "turn": data.get("turn", 1), 
        "save_time": str(data.get("save_time", "")).replace("T", " "), 
        "custom_name": str(data.get("custom_name", "")), 
    }

func _get_save_info(path: String) -> Dictionary:
    return _info_from_data(_read_save_data(path))

func save_game(slot: int) -> bool:
    _ensure_bucket_dir(RouteRegistryRef.current_bucket())
    return _write_save_data(get_slot_path(slot))

func save_autosave() -> bool:
    var bucket: = RouteRegistryRef.current_bucket()
    _ensure_bucket_dir(bucket)
    var data: = _build_save_data(true)
    _rotate_current_autosave_to_previous(bucket, data)
    return _write_raw_save_data(get_autosave_path(bucket), data)

func _rotate_current_autosave_to_previous(bucket: String, new_data: Dictionary) -> void :
    var current_data: = _read_save_data(get_autosave_path(bucket))
    if not _should_rotate_autosave(current_data, new_data):
        return
    current_data["autosave"] = true
    current_data["autosave_kind"] = "previous"
    _write_raw_save_data(get_previous_autosave_path(bucket), current_data)

func _should_rotate_autosave(current_data: Dictionary, new_data: Dictionary) -> bool:
    if current_data.is_empty():
        return false
    return int(current_data.get("turn", 1)) != int(new_data.get("turn", 1))

func load_game(slot: int) -> bool:
    return load_path(get_slot_path(slot))

func load_autosave() -> bool:
    return load_path(get_autosave_path())

func load_previous_autosave() -> bool:
    return load_path(get_previous_autosave_path())


func load_path(path: String) -> bool:
    var data: = _read_save_data(path)
    if not data.is_empty():
        GameState.load_save_data(data)
        return true
    return false

func get_slot_info(slot: int) -> Dictionary:
    return _get_save_info(get_slot_path(slot))

func get_autosave_info() -> Dictionary:
    return _get_save_info(get_autosave_path())

func get_previous_autosave_info() -> Dictionary:
    return _get_save_info(get_previous_autosave_path())

func has_autosave() -> bool:
    return not _read_save_data(get_autosave_path()).is_empty()

func delete_save(slot: int) -> void :
    delete_path(get_slot_path(slot))


func delete_path(path: String) -> void :
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(path)
        _flush_persistent_userfs()



const CUSTOM_NAME_MAX_LEN: = 24

func set_custom_name(slot: int, name: String) -> bool:
    return set_custom_name_path(get_slot_path(slot), name)

func set_custom_name_path(path: String, name: String) -> bool:
    var data: = _read_save_data(path)
    if data.is_empty():
        return false
    var trimmed: = name.strip_edges()
    if trimmed == "":
        data.erase("custom_name")
    else:
        data["custom_name"] = trimmed.substr(0, CUSTOM_NAME_MAX_LEN)
    var file = FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        push_error("Cannot open save file: " + path)
        return false
    file.store_var(data)
    file.close()
    _flush_persistent_userfs()
    return true

func has_any_save() -> bool:
    for dir in _all_bucket_dirs():
        if FileAccess.file_exists(dir + "autosave.save") or FileAccess.file_exists(dir + PREVIOUS_AUTOSAVE_FILENAME):
            return true
        for i in range(get_available_manual_slots()):
            if FileAccess.file_exists(dir + "slot_" + str(i) + ".save"):
                return true
    return false





func list_save_groups() -> Array:
    var entries: = []
    for dir in _all_bucket_dirs():
        _collect_dir_entries(dir, entries)
    var groups: = []
    for bucket in RouteRegistryRef.BUCKET_ORDER:
        var own_autosave_path: = get_autosave_path(bucket)
        var own_previous_autosave_path: = get_previous_autosave_path(bucket)
        var bucket_entries: = []
        var autosave_entry: Dictionary = {}
        var previous_autosave_entry: Dictionary = {}
        for e in entries:
            if e["bucket"] != bucket:
                continue
            if bool(e.get("is_autosave", false)):
                var kind: = str(e.get("autosave_kind", "current"))
                if kind == "previous":
                    if previous_autosave_entry.is_empty() or str(e.get("path", "")) == own_previous_autosave_path:
                        previous_autosave_entry = e
                else:
                    if autosave_entry.is_empty() or str(e.get("path", "")) == own_autosave_path:
                        autosave_entry = e
                continue
            bucket_entries.append(e)
        if not previous_autosave_entry.is_empty():
            bucket_entries.push_front(previous_autosave_entry)
        if not autosave_entry.is_empty():
            bucket_entries.push_front(autosave_entry)
        if bucket_entries.is_empty():
            continue
        groups.append({
            "bucket": bucket, 
            "label": RouteRegistryRef.bucket_label(bucket), 
            "entries": bucket_entries, 
        })
    return groups

func _collect_dir_entries(dir: String, entries: Array) -> void :
    var auto_path: = dir + "autosave.save"
    if FileAccess.file_exists(auto_path):
        var auto_data: = _read_save_data(auto_path)
        if not auto_data.is_empty():
            entries.append({
                "is_autosave": true, 
                "slot": -1, 
                "path": auto_path, 
                "bucket": RouteRegistryRef.bucket_of_save(auto_data), 
                "info": _info_from_data(auto_data), 
            })
    var previous_auto_path: = dir + PREVIOUS_AUTOSAVE_FILENAME
    if FileAccess.file_exists(previous_auto_path):
        var previous_auto_data: = _read_save_data(previous_auto_path)
        if not previous_auto_data.is_empty():
            entries.append({
                "is_autosave": true, 
                "autosave_kind": "previous", 
                "slot": -1, 
                "path": previous_auto_path, 
                "bucket": RouteRegistryRef.bucket_of_save(previous_auto_data), 
                "info": _info_from_data(previous_auto_data), 
            })
    for i in range(get_available_manual_slots()):
        var slot_path: = dir + "slot_" + str(i) + ".save"
        if not FileAccess.file_exists(slot_path):
            continue
        var slot_data: = _read_save_data(slot_path)
        if slot_data.is_empty():
            continue
        entries.append({
            "is_autosave": false, 
            "slot": i, 
            "path": slot_path, 
            "bucket": RouteRegistryRef.bucket_of_save(slot_data), 
            "info": _info_from_data(slot_data), 
        })

func record_ending(ending: Dictionary) -> void :
    var ending_id: = resolve_ending_id(ending)
    if ending_id == "":
        return

    var data: = _read_ending_codex()
    var unlocked: Array = data.get("unlocked_endings", [])
    if ending_id not in unlocked:
        unlocked.append(ending_id)
        data["unlocked_endings"] = unlocked
        _write_ending_codex(data)

func get_unlocked_ending_ids() -> Array[String]:
    if OS.is_debug_build() or OS.has_feature("editor"):
        var ids: Array[String] = []
        if GameData.endings:
            for key in GameData.endings.keys():
                ids.append(str(key))
        if GameData.bad_endings:
            for key in GameData.bad_endings.keys():
                ids.append(str(key))
        for id in ["jingguan_ending_yijia", "jingguan_ending_erjia", "jingguan_ending_sanjia_datong"]:
            if id not in ids:
                ids.append(id)
        return ids

    var data: = _read_ending_codex()
    var unlocked: Array = data.get("unlocked_endings", [])
    var ids: Array[String] = []
    for item in unlocked:
        var id: = str(item)
        if id != "" and id not in ids:
            ids.append(id)
    return ids

func get_kuixing_fu_count() -> int:
    var data: = _read_ending_codex()
    return clampi(int(data.get("kuixing_fu_count", 0)), 0, KUIXING_FU_MAX_COUNT)

static func calculate_kuixing_fu_total(persistent_count: int, run_count: int) -> int:
    return clampi(
        clampi(persistent_count, 0, KUIXING_FU_MAX_COUNT) + clampi(run_count, 0, KUIXING_FU_MAX_COUNT), 
        0, 
        KUIXING_FU_MAX_COUNT
    )


func get_current_kuixing_fu_count(game_state: Variant = GameState) -> int:
    var persistent_count: = get_kuixing_fu_count()
    var run_count: = 0
    if game_state != null:
        run_count = clampi(int(game_state.kuixing_fu_draw_count), 0, KUIXING_FU_MAX_COUNT)
    return calculate_kuixing_fu_total(persistent_count, run_count)


func add_run_kuixing_fu(game_state: Variant = GameState) -> Dictionary:
    var current_total: = get_current_kuixing_fu_count(game_state)
    if current_total >= KUIXING_FU_MAX_COUNT:
        return {}
    var run_count: = clampi(int(game_state.kuixing_fu_draw_count), 0, KUIXING_FU_MAX_COUNT)
    game_state.kuixing_fu_draw_count = run_count + 1
    return {
        "item_id": KUIXING_FU_ITEM_ID, 
        "count": current_total + 1, 
        "max_count": KUIXING_FU_MAX_COUNT, 
    }

func add_kuixing_fu() -> Dictionary:
    var data: = _read_ending_codex()
    var current_count: = clampi(int(data.get("kuixing_fu_count", 0)), 0, KUIXING_FU_MAX_COUNT)
    if current_count >= KUIXING_FU_MAX_COUNT:
        return {}
    var next_count: = current_count + 1
    data["kuixing_fu_count"] = next_count
    if not _write_ending_codex(data):
        return {}
    return {
        "item_id": KUIXING_FU_ITEM_ID, 
        "count": next_count, 
        "max_count": KUIXING_FU_MAX_COUNT, 
    }


func get_rebirth_points() -> int:
    var data: = _read_ending_codex()
    return clampi(int(data.get("rebirth_points", 0)), 0, REBIRTH_POINTS_MAX)


func add_rebirth_point() -> int:
    var data: = _read_ending_codex()
    var current: = clampi(int(data.get("rebirth_points", 0)), 0, REBIRTH_POINTS_MAX)
    if current >= REBIRTH_POINTS_MAX:
        return current
    var next_count: = current + 1
    data["rebirth_points"] = next_count
    _write_ending_codex(data)
    return next_count

func claim_kuixing_reward_for_ending(ending: Dictionary) -> Dictionary:
    var ending_id: = resolve_ending_id(ending)
    if ending_id == "" or ending_id not in KUIXING_FU_REWARD_ENDINGS:
        return {}
    if not GameState.has_feature("kuixing"):
        return {}

    return add_kuixing_fu()

func resolve_ending_id(ending: Dictionary) -> String:
    if ending.has("id"):
        var explicit_id: = str(ending.get("id", ""))
        if explicit_id in GameData.endings or explicit_id in GameData.bad_endings:
            return explicit_id

    for source in [GameData.endings, GameData.bad_endings]:
        for id in source.keys():
            var candidate: Dictionary = source[id]
            if candidate.get("title", "") == ending.get("title", "") and candidate.get("narrative", "") == ending.get("narrative", ""):
                return str(id)
    return ""

func _read_ending_codex() -> Dictionary:
    if not FileAccess.file_exists(ENDING_CODEX_PATH):
        return {"unlocked_endings": []}
    var file: = FileAccess.open(ENDING_CODEX_PATH, FileAccess.READ)
    if file == null:
        return {"unlocked_endings": []}
    var data = file.get_var()
    file.close()
    if data is Dictionary:
        return data
    return {"unlocked_endings": []}

func _write_ending_codex(data: Dictionary) -> bool:
    var file: = FileAccess.open(ENDING_CODEX_PATH, FileAccess.WRITE)
    if file == null:
        push_error("Cannot open ending codex file: " + ENDING_CODEX_PATH)
        return false
    file.store_var(data)
    file.flush()
    var write_error: = file.get_error()
    file.close()
    if write_error != OK:
        return false
    _flush_persistent_userfs()
    return true
