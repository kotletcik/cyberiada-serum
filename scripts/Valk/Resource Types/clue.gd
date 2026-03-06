class_name Clue
extends Resource

@export var name: String;
@export var description: String;
@export var ui_pos: Vector2;
@export var clues_to_gather: Array[Clue];
@export var does_automatically_unlock: Array[bool];