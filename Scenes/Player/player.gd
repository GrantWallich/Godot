extends CharacterBody3D

@onready var gunRay = $Head/Camera3d/RayCast3d as RayCast3D
@onready var Cam = $Head/Camera3d as Camera3D
@export var _bullet_scene : PackedScene
@export var mouse_sensitivity : float = 600.0
@export var normal_fov : float = 75.0
@export var zoom_fov : float = 35.0
@export var zoom_speed : float = 10.0
@export var zoom_sensitivity_multiplier : float = 2.0
var mouse_relative_x = 0
var mouse_relative_y = 0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_zooming: bool = false

func _ready():
	#Captures mouse and stops gun from hitting yourself
	gunRay.add_exception(self)
	# Set default camera FOV
	Cam.fov = normal_fov
	# Don't capture mouse immediately - wait for user click
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Handle Shooting
	if Input.is_action_just_pressed("Shoot"):
		shoot()
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	# Smooth zoom update
	_update_zoom(delta)

func _input(event):
	# Capture mouse on first click
	if event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return  # Don't process the click that captures the mouse
	
	# Only process mouse motion if mouse is captured
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var sensitivity := mouse_sensitivity * (zoom_sensitivity_multiplier if is_zooming else 1.0)
		rotation.y -= event.relative.x / sensitivity
		$Head/Camera3d.rotation.x -= event.relative.y / sensitivity
		$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)
	# Hold right mouse to zoom
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		is_zooming = event.pressed

func shoot():
	if not gunRay.is_colliding():
		return
	var bulletInst = _bullet_scene.instantiate() as Node3D
	bulletInst.set_as_top_level(true)
	get_parent().add_child(bulletInst)
	bulletInst.global_transform.origin = gunRay.get_collision_point() as Vector3
	bulletInst.look_at((gunRay.get_collision_point()+gunRay.get_collision_normal()),Vector3.BACK)
	print(gunRay.get_collision_point())
	print(gunRay.get_collision_point()+gunRay.get_collision_normal())

func _update_zoom(delta: float) -> void:
	var target_fov := (zoom_fov if is_zooming else normal_fov)
	Cam.fov = lerp(Cam.fov, target_fov, clamp(zoom_speed * delta, 0.0, 1.0))
