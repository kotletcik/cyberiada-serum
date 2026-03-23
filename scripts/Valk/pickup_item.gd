class_name PickupItem
extends StaticBody3D

@export var group_name: String;
@export var event_on_pickup: EventBus.triggers = EventBus.triggers.None;
@export var clue_on_pickup: Clue = null;
@export var does_clue_automatically_unlock: bool = false;
var is_disabled: bool = false;

func _ready() -> void:
	add_to_group(group_name);
	if(group_name == "Serum"):
		PsycheManager.instance.register_serum(self, global_position);


func disable() -> void:
	visible = false;
	get_node("CollisionShape3D").disabled = true;
	is_disabled = true;

func enable() -> void:
	visible = true;
	get_node("CollisionShape3D").disabled = false;
	is_disabled = false;
