class_name PlayerMovementState

extends State

var PLAYER: Player
var ANIMATION_PLAYER: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Waits for parent to be ready before it starts executing code
	await owner.ready
	
	PLAYER = owner as Player
	ANIMATION_PLAYER = PLAYER.ANIMATIONPLAYER

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
