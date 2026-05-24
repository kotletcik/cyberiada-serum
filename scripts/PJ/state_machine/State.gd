extends Node
class_name State

enum types
{
	Wander,
	Follow_player,
	Follow_sound,
	Searching,
	Attack,
	Debuff,
	Patrol,
	Scream
}

@export var move_speed := 5.0
@export var acceleration := 1.0
@export var state_type: types

@onready var state_machine: State_machine = $"../"

func Enter():
	state_machine.nav_agent.move_speed = move_speed
	state_machine.nav_agent.acceleration = acceleration
	
func Exit():
	pass

func Update(_delta: float):
	pass
	
func Physics_Update(_delta: float):
	pass

func update_target_position(pos: Vector3):
	state_machine.nav_agent.update_target_position(pos);
