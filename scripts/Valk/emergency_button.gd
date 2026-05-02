extends StaticBody3D

@export var linked_door: DoubleDoor = null;
@export var emergency_open_timer: float = 5.0;

var is_unlocking: bool = false;

func player_interact():
	if(linked_door == null):
		print("DOOR NOT CONNECTED TO EMERGENCY BUTTON");
		return;
		
	is_unlocking = true;
	linked_door.switch_open();
	await get_tree().create_timer(emergency_open_timer).timeout;
	linked_door.switch_open();
	await get_tree().create_timer(linked_door.move_duration).timeout;
	is_unlocking = false;
