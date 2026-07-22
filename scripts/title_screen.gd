extends Control

const AdsConfigRef = preload("res://scripts/services/ads_config.gd")

signal start_game
signal load_game
signal dossier_requested

var INK: Color:
    get: return GameState.get_theme_color("text_main")
var INK_SOFT: Color:
    get: return GameState.get_theme_color("text_sub")
var INK_BODY: Color:
    get: return GameState.get_theme_color("text_desc")
var GOLD: Color:
    get: return GameState.get_theme_color("border_active")
var GOLD_LIGHT: Color:
    get: return GameState.get_theme_color("border_stronger")
var PAPER: Color:
    get: return GameState.get_theme_color("bg_panel_weak")
var PAPER_HOVER: Color:
    get: return GameState.get_theme_color("bg_panel")
const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const FontLoader = preload("res://scripts/ui/font_loader.gd")
const ScrollbarThemeRef = preload("res://scripts/ui/scrollbar_theme.gd")
const AboutGamePopupRef = preload("res://scripts/ui/about_game_popup.gd")
const AboutAdsPopupRef = preload("res://scripts/ui/about_ads_popup.gd")
const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")
const SettingsPopupStyle = preload("res://scripts/ui/settings_popup_style.gd")
const RED_SEAL: = Color(0.55, 0.12, 0.08, 0.88)
const TITLE_PARTICLES_ENABLED: = true
const MOBILE_PORTRAIT_MAX_WIDTH: = 900.0
const MOBILE_TITLE_FONT_SIZE: = 142
const MOBILE_SUBTITLE_FONT_SIZE: = 46
const MOBILE_BODY_FONT_SIZE: = 37
const MOBILE_PRIMARY_BUTTON_FONT_SIZE: = 50
const MOBILE_SECONDARY_BUTTON_FONT_SIZE: = 43
const MOBILE_TOP_BUTTON_FONT_SIZE: = 38
const MOBILE_META_FONT_SIZE: = 31
const MOBILE_PRIMARY_BUTTON_HEIGHT: = 104.0
const MOBILE_SECONDARY_BUTTON_HEIGHT: = 88.0
const MOBILE_TOP_BUTTON_HEIGHT: = 82.0
const MOBILE_CONTENT_STACK_HEIGHT: = 690.0
const MOBILE_CONTENT_CENTER_BIAS_Y: = -72.0
const NATIVE_MOBILE_LANDSCAPE_CONTENT_STACK_HEIGHT: = 690.0
const NATIVE_MOBILE_LANDSCAPE_VERSION_GAP: = 58.0
const MOBILE_MODAL_TITLE_FONT_SIZE: = 43
const MOBILE_GAME_MODAL_TITLE_FONT_SIZE: = 55
const MOBILE_MODAL_BUTTON_FONT_SIZE: = 36
const MOBILE_MODAL_BUTTON_HEIGHT: = 76.0
const LEFT_PANEL_MIN_WIDTH: = 392.0
const LEFT_PANEL_WIDTH_RATIO: = 0.25

const LEFT_PANEL_WIDE_ASPECT_BASE: = 1.78
const LEFT_PANEL_WIDE_ASPECT_MAX: = 2.4
const LEFT_PANEL_WIDTH_RATIO_WIDE: = 0.32
const LEFT_WIDTH_MAX_WIDE: = 760.0

const LOGO_TEX_ASPECT: = 1698.0 / 926.0
const LOGO_DECOR_LEFT_FRAC: = 0.232
const LOGO_DECOR_RIGHT_FRAC: = 0.803


const BG_NARROW_ASPECT_BASE: = 1.5
const BG_NARROW_ASPECT_MIN: = 0.95
const BG_NARROW_SHIFT_RATIO: = 0.08
const TITLE_CHARACTER_CENTER_X_FRAC: = 0.765
const TITLE_CHARACTER_BOTTOM_Y_FRAC: = 0.865
const TITLE_CHARACTER_HEIGHT_FRAC: = 0.37
const TITLE_CHARACTER_WIND_PADDING: = 0.0


@onready var background: TextureRect = $Background
@onready var title_character: TextureRect = $TitleCharacter
@onready var gradient_overlay: TextureRect = $GradientOverlay
@onready var left_panel: ColorRect = $LeftPanel
@onready var atmosphere_layer: Control = $AtmosphereLayer
@onready var center_frame: MarginContainer = $CenterFrame
@onready var menu: HBoxContainer = $TopRightMenu
@onready var version_label: Label = $VersionLabel
@onready var logo: TextureRect = $CenterFrame / VBoxContainer / Logo
@onready var tagline_margin: MarginContainer = $CenterFrame / VBoxContainer / TaglineMargin
@onready var tagline_label: Label = $CenterFrame / VBoxContainer / TaglineMargin / Tagline
@onready var start_button: Button = $CenterFrame / VBoxContainer / StartButton
@onready var load_button: Button = $CenterFrame / VBoxContainer / LoadButton
@onready var dossier_button: Button = $CenterFrame / VBoxContainer / DossierButton
@onready var exit_button: Button = $CenterFrame / VBoxContainer / ExitButton
@onready var settings_button: Button = $TopRightMenu / SettingsButton

var title_font: Font = FontLoader.title()
var serif_font: Font = FontLoader.serif_bold()
var body_font: Font = FontLoader.body()
var logo_dark: Texture2D = preload("res://assets/ui/czzp-logo-white.webp")
var logo_light: Texture2D = preload("res://assets/ui/czzp-logo.webp")
var start_button_bg: TextureRect
var start_grad: Gradient
var sparks: CPUParticles2D
var smoke: CPUParticles2D
var _privacy_gate_active: = false

func _setup_web_fonts() -> void :
    title_font = FontLoader.title()
    serif_font = FontLoader.serif_bold()
    body_font = FontLoader.body()

func _is_primary_press_event(event: InputEvent) -> bool:
    if event is InputEventScreenTouch:
        return event.pressed
    if event is InputEventMouseButton:
        return event.pressed
    return false

var _dbgc: = 0
func _process(_d):
    _dbgc += 1
    if _dbgc == 120:
        print("DBG STEADY settings size=", settings_button.size, " win=", DisplayServer.window_get_size(), " vp=", get_viewport().get_visible_rect().size, " xform_scale=", get_viewport().get_final_transform().get_scale())

func _ready() -> void :
    _setup_web_fonts()
    _refresh_version_label()
    start_button.pressed.connect( func(): start_game.emit())
    load_button.pressed.connect( func(): load_game.emit())
    dossier_button.pressed.connect( func(): dossier_requested.emit())
    exit_button.pressed.connect(_show_exit_confirm_popup)
    settings_button.pressed.connect(_show_settings_popup)
    settings_button.text = ""
    settings_button.icon = preload("res://assets/ui/settings_icon.svg")
    settings_button.expand_icon = true
    settings_button.custom_minimum_size = Vector2(26, 26)
    settings_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    settings_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER

    settings_button.mouse_entered.connect( func():
        settings_button.self_modulate = Color(0.85, 0.85, 0.85, 1.0)
    )
    settings_button.mouse_exited.connect( func():
        settings_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
    )
    settings_button.button_down.connect( func():
        settings_button.self_modulate = Color(0.7, 0.7, 0.7, 1.0)
    )
    settings_button.button_up.connect( func():
        if settings_button.is_hovered():
            settings_button.self_modulate = Color(0.85, 0.85, 0.85, 1.0)
        else:
            settings_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
    )
    if not GameState.theme_changed.is_connected(_on_theme_changed):
        GameState.theme_changed.connect(_on_theme_changed)
    load_button.visible = true
    load_button.disabled = not SaveManager.has_any_save()
    resized.connect(_apply_responsive_layout)

    if _requires_privacy_consent():
        _set_privacy_gate_active(true)

    _apply_typography()
    _apply_button_styles()
    if TITLE_PARTICLES_ENABLED:
        _add_particle_effects()
    _apply_responsive_layout()
    _apply_native_mobile_font_scale()


    if _privacy_gate_active:
        call_deferred("_show_privacy_consent_popup")


func _refresh_version_label() -> void :
    var project_version: = str(ProjectSettings.get_setting("application/config/version", "")).strip_edges()
    if project_version.is_empty():
        return
    version_label.text = "%s" % project_version


func _on_theme_changed(_theme: String) -> void :
    if not is_inside_tree(): return
    _apply_typography()
    _apply_button_styles()
    _apply_native_mobile_font_scale()

func _sync_native_landscape_size_override() -> void :
    NativeMobileFontScalerRef.set_landscape_size_mode_override(GameState.landscape_size_mode)

func _landscape_size_button_text() -> String:
    return "UI：大" if _is_effective_large_ui_mode() else "UI：普通"

func _is_effective_large_ui_mode() -> bool:
    if GameState.landscape_size_mode == "phone":
        return true
    if GameState.landscape_size_mode == "desktop":
        return false
    return _is_mobile_portrait() or NativeMobileFontScalerRef.is_native_phone_landscape(self)

