extends Control

const BiographyServiceRef = preload("res://scripts/services/biography_service.gd")
const RouteRegistryRef = preload("res://scripts/route_registry.gd")

@onready var content_root: Control = $ContentRoot
@onready var title_screen = $ContentRoot / TitleScreen
@onready var timeline_screen = $ContentRoot / TimelineScreen
@onready var mode_select_screen = $ContentRoot / ModeSelectScreen
@onready var origin_roll_screen = $ContentRoot / OriginRollScreen
@onready var select_screen = $ContentRoot / SelectScreen
@onready var game_screen = $ContentRoot / GameScreen
@onready var ending_screen = $ContentRoot / EndingScreen
@onready var dossier_screen = $ContentRoot / DossierScreen
@onready var save_modal = $ContentRoot / SaveModal
@onready var rank_tree_modal = $ContentRoot / RankTreeModal
@onready var battle_screen = $ContentRoot / BattleScreen

var current_screen: String = "title"
var _battle_done_cb: Callable = Callable()
var _screen_before_battle: String = "game"
var _web_font_fallbacks_ready: = false
var _native_font_fallbacks_ready: = false
var _last_content_root_fit_size: = Vector2.ZERO
var _last_content_root_window_size: = Vector2.ZERO
var _content_root_fit_sync_elapsed: = 0.0

func _enter_tree() -> void :
    _setup_web_font_fallbacks()

func _ready() -> void :
    _setup_web_font_fallbacks()
    _prepare_content_root()
    _fit_content_root()
    resized.connect(_fit_content_root)
    show_screen("title")
    title_screen.start_game.connect(_on_start_game)
    title_screen.load_game.connect(_on_title_load)
    title_screen.dossier_requested.connect(_on_title_dossier)
    mode_select_screen.mode_selected.connect(_on_mode_selected)
    mode_select_screen.back_requested.connect( func(): show_screen("title"))
    origin_roll_screen.origin_rolled.connect(_on_origin_rolled)
    origin_roll_screen.back_requested.connect( func(): show_screen("mode_select"))
    timeline_screen.timeline_selected.connect(_on_timeline_selected)
    timeline_screen.back_requested.connect( func(): show_screen("select"))
    select_screen.character_selected.connect(_on_character_selected)
    select_screen.back_requested.connect( func(): show_screen("title"))
    game_screen.game_ended.connect(_on_game_ended)
    game_screen.show_rank_tree_requested.connect(_on_show_rank_tree_requested)
    game_screen.restart_requested.connect(_on_play_again)
    ending_screen.play_again.connect(_on_play_again)
    ending_screen.back_to_choices.connect(_on_back_to_choices)
    ending_screen.biography_requested.connect(_on_biography_requested)
    dossier_screen.back_requested.connect( func(): show_screen("title"))
    battle_screen.battle_finished.connect(_on_battle_finished)

