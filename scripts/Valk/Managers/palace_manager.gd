class_name PalaceManager
extends Node

static var instance: PalaceManager;

var gathered_clues: Array[Clue] = [null];
var first_free_index: int = 0;

@export var thought_paths: Array[ThoughtPath] = [null];

var gathered_notes: Array[Note] = [null];
var first_note_free_index: int = 0;


func _ready() -> void:
	if(instance == null):
		instance = self;
		for i in range(0, thought_paths.size()):
			thought_paths[i].initialize();
	else:
		print("More than one PalaceManager exists!!!");
	pass 

func get_note_index(note: Note):
	for i in range(0, first_note_free_index):
		if(gathered_notes[i] == note):
			return i;
	return -1;


func get_thought_path_index(thought_path: ThoughtPath):
	for i in range(0, thought_paths.size()):
		if(thought_paths[i] == thought_path):
			return i;
	return -1;

func is_note_gathered(note: Note):
	for i in range(0, first_note_free_index):
		if(gathered_notes[i] == note):
			return true;
	return false;

func gather_note(new_note: Note):
	if(new_note == null): return;
	if(!is_note_gathered(new_note)):
		gathered_notes[first_note_free_index] = new_note;
		first_note_free_index += 1;
		if(gathered_notes.size() == first_note_free_index):
			gathered_notes.resize(first_note_free_index * 2);
	UIManager.instance.choose_note_ui(new_note);
	UIManager.instance.show_notes_ui();

func add_gathered_clue(new_clue: Clue):
	if(new_clue == null): return;
	# print(new_clue.name);
	gathered_clues[first_free_index] = new_clue;
	first_free_index += 1;
	# print(first_free_index);
	if(gathered_clues.size() == first_free_index):
		gathered_clues.resize(first_free_index * 2);
	UIManager.instance.show_added_thought_notif(new_clue, 5.0);
	if(is_first_thought(new_clue)): create_thought(new_clue);
	# if(new_clue.automatically_unlock_path): create_thought(new_clue);
	EventBus.clue_gathered.emit(new_clue);

func remove_gathered_clue(clue_to_remove: Clue):
	for i in range(0, gathered_clues.size()):
		if(gathered_clues[i].name == clue_to_remove.name):
			if(gathered_clues[i].description == clue_to_remove.description):
				gathered_clues.remove_at(i);
				if(first_free_index > 0):
					first_free_index -= 1;
				return;

func remove_all_clues():
	gathered_clues = [null];
	first_free_index = 0;

func is_clue_realized(checked_clue: Clue):
	for i in range(0, thought_paths.size()):
		for j in range(0, thought_paths[i].required_clues.size()):
			if(thought_paths[i].required_clues[j] == checked_clue): 
				return thought_paths[i].is_clue_realized[j];
	return false;

func is_correct_thought(checked_clue: Clue, chosen_clue: Clue) -> bool:
	for i in range(0, thought_paths.size()):
		for j in range(0, thought_paths[i].required_clues.size()):
			if(thought_paths[i].required_clues[j] == checked_clue && thought_paths[i].is_clue_realized[j]):
				var index: int = j + 1;
				for k in range(0, index):
					if(!thought_paths[i].is_clue_realized[k] && thought_paths[i].required_for_realization[k]): return false;
				if(index >= thought_paths[i].required_clues.size() || thought_paths[i].is_clue_realized[index]): return false;
				if(thought_paths[i].required_clues[index] == chosen_clue): return true;
	return false;

func is_first_thought(chosen_clue: Clue) -> bool:
	for i in range(0, thought_paths.size()):
		if(thought_paths[i].required_clues[0] == chosen_clue): return true;
	return false;

# func does_automatically_unlock(clue: Clue) -> bool:
# 	for i in range(0, thought_paths.size()):
# 		for j in range(0, thought_paths[i].required_clues.size()):
# 			if(thought_paths[i].required_clues[j] == clue): 
# 				return thought_paths[i].does_automatically_unlock[j];
# 	return false;

func create_thought(chosen_clue: Clue):
	for i in range(0, thought_paths.size()):
		for j in range(0, thought_paths[i].required_clues.size()):
			if(thought_paths[i].required_clues[j] == chosen_clue):
				thought_paths[i].is_clue_realized[j] = true;
				match chosen_clue.clue_trigger:
					Clue.triggers.None:
						print("no trigger function");
					Clue.triggers.SomethingUnlocks:
						trigger_test();

				# if(has_method(chosen_clue.trigger_method_name)):
				# 	call(chosen_clue.trigger_method_name);
				# elif(chosen_clue.trigger_method_name == ""):
				# 	print("trigger method empty for " + chosen_clue.name);
				# else:
				# 	print("haven't found a trigger method for " + chosen_clue.name);
				# if(!thought_paths[i].does_automatically_unlock[j]):
				remove_gathered_clue(chosen_clue);
				# var index: int = j + 1;
				# if(index < thought_paths[i].does_automatically_unlock.size()):
				# 	if(thought_paths[i].does_automatically_unlock[index]): 
				# 		create_thought(thought_paths[i].required_clues[index]);
				for k in range(0, chosen_clue.clues_to_gather.size()):
					add_gathered_clue(chosen_clue.clues_to_gather[k]);
					if(chosen_clue.does_automatically_unlock[k]): create_thought(chosen_clue.clues_to_gather[k]);
				return;
	print("Error while creating a thought, probably the clue was not found in thought paths");

func trigger_test() -> void:
	print("test");
