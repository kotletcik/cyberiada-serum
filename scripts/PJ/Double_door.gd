extends Node3D

var isOpened: bool = false
var isInteracting: bool = false
@export var isDisposable: bool = false
@export var move_distance:= 2.0
@export var open_duration:= 1.0
@export var first_door: Node3D
@export var second_door: Node3D
@export var is_final_door: bool = false;
@onready var nav_region: NavigationRegion3D = get_parent() as NavigationRegion3D
@export var unlock_if_clue_realized: Clue;

var interacted: bool = false;

func _ready() -> void:
	if(is_final_door):
		EventBus.close_final_door.connect(close_door);

func player_interact():
	if(unlock_if_clue_realized != null):
		if(!PalaceManager.instance.is_clue_realized(unlock_if_clue_realized)): return;
	if (!isInteracting):
		isInteracting = true
		if (isDisposable && interacted): return
		else: 
			interacted = true;
			switch_open()

func switch_open():
	if (isInteracting):
		var first_door_start_local_pos_z = first_door.position.z
		var second_door_start_local_pos_z = second_door.position.z
		var start_time = Time.get_ticks_msec()
		while (abs(first_door.position.z - first_door_start_local_pos_z) < move_distance/2 - 0.01):
				
			var now = Time.get_ticks_msec()
			var delta = (now - start_time) / 1000.0
			var opened_bool_coeff: = 1
			if (isOpened): opened_bool_coeff = -1
			
			#global_position = start_pos + opened_bool_coeff * move_distance * sin(delta * (PI) / open_duration) * transform.basis.z / 2
			first_door.position.z = first_door_start_local_pos_z + opened_bool_coeff * move_distance * sin(delta * (PI) / open_duration) 
			second_door.position.z = second_door_start_local_pos_z + opened_bool_coeff * move_distance * sin(delta * (PI) / open_duration) * -1
			await get_tree().process_frame
		isOpened = !isOpened
		isInteracting = false
		if (nav_region != null):
			nav_region.bake_navigation_mesh(true)

func close_door():
	if(!isOpened): return;
	isInteracting = true;
	switch_open();
