extends Control

signal mode_selected(mode_id: String)
signal back_requested

const FontLoader = preload("res://scripts/ui/font_loader.gd")
const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")
const TIMELINE_BG: Texture2D = preload("res://assets/choose-bg.webp")
const LOCKED_MODE_ART_MODULATE: = Color(0.92, 0.84, 0.66, 0.36)
const LOCKED_MODE_ART_OVERLAY: = Color(0.11, 0.075, 0.025, 0.36)
const BIOGRAPHY_CONTINUE_SLOT_HEIGHT: = 64
const BIOGRAPHY_CONTINUE_SLOT_HEIGHT_COMPACT: = 78


const MODE_LABELS: = {"normal": "普通模式", "simple": "简单模式"}
const MODE_DESCS: = {
    "normal": "标准难度。运气抽卡每场只有一次机会；每月 2 点行动力。", 
    "simple": "更易上手。运气抽卡每场失利后可「再试一次」；每月 3 点行动力。", 
}

const MODES: = [
    {
        "id": "hanmen", 
        "title": "寒门", 
        "person": "李承槐", 
        "origin": "开封府祥符县小农之子。家无余粮，族无靠山，一路熬到进士，靠的不是天分，是不肯认命。如今踏上仕途，能走到哪一步，全看自己。", 
        "tag": "地方线", 
        "enabled": true, 
        "bg_tex_path": "res://assets/Texture/Farmer.webp", 
        "art_anchor_top": 0.35
    }, 
    {
        "id": "shijia", 
        "title": "没落世家", 
        "person": "顾延澜", 
        "origin": "北直隶保定府百户之子。祖上以军功起家，到这一代已是世职空悬、家底见底。别人眼里你还是将门子弟，只有自己知道，那块牌匾撑不了多久了。", 
        "tag": "边务线", 
        "enabled": true, 
        "bg_tex_path": "res://assets/Texture/GreatWall.webp", 
        "art_anchor_top": 0.4
    }, 
    {
        "id": "jinshen", 
        "title": "缙绅", 
        "person": "沈廷砚", 
        "origin": "苏州府缙绅幼子。家底丰厚，人脉遍布，生来便不缺门路。只是庶出的身份断了继承的念想，与其等人施舍，不如自己在官场上走出一条路来。", 
        "tag": "户部线", 
        "enabled": false, 
        "bg_tex_path": "res://assets/Texture/SuzhouGardens.webp", 
        "art_anchor_top": 0.4
    }, 
    {
        "id": "wanderer", 
        "title": "游民", 
        "person": "赵有生", 
        "origin": "顺天府城郊流民之后。无田无产，从小便知道没有人会替你兜底。这些年学会的那套本事——看人、等时机、不动声色——如今总算有了用武之地。", 
        "tag": "内廷线", 
        "enabled": false, 
        "bg_tex_path": "res://assets/Texture/市井.webp", 
        "art_anchor_top": 0.4
    }, 
    {
        "id": "free", 
        "title": "自由模式", 
        "person": "自定义", 
        "origin": "体验明末普通人的一生，功能探索。", 
        "tag": "旷野线", 
        "enabled": true, 
        "bg_tex_path": "res://assets/Texture/书房.webp", 
        "art_anchor_top": 0.4
    }
]

const HANMEN_BIOGRAPHY_PAGES: = [
    [
        "万历三十一年，你降生在河南开封府祥符县一户农家。", 
        "黄河冲积的平原养活了祖祖辈辈的庄稼人，也年年带来水患与饥荒。你家薄田几亩，灶头常有炊烟，却难得闻见荤腥。", 
        "四岁那年，父亲帮人砍了一整天柴，换回一张写着「天地玄黄」的旧纸。他在院子里铺了一层细沙，折了根柳条递给你。", 
        "你蹲在地上，照着那四个字一笔一画地描。写得歪了，父亲便蹲下身，用手掌将沙面抹平——再写，写端正些。", 
        "日头落山时，你写了几十遍，手指磨得通红，父亲才点了点头，转身去灶房给你热了碗粥。", 
    ], 
    [
        "七岁那年，家里实在凑不出束脩。母亲主动取下发间那根唯一的陪嫁银簪，塞到父亲手里。第二天一早，父亲拿着换来的银钱送你进了村塾。", 
        "塾里的老秀才姓赵，教了一辈子书，也只考到秀才便再没往上走。富户家的孩子嫌你衣裳破旧，往你脚边扔石子。", 
        "你没有理会，只是把书读得比谁都大声。老秀才听了几日，在堂上敲了一下戒尺，说：都给我安静——听这孩子背。", 
        "散学后他把你叫到一旁，翻出一本卷了边的《大学》递过来：拿回去读，读完了来找我换下一本。", 
        "那时你还不明白，这个寒酸的老秀才把自己没能走完的路，悄悄押在了你身上。", 
    ], 
    [
        "十二岁，你头一回进县城应童子试。老秀才垫了盘缠，又拿老脸替你写了保结文书。", 
        "青石板长街、绸缎铺面、轿马往来、考棚里密密麻麻的人头——你才晓得，天底下读书的穷孩子远不止你一个。", 
        "十六岁那年，你中了秀才。放榜那天，父亲立在人群外头，脊背比从前更弯了，两只粗糙的手攥着衣角，不停地搓。", 
        "回村的路上，你说想给老秀才带一壶酒——当年他说过，你若进学，他要一壶好酒。", 
        "父亲没答话，拐进镇上的酒铺，掏光了身上的铜板，打了一壶最便宜的黄酒。", 
    ], 
    [
        "二十一岁，你考中举人。村里人开始毕恭毕敬地喊你「李相公」，连从前扔石子的富户也托人来攀交情。", 
        "母亲高兴得抹了半天眼泪，父亲坐在门槛上抽了一袋旱烟，没多说什么。", 
        "会试三年一科。头一回进京赶考，你没有考中。第二回会试的年头到了，程仪没人再送，盘缠是族里七拼八凑的。临行那天，老秀才拄着拐杖到村口送你，说了一句：我这辈子是走不到顺天府了，你带我去看看。", 
        "母亲往包袱里塞了双新纳的布鞋。父亲送你到家门口，只叮嘱了一句：将来若是考中了、做了官，别忘了根在哪儿，别让人戳脊梁骨。", 
    ], 
    [
        "你带着一口河南乡音和半箱子书，晓行夜宿，进了京师。", 
        "崇祯元年春闱，贡院里九天三场。出场那日你两腿发软，几乎是被人架出龙门的。", 
        "放榜那天，你挤在人堆里，从榜尾一行一行往上找——找到了。你的名字端端正正写在杏榜上，你一举中试。", 
        "你站在人堆里愣了半天，直到旁边的人拍了你一把，你才回过神来。", 
        "你知道，属于你的人生就要到来了。", 
    ]
]

