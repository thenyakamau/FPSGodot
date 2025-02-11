class_name CrouchingPlayerState

extends PlayerMovementState

@export var SPEED :float = 3.0
@export var ACCELERATION :float = 0.1
@export var DECELERATION :float = 0.25
@export_range(1,6,0.1) var CROUCH_SPEED : float = 4.0

@onready var CROUCH_SHAPECAST: ShapeCast3D = %ShapeCast3D

func enter(previous_state: State) -> void:
	ANIMATION_PLAYER.play("Crouch", -1.0, CROUCH_SPEED)
	
func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_released("crouch"):
		uncrouch()
		
func uncrouch() -> void:
	if !CROUCH_SHAPECAST.is_colliding() and !Input.is_action_pressed("crouch"):
		ANIMATION_PLAYER.play("Crouch", -1.0, -CROUCH_SPEED* 1.5, true)
		if ANIMATION_PLAYER.is_playing():
			await ANIMATION_PLAYER.animation_finished
		
		transition.emit("IdlePlayerState")
	if CROUCH_SHAPECAST.is_colliding():
		await get_tree().create_timer(0.1).timeout
		uncrouch()
		