func _requires_privacy_consent() -> bool:
    return OS.has_feature("android") and not GameState.is_privacy_agreed()

func is_privacy_gate_active() -> bool:
    return _privacy_gate_active

func _set_privacy_gate_active(active: bool) -> void :
    _privacy_gate_active = active
    start_button.disabled = active
    load_button.disabled = active or not SaveManager.has_any_save()
    dossier_button.disabled = active
    exit_button.disabled = active
    settings_button.disabled = active

func _show_settings_popup() -> void :
    if _privacy_gate_active:
        return
    var overlay = ColorRect.new()
    overlay.color = Color(0, 0, 0, 0.56) if GameState.theme == "dark" else Color(0, 0, 0, 0.34)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.z_index = 100

    overlay.gui_input.connect( func(event):
        if _is_primary_press_event(event):
            overlay.queue_free()
    )

    var panel = PanelContainer.new()
    var mobile_portrait: = _is_mobile_portrait()
    var is_landscape_mobile: = NativeMobileFontScalerRef.is_native_phone_landscape(self)
    panel.add_theme_stylebox_override("panel", SettingsPopupStyle.panel_style())
    panel.custom_minimum_size = Vector2(SettingsPopupStyle.popup_width(mobile_portrait, is_landscape_mobile, _is_effective_large_ui_mode()), 0)

    var center = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)

    var vbox = VBoxContainer.new()
    vbox.add_child(SettingsPopupStyle.make_header("设置"))
    vbox.add_child(SettingsPopupStyle.make_header_separator())

    var sound_btn = SettingsPopupStyle.make_text_toggle_row("音乐", "开" if GameState.sound_on else "关", func(): pass)
    sound_btn.pressed.connect( func():
        GameState.set_music( !GameState.sound_on)
        var sound_value: = sound_btn.get_node("Content/ValueLabel") as Label
        if sound_value:
            sound_value.text = "开" if GameState.sound_on else "关"
    )
    vbox.add_child(sound_btn)

    var ui_scale_btn = SettingsPopupStyle.make_text_toggle_row("界面大小", "大" if _is_effective_large_ui_mode() else "普通", func(): pass)
    ui_scale_btn.pressed.connect( func():
        GameState.set_large_ui_mode( not _is_effective_large_ui_mode())
        NativeMobileFontScalerRef.reset_scaled_overrides(self)
        _sync_native_landscape_size_override()
        _apply_responsive_layout()
        var ui_scale_value: = ui_scale_btn.get_node("Content/ValueLabel") as Label
        if ui_scale_value:
            ui_scale_value.text = "大" if _is_effective_large_ui_mode() else "普通"
        NativeMobileFontScalerRef.apply_to(overlay)
    )
    vbox.add_child(ui_scale_btn)

    var theme_btn = SettingsPopupStyle.make_button("主题：浅色" if GameState.theme == "light" else "主题：深色", func():
        GameState.toggle_theme()
        overlay.queue_free()
        _show_settings_popup()
    )



    if OS.has_feature("web") or not (OS.get_name() in ["Android", "iOS"]):
        var is_fs: = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
        if OS.has_feature("web"):
            is_fs = bool(JavaScriptBridge.eval("Boolean(document.fullscreenElement)"))
        var fullscreen_btn = SettingsPopupStyle.make_button("退出全屏" if is_fs else "网页全屏", func(): pass)
        fullscreen_btn.pressed.connect( func():
            var now_fs: = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
            if OS.has_feature("web"):
                now_fs = bool(JavaScriptBridge.eval("Boolean(document.fullscreenElement)"))
            if now_fs:
                if OS.has_feature("web"):
                    JavaScriptBridge.eval("if (window.__czExitFullscreen) window.__czExitFullscreen(); else if (document.exitFullscreen) document.exitFullscreen().catch(() => {});")
                else:
                    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
                fullscreen_btn.text = "网页全屏"
            else:
                if OS.has_feature("web"):
                    JavaScriptBridge.eval("\n\t\t\t\t\t(() => {\n\t\t\t\t\t\tif (window.__czEnterFullscreen) {\n\t\t\t\t\t\t\twindow.__czEnterFullscreen();\n\t\t\t\t\t\t\treturn;\n\t\t\t\t\t\t}\n\t\t\t\t\t\tconst target = document.documentElement || document.getElementById('canvas');\n\t\t\t\t\t\tif (target && target.requestFullscreen) {\n\t\t\t\t\t\t\ttarget.requestFullscreen().catch(() => {});\n\t\t\t\t\t\t}\n\t\t\t\t\t})();\n\t\t\t\t\t"\
\
\
\
\
\
\
\
\
\
\
)
                else:
                    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
                fullscreen_btn.text = "退出全屏"
        )
        vbox.add_child(fullscreen_btn)

    vbox.add_child(SettingsPopupStyle.make_button("隐私政策", _show_privacy_policy_viewer))


    if AdsConfigRef.ADS_ENABLED and OS.has_feature("android"):
        vbox.add_child(SettingsPopupStyle.make_button("关于广告机制的说明", _show_about_ads_popup))
    vbox.add_child(SettingsPopupStyle.make_button("关于游戏", _show_about_author_popup))

    SettingsPopupStyle.apply_layout(panel, vbox, mobile_portrait, is_landscape_mobile, _is_effective_large_ui_mode())

    panel.add_child(vbox)
    center.add_child(panel)
    overlay.add_child(center)
    add_child(overlay)
    NativeMobileFontScalerRef.apply_to(overlay)

