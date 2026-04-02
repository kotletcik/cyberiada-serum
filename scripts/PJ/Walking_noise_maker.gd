extends Node3D
#Odpowiedzialny za triggerowanie enemies od dźwięku poruszania się gracza

@onready var player: PlayerController = $"../"
@export var enemy_layer: int = 4
@export var sound_timer: float = 1.0;

var timer: float;

func _ready() -> void:
	timer = sound_timer;

func _process(delta: float) -> void:
	timer -= delta;
	if(timer < 0):
		if(is_player_making_noise() && PsycheManager.instance.invisibility_timer <= 0):
			EventBus.sound_emitted_by_player.emit(global_position, 0.5);
		timer = sound_timer;
	# var enemy = enemy_heard()
	# if enemy != null:
	# 	if(PsycheManager.instance.invisibility_timer <= 0):
	# 		emit_sound_to_enemy(enemy)

func is_player_making_noise() -> bool:
	if (player != null):
		return abs(player.velocity.x * player.velocity.z) > 0.01 && !player.is_crouching
	else: return false

# func enemy_heard() -> CharacterBody3D:
# 	var enemy = enemy_around()
# 	if player_is_making_noise() && enemy != null:
# 		return enemy
# 	else: return null

# func emit_sound_to_enemy(enemy: CharacterBody3D):
# 	var state_machine: State_machine = enemy.get_node("State_machine") as State_machine
# 	if ( state_machine != null && state_machine.behaviour.has_method("_is_heard_a_sound")):
# 		state_machine.behaviour._is_heard_a_sound(player.position, player.noise)
	
# func enemy_around() -> CharacterBody3D:
# 	if (player != null):
# 		var arr = overlap_circle_xz(player.global_position, player.noise, pow(2, enemy_layer - 1))
# 		if arr.size() > 0:
# 			return arr[0]
# 		else: return null
# 	else : return null

# func overlap_circle_xz(
# 		position: Vector3,
# 		radius: float,
# 		collision_mask: int = 0,
# 		height: float = 0.1
# 	) -> Array:

# 	var space_state = get_world_3d().direct_space_state
	
# 	var shape := CylinderShape3D.new()
# 	shape.radius = radius
# 	shape.height = height
	
# 	var query := PhysicsShapeQueryParameters3D.new()
# 	query.shape = shape
# 	query.transform = Transform3D(Basis(), position)
# 	query.collision_mask = collision_mask
# 	query.collide_with_bodies = true
# 	query.collide_with_areas = true
	
# 	var results = space_state.intersect_shape(query)
	
# 	var colliders: Array = []
# 	var seen := {}
	
# 	for r in results:
# 		var collider = r.collider
# 		if collider and not seen.has(collider):
# 			seen[collider] = true
# 			colliders.append(collider)
	
# 	return colliders
