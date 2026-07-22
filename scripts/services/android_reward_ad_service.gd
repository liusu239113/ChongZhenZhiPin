extends Node

const AdsConfigRef = preload("res://scripts/services/ads_config.gd")

signal reward_granted(reward_type: String)
signal reward_failed(reward_type: String, message: String)
signal reward_unavailable(reward_type: String, message: String)

const ANDROID_PLUGIN_SINGLETON: = "ChongzhenTapAdPlugin"
const SAVE_SLOT_SPACE_ID: = "1056366"
const LINGWU_SPACE_ID: = "1059276"
const REQUEST_TIMEOUT_SECONDS: = 120.0

var _native_plugin = null
var _signals_connected: = false
var _request_busy: = false
var _request_settled: = true
var _request_generation: = 0
var _active_request_id: = ""
var _active_reward_type: = ""
var _request_watchdog: Timer

func _ready() -> void :
    _request_watchdog = Timer.new()
    _request_watchdog.one_shot = true
    _request_watchdog.wait_time = REQUEST_TIMEOUT_SECONDS
    _request_watchdog.timeout.connect(_on_request_timeout)
    add_child(_request_watchdog)
    if AdsConfigRef.ADS_ENABLED and OS.has_feature("android"):
        _ensure_native_plugin()

func _exit_tree() -> void :
    if _request_watchdog != null:
        _request_watchdog.stop()
    _active_request_id = ""
    _active_reward_type = ""
    _request_busy = false
    _request_settled = true
    if OS.has_feature("android") and _native_plugin != null:
        _native_plugin.disposeRewardAd()

func is_available() -> bool:
    return (
        AdsConfigRef.ADS_ENABLED
        and OS.has_feature("android")
        and GameState.is_privacy_agreed()
        and _ensure_native_plugin()
        and not _request_busy
    )

func show_save_slot_reward_ad() -> bool:
    return _show_reward_ad(SAVE_SLOT_SPACE_ID, "save_slot", "手动存档栏位", 1)

func show_lingwu_reward_ad() -> bool:
    return _show_reward_ad(LINGWU_SPACE_ID, "lingwu", "识悟", 10)

func _show_reward_ad(space_id: String, reward_type: String, reward_name: String, reward_amount: int) -> bool:
    if not AdsConfigRef.ADS_ENABLED:
        reward_unavailable.emit(reward_type, "激励视频暂不可用，请稍后再试")
        return false
    if not OS.has_feature("android"):
        reward_unavailable.emit(reward_type, "激励视频仅在安卓版提供")
        return false
    if not GameState.is_privacy_agreed():
        reward_unavailable.emit(reward_type, "请先阅读并同意隐私政策")
        return false
    if _request_busy:
        return false
    if not _ensure_native_plugin():
        reward_unavailable.emit(reward_type, "激励视频暂不可用，请稍后再试")
        return false

    _request_generation += 1
    _active_request_id = str(_request_generation)
    _active_reward_type = reward_type
    _request_busy = true
    _request_settled = false
    _request_watchdog.start()

    _native_plugin.initializeAds()
    _native_plugin.showRewardAd(_active_request_id, space_id, reward_type, reward_name, reward_amount)
    return true

func _ensure_native_plugin() -> bool:
    if _native_plugin != null:
        return true
    if not OS.has_feature("android") or not Engine.has_singleton(ANDROID_PLUGIN_SINGLETON):
        return false
    _native_plugin = Engine.get_singleton(ANDROID_PLUGIN_SINGLETON)
    if _native_plugin == null:
        return false
    _connect_native_signals_once()
    return true

func _connect_native_signals_once() -> void :
    if _signals_connected or _native_plugin == null:
        return
    _native_plugin.reward_verified.connect(_on_native_reward_verified)
    _native_plugin.reward_failed.connect(_on_native_reward_failed)
    _native_plugin.reward_unavailable.connect(_on_native_reward_unavailable)
    _signals_connected = true

func _on_native_reward_verified(request_id: String, reward_type: String) -> void :
    if request_id.is_empty() or request_id != _active_request_id:
        return
    if reward_type != _active_reward_type:
        var mismatched_reward_type: = _active_reward_type
        if _settle_current_request(request_id):
            reward_failed.emit(mismatched_reward_type, "激励视频奖励校验失败，请稍后再试")
        return
    var verified_reward_type: = _active_reward_type
    if not _settle_current_request(request_id):
        return
    reward_granted.emit(verified_reward_type)

func _on_native_reward_failed(request_id: String, message: String = "") -> void :
    if request_id.is_empty() or request_id != _active_request_id:
        return
    var failed_reward_type: = _active_reward_type
    if not _settle_current_request(request_id):
        return
    var player_message: = message.strip_edges()
    reward_failed.emit(failed_reward_type, player_message if player_message != "" else "激励视频未完成，请稍后再试")

func _on_native_reward_unavailable(request_id: String, _message: String = "") -> void :
    if request_id.is_empty() or request_id != _active_request_id:
        return
    var unavailable_reward_type: = _active_reward_type
    if not _settle_current_request(request_id):
        return
    reward_unavailable.emit(unavailable_reward_type, "激励视频暂不可用，请稍后再试")

func _settle_current_request(request_id: String) -> bool:
    if request_id.is_empty() or request_id != _active_request_id:
        return false
    if not _request_busy or _request_settled:
        return false
    _request_settled = true
    _request_busy = false
    _active_request_id = ""
    _active_reward_type = ""
    _request_watchdog.stop()
    return true

func _on_request_timeout() -> void :
    var request_id: = _active_request_id
    var timed_out_reward_type: = _active_reward_type
    if not _settle_current_request(request_id):
        return
    if OS.has_feature("android") and _native_plugin != null:
        _native_plugin.disposeRewardAd()
    reward_failed.emit(timed_out_reward_type, "激励视频响应超时，请稍后再试")
