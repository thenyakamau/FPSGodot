class_name Player 

extends CharacterBody3D

var _mouse_input: bool = false
var _rotation_input: float = 0.0
var _tilt_input: float = 0.0
var _speed : float

var _is_crouching: bool = false

var _player_rotation : Vector3
var _camera_rotation: Vector3
var _mouse_rotation: Vector3

@export_category("Velocity")
@export var SPEED_DEFAULT :float = 5.0
@export var SPEED_SPRINTING :float = 7.0
@export var SPEED_CROUNCH :float = 2.0
@export var JUMP_VELOCITY :float = 4.5
@export var ACCELERATION :float = 0.1
@export var DECELERATION :float = 0.25

@export_category("Ranges")
@export var MOUSE_SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT :float= deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT :float= deg_to_rad(90.0)
@export var TOOGLE_CROUCH : bool = true

@export_range(5,10,0.1) var CROUCH_SPEED : float = 7.0

@export_category("External Nodes")
@export var CAMERA_CONTROLLER : Camera3D
@export var ANIMATIONPLAYER: AnimationPlayer
@export var CROUCH_SHAPECAST: Node3D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()
		
	if event.is_action_pressed("crouch") and is_on_floor():
		_toggle_crouch()
		
	var _check_crouch_toggle :bool= event.is_action_pressed("crouch") and !_is_crouching and is_on_floor() and !TOOGLE_CROUCH
	if _check_crouch_toggle:
		crouching(true)
		
	var _check_release_crouch :bool = event.is_action_released("crouch") and !TOOGLE_CROUCH
	if _check_release_crouch:
		uncrouch_check()
		
func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		
func _update_camera(delta: float) -> void:
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

func _ready() -> void:
	# Get Mouse Input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	Global.player = self
	
	#Set Default speed
	_speed = SPEED_DEFAULT
	
	# Add crouch check shapecast collission exception for CharacterBody3D node
	CROUCH_SHAPECAST.add_exception($".")

func _physics_process(delta: float) -> void:
	
	Global.debug.add_property("MovementSpeed", _speed, 2) 
	Global.debug.add_property("MouseRotation", _mouse_rotation, 3) 
	
	# Update camera movements based on movement
	_update_camera(delta)
	
	# Add the gravity.
	if not is_on_floor():  
		velocity += get_gravity() * delta

	# Handle jump.
	var _check_jump :bool= Input.is_action_just_pressed("jump") and is_on_floor() and !_is_crouching
	if _check_jump:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir :Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction :Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * _speed, ACCELERATION)
		velocity.z = lerp(velocity.z, direction.z * _speed, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION)
		velocity.z = move_toward(velocity.z, 0, DECELERATION)

	move_and_slide()

func _toggle_crouch() -> void:
	if _is_crouching and !CROUCH_SHAPECAST.is_colliding():
		crouching(false)
	elif !_is_crouching:
		crouching(true)
		
func uncrouch_check() -> void:
	if !CROUCH_SHAPECAST.is_colliding():
		crouching(false)
	
	if CROUCH_SHAPECAST.is_colliding():
		await get_tree().create_timer(0.1).timeout
		uncrouch_check()
		
func crouching(state: bool) -> void:
	match state:
		true:
			ANIMATIONPLAYER.play("Crouch", 0, CROUCH_SPEED)
			set_movement_speed("crouching")
		false:
			ANIMATIONPLAYER.play("Crouch", 0, -CROUCH_SPEED, true)
			set_movement_speed("default")
			
func set_movement_speed(state: String) -> void:
	match state:
		"default":
			_speed = SPEED_DEFAULT
		"crouching":
			_speed = SPEED_CROUNCH

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "Crouch":
		_is_crouching = !_is_crouching
