extends State
class_name Searching

var searching_point_change_time: float = 1.0
var searching_radius: float = 1.0
var searching_point_timer: float
var searching_area_center: Vector3

func randomize_searching_point():
	state_machine.nav_agent.move_speed = move_speed
	update_target_position(get_random_pos_in_range(searching_radius));
	
func random_pos_in_current_region() -> Vector3:
	return state_machine.mob.global_position + Vector3( randf_range(-2, 2), state_machine.mob.global_position.y, randf_range(-2, 2))
	
# func calculate_random_pos_in_range(ai_range: float) -> Vector3:
# 	var destination: Vector3 = get_random_pos_in_range(ai_range);
# 	var query = PhysicsRayQueryParameters3D.create(state_machine.mob.global_position, destination);
# 	var collision = state_machine.mob.get_world_3d().direct_space_state.intersect_ray(query);
# 	while(!collision.is_empty()):
# 		destination = get_random_pos_in_range(ai_range)
# 		query = PhysicsRayQueryParameters3D.create(state_machine.mob.global_position, destination);
# 		collision = state_machine.mob.get_world_3d().direct_space_state.intersect_ray(query);
# 	return destination;

func get_random_pos_in_range(ai_range: float) -> Vector3:
	var angle : float = (2*PI) * randf() 
	var distance: float = ai_range * randf()
	return searching_area_center + Vector3(distance, 0, 0) * cos(angle) + Vector3(0, 0, distance) * sin(angle)
	
func Enter():
	super.Enter();
	state_machine.nav_agent.stop_immediately()
	searching_area_center = state_machine.mob.global_position
	searching_point_change_time = state_machine.behaviour.searching_point_change_time
	searching_radius = state_machine.behaviour.searching_radius 
	searching_point_timer = searching_point_change_time

	randomize_searching_point()

func Update(delta: float):
	searching_point_timer -= delta
	print(searching_point_timer)
	if searching_point_timer < 0:
		randomize_searching_point()
		searching_point_timer = searching_point_change_time

	if (state_machine.mob.global_position - state_machine.nav_agent.target_position).length() < 1:
		state_machine.nav_agent.stop_immediately()
	else: 
		state_machine.nav_agent.move_speed = move_speed
	
