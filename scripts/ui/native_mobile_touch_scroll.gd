extends RefCounted

const SUPPRESS_PRESS_MS: = 250





const DRAG_ARMING_DISTANCE: = 22.0

const GESTURE_RESET_GAP_MS: = 140


static func _accumulate_and_arm(owner: Object, meta: String, delta_abs: float) -> void :
    if owner == null or meta == "":
        return
    var now: = Time.get_ticks_msec()
    var t_key: = meta + "__drag_t"
    var acc_key: = meta + "__drag_acc"
    var last_t: = int(owner.get_meta(t_key, 0))
    var acc: = float(owner.get_meta(acc_key, 0.0))
    if now - last_t > GESTURE_RESET_GAP_MS:
        acc = 0.0
    acc += abs(delta_abs)
    owner.set_meta(t_key, now)
    owner.set_meta(acc_key, acc)
    if acc >= DRAG_ARMING_DISTANCE:
        owner.set_meta(meta, now + SUPPRESS_PRESS_MS)

static func forward_drag_to_scroll(event: InputEvent, scroll: ScrollContainer, suppress_owner: Object = null, suppress_meta: String = "") -> void :
    if not (event is InputEventScreenDrag):
        return
    if scroll == null or not is_instance_valid(scroll) or not scroll.visible:
        return
    var bar: = scroll.get_v_scroll_bar()
    if bar == null:
        return
    _accumulate_and_arm(suppress_owner, suppress_meta, event.relative.y)
    scroll.scroll_vertical = int(clampi(
        scroll.scroll_vertical - int(event.relative.y), 
        0, 
        int(bar.max_value)
    ))
    scroll.get_viewport().set_input_as_handled()



static func forward_horizontal_drag_to_scroll(event: InputEvent, scroll: ScrollContainer, suppress_owner: Object = null, suppress_meta: String = "") -> void :
    if not (event is InputEventScreenDrag):
        return
    if scroll == null or not is_instance_valid(scroll) or not scroll.visible:
        return
    var bar: = scroll.get_h_scroll_bar()
    if bar == null:
        return
    _accumulate_and_arm(suppress_owner, suppress_meta, event.relative.x)
    scroll.scroll_horizontal = int(clampi(
        scroll.scroll_horizontal - int(event.relative.x), 
        0, 
        int(bar.max_value)
    ))
    scroll.get_viewport().set_input_as_handled()




static func forward_event_to_scroll(event: InputEvent, scroll: ScrollContainer, suppress_owner: Object = null, suppress_meta: String = "") -> void :
    if scroll == null or not is_instance_valid(scroll) or not scroll.visible:
        return
    var bar: = scroll.get_v_scroll_bar()
    if bar == null:
        return
    if event is InputEventScreenDrag:
        forward_drag_to_scroll(event, scroll, suppress_owner, suppress_meta)
        return
    if event is InputEventMouseButton and event.pressed:
        var step: = 0
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            step = -1
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            step = 1
        if step == 0:
            return
        var amount: = int(bar.page * 0.25) if bar.page > 0.0 else 60
        amount = maxi(amount, 40)
        scroll.scroll_vertical = int(clampi(
            scroll.scroll_vertical + step * amount, 
            0, 
            int(bar.max_value)
        ))
        scroll.get_viewport().set_input_as_handled()


static func should_suppress_press(owner: Object, suppress_meta: String) -> bool:
    if owner == null or suppress_meta == "":
        return false
    return Time.get_ticks_msec() < int(owner.get_meta(suppress_meta, 0))