const SHIJIA_BIOGRAPHY_PAGES: = [
    [
        "万历末年，你生在北直隶保定府一户军户人家。", 
        "祖上在永乐年间随靖难军南下，立过武功，封了世袭百户。两百年传下来，当年的战功牌已在祠堂里积了灰，军田也剩不了多少了。", 
        "父亲是个沉默的人，平日话很少，每天练刀、看兵书、喝闷酒。他年轻时还没接百户的差，按卫里的班军旧例，被点去蓟镇戍守过两年，亲眼见过鞑子骑兵冲阵。只要说起这段，他就跟换了一个人似的，比划着手势说个没完，眼里有光。", 
    ], 
    [
        "百户的位子迟早是哥哥的。父亲从小把他带在身边，教刀、教阵，把一身本事往他身上使。", 
        "你是老二。军户世代锁在名册上，子孙婚配、科场都矮人一头，凡有余力的人家，总要分一个儿子出去博功名。", 
        "你五岁就被送去了城外舅家，寄在民籍名下读书，离卫所远远的。", 
        "父亲的意思很直白——长子守着世袭的差事饿不着，次子若能读出个名堂，门楣才算立起来。", 
    ], 
    [
        "只是你不是那块料。四书五经背得磕磕巴巴，村里耍拳的、赶集卖艺的，你倒是见一次学一次。县试考过两回，都没过。", 
        "日子难归难，你不用想以后怎么办。那是你哥的事。", 
        "万历四十七年，萨尔浒大败的消息传到保定。四路大军尽丧，阵亡名册上有你家认识的人。舅家离城几十里，消息辗转到你耳朵里，已经晚了半个月。", 
    ], 
    [
        "家书是父亲的笔迹，比往常潦草。朝廷从各卫所紧急抽丁填辽东的窟窿，勾军的册子翻到了你家。", 
        "父亲想花钱买通书办改名册，哥哥说不用，他十八了，刀练了十几年，自己去。", 
        "哥哥走的那天，把自己那把刀留在了堂屋的桌上，托人给你捎了一句：「替我磨着，别让它锈了。」", 
        "你当时觉得他很快就会回来。", 
    ], 
    [
        "天启元年，辽阳、沈阳一个月内接连失陷。再没有哥哥的消息。", 
        "父亲托人打听了大半年。最后是一个逃回来的伤兵说的：沈阳城破那天，他还在城墙上。后金兵从缺口涌进来时，他身边只剩了几个人。没有人看见他怎么死的。", 
        "你是回保定奔丧时才知道全的。母亲收到消息那天没有哭，在灶台前坐了一整夜。", 
    ], 
    [
        "父亲把哥哥那把刀从桌上收进了里屋。你又把它拿出来，放回桌上。", 
        "父亲看见了，沉了半天，说了一句话。后来这些年他反反复复就说这一句，说到你能背出他的语气：", 
        "「别蛮拼。好好活下去。」", 
    ], 
    [
        "奔丧回舅家，你带走了哥哥那把刀。此后每天一个人在院子里练，没人教你，你就照着记忆里父亲比划的那套路子劈，一遍一遍，劈到手掌起茧。", 
        "你想过要去辽东，想过替哥哥报仇。可那些念头到了嘴边，又被父亲那句话压了回去。他已经失去了一个儿子，你不能让他再赌第二个。", 
        "那几年辽民大批南逃，舅家这一带也来了几户辽东逃来的军户，在村外搭了棚子。你去棚子那边转，一半是想找到从沈阳活着回来的人，一半是想听听那边的事。", 
        "你拿家里的饭去换：一顿饱饭换一手关外骑射的技法，你觉得赚了。仿佛学会了这些，就离哥哥走过的那条路近了一点。", 
    ], 
    [
        "天启末年，父亲老了。他不再练刀，话更少，背更弯。这年他满六十：按制，武官年六十，子可替职。", 
        "家书来得比往常都郑重。你收拾了行装，离开住了十几年的舅家，回到那座你只在年节里见过几面的卫所。", 
        "他把那块百户腰牌从箱底翻出来，用袖子擦了擦，放到桌上：「以前我想着，这牌子传给你哥。现在，传给你。」", 
        "他又说了那句话：「别蛮拼。好好活下去。」", 
    ], 
    [
        "你接过腰牌，在手里翻了个面。铜牌磨得包了浆，背面刻着保定右卫的编号，笔画都快认不清了。", 
        "你心里忽然冒出一个念头：哥哥没来得及做的事，你来做。这个破烂卫所，你要把它收拾起来。", 
    ]
]

var FONT_TITLE: Font = FontLoader.title()
var FONT_BODY: Font = FontLoader.body()
var FONT_BOLD: Font = FontLoader.serif_bold()

var GOLD: Color:
    get: return GameState.get_theme_color("border_active")
var INK: Color:
    get: return GameState.get_theme_color("text_desc")
var INK_DEEP: Color:
    get: return GameState.get_theme_color("text_main")
var MUTED: Color:
    get: return GameState.get_theme_color("text_sub")

@onready var background: TextureRect = $Background
@onready var overlay: ColorRect = $Overlay

var _root_margin: MarginContainer
var _showing_biography: = false
var _showing_construction_dialog: = false
var _construction_mode_id: = ""

var _biography_mode_id: = "hanmen"
var _biography_page_index: = 0
var _biography_lines: Array[Control] = []
var _biography_arrow: Label
var _assignment_button: Button
var _is_revealing_biography: = false
var _biography_tweens: Array[Tween] = []


var _last_biography_advance_frame: = -1


var _mode_button: Button
var _mode_dropdown: PanelContainer
var _mode_mask: Control

func _ready() -> void :
    GameState.theme_changed.connect(_on_theme_changed)
    resized.connect(_rebuild)
    visibility_changed.connect(_on_visibility_changed)
    _rebuild()

func _on_visibility_changed() -> void :
    if visible:
        _showing_biography = false
        _biography_page_index = 0
        _showing_construction_dialog = false
        _rebuild()

func _on_theme_changed(_theme: String) -> void :
    if not is_inside_tree():
        return
    _rebuild()

func _rebuild() -> void :
    if not is_inside_tree():
        return
    for child in get_children():
        if child == background or child == overlay:
            continue
        child.queue_free()
    _apply_background()
    if _showing_construction_dialog:
        _build_construction_dialog_view()
    elif _showing_biography:
        _build_biography_view()
    else:
        _build_mode_view()
    _apply_native_mobile_font_scale()

func _apply_background() -> void :
    background.texture = TIMELINE_BG
    background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    if _showing_biography:
        overlay.color = Color(0.0, 0.0, 0.0, 0.86)
        return
    overlay.color = Color(0.015, 0.012, 0.01, 0.78) if GameState.theme == "dark" else Color(0.04, 0.032, 0.024, 0.58)

func _is_compact() -> bool:
    var size: = get_viewport_rect().size
    return size.x < 980.0 or size.y > size.x * 1.18

func _build_base_margin() -> VBoxContainer:
    _root_margin = MarginContainer.new()
    _root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
    var compact: = _is_compact()
    _root_margin.add_theme_constant_override("margin_left", 24 if compact else 56)
    _root_margin.add_theme_constant_override("margin_top", 34 if compact else 46)
    _root_margin.add_theme_constant_override("margin_right", 24 if compact else 56)
    _root_margin.add_theme_constant_override("margin_bottom", 34 if compact else 46)
    add_child(_root_margin)

    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 22 if compact else 30)
    _root_margin.add_child(vbox)
    return vbox

