class_name GameManager
extends Node

static var instance: GameManager;
@onready var player: PlayerController = $"../Player" #Link na playera w globalnej scenie

var is_game_over: bool = false;

func _ready() -> void:
	if(instance == null):
		instance = self;    
		is_game_over = false;
	else:
		print("More than one GameManager exists!!!");
		queue_free();
		

func game_over() -> void:
	is_game_over = true;
	pause_game();
	UIManager.instance.show_game_over();

func restart_scene() -> void:
	is_game_over = false;
	get_tree().get_root().request_ready();
	get_tree().reload_current_scene();
	
func pause_game() -> void:
	get_tree().paused = true;

func unpause_game() -> void:
	get_tree().paused = false;
