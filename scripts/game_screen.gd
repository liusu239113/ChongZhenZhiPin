extends Control

signal game_ended(ending: Dictionary)
signal show_rank_tree_requested
signal restart_requested

const AdsConfigRef = preload("res://scripts/services/ads_config.gd")
const EffectsServiceRef = preload("res://scripts/services/effects_service.gd")
const EndingServiceRef = preload("res://scripts/services/ending_service.gd")
const EventServiceRef = preload("res://scripts/services/event_service.gd")
const PersonalStatCapstoneServiceRef = preload("res://scripts/services/personal_stat_capstone_service.gd")
const BianwuDefenseServiceRef = preload("res://scripts/services/bianwu_defense_service.gd")
const BianwuHexMapRef = preload("res://scripts/ui/bianwu_hex_map.gd")
const BianwuDeploymentSlotControllerRef = preload("res://scripts/ui/bianwu_deployment_slot_controller.gd")
const ChoiceRequirementServiceRef = preload("res://scripts/services/choice_requirement_service.gd")
const Presenter = preload("res://scripts/ui/game_screen_presenter.gd")
const ChoiceHintBuilderRef = preload("res://scripts/ui/choice_hint_builder.gd")
const ChoiceTitleFormatterRef = preload("res://scripts/ui/choice_title_formatter.gd")
const ItemListBuilderRef = preload("res://scripts/ui/item_list_builder.gd")
const ItemDetailBuilderRef = preload("res://scripts/ui/item_detail_builder.gd")
const LingwuItemDrawServiceRef = preload("res://scripts/services/lingwu_item_draw_service.gd")
const GovernanceCalendarTextRef = preload("res://scripts/ui/governance_calendar_text.gd")
const ScrollbarThemeRef = preload("res://scripts/ui/scrollbar_theme.gd")
const NativeMobileFontScalerRef = preload("res://scripts/ui/native_mobile_font_scaler.gd")
const NativeMobileTouchScrollRef = preload("res://scripts/ui/native_mobile_touch_scroll.gd")
const FontLoader = preload("res://scripts/ui/font_loader.gd")
const GrainTexture = preload("res://scripts/ui/grain_texture.gd")
const CardAnimations = preload("res://scripts/ui/card_animations.gd")
const DianshiController = preload("res://scripts/ui/dianshi_controller.gd")
const DiceOverlayController = preload("res://scripts/ui/dice_overlay_controller.gd")
const ItemsOverlayController = preload("res://scripts/ui/items_overlay_controller.gd")
const MingMapController = preload("res://scripts/ui/ming_map_controller.gd")
const HelpOverlayController = preload("res://scripts/ui/help_overlay_controller.gd")
const TransitionToastController = preload("res://scripts/ui/transition_toast_controller.gd")
const SettingsPopupController = preload("res://scripts/ui/settings_popup_controller.gd")
const SettingsPopupStyle = preload("res://scripts/ui/settings_popup_style.gd")
const GearIcon = preload("res://scripts/ui/gear_icon.gd")
const GameScreenStyleFactory = preload("res://scripts/ui/game_screen_style_factory.gd")
const PortraitBacking = preload("res://scripts/ui/portrait_backing.gd")
const CHOICE_CIRCLE_PATTERN = preload("res://assets/ui/choice_circle_pattern.png")
const EventPortraitController = preload("res://scripts/ui/event_portrait_controller.gd")
const MobileReadingController = preload("res://scripts/ui/mobile_reading_controller.gd")
const MonthWarningController = preload("res://scripts/ui/month_warning_controller.gd")
const GovernanceMonthCardDisplay = preload("res://scripts/ui/governance_month_card_display.gd")
const ResponsiveLayoutController = preload("res://scripts/ui/responsive_layout_controller.gd")
const SidePanelLayoutController = preload("res://scripts/ui/side_panel_layout_controller.gd")
const MobileBottomTabController = preload("res://scripts/ui/mobile_bottom_tab_controller.gd")
const CityStatsDisplayController = preload("res://scripts/ui/city_stats_display_controller.gd")
const OverviewPanelController = preload("res://scripts/ui/overview_panel_controller.gd")
const StatusIconUtil = preload("res://scripts/ui/status_icon_util.gd")
const ResourceTooltipController = preload("res://scripts/ui/resource_tooltip_controller.gd")
const BattleTypesRef = preload("res://scripts/battle/battle_types.gd")
const UNIT_RENAME_ICON = preload("res://assets/ui/unit_rename.svg")
const UNIT_UPGRADE_ICON = preload("res://assets/ui/unit_upgrade.svg")
const LINGWU_BTN_ICON_STAT = preload("res://assets/ui/lingwu/lingwu_stat.png")
const LINGWU_BTN_ICON_CITY = preload("res://assets/ui/lingwu/lingwu_city.png")
const LINGWU_BTN_ICON_CARD = preload("res://assets/ui/lingwu/lingwu_card.png")
const LINGWU_BTN_ICON_ITEM_DRAW = preload("res://assets/ui/lingwu/lingwu_item_draw.png")
const GAME_BG_DEFAULT = preload("res://assets/game_background_v2.webp")
const GAME_BG_GOVERNANCE_OVERVIEW = preload("res://assets/frame_5.webp")
const GAME_BACKGROUND_MASK_TOP: = Color(0.018, 0.017, 0.014, 0.52)
const GAME_BACKGROUND_MASK_MID: = Color(0.012, 0.011, 0.009, 0.7)
const GAME_BACKGROUND_MASK_BOTTOM: = Color(0.012, 0.011, 0.009, 0.88)

const DARK_GOVERNANCE_OVERVIEW_MASK_TOP: = Color(0.018, 0.017, 0.014, 0.12)
const DARK_GOVERNANCE_OVERVIEW_MASK_MID: = Color(0.012, 0.011, 0.009, 0.18)
const DARK_GOVERNANCE_OVERVIEW_MASK_BOTTOM: = Color(0.012, 0.011, 0.009, 0.3)



const GAME_BG_LIGHT_ILLUST_WIDTH_RATIO: = 0.78

const GAME_BG_LIGHT_GOV_BACKDROP: = Color(0.878, 0.878, 0.878, 1.0)
const GAME_BACKGROUND_MASK_LIGHT_EDGE: = Color(0.98, 0.98, 0.97, 0.08)
const GAME_BACKGROUND_MASK_LIGHT_CLEAR: = Color(0.98, 0.98, 0.97, 0.0)
const MOBILE_GOVERNANCE_MASK_TOP: = Color(0.0, 0.0, 0.0, 0.72)
const MOBILE_GOVERNANCE_MASK_MID: = Color(0.0, 0.0, 0.0, 0.86)
const MOBILE_GOVERNANCE_MASK_BOTTOM: = Color(0.0, 0.0, 0.0, 1.0)
const MOBILE_EVENT_READING_MASK_COLOR: = Color(0.0, 0.0, 0.0, 0.64)
const CHOICE_REQUIREMENT_HINT_MIN_VALUE: = 10
const BIANWU_FORCE_CARD_CAP: = 10000
const MING_MAP_BASE_PATH: = "res://assets/map/ming_base_map.webp"
const MING_MAP_CURRENT_MARKER_PATH: = "res://assets/map/city_marker_current.svg"
const MING_MAP_MIN_ZOOM: = 1.0
const MING_MAP_MAX_ZOOM: = 3.0
const MING_MAP_ZOOM_STEP: = 1.16
const DIANSHI_ROLL_TARGET: = 60
const DIANSHI_YIJIA_ROLL_TARGET: = 75
const DIANSHI_ROLL_STATS: = [
    {"key": "wentao", "label": "文韬"}, 
    {"key": "wulue", "label": "武略"}, 
    {"key": "lizheng", "label": "理政"}, 
    {"key": "tizhi", "label": "体质"}
]

const PERSONAL_STAT_KEYS: = ["wentao", "wulue", "lizheng", "tizhi"]
const PERSONAL_STAT_LABELS: = {"wentao": "文韬", "wulue": "武略", "lizheng": "理政", "tizhi": "体质"}
const DIANSHI_MODAL_ACCENT: = Color(0.74, 0.58, 0.34, 1.0)
const DIANSHI_MODAL_BORDER: = Color(0.42, 0.43, 0.44, 0.72)
const DIANSHI_SUCCESS: = Color(0.48, 0.78, 0.44, 1.0)
const DIANSHI_FAIL: = Color(0.86, 0.38, 0.3, 1.0)
const DICE_SUCCESS_SYMBOL: = "亨"
const DICE_FAIL_SYMBOL: = "否"
const PORTRAIT_MAP: = {
    "行脚僧": "res://assets/portraits/senglv.webp", 
    "薄珏": "res://assets/portraits/bojue.webp", 
    "西洋传教士": "res://assets/portraits/chuanjiaoshi.webp", 
    "江湖草莽": "res://assets/portraits/jianghucaomang.webp", 
    "镖客": "res://assets/portraits/nanbiaoshi.webp", 
    "男镖师": "res://assets/portraits/nanbiaoshi.webp", 
    "镖师": "res://assets/portraits/nanbiaoshi.webp", 
    "篾匠": "res://assets/portraits/shouyiren.webp", 
    "铁匠": "res://assets/portraits/shouyiren.webp", 
    "木匠": "res://assets/portraits/shouyiren.webp", 
    "石匠": "res://assets/portraits/shouyiren.webp", 
    "剃头匠": "res://assets/portraits/shouyiren.webp", 
    "挑夫": "res://assets/portraits/shouyiren.webp", 
    "药材商": "res://assets/portraits/shouyiren.webp", 
    "情报头目": "res://assets/portraits/shouyiren.webp", 
    "牛贩子": "res://assets/portraits/niufanzi.webp", 
    "走私贩": "res://assets/portraits/niufanzi.webp", 
    "赌徒": "res://assets/portraits/niufanzi.webp", 
    "讼棍": "res://assets/portraits/luopowenshi.webp", 
    "王老爷": "res://assets/portraits/wanglaoye.webp", 
    "王敬斋": "res://assets/portraits/laozhe.webp", 
    "徐霞客": "res://assets/portraits/xuxiake.webp", 
    "徐霞客·黄河的预警": "res://assets/portraits/xuxiake.webp", 
    "徐霞客·最后的手稿": "res://assets/portraits/xuxiake.webp", 
    "李天经": "res://assets/portraits/litianjing.webp", 
    "汤若望": "res://assets/portraits/tangruowang.webp", 
    "汤若望·铸炮畿南": "res://assets/portraits/tangruowang.webp", 
    "汤若望·焦土里的铁信": "res://assets/portraits/tangruowang.webp", 
    "赵二锤": "res://assets/portraits/zhaoerchui.webp", 
    "赵二锤·旱地里见过": "res://assets/portraits/zhaoerchui.webp", 
    "赵二锤·喝一杯": "res://assets/portraits/zhaoerchui.webp", 
    "赵二锤·剿匪": "res://assets/portraits/zhaoerchui.webp", 
    "赵二锤·守隘": "res://assets/portraits/zhaoerchui.webp", 
    "赵二锤·你的刀": "res://assets/portraits/zhaoerchui.webp", 
    "李老三": "res://assets/portraits/lilaosan.webp", 
    "顾炎武": "res://assets/portraits/guyanwu_young.webp", 
    "顾炎武·畿南问政": "res://assets/portraits/guyanwu_adult.webp", 
    "顾炎武·归山东，问天下": "res://assets/portraits/guyanwu_adult.webp", 
    "王夫之": "res://assets/portraits/wangfuzhi_young.webp", 
    "王夫之·乱世问实": "res://assets/portraits/wangfuzhi_adult.webp", 
    "王夫之·公天下": "res://assets/portraits/wangfuzhi_adult.webp", 
    "傅山": "res://assets/portraits/fushan.webp", 
    "傅山·故人在直隶": "res://assets/portraits/fushan.webp", 
    "傅山·焦土尽头的信": "res://assets/portraits/fushan.webp", 
    "孙奇逢": "res://assets/portraits/sunqifeng.webp", 
    "贾凫西": "res://assets/portraits/jiafuxi.webp", 
    "大顺密使": "res://assets/portraits/dashun_mishi.webp", 
    "三方使者": "res://assets/portraits/dashun_mishi.webp", 
    "清军使者": "res://assets/portraits/daqing_shizhe.webp", 
    "冒辟疆": "res://assets/portraits/maobijiang.webp", 
    "陈子龙": "res://assets/portraits/chenzilong.webp", 
    "陈子龙·经世同路人": "res://assets/portraits/chenzilong_middle.webp", 
    "陈洪绶": "res://assets/portraits/chen_hongshou.webp", 
    "凌濛初": "res://assets/portraits/ling_mengchu.webp", 
    "书商": "res://assets/portraits/shushang.webp", 
    "书商·玄字册": "res://assets/portraits/shushang.webp", 
    "书商·洪字册": "res://assets/portraits/shushang.webp", 
    "书商·荒字册": "res://assets/portraits/shushang.webp", 
    "书商·日字册": "res://assets/portraits/shushang.webp", 
    "书商·盈字册": "res://assets/portraits/shushang.webp", 
    "书商·宿字册": "res://assets/portraits/shushang.webp", 
    "书商·元素遗稿": "res://assets/portraits/shushang.webp", 
    "守城把总": "res://assets/portraits/junguan.webp", 
    "驻防千总": "res://assets/portraits/junguan.webp", 
    "千总官": "res://assets/portraits/junguan.webp", 
    "练总": "res://assets/portraits/lianzong.webp", 
    "团练练总": "res://assets/portraits/lianzong.webp", 
    "把总": "res://assets/portraits/junguan.webp", 
    "亲兵队长": "res://assets/portraits/junguan.webp", 
    "河工把总": "res://assets/portraits/hegong.webp", 
    "募兵把总": "res://assets/portraits/junguan.webp", 
    "老把总": "res://assets/portraits/junguan.webp", 
    "军官": "res://assets/portraits/junguan.webp", 
    "守备": "res://assets/portraits/junguan.webp", 
    "游击": "res://assets/portraits/junguan.webp", 
    "参将": "res://assets/portraits/canjiang.webp", 
    "降顺参将": "res://assets/portraits/canjiang.webp", 
    "副将": "res://assets/portraits/junguan.webp", 
    "总兵": "res://assets/portraits/junguan.webp", 
    "先锋营小校": "res://assets/portraits/junguan.webp", 
    "降顺小校": "res://assets/portraits/junguan.webp", 
    "士卒": "res://assets/portraits/shizu.webp", 
    "士兵": "res://assets/portraits/shizu.webp", 
    "兵卒": "res://assets/portraits/shizu.webp", 
    "巡场号军": "res://assets/portraits/shizu.webp", 
    "败卒": "res://assets/portraits/baizu.webp", 
    "败退士卒": "res://assets/portraits/baizu.webp", 
    "溃兵": "res://assets/portraits/baizu.webp", 
    "逃兵": "res://assets/portraits/baizu.webp", 
    "辽东败兵": "res://assets/portraits/baizu.webp", 
    "溃军总兵": "res://assets/portraits/kuijunzongbing.webp", 
    "溃军把总": "res://assets/portraits/kuijunzongbing.webp", 
    "溃兵把总": "res://assets/portraits/kuijunzongbing.webp", 
    "败兵把总": "res://assets/portraits/kuijunzongbing.webp", 
    "溃将": "res://assets/portraits/kuijunzongbing.webp", 
    "败将": "res://assets/portraits/kuijunzongbing.webp", 
    "老兵": "res://assets/portraits/laozu.webp", 
    "退役老兵": "res://assets/portraits/laozu.webp", 
    "老卒": "res://assets/portraits/laozu.webp", 
    "九边老卒": "res://assets/portraits/laozu.webp", 
    "浑河遗卒": "res://assets/portraits/laozu.webp", 
    "前哨": "res://assets/portraits/lilaosan.webp", 
    "探马": "res://assets/portraits/lilaosan.webp", 
    "哨骑": "res://assets/portraits/lilaosan.webp", 
    "斥候": "res://assets/portraits/lilaosan.webp", 
    "前方斥候": "res://assets/portraits/lilaosan.webp", 
    "斥候队长": "res://assets/portraits/lilaosan.webp", 
    "密探": "res://assets/portraits/lilaosan.webp", 
    "眼线": "res://assets/portraits/lilaosan.webp", 
    "山东来使": "res://assets/portraits/lilaosan.webp", 
    "吏部书吏": "res://assets/portraits/libushuli.webp", 
    "吏部书办": "res://assets/portraits/libushuli.webp", 
    "吏部堂官": "res://assets/portraits/libutangguan.webp", 
    "礼部官员": "res://assets/portraits/libutangguan.webp", 
    "吏部考功司": "res://assets/portraits/libukaogongsizhushi.webp", 
    "考功司主事": "res://assets/portraits/libukaogongsizhushi.webp", 
    "吏部考功司主事": "res://assets/portraits/libukaogongsizhushi.webp", 
    "巡按御史": "res://assets/portraits/libukaogongsizhushi.webp", 
    "兵部司官": "res://assets/portraits/libukaogongsizhushi.webp", 
    "典吏": "res://assets/portraits/dianli.webp", 
    "典史": "res://assets/portraits/dianli.webp", 
    "黄典吏": "res://assets/portraits/dianli.webp", 
    "户房典吏": "res://assets/portraits/hufangdianli.webp", 
    "前任典史": "res://assets/portraits/dianli.webp", 
    "湖广逃吏": "res://assets/portraits/taonanwenshi.webp", 
    "逃难文士": "res://assets/portraits/taonanwenshi.webp", 
    "从潼关逃出的幕僚": "res://assets/portraits/taonanwenshi.webp", 
    "落魄账房": "res://assets/portraits/dianli.webp", 
    "落魄文士": "res://assets/portraits/luopowenshi.webp", 
    "落第举人": "res://assets/portraits/luopowenshi.webp", 
    "许衡圃": "res://assets/portraits/xuhengpu.webp", 
    "方以智": "res://assets/portraits/fangyizhi.webp", 
    "宋应星": "res://assets/portraits/songyingxing.webp", 
    "宋应星·晋地的煤与铁": "res://assets/portraits/songyingxing.webp", 
    "宋应星·天工开物成书": "res://assets/portraits/songyingxing.webp", 
    "文震亨": "res://assets/portraits/wenzhenheng.webp", 
    "毕拱辰": "res://assets/portraits/bigongchen.webp", 
    "张万钟": "res://assets/portraits/zhangwanzhong.webp", 
    "张岱": "res://assets/portraits/zhangdai.webp", 
    "张溥": "res://assets/portraits/zhangpu.webp", 
    "窑匠": "res://assets/portraits/yaojiang.webp", 
    "郎中": "res://assets/portraits/langzhong.webp", 
    "张郎中": "res://assets/portraits/langzhong.webp", 
    "赵郎中": "res://assets/portraits/langzhong.webp", 
    "游方郎中": "res://assets/portraits/langzhong.webp", 
    "城中郎中": "res://assets/portraits/langzhong.webp", 
    "坐堂郎中": "res://assets/portraits/langzhong.webp", 
    "营医": "res://assets/portraits/langzhong.webp", 
    "游医": "res://assets/portraits/langzhong.webp", 
    "医官": "res://assets/portraits/langzhong.webp", 
    "崇祯": "res://assets/portraits/chongzhen_young.webp", 
    "年轻崇祯": "res://assets/portraits/chongzhen_young.webp", 
    "当朝天子": "res://assets/portraits/chongzhen_young.webp", 
    "崇祯皇帝": "res://assets/portraits/chongzhen_middle.webp", 
    "中年崇祯": "res://assets/portraits/chongzhen_middle.webp", 
    "大明皇帝": "res://assets/portraits/chongzhen_middle.webp", 
    "皇帝": "res://assets/portraits/chongzhen_middle.webp", 
    "陈于鼎": "res://assets/portraits/chenyuding.webp", 
    "学正": "res://assets/portraits/xuezheng.webp", 
    "催科书办": "res://assets/portraits/xuezheng.webp", 
    "王征": "res://assets/portraits/wangzheng.webp", 
    "说书人": "res://assets/portraits/shuoshuren.webp", 
    "老农": "res://assets/portraits/hegong.webp", 
    "老匠人": "res://assets/portraits/laozhe.webp", 
    "老粮长": "res://assets/portraits/laozhe.webp", 
    "致仕老儒": "res://assets/portraits/laozhe.webp", 
    "老营管事": "res://assets/portraits/laozhe.webp", 
    "本地乡老": "res://assets/portraits/laozhe.webp", 
    "老者": "res://assets/portraits/laozhe.webp", 
    "百姓代表": "res://assets/portraits/laozhe.webp", 
    "里正": "res://assets/portraits/laozhe.webp", 
    "老猎户": "res://assets/portraits/laoliehu.webp", 
    "老捕头": "res://assets/portraits/laobutou.webp", 
    "捕头": "res://assets/portraits/laobutou.webp", 
    "河西道捕头": "res://assets/portraits/laobutou.webp", 
    "巡灾书吏": "res://assets/portraits/laobutou.webp", 
    "东厂太监": "res://assets/portraits/nianzhangtaijian.webp", 
    "监军太监": "res://assets/portraits/nianzhangtaijian.webp", 
    "镇守太监": "res://assets/portraits/nianzhangtaijian.webp", 
    "司礼监内使": "res://assets/portraits/nianzhangtaijian.webp", 
    "司礼监内史": "res://assets/portraits/nianzhangtaijian.webp", 
    "矿税太监": "res://assets/portraits/nianqingtaijian.webp", 
    "陈公公": "res://assets/portraits/nianzhangtaijian.webp", 
    "吴公公": "res://assets/portraits/nianzhangtaijian.webp", 
    "马公公": "res://assets/portraits/nianqingtaijian.webp", 
    "高公公": "res://assets/portraits/nianzhangtaijian.webp", 
    "范公公": "res://assets/portraits/nianqingtaijian.webp", 
    "河工": "res://assets/portraits/hegong.webp", 
    "河工老把头": "res://assets/portraits/hegong.webp", 
    "河道把头": "res://assets/portraits/hegong.webp", 
    "刘老汉": "res://assets/portraits/hegong.webp", 
    "老船工": "res://assets/portraits/hegong.webp", 
    "船工": "res://assets/portraits/hegong.webp", 
    "老马夫": "res://assets/portraits/hegong.webp", 
    "老军户": "res://assets/portraits/hegong.webp", 
    "养蜂人": "res://assets/portraits/hegong.webp", 
    "张尔岐": "res://assets/portraits/zhangerqi.webp", 

    "村老": "res://assets/portraits/cunlao.webp", 
    "父亲": "res://assets/portraits/fuqin.webp", 
    "母亲": "res://assets/portraits/muqin.webp", 
    "乡绅遗孀": "res://assets/portraits/furen.webp", 
    "郑乡绅": "res://assets/portraits/laozhe.webp", 
    "粮商": "res://assets/portraits/liangshang.webp", 
    "盐商": "res://assets/portraits/liangshang.webp", 
    "布商": "res://assets/portraits/shoushangren.webp", 
    "沈布商": "res://assets/portraits/shoushangren.webp", 
    "盐运司判官": "res://assets/portraits/yanyunsipanguan.webp", 
    "兵部主事": "res://assets/portraits/yanyunsipanguan.webp", 
    "户部勘合差官": "res://assets/portraits/hubukanheguan.webp", 
    "真定督饷委官": "res://assets/portraits/hubukanheguan.webp", 
    "督师行辕粮书": "res://assets/portraits/hubukanheguan.webp", 
    "户部派饷司官": "res://assets/portraits/hubuguan.webp", 
    "户部官": "res://assets/portraits/hubuguan.webp", 
    "吏部文选司郎中": "res://assets/portraits/hubuguan.webp", 
    "漕运催粮官": "res://assets/portraits/hubukanheguan.webp", 
    "师爷": "res://assets/portraits/shiye.webp", 
    "赵藩台": "res://assets/portraits/zhaofantai.webp", 
    "省城幕友": "res://assets/portraits/tongliao.webp", 
    "熊文灿幕僚": "res://assets/portraits/tongliao.webp", 
    "幕僚师爷": "res://assets/portraits/shiye.webp", 
    "首席幕僚": "res://assets/portraits/shiye.webp", 
    "高万利": "res://assets/portraits/gaowanli_early.webp", 
    "高万利·前期": "res://assets/portraits/gaowanli_early.webp", 
    "高万利·中期": "res://assets/portraits/gaowanli_middle.webp", 
    "高万利·后期": "res://assets/portraits/gaowanli_late.webp", 
    "李青山": "res://assets/portraits/liqingshan.webp", 
    "绿林好汉": "res://assets/portraits/liqingshan.webp", 
    "血诏信使": "res://assets/portraits/neitingxinshe.webp", 
    "道士": "res://assets/portraits/laodaoshi.webp", 
    "老道长": "res://assets/portraits/laodaoshi.webp", 
    "武当云游道人": "res://assets/portraits/laodaoshi.webp", 
    "游方道士": "res://assets/portraits/daoshi.webp", 
    "算命瞎子": "res://assets/portraits/suanmingxiazi.webp", 
    "相面先生": "res://assets/portraits/laodaoshi.webp", 
    "测字先生": "res://assets/portraits/daoshi.webp", 
    "风水先生": "res://assets/portraits/daoshi.webp", 
    "王天一": "res://assets/portraits/daoshi.webp", 
    "驿卒": "res://assets/portraits/yizu.webp", 
    "河东塘报": "res://assets/portraits/yizu.webp", 
    "旧部塘报使": "res://assets/portraits/yizu.webp", 
    "兵部塘报": "res://assets/portraits/yizu.webp", 
    "传令塘马": "res://assets/portraits/yizu.webp", 
    "兵部塘马": "res://assets/portraits/yizu.webp", 
    "南方来的信使": "res://assets/portraits/yizu.webp", 
    "传令官": "res://assets/portraits/yizu.webp", 
    "中军传令": "res://assets/portraits/yizu.webp", 
    "黄宗羲": "res://assets/portraits/huangzongxi.webp", 
    "黄宗羲·晋地问天": "res://assets/portraits/huangzongxi.webp", 
    "黄宗羲·待访录": "res://assets/portraits/huangzongxi_middle.webp", 
    "沈百户": "res://assets/portraits/jinyiwei.webp", 
    "诏狱锦衣卫": "res://assets/portraits/jinyiwei.webp", 
    "锦衣卫缇骑": "res://assets/portraits/jinyiwei.webp", 
    "锦衣卫百户": "res://assets/portraits/jinyiwei.webp", 
    "诏狱狱卒": "res://assets/portraits/zhaoyu_yuzu.webp", 
    "诏狱老御史": "res://assets/portraits/zhaoyu_yushi.webp", 
    "县丞": "res://assets/portraits/dianli.webp", 
    "衙署书吏": "res://assets/portraits/libushuli.webp", 
    "里甲": "res://assets/portraits/cunlao.webp", 
    "账房先生": "res://assets/portraits/dianli.webp", 
    "江南老账房": "res://assets/portraits/laozhanfang.webp", 
    "伙计": "res://assets/portraits/shouyiren.webp", 
    "船老大": "res://assets/portraits/hegong.webp"
}


const PLAYER_RANK_PORTRAIT_MAP: = {
    "七品": "res://assets/portraits/hanmen_rank7.webp", 
    "六品": "res://assets/portraits/hanmen_rank6.webp", 
    "五品": "res://assets/portraits/hanmen_rank5.webp", 
    "四品": "res://assets/portraits/hanmen_rank4.webp", 
    "三品": "res://assets/portraits/hanmen_rank3.webp", 
    "二品": "res://assets/portraits/hanmen_rank2.webp", 
    "一品": "res://assets/portraits/hanmen_rank2.webp"
}

const CHARACTER_FIXED_RANK_PORTRAIT: = {
    "shijia": "res://assets/portraits/junguan.webp"
}
const MONTH_CARD_ILLUSTRATION_PATHS: = {
    "field": "res://assets/ui/month_card_illustrations/field_田野.webp", 
    "home": "res://assets/ui/month_card_illustrations/home_自宅.webp", 
    "important": "res://assets/ui/month_card_illustrations/important_重要.webp", 
    "governance": "res://assets/ui/month_card_illustrations/governance_政务.webp", 
    "trade": "res://assets/ui/month_card_illustrations/market_商贸.webp", 
    "military": "res://assets/ui/month_card_illustrations/military_兵事.webp", 
    "street": "res://assets/ui/month_card_illustrations/street_街巷.webp", 
    "rumor": "res://assets/ui/month_card_illustrations/rumor_传闻.webp", 
    "yamen": "res://assets/ui/month_card_illustrations/yamen_衙门.webp"
}
const YAMEN_OFFICE_BG_PATH: = "res://assets/portraits/yamen_office_bg.webp"
var DIANSHI_SYMBOL_FONT: Font = FontLoader.title()
var MOBILE_EVENT_TITLE_BOLD_FONT: Font = FontLoader.serif_bold()
var _choice_in_progress: = false

var _defer_choice_result_panel_refresh: = false
var _choice_result_panel_refresh_pending: = false


const CHOICE_INPUT_LOCK_MS: = 320
var _choice_input_lock_until_ms: int = 0
var _dice_overlay_rolled: = false

var _dice_overlay_resolved: = false

var _dice_overlay_committed: = false
var _dice_pending_success: = false
var _dice_pending_failed_keys: Array = []
var _dice_overlay_controller
const DIANSHI_STRATEGY_MODAL_DESKTOP_WIDTH: = 880.0
const DIANSHI_STRATEGY_MODAL_DESKTOP_HEIGHT_RATIO: = 0.78
const DIANSHI_STRATEGY_MODAL_MOBILE_HEIGHT_RATIO: = 0.72
const DIANSHI_STRATEGY_MODAL_MOBILE_SCROLL_PADDING: = 24.0

const DIANSHI_DICE_MODAL_LANDSCAPE_HEIGHT_RATIO: = 0.78
const MOBILE_HELP_PANEL_WIDTH_RATIO: = 0.72
const MOBILE_HELP_PANEL_MIN_WIDTH: = 680.0
const MOBILE_HELP_PANEL_MAX_WIDTH: = 900.0
const MOBILE_HELP_TITLE_FONT_SIZE: = 38
const MOBILE_HELP_BODY_FONT_SIZE: = 32
const MOBILE_HELP_PANEL_PADDING: = 40
const MOBILE_HELP_PANEL_MIN_HEIGHT: = 300.0
const MOBILE_GAME_MODAL_WIDTH_RATIO: = 0.94
const MOBILE_GAME_MODAL_MIN_WIDTH: = 720.0
const MOBILE_GAME_MODAL_MAX_WIDTH: = 1024.0
const MOBILE_GAME_MODAL_PADDING: = 52
const MOBILE_GAME_MODAL_TITLE_FONT_SIZE: = 55
const MOBILE_GAME_MODAL_BODY_FONT_SIZE: = 38
const MOBILE_GAME_MODAL_ACTION_FONT_SIZE: = 41
const MOBILE_GAME_MODAL_ACTION_WIDTH: = 300.0
const MOBILE_GAME_MODAL_ACTION_HEIGHT: = 84.0
const MOBILE_DICE_CARD_SIZE: = 128.0
const MOBILE_DICE_DECK_CONTAINER_SIZE: = 154.0
const MOBILE_DICE_SYMBOL_FONT_SIZE: = 82
const MOBILE_GOVERNANCE_MERIT_FONT_SIZE: = 48
const MOBILE_GOVERNANCE_MERIT_SUB_FONT_SIZE: = 38
const MOBILE_MONTH_CARD_TAG_FONT_SIZE: = 19
const MOBILE_MONTH_CARD_TITLE_FONT_SIZE: = 24
const MOBILE_MONTH_CARD_SUMMARY_FONT_SIZE: = 20
const MOBILE_MONTH_CARD_NOTE_FONT_SIZE: = 18
const MOBILE_MONTH_CARD_STATUS_FONT_SIZE: = 28
const MOBILE_MONTH_CARD_HEIGHT_RATIO: = 2.3
const MOBILE_MONTH_CARD_WIDTH_FILL_BONUS: = 1.18
const MOBILE_MONTH_CARD_MIN_WIDTH: = 118.0
const MOBILE_MONTH_CARD_MAX_WIDTH: = 236.0
const MOBILE_MONTH_CARD_MIN_HEIGHT: = 252.0
const MOBILE_MONTH_CARD_MAX_HEIGHT: = 505.0
const MOBILE_ACTION_POINTS_FONT_SIZE: = 36
const MOBILE_ACTION_POINTS_DOT_FONT_SIZE: = 38
const MOBILE_ACTION_POINTS_WIDTH: = 520.0
const DESKTOP_ACTION_POINTS_WIDTH: = 304.0
const MOBILE_RESOURCE_TOOLTIP_WIDTH_RATIO: = 0.88
const MOBILE_RESOURCE_TOOLTIP_MIN_WIDTH: = 640.0
const MOBILE_RESOURCE_TOOLTIP_MAX_WIDTH: = 820.0
const MOBILE_RESOURCE_TOOLTIP_TITLE_FONT_SIZE: = 38
const MOBILE_RESOURCE_TOOLTIP_BODY_FONT_SIZE: = 31
const MOBILE_RESOURCE_TOOLTIP_HINT_FONT_SIZE: = 29
const DESKTOP_RESOURCE_TOOLTIP_MIN_WIDTH: = 240.0
const MOBILE_TOP_BAR_HEIGHT_WITH_RESOURCES: = 142.0
const MOBILE_TOP_BAR_HEIGHT_NO_RESOURCES: = 72.0
const NATIVE_LANDSCAPE_TOP_BAR_HEIGHT: = 48.0
const NATIVE_LANDSCAPE_LEFT_CONTENT_TOP_MARGIN: = 34


const NATIVE_LANDSCAPE_LEFT_PANEL_WIDTH: = 403.0
const NATIVE_LANDSCAPE_LEFT_TABS_WIDTH: = 72.0
const NATIVE_LANDSCAPE_LEFT_CONTENT_SIDE_MARGIN: = 29
const NATIVE_LANDSCAPE_CENTER_MIN_WIDTH_FLOOR: = 760.0
const NATIVE_LANDSCAPE_CENTER_SIDE_BUFFER: = 32.0

const NATIVE_LANDSCAPE_MONTH_CARD_WIDTH: = 164.0
const NATIVE_LANDSCAPE_MONTH_CARD_HEIGHT: = 294.0
const NATIVE_LANDSCAPE_MONTH_CARD_GAP: = 9
const NATIVE_TABLET_LANDSCAPE_MONTH_CARD_WIDTH: = 174.0
const NATIVE_TABLET_LANDSCAPE_MONTH_CARD_HEIGHT: = 308.0

const BIANWU_EVENT_CARD_HEIGHT_RATIO: = 1.15


const BIANWU_DESKTOP_MONTH_CARD_SCALE: = 0.8

const BIANWU_DETAIL_PANEL_WIDTH: = 296.0
const BIANWU_DETAIL_PANEL_SCALE: = 0.8
const NATIVE_TABLET_LANDSCAPE_MONTH_CARD_MIN_WIDTH: = 150.0
const NATIVE_TABLET_LANDSCAPE_MONTH_CARD_GAP: = 12
const DESKTOP_LEFT_PANEL_WIDTH: = 240.0
const DESKTOP_LEFT_TABS_WIDTH: = 46.0
const ZHISU_ROW_CARD_SIDE_MARGIN: = 8

const MOBILE_TOP_BAR_ROW_GAP: = 14
const MOBILE_TOP_BAR_SAFE_SIDE_MARGIN: = 44
const MOBILE_TOP_STATUS_FONT_SIZE: = 34
const MOBILE_TOP_RESOURCE_FONT_SIZE: = 34
const MOBILE_TOP_SETTINGS_FONT_SIZE: = 31
const MOBILE_TOP_ACTION_BUTTON_SEPARATION: = 18
const MOBILE_BOTTOM_TAB_FONT_SIZE: = 29
const MOBILE_BOTTOM_TAB_HEIGHT: = 88.0
const MOBILE_BOTTOM_TAB_TOP_GAP: = 18.0
const MOBILE_BOTTOM_TAB_BOTTOM_GAP: = 20.0
const MOBILE_BOTTOM_TAB_ICON_SIZE: = 38
const MOBILE_BOTTOM_TAB_ICON_TEXT_GAP: = 2
const MOBILE_CONTENT_SIDE_MARGIN: = 24
const MOBILE_GOVERNANCE_SIDE_MARGIN: = 10
const MOBILE_BORDER_WIDTH: = 2
const MOBILE_SIDE_PANE_FONT_SIZE: = 34
const MOBILE_DETAIL_PANE_FONT_SIZE: = 38
const MOBILE_TOP_PERSONAL_STAT_KEYS: = ["wentao", "wulue", "lizheng", "tizhi"]
const MOBILE_CITY_RESOURCE_KEYS: = ["liangshi", "yinliang", "renkou_val", "liumin", "bingyong"]
const LOCAL_TOP_ATTITUDE_KEYS: = ["shengjuan", "zhongguan", "qingyi", "shishen", "minwang"]
const MOBILE_BOTTOM_TAB_ICON_REGIONS: = {
    "jushi": Rect2(52, 64, 160, 128), 
    "dangan": Rect2(52, 52, 152, 152), 
    "daoju": Rect2(54, 54, 148, 152), 
    "lingwu": Rect2(54, 54, 148, 152)
}
const MOBILE_CITY_RESOURCE_LABELS: = {
    "yinliang": "库银", 
    "liangshi": "官粮", 
    "bingyong": "兵勇", 
    "renkou_val": "人口", 
    "liumin": "流民"
}
const MOBILE_EVENT_STAGE_FONT_SIZE: = 29
const MOBILE_EVENT_DATE_FONT_SIZE: = 38
const MOBILE_EVENT_DATE_TITLE_GAP: = 18
const MOBILE_EVENT_TITLE_FONT_SIZE: = 67
const MOBILE_EVENT_READING_SIDE_MARGIN: = 72
const MOBILE_EVENT_IMMERSIVE_SIDE_MARGIN: = 104
const MOBILE_EVENT_IMMERSIVE_TEXT_MARGIN: = 32
const MOBILE_EVENT_IMMERSIVE_TOP_MARGIN: = 92
const MOBILE_EVENT_IMMERSIVE_TITLE_BODY_GAP: = 86
const MOBILE_EVENT_CONTINUE_GAP: = 32.0
const MOBILE_EVENT_CONTINUE_BUTTON_HEIGHT: = 44.0
const MOBILE_EVENT_SCROLLBAR_TOLERANCE: = 36.0
const MOBILE_EVENT_REOPEN_SUPPRESS_MS: = 320
const EVENT_RESULT_BUTTON_BOTTOM_GAP: = 24.0
const MOBILE_EVENT_RESULT_BUTTON_BOTTOM_GAP: = 34.0
const MOBILE_EVENT_SPEAKER_NAME_FONT_SIZE: = 41
const MOBILE_EVENT_SPEAKER_TAG_FONT_SIZE: = 31
const MOBILE_EVENT_AVATAR_FONT_SIZE: = 43
const MOBILE_EVENT_AVATAR_SIZE: = 82.0
const MOBILE_EVENT_SPEAKER_LINE_FONT_SIZE: = 41
const MOBILE_EVENT_NARRATIVE_FONT_SIZE: = 48
const MOBILE_EVENT_FLAVOR_FONT_SIZE: = 36
const MOBILE_EVENT_FOCUS_FONT_SIZE: = 40
const MOBILE_CHOICE_TITLE_FONT_SIZE: = 43
const MOBILE_CHOICE_BODY_FONT_SIZE: = 38
const MOBILE_CHOICE_HINT_FONT_SIZE: = 36
const MOBILE_CHOICE_MIN_HEIGHT: = 124.0
const MOBILE_CHOICE_SIDE_PADDING: = 30
const MOBILE_CHOICE_VERTICAL_PADDING: = 24
const MOBILE_RESULT_TITLE_FONT_SIZE: = 46
const MOBILE_RESULT_BODY_FONT_SIZE: = 40
const MOBILE_NEXT_BUTTON_FONT_SIZE: = 41
const MOBILE_NEXT_BUTTON_HEIGHT: = 82.0
const MOBILE_INFO_PANEL_HEIGHT_RATIO: = 0.44
const MOBILE_INFO_PANEL_MIN_HEIGHT: = 380.0
const MOBILE_INFO_PANEL_MAX_HEIGHT: = 560.0
const MOBILE_INFO_HOST_MIN_HEIGHT: = 860.0
const MOBILE_DANGAN_STATS_PANEL_HEIGHT: = 480.0
const MOBILE_DANGAN_RADAR_LABEL_RESERVE: = 112.0
const MOBILE_DANGAN_RADAR_SCALE: = 0.78
const MOBILE_DANGAN_RADAR_ICON_SIZE: = 28.0
const MOBILE_DANGAN_CARD_SIDE_PADDING: = 28.0
const MOBILE_DANGAN_CARD_VERTICAL_PADDING: = 22.0


@onready var zhisu_tab: Button = $MainVBox / Layout / LeftPanel / LeftShell / LeftTabsHost / LeftTabs / ZhisuTab
@onready var buqu_tab: Button = $MainVBox / Layout / LeftPanel / LeftShell / LeftTabsHost / LeftTabs / BuquTab
@onready var zengyi_tab: Button = $MainVBox / Layout / LeftPanel / LeftShell / LeftTabsHost / LeftTabs / ZengyiTab
@onready var jushi_tab: Button = $MainVBox / Layout / LeftPanel / LeftShell / LeftTabsHost / LeftTabs / JushiTab
@onready var dangan_tab: Button = $MainVBox / Layout / LeftPanel / LeftShell / LeftTabsHost / LeftTabs / DanganTab
@onready var daoju_tab: Button = $MainVBox / Layout / LeftPanel / LeftShell / LeftTabsHost / LeftTabs / DaojuTab
@onready var lingwu_tab: Button = $MainVBox / Layout / LeftPanel / LeftShell / LeftTabsHost / LeftTabs / LingwuTab
@onready var shezhi_tab: Button = $MainVBox / Layout / LeftPanel / LeftShell / LeftTabsHost / LeftTabs / SheZhiTab
@onready var shezhi_spacer: Control = $MainVBox / Layout / LeftPanel / LeftShell / LeftTabsHost / LeftTabs / SheZhiSpacer
@onready var left_tabs: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftTabsHost / LeftTabs
@onready var left_tabs_host: PanelContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftTabsHost
@onready var zhisu_pane: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / ZhisuPane
@onready var zhisu_scroll: ScrollContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / ZhisuPane / ZhisuScroll
@onready var zhisu_vbox: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / ZhisuPane / ZhisuScroll / ZhisuVBox
@onready var zhisu_info_container: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / ZhisuPane / ZhisuScroll / ZhisuVBox / ZhisuSection / ZhisuPanel / ZhisuInfo
@onready var zhisu_title: Label = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / ZhisuPane / ZhisuScroll / ZhisuVBox / ZhisuSection / ZhisuTitle
@onready var buqu_pane: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / BuquPane
@onready var buqu_info_container: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / BuquPane / BuquScroll / BuquVBox / BuquSection / BuquPanel / BuquInfo
@onready var zengyi_pane: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / ZengyiPane
@onready var zengyi_scroll: ScrollContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / ZengyiPane / ZengyiScroll
@onready var zengyi_vbox: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / ZengyiPane / ZengyiScroll / ZengyiVBox
@onready var zengyi_info_container: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / ZengyiPane / ZengyiScroll / ZengyiVBox / ZengyiSection / ZengyiPanel / ZengyiInfo
@onready var jushi_pane: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / JushiPane
@onready var jushi_scroll: ScrollContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / JushiPane / JushiScroll
@onready var jushi_vbox: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / JushiPane / JushiScroll / JushiVBox
@onready var dangan_pane: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / DanganPane
@onready var dangan_scroll: ScrollContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / DanganPane / DanganScroll
@onready var dangan_vbox: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / DanganPane / DanganScroll / DanganVBox
@onready var daoju_pane: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / DaojuPane
@onready var lingwu_pane: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / LingwuPane
@onready var lingwu_scroll: ScrollContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / LingwuPane / LingwuSection / LingwuPanel / LingwuScroll
@onready var lingwu_info_container: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / LingwuPane / LingwuSection / LingwuPanel / LingwuScroll / LingwuInfo
@onready var lingwu_title: Label = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / LingwuPane / LingwuSection / LingwuTitle
@onready var shezhi_pane: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / SheZhiPane
@onready var shezhi_panel: PanelContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / SheZhiPane / SheZhiSection / SheZhiPanel
@onready var shezhi_scroll: ScrollContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / SheZhiPane / SheZhiSection / SheZhiPanel / SheZhiScroll
@onready var shezhi_info_container: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / SheZhiPane / SheZhiSection / SheZhiPanel / SheZhiScroll / SheZhiInfo
@onready var shezhi_title: Label = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / SheZhiPane / SheZhiSection / SheZhiTitle
@onready var stats_section: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / JushiPane / JushiScroll / JushiVBox / StatsSection
@onready var attitudes_section: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / JushiPane / JushiScroll / JushiVBox / AttitudesSection
@onready var stats_title: Label = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / JushiPane / JushiScroll / JushiVBox / StatsSection / StatsTitle
@onready var attitudes_title: Label = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / JushiPane / JushiScroll / JushiVBox / AttitudesSection / AttitudesTitle
@onready var stats_container: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / JushiPane / JushiScroll / JushiVBox / StatsSection / StatsPanel / StatsVBox
@onready var attitudes_container: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / JushiPane / JushiScroll / JushiVBox / AttitudesSection / AttitudesPanel / AttitudesVBox
@onready var tags_content_margin: MarginContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / DanganPane / DanganScroll / DanganVBox / TagsSection / TagsPanel / TagsContentMargin
@onready var tags_container: HFlowContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / DanganPane / DanganScroll / DanganVBox / TagsSection / TagsPanel / TagsContentMargin / TagsFlow
@onready var archive_section: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / DanganPane / DanganScroll / DanganVBox / ArchiveSection
@onready var archive_title: Label = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / DanganPane / DanganScroll / DanganVBox / ArchiveSection / ArchiveTitle
@onready var archive_content_margin: MarginContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / DanganPane / DanganScroll / DanganVBox / ArchiveSection / ArchivePanel / ArchiveContentMargin
@onready var archive_info_container: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / DanganPane / DanganScroll / DanganVBox / ArchiveSection / ArchivePanel / ArchiveContentMargin / ArchiveInfo
@onready var items_scroll: ScrollContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / DaojuPane / ItemsSection / ItemsPanel / ItemsScroll
@onready var items_info_container: VBoxContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / DaojuPane / ItemsSection / ItemsPanel / ItemsScroll / ItemsInfo
@onready var desktop_pane_stack: Control = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack
@onready var left_content_margin: MarginContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent
@onready var mobile_info_panel: PanelContainer = $MainVBox / MobileInfoPanel
@onready var mobile_info_margin: MarginContainer = $MainVBox / MobileInfoPanel / MobileInfoMargin
@onready var mobile_info_scroll: ScrollContainer = $MainVBox / MobileInfoPanel / MobileInfoMargin / MobileInfoScroll
@onready var mobile_info_host: Control = $MainVBox / MobileInfoPanel / MobileInfoMargin / MobileInfoScroll / MobileInfoHost
@onready var mobile_bottom_tabs: HBoxContainer = $MainVBox / MobileBottomTabs
@onready var mobile_jushi_tab: Button = $MainVBox / MobileBottomTabs / MobileJushiTab
@onready var mobile_dangan_tab: Button = $MainVBox / MobileBottomTabs / MobileDanganTab
@onready var mobile_daoju_tab: Button = $MainVBox / MobileBottomTabs / MobileDaojuTab
@onready var mobile_lingwu_tab: Button = $MainVBox / MobileBottomTabs / MobileLingwuTab


@onready var top_bar: PanelContainer = $MainVBox / TopBar
@onready var top_bar_underline: ColorRect = $MainVBox / TopBarUnderline
@onready var main_layout: HBoxContainer = $MainVBox / Layout
@onready var left_panel: PanelContainer = $MainVBox / Layout / LeftPanel
@onready var center_panel: PanelContainer = $MainVBox / Layout / CenterPanel
@onready var zhisu_panel: PanelContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / ZhisuPane / ZhisuScroll / ZhisuVBox / ZhisuSection / ZhisuPanel
@onready var zengyi_panel: PanelContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / ZengyiPane / ZengyiScroll / ZengyiVBox / ZengyiSection / ZengyiPanel
@onready var zengyi_title: Label = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / ZengyiPane / ZengyiScroll / ZengyiVBox / ZengyiSection / ZengyiTitle
@onready var stats_panel: PanelContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / JushiPane / JushiScroll / JushiVBox / StatsSection / StatsPanel
@onready var attitudes_panel: PanelContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / JushiPane / JushiScroll / JushiVBox / AttitudesSection / AttitudesPanel
@onready var tags_panel: PanelContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / DanganPane / DanganScroll / DanganVBox / TagsSection / TagsPanel
@onready var archive_panel: PanelContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / DanganPane / DanganScroll / DanganVBox / ArchiveSection / ArchivePanel
@onready var items_panel: PanelContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / DaojuPane / ItemsSection / ItemsPanel
@onready var items_title: Label = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / DaojuPane / ItemsSection / ItemsTitle
@onready var lingwu_panel: PanelContainer = $MainVBox / Layout / LeftPanel / LeftShell / LeftContent / PaneStack / LingwuPane / LingwuSection / LingwuPanel


var items_expand_btn: Button = null
var items_overlay_layer: CanvasLayer = null
var items_overlay_content: VBoxContainer = null
var items_overlay_grid: VBoxContainer = null
var items_overlay_tabs: HBoxContainer = null
var items_overlay_category: String = "all"
var items_overlay_selection_callback: Callable = Callable()
var items_overlay_selection_type: String = ""

var items_overlay_selected_id: String = ""

var items_overlay_preselect_id: String = ""
var items_overlay_replace_btn: Button = null

var items_overlay_view_id: String = ""

var items_overlay_detail: VBoxContainer = null
var zengyi_active_boost_tab: String = "governance"
var lingwu_popup_layer: CanvasLayer = null
var _personal_stat_capstone_notice_layer: CanvasLayer = null
var _personal_stat_capstone_notice_queue: Array = []
var bw_micro_popup_layer: CanvasLayer = null



var bw_current_location: String = ""

var _bw_force_deal_animation: = false

var bw_story_banner: Control = null

var _bw_merit_group: HBoxContainer = null
var _bw_merit_label: Label = null

var _bw_sidebar_collapse_btn: Button = null
var _bw_sidebar_btn_overlay: Control = null
var _bw_sidebar_collapsed: bool = false
var _bw_sidebar_tween: Tween = null
var _bw_sidebar_expanded_min_w: float = 0.0
var _bw_sidebar_pane_frozen_w: float = 0.0

var _bianwu_ap_floating: bool = false
var _bw_ap_float_overlay: Control = null

var _bw_juntian_diamond: Control = null

const BW_LOCATIONS: = [
    {"id": "juntian", "title": "军田", "desc": "屯垦军田、清查粮饷军需诸务。", "tags": ["军务", "军需"]}, 
    {"id": "junying", "title": "军营", "desc": "募兵操练、拣选健勇、收编溃卒。", "tags": ["募兵"]}, 
    {"id": "duntai", "title": "墩台", "desc": "哨探塘报、边地消息传闻。", "tags": ["斥候", "传闻"]}, 
    {"id": "chengnei", "title": "城内", "desc": "结纳应酬、边市往来。", "tags": ["应酬", "边市"]}, 
    {"id": "chengjiao", "title": "城郊", "desc": "巡视郊野屯堡、安辑流民、乡勇团练。", "tags": ["郊野", "乡勇"]}, 
]

const BW_TOP_LOCATION_IDS: = ["juntian"]

const BW_BANNER_CARD_TYPES: = ["story", "attitude", "grain_shortage", "riot", "mutiny"]
var _lingwu_selected_stat_key: String = ""
var _lingwu_stat_multiplier: int = 1
var _lingwu_stat_multipliers: Dictionary = {}
var _lingwu_stat_rows_holder: VBoxContainer = null
var _lingwu_stat_confirm_holder: Control = null
var _lingwu_stat_total_label: Label = null
var _lingwu_stat_radar: Control = null
var _lingwu_stat_value_labels: Dictionary = {}
var _lingwu_stat_scroll: ScrollContainer = null
var _lingwu_stat_popup_last_press_frame: int = -1
var _lingwu_reward_button: Button = null
var _lingwu_reward_status_label: Label = null
var _lingwu_reward_request_pending: = false

var _app_backgrounded: = false
var _pending_lingwu_reward_toast: = 0
var _lingwu_item_draw_in_progress: = false
var _lingwu_item_draw_token: = 0
var _rank_tree_last_press_frame: int = -1
var _items_overlay_controller
@onready var governance_scroll: ScrollContainer = $MainVBox / Layout / CenterPanel / CenterMargin / GovernanceScroll
@onready var governance_vbox: VBoxContainer = $MainVBox / Layout / CenterPanel / CenterMargin / GovernanceScroll / GovernanceVBox
@onready var governance_stage_label: Label = $MainVBox / Layout / CenterPanel / CenterMargin / GovernanceScroll / GovernanceVBox / GovernanceStage
@onready var governance_turn_label: Label = $MainVBox / Layout / CenterPanel / CenterMargin / GovernanceScroll / GovernanceVBox / GovernanceTurn
@onready var action_points_row: HBoxContainer = $MainVBox / Layout / CenterPanel / CenterMargin / GovernanceScroll / GovernanceVBox / ActionPointsRow
@onready var action_points_value: Label = $MainVBox / Layout / CenterPanel / CenterMargin / GovernanceScroll / GovernanceVBox / ActionPointsRow / ActionPointsValue
@onready var month_cards_container: HFlowContainer = $MainVBox / Layout / CenterPanel / CenterMargin / GovernanceScroll / GovernanceVBox / MonthCardsContainer
@onready var event_scroll: ScrollContainer = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter
@onready var event_vbox: VBoxContainer = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox
@onready var stage_label: Label = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / TitleGroup / StageLabel
@onready var event_date_label: Label = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / TitleGroup / EventDateLabel
@onready var event_title_label: Label = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / TitleGroup / EventTitle
var visitor_bio_btn: Button
var current_bio_text: String = ""
var mobile_jushi_stats_row: HBoxContainer
@onready var title_rule: HSeparator = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / TitleRule
@onready var speaker_bubble: PanelContainer = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / SpeakerBox / SpeakerBubble
@onready var speaker_avatar: Label = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / SpeakerBox / SpeakerHeader / SpeakerAvatar
@onready var speaker_name: Label = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / SpeakerBox / SpeakerHeader / SpeakerMeta / SpeakerName
@onready var speaker_role: Label = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / SpeakerBox / SpeakerHeader / SpeakerMeta / SpeakerTags / SpeakerRole
@onready var speaker_faction: Label = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / SpeakerBox / SpeakerHeader / SpeakerMeta / SpeakerTags / SpeakerFaction
@onready var speaker_line: Label = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / SpeakerBox / SpeakerBubble / SpeakerLine
@onready var narrative_label: Label = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / NarrativeLabel
@onready var flavor_panel: PanelContainer = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / FlavorPanel
@onready var flavor_label: Label = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / FlavorPanel / FlavorLabel
@onready var focus_panel: PanelContainer = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / FocusPanel
@onready var focus_label: Label = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / FocusPanel / FocusLabel
@onready var choices_container: VBoxContainer = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / ChoicesVBox
@onready var result_panel: PanelContainer = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / ResultPanel
@onready var result_title: Label = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / ResultPanel / ResultVBox / ResultTitle
@onready var chosen_choice_box: PanelContainer = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / ResultPanel / ResultVBox / ChosenChoiceBox
@onready var chosen_choice_title: Label = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / ResultPanel / ResultVBox / ChosenChoiceBox / ChosenChoiceVBox / ChosenChoiceTitle
@onready var chosen_choice_desc: Label = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / ResultPanel / ResultVBox / ChosenChoiceBox / ChosenChoiceVBox / ChosenChoiceDesc
@onready var result_comment: Label = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / ResultPanel / ResultVBox / ResultComment
@onready var result_changes_container: FlowContainer = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / ResultPanel / ResultVBox / ResultChanges
@onready var result_items_container: VBoxContainer = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / ResultPanel / ResultVBox / ResultItems
@onready var result_tags_container: FlowContainer = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / ResultPanel / ResultVBox / ResultTags
@onready var next_button: Button = $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter / EventVBox / ResultPanel / ResultVBox / NextButton


@onready var top_location: HBoxContainer = $MainVBox / TopBar / MarginContainer / HBox / TopLocation
@onready var location_label: Label = $MainVBox / TopBar / MarginContainer / HBox / TopLocation / LocationLabel
@onready var topbar_rank: Button = $MainVBox / TopBar / MarginContainer / HBox / TopRank
@onready var topbar_turn: Label = $MainVBox / TopBar / MarginContainer / TopTurn
@onready var resource_bar: HBoxContainer = $MainVBox / TopBar / MarginContainer / HBox / ResourceBar
@onready var save_btn: Button = $MainVBox / TopBar / MarginContainer / HBox / Actions / SaveButton
@onready var load_btn: Button = $MainVBox / TopBar / MarginContainer / HBox / Actions / LoadButton
@onready var settings_btn: Button = $MainVBox / TopBar / MarginContainer / HBox / Actions / SettingsButton

@onready var settings_popup: PanelContainer = $SettingsPopup
@onready var restart_btn: Button = $SettingsPopup / VBox / RestartButton
@onready var fullscreen_btn: Button = $SettingsPopup / VBox / FullscreenButton
@onready var close_settings_btn: Button = $SettingsPopup / VBox / CloseSettingsButton
var landscape_size_btn: Button
var portrait_toggle_btn: Button
var about_author_btn: Button
var theme_btn: Button
var music_text_row: Button
var ui_scale_text_row: Button

@onready var silver_label: Label = $MainVBox / TopBar / MarginContainer / HBox / ResourceBar / SilverLabel
@onready var grain_label: Label = $MainVBox / TopBar / MarginContainer / HBox / ResourceBar / GrainLabel
@onready var bingyong_label: Label = $MainVBox / TopBar / MarginContainer / HBox / ResourceBar / BingyongLabel
@onready var pop_label: Label = $MainVBox / TopBar / MarginContainer / HBox / ResourceBar / PopLabel
@onready var refugee_label: Label = $MainVBox / TopBar / MarginContainer / HBox / ResourceBar / RefugeeLabel


var _prev_resources_cache: Dictionary = {}
var _prev_city_stats_cache: Dictionary = {}
var _prev_governance_merit_cache: Dictionary = {}
var _prev_attitudes_cache: Dictionary = {}
var _prev_personal_stats_cache: Dictionary = {}

func _result_card_border_color() -> Color:
    if GameState.theme == "light" and not _is_mobile_portrait():
        return Color(1, 1, 1, 0.3)
    return Color(GameState.get_theme_color("border"), 0.24 if GameState.theme == "dark" else 0.22)

var current_left_tab: String = "zhisu"

var _shezhi_gear: Control
var _shezhi_save_btn: Button
var _shezhi_load_btn: Button
var _shezhi_music_text_row: Button
var _shezhi_ui_scale_text_row: Button
var _shezhi_portrait_btn: Button
var _shezhi_fullscreen_btn: Button
var _shezhi_about_btn: Button
var _shezhi_restart_btn: Button
var _shezhi_exit_btn: Button
var governance_active_card_index: int = -1
var pending_governance_completion_card_index: int = -1
var pending_result_progress_committed: = false
var pending_month_card_settle_index: = -1
var pending_month_advance_after_settle: = false
var selected_mobile_month_card_index: = -1
var mobile_month_card_preview_panel: PanelContainer = null
var mobile_month_execute_spacer: Control = null
var mobile_month_execute_button: Button = null
var desktop_action_points_left_spacer: Control = null
var action_points_content_box: HBoxContainer = null
var action_points_turn_label: Label = null
var action_points_attr_label: RichTextLabel = null
var action_points_text_label: Label = null
var action_points_dots_label: Label
var action_points_separator: ColorRect
var action_points_portrait_frame: Panel = null
var action_points_portrait_bg: ColorRect = null
var action_points_portrait_tex: TextureRect = null
var action_points_info_box: VBoxContainer = null
var action_points_dots_row: HBoxContainer = null
var action_points_dots_spacer: Control = null
var action_points_divider: TextureRect = null
var _action_points_portrait_path: String = ""
var _action_points_portrait_active: bool = false
var _ap_left_pad: float = 0.0
var _ap_right_pad: float = 0.0
var _ap_portrait_overlay: Control = null
var _ap_portrait_size: float = 82.0
var _ap_hex_right: float = 41.0
var _overlay_overview_button: Control = null
var fullscreen_was_active: bool = false
var fullscreen_sync_elapsed: float = 0.0
var responsive_sync_elapsed: float = 0.0
var last_responsive_window_size: = Vector2.ZERO
var responsive_layout_pending: bool = false
var last_mobile_portrait_layout: bool = false
var had_responsive_layout_pass: bool = false
var mobile_pixel_snap_queued: bool = false
var city_panel_grain_texture: ImageTexture

var month_warning_box: HFlowContainer = null
var month_warning_container: HBoxContainer = null
var month_warning_toggle_btn: Button = null
var month_warning_wrapper: MarginContainer = null
var month_warning_badge: Label = null
var month_warning_collapsed: bool = false


var _month_warning_anim_key: String = ""
var _dianshi
var _tooltips
var _hover_tooltip_active: = false
var _ming_map_controller
var _help_overlay_controller
var _transition_toast_controller
var _settings_popup_controller
var _event_portrait_controller
var _mobile_reading_controller
var _month_warning_controller
var _month_card_display
var _responsive_layout_controller
var _side_panel_layout_controller
var _mobile_bottom_tab_controller
var _city_stats_display_controller
var _overview_panel_controller
var _bianwu_deployment_slot_controller
var ming_map_current_marker_texture: Texture2D
var ming_map_zoom: = 1.0
var ming_map_mode: = "rendi"
var ming_map_dragging: = false
var ming_map_drag_last_pos: = Vector2.ZERO
@onready var game_background: TextureRect = $Background
@onready var game_overlay: TextureRect = $Overlay
@onready var mobile_governance_background_mask: ColorRect = $MobileGovernanceBackgroundMask
@onready var mobile_event_reading_mask: ColorRect = $MobileEventReadingMask
@onready var ming_map_overlay: Control = $MingMapOverlay
@onready var ming_map_dimmer: ColorRect = $MingMapOverlay / MingMapDimmer
@onready var ming_map_panel: PanelContainer = $MingMapOverlay / MingMapPanel
@onready var ming_map_frame: PanelContainer = $MingMapOverlay / MingMapPanel / MingMapMargin / MingMapVBox / MingMapFrame
@onready var ming_map_base: TextureRect = $MingMapOverlay / MingMapPanel / MingMapMargin / MingMapVBox / MingMapFrame / MingMapCanvas / MingMapViewport / MingMapZoomRoot / MingMapAspectRatio / MingMapBase
@onready var ming_map_canvas: Control = $MingMapOverlay / MingMapPanel / MingMapMargin / MingMapVBox / MingMapFrame / MingMapCanvas
@onready var ming_map_viewport: Control = $MingMapOverlay / MingMapPanel / MingMapMargin / MingMapVBox / MingMapFrame / MingMapCanvas / MingMapViewport
@onready var ming_map_zoom_root: Control = $MingMapOverlay / MingMapPanel / MingMapMargin / MingMapVBox / MingMapFrame / MingMapCanvas / MingMapViewport / MingMapZoomRoot
@onready var ming_map_province_layer: Control = $MingMapOverlay / MingMapPanel / MingMapMargin / MingMapVBox / MingMapFrame / MingMapCanvas / MingMapViewport / MingMapZoomRoot / MingMapAspectRatio / MingMapProvinceLayer
@onready var ming_map_marker_layer: Control = $MingMapOverlay / MingMapPanel / MingMapMargin / MingMapVBox / MingMapFrame / MingMapCanvas / MingMapViewport / MingMapZoomRoot / MingMapAspectRatio / MingMapMarkerLayer

@onready var ming_map_close_button: Button = $MingMapOverlay / MingMapPanel / MingMapMargin / MingMapVBox / MingMapHeader / MingMapCloseButton
@onready var ming_map_reset_zoom_button: Button = $MingMapOverlay / MingMapPanel / MingMapMargin / MingMapVBox / MingMapHeader / MingMapResetZoomButton
@onready var top_location_button: Button = $MainVBox / TopBar / MarginContainer / HBox / TopLocation / TopLocationButton
@onready var ming_map_mode_tabs: HBoxContainer = $MingMapOverlay / MingMapPanel / MingMapMargin / MingMapVBox / MingMapHeader / MingMapModeTabs
@onready var ming_map_mode_rendi_button: Button = $MingMapOverlay / MingMapPanel / MingMapMargin / MingMapVBox / MingMapHeader / MingMapModeTabs / MingMapModeRenDiButton
@onready var ming_map_mode_minsheng_button: Button = $MingMapOverlay / MingMapPanel / MingMapMargin / MingMapVBox / MingMapHeader / MingMapModeTabs / MingMapModeMinShengButton
@onready var ming_map_mode_junwu_button: Button = $MingMapOverlay / MingMapPanel / MingMapMargin / MingMapVBox / MingMapHeader / MingMapModeTabs / MingMapModeJunWuButton
@onready var ming_map_detail_label: RichTextLabel = $MingMapOverlay / MingMapPanel / MingMapMargin / MingMapVBox / MingMapDetailLabel

var event_scroll_touch_drag_suppress_until_ms: int = 0
var governance_scroll_touch_drag_suppress_until_ms: int = 0
var bianwu_defense_scroll_suppress_until_ms: int = 0
var items_scroll_touch_drag_suppress_until_ms: int = 0
var mobile_info_scroll_touch_drag_suppress_until_ms: int = 0
var mobile_event_reading_continue_suppress_until_ms: int = 0


const MOBILE_READING_TAP_MOVE_THRESHOLD: = 12.0
var _mobile_reading_press_active: bool = false
var _mobile_reading_press_moved: bool = false
var _mobile_reading_press_position: Vector2 = Vector2.ZERO
var _mobile_reading_press_in_narrative_area: bool = false
var mobile_detail_bg_rect: TextureRect = null
var mobile_event_phase: = "reading"

var _showing_dianshi_memory_result: = false
var _dianshi_memory_turn_label: = ""
var mobile_reading_card: PanelContainer = null
var mobile_reading_card_vbox: VBoxContainer = null
var mobile_narrative_scroll: ScrollContainer = null
var mobile_narrative_text_margin: MarginContainer = null
var mobile_reading_button_spacer: Control = null
var mobile_continue_button: Button = null

var _mobile_reading_layout_resync_queued: bool = false
var mobile_choice_narrative_label: Label = null
var mobile_choice_narrative_container: MarginContainer = null


func _is_primary_press_event(event: InputEvent) -> bool:
    if event is InputEventScreenTouch:
        return event.pressed
    if event is InputEventMouseButton:
        return event.button_index == MOUSE_BUTTON_LEFT and event.pressed
    return false

func _get_primary_press_position(event: InputEvent):
    if event is InputEventScreenTouch and event.pressed:
        return event.position
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        return event.global_position
    return null


func _apply_serif_fonts_to_all_labels_and_buttons() -> void :
    var font_body = FontLoader.body()
    var font_serif_bold = FontLoader.serif_bold()

    var labels_to_serif = [
        narrative_label, 
        speaker_line, 
        result_comment, 
        chosen_choice_title, 
        chosen_choice_desc, 
        flavor_label, 
        focus_label, 
        event_date_label, 
        stage_label, 
        speaker_name, 
        result_title, 
        governance_stage_label, 
        governance_turn_label, 
        action_points_value, 
        topbar_turn, 
        silver_label, 
        grain_label, 
        bingyong_label, 
        pop_label, 
        refugee_label
    ]
    for label in labels_to_serif:
        if is_instance_valid(label):
            label.add_theme_font_override("font", font_body)

    if is_instance_valid(result_title):
        result_title.add_theme_font_override("font", font_serif_bold)

    var buttons_to_serif = [
        next_button, 
        topbar_rank, 
        settings_btn, 
        save_btn, 
        load_btn, 
        restart_btn, 
        fullscreen_btn, 
        close_settings_btn, 
        ming_map_close_button, 
        ming_map_reset_zoom_button, 
        top_location_button, 
        ming_map_mode_rendi_button, 
        ming_map_mode_minsheng_button, 
        ming_map_mode_junwu_button, 
        zhisu_tab, 
        buqu_tab, 
        zengyi_tab, 
        jushi_tab, 
        dangan_tab, 
        daoju_tab, 
        lingwu_tab, 
        mobile_jushi_tab, 
        mobile_dangan_tab, 
        mobile_daoju_tab, 
        mobile_lingwu_tab
    ]
    for btn in buttons_to_serif:
        if is_instance_valid(btn):
            btn.add_theme_font_override("font", font_body)


func _ready() -> void :
    _dianshi = DianshiController.new(self)
    _dice_overlay_controller = DiceOverlayController.new(self)
    _items_overlay_controller = ItemsOverlayController.new(self)
    _ming_map_controller = MingMapController.new(self)
    _help_overlay_controller = HelpOverlayController.new(self)
    _transition_toast_controller = TransitionToastController.new(self)
    if has_node("/root/AndroidRewardAdService"):
        AndroidRewardAdService.reward_granted.connect(_on_android_reward_granted)
        AndroidRewardAdService.reward_failed.connect(_on_android_reward_failed)
        AndroidRewardAdService.reward_unavailable.connect(_on_android_reward_unavailable)
    _settings_popup_controller = SettingsPopupController.new(self)
    _event_portrait_controller = EventPortraitController.new(self)
    _mobile_reading_controller = MobileReadingController.new(self)
    _month_warning_controller = MonthWarningController.new(self)
    _month_card_display = GovernanceMonthCardDisplay.new(self)
    _responsive_layout_controller = ResponsiveLayoutController.new(self)
    _side_panel_layout_controller = SidePanelLayoutController.new(self)
    _mobile_bottom_tab_controller = MobileBottomTabController.new(self)
    _city_stats_display_controller = CityStatsDisplayController.new(self)
    _overview_panel_controller = OverviewPanelController.new(self)
    _bianwu_deployment_slot_controller = BianwuDeploymentSlotControllerRef.new(self)
    _tooltips = ResourceTooltipController.new(self)
    _apply_serif_fonts_to_all_labels_and_buttons()
    ming_map_overlay.visible = false
    var grad = Gradient.new()
    var tex = GradientTexture2D.new()
    tex.gradient = grad
    tex.fill_from = Vector2(0.5, 0.0)
    tex.fill_to = Vector2(0.5, 1.0)
    game_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    game_overlay.offset_left = 0
    game_overlay.offset_top = 0
    game_overlay.offset_right = 0
    game_overlay.offset_bottom = 0
    game_overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    game_overlay.stretch_mode = TextureRect.STRETCH_SCALE
    game_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    game_overlay.texture = tex
    mobile_governance_background_mask.set_anchors_preset(Control.PRESET_FULL_RECT)
    mobile_governance_background_mask.offset_left = 0
    mobile_governance_background_mask.offset_top = 0
    mobile_governance_background_mask.offset_right = 0
    mobile_governance_background_mask.offset_bottom = 0
    mobile_governance_background_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
    mobile_governance_background_mask.color = Color(0.0, 0.0, 0.0, 0.5)
    mobile_governance_background_mask.visible = false
    mobile_event_reading_mask.set_anchors_preset(Control.PRESET_FULL_RECT)
    mobile_event_reading_mask.offset_left = 0
    mobile_event_reading_mask.offset_top = 0
    mobile_event_reading_mask.offset_right = 0
    mobile_event_reading_mask.offset_bottom = 0
    mobile_event_reading_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
    mobile_event_reading_mask.color = MOBILE_EVENT_READING_MASK_COLOR
    mobile_event_reading_mask.visible = false
    _apply_game_background_mask()
    game_overlay.modulate.a = _governance_overlay_alpha()

    grain_label.mouse_filter = Control.MOUSE_FILTER_PASS
    grain_label.gui_input.connect(_on_grain_label_gui_input)

    silver_label.mouse_filter = Control.MOUSE_FILTER_PASS
    silver_label.gui_input.connect(_on_silver_label_gui_input)

    refugee_label.mouse_filter = Control.MOUSE_FILTER_PASS
    refugee_label.gui_input.connect(_on_refugee_label_gui_input)

    bingyong_label.mouse_filter = Control.MOUSE_FILTER_PASS
    bingyong_label.gui_input.connect(_on_bingyong_label_gui_input)

    pop_label.mouse_filter = Control.MOUSE_FILTER_PASS
    pop_label.gui_input.connect(_on_pop_label_gui_input)

    _insert_resource_icon_before_label(silver_label, "yinliang")
    _insert_resource_icon_before_label(grain_label, "liangshi")
    _insert_resource_icon_before_label(bingyong_label, "bingyong")
    _insert_resource_icon_before_label(pop_label, "renkou_val")
    _insert_resource_icon_before_label(refugee_label, "liumin")




    _connect_resource_label_hover(silver_label, Callable(self, "_show_silver_resource_tooltip"))
    _connect_resource_label_hover(grain_label, Callable(self, "_show_grain_resource_tooltip"))
    _connect_resource_label_hover(bingyong_label, Callable(self, "_show_bingyong_resource_tooltip"))
    _connect_resource_label_hover(refugee_label, Callable(self, "_show_refugee_resource_tooltip"))
    _connect_resource_label_hover(pop_label, Callable(self, "_show_pop_resource_tooltip"))

    next_button.pressed.connect(_on_next_pressed)
    save_btn.pressed.connect(_on_save_pressed)
    load_btn.pressed.connect(_on_load_pressed)
    if settings_popup:
        settings_popup.z_as_relative = false
        settings_popup.z_index = 100
        _rebuild_game_settings_popup_content()
    theme_btn = Button.new()
    theme_btn.name = "ThemeButton"
    theme_btn.add_theme_font_override("font", FontLoader.body())
    theme_btn.text = "主题：浅色" if GameState.theme == "light" else "主题：深色"
    theme_btn.pressed.connect(_on_theme_toggle_pressed)
    settings_btn.pressed.connect(_show_settings_popup)

    ming_map_close_button.pressed.connect(_close_ming_map_overlay)
    ming_map_reset_zoom_button.pressed.connect(_reset_ming_map_zoom)
    top_location_button.pressed.connect(_on_locate_city_pressed)
    ming_map_mode_rendi_button.pressed.connect( func(): _on_ming_map_mode_pressed("rendi"))
    ming_map_mode_minsheng_button.pressed.connect( func(): _on_ming_map_mode_pressed("minsheng"))
    ming_map_mode_junwu_button.pressed.connect( func(): _on_ming_map_mode_pressed("junwu"))
    ming_map_dimmer.gui_input.connect(_on_ming_map_dimmer_gui_input)
    ming_map_viewport.gui_input.connect(_on_ming_map_viewport_gui_input)
    ming_map_province_layer.gui_input.connect(_on_ming_map_province_layer_gui_input)
    ming_map_province_layer.mouse_exited.connect(_on_ming_map_province_layer_mouse_exited)
    ming_map_viewport.resized.connect(_on_ming_map_viewport_resized)
    if not GameState.theme_changed.is_connected(_on_theme_changed):
        GameState.theme_changed.connect(_on_theme_changed)
    fullscreen_was_active = _is_fullscreen_active()
    _refresh_fullscreen_button()
    _apply_shell_grain_layers()
    _style_ming_map_overlay()
    ming_map_base.texture = load(MING_MAP_BASE_PATH)
    ming_map_current_marker_texture = load(MING_MAP_CURRENT_MARKER_PATH)

    flavor_panel.visible = false

    stats_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    zhisu_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    zengyi_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    attitudes_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    tags_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    archive_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    items_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    lingwu_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    var buqu_panel: = buqu_info_container.get_parent() as PanelContainer
    if buqu_panel:
        buqu_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    result_changes_container.alignment = FlowContainer.ALIGNMENT_CENTER
    result_tags_container.alignment = FlowContainer.ALIGNMENT_CENTER
    ScrollbarThemeRef.apply_to(governance_scroll)
    ScrollbarThemeRef.apply_to(event_scroll)
    ScrollbarThemeRef.apply_to(items_scroll)
    ScrollbarThemeRef.apply_to(lingwu_scroll)
    ScrollbarThemeRef.apply_to(mobile_info_scroll)
    ScrollbarThemeRef.apply_to(dangan_scroll)
    ScrollbarThemeRef.apply_to(jushi_scroll)
    items_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
    mobile_info_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
    items_scroll.gui_input.connect(_on_items_scroll_touch_drag)
    mobile_info_scroll.gui_input.connect(_on_mobile_info_scroll_touch_drag)
    event_scroll.gui_input.connect(_on_mobile_event_reading_area_gui_input)
    narrative_label.gui_input.connect(_on_narrative_text_touch_drag)
    _connect_scroll_drag_forwarders_recursive(event_vbox, _on_event_scroll_touch_drag)
    _connect_scroll_drag_forwarders_recursive(governance_vbox, _on_governance_scroll_touch_drag)


    governance_scroll.gui_input.connect(_on_bianwu_backdrop_scroll_gui_input)

    center_panel.mouse_filter = Control.MOUSE_FILTER_PASS
    center_panel.gui_input.connect(_on_background_touch_drag)
    var center_margin = center_panel.get_node_or_null("CenterMargin")
    if center_margin:
        center_margin.mouse_filter = Control.MOUSE_FILTER_PASS
        center_margin.gui_input.connect(_on_background_touch_drag)

    result_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    _style_ming_map_overlay()



    var help_btn_normal = StyleBoxFlat.new()
    help_btn_normal.bg_color = Color(0, 0, 0, 0)
    _apply_style_border_width(help_btn_normal, _responsive_border_width())
    help_btn_normal.border_color = Color(0.72, 0.6, 0.36, 0.6)
    help_btn_normal.corner_radius_top_left = 7;help_btn_normal.corner_radius_top_right = 7
    help_btn_normal.corner_radius_bottom_left = 7;help_btn_normal.corner_radius_bottom_right = 7
    help_btn_normal.content_margin_left = 1;help_btn_normal.content_margin_right = 1
    help_btn_normal.content_margin_top = 0;help_btn_normal.content_margin_bottom = 0

    var help_btn_hover = help_btn_normal.duplicate()
    help_btn_hover.border_color = Color(0.9, 0.8, 0.6, 1.0)
    help_btn_hover.bg_color = Color(0.72, 0.6, 0.36, 0.2)
    var empty_focus = StyleBoxEmpty.new()

    var stats_hbox = HBoxContainer.new()
    stats_hbox.name = "StatsTitleRow"
    stats_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    stats_hbox.add_theme_constant_override("separation", 6)
    var stats_parent = stats_title.get_parent()
    var stats_idx = stats_title.get_index()
    stats_parent.remove_child(stats_title)
    stats_hbox.add_child(stats_title)
    var stats_help = Button.new()
    stats_help.text = "?"
    stats_help.name = "StatsHelpButton"
    stats_help.custom_minimum_size = Vector2(16, 16)
    stats_help.add_theme_font_size_override("font_size", 13)
    stats_help.add_theme_color_override("font_color", Color(0.72, 0.6, 0.36, 0.8))
    stats_help.add_theme_color_override("font_hover_color", Color(0.9, 0.8, 0.6, 1.0))
    stats_help.add_theme_stylebox_override("normal", help_btn_normal)
    stats_help.add_theme_stylebox_override("hover", help_btn_hover)
    stats_help.add_theme_stylebox_override("pressed", help_btn_hover)
    stats_help.add_theme_stylebox_override("focus", empty_focus)
    stats_help.add_theme_stylebox_override("disabled", help_btn_normal)
    stats_help.add_theme_color_override("font_disabled_color", Color(0.72, 0.6, 0.36, 0.8))
    stats_help.pressed.connect( func(): _show_help_overlay(stats_help, "个 人 禀 赋", "四项禀赋，俱有妙用。\n但应额外留意体质，一旦归零，油尽灯枯，再无回天之力。"))
    _connect_help_btn_hover(stats_help, "个 人 禀 赋", func(): return "四项禀赋，俱有妙用。\n但应额外留意体质，一旦归零，油尽灯枯，再无回天之力。")
    stats_hbox.add_child(stats_help)
    stats_parent.add_child(stats_hbox)
    stats_parent.move_child(stats_hbox, stats_idx)
    stats_parent.add_child(_make_personal_stat_upgrade_button())

    var att_hbox = HBoxContainer.new()
    att_hbox.name = "AttitudesTitleRow"
    att_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    att_hbox.add_theme_constant_override("separation", 6)
    var att_parent = attitudes_title.get_parent()
    var att_idx = attitudes_title.get_index()
    att_parent.remove_child(attitudes_title)
    att_hbox.add_child(attitudes_title)
    var att_help = Button.new()
    att_help.text = "?"
    att_help.name = "AttitudesHelpButton"
    att_help.custom_minimum_size = Vector2(16, 16)
    att_help.add_theme_font_size_override("font_size", 13)
    att_help.add_theme_color_override("font_color", Color(0.72, 0.6, 0.36, 0.8))
    att_help.add_theme_color_override("font_hover_color", Color(0.9, 0.8, 0.6, 1.0))
    att_help.add_theme_stylebox_override("normal", help_btn_normal)
    att_help.add_theme_stylebox_override("hover", help_btn_hover)
    att_help.add_theme_stylebox_override("pressed", help_btn_hover)
    att_help.add_theme_stylebox_override("focus", empty_focus)
    att_help.add_theme_stylebox_override("disabled", help_btn_normal)
    att_help.add_theme_color_override("font_disabled_color", Color(0.72, 0.6, 0.36, 0.8))
    att_help.pressed.connect( func(): _show_help_overlay(att_help, "诸 方 态 度", "官场如棋，五方皆不可失。圣眷、中官、清议、士绅、民望——你无法让所有人满意，但务必守住每一方的底线。任意一方态度归零，便是你在这盘棋局中出局之时。"))
    _connect_help_btn_hover(att_help, "诸 方 态 度", func(): return "官场如棋，五方皆不可失。圣眷、中官、清议、士绅、民望——你无法让所有人满意，但务必守住每一方的底线。任意一方态度归零，便是你在这盘棋局中出局之时。")
    att_hbox.add_child(att_help)

    var title_hbox = HBoxContainer.new()
    title_hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
    title_hbox.add_theme_constant_override("separation", 8)
    var title_parent = speaker_name.get_parent()
    var title_idx = speaker_name.get_index()
    title_parent.remove_child(speaker_name)
    title_hbox.add_child(speaker_name)
    visitor_bio_btn = Button.new()
    visitor_bio_btn.text = "?"
    visitor_bio_btn.add_theme_font_size_override("font_size", 13)
    visitor_bio_btn.add_theme_color_override("font_color", Color(0.72, 0.6, 0.36, 0.8))
    visitor_bio_btn.add_theme_color_override("font_hover_color", Color(0.9, 0.8, 0.6, 1.0))

    var bio_btn_normal = help_btn_normal
    var bio_btn_hover = help_btn_hover
    visitor_bio_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    visitor_bio_btn.custom_minimum_size = Vector2(16, 16)
    visitor_bio_btn.add_theme_stylebox_override("normal", bio_btn_normal)
    visitor_bio_btn.add_theme_stylebox_override("hover", bio_btn_hover)
    visitor_bio_btn.add_theme_stylebox_override("pressed", bio_btn_hover)
    visitor_bio_btn.add_theme_stylebox_override("focus", empty_focus)
    visitor_bio_btn.add_theme_stylebox_override("disabled", bio_btn_normal)
    visitor_bio_btn.add_theme_color_override("font_disabled_color", Color(0.72, 0.6, 0.36, 0.8))
    visitor_bio_btn.pressed.connect( func():
        if current_bio_text != "":
            _show_help_overlay(visitor_bio_btn, "人 物 介 绍", current_bio_text)
    )
    _connect_help_btn_hover(visitor_bio_btn, "人 物 介 绍", func(): return current_bio_text)
    visitor_bio_btn.hide()
    title_hbox.add_child(visitor_bio_btn)
    title_parent.add_child(title_hbox)
    title_parent.move_child(title_hbox, title_idx)
    att_parent.add_child(att_hbox)
    att_parent.move_child(att_hbox, att_idx)

    var box_style = StyleBoxFlat.new()
    box_style.bg_color = GameState.get_theme_color("bg_panel_weak")
    _apply_style_border_width(box_style, _responsive_border_width())
    box_style.border_color = _result_card_border_color()
    box_style.corner_radius_top_left = 2;box_style.corner_radius_top_right = 2;box_style.corner_radius_bottom_right = 2;box_style.corner_radius_bottom_left = 2
    box_style.content_margin_left = 16;box_style.content_margin_top = 16;box_style.content_margin_right = 16;box_style.content_margin_bottom = 16
    box_style.shadow_size = 10 if GameState.theme == "dark" else 0
    box_style.shadow_color = Color(0, 0, 0, 0.34 if GameState.theme == "dark" else 0.0)
    chosen_choice_box.add_theme_stylebox_override("panel", box_style)

    var settlement_box = PanelContainer.new()
    settlement_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
    settlement_box.add_theme_stylebox_override("panel", box_style)
    var settlement_vbox = VBoxContainer.new()
    settlement_vbox.add_theme_constant_override("separation", 16)
    settlement_box.add_child(settlement_vbox)

    var result_parent = result_title.get_parent()
    result_parent.add_child(settlement_box)

    result_parent.remove_child(result_title)
    settlement_vbox.add_child(result_title)
    result_parent.remove_child(result_changes_container)
    settlement_vbox.add_child(result_changes_container)
    result_parent.remove_child(result_items_container)
    settlement_vbox.add_child(result_items_container)
    result_parent.remove_child(result_tags_container)
    settlement_vbox.add_child(result_tags_container)
    result_parent.remove_child(result_comment)
    settlement_vbox.add_child(result_comment)
    result_comment.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

    result_parent.remove_child(next_button)
    result_parent.add_child(next_button)
    _ensure_mobile_continue_button()

    var tab_separator = ColorRect.new()
    tab_separator.custom_minimum_size = Vector2(1, 0)
    tab_separator.color = Color(0.36, 0.3, 0.18, 1.0) if GameState.theme == "light" else GameState.get_theme_color("border_weak")
    var left_shell = left_tabs_host.get_parent()
    left_shell.add_child(tab_separator)
    left_shell.move_child(tab_separator, 1)

    jushi_vbox.add_theme_constant_override("separation", 24)

    var h_sep = HSeparator.new()
    var sep_style = StyleBoxLine.new()
    sep_style.color = GameState.get_theme_color("border_weak")
    sep_style.thickness = 1
    h_sep.add_theme_stylebox_override("separator", sep_style)
    jushi_vbox.add_child(h_sep)
    jushi_vbox.move_child(h_sep, 1)

    dangan_vbox.add_theme_constant_override("separation", 24)

    attitudes_container.add_theme_constant_override("separation", 18)

    _apply_focus_panel_style()

    var avatar_style = StyleBoxFlat.new()
    avatar_style.bg_color = Color(0.055, 0.047, 0.038, 1.0) if GameState.theme == "dark" else Color(0, 0, 0, 0)
    _apply_style_border_width(avatar_style, _responsive_border_width())
    avatar_style.border_color = GameState.get_theme_color("border_strong")
    avatar_style.corner_radius_top_left = 2;avatar_style.corner_radius_top_right = 2
    avatar_style.corner_radius_bottom_left = 2;avatar_style.corner_radius_bottom_right = 2
    avatar_style.shadow_size = 8 if GameState.theme == "dark" else 0
    avatar_style.shadow_color = Color(0, 0, 0, 0.28)
    speaker_avatar.add_theme_stylebox_override("normal", avatar_style)
    speaker_avatar.custom_minimum_size = Vector2(40, 40)
    speaker_avatar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    speaker_avatar.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

    var bubble_style = StyleBoxFlat.new()

    bubble_style.bg_color = Color(0.06, 0.052, 0.043, 0.98) if GameState.theme == "dark" else Color(0, 0, 0, 0)
    _apply_style_border_width(bubble_style, _responsive_border_width())
    bubble_style.border_color = GameState.get_theme_color("border_med")
    bubble_style.corner_radius_top_left = 2;bubble_style.corner_radius_top_right = 2
    bubble_style.corner_radius_bottom_left = 2;bubble_style.corner_radius_bottom_right = 2
    bubble_style.content_margin_left = 16;bubble_style.content_margin_right = 16
    bubble_style.content_margin_top = 16;bubble_style.content_margin_bottom = 16
    bubble_style.shadow_size = 10 if GameState.theme == "dark" else 0
    bubble_style.shadow_color = Color(0, 0, 0, 0.3 if GameState.theme == "dark" else 0.0)
    speaker_bubble.add_theme_stylebox_override("panel", bubble_style)
    speaker_line.add_theme_color_override("font_color", GameState.get_theme_color("text_desc") if GameState.theme == "dark" else GameState.get_theme_color("text_main"))

    speaker_bubble.draw.connect( func():
        var origin = Vector2(12, -8)
        var pts = PackedVector2Array([
            origin + Vector2(0, 8), 
            origin + Vector2(8, 0), 
            origin + Vector2(16, 8), 
            origin + Vector2(16, 12), 
            origin + Vector2(0, 12)
        ])


        var panel_sb: = speaker_bubble.get_theme_stylebox("panel")
        var bg_col: Color = panel_sb.bg_color if panel_sb is StyleBoxFlat else Color(0, 0, 0, 0)
        if bg_col.a > 0.05:
            speaker_bubble.draw_colored_polygon(pts, bg_col)
            var notch_width: = float(_responsive_border_width())
            speaker_bubble.draw_line(origin + Vector2(0, 8), origin + Vector2(8, 0), GameState.get_theme_color("border_med"), notch_width)
            speaker_bubble.draw_line(origin + Vector2(8, 0), origin + Vector2(16, 8), GameState.get_theme_color("border_med"), notch_width)
    )

    topbar_rank.pressed.connect( func(): show_rank_tree_requested.emit())

    if action_points_value != null and is_instance_valid(action_points_value) and not action_points_value.gui_input.is_connected(_on_action_points_card_gui_input):
        action_points_value.mouse_filter = Control.MOUSE_FILTER_STOP
        action_points_value.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
        action_points_value.gui_input.connect(_on_action_points_card_gui_input)
    topbar_rank.custom_minimum_size.y = 32
    topbar_rank.alignment = HORIZONTAL_ALIGNMENT_LEFT
    topbar_rank.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
    governance_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
    governance_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    event_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
    event_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    title_rule.add_theme_constant_override("separation", 16)
    zhisu_tab.pressed.connect( func(): _on_left_tab_clicked("zhisu"))
    buqu_tab.pressed.connect( func(): _on_left_tab_clicked("buqu"))
    zengyi_tab.pressed.connect( func(): _on_left_tab_clicked("zengyi"))
    jushi_tab.pressed.connect( func(): _on_left_tab_clicked("jushi"))
    dangan_tab.pressed.connect( func(): _on_left_tab_clicked("dangan"))
    daoju_tab.pressed.connect( func(): _on_left_tab_clicked("daoju"))
    lingwu_tab.pressed.connect( func(): _on_left_tab_clicked("lingwu"))
    shezhi_tab.pressed.connect( func(): _on_shezhi_tab_pressed())
    _setup_shezhi_tab_icon()
    _build_shezhi_pane()
    mobile_jushi_tab.pressed.connect( func(): _switch_left_tab("jushi"))
    mobile_dangan_tab.pressed.connect( func(): _switch_left_tab("dangan"))
    mobile_daoju_tab.pressed.connect( func(): _switch_left_tab("daoju"))
    mobile_lingwu_tab.pressed.connect( func(): _switch_left_tab("lingwu"))
    resized.connect(_queue_responsive_layout)
    _apply_dynamic_theme()
    _setup_top_overview_button()
    _update_top_location()
    GameState.state_changed.connect(_on_game_state_changed)
    if not GameState.personal_stat_capstone_reached.is_connected(_on_personal_stat_capstone_reached):
        GameState.personal_stat_capstone_reached.connect(_on_personal_stat_capstone_reached)
    _switch_left_tab(current_left_tab)
    _sync_native_landscape_size_override()
    _apply_responsive_layout()
    last_responsive_window_size = _get_responsive_window_size()
    _refresh_music_button()
    _apply_native_mobile_font_scale()

func _on_personal_stat_capstone_reached(stat_key: String) -> void :
    if GameData.active_line != "hanmen":
        return
    if not _personal_stat_capstone_notice_queue.has(stat_key):
        _personal_stat_capstone_notice_queue.append(stat_key)
    _personal_stat_capstone_notice_queue.sort_custom( func(a, b):
        return PersonalStatCapstoneServiceRef.STAT_ORDER.find(a) < PersonalStatCapstoneServiceRef.STAT_ORDER.find(b)
    )
    if lingwu_popup_layer != null and is_instance_valid(lingwu_popup_layer):
        _close_lingwu_popup()
    call_deferred("_show_next_personal_stat_capstone_notice")

func _show_next_personal_stat_capstone_notice() -> void :
    if GameData.active_line != "hanmen" or _personal_stat_capstone_notice_queue.is_empty():
        return
    if _personal_stat_capstone_notice_layer != null and is_instance_valid(_personal_stat_capstone_notice_layer):
        return
    var stat_key: = str(_personal_stat_capstone_notice_queue.pop_front())
    _personal_stat_capstone_notice_layer = CanvasLayer.new()
    _personal_stat_capstone_notice_layer.name = "PersonalStatCapstoneNoticeLayer"
    _personal_stat_capstone_notice_layer.layer = 130
    _personal_stat_capstone_notice_layer.add_to_group("blocking_modal_overlay")
    get_tree().root.add_child(_personal_stat_capstone_notice_layer)

    var dim: = ColorRect.new()
    dim.color = Color(0, 0, 0, 0.72)
    dim.set_anchors_preset(Control.PRESET_FULL_RECT)
    dim.mouse_filter = Control.MOUSE_FILTER_STOP
    _personal_stat_capstone_notice_layer.add_child(dim)

    var viewport_size: = get_viewport_rect().size
    var panel: = PanelContainer.new()
    var notice_width: = minf(540.0, maxf(320.0, viewport_size.x - 48.0))
    var notice_height: = minf(280.0, maxf(240.0, viewport_size.y - 48.0))
    panel.custom_minimum_size = Vector2(notice_width, notice_height)
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.offset_left = - notice_width / 2.0
    panel.offset_right = notice_width / 2.0
    panel.offset_top = - notice_height / 2.0
    panel.offset_bottom = notice_height / 2.0
    panel.add_theme_stylebox_override("panel", _make_items_overlay_panel_style())
    _personal_stat_capstone_notice_layer.add_child(panel)

    var margin: = MarginContainer.new()
    for side in ["left", "right", "top", "bottom"]:
        margin.add_theme_constant_override("margin_" + side, 28)
    panel.add_child(margin)
    var body: = VBoxContainer.new()
    body.alignment = BoxContainer.ALIGNMENT_CENTER
    body.add_theme_constant_override("separation", 22)
    margin.add_child(body)

    var title: = Label.new()
    title.text = "禀赋已臻满值"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_override("font", FontLoader.title())
    title.add_theme_font_size_override("font_size", 24)
    body.add_child(title)
    var desc: = Label.new()
    desc.text = PersonalStatCapstoneServiceRef.notice_text(stat_key)
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    desc.add_theme_font_override("font", FontLoader.body())
    desc.add_theme_font_size_override("font_size", 17)
    body.add_child(desc)
    var close_btn: = _make_shezhi_button("关闭", _close_personal_stat_capstone_notice)
    close_btn.text = "关闭"
    close_btn.custom_minimum_size = Vector2(180, 42)
    close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    body.add_child(close_btn)


    call_deferred("_scale_capstone_notice_for_mobile", panel)

func _scale_capstone_notice_for_mobile(panel: PanelContainer) -> void :
    if not is_instance_valid(panel) or not panel.is_inside_tree():
        return
    if not NativeMobileFontScalerRef.is_native_phone_landscape(panel):
        return
    NativeMobileFontScalerRef.apply_to(panel)
    var viewport_size: = get_viewport_rect().size
    var scaled_width: = minf(panel.custom_minimum_size.x, maxf(320.0, viewport_size.x - 48.0))
    var scaled_height: = minf(panel.custom_minimum_size.y, maxf(240.0, viewport_size.y - 48.0))
    panel.custom_minimum_size = Vector2(scaled_width, scaled_height)
    panel.offset_left = - scaled_width / 2.0
    panel.offset_right = scaled_width / 2.0
    panel.offset_top = - scaled_height / 2.0
    panel.offset_bottom = scaled_height / 2.0

func _close_personal_stat_capstone_notice() -> void :
    if _personal_stat_capstone_notice_layer != null and is_instance_valid(_personal_stat_capstone_notice_layer):
        _personal_stat_capstone_notice_layer.queue_free()
    _personal_stat_capstone_notice_layer = null
    call_deferred("_show_next_personal_stat_capstone_notice")

func start_game() -> void :
    _hide_settings_popup()
    _reset_transient_overlays_for_game_entry()
    _apply_responsive_layout()
    if _is_mobile_portrait():
        current_left_tab = "jushi"
    else:
        current_left_tab = "zhisu"
    governance_active_card_index = -1
    pending_governance_completion_card_index = -1
    pending_result_progress_committed = false
    _switch_left_tab(current_left_tab)
    _refresh_panels()


    if is_instance_valid(GameState):
        var _entry_bgm: = GameState.current_bgm_path
        if GameState.is_title_playlist_path(_entry_bgm) or _entry_bgm == "res://assets/" + "终局回响.mp3" or _entry_bgm == "":
            GameState.play_default_bgm(2.0)
    if GameState.is_governance_mode():
        _show_governance_overview()
    else:
        _show_current_event()

func resume_from_load() -> void :
    _reset_transient_overlays_for_game_entry()
    start_game()
    _queue_responsive_layout()

func resume_from_back_to_choices() -> void :
    _choice_in_progress = false
    _show_current_event()

func _reset_transient_overlays_for_game_entry() -> void :
    _hide_settings_popup()
    _close_lingwu_popup()
    _close_ming_map_overlay()
    _tooltips._clear_resource_tooltips()

func _process(delta: float) -> void :
    _poll_pending_event_portrait()
    if OS.has_feature("web"):
        responsive_sync_elapsed += delta
        if responsive_sync_elapsed >= 0.08:
            responsive_sync_elapsed = 0.0
            var current_size: = _get_responsive_window_size()
            if last_responsive_window_size == Vector2.ZERO:
                last_responsive_window_size = current_size
            elif absf(current_size.x - last_responsive_window_size.x) >= 1.0 or absf(current_size.y - last_responsive_window_size.y) >= 1.0:
                last_responsive_window_size = current_size
                _queue_responsive_layout()
    if OS.has_feature("web"):
        fullscreen_sync_elapsed += delta
        if fullscreen_sync_elapsed < 0.25:
            _clamp_event_result_scroll_bottom()
            return
        fullscreen_sync_elapsed = 0.0
    var fullscreen_active: = _is_fullscreen_active()
    if fullscreen_active != fullscreen_was_active:
        fullscreen_was_active = fullscreen_active
        _refresh_fullscreen_button()
    _clamp_event_result_scroll_bottom()

func _get_topbar_turn_label() -> String:

    if _showing_dianshi_memory_result and _dianshi_memory_turn_label != "":
        return _dianshi_memory_turn_label

    if GameState.has_method("is_after_sun_chuanting_branch_split") and GameState.is_after_sun_chuanting_branch_split():
        return "终卷 · 尘埃渐落"
    if governance_active_card_index >= 0:
        var evt: = GameState.get_month_card_event(governance_active_card_index)
        if str(evt.get("id", "")) == "e5_5":
            return "终卷 · 尘埃渐落"
        var event_turn: String = Presenter.get_event_time_label(evt)
        if event_turn.strip_edges() != "":
            return event_turn
    var label = GameState.get_governance_turn_label() if GameState.is_governance_mode() else GameState.get_volume_label()
    if label.contains("终卷 · 尘埃渐落"):
        return "终卷 · 尘埃渐落"
    return label


func _is_dianshi_memory_event_context() -> bool:
    var cur_event = GameState.get_current_event()
    if cur_event == null:
        return false
    if str(cur_event.get("id", "")) == "e_keju_dianshi_memory":
        return true
    return str(cur_event.get("stage", "")).contains("殿试")

func _is_final_volume_context() -> bool:
    var cur_event = GameState.get_current_event()
    if cur_event != null:
        var stage_str = str(cur_event.get("stage", ""))
        var active_branch = GameState.active_pending_event.get("branch", GameState.branch) if not GameState.active_pending_event.is_empty() else GameState.branch
        if stage_str.contains("终卷") or int(cur_event.get("year", 0)) == 17 or active_branch in ["zhongchen", "bifan", "xiaoxiong", "xinghuo"]:
            return true
    var volume_label: = str(GameState.get_volume_label())
    if volume_label.contains("终卷") or volume_label.contains("最终卷"):
        return true
    return GameState.branch in ["zhongchen", "bifan", "xiaoxiong", "xinghuo"]

func _sync_topbar_turn_label() -> void :
    topbar_turn.text = _get_topbar_turn_label()

func _sync_event_date_label_visibility() -> void :


    var year_label: = ""
    if GameState.has_method("get_current_year_str"):
        year_label = str(GameState.get_current_year_str()).strip_edges()
    if year_label != "":
        var month_value: = 0
        var cur_event: = GameState.get_current_event()
        if cur_event != null:
            month_value = int(cur_event.get("month", 0))
        var m_name: = GovernanceCalendarTextRef.month_name(month_value) if month_value > 0 else ""
        if m_name != "":
            if not GameData.SEASON_NAMES.is_empty():
                event_date_label.text = "%s·%s" % [year_label, m_name]
            else:
                event_date_label.text = "%s%s" % [year_label, m_name]
        else:
            event_date_label.text = year_label
    var should_show: = _is_local_route() and not _is_final_volume_context()
    event_date_label.visible = should_show and event_date_label.text.strip_edges() != ""

func _on_landscape_size_mode_pressed() -> void :
    GameState.cycle_landscape_size_mode()
    NativeMobileFontScalerRef.reset_scaled_overrides(self)
    _sync_native_landscape_size_override()
    _sync_landscape_size_button_text()
    _apply_responsive_layout()

func _set_large_ui_mode(enabled: bool) -> void :
    GameState.set_large_ui_mode(enabled)
    NativeMobileFontScalerRef.reset_scaled_overrides(self)
    _sync_native_landscape_size_override()
    _sync_landscape_size_button_text()
    _refresh_shezhi_buttons()
    _apply_responsive_layout()



    _switch_left_tab(current_left_tab)



    call_deferred("_refresh_governance_overview_after_ui_scale")

func _refresh_governance_overview_after_ui_scale() -> void :

    if governance_active_card_index >= 0:
        return
    if not is_instance_valid(governance_scroll) or not governance_scroll.visible:
        return
    _show_governance_overview(false)

func _sync_landscape_size_button_text() -> void :
    if landscape_size_btn == null:
        return
    landscape_size_btn.text = "UI：大" if _is_effective_large_ui_mode() else "UI：普通"

func _sync_native_landscape_size_override() -> void :
    NativeMobileFontScalerRef.set_landscape_size_mode_override(GameState.landscape_size_mode)

func _is_effective_large_ui_mode() -> bool:
    if GameState.landscape_size_mode == "phone":
        return true
    if GameState.landscape_size_mode == "desktop":
        return false
    return _is_mobile_portrait() or _is_native_mobile_landscape()

func _on_game_state_changed() -> void :
    if _defer_choice_result_panel_refresh:
        _choice_result_panel_refresh_pending = true
        return
    _refresh_panels()

func _begin_choice_result_panel_refresh_deferral() -> void :
    _defer_choice_result_panel_refresh = true
    _choice_result_panel_refresh_pending = false

func _flush_choice_result_panel_refresh() -> void :
    _defer_choice_result_panel_refresh = false
    _choice_result_panel_refresh_pending = false
    _refresh_panels()

func _cancel_choice_result_panel_refresh_deferral() -> void :
    _defer_choice_result_panel_refresh = false
    _choice_result_panel_refresh_pending = false

func _refresh_panels() -> void :
    var identity = GameState.get_display_identity()
    if _is_mobile_portrait():
        if identity.contains("("):
            identity = identity.split("(")[0].strip_edges()
        if identity.contains("（"):
            identity = identity.split("（")[0].strip_edges()

    if GameState.has_method("get_active_honorary_title"):
        var honorary: = str(GameState.get_active_honorary_title())
        if honorary != "":
            identity = "%s·%s" % [identity, honorary]
    topbar_rank.text = identity
    var new_turn = _get_topbar_turn_label()

    var is_final_volume: = _is_final_volume_context()

    var is_dianshi_memory: = _is_dianshi_memory_event_context()

    var is_bianwu_line: = GameData.active_line == "bianwu"
    buqu_tab.visible = is_bianwu_line
    jushi_tab.visible = not is_bianwu_line
    if is_bianwu_line and current_left_tab == "jushi":
        _switch_left_tab("zhisu")
    if not is_bianwu_line and current_left_tab == "buqu":
        _switch_left_tab("zhisu")


    zhisu_tab.visible = not is_dianshi_memory
    if is_dianshi_memory and current_left_tab == "zhisu":
        _switch_left_tab("jushi")

    if is_final_volume or is_dianshi_memory:
        zengyi_tab.visible = false
        if current_left_tab == "zengyi":
            _switch_left_tab("jushi" if is_dianshi_memory else "zhisu")
    else:
        zengyi_tab.visible = true

    if not _is_mobile_portrait():
        var top_rank_divider: = _ensure_top_rank_divider()
        if top_rank_divider != null:
            top_rank_divider.visible = not is_dianshi_memory

    var att_section = attitudes_panel.get_parent()
    att_section.modulate = Color(1, 1, 1, 1.0)
    var help_btns = att_section.find_children("*", "Button", true, false)
    for btn in help_btns:
        btn.disabled = false

    if topbar_turn.text != "" and topbar_turn.text != new_turn:
        topbar_turn.pivot_offset = topbar_turn.size / 2.0
        var t = create_tween()
        t.tween_property(topbar_turn, "scale:y", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
        t.parallel().tween_property(topbar_turn, "modulate", Color(1.0, 0.84, 0.0, 1.0), 0.2)

        t.tween_callback( func(): topbar_turn.text = new_turn)

        t.tween_property(topbar_turn, "scale:y", 1.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
        t.parallel().tween_property(topbar_turn, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)
    else:
        topbar_turn.text = new_turn
    topbar_turn.visible = _is_mobile_portrait() or not GameState.is_governance_mode() or is_dianshi_memory or _showing_dianshi_memory_result


    var is_mobile: = _is_mobile_portrait()
    if is_mobile:
        Presenter.populate_stats(stats_container, GameState.stats)
        _apply_mobile_dangan_stats_layout()
        Presenter.populate_attitudes_compact(attitudes_container, GameState.attitudes, Callable(GameState, "get_attitude_tier"), Callable(self, "_get_tier_color"))
    else:
        Presenter.populate_stats(stats_container, GameState.stats)
        Presenter.populate_attitudes(attitudes_container, GameState.attitudes, Callable(GameState, "get_attitude_tier"), Callable(self, "_get_tier_color"), is_mobile, GameState.theme == "light")
    var _fd: = GameState.theme == "light"
    Presenter.populate_tags(tags_container, GameState.tags, "暂无标签", is_mobile, _fd)
    Presenter.populate_archive_info(archive_info_container, GameState, is_mobile, _fd)
    _ensure_archive_tags_divider()
    _refresh_dossier_avatar()
    Presenter.populate_items(items_info_container, _build_display_items(), "尚无物件", is_mobile, _fd)
    _refresh_zhisu_panel()
    _refresh_buqu_panel()
    _refresh_zengyi_panel()
    _refresh_lingwu_panel()
    _connect_item_scroll_drag_forwarders()
    _connect_jushi_scroll_drag_forwarders()
    _connect_dangan_scroll_drag_forwarders()
    _refresh_music_button()


    for key in GameData.ATT_KEYS:
        if not GameState.attitudes.has(key):
            continue
        var current_val: = int(GameState.attitudes.get(key, 0))
        if _prev_attitudes_cache.has(key):
            var prev_val: int = _prev_attitudes_cache[key]
            if current_val != prev_val:
                var diff = current_val - prev_val
                var target_node: Control = null
                if is_mobile:
                    target_node = attitudes_container.find_child("AttitudeBox_" + key, true, false) as Control
                else:
                    target_node = attitudes_container.find_child("AttitudeWrapper_" + key, true, false) as Control
                if target_node != null:
                    _animate_control_value_change(target_node, diff)
        _prev_attitudes_cache[key] = current_val


    var personal_stat_keys: = ["wentao", "wulue", "lizheng", "tizhi"]
    for key in personal_stat_keys:
        if not GameState.stats.has(key):
            continue
        var current_val: = int(GameState.stats.get(key, 0))
        if _prev_personal_stats_cache.has(key):
            var prev_val: int = _prev_personal_stats_cache[key]
            if current_val != prev_val:
                var diff = current_val - prev_val
                if is_mobile:
                    var target_node = stats_container.find_child("StatPanel_" + key, true, false) as Control
                    if target_node != null:
                        _animate_control_value_change(target_node, diff)

        _prev_personal_stats_cache[key] = current_val

    if ming_map_overlay.visible:
        _refresh_ming_map_overlay()

    if resource_bar:
        resource_bar.visible = _should_show_top_resources()

    _configure_top_status_bar_content()
    if _is_mobile_portrait():

        var has_res: = resource_bar.visible if resource_bar else false
        top_bar.custom_minimum_size.y = MOBILE_TOP_BAR_HEIGHT_WITH_RESOURCES if has_res else MOBILE_TOP_BAR_HEIGHT_NO_RESOURCES

        _apply_font_floor_recursive(stats_section, MOBILE_SIDE_PANE_FONT_SIZE)
        _apply_font_floor_recursive(attitudes_section, MOBILE_SIDE_PANE_FONT_SIZE)
        _apply_side_pane_font_floor(MOBILE_SIDE_PANE_FONT_SIZE)
        _apply_mobile_detail_tab_typography()

    call_deferred("_apply_native_mobile_font_scale")

func _format_large_number(val: int) -> String:
    var abs_val = abs(val)
    if abs_val < 10000:
        return str(val)
    else:
        var result = "%.1f万" % (float(val) / 10000.0)
        if result.ends_with(".0万"):
            return result.replace(".0万", "万")
        return result

func _refresh_zhisu_panel() -> void :
    _update_top_location()
    if not is_instance_valid(zhisu_info_container):
        return
    zhisu_info_container.add_theme_constant_override("separation", 0)
    for child in zhisu_info_container.get_children():
        zhisu_info_container.remove_child(child)
        if child == stats_section:
            continue
        child.queue_free()

    if GameState.city.is_empty():
        zhisu_info_container.add_child(_make_zhisu_empty_label("暂无治所数据"))
        _apply_dynamic_side_pane_font_scale(zhisu_pane)
        return

    if not _is_local_route():

        if GameData.active_line != "bianwu":
            var city_name: = str(GameState.city.get("name", "治所"))
            var province: = str(GameState.city.get("province", ""))
            var title_text: = city_name
            if province != "" and not city_name.begins_with(province):
                title_text = "%s · %s" % [province, city_name]
            zhisu_info_container.add_child(_make_zhisu_title_label(title_text))
            var merit_word: = "政绩"
            var merit: = GameState.get_governance_merit()
            var merit_target: = GameState.get_governance_merit_target()
            var merit_text: = str(merit)
            if merit_target > 0:
                merit_text = "%d/%d" % [merit, merit_target]
        if not _action_points_portrait_active:
            zhisu_info_container.add_child(_make_zhisu_overview_button_block())

        var spacer: = Control.new()
        spacer.custom_minimum_size = Vector2(0, 16)
        zhisu_info_container.add_child(spacer)


        if not _is_local_route():
            if GameData.active_line == "bianwu":

                if stats_section.get_parent() != zhisu_info_container:
                    if stats_section.get_parent():
                        stats_section.get_parent().remove_child(stats_section)
                    zhisu_info_container.add_child(stats_section)
                stats_section.visible = true
                stats_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                stats_section.size_flags_vertical = Control.SIZE_FILL
                stats_panel.custom_minimum_size = Vector2(0, 0)

                var bianwu_divider: = HSeparator.new()
                var bianwu_div_style: = StyleBoxLine.new()
                bianwu_div_style.color = GameState.get_theme_color("border_weak")
                bianwu_div_style.thickness = 1
                bianwu_divider.add_theme_stylebox_override("separator", bianwu_div_style)
                var div_margin: = MarginContainer.new()
                div_margin.add_theme_constant_override("margin_top", 10)
                div_margin.add_theme_constant_override("margin_bottom", 4)
                div_margin.add_child(bianwu_divider)
                zhisu_info_container.add_child(div_margin)

                zhisu_info_container.add_child(_make_zhisu_section_label("诸方态度"))
                zhisu_info_container.add_child(_make_zhisu_attitudes_list())
            else:
                zhisu_info_container.add_child(_make_zhisu_section_label("府库民力"))
                for resource in [
                    {"key": "yinliang", "label": "库银"}, 
                    {"key": "liangshi", "label": "官粮"}, 
                    {"key": "bingyong", "label": "兵勇"}, 
                    {"key": "renkou_val", "label": "人口"}, 
                    {"key": "liumin", "label": "流民"}, 
                ]:
                    zhisu_info_container.add_child(_make_zhisu_resource_row(str(resource["key"]), str(resource["label"])))

    var is_final_volume: = _is_final_volume_context()


    if _is_local_route():
        zhisu_info_container.add_child(_make_zhisu_section_label("诸方态度"))
        zhisu_info_container.add_child(_make_zhisu_attitudes_list())
        if is_final_volume:
            var stats_spacer: = Control.new()
            stats_spacer.custom_minimum_size = Vector2(0, 36)
            zhisu_info_container.add_child(stats_spacer)

            if stats_section.get_parent() != zhisu_info_container:
                if stats_section.get_parent():
                    stats_section.get_parent().remove_child(stats_section)
                zhisu_info_container.add_child(stats_section)
            stats_section.visible = true
            stats_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            stats_section.size_flags_vertical = Control.SIZE_FILL
            stats_panel.custom_minimum_size = Vector2(0, 0)

    if not is_final_volume and GameData.active_line != "bianwu":
        if _is_local_route():
            var segment_spacer: = Control.new()
            segment_spacer.custom_minimum_size = Vector2(0, 24)
            zhisu_info_container.add_child(segment_spacer)

        zhisu_info_container.add_child(_make_zhisu_section_label("辖地民生"))
        var merit_word: = "政绩"
        var merit: = GameState.get_governance_merit()
        var merit_target: = GameState.get_governance_merit_target()
        var merit_text: = str(merit)
        if merit_target > 0:
            merit_text = "%d/%d" % [merit, merit_target]
        var merit_row: = _make_zhisu_merit_row(merit_word, merit_text)
        zhisu_info_container.add_child(merit_row)
        _animate_zhisu_merit_change_if_needed(merit)
        for key in GameData.CITY_STAT_KEYS:
            zhisu_info_container.add_child(_make_zhisu_city_stat_row(str(key)))

    _connect_zhisu_scroll_drag_forwarders()
    _apply_dynamic_side_pane_font_scale(zhisu_pane)

func _refresh_buqu_panel() -> void :
    if not is_instance_valid(buqu_info_container):
        return
    buqu_info_container.add_theme_constant_override("separation", 0)
    for child in buqu_info_container.get_children():
        buqu_info_container.remove_child(child)
        child.queue_free()

    if GameData.active_line != "bianwu":
        buqu_info_container.add_child(_make_zhisu_empty_label("暂无部曲数据"))
        _apply_dynamic_side_pane_font_scale(buqu_pane)
        return

    buqu_info_container.add_child(_make_bianwu_buqu_sidebar_entry())
    buqu_info_container.add_child(_make_zhisu_section_label("官军"))
    buqu_info_container.add_child(_make_zhisu_bianwu_force_cards(false, false))
    var force_spacer: = Control.new()
    force_spacer.custom_minimum_size = Vector2(0, 16)
    buqu_info_container.add_child(force_spacer)
    buqu_info_container.add_child(_make_zhisu_section_label("家丁"))
    buqu_info_container.add_child(_make_zhisu_bianwu_force_cards(true, false))
    var officer_spacer: = Control.new()
    officer_spacer.custom_minimum_size = Vector2(0, 16)
    buqu_info_container.add_child(officer_spacer)
    buqu_info_container.add_child(_make_zhisu_section_label("将官"))
    var officer_list: = VBoxContainer.new()
    officer_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    officer_list.add_theme_constant_override("separation", 8)
    for officer_index in range(GameState.bianwu_defense_officers.size()):
        var officer: Dictionary = GameState.bianwu_defense_officers[officer_index]
        var officer_card: Button = _bianwu_deployment_slot_controller.make_officer_card(officer, officer_index)
        officer_card.pressed.connect(_show_bianwu_officer_detail_popup.bind(officer_card, officer_index))
        officer_list.add_child(officer_card)
        _bianwu_deployment_slot_controller.attach_officer_drag_source(officer_card, officer_index)
    buqu_info_container.add_child(officer_list)
    _apply_dynamic_side_pane_font_scale(buqu_pane)

func _refresh_zengyi_panel() -> void :
    if not is_instance_valid(zengyi_info_container):
        return
    zengyi_info_container.add_theme_constant_override("separation", 8)
    for child in zengyi_info_container.get_children():
        zengyi_info_container.remove_child(child)
        child.queue_free()

    if GameState.city.is_empty():
        zengyi_info_container.add_child(_make_zhisu_empty_label("暂无治所数据"))
        _apply_dynamic_side_pane_font_scale(zengyi_pane)
        return

    zengyi_info_container.add_child(_make_zengyi_boost_tabs())
    if zengyi_active_boost_tab == "personal":
        zengyi_info_container.add_child(_make_zengyi_personal_boost_tabs_gap())
        zengyi_info_container.add_child(_make_zengyi_boost_section_title("已装配"))
        zengyi_info_container.add_child(_make_zengyi_governance_title_slots_gap())
        zengyi_info_container.add_child(_make_zengyi_personal_boost_slots())

        var note: = Label.new()
        note.text = "注：个人增益栏位每两年扩充一格。"
        note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        note.add_theme_font_override("font", FontLoader.body())
        note.add_theme_font_size_override("font_size", 10)
        note.add_theme_color_override("font_color", _left_panel_text_color("text_sub"))
        zengyi_info_container.add_child(note)

        var note_button_gap: = Control.new()
        note_button_gap.custom_minimum_size = Vector2(0, 4)
        note_button_gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
        zengyi_info_container.add_child(note_button_gap)

        zengyi_info_container.add_child(_make_zengyi_auto_arrange_button_block())
        _connect_zengyi_scroll_drag_forwarders()
        _apply_dynamic_side_pane_font_scale(zengyi_pane)
        return

    var city_name: = str(GameState.city.get("name", "治所"))
    var province: = str(GameState.city.get("province", ""))
    var title_text: = city_name
    if province != "" and not city_name.begins_with(province):
        title_text = "%s · %s" % [province, city_name]
    zengyi_info_container.add_child(_make_zengyi_governance_tabs_title_gap())
    zengyi_info_container.add_child(_make_zengyi_boost_section_title(title_text))
    zengyi_info_container.add_child(_make_zengyi_governance_title_slots_gap())
    zengyi_info_container.add_child(_make_zengyi_boost_slots())
    zengyi_info_container.add_child(_make_zengyi_expand_button_block())

    _connect_zengyi_scroll_drag_forwarders()
    _apply_dynamic_side_pane_font_scale(zengyi_pane)

func _make_zengyi_boost_tabs() -> Control:
    var row: = HBoxContainer.new()
    row.name = "ZengyiBoostTabs"
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_theme_constant_override("separation", 6)
    for definition in [{"key": "governance", "label": "治理增益"}, {"key": "personal", "label": "个人增益"}]:
        var btn: = Button.new()
        var key: = str(definition["key"])
        var active: = key == zengyi_active_boost_tab
        btn.text = str(definition["label"])
        btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        btn.focus_mode = Control.FOCUS_NONE
        btn.add_theme_font_override("font", FontLoader.body())
        btn.add_theme_font_size_override("font_size", 12)
        btn.add_theme_color_override("font_color", GameState.get_theme_color("border_active") if active else _left_panel_text_color("text_sub"))
        btn.add_theme_stylebox_override("normal", _make_zengyi_expand_button_style(active))
        btn.add_theme_stylebox_override("hover", _make_zengyi_expand_button_style(true))
        btn.add_theme_stylebox_override("pressed", _make_zengyi_expand_button_style(true))
        btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
        btn.pressed.connect( func():
            if zengyi_active_boost_tab != key:
                zengyi_active_boost_tab = key
                _refresh_zengyi_panel()
        )
        row.add_child(btn)
    return row

func _make_zengyi_personal_boost_tabs_gap() -> Control:
    var spacer: = Control.new()
    spacer.name = "ZengyiPersonalBoostTabsGap"
    spacer.custom_minimum_size = Vector2(0, 20)
    spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    return spacer

func _make_zengyi_governance_tabs_title_gap() -> Control:
    var spacer: = Control.new()
    spacer.name = "ZengyiGovernanceTabsTitleGap"
    spacer.custom_minimum_size = Vector2(0, 20)
    spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    return spacer

func _make_zengyi_governance_title_slots_gap() -> Control:
    var spacer: = Control.new()
    spacer.name = "ZengyiGovernanceTitleSlotsGap"
    spacer.custom_minimum_size = Vector2(0, 0)
    spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    return spacer

func _make_zengyi_boost_section_title(text: String) -> Label:
    var title: = _make_zhisu_title_label(text)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    title.add_theme_font_override("font", FontLoader.body())
    title.add_theme_font_size_override("font_size", 13)
    return title

func _make_zhisu_title_label(text: String) -> Label:
    var label: = Label.new()
    label.text = text
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_override("font", FontLoader.serif_bold())
    label.add_theme_font_size_override("font_size", 17)
    label.add_theme_color_override("font_color", _left_panel_text_color("text_main"))
    return label

func _make_zhisu_empty_label(text: String) -> Label:
    var label: = Label.new()
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_override("font", FontLoader.body())
    label.add_theme_font_size_override("font_size", 13)
    label.add_theme_color_override("font_color", _left_panel_text_color("text_sub"))
    return label

func _make_zhisu_section_label(text: String) -> Control:
    var label: = Label.new()
    label.text = text
    label.add_theme_font_override("font", FontLoader.serif_bold())
    label.add_theme_font_size_override("font_size", 13)
    label.add_theme_color_override("font_color", _left_panel_text_color("text_sub"))
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.custom_minimum_size.y = 26

    if text == "府库民力" or text == "作战资源" or text == "兵力" or text == "官军" or text == "家丁" or text == "将官":
        var margin: = MarginContainer.new()
        margin.add_theme_constant_override("margin_top", 10)
        margin.add_theme_constant_override("margin_bottom", 4)
        margin.add_child(label)
        return margin

    if text == "辖地民生" or text == "诸方态度":
        var hbox: = HBoxContainer.new()
        hbox.alignment = BoxContainer.ALIGNMENT_CENTER
        hbox.add_theme_constant_override("separation", 6)



        var title_label: = Label.new()
        title_label.text = text
        title_label.add_theme_font_override("font", FontLoader.serif_bold())
        title_label.add_theme_font_size_override("font_size", 13)
        title_label.add_theme_color_override("font_color", _left_panel_text_color("text_sub"))
        title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        hbox.add_child(title_label)

        var help_btn: = Button.new()
        help_btn.name = "ZhisuAttitudesHelpButton" if text == "诸方态度" else "ZhisuGovernanceMeritHelpButton"
        help_btn.text = "?"
        help_btn.custom_minimum_size = Vector2(16, 16)
        help_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        help_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        help_btn.focus_mode = Control.FOCUS_NONE
        help_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
        help_btn.add_theme_font_size_override("font_size", 13)
        help_btn.add_theme_color_override("font_color", Color(0.72, 0.6, 0.36, 0.8))
        help_btn.add_theme_color_override("font_hover_color", Color(0.9, 0.8, 0.6, 1.0))
        var _help_normal: = StyleBoxFlat.new()
        _help_normal.bg_color = Color(0, 0, 0, 0)
        _apply_style_border_width(_help_normal, _responsive_border_width())
        _help_normal.border_color = Color(0.72, 0.6, 0.36, 0.6)
        _help_normal.corner_radius_top_left = 8;_help_normal.corner_radius_top_right = 8
        _help_normal.corner_radius_bottom_left = 8;_help_normal.corner_radius_bottom_right = 8
        _help_normal.content_margin_left = 1;_help_normal.content_margin_right = 1
        _help_normal.content_margin_top = 0;_help_normal.content_margin_bottom = 0
        var _help_hover: = _help_normal.duplicate()
        _help_hover.border_color = Color(0.9, 0.8, 0.6, 1.0)
        _help_hover.bg_color = Color(0.72, 0.6, 0.36, 0.2)
        help_btn.add_theme_stylebox_override("normal", _help_normal)
        help_btn.add_theme_stylebox_override("hover", _help_hover)
        help_btn.add_theme_stylebox_override("pressed", _help_hover)
        help_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

        if text == "诸方态度":
            var att_title: = "诸 方 态 度"
            var att_text: = _zhisu_attitudes_help_text()
            help_btn.pressed.connect( func(): _show_help_overlay(help_btn, att_title, att_text))
            _connect_help_btn_hover(help_btn, att_title, func(): return att_text)
        else:
            var merit_title: = "战功考成" if GameData.active_line == "bianwu" else "政绩考成"
            help_btn.pressed.connect( func(): _show_help_overlay(help_btn, merit_title, _build_governance_merit_help_text()))
            _connect_help_btn_hover(help_btn, merit_title, func(): return _build_governance_merit_help_text())
        hbox.add_child(help_btn)

        var margin: = MarginContainer.new()
        var top_margin: = 10
        if text == "辖地民生":
            top_margin = 12
        elif text == "诸方态度" and _is_final_volume_context():
            top_margin = 12
        margin.add_theme_constant_override("margin_top", top_margin)
        margin.add_theme_constant_override("margin_bottom", 6)
        margin.add_child(hbox)
        return margin

    return label

func _make_zhisu_plain_row(label_text: String, value_text: String) -> Control:
    return _make_zhisu_row("", label_text, value_text)

func _make_zhisu_merit_row(label_text: String, value_text: String) -> Control:
    var row: = _make_zhisu_row("city", label_text, value_text)
    row.name = "ZhisuMeritRow"
    _connect_zhisu_merit_row_interactions(row)
    return row

func _animate_zhisu_merit_change_if_needed(current_merit: int) -> void :
    var cache_key: = str(GameData.active_line)
    if _prev_governance_merit_cache.has(cache_key):
        var prev_merit: = int(_prev_governance_merit_cache[cache_key])
        if current_merit != prev_merit:
            var diff: = current_merit - prev_merit
            var target_node: = zhisu_info_container.find_child("ZhisuMeritRow", true, false) as Control
            if target_node != null:
                _animate_control_value_change(target_node, diff, current_merit)
    _prev_governance_merit_cache[cache_key] = current_merit

func _make_zhisu_merit_summary(label_text: String, value_text: String) -> Control:
    var summary: = HBoxContainer.new()
    summary.alignment = BoxContainer.ALIGNMENT_CENTER
    summary.add_theme_constant_override("separation", 4)
    summary.custom_minimum_size.y = 24

    var label: = Label.new()
    label.text = label_text
    label.add_theme_font_override("font", FontLoader.body())
    label.add_theme_font_size_override("font_size", 12)
    label.add_theme_color_override("font_color", _left_panel_text_color("text_sub"))
    summary.add_child(label)

    var value: = Label.new()
    value.text = value_text
    value.add_theme_font_override("font", FontLoader.serif_bold())
    value.add_theme_font_size_override("font_size", 12)
    value.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    summary.add_child(value)

    return summary

func _make_bianwu_buqu_sidebar_entry() -> Control:
    var margin: = MarginContainer.new()
    margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    margin.add_theme_constant_override("margin_left", ZHISU_ROW_CARD_SIDE_MARGIN)
    margin.add_theme_constant_override("margin_right", ZHISU_ROW_CARD_SIDE_MARGIN)
    margin.add_theme_constant_override("margin_top", 10)
    margin.add_theme_constant_override("margin_bottom", 18)

    var column: = VBoxContainer.new()
    column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    column.alignment = BoxContainer.ALIGNMENT_CENTER
    column.add_theme_constant_override("separation", 6)
    margin.add_child(column)

    var title: = Label.new()
    title.text = "部曲"
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", 14)
    title.add_theme_color_override("font_color", Color(1, 1, 1, 0.92))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    column.add_child(title)

    var manage_btn: = Button.new()
    manage_btn.text = "管理"
    manage_btn.focus_mode = Control.FOCUS_NONE
    manage_btn.custom_minimum_size = Vector2(52, 24)
    manage_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    manage_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    manage_btn.add_theme_font_override("font", FontLoader.serif_bold())
    manage_btn.add_theme_font_size_override("font_size", 10)
    manage_btn.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    var btn_style: = StyleBoxFlat.new()
    btn_style.bg_color = Color(0.18, 0.16, 0.13, 0.45)
    btn_style.border_color = Color(GameState.get_theme_color("border_active"))
    btn_style.border_color.a = 0.5
    btn_style.set_border_width_all(1)
    btn_style.corner_radius_top_left = 4;btn_style.corner_radius_top_right = 4
    btn_style.corner_radius_bottom_left = 4;btn_style.corner_radius_bottom_right = 4
    btn_style.content_margin_left = 10
    btn_style.content_margin_right = 10
    manage_btn.add_theme_stylebox_override("normal", btn_style)
    manage_btn.add_theme_stylebox_override("hover", btn_style)
    manage_btn.add_theme_stylebox_override("pressed", btn_style)
    manage_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    manage_btn.pressed.connect(_show_bianwu_buqu_management_modal)
    column.add_child(manage_btn)

    return margin

func _make_zhisu_resource_row(key: String, label_text: String) -> Control:
    var value: = int(GameState.city.get(key, 0))
    var row: = _make_zhisu_row(key, label_text, _format_large_number(value))
    _connect_zhisu_resource_row_interactions(row, key)
    return row

func _make_zhisu_bianwu_force_cards(only_jiading: bool = false, show_actions: bool = true, card_mode: String = "sidebar") -> Control:
    var list: = VBoxContainer.new()
    list.name = "ZhisuBianwuForceCards_Jiading" if only_jiading else "ZhisuBianwuForceCards_Guanjun"
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list.add_theme_constant_override("separation", 14 if card_mode == "management" else 0)
    var serial_by_unit: = {}

    var entries: Array = GameState.bianwu_units.duplicate()
    var idx: = 0
    for entry in entries:
        var unit_id: = ""
        var cap: = BIANWU_FORCE_CARD_CAP
        var amount: = 0
        var is_jd: = false
        if entry is Dictionary:
            unit_id = str(entry.get("id", ""))
            cap = int(entry.get("cap", BIANWU_FORCE_CARD_CAP))
            is_jd = bool(entry.get("is_jiading", false))
        else:
            unit_id = str(entry)
            is_jd = false
        if unit_id == "":
            idx += 1
            continue
        if is_jd != only_jiading:
            idx += 1
            continue
        serial_by_unit[unit_id] = int(serial_by_unit.get(unit_id, 0)) + 1
        var serial: int = int(serial_by_unit[unit_id])
        var unit_def: Dictionary = BattleTypesRef.unit_def(unit_id)
        amount = int(entry.get("hp", unit_def.get("hp", 0))) if entry is Dictionary else int(unit_def.get("hp", 0))
        list.add_child(_make_zhisu_bianwu_force_card(unit_id, serial, amount, cap, idx, show_actions, card_mode))
        idx += 1
    if list.get_child_count() == 0:
        list.add_child(_make_zhisu_empty_label("暂无部队"))
    var margin: = MarginContainer.new()
    margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var side_margin: = 0 if card_mode == "management" else ZHISU_ROW_CARD_SIDE_MARGIN
    margin.add_theme_constant_override("margin_left", side_margin)
    margin.add_theme_constant_override("margin_right", side_margin)
    margin.add_child(list)
    return margin

func _make_zhisu_bianwu_force_card(unit_id: String, serial: int, amount: int, cap: int, idx: int, show_actions: bool = true, card_mode: String = "sidebar") -> Control:
    var unit_def: Dictionary = BattleTypesRef.unit_def(unit_id)


    var base_name: = str(unit_def.get("name", unit_id))
    var entry = GameState.bianwu_units[idx]
    if entry is Dictionary and entry.has("name"):
        base_name = str(entry["name"])

    var card: = PanelContainer.new()
    card.name = "ZhisuBianwuForceCard_%s_%d" % [unit_id, serial]
    card.size_flags_horizontal = Control.SIZE_EXPAND_FILL if card_mode == "sidebar" else Control.SIZE_FILL
    card.custom_minimum_size = Vector2(210, 150) if card_mode == "management" else Vector2(0, 56)
    if _bianwu_deployment_slot_controller != null:
        _bianwu_deployment_slot_controller.attach_unit_drag_source(card, idx)


    var custom_style: = _make_zhisu_row_card_style(false)
    if card_mode == "management":
        custom_style.bg_color = Color(0.08, 0.065, 0.045, 0.68)
        custom_style.border_color = Color(0.72, 0.6, 0.36, 0.25)
        custom_style.corner_radius_top_left = 6;custom_style.corner_radius_top_right = 6
        custom_style.corner_radius_bottom_left = 6;custom_style.corner_radius_bottom_right = 6
        custom_style.content_margin_left = 16
        custom_style.content_margin_right = 16
        custom_style.content_margin_top = 14
        custom_style.content_margin_bottom = 14
    else:
        custom_style.content_margin_left = 12
        custom_style.content_margin_right = 12
        custom_style.content_margin_top = 8
        custom_style.content_margin_bottom = 8
    card.add_theme_stylebox_override("panel", custom_style)

    var text_box: = VBoxContainer.new()
    text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    text_box.add_theme_constant_override("separation", 6)
    card.add_child(text_box)

    var unit_level: int = 1
    for u_entry in GameState.bianwu_units:
        if u_entry is Dictionary and str(u_entry.get("id", "")) == unit_id:
            unit_level = int(u_entry.get("level", 1))
            break

    if card_mode == "management":
        var top_row: = HBoxContainer.new()
        top_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        top_row.add_theme_constant_override("separation", 6)
        text_box.add_child(top_row)

        var management_level: = Label.new()
        management_level.text = "Lv.%d" % unit_level
        management_level.add_theme_font_override("font", FontLoader.serif_bold())
        management_level.add_theme_font_size_override("font_size", 12)
        management_level.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
        management_level.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
        top_row.add_child(management_level)

        var top_spacer: = Control.new()
        top_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        top_row.add_child(top_spacer)

        if show_actions:
            var edit_icon_btn: = _make_bianwu_unit_icon_button(UNIT_RENAME_ICON, "自定义名称")
            edit_icon_btn.pressed.connect( func():
                _show_unit_rename_dialog(idx, base_name)
            )
            top_row.add_child(edit_icon_btn)

            var upgrade_icon_btn: = _make_bianwu_unit_icon_button(UNIT_UPGRADE_ICON, "升级")
            upgrade_icon_btn.pressed.connect( func():
                _show_unit_upgrade_dialog(idx)
            )
            top_row.add_child(upgrade_icon_btn)

        var management_name: = Label.new()
        management_name.text = _format_bianwu_force_card_name(base_name, serial)
        management_name.add_theme_font_override("font", FontLoader.serif_bold())
        management_name.add_theme_font_size_override("font_size", 16)
        management_name.add_theme_color_override("font_color", _left_panel_text_color("text_main"))
        management_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
        management_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        text_box.add_child(management_name)

        var management_spacer: = Control.new()
        management_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
        text_box.add_child(management_spacer)

        text_box.add_child(_make_bianwu_force_amount_row(unit_def, amount, 13))
        return card

    var first_row: = HBoxContainer.new()
    first_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    first_row.add_theme_constant_override("separation", 6)
    text_box.add_child(first_row)

    var name_label: = Label.new()
    name_label.text = _format_bianwu_force_card_name(base_name, serial)
    name_label.add_theme_font_override("font", FontLoader.serif_bold())
    name_label.add_theme_font_size_override("font_size", 13)
    name_label.add_theme_color_override("font_color", _left_panel_text_color("text_main"))
    name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    first_row.add_child(name_label)

    var level_label: = Label.new()
    level_label.text = "Lv.%d" % unit_level
    level_label.add_theme_font_override("font", FontLoader.serif_bold())
    level_label.add_theme_font_size_override("font_size", 11)
    level_label.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    first_row.add_child(level_label)

    if show_actions:
        var edit_btn: = _make_bianwu_unit_icon_button(UNIT_RENAME_ICON, "自定义名称")
        edit_btn.pressed.connect( func():
            _show_unit_rename_dialog(idx, base_name)
        )
        first_row.add_child(edit_btn)

        var upgrade_btn: = _make_bianwu_unit_icon_button(UNIT_UPGRADE_ICON, "升级")
        upgrade_btn.pressed.connect( func():
            _show_unit_upgrade_dialog(idx)
        )
        first_row.add_child(upgrade_btn)

    text_box.add_child(_make_bianwu_force_amount_row(unit_def, amount, 12))
    if card_mode == "sidebar":
        card.gui_input.connect(_on_bianwu_force_card_gui_input.bind(card, idx))
        card.mouse_entered.connect(_show_bianwu_unit_hover_hint.bind(card, idx))
        card.mouse_exited.connect(_hide_bianwu_unit_hover_hint.bind(card))
    return card

func _on_bianwu_force_card_gui_input(event: InputEvent, card: Control, idx: int) -> void :
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
        _show_bianwu_unit_detail_popup(card, idx)

func _show_bianwu_unit_detail_popup(anchor: Control, idx: int, is_hover: bool = false) -> void :
    if idx < 0 or idx >= GameState.bianwu_units.size():
        return
    var entry = GameState.bianwu_units[idx]
    if not (entry is Dictionary):
        return
    var unit_id: = str(entry.get("id", ""))
    var unit_def: Dictionary = BattleTypesRef.unit_def(unit_id)
    var unit_name: = str(entry.get("name", unit_def.get("name", unit_id)))
    var kind: = "家丁" if bool(entry.get("is_jiading", false)) else "官军"
    var lines: Array[String] = []
    lines.append(unit_name)
    lines.append("%s　Lv.%d" % [kind, int(entry.get("level", 1))])
    lines.append("")
    lines.append("兵力 %d　攻击 %d" % [int(entry.get("hp", unit_def.get("hp", 0))), int(unit_def.get("atk", 10))])
    lines.append("士气 %s　补给 %s" % [
        BianwuDefenseServiceRef.morale_label(int(entry.get("morale", 60))), 
        str(entry.get("supply", "充足")), 
    ])
    Presenter._show_item_hint_card(anchor, "\n".join(lines), _is_mobile_portrait(), is_hover)
    _bianwu_unit_hover_hint_anchor = anchor if is_hover else null

func _show_bianwu_unit_hover_hint(anchor: Control, idx: int) -> void :
    if DisplayServer.is_touchscreen_available():
        return
    _show_bianwu_unit_detail_popup(anchor, idx, true)

func _hide_bianwu_unit_hover_hint(anchor: Control) -> void :
    if _bianwu_unit_hover_hint_anchor == anchor:
        Presenter._hide_item_hint_card(true)
        _bianwu_unit_hover_hint_anchor = null

func _show_bianwu_officer_detail_popup(anchor: Control, officer_index: int, is_hover: bool = false) -> void :
    if officer_index < 0 or officer_index >= GameState.bianwu_defense_officers.size():
        return
    var officer: Dictionary = GameState.bianwu_defense_officers[officer_index]
    var lines: Array[String] = []
    lines.append(str(officer.get("name", "人物")))
    var sub_parts: Array[String] = []
    for key in ["role", "specialty"]:
        var value: = str(officer.get(key, "")).strip_edges()
        if value != "":
            sub_parts.append(value)
    lines.append(" · ".join(sub_parts))
    lines.append("")
    var relation: = str(officer.get("relation", "")).strip_edges()
    if relation != "":
        lines.append("关系：%s" % relation)
    var loyalty: = int(officer.get("loyalty", 60))
    lines.append("忠诚：%s（%d）" % [BianwuDefenseServiceRef.loyalty_label(loyalty), loyalty])
    var monthly_effect: = str(officer.get("monthly_effect", "")).strip_edges()
    if monthly_effect != "":
        lines.append("加值：%s" % monthly_effect.trim_prefix("每月："))
    Presenter._show_item_hint_card(anchor, "\n".join(lines), _is_mobile_portrait(), is_hover)
    _bianwu_officer_hover_hint_anchor = anchor if is_hover else null

func _show_bianwu_officer_hover_hint(anchor: Control, officer_index: int) -> void :
    _show_bianwu_officer_detail_popup(anchor, officer_index, true)

func _hide_bianwu_officer_hover_hint(anchor: Control) -> void :
    if _bianwu_officer_hover_hint_anchor == anchor:
        Presenter._hide_item_hint_card(true)
        _bianwu_officer_hover_hint_anchor = null

func _dismiss_bianwu_hover_hints() -> void :
    Presenter._hide_item_hint_card(true)
    _bianwu_unit_hover_hint_anchor = null
    _bianwu_officer_hover_hint_anchor = null

func _make_bianwu_force_amount_row(unit_def: Dictionary, amount: int, font_size: int) -> Control:
    var second_row: = HBoxContainer.new()
    second_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    var atk_container: = HBoxContainer.new()
    atk_container.add_theme_constant_override("separation", 4)
    second_row.add_child(atk_container)

    var atk_icon: = TextureRect.new()
    atk_icon.texture = load("res://assets/ui/status_icons/攻击力.svg")
    atk_icon.custom_minimum_size = Vector2(14, 14)
    atk_icon.ignore_texture_size = true
    atk_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    atk_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    atk_icon.modulate = Color.WHITE
    atk_container.add_child(atk_icon)

    var atk_value: = int(unit_def.get("atk", 10))
    var atk_label: = Label.new()
    atk_label.text = str(atk_value)
    atk_label.add_theme_font_override("font", FontLoader.serif_bold())
    atk_label.add_theme_font_size_override("font_size", font_size)
    atk_label.add_theme_color_override("font_color", _left_panel_text_color("text_main"))
    atk_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    atk_container.add_child(atk_label)

    var spacer: = Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    second_row.add_child(spacer)

    var strength: = Label.new()
    strength.text = _format_large_number(amount)
    strength.add_theme_font_override("font", FontLoader.serif_bold())
    strength.add_theme_font_size_override("font_size", font_size + 1)
    strength.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    strength.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    second_row.add_child(strength)

    return second_row

func _make_bianwu_unit_icon_button(icon_texture: Texture2D, tooltip: String) -> Button:
    var btn: = Button.new()
    btn.focus_mode = Control.FOCUS_NONE
    btn.custom_minimum_size = Vector2(20, 20)
    btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    btn.tooltip_text = tooltip
    btn.clip_contents = false
    var normal: = StyleBoxEmpty.new()
    var hover: = StyleBoxEmpty.new()
    btn.add_theme_stylebox_override("normal", normal)
    btn.add_theme_stylebox_override("hover", hover)
    btn.add_theme_stylebox_override("pressed", hover)
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

    var icon: = TextureRect.new()
    icon.texture = icon_texture
    icon.custom_minimum_size = Vector2(18, 18)
    icon.ignore_texture_size = true
    icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
    icon.modulate = Color(1, 1, 1, 0.96)
    icon.set_anchors_preset(Control.PRESET_CENTER)
    icon.grow_horizontal = Control.GROW_DIRECTION_BOTH
    icon.grow_vertical = Control.GROW_DIRECTION_BOTH
    btn.add_child(icon)
    return btn

func _format_bianwu_force_card_name(base_name: String, serial: int) -> String:
    return base_name

func _show_bianwu_buqu_management_modal() -> void :
    var existing: = get_node_or_null("BianwuBuquManagementModal")
    if existing:
        existing.queue_free()

    var layer: = Control.new()
    layer.name = "BianwuBuquManagementModal"
    layer.set_anchors_preset(Control.PRESET_FULL_RECT)
    layer.mouse_filter = Control.MOUSE_FILTER_STOP
    layer.z_index = 980
    add_child(layer)

    var overlay_bg: = ColorRect.new()
    overlay_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay_bg.color = Color(0.0, 0.0, 0.0, 0.78)
    layer.add_child(overlay_bg)

    var margin: = MarginContainer.new()
    margin.set_anchors_preset(Control.PRESET_FULL_RECT)
    var compact: = _is_mobile_portrait()
    var pad_x: = 0
    var pad_y: = 0
    margin.add_theme_constant_override("margin_left", pad_x)
    margin.add_theme_constant_override("margin_right", pad_x)
    margin.add_theme_constant_override("margin_top", pad_y)
    margin.add_theme_constant_override("margin_bottom", pad_y)
    layer.add_child(margin)

    var panel: = PanelContainer.new()
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    var panel_style: = StyleBoxFlat.new()
    panel_style.bg_color = GameState.get_theme_color("bg_popup")
    panel_style.border_color = Color(0.42, 0.43, 0.44, 0.72)
    panel_style.set_border_width_all(1)
    panel_style.corner_radius_top_left = 0;panel_style.corner_radius_top_right = 0
    panel_style.corner_radius_bottom_left = 0;panel_style.corner_radius_bottom_right = 0
    panel_style.shadow_color = Color(0, 0, 0, 0.65)
    panel_style.shadow_size = 0
    panel.add_theme_stylebox_override("panel", panel_style)
    margin.add_child(panel)

    var content_margin: = MarginContainer.new()
    var inner_pad: = 18 if compact else 28
    content_margin.add_theme_constant_override("margin_left", inner_pad)
    content_margin.add_theme_constant_override("margin_right", inner_pad)
    content_margin.add_theme_constant_override("margin_top", inner_pad)
    content_margin.add_theme_constant_override("margin_bottom", inner_pad)
    panel.add_child(content_margin)

    var box: = VBoxContainer.new()
    box.name = "BianwuBuquManagementContent"
    box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    box.size_flags_vertical = Control.SIZE_EXPAND_FILL
    box.add_theme_constant_override("separation", 14)
    content_margin.add_child(box)

    var header: = HBoxContainer.new()
    header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_theme_constant_override("separation", 12)
    box.add_child(header)

    var title: = Label.new()
    title.text = "部曲管理"
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", 20 if compact else 22)
    title.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)

    var close_btn: = Button.new()
    close_btn.text = "关闭"
    close_btn.focus_mode = Control.FOCUS_NONE
    close_btn.custom_minimum_size = Vector2(92, 40)
    _apply_global_modal_command_button_style(close_btn)
    close_btn.pressed.connect( func(): layer.queue_free())
    header.add_child(close_btn)

    var scroll: = ScrollContainer.new()
    scroll.name = "BianwuBuquManagementScroll"
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    box.add_child(scroll)

    var list: = VBoxContainer.new()
    list.name = "BianwuBuquManagementList"
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list.add_theme_constant_override("separation", 24)
    scroll.add_child(list)
    _populate_bianwu_buqu_management_list(list)

func _ensure_bianwu_defense_button() -> void :
    var existing: = governance_vbox.get_node_or_null("BianwuDefenseButton") as Button
    if GameData.active_line != "bianwu":
        if is_instance_valid(existing):
            existing.visible = false
        return
    BianwuDefenseServiceRef.ensure_initialized(GameState)


    if _is_mobile_portrait():
        if not is_instance_valid(existing):
            existing = Button.new()
            existing.name = "BianwuDefenseButton"
            existing.focus_mode = Control.FOCUS_NONE
            existing.custom_minimum_size = Vector2(0, 44)
            existing.pressed.connect(_show_bianwu_defense_map)
            governance_vbox.add_child(existing)
            governance_vbox.move_child(existing, mini(action_points_row.get_index() + 1, governance_vbox.get_child_count() - 1))
        existing.visible = true
        existing.text = "防区沙盘　行动力 %d/%d" % [GameState.action_points, GameState.monthly_action_points()]
    elif is_instance_valid(existing):
        existing.visible = false

func _show_bianwu_defense_map() -> void :
    if GameData.active_line != "bianwu":
        return
    BianwuDefenseServiceRef.ensure_initialized(GameState)
    var old: = get_node_or_null("BianwuDefenseMapModal")
    if old:
        old.queue_free()
    var layer: = Control.new()
    layer.name = "BianwuDefenseMapModal"
    layer.set_anchors_preset(Control.PRESET_FULL_RECT)
    layer.mouse_filter = Control.MOUSE_FILTER_STOP
    layer.clip_contents = true
    layer.z_index = 985
    add_child(layer)
    var dim: = ColorRect.new()
    dim.set_anchors_preset(Control.PRESET_FULL_RECT)
    dim.color = Color(0, 0, 0, 0.82)
    layer.add_child(dim)
    var margin: = MarginContainer.new()
    margin.set_anchors_preset(Control.PRESET_FULL_RECT)
    var outer_pad: = 0
    for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
        margin.add_theme_constant_override(side, outer_pad)
    layer.add_child(margin)
    var panel: = PanelContainer.new()
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    var panel_style: = StyleBoxFlat.new()
    panel_style.bg_color = GameState.get_theme_color("bg_popup")
    panel_style.set_border_width_all(0)
    panel_style.set_corner_radius_all(0)
    panel.add_theme_stylebox_override("panel", panel_style)
    margin.add_child(panel)
    var root_box: = VBoxContainer.new()
    root_box.add_theme_constant_override("separation", 0)
    panel.add_child(root_box)
    var header: = HBoxContainer.new()
    header.custom_minimum_size.y = 62
    header.add_theme_constant_override("separation", 16)
    root_box.add_child(header)
    var header_left: = Control.new()
    header_left.custom_minimum_size.x = 24
    header.add_child(header_left)
    var map_cfg: Dictionary = GameData.LINES.get("bianwu", {}).get("defense_maps_by_act", {}).get(str(GameState.bianwu_defense_act), {})
    var title: = Label.new()
    title.text = "%s　行动力 %d/%d" % [str(map_cfg.get("title", "防区沙盘")), GameState.action_points, GameState.monthly_action_points()]
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", 20)
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)
    var legend: = Label.new()
    legend.text = "绿界·安定　金界·戒备　赤界·叛乱"
    legend.add_theme_font_size_override("font_size", 13)
    legend.add_theme_color_override("font_color", Color(0.7, 0.62, 0.45, 0.88))
    legend.tooltip_text = "绿色为安定控制区，土黄为不安地区，红色为敌情或叛乱占据的局部地块。"
    header.add_child(legend)
    var close_btn: = Button.new()
    close_btn.text = "返回"
    close_btn.icon = load("res://assets/ui/back.svg")
    close_btn.expand_icon = false
    close_btn.focus_mode = Control.FOCUS_NONE
    close_btn.custom_minimum_size = Vector2(128, 42)
    close_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    close_btn.add_theme_font_size_override("font_size", 16)
    close_btn.add_theme_constant_override("icon_max_width", 16)
    close_btn.add_theme_constant_override("h_separation", 6)
    close_btn.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    close_btn.add_theme_color_override("font_hover_color", GameState.get_theme_color("border_active"))
    close_btn.add_theme_color_override("font_pressed_color", GameState.get_theme_color("border_active"))
    close_btn.add_theme_color_override("font_focus_color", GameState.get_theme_color("text_sub"))
    close_btn.add_theme_stylebox_override("normal", GameScreenStyleFactory.modal_return_button_style("normal"))
    close_btn.add_theme_stylebox_override("hover", GameScreenStyleFactory.modal_return_button_style("hover"))
    close_btn.add_theme_stylebox_override("pressed", GameScreenStyleFactory.modal_return_button_style("pressed"))
    close_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    close_btn.pressed.connect( func(): layer.queue_free())
    header.add_child(close_btn)
    var header_right: = Control.new()
    header_right.custom_minimum_size.x = 18
    header.add_child(header_right)
    if not GameState.bianwu_defense_warnings.is_empty():
        var warning_box: = VBoxContainer.new()
        warning_box.add_theme_constant_override("separation", 3)
        root_box.add_child(warning_box)
        for warning in GameState.bianwu_defense_warnings:
            var warning_label: = Label.new()
            warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            warning_label.text = "军情预警：" + str(warning.get("text", "防区外似有异动。"))
            warning_label.add_theme_color_override("font_color", Color(0.82, 0.38, 0.24))
            warning_box.add_child(warning_label)
    var body: BoxContainer = VBoxContainer.new() if _is_mobile_portrait() else HBoxContainer.new()
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 0)
    root_box.add_child(body)
    var map_scroll: = ScrollContainer.new()
    map_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    map_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    map_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO if _is_mobile_portrait() else ScrollContainer.SCROLL_MODE_DISABLED
    map_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO if _is_mobile_portrait() else ScrollContainer.SCROLL_MODE_DISABLED
    body.add_child(map_scroll)
    var detail_panel: = PanelContainer.new()
    detail_panel.custom_minimum_size = Vector2(0, 230) if _is_mobile_portrait() else Vector2(350, 0)
    detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL if _is_mobile_portrait() else Control.SIZE_SHRINK_END
    detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    detail_panel.clip_contents = true
    var detail_style: = StyleBoxFlat.new()
    detail_style.bg_color = Color(0.055, 0.047, 0.035, 0.98)
    detail_style.border_color = Color(0.55, 0.43, 0.23, 0.55)
    detail_style.border_width_left = 1
    detail_style.content_margin_left = 22
    detail_style.content_margin_right = 22
    detail_style.content_margin_top = 20
    detail_style.content_margin_bottom = 20
    detail_panel.add_theme_stylebox_override("panel", detail_style)
    body.add_child(detail_panel)
    var detail_scroll: = ScrollContainer.new()
    detail_scroll.custom_minimum_size = Vector2(0, 210)
    detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    detail_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
    detail_panel.add_child(detail_scroll)
    var detail_box: = VBoxContainer.new()
    detail_box.name = "BianwuRegionDetailBox"
    detail_box.custom_minimum_size.x = 0
    detail_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_box.add_theme_constant_override("separation", 8)
    detail_scroll.add_child(detail_box)
    var selected_id: = BianwuDefenseServiceRef.default_region_id(GameState)
    _render_bianwu_defense_map(map_scroll, detail_box, layer)
    if selected_id != "":
        _show_bianwu_region_detail(selected_id, detail_box, layer, detail_scroll)

func _render_bianwu_defense_map(map_scroll: ScrollContainer, detail_box: VBoxContainer, layer: Control) -> void :
    var hex_map = BianwuHexMapRef.new()
    hex_map.name = "BianwuHexMap"
    hex_map.custom_minimum_size = Vector2(980, 650) if not _is_mobile_portrait() else Vector2(760, 520)
    hex_map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hex_map.size_flags_vertical = Control.SIZE_EXPAND_FILL
    hex_map.region_selected.connect(_on_bianwu_hex_region_selected.bind(detail_box, layer))
    hex_map.gui_input.connect(_on_bianwu_defense_node_gui_input.bind(map_scroll))
    map_scroll.add_child(hex_map)
    var selected_id: = BianwuDefenseServiceRef.default_region_id(GameState)
    hex_map.setup(GameState.bianwu_defense_regions, GameState.bianwu_defense_enemies, GameState.bianwu_units, selected_id)

func _on_bianwu_hex_region_selected(region_id: String, detail_box: VBoxContainer, layer: Control) -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(self, "bianwu_defense_scroll_suppress_until_ms"):
        return
    _show_bianwu_region_detail(region_id, detail_box, layer)

func _on_bianwu_defense_node_gui_input(event: InputEvent, map_scroll: ScrollContainer) -> void :
    NativeMobileTouchScrollRef.forward_drag_to_scroll(event, map_scroll, self, "bianwu_defense_scroll_suppress_until_ms")




func _bw_detail_font(base: int, layer: Control) -> int:
    if is_instance_valid(_bw_defense_detail_layer) and layer == _bw_defense_detail_layer:
        return maxi(1, roundi(float(base) * BIANWU_DETAIL_PANEL_SCALE))
    return base

func _show_bianwu_region_detail(region_id: String, detail_box: VBoxContainer, layer: Control, detail_scroll: ScrollContainer = null) -> void :
    for child in detail_box.get_children():
        child.queue_free()
    var region: Dictionary = {}
    for candidate in GameState.bianwu_defense_regions:
        if str(candidate.get("id", "")) == region_id:
            region = candidate
            break
    if region.is_empty():
        return
    var effective_scroll: = detail_scroll
    if effective_scroll == null and detail_box.get_parent() is ScrollContainer:
        effective_scroll = detail_box.get_parent() as ScrollContainer
    if effective_scroll != null:
        effective_scroll.scroll_vertical = 0
        effective_scroll.set_deferred("scroll_vertical", 0)
    var heading: = Label.new()
    heading.text = str(region.get("name", ""))
    heading.add_theme_font_override("font", FontLoader.serif_bold())
    heading.add_theme_font_size_override("font_size", _bw_detail_font(19, layer))
    detail_box.add_child(heading)
    var allows_deployment: = bool(region.get("allows_deployment", true))
    if not allows_deployment:
        var city_info: = Label.new()
        city_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        city_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        city_info.add_theme_font_size_override("font_size", _bw_detail_font(16, layer))
        if region_id == "bw1_baoding_city":
            city_info.text = "城池\n北直隶府城，大宁都司与保定诸卫的军政中枢。\n\n城防\n由大宁都司及保定诸卫驻军维持，无须派驻本部兵马。\n\n城内机构\n大宁都指挥使司、保定府署、保定左卫署、保定右卫署、保定中卫署、茂山卫署。\n\n接界\n与右卫百户所、驿道粮站接界。"
        else:
            city_info.text = "类型：%s\n设施：%s\n\n此地由既有驻防体系管理，无须派驻本部兵马。" % [str(region.get("type", "驻防地区")), str(region.get("facility", "无"))]
        detail_box.add_child(city_info)
        return
    var info: = Label.new()
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    info.add_theme_font_size_override("font_size", _bw_detail_font(16, layer))
    var region_supply: = {"actual_grain": int(region.get("base_grain", 0)), "actual_silver": int(region.get("base_silver", 0)), "shuban_grain_bonus": 0, "shuban_silver_bonus": 0}
    for supply_entry in BianwuDefenseServiceRef.calculate_regional_supply(GameState).get("regions", []):
        if str(supply_entry.get("region_id", "")) == region_id:
            region_supply = supply_entry
            break
    var supply_source: = "（含书办加成：粮草%d、饷银%d）" % [int(region_supply.shuban_grain_bonus), int(region_supply.shuban_silver_bonus)] if int(region_supply.shuban_grain_bonus) > 0 or int(region_supply.shuban_silver_bonus) > 0 else ""
    var control_text: = "官军"
    match str(region.get("control", "player")):
        "enemy":
            control_text = "贼据"
        "player":
            control_text = "官军"
        _:
            control_text = "失控"
    var stronghold_line: = ""
    if BianwuDefenseServiceRef.region_fortified(region):
        stronghold_line = "\n据点：%s（有垒，守方得地利）" % ("官军把守" if BianwuDefenseServiceRef.stronghold_holder(region) == "player" else "贼军盘踞")
    info.text = "安定度：%d（%s）\n控制：%s%s\n设施：%s\n问题：%s\n每月应供：粮草 %d　饷银 %d%s" % [int(region.get("stability", 60)), BianwuDefenseServiceRef.stability_label(int(region.get("stability", 60))), control_text, stronghold_line, str(region.get("facility", "无")), str(region.get("problem", "无")) if str(region.get("problem", "")) != "" else "无", int(region_supply.actual_grain), int(region_supply.actual_silver), supply_source]
    detail_box.add_child(info)
    var region_has_enemy: = false
    for enemy in GameState.bianwu_defense_enemies:
        if str(enemy.get("region_id", "")) == region_id:
            region_has_enemy = true
            var enemy_label: = Label.new()
            enemy_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            enemy_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            enemy_label.add_theme_font_size_override("font_size", _bw_detail_font(16, layer))
            var enemy_target: = _bianwu_region_name(str(enemy.get("target_region_id", "")))
            var enemy_text: = "敌情：%s约%d人，%s" % [str(enemy.get("name", "敌军")), int(enemy.get("size", 0)), str(enemy.get("status", "活动中"))]
            if str(enemy.get("target_region_id", "")) != "":
                enemy_text += "，目标%s" % enemy_target
            enemy_label.text = enemy_text
            detail_box.add_child(enemy_label)
    if region_has_enemy:
        var context: Dictionary = BianwuDefenseServiceRef.battle_context(GameState, region_id, "player")
        var context_label: = Label.new()
        context_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        context_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        context_label.add_theme_font_size_override("font_size", _bw_detail_font(15, layer))
        context_label.add_theme_color_override("font_color", Color(0.82, 0.68, 0.46))
        context_label.text = "若兴兵进剿，将是一场%s：%s" % [str(context.get("type", "野战")), str(context.get("desc", ""))]
        detail_box.add_child(context_label)

    if allows_deployment:
        _bianwu_deployment_slot_controller.render_region_slots(region_id, detail_box, layer, detail_scroll)

func _bianwu_region_name(region_id: String) -> String:
    for region in GameState.bianwu_defense_regions:
        if str(region.get("id", "")) == region_id:
            return str(region.get("name", "未知地区"))
    return "未知地区"


var _bw_battle_running: = false


func _apply_bianwu_battle_resources(cfg: Dictionary) -> void :
    var houqin: int = GameState.get_city_stat_level("houqin")
    var qingbao: int = GameState.get_city_stat_level("qingbao")
    if not cfg.has("intel"):
        cfg["intel"] = 0 if qingbao < 3 else (1 if qingbao < 7 else 2)
    if not cfg.has("ammo"):
        cfg["ammo"] = clampi(6 + int(round(houqin * 0.6)), 6, 14)
    if not cfg.has("skills") and "bianwu_skills" in GameState and not GameState.bianwu_skills.is_empty():
        cfg["skills"] = GameState.bianwu_skills.duplicate()


var _bw_muster_layer: Control = null

func _close_bianwu_assault_muster() -> void :
    if is_instance_valid(_bw_muster_layer):
        _bw_muster_layer.queue_free()
    _bw_muster_layer = null

func _show_bianwu_assault_muster(region_id: String, layer: Control) -> void :
    if _bw_battle_running:
        return
    _close_bianwu_assault_muster()
    var candidates: Array = BianwuDefenseServiceRef.muster_candidates(GameState, region_id)
    if candidates.is_empty():
        return
    var officers: Array = BianwuDefenseServiceRef.muster_officers(GameState, region_id)
    var muster_layer: = Control.new()
    muster_layer.name = "BianwuMusterLayer"
    muster_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
    muster_layer.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(muster_layer)
    _bw_muster_layer = muster_layer
    var dim: = ColorRect.new()
    dim.color = Color(0, 0, 0, 0.55)
    dim.set_anchors_preset(Control.PRESET_FULL_RECT)
    dim.mouse_filter = Control.MOUSE_FILTER_STOP
    muster_layer.add_child(dim)
    var center_container: = CenterContainer.new()
    center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
    center_container.mouse_filter = Control.MOUSE_FILTER_PASS
    muster_layer.add_child(center_container)
    var panel: = PanelContainer.new()
    var panel_style: = StyleBoxFlat.new()
    panel_style.bg_color = Color(0.055, 0.048, 0.036, 0.97)
    panel_style.border_color = Color(0.72, 0.56, 0.28, 0.4)
    panel_style.set_border_width_all(1)
    panel_style.set_corner_radius_all(8)
    panel_style.set_content_margin_all(20)
    panel.add_theme_stylebox_override("panel", panel_style)
    panel.custom_minimum_size = Vector2(440, 0)
    center_container.add_child(panel)
    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 10)
    panel.add_child(vbox)
    var title: = Label.new()
    title.text = "点兵进剿·%s" % _bianwu_region_name(region_id)
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", 19)
    title.add_theme_color_override("font_color", Color(0.92, 0.83, 0.62))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)

    var apply_cb_style: = func(cb: CheckBox) -> void :
        var empty_style: = StyleBoxEmpty.new()
        cb.add_theme_stylebox_override("normal", empty_style)
        cb.add_theme_stylebox_override("hover", empty_style)
        cb.add_theme_stylebox_override("pressed", empty_style)
        cb.add_theme_stylebox_override("focus", empty_style)
        cb.add_theme_stylebox_override("hover_pressed", empty_style)
        cb.add_theme_color_override("font_color", Color(0.77, 0.65, 0.35))
        cb.add_theme_color_override("font_hover_color", Color(0.91, 0.83, 0.55))
        cb.add_theme_color_override("font_pressed_color", Color(0.96, 0.9, 0.78))
        cb.add_theme_color_override("font_focus_color", Color(0.77, 0.65, 0.35))

    var unit_toggles: Array = []
    for candidate in candidates:
        var unit: Dictionary = candidate.get("unit", {})
        var toggle: = CheckBox.new()
        toggle.text = "%s　兵力%d　士气%d　现驻%s" % [str(unit.get("name", "部队")), int(unit.get("hp", 0)), int(unit.get("morale", 65)), _bianwu_region_name(str(unit.get("region_id", "")))]
        toggle.add_theme_font_size_override("font_size", 14)
        apply_cb_style.call(toggle)
        toggle.button_pressed = bool(candidate.get("in_region", false))
        vbox.add_child(toggle)
        unit_toggles.append({"toggle": toggle, "card_id": str(unit.get("deployment_card_id", ""))})
    var officer_toggle: CheckBox = null
    if not officers.is_empty():
        var officer: Dictionary = officers[0].get("officer", {})
        officer_toggle = CheckBox.new()
        officer_toggle.text = "武官督战：%s（武略 +8，胜败皆全身而退）" % str(officer.get("name", "武官"))
        officer_toggle.add_theme_font_size_override("font_size", 14)
        apply_cb_style.call(officer_toggle)
        officer_toggle.button_pressed = true
        vbox.add_child(officer_toggle)
    var button_row: = HBoxContainer.new()
    button_row.alignment = BoxContainer.ALIGNMENT_CENTER
    button_row.add_theme_constant_override("separation", 16)
    vbox.add_child(button_row)
    var confirm: = Button.new()
    confirm.text = "出战　-1 行动力"
    confirm.custom_minimum_size = Vector2(180, 40)
    confirm.pressed.connect( func():
        var selected_ids: Array = []
        for entry in unit_toggles:
            if (entry.get("toggle") as CheckBox).button_pressed:
                selected_ids.append(str(entry.get("card_id", "")))
        if selected_ids.is_empty():
            return
        var with_officer: bool = officer_toggle != null and officer_toggle.button_pressed
        var begun: Dictionary = BianwuDefenseServiceRef.begin_assault(GameState, region_id, selected_ids, with_officer)
        if not bool(begun.get("ok", false)):
            return
        _close_bianwu_assault_muster()
        _launch_bianwu_sandbox_battle(region_id, "player", begun.get("config", {}), layer, selected_ids))
    button_row.add_child(confirm)
    var cancel: = Button.new()
    cancel.text = "关闭"
    cancel.custom_minimum_size = Vector2(120, 40)
    cancel.pressed.connect(_close_bianwu_assault_muster)
    button_row.add_child(cancel)

func _launch_bianwu_sandbox_battle(region_id: String, initiator: String, cfg: Dictionary, layer: Control, participants: Array = []) -> void :
    _apply_bianwu_battle_resources(cfg)
    var main = get_tree().current_scene
    if main == null or not main.has_method("request_battle"):

        BianwuDefenseServiceRef.resolve_battle(GameState, region_id, initiator, "pyrrhic", participants)
        _after_bianwu_sandbox_battle(region_id, "pyrrhic", layer)
        return
    _bw_battle_running = true
    main.request_battle(cfg, func(grade: String):
        _bw_battle_running = false
        BianwuDefenseServiceRef.resolve_battle(GameState, region_id, initiator, grade, participants)
        _after_bianwu_sandbox_battle(region_id, grade, layer))

func _after_bianwu_sandbox_battle(region_id: String, grade: String, layer: Control) -> void :

    var reward_zhanyi: = 8 if grade == "great" else (-3 if grade == "fail" else 3)
    var merit_val: = 100 + 100 * maxi(1, GameState.get_current_governance_act())
    var merit_gain: = merit_val if grade == "great" else (0 if grade == "fail" else int(round(merit_val * 0.6)))
    if GameState.city and not GameState.city.is_empty():
        GameState.city["zhanyi"] = maxi(0, int(GameState.city.get("zhanyi", 0)) + reward_zhanyi)
        if merit_gain > 0:
            GameState.city["zhengji"] = int(GameState.city.get("zhengji", 0)) + merit_gain
    GameState.state_changed.emit()
    _update_bianwu_defense_backdrop()
    if is_instance_valid(_bw_defense_detail_layer) and is_instance_valid(_bw_defense_detail_box) and _bw_defense_detail_layer.visible:
        _show_bianwu_region_detail(region_id, _bw_defense_detail_box, _bw_defense_detail_layer, _bw_defense_detail_box.get_parent() as ScrollContainer)
    _schedule_month_advance_after_settle()


func _maybe_launch_bianwu_pending_battle() -> void :
    if _bw_battle_running:
        return
    if not GameState.has_meta(BianwuDefenseServiceRef.PENDING_BATTLE_META):
        return
    var pending: Dictionary = GameState.get_meta(BianwuDefenseServiceRef.PENDING_BATTLE_META)
    var region_id: = str(pending.get("region_id", ""))
    if region_id == "":
        GameState.remove_meta(BianwuDefenseServiceRef.PENDING_BATTLE_META)
        return
    var cfg: Dictionary = BianwuDefenseServiceRef.build_battle_config(GameState, region_id, "enemy")
    if (cfg.get("player_units", []) as Array).is_empty():

        BianwuDefenseServiceRef.resolve_battle(GameState, region_id, "enemy", "fail")
        GameState.state_changed.emit()
        return
    _launch_bianwu_sandbox_battle(region_id, "enemy", cfg, _bw_defense_detail_layer)

func _on_bianwu_deployment_result(result: Dictionary, region_id: String, layer: Control) -> void :
    if bool(result.get("ok", false)):
        GameState.state_changed.emit()
        _schedule_month_advance_after_settle()
        _ensure_bianwu_defense_button()
        _update_bianwu_defense_backdrop()
        if is_instance_valid(layer):
            var modal_map: = layer.find_child("BianwuHexMap", true, false) as BianwuHexMap
            if modal_map != null:
                modal_map.setup(GameState.bianwu_defense_regions, GameState.bianwu_defense_enemies, GameState.bianwu_units, region_id)
    if is_instance_valid(_bw_defense_detail_layer) and layer == _bw_defense_detail_layer and is_instance_valid(_bw_defense_detail_box):
        _show_bianwu_region_detail(region_id, _bw_defense_detail_box, layer, _bw_defense_detail_box.get_parent() as ScrollContainer)
        return
    if is_instance_valid(layer):
        var detail_box: = layer.find_child("BianwuRegionDetailBox", true, false) as VBoxContainer
        if detail_box != null:
            _show_bianwu_region_detail(region_id, detail_box, layer, detail_box.get_parent() as ScrollContainer)





var _bw_defense_backdrop: Control = null
var _bw_defense_backdrop_map: BianwuHexMap = null
var _bw_defense_detail_layer: Control = null
var _bw_defense_detail_box: VBoxContainer = null
var _bw_defense_selected_region_id: = ""
var _bw_defense_map_offset: = Vector2.INF
var _bw_backdrop_dragging: = false
var _bw_backdrop_drag_accum: = 0.0
var _bianwu_officer_hover_hint_anchor: Control = null
var _bianwu_unit_hover_hint_anchor: Control = null

func _is_bianwu_defense_backdrop_active() -> bool:
    return GameData.active_line == "bianwu" and not _is_mobile_portrait()\
and GameState.is_governance_mode() and governance_active_card_index < 0\
and is_instance_valid(governance_scroll) and governance_scroll.visible

func _bianwu_region_id_exists(region_id: String) -> bool:
    if region_id == "":
        return false
    for region in GameState.bianwu_defense_regions:
        if region is Dictionary and str(region.get("id", "")) == region_id:
            return true
    return false

func _resolved_bianwu_selected_region_id(current_id: String) -> String:
    if _bianwu_region_id_exists(current_id):
        return current_id
    return BianwuDefenseServiceRef.default_region_id(GameState)

func _update_bianwu_defense_backdrop() -> void :
    var active: = _is_bianwu_defense_backdrop_active()
    if not active:
        if is_instance_valid(_bw_defense_backdrop):
            _bw_defense_backdrop.visible = false
        if is_instance_valid(_bw_defense_detail_layer):
            _bw_defense_detail_layer.visible = false
        _bw_backdrop_dragging = false
        if is_instance_valid(game_background):
            game_background.visible = true
        return
    BianwuDefenseServiceRef.ensure_initialized(GameState)

    if is_instance_valid(game_background):
        game_background.visible = false
    if not is_instance_valid(_bw_defense_backdrop):
        _bw_defense_backdrop = Control.new()
        _bw_defense_backdrop.name = "BianwuDefenseBackdrop"
        _bw_defense_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
        _bw_defense_backdrop.clip_contents = true
        _bw_defense_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(_bw_defense_backdrop)
        move_child(_bw_defense_backdrop, game_overlay.get_index() + 1)
        _bw_defense_backdrop.resized.connect(_layout_bianwu_defense_backdrop_map)
        var map: = BianwuHexMapRef.new() as BianwuHexMap
        map.name = "BianwuHexMap"
        map.mouse_filter = Control.MOUSE_FILTER_IGNORE
        map.region_selected.connect(_show_bianwu_backdrop_region_detail)
        _bw_defense_backdrop.add_child(map)
        _bw_defense_backdrop_map = map
    _bw_defense_backdrop.visible = true
    _bw_defense_selected_region_id = _resolved_bianwu_selected_region_id(_bw_defense_selected_region_id)
    _bw_defense_backdrop_map.setup(GameState.bianwu_defense_regions, GameState.bianwu_defense_enemies, GameState.bianwu_units, _bw_defense_selected_region_id)
    _layout_bianwu_defense_backdrop_map()

    call_deferred("_maybe_launch_bianwu_pending_battle")

    if is_instance_valid(_bw_defense_detail_layer) and _bw_defense_detail_layer.visible:
        if _bw_defense_selected_region_id != "":
            _show_bianwu_backdrop_region_detail(_bw_defense_selected_region_id)
        else:
            _hide_bianwu_backdrop_region_detail()

func _layout_bianwu_defense_backdrop_map() -> void :
    if not is_instance_valid(_bw_defense_backdrop) or not is_instance_valid(_bw_defense_backdrop_map):
        return
    var vp: Vector2 = _bw_defense_backdrop.size
    if vp.x < 2.0 or vp.y < 2.0:
        vp = get_viewport_rect().size

    var map_size: = Vector2(maxf(vp.x * 1.35, 1280.0), maxf(vp.y * 1.45, 900.0))
    _bw_defense_backdrop_map.size = map_size
    if _bw_defense_map_offset == Vector2.INF:
        _bw_defense_map_offset = (vp - map_size) * 0.5
    _apply_bw_backdrop_map_offset(Vector2.ZERO)

func _apply_bw_backdrop_map_offset(delta: Vector2) -> void :
    if not is_instance_valid(_bw_defense_backdrop) or not is_instance_valid(_bw_defense_backdrop_map):
        return
    var vp: Vector2 = _bw_defense_backdrop.size
    if vp.x < 2.0 or vp.y < 2.0:
        vp = get_viewport_rect().size
    var ms: Vector2 = _bw_defense_backdrop_map.size
    _bw_defense_map_offset += delta
    _bw_defense_map_offset.x = clampf(_bw_defense_map_offset.x, minf(vp.x - ms.x, 0.0), 0.0)
    _bw_defense_map_offset.y = clampf(_bw_defense_map_offset.y, minf(vp.y - ms.y, 0.0), 0.0)
    _bw_defense_backdrop_map.position = _bw_defense_map_offset



func _handle_bianwu_backdrop_gui_input(event: InputEvent) -> bool:
    if not _is_bianwu_defense_backdrop_active() or not is_instance_valid(_bw_defense_backdrop_map):
        return false
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            _bw_backdrop_dragging = true
            _bw_backdrop_drag_accum = 0.0
        elif _bw_backdrop_dragging:
            _bw_backdrop_dragging = false
            if _bw_backdrop_drag_accum <= 6.0:
                var local: Vector2 = _bw_defense_backdrop_map.get_global_transform().affine_inverse() * get_global_mouse_position()


                if not _bw_defense_backdrop_map.select_at_position(local):
                    _hide_bianwu_backdrop_region_detail()
        return true
    if event is InputEventMouseMotion and _bw_backdrop_dragging:
        _bw_backdrop_drag_accum += event.relative.length()
        _apply_bw_backdrop_map_offset(event.relative)
        return true
    return false

func _on_bianwu_backdrop_scroll_gui_input(event: InputEvent) -> void :
    _handle_bianwu_backdrop_gui_input(event)

func _show_bianwu_backdrop_region_detail(region_id: String) -> void :
    if region_id == "":
        return
    var region_changed: = _bw_defense_selected_region_id != region_id
    _bw_defense_selected_region_id = region_id


    if region_changed and GameState.is_governance_mode() and governance_active_card_index < 0:
        _bw_force_deal_animation = true
        _show_governance_overview(true)
    if is_instance_valid(_bw_defense_backdrop_map):
        _bw_defense_backdrop_map.select_region(region_id)
    if not is_instance_valid(_bw_defense_detail_layer):
        _build_bianwu_backdrop_detail_layer()
    _bw_defense_detail_layer.visible = true
    _layout_bianwu_backdrop_detail_layer()
    if is_instance_valid(_bw_defense_detail_box):
        _show_bianwu_region_detail(region_id, _bw_defense_detail_box, _bw_defense_detail_layer)

func _build_bianwu_backdrop_detail_layer() -> void :
    _bw_defense_detail_layer = Control.new()
    _bw_defense_detail_layer.name = "BianwuDefenseDetailLayer"
    _bw_defense_detail_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
    _bw_defense_detail_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

    add_child(_bw_defense_detail_layer)
    var panel: = PanelContainer.new()
    panel.name = "Panel"
    panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
    panel.offset_left = - BIANWU_DETAIL_PANEL_WIDTH
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    var detail_style: = StyleBoxFlat.new()
    detail_style.bg_color = Color(0.055, 0.047, 0.035, 0.98)
    detail_style.border_color = Color(0.55, 0.43, 0.23, 0.55)
    detail_style.border_width_left = 1
    detail_style.content_margin_left = 18
    detail_style.content_margin_right = 18
    detail_style.content_margin_top = 12
    detail_style.content_margin_bottom = 16
    panel.add_theme_stylebox_override("panel", detail_style)
    _bw_defense_detail_layer.add_child(panel)
    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 7)
    panel.add_child(vbox)
    var header_label: = Label.new()
    header_label.text = "防区详情"
    header_label.add_theme_font_size_override("font_size", 11)
    header_label.add_theme_color_override("font_color", Color(0.7, 0.62, 0.45, 0.88))
    header_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.add_child(header_label)
    var detail_scroll: = ScrollContainer.new()
    detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    detail_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
    vbox.add_child(detail_scroll)
    _bw_defense_detail_box = VBoxContainer.new()
    _bw_defense_detail_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _bw_defense_detail_box.add_theme_constant_override("separation", 8)
    detail_scroll.add_child(_bw_defense_detail_box)

    var close_btn: = Button.new()
    close_btn.text = "关闭"
    close_btn.focus_mode = Control.FOCUS_NONE
    close_btn.custom_minimum_size = Vector2(78, 26)
    close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    close_btn.add_theme_font_size_override("font_size", 13)
    close_btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
    close_btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER


    for state in ["normal", "hover", "pressed", "focus"]:
        close_btn.add_theme_stylebox_override(state, _make_bw_detail_close_button_style(state))
    close_btn.pressed.connect(_hide_bianwu_backdrop_region_detail)
    vbox.add_child(close_btn)

func _make_bw_detail_close_button_style(state: String) -> StyleBox:
    if state == "focus":
        return StyleBoxEmpty.new()
    var style: = StyleBoxFlat.new()
    style.set_corner_radius_all(6)
    style.set_border_width_all(1)
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 0
    style.content_margin_bottom = 0
    match state:
        "hover":
            style.bg_color = Color(0.16, 0.1, 0.05, 0.62)
            style.border_color = Color(0.8, 0.62, 0.32, 0.42)
            style.shadow_color = Color(0, 0, 0, 0.26)
        "pressed":
            style.bg_color = Color(0.1, 0.07, 0.035, 0.76)
            style.border_color = Color(0.8, 0.62, 0.32, 0.42)
        _:
            style.bg_color = Color(0.08, 0.06, 0.04, 0.6)
            style.border_color = Color(0.72, 0.58, 0.32, 0.34)
    return style

func _hide_bianwu_backdrop_region_detail() -> void :
    if is_instance_valid(_bw_defense_detail_layer):
        _bw_defense_detail_layer.visible = false
    _bw_defense_selected_region_id = ""
    if is_instance_valid(_bw_defense_backdrop_map):
        _bw_defense_backdrop_map.select_region("")

func _layout_bianwu_backdrop_detail_layer() -> void :
    if not is_instance_valid(_bw_defense_detail_layer):
        return

    var top_offset: = 0.0
    var top_bar: = get_node_or_null("MainVBox/TopBar") as Control
    if top_bar != null:
        top_offset = top_bar.get_global_rect().end.y - get_global_rect().position.y + 2.0
    _bw_defense_detail_layer.offset_top = top_offset

func _populate_bianwu_buqu_management_list(list: VBoxContainer) -> void :
    for child in list.get_children():
        list.remove_child(child)
        child.queue_free()
    list.add_child(_make_bianwu_management_section_header("官军"))
    list.add_child(_make_bianwu_management_card_grid(false))
    list.add_child(_make_bianwu_management_section_header("家丁"))
    list.add_child(_make_bianwu_management_card_grid(true))

func _make_bianwu_management_section_header(text: String) -> Control:
    var margin: = MarginContainer.new()
    margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    margin.add_theme_constant_override("margin_top", 10)
    margin.add_theme_constant_override("margin_bottom", 2)

    var column: = VBoxContainer.new()
    column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    column.add_theme_constant_override("separation", 7)
    margin.add_child(column)

    var label: = Label.new()
    label.text = text
    label.add_theme_font_override("font", FontLoader.serif_bold())
    label.add_theme_font_size_override("font_size", 13)
    label.add_theme_color_override("font_color", _left_panel_text_color("text_sub"))
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.custom_minimum_size.y = 24
    column.add_child(label)

    var rule: = ColorRect.new()
    rule.color = Color(0.7, 0.55, 0.28, 0.34)
    rule.custom_minimum_size.y = 1
    rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    column.add_child(rule)

    return margin

func _make_bianwu_management_card_grid(only_jiading: bool) -> Control:
    var grid: = GridContainer.new()
    grid.name = "BianwuManagementCardGrid_Jiading" if only_jiading else "BianwuManagementCardGrid_Guanjun"
    grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    grid.columns = 1 if _is_mobile_portrait() else 5
    grid.add_theme_constant_override("h_separation", 16)
    grid.add_theme_constant_override("v_separation", 16)

    var serial_by_unit: = {}
    var idx: = 0
    for entry in GameState.bianwu_units:
        var unit_id: = ""
        var cap: = BIANWU_FORCE_CARD_CAP
        var amount: = 0
        var is_jd: = false
        if entry is Dictionary:
            unit_id = str(entry.get("id", ""))
            cap = int(entry.get("cap", BIANWU_FORCE_CARD_CAP))
            is_jd = bool(entry.get("is_jiading", false))
        else:
            unit_id = str(entry)
        if unit_id == "":
            idx += 1
            continue
        if is_jd != only_jiading:
            idx += 1
            continue
        serial_by_unit[unit_id] = int(serial_by_unit.get(unit_id, 0)) + 1
        var serial: int = int(serial_by_unit[unit_id])
        var unit_def: Dictionary = BattleTypesRef.unit_def(unit_id)
        amount = int(entry.get("hp", unit_def.get("hp", 0))) if entry is Dictionary else int(unit_def.get("hp", 0))
        grid.add_child(_make_zhisu_bianwu_force_card(unit_id, serial, amount, cap, idx, true, "management"))
        idx += 1

    if grid.get_child_count() == 0:
        grid.add_child(_make_zhisu_empty_label("暂无部队"))
    return grid

func _apply_global_modal_command_button_style(button: Button) -> void :
    button.add_theme_font_override("font", FontLoader.serif_bold())
    button.add_theme_font_size_override("font_size", 14)
    button.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    button.add_theme_color_override("font_hover_color", Color(1.0, 0.88, 0.58, 1.0))
    button.add_theme_stylebox_override("normal", _topbar_button_style(false))
    button.add_theme_stylebox_override("hover", _topbar_button_style(true))
    button.add_theme_stylebox_override("pressed", _topbar_button_style(true))
    button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _refresh_bianwu_buqu_management_modal() -> void :
    var layer: = get_node_or_null("BianwuBuquManagementModal")
    if not layer:
        return
    var list: = layer.find_child("BianwuBuquManagementList", true, false) as VBoxContainer
    if list:
        _populate_bianwu_buqu_management_list(list)

func _show_unit_rename_dialog(idx: int, current_name: String) -> void :
    var compact: = _is_mobile_portrait()

    var layer: = Control.new()
    layer.name = "UnitRenameDialog"
    layer.set_anchors_preset(Control.PRESET_FULL_RECT)
    layer.mouse_filter = Control.MOUSE_FILTER_STOP
    layer.z_index = 1000
    add_child(layer)

    var overlay_bg: = ColorRect.new()
    overlay_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay_bg.color = Color(0.0, 0.0, 0.0, 0.7)
    layer.add_child(overlay_bg)

    var dialog_panel: = PanelContainer.new()
    dialog_panel.set_anchors_preset(Control.PRESET_CENTER)
    dialog_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    dialog_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
    dialog_panel.custom_minimum_size = Vector2(380, 180) if compact else Vector2(500, 180)

    var panel_style: = StyleBoxFlat.new()
    panel_style.bg_color = GameState.get_theme_color("bg_popup")
    panel_style.border_color = Color(0.42, 0.43, 0.44, 0.72)
    panel_style.set_border_width_all(1)
    panel_style.shadow_color = Color(0, 0, 0, 0.6)
    panel_style.shadow_size = 24
    dialog_panel.add_theme_stylebox_override("panel", panel_style)
    layer.add_child(dialog_panel)

    var margin: = MarginContainer.new()
    var pad: = 20
    margin.add_theme_constant_override("margin_left", pad)
    margin.add_theme_constant_override("margin_right", pad)
    margin.add_theme_constant_override("margin_top", pad)
    margin.add_theme_constant_override("margin_bottom", pad)
    dialog_panel.add_child(margin)

    var box: = VBoxContainer.new()
    box.add_theme_constant_override("separation", 14)
    margin.add_child(box)

    var title_lbl: = Label.new()
    title_lbl.text = "自定义部队名称"
    title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_lbl.add_theme_font_override("font", FontLoader.serif_bold())
    title_lbl.add_theme_font_size_override("font_size", 15)
    title_lbl.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    box.add_child(title_lbl)

    var line_edit: = LineEdit.new()
    line_edit.text = current_name
    line_edit.placeholder_text = "请输入新的部队名称"
    line_edit.max_length = 8
    line_edit.virtual_keyboard_enabled = true
    line_edit.context_menu_enabled = true
    line_edit.add_theme_font_size_override("font_size", 13)
    line_edit.custom_minimum_size.y = 34
    line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    line_edit.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    line_edit.add_theme_color_override("caret_color", GameState.get_theme_color("text_main"))

    var edit_style: = StyleBoxFlat.new()
    edit_style.bg_color = Color(0.12, 0.11, 0.09, 0.6)
    edit_style.border_color = Color(0.42, 0.43, 0.44, 0.3)
    edit_style.set_border_width_all(1)
    line_edit.add_theme_stylebox_override("normal", edit_style)
    line_edit.add_theme_stylebox_override("focus", edit_style)
    box.add_child(line_edit)

    var btn_box: = HBoxContainer.new()
    btn_box.alignment = BoxContainer.ALIGNMENT_CENTER
    btn_box.add_theme_constant_override("separation", 16)
    box.add_child(btn_box)

    var close_dialog: = func():
        DisplayServer.virtual_keyboard_hide()
        layer.queue_free()

    var btn_cancel: = Button.new()
    btn_cancel.text = "取消"
    btn_cancel.focus_mode = Control.FOCUS_NONE
    btn_cancel.custom_minimum_size = Vector2(84, 32)
    btn_box.add_child(btn_cancel)

    var btn_reset: = Button.new()
    btn_reset.text = "恢复默认"
    btn_reset.focus_mode = Control.FOCUS_NONE
    btn_reset.custom_minimum_size = Vector2(96, 32)
    btn_box.add_child(btn_reset)

    var btn_ok: = Button.new()
    btn_ok.text = "确定"
    btn_ok.focus_mode = Control.FOCUS_NONE
    btn_ok.custom_minimum_size = Vector2(84, 32)
    btn_box.add_child(btn_ok)

    for btn in [btn_cancel, btn_reset, btn_ok]:
        btn.add_theme_font_override("font", FontLoader.serif_bold())
        btn.add_theme_font_size_override("font_size", 13)
    GameScreenStyleFactory.apply_command_button_style(btn_cancel, "secondary", 10, 6)
    GameScreenStyleFactory.apply_command_button_style(btn_reset, "secondary", 10, 6)
    GameScreenStyleFactory.apply_command_button_style(btn_ok, "primary", 10, 6)

    btn_cancel.pressed.connect( func(): close_dialog.call())

    btn_reset.pressed.connect( func():
        var entries: Array = GameState.bianwu_units
        if idx >= 0 and idx < entries.size():
            var entry = entries[idx]
            var unit_id: = ""
            if entry is Dictionary:
                unit_id = str(entry.get("id", ""))
            else:
                unit_id = str(entry)
            if unit_id != "":
                var unit_def: Dictionary = BattleTypesRef.unit_def(unit_id)
                var default_name = str(unit_def.get("name", unit_id))
                if entry is Dictionary:
                    entry["name"] = default_name
                else:
                    entry = {
                        "id": unit_id, 
                        "hp": int(unit_def.get("hp", 0)), 
                        "cap": BIANWU_FORCE_CARD_CAP, 
                        "level": 1, 
                        "name": default_name
                    }
                GameState.bianwu_units[idx] = entry
                GameState.bianwu_units = GameState.bianwu_units.duplicate()
                GameState.state_changed.emit()
                _refresh_zhisu_panel()
                _refresh_bianwu_buqu_management_modal()
        close_dialog.call()
    )

    var submit: = func():
        var nm: = line_edit.text.strip_edges()
        if nm != "":
            var entries: Array = GameState.bianwu_units
            if idx >= 0 and idx < entries.size():
                var entry = entries[idx]
                if typeof(entry) == TYPE_STRING:
                    var unit_id = entry
                    var unit_def: Dictionary = BattleTypesRef.unit_def(unit_id)
                    entry = {
                        "id": unit_id, 
                        "hp": int(unit_def.get("hp", 0)), 
                        "cap": BIANWU_FORCE_CARD_CAP, 
                        "level": 1, 
                        "name": nm
                    }
                else:
                    entry["name"] = nm
                GameState.bianwu_units[idx] = entry
                GameState.bianwu_units = GameState.bianwu_units.duplicate()
                GameState.state_changed.emit()
                _refresh_zhisu_panel()
                _refresh_bianwu_buqu_management_modal()
        close_dialog.call()

    btn_ok.pressed.connect(submit)
    line_edit.text_submitted.connect( func(_txt): submit.call())

    line_edit.call_deferred("grab_focus")
    line_edit.call_deferred("select_all")

func _get_unit_upgrade_costs(unit_id: String, current_level: int) -> Dictionary:
    var is_elite: = false
    var BattleTypesRef = load("res://scripts/battle/battle_types.gd")
    var def = BattleTypesRef.unit_def(unit_id)
    if not def.is_empty():
        is_elite = bool(def.get("elite", false))

    var costs: = {
        "zhanyi": 0, 
        "xiangyin": 0, 
        "liangcao": 0, 
        "mapi": 0, 
        "huoqi": 0
    }

    if not is_elite:
        if current_level == 1:
            costs["zhanyi"] = 4
            costs["xiangyin"] = 100
            costs["liangcao"] = 200
        elif current_level == 2:
            costs["zhanyi"] = 6
            costs["xiangyin"] = 200
            costs["liangcao"] = 400
        else:
            costs["zhanyi"] = 8 + (current_level - 3) * 3
            costs["xiangyin"] = 300 + (current_level - 3) * 100
            costs["liangcao"] = 600 + (current_level - 3) * 200
    else:
        if current_level == 1:
            costs["zhanyi"] = 8
            costs["xiangyin"] = 200
            costs["liangcao"] = 400
        elif current_level == 2:
            costs["zhanyi"] = 12
            costs["xiangyin"] = 400
            costs["liangcao"] = 800
        else:
            costs["zhanyi"] = 16 + (current_level - 3) * 5
            costs["xiangyin"] = 600 + (current_level - 3) * 200
            costs["liangcao"] = 1200 + (current_level - 3) * 400


    if unit_id == "cavalry" or unit_id == "guanning":
        costs["mapi"] = 10 if current_level == 1 else (20 if current_level == 2 else 30)
    elif unit_id in ["musket", "cannon", "chariot", "redcannon"]:
        costs["huoqi"] = 10 if current_level == 1 else (20 if current_level == 2 else 30)

    return costs

func _show_unit_upgrade_dialog(idx: int) -> void :
    var compact: = _is_mobile_portrait()
    var entries: Array = GameState.bianwu_units
    if idx < 0 or idx >= entries.size():
        return
    var entry = entries[idx]
    var unit_id: = ""
    var unit_level: = 1
    var base_name: = ""
    var BattleTypesRef = load("res://scripts/battle/battle_types.gd")
    if entry is Dictionary:
        unit_id = str(entry.get("id", ""))
        unit_level = int(entry.get("level", 1))
        base_name = str(entry.get("name", ""))
    else:
        unit_id = str(entry)
        unit_level = 1
        var unit_def = BattleTypesRef.unit_def(unit_id)
        base_name = str(unit_def.get("name", unit_id))

    if unit_id == "":
        return
    var unit_group_id: = BianwuDefenseServiceRef.unit_group_key(entry)

    var costs: = _get_unit_upgrade_costs(unit_id, unit_level)
    var zhanyi_stock: = int(GameState.city.get("zhanyi", 0))
    var xiangyin_stock: = int(GameState.city.get("xiangyin", 0))
    var liangcao_stock: = int(GameState.city.get("liangcao", 0))
    var mapi_stock: = int(GameState.city.get("mapi", 0))
    var huoqi_stock: = int(GameState.city.get("huoqi", 0))

    var can_upgrade: = true
    if zhanyi_stock < costs["zhanyi"]: can_upgrade = false
    if xiangyin_stock < costs["xiangyin"]: can_upgrade = false
    if liangcao_stock < costs["liangcao"]: can_upgrade = false
    if costs["mapi"] > 0 and mapi_stock < costs["mapi"]: can_upgrade = false
    if costs["huoqi"] > 0 and huoqi_stock < costs["huoqi"]: can_upgrade = false

    var layer: = Control.new()
    layer.name = "UnitUpgradeDialog"
    layer.set_anchors_preset(Control.PRESET_FULL_RECT)
    layer.mouse_filter = Control.MOUSE_FILTER_STOP
    layer.z_index = 1000
    add_child(layer)

    var overlay_bg: = ColorRect.new()
    overlay_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay_bg.color = Color(0.0, 0.0, 0.0, 0.7)
    layer.add_child(overlay_bg)

    var dialog_panel: = PanelContainer.new()
    dialog_panel.set_anchors_preset(Control.PRESET_CENTER)
    dialog_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
    dialog_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
    dialog_panel.custom_minimum_size = Vector2(380, 240) if compact else Vector2(500, 260)

    var panel_style: = StyleBoxFlat.new()
    panel_style.bg_color = GameState.get_theme_color("bg_popup")
    panel_style.border_color = Color(0.42, 0.43, 0.44, 0.72)
    panel_style.set_border_width_all(1)
    panel_style.shadow_color = Color(0, 0, 0, 0.6)
    panel_style.shadow_size = 24
    dialog_panel.add_theme_stylebox_override("panel", panel_style)
    layer.add_child(dialog_panel)

    var margin: = MarginContainer.new()
    var pad: = 20
    margin.add_theme_constant_override("margin_left", pad)
    margin.add_theme_constant_override("margin_right", pad)
    margin.add_theme_constant_override("margin_top", pad)
    margin.add_theme_constant_override("margin_bottom", pad)
    dialog_panel.add_child(margin)

    var box: = VBoxContainer.new()
    box.add_theme_constant_override("separation", 14)
    margin.add_child(box)

    var title_lbl: = Label.new()
    title_lbl.text = "营伍操练"
    title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_lbl.add_theme_font_override("font", FontLoader.serif_bold())
    title_lbl.add_theme_font_size_override("font_size", 16)
    title_lbl.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    box.add_child(title_lbl)

    var subtitle_lbl: = Label.new()
    subtitle_lbl.text = "%s (Lv.%d → Lv.%d)" % [base_name, unit_level, unit_level + 1]
    subtitle_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle_lbl.add_theme_font_override("font", FontLoader.body())
    subtitle_lbl.add_theme_font_size_override("font_size", 13)
    subtitle_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    box.add_child(subtitle_lbl)


    var costs_box: = VBoxContainer.new()
    costs_box.add_theme_constant_override("separation", 6)
    box.add_child(costs_box)

    var create_cost_row: = func(resource_name: String, cost: int, stock: int):
        var row: = HBoxContainer.new()
        var name_lbl: = Label.new()
        name_lbl.text = resource_name
        name_lbl.add_theme_font_override("font", FontLoader.body())
        name_lbl.add_theme_font_size_override("font_size", 12)
        name_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        row.add_child(name_lbl)

        var spacer: = Control.new()
        spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(spacer)

        var val_lbl: = Label.new()
        val_lbl.text = "%d / %d" % [cost, stock]
        val_lbl.add_theme_font_override("font", FontLoader.serif_bold())
        val_lbl.add_theme_font_size_override("font_size", 12)
        if stock < cost:
            val_lbl.add_theme_color_override("font_color", Presenter.negative_delta_color())
        else:
            val_lbl.add_theme_color_override("font_color", Color(0.3, 0.7, 0.3) if GameState.theme == "dark" else Color(0.1, 0.5, 0.1))
        row.add_child(val_lbl)
        return row

    costs_box.add_child(create_cost_row.call("战意需求", costs["zhanyi"], zhanyi_stock))
    costs_box.add_child(create_cost_row.call("饷银需求", costs["xiangyin"], xiangyin_stock))
    costs_box.add_child(create_cost_row.call("粮草需求", costs["liangcao"], liangcao_stock))
    if costs["mapi"] > 0:
        costs_box.add_child(create_cost_row.call("马匹需求", costs["mapi"], mapi_stock))
    if costs["huoqi"] > 0:
        costs_box.add_child(create_cost_row.call("火器需求", costs["huoqi"], huoqi_stock))

    var btn_box: = HBoxContainer.new()
    btn_box.alignment = BoxContainer.ALIGNMENT_CENTER
    btn_box.add_theme_constant_override("separation", 24)
    box.add_child(btn_box)

    var close_dialog: = func():
        layer.queue_free()

    var btn_cancel: = Button.new()
    btn_cancel.text = "取消"
    btn_cancel.focus_mode = Control.FOCUS_NONE
    btn_cancel.custom_minimum_size = Vector2(84, 32)
    btn_box.add_child(btn_cancel)
    btn_cancel.pressed.connect(close_dialog)

    var btn_ok: = Button.new()
    btn_ok.text = "确认操练"
    btn_ok.focus_mode = Control.FOCUS_NONE
    btn_ok.custom_minimum_size = Vector2(96, 32)
    btn_ok.disabled = not can_upgrade
    btn_box.add_child(btn_ok)

    btn_ok.pressed.connect( func():

        GameState.city["zhanyi"] = maxi(0, int(GameState.city.get("zhanyi", 0)) - costs["zhanyi"])
        GameState.city["xiangyin"] = int(GameState.city.get("xiangyin", 0)) - costs["xiangyin"]
        GameState.city["liangcao"] = maxi(0, int(GameState.city.get("liangcao", 0)) - costs["liangcao"])
        if costs["mapi"] > 0:
            GameState.city["mapi"] = maxi(0, int(GameState.city.get("mapi", 0)) - costs["mapi"])
        if costs["huoqi"] > 0:
            GameState.city["huoqi"] = maxi(0, int(GameState.city.get("huoqi", 0)) - costs["huoqi"])


        BianwuDefenseServiceRef.set_unit_group_level(GameState, unit_group_id, unit_level + 1)
        GameState.bianwu_units = GameState.bianwu_units.duplicate()
        GameState.city = GameState.city.duplicate()
        GameState.state_changed.emit()
        _refresh_zhisu_panel()
        _refresh_bianwu_buqu_management_modal()
        close_dialog.call()
    )

    for btn in [btn_cancel, btn_ok]:
        btn.add_theme_font_override("font", FontLoader.serif_bold())
        btn.add_theme_font_size_override("font_size", 13)
    GameScreenStyleFactory.apply_command_button_style(btn_cancel, "secondary", 10, 6)
    GameScreenStyleFactory.apply_command_button_style(btn_ok, "primary", 10, 6)

func _zhisu_attitudes_help_text() -> String:
    return "边关如弈，五方皆不可失。圣眷、朝堂、监军、军心、士民——你无法让所有人满意，但务必守住每一方的底线。任意一方态度归零，便是你在这盘棋局中出局之时。" if GameData.active_line == "bianwu" else "官场如棋，五方皆不可失。圣眷、中官、清议、士绅、民望——你无法让所有人满意，但务必守住每一方的底线。任意一方态度归零，便是你在这盘棋局中出局之时。"


func _make_zhisu_attitudes_list() -> Control:
    var list: = VBoxContainer.new()
    list.name = "ZhisuAttitudesList"
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list.add_theme_constant_override("separation", 0)
    Presenter.populate_attitudes(list, GameState.attitudes, Callable(GameState, "get_attitude_tier"), Callable(self, "_get_tier_color"), false, GameState.theme == "light")
    var margin: = MarginContainer.new()
    margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    margin.add_theme_constant_override("margin_left", ZHISU_ROW_CARD_SIDE_MARGIN)
    margin.add_theme_constant_override("margin_right", ZHISU_ROW_CARD_SIDE_MARGIN)
    margin.add_child(list)
    return margin

func _make_zhisu_city_stat_row(key: String) -> Control:
    var label_text: = str(GameData.CITY_STAT_LABELS.get(key, key))
    var level: = GameState.get_city_stat_level(key)
    var row: = _make_zhisu_row(key, label_text, "Lv.%d/50" % level)
    _connect_zhisu_city_stat_row_interactions(row, key)
    return row

func _make_zhisu_row(icon_key: String, label_text: String, value_text: String, trailing: Control = null) -> Control:
    var card: = PanelContainer.new()
    card.name = "ZhisuRowCard_%s" % label_text
    card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    card.custom_minimum_size.y = 38
    card.add_theme_stylebox_override("panel", _make_zhisu_row_card_style(false))

    var row: = HBoxContainer.new()
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_theme_constant_override("separation", 7)
    row.custom_minimum_size.y = 32
    card.add_child(row)

    var icon_slot: = Control.new()
    icon_slot.custom_minimum_size = Vector2(22, 22)
    icon_slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    if icon_key != "":
        var icon: = StatusIconUtil.make_texture(icon_key, 18)
        if icon != null:
            icon.position = Vector2(2, 2)
            icon_slot.add_child(icon)
    row.add_child(icon_slot)

    var label: = Label.new()
    label.text = label_text
    label.add_theme_font_override("font", FontLoader.body())
    label.add_theme_font_size_override("font_size", 13)
    label.add_theme_color_override("font_color", _left_panel_text_color("text_sub"))
    row.add_child(label)

    if trailing != null:
        row.add_child(trailing)

    var spacer: = Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(spacer)

    var parts: = value_text.split("/")
    if parts.size() == 2:
        var value_container: = HBoxContainer.new()
        value_container.add_theme_constant_override("separation", 1)
        value_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER

        var main_val_label: = Label.new()
        main_val_label.text = parts[0]
        main_val_label.add_theme_font_override("font", FontLoader.serif_bold())
        main_val_label.add_theme_font_size_override("font_size", 13)
        var main_color: Color
        if label_text in ["政绩", "战功"]:
            var merit: = GameState.get_governance_merit()
            var merit_target: = GameState.get_governance_merit_target()
            if merit_target > 0 and merit >= merit_target:
                main_color = GameState.get_theme_color("req_green")
            elif GameState.theme == "light":
                main_color = Color(0.48, 0.35, 0.12)
            else:
                main_color = GameState.get_theme_color("border_active")
        else:
            main_color = _left_panel_text_color("text_main")
        main_val_label.add_theme_color_override("font_color", main_color)
        main_val_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        value_container.add_child(main_val_label)

        var sub_val_label: = Label.new()
        sub_val_label.text = "/" + parts[1]
        sub_val_label.add_theme_font_override("font", FontLoader.serif_bold())
        sub_val_label.add_theme_font_size_override("font_size", 9)
        var sub_color: Color
        if GameState.theme == "light":
            sub_color = Color(0.34, 0.25, 0.1, 0.92)
        else:
            var weak_color = GameState.get_theme_color("text_sub")
            sub_color = Color(weak_color.r, weak_color.g, weak_color.b, 0.55)
        sub_val_label.add_theme_color_override("font_color", sub_color)
        sub_val_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
        value_container.add_child(sub_val_label)

        row.add_child(value_container)
    else:
        var value: = Label.new()
        value.text = value_text
        value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        value.add_theme_font_override("font", FontLoader.serif_bold())
        value.add_theme_font_size_override("font_size", 13)
        value.add_theme_color_override("font_color", _left_panel_text_color("text_main"))
        row.add_child(value)
    return _wrap_zhisu_row_card(card)

func _wrap_zhisu_row_card(card: Control) -> MarginContainer:
    var margin: = MarginContainer.new()
    margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    margin.add_theme_constant_override("margin_left", ZHISU_ROW_CARD_SIDE_MARGIN)
    margin.add_theme_constant_override("margin_right", ZHISU_ROW_CARD_SIDE_MARGIN)
    margin.add_child(card)
    return margin

func _connect_zhisu_merit_row_interactions(row: Control) -> void :
    _prepare_zhisu_interactive_row(row)
    _connect_help_btn_hover(row, "政 绩 考 成", func(): return _build_governance_merit_help_text())
    row.gui_input.connect( func(event: InputEvent) -> void :
        if not _is_zhisu_scroll_safe_tap_event(event):
            return
        _show_help_overlay(row, "政 绩 考 成", _build_governance_merit_help_text())
    )

func _connect_zhisu_resource_row_interactions(row: Control, key: String) -> void :
    var hover_callables: = {
        "yinliang": Callable(_tooltips, "_show_silver_breakdown_tooltip"), 
        "liangshi": Callable(_tooltips, "_show_grain_breakdown_tooltip"), 
        "bingyong": Callable(_tooltips, "_show_bingyong_tooltip"), 
        "renkou_val": Callable(_tooltips, "_show_renkou_tooltip"), 
        "liumin": Callable(_tooltips, "_show_liumin_tooltip")
    }
    if not hover_callables.has(key):
        return
    _prepare_zhisu_interactive_row(row)
    _connect_resource_label_hover(row, hover_callables[key])
    row.gui_input.connect( func(event: InputEvent) -> void :
        if not _is_zhisu_scroll_safe_tap_event(event):
            return
        _show_zhisu_resource_tooltip(key, row)
    )

func _connect_zhisu_city_stat_row_interactions(row: Control, key: String) -> void :
    _prepare_zhisu_interactive_row(row)
    _city_stats_display_controller._connect_city_stat_events(row, key)

func _prepare_zhisu_interactive_row(row: Control) -> void :
    if row == null:
        return
    row.mouse_filter = Control.MOUSE_FILTER_STOP
    row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    _set_mouse_filter_recursive(row, Control.MOUSE_FILTER_IGNORE)
    row.mouse_filter = Control.MOUSE_FILTER_STOP

    var card: = _zhisu_row_card_panel(row)
    if card != null:
        _connect_zhisu_row_card_hover_style(row, card)

func _should_suppress_jushi_scroll_press() -> bool:
    return NativeMobileTouchScrollRef.should_suppress_press(self, "jushi_scroll_touch_drag_suppress_until_ms")

func _is_zhisu_scroll_safe_tap_event(event: InputEvent) -> bool:
    if _should_suppress_jushi_scroll_press():
        return false
    if event is InputEventScreenTouch:
        return not event.pressed
    if event is InputEventMouseButton:
        return event.button_index == MOUSE_BUTTON_LEFT and event.pressed
    return false

func _show_zhisu_resource_tooltip(key: String, anchor: Control) -> void :
    if GameState.has_method("is_after_sun_chuanting_branch_split") and GameState.is_after_sun_chuanting_branch_split():
        return
    match key:
        "yinliang":
            _tooltips._show_silver_breakdown_tooltip(anchor)
        "liangshi":
            _tooltips._show_grain_breakdown_tooltip(anchor)
        "bingyong":
            _tooltips._show_bingyong_tooltip(anchor)
        "renkou_val":
            _tooltips._show_renkou_tooltip(anchor)
        "liumin":
            _tooltips._show_liumin_tooltip(anchor)
        _:
            return
    _pin_resource_tooltip_from_click()

func _zhisu_row_card_panel(row: Control) -> PanelContainer:
    if row is PanelContainer:
        return row
    for child in row.get_children():
        if child is PanelContainer:
            return child
    return null

func _connect_zhisu_row_card_hover_style(row: Control, card: PanelContainer) -> void :
    if not row.mouse_entered.is_connected(Callable(self, "_on_zhisu_row_card_mouse_entered").bind(card)):
        row.mouse_entered.connect(_on_zhisu_row_card_mouse_entered.bind(card))
    if not row.mouse_exited.is_connected(Callable(self, "_on_zhisu_row_card_mouse_exited").bind(card)):
        row.mouse_exited.connect(_on_zhisu_row_card_mouse_exited.bind(card))

func _on_zhisu_row_card_mouse_entered(row: Control) -> void :
    if row is PanelContainer:
        row.add_theme_stylebox_override("panel", _make_zhisu_row_card_style(true))

func _on_zhisu_row_card_mouse_exited(row: Control) -> void :
    if row is PanelContainer:
        row.add_theme_stylebox_override("panel", _make_zhisu_row_card_style(false))

func _make_zhisu_row_card_style(hovered: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    var accent: = GameState.get_theme_color("border_active")
    if GameState.theme == "light":
        style.bg_color = Color(0.96, 0.93, 0.86, 0.36 if hovered else 0.22)
        style.border_color = Color(0.5, 0.38, 0.2, (0.34 if hovered else 0.18) * 0.3)
    else:
        style.bg_color = Color(0.03, 0.029, 0.026, 0.46 if hovered else 0.28)
        style.border_color = Color(accent.r, accent.g, accent.b, (0.36 if hovered else 0.16) * 0.3)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.corner_radius_top_left = 0
    style.corner_radius_top_right = 0
    style.corner_radius_bottom_left = 0
    style.corner_radius_bottom_right = 0
    style.content_margin_left = 6
    style.content_margin_right = 8
    style.content_margin_top = 3
    style.content_margin_bottom = 3
    return style

func _set_mouse_filter_recursive(node: Node, mouse_filter_value: int) -> void :
    for child in node.get_children():
        if child is Control:
            child.mouse_filter = mouse_filter_value
        _set_mouse_filter_recursive(child, mouse_filter_value)

func _make_zhisu_overview_button_block() -> Control:
    var margin: = MarginContainer.new()
    margin.add_theme_constant_override("margin_top", 8)
    margin.add_child(_make_zhisu_overview_button())
    return margin

func _make_zhisu_overview_button() -> Control:
    var row: = HBoxContainer.new()
    row.alignment = BoxContainer.ALIGNMENT_CENTER
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.custom_minimum_size.y = 32
    var btn: = Button.new()
    btn.name = "ZhisuOverviewButton"
    btn.text = "总览"
    btn.custom_minimum_size = Vector2(70, 24)
    btn.focus_mode = Control.FOCUS_NONE
    btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    btn.add_theme_font_override("font", FontLoader.body())
    btn.add_theme_font_size_override("font_size", 13)
    btn.add_theme_color_override("font_color", _left_panel_text_color("text_main"))
    btn.add_theme_color_override("font_hover_color", GameState.get_theme_color("border_active"))
    btn.add_theme_stylebox_override("normal", _make_zhisu_pill_button_style(false))
    btn.add_theme_stylebox_override("hover", _make_zhisu_pill_button_style(true))
    btn.add_theme_stylebox_override("pressed", _make_zhisu_pill_button_style(true))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    btn.pressed.connect( func():
        if _overview_panel_controller != null:
            _overview_panel_controller.show_overview_panel()
    )
    row.add_child(btn)
    return row

func _make_zengyi_expand_button_block() -> Control:
    var row: = HBoxContainer.new()
    row.alignment = BoxContainer.ALIGNMENT_CENTER
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.custom_minimum_size.y = 30
    var btn: = Button.new()
    btn.name = "ZengyiExpandButton"
    btn.text = "扩充"
    btn.custom_minimum_size = Vector2(58, 18)
    btn.focus_mode = Control.FOCUS_NONE
    btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    btn.add_theme_font_override("font", FontLoader.body())
    btn.add_theme_font_size_override("font_size", 15)
    btn.add_theme_color_override("font_color", _left_panel_text_color("text_main"))
    btn.add_theme_color_override("font_hover_color", GameState.get_theme_color("border_active"))
    btn.add_theme_stylebox_override("normal", _make_zengyi_expand_button_style(false))
    btn.add_theme_stylebox_override("hover", _make_zengyi_expand_button_style(true))
    btn.add_theme_stylebox_override("pressed", _make_zengyi_expand_button_style(true))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    btn.pressed.connect( func():
        if NativeMobileTouchScrollRef.should_suppress_press(self, "jushi_scroll_touch_drag_suppress_until_ms"):
            return
        _show_lingwu_city_slot_popup()
    )
    row.add_child(btn)
    return row

func _make_zengyi_auto_arrange_button_block() -> Control:
    var row: = HBoxContainer.new()
    row.alignment = BoxContainer.ALIGNMENT_CENTER
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.custom_minimum_size.y = 30
    var btn: = Button.new()
    btn.name = "ZengyiAutoArrangeButton"
    btn.text = "自动整理"
    btn.custom_minimum_size = Vector2(78, 18)
    btn.focus_mode = Control.FOCUS_NONE
    btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    btn.add_theme_font_override("font", FontLoader.body())
    btn.add_theme_font_size_override("font_size", 15)
    btn.add_theme_color_override("font_color", _left_panel_text_color("text_main"))
    btn.add_theme_color_override("font_hover_color", GameState.get_theme_color("border_active"))
    btn.add_theme_stylebox_override("normal", _make_zengyi_expand_button_style(false))
    btn.add_theme_stylebox_override("hover", _make_zengyi_expand_button_style(true))
    btn.add_theme_stylebox_override("pressed", _make_zengyi_expand_button_style(true))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    btn.pressed.connect( func():
        if NativeMobileTouchScrollRef.should_suppress_press(self, "jushi_scroll_touch_drag_suppress_until_ms"):
            return
        GameState.auto_arrange_personal_boost_item_slots()
        _refresh_zengyi_panel()
    )
    row.add_child(btn)
    return row

func _make_zengyi_title_slots_gap() -> Control:
    var spacer: = Control.new()
    spacer.custom_minimum_size = Vector2(0, 18)
    spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    return spacer

func _make_zengyi_boost_slots() -> Control:
    GameState.normalize_city_boost_item_slots()
    var list: = VBoxContainer.new()
    list.name = "ZengyiCityBoostSlots"
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list.add_theme_constant_override("separation", 8)
    for idx in range(GameState.city_boost_item_slots.size()):
        list.add_child(_make_zengyi_boost_slot(idx))
    var outer: = VBoxContainer.new()
    outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    outer.add_child(list)
    return outer

func _make_zengyi_personal_boost_slots() -> Control:
    GameState.normalize_personal_boost_item_slots()
    var list: = VBoxContainer.new()
    list.name = "ZengyiPersonalBoostSlots"
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list.add_theme_constant_override("separation", 8)
    for idx in range(GameState.personal_boost_item_slots.size()):
        list.add_child(_make_zengyi_personal_boost_slot(idx))
    return list

func _make_zengyi_personal_boost_slot(slot_index: int) -> Control:
    var item_id: = str(GameState.personal_boost_item_slots[slot_index])
    var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
    var filled: = item_id != "" and not item_def.is_empty()
    var card: = PanelContainer.new()
    card.name = "ZengyiPersonalBoostSlot%d" % slot_index
    card.custom_minimum_size = Vector2(0, 56)
    card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    card.add_theme_stylebox_override("panel", _make_zengyi_boost_slot_card_style())
    card.gui_input.connect( func(event: InputEvent):
        if Presenter._is_primary_press_event(event):
            if NativeMobileTouchScrollRef.should_suppress_press(self, "jushi_scroll_touch_drag_suppress_until_ms"):
                return
            _show_items_overlay(Callable(self, "_select_zengyi_personal_boost_item").bind(slot_index), item_id, "personal")
    )
    var row: = HBoxContainer.new()
    row.add_theme_constant_override("separation", 10)
    card.add_child(row)
    var btn: = Button.new()
    btn.custom_minimum_size = Vector2(36, 36)
    btn.focus_mode = Control.FOCUS_NONE
    btn.text = str(item_def.get("name", "")).substr(0, 1) if filled else "+"
    btn.add_theme_font_override("font", FontLoader.serif_bold())
    btn.add_theme_font_size_override("font_size", 17)
    btn.add_theme_color_override("font_color", GameState.get_theme_color("border_active") if filled else GameState.get_theme_color("text_sub"))
    btn.add_theme_stylebox_override("normal", _city_stats_display_controller._make_city_boost_slot_style(filled, false))
    btn.add_theme_stylebox_override("hover", _city_stats_display_controller._make_city_boost_slot_style(true, true))
    btn.add_theme_stylebox_override("pressed", _city_stats_display_controller._make_city_boost_slot_style(true, true))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    btn.pressed.connect( func():
        if NativeMobileTouchScrollRef.should_suppress_press(self, "jushi_scroll_touch_drag_suppress_until_ms"):
            return
        _show_items_overlay(Callable(self, "_select_zengyi_personal_boost_item").bind(slot_index), item_id, "personal")
    )
    row.add_child(btn)
    var text_box: = VBoxContainer.new()
    text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    text_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    row.add_child(text_box)
    var name_label: = Label.new()
    name_label.text = str(item_def.get("name", "")) if filled else "添加道具"
    name_label.add_theme_font_size_override("font_size", 11)
    name_label.add_theme_color_override("font_color", _left_panel_text_color("text_main") if filled else _left_panel_text_color("text_sub"))
    text_box.add_child(name_label)
    var effect_label: = Label.new()
    var parts: Array[String] = []
    for key in PERSONAL_STAT_KEYS:
        var value: = int(item_def.get("effects", {}).get(key, 0))
        if value != 0:
            parts.append("%s %+d" % [PERSONAL_STAT_LABELS[key], value])
    effect_label.text = "、".join(parts) if filled else "选择个人增益"
    effect_label.add_theme_font_size_override("font_size", 9)
    effect_label.add_theme_color_override("font_color", _left_panel_text_color("text_sub"))
    text_box.add_child(effect_label)
    return card

func _make_zengyi_boost_slot(slot_index: int) -> Control:
    var item_id: = ""
    if slot_index < GameState.city_boost_item_slots.size():
        item_id = str(GameState.city_boost_item_slots[slot_index])
    var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
    var item_name: = str(item_def.get("name", ""))
    var filled: = item_id != "" and not item_def.is_empty()

    var card: = PanelContainer.new()
    card.name = "ZengyiCityBoostSlot%d" % slot_index
    card.custom_minimum_size = Vector2(0, 56)
    card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    card.add_theme_stylebox_override("panel", _make_zengyi_boost_slot_card_style())
    card.gui_input.connect( func(event: InputEvent):
        if Presenter._is_primary_press_event(event):
            if NativeMobileTouchScrollRef.should_suppress_press(self, "jushi_scroll_touch_drag_suppress_until_ms"):
                return
            _show_items_overlay(Callable(self, "_select_zengyi_city_boost_item").bind(slot_index), item_id, "governance")
    )

    var row: = HBoxContainer.new()
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.alignment = BoxContainer.ALIGNMENT_BEGIN
    row.add_theme_constant_override("separation", 10)
    card.add_child(row)

    var btn: = Button.new()
    btn.name = "ZengyiCityBoostSlotButton"
    btn.custom_minimum_size = Vector2(36, 36)
    btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    btn.focus_mode = Control.FOCUS_NONE
    btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    btn.clip_text = true
    btn.text = item_name.substr(0, 1) if filled else "+"
    btn.tooltip_text = _city_stats_display_controller._build_city_boost_slot_tooltip(item_id)
    btn.add_theme_font_override("font", FontLoader.serif_bold())
    btn.add_theme_font_size_override("font_size", 17)
    btn.add_theme_color_override("font_color", GameState.get_theme_color("border_active") if filled else GameState.get_theme_color("text_sub"))
    btn.add_theme_color_override("font_hover_color", GameState.get_theme_color("border_active"))
    btn.add_theme_stylebox_override("normal", _city_stats_display_controller._make_city_boost_slot_style(filled, false))
    btn.add_theme_stylebox_override("hover", _city_stats_display_controller._make_city_boost_slot_style(true, true))
    btn.add_theme_stylebox_override("pressed", _city_stats_display_controller._make_city_boost_slot_style(true, true))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    btn.pressed.connect( func():

        if NativeMobileTouchScrollRef.should_suppress_press(self, "jushi_scroll_touch_drag_suppress_until_ms"):
            return
        _show_items_overlay(Callable(self, "_select_zengyi_city_boost_item").bind(slot_index), item_id, "governance")
    )
    btn.set_drag_forwarding(Callable(), Callable(_city_stats_display_controller, "_can_drop_city_boost_item").bind(slot_index), Callable(self, "_drop_zengyi_city_boost_item").bind(slot_index))
    row.add_child(btn)

    var text_box: = VBoxContainer.new()
    text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    text_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    text_box.add_theme_constant_override("separation", 2)
    row.add_child(text_box)

    var name_label: = Label.new()
    name_label.text = item_name if filled else "添加道具"
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
    name_label.clip_text = true
    name_label.custom_minimum_size = Vector2(0, 0)
    name_label.add_theme_font_override("font", FontLoader.body())
    name_label.add_theme_font_size_override("font_size", 11)
    name_label.add_theme_color_override("font_color", _left_panel_text_color("text_main") if filled else _left_panel_text_color("text_sub"))
    text_box.add_child(name_label)

    var effect_label: = Label.new()
    effect_label.text = _city_stats_display_controller._city_boost_effect_text(item_id) if filled else "选择随身增益"
    effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    effect_label.autowrap_mode = TextServer.AUTOWRAP_OFF
    effect_label.clip_text = true
    effect_label.custom_minimum_size = Vector2(0, 0)
    effect_label.add_theme_font_override("font", FontLoader.body())
    effect_label.add_theme_font_size_override("font_size", 9)
    var effect_color: = _left_panel_text_color("text_sub")
    if not filled:
        effect_color.a *= 0.5
    effect_label.add_theme_color_override("font_color", effect_color)
    text_box.add_child(effect_label)

    return card

func _make_zengyi_boost_slot_card_style() -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0.2, 0.14, 0.09, 0.15)
    var accent: = GameState.get_theme_color("border_active")
    style.border_color = Color(accent.r, accent.g, accent.b, 0.2)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.corner_radius_top_left = 4
    style.corner_radius_top_right = 4
    style.corner_radius_bottom_left = 4
    style.corner_radius_bottom_right = 4
    style.content_margin_left = 10
    style.content_margin_right = 10
    style.content_margin_top = 6
    style.content_margin_bottom = 6
    return style

func _select_zengyi_city_boost_item(item_id: String, slot_index: int) -> void :
    if GameState.set_city_boost_item_slot(slot_index, item_id):
        if _items_overlay_controller != null:
            _items_overlay_controller.close_items_overlay()
        _refresh_zengyi_panel()

func _select_zengyi_personal_boost_item(item_id: String, slot_index: int) -> void :
    if GameState.set_personal_boost_item_slot(slot_index, item_id):
        if _items_overlay_controller != null:
            _items_overlay_controller.close_items_overlay()
        _refresh_zengyi_panel()

func _drop_zengyi_city_boost_item(_at_position: Vector2, data, slot_index: int) -> void :
    if not _city_stats_display_controller._can_drop_city_boost_item(_at_position, data, slot_index):
        return
    if GameState.move_city_boost_item_to_slot(str(data.get("item_id", "")), slot_index):
        _refresh_zengyi_panel()

func _refresh_lingwu_panel() -> void :
    if not is_instance_valid(lingwu_info_container):
        return
    lingwu_info_container.add_theme_constant_override("separation", 12)
    for child in lingwu_info_container.get_children():
        lingwu_info_container.remove_child(child)
        child.queue_free()

    var value: = Label.new()
    value.name = "LingwuCurrentValue"
    value.text = "当前识悟：%d" % int(GameState.lingwu)
    value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    value.add_theme_font_override("font", FontLoader.serif_bold())
    value.add_theme_font_size_override("font_size", 24 if _is_mobile_portrait() else 18)
    value.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    lingwu_info_container.add_child(value)

    lingwu_info_container.add_child(_make_lingwu_action_button("+ 个人禀赋", GameState.LINGWU_STAT_COST, Callable(self, "_show_lingwu_stat_popup"), LINGWU_BTN_ICON_STAT))
    lingwu_info_container.add_child(_make_lingwu_action_button("+ 治理增益栏位", GameState.LINGWU_CITY_BOOST_SLOT_COST, Callable(self, "_show_lingwu_city_slot_popup"), LINGWU_BTN_ICON_CITY))
    lingwu_info_container.add_child(_make_lingwu_action_button("+ 精研政务", GameState.LINGWU_CARD_UPGRADE_COST, Callable(self, "_show_lingwu_governance_card_popup"), LINGWU_BTN_ICON_CARD))
    if GameState.has_feature("kuixing"):
        lingwu_info_container.add_child(_make_lingwu_action_button("+ 识悟寻珍", LingwuItemDrawServiceRef.COST, Callable(self, "_show_lingwu_item_draw_popup"), LINGWU_BTN_ICON_ITEM_DRAW))
    if AdsConfigRef.ADS_ENABLED and OS.has_feature("android"):
        lingwu_info_container.add_child(_make_lingwu_reward_button())




    _apply_dynamic_side_pane_font_scale(lingwu_pane)


func _make_lingwu_reward_button() -> Control:


    var wrap: = MarginContainer.new()
    wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    wrap.add_theme_constant_override("margin_top", 8)

    var row: = HBoxContainer.new()
    row.alignment = BoxContainer.ALIGNMENT_CENTER
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    var btn: = Button.new()
    btn.name = "LingwuRewardButton"
    btn.text = "获取识悟"
    btn.custom_minimum_size = Vector2(88, 18)
    btn.focus_mode = Control.FOCUS_NONE
    btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    btn.tooltip_text = "观看激励视频额外获得识悟"
    btn.add_theme_font_override("font", FontLoader.body())
    btn.add_theme_font_size_override("font_size", 15)
    btn.add_theme_color_override("font_color", _left_panel_text_color("text_main"))
    btn.add_theme_color_override("font_hover_color", GameState.get_theme_color("border_active"))
    btn.add_theme_stylebox_override("normal", _make_zengyi_expand_button_style(false))
    btn.add_theme_stylebox_override("hover", _make_zengyi_expand_button_style(true))
    btn.add_theme_stylebox_override("pressed", _make_zengyi_expand_button_style(true))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    btn.pressed.connect( func():
        if NativeMobileTouchScrollRef.should_suppress_press(self, "lingwu_scroll_suppress_until"):
            return
        _show_lingwu_reward_popup()
    )
    btn.gui_input.connect( func(event: InputEvent):
        if is_instance_valid(lingwu_scroll):
            NativeMobileTouchScrollRef.forward_drag_to_scroll(event, lingwu_scroll, self, "lingwu_scroll_suppress_until")
    )
    row.add_child(btn)
    wrap.add_child(row)
    return wrap


func _apply_dynamic_side_pane_font_scale(pane: Control) -> void :
    if not _is_native_mobile_landscape():
        return
    NativeMobileFontScalerRef.apply_to(pane)


func _make_lingwu_action_button(label: String, _cost: int, on_press: Callable, icon: Texture2D = null) -> Button:



    var is_disabled: = false
    var accent: = GameState.get_theme_color("border_active")

    var btn: = Button.new()
    btn.text = ""
    btn.disabled = is_disabled
    btn.focus_mode = Control.FOCUS_NONE
    btn.clip_contents = true
    btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    var aspect: = 0.66
    btn.resized.connect( func():
        var target: = btn.size.x * aspect
        if target > 0.0 and absf(btn.custom_minimum_size.y - target) > 0.5:
            btn.custom_minimum_size.y = target
    )

    var radius: = 6
    var style_normal: = StyleBoxFlat.new()
    style_normal.corner_radius_top_left = radius
    style_normal.corner_radius_top_right = radius
    style_normal.corner_radius_bottom_left = radius
    style_normal.corner_radius_bottom_right = radius
    style_normal.border_width_left = 1
    style_normal.border_width_top = 1
    style_normal.border_width_right = 1
    style_normal.border_width_bottom = 1
    var style_hover: = style_normal.duplicate()
    var style_disabled: = style_normal.duplicate()

    if is_disabled:
        style_disabled.bg_color = Color(0.16, 0.11, 0.07, 0.55)
        style_disabled.border_color = Color(0.35, 0.28, 0.2, 0.3)
        btn.add_theme_stylebox_override("disabled", style_disabled)
    else:
        var border_col: = Color(accent.r, accent.g, accent.b, 0.26)
        style_normal.bg_color = Color(0.19, 0.14, 0.09, 0.85)
        style_normal.border_color = border_col
        style_hover.bg_color = Color(0.24, 0.18, 0.11, 0.92)
        style_hover.border_color = Color(accent.r, accent.g, accent.b, 0.55)
        btn.add_theme_stylebox_override("normal", style_normal)
        btn.add_theme_stylebox_override("hover", style_hover)
        btn.add_theme_stylebox_override("pressed", style_hover)


    if icon != null:
        var pic: = TextureRect.new()
        pic.texture = icon
        pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
        pic.clip_contents = true
        pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
        pic.set_anchors_preset(Control.PRESET_FULL_RECT)
        pic.anchor_bottom = 0.74
        pic.offset_left = 4
        pic.offset_top = 4
        pic.offset_right = -4
        pic.offset_bottom = 0
        if icon == LINGWU_BTN_ICON_ITEM_DRAW:
            pic.modulate = Color(0.58, 0.52, 0.4, 0.78)
        else:
            pic.modulate = Color(1, 1, 1, 0.4 if is_disabled else 1.0)
        btn.add_child(pic)


    var grad: = Gradient.new()
    grad.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
    grad.colors = PackedColorArray([
        Color(0.06, 0.04, 0.02, 0.0), 
        Color(0.06, 0.04, 0.02, 0.1), 
        Color(0.05, 0.035, 0.02, 0.92), 
    ])
    var grad_tex: = GradientTexture2D.new()
    grad_tex.gradient = grad
    grad_tex.width = 4
    grad_tex.height = 64
    grad_tex.fill_from = Vector2(0, 0)
    grad_tex.fill_to = Vector2(0, 1)
    var mask: = TextureRect.new()
    mask.texture = grad_tex
    mask.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    mask.stretch_mode = TextureRect.STRETCH_SCALE
    mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
    mask.set_anchors_preset(Control.PRESET_FULL_RECT)
    mask.offset_left = 2
    mask.offset_top = 2
    mask.offset_right = -2
    mask.offset_bottom = -2
    btn.add_child(mask)


    var lbl: = Label.new()
    lbl.text = label
    lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lbl.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
    lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
    lbl.add_theme_font_override("font", FontLoader.serif_bold())
    lbl.add_theme_font_size_override("font_size", 17 if _is_mobile_portrait() else 15)
    if is_disabled:
        lbl.add_theme_color_override("font_color", Color(0.6, 0.55, 0.5, 0.5))
    else:
        lbl.add_theme_color_override("font_color", Color(0.97, 0.9, 0.78, 1.0))
    lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
    lbl.offset_left = 8
    lbl.offset_top = 0
    lbl.offset_right = -8
    lbl.offset_bottom = -12
    btn.add_child(lbl)

    btn.pressed.connect( func():
        if NativeMobileTouchScrollRef.should_suppress_press(self, "lingwu_scroll_suppress_until"):
            return
        if on_press.is_valid():
            on_press.call()
    )
    btn.gui_input.connect( func(event: InputEvent):
        if is_instance_valid(lingwu_scroll):
            NativeMobileTouchScrollRef.forward_drag_to_scroll(event, lingwu_scroll, self, "lingwu_scroll_suppress_until")
    )
    return btn

func _close_lingwu_popup() -> void :
    if lingwu_popup_layer != null and is_instance_valid(lingwu_popup_layer):
        lingwu_popup_layer.queue_free()
    lingwu_popup_layer = null

func _make_lingwu_popup(title_text: String, height: float = 400.0, width: float = 580.0) -> VBoxContainer:
    _close_lingwu_popup()
    var viewport_size: = get_viewport_rect().size
    var popup_width: = minf(width, maxf(320.0, viewport_size.x - 32.0))
    var popup_height: = minf(height, maxf(300.0, viewport_size.y - 32.0))
    lingwu_popup_layer = CanvasLayer.new()
    lingwu_popup_layer.name = "LingwuPopupLayer"
    lingwu_popup_layer.layer = 115
    lingwu_popup_layer.add_to_group("blocking_modal_overlay")
    get_tree().root.add_child(lingwu_popup_layer)

    var dim: = ColorRect.new()
    dim.name = "LingwuPopupDim"
    dim.color = Color(0, 0, 0, 0.58)
    dim.set_anchors_preset(Control.PRESET_FULL_RECT)
    lingwu_popup_layer.add_child(dim)
    dim.gui_input.connect( func(event: InputEvent):
        var is_click: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
        var is_touch: bool = event is InputEventScreenTouch and event.pressed
        if is_click or is_touch:
            _close_lingwu_popup()
    )

    var panel: = PanelContainer.new()
    panel.name = "LingwuPopupPanel"
    panel.custom_minimum_size = Vector2(popup_width, popup_height)
    var popup_style: = _make_items_overlay_panel_style().duplicate()
    popup_style.border_color = DIANSHI_MODAL_BORDER
    panel.add_theme_stylebox_override("panel", popup_style)
    panel.set_anchors_preset(Control.PRESET_CENTER)
    var half_w: = popup_width / 2.0
    var half_h: = popup_height / 2.0
    panel.offset_left = - half_w
    panel.offset_right = half_w
    panel.offset_top = - half_h
    panel.offset_bottom = half_h
    lingwu_popup_layer.add_child(panel)

    var margin: = MarginContainer.new()
    for side in ["left", "right", "top", "bottom"]:
        margin.add_theme_constant_override("margin_" + side, 18)
    panel.add_child(margin)

    var root: = VBoxContainer.new()
    root.add_theme_constant_override("separation", 12)
    margin.add_child(root)

    var title: = Label.new()
    title.text = title_text
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", 21)
    title.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    root.add_child(title)

    var sep: = HSeparator.new()
    var sep_style: = StyleBoxLine.new()
    sep_style.color = DIANSHI_MODAL_BORDER
    sep_style.color.a = 0.25
    sep_style.thickness = 1
    sep.add_theme_stylebox_override("separator", sep_style)
    root.add_child(sep)


    call_deferred("_scale_lingwu_popup_for_mobile", panel)

    return root

func _scale_lingwu_popup_for_mobile(panel: PanelContainer) -> void :
    if not is_instance_valid(panel) or not panel.is_inside_tree():
        return
    if not NativeMobileFontScalerRef.is_native_phone_landscape(panel):
        return
    NativeMobileFontScalerRef.apply_to(panel)
    var viewport_size: = get_viewport_rect().size
    var scaled_width: = minf(panel.custom_minimum_size.x, maxf(320.0, viewport_size.x - 32.0))
    var scaled_height: = minf(panel.custom_minimum_size.y, maxf(300.0, viewport_size.y - 32.0))
    panel.custom_minimum_size = Vector2(scaled_width, scaled_height)
    panel.offset_left = - scaled_width / 2.0
    panel.offset_right = scaled_width / 2.0
    panel.offset_top = - scaled_height / 2.0
    panel.offset_bottom = scaled_height / 2.0

func _show_lingwu_reward_popup() -> void :
    var root: = _make_lingwu_popup("获取识悟", 460.0, 620.0)

    var explanation: = Label.new()
    explanation.text = "识悟可在游玩过程中获得，依靠游戏内获得的识悟即可正常完成游戏。\n\n观看激励视频可额外获得识悟，用于降低挑战压力、改善游玩体验，并非通关的必要条件。\n\n若仍觉得难度较高，可在开始游戏选择开局时切换为简单模式。"
    explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    explanation.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    explanation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    explanation.size_flags_vertical = Control.SIZE_EXPAND_FILL
    explanation.add_theme_font_override("font", FontLoader.body())
    explanation.add_theme_font_size_override("font_size", 15)
    explanation.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    explanation.add_theme_constant_override("line_spacing", 6)
    root.add_child(explanation)

    var status: = Label.new()
    status.name = "LingwuRewardStatus"
    status.text = "正在加载激励视频……" if _lingwu_reward_request_pending else ""
    status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status.add_theme_font_override("font", FontLoader.body())
    status.add_theme_font_size_override("font_size", 13)
    status.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    root.add_child(status)
    _lingwu_reward_status_label = status

    var bottom_row: = HBoxContainer.new()
    bottom_row.alignment = BoxContainer.ALIGNMENT_CENTER
    bottom_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    bottom_row.add_theme_constant_override("separation", 24)
    root.add_child(bottom_row)

    var return_btn: = _make_lingwu_return_button()
    return_btn.custom_minimum_size = Vector2(150, 56)
    bottom_row.add_child(return_btn)

    var reward_btn: = _make_shezhi_button("查看广告\n获得 10 点识悟", Callable(self, "_on_lingwu_reward_ad_pressed"))
    reward_btn.name = "LingwuRewardAdButton"
    reward_btn.custom_minimum_size = Vector2(210, 56)
    reward_btn.add_theme_font_size_override("font_size", 15)
    reward_btn.disabled = _lingwu_reward_request_pending
    _style_lingwu_confirm_button(reward_btn, reward_btn.disabled)
    reward_btn.custom_minimum_size = Vector2(210, 56)
    bottom_row.add_child(reward_btn)
    _lingwu_reward_button = reward_btn

func _show_lingwu_item_draw_popup() -> void :
    _lingwu_item_draw_token += 1
    _lingwu_item_draw_in_progress = false
    var root: = _make_lingwu_popup("识悟寻珍", 400.0, 560.0)

    var spacer_top: = Control.new()
    spacer_top.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(spacer_top)

    var explanation: = Label.new()
    explanation.text = "耗费二十点识悟，可从行囊尚未收录的物件中随机寻得一件。"
    explanation.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    explanation.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    explanation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    explanation.add_theme_font_override("font", FontLoader.body())
    explanation.add_theme_font_size_override("font_size", 15)
    explanation.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    explanation.add_theme_constant_override("line_spacing", 6)
    root.add_child(explanation)

    var current_value: = Label.new()
    current_value.text = "当前识悟：%d" % int(GameState.lingwu)
    current_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    current_value.add_theme_font_override("font", FontLoader.body())
    current_value.add_theme_font_size_override("font_size", 14)
    current_value.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    root.add_child(current_value)

    var spacer_bottom: = Control.new()
    spacer_bottom.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(spacer_bottom)

    var bottom_row: = HBoxContainer.new()
    bottom_row.alignment = BoxContainer.ALIGNMENT_CENTER
    bottom_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    bottom_row.add_theme_constant_override("separation", 24)
    root.add_child(bottom_row)

    var return_btn: = _make_lingwu_return_button()
    return_btn.custom_minimum_size = Vector2(150, 56)
    bottom_row.add_child(return_btn)

    var confirm_disabled: = int(GameState.lingwu) < LingwuItemDrawServiceRef.COST
    var confirm_btn: = _make_shezhi_button("寻珍一回\n消耗 20 点识悟", Callable(self, "_confirm_lingwu_item_draw"))
    confirm_btn.name = "LingwuItemDrawConfirmButton"
    confirm_btn.disabled = confirm_disabled
    confirm_btn.custom_minimum_size = Vector2(210, 56)
    confirm_btn.add_theme_font_size_override("font_size", 15)
    _style_lingwu_confirm_button(confirm_btn, confirm_disabled)
    confirm_btn.custom_minimum_size = Vector2(210, 56)
    bottom_row.add_child(confirm_btn)

func _confirm_lingwu_item_draw() -> void :
    if _lingwu_item_draw_in_progress:
        return
    _lingwu_item_draw_in_progress = true
    var request_token: = _lingwu_item_draw_token
    call_deferred("_release_lingwu_item_draw_guard", request_token)
    var result: Dictionary = LingwuItemDrawServiceRef.draw(GameState)
    var status: = str(result.get("status", "unavailable"))
    match status:
        "insufficient", "unavailable":
            return
        "refunded":
            _close_lingwu_popup()
            _refresh_panels()
            _transition_toast_controller.show_simple_toast("已无新物可寻，识悟 +20 已返还")
        "item":
            var item_id: = str(result.get("item_id", ""))
            _finish_lingwu_item_draw(item_id, false)
        "kuixing":
            var item_id: = str(result.get("item_id", ""))
            _finish_lingwu_item_draw(item_id, true)

func _release_lingwu_item_draw_guard(request_token: int) -> void :
    if request_token != _lingwu_item_draw_token:
        return
    _lingwu_item_draw_in_progress = false

func _finish_lingwu_item_draw(item_id: String, is_kuixing: bool) -> void :
    _close_lingwu_popup()
    _refresh_panels()
    _animate_lingwu_reward_value( - LingwuItemDrawServiceRef.COST)
    _show_lingwu_item_result_popup(item_id)
    if is_kuixing:
        _transition_toast_controller.show_simple_toast("魁星符 +1")
    else:
        var detail: = ItemDetailBuilderRef.build(item_id)
        var item_name: = str(detail.get("name", "无名物件"))
        _transition_toast_controller.show_simple_toast("已得：%s" % item_name)

func _show_lingwu_item_result_popup(item_id: String) -> void :
    var root: = _make_lingwu_popup("新得一物", 560.0, 540.0)
    var detail: = ItemDetailBuilderRef.build(item_id)

    var result_scroll: = ScrollContainer.new()
    result_scroll.name = "LingwuItemResultScroll"
    result_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    result_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    result_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    result_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    ScrollbarThemeRef.apply_to(result_scroll)
    result_scroll.gui_input.connect( func(event: InputEvent):
        NativeMobileTouchScrollRef.forward_drag_to_scroll(event, result_scroll, self, "lingwu_item_result_scroll_suppress_until")
    )
    root.add_child(result_scroll)

    var card_margin: = MarginContainer.new()
    card_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    for side in ["left", "right", "top", "bottom"]:
        card_margin.add_theme_constant_override("margin_" + side, 12)
    result_scroll.add_child(card_margin)

    var card: = PanelContainer.new()
    card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var card_style: = StyleBoxFlat.new()
    card_style.bg_color = Color(0.1, 0.075, 0.045, 0.46)
    card_style.border_width_left = 1
    card_style.border_width_top = 1
    card_style.border_width_right = 1
    card_style.border_width_bottom = 1
    card_style.border_color = Color(DIANSHI_MODAL_BORDER.r, DIANSHI_MODAL_BORDER.g, DIANSHI_MODAL_BORDER.b, 0.34)
    card_style.corner_radius_top_left = 4
    card_style.corner_radius_top_right = 4
    card_style.corner_radius_bottom_left = 4
    card_style.corner_radius_bottom_right = 4
    card.add_theme_stylebox_override("panel", card_style)
    card_margin.add_child(card)

    var content_margin: = MarginContainer.new()
    for side in ["left", "right", "top", "bottom"]:
        content_margin.add_theme_constant_override("margin_" + side, 18)
    card.add_child(content_margin)

    var content: = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 12)
    content_margin.add_child(content)

    if detail.is_empty():
        var missing: = Label.new()
        missing.text = "未找到物件详情，但所得物件已收入行囊。"
        missing.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        missing.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        missing.add_theme_font_override("font", FontLoader.body())
        missing.add_theme_font_size_override("font_size", 14)
        missing.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        content.add_child(missing)
    else:
        _append_lingwu_item_result_label(content, str(detail.get("name", "无名物件")), "text_main", 20, FontLoader.title())
        _append_lingwu_item_result_label(content, "得自 " + str(detail.get("source", "随身旧物")), "text_sub", 12)
        _append_lingwu_item_result_label(content, str(detail.get("body", "")), "text_desc", 14)
        var effect: = str(detail.get("effect", ""))
        if effect != "":
            _append_lingwu_item_result_label(content, "效果", "text_sub", 12)
            _append_lingwu_item_result_label(content, effect, "border_active", 14)
        _append_lingwu_item_result_label(content, str(detail.get("note", "")), "text_sub", 12)
        if item_id == SaveManager.KUIXING_FU_ITEM_ID:
            _append_lingwu_item_result_label(
                content, 
                "当前持有：%d / %d" % [SaveManager.get_current_kuixing_fu_count(GameState), SaveManager.KUIXING_FU_MAX_COUNT], 
                "border_active", 
                13
            )

    var close_btn: = _make_shezhi_button("收入行囊", Callable(self, "_close_lingwu_popup"))
    close_btn.custom_minimum_size = Vector2(210, 48)
    close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    _style_lingwu_confirm_button(close_btn, false)
    close_btn.custom_minimum_size = Vector2(210, 48)
    root.add_child(close_btn)

func _append_lingwu_item_result_label(
    parent: Control, 
    text: String, 
    color_key: String, 
    font_size: int, 
    font: Font = null
) -> void :
    if text == "":
        return
    var label: = Label.new()
    label.text = text
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    label.add_theme_font_override("font", font if font != null else FontLoader.body())
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", GameState.get_theme_color(color_key))
    parent.add_child(label)

func _on_lingwu_reward_ad_pressed() -> void :
    if _lingwu_reward_request_pending:
        return
    _lingwu_reward_request_pending = true
    if is_instance_valid(_lingwu_reward_button):
        _lingwu_reward_button.disabled = true
    if is_instance_valid(_lingwu_reward_status_label):
        _lingwu_reward_status_label.text = "正在加载激励视频……"
    if not AndroidRewardAdService.show_lingwu_reward_ad():
        _set_lingwu_reward_error("激励视频暂不可用，请稍后再试")

func _on_android_reward_granted(reward_type: String) -> void :
    if reward_type != "lingwu":
        return
    _lingwu_reward_request_pending = false
    GameState.lingwu += 10
    _close_lingwu_popup()
    _refresh_panels()



    if _app_backgrounded:
        _pending_lingwu_reward_toast = 10
    else:
        _play_lingwu_reward_feedback(10)

func _play_lingwu_reward_feedback(amount: int) -> void :
    _animate_lingwu_reward_value(amount)
    _transition_toast_controller.show_simple_toast("识悟 +%d" % amount)

func _notification(what: int) -> void :
    match what:
        NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT:
            _app_backgrounded = true
        NOTIFICATION_APPLICATION_RESUMED, NOTIFICATION_APPLICATION_FOCUS_IN:
            _app_backgrounded = false
            _flush_pending_lingwu_reward_toast()

func _flush_pending_lingwu_reward_toast() -> void :
    if _pending_lingwu_reward_toast <= 0 or not is_inside_tree():
        return
    var amount: = _pending_lingwu_reward_toast
    _pending_lingwu_reward_toast = 0

    _play_lingwu_reward_feedback.call_deferred(amount)

func _on_android_reward_failed(reward_type: String, message: String = "") -> void :
    if reward_type != "lingwu":
        return
    _set_lingwu_reward_error(message)

func _on_android_reward_unavailable(reward_type: String, message: String = "") -> void :
    if reward_type != "lingwu":
        return
    _set_lingwu_reward_error(message)

func _set_lingwu_reward_error(message: String) -> void :
    _lingwu_reward_request_pending = false
    if is_instance_valid(_lingwu_reward_button):
        _lingwu_reward_button.disabled = false
    if is_instance_valid(_lingwu_reward_status_label):
        _lingwu_reward_status_label.text = message if message != "" else "激励视频未完成，请稍后再试"

func _animate_lingwu_reward_value(amount: int) -> void :
    if not is_instance_valid(lingwu_info_container):
        return
    var value_label: = lingwu_info_container.find_child("LingwuCurrentValue", true, false) as Label
    if value_label == null:
        return
    _animate_control_value_change(value_label, amount, GameState.lingwu)

func _show_lingwu_stat_popup() -> void :
    var root: = _make_lingwu_popup("提升个人禀赋", 660.0)
    _lingwu_stat_popup_last_press_frame = -1
    _lingwu_selected_stat_key = str(PERSONAL_STAT_KEYS[0])
    _lingwu_stat_multiplier = 1
    _lingwu_stat_value_labels = {}
    _lingwu_stat_scroll = null
    for key in PERSONAL_STAT_KEYS:
        if not _lingwu_stat_multipliers.has(key):
            _lingwu_stat_multipliers[key] = 1
    _lingwu_stat_multiplier = clampi(int(_lingwu_stat_multipliers.get(_lingwu_selected_stat_key, 1)), 1, _get_lingwu_stat_max_multiplier())
    _lingwu_stat_multipliers[_lingwu_selected_stat_key] = _lingwu_stat_multiplier

    var stat_scroll: = ScrollContainer.new()
    stat_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    stat_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    stat_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    stat_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
    ScrollbarThemeRef.apply_to(stat_scroll)
    stat_scroll.gui_input.connect(_on_lingwu_stat_popup_touch_drag)
    root.add_child(stat_scroll)
    _lingwu_stat_scroll = stat_scroll

    var stat_body: = VBoxContainer.new()
    stat_body.add_theme_constant_override("separation", 12)
    stat_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    stat_scroll.add_child(stat_body)

    var radar_container: = PanelContainer.new()
    var empty_style: = StyleBoxEmpty.new()
    radar_container.add_theme_stylebox_override("panel", empty_style)


    var stat_phone: = NativeMobileFontScalerRef.is_native_phone_landscape(self)
    radar_container.custom_minimum_size = Vector2(0, 190.0 if stat_phone else 220.0)
    radar_container.set_meta(NativeMobileFontScalerRef.META_SKIP_MIN_SIZE_SCALE, true)
    stat_body.add_child(radar_container)

    var radar: = preload("res://scripts/ui/radar_chart.gd").new()
    radar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    radar.size_flags_vertical = Control.SIZE_EXPAND_FILL

    radar.set_meta(NativeMobileFontScalerRef.META_SKIP_MIN_SIZE_SCALE, true)
    radar.force_dark_palette = (GameState.theme == "light")
    radar_container.add_child(radar)
    _lingwu_stat_radar = radar
    radar.update_stats(GameState.stats)

    var rows_holder: = VBoxContainer.new()
    rows_holder.add_theme_constant_override("separation", 8)
    rows_holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    stat_body.add_child(rows_holder)
    _lingwu_stat_rows_holder = rows_holder
    _refresh_lingwu_stat_rows()

    var spacer_bottom: = Control.new()
    spacer_bottom.custom_minimum_size = Vector2(0, 8)
    root.add_child(spacer_bottom)

    var total_lbl: = Label.new()
    total_lbl.text = "当前识悟：%d" % int(GameState.lingwu)
    total_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    total_lbl.add_theme_font_override("font", FontLoader.body())
    total_lbl.add_theme_font_size_override("font_size", 14)
    var total_lbl_color: = GameState.get_theme_color("text_desc")
    total_lbl_color.a *= 0.6
    total_lbl.add_theme_color_override("font_color", total_lbl_color)
    root.add_child(total_lbl)
    _lingwu_stat_total_label = total_lbl

    var total_lbl_spacer: = Control.new()
    total_lbl_spacer.custom_minimum_size = Vector2(0, 10)
    root.add_child(total_lbl_spacer)

    var bottom_row: = HBoxContainer.new()
    bottom_row.alignment = BoxContainer.ALIGNMENT_CENTER
    bottom_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    bottom_row.add_theme_constant_override("separation", 16)
    root.add_child(bottom_row)
    var return_btn: = _make_lingwu_return_button()
    return_btn.custom_minimum_size.x = 120
    bottom_row.add_child(return_btn)

    var confirm_holder: = PanelContainer.new()
    confirm_holder.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    confirm_holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    bottom_row.add_child(confirm_holder)
    _lingwu_stat_confirm_holder = confirm_holder
    _refresh_lingwu_stat_confirm_button()

func _refresh_lingwu_stat_rows() -> void :
    if _lingwu_stat_rows_holder == null or not is_instance_valid(_lingwu_stat_rows_holder):
        return
    _lingwu_stat_value_labels = {}
    for child in _lingwu_stat_rows_holder.get_children():
        child.queue_free()
    for key in PERSONAL_STAT_KEYS:
        _lingwu_stat_rows_holder.add_child(_make_lingwu_stat_choice_row(key))

    NativeMobileFontScalerRef.apply_to(_lingwu_stat_rows_holder)

func _make_lingwu_stat_choice_row(stat_key: String) -> Control:
    var current_val: = int(GameState.stats.get(stat_key, 0))
    var is_maxed: = current_val >= 100
    var is_disabled: = int(GameState.lingwu) < GameState.LINGWU_STAT_COST or is_maxed
    var selected: = _lingwu_selected_stat_key == stat_key
    var label: = str(PERSONAL_STAT_LABELS.get(stat_key, stat_key))
    var row_width: = minf(560.0, maxf(292.0, get_viewport_rect().size.x - 96.0))
    var card: = PanelContainer.new()
    card.custom_minimum_size = Vector2(row_width, 38)

    card.set_meta(NativeMobileFontScalerRef.META_SKIP_MIN_SIZE_SCALE, true)
    card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    card.gui_input.connect( func(event: InputEvent):
        _on_lingwu_stat_popup_touch_drag(event)
        _try_select_lingwu_stat_from_event(event, stat_key)
    )

    var accent: = GameState.get_theme_color("border_active")
    var card_style: = StyleBoxFlat.new()
    card_style.bg_color = Color(accent.r, accent.g, accent.b, 0.32 if selected else 0.12)
    card_style.border_width_left = 1
    card_style.border_width_top = 1
    card_style.border_width_right = 1
    card_style.border_width_bottom = 1
    card_style.border_color = Color(accent.r, accent.g, accent.b, 0.26 if selected else 0.18)
    card_style.corner_radius_top_left = 4
    card_style.corner_radius_top_right = 4
    card_style.corner_radius_bottom_left = 4
    card_style.corner_radius_bottom_right = 4
    card_style.content_margin_left = 12
    card_style.content_margin_right = 12
    card.add_theme_stylebox_override("panel", card_style)

    var card_body: = HBoxContainer.new()
    card_body.add_theme_constant_override("separation", 10)
    card.add_child(card_body)

    var label_left: = Label.new()
    label_left.text = label + ("已满" if is_maxed else "加1")
    label_left.custom_minimum_size.x = 12
    label_left.add_theme_font_override("font", FontLoader.body())
    label_left.add_theme_font_size_override("font_size", 14)
    label_left.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4, 0.4) if is_disabled else Color(0.95, 0.9, 0.85, 1.0))
    label_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
    card_body.add_child(label_left)

    var spacer: = Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    card_body.add_child(spacer)

    var stepper: = _make_lingwu_stat_multiplier_stepper(stat_key, is_disabled)
    stepper.gui_input.connect(_on_lingwu_stat_popup_touch_drag)
    card_body.add_child(stepper)
    return card

func _make_lingwu_stat_multiplier_stepper(stat_key: String, is_disabled: bool) -> HBoxContainer:
    var selected: = _lingwu_selected_stat_key == stat_key
    var multiplier: = int(_lingwu_stat_multipliers.get(stat_key, 1))
    if selected:
        multiplier = _lingwu_stat_multiplier
    var max_multiplier: = _get_lingwu_stat_max_multiplier_for_key(stat_key)
    multiplier = clampi(multiplier, 1, max_multiplier)
    _lingwu_stat_multipliers[stat_key] = multiplier

    var stepper: = HBoxContainer.new()
    stepper.alignment = BoxContainer.ALIGNMENT_CENTER
    stepper.add_theme_constant_override("separation", 0)
    stepper.custom_minimum_size = Vector2(84, 38)

    var minus: = _make_lingwu_stepper_button("-", Callable(self, "_select_and_change_lingwu_stat_multiplier").bind(stat_key, -1))
    minus.disabled = is_disabled or multiplier <= 1
    stepper.add_child(minus)

    var lbl: = Label.new()
    lbl.text = "×%d" % multiplier
    lbl.custom_minimum_size = Vector2(36, 0)
    lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    lbl.add_theme_font_override("font", FontLoader.body())
    lbl.add_theme_font_size_override("font_size", 13)
    lbl.add_theme_color_override("font_color", GameState.get_theme_color("border_active") if selected else GameState.get_theme_color("text_desc"))
    stepper.add_child(lbl)

    var plus: = _make_lingwu_stepper_button("+", Callable(self, "_select_and_change_lingwu_stat_multiplier").bind(stat_key, 1))
    plus.disabled = is_disabled or multiplier >= max_multiplier
    stepper.add_child(plus)
    return stepper

func _make_lingwu_stepper_button(label_text: String, on_press: Callable) -> Button:
    var btn: = _make_shezhi_button(label_text, on_press)
    btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    _style_lingwu_stepper_round_button(btn)
    btn.custom_minimum_size = Vector2(24, 24)
    btn.gui_input.connect(_on_lingwu_stat_popup_touch_drag)
    return btn

func _style_lingwu_stepper_round_button(btn: Button) -> void :
    btn.custom_minimum_size = Vector2(24, 24)

    var style_normal: = StyleBoxFlat.new()
    style_normal.corner_radius_top_left = 12
    style_normal.corner_radius_top_right = 12
    style_normal.corner_radius_bottom_left = 12
    style_normal.corner_radius_bottom_right = 12
    style_normal.content_margin_left = 0
    style_normal.content_margin_right = 0
    style_normal.content_margin_top = 0
    style_normal.content_margin_bottom = 0

    var style_hover: = style_normal.duplicate()
    var style_disabled: = style_normal.duplicate()

    var accent: = GameState.get_theme_color("border_active")
    var border_col: = Color(accent.r, accent.g, accent.b, 0.26)

    style_disabled.bg_color = Color(0.2, 0.14, 0.09, 0.1)
    style_disabled.border_width_left = 1
    style_disabled.border_width_top = 1
    style_disabled.border_width_right = 1
    style_disabled.border_width_bottom = 1
    style_disabled.border_color = Color(0.35, 0.28, 0.2, 0.15)
    btn.add_theme_stylebox_override("disabled", style_disabled)
    btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.45, 0.4, 0.4))

    style_normal.bg_color = Color(0.28, 0.2, 0.13, 0.3)
    style_normal.border_width_left = 1
    style_normal.border_width_top = 1
    style_normal.border_width_right = 1
    style_normal.border_width_bottom = 1
    style_normal.border_color = border_col

    style_hover.bg_color = Color(0.34, 0.25, 0.16, 0.5)
    style_hover.border_width_left = 1
    style_hover.border_width_top = 1
    style_hover.border_width_right = 1
    style_hover.border_width_bottom = 1
    style_hover.border_color = Color(accent.r, accent.g, accent.b, 0.55)

    btn.add_theme_stylebox_override("normal", style_normal)
    btn.add_theme_stylebox_override("hover", style_hover)
    btn.add_theme_stylebox_override("pressed", style_hover)
    btn.add_theme_color_override("font_color", Color(0.95, 0.9, 0.85, 1.0))

func _select_lingwu_stat(stat_key: String) -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(self, "lingwu_stat_popup_scroll_suppress_until"):
        return
    if not PERSONAL_STAT_KEYS.has(stat_key):
        return
    _lingwu_selected_stat_key = stat_key
    _lingwu_stat_multiplier = int(_lingwu_stat_multipliers.get(stat_key, 1))
    _lingwu_stat_multiplier = clampi(_lingwu_stat_multiplier, 1, _get_lingwu_stat_max_multiplier())
    _lingwu_stat_multipliers[stat_key] = _lingwu_stat_multiplier
    _refresh_lingwu_stat_rows()
    _refresh_lingwu_stat_confirm_button()

func _try_select_lingwu_stat_from_event(event: InputEvent, stat_key: String) -> void :
    if not _is_primary_press_event(event):
        return
    if NativeMobileTouchScrollRef.should_suppress_press(self, "lingwu_stat_popup_scroll_suppress_until"):
        return


    var press_frame: = Engine.get_process_frames()
    if _lingwu_stat_popup_last_press_frame == press_frame:
        return
    _lingwu_stat_popup_last_press_frame = press_frame
    _select_lingwu_stat(stat_key)

func _select_and_change_lingwu_stat_multiplier(stat_key: String, delta: int) -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(self, "lingwu_stat_popup_scroll_suppress_until"):
        return
    _select_lingwu_stat(stat_key)
    _change_lingwu_stat_multiplier(delta)

func _on_lingwu_stat_popup_touch_drag(event: InputEvent) -> void :
    if _lingwu_stat_scroll == null or not is_instance_valid(_lingwu_stat_scroll):
        return
    NativeMobileTouchScrollRef.forward_drag_to_scroll(event, _lingwu_stat_scroll, self, "lingwu_stat_popup_scroll_suppress_until")

func _change_lingwu_stat_multiplier(delta: int) -> void :
    if _lingwu_selected_stat_key == "":
        return
    _lingwu_stat_multiplier = clampi(_lingwu_stat_multiplier + delta, 1, _get_lingwu_stat_max_multiplier())
    _lingwu_stat_multipliers[_lingwu_selected_stat_key] = _lingwu_stat_multiplier
    _refresh_lingwu_stat_rows()
    _refresh_lingwu_stat_confirm_button()

func _get_lingwu_stat_max_multiplier() -> int:
    if _lingwu_selected_stat_key == "":
        return 1
    return _get_lingwu_stat_max_multiplier_for_key(_lingwu_selected_stat_key)

func _get_lingwu_stat_max_multiplier_for_key(stat_key: String) -> int:
    if not GameState.stats.has(stat_key):
        return 1
    var remaining: = maxi(0, 100 - int(GameState.stats.get(stat_key, 0)))
    var affordable: = int(floor(float(GameState.lingwu) / float(GameState.LINGWU_STAT_COST)))
    return maxi(1, mini(remaining, affordable))

func _refresh_lingwu_stat_confirm_button() -> void :
    if _lingwu_stat_confirm_holder == null or not is_instance_valid(_lingwu_stat_confirm_holder):
        return
    for ch in _lingwu_stat_confirm_holder.get_children():
        ch.queue_free()
    var has_sel: = _lingwu_selected_stat_key != ""
    var cost: = _lingwu_stat_multiplier * GameState.LINGWU_STAT_COST
    var is_disabled: = ( not has_sel) or int(GameState.lingwu) < cost or int(GameState.stats.get(_lingwu_selected_stat_key, 0)) >= 100
    var label: = "确定"
    var cost_text: = "减%d识悟" % cost if has_sel else "请选择"
    var btn: = _make_lingwu_stat_option_button(label, cost_text, is_disabled, Callable(self, "_confirm_lingwu_stat"))
    btn.custom_minimum_size = Vector2(220, 38)
    _lingwu_stat_confirm_holder.add_child(btn)

    NativeMobileFontScalerRef.apply_to(_lingwu_stat_confirm_holder)

func _update_lingwu_stat_total_label() -> void :
    if _lingwu_stat_total_label != null and is_instance_valid(_lingwu_stat_total_label):
        _lingwu_stat_total_label.text = "当前识悟：%d" % int(GameState.lingwu)

func _animate_lingwu_stat_value_label(stat_key: String, diff: int) -> void :
    var label = _lingwu_stat_value_labels.get(stat_key)
    if label == null or not is_instance_valid(label):
        _refresh_lingwu_stat_rows()
        return
    var final_val: = int(GameState.stats.get(stat_key, 0))
    var start_val: = final_val - diff
    label.visible = true
    label.modulate.a = 1.0
    label.text = str(start_val)
    var tween: Tween = label.create_tween()
    var update_text_func = func(value: float):
        if is_instance_valid(label):
            label.text = "当前%d" % int(round(value))
    tween.tween_method(update_text_func, float(start_val), float(final_val), 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    _spawn_floating_change_label(label, diff)
    CardAnimations.play_pulse(label, diff > 0, true)
    tween.tween_callback( func():
        if is_instance_valid(label):
            label.text = "当前%d" % final_val
        _refresh_lingwu_stat_rows()
    )

func _make_lingwu_return_button() -> Button:
    var btn: = _make_shezhi_button("返回", Callable(self, "_close_lingwu_popup"))
    btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    btn.custom_minimum_size = Vector2(160, 38)

    var style_ret: = StyleBoxFlat.new()
    style_ret.bg_color = Color(0.2, 0.14, 0.09, 0.35)
    style_ret.border_width_left = 1
    style_ret.border_width_top = 1
    style_ret.border_width_right = 1
    style_ret.border_width_bottom = 1
    style_ret.border_color = Color(0.42, 0.43, 0.44, 0.18)
    style_ret.corner_radius_top_left = 4
    style_ret.corner_radius_top_right = 4
    style_ret.corner_radius_bottom_left = 4
    style_ret.corner_radius_bottom_right = 4
    style_ret.content_margin_left = 12
    style_ret.content_margin_right = 12
    style_ret.content_margin_top = 8
    style_ret.content_margin_bottom = 8
    btn.add_theme_stylebox_override("normal", style_ret)

    var style_ret_hover: = style_ret.duplicate()
    style_ret_hover.bg_color = Color(0.3, 0.22, 0.15, 0.5)
    style_ret_hover.border_color = Color(0.42, 0.43, 0.44, 0.3)
    btn.add_theme_stylebox_override("hover", style_ret_hover)
    btn.add_theme_stylebox_override("pressed", style_ret_hover)
    return btn

func _style_lingwu_confirm_button(btn: Button, is_disabled: bool) -> void :
    btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    btn.custom_minimum_size = Vector2(360, 38)

    var style_normal: = StyleBoxFlat.new()
    style_normal.corner_radius_top_left = 4
    style_normal.corner_radius_top_right = 4
    style_normal.corner_radius_bottom_left = 4
    style_normal.corner_radius_bottom_right = 4
    style_normal.content_margin_left = 12
    style_normal.content_margin_right = 12
    style_normal.content_margin_top = 8
    style_normal.content_margin_bottom = 8

    var style_hover: = style_normal.duplicate()
    var style_disabled: = style_normal.duplicate()

    var accent: = GameState.get_theme_color("border_active")
    var border_col: = Color(accent.r, accent.g, accent.b, 0.26)

    if is_disabled:
        style_disabled.bg_color = Color(0.2, 0.14, 0.09, 0.1)
        style_disabled.border_width_left = 1
        style_disabled.border_width_top = 1
        style_disabled.border_width_right = 1
        style_disabled.border_width_bottom = 1
        style_disabled.border_color = Color(0.35, 0.28, 0.2, 0.15)
        btn.add_theme_stylebox_override("disabled", style_disabled)
        btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.45, 0.4, 0.4))
    else:
        style_normal.bg_color = Color(0.28, 0.2, 0.13, 0.3)
        style_normal.border_width_left = 1
        style_normal.border_width_top = 1
        style_normal.border_width_right = 1
        style_normal.border_width_bottom = 1
        style_normal.border_color = border_col

        style_hover.bg_color = Color(0.34, 0.25, 0.16, 0.5)
        style_hover.border_width_left = 1
        style_hover.border_width_top = 1
        style_hover.border_width_right = 1
        style_hover.border_width_bottom = 1
        style_hover.border_color = Color(accent.r, accent.g, accent.b, 0.55)

        btn.add_theme_stylebox_override("normal", style_normal)
        btn.add_theme_stylebox_override("hover", style_hover)
        btn.add_theme_stylebox_override("pressed", style_hover)
        btn.add_theme_color_override("font_color", Color(0.95, 0.9, 0.85, 1.0))

func _make_lingwu_stat_option_button(label: String, cost_text: String, is_disabled: bool, on_press: Callable) -> Button:
    var btn: = _make_shezhi_button("", on_press)
    btn.disabled = is_disabled
    btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    btn.custom_minimum_size = Vector2(360, 38)

    var hbox: = HBoxContainer.new()
    hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
    hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    hbox.add_theme_constant_override("separation", 10)
    btn.add_child(hbox)

    var margin_left: = Control.new()
    margin_left.custom_minimum_size = Vector2(12, 0)
    margin_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hbox.add_child(margin_left)

    var lbl_left: = Label.new()
    lbl_left.text = label
    lbl_left.add_theme_font_override("font", FontLoader.body())
    lbl_left.add_theme_font_size_override("font_size", 14)
    lbl_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hbox.add_child(lbl_left)

    var spacer: = Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hbox.add_child(spacer)

    var lbl_right: = Label.new()
    lbl_right.text = cost_text
    lbl_right.add_theme_font_override("font", FontLoader.body())
    lbl_right.add_theme_font_size_override("font_size", 13)
    lbl_right.mouse_filter = Control.MOUSE_FILTER_IGNORE

    if is_disabled:
        lbl_left.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4, 0.4))
        lbl_right.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4, 0.3))
    else:
        lbl_left.add_theme_color_override("font_color", Color(0.95, 0.9, 0.85, 1.0))
        lbl_right.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75, 0.8))
    hbox.add_child(lbl_right)
    btn.set_meta("lingwu_right_label", lbl_right)

    var margin_right: = Control.new()
    margin_right.custom_minimum_size = Vector2(12, 0)
    margin_right.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hbox.add_child(margin_right)

    _style_lingwu_confirm_button(btn, is_disabled)
    return btn

func _confirm_lingwu_stat() -> void :
    var stat_key: = _lingwu_selected_stat_key
    if stat_key == "":
        return
    var old_val: = int(GameState.stats.get(stat_key, 0))
    var applied: = GameState.spend_lingwu_for_stat_amount(stat_key, _lingwu_stat_multiplier)
    if applied <= 0:
        _refresh_lingwu_stat_rows()
        _refresh_lingwu_stat_confirm_button()
        _update_lingwu_stat_total_label()
        return
    var stat_name: = str(PERSONAL_STAT_LABELS.get(stat_key, stat_key))
    var new_val: = int(GameState.stats.get(stat_key, 0))
    _lingwu_stat_multiplier = clampi(int(_lingwu_stat_multipliers.get(stat_key, 1)), 1, _get_lingwu_stat_max_multiplier())
    _lingwu_stat_multipliers[stat_key] = _lingwu_stat_multiplier
    if _lingwu_stat_radar != null and is_instance_valid(_lingwu_stat_radar):
        _lingwu_stat_radar.update_stats(GameState.stats)
    _animate_lingwu_stat_value_label(stat_key, new_val - old_val)
    _update_lingwu_stat_total_label()
    _refresh_lingwu_stat_confirm_button()
    _refresh_panels()
    _transition_toast_controller.show_simple_toast("%s已提升至 %d" % [stat_name, new_val])

func _show_lingwu_city_slot_popup() -> void :
    var root: = _make_lingwu_popup("扩充治理增益栏位", 420.0, 440.0)

    var spacer_top: = Control.new()
    spacer_top.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(spacer_top)

    var accent: = GameState.get_theme_color("border_active")

    var info_group: = VBoxContainer.new()
    info_group.add_theme_constant_override("separation", 18)
    info_group.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    root.add_child(info_group)


    var info: = RichTextLabel.new()
    info.bbcode_enabled = true
    info.fit_content = true
    info.scroll_active = false
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.custom_minimum_size = Vector2(320, 0)
    info.add_theme_font_override("normal_font", FontLoader.body())
    info.add_theme_font_size_override("normal_font_size", 14)
    var accent_hex: = accent.to_html(false)
    var desc_col: = GameState.get_theme_color("text_desc")
    info.add_theme_color_override("default_color", desc_col)
    info.text = "[center]消耗 [color=#%s][b]10[/b][/color] 点识悟\n永久增加一个治理增益栏位[/center]" % accent_hex
    info_group.add_child(info)


    var stat_card: = PanelContainer.new()
    var card_style: = StyleBoxFlat.new()
    card_style.bg_color = Color(accent.r, accent.g, accent.b, 0.06)
    card_style.border_width_left = 1
    card_style.border_width_top = 1
    card_style.border_width_right = 1
    card_style.border_width_bottom = 1
    card_style.border_color = Color(accent.r, accent.g, accent.b, 0.22)
    card_style.corner_radius_top_left = 6
    card_style.corner_radius_top_right = 6
    card_style.corner_radius_bottom_left = 6
    card_style.corner_radius_bottom_right = 6
    card_style.content_margin_left = 22
    card_style.content_margin_right = 22
    card_style.content_margin_top = 14
    card_style.content_margin_bottom = 14
    stat_card.add_theme_stylebox_override("panel", card_style)
    stat_card.custom_minimum_size = Vector2(300, 0)
    info_group.add_child(stat_card)

    var stat_rows: = VBoxContainer.new()
    stat_rows.add_theme_constant_override("separation", 10)
    stat_card.add_child(stat_rows)

    stat_rows.add_child(_make_lingwu_stat_row("当前识悟总量", str(int(GameState.lingwu))))

    var divider: = HSeparator.new()
    var div_style: = StyleBoxLine.new()
    div_style.color = Color(accent.r, accent.g, accent.b, 0.16)
    div_style.thickness = 1
    divider.add_theme_stylebox_override("separator", div_style)
    stat_rows.add_child(divider)

    stat_rows.add_child(_make_lingwu_stat_row("治理增益栏位", str(GameState.get_city_boost_slot_count())))

    var spacer_bottom: = Control.new()
    spacer_bottom.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(spacer_bottom)

    var btn_row: = HBoxContainer.new()
    btn_row.add_theme_constant_override("separation", 16)
    btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
    root.add_child(btn_row)

    btn_row.add_child(_make_lingwu_return_button())

    var btn: = _make_shezhi_button("确认解锁", Callable(self, "_confirm_lingwu_city_slot"))
    btn.disabled = int(GameState.lingwu) < GameState.LINGWU_CITY_BOOST_SLOT_COST
    _style_lingwu_confirm_button(btn, btn.disabled)
    btn.custom_minimum_size = Vector2(160, 38)
    btn_row.add_child(btn)

func _make_lingwu_stat_row(label_text: String, value_text: String) -> HBoxContainer:
    var row: = HBoxContainer.new()
    row.add_theme_constant_override("separation", 12)

    var name_lbl: = Label.new()
    name_lbl.text = label_text
    name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    name_lbl.add_theme_font_override("font", FontLoader.body())
    name_lbl.add_theme_font_size_override("font_size", 13)
    name_lbl.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    row.add_child(name_lbl)

    var value_lbl: = Label.new()
    value_lbl.text = value_text
    value_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    value_lbl.add_theme_font_override("font", FontLoader.serif_bold())
    value_lbl.add_theme_font_size_override("font_size", 17)
    value_lbl.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    row.add_child(value_lbl)

    return row

func _confirm_lingwu_city_slot() -> void :
    if GameState.spend_lingwu_for_city_boost_slot():
        var new_count: = GameState.get_city_boost_slot_count()
        _close_lingwu_popup()
        _refresh_panels()
        _transition_toast_controller.show_simple_toast("治理增益栏位已增至 %d 个" % new_count)

var _lingwu_selected_jianwen_id: String = ""
var _lingwu_jianwen_confirm_holder: Control = null
var _lingwu_jianwen_card_entries: Array = []

func _show_lingwu_jianwen_popup() -> void :

    var root: = _make_lingwu_popup("经世方略", 660.0, 900.0)


    var intro: = RichTextLabel.new()
    intro.bbcode_enabled = true
    intro.fit_content = true
    intro.scroll_active = false
    intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    intro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    intro.add_theme_font_override("normal_font", FontLoader.body())
    intro.add_theme_font_size_override("normal_font_size", 14)
    intro.add_theme_color_override("default_color", GameState.get_theme_color("text_desc"))
    intro.text = "[center]以识悟研习方略，择定之策将于近日现于街巷[/center]"
    root.add_child(intro)

    var offers: Array = GameState.JIANWEN_OFFERS
    if offers.is_empty():
        var empty: = Label.new()
        empty.text = "暂无可换取的见闻。"
        empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        empty.size_flags_vertical = Control.SIZE_EXPAND_FILL
        empty.add_theme_font_size_override("font_size", 14)
        empty.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        root.add_child(empty)
        root.add_child(_make_lingwu_return_button())
        return

    _lingwu_selected_jianwen_id = str(offers[0].get("id", ""))
    _lingwu_jianwen_card_entries.clear()

    var hscroll: = ScrollContainer.new()
    hscroll.custom_minimum_size = Vector2(0, 400)
    hscroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hscroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    hscroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

    hscroll.set_meta(NativeMobileFontScalerRef.META_SKIP_MIN_SIZE_SCALE, true)
    ScrollbarThemeRef.apply_to(hscroll)
    var hbar: = hscroll.get_h_scroll_bar()
    if hbar != null:
        hbar.visible = false
        hbar.modulate.a = 0.0
    hscroll.gui_input.connect( func(event: InputEvent): _on_lingwu_jianwen_scroll_input(event, hscroll))
    root.add_child(hscroll)

    var hbox: = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 14)
    hscroll.add_child(hbox)
    for offer in offers:
        hbox.add_child(_make_lingwu_jianwen_selectable_card(offer, hscroll))


    var lingwu_lbl: = Label.new()
    lingwu_lbl.text = "当前识悟：%d" % int(GameState.lingwu)
    lingwu_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    lingwu_lbl.add_theme_font_override("font", FontLoader.serif_bold())
    lingwu_lbl.add_theme_font_size_override("font_size", 15)
    lingwu_lbl.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    root.add_child(lingwu_lbl)


    var bottom_row: = HBoxContainer.new()
    bottom_row.alignment = BoxContainer.ALIGNMENT_CENTER
    bottom_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    bottom_row.add_theme_constant_override("separation", 16)
    root.add_child(bottom_row)

    bottom_row.add_child(_make_lingwu_return_button())

    var confirm_holder: = PanelContainer.new()
    confirm_holder.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    confirm_holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    bottom_row.add_child(confirm_holder)
    _lingwu_jianwen_confirm_holder = confirm_holder

    _refresh_lingwu_jianwen_confirm_button()


func _make_lingwu_jianwen_selectable_card(offer: Dictionary, hscroll: ScrollContainer) -> Button:
    var accent: = GameState.get_theme_color("border_active")
    var offer_id: = str(offer.get("id", ""))
    var purchased: = GameState.is_jianwen_purchased(offer_id)

    var card: = Button.new()
    card.custom_minimum_size = Vector2(172, 380)

    card.set_meta(NativeMobileFontScalerRef.META_SKIP_MIN_SIZE_SCALE, true)
    card.clip_contents = true
    card.focus_mode = Control.FOCUS_NONE
    _apply_lingwu_jianwen_card_selection(card, offer_id == _lingwu_selected_jianwen_id)

    var content: = MarginContainer.new()
    content.set_anchors_preset(Control.PRESET_FULL_RECT)
    content.mouse_filter = Control.MOUSE_FILTER_IGNORE
    for side in ["left", "right", "top", "bottom"]:
        content.add_theme_constant_override("margin_" + side, 16)
    card.add_child(content)
    var rows: = VBoxContainer.new()
    rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
    rows.add_theme_constant_override("separation", 14)
    content.add_child(rows)


    var head: = VBoxContainer.new()
    head.mouse_filter = Control.MOUSE_FILTER_IGNORE
    head.add_theme_constant_override("separation", 6)
    rows.add_child(head)

    var title_text: = str(offer.get("title", ""))
    if purchased:
        title_text += "（已获）"
    var title_lbl: = Label.new()
    title_lbl.text = title_text
    title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    title_lbl.max_lines_visible = 2
    title_lbl.add_theme_font_override("font", FontLoader.title())
    title_lbl.add_theme_font_size_override("font_size", 18)
    title_lbl.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
    title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
    head.add_child(title_lbl)

    var cost_lbl: = Label.new()
    cost_lbl.text = "%d 识悟" % int(offer.get("cost", 0))
    cost_lbl.add_theme_font_override("font", FontLoader.serif_bold())
    cost_lbl.add_theme_font_size_override("font_size", 13)
    cost_lbl.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    cost_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
    head.add_child(cost_lbl)

    var divider: = HSeparator.new()
    var div_style: = StyleBoxLine.new()
    div_style.color = Color(accent.r, accent.g, accent.b, 0.16)
    div_style.thickness = 1
    divider.add_theme_stylebox_override("separator", div_style)
    divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
    rows.add_child(divider)

    var desc: = Label.new()
    desc.text = str(offer.get("desc", ""))
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
    desc.add_theme_font_override("font", FontLoader.body())
    desc.add_theme_font_size_override("font_size", 14)
    desc.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
    rows.add_child(desc)

    _lingwu_jianwen_card_entries.append({"id": offer_id, "card": card})

    card.pressed.connect( func():
        if NativeMobileTouchScrollRef.should_suppress_press(self, "lingwu_jianwen_scroll_suppress_until"):
            return
        _select_lingwu_jianwen(offer)
    )
    card.gui_input.connect( func(event: InputEvent): _on_lingwu_jianwen_scroll_input(event, hscroll))
    return card

func _apply_lingwu_jianwen_card_selection(card: Button, selected: bool) -> void :
    var accent: = GameState.get_theme_color("border_active")
    var card_style: = StyleBoxFlat.new()
    card_style.bg_color = Color(accent.r, accent.g, accent.b, 0.18 if selected else 0.1)
    card_style.border_width_left = 1
    card_style.border_width_top = 1
    card_style.border_width_right = 1
    card_style.border_width_bottom = 1
    card_style.border_color = Color(accent.r, accent.g, accent.b, 0.6 if selected else 0.32)
    card_style.corner_radius_top_left = 8
    card_style.corner_radius_top_right = 8
    card_style.corner_radius_bottom_left = 8
    card_style.corner_radius_bottom_right = 8
    card.add_theme_stylebox_override("normal", card_style)
    card.add_theme_stylebox_override("hover", card_style)
    card.add_theme_stylebox_override("pressed", card_style)
    card.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _select_lingwu_jianwen(offer: Dictionary) -> void :
    _lingwu_selected_jianwen_id = str(offer.get("id", ""))
    for entry in _lingwu_jianwen_card_entries:
        var card = entry.get("card")
        if card is Button and is_instance_valid(card):
            _apply_lingwu_jianwen_card_selection(card, str(entry.get("id", "")) == _lingwu_selected_jianwen_id)
    _refresh_lingwu_jianwen_confirm_button()

func _on_lingwu_jianwen_scroll_input(event: InputEvent, hscroll: ScrollContainer) -> void :
    NativeMobileTouchScrollRef.forward_horizontal_drag_to_scroll(event, hscroll, self, "lingwu_jianwen_scroll_suppress_until")
    if not (event is InputEventMouseButton and event.pressed):
        return
    var direction: = 0
    if event.button_index == MOUSE_BUTTON_WHEEL_UP:
        direction = -1
    elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
        direction = 1
    if direction == 0:
        return
    var bar: = hscroll.get_h_scroll_bar()
    if bar == null:
        return
    var amount: = maxi(int(bar.page * 0.25), 80)
    hscroll.scroll_horizontal = int(clampi(hscroll.scroll_horizontal + direction * amount, 0, int(bar.max_value)))
    hscroll.get_viewport().set_input_as_handled()


func _refresh_lingwu_jianwen_confirm_button() -> void :
    if _lingwu_jianwen_confirm_holder == null or not is_instance_valid(_lingwu_jianwen_confirm_holder):
        return
    for ch in _lingwu_jianwen_confirm_holder.get_children():
        ch.queue_free()
    var offer: = GameState.get_jianwen_offer(_lingwu_selected_jianwen_id)
    var has_sel: = not offer.is_empty()
    var purchased: = has_sel and GameState.is_jianwen_purchased(_lingwu_selected_jianwen_id)
    var cost: = int(offer.get("cost", 0))
    var is_disabled: = ( not has_sel) or purchased or int(GameState.lingwu) < cost
    var label: = "已择定" if purchased else "择定此策"
    var cost_text: = "" if purchased else "减%d识悟" % cost
    var btn: = _make_lingwu_stat_option_button(label, cost_text, is_disabled, Callable(self, "_confirm_lingwu_selected_jianwen"))
    btn.custom_minimum_size = Vector2(300, 38)
    _lingwu_jianwen_confirm_holder.add_child(btn)

    NativeMobileFontScalerRef.apply_to(_lingwu_jianwen_confirm_holder)

func _confirm_lingwu_selected_jianwen() -> void :
    if _lingwu_selected_jianwen_id == "":
        return
    _confirm_lingwu_jianwen(_lingwu_selected_jianwen_id)

func _confirm_lingwu_jianwen(offer_id: String) -> void :
    if GameState.spend_lingwu_for_jianwen(offer_id):
        _close_lingwu_popup()
        _refresh_panels()
        _transition_toast_controller.show_simple_toast("帖子已递出去，近日当有奇人过县")

var _lingwu_preview_holder: Control = null
var _lingwu_confirm_holder: Control = null
var _lingwu_selected_card_id: String = ""
var _lingwu_card_entries: Array = []

func _show_lingwu_governance_card_popup() -> void :
    var root: = _make_lingwu_popup("精研政务", 720.0, 1000.0)


    var candidates: Array = []
    for card in GameData.GOVERNANCE_CARDS:
        if typeof(card) != TYPE_DICTIONARY:
            continue
        if str(card.get("specialType", "")) == "card_upgrade":
            continue
        var card_id: = str(card.get("id", ""))
        if card_id == "":
            continue

        var lines: Array = card.get("lines", [])
        if not lines.is_empty() and not lines.has(GameState.active_line):
            continue
        candidates.append(card)

    if candidates.is_empty():
        var empty: = Label.new()
        empty.text = "暂无可精研的政务卡。"
        empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        empty.size_flags_vertical = Control.SIZE_EXPAND_FILL
        empty.add_theme_font_size_override("font_size", 14)
        empty.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
        root.add_child(empty)
        root.add_child(_make_lingwu_return_button())
        return

    _lingwu_selected_card_id = ""
    _lingwu_card_entries = []



    var vscroll: = ScrollContainer.new()
    vscroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    vscroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    vscroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vscroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    ScrollbarThemeRef.apply_to(vscroll)
    vscroll.gui_input.connect( func(event: InputEvent):
        NativeMobileTouchScrollRef.forward_drag_to_scroll(event, vscroll, self, "lingwu_scroll_suppress_until")
    )
    root.add_child(vscroll)
    var body: = VBoxContainer.new()
    body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 12)
    vscroll.add_child(body)


    var preview_holder: = PanelContainer.new()
    preview_holder.custom_minimum_size = Vector2(0, 330)
    preview_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL

    preview_holder.set_meta(NativeMobileFontScalerRef.META_SKIP_MIN_SIZE_SCALE, true)
    preview_holder.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    body.add_child(preview_holder)
    _lingwu_preview_holder = preview_holder
    _populate_lingwu_preview(preview_holder, {})


    var hscroll: = ScrollContainer.new()
    hscroll.custom_minimum_size = Vector2(0, 210)
    hscroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hscroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    hscroll.set_meta(NativeMobileFontScalerRef.META_SKIP_MIN_SIZE_SCALE, true)
    ScrollbarThemeRef.apply_to(hscroll)

    var hbar: = hscroll.get_h_scroll_bar()
    if hbar != null:
        hbar.visible = false
        hbar.modulate.a = 0.0
    body.add_child(hscroll)
    var hbox: = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 14)
    hscroll.add_child(hbox)
    for card in candidates:
        hbox.add_child(_make_lingwu_selectable_card(card, hscroll))


    var bottom_row: = HBoxContainer.new()
    bottom_row.alignment = BoxContainer.ALIGNMENT_CENTER
    bottom_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    bottom_row.add_theme_constant_override("separation", 16)
    root.add_child(bottom_row)


    bottom_row.add_child(_make_lingwu_return_button())

    var confirm_holder: = PanelContainer.new()
    confirm_holder.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    confirm_holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    bottom_row.add_child(confirm_holder)
    _lingwu_confirm_holder = confirm_holder
    _refresh_lingwu_confirm_button()


func _apply_lingwu_card_visual(host: Control, card: Dictionary) -> void :
    if host is Button:
        host.add_theme_stylebox_override("normal", _make_landscape_card_style(card, false, false))
        host.add_theme_stylebox_override("hover", _make_landscape_card_style(card, false, true))
        host.add_theme_stylebox_override("pressed", _make_landscape_card_style(card, false, true))
        host.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    else:
        host.add_theme_stylebox_override("panel", _make_landscape_card_style(card, false, false))
    _add_landscape_card_gradient_layer(host, card, false, false)
    _add_month_card_illustration(host, card, false, false, host.custom_minimum_size)
    _add_month_card_top_mask(host, card, false)
    var inner_border: = Control.new()
    inner_border.set_anchors_preset(Control.PRESET_FULL_RECT)
    inner_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
    inner_border.draw.connect( func():
        var inset: = 6.0
        var rect: = Rect2(inset, inset, inner_border.size.x - inset * 2.0, inner_border.size.y - inset * 2.0)
        if rect.size.x <= 0.0 or rect.size.y <= 0.0:
            return
        inner_border.draw_rect(rect, Color(0.86, 0.78, 0.55, 0.34), false, 1.0)
    )
    host.add_child(inner_border)


func _make_lingwu_selectable_card(card: Dictionary, hscroll: ScrollContainer) -> Button:
    var btn: = Button.new()
    btn.custom_minimum_size = Vector2(172, 184)

    btn.set_meta(NativeMobileFontScalerRef.META_SKIP_MIN_SIZE_SCALE, true)
    btn.clip_contents = true
    _apply_lingwu_card_visual(btn, card)

    var root: = MarginContainer.new()
    root.set_anchors_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    for side in ["left", "right", "top", "bottom"]:
        root.add_theme_constant_override("margin_" + side, 14)
    var col: = VBoxContainer.new()
    col.mouse_filter = Control.MOUSE_FILTER_IGNORE
    col.add_theme_constant_override("separation", 6)
    root.add_child(col)

    var card_upgraded: = GameState.upgraded_governance_cards.has(str(card.get("id", "")))

    var title: = Label.new()
    title.text = (str(card.get("title", "政务卡")) + "（已精研）") if card_upgraded else str(card.get("title", "政务卡"))
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", 17)
    title.add_theme_color_override("font_color", Color(0.94, 0.88, 0.75))
    title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    title.max_lines_visible = 2
    title.mouse_filter = Control.MOUSE_FILTER_IGNORE
    col.add_child(title)

    var brief: = Label.new()
    brief.text = EventServiceRef._format_effects_list(card)
    brief.add_theme_font_override("font", FontLoader.body())
    brief.add_theme_font_size_override("font_size", 12)
    brief.add_theme_color_override("font_color", Color(0.8, 0.72, 0.6))
    brief.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    brief.max_lines_visible = 4
    brief.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
    brief.mouse_filter = Control.MOUSE_FILTER_IGNORE
    col.add_child(brief)

    btn.add_child(root)


    var sel_border: = Control.new()
    sel_border.set_anchors_preset(Control.PRESET_FULL_RECT)
    sel_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
    sel_border.visible = false
    var accent: = GameState.get_theme_color("border_active")
    sel_border.draw.connect( func():
        var inset: = 2.0
        var rect: = Rect2(inset, inset, sel_border.size.x - inset * 2.0, sel_border.size.y - inset * 2.0)
        if rect.size.x <= 0.0 or rect.size.y <= 0.0:
            return
        sel_border.draw_rect(rect, Color(accent.r, accent.g, accent.b, 0.95), false, 2.5)
    )
    btn.add_child(sel_border)

    var card_id: = str(card.get("id", ""))
    _lingwu_card_entries.append({"id": card_id, "border": sel_border})

    btn.pressed.connect( func():
        if NativeMobileTouchScrollRef.should_suppress_press(self, "lingwu_scroll_suppress_until"):
            return
        _select_lingwu_card(card)
    )
    btn.gui_input.connect( func(event: InputEvent):
        if is_instance_valid(hscroll):
            NativeMobileTouchScrollRef.forward_horizontal_drag_to_scroll(event, hscroll, self, "lingwu_scroll_suppress_until")
    )
    return btn


func _select_lingwu_card(card: Dictionary) -> void :
    _lingwu_selected_card_id = str(card.get("id", ""))
    for entry in _lingwu_card_entries:
        var border = entry.get("border")
        if border != null and is_instance_valid(border):
            border.visible = (str(entry.get("id", "")) == _lingwu_selected_card_id)
    _populate_lingwu_preview(_lingwu_preview_holder, card)
    _refresh_lingwu_confirm_button()


func _refresh_lingwu_confirm_button() -> void :
    if _lingwu_confirm_holder == null or not is_instance_valid(_lingwu_confirm_holder):
        return
    for ch in _lingwu_confirm_holder.get_children():
        ch.queue_free()
    var has_sel: = _lingwu_selected_card_id != ""
    var already_upgraded: = has_sel and GameState.upgraded_governance_cards.has(_lingwu_selected_card_id)
    var is_disabled: = ( not has_sel) or already_upgraded or int(GameState.lingwu) < GameState.LINGWU_CARD_UPGRADE_COST
    var btn: = _make_lingwu_stat_option_button("确认精研", "减15识悟", is_disabled, Callable(self, "_confirm_lingwu_selected"))
    btn.custom_minimum_size = Vector2(300, 38)
    _lingwu_confirm_holder.add_child(btn)

    NativeMobileFontScalerRef.apply_to(_lingwu_confirm_holder)

func _confirm_lingwu_selected() -> void :
    if _lingwu_selected_card_id == "":
        return
    _confirm_lingwu_governance_card(_lingwu_selected_card_id)


func _populate_lingwu_preview(holder: Control, card: Dictionary) -> void :
    if holder == null or not is_instance_valid(holder):
        return
    for ch in holder.get_children():
        ch.queue_free()

    if card.is_empty():
        var hint: = Label.new()
        hint.text = "请从下方选择一张政务卡，查看精研前后的效果对比。"
        hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        hint.size_flags_vertical = Control.SIZE_EXPAND_FILL
        hint.add_theme_font_override("font", FontLoader.body())
        hint.add_theme_font_size_override("font_size", 14)
        hint.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        holder.add_child(hint)
        return

    var col: = VBoxContainer.new()
    col.alignment = BoxContainer.ALIGNMENT_CENTER
    col.add_theme_constant_override("separation", 16)
    holder.add_child(col)

    var row: = HBoxContainer.new()
    row.alignment = BoxContainer.ALIGNMENT_CENTER
    row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    row.add_theme_constant_override("separation", 18)
    col.add_child(row)

    row.add_child(_make_lingwu_preview_card(card, false, "精研前"))

    var arrow_col: = VBoxContainer.new()
    arrow_col.alignment = BoxContainer.ALIGNMENT_CENTER
    arrow_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    arrow_col.add_theme_constant_override("separation", 4)
    row.add_child(arrow_col)
    var arrow: = Label.new()
    arrow.text = "→"
    arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    arrow.add_theme_font_override("font", FontLoader.serif_bold())
    arrow.add_theme_font_size_override("font_size", 36)
    arrow.add_theme_color_override("font_color", GameState.get_theme_color("border_active"))
    arrow_col.add_child(arrow)
    var arrow_hint: = Label.new()
    arrow_hint.text = "升级预览"
    arrow_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    arrow_hint.add_theme_font_override("font", FontLoader.body())
    arrow_hint.add_theme_font_size_override("font_size", 12)
    arrow_hint.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    arrow_col.add_child(arrow_hint)

    row.add_child(_make_lingwu_preview_card(card, true, "精研后"))

    NativeMobileFontScalerRef.apply_to(holder)


func _make_lingwu_preview_card(card: Dictionary, doubled: bool, badge_text: String) -> Control:

    var wrap: = VBoxContainer.new()
    wrap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    wrap.add_theme_constant_override("separation", 8)

    var panel: = PanelContainer.new()
    panel.custom_minimum_size = Vector2(228, 224)
    panel.clip_contents = true
    _apply_lingwu_card_visual(panel, card)

    var root: = MarginContainer.new()
    root.set_anchors_preset(Control.PRESET_FULL_RECT)
    for side in ["left", "right", "top", "bottom"]:
        root.add_theme_constant_override("margin_" + side, 16)
    var col: = VBoxContainer.new()
    col.add_theme_constant_override("separation", 7)
    root.add_child(col)


    var base_title: = str(card.get("title", "政务卡"))
    var title: = Label.new()
    title.text = (base_title + "·二级") if doubled else base_title
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", 18)
    title.add_theme_color_override("font_color", Color(0.94, 0.88, 0.75))
    title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    title.max_lines_visible = 2
    col.add_child(title)

    var eff: = Label.new()
    eff.text = EventServiceRef._format_effects_list_doubled(card) if doubled else EventServiceRef._format_effects_list(card)
    eff.add_theme_font_override("font", FontLoader.body())
    eff.add_theme_font_size_override("font_size", 13)
    var eff_col: = Color(0.92, 0.84, 0.66) if doubled else Color(0.82, 0.74, 0.62)
    eff.add_theme_color_override("font_color", eff_col)
    eff.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    col.add_child(eff)

    panel.add_child(root)
    wrap.add_child(panel)

    var badge: = Label.new()
    badge.text = badge_text
    badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    badge.add_theme_font_override("font", FontLoader.body())
    badge.add_theme_font_size_override("font_size", 13)
    var badge_col: = GameState.get_theme_color("border_active") if doubled else Color(0.8, 0.72, 0.6)
    badge.add_theme_color_override("font_color", badge_col)
    wrap.add_child(badge)

    return wrap

func _confirm_lingwu_governance_card(card_id: String) -> void :
    if GameState.spend_lingwu_for_governance_card(card_id):
        _close_lingwu_popup()
        _refresh_panels()

func _make_zhisu_pill_button_style(hovered: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    var accent: = GameState.get_theme_color("border_active")
    style.bg_color = Color(accent.r, accent.g, accent.b, 0.12 if hovered else 0.05)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = Color(accent.r, accent.g, accent.b, 0.55 if hovered else 0.35)
    style.corner_radius_top_left = 12
    style.corner_radius_top_right = 12
    style.corner_radius_bottom_left = 12
    style.corner_radius_bottom_right = 12
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 2
    style.content_margin_bottom = 2
    return style

func _make_zengyi_expand_button_style(hovered: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    var accent: = GameState.get_theme_color("border_active")
    style.bg_color = Color(0, 0, 0, 0)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = Color(accent.r, accent.g, accent.b, 0.68 if hovered else 0.42)
    style.corner_radius_top_left = 9
    style.corner_radius_top_right = 9
    style.corner_radius_bottom_left = 9
    style.corner_radius_bottom_right = 9
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 0
    style.content_margin_bottom = 0
    return style

func _should_show_top_resources() -> bool:


    if _is_dianshi_memory_event_context() or _showing_dianshi_memory_result:
        return false
    if _should_show_top_attitudes():
        return true
    if GameState.is_governance_mode() and not GameState.transitioning_to_governance:
        return true
    return GameState.has_method("is_after_sun_chuanting_branch_split") and GameState.is_after_sun_chuanting_branch_split() and not GameState.city.is_empty()



func _is_local_route() -> bool:
    return GameData.active_line == "" or GameData.active_line == "hanmen"

func _should_show_top_attitudes() -> bool:
    if _is_local_route() or GameData.active_line == "bianwu":
        return false
    return GameState.is_governance_mode() and not GameState.transitioning_to_governance


func _top_attitude_keys() -> Array:
    if GameData.ATT_KEYS != null and not GameData.ATT_KEYS.is_empty():
        return GameData.ATT_KEYS
    return LOCAL_TOP_ATTITUDE_KEYS

func _configure_top_status_bar_content() -> void :
    if silver_label == null:
        return
    if _should_show_top_attitudes():
        _configure_top_attitude_status_bar_content()
        return
    _clear_top_attitude_status_groups()
    _set_top_resource_groups_visible(true)
    var mobile_portrait: = _is_mobile_portrait()
    var is_bianwu: = GameData.active_line == "bianwu"
    var locked_resources: = GameState.has_method("is_after_sun_chuanting_branch_split") and GameState.is_after_sun_chuanting_branch_split()
    var resource_keys: = ["liangcao", "xiangyin", "mapi", "huoqi", "zhanyi"] if is_bianwu else (["yinliang", "liangshi", "bingyong"] if locked_resources else ["yinliang", "liangshi", "bingyong", "renkou_val", "liumin"])
    var display_resource_keys: = resource_keys
    if mobile_portrait and not locked_resources and not is_bianwu:
        display_resource_keys = MOBILE_CITY_RESOURCE_KEYS
    var resource_labels: = {
        "yinliang": silver_label, 
        "liangshi": grain_label, 
        "bingyong": bingyong_label, 
        "renkou_val": pop_label, 
        "liumin": refugee_label, 
        "liangcao": silver_label, 
        "xiangyin": grain_label, 
        "mapi": bingyong_label, 
        "huoqi": pop_label, 
        "zhanyi": refugee_label
    }
    var resource_name_labels: = {
        "yinliang": MOBILE_CITY_RESOURCE_LABELS.get("yinliang", "库银"), 
        "liangshi": MOBILE_CITY_RESOURCE_LABELS.get("liangshi", "官粮"), 
        "bingyong": MOBILE_CITY_RESOURCE_LABELS.get("bingyong", "兵勇"), 
        "renkou_val": MOBILE_CITY_RESOURCE_LABELS.get("renkou_val", "人口"), 
        "liumin": MOBILE_CITY_RESOURCE_LABELS.get("liumin", "流民"), 
        "liangcao": "粮草", 
        "xiangyin": "饷银", 
        "mapi": "马匹", 
        "huoqi": "火器", 
        "zhanyi": "战意"
    }
    for label in _get_top_resource_labels():
        if label == null:
            continue
        label.visible = false
        if label.get_parent() is Control:
            label.get_parent().visible = false

    if mobile_portrait:
        for key in display_resource_keys:
            var label: Label = resource_labels.get(key)
            if label == null:
                continue
            var val: = int(GameState.city.get(key, 0))
            if key != "yinliang" and key != "xiangyin":
                val = maxi(0, val)
            label.text = "%s  %s" % [resource_name_labels.get(key, key), _format_large_number(val)]
            label.visible = true
            _set_resource_group_stat_key(label, key)
    else:
        for key in resource_keys:
            var label: Label = resource_labels.get(key)
            if label == null:
                continue
            var val: = int(GameState.city.get(key, 0))
            if key != "yinliang" and key != "xiangyin":
                val = maxi(0, val)
            label.text = "%s %s" % [resource_name_labels.get(key, key), _format_large_number(val)]
            label.visible = true
            _set_resource_group_stat_key(label, key)
    _refresh_resource_icon_style()
    _update_bw_merit_status_group(is_bianwu)


    for key in resource_keys:
        var current_val: int = int(GameState.city.get(key, 0))
        var label: Label = resource_labels.get(key)
        if label != null:
            if _prev_resources_cache.has(key):
                var prev_val: int = _prev_resources_cache[key]
                if current_val != prev_val:
                    var diff = current_val - prev_val
                    _animate_control_value_change(label, diff, current_val)
            _prev_resources_cache[key] = current_val

    _normalize_top_resource_label_style()

    _update_resource_bar_separators()

func _configure_top_attitude_status_bar_content() -> void :
    if resource_bar == null:
        return
    _clear_top_attitude_status_groups()
    _set_top_resource_groups_visible(false)
    for key in _top_attitude_keys():
        if not GameState.attitudes.has(key):
            continue
        var group: = HBoxContainer.new()
        group.name = "TopAttitudeGroup_" + key
        group.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        group.add_theme_constant_override("separation", 4)
        group.mouse_filter = Control.MOUSE_FILTER_STOP
        group.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

        var help_title: = "诸 方 态 度"
        var help_text: = "边关如弈，五方皆不可失。圣眷、朝堂、监军、军心、士民——你无法让所有人满意，但务必守住每一方的底线。任意一方态度归零，便是你在这盘棋局中出局之时。" if GameData.active_line == "bianwu" else "官场如棋，五方皆不可失。圣眷、中官、清议、士绅、民望——你无法让所有人满意，但务必守住每一方的底线。任意一方态度归零，便是你在这盘棋局中出局之时。"

        group.gui_input.connect( func(event: InputEvent) -> void :
            if event is InputEventMouseButton:
                if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
                    _show_help_overlay(group, help_title, help_text)
            elif event is InputEventScreenTouch and event.pressed:
                _show_help_overlay(group, help_title, help_text)
        )
        _connect_help_btn_hover(group, help_title, func(): return help_text)

        var icon: = StatusIconUtil.make_texture(key, 34.0 if _is_mobile_portrait() else 18.0)
        if icon != null:
            icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
            icon.modulate = Color(1.0, 0.92, 0.74, 0.94)
            group.add_child(icon)

        var name_label: = Label.new()
        var value: = int(GameState.attitudes.get(key, 0))
        var label_text: = str(GameData.ATT_LABELS.get(key, key))
        name_label.text = label_text
        name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        name_label.add_theme_font_size_override("font_size", 30 if _is_mobile_portrait() else 14)
        name_label.add_theme_color_override("font_color", Color(0.88, 0.83, 0.73, 0.95) if GameState.theme == "light" else _chrome_color("text_sub"))
        group.add_child(name_label)

        var val_label: = Label.new()
        var tier_text: = GameState.get_attitude_tier(key)
        val_label.text = "%s %s" % [_format_large_number(value), tier_text]
        val_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        val_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        val_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        val_label.add_theme_font_size_override("font_size", 30 if _is_mobile_portrait() else 14)
        val_label.add_theme_color_override("font_color", _get_tier_color(value))
        group.add_child(val_label)

        resource_bar.add_child(group)
    _update_resource_bar_separators()

func _clear_top_attitude_status_groups() -> void :
    if resource_bar == null:
        return
    for child in resource_bar.get_children():
        if str(child.name).begins_with("TopAttitudeGroup_"):
            resource_bar.remove_child(child)
            child.queue_free()

func _set_top_resource_groups_visible(visible: bool) -> void :
    for label in _get_top_resource_labels():
        if label == null:
            continue
        if label.get_parent() is Control:
            label.get_parent().visible = visible
        else:
            label.visible = visible
    if not visible and _bw_merit_group != null and is_instance_valid(_bw_merit_group):
        _bw_merit_group.visible = false


func _update_bw_merit_status_group(is_bianwu: bool) -> void :
    if not is_bianwu:
        if _bw_merit_group != null and is_instance_valid(_bw_merit_group):
            _bw_merit_group.visible = false
        return
    if resource_bar == null or refugee_label == null:
        return
    if _bw_merit_group == null or not is_instance_valid(_bw_merit_group):
        var group: = HBoxContainer.new()
        group.name = "zhangong_resource_group"
        group.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        group.add_theme_constant_override("separation", 4)
        group.mouse_filter = Control.MOUSE_FILTER_PASS
        var icon: = StatusIconUtil.make_texture("wulue", 34.0 if _is_mobile_portrait() else 18.0)
        if icon != null:
            icon.name = "zhangong_icon"
            icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
            group.add_child(icon)
        var lbl: = Label.new()
        lbl.name = "ZhangongLabel"
        lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
        lbl.add_theme_font_override("font", refugee_label.get_theme_font("font"))
        lbl.add_theme_font_size_override("font_size", refugee_label.get_theme_font_size("font_size"))
        group.add_child(lbl)
        resource_bar.add_child(group)
        _bw_merit_group = group
        _bw_merit_label = lbl

    var zhanyi_group: = refugee_label.get_parent()
    if zhanyi_group != null and zhanyi_group.get_parent() == resource_bar:
        resource_bar.move_child(_bw_merit_group, zhanyi_group.get_index() + 1)
    var merit: = GameState.get_governance_merit()
    var merit_target: = GameState.get_governance_merit_target()
    _bw_merit_label.text = "战功 %d/%d" % [merit, merit_target] if merit_target > 0 else "战功 %d" % merit
    var col: = _chrome_color("text_sub")
    if GameState.theme == "light":
        col = Color(0.88, 0.83, 0.73, 0.95)
    _bw_merit_label.add_theme_color_override("font_color", col)
    for child in _bw_merit_group.get_children():
        if child is TextureRect:
            child.custom_minimum_size = Vector2(34.0 if _is_mobile_portrait() else 18.0, 34.0 if _is_mobile_portrait() else 18.0)
            child.modulate = Color(1.0, 0.92, 0.74, 0.94)
    _bw_merit_group.visible = true

func _get_top_resource_labels() -> Array[Label]:
    return [silver_label, grain_label, bingyong_label, pop_label, refugee_label]

func _is_top_resource_label(control: Control) -> bool:
    return control is Label and _get_top_resource_labels().has(control)

func _normalize_top_resource_label_style() -> void :
    for lbl in _get_top_resource_labels():
        if lbl:
            var col: = _chrome_color("text_sub")
            if GameState.theme == "light":

                col = Color(0.88, 0.83, 0.73, 0.95)
            lbl.add_theme_color_override("font_color", col)
            lbl.modulate = Color.WHITE

func _update_resource_bar_separators() -> void :
    if not resource_bar:
        return
    for child in resource_bar.get_children():
        if child is VSeparator:
            resource_bar.remove_child(child)
            child.queue_free()

    if not _is_mobile_portrait():
        return

    var visible_groups: = []
    for child in resource_bar.get_children():
        if child is HBoxContainer and child.visible:
            visible_groups.append(child)

    for i in range(1, visible_groups.size()):
        var sep = VSeparator.new()

        sep.size_flags_vertical = Control.SIZE_FILL
        sep.custom_minimum_size = Vector2(2, 0)
        var sep_style = StyleBoxLine.new()
        sep_style.vertical = true
        sep_style.color = Color(0.72, 0.6, 0.36, 0.5)
        sep_style.thickness = 2
        sep_style.grow_begin = -4
        sep_style.grow_end = -4
        sep.add_theme_stylebox_override("separator", sep_style)
        resource_bar.add_child(sep)
        resource_bar.move_child(sep, visible_groups[i].get_index())

func _set_resource_group_stat_key(label: Label, stat_key: String) -> void :
    if label == null or label.get_parent() == null:
        return
    var group: = label.get_parent()
    if group is Control:
        group.visible = label.visible
        group.name = "%s_resource_group" % stat_key
    for child in group.get_children():
        if child is TextureRect:
            var icon: = child as TextureRect
            var tex: = load(StatusIconUtil.STATUS_ICON_PATHS.get(stat_key, "")) as Texture2D
            if tex:
                icon.texture = tex
            break

func _insert_resource_icon_before_label(label: Label, stat_key: String) -> void :
    if label == null or label.get_parent() == null:
        return
    var icon: = StatusIconUtil.make_texture(stat_key, 34.0 if _is_mobile_portrait() else 18.0)
    if icon == null:
        return
    icon.name = "%s_icon" % stat_key
    icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var parent: = label.get_parent()
    var label_index: = label.get_index()
    var group: = HBoxContainer.new()
    group.name = "%s_resource_group" % stat_key
    group.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    group.add_theme_constant_override("separation", 4)
    group.mouse_filter = Control.MOUSE_FILTER_PASS
    parent.add_child(group)
    parent.move_child(group, label_index)
    parent.remove_child(label)
    group.add_child(icon)
    group.add_child(label)

    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    for conn in label.gui_input.get_connections():
        group.gui_input.connect(conn.callable)
        label.gui_input.disconnect(conn.callable)

func _refresh_resource_icon_style() -> void :
    if resource_bar == null:
        return
    var icon_size: = 34.0 if _is_mobile_portrait() else 18.0
    for group in resource_bar.get_children():
        if group is HBoxContainer:
            for child in group.get_children():
                if child is TextureRect:
                    child.custom_minimum_size = Vector2(icon_size, icon_size)
                    child.modulate = Color(1.0, 0.92, 0.74, 0.94)

func _style_ming_map_overlay() -> void :
    _ming_map_controller.style_ming_map_overlay()

func _on_locate_city_pressed() -> void :
    _ming_map_controller.on_locate_city_pressed()

func _on_ming_map_mode_pressed(mode: String) -> void :
    _ming_map_controller.on_ming_map_mode_pressed(mode)

func _map_button_style(hovered: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0.7, 0.58, 0.34, 0.15 if hovered else 0.06)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.border_color = Color(0.72, 0.6, 0.36, 0.58 if hovered else 0.32)
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    style.content_margin_left = 8
    style.content_margin_right = 8
    style.content_margin_top = 2
    style.content_margin_bottom = 2
    return style

func _close_ming_map_overlay() -> void :
    _ming_map_controller.close_ming_map_overlay()

func _on_ming_map_dimmer_gui_input(event: InputEvent) -> void :
    _ming_map_controller.on_ming_map_dimmer_gui_input(event)

func _on_ming_map_viewport_gui_input(event: InputEvent) -> void :
    _ming_map_controller.on_ming_map_viewport_gui_input(event)

func _on_ming_map_province_layer_gui_input(event: InputEvent) -> void :
    _ming_map_controller.on_ming_map_province_layer_gui_input(event)

func _on_ming_map_province_layer_mouse_exited() -> void :
    _ming_map_controller.on_ming_map_province_layer_mouse_exited()

func _on_ming_map_viewport_resized() -> void :
    _ming_map_controller.on_ming_map_viewport_resized()

func _set_ming_map_zoom(target_zoom: float, pivot: Vector2) -> void :
    _ming_map_controller.set_ming_map_zoom(target_zoom, pivot)

func _reset_ming_map_zoom() -> void :
    _ming_map_controller.reset_ming_map_zoom()

func _clamp_ming_map_pan() -> void :
    _ming_map_controller.clamp_ming_map_pan()

func _apply_ming_map_crisp_text() -> void :
    _ming_map_controller.apply_ming_map_crisp_text()

func _collect_ming_map_labels(node: Node) -> Array[Label]:
    return _ming_map_controller.collect_ming_map_labels(node)

func _remember_ming_map_label_metrics(label: Label) -> void :
    _ming_map_controller.remember_ming_map_label_metrics(label)

func _set_ming_map_label_metrics(label: Label, base_font_size: int, base_size: Vector2) -> void :
    _ming_map_controller.set_ming_map_label_metrics(label, base_font_size, base_size)

func _apply_ming_map_crisp_label(label: Label) -> void :
    _ming_map_controller.apply_ming_map_crisp_label(label)

func _current_map_act_key() -> String:
    return _ming_map_controller.current_map_act_key()

func _current_map_label() -> String:
    return _ming_map_controller.current_map_label()

func _refresh_ming_map_overlay() -> void :
    _ming_map_controller.refresh_ming_map_overlay()

func _align_current_map_dot(current_dot: TextureRect, dot: Control) -> void :
    _ming_map_controller.align_current_map_dot(current_dot, dot)

func _show_current_event() -> void :
    _choice_in_progress = false
    pending_result_progress_committed = false
    if GameState.is_governance_mode() and governance_active_card_index < 0:
        _show_governance_overview()
        return
    var bad_ending = EndingServiceRef.get_bad_ending_payload(GameState)
    if not bad_ending.is_empty():
        game_ended.emit(bad_ending)
        return

    var governance_card_active: = GameState.is_governance_mode() and governance_active_card_index >= 0
    if not governance_card_active and GameState.is_game_over():
        var ending = GameState.determine_ending()
        if ending.is_empty():
            return
        game_ended.emit(ending)
        return

    _autosave_current_safe_state()

    var evt = GameState.get_current_event()
    if GameState.is_governance_mode():
        evt = GameState.get_month_card_event(governance_active_card_index)
    if evt.is_empty():
        return



    if GameState.in_prison and GameState.prison_index == 0 and not GameState.get_meta("prison_transition_shown", false):
        GameState.set_meta("prison_transition_shown", true)
        _show_stage_transition("一朝入诏狱", "身陷囹圄，生死未卜", Callable(self, "_render_event_inner"))
        return
    elif GameState.branch == "" and GameState.is_governance_mode() and str(evt.get("id", "")) == "e5_5" and not GameState.get_meta("terminal_volume_transition_shown", false):
        GameState.set_meta("terminal_volume_transition_shown", true)
        _show_stage_transition("终卷 · 尘埃渐落", "大厦将倾，尘埃渐落", Callable(self, "_render_event_inner"))
        return
    elif GameState.play_mode != "free" and GameState.branch != "" and GameState.branch not in ["origin", "origin_fail", "origin_detour", "keju", "keju_continue"] and GameState.branch_index == 0 and not GameState.get_meta("branch_transition_shown", false):
        GameState.set_meta("branch_transition_shown", true)
        if not GameState.get_meta("terminal_volume_transition_shown", false):
            _show_stage_transition("终卷 · 尘埃渐落", "大厦将倾，尘埃渐落", Callable(self, "_render_event_inner"))
            return


    _render_event_inner()

func _autosave_current_safe_state() -> void :
    SaveManager.save_autosave()

func _render_event_inner() -> void :
    _choice_in_progress = false

    _choice_input_lock_until_ms = Time.get_ticks_msec() + CHOICE_INPUT_LOCK_MS
    _clear_dynamic_chosen_choice()
    mobile_event_phase = "reading"
    var evt_raw = GameState.get_current_event()
    if GameState.is_governance_mode():
        evt_raw = GameState.get_month_card_event(governance_active_card_index)

    var evt = evt_raw.duplicate(true)
    if evt.has("alt_narratives"):
        for alt in evt["alt_narratives"]:
            var matched = false
            if alt.has("requireChain"):


                var rc: Dictionary = alt["requireChain"]
                var rc_id = str(rc.get("id", ""))
                var rc_state: Dictionary = GameState.historical_chains.get(rc_id, {})
                if not rc_state.is_empty():
                    var rc_outcome = str(rc_state.get("outcome", ""))
                    var rc_req: Array = rc.get("outcomes", [])
                    var rc_not: Array = rc.get("notOutcomes", [])
                    var rc_ok = true
                    if rc_req.size() > 0 and not rc_req.has(rc_outcome): rc_ok = false
                    if rc_not.size() > 0 and rc_not.has(rc_outcome): rc_ok = false
                    if rc_ok: matched = true
            elif alt.has("requireFn"):
                var req_fn = str(alt["requireFn"]).strip_edges()
                var cal_year = 1602 + GameState.age
                if "year==" in req_fn:
                    if cal_year == int(req_fn.split("==")[1]): matched = true
                elif "year>=" in req_fn:
                    if cal_year >= int(req_fn.split(">=")[1]): matched = true
                elif "year<" in req_fn:
                    if cal_year < int(req_fn.split("<")[1]): matched = true
            else:
                var req_keju = alt.get("requireKeju", [])
                var req_char = alt.get("requireChar", [])
                var keju_ok = req_keju.size() == 0 or req_keju.has(GameState.keju_status)
                var char_ok = req_char.size() == 0 or req_char.has(GameState.char_id)

                var fail_ok = true
                if alt.has("requireFailKey") and alt.has("requireFailCount"):
                    var f_key = str(alt["requireFailKey"])
                    var f_count = int(alt["requireFailCount"])
                    var current_fail = int(GameState.keju_fail_counts.get(f_key, 0))
                    if current_fail != f_count:
                        fail_ok = false

                if keju_ok and char_ok and fail_ok and (req_keju.size() > 0 or req_char.size() > 0 or alt.has("requireFailKey")): matched = true

            if matched:
                if alt.has("narrative"): evt["narrative"] = alt["narrative"]
                if alt.has("speakerLine"): evt["speakerLine"] = alt["speakerLine"]
                if alt.has("speaker"): evt["speaker"] = alt["speaker"]
                if alt.has("stageOverride"): evt["stageOverride"] = alt["stageOverride"]
                break
    _apply_current_city_placeholders(evt)
    _apply_court_session_player_speaker(evt)


    var is_riot_or_mutiny: = false
    var stage_str = str(evt.get("stage", "")).strip_edges()
    var stage_override = str(evt.get("stageOverride", "")).strip_edges()
    var check_evt_id = str(evt.get("id", "")).strip_edges()
    var check_evt_title = str(evt.get("title", "")).strip_edges()

    if "哗变" in stage_str or "暴动" in stage_str or "哗变" in stage_override or "暴动" in stage_override or "mutiny" in check_evt_id or "riot" in check_evt_id or "哗变" in check_evt_title or "暴动" in check_evt_title:
        is_riot_or_mutiny = true

    if is_riot_or_mutiny:
        if is_instance_valid(GameState):
            GameState.play_riot_interrupt_bgm(1.0)
    else:


        if is_instance_valid(GameState):
            var _cur_bgm: = GameState.current_bgm_path
            if _cur_bgm == "res://assets/" + "riot_bgm.mp3" and GameState.riot_interrupt_active:
                GameState.resume_riot_interrupted_bgm(1.5)
            elif GameState.is_title_playlist_path(_cur_bgm) or _cur_bgm == "res://assets/" + "riot_bgm.mp3" or _cur_bgm == "res://assets/" + "终局回响.mp3" or _cur_bgm == "":
                GameState.play_default_bgm(2.0)

    governance_scroll.visible = false

    _set_bianwu_ap_floating(false)

    if _bw_sidebar_btn_overlay != null and is_instance_valid(_bw_sidebar_btn_overlay):
        _bw_sidebar_btn_overlay.visible = false

    _reassert_bw_sidebar_collapsed_width()

    if action_points_portrait_frame != null and is_instance_valid(action_points_portrait_frame):
        action_points_portrait_frame.visible = false
    _apply_game_background_mask()
    var tween = create_tween()
    tween.tween_property(game_overlay, "modulate:a", _event_overlay_alpha(), 0.4)
    $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter.visible = true
    $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter.set_deferred("scroll_vertical", 0)
    if _is_mobile_portrait():
        _apply_mobile_jushi_stats_layout()

    if evt.has("stageOverride") and str(evt["stageOverride"]) != "":
        stage_label.text = str(evt["stageOverride"])
        stage_label.show()
    else:
        stage_label.hide()

    Presenter.render_event(evt, event_date_label, event_title_label, speaker_avatar, speaker_name, speaker_role, speaker_faction, speaker_line, narrative_label, flavor_label, focus_label)
    _sync_topbar_turn_label()
    _sync_event_date_label_visibility()
    flavor_panel.visible = false
    focus_panel.visible = false
    _apply_focus_panel_style()

    current_bio_text = evt.get("bio", "")

    if evt.get("speaker", {}).get("role", "") == "街谈奇遇":
        var s_name = evt.get("title", "")
        speaker_name.text = s_name
        speaker_avatar.text = s_name.substr(0, 1) if s_name != "" else "人"
        if evt.get("is_historical", false):
            event_title_label.text = evt.get("title", "")


    visitor_bio_btn.visible = current_bio_text != ""

    speaker_bubble.visible = speaker_line.text.length() > 0


    var speaker_obj = evt.get("speaker", {})
    var speaker_name_for_portrait: = ""
    if speaker_obj is Dictionary:


        var portrait_key: = str(speaker_obj.get("portrait", "")).strip_edges()
        if portrait_key != "":
            speaker_name_for_portrait = portrait_key
        elif speaker_obj.get("role", "") == "街谈奇遇":
            speaker_name_for_portrait = str(evt.get("title", ""))
        else:
            speaker_name_for_portrait = str(speaker_obj.get("name", ""))
    elif speaker_obj is String:
        speaker_name_for_portrait = speaker_obj

    var portrait_path: = "res://assets/portraits/portrait_default.webp"



    var matched_real_portrait: = false
    var player_rank_portrait: = _get_player_rank_portrait_path() if _current_event_uses_player_rank_portrait(evt) else ""
    var evt_id: = str(evt.get("id", ""))
    if player_rank_portrait != "":
        portrait_path = player_rank_portrait
        matched_real_portrait = true
    elif evt_id == "v_nvxia":
        portrait_path = "res://assets/portraits/nvbiaoshi.webp"
        matched_real_portrait = true
    elif speaker_name_for_portrait == "高万利" or evt_id.begins_with("v_c_gaowanli_"):
        matched_real_portrait = true
        if evt_id.begins_with("v_c_gaowanli_ch3") or evt_id.begins_with("v_c_gaowanli_ch4"):
            portrait_path = "res://assets/portraits/gaowanli_middle.webp"
        elif evt_id.begins_with("v_c_gaowanli_ch5") or evt_id.begins_with("v_c_gaowanli_ch6"):
            portrait_path = "res://assets/portraits/gaowanli_late.webp"
        else:
            portrait_path = "res://assets/portraits/gaowanli_early.webp"
    elif speaker_name_for_portrait.begins_with("许衡圃"):
        portrait_path = "res://assets/portraits/xuhengpu.webp"
        matched_real_portrait = true
    elif speaker_name_for_portrait != "" and PORTRAIT_MAP.has(speaker_name_for_portrait):
        portrait_path = PORTRAIT_MAP[speaker_name_for_portrait]
        matched_real_portrait = true

    if not matched_real_portrait and (str(evt.get("type", "")) == "rumor" or evt_id.begins_with("rumor_") or (evt.has("speaker") and evt["speaker"] is Dictionary and evt["speaker"].get("name", "") == "坊间传闻")):
        portrait_path = "res://assets/portraits/shiye.webp"
        matched_real_portrait = true

    event_portrait_court_mode = player_rank_portrait != ""


    event_portrait_hide_backdrop = not _is_court_session_event(evt)



    var is_placeholder_portrait: = not matched_real_portrait
    if is_instance_valid(event_portrait_rect):
        if OS.has_feature("web"):
            event_portrait_rect.texture = null
        else:
            _set_event_portrait_async(portrait_path, is_placeholder_portrait)


    if is_instance_valid(event_portrait_office_bg):
        event_portrait_office_bg.visible = event_portrait_court_mode and not event_portrait_hide_backdrop
    if is_instance_valid(event_portrait_right_backing):
        event_portrait_right_backing.visible = false
    _apply_game_background_mask()



    if is_instance_valid(event_portrait_rect) and event_portrait_rect.texture != null:
        _request_event_portrait_loading_animation()
    _update_event_portrait_layout()
    _build_choices(evt.get("choices", []))
    _update_choice_top_spacer()
    _update_dialogue_narrative_spacing()
    result_panel.visible = false
    _apply_mobile_event_phase_visibility()
    _apply_native_mobile_font_scale()
    _play_event_content_enter_animation()
    if is_instance_valid(mobile_choice_narrative_label):
        mobile_choice_narrative_label.text = narrative_label.text

    if _is_mobile_portrait():
        _apply_mobile_dialogue_narrative_spacing(true)
        _apply_mobile_focus_outer_spacing(true)
        _apply_mobile_event_width_constraints()
        _schedule_mobile_reading_layout_sync()

func _apply_current_city_placeholders(event_data: Dictionary) -> void :
    var replacements: = {}
    var current_city: String = GameState.get_current_city_name()
    if current_city != "":
        replacements["{current_city}"] = current_city
        var city_under: = "辖下各乡"
        if current_city.ends_with("府"):
            city_under = "辖下十余县"
        elif current_city.ends_with("州"):
            city_under = "下辖各县"
        replacements["{city_under}"] = city_under
    if GameState.has_method("resolve_honorary_title_for_rank"):
        replacements["{new_honorary_title}"] = GameState.resolve_honorary_title_for_rank()
    var office_title: = GameState.get_office_title() if GameState.has_method("get_office_title") else GameState.get_rank_title()
    var office_juris: = GameState.get_office_juris_from_rank_title() if GameState.has_method("get_office_juris_from_rank_title") else ""
    if office_title != "":
        replacements["{official_title}"] = office_title
        replacements["{office_title}"] = office_title
        replacements["{office_short}"] = office_title
    if office_juris != "":
        replacements["{office_juris}"] = office_juris
        replacements["{office_scope}"] = office_juris
    for act_idx in range(1, 7):
        var act_key: = str(act_idx)
        var city_cfg: Dictionary = GameState.resolve_transfer_city_for_act(act_key, GameState.get_rank_title())
        var city_name: = str(city_cfg.get("name", ""))
        if city_name != "":
            replacements["{city_%s}" % act_key] = city_name
    if replacements.is_empty():
        return
    Presenter.apply_placeholders_with(event_data, replacements)

func _ensure_mobile_continue_button() -> void :
    if not is_instance_valid(mobile_reading_card):
        mobile_reading_card = PanelContainer.new()
        mobile_reading_card.name = "MobileReadingCard"
        mobile_reading_card.mouse_filter = Control.MOUSE_FILTER_PASS
        mobile_reading_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        mobile_reading_card.gui_input.connect(_on_mobile_reading_card_gui_input)
        mobile_reading_card.draw.connect(_draw_mobile_reading_card_border)
        mobile_reading_card_vbox = VBoxContainer.new()
        mobile_reading_card_vbox.name = "MobileReadingCardVBox"
        mobile_reading_card_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        mobile_reading_card_vbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
        mobile_reading_card_vbox.add_theme_constant_override("separation", int(MOBILE_EVENT_CONTINUE_GAP))
        mobile_reading_card.add_child(mobile_reading_card_vbox)
        mobile_narrative_scroll = ScrollContainer.new()
        mobile_narrative_scroll.name = "MobileNarrativeScroll"
        mobile_narrative_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
        mobile_narrative_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        mobile_narrative_scroll.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
        mobile_narrative_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
        mobile_narrative_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
        mobile_narrative_scroll.gui_input.connect(_on_mobile_event_reading_area_gui_input)
        ScrollbarThemeRef.apply_to(mobile_narrative_scroll)
        var narrative_v_bar: = mobile_narrative_scroll.get_v_scroll_bar()
        if narrative_v_bar != null:
            narrative_v_bar.value_changed.connect(_on_mobile_narrative_scroll_value_changed)
            narrative_v_bar.changed.connect(_update_mobile_continue_button_reveal)
        mobile_narrative_text_margin = MarginContainer.new()
        mobile_narrative_text_margin.name = "MobileNarrativeTextMargin"
        mobile_narrative_text_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        mobile_narrative_text_margin.add_theme_constant_override("margin_right", 34)
        var previous_parent: = narrative_label.get_parent()
        var narrative_index: = narrative_label.get_index()
        previous_parent.remove_child(narrative_label)
        event_vbox.add_child(mobile_reading_card)
        event_vbox.move_child(mobile_reading_card, narrative_index)
        mobile_reading_card_vbox.add_child(mobile_narrative_scroll)
        mobile_narrative_scroll.add_child(mobile_narrative_text_margin)
        mobile_narrative_text_margin.add_child(narrative_label)
        narrative_label.resized.connect(_on_mobile_narrative_label_resized)
        mobile_reading_button_spacer = Control.new()
        mobile_reading_button_spacer.name = "MobileReadingButtonSpacer"
        mobile_reading_button_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        mobile_reading_button_spacer.visible = false
        mobile_reading_button_spacer.custom_minimum_size = Vector2.ZERO
        mobile_reading_button_spacer.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
        mobile_reading_card_vbox.add_child(mobile_reading_button_spacer)


        mobile_choice_narrative_container = MarginContainer.new()
        mobile_choice_narrative_container.name = "MobileChoiceNarrativeContainer"
        mobile_choice_narrative_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        mobile_choice_narrative_container.add_theme_constant_override("margin_top", 36)
        mobile_choice_narrative_container.add_theme_constant_override("margin_bottom", 36)
        mobile_choice_narrative_container.mouse_filter = Control.MOUSE_FILTER_STOP
        mobile_choice_narrative_container.gui_input.connect(_on_mobile_choice_narrative_gui_input)


        mobile_choice_narrative_label = Label.new()
        mobile_choice_narrative_label.name = "MobileChoiceNarrativeLabel"
        mobile_choice_narrative_label.add_theme_font_override("font", FontLoader.body())
        mobile_choice_narrative_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        mobile_choice_narrative_label.max_lines_visible = 3
        mobile_choice_narrative_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
        mobile_choice_narrative_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        mobile_choice_narrative_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL


        mobile_choice_narrative_label.add_theme_font_size_override("font_size", MOBILE_EVENT_NARRATIVE_FONT_SIZE)
        mobile_choice_narrative_label.add_theme_constant_override("line_spacing", 16)
        mobile_choice_narrative_label.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
        mobile_choice_narrative_label.modulate.a = 0.85


        mobile_choice_narrative_container.add_child(mobile_choice_narrative_label)
        event_vbox.add_child(mobile_choice_narrative_container)
        event_vbox.move_child(mobile_choice_narrative_container, mobile_reading_card.get_index() + 1)



    if is_instance_valid(mobile_continue_button):
        return
    mobile_continue_button = Button.new()
    mobile_continue_button.name = "MobileEventContinueButton"
    mobile_continue_button.text = "▾"
    mobile_continue_button.tooltip_text = "继续"
    mobile_continue_button.custom_minimum_size = Vector2(0, MOBILE_EVENT_CONTINUE_BUTTON_HEIGHT)
    mobile_continue_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    mobile_continue_button.add_theme_font_size_override("font_size", 38)
    GameScreenStyleFactory.apply_command_button_style(mobile_continue_button, "primary", 18, 8)
    mobile_continue_button.pressed.connect(_on_mobile_event_continue_pressed)
    mobile_reading_card_vbox.add_child(mobile_continue_button)

func _on_mobile_choice_narrative_gui_input(event: InputEvent) -> void :
    if not _is_mobile_portrait() or mobile_event_phase != "choice":
        return
    if _is_primary_press_event(event):
        _return_to_mobile_event_reading()
        accept_event()
        get_viewport().set_input_as_handled()

func _return_to_mobile_event_reading() -> void :
    _suppress_mobile_event_reading_continue()
    mobile_event_phase = "reading"
    if is_instance_valid(event_scroll):
        event_scroll.scroll_vertical = 0
        event_scroll.set_deferred("scroll_vertical", 0)
    if is_instance_valid(mobile_choice_narrative_container):
        mobile_choice_narrative_container.visible = false
    _apply_mobile_event_phase_visibility()
    _finish_return_to_mobile_event_reading()

func _finish_return_to_mobile_event_reading() -> void :
    await get_tree().process_frame
    await get_tree().process_frame
    if not _is_mobile_portrait() or mobile_event_phase != "reading":
        return
    if is_instance_valid(event_scroll):
        event_scroll.scroll_vertical = 0
        event_scroll.set_deferred("scroll_vertical", 0)
    _sync_mobile_reading_card_height()
    _sync_mobile_immersive_reading_vertical_center()

func _suppress_mobile_event_reading_continue() -> void :
    mobile_event_reading_continue_suppress_until_ms = Time.get_ticks_msec() + MOBILE_EVENT_REOPEN_SUPPRESS_MS

func _should_suppress_mobile_event_reading_continue() -> bool:
    return Time.get_ticks_msec() < mobile_event_reading_continue_suppress_until_ms

func _is_mobile_choice_narrative_tap(event: InputEvent) -> bool:
    if not _is_mobile_portrait() or mobile_event_phase != "choice":
        return false
    if not is_instance_valid(mobile_choice_narrative_container) or not mobile_choice_narrative_container.visible:
        return false
    var tap_position = _get_primary_press_position(event)
    if tap_position == null:
        return false
    return mobile_choice_narrative_container.get_global_rect().has_point(tap_position)

func _on_mobile_reading_card_gui_input(event: InputEvent) -> void :
    if not _is_mobile_portrait() or mobile_event_phase != "reading":
        return
    _handle_mobile_reading_tap_event(event)

func _on_mobile_event_reading_area_gui_input(event: InputEvent) -> void :
    if not _is_mobile_portrait() or mobile_event_phase != "reading":
        _on_background_touch_drag(event)
        return
    _handle_mobile_reading_tap_event(event)



func _handle_mobile_reading_tap_event(event: InputEvent) -> void :
    if event is InputEventScreenDrag:
        _mobile_reading_press_moved = true
        NativeMobileTouchScrollRef.forward_drag_to_scroll(event, mobile_narrative_scroll, self, "event_scroll_touch_drag_suppress_until_ms")
        return
    if event is InputEventScreenTouch:
        if event.pressed:
            _mobile_reading_press_active = true
            _mobile_reading_press_moved = false
            _mobile_reading_press_position = event.position
            _mobile_reading_press_in_narrative_area = _is_mobile_narrative_touch_position(event.position)
        else:
            var was_tap: = _mobile_reading_press_active and not _mobile_reading_press_moved
            if was_tap and _mobile_reading_press_position.distance_to(event.position) > MOBILE_READING_TAP_MOVE_THRESHOLD:
                was_tap = false
            var started_in_narrative_area: = _mobile_reading_press_in_narrative_area
            _mobile_reading_press_active = false
            _mobile_reading_press_moved = false
            _mobile_reading_press_in_narrative_area = false
            if was_tap:
                _try_continue_from_mobile_reading_tap(started_in_narrative_area)
        return

    if not _is_mobile_portrait() and _is_primary_press_event(event):
        _try_continue_from_mobile_reading_tap()

func _on_narrative_text_touch_drag(event: InputEvent) -> void :
    if not (event is InputEventScreenDrag):
        return
    if _is_mobile_portrait() and mobile_event_phase == "reading":
        NativeMobileTouchScrollRef.forward_drag_to_scroll(event, mobile_narrative_scroll, self, "event_scroll_touch_drag_suppress_until_ms")
        return
    _on_event_scroll_touch_drag(event)

func _try_continue_from_mobile_reading_tap(from_narrative_area: bool = false) -> void :
    if _should_suppress_mobile_event_reading_continue():
        return
    if _mobile_narrative_has_scrollbar():

        if not _is_mobile_narrative_scrolled_to_bottom():
            return

        if from_narrative_area:
            return

    _advance_mobile_event_to_choice()

func _is_mobile_narrative_touch_position(position: Vector2) -> bool:
    if not is_instance_valid(mobile_narrative_scroll) or not mobile_narrative_scroll.visible:
        return false
    return mobile_narrative_scroll.get_global_rect().has_point(position)

func _is_mobile_narrative_scrolled_to_bottom() -> bool:
    if not is_instance_valid(mobile_narrative_scroll):
        return true
    var max_scroll: = _get_mobile_narrative_max_scroll()
    return float(mobile_narrative_scroll.scroll_vertical) >= max_scroll - 10.0

func _get_mobile_narrative_max_scroll() -> float:
    if not is_instance_valid(mobile_narrative_scroll):
        return 0.0
    var bar: = mobile_narrative_scroll.get_v_scroll_bar()
    if bar == null:
        return 0.0
    var page: = maxf(bar.page, mobile_narrative_scroll.size.y)
    return maxf(0.0, bar.max_value - page)

func _mobile_narrative_has_scrollbar() -> bool:
    if not is_instance_valid(mobile_narrative_scroll):
        return false
    if mobile_narrative_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED:
        return false
    var bar: = mobile_narrative_scroll.get_v_scroll_bar()
    return bar != null and bar.max_value > 0.5

func _is_topbar_interactive_tap(tap_position: Vector2) -> bool:
    for control in [save_btn, load_btn, settings_btn, topbar_rank]:
        if is_instance_valid(control) and control.visible and control.get_global_rect().has_point(tap_position):
            return true
    return false

func _on_mobile_narrative_scroll_value_changed(_value: float) -> void :
    _update_mobile_continue_button_reveal()

func _update_mobile_continue_button_reveal() -> void :
    if not is_instance_valid(mobile_continue_button):
        return
    if not _is_mobile_event_reading_active():
        return
    var revealed: = not _mobile_narrative_has_scrollbar() or _is_mobile_narrative_scrolled_to_bottom()
    mobile_continue_button.modulate.a = 1.0 if revealed else 0.0
    mobile_continue_button.mouse_filter = Control.MOUSE_FILTER_STOP if revealed else Control.MOUSE_FILTER_IGNORE
    mobile_continue_button.disabled = not revealed

func _on_mobile_narrative_label_resized() -> void :
    if _mobile_reading_layout_resync_queued:
        return
    if not _is_mobile_event_reading_active():
        return
    _mobile_reading_layout_resync_queued = true
    call_deferred("_run_mobile_reading_layout_resync")

func _run_mobile_reading_layout_resync() -> void :
    _mobile_reading_layout_resync_queued = false
    if not _is_mobile_event_reading_active():
        return
    _sync_mobile_reading_card_height()

func _is_fullscreen_mobile_reading_tap(event: InputEvent) -> bool:
    if not _is_mobile_portrait() or mobile_event_phase != "reading":
        return false
    if not is_instance_valid(event_scroll) or not event_scroll.visible:
        return false
    var tap_position: = Vector2.ZERO
    if event is InputEventMouseButton:
        if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
            return false
        tap_position = event.global_position
    elif event is InputEventScreenTouch:
        if not event.pressed:
            return false
        tap_position = event.position
    else:
        return false
    if _is_topbar_interactive_tap(tap_position):
        return false
    if not event_scroll.get_global_rect().has_point(tap_position):
        return false

    if _mobile_narrative_has_scrollbar():
        if is_instance_valid(mobile_narrative_scroll) and mobile_narrative_scroll.visible\
and mobile_narrative_scroll.get_global_rect().has_point(tap_position):
            return false
    return true

func _make_mobile_continue_button_style(hovered: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0, 0, 0, 0)
    style.border_width_left = 0
    style.border_width_right = 0
    style.border_width_top = 0
    style.border_width_bottom = 0
    style.border_color = Color(0, 0, 0, 0)
    style.corner_radius_top_left = 2
    style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2
    style.corner_radius_bottom_right = 2
    style.content_margin_left = 24
    style.content_margin_right = 24
    style.content_margin_top = 0
    style.content_margin_bottom = 0
    return style

func _make_mobile_reading_card_style(mobile: bool, active: bool) -> StyleBox:
    if not mobile:
        return StyleBoxEmpty.new()
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0, 0, 0, 0)
    style.border_width_left = 0
    style.border_width_right = 0
    style.border_width_top = 0
    style.border_width_bottom = 0
    style.border_color = Color(0, 0, 0, 0)
    style.corner_radius_top_left = 4
    style.corner_radius_top_right = 4
    style.corner_radius_bottom_left = 4
    style.corner_radius_bottom_right = 4
    style.content_margin_left = 0
    style.content_margin_right = 0
    style.content_margin_top = 0
    style.content_margin_bottom = 0
    style.shadow_size = 0
    style.shadow_color = Color(0, 0, 0, 0)
    return style

func _draw_mobile_reading_card_border() -> void :
    if not is_instance_valid(mobile_reading_card) or not mobile_reading_card.visible:
        return
    if not _is_mobile_portrait() or mobile_event_phase != "reading":
        return
    return

func _sync_mobile_reading_card_height() -> void :
    await get_tree().process_frame
    if not _is_mobile_portrait() or mobile_event_phase != "reading":
        return
    if not is_instance_valid(mobile_reading_card) or not is_instance_valid(event_scroll):
        return
    var title_group: = event_title_label.get_parent() as Control
    var title_height: = title_group.get_combined_minimum_size().y if title_group != null else 0.0
    var available_height: = event_scroll.size.y
    if available_height <= 0.0:
        available_height = get_viewport_rect().size.y
    var max_scroll_height: = maxf(120.0, available_height - title_height - MOBILE_EVENT_IMMERSIVE_TITLE_BODY_GAP - MOBILE_EVENT_CONTINUE_GAP - MOBILE_EVENT_CONTINUE_BUTTON_HEIGHT)
    var visible_text_height: = _sync_mobile_narrative_scroll_height(max_scroll_height)
    mobile_reading_card.custom_minimum_size.y = visible_text_height + MOBILE_EVENT_CONTINUE_GAP + MOBILE_EVENT_CONTINUE_BUTTON_HEIGHT
    if is_instance_valid(mobile_continue_button):
        mobile_continue_button.custom_minimum_size = Vector2(0, MOBILE_EVENT_CONTINUE_BUTTON_HEIGHT)
    mobile_reading_card.queue_redraw()
    _sync_mobile_immersive_reading_vertical_center()
    _update_mobile_continue_button_reveal()

func _sync_mobile_narrative_scroll_height(max_scroll_height: float = -1.0) -> float:
    if not is_instance_valid(mobile_narrative_scroll) or not is_instance_valid(narrative_label):
        return 0.0
    if max_scroll_height <= 0.0:
        var card_height: = mobile_reading_card.custom_minimum_size.y if is_instance_valid(mobile_reading_card) else 0.0
        if card_height <= 0.0:
            card_height = mobile_reading_card.size.y if is_instance_valid(mobile_reading_card) else 0.0
        max_scroll_height = maxf(120.0, card_height - MOBILE_EVENT_CONTINUE_GAP - MOBILE_EVENT_CONTINUE_BUTTON_HEIGHT)
    var text_height: = _get_mobile_narrative_content_height()
    var fits_without_scrollbar: = text_height <= max_scroll_height + MOBILE_EVENT_SCROLLBAR_TOLERANCE
    var visible_text_height: = text_height if fits_without_scrollbar else max_scroll_height
    mobile_narrative_scroll.custom_minimum_size.y = visible_text_height
    mobile_narrative_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED if fits_without_scrollbar else ScrollContainer.SCROLL_MODE_AUTO
    ScrollbarThemeRef.apply_to(mobile_narrative_scroll)
    return visible_text_height

func _get_mobile_narrative_content_height() -> float:
    if not is_instance_valid(narrative_label):
        return 0.0
    var label_height: = narrative_label.get_combined_minimum_size().y
    var margin_height: = 0.0
    if is_instance_valid(mobile_narrative_text_margin):
        margin_height = mobile_narrative_text_margin.get_combined_minimum_size().y
    return maxf(label_height, margin_height) + 10.0

func _schedule_mobile_reading_layout_sync() -> void :
    await get_tree().process_frame
    await get_tree().process_frame
    if not _is_mobile_portrait() or mobile_event_phase != "reading":
        return
    _sync_mobile_reading_card_height()

func _on_mobile_event_continue_pressed() -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(self, "event_scroll_touch_drag_suppress_until_ms"):
        return
    _advance_mobile_event_to_choice()

func _advance_mobile_event_to_choice() -> void :
    mobile_event_phase = "choice"
    _apply_mobile_event_phase_visibility()
    CardAnimations.play_control_enter(choices_container, 0.2, 16.0)
    if is_instance_valid(event_scroll):
        event_scroll.set_deferred("scroll_vertical", 0)
    _apply_mobile_focus_outer_spacing(true)

func _apply_mobile_event_phase_visibility() -> void :
    _mobile_reading_controller.apply_phase_visibility()


func _apply_mobile_immersive_event_reading(reading: bool) -> void :
    _mobile_reading_controller.apply_immersive_event_reading(reading)

func _is_mobile_event_reading_active() -> bool:
    return _is_mobile_portrait() and mobile_event_phase == "reading" and ( not GameState.is_governance_mode() or governance_active_card_index >= 0)


func _sync_mobile_immersive_reading_vertical_center() -> void :
    _mobile_reading_controller.sync_vertical_center()

func _can_afford_card(card_index: int) -> bool:
    var event_data = GameState.get_month_card_event(card_index)
    var choices = event_data.get("choices", [])
    if choices.is_empty():
        return true

    for choice in choices:
        var can_afford_this_choice = true
        var effects = choice.get("effects", {})
        var skip_limit_for = choice.get("skipLimitFor", [])
        for key in effects:
            if key in skip_limit_for:
                continue
            var effect_val = int(effects[key])
            if effect_val < 0:
                var current_val = 0
                if key == "private_silver":
                    current_val = GameState.private_silver
                elif key in GameState.stats:
                    current_val = GameState.stats[key]
                elif key in GameState.city:
                    current_val = GameState.city[key]
                elif key in GameState.attitudes:
                    current_val = GameState.attitudes[key]
                if current_val + effect_val < 0:
                    if key in ["private_silver", "yinliang", "liangshi", "bingyong", "action_points"]:
                        can_afford_this_choice = false
                        break
        if can_afford_this_choice:
            return true

    return false

func _prepare_act_transition_surface() -> void :
    result_panel.visible = false
    choices_container.visible = false
    next_button.visible = false
    mobile_event_phase = "reading"
    $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter.visible = false


    if is_instance_valid(event_portrait_layer):
        event_portrait_layer.visible = false
    if is_instance_valid(event_portrait_backdrop):
        event_portrait_backdrop.visible = false
    _set_center_panel_bg_transparent(false)
    _set_event_portrait_spacer_width(0.0)
    _apply_mobile_event_phase_visibility()

func _show_governance_overview(play_deal_animation: bool = true) -> void :
    _ensure_bianwu_defense_button()
    result_panel.visible = false
    choices_container.visible = false
    next_button.visible = false
    mobile_event_phase = "reading"
    var pending_transition: = _consume_pending_act_transition()
    if not pending_transition.is_empty():



        if is_instance_valid(GameState):
            GameState.governance_playlist_active = false
            GameState.play_bgm("res://assets/" + "transfer_bgm.mp3", 1.5)
        _prepare_act_transition_surface()
        _show_act_transition_narrative(pending_transition, Callable(self, "_show_governance_overview"))
        return



    if is_instance_valid(GameState):
        if GameState.current_bgm_path == "res://assets/" + "riot_bgm.mp3" and GameState.riot_interrupt_active:
            GameState.resume_riot_interrupted_bgm(1.5)
        elif GameState.current_bgm_path == "res://assets/" + "riot_bgm.mp3" or GameState.current_bgm_path == "res://assets/" + "transfer_bgm.mp3":
            GameState.play_default_bgm(1.5)
        elif GameState.current_bgm_path == "res://assets/" + "normal_bgm.mp3" or GameState.current_bgm_path == "res://assets/" + "prologue_bgm.mp3" or GameState.is_title_playlist_path(GameState.current_bgm_path) or GameState.current_bgm_path == "res://assets/" + "终局回响.mp3" or GameState.current_bgm_path == "":
            GameState.play_default_bgm(2.0)



    if GameState.has_feature("governance") and GameState.year == 1 and GameState.month == 9 and not GameState.get_meta("act_transition_shown_1", false):
        GameState.set_meta("act_transition_shown_1", true)
        var act1: Dictionary = GameData.ACT_CONFIG.get("1", {})
        _show_stage_transition(str(act1.get("title", "")), str(act1.get("sub", "")), Callable(self, "_show_governance_overview"))
        return

    var bad_ending = EndingServiceRef.get_bad_ending_payload(GameState)
    if not bad_ending.is_empty():
        game_ended.emit(bad_ending)
        return

    if GameState.is_game_over():
        var ending = GameState.determine_ending()
        if ending.is_empty():
            return
        game_ended.emit(ending)
        return

    _autosave_current_safe_state()

    governance_active_card_index = -1
    selected_mobile_month_card_index = -1
    _clear_mobile_month_card_preview()
    governance_scroll.visible = true
    _apply_mobile_immersive_event_reading(false)
    _apply_dynamic_theme()
    _apply_game_background_mask()
    var tween = create_tween()
    tween.tween_property(game_overlay, "modulate:a", _governance_overlay_alpha(), 0.4)
    governance_scroll.set_deferred("scroll_vertical", 0)
    $MainVBox / Layout / CenterPanel / CenterMargin / ScrollOuter.visible = false
    _update_event_portrait_layout()
    governance_stage_label.add_theme_color_override("font_color", _governance_header_color(false))
    governance_turn_label.text = GameState.get_governance_turn_label()
    if _is_mobile_portrait():
        var center_margin: MarginContainer = $MainVBox / Layout / CenterPanel / CenterMargin
        center_margin.add_theme_constant_override("margin_left", MOBILE_CONTENT_SIDE_MARGIN)
        center_margin.add_theme_constant_override("margin_right", MOBILE_CONTENT_SIDE_MARGIN)
        _apply_mobile_governance_width_constraints()
        _apply_mobile_jushi_stats_layout()
    governance_stage_label.visible = false
    governance_turn_label.visible = false
    action_points_value.text = ""
    _update_action_points_separator()
    _update_action_points_dots()
    _configure_mobile_month_execute_button()
    if _is_mobile_portrait():
        governance_stage_label.add_theme_font_size_override("font_size", 24)
    else:
        governance_stage_label.add_theme_font_size_override("font_size", 12)

    _reposition_governance_action_points_row()
    var ap_label = $MainVBox / Layout / CenterPanel / CenterMargin / GovernanceScroll / GovernanceVBox / ActionPointsRow / ActionPointsLabel
    if ap_label: ap_label.visible = false

    var ap_style = StyleBoxFlat.new()
    ap_style.bg_color = Color(0.99, 0.98, 0.96, 0.9) if GameState.theme == "light" else Color(0.1, 0.075, 0.055, 0.92)
    ap_style.border_width_left = 1;ap_style.border_width_right = 1
    ap_style.border_width_top = 1;ap_style.border_width_bottom = 1
    ap_style.border_color = Color(0.72, 0.6, 0.34, 0.18) if GameState.theme == "light" else Color(0.86, 0.72, 0.43, 0.2)
    ap_style.corner_radius_top_left = 18;ap_style.corner_radius_top_right = 18
    ap_style.corner_radius_bottom_left = 18;ap_style.corner_radius_bottom_right = 18
    ap_style.content_margin_left = 0
    ap_style.content_margin_right = 0
    ap_style.content_margin_top = 6;ap_style.content_margin_bottom = 6
    if _is_mobile_portrait():
        action_points_value.custom_minimum_size.y = 72.0
        action_points_value.add_theme_font_size_override("font_size", MOBILE_ACTION_POINTS_FONT_SIZE)
    else:
        action_points_value.custom_minimum_size.y = 0
        action_points_value.add_theme_font_size_override("font_size", 16)
    action_points_value.add_theme_font_override("font", FontLoader.body())
    action_points_value.add_theme_stylebox_override("normal", ap_style)
    action_points_value.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    _update_action_points_separator()
    _update_action_points_dots()

    var is_new_deal = GameState.month_cards_done.size() == 0
    if is_new_deal:
        _city_stats_display_controller.collapse_city_boosts_for_new_month()
        bw_current_location = ""
    for child in month_cards_container.get_children():
        month_cards_container.remove_child(child)
        child.queue_free()
    if _is_mobile_portrait():
        month_cards_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        month_cards_container.custom_minimum_size.x = 0
        month_cards_container.alignment = FlowContainer.ALIGNMENT_BEGIN
        month_cards_container.add_theme_constant_override("h_separation", 6)
        month_cards_container.add_theme_constant_override("v_separation", 12)
    else:
        month_cards_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        month_cards_container.custom_minimum_size.x = 0
        month_cards_container.alignment = FlowContainer.ALIGNMENT_CENTER
        month_cards_container.add_theme_constant_override("h_separation", NATIVE_LANDSCAPE_MONTH_CARD_GAP if _is_native_mobile_landscape() else 12)
        month_cards_container.add_theme_constant_override("v_separation", 12 if _is_native_mobile_landscape() else 16)

    var cards: Array = EventServiceRef.generate_month_cards(GameState)
    print("[Debug] _show_governance_overview cards loaded. size: ", cards.size())
    for i in range(cards.size()):
        var c = cards[i]
        print("  - [", i, "] type: ", c.get("type", ""), ", id: ", c.get("id", ""), ", title: ", c.get("title", ""))
    if _show_direct_story_card_if_needed(cards):
        return
    var story_blocking: bool = false
    for idx in range(cards.size()):
        var maybe_story: Dictionary = cards[idx]
        if maybe_story.get("type", "") in ["story", "attitude", "grain_shortage"] and not GameState.month_cards_done.has(idx):
            story_blocking = true
            break
    var riot_blocking: bool = false
    for idx in range(cards.size()):
        var maybe_riot: Dictionary = cards[idx]
        if maybe_riot.get("type", "") == "riot" and not GameState.month_cards_done.has(idx):
            riot_blocking = true
            break

    var mutiny_blocking: bool = false
    for idx in range(cards.size()):
        var maybe_mutiny: Dictionary = cards[idx]
        if maybe_mutiny.get("type", "") == "mutiny" and not GameState.month_cards_done.has(idx):
            mutiny_blocking = true
            break




    _set_bianwu_ap_floating(_is_bianwu_desktop_overview())
    _update_bw_sidebar_collapse_button()
    _clear_bianwu_story_banner()

    for idx in _get_month_card_display_indices(cards):
        var card: Dictionary = cards[idx]
        var card_size: = _get_month_card_size()

        if GameData.active_line == "bianwu":
            card_size = _get_bianwu_month_card_size()
        var lock_reason: = ""
        var card_slot: = Control.new()
        card_slot.custom_minimum_size = card_size
        card_slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        card_slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        card_slot.clip_contents = (GameState.theme != "light")

        var card_button: = Button.new()
        card_button.mouse_filter = Control.MOUSE_FILTER_PASS
        card_button.gui_input.connect(_on_governance_scroll_touch_drag)
        card_button.text = ""
        card_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        card_button.set_anchors_preset(Control.PRESET_FULL_RECT)
        card_button.custom_minimum_size = card_size
        var blocked_by_story: bool = story_blocking and card.get("type", "") not in ["story", "attitude", "grain_shortage"]
        var blocked_by_riot: bool = riot_blocking and card.get("type", "") not in ["riot", "story", "attitude", "grain_shortage"]
        var blocked_by_mutiny: bool = mutiny_blocking and card.get("type", "") not in ["riot", "mutiny", "story", "attitude", "grain_shortage"]
        var disabled: bool = GameState.month_cards_done.has(idx) or GameState.action_points <= 0 or blocked_by_story or blocked_by_riot or blocked_by_mutiny or not _can_afford_card(idx)
        if GameState.month_cards_done.has(idx):
            lock_reason = "已处理"
        elif GameState.action_points <= 0:
            lock_reason = "行动力不足"
        elif blocked_by_story:
            lock_reason = "需先处置本月大事"
        elif blocked_by_riot:
            lock_reason = "需先处置流民暴动"
        elif blocked_by_mutiny:
            lock_reason = "需先处置兵勇哗变"
        elif not _can_afford_card(idx):
            lock_reason = "资源不足"
        card_button.disabled = disabled and not _is_mobile_portrait()
        card_button.add_theme_stylebox_override("normal", _make_month_card_style(card, disabled, false))
        card_button.add_theme_stylebox_override("hover", _make_month_card_style(card, disabled, true))
        card_button.add_theme_stylebox_override("pressed", _make_month_card_style(card, disabled, true, true))
        card_button.add_theme_stylebox_override("disabled", _make_month_card_style(card, disabled, false))




        card_button.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW


        if not _is_mobile_portrait():
            _build_landscape_month_card(card_button, card, disabled, idx, lock_reason, card_size)
            card_button.pressed.connect(_on_month_card_pressed.bind(idx))
            card_slot.add_child(card_button)
            card_slot.set_meta("month_card", card)
            card_slot.set_meta("disabled", disabled)
            card_slot.set_meta("lock_reason", lock_reason)
            month_cards_container.add_child(card_slot)
            _play_pending_month_card_settle(idx, card_button)
            continue

        var effect_layer = Control.new()
        effect_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
        effect_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        effect_layer.draw.connect( func():
            var s = effect_layer.size
            var overlay_cols = _month_card_overlay_colors(card, disabled)
            var steps: = 56
            for band in range(steps):
                var t: = float(band) / float(maxi(1, steps - 1))
                var band_col: Color = overlay_cols[0].lerp(overlay_cols[1], t)
                var y0: float = 1.0 + (s.y - 2.0) * float(band) / float(steps)
                var y1: float = 1.0 + (s.y - 2.0) * float(band + 1) / float(steps)
                effect_layer.draw_rect(Rect2(1, y0, s.x - 2, y1 - y0 + 1.0), band_col)
            var stripe_col = Color(0.38, 0.36, 0.32, 0.035) if (GameState.theme == "light" and disabled) else (Color(0.58, 0.43, 0.26, 0.03) if GameState.theme == "light" else Color(0.85, 0.75, 0.55, 0.014))
            var step = 16
            for x in range(5, int(s.x) - 1, step):
                var line_alpha: float = stripe_col.a * (0.55 + GrainTexture.hash_noise(x, int(s.y), 211) * 0.45)
                effect_layer.draw_line(Vector2(x, 1), Vector2(x, s.y - 1), Color(stripe_col.r, stripe_col.g, stripe_col.b, line_alpha), 1.0)
        )
        card_button.add_child(effect_layer)
        _attach_grain_texture_layer(card_button, "MonthCardGrainLayer", _month_card_grain_alpha(disabled), 1)

        var box = VBoxContainer.new()

        box.alignment = BoxContainer.ALIGNMENT_BEGIN if _is_mobile_portrait() else BoxContainer.ALIGNMENT_CENTER
        box.set_anchors_preset(Control.PRESET_FULL_RECT)
        box.offset_left = _mobile_font_size(12, 14)
        box.offset_top = _mobile_font_size(16, 28)
        box.offset_right = - _mobile_font_size(12, 14)
        box.offset_bottom = - _mobile_font_size(16, 10)
        box.mouse_filter = Control.MOUSE_FILTER_IGNORE
        box.add_theme_constant_override("separation", _mobile_font_size(10, 6))

        var tag_panel = PanelContainer.new()
        tag_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
        var tag_style = StyleBoxFlat.new()
        tag_style.bg_color = _month_card_tag_bg(disabled)
        _apply_style_border_width(tag_style, _responsive_border_width())
        tag_style.border_color = Color(GameState.get_theme_color("border_stronger" if not disabled else "border_weak"), 0.12)
        tag_style.corner_radius_top_left = 8;tag_style.corner_radius_top_right = 8
        tag_style.corner_radius_bottom_left = 8;tag_style.corner_radius_bottom_right = 8
        tag_style.content_margin_left = _mobile_font_size(12, 8);tag_style.content_margin_right = _mobile_font_size(12, 8)
        tag_style.content_margin_top = _mobile_font_size(3, 4);tag_style.content_margin_bottom = _mobile_font_size(3, 4)
        tag_panel.add_theme_stylebox_override("panel", tag_style)
        tag_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

        var tag_label = Label.new()
        tag_label.text = _get_month_card_tag_text(card)
        tag_label.add_theme_font_override("font", FontLoader.body())
        tag_label.add_theme_font_size_override("font_size", _mobile_font_size(11, 33))
        tag_label.add_theme_color_override("font_color", _month_card_text_color(disabled, true))
        tag_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        tag_panel.add_child(tag_label)
        box.add_child(tag_panel)

        var title = Label.new()
        title.text = _get_month_card_title(card)
        title.add_theme_font_override("font", FontLoader.serif_bold())
        title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        title.add_theme_font_size_override("font_size", _mobile_font_size(16, 38))
        title.add_theme_color_override("font_color", _month_card_text_color(disabled, true))
        title.max_lines_visible = 2
        title.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
        if _is_mobile_portrait():

            title.vertical_alignment = VERTICAL_ALIGNMENT_TOP
            var title_font: = title.get_theme_font("font")
            var title_font_size: = _mobile_font_size(16, 38)
            title.custom_minimum_size.y = title_font.get_height(title_font_size) * 2.0
        box.add_child(title)

        var summary = Label.new()
        summary.text = _build_month_card_summary(card)
        summary.add_theme_font_override("font", FontLoader.body())
        summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        summary.add_theme_font_size_override("font_size", _mobile_font_size(12, 31))
        summary.add_theme_color_override("font_color", _month_card_text_color(disabled, false))
        if not _is_mobile_portrait():
            summary.size_flags_vertical = Control.SIZE_EXPAND_FILL
            summary.custom_minimum_size.y = 1
        summary.max_lines_visible = _get_month_card_summary_lines(card) if _is_mobile_portrait() else 3
        summary.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
        summary.visible = summary.text != ""
        box.add_child(summary)

        var note_text = _get_month_card_note_text(card)

        if note_text != "":
            var note_label = Label.new()
            note_label.text = note_text
            note_label.add_theme_font_override("font", FontLoader.body())
            note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            note_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            note_label.add_theme_font_size_override("font_size", _mobile_font_size(9, 20))
            var note_color = _month_card_text_color(disabled, false)
            note_color.a = note_color.a * 0.55
            note_label.add_theme_color_override("font_color", note_color)
            note_label.max_lines_visible = 2 if _is_mobile_portrait() else 0
            note_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
            note_label.visible = not _is_mobile_portrait() or str(card.get("type", "")) in ["governance", "trade", "home", "field"]
            box.add_child(note_label)

        var status_text = ""
        if GameState.month_cards_done.has(idx):
            status_text = "已处理"
        elif disabled and lock_reason != "":
            status_text = lock_reason

        if _is_mobile_portrait() and status_text == "需先处置本月大事":
            status_text = ""

        if status_text != "":
            var status_label = Label.new()
            status_label.text = status_text
            status_label.add_theme_font_override("font", FontLoader.body())
            status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            var font_sz = MOBILE_MONTH_CARD_STATUS_FONT_SIZE if _is_mobile_portrait() else 12
            if status_text == "需先处置本月大事":
                font_sz = (MOBILE_MONTH_CARD_STATUS_FONT_SIZE - 2) if _is_mobile_portrait() else 10
            status_label.add_theme_font_size_override("font_size", font_sz)
            var status_color: = GameState.get_theme_color("text_sub")
            if status_text == "需先处置本月大事":
                status_color.a = status_color.a * 0.35
            status_label.add_theme_color_override("font_color", status_color)
            box.add_child(status_label)

        card_button.add_child(box)
        card_button.pressed.connect(_on_month_card_pressed.bind(idx))
        card_slot.add_child(card_button)
        card_slot.set_meta("month_card", card)
        card_slot.set_meta("month_card_index", idx)
        card_slot.set_meta("disabled", disabled)
        card_slot.set_meta("lock_reason", lock_reason)
        month_cards_container.add_child(card_slot)
        _play_pending_month_card_settle(idx, card_button)

    if _is_mobile_portrait() and cards.size() > 0:
        _clear_mobile_month_card_preview()
        selected_mobile_month_card_index = -1

    if play_deal_animation and (is_new_deal or _bw_force_deal_animation) and month_cards_container.get_child_count() > 0:
        CardAnimations.play_shuffle_deal(month_cards_container)
    _bw_force_deal_animation = false

    _sync_action_points_card_alignment()
    call_deferred("_sync_action_points_card_alignment_after_layout")
    call_deferred("_apply_native_mobile_font_scale")



    _refresh_month_warning()





    if governance_active_card_index < 0 and GameState.action_points <= 0\
and not story_blocking and not riot_blocking and not mutiny_blocking:
        _schedule_month_advance_after_settle()

func _show_direct_story_card_if_needed(cards: Array) -> bool:
    for idx in range(cards.size()):
        var card: Dictionary = cards[idx]
        if GameState.month_cards_done.has(idx):
            continue
        if card.get("type", "") == "story" and bool(card.get("direct", false)):
            governance_active_card_index = idx
            _show_current_event()
            return true
    return false




func _get_month_card_display_indices(cards: Array) -> Array:
    var display_indices: Array = range(cards.size())
    if GameData.active_line != "bianwu":
        return display_indices
    var selected_region: = _resolved_bianwu_selected_region_id(_bw_defense_selected_region_id)
    var filtered: Array = []
    for idx in range(cards.size()):
        var card: Dictionary = cards[idx]
        var card_type: = str(card.get("type", ""))
        if BW_BANNER_CARD_TYPES.has(card_type):
            filtered.append(idx)
            continue
        var card_region: = str(card.get("bw_region", ""))
        if card_type == "bw_assault":
            if card_region == selected_region and not BianwuDefenseServiceRef.enemy_in_region(GameState, card_region).is_empty():
                filtered.append(idx)
            continue
        if card_region == "" or card_region == selected_region:
            filtered.append(idx)
    display_indices = filtered
    var priority_idx: = -1
    for idx in display_indices:
        var card: Dictionary = cards[idx]
        if BW_BANNER_CARD_TYPES.has(str(card.get("type", ""))) and not GameState.month_cards_done.has(idx):
            priority_idx = idx
            break
    if priority_idx >= 0:
        display_indices.erase(priority_idx)
        display_indices.push_front(priority_idx)
    return display_indices






func _is_bianwu_desktop_overview() -> bool:
    return GameData.active_line == "bianwu" and not _is_mobile_portrait()







const BW_OVERVIEW_RIGHT_MARGIN: = 8
const CENTER_MARGIN_RIGHT_DEFAULT: = 32
const CENTER_MARGIN_MIN_WIDTH_DEFAULT: = 1000.0


func _debug_dump_bw_layout_rects() -> void :
    await get_tree().process_frame
    await get_tree().process_frame
    var vp: = get_viewport_rect()
    print("[BWDBG] viewport=", vp)
    var cm: Control = center_panel.get_node_or_null("CenterMargin")
    for pair in [["center_panel", center_panel], ["center_margin", cm], ["gov_scroll", governance_scroll], ["gov_vbox", governance_vbox], ["month_cards", month_cards_container]]:
        var n: Control = pair[1]
        if n == null: continue
        print("[BWDBG] ", pair[0], " global_rect=", n.get_global_rect(), " size_flags_h=", n.size_flags_horizontal, " min=", n.custom_minimum_size)
    if cm != null:
        print("[BWDBG] cm margin_right=", cm.get_theme_constant("margin_right"))
    if month_cards_container.get_child_count() > 0:
        var last: = month_cards_container.get_child(month_cards_container.get_child_count() - 1) as Control
        if last != null:
            print("[BWDBG] last_card rect=", last.get_global_rect())

func _apply_bianwu_overview_right_margin(active: bool) -> void :
    if _is_mobile_portrait():
        return
    var cm: MarginContainer = center_panel.get_node_or_null("CenterMargin")
    if cm == null:
        return
    if active:
        cm.add_theme_constant_override("margin_right", BW_OVERVIEW_RIGHT_MARGIN)
        cm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        cm.custom_minimum_size.x = 0.0
    else:
        cm.add_theme_constant_override("margin_right", CENTER_MARGIN_RIGHT_DEFAULT)
        cm.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER
        cm.custom_minimum_size.x = CENTER_MARGIN_MIN_WIDTH_DEFAULT

func _ensure_bw_ap_float_overlay() -> Control:
    if _bw_ap_float_overlay != null and is_instance_valid(_bw_ap_float_overlay):
        return _bw_ap_float_overlay
    var o: = Control.new()
    o.name = "BianwuActionPointsFloat"
    o.mouse_filter = Control.MOUSE_FILTER_IGNORE
    o.set_anchors_preset(Control.PRESET_FULL_RECT)
    center_panel.add_child(o)
    _bw_ap_float_overlay = o
    return o

func _set_bianwu_ap_floating(active: bool) -> void :

    _apply_bianwu_overview_right_margin(false)
    if active:
        _bianwu_ap_floating = true
        var o: = _ensure_bw_ap_float_overlay()
        o.visible = true
        if action_points_row.get_parent() != o:
            _detach_node(action_points_row)
            o.add_child(action_points_row)
        action_points_row.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
        action_points_row.alignment = BoxContainer.ALIGNMENT_BEGIN
        if is_instance_valid(desktop_action_points_left_spacer):
            desktop_action_points_left_spacer.visible = false
            desktop_action_points_left_spacer.custom_minimum_size.x = 0.0
        call_deferred("_position_bianwu_ap_float")
    else:
        if not _bianwu_ap_floating:
            return
        _bianwu_ap_floating = false
        if is_instance_valid(_bw_ap_float_overlay):
            _bw_ap_float_overlay.visible = false
        if is_instance_valid(action_points_row) and action_points_row.get_parent() != governance_vbox:
            _detach_node(action_points_row)
            governance_vbox.add_child(action_points_row)
            action_points_row.position = Vector2.ZERO
            action_points_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

            _reposition_governance_action_points_row()

func _position_bianwu_ap_float() -> void :
    if not _bianwu_ap_floating:
        return
    if not is_instance_valid(action_points_row) or not is_instance_valid(center_panel):
        return


    await get_tree().process_frame
    await get_tree().process_frame
    if not _bianwu_ap_floating or not is_instance_valid(action_points_row):
        return
    action_points_row.size = action_points_row.get_combined_minimum_size()
    var cp_rect: = center_panel.get_global_rect()
    var pad_l: = 0.0
    var pad_t: = 0.0
    var sb: = center_panel.get_theme_stylebox("panel")
    if sb != null:
        pad_l = sb.get_margin(SIDE_LEFT)
        pad_t = sb.get_margin(SIDE_TOP)
    var content_left: = cp_rect.position.x + pad_l
    var content_top: = cp_rect.position.y + pad_t



    var card_h: = action_points_row.size.y
    if _action_points_portrait_active:
        action_points_row.global_position = Vector2(
            content_left + 8.0 + _ap_hex_right, 
            content_top + 8.0 + _ap_portrait_size - 6.0 - card_h
        )
    else:
        action_points_row.global_position = Vector2(content_left + 8.0, content_top + 8.0)

    await get_tree().process_frame
    if not _bianwu_ap_floating:
        return
    _position_ap_portrait_overlay()


    if is_instance_valid(_ap_portrait_overlay):
        center_panel.move_child(_ap_portrait_overlay, -1)
    _position_bw_juntian_diamond()
    _position_bw_sidebar_collapse_button()





func _bw_left_panel() -> Control:
    if left_tabs_host == null or not is_instance_valid(left_tabs_host):
        return null
    var shell: = left_tabs_host.get_parent()
    if shell == null:
        return null
    return shell.get_parent() as Control

func _make_bw_sidebar_btn_style(hovered: bool) -> StyleBoxFlat:
    var s: = StyleBoxFlat.new()

    s.bg_color = Color(0.16, 0.1, 0.05, 0.62) if hovered else Color(0.07, 0.055, 0.04, 0.85)
    s.border_color = Color(0.8, 0.62, 0.32, 0.42) if hovered else Color(0.62, 0.5, 0.3, 0.35)
    s.border_width_top = 1
    s.border_width_right = 1
    s.border_width_bottom = 1
    s.border_width_left = 0
    s.corner_radius_top_right = 8
    s.corner_radius_bottom_right = 8
    s.content_margin_left = 5
    s.content_margin_right = 5
    s.content_margin_top = 10
    s.content_margin_bottom = 10
    return s


func _sidebar_collapse_supported() -> bool:
    return not _is_mobile_portrait()


func _ensure_bw_sidebar_btn_overlay() -> Control:
    if _bw_sidebar_btn_overlay != null and is_instance_valid(_bw_sidebar_btn_overlay):
        return _bw_sidebar_btn_overlay
    var o: = Control.new()
    o.name = "SidebarCollapseBtnFloat"
    o.mouse_filter = Control.MOUSE_FILTER_IGNORE
    o.set_anchors_preset(Control.PRESET_FULL_RECT)
    center_panel.add_child(o)
    _bw_sidebar_btn_overlay = o
    return o

func _update_bw_sidebar_collapse_button() -> void :
    if not _sidebar_collapse_supported():
        if _bw_sidebar_collapsed:
            _set_bw_sidebar_collapsed(false, true)
        if _bw_sidebar_btn_overlay != null and is_instance_valid(_bw_sidebar_btn_overlay):
            _bw_sidebar_btn_overlay.visible = false
        return
    if _bw_sidebar_collapse_btn == null or not is_instance_valid(_bw_sidebar_collapse_btn):
        var btn: = Button.new()
        btn.name = "BwSidebarCollapseBtn"
        btn.focus_mode = Control.FOCUS_NONE
        btn.custom_minimum_size = Vector2(26, 84)
        btn.add_theme_font_override("font", FontLoader.serif_bold())
        btn.add_theme_font_size_override("font_size", 13)
        btn.add_theme_color_override("font_color", Color(0.86, 0.78, 0.62, 0.9))
        btn.add_theme_color_override("font_hover_color", Color(0.95, 0.89, 0.76))
        btn.add_theme_stylebox_override("normal", _make_bw_sidebar_btn_style(false))
        btn.add_theme_stylebox_override("hover", _make_bw_sidebar_btn_style(true))
        btn.add_theme_stylebox_override("pressed", _make_bw_sidebar_btn_style(true))
        btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
        btn.pressed.connect(_on_bw_sidebar_collapse_pressed)
        _ensure_bw_sidebar_btn_overlay().add_child(btn)
        _bw_sidebar_collapse_btn = btn
    _ensure_bw_sidebar_btn_overlay().visible = true
    _bw_sidebar_collapse_btn.text = "收\n起"
    _bw_sidebar_collapse_btn.visible = not _bw_sidebar_collapsed
    call_deferred("_position_bw_sidebar_collapse_button")

func _position_bw_sidebar_collapse_button() -> void :
    if _bw_sidebar_collapse_btn == null or not is_instance_valid(_bw_sidebar_collapse_btn):
        return
    var lp: = _bw_left_panel()
    if lp == null:
        return
    var r: = lp.get_global_rect()
    _bw_sidebar_collapse_btn.size = _bw_sidebar_collapse_btn.custom_minimum_size
    _bw_sidebar_collapse_btn.global_position = Vector2(
        r.position.x + r.size.x, 
        r.position.y + r.size.y - _bw_sidebar_collapse_btn.size.y - 24.0
    )

func _on_bw_sidebar_collapse_pressed() -> void :

    _set_bw_sidebar_collapsed(true, false)

func _set_bw_sidebar_collapsed(collapsed: bool, instant: bool) -> void :
    if collapsed == _bw_sidebar_collapsed:
        return
    var lp: = _bw_left_panel()
    if lp == null or left_content_margin == null:
        return
    _bw_sidebar_collapsed = collapsed


    if governance_scroll != null and not governance_scroll.visible:
        _update_event_portrait_layout()

        if not _is_mobile_portrait() and ( not is_instance_valid(event_portrait_layer) or not event_portrait_layer.visible):
            var cm: MarginContainer = $MainVBox / Layout / CenterPanel / CenterMargin
            if _is_native_mobile_landscape():
                cm.custom_minimum_size.x = _get_native_mobile_landscape_center_min_width()
            else:
                cm.custom_minimum_size.x = _desktop_center_min_width()
    if _bw_sidebar_tween != null and _bw_sidebar_tween.is_valid():
        _bw_sidebar_tween.kill()
    var pane: Control = left_content_margin.get_node_or_null("PaneStack")
    if _bw_sidebar_expanded_min_w <= 0.0:
        _bw_sidebar_expanded_min_w = lp.custom_minimum_size.x
    var lp_pad: = 0.0
    var lp_sb: = lp.get_theme_stylebox("panel")
    if lp_sb != null:
        lp_pad = lp_sb.get_margin(SIDE_LEFT) + lp_sb.get_margin(SIDE_RIGHT)
    var collapsed_w: = left_tabs_host.size.x + lp_pad
    if collapsed:

        _bw_sidebar_pane_frozen_w = maxf(0.0, left_content_margin.size.x - 12.0)
    var pane_w: = _bw_sidebar_pane_frozen_w


    left_content_margin.clip_contents = true
    if pane != null:
        pane.custom_minimum_size.x = pane_w
    var target_margin: = - (pane_w + 12.0) if collapsed else 12.0
    var target_min_w: = collapsed_w if collapsed else _bw_sidebar_expanded_min_w
    left_content_margin.visible = true
    if instant:
        left_content_margin.add_theme_constant_override("margin_left", int(target_margin))
        lp.custom_minimum_size.x = target_min_w
        _finish_bw_sidebar_anim()
        return
    var tw: = create_tween()
    tw.set_parallel(true)
    tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    var from_margin: = float(left_content_margin.get_theme_constant("margin_left"))
    var set_margin: = func(v: float) -> void :
        left_content_margin.add_theme_constant_override("margin_left", int(v))



        if not _bianwu_ap_floating and _action_points_portrait_active:
            _sync_action_points_card_alignment()
            call_deferred("_position_ap_portrait_overlay")
    tw.tween_method(set_margin, from_margin, target_margin, 0.28)
    tw.tween_property(lp, "custom_minimum_size:x", target_min_w, 0.28)
    tw.set_parallel(false)
    tw.tween_callback(_finish_bw_sidebar_anim)
    _bw_sidebar_tween = tw

func _finish_bw_sidebar_anim() -> void :
    var pane: Control = left_content_margin.get_node_or_null("PaneStack") if left_content_margin != null else null
    if _bw_sidebar_collapsed:
        left_content_margin.visible = false

        for tab in [zhisu_tab, buqu_tab, zengyi_tab, jushi_tab, dangan_tab, daoju_tab, lingwu_tab]:
            if tab != null and is_instance_valid(tab):
                _apply_tab_style(tab, false)
    else:
        left_content_margin.visible = true
        left_content_margin.clip_contents = false
        if pane != null:
            pane.custom_minimum_size.x = 0.0
        left_content_margin.add_theme_constant_override("margin_left", 12)

        _switch_left_tab(current_left_tab)
    if _bw_sidebar_collapse_btn != null and is_instance_valid(_bw_sidebar_collapse_btn):
        _bw_sidebar_collapse_btn.visible = not _bw_sidebar_collapsed and _sidebar_collapse_supported()
    call_deferred("_position_bw_sidebar_collapse_button")

    if _bianwu_ap_floating:
        _position_bianwu_ap_float()
    else:
        _sync_action_points_card_alignment_after_layout()



func _update_bw_juntian_diamond(cards: Array, blocked: bool) -> void :
    if _bw_juntian_diamond != null and is_instance_valid(_bw_juntian_diamond):
        _bw_juntian_diamond.queue_free()
    _bw_juntian_diamond = null
    if not _bianwu_ap_floating:
        return

    var btn: = Button.new()
    btn.name = "BwJuntianDiamond"
    btn.text = ""
    btn.disabled = blocked
    btn.tooltip_text = "军田：屯垦军田、清查粮饷军需诸务。"
    btn.custom_minimum_size = Vector2(88, 92)
    btn.size = btn.custom_minimum_size
    btn.visible = false
    for style_name in ["normal", "hover", "pressed", "disabled", "focus"]:
        btn.add_theme_stylebox_override(style_name, StyleBoxEmpty.new())




    var half: = 25.6
    var diamond_center: = Vector2(44.0, 38.0)

    var square_side: = (half * 2.0) / sqrt(2.0)
    var fill: = Color(0.075, 0.06, 0.045, 0.9)
    if btn.disabled:
        fill = Color(0.06, 0.05, 0.04, 0.55)
    var border_col: = Color(0.8, 0.62, 0.32, 0.42)
    if btn.disabled:
        border_col = Color(0.62, 0.54, 0.42, 0.25)
    var diamond: = Panel.new()
    diamond.mouse_filter = Control.MOUSE_FILTER_IGNORE
    diamond.size = Vector2(square_side, square_side)
    diamond.pivot_offset = Vector2(square_side, square_side) * 0.5
    diamond.position = diamond_center - Vector2(square_side, square_side) * 0.5
    diamond.rotation = deg_to_rad(45.0)
    var d_normal: = StyleBoxFlat.new()
    d_normal.bg_color = fill
    _apply_style_border_width(d_normal, 1)
    d_normal.border_color = border_col
    diamond.add_theme_stylebox_override("panel", d_normal)
    btn.add_child(diamond)
    if not btn.disabled:
        var d_hover: = d_normal.duplicate() as StyleBoxFlat
        d_hover.bg_color = Color(0.16, 0.1, 0.05, 0.92)
        d_hover.border_color = Color(0.8, 0.62, 0.32, 0.62)
        btn.mouse_entered.connect( func(): diamond.add_theme_stylebox_override("panel", d_hover))
        btn.mouse_exited.connect( func(): diamond.add_theme_stylebox_override("panel", d_normal))


    var icon: = StatusIconUtil.make_texture("liangcao", 24.0)
    if icon != null:
        icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
        icon.position = diamond_center - Vector2(12.0, 12.0)
        icon.modulate = Color(1.0, 0.92, 0.74, 0.94) if not blocked else Color(1.0, 0.92, 0.74, 0.45)
        btn.add_child(icon)

    var title: = Label.new()
    title.text = "军田"
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", 15)
    title.add_theme_color_override("font_color", Color(0.94, 0.88, 0.75) if not blocked else Color(0.86, 0.8, 0.68, 0.5))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.mouse_filter = Control.MOUSE_FILTER_IGNORE
    title.set_anchors_preset(Control.PRESET_TOP_WIDE)

    title.offset_top = 52.0
    title.offset_bottom = 70.0
    btn.add_child(title)

    btn.pressed.connect( func():
        bw_current_location = "juntian"
        _show_governance_overview(false)
    )
    _ensure_bw_ap_float_overlay().add_child(btn)
    _bw_juntian_diamond = btn

func _position_bw_juntian_diamond() -> void :
    if _bw_juntian_diamond == null or not is_instance_valid(_bw_juntian_diamond):
        return
    if not _bianwu_ap_floating or not is_instance_valid(action_points_row):
        return
    var row_rect: = action_points_row.get_global_rect()

    _bw_juntian_diamond.global_position = Vector2(
        row_rect.position.x + row_rect.size.x + 18.0, 
        row_rect.position.y + row_rect.size.y * 0.5 - 38.0
    )
    _bw_juntian_diamond.visible = true

func _clear_bianwu_story_banner() -> void :
    if bw_story_banner != null and is_instance_valid(bw_story_banner):
        bw_story_banner.queue_free()
    bw_story_banner = null


func _bianwu_find_location(tag: String) -> Dictionary:
    for loc in BW_LOCATIONS:
        if (loc.get("tags", []) as Array).has(tag):
            return loc
    return BW_LOCATIONS[0]

func _bianwu_location_card_indices(cards: Array, loc_id: String) -> Array:
    var indices: Array = []
    for idx in range(cards.size()):
        var card: Dictionary = cards[idx]
        if str(card.get("type", "")) in BW_BANNER_CARD_TYPES:
            continue
        var loc: Dictionary = _bianwu_find_location(str(card.get("tag", "")))
        if str(loc.get("id", "")) == loc_id:
            indices.append(idx)
    return indices

func _render_bianwu_location_layer(cards: Array, blocked: bool) -> void :


    month_cards_container.alignment = FlowContainer.ALIGNMENT_END if bw_current_location == "" else FlowContainer.ALIGNMENT_BEGIN
    _debug_dump_bw_layout_rects()
    _update_bianwu_story_banner(cards)
    _update_bw_juntian_diamond(cards, blocked)
    if bw_current_location == "":
        for loc in BW_LOCATIONS:

            if BW_TOP_LOCATION_IDS.has(str(loc.get("id", ""))):
                continue
            month_cards_container.add_child(_make_bianwu_location_card(loc, cards, blocked))
        return
    month_cards_container.add_child(_make_bianwu_back_bar())
    var indices: = _bianwu_location_card_indices(cards, bw_current_location)
    if indices.is_empty():
        month_cards_container.add_child(_make_bianwu_empty_card())
        return
    for idx in indices:
        month_cards_container.add_child(_make_bianwu_event_card_slot(cards, idx, blocked))


func _update_bianwu_story_banner(cards: Array) -> void :
    _clear_bianwu_story_banner()
    var banner_idx: = -1
    for idx in range(cards.size()):
        var card: Dictionary = cards[idx]
        if str(card.get("type", "")) in BW_BANNER_CARD_TYPES and not GameState.month_cards_done.has(idx):
            banner_idx = idx
            break
    if banner_idx < 0:
        return
    var card: Dictionary = cards[banner_idx]
    var banner: = Button.new()
    banner.text = ""
    banner.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    banner.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    banner.custom_minimum_size = Vector2(440, 62)
    banner.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW

    var normal: = StyleBoxFlat.new()
    normal.bg_color = Color(0.22, 0.165, 0.1, 0.94)
    normal.border_width_left = 1;normal.border_width_right = 1
    normal.border_width_top = 1;normal.border_width_bottom = 1
    normal.border_color = Color(0.8, 0.62, 0.32, 0.42)
    normal.corner_radius_top_left = 12;normal.corner_radius_top_right = 12
    normal.corner_radius_bottom_left = 12;normal.corner_radius_bottom_right = 12
    normal.content_margin_left = 16;normal.content_margin_right = 16
    normal.content_margin_top = 7;normal.content_margin_bottom = 7
    var hover: = normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color(0.27, 0.2, 0.13, 0.96)
    var pressed: = normal.duplicate() as StyleBoxFlat
    pressed.bg_color = Color(0.17, 0.125, 0.075, 0.96)
    banner.add_theme_stylebox_override("normal", normal)
    banner.add_theme_stylebox_override("hover", hover)
    banner.add_theme_stylebox_override("pressed", pressed)
    banner.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


    var outer_row: = HBoxContainer.new()
    outer_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
    outer_row.add_theme_constant_override("separation", 6)
    outer_row.set_anchors_preset(Control.PRESET_FULL_RECT)
    outer_row.offset_left = 16
    outer_row.offset_right = -16
    outer_row.offset_top = 6
    outer_row.offset_bottom = -6
    banner.add_child(outer_row)

    var box: = VBoxContainer.new()
    box.mouse_filter = Control.MOUSE_FILTER_IGNORE
    box.add_theme_constant_override("separation", 2)
    box.alignment = BoxContainer.ALIGNMENT_CENTER
    box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    box.size_flags_vertical = Control.SIZE_EXPAND_FILL
    outer_row.add_child(box)

    var row: = HBoxContainer.new()
    row.mouse_filter = Control.MOUSE_FILTER_IGNORE
    row.add_theme_constant_override("separation", 8)
    box.add_child(row)

    var tag_panel: = PanelContainer.new()
    tag_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    tag_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    var tag_style: = StyleBoxFlat.new()
    tag_style.bg_color = Color(0, 0, 0, 0)
    _apply_style_border_width(tag_style, 1)
    tag_style.border_color = Color(0.86, 0.72, 0.43, 0.62)
    tag_style.corner_radius_top_left = 4;tag_style.corner_radius_top_right = 4
    tag_style.corner_radius_bottom_left = 4;tag_style.corner_radius_bottom_right = 4
    tag_style.content_margin_left = 8;tag_style.content_margin_right = 8
    tag_style.content_margin_top = 1;tag_style.content_margin_bottom = 1
    tag_panel.add_theme_stylebox_override("panel", tag_style)
    row.add_child(tag_panel)

    var tag_label: = Label.new()
    tag_label.text = _get_month_card_tag_text(card)
    tag_label.add_theme_font_override("font", FontLoader.body())
    tag_label.add_theme_font_size_override("font_size", 12)
    tag_label.add_theme_color_override("font_color", Color(0.92, 0.78, 0.5))
    tag_panel.add_child(tag_label)

    var title: = Label.new()
    title.text = _get_month_card_title(card)
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", 17)
    title.add_theme_color_override("font_color", Color(0.94, 0.88, 0.75))
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title.clip_text = true
    title.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
    row.add_child(title)

    var summary: = Label.new()
    summary.text = _build_month_card_summary(card)
    summary.add_theme_font_override("font", FontLoader.body())
    summary.add_theme_font_size_override("font_size", 12)
    summary.add_theme_color_override("font_color", Color(0.8, 0.72, 0.6))
    summary.clip_text = true
    summary.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
    summary.max_lines_visible = 1
    summary.visible = summary.text != ""
    box.add_child(summary)

    var arrow: = Label.new()
    arrow.text = "〉"
    arrow.add_theme_font_override("font", FontLoader.body())
    arrow.add_theme_font_size_override("font_size", 18)
    arrow.add_theme_color_override("font_color", Color(0.8, 0.72, 0.6, 0.65))
    arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
    arrow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    arrow.custom_minimum_size = Vector2(16, 0)
    outer_row.add_child(arrow)

    banner.pressed.connect(_on_bianwu_story_banner_pressed.bind(banner_idx))

    banner.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    governance_vbox.add_child(banner)
    governance_vbox.move_child(banner, month_cards_container.get_index())
    bw_story_banner = banner


func _make_bianwu_location_card(loc: Dictionary, cards: Array, blocked: bool) -> Control:


    var side: = roundf(_get_month_card_size().x * _bianwu_card_scale())
    var card_size: = Vector2(side, side)
    var loc_id: = str(loc.get("id", ""))
    var pending: = 0
    for idx in _bianwu_location_card_indices(cards, loc_id):
        if not GameState.month_cards_done.has(idx):
            pending += 1
    var style_card: = {"type": "governance", "tag": str(loc.get("title", ""))}

    var slot: = Control.new()
    slot.custom_minimum_size = card_size
    slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    slot.clip_contents = (GameState.theme != "light")

    var btn: = Button.new()
    btn.mouse_filter = Control.MOUSE_FILTER_PASS
    btn.gui_input.connect(_on_governance_scroll_touch_drag)
    btn.text = ""
    btn.set_anchors_preset(Control.PRESET_FULL_RECT)
    btn.custom_minimum_size = card_size
    btn.disabled = blocked
    btn.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
    btn.add_theme_stylebox_override("normal", _make_landscape_card_style(style_card, blocked, false))
    btn.add_theme_stylebox_override("hover", _make_landscape_card_style(style_card, blocked, true))
    btn.add_theme_stylebox_override("pressed", _make_landscape_card_style(style_card, blocked, true))
    btn.add_theme_stylebox_override("disabled", _make_landscape_card_style(style_card, blocked, false))
    _add_landscape_card_gradient_layer(btn, style_card, blocked, false)

    var title_col: = Color(0.94, 0.88, 0.75) if not blocked else Color(0.86, 0.8, 0.68, 0.5)
    var summary_col: = Color(0.8, 0.72, 0.6) if not blocked else Color(0.66, 0.6, 0.5, 0.5)

    var root: = MarginContainer.new()
    root.set_anchors_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_theme_constant_override("margin_left", _bianwu_card_scaled(18))
    root.add_theme_constant_override("margin_right", _bianwu_card_scaled(18))
    root.add_theme_constant_override("margin_top", _bianwu_card_scaled(18))
    root.add_theme_constant_override("margin_bottom", _bianwu_card_scaled(18))
    btn.add_child(root)

    var col: = VBoxContainer.new()
    col.mouse_filter = Control.MOUSE_FILTER_IGNORE
    col.add_theme_constant_override("separation", _bianwu_card_scaled(7))
    root.add_child(col)

    var tag_panel: = PanelContainer.new()
    tag_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    tag_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    var tag_style: = StyleBoxFlat.new()
    tag_style.bg_color = Color(0, 0, 0, 0)
    _apply_style_border_width(tag_style, 1)
    tag_style.border_color = Color(0.78, 0.66, 0.44, 0.62 if not blocked else 0.3)
    tag_style.corner_radius_top_left = 4;tag_style.corner_radius_top_right = 4
    tag_style.corner_radius_bottom_left = 4;tag_style.corner_radius_bottom_right = 4
    tag_style.content_margin_left = _bianwu_card_scaled(8);tag_style.content_margin_right = _bianwu_card_scaled(8)
    tag_style.content_margin_top = _bianwu_card_scaled(3);tag_style.content_margin_bottom = _bianwu_card_scaled(3)
    tag_panel.add_theme_stylebox_override("panel", tag_style)
    col.add_child(tag_panel)

    var tag_label: = Label.new()
    tag_label.text = "地点"
    tag_label.add_theme_font_override("font", FontLoader.body())
    tag_label.add_theme_font_size_override("font_size", _bianwu_card_scaled(12))
    tag_label.add_theme_color_override("font_color", Color(0.88, 0.78, 0.55) if not blocked else Color(0.78, 0.7, 0.56, 0.5))
    tag_panel.add_child(tag_label)

    var title: = Label.new()
    title.text = str(loc.get("title", ""))
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", _bianwu_card_scaled(22))
    title.add_theme_color_override("font_color", title_col)
    col.add_child(title)

    var summary: = Label.new()
    summary.text = str(loc.get("desc", ""))
    summary.add_theme_font_override("font", FontLoader.body())
    summary.add_theme_font_size_override("font_size", _bianwu_card_scaled(13))
    summary.add_theme_color_override("font_color", summary_col)
    summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    summary.max_lines_visible = 3
    summary.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
    col.add_child(summary)

    var spacer: = Control.new()
    spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    col.add_child(spacer)

    var divider: = Control.new()
    divider.custom_minimum_size = Vector2(0, 1)
    divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var divider_col: = Color(0.8, 0.66, 0.42, 0.42) if not blocked else Color(0.62, 0.54, 0.42, 0.15)
    divider.draw.connect( func():
        divider.draw_line(Vector2(0.0, 0.5), Vector2(divider.size.x, 0.5), divider_col, 1.0)
    )
    col.add_child(divider)

    var status_label: = Label.new()
    if blocked:
        status_label.text = "需先处置本月大事"
    elif pending > 0:
        status_label.text = "事务 " + str(pending) + " 件"
    else:
        status_label.text = "本月无事"
    status_label.add_theme_font_override("font", FontLoader.body())
    status_label.add_theme_font_size_override("font_size", _bianwu_card_scaled(11))
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.add_theme_color_override("font_color", summary_col)
    col.add_child(status_label)

    btn.pressed.connect( func():
        bw_current_location = loc_id
        _show_governance_overview(false)
    )
    slot.add_child(btn)
    return slot


func _make_bianwu_back_bar() -> Control:
    var card_size: = _get_bianwu_month_card_size()
    var bar_width: = float(_bianwu_card_scaled(40))
    var slot: = Control.new()
    slot.custom_minimum_size = Vector2(bar_width, card_size.y)
    slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER

    var btn: = Button.new()
    btn.text = ""
    btn.set_anchors_preset(Control.PRESET_FULL_RECT)
    btn.custom_minimum_size = Vector2(bar_width, card_size.y)

    var normal: = StyleBoxFlat.new()
    normal.bg_color = Color(0.055, 0.047, 0.038, 0.96)
    normal.corner_radius_top_left = 0;normal.corner_radius_top_right = 0
    normal.corner_radius_bottom_left = 0;normal.corner_radius_bottom_right = 0
    var hover: = normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color(0.16, 0.1, 0.05, 0.96)
    var pressed: = normal.duplicate() as StyleBoxFlat
    pressed.bg_color = Color(0.1, 0.07, 0.035, 0.96)
    btn.add_theme_stylebox_override("normal", normal)
    btn.add_theme_stylebox_override("hover", hover)
    btn.add_theme_stylebox_override("pressed", pressed)
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

    var icon: = Control.new()
    icon.set_anchors_preset(Control.PRESET_FULL_RECT)
    icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
    icon.draw.connect( func():
        var c: = icon.size * 0.5
        var w: = 9.0
        var line_w: = 3.0
        var col: = Color(0.88, 0.78, 0.55, 0.92)
        var pts: = PackedVector2Array([
            Vector2(c.x + w * 0.5, c.y - w), 
            Vector2(c.x - w * 0.5, c.y), 
            Vector2(c.x + w * 0.5, c.y + w), 
        ])
        icon.draw_polyline(pts, col, line_w, true)

        for p in pts:
            icon.draw_circle(p, line_w * 0.5, col)
    )
    btn.add_child(icon)

    btn.pressed.connect( func():
        bw_current_location = ""
        _show_governance_overview(false)
    )
    slot.add_child(btn)
    return slot


func _make_bianwu_empty_card() -> Control:
    var card_size: = _get_bianwu_month_card_size()
    var slot: = Control.new()
    slot.custom_minimum_size = card_size
    slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER

    var panel: = PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_FULL_RECT)
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0.09, 0.075, 0.06, 0.55) if GameState.theme != "light" else Color(0.93, 0.9, 0.83, 0.6)
    _apply_style_border_width(style, 1)
    style.border_color = Color(0.62, 0.54, 0.42, 0.25)
    style.corner_radius_top_left = 4;style.corner_radius_top_right = 4
    style.corner_radius_bottom_left = 4;style.corner_radius_bottom_right = 4
    panel.add_theme_stylebox_override("panel", style)

    var label: = Label.new()
    label.text = "暂无情况"
    label.add_theme_font_override("font", FontLoader.body())
    label.add_theme_font_size_override("font_size", _bianwu_card_scaled(15))
    label.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    panel.add_child(label)

    slot.add_child(panel)
    return slot


func _make_bianwu_event_card_slot(cards: Array, idx: int, blocked: bool) -> Control:
    var card: Dictionary = cards[idx]

    var card_size: = _get_bianwu_month_card_size()
    var lock_reason: = ""
    var disabled: bool = GameState.month_cards_done.has(idx) or GameState.action_points <= 0 or blocked or not _can_afford_card(idx)
    if GameState.month_cards_done.has(idx):
        lock_reason = "已处理"
    elif GameState.action_points <= 0:
        lock_reason = "行动力不足"
    elif blocked:
        lock_reason = "需先处置本月大事"
    elif not _can_afford_card(idx):
        lock_reason = "资源不足"

    var card_slot: = Control.new()
    card_slot.custom_minimum_size = card_size
    card_slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    card_slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    card_slot.clip_contents = (GameState.theme != "light")

    var card_button: = Button.new()
    card_button.mouse_filter = Control.MOUSE_FILTER_PASS
    card_button.gui_input.connect(_on_governance_scroll_touch_drag)
    card_button.text = ""
    card_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
    card_button.set_anchors_preset(Control.PRESET_FULL_RECT)
    card_button.custom_minimum_size = card_size
    card_button.disabled = disabled
    card_button.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
    _build_landscape_month_card(card_button, card, disabled, idx, lock_reason, card_size)
    card_button.pressed.connect(_on_month_card_pressed.bind(idx))
    card_slot.add_child(card_button)
    card_slot.set_meta("month_card", card)
    card_slot.set_meta("disabled", disabled)
    card_slot.set_meta("lock_reason", lock_reason)
    _play_pending_month_card_settle(idx, card_button)
    return card_slot

func _mark_month_card_for_settle(card_index: int) -> void :
    pending_month_card_settle_index = card_index

func _play_pending_month_card_settle(card_index: int, card_button: Control) -> void :
    if card_index != pending_month_card_settle_index:
        return
    if not GameState.month_cards_done.has(card_index):
        return
    pending_month_card_settle_index = -1
    CardAnimations.play_month_card_disabled_settle(card_button)

func _schedule_month_advance_after_settle() -> void :
    if GameState.action_points > 0:
        return
    if pending_month_advance_after_settle:
        return
    pending_month_advance_after_settle = true
    call_deferred("_advance_month_after_settle")

func _advance_month_after_settle() -> void :
    await get_tree().create_timer(0.46).timeout
    pending_month_advance_after_settle = false
    if not GameState.is_governance_mode():
        return
    if governance_active_card_index >= 0:
        return
    if GameState.action_points > 0:
        return
    EventServiceRef.advance_month(GameState)
    _show_governance_overview(true)

func _get_month_card_tag_text(card: Dictionary) -> String:
    return _month_card_display.get_tag_text(card)

func _is_governance_card_upgraded(card: Dictionary) -> bool:
    var card_id: = str(card.get("id", ""))
    if card_id == "":
        var gov_idx: int = int(card.get("idx", -1))
        if gov_idx >= 0 and gov_idx < GameData.GOVERNANCE_CARDS.size():
            card_id = str(GameData.GOVERNANCE_CARDS[gov_idx].get("id", ""))
    return card_id != "" and GameState.upgraded_governance_cards.has(card_id)

func _apply_shell_grain_layers() -> void :
    _attach_grain_texture_layer(top_bar, "TopBarGrainLayer", _topbar_grain_alpha())
    _attach_grain_texture_layer(left_panel, "LeftPanelGrainLayer", _left_panel_grain_alpha())

func _attach_grain_texture_layer(parent: Control, layer_name: String, alpha: float, child_index: int = 0) -> TextureRect:
    if parent is PanelContainer:
        var old_layer: = parent.get_node_or_null(layer_name) as TextureRect
        if old_layer != null:
            old_layer.queue_free()
        parent.set_meta(layer_name + "_alpha", alpha)
        parent.set_meta(layer_name + "_texture", _get_city_panel_grain_texture())
        if not parent.has_meta(layer_name + "_draw_connected"):
            parent.draw.connect( func():
                var tex: = parent.get_meta(layer_name + "_texture", null) as Texture2D
                if tex == null:
                    return
                var draw_alpha: = float(parent.get_meta(layer_name + "_alpha", 0.0))
                parent.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
                parent.draw_texture_rect(tex, Rect2(Vector2.ZERO, parent.size), true, Color(1, 1, 1, draw_alpha))
            )
            parent.set_meta(layer_name + "_draw_connected", true)
        parent.queue_redraw()
        return null

    var layer: = parent.get_node_or_null(layer_name) as TextureRect
    if layer == null:
        layer = TextureRect.new()
        layer.name = layer_name
        layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        layer.set_anchors_preset(Control.PRESET_FULL_RECT)
        layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        layer.stretch_mode = TextureRect.STRETCH_TILE
        layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        parent.add_child(layer)
    parent.move_child(layer, clampi(child_index, 0, parent.get_child_count() - 1))
    layer.texture = _get_city_panel_grain_texture()
    layer.modulate = Color(1, 1, 1, alpha)
    return layer

func _city_panel_grain_alpha() -> float:
    return 0.72 if GameState.theme == "dark" else 0.44

func _month_card_grain_alpha(disabled: bool) -> float:
    if disabled:
        return 0.28 if GameState.theme == "dark" else 0.26

    return 0.42 if GameState.theme == "dark" else 0.4

func _topbar_grain_alpha() -> float:
    return 0.22 if GameState.theme == "dark" else 0.16

func _left_panel_grain_alpha() -> float:
    return 0.3 if GameState.theme == "dark" else 0.22

func _get_city_panel_grain_texture() -> Texture2D:
    if city_panel_grain_texture != null:
        return city_panel_grain_texture
    city_panel_grain_texture = GrainTexture.build_city_panel_texture()
    return city_panel_grain_texture

func _play_event_content_enter_animation() -> void :
    var controls: Array[Control] = [
        event_date_label, 
        event_title_label, 
        _get_speaker_box_control(), 
        narrative_label, 
        focus_panel, 
        choices_container
    ]
    var delay: = 0.0
    for control in controls:
        if control == null or not control.visible:
            continue
        CardAnimations.play_control_enter(control, delay, 14.0)
        delay += 0.045

func _play_result_enter_animation(effects: Dictionary) -> void :
    CardAnimations.play_control_enter(result_panel, 0.0, 18.0)
    CardAnimations.play_control_enter(chosen_choice_box, 0.06, 12.0)
    CardAnimations.play_control_enter(result_changes_container, 0.12, 10.0)
    CardAnimations.play_result_change_number(result_changes_container)
    if not effects.is_empty():
        CardAnimations.play_city_level_change_pulses(result_changes_container)


func _month_card_slot_for_index(card_index: int) -> Control:
    for child in month_cards_container.get_children():
        if child is Control and int(child.get_meta("month_card_index", -1)) == card_index:
            return child
    return null

func _on_month_card_pressed(card_index: int) -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(self, "governance_scroll_touch_drag_suppress_until_ms"):
        return
    var slot: = _month_card_slot_for_index(card_index)
    if slot != null and bool(slot.get_meta("disabled", false)):
        return
    if slot != null and bool(slot.get_meta("press_animating", false)):
        return
    if slot != null:
        await CardAnimations.play_month_card_press(slot)

    var card: Dictionary = slot.get_meta("month_card", {}) if slot != null else {}
    if str(card.get("type", "")) == "bw_assault":
        _show_bianwu_assault_muster(str(card.get("bw_region", "")), _bw_defense_detail_layer)
        return
    _execute_month_card(card_index)

func _on_month_card_selected(card_index: int) -> void :
    _on_month_card_pressed(card_index)

func _on_bianwu_story_banner_pressed(card_index: int) -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(self, "governance_scroll_touch_drag_suppress_until_ms"):
        return
    _execute_month_card(card_index)

func _select_mobile_month_card(card_index: int) -> void :
    var slot: = _month_card_slot_for_index(card_index)
    if slot == null:
        return
    selected_mobile_month_card_index = card_index
    var card: Dictionary = slot.get_meta("month_card", {})
    var disabled: = bool(slot.get_meta("disabled", false))
    var lock_reason: = str(slot.get_meta("lock_reason", ""))
    _show_mobile_month_card_preview(card, disabled, lock_reason)
    if mobile_month_execute_button != null and is_instance_valid(mobile_month_execute_button):
        mobile_month_execute_button.disabled = disabled
        mobile_month_execute_button.text = "执行"

func _show_mobile_month_card_preview(card: Dictionary, disabled: bool, lock_reason: String) -> void :
    _clear_mobile_month_card_preview()
    if not _is_mobile_portrait() or card.is_empty():
        return
    mobile_month_card_preview_panel = _create_mobile_month_card_preview(card, disabled, lock_reason)
    governance_vbox.add_child(mobile_month_card_preview_panel)
    governance_vbox.move_child(mobile_month_card_preview_panel, month_cards_container.get_index())

func _clear_mobile_month_card_preview() -> void :
    if mobile_month_card_preview_panel != null and is_instance_valid(mobile_month_card_preview_panel):
        mobile_month_card_preview_panel.queue_free()
    mobile_month_card_preview_panel = null

func _create_mobile_month_card_preview(card: Dictionary, disabled: bool, lock_reason: String) -> PanelContainer:
    var panel: = PanelContainer.new()
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var style: = StyleBoxFlat.new()
    style.bg_color = Color(0.95, 0.92, 0.84, 0.96) if GameState.theme == "light" else Color(0.11, 0.075, 0.052, 0.96)
    style.border_width_left = 1;style.border_width_right = 1
    style.border_width_top = 1;style.border_width_bottom = 1
    style.border_color = Color(0.72, 0.6, 0.34, 0.22)
    style.corner_radius_top_left = 2;style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2;style.corner_radius_bottom_right = 2
    style.content_margin_left = 30;style.content_margin_right = 30
    style.content_margin_top = 22;style.content_margin_bottom = 22
    panel.add_theme_stylebox_override("panel", style)

    var box: = VBoxContainer.new()
    box.add_theme_constant_override("separation", 12)
    panel.add_child(box)

    var title: = Label.new()
    title.text = "%s  %s" % [_get_month_card_tag_text(card), _get_month_card_title(card)]
    title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    title.add_theme_font_size_override("font_size", 30)
    title.add_theme_color_override("font_color", _month_card_text_color(disabled, true))
    box.add_child(title)

    var summary: = Label.new()
    summary.text = _build_month_card_summary(card)
    if summary.text == "":
        summary.text = "点击执行后处置本月行动。"
    summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    summary.add_theme_font_size_override("font_size", 25)
    summary.add_theme_color_override("font_color", _month_card_text_color(disabled, false))
    box.add_child(summary)

    var note_text: = _get_month_card_note_text(card)
    if note_text != "":
        var note: = Label.new()
        note.text = note_text
        note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        note.add_theme_font_size_override("font_size", 22)
        var note_color: = _month_card_text_color(disabled, false)
        note_color.a *= 0.66
        note.add_theme_color_override("font_color", note_color)
        box.add_child(note)

    if disabled and lock_reason != "":
        var lock: = Label.new()
        lock.text = lock_reason
        lock.add_theme_font_size_override("font_size", 24)
        lock.add_theme_color_override("font_color", Color(0.76, 0.32, 0.24, 0.9))
        box.add_child(lock)

    return panel

func _configure_mobile_month_execute_button() -> void :
    _ensure_desktop_action_points_left_spacer()
    if mobile_month_execute_spacer == null or not is_instance_valid(mobile_month_execute_spacer):
        mobile_month_execute_spacer = Control.new()
        mobile_month_execute_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        action_points_row.add_child(mobile_month_execute_spacer)
    if mobile_month_execute_button == null or not is_instance_valid(mobile_month_execute_button):
        mobile_month_execute_button = Button.new()
        mobile_month_execute_button.text = "执行"
        mobile_month_execute_button.size_flags_horizontal = Control.SIZE_SHRINK_END
        mobile_month_execute_button.custom_minimum_size = Vector2(200, 72)
        GameScreenStyleFactory.apply_command_button_style(mobile_month_execute_button, "primary", 18, 8)
        mobile_month_execute_button.pressed.connect( func(): _execute_selected_mobile_month_card())
        action_points_row.add_child(mobile_month_execute_button)
    mobile_month_execute_spacer.visible = false
    mobile_month_execute_button.visible = false
    mobile_month_execute_button.disabled = selected_mobile_month_card_index < 0
    mobile_month_execute_button.add_theme_font_size_override("font_size", 32)

func _ensure_desktop_action_points_left_spacer() -> void :
    if desktop_action_points_left_spacer != null and is_instance_valid(desktop_action_points_left_spacer):
        return
    desktop_action_points_left_spacer = Control.new()
    desktop_action_points_left_spacer.name = "DesktopActionPointsLeftSpacer"
    desktop_action_points_left_spacer.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    var insert_idx: = action_points_value.get_index() if is_instance_valid(action_points_value) else 0
    action_points_row.add_child(desktop_action_points_left_spacer)
    action_points_row.move_child(desktop_action_points_left_spacer, insert_idx)

func _reposition_governance_action_points_row() -> void :

    if _bianwu_ap_floating:
        return
    _ensure_desktop_action_points_left_spacer()
    var m_idx = month_cards_container.get_index()
    var a_idx = action_points_row.get_index()
    if _is_mobile_portrait():
        if a_idx > m_idx:
            governance_vbox.move_child(action_points_row, m_idx)
        elif a_idx < m_idx - 1:
            governance_vbox.move_child(action_points_row, m_idx - 1)
        action_points_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        action_points_row.alignment = BoxContainer.ALIGNMENT_BEGIN
        desktop_action_points_left_spacer.visible = false
        desktop_action_points_left_spacer.custom_minimum_size.x = 0
    else:
        if a_idx > m_idx:
            governance_vbox.move_child(action_points_row, m_idx)
        elif a_idx < m_idx - 1:
            governance_vbox.move_child(action_points_row, m_idx - 1)
        action_points_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        action_points_row.alignment = BoxContainer.ALIGNMENT_BEGIN
        desktop_action_points_left_spacer.visible = true
        _sync_action_points_card_alignment()

func _sync_action_points_card_alignment() -> void :
    if _bianwu_ap_floating:
        return
    if not is_instance_valid(action_points_row) or not is_instance_valid(month_cards_container):
        return
    _ensure_desktop_action_points_left_spacer()
    if _is_mobile_portrait():
        desktop_action_points_left_spacer.visible = false
        desktop_action_points_left_spacer.custom_minimum_size.x = 0
        return


    var ap_shift: = _ap_hex_right if _action_points_portrait_active else 0.0
    var card_count: = month_cards_container.get_child_count()
    var row_gap: = float(action_points_row.get_theme_constant("separation"))
    if card_count > 0:
        var first_card: = month_cards_container.get_child(0) as Control
        if first_card != null and first_card.size.x > 0.0:
            var measured_left_inset: = first_card.global_position.x - action_points_row.global_position.x - row_gap
            desktop_action_points_left_spacer.visible = true
            desktop_action_points_left_spacer.custom_minimum_size.x = maxf(0.0, measured_left_inset) + ap_shift
            return
    if card_count <= 0:
        card_count = 5
    var card_w: = _get_month_card_size().x
    var gap: = float(month_cards_container.get_theme_constant("h_separation"))
    if gap <= 0.0:
        gap = 12.0
    var total_cards_w: = card_w * float(card_count) + gap * float(maxi(0, card_count - 1))
    var available_w: = month_cards_container.size.x
    if available_w <= 1.0:
        available_w = governance_vbox.size.x
    var left_inset: = maxf(0.0, (available_w - total_cards_w) * 0.5)
    desktop_action_points_left_spacer.visible = true
    desktop_action_points_left_spacer.custom_minimum_size.x = left_inset + ap_shift

func _sync_action_points_card_alignment_after_layout() -> void :
    await get_tree().process_frame
    _position_bw_sidebar_collapse_button()
    if _bianwu_ap_floating:
        _position_bianwu_ap_float()
        return
    _sync_action_points_card_alignment()
    await get_tree().process_frame
    _position_ap_portrait_overlay()

func _execute_selected_mobile_month_card() -> void :
    if selected_mobile_month_card_index < 0:
        return
    _execute_month_card(selected_mobile_month_card_index)

func _execute_month_card(card_index: int) -> void :
    print("[Debug] _execute_month_card index: ", card_index)
    var debug_cards: = GameState.month_cards
    print("[Debug] current cards size: ", debug_cards.size())
    for i in range(debug_cards.size()):
        var c = debug_cards[i]
        print("  - [", i, "] type: ", c.get("type", ""), ", id: ", c.get("id", ""), ", title: ", c.get("title", ""))
    var payload: Dictionary = EventServiceRef.execute_month_card(GameState, card_index)
    if payload.is_empty():
        print("[Debug] execute_month_card payload is empty!")
        return

    governance_active_card_index = card_index
    var card_type: = str(payload.get("card", {}).get("type", ""))
    if _is_direct_month_action_card(card_type):
        var choices: Array = payload.get("event", {}).get("choices", [])
        if choices.size() == 1:
            var card_dict: Dictionary = payload.get("card", {})
            var card_id: = str(card_dict.get("id", ""))
            if GameState.active_line == "bianwu" and GameData.BW_MICRO_EVENTS.has(card_id):
                _resolve_choice_with_bw_micro_popup(choices[0], card_id, card_dict)
                return
            _resolve_choice_as_toast(choices[0])
            return
    _show_current_event()

func _is_direct_month_action_card(card_type: String) -> bool:
    return card_type in ["governance", "trade", "home", "field"]

func _resolve_choice_as_toast(ch: Dictionary) -> void :
    var old_rank = GameState.rank_index
    var choice_result = EffectsServiceRef.apply_choice(GameState, ch, 0)

    EventServiceRef.finalize_month_card_choice(GameState, governance_active_card_index, ch)
    var effects = choice_result.get("effects", {})



    var ekey = choice_result.get("ending_key", "")
    if ekey != "":
        var ending = GameData.endings.get(ekey, {})
        if not ending.is_empty():
            game_ended.emit(ending)
            return

    _mark_month_card_for_settle(governance_active_card_index)
    GameState.complete_month_card(governance_active_card_index, false)
    governance_active_card_index = -1
    _show_governance_overview(false)
    _schedule_month_advance_after_settle()

    if GameState.rank_index != old_rank:
        _show_rank_up_toast(GameState.get_rank_title())

    if not effects.is_empty():
        _show_effects_toast(effects)

func _show_effects_toast(effects: Dictionary) -> void :
    _transition_toast_controller.show_effects_toast(effects)



func _bw_micro_entry_in_season(entry: Variant) -> bool:
    if typeof(entry) != TYPE_DICTIONARY:
        return true
    var months: Array = entry.get("months", [])
    if months.is_empty():
        return true
    return int(GameState.month) in months

func _bw_micro_entry_text(entry: Variant) -> String:
    if typeof(entry) == TYPE_DICTIONARY:
        return str(entry.get("text", ""))
    return str(entry)

func _pick_bw_micro_event(card_id: String) -> String:
    var pool: Array = GameData.BW_MICRO_EVENTS.get(card_id, [])
    if pool.is_empty():
        return ""
    var in_season: Array[int] = []
    for i in range(pool.size()):
        if _bw_micro_entry_in_season(pool[i]):
            in_season.append(i)
    if in_season.is_empty():

        for i in range(pool.size()):
            in_season.append(i)
    var cooldown: Array = GameState.bw_micro_event_cooldown.get(card_id, [])
    var available: Array[int] = []
    for i in in_season:
        if i not in cooldown:
            available.append(i)
    if available.is_empty():
        cooldown.clear()
        available = in_season.duplicate()
    var picked: int = available[randi() % available.size()]
    cooldown.append(picked)
    var max_cooldown: = maxi(in_season.size() / 2, 5)
    while cooldown.size() > max_cooldown:
        cooldown.pop_front()
    GameState.bw_micro_event_cooldown[card_id] = cooldown
    return _bw_micro_entry_text(pool[picked])

func _resolve_choice_with_bw_micro_popup(ch: Dictionary, card_id: String, card_dict: Dictionary) -> void :
    var old_rank = GameState.rank_index
    var choice_result = EffectsServiceRef.apply_choice(GameState, ch, 0)
    EventServiceRef.finalize_month_card_choice(GameState, governance_active_card_index, ch)
    var effects: Dictionary = choice_result.get("effects", {})


    var ekey = choice_result.get("ending_key", "")
    if ekey != "":
        var ending = GameData.endings.get(ekey, {})
        if not ending.is_empty():
            game_ended.emit(ending)
            return
    var micro_text: = _pick_bw_micro_event(card_id)
    var card_title: = str(card_dict.get("title", ""))
    _show_bw_micro_popup(card_title, micro_text, effects, old_rank)

func _close_bw_micro_popup() -> void :
    if bw_micro_popup_layer != null and is_instance_valid(bw_micro_popup_layer):
        bw_micro_popup_layer.queue_free()
    bw_micro_popup_layer = null

func _show_bw_micro_popup(card_title: String, micro_text: String, effects: Dictionary, old_rank: int) -> void :
    _close_bw_micro_popup()
    var is_mobile: = _is_mobile_portrait()
    var viewport_size: = get_viewport_rect().size

    var popup_width: = (minf(520.0, maxf(300.0, viewport_size.x - 48.0))) if is_mobile else 400.0
    var popup_height: = minf(420.0, maxf(260.0, viewport_size.y - 80.0)) if is_mobile else 300.0

    bw_micro_popup_layer = CanvasLayer.new()
    bw_micro_popup_layer.name = "BwMicroPopupLayer"
    bw_micro_popup_layer.layer = 115
    bw_micro_popup_layer.add_to_group("blocking_modal_overlay")
    get_tree().root.add_child(bw_micro_popup_layer)

    var dim: = ColorRect.new()
    dim.color = Color(0, 0, 0, 0.58)
    dim.set_anchors_preset(Control.PRESET_FULL_RECT)
    dim.mouse_filter = Control.MOUSE_FILTER_STOP
    bw_micro_popup_layer.add_child(dim)

    var panel: = PanelContainer.new()
    panel.custom_minimum_size = Vector2(popup_width, 0)
    var panel_style: = StyleBoxFlat.new()
    panel_style.bg_color = Color(0.95, 0.92, 0.84, 0.97) if GameState.theme == "light" else Color(0.075, 0.06, 0.04, 0.97)
    panel_style.border_width_left = 1;panel_style.border_width_right = 1
    panel_style.border_width_top = 1;panel_style.border_width_bottom = 1

    panel_style.border_color = Color(0.72, 0.6, 0.36, 0.45)
    panel_style.corner_radius_top_left = 6;panel_style.corner_radius_top_right = 6
    panel_style.corner_radius_bottom_left = 6;panel_style.corner_radius_bottom_right = 6
    if is_mobile:
        panel_style.content_margin_left = 28;panel_style.content_margin_right = 28
        panel_style.content_margin_top = 24;panel_style.content_margin_bottom = 24
    else:
        panel_style.content_margin_left = 30;panel_style.content_margin_right = 30
        panel_style.content_margin_top = 24;panel_style.content_margin_bottom = 22
    panel_style.shadow_color = Color(0, 0, 0, 0.38)
    panel_style.shadow_size = 14 if not is_mobile else 8
    panel.add_theme_stylebox_override("panel", panel_style)
    panel.set_anchors_preset(Control.PRESET_CENTER)
    var half_w: = popup_width / 2.0
    panel.offset_left = - half_w
    panel.offset_right = half_w
    panel.offset_top = - popup_height / 2.0
    panel.offset_bottom = popup_height / 2.0
    panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    bw_micro_popup_layer.add_child(panel)

    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 16 if is_mobile else 14)
    panel.add_child(vbox)

    var title_label: = Label.new()
    title_label.text = card_title
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.add_theme_font_size_override("font_size", 28 if is_mobile else 19)
    title_label.add_theme_color_override("font_color", GameState.get_theme_color("text_title"))
    title_label.add_theme_font_override("font", FontLoader.serif_bold())
    vbox.add_child(title_label)


    var ornament: = Control.new()
    ornament.custom_minimum_size = Vector2(0, 1)
    ornament.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    ornament.draw.connect( func():
        var w: float = ornament.size.x
        var line_w: = minf(64.0, w)
        var x0: = (w - line_w) * 0.5
        ornament.draw_line(Vector2(x0, 0.5), Vector2(x0 + line_w, 0.5), Color(0.8, 0.62, 0.32, 0.55), 1.0)
    )
    vbox.add_child(ornament)

    if micro_text != "":
        var text_label: = Label.new()
        text_label.text = micro_text
        text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        text_label.add_theme_font_size_override("font_size", 24 if is_mobile else 15)
        text_label.add_theme_constant_override("line_spacing", 8 if is_mobile else 6)
        text_label.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
        vbox.add_child(text_label)

    if not effects.is_empty():
        var sep: = HSeparator.new()
        sep.add_theme_stylebox_override("separator", StyleBoxFlat.new())
        var sep_style: = sep.get_theme_stylebox("separator") as StyleBoxFlat
        sep_style.bg_color = Color(0.72, 0.6, 0.36, 0.2)
        sep_style.content_margin_top = 1;sep_style.content_margin_bottom = 1
        vbox.add_child(sep)

        var effects_box: = HFlowContainer.new()
        effects_box.alignment = FlowContainer.ALIGNMENT_CENTER
        effects_box.add_theme_constant_override("h_separation", 16 if is_mobile else 14)
        effects_box.add_theme_constant_override("v_separation", 6)
        for key in effects.keys():
            var val: int = int(effects[key])
            if val == 0:
                continue
            var lbl: = Label.new()


            lbl.text = Presenter.format_effect_delta_text(str(key), val)
            lbl.add_theme_font_override("font", FontLoader.serif_bold())
            lbl.add_theme_font_size_override("font_size", 22 if is_mobile else 14)
            lbl.add_theme_color_override("font_color", _get_effect_delta_color(key, val))
            effects_box.add_child(lbl)
        vbox.add_child(effects_box)

    var spacer: = Control.new()
    spacer.custom_minimum_size = Vector2(0, 4 if is_mobile else 2)
    vbox.add_child(spacer)

    var btn_row: = HBoxContainer.new()
    btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
    vbox.add_child(btn_row)

    var confirm_btn: = Button.new()
    confirm_btn.text = "确认"
    confirm_btn.custom_minimum_size = Vector2(140, 48) if is_mobile else Vector2(108, 34)
    confirm_btn.add_theme_font_size_override("font_size", 24 if is_mobile else 15)
    GameScreenStyleFactory.apply_command_button_style(confirm_btn, "primary", 18 if is_mobile else 14, 8 if is_mobile else 6)
    confirm_btn.pressed.connect( func():
        _close_bw_micro_popup()
        _mark_month_card_for_settle(governance_active_card_index)
        GameState.complete_month_card(governance_active_card_index, false)
        governance_active_card_index = -1
        _show_governance_overview(false)
        _schedule_month_advance_after_settle()
        if GameState.rank_index != old_rank:
            _show_rank_up_toast(GameState.get_rank_title())
    )
    btn_row.add_child(confirm_btn)

func _get_effect_delta_color(key: String, value: int) -> Color:
    if Presenter.is_effect_positive(key, value):
        return Color(0.92, 0.72, 0.3, 1.0)
    if Presenter.is_effect_negative(key, value):
        return Color(0.7, 0.32, 0.14, 1.0) if GameState.theme == "dark" else Color(0.58, 0.25, 0.1, 1.0)
    return GameState.get_theme_color("text_desc")

func _get_stat_label(stat_key: String) -> String:
    return ChoiceRequirementServiceRef.stat_label(stat_key)

func _get_stat_or_resource_value(stat_key: String) -> int:
    return ChoiceRequirementServiceRef.stat_or_resource_value(stat_key, GameState)

func _current_event_disables_choice_dice() -> bool:
    var evt = GameState.get_current_event()
    if GameState.is_governance_mode():
        evt = GameState.get_month_card_event(governance_active_card_index)
    return bool(evt.get("isActEnding", false))

func _current_event_shows_locked_hidden_choices() -> bool:


    return true

func _parse_dice_eligibility(ch: Dictionary) -> Dictionary:
    return ChoiceRequirementServiceRef.parse_dice_eligibility(ch, GameState)

func _require_fn_uses_boolean_state(req_fn: String) -> bool:
    return ChoiceRequirementServiceRef.require_fn_uses_boolean_state(req_fn)

func _strip_wrapping_parentheses(raw_text: String) -> String:
    return ChoiceRequirementServiceRef.strip_wrapping_parentheses(raw_text)

func _evaluate_require_fn(req_fn: String) -> bool:
    return ChoiceRequirementServiceRef.evaluate_require_fn(req_fn, GameState)

func _split_require_fn(text: String, separator: String) -> Array[String]:
    return ChoiceRequirementServiceRef.split_require_fn(text, separator)

func _evaluate_require_fn_condition(cond: String) -> bool:
    return ChoiceRequirementServiceRef.evaluate_require_fn_condition(cond, GameState)

func _extract_call_string_argument(text: String) -> String:
    return ChoiceRequirementServiceRef.extract_call_string_argument(text)

func _evaluate_last_branch_choice_condition(text: String) -> bool:
    return ChoiceRequirementServiceRef.evaluate_last_branch_choice_condition(text, GameState)

func _evaluate_stat_or_resource_condition(text: String) -> bool:
    return ChoiceRequirementServiceRef.evaluate_stat_or_resource_condition(text, GameState)

func _evaluate_tags_count_condition(text: String) -> bool:
    return ChoiceRequirementServiceRef.evaluate_tags_count_condition(text, GameState)

func _evaluate_items_prefix_count_condition(text: String) -> bool:
    return ChoiceRequirementServiceRef.evaluate_items_prefix_count_condition(text, GameState)

func _evaluate_explicit_items_count_condition(text: String) -> bool:
    return ChoiceRequirementServiceRef.evaluate_explicit_items_count_condition(text, GameState)

func _calc_dice_threshold(gap: int) -> Dictionary:
    return ChoiceRequirementServiceRef.calc_dice_threshold(gap)

func get_dice_pass_hint(min_val: int) -> String:
    return ChoiceRequirementServiceRef.dice_pass_hint(min_val)

func _choice_card_uses_light_dark_style() -> bool:
    return GameState.theme == "light" and not _is_mobile_portrait()

func _choice_card_bg_color(hovered: bool = false, pressed: bool = false, locked: bool = false) -> Color:
    if locked:
        return Color(0.145, 0.135, 0.12, 0.72)
    var color: = Color(0.112, 0.108, 0.096, 0.96)
    if hovered:
        color = Color(0.154, 0.146, 0.128, 0.98)
    if pressed:
        color = Color(0.09, 0.084, 0.074, 0.98)
    return color

func _settlement_card_bg_color() -> Color:
    return Color(0.34, 0.34, 0.31, 0.96)

func _choice_card_gradient_texture(settlement: bool = false) -> GradientTexture2D:
    var grad: = Gradient.new()
    if settlement:
        grad.offsets = PackedFloat32Array([0.0, 1.0])
        grad.colors = PackedColorArray([
            Color(0.46, 0.46, 0.43, 0.94), 
            Color(0.25, 0.25, 0.23, 0.96)
        ])
    else:
        grad.offsets = PackedFloat32Array([0.0, 1.0])
        grad.colors = PackedColorArray([
            Color(0.17, 0.125, 0.085, 0.98), 
            Color(0.05, 0.049, 0.046, 0.98)
        ])
    var tex: = GradientTexture2D.new()
    tex.gradient = grad
    tex.fill_from = Vector2(0.0, 0.0) if settlement else Vector2(0.0, 0.5)
    tex.fill_to = Vector2(1.0, 1.0) if settlement else Vector2(1.0, 0.5)
    tex.width = 256
    tex.height = 256 if settlement else 16
    return tex

func _choice_card_texture_style(settlement: bool = false) -> StyleBoxTexture:
    var style: = StyleBoxTexture.new()
    style.texture = _choice_card_gradient_texture(settlement)
    style.content_margin_left = 16
    style.content_margin_right = 16
    style.content_margin_top = 16
    style.content_margin_bottom = 16
    return style

func _choice_confirm_button_bg_color(hovered: bool = false, pressed: bool = false) -> Color:
    if pressed:
        return Color(0.06, 0.056, 0.05, 0.98)
    if hovered:
        return Color(0.112, 0.104, 0.092, 0.98)
    return Color(0.078, 0.073, 0.064, 0.98)

func _choice_card_text_color(secondary: bool = false, locked: bool = false) -> Color:
    if locked:
        return Color(0.78, 0.78, 0.74, 0.72)
    return Color(0.9, 0.9, 0.86, 0.92) if secondary else Color(0.965, 0.955, 0.9, 0.98)

func _choice_card_hint_color(color: Color) -> Color:
    if not _choice_card_uses_light_dark_style():
        return color
    var bright: = color.lightened(0.28)
    bright.a = minf(1.0, maxf(color.a, 0.92))
    return bright

func _create_choice_unified_wrapper(is_hidden: bool, is_locked: bool, is_risky: bool) -> Dictionary:
    var container = MarginContainer.new()
    container.mouse_filter = Control.MOUSE_FILTER_PASS
    container.gui_input.connect(_on_event_scroll_touch_drag)
    container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    container.custom_minimum_size.x = 0
    container.z_as_relative = false
    container.z_index = 10

    var bg_panel = PanelContainer.new()
    bg_panel.mouse_filter = Control.MOUSE_FILTER_PASS
    bg_panel.gui_input.connect(_on_event_scroll_touch_drag)
    bg_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    bg_panel.custom_minimum_size.x = 0
    var bg_style = StyleBoxFlat.new()
    bg_style.bg_color = GameState.get_theme_color("choice_normal") if not is_locked else GameState.get_theme_color("choice_locked")
    if _choice_card_uses_light_dark_style():
        bg_style.bg_color = _choice_card_bg_color(false, false, is_locked)
    bg_style.corner_radius_top_left = 2;bg_style.corner_radius_top_right = 2
    bg_style.corner_radius_bottom_left = 2;bg_style.corner_radius_bottom_right = 2
    bg_style.shadow_size = 8 if GameState.theme == "dark" and not is_locked else 0
    bg_style.shadow_color = Color(0, 0, 0, 0.24)
    bg_panel.add_theme_stylebox_override("panel", bg_style)
    bg_panel.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
    container.add_child(bg_panel)

    var effect = Control.new()
    effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var grad = Gradient.new()
    if GameState.theme == "dark" or _choice_card_uses_light_dark_style():
        grad.offsets = PackedFloat32Array([0.0, 1.0])
        grad.colors = PackedColorArray([
            Color(0.17, 0.125, 0.085, 0.98), 
            Color(0.05, 0.049, 0.046, 0.98)
        ])
    else:
        grad.offsets = PackedFloat32Array([0.0, 0.35, 0.7, 1.0])
        grad.colors = PackedColorArray([
            Color(1.0, 0.99, 0.97, 0.75), 
            Color(0.96, 0.93, 0.86, 0.5), 
            Color(0.86, 0.76, 0.6, 0.45), 
            Color(0.74, 0.62, 0.42, 0.65)
        ])
    var grad_tex = GradientTexture2D.new()
    grad_tex.gradient = grad
    grad_tex.fill_from = Vector2(0.0, 0.5) if (GameState.theme == "dark" or _choice_card_uses_light_dark_style()) else Vector2(0, 0)
    grad_tex.fill_to = Vector2(1.0, 0.5) if (GameState.theme == "dark" or _choice_card_uses_light_dark_style()) else Vector2(1, 1)
    grad_tex.width = 256 if (GameState.theme == "dark" or _choice_card_uses_light_dark_style()) else 64
    grad_tex.height = 16 if (GameState.theme == "dark" or _choice_card_uses_light_dark_style()) else 256
    effect.draw.connect( func():
        var s = effect.size
        if GameState.theme == "dark" or _choice_card_uses_light_dark_style():
            effect.draw_texture_rect(grad_tex, Rect2(0, 0, s.x, s.y), false)
        elif CHOICE_CIRCLE_PATTERN != null:



            var inset: = 5.0
            if s.x > inset * 2.0 and s.y > inset * 2.0:
                effect.draw_texture_rect(CHOICE_CIRCLE_PATTERN, Rect2(Vector2(inset, inset), s - Vector2(inset * 2.0, inset * 2.0)), true, Color(1, 1, 1, 0.1))
    )
    bg_panel.add_child(effect)

    var border_layer = PanelContainer.new()
    border_layer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    border_layer.custom_minimum_size.x = 0
    var get_border_style = func(is_hover: bool, is_pressed: bool):
        var b = StyleBoxFlat.new()
        b.draw_center = false

        var bw: = 1
        var light_mode: = GameState.theme == "light"
        b.border_width_left = bw;b.border_width_right = bw
        b.border_width_top = bw;b.border_width_bottom = bw
        b.corner_radius_top_left = 2;b.corner_radius_top_right = 2
        b.corner_radius_bottom_left = 2;b.corner_radius_bottom_right = 2
        if is_locked:
            b.border_color = Color(1, 1, 1, 0.18) if _choice_card_uses_light_dark_style() else Color(0.35, 0.3, 0.25, 0.4)
        elif light_mode:
            if is_pressed:
                b.border_color = Color(1, 1, 1, 0.58) if _choice_card_uses_light_dark_style() else Color(0.48, 0.35, 0.13, 0.85)
            elif is_hover:
                b.border_color = Color(1, 1, 1, 0.42) if _choice_card_uses_light_dark_style() else Color(0, 0, 0, 0)
            else:
                b.border_color = Color(1, 1, 1, 0.3) if _choice_card_uses_light_dark_style() else Color(0.56, 0.43, 0.21, 0.5)
        else:
            if is_pressed:
                b.border_color = Color(1.0, 0.75, 0.35, 0.95) if is_hidden else GameState.get_theme_color("border_active")
            elif is_hover:
                b.border_color = GameState.get_theme_color("border_stronger") if is_hidden else GameState.get_theme_color("border_stronger")
            else:
                b.border_color = GameState.get_theme_color("border_strong") if is_hidden else GameState.get_theme_color("border")
        return b

    border_layer.add_theme_stylebox_override("panel", get_border_style.call(false, false))
    border_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    border_layer.draw.connect( func():
        var s: Vector2 = border_layer.size
        var current_style = border_layer.get_theme_stylebox("panel") as StyleBoxFlat
        if current_style == null:
            return
        var base_color = current_style.border_color

        var inner_color = Color(base_color.r, base_color.g, base_color.b, base_color.a * 0.35)

        var margin: float = 4.0
        var d: float = 4.0
        var left: float = margin
        var top: float = margin
        var right: float = s.x - margin
        var bottom: float = s.y - margin

        if s.x < (margin + d) * 2.0 or s.y < (margin + d) * 2.0:
            return

        var points = PackedVector2Array([
            Vector2(left + d, top), 
            Vector2(right - d, top), 
            Vector2(right - d, top + d), 
            Vector2(right, top + d), 
            Vector2(right, bottom - d), 
            Vector2(right - d, bottom - d), 
            Vector2(right - d, bottom), 
            Vector2(left + d, bottom), 
            Vector2(left + d, bottom - d), 
            Vector2(left, bottom - d), 
            Vector2(left, top + d), 
            Vector2(left + d, top + d), 
            Vector2(left + d, top)
        ])
        border_layer.draw_polyline(points, inner_color, 1.0)
    )
    container.add_child(border_layer)

    var content_pad = MarginContainer.new()
    content_pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
    content_pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content_pad.custom_minimum_size.x = 0
    content_pad.add_theme_constant_override("margin_left", _mobile_font_size(14, MOBILE_CHOICE_SIDE_PADDING))
    content_pad.add_theme_constant_override("margin_right", _mobile_font_size(14, MOBILE_CHOICE_SIDE_PADDING))
    content_pad.add_theme_constant_override("margin_top", _mobile_font_size(12, 16))
    content_pad.add_theme_constant_override("margin_bottom", _mobile_font_size(12, 16))
    container.add_child(content_pad)
    container.custom_minimum_size.y = MOBILE_CHOICE_MIN_HEIGHT if _is_mobile_portrait() else 0

    var btn: Button = null
    if not is_locked:
        btn = Button.new()
        btn.mouse_filter = Control.MOUSE_FILTER_PASS
        var empty_style = StyleBoxEmpty.new()
        btn.add_theme_stylebox_override("normal", empty_style)
        btn.add_theme_stylebox_override("hover", empty_style)
        btn.add_theme_stylebox_override("pressed", empty_style)
        btn.add_theme_stylebox_override("focus", empty_style)
        btn.gui_input.connect(_on_event_scroll_touch_drag)

        var base_bg = GameState.get_theme_color("choice_normal")
        var hover_bg = GameState.get_theme_color("choice_hover")
        var press_bg = GameState.get_theme_color("choice_press")
        if _choice_card_uses_light_dark_style():
            base_bg = _choice_card_bg_color()
            hover_bg = _choice_card_bg_color(true)
            press_bg = _choice_card_bg_color(false, true)
        elif GameState.theme == "light":
            base_bg = Color("d7c9b3")
            hover_bg = base_bg.darkened(0.04)
            press_bg = base_bg.darkened(0.08)

        btn.mouse_entered.connect( func():
            border_layer.add_theme_stylebox_override("panel", get_border_style.call(true, false))
            bg_style.bg_color = hover_bg
        )
        btn.mouse_exited.connect( func():
            border_layer.add_theme_stylebox_override("panel", get_border_style.call(false, false))
            bg_style.bg_color = base_bg
        )
        btn.button_down.connect( func():
            border_layer.add_theme_stylebox_override("panel", get_border_style.call(true, true))
            bg_style.bg_color = press_bg
        )
        btn.button_up.connect( func():
            border_layer.add_theme_stylebox_override("panel", get_border_style.call(btn.is_hovered(), false))
            bg_style.bg_color = hover_bg if btn.is_hovered() else base_bg
        )
        container.add_child(btn)

    return {"root": container, "pad": content_pad, "btn": btn}

func _on_background_touch_drag(event: InputEvent) -> void :
    if _handle_bianwu_backdrop_gui_input(event):
        return
    if _is_mobile_portrait() and mobile_event_phase == "reading":
        if is_instance_valid(mobile_narrative_scroll) and mobile_narrative_scroll.visible:
            NativeMobileTouchScrollRef.forward_drag_to_scroll(event, mobile_narrative_scroll, self, "event_scroll_touch_drag_suppress_until_ms")
            return
    if is_instance_valid(governance_scroll) and governance_scroll.visible:
        _on_governance_scroll_touch_drag(event)
    else:
        _on_event_scroll_touch_drag(event)

func _on_event_scroll_touch_drag(event: InputEvent) -> void :
    NativeMobileTouchScrollRef.forward_drag_to_scroll(event, event_scroll, self, "event_scroll_touch_drag_suppress_until_ms")

func _on_items_scroll_touch_drag(event: InputEvent) -> void :
    NativeMobileTouchScrollRef.forward_drag_to_scroll(event, items_scroll, self, "items_scroll_touch_drag_suppress_until_ms")

func _on_jushi_scroll_touch_drag(event: InputEvent) -> void :
    NativeMobileTouchScrollRef.forward_drag_to_scroll(event, jushi_scroll, self, "jushi_scroll_touch_drag_suppress_until_ms")

func _on_mobile_info_scroll_touch_drag(event: InputEvent) -> void :
    NativeMobileTouchScrollRef.forward_drag_to_scroll(event, mobile_info_scroll, self, "mobile_info_scroll_touch_drag_suppress_until_ms")

func _connect_item_scroll_drag_forwarders() -> void :
    _connect_scroll_drag_forwarders_recursive(items_info_container, _on_items_scroll_touch_drag)

func _connect_jushi_scroll_drag_forwarders() -> void :
    _connect_scroll_drag_forwarders_recursive(jushi_vbox, _on_jushi_scroll_touch_drag)

func _on_zhisu_scroll_touch_drag(event: InputEvent) -> void :
    NativeMobileTouchScrollRef.forward_drag_to_scroll(event, zhisu_scroll, self, "jushi_scroll_touch_drag_suppress_until_ms")

func _connect_zhisu_scroll_drag_forwarders() -> void :
    _connect_scroll_drag_forwarders_recursive(zhisu_vbox, _on_zhisu_scroll_touch_drag)

func _on_zengyi_scroll_touch_drag(event: InputEvent) -> void :

    NativeMobileTouchScrollRef.forward_event_to_scroll(event, zengyi_scroll, self, "jushi_scroll_touch_drag_suppress_until_ms")

func _connect_zengyi_scroll_drag_forwarders() -> void :
    if not is_instance_valid(zengyi_vbox):
        return
    _connect_scroll_drag_forwarders_recursive(zengyi_vbox, _on_zengyi_scroll_touch_drag)

func _on_dangan_scroll_touch_drag(event: InputEvent) -> void :

    NativeMobileTouchScrollRef.forward_event_to_scroll(event, dangan_scroll, self, "jushi_scroll_touch_drag_suppress_until_ms")

func _connect_dangan_scroll_drag_forwarders() -> void :
    if not is_instance_valid(dangan_vbox):
        return
    _connect_scroll_drag_forwarders_recursive(dangan_vbox, _on_dangan_scroll_touch_drag)

func _on_shezhi_scroll_touch_drag(event: InputEvent) -> void :

    NativeMobileTouchScrollRef.forward_event_to_scroll(event, shezhi_scroll, self, "jushi_scroll_touch_drag_suppress_until_ms")

func _connect_shezhi_scroll_drag_forwarders() -> void :
    if not is_instance_valid(shezhi_info_container):
        return
    _connect_scroll_drag_forwarders_recursive(shezhi_info_container, _on_shezhi_scroll_touch_drag)

func _connect_scroll_drag_forwarders_recursive(node: Node, handler: Callable) -> void :
    if node is Control:
        var control: = node as Control
        if control.mouse_filter == Control.MOUSE_FILTER_STOP:
            control.mouse_filter = Control.MOUSE_FILTER_PASS
        if not control.gui_input.is_connected(handler):
            control.gui_input.connect(handler)
    for child in node.get_children():
        _connect_scroll_drag_forwarders_recursive(child, handler)


func _apply_mobile_event_width_constraints() -> void :
    event_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    event_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    event_vbox.custom_minimum_size.x = 0
    choices_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    choices_container.custom_minimum_size.x = 0
    for node in [
        stage_label, 
        event_date_label, 
        event_title_label, 
        title_rule, 
        speaker_bubble, 
        speaker_name, 
        speaker_role, 
        speaker_faction, 
        speaker_line, 
        narrative_label, 
        flavor_panel, 
        flavor_label, 
        focus_panel, 
        focus_label, 
        result_panel
    ]:
        if node is Control:
            node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            node.custom_minimum_size.x = 0
    for child in choices_container.get_children():
        if child is Control:
            child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            child.custom_minimum_size.x = 0

func _apply_mobile_governance_width_constraints() -> void :
    governance_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    governance_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    governance_vbox.custom_minimum_size.x = 0
    month_cards_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    month_cards_container.custom_minimum_size.x = 0
    action_points_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    action_points_row.custom_minimum_size.x = 0
    for child in month_cards_container.get_children():
        if child is Control:
            child.size_flags_horizontal = Control.SIZE_SHRINK_CENTER


func _on_governance_scroll_touch_drag(event: InputEvent) -> void :
    NativeMobileTouchScrollRef.forward_drag_to_scroll(event, governance_scroll, self, "governance_scroll_touch_drag_suppress_until_ms")

func _build_choices(choices: Array) -> void :
    for child in choices_container.get_children():
        child.queue_free()

    for i in range(choices.size()):
        var ch = choices[i]

        var hide_keju = ch.get("hideIfKeju", [])
        if hide_keju.size() > 0 and hide_keju.has(GameState.keju_status):
            continue
        var show_keju = ch.get("showIfKeju", [])
        if show_keju.size() > 0 and not show_keju.has(GameState.keju_status):
            continue
        var require_char = ch.get("requireChar", [])
        if require_char.size() > 0 and not require_char.has(GameState.char_id):
            continue

        if require_char.has("hanmen"):
            continue
        var show_last_branch_choice: = str(ch.get("showIfLastBranchChoice", "")).strip_edges()
        if show_last_branch_choice != "" and GameState.last_branch_choice != show_last_branch_choice:
            continue
        var show_play_mode: = str(ch.get("showIfPlayMode", "")).strip_edges()
        if show_play_mode != "" and GameState.play_mode != show_play_mode:
            continue

        var display_title = str(ch.get("title", ""))



        var parts = _split_choice_title(display_title)
        var tag_text = parts.get("tag", "").strip_edges()
        if tag_text != "":
            var desc_text = ch.get("desc", ch.get("description", ""))
            if desc_text == "":
                desc_text = parts.get("line", "")
            display_title = "【" + tag_text + "】" + desc_text

        var is_hidden = ch.get("hidden", false)
        var unlocked = true
        var dice_check = {"eligible": false, "gap": 0}
        var lock_info = ""

        var req = ch.get("require", ch.get("requirement", {}))
        var req_fn = ch.get("requireFn", "")
        if req_fn != "" or not req.is_empty():
            if req_fn != "":
                var parsed = _parse_dice_eligibility(ch)
                unlocked = parsed.get("unlocked", false)
                dice_check = parsed.get("dice", {"eligible": false, "gap": 0})
                if unlocked:
                    lock_info = _build_hidden_hint(ch, req)
                else:
                    var raw_lbl: = str(ch.get("requireLabel", "")).strip_edges()
                    if raw_lbl == "" or raw_lbl == "条件未完成":
                        var auto_hint: = _build_hidden_hint(ch, req)
                        if auto_hint != "":
                            lock_info = auto_hint
                        else:
                            lock_info = "条件未完成"
                    elif raw_lbl.ends_with("已启") or raw_lbl.contains("已开启"):
                        lock_info = "未达触发条件"
                    else:
                        lock_info = ChoiceHintBuilderRef.format_requirement_label(raw_lbl)
            elif not req.is_empty():
                var req_stat = req.get("stat", "")
                var req_val = req.get("value", req.get("min", 0))
                var current_val = _get_stat_or_resource_value(str(req_stat))
                unlocked = current_val >= req_val
                lock_info = "需要 %s ≥ %d" % [_get_stat_label(req_stat), int(req_val)]
                if not unlocked:
                    dice_check = {"eligible": true, "gap": req_val - current_val}

        var req_city = ch.get("requireCity", {})
        if not req_city.is_empty():
            var req_city_stat = req_city.get("stat", "")
            var req_city_val = int(req_city.get("value", req_city.get("min", 0)))
            var current_city_val = _get_stat_or_resource_value(str(req_city_stat))
            if current_city_val < req_city_val:
                unlocked = false
                dice_check.eligible = false
                var req_city_label = str(ch.get("requireCityLabel", ""))
                if req_city_label == "":
                    req_city_label = GameData.city_stat_effect_label(req_city_stat)
                lock_info = "需要 %s ≥ %d" % [req_city_label, req_city_val]

        var display_choice: Dictionary = ch.duplicate(true)
        if ch.has("dynamicCourtLevy"):
            display_choice["effects"] = EffectsServiceRef.choice_effects_for_state(GameState, ch)
        var effects = display_choice.get("effects", {})
        var skip_limit_for = ch.get("skipLimitFor", [])
        for k in effects:
            if k in skip_limit_for:
                continue
            if effects[k] < 0:
                var required_effect_value: int = absi(int(effects[k]))
                if not _should_show_choice_requirement_value(required_effect_value):
                    continue
                if k in ["liumin", "renkou_val", "zhengji"]:
                    continue

                if k in GameState.stats and GameState.stats[k] + effects[k] < 0:
                    unlocked = false
                    dice_check.eligible = false
                    lock_info = "需要 %s ≥ %d" % [GameData.STAT_LABELS.get(k, k), required_effect_value]
                if k == "private_silver" and GameState.private_silver + effects[k] < 0:
                    unlocked = false
                    dice_check.eligible = false
                    lock_info = "需要 %s ≥ %d" % [_get_stat_label("private_silver"), required_effect_value]
                if k in GameState.city:
                    if GameData.CITY_STAT_KEYS.has(k):
                        continue
                    if GameState.city[k] + effects[k] < 0:
                        unlocked = false
                        dice_check.eligible = false
                        if k == "yinliang":
                            lock_info = "需要 库银 ≥ %d" % required_effect_value
                        else:
                            lock_info = "需要 %s ≥ %d" % [GameData.city_stat_effect_label(k), required_effect_value]
        if ch.get("noDice", false) or _current_event_disables_choice_dice():
            dice_check.eligible = false

        if not unlocked and not dice_check.eligible:
            if ch.get("hideWhenLocked", false):
                continue
            if is_hidden and not _current_event_shows_locked_hidden_choices():
                continue
            var wrapper = _create_choice_unified_wrapper(is_hidden, true, false)
            var locked = wrapper.root
            var content_pad = wrapper.pad
            var locked_box = VBoxContainer.new()
            locked_box.alignment = BoxContainer.ALIGNMENT_CENTER
            locked_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
            locked_box.add_theme_constant_override("separation", _mobile_font_size(6, 10))
            locked_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL

            var lock_title_row = _create_choice_title_row(Presenter.resolve_text_placeholders(display_title), true)
            locked_box.add_child(lock_title_row)

            var lock_upgrade_desc: = _create_upgrade_card_desc_label(ch)
            if lock_upgrade_desc != null:
                locked_box.add_child(lock_upgrade_desc)








            var lock_info_label = Label.new()
            lock_info_label.text = lock_info
            lock_info_label.add_theme_font_override("font", FontLoader.body())
            lock_info_label.add_theme_font_size_override("font_size", _mobile_font_size(12, MOBILE_CHOICE_HINT_FONT_SIZE))
            lock_info_label.add_theme_color_override("font_color", _choice_card_hint_color(GameState.get_theme_color("req_red")))
            if not _attach_choice_hint_to_title_row(lock_title_row, lock_info_label):
                locked_box.add_child(lock_info_label)
            content_pad.add_child(locked_box)
            choices_container.add_child(locked)
        elif not unlocked and dice_check.eligible:
            var is_risky = true
            var wrapper = _create_choice_unified_wrapper(is_hidden, false, true)
            var risky_panel = wrapper.root
            var content_pad = wrapper.pad


            if wrapper.btn != null:
                wrapper.btn.pressed.connect(_on_choice_selected.bind(i, true))

            var content = VBoxContainer.new()
            content.mouse_filter = Control.MOUSE_FILTER_IGNORE
            content.add_theme_constant_override("separation", _mobile_font_size(6, 10))
            content.size_flags_horizontal = Control.SIZE_EXPAND_FILL

            var title_row = _create_choice_title_row(Presenter.resolve_text_placeholders(display_title))
            content.add_child(title_row)

            var upgrade_desc: = _create_upgrade_card_desc_label(ch)
            if upgrade_desc != null:
                content.add_child(upgrade_desc)








            var risk_hbox = HBoxContainer.new()
            risk_hbox.add_theme_constant_override("separation", 12)
            risk_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

            var thresh = _calc_dice_threshold(dice_check.gap)
            var info_label = Label.new()
            info_label.text = "%s   %s" % [lock_info, thresh.dots]
            info_label.add_theme_font_override("font", FontLoader.body())
            info_label.add_theme_font_size_override("font_size", _mobile_font_size(12, MOBILE_CHOICE_HINT_FONT_SIZE))
            var diff_color = GameState.get_theme_color("req_red")
            if thresh.level <= 1:
                diff_color = GameState.get_theme_color("req_green")
            elif thresh.level <= 3:
                diff_color = GameState.get_theme_color("req_yellow")
            diff_color = _choice_card_hint_color(diff_color)
            info_label.add_theme_color_override("font_color", diff_color)
            info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            info_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

            var try_btn = Button.new()
            try_btn.mouse_filter = Control.MOUSE_FILTER_PASS
            try_btn.text = "勉力一试"
            try_btn.gui_input.connect(_on_event_scroll_touch_drag)
            try_btn.add_theme_font_override("font", FontLoader.body())
            try_btn.add_theme_font_size_override("font_size", _mobile_font_size(12, MOBILE_CHOICE_HINT_FONT_SIZE))
            try_btn.custom_minimum_size = Vector2(0, 56) if _is_mobile_portrait() else Vector2(0, 0)
            var try_style = StyleBoxFlat.new()
            var is_light_try: = GameState.theme == "light"
            if _choice_card_uses_light_dark_style():
                try_style.bg_color = Color(1, 1, 1, 0.1)
                _apply_style_border_width(try_style, _responsive_border_width())
                try_style.border_color = Color(1, 1, 1, 0.28)
            elif is_light_try:
                try_style.bg_color = Color(0.52, 0.39, 0.17, 1.0)
                _apply_style_border_width(try_style, 0)
            else:
                try_style.bg_color = GameState.get_theme_color("choice_normal")
                _apply_style_border_width(try_style, _responsive_border_width())
                try_style.border_color = GameState.get_theme_color("border_med")
            try_style.corner_radius_top_left = 2;try_style.corner_radius_top_right = 2
            try_style.corner_radius_bottom_left = 2;try_style.corner_radius_bottom_right = 2
            try_style.content_margin_left = 12;try_style.content_margin_right = 12
            try_style.content_margin_top = 4;try_style.content_margin_bottom = 4
            try_btn.add_theme_stylebox_override("normal", try_style)
            try_btn.add_theme_color_override("font_color", _choice_card_text_color() if _choice_card_uses_light_dark_style() else (Color(0.97, 0.93, 0.84, 1.0) if is_light_try else GameState.get_theme_color("text_main")))

            var try_hover = try_style.duplicate()
            try_hover.bg_color = Color(1, 1, 1, 0.16) if _choice_card_uses_light_dark_style() else (Color(0.44, 0.32, 0.13, 1.0) if is_light_try else GameState.get_theme_color("choice_risky_hover"))
            try_btn.add_theme_stylebox_override("hover", try_hover)
            try_btn.add_theme_stylebox_override("pressed", try_style)

            try_btn.pressed.connect(_on_choice_selected.bind(i, true))


            var attached: = false
            if not _is_mobile_portrait() and _is_event_portrait_active():
                info_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
                if _attach_choice_hint_to_title_row(title_row, info_label):

                    var spring: = Control.new()
                    spring.mouse_filter = Control.MOUSE_FILTER_IGNORE
                    spring.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                    _attach_choice_hint_to_title_row(title_row, spring)


                    _attach_choice_hint_to_title_row(title_row, try_btn)
                    attached = true

            if not attached:
                info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                risk_hbox.add_child(info_label)
                risk_hbox.add_child(try_btn)
                content.add_child(risk_hbox)

            content_pad.add_child(content)
            choices_container.add_child(risky_panel)
        else:
            var wrapper = _create_choice_unified_wrapper(is_hidden, false, false)
            var root = wrapper.root
            var content_pad = wrapper.pad
            var btn = wrapper.btn

            var content = VBoxContainer.new()
            content.mouse_filter = Control.MOUSE_FILTER_IGNORE
            content.add_theme_constant_override("separation", _mobile_font_size(4, 9))
            content.size_flags_horizontal = Control.SIZE_EXPAND_FILL

            var title_row = _create_choice_title_row(Presenter.resolve_text_placeholders(display_title))
            content.add_child(title_row)

            var upgrade_desc: = _create_upgrade_card_desc_label(ch)
            if upgrade_desc != null:
                content.add_child(upgrade_desc)




            var hint_label = Label.new()
            hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
            hint_label.add_theme_font_override("font", FontLoader.body())
            hint_label.add_theme_font_size_override("font_size", _mobile_font_size(11, MOBILE_CHOICE_HINT_FONT_SIZE))

            if is_hidden:
                hint_label.text = lock_info if lock_info != "" else _build_hidden_hint(ch, req)
                hint_label.add_theme_color_override("font_color", _choice_card_hint_color(GameState.get_theme_color("req_green")))
            else:
                var satisfied_text = _build_satisfied_hints(display_choice, req)
                if satisfied_text != "":
                    hint_label.text = satisfied_text
                    hint_label.add_theme_color_override("font_color", _choice_card_hint_color(GameState.get_theme_color("req_green")))
                    hint_label.visible = true
                else:
                    hint_label.text = ""
                    hint_label.visible = false

            if hint_label.text != "":
                var txt = hint_label.text
                txt = txt.replace("需要持有", "已持有")
                txt = txt.replace("需要未持有", "已确认未持有")
                txt = txt.replace("需要完成", "已完成")
                txt = txt.replace("需要", "已达")
                hint_label.text = txt

            if hint_label.text != "" and not _attach_choice_hint_to_title_row(title_row, hint_label):
                content.add_child(hint_label)

            content_pad.add_child(content)
            btn.pressed.connect(_on_choice_selected.bind(i, false))
            choices_container.add_child(root)
    _connect_scroll_drag_forwarders_recursive(choices_container, _on_event_scroll_touch_drag)
    _queue_mobile_pixel_snap()


func _create_upgrade_card_desc_label(ch: Dictionary) -> Label:
    if str(ch.get("upgradeCardId", "")) == "":
        return null
    var desc_text: = str(ch.get("description", ch.get("desc", ""))).strip_edges()
    if desc_text == "":
        return null
    var desc_label = Label.new()
    desc_label.text = Presenter.resolve_text_placeholders(desc_text)
    desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    desc_label.add_theme_font_override("font", FontLoader.body())
    desc_label.add_theme_font_size_override("font_size", _mobile_font_size(12, MOBILE_CHOICE_BODY_FONT_SIZE))
    desc_label.add_theme_color_override("font_color", _choice_card_text_color(true) if _choice_card_uses_light_dark_style() else GameState.get_theme_color("text_desc"))
    return desc_label

func _format_choice_title(raw_title: Variant, shorten: bool = false) -> String:
    return ChoiceTitleFormatterRef.format_title(raw_title, shorten)

func _split_choice_title(raw_title: Variant, shorten: bool = false) -> Dictionary:
    return ChoiceTitleFormatterRef.split_title(raw_title, shorten)

func _create_choice_title_row(raw_title: Variant, locked: bool = false) -> BoxContainer:
    var parts: = _split_choice_title(raw_title)
    var is_mobile: = _is_mobile_portrait()


    var split_rows: = not is_mobile and (_is_event_portrait_active() or speaker_bubble.visible)
    var row: BoxContainer
    if is_mobile:
        row = VBoxContainer.new()
        row.add_theme_constant_override("separation", 14)
    elif split_rows:
        row = VBoxContainer.new()
        row.add_theme_constant_override("separation", 6)
    else:
        row = HBoxContainer.new()
        row.add_theme_constant_override("separation", _mobile_font_size(9, 12))

    row.mouse_filter = Control.MOUSE_FILTER_IGNORE
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    var tag_row: HBoxContainer = null
    if split_rows:
        tag_row = HBoxContainer.new()
        tag_row.name = "ChoiceTagRow"
        tag_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
        tag_row.add_theme_constant_override("separation", 12)
        tag_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(tag_row)

    var tag_text: = str(parts.get("tag", "")).strip_edges()
    if split_rows:
        tag_row.visible = tag_text != ""
    if tag_text != "":
        var tag_panel: = PanelContainer.new()
        tag_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
        tag_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        if is_mobile:
            tag_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
        tag_panel.add_theme_stylebox_override("panel", _make_choice_title_tag_style(locked))

        var tag_label: = Label.new()
        tag_label.text = tag_text
        tag_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        tag_label.add_theme_font_override("font", FontLoader.body())

        var tag_font_size
        if is_mobile:
            tag_font_size = _mobile_font_size(14, MOBILE_CHOICE_TITLE_FONT_SIZE) if locked else _mobile_font_size(15, MOBILE_CHOICE_TITLE_FONT_SIZE)
        else:
            tag_font_size = _mobile_font_size(13, MOBILE_CHOICE_HINT_FONT_SIZE)

        tag_label.add_theme_font_size_override("font_size", tag_font_size)

        var tag_color: Color
        if locked:
            tag_color = _choice_card_text_color(true, true) if _choice_card_uses_light_dark_style() else GameState.get_theme_color("text_sub")
        elif _choice_card_uses_light_dark_style():
            tag_color = Color(0.98, 0.88, 0.55, 0.98)
        elif GameState.theme == "light":
            tag_color = Color(0.52, 0.39, 0.17, 1.0)
        else:
            tag_color = GameState.get_theme_color("border_active")
        tag_label.add_theme_color_override("font_color", tag_color)
        tag_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        tag_panel.add_child(tag_label)
        if split_rows:
            tag_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
            tag_row.add_child(tag_panel)
        else:
            row.add_child(tag_panel)

    var line_label: = Label.new()
    line_label.text = str(parts.get("line", "")).strip_edges()
    line_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    line_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    line_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    line_label.add_theme_font_override("font", FontLoader.body())
    var title_font_size = _mobile_font_size(14, MOBILE_CHOICE_TITLE_FONT_SIZE) if locked else _mobile_font_size(15, MOBILE_CHOICE_TITLE_FONT_SIZE)
    line_label.add_theme_font_size_override("font_size", title_font_size)
    line_label.add_theme_color_override("font_color", _choice_card_text_color(false, locked) if _choice_card_uses_light_dark_style() else (GameState.get_theme_color("text_sub") if locked else GameState.get_theme_color("text_main")))


    if line_label.text == "":
        line_label.visible = false
    row.add_child(line_label)
    return row


func _make_choice_title_tag_style(locked: bool = false) -> StyleBoxFlat:
    return GameScreenStyleFactory.choice_title_tag_style(locked, _responsive_border_width())

func _clear_dynamic_chosen_choice() -> void :
    if is_instance_valid(chosen_choice_title):
        var chosen_choice_vbox = chosen_choice_title.get_parent()
        if chosen_choice_vbox is VBoxContainer:
            for child in chosen_choice_vbox.get_children():
                if child.name.begins_with("DynamicChosenChoiceRow"):
                    child.queue_free()
        chosen_choice_title.visible = true

func _apply_chosen_choice_text_layout() -> void :
    if chosen_choice_desc.text == "":
        chosen_choice_desc.visible = false
    else:
        chosen_choice_desc.visible = true

    for label in [chosen_choice_title, chosen_choice_desc]:
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        label.clip_text = false
        label.custom_minimum_size.x = 0
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    chosen_choice_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    chosen_choice_box.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

    var chosen_choice_vbox = chosen_choice_title.get_parent()
    if chosen_choice_vbox is VBoxContainer:
        chosen_choice_vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        for child in chosen_choice_vbox.get_children():
            if child.name.begins_with("DynamicChosenChoiceRow") and child is Control:
                child.reset_size()

    chosen_choice_box.reset_size()
    chosen_choice_desc.reset_size()
    chosen_choice_title.reset_size()
    chosen_choice_box.update_minimum_size()

func _keep_alphanumeric_and_chinese(text: String) -> String:
    return ChoiceTitleFormatterRef.keep_alphanumeric_and_chinese(text)

func _calculate_similarity(s1: String, s2: String) -> float:
    return ChoiceTitleFormatterRef.calculate_similarity(s1, s2)

func _calc_lcs_length(s1: String, s2: String) -> int:
    return ChoiceTitleFormatterRef.calc_lcs_length(s1, s2)

func _is_action_desc_duplicate(action_desc: String, sys_comment: String) -> bool:
    return ChoiceTitleFormatterRef.is_action_desc_duplicate(action_desc, sys_comment)

func _extract_actual_action_desc(raw_title: String, raw_desc: String) -> String:
    return ChoiceTitleFormatterRef.extract_actual_action_desc(raw_title, raw_desc)

func _disable_all_choice_buttons() -> void :
    if not is_instance_valid(choices_container):
        return
    for child in choices_container.get_children():
        _disable_buttons_recursive(child)

func _disable_buttons_recursive(node: Node) -> void :
    if node is Button:
        node.disabled = true
    for child in node.get_children():
        _disable_buttons_recursive(child)

func _on_choice_selected(index: int, is_risky: bool = false) -> void :
    if _choice_in_progress:
        return

    if Time.get_ticks_msec() < _choice_input_lock_until_ms:
        return
    if NativeMobileTouchScrollRef.should_suppress_press(self, "event_scroll_touch_drag_suppress_until_ms"):
        return
    var evt = GameState.get_current_event()
    if GameState.is_governance_mode():
        evt = GameState.get_month_card_event(governance_active_card_index)
    evt = evt.duplicate(true)
    _apply_current_city_placeholders(evt)
    if evt.is_empty():
        return
    var choices = evt.get("choices", [])
    if index >= choices.size():
        return

    _choice_in_progress = true
    _disable_all_choice_buttons()

    var ch = choices[index]
    if ch.get("dianshiRoll", false):
        _dianshi._show_dianshi_strategy_overlay(index, ch)
        return



    if ch.has("battle"):
        _launch_choice_battle(index, ch)
        return

    if is_risky or ch.has("pureChance"):
        _show_dice_overlay(index, ch)
        return

    _resolve_choice_internal(index, ch, false, false)


func _launch_choice_battle(index: int, ch: Dictionary) -> void :
    var cfg: Dictionary = (ch.get("battle", {}) as Dictionary).duplicate(true)
    if not cfg.has("title"):
        cfg["title"] = _split_choice_title(str(ch.get("title", "军阵交锋"))).get("line", "军阵交锋")

    if not cfg.has("player_units") and "bianwu_units" in GameState and not GameState.bianwu_units.is_empty():
        cfg["player_units"] = GameState.bianwu_units.duplicate()
    if not cfg.has("skills") and "bianwu_skills" in GameState and not GameState.bianwu_skills.is_empty():
        cfg["skills"] = GameState.bianwu_skills.duplicate()


    if cfg.has("ally_units"):
        var roster: Array = (cfg.get("player_units", []) as Array).duplicate()
        for au in (cfg["ally_units"] as Array):
            roster.append({"id": str(au), "ally": true})
        cfg["player_units"] = roster
        cfg.erase("ally_units")


    if GameData.active_line == "bianwu":
        var houqin: int = GameState.get_city_stat_level("houqin")
        var qingbao: int = GameState.get_city_stat_level("qingbao")
        if not cfg.has("intel"):
            cfg["intel"] = 0 if qingbao < 3 else (1 if qingbao < 7 else 2)
        if not cfg.has("ammo"):
            cfg["ammo"] = clampi(6 + int(round(houqin * 0.6)), 6, 14)
    var main = get_tree().current_scene
    if main == null or not main.has_method("request_battle"):
        _resolve_choice_internal(index, ch, false, false)
        return
    main.request_battle(cfg, func(grade: String): _on_choice_battle_done(index, ch, grade))

func _on_choice_battle_done(index: int, ch: Dictionary, grade: String) -> void :
    if GameData.active_line == "bianwu":
        var reward_zhanyi: = 0
        match grade:
            "great":
                reward_zhanyi = 8
            "fail":
                reward_zhanyi = -3
            _:
                reward_zhanyi = 3


        var merit_val: = int((ch.get("battle", {}) as Dictionary).get("merit", 0))
        if merit_val <= 0:
            merit_val = 100 + 100 * maxi(1, GameState.get_current_governance_act())
        var merit_gain: = 0
        match grade:
            "great":
                merit_gain = merit_val
            "fail":
                merit_gain = 0
            _:
                merit_gain = int(round(merit_val * 0.6))
        if (reward_zhanyi != 0 or merit_gain > 0) and GameState.city and not GameState.city.is_empty():
            if reward_zhanyi != 0:
                GameState.city["zhanyi"] = maxi(0, int(GameState.city.get("zhanyi", 0)) + reward_zhanyi)
            if merit_gain > 0:
                GameState.city["zhengji"] = int(GameState.city.get("zhengji", 0)) + merit_gain
            GameState.city = GameState.city.duplicate()
            GameState.state_changed.emit()

    match grade:
        "great": _resolve_choice_internal(index, ch, true, true)
        "fail": _resolve_choice_internal(index, ch, true, false)
        _: _resolve_choice_internal(index, ch, false, false)

func _resolve_choice_internal(index: int, ch: Dictionary, is_risky: bool, dice_won: bool, failed_keys: Array = []) -> void :
    var use_fail = is_risky and not dice_won
    var applied_ch = ch.duplicate(true)




    _showing_dianshi_memory_result = _is_dianshi_memory_event_context()
    if _showing_dianshi_memory_result:

        _dianshi_memory_turn_label = _get_topbar_turn_label()

    if use_fail:
        if ch.has("failEffects"): applied_ch["effects"] = ch["failEffects"]
        if ch.has("failTriggerEnding"):
            applied_ch["triggerEnding"] = ch["failTriggerEnding"]
        else:
            applied_ch.erase("triggerEnding")
        if ch.has("failEndingKey"):
            applied_ch["endingKey"] = ch["failEndingKey"]
        else:
            applied_ch.erase("endingKey")
        applied_ch.erase("startKeju")

        if ch.has("failMeritReward"):
            applied_ch["meritReward"] = ch["failMeritReward"]
        else:
            applied_ch.erase("meritReward")

        applied_ch.erase("grantUnits")
        applied_ch.erase("grantSkills")
        applied_ch.erase("upgradeUnit")
        if not ch.has("failKejuStatus"):
            applied_ch.erase("setKejuStatus")

        var fail_text = ch.get("failComment", "")
        if failed_keys.size() == 1:
            var fk = failed_keys[0]
            if fk == "wentao" and ch.has("failCommentWentao"):
                fail_text = ch["failCommentWentao"]
            elif fk == "tizhi" and ch.has("failCommentTizhi"):
                fail_text = ch["failCommentTizhi"]
            elif fk == "lizheng" and ch.has("failCommentLizheng"):
                fail_text = ch["failCommentLizheng"]
            elif fk == "wulue" and ch.has("failCommentWulue"):
                fail_text = ch["failCommentWulue"]
        elif failed_keys.size() > 1 and ch.has("failCommentBoth"):
            fail_text = ch["failCommentBoth"]

        if fail_text != "":
            applied_ch["systemComment"] = fail_text
            applied_ch["description"] = ""
            applied_ch["desc"] = ""

        if ch.has("failTags"): applied_ch["tags"] = ch["failTags"]
        if ch.has("failBranch"): applied_ch["enterBranch"] = ch["failBranch"]
        if ch.has("failGovernance"): applied_ch["enterGovernance"] = ch["failGovernance"]
        if ch.has("failKejuStatus"): applied_ch["setKejuStatus"] = ch["failKejuStatus"]
        if ch.has("failCounterKey"):
            var fail_counter_key: = str(ch.get("failCounterKey", ""))
            if fail_counter_key != "":
                var prev_fail_count: = int(GameState.keju_fail_counts.get(fail_counter_key, 0))
                var next_fail_count: = prev_fail_count + 1
                GameState.keju_fail_counts[fail_counter_key] = next_fail_count
                var fail_counter_limit: = int(ch.get("failCounterLimit", 0))
                var repeat_fail_triggered: = fail_counter_limit > 0 and next_fail_count >= fail_counter_limit
                if repeat_fail_triggered:
                    if ch.has("repeatFailEffects"): applied_ch["effects"] = ch["repeatFailEffects"]
                    if ch.has("repeatFailComment"): applied_ch["systemComment"] = ch["repeatFailComment"]
                    if ch.has("repeatFailTags"): applied_ch["tags"] = ch["repeatFailTags"]
                    if ch.has("repeatFailBranch"): applied_ch["enterBranch"] = ch["repeatFailBranch"]
                    if ch.has("repeatFailBranchIndex"): applied_ch["enterBranchIndex"] = ch["repeatFailBranchIndex"]
                    if ch.has("repeatFailGovernance"): applied_ch["enterGovernance"] = ch["repeatFailGovernance"]
                    if ch.has("repeatFailKejuStatus"): applied_ch["setKejuStatus"] = ch["repeatFailKejuStatus"]
                    if ch.has("repeatFailQueueBranch"):
                        if ch["repeatFailQueueBranch"] != "":
                            applied_ch["queueBranch"] = ch["repeatFailQueueBranch"]
                            if ch.has("repeatFailQueueBranchIndex"):
                                applied_ch["queueBranchIndex"] = ch["repeatFailQueueBranchIndex"]
                        else:
                            applied_ch.erase("queueBranch")
                            applied_ch.erase("queueBranchIndex")
                else:
                    var specific_fail_comment_key = "failComment" + str(next_fail_count)
                    if ch.has(specific_fail_comment_key):
                        applied_ch["systemComment"] = ch[specific_fail_comment_key]
                    if ch.has("failRetryDelayYears"):
                        var retry_status: = str(applied_ch.get("setKejuStatus", GameState.keju_status))
                        var retry_delay_years: = int(ch.get("failRetryDelayYears", 0))
                        if retry_status != "" and retry_delay_years > 0:
                            GameState.keju_next_exam_age[retry_status] = GameState.age + retry_delay_years
        if use_fail and ch.has("failQueueBranch"):
            if ch["failQueueBranch"] != "":
                applied_ch["queueBranch"] = ch["failQueueBranch"]
                if ch.has("failQueueBranchIndex"):
                    applied_ch["queueBranchIndex"] = ch["failQueueBranchIndex"]
                else:
                    applied_ch.erase("queueBranchIndex")
            else:


                applied_ch.erase("queueBranch")
                applied_ch.erase("queueBranchIndex")
        elif use_fail:


            applied_ch.erase("queueBranch")
            applied_ch.erase("queueBranchIndex")
    elif is_risky and dice_won:
        if ch.has("diceWinEffects"): applied_ch["effects"] = ch["diceWinEffects"]
        if ch.has("diceWinComment"): applied_ch["systemComment"] = ch["diceWinComment"]
        if ch.has("diceWinTags"): applied_ch["tags"] = ch["diceWinTags"]
        if ch.has("diceWinBranch"): applied_ch["enterBranch"] = ch["diceWinBranch"]
        if ch.has("diceWinQueueBranch"): applied_ch["queueBranch"] = ch["diceWinQueueBranch"]
        if ch.has("diceWinQueueBranchIndex"): applied_ch["queueBranchIndex"] = ch["diceWinQueueBranchIndex"]
        if ch.has("diceWinGovernance"): applied_ch["enterGovernance"] = ch["diceWinGovernance"]
        if ch.has("diceWinKejuStatus"): applied_ch["setKejuStatus"] = ch["diceWinKejuStatus"]

        if ch.has("diceWinGrantUnits"): applied_ch["grantUnits"] = ch["diceWinGrantUnits"]
        if ch.has("diceWinGrantSkills"): applied_ch["grantSkills"] = ch["diceWinGrantSkills"]
        if ch.has("diceWinUpgradeUnit"): applied_ch["upgradeUnit"] = ch["diceWinUpgradeUnit"]

    if applied_ch.get("queueBranch", "") == "keju" and applied_ch.get("comment", "") != "":
        var ks = GameState.keju_status
        if ks in ["zhuangyuan", "bangyan", "tanhua"]:
            applied_ch["comment"] = "吏部堂官抬起头来，多看了你一眼。一甲进士及第，放着翰林清贵不要，主动请缨外放。他提笔蘸墨，在你的名字旁重重画了个圈，末了搁笔叹了句：「倒是头一遭。」"
        elif ks == "erjia":
            applied_ch["comment"] = "吏部堂官翻了翻名册，顿了一下。二甲进士出身，本可留京观政、候选清要，你却要外放州县。他抬眼打量你片刻，没说什么，提笔在你名字旁画了个圈。"

    var old_rank = GameState.rank_index
    var old_keju = GameState.keju_status
    if GameState.is_governance_mode() and governance_active_card_index >= 0:
        pending_governance_completion_card_index = governance_active_card_index
    _begin_choice_result_panel_refresh_deferral()
    var choice_result = EffectsServiceRef.apply_choice(GameState, applied_ch, index)

    if GameState.is_governance_mode() and governance_active_card_index >= 0:
        EventServiceRef.finalize_month_card_choice(GameState, governance_active_card_index, applied_ch)
    _commit_choice_result_progress()
    var effects = choice_result.get("effects", {})



    var ekey = choice_result.get("ending_key", "")
    if ekey != "":
        var ending = GameData.endings.get(ekey, {})
        if not ending.is_empty():
            _cancel_choice_result_panel_refresh_deferral()
            game_ended.emit(ending)
            return

    for child in choices_container.get_children():
        child.queue_free()

    result_panel.visible = true
    mobile_event_phase = "result"
    if use_fail:
        result_title.text = "铩 羽 而 归"
    elif is_risky:
        result_title.text = "险 中 求 胜"
    else:
        result_title.text = "结 算"

    _clear_dynamic_chosen_choice()
    var raw_title: String = Presenter.resolve_text_placeholders(str(applied_ch.get("title", "")))


    var parts = _split_choice_title(raw_title)
    var tag_text = parts.get("tag", "").strip_edges()
    if tag_text != "":
        var desc_text = applied_ch.get("desc", applied_ch.get("description", ""))
        if desc_text == "":
            desc_text = parts.get("line", "")
        raw_title = "【" + tag_text + "】" + desc_text

    chosen_choice_title.visible = false
    var dynamic_row = _create_choice_title_row(raw_title)
    dynamic_row.name = "DynamicChosenChoiceRow_" + str(Time.get_ticks_msec())
    var chosen_choice_vbox = chosen_choice_title.get_parent()
    chosen_choice_vbox.add_child(dynamic_row)
    chosen_choice_vbox.move_child(dynamic_row, 0)

    chosen_choice_desc.text = ""
    _apply_chosen_choice_text_layout()



    var sys_comment: String = Presenter.resolve_text_placeholders(str(choice_result.get("system_comment", ""))).strip_edges()
    result_comment.text = sys_comment
    Presenter.populate_result_changes(result_changes_container, effects, _is_mobile_portrait())
    Presenter.populate_result_items(result_items_container, choice_result.get("granted_items", []), _is_mobile_portrait())
    Presenter.populate_result_guozuo(result_items_container, choice_result.get("granted_guozuo", []), _is_mobile_portrait())
    Presenter.populate_result_tags(result_tags_container, choice_result.get("tags", []), _is_mobile_portrait())
    result_tags_container.visible = Presenter.has_visible_tags(choice_result.get("tags", []))
    _apply_mobile_event_phase_visibility()
    NativeMobileFontScalerRef.apply_to(result_panel)





    NativeMobileFontScalerRef.reset_scaled_minimum_width(result_panel)
    _update_event_portrait_layout()
    _apply_chosen_choice_text_layout()
    _connect_scroll_drag_forwarders_recursive(result_panel, _on_event_scroll_touch_drag)
    _play_result_enter_animation(effects)






    await get_tree().process_frame

    _flush_choice_result_panel_refresh()

    if GameState.rank_index != old_rank:
        _show_rank_up_toast(GameState.get_rank_title())

    if GameState.keju_status != old_keju and not GameState.keju_status in ["none", "tongshi_prep", "xianshi_prep"]:
        var jinshi_ranks = ["zhuangyuan", "bangyan", "tanhua", "erjia", "sanjia"]
        if GameState.keju_status == "jinshi" and old_keju in jinshi_ranks:
            pass
        else:
            var keju_display = "平民"
            if GameState.keju_status == "zhuangyuan": keju_display = "状元及第"
            elif GameState.keju_status == "bangyan": keju_display = "榜眼及第"
            elif GameState.keju_status == "tanhua": keju_display = "探花及第"
            elif GameState.keju_status == "erjia": keju_display = "二甲进士"
            elif GameState.keju_status == "sanjia": keju_display = "三甲同进士"
            elif GameState.keju_status == "jinshi": keju_display = "进士"
            elif GameState.keju_status == "gongshi": keju_display = "贡士"
            elif GameState.keju_status == "juren": keju_display = "举人"
            elif GameState.keju_status == "xiucai": keju_display = "秀才"
            elif GameState.keju_status == "tongshi": keju_display = "童生"
            _show_keju_toast(keju_display)


    await get_tree().process_frame
    await get_tree().process_frame
    _scroll_event_to_result_button()

func _scroll_event_to_result_button() -> void :
    if not is_instance_valid(event_scroll) or not is_instance_valid(next_button):
        return
    var v_bar: = event_scroll.get_v_scroll_bar()
    var max_scroll: = maxf(0.0, v_bar.max_value - event_scroll.size.y)
    var target_scroll: = float(event_scroll.scroll_vertical)
    var scroll_rect: = event_scroll.get_global_rect()
    var button_rect: = next_button.get_global_rect()
    var bottom_gap: = MOBILE_EVENT_RESULT_BUTTON_BOTTOM_GAP if _is_mobile_portrait() else EVENT_RESULT_BUTTON_BOTTOM_GAP
    var desired_bottom: = scroll_rect.position.y + scroll_rect.size.y - bottom_gap
    if button_rect.end.y > desired_bottom:
        target_scroll += button_rect.end.y - desired_bottom
    var top_gap: = bottom_gap
    var desired_top: = scroll_rect.position.y + top_gap
    if button_rect.position.y < desired_top:
        target_scroll -= desired_top - button_rect.position.y
    target_scroll = clampf(target_scroll, 0.0, max_scroll)
    var duration: = 0.36 if absf(target_scroll - float(event_scroll.scroll_vertical)) > 1.0 else 0.12
    var t: = create_tween()
    t.tween_property(event_scroll, "scroll_vertical", target_scroll, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _clamp_event_result_scroll_bottom() -> void :
    if not is_instance_valid(event_scroll) or not is_instance_valid(result_panel) or not is_instance_valid(next_button):
        return
    if not event_scroll.visible or not result_panel.visible or not next_button.visible:
        return
    var scroll_rect: = event_scroll.get_global_rect()
    var button_rect: = next_button.get_global_rect()
    if scroll_rect.size.y <= 0.0 or button_rect.size.y <= 0.0:
        return
    var bottom_gap: = MOBILE_EVENT_RESULT_BUTTON_BOTTOM_GAP if _is_mobile_portrait() else EVENT_RESULT_BUTTON_BOTTOM_GAP
    var desired_bottom: = scroll_rect.position.y + scroll_rect.size.y - bottom_gap
    var extra_blank: = desired_bottom - button_rect.end.y
    if extra_blank <= 1.0:
        return
    event_scroll.scroll_vertical = maxi(0, event_scroll.scroll_vertical - int(ceil(extra_blank)))

func _show_dice_overlay(index: int, ch: Dictionary, allow_reroll: bool = true) -> void :
    _dice_overlay_controller.show_dice_overlay(index, ch, allow_reroll)

func _show_dice_confirm_button(vbox: VBoxContainer, overlay: ColorRect, index: int, ch: Dictionary, success: bool, failed_keys: Array, allow_reroll: bool = false) -> void :
    _dice_overlay_controller.show_dice_confirm_button(vbox, overlay, index, ch, success, failed_keys, allow_reroll)

func _make_dice_reroll_button(overlay: ColorRect, index: int, ch: Dictionary) -> Button:
    return _dice_overlay_controller.make_dice_reroll_button(overlay, index, ch)

func _commit_dice_overlay(overlay: ColorRect, index: int, ch: Dictionary, success: bool, failed_keys: Array) -> void :
    _dice_overlay_controller.commit_dice_overlay(overlay, index, ch, success, failed_keys)

func _show_rank_up_toast(rank_name: String) -> void :
    _transition_toast_controller.show_rank_up_toast(rank_name)

func _center_transient_toast(toast: Control) -> void :
    _transition_toast_controller.center_transient_toast(toast)

func _show_keju_toast(keju_name: String) -> void :
    _transition_toast_controller.show_keju_toast(keju_name)

func _show_stage_transition(title: String, sub: String, callback: Callable) -> void :
    _prepare_act_transition_surface()
    _transition_toast_controller.show_stage_transition(title, sub, callback)

func _consume_pending_act_transition() -> Dictionary:
    var pending = GameState.get_meta("pending_act_transition", {})
    if typeof(pending) != TYPE_DICTIONARY or pending.is_empty():
        return {}
    GameState.set_meta("pending_act_transition", {})
    return pending

func _show_act_transition_narrative(pending: Dictionary, callback: Callable) -> void :
    _transition_toast_controller.show_act_transition_narrative(pending, callback)

func _make_act_transition_background_gradient() -> TextureRect:
    return _transition_toast_controller.make_act_transition_background_gradient()

func _make_act_transition_orange_glow(center: Vector2, radius_to: Vector2, color: Color) -> TextureRect:
    return _transition_toast_controller.make_act_transition_orange_glow(center, radius_to, color)

func _split_nonempty_paragraphs(text: String) -> Array[String]:
    return _transition_toast_controller.split_nonempty_paragraphs(text)

func _add_transition_reward_panel(parent: VBoxContainer, item_id: String, replacements: Dictionary = {}) -> void :
    _transition_toast_controller.add_transition_reward_panel(parent, item_id, replacements)

func _consume_governance_completion_card_index() -> int:
    var card_index: = pending_governance_completion_card_index
    if card_index < 0 and GameState.is_governance_mode() and governance_active_card_index >= 0:
        card_index = governance_active_card_index
    pending_governance_completion_card_index = -1
    return card_index

func _commit_choice_result_progress() -> void :
    var completion_card_index: = _consume_governance_completion_card_index()
    if completion_card_index >= 0:
        _mark_month_card_for_settle(completion_card_index)
        GameState.complete_month_card(completion_card_index, false)
        governance_active_card_index = -1
        if GameState.in_prison and GameState.prison_index < 0:

            GameState.prison_index = 0
        pending_result_progress_committed = true
        return
    GameState.advance_event()
    pending_result_progress_committed = true

func _on_next_pressed() -> void :

    if Time.get_ticks_msec() < _choice_input_lock_until_ms:
        return
    _choice_input_lock_until_ms = Time.get_ticks_msec() + CHOICE_INPUT_LOCK_MS
    if pending_result_progress_committed:
        pending_result_progress_committed = false

        _showing_dianshi_memory_result = false
        _dianshi_memory_turn_label = ""
        if GameState.get_meta("prison_just_exited", false):
            GameState.set_meta("prison_just_exited", false)
            _serve_prison_term_and_return()
            return
        if GameState.is_governance_mode():
            _show_governance_overview()
            _schedule_month_advance_after_settle()
        else:
            _show_current_event()
        return
    var completion_card_index: = _consume_governance_completion_card_index()
    if completion_card_index >= 0:
        _mark_month_card_for_settle(completion_card_index)
        GameState.complete_month_card(completion_card_index, false)
        governance_active_card_index = -1
        if GameState.in_prison and GameState.prison_index < 0:
            GameState.prison_index = 0
        if GameState.is_governance_mode():
            _show_governance_overview()
            _schedule_month_advance_after_settle()
        else:
            _show_current_event()
        return
    GameState.advance_event()
    if GameState.get_meta("prison_just_exited", false):
        GameState.set_meta("prison_just_exited", false)
        _serve_prison_term_and_return()
        return
    _show_current_event()



const PRISON_TERM_MONTHS: = 4

func _serve_prison_term_and_return() -> void :
    if GameState.is_governance_mode():
        for _i in range(PRISON_TERM_MONTHS):
            if not GameState.is_governance_mode():
                break
            EventServiceRef.advance_month(GameState)
    _show_governance_overview(true)


func _setup_shezhi_tab_icon() -> void :
    if shezhi_tab == null:
        return
    shezhi_tab.text = ""
    shezhi_tab.tooltip_text = "设置"
    if _shezhi_gear == null:
        _shezhi_gear = GearIcon.new()

        _shezhi_gear.set_anchors_preset(Control.PRESET_FULL_RECT)
        shezhi_tab.add_child(_shezhi_gear)


func _setup_top_overview_button() -> void :
    _build_top_right_actions()


func _top_status_hbox() -> HBoxContainer:
    if not is_instance_valid(top_bar):
        return null
    var m: = top_bar.get_node_or_null("MarginContainer")
    if m == null:
        return null
    if m.has_node("TopBarVBox/HBox"):
        return m.get_node("TopBarVBox/HBox") as HBoxContainer
    if m.has_node("HBox"):
        return m.get_node("HBox") as HBoxContainer
    return null


func _make_top_pill_button(label: String, on_press: Callable) -> Button:
    var btn: = Button.new()
    btn.text = label
    btn.custom_minimum_size = Vector2(60, 24)
    btn.focus_mode = Control.FOCUS_NONE
    btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    btn.add_theme_font_override("font", FontLoader.body())
    btn.add_theme_font_size_override("font_size", 13)
    btn.add_theme_color_override("font_color", _left_panel_text_color("text_main"))
    btn.add_theme_color_override("font_hover_color", GameState.get_theme_color("border_active"))
    btn.add_theme_stylebox_override("normal", _make_zhisu_pill_button_style(false))
    btn.add_theme_stylebox_override("hover", _make_zhisu_pill_button_style(true))
    btn.add_theme_stylebox_override("pressed", _make_zhisu_pill_button_style(true))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    btn.pressed.connect(on_press)
    return btn


func _build_top_right_actions() -> HBoxContainer:
    var hbox: = _top_status_hbox()
    if hbox == null:
        return null
    var group: = hbox.get_node_or_null("TopRightActions") as HBoxContainer
    if group != null:
        return group
    group = HBoxContainer.new()
    group.name = "TopRightActions"
    group.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    group.add_theme_constant_override("separation", 8)
    var overview_btn: = _make_top_pill_button("总览", func():
        if _overview_panel_controller != null:
            _overview_panel_controller.show_overview_panel())
    overview_btn.name = "TopOverviewButton"
    group.add_child(overview_btn)
    group.add_child(_make_top_pill_button("存档", _on_save_pressed))
    group.add_child(_make_top_pill_button("读档", _on_load_pressed))
    hbox.add_child(group)
    return group


func _ensure_archive_tags_divider() -> Control:
    if not is_instance_valid(archive_section):
        return null
    var vbox: = archive_section.get_parent()
    if vbox == null:
        return null
    var margin: = vbox.get_node_or_null("ArchiveTagsDividerMargin") as MarginContainer
    if margin == null:
        margin = MarginContainer.new()
        margin.name = "ArchiveTagsDividerMargin"
        margin.add_theme_constant_override("margin_top", 10)
        margin.add_theme_constant_override("margin_bottom", 4)
        var new_div: = HSeparator.new()
        new_div.name = "ArchiveTagsDivider"
        var s: = StyleBoxLine.new()
        s.thickness = 1
        new_div.add_theme_stylebox_override("separator", s)
        margin.add_child(new_div)
        vbox.add_child(margin)
    vbox.move_child(margin, archive_section.get_index() + 1)
    var div: = margin.get_node("ArchiveTagsDivider") as HSeparator
    if div != null:
        var sbox: = div.get_theme_stylebox("separator") as StyleBoxLine
        if sbox != null:
            sbox.color = GameState.get_theme_color("border_weak")
    return margin


func _ensure_top_rank_divider() -> VSeparator:
    var hbox: = _top_status_hbox()
    if hbox == null:
        return null
    var div: = hbox.get_node_or_null("TopRankDivider") as VSeparator
    if div == null:
        div = VSeparator.new()
        div.name = "TopRankDivider"
        div.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        div.custom_minimum_size = Vector2(2, 18)
        var s: = StyleBoxLine.new()
        s.vertical = true
        s.color = Color(0.72, 0.66, 0.58, 0.28)
        s.thickness = 1
        s.grow_begin = -2
        s.grow_end = -2
        div.add_theme_stylebox_override("separator", s)
        hbox.add_child(div)
    return div


func _ensure_top_right_spacer() -> Control:
    var hbox: = _top_status_hbox()
    if hbox == null:
        return null
    var sp: = hbox.get_node_or_null("RightSpacer") as Control
    if sp == null:
        sp = Control.new()
        sp.name = "RightSpacer"
        sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        hbox.add_child(sp)
    return sp


func _apply_desktop_top_bar_layout() -> void :
    var hbox: = _top_status_hbox()
    if hbox == null:
        return

    if is_instance_valid(top_location) and top_location.has_node("ZhisuOverviewButton"):
        var legacy: = top_location.get_node("ZhisuOverviewButton")
        top_location.remove_child(legacy)
        legacy.queue_free()
    var divider: = _ensure_top_rank_divider()
    _ensure_top_right_spacer()
    _build_top_right_actions()

    if is_instance_valid(topbar_rank) and topbar_rank.get_parent() != hbox:
        topbar_rank.get_parent().remove_child(topbar_rank)
        hbox.add_child(topbar_rank)
    if is_instance_valid(resource_bar) and resource_bar.get_parent() != hbox:
        resource_bar.get_parent().remove_child(resource_bar)
        hbox.add_child(resource_bar)
    resource_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    resource_bar.alignment = BoxContainer.ALIGNMENT_CENTER
    topbar_rank.alignment = HORIZONTAL_ALIGNMENT_LEFT

    var spacer: = hbox.get_node_or_null("Spacer")
    var right_spacer: = hbox.get_node_or_null("RightSpacer")
    var right_actions: = hbox.get_node_or_null("TopRightActions")
    var ordered: = [top_location, divider, topbar_rank, spacer, resource_bar, right_spacer, right_actions]
    var idx: = 0
    for node in ordered:
        if node != null and is_instance_valid(node) and node.get_parent() == hbox:
            hbox.move_child(node, idx)
            idx += 1
    if divider != null:
        divider.visible = not _is_dianshi_memory_event_context()
    if right_spacer != null:
        right_spacer.visible = true
    if right_actions != null:
        right_actions.visible = true


func _update_top_location() -> void :
    if not is_instance_valid(top_location) or not is_instance_valid(location_label):
        return

    if _is_dianshi_memory_event_context():
        top_location.visible = not _is_mobile_portrait()
        top_location_button.visible = false
        location_label.text = "科举"
        location_label.add_theme_font_override("font", FontLoader.serif_bold())
        location_label.add_theme_color_override("font_color", _chrome_color("text_main"))
        return


    var is_final_volume = false
    var cur_event = GameState.get_current_event()
    if cur_event != null:
        var stage_str = str(cur_event.get("stage", ""))
        var active_branch = GameState.active_pending_event.get("branch", GameState.branch) if not GameState.active_pending_event.is_empty() else GameState.branch
        if stage_str.contains("终卷") or int(cur_event.get("year", 0)) == 17 or active_branch in ["zhongchen", "bifan", "xiaoxiong", "xinghuo"]:
            is_final_volume = true

    if GameState.branch in ["zhongchen", "bifan", "xiaoxiong", "xinghuo"]:
        is_final_volume = true

    if is_final_volume:
        top_location.visible = not _is_mobile_portrait()
        top_location_button.visible = false
        location_label.text = "终卷·尘埃渐落"
        location_label.add_theme_font_override("font", FontLoader.serif_bold())
        location_label.add_theme_color_override("font_color", _chrome_color("text_main"))
        return

    if GameState.city.is_empty():
        top_location.visible = false
        top_location_button.visible = false
        return
    top_location.visible = not _is_mobile_portrait()
    top_location_button.visible = false

    var city_name: = str(GameState.city.get("name", "治所"))
    var province: = str(GameState.city.get("province", ""))
    var title_text: = city_name
    if province != "" and not city_name.begins_with(province):
        title_text = "%s · %s" % [province, city_name]
    location_label.text = title_text
    location_label.add_theme_font_override("font", FontLoader.serif_bold())
    location_label.add_theme_color_override("font_color", _chrome_color("text_main"))


func _build_shezhi_pane() -> void :
    if shezhi_info_container == null:
        return
    for child in shezhi_info_container.get_children():
        child.queue_free()

    _shezhi_save_btn = _make_shezhi_button("存档", _on_save_pressed)
    shezhi_info_container.add_child(_shezhi_save_btn)
    _shezhi_load_btn = _make_shezhi_button("读档", _on_load_pressed)
    shezhi_info_container.add_child(_shezhi_load_btn)

    var shezhi_music_row: = _make_game_settings_popup_text_toggle_row("音乐", "开" if GameState.sound_on else "关", _on_music_text_toggle_pressed)
    _shezhi_music_text_row = shezhi_music_row
    shezhi_info_container.add_child(shezhi_music_row)

    var shezhi_ui_row: = _make_game_settings_popup_text_toggle_row("界面大小", "大" if _is_effective_large_ui_mode() else "普通", _on_ui_scale_text_toggle_pressed)
    _shezhi_ui_scale_text_row = shezhi_ui_row
    shezhi_info_container.add_child(shezhi_ui_row)

    if not OS.has_feature("web"):
        _shezhi_portrait_btn = _make_shezhi_button("立绘", func():
            _on_portrait_toggle_pressed()
            _refresh_shezhi_buttons())
        shezhi_info_container.add_child(_shezhi_portrait_btn)

    if OS.has_feature("web") or not (OS.get_name() in ["Android", "iOS"]):
        _shezhi_fullscreen_btn = _make_shezhi_button("全屏", func():
            _on_fullscreen_toggle()
            _refresh_shezhi_buttons())
        shezhi_info_container.add_child(_shezhi_fullscreen_btn)

    _shezhi_about_btn = _make_shezhi_button("关于游戏", _show_about_author_popup)
    shezhi_info_container.add_child(_shezhi_about_btn)

    _shezhi_restart_btn = _make_shezhi_button("重新开始", _on_restart_pressed)
    shezhi_info_container.add_child(_shezhi_restart_btn)
    _shezhi_exit_btn = _make_shezhi_button("退出游戏", _show_exit_game_confirm_popup)
    shezhi_info_container.add_child(_shezhi_exit_btn)

    if shezhi_panel:
        var shezhi_style = shezhi_panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
        if shezhi_style:
            shezhi_style.border_color.a = 0.05
            shezhi_panel.add_theme_stylebox_override("panel", shezhi_style)

    _refresh_shezhi_buttons()
    _connect_shezhi_scroll_drag_forwarders()

func _make_shezhi_button(label: String, on_press: Callable) -> Button:
    var btn: = Button.new()
    btn.text = label
    btn.custom_minimum_size = Vector2(0, 38)
    btn.add_theme_font_override("font", FontLoader.body())
    btn.add_theme_font_size_override("font_size", 14)
    var main_color: = Color(0.85, 0.75, 0.65, 1.0)
    btn.add_theme_color_override("font_color", main_color)
    btn.add_theme_color_override("font_hover_color", _chrome_color("border_active"))
    btn.add_theme_stylebox_override("normal", _topbar_button_style(false))
    btn.add_theme_stylebox_override("hover", _topbar_button_style(true))
    btn.add_theme_stylebox_override("pressed", _topbar_button_style(true))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    btn.pressed.connect(on_press)
    return btn

func _make_personal_stat_upgrade_button() -> Control:
    var row: = HBoxContainer.new()
    row.alignment = BoxContainer.ALIGNMENT_CENTER
    row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.custom_minimum_size.y = 30
    var btn: = Button.new()
    btn.name = "PersonalStatUpgradeButton"
    btn.text = "提升"
    btn.custom_minimum_size = Vector2(58, 18)
    btn.focus_mode = Control.FOCUS_NONE
    btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    btn.tooltip_text = "消耗识悟提升个人禀赋"
    btn.add_theme_font_override("font", FontLoader.body())
    btn.add_theme_font_size_override("font_size", 15)
    btn.add_theme_color_override("font_color", _left_panel_text_color("text_main"))
    btn.add_theme_color_override("font_hover_color", GameState.get_theme_color("border_active"))
    btn.add_theme_stylebox_override("normal", _make_zengyi_expand_button_style(false))
    btn.add_theme_stylebox_override("hover", _make_zengyi_expand_button_style(true))
    btn.add_theme_stylebox_override("pressed", _make_zengyi_expand_button_style(true))
    btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    btn.pressed.connect(_on_personal_stat_upgrade_pressed)
    row.add_child(btn)
    return row

func _on_personal_stat_upgrade_pressed() -> void :
    if NativeMobileTouchScrollRef.should_suppress_press(self, "jushi_scroll_touch_drag_suppress_until_ms"):
        return
    _show_lingwu_stat_popup()

func _make_game_settings_popup_button(label: String, on_press: Callable) -> Button:
    return SettingsPopupStyle.make_button(label, on_press)

func _rebuild_game_settings_popup_content() -> void :
    if settings_popup == null:
        return
    var vbox: = settings_popup.get_node_or_null("VBox") as VBoxContainer
    if vbox == null:
        return
    for child in vbox.get_children():
        vbox.remove_child(child)
        child.queue_free()

    vbox.add_child(SettingsPopupStyle.make_header("设置"))
    vbox.add_child(SettingsPopupStyle.make_header_separator())

    var save_popup_btn: = _make_game_settings_popup_button("存档", _on_save_pressed)
    vbox.add_child(save_popup_btn)
    var load_popup_btn: = _make_game_settings_popup_button("读档", _on_load_pressed)
    vbox.add_child(load_popup_btn)

    music_text_row = _make_game_settings_popup_text_toggle_row("音乐", "开" if GameState.sound_on else "关", _on_music_text_toggle_pressed)
    vbox.add_child(music_text_row)

    ui_scale_text_row = _make_game_settings_popup_text_toggle_row("界面大小", "大" if _is_effective_large_ui_mode() else "普通", _on_ui_scale_text_toggle_pressed)
    vbox.add_child(ui_scale_text_row)

    if not OS.has_feature("web"):
        portrait_toggle_btn = _make_game_settings_popup_button("立绘", func():
            _on_portrait_toggle_pressed()
            _refresh_game_settings_popup_buttons())
        vbox.add_child(portrait_toggle_btn)
    else:
        portrait_toggle_btn = null

    if OS.has_feature("web") or not (OS.get_name() in ["Android", "iOS"]):
        fullscreen_btn = _make_game_settings_popup_button("全屏", func():
            _on_fullscreen_toggle()
            _refresh_game_settings_popup_buttons())
        vbox.add_child(fullscreen_btn)
    else:
        fullscreen_btn = null

    about_author_btn = _make_game_settings_popup_button("关于游戏", _show_about_author_popup)
    vbox.add_child(about_author_btn)

    restart_btn = _make_game_settings_popup_button("重新开始", _on_restart_pressed)
    vbox.add_child(restart_btn)

    var exit_popup_btn: = _make_game_settings_popup_button("退出游戏", _show_exit_game_confirm_popup)
    vbox.add_child(exit_popup_btn)

    close_settings_btn = null

    _refresh_game_settings_popup_buttons()

func _make_game_settings_popup_text_toggle_row(label_text: String, value_text: String, on_press: Callable) -> Button:
    return SettingsPopupStyle.make_text_toggle_row(label_text, value_text, on_press)

func _show_exit_game_confirm_popup() -> void :
    var existing: = get_node_or_null("ExitGameConfirmOverlay")
    if existing:
        existing.queue_free()

    var overlay: = ColorRect.new()
    overlay.name = "ExitGameConfirmOverlay"
    overlay.color = Color(0, 0, 0, 0.58) if GameState.theme == "dark" else Color(0, 0, 0, 0.36)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.z_as_relative = false
    overlay.z_index = 1000
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.add_to_group("blocking_modal_overlay")
    overlay.gui_input.connect( func(event):
        if _is_primary_press_event(event):
            overlay.queue_free()
    )

    var mobile_portrait: = _is_mobile_portrait()
    var is_landscape_mobile: = _is_native_mobile_landscape()
    var viewport_size: = get_viewport_rect().size

    var center: = CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)

    var panel: = PanelContainer.new()
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    panel.gui_input.connect( func(event):
        if event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventScreenDrag:
            panel.get_viewport().set_input_as_handled()
    )
    var panel_style: = StyleBoxFlat.new()
    panel_style.bg_color = GameState.get_theme_color("bg_popup")
    panel_style.border_color = Color(0.42, 0.43, 0.44, 0.72)
    panel_style.set_border_width_all(1)
    panel_style.set_corner_radius_all(2)
    panel_style.shadow_color = Color(0, 0, 0, 0.6)
    panel_style.shadow_size = 18
    var panel_padding: = 20 if is_landscape_mobile else (34 if mobile_portrait else 28)
    panel_style.content_margin_left = panel_padding
    panel_style.content_margin_right = panel_padding
    panel_style.content_margin_top = panel_padding
    panel_style.content_margin_bottom = panel_padding
    panel.add_theme_stylebox_override("panel", panel_style)
    var panel_w: float
    if is_landscape_mobile:
        panel_w = minf(viewport_size.x * 0.68, 520.0)
    elif mobile_portrait:
        panel_w = viewport_size.x * 0.84
    else:
        panel_w = minf(viewport_size.x * 0.42, 480.0)
    panel.custom_minimum_size = Vector2(panel_w, 0)

    var vbox: = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 12 if is_landscape_mobile else (20 if mobile_portrait else 14))

    var title: = Label.new()
    title.text = "退出游戏"
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", 22 if is_landscape_mobile else (MOBILE_GAME_MODAL_TITLE_FONT_SIZE if mobile_portrait else 20))
    title.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)

    var desc: = Label.new()
    desc.text = "确定要退出游戏吗？"
    desc.add_theme_font_override("font", FontLoader.body())
    desc.add_theme_font_size_override("font_size", 16 if is_landscape_mobile else (MOBILE_GAME_MODAL_BODY_FONT_SIZE if mobile_portrait else 14))
    desc.add_theme_color_override("font_color", GameState.get_theme_color("text_desc"))
    desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(desc)

    var buttons: = HBoxContainer.new()
    buttons.alignment = BoxContainer.ALIGNMENT_CENTER
    buttons.add_theme_constant_override("separation", 10 if is_landscape_mobile else (18 if mobile_portrait else 12))

    var cancel_btn: = Button.new()
    cancel_btn.text = "取消"
    cancel_btn.focus_mode = Control.FOCUS_NONE
    cancel_btn.custom_minimum_size = Vector2(120.0 if not mobile_portrait else 220.0, 42.0 if not mobile_portrait else MOBILE_GAME_MODAL_ACTION_HEIGHT)
    cancel_btn.add_theme_font_override("font", FontLoader.body())
    cancel_btn.add_theme_font_size_override("font_size", 16 if is_landscape_mobile else (MOBILE_GAME_MODAL_ACTION_FONT_SIZE if mobile_portrait else 16))
    var cancel_pad_x: = 24 if mobile_portrait else 18
    var cancel_pad_y: = 12 if mobile_portrait else 8
    GameScreenStyleFactory.apply_command_button_style(cancel_btn, "secondary", cancel_pad_x, cancel_pad_y)
    cancel_btn.pressed.connect( func():
        overlay.queue_free()
    )
    buttons.add_child(cancel_btn)

    var confirm_btn: = Button.new()
    confirm_btn.text = "退出游戏"
    confirm_btn.focus_mode = Control.FOCUS_NONE
    confirm_btn.custom_minimum_size = Vector2(120.0 if not mobile_portrait else 220.0, 42.0 if not mobile_portrait else MOBILE_GAME_MODAL_ACTION_HEIGHT)
    confirm_btn.add_theme_font_override("font", FontLoader.body())
    confirm_btn.add_theme_font_size_override("font_size", 16 if is_landscape_mobile else (MOBILE_GAME_MODAL_ACTION_FONT_SIZE if mobile_portrait else 16))
    GameScreenStyleFactory.apply_command_button_style(confirm_btn, "primary", cancel_pad_x, cancel_pad_y)
    confirm_btn.pressed.connect( func():
        get_tree().quit()
    )
    buttons.add_child(confirm_btn)

    vbox.add_child(buttons)
    panel.add_child(vbox)
    center.add_child(panel)
    overlay.add_child(center)
    add_child(overlay)
    NativeMobileFontScalerRef.apply_to(overlay)

func _make_game_exit_confirm_button_box(bg: Color) -> StyleBoxFlat:
    var box: = StyleBoxFlat.new()
    box.bg_color = bg
    box.set_border_width_all(0)
    box.set_corner_radius_all(2)
    box.content_margin_left = 18
    box.content_margin_right = 18
    box.content_margin_top = 8
    box.content_margin_bottom = 8
    return box


func _refresh_shezhi_buttons() -> void :
    _update_text_toggle_row(_shezhi_music_text_row, "开" if GameState.sound_on else "关")
    _update_text_toggle_row(_shezhi_ui_scale_text_row, "大" if _is_effective_large_ui_mode() else "普通")
    if _shezhi_portrait_btn:
        _shezhi_portrait_btn.text = "隐藏立绘" if GameState.event_portraits_enabled else "显示立绘"
    if _shezhi_fullscreen_btn:
        _shezhi_fullscreen_btn.text = "退出全屏" if _is_fullscreen_active() else "网页全屏"

func _refresh_game_settings_popup_buttons() -> void :
    _update_text_toggle_row(music_text_row, "开" if GameState.sound_on else "关")
    _update_text_toggle_row(ui_scale_text_row, "大" if _is_effective_large_ui_mode() else "普通")
    if fullscreen_btn:
        fullscreen_btn.text = "退出全屏" if _is_fullscreen_active() else "网页全屏"
    if portrait_toggle_btn:
        portrait_toggle_btn.text = "隐藏立绘" if GameState.event_portraits_enabled else "显示立绘"
    _sync_landscape_size_button_text()
    _refresh_shezhi_buttons()

func _show_settings_popup() -> void :
    if settings_popup:
        _rebuild_game_settings_popup_content()
        if theme_btn:
            theme_btn.text = "主题：浅色" if GameState.theme == "light" else "主题：深色"
        _refresh_game_settings_popup_buttons()
        settings_popup.visible = true
        _update_settings_popup_layout(_is_mobile_portrait())

func _on_shezhi_tab_pressed() -> void :
    _show_settings_popup()
    if shezhi_tab:
        _apply_tab_style(shezhi_tab, true)

func _hide_settings_popup() -> void :
    if settings_popup:
        settings_popup.visible = false
    if shezhi_tab:
        _apply_tab_style(shezhi_tab, false)

func _show_about_author_popup() -> void :
    _settings_popup_controller.show_about_author_popup()

func _is_blocking_modal_open() -> bool:
    if settings_popup and settings_popup.visible:
        return true
    for overlay in get_tree().get_nodes_in_group("blocking_modal_overlay"):
        if overlay is CanvasItem and overlay.is_visible_in_tree():
            return true
    var main = get_tree().root.get_node_or_null("Main")
    if main:
        var save_modal = main.get_node_or_null("ContentRoot/SaveModal")
        if save_modal:
            return save_modal.visible
    return false

func _on_theme_toggle_pressed() -> void :
    GameState.toggle_theme()
    if theme_btn:
        theme_btn.text = "主题：浅色" if GameState.theme == "light" else "主题：深色"

func _sync_portrait_toggle_button_text() -> void :
    if portrait_toggle_btn:
        portrait_toggle_btn.text = "隐藏立绘" if GameState.event_portraits_enabled else "显示立绘"

func _on_portrait_toggle_pressed() -> void :
    GameState.set_event_portraits_enabled( !GameState.event_portraits_enabled)
    _sync_portrait_toggle_button_text()
    _update_event_portrait_layout()
    _apply_game_background_mask()
    _sync_speaker_header_text_colors()

func _show_theme_select_popup() -> void :
    _settings_popup_controller.show_theme_select_popup()

func _on_save_pressed() -> void :
    var main = get_tree().root.get_node_or_null("Main")
    if main:
        var save_modal = main.get_node_or_null("ContentRoot/SaveModal")
        if save_modal:
            save_modal.open_save_mode()
            _hide_settings_popup()

func _on_load_pressed() -> void :
    var main = get_tree().root.get_node_or_null("Main")
    if main:
        var save_modal = main.get_node_or_null("ContentRoot/SaveModal")
        if save_modal:
            save_modal.open_load_mode()
            _hide_settings_popup()

func _on_restart_pressed() -> void :
    _hide_settings_popup()
    restart_requested.emit()

func _on_music_toggle() -> void :
    GameState.set_music( !GameState.sound_on)
    _refresh_music_button()

func _on_music_text_toggle_pressed() -> void :
    GameState.set_music( !GameState.sound_on)
    _refresh_music_button()
    _refresh_game_settings_popup_buttons()

func _on_ui_scale_text_toggle_pressed() -> void :
    _set_large_ui_mode( not _is_effective_large_ui_mode())
    _refresh_game_settings_popup_buttons()

func _on_fullscreen_toggle() -> void :
    var should_enter: = not _is_fullscreen_active()
    if OS.has_feature("web"):
        _toggle_web_fullscreen(should_enter)
    else:
        _toggle_native_fullscreen(should_enter)
    fullscreen_was_active = should_enter
    _refresh_fullscreen_button()

func _toggle_native_fullscreen(should_enter: bool) -> void :
    if should_enter:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _toggle_web_fullscreen(should_enter: bool) -> void :
    if should_enter:
        _request_browser_fullscreen()
    else:
        _exit_browser_fullscreen()

func _request_browser_fullscreen() -> void :
    if not OS.has_feature("web"):
        return
    JavaScriptBridge.eval("\n\t(() => {\n\t\tif (window.__czEnterFullscreen) {\n\t\t\twindow.__czEnterFullscreen();\n\t\t\treturn;\n\t\t}\n\t\tconst target = document.documentElement || document.getElementById('canvas');\n\t\tif (!document.fullscreenElement && target && target.requestFullscreen) {\n\t\t\ttarget.requestFullscreen().catch(() => {});\n\t\t}\n\t})();\n\t"\
\
\
\
\
\
\
\
\
\
\
)

func _exit_browser_fullscreen() -> void :
    if not OS.has_feature("web"):
        return
    JavaScriptBridge.eval("\n\t(() => {\n\t\tif (window.__czExitFullscreen) {\n\t\t\twindow.__czExitFullscreen();\n\t\t\treturn;\n\t\t}\n\t\tif (document.fullscreenElement && document.exitFullscreen) {\n\t\t\tdocument.exitFullscreen().catch(() => {});\n\t\t}\n\t})();\n\t"\
\
\
\
\
\
\
\
\
\
)

func _is_fullscreen_active() -> bool:
    if OS.has_feature("web"):
        return bool(JavaScriptBridge.eval("Boolean(document.fullscreenElement)"))
    var mode: = DisplayServer.window_get_mode()
    if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
        return true
    return false

func _refresh_fullscreen_button() -> void :
    if not is_instance_valid(fullscreen_btn):
        return
    fullscreen_btn.text = "退出全屏" if _is_fullscreen_active() else "网页全屏"
    fullscreen_btn.visible = OS.has_feature("web") or not (OS.get_name() in ["Android", "iOS"])



func _on_left_tab_clicked(tab_id: String) -> void :
    if tab_id != "shezhi" and _sidebar_collapse_supported()\
and not _bw_sidebar_collapsed and tab_id == current_left_tab:
        _set_bw_sidebar_collapsed(true, false)
        return
    _switch_left_tab(tab_id)

func _switch_left_tab(tab_id: String) -> void :
    if tab_id == "shezhi":
        _on_shezhi_tab_pressed()
        return

    if _bw_sidebar_collapsed:
        _set_bw_sidebar_collapsed(false, false)
    if tab_id == "buqu" and GameData.active_line != "bianwu":
        tab_id = "zhisu"
    if tab_id == "jushi" and GameData.active_line == "bianwu" and not _is_mobile_portrait():
        tab_id = "zhisu"
    current_left_tab = tab_id
    zhisu_pane.visible = tab_id == "zhisu"
    buqu_pane.visible = tab_id == "buqu"
    zengyi_pane.visible = tab_id == "zengyi"
    jushi_pane.visible = tab_id == "jushi"
    dangan_pane.visible = tab_id == "dangan"
    daoju_pane.visible = tab_id == "daoju"
    lingwu_pane.visible = tab_id == "lingwu"
    if shezhi_pane:
        shezhi_pane.visible = false
    _apply_tab_style(zhisu_tab, tab_id == "zhisu")
    _apply_tab_style(buqu_tab, tab_id == "buqu")
    _apply_tab_style(zengyi_tab, tab_id == "zengyi")
    _apply_tab_style(jushi_tab, tab_id == "jushi")
    _apply_tab_style(dangan_tab, tab_id == "dangan")
    _apply_tab_style(daoju_tab, tab_id == "daoju")
    _apply_tab_style(lingwu_tab, tab_id == "lingwu")
    if shezhi_tab:
        _apply_tab_style(shezhi_tab, settings_popup != null and settings_popup.visible)
    _apply_mobile_tab_page_mode()
    _sync_mobile_tab_labels()
    if tab_id == "daoju" and is_instance_valid(items_scroll):
        items_scroll.set_deferred("scroll_vertical", 0)
    if tab_id == "lingwu":
        _refresh_lingwu_panel()
        if is_instance_valid(lingwu_scroll):
            lingwu_scroll.set_deferred("scroll_vertical", 0)
    _update_items_expand_button()
    _position_bw_sidebar_collapse_button()
    if _bianwu_ap_floating:
        _position_bianwu_ap_float()
    elif _action_points_portrait_active:
        _position_ap_portrait_overlay()

func _queue_responsive_layout() -> void :
    _responsive_layout_controller.queue_layout()

func _apply_responsive_layout_after_resize() -> void :
    _responsive_layout_controller.apply_after_resize()

func _apply_responsive_layout() -> void :
    _responsive_layout_controller.apply()

func _refresh_content_for_responsive_change() -> void :
    _responsive_layout_controller.refresh_content_for_responsive_change()

func _get_responsive_window_size() -> Vector2:
    return _responsive_layout_controller.get_window_size()

func _get_native_safe_area_insets() -> Rect2i:
    if not (OS.has_feature("android") or OS.has_feature("ios")):
        return Rect2i()
    var viewport_size: = get_viewport_rect().size
    var window_size: = Vector2(DisplayServer.window_get_size())
    var safe_area: = DisplayServer.get_display_safe_area()
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0 or window_size.x <= 0.0 or window_size.y <= 0.0:
        return Rect2i()
    if safe_area.size.x <= 0 or safe_area.size.y <= 0:
        return Rect2i()
    var scale_x: = viewport_size.x / window_size.x
    var scale_y: = viewport_size.y / window_size.y
    var left: = maxi(0, int(round(float(safe_area.position.x) * scale_x)))
    var top: = maxi(0, int(round(float(safe_area.position.y) * scale_y)))
    var right: = maxi(0, int(round(float(window_size.x - safe_area.position.x - safe_area.size.x) * scale_x)))
    var bottom: = maxi(0, int(round(float(window_size.y - safe_area.position.y - safe_area.size.y) * scale_y)))
    return Rect2i(left, top, right, bottom)





func _get_safe_area_horizontal_insets() -> Vector2:
    if OS.has_feature("web"):
        return _get_web_safe_area_horizontal_insets()
    if OS.has_feature("android") or OS.has_feature("ios"):
        var insets: = _get_native_safe_area_insets()
        return Vector2(float(insets.position.x), float(insets.size.x))
    return Vector2.ZERO

func _get_web_safe_area_horizontal_insets() -> Vector2:
    var js: = "\n(() => {\n\tconst probe = document.createElement('div');\n\tprobe.style.cssText = 'position:fixed;top:0;left:0;padding-left:env(safe-area-inset-left);padding-right:env(safe-area-inset-right);visibility:hidden;pointer-events:none;';\n\tdocument.body.appendChild(probe);\n\tconst style = getComputedStyle(probe);\n\tconst left = parseFloat(style.paddingLeft) || 0;\n\tconst right = parseFloat(style.paddingRight) || 0;\n\tprobe.remove();\n\treturn JSON.stringify({ l: left, r: right });\n})()\n"











    var raw = JavaScriptBridge.eval(js)
    if raw == null:
        return Vector2.ZERO
    var parsed = JSON.parse_string(str(raw))
    if not (parsed is Dictionary):
        return Vector2.ZERO
    var css_left: = float(parsed.get("l", 0.0))
    var css_right: = float(parsed.get("r", 0.0))
    if css_left <= 0.0 and css_right <= 0.0:
        return Vector2.ZERO

    var window_size: = _get_responsive_window_size()
    var viewport_width: = get_viewport_rect().size.x
    var scale: = 1.0
    if window_size.x > 0.0 and viewport_width > 0.0:
        scale = viewport_width / window_size.x
    return Vector2(maxf(0.0, css_left * scale), maxf(0.0, css_right * scale))


func _apply_safe_area_horizontal_insets() -> void :
    var main_vbox: = get_node_or_null("MainVBox") as Control
    if main_vbox == null:
        return
    main_vbox.offset_left = 0
    main_vbox.offset_right = 0

func _is_mobile_portrait() -> bool:
    var window_size: = _get_responsive_window_size()
    return window_size.y > window_size.x
func _is_native_mobile_landscape() -> bool:
    return NativeMobileFontScalerRef.is_native_phone_landscape(self)

func _is_native_tablet_landscape() -> bool:
    return NativeMobileFontScalerRef.is_native_tablet_landscape(self)

func _apply_mobile_portrait_layout() -> void :
    if current_left_tab in ["zhisu", "shezhi"]:
        _switch_left_tab("jushi")

    if shezhi_tab:
        shezhi_tab.visible = false
    if shezhi_spacer:
        shezhi_spacer.visible = false
    var desktop_actions: = save_btn.get_parent() as Control
    if desktop_actions:
        desktop_actions.visible = true
    var window_size: = _get_responsive_window_size()
    left_panel.visible = false
    mobile_info_panel.visible = true
    mobile_bottom_tabs.visible = true
    main_layout.add_theme_constant_override("separation", 0)
    center_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    center_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    mobile_info_panel.custom_minimum_size.y = clampf(window_size.y * MOBILE_INFO_PANEL_HEIGHT_RATIO, MOBILE_INFO_PANEL_MIN_HEIGHT, MOBILE_INFO_PANEL_MAX_HEIGHT)
    mobile_info_host.custom_minimum_size.y = MOBILE_INFO_HOST_MIN_HEIGHT
    mobile_bottom_tabs.custom_minimum_size.y = MOBILE_BOTTOM_TAB_HEIGHT
    mobile_bottom_tabs.add_theme_constant_override("separation", 0)
    if not mobile_bottom_tabs.has_node("LeftMargin"):
        var left_margin = Control.new()
        left_margin.name = "LeftMargin"
        left_margin.custom_minimum_size = Vector2(MOBILE_CONTENT_SIDE_MARGIN, 0)
        mobile_bottom_tabs.add_child(left_margin)
        mobile_bottom_tabs.move_child(left_margin, 0)
        var right_margin = Control.new()
        right_margin.name = "RightMargin"
        right_margin.custom_minimum_size = Vector2(MOBILE_CONTENT_SIDE_MARGIN, 0)
        mobile_bottom_tabs.add_child(right_margin)

    var main_vbox = mobile_bottom_tabs.get_parent()
    if not main_vbox.has_node("MobileBottomTopSpacer"):
        var top_spacer = Control.new()
        top_spacer.name = "MobileBottomTopSpacer"
        top_spacer.custom_minimum_size = Vector2(0, MOBILE_BOTTOM_TAB_TOP_GAP)
        top_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        main_vbox.add_child(top_spacer)
        main_vbox.move_child(top_spacer, mobile_bottom_tabs.get_index())
    else:
        var top_spacer: = main_vbox.get_node("MobileBottomTopSpacer") as Control
        top_spacer.visible = true
        top_spacer.custom_minimum_size = Vector2(0, MOBILE_BOTTOM_TAB_TOP_GAP)
    if mobile_bottom_tabs.has_node("LeftMargin"):
        var left_margin: = mobile_bottom_tabs.get_node("LeftMargin") as Control
        left_margin.custom_minimum_size = Vector2(MOBILE_CONTENT_SIDE_MARGIN, 0)
    if mobile_bottom_tabs.has_node("RightMargin"):
        var right_margin: = mobile_bottom_tabs.get_node("RightMargin") as Control
        right_margin.custom_minimum_size = Vector2(MOBILE_CONTENT_SIDE_MARGIN, 0)
    if not main_vbox.has_node("MobileBottomSpacer"):
        var spacer = Control.new()
        spacer.name = "MobileBottomSpacer"
        spacer.custom_minimum_size = Vector2(0, MOBILE_BOTTOM_TAB_BOTTOM_GAP + float(_get_native_safe_area_insets().size.y))
        spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        main_vbox.add_child(spacer)
    else:
        var spacer: = main_vbox.get_node("MobileBottomSpacer") as Control
        spacer.visible = true
        spacer.custom_minimum_size = Vector2(0, MOBILE_BOTTOM_TAB_BOTTOM_GAP + float(_get_native_safe_area_insets().size.y))

    _move_side_panes_to(mobile_info_host)
    _apply_mobile_jushi_stats_layout()
    _apply_mobile_dangan_stats_layout()
    _apply_mobile_spacing()
    _apply_mobile_tab_page_mode()
    if _is_mobile_event_reading_active():
        _apply_mobile_immersive_event_reading(true)

func _apply_desktop_landscape_layout() -> void :
    top_bar.visible = true
    mobile_info_panel.visible = false
    mobile_bottom_tabs.visible = false
    main_layout.visible = true
    left_panel.visible = true
    stats_section.visible = true

    attitudes_section.visible = false
    main_layout.add_theme_constant_override("separation", 0)
    center_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    center_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    left_panel.custom_minimum_size.x = DESKTOP_LEFT_PANEL_WIDTH
    left_tabs.custom_minimum_size.x = DESKTOP_LEFT_TABS_WIDTH
    _reassert_bw_sidebar_collapsed_width()
    top_bar.custom_minimum_size.y = 0
    mobile_info_host.custom_minimum_size.y = 0
    mobile_bottom_tabs.custom_minimum_size.y = 52
    if main_layout.get_parent().has_node("MobileBottomTopSpacer"):
        main_layout.get_parent().get_node("MobileBottomTopSpacer").visible = false
    if main_layout.get_parent().has_node("MobileBottomSpacer"):
        main_layout.get_parent().get_node("MobileBottomSpacer").visible = false
    _move_side_panes_to(desktop_pane_stack)
    _apply_desktop_jushi_stats_layout(_is_final_volume_context())
    _apply_dangan_card_padding(false)
    _apply_desktop_spacing()

    if shezhi_tab:
        shezhi_tab.visible = true
    if shezhi_spacer:
        shezhi_spacer.visible = true
    var desktop_actions: = save_btn.get_parent() as Control
    if desktop_actions:
        desktop_actions.visible = false
    _apply_desktop_top_bar_layout()

func _move_side_panes_to(target: Control) -> void :
    _side_panel_layout_controller.move_side_panes_to(target)

func _update_settings_popup_layout(mobile_portrait: bool) -> void :
    if not settings_popup: return
    var is_landscape_mobile: = _is_native_mobile_landscape()
    var large_ui: = _is_effective_large_ui_mode()
    var scale_factor: = 1.2 if large_ui else 1.0
    if mobile_portrait:
        settings_popup.offset_left = -440.0 * scale_factor
        settings_popup.offset_right = 440.0 * scale_factor
        settings_popup.offset_top = -470.0 * scale_factor
        settings_popup.offset_bottom = 470.0 * scale_factor
    elif is_landscape_mobile:
        settings_popup.offset_left = -320.0 * scale_factor
        settings_popup.offset_right = 320.0 * scale_factor

        settings_popup.offset_top = -265.0 * scale_factor
        settings_popup.offset_bottom = 265.0 * scale_factor
    else:
        settings_popup.offset_left = -210.0 * scale_factor
        settings_popup.offset_right = 210.0 * scale_factor
        settings_popup.offset_top = -285.0 * scale_factor
        settings_popup.offset_bottom = 285.0 * scale_factor

    SettingsPopupStyle.apply_layout(settings_popup, settings_popup.get_node("VBox"), mobile_portrait, is_landscape_mobile, large_ui)

func _apply_settings_popup_dividers() -> void :
    if not settings_popup: return
    var vbox = settings_popup.get_node("VBox")
    if not vbox: return
    var large_ui: = _is_effective_large_ui_mode()
    var scale_factor: = 1.2 if large_ui else 1.0
    SettingsPopupStyle.apply_dividers(vbox, SettingsPopupStyle.divider_inset(_is_mobile_portrait(), _is_native_mobile_landscape()) * scale_factor)

func _apply_mobile_spacing() -> void :
    var center_margin: MarginContainer = $MainVBox / Layout / CenterPanel / CenterMargin

    center_margin.custom_minimum_size.x = 0
    center_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    var tight_margin: = int(MOBILE_CONTENT_SIDE_MARGIN / 2)
    var side_margin: = tight_margin
    if event_scroll.visible:
        var reading: = mobile_event_phase == "reading"
        side_margin = MOBILE_EVENT_IMMERSIVE_SIDE_MARGIN if reading else MOBILE_EVENT_READING_SIDE_MARGIN

    center_margin.add_theme_constant_override("margin_left", side_margin)
    center_margin.add_theme_constant_override("margin_top", 0)
    center_margin.add_theme_constant_override("margin_right", side_margin)
    center_margin.add_theme_constant_override("margin_bottom", 0)
    event_vbox.add_theme_constant_override("separation", 14)
    choices_container.add_theme_constant_override("separation", 18)
    governance_vbox.add_theme_constant_override("separation", 18)
    _sync_existing_border_widths()
    _apply_mobile_top_bar_spacing()
    stage_label.add_theme_font_size_override("font_size", MOBILE_EVENT_STAGE_FONT_SIZE)
    event_date_label.add_theme_font_size_override("font_size", MOBILE_EVENT_DATE_FONT_SIZE)
    event_date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    event_date_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    event_title_label.add_theme_font_size_override("font_size", MOBILE_EVENT_TITLE_FONT_SIZE)
    event_title_label.add_theme_font_override("font", MOBILE_EVENT_TITLE_BOLD_FONT)
    var title_group: = event_title_label.get_parent()
    if title_group is BoxContainer:
        title_group.add_theme_constant_override("separation", MOBILE_EVENT_DATE_TITLE_GAP)
    speaker_avatar.custom_minimum_size = Vector2(MOBILE_EVENT_AVATAR_SIZE, MOBILE_EVENT_AVATAR_SIZE)
    speaker_avatar.add_theme_font_size_override("font_size", MOBILE_EVENT_AVATAR_FONT_SIZE + 2)
    speaker_avatar.add_theme_font_override("font", MOBILE_EVENT_TITLE_BOLD_FONT)
    speaker_name.add_theme_font_size_override("font_size", MOBILE_EVENT_SPEAKER_NAME_FONT_SIZE)
    speaker_role.add_theme_font_size_override("font_size", MOBILE_EVENT_SPEAKER_TAG_FONT_SIZE)
    speaker_faction.add_theme_font_size_override("font_size", MOBILE_EVENT_SPEAKER_TAG_FONT_SIZE)
    visitor_bio_btn.add_theme_font_size_override("font_size", MOBILE_EVENT_SPEAKER_TAG_FONT_SIZE)
    visitor_bio_btn.custom_minimum_size = Vector2(38, 38)
    narrative_label.add_theme_font_size_override("font_size", MOBILE_EVENT_NARRATIVE_FONT_SIZE)
    narrative_label.add_theme_constant_override("line_spacing", 16)
    flavor_label.add_theme_font_size_override("font_size", MOBILE_EVENT_FLAVOR_FONT_SIZE)
    speaker_line.add_theme_font_size_override("font_size", MOBILE_EVENT_SPEAKER_LINE_FONT_SIZE)
    focus_label.add_theme_font_size_override("font_size", MOBILE_EVENT_FOCUS_FONT_SIZE)
    _apply_focus_panel_style()
    _apply_mobile_dialogue_narrative_spacing(true)
    _apply_mobile_focus_outer_spacing(true)
    _apply_mobile_reading_label_layout()
    chosen_choice_title.add_theme_font_size_override("font_size", MOBILE_RESULT_TITLE_FONT_SIZE)
    chosen_choice_desc.add_theme_font_size_override("font_size", MOBILE_RESULT_BODY_FONT_SIZE)
    _apply_chosen_choice_text_layout()
    result_title.add_theme_font_size_override("font_size", MOBILE_RESULT_TITLE_FONT_SIZE)
    result_comment.add_theme_font_size_override("font_size", MOBILE_RESULT_BODY_FONT_SIZE + 3)

    var settlement_box = result_title.get_parent().get_parent()
    if settlement_box is PanelContainer:
        var sbox_style = settlement_box.get_theme_stylebox("panel")
        if sbox_style and sbox_style is StyleBoxFlat:
            sbox_style.content_margin_left = 28
            sbox_style.content_margin_right = 28
            sbox_style.content_margin_top = 28
            sbox_style.content_margin_bottom = 28
            settlement_box.add_theme_stylebox_override("panel", sbox_style)
    var ccbox_style = chosen_choice_box.get_theme_stylebox("panel")
    if ccbox_style:
        ccbox_style.content_margin_left = 28
        ccbox_style.content_margin_right = 28
        ccbox_style.content_margin_top = 28
        ccbox_style.content_margin_bottom = 28
        chosen_choice_box.add_theme_stylebox_override("panel", ccbox_style)
    var next_button_spacer: = next_button.get_parent().get_node_or_null("MobileNextButtonSpacer") as Control
    if next_button_spacer == null:
        next_button_spacer = Control.new()
        next_button_spacer.name = "MobileNextButtonSpacer"
        next_button_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        next_button.get_parent().add_child(next_button_spacer)
        next_button.get_parent().move_child(next_button_spacer, next_button.get_index())
    else:
        next_button.get_parent().move_child(next_button_spacer, next_button.get_index())
    next_button_spacer.visible = _is_mobile_portrait()
    next_button_spacer.custom_minimum_size = Vector2(0, 18 if _is_mobile_portrait() else 0)
    next_button.add_theme_font_size_override("font_size", MOBILE_NEXT_BUTTON_FONT_SIZE)
    next_button.custom_minimum_size = Vector2(0, MOBILE_NEXT_BUTTON_HEIGHT)
    next_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _apply_side_pane_font_floor(MOBILE_SIDE_PANE_FONT_SIZE)
    _apply_mobile_detail_tab_typography()
    topbar_turn.visible = true
    topbar_turn.add_theme_font_size_override("font_size", MOBILE_TOP_STATUS_FONT_SIZE)
    topbar_turn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    topbar_turn.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    for action_btn in [save_btn, load_btn, settings_btn]:
        if action_btn:
            action_btn.visible = true
    if is_instance_valid(fullscreen_btn):
        fullscreen_btn.visible = OS.has_feature("web") or not (OS.get_name() in ["Android", "iOS"])
    _update_settings_popup_layout(true)

func _apply_mobile_tab_page_mode() -> void :
    if not _is_mobile_portrait():
        main_layout.visible = true
        return
    var is_detail_page: = current_left_tab != "jushi"
    main_layout.visible = not is_detail_page
    if is_detail_page:
        mobile_info_panel.visible = true
        mobile_info_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
        mobile_info_panel.custom_minimum_size.y = 0
        mobile_info_host.custom_minimum_size.y = 0

        mobile_info_margin.add_theme_constant_override("margin_left", MOBILE_EVENT_READING_SIDE_MARGIN)
        mobile_info_margin.add_theme_constant_override("margin_right", MOBILE_EVENT_READING_SIDE_MARGIN)
        mobile_info_margin.add_theme_constant_override("margin_top", 96)
        _apply_mobile_detail_tab_typography()
        _apply_mobile_detail_gradient_bg(true)
    else:
        mobile_info_panel.visible = false
        mobile_info_panel.size_flags_vertical = Control.SIZE_FILL
        mobile_info_panel.custom_minimum_size.y = 0
        mobile_info_host.custom_minimum_size.y = 0

        mobile_info_margin.add_theme_constant_override("margin_left", 14)
        mobile_info_margin.add_theme_constant_override("margin_right", 14)
        mobile_info_margin.add_theme_constant_override("margin_top", 0)
        _apply_mobile_detail_gradient_bg(false)

func _apply_desktop_spacing() -> void :
    var center_margin: MarginContainer = $MainVBox / Layout / CenterPanel / CenterMargin


    center_margin.custom_minimum_size.x = _desktop_center_min_width()
    center_margin.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

    center_margin.add_theme_constant_override("margin_left", 28)

    center_margin.add_theme_constant_override("margin_top", 6)
    center_margin.add_theme_constant_override("margin_right", 32)
    center_margin.add_theme_constant_override("margin_bottom", 4)
    event_vbox.add_theme_constant_override("separation", 16)
    choices_container.add_theme_constant_override("separation", 10)
    governance_vbox.add_theme_constant_override("separation", 16)
    _sync_existing_border_widths()
    _apply_desktop_top_bar_spacing()
    if left_content_margin:

        left_content_margin.add_theme_constant_override("margin_top", 20)
        left_content_margin.add_theme_constant_override("margin_bottom", 12)
    stage_label.add_theme_font_size_override("font_size", 12)
    event_date_label.add_theme_font_size_override("font_size", 15)
    event_date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    event_title_label.add_theme_font_size_override("font_size", 30)
    event_title_label.add_theme_font_override("font", MOBILE_EVENT_TITLE_BOLD_FONT)
    var title_group: = event_title_label.get_parent()
    if title_group is BoxContainer:
        title_group.add_theme_constant_override("separation", 4)
    speaker_avatar.custom_minimum_size = Vector2(40, 40)
    speaker_avatar.add_theme_font_size_override("font_size", 17)
    speaker_avatar.add_theme_font_override("font", MOBILE_EVENT_TITLE_BOLD_FONT)
    speaker_name.add_theme_font_size_override("font_size", 15)
    speaker_role.add_theme_font_size_override("font_size", 11)
    speaker_faction.add_theme_font_size_override("font_size", 11)
    visitor_bio_btn.add_theme_font_size_override("font_size", 14)
    visitor_bio_btn.custom_minimum_size = Vector2(24, 24)
    narrative_label.add_theme_font_size_override("font_size", 17)
    narrative_label.add_theme_constant_override("line_spacing", 0)
    flavor_label.add_theme_font_size_override("font_size", 15)
    speaker_line.add_theme_font_size_override("font_size", 15)
    focus_label.add_theme_font_size_override("font_size", 17)
    _apply_focus_panel_style()
    _apply_mobile_dialogue_narrative_spacing(false)
    _apply_mobile_focus_outer_spacing(false)
    _apply_desktop_reading_label_layout()
    chosen_choice_title.add_theme_font_size_override("font_size", 16)
    chosen_choice_desc.add_theme_font_size_override("font_size", 13)
    _apply_chosen_choice_text_layout()
    result_title.add_theme_font_size_override("font_size", 14)
    result_comment.add_theme_font_size_override("font_size", 16)

    governance_stage_label.add_theme_font_size_override("font_size", 12)


    var settlement_box = result_title.get_parent().get_parent()
    if settlement_box is PanelContainer:
        var sbox_style = settlement_box.get_theme_stylebox("panel")
        if sbox_style and sbox_style is StyleBoxFlat:
            sbox_style.content_margin_left = 16
            sbox_style.content_margin_right = 16
            sbox_style.content_margin_top = 16
            sbox_style.content_margin_bottom = 16
            settlement_box.add_theme_stylebox_override("panel", sbox_style)
    var ccbox_style = chosen_choice_box.get_theme_stylebox("panel")
    if ccbox_style:
        ccbox_style.content_margin_left = 16
        ccbox_style.content_margin_right = 16
        ccbox_style.content_margin_top = 16
        ccbox_style.content_margin_bottom = 16
        chosen_choice_box.add_theme_stylebox_override("panel", ccbox_style)
    next_button.add_theme_font_size_override("font_size", 16)
    next_button.custom_minimum_size = Vector2(300, 44)
    next_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    _apply_side_pane_font_size(13)
    _set_mobile_detail_titles_left_aligned(false)
    topbar_turn.visible = not GameState.is_governance_mode()
    for action_btn in [save_btn, load_btn, settings_btn]:
        if action_btn:
            action_btn.visible = true
    if is_instance_valid(fullscreen_btn):
        fullscreen_btn.visible = OS.has_feature("web") or not (OS.get_name() in ["Android", "iOS"])
    _update_settings_popup_layout(false)

func _apply_mobile_top_bar_spacing() -> void :

    var has_resources: = resource_bar.visible if resource_bar else false
    var base_top_bar_height: = MOBILE_TOP_BAR_HEIGHT_WITH_RESOURCES if has_resources else MOBILE_TOP_BAR_HEIGHT_NO_RESOURCES
    var safe_insets: = _get_native_safe_area_insets()
    top_bar.custom_minimum_size.y = base_top_bar_height + float(safe_insets.position.y)
    topbar_rank.custom_minimum_size = Vector2(0, 40)
    topbar_rank.add_theme_font_size_override("font_size", MOBILE_TOP_STATUS_FONT_SIZE)
    topbar_rank.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
    topbar_rank.alignment = HORIZONTAL_ALIGNMENT_RIGHT
    settings_btn.custom_minimum_size = Vector2(80, 40)
    settings_btn.add_theme_font_size_override("font_size", MOBILE_TOP_SETTINGS_FONT_SIZE)
    settings_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
    resource_bar.add_theme_constant_override("separation", 14)
    for label in [silver_label, grain_label, bingyong_label, pop_label, refugee_label]:
        label.add_theme_font_size_override("font_size", MOBILE_TOP_RESOURCE_FONT_SIZE)
        label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

    var top_margin_node: MarginContainer = top_bar.get_node("MarginContainer")

    var top_hbox: HBoxContainer
    if top_margin_node.has_node("TopBarVBox/HBox"):
        top_hbox = top_margin_node.get_node("TopBarVBox/HBox")
    elif top_margin_node.has_node("HBox"):
        top_hbox = top_margin_node.get_node("HBox")
    else:
        return


    if top_hbox:
        if top_location:
            top_location.visible = false

        var top_divider: = top_hbox.get_node_or_null("TopRankDivider") as Control
        if top_divider:
            top_divider.visible = false
        var top_right_spacer: = top_hbox.get_node_or_null("RightSpacer") as Control
        if top_right_spacer:
            top_right_spacer.visible = false
        var top_right_actions: = top_hbox.get_node_or_null("TopRightActions") as Control
        if top_right_actions:
            top_right_actions.visible = false
        var actions_node = settings_btn.get_parent() as HBoxContainer
        var spacer_node = top_hbox.get_node_or_null("Spacer") as Control
        if actions_node:
            actions_node.add_theme_constant_override("separation", MOBILE_TOP_ACTION_BUTTON_SEPARATION)
        if actions_node and actions_node.get_parent() == top_hbox:
            top_hbox.move_child(actions_node, 0)
        if spacer_node and spacer_node.get_parent() == top_hbox:
            top_hbox.move_child(spacer_node, 1)
        if topbar_rank and topbar_rank.get_parent() == top_hbox:
            top_hbox.move_child(topbar_rank, 2)


    if topbar_turn.get_parent() == top_hbox:
        top_hbox.remove_child(topbar_turn)


    var top_vbox: VBoxContainer
    if top_margin_node.has_node("TopBarVBox"):
        top_vbox = top_margin_node.get_node("TopBarVBox")
    else:
        top_vbox = VBoxContainer.new()
        top_vbox.name = "TopBarVBox"
        top_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        top_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
        top_vbox.add_theme_constant_override("separation", MOBILE_TOP_BAR_ROW_GAP)
        if top_hbox.get_parent() == top_margin_node:
            top_margin_node.remove_child(top_hbox)
        top_margin_node.add_child(top_vbox)
        top_vbox.add_child(top_hbox)

    top_vbox.add_theme_constant_override("separation", MOBILE_TOP_BAR_ROW_GAP)

    top_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    top_hbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    top_hbox.custom_minimum_size.y = MOBILE_TOP_BAR_HEIGHT_NO_RESOURCES

    var top_sep: HSeparator
    if top_vbox.has_node("TopBarSeparator"):
        top_sep = top_vbox.get_node("TopBarSeparator")
    else:
        top_sep = HSeparator.new()
        top_sep.name = "TopBarSeparator"
        var sep_style: = StyleBoxLine.new()
        sep_style.color = Color(0.72, 0.6, 0.36, 0.25)
        sep_style.thickness = 1
        top_sep.add_theme_stylebox_override("separator", sep_style)
        top_vbox.add_child(top_sep)
        top_vbox.move_child(top_sep, 1)
    top_sep.visible = false

    var res_margin: MarginContainer
    if top_vbox.has_node("ResourceBarMargin"):
        res_margin = top_vbox.get_node("ResourceBarMargin")
    else:
        res_margin = MarginContainer.new()
        res_margin.name = "ResourceBarMargin"
        res_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        res_margin.add_theme_constant_override("margin_bottom", 8)
        top_vbox.add_child(res_margin)

    if resource_bar.get_parent() == top_hbox:
        top_hbox.remove_child(resource_bar)
    if resource_bar.get_parent() != res_margin:
        if resource_bar.get_parent():
            resource_bar.get_parent().remove_child(resource_bar)
        res_margin.add_child(resource_bar)
    resource_bar.alignment = BoxContainer.ALIGNMENT_CENTER
    resource_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    resource_bar.mouse_filter = Control.MOUSE_FILTER_PASS




    if topbar_turn.get_parent() != top_margin_node:
        if topbar_turn.get_parent():
            topbar_turn.get_parent().remove_child(topbar_turn)
        top_margin_node.add_child(topbar_turn)
    topbar_turn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    topbar_turn.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    topbar_turn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    topbar_turn.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

    var first_row_h: = MOBILE_TOP_BAR_HEIGHT_NO_RESOURCES
    topbar_turn.custom_minimum_size = Vector2(0, first_row_h)
    topbar_turn.custom_minimum_size.y = first_row_h

    topbar_turn.mouse_filter = Control.MOUSE_FILTER_IGNORE

    top_margin_node.add_theme_constant_override("margin_left", MOBILE_TOP_BAR_SAFE_SIDE_MARGIN)
    top_margin_node.add_theme_constant_override("margin_right", MOBILE_TOP_BAR_SAFE_SIDE_MARGIN)
    top_margin_node.add_theme_constant_override("margin_top", safe_insets.position.y)

    top_bar.add_theme_stylebox_override("panel", _make_mobile_top_bar_gradient())

func _make_mobile_top_bar_gradient() -> StyleBoxTexture:
    var tex_style = StyleBoxTexture.new()
    var grad = Gradient.new()
    grad.colors = PackedColorArray([Color(0.01, 0.01, 0.01, 0.95), Color(0.01, 0.01, 0.01, 0.0)])
    var tex = GradientTexture2D.new()
    tex.gradient = grad
    tex.fill_from = Vector2(0.5, 0.0)
    tex.fill_to = Vector2(0.5, 1.0)
    tex_style.texture = tex
    return tex_style

func _apply_desktop_top_bar_spacing() -> void :
    top_bar.custom_minimum_size.y = 40
    topbar_rank.custom_minimum_size = Vector2(0, 28)
    topbar_rank.add_theme_font_size_override("font_size", 13)
    topbar_rank.alignment = HORIZONTAL_ALIGNMENT_LEFT
    settings_btn.custom_minimum_size = Vector2(0, 0)
    settings_btn.add_theme_font_size_override("font_size", 12)
    settings_btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
    topbar_turn.add_theme_font_size_override("font_size", 12)
    topbar_turn.custom_minimum_size = Vector2.ZERO
    topbar_turn.size_flags_vertical = Control.SIZE_FILL
    topbar_turn.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    topbar_turn.scale = Vector2.ONE
    resource_bar.add_theme_constant_override("separation", 16)
    for label in [silver_label, grain_label, bingyong_label, pop_label, refugee_label]:
        label.add_theme_font_size_override("font_size", 14)
        label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

    var top_margin_node: MarginContainer = top_bar.get_node("MarginContainer")
    top_margin_node.add_theme_constant_override("margin_left", 20)
    top_margin_node.add_theme_constant_override("margin_right", 20)
    top_margin_node.add_theme_constant_override("margin_top", 0)
    var top_hbox: HBoxContainer = top_margin_node.get_node("HBox") if top_margin_node.has_node("HBox") else null
    if top_hbox == null and top_margin_node.has_node("TopBarVBox/HBox"):
        top_hbox = top_margin_node.get_node("TopBarVBox/HBox")


    if top_hbox:
        top_hbox.custom_minimum_size.y = 0
        var actions_node = settings_btn.get_parent() as HBoxContainer
        var spacer_node = top_hbox.get_node_or_null("Spacer") as Control
        if actions_node:
            actions_node.add_theme_constant_override("separation", 6)
        if top_location and top_location.get_parent() == top_hbox:
            top_location.visible = true
            top_hbox.move_child(top_location, 0)
        if spacer_node and spacer_node.get_parent() == top_hbox:
            top_hbox.move_child(spacer_node, 1)
        if topbar_rank and topbar_rank.get_parent() == top_hbox:
            top_hbox.move_child(topbar_rank, 3)
        if actions_node and actions_node.get_parent() == top_hbox:
            top_hbox.move_child(actions_node, 4)

    if top_hbox and topbar_turn.get_parent() == top_hbox:
        top_hbox.remove_child(topbar_turn)

    if top_margin_node.has_node("TopBarVBox"):
        var top_vbox = top_margin_node.get_node("TopBarVBox")
        if top_hbox and top_hbox.get_parent() == top_vbox:
            top_vbox.remove_child(top_hbox)
            top_margin_node.add_child(top_hbox)
            top_margin_node.move_child(top_hbox, 0)
        if topbar_turn.get_parent() == top_vbox:
            top_vbox.remove_child(topbar_turn)
        if top_vbox.has_node("ResourceBarMargin"):
            var res_margin = top_vbox.get_node("ResourceBarMargin")
            if resource_bar.get_parent() == res_margin:
                res_margin.remove_child(resource_bar)
            res_margin.queue_free()
        elif resource_bar.get_parent() == top_vbox:
            top_vbox.remove_child(resource_bar)
        top_vbox.queue_free()

    if topbar_turn.get_parent() != top_margin_node:
        if topbar_turn.get_parent():
            topbar_turn.get_parent().remove_child(topbar_turn)
        top_margin_node.add_child(topbar_turn)
    topbar_turn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    topbar_turn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    topbar_turn.mouse_filter = Control.MOUSE_FILTER_STOP
    topbar_turn.custom_minimum_size = Vector2.ZERO
    topbar_turn.visible = false

    if resource_bar.get_parent() != top_margin_node:
        if resource_bar.get_parent():
            resource_bar.get_parent().remove_child(resource_bar)
        top_margin_node.add_child(resource_bar)
    resource_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    resource_bar.size_flags_vertical = Control.SIZE_FILL
    resource_bar.alignment = BoxContainer.ALIGNMENT_CENTER
    resource_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE

    if top_bar.has_theme_stylebox_override("panel"):
        top_bar.remove_theme_stylebox_override("panel")
        _apply_dynamic_theme()

func _apply_mobile_reading_label_layout() -> void :
    for label in [speaker_line, narrative_label, flavor_label, focus_label]:
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        label.clip_text = false
        label.custom_minimum_size.x = 0
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    speaker_bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    flavor_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    focus_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _apply_focus_panel_style() -> void :
    if focus_panel == null:
        return
    var focus_style: = StyleBoxFlat.new()
    focus_style.bg_color = Color(0, 0, 0, 0)
    focus_style.border_width_left = 0
    focus_style.border_width_right = 0
    focus_style.border_width_top = 0
    focus_style.border_width_bottom = 0
    focus_style.content_margin_left = 12
    focus_style.content_margin_right = 12
    focus_style.content_margin_top = 16
    focus_style.content_margin_bottom = 16
    focus_panel.add_theme_stylebox_override("panel", focus_style)
    if not focus_panel.draw.is_connected(_draw_focus_panel_lines):
        focus_panel.draw.connect(_draw_focus_panel_lines)
    focus_panel.queue_redraw()

func _draw_focus_panel_lines() -> void :
    if focus_panel == null or not is_instance_valid(focus_panel):
        return
    var w: = focus_panel.size.x
    var h: = focus_panel.size.y
    if w <= 0.0 or h <= 1.0:
        return
    var line_color: = GameState.get_theme_color("border_weak")
    var line_width: = float(_responsive_border_width())
    var line_offset: = line_width * 0.5
    focus_panel.draw_line(Vector2(0.0, line_offset), Vector2(w, line_offset), line_color, line_width, true)
    focus_panel.draw_line(Vector2(0.0, h - line_offset), Vector2(w, h - line_offset), line_color, line_width, true)

func _apply_mobile_dialogue_narrative_spacing(enabled: bool) -> void :
    var spacer: = event_vbox.get_node_or_null("MobileDialogueNarrativeSpacer") as Control
    if spacer == null:
        spacer = Control.new()
        spacer.name = "MobileDialogueNarrativeSpacer"
        spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        event_vbox.add_child(spacer)

    if spacer.get_parent() == event_vbox:
        event_vbox.move_child(spacer, narrative_label.get_index())

    var spacer_visible: = enabled and speaker_bubble.visible
    spacer.visible = spacer_visible
    spacer.custom_minimum_size = Vector2(0, 8 if spacer_visible else 0)

func _apply_mobile_focus_outer_spacing(enabled: bool) -> void :
    var top_spacer: = event_vbox.get_node_or_null("MobileFocusTopSpacer") as Control
    if top_spacer == null:
        top_spacer = Control.new()
        top_spacer.name = "MobileFocusTopSpacer"
        top_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        event_vbox.add_child(top_spacer)
    var bottom_spacer: = event_vbox.get_node_or_null("MobileFocusBottomSpacer") as Control
    if bottom_spacer == null:
        bottom_spacer = Control.new()
        bottom_spacer.name = "MobileFocusBottomSpacer"
        bottom_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        event_vbox.add_child(bottom_spacer)

    var focus_index: = focus_panel.get_index()
    if top_spacer.get_parent() == event_vbox:
        event_vbox.move_child(top_spacer, focus_index)
    if bottom_spacer.get_parent() == event_vbox:
        event_vbox.move_child(bottom_spacer, focus_panel.get_index() + 1)

    var spacer_visible: = enabled and focus_panel.visible
    top_spacer.visible = spacer_visible
    bottom_spacer.visible = spacer_visible
    top_spacer.custom_minimum_size = Vector2(0, 30 if spacer_visible else 0)
    bottom_spacer.custom_minimum_size = Vector2(0, 32 if spacer_visible else 0)

func _apply_desktop_reading_label_layout() -> void :
    for label in [speaker_line, narrative_label, flavor_label, focus_label]:
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        label.clip_text = false
        label.custom_minimum_size.x = 0
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        label.size_flags_vertical = Control.SIZE_FILL

func _apply_mobile_jushi_stats_layout() -> void :
    _side_panel_layout_controller.apply_mobile_jushi_stats_layout()

func _apply_mobile_dangan_stats_layout() -> void :
    _side_panel_layout_controller.apply_mobile_dangan_stats_layout()

func _apply_dangan_card_padding(mobile_portrait: bool) -> void :
    _side_panel_layout_controller.apply_dangan_card_padding(mobile_portrait)

func _get_mobile_jushi_stats_parent() -> VBoxContainer:
    return _side_panel_layout_controller.get_mobile_jushi_stats_parent()

func _remove_mobile_jushi_stats_margin_from(parent: VBoxContainer, keep_parent: VBoxContainer) -> void :
    _side_panel_layout_controller.remove_mobile_jushi_stats_margin_from(parent, keep_parent)

func _make_mobile_status_dashboard_style() -> StyleBoxFlat:
    return _side_panel_layout_controller.make_mobile_status_dashboard_style()

func _apply_desktop_jushi_stats_layout(is_final_volume: bool = false) -> void :
    _side_panel_layout_controller.apply_desktop_jushi_stats_layout(is_final_volume)

func _set_side_pane_title_row_layout(mobile_portrait: bool) -> void :
    _side_panel_layout_controller.set_side_pane_title_row_layout(mobile_portrait)

func _set_jushi_separators_visible(is_visible: bool) -> void :
    _side_panel_layout_controller.set_jushi_separators_visible(is_visible)

func _apply_side_pane_font_floor(min_font_size: int) -> void :
    _side_panel_layout_controller.apply_side_pane_font_floor(min_font_size)

func _apply_mobile_detail_tab_typography() -> void :
    _side_panel_layout_controller.apply_mobile_detail_tab_typography()

func _set_mobile_detail_titles_left_aligned(is_left_aligned: bool) -> void :
    _side_panel_layout_controller.set_mobile_detail_titles_left_aligned(is_left_aligned)

func _apply_mobile_detail_gradient_bg(show: bool) -> void :
    _side_panel_layout_controller.apply_mobile_detail_gradient_bg(show)

func _apply_side_pane_font_size(font_size: int) -> void :
    _side_panel_layout_controller.apply_side_pane_font_size(font_size)

func _mobile_font_size(desktop_size: int, mobile_size: int) -> int:
    return mobile_size if _is_mobile_portrait() else desktop_size

func _get_mobile_governance_content_width() -> float:
    var content_w: = get_viewport_rect().size.x
    return maxf(1.0, content_w - float(MOBILE_CONTENT_SIDE_MARGIN * 2))



func _get_bianwu_month_card_size() -> Vector2:
    var w: = roundf(_get_month_card_size().x * _bianwu_card_scale())
    return Vector2(w, roundf(w * BIANWU_EVENT_CARD_HEIGHT_RATIO))



func _bianwu_card_scale() -> float:
    if GameData.active_line != "bianwu":
        return 1.0
    if _is_mobile_portrait() or _is_native_mobile_landscape() or _is_native_tablet_landscape():
        return 1.0
    return BIANWU_DESKTOP_MONTH_CARD_SCALE


func _bianwu_card_scaled(value: float) -> int:
    return maxi(1, roundi(value * _bianwu_card_scale()))

func _get_month_card_size() -> Vector2:
    if _is_mobile_portrait():
        var cols: = 5.0
        var gap: = 6.0
        var available_w: = _get_mobile_governance_content_width()
        var natural_w: = floorf((available_w - gap * (cols - 1.0)) / cols)
        var expanded_w: = floorf(natural_w * MOBILE_MONTH_CARD_WIDTH_FILL_BONUS)
        var max_fit_w: = floorf((available_w - gap * (cols - 1.0)) / cols)
        var w: = minf(clampf(expanded_w, MOBILE_MONTH_CARD_MIN_WIDTH, MOBILE_MONTH_CARD_MAX_WIDTH), max_fit_w)
        var h: = clampf(w * MOBILE_MONTH_CARD_HEIGHT_RATIO, MOBILE_MONTH_CARD_MIN_HEIGHT, MOBILE_MONTH_CARD_MAX_HEIGHT)
        return Vector2(w, h)
    if _is_native_mobile_landscape():
        return _get_native_landscape_month_card_size()
    if _is_native_tablet_landscape():
        return _get_native_tablet_landscape_month_card_size()
    else:


        return Vector2(NATIVE_TABLET_LANDSCAPE_MONTH_CARD_WIDTH, NATIVE_TABLET_LANDSCAPE_MONTH_CARD_HEIGHT)

func _get_native_landscape_month_card_size() -> Vector2:
    var cols: = 5.0
    var gap: = float(NATIVE_LANDSCAPE_MONTH_CARD_GAP)
    var content_w: = maxf(1.0, _get_native_mobile_landscape_center_min_width() - 36.0)
    var fit_w: = floorf((content_w - gap * (cols - 1.0)) / cols)
    var target_w: = minf(NATIVE_LANDSCAPE_MONTH_CARD_WIDTH, fit_w)



    var base_w: = floorf(target_w / NativeMobileFontScalerRef.SCALE)
    var base_h: = floorf(base_w * NATIVE_LANDSCAPE_MONTH_CARD_HEIGHT / NATIVE_LANDSCAPE_MONTH_CARD_WIDTH)
    return Vector2(base_w, base_h)

func _get_native_tablet_landscape_month_card_size() -> Vector2:
    var cols: = 5.0
    var gap: = float(NATIVE_TABLET_LANDSCAPE_MONTH_CARD_GAP)
    var center_margin_w: = _desktop_center_min_width()
    var content_w: = maxf(1.0, center_margin_w - 60.0)
    var fit_w: = floorf((content_w - gap * (cols - 1.0)) / cols)
    var w: = minf(NATIVE_TABLET_LANDSCAPE_MONTH_CARD_WIDTH, maxf(NATIVE_TABLET_LANDSCAPE_MONTH_CARD_MIN_WIDTH, fit_w))
    var h: = roundf(w * NATIVE_TABLET_LANDSCAPE_MONTH_CARD_HEIGHT / NATIVE_TABLET_LANDSCAPE_MONTH_CARD_WIDTH)
    return Vector2(w, h)

func _get_mobile_game_modal_width(viewport_width: float) -> float:
    return clampf(viewport_width * MOBILE_GAME_MODAL_WIDTH_RATIO, MOBILE_GAME_MODAL_MIN_WIDTH, MOBILE_GAME_MODAL_MAX_WIDTH)

func _apply_font_floor_recursive(node: Node, min_font_size: int) -> void :
    if node is Label or node is Button:
        var control: = node as Control
        var current_size: = int(control.get_theme_font_size("font_size"))
        control.add_theme_font_size_override("font_size", maxi(current_size, min_font_size))
    for child in node.get_children():
        _apply_font_floor_recursive(child, min_font_size)

func _apply_font_size_recursive(node: Node, font_size: int) -> void :
    if node is Label or node is Button:
        var control: = node as Control
        control.add_theme_font_size_override("font_size", font_size)
    for child in node.get_children():
        _apply_font_size_recursive(child, font_size)


func _apply_native_mobile_font_scale() -> void :
    _sync_native_landscape_size_override()
    if not _is_native_mobile_landscape():
        NativeMobileFontScalerRef.reset_scaled_overrides(self)

        if attitudes_container:
            attitudes_container.add_theme_constant_override("separation", 18)
    if _is_native_tablet_landscape():
        _apply_native_tablet_landscape_desktop_layout()
        return
    NativeMobileFontScalerRef.reset_scaled_overrides(self)
    NativeMobileFontScalerRef.apply_to(self)
    _apply_native_mobile_landscape_compact_layout()



    NativeMobileFontScalerRef.reset_scaled_minimum_width(event_vbox)
    _update_event_portrait_layout()

    if action_points_value != null and is_instance_valid(action_points_value):
        _update_action_points_separator()
        _update_action_points_dots()
        call_deferred("_sync_action_points_card_alignment_after_layout")

func _apply_native_tablet_landscape_desktop_layout() -> void :
    if not _is_native_tablet_landscape():
        return

    var center_margin: MarginContainer = $MainVBox / Layout / CenterPanel / CenterMargin
    center_margin.custom_minimum_size.x = _desktop_center_min_width()
    center_margin.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    center_margin.add_theme_constant_override("margin_left", 28)
    center_margin.add_theme_constant_override("margin_right", 32)
    center_margin.add_theme_constant_override("margin_top", 4)
    center_margin.add_theme_constant_override("margin_bottom", 4)

    left_panel.custom_minimum_size.x = DESKTOP_LEFT_PANEL_WIDTH
    left_tabs.custom_minimum_size.x = DESKTOP_LEFT_TABS_WIDTH
    _reassert_bw_sidebar_collapsed_width()
    month_cards_container.add_theme_constant_override("h_separation", NATIVE_TABLET_LANDSCAPE_MONTH_CARD_GAP)
    month_cards_container.add_theme_constant_override("v_separation", 16)

func _apply_native_mobile_landscape_compact_layout() -> void :
    if not _is_native_mobile_landscape():
        return

    var center_margin: MarginContainer = $MainVBox / Layout / CenterPanel / CenterMargin
    center_margin.custom_minimum_size.x = _get_native_mobile_landscape_center_min_width()
    center_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    center_margin.add_theme_constant_override("margin_left", 18)
    center_margin.add_theme_constant_override("margin_right", 18)
    center_margin.add_theme_constant_override("margin_top", 2)
    center_margin.add_theme_constant_override("margin_bottom", 2)

    left_panel.custom_minimum_size.x = NATIVE_LANDSCAPE_LEFT_PANEL_WIDTH
    _reassert_bw_sidebar_collapsed_width()


    left_tabs.custom_minimum_size.x = NATIVE_LANDSCAPE_LEFT_TABS_WIDTH

    if left_content_margin:
        left_content_margin.add_theme_constant_override("margin_left", NATIVE_LANDSCAPE_LEFT_CONTENT_SIDE_MARGIN)
        left_content_margin.add_theme_constant_override("margin_right", int(NATIVE_LANDSCAPE_LEFT_CONTENT_SIDE_MARGIN * 0.6))
    month_cards_container.add_theme_constant_override("h_separation", NATIVE_LANDSCAPE_MONTH_CARD_GAP)
    month_cards_container.add_theme_constant_override("v_separation", 12)

    if attitudes_container:
        attitudes_container.add_theme_constant_override("separation", 0)
    _apply_native_mobile_landscape_zhisu_card_spacing()
    _apply_native_mobile_landscape_compact_top_bar()

func _apply_native_mobile_landscape_zhisu_card_spacing() -> void :
    if not _is_native_mobile_landscape():
        return
    if not is_instance_valid(zhisu_info_container):
        return
    zhisu_info_container.add_theme_constant_override("separation", 0)
    for margin_node in zhisu_info_container.get_children():
        var margin: = margin_node as MarginContainer
        if margin == null:
            continue
        margin.add_theme_constant_override("margin_top", 0)
        margin.add_theme_constant_override("margin_bottom", 0)
        if margin.get_child_count() <= 0:
            continue
        var card: = margin.get_child(0) as PanelContainer
        if card == null or not card.name.begins_with("ZhisuRowCard_"):
            continue
        card.custom_minimum_size.y = 50
        for child in card.get_children():
            var row: = child as HBoxContainer
            if row == null:
                continue
            row.custom_minimum_size.y = 43
            row.add_theme_constant_override("separation", 8)
            break

func _get_native_mobile_landscape_center_min_width() -> float:





    var insets: = _get_safe_area_horizontal_insets()
    var available: = get_viewport_rect().size.x - insets.x - insets.y - NATIVE_LANDSCAPE_LEFT_PANEL_WIDTH
    return maxf(NATIVE_LANDSCAPE_CENTER_MIN_WIDTH_FLOOR, available - NATIVE_LANDSCAPE_CENTER_SIDE_BUFFER)

func _apply_native_mobile_landscape_compact_top_bar() -> void :
    if not _is_native_mobile_landscape():
        return

    top_bar.custom_minimum_size.y = NATIVE_LANDSCAPE_TOP_BAR_HEIGHT
    topbar_rank.custom_minimum_size = Vector2(0, 36)
    topbar_rank.add_theme_font_size_override("font_size", 15)
    settings_btn.custom_minimum_size = Vector2(0, 36)
    settings_btn.add_theme_font_size_override("font_size", 14)
    topbar_turn.custom_minimum_size = Vector2.ZERO
    topbar_turn.add_theme_font_size_override("font_size", 14)
    resource_bar.add_theme_constant_override("separation", 16)
    for label in _get_top_resource_labels():
        if label:
            label.add_theme_font_size_override("font_size", 16)
            label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

    var top_margin_node: = top_bar.get_node("MarginContainer") as MarginContainer
    if top_margin_node:
        top_margin_node.add_theme_constant_override("margin_top", 0)
        top_margin_node.add_theme_constant_override("margin_bottom", 0)
        top_margin_node.add_theme_constant_override("margin_left", 56)
        top_margin_node.add_theme_constant_override("margin_right", 56)
    if left_content_margin:
        left_content_margin.add_theme_constant_override("margin_top", NATIVE_LANDSCAPE_LEFT_CONTENT_TOP_MARGIN)

    var top_hbox: HBoxContainer = null
    if top_margin_node:
        if top_margin_node.has_node("HBox"):
            top_hbox = top_margin_node.get_node("HBox") as HBoxContainer
        elif top_margin_node.has_node("TopBarVBox/HBox"):
            top_hbox = top_margin_node.get_node("TopBarVBox/HBox") as HBoxContainer
    if top_hbox:
        top_hbox.custom_minimum_size.y = 36

func _responsive_border_width() -> int:
    return MOBILE_BORDER_WIDTH if _is_mobile_portrait() else 1

func _apply_style_border_width(style: StyleBoxFlat, width: int) -> void :
    style.border_width_left = width
    style.border_width_top = width
    style.border_width_right = width
    style.border_width_bottom = width

func _sync_stylebox_border_width(control: Control, style_name: String, width: int) -> void :
    if not is_instance_valid(control):
        return
    var style = control.get_theme_stylebox(style_name)
    if style is StyleBoxFlat:
        _apply_style_border_width(style, width)
        control.add_theme_stylebox_override(style_name, style)

func _sync_existing_border_widths() -> void :
    var width: = _responsive_border_width()
    _sync_stylebox_border_width(speaker_avatar, "normal", width)
    _sync_stylebox_border_width(speaker_bubble, "panel", width)
    _sync_stylebox_border_width(chosen_choice_box, "panel", width)
    _sync_stylebox_border_width(zhisu_panel, "panel", width)
    _sync_stylebox_border_width(zengyi_panel, "panel", width)
    _sync_stylebox_border_width(stats_panel, "panel", width)
    _sync_stylebox_border_width(attitudes_panel, "panel", width)
    _sync_stylebox_border_width(archive_panel, "panel", width)
    _sync_stylebox_border_width(tags_panel, "panel", width)
    _sync_stylebox_border_width(items_panel, "panel", width)
    _sync_stylebox_border_width(shezhi_panel, "panel", width)

func _queue_mobile_pixel_snap() -> void :
    if mobile_pixel_snap_queued or not _is_mobile_portrait():
        return
    mobile_pixel_snap_queued = true
    call_deferred("_apply_mobile_pixel_snap_deferred")

func _apply_mobile_pixel_snap_deferred() -> void :
    if is_inside_tree():
        await get_tree().process_frame
    mobile_pixel_snap_queued = false
    if not is_inside_tree() or not _is_mobile_portrait():
        return
    _snap_control_tree_to_pixels(self)

func _snap_control_tree_to_pixels(node: Node) -> void :
    if node is Control:
        _snap_control_rect_to_pixels(node)
    for child in node.get_children():
        _snap_control_tree_to_pixels(child)

func _snap_control_rect_to_pixels(control: Control) -> void :
    if not control.visible:
        return
    if control is Button or control is PanelContainer or control is ColorRect:
        control.position = control.position.round()
        control.size = control.size.round()

func _sync_mobile_tab_labels() -> void :
    _mobile_bottom_tab_controller.sync_labels()

func _configure_mobile_bottom_tab_content(button: Button, label_text: String, icon_path: String, icon_key: String) -> void :
    _mobile_bottom_tab_controller.configure_content(button, label_text, icon_path, icon_key)

func _make_mobile_bottom_tab_texture(icon_path: String, icon_key: String) -> Texture2D:
    return _mobile_bottom_tab_controller.make_texture(icon_path, icon_key)

func _apply_dynamic_theme() -> void :
    if not _is_mobile_portrait():
        if GameState.theme == "dark":

            var top_style = StyleBoxFlat.new()
            top_style.bg_color = Color(0.045, 0.043, 0.038, 0.96)
            top_style.shadow_size = 8
            top_style.shadow_color = Color(0, 0, 0, 0.26)
            top_bar.add_theme_stylebox_override("panel", top_style)
        else:

            top_bar.add_theme_stylebox_override("panel", _make_chrome_gradient_style(true))


    if top_bar_underline:
        top_bar_underline.visible = not _is_mobile_portrait()
        top_bar_underline.color = Color(0.62, 0.55, 0.42, 0.55) if GameState.theme == "dark" else Color("a39271")


    if left_tabs_host:
        if GameState.theme == "dark":
            left_tabs_host.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
        else:
            var left_tab_bg: = StyleBoxFlat.new()
            left_tab_bg.bg_color = Color("20201d")
            left_tabs_host.add_theme_stylebox_override("panel", left_tab_bg)

    var left_style = left_panel.get_theme_stylebox("panel") as StyleBoxFlat
    if left_style:


        left_style.bg_color = Color(0.2, 0.2, 0.184314, 1.0) if GameState.theme == "light" else GameState.get_theme_color("bg_popup")
        left_style.border_width_right = 1
        left_style.border_color = Color(0.36, 0.3, 0.18, 1.0) if GameState.theme == "light" else GameState.get_theme_color("border_weak")
        left_style.shadow_size = 10 if GameState.theme == "dark" else 0
        left_style.shadow_color = Color(0, 0, 0, 0.28)


        left_style.content_margin_top = 0
        left_style.content_margin_bottom = 0

        var is_detail_gradient_active: = false
        if mobile_info_panel.has_theme_stylebox_override("panel"):
            is_detail_gradient_active = mobile_info_panel.get_theme_stylebox("panel") is StyleBoxTexture
        if not is_detail_gradient_active:

            var mobile_left_style: = left_style.duplicate()
            mobile_left_style.content_margin_top = 8
            mobile_left_style.content_margin_bottom = 8
            mobile_info_panel.add_theme_stylebox_override("panel", mobile_left_style)

    var center_style: = center_panel.get_theme_stylebox("panel") as StyleBoxFlat
    if center_style == null:
        center_style = StyleBoxFlat.new()
    center_style.bg_color = Color(0, 0, 0, 0) if GameState.theme == "light" or _is_dark_governance_overview_active() else Color(0.045, 0.043, 0.038, 0.56)
    center_style.border_width_left = 0
    center_style.border_width_right = 0
    center_style.border_width_top = 0
    center_style.border_width_bottom = 0
    center_style.shadow_size = 0
    center_panel.add_theme_stylebox_override("panel", center_style)

    _apply_shell_grain_layers()

    topbar_rank.add_theme_color_override("font_color", _chrome_color("text_main"))
    topbar_rank.add_theme_color_override("font_hover_color", _chrome_color("border_active"))
    topbar_rank.add_theme_stylebox_override("normal", _topbar_rank_style(false))
    topbar_rank.add_theme_stylebox_override("hover", _topbar_rank_style(true))
    topbar_rank.add_theme_stylebox_override("pressed", _topbar_rank_style(true))
    topbar_turn.add_theme_color_override("font_color", _chrome_color("text_sub"))
    for action_btn in [save_btn, load_btn]:
        if action_btn:
            action_btn.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
            action_btn.add_theme_color_override("font_hover_color", GameState.get_theme_color("border_active"))
            action_btn.add_theme_stylebox_override("normal", _topbar_button_style(false))
            action_btn.add_theme_stylebox_override("hover", _topbar_button_style(true))
            action_btn.add_theme_stylebox_override("pressed", _topbar_button_style(true))

    if settings_btn:
        settings_btn.add_theme_color_override("font_color", _chrome_color("text_main"))
        settings_btn.add_theme_color_override("font_hover_color", _chrome_color("border_active"))
        settings_btn.add_theme_stylebox_override("normal", _settings_button_style(false))
        settings_btn.add_theme_stylebox_override("hover", _settings_button_style(true))
        settings_btn.add_theme_stylebox_override("pressed", _settings_button_style(true))

    if settings_popup:
        var mobile_portrait: = _is_mobile_portrait()
        settings_popup.add_theme_stylebox_override("panel", SettingsPopupStyle.panel_style())

        for child in settings_popup.get_node("VBox").get_children():
            if child is Button:
                if child.name == "CloseSettingsButton":
                    var close_normal = StyleBoxFlat.new()
                    if GameState.theme == "light":
                        close_normal.bg_color = Color(0.94, 0.94, 0.94, 0.3)
                        close_normal.border_color = Color(0, 0, 0, 0)
                    else:
                        close_normal.bg_color = Color(0.18, 0.14, 0.12, 0.45)
                        close_normal.border_color = Color(0.3, 0.22, 0.18, 0.5)
                        close_normal.border_width_left = 1;close_normal.border_width_top = 1;close_normal.border_width_right = 1;close_normal.border_width_bottom = 1

                    close_normal.corner_radius_top_left = 3;close_normal.corner_radius_top_right = 3;close_normal.corner_radius_bottom_right = 3;close_normal.corner_radius_bottom_left = 3
                    close_normal.content_margin_left = 12;close_normal.content_margin_right = 12;close_normal.content_margin_top = 8;close_normal.content_margin_bottom = 8

                    var close_hover = close_normal.duplicate()
                    if GameState.theme == "light":
                        close_hover.bg_color = Color(0.88, 0.88, 0.88, 0.4)
                        close_hover.border_color = Color(0, 0, 0, 0)
                    else:
                        close_hover.bg_color = Color(0.22, 0.17, 0.15, 0.6)
                        close_hover.border_color = Color(0.38, 0.28, 0.24, 0.65)

                    var close_pressed = close_normal.duplicate()
                    if GameState.theme == "light":
                        close_pressed.bg_color = Color(0.82, 0.82, 0.82, 0.5)
                    else:
                        close_pressed.bg_color = Color(0.14, 0.11, 0.09, 0.55)

                    child.add_theme_stylebox_override("normal", close_normal)
                    child.add_theme_stylebox_override("hover", close_hover)
                    child.add_theme_stylebox_override("pressed", close_pressed)
                    child.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

                    var text_col: = Color(0.2, 0.18, 0.16, 1.0) if GameState.theme == "light" else Color(0.85, 0.75, 0.65, 1.0)
                    child.add_theme_color_override("font_color", text_col)
                    child.add_theme_color_override("font_hover_color", text_col.darkened(0.1) if GameState.theme == "light" else Color(0.95, 0.85, 0.75, 1.0))
                    child.add_theme_color_override("font_pressed_color", text_col.darkened(0.2) if GameState.theme == "light" else Color(0.75, 0.65, 0.55, 1.0))
                else:
                    child.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
                    var hover_col = GameState.get_theme_color("border_active")
                    if GameState.theme == "light":
                        hover_col = Color(0.58, 0.44, 0.18, 1.0)
                    child.add_theme_color_override("font_hover_color", hover_col)
                    if GameState.theme == "light":
                        var btn_normal = StyleBoxFlat.new()
                        btn_normal.bg_color = Color(0, 0, 0, 0)
                        var btn_hover = StyleBoxFlat.new()
                        btn_hover.bg_color = Color(0.96, 0.91, 0.78, 0.42)
                        btn_hover.border_width_left = 0
                        btn_hover.border_width_top = 0
                        btn_hover.border_width_right = 0
                        btn_hover.border_width_bottom = 0
                        child.add_theme_stylebox_override("normal", btn_normal)
                        child.add_theme_stylebox_override("hover", btn_hover)
                        child.add_theme_stylebox_override("pressed", btn_hover)
                    else:
                        child.add_theme_stylebox_override("normal", _topbar_button_style(false))
                        child.add_theme_stylebox_override("hover", _topbar_button_style(true))
                        child.add_theme_stylebox_override("pressed", _topbar_button_style(true))

        _update_settings_popup_layout(mobile_portrait)

    _normalize_top_resource_label_style()

    stage_label.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    event_date_label.add_theme_color_override("font_color", Color(0.58, 0.45, 0.2, 0.88))

    if GameState.theme == "light":
        event_title_label.add_theme_color_override("font_color", Color(0.34, 0.21, 0.1, 1.0))
    else:
        event_title_label.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    title_rule.modulate = GameState.get_theme_color("border_med")
    _sync_speaker_header_text_colors()

    var avatar_style = speaker_avatar.get_theme_stylebox("normal")
    if avatar_style and avatar_style is StyleBoxFlat:
        avatar_style.bg_color = Color(0.055, 0.047, 0.038, 1.0) if GameState.theme == "dark" else Color(0.105, 0.092, 0.072, 1.0)
        avatar_style.border_color = GameState.get_theme_color("border_strong")
        avatar_style.shadow_size = 8 if GameState.theme == "dark" else 0
        avatar_style.shadow_color = Color(0, 0, 0, 0.28 if GameState.theme == "dark" else 0.0)
        speaker_avatar.add_theme_stylebox_override("normal", avatar_style)

    var bubble_style = speaker_bubble.get_theme_stylebox("panel")
    if bubble_style and bubble_style is StyleBoxFlat:
        bubble_style.bg_color = Color(0.06, 0.052, 0.043, 0.98) if GameState.theme == "dark" else Color(0.075, 0.066, 0.054, 0.97)
        bubble_style.border_color = GameState.get_theme_color("border_med")
        bubble_style.shadow_size = 10 if GameState.theme == "dark" else 0
        bubble_style.shadow_color = Color(0, 0, 0, 0.3 if GameState.theme == "dark" else 0.0)
        speaker_bubble.add_theme_stylebox_override("panel", bubble_style)

    var box_style = chosen_choice_box.get_theme_stylebox("panel")
    if not (box_style is StyleBoxFlat):
        box_style = StyleBoxFlat.new()
        box_style.corner_radius_top_left = 2;box_style.corner_radius_top_right = 2;box_style.corner_radius_bottom_right = 2;box_style.corner_radius_bottom_left = 2
        box_style.content_margin_left = 16;box_style.content_margin_top = 16;box_style.content_margin_right = 16;box_style.content_margin_bottom = 16

    box_style.bg_color = _choice_card_bg_color() if _choice_card_uses_light_dark_style() else GameState.get_theme_color("choice_normal")
    box_style.border_color = _result_card_border_color()
    box_style.shadow_size = 10 if GameState.theme == "dark" else 0
    box_style.shadow_color = Color(0, 0, 0, 0.34 if GameState.theme == "dark" else 0.0)
    _apply_style_border_width(box_style, _responsive_border_width())

    var use_gradient = GameState.theme == "dark" or _choice_card_uses_light_dark_style()
    chosen_choice_box.add_theme_stylebox_override("panel", _choice_card_texture_style(false) if use_gradient else box_style)

    var settlement_box = result_title.get_parent().get_parent()
    if settlement_box is PanelContainer:
        var settlement_style: = box_style.duplicate()
        if GameState.theme == "dark":
            settlement_style.bg_color = Color(0, 0, 0, 0)
            settlement_style.border_color = Color(0, 0, 0, 1.0)
        elif _choice_card_uses_light_dark_style():
            settlement_style.bg_color = Color(0, 0, 0, 0)
            settlement_style.border_color = Color(0.05, 0.05, 0.045, 0.72)
        settlement_box.add_theme_stylebox_override("panel", settlement_style)

    GameScreenStyleFactory.apply_command_button_style(next_button, "primary", 18, 12)

    speaker_bubble.queue_redraw()

    speaker_avatar.add_theme_color_override("font_color", Color(0.95, 0.8, 0.42) if GameState.theme == "light" else GameState.get_theme_color("text_main"))

    narrative_label.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
    if is_instance_valid(mobile_choice_narrative_label):
        mobile_choice_narrative_label.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))

    flavor_label.add_theme_color_override("font_color", GameState.get_theme_color("text_sub"))
    focus_label.add_theme_color_override("font_color", Color(0.82, 0.68, 0.38, 1.0) if GameState.theme == "dark" else Color(0.72, 0.52, 0.18, 1.0))
    _apply_focus_panel_style()

    var settlement_text_col: = Color(0.1, 0.1, 0.095, 0.96) if _choice_card_uses_light_dark_style() else GameState.get_theme_color("text_main")
    var settlement_desc_col: = Color(0.16, 0.16, 0.15, 0.92) if _choice_card_uses_light_dark_style() else GameState.get_theme_color("text_desc")
    result_title.add_theme_color_override("font_color", settlement_text_col)
    chosen_choice_title.add_theme_color_override("font_color", _choice_card_text_color() if _choice_card_uses_light_dark_style() else GameState.get_theme_color("text_main"))
    chosen_choice_desc.add_theme_color_override("font_color", _choice_card_text_color(true) if _choice_card_uses_light_dark_style() else GameState.get_theme_color("text_desc"))
    result_comment.add_theme_color_override("font_color", settlement_desc_col)


    if is_instance_valid(zhisu_title): zhisu_title.add_theme_color_override("font_color", _left_panel_text_color("text_sub"))
    if is_instance_valid(zengyi_title): zengyi_title.add_theme_color_override("font_color", _left_panel_text_color("text_sub"))
    stats_title.add_theme_color_override("font_color", _left_panel_text_color("text_sub"))
    attitudes_title.add_theme_color_override("font_color", _left_panel_text_color("text_sub"))
    var tags_title = dangan_pane.get_node_or_null("DanganScroll/DanganVBox/TagsSection/TagsTitle")
    if tags_title: tags_title.add_theme_color_override("font_color", _left_panel_text_color("text_sub"))
    if is_instance_valid(archive_title): archive_title.add_theme_color_override("font_color", _left_panel_text_color("text_sub"))
    if is_instance_valid(items_title): items_title.add_theme_color_override("font_color", _left_panel_text_color("text_sub"))
    if is_instance_valid(lingwu_title): lingwu_title.add_theme_color_override("font_color", _left_panel_text_color("text_sub"))

    _apply_sidebar_title_font(zhisu_title)
    _apply_sidebar_title_font(zengyi_title)
    _apply_sidebar_title_font(stats_title)
    _apply_sidebar_title_font(attitudes_title)
    _apply_sidebar_title_font(tags_title)
    _apply_sidebar_title_font(archive_title)
    _apply_sidebar_title_font(items_title)
    _apply_sidebar_title_font(shezhi_title)

func _sync_speaker_header_text_colors() -> void :

    var sp_name_col: = GameState.get_theme_color("border_active")
    var sp_sub_col: = GameState.get_theme_color("text_desc")
    var sp_line_col: = GameState.get_theme_color("text_main")
    if GameState.theme == "light":
        if _is_event_portrait_active():

            sp_name_col = Color(0.95, 0.83, 0.5)
            sp_sub_col = Color(0.8, 0.74, 0.62)
            sp_line_col = Color(0.9, 0.84, 0.7)
        else:

            sp_name_col = Color(0.28, 0.18, 0.08, 1.0)
            sp_sub_col = Color(0.48, 0.4, 0.32, 1.0)
            sp_line_col = Color(0.9, 0.84, 0.7)
    speaker_name.add_theme_color_override("font_color", sp_name_col)
    speaker_role.add_theme_color_override("font_color", sp_sub_col)
    speaker_faction.add_theme_color_override("font_color", sp_sub_col)
    speaker_line.add_theme_color_override("font_color", sp_line_col)

func _apply_tab_style(button: Button, active: bool) -> void :
    button.flat = not active
    button.add_theme_font_size_override("font_size", _left_tab_font_size())
    button.alignment = HORIZONTAL_ALIGNMENT_CENTER
    button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER

    button.add_theme_color_override("font_color", _chrome_color("border_active") if active else Color(0.72, 0.71, 0.68, 0.85))
    button.add_theme_color_override("font_hover_color", _chrome_color("border_stronger"))
    button.add_theme_stylebox_override("normal", _make_tab_style(active))
    button.add_theme_stylebox_override("hover", _make_tab_style(true))
    button.add_theme_stylebox_override("pressed", _make_tab_style(true, true))
    if button == shezhi_tab and _shezhi_gear:
        _shezhi_gear.line_color = _chrome_color("border_active") if active else Color(0.72, 0.71, 0.68, 0.85)

func _left_tab_font_size() -> int:
    if _is_native_mobile_landscape():
        return 18
    return 13

func _apply_mobile_tab_style(button: Button, active: bool, position: int = 0) -> void :
    _mobile_bottom_tab_controller.apply_style(button, active, position)

func _topbar_button_style(hovered: bool) -> StyleBoxFlat:
    return GameScreenStyleFactory.topbar_button_style(hovered)

func _settings_button_style(hovered: bool) -> StyleBoxFlat:
    return GameScreenStyleFactory.settings_button_style(hovered, _responsive_border_width())

func _topbar_rank_style(hovered: bool) -> StyleBoxFlat:
    return GameScreenStyleFactory.topbar_rank_style(hovered)

func _refresh_music_button() -> void :
    _update_text_toggle_row(music_text_row, "开" if GameState.sound_on else "关")
    _update_text_toggle_row(_shezhi_music_text_row, "开" if GameState.sound_on else "关")

func _update_text_toggle_row(row: Button, value_text: String) -> void :
    if row == null:
        return
    var value: = row.get_node_or_null("Content/ValueLabel") as Label
    if value:
        value.text = value_text

func _build_hidden_hint(choice: Dictionary, req: Dictionary) -> String:
    return ChoiceHintBuilderRef.build_hidden_hint(choice, req, GameState)

func _build_satisfied_hints(ch: Dictionary, req: Dictionary) -> String:
    return ChoiceHintBuilderRef.build_satisfied_hints(ch, req, GameState)

func _filter_redundant_hints(parts: Array[String]) -> Array[String]:
    return ChoiceHintBuilderRef.filter_redundant_hints(parts)

func _should_show_choice_requirement_value(value: int) -> bool:
    return ChoiceHintBuilderRef.should_show_choice_requirement_value(value)

func _build_require_fn_hints(req_fn: String) -> Array[String]:
    return ChoiceHintBuilderRef.build_require_fn_hints(req_fn)

func _build_require_fn_single_hint(expr: String) -> String:
    return ChoiceHintBuilderRef.build_require_fn_single_hint(expr)

func _format_require_fn_condition_hint(condition: String) -> String:
    return ChoiceHintBuilderRef.format_require_fn_condition_hint(condition)

func _format_numeric_condition_hint(text: String) -> String:
    return ChoiceHintBuilderRef.format_numeric_condition_hint(text)

func _format_display_operator(operator: String) -> String:
    return ChoiceHintBuilderRef.format_display_operator(operator)

func _format_historical_chain_hint(text: String) -> String:
    return ChoiceHintBuilderRef.format_historical_chain_hint(text)

func _extract_condition_number(text: String) -> int:
    return ChoiceHintBuilderRef.extract_condition_number(text)

func _extract_comparison_expected_text(text: String) -> String:
    return ChoiceHintBuilderRef.extract_comparison_expected_text(text)

func _build_display_items() -> Array:
    return ItemListBuilderRef.build_display_items()

func _compute_item_categories(item_id: String, item_def: Dictionary) -> Dictionary:
    return ItemListBuilderRef.compute_item_categories(item_id, item_def)






func _update_items_expand_button() -> void :
    _items_overlay_controller.update_items_expand_button()




func _create_items_expand_button() -> void :
    _items_overlay_controller.create_items_expand_button()


func _show_items_overlay(selection_callback: Callable = Callable(), preselect_item_id: String = "", selection_type: String = "") -> void :
    _items_overlay_controller.show_items_overlay(selection_callback, preselect_item_id, selection_type)


func _close_items_overlay() -> void :
    _items_overlay_controller.close_items_overlay()




func _apply_items_overlay_font_scale() -> void :
    _items_overlay_controller.apply_items_overlay_font_scale()


func _rebuild_items_overlay_tabs() -> void :
    _items_overlay_controller.rebuild_items_overlay_tabs()


func _populate_items_overlay_grid() -> void :
    _items_overlay_controller.populate_items_overlay_grid()

func _make_items_overlay_panel_style() -> StyleBoxFlat:
    return _items_overlay_controller.make_items_overlay_panel_style()

func _make_items_overlay_tab_style(active: bool) -> StyleBoxFlat:
    return _items_overlay_controller.make_items_overlay_tab_style(active)

func _build_private_silver_item_desc() -> String:
    return ItemListBuilderRef.build_private_silver_item_desc()




func _refresh_month_warning() -> void :
    _month_warning_controller.refresh()



func _make_month_warning_chip(entry: Dictionary) -> PanelContainer:
    return _month_warning_controller.make_chip(entry)


func _ensure_month_warning_label() -> void :
    _month_warning_controller.ensure_nodes()

func _toggle_month_warning_collapsed() -> void :
    _month_warning_controller.toggle_collapsed()

func _animate_month_warning_transition(user_triggered: bool) -> void :
    _month_warning_controller.animate_transition(user_triggered)

func _make_small_help_button_style(hovered: bool) -> StyleBoxFlat:
    return GameScreenStyleFactory.small_help_button_style(hovered, _responsive_border_width())

func _build_governance_merit_help_text() -> String:
    return _city_stats_display_controller.build_governance_merit_help_text()

func _get_governance_assessment_year() -> int:
    return GovernanceCalendarTextRef.governance_assessment_year()

func _get_month_name(month_idx: int) -> String:
    return GovernanceCalendarTextRef.month_name(month_idx)

func _format_cz_year_for_ui(year: int) -> String:
    return GovernanceCalendarTextRef.format_cz_year(year)

func _ensure_action_points_content_nodes() -> void :
    if action_points_content_box == null or not is_instance_valid(action_points_content_box):
        action_points_content_box = HBoxContainer.new()
        action_points_content_box.name = "ActionPointsContent"
        action_points_content_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
        action_points_content_box.set_anchors_preset(Control.PRESET_FULL_RECT)
        action_points_content_box.alignment = BoxContainer.ALIGNMENT_CENTER
        action_points_value.add_child(action_points_content_box)
    if action_points_turn_label == null or not is_instance_valid(action_points_turn_label):
        action_points_turn_label = Label.new()
        action_points_turn_label.name = "ActionPointsTurn"
        action_points_turn_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        action_points_turn_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        action_points_content_box.add_child(action_points_turn_label)
    if action_points_separator == null or not is_instance_valid(action_points_separator):
        action_points_separator = ColorRect.new()
        action_points_separator.name = "ActionPointsSeparator"
        action_points_separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
    if action_points_separator.get_parent() != action_points_content_box:
        if action_points_separator.get_parent() != null:
            action_points_separator.get_parent().remove_child(action_points_separator)
        action_points_content_box.add_child(action_points_separator)
    if action_points_text_label == null or not is_instance_valid(action_points_text_label):
        action_points_text_label = Label.new()
        action_points_text_label.name = "ActionPointsText"
        action_points_text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        action_points_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        action_points_content_box.add_child(action_points_text_label)
    if action_points_dots_label == null or not is_instance_valid(action_points_dots_label):
        action_points_dots_label = Label.new()
        action_points_dots_label.name = "ActionPointsDots"
        action_points_dots_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        action_points_dots_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

    if action_points_info_box == null or not is_instance_valid(action_points_info_box):
        action_points_info_box = VBoxContainer.new()
        action_points_info_box.name = "ActionPointsInfo"
        action_points_info_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
        action_points_info_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    if action_points_dots_row == null or not is_instance_valid(action_points_dots_row):
        action_points_dots_row = HBoxContainer.new()
        action_points_dots_row.name = "ActionPointsDotsRow"
        action_points_dots_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
    if action_points_dots_spacer == null or not is_instance_valid(action_points_dots_spacer):
        action_points_dots_spacer = Control.new()
        action_points_dots_spacer.name = "ActionPointsDotsSpacer"
        action_points_dots_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE


    if action_points_attr_label == null or not is_instance_valid(action_points_attr_label):
        action_points_attr_label = RichTextLabel.new()
        action_points_attr_label.name = "ActionPointsAttr"
        action_points_attr_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        action_points_attr_label.bbcode_enabled = true
        action_points_attr_label.fit_content = true
        action_points_attr_label.scroll_active = false
        action_points_attr_label.autowrap_mode = TextServer.AUTOWRAP_OFF

    if action_points_divider == null or not is_instance_valid(action_points_divider):
        action_points_divider = TextureRect.new()
        action_points_divider.name = "ActionPointsDivider"
        action_points_divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
        action_points_divider.custom_minimum_size = Vector2(0, 1)
        action_points_divider.size_flags_horizontal = Control.SIZE_FILL
        action_points_divider.stretch_mode = TextureRect.STRETCH_SCALE
        action_points_divider.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        var grad: = Gradient.new()
        grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
        grad.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
        var grad_tex: = GradientTexture1D.new()
        grad_tex.gradient = grad
        grad_tex.width = 96
        action_points_divider.texture = grad_tex
    if action_points_portrait_frame == null or not is_instance_valid(action_points_portrait_frame):
        action_points_portrait_frame = Panel.new()
        action_points_portrait_frame.name = "ActionPointsPortrait"
        action_points_portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
        action_points_portrait_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        action_points_portrait_frame.add_theme_stylebox_override("panel", StyleBoxEmpty.new())

        action_points_portrait_bg = ColorRect.new()
        action_points_portrait_bg.name = "HexBg"
        action_points_portrait_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
        action_points_portrait_bg.color = Color(1, 1, 1, 1)
        action_points_portrait_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
        var bg_shader: = Shader.new()
        bg_shader.code = ACTION_POINTS_HEX_BG_SHADER
        var bg_mat: = ShaderMaterial.new()
        bg_mat.shader = bg_shader
        action_points_portrait_bg.material = bg_mat
        action_points_portrait_frame.add_child(action_points_portrait_bg)
        action_points_portrait_tex = TextureRect.new()
        action_points_portrait_tex.name = "Tex"
        action_points_portrait_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
        action_points_portrait_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        action_points_portrait_tex.stretch_mode = TextureRect.STRETCH_SCALE
        action_points_portrait_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
        var p_shader: = Shader.new()
        p_shader.code = ACTION_POINTS_PORTRAIT_SHADER
        var p_mat: = ShaderMaterial.new()
        p_mat.shader = p_shader
        action_points_portrait_tex.material = p_mat
        action_points_portrait_frame.add_child(action_points_portrait_tex)



func _ap_reparent(node: Node, parent: Node, idx: int) -> void :
    if node == null or parent == null:
        return
    if node.get_parent() != parent:
        if node.get_parent() != null:
            node.get_parent().remove_child(node)
        parent.add_child(node)
    parent.move_child(node, idx)

func _detach_node(node: Node) -> void :
    if node != null and is_instance_valid(node) and node.get_parent() != null:
        node.get_parent().remove_child(node)




func _ensure_ap_portrait_overlay() -> Control:
    if _ap_portrait_overlay != null and is_instance_valid(_ap_portrait_overlay):
        return _ap_portrait_overlay
    _ap_portrait_overlay = Control.new()
    _ap_portrait_overlay.name = "ActionPointsPortraitOverlay"
    _ap_portrait_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    center_panel.add_child(_ap_portrait_overlay)
    return _ap_portrait_overlay


func _position_ap_portrait_overlay() -> void :
    if not _action_points_portrait_active:
        return
    if action_points_portrait_frame == null or not is_instance_valid(action_points_portrait_frame):
        return
    if _ap_portrait_overlay == null or not is_instance_valid(_ap_portrait_overlay):
        return
    if action_points_value == null or not is_instance_valid(action_points_value):
        return

    if governance_scroll == null or not is_instance_valid(governance_scroll) or not governance_scroll.visible:
        action_points_portrait_frame.visible = false
        return
    var card: = action_points_value.get_global_rect()
    if card.size.x <= 1.0 or card.position == Vector2.ZERO:
        action_points_portrait_frame.visible = false
        return
    var top_left_global: = Vector2(card.position.x - _ap_hex_right, card.end.y + 6.0 - _ap_portrait_size)
    action_points_portrait_frame.size = Vector2(_ap_portrait_size, _ap_portrait_size)
    action_points_portrait_frame.global_position = top_left_global
    action_points_portrait_frame.visible = true

func _arrange_action_points_content(use_portrait: bool) -> void :
    if use_portrait:



        _ap_reparent(action_points_info_box, action_points_content_box, 0)
        _ap_reparent(action_points_attr_label, action_points_info_box, 0)
        _ap_reparent(action_points_dots_row, action_points_info_box, 1)

        if action_points_divider.get_parent() != action_points_value:
            _detach_node(action_points_divider)
            action_points_value.add_child(action_points_divider)
        _ap_reparent(action_points_turn_label, action_points_dots_row, 0)
        _ap_reparent(action_points_dots_spacer, action_points_dots_row, 1)
        _ap_reparent(action_points_text_label, action_points_dots_row, 2)
        _ap_reparent(action_points_dots_label, action_points_dots_row, 3)
        _detach_node(action_points_separator)
        var overlay: = _ensure_ap_portrait_overlay()
        if action_points_portrait_frame.get_parent() != overlay:
            _detach_node(action_points_portrait_frame)
            overlay.add_child(action_points_portrait_frame)


        action_points_portrait_frame.visible = false
    else:

        _ap_reparent(action_points_turn_label, action_points_content_box, 0)
        _ap_reparent(action_points_separator, action_points_content_box, 1)
        _ap_reparent(action_points_text_label, action_points_content_box, 2)
        _ap_reparent(action_points_dots_label, action_points_content_box, 3)
        _detach_node(action_points_portrait_frame)
        _detach_node(action_points_attr_label)
        _detach_node(action_points_dots_spacer)
        _detach_node(action_points_divider)
        _detach_node(action_points_dots_row)
        _detach_node(action_points_info_box)

func _on_action_points_card_gui_input(event: InputEvent) -> void :
    if not _is_primary_press_event(event):
        return
    var press_frame: = Engine.get_process_frames()
    if _rank_tree_last_press_frame == press_frame:
        return
    _rank_tree_last_press_frame = press_frame
    call_deferred("_emit_show_rank_tree_requested")

func _emit_show_rank_tree_requested() -> void :
    show_rank_tree_requested.emit()

func _build_action_points_attr_text(label_color: Color, value_color: Color) -> String:



    var pairs: = [["wentao", "文"], ["wulue", "武"], ["lizheng", "政"], ["tizhi", "体"]]
    if GameData.active_line == "bianwu":
        pairs = [["wulue", "武"], ["lizheng", "政"], ["wentao", "文"], ["tizhi", "体"]]
    var lc: = label_color.to_html(true)
    var vc: = value_color.to_html(true)
    var parts: Array[String] = []
    for p in pairs:
        var v: = int(GameState.stats.get(p[0], 0))
        parts.append("[color=#%s]%s[/color] [color=#%s]%d[/color]" % [lc, p[1], vc, v])
    return "　　".join(parts)

func _build_action_points_dots_text() -> String:
    var parts: Array[String] = []

    var dot_count: int = maxi(GameState.monthly_action_points(), GameState.action_points)
    for idx in range(dot_count):
        parts.append("●" if idx < GameState.action_points else "○")
    return " ".join(parts)

func _governance_overlay_alpha() -> float:
    return 1.0

func _event_overlay_alpha() -> float:
    return 1.0

func _update_action_points_dots() -> void :
    _update_action_points_content()

func _update_action_points_separator() -> void :
    _update_action_points_content()

func _update_action_points_content() -> void :
    if action_points_value == null or not is_instance_valid(action_points_value):
        return
    action_points_value.text = ""
    action_points_value.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    _ensure_action_points_content_nodes()
    var native_landscape: = _is_native_mobile_landscape()

    var portrait_path: = _get_player_rank_portrait_path()
    var use_portrait: = not _is_mobile_portrait() and portrait_path != ""
    _arrange_action_points_content(use_portrait)
    _action_points_portrait_active = use_portrait
    action_points_content_box.alignment = BoxContainer.ALIGNMENT_BEGIN if use_portrait else BoxContainer.ALIGNMENT_CENTER
    action_points_turn_label.text = GameState.get_governance_turn_label()
    action_points_text_label.text = "行动力"
    action_points_dots_label.text = _build_action_points_dots_text()
    var font: = FontLoader.body()


    var text_size: = MOBILE_ACTION_POINTS_FONT_SIZE if _is_mobile_portrait() else ((18 if native_landscape else 15) if use_portrait else (18 if native_landscape else 16))
    var dot_size: = MOBILE_ACTION_POINTS_DOT_FONT_SIZE if _is_mobile_portrait() else ((19 if native_landscape else 16) if use_portrait else (23 if native_landscape else 17))
    for label in [action_points_turn_label, action_points_text_label]:
        label.add_theme_font_override("font", font)
        label.add_theme_font_size_override("font_size", text_size)
        label.add_theme_color_override("font_color", GameState.get_theme_color("text_main"))
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if use_portrait else HORIZONTAL_ALIGNMENT_CENTER

    var attr_value_color: Color = GameState.get_theme_color("text_main")
    var attr_label_color: = Color(attr_value_color.r, attr_value_color.g, attr_value_color.b, attr_value_color.a * 0.55)
    action_points_attr_label.add_theme_font_override("normal_font", font)
    action_points_attr_label.add_theme_font_size_override("normal_font_size", text_size + 1)
    action_points_attr_label.text = _build_action_points_attr_text(attr_label_color, attr_value_color)
    action_points_attr_label.tooltip_text = "体质满值：处理流民暴动与兵勇哗变不消耗行动力" if PersonalStatCapstoneServiceRef.is_active(GameState, "tizhi") else ""
    action_points_dots_label.add_theme_font_override("font", font)
    action_points_dots_label.add_theme_font_size_override("font_size", dot_size)
    action_points_dots_label.add_theme_color_override("font_color", Color(0.66, 0.46, 0.1, 1.0) if GameState.theme == "light" else Color(0.92, 0.76, 0.38, 1.0))
    action_points_dots_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    action_points_separator.color = Color(0.45, 0.36, 0.2, 0.55) if GameState.theme == "light" else Color(0.72, 0.6, 0.36, 0.38)
    action_points_separator.custom_minimum_size = Vector2(1.0, 26.0 if _is_mobile_portrait() else (19.0 if native_landscape else 16.0))
    action_points_separator.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    if use_portrait:

        var portrait_size: = 103.0 if native_landscape else 86.0

        var card_height: = 82.0 if native_landscape else 68.0
        var text_gap: = 31.0 if native_landscape else 26.0

        var right_pad: = 60.0 if native_landscape else 48.0

        var hex_right: = portrait_size * 0.5
        action_points_content_box.offset_left = hex_right + text_gap
        action_points_content_box.offset_right = - right_pad
        action_points_content_box.offset_top = 0
        action_points_content_box.offset_bottom = 0
        action_points_info_box.add_theme_constant_override("separation", 6 if native_landscape else 5)
        action_points_info_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        action_points_dots_row.alignment = BoxContainer.ALIGNMENT_BEGIN
        action_points_dots_row.add_theme_constant_override("separation", 10 if native_landscape else 8)

        action_points_turn_label.size_flags_horizontal = Control.SIZE_FILL
        action_points_text_label.size_flags_horizontal = Control.SIZE_FILL
        action_points_dots_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        action_points_dots_spacer.custom_minimum_size = Vector2(18.0 if native_landscape else 14.0, 0)
        action_points_attr_label.size_flags_horizontal = Control.SIZE_FILL
        _ap_left_pad = hex_right + text_gap
        _ap_right_pad = right_pad


        action_points_divider.modulate = Color(0.72, 0.6, 0.34, 0.55) if GameState.theme == "light" else Color(0.86, 0.72, 0.43, 0.42)
        var _div_left_inset: = hex_right + (16.0 if native_landscape else 12.0)
        var _div_right_inset: = 16.0 if native_landscape else 12.0
        action_points_divider.size_flags_horizontal = Control.SIZE_FILL
        action_points_divider.custom_minimum_size = Vector2(0, 1)
        action_points_divider.anchor_left = 0.0
        action_points_divider.anchor_right = 1.0
        action_points_divider.anchor_top = 0.5
        action_points_divider.anchor_bottom = 0.5
        action_points_divider.offset_left = _div_left_inset
        action_points_divider.offset_right = - _div_right_inset
        action_points_divider.offset_top = -0.5
        action_points_divider.offset_bottom = 0.5

        _ap_portrait_size = portrait_size
        _ap_hex_right = hex_right
        action_points_portrait_frame.set_anchors_preset(Control.PRESET_TOP_LEFT)
        action_points_portrait_frame.custom_minimum_size = Vector2(portrait_size, portrait_size)
        action_points_portrait_frame.size = Vector2(portrait_size, portrait_size)
        action_points_portrait_frame.add_theme_stylebox_override("panel", StyleBoxEmpty.new())

        var hex_corner: = 9.0 / portrait_size
        var hex_border_color: = Color(0.66, 0.5, 0.26, 1.0) if GameState.theme == "light" else Color(0.82, 0.68, 0.42, 1.0)
        var hex_fill_color: = Color(0.97, 0.94, 0.88, 1.0) if GameState.theme == "light" else Color(0.11, 0.095, 0.072, 1.0)
        if action_points_portrait_bg != null and action_points_portrait_bg.material is ShaderMaterial:
            var bg_mat: = action_points_portrait_bg.material as ShaderMaterial
            bg_mat.set_shader_parameter("corner", hex_corner)
            bg_mat.set_shader_parameter("hex_r", 0.84)
            bg_mat.set_shader_parameter("border", 5.0 / portrait_size)
            bg_mat.set_shader_parameter("fill_color", hex_fill_color)
            bg_mat.set_shader_parameter("border_color", hex_border_color)
        if action_points_portrait_tex != null:
            if action_points_portrait_tex.material is ShaderMaterial:
                var hex_mat: = action_points_portrait_tex.material as ShaderMaterial
                hex_mat.set_shader_parameter("corner", hex_corner)
                hex_mat.set_shader_parameter("border", 0.0)
                hex_mat.set_shader_parameter("hex_r", 0.7)
            if _action_points_portrait_path != portrait_path:
                action_points_portrait_tex.texture = load(portrait_path)
                _action_points_portrait_path = portrait_path

        var card_style: = StyleBoxFlat.new()
        card_style.bg_color = Color(0.99, 0.98, 0.96, 0.9) if GameState.theme == "light" else Color(0.1, 0.075, 0.055, 0.92)
        card_style.border_color = Color(0.72, 0.6, 0.34, 0.18) if GameState.theme == "light" else Color(0.86, 0.72, 0.43, 0.2)
        card_style.set_border_width_all(1)
        card_style.set_corner_radius_all(0)
        card_style.corner_radius_bottom_right = 16
        card_style.content_margin_left = 0
        card_style.content_margin_right = 0
        card_style.content_margin_top = 0
        card_style.content_margin_bottom = 0
        action_points_value.add_theme_stylebox_override("normal", card_style)
        action_points_value.custom_minimum_size.y = card_height
    else:

        action_points_turn_label.size_flags_horizontal = Control.SIZE_FILL
        action_points_text_label.size_flags_horizontal = Control.SIZE_FILL
        action_points_content_box.offset_left = 0
        action_points_content_box.offset_right = 0
        action_points_content_box.offset_top = 0
        action_points_content_box.offset_bottom = 0
        action_points_content_box.add_theme_constant_override("separation", 24 if _is_mobile_portrait() else (21 if native_landscape else 18))
        if not _is_mobile_portrait():
            action_points_value.custom_minimum_size.y = 0
        if _ap_portrait_overlay != null and is_instance_valid(_ap_portrait_overlay) and action_points_portrait_frame != null and is_instance_valid(action_points_portrait_frame):
            action_points_portrait_frame.visible = false
    _sync_action_points_value_width()
    if _action_points_portrait_active:
        call_deferred("_position_ap_portrait_overlay")

func _sync_action_points_value_width() -> void :
    if action_points_value == null or not is_instance_valid(action_points_value):
        return
    if action_points_content_box == null or not is_instance_valid(action_points_content_box):
        return

    if _action_points_portrait_active:

        var pw: = _ap_left_pad + action_points_content_box.get_combined_minimum_size().x + _ap_right_pad
        action_points_value.custom_minimum_size.x = pw
        return
    var base_width: = MOBILE_ACTION_POINTS_WIDTH if _is_mobile_portrait() else DESKTOP_ACTION_POINTS_WIDTH
    var horizontal_padding: = 56.0 if _is_mobile_portrait() else (42.0 if _is_native_mobile_landscape() else 36.0)
    var content_width: = action_points_content_box.get_combined_minimum_size().x + horizontal_padding
    action_points_value.custom_minimum_size.x = maxf(base_width, content_width)

func _get_month_card_title(card: Dictionary) -> String:
    return _month_card_display.get_title(card)

func _build_month_card_summary(card: Dictionary) -> String:
    return _month_card_display.build_summary(card)

func _get_month_card_summary_lines(card: Dictionary) -> int:
    return _month_card_display.get_summary_lines(card)

func _get_month_card_note_text(card: Dictionary) -> String:
    return _month_card_display.get_note_text(card)

func _maybe_doubled_att_effects(state: Node, action_data: Dictionary) -> Dictionary:
    var att: Dictionary = action_data.get("attEffects", {})
    var card_id: = str(action_data.get("id", ""))
    if card_id == "" or not state.upgraded_governance_cards.has(card_id):
        return att
    var doubled: Dictionary = {}
    for k in att:
        var v = att[k]
        if typeof(v) == TYPE_INT:
            doubled[k] = int(v) * 2
        elif typeof(v) == TYPE_FLOAT:
            doubled[k] = float(v) * 2.0
        else:
            doubled[k] = v
    return doubled

func _format_effect_summary(effects: Dictionary, extra_effects: Dictionary = {}) -> String:
    return _month_card_display.format_effect_summary(effects, extra_effects)

func _truncate_text(value: String, length: int) -> String:
    return _month_card_display.truncate_text(value, length)

func _month_card_text_color(disabled: bool, strong: bool) -> Color:
    return _month_card_display.text_color(disabled, strong)

func _month_card_tag_bg(disabled: bool) -> Color:
    return _month_card_display.tag_bg(disabled)

func _month_card_overlay_colors(card: Dictionary, disabled: bool) -> Array[Color]:
    return _month_card_display.overlay_colors(card, disabled)


func _is_highlight_event_card(card: Dictionary) -> bool:
    var c_type: = str(card.get("type", ""))
    if c_type in ["story", "attitude", "court", "court_chain", "riot", "mutiny", "grain_shortage"]:
        return true
    if c_type == "visitor":
        var visitor_id: = str(card.get("visitor_id", ""))
        if visitor_id == "v_xiangshen":
            return true
        var visitor_def: = EventServiceRef._find_visitor_by_id(visitor_id)
        if not visitor_def.is_empty() and (str(visitor_def.get("sceneType", "")) == "court" or visitor_def.get("is_court_session", false)):
            return true
    return false



func _landscape_card_face_color(card: Dictionary, disabled: bool, dark_face: bool) -> Color:

    var c: Color
    if dark_face:



        var is_court_style: = str(card.get("type", "")) in ["court", "court_chain"]
        if not is_court_style and str(card.get("type", "")) == "visitor":
            var visitor_id: = str(card.get("visitor_id", ""))
            if visitor_id == "v_xiangshen":
                is_court_style = true
            else:
                var visitor_def: = EventServiceRef._find_visitor_by_id(visitor_id)
                if not visitor_def.is_empty() and (str(visitor_def.get("sceneType", "")) == "court" or visitor_def.get("is_court_session", false)):
                    is_court_style = true
        if is_court_style:
            c = Color(0.243, 0.271, 0.255)
        else:
            c = Color(0.361, 0.29, 0.18)
    elif disabled:
        c = Color(0.686, 0.686, 0.635)
    else:
        match str(card.get("type", "")):
            "governance":
                c = Color(0.376, 0.353, 0.322)
            "trade":
                c = Color(0.4, 0.333, 0.247)
            "home":
                c = Color(0.443, 0.416, 0.435)
            "field":
                c = Color(0.322, 0.388, 0.306)
            "visitor":
                c = Color(0.31, 0.349, 0.494)
            "rumor":
                c = Color(0.329, 0.29, 0.298)
            _:
                c = Color(0.376, 0.353, 0.322)




    if not dark_face:
        if GameState.theme == "dark":
            c = c.darkened(0.74)
        else:
            c = c.darkened(0.3 if disabled else 0.58)
    elif GameState.theme == "light":
        c = c.lightened(0.1)
    return c


func _make_landscape_card_style(card: Dictionary, disabled: bool, hovered: bool) -> StyleBoxFlat:
    var style: = StyleBoxFlat.new()
    _apply_style_border_width(style, _responsive_border_width())
    var r: = 4
    style.corner_radius_top_left = r
    style.corner_radius_top_right = r
    style.corner_radius_bottom_left = r
    style.corner_radius_bottom_right = r
    style.content_margin_left = 0
    style.content_margin_right = 0
    style.content_margin_top = 0
    style.content_margin_bottom = 0
    if GameState.theme == "light":
        style.shadow_size = 6 if disabled else 8
        style.shadow_offset = Vector2(0, 3 if disabled else 4)
        style.shadow_color = Color(0.12, 0.1, 0.08, 0.08 if disabled else 0.14)
    else:
        style.shadow_size = 0
    var dark_face: = _is_highlight_event_card(card) and not disabled
    var base: = _landscape_card_face_color(card, disabled, dark_face)
    if hovered:
        base = base.lightened(0.06)
    style.bg_color = base

    if dark_face:
        style.border_color = Color(0.46, 0.33, 0.18, 0.55)
    else:
        style.border_color = Color(0.55, 0.48, 0.36, 0.32)
    return style

func _make_landscape_card_gradient_texture(disabled: bool, dark_face: bool) -> GradientTexture2D:

    var top_col: = Color(0.52, 0.5, 0.44, 0.14) if disabled else Color(1.0, 0.78, 0.4, 0.08)
    var bottom_col: = Color(0.0, 0.0, 0.0, 0.12) if disabled else Color(0.0, 0.0, 0.0, 0.16)
    if GameState.theme == "light":
        top_col = Color(0.56, 0.53, 0.47, 0.2) if disabled else Color(1.0, 0.8, 0.42, 0.16)
        bottom_col = Color(0.0, 0.0, 0.0, 0.2) if disabled else Color(0.0, 0.0, 0.0, 0.3)

    var grad: = Gradient.new()
    grad.offsets = PackedFloat32Array([0.0, 0.52, 1.0])
    grad.colors = PackedColorArray([
        top_col, 
        top_col.lerp(bottom_col, 0.45), 
        bottom_col
    ])
    var tex: = GradientTexture2D.new()
    tex.width = 8
    tex.height = 512
    tex.gradient = grad
    tex.fill_from = Vector2(0.5, 0.0)
    tex.fill_to = Vector2(0.5, 1.0)
    return tex

func _add_landscape_card_gradient_layer(parent: Control, card: Dictionary, disabled: bool, dark_face: bool) -> void :
    var old_layer: = parent.get_node_or_null("MonthCardGradientLayer")
    if old_layer != null:
        old_layer.queue_free()
    var layer: = TextureRect.new()
    layer.name = "MonthCardGradientLayer"
    layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.set_anchors_preset(Control.PRESET_FULL_RECT)
    layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    layer.stretch_mode = TextureRect.STRETCH_SCALE
    layer.texture = _make_landscape_card_gradient_texture(disabled, dark_face)
    parent.add_child(layer)
    parent.move_child(layer, 0)

func _get_month_card_visual_key(card: Dictionary) -> String:
    var card_type: = str(card.get("type", ""))
    var illustration_key: = card_type
    var card_category: = str(card.get("cardCategory", ""))
    var idx: = int(card.get("idx", -1))

    match card_type:
        "governance":
            if idx >= 0 and idx < GameData.GOVERNANCE_CARDS.size():
                card_category = str(GameData.GOVERNANCE_CARDS[idx].get("cardCategory", card_category))
            illustration_key = "military" if card_category == "bingyong" else "governance"
        "field":
            var field_action: Dictionary = {}
            if idx >= 0 and idx < GameData.FIELD_ACTIONS.size():
                field_action = GameData.FIELD_ACTIONS[idx]
                card_category = str(field_action.get("cardCategory", card_category))
            illustration_key = "military" if card_category == "bingyong" else "field"
        "trade":
            illustration_key = "trade"
        "home":
            illustration_key = "home"
        "visitor":
            var visitor_id: = str(card.get("visitor_id", ""))
            var is_court: = visitor_id == "v_xiangshen"
            if not is_court:
                var visitor_def: = EventServiceRef._find_visitor_by_id(visitor_id)
                if not visitor_def.is_empty() and (str(visitor_def.get("sceneType", "")) == "court" or visitor_def.get("is_court_session", false)):
                    is_court = true
            illustration_key = "yamen" if is_court else "street"
        "rumor":
            illustration_key = "rumor"
        "riot", "mutiny":
            illustration_key = "military"
        "story", "attitude", "grain_shortage":
            illustration_key = "important"
        "court", "court_chain":
            illustration_key = "yamen"
        _:
            illustration_key = "governance"

    return illustration_key

func _get_month_card_illustration_path(card: Dictionary) -> String:
    var illustration_key: = _get_month_card_visual_key(card)
    return str(MONTH_CARD_ILLUSTRATION_PATHS.get(illustration_key, MONTH_CARD_ILLUSTRATION_PATHS["governance"]))

func _month_card_visual_tint(card: Dictionary) -> Color:
    match _get_month_card_visual_key(card):
        "important":
            return Color(0.58, 0.32, 0.13, 1.0)
        "governance":
            return Color(0.36, 0.27, 0.17, 1.0)
        "trade":
            return Color(0.14, 0.34, 0.35, 1.0)
        "yamen":
            return Color(0.24, 0.32, 0.29, 1.0)
        "field":
            return Color(0.24, 0.36, 0.2, 1.0)
        "home":
            return Color(0.32, 0.25, 0.34, 1.0)
        "military":
            return Color(0.16, 0.22, 0.3, 1.0)
        "street":
            return Color(0.2, 0.27, 0.46, 1.0)
        "rumor":
            return Color(0.36, 0.23, 0.26, 1.0)
    return Color(0.34, 0.27, 0.18, 1.0)

func _make_month_card_top_mask_texture(card: Dictionary, disabled: bool) -> GradientTexture2D:
    var tint: = _month_card_visual_tint(card)
    if disabled:

        var lum: = tint.r * 0.299 + tint.g * 0.587 + tint.b * 0.114
        var gray: = Color(lum, lum, lum, tint.a)
        tint = tint.lerp(gray, 0.75)
    else:

        var lum: = tint.r * 0.299 + tint.g * 0.587 + tint.b * 0.114
        var gray: = Color(lum, lum, lum, tint.a)
        tint = tint.lerp(gray, 0.45)
    var alpha_top: = 0.86 if not disabled else 0.58
    var alpha_mid: = 0.38 if not disabled else 0.22
    var alpha_bottom: = 0.0
    if GameState.theme == "light":
        alpha_bottom = 0.2 if not disabled else 0.12
    var grad: = Gradient.new()

    grad.offsets = PackedFloat32Array([0.0, 0.55, 0.82, 1.0])
    grad.colors = PackedColorArray([
        Color(tint.r, tint.g, tint.b, alpha_top), 
        Color(tint.r, tint.g, tint.b, alpha_top), 
        Color(tint.r, tint.g, tint.b, alpha_mid), 
        Color(tint.r, tint.g, tint.b, alpha_bottom)
    ])
    var tex: = GradientTexture2D.new()
    tex.width = 8
    tex.height = 512
    tex.gradient = grad
    tex.fill_from = Vector2(0.5, 0.0)
    tex.fill_to = Vector2(0.5, 1.0)
    return tex

func _add_month_card_top_mask(parent: Control, card: Dictionary, disabled: bool) -> void :
    var mask: = TextureRect.new()
    mask.name = "MonthCardTopThemeMask"
    mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
    mask.set_anchors_preset(Control.PRESET_FULL_RECT)
    mask.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    mask.stretch_mode = TextureRect.STRETCH_SCALE
    mask.texture = _make_month_card_top_mask_texture(card, disabled)
    parent.add_child(mask)

func _add_month_card_illustration(parent: Control, card: Dictionary, disabled: bool, _dark_face: bool, _card_size: Vector2) -> void :
    var illustration_path: = _get_month_card_illustration_path(card)
    if illustration_path == "":
        return
    var illustration_texture: = load(illustration_path)
    if illustration_texture == null:
        return

    var illustration: = TextureRect.new()
    illustration.name = "MonthCardIllustration"
    illustration.texture = illustration_texture
    illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
    illustration.set_anchors_preset(Control.PRESET_FULL_RECT)
    var mat: = ShaderMaterial.new()
    mat.shader = _get_month_card_illust_shader()
    mat.set_shader_parameter("saturation", 0.0 if disabled else 0.12)
    mat.set_shader_parameter("contrast", 1.0 if disabled else 1.45)
    mat.set_shader_parameter("overall_alpha", 0.09 if disabled else (0.32 if GameState.theme == "light" else 0.4))
    illustration.material = mat
    illustration.modulate = Color.WHITE
    parent.add_child(illustration)

var _month_card_illust_shader: Shader = null
func _get_month_card_illust_shader() -> Shader:
    if _month_card_illust_shader != null:
        return _month_card_illust_shader
    var sh: = Shader.new()
    sh.code = "\nshader_type canvas_item;\nrender_mode blend_mix;\nuniform float saturation = 1.0;\nuniform float contrast = 1.0;\nuniform float overall_alpha = 1.0;\nvoid fragment() {\n\tvec4 tex = texture(TEXTURE, UV);\n\tfloat lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));\n\tvec3 gray = vec3(lum);\n\tvec3 rgb = mix(gray, tex.rgb, saturation);\n\trgb = clamp((rgb - 0.5) * contrast + 0.5, 0.0, 1.0);\n\tCOLOR = vec4(rgb, tex.a * overall_alpha);\n}\n"














    _month_card_illust_shader = sh
    return _month_card_illust_shader


func _build_landscape_month_card(card_button: Button, card: Dictionary, disabled: bool, _idx: int, lock_reason: String, card_size: Vector2) -> void :
    var dark_face: = _is_highlight_event_card(card) and not disabled

    card_button.add_theme_stylebox_override("normal", _make_landscape_card_style(card, disabled, false))
    card_button.add_theme_stylebox_override("hover", _make_landscape_card_style(card, disabled, true))
    card_button.add_theme_stylebox_override("pressed", _make_landscape_card_style(card, disabled, true))
    card_button.add_theme_stylebox_override("disabled", _make_landscape_card_style(card, disabled, false))
    _add_landscape_card_gradient_layer(card_button, card, disabled, dark_face)
    _add_month_card_illustration(card_button, card, disabled, dark_face, card_size)
    _add_month_card_top_mask(card_button, card, disabled)


    var grain_alpha: = 0.0
    _attach_grain_texture_layer(card_button, "MonthCardGrainLayer", grain_alpha, 1)



    var inner_border_inset: = float(_bianwu_card_scaled(6.0))
    var inner_border: = Control.new()
    inner_border.set_anchors_preset(Control.PRESET_FULL_RECT)
    inner_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
    inner_border.draw.connect( func():
        var rect: = Rect2(
            inner_border_inset, 
            inner_border_inset, 
            inner_border.size.x - inner_border_inset * 2.0, 
            inner_border.size.y - inner_border_inset * 2.0
        )
        if rect.size.x <= 0.0 or rect.size.y <= 0.0:
            return
        var border_col: = Color(0.86, 0.78, 0.55, 0.34)
        if disabled:
            border_col.a *= 0.55
        inner_border.draw_rect(rect, border_col, false, 1.0)
    )
    card_button.add_child(inner_border)


    var title_col: Color
    var summary_col: Color
    var divider_col: Color

    if not disabled:
        title_col = Color(0.94, 0.88, 0.75)
        summary_col = Color(0.8, 0.72, 0.6)
        divider_col = Color(0.8, 0.66, 0.42, 0.42)
    else:
        title_col = Color(0.86, 0.8, 0.68)
        summary_col = Color(0.66, 0.6, 0.5)
        divider_col = Color(0.62, 0.54, 0.42, 0.3)
    if disabled:
        title_col.a *= 0.5
        summary_col.a *= 0.5
        divider_col.a *= 0.5

    var root: = MarginContainer.new()
    root.set_anchors_preset(Control.PRESET_FULL_RECT)
    root.offset_left = 1
    root.offset_top = 1
    root.offset_right = -1
    root.offset_bottom = -1
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_theme_constant_override("margin_left", _bianwu_card_scaled(18))
    root.add_theme_constant_override("margin_right", _bianwu_card_scaled(18))
    root.add_theme_constant_override("margin_top", _bianwu_card_scaled(18))
    root.add_theme_constant_override("margin_bottom", _bianwu_card_scaled(18))

    var col: = VBoxContainer.new()
    col.mouse_filter = Control.MOUSE_FILTER_IGNORE
    col.add_theme_constant_override("separation", _bianwu_card_scaled(7))
    root.add_child(col)

    var tag_panel: = PanelContainer.new()
    tag_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    tag_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    var tag_style: = StyleBoxFlat.new()
    tag_style.bg_color = Color(0, 0, 0, 0)
    _apply_style_border_width(tag_style, 1)
    tag_style.border_color = Color(0.78, 0.66, 0.44, 0.62) if ( not disabled) else Color(0.66, 0.58, 0.44, 0.45)
    if disabled:
        tag_style.border_color.a *= 0.5
    tag_style.corner_radius_top_left = 4
    tag_style.corner_radius_top_right = 4
    tag_style.corner_radius_bottom_left = 4
    tag_style.corner_radius_bottom_right = 4
    tag_style.content_margin_left = _bianwu_card_scaled(8)
    tag_style.content_margin_right = _bianwu_card_scaled(8)
    tag_style.content_margin_top = _bianwu_card_scaled(3)
    tag_style.content_margin_bottom = _bianwu_card_scaled(3)
    tag_panel.add_theme_stylebox_override("panel", tag_style)
    col.add_child(tag_panel)

    var tag_label: = Label.new()
    tag_label.text = _get_month_card_tag_text(card)
    tag_label.add_theme_font_override("font", FontLoader.body())
    tag_label.add_theme_font_size_override("font_size", _bianwu_card_scaled(12))
    var tag_text_col: = Color(0.88, 0.78, 0.55) if ( not disabled) else Color(0.78, 0.7, 0.56)
    if disabled:
        tag_text_col.a *= 0.5
    tag_label.add_theme_color_override("font_color", tag_text_col)
    tag_panel.add_child(tag_label)

    var title: = Label.new()
    title.text = _get_month_card_title(card)
    title.add_theme_font_override("font", FontLoader.serif_bold())
    title.add_theme_font_size_override("font_size", _bianwu_card_scaled(19))
    title.add_theme_color_override("font_color", title_col)
    title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    title.max_lines_visible = 2
    title.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
    col.add_child(title)

    var summary: = Label.new()
    summary.text = _build_month_card_summary(card)
    summary.add_theme_font_override("font", FontLoader.body())
    summary.add_theme_font_size_override("font_size", _bianwu_card_scaled(13))
    summary.add_theme_color_override("font_color", summary_col)
    summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    summary.vertical_alignment = VERTICAL_ALIGNMENT_TOP
    summary.max_lines_visible = 3
    summary.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
    summary.visible = summary.text != ""
    col.add_child(summary)

    var spacer: = Control.new()
    spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    col.add_child(spacer)



    if disabled:
        var divider: = Control.new()
        divider.custom_minimum_size = Vector2(0, 1)
        divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
        divider.draw.connect( func():
            divider.draw_line(Vector2(0.0, 0.5), Vector2(divider.size.x, 0.5), divider_col, 1.0)
        )
        col.add_child(divider)

        var status_label: = Label.new()
        status_label.text = lock_reason if lock_reason != "" else "已处理"
        status_label.add_theme_font_override("font", FontLoader.body())
        status_label.add_theme_font_size_override("font_size", _bianwu_card_scaled(11))
        status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        var status_col: = Color(0.62, 0.56, 0.46, 0.85)
        if GameState.theme == "light":
            status_col = Color(0.85, 0.81, 0.73, 0.9)
        else:
            status_col.a *= 0.5
        status_label.add_theme_color_override("font_color", status_col)
        col.add_child(status_label)

    card_button.add_child(root)

func _governance_header_color(strong: bool) -> Color:
    if GameState.theme == "dark":
        return Color(0.88, 0.82, 0.68, 0.96) if strong else Color(0.74, 0.68, 0.56, 0.9)
    return GameState.get_theme_color("text_main") if strong else GameState.get_theme_color("text_sub")

func _make_month_card_style(card: Dictionary, disabled: bool, hovered: bool = false, pressed: bool = false) -> StyleBoxFlat:
    return GameScreenStyleFactory.month_card_style(card, disabled, hovered, pressed, _responsive_border_width())

func _get_tier_color(value: int) -> Color:
    var tier = GameData.get_tier(value)
    match tier:
        0:
            return Color(0.8, 0.3, 0.3, 1.0)
        1:
            return Color(0.78, 0.35, 0.35, 1.0)
        2:
            return Color(0.55, 0.62, 0.7, 1.0)
        3:
            return Color(0.78, 0.72, 0.62, 1.0)
        4:
            return Color(0.85, 0.6, 0.3, 1.0)
        5:
            return Color(0.92, 0.76, 0.35, 1.0)
        6:
            return Color(0.35, 0.7, 0.48, 1.0)
        _:
            return Color(0.82, 0.56, 0.22, 1.0)

func _make_choice_style(is_hidden: bool, is_locked: bool = false, hovered: bool = false, pressed: bool = false) -> StyleBoxFlat:
    return GameScreenStyleFactory.choice_style(is_hidden, is_locked, hovered, pressed, _responsive_border_width())




func _chrome_color(key: String) -> Color:
    return GameState.theme_colors["dark"].get(key, Color.WHITE)



func _make_chrome_gradient_style(_is_top_bar: bool) -> StyleBoxTexture:
    var grad: = Gradient.new()
    grad.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
    grad.colors = PackedColorArray([
        Color(0.175, 0.165, 0.15, 1.0), 
        Color(0.12, 0.112, 0.1, 1.0), 
        Color(0.082, 0.077, 0.068, 1.0), 
    ])
    var tex: = GradientTexture2D.new()
    tex.width = 16
    tex.height = 64
    tex.gradient = grad
    tex.fill_from = Vector2(0.5, 0.0)
    tex.fill_to = Vector2(0.5, 1.0)
    var st: = StyleBoxTexture.new()
    st.texture = tex
    st.content_margin_left = 0
    st.content_margin_right = 0
    st.content_margin_top = 0
    st.content_margin_bottom = 0
    return st

func _make_tab_style(active: bool, pressed: bool = false) -> StyleBox:
    return GameScreenStyleFactory.tab_style(active, pressed)

func _make_tab_active_texture() -> ImageTexture:
    return GameScreenStyleFactory.tab_active_texture()

func _make_mobile_tab_style(active: bool, hovered: bool = false, pressed: bool = false, position: int = 0) -> StyleBoxFlat:
    return GameScreenStyleFactory.mobile_tab_style(active, hovered, pressed, position, _responsive_border_width())

func _on_theme_changed(_theme: String) -> void :
    if not is_inside_tree(): return

    _apply_dynamic_theme()
    _switch_left_tab(current_left_tab)
    ScrollbarThemeRef.apply_to(governance_scroll)
    ScrollbarThemeRef.apply_to(event_scroll)
    ScrollbarThemeRef.apply_to(items_scroll)
    ScrollbarThemeRef.apply_to(mobile_info_scroll)

    _apply_game_background_mask()

    _render_event_inner()

    if GameState.is_governance_mode():
        _show_governance_overview()

    _refresh_panels()


func _apply_game_background_mask() -> void :




    RenderingServer.set_default_clear_color(
        Color(0.878, 0.878, 0.878) if GameState.theme == "light" else Color(0.043, 0.031, 0.023)
    )
    if not is_instance_valid(game_overlay) or not (game_overlay.texture is GradientTexture2D):
        _apply_mobile_governance_background_mask()
        _apply_mobile_event_reading_mask()
        _apply_mobile_event_background_alpha()
        return

    var grad = game_overlay.texture.gradient
    if not grad:
        _apply_mobile_governance_background_mask()
        _apply_mobile_event_reading_mask()
        _apply_mobile_event_background_alpha()
        return

    game_overlay.material = null
    if _is_mobile_event_reading_active():
        grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
        grad.colors = PackedColorArray([
            Color(0.0, 0.0, 0.0, 0.0), 
                Color(0.0, 0.0, 0.0, 0.0), 
                Color(0.0, 0.0, 0.0, 0.0)
            ])
    elif _is_mobile_governance_overview_active():
        grad.offsets = PackedFloat32Array([0.0, 0.44, 1.0])
        grad.colors = PackedColorArray([
            MOBILE_GOVERNANCE_MASK_TOP, 
            MOBILE_GOVERNANCE_MASK_MID, 
            MOBILE_GOVERNANCE_MASK_BOTTOM
        ])
    elif GameState.theme == "light":









        var card_overview: = GameState.is_governance_mode() and governance_active_card_index < 0\
and is_instance_valid(governance_scroll) and governance_scroll.visible



        var light_event_active: = ( not card_overview) and not _is_mobile_portrait()\
and ((is_instance_valid(event_scroll) and event_scroll.visible) or _is_event_portrait_active())
        if light_event_active:
            var paper: = Color("#E1E1E1", 0.9)
            grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
            grad.colors = PackedColorArray([paper, paper, paper])
        else:


            grad.offsets = PackedFloat32Array([0.0, 0.24, 0.4, 0.5, 1.0])
            grad.colors = PackedColorArray([
                GAME_BACKGROUND_MASK_LIGHT_EDGE, 
                GAME_BACKGROUND_MASK_LIGHT_EDGE, 
                GAME_BACKGROUND_MASK_LIGHT_CLEAR, 
                GAME_BACKGROUND_MASK_LIGHT_CLEAR, 
                GAME_BACKGROUND_MASK_LIGHT_EDGE
            ])
    elif _is_desktop_dark_event_reading_active():
        game_overlay.material = _get_dark_event_reading_full_mask_material() if (OS.has_feature("web") or not GameState.event_portraits_enabled) else _get_dark_event_reading_mask_material()
        grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
        grad.colors = PackedColorArray([
            Color(1, 1, 1, 1), 
            Color(1, 1, 1, 1), 
            Color(1, 1, 1, 1)
        ])
    elif _is_dark_governance_overview_active():
        grad.offsets = PackedFloat32Array([0.0, 0.44, 1.0])
        grad.colors = PackedColorArray([
            _dark_gov_mask_color(DARK_GOVERNANCE_OVERVIEW_MASK_TOP), 
            _dark_gov_mask_color(DARK_GOVERNANCE_OVERVIEW_MASK_MID), 
            _dark_gov_mask_color(DARK_GOVERNANCE_OVERVIEW_MASK_BOTTOM)
        ])
    elif _is_mobile_portrait():
        grad.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
        grad.colors = PackedColorArray([
            GAME_BACKGROUND_MASK_TOP, 
            Color(0.012, 0.011, 0.009, 0.96), 
            GAME_BACKGROUND_MASK_BOTTOM
        ])
    else:
        grad.offsets = PackedFloat32Array([0.0, 0.48, 1.0])
        grad.colors = PackedColorArray([
            GAME_BACKGROUND_MASK_TOP, 
            GAME_BACKGROUND_MASK_MID, 
            GAME_BACKGROUND_MASK_BOTTOM
        ])
    _apply_mobile_governance_background_mask()
    _apply_mobile_event_reading_mask()
    _apply_mobile_event_background_alpha()


func _is_desktop_dark_event_reading_active() -> bool:
    if GameState.theme != "dark" or _is_mobile_portrait():
        return false
    var card_overview: = GameState.is_governance_mode() and governance_active_card_index < 0\
and is_instance_valid(governance_scroll) and governance_scroll.visible
    return ( not card_overview) and ((is_instance_valid(event_scroll) and event_scroll.visible) or _is_event_portrait_active())


func _get_dark_event_reading_mask_material() -> ShaderMaterial:
    if _dark_event_reading_mask_material != null:
        return _dark_event_reading_mask_material
    var shader: = Shader.new()
    shader.code = "\nshader_type canvas_item;\n\nuniform vec3 left_tint = vec3(0.035, 0.024, 0.016);\nuniform vec3 mid_tint = vec3(0.022, 0.020, 0.017);\nuniform vec3 right_tint = vec3(0.112, 0.105, 0.096);\nuniform vec3 corner_brown_tint = vec3(0.095, 0.048, 0.022);\nuniform float base_alpha : hint_range(0.0, 1.0) = 0.94;\nuniform float right_top_push : hint_range(0.0, 0.30) = 0.13;\nuniform float right_bottom_pull : hint_range(0.0, 0.30) = 0.12;\nuniform float edge_softness : hint_range(0.02, 0.24) = 0.12;\nuniform float edge_noise : hint_range(0.0, 0.10) = 0.035;\n\nfloat hash(vec2 p) {\n\treturn fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);\n}\n\nvoid fragment() {\n\tfloat top_edge = 0.68 + right_top_push;\n\tfloat bottom_edge = 0.68 - right_bottom_pull;\n\tfloat slanted_edge = mix(top_edge, bottom_edge, UV.y);\n\tfloat wave = sin(UV.y * 19.0 + sin(UV.y * 7.0) * 1.8) * edge_noise;\n\tfloat grain = (hash(floor(FRAGCOORD.xy / 3.0)) - 0.5) * edge_noise;\n\tfloat edge = slanted_edge + wave + grain;\n\tfloat side_fade = 1.0 - smoothstep(edge - edge_softness, edge + edge_softness, UV.x);\n\tfloat left_fade = smoothstep(0.00, 0.08, UV.x);\n\tfloat vertical_weight = mix(0.78, 1.0, smoothstep(0.02, 0.42, UV.y));\n\tvertical_weight *= mix(1.0, 0.86, smoothstep(0.72, 1.0, UV.y));\n\tfloat tone = smoothstep(0.06, 0.78, UV.x);\n\tvec3 dark_grad = mix(left_tint, mid_tint, smoothstep(0.0, 0.48, UV.x));\n\tvec3 color_grad = mix(dark_grad, right_tint, tone * 0.30);\n\tfloat corner_warmth = (1.0 - smoothstep(0.00, 0.46, UV.x)) * (1.0 - smoothstep(0.00, 0.62, UV.y));\n\tcolor_grad = mix(color_grad, corner_brown_tint, corner_warmth * 0.52);\n\tCOLOR = vec4(color_grad, base_alpha * side_fade * left_fade * vertical_weight);\n}\n"



































    _dark_event_reading_mask_material = ShaderMaterial.new()
    _dark_event_reading_mask_material.shader = shader
    return _dark_event_reading_mask_material


func _get_dark_event_reading_full_mask_material() -> ShaderMaterial:
    if _dark_event_reading_full_mask_material != null:
        return _dark_event_reading_full_mask_material
    var shader: = Shader.new()
    shader.code = "\nshader_type canvas_item;\n\nuniform vec3 left_tint = vec3(0.035, 0.024, 0.016);\nuniform vec3 mid_tint = vec3(0.022, 0.020, 0.017);\nuniform vec3 right_tint = vec3(0.082, 0.075, 0.064);\nuniform vec3 corner_brown_tint = vec3(0.095, 0.048, 0.022);\nuniform float left_alpha : hint_range(0.0, 1.0) = 0.92;\nuniform float right_alpha : hint_range(0.0, 1.0) = 0.78;\nuniform float edge_noise : hint_range(0.0, 0.10) = 0.025;\n\nfloat hash(vec2 p) {\n\treturn fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);\n}\n\nvoid fragment() {\n\tfloat grain = (hash(floor(FRAGCOORD.xy / 3.0)) - 0.5) * edge_noise;\n\tfloat horizontal = smoothstep(0.18, 1.0, UV.x);\n\tfloat vertical_weight = mix(0.86, 1.0, smoothstep(0.04, 0.36, UV.y));\n\tvertical_weight *= mix(1.0, 0.90, smoothstep(0.78, 1.0, UV.y));\n\tvec3 dark_grad = mix(left_tint, mid_tint, smoothstep(0.0, 0.54, UV.x));\n\tvec3 color_grad = mix(dark_grad, right_tint, horizontal * 0.42);\n\tfloat corner_warmth = (1.0 - smoothstep(0.00, 0.46, UV.x)) * (1.0 - smoothstep(0.00, 0.62, UV.y));\n\tcolor_grad = mix(color_grad, corner_brown_tint, corner_warmth * 0.52);\n\tfloat alpha = mix(left_alpha, right_alpha, horizontal) * vertical_weight + grain;\n\tCOLOR = vec4(color_grad, clamp(alpha, 0.0, 1.0));\n}\n"



























    _dark_event_reading_full_mask_material = ShaderMaterial.new()
    _dark_event_reading_full_mask_material.shader = shader
    return _dark_event_reading_full_mask_material


func _is_mobile_governance_overview_active() -> bool:
    return _is_mobile_portrait() and GameState.is_governance_mode() and current_left_tab in ["jushi", "dangan", "daoju", "lingwu"] and governance_active_card_index < 0




func _dark_gov_mask_color(base: Color) -> Color:
    if OS.get_name() == "Android":
        var c: = base

        c.a = minf(1.0, base.a * 1.6)
        return c
    return base

func _is_dark_governance_overview_active() -> bool:
    if GameState.theme != "dark":
        return false
    if not GameState.is_governance_mode():
        return false
    if governance_active_card_index >= 0:
        return false
    return is_instance_valid(governance_scroll) and governance_scroll.visible


func _apply_mobile_governance_background_mask() -> void :
    if not is_instance_valid(mobile_governance_background_mask):
        return
    mobile_governance_background_mask.visible = false
    mobile_governance_background_mask.color = Color(0.0, 0.0, 0.0, 0.5)


func _apply_mobile_event_reading_mask() -> void :
    if not is_instance_valid(mobile_event_reading_mask):
        return
    mobile_event_reading_mask.visible = _is_mobile_event_reading_active()
    mobile_event_reading_mask.color = MOBILE_EVENT_READING_MASK_COLOR


func _apply_mobile_event_background_alpha() -> void :
    if not is_instance_valid(game_background):
        return

    if _is_mobile_portrait():
        if game_background.texture != GAME_BG_DEFAULT:
            game_background.texture = GAME_BG_DEFAULT
        game_background.modulate.a = 0.2 if _is_mobile_event_reading_active() else 1.0
        _update_bianwu_defense_backdrop()
        return





    var is_event_active: = is_instance_valid(event_scroll) and event_scroll.visible




    var is_card_overview: = GameState.is_governance_mode() and governance_active_card_index < 0\
and is_instance_valid(governance_scroll) and governance_scroll.visible




    _apply_light_gov_backdrop(GameState.theme == "light" and is_card_overview)

    if is_card_overview:
        if game_background.texture != GAME_BG_GOVERNANCE_OVERVIEW:
            game_background.texture = GAME_BG_GOVERNANCE_OVERVIEW
        if GameState.theme == "light":



            if is_instance_valid(month_cards_container) and not month_cards_container.resized.is_connected(_position_light_gov_illustration):
                month_cards_container.resized.connect(_position_light_gov_illustration)
            _position_light_gov_illustration()
        else:
            game_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
            game_background.offset_left = 0
            game_background.offset_top = 0
            game_background.offset_right = 0
            game_background.offset_bottom = 0
    else:
        if game_background.texture != GAME_BG_DEFAULT:
            game_background.texture = GAME_BG_DEFAULT
        game_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

        game_background.offset_left = 0
        game_background.offset_top = 0
        game_background.offset_right = 0
        game_background.offset_bottom = 0



    var reading_event: = is_event_active or is_card_overview or _is_event_portrait_active()
    if reading_event:
        if GameState.theme == "light":


            game_background.modulate.a = 1.0 if is_card_overview else 0.0
        elif _is_dark_governance_overview_active():
            game_background.modulate.a = 0.8
        elif event_portrait_court_mode and not is_card_overview:

            game_background.modulate.a = 0.0
        elif _is_event_portrait_active():


            game_background.modulate.a = 0.22
        else:
            game_background.modulate.a = 0.95
    else:
        game_background.modulate.a = 1.0

    _update_bianwu_defense_backdrop()




func _position_light_gov_illustration() -> void :
    if GameState.theme != "light":
        return
    var is_overview: = GameState.is_governance_mode() and governance_active_card_index < 0\
and is_instance_valid(governance_scroll) and governance_scroll.visible
    if not is_overview:
        return
    if not is_instance_valid(game_background) or game_background.texture != GAME_BG_GOVERNANCE_OVERVIEW:
        return
    var vp: = get_viewport_rect().size
    if vp.x <= 0.0 or vp.y <= 0.0:
        return

    var center_x: = vp.x * 0.5
    if is_instance_valid(month_cards_container) and month_cards_container.size.x > 0.0:
        center_x = month_cards_container.global_position.x + month_cards_container.size.x * 0.5
    elif is_instance_valid(center_panel) and center_panel.size.x > 0.0:
        center_x = center_panel.global_position.x + center_panel.size.x * 0.5

    var top: = vp.y * 0.3
    if is_instance_valid(month_warning_wrapper) and month_warning_wrapper.is_inside_tree()\
and month_warning_wrapper.visible and month_warning_wrapper.size.y > 0.0:
        var r: = month_warning_wrapper.get_global_rect()
        top = r.position.y + r.size.y + 8.0

    var aspect: = 2.1
    var tex: = game_background.texture
    if tex != null and tex.get_height() > 0:
        aspect = float(tex.get_width()) / float(tex.get_height())
    var target_w: = vp.x * GAME_BG_LIGHT_ILLUST_WIDTH_RATIO
    var target_h: = target_w / aspect

    game_background.stretch_mode = TextureRect.STRETCH_SCALE
    var box_left: = center_x - target_w * 0.5
    game_background.offset_left = box_left
    game_background.offset_right = box_left + target_w - vp.x
    game_background.offset_top = top
    game_background.offset_bottom = top + target_h - vp.y


var _light_gov_backdrop: ColorRect = null
func _apply_light_gov_backdrop(show_it: bool) -> void :
    if _light_gov_backdrop == null:
        if not show_it:
            return
        _light_gov_backdrop = ColorRect.new()
        _light_gov_backdrop.name = "LightGovBackdrop"
        _light_gov_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
        _light_gov_backdrop.color = GAME_BG_LIGHT_GOV_BACKDROP
        add_child(_light_gov_backdrop)

        move_child(_light_gov_backdrop, 0)
        _light_gov_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _light_gov_backdrop.color = GAME_BG_LIGHT_GOV_BACKDROP
    _light_gov_backdrop.visible = show_it


func _show_help_overlay(target_btn: Control, title_text: String, desc_text: String) -> void :
    _help_overlay_controller.show_help_overlay(target_btn, title_text, desc_text)

func _close_help_overlays() -> void :
    _help_overlay_controller.close_help_overlays()



func _connect_help_btn_hover(btn: Control, title_text: String, desc_provider: Callable) -> void :
    if btn == null:
        return
    btn.mouse_entered.connect( func() -> void :
        if DisplayServer.is_touchscreen_available():
            return
        var desc: String = str(desc_provider.call())
        if desc == "":
            return
        _help_overlay_controller.show_help_overlay(btn, title_text, desc, true)
    )
    btn.mouse_exited.connect( func() -> void :


        if _help_overlay_controller.has_click_help_open():
            return
        _close_help_overlays()
    )

func _make_dianshi_panel_style(mobile_portrait: bool) -> StyleBoxFlat:
    var style = StyleBoxFlat.new()
    style.bg_color = Color(0, 0, 0, 0)
    style.border_width_left = 1;style.border_width_right = 1
    style.border_width_top = 1;style.border_width_bottom = 1
    style.border_color = DIANSHI_MODAL_BORDER
    style.corner_radius_top_left = 2;style.corner_radius_top_right = 2
    style.corner_radius_bottom_left = 2;style.corner_radius_bottom_right = 2
    style.content_margin_left = MOBILE_GAME_MODAL_PADDING if mobile_portrait else 34
    style.content_margin_right = MOBILE_GAME_MODAL_PADDING if mobile_portrait else 34
    style.content_margin_top = MOBILE_GAME_MODAL_PADDING if mobile_portrait else 28
    style.content_margin_bottom = MOBILE_GAME_MODAL_PADDING if mobile_portrait else 30

    style.shadow_size = 0 if GameState.theme == "light" else 18
    style.shadow_color = Color(0, 0, 0, 0.0 if GameState.theme == "light" else 0.42)
    return style

func _set_autowrap_labels_width_recursive(node: Node, target_width: float) -> void :
    if node is Label and node.autowrap_mode != TextServer.AUTOWRAP_OFF:
        node.custom_minimum_size.x = target_width
        node.update_minimum_size()
    for child in node.get_children():
        _set_autowrap_labels_width_recursive(child, target_width)


func _input(event: InputEvent) -> void :
    var press_position = _get_primary_press_position(event)
    if press_position != null:
        if settings_popup and settings_popup.visible and not settings_popup.get_global_rect().has_point(press_position) and not settings_btn.get_global_rect().has_point(press_position):
            _hide_settings_popup()
            get_viewport().set_input_as_handled()
            return

    if press_position != null and _tooltips._has_resource_tooltip_open():
        _tooltips._handle_resource_tooltip_dismissal(press_position)
        return




    if press_position != null and _is_click_info_popup_open():
        _dismiss_click_info_popups(press_position)
        return

    if _is_blocking_modal_open():
        return
    if _is_fullscreen_mobile_reading_tap(event):
        _try_continue_from_mobile_reading_tap()
        get_viewport().set_input_as_handled()
        return
    if _is_mobile_choice_narrative_tap(event):
        _return_to_mobile_event_reading()
        get_viewport().set_input_as_handled()
        return

func _is_click_info_popup_open() -> bool:
    return _help_overlay_controller.has_any_help_open() or Presenter.get_open_click_item_popup() != null

func _dismiss_click_info_popups(press_position: Vector2) -> void :
    _help_overlay_controller.dismiss_help_on_outside_press(press_position)
    var item_popup: Control = Presenter.get_open_click_item_popup()
    if item_popup != null and not item_popup.get_global_rect().has_point(press_position):
        Presenter._hide_item_hint_card(false)

func _on_silver_label_gui_input(event: InputEvent, anchor: Control = null) -> void :
    if _is_primary_press_event(event):
        if GameState.has_method("is_after_sun_chuanting_branch_split") and GameState.is_after_sun_chuanting_branch_split():
            return
        _show_silver_resource_tooltip(anchor)
        _pin_resource_tooltip_from_click()

func _on_grain_label_gui_input(event: InputEvent, anchor: Control = null) -> void :
    if _is_primary_press_event(event):
        if GameState.has_method("is_after_sun_chuanting_branch_split") and GameState.is_after_sun_chuanting_branch_split():
            return
        _show_grain_resource_tooltip(anchor)
        _pin_resource_tooltip_from_click()

func _on_bingyong_label_gui_input(event: InputEvent, anchor: Control = null) -> void :
    if _is_primary_press_event(event):
        if GameState.has_method("is_after_sun_chuanting_branch_split") and GameState.is_after_sun_chuanting_branch_split():
            return
        _show_bingyong_resource_tooltip(anchor)
        _pin_resource_tooltip_from_click()

func _on_refugee_label_gui_input(event: InputEvent, anchor: Control = null) -> void :
    if _is_primary_press_event(event):
        if GameState.has_method("is_after_sun_chuanting_branch_split") and GameState.is_after_sun_chuanting_branch_split():
            return
        _show_refugee_resource_tooltip(anchor)
        _pin_resource_tooltip_from_click()

func _on_pop_label_gui_input(event: InputEvent, anchor: Control = null) -> void :
    if _is_primary_press_event(event):
        if GameState.has_method("is_after_sun_chuanting_branch_split") and GameState.is_after_sun_chuanting_branch_split():
            return
        _show_pop_resource_tooltip(anchor)
        _pin_resource_tooltip_from_click()

func _show_silver_resource_tooltip(anchor: Control = null) -> void :
    if GameData.active_line == "bianwu":
        _tooltips._show_bianwu_resource_tooltip("liangcao", anchor)
        return
    _tooltips._show_silver_breakdown_tooltip(anchor)

func _show_grain_resource_tooltip(anchor: Control = null) -> void :
    if GameData.active_line == "bianwu":
        _tooltips._show_bianwu_resource_tooltip("xiangyin", anchor)
        return
    _tooltips._show_grain_breakdown_tooltip(anchor)

func _show_bingyong_resource_tooltip(anchor: Control = null) -> void :
    if GameData.active_line == "bianwu":
        _tooltips._show_bianwu_resource_tooltip("mapi", anchor)
        return
    _tooltips._show_bingyong_tooltip(anchor)

func _show_refugee_resource_tooltip(anchor: Control = null) -> void :
    if GameData.active_line == "bianwu":
        _tooltips._show_bianwu_resource_tooltip("zhanyi", anchor)
        return
    _tooltips._show_liumin_tooltip(anchor)

func _show_pop_resource_tooltip(anchor: Control = null) -> void :
    if GameData.active_line == "bianwu":
        _tooltips._show_bianwu_resource_tooltip("huoqi", anchor)
        return
    _tooltips._show_renkou_tooltip(anchor)



func _pin_resource_tooltip_from_click() -> void :
    _hover_tooltip_active = false


func _connect_resource_label_hover(label: Control, show_callable: Callable) -> void :
    if label == null:
        return

    var anchor: Control = label
    if label is Label:
        anchor = _tooltips._get_resource_tooltip_anchor(label)
    if anchor == null:
        anchor = label
    anchor.mouse_entered.connect( func() -> void :
        if DisplayServer.is_touchscreen_available():
            return
        if GameState.has_method("is_after_sun_chuanting_branch_split") and GameState.is_after_sun_chuanting_branch_split():
            return
        show_callable.call(anchor)
        _hover_tooltip_active = true
    )
    anchor.mouse_exited.connect( func() -> void :
        if _hover_tooltip_active:
            _tooltips._clear_resource_tooltips()
            _hover_tooltip_active = false
    )

func _spawn_floating_change_label(target_node: Control, diff: int) -> void :
    if target_node == null or not target_node.is_inside_tree():
        return

    var label: = Label.new()
    label.text = ("+%d" % diff) if diff > 0 else str(diff)

    var font_color: = Color(0.95, 0.75, 0.3) if diff > 0 else Color(0.78, 0.46, 0.42)
    label.add_theme_color_override("font_color", font_color)
    label.add_theme_font_size_override("font_size", 18)

    if target_node.has_theme_font("font"):
        label.add_theme_font_override("font", target_node.get_theme_font("font"))

    label.top_level = true

    var target_pos: = target_node.global_position
    var target_size: = target_node.size
    var start_pos: = target_pos + Vector2(target_size.x * 0.7, -12.0)
    label.position = start_pos

    target_node.add_child(label)

    var tween: = label.create_tween()
    var up_offset: = Vector2(0, -32)
    tween.tween_property(label, "position", start_pos + up_offset, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.parallel().tween_property(label, "modulate:a", 0.0, 0.65).set_delay(0.15)
    tween.tween_callback(label.queue_free)

func _animate_control_value_change(control: Control, diff: int, expected_new_value: Variant = null) -> void :
    if control == null:
        return
    _trigger_animations_after_frame(control, diff, expected_new_value)

func _parse_numeric_text(text: String) -> Dictionary:
    var result: = {
        "success": false, 
        "prefix": "", 
        "value": 0.0, 
        "suffix": "", 
        "is_int": true, 
        "has_wan": false
    }

    if text.contains("万"):
        result["has_wan"] = true

    var start_idx: = -1
    var end_idx: = -1
    for i in range(text.length()):
        var c: = text[i]
        if (c >= "0" and c <= "9") or (c == "." and start_idx != -1):
            if start_idx == -1:
                start_idx = i
            end_idx = i
        else:
            if start_idx != -1:
                break

    if start_idx == -1:
        return result

    result["success"] = true
    result["prefix"] = text.substr(0, start_idx)
    result["suffix"] = text.substr(end_idx + 1)

    var num_str: = text.substr(start_idx, end_idx - start_idx + 1)
    if num_str.contains("."):
        result["value"] = float(num_str)
        result["is_int"] = false
    else:
        result["value"] = float(int(num_str))
        result["is_int"] = true

    return result

func _find_numeric_label(node: Node) -> Label:
    if node == null:
        return null
    if node is Label:
        var parsed = _parse_numeric_text(node.text)
        if parsed["success"]:
            return node

    for child in node.get_children():
        var found = _find_numeric_label(child)
        if found != null:
            return found
    return null

func _trigger_animations_after_frame(control: Control, diff: int, expected_new_value: Variant = null) -> void :
    var control_name: = control.name
    var parent_node: = control.get_parent()

    if not control.is_inside_tree():
        await control.ready


    if control.is_inside_tree():
        await control.get_tree().process_frame

    var active_control = control
    if not is_instance_valid(active_control) or not active_control.is_inside_tree():
        if is_instance_valid(parent_node):
            active_control = parent_node.find_child(control_name, true, false) as Control

    if not is_instance_valid(active_control) or not active_control.is_inside_tree():
        return

    _spawn_floating_change_label(active_control, diff)
    CardAnimations.play_pulse(active_control, diff > 0, not _is_top_resource_label(active_control))


    var num_label: = _find_numeric_label(active_control)
    if num_label != null:
        var parsed: = _parse_numeric_text(num_label.text)
        if parsed["success"]:
            var actual_new_val: float = parsed["value"]
            if parsed["has_wan"]:
                actual_new_val = parsed["value"] * 10000.0
            if expected_new_value != null and int(round(actual_new_val)) != int(expected_new_value):
                return

            var actual_old_val: float = actual_new_val - float(diff)

            var tween: = num_label.create_tween()
            var update_text_func = func(current_temp_val: float):
                if not is_instance_valid(num_label):
                    return
                var display_str: = ""
                if parsed["has_wan"]:
                    display_str = parsed["prefix"] + _format_large_number(int(current_temp_val)) + parsed["suffix"].replace("万", "")
                else:
                    if parsed["is_int"]:
                        display_str = parsed["prefix"] + str(int(current_temp_val)) + parsed["suffix"]
                    else:
                        display_str = parsed["prefix"] + ("%.1f" % current_temp_val) + parsed["suffix"]
                num_label.text = display_str

            update_text_func.call(actual_old_val)
            tween.tween_method(update_text_func, actual_old_val, actual_new_val, 0.45).set_trans(Tween.TRANS_LINEAR)


func _update_choice_top_spacer() -> void :
    if event_vbox == null or choices_container == null:
        return
    var spacer: = event_vbox.get_node_or_null("ChoiceTopSpacer") as Control
    if spacer == null:
        spacer = Control.new()
        spacer.name = "ChoiceTopSpacer"
        spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        event_vbox.add_child(spacer)

    var target_idx: = choices_container.get_index()
    var current_idx: = spacer.get_index()
    if current_idx != target_idx - 1:
        if current_idx < target_idx:
            event_vbox.move_child(spacer, target_idx - 1)
        else:
            event_vbox.move_child(spacer, target_idx)

    var is_mobile: = _is_mobile_portrait()
    if is_mobile:
        spacer.visible = false
        spacer.custom_minimum_size = Vector2.ZERO
    else:
        spacer.visible = choices_container.visible
        spacer.custom_minimum_size = Vector2(0, 14 if spacer.visible else 0)


func _update_dialogue_narrative_spacing() -> void :
    if event_vbox == null or speaker_bubble == null or narrative_label == null:
        return
    var spacer: = event_vbox.get_node_or_null("DialogueNarrativeSpacer") as Control
    if spacer == null:
        spacer = Control.new()
        spacer.name = "DialogueNarrativeSpacer"
        spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        event_vbox.add_child(spacer)

    var target_node: Control = narrative_label
    if is_instance_valid(mobile_reading_card) and mobile_reading_card.get_parent() == event_vbox:
        target_node = mobile_reading_card

    var target_idx: = target_node.get_index()
    var current_idx: = spacer.get_index()
    if current_idx != target_idx - 1:
        if current_idx < target_idx:
            event_vbox.move_child(spacer, target_idx - 1)
        else:
            event_vbox.move_child(spacer, target_idx)

    var is_mobile: = _is_mobile_portrait()
    if is_mobile:
        spacer.visible = false
        spacer.custom_minimum_size = Vector2.ZERO
    else:
        spacer.visible = speaker_bubble.visible and narrative_label.visible and not _is_event_portrait_active()


        spacer.custom_minimum_size = Vector2(0, 20 if spacer.visible else 0)








const EVENT_PORTRAIT_AREA_RATIO: = 0.27
const EVENT_PORTRAIT_AREA_MIN_WIDTH: = 280.0
const EVENT_PORTRAIT_AREA_MAX_WIDTH: = 640.0
const EVENT_PORTRAIT_DECOR_ALPHA: = 0.08
const EVENT_PORTRAIT_HEIGHT_RATIO: = 0.86

const EVENT_PORTRAIT_OFFICE_BG_ALPHA: = 0.55

const EVENT_PORTRAIT_RIGHT_SHIFT_RATIO: = 1.0
const EVENT_PORTRAIT_RIGHT_OVERFLOW: = 40.0
const EVENT_PORTRAIT_SPEAKER_TOP_RATIO: = 0.7
const EVENT_PORTRAIT_SPEAKER_MAX_WIDTH: = 380.0

const EVENT_PORTRAIT_CENTER_MIN_WIDTH: = 560.0



const EVENT_PORTRAIT_TEXT_MIN_WIDTH: = 540.0
const EVENT_PORTRAIT_TEXT_MAX_WIDTH: = 920.0

const EVENT_PORTRAIT_TEXT_SIDE_RESERVE: = 48.0






const EVENT_PORTRAIT_TEXT_OVERLAP: = 160.0

const NO_PORTRAIT_EVENT_TEXT_MAX_WIDTH: = 860.0

var event_portrait_layer: Control = null
var event_portrait_backdrop: Control = null
var event_portrait_zone: Control = null
var event_portrait_decor: TextureRect = null
var event_portrait_rect: TextureRect = null
var event_portrait_office_bg: TextureRect = null
var event_portrait_right_backing: TextureRect = null
var event_portrait_court_mode: bool = false

var event_portrait_hide_backdrop: bool = false
var event_portrait_speaker_anchor: VBoxContainer = null
var event_portrait_speaker_frame: PanelContainer = null
var _dark_event_reading_mask_material: ShaderMaterial
var _dark_event_reading_full_mask_material: ShaderMaterial

func _is_court_session_event(evt: Dictionary) -> bool:
    return bool(evt.get("is_court_session", false)) and GameState.is_governance_mode()


const SIDEBAR_TITLE_BOLD_FONT_PATH: = "res://assets/fonts/NotoSerifSC-Bold.otf"
var _sidebar_title_bold_font: Font = null

func _apply_sidebar_title_font(label: Node) -> void :
    if not is_instance_valid(label):
        return
    if _sidebar_title_bold_font == null:
        _sidebar_title_bold_font = load(SIDEBAR_TITLE_BOLD_FONT_PATH) as Font
    if _sidebar_title_bold_font != null:
        label.add_theme_font_override("font", _sidebar_title_bold_font)



const ACTION_POINTS_HEX_BG_SHADER: = "\nshader_type canvas_item;\nuniform float corner = 0.05;\nuniform float border = 0.06;\nuniform float hex_r = 0.84;\nuniform vec4 fill_color : source_color = vec4(0.10, 0.09, 0.07, 1.0);\nuniform vec4 border_color : source_color = vec4(0.80, 0.66, 0.40, 1.0);\nfloat sd_hex(vec2 p, float r) {\n\tconst vec3 k = vec3(-0.866025404, 0.5, 0.577350269);\n\tp = abs(p);\n\tp -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;\n\tp -= vec2(clamp(p.x, -k.z * r, k.z * r), r);\n\treturn length(p) * sign(p.y);\n}\nvoid fragment() {\n\tvec2 p = (UV - vec2(0.5)) * 2.0;\n\tfloat dist = sd_hex(p, hex_r - corner) - corner;\n\tif (dist > 0.004) { discard; }\n\tfloat aa = smoothstep(0.004, -0.004, dist);\n\tfloat edge = smoothstep(-border, -border + 0.012, dist);\n\tvec3 rgb = mix(fill_color.rgb, border_color.rgb, edge);\n\tCOLOR = vec4(rgb, aa);\n}\n"
























const ACTION_POINTS_PORTRAIT_SHADER: = "\nshader_type canvas_item;\n// 平顶六边形（左右为顶点），圆角 corner，边框 border；focus/crop_frac 同前。\nuniform vec2 focus = vec2(0.5, 0.2);\nuniform float crop_frac = 0.62;\nuniform float corner = 0.05;\nuniform float border = 0.05;\nuniform float hex_r = 0.78;\nuniform vec4 border_color : source_color = vec4(0.72, 0.60, 0.36, 0.85);\nfloat sd_hex(vec2 p, float r) {\n\tconst vec3 k = vec3(-0.866025404, 0.5, 0.577350269);\n\tp = abs(p);\n\tp -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;\n\tp -= vec2(clamp(p.x, -k.z * r, k.z * r), r);\n\treturn length(p) * sign(p.y);\n}\nvoid fragment() {\n\tvec2 p = (UV - vec2(0.5)) * 2.0;\n\tfloat dist = sd_hex(p, hex_r - corner) - corner;\n\tif (dist > 0.004) { discard; }\n\tvec2 tex_size = 1.0 / TEXTURE_PIXEL_SIZE;\n\tfloat aspect = tex_size.x / tex_size.y;\n\tvec2 crop = vec2(crop_frac, crop_frac * aspect);\n\tvec2 src_uv = focus + (UV - vec2(0.5)) * crop;\n\tvec4 col = texture(TEXTURE, src_uv);\n\tfloat aa = smoothstep(0.004, -0.004, dist);\n\tfloat edge = smoothstep(-border, -border + 0.006, dist);\n\tvec3 rgb = mix(col.rgb, border_color.rgb, edge * border_color.a);\n\tCOLOR = vec4(rgb, col.a * aa);\n}\n"
































const DOSSIER_AVATAR_SHADER: = "\nshader_type canvas_item;\n// focus：源图中要落在圆心的归一化坐标；crop_frac：方形裁剪边长占源图宽度的比例\nuniform vec2 focus = vec2(0.5, 0.2);\nuniform float crop_frac = 0.6;\nvoid fragment() {\n\tfloat r = length(UV - vec2(0.5));\n\tif (r > 0.5) { discard; }\n\tvec2 tex_size = 1.0 / TEXTURE_PIXEL_SIZE;\n\tfloat aspect = tex_size.x / tex_size.y;\n\tvec2 crop = vec2(crop_frac, crop_frac * aspect);\n\tvec2 src_uv = focus + (UV - vec2(0.5)) * crop;\n\tvec4 col = texture(TEXTURE, src_uv);\n\tfloat aa = smoothstep(0.5, 0.485, r);\n\tCOLOR = vec4(col.rgb, col.a * aa);\n}\n"

















func _refresh_dossier_avatar() -> void :
    var section: = archive_section
    if not is_instance_valid(section):
        return
    var holder: = section.get_node_or_null("DossierAvatar") as CenterContainer
    if holder != null:
        holder.visible = false

func _current_event_uses_player_rank_portrait(evt: Dictionary) -> bool:
    return _is_court_session_event(evt) or bool(evt.get("isEnding", false))


func _get_player_rank_portrait_path(override_title: String = "") -> String:
    if not GameState.has_feature("rank_portrait"):
        return ""

    if CHARACTER_FIXED_RANK_PORTRAIT.has(GameState.char_id):
        return CHARACTER_FIXED_RANK_PORTRAIT[GameState.char_id]
    var title: = override_title if override_title != "" else GameState.get_rank_title()
    for grade in PLAYER_RANK_PORTRAIT_MAP:
        if title.contains(grade):
            return PLAYER_RANK_PORTRAIT_MAP[grade]
    return ""


func _get_player_identity_label() -> String:
    var province: = str(GameState.city.get("province", ""))
    var city_name: = GameState.get_current_city_name()
    var office: = GameState.get_office_title()
    return "%s%s%s" % [province, city_name, office]


func _apply_court_session_player_speaker(evt: Dictionary) -> void :
    if not _is_court_session_event(evt):
        return
    evt["speaker"] = {"name": "你", "role": _get_player_identity_label(), "faction": ""}
var event_portrait_avatar_orig_style: StyleBox = null
var event_portrait_loading_tween: Tween = null
var speaker_box_home_parent: Node = null
var speaker_box_home_index: int = -1

var _event_portrait_speaker_clamp_pending: = false
var _event_portrait_relayout_pending: = false
var _event_portrait_loading_animation_pending: = false

var _pending_portrait_path: String = ""
var _pending_portrait_is_placeholder: = false



func _queue_event_portrait_relayout_check() -> void :
    if _event_portrait_relayout_pending:
        return
    _event_portrait_relayout_pending = true
    _run_event_portrait_relayout_check()

func _run_event_portrait_relayout_check() -> void :
    await get_tree().process_frame

    _update_event_portrait_layout()
    _event_portrait_relayout_pending = false


func _queue_event_portrait_speaker_clamp() -> void :
    if _event_portrait_speaker_clamp_pending:
        return
    _event_portrait_speaker_clamp_pending = true
    _run_event_portrait_speaker_clamp()

func _run_event_portrait_speaker_clamp() -> void :
    await get_tree().process_frame
    await get_tree().process_frame
    _event_portrait_speaker_clamp_pending = false
    if _is_event_portrait_active():
        _event_portrait_controller.clamp_speaker_anchor_bottom()



func _set_event_portrait_async(portrait_path: String, is_placeholder: bool) -> void :
    if not is_instance_valid(event_portrait_rect):
        return
    if ResourceLoader.has_cached(portrait_path):
        _pending_portrait_path = ""
        _apply_event_portrait_texture(load(portrait_path), is_placeholder)
        return
    _pending_portrait_path = portrait_path
    _pending_portrait_is_placeholder = is_placeholder
    event_portrait_rect.texture = null
    ResourceLoader.load_threaded_request(portrait_path)

func _apply_event_portrait_texture(tex: Texture2D, is_placeholder: bool) -> void :
    if not is_instance_valid(event_portrait_rect):
        return
    event_portrait_rect.texture = tex
    if is_placeholder:
        var placeholder_tint: = Color(0.85, 0.83, 0.8, 1.0) if GameState.theme == "light" else Color(0.4, 0.38, 0.36, 1.0)
        event_portrait_rect.material = PortraitBacking.make_silhouette_material(placeholder_tint)
        event_portrait_rect.modulate = Color(1, 1, 1, 1)
    else:
        event_portrait_rect.material = null
        event_portrait_rect.modulate = Color(1, 1, 1, 1)


func _poll_pending_event_portrait() -> void :
    if _pending_portrait_path == "":
        return
    var path: = _pending_portrait_path
    var st: = ResourceLoader.load_threaded_get_status(path)
    if st == ResourceLoader.THREAD_LOAD_LOADED:
        var tex: = ResourceLoader.load_threaded_get(path) as Texture2D
        _pending_portrait_path = ""
        if tex != null and is_instance_valid(event_portrait_rect):
            _apply_event_portrait_texture(tex, _pending_portrait_is_placeholder)
            if _is_event_portrait_active():
                _request_event_portrait_loading_animation()
                _update_event_portrait_layout()
    elif st == ResourceLoader.THREAD_LOAD_FAILED or st == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
        var fallback_tex: = load(path) as Texture2D
        _pending_portrait_path = ""
        if fallback_tex != null and is_instance_valid(event_portrait_rect):
            _apply_event_portrait_texture(fallback_tex, _pending_portrait_is_placeholder)
            if _is_event_portrait_active():
                _request_event_portrait_loading_animation()
                _update_event_portrait_layout()

func _request_event_portrait_loading_animation() -> void :
    _event_portrait_loading_animation_pending = true

func _queue_event_portrait_loading_animation() -> void :
    call_deferred("_run_event_portrait_loading_animation")

func _run_event_portrait_loading_animation() -> void :
    await get_tree().process_frame
    if _is_event_portrait_active():
        _event_portrait_controller.play_loading_animation()

func _is_event_portrait_active() -> bool:
    if OS.has_feature("web"):
        return false
    return is_instance_valid(event_portrait_layer) and event_portrait_layer.visible

func _is_desktop_event_reading_without_portraits() -> bool:
    if _is_mobile_portrait():
        return false
    if not is_instance_valid(event_scroll) or not event_scroll.visible:
        return false
    if not (GameState.is_governance_mode() or speaker_bubble.visible):
        return false
    return OS.has_feature("web") or not GameState.event_portraits_enabled

func _get_speaker_box_control() -> Control:


    return speaker_bubble.get_parent() as Control

func _event_portrait_window_size() -> Vector2:
    var window_size: = get_viewport_rect().size
    if window_size.x <= 0.0 or window_size.y <= 0.0:
        window_size = _get_responsive_window_size()
    return window_size





func _bw_sidebar_collapsed_panel_width() -> float:
    var w: = 0.0
    if left_tabs_host != null and is_instance_valid(left_tabs_host):
        w = left_tabs_host.size.x
    if w <= 0.0 and left_tabs != null and is_instance_valid(left_tabs):
        w = left_tabs.custom_minimum_size.x
    var lp: = _bw_left_panel()
    if lp != null:
        var sb: = lp.get_theme_stylebox("panel")
        if sb != null:
            w += sb.get_margin(SIDE_LEFT) + sb.get_margin(SIDE_RIGHT)
    return w

func _active_left_panel_width() -> float:

    if _bw_sidebar_collapsed and _sidebar_collapse_supported():
        return _bw_sidebar_collapsed_panel_width()
    return NATIVE_LANDSCAPE_LEFT_PANEL_WIDTH if _is_native_mobile_landscape() else DESKTOP_LEFT_PANEL_WIDTH


const SIDEBAR_COLLAPSED_TEXT_WIDTH_BONUS: = 120.0



func _reassert_bw_sidebar_collapsed_width() -> void :
    if not (_bw_sidebar_collapsed and _sidebar_collapse_supported()):
        return
    if left_panel != null and is_instance_valid(left_panel):
        var cw: = _bw_sidebar_collapsed_panel_width()

        if left_panel.custom_minimum_size.x > cw + 1.0:
            _bw_sidebar_expanded_min_w = left_panel.custom_minimum_size.x
        left_panel.custom_minimum_size.x = cw
    if left_content_margin != null and is_instance_valid(left_content_margin):
        left_content_margin.visible = false

func _sidebar_collapsed_text_bonus() -> float:
    return SIDEBAR_COLLAPSED_TEXT_WIDTH_BONUS if (_bw_sidebar_collapsed and _sidebar_collapse_supported()) else 0.0

func _event_portrait_area_width() -> float:
    var window_size: = _event_portrait_window_size()
    var wanted: = clampf(window_size.x * EVENT_PORTRAIT_AREA_RATIO, EVENT_PORTRAIT_AREA_MIN_WIDTH, EVENT_PORTRAIT_AREA_MAX_WIDTH)

    var insets: = _get_safe_area_horizontal_insets()
    var available: = window_size.x - insets.x - insets.y - _active_left_panel_width() - _event_portrait_center_floor() - _center_panel_side_chrome()
    return clampf(minf(wanted, available), EVENT_PORTRAIT_AREA_MIN_WIDTH, EVENT_PORTRAIT_AREA_MAX_WIDTH)


func _center_panel_side_chrome() -> float:
    var sb: = center_panel.get_theme_stylebox("panel")
    if sb != null:
        return sb.get_margin(SIDE_LEFT) + sb.get_margin(SIDE_RIGHT)
    return 0.0





func _event_portrait_center_floor() -> float:
    return EVENT_PORTRAIT_CENTER_MIN_WIDTH



func _desktop_center_min_width() -> float:
    var available: = _event_portrait_window_size().x - _active_left_panel_width() - _center_panel_side_chrome()
    return minf(1000.0 + _sidebar_collapsed_text_bonus(), maxf(available, 0.0))

func _ensure_event_portrait_layer() -> void :
    _event_portrait_controller.ensure_layer()

func _make_speaker_frame_style() -> StyleBoxFlat:
    return _event_portrait_controller.make_speaker_frame_style()


func _draw_speaker_frame_corners() -> void :
    _event_portrait_controller.draw_speaker_frame_corners(event_portrait_speaker_frame)

func _make_speaker_avatar_circle_style() -> StyleBoxFlat:
    return _event_portrait_controller.make_speaker_avatar_circle_style()


func _apply_speaker_header_frame(active: bool, speaker_box: Control) -> void :
    _event_portrait_controller.apply_speaker_header_frame(active, speaker_box)
    _apply_dynamic_theme()

func _layout_event_portrait_zone(area_width: float) -> void :
    _event_portrait_controller.layout_zone(area_width)

func _set_event_portrait_spacer_width(width: float) -> void :
    _event_portrait_controller.set_spacer_width(width)






const PORTRAIT_CENTER_BG_FADE_START: = 0.14
var _portrait_center_bg_active: = false


func _left_panel_text_color(key: String) -> Color:
    if GameState.theme == "light":
        return GameState.theme_colors["dark"].get(key, GameState.get_theme_color(key))
    return GameState.get_theme_color(key)

func _set_center_panel_bg_transparent(active: bool) -> void :
    var cs: = center_panel.get_theme_stylebox("panel") as StyleBoxFlat
    if cs != null:



        cs.bg_color.a = 0.0 if (active or GameState.theme == "light") else 0.56
    _portrait_center_bg_active = active
    if not center_panel.draw.is_connected(_draw_portrait_center_bg):
        center_panel.draw.connect(_draw_portrait_center_bg)
    if center_panel.is_inside_tree():
        center_panel.queue_redraw()

var _portrait_center_bg_texture: GradientTexture2D = null
var _portrait_center_bg_texture_theme: = ""

var _portrait_center_bg_width: = 0.0
func _draw_portrait_center_bg() -> void :
    if not _portrait_center_bg_active:
        return
    if _portrait_center_bg_texture == null or _portrait_center_bg_texture_theme != GameState.theme:
        var base: = Color("#E1E1E1") if GameState.theme == "light" else Color(0.115, 0.112, 0.105)
        var grad: = Gradient.new()


        grad.set_offset(0, 0.0)
        grad.set_color(0, Color(base.r, base.g, base.b, 0.0))
        grad.set_offset(1, 1.0)
        grad.set_color(1, Color(base.r, base.g, base.b, 0.0))
        grad.add_point(PORTRAIT_CENTER_BG_FADE_START, Color(base.r, base.g, base.b, 1.0))
        grad.add_point(1.0 - PORTRAIT_CENTER_BG_FADE_START, Color(base.r, base.g, base.b, 1.0))
        _portrait_center_bg_texture = GradientTexture2D.new()
        _portrait_center_bg_texture.gradient = grad
        _portrait_center_bg_texture.width = 256
        _portrait_center_bg_texture.height = 8
        _portrait_center_bg_texture.fill_from = Vector2(0.0, 0.5)
        _portrait_center_bg_texture.fill_to = Vector2(1.0, 0.5)
        _portrait_center_bg_texture_theme = GameState.theme



    var bg_width: float = _portrait_center_bg_width if _portrait_center_bg_width > 0.0 else center_panel.size.x
    bg_width = minf(bg_width, center_panel.size.x)
    center_panel.draw_texture_rect(_portrait_center_bg_texture, Rect2(Vector2.ZERO, Vector2(bg_width, center_panel.size.y)), false)

func _update_event_portrait_layout() -> void :


    var active: = ( not _is_mobile_portrait()) and event_scroll.visible and GameState.event_portraits_enabled and (GameState.is_governance_mode() or speaker_bubble.visible)
    if OS.has_feature("web"):
        active = false
    if active:

        var min_total: = _active_left_panel_width() + _event_portrait_center_floor() + EVENT_PORTRAIT_AREA_MIN_WIDTH + _center_panel_side_chrome()
        if _event_portrait_window_size().x < min_total:
            active = false
        if OS.get_environment("DEBUG_PORTRAIT_LAYOUT") == "1":
            print("[portrait] vp=%.0f floor=%.0f min_total=%.0f active=%s evt_vis=%s" % [
                _event_portrait_window_size().x, _event_portrait_center_floor(), min_total, active, event_scroll.visible])

        _queue_event_portrait_relayout_check()
    if active:
        _ensure_event_portrait_layer()
    if not is_instance_valid(event_portrait_layer):
        _set_event_portrait_spacer_width(0.0)
        if _is_desktop_event_reading_without_portraits():
            _set_event_text_width_constraints(NO_PORTRAIT_EVENT_TEXT_MAX_WIDTH + _sidebar_collapsed_text_bonus())
            _set_no_portrait_speaker_width_constraint(NO_PORTRAIT_EVENT_TEXT_MAX_WIDTH + _sidebar_collapsed_text_bonus())
        else:
            _set_event_text_width_constraints(0.0)
            _set_no_portrait_speaker_width_constraint(0.0)
        return
    var speaker_box: = _get_speaker_box_control()
    var center_margin: MarginContainer = $MainVBox / Layout / CenterPanel / CenterMargin
    if active:
        var area_width: = _event_portrait_area_width()
        _layout_event_portrait_zone(area_width)
        event_vbox.add_theme_constant_override("separation", 18)
        title_rule.visible = false


        var window_size: = _event_portrait_window_size()


        var reserved_width: = maxf(area_width - EVENT_PORTRAIT_TEXT_OVERLAP, EVENT_PORTRAIT_AREA_MIN_WIDTH * 0.5)
        var center_available: = window_size.x - _active_left_panel_width() - reserved_width - _center_panel_side_chrome()
        center_margin.custom_minimum_size.x = maxf(center_available, EVENT_PORTRAIT_CENTER_MIN_WIDTH)


        var text_available: = window_size.x - _active_left_panel_width() - area_width - _center_panel_side_chrome()
        _set_event_text_width_constraints(clampf(text_available - EVENT_PORTRAIT_TEXT_SIDE_RESERVE, EVENT_PORTRAIT_TEXT_MIN_WIDTH, EVENT_PORTRAIT_TEXT_MAX_WIDTH + _sidebar_collapsed_text_bonus()))


        _portrait_center_bg_width = maxf(text_available, EVENT_PORTRAIT_CENTER_MIN_WIDTH)
        _set_no_portrait_speaker_width_constraint(0.0)
        if speaker_box != null and speaker_box.get_parent() != event_portrait_speaker_anchor:
            if speaker_box_home_parent == null:
                speaker_box_home_parent = speaker_box.get_parent()
                speaker_box_home_index = speaker_box.get_index()
            speaker_box.get_parent().remove_child(speaker_box)
            event_portrait_speaker_anchor.add_child(speaker_box)
        if speaker_box != null:
            _apply_speaker_header_frame(true, speaker_box)
        event_portrait_layer.visible = true
        if is_instance_valid(event_portrait_backdrop):
            event_portrait_backdrop.visible = true

        _set_center_panel_bg_transparent(true)
        _set_event_portrait_spacer_width(reserved_width)
        _queue_event_portrait_speaker_clamp()
        if _event_portrait_loading_animation_pending:
            _event_portrait_loading_animation_pending = false
            _queue_event_portrait_loading_animation()
    else:
        if not _is_mobile_portrait():
            event_vbox.add_theme_constant_override("separation", 16)
            title_rule.visible = true
        if speaker_box != null:
            _apply_speaker_header_frame(false, speaker_box)
        if speaker_box != null and speaker_box_home_parent != null and speaker_box.get_parent() != speaker_box_home_parent:
            speaker_box.get_parent().remove_child(speaker_box)
            speaker_box_home_parent.add_child(speaker_box)
            speaker_box_home_parent.move_child(speaker_box, clampi(speaker_box_home_index, 0, speaker_box_home_parent.get_child_count() - 1))
        event_portrait_layer.visible = false
        if is_instance_valid(event_portrait_backdrop):
            event_portrait_backdrop.visible = false
        _set_center_panel_bg_transparent(false)
        _set_event_portrait_spacer_width(0.0)
        _set_event_text_width_constraints((NO_PORTRAIT_EVENT_TEXT_MAX_WIDTH + _sidebar_collapsed_text_bonus()) if _is_desktop_event_reading_without_portraits() else 0.0)
        _set_no_portrait_speaker_width_constraint((NO_PORTRAIT_EVENT_TEXT_MAX_WIDTH + _sidebar_collapsed_text_bonus()) if _is_desktop_event_reading_without_portraits() else 0.0)
        if not _is_mobile_portrait():




            if _is_native_mobile_landscape():
                center_margin.custom_minimum_size.x = _get_native_mobile_landscape_center_min_width()
            else:
                center_margin.custom_minimum_size.x = _desktop_center_min_width()
    _update_dialogue_narrative_spacing()


func _set_event_text_width_constraints(width: float) -> void :
    _event_portrait_controller.set_event_text_width_constraints(width)

func _set_no_portrait_speaker_width_constraint(width: float) -> void :
    var speaker_box: = _get_speaker_box_control()
    for node in [speaker_box, speaker_bubble]:
        var control: = node as Control
        if control == null or not is_instance_valid(control):
            continue
        if width > 0.0:
            control.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
            control.custom_minimum_size.x = width
        else:
            control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            control.custom_minimum_size.x = 0



func _attach_choice_hint_to_title_row(title_row: BoxContainer, hint: Control) -> bool:
    if title_row == null or hint == null:
        return false
    var tag_row: = title_row.get_node_or_null("ChoiceTagRow") as BoxContainer
    if tag_row == null:
        return false
    if not (hint.size_flags_horizontal & Control.SIZE_EXPAND):
        hint.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    if hint is Label:
        (hint as Label).vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    tag_row.add_child(hint)
    tag_row.visible = true
    return true
