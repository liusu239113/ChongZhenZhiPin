extends RefCounted













const Presenter = preload("res://scripts/ui/game_screen_presenter.gd")
const PersonalStatCapstoneService = preload("res://scripts/services/personal_stat_capstone_service.gd")

var _host

var silver_tooltip_panel: PanelContainer = null
var grain_tooltip_panel: PanelContainer = null
var liumin_tooltip_panel: PanelContainer = null
var renkou_tooltip_panel: PanelContainer = null
var bingyong_tooltip_panel: PanelContainer = null
var city_stat_tooltip_panel: PanelContainer = null
var _active_city_stat_anchor: Control = null

const CITY_STAT_DESCS: = {
    "nongsang": {
        "title": "城池属性 · 农桑等级", 
        "desc": "劝课农桑，发展农业。", 
        "effect": "决定城池每月基础的粮草产出（官粮）。农桑等级越高，每月官粮的基础产出越丰厚。"
    }, 
    "shangmao": {
        "title": "城池属性 · 商贸等级", 
        "desc": "平准物价，鼓励商旅。", 
        "effect": "提供经常性的商税赋税收入（库银）。商贸等级越高，每月库银的基础税收越多。"
    }, 
    "baigong": {
        "title": "城池属性 · 百工等级", 
        "desc": "修造器械，百工治事。", 
        "effect": "决定百工的税赋收入（库银），并提供额外的辅助粮草产出（官粮）。"
    }, 
    "wenjiao": {
        "title": "城池属性 · 文教等级", 
        "desc": "兴学教化，安民育才。", 
        "effect": "安抚民心，每月将部分流民转化为安定的人口（不仅能降低流民暴动风险，还能长远增加丁银税收），并提供少量的文教收入。"
    }, 
    "chengfang": {
        "title": "城池属性 · 城防等级", 
        "desc": "修缮城廓，整饬防务。", 
        "effect": "衡量城防的守备水平。当遭遇突发的盗匪滋扰、流民暴动或敌军围城时，更高的城防能降低城池损失，并在许多军事或守城相关的事件中解锁更好的决策分支。"
    }
}

func _init(host) -> void :
    _host = host

func _is_native_landscape() -> bool:
    return _host.has_method("_is_native_mobile_landscape") and _host._is_native_mobile_landscape()

func _resource_tooltip_title_font_size() -> int:
    if _host._is_mobile_portrait():
        return _host.MOBILE_RESOURCE_TOOLTIP_TITLE_FONT_SIZE
    elif _is_native_landscape():
        return 18
    else:
        return 14

func _resource_tooltip_body_font_size() -> int:
    if _host._is_mobile_portrait():
        return _host.MOBILE_RESOURCE_TOOLTIP_BODY_FONT_SIZE
    elif _is_native_landscape():
        return 17
    else:
        return 13

func _resource_tooltip_hint_font_size() -> int:
    if _host._is_mobile_portrait():
        return _host.MOBILE_RESOURCE_TOOLTIP_HINT_FONT_SIZE
    elif _is_native_landscape():
        return 14
    else:
        return 11

func _make_resource_tooltip_panel() -> PanelContainer:
    var panel = PanelContainer.new()



    panel.position = Vector2(-100000, -100000)
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
    panel.clip_contents = true
    panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    panel.add_to_group("resource_tooltip_overlay")
    var style = StyleBoxFlat.new()
    if GameState.theme == "light":
        style.bg_color = Color.html("E0E2E6")
    else:
        style.bg_color = GameState.get_theme_color("bg_panel")
    style.border_color = GameState.get_theme_color("border_strong")
    _host._apply_style_border_width(style, _host._responsive_border_width())
    var pad: = 34 if _host._is_mobile_portrait() else (16 if _is_native_landscape() else 12)
    style.corner_radius_top_left = 6;style.corner_radius_top_right = 6
    style.corner_radius_bottom_left = 6;style.corner_radius_bottom_right = 6
    style.shadow_size = 0 if GameState.theme == "light" else 12
    style.shadow_color = Color(0.2, 0.15, 0.1, 0.15) if GameState.theme == "light" else Color(0, 0, 0, 0.42)
    style.shadow_offset = Vector2(0, 6)
    style.content_margin_left = pad
    style.content_margin_right = pad
    style.content_margin_top = 26 if _host._is_mobile_portrait() else (13 if _is_native_landscape() else 10)
    style.content_margin_bottom = 26 if _host._is_mobile_portrait() else (13 if _is_native_landscape() else 10)
    panel.add_theme_stylebox_override("panel", style)
    if _host._is_mobile_portrait():
        var viewport_width: float = _host.get_viewport_rect().size.x
        var max_w: = viewport_width * 0.92
        var target_w: = clampf(viewport_width * _host.MOBILE_RESOURCE_TOOLTIP_WIDTH_RATIO, _host.MOBILE_RESOURCE_TOOLTIP_MIN_WIDTH, _host.MOBILE_RESOURCE_TOOLTIP_MAX_WIDTH)
        panel.custom_minimum_size = Vector2(minf(target_w, max_w), 0)
    elif _is_native_landscape():
        panel.custom_minimum_size = Vector2(312.0, 0)
    else:
        panel.custom_minimum_size = Vector2(_host.DESKTOP_RESOURCE_TOOLTIP_MIN_WIDTH, 0)
    return panel

func _clear_resource_tooltips() -> void :
    for node in _host.get_tree().get_nodes_in_group("resource_tooltip_overlay"):
        if node is CanvasLayer or node is Control:
            node.queue_free()
    silver_tooltip_panel = null
    grain_tooltip_panel = null
    liumin_tooltip_panel = null
    renkou_tooltip_panel = null
    bingyong_tooltip_panel = null
    city_stat_tooltip_panel = null
    _active_city_stat_anchor = null

func _has_resource_tooltip_open() -> bool:
    return is_instance_valid(silver_tooltip_panel) or is_instance_valid(grain_tooltip_panel) or is_instance_valid(liumin_tooltip_panel) or is_instance_valid(renkou_tooltip_panel) or is_instance_valid(bingyong_tooltip_panel) or is_instance_valid(city_stat_tooltip_panel)

