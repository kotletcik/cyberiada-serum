class_name PalaceManager
extends Node

static var instance: PalaceManager;

var gathered_clues: Array[Clue] = [null];
var first_free_index: int = 0;

@export var thought_paths: Array[ThoughtPath] = [null];



func _ready() -> void:
	if(instance == null):
		instance = self;
	else:
		print("More than one PalaceManager exists!!!");
	pass 

func add_gathered_clue(new_clue: Clue):
	print(new_clue.name);
	gathered_clues[first_free_index] = new_clue;
	first_free_index += 1;
	print(first_free_index);
	if(gathered_clues.size() == first_free_index):
		gathered_clues.resize(first_free_index * 2);
	UIManager.instance.show_added_thought_notif(new_clue, 5.0);
	if(is_first_thought(new_clue)): create_thought(new_clue);
	EventBus.clue_gathered.emit(new_clue);

func remove_gathered_clue(clue_to_remove: Clue):
	for i in range(0, gathered_clues.size()):
		if(gathered_clues[i].name == clue_to_remove.name):
			if(gathered_clues[i].description == clue_to_remove.description):
				gathered_clues.remove_at(i);
				if(first_free_index > 0):
					first_free_index -= 1;
				return;

func is_correct_thought(checked_clue: Clue, chosen_clue: Clue) -> bool:
	for i in range(0, thought_paths.size()):
		for j in range(0, thought_paths[i].required_clues.size()):
			if(thought_paths[i].required_clues[j] == checked_clue && thought_paths[i].is_clue_realized[j]):
				var index: int = j + 1;
				for k in range(0, index):
					if(!thought_paths[i].is_clue_realized[k]): return false;
				if(index >= thought_paths[i].required_clues.size() || thought_paths[i].is_clue_realized[index]): return false;
				if(thought_paths[i].required_clues[index] == chosen_clue): return true;
	return false;

func is_first_thought(chosen_clue: Clue) -> bool:
	for i in range(0, thought_paths.size()):
		if(thought_paths[i].required_clues[0] == chosen_clue): return true;
	return false;

func create_thought(chosen_clue: Clue):
	for i in range(0, thought_paths.size()):
		for j in range(0, thought_paths[i].required_clues.size()):
			if(thought_paths[i].required_clues[j] == chosen_clue):
				thought_paths[i].is_clue_realized[j] = true;
				if(!thought_paths[i].does_automatically_unlock[j]):
					remove_gathered_clue(chosen_clue);
				var index: int = j + 1;
				if(index < thought_paths[i].does_automatically_unlock.size()):
					if(thought_paths[i].does_automatically_unlock[index]): 
						create_thought(thought_paths[i].required_clues[index]);
				return;
	print("Error while creating a thought, probably the clue was not found in thought paths");
