class_name IdlePlayerState

extends PlayerMovementState

@export var SPEED :float = 5.0
@export var ACCELERATION :float = 0.1
@export var DECELERATION :float = 0.25
@export var TOP_ANIM_SPEED :float = 2.2

func enter(previous_state: State) -> void:
	if ANIMATION_PLAYER.is_playing() and ANIMATION_PLAYER.current_animation == "JumpEnd":
		await ANIMATION_PLAYER.animation_finished2
		
	ANIMATION_PLAYER.pause()
	
func physical_update(delta: float) -> void:
	WEAPON_CONTROLLER.sway_weapon(delta, true)

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
	
	if PLAYER.velocity.length() > 0.0 and PLAYER.is_on_floor():
		transition.emit("WalkingPlayerState")
		
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
		
	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