func _build_mode_view() -> void :
    var compact: = _is_compact()
    var vbox: = _build_base_margin()

    var header: = HBoxContainer.new()
    header.add_theme_constant_override("separation", 18)
    vbox.add_child(header)

    var title_box: = VBoxContainer.new()
    title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title_box)

    var title: = Label.new()
    title.text = "选择开局"
    title.add_theme_font_override("font", FONT_TITLE)
    title.add_theme_font_size_override("font_size", 52 if compact else 46)
    title.add_theme_color_override("font_color", INK_DEEP)
    title_box.add_child(title)


    _mode_button = Button.new()
    _mode_button.focus_mode = Control.FOCUS_NONE
    _mode_button.custom_minimum_size = Vector2(280 if compact else 156, 60 if compact else 38)
    _mode_button.add_theme_font_override("font", FONT_BOLD)
    _mode_button.add_theme_font_size_override("font_size", 28 if compact else 15)
    _mode_button.pressed.connect( func(): _toggle_mode_dropdown())
    _style_mode_button(_mode_button)
    _update_mode_button_text()
    header.add_child(_mode_button)

    var back: = Button.new()
    back.text = "返回"
    back.focus_mode = Control.FOCUS_NONE
    back.custom_minimum_size = Vector2(290 if compact else 112, 60 if compact else 38)
    back.add_theme_font_override("font", FONT_BODY)
    back.add_theme_font_size_override("font_size", 28 if compact else 16)
    back.pressed.connect( func(): back_requested.emit())
    _style_back_button(back)
    header.add_child(back)

    _build_mode_dropdown(compact)

    var scroll: = ScrollContainer.new()
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO if compact else ScrollContainer.SCROLL_MODE_DISABLED
    vbox.add_child(scroll)

    var cards: = HBoxContainer.new()
    cards.add_theme_constant_override("separation", 16 if compact else 18)
    cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.add_child(cards)

    for data in MODES:
        cards.add_child(_build_mode_card(data, compact))

func _build_mode_card(data: Dictionary, compact: bool) -> Button:
    var enabled: = bool(data.get("enabled", false))


    if str(data.get("id", "")) in ["shijia", "free"] and not OS.has_feature("editor"):
        enabled = false
    var card: = Button.new()
    card.text = ""
    card.disabled = not enabled
    card.focus_mode = Control.FOCUS_NONE
    card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if enabled else Control.CURSOR_ARROW
    card.custom_minimum_size = Vector2(210 if compact else 214, 360 if compact else 440)
    card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    card.size_flags_vertical = Control.SIZE_EXPAND_FILL
    card.add_theme_stylebox_override("normal", _card_style(enabled, false))
    card.add_theme_stylebox_override("hover", _card_style(enabled, true))
    card.add_theme_stylebox_override("pressed", _card_style(enabled, true))
    card.add_theme_stylebox_override("disabled", _card_style(false, false))
    card.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    card.add_theme_color_override("font_disabled_color", Color.TRANSPARENT)
    card.clip_contents = true

    var id: = str(data.get("id", ""))
    card.set_meta("mode_id", id)
    if enabled:
        card.pressed.connect( func(): _on_mode_card_pressed(id))
        card.mouse_entered.connect( func():
            _update_card_hover(card, true)
        )
        card.mouse_exited.connect( func():
            _update_card_hover(card, false)
        )


    var bg_tex_path: String = data.get("bg_tex_path", "")
    var art_anchor_top: float = data.get("art_anchor_top", 0.4)
    if bg_tex_path != "":
        var bg_tex: Texture2D = load(bg_tex_path) as Texture2D
        if bg_tex == null:
            var img = Image.new()
            var err = img.load(bg_tex_path)
            if err == OK:
                bg_tex = ImageTexture.create_from_image(img)

        if bg_tex:
            var bg_holder = Control.new()
            bg_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
            bg_holder.set_anchors_preset(Control.PRESET_FULL_RECT)
            bg_holder.offset_left = 2
            bg_holder.offset_top = 2
            bg_holder.offset_right = -2
            bg_holder.offset_bottom = -2

            var tex_rect = TextureRect.new()
            tex_rect.name = "ModeCardArt"
            tex_rect.texture = bg_tex
            tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
            tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
            tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
            tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
            tex_rect.anchor_top = art_anchor_top
            tex_rect.modulate = _mode_art_modulate(id, enabled, false)
            bg_holder.add_child(tex_rect)

            if not enabled:
                var locked_overlay = ColorRect.new()
                locked_overlay.name = "ModeCardLockedArtOverlay"
                locked_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
                locked_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
                locked_overlay.color = LOCKED_MODE_ART_OVERLAY
                bg_holder.add_child(locked_overlay)

            var grad_tex_rect = TextureRect.new()
            grad_tex_rect.name = "ModeCardShade"
            grad_tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
            grad_tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
            grad_tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE


            var grad_tex = GradientTexture2D.new()
            grad_tex.fill_from = Vector2(0, 0)
            grad_tex.fill_to = Vector2(0, 1)

            var grad = Gradient.new()
            grad.set_color(0, Color(0.02, 0.018, 0.015, 0.96))
            grad.set_color(1, Color(0.07, 0.05, 0.032, 0.4))
            grad.add_point(0.5, Color(0.045, 0.035, 0.024, 0.72))
            grad_tex.gradient = grad
            grad_tex_rect.texture = grad_tex
            grad_tex_rect.modulate = Color(1, 1, 1, 1)
            bg_holder.add_child(grad_tex_rect)

            card.add_child(bg_holder)


    var inner_frame: = Panel.new()
    inner_frame.name = "ModeCardInnerFrame"
    inner_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
    inner_frame.set_anchors_preset(Control.PRESET_FULL_RECT)
    inner_frame.offset_left = 5
    inner_frame.offset_top = 5
    inner_frame.offset_right = -5
    inner_frame.offset_bottom = -5
    inner_frame.add_theme_stylebox_override("panel", _card_inner_frame_style(enabled, false))
    card.add_child(inner_frame)

    var box: = VBoxContainer.new()
    box.mouse_filter = Control.MOUSE_FILTER_IGNORE
    box.set_anchors_preset(Control.PRESET_FULL_RECT)
    box.offset_left = 18
    box.offset_top = 68
    box.offset_right = -18
    box.offset_bottom = -20
    box.add_theme_constant_override("separation", 14)
    card.add_child(box)

    var mode_title: = Label.new()
    mode_title.text = str(data.get("title", ""))
    mode_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    mode_title.add_theme_font_override("font", FONT_TITLE)
    mode_title.add_theme_font_size_override("font_size", 38 if compact else 34)
    mode_title.add_theme_color_override("font_color", GOLD if enabled else Color(0.55, 0.53, 0.49, 0.8))
    box.add_child(mode_title)

    var person: = Label.new()
    person.text = str(data.get("person", ""))
    person.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    person.add_theme_font_override("font", FONT_BOLD)
    person.add_theme_font_size_override("font_size", 25 if compact else 19)
    person.add_theme_color_override("font_color", INK_DEEP if enabled else Color(0.5, 0.48, 0.44, 0.72))
    box.add_child(person)

    var tag_text: = str(data.get("tag", ""))
    if tag_text != "":
        var tag_chip = _build_tag_chip(tag_text, enabled)
        tag_chip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        box.add_child(tag_chip)

    var sep: = HSeparator.new()
    var sep_style: = StyleBoxLine.new()
    sep_style.color = GOLD
    sep_style.color.a = 0.28 if enabled else 0.12
    sep.add_theme_stylebox_override("separator", sep_style)
    box.add_child(sep)

    var origin: = Label.new()
    origin.text = str(data.get("origin", ""))
    origin.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    origin.vertical_alignment = VERTICAL_ALIGNMENT_TOP
    origin.size_flags_vertical = Control.SIZE_EXPAND_FILL
    origin.add_theme_font_override("font", FONT_BODY)
    origin.add_theme_font_size_override("font_size", 23 if compact else 14)
    origin.add_theme_color_override("font_color", Color(0.88, 0.84, 0.72, 0.88) if enabled else Color(0.55, 0.53, 0.49, 0.74))
    origin.add_theme_constant_override("line_spacing", 9 if compact else 6)
    box.add_child(origin)

    var status: = Label.new()
    status.text = "可选择" if enabled else "暂未开放"
    status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status.add_theme_font_override("font", FONT_BODY)
    status.add_theme_font_size_override("font_size", 22 if compact else 15)
    status.add_theme_color_override("font_color", GOLD if enabled else MUTED)
    box.add_child(status)
    return card