func _handle_resource_tooltip_dismissal(press_position: Vector2) -> void :
    if is_instance_valid(grain_tooltip_panel) and not grain_tooltip_panel.get_global_rect().has_point(press_position) and not _resource_tooltip_anchor_has_point(_host.grain_label, press_position):
        grain_tooltip_panel.queue_free()
        grain_tooltip_panel = null
    if is_instance_valid(silver_tooltip_panel) and not silver_tooltip_panel.get_global_rect().has_point(press_position) and not _resource_tooltip_anchor_has_point(_host.silver_label, press_position):
        silver_tooltip_panel.queue_free()
        silver_tooltip_panel = null
    if is_instance_valid(liumin_tooltip_panel) and not liumin_tooltip_panel.get_global_rect().has_point(press_position) and not _resource_tooltip_anchor_has_point(_host.refugee_label, press_position):
        liumin_tooltip_panel.queue_free()
        liumin_tooltip_panel = null
    if is_instance_valid(renkou_tooltip_panel) and not renkou_tooltip_panel.get_global_rect().has_point(press_position) and not _resource_tooltip_anchor_has_point(_host.pop_label, press_position):
        renkou_tooltip_panel.queue_free()
        renkou_tooltip_panel = null
    if is_instance_valid(bingyong_tooltip_panel) and not bingyong_tooltip_panel.get_global_rect().has_point(press_position) and not _resource_tooltip_anchor_has_point(_host.bingyong_label, press_position):
        bingyong_tooltip_panel.queue_free()
        bingyong_tooltip_panel = null
    if is_instance_valid(city_stat_tooltip_panel) and not city_stat_tooltip_panel.get_global_rect().has_point(press_position) and ( not is_instance_valid(_active_city_stat_anchor) or not _active_city_stat_anchor.get_global_rect().has_point(press_position)):
        city_stat_tooltip_panel.queue_free()
        city_stat_tooltip_panel = null
        _active_city_stat_anchor = null

func _attach_resource_tooltip_panel(panel: PanelContainer) -> void :
    if not is_instance_valid(panel):
        return
    var overlay_layer: = CanvasLayer.new()
    overlay_layer.name = "ResourceTooltipCanvasLayer"
    overlay_layer.layer = 140
    overlay_layer.add_to_group("resource_tooltip_overlay")
    panel.add_to_group("resource_tooltip_overlay")
    overlay_layer.add_child(panel)
    _host.get_tree().root.add_child(overlay_layer)

func _get_resource_tooltip_anchor(label: Label) -> Control:
    if label == null:
        return null
    var parent: = label.get_parent()
    if parent is Control and str(parent.name).ends_with("_resource_group"):
        return parent as Control
    return label

func _resource_tooltip_anchor_has_point(label: Label, global_point: Vector2) -> bool:
    var anchor: = _get_resource_tooltip_anchor(label)
    return is_instance_valid(anchor) and anchor.get_global_rect().has_point(global_point)

func _prepare_resource_tooltip_width(panel: PanelContainer, panel_width: float) -> void :
    if not is_instance_valid(panel):
        return
    panel.custom_minimum_size = Vector2(panel_width, 0)
    panel.size = Vector2(panel_width, 0)
    var stylebox: = panel.get_theme_stylebox("panel")
    var padding_width: = 0.0
    if stylebox:
        padding_width = stylebox.get_minimum_size().x
    var content_width: = maxf(80.0, panel_width - padding_width)
    for child in panel.get_children():
        if child is Control:
            var content: = child as Control
            content.custom_minimum_size = Vector2(content_width, 0)
            content.size = Vector2(content_width, 0)
            _host._set_autowrap_labels_width_recursive(content, content_width)
    panel.update_minimum_size()

func _finalize_resource_tooltip(panel: PanelContainer, anchor_label: Control) -> void :
    if not is_instance_valid(panel) or not is_instance_valid(anchor_label):
        return
    panel.update_minimum_size()
    var viewport_size: Vector2 = _host.get_viewport_rect().size
    var min_w: float = 312.0 if _is_native_landscape() else _host.DESKTOP_RESOURCE_TOOLTIP_MIN_WIDTH
    var panel_width: = maxf(panel.get_combined_minimum_size().x, min_w)
    if _host._is_mobile_portrait():
        var target_w: = clampf(viewport_size.x * _host.MOBILE_RESOURCE_TOOLTIP_WIDTH_RATIO, _host.MOBILE_RESOURCE_TOOLTIP_MIN_WIDTH, _host.MOBILE_RESOURCE_TOOLTIP_MAX_WIDTH)
        panel_width = minf(target_w, viewport_size.x * 0.92)
    _prepare_resource_tooltip_width(panel, panel_width)


    await _host.get_tree().process_frame
    if not is_instance_valid(panel) or not is_instance_valid(anchor_label):
        return
    panel.custom_minimum_size = Vector2(panel_width, 0)
    panel.size = Vector2(panel_width, 0)
    _position_resource_tooltip(panel, anchor_label)

func _position_resource_tooltip(panel: PanelContainer, anchor_label: Control) -> void :
    var rect = anchor_label.get_global_rect()
    var viewport_size: Vector2 = _host.get_viewport_rect().size
    var margin: = 16.0 if _host._is_mobile_portrait() else 10.0
    var panel_size: = panel.size
    if _host._is_mobile_portrait():
        var x = clampf(rect.position.x + rect.size.x * 0.5 - panel_size.x * 0.5, 12.0, viewport_size.x - panel_size.x - 12.0)
        if rect.end.y + 16 + panel_size.y > viewport_size.y - 24.0:
            panel.global_position = Vector2(x, rect.position.y - panel_size.y - 16)
        else:
            panel.global_position = Vector2(x, rect.end.y + 16)
    else:
        var x: float = rect.position.x
        if x + panel_size.x > viewport_size.x - margin:
            x = rect.end.x - panel_size.x
        x = clampf(x, margin, maxf(margin, viewport_size.x - panel_size.x - margin))
        if rect.end.y + 4.0 + panel_size.y > viewport_size.y - 12.0:
            panel.global_position = Vector2(x, rect.position.y - panel_size.y - 4.0)
        else:
            panel.global_position = Vector2(x, rect.end.y + 4.0)
    panel.z_index = 100

