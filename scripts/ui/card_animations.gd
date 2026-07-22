extends RefCounted








static func play_shuffle_deal(month_cards_container: Container) -> void :
    if not is_instance_valid(month_cards_container):
        return
    await month_cards_container.get_tree().process_frame
    await month_cards_container.get_tree().process_frame
    if not month_cards_container.is_inside_tree() or month_cards_container.get_child_count() == 0:
        return


    if is_instance_valid(GameState):
        GameState.play_card_deal_sfx()

    var source_global_pos: = (month_cards_container.get_child(0) as Control).global_position

    for i in range(month_cards_container.get_child_count()):
        var slot: = month_cards_container.get_child(i) as Control
        if slot == null or slot.get_child_count() == 0:
            continue
        var c: = slot.get_child(0) as Control
        if c == null:
            continue
        c.position = source_global_pos - slot.global_position
        c.modulate.a = 0.0

    var t = month_cards_container.create_tween()
    t.set_parallel(true)
    for i in range(month_cards_container.get_child_count()):
        var slot: = month_cards_container.get_child(i) as Control
        if slot == null or slot.get_child_count() == 0:
            continue
        var c: = slot.get_child(0) as Control
        if c == null:
            continue
        t.tween_property(c, "modulate:a", 1.0, 0.2).set_delay(i * 0.1)
        t.tween_property(c, "position", Vector2.ZERO, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(i * 0.1)


static func play_month_card_press(slot: Control) -> void :
    if slot == null or slot.get_child_count() == 0:
        return
    var card: = slot.get_child(0) as Control
    if card == null:
        return
    slot.set_meta("press_animating", true)
    card.pivot_offset = card.size / 2.0
    var original_scale: = card.scale
    var original_modulate: = card.modulate
    var t: = card.create_tween()
    t.tween_property(card, "scale:x", 0.04, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    t.parallel().tween_property(card, "scale:y", original_scale.y * 1.025, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    t.parallel().tween_property(card, "modulate", Color(0.92, 0.82, 0.62, original_modulate.a * 0.72), 0.18)
    await t.finished
    if is_instance_valid(card):
        var recover_t: = card.create_tween()
        recover_t.tween_property(card, "scale:x", original_scale.x, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
        recover_t.parallel().tween_property(card, "scale:y", original_scale.y, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
        recover_t.parallel().tween_property(card, "modulate", original_modulate, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
        await recover_t.finished
    if is_instance_valid(slot):
        slot.set_meta("press_animating", false)


static func play_month_card_disabled_settle(card: Control) -> void :
    if card == null or not is_instance_valid(card):
        return
    await card.get_tree().process_frame
    if not is_instance_valid(card):
        return
    card.pivot_offset = card.size / 2.0
    card.scale = Vector2(1.035, 1.035)
    card.modulate = Color(1.1, 1.03, 0.86, 0.96)
    var t: = card.create_tween()
    t.tween_property(card, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    t.parallel().tween_property(card, "modulate", Color.WHITE, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


static func play_control_enter(control: Control, delay: float = 0.0, rise: float = 12.0) -> void :
    if control == null or not is_instance_valid(control):
        return
    if control.get_parent() is Container:
        control.modulate.a = 0.0
        var fade_tween: = control.create_tween()
        fade_tween.tween_interval(delay)
        fade_tween.tween_property(control, "modulate:a", 1.0, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
        return
    var target_position: = control.position
    control.position = target_position + Vector2(0, rise)
    control.modulate.a = 0.0
    var t: = control.create_tween()
    t.tween_interval(delay)
    t.tween_property(control, "modulate:a", 1.0, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    t.parallel().tween_property(control, "position", target_position, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)




static func play_chip_pop(chip: Control, delay: float = 0.0) -> void :
    if chip == null or not is_instance_valid(chip):
        return
    chip.modulate.a = 0.0
    chip.scale = Vector2(0.6, 0.6)
    await chip.get_tree().process_frame
    if not is_instance_valid(chip):
        return
    chip.pivot_offset = chip.size / 2.0
    var t: = chip.create_tween()
    t.tween_interval(delay)
    t.tween_property(chip, "modulate:a", 1.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    t.parallel().tween_property(chip, "scale", Vector2.ONE, 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


static func play_result_change_number(container: Control) -> void :
    if container == null or not is_instance_valid(container):
        return
    for child in container.get_children():
        var label: = child as Label
        if label == null or not bool(label.get_meta("is_city_level_effect", false)):
            continue
        var key: = str(label.get_meta("effect_key", ""))
        var value: = int(label.get_meta("effect_value", 0))
        if key == "" or value == 0:
            continue
        var update_text: = func(amount: float, target_label: Label, effect_key: String, effect_value: int):
            if not is_instance_valid(target_label):
                return
            var label_text: String = GameData.city_stat_effect_label(effect_key)
            var sign: = "+" if effect_value > 0 else "-"
            target_label.text = "%s %s%d" % [label_text, sign, int(round(amount))]
        var t: = label.create_tween()
        t.tween_method(update_text.bind(label, key, value), 0.0, float(absi(value)), 0.52).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


static func play_city_level_change_pulses(container: Control) -> void :
    if container == null or not is_instance_valid(container):
        return
    for child in container.get_children():
        var chip: = child as Control
        if chip == null or not bool(chip.get_meta("is_city_level_effect", false)):
            continue
        var value: = int(chip.get_meta("effect_value", 0))
        if value <= 0:
            continue
        chip.pivot_offset = chip.size / 2.0
        var original_scale: = chip.scale
        var original_modulate: = chip.modulate
        var t: = chip.create_tween()
        t.tween_property(chip, "scale", original_scale * 1.08, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
        t.parallel().tween_property(chip, "modulate", Color(1.18, 1.08, 0.82, original_modulate.a), 0.16)
        t.tween_property(chip, "scale", original_scale, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
        t.parallel().tween_property(chip, "modulate", original_modulate, 0.24)



static func play_pulse(node: Control, is_positive: bool, allow_color_flash: bool) -> void :
    if node == null or not node.is_inside_tree():
        return

    node.pivot_offset = node.size / 2.0
    var tween: = node.create_tween()
    node.scale = Vector2(1.25, 1.25)

    var original_modulate = node.modulate
    if allow_color_flash:
        var flash_color = Color(0.95, 0.75, 0.3) if is_positive else Color(0.78, 0.46, 0.42)
        node.modulate = flash_color

    tween.tween_property(node, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    if allow_color_flash:
        tween.parallel().tween_property(node, "modulate", original_modulate, 0.35)