func _show_privacy_consent_popup() -> void :
    var overlay = ColorRect.new()
    overlay.color = Color(0, 0, 0, 0.72)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.z_index = 200

    overlay.mouse_filter = Control.MOUSE_FILTER_STOP

    var panel = PanelContainer.new()
    var mobile_portrait: = OS.get_name() in ["Android", "iOS"] or _is_mobile_portrait()
    var is_landscape_mobile: = (OS.get_name() in ["Android", "iOS"]) and not _is_mobile_portrait()
    var viewport_size: = get_viewport_rect().size
    var panel_padding: = 20 if is_landscape_mobile else (36 if mobile_portrait else 32)
    panel.add_theme_stylebox_override("panel", _make_panel_box(panel_padding, true))

    var panel_w: float
    if is_landscape_mobile:
        panel_w = minf(viewport_size.x * 0.75, 560.0)
    elif mobile_portrait:
        panel_w = viewport_size.x * 0.92
    else:
        panel_w = minf(viewport_size.x * 0.5, 560.0)


    var panel_max_h: float
    if is_landscape_mobile:
        panel_max_h = viewport_size.y * 0.9
    elif mobile_portrait:
        panel_max_h = viewport_size.y * 0.88
    else:
        panel_max_h = viewport_size.y * 0.85
    panel.custom_minimum_size = Vector2(panel_w, 0)
    panel.custom_maximum_size = Vector2(panel_w, panel_max_h)

    var center = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 12 if is_landscape_mobile else (20 if mobile_portrait else 16))


    var title = Label.new()
    title.text = "隐私政策"
    title.add_theme_font_override("font", serif_font)
    title.add_theme_font_size_override("font_size", 22 if is_landscape_mobile else (MOBILE_MODAL_TITLE_FONT_SIZE if mobile_portrait else 20))
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)


    var scroll = ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.mouse_filter = Control.MOUSE_FILTER_PASS

    var scroll_min_h: float
    if is_landscape_mobile:
        scroll_min_h = viewport_size.y * 0.35
    elif mobile_portrait:
        scroll_min_h = viewport_size.y * 0.35
    else:
        scroll_min_h = 200.0
    scroll.custom_minimum_size = Vector2(0, scroll_min_h)
    ScrollbarThemeRef.apply_to(scroll)

    var desc = RichTextLabel.new()
    desc.bbcode_enabled = true
    desc.fit_content = true
    desc.scroll_active = false
    desc.selection_enabled = false
    desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    var desc_font_size: int
    if is_landscape_mobile:
        desc_font_size = 15
    elif mobile_portrait:
        desc_font_size = MOBILE_BODY_FONT_SIZE - 2
    else:
        desc_font_size = 13
    var desc_text: = "欢迎使用《崇祯直聘：明末官场沉浮模拟器》。\n\n[b]第三方广告服务[/b]\n• 游戏已接入 TapADN 激励视频 SDK，运营者为上海艾得蒽数字科技有限公司。只有在您同意本政策后且主动点击观看激励视频时，才会初始化并调用该 SDK。\n\n[b]处理信息[/b]\n• 设备基础信息（设备品牌、设备型号、系统版本、屏幕密度、屏幕分辨率、语言、时区、CPU、可用存储）、OAID、网络信息（Wi-Fi 状态、网络信号强度、IP 地址）、应用信息（应用包名、应用版本、运行进程、前后台状态）、广告展示、点击与转化数据、崩溃与性能数据。\n\n[b]目的、处理与共享[/b]\n• 用于广告展示、投放优化、归因、统计、反作弊及安全稳定。SDK 通过自动化方式采集上述信息，并传输至运营者及其关联方的境内服务器处理。\n• SDK 运营者可能向广告主、代理商、广告监测服务商等广告合作方共享经去标识化或匿名化处理的必要设备、网络与广告统计信息，以实现投放优化、归因、统计和反作弊，以 SDK 隐私政策为准。\n\n[b]保存与最小化[/b]\n• 相关数据仅在提供广告服务所必需期间保存；期限届满或收到删除等相应指令后，运营者将依其政策依法删除或匿名化，法定留存除外。个性化广告默认为限制模式。\n• 本游戏不申请 READ_PHONE_STATE、定位、QUERY_ALL_PACKAGES、REQUEST_INSTALL_PACKAGES、蓝牙、通知等权限。游戏存档仅保存在本地且不上传；该说明不适用于 SDK 广告数据。\n\n[b]您的选择[/b]\n• 点击“同意并继续”表示同意本政策；点击“不同意并退出”将退出游戏。\n• 隐私政策：[color=#8e3e2d][url=https://susugogo.cn/privacy/chongzhen_privacy_policy.html]https://susugogo.cn/privacy/chongzhen_privacy_policy.html[/url][/color]\n• SDK 隐私政策：[color=#8e3e2d][url=https://ssp.dirichlet.cn/docs/agreement/]https://ssp.dirichlet.cn/docs/agreement/[/url][/color]\n• SDK 合规说明：[color=#8e3e2d][url=https://ssp.dirichlet.cn/docs/compliance/]https://ssp.dirichlet.cn/docs/compliance/[/url][/color]"




















    desc.add_theme_font_override("normal_font", body_font)
    desc.add_theme_font_size_override("normal_font_size", desc_font_size)
    desc.add_theme_color_override("default_color", GameState.get_theme_color("text_desc"))
    desc.text = desc_text
    desc.meta_clicked.connect( func(meta): OS.shell_open(str(meta)))
    scroll.add_child(desc)
    vbox.add_child(scroll)


    var btn_box = VBoxContainer.new()
    btn_box.add_theme_constant_override("separation", 8 if is_landscape_mobile else (12 if mobile_portrait else 10))


    var agree_btn = Button.new()
    agree_btn.text = "同意并继续"
    var agree_btn_h: = 44.0 if is_landscape_mobile else (MOBILE_MODAL_BUTTON_HEIGHT if mobile_portrait else 42.0)
    agree_btn.custom_minimum_size = Vector2(0, agree_btn_h)
    agree_btn.add_theme_font_override("font", body_font)
    var agree_font_size: = 16 if is_landscape_mobile else (MOBILE_MODAL_BUTTON_FONT_SIZE if mobile_portrait else 16)
    agree_btn.add_theme_font_size_override("font_size", agree_font_size)
    GameScreenStyleFactory.apply_command_button_style(agree_btn, "primary", 20, 8)
    agree_btn.focus_mode = Control.FOCUS_NONE
    agree_btn.pressed.connect( func():
        GameState.set_privacy_agreed()
        _set_privacy_gate_active(false)
        overlay.queue_free()
    )
    btn_box.add_child(agree_btn)


    var disagree_btn = Button.new()
    disagree_btn.text = "不同意并退出"
    var disagree_btn_h: = 36.0 if is_landscape_mobile else (MOBILE_MODAL_BUTTON_HEIGHT - 8 if mobile_portrait else 36.0)
    disagree_btn.custom_minimum_size = Vector2(0, disagree_btn_h)
    disagree_btn.add_theme_font_override("font", body_font)
    var disagree_font_size: = 14 if is_landscape_mobile else (MOBILE_MODAL_BUTTON_FONT_SIZE - 2 if mobile_portrait else 14)
    disagree_btn.add_theme_font_size_override("font_size", disagree_font_size)
    GameScreenStyleFactory.apply_command_button_style(disagree_btn, "secondary", 20, 8)
    disagree_btn.focus_mode = Control.FOCUS_NONE
    disagree_btn.pressed.connect( func():
        get_tree().quit()
    )
    btn_box.add_child(disagree_btn)

    vbox.add_child(btn_box)
    panel.add_child(vbox)
    center.add_child(panel)
    overlay.add_child(center)
    add_child(overlay)
    NativeMobileFontScalerRef.apply_to(overlay)

func _show_privacy_policy_viewer() -> void :
    var overlay = ColorRect.new()
    overlay.color = Color(0, 0, 0, 0.72)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.z_index = 150
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP

    var panel = PanelContainer.new()
    var mobile_portrait: = OS.get_name() in ["Android", "iOS"] or _is_mobile_portrait()
    var is_landscape_mobile: = (OS.get_name() in ["Android", "iOS"]) and not _is_mobile_portrait()
    var pad_val: = 20 if is_landscape_mobile else (24 if mobile_portrait else 28)
    panel.add_theme_stylebox_override("panel", _make_panel_box(pad_val, true))

    var center = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)

    var viewport_size: = get_viewport_rect().size
    var panel_w: float
    var panel_h: float
    if is_landscape_mobile:
        panel_w = viewport_size.x * 0.75
        panel_h = viewport_size.y * 0.85
    elif mobile_portrait:
        panel_w = viewport_size.x * 0.92
        panel_h = viewport_size.y * 0.82
    else:
        panel_w = minf(viewport_size.x * 0.7, 680.0)
        panel_h = minf(viewport_size.y * 0.8, 640.0)
    panel.custom_minimum_size = Vector2(panel_w, panel_h)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 10 if is_landscape_mobile else (16 if mobile_portrait else 12))


    var title = Label.new()
    title.text = "《崇祯直聘：明末官场沉浮模拟器》隐私政策"
    title.add_theme_font_override("font", serif_font)
    title.add_theme_font_size_override("font_size", 20 if is_landscape_mobile else (26 if mobile_portrait else 18))
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(title)


    var scroll = ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    ScrollbarThemeRef.apply_to(scroll)

    var content = RichTextLabel.new()
    content.bbcode_enabled = true
    content.fit_content = true
    content.scroll_active = false
    content.selection_enabled = false
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var content_font_size: = 15 if is_landscape_mobile else (15 if mobile_portrait else 14)
    content.add_theme_font_override("normal_font", body_font)
    content.add_theme_font_override("bold_font", serif_font)
    content.add_theme_font_size_override("normal_font_size", content_font_size)
    content.add_theme_font_size_override("bold_font_size", content_font_size + 2)
    content.add_theme_color_override("default_color", GameState.get_theme_color("text_desc"))

    var policy_text: = "[b]温馨提示[/b]\n\n欢迎您使用《崇祯直聘：明末官场沉浮模拟器》！我们非常重视保护您的个人信息和隐私。您可以通过本隐私政策了解我们收集、使用、存储用户信息的情况，以及您所享有的相关权利。\n\n当前版本主要为单机叙事决策游戏，不提供账号注册、实名认证、充值消费、社交分享、语音聊天等功能。游戏已接入 TapADN 激励视频 SDK。\n\n[b]一、政策说明[/b]\n\n速速归位工作室（以下简称\"我们\"）系《崇祯直聘：明末官场沉浮模拟器》的运营者。我们非常重视保护您的个人信息和隐私。您在使用本游戏时，我们会依据本隐私政策，在实现游戏基础功能所必要的范围内处理相关信息。\n\n在移动端中，当您首次启动本游戏时，我们将以弹窗形式向您展示本隐私政策。只有在您点击\"同意并继续\"后，游戏才会正式提供完整的服务功能。\n\n[b]二、我们如何收集和使用您的信息[/b]\n\n1. 游戏加载与基础运行：Godot 引擎用于画面渲染、输入交互、本地运行和存档，不涉及设备标识。\n\n2. 本地游戏存档与结局记录：游戏可能在您的设备本地存储游戏进度、结局解锁记录、基础设置等信息，通常不会主动上传至服务器。\n\n3. 激励视频广告：只有在您同意本隐私政策后，且主动点击观看激励视频时，游戏才会初始化并调用 TapADN SDK。\n\n[b]三、设备权限调用情况[/b]\n\n本游戏不申请 READ_PHONE_STATE、定位、QUERY_ALL_PACKAGES、REQUEST_INSTALL_PACKAGES、蓝牙、通知等权限。TapADN 自定义隐私控制器禁止获取 IMEI、Android ID、位置信息、软件列表和外部写入；摇一摇交互已关闭，个性化广告默认为限制模式。\n\n[b]四、第三方 SDK 或引擎信息披露[/b]\n\n第三方 SDK 名称：TapADN\n运营者：上海艾得蒽数字科技有限公司\n处理信息：设备基础信息（设备品牌、设备型号、系统版本、屏幕密度、屏幕分辨率、语言、时区、CPU、可用存储）、OAID、网络信息（Wi-Fi 状态、网络信号强度、IP 地址）、应用信息（应用包名、应用版本、运行进程、前后台状态）、广告展示、点击与转化数据、崩溃与性能数据。\n使用目的：广告展示、投放优化、归因、统计、反作弊与安全稳定。\n调用时机：您同意本隐私政策后，且主动点击观看激励视频时。\n处理方式：SDK 通过自动化方式采集上述信息，并传输至上海艾得蒽数字科技有限公司及其关联方的境内服务器进行处理。\n共享情形：SDK 运营者可能向广告主、代理商、广告监测服务商等广告合作方共享经去标识化或匿名化处理的必要设备、网络与广告统计信息，用于投放优化、归因、统计和反作弊，以 SDK 隐私政策为准。\n保存期限：相关数据仅在提供广告服务所必需期间保存；期限届满或收到删除等相应指令后，该公司将依其政策依法删除或匿名化，法律法规要求法定留存的除外。\n数据区分：游戏存档仅保存在本地且不上传；该说明不适用于 SDK 广告数据。\nSDK 隐私政策：[url=https://ssp.dirichlet.cn/docs/agreement/]https://ssp.dirichlet.cn/docs/agreement/[/url]\nSDK 合规说明：[url=https://ssp.dirichlet.cn/docs/compliance/]https://ssp.dirichlet.cn/docs/compliance/[/url]\n\n[b]五、我们如何保存您的信息[/b]\n\n游戏进度、设置、结局记录等数据通常保存在您的本地设备中，不主动上传至服务器。我们在中国境内运营过程中收集和产生的个人信息将保存在中国境内。\n\n[b]六、共享、转让、公开披露[/b]\n\n我们不会主动向第三方共享您的个人信息，法律法规要求或获得您明确同意的情形除外。\n\n[b]七、未成年人信息保护[/b]\n\n如您为未成年人，请您的父母或其他监护人仔细阅读本隐私政策，并在征得监护人同意后使用我们的服务。\n\n[b]八、联系我们[/b]\n\n运营者：速速归位工作室\n联系邮箱：Pyacark@gmail.com\n\n更新日期：2026年7月15日\n生效日期：2026年7月15日"

























































    content.text = policy_text
    content.meta_clicked.connect( func(meta): OS.shell_open(str(meta)))
    scroll.add_child(content)
    vbox.add_child(scroll)


    var close_btn = Button.new()
    close_btn.text = "返回"
    var close_btn_h: = 44.0 if is_landscape_mobile else (MOBILE_MODAL_BUTTON_HEIGHT if mobile_portrait else 36.0)
    close_btn.custom_minimum_size = Vector2(0, close_btn_h)
    close_btn.add_theme_font_override("font", body_font)
    var close_btn_font_size: = 16 if is_landscape_mobile else (MOBILE_MODAL_BUTTON_FONT_SIZE if mobile_portrait else 14)
    close_btn.add_theme_font_size_override("font_size", close_btn_font_size)
    var main_color = GameState.get_theme_color("text_main")
    close_btn.add_theme_color_override("font_color", main_color)
    close_btn.add_theme_stylebox_override("normal", _make_button_box(GameState.get_theme_color("bg_panel_weak")))
    close_btn.add_theme_stylebox_override("hover", _make_button_box(GameState.get_theme_color("bg_panel")))
    close_btn.add_theme_stylebox_override("pressed", _make_button_box(GameState.get_theme_color("choice_press")))
    close_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    close_btn.focus_mode = Control.FOCUS_NONE
    close_btn.pressed.connect( func():
        overlay.queue_free()
    )
    vbox.add_child(close_btn)

    panel.add_child(vbox)
    center.add_child(panel)
    overlay.add_child(center)
    add_child(overlay)
    NativeMobileFontScalerRef.apply_to(overlay)

