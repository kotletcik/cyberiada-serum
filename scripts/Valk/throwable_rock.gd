extends RigidBody3D

var player_pos: Vector3;
@onready var signal_emmited: bool = false;
@export var fall_sound_manager: AudioStreamPlayer3D
@export var destroy_time: float;

var timer: float;

func _ready() -> void:
	contact_monitor = true;
	max_contacts_reported = 1;
	continuous_cd = true;
	timer = destroy_time;

func _process(delta: float) -> void:
	timer -= delta;
	if(timer <= 0):
		queue_free();

func _on_body_entered(body: Node) -> void:
	if(signal_emmited): return;
	fall_sound_manager.play();
	if(body.name == "Shell"):
		EventBus.sound_emitted_by_player.emit(player_pos, 1.0);
	elif(body.has_method("rock_interact")):
		body.rock_interact()
	else:
		EventBus.sound_emitted_by_player.emit(global_position, 1.0);
	signal_emmited = true;
	var particles = $GPUParticles3D
	particles.restart()
