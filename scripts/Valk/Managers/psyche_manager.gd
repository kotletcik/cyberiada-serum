class_name PsycheManager
extends Node

static var instance: PsycheManager;

var serum_level: float;
var fog_fade_level: float;
@export var player: Node3D;

@export var settings: PsycheManagerSettings = null;
@export var mutation: Resource;

@onready var camera: Camera3D = $"../Player/Head/Camera3D";
@onready var vignette_texture: TextureRect = $"../Player/CanvasLayer/TextureRect";
@onready var saturation_texture: TextureRect = $"../Player/CanvasLayer/TextureRect2";
@onready var base_camera_fov: float = camera.fov;
@onready var environment: Environment = camera.environment;


var serum_positions: Array[Vector3] = [Vector3.ZERO];
var serums: Array[Node3D] = [null];

var first_free_index: int = 0;

var invisibility_timer: float = 0;
var invisibility_diming_timer: float = 0;
var invisibility_diming_max_timer: float = 0;
var invisibility_jumpscare_timer: float = 0;

var craving_timer: float;
var overtake_timer: float;
var overtake_dir: Vector3;

var mutation_spawn_timer: float

var ending: float = false;

func register_serum(node: Node3D, pos: Vector3) -> void:
	serums[first_free_index] = node;
	serum_positions[first_free_index] = pos;
	first_free_index += 1;
	if(serums.size() == first_free_index):
		serums.resize(first_free_index * 2);
		serum_positions.resize(first_free_index * 2);

func unregister_serum(node: Node3D) -> void:
	for i in range(0, first_free_index):
		if(serums[i] == node):
			serum_positions.remove_at(i);
			serums.remove_at(i);
			if(first_free_index > 0):
				first_free_index -= 1;
			break;

func _ready() -> void:
	if(instance == null):
		instance = self;
		base_camera_fov = camera.fov;
		environment = camera.environment;
		print("Camera FOV: ", camera.fov);
		environment.fog_density = settings.normal_fog_density;
		camera  = player.get_child(0).get_child(0);
		vignette_texture.material.set_shader_parameter("intensity", 0);
		saturation_texture.material.set_shader_parameter("saturation", settings.normal_saturation);
		serum_level = settings.serum_start_level;
		fog_fade_level = settings.fog_fade_start_level;
		EventBus.close_final_door.connect(bad_ending);
	else:
		print("More than one PsycheManager exists!!!");
	pass 

func bad_ending() -> void:
	ending = true;
	if(serum_level > settings.serum_overdose_level && serum_level < settings.serum_critical_level):
		overtake_timer = 0;
	if(serum_level > settings.serum_critical_level):
		craving_timer = 0;

func find_closest_serum_pos() -> Vector3:
	var min_index: int = -1;
	var min_dist: float;
	var player_pos: Vector3 = camera.global_position;
	for i in range(0, first_free_index):
		var subtracted_vector: Vector3 = serum_positions[i] - player_pos;
		var distance_sqr = subtracted_vector.length_squared();
		if(min_index == -1 || distance_sqr < min_dist):
			min_index = i;
			min_dist = distance_sqr;
	return serum_positions[min_index] if min_index != -1 else Vector3.ZERO;

func find_closest_serum() -> Node3D:
	var min_index: int = -1;
	var min_dist: float;
	var player_pos: Vector3 = camera.global_position;
	for i in range(0, first_free_index):
		var subtracted_vector: Vector3 = serum_positions[i] - player_pos;
		var distance_sqr = subtracted_vector.length_squared();
		if(min_index == -1 || distance_sqr < min_dist):
			min_index = i;
			min_dist = distance_sqr;
	return serums[min_index] if min_index != -1 else null;

func find_closest_serum_with_fov(fov: float) -> Node3D:
	var min_index: int = -1;
	var min_dist: float;
	var player_pos: Vector3 = camera.global_position;
	for i in range(0, first_free_index):
		var subtracted_vector: Vector3 = serum_positions[i] - player_pos;
		var direction = subtracted_vector.normalized();
		var dot: float = -player.global_basis.z.dot(direction);
		if(dot < 1-fov/180): continue;
		var distance_sqr = subtracted_vector.length_squared();
		if(min_index == -1 || distance_sqr < min_dist):
			min_index = i;
			min_dist = distance_sqr;
	return serums[min_index] if min_index != -1 else null;