func _show_about_author_popup() -> void :

    AboutGamePopupRef.show(self)

func _show_about_ads_popup() -> void :

    AboutAdsPopupRef.show(self)

func _show_exit_confirm_popup() -> void :
    if _privacy_gate_active:
        return
    var overlay: = ColorRect.new()
    overlay.color = Color(0, 0, 0, 0.58) if GameState.theme == "dark" else Color(0, 0, 0, 0.36)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.z_index = 120
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.add_to_group("blocking_modal_overlay")
    overlay.gui_input.connect( func(event):
        if _is_primary_press_event(event):
            overlay.queue_free()
    )

    var mobile_portrait: = OS.get_name() in ["Android", "iOS"] or _is_mobile_portrait()
    var is_landscape_mobile: = NativeMobileFontScalerRef.is_native_phone_landscape(self)
    var viewport_size: = get_viewport_rect().size

    var center: = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)

    var panel: = PanelContainer.new()
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    panel.gui_input.connect( func(event):
        if event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventScreenDrag:
            panel.get_viewport().set_input_as_handled()
    )
    var panel_padding: = 20 if is_landscape_mobile else (34 if mobile_portrait else 28)
    panel.add_theme_stylebox_override("panel", _make_panel_box(panel_padding, true))
    var panel_w: float
    if is_landscape_mobile:
        panel_w = minf(viewport_size.x * 0.68, 520.0)
    elif mobile_portrait:
        panel_w = viewport_size.x * 0.84
    else:
        panel_w = minf(viewport_size.x * 0.42, 480.0)
    panel.custom_minimum_size = Vector2(panel_w, 0)

    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 12 if is_landscape_mobile else (20 if mobile_portrait else 14))

    var title: = Label.new()
    title.text = "退出游戏"
    title.add_theme_font_override("font", serif_font)
    title.add_theme_font_size_override("font_size", 22 if is_landscape_mobile else (MOBILE_MODAL_TITLE_FONT_SIZE if mobile_portrait else 20))
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)

    var desc: = Label.new()
    desc.text = "确定要退出游戏吗？"
    desc.add_theme_font_override("font", body_font)
    desc.add_theme_font_size_override("font_size", 16 if is_landscape_mobile else (MOBILE_BODY_FONT_SIZE if mobile_portrait else 14))
    desc.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(desc)

    var buttons: = HBoxContainer.new()
    buttons.alignment = BoxContainer.ALIGNMENT_CENTER
    buttons.add_theme_constant_override("separation", 10 if is_landscape_mobile else (18 if mobile_portrait else 12))

    var cancel_btn: = _make_settings_button("取消", mobile_portrait, is_landscape_mobile)
    cancel_btn.custom_minimum_size.x = 120.0 if not mobile_portrait else 220.0
    var command_pad_x: = 24 if mobile_portrait else 18
    var command_pad_y: = 12 if mobile_portrait else 8
    GameScreenStyleFactory.apply_command_button_style(cancel_btn, "secondary", command_pad_x, command_pad_y)
    cancel_btn.pressed.connect( func():
        overlay.queue_free()
    )
    buttons.add_child(cancel_btn)

    var confirm_btn: = _make_settings_button("退出游戏", mobile_portrait, is_landscape_mobile)
    confirm_btn.custom_minimum_size.x = 120.0 if not mobile_portrait else 220.0
    GameScreenStyleFactory.apply_command_button_style(confirm_btn, "primary", command_pad_x, command_pad_y)
    confirm_btn.pressed.connect( func():
        get_tree().quit()
    )
    buttons.add_child(confirm_btn)

    vbox.add_child(buttons)
    panel.add_child(vbox)
    center.add_child(panel)
    overlay.add_child(center)
    add_child(overlay)
    NativeMobileFontScalerRef.apply_to(overlay)

func _make_settings_button(text: String, mobile_portrait: bool, is_landscape_mobile: bool = false) -> Button:
    var button = Button.new()
    button.text = text
    var btn_h: = 38.0 if is_landscape_mobile else (MOBILE_MODAL_BUTTON_HEIGHT if mobile_portrait else 0.0)
    button.custom_minimum_size = Vector2(0, btn_h)
    var btn_font: = 14 if is_landscape_mobile else (MOBILE_MODAL_BUTTON_FONT_SIZE if mobile_portrait else 16)
    button.add_theme_font_size_override("font_size", btn_font)
    var text_color = GameState.get_theme_color("text_main")
    var hover_color = GameState.get_theme_color("border_active")
    if GameState.theme == "light":
        hover_color = Color(0.58, 0.44, 0.18, 1.0)
    button.add_theme_color_override("font_color", text_color)
    button.add_theme_color_override("font_hover_color", hover_color)
    button.add_theme_color_override("font_pressed_color", hover_color.darkened(0.1))

    if text == "返回":
        button.icon = load("res://assets/ui/back.svg")
        button.expand_icon = false
        button.add_theme_constant_override("h_separation", 6)
        button.add_theme_constant_override("icon_max_width", btn_font)
        button.add_theme_color_override("icon_normal_color", text_color)
        button.add_theme_color_override("icon_hover_color", hover_color)
        button.add_theme_color_override("icon_pressed_color", hover_color.darkened(0.1))
        button.add_theme_color_override("icon_focus_color", hover_color)

    if GameState.theme == "light":
        var empty_style = StyleBoxEmpty.new()
        button.add_theme_stylebox_override("normal", empty_style)
        button.add_theme_stylebox_override("hover", empty_style)
        button.add_theme_stylebox_override("pressed", empty_style)
        button.add_theme_stylebox_override("focus", empty_style)
    else:
        button.add_theme_stylebox_override("normal", _make_button_box(GameState.get_theme_color("bg_panel_weak")))
        button.add_theme_stylebox_override("hover", _make_button_box(GameState.get_theme_color("bg_panel")))
        button.add_theme_stylebox_override("pressed", _make_button_box(GameState.get_theme_color("choice_press")))
        button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    return button


