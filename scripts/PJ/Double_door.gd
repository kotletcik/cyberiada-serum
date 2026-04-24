extends Node3D

var isOpened: bool = false
var isMoving: bool = false
@export var isDisposable: bool = false
@export var move_distance:= 2.0
@export var move_duration:= 0.5
@export var first_door: Node3D
@export var second_door: Node3D
@export var is_lift_door: bool = false;
@onready var nav_region: NavigationRegion3D = get_parent() as NavigationRegion3D
@export var unlock_if_clue_realized: Clue;

var interacted: bool = false;

# var first_door_start_local_pos_z;
# var second_door_start_local_pos_z;
# var first_door_final_local_pos_z;
# var second_door_final_local_pos_z;

# var time = 0;

func _ready() -> void:
	if(is_lift_door):
		EventBus.close_final_door.connect(close_door);

func player_interact():
	if(unlock_if_clue_realized != null):
		if(!PalaceManager.instance.is_clue_realized(unlock_if_clue_realized)): return;
	
	if (!isMoving):
		if (isDisposable && interacted): return
		else: 
			interacted = true;
		isMoving = true
		switch_open()
		# time = 0
		# first_door_start_local_pos_z = first_door.position.z
		# second_door_start_local_pos_z = second_door.position.z
		# first_door_final_local_pos_z = first_door.position.z + move_distance if !isOpened else first_door.position.z - move_distance;
		# second_door_final_local_pos_z = second_door.position.z - move_distance if !isOpened else second_door.position.z + move_distance;

func switch_open():
	if (isMoving):
		var first_door_start_local_pos_z = first_door.position.z
		var second_door_start_local_pos_z = second_door.position.z
		var first_door_final_local_pos_z = first_door.position.z + move_distance if !isOpened else first_door.position.z - move_distance;
		var second_door_final_local_pos_z = second_door.position.z - move_distance if !isOpened else second_door.position.z + move_distance;

		var start_time = Time.get_ticks_msec()
		# while (abs(first_door.position.z - first_door_start_local_pos_z) < move_distance/2 - 0.001):
				
		# 	var now = Time.get_ticks_msec()
		# 	var delta = (now - start_time) / 1000.0
		# 	var opened_bool_coeff: = 1 if !isOpened else -1;
			
		# 	first_door.position.z = first_door_start_local_pos_z + opened_bool_coeff * move_distance * sin(delta * (PI) / move_duration) 
		# 	second_door.position.z = second_door_start_local_pos_z + opened_bool_coeff * move_distance * sin(delta * (PI) / move_duration) * -1
		# 	await get_tree().process_frame
		while(abs(first_door.position.z - first_door_final_local_pos_z) > 0.01):
			var now = Time.get_ticks_msec()
			var delta = (now - start_time) / 1000.0
			var opened_bool_coeff: = 1 if !isOpened else -1;
			
			first_door.position.z = first_door_start_local_pos_z + opened_bool_coeff * move_distance * sin(0.5 * delta * (PI) / move_duration) 
			second_door.position.z = second_door_start_local_pos_z + opened_bool_coeff * -1 * move_distance * sin(0.5 * delta * (PI) / move_duration)
			await get_tree().process_frame

		isOpened = !isOpened
		isMoving = false
		if (nav_region != null):
			nav_region.bake_navigation_mesh(true)

# func _process(delta: float) -> void:
# 	if (isDisposable && interacted): return
# 	if (isMoving):
# 		if(abs(first_door.position.z - first_door_final_local_pos_z) > 0.01):
# 			time += delta;
# 			var opened_bool_coeff: = 1 if !isOpened else -1;
			
# 			first_door.position.z = first_door_start_local_pos_z + opened_bool_coeff * move_distance * sin((0.5 * time * (PI)) / move_duration) 
# 			second_door.position.z = second_door_start_local_pos_z + opened_bool_coeff * -1 * move_distance * sin((0.5 * time * (PI)) / move_duration)
# 			return;

# 		first_door.position.z = first_door_final_local_pos_z;
# 		second_door.position.z = second_door_final_local_pos_z;

# 		isOpened = !isOpened
# 		isMoving = false
# 		if (nav_region != null):
# 			nav_region.bake_navigation_mesh(true)

func close_door():
	if(!isOpened): return;
	isMoving = true;
	# first_door_start_local_pos_z = first_door.position.z
	# second_door_start_local_pos_z = second_door.position.z
	# first_door_final_local_pos_z = first_door.position.z + move_distance if !isOpened else first_door.position.z - move_distance;
	# second_door_final_local_pos_z = second_door.position.z - move_distance if !isOpened else second_door.position.z + move_distance;
	# time = 0;
	switch_open()