func _physics_process(delta: float) -> void:
	if(serum_level > settings.serum_overdose_level && serum_level < settings.serum_critical_level):
		overtake_timer -= delta;
		var closest_serum: Node3D = find_closest_serum_with_fov(settings.craving_serum_fov); # vs find_closest_serum()
		if(closest_serum != null): 
			var closest_serum_pos: Vector3 = closest_serum.global_position;
			var distance_sqr = (closest_serum_pos - player.global_position).length_squared();
			if(distance_sqr < settings.craving_serum_take_radius*settings.craving_serum_take_radius):
				pickup_serum(closest_serum);
		if(overtake_timer < 0):
			player.global_translate(overtake_dir * settings.overtake_player_force * delta);
			if(overtake_timer < -settings.overtake_duration):
				overtake_timer = randf_range(settings.min_overtake_timer, settings.max_overtake_timer);
				overtake_dir = Vector3(randf_range(-1, 1), 0 , randf_range(-1, 1)).normalized();

	if(serum_level > settings.serum_critical_level):
		# print("works");
		print(craving_timer);
		craving_timer -= delta;
		if(craving_timer < 0):
			var closest_serum: Node3D = find_closest_serum_with_fov(settings.craving_serum_fov); # vs find_closest_serum()
			if(closest_serum == null): return;
			var closest_serum_pos: Vector3 = closest_serum.global_position;
			var direction: Vector3 = (closest_serum_pos - player.global_position).normalized();
			# var dot: float = -player.global_basis.z.dot(direction);
			# if(dot < 1-craving_serum_fov/180): dot = 0;
			player.global_translate(direction * settings.craving_player_force * delta);

			var distance_sqr = (closest_serum_pos - player.global_position).length_squared();
			if(distance_sqr < settings.craving_serum_take_radius*settings.craving_serum_take_radius):
				pickup_serum(closest_serum);
			if(craving_timer <= -settings.craving_duration):
				craving_timer = randf_range(settings.min_craving_timer, settings.max_craving_timer);


func pickup_serum(serum: Node3D) -> void:
		unregister_serum(serum);
		var pickup_item = serum as PickupItem;
		EventBus.call_event(pickup_item.event_on_pickup);
		if(pickup_item.event_on_pickup == EventBus.triggers.BadEnding): serum.queue_free(); return;
		PalaceManager.instance.add_gathered_clue(pickup_item.clue_on_pickup);
		if(pickup_item.does_clue_automatically_unlock):
			PalaceManager.instance.create_thought(pickup_item.clue_on_pickup);
		serum.queue_free();
		take_serum();	

func _process(delta: float) -> void:
	serum_level -= settings.serum_drop_rate * delta;
	# print(serum_level);
	if(serum_level < 0): serum_level = 0;
	if(invisibility_timer > 0):
		invisibility_timer -= delta;

		if(invisibility_diming_timer > 0):
			invisibility_diming_timer -= delta;
			if(invisibility_diming_timer < 0):
				invisibility_jumpscare_timer = settings.invisibility_jumpscare_time;
				EventBus.shells_appear.emit();
		else:
			invisibility_jumpscare_timer -= delta;
			if(invisibility_jumpscare_timer < 0):
				EventBus.shells_disappear.emit();
				var invisibility_time = 1 - (invisibility_timer/settings.serum_invisibility_time);
				invisibility_diming_timer = invisibility_diming_max_timer * settings.invisibility_diming_time_curve.sample(invisibility_time);
		
		if(invisibility_timer <= 0):
			EventBus.shells_appear.emit();
			invisibility_jumpscare_timer = 0;
			invisibility_diming_timer = 0;
	
	if(serum_level > settings.serum_overdose_level && serum_level < settings.serum_critical_level):
		mutation_spawn_timer -= delta;
		if(mutation_spawn_timer <= 0):
			spawn_mutation(); #funkcja resetuje timer

	fog_fade_level -= settings.fog_fade_drop_rate * delta;
	if(fog_fade_level < 0): fog_fade_level = 0;

	# if(Input.is_key_pressed(KEY_P)):
	# 	craving_timer = randf_range(settings.min_craving_timer, settings.max_craving_timer);

	if(environment.fog_density < settings.normal_fog_density):
		environment.fog_density += delta * settings.serum_to_normal_fog_speed;

	var vignette_intensity: float = vignette_texture.material.get_shader_parameter("intensity");
	if(vignette_intensity > 0):
		vignette_texture.material.set_shader_parameter("intensity", vignette_intensity - (delta*settings.serum_to_normal_vignette_speed)); 
	
	var saturation: float = saturation_texture.material.get_shader_parameter("saturation");
	if(saturation < settings.normal_saturation):
		saturation_texture.material.set_shader_parameter("saturation", saturation + (delta*settings.serum_to_normal_saturation_speed));

		
