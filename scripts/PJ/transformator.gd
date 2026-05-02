extends StaticBody3D

@export var animator: GPUParticles3D
@onready var mesh := $"MeshInstance3D"
var mat: StandardMaterial3D
var isActive: bool
@export var turned_on_timer:= 2.0
@export var turned_off_timer:= 2.0
@export var noise_volume:= 10.0
var timer:= 0.0
var sound_emitter_time:= 0.5
var sound_emitter_timer:=0.0


func _ready() -> void:
		mat = mesh.get_active_material(0).duplicate()
		mesh.set_surface_override_material(0, mat)
		Activate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (isActive && timer > turned_on_timer):
		Activate(false)
	elif (!isActive && timer > turned_off_timer):
		Activate(true)
	else: timer += delta
	
	if (isActive):
		if (sound_emitter_time > sound_emitter_timer):
			EventBus.sound_emitted_by_player.emit(global_position, noise_volume);
			sound_emitter_time = 0
		else: sound_emitter_time += delta

func Activate(activate: bool = false):
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
	timer = 0.0
	sound_emitter_time = 0.0
