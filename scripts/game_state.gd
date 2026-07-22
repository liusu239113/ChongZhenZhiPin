extends Node


const EventServiceRef = preload("res://scripts/services/event_service.gd")
const EndingServiceRef = preload("res://scripts/services/ending_service.gd")
const EffectsServiceRef = preload("res://scripts/services/effects_service.gd")
const BiographyServiceRef = preload("res://scripts/services/biography_service.gd")
const GameStateQueryServiceRef = preload("res://scripts/services/game_state_query_service.gd")
const MonthlySettlementServiceRef = preload("res://scripts/services/monthly_settlement_service.gd")
const PersonalStatCapstoneServiceRef = preload("res://scripts/services/personal_stat_capstone_service.gd")
const BianwuDefenseServiceRef = preload("res://scripts/services/bianwu_defense_service.gd")
const CITY_STAT_MAX_LEVEL: = 50
const CITY_BOOST_SLOT_BASE_COUNT: = 3
const CITY_BOOST_SLOT_LEGACY_BASE_COUNT: = 5
const CITY_BOOST_SLOT_COUNT: = CITY_BOOST_SLOT_BASE_COUNT
const LINGWU_STAT_COST: = 2
const LINGWU_CITY_BOOST_SLOT_COST: = 10
const LINGWU_CARD_UPGRADE_COST: = 15


const JIANWEN_OFFERS: = [
    {
        "id": "jw_kuji_chenggui", 
        "title": "库计成规", 
        "cost": 20, 
        "visitor_id": "v_jianwen_kuji", 
        "desc": "延请江南老账房查库理账。得《库计成规》一册——装入治理增益槽后，每月库银收益增三成；然清账堵漏动了士绅分润，士绅态度每月减五。", 
    }, 
    {
        "id": "jw_junshui_gundan", 
        "title": "陂塘之政", 
        "cost": 20, 
        "visitor_id": "v_js_junshui", 
        "desc": "循老河工之策，增浚陂塘、按册派役。得陂塘水利规程一册——装入治理增益槽后，每月官粮收益增三成；然农时强征夫役苦民，民望每月减五。", 
    }, 
    {
        "id": "jw_qingtang_zhenji", 
        "title": "请帑赈济", 
        "cost": 20, 
        "visitor_id": "v_js_qingtang", 
        "desc": "仗天子恩眷，具本向太仓内帑请拨帑银以充赈济。得请帑陈乞之式一份——装入治理增益槽后，每月库银增四百；然屡屡伸手请拨，圣心渐生倦厌，圣眷每月减五。", 
    }, 
    {
        "id": "jw_kaiyuan_queli", 
        "title": "开源榷利", 
        "cost": 20, 
        "visitor_id": "v_js_kaiyuan", 
        "desc": "兴官营榷卖、抽分收息，以佐用度。得榷利经营之法一册——装入治理增益槽后，每月库银收益增三成；然聚敛言利为清流所鄙，清议每月减五。", 
    }, 
    {
        "id": "jw_hushang_yizhen", 
        "title": "护商抑珰", 
        "cost": 20, 
        "visitor_id": "v_js_hushang", 
        "desc": "顶住税监横抽，护住境内商路，商货日繁。得护商约束之条一份——装入治理增益槽后，商贸等级每三月加一；然夺了内官财路，中官每月减五。", 
    }, 
]


const ITEM_STATUS_EFFECT_KEYS: = ["yinliang", "liangshi", "bingyong", "liumin", "renkou_val", "private_silver"]
const ITEM_STATUS_EFFECT_LABELS: = {
    "yinliang": "库银", 
    "liangshi": "官粮", 
    "bingyong": "兵勇", 
    "liumin": "流民", 
    "renkou_val": "人口", 
    "private_silver": "私银", 
}
const PERSONAL_ITEM_EFFECT_KEYS: = ["wentao", "wulue", "lizheng", "tizhi"]
const LEGACY_MIXED_ITEM_PERSONAL_EFFECTS: = {
    "yuan_yigao": {"wulue": 1}, 
    "jixiao_xinshu": {"wulue": 3}, 
}
const CITY_STAT_GRAIN_OUTPUTS: = [
    120, 160, 210, 270, 340, 
    420, 510, 610, 720, 850, 
    1000, 1170, 1360, 1570, 1800, 
    2050, 2320, 2610, 2920, 3250, 
    3610, 3990, 4400, 4840, 5310, 
    5810, 6340, 6900, 7490, 8110, 
    8760, 9440, 10150, 10890, 11660, 
    12460, 13290, 14150, 15040, 15960, 
    16910, 17890, 18900, 19940, 21010, 
    22110, 23240, 24400, 25590, 26810
]
const GOVERNANCE_MERIT_SCHEMA_VERSION: = 2
const GRAIN_DEFICIT_SOLDIER_LOSS_CAP: = 500
const RIOT_MIN_REFUGEE_COUNT: = 1000
const RIOT_LOW_RATIO_PROBABILITY_START: = 0.03
const RIOT_LOW_RATIO_PROBABILITY_END: = 0.3
const RIOT_LOW_RATIO_MAX: = 0.15
const RIOT_GRAIN_EMPTY_MIN_PROBABILITY: = 0.12

const GRAIN_SAFETY_MONTHS: = 1.0

const GRAIN_TIER_REFUGEE_RATE: = [0.0, 0.005, 0.015, 0.025]

const GRAIN_TIER_POP_DEATH_RATE: = [0.0, 0.0, 0.002, 0.01]

const GRAIN_TIER_REF_DEATH_RATE: = [0.0, 0.0, 0.004, 0.02]

const GRAIN_TIER_MINWANG_DROP: = [0, 1, 3, 4]
const LIUMIN_GRAIN_SHORTAGE_DEFICIT_RATE: = 0.2
const LIUMIN_GRAIN_SHORTAGE_MIN_GROWTH: = 50
const LIUMIN_GRAIN_SHORTAGE_MAX_GROWTH: = 600
const LIUMIN_MONTHLY_BASE_INFLOW: = 50
const LIUMIN_YEARLY_PRESSURE_START_YEAR: = 1
const LIUMIN_YEARLY_PRESSURE_END_YEAR: = 17
const LIUMIN_YEARLY_PRESSURE_START_MULTIPLIER: = 1.0
const LIUMIN_YEARLY_PRESSURE_END_MULTIPLIER: = 24.0

const RENKOU_MONTHLY_NATURAL_GROWTH_RATE: = 0.0015
const OFFICIAL_MONTHLY_SALARY_BY_GRADE: = {
    "正一品": 44, 
    "从一品": 37, 
    "正二品": 31, 
    "从二品": 24, 
    "正三品": 18, 
    "从三品": 13, 
    "正四品": 12, 
    "从四品": 11, 
    "正五品": 8, 
    "从五品": 7, 
    "正六品": 5, 
    "从六品": 4, 
    "正七品": 4, 
    "从七品": 4, 
    "正八品": 3, 
    "从八品": 3, 
    "正九品": 3, 
    "从九品": 3
}
const LEGACY_CITY_IDENTITY_MIGRATIONS: = {
    "蓬莱县": {"name": "蓬莱县", "province": "山东", "juris": "县"}, 
    "宁昌州": {"name": "蒲州", "province": "山西", "juris": "州"}, 
    "平阳府": {"name": "蒲州", "province": "山西", "juris": "州"}, 
    "保阳府": {"name": "真定府", "province": "北直隶", "juris": "府"}, 
    "安陵府": {"name": "襄阳府", "province": "湖广", "juris": "府"}, 
    "延昌道": {"name": "河西道", "province": "陕西", "juris": "道"}, 
    "延安府": {"name": "河西道", "province": "陕西", "juris": "道"}, 
    "庆阳府": {"name": "河西道", "province": "陕西", "juris": "道"}, 
    "延庆道": {"name": "河西道", "province": "陕西", "juris": "道"}, 
    "肤施县": {"name": "安化县", "province": "陕西", "juris": "县"}, 
    "鄜州": {"name": "宁州", "province": "陕西", "juris": "州"}
}

signal state_changed
signal personal_stat_capstone_reached(stat_key: String)
signal event_advanced
signal bad_ending_triggered(ending_id: String)
signal game_ended(ending: Dictionary)
signal theme_changed(new_theme: String)

var theme: String = "dark"
var theme_colors: Dictionary = {
    "light": {
        "bg_top": Color(0.95, 0.92, 0.86, 0.96), 
        "bg_bottom": Color(0.92, 0.88, 0.8, 1.0), 
        "bg_popup": Color(0.878, 0.886, 0.902, 1.0), 
        "text_main": Color(0.018, 0.016, 0.013, 0.86), 
        "text_sub": Color(0.42, 0.37, 0.29, 0.8), 
        "text_desc": Color(0.048, 0.039, 0.031, 0.85), 
        "border_weak": Color(0.72, 0.6, 0.34, 0.25), 
        "border": Color(0.72, 0.6, 0.34, 0.4), 
        "border_med": Color(0.72, 0.6, 0.34, 0.5), 
        "border_strong": Color(0.72, 0.6, 0.34, 0.6), 
        "border_stronger": Color(0.72, 0.6, 0.36, 0.85), 
        "border_active": Color(0.72, 0.6, 0.34, 0.9), 
        "bg_panel": Color(0.96, 0.93, 0.88, 0.9), 
        "bg_panel_weak": Color(0.96, 0.93, 0.88, 0.6), 
        "choice_normal": Color(0.96, 0.93, 0.88, 0.9), 
        "choice_hover": Color(0.96, 0.91, 0.78, 0.9), 
        "choice_press": Color(0.93, 0.86, 0.68, 0.9), 
        "choice_locked": Color(0.9, 0.86, 0.8, 0.8), 
        "choice_risky_hover": Color(0.9, 0.86, 0.8, 0.95), 
        "radar_fill": Color(0.72, 0.6, 0.34, 0.5), 
        "radar_stroke": Color(0.72, 0.6, 0.34, 0.8), 
        "req_red": Color(0.65, 0.18, 0.15, 1.0), 
        "req_green": Color(0.15, 0.42, 0.25, 1.0), 
        "req_yellow": Color(0.58, 0.4, 0.08, 1.0)
    }, 
    "dark": {
        "bg_top": Color(0.035, 0.039, 0.036, 0.97), 
        "bg_bottom": Color(0.016, 0.018, 0.017, 1.0), 
        "bg_popup": Color(0.052, 0.047, 0.039, 0.98), 
        "text_main": Color(0.96, 0.9, 0.76, 1.0), 
        "text_sub": Color(0.63, 0.57, 0.45, 0.82), 
        "text_desc": Color(0.9, 0.84, 0.7, 0.96), 
        "border_weak": Color(0.64, 0.51, 0.29, 0.24), 
        "border": Color(0.66, 0.54, 0.32, 0.38), 
        "border_med": Color(0.7, 0.58, 0.35, 0.5), 
        "border_strong": Color(0.74, 0.61, 0.36, 0.64), 
        "border_stronger": Color(0.82, 0.69, 0.43, 0.86), 
        "border_active": Color(0.86, 0.72, 0.43, 0.92), 
        "bg_panel": Color(0.075, 0.068, 0.055, 0.92), 
        "bg_panel_weak": Color(0.068, 0.061, 0.05, 0.68), 
        "choice_normal": Color(0.078, 0.054, 0.039, 0.92), 
        "choice_hover": Color(0.115, 0.078, 0.052, 0.95), 
        "choice_press": Color(0.145, 0.096, 0.061, 0.98), 
        "choice_locked": Color(0.055, 0.046, 0.039, 0.82), 
        "choice_risky_hover": Color(0.125, 0.072, 0.052, 0.97), 
        "radar_fill": Color(0.78, 0.62, 0.32, 0.42), 
        "radar_stroke": Color(0.84, 0.7, 0.42, 0.78), 
        "req_red": Color(0.78, 0.32, 0.28, 0.9), 
        "req_green": Color(0.33, 0.72, 0.5, 0.92), 
        "req_yellow": Color(0.85, 0.65, 0.35, 0.9)
    }
}

func get_theme_color(key: String) -> Color:
    var th = theme_colors.get(theme, theme_colors["dark"])
    return th.get(key, Color.WHITE)

func toggle_theme() -> void :
    theme = "light" if theme == "dark" else "dark"
    theme_changed.emit(theme)
    _save_settings()

func set_theme(next_theme: String) -> void :
    if theme == next_theme:
        return
    theme = next_theme
    theme_changed.emit(theme)
    _save_settings()


var char_id: String = ""
var char_name: String = ""
var route: String = ""
var selected_timeline: String = "wanli"
var play_mode: String = "story"


var active_line: String = "hanmen"


var difficulty: String = "normal"


var stats: Dictionary = {}
var notified_personal_stat_capstones: Array = []
var wentao_capstone_months: int = 0
var private_silver: int = 0
var lingwu: int = 0


var kuixing_fu_draw_count: int = 0





var attitudes: Dictionary = {}


var att_events_triggered: Array = []
var att_event_last_time: int = -100
var att_event_repeat_last: Dictionary = {}
var honorary_title: String = ""
var honorary_title_rank: int = -1
var salary_penalty_months: int = 0
var living_shrine: bool = false
var grain_shortage_last_time: int = -100


var rank_index: int = 0
var current_event: int = 0
var turn: int = 1
var _base_age: int = 20
var age: int:
    get:
        var curr_year = get_czYear()
        if curr_year > 1600:
            return max(1, curr_year - 1602)

        if typeof(branch) == TYPE_STRING and branch.begins_with("origin"):
            return branch_index + 1

        var years_elapsed = max(0, curr_year - 1)
        return _base_age + years_elapsed
    set(value):
        pass
var city: Dictionary = {}
var month: int = 0
var year: int = 0
var action_points: int = 0
var monthly_grain_breakdown: Array = []
var monthly_silver_breakdown: Array = []

var last_grain_shortage_report: Dictionary = {}



var last_month_resource_delta: Dictionary = {}
var month_cards: Array = []
var month_cards_done: Array[int] = []
var current_month_card_index: int = -1
var used_month_court: Array[String] = []
var used_month_visitors: Array[String] = []
var used_case_ids: Array[String] = []
var used_chain_ids: Array[String] = []
var mutiny_risk_modifiers: Array = []
var last_military_discipline_case_month_index: int = -99
var recent_rumor_card_ids: Array[String] = []
var bw_micro_event_cooldown: Dictionary = {}
var month_visitors: Array[String] = []
var pending_follow_ups: Array = []
var pending_scheduled_visitors: Array = []
var resolved_scheduled_visitors: Array[String] = []
var active_case_chain: Dictionary = {}
var historical_chains: Dictionary = {}
var items: Array[String] = []
var city_boost_item_slots: Array[String] = []


var city_boost_growth_months: Dictionary = {}
var personal_boost_item_slots: Array[String] = []
var unlocked_city_boost_slots: int = 0
var city_boost_slot_base_count: int = CITY_BOOST_SLOT_BASE_COUNT
var purchased_jianwen_ids: Array[String] = []
var applied_carried_city_effects: Dictionary = {}
var applied_carried_personal_effects: Dictionary = {}
var personal_boost_slots_migrated: bool = false
var guozuo_entries: Array[String] = []
var upgraded_governance_cards: Array[String] = []
var life_chronicle_entries: Array = []
var jinshi_year: int = 0
var sun_chuanting_branch_lock: bool = false
var wartime_index: int = 0


var branch: String = ""
var branch_index: int = 0
var last_branch_choice: String = ""


var bianwu_units: Array = []
var bianwu_unit_group_defs: Dictionary = {}
var bianwu_skills: Array = []
var bianwu_defense_act: int = 0
var bianwu_defense_regions: Array = []
var bianwu_defense_roads: Array = []
var bianwu_defense_enemies: Array = []
var bianwu_defense_officers: Array = []
var bianwu_command_points: int = 0
var bianwu_command_cap: int = 2
var bianwu_defense_last_report: Dictionary = {}
var bianwu_defense_warnings: Array = []


var pending_events: Array = []
var active_pending_event: Dictionary = {}
var keju_status: String = "none"
var keju_year: int = 0
var keju_year_str: String = ""
var keju_continue_mode: bool = false
var keju_start_act: int = 1
var force_dice_win: bool = false
var keju_fail_counts: Dictionary = {}
var keju_next_exam_age: Dictionary = {}


var in_prison: bool = false
var prison_index: int = 0


var emperor_dead: bool = false


var tags: Array[String] = []



var term_tag_counts: Dictionary = {}
var term_court_total: int = 0
var term_court_just: int = 0
var term_court_seen_ids: Dictionary = {}


var term_martial_chengfang: int = 0
var term_martial_lingwu: int = 0

var dezheng_plaque_evals: Dictionary = {}


