extends RefCounted
class_name SidePanelLayoutController




var _host

func _init(host) -> void :
    _host = host

func move_side_panes_to(target: Control) -> void :
    for pane in [_host.zhisu_pane, _host.buqu_pane, _host.zengyi_pane, _host.jushi_pane, _host.dangan_pane, _host.daoju_pane, _host.lingwu_pane]:
        if pane.get_parent() == target:
            continue
        var previous_parent: Node = pane.get_parent()
        if previous_parent:
            previous_parent.remove_child(pane)
        target.add_child(pane)
        pane.set_anchors_preset(Control.PRESET_FULL_RECT)
        pane.offset_left = 0
        pane.offset_top = 0
        pane.offset_right = 0
        pane.offset_bottom = 0
        pane.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        pane.size_flags_vertical = Control.SIZE_EXPAND_FILL

func apply_mobile_jushi_stats_layout() -> void :
    if _host.mobile_jushi_stats_row == null:
        _host.mobile_jushi_stats_row = HBoxContainer.new()
        _host.mobile_jushi_stats_row.name = "MobileJushiStatsRow"
        _host.mobile_jushi_stats_row.add_theme_constant_override("separation", 12)
        _host.mobile_jushi_stats_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

        _host.stats_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _host.attitudes_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    _host.stats_title.add_theme_font_size_override("font_size", 26)
    _host.attitudes_title.add_theme_font_size_override("font_size", 26)
    _host.stats_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    _host.attitudes_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

    set_side_pane_title_row_layout(true)

    var stats_parent: = get_mobile_jushi_stats_parent()
    remove_mobile_jushi_stats_margin_from(_host.event_vbox, stats_parent)
    remove_mobile_jushi_stats_margin_from(_host.governance_vbox, stats_parent)

    var stats_margin: MarginContainer
    if stats_parent.has_node("MobileJushiStatsMargin"):
        stats_margin = stats_parent.get_node("MobileJushiStatsMargin")
    else:
        stats_margin = MarginContainer.new()
        stats_margin.name = "MobileJushiStatsMargin"
        stats_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        stats_parent.add_child(stats_margin)
    if stats_parent == _host.governance_vbox and _host.action_points_row.get_parent() == _host.governance_vbox:
        stats_parent.move_child(stats_margin, mini(_host.action_points_row.get_index() + 1, stats_parent.get_child_count() - 1))
    else:
        stats_parent.move_child(stats_margin, 0)
    stats_margin.add_theme_constant_override("margin_left", 0)
    stats_margin.add_theme_constant_override("margin_top", 0)
    stats_margin.add_theme_constant_override("margin_right", 0)
    stats_margin.add_theme_constant_override("margin_bottom", 14)

    var stats_card_panel: PanelContainer
    if stats_margin.has_node("MobileJushiStatsCard"):
        stats_card_panel = stats_margin.get_node("MobileJushiStatsCard")
    else:
        stats_card_panel = PanelContainer.new()
        stats_card_panel.name = "MobileJushiStatsCard"
        stats_card_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        stats_margin.add_child(stats_card_panel)

    stats_card_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    if _host.mobile_jushi_stats_row.get_parent() != stats_card_panel:
        if _host.mobile_jushi_stats_row.get_parent():
            _host.mobile_jushi_stats_row.get_parent().remove_child(_host.mobile_jushi_stats_row)
        stats_card_panel.add_child(_host.mobile_jushi_stats_row)
        if _host.attitudes_section.get_parent() != _host.mobile_jushi_stats_row:
            if _host.attitudes_section.get_parent():
                _host.attitudes_section.get_parent().remove_child(_host.attitudes_section)
            _host.mobile_jushi_stats_row.add_child(_host.attitudes_section)
        _host.attitudes_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _host.attitudes_section.visible = true

    _host.attitudes_panel.custom_minimum_size = Vector2(0, 0)
    _host._apply_font_floor_recursive(_host.attitudes_section, 22)
    set_jushi_separators_visible(false)

