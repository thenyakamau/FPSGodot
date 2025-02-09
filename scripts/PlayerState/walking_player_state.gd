class_name WalkingPlayerState

extends PlayerMovementState

@export var TOP_ANIM_SPEED: float = 2.2

func enter() -> void:
	ANIMATION_PLAYER.play("Walking", -1.0, 1.0)
	PLAYER._speed = PLAYER.SPEED_DEFAULT

func update(delta: float) -> void:
	var playerSpeed: float = PLAYER.velocity.length()
	set_animation_speed(playerSpeed)
	
	if playerSpeed == 0.0:
		transition.emit("IdlePlayerState")

func set_animation_speed(currentSpeed: float)-> void:
	var alpha: float = remap(currentSpeed, 0.0, PLAYER.SPEED_DEFAULT, 0.0, 1.0)
	ANIMATION_PLAYER.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("sprint") and PLAYER.is_on_floor():
		transition.emit("SprintingPlayerState")
