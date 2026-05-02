extends StaticBody3D

@export var animator: GPUParticles3D
var isActive: bool
@export var turned_on_timer:= 2.0
@export var turned_off_timer:= 2.0
@export var noise_volume:= 10.0
var timer:= 0.0
var sound_emitter_timer:= 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (isActive && timer > turned_on_timer):
		Activate(false)
	elif (!isActive && timer > turned_off_timer):
		Activate(true)
	else: timer += delta
	
	if (isActive):
		EventBus.sound_emitted_by_player.emit(global_position, noise_volume);

func Activate(activate: bool):
	isActive = activate
	animator.isActive = activate
