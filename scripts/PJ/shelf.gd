extends Node3D

var isOpened: bool = false
var isInteracting: bool = false
@export var switch_open_direction = false 
@export var move_distance:= 2.0
@export var open_duration:= 1.0
@onready var nav_region: NavigationRegion3D = get_parent() as NavigationRegion3D

func player_interact():
	if (!isInteracting):
		isInteracting = true
		switch_open()

func switch_open():
	if (isInteracting):
		var start_pos = global_position
		var start_time = Time.get_ticks_msec()
		while ((global_position - start_pos).length() < move_distance - 0.01):
				
			var now = Time.get_ticks_msec()
			var delta = (now - start_time) / 1000.0
			var switch_dir_coeff:= 1
			var opened_bool_coeff: = 1
			if (switch_open_direction): switch_dir_coeff = -1
			if (isOpened): opened_bool_coeff = -1
			
			global_position = start_pos + opened_bool_coeff * switch_dir_coeff * move_distance * sin(delta * (PI) / open_duration) * transform.basis.z 
			await get_tree().process_frame
		isOpened = !isOpened
		isInteracting = false
		if (nav_region != null):
			nav_region.bake_navigation_mesh(true)