func _setup_web_font_fallbacks() -> void :
    if not OS.has_feature("web"):
        if _native_font_fallbacks_ready:
            return
        _native_font_fallbacks_ready = true


        print("ℹ️ 正在为原生平台（Android/PC）配置高清完整字库接管机制...")
        var full_regular_path: = "res://assets/fonts/NotoSerifSC-Regular.otf"
        var full_bold_path: = "res://assets/fonts/NotoSerifSC-Bold.otf"
        var full_title_path: = "res://assets/fonts/alimama-dongfang.ttf"


        var system_serif_fallback = SystemFont.new()
        system_serif_fallback.font_names = PackedStringArray([
            "Songti SC", 
            "SimSun", 
            "STSong", 
            "serif", 
            "PingFang SC", 
            "Microsoft YaHei", 
            "sans-serif"
        ])




        if ResourceLoader.exists(full_regular_path):
            var full_font = load(full_regular_path) as FontFile
            if full_font:
                full_font.fallbacks = [system_serif_fallback]
                full_font.take_over_path("res://assets/fonts/NotoSerifSC-Regular_web.otf")
                print("   ✅ 已成功接管 NotoSerifSC-Regular_web.otf -> 完整常规宋体（带系统宋体保底）")

        if ResourceLoader.exists(full_bold_path):
            var full_font = load(full_bold_path) as FontFile
            if full_font:
                full_font.fallbacks = [system_serif_fallback]
                full_font.take_over_path("res://assets/fonts/NotoSerifSC-Bold_web.otf")
                print("   ✅ 已成功接管 NotoSerifSC-Bold_web.otf -> 完整粗宋体（带系统宋体保底）")

        if ResourceLoader.exists(full_title_path):
            var full_font = load(full_title_path) as Font
            if full_font:
                full_font.take_over_path("res://assets/fonts/alimama-dongfang_web.ttf")
                print("   ✅ 已成功接管 alimama-dongfang_web.ttf -> 完整版")


        var wenkai_path: = "res://assets/fonts/LXGWWenKai-Regular.ttf"
        var theme_res = load("res://themes/game_theme.tres") as Theme
        if theme_res:
            if ResourceLoader.exists(wenkai_path):
                var body_font = load(wenkai_path) as FontFile
                if body_font:
                    body_font.fallbacks = [system_serif_fallback]
                theme_res.default_font = body_font
            elif ResourceLoader.exists(full_regular_path):
                theme_res.default_font = load(full_regular_path) as Font
            else:
                theme_res.default_font = system_serif_fallback
            print("   ✅ 原生平台 Theme 默认字体已显式配置（霞鹜文楷）")
        return
    if _web_font_fallbacks_ready:
        return
    _web_font_fallbacks_ready = true

    print("⏳ 正在为 Web 端配置专属轻量字体与系统字体保底 (Font Fallback) 容灾机制...")


    var regular_web_path: = "res://assets/fonts/NotoSerifSC-Regular_web.otf"
    var bold_web_path: = "res://assets/fonts/NotoSerifSC-Bold_web.otf"
    var title_web_path: = "res://assets/fonts/alimama-dongfang_web.ttf"


    var system_sans_fallback = SystemFont.new()
    system_sans_fallback.font_names = PackedStringArray([
        "PingFang SC", 
        "Microsoft YaHei", 
        "Noto Sans CJK SC", 
        "sans-serif"
    ])


    var system_serif_fallback = SystemFont.new()
    system_serif_fallback.font_names = PackedStringArray([
        "Songti SC", 
        "SimSun", 
        "STSong", 
        "serif", 
        "PingFang SC", 
        "Microsoft YaHei", 
        "sans-serif"
    ])



    system_serif_fallback.take_over_path("res://assets/fonts/NotoSerifSC-Regular.otf")
    system_serif_fallback.take_over_path("res://assets/fonts/NotoSerifSC-Bold.otf")
    system_sans_fallback.take_over_path("res://assets/fonts/alimama-dongfang.ttf")

    var theme_res = load("res://themes/game_theme.tres") as Theme
    if theme_res:

        theme_res.default_font = system_serif_fallback



    if ResourceLoader.exists(regular_web_path):
        var reg_font = load(regular_web_path) as FontFile
        if reg_font:
            reg_font.fallbacks = [system_serif_fallback]
            reg_font.take_over_path("res://assets/fonts/NotoSerifSC-Regular.otf")
            if theme_res:
                theme_res.default_font = reg_font
            print("   ✅ Web Regular 字体 + 系统宋体保底已注入并接管原路径")

    if ResourceLoader.exists(bold_web_path):
        var bold_font = load(bold_web_path) as FontFile
        if bold_font:
            bold_font.fallbacks = [system_serif_fallback]

            bold_font.take_over_path("res://assets/fonts/NotoSerifSC-Bold.otf")
            print("   ✅ Web Bold 字体 + 系统宋体保底已注入并接管原路径")

    if ResourceLoader.exists(title_web_path):
        var title_font = load(title_web_path) as FontFile
        if title_font:
            title_font.fallbacks = [system_sans_fallback]

            title_font.take_over_path("res://assets/fonts/alimama-dongfang.ttf")
            print("   ✅ Web Title 字体 + 系统保底已注入并接管原路径")

func _prepare_content_root() -> void :
    content_root.set_anchors_preset(Control.PRESET_TOP_LEFT)
    for child in content_root.get_children():
        if child is Control:
            child.set_anchors_preset(Control.PRESET_FULL_RECT)
            child.offset_left = 0.0
            child.offset_top = 0.0
            child.offset_right = 0.0
            child.offset_bottom = 0.0

