extends RefCounted
class_name MobileReadingController




var _host

func _init(host) -> void :
    _host = host

func apply_phase_visibility() -> void :
    var mobile: bool = _host._is_mobile_portrait()
    var speaker_box: Control = _host._get_speaker_box_control()
    if not mobile:
        apply_immersive_event_reading(false)
        if is_instance_valid(_host.mobile_continue_button):
            _host.mobile_continue_button.visible = false
        if is_instance_valid(_host.mobile_reading_card):
            _host.mobile_reading_card.visible = true
            _host.mobile_reading_card.custom_minimum_size = Vector2.ZERO
            _host.mobile_reading_card.add_theme_stylebox_override("panel", _host._make_mobile_reading_card_style(false, false))
        if is_instance_valid(_host.mobile_narrative_scroll):
            _host.mobile_narrative_scroll.custom_minimum_size.y = 0
            _host.mobile_narrative_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
        if is_instance_valid(_host.mobile_reading_card_vbox):
            _host.mobile_reading_card_vbox.add_theme_constant_override("separation", 0)
        if is_instance_valid(_host.mobile_narrative_text_margin):
            _host.mobile_narrative_text_margin.add_theme_constant_override("margin_left", 0)
            _host.mobile_narrative_text_margin.add_theme_constant_override("margin_right", 0)
        _host.event_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
        var center_margin: MarginContainer = _host.get_node("MainVBox/Layout/CenterPanel/CenterMargin")
        center_margin.add_theme_constant_override("margin_left", 28)
        center_margin.add_theme_constant_override("margin_right", 32)
        _host.narrative_label.visible = true
        speaker_box.visible = true
        _host.flavor_panel.visible = _host.flavor_label.text.strip_edges() != ""
        _host.focus_panel.visible = false
        _host.choices_container.visible = not _host.result_panel.visible
        _host._update_choice_top_spacer()
        _host._update_dialogue_narrative_spacing()
        _host.next_button.visible = _host.result_panel.visible
        if is_instance_valid(_host.mobile_choice_narrative_container):
            _host.mobile_choice_narrative_container.visible = false

        _host._apply_game_background_mask()
        if _host._is_native_mobile_landscape():
            _host._apply_native_mobile_landscape_compact_layout()
        return

    if GameState.is_governance_mode() and _host.governance_active_card_index < 0 and not _host.result_panel.visible:
        apply_immersive_event_reading(false)
        if is_instance_valid(_host.mobile_continue_button):
            _host.mobile_continue_button.visible = false
        if is_instance_valid(_host.mobile_choice_narrative_container):
            _host.mobile_choice_narrative_container.visible = false
        _host._apply_game_background_mask()
        return

    var reading: bool = _host.mobile_event_phase == "reading"
    apply_immersive_event_reading(reading)
    var mobile_center_margin: MarginContainer = _host.get_node("MainVBox/Layout/CenterPanel/CenterMargin")
    var reading_side_margin: int = _host.MOBILE_EVENT_IMMERSIVE_SIDE_MARGIN if reading else _host.MOBILE_EVENT_READING_SIDE_MARGIN
    mobile_center_margin.add_theme_constant_override("margin_left", reading_side_margin)
    mobile_center_margin.add_theme_constant_override("margin_right", reading_side_margin)
    if reading:
        sync_vertical_center()
    else:
        mobile_center_margin.add_theme_constant_override("margin_top", 0)
    if is_instance_valid(_host.mobile_reading_card):
        _host.mobile_reading_card.visible = reading
        _host.mobile_reading_card.custom_minimum_size = Vector2(0, 0)
        _host.mobile_reading_card.add_theme_stylebox_override("panel", _host._make_mobile_reading_card_style(true, reading))
        _host.mobile_reading_card.queue_redraw()
        if reading:
            _host._sync_mobile_reading_card_height()
    if is_instance_valid(_host.mobile_reading_card_vbox):
        _host.mobile_reading_card_vbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN if reading else Control.SIZE_EXPAND_FILL
        _host.mobile_reading_card_vbox.add_theme_constant_override("separation", int(_host.MOBILE_EVENT_CONTINUE_GAP) if reading else 0)
    if is_instance_valid(_host.mobile_reading_button_spacer):
        _host.mobile_reading_button_spacer.visible = false
        _host.mobile_reading_button_spacer.custom_minimum_size = Vector2.ZERO
        _host.mobile_reading_button_spacer.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    if is_instance_valid(_host.mobile_narrative_text_margin):
        _host.mobile_narrative_text_margin.add_theme_constant_override("margin_left", _host.MOBILE_EVENT_IMMERSIVE_TEXT_MARGIN if reading else 0)
        _host.mobile_narrative_text_margin.add_theme_constant_override("margin_right", _host.MOBILE_EVENT_IMMERSIVE_TEXT_MARGIN if reading else 34)
    if reading:
        _host._sync_mobile_narrative_scroll_height()
        sync_vertical_center()
    if is_instance_valid(_host.mobile_continue_button):
        _host.mobile_continue_button.visible = reading
        _host.mobile_continue_button.custom_minimum_size = Vector2(0, _host.MOBILE_EVENT_CONTINUE_BUTTON_HEIGHT)
        _host.mobile_continue_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _host.mobile_continue_button.add_theme_stylebox_override("normal", _host._make_mobile_continue_button_style(false))
        _host.mobile_continue_button.add_theme_stylebox_override("hover", _host._make_mobile_continue_button_style(true))
        _host.mobile_continue_button.add_theme_stylebox_override("pressed", _host._make_mobile_continue_button_style(true))
        if reading:
            _host._update_mobile_continue_button_reveal()
        else:
            _host.mobile_continue_button.modulate.a = 1.0
            _host.mobile_continue_button.mouse_filter = Control.MOUSE_FILTER_STOP
            _host.mobile_continue_button.disabled = false
    _host.narrative_label.visible = reading
    speaker_box.visible = not reading
    _host.flavor_panel.visible = false
    _host.focus_panel.visible = false
    _host.choices_container.visible = not reading and not _host.result_panel.visible
    _host._update_choice_top_spacer()
    _host._update_dialogue_narrative_spacing()
    _host.result_panel.visible = not reading and _host.result_panel.visible
    _host.next_button.visible = _host.result_panel.visible
    if is_instance_valid(_host.mobile_choice_narrative_container):
        _host.mobile_choice_narrative_container.visible = not reading and _host.mobile_choice_narrative_label.text.strip_edges() != ""

    _host._apply_game_background_mask()

