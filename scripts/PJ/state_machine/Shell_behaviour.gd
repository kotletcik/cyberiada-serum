extends Behaviour
class_name Shell_behaviour

@onready var nav_agent: NavigationAgent3D = $"../../NavigationAgent3D"
@onready var mesh_instance: MeshInstance3D = $"../../MeshInstance3D"
@export_group("follow_player")
@export var follow_state_duration:= 5.0
@export_group("searching_player")
@export var searching_time: float = 5.0
@export_group("follow_sound")
@export var follow_sound_state_duration:= 2.0
@export var sound_target: Node3D
@export var hearing_range := 10.0
@export_group("wander")
@export var wander_time: float = 10.0
@export_group("patrol")
@export var patrol_time: float = 10.0
@export_group("scream")
@export var scream_time: float = 1.0
	
func _process(delta: float) -> void:
	Check_conditions(delta)

func Check_conditions(delta: float) -> void:
	var current = state_machine.current_state.state_type
	match current:
		STATE_TYPES.Follow_player:
			if ((state_machine.mob.global_position) - (GameManager.instance.player.global_position)).length() < attack_range:
				change_state_by_name(current, STATE_TYPES.Attack)
			elif timer > 0:
				timer-=delta
			else:
				change_state_by_name(current, STATE_TYPES.Searching)
			if(PsycheManager.instance.invisibility_timer > 0):
				change_state_by_name(current, STATE_TYPES.Patrol)
		STATE_TYPES.Searching:
			if timer > 0:
				timer -= delta
				if (is_player_in_sight()):
					if (PsycheManager.instance.invisibility_timer <= 0): 
						change_state_by_name(current,STATE_TYPES.Scream);
			else:
				change_state_by_name(current, STATE_TYPES.Patrol)
		STATE_TYPES.Follow_sound:
			if (is_player_in_sight()):
				if (PsycheManager.instance.invisibility_timer <= 0): 
					change_state_by_name(current, STATE_TYPES.Scream);
			elif ((state_machine.mob.position) - (sound_target.position)).length() < attack_range:
				change_state_by_name(current, STATE_TYPES.Searching)
			elif timer > 0:
				timer-=delta
			elif timer < 0:
				change_state_by_name(current, STATE_TYPES.Searching)
			else:
				change_state_by_name(current, STATE_TYPES.Patrol)
		STATE_TYPES.Wander:
			if (is_player_in_sight()):
				if (PsycheManager.instance.invisibility_timer <= 0): 
					change_state_by_name(current, STATE_TYPES.Scream);
		STATE_TYPES.Patrol:
			if (is_player_in_sight()):
				if (PsycheManager.instance.invisibility_timer <= 0): 
					change_state_by_name(current, STATE_TYPES.Scream);
		STATE_TYPES.Scream:
			if timer > 0:
				timer-=delta
			else: change_state_by_name(current, STATE_TYPES.Follow_player);
		

func Enter_state(state: int):
	match state:
		STATE_TYPES.Follow_player:
			timer = follow_state_duration
		STATE_TYPES.Searching:
			EventBus.connect("sound_emitted_by_player", _is_heard_a_sound)
			timer = searching_time
		STATE_TYPES.Wander:
			timer=wander_time
			EventBus.connect("sound_emitted_by_player", _is_heard_a_sound)
		STATE_TYPES.Follow_sound:
			timer = follow_state_duration
			# Valk: dodałem aby potwór szedł do najnowszego dzwięku
			EventBus.connect("sound_emitted_by_player", _is_heard_a_sound)
		STATE_TYPES.Patrol:
			timer = patrol_time
			EventBus.connect("sound_emitted_by_player", _is_heard_a_sound)
		STATE_TYPES.Scream:
			timer = scream_time

func Exit_state(state: int):
	match state:
		STATE_TYPES.Searching:
			EventBus.disconnect("sound_emitted_by_player", _is_heard_a_sound)
		STATE_TYPES.Wander:
			EventBus.disconnect("sound_emitted_by_player", _is_heard_a_sound)
		STATE_TYPES.Follow_sound:
			EventBus.disconnect("sound_emitted_by_player", _is_heard_a_sound)
		STATE_TYPES.Patrol:
			EventBus.connect("sound_emitted_by_player", _is_heard_a_sound)

func _is_heard_a_sound(sound_pos: Vector3, volume: float):
	if ((sound_pos - state_machine.mob.global_position).length() < hearing_range * volume 
	&& state_machine.current_state.state_type != STATE_TYPES.Follow_player
	&& state_machine.current_state.state_type != STATE_TYPES.Scream):
		change_state_to_follow_sound(sound_pos)
		print("3")

func change_state_to_follow_sound(sound_pos: Vector3):
	state_machine.target = sound_pos
	change_state_to(state_machine.current_state, STATE_TYPES.Follow_sound)

func change_state_to(current_state: State, _new_state: int):
	state_machine.transit_to_state(current_state, _new_state)

func change_state_by_name(current_state: int, _new_state: int):
	state_machine.transit_to_state_by_name(current_state, _new_state)
