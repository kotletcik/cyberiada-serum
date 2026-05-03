extends AnimationPlayer
@onready var mob: CharacterBody3D = $"../../"
@export var idle_animation_name: = ""
@export var walking_animation_name: = ""
@export var running_animation_name: = ""
@export var animation_tree: AnimationTree
@export var test_mode:= false
var one_time_animation_is_playing: bool = false
var last_pos:Vector3

func play_one_time_animation():
	one_time_animation_is_playing = true
	
func _ready() -> void:
	test_mode = get_parent().get_parent().test_mode

func _process(delta: float) -> void:
	if (!one_time_animation_is_playing):
		#var current_pos = mob.global_position
		#var real_speed = lerp(0.0, (current_pos - last_pos).length()/delta, 0.1)
		#last_pos = current_pos
		var speed = mob.velocity.length()
		#if (test_mode):
			#print("speed: ", speed)
		animation_tree.set("parameters/Run/blend_position", speed)
		#if speed < 0.1:
			#if current_animation != idle_animation_name:
				#play(idle_animation_name)
		#elif speed < 1:
			#if current_animation != walking_animation_name:
				#play(walking_animation_name)
		#else:
			#if current_animation != running_animation_name:
				#play(running_animation_name)
#Shell:
#Rig_Large_General/Idle_A
#Rig_Large_MovementBasic/Walking_A
#Rig_Large_MovementBasic/Running_A

#Mutation
#Rig_Medium_General/Idle_A
#Rig_Medium_MovementBasic/Walking_C
#Rig_Medium_MovementBasic/Walking_C