func take_serum():
	serum_level += settings.serum_take_amount;
	invisibility_timer = settings.serum_invisibility_time;
	if(invisibility_timer > 0): EventBus.shells_disappear.emit();
	invisibility_diming_max_timer = settings.invisibility_diming_time;
	invisibility_jumpscare_timer = settings.invisibility_jumpscare_time;

	print("fog fade level: ", fog_fade_level, " / serum level: ", serum_level);
	
	if(serum_level >= fog_fade_level):
		environment.fog_density = settings.serum_fog_density;
		fog_fade_level += settings.fog_fade_addiction_addition;
	if(serum_level < settings.serum_overdose_level):
		set_vignette_parameters(settings.serum_vignette_intensity, 
				settings.serum_vignette_color, settings.serum_vignette_radius);
	elif(serum_level < settings.serum_critical_level):
		mutation_spawn_timer = randf_range(settings.min_mutation_spawn_timer, settings.max_mutation_spawn_timer)
		overtake_timer = randf_range(settings.min_overtake_timer, settings.max_overtake_timer);
		if(ending): overtake_timer = 0;
		overtake_dir = Vector3(randf_range(-1, 1), 0 , randf_range(-1, 1)).normalized();
		saturation_texture.material.set_shader_parameter("saturation", settings.overdose_saturation);
		set_vignette_parameters(settings.serum_overdose_vignette_intensity, 
				settings.serum_overdose_vignette_color, settings.serum_overdose_vignette_radius);
	else:
		overtake_timer = 0;
		craving_timer = randf_range(settings.min_craving_timer, settings.max_craving_timer);
		if(ending): craving_timer = 0;
		saturation_texture.material.set_shader_parameter("saturation", settings.critical_saturation);
		set_vignette_parameters(settings.serum_critical_vignette_intensity, 
				settings.serum_critical_vignette_color, settings.serum_critical_vignette_radius);

func spawn_mutation() -> void:
	var spawn_points = get_tree().get_nodes_in_group("Mutation Spawn Point");
	for i in range(0, spawn_points.size()):
		var spawn_pos: Vector3 = spawn_points[i].global_position;
		var distance: float = (spawn_pos - player.global_position).length();
		if(distance > settings.max_mutation_spawn_range): continue;
		if(distance < settings.min_mutation_spawn_range): continue;
		var mutation_instance = mutation.instantiate();
		get_tree().get_current_scene().add_child(mutation_instance);
		mutation_instance.global_position = spawn_pos;
		mutation_spawn_timer = randf_range(settings.min_mutation_spawn_timer, settings.max_mutation_spawn_timer)
		return;

func restart_timers() -> void:
	craving_timer = randf_range(settings.min_craving_timer, settings.max_craving_timer);
	overtake_timer = randf_range(settings.min_overtake_timer, settings.max_overtake_timer);
	overtake_dir = Vector3(randf_range(-1, 1), 0 , randf_range(-1, 1)).normalized();
	mutation_spawn_timer = randf_range(settings.min_mutation_spawn_timer, settings.max_mutation_spawn_timer)

func set_vignette_parameters(intensity: float, color: Color, radius: float) -> void:
	vignette_texture.material.set_shader_parameter("intensity", intensity);
	vignette_texture.material.set_shader_parameter("vignette_color", color);
	vignette_texture.material.set_shader_parameter("radius", radius);
