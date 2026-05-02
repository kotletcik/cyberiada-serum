extends GPUParticles3D

@onready var character_body: PhysicsBody3D = $"../"
@export var interval_time: = 1.0
var timer: = 0.0
var isActive: bool = false

func _process(delta: float) -> void:
	if isActive:
		# print(character_body.velocity.length())
		if timer < 0:
			var particles = self
			particles.restart()
			# print("particles")
			timer = interval_time
		else: timer -= delta;
