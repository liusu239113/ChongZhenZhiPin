extends Control

signal play_again
signal back_to_choices
signal biography_requested

var back_button: Button = null

const Presenter = preload("res://scripts/ui/game_screen_presenter.gd")
const EffectsServiceRef = preload("res://scripts/services/effects_service.gd")
const ScrollbarThemeRef = preload("res://scripts/ui/scrollbar_theme.gd")
const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const NativeMobileTouchScrollRef = preload("res://scripts/ui/native_mobile_touch_scroll.gd")
const FontLoader = preload("res://scripts/ui/font_loader.gd")
const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")

const MOBILE_PORTRAIT_MAX_WIDTH: = 900.0
const MOBILE_PANEL_WIDTH_RATIO: = 0.94
const MOBILE_PANEL_HEIGHT_RATIO: = 0.88
const MOBILE_TITLE_FONT_SIZE: = 70
const MOBILE_EMOTION_FONT_SIZE: = 36
const MOBILE_BODY_FONT_SIZE: = 43
const MOBILE_COMMENT_FONT_SIZE: = 41
const MOBILE_STATS_TITLE_FONT_SIZE: = 37
const MOBILE_CHIP_FONT_SIZE: = 32
const MOBILE_BUTTON_FONT_SIZE: = 36
const MOBILE_BUTTON_WIDTH: = 448.0
const MOBILE_BUTTON_HEIGHT: = 115.0
const MOBILE_HEADER_BODY_GAP: = 64.0
const MOBILE_STAT_CHIP_MIN_WIDTH: = 132.0
const MOBILE_TAG_CHIP_MIN_WIDTH: = 168.0
const DESKTOP_STAT_CHIP_MIN_WIDTH: = 64.0
const DESKTOP_TAG_CHIP_MIN_WIDTH: = 96.0
const DESKTOP_CHIP_HEIGHT: = 42.0
const ENDING_BG_TEXTURE_ALPHA_DARK: = 0.24
const ENDING_BG_TEXTURE_ALPHA_LIGHT: = 0.1

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var background: ColorRect = $Background
@onready var bg_texture: TextureRect = $BgTexture
@onready var badge_label: Label = $ScrollContainer / VBox / EndingBadge
@onready var title_label: Label = $ScrollContainer / VBox / EndingTitle
@onready var emotion_label: Label = $ScrollContainer / VBox / EndingEmotion
@onready var header_body_gap: Control = $ScrollContainer / VBox / HeaderBodyGap
@onready var narrative_label: Label = $ScrollContainer / VBox / EndingNarrative
@onready var comment_gap_top: Control = $ScrollContainer / VBox / CommentGapTop
@onready var comment_label: Label = $ScrollContainer / VBox / EndingCommentLabel
@onready var comment_body: Label = $ScrollContainer / VBox / EndingComment
@onready var comment_gap_bottom: Control = $ScrollContainer / VBox / CommentGapBottom
@onready var stats_title: Label = $ScrollContainer / VBox / StatsTitle
@onready var stats_container: HFlowContainer = $ScrollContainer / VBox / StatsContainer
@onready var tags_title: Label = $ScrollContainer / VBox / TagsTitle
@onready var tags_container: HFlowContainer = $ScrollContainer / VBox / TagsContainer
@onready var action_buttons: HBoxContainer = $ScrollContainer / VBox / ActionButtons
@onready var biography_button: Button = $ScrollContainer / VBox / ActionButtons / BiographyButton
@onready var play_again_button: Button = $ScrollContainer / VBox / ActionButtons / PlayAgainButton
var scroll_touch_drag_suppress_until_ms: int = 0
var current_ending: Dictionary = {}
var showing_kuixing_reward: bool = false
var showing_biography: bool = false

func _ready() -> void :
    biography_button.mouse_filter = Control.MOUSE_FILTER_PASS
    biography_button.gui_input.connect(_on_scroll_touch_drag)
    biography_button.pressed.connect(_on_biography_pressed)
    play_again_button.mouse_filter = Control.MOUSE_FILTER_PASS
    play_again_button.gui_input.connect(_on_scroll_touch_drag)
    play_again_button.pressed.connect(_on_play_again_pressed)
    ScrollbarThemeRef.apply_to(scroll_container)
    resized.connect(_apply_responsive_layout)
    _apply_serif_fonts()
    _apply_theme()
    _apply_responsive_layout()
    _apply_native_mobile_font_scale()

