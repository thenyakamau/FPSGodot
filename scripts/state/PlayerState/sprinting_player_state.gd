class_name SprintingPlayerState

extends PlayerMovementState

@export var SPEED :float = 7.0
@export var ACCELERATION :float = 0.1
@export var DECELERATION :float = 0.25
@export var TOP_ANIM_SPEED: float = 1.6

func enter(previous_state: State) -> void:
	if ANIMATION_PLAYER.is_playing() and ANIMATION_PLAYER.current_animation == "JumpEnd":
		await ANIMATION_PLAYER.animation_finished
		
	ANIMATION_PLAYER.play("Sprinting", 0.5, 1.0)
	
func physical_update(delta: float) -> void:
	WEAPON_CONTROLLER.sway_weapon(delta, true)

func update(delta: float)-> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	set_animation_speed(Global.player.velocity.length())
	
	if Input.is_action_just_released("sprint") or PLAYER.velocity.length() == 0.0:
		transition.emit("IdlePlayerState")
		
	if Input.is_action_just_pressed("crouch") and PLAYER.velocity.length() > 6:
		transition.emit("SlidingPlayerState")
		
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
		
	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
	
func set_animation_speed(currentSpeed: float)-> void:
	var alpha: float = remap(currentSpeed, 0.0, SPEED, 0.0, 1.0)
	ANIMATION_PLAYER.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)
