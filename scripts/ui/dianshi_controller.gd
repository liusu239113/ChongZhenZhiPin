extends RefCounted













const FontLoader = preload("res://scripts/ui/font_loader.gd")
const ScrollbarThemeRef = preload("res://scripts/ui/scrollbar_theme.gd")
const GrainTexture = preload("res://scripts/ui/grain_texture.gd")
const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")

var _host

func _init(host) -> void :
    _host = host

func _get_dianshi_strategy_modal_height(viewport_height: float, mobile_portrait: bool) -> float:
    if mobile_portrait:
        return floorf(viewport_height * _host.DIANSHI_STRATEGY_MODAL_MOBILE_HEIGHT_RATIO)
    return floorf(viewport_height * _host.DIANSHI_STRATEGY_MODAL_DESKTOP_HEIGHT_RATIO)

func _resolve_dianshi_rank_from_pass_count(passed_count: int, first_rank_roll: bool) -> String:
    if first_rank_roll:
        if passed_count >= 4:
            return "yijia"
        if passed_count >= 3:
            return "erjia"
        return "sanjia"

    if passed_count >= 4:
        return "zhuangyuan"
    if passed_count >= 3:
        return "bangyan"
    return "tanhua"

func _make_dianshi_card_style(border_color: Color = Color(0.31, 0.33, 0.35, 0.85), bg_alpha: float = 1.0) -> StyleBoxFlat:
    var card_style = StyleBoxFlat.new()
    if _host._choice_card_uses_light_dark_style():
        card_style.bg_color = _host._choice_card_bg_color(false, false, false)
    elif GameState.theme == "light":
        card_style.bg_color = GameState.get_theme_color("choice_normal")
    else:
        card_style.bg_color = Color(0.088, 0.094, 0.102, bg_alpha)
    card_style.border_width_left = 1;card_style.border_width_right = 1
    card_style.border_width_top = 1;card_style.border_width_bottom = 1
    if _host._choice_card_uses_light_dark_style():
        card_style.border_color = Color(1, 1, 1, 0.3)
    else:
        card_style.border_color = border_color
    card_style.corner_radius_top_left = 2;card_style.corner_radius_top_right = 2
    card_style.corner_radius_bottom_left = 2;card_style.corner_radius_bottom_right = 2
    card_style.content_margin_left = 11
    card_style.content_margin_right = 11
    card_style.content_margin_top = 12
    card_style.content_margin_bottom = 11
    card_style.shadow_size = 0 if GameState.theme == "light" else 4
    card_style.shadow_color = Color(0, 0, 0, 0.0 if GameState.theme == "light" else 0.22)
    return card_style

func _make_dianshi_button_style(bg: Color, border: Color) -> StyleBoxFlat:
    var btn_style = StyleBoxFlat.new()
    btn_style.bg_color = bg
    btn_style.border_width_left = 1;btn_style.border_width_right = 1
    btn_style.border_width_top = 1;btn_style.border_width_bottom = 1
    btn_style.border_color = border
    btn_style.corner_radius_top_left = 2;btn_style.corner_radius_top_right = 2
    btn_style.corner_radius_bottom_left = 2;btn_style.corner_radius_bottom_right = 2
    btn_style.content_margin_left = 18
    btn_style.content_margin_right = 18
    return btn_style




func _attach_dianshi_panel_body(panel: PanelContainer, vbox: VBoxContainer, vp_size: Vector2, is_landscape: bool) -> void :
    if is_landscape:
        vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var body_scroll: = ScrollContainer.new()
        body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
        body_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
        body_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
        body_scroll.custom_minimum_size = Vector2(0, floorf(vp_size.y * _host.DIANSHI_DICE_MODAL_LANDSCAPE_HEIGHT_RATIO))
        ScrollbarThemeRef.apply_to(body_scroll)
        body_scroll.add_child(vbox)
        panel.add_child(body_scroll)
        panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    else:
        panel.add_child(vbox)

