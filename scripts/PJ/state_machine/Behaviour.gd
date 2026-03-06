extends Node3D
class_name Behaviour

@export var state_machine: State_machine
@export_group("general")
@export var player_sight_fov: float = 180
@export var player_sight_range: float = 2
@export var attack_range: float = 1.0
var timer: float
var stateIsActive: bool = true
@export var walls_layer: int

var fov_gizmo: MeshInstance3D

@export var disable_fov_check: bool = false;

@export var dot: float = 0;


func is_player_in_sight() -> bool:
	if (disable_fov_check): return false;
	if (state_machine == null): return false
	var player_in_local: Vector3 = GameManager.instance.player.global_position - self.global_position;
	var direction = player_in_local.normalized();
	dot = self.global_basis.z.dot(direction);
	
	if(dot < 1-(player_sight_fov/180)): 
		if (PsycheManager.instance.invisibility_timer > 0): return false;
		var query = PhysicsRayQueryParameters3D.create(global_position, global_position + direction * player_sight_range);
		# query.collision_mask itd
		var space_state = self.get_world_3d().direct_space_state
		var result = space_state.intersect_ray(query);
		if(!result.is_empty()):
			if result["collider"] is CharacterBody3D:
				return true;
	return false;
	
# var col = raycast_xz_fov_gizmo(
# 	state_machine.mob.global_position, 
# 	state_machine.mob.transform.basis.z * (-1), 
# 	player_sight_range, 
# 	player_sight_fov, 
# 	GameManager.instance.player.collision_layer | int(pow(2, walls_layer-1)))
# if col is CharacterBody3D:
# 	return true;
# else: return false
# #var isPlayerInRange: bool = (player_in_local).length() < player_sight_range;
# #return isPlayerInRange

# origin: punkt startowy promienia
# forward: kierunek „przodu” (Vector3)
# max_distance: maksymalna długość raycastu
# fov_deg: ograniczenie kąta widzenia w stopniach
# collision_mask: maska warstw kolizji
func raycast_xz_fov(origin: Vector3, forward: Vector3, max_distance: float = 100.0, fov_deg: float = 90.0, collision_mask: int = 0xFFFFFFFF) -> Node3D:
	var space_state = state_machine.mob.get_world_3d().direct_space_state
	
	# Kierunek w XZ
	var forward_xz = Vector3(forward.x, 0, forward.z).normalized()
	if forward_xz == Vector3.ZERO:
		return null
	
	# Tworzymy parametry raycastu
	var params1 = PhysicsRayQueryParameters3D.new()
	params1.from = origin
	params1.to = origin + forward_xz * max_distance
	params1.exclude = []
	params1.collision_mask = collision_mask
	params1.collide_with_bodies = true
	params1.collide_with_areas = true
	
	var params2 = PhysicsRayQueryParameters3D.new()
	params2.from = origin
	params2.to = (origin + forward_xz * max_distance).rotated(Vector3.UP, deg_to_rad(fov_deg))
	params2.exclude = []
	params2.collision_mask = collision_mask
	params2.collide_with_bodies = true
	params2.collide_with_areas = true
	
	var params3 = PhysicsRayQueryParameters3D.new()
	params3.from = origin
	params3.to = (origin + forward_xz * max_distance).rotated(Vector3.UP, deg_to_rad(-fov_deg))
	params3.exclude = []
	params3.collision_mask = collision_mask
	params3.collide_with_bodies = true
	params3.collide_with_areas = true
	
	# Raycast
	var result = space_state.intersect_ray(params1)
	result.merge(space_state.intersect_ray(params2))
	result.merge(space_state.intersect_ray(params3))
	
	if not result:
		return null
	
	var collider = result.collider
	if not collider:
		return null
	else: return collider

func raycast_xz_fov_gizmo(origin: Vector3, forward: Vector3, max_distance: float = 100.0, fov_deg: float = 90.0, collision_mask: int = 0xFFFFFFFF) -> Node3D:
	var space_state = state_machine.mob.get_world_3d().direct_space_state
	
	var forward_xz = Vector3(forward.x, 0, forward.z).normalized()
	if forward_xz == Vector3.ZERO:
		return null
	
	var half_fov = deg_to_rad(fov_deg * 0.5)
	var right_dir = forward_xz.rotated(Vector3.UP, half_fov)
	var left_dir  = forward_xz.rotated(Vector3.UP, -half_fov)
	
	var center_to = origin + forward_xz * max_distance
	var right_to  = origin + right_dir * max_distance
	var left_to   = origin + left_dir * max_distance
	
	# ==== DEBUG DRAW ====
	var debug_mesh_instance = $DebugLines
	var mesh := ImmediateMesh.new()
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	mesh.surface_add_vertex(origin)
	mesh.surface_add_vertex(center_to)
	
	mesh.surface_add_vertex(origin)
	mesh.surface_add_vertex(right_to)
	
	mesh.surface_add_vertex(origin)
	mesh.surface_add_vertex(left_to)
	
	mesh.surface_end()
	debug_mesh_instance.mesh = mesh
	# ====================
	
	var params = PhysicsRayQueryParameters3D.new()
	params.from = origin
	params.to = center_to
	params.collision_mask = collision_mask
	params.collide_with_bodies = true
	params.collide_with_areas = true
	
	
	var params2 = PhysicsRayQueryParameters3D.new()
	params2.from = origin
	params2.to = (origin + forward_xz * max_distance).rotated(Vector3.UP, deg_to_rad(fov_deg / 2 ))
	params2.exclude = []
	params2.collision_mask = collision_mask
	params2.collide_with_bodies = true
	params2.collide_with_areas = true
	
	var params3 = PhysicsRayQueryParameters3D.new()
	params3.from = origin
	params3.to = (origin + forward_xz * max_distance).rotated(Vector3.UP, deg_to_rad(-fov_deg / 2))
	params3.exclude = []
	params3.collision_mask = collision_mask
	params3.collide_with_bodies = true
	params3.collide_with_areas = true
	
	# Raycast
	var result = space_state.intersect_ray(params)
	var result2 = space_state.intersect_ray(params2)
	var result3 = space_state.intersect_ray(params3)
	
	var results = [result, result2, result3]

	for hit in results:
		if hit != {}:
			var col = hit["collider"]
			if col is PhysicsBody3D:
				if col.collision_layer == GameManager.instance.player.collision_layer:
					return col
	return null