func _build_mode_dropdown(compact: bool) -> void :

    _mode_mask = Control.new()
    _mode_mask.set_anchors_preset(Control.PRESET_FULL_RECT)
    _mode_mask.mouse_filter = Control.MOUSE_FILTER_STOP
    _mode_mask.visible = false
    _mode_mask.gui_input.connect( func(event: InputEvent):
        if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)\
or (event is InputEventScreenTouch and event.pressed):
            _defer_close_mode_dropdown()
    )
    add_child(_mode_mask)

    var dd_width: float = 600.0 if compact else 360.0
    var dd_pad: float = 18.0 if compact else 8.0
    var card_sep: float = 16.0 if compact else 4.0

    _mode_dropdown = PanelContainer.new()
    _mode_dropdown.visible = false
    var dd_style: = StyleBoxFlat.new()
    dd_style.bg_color = Color(0.05, 0.042, 0.032, 0.98)
    dd_style.border_color = Color(0.72, 0.56, 0.28, 0.42)
    dd_style.border_width_left = 1
    dd_style.border_width_top = 1
    dd_style.border_width_right = 1
    dd_style.border_width_bottom = 1
    dd_style.corner_radius_top_left = 10
    dd_style.corner_radius_top_right = 10
    dd_style.corner_radius_bottom_left = 10
    dd_style.corner_radius_bottom_right = 10
    dd_style.shadow_size = 18 if GameState.theme == "dark" else 6
    dd_style.shadow_color = Color(0, 0, 0, 0.42)
    _mode_dropdown.add_theme_stylebox_override("panel", dd_style)
    _mode_dropdown.custom_minimum_size = Vector2(dd_width, 0)
    add_child(_mode_dropdown)

    var opts_margin: = MarginContainer.new()
    opts_margin.add_theme_constant_override("margin_left", int(dd_pad))
    opts_margin.add_theme_constant_override("margin_right", int(dd_pad))
    opts_margin.add_theme_constant_override("margin_top", int(dd_pad))
    opts_margin.add_theme_constant_override("margin_bottom", int(dd_pad))
    _mode_dropdown.add_child(opts_margin)

    var opts_vbox: = VBoxContainer.new()
    opts_vbox.add_theme_constant_override("separation", int(card_sep))
    opts_margin.add_child(opts_vbox)



    var card_lr: float = 22.0 if compact else 14.0
    var content_w: float = dd_width - 2.0 * dd_pad - 2.0 * card_lr
    for mode_id in ["normal", "simple"]:
        opts_vbox.add_child(_build_mode_option_card(mode_id, compact, content_w))

func _build_mode_option_card(mode_id: String, compact: bool, content_w: float = 0.0) -> PanelContainer:
    var selected: = GameState.difficulty == mode_id
    var card: = PanelContainer.new()
    card.name = "ModeOpt_" + mode_id
    card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    card.add_theme_stylebox_override("panel", _mode_option_style(selected, false))

    var pad: = MarginContainer.new()
    pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var lr: = 22 if compact else 14
    var tb: = 18 if compact else 10
    pad.add_theme_constant_override("margin_left", lr)
    pad.add_theme_constant_override("margin_right", lr)
    pad.add_theme_constant_override("margin_top", tb)
    pad.add_theme_constant_override("margin_bottom", tb)
    card.add_child(pad)

    var vb: = VBoxContainer.new()
    vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
    vb.add_theme_constant_override("separation", 10 if compact else 6)
    pad.add_child(vb)

    var title: = Label.new()
    title.text = MODE_LABELS[mode_id]
    title.add_theme_font_override("font", FONT_BOLD)
    title.add_theme_font_size_override("font_size", 40 if compact else 15)
    title.add_theme_color_override("font_color", 
        Color(0.96, 0.84, 0.56, 1.0) if selected else Color(0.86, 0.74, 0.48, 0.94))
    vb.add_child(title)

    var desc: = Label.new()
    desc.text = MODE_DESCS[mode_id]
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    desc.add_theme_constant_override("line_spacing", 6 if compact else 3)
    desc.add_theme_font_override("font", FONT_BODY)
    desc.add_theme_font_size_override("font_size", 32 if compact else 12)
    desc.add_theme_color_override("font_color", Color(0.82, 0.77, 0.66, 0.92))

    if content_w > 0.0:
        desc.custom_minimum_size.x = content_w
        desc.size_flags_horizontal = Control.SIZE_FILL
    vb.add_child(desc)

    card.gui_input.connect( func(event: InputEvent):
        if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)\
or (event is InputEventScreenTouch and event.pressed):
            _select_difficulty(mode_id)
            card.accept_event()
    )
    card.mouse_entered.connect( func():
        if GameState.difficulty != mode_id:
            card.add_theme_stylebox_override("panel", _mode_option_style(false, true))
    )
    card.mouse_exited.connect( func():
        card.add_theme_stylebox_override("panel", _mode_option_style(GameState.difficulty == mode_id, false))
    )
    return card