func _show_dianshi_strategy_overlay(index: int, ch: Dictionary) -> void :
    for child in _host.get_children():
        if child.name == "DianshiStrategyOverlay":
            return

    var mobile_portrait: bool = _host._is_mobile_portrait()
    var is_mobile: bool = mobile_portrait
    var vp_size: Vector2 = _host.get_viewport_rect().size
    var questions = ch.get("dianshi_questions", [])
    if questions.is_empty():
        _show_dianshi_dice_overlay(index, ch)
        return
    var q = questions[randi() % questions.size()]
    var overlay = ColorRect.new()
    overlay.name = "DianshiStrategyOverlay"
    overlay.add_to_group("blocking_modal_overlay")
    overlay.color = Color(0.015, 0.016, 0.018, 0.78)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.z_index = 100
    var scroll = ScrollContainer.new()
    scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    ScrollbarThemeRef.apply_to(scroll)
    overlay.add_child(scroll)
    var center = CenterContainer.new()




    center.custom_minimum_size = Vector2(0, vp_size.y + _host.DIANSHI_STRATEGY_MODAL_MOBILE_SCROLL_PADDING * 2.0) if is_mobile else Vector2.ZERO
    center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    center.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.add_child(center)
    var panel = PanelContainer.new()
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER if is_mobile else Control.SIZE_FILL
    panel.add_theme_stylebox_override("panel", _host._make_dianshi_panel_style(is_mobile))
    var grad = Gradient.new()
    if GameState.theme == "light":

        grad.set_color(0, GameState.get_theme_color("bg_popup"))
        grad.set_color(1, GameState.get_theme_color("bg_popup"))
    else:
        grad.set_color(0, Color(0.05, 0.04, 0.03, 0.98))
        grad.set_color(1, Color(0.015, 0.012, 0.01, 0.98))
    var grad_tex = GradientTexture2D.new()
    grad_tex.gradient = grad
    grad_tex.fill_from = Vector2(0, 0)
    grad_tex.fill_to = Vector2(0, 1)
    panel.draw.connect( func():
        panel.draw_texture_rect(grad_tex, Rect2(Vector2(1, 1), panel.size - Vector2(2, 2)), false)
    )
    var panel_scroll = ScrollContainer.new()
    panel_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    panel_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    panel_scroll.custom_minimum_size = Vector2(0, _get_dianshi_strategy_modal_height(vp_size.y, is_mobile))
    panel_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    ScrollbarThemeRef.apply_to(panel_scroll)
    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 20 if is_mobile else 16)
    vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var title_lbl = Label.new()
    title_lbl.text = "殿 试 · 天 子 策 问"
    title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_lbl.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_TITLE_FONT_SIZE if is_mobile else 26)
    title_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    title_lbl.add_theme_font_override("font", _host.DIANSHI_SYMBOL_FONT)
    vbox.add_child(title_lbl)
    var accent = ColorRect.new()
    accent.color = _host.DIANSHI_MODAL_ACCENT
    accent.custom_minimum_size = Vector2(72, 1)
    vbox.add_child(accent)
    var narr_lbl = Label.new()
    narr_lbl.text = q.get("narrative_suffix", "")
    narr_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    narr_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    narr_lbl.add_theme_font_override("font", FontLoader.body())
    narr_lbl.add_theme_font_size_override("font_size", (_host.MOBILE_GAME_MODAL_BODY_FONT_SIZE + 4) if is_mobile else 18)
    narr_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    narr_lbl.add_theme_constant_override("line_spacing", 8 if is_mobile else 4)
    vbox.add_child(narr_lbl)
    var focus_lbl = Label.new()
    focus_lbl.text = q.get("promptLine", "")
    focus_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    focus_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    focus_lbl.add_theme_font_override("font", FontLoader.body())
    focus_lbl.add_theme_font_size_override("font_size", (_host.MOBILE_GAME_MODAL_BODY_FONT_SIZE + 4) if is_mobile else 18)
    focus_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    vbox.add_child(focus_lbl)
    var choices_box = VBoxContainer.new()
    choices_box.add_theme_constant_override("separation", 12 if is_mobile else 10)
    var q_choices = q.get("choices", [])
    var result_container = VBoxContainer.new()
    result_container.add_theme_constant_override("separation", 16 if is_mobile else 12)
    result_container.visible = false
    for qi in range(q_choices.size()):
        var qc = q_choices[qi]
        var is_safe = qc.get("noDice", false)
        var border_col = Color(0.31, 0.33, 0.35, 0.85) if is_safe else Color(0.55, 0.42, 0.25, 0.7)
        var card = PanelContainer.new()
        card.mouse_filter = Control.MOUSE_FILTER_STOP
        card.add_theme_stylebox_override("panel", _make_dianshi_card_style(border_col))
        card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
        card.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW

        if _host._choice_card_uses_light_dark_style():
            var card_grad = _host._choice_card_gradient_texture(false)
            var effect = Control.new()
            effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
            effect.draw.connect( func():
                effect.draw_texture_rect(card_grad, Rect2(Vector2.ZERO, effect.size), false)
            )
            card.add_child(effect)

        var card_vbox = VBoxContainer.new()
        card_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
        card_vbox.add_theme_constant_override("separation", 6 if is_mobile else 4)
        var title_row = _host._create_choice_title_row(qc.get("title", ""))
        card_vbox.add_child(title_row)

        card.add_child(card_vbox)
        card.gui_input.connect(_dianshi_card_click.bind(overlay, index, ch, qc, is_safe, choices_box, result_container, vbox))
        choices_box.add_child(card)
    vbox.add_child(choices_box)
    vbox.add_child(result_container)

    var scroll_margin: = MarginContainer.new()
    scroll_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll_margin.add_theme_constant_override("margin_right", 46 if is_mobile else 40)
    scroll_margin.add_child(vbox)

    panel_scroll.add_child(scroll_margin)
    panel.add_child(panel_scroll)
    panel.custom_minimum_size = Vector2(_host._get_mobile_game_modal_width(vp_size.x), _get_dianshi_strategy_modal_height(vp_size.y, is_mobile)) if is_mobile else Vector2(_host.DIANSHI_STRATEGY_MODAL_DESKTOP_WIDTH, _get_dianshi_strategy_modal_height(vp_size.y, is_mobile))
    center.add_child(panel)
    _host.add_child(overlay)
    _host.NativeMobileFontScalerRef.apply_to(overlay)

func _dianshi_card_click(event: InputEvent, overlay: ColorRect, index: int, ch: Dictionary, qc: Dictionary, is_safe: bool, choices_box: VBoxContainer, result_container: VBoxContainer, vbox: VBoxContainer) -> void :
    if not _host._is_primary_press_event(event):
        return
    var press_frame: = Engine.get_process_frames()
    if int(overlay.get_meta("dianshi_last_press_frame", -1)) == press_frame:
        return
    overlay.set_meta("dianshi_last_press_frame", press_frame)
    if event is InputEventMouseButton:
        _host.accept_event()
    _host.get_viewport().set_input_as_handled()
    choices_box.visible = false
    result_container.visible = true
    var mobile_portrait: bool = _host._is_mobile_portrait()
    var is_mobile: bool = mobile_portrait
    if is_safe:
        var comment_lbl = Label.new()
        comment_lbl.text = qc.get("comment", "")
        comment_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        comment_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
        comment_lbl.add_theme_font_override("font", FontLoader.body())
        comment_lbl.add_theme_font_size_override("font_size", (_host.MOBILE_GAME_MODAL_BODY_FONT_SIZE + 4) if is_mobile else 18)
        comment_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        comment_lbl.add_theme_constant_override("line_spacing", 6 if is_mobile else 3)
        result_container.add_child(comment_lbl)
        var rank_lbl = Label.new()
        rank_lbl.text = "赐二甲进士出身"
        rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        rank_lbl.add_theme_font_override("font", FontLoader.body())
        rank_lbl.add_theme_font_size_override("font_size", (_host.MOBILE_GAME_MODAL_BODY_FONT_SIZE + 4) if is_mobile else 18)
        rank_lbl.add_theme_color_override("font_color", _host.DIANSHI_MODAL_ACCENT)
        result_container.add_child(rank_lbl)
        _show_dianshi_confirm(vbox, overlay, index, ch, "erjia", is_mobile)
    else:
        _dianshi_risky_roll(overlay, index, ch, qc, result_container, vbox)