func _show_silver_breakdown_tooltip(anchor: Control = null) -> void :
    _clear_resource_tooltips()

    GameState.update_monthly_breakdowns()
    if GameState.monthly_silver_breakdown.is_empty():
        return

    silver_tooltip_panel = _make_resource_tooltip_panel()

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 6)
    silver_tooltip_panel.add_child(vbox)

    var title = Label.new()
    title.text = "本月库银收支预计"
    title.add_theme_font_size_override("font_size", _resource_tooltip_title_font_size())
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    vbox.add_child(title)

    var hs = HSeparator.new()
    var hs_style = StyleBoxLine.new()
    hs_style.color = GameState.get_theme_color("border_weak")
    hs.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs)

    var net_total = 0
    for item in GameState.monthly_silver_breakdown:
        var val: int = item.get("value", 0)
        net_total += val
        var row = HBoxContainer.new()

        var lbl_name = Label.new()
        lbl_name.text = item.get("label", "")
        lbl_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        lbl_name.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        row.add_child(lbl_name)

        var spacer = Control.new()
        spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        spacer.custom_minimum_size = Vector2(20, 0)
        row.add_child(spacer)

        var lbl_val = Label.new()
        if val > 0:
            lbl_val.text = "+%d" % val
            lbl_val.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
        elif val < 0:
            lbl_val.text = str(val)
            lbl_val.add_theme_color_override("font_color", Presenter.negative_delta_color())
        else:
            lbl_val.text = "0"
            lbl_val.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        lbl_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        row.add_child(lbl_val)

        vbox.add_child(row)

    var hs2 = HSeparator.new()
    hs2.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs2)

    var total_row = HBoxContainer.new()
    var lbl_total_name = Label.new()
    lbl_total_name.text = "净增减"
    lbl_total_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    lbl_total_name.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    total_row.add_child(lbl_total_name)

    var spacer2 = Control.new()
    spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    total_row.add_child(spacer2)

    var lbl_total_val = Label.new()
    if net_total > 0:
        lbl_total_val.text = "+%d" % net_total
        lbl_total_val.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
    elif net_total < 0:
        lbl_total_val.text = str(net_total)
        lbl_total_val.add_theme_color_override("font_color", Presenter.negative_delta_color())
    else:
        lbl_total_val.text = "0"
        lbl_total_val.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    lbl_total_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    total_row.add_child(lbl_total_val)

    vbox.add_child(total_row)
    if PersonalStatCapstoneService.is_active(GameState, "lizheng"):
        var capstone_hint: = Label.new()
        capstone_hint.text = "理政满值：每月库银增加二千两"
        capstone_hint.add_theme_font_size_override("font_size", _resource_tooltip_hint_font_size())
        capstone_hint.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
        vbox.add_child(capstone_hint)

    _attach_resource_tooltip_panel(silver_tooltip_panel)

    await _host.get_tree().process_frame
    var default_anchor: = _get_resource_tooltip_anchor(_host.silver_label)
    _finalize_resource_tooltip(silver_tooltip_panel, anchor if anchor != null else default_anchor)

func _show_grain_breakdown_tooltip(anchor: Control = null) -> void :
    _clear_resource_tooltips()

    GameState.update_monthly_breakdowns()
    if GameState.monthly_grain_breakdown.is_empty():
        return

    grain_tooltip_panel = _make_resource_tooltip_panel()

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 6)
    grain_tooltip_panel.add_child(vbox)

    var title = Label.new()
    title.text = "本月官粮收支预计"
    title.add_theme_font_size_override("font_size", _resource_tooltip_title_font_size())
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    vbox.add_child(title)

    var hs = HSeparator.new()
    var hs_style = StyleBoxLine.new()
    hs_style.color = GameState.get_theme_color("border_weak")
    hs.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs)

    var net_total = 0
    for item in GameState.monthly_grain_breakdown:
        var val: int = item.get("value", 0)
        net_total += val
        var row = HBoxContainer.new()

        var lbl_name = Label.new()
        lbl_name.text = item.get("label", "")
        lbl_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        lbl_name.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        row.add_child(lbl_name)

        var spacer = Control.new()
        spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        spacer.custom_minimum_size = Vector2(20, 0)
        row.add_child(spacer)

        var lbl_val = Label.new()
        if val > 0:
            lbl_val.text = "+%d" % val
            lbl_val.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
        elif val < 0:
            lbl_val.text = str(val)
            lbl_val.add_theme_color_override("font_color", Presenter.negative_delta_color())
        else:
            lbl_val.text = "0"
            lbl_val.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        lbl_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        row.add_child(lbl_val)

        vbox.add_child(row)

    var hs2 = HSeparator.new()
    hs2.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs2)

    var total_row = HBoxContainer.new()
    var lbl_total_name = Label.new()
    lbl_total_name.text = "净增减"
    lbl_total_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    lbl_total_name.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    total_row.add_child(lbl_total_name)

    var spacer2 = Control.new()
    spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    total_row.add_child(spacer2)

    var lbl_total_val = Label.new()
    if net_total > 0:
        lbl_total_val.text = "+%d" % net_total
        lbl_total_val.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
    elif net_total < 0:
        lbl_total_val.text = str(net_total)
        lbl_total_val.add_theme_color_override("font_color", Presenter.negative_delta_color())
    else:
        lbl_total_val.text = "0"
        lbl_total_val.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    lbl_total_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    total_row.add_child(lbl_total_val)

    vbox.add_child(total_row)


    var shortage_tier: Dictionary = GameState.get_grain_shortage_tier()
    var tier_idx: int = int(shortage_tier["tier"])
    if tier_idx >= 1:
        var hs3 = HSeparator.new()
        hs3.add_theme_stylebox_override("separator", hs_style)
        vbox.add_child(hs3)

        var tier_colors: = [
            Color(0.3, 0.7, 0.3), 
            _get_warning_yellow_color(), 
            Color(0.9, 0.55, 0.2), 
            Color(0.85, 0.25, 0.25)
        ]
        var tier_descs: = [
            "", 
            "库存见底前预警，部分百姓开始流散（每月民望 -1）", 
            "官仓已空，百姓断粮流散，已有饿殍（每月民望 -3）", 
            "彻底断粮，饿殍遍野（每月民望 -5）"
        ]
        var badge_row = HBoxContainer.new()
        var badge_name = Label.new()
        badge_name.text = "缺粮告急"
        badge_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        badge_name.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
        badge_row.add_child(badge_name)
        var spacer_b = Control.new()
        spacer_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        spacer_b.custom_minimum_size = Vector2(20, 0)
        badge_row.add_child(spacer_b)
        var badge_val = Label.new()
        badge_val.text = str(shortage_tier["label"])
        badge_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        badge_val.add_theme_color_override("font_color", tier_colors[tier_idx])
        badge_row.add_child(badge_val)
        vbox.add_child(badge_row)

        var badge_desc = Label.new()
        badge_desc.text = tier_descs[tier_idx]
        badge_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        var desc_w: = 286.0 if _is_native_landscape() else 220.0
        badge_desc.custom_minimum_size = Vector2(desc_w, 0)
        badge_desc.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        badge_desc.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        vbox.add_child(badge_desc)

    _attach_resource_tooltip_panel(grain_tooltip_panel)

    await _host.get_tree().process_frame
    var default_anchor: = _get_resource_tooltip_anchor(_host.grain_label)
    _finalize_resource_tooltip(grain_tooltip_panel, anchor if anchor != null else default_anchor)