var showing_result: bool = false
var last_choice_index: int = -1
var _last_choice = null
var transitioning_to_governance: bool = false


var sound_on: bool = true
var bgm_players: Array[AudioStreamPlayer] = []
var active_player_idx: int = 0
var current_bgm_path: String = ""
var sfx_player: AudioStreamPlayer

var music_toggle_tween: Tween


var TITLE_PLAYLIST: = ["res://assets/" + "山河入局.mp3", "res://assets/" + "山河破碎.mp3", "res://assets/" + "入局2.mp3", "res://assets/" + "归去 (Cover).mp3"]
const TITLE_PLAYLIST_GAP: = 6.0
var title_playlist_active: = false
var title_playlist_idx: = 0
var title_gap_pending: = false

func is_title_playlist_path(file_path: String) -> bool:
    return file_path in TITLE_PLAYLIST



var GOVERNANCE_PLAYLIST: = ["res://assets/" + "normal_bgm.mp3", "res://assets/" + "prologue_bgm.mp3", "res://assets/" + "governance_bgm_3.mp3", "res://assets/" + "Mountain Nocturne.mp3"]
const GOVERNANCE_PLAYLIST_GAP: = 6.0
var governance_playlist_active: = false
var governance_playlist_idx: = 0
var governance_gap_pending: = false


const RIOT_BGM_PATH: = "res://assets/" + "riot_bgm.mp3"
const RIOT_RESUME_DELAY: = 4.0
var riot_interrupt_active: = false
var riot_resume_pending: = false
var riot_resume_player_idx: = -1
var riot_resume_path: = ""
var riot_resume_governance_active: = false
var riot_interrupt_generation: = 0


var screen_landscape: bool = true
var landscape_size_mode: String = "auto"
var event_portraits_enabled: bool = true
const LANDSCAPE_SIZE_MODES: = ["auto", "desktop", "phone"]
const SETTINGS_PATH: = "user://settings.cfg"

func _save_settings() -> void :
    var cfg: = ConfigFile.new()
    cfg.set_value("settings", "screen_landscape", screen_landscape)
    cfg.set_value("settings", "landscape_size_mode", landscape_size_mode)
    cfg.set_value("settings", "event_portraits_enabled", event_portraits_enabled)
    cfg.set_value("settings", "theme", theme)
    cfg.set_value("settings", "sound_on", sound_on)
    cfg.save(SETTINGS_PATH)
    if OS.has_feature("web"):
        JavaScriptBridge.force_fs_sync()

func _load_settings() -> void :
    var cfg: = ConfigFile.new()
    if cfg.load(SETTINGS_PATH) == OK:
        var saved_screen_landscape = cfg.get_value("settings", "screen_landscape", true)
        screen_landscape = true
        landscape_size_mode = _normalize_landscape_size_mode(cfg.get_value("settings", "landscape_size_mode", "auto"))
        event_portraits_enabled = bool(cfg.get_value("settings", "event_portraits_enabled", true))
        sound_on = bool(cfg.get_value("settings", "sound_on", _default_sound_on()))

        var saved_theme = cfg.get_value("settings", "theme", "dark")
        theme = "dark"

        if saved_screen_landscape != true or saved_theme == "light":
            _save_settings()
    else:
        screen_landscape = true
        landscape_size_mode = "auto"
        event_portraits_enabled = true
        theme = "dark"
        sound_on = _default_sound_on()



func _default_sound_on() -> bool:
    return not OS.has_feature("web")

func _init() -> void :
    _load_settings()
    if screen_landscape:
        DisplayServer.screen_set_orientation(DisplayServer.SCREEN_SENSOR_LANDSCAPE)
    else:
        DisplayServer.screen_set_orientation(DisplayServer.SCREEN_SENSOR_PORTRAIT)

func set_screen_orientation(landscape: bool) -> void :
    screen_landscape = true
    DisplayServer.screen_set_orientation(DisplayServer.SCREEN_SENSOR_LANDSCAPE)
    _save_settings()

func _normalize_landscape_size_mode(mode) -> String:
    var normalized: = str(mode)
    if normalized == "tablet":
        return "desktop"
    if LANDSCAPE_SIZE_MODES.has(normalized):
        return normalized
    return "auto"

func set_landscape_size_mode(mode: String) -> void :
    landscape_size_mode = _normalize_landscape_size_mode(mode)
    _save_settings()

func set_large_ui_mode(enabled: bool) -> void :
    set_landscape_size_mode("phone" if enabled else "desktop")

func is_large_ui_mode() -> bool:
    return landscape_size_mode == "phone"

func set_event_portraits_enabled(enabled: bool) -> void :
    event_portraits_enabled = enabled
    _save_settings()

func cycle_landscape_size_mode() -> void :
    set_large_ui_mode( not is_large_ui_mode())

func _ready() -> void :

    for i in range(2):
        var p: = AudioStreamPlayer.new()
        p.bus = "Master"
        p.volume_db = -80.0
        add_child(p)
        bgm_players.append(p)

        p.finished.connect(_on_bgm_finished.bind(i))

    active_player_idx = 0
    current_bgm_path = ""
    start_title_playlist(0.0)


    sfx_player = AudioStreamPlayer.new()
    sfx_player.bus = "Master"
    sfx_player.volume_db = -4.0
    add_child(sfx_player)

var _first_interaction_done: = false

func _input(event: InputEvent) -> void :
    if not _first_interaction_done:
        if event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventKey:
            if event.is_pressed():
                _first_interaction_done = true
                _handle_first_interaction()

func _handle_first_interaction() -> void :
    if sound_on:
        var active_player: = bgm_players[active_player_idx]
        if is_instance_valid(active_player):
            if not active_player.playing or active_player.get_playback_position() <= 0.05:
                active_player.volume_db = 0.0
                active_player.play()

func set_music(on: bool) -> void :
    sound_on = on
    _save_settings()
    if is_instance_valid(music_toggle_tween):
        music_toggle_tween.kill()
    if bgm_players.is_empty():
        return
    var active_player: = bgm_players[active_player_idx]
    if not is_instance_valid(active_player):
        return

    if sound_on:

        active_player.stream_paused = false
        music_toggle_tween = create_tween()
        if not active_player.playing:
            active_player.volume_db = -80.0
            active_player.play()
        music_toggle_tween.tween_property(active_player, "volume_db", 0.0, 1.0)
    else:

        active_player.stream_paused = true
        active_player.volume_db = -80.0


func play_bgm(file_path: String, fade_duration: float = 1.5) -> void :
    if bgm_players.size() < 2:
        return

    if riot_interrupt_active and file_path != RIOT_BGM_PATH:
        riot_interrupt_active = false
        riot_resume_pending = false
        riot_interrupt_generation += 1
        if riot_resume_player_idx >= 0 and riot_resume_player_idx < bgm_players.size():
            var abandoned_player: = bgm_players[riot_resume_player_idx]
            if is_instance_valid(abandoned_player):
                abandoned_player.stream_paused = false
                abandoned_player.stop()



    if not (file_path in GOVERNANCE_PLAYLIST):
        governance_playlist_active = false
        governance_gap_pending = false
    if not is_title_playlist_path(file_path):
        title_playlist_active = false
        title_gap_pending = false

    if current_bgm_path == file_path:

        var active_player: = bgm_players[active_player_idx]
        if is_instance_valid(active_player):
            if sound_on:
                if not active_player.playing:
                    active_player.volume_db = -80.0
                    active_player.play()
                var t: = create_tween()
                t.tween_property(active_player, "volume_db", 0.0, fade_duration)
        return

    var old_idx: = active_player_idx
    var new_idx: = 1 - active_player_idx

    var old_player: = bgm_players[old_idx]
    var new_player: = bgm_players[new_idx]

    if not is_instance_valid(old_player) or not is_instance_valid(new_player):
        return

    var stream = load(file_path)
    if stream == null:
        return
    if stream is AudioStreamMP3:


        if (governance_playlist_active and file_path in GOVERNANCE_PLAYLIST) or (title_playlist_active and file_path in TITLE_PLAYLIST):
            stream.loop = false
        else:
            stream.loop = (file_path != "res://assets/" + "title_bgm.mp3" and file_path != "res://assets/" + "normal_bgm.mp3")

    new_player.stream = stream
    current_bgm_path = file_path
    active_player_idx = new_idx

    var t: = create_tween().set_parallel(true)


    if old_player.playing:
        t.tween_property(old_player, "volume_db", -80.0, fade_duration)
        var seq_t: = create_tween()
        seq_t.tween_interval(fade_duration)
        seq_t.tween_callback(old_player.stop)


    if sound_on:
        new_player.volume_db = -80.0
        new_player.play()
        t.tween_property(new_player, "volume_db", 0.0, fade_duration)
    else:
        new_player.volume_db = -80.0


func play_riot_interrupt_bgm(fade_duration: float = 1.0) -> void :
    if bgm_players.size() < 2 or riot_interrupt_active:
        return
    var resume_idx: = active_player_idx
    var event_idx: = 1 - active_player_idx
    var resume_player: = bgm_players[resume_idx]
    var event_player: = bgm_players[event_idx]
    if not is_instance_valid(resume_player) or not is_instance_valid(event_player):
        return
    var stream = load(RIOT_BGM_PATH)
    if stream == null:
        return
    if stream is AudioStreamMP3:
        stream.loop = true

    riot_interrupt_generation += 1
    riot_interrupt_active = true
    riot_resume_pending = false
    riot_resume_player_idx = resume_idx
    riot_resume_path = current_bgm_path
    riot_resume_governance_active = governance_playlist_active
    governance_playlist_active = false
    governance_gap_pending = false
    title_playlist_active = false
    title_gap_pending = false

    event_player.stream_paused = false
    event_player.stream = stream
    event_player.volume_db = -80.0
    active_player_idx = event_idx
    current_bgm_path = RIOT_BGM_PATH

    if resume_player.playing:
        var pause_tween: = create_tween()
        pause_tween.tween_property(resume_player, "volume_db", -80.0, fade_duration)
        pause_tween.tween_callback( func():
            if riot_interrupt_active and is_instance_valid(resume_player):
                resume_player.stream_paused = true
        )
    if sound_on:
        event_player.play()
        var event_tween: = create_tween()
        event_tween.tween_property(event_player, "volume_db", 0.0, fade_duration)


func resume_riot_interrupted_bgm(fade_duration: float = 1.5) -> void :
    if not riot_interrupt_active or riot_resume_pending:
        return
    riot_resume_pending = true
    var generation: = riot_interrupt_generation
    var event_player: = bgm_players[active_player_idx]
    if is_instance_valid(event_player) and event_player.playing:
        var event_fade: = create_tween()
        event_fade.tween_property(event_player, "volume_db", -80.0, fade_duration)
        await event_fade.finished
        if generation != riot_interrupt_generation:
            return
        event_player.stop()

    var tree: = get_tree()
    if tree == null:
        return
    await tree.create_timer(RIOT_RESUME_DELAY).timeout
    if generation != riot_interrupt_generation or not riot_interrupt_active:
        return
    if riot_resume_player_idx < 0 or riot_resume_player_idx >= bgm_players.size():
        return
    var resume_player: = bgm_players[riot_resume_player_idx]
    if not is_instance_valid(resume_player):
        return

    active_player_idx = riot_resume_player_idx
    current_bgm_path = riot_resume_path
    governance_playlist_active = riot_resume_governance_active
    governance_gap_pending = false
    riot_interrupt_active = false
    riot_resume_pending = false
    if sound_on:
        resume_player.volume_db = -80.0
        resume_player.stream_paused = false
        if not resume_player.playing:
            resume_player.play()
        var resume_fade: = create_tween()
        resume_fade.tween_property(resume_player, "volume_db", 0.0, fade_duration)



func is_in_hanmen_prologue() -> bool:
    if active_line != "hanmen":
        return false
    if in_prison:
        return false
    if is_governance_mode():
        return false


    if branch == "" and city.is_empty():
        return true
    if branch in ["origin", "origin_fail", "origin_detour", "keju", "keju_continue"] or branch.begins_with("keju"):
        return true
    return false


func play_default_bgm(fade_duration: float = 2.0) -> void :
    if is_in_hanmen_prologue():

        governance_playlist_active = false
        play_bgm("res://assets/" + "prologue_bgm.mp3", fade_duration)
    else:

        start_governance_playlist(fade_duration)


func start_title_playlist(fade_duration: float = 2.0) -> void :
    title_playlist_active = true
    governance_playlist_active = false
    if is_title_playlist_path(current_bgm_path):
        title_playlist_idx = TITLE_PLAYLIST.find(current_bgm_path)
        var p: = bgm_players[active_player_idx]
        if is_instance_valid(p) and p.stream is AudioStreamMP3:
            (p.stream as AudioStreamMP3).loop = false
        if sound_on and not p.playing and not title_gap_pending:
            p.volume_db = 0.0
            p.play()
        return
    title_playlist_idx = 0
    play_bgm(TITLE_PLAYLIST[title_playlist_idx], fade_duration)


func start_governance_playlist(fade_duration: float = 2.0) -> void :
    governance_playlist_active = true

    if current_bgm_path in GOVERNANCE_PLAYLIST:
        governance_playlist_idx = GOVERNANCE_PLAYLIST.find(current_bgm_path)
        var p: = bgm_players[active_player_idx]
        if is_instance_valid(p):


            if p.stream is AudioStreamMP3:
                (p.stream as AudioStreamMP3).loop = false

            if sound_on and not p.playing and not governance_gap_pending:
                p.volume_db = 0.0
                p.play()
        return
    governance_playlist_idx = 0
    play_bgm(GOVERNANCE_PLAYLIST[governance_playlist_idx], fade_duration)


func _on_bgm_finished(player_idx: int) -> void :

    if player_idx != active_player_idx:
        return


    if governance_playlist_active and current_bgm_path in GOVERNANCE_PLAYLIST:
        var tree_pl: = get_tree()
        if tree_pl == null:
            return
        governance_gap_pending = true
        await tree_pl.create_timer(GOVERNANCE_PLAYLIST_GAP).timeout
        governance_gap_pending = false

        if not governance_playlist_active or not sound_on:
            return
        if not (current_bgm_path in GOVERNANCE_PLAYLIST):
            return
        governance_playlist_idx = (governance_playlist_idx + 1) % GOVERNANCE_PLAYLIST.size()
        play_bgm(GOVERNANCE_PLAYLIST[governance_playlist_idx], 2.0)
        return


    if title_playlist_active and is_title_playlist_path(current_bgm_path):
        var title_tree: = get_tree()
        if title_tree == null:
            return
        title_gap_pending = true
        await title_tree.create_timer(TITLE_PLAYLIST_GAP).timeout
        title_gap_pending = false
        if not title_playlist_active or not sound_on or not is_title_playlist_path(current_bgm_path):
            return
        title_playlist_idx = (title_playlist_idx + 1) % TITLE_PLAYLIST.size()
        play_bgm(TITLE_PLAYLIST[title_playlist_idx], 2.0)
        return

    var delay_time: = 0.0
    if current_bgm_path == "res://assets/" + "title_bgm.mp3":
        delay_time = 5.0
    elif current_bgm_path == "res://assets/" + "normal_bgm.mp3":
        delay_time = 8.0

    if delay_time > 0.0:
        var tree: = get_tree()
        if tree == null:
            return
        await tree.create_timer(delay_time).timeout

        if (current_bgm_path == "res://assets/" + "title_bgm.mp3" or current_bgm_path == "res://assets/" + "normal_bgm.mp3") and sound_on:
            var player: = bgm_players[active_player_idx]
            if is_instance_valid(player) and not player.playing:
                player.play()


func play_card_deal_sfx() -> void :
    if not sound_on:
        return
    if not is_instance_valid(sfx_player):
        return
    var sfx_stream = load("res://assets/card_deal_sfx.mp3")
    if sfx_stream == null:
        return
    sfx_player.stream = sfx_stream
    sfx_player.play()


const PRIVACY_CONSENT_PATH: = "user://privacy_consent.cfg"

func is_privacy_agreed() -> bool:
    var cfg: = ConfigFile.new()
    if cfg.load(PRIVACY_CONSENT_PATH) != OK:
        return false
    return cfg.get_value("privacy", "agreed", false)

func set_privacy_agreed() -> void :
    var cfg: = ConfigFile.new()
    cfg.set_value("privacy", "agreed", true)
    cfg.save(PRIVACY_CONSENT_PATH)


var last_fanshi_turn: int = -99
var last_riot_turn: int = -99


func is_simple_mode() -> bool:
    return difficulty == "simple"

func monthly_action_points() -> int:

    var base: = 3 if active_line == "bianwu" else 2
    return base + (1 if is_simple_mode() else 0)

