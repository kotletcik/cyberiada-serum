#zarządzanie state'ami mobów z AI
#Musi być child'em CharacterBody3D
#Wszystkie state'y jako child'y (Node 'State')
extends Node
class_name State_machine

@export var initial_state: State
#mob do którego się odnosi ten skrypt
@export var mob: CharacterBody3D
@export var nav_agent: NavigationAgent3D
@onready var mesh := $"../MeshInstance3D"
@onready var behaviour: Behaviour = $"../"
var target: Vector3
var mat: StandardMaterial3D
var current_state : State
# key = "nazwa": string, value = state: State
var states : Dictionary = {}

func _ready():
	if get_parent() is CharacterBody3D:
		mob = get_parent()
		
	mat = mesh.get_active_material(0).duplicate()
	mesh.set_surface_override_material(0, mat)
	
	for child in get_children():
		if child is State:
			states[child.state_type] = child 
			child.Transitioned.connect(transit_to_state)
	if initial_state:
		initial_state.Enter()
		behaviour.Enter_state(initial_state.state_type)
		current_state = initial_state
	EventBus.connect("game_restarted", transit_to_initial_state)
	EventBus.connect("level_changed", transit_to_initial_state)

#aktualizuje process current_state
func _process(delta):
	if current_state:
		current_state.Update(delta)

func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)


#zmiana state'u czyli wył. current state i wł new state
func transit_to_state(_state:State, new_state_type: int):
	if _state != current_state:
		return
	var _new_state = states.get(new_state_type)
	if !_new_state:
		return
	if current_state:
		current_state.Exit()
		behaviour.Exit_state(current_state.state_type)
	
	_new_state.Enter()
	behaviour.Enter_state(_new_state.state_type)
	current_state = _new_state
	
#funckja dla sygnałów
func transit_to_initial_state(empty_arg):
	transit_to_state(current_state, initial_state.state_type)
	
func transit_to_state_by_name(_state: int, _new_state: int):
	transit_to_state(states.get(_state), _new_state)