func _make_dianshi_strategy_roll_card(mobile_portrait: bool) -> Dictionary:
    var card = PanelContainer.new()
    card.mouse_filter = Control.MOUSE_FILTER_IGNORE
    card.custom_minimum_size = Vector2(132, 148) if mobile_portrait else Vector2(112, 124)
    var dice_style = StyleBoxFlat.new()
    dice_style.bg_color = Color(0.088, 0.094, 0.102, 1.0)
    dice_style.border_width_left = 1;dice_style.border_width_right = 1
    dice_style.border_width_top = 1;dice_style.border_width_bottom = 1
    dice_style.border_color = Color(0.55, 0.42, 0.25, 0.7)
    dice_style.corner_radius_top_left = 2;dice_style.corner_radius_top_right = 2
    dice_style.corner_radius_bottom_left = 2;dice_style.corner_radius_bottom_right = 2
    dice_style.content_margin_left = 11;dice_style.content_margin_right = 11
    dice_style.content_margin_top = 12;dice_style.content_margin_bottom = 11
    dice_style.shadow_size = 0 if GameState.theme == "light" else 4
    dice_style.shadow_color = Color(0, 0, 0, 0.0 if GameState.theme == "light" else 0.22)
    card.add_theme_stylebox_override("panel", dice_style)
    var roll_noise_tex: = GrainTexture.build_card_noise_texture()
    card.draw.connect( func():
        card.draw_texture_rect(roll_noise_tex, Rect2(Vector2(1, 1), card.size - Vector2(2, 2)), true)
    )
    var dice_text_color: = Color(0.9, 0.84, 0.73, 0.92)
    var dice_sub_color: = Color(0.65, 0.58, 0.46, 0.85)
    var card_vbox = VBoxContainer.new()
    card_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
    card_vbox.add_theme_constant_override("separation", 8 if mobile_portrait else 6)
    var name_label = Label.new()
    name_label.text = "天意"
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name_label.add_theme_font_size_override("font_size", 29 if mobile_portrait else 15)
    name_label.add_theme_color_override("font_color", dice_text_color)
    card_vbox.add_child(name_label)
    var roll_label = Label.new()
    roll_label.text = "？"
    roll_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    roll_label.add_theme_font_override("font", _host.DIANSHI_SYMBOL_FONT)
    roll_label.add_theme_font_size_override("font_size", _host.MOBILE_DICE_SYMBOL_FONT_SIZE if mobile_portrait else 42)
    roll_label.add_theme_color_override("font_color", dice_text_color)
    card_vbox.add_child(roll_label)
    var status_label = Label.new()
    status_label.text = "需 4+"
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.add_theme_font_size_override("font_size", 22 if mobile_portrait else 11)
    status_label.add_theme_color_override("font_color", dice_sub_color)
    card_vbox.add_child(status_label)
    card.add_child(card_vbox)
    var center = CenterContainer.new()
    center.add_child(card)
    return {"card": center, "panel": card, "roll": roll_label, "status": status_label}

func _dianshi_risky_roll(overlay: ColorRect, index: int, ch: Dictionary, qc: Dictionary, result_container: VBoxContainer, vbox: VBoxContainer, allow_reroll: bool = true) -> void :
    var mobile_portrait: bool = _host._is_mobile_portrait()
    var is_mobile: bool = mobile_portrait
    var rolling_lbl = Label.new()
    rolling_lbl.text = "策卷呈上，读卷官传阅圈点……"
    rolling_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    rolling_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    rolling_lbl.add_theme_font_override("font", FontLoader.body())
    rolling_lbl.add_theme_font_size_override("font_size", (_host.MOBILE_GAME_MODAL_BODY_FONT_SIZE + 4) if is_mobile else 19)
    rolling_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    result_container.add_child(rolling_lbl)
    var dice_card = _make_dianshi_strategy_roll_card(is_mobile)
    var dice_display: Label = dice_card.roll
    var dice_status: Label = dice_card.status
    var dice_panel: PanelContainer = dice_card.panel
    result_container.add_child(dice_card.card)
    var roll_val = randi() % 6 + 1
    var success = roll_val >= 4
    var tween = _host.create_tween()
    tween.tween_interval(0.8)
    tween.tween_callback( func():
        if success:
            dice_display.text = _host.DICE_SUCCESS_SYMBOL
            dice_display.add_theme_color_override("font_color", _host.DIANSHI_SUCCESS)
            dice_status.text = "通过"
            dice_status.add_theme_color_override("font_color", _host.DIANSHI_SUCCESS)
            dice_panel.add_theme_stylebox_override("panel", _make_dianshi_card_style(Color(_host.DIANSHI_SUCCESS.r, _host.DIANSHI_SUCCESS.g, _host.DIANSHI_SUCCESS.b, 0.82)))
            rolling_lbl.text = qc.get("diceWinComment", "你的策论深得圣心。")
            rolling_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
            rolling_lbl.add_theme_constant_override("line_spacing", 6 if is_mobile else 3)
            var rank_lbl = Label.new()
            rank_lbl.text = "位列一甲！请再掷骰，钦定三鼎甲名次。"
            rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            rank_lbl.add_theme_font_override("font", FontLoader.body())
            rank_lbl.add_theme_font_size_override("font_size", (_host.MOBILE_GAME_MODAL_BODY_FONT_SIZE + 2) if is_mobile else 16)
            rank_lbl.add_theme_color_override("font_color", _host.DIANSHI_MODAL_ACCENT)
            result_container.add_child(rank_lbl)
            var proceed_center = CenterContainer.new()
            var proceed_btn = Button.new()
            proceed_btn.text = "钦 定 三 鼎 甲"
            proceed_btn.custom_minimum_size = Vector2(_host.MOBILE_GAME_MODAL_ACTION_WIDTH, _host.MOBILE_GAME_MODAL_ACTION_HEIGHT) if is_mobile else Vector2(160, 40)
            proceed_btn.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_ACTION_FONT_SIZE if is_mobile else 14)
            GameScreenStyleFactory.apply_command_button_style(proceed_btn, "primary", 18, 8)
            proceed_btn.pressed.connect( func():
                proceed_btn.disabled = true
                overlay.queue_free()
                _show_dianshi_yijia_roll(index, ch)
            )
            proceed_center.add_child(proceed_btn)
            result_container.add_child(proceed_center)
        else:
            dice_display.text = _host.DICE_FAIL_SYMBOL
            dice_display.add_theme_color_override("font_color", _host.DIANSHI_FAIL)
            dice_status.text = "未过 · 需4+"
            dice_status.add_theme_color_override("font_color", _host.DIANSHI_FAIL)
            dice_panel.add_theme_stylebox_override("panel", _make_dianshi_card_style(Color(_host.DIANSHI_FAIL.r, _host.DIANSHI_FAIL.g, _host.DIANSHI_FAIL.b, 0.82)))
            rolling_lbl.text = qc.get("failComment", "你的策论未能打动读卷官。")
            rolling_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
            rolling_lbl.add_theme_constant_override("line_spacing", 6 if is_mobile else 3)
            var rank_lbl = Label.new()
            rank_lbl.text = "赐三甲同进士出身"
            rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            rank_lbl.add_theme_font_override("font", FontLoader.body())
            rank_lbl.add_theme_font_size_override("font_size", (_host.MOBILE_GAME_MODAL_BODY_FONT_SIZE + 2) if is_mobile else 16)
            rank_lbl.add_theme_color_override("font_color", _host.DIANSHI_FAIL)
            result_container.add_child(rank_lbl)
            var reroll_action: = Callable()
            if allow_reroll:
                reroll_action = func():
                    for c in result_container.get_children():
                        result_container.remove_child(c)
                        c.queue_free()
                    _dianshi_risky_roll(overlay, index, ch, qc, result_container, vbox, false)
            _show_dianshi_confirm(vbox, overlay, index, ch, "sanjia", is_mobile, reroll_action)
    )

