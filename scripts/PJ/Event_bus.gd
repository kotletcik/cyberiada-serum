extends Node

signal sound_emitted_by_player(sound_pos: Vector3, sound_volume: float)
signal game_restarted
signal level_changed(level: int)
signal shells_disappear
signal shells_appear
signal clue_gathered(clue: Clue)
signal bad_ending()
signal good_ending()
signal final_door_closed()

enum triggers
{
	None,
	BadEnding,
	GoodEnding,
	FinalDoorClosed
}

# func _ready():
# 	get_tree().scene_changed.connect(_on_scene_changed)

# func _on_scene_changed():
# 	print("scene changed");
# 	reset_signal_subscribers()

func reset_signal_subscribers():
	_disconnect_all("sound_emitted_by_player")
	_disconnect_all("game_restarted")
	_disconnect_all("level_changed")
	_disconnect_all("shells_disappear")
	_disconnect_all("shells_appear")
	_disconnect_all("clue_gathered")
	_disconnect_all("bad_ending")
	_disconnect_all("good_ending")
	_disconnect_all("final_door_closed")

func _disconnect_all(signal_name: String):
	var connections = get_signal_connection_list(signal_name)
	for c in connections:
		if(is_connected(signal_name, c.callable)):
			disconnect(signal_name, c.callable)

func call_event(trigger: triggers):
	match trigger:
		triggers.BadEnding:
			bad_ending.emit();
		triggers.GoodEnding:
			good_ending.emit();
		triggers.FinalDoorClosed:
			final_door_closed.emit();
		triggers.None:
			return;
	
	
