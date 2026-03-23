extends State
class_name Scream
var scream_time:= 1.0

func Update(_delta: float):
	scream()

func scream():
	state_machine.mob.animator.play("Rig_Large_Simulation/Flexing")
	pass
	
	
