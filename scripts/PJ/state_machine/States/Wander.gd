extends State
class_name Wander

@export var wander_radius: float = 5
@export var wander_target_change_time := 5.0
var timer: float

	
func _ready() -> void:
	timer = wander_target_change_time
	
func Enter():
	super.Enter();
	randomize_wander()

func Update (delta: float):	
	timer -= delta
	if (timer < 0):
		randomize_wander()
		timer = wander_target_change_time

func randomize_wander():
	state_machine.nav_agent.update_target_position(random_pos_in_range(wander_radius));
	#nav_agent.target_pos = state_machine.mob.position + Vector3(randf_range(-1, 1),0,randf_range(-1, 1))
	state_machine.nav_agent.move_speed = move_speed

func random_pos_in_current_region() -> Vector3:
	return state_machine.mob.global_position + Vector3(\
	randf_range(-2, 2),\
	state_machine.mob.global_position.y, \
	randf_range(-2, 2))
func random_pos_in_range(range: float) -> Vector3:
	var alfa : float = randf() * (2*PI)
	return state_machine.mob.global_position + Vector3(\
	range, 0, 0) * cos(alfa) + Vector3(\
	0, 0, range) * sin(alfa)