func _make_settings_text_toggle_row(label_text: String, value_text: String, mobile_portrait: bool, is_landscape_mobile: bool = false) -> Button:
    var btn: = _make_settings_button("", mobile_portrait, is_landscape_mobile)
    btn.name = "%sTextToggleRow" % label_text



    var row_h: = 38.0 if is_landscape_mobile else (MOBILE_MODAL_BUTTON_HEIGHT if mobile_portrait else 38.0)
    btn.custom_minimum_size = Vector2(0, row_h)

    var wrapper: = HBoxContainer.new()
    wrapper.name = "Content"
    wrapper.alignment = BoxContainer.ALIGNMENT_CENTER
    wrapper.add_theme_constant_override("separation", 8)
    wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE
    btn.add_child(wrapper)
    wrapper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var label_font_size: = 14 if is_landscape_mobile else (MOBILE_MODAL_BUTTON_FONT_SIZE if mobile_portrait else 16)
    var text_color: = GameState.get_theme_color("text_main")

    var label: = Label.new()
    label.text = label_text
    label.add_theme_font_override("font", body_font)
    label.add_theme_font_size_override("font_size", label_font_size)
    label.add_theme_color_override("font_color", text_color)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    wrapper.add_child(label)

    var value: = Label.new()
    value.name = "ValueLabel"
    value.text = value_text
    value.add_theme_font_override("font", body_font)
    value.add_theme_font_size_override("font_size", label_font_size)
    value.add_theme_color_override("font_color", Color(0.98, 0.88, 0.58, 1.0))
    value.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    value.mouse_filter = Control.MOUSE_FILTER_IGNORE
    wrapper.add_child(value)
    return btn

func _apply_secondary_modal_button_style(button: Button, mobile_portrait: bool) -> void :
    var pad_x: = 24 if mobile_portrait else 18
    var pad_y: = 12 if mobile_portrait else 8
    var text_color: = GameState.get_theme_color("text_main")
    button.add_theme_color_override("font_color", text_color)
    button.add_theme_color_override("font_hover_color", text_color.lightened(0.08) if GameState.theme == "dark" else text_color.darkened(0.08))
    button.add_theme_color_override("font_pressed_color", text_color.lightened(0.14) if GameState.theme == "dark" else text_color.darkened(0.14))
    button.add_theme_stylebox_override("normal", GameScreenStyleFactory.secondary_modal_button_style(false, false, pad_x, pad_y))
    button.add_theme_stylebox_override("hover", GameScreenStyleFactory.secondary_modal_button_style(true, false, pad_x, pad_y))
    button.add_theme_stylebox_override("pressed", GameScreenStyleFactory.secondary_modal_button_style(true, true, pad_x, pad_y))
    button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())




func _apply_typography() -> void :
    if is_instance_valid(logo):
        logo.texture = logo_light if GameState.theme == "light" else logo_dark


        logo.modulate = Color(0.64, 0.47, 0.1, 1.0) if GameState.theme == "light" else Color(1, 1, 1, 1)

    tagline_label.add_theme_font_override("font", body_font)
    version_label.add_theme_font_override("font", body_font)
    version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    for button in [start_button, load_button, dossier_button, exit_button, settings_button]:
        button.focus_mode = Control.FOCUS_NONE
        button.add_theme_font_override("font", body_font)
        button.add_theme_color_override("font_color", INK)
        button.add_theme_color_override("font_hover_color", GOLD)

    tagline_label.add_theme_color_override("font_color", Color(0.48, 0.45, 0.42, 0.9) if GameState.theme == "light" else GameState.get_theme_color("text_desc"))
    version_label.add_theme_color_override("font_color", Color(0.62, 0.58, 0.52, 0.6) if GameState.theme == "light" else Color(1, 1, 1, 0.45))
    if version_label.has_theme_color_override("font_shadow_color"):
        version_label.remove_theme_color_override("font_shadow_color")
    if version_label.has_theme_constant_override("shadow_offset_x"):
        version_label.remove_theme_constant_override("shadow_offset_x")
    if version_label.has_theme_constant_override("shadow_offset_y"):
        version_label.remove_theme_constant_override("shadow_offset_y")

    if GameState.theme == "light":
        gradient_overlay.visible = false
        gradient_overlay.material = null
        background.material = _get_bg_shader_material()
    else:
        gradient_overlay.visible = true
        gradient_overlay.texture = _get_overlay_fill_texture()
        gradient_overlay.material = _get_dark_overlay_shader_material()
        background.material = null
    _setup_left_panel()


var _bg_shader_material: ShaderMaterial

func _get_bg_shader_material() -> ShaderMaterial:
    if _bg_shader_material:
        return _bg_shader_material
    var shader: = Shader.new()
    shader.code = "\nshader_type canvas_item;\nuniform float saturation : hint_range(0.0, 2.0) = 0.75;\nuniform float contrast : hint_range(0.0, 3.0) = 1.02;\nuniform float brightness : hint_range(0.0, 3.0) = 1.0;\nuniform float mix_white : hint_range(0.0, 1.0) = 0.0;\nvoid fragment() {\n\tvec4 color = texture(TEXTURE, UV);\n\tfloat luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));\n\tvec3 desat = mix(vec3(luma), color.rgb, saturation);\n\tvec3 contrasted = mix(vec3(0.5), desat, contrast);\n\tvec3 brightened = contrasted * brightness;\n\tvec3 final_color = mix(brightened, vec3(1.0), mix_white);\n\tCOLOR = vec4(final_color, color.a);\n}\n"















    _bg_shader_material = ShaderMaterial.new()
    _bg_shader_material.shader = shader
    return _bg_shader_material




func _setup_left_panel() -> void :
    var panel: = get_node_or_null("LeftPanel") as ColorRect
    if panel == null:
        return
    panel.material = null


var _dark_overlay_shader_material: ShaderMaterial
var _overlay_fill_texture: Texture2D

func _get_overlay_fill_texture() -> Texture2D:
    if _overlay_fill_texture:
        return _overlay_fill_texture
    var image: = Image.create(8, 8, false, Image.FORMAT_RGBA8)
    image.fill(Color.WHITE)
    _overlay_fill_texture = ImageTexture.create_from_image(image)
    return _overlay_fill_texture


func _get_dark_overlay_shader_material() -> ShaderMaterial:
    if _dark_overlay_shader_material:
        return _dark_overlay_shader_material
    var shader: = Shader.new()

    shader.code = "\nshader_type canvas_item;\nuniform vec3 top_color = vec3(0.020, 0.016, 0.011);\nuniform vec3 bottom_color = vec3(0.040, 0.040, 0.038);\nuniform float a_left : hint_range(0.0, 1.0) = 0.96;\n// 左侧纯黑区占比（此范围内几乎全黑），之后向右自然过渡到 0\nuniform float hold : hint_range(0.0, 1.0) = 0.18;\nuniform float fade_end : hint_range(0.0, 1.0) = 0.62;\nvoid fragment() {\n\t// 纵向配色：上深棕黑 → 下灰黑\n\tvec3 col = mix(top_color, bottom_color, UV.y);\n\t// 横向透明度：左侧约 hold 范围内保持浓黑，随后 smoothstep 自然过渡至 0，\n\t// 右侧完全透明露出底图，形成左黑右亮的明暗层次。\n\tfloat x = UV.x;\n\tfloat t = smoothstep(hold, fade_end, x);\n\tfloat alpha = a_left * (1.0 - t);\n\tCOLOR = vec4(col, alpha);\n}\n"


















    _dark_overlay_shader_material = ShaderMaterial.new()
    _dark_overlay_shader_material.shader = shader
    return _dark_overlay_shader_material


var _overlay_shader_material: ShaderMaterial