func _mode_option_style(selected: bool, hover: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    if selected:
        style.bg_color = Color(0.16, 0.1, 0.05, 0.78)
        style.border_color = Color(0.86, 0.66, 0.34, 0.62)
    elif hover:
        style.bg_color = Color(0.12, 0.08, 0.04, 0.62)
        style.border_color = Color(0.78, 0.58, 0.3, 0.42)
    else:
        style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
        style.border_color = Color(0.54, 0.4, 0.2, 0.3)
    var bw: = 2 if selected else 1
    style.border_width_left = bw
    style.border_width_top = bw
    style.border_width_right = bw
    style.border_width_bottom = bw
    style.corner_radius_top_left = 6
    style.corner_radius_top_right = 6
    style.corner_radius_bottom_left = 6
    style.corner_radius_bottom_right = 6
    return style

func _toggle_mode_dropdown() -> void :
    if _mode_dropdown == null or not is_instance_valid(_mode_dropdown):
        return
    var to_show: = not _mode_dropdown.visible
    _mode_dropdown.visible = to_show
    if _mode_mask and is_instance_valid(_mode_mask):
        _mode_mask.visible = to_show
    if to_show:
        _position_mode_dropdown()
        call_deferred("_position_mode_dropdown")

func _defer_close_mode_dropdown() -> void :
    if _mode_dropdown != null and is_instance_valid(_mode_dropdown):
        _mode_dropdown.set_deferred("visible", false)
    if _mode_mask != null and is_instance_valid(_mode_mask):
        _mode_mask.set_deferred("visible", false)


func _position_mode_dropdown() -> void :
    if _mode_dropdown == null or not is_instance_valid(_mode_dropdown):
        return
    if _mode_button == null or not is_instance_valid(_mode_button):
        return
    var btn_rect: = _mode_button.get_global_rect()
    var w: = _mode_dropdown.custom_minimum_size.x
    if w <= 0.0:
        w = _mode_dropdown.size.x


    _mode_dropdown.anchor_left = 0.0
    _mode_dropdown.anchor_top = 0.0
    _mode_dropdown.anchor_right = 0.0
    _mode_dropdown.anchor_bottom = 0.0
    _mode_dropdown.offset_left = btn_rect.end.x - w
    _mode_dropdown.offset_right = _mode_dropdown.offset_left + w
    _mode_dropdown.offset_top = btn_rect.end.y + 8.0
    var h: = _mode_dropdown.get_combined_minimum_size().y
    _mode_dropdown.offset_bottom = _mode_dropdown.offset_top + h

func _select_difficulty(mode_id: String) -> void :
    GameState.difficulty = mode_id
    _defer_close_mode_dropdown()
    _update_mode_button_text()
    _refresh_mode_option_styles()

func _refresh_mode_option_styles() -> void :
    if _mode_dropdown == null or not is_instance_valid(_mode_dropdown):
        return
    for m in ["normal", "simple"]:
        var card: = _mode_dropdown.find_child("ModeOpt_" + m, true, false)
        if not (card is PanelContainer):
            continue
        var sel: bool = (m == GameState.difficulty)
        card.add_theme_stylebox_override("panel", _mode_option_style(sel, false))

func _update_mode_button_text() -> void :
    if _mode_button != null and is_instance_valid(_mode_button):
        _mode_button.text = MODE_LABELS.get(GameState.difficulty, "普通模式") + "  ▾"

func _style_mode_button(btn: Button) -> void :
    btn.add_theme_stylebox_override("normal", _button_style(Color(0.03, 0.026, 0.02, 0.78), Color(0.72, 0.56, 0.28, 0.34)))
    btn.add_theme_stylebox_override("hover", _button_style(Color(0.14, 0.09, 0.045, 0.82), Color(0.82, 0.62, 0.32, 0.5)))
    btn.add_theme_stylebox_override("pressed", _button_style(Color(0.1, 0.07, 0.035, 0.82), Color(0.82, 0.62, 0.32, 0.5)))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    var norm_color: = Color(0.78, 0.68, 0.48, 0.92)
    var hover_color: = Color(0.96, 0.84, 0.58, 1.0)
    btn.add_theme_color_override("font_color", norm_color)
    btn.add_theme_color_override("font_hover_color", hover_color)
    btn.add_theme_color_override("font_pressed_color", hover_color)

func _current_biography_pages() -> Array:
    return SHIJIA_BIOGRAPHY_PAGES if _biography_mode_id == "shijia" else HANMEN_BIOGRAPHY_PAGES

func _on_mode_card_pressed(mode_id: String) -> void :
    if mode_id in ["shijia", "free"]:
        _showing_construction_dialog = true
        _construction_mode_id = mode_id
        _rebuild()
        return
    if mode_id == "hanmen":
        _biography_mode_id = mode_id
        _showing_biography = true
        _biography_page_index = 0
        _rebuild()
        return
    mode_selected.emit(mode_id)

func _build_construction_dialog_view() -> void :
    var compact: = _is_compact()


    var click_layer: = Control.new()
    click_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
    click_layer.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(click_layer)

    var overlay_bg: = ColorRect.new()
    overlay_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay_bg.color = Color(0.0, 0.0, 0.0, 0.85)
    click_layer.add_child(overlay_bg)


    var dialog_panel: = PanelContainer.new()
    dialog_panel.name = "ConstructionPanel"
    dialog_panel.set_anchors_preset(Control.PRESET_CENTER)
    dialog_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    dialog_panel.grow_vertical = Control.GROW_DIRECTION_BOTH

    if compact:
        dialog_panel.custom_minimum_size = Vector2(640, 500)
    else:
        dialog_panel.custom_minimum_size = Vector2(560, 380)

    var panel_style: = StyleBoxFlat.new()
    panel_style.bg_color = GameState.get_theme_color("bg_popup")
    panel_style.border_color = Color(0.42, 0.43, 0.44, 0.72)
    panel_style.border_width_left = 1
    panel_style.border_width_top = 1
    panel_style.border_width_right = 1
    panel_style.border_width_bottom = 1
    panel_style.corner_radius_top_left = 0
    panel_style.corner_radius_top_right = 0
    panel_style.corner_radius_bottom_left = 0
    panel_style.corner_radius_bottom_right = 0
    panel_style.shadow_color = Color(0, 0, 0, 0.6)
    panel_style.shadow_size = 24
    dialog_panel.add_theme_stylebox_override("panel", panel_style)
    click_layer.add_child(dialog_panel)

    var margin: = MarginContainer.new()
    var pad: = 36 if compact else 28
    margin.add_theme_constant_override("margin_left", pad)
    margin.add_theme_constant_override("margin_right", pad)
    margin.add_theme_constant_override("margin_top", pad)
    margin.add_theme_constant_override("margin_bottom", pad)
    dialog_panel.add_child(margin)

    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 24 if compact else 18)
    margin.add_child(vbox)


    var title_lbl: = Label.new()
    title_lbl.text = "神秘施工现场"
    title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_lbl.add_theme_font_override("font", FONT_BOLD)
    title_lbl.add_theme_font_size_override("font_size", 36 if compact else 22)
    title_lbl.add_theme_color_override("font_color", GOLD)
    vbox.add_child(title_lbl)

    var sep: = HSeparator.new()
    var sep_style: = StyleBoxLine.new()
    sep_style.color = GOLD
    sep_style.color.a = 0.28
    sep.add_theme_stylebox_override("separator", sep_style)
    vbox.add_child(sep)


    var mode_name: = ""
    if _construction_mode_id == "shijia":
        mode_name = "没落世家（边务线）"
    elif _construction_mode_id == "free":
        mode_name = "自由模式（旷野线）"
    else:
        mode_name = "未定义线路"

    var content_lbl: = Label.new()
    content_lbl.text = "此处的「%s」内容仍在全力建设中，暂未正式开放。\n\n如果你不小心点进来了，那么你应该是被某种洪荒之力卷进了神秘施工现场。\n请耐心等待，以后再来玩吧。" % mode_name
    content_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    content_lbl.add_theme_font_override("font", FONT_BODY)
    content_lbl.add_theme_font_size_override("font_size", 28 if compact else 15)
    content_lbl.add_theme_color_override("font_color", Color(0.92, 0.88, 0.76, 0.96))
    content_lbl.add_theme_constant_override("line_spacing", 10 if compact else 6)
    vbox.add_child(content_lbl)

    var spacer: = Control.new()
    spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    vbox.add_child(spacer)


    var btn_box: = HBoxContainer.new()
    btn_box.alignment = BoxContainer.ALIGNMENT_CENTER
    btn_box.add_theme_constant_override("separation", 40 if compact else 24)
    vbox.add_child(btn_box)

    var btn_back: = Button.new()
    btn_back.text = "先回去了"
    btn_back.focus_mode = Control.FOCUS_NONE
    btn_back.custom_minimum_size = Vector2(240 if compact else 140, 68 if compact else 40)
    btn_back.add_theme_font_override("font", FONT_BODY)
    btn_back.add_theme_font_size_override("font_size", 28 if compact else 16)
    GameScreenStyleFactory.apply_command_button_style(btn_back, "secondary", 18, 8)
    btn_back.pressed.connect( func():
        _showing_construction_dialog = false
        _rebuild()
    )
    btn_box.add_child(btn_back)

    var btn_continue: = Button.new()
    btn_continue.text = "执意探索"
    btn_continue.focus_mode = Control.FOCUS_NONE
    btn_continue.custom_minimum_size = Vector2(240 if compact else 140, 68 if compact else 40)
    btn_continue.add_theme_font_override("font", FONT_BODY)
    btn_continue.add_theme_font_size_override("font_size", 28 if compact else 16)
    GameScreenStyleFactory.apply_command_button_style(btn_continue, "primary", 18, 8)
    btn_continue.pressed.connect( func():
        _showing_construction_dialog = false
        var mid = _construction_mode_id
        if mid == "shijia":
            _biography_mode_id = "shijia"
            _showing_biography = true
            _biography_page_index = 0
            _rebuild()
        elif mid == "free":
            mode_selected.emit("free")
    )
    btn_box.add_child(btn_continue)

