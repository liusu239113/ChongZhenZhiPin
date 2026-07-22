extends RefCounted
class_name EventPortraitController




var _host

const PORTRAIT_BOTTOM_OVERFLOW_RATIO: = 0.06
const PORTRAIT_ENTER_ALPHA_FROM: = 0.12
const PORTRAIT_ENTER_MIN_OFFSET_X: = 260.0
const PORTRAIT_ENTER_RIGHT_MARGIN: = 36.0
const SPEAKER_ENTER_ALPHA_FROM: = 0.0
const SPEAKER_ENTER_OFFSET_Y: = 12.0
const CONTENT_ENTER_OFFSET_Y: = -18.0
const CONTENT_ENTER_ALPHA_FROM: = 0.0
const CHOICE_ENTER_STAGGER: = 0.055

func _init(host) -> void :
    _host = host

func ensure_layer() -> void :
    if is_instance_valid(_host.event_portrait_layer):
        return
    _host.event_portrait_layer = Control.new()
    _host.event_portrait_layer.name = "EventPortraitLayer"
    _host.event_portrait_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _host.event_portrait_layer.visible = false
    _host.add_child(_host.event_portrait_layer)

    var main_vbox: = _host.get_node("MainVBox") as Control
    _host.move_child(_host.event_portrait_layer, main_vbox.get_index() + 1)
    _host.event_portrait_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)



    _host.event_portrait_backdrop = Control.new()
    _host.event_portrait_backdrop.name = "EventPortraitBackdrop"
    _host.event_portrait_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _host.event_portrait_backdrop.visible = false
    _host.add_child(_host.event_portrait_backdrop)
    _host.move_child(_host.event_portrait_backdrop, main_vbox.get_index())
    _host.event_portrait_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    _host.event_portrait_decor = TextureRect.new()
    _host.event_portrait_decor.name = "DecorBackground"
    _host.event_portrait_decor.texture = null if OS.has_feature("web") else load("res://assets/portraits/portrait_decor_bg.webp")
    _host.event_portrait_decor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _host.event_portrait_decor.stretch_mode = TextureRect.STRETCH_SCALE
    _host.event_portrait_decor.material = PortraitBacking.make_tone_material()
    _host.event_portrait_decor.modulate = Color(1, 1, 1, _host.EVENT_PORTRAIT_DECOR_ALPHA)
    _host.event_portrait_decor.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _host.event_portrait_backdrop.add_child(_host.event_portrait_decor)



    _host.event_portrait_zone = Control.new()
    _host.event_portrait_zone.name = "PortraitZone"
    _host.event_portrait_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _host.event_portrait_zone.clip_contents = false
    _host.event_portrait_backdrop.add_child(_host.event_portrait_zone)


    _host.event_portrait_office_bg = TextureRect.new()
    _host.event_portrait_office_bg.name = "OfficeBackground"
    _host.event_portrait_office_bg.texture = null if OS.has_feature("web") else load(_host.YAMEN_OFFICE_BG_PATH)
    _host.event_portrait_office_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _host.event_portrait_office_bg.stretch_mode = TextureRect.STRETCH_SCALE
    _host.event_portrait_office_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _host.event_portrait_office_bg.visible = false
    _host.event_portrait_zone.add_child(_host.event_portrait_office_bg)



    _host.event_portrait_right_backing = PortraitBacking.make_right_backing()
    _host.event_portrait_right_backing.visible = false
    _host.event_portrait_zone.add_child(_host.event_portrait_right_backing)

    _host.event_portrait_rect = TextureRect.new()
    _host.event_portrait_rect.name = "CharacterPortrait"
    _host.event_portrait_rect.texture = null if OS.has_feature("web") else load("res://assets/portraits/portrait_default.webp")
    _host.event_portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _host.event_portrait_rect.stretch_mode = TextureRect.STRETCH_SCALE
    _host.event_portrait_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


    _host.event_portrait_rect.material = null

    _host.event_portrait_rect.z_as_relative = false
    _host.event_portrait_rect.z_index = 0
    _host.event_portrait_zone.add_child(_host.event_portrait_rect)


    _host.event_portrait_speaker_anchor = VBoxContainer.new()
    _host.event_portrait_speaker_anchor.name = "SpeakerAnchor"
    _host.event_portrait_speaker_anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _host.event_portrait_speaker_anchor.alignment = BoxContainer.ALIGNMENT_BEGIN
    _host.event_portrait_speaker_anchor.z_as_relative = false
    _host.event_portrait_speaker_anchor.z_index = 20
    _host.event_portrait_layer.add_child(_host.event_portrait_speaker_anchor)


    _host.event_portrait_speaker_frame = PanelContainer.new()
    _host.event_portrait_speaker_frame.name = "SpeakerHeaderFrame"
    _host.event_portrait_speaker_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _host.event_portrait_speaker_frame.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    _host.event_portrait_speaker_frame.add_theme_stylebox_override("panel", make_speaker_frame_style())
    _host.event_portrait_speaker_frame.draw.connect(_host._draw_speaker_frame_corners)
    _host.event_portrait_speaker_frame.visible = false
    _host.event_portrait_speaker_anchor.add_child(_host.event_portrait_speaker_frame)

