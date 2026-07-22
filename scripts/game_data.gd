extends Node



const CONTENT_PATH: = "res://content/game_content.json"

var TIER_NAMES: Array = []
var STAT_LABELS: Dictionary = {}
var STAT_KEYS: Array = []
var ATT_LABELS: Dictionary = {}
var ATT_KEYS: Array = []
var RANKS: Array = []
var MONTH_NAMES: Array = []
var MONTHS_PER_YEAR: int = 12
var SEASON_NAMES: Array = []

var characters: Dictionary = {}
var traits: Dictionary = {}
var endings: Dictionary = {}
var bad_endings: Dictionary = {}
var events: Array = []
var branch_events: Dictionary = {}
var rush_event: Dictionary = {}
var prison_events: Array = []
var wartime_events: Array = []
var CITY_STAT_KEYS: Array = []
var CITY_STAT_LABELS: Dictionary = {}
var CITY_STAT_ICONS: Dictionary = {}
var CITY_STAT_INIT: Dictionary = {}
var MING_MAP_PROVINCES: Dictionary = {}
var CITY_BY_ACT: Dictionary = {}
var TRANSFER_CITY_BY_ACT_AND_JURIS: Dictionary = {}
var GOVERNANCE_CARDS: Array = []
var TRADE_CARDS: Array = []
var BW_MICRO_EVENTS: Dictionary = {}
var ACT_CONFIG: Dictionary = {}
var ACT_TRANSITIONS: Dictionary = {}
var SPECIAL_EVENT_SCHEDULE: Dictionary = {}
var HOME_ACTIONS: Array = []
var FIELD_ACTIONS: Array = []
var RUMOR_CARDS: Array = []
var VISITORS: Array = []
var ATTITUDE_EVENTS: Array = []
var COURT_CASES: Array = []
var CHAIN_CASES: Array = []
var ITEM_DEFS: Dictionary = {}
var DYNAMIC_EVENTS: Dictionary = {}





var LINES: Dictionary = {}
var active_line: String = "hanmen"
var _base_line_config: Dictionary = {}

const _LINE_OVERRIDE_KEYS: = [
    "RANKS", "ACT_CONFIG", "ACT_TRANSITIONS", "SPECIAL_EVENT_SCHEDULE", 
    "CITY_BY_ACT", "TRANSFER_CITY_BY_ACT_AND_JURIS", "ATT_KEYS", "CITY_STAT_KEYS", 
    "ATT_LABELS", 
]

const _LINE_KEY_MAP: = {
    "RANKS": "ranks", 
    "ACT_CONFIG": "act_config", 
    "ACT_TRANSITIONS": "act_transitions", 
    "SPECIAL_EVENT_SCHEDULE": "special_event_schedule", 
    "CITY_BY_ACT": "city_by_act", 
    "TRANSFER_CITY_BY_ACT_AND_JURIS": "transfer_city_by_act_and_juris", 
    "ATT_KEYS": "att_keys", 
    "CITY_STAT_KEYS": "city_stat_keys", 
    "ATT_LABELS": "att_labels", 
}


const _MERGE_OVERRIDE_KEYS: = ["ATT_LABELS"]

const SOURCE_DIR_REL: = "res://../content/source"
const BUILD_SCRIPT_REL: = "res://../tools/importers/build_content_bundle.js"

func _ready() -> void :
    _rebuild_bundle_if_stale()
    _load_content()




func _rebuild_bundle_if_stale() -> void :
    if not OS.has_feature("editor"):
        return

    var build_script_abs: = ProjectSettings.globalize_path(BUILD_SCRIPT_REL)
    var source_dir_abs: = ProjectSettings.globalize_path(SOURCE_DIR_REL)
    var bundle_abs: = ProjectSettings.globalize_path(CONTENT_PATH)
    if not FileAccess.file_exists(build_script_abs):
        return

    var bundle_mtime: int = 0
    if FileAccess.file_exists(bundle_abs):
        bundle_mtime = FileAccess.get_modified_time(bundle_abs)

    var needs_rebuild: = bundle_mtime == 0
    if not needs_rebuild:
        needs_rebuild = _source_tree_newer_than_bundle(source_dir_abs, bundle_mtime)
    if not needs_rebuild:
        return

    var output: Array = []
    var exit_code: = OS.execute("node", [build_script_abs], output, true)
    if exit_code != 0:
        var output_text: = ""
        for line in output:
            output_text += str(line) + "\n"
        push_warning("GameData: content bundle rebuild failed (exit %d). Falling back to existing bundle.\n%s" % [exit_code, output_text])
    else:
        print("GameData: rebuilt content bundle from source.")

func _source_tree_newer_than_bundle(dir_abs: String, bundle_mtime: int) -> bool:
    var dir: = DirAccess.open(dir_abs)
    if dir == null:
        return false

    dir.list_dir_begin()
    var entry: = dir.get_next()
    while entry != "":
        if entry.begins_with("."):
            entry = dir.get_next()
            continue

        var entry_abs: = dir_abs.path_join(entry)
        if dir.current_is_dir():
            if _source_tree_newer_than_bundle(entry_abs, bundle_mtime):
                dir.list_dir_end()
                return true
        elif entry.ends_with(".json") and FileAccess.get_modified_time(entry_abs) > bundle_mtime:
            dir.list_dir_end()
            return true

        entry = dir.get_next()
    dir.list_dir_end()
    return false

