extends Node

@onready var character_body: CharacterBody3D = $"../"
@export var interval_time: = 1.0
@export var min_trigger_velocity: = 1.0
var timer: = 0.0

func _process(delta: float) -> void:
	if character_body.velocity.length() > min_trigger_velocity:
		print(character_body.velocity.length())
		# print(character_body.velocity.length())
		if timer < 0:
			var particles = self
			particles.restart()
			# print("particles")
			timer = interval_time
		else: timer -= delta * character_body.velocity.length()