func _show_dianshi_yijia_roll(index: int, ch: Dictionary, allow_reroll: bool = true) -> void :
    var mobile_portrait: bool = _host._is_mobile_portrait()
    var uses_large_mobile_layout: bool = mobile_portrait
    var is_mobile: bool = mobile_portrait or _host._is_native_mobile_landscape()
    var vp_size: Vector2 = _host.get_viewport_rect().size
    var overlay = ColorRect.new()
    overlay.name = "DianshiYijiaOverlay"
    overlay.add_to_group("blocking_modal_overlay")
    overlay.color = Color(0.015, 0.016, 0.018, 0.78)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.z_index = 100
    var center = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    center.size_flags_vertical = Control.SIZE_EXPAND_FILL
    overlay.add_child(center)
    var panel = PanelContainer.new()
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_theme_stylebox_override("panel", _host._make_dianshi_panel_style(is_mobile))
    var grad = Gradient.new()
    if GameState.theme == "light":

        grad.set_color(0, GameState.get_theme_color("bg_popup"))
        grad.set_color(1, GameState.get_theme_color("bg_popup"))
    else:
        grad.set_color(0, Color(0.05, 0.04, 0.03, 0.98))
        grad.set_color(1, Color(0.015, 0.012, 0.01, 0.98))
    var grad_tex = GradientTexture2D.new()
    grad_tex.gradient = grad
    grad_tex.fill_from = Vector2(0, 0)
    grad_tex.fill_to = Vector2(0, 1)
    panel.draw.connect( func():
        panel.draw_texture_rect(grad_tex, Rect2(Vector2(1, 1), panel.size - Vector2(2, 2)), false)
    )
    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 24 if uses_large_mobile_layout else 18)
    vbox.alignment = BoxContainer.ALIGNMENT_CENTER
    var title = Label.new()
    title.text = "一 甲 钦 点"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_TITLE_FONT_SIZE if uses_large_mobile_layout else 26)
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    title.add_theme_font_override("font", _host.DIANSHI_SYMBOL_FONT)
    vbox.add_child(title)
    var info = Label.new()
    info.text = "一甲已定，御前复核四项"
    info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    info.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_BODY_FONT_SIZE if uses_large_mobile_layout else 14)
    info.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    vbox.add_child(info)
    var accent_rule = ColorRect.new()
    accent_rule.color = _host.DIANSHI_MODAL_ACCENT
    accent_rule.custom_minimum_size = Vector2(72, 1)
    vbox.add_child(accent_rule)
    var rolls_grid = GridContainer.new()
    rolls_grid.columns = 4
    rolls_grid.add_theme_constant_override("h_separation", 18 if is_mobile else 14)
    rolls_grid.add_theme_constant_override("v_separation", 18 if is_mobile else 14)
    rolls_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    vbox.add_child(rolls_grid)
    var roll_cards: = []
    var dice_card_style = StyleBoxFlat.new()
    dice_card_style.bg_color = Color(0.088, 0.094, 0.102, 1.0)
    dice_card_style.border_width_left = 1;dice_card_style.border_width_right = 1
    dice_card_style.border_width_top = 1;dice_card_style.border_width_bottom = 1
    dice_card_style.border_color = Color(0.31, 0.33, 0.35, 0.85)
    dice_card_style.corner_radius_top_left = 2;dice_card_style.corner_radius_top_right = 2
    dice_card_style.corner_radius_bottom_left = 2;dice_card_style.corner_radius_bottom_right = 2
    dice_card_style.content_margin_left = 11;dice_card_style.content_margin_right = 11
    dice_card_style.content_margin_top = 12;dice_card_style.content_margin_bottom = 11
    dice_card_style.shadow_size = 0 if GameState.theme == "light" else 4
    dice_card_style.shadow_color = Color(0, 0, 0, 0.0 if GameState.theme == "light" else 0.22)
    var dice_txt_color: = Color(0.9, 0.84, 0.73, 0.92)
    var dice_sub_txt: = Color(0.65, 0.58, 0.46, 0.85)
    var noise_img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
    for x in range(64):
        for y in range(64):
            var v = randf()
            if v > 0.5:
                noise_img.set_pixel(x, y, Color(0, 0, 0, randf() * 0.1))
            else:
                noise_img.set_pixel(x, y, Color(1, 1, 1, randf() * 0.03))
    var noise_tex = ImageTexture.create_from_image(noise_img)
    for stat in _host.DIANSHI_ROLL_STATS:
        var current_val = int(GameState.stats.get(stat.key, 0))
        var threshold = _host._calc_dice_threshold(_host.DIANSHI_YIJIA_ROLL_TARGET - current_val)
        var item_vbox = VBoxContainer.new()
        item_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
        item_vbox.add_theme_constant_override("separation", 12 if uses_large_mobile_layout else 8)
        var status_label = Label.new()
        status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        status_label.add_theme_font_size_override("font_size", 24 if uses_large_mobile_layout else 12)
        var pass_hint_lbl: Label = null
        if threshold.level == 0:
            status_label.text = "≥%d 已达标" % _host.DIANSHI_YIJIA_ROLL_TARGET
            status_label.add_theme_color_override("font_color", _host.DIANSHI_SUCCESS)
        else:
            status_label.text = "≥%d %s" % [_host.DIANSHI_YIJIA_ROLL_TARGET, threshold.dots]
            status_label.add_theme_color_override("font_color", _host.DIANSHI_MODAL_ACCENT)
        item_vbox.add_child(status_label)

        if threshold.level > 0:
            pass_hint_lbl = Label.new()
            pass_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            pass_hint_lbl.add_theme_font_size_override("font_size", 20 if uses_large_mobile_layout else 10)
            pass_hint_lbl.add_theme_color_override("font_color", _host.DIANSHI_MODAL_ACCENT)
            pass_hint_lbl.text = _host.get_dice_pass_hint(int(threshold.min))
            item_vbox.add_child(pass_hint_lbl)
        var card = PanelContainer.new()
        card.mouse_filter = Control.MOUSE_FILTER_IGNORE
        card.custom_minimum_size = Vector2(132, 148) if uses_large_mobile_layout else Vector2(112, 124)
        card.add_theme_stylebox_override("panel", dice_card_style)
        card.draw.connect( func():
            card.draw_texture_rect(noise_tex, Rect2(Vector2(1, 1), card.size - Vector2(2, 2)), true)
        )
        var card_vbox = VBoxContainer.new()
        card_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
        card_vbox.add_theme_constant_override("separation", 8 if uses_large_mobile_layout else 6)
        var name_label = Label.new()
        name_label.text = stat.label
        name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        name_label.add_theme_font_size_override("font_size", 29 if uses_large_mobile_layout else 15)
        name_label.add_theme_color_override("font_color", dice_txt_color)
        card_vbox.add_child(name_label)
        var roll_label = Label.new()
        var _met: = int(threshold.get("level", 0)) == 0
        roll_label.text = _host.DICE_SUCCESS_SYMBOL if _met else "？"
        roll_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        roll_label.add_theme_font_override("font", _host.DIANSHI_SYMBOL_FONT)
        roll_label.add_theme_font_size_override("font_size", _host.MOBILE_DICE_SYMBOL_FONT_SIZE if uses_large_mobile_layout else 42)
        roll_label.add_theme_color_override("font_color", _host.DIANSHI_SUCCESS if _met else dice_txt_color)
        card_vbox.add_child(roll_label)
        var current_label = Label.new()
        current_label.text = "当前 %d" % current_val
        current_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        current_label.add_theme_font_size_override("font_size", 22 if uses_large_mobile_layout else 11)
        current_label.add_theme_color_override("font_color", dice_sub_txt)
        card_vbox.add_child(current_label)
        card.add_child(card_vbox)
        item_vbox.add_child(card)
        rolls_grid.add_child(item_vbox)
        roll_cards.append({"key": stat.key, "label": stat.label, "roll": roll_label, "req": status_label, "threshold": threshold, "card": card, "pass_hint": pass_hint_lbl})
    var hint = Label.new()
    hint.text = "四项全过为状元，三项过为榜眼，一二项过为探花"
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_BODY_FONT_SIZE if uses_large_mobile_layout else 14)
    hint.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    vbox.add_child(hint)
    var roll_center = CenterContainer.new()
    var roll_btn = Button.new()
    roll_btn.text = "钦 定 名 次"
    roll_btn.custom_minimum_size = Vector2(_host.MOBILE_GAME_MODAL_ACTION_WIDTH, _host.MOBILE_GAME_MODAL_ACTION_HEIGHT) if uses_large_mobile_layout else Vector2(150, 40)
    roll_btn.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_ACTION_FONT_SIZE if uses_large_mobile_layout else 14)
    GameScreenStyleFactory.apply_command_button_style(roll_btn, "primary", 18, 8)
    roll_center.add_child(roll_btn)
    vbox.add_child(roll_center)
    _attach_dianshi_panel_body(panel, vbox, vp_size, _host._is_native_mobile_landscape() or _host._is_native_tablet_landscape())
    panel.custom_minimum_size = Vector2(_host._get_mobile_game_modal_width(vp_size.x), 0) if is_mobile else Vector2(560, 420)
    center.add_child(panel)
    _host.add_child(overlay)
    _host.NativeMobileFontScalerRef.apply_to(overlay)
    roll_btn.pressed.connect( func():
        roll_btn.disabled = true
        hint.text = "御前复核，内帘诸臣逐项圈点..."
        var passed_count: = 0
        for card_info in roll_cards:

            if int(card_info.threshold.get("level", 0)) == 0:
                continue
            card_info.roll.text = "？"
            card_info.roll.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
            card_info.card.add_theme_stylebox_override("panel", _make_dianshi_card_style())
            if card_info.get("pass_hint") != null:
                card_info.pass_hint.visible = false
        var tween = _host.create_tween()
        for i in range(roll_cards.size()):
            var card_info = roll_cards[i]
            var threshold_d: Dictionary = card_info.threshold

            if int(threshold_d.get("level", 0)) == 0:
                passed_count += 1
                continue
            var roll_val = randi() % 6 + 1
            var success = roll_val >= int(threshold_d.min)
            if success:
                passed_count += 1
            var reveal = func(l_card: PanelContainer, l_roll: Label, l_req: Label, l_success: bool, l_threshold: Dictionary):
                l_roll.text = _host.DICE_SUCCESS_SYMBOL if l_success else _host.DICE_FAIL_SYMBOL
                l_roll.add_theme_color_override("font_color", _host.DIANSHI_SUCCESS if l_success else _host.DIANSHI_FAIL)
                l_req.text = "通过" if l_success else "未过 · 需%d+" % int(l_threshold.min)
                l_req.add_theme_color_override("font_color", _host.DIANSHI_SUCCESS if l_success else _host.DIANSHI_FAIL)
                var next_border = Color(_host.DIANSHI_SUCCESS.r, _host.DIANSHI_SUCCESS.g, _host.DIANSHI_SUCCESS.b, 0.82) if l_success else Color(_host.DIANSHI_FAIL.r, _host.DIANSHI_FAIL.g, _host.DIANSHI_FAIL.b, 0.82)
                l_card.add_theme_stylebox_override("panel", _make_dianshi_card_style(next_border))
            tween.tween_interval(0.08)
            tween.tween_callback(reveal.bind(card_info.card, card_info.roll, card_info.req, success, threshold_d))
        tween.tween_callback( func():
            var final_rank: String
            if passed_count >= 4:
                final_rank = "zhuangyuan"
                hint.text = "四项俱中，钦点状元及第。"
            elif passed_count >= 3:
                final_rank = "bangyan"
                hint.text = "三项入格，钦点榜眼及第。"
            else:
                final_rank = "tanhua"
                hint.text = "一二项入格，钦点探花及第。"
            hint.add_theme_color_override("font_color", _host.DIANSHI_MODAL_ACCENT)
            var reroll_action: = Callable()
            if allow_reroll:
                reroll_action = func():
                    overlay.queue_free()
                    _show_dianshi_yijia_roll(index, ch, false)
            _show_dianshi_confirm(vbox, overlay, index, ch, final_rank, uses_large_mobile_layout, reroll_action)
        )
    )

