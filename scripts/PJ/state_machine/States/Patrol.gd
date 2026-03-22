extends State
class_name Patrol

@export var empty_target: Node3D
@export var patrol_point_waiting_time:= 3.0
var current_target_pos: int = 0
var is_Staying: bool = false
var timer:= 0.0
var patrol_points: Array[Node3D] = []
	
func Enter():
	super.Enter()
	state_machine.nav_agent.target = empty_target
	patrol_points = state_machine.behaviour.patrol_points
	change_target_to_next_pos()


func Update (delta: float):
	if (patrol_points.is_empty()): return;

	var point_distance = (state_machine.mob.global_position - patrol_points[current_target_pos].global_position).length();
	if(point_distance <= 1 && !is_Staying):
		timer = patrol_point_waiting_time
		#while (state_machine.nav_agent.move_speed > 0):
			#state_machine.nav_agent.move_speed -= state_machine.mob.acceleration * delta * -state_machine.mob.transform.basis.z
		state_machine.nav_agent.move_speed = 0.1
		change_target_to_next_pos()
		is_Staying = true
	elif (is_Staying):
		if (timer < 0):
			#while (state_machine.nav_agent.move_speed > 0):
				#state_machine.nav_agent.move_speed += state_machine.mob.acceleration * delta * -state_machine.mob.transform.basis.z
			state_machine.nav_agent.move_speed = move_speed
			is_Staying = false
		else: timer -= delta
	empty_target.global_position = empty_target.global_position
	
func change_target_to_next_pos():
	if (patrol_points.is_empty()): return
	if (current_target_pos >= patrol_points.size() - 1):
		current_target_pos = 0
	else: current_target_pos += 1
	empty_target.global_position = patrol_points[current_target_pos].global_position