func _build_biography_view() -> void :



    if is_instance_valid(GameState):

        GameState.governance_playlist_active = false
        GameState.play_bgm("res://assets/" + "prologue_bgm.mp3", 1.5)
    var compact: = _is_compact()
    _kill_biography_tweens()
    _biography_lines.clear()
    _is_revealing_biography = false

    var click_layer: = Control.new()
    click_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
    click_layer.mouse_filter = Control.MOUSE_FILTER_STOP
    click_layer.gui_input.connect(_on_biography_input)
    add_child(click_layer)

    var margin: = MarginContainer.new()
    margin.set_anchors_preset(Control.PRESET_FULL_RECT)
    margin.mouse_filter = Control.MOUSE_FILTER_IGNORE


    margin.add_theme_constant_override("margin_left", 34 if compact else 132)
    margin.add_theme_constant_override("margin_top", 40 if compact else 56)
    margin.add_theme_constant_override("margin_right", 34 if compact else 132)
    margin.add_theme_constant_override("margin_bottom", 40 if compact else 56)
    click_layer.add_child(margin)

    var layout: = VBoxContainer.new()
    layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layout.alignment = BoxContainer.ALIGNMENT_CENTER
    layout.add_theme_constant_override("separation", 22 if compact else 24)
    margin.add_child(layout)

    if _biography_page_index == 0:
        var chapter_label: = Label.new()
        chapter_label.text = "序章"
        chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        chapter_label.add_theme_font_override("font", FONT_BODY)
        chapter_label.add_theme_font_size_override("font_size", 22 if compact else 16)
        chapter_label.add_theme_color_override("font_color", Color(0.82, 0.78, 0.66, 0.5))
        chapter_label.modulate.a = 0.0
        layout.add_child(chapter_label)
        _biography_lines.append(chapter_label)

        var cap_spacer: = Control.new()
        cap_spacer.custom_minimum_size = Vector2(0, 36 if compact else 28)
        layout.add_child(cap_spacer)

    var text_box: = VBoxContainer.new()
    text_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
    text_box.alignment = BoxContainer.ALIGNMENT_CENTER
    text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    text_box.add_theme_constant_override("separation", 18 if compact else 20)
    layout.add_child(text_box)

    var current_page: Array = _current_biography_pages()[_biography_page_index]
    for paragraph in current_page:
        var line: = RichTextLabel.new()
        line.text = paragraph
        line.bbcode_enabled = false
        line.fit_content = true
        line.scroll_active = false
        line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        line.mouse_filter = Control.MOUSE_FILTER_IGNORE
        line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        line.custom_minimum_size = Vector2(0, 0)
        line.add_theme_font_override("normal_font", FONT_BODY)
        line.add_theme_font_size_override("normal_font_size", 31 if compact else 22)
        line.add_theme_color_override("default_color", Color(0.92, 0.88, 0.76, 0.96))
        line.add_theme_constant_override("line_separation", 12 if compact else 10)

        line.visible_ratio = 0.0
        text_box.add_child(line)
        _biography_lines.append(line)

    var bottom: = VBoxContainer.new()
    bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
    bottom.alignment = BoxContainer.ALIGNMENT_CENTER
    bottom.custom_minimum_size = Vector2(0, BIOGRAPHY_CONTINUE_SLOT_HEIGHT_COMPACT if compact else BIOGRAPHY_CONTINUE_SLOT_HEIGHT)
    bottom.add_theme_constant_override("separation", 16)
    layout.add_child(bottom)

    _biography_arrow = Label.new()
    _biography_arrow.name = "ContinueArrow"
    _biography_arrow.text = "▼"
    _biography_arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _biography_arrow.add_theme_font_override("font", FONT_BODY)
    _biography_arrow.add_theme_font_size_override("font_size", 12 if compact else 8)
    _biography_arrow.add_theme_color_override("font_color", Color(0.94, 0.91, 0.82, 0.42))
    _biography_arrow.visible = true
    _biography_arrow.modulate.a = 0.0
    bottom.add_child(_biography_arrow)

    _assignment_button = Button.new()
    var start: = _assignment_button
    start.text = "接牌赴任" if _biography_mode_id == "shijia" else "开始篇章"
    start.focus_mode = Control.FOCUS_NONE
    start.visible = false
    start.mouse_filter = Control.MOUSE_FILTER_STOP
    start.custom_minimum_size = Vector2(210 if compact else 168, 60 if compact else 48)
    start.add_theme_font_override("font", FONT_BODY)
    start.add_theme_font_size_override("font_size", 27 if compact else 18)
    var biography_mode_id: = _biography_mode_id
    start.pressed.connect( func(): mode_selected.emit(biography_mode_id))
    GameScreenStyleFactory.apply_command_button_style(start, "primary", 18, 8)
    _apply_biography_start_button_style(start)
    bottom.add_child(start)

    call_deferred("_animate_biography_lines", _biography_page_index)