func reset() -> void :
    for m in get_meta_list():
        remove_meta(m)
    char_id = ""
    char_name = ""
    route = ""
    selected_timeline = "wanli"
    play_mode = "story"
    active_line = "hanmen"
    difficulty = "normal"
    stats = {}
    notified_personal_stat_capstones = []
    wentao_capstone_months = 0
    private_silver = 0
    lingwu = 0
    kuixing_fu_draw_count = 0
    attitudes = {}
    att_events_triggered = []
    att_event_last_time = -100
    att_event_repeat_last = {}
    honorary_title = ""
    honorary_title_rank = -1
    salary_penalty_months = 0
    living_shrine = false
    grain_shortage_last_time = -100
    rank_index = 0
    current_event = 0
    turn = 1
    _base_age = 20
    city = {}
    month = 0
    year = 0
    action_points = 0
    last_month_resource_delta = {}
    month_cards = []
    month_cards_done.clear()
    current_month_card_index = -1

    monthly_grain_breakdown.clear()
    monthly_silver_breakdown.clear()
    used_month_court.clear()
    used_month_visitors.clear()
    used_case_ids.clear()
    used_chain_ids.clear()
    mutiny_risk_modifiers.clear()
    last_military_discipline_case_month_index = -99
    recent_rumor_card_ids.clear()
    bw_micro_event_cooldown = {}
    month_visitors.clear()
    pending_follow_ups = []
    pending_scheduled_visitors = []
    resolved_scheduled_visitors.clear()
    active_case_chain = {}
    historical_chains = {}
    items = []
    city_boost_item_slots = []
    city_boost_growth_months = {}
    personal_boost_item_slots = []
    unlocked_city_boost_slots = 0
    city_boost_slot_base_count = CITY_BOOST_SLOT_BASE_COUNT
    purchased_jianwen_ids = []
    applied_carried_city_effects = {}
    applied_carried_personal_effects = {}
    personal_boost_slots_migrated = true
    guozuo_entries = []
    upgraded_governance_cards.clear()
    life_chronicle_entries = []
    branch = ""
    branch_index = 0
    last_branch_choice = ""
    bianwu_units = []
    bianwu_unit_group_defs = {}
    bianwu_skills = []
    bianwu_defense_act = 0
    bianwu_defense_regions = []
    bianwu_defense_roads = []
    bianwu_defense_enemies = []
    bianwu_defense_officers = []
    bianwu_command_points = 0
    bianwu_command_cap = 2
    bianwu_defense_last_report = {}
    bianwu_defense_warnings = []
    sun_chuanting_branch_lock = false
    wartime_index = 0
    in_prison = false
    prison_index = 0
    emperor_dead = false
    tags = []
    term_tag_counts = {}
    term_court_total = 0
    term_court_just = 0
    term_court_seen_ids = {}
    term_martial_chengfang = 0
    term_martial_lingwu = 0
    dezheng_plaque_evals = {}
    showing_result = false
    last_choice_index = -1
    _last_choice = null
    transitioning_to_governance = false
    last_fanshi_turn = -99
    last_riot_turn = -99
    pending_events = []
    active_pending_event = {}
    keju_status = "none"
    keju_year = 0
    keju_year_str = ""
    keju_continue_mode = false
    keju_start_act = 1
    force_dice_win = false
    keju_fail_counts = {}
    keju_next_exam_age = {}

func init_character(id: String, selected_traits: Array = []) -> void :
    var timeline = selected_timeline
    var saved_difficulty = difficulty
    var saved_play_mode = play_mode
    reset()
    selected_timeline = timeline
    difficulty = saved_difficulty
    play_mode = saved_play_mode
    if id not in GameData.characters:
        return
    var ch = GameData.characters[id]
    char_id = ch["id"]
    char_name = ch["name"]
    route = ch["route"]


    if selected_timeline == "chongzhen" and ch.has("stats_chongzhen"):
        stats = ch["stats_chongzhen"].duplicate()
        private_silver = ch.get("initial_private_silver_chongzhen", ch.get("initial_private_silver", 0))
    else:
        stats = ch["stats"].duplicate()
        private_silver = ch.get("initial_private_silver", 0)

    for trait_id in selected_traits:
        if trait_id in GameData.traits:
            var t_data = GameData.traits[trait_id]
            tags.append(t_data.get("name", trait_id))
            var effects = t_data.get("effects", {})
            for key in effects:
                if key in stats:
                    stats[key] = clampi(stats[key] + int(effects[key]), 0, 100)
                elif key == "private_silver":
                    private_silver = max(0, private_silver + int(effects[key]))

    _apply_kuixing_fu_bonus()
    _apply_rebirth_bonus()




    if id == "shijia":
        attitudes = {
            "shengjuan": 50, "chaotang": 50, 
            "jianjun": 40, "junxin": 60, 
            "shimin": 50
        }
    else:
        var shishen_start = {"hanmen": 30, "jinshen": 75, "shijia": 45, "qingwang": 55, "shangjia": 35}
        attitudes = {
            "shengjuan": 50, "zhongguan": 30, "qingyi": 50, 
            "shishen": shishen_start.get(id, 50), 
            "minwang": 50
        }

    if selected_timeline == "chongzhen":
        if id == "shijia":


            _base_age = 20
            keju_status = "none"

            items = ["yanling_dao"]

            bianwu_units = [
                {
                    "id": "spear", 
                    "hp": 20, 
                    "cap": 10000, 
                    "level": 1, 
                    "name": "长枪手", 
                    "is_jiading": false
                }, 
                {
                    "id": "knife_shield", 
                    "hp": 5, 
                    "cap": 500, 
                    "level": 1, 
                    "name": "家丁·刀牌手", 
                    "is_jiading": true
                }
            ]
            bianwu_skills = []
            branch = ""
            branch_index = 0
            record_life_marker("start_chongzhen")
        else:

            _base_age = 26
            keju_status = "gongshi"

            enter_branch("keju", 5)
            record_life_marker("start_chongzhen")
    else:

        _base_age = 1

        enter_branch("origin", 1)
        record_life_marker("start_origin")
    state_changed.emit()

func _apply_kuixing_fu_bonus() -> void :
    if not has_feature("kuixing"):
        return
    var kuixing_count: = SaveManager.get_kuixing_fu_count()
    if kuixing_count <= 0:
        return
    stats["wentao"] = clampi(int(stats.get("wentao", 0)) + kuixing_count, 0, 100)



const REBIRTH_BONUS_STAT_MAX: = 12
const REBIRTH_BONUS_SILVER_MAX: = 20

func _apply_rebirth_bonus() -> void :
    if play_mode != "free":
        return
    var pts: = SaveManager.get_rebirth_points()
    if pts <= 0:
        return
    var dist: int = mini(pts, REBIRTH_BONUS_STAT_MAX)
    var keys: = ["wentao", "lizheng", "wulue", "tizhi"]
    for i in dist:
        var k: String = keys[i % keys.size()]
        if k in stats:
            stats[k] = clampi(int(stats[k]) + 1, 0, 100)
    private_silver += mini(pts, REBIRTH_BONUS_SILVER_MAX)

func apply_effects(effects: Dictionary) -> void :
    EffectsServiceRef.apply_effects_to_state(self, effects)
    state_changed.emit()

func add_tags(new_tags: Array) -> void :
    EffectsServiceRef.add_tags_to_state(self, new_tags)

func add_guozuo_entry(entry_id: String) -> bool:
    var normalized: = str(entry_id).strip_edges()
    if normalized == "" or normalized in guozuo_entries:
        return false
    guozuo_entries.append(normalized)
    return true

func record_life_marker(marker_id: String) -> void :
    var entry: = BiographyServiceRef.make_marker_entry(self, marker_id)
    _append_life_chronicle_entry(entry)

func record_life_choice(event_data: Dictionary, choice: Dictionary, choice_index: int) -> void :
    var entry: = BiographyServiceRef.make_choice_entry(self, event_data, choice, choice_index)
    _append_life_chronicle_entry(entry)

func _append_life_chronicle_entry(entry: Dictionary) -> void :
    var entry_id: = str(entry.get("id", ""))
    if entry_id == "":
        return
    for existing in life_chronicle_entries:
        if existing is Dictionary and str(existing.get("id", "")) == entry_id:
            return
    life_chronicle_entries.append(entry)





func _repeat_cooldown_has_backing(event_id: String, data: Dictionary) -> bool:
    if event_id == "":
        return false

    var prefix: = event_id + ":"
    for entry in data.get("life_chronicle_entries", []):
        if entry is Dictionary:
            var eid: = str(entry.get("id", ""))
            if eid == event_id or eid.begins_with(prefix):
                return true

    for card in data.get("month_cards", []):
        if card is Dictionary and str(card.get("id", "")) == event_id:
            return true

    if bool(data.get("in_prison", false)):
        return true
    return false

func get_guozuo_count() -> int:
    return guozuo_entries.size()

func get_dezheng_item_count() -> int:
    var count: = 0
    var dezheng_ids: = ["dezheng_umbrella_1", "dezheng_plaque_2", "dezheng_robe_3", "dezheng_mirror_4", "dezheng_whip_5"]
    for item_id in items:
        if item_id in dezheng_ids:
            count += 1
    return count

func get_served_posting_count() -> int:
    var count: = 1
    var current_act: = EventServiceRef._get_current_act(self)
    for act_key in GameData.ACT_TRANSITIONS.keys():
        if int(act_key) <= current_act:
            count += 1
    return max(1, count)

func has_dezheng_mandate() -> bool:
    return get_dezheng_item_count() >= 5


func reset_term_tenure_counters() -> void :
    term_tag_counts = {}
    term_court_total = 0
    term_court_just = 0
    term_court_seen_ids = {}
    term_martial_chengfang = 0
    term_martial_lingwu = 0



func record_term_choice(event_data: Dictionary, choice: Dictionary) -> void :
    for raw_tag in choice.get("tags", []):
        var tag: = str(raw_tag).strip_edges()
        if tag == "":
            continue
        term_tag_counts[tag] = int(term_tag_counts.get(tag, 0)) + 1

    var eff: Dictionary = choice.get("effects", {}) if choice.get("effects", {}) is Dictionary else {}
    var cf: = int(eff.get("chengfang", 0))
    if cf > 0:
        term_martial_chengfang += cf
    var lw: = int(eff.get("lingwu", 0))
    if lw > 0:
        term_martial_lingwu += lw

    if _is_court_event(event_data):
        var eid: = str(event_data.get("id", ""))
        if eid != "" and not term_court_seen_ids.has(eid):
            term_court_seen_ids[eid] = true
            term_court_total += 1
            var merit: = int(choice.get("effects", {}).get("zhengji", 0))
            if merit > 0:
                term_court_just += 1


func _is_court_event(event_data: Dictionary) -> bool:
    if event_data.is_empty():
        return false
    if str(event_data.get("case_id", "")) != "":
        return true
    if bool(event_data.get("is_court_session", false)):
        return true
    if str(event_data.get("sceneType", "")) == "court":
        return true
    if str(event_data.get("category", "")) == "court":
        return true
    return false

func _format_cz_year(y: int) -> String:
    var units = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
    var tens = ["", "十", "二十", "三十", "四十", "五十", "六十"]
    if y <= 0: return ""
    if y == 1: return "崇祯元年"
    var t = y / 10
    var u = y % 10
    var res = tens[t] + units[u]
    if res == "十": return "崇祯十年"
    return "崇祯" + res + "年"

func get_display_identity() -> String:
    if is_governance_mode():
        return get_rank_title()

    var active_branch = active_pending_event.get("branch", branch) if not active_pending_event.is_empty() else branch
    if active_branch not in ["origin", "origin_fail", "origin_detour", "keju", "keju_continue"] and not active_branch.begins_with("keju"):
        return get_rank_title()

    var year_str = _format_cz_year(jinshi_year)
    var suffix = "（" + year_str + "）" if year_str != "" else ""
    if keju_status == "zhuangyuan": return "状元" + suffix
    elif keju_status == "bangyan": return "榜眼" + suffix
    elif keju_status == "tanhua": return "探花" + suffix
    elif keju_status == "erjia": return "二甲进士" + suffix
    elif keju_status == "sanjia": return "三甲同进士" + suffix
    elif keju_status == "gongshi": return "贡士"
    elif keju_status == "jinshi": return "进士"
    elif keju_status == "juren": return "举人"
    elif keju_status == "xiucai": return "秀才"
    elif keju_status == "tongshi": return "童生"
    return "平民"

func has_official_salary_rank_title(rank_title: String = "") -> bool:
    var title: = rank_title if rank_title != "" else get_rank_title()
    for grade in OFFICIAL_MONTHLY_SALARY_BY_GRADE.keys():
        if title.begins_with(str(grade)):
            return true
    return false

func is_official_career_stage() -> bool:
    var rank_title: = get_rank_title()
    return has_official_salary_rank_title(rank_title) and get_display_identity() == rank_title

func get_rank_title() -> String:
    if rank_index >= 0 and rank_index < GameData.RANKS.size():
        return GameData.RANKS[rank_index]
    return "未知"

func get_office_title() -> String:
    var title: = get_rank_title()
    if title.contains("·"):
        title = title.split("·")[-1].strip_edges()
    elif title.contains(" "):
        title = title.split(" ")[-1].strip_edges()
    else:
        title = title.strip_edges()

    if title.contains("("):
        title = title.split("(")[0].strip_edges()
    if title.contains("（"):
        title = title.split("（")[0].strip_edges()

    return title

func get_office_juris_from_rank_title(rank_title: String = "") -> String:
    var title: = rank_title if rank_title != "" else get_rank_title()
    if title.contains("知县") or title.contains("县丞"):
        return "县"
    if title.contains("知州"):
        return "州"
    if title.contains("同知") or title.contains("知府"):
        return "府"
    return ""




const HONORARY_TITLE_INITIAL_BY_GRADE: = {
    "正七品": "承事郎", "从七品": "从仕郎", 
    "正六品": "承直郎", "从六品": "承务郎", 
    "正五品": "奉议大夫", "从五品": "奉训大夫", 
    "正四品": "中顺大夫", "从四品": "朝列大夫", 
    "正三品": "嘉议大夫", "从三品": "亚中大夫", 
    "正二品": "资善大夫", "从二品": "中奉大夫", 
    "正一品": "特进荣禄大夫", "从一品": "荣禄大夫", 
}
const HONORARY_TITLE_BY_GRADE: = {
    "正七品": "文林郎", "从七品": "征仕郎", 
    "正六品": "承德郎", "从六品": "儒林郎", 
    "正五品": "奉政大夫", "从五品": "奉直大夫", 
    "正四品": "中议大夫", "从四品": "朝议大夫", 
    "正三品": "正议大夫", "从三品": "大中大夫", 
    "正二品": "资德大夫", "从二品": "正奉大夫", 
    "正一品": "特进光禄大夫", "从一品": "荣禄大夫", 
}


func _lookup_honorary_title(table: Dictionary) -> String:
    var title: = get_rank_title()
    for grade in table:
        if title.begins_with(grade):
            return table[grade]
    return "文林郎"


func initial_honorary_title_for_rank() -> String:
    return _lookup_honorary_title(HONORARY_TITLE_INITIAL_BY_GRADE)


func resolve_honorary_title_for_rank() -> String:
    return _lookup_honorary_title(HONORARY_TITLE_BY_GRADE)


func grant_honorary_title() -> void :
    honorary_title = resolve_honorary_title_for_rank()
    honorary_title_rank = rank_index


func get_active_honorary_title() -> String:
    if not is_official_career_stage():
        return ""
    if str(active_line) not in ["", "hanmen"]:
        return ""
    if honorary_title != "" and honorary_title_rank == rank_index:
        return honorary_title
    return initial_honorary_title_for_rank()

func get_current_city_name() -> String:
    var cname = str(city.get("name", ""))
    if cname == "河西道":
        var juris: = get_office_juris_from_rank_title()
        if juris == "县":
            return "安化县"
        elif juris == "州":
            return "宁州"
        elif juris == "府":
            return "庆阳府"
    return cname


func get_save_location_label() -> String:
    if city.is_empty():
        return ""

    if branch in ["zhongchen", "bifan", "xiaoxiong", "xinghuo"]:
        return ""
    var city_label: = get_current_city_name()
    if city_label == "":
        return ""
    var juris: = str(city.get("juris", ""))
    if juris != "" and not city_label.ends_with(juris):
        city_label += juris
    var province: = str(city.get("province", ""))
    if province != "":
        return province + "·" + city_label
    return city_label

