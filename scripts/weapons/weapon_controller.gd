@tool
class_name WeaponController
extends Node3D

@export var WEAPON_TYPE: Weapons:
	set(value):
		WEAPON_TYPE = value
		if Engine.is_editor_hint():
			_load_weapon()
			
@export var sway_noise: NoiseTexture2D
@export var sway_speed: float  = 1.2
@export var reset: bool = false:
	set(value):
		reset = value
		if Engine.is_editor_hint():
			_load_weapon()

@onready var weapon_mesh: MeshInstance3D = %WeaponMesh
@onready var weapon_shadow: MeshInstance3D = %WeaponShadow

var _mouse_movement: Vector2
var _random_sway_x: float
var _random_sway_y: float
var _random_sway_amount: float

var time: float = 0.0
var idle_sway_adjustment: float
var idle_sway_rotation_strength: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_weapon()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_1"):
		WEAPON_TYPE = load("res://meshes/weapons/crowbar/crowbar_resource.tres")
		_load_weapon()
	
	if event.is_action_pressed("weapon_2"):
		WEAPON_TYPE = load("res://meshes/weapons/riffle/riffle_resource.tres")
		_load_weapon()
	
	if event is InputEventMouseMotion:
		_mouse_movement = event.relative

func _load_weapon() -> void:
	weapon_mesh.mesh = WEAPON_TYPE.mesh # Set the weapon mesh
	position = WEAPON_TYPE.position
	rotation_degrees = WEAPON_TYPE.rotation
	scale = WEAPON_TYPE.scale
	weapon_shadow.visible = WEAPON_TYPE.shadow
	
	idle_sway_adjustment = WEAPON_TYPE.idle_sway_adjustment
	idle_sway_rotation_strength = WEAPON_TYPE.idle_sway_rotation_strength
	_random_sway_amount = WEAPON_TYPE.random_sway_amount

func sway_weapon(delta: float, isIdle: bool) -> void:
	# Clamp mouse Movement
	_mouse_movement = _mouse_movement.clamp(WEAPON_TYPE.sway_min, WEAPON_TYPE.sway_max)
	
	if isIdle:
		# Get random sway value from 2D noise
		var sway_random: float = _get_sway_noise()
		var _sway_random_adjusted: float = sway_random * idle_sway_adjustment # adjust the sway strength
		
		# create time with delta and set 2 sine values for x and y sway  movement
		time += delta * (sway_speed + sway_random)
		_random_sway_x = sin(time * 1.5 + _sway_random_adjusted) / _random_sway_amount
		_random_sway_y = sin(time - _sway_random_adjusted) / _random_sway_amount
	
		# lamp weapon position based on mouse movement
		position.x = lerp(position.x, WEAPON_TYPE.position.x - (_mouse_movement.x * WEAPON_TYPE.sway_amount_position + _random_sway_x) * delta, WEAPON_TYPE.sway_speed_position)
		position.y = lerp(position.y, WEAPON_TYPE.position.y + (_mouse_movement.y * WEAPON_TYPE.sway_amount_position + _random_sway_y) * delta, WEAPON_TYPE.sway_speed_position)

		# Lerp weapon rotation based on mouse movement
		rotation_degrees.x = lerp(rotation_degrees.x, WEAPON_TYPE.rotation.x - (_mouse_movement.x * WEAPON_TYPE.sway_amount_rotation + (_random_sway_x * idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_rotation)
		rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y + (_mouse_movement.y * WEAPON_TYPE.sway_amount_rotation + (_random_sway_y * idle_sway_rotation_strength)) * delta, WEAPON_TYPE.sway_speed_rotation)
		
	else:
		# lamp weapon position based on mouse movement
		position.x = lerp(position.x, WEAPON_TYPE.position.x - (_mouse_movement.x * WEAPON_TYPE.sway_amount_position) * delta, WEAPON_TYPE.sway_speed_position)
		position.y = lerp(position.y, WEAPON_TYPE.position.y + (_mouse_movement.y * WEAPON_TYPE.sway_amount_position) * delta, WEAPON_TYPE.sway_speed_position)

		# Lerp weapon rotation based on mouse movement
		rotation_degrees.x = lerp(rotation_degrees.x, WEAPON_TYPE.rotation.x - (_mouse_movement.x * WEAPON_TYPE.sway_amount_rotation) * delta, WEAPON_TYPE.sway_speed_rotation)
		rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y + (_mouse_movement.y * WEAPON_TYPE.sway_amount_rotation) * delta, WEAPON_TYPE.sway_speed_rotation)
	
func _get_sway_noise() -> float:
	var _player_position: Vector3 = Vector3.ZERO
	
	# only access global variables when in game to avoid constant errors
	if not Engine.is_editor_hint():
		_player_position = Global.player.global_position
		
	return sway_noise.noise.get_noise_2d(_player_position.x, _player_position.y)
	
	