func _apply_serif_fonts() -> void :
    var font_body: = FontLoader.body()
    var font_serif_bold: = FontLoader.serif_bold()


    var bold_labels: = [
        title_label, 
        comment_label, 
        stats_title, 
        tags_title, 
    ]
    for label in bold_labels:
        if is_instance_valid(label):
            label.add_theme_font_override("font", font_serif_bold)


    var body_labels: = [
        badge_label, 
        emotion_label, 
        narrative_label, 
        comment_body, 
    ]
    for label in body_labels:
        if is_instance_valid(label):
            label.add_theme_font_override("font", font_body)

    if is_instance_valid(play_again_button):
        play_again_button.add_theme_font_override("font", font_body)
    if is_instance_valid(biography_button):
        biography_button.add_theme_font_override("font", font_body)

func _apply_theme() -> void :


    background.color = Color(0.02, 0.015, 0.015, 1.0) if GameState.theme == "dark" else Color.html("E0E2E6")
    if is_instance_valid(bg_texture):
        bg_texture.modulate.a = ENDING_BG_TEXTURE_ALPHA_DARK if GameState.theme == "dark" else ENDING_BG_TEXTURE_ALPHA_LIGHT


    var grad_container = get_node_or_null("GradientContainer")
    if is_instance_valid(grad_container):
        grad_container.queue_free()
        grad_container = null

    if GameState.theme == "dark":
        grad_container = Control.new()
        grad_container.name = "GradientContainer"
        grad_container.set_anchors_preset(Control.PRESET_FULL_RECT)
        grad_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(grad_container)
        move_child(grad_container, 2)


        var gradient_bg = _make_ending_background_gradient()
        grad_container.add_child(gradient_bg)


        var glow1 = _make_ending_orange_glow(Vector2(0.15, 0.85), Vector2(0.65, 0.35), Color(0.2, 0.07, 0.02, 0.48))
        grad_container.add_child(glow1)


        var glow2 = _make_ending_orange_glow(Vector2(0.85, 0.15), Vector2(0.4, 0.6), Color(0.18, 0.06, 0.018, 0.42))
        grad_container.add_child(glow2)

    var active_color: = GameState.get_theme_color("border_active")

    var heading_color: = active_color if GameState.theme == "dark" else Color(0.48, 0.34, 0.12, 1.0)
    title_label.add_theme_color_override("font_color", heading_color)
    title_label.add_theme_constant_override("outline_size", 1)
    title_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.72) if GameState.theme == "dark" else Color(0.82, 0.76, 0.63, 0.18))

    if is_instance_valid(badge_label):
        badge_label.add_theme_color_override("font_color", heading_color)
        var badge_style: = StyleBoxFlat.new()
        badge_style.bg_color = Color(heading_color.r, heading_color.g, heading_color.b, 0.08)
        badge_style.draw_center = true
        badge_style.border_width_left = 1
        badge_style.border_width_top = 1
        badge_style.border_width_right = 1
        badge_style.border_width_bottom = 1
        badge_style.border_color = Color(heading_color.r, heading_color.g, heading_color.b, 0.35)

        var mobile_portrait: = _is_mobile_portrait()
        var corner_radius = 20 if mobile_portrait else 13
        badge_style.corner_radius_top_left = corner_radius
        badge_style.corner_radius_top_right = corner_radius
        badge_style.corner_radius_bottom_left = corner_radius
        badge_style.corner_radius_bottom_right = corner_radius

        badge_style.content_margin_left = 16 if mobile_portrait else 12
        badge_style.content_margin_right = 16 if mobile_portrait else 12
        badge_style.content_margin_top = 6 if mobile_portrait else 4
        badge_style.content_margin_bottom = 6 if mobile_portrait else 4

        badge_label.add_theme_stylebox_override("normal", badge_style)
    emotion_label.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    narrative_label.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    comment_label.text = "— 终局批语 —"
    comment_label.add_theme_color_override("font_color", Color(0.72, 0.3, 0.24, 0.88) if GameState.theme == "dark" else Color(0.5, 0.32, 0.18, 1))
    comment_body.add_theme_color_override("font_color", GameState.get_theme_color("text_sub") if GameState.theme == "dark" else Color(0.3, 0.25, 0.18, 0.95))
    var section_title_color: = GameState.get_theme_color("border") if GameState.theme == "dark" else Color(0.42, 0.32, 0.14, 0.95)
    stats_title.add_theme_color_override("font_color", section_title_color)
    tags_title.add_theme_color_override("font_color", section_title_color)
    GameScreenStyleFactory.apply_command_button_style(biography_button, "secondary", 18, 10)
    GameScreenStyleFactory.apply_command_button_style(play_again_button, "primary", 18, 10)
    _apply_responsive_layout()

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
    return false
