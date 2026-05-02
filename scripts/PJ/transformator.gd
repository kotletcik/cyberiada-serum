extends StaticBody3D

@export var animator: GPUParticles3D
@onready var mesh := $"MeshInstance3D"
var mat: StandardMaterial3D
var isActive: bool
@export var turned_on_duration:= 2.0
@export var turned_off_duration:= 2.0
@export var noise_volume:= 10.0
var turn_timer:= 0.0
var sound_emitter_duration:= 0.5
var sound_emitter_timer:=0.0
@export var is_activating_by_rock: bool
@export var is_activating_by_player_interaction: bool
@export var is_activating_by_timer: bool = false
@export var rock_activate_duration:= 10.0
@export var rock_activating_timer:= 0.0


func _ready() -> void:
		mat = mesh.get_active_material(0).duplicate()
		mesh.set_surface_override_material(0, mat)
		Activate(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (is_activating_by_timer):
		if (isActive && turn_timer > turned_on_duration):
			Activate(false)
		elif (!isActive && turn_timer > turned_off_duration):
			Activate(true)
		else: turn_timer += delta
	
	if (is_activating_by_rock && isActive):
		if (rock_activating_timer > rock_activate_duration):
			Activate(false)
		else: rock_activating_timer += delta
	
	if (isActive):
		if (sound_emitter_timer > sound_emitter_duration):
			EventBus.sound_emitted_by_player.emit(global_position, noise_volume);
			sound_emitter_timer = 0
		else: sound_emitter_timer += delta

func player_interact():
	if (is_activating_by_player_interaction):
		Activate(!isActive)

func rock_interact():
	if (is_activating_by_rock && !isActive):
		Activate(!isActive)

func Activate(activate: bool = true):
	isActive = activate
	animator.isActive = activate
	if (activate):
		mat.albedo_color = Color.SKY_BLUE
		mat.emission_enabled = true
		mat.emission = Color.SKY_BLUE
		mat.emission_energy_multiplier = 2.0
	else: 
		mat.albedo_color = Color.DIM_GRAY
		mat.emission_enabled = false
	
	turn_timer = 0.0
	rock_activating_timer = 0.0
	sound_emitter_timer = 0.0