func _show_bingyong_tooltip(anchor: Control = null) -> void :
    _clear_resource_tooltips()

    GameState.update_monthly_breakdowns()

    var bingyong: int = int(GameState.city.get("bingyong", 0))
    var current_grain: int = int(GameState.city.get("liangshi", 0))
    var current_silver: int = int(GameState.city.get("yinliang", 0))
    var grain_net: = 0
    for item in GameState.monthly_grain_breakdown:
        grain_net += int(item.get("value", 0))
    var silver_net: = 0
    for item in GameState.monthly_silver_breakdown:
        silver_net += int(item.get("value", 0))

    var grain_cost: = bingyong
    var silver_cost: = int(bingyong * 0.5)


    var mutiny_info: = GameState.get_mutiny_info()
    var mutiny_probability: float = mutiny_info.get("probability", 0.0)
    var mutiny_risk_loss: int = mutiny_info.get("deficit_loss", 0)


    var reinforcement: = int(GameState._process_special_items_monthly()["actual_effects"].get("bingyong", 0))
    var net_change: = reinforcement - mutiny_risk_loss

    bingyong_tooltip_panel = _make_resource_tooltip_panel()

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 6)
    bingyong_tooltip_panel.add_child(vbox)

    var title = Label.new()
    title.text = "兵勇增减预计"
    title.add_theme_font_size_override("font_size", _resource_tooltip_title_font_size())
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    vbox.add_child(title)

    var hs = HSeparator.new()
    var hs_style = StyleBoxLine.new()
    hs_style.color = GameState.get_theme_color("border_weak")
    hs.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs)

    var supply_row = HBoxContainer.new()
    var supply_name = Label.new()
    supply_name.text = "粮草消耗"
    supply_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    supply_name.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    supply_row.add_child(supply_name)
    var supply_spacer = Control.new()
    supply_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    supply_spacer.custom_minimum_size = Vector2(20, 0)
    supply_row.add_child(supply_spacer)
    var supply_val = Label.new()
    supply_val.text = "%d/月" % grain_cost
    supply_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    supply_val.add_theme_color_override("font_color", _get_warning_yellow_color() if grain_cost > 0 else GameState.get_theme_color("text_sub"))
    supply_row.add_child(supply_val)
    vbox.add_child(supply_row)

    var pay_row = HBoxContainer.new()
    var pay_name = Label.new()
    pay_name.text = "军饷消耗"
    pay_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    pay_name.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    pay_row.add_child(pay_name)
    var pay_spacer = Control.new()
    pay_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    pay_spacer.custom_minimum_size = Vector2(20, 0)
    pay_row.add_child(pay_spacer)
    var pay_val = Label.new()
    pay_val.text = "%d/月" % silver_cost
    pay_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    pay_val.add_theme_color_override("font_color", _get_warning_yellow_color() if silver_cost > 0 else GameState.get_theme_color("text_sub"))
    pay_row.add_child(pay_val)
    vbox.add_child(pay_row)

    if reinforcement > 0:
        var reinforce_row = HBoxContainer.new()
        var reinforce_name = Label.new()
        reinforce_name.text = "随身增益"
        reinforce_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        reinforce_name.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        reinforce_row.add_child(reinforce_name)
        var reinforce_spacer = Control.new()
        reinforce_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        reinforce_spacer.custom_minimum_size = Vector2(20, 0)
        reinforce_row.add_child(reinforce_spacer)
        var reinforce_val = Label.new()
        reinforce_val.text = "+%d/月" % reinforcement
        reinforce_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        reinforce_val.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
        reinforce_row.add_child(reinforce_val)
        vbox.add_child(reinforce_row)

    var hs_risk = HSeparator.new()
    hs_risk.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs_risk)

    var risk_row = HBoxContainer.new()
    var risk_name = Label.new()
    risk_name.text = "哗变风险"
    risk_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    risk_name.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    risk_row.add_child(risk_name)
    var risk_spacer = Control.new()
    risk_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    risk_spacer.custom_minimum_size = Vector2(20, 0)
    risk_row.add_child(risk_spacer)
    var risk_val = Label.new()
    if mutiny_risk_loss > 0:
        risk_val.text = "%d%%" % int(round(mutiny_probability * 100))
        risk_val.add_theme_color_override("font_color", Presenter.negative_delta_color())
    else:
        risk_val.text = "0%"
        risk_val.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
    risk_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    risk_row.add_child(risk_val)
    vbox.add_child(risk_row)

    var total_row = HBoxContainer.new()
    var total_name = Label.new()
    total_name.text = "哗变减员"
    total_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    total_name.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    total_row.add_child(total_name)
    var total_spacer = Control.new()
    total_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    total_spacer.custom_minimum_size = Vector2(20, 0)
    total_row.add_child(total_spacer)
    var total_val = Label.new()
    if mutiny_risk_loss > 0:
        total_val.text = "-%d/月" % mutiny_risk_loss
        total_val.add_theme_color_override("font_color", Presenter.negative_delta_color())
    else:
        total_val.text = "0/月"
        total_val.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
    total_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    total_row.add_child(total_val)
    vbox.add_child(total_row)

    var hint = Label.new()
    var current_lizheng = int(GameState.stats.get("lizheng", 50))
    var current_wulue = int(GameState.stats.get("wulue", 50))
    var next_grain = current_grain + grain_net
    var next_silver = current_silver + silver_net
    var both_empty: = (next_grain <= 0) and (next_silver <= 0)

    var text_buf: = ""
    if mutiny_risk_loss > 0:
        if both_empty:
            text_buf = "官粮与库银同时见底，理政、武略都压不住，下月极可能爆发激烈哗变。"
        else:
            if current_lizheng > 70 and current_wulue > 70:
                text_buf = "官粮或库银不足，但理政与武略都高于70，哗变概率降到极低（20%）。"
            elif current_lizheng > 70 or current_wulue > 70:
                text_buf = "官粮或库银不足，但理政或武略高于70，哗变概率减半（50%）。"
            else:
                text_buf = "官粮或库银不足，且理政、武略都不高于70，既无力筹措又难以弹压，哗变概率极高（100%）。"
    else:
        text_buf = "兵勇每月消耗官粮与库银。粮饷只要有一项不足，理政或武略高于70可降低哗变概率，两项都高于70则降到极低。"

    hint.text = text_buf + "\n【暴动防御】兵勇数大于等于流民数10%时，则兵力充足，爆发流民哗变、起义时，可使损失减半。"
    hint.add_theme_font_size_override("font_size", _resource_tooltip_hint_font_size())
    hint.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(hint)

    _attach_resource_tooltip_panel(bingyong_tooltip_panel)

    await _host.get_tree().process_frame
    var default_anchor: = _get_resource_tooltip_anchor(_host.bingyong_label)
    _finalize_resource_tooltip(bingyong_tooltip_panel, anchor if anchor != null else default_anchor)

