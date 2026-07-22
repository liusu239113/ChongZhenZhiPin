extends RefCounted
class_name DiceOverlayController




const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const FontLoader = preload("res://scripts/ui/font_loader.gd")
const GrainTexture = preload("res://scripts/ui/grain_texture.gd")
const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")

var _host

func _init(host) -> void :
    _host = host

func show_dice_overlay(index: int, ch: Dictionary, allow_reroll: bool = true) -> void :
    for child in _host.get_children():
        if child.name == "DiceOverlay":
            return
    _host._dice_overlay_rolled = false
    _host._dice_overlay_resolved = false
    _host._dice_overlay_committed = false
    _host._dice_pending_success = false
    _host._dice_pending_failed_keys = []

    var mobile_portrait: bool = _host._is_mobile_portrait()
    var vp_size: Vector2 = _host.get_viewport_rect().size

    var is_pure_chance: bool = ch.has("pureChance")
    var pure_chance_rate: float = float(ch.get("pureChance", 0.5)) if is_pure_chance else 0.0

    var dice_check = _host._parse_dice_eligibility(ch).get("dice", {"gap": 0})
    var is_multi = dice_check.has("multi_gaps") and dice_check.multi_gaps.size() > 1
    var gaps_to_roll = dice_check.multi_gaps if is_multi else [dice_check.get("gap", 0)]
    var labels_to_roll = dice_check.get("multi_labels", []) if is_multi else []
    var targets_to_roll = dice_check.get("multi_targets", []) if is_multi else [dice_check.get("target", 0)]
    var keys_to_roll = dice_check.get("multi_keys", []) if is_multi else []

    var threshs = []
    if is_pure_chance:
        var display_gap: int
        if pure_chance_rate >= 0.75: display_gap = 3
        elif pure_chance_rate >= 0.6: display_gap = 10
        elif pure_chance_rate >= 0.45: display_gap = 20
        elif pure_chance_rate >= 0.3: display_gap = 30
        else: display_gap = 40
        threshs.append(_host._calc_dice_threshold(display_gap))
    else:
        for g in gaps_to_roll:
            threshs.append(_host._calc_dice_threshold(g))

    var overlay = ColorRect.new()
    overlay.name = "DiceOverlay"
    overlay.color = Color(0, 0, 0, 0.85)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.z_index = 100
    overlay.add_to_group("blocking_modal_overlay")

    var center = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.add_child(center)

    var panel = PanelContainer.new()
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_theme_stylebox_override("panel", _host._make_dianshi_panel_style(mobile_portrait))

    var grad = Gradient.new()
    if GameState.theme == "light":

        grad.set_color(0, Color.html("E0E2E6"))
        grad.set_color(1, Color.html("E0E2E6"))
    else:
        grad.set_color(0, Color(0.08, 0.07, 0.06, 0.98))
        grad.set_color(1, Color(0.05, 0.045, 0.035, 0.98))
    var grad_tex = GradientTexture2D.new()
    grad_tex.gradient = grad
    grad_tex.fill_from = Vector2(0, 0)
    grad_tex.fill_to = Vector2(0, 1)

    panel.draw.connect( func():
        panel.draw_texture_rect(grad_tex, Rect2(Vector2(1, 1), panel.size - Vector2(2, 2)), false)
    )

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 24 if mobile_portrait else 18)
    vbox.alignment = BoxContainer.ALIGNMENT_CENTER

    var title = Label.new()
    title.text = "勉 力 一 试"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_TITLE_FONT_SIZE if mobile_portrait else 26)
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    title.add_theme_font_override("font", FontLoader.title())
    vbox.add_child(title)

    var accent_rule = ColorRect.new()
    accent_rule.color = Color(_host.DIANSHI_MODAL_ACCENT.r, _host.DIANSHI_MODAL_ACCENT.g, _host.DIANSHI_MODAL_ACCENT.b, 0.4)
    accent_rule.custom_minimum_size = Vector2(72, 1)
    vbox.add_child(accent_rule)

    if not is_multi:
        var stat_info_box = VBoxContainer.new()
        stat_info_box.alignment = BoxContainer.ALIGNMENT_CENTER
        stat_info_box.add_theme_constant_override("separation", 10 if mobile_portrait else 6)

        var req_lbl = Label.new()
        var diff_lbl = Label.new()

        if is_pure_chance:
            var pct: int = int(round(pure_chance_rate * 100.0))
            req_lbl.text = "胜算：%d%%" % pct
            diff_lbl.text = "成则有获，败则无所得"
        else:
            var t_val = targets_to_roll[0] if targets_to_roll.size() > 0 else 0
            var stat_label = str(dice_check.get("label", "属性"))
            var stat_key = keys_to_roll[0] if keys_to_roll.size() > 0 else dice_check.get("key", "")
            var current_val = _host._get_stat_or_resource_value(stat_key)
            req_lbl.text = "当前%s%d，%s≥%d可直接通过" % [stat_label, current_val, stat_label, t_val]
            diff_lbl.text = "难度: %d级 %s" % [threshs[0].level, threshs[0].dots]

        req_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        req_lbl.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_BODY_FONT_SIZE if mobile_portrait else 15)
        diff_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        diff_lbl.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_BODY_FONT_SIZE if mobile_portrait else 14)
        diff_lbl.add_theme_font_override("font", FontLoader.serif_bold())

        var diff_color = GameState.get_theme_color("req_red")
        if threshs[0].level <= 1:
            diff_color = GameState.get_theme_color("req_green")
        elif threshs[0].level <= 3:
            diff_color = GameState.get_theme_color("req_yellow")

        req_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        diff_lbl.add_theme_color_override("font_color", diff_color)
        diff_lbl.add_theme_font_override("font", FontLoader.serif_bold())

        stat_info_box.add_child(diff_lbl)
        stat_info_box.add_child(req_lbl)

        var pass_hint_lbl = _make_pass_hint_rich_label(
            int(threshs[0].min), 
            diff_color, 
            _host.MOBILE_GAME_MODAL_BODY_FONT_SIZE if mobile_portrait else 14, 
            GameState.get_theme_color("text_sub")
        )
        stat_info_box.add_child(pass_hint_lbl)

        vbox.add_child(stat_info_box)

    var deck_hbox = HBoxContainer.new()
    deck_hbox.add_theme_constant_override("separation", 44 if mobile_portrait else 40)
    deck_hbox.alignment = BoxContainer.ALIGNMENT_CENTER

    var card_btns = []
    var q_labels = []

    var card_style = StyleBoxFlat.new()
    if GameState.theme == "light":
        card_style.bg_color = Color(0.92, 0.88, 0.82, 1.0)
        card_style.border_color = Color(0.6, 0.55, 0.5, 0.4)
    else:
        card_style.bg_color = Color(0.12, 0.09, 0.06, 1.0)
        card_style.border_color = Color(0.4, 0.3, 0.2, 0.2)
    _host._apply_style_border_width(card_style, _host._responsive_border_width())
    card_style.corner_radius_top_left = 2;card_style.corner_radius_top_right = 2
    card_style.corner_radius_bottom_left = 2;card_style.corner_radius_bottom_right = 2
    card_style.shadow_size = 4
    card_style.shadow_color = Color(0, 0, 0, 0.15)
    card_style.shadow_offset = Vector2(0, 2)


    var card_noise_tex: = GrainTexture.build_card_noise_texture()

    for i in range(gaps_to_roll.size()):
        var col = VBoxContainer.new()
        col.alignment = BoxContainer.ALIGNMENT_CENTER
        col.add_theme_constant_override("separation", 20 if mobile_portrait else 16)

        if is_multi:
            var stat_info_box = VBoxContainer.new()
            stat_info_box.alignment = BoxContainer.ALIGNMENT_CENTER
            stat_info_box.add_theme_constant_override("separation", 8 if mobile_portrait else 4)

            var req_lbl = Label.new()
            var current_val = _host._get_stat_or_resource_value(keys_to_roll[i])
            req_lbl.text = "当前%s%d，%s≥%d可直接通过" % [labels_to_roll[i], current_val, labels_to_roll[i], targets_to_roll[i]]
            req_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            req_lbl.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_BODY_FONT_SIZE if mobile_portrait else 13)

            var diff_lbl = Label.new()
            diff_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            diff_lbl.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_BODY_FONT_SIZE if mobile_portrait else 12)
            diff_lbl.add_theme_font_override("font", FontLoader.serif_bold())

            var cur_diff_color = GameState.get_theme_color("req_red")
            if gaps_to_roll[i] <= 0:
                diff_lbl.text = "状态: 已达标"
                cur_diff_color = GameState.get_theme_color("req_green")
                req_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
                diff_lbl.add_theme_color_override("font_color", cur_diff_color)
            else:
                diff_lbl.text = "难度: %d级 %s" % [threshs[i].level, threshs[i].dots]
                if threshs[i].level <= 1:
                    cur_diff_color = GameState.get_theme_color("req_green")
                elif threshs[i].level <= 3:
                    cur_diff_color = GameState.get_theme_color("req_yellow")
                req_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
                diff_lbl.add_theme_color_override("font_color", cur_diff_color)

            stat_info_box.add_child(diff_lbl)
            stat_info_box.add_child(req_lbl)

            if gaps_to_roll[i] > 0:
                var pass_hint_lbl = _make_pass_hint_rich_label(
                    int(threshs[i].min), 
                    cur_diff_color, 
                    _host.MOBILE_GAME_MODAL_BODY_FONT_SIZE if mobile_portrait else 12, 
                    GameState.get_theme_color("text_sub")
                )
                stat_info_box.add_child(pass_hint_lbl)

            col.add_child(stat_info_box)

        var deck_container = CenterContainer.new()
        var deck_container_size: float = _host.MOBILE_DICE_DECK_CONTAINER_SIZE if mobile_portrait else 120.0
        var dice_card_size: float = _host.MOBILE_DICE_CARD_SIZE if mobile_portrait else 100.0
        deck_container.custom_minimum_size = Vector2(deck_container_size, deck_container_size)

        var deck_anchor = Control.new()
        deck_anchor.custom_minimum_size = Vector2(dice_card_size, dice_card_size)
        deck_container.add_child(deck_anchor)

        var deck_stack = Control.new()
        deck_stack.size = Vector2(dice_card_size, dice_card_size)
        deck_anchor.add_child(deck_stack)

        for j in range(5, 0, -1):
            var bg_card = Panel.new()
            bg_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
            bg_card.add_theme_stylebox_override("panel", card_style)
            bg_card.draw.connect( func():
                bg_card.draw_texture_rect(card_noise_tex, Rect2(Vector2(1, 1), bg_card.size - Vector2(2, 2)), true)
            )
            bg_card.size = Vector2(dice_card_size, dice_card_size)
            bg_card.pivot_offset = Vector2(dice_card_size * 0.5, dice_card_size * 0.5)
            bg_card.rotation_degrees = (j % 3 - 1) * 3.5 + randf_range(-1.5, 1.5)
            bg_card.position = Vector2(j * 1.5, j * 2.5)
            deck_stack.add_child(bg_card)

        var card_btn = Button.new()
        card_btn.mouse_filter = Control.MOUSE_FILTER_STOP
        var q_label = Label.new()
        q_label.text = "？"
        if gaps_to_roll[i] <= 0:
            q_label.add_theme_color_override("font_color", Color(0.25, 0.65, 0.35, 1.0) if GameState.theme == "light" else Color(0.45, 0.85, 0.55, 1.0))
        else:
            q_label.add_theme_color_override("font_color", Color(0.4, 0.35, 0.25, 0.9) if GameState.theme == "light" else Color(0.9, 0.85, 0.75, 0.9))
        q_label.position = Vector2(4, -6)

        q_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        q_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        q_label.size = Vector2(dice_card_size, dice_card_size)
        q_label.add_theme_font_override("font", _host.DIANSHI_SYMBOL_FONT)
        q_label.add_theme_font_size_override("font_size", _host.MOBILE_DICE_SYMBOL_FONT_SIZE if mobile_portrait else 54)

        card_btn.size = Vector2(dice_card_size, dice_card_size)
        card_btn.pivot_offset = Vector2(dice_card_size * 0.5, dice_card_size * 0.5)
        var front_style = card_style.duplicate()
        front_style.bg_color = Color(0.94, 0.9, 0.82, 1.0) if GameState.theme == "light" else Color(0.14, 0.1, 0.07, 1.0)
        card_btn.add_theme_stylebox_override("normal", front_style)
        card_btn.add_theme_stylebox_override("hover", front_style)
        card_btn.add_theme_stylebox_override("pressed", front_style)

        card_btn.set_meta("show_back_noise", true)
        card_btn.draw.connect( func():
            if card_btn.get_meta("show_back_noise", false):
                card_btn.draw_texture_rect(card_noise_tex, Rect2(Vector2(1, 1), card_btn.size - Vector2(2, 2)), true)
        )
        card_btn.add_child(q_label)
        deck_stack.add_child(card_btn)

        col.add_child(deck_container)
        deck_hbox.add_child(col)
        card_btns.append(card_btn)
        q_labels.append(q_label)

    vbox.add_child(deck_hbox)

    var hint = Label.new()
    hint.text = "同 时 抽 取" if is_multi else "点 击 抽 取"
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_BODY_FONT_SIZE if mobile_portrait else 14)
    hint.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    vbox.add_child(hint)

    panel.add_child(vbox)
    panel.custom_minimum_size = Vector2(_host._get_mobile_game_modal_width(vp_size.x), 0) if mobile_portrait else (Vector2(760, 0) if _host._is_native_mobile_landscape() else Vector2(560, 420))
    center.add_child(panel)

    var nums = ["", "一", "二", "三", "四", "五", "六"]

    var perform_roll = func():
        if _host._dice_overlay_rolled: return
        _host._dice_overlay_rolled = true
        hint.text = ""

        var is_forced_win = GameState.force_dice_win
        if is_forced_win:
            GameState.force_dice_win = false

        var success_all = true
        var final_rolls = []
        var failed_keys = []
        if is_pure_chance:
            var won: bool = is_forced_win or (randf() < pure_chance_rate)
            var display_roll: int
            if won:
                display_roll = maxi(threshs[0].min, 1)
                if display_roll < 6:
                    display_roll = display_roll + randi() % (7 - display_roll)
            else:
                display_roll = mini(threshs[0].min - 1, 5)
                if display_roll > 1:
                    display_roll = 1 + randi() % display_roll
                else:
                    display_roll = 1
            final_rolls.append(display_roll)
            if not won:
                success_all = false
        else:
            for i in range(card_btns.size()):
                var roll_val = randi() % 6 + 1
                if is_forced_win and roll_val < threshs[i].min:
                    roll_val = threshs[i].min + randi() % (7 - threshs[i].min)
                final_rolls.append(roll_val)
                if roll_val < threshs[i].min:
                    success_all = false
                    if i < keys_to_roll.size():
                        failed_keys.append(keys_to_roll[i])

        for i in range(card_btns.size()):
            var cbtn = card_btns[i]
            var qlbl = q_labels[i]
            var t = threshs[i]
            var d_stack = cbtn.get_parent()
            var roll_val = final_rolls[i]
            var success = roll_val >= t.min

            var tween = _host.create_tween()
            var ds_pos = d_stack.position

            tween.tween_property(d_stack, "position", ds_pos + Vector2(-5, 0), 0.05)
            tween.tween_property(d_stack, "position", ds_pos + Vector2(5, 0), 0.05)
            tween.tween_property(d_stack, "position", ds_pos + Vector2(-3, 0), 0.05)
            tween.tween_property(d_stack, "position", ds_pos, 0.05)

            var start_pos = cbtn.position
            var p_x = 25 if i == 1 else -25 if is_multi else 25
            var r_d = 0.25 if i == 1 else -0.25 if is_multi else 0.25

            tween.tween_property(cbtn, "position", start_pos + Vector2(p_x, -50), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
            tween.parallel().tween_property(cbtn, "rotation", r_d, 0.3)
            tween.tween_property(cbtn, "scale", Vector2(0, 1), 0.15).set_trans(Tween.TRANS_SINE)

            var is_already_met = t.min < 0
            var reveal_cb = func(l_btn, l_lbl, l_roll, l_success, l_met):

                l_btn.set_meta("show_back_noise", false)
                l_btn.queue_redraw()
                l_lbl.text = nums[l_roll]
                var reveal_green: = Color(0.16, 0.58, 0.3) if GameState.theme == "light" else Color(0.45, 0.85, 0.55)
                var reveal_red: = Color(0.85, 0.15, 0.12) if GameState.theme == "light" else Color(0.95, 0.38, 0.32)
                if l_met:
                    l_lbl.add_theme_color_override("font_color", reveal_green)
                else:
                    l_lbl.add_theme_color_override("font_color", reveal_green if l_success else reveal_red)
                l_lbl.position = Vector2(0, -6)

            tween.tween_callback(reveal_cb.bind(cbtn, qlbl, roll_val, success, is_already_met))

            tween.tween_property(cbtn, "scale", Vector2(1, 1), 0.15).set_trans(Tween.TRANS_SINE)
            tween.tween_property(cbtn, "position", start_pos + Vector2(p_x * 0.1, -10), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
            tween.parallel().tween_property(cbtn, "rotation", 0.0, 0.2)

            if i == card_btns.size() - 1:
                var confirm_cb = func(s_all):
                    hint.text = "天 命 所 归 —— 成 功" if s_all else "力 有 不 逮 —— 失 败"
                    var success_color: = Color(0.16, 0.58, 0.3) if GameState.theme == "light" else Color(0.45, 0.85, 0.55)
                    var fail_color: = Color(0.85, 0.15, 0.12) if GameState.theme == "light" else Color(0.95, 0.38, 0.32)
                    hint.add_theme_font_override("font", FontLoader.serif_bold())
                    hint.add_theme_color_override("font_color", success_color if s_all else fail_color)
                    _host._dice_pending_success = s_all
                    _host._dice_pending_failed_keys = failed_keys
                    _host._dice_overlay_resolved = true
                    show_dice_confirm_button(vbox, overlay, index, ch, s_all, failed_keys, allow_reroll)

                tween.tween_callback(confirm_cb.bind(success_all))

    var trigger_roll_by_touch = func(event: InputEvent):
        var is_tap: bool = (event is InputEventScreenTouch and event.pressed)\
or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)
        if not is_tap:
            return
        if _host._dice_overlay_resolved:
            commit_dice_overlay(overlay, index, ch, _host._dice_pending_success, _host._dice_pending_failed_keys)
        else:
            perform_roll.call()

    hint.mouse_filter = Control.MOUSE_FILTER_PASS
    hint.gui_input.connect(trigger_roll_by_touch)
    panel.mouse_filter = Control.MOUSE_FILTER_PASS
    panel.gui_input.connect(trigger_roll_by_touch)
    overlay.gui_input.connect(trigger_roll_by_touch)

    for cbtn in card_btns:
        cbtn.pressed.connect(perform_roll)

    _host.add_child(overlay)
    NativeMobileFontScalerRef.apply_to(overlay)

func show_dice_confirm_button(vbox: VBoxContainer, overlay: ColorRect, index: int, ch: Dictionary, success: bool, failed_keys: Array, allow_reroll: bool = false) -> void :
    for child in vbox.get_children():
        if child is CenterContainer and child.get_child_count() > 0:
            var inner = child.get_child(0)
            if inner is Button and "确认" in inner.text.replace(" ", ""):
                return
            if inner is HBoxContainer:
                for b in inner.get_children():
                    if b is Button and "确认" in b.text.replace(" ", ""):
                        return

    var confirm_center = CenterContainer.new()
    var confirm_btn = Button.new()
    confirm_btn.mouse_filter = Control.MOUSE_FILTER_STOP
    confirm_btn.text = "确  认"
    confirm_btn.custom_minimum_size = Vector2(_host.MOBILE_GAME_MODAL_ACTION_WIDTH, _host.MOBILE_GAME_MODAL_ACTION_HEIGHT) if _host._is_mobile_portrait() else Vector2(140, 40)
    confirm_btn.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_ACTION_FONT_SIZE if _host._is_mobile_portrait() else 14)
    confirm_btn.add_theme_font_override("font", FontLoader.serif_bold())

    GameScreenStyleFactory.apply_command_button_style(confirm_btn, "primary", 18, 8)

    confirm_btn.pressed.connect( func():
        confirm_btn.disabled = true
        commit_dice_overlay(overlay, index, ch, success, failed_keys)
    )
    confirm_btn.gui_input.connect( func(event: InputEvent):
        if (event is InputEventScreenTouch and event.pressed)\
or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
            confirm_btn.disabled = true
            commit_dice_overlay(overlay, index, ch, success, failed_keys)
    )

    if allow_reroll and GameState.is_simple_mode():
        var reroll_btn = make_dice_reroll_button(overlay, index, ch)
        var row = HBoxContainer.new()
        row.add_theme_constant_override("separation", 16 if _host._is_mobile_portrait() else 12)
        row.alignment = BoxContainer.ALIGNMENT_CENTER
        row.add_child(reroll_btn)
        row.add_child(confirm_btn)
        confirm_center.add_child(row)
    else:
        confirm_center.add_child(confirm_btn)
    vbox.add_child(confirm_center)

