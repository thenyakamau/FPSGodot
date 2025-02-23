class_name WalkingPlayerState

extends PlayerMovementState

@export var SPEED :float = 5.0
@export var ACCELERATION :float = 0.1
@export var DECELERATION :float = 0.25
@export var TOP_ANIM_SPEED: float = 2.2

func enter(previous_state: State) -> void:
	if ANIMATION_PLAYER.is_playing() and ANIMATION_PLAYER.current_animation == "JumpEnd":
		await ANIMATION_PLAYER.animation_finished
		
	ANIMATION_PLAYER.play("Walking", -1.0, 1.0)
	
func exit() -> void:
	ANIMATION_PLAYER.speed_scale = 1.0
	
func physical_update(delta: float) -> void:
	WEAPON_CONTROLLER.sway_weapon(delta, true)

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	var playerSpeed: float = PLAYER.velocity.length()
	set_animation_speed(playerSpeed)
	
	if Input.is_action_pressed("sprint") and PLAYER.is_on_floor():
		transition.emit("SprintingPlayerState")
	
	if Input.is_action_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
	
	if playerSpeed == 0.0:
		transition.emit("IdlePlayerState")
		
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
		
	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")

func set_animation_speed(currentSpeed: float)-> void:
	var alpha: float = remap(currentSpeed, 0.0, SPEED, 0.0, 1.0)
	ANIMATION_PLAYER.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)