func apply_mobile_dangan_stats_layout() -> void :
    if _host.stats_section.get_parent() != _host.dangan_vbox:
        if _host.stats_section.get_parent():
            _host.stats_section.get_parent().remove_child(_host.stats_section)
        _host.dangan_vbox.add_child(_host.stats_section)
    _host.dangan_vbox.move_child(_host.stats_section, 0)

    if _host.archive_section.get_parent() != _host.dangan_vbox:
        if _host.archive_section.get_parent():
            _host.archive_section.get_parent().remove_child(_host.archive_section)
        _host.dangan_vbox.add_child(_host.archive_section)
    _host.dangan_vbox.move_child(_host.archive_section, 1)
    _host.archive_section.visible = true
    _host.stats_section.visible = true
    _host.stats_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _host.stats_section.size_flags_vertical = Control.SIZE_FILL
    _host.stats_panel.custom_minimum_size = Vector2(0, _host.MOBILE_DANGAN_STATS_PANEL_HEIGHT)
    for child in _host.stats_container.get_children():
        if child is RadarChart:
            child.chart_top_label_reserve = _host.MOBILE_DANGAN_RADAR_LABEL_RESERVE
            child.chart_bottom_label_reserve = _host.MOBILE_DANGAN_RADAR_LABEL_RESERVE
            child.chart_scale = _host.MOBILE_DANGAN_RADAR_SCALE
            child.label_icon_size = _host.MOBILE_DANGAN_RADAR_ICON_SIZE
            break
    _host._apply_font_floor_recursive(_host.stats_section, 22)
    apply_dangan_card_padding(true)

func apply_dangan_card_padding(mobile_portrait: bool) -> void :
    for panel in [_host.archive_panel, _host.tags_panel]:
        panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    var horizontal_padding: float = _host.MOBILE_DANGAN_CARD_SIDE_PADDING if mobile_portrait else 0.0
    var vertical_padding: float = _host.MOBILE_DANGAN_CARD_VERTICAL_PADDING if mobile_portrait else 0.0
    _host.archive_content_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    if mobile_portrait:
        for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
            _host.archive_content_margin.add_theme_constant_override(side, 0)
    else:
        _host.archive_content_margin.add_theme_constant_override("margin_left", 6)
        _host.archive_content_margin.add_theme_constant_override("margin_right", 18)
        _host.archive_content_margin.add_theme_constant_override("margin_top", 0)
        _host.archive_content_margin.add_theme_constant_override("margin_bottom", 0)
    _host.tags_content_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _host.tags_content_margin.add_theme_constant_override("margin_left", horizontal_padding)
    _host.tags_content_margin.add_theme_constant_override("margin_right", horizontal_padding)
    _host.tags_content_margin.add_theme_constant_override("margin_top", vertical_padding)
    _host.tags_content_margin.add_theme_constant_override("margin_bottom", vertical_padding)

func get_mobile_jushi_stats_parent() -> VBoxContainer:
    if is_instance_valid(_host.governance_scroll) and _host.governance_scroll.visible:
        return _host.governance_vbox
    return _host.event_vbox

func remove_mobile_jushi_stats_margin_from(parent: VBoxContainer, keep_parent: Node) -> void :
    if parent == keep_parent or not is_instance_valid(parent):
        return
    if parent.has_node("MobileJushiStatsMargin"):
        var stats_margin = parent.get_node("MobileJushiStatsMargin")
        parent.remove_child(stats_margin)
        stats_margin.queue_free()

func make_mobile_status_dashboard_style() -> StyleBoxFlat:
    var style = StyleBoxFlat.new()
    if GameState.theme == "light":
        style.bg_color = Color(0.94, 0.91, 0.84, 0.58)
        style.border_color = Color(0.62, 0.5, 0.28, 0.34)
        style.shadow_color = Color(0.2, 0.14, 0.08, 0.16)
    else:
        style.bg_color = Color(0.018, 0.017, 0.015, 0.74)
        style.border_color = Color(0.82, 0.64, 0.34, 0.3)
        style.shadow_color = Color(0, 0, 0, 0.34)
    _host._apply_style_border_width(style, _host._responsive_border_width())
    style.corner_radius_top_left = 8
    style.corner_radius_top_right = 8
    style.corner_radius_bottom_left = 8
    style.corner_radius_bottom_right = 8
    style.content_margin_left = 16
    style.content_margin_right = 16
    style.content_margin_top = 16
    style.content_margin_bottom = 16
    style.shadow_size = 14 if GameState.theme == "dark" else 8
    style.shadow_offset = Vector2(0, 4)
    return style