func _is_native_phone_landscape() -> bool:
    return NativeMobileFontScalerRef.is_native_phone_landscape(self)

func _apply_responsive_layout() -> void :
    if not is_instance_valid(scroll_container):
        return
    var viewport_size: = get_viewport_rect().size
    var mobile_portrait: = _is_mobile_portrait()
    var phone_landscape: = _is_native_phone_landscape()



    var panel_height: = clampf(viewport_size.y * 0.9, 0.5 * viewport_size.y + 280.0, viewport_size.y)
    var panel_size: = Vector2(
        clampf(viewport_size.x * MOBILE_PANEL_WIDTH_RATIO, 300.0, 1800.0), 
        clampf(viewport_size.y * MOBILE_PANEL_HEIGHT_RATIO, 600.0, 2400.0)
    ) if mobile_portrait else Vector2(900.0 if phone_landscape else 700.0, panel_height)

    scroll_container.offset_left = - panel_size.x * 0.5
    scroll_container.offset_right = panel_size.x * 0.5
    scroll_container.offset_top = - panel_size.y * 0.5
    scroll_container.offset_bottom = panel_size.y * 0.5

    var vbox = $ScrollContainer / VBox
    vbox.custom_minimum_size.x = panel_size.x - 16

    if is_instance_valid(badge_label):
        badge_label.add_theme_font_size_override("font_size", 24 if mobile_portrait else 13)
    title_label.add_theme_font_size_override("font_size", MOBILE_TITLE_FONT_SIZE if mobile_portrait else 36)
    emotion_label.add_theme_font_size_override("font_size", MOBILE_EMOTION_FONT_SIZE if mobile_portrait else 14)
    narrative_label.add_theme_font_size_override("font_size", MOBILE_BODY_FONT_SIZE if mobile_portrait else (20 if phone_landscape else 16))
    narrative_label.add_theme_constant_override("line_spacing", 12 if mobile_portrait else 8)
    narrative_label.custom_minimum_size.x = 10
    narrative_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    narrative_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

    comment_label.add_theme_font_size_override("font_size", MOBILE_COMMENT_FONT_SIZE if mobile_portrait else (18 if phone_landscape else 14))
    comment_body.add_theme_font_size_override("font_size", MOBILE_COMMENT_FONT_SIZE if mobile_portrait else (18 if phone_landscape else 14))
    comment_body.add_theme_constant_override("line_spacing", 10 if mobile_portrait else 6)
    comment_body.custom_minimum_size.x = 10
    comment_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    comment_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

    if is_instance_valid(comment_gap_top):
        comment_gap_top.custom_minimum_size = Vector2(0, 48.0 if mobile_portrait else 24.0)
    if is_instance_valid(comment_gap_bottom):
        comment_gap_bottom.custom_minimum_size = Vector2(0, 48.0 if mobile_portrait else 24.0)


    title_label.custom_minimum_size.x = 10
    title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    emotion_label.custom_minimum_size.x = 10
    emotion_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    header_body_gap.custom_minimum_size = Vector2(0, MOBILE_HEADER_BODY_GAP if mobile_portrait else 0)

    stats_title.add_theme_font_size_override("font_size", MOBILE_STATS_TITLE_FONT_SIZE if mobile_portrait else 14)
    tags_title.add_theme_font_size_override("font_size", MOBILE_STATS_TITLE_FONT_SIZE if mobile_portrait else 14)
    var button_size: = Vector2(MOBILE_BUTTON_WIDTH, MOBILE_BUTTON_HEIGHT) if mobile_portrait else Vector2(200, 50)

    var play_again_size: = Vector2(MOBILE_BUTTON_WIDTH * 1.18, MOBILE_BUTTON_HEIGHT) if mobile_portrait else Vector2(264, 50)
    play_again_button.custom_minimum_size = play_again_size
    play_again_button.add_theme_font_size_override("font_size", MOBILE_BUTTON_FONT_SIZE if mobile_portrait else 20)
    biography_button.custom_minimum_size = button_size
    biography_button.add_theme_font_size_override("font_size", MOBILE_BUTTON_FONT_SIZE if mobile_portrait else 20)
    action_buttons.add_theme_constant_override("separation", 20 if mobile_portrait else 14)
    action_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
    if is_instance_valid(back_button) and back_button.visible:
        back_button.custom_minimum_size = button_size
        back_button.add_theme_font_size_override("font_size", MOBILE_BUTTON_FONT_SIZE if mobile_portrait else 20)
    _apply_native_mobile_font_scale()