func _show_bianwu_resource_tooltip(resource_key: String, anchor: Control = null) -> void :
    var resolved_anchor: = anchor if anchor != null else _get_bianwu_resource_anchor(resource_key)
    match resource_key:
        "liangcao":
            _show_bianwu_simple_resource_tooltip(resolved_anchor, "粮草", "军中口粮、马料与行军转运的储备。", "【用途】\n· 兵种升级时消耗。\n· 事件、战斗和军务行动会增减粮草。\n\n【获取途径】\n· 后勤等级每月带来粮草。\n· 边市、屯田、转运与战斗奖励可补充。")
        "xiangyin":
            _show_bianwu_simple_resource_tooltip(resolved_anchor, "饷银", "发饷、采购军需与维持军务周转的银两。", "【用途】\n· 兵种升级时消耗。\n· 事件、募兵、边市和军务行动会增减饷银。\n\n【获取途径】\n· 后勤等级每月带来饷银。\n· 边市贸易、朝廷拨给与战斗奖励可补充。")
        "mapi":
            _show_bianwu_mapi_tooltip(resolved_anchor)
        "huoqi":
            _show_bianwu_huoqi_tooltip(resolved_anchor)
        "zhanyi":
            _show_zhanyi_tooltip(resolved_anchor)
        _:
            _show_bingyong_tooltip(resolved_anchor)

func _get_bianwu_resource_anchor(resource_key: String) -> Control:
    match resource_key:
        "liangcao":
            return _get_resource_tooltip_anchor(_host.silver_label)
        "xiangyin":
            return _get_resource_tooltip_anchor(_host.grain_label)
        "mapi":
            return _get_resource_tooltip_anchor(_host.bingyong_label)
        "huoqi":
            return _get_resource_tooltip_anchor(_host.pop_label)
        "zhanyi":
            return _get_resource_tooltip_anchor(_host.refugee_label)
        _:
            return _get_resource_tooltip_anchor(_host.bingyong_label)

func _show_bianwu_mapi_tooltip(anchor: Control = null) -> void :
    _show_bianwu_simple_resource_tooltip(anchor, "马匹", "边军机动与骑兵整备所需的战备资源。", "【用途】\n· 骑兵相关兵种升级时消耗。\n· 部分边务事件、军务行动和战斗结算会增减马匹。\n\n【获取途径】\n· 马政等级每月带来马匹。\n· 边市买马、缴获与军务行动可补充。")

func _show_bianwu_huoqi_tooltip(anchor: Control = null) -> void :
    _show_bianwu_simple_resource_tooltip(anchor, "火器", "火铳、炮械与火药器材的储备。", "【用途】\n· 火器相关兵种升级时消耗。\n· 部分战斗、兵工和边务事件会增减火器。\n\n【获取途径】\n· 兵工等级每月带来火器。\n· 铸造、采购、缴获与战斗奖励可补充。")

