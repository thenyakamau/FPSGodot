class_name SliderPlayerState
extends PlayerMovementState

@export var SPEED :float = 3.0
@export var ACCELERATION :float = 0.1
@export var DECELERATION :float = 0.25
@export var TILT_AMOUNT :float = 0.09
@export_range(1,6,0.1) var SLIDING_ANIM_SPEED : float = 4.0

#@onready var CROUCH_SHAPECAST: ShapeCast3D = %ShapeCast3D

func enter(previous_state: State) -> void:
	#set_tilt(PLAYER._current_rotation)
	ANIMATION_PLAYER.get_animation("Sliding").track_set_key_value(4,0, PLAYER.velocity.length())
	ANIMATION_PLAYER.speed_scale = 1.0
	ANIMATION_PLAYER.play("Sliding", -1.0, SLIDING_ANIM_SPEED)
	
func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_velocity()

func set_tilt(player_rotation: float) -> void:
	var tilt: Vector3 = Vector3.ZERO
	tilt.z = clamp(TILT_AMOUNT * player_rotation, -0.1, 0.1)
	if tilt.z == 0.0:
		tilt.z = 0.05
		
	ANIMATION_PLAYER.get_animation("Sliding").track_set_key_value(8,1, tilt)
	ANIMATION_PLAYER.get_animation("Sliding").track_set_key_value(8,2, tilt)
	
func finish() -> void:
	transition.emit("CrouchingPlayerState")
