extends Node3D

func _ready() -> void:
	print("ready works");
	SaveManager.instance.load_last_checkpoint();
	get_tree().paused = false;
		
