class_name CrouchingPlayerState

extends PlayerMovementState

@export var SPEED :float = 3.0
@export var ACCELERATION :float = 0.1
@export var DECELERATION :float = 0.25
@export_range(1,6,0.1) var CROUCH_SPEED : float = 4.0

@onready var CROUCH_SHAPECAST: ShapeCast3D = %ShapeCast3D

var RELEASED: bool = false

func enter(previous_state: State) -> void:
	ANIMATION_PLAYER.speed_scale = 1.0
	if previous_state.name != "SliderPlayerState":
		ANIMATION_PLAYER.play("Crouch", -1.0, CROUCH_SPEED)
	elif previous_state.name == "SliderPlayerState":
		ANIMATION_PLAYER.current_animation = "Crouch"
		ANIMATION_PLAYER.seek(1.0, true)
		
func exit() -> void:
	RELEASED = false
	
func physical_update(delta: float) -> void:
	WEAPON_CONTROLLER.sway_weapon(delta, true)
	
func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_released("crouch"):
		uncrouch()
	elif Input.is_action_pressed("crouch") == false and RELEASED == false:
		RELEASED = true
		uncrouch()
		
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
		
func uncrouch() -> void:
	if !CROUCH_SHAPECAST.is_colliding() and !Input.is_action_pressed("crouch"):
		ANIMATION_PLAYER.play("Crouch", -1.0, -CROUCH_SPEED* 1.5, true)
		if ANIMATION_PLAYER.is_playing():
			await ANIMATION_PLAYER.animation_finished
		
		transition.emit("IdlePlayerState")
	if CROUCH_SHAPECAST.is_colliding():
		await get_tree().create_timer(0.1).timeout
		uncrouch()
		