func show_ending(ending: Dictionary) -> void :
    current_ending = ending.duplicate(true)
    _apply_city_placeholders(current_ending)
    showing_kuixing_reward = false
    showing_biography = false
    _apply_theme()
    play_again_button.text = "重新来过"
    biography_button.text = "查看生平小传"
    biography_button.icon = null
    biography_button.visible = false

    var ending_id: = ""
    var sm = get_node_or_null("/root/SaveManager")
    if sm:
        ending_id = sm.resolve_ending_id(current_ending)
    else:
        if current_ending.has("id"):
            ending_id = current_ending["id"]

    if ending_id in ["jingguan_ending_yijia", "jingguan_ending_erjia", "jingguan_ending_sanjia_datong"]:
        if not is_instance_valid(back_button):
            back_button = Button.new()
            back_button.name = "BackToChoicesButton"
            back_button.mouse_filter = Control.MOUSE_FILTER_PASS
            back_button.gui_input.connect(_on_scroll_touch_drag)
            back_button.pressed.connect( func():
                back_to_choices.emit()
            )
            action_buttons.add_child(back_button)

            var font_body: = FontLoader.body()
            back_button.add_theme_font_override("font", font_body)
            back_button.add_theme_stylebox_override("normal", _make_button_style(false))
            back_button.add_theme_stylebox_override("hover", _make_button_style(true))
            back_button.add_theme_stylebox_override("pressed", _make_button_style(true, true))
            back_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

            var main_color = GameState.get_theme_color("text_main")
            var hov_color = Color(0.98, 0.93, 0.82, 1.0)
            back_button.add_theme_color_override("font_color", main_color)
            back_button.add_theme_color_override("font_hover_color", hov_color)
            back_button.add_theme_color_override("font_pressed_color", hov_color)
            back_button.add_theme_color_override("icon_normal_color", main_color)
            back_button.add_theme_color_override("icon_hover_color", hov_color)
            back_button.add_theme_color_override("icon_pressed_color", hov_color)
            back_button.add_theme_color_override("icon_focus_color", hov_color)
            back_button.icon = load("res://assets/ui/back.svg")
            back_button.expand_icon = false
            back_button.add_theme_constant_override("h_separation", 6)

        back_button.visible = true
        back_button.text = "返回选择"

        var mobile_portrait: = _is_mobile_portrait()
        back_button.custom_minimum_size = Vector2(MOBILE_BUTTON_WIDTH, MOBILE_BUTTON_HEIGHT) if mobile_portrait else Vector2(200, 50)
        back_button.add_theme_font_size_override("font_size", MOBILE_BUTTON_FONT_SIZE if mobile_portrait else 20)
        back_button.add_theme_constant_override("icon_max_width", MOBILE_BUTTON_FONT_SIZE if mobile_portrait else 20)
    else:
        if is_instance_valid(back_button):
            back_button.visible = false
    stats_title.visible = true
    stats_container.visible = true
    if is_instance_valid(badge_label):
        badge_label.visible = true
        badge_label.text = current_ending.get("badge", "终 局")
    title_label.text = current_ending.get("title", "")
    narrative_label.text = current_ending.get("narrative", "")
    emotion_label.text = current_ending.get("emotion", "")


    await get_tree().process_frame
    $ScrollContainer.scroll_vertical = 0

    var comment_text = current_ending.get("comment", "")
    if comment_text != "":
        comment_label.visible = true
        comment_body.visible = true
        comment_body.text = comment_text
        if is_instance_valid(comment_gap_top):
            comment_gap_top.visible = true
        if is_instance_valid(comment_gap_bottom):
            comment_gap_bottom.visible = true
    else:
        comment_label.visible = false
        comment_body.visible = false
        if is_instance_valid(comment_gap_top):
            comment_gap_top.visible = false
        if is_instance_valid(comment_gap_bottom):
            comment_gap_bottom.visible = false


    if GameState.play_mode == "free":
        var reborn: = SaveManager.get_rebirth_points()
        var note: = "◈ 轮回 · 第 %d 世 —— 历劫归来，来世根骨愈壮：下一局开局四维与私银微增（各维至多 +3）。" % reborn
        comment_body.text = (comment_text + "\n\n" + note) if comment_text != "" else note
        comment_body.visible = true
        comment_label.visible = true
        if is_instance_valid(comment_gap_top):
            comment_gap_top.visible = true
        if is_instance_valid(comment_gap_bottom):
            comment_gap_bottom.visible = true


    Presenter._clear_children(stats_container)
    Presenter._clear_children(tags_container)


    var create_chip = func(text: String, is_tag: bool = false, is_alert: bool = false):
        var chip = Label.new()
        var mobile_portrait: = _is_mobile_portrait()
        chip.text = text
        chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        chip.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        chip.autowrap_mode = TextServer.AUTOWRAP_OFF
        chip.clip_text = false
        chip.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
        var chip_font_size: = MOBILE_CHIP_FONT_SIZE if mobile_portrait else 12
        chip.add_theme_font_size_override("font_size", MOBILE_CHIP_FONT_SIZE if _is_mobile_portrait() else 12)
        chip.add_theme_font_override("font", FontLoader.body())
        var estimated_text_width: = float(text.length()) * float(chip_font_size) * 1.15 + 48.0
        if mobile_portrait:
            var min_width: = MOBILE_TAG_CHIP_MIN_WIDTH if is_tag else MOBILE_STAT_CHIP_MIN_WIDTH
            chip.custom_minimum_size = Vector2(maxf(float(min_width), estimated_text_width), 54.0)
        else:
            var min_width: = DESKTOP_TAG_CHIP_MIN_WIDTH if is_tag else DESKTOP_STAT_CHIP_MIN_WIDTH
            chip.custom_minimum_size = Vector2(maxf(min_width, estimated_text_width), DESKTOP_CHIP_HEIGHT)
        var style = _make_chip_style(is_tag)

        if is_alert:
            chip.add_theme_color_override("font_color", Color(0.92, 0.28, 0.22, 1.0) if GameState.theme == "dark" else Color(0.78, 0.12, 0.08, 1.0))
        else:
            chip.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))

        chip.add_theme_stylebox_override("normal", style)
        if is_tag:
            tags_container.add_child(chip)
        else:
            stats_container.add_child(chip)


    for key in GameData.STAT_KEYS:
        if key == "private_silver" or key == "renmai":
            continue
        if GameState.stats.has(key):
            create_chip.call(GameData.STAT_LABELS.get(key, key) + " " + str(int(GameState.stats[key])), false)


    for key in GameData.ATT_KEYS:
        if GameState.attitudes.has(key):
            var attitude_value: = int(GameState.attitudes[key])
            create_chip.call(GameData.ATT_LABELS.get(key, key) + " " + str(attitude_value), false, attitude_value <= 0)


    if not GameState.tags.is_empty():
        var tag_counts: = {}
        var tag_order: Array[String] = []
        for tag in GameState.tags:
            var normalized_tag: = EffectsServiceRef.normalize_tag_name(tag)
            if not Presenter.should_show_tag(normalized_tag):
                continue
            if not tag_counts.has(normalized_tag):
                tag_counts[normalized_tag] = 0
                tag_order.append(normalized_tag)
            tag_counts[normalized_tag] = int(tag_counts[normalized_tag]) + 1
        for tag in tag_order:
            var count: = int(tag_counts.get(tag, 0))
            var tag_text: = tag
            if count > 1:
                tag_text = "%s × %d" % [tag, count]
            create_chip.call(tag_text, true)
    tags_title.visible = tags_container.get_child_count() > 0
    tags_container.visible = tags_container.get_child_count() > 0


    create_chip.call("私银 " + str(int(GameState.private_silver)), false)
    _apply_native_mobile_font_scale()

