class_name SceneClue
extends StaticBody3D

@export var clue_to_gather: Clue
@export var disappear_if_duplicate_detected: bool = false;

func _ready() -> void:
	add_to_group("Clue");
	EventBus.clue_gathered.connect(disappear_if_duplicate);

func disappear_if_duplicate(clue: Clue):
	if(!disappear_if_duplicate_detected): return;
	if(clue == clue_to_gather): queue_free();
	
func player_interact() -> void:
	PalaceManager.instance.add_gathered_clue(clue_to_gather);
	queue_free();
