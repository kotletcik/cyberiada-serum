class_name SceneClue
extends StaticBody3D

@export var clue_to_gather: Clue
@export var disappear_if_duplicate_detected: bool = false;

var is_disabled: bool = false;

func _ready() -> void:
	add_to_group("Clue");
	EventBus.clue_gathered.connect(disappear_if_duplicate);
	enable();

func disappear_if_duplicate(clue: Clue):
	if(!disappear_if_duplicate_detected): return;
	if(clue == clue_to_gather): disable();
	
func player_interact() -> void:
	PalaceManager.instance.add_gathered_clue(clue_to_gather);
	disable();

func disable() -> void:
	visible = false;
	get_node("CollisionShape3D").disabled = true;
	is_disabled = true;

func enable() -> void:
	visible = true;
	get_node("CollisionShape3D").disabled = false;
	is_disabled = false;
