class_name SaveManager
extends Node

static var instance: SaveManager;
@onready var player: PlayerController = $"../Player"

@export var last_checkpoint: Save;

func _ready() -> void:
	if(instance == null):
		instance = self;  
		# FileAccess.open("user://saves/checkpoint.dat", FileAccess.READ);
		# print(OS.get_data_dir());
		# last_checkpoint = FileAccess.get_as_var()
	else:
		print("More than one GameManager exists!!!");
		queue_free();

func save_checkpoint() -> void:
	# last_checkpoint.last_player_pos = player.global_position;
	# last_checkpoint.last_serum_level = PsycheManager.instance.serum_level;
	# last_checkpoint.last_fog_fade_level = PsycheManager.instance.fog_fade_level;
	# last_checkpoint.last_invisibility_timer = PsycheManager.instance.invisibility_timer;

	# last_checkpoint.is_serum_taken.clear();
	# var all_serums = get_tree().get_nodes_in_group("Serum");
	# for i in range(0, all_serums.size()):
	# 	var pickup_item: PickupItem = all_serums[i];
	# 	pickup_item.set_meta("id", i);
	# 	last_checkpoint.is_serum_taken[i] = pickup_item.is_disabled;
	
	# last_checkpoint.is_rock_taken.clear();
	# var all_rocks = get_tree().get_nodes_in_group("Rock");
	# for i in range(0, all_rocks.size()):
	# 	var pickup_item: PickupItem = all_rocks[i];
	# 	pickup_item.set_meta("id", i);
	# 	last_checkpoint.is_rock_taken[i] = pickup_item.is_disabled;

	# last_checkpoint.is_clue_taken.clear();
	# var all_clues = get_tree().get_nodes_in_group("Clue");
	# for i in range(0, all_clues.size()):
	# 	var scene_clue: SceneClue = all_clues[i];
	# 	scene_clue.set_meta("id", i);
	# 	last_checkpoint.is_clue_taken[i] = scene_clue.is_disabled;

	# last_checkpoint.last_thought_paths.resize(PalaceManager.instance.thought_paths.size());
	# for i in range(0, PalaceManager.instance.thought_paths.size()):
	# 	last_checkpoint.last_thought_paths[i] = ThoughtPath.new();
	# 	var length: int = PalaceManager.instance.thought_paths[i].is_clue_realized.size();
	# 	last_checkpoint.last_thought_paths[i].is_clue_realized.resize(length);
	# 	for j in range(0, length):
	# 		last_checkpoint.last_thought_paths[i].is_clue_realized[j] = PalaceManager.instance.thought_paths[i].is_clue_realized[j];

	# last_checkpoint.last_gathered_clues.resize(PalaceManager.instance.first_free_index);
	# for i in range(0, PalaceManager.instance.first_free_index):
	# 	last_checkpoint.last_gathered_clues[i] = PalaceManager.instance.gathered_clues[i];

	# last_checkpoint.last_shell_positions.clear();
	# var all_shells = get_tree().get_nodes_in_group("Shell");
	# last_checkpoint.last_shell_positions.resize(all_shells.size());
	# for i in range(0, all_shells.size()):
	# 	var node_3d: Node3D = all_shells[i];
	# 	# node_3d.set_meta("id", i);
	# 	last_checkpoint.last_shell_positions[i] = node_3d.global_position;

	# last_checkpoint.is_player_crouching = player.is_crouching;
	# last_checkpoint.checkpoint_exists = true;
	save_into_resource(last_checkpoint);
	# DirAccess.make_dir_absolute("user://saves/");
	# var file = FileAccess.open("user://saves/checkpoint.dat", FileAccess.WRITE);
	# print(FileAccess.get_open_error());
	# file.store_var(last_checkpoint., true);
	print("saved");