func resolve_transfer_city_for_act(act_key: String, rank_title: String = "") -> Dictionary:
    var city_cfg: Dictionary = GameData.CITY_BY_ACT.get(act_key, {})
    if city_cfg.is_empty():
        return {}
    var target: = {
        "name": city_cfg.get("name", ""), 
        "province": city_cfg.get("province", ""), 
        "juris": city_cfg.get("juris", ""), 
        "defaults": city_cfg.get("defaults", {}).duplicate(true)
    }
    var office_juris: = get_office_juris_from_rank_title(rank_title)
    var transfer_by_juris: Dictionary = GameData.TRANSFER_CITY_BY_ACT_AND_JURIS.get(act_key, {})
    if office_juris != "" and transfer_by_juris.has(office_juris):
        var transfer_cfg: Dictionary = transfer_by_juris.get(office_juris, {})
        target["name"] = transfer_cfg.get("name", target["name"])
        target["province"] = transfer_cfg.get("province", target["province"])
        target["juris"] = transfer_cfg.get("juris", office_juris)
        var transfer_defaults: Dictionary = transfer_cfg.get("defaults", {})
        for key in transfer_defaults:
            target["defaults"][key] = transfer_defaults[key]
    return target

func get_monthly_official_salary() -> int:
    return GameStateQueryServiceRef.monthly_official_salary(self)

func get_monthly_official_salary_desc() -> String:
    return GameStateQueryServiceRef.monthly_official_salary_desc(self)

func get_czYear() -> int:
    if is_governance_mode():
        return year
    return EventServiceRef.get_cz_year(get_current_event())





func _keju_retry_year_offset() -> int:
    if active_pending_event.is_empty() or str(active_pending_event.get("type", "")) != "branch":
        return 0
    var ev: = get_branch_event(str(active_pending_event.get("branch", "")), int(active_pending_event.get("index", 0)))
    for ch in ev.get("choices", []):
        var fck: = str(ch.get("failCounterKey", ""))
        var delay: = int(ch.get("failRetryDelayYears", 0))
        if fck != "" and delay > 0:
            return int(keju_fail_counts.get(fck, 0)) * delay
    return 0

func get_current_year_str() -> String:

    if is_governance_mode() or in_prison:
        return _format_cz_year(year)






    var cur_event: = get_current_event()
    if not cur_event.is_empty():
        var stage_str = str(cur_event.get("stage", ""))
        var active_branch = active_pending_event.get("branch", branch) if not active_pending_event.is_empty() else branch
        if stage_str.contains("终卷") or int(cur_event.get("year", 0)) == 17 or active_branch in ["zhongchen", "bifan", "xiaoxiong", "xinghuo"]:
            return "崇祯十七年"


    if branch in ["zhongchen", "bifan", "xiaoxiong", "xinghuo"]:
        return "崇祯十七年"

    if keju_status in ["zhuangyuan", "bangyan", "tanhua", "erjia", "sanjia", "jinshi"]:
        return "崇祯元年"

    var w_year = 30 + age + _keju_retry_year_offset()
    var format_zh = func(y):
        var units = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
        var tens = ["", "十", "二十", "三十", "四十", "五十", "六十"]
        var t = y / 10
        var u = y % 10
        var res = tens[t] + units[u]
        if res == "十": return "十年"
        return res + "年"

    if w_year < 48:
        return "万历" + format_zh.call(w_year)
    elif w_year == 48:
        return "泰昌元年"
    elif w_year <= 55:
        var tq_year = w_year - 48
        if tq_year == 1:
            return "天启元年"
        return "天启" + format_zh.call(tq_year)
    else:
        var cz_year = w_year - 55
        if cz_year == 1:
            return "崇祯元年"
        return "崇祯" + format_zh.call(cz_year)

func get_volume_label() -> String:
    if is_governance_mode():
        return EventServiceRef.get_governance_stage_label(self)

    if in_prison:
        return "大明" + _format_cz_year(year)

    var cur_event = get_current_event()
    var is_final_volume = false
    if cur_event != null:
        var stage_str = str(cur_event.get("stage", ""))
        var active_branch = active_pending_event.get("branch", branch) if not active_pending_event.is_empty() else branch
        if stage_str.contains("终卷") or int(cur_event.get("year", 0)) == 17 or active_branch in ["zhongchen", "bifan", "xiaoxiong", "xinghuo"]:
            is_final_volume = true

    if branch in ["zhongchen", "bifan", "xiaoxiong", "xinghuo"]:
        is_final_volume = true

    if is_final_volume:
        return "大明崇祯十七年"

    if keju_status in ["zhuangyuan", "bangyan", "tanhua", "erjia", "sanjia", "jinshi"]:
        return "大明崇祯元年"

    var active_branch = active_pending_event.get("branch", branch) if not active_pending_event.is_empty() else branch
    if active_branch in ["origin", "origin_detour", "origin_fail", "keju", "keju_continue"]:
        var w_year = 30 + age + _keju_retry_year_offset()
        var format_zh = func(y):
            var units = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
            var tens = ["", "十", "二十", "三十", "四十", "五十", "六十"]
            var t = y / 10
            var u = y % 10
            var res = tens[t] + units[u]
            if res == "十": return "十年"
            return res + "年"

        var era_str = ""
        if w_year < 48:
            era_str = "大明万历" + format_zh.call(w_year)
        elif w_year == 48:
            era_str = "大明泰昌元年"
        elif w_year <= 55:
            var tq_year = w_year - 48
            if tq_year == 1:
                era_str = "大明天启元年"
            else:
                era_str = "大明天启" + format_zh.call(tq_year)
        else:
            var cz_year = w_year - 55
            if cz_year == 1:
                era_str = "大明崇祯元年"
            else:
                era_str = "大明崇祯" + format_zh.call(cz_year)

        if active_branch in ["origin", "origin_detour"] and keju_status in ["tongshi", "xiucai", "juren"] and age < 26:
            var years_left = 3 - (age % 3)
            var exam_name = ""
            match keju_status:
                "tongshi": exam_name = "院试"
                "xiucai": exam_name = "乡试"
                "juren": exam_name = "会试"

            if years_left == 3:
                era_str += "·今年" + exam_name
            elif years_left == 2:
                era_str += "·两年后" + exam_name
            elif years_left == 1:
                era_str += "·一年后" + exam_name

        return era_str

    return EventServiceRef.get_volume_label(get_current_event())


func has_feature(feature: String) -> bool:
    return GameData.character_has_feature(char_id, feature)

func is_governance_mode() -> bool:
    if sun_chuanting_branch_lock and branch != "" and not in_prison:
        return true

    return has_feature("governance") and not city.is_empty() and branch == "" and not in_prison

func mark_sun_chuanting_branch_split() -> void :
    sun_chuanting_branch_lock = true
    action_points = monthly_action_points()
    state_changed.emit()

func is_after_sun_chuanting_branch_split() -> bool:
    return sun_chuanting_branch_lock

func get_governance_turn_label() -> String:
    return EventServiceRef.get_governance_turn_label(self)

func get_month_card_event(card_index: int) -> Dictionary:
    return EventServiceRef.get_month_card_event(self, card_index)

func generate_month_cards() -> Array:
    return EventServiceRef.generate_month_cards(self)

func execute_month_card(card_index: int) -> Dictionary:
    return EventServiceRef.execute_month_card(self, card_index)

func complete_month_card(card_index: int, auto_advance_month: bool = true) -> void :
    EventServiceRef.complete_month_card(self, card_index, auto_advance_month)

func get_attitude_tier(key: String) -> String:
    if key in attitudes:
        var tier_idx = GameData.get_tier(attitudes[key])
        if tier_idx >= 0 and tier_idx < GameData.TIER_NAMES.size():
            return GameData.TIER_NAMES[tier_idx]
    return "观望"

func check_bad_ending() -> String:
    return EndingServiceRef.check_bad_ending(self)

func resolve_tizhi_ending() -> String:
    return EndingServiceRef.resolve_tizhi_ending(self)

func get_branch_event(br: String, idx: int) -> Dictionary:
    return EventServiceRef.get_branch_event(br, idx, tags, self)

func get_current_event() -> Dictionary:
    var evt: Dictionary
    if not active_pending_event.is_empty():
        if active_pending_event.has("type") and active_pending_event["type"] == "branch":
            evt = get_branch_event(active_pending_event["branch"], active_pending_event["index"])

    if evt.is_empty():
        if branch != "":
            evt = EventServiceRef.get_branch_event(branch, branch_index, tags, self)
        else:
            evt = EventServiceRef.get_current_event(in_prison, prison_index, branch, branch_index, current_event, tags)

    if not evt.is_empty():
        var evt_id: = str(evt.get("id", ""))
        var is_relief: = "relief" in evt_id or "marquis" in evt_id or "regent" in evt_id or "北京解围" in tags or "摄政监国" in tags
        if is_relief:
            if emperor_dead:
                emperor_dead = false
                call_deferred("emit_state_changed")
        elif evt.get("emperorDead", false) and not emperor_dead:
            emperor_dead = true
            attitudes["shengjuan"] = 50

            if attitudes.has("zhongguan"):
                attitudes["zhongguan"] = 50
            call_deferred("emit_state_changed")

    return evt

func emit_state_changed() -> void :
    state_changed.emit()


func is_game_over() -> bool:
    return EventServiceRef.is_game_over(branch, branch_index, current_event, tags)

func is_branch_exhausted() -> bool:
    return EventServiceRef.is_branch_exhausted(branch, branch_index)

func advance_event() -> void :
    if not active_pending_event.is_empty():
        active_pending_event = {}
        if not pending_events.is_empty():
            active_pending_event = pending_events.pop_front()
            _internal_advance()
            return

    else:
        if not pending_events.is_empty():
            active_pending_event = pending_events.pop_front()
            _internal_advance()
            return

    var old_age = age


    if in_prison:
        prison_index += 1
        if prison_index >= GameData.prison_events.size():

            in_prison = false
            prison_index = 0
            set_meta("prison_transition_shown", false)
            set_meta("prison_just_exited", true)
    elif branch != "":
        branch_index += 1
    else:
        current_event += 1

    var new_age = age
    if new_age > old_age:
        _check_keju_trigger(new_age)

    var evt = get_current_event()
    if evt.has("skipIfKeju") and keju_status in evt["skipIfKeju"]:
        call_deferred("advance_event")
        return

    _internal_advance()

func _internal_advance() -> void :
    if transitioning_to_governance:

        transitioning_to_governance = false
        turn = 1
        month = 9
    else:
        turn += 1
    showing_result = false
    last_choice_index = -1
    _last_choice = null
    state_changed.emit()
    event_advanced.emit()

func _check_keju_trigger(new_age: int) -> void :
    if keju_status == "none":
        return
    if is_governance_mode() or not city.is_empty():
        return
    if keju_next_exam_age.has(keju_status):
        var min_next_age: = int(keju_next_exam_age.get(keju_status, 0))
        if new_age < min_next_age:
            return
        keju_next_exam_age.erase(keju_status)
    if keju_status == "jinshi" or keju_status in ["zhuangyuan", "bangyan", "tanhua", "erjia", "sanjia"]:

        if new_age == 26:
            pending_events.push_back({"type": "branch", "branch": "keju", "index": 7})
        return


    if new_age == 26:
        if keju_status == "juren":

            force_dice_win = true
            pending_events.push_back({"type": "branch", "branch": "keju", "index": 3})
        elif keju_status == "gongshi":

            pending_events.push_back({"type": "branch", "branch": "keju", "index": 4})
        else:

            pending_events.push_back({"type": "branch", "branch": "origin_fail", "index": 0})
        return


    if new_age > 26:
        return
    if keju_status == "xianshi_prep":
        pending_events.push_back({"type": "branch", "branch": "origin", "index": 9})
    elif keju_status == "tongshi_prep":
        pending_events.push_back({"type": "branch", "branch": "keju", "index": 0})
    elif keju_status == "tongshi":
        if new_age % 3 == 0:
            pending_events.push_back({"type": "branch", "branch": "keju", "index": 1})
    elif keju_status == "xiucai":
        if new_age % 3 == 0:
            pending_events.push_back({"type": "branch", "branch": "keju", "index": 2})
    elif keju_status == "juren":
        if new_age % 3 == 0:
            pending_events.push_back({"type": "branch", "branch": "keju", "index": 3})


func _is_keju_year(cal_year: int, status: String) -> bool:

    var yuanshi_years = [1629, 1632, 1635, 1638, 1641]

    var xiangshi_years = [1630, 1633, 1636, 1639, 1642]

    var huishi_years = [1628, 1631, 1634, 1637, 1640, 1643]
    match status:
        "tongshi": return cal_year in yuanshi_years
        "xiucai": return cal_year in xiangshi_years
        "juren": return cal_year in huishi_years
    return false

func _get_kc_exam_index(status: String) -> int:
    match status:
        "tongshi_prep", "tongshi": return 0
        "xiucai": return 1
        "juren": return 2
        "gongshi": return 4
    return 0





func _get_governance_entry(cal_year: int) -> Dictionary:
    var act_key: = _resolve_act_key_for_year(cal_year)
    var act_cfg: Dictionary = GameData.ACT_CONFIG.get(act_key, {})
    var city_cfg: Dictionary = GameData.CITY_BY_ACT.get(act_key, {})
    return {
        "city_act": int(act_key), 
        "start_year": int(act_cfg.get("startYear", 1)), 
        "rank_idx": 0, 

        "city_name": str(city_cfg.get("name", "")), 
        "city_juris": str(city_cfg.get("juris", "")), 
    }



func _resolve_act_key_for_year(cal_year: int) -> String:
    var ordinal: = cal_year
    if cal_year >= 1628:
        ordinal = cal_year - 1627
    for key in GameData.ACT_CONFIG:
        var cfg: Dictionary = GameData.ACT_CONFIG[key]
        var sy: = int(cfg.get("startYear", 0))
        var ey: = int(cfg.get("endYear", sy))
        if ordinal >= sy and ordinal <= ey:
            return str(key)
    return "1"

func get_initial_governance_entry() -> Dictionary:
    return _get_governance_entry(1)

func initialize_governance_city(act: int = -1) -> void :
    var entry: = get_initial_governance_entry()
    var act_key: = str(act if act > 0 else int(entry.get("city_act", keju_start_act)))
    if not GameData.CITY_BY_ACT.has(act_key):
        act_key = str(keju_start_act)
    if not GameData.CITY_BY_ACT.has(act_key):
        act_key = "1"

    var city_cfg: Dictionary = GameData.CITY_BY_ACT.get(act_key, {})
    var transfer_cfg: Dictionary = resolve_transfer_city_for_act(act_key, get_rank_title())
    city = city_cfg.get("defaults", {}).duplicate(true)
    var transfer_defaults: Dictionary = transfer_cfg.get("defaults", {})
    for key in transfer_defaults:
        city[key] = transfer_defaults[key]
    city["name"] = transfer_cfg.get("name", entry.get("city_name", city_cfg.get("name", "")))
    city["juris"] = transfer_cfg.get("juris", entry.get("city_juris", city_cfg.get("juris", "")))
    city["province"] = transfer_cfg.get("province", city_cfg.get("province", ""))
    city["zhengji"] = int(city.get("zhengji", 0))
    applied_carried_city_effects.clear()
    apply_carried_item_city_effects()

    normalize_personal_boost_item_slots()
    keju_start_act = int(act_key)

    update_monthly_breakdowns()

    if GameData.active_line == "bianwu":
        var cur_guanjun: = int(city.get("guanjun", 0))
        var cur_jiading: = int(city.get("jiading", 0))
        var BattleTypesRef = load("res://scripts/battle/battle_types.gd")
        var BIANWU_FORCE_CARD_CAP: = 10000
        for i in range(bianwu_units.size()):
            var u_entry = bianwu_units[i]
            if not u_entry is Dictionary:
                var unit_id: = str(u_entry)
                var unit_def = BattleTypesRef.unit_def(unit_id)
                u_entry = {
                    "id": unit_id, 
                    "hp": int(unit_def.get("hp", 0)), 
                    "cap": BIANWU_FORCE_CARD_CAP, 
                    "level": 1, 
                    "name": str(unit_def.get("name", unit_id)), 
                    "is_jiading": false
                }
                bianwu_units[i] = u_entry
        BianwuDefenseServiceRef.normalize_unit_cards(self)
        var groups_by_kind: = {"guanjun": {}, "jiading": {}}
        var group_order: = {"guanjun": [], "jiading": []}
        for u_entry in bianwu_units:
            if not u_entry is Dictionary:
                continue
            var kind: = "jiading" if bool(u_entry.get("is_jiading", false)) else "guanjun"
            var group_key: = BianwuDefenseServiceRef.unit_group_key(u_entry)
            if not groups_by_kind[kind].has(group_key):
                groups_by_kind[kind][group_key] = 0
                group_order[kind].append(group_key)
            groups_by_kind[kind][group_key] = int(groups_by_kind[kind][group_key]) + int(u_entry.get("hp", 0))
        var default_unit_ids: = {"guanjun": "spear", "jiading": "knife_shield"}
        for kind in ["guanjun", "jiading"]:
            var target_total: int = cur_jiading if kind == "jiading" else cur_guanjun
            if group_order[kind].is_empty():
                if target_total <= 0:
                    continue
                var restored_persisted_group: = false
                for persisted_group_key in bianwu_unit_group_defs:
                    var persisted_definition: Dictionary = bianwu_unit_group_defs[persisted_group_key]
                    if bool(persisted_definition.get("is_jiading", false)) != (kind == "jiading"):
                        continue
                    BianwuDefenseServiceRef.set_unit_group_total(self, persisted_group_key, target_total)
                    restored_persisted_group = true
                    break
                if restored_persisted_group:
                    continue
                var default_unit_id: String = default_unit_ids[kind]
                var default_def: Dictionary = BattleTypesRef.unit_def(default_unit_id)
                var default_template: = {
                    "id": default_unit_id, 
                    "cap": 500 if kind == "jiading" else BIANWU_FORCE_CARD_CAP, 
                    "level": 1, 
                    "name": str(default_def.get("name", default_unit_id)), 
                    "is_jiading": kind == "jiading", 
                }
                var group_key: = "unit:%s:%d" % [default_unit_id, int(kind == "jiading")]
                BianwuDefenseServiceRef.set_unit_group_total(self, group_key, target_total, default_template)
                continue
            var existing_total: = 0
            for group_key in group_order[kind]:
                existing_total += int(groups_by_kind[kind][group_key])
            var remaining_total: = target_total
            for group_index in range(group_order[kind].size()):
                var group_key: String = group_order[kind][group_index]
                var group_total: = remaining_total
                if group_index < group_order[kind].size() - 1:
                    group_total = int(round(float(target_total) * int(groups_by_kind[kind][group_key]) / existing_total)) if existing_total > 0 else (target_total if group_index == 0 else 0)
                    group_total = clampi(group_total, 0, remaining_total)
                remaining_total -= group_total
                BianwuDefenseServiceRef.set_unit_group_total(self, group_key, group_total)

