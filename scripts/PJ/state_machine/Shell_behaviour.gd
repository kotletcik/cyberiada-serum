extends Behaviour
class_name Shell_behaviour

@export var test_mode:= false
@export var animator: AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $"NavigationAgent3D"
@export var disabled_on_start: bool = false;
@export_group("follow_player")
@export var follow_state_duration:= 5.0
@export_group("searching_player")
@export var searching_time: float = 5.0
@export var searching_point_change_time = 2.0
@export var searching_radius = 2.0
@export_group("follow_sound")
@export var follow_sound_state_duration:= 10.0
@export var sound_target: Node3D
@export var hearing_range := 10.0
@export_group("wander")
@export var wander_time: float = 10.0
@export_group("patrol")
@export var patrol_time: float = 10.0
@export var patrol_points: Array[Node3D] = []
@export_group("scream")
@export var scream_time: float = 3.0
@export var test_mode_is_active = false
var is_screaming = false
@export_group ("attack")
@export var attack_timer: = 3.0
var is_attacking = false
var attack_target: Node3D

var disabled: bool;
var last_enabled_position: Vector3;

func _ready() -> void:
	add_to_group("Shell");
	if(disabled_on_start): disable();

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
	var player_is_on_region = player_is_on_region() && !GameManager.instance.is_player_in_safe_zone
	match current:
		State.types.Attack:
			#if ((self.global_position) - (GameManager.instance.player.global_position)).length() > attack_range:
				#change_state_by_name(State.types.Follow_player);
			#if(!is_player_in_sight || !player_is_on_region || PsycheManager.instance.invisibility_timer > 0):
			if(PsycheManager.instance.invisibility_timer > 0):
				change_state_by_name(State.types.Searching)
			if timer > 0: 
				timer -= delta
			else: change_state_by_name(State.types.Patrol)
		State.types.Follow_player:
			if ((self.global_position) - (GameManager.instance.player.global_position)).length() <= attack_range:
				change_state_by_name(State.types.Attack)
				return;
			if timer > 0:
				timer -= delta
			elif(!is_player_in_sight || !player_is_on_region || PsycheManager.instance.invisibility_timer > 0):
				change_state_by_name(State.types.Searching)
			else:
				change_state_by_name(State.types.Searching)

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
			# var distance: Vector3 = (self.global_position) - (sound_target.global_position)
			# distance.y = 0;
			if (is_player_in_sight && player_is_on_region):
				if (PsycheManager.instance.invisibility_timer <= 0): 
					change_state_by_name(State.types.Scream);
			# elif (distance.length() < attack_range):
			# 	change_state_by_name(State.types.Attack)
			elif timer > 0: timer -= delta
			elif timer < 0:
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
			#print("Doing reset for searching timer");
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
			EventBus.connect("sound_emitted_by_player", on_heard_a_sound)
			is_screaming = true
		State.types.Attack:
			timer = attack_timer
			is_attacking = true
	if (test_mode):
		var keys = State.types.keys()
		var values = State.types.values()
		var name = keys[values.find(state)]
		print(name)

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
		State.types.Scream:
			is_screaming = false
			EventBus.disconnect("sound_emitted_by_player", on_heard_a_sound)
		State.types.Attack:
			is_attacking = false

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
	if (sound_distance < hearing_range * volume && current_state != State.types.Follow_player || (current_state == State.types.Scream && volume > 10.0)):
		state_machine.target = sound_pos
		if (current_state != State.types.Follow_sound):
			state_machine.transit_to_state(state_machine.current_state, State.types.Follow_sound)

func change_state_by_name(new_state: int):
	var current_state: int = state_machine.current_state.state_type;
	state_machine.transit_to_state_by_name(current_state, new_state)
