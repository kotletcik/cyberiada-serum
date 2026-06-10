extends Behaviour
class_name Shell_behaviour

@export var debug_index: int = 0;
@export var test_mode:= false
@export var animator: AnimationPlayer
@export var disabled_on_start: bool = false;
@export var stuck_return_timer: float = 2.0;
@export var stuck_range_length: float = 0.01;

@onready var nav_agent: NavigationAgent3D = $"NavigationAgent3D"

@export_group("follow_player")
@export var follow_player_through_walls_duration:= 5.0

@export_group("searching_player")
@export var searching_time: float = 5.0
@export var searching_point_change_time = 2.0
@export var searching_radius = 2.0

@export_group("follow_sound")
@export var follow_sound_state_duration:= 10.0
@export var hearing_range := 10.0

@export_group("wander")
@export var wander_time: float = 10.0

@export_group("patrol")
@export var patrol_time: float = 10.0
@export var patrol_points: Array[Node3D] = []

@export_group("scream")
@export var scream_time: float = 3.0
@export var test_mode_is_active = false

@export_group ("attack")
@export var attack_timer: = 3.0

var is_screaming = false
var is_attacking = false

var disabled: bool;
var last_enabled_position: Vector3;

var last_position: Vector3;
var stuck_timer: float = 0.0;
var stuck_displacement: float = 0.0;

func _ready() -> void:
	add_to_group("Shell");
	if(disabled_on_start): disable();
	last_position = global_position;

func _process(delta: float) -> void:
	if(disabled): return;
	Check_conditions(delta)

func disable():
	visible = false;
	last_enabled_position = global_position;
	get_node("CollisionShape3D").disabled = true;
	disabled = true;

func enable():
	visible = true;
	get_node("CollisionShape3D").disabled = false;
	disabled = false;
	global_position = last_enabled_position;


func Check_conditions(delta: float) -> void:
	var current = state_machine.current_state.state_type
	var is_player_in_sight = is_player_in_sight()
	var is_player_on_region = player_is_on_region() && !GameManager.instance.is_player_in_safe_zone
	
	match current:
		State.types.Attack:
			#if ((self.global_position) - (GameManager.instance.player.global_position)).length() > attack_range:
				#change_state_by_name(State.types.Follow_player);
			#if(!is_player_in_sight || !is_player_on_region || PsycheManager.instance.invisibility_timer > 0):
			if(PsycheManager.instance.invisibility_timer > 0):
				change_state_by_name(State.types.Searching); return;

			timer -= delta
			if timer <= 0: change_state_by_name(State.types.Patrol)
		State.types.Follow_player:
			if ((self.global_position) - (GameManager.instance.player.global_position)).length() <= attack_range:
				change_state_by_name(State.types.Attack)
				return;
			if(!is_player_on_region || PsycheManager.instance.invisibility_timer > 0):
				change_state_by_name(State.types.Searching);
				return;
			if(!is_player_in_sight):
				if timer > 0:
					timer -= delta
				else:
					change_state_by_name(State.types.Searching)
		State.types.Searching:
			timer -= delta
			if timer > 0:
				if (is_player_in_sight && is_player_on_region):
					if (PsycheManager.instance.invisibility_timer <= 0): 
						change_state_by_name(State.types.Scream);
			else:
				change_state_by_name(State.types.Patrol)
		State.types.Follow_sound:
			var distance: Vector3 = (self.global_position) - (nav_agent.target_position);
			distance.y = 0;
			if (is_player_in_sight && is_player_on_region):
				if (PsycheManager.instance.invisibility_timer <= 0): 
					change_state_by_name(State.types.Scream); return;
			elif (distance.length() < searching_radius):
				change_state_by_name(State.types.Searching); return;

			timer -= delta
			if timer < 0:
				change_state_by_name(State.types.Patrol); return;
		State.types.Wander:
			if (is_player_in_sight && is_player_on_region):
				if (PsycheManager.instance.invisibility_timer <= 0): 
					change_state_by_name(State.types.Scream);
		State.types.Patrol:
			if (is_player_in_sight && is_player_on_region):
				if (PsycheManager.instance.invisibility_timer <= 0): 
					change_state_by_name(State.types.Scream);
		State.types.Scream:
			# print(timer);
			if timer > 0:
				timer -= delta
			else: change_state_by_name(State.types.Follow_player);

	# print((global_position - last_position).length());
	# if(test_mode): print(stuck_displacement);
	stuck_timer += delta;
	stuck_displacement += (global_position - last_position).length()
	if(stuck_timer >= stuck_return_timer):
		if(stuck_displacement <= stuck_range_length && reset_stuck_state_for(current)):
			if(is_current_state_hostile(current)):
				change_state_by_name(State.types.Searching);
			else:
				change_state_by_name(State.types.Patrol);
		stuck_displacement = 0;
		stuck_timer = 0;
	
	last_position = global_position;
		