func _biography_start_button_style(state: String) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    var dark: = GameState.theme == "dark"
    match state:
        "hover":
            style.bg_color = Color(0.16, 0.1, 0.05, 0.38) if dark else Color(0.8, 0.7, 0.5, 0.22)
            style.border_color = Color(0.86, 0.7, 0.4, 0.88) if dark else Color(0.45, 0.33, 0.18, 0.72)
        "pressed":
            style.bg_color = Color(0.1, 0.07, 0.035, 0.52) if dark else Color(0.72, 0.62, 0.42, 0.3)
            style.border_color = Color(0.86, 0.7, 0.4, 0.88) if dark else Color(0.45, 0.33, 0.18, 0.72)
        _:
            style.bg_color = Color(0, 0, 0, 0)
            style.border_color = Color(0.78, 0.62, 0.32, 0.62) if dark else Color(0.45, 0.33, 0.18, 0.52)
    style.set_border_width_all(1)
    style.set_corner_radius_all(8)
    style.content_margin_left = 18
    style.content_margin_right = 18
    style.content_margin_top = 8
    style.content_margin_bottom = 8
    return style

func _apply_biography_start_button_style(button: Button) -> void :
    var gold: = GameState.get_theme_color("border_active")
    button.add_theme_color_override("font_color", gold)
    button.add_theme_color_override("font_hover_color", gold.lightened(0.12) if GameState.theme == "dark" else gold.darkened(0.08))
    button.add_theme_color_override("font_pressed_color", gold)
    button.add_theme_stylebox_override("normal", _biography_start_button_style("normal"))
    button.add_theme_stylebox_override("hover", _biography_start_button_style("hover"))
    button.add_theme_stylebox_override("pressed", _biography_start_button_style("pressed"))

func _on_biography_input(event: InputEvent) -> void :
    if not _showing_biography:
        return
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        _advance_biography()
    elif event is InputEventScreenTouch and event.pressed:
        _advance_biography()

func _advance_biography() -> void :

    var frame: = Engine.get_process_frames()
    if frame == _last_biography_advance_frame:
        return
    _last_biography_advance_frame = frame
    if _is_revealing_biography:
        _kill_biography_tweens()
        for line in _biography_lines:
            if not is_instance_valid(line):
                continue
            line.modulate.a = 1.0
            if line is RichTextLabel:
                (line as RichTextLabel).visible_ratio = 1.0
        _is_revealing_biography = false
        _refresh_biography_continue_state()
        return
    if _biography_page_index < _current_biography_pages().size() - 1:
        _biography_page_index += 1
        _rebuild()

func _kill_biography_tweens() -> void :
    for tween in _biography_tweens:
        if tween != null and tween.is_valid():
            tween.kill()
    _biography_tweens.clear()

func _animate_biography_lines(page_index: int) -> void :
    if not _showing_biography or page_index != _biography_page_index:
        return
    _kill_biography_tweens()
    _is_revealing_biography = true
    if is_instance_valid(_biography_arrow):
        _biography_arrow.modulate.a = 0.0
    if is_instance_valid(_assignment_button):
        _assignment_button.visible = false



    var per_char: = 0.1
    var para_gap: = 0.45
    var cursor: = 0.0
    var total: = 0.0
    for i in _biography_lines.size():
        var line: Control = _biography_lines[i]
        if not is_instance_valid(line):
            continue
        if line is RichTextLabel:
            var rich: RichTextLabel = line
            rich.visible_ratio = 0.0
            var char_count: int = max(1, rich.text.length())
            var dur: float = clamp(char_count * per_char, 0.6, 3.2)
            var tween: = create_tween()
            tween.tween_interval(cursor)
            tween.tween_property(rich, "visible_ratio", 1.0, dur)
            _biography_tweens.append(tween)
            cursor += dur + para_gap
            total = max(total, cursor - para_gap)
        else:

            line.modulate.a = 0.0
            var t: = create_tween()
            t.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
            t.tween_interval(cursor)
            t.tween_property(line, "modulate:a", 1.0, 0.9)
            _biography_tweens.append(t)
            cursor += 0.9 + para_gap
            total = max(total, cursor - para_gap)

    if total <= 0.0:
        _is_revealing_biography = false
        _refresh_biography_continue_state()
        return
    await get_tree().create_timer(total).timeout
    if not _is_revealing_biography or not _showing_biography or page_index != _biography_page_index:
        return
    _biography_tweens.clear()
    _is_revealing_biography = false
    _refresh_biography_continue_state()

func _refresh_biography_continue_state() -> void :
    var is_last_page: = _biography_page_index >= _current_biography_pages().size() - 1
    if is_instance_valid(_biography_arrow):
        _biography_arrow.modulate.a = 0.0 if is_last_page else 1.0
    if is_instance_valid(_assignment_button):
        _assignment_button.visible = is_last_page

func _card_style(enabled: bool, hover: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = (GameState.get_theme_color("bg_popup") if enabled else Color(0.18, 0.17, 0.15, 0.78))
    if hover and enabled:
        style.bg_color = style.bg_color.lightened(0.05)
    style.border_color = (GOLD if enabled else Color(0.42, 0.4, 0.36, 0.5))
    style.border_color.a = (0.72 if hover else 0.52) if enabled else 0.28

    style.border_width_left = 2
    style.border_width_top = 2
    style.border_width_right = 2
    style.border_width_bottom = 2
    style.corner_radius_top_left = 0
    style.corner_radius_top_right = 0
    style.corner_radius_bottom_left = 0
    style.corner_radius_bottom_right = 0
    style.shadow_color = Color(0, 0, 0, 0.4 if enabled else 0.14)
    style.shadow_size = (18 if hover else 12) if enabled else 3
    style.shadow_offset = Vector2(0, 5 if enabled else 1)
    return style

func _card_inner_frame_style(enabled: bool, hover: bool) -> StyleBoxFlat:

    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0, 0, 0, 0.0)
    style.border_color = (GOLD if enabled else Color(0.42, 0.4, 0.36, 0.5))
    style.border_color.a = (0.42 if hover else 0.24) if enabled else 0.14
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.corner_radius_top_left = 0
    style.corner_radius_top_right = 0
    style.corner_radius_bottom_left = 0
    style.corner_radius_bottom_right = 0
    return style

func _panel_style() -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = GameState.get_theme_color("bg_popup")
    style.border_color = GameState.get_theme_color("border")
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.corner_radius_top_left = 0
    style.corner_radius_top_right = 0
    style.corner_radius_bottom_left = 0
    style.corner_radius_bottom_right = 0
    return style

