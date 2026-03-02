extends Node3D

@export var serum: PackedScene 
@export var interaction_range: float = 10.0

func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("Interact")):
		var forward: Vector3 = -get_global_transform().basis.z;
		var query = PhysicsRayQueryParameters3D.create(global_position, global_position + forward * interaction_range);
		var collision = get_world_3d().direct_space_state.intersect_ray(query);
		print(collision)
		# print(collision.is_empty());
		if(!collision.is_empty()):
			var object: Node3D = collision["collider"];
			# print(object.name);
			if(object.is_in_group("Serum")):
				InventoryManager.instance.add_item(ITEM_TYPE.SERUM, 1);
				object.queue_free();
			if(object.is_in_group("Rock")):
				InventoryManager.instance.add_item(ITEM_TYPE.ROCK, 1);
				object.queue_free();
			if(object.has_method("player_interact")):
				object.player_interact();