func _get_overlay_shader_material() -> ShaderMaterial:
    if _overlay_shader_material:
        return _overlay_shader_material
    var shader: = Shader.new()


    shader.code = "\nshader_type canvas_item;\nuniform vec3 ink = vec3(0.16, 0.17, 0.18);\nuniform float a_left : hint_range(0.0, 1.0) = 0.03;\nuniform float a_right : hint_range(0.0, 1.0) = 0.32;\nuniform float curve : hint_range(0.5, 3.0) = 1.6;\nuniform float grain : hint_range(0.0, 0.3) = 0.05;\n// 伪随机噪点\nfloat hash(vec2 p) {\n\treturn fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);\n}\nvoid fragment() {\n\t// 主轴：左->右，用幂函数让加深更偏右、更有曲线感\n\tfloat gx = pow(clamp(UV.x, 0.0, 1.0), curve);\n\t// 让加深轴随高度起伏：顶部稍偏左、底部稍偏右，形成不规则斜向\n\tfloat skew = (UV.y - 0.5) * 0.18;\n\tgx = clamp(gx + skew * (1.0 - gx), 0.0, 1.0);\n\t// 顶/底各压一点点暗，中间略亮\n\tfloat vy = 0.10 * (1.0 - smoothstep(0.0, 0.35, UV.y))\n\t\t\t + 0.08 * smoothstep(0.65, 1.0, UV.y);\n\tfloat a = mix(a_left, a_right, gx) + vy * a_right;\n\t// 细颗粒噪点，越深的区域噪点越明显，增加纸面质感\n\tfloat n = hash(floor(FRAGCOORD.xy)) - 0.5;\n\ta += n * grain * (0.4 + 0.6 * gx);\n\ta = clamp(a, 0.0, 1.0);\n\tCOLOR = vec4(ink, a);\n}\n"



























    _overlay_shader_material = ShaderMaterial.new()
    _overlay_shader_material.shader = shader
    return _overlay_shader_material


func _apply_button_styles() -> void :
    var start_font = Color(0.98, 0.93, 0.82, 1) if GameState.theme == "dark" else Color(0.98, 0.93, 0.82, 1)
    _style_button(start_button, Color.TRANSPARENT, Color.TRANSPARENT, Color.TRANSPARENT, start_font, true)
    start_button.add_theme_font_override("font", serif_font)
    _setup_start_button_gradient()
    var normal_bg = Color.html("#F3EFEC") if GameState.theme == "light" else Color(0.045, 0.032, 0.02, 0.88)
    var hover_bg = PAPER_HOVER if GameState.theme == "light" else Color(0.16, 0.1, 0.05, 0.62)
    var pressed_bg = GameState.get_theme_color("choice_press") if GameState.theme == "light" else Color(0.1, 0.07, 0.035, 0.76)
    _style_button(load_button, normal_bg, hover_bg, pressed_bg, INK, false)
    _style_button(dossier_button, normal_bg, hover_bg, pressed_bg, INK, false)
    _style_button(exit_button, normal_bg, hover_bg, pressed_bg, INK, false)


    var circle_box: = StyleBoxFlat.new()
    circle_box.bg_color = Color(0.34, 0.2, 0.08, 0.3)
    circle_box.border_color = Color(1.0, 0.96, 0.88, 1.0)
    circle_box.set_border_width_all(1)
    circle_box.set_corner_radius_all(999)
    circle_box.set_content_margin_all(5)
    var empty_box: = StyleBoxEmpty.new()
    settings_button.add_theme_stylebox_override("normal", circle_box)
    settings_button.add_theme_stylebox_override("hover", circle_box)
    settings_button.add_theme_stylebox_override("pressed", circle_box)
    settings_button.add_theme_stylebox_override("focus", empty_box)
    settings_button.add_theme_stylebox_override("disabled", empty_box)

    settings_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)


func _style_button(button: Button, normal_bg: Color, hover_bg: Color, pressed_bg: Color, font_color: Color, strong: bool) -> void :
    button.add_theme_color_override("font_color", font_color)
    button.add_theme_color_override("font_hover_color", font_color)
    button.add_theme_color_override("font_pressed_color", font_color)
    button.add_theme_color_override("font_focus_color", font_color)
    button.add_theme_color_override("font_disabled_color", Color(font_color.r, font_color.g, font_color.b, 0.42))
    button.add_theme_stylebox_override("normal", _make_button_box(normal_bg))
    button.add_theme_stylebox_override("hover", _make_button_box(hover_bg))
    button.add_theme_stylebox_override("pressed", _make_button_box(pressed_bg))
    button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    button.add_theme_stylebox_override("disabled", _make_button_box(Color(0.92, 0.88, 0.78, 0.12)))


func _make_button_box(bg: Color) -> StyleBoxFlat:
    var box: = StyleBoxFlat.new()
    box.bg_color = bg
    box.set_border_width_all(0)
    box.corner_radius_top_left = 2
    box.corner_radius_top_right = 2
    box.corner_radius_bottom_left = 2
    box.corner_radius_bottom_right = 2
    box.shadow_color = Color(0, 0, 0, 0.2 if GameState.theme == "dark" else 0.06)
    box.shadow_size = 4 if GameState.theme == "dark" else 2
    box.content_margin_left = 16
    box.content_margin_right = 16
    box.content_margin_top = 8
    box.content_margin_bottom = 8
    return box

func _make_panel_box(pad: int, strong: bool = false) -> StyleBoxFlat:
    var box: = StyleBoxFlat.new()
    box.bg_color = Color.html("E0E2E6") if GameState.theme == "light" else GameState.get_theme_color("bg_popup")
    box.border_color = Color(0.42, 0.43, 0.44, 0.72)
    box.set_border_width_all(1)
    box.corner_radius_top_left = 2
    box.corner_radius_top_right = 2
    box.corner_radius_bottom_left = 2
    box.corner_radius_bottom_right = 2
    box.content_margin_left = pad
    box.content_margin_right = pad
    box.content_margin_top = pad
    box.content_margin_bottom = pad
    box.shadow_size = 16 if GameState.theme == "dark" else (0 if GameState.theme == "light" else 8)
    box.shadow_color = Color(0, 0, 0, 0.42 if GameState.theme == "dark" else 0.14)
    box.shadow_offset = Vector2(0, 6)
    return box


func _get_responsive_window_size() -> Vector2:
    var viewport_size: = get_viewport_rect().size
    var window_size: = Vector2(DisplayServer.window_get_size())

    if OS.has_feature("web"):
        var browser_json: = str(JavaScriptBridge.eval("JSON.stringify({ w: window.innerWidth, h: window.innerHeight })"))
        var parsed = JSON.parse_string(browser_json)
        if parsed is Dictionary:
            var width: = float(parsed.get("w", 0.0))
            var height: = float(parsed.get("h", 0.0))
            if width > 0.0 and height > 0.0:
                return Vector2(width, height)

    if window_size.x > 0.0 and window_size.y > 0.0:
        return window_size
    return viewport_size


func _is_mobile_portrait() -> bool:
    var window_size: = _get_responsive_window_size()
    return window_size.y > window_size.x
func _apply_responsive_layout() -> void :
    var viewport_size: = size
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
        viewport_size = get_viewport_rect().size
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
        return

    _apply_background_alignment(viewport_size)
    _apply_title_character_layout()

    if _is_mobile_portrait():
        _apply_mobile_portrait_layout(viewport_size)
    else:
        _apply_desktop_landscape_layout(viewport_size)

    await get_tree().process_frame
    _apply_native_mobile_font_scale()
    await get_tree().process_frame
    print("DBG settings_button.size=", settings_button.size, " vflag=", settings_button.size_flags_vertical, " hflag=", settings_button.size_flags_horizontal, " menu.size=", menu.size, " menu.min=", menu.get_combined_minimum_size())

    queue_redraw()




func _apply_background_alignment(viewport_size: Vector2) -> void :
    if not is_instance_valid(background) or background.texture == null:
        return
    var tex_size: Vector2 = background.texture.get_size()
    if tex_size.x <= 0.0 or tex_size.y <= 0.0:
        return
    var bg_aspect: float = tex_size.x / tex_size.y
    var bg_width: float = viewport_size.y * bg_aspect
    var viewport_aspect: float = viewport_size.x / max(viewport_size.y, 1.0)
    var narrow_factor: float = clamp((BG_NARROW_ASPECT_BASE - viewport_aspect) / (BG_NARROW_ASPECT_BASE - BG_NARROW_ASPECT_MIN), 0.0, 1.0)
    var right_shift: float = bg_width * BG_NARROW_SHIFT_RATIO * narrow_factor
    background.offset_top = 0.0
    background.offset_bottom = 0.0
    background.offset_right = right_shift
    background.offset_left = right_shift - bg_width


