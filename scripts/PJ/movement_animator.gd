extends AnimationPlayer
@onready var mob: CharacterBody3D = $"../../"
@export var animation_tree: AnimationTree
var is_running:= false
var speed:= 0.0
var one_time_animation_is_playing: bool = false

var speed_counter_update_time = 0.2
var speed_counter_update_timer = 0.0
var last_position: Vector3

func play_one_time_animation():
	one_time_animation_is_playing = true

func _process(_delta: float) -> void:
	speed = mob.velocity.length()
	#print ("speed", speed)
	#if (!one_time_animation_is_playing):
	if speed > 0.1:
		if speed > 5:
			animation_tree.set("parameters/conditions/is_running", true)
			animation_tree.set("parameters/conditions/is_walking", true)
			animation_tree.set("parameters/conditions/!is_running", false)
			animation_tree.set("parameters/conditions/!is_walking", false)
		else: 
			animation_tree.set("parameters/conditions/is_running", false)
			animation_tree.set("parameters/conditions/!is_running", true)
			animation_tree.set("parameters/conditions/is_walking", true)
			animation_tree.set("parameters/conditions/!is_walking", false)
	else:
		animation_tree.set("parameters/conditions/is_running", false)
		animation_tree.set("parameters/conditions/is_walking", false)
		animation_tree.set("parameters/conditions/!is_running", true)
		animation_tree.set("parameters/conditions/!is_walking", true)
#Shell:
#Rig_Large_General/Idle_A
#Rig_Large_MovementBasic/Walking_A
#Rig_Large_MovementBasic/Running_A