func layout_zone(area_width: float) -> void :
    if OS.has_feature("web"):
        return
    var window_size: Vector2 = _host.get_viewport_rect().size
    _host.event_portrait_zone.set_anchors_preset(Control.PRESET_FULL_RECT)
    _host.event_portrait_zone.anchor_left = 1.0
    _host.event_portrait_zone.offset_left = - area_width
    _host.event_portrait_zone.offset_right = 0
    _host.event_portrait_zone.offset_top = 0
    _host.event_portrait_zone.offset_bottom = 0

    var zone_height: float = maxf(window_size.y, 1.0)

    var content_top: = 0.0
    if _host.top_bar != null and is_instance_valid(_host.top_bar) and _host.top_bar.visible:
        var bar_rect: Rect2 = _host.top_bar.get_global_rect()
        content_top = bar_rect.position.y + bar_rect.size.y


    _host.event_portrait_decor.visible = not (_host.event_portrait_court_mode and not _host.event_portrait_hide_backdrop)


    var target_decor_bg: = "res://assets/portraits/portrait_decor_bg.webp"
    if GameState.branch in ["origin", "origin_fail", "origin_detour", "keju", "keju_continue"]:
        target_decor_bg = "res://assets/portraits/chengjiaobg.webp"
    if _host.event_portrait_decor.texture == null or _host.event_portrait_decor.texture.resource_path != target_decor_bg:
        _host.event_portrait_decor.texture = load(target_decor_bg)

    var decor_mat: = _host.event_portrait_decor.material as ShaderMaterial
    if decor_mat != null:
        var decor_saturation: = 1.0
        var decor_brightness: = 1.0
        if GameState.theme == "light":
            if target_decor_bg.ends_with("portrait_decor_bg.webp"):
                decor_saturation = 0.42
            else:
                decor_saturation = 0.2
        else:
            decor_brightness = 0.3
            if not target_decor_bg.ends_with("portrait_decor_bg.webp"):
                decor_saturation = 0.34
        decor_mat.set_shader_parameter("saturation", decor_saturation)
        decor_mat.set_shader_parameter("brightness", decor_brightness)

    var decor_alpha: float = _host.EVENT_PORTRAIT_DECOR_ALPHA + (0.08 if GameState.theme == "light" else -0.01)
    _host.event_portrait_decor.modulate = Color(1, 1, 1, decor_alpha)
    var decor_tex: Texture2D = _host.event_portrait_decor.texture
    if decor_tex != null and decor_tex.get_height() > 0 and _host.event_portrait_decor.visible:

        var decor_top: = content_top
        var decor_height: float = maxf(zone_height - decor_top, 1.0)
        var decor_width: float = decor_height * float(decor_tex.get_width()) / float(decor_tex.get_height())
        _host.event_portrait_decor.position = Vector2(window_size.x - decor_width, decor_top)
        _host.event_portrait_decor.size = Vector2(decor_width, decor_height)


    var portrait_tex: Texture2D = _host.event_portrait_rect.texture
    if portrait_tex != null and portrait_tex.get_height() > 0:

        var portrait_height: float = zone_height * _host.EVENT_PORTRAIT_HEIGHT_RATIO
        var portrait_width: float = portrait_height * float(portrait_tex.get_width()) / float(portrait_tex.get_height())

        var centered_x: = (area_width - portrait_width) * 0.5
        var right_aligned_x: = area_width - portrait_width
        var portrait_x: float = lerpf(centered_x, right_aligned_x, float(_host.EVENT_PORTRAIT_RIGHT_SHIFT_RATIO)) + float(_host.EVENT_PORTRAIT_RIGHT_OVERFLOW)
        if area_width < portrait_width:
            portrait_x = right_aligned_x + _host.EVENT_PORTRAIT_RIGHT_OVERFLOW
        var portrait_bottom_overflow: = zone_height * PORTRAIT_BOTTOM_OVERFLOW_RATIO
        _host.event_portrait_rect.position = Vector2(portrait_x, zone_height - portrait_height + portrait_bottom_overflow)
        _host.event_portrait_rect.size = Vector2(portrait_width, portrait_height)






        if _host.event_portrait_office_bg != null and is_instance_valid(_host.event_portrait_office_bg):
            _host.event_portrait_office_bg.visible = _host.event_portrait_court_mode and not _host.event_portrait_hide_backdrop
            var office_alpha: float = _host.EVENT_PORTRAIT_OFFICE_BG_ALPHA
            if GameState.theme == "light":
                office_alpha = 0.18
            else:

                office_alpha = 0.24
            _host.event_portrait_office_bg.modulate = Color(1, 1, 1, office_alpha)
            var office_tex: Texture2D = _host.event_portrait_office_bg.texture
            if office_tex != null and office_tex.get_height() > 0:
                var office_height: float = maxf(zone_height - content_top, 1.0)
                var office_width: float = office_height * float(office_tex.get_width()) / float(office_tex.get_height())
                var offset_x: = 0.0
                var offset_y: = 0.0
                if GameState.theme == "dark":

                    office_height = zone_height * 1.1
                    office_width = office_height * float(office_tex.get_width()) / float(office_tex.get_height())
                    offset_x = 220.0
                    offset_y = -80.0

                _host.event_portrait_office_bg.position = Vector2(area_width - office_width + offset_x, content_top + offset_y)
                _host.event_portrait_office_bg.size = Vector2(office_width, office_height)
        if _host.event_portrait_right_backing != null and is_instance_valid(_host.event_portrait_right_backing):
            _host.event_portrait_right_backing.visible = false

    var has_dialogue: bool = _host.speaker_bubble.visible and _host.speaker_line.text.strip_edges() != ""
    var speaker_width: float = clampf(area_width - (56.0 if has_dialogue else 32.0), 240.0, _host.EVENT_PORTRAIT_SPEAKER_MAX_WIDTH)
    if _host.event_portrait_speaker_frame != null and is_instance_valid(_host.event_portrait_speaker_frame):
        _host.event_portrait_speaker_frame.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if has_dialogue else Control.SIZE_SHRINK_END
    _host.event_portrait_speaker_anchor.set_anchors_preset(Control.PRESET_FULL_RECT)
    _host.event_portrait_speaker_anchor.anchor_left = 0.0
    _host.event_portrait_speaker_anchor.anchor_right = 0.0
    _host.event_portrait_speaker_anchor.anchor_top = 0.0
    _host.event_portrait_speaker_anchor.anchor_bottom = 0.0
    if has_dialogue:
        _host.event_portrait_speaker_anchor.offset_left = window_size.x - speaker_width - 24.0
        _host.event_portrait_speaker_anchor.offset_right = window_size.x - 24.0
        _host.event_portrait_speaker_anchor.offset_top = zone_height * _host.EVENT_PORTRAIT_SPEAKER_TOP_RATIO
    else:
        _host.event_portrait_speaker_anchor.offset_left = window_size.x - speaker_width - 24.0
        _host.event_portrait_speaker_anchor.offset_right = window_size.x - 24.0
        _host.event_portrait_speaker_anchor.offset_top = zone_height * 0.72
    _host.event_portrait_speaker_anchor.offset_bottom = -40.0


