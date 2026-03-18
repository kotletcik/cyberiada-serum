class_name Save
extends Resource

var checkpoint_exists: bool = false;
var last_player_pos: Vector3 = Vector3(0,0,0);
var last_player_rot: Vector3 = Vector3(0,0,0);
var last_serum_level: float = 0;
var last_fog_fade_level: float = 0;
var last_invisibility_timer: float = 0;

var is_serum_taken: Dictionary[int, bool];
var is_rock_taken: Dictionary[int, bool];
var is_clue_taken: Dictionary[int, bool];

var last_thought_paths: Array[ThoughtPath] = [null];

var last_gathered_clues: Array[Clue] = [null];

var last_shell_positions: Array[Vector3];
var last_shell_rotations: Array[Vector3];

var is_player_crouching: bool;
