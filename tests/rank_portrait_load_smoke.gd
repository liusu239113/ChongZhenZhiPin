extends SceneTree

func _initialize() -> void :
    var failed: = false
    for rank in [2, 3, 4, 5, 6, 7]:
        var path: = "res://assets/portraits/hanmen_rank%d.webp" % rank
        var texture: = load(path)
        if texture == null:
            push_error("failed to load rank portrait: %s" % path)
            failed = true
    if failed:
        quit(1)
    else:
        print("rank_portrait_load_smoke: ok")
        quit()
