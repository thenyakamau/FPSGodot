class_name IdlePlayerState

extends PlayerMovementState

@export var TOP_ANIM_SPEED :float = 2.2

func enter() -> void:
	ANIMATION_PLAYER.pause()

func update(delta: float) -> void:
	if PLAYER.velocity.length() > 0.0 and PLAYER.is_on_floor():
		transition.emit("WalkingPlayerState")