func make_dice_reroll_button(overlay: ColorRect, index: int, ch: Dictionary) -> Button:
    var reroll_btn = Button.new()
    reroll_btn.mouse_filter = Control.MOUSE_FILTER_STOP
    reroll_btn.text = "再试一次"
    reroll_btn.custom_minimum_size = Vector2(_host.MOBILE_GAME_MODAL_ACTION_WIDTH, _host.MOBILE_GAME_MODAL_ACTION_HEIGHT) if _host._is_mobile_portrait() else Vector2(140, 40)
    reroll_btn.add_theme_font_size_override("font_size", _host.MOBILE_GAME_MODAL_ACTION_FONT_SIZE if _host._is_mobile_portrait() else 14)
    reroll_btn.add_theme_font_override("font", FontLoader.serif_bold())
    GameScreenStyleFactory.apply_command_button_style(reroll_btn, "secondary", 18, 8)
    var do_reroll = func():
        if not is_instance_valid(overlay) or _host._dice_overlay_committed\
or bool(overlay.get_meta("reroll_requested", false)):
            return
        overlay.set_meta("reroll_requested", true)
        overlay.name = "DiceOverlayClosing"
        overlay.queue_free()
        show_dice_overlay(index, ch, false)
    reroll_btn.pressed.connect(do_reroll)
    reroll_btn.gui_input.connect( func(event: InputEvent):
        if (event is InputEventScreenTouch and event.pressed)\
or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
            do_reroll.call()
    )
    return reroll_btn

