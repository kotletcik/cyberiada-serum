class_name ThoughtPath
extends Resource

@export var name: String = "Thought Path";
@export var required_clues: Array[Clue] = [null];
@export var is_clue_realized: Array[bool] = [false];
@export var does_automatically_unlock: Array[bool] = [false];

func is_unlocked() -> bool:
    if(required_clues.size() <= 0 || is_clue_realized.size() <= 0): return false;
    return is_clue_realized[0];
