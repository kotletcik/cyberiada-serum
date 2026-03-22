extends Behaviour
class_name Mutation_behaviour

@export_group("follow_player")
@export var follow_state_duration:= 5.0
@export_group("wander")
@export var wander_time: float = 10.0
	
func _process(delta: float) -> void:
	Check_conditions(delta)

func Check_conditions(delta: float) -> void:
	var current = state_machine.current_state.state_type
	match current:
		State.types.Follow_player:
			if ((state_machine.mob.position) - (GameManager.instance.player.position)).length() < attack_range:
				#var _timer = get_tree().create_timer(0.5)
				#await _timer.timeout
				change_state_by_name(State.types.Debuff)
				#change_state_to("wander")
			elif timer > 0:
				timer-=delta
			else:
				change_state_by_name(State.types.Wander)
			if(PsycheManager.instance.invisibility_timer > 0):
				change_state_by_name(State.types.Wander)
		State.types.Wander:
			if (is_player_in_sight()):
				if (PsycheManager.instance.invisibility_timer <= 0): 
					change_state_by_name(State.types.Follow_player);
		
func Enter_state(state: int):
	match state:
		State.types.Follow_player:
			timer = follow_state_duration
		State.types.Wander:
			timer = wander_time
			EventBus.connect("sound_emitted_by_player", change_state_to_follow_sound)

func Exit_state(state_type: int):
	match state_type:
		State.types.Wander:
			EventBus.disconnect("sound_emitted_by_player", change_state_to_follow_sound)

func change_state_to_follow_sound(sound_pos: Vector3, sound_volume: float):
	state_machine.target = sound_pos
	change_state_to(state_machine.current_state, State.types.Follow_sound)

func change_state_to(current_state: State, _new_state_type: int):
	state_machine.transit_to_state(current_state, _new_state_type)

# func change_state_by_name(current_state_type: int, _new_state_type: int):
# 	state_machine.transit_to_state_by_name(current_state_type, _new_state_type)

func change_state_by_name(new_state: int):
	var current_state: int = state_machine.current_state.state_type;
	state_machine.transit_to_state_by_name(current_state, new_state)
