extends RefCounted
class_name ItemListBuilder





const PERSONAL_STAT_KEYS: = ["wentao", "wulue", "lizheng", "tizhi"]


static func _format_large_number(val: int) -> String:
    var abs_val = abs(val)
    if abs_val < 10000:
        return str(val)
    else:
        var result = "%.1f万" % (float(val) / 10000.0)
        if result.ends_with(".0万"):
            return result.replace(".0万", "万")
        return result

static func build_display_items() -> Array:
    var items: Array = []

    var caibo = GameState.private_silver

    items.append({


        "id": "private_silver", 
        "name": "私银 %s" % _format_large_number(caibo), 
        "source": "私产", 
        "desc": build_private_silver_item_desc(), 
        "icon": "", 
        "categories": [], 
        "multi": false, 
        "draggable": false
    })

    var kuixing_count: = SaveManager.get_current_kuixing_fu_count(GameState)
    if GameState.has_feature("kuixing") and kuixing_count > 0:
        var item_def: Dictionary = GameData.ITEM_DEFS.get(SaveManager.KUIXING_FU_ITEM_ID, {})
        if not item_def.is_empty():
            var kx_cat: = compute_item_categories(SaveManager.KUIXING_FU_ITEM_ID, item_def)
            items.append({
                "id": SaveManager.KUIXING_FU_ITEM_ID, 
                "name": "%s ×%d" % [item_def.get("name", "魁星符"), kuixing_count], 
                "source": item_def.get("source", "科举进取"), 
                "desc": "%s\n当前持有：%d / %d" % [
                    item_def.get("desc", ""), 
                    kuixing_count, 
                    SaveManager.KUIXING_FU_MAX_COUNT, 
                ], 
                "icon": item_def.get("icon", ""), 
                "effects": item_def.get("effects", {}), 
                "cityEffects": item_def.get("cityEffects", {}), 
                "categories": kx_cat["categories"], 
                "multi": kx_cat["multi"]
            })

    for item_id in GameState.items:
        var item_def: Dictionary = GameData.ITEM_DEFS.get(item_id, {})
        if item_def.is_empty():
            continue

        var desc_text = item_def.get("desc", "")
        if item_id == "gaoji_banyin":
            var income = GameState.get_gaoji_banyin_income()
            desc_text += "\n[当前收益：%s（每月库银 +%d，官粮 +%d，私银 +%d）]" % [
                income["label"], 
                income["silver"], 
                income["grain"], 
                income["private"]
            ]

        var cat_info: = compute_item_categories(item_id, item_def)
        items.append({
            "id": str(item_id), 
            "name": item_def.get("name", item_id), 
            "source": item_def.get("source", "未知"), 
            "desc": desc_text, 
            "icon": item_def.get("icon", ""), 
            "effects": item_def.get("effects", {}), 
            "cityEffects": item_def.get("cityEffects", {}), 
            "categories": cat_info["categories"], 
            "multi": cat_info["multi"]
        })



    var replacements: = GameScreenPresenter._build_text_placeholder_replacements()
    for item in items:
        var item_id: = str(item.get("id", ""))
        for field in ["name", "source", "desc"]:
            if item.has(field) and item[field] is String:

                item[field] = GameScreenPresenter.resolve_dezheng_item_text(item_id, item[field])
                if not replacements.is_empty():
                    item[field] = GameScreenPresenter._replace_city_placeholders(item[field], replacements)
    return items




static func compute_item_categories(item_id: String, item_def: Dictionary) -> Dictionary:
    var categories: Array = []
    var city_effects: Dictionary = item_def.get("cityEffects", {})
    for raw_key in city_effects:
        var key: = str(raw_key)
        if GameData.CITY_STAT_KEYS.has(key) and not categories.has(key):
            categories.append(key)

    var personal_effects: Dictionary = item_def.get("effects", {})
    for raw_key in personal_effects:
        var key: = str(raw_key)
        if PERSONAL_STAT_KEYS.has(key) and not categories.has(key):
            categories.append(key)

    var status_effects: Dictionary = item_def.get("statusEffects", {})
    const CITY_RESOURCE_KEYS: = ["yinliang", "liangshi", "bingyong", "liumin", "renkou_val"]
    for raw_key in status_effects:
        var key: = str(raw_key)
        if CITY_RESOURCE_KEYS.has(key) and int(status_effects[raw_key]) != 0 and not categories.has(key):
            categories.append(key)

    var multi: = categories.size() >= 2 or item_id == "gaoji_banyin"
    return {"categories": categories, "multi": multi}

static func build_private_silver_item_desc() -> String:
    var salary: = GameState.get_monthly_official_salary()
    var lines: = [
        "天下熙熙，皆为利来。银子不会说话，但它能替你说很多话。"
    ]
    if salary > 0:
        lines.append("[每月进账：俸银 +%d]" % salary)
    else:
        lines.append("[每月进账：暂无固定俸银]")
    lines.append(GameState.get_monthly_official_salary_desc())
    return "\n".join(lines)
