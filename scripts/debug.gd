extends Panel

@onready var property_container: Node = %VBoxContainer

var frames_per_second: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Set global reference to self in Global singleton
	Global.debug = self
	
	# Hide Debug Panel on load
	visible = false

func _input(event: InputEvent) -> void:
	# Toggle debug panel
	if event.is_action_pressed("debug"):
		visible = !visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		frames_per_second = "%.2f" % (1.0 / delta) # Gets the frames per second of every frame
		
	
func add_property(title: String, value: Variant, order: int) -> void:
	var target: Label = property_container.find_child(title, true, false) # check if Label node with the same name exists
	if !target:
		target = Label.new()
		property_container.add_child(target)
		target.name = title
		target.text = target.name + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value) # Update text value
		property_container.move_child(target, order) # Reorder properties based on the order value
