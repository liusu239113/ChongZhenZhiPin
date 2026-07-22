extends RefCounted
class_name GovernanceCalendarText





static func governance_assessment_year() -> int:
    var act: int = maxi(1, int(GameState.get_current_governance_act()))
    var start_year: int = 1 + (act - 1) * 3
    return start_year + 2

static func month_name(month_idx: int) -> String:
    if not GameData.SEASON_NAMES.is_empty():
        var season_idx: = clampi(month_idx - 1, 0, GameData.SEASON_NAMES.size() - 1)
        return str(GameData.SEASON_NAMES[season_idx])
    if month_idx > 0 and month_idx <= GameData.MONTH_NAMES.size():
        return str(GameData.MONTH_NAMES[month_idx - 1])
    return "腊月" if month_idx == 12 else "正月"

static func format_cz_year(year: int) -> String:
    if year <= 0:
        return ""
    if year == 1:
        return "崇祯元年"
    var units: = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
    var tens: = ["", "十", "二十", "三十", "四十", "五十", "六十"]
    var t: int = year / 10
    var u: int = year % 10
    var text: String = tens[t] + units[u]
    if text == "十":
        return "崇祯十年"
    return "崇祯%s年" % text
