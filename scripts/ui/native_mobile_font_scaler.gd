extends RefCounted

const SCALE: = 1.2
const SPACING_SCALE: = 1.15
const MIN_FONT_SIZE: = 14
const WENKAI_MOBILE_FONT_BONUS: = 2
const TABLET_LANDSCAPE_MIN_SHORT_SIDE_INCHES: = 5.0
const TABLET_LANDSCAPE_FALLBACK_MIN_SHORT_SIDE: = 1200.0
const DESKTOP_ASPECT_RATIO_MAX: = 1.68
const META_BASE_SIZE: = "native_mobile_font_base_size"
const META_SCALED_SIZE: = "native_mobile_font_scaled_size"
const META_BASE_SEPARATION: = "native_mobile_base_separation"
const META_SCALED_SEPARATION: = "native_mobile_scaled_separation"
const META_BASE_MARGINS: = "native_mobile_base_margins"
const META_SCALED_MARGINS: = "native_mobile_scaled_margins"
const META_BASE_MINIMUM_SIZE: = "native_mobile_base_minimum_size"
const META_SCALED_MINIMUM_SIZE: = "native_mobile_scaled_minimum_size"


const META_SKIP_MIN_SIZE_SCALE: = "native_mobile_skip_min_size_scale"
static var landscape_size_mode_override: = "auto"


static func set_landscape_size_mode_override(mode: String) -> void :
    if mode == "tablet":
        landscape_size_mode_override = "desktop"
    elif ["auto", "desktop", "phone"].has(mode):
        landscape_size_mode_override = mode
    else:
        landscape_size_mode_override = "auto"


static func is_native_mobile_landscape(root: Node) -> bool:
    return is_native_phone_landscape(root)


static func is_native_mobile_portrait(root: Node) -> bool:
    if root == null or not (OS.has_feature("android") or OS.has_feature("ios")):
        return false
    var control: = root as Control
    if control == null or not control.is_inside_tree():
        return false
    var window_size: = _get_window_size(root)
    return window_size.y > window_size.x


static func is_native_phone_landscape(root: Node) -> bool:
    if landscape_size_mode_override == "phone":
        return _is_landscape_window(root)
    if landscape_size_mode_override == "desktop":
        return false
    if not (_is_native_android_landscape(root) or _is_web_landscape(root)):
        return false
    return _is_native_android_landscape(root) and not is_native_tablet_landscape(root)


static func is_native_tablet_landscape(root: Node) -> bool:
    if not _is_native_android_landscape(root):
        return false
    if landscape_size_mode_override == "desktop":
        return true
    if landscape_size_mode_override == "phone":
        return false
    var window_size: = _get_window_size(root)
    if _is_desktop_like_landscape_size(window_size):
        return true
    var short_side: = minf(window_size.x, window_size.y)
    var dpi: = _get_screen_dpi()
    if dpi > 0.0:
        return short_side / dpi >= TABLET_LANDSCAPE_MIN_SHORT_SIDE_INCHES
    return short_side >= TABLET_LANDSCAPE_FALLBACK_MIN_SHORT_SIDE


static func _is_desktop_like_landscape_size(window_size: Vector2) -> bool:
    if window_size.x <= 0.0 or window_size.y <= 0.0:
        return false
    if window_size.x <= window_size.y:
        return false
    var aspect: = window_size.x / window_size.y
    return aspect <= DESKTOP_ASPECT_RATIO_MAX


static func _is_landscape_window(root: Node) -> bool:
    var window_size: = _get_window_size(root)
    return window_size.x > window_size.y


static func _is_native_android_landscape(root: Node) -> bool:
    if root == null or not OS.has_feature("android"):
        return false
    var control: = root as Control
    if control == null or not control.is_inside_tree():
        return false
    var window_size: = _get_window_size(root)
    return window_size.x > window_size.y


static func _is_web_landscape(root: Node) -> bool:
    if root == null or not OS.has_feature("web"):
        return false
    var control: = root as Control
    if control == null or not control.is_inside_tree():
        return false
    var window_size: = _get_window_size(root)
    return window_size.x > window_size.y