func show_biography(text: String) -> void :
    showing_biography = true
    showing_kuixing_reward = false
    _apply_theme()
    if is_instance_valid(badge_label):
        badge_label.visible = true
        badge_label.text = "生平小传"
    title_label.text = current_ending.get("title", "")
    emotion_label.text = "一生行迹"
    narrative_label.text = text
    comment_label.visible = false
    comment_body.visible = false
    if is_instance_valid(comment_gap_top):
        comment_gap_top.visible = false
    if is_instance_valid(comment_gap_bottom):
        comment_gap_bottom.visible = false
    Presenter._clear_children(stats_container)
    Presenter._clear_children(tags_container)
    stats_title.visible = false
    stats_container.visible = false
    tags_title.visible = false
    tags_container.visible = false
    if is_instance_valid(back_button):
        back_button.visible = false
    biography_button.visible = true
    biography_button.text = "返回结局"
    biography_button.icon = load("res://assets/ui/back.svg")
    biography_button.expand_icon = false
    biography_button.add_theme_constant_override("h_separation", 6)
    _style_action_button(biography_button)
    var mobile_portrait: = _is_mobile_portrait()
    biography_button.add_theme_constant_override("icon_max_width", MOBILE_BUTTON_FONT_SIZE if mobile_portrait else 20)
    play_again_button.text = "重新来过"
    _apply_native_mobile_font_scale()

    await get_tree().process_frame
    $ScrollContainer.scroll_vertical = 0

