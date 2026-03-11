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
	last_checkpoint.checkpoint_exists = true;

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

	last_checkpoint.is_player_crouching = player.is_crouching;
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

	if(last_checkpoint.is_player_crouching):
		player.crouch();
	print(last_checkpoint.last_serum_level);
	print("restored");
