class_name GameManager
extends Node

static var instance: GameManager;
@onready var player: PlayerController = $"../Player" #Link na playera w globalnej scenie

func _ready() -> void:
	if(instance == null):
		instance = self;    
	else:
		print("More than one GameManager exists!!!");
		queue_free();
		

func restart_scene() -> void:
	get_tree().get_root().request_ready();
	get_tree().reload_current_scene();
