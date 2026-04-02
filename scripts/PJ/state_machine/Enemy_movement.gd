extends NavigationAgent3D
#Odpowiada za nadawanie prędkości ruchu i targeta dla navAgent3D

@onready var mob: CharacterBody3D = $"../"
@export var general_move_speed: float = 1.0
@export var acceleration: float=1 # jak szybko agent nabiera i traci prędkość move_speed
var move_speed : float = 2.0
var update_target_pos_timer: float = 1.0
var target: Node3D
# var is_active: bool = true nieuzywany?
var timer
var rotation_speed = 15.0

func _ready() -> void:
	mob = get_parent()
	update_target_pos_every(update_target_pos_timer)
	
func _physics_process(delta: float):
	var destination = get_next_path_position()
	if((destination - mob.global_position).length() < 1): return; 
	var local_destination = destination - mob.global_position

	var direction = local_destination.normalized()
	var direction_flat = Vector3(direction.x, 0, direction.z).normalized()

	# var next_position = get_next_path_position()
	# var offset = destination - mob.global_position

	if direction_flat.length() != 0 && local_destination.length() > 1:
		var target_yaw = atan2(-direction_flat.x, -direction_flat.z)
		mob.rotation.y = lerp_angle(mob.rotation.y, target_yaw , rotation_speed * delta)

	var _y_vel = mob.velocity.y
	var acc_coeff = 1
	var forward = -mob.transform.basis.z
	if (abs(mob.velocity.dot(forward) - move_speed) > 0.5 && mob.velocity.length() < 6.0):
		if (mob.velocity.dot(forward) < move_speed):
			acc_coeff = 1
		else : 
			acc_coeff = -10
		mob.velocity = (mob.velocity.length() + acc_coeff * acceleration * delta) * -mob.transform.basis.z
		
	else: mob.velocity = forward * move_speed

	# if(local_destination.length() < 0.9):
	# 	mob.velocity *= 0.1;

	mob.velocity.y = _y_vel
	if is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
	mob.move_and_slide()

func stop_immediately():
	move_speed = 0
	var _y_vel = mob.velocity.y
	mob.velocity = Vector3.ZERO
	mob.velocity.y = _y_vel

func update_target_pos_every(_update_target_pos_timer: float):
	if target:
		set_target_position(target.position)
	timer = get_tree().create_timer(_update_target_pos_timer)
	await timer.timeout
	# if is_active:
	update_target_pos_every(update_target_pos_timer)
		
func update_target(): #nieuzywany?
	timer.stop()
