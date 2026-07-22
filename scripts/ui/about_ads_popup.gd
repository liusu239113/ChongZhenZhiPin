extends RefCounted
class_name AboutAdsPopup





const FontLoader = preload("res://scripts/ui/font_loader.gd")
const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const NativeMobileTouchScrollRef = preload("res://scripts/ui/native_mobile_touch_scroll.gd")
const ScrollbarThemeRef = preload("res://scripts/ui/scrollbar_theme.gd")
const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")

const DIANSHI_MODAL_BORDER: = Color(0.42, 0.43, 0.44, 0.72)

const MOBILE_TITLE_FONT_SIZE: = 55
const MOBILE_BODY_FONT_SIZE: = 38
const MOBILE_ACTION_FONT_SIZE: = 41
const MOBILE_ACTION_WIDTH: = 300.0
const MOBILE_ACTION_HEIGHT: = 84.0


const SECTIONS: = [
    {"type": "body", "text": "自更新计划公布以来，收到了很多玩家朋友的关注和反馈，非常感谢大家。作为一款仍在长期更新、尚未完善的游戏，能得到大家这么多正面的评价，说实话让人挺意外和感动的。"}, 
    {"type": "body", "text": "其中也看到不少玩家提到，希望游戏能采用买断制、不加广告。这里想认真跟大家解释一下，为什么手机版之后会选择加入广告，而不是买断付费。"}, 
    {"type": "heading", "text": "核心原因：游戏还处于长期更新阶段，暂时无法申请版号"}, 
    {"type": "body", "text": "版号审核有一个前提，就是游戏的剧情文案要基本完工。而这款游戏的整体文本体量还是非常大，可以预见整个审核流程会比较漫长，中间大概率还会经历反复的修改、调整甚至打回，甚至可能因为一些原因无法过审。也就是说，从现在到拿到版号，可能是一段遥遥无期、充满变数的时间。"}, 
    {"type": "body", "text": "在没有版号、只能以目前这种方式在国内渠道上架的前提下，广告基本是唯一现实可行的盈利方式，这也是这次调整的根本原因。"}, 
    {"type": "heading", "text": "广告机制的设计思路"}, 
    {"type": "body", "text": "有几条是开发者一直坚持的原则："}, 
    {"type": "body", "text": "· 不会有强制观看的广告；\n· 不会把广告和某个固定功能、固定界面强绑定；\n· 广告的首要目的，是让工作室能够维持运转、支撑后续的持续更新；同时也会尽量在这个前提下，兼顾玩家的游戏体验。"}, 
    {"type": "body", "text": "目前设计的广告场景主要有两类："}, 
    {"type": "body", "text": "扩充存档栏位：默认三个存档位，观看广告可扩充至最多三十个。老版本升级上来的玩家如果原本就有十个存档位，会继续保留十个，不会被强行收回。"}, 
    {"type": "body", "text": "兑换识悟值：可用来改善游戏体验、降低上手难度。需要说明的是，游戏原有的数值不会因为加入广告而刻意调高难度；如果后续有数值调整，出发点也始终是游戏平衡性本身。而且游戏一直保留“简单模式”，如果觉得普通模式偏难，除了看广告之外，也可以随时切换到简单模式来体验。"}, 
    {"type": "body", "text": "总体来说，希望广告的存在能在“工作室能活下去”和“玩家体验不受过分影响”之间找到一个平衡点。"}, 
    {"type": "heading", "text": "关于 Steam 版与手机版的更新节奏"}, 
    {"type": "body", "text": "如果更看重沉浸式体验，也欢迎选择 Steam 版本（后续会发布）；如果愿意通过观看广告来支持开发者，手机版同样是一个不错的选择——两个平台各有侧重，都在认真对待。"}, 
    {"type": "body", "text": "游戏预计会在九月份于 Steam 上线第二条剧情路线“边务线”，并同步开启 EA 阶段。后续一段时间里，内容更新会优先在 Steam 版落地。"}, 
    {"type": "body", "text": "手机版的更新节奏会相对滞后一些——通常会等 Steam 版的新内容经过一段时间的稳定和打磨之后，再同步移植到手机版，整体大约会晚三个月左右。这么安排主要基于两点考虑："}, 
    {"type": "body", "text": "一是目前团队精力有限，多平台同步更新的维护成本比较高，需要先把 Steam 版本的内容打磨稳定，再逐步推进到其他平台；"}, 
    {"type": "body", "text": "二是考虑到手机版目前采用的是较轻量的广告模式，如果和 Steam 版本完全同步更新，对已经付费购买、期待获得对应体验价值的 Steam 玩家来说可能感觉不太公平。"}, 
    {"type": "body", "text": "所以现阶段会优先保证 Steam 版玩家在一段时间内率先体验到新内容，再逐步同步给手机版玩家。"}, 
    {"type": "body", "text": "最后，还是想真诚地说一声谢谢，谢谢大家一直以来对这款游戏的喜欢和支持。这次的规划可能和一部分玩家的期待不完全一致，但这确实是开发者综合了现实条件、尽量照顾到更多玩家感受之后，权衡出来的一套方案。也欢迎大家继续留言反馈，开发者会认真看。"}
]