func commit_dice_overlay(overlay: ColorRect, index: int, ch: Dictionary, success: bool, failed_keys: Array) -> void :
    if _host._dice_overlay_committed:
        return
    _host._dice_overlay_committed = true
    _host.get_viewport().set_input_as_handled()
    if is_instance_valid(overlay):
        overlay.queue_free()
    _host._resolve_choice_internal(index, ch, true, success, failed_keys)

func _make_pass_hint_rich_label(min_val: int, diff_color: Color, font_size: int, text_sub_color: Color) -> RichTextLabel:
    var lbl = RichTextLabel.new()
    lbl.bbcode_enabled = true
    lbl.fit_content = true
    lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    lbl.add_theme_font_size_override("normal_font_size", font_size)
    lbl.add_theme_font_override("normal_font", FontLoader.body())
    lbl.add_theme_color_override("default_color", text_sub_color)

    if min_val <= -99:
        lbl.text = "[center]无需投骰即可通过[/center]"
        return lbl

    var number_map = {
        1: "一", 
        2: "二", 
        3: "三", 
        4: "四", 
        5: "五", 
        6: "六"
    }
    var pass_numbers = []
    var start_val = max(1, min_val)
    for i in range(start_val, 7):
        pass_numbers.append(number_map[i])

    if pass_numbers.size() == 0:
        lbl.text = "[center]结果不可通过[/center]"
        return lbl

    var pass_str = ""
    for val in pass_numbers:
        pass_str += val

    var hex_color = diff_color.to_html(false)
    lbl.text = "[center]结果为  [color=#" + hex_color + "]" + pass_str + "[/color]  可通过[/center]"
    return lbl