func apply_carried_item_city_effects() -> int:
    return MonthlySettlementServiceRef.apply_carried_item_city_effects(self)

func _item_has_city_effect(item_id: String) -> bool:
    if item_id == "" or item_id not in items:
        return false
    var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
    var city_effects: Dictionary = item_def.get("cityEffects", {})
    for raw_key in city_effects:
        if GameData.CITY_STAT_KEYS.has(str(raw_key)):
            return true
    return false



func _item_has_status_effect(item_id: String) -> bool:
    if item_id == "" or item_id not in items:
        return false
    if item_id == "gaoji_banyin":
        return true
    var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
    var status: Dictionary = item_def.get("statusEffects", {})
    for raw_key in status:
        if ITEM_STATUS_EFFECT_KEYS.has(str(raw_key)) and int(status[raw_key]) != 0:
            return true

    if int(status.get("liangshi_percent", 0)) != 0 or int(status.get("yinliang_percent", 0)) != 0:
        return true
    var attitude_effects: Dictionary = item_def.get("monthlyAttitudeEffects", {})
    for raw_key in attitude_effects:
        if raw_key in attitudes and int(attitude_effects[raw_key]) != 0:
            return true
    return false


func _item_is_boost_eligible(item_id: String) -> bool:
    return _item_has_city_effect(item_id) or _item_has_status_effect(item_id)


func get_item_monthly_status_effects(item_id: String) -> Dictionary:
    var out: = {}
    if item_id == "":
        return out
    if item_id == "gaoji_banyin":
        var income: = get_gaoji_banyin_income()
        out["yinliang"] = int(income.get("silver", 0))
        out["liangshi"] = int(income.get("grain", 0))
        out["private_silver"] = int(income.get("private", 0))
        return out
    var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
    var status: Dictionary = item_def.get("statusEffects", {})
    for raw_key in status:
        var key: = str(raw_key)
        if ITEM_STATUS_EFFECT_KEYS.has(key) and int(status[raw_key]) != 0:
            out[key] = int(status[raw_key])
    return out


func get_item_status_effect_parts(item_id: String) -> Array:
    var parts: Array = []
    var eff: = get_item_monthly_status_effects(item_id)
    for key in ITEM_STATUS_EFFECT_KEYS:
        if eff.has(key) and int(eff[key]) != 0:
            parts.append("%s %+d/月" % [ITEM_STATUS_EFFECT_LABELS.get(key, key), int(eff[key])])
    var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
    var grain_pct: = int(item_def.get("statusEffects", {}).get("liangshi_percent", 0))
    if grain_pct != 0:
        parts.append("官粮收益 %+d%%/月" % grain_pct)
    var silver_pct: = int(item_def.get("statusEffects", {}).get("yinliang_percent", 0))
    if silver_pct != 0:
        parts.append("库银收益 %+d%%/月" % silver_pct)
    var city_growth: Dictionary = item_def.get("cityLevelGrowth", {})
    for raw_key in city_growth:
        var gk: = str(raw_key)
        var period: = int(city_growth[raw_key])
        if GameData.CITY_STAT_KEYS.has(gk) and period > 0:
            parts.append("%s 每%d月+1" % [GameData.city_stat_effect_label(gk), period])
    var attitude_effects: Dictionary = item_def.get("monthlyAttitudeEffects", {})
    for raw_key in attitude_effects:
        var key: = str(raw_key)
        var amount: = int(attitude_effects.get(key, 0))
        if key in attitudes and amount != 0:
            parts.append("%s %+d/月" % [GameData.attitude_effect_label(key), amount])
    return parts

func get_item_monthly_attitude_effects(item_id: String) -> Dictionary:
    var out: = {}
    if item_id == "":
        return out
    var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
    var attitude_effects: Dictionary = item_def.get("monthlyAttitudeEffects", {})
    for raw_key in attitude_effects:
        var key: = str(raw_key)
        var amount: = int(attitude_effects[raw_key])
        if key in attitudes and amount != 0:
            out[key] = amount
    return out

func apply_slotted_item_monthly_attitude_effects() -> void :
    for item_id in get_city_boost_item_ids():
        var effects: = get_item_monthly_attitude_effects(item_id)
        for key in effects:
            attitudes[key] = clampi(int(attitudes.get(key, 50)) + int(effects[key]), 0, 100)




func apply_slotted_item_city_level_growth() -> void :
    var slotted: = get_city_boost_item_ids()
    for item_id in slotted:
        var growth: Dictionary = GameData.ITEM_DEFS.get(str(item_id), {}).get("cityLevelGrowth", {})
        if growth.is_empty():
            continue
        var progress: Dictionary = city_boost_growth_months.get(item_id, {})
        for raw_key in growth:
            var stat_key: = str(raw_key)
            if not GameData.CITY_STAT_KEYS.has(stat_key):
                continue
            var period: = int(growth[raw_key])
            if period <= 0:
                continue
            var months: = int(progress.get(stat_key, 0)) + 1
            while months >= period:
                var cur: = int(city.get(stat_key, 0))
                if cur >= CITY_STAT_MAX_LEVEL:
                    months = 0
                    break
                city[stat_key] = mini(cur + 1, CITY_STAT_MAX_LEVEL)
                months -= period
            progress[stat_key] = months
        city_boost_growth_months[item_id] = progress

    for item_id in city_boost_growth_months.keys():
        if item_id not in slotted:
            city_boost_growth_months.erase(item_id)


func is_item_slotted(item_id: String) -> bool:
    return item_id != "" and city_boost_item_slots.has(item_id)

func get_city_boost_slot_count() -> int:
    return city_boost_slot_base_count + maxi(0, unlocked_city_boost_slots)

func get_personal_boost_slot_count(cz_year: int = -1) -> int:
    if cz_year < 0:
        cz_year = get_czYear()
    return 2 + int(floor(float(maxi(0, cz_year - 1)) / 2.0))

func _item_is_personal_boost_eligible(item_id: String) -> bool:
    if item_id == "" or item_id not in items:
        return false
    var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
    var effects: Dictionary = item_def.get("effects", {})
    for key in PERSONAL_ITEM_EFFECT_KEYS:
        if int(effects.get(key, 0)) != 0:
            return true
    return false

func normalize_personal_boost_item_slots() -> void :
    var normalized: Array[String] = []
    var seen: = {}
    var max_slots: = get_personal_boost_slot_count()
    for entry in personal_boost_item_slots:
        var item_id: = str(entry)
        if item_id != "" and _item_is_personal_boost_eligible(item_id) and not seen.has(item_id):
            normalized.append(item_id)
            seen[item_id] = true
        else:
            normalized.append("")
        if normalized.size() >= max_slots:
            break
    while normalized.size() < max_slots:
        normalized.append("")
    personal_boost_item_slots = normalized

func get_personal_boost_item_ids() -> Array[String]:
    normalize_personal_boost_item_slots()
    var selected: Array[String] = []
    for item_id in personal_boost_item_slots:
        if item_id != "":
            selected.append(item_id)
    return selected

func apply_carried_item_personal_effects(notify_capstone: bool = true) -> void :
    for key in applied_carried_personal_effects:
        apply_personal_stat_delta(str(key), - int(applied_carried_personal_effects[key]), false)
    var next_effects: = {}
    for item_id in get_personal_boost_item_ids():
        var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
        var effects: Dictionary = item_def.get("effects", {})
        for key in PERSONAL_ITEM_EFFECT_KEYS:
            if int(effects.get(key, 0)) != 0:
                next_effects[key] = int(next_effects.get(key, 0)) + int(effects[key])
    applied_carried_personal_effects.clear()
    for key in next_effects:
        var old_value: = int(stats.get(key, 0))
        apply_personal_stat_delta(str(key), int(next_effects[key]), notify_capstone)
        var new_value: = int(stats.get(key, 0))
        applied_carried_personal_effects[key] = new_value - old_value

func set_personal_boost_item_slot(slot_index: int, item_id: String) -> bool:
    if slot_index < 0 or slot_index >= get_personal_boost_slot_count():
        return false
    normalize_personal_boost_item_slots()
    var clean_id: = str(item_id)
    if clean_id != "" and not _item_is_personal_boost_eligible(clean_id):
        return false
    for idx in range(personal_boost_item_slots.size()):
        if idx != slot_index and personal_boost_item_slots[idx] == clean_id and clean_id != "":
            personal_boost_item_slots[idx] = ""
    personal_boost_item_slots[slot_index] = clean_id
    apply_carried_item_personal_effects()
    state_changed.emit()
    return true

func auto_arrange_personal_boost_item_slots() -> void :
    var priority_keys: Array[String] = ["lizheng", "wulue", "wentao", "tizhi"]
    var candidates: Array[String] = []
    for item_id in items:
        if _item_is_personal_boost_eligible(item_id) and not candidates.has(item_id):
            candidates.append(item_id)
    candidates.sort_custom( func(left_id: String, right_id: String) -> bool:
        var left_effects: Dictionary = GameData.ITEM_DEFS.get(left_id, {}).get("effects", {})
        var right_effects: Dictionary = GameData.ITEM_DEFS.get(right_id, {}).get("effects", {})
        for key in priority_keys:
            var left_value: = int(left_effects.get(key, 0))
            var right_value: = int(right_effects.get(key, 0))
            if left_value != right_value:
                return left_value > right_value
        return false
    )
    personal_boost_item_slots.clear()
    var max_slots: = get_personal_boost_slot_count()
    for item_id in candidates:
        personal_boost_item_slots.append(item_id)
        if personal_boost_item_slots.size() >= max_slots:
            break
    normalize_personal_boost_item_slots()
    apply_carried_item_personal_effects()
    state_changed.emit()

func _migrate_legacy_personal_item_effects() -> void :

    for item_id in items:
        var old_effects: Dictionary = LEGACY_MIXED_ITEM_PERSONAL_EFFECTS.get(item_id, {})
        if old_effects.is_empty():
            var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
            old_effects = item_def.get("effects", {})
        for key in PERSONAL_ITEM_EFFECT_KEYS:
            if int(old_effects.get(key, 0)) != 0:
                stats[key] = clampi(int(stats.get(key, 0)) - int(old_effects[key]), 0, 100)
    personal_boost_item_slots.clear()
    for item_id in items:
        if _item_is_personal_boost_eligible(item_id):
            personal_boost_item_slots.append(item_id)
        if personal_boost_item_slots.size() >= get_personal_boost_slot_count():
            break
    personal_boost_slots_migrated = true
    applied_carried_personal_effects.clear()
    normalize_personal_boost_item_slots()
    apply_carried_item_personal_effects(false)

func normalize_city_boost_item_slots() -> void :
    var normalized: Array[String] = []
    var seen: = {}
    var max_slots: = get_city_boost_slot_count()
    for entry in city_boost_item_slots:
        var item_id: = str(entry)
        if item_id == "":
            normalized.append("")
        elif _item_is_boost_eligible(item_id) and not seen.has(item_id):
            normalized.append(item_id)
            seen[item_id] = true
        else:
            normalized.append("")
        if normalized.size() >= max_slots:
            break
    while normalized.size() < max_slots:
        normalized.append("")
    city_boost_item_slots = normalized

func migrate_legacy_city_boost_item_slots() -> void :
    city_boost_item_slots.clear()
    for item_id in items:
        if _item_is_boost_eligible(item_id):
            city_boost_item_slots.append(str(item_id))
        if city_boost_item_slots.size() >= get_city_boost_slot_count():
            break
    normalize_city_boost_item_slots()

func get_city_boost_item_ids() -> Array[String]:
    normalize_city_boost_item_slots()
    var selected: Array[String] = []
    for item_id in city_boost_item_slots:
        if item_id != "":
            selected.append(item_id)
    return selected

func set_city_boost_item_slot(slot_index: int, item_id: String) -> bool:
    if slot_index < 0 or slot_index >= get_city_boost_slot_count():
        return false
    normalize_city_boost_item_slots()
    var clean_id: = str(item_id)
    if clean_id != "" and not _item_is_boost_eligible(clean_id):
        return false
    for idx in range(city_boost_item_slots.size()):
        if idx != slot_index and city_boost_item_slots[idx] == clean_id and clean_id != "":
            city_boost_item_slots[idx] = ""
    city_boost_item_slots[slot_index] = clean_id
    normalize_city_boost_item_slots()
    apply_carried_item_city_effects()
    update_monthly_breakdowns()
    state_changed.emit()
    return true





func move_city_boost_item_to_slot(item_id: String, target_slot: int) -> bool:
    if target_slot < 0 or target_slot >= get_city_boost_slot_count():
        return false
    var clean_id: = str(item_id)
    if clean_id == "" or not _item_is_boost_eligible(clean_id):
        return false
    normalize_city_boost_item_slots()
    var src: = -1
    for idx in range(city_boost_item_slots.size()):
        if str(city_boost_item_slots[idx]) == clean_id:
            src = idx
            break
    if src == target_slot:
        return false
    var displaced: = str(city_boost_item_slots[target_slot])
    city_boost_item_slots[target_slot] = clean_id
    if src >= 0:

        city_boost_item_slots[src] = displaced
    normalize_city_boost_item_slots()
    apply_carried_item_city_effects()
    update_monthly_breakdowns()
    state_changed.emit()
    return true

func spend_lingwu_for_stat(stat_key: String) -> bool:
    return spend_lingwu_for_stat_amount(stat_key, 1) > 0

func apply_personal_stat_delta(stat_key: String, delta: int, notify_capstone: bool = true) -> int:
    if not stats.has(stat_key):
        return 0
    var old_value: = int(stats.get(stat_key, 0))
    var new_value: = clampi(old_value + delta, 0, PersonalStatCapstoneServiceRef.STAT_CAP)
    stats[stat_key] = new_value
    if stat_key == "wentao" and new_value < PersonalStatCapstoneServiceRef.STAT_CAP:
        wentao_capstone_months = 0
    if notify_capstone and str(active_line) == "hanmen" and old_value < PersonalStatCapstoneServiceRef.STAT_CAP and new_value >= PersonalStatCapstoneServiceRef.STAT_CAP and not notified_personal_stat_capstones.has(stat_key):
        notified_personal_stat_capstones.append(stat_key)
        personal_stat_capstone_reached.emit(stat_key)
    return new_value - old_value