func _apply_city_placeholders(data: Dictionary) -> void :
    var replacements: = {}
    var current_city: String = GameState.get_current_city_name()
    if current_city != "":
        replacements["{current_city}"] = current_city
        var city_under: = "辖下各乡"
        if current_city.ends_with("府"):
            city_under = "辖下十余县"
        elif current_city.ends_with("州"):
            city_under = "下辖各县"
        replacements["{city_under}"] = city_under
    else:
        replacements["{current_city}"] = "蓬莱县"
        replacements["{city_under}"] = "辖下各乡"

    var office_title: = GameState.get_office_title() if GameState.has_method("get_office_title") else GameState.get_rank_title()
    var office_juris: = GameState.get_office_juris_from_rank_title() if GameState.has_method("get_office_juris_from_rank_title") else ""
    if office_title != "" and office_title != "未知":
        replacements["{official_title}"] = office_title
        replacements["{office_title}"] = office_title
        replacements["{office_short}"] = office_title
    else:
        replacements["{official_title}"] = "知县"
        replacements["{office_title}"] = "知县"
        replacements["{office_short}"] = "知县"

    if office_juris != "":
        replacements["{office_juris}"] = office_juris
        replacements["{office_scope}"] = office_juris
    else:
        replacements["{office_juris}"] = "县"
        replacements["{office_scope}"] = "县"

    for act_idx in range(1, 7):
        var act_key: = str(act_idx)
        var city_cfg: Dictionary = GameState.resolve_transfer_city_for_act(act_key, GameState.get_rank_title())
        var city_name: = str(city_cfg.get("name", ""))
        if city_name == "":
            var default_names = {
                "1": "蓬莱县", 
                "2": "蒲州", 
                "3": "真定府", 
                "4": "襄阳府", 
                "5": "河西道", 
                "6": "济南府"
            }
            city_name = default_names.get(act_key, "")
        if city_name != "":
            replacements["{city_%s}" % act_key] = city_name
    if replacements.is_empty():
        return
    _apply_city_placeholders_to_dictionary(data, replacements)

func _apply_city_placeholders_to_dictionary(data: Dictionary, replacements: Dictionary) -> void :
    for key in data.keys():
        var value = data[key]
        if value is String:
            data[key] = _replace_city_placeholders(value, replacements)
        elif value is Dictionary:
            _apply_city_placeholders_to_dictionary(value, replacements)
        elif value is Array:
            _apply_city_placeholders_to_array(value, replacements)

func _apply_city_placeholders_to_array(data: Array, replacements: Dictionary) -> void :
    for idx in range(data.size()):
        var value = data[idx]
        if value is String:
            data[idx] = _replace_city_placeholders(value, replacements)
        elif value is Dictionary:
            _apply_city_placeholders_to_dictionary(value, replacements)
        elif value is Array:
            _apply_city_placeholders_to_array(value, replacements)

