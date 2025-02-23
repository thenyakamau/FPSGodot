class_name Player 

extends CharacterBody3D

var _mouse_input: bool = false
var _rotation_input: float = 0.0
var _tilt_input: float = 0.0
var _current_rotation : float

var _is_crouching: bool = false

var _player_rotation : Vector3
var _camera_rotation: Vector3
var _mouse_rotation: Vector3

@export_category("Velocity")
@export var JUMP_VELOCITY :float = 4.5

@export_category("Ranges")
@export var MOUSE_SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT :float= deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT :float= deg_to_rad(90.0)

@export_category("External Nodes")
@export var CAMERA_CONTROLLER : Camera3D
@export var ANIMATION_PLAYER: AnimationPlayer
@export var WEAPON_CONTROLLER: WeaponController
@export var CROUCH_SHAPECAST: Node3D

var _gravity: float = 12.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()
		
func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
	
func _ready() -> void:
	# Get Mouse Input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	   
	Global.player = self
	
	# Add crouch check shapecast collission exception for CharacterBody3D node
	CROUCH_SHAPECAST.add_exception($".")

func _physics_process(delta: float) -> void:
	Global.debug.add_property("MouseRotation", _mouse_rotation, 3) 
	
	# Update camera movements based on movement
	_update_camera(delta)

func _update_camera(delta: float) -> void:
	_current_rotation = _rotation_input
	# Rotate camera using euler rotation
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0

	
func update_gravity(delta: float) -> void:
	#velocity += get_gravity() * delta
	velocity.y -= _gravity * delta

func update_input(speed:float, acceleration: float, deceleration: float) -> void:
	Global.debug.add_property("MovementSpeed", speed, 2) 
	
	var input_dir :Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction :Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
		velocity.z = move_toward(velocity.z, 0, deceleration)
	
func update_velocity() -> void:
	move_and_slide()

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "Crouch":
		_is_crouching = !_is_crouching