func spend_lingwu_for_stat_amount(stat_key: String, amount: int) -> int:
    var requested: = maxi(0, amount)
    if requested <= 0:
        return 0
    if not stats.has(stat_key):
        return 0
    var current_val: = int(stats.get(stat_key, 0))
    var remaining: = maxi(0, 100 - current_val)
    if remaining <= 0:
        return 0
    var affordable: = int(floor(float(lingwu) / float(LINGWU_STAT_COST)))
    var apply_amount: = mini(requested, mini(affordable, remaining))
    if apply_amount <= 0:
        return 0
    lingwu = maxi(0, lingwu - apply_amount * LINGWU_STAT_COST)
    apply_personal_stat_delta(stat_key, apply_amount)
    stats = stats.duplicate()
    state_changed.emit()
    return apply_amount

func spend_lingwu_for_city_boost_slot() -> bool:
    if lingwu < LINGWU_CITY_BOOST_SLOT_COST:
        return false
    lingwu = maxi(0, lingwu - LINGWU_CITY_BOOST_SLOT_COST)
    unlocked_city_boost_slots += 1
    normalize_city_boost_item_slots()
    state_changed.emit()
    return true

func spend_lingwu_for_governance_card(card_id: String) -> bool:
    var target_id: = str(card_id).strip_edges()
    if lingwu < LINGWU_CARD_UPGRADE_COST:
        return false
    if target_id == "" or upgraded_governance_cards.has(target_id):
        return false
    var found: = false
    for card in GameData.GOVERNANCE_CARDS:
        if typeof(card) != TYPE_DICTIONARY:
            continue
        if str(card.get("id", "")) == target_id and str(card.get("specialType", "")) != "card_upgrade":
            found = true
            break
    if not found:
        return false
    lingwu = maxi(0, lingwu - LINGWU_CARD_UPGRADE_COST)
    upgraded_governance_cards.append(target_id)
    state_changed.emit()
    return true

func get_jianwen_offer(offer_id: String) -> Dictionary:
    for offer in JIANWEN_OFFERS:
        if str(offer.get("id", "")) == offer_id:
            return offer
    return {}

func is_jianwen_purchased(offer_id: String) -> bool:
    return purchased_jianwen_ids.has(offer_id)



func spend_lingwu_for_jianwen(offer_id: String) -> bool:
    if GameData.active_line != "hanmen":
        return false
    var offer: = get_jianwen_offer(offer_id)
    if offer.is_empty() or is_jianwen_purchased(offer_id):
        return false
    var cost: = int(offer.get("cost", 0))
    if lingwu < cost:
        return false
    var visitor_id: = str(offer.get("visitor_id", ""))
    if visitor_id == "":
        return false
    lingwu = maxi(0, lingwu - cost)
    purchased_jianwen_ids.append(offer_id)
    pending_scheduled_visitors.append({
        "visitor_id": visitor_id, 
        "act": get_current_governance_act(), 
        "missed_turns": 0, 
    })
    state_changed.emit()
    return true

func get_current_governance_act() -> int:
    if not is_governance_mode():
        return 0
    return EventServiceRef._get_current_act(self)

func get_governance_merit() -> int:
    if city.is_empty():
        return 0
    return int(city.get("zhengji", 0)) + get_governance_city_stat_merit()

func get_governance_city_stat_merit() -> int:
    if city.is_empty():
        return 0
    var act_key: = str(get_current_governance_act())
    var city_cfg: Dictionary = GameData.CITY_BY_ACT.get(act_key, {})
    var defaults: Dictionary = city_cfg.get("defaults", {})
    var merit: = 0
    for stat_key in GameData.CITY_STAT_KEYS:
        var base_level: = int(defaults.get(stat_key, GameData.CITY_STAT_INIT.get(stat_key, 1)))
        var current_level: = int(city.get(stat_key, base_level))
        merit += maxi(0, current_level - base_level) * 100
    return merit

func _get_scripted_governance_merit_cap() -> int:
    if city.is_empty() or year <= 0 or month <= 0:
        return 0
    var current_act: = get_current_governance_act()
    if current_act <= 0:
        return 0
    var current_time: = int(year) * 12 + int(month)
    var cap: = 0
    for raw_schedule_key in GameData.SPECIAL_EVENT_SCHEDULE:
        var schedule_key: = str(raw_schedule_key)
        var parts: = schedule_key.split("-")
        if parts.size() != 2:
            continue
        var event_year: = int(parts[0])
        var event_month: = int(parts[1])
        if event_year <= 0 or event_month <= 0:
            continue
        var event_act: = int((event_year - 1) / 3) + 1
        if event_act != current_act:
            continue
        if event_year * 12 + event_month > current_time:
            continue
        var event_id: = str(GameData.SPECIAL_EVENT_SCHEDULE[raw_schedule_key])
        var best_reward: = 0
        for event_data in GameData.events:
            if str(event_data.get("id", "")) != event_id:
                continue
            for choice in event_data.get("choices", []):
                best_reward = maxi(best_reward, int(choice.get("meritReward", 0)))
            break
        cap += best_reward
    return cap

func _get_legacy_court_case_merit_cap(save_data: Dictionary) -> int:
    var used_ids: Dictionary = {}
    for raw_case_id in save_data.get("used_case_ids", []):
        var case_id: = str(raw_case_id)
        if case_id != "":
            used_ids[case_id] = true
    for raw_case_id in save_data.get("used_month_court", []):
        var case_id: = str(raw_case_id)
        if case_id != "":
            used_ids[case_id] = true
    if used_ids.is_empty():
        return 0
    var cap: = 0
    for case_data in GameData.COURT_CASES:
        var case_id: = str(case_data.get("id", ""))
        if not used_ids.has(case_id):
            continue
        var best_reward: = 0
        for choice in case_data.get("choices", []):
            var effects: Dictionary = choice.get("effects", {})
            best_reward = maxi(best_reward, int(effects.get("zhengji", 0)))
        cap += best_reward
    return cap

func _migrate_legacy_governance_merit(save_data: Dictionary) -> void :
    if city.is_empty() or not city.has("zhengji"):
        return
    var scripted_cap: = _get_scripted_governance_merit_cap() + _get_legacy_court_case_merit_cap(save_data)
    var stored_merit: = int(city.get("zhengji", 0))
    if stored_merit > scripted_cap:
        city["zhengji"] = scripted_cap

func get_governance_merit_target() -> int:
    var act_key: = str(get_current_governance_act())
    var act_cfg: Dictionary = GameData.ACT_CONFIG.get(act_key, {})
    return int(act_cfg.get("meritTarget", 0))

func get_governance_merit_desc() -> String:
    var target: = get_governance_merit_target()

    if GameData.active_line == "bianwu":
        if target <= 0:
            return "本任尚无三年考成战功线。"
        return "边务考成以阵前战功为主：每打赢一场战事，按其规模记战功——大胜全额、惨胜六成、败绩无功。军务（后勤/情报/马政/兵工）按考成时的净提升另计：每高一级加 100，中途涨后又跌只按最后结果算。三年考成需 %d。" % target
    if target <= 0:
        return "本任尚无三年考成政绩线。"
    return "本任城池属性按考成时的净提升计政绩：当前等级高于初任等级，每高一级加 100；中途涨后又跌，只按最后结果算。响应朝廷征调、输送钱粮所得政绩另行记账，不受城池属性涨跌影响。三年考成需 %d。" % target

func can_request_merit_promotion() -> bool:
    var target: = get_governance_merit_target()
    if target <= 0:
        return false
    if get_governance_merit() < target:
        return false
    var next_act_key: = str(get_current_governance_act() + 1)
    return GameData.ACT_TRANSITIONS.has(next_act_key)

func request_merit_promotion() -> bool:
    if not can_request_merit_promotion():
        return false
    var next_act_key: = str(get_current_governance_act() + 1)
    var transition: Dictionary = GameData.ACT_TRANSITIONS.get(next_act_key, {})
    var target_rank: = str(transition.get("rank", "")).replace(" ", "")
    if target_rank == "":
        return false
    for idx in range(GameData.RANKS.size()):
        if str(GameData.RANKS[idx]).replace(" ", "") == target_rank:
            if idx > rank_index:
                rank_index = idx
                state_changed.emit()
                return true
            return false
    return false

func _find_next_keju_year(cal_year_now: int, status: String) -> int:
    var years: Array = []
    match status:
        "tongshi": years = [1629, 1632, 1635, 1638, 1641]
        "xiucai": years = [1630, 1633, 1636, 1639, 1642]
        "juren": years = [1628, 1631, 1634, 1637, 1640, 1643]
    for y in years:
        if y > cal_year_now:
            return y
    return -1

func enter_branch(br: String, idx: int = 0) -> void :
    branch = br
    branch_index = idx - 1
    state_changed.emit()

func enter_prison() -> void :
    in_prison = true
    prison_index = -1
    state_changed.emit()

func exit_prison() -> void :
    in_prison = false
    prison_index = 0
    state_changed.emit()

func determine_ending() -> Dictionary:
    return EndingServiceRef.determine_ending(self)

func is_loss_ending(ending: Dictionary) -> bool:
    return EndingServiceRef.is_loss_ending(ending)

func get_ending_bgm_path(ending: Dictionary) -> String:
    if is_loss_ending(ending):
        return "res://assets/" + "bad_ending_bgm.mp3"
    if EndingServiceRef.is_retreat_ending(ending):
        return "res://assets/" + "retreat_ending_bgm.mp3"
    if EndingServiceRef.is_kangqing_ending(ending):
        return "res://assets/" + "入局2.mp3"
    return "res://assets/" + "终局回响.mp3"

func to_save_data() -> Dictionary:
    return {
        "char_id": char_id, 
        "char_name": char_name, 
        "route": route, 
        "stats": stats.duplicate(), 
        "notified_personal_stat_capstones": notified_personal_stat_capstones.duplicate(), 
        "wentao_capstone_months": wentao_capstone_months, 
        "private_silver": private_silver, 
        "lingwu": lingwu, 
        "kuixing_fu_draw_count": kuixing_fu_draw_count, 
        "attitudes": attitudes.duplicate(), 
        "att_events_triggered": att_events_triggered.duplicate(), 
        "att_event_last_time": att_event_last_time, 
        "att_event_repeat_last": att_event_repeat_last.duplicate(), 
        "honorary_title": honorary_title, 
        "honorary_title_rank": honorary_title_rank, 
        "salary_penalty_months": salary_penalty_months, 
        "living_shrine": living_shrine, 
        "grain_shortage_last_time": grain_shortage_last_time, 
        "rank_index": rank_index, 
        "current_event": current_event, 
        "turn": turn, 
        "base_age": _base_age, 
        "city": city.duplicate(), 
        "month": month, 
        "year": year, 
        "action_points": action_points, 
        "month_cards": month_cards.duplicate(true), 
        "month_cards_done": month_cards_done.duplicate(), 
        "monthly_grain_breakdown": monthly_grain_breakdown.duplicate(true), 
        "monthly_silver_breakdown": monthly_silver_breakdown.duplicate(true), 
        "last_grain_shortage_report": last_grain_shortage_report.duplicate(true), 
        "last_month_resource_delta": last_month_resource_delta.duplicate(true), 
        "current_month_card_index": current_month_card_index, 
        "used_month_court": used_month_court.duplicate(), 
        "used_month_visitors": used_month_visitors.duplicate(), 
        "used_case_ids": used_case_ids.duplicate(), 
        "used_chain_ids": used_chain_ids.duplicate(), 
        "mutiny_risk_modifiers": mutiny_risk_modifiers.duplicate(true), 
        "last_military_discipline_case_month_index": last_military_discipline_case_month_index, 
        "recent_rumor_card_ids": recent_rumor_card_ids.duplicate(), 
        "bw_micro_event_cooldown": bw_micro_event_cooldown.duplicate(true), 
        "month_visitors": month_visitors.duplicate(), 
        "pending_follow_ups": pending_follow_ups.duplicate(true), 
        "pending_scheduled_visitors": pending_scheduled_visitors.duplicate(true), 
        "resolved_scheduled_visitors": resolved_scheduled_visitors.duplicate(), 
        "active_case_chain": active_case_chain.duplicate(true), 
        "historical_chains": historical_chains.duplicate(true), 
        "items": items.duplicate(), 
        "city_boost_item_slots": city_boost_item_slots.duplicate(), 
        "city_boost_growth_months": city_boost_growth_months.duplicate(true), 
        "personal_boost_item_slots": personal_boost_item_slots.duplicate(), 
        "unlocked_city_boost_slots": unlocked_city_boost_slots, 
        "purchased_jianwen_ids": purchased_jianwen_ids.duplicate(), 
        "city_boost_slot_base_count": city_boost_slot_base_count, 
        "applied_carried_city_effects": applied_carried_city_effects.duplicate(), 
        "applied_carried_personal_effects": applied_carried_personal_effects.duplicate(), 
        "personal_boost_slots_migrated": personal_boost_slots_migrated, 
        "guozuo_entries": guozuo_entries.duplicate(), 
        "upgraded_governance_cards": upgraded_governance_cards.duplicate(), 
        "life_chronicle_entries": life_chronicle_entries.duplicate(true), 
        "tags": tags.duplicate(), 
        "term_tag_counts": term_tag_counts.duplicate(), 
        "term_court_total": term_court_total, 
        "term_court_just": term_court_just, 
        "term_court_seen_ids": term_court_seen_ids.duplicate(), 
        "term_martial_chengfang": term_martial_chengfang, 
        "term_martial_lingwu": term_martial_lingwu, 
        "dezheng_plaque_evals": dezheng_plaque_evals.duplicate(), 
        "branch": branch, 
        "branch_index": branch_index, 
        "wartime_index": wartime_index, 
        "last_branch_choice": last_branch_choice, 
        "bianwu_units": bianwu_units.duplicate(), 
        "bianwu_unit_group_defs": bianwu_unit_group_defs.duplicate(true), 
        "bianwu_skills": bianwu_skills.duplicate(), 
        "bianwu_defense_act": bianwu_defense_act, 
        "bianwu_defense_regions": bianwu_defense_regions.duplicate(true), 
        "bianwu_defense_roads": bianwu_defense_roads.duplicate(true), 
        "bianwu_defense_enemies": bianwu_defense_enemies.duplicate(true), 
        "bianwu_defense_officers": bianwu_defense_officers.duplicate(true), 
        "bianwu_command_points": bianwu_command_points, 
        "bianwu_command_cap": bianwu_command_cap, 
        "bianwu_defense_last_report": bianwu_defense_last_report.duplicate(true), 
        "bianwu_defense_warnings": bianwu_defense_warnings.duplicate(true), 
        "in_prison": in_prison, 
        "prison_index": prison_index, 
        "emperor_dead": emperor_dead, 
        "last_fanshi_turn": last_fanshi_turn, 
        "last_riot_turn": last_riot_turn, 
            "keju_status": keju_status, 
            "keju_year": keju_year, 
            "keju_year_str": keju_year_str, 
            "keju_continue_mode": keju_continue_mode, 
            "keju_start_act": keju_start_act, 
            "force_dice_win": force_dice_win, 
            "keju_fail_counts": keju_fail_counts.duplicate(true), 
            "keju_next_exam_age": keju_next_exam_age.duplicate(true), 
            "selected_timeline": selected_timeline, 
            "play_mode": play_mode, 
            "active_line": active_line, 
            "save_schema_version": 2, 
            "difficulty": difficulty, 
        "display_identity": get_display_identity(), 
        "display_location": get_save_location_label(), 
        "pending_events": pending_events.duplicate(true), 
        "active_pending_event": active_pending_event.duplicate(true), 
        "transitioning_to_governance": transitioning_to_governance, 
        "governance_merit_schema": GOVERNANCE_MERIT_SCHEMA_VERSION, 
        "sun_chuanting_branch_lock": sun_chuanting_branch_lock, 
        "jinshi_year": jinshi_year, 
    }

func _normalize_attitude_keys(raw_attitudes: Dictionary, line_id: String = "") -> Dictionary:
    var normalized: = raw_attitudes.duplicate()
    if normalized.has("yanlu"):
        normalized["qingyi"] = normalized.get("qingyi", 0) + int(normalized["yanlu"])
        normalized.erase("yanlu")

    var keys: = GameData.att_keys_for_line(line_id)
    for key in keys:
        if not normalized.has(key):
            normalized[key] = 50
    return normalized

func _normalize_legacy_city_identity() -> void :
    if city.is_empty():
        return
    var legacy_name: = str(city.get("name", ""))
    if not LEGACY_CITY_IDENTITY_MIGRATIONS.has(legacy_name):
        return
    var migrated: Dictionary = LEGACY_CITY_IDENTITY_MIGRATIONS[legacy_name]
    city["name"] = migrated.get("name", legacy_name)
    city["province"] = migrated.get("province", city.get("province", ""))
    city["juris"] = migrated.get("juris", city.get("juris", ""))