func _replace_city_placeholders(text: String, replacements: Dictionary) -> String:
    var result: = text
    for placeholder in replacements:
        result = result.replace(str(placeholder), str(replacements[placeholder]))
    return result

func _show_kuixing_reward(reward: Dictionary) -> void :
    showing_kuixing_reward = true
    _apply_theme()
    if is_instance_valid(badge_label):
        badge_label.visible = true
        badge_label.text = "获得道具"
    title_label.text = "魁星符"
    emotion_label.text = "道具获得"
    narrative_label.text = "科举不易，寒门尤其不易。别人赶考带的是书童、盘缠与座师门路，你带着半截蜡烛、一方旧砚，还有家里从牙缝里省出来的几串钱。保结要人作保，号舍要身子硬撑，红榜前还要一次次把名字从头看到尾。\n\n你的科举进取之心已上达苍穹，案头忽多一纸朱符。纸边微卷，墨迹却新，上书八字：魁星点斗，独占鳌头。\n\n已获得魁星符一张。愿魁星点斗、文曲垂光，护你下一回入场落笔，一举夺魁。"
    comment_label.visible = true
    comment_body.visible = true
    comment_label.text = "— 道具说明 —"
    if is_instance_valid(comment_gap_top):
        comment_gap_top.visible = true
    if is_instance_valid(comment_gap_bottom):
        comment_gap_bottom.visible = true
    var item_def: Dictionary = GameData.ITEM_DEFS.get(str(reward.get("item_id", "kuixing_fu")), {})
    var desc: = str(item_def.get("desc", "可随身携带的魁星符箓，上面写的是「魁星点斗，独占鳌头」，挂在书袋床头等处皆可。\n[效果：文韬 +1]"))
    comment_body.text = "%s\n\n当前持有：%d / %d" % [
        desc, 
        int(reward.get("count", 0)), 
        int(reward.get("max_count", SaveManager.KUIXING_FU_MAX_COUNT)), 
    ]

    Presenter._clear_children(stats_container)
    Presenter._clear_children(tags_container)
    stats_title.visible = false
    stats_container.visible = false
    tags_title.visible = false
    tags_container.visible = false
    biography_button.visible = false
    play_again_button.text = "收下符箓"
    _apply_native_mobile_font_scale()

    await get_tree().process_frame
    $ScrollContainer.scroll_vertical = 0

func _apply_native_mobile_font_scale() -> void :
    NativeMobileFontScalerRef.apply_to(self)


func _on_scroll_touch_drag(event: InputEvent) -> void :
    NativeMobileTouchScrollRef.forward_drag_to_scroll(event, scroll_container, self, "scroll_touch_drag_suppress_until_ms")


func _on_play_again_pressed() -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(self, "scroll_touch_drag_suppress_until_ms"):
        return
    if not showing_kuixing_reward:
        var reward: = SaveManager.claim_kuixing_reward_for_ending(current_ending)
        if not reward.is_empty():
            _show_kuixing_reward(reward)
            return
    play_again.emit()

func _on_biography_pressed() -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(self, "scroll_touch_drag_suppress_until_ms"):
        return
    if showing_biography:
        show_ending(current_ending)
        return
    if showing_kuixing_reward:
        return
    biography_requested.emit()

func _style_action_button(button: Button) -> void :
    if not is_instance_valid(button):
        return
    button.add_theme_stylebox_override("normal", _make_button_style(false))
    button.add_theme_stylebox_override("hover", _make_button_style(true))
    button.add_theme_stylebox_override("pressed", _make_button_style(true, true))
    button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    var main_color = GameState.get_theme_color("text_main")
    var hov_color = Color(0.98, 0.93, 0.82, 1.0)
    button.add_theme_color_override("font_color", main_color)
    button.add_theme_color_override("font_hover_color", hov_color)
    button.add_theme_color_override("font_pressed_color", hov_color)
    button.add_theme_color_override("icon_normal_color", main_color)
    button.add_theme_color_override("icon_hover_color", hov_color)
    button.add_theme_color_override("icon_pressed_color", hov_color)
    button.add_theme_color_override("icon_focus_color", hov_color)