func apply_desktop_jushi_stats_layout(is_final_volume: bool = false) -> void :
    if GameData.active_line == "bianwu":
        if _host.archive_section.get_parent() != _host.dangan_vbox:
            if _host.archive_section.get_parent():
                _host.archive_section.get_parent().remove_child(_host.archive_section)
            _host.dangan_vbox.add_child(_host.archive_section)
        _host.dangan_vbox.move_child(_host.archive_section, 0)
        _host.archive_section.visible = true
        _host.archive_section.size_flags_horizontal = Control.SIZE_FILL
        _host.archive_section.size_flags_vertical = Control.SIZE_FILL
        _host.stats_title.add_theme_font_size_override("font_size", 13)
        _host.stats_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        _host.stats_panel.custom_minimum_size = Vector2(0, 0)
        set_side_pane_title_row_layout(false)
        set_jushi_separators_visible(false)
        return

    if not is_final_volume and _host.stats_section.get_parent() != _host.jushi_vbox:
        if _host.stats_section.get_parent():
            _host.stats_section.get_parent().remove_child(_host.stats_section)
        _host.jushi_vbox.add_child(_host.stats_section)

    if _host.archive_section.get_parent() != _host.jushi_vbox:
        if _host.archive_section.get_parent():
            _host.archive_section.get_parent().remove_child(_host.archive_section)
        _host.jushi_vbox.add_child(_host.archive_section)
    if _host.attitudes_section.get_parent() == _host.jushi_vbox:
        _host.jushi_vbox.remove_child(_host.attitudes_section)
    _host.attitudes_section.visible = false
    if is_final_volume:
        if _host.stats_section.get_parent() == _host.jushi_vbox:
            _host.jushi_vbox.remove_child(_host.stats_section)
    else:
        _host.jushi_vbox.move_child(_host.stats_section, 0)
    _host.jushi_vbox.move_child(_host.archive_section, mini(_host.jushi_vbox.get_child_count() - 1, 2))
    if not is_final_volume:
        _host.stats_section.visible = true
    _host.archive_section.visible = true
    if _host.mobile_jushi_stats_row != null and _host.mobile_jushi_stats_row.get_parent():
        _host.mobile_jushi_stats_row.get_parent().remove_child(_host.mobile_jushi_stats_row)
    remove_mobile_jushi_stats_margin_from(_host.event_vbox, null)
    remove_mobile_jushi_stats_margin_from(_host.governance_vbox, null)
    _host.stats_section.size_flags_horizontal = Control.SIZE_FILL
    _host.archive_section.size_flags_horizontal = Control.SIZE_FILL
    _host.stats_section.size_flags_vertical = Control.SIZE_FILL
    _host.archive_section.size_flags_vertical = Control.SIZE_FILL
    _host.stats_panel.custom_minimum_size = Vector2(0, 0)
    _host.stats_title.add_theme_font_size_override("font_size", 13)
    _host.stats_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    set_side_pane_title_row_layout(false)
    for child in _host.stats_container.get_children():
        if child is RadarChart:
            child.chart_top_label_reserve = RadarChart.CHART_TOP_LABEL_RESERVE_DEFAULT
            child.chart_bottom_label_reserve = RadarChart.CHART_BOTTOM_LABEL_RESERVE_DEFAULT
            child.chart_scale = 1.0
            child.label_icon_size = RadarChart.LABEL_ICON_SIZE_DEFAULT
            break
    set_jushi_separators_visible( not is_final_volume)

func set_side_pane_title_row_layout(mobile_portrait: bool) -> void :
    for row_name in ["StatsTitleRow", "AttitudesTitleRow"]:
        var row = _host.find_child(row_name, true, false)
        if row is HBoxContainer:
            row.custom_minimum_size = Vector2(0, 48) if mobile_portrait else Vector2.ZERO
            row.add_theme_constant_override("separation", 10 if mobile_portrait else 6)
            row.alignment = BoxContainer.ALIGNMENT_BEGIN if mobile_portrait else BoxContainer.ALIGNMENT_CENTER
            row.size_flags_vertical = Control.SIZE_FILL
    for button_name in ["StatsHelpButton", "AttitudesHelpButton"]:
        var button = _host.find_child(button_name, true, false)
        if button is Button:
            button.custom_minimum_size = Vector2(32, 32) if mobile_portrait else Vector2(20, 20)
            button.add_theme_font_size_override("font_size", 29 if mobile_portrait else 13)
            button.add_theme_stylebox_override("normal", _host._make_small_help_button_style(false))
            button.add_theme_stylebox_override("hover", _host._make_small_help_button_style(true))
            button.add_theme_stylebox_override("pressed", _host._make_small_help_button_style(true))

