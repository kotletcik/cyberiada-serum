class_name SaveManager
extends Node

static var instance: SaveManager;
@onready var player: PlayerController = $"../Player"

@export var last_checkpoint: Save;

func _ready() -> void:
	if(instance == null):
		instance = self;  
	else:
		print("More than one GameManager exists!!!");
		queue_free();

func save_checkpoint() -> void:
	last_checkpoint.last_player_pos = player.global_position;
	last_checkpoint.last_serum_level = PsycheManager.instance.serum_level;
	last_checkpoint.last_fog_fade_level = PsycheManager.instance.fog_fade_level;
	last_checkpoint.last_invisibility_timer = PsycheManager.instance.invisibility_timer;

	last_checkpoint.is_serum_taken.clear();
	var all_serums = get_tree().get_nodes_in_group("Serum");
	for i in range(0, all_serums.size()):
		var pickup_item: PickupItem = all_serums[i];
		pickup_item.set_meta("id", i);
		last_checkpoint.is_serum_taken[i] = pickup_item.is_disabled;
	
	last_checkpoint.is_rock_taken.clear();
	var all_rocks = get_tree().get_nodes_in_group("Rock");
	for i in range(0, all_rocks.size()):
		var pickup_item: PickupItem = all_rocks[i];
		pickup_item.set_meta("id", i);
		last_checkpoint.is_rock_taken[i] = pickup_item.is_disabled;

	last_checkpoint.is_clue_taken.clear();
	var all_clues = get_tree().get_nodes_in_group("Clue");
	for i in range(0, all_clues.size()):
		var scene_clue: SceneClue = all_clues[i];
		scene_clue.set_meta("id", i);
		last_checkpoint.is_clue_taken[i] = scene_clue.is_disabled;

	last_checkpoint.last_thought_paths.resize(PalaceManager.instance.thought_paths.size());
	for i in range(0, PalaceManager.instance.thought_paths.size()):
		last_checkpoint.last_thought_paths[i] = ThoughtPath.new();
		var length: int = PalaceManager.instance.thought_paths[i].is_clue_realized.size();
		last_checkpoint.last_thought_paths[i].is_clue_realized.resize(length);
		for j in range(0, length):
			last_checkpoint.last_thought_paths[i].is_clue_realized[j] = PalaceManager.instance.thought_paths[i].is_clue_realized[j];

	last_checkpoint.last_gathered_clues.resize(PalaceManager.instance.first_free_index);
	for i in range(0, PalaceManager.instance.first_free_index):
		last_checkpoint.last_gathered_clues[i] = PalaceManager.instance.gathered_clues[i];

	last_checkpoint.is_player_crouching = player.is_crouching;
	last_checkpoint.checkpoint_exists = true;
	print("saved");

func load_last_checkpoint() -> void:
	print(last_checkpoint.checkpoint_exists);
	if(!last_checkpoint.checkpoint_exists): return;
	player.global_position = last_checkpoint.last_player_pos;
	PsycheManager.instance.serum_level = last_checkpoint.last_serum_level;
	PsycheManager.instance.fog_fade_level = last_checkpoint.last_fog_fade_level;
	PsycheManager.instance.invisibility_timer = last_checkpoint.last_invisibility_timer;
	PsycheManager.instance.restart_timers();

	var all_serums = get_tree().get_nodes_in_group("Serum");
	for i in range(0, all_serums.size()):
		var pickup_item: PickupItem = all_serums[i];
		pickup_item.set_meta("id", i);
	for pickup_item_id in last_checkpoint.is_serum_taken:
		if(last_checkpoint.is_serum_taken[pickup_item_id]):
			for i in range(0, all_serums.size()):
				var pickup_item: PickupItem = all_serums[i];
				if(pickup_item.get_meta("id") == pickup_item_id):
					pickup_item.disable();

	var all_rocks = get_tree().get_nodes_in_group("Rock");
	for i in range(0, all_rocks.size()):
		var pickup_item: PickupItem = all_rocks[i];
		pickup_item.set_meta("id", i);
	for pickup_item_id in last_checkpoint.is_rock_taken:
		if(last_checkpoint.is_rock_taken[pickup_item_id]):
			for i in range(0, all_rocks.size()):
				var pickup_item: PickupItem = all_rocks[i];
				if(pickup_item.get_meta("id") == pickup_item_id):
					pickup_item.disable();

	var all_clues = get_tree().get_nodes_in_group("Clue");
	for i in range(0, all_clues.size()):
		var scene_clue: SceneClue = all_clues[i];
		scene_clue.set_meta("id", i);
	for scene_clue_id in last_checkpoint.is_clue_taken:
		if(last_checkpoint.is_clue_taken[scene_clue_id]):
			for i in range(0, all_clues.size()):
				var scene_clue: SceneClue = all_clues[i];
				if(scene_clue.get_meta("id") == scene_clue_id):
					scene_clue.disable();

	for i in range(0, PalaceManager.instance.thought_paths.size()):
		var length: int = PalaceManager.instance.thought_paths[i].is_clue_realized.size();
		for j in range(0, length):
			PalaceManager.instance.thought_paths[i].is_clue_realized[j] = last_checkpoint.last_thought_paths[i].is_clue_realized[j];

	PalaceManager.instance.remove_all_clues();
	for i in range(0, last_checkpoint.last_gathered_clues.size()): # musi być last_checkpoint.last_gathered_clues.size() a nie size
		PalaceManager.instance.add_gathered_clue( last_checkpoint.last_gathered_clues[i]);

	if(last_checkpoint.is_player_crouching):
		player.crouch();

	print(last_checkpoint.last_serum_level);
	print("restored");