func _style_play_again_button(button: Button) -> void :
    if not is_instance_valid(button):
        return

    button.add_theme_stylebox_override("normal", _make_play_again_style(false))
    button.add_theme_stylebox_override("hover", _make_play_again_style(true))
    button.add_theme_stylebox_override("pressed", _make_play_again_style(true, true))
    button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    var label_color: = Color(0.98, 0.95, 0.88, 1.0)
    button.add_theme_color_override("font_color", label_color)
    button.add_theme_color_override("font_hover_color", Color(1.0, 0.99, 0.95, 1.0))
    button.add_theme_color_override("font_pressed_color", label_color)

func _make_play_again_style(hovered: bool, pressed: bool = false) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()

    var base: = Color(0.5, 0.35, 0.1, 1.0) if GameState.theme == "dark" else Color(0.52, 0.36, 0.11, 1.0)
    if pressed:
        base = base.darkened(0.18)
    elif hovered:
        base = base.darkened(0.08)
    style.bg_color = base
    style.corner_radius_top_left = 4
    style.corner_radius_top_right = 4
    style.corner_radius_bottom_left = 4
    style.corner_radius_bottom_right = 4
    style.content_margin_left = 18
    style.content_margin_right = 18
    style.content_margin_top = 10
    style.content_margin_bottom = 10

    style.shadow_size = 0
    return style

func _make_chip_style(is_tag: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    var mobile_portrait: = _is_mobile_portrait()
    style.bg_color = Color(0.07, 0.055, 0.038, 0.88) if GameState.theme == "dark" else Color(1.0, 1.0, 1.0, 1.0)

    var chip_border: = 0 if GameState.theme == "light" else 1
    style.border_width_left = chip_border
    style.border_width_top = chip_border
    style.border_width_right = chip_border
    style.border_width_bottom = chip_border
    style.border_color = Color(0.78, 0.61, 0.32, 0.52)
    style.content_margin_left = 14 if mobile_portrait else 10
    style.content_margin_right = 14 if mobile_portrait else 10
    style.content_margin_top = 8 if mobile_portrait else 5
    style.content_margin_bottom = 8 if mobile_portrait else 5
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    return style

func _make_button_style(hovered: bool, pressed: bool = false) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = GameState.get_theme_color("choice_press" if pressed else ("choice_hover" if hovered else "choice_normal"))
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = GameState.get_theme_color("border_active" if hovered or pressed else "border")
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    style.content_margin_left = 18
    style.content_margin_right = 18
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    style.shadow_size = 8 if GameState.theme == "dark" else 2
    style.shadow_color = Color(0, 0, 0, 0.28 if GameState.theme == "dark" else 0.08)
    return style

func _make_ending_background_gradient() -> TextureRect:
    var gradient_rect: = TextureRect.new()
    gradient_rect.name = "EndingBlackGradient"
    gradient_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    gradient_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    gradient_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    gradient_rect.stretch_mode = TextureRect.STRETCH_SCALE

    var grad: = Gradient.new()

    grad.set_color(0, Color(0.0, 0.0, 0.0, 0.1))
    grad.set_color(1, Color(0.0, 0.0, 0.0, 0.88))

    grad.add_point(0.42, Color(0.0, 0.0, 0.0, 0.36))
    grad.add_point(0.78, Color(0.0, 0.0, 0.0, 0.7))

    var tex: = GradientTexture2D.new()
    tex.gradient = grad
    tex.fill_from = Vector2(0.5, 0.0)
    tex.fill_to = Vector2(0.5, 1.0)
    tex.width = 64
    tex.height = 512
    gradient_rect.texture = tex
    return gradient_rect

func _make_ending_orange_glow(center: Vector2, radius_to: Vector2, color: Color) -> TextureRect:
    var glow_rect: = TextureRect.new()
    glow_rect.name = "EndingOrangeGlow_" + str(center.x).replace(".", "_") + "_" + str(center.y).replace(".", "_")
    glow_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    glow_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    glow_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    glow_rect.stretch_mode = TextureRect.STRETCH_SCALE

    var grad: = Gradient.new()

    grad.set_color(0, color)
    grad.set_color(1, Color(0.0, 0.0, 0.0, 0.0))

    grad.add_point(0.5, Color(color.r * 0.4, color.g * 0.4, color.b * 0.4, color.a * 0.4))

    var tex: = GradientTexture2D.new()
    tex.gradient = grad
    tex.fill = GradientTexture2D.FILL_RADIAL
    tex.fill_from = center
    tex.fill_to = radius_to
    tex.width = 256
    tex.height = 256
    glow_rect.texture = tex
    return glow_rect
