extends State
class_name Scream
var scream_time:= 1.0

@export var screaming_sound: AudioStreamPlayer3D

func Enter():
	screaming_sound.play()

func Update(_delta: float):
	scream()

func scream():
	state_machine.mob.animator.play("Rig_Large_Simulation/Flexing")
	
	pass
	
	