func save_into_resource(save_resource: Save) -> void:
	save_resource.last_player_pos = player.global_position;
	save_resource.last_player_rot = player.global_rotation;
	save_resource.last_serum_level = PsycheManager.instance.serum_level;
	save_resource.last_fog_fade_level = PsycheManager.instance.fog_fade_level;
	save_resource.last_invisibility_timer = PsycheManager.instance.invisibility_timer;

	save_resource.is_serum_taken.clear();
	var all_serums = get_tree().get_nodes_in_group("Serum");
	for i in range(0, all_serums.size()):
		var pickup_item: PickupItem = all_serums[i];
		pickup_item.set_meta("id", i);
		save_resource.is_serum_taken[i] = pickup_item.is_disabled;
	
	save_resource.is_rock_taken.clear();
	var all_rocks = get_tree().get_nodes_in_group("Rock");
	for i in range(0, all_rocks.size()):
		var pickup_item: PickupItem = all_rocks[i];
		pickup_item.set_meta("id", i);
		save_resource.is_rock_taken[i] = pickup_item.is_disabled;

	save_resource.is_clue_taken.clear();
	var all_clues = get_tree().get_nodes_in_group("Clue");
	for i in range(0, all_clues.size()):
		var scene_clue: SceneClue = all_clues[i];
		scene_clue.set_meta("id", i);
		save_resource.is_clue_taken[i] = scene_clue.is_disabled;

	save_resource.last_thought_paths.resize(PalaceManager.instance.thought_paths.size());
	for i in range(0, PalaceManager.instance.thought_paths.size()):
		save_resource.last_thought_paths[i] = ThoughtPath.new();
		var length: int = PalaceManager.instance.thought_paths[i].is_clue_realized.size();
		save_resource.last_thought_paths[i].is_clue_realized.resize(length);
		for j in range(0, length):
			save_resource.last_thought_paths[i].is_clue_realized[j] = PalaceManager.instance.thought_paths[i].is_clue_realized[j];

	save_resource.last_gathered_clues.resize(PalaceManager.instance.first_free_index);
	for i in range(0, PalaceManager.instance.first_free_index):
		save_resource.last_gathered_clues[i] = PalaceManager.instance.gathered_clues[i];

	save_resource.last_shell_positions.clear();
	save_resource.last_shell_rotations.clear();
	var all_shells = get_tree().get_nodes_in_group("Shell");
	save_resource.last_shell_positions.resize(all_shells.size());
	save_resource.last_shell_rotations.resize(all_shells.size());
	for i in range(0, all_shells.size()):
		var node_3d: Node3D = all_shells[i];
		# node_3d.set_meta("id", i);
		save_resource.last_shell_positions[i] = node_3d.global_position;
		save_resource.last_shell_rotations[i] = node_3d.global_rotation;

	save_resource.is_player_crouching = player.is_crouching;
	save_resource.serum_count = InventoryManager.instance.itemCount[ITEM_TYPE.SERUM];
	save_resource.rock_count = InventoryManager.instance.itemCount[ITEM_TYPE.ROCK];
	save_resource.checkpoint_exists = true;

func load_from_resource(load_resource: Save) -> void:
	if(!load_resource.checkpoint_exists): return;
	player.global_position = load_resource.last_player_pos;
	player.global_rotation = load_resource.last_player_rot;
	PsycheManager.instance.serum_level = load_resource.last_serum_level;
	PsycheManager.instance.fog_fade_level = load_resource.last_fog_fade_level;
	PsycheManager.instance.invisibility_timer = load_resource.last_invisibility_timer;
	PsycheManager.instance.restart_timers();

	var all_serums = get_tree().get_nodes_in_group("Serum");
	for i in range(0, all_serums.size()):
		var pickup_item: PickupItem = all_serums[i];
		pickup_item.set_meta("id", i);
	for pickup_item_id in load_resource.is_serum_taken:
		if(load_resource.is_serum_taken[pickup_item_id]):
			for i in range(0, all_serums.size()):
				var pickup_item: PickupItem = all_serums[i];
				if(pickup_item.get_meta("id") == pickup_item_id):
					pickup_item.disable();

	var all_rocks = get_tree().get_nodes_in_group("Rock");
	for i in range(0, all_rocks.size()):
		var pickup_item: PickupItem = all_rocks[i];
		pickup_item.set_meta("id", i);
	for pickup_item_id in load_resource.is_rock_taken:
		if(load_resource.is_rock_taken[pickup_item_id]):
			for i in range(0, all_rocks.size()):
				var pickup_item: PickupItem = all_rocks[i];
				if(pickup_item.get_meta("id") == pickup_item_id):
					pickup_item.disable();

	var all_clues = get_tree().get_nodes_in_group("Clue");
	for i in range(0, all_clues.size()):
		var scene_clue: SceneClue = all_clues[i];
		scene_clue.set_meta("id", i);
	for scene_clue_id in load_resource.is_clue_taken:
		if(load_resource.is_clue_taken[scene_clue_id]):
			for i in range(0, all_clues.size()):
				var scene_clue: SceneClue = all_clues[i];
				if(scene_clue.get_meta("id") == scene_clue_id):
					scene_clue.disable();

	for i in range(0, PalaceManager.instance.thought_paths.size()):
		var length: int = PalaceManager.instance.thought_paths[i].is_clue_realized.size();
		for j in range(0, length):
			PalaceManager.instance.thought_paths[i].is_clue_realized[j] = load_resource.last_thought_paths[i].is_clue_realized[j];

	PalaceManager.instance.remove_all_clues();
	for i in range(0, load_resource.last_gathered_clues.size()): # musi być last_checkpoint.last_gathered_clues.size() a nie size
		PalaceManager.instance.add_gathered_clue( load_resource.last_gathered_clues[i]);

	var all_shells = get_tree().get_nodes_in_group("Shell");
	for i in range(0, load_resource.last_shell_positions.size()):
		all_shells[i].global_position = load_resource.last_shell_positions[i];
		all_shells[i].global_rotation = load_resource.last_shell_rotations[i];

	if(load_resource.is_player_crouching):
		player.crouch();
	
	InventoryManager.instance.clear_item(ITEM_TYPE.SERUM);
	InventoryManager.instance.clear_item(ITEM_TYPE.ROCK);
	InventoryManager.instance.add_item(ITEM_TYPE.SERUM, load_resource.serum_count);
	InventoryManager.instance.add_item(ITEM_TYPE.ROCK, load_resource.rock_count);

	print(load_resource.last_serum_level);

