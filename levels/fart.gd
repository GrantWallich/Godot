extends Area3D

@export var stream: AudioStream
@export var player_path: NodePath = ^"AudioStreamPlayer3D"
@export var fade_in := 0.2
@export var fade_out := 0.4
@export var stop_on_exit := true

@onready var player: AudioStreamPlayer3D = get_node_or_null(player_path)

func _ready() -> void:
	if player == null:
		player = find_child("AudioStreamPlayer3D", true, false) as AudioStreamPlayer3D
	if player == null:
		push_warning("AudioStreamPlayer3D not found. Set player_path.")
		return
	if stream:
		player.stream = stream
	player.autoplay = false
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

func _on_enter(body: Node) -> void:
	if body is CharacterBody3D and player:
		player.volume_db = -60.0
		player.play()
		create_tween().tween_property(player, "volume_db", 0.0, fade_in)

func _on_exit(body: Node) -> void:
	if body is CharacterBody3D and player and stop_on_exit:
		var t := create_tween()
		t.tween_property(player, "volume_db", -60.0, fade_out)
		t.finished.connect(player.stop)
