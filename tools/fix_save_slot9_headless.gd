extends SceneTree

func _init() -> void :
    var path = "user://saves/slot_9.save"
    print("user dir: ", ProjectSettings.globalize_path("user://"))
    var file = FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Cannot open " + path)
        quit(1)
        return
    var data: Dictionary = file.get_var()
    file.close()


    var bak = FileAccess.open(path + ".prebak6", FileAccess.WRITE)
    if bak != null:
        bak.store_var(data)
        bak.close()

    print("=== BEFORE ===")
    print("year=", data.get("year"), " month=", data.get("month"), " branch=", data.get("branch"), 
        " branch_index=", data.get("branch_index"), " act5_elapsed_months=", data.get("act5_elapsed_months"), 
        " emperor_dead=", data.get("emperor_dead"), " sun_lock=", data.get("sun_chuanting_branch_lock"))
    print("active_pending_event=", data.get("active_pending_event"))


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
    data["transitioning_to_governance"] = false

    var out = FileAccess.open(path, FileAccess.WRITE)
    if out == null:
        push_error("Cannot write " + path)
        quit(1)
        return
    out.store_var(data)
    out.close()

    print("=== AFTER ===")
    print("year=", data.get("year"), " month=", data.get("month"), " branch='", data.get("branch"), "'")
    print("Done: slot 9 -> 崇祯十六年八月 governance mode.")
    quit(0)