func is_current_state_hostile(state: int) -> bool:
	match state:
		State.types.Follow_player: return true;
	return false;

func reset_stuck_state_for(state: int) -> bool:
	match state:
		State.types.Scream: return false;
		State.types.Attack: return false;
	return true;

func connect_sound_to_state(state: int) -> bool:
	match state:
		State.types.Searching: return true;
		State.types.Wander: return true;
		State.types.Follow_sound: return true;
		State.types.Patrol: return true;
	return false;

func get_state_default_timer(state: int) -> float:
	match state:
		State.types.Follow_player: return follow_player_through_walls_duration;
		State.types.Searching: return searching_time;
		State.types.Wander: return wander_time;
		State.types.Follow_sound: return follow_sound_state_duration;
		State.types.Patrol: return patrol_time;
		State.types.Scream: return scream_time;
		State.types.Attack: return attack_timer;
	return 0.0;

func Enter_state(state: int):
	if(connect_sound_to_state(state)):
		EventBus.connect("sound_emitted_by_player", on_heard_a_sound);	

	timer = get_state_default_timer(state);
	match state:
		State.types.Scream:
			print("Shell " + str(debug_index) + " switched to scream");
			is_screaming = true;
		State.types.Attack:
			is_attacking = true;

	if (test_mode):
		var keys = State.types.keys()
		print(keys[state])

func Exit_state(state: int):
	if(connect_sound_to_state(state)):
		EventBus.disconnect("sound_emitted_by_player", on_heard_a_sound);	

	match state:
		State.types.Scream:
			is_screaming = false;
		State.types.Attack:
			is_attacking = false;

func is_player_in_sight() -> bool:
	if (disable_fov_check): return false;
	if (state_machine == null): return false
	var player_in_local: Vector3 = GameManager.instance.player.global_position - self.global_position;
	var direction = player_in_local.normalized();
	dot = self.global_basis.z.dot(direction);
	if(test_mode): 
		# print(player_in_local);
		DebugDraw3D.draw_line(global_position, global_position + direction * player_sight_range, Color.RED);
	if(player_in_local.length() > player_sight_range): return false;
	if(dot < 1-(player_sight_fov/180)): #if(dot > (cos(deg_to_rad(player_sight_fov)/2))):
		if (PsycheManager.instance.invisibility_timer > 0): return false;
		var query = PhysicsRayQueryParameters3D.create(global_position, global_position + direction * player_sight_range);
		var space_state = self.get_world_3d().direct_space_state
		var result = space_state.intersect_ray(query);
		if(!result.is_empty()):
			# print(result["collider"]);
			if result["collider"] is CharacterBody3D:
				return true;
	return false;

func player_is_on_region() -> bool:
	var map_rid = nav_agent.get_navigation_map()
	var closest_point = NavigationServer3D.map_get_closest_point(map_rid, GameManager.instance.player.global_position)
	if (test_mode_is_active):
		print(closest_point)
	var distance = GameManager.instance.player.global_position.distance_to(closest_point)
	return true if distance < 1 else false;

func on_heard_a_sound(sound_pos: Vector3, volume: float):
	var current_state: int = state_machine.current_state.state_type;
	if(current_state ==  State.types.Follow_sound || current_state == State.types.Follow_player): return;
	var sound_distance: float = (sound_pos - state_machine.mob.global_position).length();
	if (sound_distance < hearing_range * volume || (current_state == State.types.Scream && volume > 10.0)):
		state_machine.transit_to_state(state_machine.current_state, State.types.Follow_sound)
		state_machine.nav_agent.update_target_position(sound_pos);

func change_state_by_name(new_state: int):
	var current_state: int = state_machine.current_state.state_type;
	var keys = State.types.keys()
	if(test_mode): print("Switching to " + str(keys[new_state]) + " from " + str(keys[current_state]));
	state_machine.transit_to_state_by_name(current_state, new_state)
	stuck_timer = 0;
