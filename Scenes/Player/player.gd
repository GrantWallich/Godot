extends CharacterBody3D

@onready var gunRay = $Head/Camera3d/RayCast3d as RayCast3D
@onready var Cam = $Head/Camera3d as Camera3D
@export var _bullet_scene : PackedScene
@export var mouse_sensitivity : float = 600.0
@export var normal_fov : float = 75.0
@export var zoom_fov : float = 35.0
@export var zoom_speed : float = 10.0
@export var zoom_sensitivity_multiplier : float = 2.0
@export var interact_max_parent_depth : int = 8
# -- Lore system removed -> obsolete exports commented out --
# @export var require_lore_group : bool = false
# @export var lore_group_name : String = "lore_hit"
# @export var search_ancestor_depth : int = 8
var mouse_relative_x = 0
var mouse_relative_y = 0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
# const LORE_TRIGGER_PATH := "res://Scripts/lore_trigger.gd"  # lore system removed
# const LORE_HIT_GROUP := "lore_hit"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_zooming: bool = false

func _ready():
	#Captures mouse and stops gun from hitting yourself
	gunRay.add_exception(self)
	gunRay.collide_with_areas = true
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

	# Interact with looked-at object
	if event.is_action_pressed("interact"):
		_interact()

func shoot():
	if not gunRay.is_colliding():
		return
	if OS.is_debug_build():
		print("[Shoot] hit:", gunRay.get_collider(), " at ", gunRay.get_collision_point())
	# If we're looking at a LoreInteractable, interact instead of shooting
	var collider_node := gunRay.get_collider()
	if collider_node is Node:
		var target := _find_lore_interactable_upwards(collider_node as Node, interact_max_parent_depth)
		if target != null:
			if OS.is_debug_build():
				print("[Shoot->Interact] triggering interact on:", target)
			target.interact(self)
			return
	var bulletInst = _bullet_scene.instantiate() as Node3D
	bulletInst.set_as_top_level(true)
	get_parent().add_child(bulletInst)
	bulletInst.global_transform.origin = gunRay.get_collision_point() as Vector3
	bulletInst.look_at((gunRay.get_collision_point()+gunRay.get_collision_normal()),Vector3.BACK)
	print(gunRay.get_collision_point())
	print(gunRay.get_collision_point()+gunRay.get_collision_normal())
	# -- Lore trigger system removed: skip collider lore checks --


func _update_zoom(delta: float) -> void:
	var target_fov := (zoom_fov if is_zooming else normal_fov)
	Cam.fov = lerp(Cam.fov, target_fov, clamp(zoom_speed * delta, 0.0, 1.0))

func _is_in_group_case_insensitive(node: Node, group_name: String) -> bool:
	var target := group_name.to_lower()
	for g in node.get_groups():
		if String(g).to_lower() == target:
			return true
	return false

func _has_group_upwards(node: Node, group_name: String, max_depth: int) -> bool:
	var current := node.get_parent()
	var depth := 0
	while current and depth < max_depth:
		if _is_in_group_case_insensitive(current, group_name):
			return true
		current = current.get_parent()
		depth += 1
	return false

func _interact() -> void:
	if not gunRay.is_colliding():
		return
	var collider := gunRay.get_collider()
	if not (collider is Node):
		return
	var candidate := _find_lore_interactable_upwards(collider as Node, interact_max_parent_depth)
	if candidate == null:
		return
	if OS.is_debug_build():
		print("[Interact] with:", candidate, " from ", collider)
	candidate.interact(self)

func _find_lore_interactable_upwards(start: Node, max_depth: int) -> LoreInteractable:
	var current: Node = start
	var depth := 0
	while current and depth <= max_depth:
		if current is LoreInteractable:
			return current as LoreInteractable
		current = current.get_parent()
		depth += 1
	return null