func _apply_title_character_layout() -> void :
    if not is_instance_valid(title_character) or title_character.texture == null:
        return
    if not is_instance_valid(background) or background.texture == null:
        return
    var bg_rect: = Rect2(background.position, background.size)
    if bg_rect.size.x <= 0.0 or bg_rect.size.y <= 0.0:
        bg_rect = Rect2(
            Vector2(background.offset_left, background.offset_top), 
            Vector2(background.offset_right - background.offset_left, background.offset_bottom - background.offset_top)
        )
    if bg_rect.size.x <= 0.0 or bg_rect.size.y <= 0.0:
        return
    var texture_size: Vector2 = title_character.texture.get_size()
    if texture_size.x <= 0.0 or texture_size.y <= 0.0:
        return
    var target_height: float = bg_rect.size.y * TITLE_CHARACTER_HEIGHT_FRAC
    var target_width: float = target_height * texture_size.x / texture_size.y
    var center_x: float = bg_rect.position.x + bg_rect.size.x * TITLE_CHARACTER_CENTER_X_FRAC
    var bottom_y: float = bg_rect.position.y + bg_rect.size.y * TITLE_CHARACTER_BOTTOM_Y_FRAC
    title_character.position = Vector2(center_x - target_width * 0.5 - TITLE_CHARACTER_WIND_PADDING, bottom_y - target_height)
    title_character.size = Vector2(target_width + TITLE_CHARACTER_WIND_PADDING * 2.0, target_height)


func _apply_desktop_landscape_layout(viewport_size: Vector2) -> void :




    var aspect: float = viewport_size.x / max(viewport_size.y, 1.0)
    var wide_factor: float = clamp((aspect - LEFT_PANEL_WIDE_ASPECT_BASE) / (LEFT_PANEL_WIDE_ASPECT_MAX - LEFT_PANEL_WIDE_ASPECT_BASE), 0.0, 1.0)
    var width_ratio: float = lerp(LEFT_PANEL_WIDTH_RATIO, LEFT_PANEL_WIDTH_RATIO_WIDE, wide_factor)
    var left_width_max: float = lerp(610.0, LEFT_WIDTH_MAX_WIDE, wide_factor)
    var panel_width: float = max(LEFT_PANEL_MIN_WIDTH, viewport_size.x * width_ratio)
    var edge: float = clamp(viewport_size.y * 0.042, 24.0, 40.0)
    if is_instance_valid(left_panel):
        left_panel.visible = true
        left_panel.offset_left = edge
        left_panel.offset_top = 0.0
        left_panel.offset_bottom = 0.0
        left_panel.offset_right = edge + panel_width

    var top_margin: float = clamp(viewport_size.y * 0.2, 100.0, 190.0)
    var left_width: float = clamp(panel_width * 0.86, 430.0, left_width_max)
    var side_margin: float = edge + (panel_width - left_width) * 0.5

    center_frame.position = Vector2(side_margin, top_margin)
    center_frame.size = Vector2(left_width, viewport_size.y - top_margin - clamp(viewport_size.y * 0.12, 72.0, 110.0))

    menu.size = Vector2(clamp(viewport_size.x * 0.18, 210.0, 300.0), 42.0)
    menu.position = Vector2(viewport_size.x - menu.size.x - 42.0, clamp(viewport_size.y * 0.045, 34.0, 58.0))

    version_label.size = Vector2(left_width, 24.0)
    version_label.position = Vector2(side_margin, viewport_size.y - version_label.size.y - 24.0)
    version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER



    var scale: float = clamp(panel_width / 640.0, 0.66, 1.0)
    var logo_scale: float = scale * 0.86
    logo.custom_minimum_size = Vector2(0, int(round(260.0 * logo_scale)))

    var btn_spacer = $CenterFrame / VBoxContainer / ButtonSpacer
    if is_instance_valid(btn_spacer):
        btn_spacer.custom_minimum_size.y = int(round(14.0 * scale))

    tagline_margin.add_theme_constant_override("margin_top", -36)
    tagline_margin.add_theme_constant_override("margin_bottom", -38)
    tagline_label.add_theme_font_size_override("font_size", int(round(20.0 * scale)))
    tagline_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    start_button.add_theme_font_size_override("font_size", int(round(32.0 * scale)))
    load_button.add_theme_font_size_override("font_size", int(round(26.0 * scale)))
    dossier_button.add_theme_font_size_override("font_size", int(round(26.0 * scale)))
    exit_button.add_theme_font_size_override("font_size", int(round(26.0 * scale)))
    version_label.add_theme_font_size_override("font_size", 10)



    var logo_display_w: float = min(left_width, logo.custom_minimum_size.y * LOGO_TEX_ASPECT)
    var logo_decor_w: float = logo_display_w * (LOGO_DECOR_RIGHT_FRAC - LOGO_DECOR_LEFT_FRAC)
    var button_width: float = clamp(logo_decor_w, 300.0, left_width * 0.74)
    start_button.custom_minimum_size = Vector2(button_width, 72.0 * scale)
    load_button.custom_minimum_size = Vector2(button_width, 60.0 * scale)
    dossier_button.custom_minimum_size = Vector2(button_width, 60.0 * scale)
    exit_button.custom_minimum_size = Vector2(button_width, 60.0 * scale)
    start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    load_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    dossier_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    exit_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

    settings_button.custom_minimum_size = Vector2(26.0, 26.0)

    if NativeMobileFontScalerRef.is_native_phone_landscape(self):
        _center_native_mobile_landscape_title_stack(viewport_size, side_margin, left_width)

    _position_atmosphere_emitters(viewport_size, center_frame.position, center_frame.size, false)


func _center_native_mobile_landscape_title_stack(viewport_size: Vector2, side_margin: float, left_width: float) -> void :
    var version_top: float = viewport_size.y - 24.0 - 24.0
    var min_top: float = clamp(viewport_size.y * 0.055, 36.0, 64.0)
    var max_top: float = maxf(min_top, version_top - NATIVE_MOBILE_LANDSCAPE_VERSION_GAP - NATIVE_MOBILE_LANDSCAPE_CONTENT_STACK_HEIGHT)
    var centered_top: float = (viewport_size.y - NATIVE_MOBILE_LANDSCAPE_CONTENT_STACK_HEIGHT) * 0.5
    var top_margin: float = clamp(centered_top, min_top, max_top)
    center_frame.position = Vector2(side_margin, top_margin)
    center_frame.size = Vector2(left_width, maxf(NATIVE_MOBILE_LANDSCAPE_CONTENT_STACK_HEIGHT, viewport_size.y - top_margin - 72.0))


func _apply_native_mobile_font_scale() -> void :
    _sync_native_landscape_size_override()
    NativeMobileFontScalerRef.apply_to(self)


func _apply_mobile_portrait_layout(viewport_size: Vector2) -> void :

    if is_instance_valid(left_panel):
        left_panel.visible = false

    var content_width: float = clamp(viewport_size.x * 0.76, 720.0, 920.0)
    var bottom_margin: float = clamp(viewport_size.y * 0.11, 92.0, 132.0)
    var top_safe_area: float = clamp(viewport_size.y * 0.12, 108.0, 158.0)
    var centered_top: float = (viewport_size.y - MOBILE_CONTENT_STACK_HEIGHT) * 0.5 + MOBILE_CONTENT_CENTER_BIAS_Y
    var top_margin: float = clamp(centered_top, top_safe_area, viewport_size.y - bottom_margin - MOBILE_CONTENT_STACK_HEIGHT)

    var side_margin: float = (viewport_size.x - content_width) * 0.5

    center_frame.position = Vector2(side_margin, top_margin)
    center_frame.size = Vector2(content_width, viewport_size.y - top_margin - bottom_margin)

    var top_menu_edge_gap: = clampf(viewport_size.x * 0.045, 40.0, 68.0)
    menu.size = Vector2(190.0, MOBILE_TOP_BUTTON_HEIGHT)
    menu.position = Vector2(
        top_menu_edge_gap, 
        clamp(viewport_size.y * 0.045, 32.0, 50.0)
    )
    settings_button.custom_minimum_size = Vector2(MOBILE_TOP_BUTTON_HEIGHT, MOBILE_TOP_BUTTON_HEIGHT)

    version_label.size = Vector2(viewport_size.x, 34.0)
    version_label.position = Vector2(0.0, viewport_size.y - version_label.size.y - 32.0)
    version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    version_label.add_theme_font_size_override("font_size", MOBILE_META_FONT_SIZE)

    logo.custom_minimum_size = Vector2(0, 260)
    var btn_spacer = $CenterFrame / VBoxContainer / ButtonSpacer
    if is_instance_valid(btn_spacer):
        btn_spacer.custom_minimum_size.y = 20
    tagline_margin.add_theme_constant_override("margin_top", 0)
    tagline_margin.add_theme_constant_override("margin_bottom", -36)
    tagline_label.add_theme_font_size_override("font_size", MOBILE_BODY_FONT_SIZE - 6)
    tagline_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    start_button.add_theme_font_size_override("font_size", MOBILE_PRIMARY_BUTTON_FONT_SIZE)
    load_button.add_theme_font_size_override("font_size", MOBILE_SECONDARY_BUTTON_FONT_SIZE)
    dossier_button.add_theme_font_size_override("font_size", MOBILE_SECONDARY_BUTTON_FONT_SIZE)
    exit_button.add_theme_font_size_override("font_size", MOBILE_SECONDARY_BUTTON_FONT_SIZE)

    var button_width: float = clamp(content_width * 0.9, 620.0, 820.0)
    start_button.custom_minimum_size = Vector2(button_width, MOBILE_PRIMARY_BUTTON_HEIGHT)
    load_button.custom_minimum_size = Vector2(button_width, MOBILE_SECONDARY_BUTTON_HEIGHT)
    dossier_button.custom_minimum_size = Vector2(button_width, MOBILE_SECONDARY_BUTTON_HEIGHT)
    exit_button.custom_minimum_size = Vector2(button_width, MOBILE_SECONDARY_BUTTON_HEIGHT)
    start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    load_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    dossier_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    exit_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

    _position_atmosphere_emitters(viewport_size, center_frame.position, center_frame.size, true)


