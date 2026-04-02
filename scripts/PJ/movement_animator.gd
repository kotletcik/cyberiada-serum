extends AnimationPlayer
@onready var mob: CharacterBody3D = $"../../"
@export var idle_animation_name: = ""
@export var walking_animation_name: = ""
@export var running_animation_name: = ""
func _process(delta: float) -> void:
	var speed = mob.velocity.length()
	if speed < 0.1:
		if current_animation != idle_animation_name:
			play(idle_animation_name)
	elif speed < 1:
		if current_animation != walking_animation_name:
			play(walking_animation_name)
	else:
		if current_animation != running_animation_name:
			play(running_animation_name)
#Shell:
#Rig_Large_General/Idle_A
#Rig_Large_MovementBasic/Walking_A
#Rig_Large_MovementBasic/Running_A

#Mutation
#Rig_Medium_General/Idle_A
#Rig_Medium_MovementBasic/Walking_C
#Rig_Medium_MovementBasic/Walking_C
