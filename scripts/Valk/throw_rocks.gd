extends Node

@export var throw_position: Node3D;
@export var throw_force: float;
@export var rock: Resource;
@export var y: float;
@onready var camera: Camera3D = $"../Head/Camera3D"

@export var throw_angle = 10.0; # from looking direction to up
@export var torque_force = 100.0;
@export var aim_range = 20.0;
var vel_vector: Vector3;
const g = 9.8;

func _physics_process(delta: float) -> void:
	if(Input.is_action_just_pressed("use_item_2")):
		var rock_instance : RigidBody3D = rock.instantiate() as RigidBody3D;
		add_child(rock_instance);
		rock_instance.global_position = throw_position.global_position;
		throw_rock(rock_instance);
	
func throw_rock(rock: RigidBody3D):

	var start: Vector3 = throw_position.global_position
	var target: Vector3 = get_aim_target()

	var delta: Vector3 = target - start

	var horizontal: Vector2 = Vector2(delta.x, delta.z)
	var R: float = horizontal.length()
	var y: float = delta.y
	var alpha: float = camera.global_rotation.x + deg_to_rad(throw_angle) * pow(cos(camera.global_rotation.x/2),3);

	var cos_a = cos(alpha)
	var tan_a = tan(alpha)

	var denom = 2.0 * cos_a * cos_a * (R * tan_a - y)

	if denom <= 0:
		print("No ballistic solution")
		return

	var v0_sq = g * R * R / denom
	var v0 = sqrt(v0_sq)

	# kierunek poziomy do celu
	var dir = Vector3(horizontal.x, 0, horizontal.y).normalized()

	var velocity = dir * (v0 * cos_a)
	velocity.y = v0 * sin(alpha)

	rock.apply_central_impulse(velocity * rock.mass)
	
func get_aim_target() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)

	var ray_end = ray_origin + ray_dir * aim_range

	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	#query.collision_mask = (1 << 0) | (1 << 2)
	
	var result = space_state.intersect_ray(query)
	var pos_2;
	if (result):
		pos_2 = result.position
	else: pos_2 = ray_end
	return pos_2

#Valk'a
func _old_throw_rock(delta: float) -> void:
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
