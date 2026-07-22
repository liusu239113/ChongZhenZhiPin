extends RefCounted
class_name ItemDetailBuilder



const ItemListBuilderRef = preload("res://scripts/ui/item_list_builder.gd")
const Presenter = preload("res://scripts/ui/game_screen_presenter.gd")

static func build(item_id: String) -> Dictionary:
    if item_id == "":
        return {}

    var item: Dictionary = {}
    for candidate in ItemListBuilderRef.build_display_items():
        if str(candidate.get("id", "")) == item_id:
            item = candidate
            break
    if item.is_empty():
        return {}

    var sections: Dictionary = Presenter._split_item_description_sections(
        str(item.get("desc", "")).strip_edges()
    )
    var effect: = str(sections.get("effect", "")).strip_edges()
    if effect == "":
        var status_parts: Array = GameState.get_item_status_effect_parts(item_id)
        if not status_parts.is_empty():
            effect = "\n".join(status_parts)

    return {
        "id": item_id, 
        "name": str(item.get("name", "无名物件")), 
        "source": str(item.get("source", "随身旧物")), 
        "body": str(sections.get("body", "")).strip_edges(), 
        "effect": effect, 
        "note": str(sections.get("note", "")).strip_edges(), 
    }
