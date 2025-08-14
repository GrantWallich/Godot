extends Node

class_name LoreInteractable

## Attach to any node you want to be interactable via player raycast + E.
## When interacted, it triggers LoreService and can optionally play a 3D sound.

@export var lore_id: String = ""
@export var title: String = ""
@export_multiline var body: String = ""
@export var one_shot: bool = false

@export var sound_stream: AudioStream
@export var play_sound_on_interact: bool = true
@export var sound_volume_db: float = 0.0
@export var sound_pitch_scale: float = 1.0
@export_range(0.0, 2.0, 0.01) var sound_randomize_pitch: float = 0.0

var _audio_player: AudioStreamPlayer3D

func _ready() -> void:
	if sound_stream != null:
		_audio_player = AudioStreamPlayer3D.new()
		_audio_player.stream = sound_stream
		_audio_player.volume_db = sound_volume_db
		_audio_player.pitch_scale = sound_pitch_scale
		add_child(_audio_player)

func interact(_actor: Node) -> void:
	LoreService.trigger_lore(lore_id, title, body, one_shot)
	if play_sound_on_interact:
		_play_sound()

func _play_sound() -> void:
	if _audio_player == null:
		return
	var pitch := sound_pitch_scale
	if sound_randomize_pitch > 0.0:
		pitch = clamp(pitch + randf_range(-sound_randomize_pitch, sound_randomize_pitch), 0.01, 4.0)
	_audio_player.pitch_scale = pitch
	if _audio_player.playing:
		_audio_player.stop()
	_audio_player.play()



