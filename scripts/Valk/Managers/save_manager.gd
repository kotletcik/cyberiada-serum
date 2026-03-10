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
	print("saved");

func load_last_checkpoint() -> void:
	print(last_checkpoint.checkpoint_exists);
	if(!last_checkpoint.checkpoint_exists): return;
	player.global_position = last_checkpoint.last_player_pos;
	PsycheManager.instance.serum_level = last_checkpoint.last_serum_level;
	PsycheManager.instance.fog_fade_level = last_checkpoint.last_fog_fade_level;
	PsycheManager.instance.invisibility_timer = last_checkpoint.last_invisibility_timer;
	PsycheManager.instance.restart_timers();
	print(last_checkpoint.last_serum_level);
	print("restored");