func _city_identity_matches(candidate: Dictionary) -> bool:
    if candidate.is_empty() or city.is_empty():
        return false
    var expected_name: = str(candidate.get("name", ""))
    if expected_name == "" or str(city.get("name", "")) != expected_name:
        return false
    var expected_province: = str(candidate.get("province", ""))
    if expected_province != "" and str(city.get("province", "")) != expected_province:
        return false
    var expected_juris: = str(candidate.get("juris", ""))
    if expected_juris != "" and str(city.get("juris", "")) != expected_juris:
        return false
    return true

func _city_identity_matches_act(act: int) -> bool:
    if city.is_empty() or act <= 0:
        return false
    var act_key: = str(act)
    var city_cfg: Dictionary = GameData.CITY_BY_ACT.get(act_key, {})
    if _city_identity_matches(city_cfg):
        return true
    var transfer_by_juris: Dictionary = GameData.TRANSFER_CITY_BY_ACT_AND_JURIS.get(act_key, {})
    for juris_key in transfer_by_juris:
        var transfer_cfg: Dictionary = transfer_by_juris[juris_key]
        if _city_identity_matches(transfer_cfg):
            return true
    return false

func repair_governance_city_for_current_act() -> bool:
    if not is_governance_mode():
        return false
    var current_act: = get_current_governance_act()
    if current_act <= 0:
        return false
    if _city_identity_matches_act(current_act):
        return false
    initialize_governance_city(current_act)



    var months_per_year: = int(GameData.MONTHS_PER_YEAR)
    if months_per_year > 0 and (month < 1 or month > months_per_year):
        var act_cfg: Dictionary = GameData.ACT_CONFIG.get(str(current_act), {})
        month = int(act_cfg.get("startMonth", 1))
    return true

func load_save_data(data: Dictionary) -> void :
    if OS.has_feature("editor"):

        GameData._ready()
    reset()
    char_id = data.get("char_id", "")
    char_name = data.get("char_name", "")
    route = data.get("route", "")
    stats = data.get("stats", {}).duplicate()
    private_silver = data.get("private_silver", data.get("private_caibo", 0))
    lingwu = int(data.get("lingwu", 0))
    kuixing_fu_draw_count = clampi(int(data.get("kuixing_fu_draw_count", 0)), 0, SaveManager.KUIXING_FU_MAX_COUNT)

    var save_line: = str(data.get("active_line", ""))
    if save_line == "":
        save_line = "bianwu" if str(data.get("char_id", "")) == "shijia" else "hanmen"
    GameData.activate_line(save_line)
    active_line = save_line
    wentao_capstone_months = clampi(int(data.get("wentao_capstone_months", 0)), 0, PersonalStatCapstoneServiceRef.WENTAO_GROWTH_PERIOD - 1)
    notified_personal_stat_capstones = []
    if str(active_line) == "hanmen":
        if data.has("notified_personal_stat_capstones"):
            for raw_key in data.get("notified_personal_stat_capstones", []):
                var stat_key: = str(raw_key)
                if PersonalStatCapstoneServiceRef.STAT_ORDER.has(stat_key) and not notified_personal_stat_capstones.has(stat_key):
                    notified_personal_stat_capstones.append(stat_key)
        else:
            notified_personal_stat_capstones = PersonalStatCapstoneServiceRef.active_stat_keys(self)
    attitudes = _normalize_attitude_keys(data.get("attitudes", {}), save_line)
    att_events_triggered = []
    for att_id in data.get("att_events_triggered", []):
        var att_id_str: = str(att_id)
        if att_id_str != "" and att_id_str not in att_events_triggered:
            att_events_triggered.append(att_id_str)
    att_event_last_time = int(data.get("att_event_last_time", -100))
    att_event_repeat_last = {}
    var saved_repeat_last = data.get("att_event_repeat_last", {})
    if saved_repeat_last is Dictionary:
        for repeat_id in saved_repeat_last:
            var rid: = str(repeat_id)

            if not _repeat_cooldown_has_backing(rid, data):
                continue
            att_event_repeat_last[rid] = int(saved_repeat_last[repeat_id])
    honorary_title = str(data.get("honorary_title", ""))
    honorary_title_rank = int(data.get("honorary_title_rank", -1))
    salary_penalty_months = int(data.get("salary_penalty_months", 0))
    living_shrine = bool(data.get("living_shrine", false))
    grain_shortage_last_time = int(data.get("grain_shortage_last_time", -100))
    rank_index = data.get("rank_index", 0)
    current_event = data.get("current_event", 0)
    turn = data.get("turn", 1)
    var default_base_age = 20
    _base_age = data.get("base_age", default_base_age)
    city = data.get("city", {}).duplicate()
    _normalize_legacy_city_identity()
    if city.has("name"):
        var matched = false
        for act_key in GameData.CITY_BY_ACT:
            var cfg = GameData.CITY_BY_ACT[act_key]
            if cfg.get("name") == city.get("name"):
                var defs = cfg.get("defaults", {})
                var is_legacy = ( not city.has("renkou_val")) or (int(city.get("renkou_val", 0)) == 0)
                for k in defs:
                    if not city.has(k) or is_legacy:
                        city[k] = defs[k]
                if not city.has("zhengji"):
                    city["zhengji"] = 0
                matched = true
                break
        if not matched:
            var is_legacy = ( not city.has("renkou_val")) or (int(city.get("renkou_val", 0)) == 0)
            if is_legacy:
                city["renkou_val"] = 30000
                city["liumin"] = 500
                city["bingyong"] = 300
                city["yinliang"] = 2000
                city["liangshi"] = 8000
                city["chengfang"] = 3
                city["nongsang"] = 5
                city["shangmao"] = 3
                city["baigong"] = 2
                city["wenjiao"] = 3
            if not city.has("zhengji"):
                city["zhengji"] = 0
    month = data.get("month", 0)
    year = data.get("year", 0)
    action_points = data.get("action_points", 0)
    sun_chuanting_branch_lock = data.get("sun_chuanting_branch_lock", false)
    jinshi_year = data.get("jinshi_year", 0)
    if jinshi_year == 0 and is_governance_mode():
        jinshi_year = 1
    if int(data.get("governance_merit_schema", 1)) < GOVERNANCE_MERIT_SCHEMA_VERSION:
        _migrate_legacy_governance_merit(data)
    month_cards = data.get("month_cards", []).duplicate(true)
    EventServiceRef._migrate_legacy_cached_month_cards(self)
    var month_done = data.get("month_cards_done", [])
    monthly_grain_breakdown = data.get("monthly_grain_breakdown", []).duplicate(true)
    monthly_silver_breakdown = data.get("monthly_silver_breakdown", []).duplicate(true)
    last_grain_shortage_report = data.get("last_grain_shortage_report", {}).duplicate(true)
    last_month_resource_delta = data.get("last_month_resource_delta", {}).duplicate(true)
    month_cards_done.clear()
    for idx in month_done:
        month_cards_done.append(int(idx))
    current_month_card_index = data.get("current_month_card_index", -1)
    used_month_court.clear()
    for entry in data.get("used_month_court", []):
        var used_month_court_id: = str(entry)
        if used_month_court_id != "" and used_month_court_id not in used_month_court:
            used_month_court.append(used_month_court_id)
    used_month_visitors.clear()
    for entry in data.get("used_month_visitors", []):
        var used_month_visitor_id: = str(entry)
        if used_month_visitor_id != "" and used_month_visitor_id not in used_month_visitors:
            used_month_visitors.append(used_month_visitor_id)
    used_case_ids.clear()
    for entry in data.get("used_case_ids", []):
        var used_case_id: = str(entry)
        if used_case_id != "" and used_case_id not in used_case_ids:
            used_case_ids.append(used_case_id)
    used_chain_ids.clear()
    for entry in data.get("used_chain_ids", []):
        var used_chain_id: = str(entry)
        if used_chain_id != "" and used_chain_id not in used_chain_ids:
            used_chain_ids.append(used_chain_id)
    mutiny_risk_modifiers = data.get("mutiny_risk_modifiers", []).duplicate(true)
    last_military_discipline_case_month_index = int(data.get("last_military_discipline_case_month_index", -99))
    recent_rumor_card_ids.clear()
    for entry in data.get("recent_rumor_card_ids", []):
        var rumor_id: = str(entry)
        if rumor_id != "":
            recent_rumor_card_ids.append(rumor_id)
    while recent_rumor_card_ids.size() > EventServiceRef.RUMOR_CARD_RECENT_WINDOW:
        recent_rumor_card_ids.pop_front()
    bw_micro_event_cooldown = {}
    var raw_cd = data.get("bw_micro_event_cooldown", {})
    if raw_cd is Dictionary:
        for k in raw_cd.keys():
            var arr: Array[int] = []
            for v in raw_cd[k]:
                arr.append(int(v))
            bw_micro_event_cooldown[str(k)] = arr
    month_visitors.clear()
    for entry in data.get("month_visitors", []):
        var month_visitor_id: = str(entry)
        if month_visitor_id != "" and month_visitor_id not in month_visitors:
            month_visitors.append(month_visitor_id)
    pending_follow_ups = data.get("pending_follow_ups", []).duplicate(true)
    pending_scheduled_visitors = data.get("pending_scheduled_visitors", []).duplicate(true)
    resolved_scheduled_visitors.clear()
    for entry in data.get("resolved_scheduled_visitors", []):
        resolved_scheduled_visitors.append(str(entry))



    var _recovered_scheduled: Array[String] = []
    for _rid in resolved_scheduled_visitors:
        if used_month_visitors.has(_rid):
            _recovered_scheduled.append(_rid)
    resolved_scheduled_visitors = _recovered_scheduled
    active_case_chain = data.get("active_case_chain", {}).duplicate(true)
    historical_chains = data.get("historical_chains", {}).duplicate(true)
    items.clear()
    for entry in data.get("items", []):
        var loaded_item_id: = str(entry)
        if loaded_item_id != "" and loaded_item_id not in items:
            items.append(loaded_item_id)
    unlocked_city_boost_slots = maxi(0, int(data.get("unlocked_city_boost_slots", 0)))
    purchased_jianwen_ids.clear()
    for _jw in data.get("purchased_jianwen_ids", []):
        purchased_jianwen_ids.append(str(_jw))
    city_boost_slot_base_count = int(data.get("city_boost_slot_base_count", CITY_BOOST_SLOT_LEGACY_BASE_COUNT))
    city_boost_item_slots.clear()
    if data.has("city_boost_item_slots"):
        for entry in data.get("city_boost_item_slots", []):
            city_boost_item_slots.append(str(entry))
        normalize_city_boost_item_slots()
    else:
        migrate_legacy_city_boost_item_slots()
    city_boost_growth_months = data.get("city_boost_growth_months", {}).duplicate(true)
    applied_carried_city_effects = data.get("applied_carried_city_effects", {}).duplicate()
    personal_boost_item_slots.clear()
    for entry in data.get("personal_boost_item_slots", []):
        personal_boost_item_slots.append(str(entry))
    applied_carried_personal_effects = data.get("applied_carried_personal_effects", {}).duplicate()
    personal_boost_slots_migrated = bool(data.get("personal_boost_slots_migrated", false))
    if not is_governance_mode():
        personal_boost_item_slots.clear()
        applied_carried_personal_effects.clear()
        personal_boost_slots_migrated = true
    elif personal_boost_slots_migrated:
        normalize_personal_boost_item_slots()
        apply_carried_item_personal_effects(false)
    else:
        _migrate_legacy_personal_item_effects()
    guozuo_entries.clear()
    for entry in data.get("guozuo_entries", []):
        var guozuo_id: = str(entry).strip_edges()
        if guozuo_id != "" and guozuo_id not in guozuo_entries:
            guozuo_entries.append(guozuo_id)
    upgraded_governance_cards.clear()
    for entry in data.get("upgraded_governance_cards", []):
        var upgraded_id: = str(entry).strip_edges()
        if upgraded_id != "" and upgraded_id not in upgraded_governance_cards:
            upgraded_governance_cards.append(upgraded_id)
    life_chronicle_entries = data.get("life_chronicle_entries", []).duplicate(true)
    var t = data.get("tags", [])
    tags = []
    for tag in t:
        var normalized_tag: = EffectsServiceRef.normalize_tag_name(tag)
        if normalized_tag != "":
            tags.append(normalized_tag)
    term_tag_counts = data.get("term_tag_counts", {}).duplicate()
    term_court_total = int(data.get("term_court_total", 0))
    term_court_just = int(data.get("term_court_just", 0))
    term_court_seen_ids = data.get("term_court_seen_ids", {}).duplicate()
    term_martial_chengfang = int(data.get("term_martial_chengfang", 0))
    term_martial_lingwu = int(data.get("term_martial_lingwu", 0))
    dezheng_plaque_evals = data.get("dezheng_plaque_evals", {}).duplicate()
    branch = data.get("branch", "")
    branch_index = data.get("branch_index", 0)
    if str(branch) != "" and branch_index < 0:
        branch_index = 0
    wartime_index = data.get("wartime_index", 0)
    last_branch_choice = data.get("last_branch_choice", "")
    bianwu_units = (data.get("bianwu_units", []) as Array).duplicate()
    bianwu_unit_group_defs = (data.get("bianwu_unit_group_defs", {}) as Dictionary).duplicate(true)
    bianwu_skills = (data.get("bianwu_skills", []) as Array).duplicate()
    bianwu_defense_act = int(data.get("bianwu_defense_act", 0))
    bianwu_defense_regions = (data.get("bianwu_defense_regions", []) as Array).duplicate(true)
    bianwu_defense_roads = (data.get("bianwu_defense_roads", []) as Array).duplicate(true)
    bianwu_defense_enemies = (data.get("bianwu_defense_enemies", []) as Array).duplicate(true)
    bianwu_defense_officers = (data.get("bianwu_defense_officers", []) as Array).duplicate(true)
    bianwu_command_points = int(data.get("bianwu_command_points", 0))
    bianwu_command_cap = int(data.get("bianwu_command_cap", 2))
    bianwu_defense_last_report = (data.get("bianwu_defense_last_report", {}) as Dictionary).duplicate(true)
    bianwu_defense_warnings = (data.get("bianwu_defense_warnings", []) as Array).duplicate(true)
    in_prison = data.get("in_prison", false)
    prison_index = data.get("prison_index", 0)
    emperor_dead = data.get("emperor_dead", false)
    last_fanshi_turn = data.get("last_fanshi_turn", -99)
    last_riot_turn = data.get("last_riot_turn", -99)
    keju_status = data.get("keju_status", "none")
    keju_year = data.get("keju_year", 0)
    keju_year_str = data.get("keju_year_str", "")
    keju_continue_mode = data.get("keju_continue_mode", false)
    keju_start_act = data.get("keju_start_act", 1)
    force_dice_win = data.get("force_dice_win", false)
    keju_fail_counts = data.get("keju_fail_counts", {}).duplicate(true)
    keju_next_exam_age = data.get("keju_next_exam_age", {}).duplicate(true)
    selected_timeline = data.get("selected_timeline", "wanli")
    play_mode = data.get("play_mode", "story")
    difficulty = data.get("difficulty", "normal")
    EventServiceRef.sanitize_cached_month_cards(self)
    pending_events = data.get("pending_events", []).duplicate(true)
    active_pending_event = data.get("active_pending_event", {}).duplicate(true)
    transitioning_to_governance = data.get("transitioning_to_governance", false)
    BianwuDefenseServiceRef.ensure_initialized(self)
    showing_result = false
    last_choice_index = -1
    _last_choice = null

    if not data.has("applied_carried_city_effects"):
        var act: = EventServiceRef._get_current_act(self)


        if act == 1 and ( not city.has("name") or city.get("name") == ""):
            if str(active_line) in ["", "hanmen"]:
                city["name"] = "蓬莱县"
                city["province"] = "山东"
                city["juris"] = "县"
            else:
                var act1_cfg: Dictionary = GameData.CITY_BY_ACT.get("1", {})
                city["name"] = str(act1_cfg.get("name", ""))
                city["province"] = str(act1_cfg.get("province", ""))
                city["juris"] = str(act1_cfg.get("juris", ""))

        if act == 1 and str(active_line) in ["", "hanmen"]:


            if int(city.get("nongsang", 0)) >= 30:
                city["nongsang"] = 12
                applied_carried_city_effects["nongsang"] = 2


            if int(city.get("renkou_val", 0)) == 0:
                city["renkou_val"] = 30000
            if int(city.get("liumin", 0)) == 0:
                city["liumin"] = 500

    repair_governance_city_for_current_act()
    update_monthly_breakdowns()
    state_changed.emit()

func get_city_stat_level(stat_key: String) -> int:
    var raw_value: int = int(city.get(stat_key, 0))
    return clampi(raw_value, 1, CITY_STAT_MAX_LEVEL)

