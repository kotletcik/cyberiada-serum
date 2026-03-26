class_name Clue
extends Resource

enum triggers
{
    None,
    SomethingUnlocks,
}

@export var name: String;
@export var description: String;
@export var ui_pos: Vector2;
@export var automatically_unlock_path: bool = false;
@export var required_for_realization: bool = true;

# @export var trigger_method_name: String;
@export var clue_trigger: triggers;

@export_group("Clues On Unlock")
@export var clues_to_gather: Array[Clue];
@export var does_automatically_unlock: Array[bool];