static func _get_window_size(root: Node) -> Vector2:
    if OS.has_feature("web"):
        var browser_json: = str(JavaScriptBridge.eval("JSON.stringify({ w: window.innerWidth, h: window.innerHeight })"))
        var parsed = JSON.parse_string(browser_json)
        if parsed is Dictionary:
            var width: = float(parsed.get("w", 0.0))
            var height: = float(parsed.get("h", 0.0))
            if width > 0.0 and height > 0.0:
                return Vector2(width, height)
    var window_size: = Vector2(DisplayServer.window_get_size())
    if window_size.x > 0.0 and window_size.y > 0.0:
        return window_size
    var control: = root as Control
    if control != null:
        return control.get_viewport_rect().size
    return Vector2.ZERO


static func _get_screen_dpi() -> float:
    return float(DisplayServer.screen_get_dpi())


static func apply_to(root: Node, scale: float = SCALE) -> void :
    if root == null:
        return
    if is_native_phone_landscape(root):
        _apply_recursive(root, scale)
    elif is_native_mobile_portrait(root):
        _apply_wenkai_font_bonus_recursive(root)


static func reset_scaled_overrides(root: Node) -> void :
    if root == null:
        return
    _reset_scaled_overrides_recursive(root)





static func reset_scaled_minimum_width(root: Node) -> void :
    if root == null:
        return
    _reset_scaled_minimum_width_recursive(root)


static func _reset_scaled_minimum_width_recursive(node: Node) -> void :
    var control: = node as Control
    if control != null and control.has_meta(META_BASE_MINIMUM_SIZE) and control.has_meta(META_SCALED_MINIMUM_SIZE):
        var base_size = control.get_meta(META_BASE_MINIMUM_SIZE)
        var scaled_size = control.get_meta(META_SCALED_MINIMUM_SIZE)
        if base_size is Vector2 and scaled_size is Vector2 and is_equal_approx(control.custom_minimum_size.x, scaled_size.x):
            control.custom_minimum_size.x = base_size.x
            control.set_meta(META_SCALED_MINIMUM_SIZE, Vector2(base_size.x, scaled_size.y))
    for child in node.get_children():
        _reset_scaled_minimum_width_recursive(child)


static func _apply_recursive(node: Node, scale: float) -> void :
    var control: = node as Control
    if control != null:
        if _should_skip_native_mobile_font_scale(control):
            return
        _scale_control_font(control, scale)
        _scale_control_minimum_size(control, scale)
        _scale_control_spacing(control)
    for child in node.get_children():
        _apply_recursive(child, scale)


static func _should_skip_native_mobile_font_scale(control: Control) -> bool:
    var curr: Node = control
    while curr != null:


        if curr.name in ["LeftTabs", "SettingsPopup"]:
            return true
        curr = curr.get_parent()
    return false


static func _apply_wenkai_font_bonus_recursive(node: Node) -> void :
    var control: = node as Control
    if control != null:
        _apply_wenkai_font_bonus(control)
    for child in node.get_children():
        _apply_wenkai_font_bonus_recursive(child)


static func _reset_scaled_overrides_recursive(node: Node) -> void :
    var control: = node as Control
    if control != null:
        _reset_control_font(control)
        _reset_control_minimum_size(control)
        _reset_control_spacing(control)
    for child in node.get_children():
        _reset_scaled_overrides_recursive(child)


static func _scale_control_font(control: Control, scale: float) -> void :
    if not (control is Label or control is Button or control is RichTextLabel or control is LinkButton):
        return
    var current_size: = int(control.get_theme_font_size("font_size"))
    if current_size <= 0:
        return

    var previous_scaled: = int(control.get_meta(META_SCALED_SIZE, -1))
    var base_size: = int(control.get_meta(META_BASE_SIZE, current_size))
    if current_size != previous_scaled:
        base_size = current_size
        control.set_meta(META_BASE_SIZE, base_size)

    var scaled_size: = maxi(base_size + 2, int(ceil(float(base_size) * scale)))
    scaled_size = maxi(scaled_size, MIN_FONT_SIZE)
    if _is_settlement_or_narrative(control):
        scaled_size += 2

    if _uses_lxgw_wenkai(control):
        scaled_size += WENKAI_MOBILE_FONT_BONUS

    control.set_meta(META_SCALED_SIZE, scaled_size)
    control.add_theme_font_size_override("font_size", scaled_size)


