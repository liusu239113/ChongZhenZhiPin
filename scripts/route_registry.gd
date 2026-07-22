extends RefCounted












const BUCKET_ORDER: = ["hanmen", "bianwu", "free"]
const BUCKET_LABELS: = {
    "hanmen": "地方线", 
    "bianwu": "边务线", 
    "free": "自由模式", 
}





const STORY_ROUTES: = {
    "hanmen": {
        "line": "hanmen", "char_id": "hanmen", "timeline": "chongzhen", 
        "keju_status": "sanjia", "start_kind": "fixed", 
        "city_act": 1, "year": 1, "month": 9, 



        "intro_branch": "keju", "intro_branch_index": 9, 
    }, 
    "shijia": {
        "line": "bianwu", "char_id": "shijia", "timeline": "chongzhen", 
        "keju_status": "none", "start_kind": "entry", "month": 1, 
    }, 
}

static func bucket_label(bucket: String) -> String:
    return str(BUCKET_LABELS.get(bucket, bucket))



static func current_bucket() -> String:
    if GameState.play_mode == "free":
        return "free"
    var line: = str(GameData.active_line)
    return line if line != "" else "hanmen"



static func bucket_of_save(data: Dictionary) -> String:
    if str(data.get("play_mode", "story")) == "free":
        return "free"
    var line: = str(data.get("active_line", ""))
    if line == "":
        line = "bianwu" if str(data.get("char_id", "")) == "shijia" else "hanmen"
    return line



static func line_of_save_fields(active_line: String, char_id: String) -> String:
    if active_line != "":
        return active_line
    return "bianwu" if char_id == "shijia" else "hanmen"
