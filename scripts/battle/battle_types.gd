extends RefCounted






const CAT_POLE: = "pole"
const CAT_CAV: = "cav"
const CAT_RANGED: = "ranged"
const CAT_SHIELD: = "shield"
const COUNTER_BONUS: = 1.3

const COUNTERS: = {
    CAT_POLE: CAT_CAV, 
    CAT_CAV: CAT_RANGED, 
    CAT_RANGED: CAT_SHIELD, 
    CAT_SHIELD: CAT_POLE, 
}





const POS_FENG: = 0
const POS_LEFT: = 1
const POS_CENTER: = 2
const POS_RIGHT: = 3
const POS_REAR: = 4
const POS_REAR_R: = 5

const FRONT_POSITIONS: = [POS_FENG, POS_LEFT, POS_CENTER, POS_RIGHT, POS_REAR, POS_REAR_R]
const POS_NAMES: = {0: "前锋", 1: "左翼", 2: "中军", 3: "右翼", 4: "后翼", 5: "后翼"}
const ADJACENT_POSITIONS: = {
    POS_FENG: [POS_LEFT, POS_RIGHT, POS_CENTER], 
    POS_LEFT: [POS_FENG, POS_REAR], 
    POS_CENTER: [POS_FENG, POS_REAR, POS_REAR_R], 
    POS_RIGHT: [POS_FENG, POS_REAR_R], 
    POS_REAR: [POS_LEFT, POS_CENTER], 
    POS_REAR_R: [POS_RIGHT, POS_CENTER], 
}

const COL_FRONT: = [POS_LEFT, POS_FENG, POS_RIGHT]
const COL_BACK: = [POS_REAR, POS_CENTER, POS_REAR_R]
const COLUMN_OF: = {
    POS_LEFT: 0, POS_REAR: 0, 
    POS_FENG: 1, POS_CENTER: 1, 
    POS_RIGHT: 2, POS_REAR_R: 2, 
}

const RING: = [POS_LEFT, POS_FENG, POS_RIGHT, POS_REAR_R, POS_CENTER, POS_REAR]



const UNITS: = {

    "knife_shield": {"name": "刀牌手", "cat": CAT_SHIELD, "atk": 2, "hp": 1000, "reload": 0, "tags": ["bulwark"], "dmg_reduction": 0.25, "elite": false}, 
    "spear": {"name": "长枪手", "cat": CAT_POLE, "atk": 1, "hp": 800, "reload": 0, "tags": ["anti_cav"], "elite": false}, 
    "bow": {"name": "弓弩手", "cat": CAT_RANGED, "atk": 10, "hp": 600, "reload": 0, "tags": ["ranged"], "elite": false}, 
    "musket": {"name": "火铳手", "cat": CAT_RANGED, "atk": 16, "hp": 500, "reload": 1, "tags": ["ranged", "firearm"], "elite": false}, 
    "cavalry": {"name": "骑兵", "cat": CAT_CAV, "atk": 14, "hp": 800, "reload": 0, "tags": ["charge", "flank_first"], "elite": false}, 
    "cannon": {"name": "炮手", "cat": CAT_RANGED, "atk": 18, "hp": 300, "reload": 2, "tags": ["ranged", "firearm", "splash1"], "elite": false}, 

    "langxian": {"name": "狼筅兵", "cat": CAT_SHIELD, "atk": 14, "hp": 1200, "reload": 0, "tags": ["bulwark", "share20"], "dmg_reduction": 0.25, "elite": true}, 
    "baigan": {"name": "白杆兵", "cat": CAT_POLE, "atk": 16, "hp": 1000, "reload": 0, "tags": ["anti_cav", "pull"], "elite": true}, 
    "qinbow": {"name": "秦兵弩手", "cat": CAT_RANGED, "atk": 14, "hp": 800, "reload": 0, "tags": ["ranged", "ramp"], "elite": true}, 
    "chariot": {"name": "戚家军车营", "cat": CAT_RANGED, "atk": 18, "hp": 900, "reload": 1, "tags": ["ranged", "firearm", "reload_shield", "block_charge"], "elite": true}, 
    "redcannon": {"name": "红夷大炮营", "cat": CAT_RANGED, "atk": 24, "hp": 500, "reload": 2, "tags": ["ranged", "firearm", "splash2", "siege_bonus"], "elite": true}, 
    "guanning": {"name": "关宁铁骑", "cat": CAT_CAV, "atk": 20, "hp": 1100, "reload": 0, "tags": ["charge", "flank_first", "volley"], "elite": true}, 
}


const TERRAIN: = {
    "plain": {"name": "平原"}, 
    "narrow": {"name": "窄路·关隘", "flanks_safe": true, "defender_reduction": 0.3, "arty_bonus": 0.5}, 
    "siege": {"name": "守城", "all_reduction": 0.2, "arty_bonus": 0.5, "charge_penalty": 1}, 
    "mountain": {"name": "山地", "infantry_bonus": 0.15, "cav_penalty": 0.2, "no_charge": true}, 
    "ford": {"name": "河口·渡口", "first_turn_attacker_penalty": 0.3}, 
}



const SKILLS: = {
    "yuanyang": {"name": "鸳鸯阵", "from": "戚继光", "desc": "2 回合内前阵全体减伤 30% + 互相补刀", "duration": 2, "cooldown": 3}, 
    "pingjian": {"name": "凭坚城用大炮", "from": "袁崇焕", "desc": "本回合炮/红夷攻击 ×2 且覆盖敌全前阵", "duration": 1, "cooldown": 3}, 
    "huoche": {"name": "火车营齐射", "from": "孙传庭", "desc": "本回合所有火器无视装填齐射全场", "duration": 1, "cooldown": 4}, 
    "baiganpo": {"name": "白杆破阵", "from": "秦良玉", "desc": "拉拽敌方全部骑兵下马，2 回合不能冲锋", "duration": 2, "cooldown": 3}, 
    "tianxiong": {"name": "天雄死战", "from": "卢象升", "desc": "本回合指定残血单位攻击 ×1.8 且不溃", "duration": 1, "cooldown": 3}, 
    "yizouzhi": {"name": "以走制敌", "from": "洪承畴", "desc": "后撤 1 回合：全军不接战、回兵力 30%", "duration": 1, "cooldown": 4}, 
}


const DEFAULT_AMMO: = 9
const DEFAULT_HORSE: = 4
const MORALE_FULL: = 100


const ATK_MULT_CAP: = 2.2
const REDUCTION_CAP: = 0.6

static func unit_def(id: String) -> Dictionary:
    return UNITS.get(id, {})


static func counters(attacker_cat: String, defender_cat: String) -> bool:
    return COUNTERS.get(attacker_cat, "") == defender_cat
