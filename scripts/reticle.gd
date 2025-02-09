extends CenterContainer

@export var DOT_RADIUS: float = 1.0
@export var RECTICLE_SPEED: float = 0.25
@export var RECTICLE_DISTANCE: float = 2
@export var DOT_COLOR: Color = Color.WHITE

@export var RETICLE_LINES: Array[Line2D]
@export var PLAYER_CONTROLLER: CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	adjust_reticle_lines()
	
func _draw() -> void:
	draw_circle(Vector2(0, 0), DOT_RADIUS, DOT_COLOR)


func adjust_reticle_lines() -> void:
	var _playerVelocity: Vector3 = PLAYER_CONTROLLER.get_real_velocity()
	var origin: Vector3 = Vector3(0, 0, 0)
	var pos: Vector2 = Vector2(0, 0)
	var speed: float = origin.distance_to(_playerVelocity)
	
	# Adjust Recticle Line Position
	var adjustMent: float = -1
	for index in len(RETICLE_LINES):
		var currentX: float = (adjustMent * speed) * RECTICLE_DISTANCE if index % 2 > 0 else 0.0
		var currentY: float = 0.0 if index % 2 > 0 else (adjustMent * speed) * RECTICLE_DISTANCE
		
		RETICLE_LINES[index].position = lerp(RETICLE_LINES[index].position, pos + Vector2(currentX, currentY), RECTICLE_SPEED)
		if currentX == 0:
			adjustMent *= -1