func _city_stat_grain_output(level: int) -> int:
    var clamped_level: = clampi(level, 1, CITY_STAT_MAX_LEVEL)
    return CITY_STAT_GRAIN_OUTPUTS[clamped_level - 1]

func _city_stat_silver_output(level: int, kind: String) -> int:
    var clamped_level: = clampi(level, 1, CITY_STAT_MAX_LEVEL)
    var output: = 80 if kind == "shangmao" else 40
    for current_level in range(2, clamped_level + 1):
        if kind == "shangmao":
            if current_level <= 5:
                output += 40
            elif current_level <= 10:
                output += 60
            elif current_level <= 15:
                output += 90
            elif current_level <= 30:
                output += 130
            else:
                output += 180
        else:
            if current_level <= 5:
                output += 30
            elif current_level <= 10:
                output += 45
            elif current_level <= 15:
                output += 65
            elif current_level <= 30:
                output += 90
            else:
                output += 120
    return output

func _wenjiao_silver_output(level: int) -> int:


    var clamped: = clampi(level, 1, CITY_STAT_MAX_LEVEL)
    if clamped <= 2:
        return 0
    var output: = 0
    for lv in range(3, clamped + 1):
        if lv <= 5:
            output += 15
        elif lv <= 8:
            output += 30
        elif lv <= 12:
            output += 45
        elif lv <= 16:
            output += 60
        elif lv <= 30:
            output += 80
        else:
            output += 110
    return int(output * 0.8)

func _baigong_grain_output(level: int) -> int:


    var clamped: = clampi(level, 1, CITY_STAT_MAX_LEVEL)
    if clamped <= 2:
        return 0
    var output: = 0
    for lv in range(3, clamped + 1):
        if lv <= 5:
            output += 50
        elif lv <= 8:
            output += 100
        elif lv <= 12:
            output += 150
        elif lv <= 16:
            output += 225
        elif lv <= 30:
            output += 300
        else:
            output += 400
    return output

func update_monthly_breakdowns() -> void :
    MonthlySettlementServiceRef.update_monthly_breakdowns(self)

func _append_sanxiang_breakdown() -> void :
    var liao: = 0
    if year >= 1:
        liao += 150
    if year >= 4:
        liao += 200
    if liao > 0:
        monthly_silver_breakdown.append({"label": "辽饷", "value": - liao})
    if year >= 10 and year <= 13:
        monthly_silver_breakdown.append({"label": "剿饷", "value": -250})
    if year >= 11:
        monthly_silver_breakdown.append({"label": "练饷", "value": -300})

func _process_special_items_monthly() -> Dictionary:
    var result = {
        "grain_breakdowns": [], 
        "silver_breakdowns": [], 
        "actual_effects": {
            "private_silver": 0, 
            "bingyong": 0, 
            "liumin": 0, 
            "renkou_val": 0
        }
    }



    if is_item_slotted("gaoji_banyin"):
        var income = get_gaoji_banyin_income()
        var gwl_label = "高万利·" + income["label"]
        result["grain_breakdowns"].append({"label": gwl_label, "value": income["grain"]})
        result["silver_breakdowns"].append({"label": gwl_label, "value": income["silver"]})
        result["actual_effects"]["private_silver"] += income["private"]


    for slot_id in city_boost_item_slots:
        var item_id: = str(slot_id)
        if item_id == "" or item_id == "gaoji_banyin":
            continue
        var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
        var status: Dictionary = item_def.get("statusEffects", {})
        if status.is_empty():
            continue
        var item_name: = str(item_def.get("name", item_id))
        for raw_key in status:
            var key: = str(raw_key)
            var amt: = int(status[raw_key])
            if amt == 0:
                continue
            match key:
                "liangshi":
                    result["grain_breakdowns"].append({"label": item_name, "value": amt})
                "yinliang":
                    result["silver_breakdowns"].append({"label": item_name, "value": amt})
                "bingyong":
                    result["actual_effects"]["bingyong"] += amt
                "private_silver":
                    result["actual_effects"]["private_silver"] += amt
                "liumin":
                    result["actual_effects"]["liumin"] += amt
                "renkou_val":
                    result["actual_effects"]["renkou_val"] += amt

    return result

func get_gaoji_banyin_income() -> Dictionary:
    return GameStateQueryServiceRef.gaoji_banyin_income(self)


func process_monthly_production() -> void :
    MonthlySettlementServiceRef.process_monthly_production(self)




func apply_bianwu_monthly_attitude_tick() -> void :
    if GameData.active_line != "bianwu" or city.is_empty():
        return
    if not attitudes.has("junxin"):
        return


    var bw_guanjun: = int(city.get("guanjun", 0))
    var bw_liangcao: = int(city.get("liangcao", 0))
    var shortage_tier: = 0
    if bw_guanjun > 0:
        if bw_liangcao <= 0:
            shortage_tier = 3
        elif bw_liangcao < bw_guanjun:
            shortage_tier = 2
    var starving: = shortage_tier >= 2
    var pay_arrears: = int(city.get("xiangyin", 0)) <= 0
    var junxin: = int(attitudes.get("junxin", 60))
    if starving or pay_arrears:
        var months: = int(city.get("arrears_months", 0)) + 1
        city["arrears_months"] = months
        var drop: = 3
        if starving:
            drop += shortage_tier
        if months >= 3:
            drop += 3
        junxin = maxi(0, junxin - drop)
    else:
        city["arrears_months"] = 0
        junxin = mini(100, junxin + 1)
    attitudes["junxin"] = junxin

    var jianjun: = int(attitudes.get("jianjun", 40))
    var shengjuan: = int(attitudes.get("shengjuan", 50))
    if jianjun < 25:
        attitudes["shengjuan"] = maxi(0, shengjuan - 2)
    elif jianjun < 40:
        attitudes["shengjuan"] = maxi(0, shengjuan - 1)
    elif jianjun >= 70:
        attitudes["shengjuan"] = mini(100, shengjuan + 1)

func _should_trigger_soldier_mutiny() -> bool:


    return randf() < mutiny_trigger_chance()

func mutiny_trigger_chance() -> float:
    return float(GameData.characters.get(char_id, {}).get("mutiny_trigger_chance", 1.0))

func get_monthly_wenjiao_refugee_settlement(liumin_override: int = -1) -> int:

    var liumin_val: int = liumin_override
    if liumin_val < 0:
        liumin_val = int(city.get("liumin", 0))
    var wenjiao_lv: int = get_city_stat_level("wenjiao")
    if wenjiao_lv < 3 or liumin_val <= 0:
        return 0
    var settled: int = int(liumin_val * wenjiao_lv * 0.003)
    settled = maxi(settled, 1)
    return mini(settled, liumin_val)

func get_liumin_yearly_pressure_multiplier() -> float:

    var effective_year: = get_czYear()
    if is_governance_mode() and month > 12:
        effective_year += 1
    var cz_year: = clampi(effective_year, LIUMIN_YEARLY_PRESSURE_START_YEAR, LIUMIN_YEARLY_PRESSURE_END_YEAR)
    var progress: = float(cz_year - LIUMIN_YEARLY_PRESSURE_START_YEAR) / float(LIUMIN_YEARLY_PRESSURE_END_YEAR - LIUMIN_YEARLY_PRESSURE_START_YEAR)
    return lerpf(LIUMIN_YEARLY_PRESSURE_START_MULTIPLIER, LIUMIN_YEARLY_PRESSURE_END_MULTIPLIER, progress)

func get_monthly_liumin_natural_inflow() -> int:
    if city.is_empty():
        return 0
    return maxi(0, int(round(float(LIUMIN_MONTHLY_BASE_INFLOW) * get_liumin_yearly_pressure_multiplier())))

func get_grain_shortage_tier() -> Dictionary:


    if city.is_empty():
        return {"tier": 0, "label": "充足", "deficit": 0, "safety_line": 0}
    var stock: int = int(city.get("liangshi", 0))
    var net: int = get_monthly_grain_net_change()
    var bingyong_cost: int = int(city.get("bingyong", 0))
    var safety_line: int = int(round(float(bingyong_cost) * GRAIN_SAFETY_MONTHS))
    var deficit: int = maxi(0, - net)
    var tier: int = 0
    if net >= 0 or stock >= safety_line:
        tier = 0
    elif stock > 0:
        tier = 1
    elif deficit <= bingyong_cost:
        tier = 2
    else:
        tier = 3
    var labels: = ["充足", "告急", "缺粮", "绝粮"]
    return {"tier": tier, "label": labels[tier], "deficit": deficit, "safety_line": safety_line}

func get_grain_shortage_report(renkou_override: int = -1, liumin_override: int = -1) -> Dictionary:


    var rk: int = renkou_override if renkou_override >= 0 else int(city.get("renkou_val", 0))
    var lm: int = liumin_override if liumin_override >= 0 else int(city.get("liumin", 0))
    var info: Dictionary = get_grain_shortage_tier()
    var tier: int = int(info["tier"])
    var result: = {
        "tier": tier, "label": info["label"], 
        "to_refugee": 0, "pop_death": 0, "ref_death": 0, "minwang_drop": 0
    }
    if tier <= 0 or rk <= 0:
        return result

    var to_refugee: = int(float(rk) * float(GRAIN_TIER_REFUGEE_RATE[tier]))
    if tier >= 2:
        to_refugee += int(float(int(info["deficit"])) * LIUMIN_GRAIN_SHORTAGE_DEFICIT_RATE)
        to_refugee = clampi(to_refugee, LIUMIN_GRAIN_SHORTAGE_MIN_GROWTH, LIUMIN_GRAIN_SHORTAGE_MAX_GROWTH)
    else:

        to_refugee = mini(to_refugee, LIUMIN_GRAIN_SHORTAGE_MAX_GROWTH)
    to_refugee = mini(to_refugee, rk)
    result["to_refugee"] = to_refugee

    if tier >= 2:
        var remain_pop: = rk - to_refugee
        result["pop_death"] = int(float(remain_pop) * float(GRAIN_TIER_POP_DEATH_RATE[tier]))
        result["ref_death"] = int(float(lm) * float(GRAIN_TIER_REF_DEATH_RATE[tier]))
    result["minwang_drop"] = int(GRAIN_TIER_MINWANG_DROP[tier])
    return result

func get_monthly_liumin_net_change(liumin_override: int = -1) -> Dictionary:

    var liumin_val: int = liumin_override
    if liumin_val < 0:
        liumin_val = int(city.get("liumin", 0))
    var base_growth: int = get_monthly_liumin_natural_inflow()
    var renkou_val: int = int(city.get("renkou_val", 0))
    var shortage: Dictionary = get_grain_shortage_report(renkou_val, liumin_val)
    var grain_shortage_growth: int = int(shortage["to_refugee"])
    var ref_death: int = int(shortage["ref_death"])
    var settled: int = get_monthly_wenjiao_refugee_settlement(liumin_val)
    var item_change: int = int(_process_special_items_monthly()["actual_effects"].get("liumin", 0))
    var before_capstone: = maxi(0, liumin_val + base_growth + grain_shortage_growth - settled - ref_death + item_change)
    var wulue_capstone_reduction: = PersonalStatCapstoneServiceRef.wulue_liumin_reduction(self, before_capstone)
    return {
        "base_growth": base_growth, 
        "grain_shortage_growth": grain_shortage_growth, 
        "ref_death": ref_death, 
        "pop_death": int(shortage["pop_death"]), 
        "tier": int(shortage["tier"]), 
        "tier_label": shortage["label"], 
        "incoming_growth": base_growth + grain_shortage_growth, 
        "settled": settled, 
        "item_change": item_change, 
        "wulue_capstone_reduction": wulue_capstone_reduction, 
        "net_change": base_growth + grain_shortage_growth - settled - ref_death + item_change - wulue_capstone_reduction
    }

func get_monthly_renkou_net_change() -> Dictionary:

    if city.is_empty():
        return {
            "natural_growth": 0, "settled": 0, "to_refugee": 0, 
            "pop_death": 0, "tier": 0, "tier_label": "充足", "net_change": 0
        }
    var renkou_val: int = int(city.get("renkou_val", 0))
    var liumin_val: int = int(city.get("liumin", 0))
    var natural_growth: int = int(float(renkou_val) * RENKOU_MONTHLY_NATURAL_GROWTH_RATE)
    var settled: int = get_monthly_wenjiao_refugee_settlement(liumin_val)
    var shortage: Dictionary = get_grain_shortage_report(renkou_val, liumin_val)
    var to_refugee: int = int(shortage["to_refugee"])
    var pop_death: int = int(shortage["pop_death"])
    var item_change: int = int(_process_special_items_monthly()["actual_effects"].get("renkou_val", 0))
    return {
        "natural_growth": natural_growth, 
        "settled": settled, 
        "to_refugee": to_refugee, 
        "pop_death": pop_death, 
        "tier": int(shortage["tier"]), 
        "tier_label": shortage["label"], 
        "item_change": item_change, 
        "net_change": natural_growth + settled - to_refugee - pop_death + item_change
    }

func get_monthly_grain_net_change() -> int:

    if city.is_empty():
        return 0
    if monthly_grain_breakdown.is_empty():
        update_monthly_breakdowns()
    var net_grain: = 0
    for item in monthly_grain_breakdown:
        net_grain += int(item.get("value", 0))
    return net_grain

func get_riot_info() -> Dictionary:
    return GameStateQueryServiceRef.riot_info(self)

func check_riot() -> int:

    var info: Dictionary = get_riot_info()
    if info["level"] == 0 or info["cooldown"]:
        return 0
    var roll: float = randf()
    if roll < info["probability"]:
        last_riot_turn = turn
        return info["level"]
    return 0

func get_mutiny_info() -> Dictionary:
    return GameStateQueryServiceRef.mutiny_info(self)

func mark_military_discipline_case_settled() -> void :
    last_military_discipline_case_month_index = int(year) * 12 + int(month)

func is_military_discipline_case_on_cooldown(cooldown_months: int = 6) -> bool:
    var current_month_index: = int(year) * 12 + int(month)
    return current_month_index - last_military_discipline_case_month_index < maxi(1, cooldown_months)

func add_mutiny_risk_modifier(modifier: Dictionary) -> void :
    if str(active_line) not in ["", "hanmen"]:
        return
    var modifier_id: = str(modifier.get("id", "")).strip_edges()
    var points: = clampi(int(modifier.get("points", 0)), -30, 30)
    var duration_months: = maxi(1, int(modifier.get("durationMonths", 1)))
    if modifier_id == "" or points == 0:
        return
    var current_month_index: = int(year) * 12 + int(month)
    var normalized: = {
        "id": modifier_id, 
        "label": str(modifier.get("label", "军中余波")), 
        "points": points, 
        "start_month_index": current_month_index + 1, 
        "expires_month_index": current_month_index + duration_months, 
    }
    for idx in range(mutiny_risk_modifiers.size()):
        if str(mutiny_risk_modifiers[idx].get("id", "")) == modifier_id:
            mutiny_risk_modifiers[idx] = normalized
            state_changed.emit()
            return
    mutiny_risk_modifiers.append(normalized)
    state_changed.emit()

func get_active_mutiny_risk_modifiers() -> Array:
    var current_month_index: = int(year) * 12 + int(month)
    var active: Array = []
    var retained: Array = []
    for raw_modifier in mutiny_risk_modifiers:
        if not (raw_modifier is Dictionary):
            continue
        var modifier: Dictionary = raw_modifier
        if int(modifier.get("expires_month_index", -1)) < current_month_index:
            continue
        retained.append(modifier)
        if current_month_index >= int(modifier.get("start_month_index", current_month_index)):
            var displayed: = modifier.duplicate(true)
            displayed["remaining_months"] = int(modifier.get("expires_month_index", current_month_index)) - current_month_index + 1
            active.append(displayed)
    mutiny_risk_modifiers = retained
    return active

func mutiny_risk_modifier_points() -> int:
    var total: = 0
    for modifier in get_active_mutiny_risk_modifiers():
        total += int(modifier.get("points", 0))
    return clampi(total, -30, 30)

func check_mutiny() -> int:

    if city.is_empty():
        return 0

    var info: = get_mutiny_info()
    if info["level"] == 0:
        return 0


    var last_mut_turn: int = int(city.get("last_mutiny_turn", -99))
    if (turn - last_mut_turn) < 3:
        return 0
    if (turn - last_riot_turn) < 2:
        return 0

    var roll: float = randf()
    if roll < info["probability"]:
        city["last_mutiny_turn"] = turn
        var current_count = int(city.get("mutiny_count", 0))
        city["mutiny_count"] = current_count + 1

        var raw_level: = 1
        var loss = info["deficit_loss"]
        if loss >= 400:
            raw_level = 3
        elif loss >= 150:
            raw_level = 2
        else:
            raw_level = 1

        return mini(raw_level, current_count + 1)
    return 0
