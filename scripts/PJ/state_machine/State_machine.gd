#Musi być child'em CharacterBody3D
extends Node
class_name State_machine

@export var initial_state: State
@export var mob: CharacterBody3D
@export var nav_agent: EnemyMovement

@onready var behaviour: Shell_behaviour = $"../"

var current_state : State
# key = "nazwa": string, value = state: State
var states : Dictionary = {}

func _ready():
	if get_parent() is CharacterBody3D:
		mob = get_parent()
	
	for child in get_children():
		if child is State:
			states[child.state_type] = child 

	if initial_state:
		initial_state.Enter()
		behaviour.Enter_state(initial_state.state_type)
		current_state = initial_state
	EventBus.connect("game_restarted", transit_to_initial_state)
	EventBus.connect("level_changed", transit_to_initial_state)

func _process(delta):
	if current_state:
		current_state.Update(delta)

func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)

func transit_to_state(_state: State, new_state_type: int):
	if _state != current_state: push_error("_state != current_state in State_machine"); return

	var _new_state = states.get(new_state_type)
	if !_new_state: push_error("_new_state not found in State_machine"); return

	if current_state:
		current_state.Exit()
		behaviour.Exit_state(current_state.state_type)
	
	_new_state.Enter()
	behaviour.Enter_state(_new_state.state_type)
	current_state = _new_state
	
func transit_to_state_by_name(_state: int, _new_state: int):
	transit_to_state(states.get(_state), _new_state)

func transit_to_initial_state(_empty_arg):
	transit_to_state(current_state, initial_state.state_type)