func _show_dianshi_dice_overlay(index: int, ch: Dictionary) -> void :
    for child in _host.get_children():
        if child.name == "DianshiDiceOverlay":
            return

    var mobile_portrait: bool = _host._is_mobile_portrait()
    var uses_large_mobile_layout: bool = mobile_portrait
    var is_mobile: bool = mobile_portrait or _host._is_native_mobile_landscape()
    var vp_size: Vector2 = _host.get_viewport_rect().size
    var overlay = ColorRect.new()
    overlay.name = "DianshiDiceOverlay"
    overlay.add_to_group("blocking_modal_overlay")
    overlay.color = Color(0.015, 0.016, 0.018, 0.78)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.z_index = 100

    var center = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    center.size_flags_vertical = Control.SIZE_EXPAND_FILL
    overlay.add_child(center)

    var panel = PanelContainer.new()
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_theme_stylebox_override("panel", _host._make_dianshi_panel_style(is_mobile))

    var grad = Gradient.new()
    if GameState.theme == "light":

        grad.set_color(0, GameState.get_theme_color("bg_popup"))
        grad.set_color(1, GameState.get_theme_color("bg_popup"))
    else:
        grad.set_color(0, Color(0.05, 0.04, 0.03, 0.98))
        grad.set_color(1, Color(0.015, 0.012, 0.01, 0.98))
    var grad_tex = GradientTexture2D.new()
    grad_tex.gradient = grad
    grad_tex.fill_from = Vector2(0, 0)
    grad_tex.fill_to = Vector2(0, 1)

    panel.draw.connect( func():
        panel.draw_texture_rect(grad_tex, Rect2(Vector2(1, 1), panel.size - Vector2(2, 2)), false)
    )

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 24 if uses_large_mobile_layout else 18)
    vbox.alignment = BoxContainer.ALIGNMENT_CENTER

    var title = Label.new()
    title.text = "殿 试 钦 点"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_TITLE_FONT_SIZE if uses_large_mobile_layout else 26)
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    vbox.add_child(title)

    var info = Label.new()
    info.text = "御前策问，四项同掷"
    info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    info.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_BODY_FONT_SIZE if uses_large_mobile_layout else 14)
    info.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    vbox.add_child(info)

    var accent_rule = ColorRect.new()
    accent_rule.color = _host.DIANSHI_MODAL_ACCENT
    accent_rule.custom_minimum_size = Vector2(72, 1)
    vbox.add_child(accent_rule)

    var rolls_grid = GridContainer.new()
    rolls_grid.columns = 4
    rolls_grid.add_theme_constant_override("h_separation", 18 if is_mobile else 14)
    rolls_grid.add_theme_constant_override("v_separation", 18 if is_mobile else 14)
    rolls_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    vbox.add_child(rolls_grid)

    var roll_cards: = []
    var dice_style2 = StyleBoxFlat.new()
    dice_style2.bg_color = Color(0.088, 0.094, 0.102, 1.0)
    dice_style2.border_width_left = 1;dice_style2.border_width_right = 1
    dice_style2.border_width_top = 1;dice_style2.border_width_bottom = 1
    dice_style2.border_color = Color(0.31, 0.33, 0.35, 0.85)
    dice_style2.corner_radius_top_left = 2;dice_style2.corner_radius_top_right = 2
    dice_style2.corner_radius_bottom_left = 2;dice_style2.corner_radius_bottom_right = 2
    dice_style2.content_margin_left = 11;dice_style2.content_margin_right = 11
    dice_style2.content_margin_top = 12;dice_style2.content_margin_bottom = 11
    dice_style2.shadow_size = 0 if GameState.theme == "light" else 4
    dice_style2.shadow_color = Color(0, 0, 0, 0.0 if GameState.theme == "light" else 0.22)
    var dtxt2: = Color(0.9, 0.84, 0.73, 0.92)
    var dsub2: = Color(0.65, 0.58, 0.46, 0.85)

    var noise_img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
    for x in range(64):
        for y in range(64):
            var v = randf()
            if v > 0.5:
                noise_img.set_pixel(x, y, Color(0, 0, 0, randf() * 0.1))
            else:
                noise_img.set_pixel(x, y, Color(1, 1, 1, randf() * 0.03))
    var noise_tex = ImageTexture.create_from_image(noise_img)

    for stat in _host.DIANSHI_ROLL_STATS:
        var current_val = int(GameState.stats.get(stat.key, 0))
        var threshold = _host._calc_dice_threshold(_host.DIANSHI_ROLL_TARGET - current_val)

        var item_vbox = VBoxContainer.new()
        item_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
        item_vbox.add_theme_constant_override("separation", 12 if uses_large_mobile_layout else 8)

        var status_label = Label.new()
        status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        status_label.add_theme_font_size_override("font_size", 24 if uses_large_mobile_layout else 12)
        var pass_hint_lbl: Label = null
        if threshold.level == 0:
            status_label.text = "≥%d 已达标" % _host.DIANSHI_ROLL_TARGET
            status_label.add_theme_color_override("font_color", _host.DIANSHI_SUCCESS)
        else:
            status_label.text = "≥%d %s" % [_host.DIANSHI_ROLL_TARGET, threshold.dots]
            status_label.add_theme_color_override("font_color", _host.DIANSHI_MODAL_ACCENT)
        item_vbox.add_child(status_label)

        if threshold.level > 0:
            pass_hint_lbl = Label.new()
            pass_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            pass_hint_lbl.add_theme_font_size_override("font_size", 20 if uses_large_mobile_layout else 10)
            pass_hint_lbl.add_theme_color_override("font_color", _host.DIANSHI_MODAL_ACCENT)
            pass_hint_lbl.text = _host.get_dice_pass_hint(int(threshold.min))
            item_vbox.add_child(pass_hint_lbl)

        var card = PanelContainer.new()
        card.mouse_filter = Control.MOUSE_FILTER_IGNORE
        card.custom_minimum_size = Vector2(132, 148) if uses_large_mobile_layout else Vector2(112, 124)
        card.add_theme_stylebox_override("panel", dice_style2)
        card.draw.connect( func():
            card.draw_texture_rect(noise_tex, Rect2(Vector2(1, 1), card.size - Vector2(2, 2)), true)
        )

        var card_vbox = VBoxContainer.new()
        card_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
        card_vbox.add_theme_constant_override("separation", 8 if uses_large_mobile_layout else 6)

        var name_label = Label.new()
        name_label.text = stat.label
        name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        name_label.add_theme_font_size_override("font_size", 29 if uses_large_mobile_layout else 15)
        name_label.add_theme_color_override("font_color", dtxt2)
        card_vbox.add_child(name_label)

        var roll_label = Label.new()
        var _met: = int(threshold.get("level", 0)) == 0
        roll_label.text = _host.DICE_SUCCESS_SYMBOL if _met else "？"
        roll_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        roll_label.add_theme_font_override("font", _host.DIANSHI_SYMBOL_FONT)
        roll_label.add_theme_font_size_override("font_size", _host.MOBILE_DICE_SYMBOL_FONT_SIZE if uses_large_mobile_layout else 42)
        roll_label.add_theme_color_override("font_color", _host.DIANSHI_SUCCESS if _met else dtxt2)
        card_vbox.add_child(roll_label)

        var current_label = Label.new()
        current_label.text = "当前 %d" % current_val
        current_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        current_label.add_theme_font_size_override("font_size", 22 if uses_large_mobile_layout else 11)
        current_label.add_theme_color_override("font_color", dsub2)
        card_vbox.add_child(current_label)

        card.add_child(card_vbox)
        item_vbox.add_child(card)
        rolls_grid.add_child(item_vbox)

        roll_cards.append({"key": stat.key, "label": stat.label, "roll": roll_label, "req": status_label, "threshold": threshold, "card": card, "pass_hint": pass_hint_lbl})

    var hint = Label.new()
    hint.text = "四项全过为一甲，三项过为二甲，一二项过为三甲"
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_BODY_FONT_SIZE if uses_large_mobile_layout else 14)
    hint.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    vbox.add_child(hint)

    var roll_center = CenterContainer.new()
    var roll_btn = Button.new()
    roll_btn.text = "御 前 作 答"
    roll_btn.custom_minimum_size = Vector2(_host.MOBILE_GAME_MODAL_ACTION_WIDTH, _host.MOBILE_GAME_MODAL_ACTION_HEIGHT) if uses_large_mobile_layout else Vector2(150, 40)
    roll_btn.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_ACTION_FONT_SIZE if uses_large_mobile_layout else 14)
    GameScreenStyleFactory.apply_command_button_style(roll_btn, "primary", 18, 8)
    roll_center.add_child(roll_btn)
    vbox.add_child(roll_center)

    _attach_dianshi_panel_body(panel, vbox, vp_size, _host._is_native_mobile_landscape() or _host._is_native_tablet_landscape())
    panel.custom_minimum_size = Vector2(_host._get_mobile_game_modal_width(vp_size.x), 0) if is_mobile else Vector2(560, 420)
    center.add_child(panel)

    _host.add_child(overlay)
    _host.NativeMobileFontScalerRef.apply_to(overlay)

    var dianshi_roll_state: = {"step": 1}

    var do_roll = func(allow_rr: bool):
        roll_btn.disabled = true
        hint.text = "策卷呈上，内帘诸臣逐项圈点..."
        var passed_count: = 0
        var first_rank_roll: bool = int(dianshi_roll_state.step) == 1
        for card_info in roll_cards:

            if int(card_info.threshold.get("level", 0)) == 0:
                continue
            card_info.roll.text = "？"
            card_info.roll.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
            card_info.card.add_theme_stylebox_override("panel", _make_dianshi_card_style())
            if card_info.get("pass_hint") != null:
                card_info.pass_hint.visible = false

        var tween = _host.create_tween()
        for i in range(roll_cards.size()):
            var card_info = roll_cards[i]
            var threshold: Dictionary = card_info.threshold

            if int(threshold.get("level", 0)) == 0:
                passed_count += 1
                continue
            var roll_val = randi() % 6 + 1
            var success = roll_val >= int(threshold.min)
            if success:
                passed_count += 1

            var reveal = func(l_card: PanelContainer, l_roll: Label, l_req: Label, l_success: bool, l_threshold: Dictionary):
                l_roll.text = _host.DICE_SUCCESS_SYMBOL if l_success else _host.DICE_FAIL_SYMBOL
                l_roll.add_theme_color_override("font_color", _host.DIANSHI_SUCCESS if l_success else _host.DIANSHI_FAIL)
                l_req.text = "通过" if l_success else "未过 · 需%d+" % int(l_threshold.min)
                l_req.add_theme_color_override("font_color", _host.DIANSHI_SUCCESS if l_success else _host.DIANSHI_FAIL)
                var next_border = Color(_host.DIANSHI_SUCCESS.r, _host.DIANSHI_SUCCESS.g, _host.DIANSHI_SUCCESS.b, 0.82) if l_success else Color(_host.DIANSHI_FAIL.r, _host.DIANSHI_FAIL.g, _host.DIANSHI_FAIL.b, 0.82)
                l_card.add_theme_stylebox_override("panel", _make_dianshi_card_style(next_border))
            tween.tween_interval(0.08)
            tween.tween_callback(reveal.bind(card_info.card, card_info.roll, card_info.req, success, threshold))

        tween.tween_callback( func():
            var rank_result = _resolve_dianshi_rank_from_pass_count(passed_count, first_rank_roll)
            if rank_result == "yijia":
                hint.text = "四项俱中，位列一甲！请再掷一次，钦定三鼎甲名次。"
                hint.add_theme_color_override("font_color", _host.DIANSHI_MODAL_ACCENT)
                dianshi_roll_state.step = 2
                var t2 = _host.get_tree().create_timer(1.2)
                t2.timeout.connect( func():
                    for card_info in roll_cards:
                        card_info.req.text = "再听圣裁"
                        card_info.req.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
                        card_info.card.add_theme_stylebox_override("panel", _make_dianshi_card_style())
                    hint.text = "一甲已定，再作御前复核：四项全过为状元，三项为榜眼，一二项为探花。"
                    roll_btn.text = "钦 定 名 次"
                    roll_btn.disabled = false
                )
            else:
                var final_rank = rank_result
                if final_rank == "erjia":
                    hint.text = "三项入格，赐二甲进士出身。"
                elif final_rank == "sanjia":
                    hint.text = "一二项入格，赐三甲同进士出身。"
                elif final_rank == "zhuangyuan":
                    hint.text = "四项俱中，钦点状元及第。"
                elif final_rank == "bangyan":
                    hint.text = "三项入格，钦点榜眼及第。"
                else:
                    hint.text = "一二项入格，钦点探花及第。"
                hint.add_theme_color_override("font_color", _host.DIANSHI_MODAL_ACCENT)
                var reroll_action: = Callable()
                if allow_rr:

                    reroll_action = func(): dianshi_roll_state.do_roll.call(false)
                _show_dianshi_confirm(vbox, overlay, index, ch, final_rank, uses_large_mobile_layout, reroll_action)
        )

    dianshi_roll_state["do_roll"] = do_roll
    roll_btn.pressed.connect( func():
        do_roll.call(true)
    )

