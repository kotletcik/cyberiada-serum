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

#move_speed określonego state'u, można zmienić w każdym state
@export var move_speed:= 5.0
@export var acceleration: = 1.0
@export var model_color: Color
@onready var state_machine: State_machine = $"../"
var state_is_active: bool = true
signal Transitioned
@export var state_type: types

#Wywoływany zawsze przy przełączeniu na ten state
func Enter():
	state_is_active = true	
	state_machine.nav_agent.move_speed = move_speed
	state_machine.nav_agent.acceleration = acceleration
	#change_color(model_color)
	
#Wywoływany zawsze przy przełączeniu z tego state	
func Exit():
	state_is_active = false

#aktualizowany w state-machine jeśli aktualny state
func Update(_delta: float):
	pass
	
func Physics_Update(_delta: float):
	pass

func change_color(_color: Color):
	state_machine.mat.albedo_color.r = model_color.r
	state_machine.mat.albedo_color.g = model_color.g
	state_machine.mat.albedo_color.b = model_color.b

# func change_state_to(_new_state: int):
# 	state_machine.transit_to_state(self, _new_state)