func _position_atmosphere_emitters(viewport_size: Vector2, content_position: Vector2, content_size: Vector2, mobile_portrait: bool) -> void :
    if is_instance_valid(smoke):
        if mobile_portrait:
            smoke.position = Vector2(content_position.x - 54.0, content_position.y + content_size.y * 0.44)
            smoke.emission_rect_extents = Vector2(maxf(56.0, content_size.x * 0.1), maxf(260.0, content_size.y * 0.54))
        else:
            smoke.position = Vector2(content_position.x - 72.0, content_position.y + content_size.y * 0.4)
            smoke.emission_rect_extents = Vector2(maxf(52.0, content_size.x * 0.08), maxf(220.0, content_size.y * 0.56))

    if is_instance_valid(sparks):
        if mobile_portrait:
            sparks.position = Vector2(viewport_size.x * 0.5, content_position.y + content_size.y * 0.82)
            sparks.emission_rect_extents = Vector2(maxf(220.0, content_size.x * 0.44), 32.0)
        else:
            sparks.position = Vector2(content_position.x + content_size.x * 0.52, content_position.y + content_size.y - 34.0)
            sparks.emission_rect_extents = Vector2(maxf(180.0, content_size.x * 0.48), 26.0)


func _setup_start_button_gradient() -> void :
    if not is_instance_valid(start_button_bg):
        start_button_bg = TextureRect.new()
        start_button_bg.name = "GradientBG"
        start_button_bg.show_behind_parent = true
        start_button_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
        start_button_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
        start_grad = Gradient.new()
        var tex: = GradientTexture1D.new()
        tex.gradient = start_grad
        start_button_bg.texture = tex
        start_button.add_child(start_button_bg)
    elif not is_instance_valid(start_grad):
        start_grad = Gradient.new()

    if not start_button.mouse_entered.is_connected(_update_start_button_gradient):
        start_button.mouse_entered.connect(_update_start_button_gradient)
    if not start_button.mouse_exited.is_connected(_update_start_button_gradient):
        start_button.mouse_exited.connect(_update_start_button_gradient)
    if not start_button.button_down.is_connected(_update_start_button_gradient):
        start_button.button_down.connect(_update_start_button_gradient)
    if not start_button.button_up.is_connected(_update_start_button_gradient):
        start_button.button_up.connect(_update_start_button_gradient)

    _update_start_button_gradient()


func _update_start_button_gradient() -> void :
    var left_color: Color
    var right_color: Color

    if start_button.button_pressed or start_button.is_pressed():
        left_color = Color(0.5, 0.36, 0.18, 0.96) if GameState.theme == "dark" else Color.html("#A88550F0")
        right_color = Color(0.36, 0.25, 0.11, 0.96) if GameState.theme == "dark" else Color.html("#6B4F26F0")
    elif start_button.is_hovered():
        left_color = Color(0.62, 0.46, 0.24, 0.94) if GameState.theme == "dark" else Color.html("#C59F66EB")
        right_color = Color(0.43, 0.3, 0.13, 0.94) if GameState.theme == "dark" else Color.html("#8C693AEB")
    else:
        left_color = Color(0.58, 0.43, 0.22, 0.92) if GameState.theme == "dark" else Color.html("#BA955CE6")
        right_color = Color(0.39, 0.27, 0.11, 0.92) if GameState.theme == "dark" else Color.html("#7C5C30E6")

    start_grad.set_color(0, left_color)
    start_grad.set_color(1, right_color)


func _add_particle_effects() -> void :
    if not is_instance_valid(atmosphere_layer):
        return
    atmosphere_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    for child in atmosphere_layer.get_children():
        child.queue_free()


    var p_tex = GradientTexture2D.new()
    p_tex.width = 32
    p_tex.height = 32
    p_tex.fill = GradientTexture2D.FILL_RADIAL
    p_tex.fill_from = Vector2(0.5, 0.5)
    p_tex.fill_to = Vector2(0.9, 0.5)
    var base_g = Gradient.new()
    base_g.set_color(0, Color.WHITE)
    base_g.set_color(1, Color(1, 1, 1, 0))
    p_tex.gradient = base_g


    var cloud_tex = _create_cloud_texture()

    smoke = CPUParticles2D.new()
    smoke.name = "SmokeEffect"
    smoke.texture = cloud_tex
    smoke.emitting = true
    smoke.amount = 28
    smoke.lifetime = 28.0
    smoke.preprocess = 28.0
    smoke.explosiveness = 0.0
    smoke.randomness = 1.0
    smoke.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE

    smoke.direction = Vector2(1, -0.05)
    smoke.spread = 18.0
    smoke.gravity = Vector2(1.5, -0.8)
    smoke.initial_velocity_min = 28.0
    smoke.initial_velocity_max = 66.0
    smoke.angular_velocity_min = -6.0
    smoke.angular_velocity_max = 6.0
    smoke.scale_amount_min = 5.0
    smoke.scale_amount_max = 12.0
    var smoke_curve = Curve.new()
    smoke_curve.add_point(Vector2(0, 0.4))
    smoke_curve.add_point(Vector2(0.5, 1.0))
    smoke_curve.add_point(Vector2(1, 1.2))
    smoke.scale_amount_curve = smoke_curve
    var smoke_grad = Gradient.new()

    smoke_grad.set_color(0, Color(0.28, 0.22, 0.14, 0.0))
    smoke_grad.add_point(0.28, Color(0.3, 0.23, 0.15, 0.035))
    smoke_grad.add_point(0.72, Color(0.18, 0.13, 0.08, 0.026))
    smoke_grad.set_color(3, Color(0.12, 0.08, 0.05, 0.0))
    smoke.color_ramp = smoke_grad

    sparks = CPUParticles2D.new()
    sparks.name = "SparksEffect"
    sparks.texture = p_tex
    sparks.emitting = true
    sparks.amount = 95
    sparks.lifetime = 10.0
    sparks.preprocess = 10.0
    sparks.explosiveness = 0.0
    sparks.randomness = 0.72
    sparks.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
    sparks.direction = Vector2(0.24, -1)
    sparks.spread = 96.0
    sparks.gravity = Vector2(2, -12)
    sparks.initial_velocity_min = 18.0
    sparks.initial_velocity_max = 58.0
    sparks.scale_amount_min = 0.08
    sparks.scale_amount_max = 0.3
    var color_grad = Gradient.new()
    color_grad.set_color(0, Color(1.0, 0.9, 0.4, 0.0))
    color_grad.add_point(0.12, Color(1.0, 0.82, 0.32, 0.12))
    color_grad.add_point(0.68, Color(0.95, 0.55, 0.18, 0.07))
    color_grad.set_color(3, Color(0.8, 0.1, 0.0, 0.0))
    sparks.color_ramp = color_grad


    var mat = CanvasItemMaterial.new()
    mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
    sparks.material = mat


    atmosphere_layer.add_child(smoke)
    atmosphere_layer.add_child(sparks)
    _position_atmosphere_emitters(size if size != Vector2.ZERO else get_viewport_rect().size, center_frame.position, center_frame.size, _is_mobile_portrait())


func _create_cloud_texture() -> ImageTexture:
    var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
    var noise = FastNoiseLite.new()
    noise.seed = 1024
    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    noise.frequency = 0.04

    for y in range(64):
        for x in range(64):
            var dist = Vector2(32, 32).distance_to(Vector2(x, y))
            if dist > 31.0:
                img.set_pixel(x, y, Color(1, 1, 1, 0))
            else:
                var n = (noise.get_noise_2d(x, y) + 1.0) * 0.5
                n = smoothstep(0.2, 0.8, n)
                var falloff = 1.0 - (dist / 31.0)
                falloff = falloff * falloff
                img.set_pixel(x, y, Color(1, 1, 1, n * falloff))

    return ImageTexture.create_from_image(img)
