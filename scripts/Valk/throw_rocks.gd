extends Node

@export var throw_position: Node3D;
@export var throw_force: float;
@export var rock: Resource;
@export var y: float;

const g = 9.8;

func _physics_process(delta: float) -> void:
	if(Input.is_action_just_pressed("use_item_2")):
		# if(!InventoryManager.instance.has_item(ITEM_TYPE.ROCK)): return;
		# InventoryManager.instance.remove_item(ITEM_TYPE.ROCK, 1);
		var forward: Vector3 = -throw_position.get_global_transform().basis.z;
		var query = PhysicsRayQueryParameters3D.create(throw_position.global_position, throw_position.global_position + forward * 100);
		var collision = throw_position.get_world_3d().direct_space_state.intersect_ray(query);
		# print(collision);
		
		var final_throw_force: float = throw_force;
		# if(!collision.is_empty()):
			# print(collision["position"]);
			# throw_position.look_at(collision["position"], throw_position.basis.y, false);
			# print(throw_position.rotation);
		# 	var distance: float = Vector3(throw_position.global_position - collision["position"]).length();
		# 	print(distance);
		# else:
		# 	final_throw_force = throw_force;
		var rock_instance = rock.instantiate();
		rock_instance.player_pos = throw_position.global_position;
		get_tree().get_current_scene().add_child(rock_instance);
		rock_instance.global_position = throw_position.global_position;
		rock_instance.global_rotation = throw_position.global_rotation;
		rock_instance.apply_central_impulse(-rock_instance.basis.z * final_throw_force);