func _show_bianwu_simple_resource_tooltip(anchor: Control, title_text: String, desc_text: String, usage_text: String) -> void :
    _clear_resource_tooltips()

    var panel: = _make_resource_tooltip_panel()

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 6)
    panel.add_child(vbox)

    var title = Label.new()
    title.text = title_text
    title.add_theme_font_size_override("font_size", _resource_tooltip_title_font_size())
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    vbox.add_child(title)

    var hs = HSeparator.new()
    var hs_style = StyleBoxLine.new()
    hs_style.color = GameState.get_theme_color("border_weak")
    hs.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs)

    var desc = Label.new()
    desc.text = desc_text
    desc.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    desc.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(desc)

    var hs2 = HSeparator.new()
    hs2.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs2)

    var usage = Label.new()
    usage.text = usage_text
    usage.add_theme_font_size_override("font_size", _resource_tooltip_hint_font_size())
    usage.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    usage.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(usage)

    match title_text:
        "粮草":
            grain_tooltip_panel = panel
        "饷银":
            silver_tooltip_panel = panel
        "马匹":
            bingyong_tooltip_panel = panel
        "火器":
            renkou_tooltip_panel = panel
        _:
            liumin_tooltip_panel = panel

    _attach_resource_tooltip_panel(panel)

    await _host.get_tree().process_frame
    _finalize_resource_tooltip(panel, anchor)

func _show_liumin_tooltip(anchor: Control = null) -> void :
    _clear_resource_tooltips()
    if GameData.active_line == "bianwu":
        _show_zhanyi_tooltip(anchor)
        return

    var riot_info: Dictionary = GameState.get_riot_info()

    liumin_tooltip_panel = _make_resource_tooltip_panel()

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 6)
    liumin_tooltip_panel.add_child(vbox)

    var title = Label.new()
    title.text = "流民暴动风险"
    title.add_theme_font_size_override("font_size", _resource_tooltip_title_font_size())
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    vbox.add_child(title)

    var hs = HSeparator.new()
    var hs_style = StyleBoxLine.new()
    hs_style.color = GameState.get_theme_color("border_weak")
    hs.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs)


    var ratio_row = HBoxContainer.new()
    var ratio_name = Label.new()
    ratio_name.text = "流民占比"
    ratio_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    ratio_name.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    ratio_row.add_child(ratio_name)
    var spacer1 = Control.new()
    spacer1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    spacer1.custom_minimum_size = Vector2(20, 0)
    ratio_row.add_child(spacer1)
    var ratio_val = Label.new()
    ratio_val.text = "%.1f%%" % (float(riot_info.get("ratio", 0.0)) * 100.0)
    ratio_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    var r = float(riot_info.get("ratio", 0.0))
    if r >= 0.5:
        ratio_val.add_theme_color_override("font_color", Presenter.negative_delta_color())
    elif r >= 0.3:
        ratio_val.add_theme_color_override("font_color", Color(0.85, 0.45, 0.2))
    elif r >= 0.15:
        ratio_val.add_theme_color_override("font_color", _get_warning_yellow_color())
    else:
        ratio_val.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
    ratio_row.add_child(ratio_val)
    vbox.add_child(ratio_row)


    var liumin_monthly_change: Dictionary = GameState.get_monthly_liumin_net_change()
    var monthly_growth: int = 0
    monthly_growth = int(liumin_monthly_change.get("base_growth", 0))
    if monthly_growth > 0 or int(liumin_monthly_change.get("settled", 0)) > 0:
        var growth_row = HBoxContainer.new()
        var growth_name = Label.new()
        growth_name.text = "每月涌入"
        growth_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        growth_name.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        growth_row.add_child(growth_name)
        var spacer_g = Control.new()
        spacer_g.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        spacer_g.custom_minimum_size = Vector2(20, 0)
        growth_row.add_child(spacer_g)
        var growth_val = Label.new()
        growth_val.text = "%+d/月" % monthly_growth
        growth_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        if monthly_growth <= 0:
            growth_val.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
        else:
            growth_val.add_theme_color_override("font_color", Presenter.negative_delta_color())
        growth_row.add_child(growth_val)
        vbox.add_child(growth_row)

    var grain_shortage_growth: int = int(liumin_monthly_change.get("grain_shortage_growth", 0))
    if grain_shortage_growth > 0:
        var shortage_row = HBoxContainer.new()
        var shortage_name = Label.new()
        shortage_name.text = "断粮流散"
        shortage_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        shortage_name.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        shortage_row.add_child(shortage_name)
        var spacer_shortage = Control.new()
        spacer_shortage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        spacer_shortage.custom_minimum_size = Vector2(20, 0)
        shortage_row.add_child(spacer_shortage)
        var shortage_val = Label.new()
        shortage_val.text = "+%d/月" % grain_shortage_growth
        shortage_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        shortage_val.add_theme_color_override("font_color", Presenter.negative_delta_color())
        shortage_row.add_child(shortage_val)
        vbox.add_child(shortage_row)

    var wenjiao_settlement: int = int(liumin_monthly_change.get("settled", 0))
    if wenjiao_settlement > 0:
        var settle_row = HBoxContainer.new()
        var settle_name = Label.new()
        settle_name.text = "文教安民"
        settle_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        settle_name.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        settle_row.add_child(settle_name)
        var spacer_s = Control.new()
        spacer_s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        spacer_s.custom_minimum_size = Vector2(20, 0)
        settle_row.add_child(spacer_s)
        var settle_val = Label.new()
        settle_val.text = "-%d/月" % wenjiao_settlement
        settle_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        settle_val.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
        settle_row.add_child(settle_val)
        vbox.add_child(settle_row)

    var ref_death: int = int(liumin_monthly_change.get("ref_death", 0))
    if ref_death > 0:
        var death_row = HBoxContainer.new()
        var death_name = Label.new()
        death_name.text = "流民饿殍"
        death_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        death_name.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        death_row.add_child(death_name)
        var spacer_d = Control.new()
        spacer_d.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        spacer_d.custom_minimum_size = Vector2(20, 0)
        death_row.add_child(spacer_d)
        var death_val = Label.new()
        death_val.text = "-%d/月" % ref_death
        death_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        death_val.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
        death_row.add_child(death_val)
        vbox.add_child(death_row)

    var liumin_item_change: int = int(liumin_monthly_change.get("item_change", 0))
    if liumin_item_change != 0:
        var item_row = HBoxContainer.new()
        var item_name = Label.new()
        item_name.text = "随身增益"
        item_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        item_name.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        item_row.add_child(item_name)
        var spacer_i = Control.new()
        spacer_i.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        spacer_i.custom_minimum_size = Vector2(20, 0)
        item_row.add_child(spacer_i)
        var item_val = Label.new()
        item_val.text = "%+d/月" % liumin_item_change
        item_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())

        item_val.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3) if liumin_item_change < 0 else Presenter.negative_delta_color())
        item_row.add_child(item_val)
        vbox.add_child(item_row)

    var wulue_capstone_reduction: = int(liumin_monthly_change.get("wulue_capstone_reduction", 0))
    if wulue_capstone_reduction > 0:
        var capstone_row: = Label.new()
        capstone_row.text = "武略满值：每月流民减少一千"
        capstone_row.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        capstone_row.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
        vbox.add_child(capstone_row)

    if monthly_growth > 0 or wenjiao_settlement > 0 or ref_death > 0 or liumin_item_change != 0:
        var hs_net = HSeparator.new()
        hs_net.add_theme_stylebox_override("separator", hs_style)
        vbox.add_child(hs_net)

        var net_row = HBoxContainer.new()
        var lbl_liumin_total_name = Label.new()
        lbl_liumin_total_name.text = "净增减"
        lbl_liumin_total_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        lbl_liumin_total_name.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
        net_row.add_child(lbl_liumin_total_name)
        var spacer_net = Control.new()
        spacer_net.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        spacer_net.custom_minimum_size = Vector2(20, 0)
        net_row.add_child(spacer_net)
        var liumin_net_total: int = 0
        liumin_net_total = int(liumin_monthly_change.get("net_change", 0))
        var lbl_liumin_total_val = Label.new()
        lbl_liumin_total_val.text = "%+d/月" % liumin_net_total
        lbl_liumin_total_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        if liumin_net_total > 0:
            lbl_liumin_total_val.add_theme_color_override("font_color", Presenter.negative_delta_color())
        elif liumin_net_total < 0:
            lbl_liumin_total_val.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
        else:
            lbl_liumin_total_val.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        net_row.add_child(lbl_liumin_total_val)
        vbox.add_child(net_row)


    var level_row = HBoxContainer.new()
    var level_name = Label.new()
    level_name.text = "当前等级"
    level_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    level_name.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    level_row.add_child(level_name)
    var spacer2 = Control.new()
    spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    spacer2.custom_minimum_size = Vector2(20, 0)
    level_row.add_child(spacer2)
    var level_val = Label.new()
    var level_label: String = str(riot_info.get("label", "安全"))
    level_val.text = level_label
    level_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    var lv: int = int(riot_info.get("level", 0))
    if lv >= 3:
        level_val.add_theme_color_override("font_color", Presenter.negative_delta_color())
    elif lv == 2:
        level_val.add_theme_color_override("font_color", Color(0.85, 0.45, 0.2))
    elif lv == 1:
        level_val.add_theme_color_override("font_color", _get_warning_yellow_color())
    else:
        level_val.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
    level_row.add_child(level_val)
    vbox.add_child(level_row)


    var prob_row = HBoxContainer.new()
    var prob_name = Label.new()
    prob_name.text = "月触发概率"
    prob_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    prob_name.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    prob_row.add_child(prob_name)
    var spacer3 = Control.new()
    spacer3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    spacer3.custom_minimum_size = Vector2(20, 0)
    prob_row.add_child(spacer3)
    var prob_val = Label.new()
    var prob: float = float(riot_info.get("probability", 0.0))
    if riot_info.get("cooldown", false):
        prob_val.text = "冷却中"
        prob_val.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    else:
        prob_val.text = "%.0f%%" % (prob * 100.0)
        if prob >= 0.5:
            prob_val.add_theme_color_override("font_color", Presenter.negative_delta_color())
        elif prob >= 0.2:
            prob_val.add_theme_color_override("font_color", Color(0.85, 0.45, 0.2))
        elif prob > 0:
            prob_val.add_theme_color_override("font_color", _get_warning_yellow_color())
        else:
            prob_val.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3))
    prob_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    prob_row.add_child(prob_val)
    vbox.add_child(prob_row)


    if lv > 0:
        var hs2 = HSeparator.new()
        hs2.add_theme_stylebox_override("separator", hs_style)
        vbox.add_child(hs2)
        var hint = Label.new()
        hint.text = "兴办文教可安置流民，理政与城防越高，暴动概率越低。"
        hint.add_theme_font_size_override("font_size", _resource_tooltip_hint_font_size())
        hint.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        vbox.add_child(hint)

    _attach_resource_tooltip_panel(liumin_tooltip_panel)

    await _host.get_tree().process_frame
    var default_anchor: = _get_resource_tooltip_anchor(_host.refugee_label)
    _finalize_resource_tooltip(liumin_tooltip_panel, anchor if anchor != null else default_anchor)