const SPEAKER_BOTTOM_MARGIN: = 32.0



func clamp_speaker_anchor_bottom() -> void :
    var anchor: VBoxContainer = _host.event_portrait_speaker_anchor
    if anchor == null or not is_instance_valid(anchor) or not anchor.is_visible_in_tree():
        return
    var window_size: Vector2 = _host.get_viewport_rect().size
    var content_bottom: = - INF
    for child in anchor.get_children():
        var ctrl: = child as Control
        if ctrl == null or not ctrl.visible:
            continue
        content_bottom = maxf(content_bottom, ctrl.get_global_rect().end.y)
    if content_bottom == - INF:
        return
    var overflow: float = content_bottom - (window_size.y - SPEAKER_BOTTOM_MARGIN)
    if overflow > 0.0:
        anchor.offset_top = maxf(anchor.offset_top - overflow, 64.0)

func play_loading_animation() -> void :
    if OS.has_feature("web"):
        return
    if not is_instance_valid(_host.event_portrait_layer) or not _host.event_portrait_layer.visible:
        return
    if not is_instance_valid(_host.event_portrait_rect):
        return
    var speaker_frame: = _host.event_portrait_speaker_frame as Control
    var portrait_start_x: float = _host.event_portrait_rect.position.x
    var portrait_enter_x: float = maxf(portrait_start_x + PORTRAIT_ENTER_MIN_OFFSET_X, _host.event_portrait_zone.size.x + PORTRAIT_ENTER_RIGHT_MARGIN)
    _restore_content_enter_targets()
    var narrative_start_y: = _prepare_content_enter(_host.narrative_label, CONTENT_ENTER_OFFSET_Y)
    _prepare_choice_cards_enter()
    var speaker_frame_start_y: = 0.0
    var bubble_start_y: = 0.0
    var has_speaker_frame: bool = speaker_frame != null and is_instance_valid(speaker_frame) and speaker_frame.visible
    var has_bubble: bool = is_instance_valid(_host.speaker_bubble) and _host.speaker_bubble.visible
    if has_speaker_frame:
        speaker_frame_start_y = speaker_frame.position.y
    if has_bubble:
        bubble_start_y = _host.speaker_bubble.position.y
    if _host.event_portrait_loading_tween != null and _host.event_portrait_loading_tween.is_valid():
        _host.event_portrait_loading_tween.kill()

    _host.event_portrait_rect.modulate.a = PORTRAIT_ENTER_ALPHA_FROM
    _host.event_portrait_rect.position.x = portrait_enter_x
    if has_speaker_frame:
        speaker_frame.modulate.a = SPEAKER_ENTER_ALPHA_FROM
        speaker_frame.position.y = speaker_frame_start_y + SPEAKER_ENTER_OFFSET_Y
    if has_bubble:
        _host.speaker_bubble.modulate.a = SPEAKER_ENTER_ALPHA_FROM
        _host.speaker_bubble.position.y = bubble_start_y + SPEAKER_ENTER_OFFSET_Y

    var tween: Tween = _host.create_tween()
    _host.event_portrait_loading_tween = tween
    tween.set_parallel(true)
    tween.tween_property(_host.event_portrait_rect, "modulate:a", 1.0, 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    tween.tween_property(_host.event_portrait_rect, "position:x", portrait_start_x, 0.46).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
    _animate_content_enter(tween, _host.narrative_label, narrative_start_y, 0.1)
    _animate_choice_cards_enter(tween, 0.18)
    if has_speaker_frame:
        tween.tween_property(speaker_frame, "modulate:a", 1.0, 0.24).set_delay(0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
        tween.tween_property(speaker_frame, "position:y", speaker_frame_start_y, 0.24).set_delay(0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    if has_bubble:
        tween.tween_property(_host.speaker_bubble, "modulate:a", 1.0, 0.26).set_delay(0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
        tween.tween_property(_host.speaker_bubble, "position:y", bubble_start_y, 0.26).set_delay(0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _prepare_content_enter(control: Control, offset_y: float) -> float:
    if control == null or not is_instance_valid(control) or not control.visible:
        return 0.0
    var start_y: float = _content_enter_target_y(control)
    control.modulate.a = CONTENT_ENTER_ALPHA_FROM
    control.position.y = start_y + offset_y
    return start_y

func _content_enter_target_y(control: Control) -> float:
    if control.has_meta("event_portrait_enter_target_y"):
        return float(control.get_meta("event_portrait_enter_target_y"))
    control.set_meta("event_portrait_enter_target_y", control.position.y)
    return control.position.y

func _restore_content_enter_targets() -> void :
    for control in _event_content_enter_controls():
        if control == null or not is_instance_valid(control):
            continue
        if control.has_meta("event_portrait_enter_target_y"):
            control.position.y = float(control.get_meta("event_portrait_enter_target_y"))
        control.modulate.a = 1.0

func _event_content_enter_controls() -> Array[Control]:
    var controls: Array[Control] = []
    if is_instance_valid(_host.narrative_label):
        controls.append(_host.narrative_label)
    if is_instance_valid(_host.choices_container):
        for child in _host.choices_container.get_children():
            var choice: = child as Control
            if choice != null:
                controls.append(choice)
    return controls

func _animate_content_enter(tween: Tween, control: Control, start_y: float, delay: float) -> void :
    if tween == null or control == null or not is_instance_valid(control) or not control.visible:
        return
    tween.tween_property(control, "modulate:a", 1.0, 0.3).set_delay(delay).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    tween.tween_property(control, "position:y", start_y, 0.38).set_delay(delay).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

func _prepare_choice_cards_enter() -> void :
    if not is_instance_valid(_host.choices_container) or not _host.choices_container.visible:
        return
    for child in _host.choices_container.get_children():
        var choice: = child as Control
        if choice == null or not choice.visible:
            continue
        choice.set_meta("event_portrait_enter_start_y", _prepare_content_enter(choice, CONTENT_ENTER_OFFSET_Y))

func _animate_choice_cards_enter(tween: Tween, base_delay: float) -> void :
    if tween == null or not is_instance_valid(_host.choices_container) or not _host.choices_container.visible:
        return
    var delay: = base_delay
    for child in _host.choices_container.get_children():
        var choice: = child as Control
        if choice == null or not choice.visible:
            continue
        var start_y: float = float(choice.get_meta("event_portrait_enter_start_y", choice.position.y))
        _animate_content_enter(tween, choice, start_y, delay)
        delay += CHOICE_ENTER_STAGGER

func make_speaker_frame_style() -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0, 0, 0, 0)
    style.content_margin_left = 16
    style.content_margin_right = 24
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    return style

func draw_speaker_frame_corners(frame: Control) -> void :
    if frame == null or not is_instance_valid(frame):
        return
    var w: = frame.size.x
    var h: = frame.size.y
    var cut: = 5.0

    var points: = PackedVector2Array([
        Vector2(cut, 0), 
        Vector2(w - cut, 0), 
        Vector2(w, cut), 
        Vector2(w, h - cut), 
        Vector2(w - cut, h), 
        Vector2(cut, h), 
        Vector2(0, h - cut), 
        Vector2(0, cut)
    ])

    var bg_color: = Color(0.105, 0.09, 0.07, 0.95) if GameState.theme == "light" else Color(0.06, 0.048, 0.036, 0.94)
    frame.draw_polygon(points, PackedColorArray([bg_color]))


    var gold: = GameState.get_theme_color("border_active").darkened(0.68 if GameState.theme == "dark" else 0.5)
    var line_width: = 1.5
    frame.draw_line(Vector2(cut, 0), Vector2(w - cut, 0), gold, line_width)
    frame.draw_line(Vector2(cut, h), Vector2(w - cut, h), gold, line_width)
    frame.draw_line(Vector2(0, cut), Vector2(0, h - cut), gold, line_width)
    frame.draw_line(Vector2(w, cut), Vector2(w, h - cut), gold, line_width)
    frame.draw_line(Vector2(cut, 0), Vector2(0, cut), gold, line_width)
    frame.draw_line(Vector2(w - cut, 0), Vector2(w, cut), gold, line_width)
    frame.draw_line(Vector2(w - cut, h), Vector2(w, h - cut), gold, line_width)
    frame.draw_line(Vector2(cut, h), Vector2(0, h - cut), gold, line_width)

func make_speaker_avatar_circle_style() -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0.09, 0.078, 0.062, 0.88) if GameState.theme == "light" else Color(0.04, 0.032, 0.024, 0.85)
    style.border_width_left = 2
    style.border_width_top = 2
    style.border_width_right = 2
    style.border_width_bottom = 2
    style.border_color = GameState.get_theme_color("border_active")
    style.corner_radius_top_left = 999
    style.corner_radius_top_right = 999
    style.corner_radius_bottom_left = 999
    style.corner_radius_bottom_right = 999
    return style

func apply_speaker_header_frame(active: bool, speaker_box: Control) -> void :
    if _host.event_portrait_speaker_frame == null or not is_instance_valid(_host.event_portrait_speaker_frame):
        return
    var header: = _host.speaker_avatar.get_parent() as Control
    if header == null:
        return
    if active:
        if _host.event_portrait_avatar_orig_style == null:
            _host.event_portrait_avatar_orig_style = _host.speaker_avatar.get_theme_stylebox("normal")
        _host.speaker_avatar.add_theme_stylebox_override("normal", make_speaker_avatar_circle_style())
        _host.speaker_avatar.custom_minimum_size = Vector2(46, 46)
        if header.get_parent() != _host.event_portrait_speaker_frame:
            header.get_parent().remove_child(header)
            _host.event_portrait_speaker_frame.add_child(header)
        if _host.event_portrait_speaker_frame.get_parent() != speaker_box:
            _host.event_portrait_speaker_frame.get_parent().remove_child(_host.event_portrait_speaker_frame)
            speaker_box.add_child(_host.event_portrait_speaker_frame)
        speaker_box.move_child(_host.event_portrait_speaker_frame, 0)
        _host.event_portrait_speaker_frame.visible = true
    else:
        if _host.event_portrait_avatar_orig_style != null:
            _host.speaker_avatar.add_theme_stylebox_override("normal", _host.event_portrait_avatar_orig_style)
            _host.speaker_avatar.custom_minimum_size = Vector2(40, 40)
        if header.get_parent() == _host.event_portrait_speaker_frame:
            _host.event_portrait_speaker_frame.remove_child(header)
            speaker_box.add_child(header)
            speaker_box.move_child(header, 0)
        if _host.event_portrait_speaker_frame.get_parent() != _host.event_portrait_speaker_anchor:
            _host.event_portrait_speaker_frame.get_parent().remove_child(_host.event_portrait_speaker_frame)
            _host.event_portrait_speaker_anchor.add_child(_host.event_portrait_speaker_frame)
        _host.event_portrait_speaker_frame.visible = false

func set_spacer_width(width: float) -> void :
    var spacer: = _host.main_layout.get_node_or_null("EventPortraitSpacer") as Control
    if width <= 0.0:
        if spacer != null:
            spacer.visible = false
            spacer.custom_minimum_size = Vector2.ZERO
        return
    if spacer == null:
        spacer = Control.new()
        spacer.name = "EventPortraitSpacer"
        spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        _host.main_layout.add_child(spacer)
    spacer.visible = true
    spacer.custom_minimum_size = Vector2(width, 0)




func set_event_text_width_constraints(width: float) -> void :
    for node in [_host.narrative_label, _host.flavor_panel, _host.focus_panel, _host.choices_container, _host.result_panel]:
        var control: = node as Control
        if control == null or not is_instance_valid(control):
            continue
        if width > 0.0:
            control.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
            control.custom_minimum_size.x = width
        else:
            control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            control.custom_minimum_size.x = 0