func apply_immersive_event_reading(reading: bool) -> void :
    if not _host._is_mobile_portrait():
        _host.top_bar.visible = true
        _host.mobile_info_panel.visible = false
        _host.mobile_bottom_tabs.visible = false
        _host.stats_section.visible = true
        _host.attitudes_section.visible = true

        _host._sync_event_date_label_visibility()
        return
    _host.top_bar.visible = not reading
    var should_show_detail_panel: bool = not reading and _host.current_left_tab != "jushi"
    _host.mobile_info_panel.visible = should_show_detail_panel
    _host.mobile_bottom_tabs.visible = not reading
    var main_vbox: Node = _host.mobile_bottom_tabs.get_parent()
    if main_vbox.has_node("MobileBottomTopSpacer"):
        main_vbox.get_node("MobileBottomTopSpacer").visible = not reading
    if main_vbox.has_node("MobileBottomSpacer"):
        main_vbox.get_node("MobileBottomSpacer").visible = not reading
    _host.stats_section.visible = not reading
    _host.attitudes_section.visible = not reading
    _host.stage_label.visible = false
    _host._sync_event_date_label_visibility()
    _host.title_rule.visible = false if reading else true
    _host.event_vbox.add_theme_constant_override("separation", _host.MOBILE_EVENT_IMMERSIVE_TITLE_BODY_GAP if reading else 14)
    _host.event_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _host.event_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _host.narrative_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    _host.narrative_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP

func sync_vertical_center() -> void :
    if not _host._is_mobile_portrait() or _host.mobile_event_phase != "reading":
        return
    if not is_instance_valid(_host.event_scroll) or not is_instance_valid(_host.mobile_narrative_scroll):
        return
    var mobile_center_margin: MarginContainer = _host.get_node("MainVBox/Layout/CenterPanel/CenterMargin")
    var title_group: = _host.event_title_label.get_parent() as Control
    if title_group == null:
        return
    var title_height: = title_group.get_combined_minimum_size().y
    var reading_card_height: = 0.0
    if is_instance_valid(_host.mobile_reading_card):
        reading_card_height = _host.mobile_reading_card.custom_minimum_size.y
        if reading_card_height <= 0.0:
            reading_card_height = _host.mobile_reading_card.get_combined_minimum_size().y
    if reading_card_height <= 0.0:
        reading_card_height = _host.mobile_narrative_scroll.custom_minimum_size.y
    if reading_card_height <= 0.0:
        reading_card_height = _host.mobile_narrative_scroll.get_combined_minimum_size().y
    var group_height: float = title_height + _host.MOBILE_EVENT_IMMERSIVE_TITLE_BODY_GAP + reading_card_height
    var available_height: float = _host.event_scroll.size.y
    if available_height <= 0.0:
        available_height = _host.get_viewport_rect().size.y
    var centered_top: = maxf(0.0, (available_height - group_height) * 0.5)
    mobile_center_margin.add_theme_constant_override("margin_top", centered_top)