func _show_zhanyi_tooltip(anchor: Control = null) -> void :
    _clear_resource_tooltips()

    liumin_tooltip_panel = _make_resource_tooltip_panel()

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 6)
    liumin_tooltip_panel.add_child(vbox)

    var title = Label.new()
    title.text = "战意"
    title.add_theme_font_size_override("font_size", _resource_tooltip_title_font_size())
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    vbox.add_child(title)

    var hs = HSeparator.new()
    var hs_style = StyleBoxLine.new()
    hs_style.color = GameState.get_theme_color("border_weak")
    hs.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs)

    var desc = Label.new()
    desc.text = "日常操练与实战所积攒的军心与备战意志。"
    desc.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    desc.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(desc)

    var hs2 = HSeparator.new()
    hs2.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs2)

    var usage = Label.new()
    usage.text = "【作用】\n· 作为升级兵种等级的关键资源。\n\n【获取途径】\n· 操练兵卒：使用军务类行动卡进行操演。\n· 战斗奖励：在边关战斗中取得胜利。"
    usage.add_theme_font_size_override("font_size", _resource_tooltip_hint_font_size())
    usage.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    usage.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(usage)

    _attach_resource_tooltip_panel(liumin_tooltip_panel)

    await _host.get_tree().process_frame
    var default_anchor: = _get_resource_tooltip_anchor(_host.refugee_label)
    _finalize_resource_tooltip(liumin_tooltip_panel, anchor if anchor != null else default_anchor)

