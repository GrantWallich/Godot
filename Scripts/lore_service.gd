extends Node

## Autoload singleton that manages micro-lore triggers and minimal UI popup.

var _seen: Dictionary = {}  ## lore_id -> true
var _ui_layer: CanvasLayer
@export var fade_in_seconds: float = 0.18
@export var auto_hide_seconds: float = 2.5
@export var fade_out_seconds: float = 0.35
var _last_title: String = ""
var _last_body: String = ""

func _ready() -> void:
	name = "LoreService"  # Ensure autoload node has the expected name
	if OS.is_debug_build():
		print("[LoreService] ready at:", get_path())

func trigger_lore(lore_id: String, title: String, body: String, one_shot: bool) -> void:
	if one_shot and lore_id != "" and _seen.get(lore_id, false):
		return
	if one_shot and lore_id != "":
		_seen[lore_id] = true
	_last_title = title
	_last_body = body
	_show_ui(title, body)

func replay_last() -> void:
	if _last_title == "" and _last_body == "":
		return
	_show_ui(_last_title, _last_body)

func _show_ui(title: String, body: String) -> void:
	if _ui_layer == null:
		_ui_layer = _build_ui()
		get_tree().root.add_child(_ui_layer)
	# Populate
	var panel := _ui_layer.get_node("Panel") as Panel
	(panel.get_node("Margin/VBox/Title") as Label).text = title
	(panel.get_node("Margin/VBox/Body") as RichTextLabel).text = body
	panel.visible = true
	panel.modulate.a = 0.0
	var tw := panel.create_tween()
	tw.tween_property(panel, "modulate:a", 1.0, fade_in_seconds)
	if auto_hide_seconds > 0.0:
		tw.tween_interval(auto_hide_seconds)
		tw.tween_property(panel, "modulate:a", 0.0, fade_out_seconds)
		tw.tween_callback(func(): panel.visible = false)
	if OS.is_debug_build():
		print("[LoreService] showing UI: ", title)

func hide_ui() -> void:
	if _ui_layer == null:
		return
	var panel := _ui_layer.get_node("Panel") as Panel
	var tw := panel.create_tween()
	tw.tween_property(panel, "modulate:a", 0.0, fade_out_seconds)
	tw.tween_callback(func(): panel.visible = false)

func _build_ui() -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.layer = 1000
	var panel := Panel.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(480, 0)
	# Bottom-right anchoring
	panel.anchor_left = 1.0
	panel.anchor_top = 1.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	panel.offset_right = -580.0
	panel.offset_bottom = -140.0
	# Remove default panel background
	panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())

	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)

	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.custom_minimum_size = Vector2(560, 0)

	var title_label := Label.new()
	title_label.name = "Title"
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.modulate = Color(1, 1, 1)

	var body_label := RichTextLabel.new()
	body_label.name = "Body"
	body_label.fit_content = true
	body_label.bbcode_enabled = false
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	body_label.modulate = Color(1, 1, 1)

	vbox.add_child(title_label)
	vbox.add_child(body_label)
	margin.add_child(vbox)
	panel.add_child(margin)
	layer.add_child(panel)
	return layer