func _make_dianshi_reroll_button(uses_large_mobile_layout: bool) -> Button:
    var reroll_btn = Button.new()
    reroll_btn.text = "再 试 一 次"
    reroll_btn.custom_minimum_size = Vector2(_host.MOBILE_GAME_MODAL_ACTION_WIDTH, _host.MOBILE_GAME_MODAL_ACTION_HEIGHT) if uses_large_mobile_layout else Vector2(140, 40)
    reroll_btn.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_ACTION_FONT_SIZE if uses_large_mobile_layout else 14)
    GameScreenStyleFactory.apply_command_button_style(reroll_btn, "secondary", 18, 8)
    return reroll_btn

func _show_dianshi_confirm(vbox: VBoxContainer, overlay: ColorRect, index: int, ch: Dictionary, final_rank: String, uses_large_mobile_layout: bool, reroll_action: Callable = Callable()) -> void :

    for child in vbox.get_children():
        if child is CenterContainer and child.get_child_count() > 0:
            var inner = child.get_child(0)
            if inner is Button and "叩谢皇恩" in inner.text.replace(" ", ""):
                return
            if inner is HBoxContainer:
                for b in inner.get_children():
                    if b is Button and "叩谢皇恩" in b.text.replace(" ", ""):
                        return

    var confirm_center = CenterContainer.new()
    var confirm_btn = Button.new()
    confirm_btn.text = "叩 谢 皇 恩"
    confirm_btn.custom_minimum_size = Vector2(_host.MOBILE_GAME_MODAL_ACTION_WIDTH, _host.MOBILE_GAME_MODAL_ACTION_HEIGHT) if uses_large_mobile_layout else Vector2(140, 40)
    confirm_btn.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_ACTION_FONT_SIZE if uses_large_mobile_layout else 14)

    GameScreenStyleFactory.apply_command_button_style(confirm_btn, "primary", 18, 8)

    confirm_btn.pressed.connect( func():
        confirm_btn.disabled = true
        overlay.queue_free()
        _resolve_dianshi_result(index, ch, final_rank)
    )


    if GameState.is_simple_mode() and reroll_action.is_valid():
        var reroll_btn = _make_dianshi_reroll_button(uses_large_mobile_layout)
        reroll_btn.pressed.connect( func():

            if confirm_center.get_parent() != null:
                confirm_center.get_parent().remove_child(confirm_center)
            confirm_center.queue_free()
            reroll_action.call()
        )
        var row = HBoxContainer.new()
        row.add_theme_constant_override("separation", 16 if uses_large_mobile_layout else 12)
        row.alignment = BoxContainer.ALIGNMENT_CENTER
        row.add_child(reroll_btn)
        row.add_child(confirm_btn)
        confirm_center.add_child(row)
    else:
        confirm_center.add_child(confirm_btn)
    vbox.add_child(confirm_center)

