@tool
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
@export var automatically_unlock: bool = false : 
    set(value): 
        automatically_unlock = value;
        EditorEventBus.mind_palace_editor_refresh.emit();

@export var required_for_realization: bool = true :
    set(value): 
        required_for_realization = value;
        EditorEventBus.mind_palace_editor_refresh.emit();

@export var connected_note: Note = null;

@export var clue_trigger: triggers;

# @export_group("Clues On Unlock")
@export var clues_to_gather: Array[Clue];
# @export var does_automatically_unlock: Array[bool];

