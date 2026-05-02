extends Node

@export var lift_to_disable: DoubleDoor;
@export var lift_to_enable: DoubleDoor;

func _ready() -> void:
	EventBus.lift_to_final_level_unlocked.connect(replace);
	lift_to_enable.turn_invisible();
	lift_to_disable.turn_visible();


func replace():
	lift_to_disable.turn_invisible();
	lift_to_enable.turn_visible();