func _get_content_root_fit_size() -> Vector2:
    var viewport_size: = get_viewport_rect().size
    var window_size: = Vector2(DisplayServer.window_get_size())
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
        return window_size
    return viewport_size

func _fit_content_root() -> void :
    var fit_size: = _get_content_root_fit_size()
    if fit_size.x <= 0.0 or fit_size.y <= 0.0:
        return
    _last_content_root_fit_size = fit_size
    _last_content_root_window_size = Vector2(DisplayServer.window_get_size())
    content_root.size = fit_size
    content_root.position = Vector2.ZERO
    for child in content_root.get_children():
        if child is Control:
            child.size = content_root.size

func _process(_delta: float) -> void :
    _content_root_fit_sync_elapsed += _delta
    if _content_root_fit_sync_elapsed < 0.08:
        return
    _content_root_fit_sync_elapsed = 0.0
    var fit_size: = _get_content_root_fit_size()
    if fit_size.x <= 0.0 or fit_size.y <= 0.0:
        return
    if _last_content_root_fit_size == Vector2.ZERO:
        _last_content_root_fit_size = fit_size
        _last_content_root_window_size = Vector2(DisplayServer.window_get_size())
        return
    var window_size: = Vector2(DisplayServer.window_get_size())
    var viewport_changed: = absf(fit_size.x - _last_content_root_fit_size.x) >= 1.0 or absf(fit_size.y - _last_content_root_fit_size.y) >= 1.0
    var window_changed: = absf(window_size.x - _last_content_root_window_size.x) >= 1.0 or absf(window_size.y - _last_content_root_window_size.y) >= 1.0
    if viewport_changed or window_changed:
        _fit_content_root()

func show_screen(screen_id: String) -> void :
    current_screen = screen_id
    title_screen.visible = (screen_id == "title")
    mode_select_screen.visible = (screen_id == "mode_select")
    origin_roll_screen.visible = (screen_id == "origin_roll")
    timeline_screen.visible = (screen_id == "timeline")
    select_screen.visible = (screen_id == "select")
    game_screen.visible = (screen_id == "game")
    ending_screen.visible = (screen_id == "ending")
    dossier_screen.visible = (screen_id == "dossier")

func _is_privacy_gate_active() -> bool:
    return title_screen.is_privacy_gate_active()

func _on_start_game() -> void :
    if _is_privacy_gate_active():
        return
    show_screen("mode_select")

func _on_mode_selected(mode_id: String) -> void :
    if RouteRegistryRef.STORY_ROUTES.has(mode_id):
        _start_story_route(mode_id)
        return
    if mode_id == "free":

        show_screen("origin_roll")
        return
    show_screen("select")


func _on_origin_rolled(char_id: String, traits: Array) -> void :
    GameData.activate_line("hanmen")
    GameState.active_line = "hanmen"
    GameState.selected_timeline = "wanli"
    GameState.play_mode = "free"
    GameState.init_character(char_id, traits)
    GameState.active_line = "hanmen"
    show_screen("game")
    game_screen.start_game()




func _start_story_route(route_id: String) -> void :
    var cfg: Dictionary = RouteRegistryRef.STORY_ROUTES[route_id]
    var line: String = str(cfg["line"])
    GameState.selected_timeline = str(cfg.get("timeline", "chongzhen"))
    GameState.play_mode = "story"
    GameData.activate_line(line)
    GameState.init_character(str(cfg["char_id"]), [])

    GameState.active_line = line
    GameState.pending_events.clear()
    GameState.active_pending_event = {}
    GameState.keju_status = str(cfg.get("keju_status", "none"))
    GameState.branch = ""
    GameState.branch_index = 0
    if str(cfg.get("intro_branch", "")) != "":


        GameState.enter_branch(str(cfg["intro_branch"]), int(cfg.get("intro_branch_index", 1)))
        GameState.transitioning_to_governance = false
        GameState.current_event = 0
        GameState.emit_state_changed()
        show_screen("game")
        game_screen.start_game()
        return
    var start_act: = 1
    var start_year: = 1
    if str(cfg.get("start_kind", "fixed")) == "entry":

        var entry: = GameState.get_initial_governance_entry()
        start_act = int(entry.get("city_act", 1))
        start_year = int(entry.get("start_year", 1))
    else:
        start_act = int(cfg.get("city_act", 1))
        start_year = int(cfg.get("year", 1))
    GameState.initialize_governance_city(start_act)
    GameState.year = start_year
    GameState.month = int(cfg.get("month", 9))
    GameState.transitioning_to_governance = false
    GameState.action_points = GameState.monthly_action_points()
    GameState.current_event = 0
    GameState.emit_state_changed()
    show_screen("game")
    game_screen.start_game()

