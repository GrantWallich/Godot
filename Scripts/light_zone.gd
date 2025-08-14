extends Area3D

class_name LightZone

@export var light_node_path: NodePath
@export var start_on: bool = false
@export var turn_on_flicker: bool = true
@export var flicker_time: float = 0.8
@export var flicker_frequency_hz: float = 18.0
@export var intensity_on: float = 4.0
@export var intensity_off: float = 0.0
@export var energy_min_fraction: float = 0.3

var _light: OmniLight3D
var _flicker_running: bool = false

# Optional sound FX when turning on/off
@export var sound_on_stream: AudioStream
@export var sound_off_stream: AudioStream
@export var play_sound_on_turn_on: bool = true
@export var play_sound_on_turn_off: bool = false
@export var sound_on_at_flicker_start: bool = true
@export var sound_volume_db: float = 0.0
@export var sound_pitch_scale: float = 1.0
@export_range(0.0, 2.0, 0.01) var sound_randomize_pitch: float = 0.0

var _audio: AudioStreamPlayer3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_light = get_node_or_null(light_node_path) as OmniLight3D
	if _light == null:
		push_warning("LightZone: light_node_path not set or not an OmniLight3D")
		return
	# Ensure the light reacts in real-time
	_light.light_bake_mode = Light3D.BAKE_DYNAMIC
	# Prepare audio player if any stream is set
	if sound_on_stream != null or sound_off_stream != null:
		_audio = AudioStreamPlayer3D.new()
		_audio.volume_db = sound_volume_db
		_audio.pitch_scale = sound_pitch_scale
		add_child(_audio)
	if start_on:
		_turn_on_immediate()
	else:
		_turn_off()

func _on_body_entered(body: Node) -> void:
	if not (body is CharacterBody3D):
		return
	if _light == null:
		return
	if turn_on_flicker:
		await _turn_on_with_flicker()
	else:
		_turn_on_immediate()

func _on_body_exited(body: Node) -> void:
	if not (body is CharacterBody3D):
		return
	_turn_off()

func _turn_on_immediate() -> void:
	if _light == null:
		return
	_light.visible = true
	_light.light_energy = intensity_on
	if play_sound_on_turn_on:
		_play_sound(sound_on_stream)

func _turn_off() -> void:
	if _light == null:
		return
	_light.light_energy = intensity_off
	_light.visible = intensity_off > 0.0  # keep visible if you use very low but nonzero off energy
	if play_sound_on_turn_off:
		_play_sound(sound_off_stream)

func _rand_wait() -> float:
	# small random interval for flicker cadence
	return clamp(1.0 / flicker_frequency_hz * randf_range(0.5, 1.5), 0.01, 0.12)

func _energy_jitter() -> float:
	return randf_range(intensity_on * energy_min_fraction, intensity_on)

func _turn_on_with_flicker() -> void:
	if _flicker_running:
		return
	_flicker_running = true
	_light.visible = true
	if play_sound_on_turn_on and sound_on_at_flicker_start:
		_play_sound(sound_on_stream)
	var steps: int = int(max(1.0, flicker_time * flicker_frequency_hz))
	for i in steps:
		_light.light_energy = _energy_jitter()
		await get_tree().create_timer(_rand_wait()).timeout
	_light.light_energy = intensity_on
	_flicker_running = false
	if play_sound_on_turn_on and not sound_on_at_flicker_start:
		_play_sound(sound_on_stream)

func _play_sound(stream: AudioStream) -> void:
	if _audio == null:
		return
	if stream == null:
		return
	var pitch := sound_pitch_scale
	if sound_randomize_pitch > 0.0:
		pitch = clamp(pitch + randf_range(-sound_randomize_pitch, sound_randomize_pitch), 0.01, 4.0)
	_audio.pitch_scale = pitch
	_audio.stream = stream
	if _audio.playing:
		_audio.stop()
	_audio.play()
