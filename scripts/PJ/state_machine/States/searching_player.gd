extends State
class_name Searching

@export var empty_target: Node3D
var searching_point_change_time: float = 1.0
var searching_radius: float = 1.0
var searching_point_timer: float
var searching_area_center: Vector3

func randomize_searching_point():
	empty_target.position = random_pos_in_range(searching_radius)
	#nav_agent.target_pos = state_machine.mob.position + Vector3(randf_range(-1, 1),0,randf_range(-1, 1))
	state_machine.nav_agent.move_speed = move_speed
	
func random_pos_in_current_region() -> Vector3:
	return state_machine.mob.global_position + Vector3(\
	randf_range(-2, 2),\
	state_machine.mob.global_position.y, \
	randf_range(-2, 2))
	
func random_pos_in_range(range: float) -> Vector3:
	var angle : float = (2*PI) * randf() 
	var distance: float = range * randf()
	return searching_area_center + Vector3(\
	distance, 0, 0) * cos(angle) + Vector3(\
	0, 0, distance) * sin(angle)
	
func Enter():
	super.Enter()
	state_machine.nav_agent.target = empty_target
	searching_area_center = state_machine.mob.global_position
	searching_point_change_time = state_machine.behaviour.searching_point_change_time
	searching_radius = state_machine.behaviour.searching_radius 

	randomize_searching_point()

func Update (delta: float):
	if searching_point_timer < 0:
		randomize_searching_point()
		searching_point_timer = searching_point_change_time
	else:
		searching_point_timer -= delta
	if (state_machine.mob.global_position - empty_target.global_position).length() < 1:
		state_machine.nav_agent.stop_immediately()
	else: state_machine.nav_agent.move_speed = move_speed
	empty_target.global_position = empty_target.global_position

#func change_state_to_follow():
	#change_state_to("follow_player")
#
#func change_state_to_wander():
	#change_state_to("wander")

func Exit():
	super.Exit()
	