static func _apply_wenkai_font_bonus(control: Control) -> void :
    if not (control is Label or control is Button or control is RichTextLabel or control is LinkButton):
        return
    if not _uses_lxgw_wenkai(control):
        return
    var current_size: = int(control.get_theme_font_size("font_size"))
    if current_size <= 0:
        return

    var previous_scaled: = int(control.get_meta(META_SCALED_SIZE, -1))
    var base_size: = int(control.get_meta(META_BASE_SIZE, current_size))
    if current_size != previous_scaled:
        base_size = current_size
        control.set_meta(META_BASE_SIZE, base_size)

    var scaled_size: = base_size + WENKAI_MOBILE_FONT_BONUS
    control.set_meta(META_SCALED_SIZE, scaled_size)
    control.add_theme_font_size_override("font_size", scaled_size)


static func _uses_lxgw_wenkai(control: Control) -> bool:
    var current_font: Font = null
    if control is RichTextLabel:
        current_font = control.get_theme_font("normal_font")
    else:
        current_font = control.get_theme_font("font")
    return current_font != null and current_font.resource_path.contains("LXGWWenKai")


static func _is_settlement_or_narrative(control: Control) -> bool:
    if control == null:
        return false
    var name_lower: = control.name.to_lower()
    if name_lower.contains("narrative") or name_lower == "speakerline" or name_lower == "speaker_line" or name_lower == "endingcomment" or name_lower == "ending_comment":
        return true

    var curr: = control.get_parent()
    while curr != null:
        var curr_name_lower: = curr.name.to_lower()
        if curr_name_lower.contains("resultpanel") or curr_name_lower.contains("result_panel") or curr_name_lower.contains("endingscreen") or curr_name_lower.contains("ending_screen"):
            return true
        var script = curr.get_script()
        if script:
            var script_path: String = script.resource_path.to_lower()
            if script_path.contains("ending_screen") or script_path.contains("ending_screen.gd"):
                return true
        curr = curr.get_parent()
    return false


static func _reset_control_font(control: Control) -> void :
    if not (control is Label or control is Button or control is RichTextLabel or control is LinkButton):
        return


    if control.has_meta(META_BASE_SIZE) and control.has_meta(META_SCALED_SIZE):
        var base_size: = int(control.get_meta(META_BASE_SIZE))
        var scaled_size: = int(control.get_meta(META_SCALED_SIZE))
        var current_size: = int(control.get_theme_font_size("font_size"))
        if base_size > 0 and current_size == scaled_size:
            control.add_theme_font_size_override("font_size", base_size)
    if control.has_meta(META_BASE_SIZE):
        control.remove_meta(META_BASE_SIZE)
    if control.has_meta(META_SCALED_SIZE):
        control.remove_meta(META_SCALED_SIZE)


static func _scale_control_minimum_size(control: Control, scale: float) -> void :
    if control.has_meta(META_SKIP_MIN_SIZE_SCALE):
        return
    var current_size: = control.custom_minimum_size
    if current_size == Vector2.ZERO:
        return

    var previous_scaled = control.get_meta(META_SCALED_MINIMUM_SIZE, Vector2(-1.0, -1.0))
    var base_size = control.get_meta(META_BASE_MINIMUM_SIZE, current_size)
    if not (previous_scaled is Vector2) or current_size != previous_scaled:
        base_size = current_size
        control.set_meta(META_BASE_MINIMUM_SIZE, base_size)

    if not (base_size is Vector2):
        return
    var scaled_size: = Vector2(
        ceilf(float(base_size.x) * scale) if base_size.x > 0.0 else 0.0, 
        ceilf(float(base_size.y) * scale) if base_size.y > 0.0 else 0.0
    )
    control.set_meta(META_SCALED_MINIMUM_SIZE, scaled_size)
    control.custom_minimum_size = scaled_size


