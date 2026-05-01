extends Behaviour
class_name Shell_behaviour

@onready var animator: AnimationPlayer = $"Skin/AnimationPlayer"
@onready var nav_agent: NavigationAgent3D = $"NavigationAgent3D"
@export_group("follow_player")
@export var follow_state_duration:= 5.0
@export_group("searching_player")
@export var searching_time: float = 5.0
@export var searching_point_change_time = 2.0
@export var searching_radius = 2.0
@export_group("follow_sound")
@export var follow_sound_state_duration:= 2.0
@export var sound_target: Node3D
@export var hearing_range := 10.0
@export_group("wander")
@export var wander_time: float = 10.0
@export_group("patrol")
@export var patrol_time: float = 10.0
@export var patrol_points: Array[Node3D] = []
@export_group("scream")
@export var scream_time: float = 1.0
@export var test_mode_is_active = false
	
func _ready() -> void:
	add_to_group("Shell");

func _process(delta: float) -> void:
	Check_conditions(delta)

func Check_conditions(delta: float) -> void:
	var current = state_machine.current_state.state_type
	var is_player_in_sight = is_player_in_sight()
	var player_is_on_region = player_is_on_region()
	match current:
		State.types.Attack:
			if ((self.global_position) - (GameManager.instance.player.global_position)).length() > attack_range:
				change_state_by_name(State.types.Follow_player);
			if(!is_player_in_sight || !player_is_on_region || PsycheManager.instance.invisibility_timer > 0):
				change_state_by_name(State.types.Searching)
		State.types.Follow_player:
			if ((self.global_position) - (GameManager.instance.player.global_position)).length() <= attack_range:
				change_state_by_name(State.types.Attack)
				return;
			if timer > 0:
				timer -= delta
			elif(!is_player_in_sight || !player_is_on_region || PsycheManager.instance.invisibility_timer > 0):
				change_state_by_name(State.types.Searching)
			else:
				timer = follow_state_duration

			# if(PsycheManager.instance.invisibility_timer > 0):
			# 	change_state_by_name(State.types.Patrol)
			# if (!player_is_on_region):
			# 	change_state_by_name(State.types.Patrol)
		State.types.Searching:
			if timer > 0:
				timer -= delta
				if (is_player_in_sight && player_is_on_region):
					if (PsycheManager.instance.invisibility_timer <= 0): 
						change_state_by_name(State.types.Scream);
			else:
				change_state_by_name(State.types.Patrol)
		State.types.Follow_sound:
			var temp: Vector3 = (self.global_position) - (sound_target.global_position)
			temp.y = 0;
			if (is_player_in_sight && player_is_on_region):
				if (PsycheManager.instance.invisibility_timer <= 0): 
					change_state_by_name(State.types.Scream);
			elif (temp.length() < 1.5):
				change_state_by_name(State.types.Searching)
			elif timer > 0: timer -= delta
			elif timer < 0:
				change_state_by_name(State.types.Searching)
			else:
				change_state_by_name(State.types.Patrol)
		State.types.Wander:
			if (is_player_in_sight && player_is_on_region):
				if (PsycheManager.instance.invisibility_timer <= 0): 
					change_state_by_name(State.types.Scream);
		State.types.Patrol:
			if (is_player_in_sight && player_is_on_region):
				if (PsycheManager.instance.invisibility_timer <= 0): 
					change_state_by_name(State.types.Scream);
		State.types.Scream:
			if timer > 0:
				timer -= delta
			else: change_state_by_name(State.types.Follow_player);
		

func Enter_state(state: int):
	match state:
		State.types.Follow_player:
			timer = follow_state_duration
		State.types.Searching:
			EventBus.connect("sound_emitted_by_player", on_heard_a_sound)
			timer = searching_time
			print("Doing reset for searching timer");
		State.types.Wander:
			timer = wander_time
			EventBus.connect("sound_emitted_by_player", on_heard_a_sound)
		State.types.Follow_sound:
			timer = follow_sound_state_duration
			EventBus.connect("sound_emitted_by_player", on_heard_a_sound)
		State.types.Patrol:
			timer = patrol_time
			EventBus.connect("sound_emitted_by_player", on_heard_a_sound)
		State.types.Scream:
			timer = scream_time

func Exit_state(state: int):
	match state:
		State.types.Searching:
			EventBus.disconnect("sound_emitted_by_player", on_heard_a_sound)
		State.types.Wander:
			EventBus.disconnect("sound_emitted_by_player", on_heard_a_sound)
		State.types.Follow_sound:
			EventBus.disconnect("sound_emitted_by_player", on_heard_a_sound)
		State.types.Patrol:
			EventBus.disconnect("sound_emitted_by_player", on_heard_a_sound)

func player_is_on_region() -> bool:
	var map_rid = nav_agent.get_navigation_map()
	var closest_point = NavigationServer3D.map_get_closest_point(map_rid, GameManager.instance.player.global_position)
	if (test_mode_is_active):
		print(closest_point)
	var distance = GameManager.instance.player.global_position.distance_to(closest_point)
	return true if distance < 1 else false;

func on_heard_a_sound(sound_pos: Vector3, volume: float):
	var current_state: int = state_machine.current_state.state_type;
	var sound_distance: float = (sound_pos - state_machine.mob.global_position).length();
	if (sound_distance < hearing_range * volume && current_state != State.types.Follow_player && current_state != State.types.Scream):
		state_machine.target = sound_pos
		state_machine.transit_to_state(state_machine.current_state, State.types.Follow_sound)

func change_state_by_name(new_state: int):
	var current_state: int = state_machine.current_state.state_type;
	state_machine.transit_to_state_by_name(current_state, new_state)