func _load_content() -> void :
    if not FileAccess.file_exists(CONTENT_PATH):
        push_error("GameData: missing content bundle at %s" % CONTENT_PATH)
        return

    var file: = FileAccess.open(CONTENT_PATH, FileAccess.READ)
    if file == null:
        push_error("GameData: failed to open content bundle at %s" % CONTENT_PATH)
        return

    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("GameData: invalid JSON content in %s" % CONTENT_PATH)
        return

    var payload: Dictionary = parsed
    TIER_NAMES = payload.get("tier_names", [])
    STAT_LABELS = payload.get("stat_labels", {})
    STAT_KEYS = payload.get("stat_keys", [])
    ATT_LABELS = payload.get("att_labels", {})
    ATT_KEYS = payload.get("att_keys", [])
    RANKS = payload.get("ranks", [])
    MONTH_NAMES = payload.get("month_names", [])
    characters = payload.get("characters", {})
    endings = payload.get("endings", {})
    bad_endings = payload.get("bad_endings", {})
    events = payload.get("events", [])
    branch_events = payload.get("branch_events", {})
    rush_event = payload.get("rush_event", {})
    prison_events = payload.get("prison_events", [])
    wartime_events = payload.get("wartime_events", [])
    CITY_STAT_KEYS = payload.get("city_stat_keys", [])
    CITY_STAT_LABELS = payload.get("city_stat_labels", {})
    CITY_STAT_ICONS = payload.get("city_stat_icons", {})
    CITY_STAT_INIT = payload.get("city_stat_init", {})
    MING_MAP_PROVINCES = payload.get("ming_map_provinces", {})
    CITY_BY_ACT = payload.get("city_by_act", {})
    TRANSFER_CITY_BY_ACT_AND_JURIS = payload.get("transfer_city_by_act_and_juris", {})
    GOVERNANCE_CARDS = payload.get("governance_cards", [])
    TRADE_CARDS = payload.get("trade_cards", [])
    BW_MICRO_EVENTS = payload.get("bw_micro_events", {})
    ACT_CONFIG = payload.get("act_config", {})
    ACT_TRANSITIONS = payload.get("act_transitions", {})
    SPECIAL_EVENT_SCHEDULE = payload.get("special_event_schedule", {})
    HOME_ACTIONS = payload.get("home_actions", [])
    FIELD_ACTIONS = payload.get("field_actions", [])
    RUMOR_CARDS = payload.get("rumor_cards", [])
    VISITORS = payload.get("visitors", [])
    ATTITUDE_EVENTS = payload.get("attitude_events", [])
    COURT_CASES = payload.get("court_cases", [])
    CHAIN_CASES = payload.get("chain_cases", [])
    ITEM_DEFS = payload.get("item_defs", {})
    DYNAMIC_EVENTS = payload.get("dynamic_events", {})
    traits = payload.get("traits", {})
    LINES = payload.get("lines", {})
    _snapshot_base_line()
    active_line = "hanmen"


func _snapshot_base_line() -> void :
    _base_line_config.clear()
    for key in _LINE_OVERRIDE_KEYS:
        _base_line_config[key] = get(key)



func activate_line(line_id: String) -> void :
    if line_id == "" or line_id == "hanmen" or not LINES.has(line_id):
        for key in _LINE_OVERRIDE_KEYS:
            if _base_line_config.has(key):
                set(key, _base_line_config[key])
        MONTHS_PER_YEAR = 12
        SEASON_NAMES = []
        active_line = "hanmen"
        return
    var cfg: Dictionary = LINES.get(line_id, {})
    for key in _LINE_OVERRIDE_KEYS:
        var src_key: String = _LINE_KEY_MAP.get(key, "")
        if key in _MERGE_OVERRIDE_KEYS:
            var merged: Dictionary = (_base_line_config.get(key, {}) as Dictionary).duplicate()
            merged.merge(cfg.get(src_key, {}), true)
            set(key, merged)
        elif cfg.has(src_key):
            set(key, cfg[src_key])
        elif _base_line_config.has(key):
            set(key, _base_line_config[key])
    MONTHS_PER_YEAR = int(cfg.get("months_per_year", 12))
    SEASON_NAMES = cfg.get("season_names", [])
    active_line = line_id




func att_keys_for_line(line_id: String) -> Array:
    if line_id != "" and line_id != "hanmen" and LINES.has(line_id):
        var cfg: Dictionary = LINES[line_id]
        if cfg.has("att_keys"):
            return cfg["att_keys"]
    return _base_line_config.get("ATT_KEYS", ATT_KEYS)

func has_content() -> bool:
    return not characters.is_empty() and not events.is_empty()



func character_has_feature(character_id: String, feature: String) -> bool:
    var feats = characters.get(character_id, {}).get("features", [])
    return feature in feats




func city_stat_effect_label(key: String) -> String:
    var base: = str(CITY_STAT_LABELS.get(key, key))
    if CITY_STAT_KEYS.has(key):
        return base + "等级"
    return base



func attitude_effect_label(key: String) -> String:
    var base: = str(ATT_LABELS.get(key, key))
    if active_line == "bianwu" and ATT_KEYS.has(key):
        return base + "态度"
    return base

static func get_tier(value: int) -> int:
    if value < 15:
        return 0
    elif value < 29:
        return 1
    elif value < 43:
        return 2
    elif value < 58:
        return 3
    elif value < 72:
        return 4
    elif value < 86:
        return 5
    else:
        return 6