func _show_renkou_tooltip(anchor: Control = null) -> void :
    _clear_resource_tooltips()

    GameState.update_monthly_breakdowns()
    var change: Dictionary = GameState.get_monthly_renkou_net_change()

    renkou_tooltip_panel = _make_resource_tooltip_panel()

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 6)
    renkou_tooltip_panel.add_child(vbox)

    var title = Label.new()
    title.text = "本月人口增减预计"
    title.add_theme_font_size_override("font_size", _resource_tooltip_title_font_size())
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    vbox.add_child(title)

    var hs_style = StyleBoxLine.new()
    hs_style.color = GameState.get_theme_color("border_weak")
    var hs = HSeparator.new()
    hs.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs)

    var pos_color: = Color(0.3, 0.7, 0.3)
    var neg_color: = Presenter.negative_delta_color()


    var natural_growth: int = int(change.get("natural_growth", 0))
    var settled: int = int(change.get("settled", 0))
    var to_refugee: int = int(change.get("to_refugee", 0))
    var pop_death: int = int(change.get("pop_death", 0))

    var rows: = []
    rows.append({"name": "休养生息", "value": natural_growth, "positive": true})
    if settled > 0:
        rows.append({"name": "文教安民入籍", "value": settled, "positive": true})
    if to_refugee > 0:
        rows.append({"name": "断粮流散", "value": - to_refugee, "positive": false})
    if pop_death > 0:
        rows.append({"name": "人口饿殍", "value": - pop_death, "positive": false})

    for r in rows:
        var row = HBoxContainer.new()
        var name_lbl = Label.new()
        name_lbl.text = str(r["name"])
        name_lbl.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        name_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        row.add_child(name_lbl)
        var spacer = Control.new()
        spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        spacer.custom_minimum_size = Vector2(20, 0)
        row.add_child(spacer)
        var val_lbl = Label.new()
        val_lbl.text = "%+d/月" % int(r["value"])
        val_lbl.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
        val_lbl.add_theme_color_override("font_color", pos_color if bool(r["positive"]) else neg_color)
        row.add_child(val_lbl)
        vbox.add_child(row)

    var hs2 = HSeparator.new()
    hs2.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs2)


    var net_change: int = int(change.get("net_change", 0))
    var net_row = HBoxContainer.new()
    var net_name = Label.new()
    net_name.text = "净增减"
    net_name.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    net_name.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    net_row.add_child(net_name)
    var spacer_net = Control.new()
    spacer_net.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    spacer_net.custom_minimum_size = Vector2(20, 0)
    net_row.add_child(spacer_net)
    var net_val = Label.new()
    net_val.text = "%+d/月" % net_change
    net_val.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    if net_change > 0:
        net_val.add_theme_color_override("font_color", pos_color)
    elif net_change < 0:
        net_val.add_theme_color_override("font_color", neg_color)
    else:
        net_val.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    net_row.add_child(net_val)
    vbox.add_child(net_row)


    var tier: int = int(change.get("tier", 0))
    if tier >= 1:
        var hs3 = HSeparator.new()
        hs3.add_theme_stylebox_override("separator", hs_style)
        vbox.add_child(hs3)
        var hint = Label.new()
        hint.text = "缺粮%s导致百姓流散、饿殍；及时补粮可止损。" % str(change.get("tier_label", ""))
        hint.add_theme_font_size_override("font_size", _resource_tooltip_hint_font_size())
        hint.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        vbox.add_child(hint)

    _attach_resource_tooltip_panel(renkou_tooltip_panel)

    await _host.get_tree().process_frame
    var default_anchor: = _get_resource_tooltip_anchor(_host.pop_label)
    _finalize_resource_tooltip(renkou_tooltip_panel, anchor if anchor != null else default_anchor)

func _get_warning_yellow_color() -> Color:
    if GameState.theme == "light":
        return Color(0.66, 0.46, 0.1)
    return Color(0.85, 0.7, 0.2)

func _show_city_stat_tooltip(stat_key: String, anchor: Control) -> void :
    _clear_resource_tooltips()

    if not CITY_STAT_DESCS.has(stat_key):
        return

    var info: Dictionary = CITY_STAT_DESCS[stat_key]
    _active_city_stat_anchor = anchor
    city_stat_tooltip_panel = _make_resource_tooltip_panel()

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 8)
    city_stat_tooltip_panel.add_child(vbox)


    var title = Label.new()
    title.text = info["title"]
    title.add_theme_font_size_override("font_size", _resource_tooltip_title_font_size())
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(title)


    var hs = HSeparator.new()
    var hs_style = StyleBoxLine.new()
    hs_style.color = GameState.get_theme_color("border_weak")
    hs.add_theme_stylebox_override("separator", hs_style)
    vbox.add_child(hs)


    var desc = Label.new()
    desc.text = info["desc"]
    desc.add_theme_font_size_override("font_size", _resource_tooltip_body_font_size())
    desc.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(desc)


    var effect = Label.new()
    effect.text = info["effect"]
    effect.add_theme_font_size_override("font_size", _resource_tooltip_hint_font_size())
    effect.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(effect)
    if stat_key == "wenjiao" and PersonalStatCapstoneService.is_active(GameState, "wentao"):
        var capstone_effect: = Label.new()
        capstone_effect.text = "文韬满值：每三个月文教等级提升一级；%s" % PersonalStatCapstoneService.wentao_progress_text(GameState)
        capstone_effect.add_theme_font_size_override("font_size", _resource_tooltip_hint_font_size())
        capstone_effect.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
        capstone_effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        vbox.add_child(capstone_effect)

    _attach_resource_tooltip_panel(city_stat_tooltip_panel)

    await _host.get_tree().process_frame
    if is_instance_valid(city_stat_tooltip_panel) and is_instance_valid(anchor):
        _finalize_resource_tooltip(city_stat_tooltip_panel, anchor)