func load_last_checkpoint() -> void:
	# print(last_checkpoint.checkpoint_exists);
	# if(!last_checkpoint.checkpoint_exists): return;
	# player.global_position = last_checkpoint.last_player_pos;
	# PsycheManager.instance.serum_level = last_checkpoint.last_serum_level;
	# PsycheManager.instance.fog_fade_level = last_checkpoint.last_fog_fade_level;
	# PsycheManager.instance.invisibility_timer = last_checkpoint.last_invisibility_timer;
	# PsycheManager.instance.restart_timers();

	# var all_serums = get_tree().get_nodes_in_group("Serum");
	# for i in range(0, all_serums.size()):
	# 	var pickup_item: PickupItem = all_serums[i];
	# 	pickup_item.set_meta("id", i);
	# for pickup_item_id in last_checkpoint.is_serum_taken:
	# 	if(last_checkpoint.is_serum_taken[pickup_item_id]):
	# 		for i in range(0, all_serums.size()):
	# 			var pickup_item: PickupItem = all_serums[i];
	# 			if(pickup_item.get_meta("id") == pickup_item_id):
	# 				pickup_item.disable();

	# var all_rocks = get_tree().get_nodes_in_group("Rock");
	# for i in range(0, all_rocks.size()):
	# 	var pickup_item: PickupItem = all_rocks[i];
	# 	pickup_item.set_meta("id", i);
	# for pickup_item_id in last_checkpoint.is_rock_taken:
	# 	if(last_checkpoint.is_rock_taken[pickup_item_id]):
	# 		for i in range(0, all_rocks.size()):
	# 			var pickup_item: PickupItem = all_rocks[i];
	# 			if(pickup_item.get_meta("id") == pickup_item_id):
	# 				pickup_item.disable();

	# var all_clues = get_tree().get_nodes_in_group("Clue");
	# for i in range(0, all_clues.size()):
	# 	var scene_clue: SceneClue = all_clues[i];
	# 	scene_clue.set_meta("id", i);
	# for scene_clue_id in last_checkpoint.is_clue_taken:
	# 	if(last_checkpoint.is_clue_taken[scene_clue_id]):
	# 		for i in range(0, all_clues.size()):
	# 			var scene_clue: SceneClue = all_clues[i];
	# 			if(scene_clue.get_meta("id") == scene_clue_id):
	# 				scene_clue.disable();

	# for i in range(0, PalaceManager.instance.thought_paths.size()):
	# 	var length: int = PalaceManager.instance.thought_paths[i].is_clue_realized.size();
	# 	for j in range(0, length):
	# 		PalaceManager.instance.thought_paths[i].is_clue_realized[j] = last_checkpoint.last_thought_paths[i].is_clue_realized[j];

	# PalaceManager.instance.remove_all_clues();
	# for i in range(0, last_checkpoint.last_gathered_clues.size()): # musi być last_checkpoint.last_gathered_clues.size() a nie size
	# 	PalaceManager.instance.add_gathered_clue( last_checkpoint.last_gathered_clues[i]);

	# var all_shells = get_tree().get_nodes_in_group("Shell");
	# for i in range(0, last_checkpoint.last_shell_positions.size()):
	# 	all_shells[i].global_position = last_checkpoint.last_shell_positions[i];

	# if(last_checkpoint.is_player_crouching):
	# 	player.crouch();

	# print(last_checkpoint.last_serum_level);
	load_from_resource(last_checkpoint);
	print("restored");