static func _reset_control_minimum_size(control: Control) -> void :


    if control.has_meta(META_BASE_MINIMUM_SIZE) and control.has_meta(META_SCALED_MINIMUM_SIZE):
        var base_size = control.get_meta(META_BASE_MINIMUM_SIZE)
        var scaled_size = control.get_meta(META_SCALED_MINIMUM_SIZE)
        if base_size is Vector2 and scaled_size is Vector2 and control.custom_minimum_size == scaled_size:
            control.custom_minimum_size = base_size
    if control.has_meta(META_BASE_MINIMUM_SIZE):
        control.remove_meta(META_BASE_MINIMUM_SIZE)
    if control.has_meta(META_SCALED_MINIMUM_SIZE):
        control.remove_meta(META_SCALED_MINIMUM_SIZE)


static func _scale_control_spacing(control: Control) -> void :

    if control is VBoxContainer or control is HBoxContainer:
        _scale_separation(control, "separation")
    elif control is GridContainer:
        _scale_separation(control, "h_separation")
        _scale_separation(control, "v_separation")


    if control is MarginContainer:
        _scale_margin(control)


static func _reset_control_spacing(control: Control) -> void :
    if control is VBoxContainer or control is HBoxContainer:
        _reset_separation(control, "separation")
    elif control is GridContainer:
        _reset_separation(control, "h_separation")
        _reset_separation(control, "v_separation")

    if control is MarginContainer:
        _reset_margin(control)


static func _scale_separation(control: Control, prop: String) -> void :
    var meta_base: String = META_BASE_SEPARATION + "_" + prop
    var meta_scaled: String = META_SCALED_SEPARATION + "_" + prop

    var has_override: = control.has_theme_constant_override(prop)
    if not has_override:
        return

    var current_val: = int(control.get_theme_constant(prop))
    if current_val <= 0:
        return

    var previous_scaled: = int(control.get_meta(meta_scaled, -1))
    var base_val: = int(control.get_meta(meta_base, current_val))
    if current_val != previous_scaled:
        base_val = current_val
        control.set_meta(meta_base, base_val)

    var scaled_val: = int(ceil(float(base_val) * SPACING_SCALE))
    control.set_meta(meta_scaled, scaled_val)
    control.add_theme_constant_override(prop, scaled_val)


static func _reset_separation(control: Control, prop: String) -> void :
    var meta_base: String = META_BASE_SEPARATION + "_" + prop
    var meta_scaled: String = META_SCALED_SEPARATION + "_" + prop
    if control.has_meta(meta_base):
        var base_val: = int(control.get_meta(meta_base))
        if base_val > 0:
            control.add_theme_constant_override(prop, base_val)
    if control.has_meta(meta_base):
        control.remove_meta(meta_base)
    if control.has_meta(meta_scaled):
        control.remove_meta(meta_scaled)


static func _scale_margin(control: Control) -> void :
    var sides: = ["margin_left", "margin_right", "margin_top", "margin_bottom"]
    for side in sides:
        var has_override: = control.has_theme_constant_override(side)
        if not has_override:
            continue

        var meta_base: String = META_BASE_MARGINS + "_" + side
        var meta_scaled: String = META_SCALED_MARGINS + "_" + side

        var current_val: = int(control.get_theme_constant(side))
        if current_val <= 0:
            continue

        var previous_scaled: = int(control.get_meta(meta_scaled, -1))
        var base_val: = int(control.get_meta(meta_base, current_val))
        if current_val != previous_scaled:
            base_val = current_val
            control.set_meta(meta_base, base_val)

        var scaled_val: = int(ceil(float(base_val) * SPACING_SCALE))
        control.set_meta(meta_scaled, scaled_val)
        control.add_theme_constant_override(side, scaled_val)


static func _reset_margin(control: Control) -> void :
    var sides: = ["margin_left", "margin_right", "margin_top", "margin_bottom"]
    for side in sides:
        var meta_base: String = META_BASE_MARGINS + "_" + side
        var meta_scaled: String = META_SCALED_MARGINS + "_" + side
        if control.has_meta(meta_base):
            var base_val: = int(control.get_meta(meta_base))
            if base_val > 0:
                control.add_theme_constant_override(side, base_val)
        if control.has_meta(meta_base):
            control.remove_meta(meta_base)
        if control.has_meta(meta_scaled):
            control.remove_meta(meta_scaled)
