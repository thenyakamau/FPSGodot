class_name SprintingPlayerState

extends PlayerMovementState

@export var TOP_ANIM_SPEED: float = 1.6

func enter() -> void:
	ANIMATION_PLAYER.play("Sprinting", 0.5, 1.0)
	PLAYER._speed =PLAYER.SPEED_SPRINTING

func update(delta: float)-> void:
	set_animation_speed(Global.player.velocity.length())
	
func set_animation_speed(currentSpeed: float)-> void:
	var alpha: float = remap(currentSpeed, 0.0, PLAYER.SPEED_SPRINTING, 0.0, 1.0)
	ANIMATION_PLAYER.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)

func _input(event: InputEvent) -> void:
	if event.is_action_released("sprint"):
		transition.emit("WalkingPlayerState")