func set_jushi_separators_visible(is_visible: bool) -> void :
    for child in _host.jushi_vbox.get_children():
        if child is HSeparator:
            child.visible = is_visible

func apply_side_pane_font_floor(min_font_size: int) -> void :
    for pane in [_host.zhisu_pane, _host.zengyi_pane, _host.jushi_pane, _host.dangan_pane, _host.daoju_pane, _host.lingwu_pane]:
        _host._apply_font_floor_recursive(pane, min_font_size)

func apply_mobile_detail_tab_typography() -> void :
    if not _host._is_mobile_portrait():
        return
    for pane in [_host.dangan_pane, _host.daoju_pane]:
        _host._apply_font_floor_recursive(pane, _host.MOBILE_DETAIL_PANE_FONT_SIZE)
    set_mobile_detail_titles_left_aligned(true)
    var empty_tags_label: = _host.tags_container.get_node_or_null("EmptyTagsLabel") as Label
    if empty_tags_label:
        empty_tags_label.add_theme_font_size_override("font_size", 28)
        var empty_color: = GameState.get_theme_color("text_sub")
        empty_tags_label.add_theme_color_override("font_color", Color(empty_color.r, empty_color.g, empty_color.b, 0.3))

func set_mobile_detail_titles_left_aligned(is_left_aligned: bool) -> void :
    var alignment: = HORIZONTAL_ALIGNMENT_LEFT if is_left_aligned else HORIZONTAL_ALIGNMENT_CENTER
    var detail_titles: = [
        _host.dangan_pane.get_node_or_null("DanganScroll/DanganVBox/TagsSection/TagsTitle"), 
        _host.archive_title, 
        _host.items_title
    ]
    for title in detail_titles:
        if title is Label:
            title.horizontal_alignment = alignment

func apply_mobile_detail_gradient_bg(show: bool) -> void :
    if _host.mobile_detail_bg_rect != null and is_instance_valid(_host.mobile_detail_bg_rect):
        _host.mobile_detail_bg_rect.queue_free()
        _host.mobile_detail_bg_rect = null

    var bg_node = _host.get_node_or_null("DetailGradientBg")
    if bg_node:
        bg_node.queue_free()

    if show:
        var grad: = Gradient.new()
        grad.set_offset(0, 0.0)
        grad.set_color(0, Color(0.02, 0.018, 0.016, 0.42))
        grad.add_point(0.25, Color(0.05, 0.03, 0.025, 0.34))
        grad.add_point(0.45, Color(0.08, 0.035, 0.03, 0.26))
        grad.add_point(0.55, Color(0.08, 0.035, 0.03, 0.26))
        grad.add_point(0.75, Color(0.05, 0.03, 0.025, 0.34))
        grad.set_offset(1, 1.0)
        grad.set_color(1, Color(0.02, 0.018, 0.016, 0.42))

        var tex: = GradientTexture2D.new()
        tex.gradient = grad
        tex.fill_from = Vector2(0.0, 1.0)
        tex.fill_to = Vector2(1.0, 0.0)
        tex.width = 512
        tex.height = 512

        var style: = StyleBoxTexture.new()
        style.texture = tex
        _host.mobile_info_panel.add_theme_stylebox_override("panel", style)
    else:
        var left_style = _host.left_panel.get_theme_stylebox("panel") as StyleBoxFlat
        if left_style:
            _host.mobile_info_panel.add_theme_stylebox_override("panel", left_style.duplicate())

func apply_side_pane_font_size(font_size: int) -> void :
    for pane in [_host.zhisu_pane, _host.zengyi_pane, _host.jushi_pane, _host.dangan_pane, _host.daoju_pane, _host.lingwu_pane]:
        _host._apply_font_size_recursive(pane, font_size)
