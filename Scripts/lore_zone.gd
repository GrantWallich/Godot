extends Area3D

class_name LoreZone

## Zone that triggers LoreService when the player enters, exits, or presses Interact.
## Usage: Add an Area3D with a CollisionShape3D, attach this script, and fill the exports.

@export var lore_id: String = ""            ## set to mark as one-shot per id
@export var title_on_enter: String = ""      ## title shown on enter
@export_multiline var body_on_enter: String = ""       ## body shown on enter
@export var title_on_exit: String = ""       ## optional title on exit
@export_multiline var body_on_exit: String = ""        ## optional body on exit
@export var require_interact: bool = false   ## if true, only triggers on Interact action while inside
@export var one_shot: bool = true            ## do not repeat once seen (by lore_id)

## Optional sound to play when triggered
@export var sound_stream: AudioStream
@export var play_sound_on_enter: bool = true
@export var play_sound_on_exit: bool = false
@export var sound_volume_db: float = 0.0
@export var sound_pitch_scale: float = 1.0
@export_range(0.0, 2.0, 0.01) var sound_randomize_pitch: float = 0.0

var _player_inside: bool = false
var _audio_player: AudioStreamPlayer3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if sound_stream != null:
		_audio_player = AudioStreamPlayer3D.new()
		_audio_player.stream = sound_stream
		_audio_player.volume_db = sound_volume_db
		_audio_player.pitch_scale = sound_pitch_scale
		add_child(_audio_player)

func _input(event: InputEvent) -> void:
	if not require_interact:
		return
	if not _player_inside:
		return
	if event.is_action_pressed("interact"):
		_trigger_enter_lore()

func _on_body_entered(body: Node) -> void:
	if not (body is CharacterBody3D):
		return
	_player_inside = true
	if require_interact:
		return
	_trigger_enter_lore()

func _on_body_exited(body: Node) -> void:
	if not (body is CharacterBody3D):
		return
	_player_inside = false
	if title_on_exit == "" and body_on_exit == "":
		return
	LoreService.trigger_lore(lore_id + "__exit" if lore_id != "" else "", title_on_exit, body_on_exit, one_shot)
	if play_sound_on_exit:
		_play_sound()

func _trigger_enter_lore() -> void:
	if title_on_enter == "" and body_on_enter == "":
		return
	LoreService.trigger_lore(lore_id, title_on_enter, body_on_enter, one_shot)
	if play_sound_on_enter:
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