func _on_timeline_selected(timeline: String) -> void :
    GameState.selected_timeline = timeline
    GameState.init_character(temp_selected_char_id, temp_selected_traits)
    show_screen("game")
    game_screen.start_game()

func _on_title_load() -> void :
    if _is_privacy_gate_active():
        return

    save_modal.open_load_mode(true)

func _on_title_dossier() -> void :
    if _is_privacy_gate_active():
        return
    dossier_screen.refresh()
    show_screen("dossier")

var temp_selected_char_id: String = ""
var temp_selected_traits: Array = []

func _on_character_selected(char_id: String, selected_traits: Array = []) -> void :
    temp_selected_char_id = char_id
    temp_selected_traits = selected_traits
    GameData.activate_line("hanmen")
    GameState.active_line = "hanmen"
    GameState.selected_timeline = "wanli"
    GameState.play_mode = "free"
    GameState.init_character(temp_selected_char_id, temp_selected_traits)
    GameState.active_line = "hanmen"
    show_screen("game")
    game_screen.start_game()

func _on_game_ended(ending: Dictionary) -> void :
    SaveManager.record_ending(ending)

    if GameState.play_mode == "free":
        SaveManager.add_rebirth_point()
    show_screen("ending")
    ending_screen.show_ending(ending)
    if is_instance_valid(GameState):
        GameState.play_bgm(GameState.get_ending_bgm_path(ending), 2.0)

func _on_play_again() -> void :
    GameState.reset()
    show_screen("title")
    if is_instance_valid(GameState):
        GameState.start_title_playlist(2.0)

func resume_from_load() -> void :


    var line: = RouteRegistryRef.line_of_save_fields(GameState.active_line, GameState.char_id)
    GameData.activate_line(line)
    GameState.active_line = line
    show_screen("game")
    game_screen.resume_from_load()



func _unhandled_key_input(event: InputEvent) -> void :
    if not OS.has_feature("editor"):
        return
    if event is InputEventKey and event.pressed and event.keycode == KEY_F9:
        request_battle({
            "title": "遵化城外·截击（调试样例）", 
            "terrain": "plain", 
            "front_slots": 2, 
            "objective": {"type": "annihilate"}, 
            "player_units": ["spear", "knife_shield", "bow", "musket"], 
            "enemy_units": ["cavalry", "bow", "knife_shield"], 
            "intel": 1, "ammo": 6, "horse": 2, 
        }, func(grade): print("[BATTLE DEBUG] grade = ", grade))



func request_battle(config: Dictionary, on_done: Callable = Callable()) -> void :
    _battle_done_cb = on_done
    _screen_before_battle = current_screen if current_screen != "" else "game"

    if not config.has("wulue"):
        config["wulue"] = int(GameState.stats.get("wulue", 50))
    show_screen("")
    battle_screen.start_battle(config)

func _on_battle_finished(grade: String) -> void :
    show_screen(_screen_before_battle)
    var cb: = _battle_done_cb
    _battle_done_cb = Callable()
    if cb.is_valid():
        cb.call(grade)

func _on_show_rank_tree_requested() -> void :
    rank_tree_modal.open_modal()

func _on_back_to_choices() -> void :
    show_screen("game")
    if game_screen.has_method("resume_from_back_to_choices"):
        game_screen.resume_from_back_to_choices()

func _on_biography_requested() -> void :
    var text: = BiographyServiceRef.build_biography_text(GameState, ending_screen.current_ending)
    ending_screen.show_biography(text)
