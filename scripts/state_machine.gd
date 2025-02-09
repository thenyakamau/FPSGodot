class_name StateMachine

extends Node

@export var CURRENT_STATE: State
var states: Dictionary = {}

func _ready() -> void:
	# Get children states and assign them to state dict
	for child in get_children():
		if child is State:
			states[child.name] = child
			# attatch signal to transition function
			child.transition.connect(on_child_transition)
		else:
			push_warning("State machine contains incompatible child nodes")
	
	# Waits for parent to be ready before it starts executing code
	await owner.ready
	CURRENT_STATE.enter()

func _process(delta: float) -> void:
	CURRENT_STATE.update(delta)
	
	Global.debug.add_property("Current State", CURRENT_STATE.name, 1)
	
func _physics_process(delta: float) -> void:
	CURRENT_STATE.physical_update(delta)

# Manage transition changes in state
func on_child_transition(new_state_name: StringName) -> void:
	var new_state: State = states.get(new_state_name)
	if new_state == null:
		push_warning("State does not exit")
		return
	
	if new_state!= CURRENT_STATE:
		CURRENT_STATE.exit()
		new_state.enter()
		CURRENT_STATE = new_state
