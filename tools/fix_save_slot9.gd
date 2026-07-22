@tool
extends EditorScript

func _run() -> void :
    var path = "user://saves/slot_9.save"
    var file = FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Cannot open " + path)
        return
    var data: Dictionary = file.get_var()
    file.close()

    print("=== BEFORE ===")
    print("year: ", data.get("year"))
    print("month: ", data.get("month"))
    print("branch: ", data.get("branch"))
    print("branch_index: ", data.get("branch_index"))
    print("active_pending_event: ", data.get("active_pending_event"))
    print("act5_elapsed_months: ", data.get("act5_elapsed_months"))
    print("sun_chuanting_branch_lock: ", data.get("sun_chuanting_branch_lock"))
    print("emperor_dead: ", data.get("emperor_dead"))


    data["year"] = 16
    data["month"] = 8
    data["branch"] = ""
    data["branch_index"] = 0
    data["wartime_index"] = 0
    data["active_pending_event"] = {}
    data["pending_events"] = []
    data["emperor_dead"] = false
    data["act5_elapsed_months"] = 36
    data["sun_chuanting_branch_lock"] = false
    data["action_points"] = 2
    data["month_cards"] = []
    data["month_cards_done"] = []
    data["current_month_card_index"] = -1
    data["month_visitors"] = []
    data["active_case_chain"] = {}

    print("=== AFTER ===")
    print("year: ", data.get("year"))
    print("month: ", data.get("month"))
    print("branch: ", data.get("branch"))

    var out = FileAccess.open(path, FileAccess.WRITE)
    if out == null:
        push_error("Cannot write " + path)
        return
    out.store_var(data)
    out.close()
    print("Save slot 9 patched to 崇祯十六年八月 governance mode.")
