extends AnimationPlayer
@onready var mob: CharacterBody3D = $"../../"
@export var animation_tree: AnimationTree
var one_time_animation_is_playing: bool = false

func play_one_time_animation():
	one_time_animation_is_playing = true

func _process(_delta: float) -> void:
	if (!one_time_animation_is_playing):
		var speed = mob.velocity.length()
		animation_tree.set("parameters/Run/blend_position", speed)
#Shell:
#Rig_Large_General/Idle_A
#Rig_Large_MovementBasic/Walking_A
#Rig_Large_MovementBasic/Running_A