func _is_dianshi_before_chongzhen() -> bool:
    if GameState.selected_timeline == "chongzhen":
        return false
    if not GameState.has_method("get_current_year_str"):
        return false
    var year_str: = str(GameState.get_current_year_str()).strip_edges()
    return year_str != "" and not year_str.begins_with("崇祯")

func _resolve_dianshi_result(index: int, ch: Dictionary, final_rank: String) -> void :
    var applied_ch = ch.duplicate(true)
    applied_ch["setKejuStatus"] = final_rank
    GameState.jinshi_year = GameState.get_czYear()
    var before_chongzhen: = _is_dianshi_before_chongzhen()

    if final_rank == "zhuangyuan":
        applied_ch["effects"] = {"shengjuan": 10, "zhongguan": 10, "qingyi": 10, "shishen": 10, "minwang": 10}
        applied_ch["systemComment"] = "状元及第，大明科举的巅峰。"
    elif final_rank in ["bangyan", "tanhua"]:
        applied_ch["effects"] = {"shengjuan": 8, "qingyi": 8, "shishen": 8}
        applied_ch["systemComment"] = "一甲及第，名列三鼎甲。"
    elif final_rank == "erjia":
        applied_ch["effects"] = {"qingyi": 5, "shishen": 5}
        applied_ch["systemComment"] = "二甲登科，赐二甲进士出身。"
    elif final_rank == "sanjia":
        applied_ch["effects"] = {"qingyi": 3, "shishen": 3}
        if before_chongzhen:
            applied_ch["systemComment"] = "三甲同进士出身。\n\n这个「同」字，是朝廷给你的，也是压在你身上的一块石头。它的意思是：你与进士「相同」，但终究不是进士。"
        else:
            applied_ch["systemComment"] = "三甲同进士出身。\n\n这个「同」字，是朝廷给你的，也是压在你身上的一块石头。它的意思是：你与进士「相同」，但终究不是进士。\n\n一甲「进士及第」，二甲「进士出身」，到了三甲，只剩「同进士出身」——五个字里藏着一道裂缝，官场中人一眼便能看穿。吏部铨选时，一二甲可留京、入翰林、候清贵美缺；三甲则多外放偏远州县，候缺更久，升迁更慢，终身头顶「三甲」二字，抹不掉，挣不脱。\n\n私下里有人说：「三甲非真进士。」也有人说：「同而不同，终究差一格。」你听过，装作没听见，继续往前走。\n\n进了这道门，就是官身。至于这门比别人窄了几寸——你以后用政绩去量。"

    if before_chongzhen:
        var year_str = GameState.get_current_year_str() if GameState.has_method("get_current_year_str") else "天启年间"
        var tianqi_suffix = "\n\n然而，在这大明%s的京城里，这金灿灿的进士功名并不能为你换来半个前程。东林与阉党斗得你死我活，朝堂之上乌烟瘴气。你既无世家背景遮风荡雨，又不愿去阉党门下呈递名帖，更拿不出成百上千两白银打点吏部铨曹。\n\n吏部的铨选红册在你的注视下轻轻合上。书办连头都没抬，只是将你的告身和名字压进了铨选簿册的最后面。没有留京，没有外放，甚至连一张回乡的文凭都没有。你只攥着一张进士捷报，在一片冷眼与飞沙中走向了宣武门外的破客栈。\n\n你在这座大明心脏的角落里住了下来。窗外风起，辽东的急报与阉党的谄谀日复一日地从街上经过。这一等，便是漫漫长夜。你的名字落满了灰尘，而你只能在破桌、孤灯与寒窗前，苦苦等待着冰消雪融的那一天。" % year_str
        applied_ch["systemComment"] += tianqi_suffix


    if before_chongzhen:

        GameState.branch = "origin"
        GameState.branch_index = 24
        GameState._base_age = 25
        GameState.current_event = 24
        GameState.pending_events.clear()
        GameState.active_pending_event = {}
        GameState.state_changed.emit()


        applied_ch.erase("queueBranch")
        applied_ch.erase("queueBranchIndex")
    else:

        applied_ch["queueBranch"] = "keju"
        var target_idx = 0
        if GameData.branch_events.has("keju"):
            var kc_events = GameData.branch_events["keju"]
            for i in range(kc_events.size()):
                if kc_events[i].get("id", "") == "e_keju_dianshi_choice":
                    target_idx = i
                    break
        applied_ch["queueBranchIndex"] = target_idx

    _host._resolve_choice_internal(index, applied_ch, false, true, [])