func _style_button(btn: Button, primary: bool) -> void :
    var normal: = StyleBoxFlat.new()
    if primary:

        normal.bg_color = Color(0.28, 0.18, 0.1, 0.88)
        normal.border_color = GOLD
        normal.border_color.a = 0.65
    else:

        normal.bg_color = Color(0.08, 0.06, 0.04, 0.52)
        normal.border_color = GOLD
        normal.border_color.a = 0.28

    normal.border_width_left = 1
    normal.border_width_top = 1
    normal.border_width_right = 1
    normal.border_width_bottom = 1
    normal.corner_radius_top_left = 6
    normal.corner_radius_top_right = 6
    normal.corner_radius_bottom_left = 6
    normal.corner_radius_bottom_right = 6

    var hover: = normal.duplicate() as StyleBoxFlat
    if primary:
        hover.bg_color = Color(0.38, 0.25, 0.14, 0.95)
        hover.border_color.a = 0.85
    else:
        hover.bg_color = Color(0.14, 0.1, 0.07, 0.72)
        hover.border_color.a = 0.45

    var pressed: = normal.duplicate() as StyleBoxFlat
    if primary:
        pressed.bg_color = Color(0.22, 0.14, 0.08, 0.88)
    else:
        pressed.bg_color = Color(0.06, 0.04, 0.03, 0.62)

    btn.add_theme_stylebox_override("normal", normal)
    btn.add_theme_stylebox_override("hover", hover)
    btn.add_theme_stylebox_override("pressed", pressed)
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


    var font_color = Color(0.94, 0.88, 0.75, 1.0) if primary else Color(0.82, 0.77, 0.66, 0.88)
    var font_hover = Color(1.0, 0.94, 0.8, 1.0) if primary else Color(0.94, 0.88, 0.75, 1.0)
    btn.add_theme_color_override("font_color", font_color)
    btn.add_theme_color_override("font_hover_color", font_hover)
    btn.add_theme_color_override("font_pressed_color", font_hover)


func _style_assignment_button(btn: Button) -> void :
    var normal: = StyleBoxFlat.new()
    normal.draw_center = false
    normal.border_color = Color(0.94, 0.91, 0.84, 0.72)
    normal.border_width_left = 1
    normal.border_width_top = 1
    normal.border_width_right = 1
    normal.border_width_bottom = 1
    normal.corner_radius_top_left = 5
    normal.corner_radius_top_right = 5
    normal.corner_radius_bottom_left = 5
    normal.corner_radius_bottom_right = 5
    var hover: = normal.duplicate() as StyleBoxFlat
    hover.border_color = Color(1.0, 0.96, 0.88, 0.96)
    btn.add_theme_stylebox_override("normal", normal)
    btn.add_theme_stylebox_override("hover", hover)
    btn.add_theme_stylebox_override("pressed", normal)
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    btn.add_theme_color_override("font_color", Color(0.94, 0.91, 0.84, 0.9))
    btn.add_theme_color_override("font_hover_color", Color(1.0, 0.97, 0.9, 1.0))

func _apply_native_mobile_font_scale() -> void :
    if not OS.has_feature("android"):
        return
    NativeMobileFontScalerRef.apply_to(self)

func _style_back_button(btn: Button) -> void :
    btn.add_theme_stylebox_override("normal", _button_style(Color(0.02, 0.018, 0.014, 0.62), Color(0.72, 0.56, 0.28, 0.25)))
    btn.add_theme_stylebox_override("hover", _button_style(Color(0.16, 0.1, 0.05, 0.62), Color(0.8, 0.62, 0.32, 0.42)))
    btn.add_theme_stylebox_override("pressed", _button_style(Color(0.1, 0.07, 0.035, 0.76), Color(0.8, 0.62, 0.32, 0.42)))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

    var norm_color = Color(0.74, 0.64, 0.45, 0.9)
    var hover_color = Color(0.96, 0.84, 0.58, 1.0)
    btn.add_theme_color_override("font_color", norm_color)
    btn.add_theme_color_override("font_hover_color", hover_color)
    btn.add_theme_color_override("font_pressed_color", hover_color)

    btn.icon = load("res://assets/ui/back.svg")
    btn.expand_icon = false
    btn.add_theme_constant_override("h_separation", 6)
    btn.add_theme_color_override("icon_normal_color", norm_color)
    btn.add_theme_color_override("icon_hover_color", hover_color)
    btn.add_theme_color_override("icon_pressed_color", hover_color)
    btn.add_theme_color_override("icon_focus_color", hover_color)

    var fs = btn.get_theme_font_size("font_size")
    if fs <= 0:
        fs = 16
    btn.add_theme_constant_override("icon_max_width", fs)

func _button_style(bg: Color, border: Color) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = bg
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = border
    style.corner_radius_top_left = 8
    style.corner_radius_top_right = 8
    style.corner_radius_bottom_left = 8
    style.corner_radius_bottom_right = 8
    style.shadow_size = 6 if GameState.theme == "dark" and bg.a > 0.2 else 0
    style.shadow_color = Color(0, 0, 0, 0.26)
    style.content_margin_left = 18
    style.content_margin_top = 10
    style.content_margin_right = 18
    style.content_margin_bottom = 10
    return style

func _update_card_hover(card: Button, hover: bool) -> void :
    var enabled = not card.disabled
    var art = card.find_child("ModeCardArt", true, false) as TextureRect
    if art:
        var mode_id = card.get_meta("mode_id", "")
        art.modulate = _mode_art_modulate(mode_id, enabled, hover)
    var inner_frame = card.find_child("ModeCardInnerFrame", true, false) as Panel
    if inner_frame:
        inner_frame.add_theme_stylebox_override("panel", _card_inner_frame_style(enabled, hover))

func _mode_art_modulate(id: String, enabled: bool, hover: bool) -> Color:
    if not enabled:
        return LOCKED_MODE_ART_MODULATE
    if id == "free":
        if hover:
            return Color(0.85, 0.8, 0.7, 0.46)
        return Color(0.7, 0.65, 0.55, 0.32)
    else:
        if hover:
            return Color(1.5, 1.35, 1.1, 0.95)
        return Color(1.3, 1.2, 1.0, 0.88)

func _build_tag_chip(text: String, enabled: bool) -> PanelContainer:
    var chip = PanelContainer.new()
    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.12, 0.08, 0.04, 0.52) if enabled else Color(0.08, 0.08, 0.08, 0.35)
    style.border_color = Color(0.7, 0.48, 0.2, 0.4) if enabled else Color(0.42, 0.4, 0.36, 0.22)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.corner_radius_top_left = 8
    style.corner_radius_top_right = 8
    style.corner_radius_bottom_left = 8
    style.corner_radius_bottom_right = 8
    style.content_margin_left = 8
    style.content_margin_top = 4
    style.content_margin_right = 8
    style.content_margin_bottom = 4
    chip.add_theme_stylebox_override("panel", style)

    var label = Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_override("font", FONT_BODY)
    var compact: = _is_compact()
    label.add_theme_font_size_override("font_size", 20 if compact else 13)
    label.add_theme_color_override("font_color", Color(0.86, 0.7, 0.42, 0.9) if enabled else Color(0.55, 0.53, 0.49, 0.6))
    chip.add_child(label)
    return chip
