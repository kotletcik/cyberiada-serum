extends Node3D
class_name Behaviour

@export var state_machine: State_machine
@export_group("general")
@export var player_sight_fov: float = 180
@export var player_sight_range: float = 2
@export var attack_range: float = 1.0
@export var walls_layer: int

var timer: float
var stateIsActive: bool = true

@export var disable_fov_check: bool = false;

var dot: float = 0;

func is_player_in_sight() -> bool:
	if (disable_fov_check): return false;
	if (state_machine == null): return false
	var player_in_local: Vector3 = GameManager.instance.player.global_position - self.global_position;
	var direction = player_in_local.normalized();
	dot = self.global_basis.z.dot(direction);
	
	if(dot < 1-(player_sight_fov/180)): 
		if (PsycheManager.instance.invisibility_timer > 0): return false;
		var query = PhysicsRayQueryParameters3D.create(global_position, global_position + direction * player_sight_range);
		var space_state = self.get_world_3d().direct_space_state
		var result = space_state.intersect_ray(query);
		if(!result.is_empty()):
			if result["collider"] is CharacterBody3D:
				return true;
	return false;
	
#func is_player_in_sight_2() -> bool:
	#if (disable_fov_check): return false;
	#if (state_machine == null): return false
	#var player_in_local: Vector3 = GameManager.instance.player.global_position - self.global_position;
	#var direction = player_in_local.normalized();
	#dot = self.global_basis.z.dot(direction);
	#
	#if(dot > (cos(deg_to_rad(player_sight_fov)/2))): 
		#if (PsycheManager.instance.invisibility_timer > 0): return false;
		#var query = PhysicsRayQueryParameters3D.create(global_position, global_position + direction * player_sight_range);
		## query.collision_mask itd
		#var space_state = self.get_world_3d().direct_space_state
		#var result = space_state.intersect_ray(query);
		#if(!result.is_empty()):
			#if result["collider"].get_parent() == GameManager.instance.player:
				#return true;
	#return false;