static func show(host) -> void :
    var overlay: = ColorRect.new()
    overlay.color = Color(0, 0, 0, 0.56) if GameState.theme == "dark" else Color(0, 0, 0, 0.34)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.z_index = 101
    overlay.add_to_group("blocking_modal_overlay")

    overlay.gui_input.connect( func(event):
        if host._is_primary_press_event(event):
            overlay.queue_free()
    )

    var mobile_portrait: bool = host._is_mobile_portrait()
    var is_landscape_mobile: bool = NativeMobileFontScalerRef.is_native_phone_landscape(host)

    var panel: = PanelContainer.new()
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    panel.gui_input.connect( func(event):
        if event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventScreenDrag:
            panel.get_viewport().set_input_as_handled()
    )
    var panel_style: = StyleBoxFlat.new()
    panel_style.bg_color = Color.html("E0E2E6") if GameState.theme == "light" else GameState.get_theme_color("bg_popup")
    panel_style.set_border_width_all(1)
    panel_style.border_color = DIANSHI_MODAL_BORDER
    panel_style.set_corner_radius_all(2)
    var pad_val: = 24 if is_landscape_mobile else (44 if mobile_portrait else 24)
    panel_style.content_margin_left = pad_val
    panel_style.content_margin_right = pad_val
    panel_style.content_margin_top = pad_val
    panel_style.content_margin_bottom = pad_val
    panel_style.shadow_size = 0 if GameState.theme == "light" else 12
    panel_style.shadow_color = Color(0.2, 0.15, 0.1, 0.15) if GameState.theme == "light" else Color(0, 0, 0, 0.4)
    panel_style.shadow_offset = Vector2(0, 6)
    panel.add_theme_stylebox_override("panel", panel_style)

    var width_val: = 680 if is_landscape_mobile else (800 if mobile_portrait else 620)
    panel.custom_minimum_size = Vector2(width_val, 0)

    var center: = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)

    var vbox: = VBoxContainer.new()
    var sep_val: = 12 if is_landscape_mobile else (24 if mobile_portrait else 16)
    vbox.add_theme_constant_override("separation", sep_val)

    var title: = Label.new()
    title.text = "关于广告机制的说明"
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", 20 if is_landscape_mobile else (MOBILE_TITLE_FONT_SIZE if mobile_portrait else 18))
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)

    var separator: = HSeparator.new()
    var sep_style: = StyleBoxLine.new()
    sep_style.color = GameState.get_theme_color("border_active")
    sep_style.color.a = 0.15
    separator.add_theme_stylebox_override("separator", sep_style)
    vbox.add_child(separator)

    var scroll: = ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.mouse_filter = Control.MOUSE_FILTER_PASS
    var scroll_h: = 380.0 if is_landscape_mobile else (760.0 if mobile_portrait else 440.0)
    scroll.custom_minimum_size = Vector2(0, scroll_h)
    ScrollbarThemeRef.apply_to(scroll)

    var scroll_vbox: = VBoxContainer.new()
    scroll_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll_vbox.add_theme_constant_override("separation", 14)
    scroll.add_child(scroll_vbox)

    var heading_hex: = GameState.get_theme_color("border_active").to_html(false)
    var body_hex: = GameState.get_theme_color("text_desc").to_html(false)
    var base_size: int = 18 if is_landscape_mobile else (MOBILE_BODY_FONT_SIZE if mobile_portrait else 15)
    var heading_size: int = base_size + 2
    var text_w: float = width_val - pad_val * 2 - 20

    for sec in SECTIONS:
        var is_heading: bool = sec["type"] == "heading"
        var rt: = RichTextLabel.new()
        rt.bbcode_enabled = true
        rt.fit_content = true
        rt.scroll_active = false
        rt.selection_enabled = false
        rt.mouse_filter = Control.MOUSE_FILTER_PASS
        rt.custom_minimum_size.x = text_w
        rt.add_theme_font_override("normal_font", FontLoader.body())
        rt.add_theme_font_override("bold_font", FontLoader.serif_bold())
        if is_heading:
            rt.add_theme_font_size_override("normal_font_size", heading_size)
            rt.add_theme_font_size_override("bold_font_size", heading_size)
            rt.add_theme_constant_override("line_separation", 4)
            rt.text = "[b][color=#%s]%s[/color][/b]" % [heading_hex, sec["text"]]
        else:
            rt.add_theme_font_size_override("normal_font_size", base_size)
            rt.add_theme_font_size_override("bold_font_size", base_size)
            rt.add_theme_constant_override("line_separation", 6)
            rt.text = "[color=#%s]%s[/color]" % [body_hex, sec["text"]]
        scroll_vbox.add_child(rt)

    scroll.gui_input.connect( func(event):
        NativeMobileTouchScrollRef.forward_drag_to_scroll(event, scroll, host, "about_ads_scroll_touch_drag_suppress_until_ms")
        if event is InputEventScreenDrag:
            scroll.get_viewport().set_input_as_handled()
    )
    vbox.add_child(scroll)

    var close_btn: = Button.new()
    close_btn.text = "返回"
    close_btn.custom_minimum_size = Vector2(0, 42) if is_landscape_mobile else (Vector2(MOBILE_ACTION_WIDTH, MOBILE_ACTION_HEIGHT) if mobile_portrait else Vector2(120, 36))
    close_btn.add_theme_font_override("font", FontLoader.serif_bold())
    var fs: int = MOBILE_ACTION_FONT_SIZE if mobile_portrait else 14
    close_btn.add_theme_font_size_override("font_size", fs)
    close_btn.add_theme_constant_override("icon_max_width", fs)
    var main_color: = Color(0.85, 0.75, 0.65, 1.0)
    close_btn.add_theme_color_override("font_color", main_color)
    close_btn.add_theme_color_override("icon_normal_color", main_color)
    close_btn.add_theme_color_override("icon_hover_color", main_color)
    close_btn.add_theme_color_override("icon_pressed_color", main_color)
    close_btn.add_theme_color_override("icon_focus_color", main_color)
    var pad_x: = 24 if mobile_portrait else 18
    var pad_y: = 12 if mobile_portrait else 8
    close_btn.add_theme_stylebox_override("normal", GameScreenStyleFactory.secondary_modal_button_style(false, false, pad_x, pad_y))
    close_btn.add_theme_stylebox_override("hover", GameScreenStyleFactory.secondary_modal_button_style(true, false, pad_x, pad_y))
    close_btn.add_theme_stylebox_override("pressed", GameScreenStyleFactory.secondary_modal_button_style(true, true, pad_x, pad_y))
    close_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    close_btn.pressed.connect( func():
        overlay.queue_free()
    )
    vbox.add_child(close_btn)

    panel.add_child(vbox)
    center.add_child(panel)
    overlay.add_child(center)
    host.add_child(overlay)
    NativeMobileFontScalerRef.apply_to(overlay)
