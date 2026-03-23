extends Area3D

@export var enable_trigger: bool = true;
@export var repeatable: bool = false;
@export var trigger_clue: Clue = null;
@export var does_clue_automatically_unlock: bool = false;
var trigger_destroyed: bool = false;

func _on_body_entered(body) -> void:
	if(!enable_trigger || trigger_destroyed): return;
	print(body.name);
	if(body.name == "Player"):
		PalaceManager.instance.add_gathered_clue(trigger_clue);
		if(does_clue_automatically_unlock):
				PalaceManager.instance.create_thought(trigger_clue);
		if(!repeatable): trigger_destroyed = true;
