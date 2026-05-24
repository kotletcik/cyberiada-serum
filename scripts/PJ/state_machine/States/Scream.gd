extends State
class_name Scream

var scream_time := 1.0
@export var screaming_sound: AudioStreamPlayer3D

func Enter():
	super.Enter();
	screaming_sound.play()
	update_target_position(state_machine.mob.global_position);
